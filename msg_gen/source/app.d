import msg_gen;
import std.stdio;
import std.file;

void main(string[] args)
{
    auto g = new DUBGenerator();
    auto m = loadROS2Package(args[1]);
    g.makePackage(m, args[2]);

}
