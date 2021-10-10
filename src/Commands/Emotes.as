class EmotesCommand : ICommand
{
	string Icon()
	{
		return Icons::SmileO;
	}

	string Description()
	{
		return "Shows a list of emotes available in Better Chat.";
	}

	void Run(const string &in text)
	{
		Renderables::Add(EmotesModalDialog());
	}
}
