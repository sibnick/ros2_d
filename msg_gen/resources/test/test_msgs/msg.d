// dfmt off
module test_msgs.msg;

import std.string;
import std.utf;
import test_msgs.c.msg;
import builtin_interfaces.msg;

struct StandAlone
{
    bool data1;
    int data2 = 0;
    float data3 = 0.0;
    string data4 = "hello";
    int[] array1;
    int[] array2 = [-1, 0, 1];
    string[] array3 = ["aa", "bb"];
}

struct Depend
{
    builtin_interfaces.msg.Time stamp;
    string data;
}
