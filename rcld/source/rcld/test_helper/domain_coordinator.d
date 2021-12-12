module rcld.test_helper.domain_coordinator;

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

// Just printing ROS_DISTRO
version (foxy) @("foxy is here") unittest
{
}

version (galactic) @("galactic is here") unittest
{
}

version (rolling) @("rolling is here") unittest
{
}

@("Choose different domain_id") unittest
{
    auto a = findVacantDomainID();
    auto b = findVacantDomainID();
    assert(a.id != b.id);
}

@("Re-pick same domain_id returned") unittest
{
    int a_id, b_id;
    {
        auto a = findVacantDomainID();
        a_id = a.id;
        // Call destructor of a
    }
    {
        auto b = findVacantDomainID();
        b_id = b.id;
        // Call destroctor of b
    }
    assert(a_id == b_id);
}
