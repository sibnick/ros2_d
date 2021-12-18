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

void main()
{
    "cat dub.json"
        .exec
        .parseJSON["configurations"]
        .array
        .map!(c => c["name"].str)
        .each!(c => format!"dub build -c %s"(c).run);
}
