module test_helper.test_msgs;
import pegged.grammar;
import std.typecons;
import std.array;
import std.algorithm;
import std.string;
import std.format;

static struct TestMsgs
{
    enum name = "test_msgs";
    enum packageXML = import("package.xml");

    struct Msg
    {
        enum Arrays = import("msg/Arrays.idl");
        enum BasicTypes = import("msg/BasicTypes.idl");
        version (rolling) enum BoundedPlainSequences = import("msg/BoundedPlainSequences.idl");
        enum BoundedSequences = import("msg/BoundedSequences.idl");
        enum Constants = import("msg/Constants.idl");
        enum Defaults = import("msg/Defaults.idl");
        enum Empty = import("msg/Empty.idl");
        enum MultiNested = import("msg/MultiNested.idl");
        enum Nested = import("msg/Nested.idl");
        enum Strings = import("msg/Strings.idl");
        enum WStrings = import("msg/WStrings.idl");
    }

    struct Srv
    {
        enum Arrays = import("srv/Arrays.idl");
        enum BasicTypes = import("srv/BasicTypes.idl");
        enum Empty = import("srv/Empty.idl");
    }

    struct Action
    {
        enum Fibonacci = import("action/Fibonacci.idl");
    }
}

static struct TestMsgsData
{
    enum name = "test_msgs";
    enum version_ = "0.1.1";

    struct Msg
    {
        mixin(makeMember("Arrays"));
        mixin(makeMember("BasicTypes"));
        version (roling) mixin(makeMember("BoundedPlainSequences"));
        mixin(makeMember("BoundedSequences"));
        mixin(makeMember("Constants"));
        mixin(makeMember("Defaults"));
        mixin(makeMember("Empty"));
        mixin(makeMember("MultiNested"));
        mixin(makeMember("Nested"));
        mixin(makeMember("Strings"));
        mixin(makeMember("WStrings"));
    }

    struct Srv
    {
        mixin(makeService("Arrays"));
        mixin(makeService("BasicTypes"));
        mixin(makeService("Empty"));
    }

    struct Action
    {
        mixin(makeAction("Fibonacci"));
    }
}

private string makeMember(string type)
{
    return format!`static auto %1$s() { return parseMessage("%1$s", import("msg/%1$s.msg")); }`(
        type);
}

private string makeService(string type)
{
    return format!`static auto %1$s() { return parseService("%1$s", import("srv/%1$s.srv")); }`(
        type);
}

private string makeAction(string type)
{
    return format!`static auto %1$s() { return parseAction("%1$s", import("action/%1$s.action")); }`(
        type);
}

struct Type
{
    string name;

    enum Kind
    {
        plain,
        bounded,
        unbounded,
        array,
    }

    Kind kind;
    string size;

    this(string name, Kind kind, string size = "")
    {
        this.name = typeMap.get(name, name);
        this.kind = kind;
        this.size = size;
    }
}

struct Member
{
    Type type;
    string name;
    Nullable!string default_;
    this(Type type, string name, Nullable!string default_ = Nullable!string.init)
    {
        this.type = type;
        this.name = name;
        this.default_ = default_;
    }
}

enum empty = Member(Type("uint8", Type.Kind.plain), "structure_needs_at_least_one_member");

struct Constant
{
    Type type;
    string name;
    string value;
}

struct Structure
{
    string name;
    Member[] members;
}

struct Message
{
    Structure structure;
    Constant[] constants;

}

struct Service
{
    string name;
    Message request;
    Message response;
}

struct Action
{
    string name;
    Message goal;
    Message result;
    Message feedback;
    Service sendGoalService;
    Service getResultService;
    Message feedbackMessage;
}

private void appendLine(ref Message msg, string line)
{
    auto parsed = MemberLine(line);
    assert(parsed.successful);
    auto elem = parsed.children[0].children[0];
    switch (elem.name.split('.')[$ - 1])
    {
    case "constant":
        auto t = parseType(elem.children[0]);
        auto n = elem.children[1].matches.join;
        auto v = elem.children[2].matches.join;
        msg.constants ~= Constant(t, n, v);
        break;
    case "member":
        auto t = parseType(elem.children[0]);
        auto n = elem.children[1].matches.join;
        auto v = elem.children.length > 2 ? elem.children[2].matches.join.nullable
            : Nullable!string.init;
        msg.structure.members ~= Member(t, n, v);
        break;
    default:
        assert(false);
    }
}

private Message parseMessage(string name, string text)
{
    Message msg;
    msg.structure.name = name;
    text.split("\n").map!(line => line.strip)
        .filter!(line => line.length > 0)
        .filter!(line => line[0] != '#')
        .each!(line => appendLine(msg, line));

    if (msg.structure.members.length == 0)
    {
        msg.structure.members ~= empty;
    }
    return msg;
}

@("parseMessage") unittest
{
    const data = `
# comment
int32 INT32_CONST=123
bool bool_value
float32 float32_value 1.125
int32[12] array
int32[<=12] bounded
int32[] unbounded
string<=12 bounded_string
wstring<=12 bounded_wstring
`;
    auto ans = parseMessage("Test", data);

    assert(ans.constants.length == 1);
    assert(ans.constants[0] == Constant(Type("int32", Type.Kind.plain, ""), "INT32_CONST", "123"));

    auto reference = [
        Member(Type("boolean", Type.Kind.plain), "bool_value"),
        Member(Type("float", Type.Kind.plain), "float32_value", "1.125".nullable),
        Member(Type("int32", Type.Kind.array, "12"), "array"),
        Member(Type("int32", Type.Kind.bounded, "12"), "bounded"),
        Member(Type("int32", Type.Kind.unbounded, ""), "unbounded"),
        Member(Type("string", Type.Kind.bounded, "12"), "bounded_string"),
        Member(Type("wstring", Type.Kind.bounded, "12"), "bounded_wstring"),
    ];

    assert(ans.structure.name == "Test");
    assert(ans.structure.members.length == reference.length);
    foreach (i; 0 .. reference.length)
    {
        auto a = ans.structure.members[i];
        auto b = reference[i];
        assert(a == b);
    }
}

private Service parseService(string name, string text)
{
    Service srv;
    srv.name = name;
    srv.request.structure.name = name ~ "_Request";
    srv.response.structure.name = name ~ "_Response";
    auto lines = text.split("\n").map!(line => line.strip)
        .filter!(line => line.length > 0)
        .filter!(line => line[0] != '#')
        .array;
    auto sections = lines.split("---");

    if (sections.length == 2)
    {
        sections[0].each!(line => appendLine(srv.request, line));
        sections[1].each!(line => appendLine(srv.response, line));
    }

    if (srv.request.structure.members.length == 0)
    {
        srv.request.structure.members ~= empty;
    }
    if (srv.response.structure.members.length == 0)
    {
        srv.response.structure.members ~= empty;
    }

    return srv;
}

@("parseService") unittest
{
    const data = `
# comment
int32 request
---
int32 response
`;

    auto ans = parseService("Test", data);
    assert(ans.name == "Test");
    assert(ans.request.structure.name == "Test_Request");
    assert(ans.request.structure.members.length == 1);
    assert(ans.request.structure.members[0] == Member(Type("int32", Type.Kind.plain), "request"));
    assert(ans.response.structure.name == "Test_Response");
    assert(ans.response.structure.members.length == 1);
    assert(ans.response.structure.members[0] == Member(Type("int32", Type.Kind.plain), "response"));

}

private Action parseAction(string name, string text)
{
    Action action;
    action.name = name;
    Message goal;
    Message result;
    Message feedback;
    Service sendGoalService;
    Service getResultService;
    Message feedbackMessage;

    goal.structure.name = name ~ "_Goal";
    result.structure.name = name ~ "_Result";
    feedback.structure.name = name ~ "_Feedback";

    auto lines = text.split("\n").map!(line => line.strip)
        .filter!(line => line.length > 0)
        .filter!(line => line[0] != '#')
        .array;
    auto sections = lines.split("---");
    if (sections.length == 3)
    {
        sections[0].each!(line => appendLine(goal, line));
        sections[1].each!(line => appendLine(result, line));
        sections[2].each!(line => appendLine(feedback, line));
    }
    if (goal.structure.members.length == 0)
    {
        goal.structure.members ~= empty;
    }
    if (result.structure.members.length == 0)
    {
        result.structure.members ~= empty;
    }
    if (feedback.structure.members.length == 0)
    {
        feedback.structure.members ~= empty;
    }

    sendGoalService.name = name ~ "_SendGoal";
    sendGoalService.request = Message(Structure(name ~ "_SendGoal_Request", [
                Member(Type("unique_identifier_msgs.msg.UUID", Type.Kind.plain), "goal_id"),
                Member(Type(goal.structure.name, Type.Kind.plain), "goal"),
            ]));
    sendGoalService.response = Message(Structure(name ~ "_SendGoal_Response", [
                Member(Type("boolean", Type.Kind.plain), "accepted"),
                Member(Type("builtint_interfaces.msg.Time", Type.Kind.plain), "stamp"),
            ]));
    getResultService.name = name ~ "_GetResult";
    getResultService.request = Message(Structure(name ~ "_GetResult_Request", [
                Member(Type("unique_identifier_msgs.msg.UUID", Type.Kind.plain), "goal_id"),
            ]));
    getResultService.response = Message(Structure(name ~ "_GetResult_Response", [
                Member(Type("int8", Type.Kind.plain), "status"),
                Member(Type(result.structure.name, Type.Kind.plain), "result"),
            ]));
    feedbackMessage = Message(Structure(name ~ "_FeedbackMessage", [
                Member(Type("unique_identifier_msgs.msg.UUID", Type.Kind.plain), "goal_id"),
                Member(Type(feedbackMessage.structure.name, Type.Kind.plain), "feedback"),
            ]));
    action.goal = goal;
    action.result = result;
    action.feedback = feedback;
    action.sendGoalService = sendGoalService;
    action.getResultService = getResultService;
    action.feedbackMessage = feedbackMessage;

    return action;
}

@("parseAction") unittest
{
    const data = `
# comment
int32 goal
---
int32 result
---
int32 feedback
`;
    auto ans = parseAction("Test", data);
    assert(ans.name == "Test");

    assert(ans.goal.structure.name == "Test_Goal");
    assert(ans.goal.structure.members.length == 1);
    assert(ans.result.structure.name == "Test_Result");
    assert(ans.result.structure.members.length == 1);
    assert(ans.feedback.structure.name == "Test_Feedback");
    assert(ans.feedback.structure.members.length == 1);
    assert(ans.sendGoalService.name == "Test_SendGoal");
    assert(ans.getResultService.name == "Test_GetResult");
    assert(ans.feedbackMessage.structure.name == "Test_FeedbackMessage");

}

private Type parseType(in ParseTree type)
{
    auto p = type.children[0];
    switch (p.name.split('.')[$ - 1])
    {
    case "arrayType":
        return Type(p.matches[0 .. $ - 3].join(), Type.Kind.array, p.matches[$ - 2]);
    case "boundedSequenceType":
        return Type(p.matches[0 .. $ - 4].join(), Type.Kind.bounded, p.matches[$ - 2]);
    case "unboundedSequenceType":
        return Type(p.matches[0 .. $ - 2].join(), Type.Kind.unbounded, "");
    case "boundedString":
        return Type(p.matches[0], Type.Kind.bounded, p.matches[$ - 1]);
    case "boundedWString":
        return Type(p.matches[0], Type.Kind.bounded, p.matches[$ - 1]);
    case "scopedName":
        return Type(p.matches.join, Type.Kind.plain, "");
    default:
        assert(false);
    }
}

private enum typeMap = [ // @suppress(dscanner.performance.enum_array_literal)
        "bool": "boolean",
        "byte": "octet",
        "char": "uint8",
        "float32": "float",
        "float64": "double",
        "int8": "int8",
        "uint8": "uint8",
        "int16": "int16",
        "uint16": "uint16",
        "int32": "int32",
        "uint32": "uint32",
        "int64": "int64",
        "uint64": "uint64",
        "string": "string",
        "wstring": "wstring",
    ];

mixin(grammar(`
MemberLine:
    line <- constant / member
    constant < type field '=' value
    member < type field !'=' value?
    scopedName < identifier | '.' identifier | scopedName '.' identifier
    field <- identifier
    value <~ .+
    type <-
        / arrayType
        / boundedSequenceType
        / unboundedSequenceType
        / boundedString
        / boundedWString
        / scopedName
    arrayType < scopedName '[' digits ']'
    boundedSequenceType < scopedName '[' '<=' digits ']'
    unboundedSequenceType < scopedName '[' ']'
    boundedString < 'string' '<=' digits
    boundedWString < 'wstring' '<=' digits
`));
@("MemberLine") unittest
{
    import std.stdio;
    import std.array;
    import std.conv;

    void test(T, U)(T a, U b)
    {
        assert(a == b, a.to!string);
    }

    test(MemberLine.type(`bool`).matches.join(), "bool");
    test(
        MemberLine.type(`BasicTypes`).matches.join(), "BasicTypes");
    test(
        MemberLine.type(`test_msgs.msg.BasicTypes`).matches.join(), "test_msgs.msg.BasicTypes");

    test(MemberLine.type(`bool[]`).matches.join(), "bool[]");
    test(
        MemberLine.type(`BasicTypes[]`).matches.join(), "BasicTypes[]");
    test(
        MemberLine.type(`test_msgs.msg.BasicTypes[]`).matches.join(), "test_msgs.msg.BasicTypes[]");

    test(MemberLine.type(`bool[3]`).matches.join(), "bool[3]");
    test(
        MemberLine.type(`BasicTypes[3]`).matches.join(), "BasicTypes[3]");
    test(MemberLine.type(`test_msgs.msg.BasicTypes[3]`).matches.join(), "test_msgs.msg.BasicTypes[3]");

    test(MemberLine.type(`bool[<=3]`).matches.join(), "bool[<=3]");
    test(
        MemberLine.type(`BasicTypes[<=3]`).matches.join(), "BasicTypes[<=3]");
    test(MemberLine.type(`test_msgs.msg.BasicTypes[<=3]`)
            .matches.join(), "test_msgs.msg.BasicTypes[<=3]");
    test(
        MemberLine.type(`string`).matches.join(), "string");
    test(
        MemberLine.type(`string<=3`).matches.join(), "string<=3");
    test(
        MemberLine.type(`wstring`).matches.join(), "wstring");
    test(
        MemberLine.type(`wstring<=3`).matches.join(), "wstring<=3");
    test(
        MemberLine.constant(`bool BOOL_CONST=true`).matches, [
            "bool", "BOOL_CONST", "=", "true"
        ]);
    test(MemberLine.constant(`float32 FLOAT32_CONST=1.125`)
            .matches, [
                "float32", "FLOAT32_CONST", "=", "1.125"
            ]);
    test(MemberLine.member(`bool bool_value`).matches, [
            "bool", "bool_value"
        ]);
    test(MemberLine.member(`float32 float32_value 1.125`)
            .matches, [
                "float32", "float32_value", "1.125"
            ]);
    test(MemberLine(`bool BOOL_CONST=true`)
            .children[0].children[0].name, "MemberLine.constant");
    test(MemberLine(`bool bool_value`)
            .children[0].children[0].name, "MemberLine.member");
    test(MemberLine(`float32 float32_value 1.125`)
            .children[0].children[0].name, "MemberLine.member");
}
