import rcld;
import core.thread;
import std.stdio;
import example_interfaces.srv : AddTwoInts;

class ClientNode : Node
{
    this(Context cxt)
    {
        super("client", "", cxt);
        client = new Client!AddTwoInts(this, "/add_two_ints");
        client.setCallback(&callback);
    }

    void send(int a, int b)
    {
        client.sendRequest(AddTwoInts.Request(a, b));
    }

private:
    void callback(in AddTwoInts.Response response)
    {
        writeln("Received: ", response);
    }

    Client!AddTwoInts client;
}

void main()
{
    auto cxt = new Context();
    auto client = new ClientNode(cxt);
    auto executor = new Executor(cxt);
    executor.addNode(client);

    Thread.sleep(2.seconds);

    client.send(1, 2);
    executor.spinSome();
}
