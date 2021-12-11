module test_helper;

mixin template ConvertCheck(alias a)
{
    void check()
    {
        import std.traits : Unconst;

        alias T = Unconst!(typeof(a));
        auto b = T.createC();
        scope (exit)
            T.destroyC(b);
        auto c = T();
        T.convert(a, *b);
        T.convert(*b, c);
        assert(a == c);
    }
}
