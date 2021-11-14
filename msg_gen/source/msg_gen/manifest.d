module msg_gen.manifest;

import msg_gen.types;
import msg_gen.importer;
import std.array;
import std.string;
import std.file;
import std.exception;
import dxml.dom;
import std.stdio;
import std.path;

struct Manifest
{
    string packageName;
    MessageModule message;

    string[] depends() const @property
    {
        string[] deps;
        foreach (d; message.uniqueDepends)
        {
            deps ~= d.split('.')[0];
        }
        return deps;
    }

}

auto get(string field, R)(DOMEntity!R entry)
{
    foreach (e; entry.children)
    {
        if (e.name == field)
        {
            return e;
        }
    }
    assert(0);
}

Manifest loadROS2Package(string root)
{
    enforce(exists(root ~ "/package.xml"));
    auto dom = parseDOM(readText(root ~ "/package.xml"));
    auto pkg = dom.get!"package";
    auto pkgName = pkg.get!"name".children[0].text;
    auto m = Manifest();
    m.packageName = pkgName;

    MessageModule[string] mms;

    const msgDir = root ~ "/msg";
    auto idls = dirEntries(msgDir, "*.idl", SpanMode.depth);

    foreach (idl; idls)
    {
        auto msg = Idl(readText(idl));
        setMessageModule(mms, msg);
    }
    assert(mms.length <= 1);
    foreach (_, mm; mms)
    {
        m.message = mm;
    }
    return m;

}
