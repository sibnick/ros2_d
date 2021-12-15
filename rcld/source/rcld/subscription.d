module rcld.subscription;

import rcld.node;
import rcl;
import std.string;
import std.exception;

interface BaseSubscription
{
    void terminate(Node node);
}

class Subscription(Message) : BaseSubscription
{
    this(Node node, in string name)
    {
        subHandle = rcl_get_zero_initialized_subscription();
        auto options = rcl_subscription_get_default_options();
        auto typesupport = Message.getTypesupport();
        enforce(rcl_subscription_init(&subHandle, &node.nodeHandle, typesupport, name.toStringz, &options) == 0);
        node.subscriptions ~= this;
    }

    override void terminate(Node node)
    {
        if (subHandle.impl)
        {
            enforce(rcl_subscription_fini(&subHandle, &node.nodeHandle) == 0);
            subHandle.impl = null;
        }
    }

    bool take(out Message msg)
    {
        auto cMsg = Message.createC();
        assert(cMsg);
        scope (exit)
            Message.destroyC(cMsg);
        auto messageInfo = rmw_message_info_t();
        messageInfo.from_intra_process = false;
        const ret = rcl_take(&subHandle, cast(void*) cMsg, &messageInfo, null);
        if (ret == 0)
        {
            Message.convert(*cMsg, msg);
        }
        return ret == 0;
    }

package:
    rcl_subscription_t subHandle;
}
