module msg_gen.renderers.c;

import rosidl_parser;
import mustache;
import std.array;
import std.algorithm;
import std.algorithm.comparison;
import std.format;
import std.stdio;

string renderMessage(string packageName, IdlFile!Message[] msgs)
{
    auto cxt = new MustacheEngine!string.Context;
    cxt["moduleName"] = packageName ~ ".c.msg";

    auto includes = msgs.map!(m => m.includes).join();

    auto uniqueIncludes = makeUniqueIncludes(includes, [packageName ~ ".c.msg"]);
    foreach (include; uniqueIncludes)
    {
        cxt.addSubContext("depends")["name"] = include;
    }

    foreach (msg; msgs)
    {
        auto message = msg.data;
        auto messageCxt = cxt.addSubContext("messages");
        auto struct_ = message.structure;
        messageCxt["name"] = struct_.namespacedType.toCTypeName;
        messageCxt["arrayName"] = new UnboundedSequence(struct_.namespacedType).toCTypeName;

        foreach (member; struct_.members)
        {
            auto memberCxt = messageCxt.addSubContext("members");

            if (auto named = cast(NamedType) member.type)
            {
                auto namespaced = new NamespacedType([packageName, "msg"], named.name);
                memberCxt["type"] = msg.typedefMap.get(namespaced, member.type).toCTypeName;
            }
            else
            {
                memberCxt["type"] = member.type.toCTypeName;
            }
            memberCxt["name"] = member.name;
        }

    }
    MustacheEngine!string mustache_;

    return mustache_.renderString(import("renderers/pkg/source/pkg/c/msg.mustache"), cxt);
}

@("renderMessage") unittest
{
    import std;
    import test_helper.ament : amentPrefixPath;

    auto manifests = findROSIDLPackages(amentPrefixPath);
    assert(manifests.length == 1);
    auto manifest = manifests[0];
    IdlFile!Message[] msgs;
    foreach (f; manifest.messageFiles)
    {
        msgs ~= parseAsMessage(readText(f));
    }

    assert(renderMessage(manifest.packageName, msgs).length > 100);
}

private string[] makeUniqueIncludes(Include[] includes, string[] ignoreList)
{
    return includes
        .map!(i => i.locator[1 .. $ - 1]) // trim bracket
        .map!(i => i.split('/')[0 .. $ - 1].join('.')) // get module name
        .map!(i => i.makeCModuleName) // to C module name
        .array
        .sort
        .uniq
        .filter!(i => !ignoreList.canFind(i))
        .array;
}

@("makeUniqueIncludes") unittest
{
    assert(makeUniqueIncludes([
            Include(`"pkgname/msg/MyMessage.idl"`),
            Include(`"pkgname/msg/MyMessage2.idl"`),
            Include(`"this/msg/MyMessage.idl"`)
        ], ["this.c.msg"]) == ["pkgname.c.msg"]);
}

private string makeCModuleName(string moduleName)
{
    auto splitted = moduleName.split('.');
    return (splitted[0 .. $ - 1] ~ "c" ~ splitted[$ - 1]).join('.');
}

@("makeCModuleName") unittest
{
    assert(makeCModuleName("pkgname.msg") == "pkgname.c.msg");
    assert(makeCModuleName("pkgname.foo.msg") == "pkgname.foo.c.msg");
    assert(makeCModuleName("pkgname") == "c.pkgname");
}

// dfmt off
private enum basicTypeToCType = [ // @suppress(dscanner.performance.enum_array_literal)
    "short"              : "int16_t",
    "long"               : "int32_t",
    "long long"          : "int64_t",
    "unsigned short"     : "uint16_t",
    "unsigned long"      : "uint32_t",
    "unsigned long long" : "uint64_t",
    "float"              : "float",
    "double"             : "double",
    "long double"        : "long double",
    "char"               : "char",
    "wchar"              : "uint16_t",
    "boolean"            : "bool",
    "octet"              : "char",
    "int8"               : "int8_t",
    "int16"              : "int16_t",
    "int32"              : "int32_t",
    "int64"              : "int64_t",
    "uint8"              : "uint8_t",
    "uint16"             : "uint16_t",
    "uint32"             : "uint32_t",
    "uint64"             : "uint64_t",
];
// dfmt on

// dfmt off
private enum basicTypeToIDLType = [ // @suppress(dscanner.performance.enum_array_literal)
    "short"              : "int16",
    "long"               : "int32",
    "long long"          : "int64",
    "unsigned short"     : "uint16",
    "unsigned long"      : "uint32",
    "unsigned long long" : "uint64",
    "float"              : "float",
    "double"             : "double",
    "long double"        : "long_double",
    "char"               : "char",
    "wchar"              : "uint16",
    "boolean"            : "bool",
    "octet"              : "octet",
    "int8"               : "int8",
    "int16"              : "int16",
    "int32"              : "int32",
    "int64"              : "int64",
    "uint8"              : "uint8",
    "uint16"             : "uint16",
    "uint32"             : "uint32",
    "uint64"             : "uint64",
];
// dfmt on

private string toCTypeName(in AbstractType type)
{

    string toSequenceType(in AbstractSequence t)
    {
        if (auto b = cast(const(BasicType)) t.valueType)
        {
            return "rosidl_runtime_c__" ~ basicTypeToIDLType[b.name] ~ "__Sequence";
        }
        else
        {
            return t.valueType.toCTypeName ~ "__Sequence";
        }
    }

    // dfmt off
    return (cast(AbstractType) type).castSwitch!(
        (in BasicType t)         => basicTypeToCType[t.name],
        (in NamedType t)         => t.name,
        (in NamespacedType t)    => t.joinedName("__"),
        (in BoundedString t)     => "rosidl_runtime_c__String",
        (in UnboundedString t)   => "rosidl_runtime_c__String",
        (in BoundedWString t)    => "rosidl_runtime_c__U16String",
        (in UnboundedWString t)  => "rosidl_runtime_c__U16String",
        (in ArrayType t)         => t.valueType.toCTypeName ~ "[" ~ t.size ~ "]",
        (in BoundedSequence t)   => toSequenceType(t),
        (in UnboundedSequence t) => toSequenceType(t),
    );
    // dfmt on
}

@("toCTypeName") unittest
{
    AbstractNestableType short_ = new BasicType("short");
    AbstractNestableType myMessage = new NamespacedType(["pkgname", "msg"], "MyMessage");

    assert(toCTypeName(short_) == "int16_t");
    assert(toCTypeName(new NamedType("MyMessage")) == "MyMessage");
    assert(toCTypeName(myMessage) == "pkgname__msg__MyMessage");
    assert(toCTypeName(new BoundedString("123")) == "rosidl_runtime_c__String");
    assert(toCTypeName(new UnboundedString()) == "rosidl_runtime_c__String");
    assert(toCTypeName(new BoundedWString("123")) == "rosidl_runtime_c__U16String");
    assert(toCTypeName(new UnboundedWString()) == "rosidl_runtime_c__U16String");
    assert(toCTypeName(new ArrayType(short_, "3")) == "int16_t[3]");
    assert(toCTypeName(new BoundedSequence(short_, "3")) == "rosidl_runtime_c__int16__Sequence");
    assert(toCTypeName(new UnboundedSequence(short_)) == "rosidl_runtime_c__int16__Sequence");
    assert(toCTypeName(new UnboundedSequence(myMessage)) == "pkgname__msg__MyMessage__Sequence");
}
