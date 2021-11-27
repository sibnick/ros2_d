import msg_gen;
import std.stdio;
import std.file;

void main(string[] args)
{
    auto g = new DUBGenerator();
    auto packages = findMessagePackages();
    foreach (p; packages)
    {
        g.makePackageAsDependency(p, args[1]);
    }
}
