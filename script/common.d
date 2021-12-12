module common;
import std;

enum reset = "\033[0m";
enum red = "\033[31m";
enum green = "\033[32m";
enum yellow = "\033[33m";

enum commandResultFmt = yellow ~ "%s" ~ reset ~ " : %s";
enum succeeded = green ~ "suceeded" ~ reset;
enum failed = red ~ "failed" ~ reset;

template runImpl(string workingDir)
{
    void runImpl(string file = __FILE__, int line = __LINE__)(string cmd)
    {
        const ret = spawnShell(cmd, environment.toAA, Config.none, workingDir).wait;
        stderr.writefln!commandResultFmt(cmd, ret == 0 ? succeeded : failed);
        assert(ret == 0, format!"%s@%d: Returns %d"(file, line, ret));
    }
}

template execImpl(string workingDir)
{
    string execImpl(string file = __FILE__, int line = __LINE__)(string cmd)
    {
        const ret = executeShell(cmd, environment.toAA, Config.none, size_t.max, workingDir);
        assert(ret.status == 0, format!"%s@%d: Returns %d"(file, line, ret));
        return ret.output;
    }
}

void source(string filename)
{
    auto env = format!". %s; env -0"(filename).executeShell;
    assert(env.status == 0);
    env.output.split("\0").map!(l => l.split("="))
        .filter!(ll => ll.length == 2)
        .each!(ll => environment[ll[0]] = ll[1]);
}
