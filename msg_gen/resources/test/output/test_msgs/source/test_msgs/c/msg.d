// dfmt off
module test_msgs.c.msg;

import core.stdc.stdint;
import rcl;

extern (C):
@nogc:
nothrow:

struct test_msgs__msg__Arrays
{
    bool[3] bool_values;
    char[3] byte_values;
    uint8_t[3] char_values;
    float[3] float32_values;
    double[3] float64_values;
    int8_t[3] int8_values;
    uint8_t[3] uint8_values;
    int16_t[3] int16_values;
    uint16_t[3] uint16_values;
    int32_t[3] int32_values;
    uint32_t[3] uint32_values;
    int64_t[3] int64_values;
    uint64_t[3] uint64_values;
    rosidl_runtime_c__String[3] string_values;
    test_msgs__msg__BasicTypes[3] basic_types_values;
    test_msgs__msg__Constants[3] constants_values;
    test_msgs__msg__Defaults[3] defaults_values;
    bool[3] bool_values;
    char[3] byte_values;
    uint8_t[3] char_values;
    float[3] float32_values;
    double[3] float64_values;
    int8_t[3] int8_values;
    uint8_t[3] uint8_values;
    int16_t[3] int16_values;
    uint16_t[3] uint16_values;
    int32_t[3] int32_values;
    uint32_t[3] uint32_values;
    int64_t[3] int64_values;
    uint64_t[3] uint64_values;
    rosidl_runtime_c__String[3] string_values;
    int32_t alighment_check;
}

struct test_msgs__msg__Arrays__Sequence
{
    test_msgs__msg__Arrays *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__Arrays__init(test_msgs__msg__Arrays * msg);
void test_msgs__msg__Arrays__fini(test_msgs__msg__Arrays * msg);
test_msgs__msg__Arrays * test_msgs__msg__Arrays__create();
void test_msgs__msg__Arrays__destroy(test_msgs__msg__Arrays * msg);
bool test_msgs__msg__Arrays__Sequence__init(test_msgs__msg__Arrays__Sequence * array, size_t size);
void test_msgs__msg__Arrays__Sequence__fini(test_msgs__msg__Arrays__Sequence * array);
test_msgs__msg__Arrays__Sequence * test_msgs__msg__Arrays__Sequence__create(size_t size);
void test_msgs__msg__Arrays__Sequence__destroy(test_msgs__msg__Arrays__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__Arrays();

struct test_msgs__msg__BasicTypes
{
    bool bool_value;
    char byte_value;
    uint8_t char_value;
    float float32_value;
    double float64_value;
    int8_t int8_value;
    uint8_t uint8_value;
    int16_t int16_value;
    uint16_t uint16_value;
    int32_t int32_value;
    uint32_t uint32_value;
    int64_t int64_value;
    uint64_t uint64_value;
}

struct test_msgs__msg__BasicTypes__Sequence
{
    test_msgs__msg__BasicTypes *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__BasicTypes__init(test_msgs__msg__BasicTypes * msg);
void test_msgs__msg__BasicTypes__fini(test_msgs__msg__BasicTypes * msg);
test_msgs__msg__BasicTypes * test_msgs__msg__BasicTypes__create();
void test_msgs__msg__BasicTypes__destroy(test_msgs__msg__BasicTypes * msg);
bool test_msgs__msg__BasicTypes__Sequence__init(test_msgs__msg__BasicTypes__Sequence * array, size_t size);
void test_msgs__msg__BasicTypes__Sequence__fini(test_msgs__msg__BasicTypes__Sequence * array);
test_msgs__msg__BasicTypes__Sequence * test_msgs__msg__BasicTypes__Sequence__create(size_t size);
void test_msgs__msg__BasicTypes__Sequence__destroy(test_msgs__msg__BasicTypes__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__BasicTypes();

struct test_msgs__msg__Empty
{
    uint8_t structure_needs_at_least_one_member;
}

struct test_msgs__msg__Empty__Sequence
{
    test_msgs__msg__Empty *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__Empty__init(test_msgs__msg__Empty * msg);
void test_msgs__msg__Empty__fini(test_msgs__msg__Empty * msg);
test_msgs__msg__Empty * test_msgs__msg__Empty__create();
void test_msgs__msg__Empty__destroy(test_msgs__msg__Empty * msg);
bool test_msgs__msg__Empty__Sequence__init(test_msgs__msg__Empty__Sequence * array, size_t size);
void test_msgs__msg__Empty__Sequence__fini(test_msgs__msg__Empty__Sequence * array);
test_msgs__msg__Empty__Sequence * test_msgs__msg__Empty__Sequence__create(size_t size);
void test_msgs__msg__Empty__Sequence__destroy(test_msgs__msg__Empty__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__Empty();

struct test_msgs__msg__Nested
{
    test_msgs__msg__BasicTypes basic_types_value;
}

struct test_msgs__msg__Nested__Sequence
{
    test_msgs__msg__Nested *data;
    size_t size;
    size_t capacity;
}

bool test_msgs__msg__Nested__init(test_msgs__msg__Nested * msg);
void test_msgs__msg__Nested__fini(test_msgs__msg__Nested * msg);
test_msgs__msg__Nested * test_msgs__msg__Nested__create();
void test_msgs__msg__Nested__destroy(test_msgs__msg__Nested * msg);
bool test_msgs__msg__Nested__Sequence__init(test_msgs__msg__Nested__Sequence * array, size_t size);
void test_msgs__msg__Nested__Sequence__fini(test_msgs__msg__Nested__Sequence * array);
test_msgs__msg__Nested__Sequence * test_msgs__msg__Nested__Sequence__create(size_t size);
void test_msgs__msg__Nested__Sequence__destroy(test_msgs__msg__Nested__Sequence * array);
const(rosidl_message_type_support_t) * rosidl_typesupport_c__get_message_type_support_handle__test_msgs__msg__Nested();
