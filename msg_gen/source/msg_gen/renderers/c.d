module msg_gen.renderers.c;

private enum tmpl = import("renderers/pkg/source/pkg/c/msg.mustache");

import mustache;
import msg_gen.rosidl.type;
import msg_gen.rosidl.c;
import msg_gen.util;
import std.array;

template Context(T)
{
    alias Context = MustacheEngine!T.Context;
}

void insert(T)(Context!T cxt, in Member member)
{
    cxt["type"] = member.type.toString;
    cxt["name"] = member.field;
}

void insert(T)(Context!T cxt, in Structure struct_)
{
    cxt["name"] = Type(struct_.fullname, false).toString;
    cxt["arrayName"] = Type(struct_.fullname, true).toString;

    foreach (m; struct_.members)
    {
        cxt.addSubContext("members").insert!T(m);
    }
}

void insert(T)(Context!T cxt, in MessageModule mm)
{
    cxt["moduleName"] = mm.fullname.replace("::", ".c.");
    foreach (d; mm.uniqueDependModules)
    {
        cxt.addSubContext("depends")["name"] = d.replace("::", ".c.");
    }
    foreach (m; mm.messages)
    {
        cxt.addSubContext("messages").insert!T(m);
    }
}

string render(T)(MustacheEngine!T mustache, in MessageModule mm)
{
    auto cxt = new Context!T();
    cxt.insert!T(mm);
    return mustache.renderString(tmpl, cxt).trimTrailingWhitespace();
}

@("render MessageModule") unittest
{
    import msg_gen.test_helper;

    const data = TestData.Internal.manifest.message;

    MustacheEngine!string mustache;
    const answer = render(mustache, data);
    assert(answer == TestData.Output.cMsgD, answer);
}
