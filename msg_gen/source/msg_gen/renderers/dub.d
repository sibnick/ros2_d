module msg_gen.renderers.dub;

import mustache;
import msg_gen.rosidl.manifest;
import msg_gen.rosidl.type;
import msg_gen.util;

private enum tmpl = import("renderers/pkg/dub.mustache");

template Context(T)
{
    alias Context = MustacheEngine!T.Context;
}

string render(T)(MustacheEngine!T mustache, in Manifest m)
{
    auto cxt = new Context!T();
    cxt["package_name"] = m.packageName;
    cxt["version"] = m.version_;
    cxt["installDirectory"] = m.installDirectory;
    foreach (d; m.depends)
    {
        cxt.addSubContext("depends")["name"] = d;
    }

    return mustache.renderString(tmpl, cxt).trimTrailingWhitespace();
}

@("render") unittest
{
    import test_helper.test_msgs : TestMsgs;

    const m = Manifest(TestMsgs.name, TestMsgs.version_, "install/test_msgs/lib", MessageModule(
            TestMsgs.name ~ "::msg"));
    MustacheEngine!string mustache;
    const answer = render(mustache, m);
    const reference = import("test/output/test_msgs/dub.json");
    assert(answer == reference, answer);
}
