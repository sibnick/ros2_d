#!/usr/bin/env rdmd
import std;

void run(string cmd)
{
    assert(cmd.spawnShell.wait == 0);
}

void main()
{
    "dub build :msg_gen".run;
}
