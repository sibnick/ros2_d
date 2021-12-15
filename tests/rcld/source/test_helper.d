module test_helper;
import std.conv;
import std.array;
import std.string;

template makeNamespace()
{
    string makeNamespace(string file = __FILE__, int line = __LINE__)()
    {
        return file
            .split("/")[1 .. $].join("_")
            .split(".")[0 .. $ - 1].join("_") ~ "_l" ~ line.to!string;
    }
}
