module msg_gen.logging;

import colorize;
import std.experimental.logger;
import std.stdio;
import std.format;

static this()
{
    version (unittest)
    {
        stdThreadLocalLog = new MsgGenFileLogger(stderr, LogLevel.off);
    }
    else
    {
        stdThreadLocalLog = new MsgGenFileLogger(stderr, LogLevel.info);
    }
}

string colorLogLevel(LogLevel l) @safe
{
    auto color = fg.init;
    switch (l)
    {
    case LogLevel.trace:
    case LogLevel.info:
        color = fg.green;
        break;
    case LogLevel.warning:
        color = fg.yellow;
        break;
    case LogLevel.error:
    case LogLevel.critical:
    case LogLevel.fatal:
        color = fg.red;
        break;
    default:
        break;
    }

    import std.conv : to;

    return format!"[%s]"(l.to!string).color(color);
}

class MsgGenFileLogger : FileLogger
{
    import std.concurrency : Tid;
    import std.datetime.systime : SysTime;
    import std.format.write : formattedWrite;

    this(File file = stderr, LogLevel l = LogLevel.info) @safe
    {
        super(file, l);
    }

    override protected void beginLogMsg(string file, int line, string funcName,
        string prettyFuncName, string moduleName, LogLevel logLevel,
        Tid threadId, SysTime timestamp, Logger logger)
    @safe
    {
        import std.string : lastIndexOf;

        ptrdiff_t fnIdx = file.lastIndexOf('/') + 1;
        ptrdiff_t funIdx = funcName.lastIndexOf('.') + 1;

        auto lt = this.file_.lockingTextWriter();
        systimeToISOString(lt, timestamp);

        formattedWrite(lt, " %s %s:%u:%s ", colorLogLevel(logLevel),
            file[fnIdx .. $], line, funcName[funIdx .. $]);
    }
}
