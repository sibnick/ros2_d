module msg_gen.rosidl.type;

import std.algorithm;
import std.array;
import std.typecons;

/**
 * A list of basic type of IDL usable in this package
 */
enum basicIDL = [ // @suppress(dscanner.performance.enum_array_literal)
        "float",
        "double",
        "long double",
        "char",
        "wchar",
        "octet",
        "boolean",
        "uint8",
        "int8",
        "uint16",
        "int16",
        "uint32",
        "int32",
        "uint64",
        "int64",
    ];

/**
 * Judge if `typename` is primitive or not
 * Params:
 *   typename = Typename text
 * Returns: is primitive or not
 */
bool isPrimitive(string typename)
{
    return basicIDL.canFind(typename);
}

/**
 * Type representation of IDL
 */
struct Type
{
    enum Kind
    {
        primitive,
        string_,
        nested
    }

    /**
     * Fullname of the type
     *
     * Examples:
     * - `std_msgs::msg::Header` for nested type
     * - `string`` for string type
     * - `int32` for primitive type (see `basicIDL` for full list)
     */
    string fullname;
    /**
     * Is array or not
     */
    bool isArray;

    /**
     * Returns: Type kind of the type by seeing `fullname` text
     */
    Kind kind() const @property
    {
        if (isPrimitive(fullname))
        {
            return Kind.primitive;
        }
        else if (fullname == "string")
        {
            return Kind.string_;
        }
        else
        {
            return Kind.nested;
        }
    }

    /**
     *
     * Returns: Namespace of the type (e.g. `std_msgs::msg::Header` -> `std_msgs::msg`)
     */
    string namespace() const @property
    {
        return fullname.split("::")[0 .. $ - 1].join("::");
    }

    /**
     *
     * Returns: Short name of the type (e.g. `std_msgs::msg::Header` -> `Header`)
     */
    string shortName() const @property
    {
        return fullname.split("::")[$ - 1];
    }

    /**
     *
     * Returns: Type name having namespace
     */
    bool isNamespaced() const @property
    {
        return fullname.split("::").length > 1;
    }

    /**
     * Returns: Non array version of the type
     */
    Type asPlain() const @property
    {
        return Type(fullname, false);
    }

    @("kind extraction") unittest
    {
        // Check supported primitive types
        foreach (t; [
                "double",
                "char",
                "wchar",
                "boolean",
                "uint8",
                "int8",
                "uint16",
                "int16",
                "uint32",
                "int32",
                "uint64",
                "int64",
            ])
        {
            assert(Type(t, false).kind == Kind.primitive, t);
        }
        // Check string
        assert(Type("string", false).kind == Kind.string_);

        // Check nested
        assert(Type("Header", false).kind == Kind.nested);
        assert(Type("std_msgs::msg::Header", false).kind == Kind.nested);
    }

    @("namespace parsing") unittest
    {
        assert(Type("Header", false).isNamespaced == false);
        assert(Type("std_msgs::msg::Header", false).isNamespaced == true);

        assert(Type("Header", false).shortName == "Header");
        assert(Type("std_msgs::msg::Header", false).shortName == "Header");

        assert(Type("Header", false).namespace == "");
        assert(Type("std_msgs::msg::Header", false).namespace == "std_msgs::msg");
    }

}

/**
 * Member representation of IDL
 */
struct Member
{
    /**
     * Type of the member
     */
    Type type;
    /**
     * Field name of the member
     */
    string field;
    /**
     * Default value as a string (optional)
     */
    Nullable!string defaultText;
    /**
     * Comment text (optional)
     */
    Nullable!string comment;

    /**
     * Ditto
     */
    this(typeof(this.tupleof) args)
    {
        this.tupleof = args;
    }

    /**
     * Ditto
     */
    this(Type type, string field, string defaultText, string comment)
    {
        this(type, field, defaultText.nullable, comment.nullable);
    }

    /**
     * Ditto
     */
    this(Type type, string field, string defaultText)
    {
        this(type, field, defaultText.nullable, Nullable!string());
    }

    /**
     * Ditto
     */
    this(Type type, string field, Nullable!string defaultText, string comment)
    {
        this(type, field, defaultText, comment.nullable);
    }

    /**
     * Ditto
     */
    this(Type type, string field)
    {
        this(type, field, Nullable!string(), Nullable!string());
    }

}

/**
 * Constant value representation of IDL
 */
struct Constant
{
    /**
     * Type of the field
     */
    Type type;
    /**
     * Field name
     */
    string field;
    /**
     * Value as a string
     */
    string valueString;
}

/**
 * Struct representation of IDL
 */
struct Structure
{
    /**
     * Full name of the struct
     */
    string fullname;
    /**
     * A list of members
     */
    Member[] members;
    /**
     * A list of constants
     */
    Constant[] constants;
    /**
     * Comment text (optional)
     */
    Nullable!string comment;

    /**
     * Returns: Short name of the struct (e.g. `std_msgs::msg::Header` -> `Header`)
     */
    string shortName() const @property
    {
        return fullname.split("::")[$ - 1];
    }

    /**
     * Returns: Namespace of the struct (e.g. `std_msgs::msg::Header` -> `std_msgs::msg`)
     */
    string namespace() const @property
    {
        return fullname.split("::")[0 .. $ - 1].join("::");
    }

    @("namespace parsing") unittest
    {
        assert(Structure("Header", []).shortName == "Header");
        assert(Structure("std_msgs::msg::Header", []).shortName == "Header");
    }
}

/**
 * Message (.msg) representation of ROSIDL
 */
struct MessageModule
{
    /**
     * Fullname of the module
     */
    string fullname;
    /**
     * A list of dependent types
     */
    Type[] depends;
    /**
     * A list of messages in the module
     */
    Structure[] messages;

    /**
     *
     * Returns: A list of dependent modules
     */
    string[] uniqueDependModules() const @property
    {
        return depends.filter!(d => (d.kind == Type.Kind.nested && d.isNamespaced && d.namespace != fullname))
            .map!(d => d.namespace)
            .array
            .sort
            .uniq
            .array;
    }

    @("uniqueDependModules") unittest
    {
        import std.algorithm : sort, equal;

        assert(equal(MessageModule("test_msgs::msg", [
                    Type("std_msgs::msg::Header", false),
                    Type("std_msgs::msg::String", true),
                    Type("string", false),
                    Type("builtin_interfaces::msg::Time", false),
                ], []).uniqueDependModules.sort, [
                    "builtin_interfaces::msg", "std_msgs::msg"
                ]));
    }
}
