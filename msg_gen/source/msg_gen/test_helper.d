module msg_gen.test_helper;
version (unittest)
{

    import std.file;
    import std.path;
    import std.array;
    import std.string;
    import std.conv;
    import std.process : thisProcessID;

    template makeUniqTemp(string f = __FILE__, int l = __LINE__)
    {
        string makeUniqTemp()
        {
            enum f_text = f.replace("/", ".");

            enum l_text = l.to!string;
            enum base = "deleteme.dmd.unittest";

            return text(buildPath(tempDir(), [base, f_text, l_text].join(".")), ".pid", thisProcessID);
        }
    }

    import msg_gen.rosidl.type;
    import msg_gen.rosidl.manifest;
    import std.typecons;

    private enum null_ = Nullable!string();

    struct TestData
    {
        enum packageName = "test_msgs";
        enum version_ = "1.2.3";

        struct Input
        {
            enum standAloneIdl = import("test/input/test_msgs/msg/StandAlone.idl");
            enum dependIdl = import("test/input/test_msgs/msg/Depend.idl");
            enum constantIdl = import("test/input/test_msgs/msg/Constant.idl");
            enum packageXml = import("test/input/test_msgs/package.xml");
        }
        // output
        struct Output
        {
            enum dubJson = import("test/output/test_msgs/dub.json");
            enum msgD = import("test/output/test_msgs/source/test_msgs/msg.d");
            enum cMsgD = import("test/output/test_msgs/source/test_msgs/c/msg.d");
        }

        struct Internal
        {
            // internal
            enum standAlone = Structure("test_msgs::msg::StandAlone", [
                        Member(Type("boolean", false), "data1", null_, "\" comment for member 1\""),
                        Member(Type("int32", false), "data2", "0", "\" comment for member 2\""),
                        Member(Type("float", false), "data3", "0.0"),
                        Member(Type("string", false), "data4", "\"hello\""),
                        Member(Type("int32", true), "array1", null_, "\" comment for array member 1\""),
                        Member(Type("int32", true), "array2", "\"(-1, 0, 1)\""),
                        Member(Type("string", true), "array3", "\"('aa', 'bb')\""),
                    ],
                    [],
                    "\" comment for struct\"\"\\n\"\" newline\"".nullable);

            enum depend = Structure("test_msgs::msg::Depend", [
                        Member(Type("builtin_interfaces::msg::Time", false), "stamp"),
                        Member(Type("string", false), "data"),
                    ]);

            enum constant = Structure("test_msgs::msg::Constant",
                    [Member(Type("uint8", false), "data")],
                    [Constant(Type("uint8", false), "TEST", "0")]
                );

            enum builtinType = Type("builtin_interfaces::msg::Time", false);

            enum manifest =
                Manifest("test_msgs", "1.2.3", "install/test_msgs", MessageModule("test_msgs::msg", [
                            builtinType,
                        ], [
                            standAlone,
                            depend,
                            constant,
                        ]));
        }
    }
}
