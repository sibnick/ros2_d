#!/usr/bin/env rdmd
// Before you run this script, you need to `source /opt/ros/$ROS_DISTRO/setup.sh`.
// And then run `rdmd build`. Every configurations in the `configurations` sections
// are built respectively.

import std;

enum workingDir = __FILE_FULL_PATH__.dirName;

void run(string cmd)
{
    writeln(cmd);
    const ret = spawnShell(cmd, environment.toAA, Config.none, workingDir).wait;
    assert(ret == 0, format!"Returns %d"(ret));
}

string exec(string cmd)
{
    writeln(cmd);
    const ret = executeShell(cmd, environment.toAA, Config.none, size_t.max, workingDir);
    assert(ret.status == 0, format!"Returns %d"(ret.status));
    return ret.output;
}

void main()
{
    "dub run --root .. ros2_d:msg_gen -- .dub/packages -r".run;
    "cat dub.json"
        .exec
        .parseJSON["configurations"]
        .array
        .map!(c => c["name"].str)
        .each!(c => format!"dub build -c %s"(c).run);
}
