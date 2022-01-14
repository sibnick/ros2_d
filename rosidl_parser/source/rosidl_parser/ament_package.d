module rosidl_parser.ament_package;

import std.experimental.logger;
import std.file;
import std.process;
import std.string;
import std.path;
import std.array;
import std.algorithm;
import dxml.dom;

/**
 * Ament package manifest.
 */
struct Manifest
{
    /// Package name
    string packageName;
    /// Package version string
    string version_;
    /// Install directory which contains `include`, `lib` and `share`.
    string installDirectory;
    /// Extracted message files
    string[] messageFiles;
    /// Extracted service files
    string[] serviceFiles;
    /// Extracted action files
    string[] actionFiles;
}

/**
 * Find ROSIDL packages at `amentPrefix`
 *
 * This function recognizes ament packages that meet the following conditions
 * - Having `<amentPrefix>/<packageName>/package.xml` -> `<packageName>` as package directory
 * - Having `member_of_group` tag and its text is `rosidl_interface_packages`
 *
 * Params:
 *   amentPrefix = A path to ament prefix
 * Returns: A list of Manifest objects
 */
Manifest[] findROSIDLPackages(string amentPrefix)
{
    tracef("Searching AmentPrefix: %s", amentPrefix);
    Manifest[] manifests;
    foreach (dir; dirEntries(buildPath(amentPrefix, "share"), SpanMode.shallow))
    {
        tracef("Checking directory: %s", dir);
        auto pkgXml = buildPath(dir, "package.xml");
        if (!pkgXml.exists)
        {
            continue;
        }
        tracef("Found %s", pkgXml);
        auto pkg = parseDOM(readText(pkgXml)).getFirst("package");
        if (!pkg.has("member_of_group") || !(pkg.getFirst("member_of_group")
                .getData == "rosidl_interface_packages"))
        {
            continue;
        }
        tracef("Found rosidl_interface_packages at %s", pkgXml);

        Manifest manifest;
        manifest.packageName = pkg.getFirst("name").getData;
        manifest.version_ = pkg.getFirst("version").getData;
        manifest.installDirectory = amentPrefix;
        // TODO: need to parse subdirectory's files
        if (buildPath(dir, "msg").exists)
        {
            manifest.messageFiles = dirEntries(buildPath(dir, "msg"), "*.idl", SpanMode.shallow)
                .map!(d => d.name).array;
        }
        if (buildPath(dir, "srv").exists)
        {
            manifest.serviceFiles = dirEntries(buildPath(dir, "srv"), "*.idl", SpanMode.shallow)
                .map!(d => d.name).array;
        }
        if (buildPath(dir, "action").exists)
        {
            manifest.actionFiles = dirEntries(buildPath(dir, "action"), "*.idl", SpanMode.shallow)
                .map!(d => d.name).array;
        }
        manifests ~= manifest;

    }
    return manifests;
}

@("findROSIDLPackages")
unittest
{
    import test_helper.ament : amentPrefixPath;

    auto manifests = findROSIDLPackages(amentPrefixPath);
    assert(manifests.length == 1);
    auto m = manifests[0];
    assert(m.packageName == "test_msgs");
    assert(m.version_ == "0.1.1");
    assert(m.installDirectory == amentPrefixPath);
    assert(m.messageFiles.length > 0);
    assert(m.serviceFiles.length > 0);
    assert(m.actionFiles.length > 0);
}

/**
 * Find ROSIDL packages from environment variable `AMENT_PREFIX_PATH`
 *
 * Returns: A list of Manifest objects.
 */
Manifest[] findROSIDLPackagesFromEnvironmentVariable()
{
    enum env = "AMENT_PREFIX_PATH";
    tracef(env ~ "=%s", environment.get(env));
    Manifest[] manifests;
    foreach (amentPrefix; environment.get(env).split(":"))
    {
        manifests ~= findROSIDLPackages(amentPrefix);
    }
    return manifests;
}

private auto getFirst(R)(DOMEntity!R entity, string field)
{
    return entity.children.find!(e => (e.type != EntityType.comment && e.name == field)).front;
}

private auto getData(R)(DOMEntity!R entity)
{
    return entity.children[0].text;
}

private auto has(R)(DOMEntity!R entity, string field)
{
    return entity.children.any!(e => (e.type != EntityType.comment && e.name == field));
}
