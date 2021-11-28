import std.stdio;
import std_msgs.msg;
import std_msgs.c.msg;

void main()
{
    auto m = Header();
    m.writeln;
    auto cm = std_msgs__msg__Header__create();
    writeln(*cm);
    std_msgs__msg__Header__destroy(cm);
}
