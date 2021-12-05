module msg_gen.rosidl.c;

import msg_gen.rosidl.type;
import std.format;
import std.array;

/**
 * A map of IDL to C type
 */
enum basicIDLToC = [ // @suppress(dscanner.performance.enum_array_literal)
        "float": "float",
        "double": "double",
        "char": "char",
        "wchar": "uint16_t",
        "boolean": "bool",
        "octet": "char",
        "uint8": "uint8_t",
        "int8": "int8_t",
        "uint16": "uint16_t",
        "int16": "int16_t",
        "uint32": "uint32_t",
        "int32": "int32_t",
        "uint64": "uint64_t",
        "int64": "int64_t",
    ];

/**
 * Create a C type string
 * Params:
 *   t = Type
 * Returns: C type string
 */
string toString(Type t)
{
    if (t.isArray)
    {
        final switch (t.kind)
        {
        case Type.Kind.primitive:
            return format!"rosidl_runtime_c__%s__Sequence"(t.fullname);
        case Type.Kind.string_:
            return "rosidl_runtime_c__String__Sequence";
        case Type.Kind.nested:
            assert(t.isNamespaced);
            return t.fullname.replace("::", "__") ~ "__Sequence";
        }
    }
    else
    {
        final switch (t.kind)
        {
        case Type.Kind.primitive:
            return basicIDLToC[t.fullname];
        case Type.Kind.string_:
            return "rosidl_runtime_c__String";
        case Type.Kind.nested:
            assert(t.isNamespaced);
            return t.fullname.replace("::", "__");
        }
    }
}

@("toString") unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;

    assert(Type("int32", false).toString() == "int32_t");
    assert(Type("int32", true).toString() == "rosidl_runtime_c__int32__Sequence");

    assert(Type("string", false).toString() == "rosidl_runtime_c__String");
    assert(Type("string", true).toString() == "rosidl_runtime_c__String__Sequence");

    assert(Type("std_msgs::msg::Header", false).toString() == "std_msgs__msg__Header");
    assert(Type("std_msgs::msg::Header", true).toString() == "std_msgs__msg__Header__Sequence");

    assertThrown!AssertError(Type("Header", false).toString());
}
