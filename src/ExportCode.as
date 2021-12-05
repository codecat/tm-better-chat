namespace BetterChat
{
	void RegisterCommand(const string &in name, ICommand@ cmd)
	{
		Commands::Register(name, cmd);
	}

	void AddSystemLine(const string &in text)
	{
		g_window.AddSystemLine(text);
	}
}
