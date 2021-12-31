// https://dlang.org/phobos/std_experimental_logger_core.html#.moduleLogLevel
import std.experimental.logger;

version (noLogging)
{
    enum logLevel = LogLevel.off;
}
else
{
    enum logLevel = LogLevel.info;
}
