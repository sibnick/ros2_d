#!/usr/bin/env rdmd
import std;
import script.common;

enum workingDir = __FILE_FULL_PATH__.dirName;
alias run = runImpl!workingDir;

int main(string[] args)
{
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    if (args.length == 1)
    {
        "dub test :msg_gen".run;
        "dub test :rcld".run;
        "rdmd msg_gen/msg_gen_test/test".run;
        "rdmd example/build".run;
    }
    else
    {
        switch (args[1])
        {
        case "msg_gen":
            "dub test :msg_gen".run;
            "rdmd msg_gen/msg_gen_test/test".run;
            break;
        case "example":
            "rdmd example/build".run;
            break;
        case "rcld":
            "dub test :rcld".run;
            break;
        default:
            break;
        }
    }
    return 0;
}
