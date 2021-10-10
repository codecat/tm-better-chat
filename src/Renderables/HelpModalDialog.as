class HelpModalDialog : ModalDialog
{
	HelpModalDialog()
	{
		super("Help");
	}

	void RenderDialog() override
	{
		for (uint i = 0; i < Commands::g_sortedCommands.Length; i++) {
			string key = Commands::g_sortedCommands[i];
			auto cmd = Commands::Find(key);
			UI::Text(cmd.Icon() + "\\$z /" + key + " \\$bbb- " + cmd.Description());
		}
	}
}
