module rosidl_parser.definition.rosidl;

import rosidl_parser.definition.structure;
import rosidl_parser.definition.type;
import rosidl_parser.definition.identifier;

import std.range;
import std.algorithm.comparison;
import std.algorithm;

/**
 * Represent ROSIDL message (.msg).
 *
 * A message has one structure and more than zero constants. In IDL file, constants are in
 * `foo::bar::baz_Constants` module. In this case, the constants are associated to `foo::bar::baz`
 * structure. If an IDL file is message, the structure is in `msg` module.
 */
class Message
{
    /// A structure of the message
    Structure structure;
    /// A list of constants
    Constant[] constants;

    ///
    this(Structure structure = Structure(), Constant[] constants = [])
    {
        this.structure = structure;
        this.constants = constants;
    }

}

/**
 * Represent ROSIDL service (.srv).
 *
 * A Service has two message: request and response. When a service name is `foo::bar::baz`, the
 * request and response structure name is `foo::bar::baz_Request` and `foor::bar::baz_Response`
 * respectively in IDL file. Note that there is no Service representation directly in IDL file,
 * but is a combination of request and response message in `srv` module.
 */
class Service
{
    /// Namespaced typename (e.g. `foo::bar::baz`).
    NamespacedType type;
    /// Request message (e.g. `foo::bar::baz_Request`).
    Message request;
    /// Response message (e.g. `foo::bar::baz_Response`).
    Message response;

    /**
     * Construct a Service object.
     *
     * Params:
     *   messages = A combination of request and response messages
     */
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

/**
 * Represent ROSIDL action (.action).
 *
 * An Action has tree structures, goal, result and feedback as public APIs,and whose suffixes are
 * `_Goal`, `_Result` and `_Feedback` respectively. As same as Service, there is no Action
 * representation directly in IDL file, but is a combination of these tree structure in `action`
 * module.
 * In addition, two service (sendGoalService and getResultService) and one message (feedbackMessage)
 * are required to work as Action. They will be automatically constructed from first tree structures.
 */
class Action
{
    /// Namespaced typename (e.g. `foo::bar::baz`)
    NamespacedType type;
    /// Goal message (e.g. `foo::bar::baz_Goal`)
    Message goal;
    /// Result message (e.g. `foo::bar::baz_Result`)
    Message result;
    /// Feeback message (e.g. `foo::bar::baz_Feedback`)
    Message feedback;
    /// Service for sending goal (e.g. `foo::bar::baz_SendGoal`)
    Service sendGoalService;
    /// Service for getting result (e.g. `foo::bar::baz_GetResult`)
    Service getResultService;
    /// Message for getting feedback (e.g. `foo::bar::baz_FeedbackMessage`)
    Message feedbackMessage;

    /// Implicit depending IDL files.
    static immutable implicitIncludes = [
        Include(`"builtin_interfaces/msg/Time.idl"`),
        Include(`"unique_identifier_msgs/msg/UUID.idl"`),
    ];

    /**
     * COnstruct an Action object
     * Params:
     *   messages = A combination of goal, result and feedback messages
     */
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

/**
 * Represent IDL file
 *
 * An IDL file is constructed with
 * - `includes`: A list of depending IDL files
 * - `typedefMap`: A typedef map
 * - Message|Service|Action: Content
 *
 * If the content is Action, implicitIncludes are added to `includes`.
 */
struct IdlFile(T) if (is(T == Message) || is(T == Service) || is(T == Action))
{
    /// A list of depending IDL files
    Include[] includes;
    /// A typedef map
    AbstractType[AbstractType] typedefMap;
    /// Content
    T data;
}

private NamespacedType construct(Args...)(Message[] messages, Args args)
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
