module test_diagnostic_msgs;

import diagnostic_msgs.msg;
import test_helper;

@("DiagnosticStatus") unittest
{
    // To check complex message with constant variables.
    const a = DiagnosticStatus(
        DiagnosticStatus.WARN,
        "name",
        "message",
        "hardware_id",
        [
            KeyValue("key1", "value1"),
            KeyValue("key2", "value2"),
        ]
    );
    mixin ConvertCheck!(a);
    check();

}
