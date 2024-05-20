
import std.stdio;
import std.file;

void main()
{
    import std;
    import std.process;
    auto rosDist = environment.get("ROS_DISTRO");
    if (rosDist=="humble")
    {
        auto includes_dir = i"/opt/ros/$(rosDist)/include/".text;
        import std.file;
        string includes;

        foreach (dir; dirEntries(includes_dir, SpanMode.shallow, false))
        {
            includes ~= " --include-path " ~ dir;
        }

        auto gen_mk_tmpl = `DST = source/rcl/package.d
SRC = source/rcl/package.dpp

$(DST): $(SRC)` ~ i"
\tCC=clang dub run -y dpp -- --preprocess-only $(includes) source/rcl/package.dpp
\tsed -i -e '/struct _IO_FILE/,/}/d' source/rcl/package.d
\tsed -i -e '/module rcl/a import core.stdc.stdio;' source/rcl/package.d".text;

        writeln(gen_mk_tmpl);
    } else {
        writeln(readText("gen.mk.old"));
    }
    
}
