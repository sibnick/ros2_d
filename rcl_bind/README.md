# rcl_bind

ROS2 binding for D. 

## Supporting environment

- Foxy on Ubuntu 20.04

## Requirements

- [dpp](https://code.dlang.org/packages/dpp)
  - Will be fetched automatically
- apt packages
  - libclang-10-dev (tested version)
  - clang-10 (tested version)

[Example Dockerfile](https://gist.github.com/nonanonno/f5b4654f651807a3293f59cb91f40a12)

## How to use

TBD

Since other packages (e.g. `rmw`) than `rcl` are required to work with ROS2, this package includes additional ROS2 packages. However all packages are under `rcl` module in D.
