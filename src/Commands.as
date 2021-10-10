interface ICommand
{
	string Icon();
	string Description();
	void Run(const string &in text);
}

namespace Commands
{
	dictionary g_commands;
	array<string> g_sortedCommands;

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
		g_sortedCommands.InsertLast(name);
	}

	void Load()
	{
		// Medal times
		Register("author", TimeCommand(TimeCommandType::Author, false));
		Register("gold", TimeCommand(TimeCommandType::Gold, false));
		Register("silver", TimeCommand(TimeCommandType::Silver, false));
		Register("bronze", TimeCommand(TimeCommandType::Bronze, false));

		// Trackmania.io
		Register("trackmaniaio", TmioCommand(false));
		Register("tmio", TmioCommand(false));

		// Built-in commands available on all servers
		Register("version", PassthroughCommand("Prints the dedicated server version."));
		Register("serverlogin", PassthroughCommand("Prints the server login."));

		// Help dialog
		Register("bc-help", HelpCommand());

		// Tell medal times
		Register("tell-author", TimeCommand(TimeCommandType::Author, true));
		Register("tell-gold", TimeCommand(TimeCommandType::Gold, true));
		Register("tell-silver", TimeCommand(TimeCommandType::Silver, true));
		Register("tell-bronze", TimeCommand(TimeCommandType::Bronze, true));

		// Tell Trackmania.io
		Register("tell-trackmaniaio", TmioCommand(true));
		Register("tell-tmio", TmioCommand(true));

		// Promotion
		Register("tell-openplanet", SendTextCommand("$<$f39" + Icons::Heartbeat + "$> Openplanet is an extension platform for Trackmania with many plugins: $lhttps://openplanet.nl/", "Tells chat about Openplanet.", Icons::Heartbeat));
		Register("tell-betterchat", SendTextCommand("$<$96f" + Icons::Bolt + " $ef7Better Chat$> is a complete replacement for the in-game chat: $lhttps://openplanet.nl/files/134", "Tells chat about Better Chat.", Icons::Bolt));
	}
}
