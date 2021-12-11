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

string runAndGet(string cmd)
{
    writeln(cmd);
    const ret = executeShell(cmd, environment.toAA, Config.none, size_t.max, workingDir);
    assert(ret.status == 0, format!"Returns %d"(ret.status));
    return ret.output;
}

void main()
{
    "dub add-local ..".run;
    scope (exit)
        "dub remove-local ..".run;
    "dub run ros2_d:msg_gen -- .dub/packages -r".run;
    const manifest = "cat dub.json".runAndGet.parseJSON;
    const configs = manifest["configurations"].array.map!(c => c["name"].str).array;
    foreach (c; configs)
    {
        format!"dub build -c %s"(c).run;
    }
}
