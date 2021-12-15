module rcld.executor;

import rcl;
import rcld.node;
import rcld.subscription;
import rcld.context;
import std.exception;
import std.algorithm;
import core.time;

class Executor
{
    this(Context context)
    {
        waitSetHandle = rcl_get_zero_initialized_wait_set();
        enforce(rcl_wait_set_init(&waitSetHandle, 0, 0, 0, 0, 0, 0,
                &context.context, rcutils_get_default_allocator()) == 0);
    }

    ~this()
    {
        terminate();
    }

    void terminate()
    {
        if (waitSetHandle.impl)
        {
            rcl_wait_set_fini(&waitSetHandle);
        }
    }

    void addNode(Node node)
    {
        assert(node);
        enforce(node !in nodes);
        nodes[node] = true;
    }

    void removeNode(Node node)
    {
        assert(node);
        enforce(node in nodes);
        nodes.remove(node);
    }

    bool spinOnce(Duration timeout = -1.hnsecs)
    {
        enforce(rcl_wait_set_clear(&waitSetHandle) == 0);
        const subNum = reduce!((a, b) => a + cast(int) b.subscriptions.length)(0, nodes.keys);
        enforce(rcl_wait_set_resize(&waitSetHandle, subNum, 0, 0, 0, 0, 0) == 0);

        BaseSubscription[] subscriptions;

        foreach (node; nodes.keys)
        {
            foreach (sub; node.subscriptions)
            {
                subscriptions ~= sub;
                enforce(rcl_wait_set_add_subscription(&waitSetHandle, sub.handle, null) == 0);
            }
        }

        const ret = rcl_wait(&waitSetHandle, timeout.total!"nsecs");
        if (ret != 0)
        {
            return false;
        }

        foreach (i; 0 .. subNum)
        {
            if (waitSetHandle.subscriptions[i])
            {
                subscriptions[i].takeAndCall();
            }
        }
        return true;
    }

package:
    rcl_wait_set_t waitSetHandle;
    bool[Node] nodes; // bool is meaningless
}
