// dfmt off
module test_msgs.c.msg;

import core.stdc.stdint;
import rcl;
import builtin_interfaces.c.msg;

extern (C):
@nogc:
nothrow:

struct test_msgs__msg__StandAlone
{
    bool data1;
    int32_t data2;
    float data3;
    rosidl_runtime_c__String data4;
    rosidl_runtime_c__int32__Sequence array1;
    rosidl_runtime_c__int32__Sequence array2;
    rosidl_runtime_c__String__Sequence array3;
}

struct test_msgs__msg__StandAlone__Sequence
{
    test_msgs__msg__StandAlone *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__StandAlone__init(test_msgs__msg__StandAlone * msg);
void test_msgs__msg__StandAlone__fini(test_msgs__msg__StandAlone * msg);
test_msgs__msg__StandAlone * test_msgs__msg__StandAlone__create();
void test_msgs__msg__StandAlone__destroy(test_msgs__msg__StandAlone * msg);
bool test_msgs__msg__StandAlone__Sequence__init(test_msgs__msg__StandAlone__Sequence * array, size_t size);
void test_msgs__msg__StandAlone__Sequence__fini(test_msgs__msg__StandAlone__Sequence * array);
test_msgs__msg__StandAlone__Sequence * test_msgs__msg__StandAlone__Sequence__create(size_t size);
void test_msgs__msg__StandAlone__Sequence__destroy(test_msgs__msg__StandAlone__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__StandAlone();

struct test_msgs__msg__Depend
{
    builtin_interfaces__msg__Time stamp;
    rosidl_runtime_c__String data;
}

struct test_msgs__msg__Depend__Sequence
{
    test_msgs__msg__Depend *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__Depend__init(test_msgs__msg__Depend * msg);
void test_msgs__msg__Depend__fini(test_msgs__msg__Depend * msg);
test_msgs__msg__Depend * test_msgs__msg__Depend__create();
void test_msgs__msg__Depend__destroy(test_msgs__msg__Depend * msg);
bool test_msgs__msg__Depend__Sequence__init(test_msgs__msg__Depend__Sequence * array, size_t size);
void test_msgs__msg__Depend__Sequence__fini(test_msgs__msg__Depend__Sequence * array);
test_msgs__msg__Depend__Sequence * test_msgs__msg__Depend__Sequence__create(size_t size);
void test_msgs__msg__Depend__Sequence__destroy(test_msgs__msg__Depend__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__Depend();

struct test_msgs__msg__Constant
{
    uint8_t data;
}

struct test_msgs__msg__Constant__Sequence
{
    test_msgs__msg__Constant *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__Constant__init(test_msgs__msg__Constant * msg);
void test_msgs__msg__Constant__fini(test_msgs__msg__Constant * msg);
test_msgs__msg__Constant * test_msgs__msg__Constant__create();
void test_msgs__msg__Constant__destroy(test_msgs__msg__Constant * msg);
bool test_msgs__msg__Constant__Sequence__init(test_msgs__msg__Constant__Sequence * array, size_t size);
void test_msgs__msg__Constant__Sequence__fini(test_msgs__msg__Constant__Sequence * array);
test_msgs__msg__Constant__Sequence * test_msgs__msg__Constant__Sequence__create(size_t size);
void test_msgs__msg__Constant__Sequence__destroy(test_msgs__msg__Constant__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__Constant();

struct test_msgs__msg__FixedArray
{
    double[10] data;
}

struct test_msgs__msg__FixedArray__Sequence
{
    test_msgs__msg__FixedArray *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__FixedArray__init(test_msgs__msg__FixedArray * msg);
void test_msgs__msg__FixedArray__fini(test_msgs__msg__FixedArray * msg);
test_msgs__msg__FixedArray * test_msgs__msg__FixedArray__create();
void test_msgs__msg__FixedArray__destroy(test_msgs__msg__FixedArray * msg);
bool test_msgs__msg__FixedArray__Sequence__init(test_msgs__msg__FixedArray__Sequence * array, size_t size);
void test_msgs__msg__FixedArray__Sequence__fini(test_msgs__msg__FixedArray__Sequence * array);
test_msgs__msg__FixedArray__Sequence * test_msgs__msg__FixedArray__Sequence__create(size_t size);
void test_msgs__msg__FixedArray__Sequence__destroy(test_msgs__msg__FixedArray__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__FixedArray();
