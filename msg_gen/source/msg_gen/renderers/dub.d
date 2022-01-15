module msg_gen.renderers.dub;

import rosidl_parser;
import mustache;
import std.array;
import std.algorithm;
import std.algorithm.comparison;
import std.format;
import std.stdio;

string renderDUB(in Manifest manifest, string[] depends)
{
    auto cxt = new MustacheEngine!string.Context;
    cxt["package_name"] = manifest.packageName;
    cxt["version"] = manifest.version_;
    cxt["installDirectory"] = manifest.installDirectory;

    foreach (d; depends)
    {
        cxt.addSubContext("depends")["name"] = d;
    }

    MustacheEngine!string mustache_;

    return mustache_.renderString(import("renderers/pkg/dub.mustache"), cxt);
}

@("renderDUB") unittest
{

    const m = Manifest("test_msgs", "1.2.3", "install/test_msgs/lib", [
        ], [], []);
    const answer = renderDUB(m, []);
    assert(answer.length > 10);
}
