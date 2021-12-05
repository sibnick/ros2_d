module msg_gen.generator;

import mustache;
import std.file;
import std.path;

import msg_gen.rosidl.manifest;
import msg_gen.renderers;

void generateDUB(in Manifest m, string outDir)
{
    MustacheEngine!string mustache;
    const pkgRoot = buildPath(outDir, m.packageName);
    mkdirRecurse(pkgRoot);
    write(buildPath(pkgRoot, "dub.json"), renderDUB(mustache, m));

    if (m.hasMessages)
    {
        const srcDir = buildPath(pkgRoot, "source", m.packageName);
        mkdirRecurse(buildPath(srcDir, "c"));
        write(buildPath(srcDir, "msg.d"), renderD(mustache, m.message));
        write(buildPath(srcDir, "c", "msg.d"), renderC(mustache, m.message));
    }
}

@("generateDUB") unittest
{
    import msg_gen.test_helper;
    import msg_gen.rosidl.type;

    const tempDir = makeUniqTemp;

    scope (exit)
    {
        assert(exists(tempDir));
        rmdirRecurse(tempDir);
    }

    const m = TestData.Internal.manifest;

    generateDUB(m, tempDir);

    const dubRoot = buildPath(tempDir, "test_msgs");

    const dubPath = buildPath(dubRoot, "dub.json");
    const dMsgPath = buildPath(dubRoot, "source", "test_msgs", "msg.d");
    const cMsgPath = buildPath(dubRoot, "source", "test_msgs", "c", "msg.d");

    assert(exists(dubPath));
    assert(exists(dMsgPath));
    assert(exists(cMsgPath));

    const dub = readText(dubPath);
    const dMsg = readText(dMsgPath);
    const cMsg = readText(cMsgPath);

    assert(dub == import("test/output/test_msgs/dub.json"), dub);
    assert(dMsg == import("test/output/test_msgs/source/test_msgs/msg.d"), dMsg);
    assert(cMsg == import("test/output/test_msgs/source/test_msgs/c/msg.d"), cMsg);
}

/**
 * Generate DUB package as a dependent module.
 *
 * This function generates a directory which can be recognized as a dependent module.
 * This will produce the following directory tree.
 * ---
 * <outDir>
 * +- <packageName>-<version>
 *    +- <packageName>.lock
 *    +- <packageName>
 *       +- dub.json
 *       +- source
 *          +- <packageName>
 *             +- msg.d
 *             +- c
 *                +- msg.d
 * ---
 * Params:
 *   m = Manifest
 *   outDir = Output directory
 */
void generateDUBAsDepend(in Manifest m, string outDir)
{
    const dir = buildPath(outDir, m.packageName ~ "-" ~ m.version_);

    mkdirRecurse(dir);
    write(buildPath(dir, m.packageName ~ ".lock"), "");

    generateDUB(m, dir);
}

@("generateDUB") unittest
{
    import msg_gen.test_helper;
    import msg_gen.rosidl.type;

    const tempDir = makeUniqTemp;

    scope (exit)
    {
        assert(exists(tempDir));
        rmdirRecurse(tempDir);
    }

    const m = TestData.Internal.manifest;

    generateDUBAsDepend(m, tempDir);

    const depRoot = buildPath(tempDir, "test_msgs-1.2.3");
    const lockPath = buildPath(depRoot, "test_msgs.lock");

    const dubRoot = buildPath(depRoot, "test_msgs");

    const dubPath = buildPath(dubRoot, "dub.json");
    const dMsgPath = buildPath(dubRoot, "source", "test_msgs", "msg.d");
    const cMsgPath = buildPath(dubRoot, "source", "test_msgs", "c", "msg.d");

    assert(exists(lockPath));
    assert(exists(dubPath));
    assert(exists(dMsgPath));
    assert(exists(cMsgPath));

}
