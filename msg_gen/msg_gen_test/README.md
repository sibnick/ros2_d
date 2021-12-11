# msg_gen_test

Testing package to check that the generated messages are usable by executing:

1. Generating message types of ROS2 common_interfaces
2. Building with the part of the messages
3. Executing conversion: D struct (a) -> C struct (b) -> D struct (c)
4. Testing `assert(a == c)` to check the convesion works

This procedure can be run by just executing the following command.

```shell
rdmd test
```

When something went wrong, that returns non-zero value.
