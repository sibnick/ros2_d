module msg_gen.rosidl.d;

import std.string;
import msg_gen.rosidl.type;

enum basicIDLToD = [ // @suppress(dscanner.performance.enum_array_literal)
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

string toString(Type t)
{
    import std.conv : to;

    string tmp;
    final switch (t.kind)
    {
    case Type.Kind.primitive:
        tmp = basicIDLToD[t.fullname];
        break;
    case Type.Kind.string_:
        tmp = "string";
        break;
    case Type.Kind.nested:
        assert(t.isNamespaced, t.to!string);
        tmp = t.fullname.replace("::", ".");
        break;
    }
    if (t.isArray)
    {
        tmp ~= t.size == 0 ? "[]" : format!"[%d]"(t.size);
    }
    return tmp;
}

string castLiteral(string idl_literal)
{
    return idl_literal;
}

string castArrayLiteral(string idl_literal)
{
    const list = idl_literal[2 .. $ - 2].split(',');
    string[] contents;
    foreach (l; list)
    {
        const tmp = l.strip;
        if (tmp[0] == '\'')
        {
            contents ~= format!"\"%s\""(tmp[1 .. $ - 1]);
        }
        else
        {
            contents ~= tmp;
        }
    }
    return format!"[%-(%s, %)]"(contents);
}
