# rcld

ROS2 client library for Dlang.

## Supported features

- Node creation
- Publisher
- Subscription
- Executor (simple implementation)

## Examples

Example Publisher

```d
import std;
import core.thread;
import rcld;
import std_msgs.msg : String;

void main() {
    auto cxt = new Context();
    auto node = new Node("publisher", "", cxt);
    auto pub = new Publisher!String(node, "chatter");
    foreach(i; 0 .. 10) {
        const msg = String(format!"Hello world %d"(i));
        pub.publish(msg);
        Thread.sleep(1.seconds);
    }
}
```

Example Subscription

```d
import std;
import core.time;
import rcld;
import std_msgs.msg : String;

void main() {
    auto cxt = new Context();
    auto node = new Node("subscription", "", cxt);
    auto sub = new Subscription!String(node, "chatter");
    sub.setCallback(delegate(in String msg) {
        msg.writeln;
    });
    auto exec = new Executor(cxt);
    exec.addNode(node);

    while(true) {
        exec.spinOnce(1.seconds);
    }
}
```
