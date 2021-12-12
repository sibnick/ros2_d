module test_sensor_msgs;
import sensor_msgs.msg;
import std_msgs.msg;
import builtin_interfaces.msg;
import test_helper;

@("CameraInfo") unittest
{
    // To check complex message with array types.
    const a = CameraInfo(
        Header(Time(1, 2), "frame_id"),
        3,
        4,
        "distortion",
        [5, 6],
        [0, 1, 2, 3, 4, 5, 6, 7, 8],
        [1, 2, 3, 4, 5, 6, 7, 8, 9],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        7,
        8,
        RegionOfInterest(9, 10, 11, 12, false)
    );
    mixin ConvertCheck!(a);
    check();
}
