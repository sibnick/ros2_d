import std;

enum workingDir = __FILE_FULL_PATH__.dirName;

void run(string cmd)
{
    assert(spawnShell(cmd, environment.toAA, Config.none, workingDir).wait == 0);
}

void main()
{
    "dub run --root ../.. :msg_gen -- .dub/packages -r".run;
    "dub test".run;
    return;
}
