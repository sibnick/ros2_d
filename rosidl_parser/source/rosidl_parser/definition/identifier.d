module rosidl_parser.definition.identifier;

// Basic types
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

// Suffixes
enum constantModuleSuffix = "_Constants";
enum serviceRequestMessageSuffix = "_Request";
enum serviceResponseMessageSuffix = "_Response";
enum actionGoalSuffix = "_Goal";
enum actionResultSuffix = "_Result";
enum actionFeedbackSuffix = "_Feedback";
enum actionGoalServiceSuffix = "_SendGoal";
enum actionResultServiceSuffix = "_GetResult";
enum actionFeedbackMessageSuffix = "_FeedbackMessage";
