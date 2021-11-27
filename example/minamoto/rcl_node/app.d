import std.stdio;
import rcl;

import core.runtime;
import core.thread;
import std.exception;

void main()
{
    auto args = Runtime.cArgs;

    auto init_options = rcl_get_zero_initialized_init_options();
    auto allocator = rcutils_get_default_allocator();

    enforce(rcl_init_options_init(&init_options, allocator) == 0);

    auto context = rcl_context_t();
    enforce(rcl_init(args.argc, args.argv, &init_options, &context) == 0);

    auto node_handle = rcl_get_zero_initialized_node();
    auto node_options = rcl_node_get_default_options();
    enforce(rcl_node_init(&node_handle, "node", "", &context, &node_options) == 0);

    Thread.sleep(10.seconds);

    rcl_node_fini(&node_handle);
    rcl_shutdown(&context);
}
