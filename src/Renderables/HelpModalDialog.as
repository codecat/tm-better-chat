class HelpModalDialog : ModalDialog
{
	HelpModalDialog()
	{
		super("Help");

		m_size = vec2(500, 500);
	}

	void RenderDialog() override
	{
		UI::Text("This is a list of all chat commands available in Better Chat.");

		UI::Separator();

		UI::BeginChild("Commands");
		for (uint i = 0; i < Commands::g_sortedCommands.Length; i++) {
			string key = Commands::g_sortedCommands[i];
			auto cmd = Commands::Find(key);
			UI::Text(cmd.Icon() + "\\$z /" + key + " \\$bbb- " + cmd.Description());
		}
		UI::EndChild();
	}
}
