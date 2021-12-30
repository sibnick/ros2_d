module rosidl_parser.definition.rosidl;

import rosidl_parser.definition.structure;
import rosidl_parser.definition.type;
import rosidl_parser.definition.identifier;

import std.range;
import std.algorithm.comparison;
import std.algorithm;

NamespacedType construct(Args...)(Message[] messages, Args args)
{
    string prefix = null;
    string[] namespaces = [];

    foreach (m; messages)
    {
        static foreach (i; 0 .. args.length / 2)
        {
            {
                static assert(is(Args[i * 2] == string));
                static assert(is(Args[i * 2 + 1] == Message*));

                alias key = args[i * 2];
                alias target = args[i * 2 + 1];

                if (m.structure.namespacedType.name.endsWith(key))
                {
                    *target = m;
                    const currentPrefix = m.structure.namespacedType.name[0 .. $ - key.length];
                    const currentNamespces = m.structure.namespacedType.namespaces;
                    if (prefix)
                    {
                        assert(prefix == currentPrefix);
                        assert(namespaces == currentNamespces);
                    }
                    else
                    {
                        prefix = currentPrefix;
                        namespaces = currentNamespces.dup;
                    }
                }
            }
        }
    }

    static foreach (i; 0 .. args.length / 2)
    {
        assert(*args[i * 2 + 1]);
    }
    assert(prefix);
    assert(namespaces);

    return new NamespacedType(namespaces, prefix);
}

@("construct function")
unittest
{
    immutable namespaces = ["pkgname", "msg"];
    Message a, b;
    Message[] messages = [
        new Message(Structure(new NamespacedType(namespaces, "MyMessage_a")), []),
        new Message(Structure(new NamespacedType(namespaces, "MyMessage_b")), []),
    ];
    const t = construct(messages, "_a", &a, "_b", &b);
    assert(messages[0] == a);
    assert(messages[1] == b);
    assert(t == new NamespacedType(namespaces, "MyMessage"));
}

class Message
{
    Structure structure;
    Constant[] constants;

    this(Structure structure = Structure(), Constant[] constants = [])
    {
        this.structure = structure;
        this.constants = constants;
    }

}

class Service
{
    NamespacedType type;
    Message request;
    Message response;

    this(Message[] messages)
    {
        type = construct(messages,
            serviceRequestMessageSuffix, &request,
            serviceResponseMessageSuffix, &response,
        );
    }

    @("construct")
    unittest
    {
        immutable namespaces = ["pkgname", "msg"];
        immutable name = "MyMessage";
        Message[] messages = [
            new Message(Structure(new NamespacedType(namespaces, name ~ serviceResponseMessageSuffix)), [
                ]),
            new Message(Structure(new NamespacedType(namespaces, name ~ serviceRequestMessageSuffix)), [
                ]),

        ];

        auto srv = new Service(messages);

        assert(srv.type == new NamespacedType(namespaces, name));
        assert(srv.request == messages[1]);
        assert(srv.response == messages[0]);
    }
}

class Action
{
    NamespacedType type;
    Message goal;
    Message result;
    Message feedback;
    Service sendGoalService;
    Service getResultService;
    Message feedbackMessage;

    static immutable implicitIncludes = [
        Include(`"builtin_interfaces/msg/Time.idl"`),
        Include(`"unique_identifier_msgs/msg/UUID.idl"`),
    ];

    this(Message[] messages)
    {
        type = construct(messages,
            actionGoalSuffix, &goal,
            actionResultSuffix, &result,
            actionFeedbackSuffix, &feedback,
        );

        auto goalIdType = new NamespacedType(["unique_identifier_msgs", "msg"], "UUID");

        sendGoalService = new Service(
            [
            createMessage(
                type.name ~ actionGoalServiceSuffix ~ serviceRequestMessageSuffix, [
                    Member(goalIdType, "goal_id"),
                    Member(goal.structure.namespacedType, "goal"),
                ]
            ),
            createMessage(
                type.name ~ actionGoalServiceSuffix ~ serviceResponseMessageSuffix, [
                    Member(new BasicType("boolean"), "accepted"),
                    Member(new NamespacedType(["builtin_interfaces", "msg"], "Time"), "stamp"),
                ]
            ),
        ]);

        getResultService = new Service(
            [
            createMessage(
                type.name ~ actionResultServiceSuffix ~ serviceRequestMessageSuffix, [
                    Member(goalIdType, "goal_id"),
                ],
            ),
            createMessage(
                type.name ~ actionResultServiceSuffix ~ serviceResponseMessageSuffix, [
                    Member(new BasicType("int8"), "status"),
                    Member(result.structure.namespacedType, "result"),
                ]
            ),
        ]);

        feedbackMessage = createMessage(type.name ~ actionFeedbackMessageSuffix, [
                Member(goalIdType, "goal_id"),
                Member(feedback.structure.namespacedType, "feedback"),
            ]);

    }

    private auto createMessage(string name, Member[] members) const
    {
        return new Message(
            Structure(new NamespacedType(type.namespaces, name), members), []);
    }

    @("construct")
    unittest
    {
        immutable namespaces = ["pkgname", "msg"];
        immutable name = "MyMessage";
        Message[] messages = [
            new Message(Structure(new NamespacedType(namespaces, name ~ actionGoalSuffix)), [
                ]),
            new Message(Structure(new NamespacedType(namespaces, name ~ actionResultSuffix)), [
                ]),
            new Message(Structure(new NamespacedType(namespaces, name ~ actionFeedbackSuffix)), [
                ]),
        ];
        auto action = new Action(messages);
        assert(action.type == new NamespacedType(namespaces, name));
        assert(action.goal == messages[0]);
        assert(action.result == messages[1]);
        assert(action.feedback == messages[2]);
        assert(action.sendGoalService);
        assert(action.getResultService);
        assert(action.feedbackMessage);
    }
}

struct IdlFile(T) if (is(T == Message) || is(T == Service) || is(T == Action))
{
    Include[] includes;
    AbstractType[AbstractType] typedefMap;
    T data;
}
