module rcld.node;

import rcl;
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
        enforce(rcl_node_init(&nodeHandle, name.toStringz, namespace.toStringz, &context.context, &options) == 0);
    }

    ~this()
    {
        terminate();
    }

    void terminate()
    {
        if (rcl_node_is_valid(&nodeHandle))
        {
            rcl_node_fini(&nodeHandle);
        }
    }

private:
    rcl_node_t nodeHandle;
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
