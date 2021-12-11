module msg_gen.renderers.d;

import mustache;
import msg_gen.rosidl.type;
import msg_gen.rosidl.d : dToString = toString, castLiteral, castArrayLiteral;
import msg_gen.rosidl.c : cToString = toString;
import msg_gen.util;
import std.array;
import std.format;
import std.string;

private enum tmpl = import("renderers/pkg/source/pkg/msg.mustache");

template Context(T)
{
    alias Context = MustacheEngine!T.Context;
}

string createAssignDtoC(in Member member)
{
    const type = member.type;
    const dField = member.field ~ (type.isArray ? "[i]" : "");
    const cField = member.field ~ (type.isArray ? ".data[i]" : "");

    final switch (type.kind)
    {
    case Type.Kind.primitive:
        return format!"dst.%s = src.%s"(cField, dField);
    case Type.Kind.string_:
        return format!"rosidl_runtime_c__String__assign(&dst.%s, toStringz(src.%s))"(cField, dField);
    case Type.Kind.nested:
        return format!"%s.convert(src.%s, dst.%s)"(dToString(type.asPlain), dField, cField);
    }
}

string createAssignCtoD(in Member member)
{
    const type = member.type;
    const dField = member.field ~ (type.isArray ? "[i]" : "");
    const cField = member.field ~ (type.isArray ? ".data[i]" : "");

    final switch (type.kind)
    {
    case Type.Kind.primitive:
        return format!"dst.%s = src.%s"(dField, cField);
    case Type.Kind.string_:
        return format!"dst.%s = fromStringz(src.%s.data).dup()"(dField, cField);
    case Type.Kind.nested:
        return format!"%s.convert(src.%s, dst.%s)"(dToString(type.asPlain), cField, dField);
    }
}

void insert(T)(Context!T cxt, in Member member)
{
    // for assignment
    if (member.type.isArray)
    {
        cxt.useSection("isArray");
    }
    cxt["type"] = member.type.dToString();
    cxt["cType"] = member.type.cToString();
    cxt["name"] = member.field;
    cxt["assignDtoC"] = createAssignDtoC(member);
    cxt["assignCtoD"] = createAssignCtoD(member);
    if (!member.defaultText.isNull)
    {
        const default_ = member.type.isArray ?
            castArrayLiteral(member.defaultText.get) : castLiteral(member.defaultText.get);
        cxt["default?"] = ["value": default_];
    }
}

void insert(T)(Context!T cxt, in Constant constant)
{
    cxt["type"] = constant.type.dToString();
    cxt["name"] = constant.field;
    cxt["value"] = castLiteral(constant.valueString);
}

void insert(T)(Context!T cxt, in Structure struct_)
{
    cxt["name"] = struct_.shortName;
    cxt["cName"] = Type(struct_.fullname, false).cToString();
    cxt["cArrayName"] = Type(struct_.fullname, true).cToString();
    foreach (m; struct_.members)
    {
        cxt.addSubContext("members").insert!T(m);
    }
    foreach (c; struct_.constants)
    {
        cxt.addSubContext("constants").insert!T(c);
    }
}

void insert(T)(Context!T cxt, in MessageModule mm)
{
    cxt["moduleName"] = mm.fullname.replace("::", ".");
    cxt["cModuleName"] = mm.fullname.replace("::", ".c.");
    foreach (d; mm.uniqueDependModules)
    {
        cxt.addSubContext("depends")["name"] = d.replace("::", ".");
    }
    foreach (m; mm.messages)
    {
        cxt.addSubContext("messages").insert!T(m);
    }
}

string render(T)(MustacheEngine!T mustache, in MessageModule mm)
{
    auto cxt = new Context!T();
    cxt.insert!T(mm);
    return mustache.renderString(tmpl, cxt).trimTrailingWhitespace();
}

@("render MessageModule") unittest
{
    import msg_gen.test_helper;

    const data = TestData.Internal.manifest.message;
    MustacheEngine!string mustache;
    const answer = render(mustache, data);
    assert(answer == TestData.Output.msgD, answer);
}
