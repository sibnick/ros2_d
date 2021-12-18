/**
 * This is a node creation example with RCL C API binding.
 + While executing this application, you can find "rcl_example" node.
 */
import rcl;

import core.runtime;
import core.thread;
import std.exception;

void main()
{
    const args = Runtime.cArgs;
    auto initOptions = rcl_get_zero_initialized_init_options();
    auto allocator = rcutils_get_default_allocator();

    enforce(rcl_init_options_init(&initOptions, allocator) == 0);
    scope (exit)
        rcl_init_options_fini(&initOptions);

    auto context = rcl_context_t();
    enforce(rcl_init(args.argc, args.argv, &initOptions, &context) == 0);
    scope (exit)
        rcl_shutdown(&context);

    auto node = rcl_get_zero_initialized_node();
    auto nodeOptions = rcl_node_get_default_options();
    enforce(rcl_node_init(&node, "rcl_example", "", &context, &nodeOptions) == 0);
    scope (exit)
        rcl_node_fini(&node);

    Thread.sleep(10.seconds);
}
