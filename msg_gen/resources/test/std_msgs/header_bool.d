// dfmt off
module std_msgs.msg;

import builtin_interfaces.msg;

struct Header
{
    builtin_interfaces.msg.Time stamp;
    string frame_id;
}

struct Bool
{
    bool data;
}
