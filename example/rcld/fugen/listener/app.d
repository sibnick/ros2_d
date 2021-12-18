import rcld;
import core.thread;
import std.stdio;
import std.format;
import std.conv;
import std_msgs.msg : String;

class Listener : Node
{
    this(Context cxt)
    {
        super("listener", "", cxt);
        sub = new Subscription!String(this, "/chatter");
        sub.setCallback(&callback);
    }

private:
    void callback(in String msg)
    {
        writefln!"Received: %s"(msg.to!string);
    }

    Subscription!String sub;
}

void main()
{
    auto cxt = new Context();
    auto listener = new Listener(cxt);
    auto executor = new Executor(cxt);
    executor.addNode(listener);

    while (true)
    {
        executor.spinOnce();
    }
}
