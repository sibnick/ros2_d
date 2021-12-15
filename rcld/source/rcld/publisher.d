module rcld.publisher;

import rcld.node;
import rcl;
import std.string;
import std.exception;

interface BasePublisher
{
    void terminate(Node node);
}

class Publisher(Message) : BasePublisher
{
    this(Node node, in string name)
    {
        pubHandle = rcl_get_zero_initialized_publisher();
        auto options = rcl_publisher_get_default_options();
        auto typesupport = Message.getTypesupport();
        enforce(rcl_publisher_init(&pubHandle, &node.nodeHandle, typesupport, name.toStringz, &options) == 0);
        node.publishers ~= this;
    }

    override void terminate(Node node)
    {
        if (pubHandle.impl)
        {
            enforce(rcl_publisher_fini(&pubHandle, &node.nodeHandle) == 0);
            // workaround: The function rcl_publisher_fini does not assign null pointer to `impl`.
            pubHandle.impl = null;
        }
    }

    void publish(in Message msg)
    {
        auto cMsg = Message.createC();
        assert(cMsg);
        Message.convert(msg, *cMsg);
        enforce(rcl_publish(&pubHandle, cast(const(void)*) cMsg, null) == 0);
        Message.destroyC(cMsg);
    }

package:
    rcl_publisher_t pubHandle;
}
