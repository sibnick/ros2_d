module msg_gen.generator;

import msg_gen.types;
import msg_gen.manifest;
import mustache;
import std.string;
import std.array;
import std.file;
import std.stdio;
import std.typecons;
import msg_gen.util;

alias Mustache = MustacheEngine!string;
alias Context = Mustache.Context;

string createAssignDtoC(in Member member)
{
    const type = member.typeName;
    const isArray = type.isArray;
    const isString = type.namespaced == "string";
    const isPrimitive = cast(bool)(type.namespaced in DToC);
    const field = member.fieldName ~ (isArray ? "[i]" : "");
    const cField = member.fieldName ~ (isArray ? ".data[i]" : "");
    if (isString)
    {
        return format!"rosidl_runtime_c__String__assign(&dst.%s, toStringz(src.%s))"(cField, field);
    }
    else if (isPrimitive)
    {
        return format!"dst.%s = src.%s"(cField, field);
    }
    else
    {
        return format!"%s.convert(src.%s, dst.%s)"(type.namespaced, field, cField);
    }
}

string createAssignCtoD(in Member member)
{
    const type = member.typeName;
    const isArray = type.isArray;
    const isString = type.namespaced == "string";
    const isPrimitive = cast(bool)(type.namespaced in DToC);
    const field = member.fieldName ~ (isArray ? "[i]" : "");
    const cField = member.fieldName ~ (isArray ? ".data[i]" : "");
    if (isString)
    {
        return format!"dst.%s = fromStringz(src.%s.data).dup()"(field, cField);
    }
    else if (isPrimitive)
    {
        return format!"dst.%s = src.%s"(field, cField);
    }
    else
    {
        return format!"%s.convert(src.%s, dst.%s)"(type.namespaced, cField, field);
    }
}

void insert(Context cxt, Member member)
{
    if (member.typeName.isArray)
    {
        cxt.useSection("isArray");
    }
    cxt["type"] = member.typeName.namespaced ~ (member.typeName.isArray ? "[]" : "");
    cxt["cType"] = toC(member.typeName);
    cxt["name"] = member.fieldName;
    cxt["assignDtoC"] = createAssignDtoC(member);
    cxt["assignCtoD"] = createAssignCtoD(member);
    if (!member.defaultValue.isNull)
    {
        cxt["default?"] = ["value": member.defaultValue.get];
    }
}

void insertC(Context cxt, Member member)
{
    cxt["type"] = toC(member.typeName);
    cxt["name"] = member.fieldName;
}

void insert(Context cxt, Structure structure, string namespace_)
{
    auto namespaced = namespace_ ~ "." ~ structure.name;
    cxt["name"] = structure.name;
    cxt["cName"] = toC(Type(namespaced));
    cxt["cArrayName"] = toC(Type(namespaced, true));
    foreach (m; structure.members)
    {
        cxt.addSubContext("members").insert(m);
    }
}

void insertC(Context cxt, Structure structure, string namespace_)
{
    auto namespaced = namespace_ ~ "." ~ structure.name;
    cxt["name"] = toC(Type(namespaced));
    cxt["arrayName"] = toC(Type(namespaced, true));

    foreach (m; structure.members)
    {
        cxt.addSubContext("members").insertC(m);
    }
}

void insert(Context cxt, MessageModule mm)
{
    cxt["moduleName"] = mm.name;
    cxt["cModuleName"] = mm.name.replace(".", ".c.");
    foreach (d; mm.uniqueDepends)
    {
        cxt.addSubContext("depends")["name"] = d;
    }
    foreach (m; mm.messages)
    {
        cxt.addSubContext("messages").insert(m, mm.name);
    }
}

void insertC(Context cxt, MessageModule mm)
{
    cxt["moduleName"] = mm.name.replace(".", ".c.");
    foreach (d; mm.uniqueDepends)
    {
        cxt.addSubContext("depends")["name"] = d.replace(".", ".c.");
    }
    foreach (m; mm.messages)
    {
        cxt.addSubContext("messages").insertC(m, mm.name);
    }
}

class DUBGenerator
{
    private enum dubTmpl = import("generator/pkg/dub.mustache");
    private enum msgTmpl = import("generator/pkg/source/pkg/msg.mustache");
    private enum msgCTmpl = import("generator/pkg/source/pkg/c/msg.mustache");

    private Mustache mustache;

    public string renderMessage(MessageModule mm)
    {
        auto cxt = new Mustache.Context();
        cxt.insert(mm);
        return mustache.renderString(msgTmpl, cxt).trimTrailingWhitespace();
    }

    @("msg.d")
    unittest
    {
        auto mm = MessageModule("test_msgs.msg", [
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
        auto g = new DUBGenerator();
        auto answer = g.renderMessage(mm);
        enum reference = import("test/test_msgs/msg.d");
        assert(answer == reference, "\n" ~ answer);
    }

    public string renderCMessage(MessageModule mm)
    {
        auto cxt = new Mustache.Context();
        cxt.insertC(mm);
        return mustache.renderString(msgCTmpl, cxt).trimTrailingWhitespace();
    }

    @("msg.c")
    unittest
    {
        auto mm = MessageModule("test_msgs.msg", [
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
        auto g = new DUBGenerator();
        auto answer = g.renderCMessage(mm);
        enum reference = import("test/test_msgs/msg_c.d");
        assert(answer == reference, "\n" ~ answer);

        // import std.stdio : writeln;
        // answer.writeln;
    }

    public string renderDUB(const Manifest m)
    {
        auto cxt = new Mustache.Context();
        cxt["package_name"] = m.packageName;
        cxt["version"] = m.version_;
        cxt["installDirectory"] = m.installDirectory;
        foreach (d; m.depends)
        {
            auto sub = cxt.addSubContext("depends");
            sub["name"] = d;
        }

        return mustache.renderString(dubTmpl, cxt).trimTrailingWhitespace();
    }

    @("DUB")
    unittest
    {
        auto g = new DUBGenerator();
        auto m = Manifest();
        m.packageName = "test_msgs";
        m.version_ = "1.0.0";
        m.installDirectory = "install/test_msgs";
        m.message = MessageModule("test_msgs.msg", [
                DependentType("builtin_interfaces.msg.Time"),
            ]);
        auto answer = g.renderDUB(m);
        enum reference = import("test/test_msgs/dub.json");
        assert(answer == reference, "\n" ~ answer);
    }

    public void makePackage(Manifest m, string outDir)
    {
        auto pkgRoot = [outDir, m.packageName].join('/');
        mkdirRecurse(pkgRoot);
        auto dub = File(pkgRoot ~ "/dub.json", "w");
        scope (exit)
            dub.close();
        dub.write(renderDUB(m));
        auto srcDir = [pkgRoot, "source", m.packageName].join('/');
        mkdirRecurse(srcDir);
        mkdirRecurse(srcDir ~ "/c");
        if (m.message.messages.length > 0)
        {
            auto msg = File(srcDir ~ "/msg.d", "w");
            scope (exit)
                msg.close();
            msg.write(renderMessage(m.message));

            auto msg_c = File(srcDir ~ "/c/msg.d", "w");
            scope (exit)
                msg_c.close();
            msg_c.write(renderCMessage(m.message));

        }
    }

    public void makePackageAsDependency(Manifest m, string outDir)
    {
        auto dir = outDir ~ "/" ~ m.packageName ~ "-" ~ m.version_;
        makePackage(m, dir);
        File(dir ~ "/" ~ m.packageName ~ ".lock", "w").close();
    }

}
