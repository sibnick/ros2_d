import std;

enum rootDir = __FILE_FULL_PATH__.dirName;
enum url = "https://github.com/ros2/test_interface_files";

void run(string cmd, string workDir = rootDir)
{
    assert(spawnShell(cmd, environment.toAA, Config.none, workDir).wait == 0);
}

void main()
{
    if (!buildPath(rootDir, "src", "test_interface_files").exists)
    {
        const distro = environment["ROS_DISTRO"];
        const branch = distro == "rolling" ? "master" : distro;
        format!"git clone -b %s %s"(branch, url).run(buildPath(rootDir, "src"));

    }
    "colcon build".run;
}
