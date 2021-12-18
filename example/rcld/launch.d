import std;

auto spawn(string cmd, string workDir = __FILE_FULL_PATH__.dirName)
{
    return spawnProcess(cmd.split(" "), environment.toAA, Config.none, workDir);
}

void main()
{
    auto talker = "dub run -c talker".spawn;
    scope (exit)
        talker.wait;
    auto listener = "dub run -c listener".spawn;
    scope (exit)
        listener.wait;
    ">> launched".writeln;
}
