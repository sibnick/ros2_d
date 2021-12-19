import msg_gen;
import jcli;

version (unittest)
{
    // Do nothing
}
else
{
    int main(string[] args)
    {
        auto executor = new CommandLineInterface!(msg_gen.commands);
        return executor.parseAndExecute(args);
    }
}
