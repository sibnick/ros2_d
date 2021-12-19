module test_helper.utils;

import std : replace, to, join, tempDir, buildPath, text, thisProcessID;

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
