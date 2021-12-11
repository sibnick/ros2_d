import std.stdio;
import std_msgs.msg;

void main()
{
    auto a = ColorRGBA(0, 1, 2, 3);
    auto b = ColorRGBA.createC();
    scope (exit)
        ColorRGBA.destroyC(b);
    ColorRGBA.convert(a, *b);
    a.writeln;
    writeln(*b);

}
