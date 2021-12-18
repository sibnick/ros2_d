/**
 * This is a message usage example.
 */
import std.stdio;
import std_msgs.msg : ColorRGBA;

void main()
{
    const a = ColorRGBA(0, 1, 2, 3);
    auto b = ColorRGBA.createC();
    auto c = ColorRGBA();

    scope (exit)
        ColorRGBA.destroyC(b);
    ColorRGBA.convert(a, *b);
    ColorRGBA.convert(*b, c);

    writeln(a);
    writeln(*b);
    writeln(c);
}
