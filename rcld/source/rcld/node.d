module rcld.node;

import rcl;
import rcld.publisher;
import rcld.subscription;
import rcld.service;
import rcld.client;
import std.string;
import std.exception;
import rcld.context;

class Node
{
    this(in string name, in string namespace, Context context)
    {
        nodeHandle = rcl_get_zero_initialized_node();
        auto options = rcl_node_get_default_options();
        scope (exit)
            rcl_node_options_fini(&options);
        enforce(rcl_node_init(&nodeHandle, cast(const(ubyte)*)name.toStringz, cast(const(ubyte)*)namespace.toStringz, &context.context, &options) == 0);
        context.nodes ~= this;
    }

    ~this()
    {
        terminate();
    }

    void terminate()
    {
        foreach (pub; publishers)
        {
            pub.terminate(this);
        }
        publishers.length = 0;
        foreach (sub; subscriptions)
        {
            sub.terminate(this);
        }
        subscriptions.length = 0;
        foreach (client; clients)
        {
            client.terminate(this);
        }
        clients.length = 0;
        foreach (service; services)
        {
            service.terminate(this);
        }
        services.length = 0;
        if (rcl_node_is_valid(&nodeHandle))
        {
            rcl_node_fini(&nodeHandle);
        }
    }

package:
    rcl_node_t nodeHandle;
    BasePublisher[] publishers;
    BaseSubscription[] subscriptions;
    BaseService[] services;
    BaseClient[] clients;
}

private enum testNamespace = "node_test_ns";

@("create a node") unittest
{
    import std.process : executeShell;
    import std.algorithm : canFind;

    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();
    auto node = new Node("test", testNamespace, cxt);

    auto nodes = executeShell("ros2 node list");
    scope (exit)
        node.terminate();

    assert(nodes.output.split('\n').canFind("/" ~ testNamespace ~ "/test"));
}
