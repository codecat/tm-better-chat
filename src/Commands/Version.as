class VersionCommand : PassthroughCommand
{
	VersionCommand(const string &in description)
	{
		super(description);
	}

	void Run(const string &in text) override
	{
		g_window.AddSystemLine("$<$f39" + Icons::Heartbeat + "$> Openplanet " + Meta::OpenplanetBuildInfo());

		PassthroughCommand::Run(text);
	}
}
