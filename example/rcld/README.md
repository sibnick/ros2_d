# rcld_example

An example package working with `rcld`. The following two executables are included.

- [talker](fugen/talker/app.d)
- [listener](fugen/listener/app.d)

These nodes are built by the following two steps. Note that you need to run first step at only first time.

```shell
# 1. Setting up to generate messages
rdmd setup
# 2. Build all configurations
rdmd build
```

And then, launches `talker` and `listener` by the following command.

```shell
rdmd launch
```

All source files are in `fugen` directory. The name is changed from `source` due to [the bug](https://github.com/dlang/dub/issues/1913) of DuB. `fugen` is `譜源`. It's a coined word in Japanese and means "source file".