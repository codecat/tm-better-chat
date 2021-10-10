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

		// Tell medal times
		Register("tellauthor", TimeCommand(TimeCommandType::Author, true));
		Register("tellgold", TimeCommand(TimeCommandType::Gold, true));
		Register("tellsilver", TimeCommand(TimeCommandType::Silver, true));
		Register("tellbronze", TimeCommand(TimeCommandType::Bronze, true));

		// Tell Trackmania.io
		Register("telltrackmaniaio", TmioCommand(true));
		Register("telltmio", TmioCommand(true));

		// Promotion
		Register("tellopenplanet", SendTextCommand("$<$f39" + Icons::Heartbeat + "$> Openplanet is an extension platform for Trackmania with many plugins: $lhttps://openplanet.nl", "Tells chat about Openplanet."));
		Register("tellbetterchat", SendTextCommand("$<$96f" + Icons::Bolt + " $ef7Better Chat$> is a complete replacement for the in-game chat: $lhttps://openplanet.nl/files/134", "Tells chat about Better Chat."));
	}
}
