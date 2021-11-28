/**
 * Internal messages representation
 *
 * - Typename is namespaced with `.` concatting. (e.g. builtin_interfaces.msg.Time)
 * - Extention of IDL file is dropped in the internal representation because of no need to read it recursively.
 */
module msg_gen.types;
import std.string;
import std.array;
import std.typecons;

/// Type representation
/// - namespaced : e.g. std_msgs.msg.Header
/// - primitive  : use d type for consistency with namespaced type. e.g. bool, int, float, ...
/// - array      : do not seperate array and bounded array now. use flag for it
struct Type
{
    string namespaced;
    bool isArray = false;

    string namespace() const @property
    {
        return namespaced.split('.')[0 .. $ - 1].join('.');
    }

    string name() const @property
    {
        return namespaced.split('.')[$ - 1];
    }

    bool isNamespaced() const @property
    {
        return namespaced.split('.').length > 1;
    }
}

struct Member
{
    Type typeName;
    string fieldName;
    Nullable!string defaultValue;
}

struct Structure
{
    string name;
    Member[] members;
}

alias DependentType = Type;
alias Message = Structure;

struct MessageModule
{
    string name;
    DependentType[] depends;
    Message[] messages;

    string[] uniqueDepends() const @property
    {
        string[][string] data;
        foreach (d; depends)
        {
            if (d.namespace == name)
            {
                continue;
            }
            if (d.isNamespaced)
            {
                data[d.namespace] ~= d.name;
            }
        }
        return data.byKey.array;
    }
}

enum OMGToD = [ // @suppress(dscanner.performance.enum_array_literal)
        "boolean": "bool",
        "octet": "byte",
        "int8": "byte",
        "uint8": "ubyte",
        "int16": "short",
        "uint16": "ushort",
        "int32": "int",
        "uint32": "uint",
        "int64": "long",
        "uint64": "ulong",
        "float": "float",
        "double": "double",
    ];

string toDTypeIfIsPrimitive(string type)
{
    if (isPrimitive(type))
    {
        return OMGToD[type];
    }
    else
    {
        return type;
    }
}

bool isPrimitive(string typeName)
{
    return cast(bool)(typeName in OMGToD);
}

enum DToC = [ // @suppress(dscanner.performance.enum_array_literal)
        "bool": "bool",
        "byte": "int8",
        "ubyte": "uint8",
        "short": "int16",
        "ushort": "uint16",
        "int": "int32",
        "uint": "uint32",
        "long": "int64",
        "ulong": "uint64",
        "float": "float",
        "double": "double",
    ];

string toC(Type type_)
{
    if (type_.isArray)
    {
        if (type_.namespaced in DToC)
        {
            return "rosidl_runtime_c__" ~ DToC[type_.namespaced] ~ "__Sequence";
        }
        if (type_.namespaced == "string")
        {
            return "rosidl_runtime_c__String__Sequence";
        }
        return type_.namespaced.replace(".", "__") ~ "__Sequence";
    }
    else
    {
        if (type_.namespaced in DToC)
        {
            return type_.namespaced;
        }
        if (type_.namespaced == "string")
        {
            return "rosidl_runtime_c__String";
        }
        return type_.namespaced.replace(".", "__");
    }
}
