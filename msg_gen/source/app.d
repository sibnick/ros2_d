import msg_gen;
import jcli;

int main(string[] args)
{
    auto executor = new CommandLineInterface!(msg_gen.commands);
    return executor.parseAndExecute(args);
}
