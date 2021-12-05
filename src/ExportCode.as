namespace BetterChat
{
	void RegisterCommand(const string &in name, ICommand@ cmd)
	{
		Commands::Register(name, cmd);
	}
}
