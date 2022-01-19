module test_std_srvs;
import std_srvs.srv;
import test_helper;

@("SetBool") unittest
{
    {

        const a = SetBool.Request(true);
        mixin ConvertCheck!(a);
        check();
    }
    {
        const a = SetBool.Response(true, "abc");
        mixin ConvertCheck!(a);
        check();
    }
}
