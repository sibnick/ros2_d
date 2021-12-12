#!/usr/bin/env rdmd
import std;
import script.common;

enum workingDir = __FILE_FULL_PATH__.dirName;
alias run = runImpl!workingDir;

void main(string[] args)
{
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    if (args.length == 1)
    {
        "dub build :msg_gen".run;
        "dub build :rcld".run;
    }
    else
    {
        switch (args[1])
        {
        case "msg_gen":
            "dub build :msg_gen".run;
            break;
        case "rcld":
            "dub build :rcld".run;
            break;
        default:
            break;
        }
    }

}
