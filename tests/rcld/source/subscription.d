module test_subscription;

import std_msgs.msg;
import rcld;
import std.exception;
import test_helper;
import core.thread;
import std.conv;
import std.format;

@("take no message") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    auto sub = new Subscription!String(node, "chatter");
    auto msg = String();
    assert(!sub.take(msg));
    assert(msg == String());

    // calls sub.terminate() internally
    assertNotThrown(node.terminate());
}

@("take one message") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    scope (exit)
        node.terminate();
    auto sub = new Subscription!String(node, "chatter");
    auto pub = new Publisher!String(node, "chatter");
    auto pubMsg = String("hello world");
    auto subMsg = String();

    assertNotThrown(pub.publish(pubMsg));
    foreach (_; 0 .. 10)
    {
        if (sub.take(subMsg))
        {
            break;
        }
        Thread.sleep(50.msecs);
    }
    assert(pubMsg == subMsg, subMsg.to!string);
}

@("take several messages") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    scope (exit)
        node.terminate();
    auto sub = new Subscription!String(node, "chatter");
    auto pub = new Publisher!String(node, "chatter");

    foreach (i; 0 .. 5)
    {
        auto pubMsg = String(format!"hello world %d"(i));
        auto subMsg = String();

        assertNotThrown(pub.publish(pubMsg));
        foreach (_; 0 .. 10)
        {
            if (sub.take(subMsg))
            {
                break;
            }
            Thread.sleep(50.msecs);
        }
        assert(pubMsg == subMsg, subMsg.to!string);
    }
}
