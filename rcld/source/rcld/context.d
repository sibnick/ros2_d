module rcld.context;

import rcl;
import core.runtime;
import std.exception;
import rcld.node;

class Context
{
    this(in CArgs args = Runtime.cArgs)
    {
        auto options = rcl_get_zero_initialized_init_options();
        allocator = rcutils_get_default_allocator();
        enforce(rcl_init_options_init(&options, allocator) == 0);
        scope (exit)
            rcl_init_options_fini(&options);
        context = rcl_context_t();
        enforce(rcl_init(args.argc, args.argv, &options, &context) == 0);
    }

    void shutdown()
    {
        foreach (node; nodes)
        {
            node.terminate();
        }
        if (context != rcl_context_t())
        {
            rcl_shutdown(&context);
            rcl_context_fini(&context);
            context = rcl_context_t();
        }
    }

package:
    rcutils_allocator_t allocator;
    rcl_context_t context;
    Node[] nodes;

}
