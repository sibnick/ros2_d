module test_std_msgs;
import std_msgs.msg;
import test_helper;

@("ColorRGBA") unittest
{
    // To check simple message.
    const a = ColorRGBA(0, 1, 2, 3);
    mixin ConvertCheck!(a);
    check();
}
