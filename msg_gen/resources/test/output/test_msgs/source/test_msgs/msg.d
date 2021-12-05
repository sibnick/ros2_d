// dfmt off
module test_msgs.msg;

import std.string;
import std.utf;
import rcl;
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

    alias CType = test_msgs__msg__StandAlone;
    alias CArrayType = test_msgs__msg__StandAlone__Sequence;

    static const(rosidl_message_type_support_t)* getTypesupport() @nogc nothrow
    {
        return rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__StandAlone();
    }

    static CType* createC() @nogc nothrow
    {
        return test_msgs__msg__StandAlone__create();
    }

    static void destroyC(ref CType * msg) @nogc nothrow
    {
        test_msgs__msg__StandAlone__destroy(msg);
        msg = null;
    }

    static CArrayType *createC(size_t size) @nogc nothrow
    {
        return test_msgs__msg__StandAlone__Sequence__create(size);
    }

    static destroyC(ref CArrayType * msg) @nogc nothrow
    {
        test_msgs__msg__StandAlone__Sequence__destroy(msg);
        msg = null;
    }

    static convert(in StandAlone src, ref StandAlone.CType dst)
    {

        dst.data1 = src.data1;

        dst.data2 = src.data2;

        dst.data3 = src.data3;

        rosidl_runtime_c__String__assign(&dst.data4, toStringz(src.data4));

        rosidl_runtime_c__int32__Sequence__init(&dst.array1, src.array1.length);
        foreach(i;0U..src.array1.length) {
            dst.array1.data[i] = src.array1[i];
        }

        rosidl_runtime_c__int32__Sequence__init(&dst.array2, src.array2.length);
        foreach(i;0U..src.array2.length) {
            dst.array2.data[i] = src.array2[i];
        }

        rosidl_runtime_c__String__Sequence__init(&dst.array3, src.array3.length);
        foreach(i;0U..src.array3.length) {
            rosidl_runtime_c__String__assign(&dst.array3.data[i], toStringz(src.array3[i]));
        }

    }

    static convert(in StandAlone.CType src, out StandAlone dst)
    {

        dst.data1 = src.data1;

        dst.data2 = src.data2;

        dst.data3 = src.data3;

        dst.data4 = fromStringz(src.data4.data).dup();

        dst.array1.length = src.array1.size;
        foreach(i;0U..src.array1.size) {
            dst.array1[i] = src.array1.data[i];
        }

        dst.array2.length = src.array2.size;
        foreach(i;0U..src.array2.size) {
            dst.array2[i] = src.array2.data[i];
        }

        dst.array3.length = src.array3.size;
        foreach(i;0U..src.array3.size) {
            dst.array3[i] = fromStringz(src.array3.data[i].data).dup();
        }

    }
}

struct Depend
{
    builtin_interfaces.msg.Time stamp;
    string data;

    alias CType = test_msgs__msg__Depend;
    alias CArrayType = test_msgs__msg__Depend__Sequence;

    static const(rosidl_message_type_support_t)* getTypesupport() @nogc nothrow
    {
        return rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__Depend();
    }

    static CType* createC() @nogc nothrow
    {
        return test_msgs__msg__Depend__create();
    }

    static void destroyC(ref CType * msg) @nogc nothrow
    {
        test_msgs__msg__Depend__destroy(msg);
        msg = null;
    }

    static CArrayType *createC(size_t size) @nogc nothrow
    {
        return test_msgs__msg__Depend__Sequence__create(size);
    }

    static destroyC(ref CArrayType * msg) @nogc nothrow
    {
        test_msgs__msg__Depend__Sequence__destroy(msg);
        msg = null;
    }

    static convert(in Depend src, ref Depend.CType dst)
    {

        builtin_interfaces.msg.Time.convert(src.stamp, dst.stamp);

        rosidl_runtime_c__String__assign(&dst.data, toStringz(src.data));

    }

    static convert(in Depend.CType src, out Depend dst)
    {

        builtin_interfaces.msg.Time.convert(src.stamp, dst.stamp);

        dst.data = fromStringz(src.data.data).dup();

    }
}
