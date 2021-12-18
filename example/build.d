import std;

enum rootDir = __FILE_FULL_PATH__.dirName;

void run(string cmd, string workDir = rootDir)
{
    assert(spawnShell(cmd, environment.toAA, Config.none, workDir).wait == 0);
}

string exec(string cmd, string workDir = rootDir)
{
    const ret = executeShell(cmd, environment.toAA, Config.none, size_t.max, workDir);
    assert(ret.status == 0);
    return ret.output.strip;
}

void build(string subDir)
{
    writefln!"\033[32m>> Building %s\033[0m"(subDir);
    const dir = buildPath(rootDir, subDir);
    if (buildPath(dir, "setup.d").exists)
    {
        "rdmd setup".run(dir);
    }
    if (buildPath(dir, "build.d").exists)
    {
        "rdmd build".run(dir);
    }
    else
    {
        "dub build".run(dir);
    }
}

void main(string[] args)
{
    if (args.length > 1)
    {
        build(args[1]);
    }
    else
    {
        "ls | grep -v build.d".exec.split("\n").each!(p => build(p));
    }
}
