class PassthroughCommand : ICommand
{
	string m_description;

	PassthroughCommand(const string &in description)
	{
		m_description = description;
	}

	string Description()
	{
		return m_description;
	}

	void Run(const string &in text)
	{
		g_window.SendChatMessage(text);
	}
}
