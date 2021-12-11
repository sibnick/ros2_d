module msg_gen.parsers.idl;

import std.algorithm;
import std.array;
import std.typecons;
import std.container : SList;
import std.conv : to;
import pegged.grammar;
import msg_gen.rosidl.type;

import std.stdio;

private:
mixin(grammar(import("parsers/idl.peg")));

// helpers
enum prefix = "Idl";
template tag(string k)
{
    string tag()
    {
        return [prefix, k].join(".");
    }
}

auto getFirst(string field)(in ParseTree p)
{
    return p.children.find!(c => c.name == tag!field).front;
}

bool has(string field)(in ParseTree p)
{
    return p.children.any!(c => c.name == tag!field);
}

auto all(string field)(in ParseTree p)
{
    return p.children.filter!(c => c.name == tag!field);
}

string getData(in ParseTree p)
{
    return p.matches.join();
}

string getLiteral(in ParseTree p)
{
    if (p.has!"Text")
    {
        return p.getFirst!"Text".getData;
    }
    else if (p.has!"Number")
    {
        return p.getFirst!"Number".getData;
    }
    else
    {
        assert(0);
    }
}

public:
/**
 * IDL parser
 *
 * This class reads IDL files and holds them as an internal representation.
 * "Internal representation" is defined in msg_gen.rosidl.type.
 */
class Parser
{
    /**
     * Holds pared messages as [moduleName -> moduleManifest]
     */
    MessageModule[string] messageModules;

    private class Impl
    {
        struct Annotation
        {
            string name;
            string[string] content;
        }

        SList!string moduleName;
        SList!Structure struct_;

        Type[] depends;
        Structure[] structs;
        Constant[][string] constants;
        Type[string] typedefMap;

        void parseModule(in ParseTree p)
        {
            moduleName.insert(p.getFirst!"Name".getData);
            p.children.each!(c => parse(c));
            moduleName.removeAny();
        }

        void parseStruct(in ParseTree p)
        {
            const name = p.getFirst!"Name".getData;
            const fullname = (moduleName.array.reverse ~ name).join("::");
            struct_.insert(Structure(fullname, []));
            auto annotations = p.all!"Annotation"
                .map!(a => parseAnnotation(a));
            foreach (a; annotations)
            {
                if (a.name == "@verbatim" && a.content.get("language", "") == "\"comment\"" && "text" in a
                    .content)
                {
                    struct_.front.comment = a.content["text"].nullable;
                }
            }
            p.children.each!(c => parse(c));
            structs ~= struct_.front;
            struct_.removeAny();
        }

        void parseConstant(in ParseTree p)
        {
            const mod = moduleName.array.reverse.join("::");
            assert(mod.endsWith("_Constants"), mod);
            const t = p.getFirst!"Type".getData;
            const f = p.getFirst!"Field".getData;
            const v = p.getFirst!"AnyLiteral".getLiteral;

            constants.require(moduleName.array.reverse.join("::"), []) ~= Constant(Type(t, false), f, v);
        }

        void parseTypedef(in ParseTree p)
        {
            const t = p.getFirst!"Type".getData;
            const f = p.getFirst!"ArrayField"
                .getFirst!"Field"
                .getData;
            const s = p.getFirst!"ArrayField"
                .getFirst!"Unsigned"
                .getData
                .to!int;

            typedefMap[f] = Type(t, true, s);
        }

        void parseMember(in ParseTree p, bool isArray)
        {
            const type = isArray ? p.getFirst!"ArrayType"
                .getFirst!"Type"
                .getData : p.getFirst!"Type".getData;
            const field = p.getFirst!"Field".getData;
            Nullable!string defaultText;
            Nullable!string comment;

            auto annotations = p.all!"Annotation"
                .map!(a => parseAnnotation(a));
            foreach (a; annotations)
            {
                switch (a.name)
                {
                case "@verbatim":
                    if (a.content.get("language", "") == "\"comment\"" && "text" in a.content)
                    {
                        comment = a.content["text"].nullable;
                    }
                    break;
                case "@default":
                    defaultText = a.content["value"].nullable;
                    break;
                default:
                    break;
                }
            }

            const solvedType = typedefMap.get(type, Type(type, isArray));

            const member = Member(solvedType, field, defaultText, comment);
            struct_.front.members ~= member;
        }

        Annotation parseAnnotation(in ParseTree p)
        {
            Annotation a;
            a.name = p.getFirst!"AnnoType".getData;
            foreach (c; p.all!"AnnoContent")
            {
                const k = c.getFirst!"Type".getData;
                if (c.has!"Text")
                {
                    a.content[k] = c.getFirst!"Text".getData;
                }
                else if (c.has!"Number")
                {
                    a.content[k] = c.getFirst!"Number".getData;
                }
            }
            return a;
        }

        void parseInclude(in ParseTree p)
        {
            const tmp = p.getFirst!"FileName".getData[1 .. $ - 1].split('.')[0].replace("/", "::");
            depends ~= Type(tmp, false);

        }

        void parse(in ParseTree p)
        {
            switch (p.name)
            {
            case tag!"Module":
                parseModule(p);
                break;
            case tag!"Constant":
                parseConstant(p);
                break;
            case tag!"Typedef":
                parseTypedef(p);
                break;
            case tag!"Struct":
                parseStruct(p);
                break;
            case tag!"Member":
                parseMember(p, false);
                break;
            case tag!"ArrayMember":
                parseMember(p, true);
                break;
            case tag!"Include":
                parseInclude(p);
                break;
            default:
                p.children.each!(c => parse(c));
                break;
            }
        }
    }

    /**
     * Parse IDL text and hold it
     * Params:
     *   data = IDL text
     */
    bool consume(string data)
    {
        import std;

        const idl = Idl(data);
        auto impl = new Impl();
        impl.parse(idl);
        byte[string] modules;
        if (impl.structs.length == 0)
        {
            return false;
        }
        foreach (s; impl.structs)
        {
            const mod = s.namespace;
            modules[mod] = 0;
            messageModules.require(mod, MessageModule(mod, [], [])).messages ~= s;
        }
        foreach (m, cs; impl.constants)
        {
            const type = m[0 .. $ - "_Constants".length];
            const mod = type.split("::")[0 .. $ - 1].join("::");

            if (messageModules.require(mod, MessageModule(mod, [], []))
                .messages.canFind!"a.fullname == b"(type))
            {
                messageModules[mod].messages.find!"a.fullname == b"(type).front.constants ~= cs;
            }
            else
            {
                messageModules[mod].messages ~= Structure(type, [], cs);
            }
        }
        foreach (m; modules.byKey)
        {
            messageModules[m].depends ~= impl.depends;
        }
        return true;
    }

    @("one file : StandAlone") unittest
    {
        import std.conv : to;
        import msg_gen.test_helper;

        const mod = TestData.packageName ~ "::msg";

        auto parser = new Parser();
        parser.consume(TestData.Input.standAloneIdl);

        assert(parser.messageModules.length == 1);
        assert(mod in parser.messageModules);

        const answer = parser.messageModules[mod];
        const reference = MessageModule(mod, [], [TestData.Internal.standAlone]);
        assert(answer == reference, answer.to!string);
    }

    @("one file : Depend") unittest
    {
        import std.conv : to;
        import msg_gen.test_helper;

        const mod = TestData.packageName ~ "::msg";

        auto parser = new Parser();

        parser.consume(TestData.Input.dependIdl);

        assert(parser.messageModules.length == 1);
        assert(mod in parser.messageModules);

        const answer = parser.messageModules[mod];
        const reference = MessageModule(mod, [TestData.Internal.builtinType], [
                TestData.Internal.depend
            ]);
        assert(answer == reference, answer.to!string);
    }

    @("one file : Constant") unittest
    {
        import std.conv : to;
        import msg_gen.test_helper;

        const mod = TestData.packageName ~ "::msg";

        auto parser = new Parser();

        parser.consume(TestData.Input.constantIdl);

        assert(parser.messageModules.length == 1);
        assert(mod in parser.messageModules);
        const answer = parser.messageModules[mod];
        const reference = MessageModule(mod, [], [TestData.Internal.constant]);

        assert(answer == reference, answer.to!string);

    }

    @("one file : FixedArray") unittest
    {
        import std.conv : to;
        import msg_gen.test_helper;

        const mod = TestData.packageName ~ "::msg";

        auto parser = new Parser();

        parser.consume(TestData.Input.fixedArrayIdl);

        assert(parser.messageModules.length == 1);
        assert(mod in parser.messageModules);
        const answer = parser.messageModules[mod];
        const reference = MessageModule(mod, [], [TestData.Internal.fixedArray]);

        assert(answer == reference, answer.to!string);
    }

    @("multiple files") unittest
    {
        import std.conv : to;
        import msg_gen.test_helper;

        const mod = TestData.packageName ~ "::msg";

        auto parser = new Parser();

        parser.consume(TestData.Input.standAloneIdl);
        parser.consume(TestData.Input.dependIdl);
        parser.consume(TestData.Input.constantIdl);
        parser.consume(TestData.Input.fixedArrayIdl);

        assert(parser.messageModules.length == 1);
        assert(mod in parser.messageModules);

        const answer = parser.messageModules["test_msgs::msg"];
        const reference = TestData.Internal.manifest.message;
        assert(answer == reference, answer.to!string);
    }
}
