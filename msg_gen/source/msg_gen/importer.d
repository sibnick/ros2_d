module msg_gen.importer;

import msg_gen.types;
import msg_gen.util;
import pegged.grammar;
import std.exception;
import std.array;
import std.string;

mixin(grammar(import("importer/idl.peg")));

void setMessageModule(ref MessageModule[string] mms, ParseTree p)
{
    string[] moduleName;
    bool[string] moduleNames;
    DependentType[] deps;

    Member parseMember(ParseTree p)
    {
        const isArray = p.has!"ArrayType";
        const typeParsed = isArray ? p.get!"ArrayType"
            .get!"Type" : p.get!"Type";
        const type = Type(typeParsed.getData.toDTypeIfIsPrimitive.replace("::", "."), isArray);

        return Member(
                type,
                p.get!"Field".getData(),
                "");
    }

    Structure parseStruct(ParseTree p)
    {
        Structure s;
        s.name = p.get!"Name".getData();
        foreach (c; p.children)
        {
            if (c.name == "Idl.Member")
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

@("Header Bool")
unittest
{
    import std.conv : to;

    MessageModule[string] mms;
    setMessageModule(mms, Idl(import("test/std_msgs/Header.idl")));
    setMessageModule(mms, Idl(import("test/std_msgs/Bool.idl")));

    assert("std_msgs.msg" in mms);

    auto answer = mms["std_msgs.msg"];
    auto reference = MessageModule("std_msgs.msg", [
            DependentType("builtin_interfaces.msg.Time"),
            ], [
            Message("Header", [
                    Member(Type("builtin_interfaces.msg.Time"), "stamp", ""),
                    Member(Type("string"), "frame_id", ""),
                ]),
            Message("Bool", [
                    Member(Type("bool"), "data", ""),
                ]),
            ]);
    assert(answer == reference, "\n" ~ answer.to!string);
}

@("Int32MultiArray")
unittest
{
    import std.conv : to;

    MessageModule[string] mms;
    setMessageModule(mms, Idl(import("test/std_msgs/Int32MultiArray.idl")));

    assert("std_msgs.msg" in mms);

    auto answer = mms["std_msgs.msg"];
    auto reference = MessageModule("std_msgs.msg", [
            DependentType("std_msgs.msg.MultiArrayLayout"),
            ], [
            Message("Int32MultiArray", [
                    Member(Type("std_msgs.msg.MultiArrayLayout"), "layout", ""),
                    Member(Type("int", true), "data", ""),
                ]),
            ]);

    assert(answer == reference, "\n" ~ answer.to!string);

}
