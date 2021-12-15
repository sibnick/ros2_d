module test_publisher;

import std_msgs.msg;
import rcld;
import std.process;
import std.typecons;
import std.array;
import std.stdio;
import std.exception;

private enum testNamespace = "publisher_test_ns";

string namespaced(string name)
{
    return "/" ~ testNamespace ~ "/" ~ name;
}

@("send a message") unittest
{
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", testNamespace, cxt);
    auto pub = new Publisher!String(node, "chatter");
    auto msg = String("hello world");
    assertNotThrown(pub.publish(msg));
    // calls pub.terminate() internally
    assertNotThrown(node.terminate());
}
