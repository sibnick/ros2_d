module test_service;

import example_interfaces.srv : AddTwoInts;
import rcld;
import core.thread;
import test_helper;
import std.datetime.stopwatch;

@("service request and response") unittest
{
    const a = 1;
    const b = 2;
    const long gt = 3;
    long ans;
    bool received = false;
    enum ns = makeNamespace;
    auto cxt = new Context();
    scope (exit)
        cxt.shutdown();

    auto node = new Node("test", ns, cxt);
    scope (exit)
        node.terminate();

    auto client = new Client!AddTwoInts(node, "add_two_ints");
    auto service = new Service!AddTwoInts(node, "add_two_ints");
    client.setCallback((in AddTwoInts.Response res) {
        ans = res.sum;
        received = true;
    });

    auto executor = new Executor(cxt);
    service.setCallback((in AddTwoInts.Request req, out AddTwoInts.Response res) {
        res.sum = req.a + req.b;
    });
    executor.addNode(node);

    client.sendRequest(AddTwoInts.Request(a, b));

    auto timeout = 1.seconds;
    auto sw = StopWatch();
    sw.start();
    while (!received && (sw.peek() < timeout))
    {
        executor.spinSome();
    }
    assert(received);
    assert(ans == gt);
}
