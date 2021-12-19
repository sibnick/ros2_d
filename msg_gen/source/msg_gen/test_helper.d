module msg_gen.test_helper;

version (unittest)
{
    import msg_gen.rosidl.type;

    MessageModule fromTestMsgs()
    {
        import test_helper.test_msgs : TestMsgsData, HelperType = Type;
        import std.traits;

        MessageModule mm;
        mm.fullname = TestMsgsData.Msg.name;
        static foreach (type; __traits(allMembers, TestMsgsData.Msg))
        {
            {
                static if (type != "name")
                {
                    alias Struct = mixin("TestMsgsData.Msg." ~ type);
                    Structure s;
                    s.fullname = Struct.name;
                    foreach (m; Struct.members)
                    {
                        Member tmp;
                        tmp.type = Type(m.type.name, m.type.kind != HelperType.Kind.plain, m
                                .type.size);
                        tmp.field = m.field;
                        tmp.defaultText = m.default_;
                        s.members ~= tmp;
                    }
                    mm.messages ~= s;
                }
            }
        }

        return mm;
    }
}
