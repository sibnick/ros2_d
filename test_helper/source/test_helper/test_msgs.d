module test_helper.test_msgs;
import std.typecons;

enum NotSupported;

/**
 * Holds package.xml and IDL files as strings
 */
static struct TestMsgs
{
    enum name = "test_msgs";
    enum version_ = "0.1.1";

    enum packageXML = import("package.xml");

    struct Msg
    {
        // TODO: need to support array of nested type
        @NotSupported enum Arrays = import("msg/Arrays.idl");
        enum BasicTypes = import("msg/BasicTypes.idl");
        // Skip rolling specific type
        version (rolling) @NotSupported enum BoundedPlainSequences = import(
                "msg/BoundedPlainSequences.idl");
        // TODO: need to support bounded array
        @NotSupported enum BoundedSequences = import("msg/BoundedSequences.idl");
        // TODO: need to check the reason of the failure
        @NotSupported enum Constants = import("msg/Constants.idl");
        // TODO: need to check the reason of the failure
        @NotSupported enum Defaults = import("msg/Defaults.idl");
        enum Empty = import("msg/Empty.idl");
        // TODO: need to check the reason of the failure
        @NotSupported enum MultiNested = import("msg/MultiNested.idl");
        enum Nested = import("msg/Nested.idl");
        // TODO: need to support bounded string
        @NotSupported enum Strings = import("msg/Strings.idl");
        // TODO: need to support bounded string
        @NotSupported enum WStrings = import("msg/WStrings.idl");
    }
}

struct Type
{
    string name;
    enum Kind
    {
        plain,
        dynamicArray,
        staticArray,
        boundedArray,
    }

    Kind kind;
    int size;

    /**
     * p : plain
     * d : dynamicArray,
     * s : stataicArray,
     * b : boundedArray
     */
    this(string name, char kind = 'p', int size = 0)
    {
        this.name = name;
        this.size = size;
        switch (kind)
        {
        case 'p':
            this.kind = Kind.plain;
            break;
        case 'd':
            this.kind = Kind.dynamicArray;
            break;
        case 's':
            this.kind = Kind.staticArray;
            break;
        case 'b':
            this.kind = Kind.boundedArray;
            break;
        default:
            assert(false);
        }
    }
}

struct Member
{
    Type type;
    string field;
    Nullable!string default_;

    this(Type type, string field, string default_ = "")
    {
        this.type = type;
        this.field = field;
        this.default_ = default_ == "" ? Nullable!string() : default_.nullable;
    }
}

static struct TestMsgsData
{
    static struct Msg
    {
        enum name = "test_msgs::msg";
        static struct Arrays
        {
            enum name = "test_msgs::msg::Arrays";
            static const members = [
                Member(Type("boolean", 's', 3), "bool_values"),
                Member(Type("octet", 's', 3), "byte_values"),
                Member(Type("uint8", 's', 3), "char_values"),
                Member(Type("float", 's', 3), "float32_values"),
                Member(Type("double", 's', 3), "float64_values"),
                Member(Type("int8", 's', 3), "int8_values"),
                Member(Type("uint8", 's', 3), "uint8_values"),
                Member(Type("int16", 's', 3), "int16_values"),
                Member(Type("uint16", 's', 3), "uint16_values"),
                Member(Type("int32", 's', 3), "int32_values"),
                Member(Type("uint32", 's', 3), "uint32_values"),
                Member(Type("int64", 's', 3), "int64_values"),
                Member(Type("uint64", 's', 3), "uint64_values"),
                Member(Type("string", 's', 3), "string_values"),
                Member(Type("test_msgs::msg::BasicTypes", 's', 3), "basic_types_values"),
                Member(Type("test_msgs::msg::Constants", 's', 3), "constants_values"),
                Member(Type("test_msgs::msg::Defaults", 's', 3), "defaults_values"),
                Member(Type("boolean", 's', 3), "bool_values", `"(False, True, False)"`),
                Member(Type("octet", 's', 3), "byte_values", `"(0, 1, 255)"`),
                Member(Type("uint8", 's', 3), "char_values", `"(0, 1, 127)"`),
                Member(Type("float", 's', 3), "float32_values", `"(1.125, 0.0, -1.125)"`),
                Member(Type("double", 's', 3), "float64_values", `"(3.1415, 0.0, -3.1415)"`),
                Member(Type("int8", 's', 3), "int8_values", `"(0, 127, -128)"`),
                Member(Type("uint8", 's', 3), "uint8_values", `"(0, 1, 255)"`),
                Member(Type("int16", 's', 3), "int16_values", `"(0, 32767, -32768)"`),
                Member(Type("uint16", 's', 3), "uint16_values", `"(0, 1, 65535)"`),
                Member(Type("int32", 's', 3), "int32_values", `"(0, 2147483647, -2147483648)"`),
                Member(Type("uint32", 's', 3), "uint32_values", `"(0, 1, 4294967295)"`),
                Member(Type("int64", 's', 3), "int64_values", `"(0, 9223372036854775807, -9223372036854775808)"`),
                Member(Type("uint64", 's', 3), "uint64_values", `"(0, 1, 18446744073709551615)"`),
                Member(Type("string", 's', 3), "string_values", `"('', 'max value', 'min value')"`),
                Member(Type("int32", 'p', 0), "alighment_check"),
            ];
        }

        static struct BasicTypes
        {
            enum name = "test_msgs::msg::BasicTypes";
            static const members = [
                Member(Type("boolean"), "bool_value"),
                Member(Type("octet"), "byte_value"),
                Member(Type("uint8"), "char_value"),
                Member(Type("float"), "float32_value"),
                Member(Type("double"), "float64_value"),
                Member(Type("int8"), "int8_value"),
                Member(Type("uint8"), "uint8_value"),
                Member(Type("int16"), "int16_value"),
                Member(Type("uint16"), "uint16_value"),
                Member(Type("int32"), "int32_value"),
                Member(Type("uint32"), "uint32_value"),
                Member(Type("int64"), "int64_value"),
                Member(Type("uint64"), "uint64_value"),
            ];
        }

        static struct Empty
        {
            enum name = "test_msgs::msg::Empty";
            static const members = [
                Member(Type("uint8"), "structure_needs_at_least_one_member"),
            ];
        }

        static struct Nested
        {
            enum name = "test_msgs::msg::Nested";
            static const members = [
                Member(Type("test_msgs::msg::BasicTypes"), "basic_types_value"),
            ];
        }
    }
}
