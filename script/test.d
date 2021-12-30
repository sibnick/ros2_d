#!/usr/bin/env rdmd
import std;
import common;

enum workingDir = __FILE_FULL_PATH__.dirName.dirName; // to top
alias run = runImpl!workingDir;
alias exec = execImpl!workingDir;

void helpText(Config[] configs)
{
    stderr.writeln("rdmd script/test <dub|test> <target>");
    stderr.writefln!"%-(  %s\n%)"(configs.to!(string[]));
}

void testDUB(string target)
{
    format!"dub test :%s --coverage"(target).run;
}

void testTests(string target)
{
    format!"rdmd tests/%s/test"(target).run;
}

const dubList = ["msg_gen", "rcld", "rosidl_parser"];
const testList = ["msg_gen", "rcld"];

struct Config
{
    string type;
    string target;

    string toString() const
    {
        return type ~ " " ~ target;
    }
}

alias Runner = void function(string);

void main(string[] args)
{
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    Runner[Config] configs;
    foreach (dub; dubList)
    {
        configs[Config("dub", dub)] = &testDUB;
    }
    foreach (test; testList)
    {
        configs[Config("test", test)] = &testTests;
    }
    if (args.length == 1)
    {
        configs.each!((c, f) { f(c.target); });
    }
    else if (args.length == 3)
    {
        auto c = Config(args[1], args[2]);
        if (c in configs)
        {
            configs[c](c.target);
        }
        else
        {
            helpText(configs.keys);
        }
    }
    else
    {
        helpText(configs.keys);
    }
}
