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

@("render DUB") unittest
{
    import msg_gen.test_helper;

    auto m = TestData.Internal.manifest;

    MustacheEngine!string mustache;
    const answer = render(mustache, m);
    assert(answer == TestData.Output.dubJson, answer);
}
