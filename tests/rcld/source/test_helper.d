module test_helper;
import std.conv;
import std.array;
import std.string;

template makeNamespace()
{
    string makeNamespace(string file = __FILE__, int line = __LINE__)()
    {
        auto id = file
            .split("/")[1 .. $].join("_")
            .split(".")[0 .. $ - 1].join("_") ~ "_l" ~ line.to!string;
        version (foxy)
        {
            id ~= "_foxy";
        }
        version (galactic)
        {
            id ~= "_galactic";
        }
        version (rolling)
        {
            id ~= "_rolling";
        }
        version (humble)
        {
            id ~= "_humble";
        }
        return id;
    }
}
