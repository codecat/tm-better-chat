class HelpCommand : BetterChat::ICommand
{
	string Icon()
	{
		return Icons::QuestionCircle;
	}

	string Description()
	{
		return "Shows a list of commands available in Better Chat.";
	}

	void Run(const string &in text)
	{
		Renderables::Add(HelpModalDialog());
	}
}
