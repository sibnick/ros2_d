import rcld;
import core.thread;
import std.stdio;
import std.format;
import std.conv;
import std_msgs.msg : String;

class Talker : Node
{
    this(Context cxt)
    {
        super("talker", "", cxt);
        pub = new Publisher!String(this, "/chatter");
    }

    void run()
    {
        int count = 0;
        while (true)
        {
            Thread.sleep(1.seconds);
            const msg = String(format!"Hello world %d"(count));
            writefln!"Publishing: %s"(msg.to!string);
            pub.publish(msg);
            count++;
        }
    }

private:
    Publisher!String pub;
}

void main()
{
    auto cxt = new Context();
    auto talker = new Talker(cxt);
    talker.run();
}
