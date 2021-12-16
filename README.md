# ros2_d - ROS2 client library written in Dlang

[![workflow](https://github.com/nonanonno/ros2_d/actions/workflows/workflow.yml/badge.svg?branch=main)](https://github.com/nonanonno/ros2_d/actions/workflows/workflow.yml)

This is a ROS2 client library written in Dlang that does **not** depend on ROS2 build infrastructure (`colcon`).

## Sub packages

- [rcl_bind](rcl_bind) : D binding package of rcl
- [msg_gen](msg_gen) : Message generator that reads IDL files
- [rcld](rcld) : ROS2 client library API for D

## Getting started
### Prerequisites

- `libclang-dev` (tested with `libclang-10-dev`)
- `clang` (tested with `clang-10`)

### Build

1. Execute this command at your project root.
    - This will generate D message packages from visible ROS2 message packages.

    ```shell
    dub run ros2_d:msg_gen -- .dub/packages
    ```

2. Add ros2_d to your project

    ```shell
    dub add ros2_d:rcld
    ```

3. Add message packages you want to use
    - Open dub.json and add (e.g.) `"std_msgs": ">=0.0.1"` to `dependencies` section

4. Build

    ```shell
    dub build
    ```

Before you execute that procedure, please be sure that necessary environment varialbles for ROS2. This means, you need to execute the following command before setting up.

```shell
source /opt/ros/$ROS_DISTRO/setup.bash
```

And if you have your own message type, please do the following command too.

```shell
source <your-ament-workspace>/install/setup.bash
```

When some of ROS2 message type definitions are changed, please do the following command again.

```shell
dub run ros2_d:msg_gen -- .dub/packages -r
```

Here is a [example pacakge](example).

## Supporting environments

- OS
    - Linux (tested with Ubuntu 20.04)
- ROS2 distribution
    - Foxy
    - Galactic
    - Rolling
- Dlang
    - dmd (tested with dmd-2.098.0)
- CPU
    - x86_64

## For developer

[Getting started](doc/develop.md)
