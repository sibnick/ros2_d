import std;

void run(string cmd, string workDir = __FILE_FULL_PATH__.dirName)
{
    spawnShell(cmd, environment.toAA, Config.none, workDir).wait;
}

void main()
{
    "dub run --root ../../ :msg_gen -- .dub/packages".run;
}
