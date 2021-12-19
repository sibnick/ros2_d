import std;
import common;

enum workingDir = __FILE_FULL_PATH__.dirName.dirName; // to top
alias run = runImpl!workingDir;

void main()
{
    const items = [
        ".dub",
        "rcld/.dub",
        "rcld/ros2_d*",
        "rcld/libros2_d*",
        "rcl_bind/source/rcl/package.d",
        "msg_gen/.dub",
        "msg_gen/ros2_d*",
        "msg_gen/libros2_d*",
        "example/.dub",
        "example/dub.selections.json",
        "example/bin",
        "example/example",
        "example/ros2_d*",
        "tests/msg_gen/.dub",
        "tests/msg_gen/dub.selections.json",
        "tests/msg_gen/tests-*",
        "tests/rcld/.dub",
        "tests/rcld/dub.selections.json",
        "tests/rcld/tests-*",
        "test_helper/.dub",
        "test_helper/ament/build",
        "test_helper/ament/install",
        "test_helper/ament/log",
        "test_helper/ament/src/test_interfaces"
    ];
    format!"rm -rf %-(%s %)"(items).run;
    "rm -rf -- *.lst".run;
}
