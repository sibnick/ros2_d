#!/usr/bin/env rdmd
import std;
import common;

enum workingDir = __FILE_FULL_PATH__.dirName.dirName; // to top
alias run = runImpl!workingDir;
alias exec = execImpl!workingDir;

const subs = ["msg_gen", "rcld"];

void helpText()
{
    stderr.writeln("rdmd script/test <sub|tests> <target>");
}

void main(string[] args)
{
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    if (args.length == 1)
    {
        foreach (s; subs)
        {
            format!"dub test :%s"(s).run;
        }
        "ls tests".exec.split.each!(t => format!"rdmd tests/%s/test"(t).run);
    }
    else if (args.length == 3)
    {
        switch (args[1])
        {
        case "sub":
            format!"dub test :%s"(args[2]).run;
            break;
        case "tests":
            format!"rdmd tests/%s/test"(args[2]).run;
            break;
        default:
            helpText();
            break;
        }
    }
    else
    {
        helpText();
    }
}
