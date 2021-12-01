import std.stdio;
import std_msgs.msg;
import std_msgs.c.msg;

void main()
{
    auto a = ColorRGBA(0, 1, 2, 3);
    auto b = ColorRGBA.createC();
    ColorRGBA.convert(a, *b);
    a.writeln;
    writeln(*b);

    auto c = Int32MultiArray(MultiArrayLayout([MultiArrayDimension("x", 1, 2)], 0), [
            1, 2
        ]);
    auto d = Int32MultiArray.createC();
    Int32MultiArray.convert(c, *d);
    writeln(c);
    writeln(*d);
    Int32MultiArray e;
    Int32MultiArray.convert(*d, e);
    writeln(e);
}
