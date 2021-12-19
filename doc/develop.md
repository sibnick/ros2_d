# For developer

[ros2_d_devenv](https://github.com/nonanonno/ros2_d_devenv) is a development environment for `ros2_d`.
If you are a vscode user, you can setup the environment easily by using it.

## Prerequisites

- ROS2 (See [Supprting environment](../README.md#supporting-environments))
- apt packages (for rcl_bind)
    - libclang-10-dev (tested version)
    - clang-10 (tested version)

[Example Dockerfile](https://gist.github.com/nonanonno/f5b4654f651807a3293f59cb91f40a12)

## Getting started

Prepare workspace

```shell
git clone https://github.com/nonanonno/ros2_d.git
cd ros2_d
```

Build

```shell
rdmd script/build
```

Test

```shell
rdmd script/test
```

Clean caches

```shell
rdmd script/clean
```

## CI

- [Github Actions Runner](https://github.com/nonanonno/ros2_runner)

