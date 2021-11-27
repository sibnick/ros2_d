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
    string version_;

    bool hasMessages() const
    {
        return message.messages.length != 0;
    }

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
        if (e.type == EntityType.comment)
        {
            continue;
        }
        if (e.name == field)
        {
            return e;
        }
    }
    assert(0);
}

auto has(string field, R)(DOMEntity!R entry)
{
    foreach (e; entry.children)
    {
        if (e.type == EntityType.comment)
        {
            continue;
        }
        if (e.name == field)
        {
            return true;
        }
    }
    return false;
}

Manifest loadROS2Package(string root)
{
    enforce(exists(root ~ "/package.xml"));
    auto m = Manifest();

    auto dom = parseDOM(readText(root ~ "/package.xml"));
    auto pkg = dom.get!"package";
    auto pkgName = pkg.get!"name".children[0].text;
    m.packageName = pkgName;
    m.version_ = pkg.get!"version".children[0].text;

    if (!(pkg.has!"member_of_group" && pkg.get!"member_of_group".children[0].text == "rosidl_interface_packages"))
    {
        return m;
    }

    const msgDir = root ~ "/msg";
    if (msgDir.exists)
    {
        MessageModule[string] mms;

        auto idls = dirEntries(msgDir, "*.idl", SpanMode.shallow);

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

    }

    return m;

}
