module rosidl_parser.definition.identifier;

/// A list of basic types
immutable basicTypes = [
    "short",
    "long",
    "long long",
    "unsigned short",
    "unsigned long",
    "unsigned long long",
    "float",
    "double",
    "long double",
    "char",
    "wchar",
    "boolean",
    "octet",
    "int8",
    "int16",
    "int32",
    "int64",
    "uint8",
    "uint16",
    "uint32",
    "uint64",
];

/// Suffix for module name holding constant variables
enum constantModuleSuffix = "_Constants";
/// Suffix for service request structure
enum serviceRequestMessageSuffix = "_Request";
/// Suffix for service response structure
enum serviceResponseMessageSuffix = "_Response";
/// Suffix for action goal structure
enum actionGoalSuffix = "_Goal";
/// Suffix for action result structure
enum actionResultSuffix = "_Result";
/// Suffix for action feedback structure
enum actionFeedbackSuffix = "_Feedback";
/// Suffix for service to send an action goal
enum actionGoalServiceSuffix = "_SendGoal";
/// Suffix for service to get a action result
enum actionResultServiceSuffix = "_GetResult";
/// Suffix for message for getting feedback
enum actionFeedbackMessageSuffix = "_FeedbackMessage";
