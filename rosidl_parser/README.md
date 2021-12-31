# ROSIDL Parser written in D

This is a sub package of ros2_d and provides ROSIDL file handling role. Here is a list of features.

- Parsing ROSIDL file (.idl)
    - Compliant to [IDL mapping](https://design.ros2.org/articles/idl_interface_definition.html) as possible
    - Works like [official rosidl_parser written in Python](https://github.com/ros2/rosidl/tree/master/rosidl_parser/rosidl_parser)
- Parsing ROSIDL package (with `package.xml`)
    - This is not opened but used inside the next feature
- Watching `AMTNT_PREFIX_PATH` environment variable and Creating whole list of ROSIDL packages with msgs, srvs and actions

