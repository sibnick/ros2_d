module msg_gen.util;

import pegged.grammar;
import std.array;
import std.algorithm;
import std.string;

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

string trimTrailingWhitespace(string text)
{
    return text.split('\n').map!(l => l.stripRight(" ")).join('\n');
}

string[] formatMatrix(string[][] matrix)
{
    import std.format;
    import std.array;
    import std.range;

    auto sizes = new ulong[matrix[0].length];
    foreach (line; matrix)
    {
        foreach (i; 0 .. line.length)
        {
            sizes[i] = max(sizes[i], line[i].length);
        }
    }
    string[] rslt;
    foreach (line; matrix)
    {
        string[] l;
        foreach (i; 0 .. line.length)
        {
            l ~= format!"%*-s"(sizes[i], line[i]);
        }
        rslt ~= l.join(" ");
    }
    return rslt;
}
