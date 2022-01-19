module rcld.executor;

import rcl;
import rcld.node;
import rcld.subscription;
import rcld.client;
import rcld.service;
import rcld.context;
import std.exception;
import std.algorithm;
import core.time;
import std.algorithm.comparison;

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

    bool spinSome(Duration timeout = -1.hnsecs)
    {
        enforce(rcl_wait_set_clear(&waitSetHandle) == 0);
        const subNum = reduce!((a, b) => a + cast(int) b.subscriptions.length)(0, nodes.keys);
        const guardNum = 0;
        const timerNum = 0;
        const clientNum = reduce!((a, b) => a + cast(int) b.clients.length)(0, nodes.keys);
        const servieNum = reduce!((a, b) => a + cast(int) b.services.length)(0, nodes.keys);
        const eventNum = 0;

        enforce(rcl_wait_set_resize(&waitSetHandle, subNum, guardNum, timerNum, clientNum, servieNum, eventNum) == 0);

        AnyExecutable[] executables;

        foreach (node; nodes.keys)
        {
            foreach (sub; node.subscriptions)
            {
                auto executable = AnyExecutable(cast(Object) sub);
                enforce(rcl_wait_set_add_subscription(&waitSetHandle, sub.handle, &executable.index) == 0);
                executables ~= executable;
            }
            foreach (client; node.clients)
            {
                auto executable = AnyExecutable(cast(Object) client);
                enforce(rcl_wait_set_add_client(&waitSetHandle, client.handle, &executable.index) == 0);
                executables ~= executable;
            }
            foreach (service; node.services)
            {
                auto executable = AnyExecutable(cast(Object) service);
                enforce(rcl_wait_set_add_service(&waitSetHandle, service.handle, &executable.index) == 0);
                executables ~= executable;
            }
        }

        const ret = rcl_wait(&waitSetHandle, timeout.total!"nsecs");

        if (ret != 0)
        {
            return false;
        }

        foreach (executable; executables)
        {
            executable.handle.castSwitch!(
                (BaseSubscription sub) {
                if (waitSetHandle.subscriptions[executable.index])
                {
                    sub.takeAndCall();
                }
            },
                (BaseClient client) {
                if (waitSetHandle.clients[executable.index])
                {
                    client.takeAndCall();
                }
            },
                (BaseService service) {
                if (waitSetHandle.services[executable.index])
                {
                    service.takeAndCall();
                }
            },
                () { assert(false); }
            );
        }

        return true;
    }

package:
    rcl_wait_set_t waitSetHandle;
    bool[Node] nodes; // bool is meaningless
}

struct AnyExecutable
{
    Object handle;
    ulong index = 0;
}
