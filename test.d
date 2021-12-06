#!/usr/bin/env rdmd
import std;
import core.stdc.stdlib;

enum reset = "\033[0m";
enum red = "\033[31m";
enum green = "\033[32m";
enum yellow = "\033[33m";

enum commandResultFmt = yellow ~ "%s" ~ reset ~ " : %s";
enum succeeded = green ~ "suceeded" ~ reset;
enum failed = red ~ "failed" ~ reset;

void run(string cmd)
{
    const ret = cmd.spawnShell.wait;
    if (ret == 0)
    {
        stderr.writefln!commandResultFmt(cmd, succeeded);
    }
    else
    {
        stderr.writefln!commandResultFmt(cmd, failed);
        exit(ret);
    }
}

int main()
{
    "dub test ros2_d:msg_gen".run;
    "bash example/test/build_all.sh".run;
    return 0;
}
