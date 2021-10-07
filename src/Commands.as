interface ICommand
{
	string Description();
	void Run(const string &in text);
}

namespace Commands
{
	dictionary g_commands;

	ICommand@ Find(const string &in name)
	{
		ICommand@ ret;
		if (!g_commands.Get(name, @ret)) {
			return null;
		}
		return ret;
	}

	void Register(const string &in name, ICommand@ cmd)
	{
		g_commands.Set(name, @cmd);
	}

	void Load()
	{
		Register("version", PassthroughCommand("Prints the dedicated server version."));
		Register("serverlogin", PassthroughCommand("Prints the server login."));
		Register("author", TimeCommand(TimeCommandType::Author));
		Register("gold", TimeCommand(TimeCommandType::Gold));
		Register("silver", TimeCommand(TimeCommandType::Silver));
		Register("bronze", TimeCommand(TimeCommandType::Bronze));
	}
}
