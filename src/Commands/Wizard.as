class WizardCommand : ICommand
{
	string Icon()
	{
		return Icons::QuestionCircle;
	}

	string Description()
	{
		return "Opens the Better Chat setup wizard.";
	}

	void Run(const string &in text)
	{
		Setting_WizardShown = false;
		Renderables::Add(WizardModalDialog());
	}
}
