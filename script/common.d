module script.common;
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
        if (ret == 0)
        {
            stderr.writefln!commandResultFmt(cmd, succeeded);
        }
        else
        {
            stderr.writefln!commandResultFmt(cmd, failed);
        }
        assert(ret == 0, format!"%s@%d: Returns %d"(file, line, ret));
    }
}

void source(string filename)
{
    auto env = format!". %s; env -0"(filename).executeShell;
    assert(env.status == 0);
    foreach (l; env.output.split("\0"))
    {
        auto ll = l.split("=");
        if (ll.length == 2)
        {
            auto key = ll[0];
            auto value = ll[1];
            environment[key] = value;
        }
    }
}
