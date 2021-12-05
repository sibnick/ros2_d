module msg_gen.rosidl.manifest;

import msg_gen.rosidl.type;
import std.algorithm;
import std.array;

struct Manifest
{
    string packageName;
    string version_;
    string installDirectory;
    MessageModule message;

    bool hasMessages() const @property
    {
        return message.messages.length > 0;
    }

    string[] depends() const @property
    {
        string[] deps;
        deps ~= message.uniqueDependModules.map!(d => d.split("::")[0]).array;
        return deps;
    }
}
