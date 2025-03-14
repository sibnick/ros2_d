module msg_gen.commands;
import jcli;
import msg_gen;
import std.file;
import std.path;
import std.stdio;
import colorize;
import msg_gen.util;
import std.conv;
import std.experimental.logger;
import msg_gen.logging;
import rosidl_parser;

@CommandDefault("Generate DUB dependencies from ROS2 message packages.")
struct GenerateDUBDependencies
{
    @ArgPositional("output", "Output directory (e.g. `my_dub/.dub/packages`)")
    string output;

    @ArgNamed("r|regenerate", "Clean `output` first to regenerate msg packages.")
    Nullable!bool regenerate;

    @ArgNamed("dry_run", "Execute parsing ROS2 message packages without generating DUB.")
    Nullable!bool dry_run;

    @ArgNamed("verbose", "Print verbose log.")
    Nullable!bool verbose;

    int onExecute()
    {
        const logLevel = verbose.get(false) ? LogLevel.all : LogLevel.info;

        stdThreadLocalLog.logLevel = logLevel;

        const manifests = findROSIDLPackagesFromEnvironmentVariable();

        if (dry_run.get(false))
        {
            string[][] matrix;
            foreach (m; manifests)
            {
                const pkgName = m.packageName;
                const pkgPath = buildPath(m.installDirectory, "share", pkgName);
                const msgNum = m.messageFiles.length.to!string;
                const outDir = buildPath(output, pkgName ~ "-" ~ m.version_);
                matrix ~= [
                    "Found", pkgName.style(mode.bold), "at", pkgPath, "with",
                    msgNum, "msgs ->", outDir
                ];
            }
            foreach (line; formatMatrix(matrix))
            {
                writeln(line);
            }
        }
        else
        {
            if (regenerate.get(false) && exists(output))
            {
                rmdirRecurse(output);
            }

            foreach (m; manifests)
            {
                generateDUBAsDepend(m, output);
            }
        }
        return 0;
    }
}
