module test_executor;

import std_msgs.msg;
import rcld;
import std.exception;
import test_helper;
import core.time;
import std.format;

@("call spinOnce") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    auto sub = new Subscription!String(node, "chatter");
    auto pub = new Publisher!String(node, "chatter");
    auto executor = new Executor(cxt);
    executor.addNode(node);

    const text = "hello world";
    string received;
    sub.setCallback(delegate(in String msg) { received = msg.data; });

    auto pubMsg = String(text);
    assertNotThrown(pub.publish(pubMsg));

    assert(executor.spinOnce(100.msecs));

    assert(text == received, received);
}

@("timeout spinOnce") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    auto sub = new Subscription!String(node, "chatter");
    auto executor = new Executor(cxt);
    executor.addNode(node);

    string received;
    sub.setCallback(delegate(in String msg) { received = msg.data; });

    assert(!executor.spinOnce(100.msecs));
}

@("loop spinOnce") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    auto sub = new Subscription!String(node, "chatter");
    auto pub = new Publisher!String(node, "chatter");
    auto executor = new Executor(cxt);
    executor.addNode(node);

    string received;
    sub.setCallback(delegate(in String msg) { received = msg.data; });

    foreach (i; 0 .. 5)
    {
        const text = format!"hello world %d"(i);
        auto pubMsg = String(text);
        assertNotThrown(pub.publish(pubMsg));

        assert(executor.spinOnce(100.msecs));

        assert(text == received, received);
    }
}
