namespace Commands
{
	dictionary g_commands;
	array<string> g_sortedCommands;

	BetterChat::ICommand@ Find(const string &in name)
	{
		BetterChat::ICommand@ ret;
		if (!g_commands.Get(name, @ret)) {
			return null;
		}
		return ret;
	}

	void Register(const string &in name, BetterChat::ICommand@ cmd)
	{
		g_commands.Set(name, @cmd);

		if (g_sortedCommands.Find(name) == -1) {
			g_sortedCommands.InsertLast(name);
		}
	}

	void Unregister(const string &in name)
	{
		g_commands.Delete(name);

		int index = g_sortedCommands.Find(name);
		if (index != -1) {
			g_sortedCommands.RemoveAt(index);
		}
	}

	void Load()
	{
		// Medal times
		Register("author", TimeCommand(TimeCommandType::Author, false));
		Register("gold", TimeCommand(TimeCommandType::Gold, false));
		Register("silver", TimeCommand(TimeCommandType::Silver, false));
		Register("bronze", TimeCommand(TimeCommandType::Bronze, false));

#if TMNEXT
#if DEPENDENCY_NADEOSERVICES
		// World record
		Register("wr", TimeCommand(TimeCommandType::WorldRecord, false));
		// champion medal
		Register("champion", TimeCommand(TimeCommandType::Champion, false));
#endif

		// Trackmania.io
		Register("trackmaniaio", TmioCommand(false));
		Register("tmio", TmioCommand(false));
#endif

		// Built-in commands available on all servers
		Register("version", VersionCommand("Prints the dedicated server version as well as the Openplanet version."));
		Register("serverlogin", PassthroughCommand("Prints the server login."));

		// Help dialog
		Register("bc-help", HelpCommand());

		// Emotes dialog
		Register("bc-emotes", EmotesCommand());

		// Setup wizard dialog
		Register("bc-wizard", WizardCommand());

		// Tell medal times
		Register("tell-author", TimeCommand(TimeCommandType::Author, true));
		Register("tell-gold", TimeCommand(TimeCommandType::Gold, true));
		Register("tell-silver", TimeCommand(TimeCommandType::Silver, true));
		Register("tell-bronze", TimeCommand(TimeCommandType::Bronze, true));

#if TMNEXT
#if DEPENDENCY_NADEOSERVICES
		// Tell world record
		Register("tell-wr", TimeCommand(TimeCommandType::WorldRecord, true));
		// champion medal
		Register("tell-champion", TimeCommand(TimeCommandType::Champion, true));
#endif

		// Tell Trackmania.io
		Register("tell-trackmaniaio", TmioCommand(true));
		Register("tell-tmio", TmioCommand(true));
#endif

		// Promotion
		Register("tell-openplanet", SendTextCommand("$<$f39" + Icons::Heartbeat + "$> Openplanet is an extension platform for Trackmania with many plugins: $lhttps://openplanet.dev/", "Tells chat about Openplanet.", Icons::Heartbeat));
		Register("tell-betterchat", SendTextCommand("$<$96f" + Icons::Bolt + " $ef7Better Chat$> is a complete replacement for the in-game chat: $lhttps://openplanet.dev/plugin/betterchat", "Tells chat about Better Chat.", Icons::Bolt));
	}
}
