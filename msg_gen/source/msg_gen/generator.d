module msg_gen.generator;

import msg_gen.types;
import msg_gen.manifest;
import mustache;
import std.string;
import std.array;
import std.file;
import std.stdio;

alias Mustache = MustacheEngine!string;
alias Context = Mustache.Context;

void insert(Context cxt, Member member)
{
    cxt["type"] = member.typeName.namespaced ~ (member.typeName.isArray ? "[]" : "");
    cxt["name"] = member.fieldName;
}

void insert(Context cxt, Structure structure)
{
    cxt["name"] = structure.name;
    foreach (m; structure.members)
    {
        cxt.addSubContext("members").insert(m);
    }
}

void insert(Context cxt, MessageModule mm)
{
    cxt["moduleName"] = mm.name;
    foreach (d; mm.uniqueDepends)
    {
        cxt.addSubContext("depends")["name"] = d;
    }
    foreach (m; mm.messages)
    {
        cxt.addSubContext("messages").insert(m);
    }
}

class DUBGenerator
{
    private enum dubTmpl = import("generator/pkg/dub.mustache");
    private enum msgTmpl = import("generator/pkg/source/pkg/msg.mustache");

    private Mustache mustache;

    public string renderMessage(MessageModule mm)
    {
        auto cxt = new Mustache.Context();
        cxt.insert(mm);
        return mustache.renderString(msgTmpl, cxt);
    }

    @("Header Bool")
    unittest
    {
        auto mm = MessageModule("std_msgs.msg", [
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
        auto g = new DUBGenerator();

        auto answer = g.renderMessage(mm);
        enum reference = import("test/std_msgs/header_bool.d");
        assert(answer == reference, "\n" ~ answer);
    }

    @("Int32MultiArray")
    unittest
    {
        auto mm = MessageModule("std_msgs.msg", [
                DependentType("std_msgs.msg.MultiArrayLayout"),
                ], [
                Message("Int32MultiArray", [
                        Member(Type("std_msgs.msg.MultiArrayLayout"), "layout", ""),
                        Member(Type("int", true), "data", ""),
                    ]),
                ]);
        auto g = new DUBGenerator();

        auto answer = g.renderMessage(mm);
        enum reference = import("test/std_msgs/int32_multi_array.d");
        assert(answer == reference, "\n" ~ answer);

    }

    public string renderDUB(string packageName, string[] depends)
    {
        auto cxt = new Mustache.Context();
        cxt["package_name"] = packageName;
        foreach (d; depends)
        {
            auto sub = cxt.addSubContext("depends");
            sub["name"] = d;
        }
        return mustache.renderString(dubTmpl, cxt);
    }

    @("DUB")
    unittest
    {
        auto g = new DUBGenerator();
        auto answer = g.renderDUB("std_msgs", ["builtin_interfaces"]);
        enum reference = import("test/std_msgs/dub.json");
        assert(answer == reference, "\n" ~ answer);
    }

    public void makePackage(Manifest m, string outDir)
    {
        auto pkgRoot = [outDir, m.packageName].join('/');
        mkdirRecurse(pkgRoot);
        auto dub = File(pkgRoot ~ "/dub.json", "w");
        scope (exit)
            dub.close();
        dub.write(renderDUB(m.packageName, m.depends));
        auto srcDir = [pkgRoot, "source", m.packageName].join('/');
        mkdirRecurse(srcDir);
        auto msg = File(srcDir ~ "/msg.d", "w");
        scope (exit)
            msg.close();
        msg.write(renderMessage(m.message));
    }

}
