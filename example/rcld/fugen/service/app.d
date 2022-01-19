import rcld;
import core.thread;
import std.stdio;
import example_interfaces.srv : AddTwoInts;
import std_msgs.msg : String;
import std.conv;

class ServiceNode : Node
{
    this(Context cxt)
    {
        super("service", "", cxt);
        service = new Service!AddTwoInts(this, "/add_two_ints");
        service.setCallback(&callback);
        sub = new Subscription!String(this, "/chatter");
        sub.setCallback(&subCallback);
    }

private:
    void callback(in AddTwoInts.Request request, out AddTwoInts.Response response)
    {
        writefln("Request %d + %d", request.a, request.b);
        response.sum = request.a + request.b;
    }

    void subCallback(in String msg)
    {
        writefln("Received: %s", msg.to!string);
    }

    Service!AddTwoInts service;
    Subscription!String sub;
}

void main()
{
    auto cxt = new Context();
    auto service = new ServiceNode(cxt);
    auto executor = new Executor(cxt);
    executor.addNode(service);

    executor.spinSome();

}
