import std;

enum workingDir = __FILE_FULL_PATH__.dirName;

enum reset = "\033[0m";
enum red = "\033[31m";
enum green = "\033[32m";
enum yellow = "\033[33m";

enum commandResultFmt = yellow ~ "%s" ~ reset ~ " : %s";
enum succeeded = green ~ "suceeded" ~ reset;
enum failed = red ~ "failed" ~ reset;

void run(string cmd)
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
    assert(ret == 0, format!"Returns %d"(ret));
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

int main()
{
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    scope (exit)
        "dub remove-local ../../".run;
    "dub add-local ../..".run;
    "dub run ros2_d:msg_gen -- .dub/packages -r".run;
    "dub test".run;

    return 0;
}
