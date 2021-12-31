import std;
import common;

enum workingDir = __FILE_FULL_PATH__.dirName.dirName; // to top
alias run = runImpl!workingDir;

void main()
{
    // workaround
    "cp rcl_bind/dub.json rcl_bind/dub.json.back".run;
    scope (exit)
        "mv rcl_bind/dub.json.back rcl_bind/dub.json".run;
    "sed -i -e 's/sourceLibrary/library/g' rcl_bind/dub.json".run;
    source("/opt/ros/$ROS_DISTRO/setup.sh");
    "dub run -y gendoc".run;
}
