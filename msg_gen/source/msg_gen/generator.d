module msg_gen.generator;

import mustache;
import std.file;
import std.path;
import std.array;
import std.algorithm;
import std.algorithm.comparison;

import rosidl_parser;
import msg_gen.renderers.d : renderMessageD = renderMessage, renderServiceD = renderService;
import msg_gen.renderers.c : renderMessageC = renderMessage, renderServiceC = renderService;
import msg_gen.renderers.dub;

void generateDUB(in Manifest manifest, string outDir)
{
    const pkgRoot = buildPath(outDir, manifest.packageName);
    mkdirRecurse(pkgRoot);

    Include[] includes;

    auto msgs = manifest.messageFiles.map!(f => parseAsMessage(readText(f))).array;
    if (msgs)
    {
        const srcDir = buildPath(pkgRoot, "source", manifest.packageName);
        mkdirRecurse(buildPath(srcDir, "c"));
        write(buildPath(srcDir, "msg.d"), renderMessageD(manifest.packageName, msgs));
        write(buildPath(srcDir, "c", "msg.d"), renderMessageC(manifest.packageName, msgs));
    }
    includes ~= msgs.map!(m => m.includes).join();

    auto srvs = manifest.serviceFiles.map!(f => parseAsService(readText(f))).array;
    if (srvs)
    {
        const srcDir = buildPath(pkgRoot, "source", manifest.packageName);
        mkdirRecurse(buildPath(srcDir, "c"));
        write(buildPath(srcDir, "srv.d"), renderServiceD(manifest.packageName, srvs));
        write(buildPath(srcDir, "c", "srv.d"), renderServiceC(manifest.packageName, srvs));
    }
    includes ~= srvs.map!(s => s.includes).join();

    auto depends = makeUniqueDepends(includes, [manifest.packageName]);

    write(buildPath(pkgRoot, "dub.json"), renderDUB(manifest, depends));

}

@("generateDUB test_msgs") unittest
{
    import test_helper.utils;
    import test_helper.ament : amentPrefixPath;

    auto manifests = findROSIDLPackages(amentPrefixPath);
    assert(manifests.length == 1);
    auto manifest = manifests[0];

    auto name = manifest.packageName;

    const tempDir = makeUniqTemp;

    scope (exit)
    {
        assert(exists(tempDir));
        rmdirRecurse(tempDir);
    }

    generateDUB(manifest, tempDir);

    const dubRoot = buildPath(tempDir, name);

    const dubPath = buildPath(dubRoot, "dub.json");
    const dMsgPath = buildPath(dubRoot, "source", name, "msg.d");
    const cMsgPath = buildPath(dubRoot, "source", name, "c", "msg.d");

    assert(exists(dubPath));
    assert(exists(dMsgPath));
    assert(exists(cMsgPath));
}

void generateDUBAsDepend(in Manifest m, string outDir)
{
    const dir = buildPath(outDir, m.packageName ~ "/" ~ m.version_);

    mkdirRecurse(dir);
    write(buildPath(dir, m.packageName ~ ".lock"), "");

    generateDUB(m, dir);
}

private string[] makeUniqueDepends(Include[] includes, string[] ignoreList)
{
    return includes
        .map!(i => i.locator[1 .. $ - 1]) // trim bracket
        .map!(i => i.split('/')[0]) // get module name
        .array // to array to sort
        .sort // sort to apply uniq
        .uniq // get uniq
        .filter!(i => !ignoreList.canFind(i)) // delete items appeared in ignoreList
        .array; // to array
}

@("makeUniqueDepends") unittest
{
    assert(makeUniqueDepends([
            Include(`"pkgname/msg/MyMessage.idl"`),
            Include(`"pkgname/msg/MyMessage2.idl"`),
            Include(`"this/msg/MyMessage.idl"`)
        ], ["this"]) == ["pkgname"]);
}
