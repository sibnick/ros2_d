import std;
import common;

enum workingDir = __FILE_FULL_PATH__.dirName.dirName; // to top
alias run = runImpl!workingDir;

void main()
{
    auto items = ["docs"];

    // packages
    immutable packages = [
        ".",
        "msg_gen",
        "rcl_bind",
        "rcld",
        "rosidl_parser",
        "test_helper",
    ];

    foreach (pkg; packages)
    {
        foreach (t; [".dub", "ros2_d*", "libros2_d*"])
        {
            items ~= buildPath(pkg, t);
        }
    }

    // example
    immutable examplePackagesTargets = [
        "msg_gen": "msg_gen_example",
        "rcl": "rcl_example",
        "rcld": "bin",
    ];
    foreach (pkg, target; examplePackagesTargets)
    {
        foreach (t; [".dub", "dub.selections.json", target])
        {
            items ~= buildPath("example", pkg, t);
        }
    }

    // tests
    immutable testPackages = [
        "msg_gen",
        "rcld",
    ];
    foreach (pkg; testPackages)
    {
        foreach (t; [".dub", "dub.selections.json", "tests-*"])
        {
            items ~= buildPath("tests", pkg, t);
        }
    }

    // ament
    foreach (t; ["build", "install", "log", "src/test_interfaces"])
    {
        items ~= buildPath("test_helper", "ament", t);
    }

    // rcl_bind
    items ~= buildPath("rcl_bind", "source", "rcl", "package.d");

    format!"rm -rf %-(%s %)"(items).run;
    "rm -rf -- *.lst".run;
}
