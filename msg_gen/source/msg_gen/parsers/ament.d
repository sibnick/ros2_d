module msg_gen.parsers.ament;
import std.process;
import std.stdio;
import std.string;
import std.file;
import msg_gen.rosidl.manifest;
import msg_gen.parsers.package_xml;

string[] getAmentPrefix()
{
    return environment.get("AMENT_PREFIX_PATH").split(":");
}

string[] findAmentPackages(string amentPrefix)
{
    string[] pkgs;
    foreach (dir; dirEntries([amentPrefix, "share"].join("/"), SpanMode.shallow))
    {
        if (exists([dir, "package.xml"].join("/")))
        {
            pkgs ~= dir;
        }
    }
    return pkgs;
}

Manifest[] findMessagePackages(string amentPrefix)
{
    const pkgDirs = findAmentPackages(amentPrefix);
    Manifest[] pkgs;
    foreach (p; pkgDirs)
    {
        auto m = parseROS2Package(p);
        m.installDirectory = amentPrefix;
        if (m.hasMessages())
        {
            pkgs ~= m;
        }
    }
    return pkgs;
}

Manifest[] findMessagePackages()
{
    Manifest[] pkgs;
    foreach (a; getAmentPrefix())
    {
        pkgs ~= findMessagePackages(a);
    }
    return pkgs;
}
