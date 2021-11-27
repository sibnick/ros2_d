module msg_gen.util;

import pegged.grammar;
import std.array;

private enum prefix = "Idl.";

auto get(string field)(const ParseTree p)
{
    foreach (c; p.children)
    {
        if (c.name == prefix ~ field)
        {
            return c;
        }
    }
    assert(0);
}

bool has(string field)(const ParseTree p)
{
    foreach (c; p.children)
    {
        if (c.name == prefix ~ field)
        {
            return true;
        }
    }
    return false;
}

ParseTree[] all(string field)(const ParseTree p)
{
    ParseTree[] rslt;
    foreach (c; p.children)
    {
        if (c.name == prefix ~ field)
        {
            rslt ~= c.dup;
        }
    }
    return rslt;
}

string getData(const ParseTree p)
{
    return p.matches.join();
}
