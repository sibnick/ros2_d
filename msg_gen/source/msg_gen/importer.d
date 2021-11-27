module msg_gen.importer;

import msg_gen.types;
import msg_gen.util;
import pegged.grammar;
import std.exception;
import std.array;
import std.string;
import std.typecons;

mixin(grammar(import("importer/idl.peg")));

void setMessageModule(ref MessageModule[string] mms, ParseTree p)
{
    string[] moduleName;
    bool[string] moduleNames;
    DependentType[] deps;

    Member parseAsMember(const ParseTree p)
    {
        Nullable!string default_;
        foreach (a; p.all!"Annotation")
        {
            if (a.get!"AnnoType".getData == "@default")
            {
                auto c = a.get!"AnnoContent";
                if (c.has!"Text")
                {
                    default_ = c.get!"Text".getData.nullable;
                }
                else if (c.has!"Number")
                {
                    default_ = c.get!"Number".getData.nullable;
                }
            }
        }
        const type = Type(p.get!"Type".getData.toDTypeIfIsPrimitive.replace("::", "."));
        return Member(
            type,
            p.get!"Field".getData,
            default_);
    }

    Member parseAsArrayMember(const ParseTree p)
    {
        Nullable!string default_;
        foreach (a; p.all!"Annotation")
        {
            if (a.get!"AnnoType".getData == "@default")
            {
                auto arrayLiteral = a.get!"AnnoContent"
                    .get!"Text"
                    .getData;
                auto list = arrayLiteral[2 .. $ - 2].split(',');
                string[] data;
                foreach (l; list)
                {
                    auto tmp = l.strip;
                    if (tmp[0] == '\'')
                    {
                        data ~= "\"" ~ tmp[1 .. $ - 1] ~ "\"";
                    }
                    else
                    {
                        data ~= tmp;
                    }
                }
                default_ = ("[" ~ data.join(", ") ~ "]").nullable;
            }
        }
        const type = Type(p.get!"ArrayType"
                .get!"Type"
                .getData
                .toDTypeIfIsPrimitive
                .replace("::", "."), true);
        return Member(
            type,
            p.get!"Field".getData,
            default_);
    }

    Member parseMember(ParseTree p)
    {
        if (p.has!"Member")
        {
            return parseAsMember(p.get!"Member");
        }
        else if (p.has!"ArrayMember")
        {
            return parseAsArrayMember(p.get!"ArrayMember");
        }
        else
        {
            assert(0);
        }
    }

    Structure parseStruct(ParseTree p)
    {
        Structure s;
        s.name = p.get!"Name".getData();
        foreach (c; p.children)
        {
            if (c.name == "Idl.GeneralMember")
            {
                s.members ~= parseMember(c);
            }
        }
        return s;
    }

    string toDepend(string inc)
    {
        return inc[1 .. $ - 1].split('.')[0].split('/').join('.');
    }

    void parse(ParseTree p)
    {
        switch (p.name)
        {
        case "Idl":
        case "Idl.Sentence":
            foreach (c; p.children)
            {
                parse(c);
            }
            break;
        case "Idl.Module":
            moduleName ~= p.get!"Name".getData();
            foreach (c; p.children)
            {
                parse(c);
            }
            moduleName.length--;
            break;
        case "Idl.Struct":
            auto mn = moduleName.join(".");
            if (mn !in mms)
            {
                mms[mn] = MessageModule(mn);
            }
            moduleNames[mn] = true;
            mms[mn].messages ~= parseStruct(p);
            break;

        case "Idl.Include":
            deps ~= DependentType(toDepend(p.get!"FileName".getData()));
            break;

        case "Idl.Verbatim":
        case "Idl.Comment":
        default:
            break;
        }
    }

    parse(p);

    foreach (mn; moduleNames.byKey)
    {
        mms[mn].depends ~= deps;
    }
}

@("msg")
unittest
{
    import std.conv : to;

    MessageModule[string] mms;
    setMessageModule(mms, Idl(import("test/test_msgs/msg/StandAlone.idl")));
    setMessageModule(mms, Idl(import("test/test_msgs/msg/Depend.idl")));

    assert("test_msgs.msg" in mms);

    auto answer = mms["test_msgs.msg"];
    auto reference = MessageModule("test_msgs.msg", [
            DependentType("builtin_interfaces.msg.Time"),
        ], [
            Message("StandAlone", [
                    Member(Type("bool"), "data1"),
                    Member(Type("int"), "data2", "0".nullable),
                    Member(Type("float"), "data3", "0.0".nullable),
                    Member(Type("string"), "data4", "\"hello\"".nullable),
                    Member(Type("int", true), "array1"),
                    Member(Type("int", true), "array2", "[-1, 0, 1]".nullable),
                    Member(Type("string", true), "array3", "[\"aa\", \"bb\"]".nullable),
                ]),
            Message("Depend", [
                    Member(Type("builtin_interfaces.msg.Time"), "stamp"),
                    Member(Type("string"), "data"),
                ]),
        ]);
    assert(answer == reference, "\n" ~ answer.to!string);
}
