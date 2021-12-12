import std;
import common;

enum workingDir = __FILE_FULL_PATH__.dirName.dirName; // to top
alias run = runImpl!workingDir;

const subs = ["msg_gen", "rcld"];

void main()
{
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    foreach (s; subs)
    {
        format!"dub build :%s"(s).run;
    }
}
