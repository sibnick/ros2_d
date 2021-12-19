module test_helper.domain_coordinator;

import std.socket;
import std.stdio;
import std.conv;
import std.typecons;
import std.algorithm.mutation : move;

version (foxy)
{
    // https://github.com/ros2/ament_cmake_ros/blob/foxy/domain_coordinator/domain_coordinator/__init__.py#L21
    enum ushort portBase = 22_119;
}
else version (galactic)
{
    // https://github.com/ros2/ament_cmake_ros/blob/galactic/domain_coordinator/domain_coordinator/__init__.py#L21
    enum ushort portBase = 22_119;
}
else
{
    // https://github.com/ros2/ament_cmake_ros/blob/master/domain_coordinator/domain_coordinator/impl.py#L23
    enum ushort portBase = 32_768;
}

struct SocketWrapper
{
    private Socket s;

    @disable this(this);

    ~this()
    {
        if (s)
        {
            s.close();
        }
    }

    int id()
    {
        return s.localAddress().toPortString().to!ushort - portBase;
    }

}

auto findVacantDomainID()
{
    foreach (ushort i; 1 .. 101)
    {
        auto s = new TcpSocket;
        try
        {
            s.bind(new InternetAddress(cast(ushort)(portBase + i)));
            return refCounted(SocketWrapper(s));
        }
        catch (SocketOSException e)
        {
            continue;
        }
    }
    assert(0, "Failed to find vacant deomain_id.");
}

version (foxy) pragma(msg, "ROS_DISTRO is foxy");
version (galactic) pragma(msg, "ROS_DISTRO is galactic");
version (rolling) pragma(msg, "ROS_DISTRO is rolling");

@("choose different domain_id") unittest
{
    auto a = findVacantDomainID();
    auto b = findVacantDomainID();
    assert(a.id != b.id);
}
