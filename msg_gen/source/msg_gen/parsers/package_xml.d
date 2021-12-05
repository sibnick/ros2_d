module msg_gen.parsers.package_xml;

import msg_gen.rosidl.manifest;
import msg_gen.parsers.idl;
import dxml.dom;
import std.path;
import std.range;
import std.algorithm;
import std.file;
import std.exception;

private auto getFirst(string field, R)(DOMEntity!R entity)
{
    return entity.children.find!(e => (e.type != EntityType.comment && e.name == field)).front;
}

private auto getData(R)(DOMEntity!R entity)
{
    return entity.children[0].text;
}

private auto has(string field, R)(DOMEntity!R entity)
{
    return entity.children.any!(e => (e.type != EntityType.comment && e.name == field));
}

Manifest parseROS2Package(string root)
{
    import std.stdio;
    import colorize;

    enforce(exists(root ~ "/package.xml"));
    auto m = Manifest();

    auto dom = parseDOM(readText(root ~ "/package.xml"));
    auto pkg = dom.getFirst!"package"; // <package format="3"> ... </package>
    m.packageName = pkg.getFirst!"name".getData;
    m.version_ = pkg.getFirst!"version".getData;

    if (!(pkg.has!"member_of_group" && pkg.getFirst!"member_of_group".getData == "rosidl_interface_packages"))
    {
        return m;
    }

    // find msg
    const msgDir = root ~ "/msg";
    if (msgDir.exists)
    {
        auto idls = dirEntries(msgDir, "*.idl", SpanMode.shallow);
        auto parser = new Parser();

        foreach (idl; idls)
        {
            parser.consume(readText(idl));
        }
        if (parser.messageModules.length == 1)
        {
            m.message = parser.messageModules.values[0];
        }
        else
        {
            stderr.writefln!"%s: Cannot parse pacakge %s at %s"("Warning".color(fg.yellow), m.packageName.style(
                    mode.bold), root);
        }

    }

    return m;
}

@("parseROS2Package") unittest
{
    import std.format;
    import msg_gen.test_helper;

    // deploy package in temp directory
    const tempDir = makeUniqTemp;
    scope (exit)
    {
        assert(exists(tempDir));
        rmdirRecurse(tempDir);
    }

    const msgDir = buildPath(tempDir, "msg");
    msgDir.mkdirRecurse;

    write(buildPath(tempDir, "package.xml"), TestData.Input.packageXml);
    write(buildPath(tempDir, "msg", "StandAline.idl"), TestData.Input.standAloneIdl);
    write(buildPath(tempDir, "msg", "Depend.idl"), TestData.Input.dependIdl);

    const answer = parseROS2Package(tempDir);

    assert(answer.packageName == TestData.packageName);
    assert(answer.version_ == TestData.version_);
    assert(answer.installDirectory == ""); // Need to be filled later
    assert(answer.depends.length == 1);
    assert(answer.message.messages.length == 2);
}
