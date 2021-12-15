module test_publisher;

import std_msgs.msg;
import rcld;
import std.exception;
import test_helper;

@("send a message") unittest
{
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    auto pub = new Publisher!String(node, "chatter");
    auto msg = String("hello world");
    assertNotThrown(pub.publish(msg));

    // calls pub.terminate() internally
    assertNotThrown(node.terminate());
}
