class PassthroughCommand : ICommand
{
	string m_description;
	string m_icon;

	PassthroughCommand(const string &in description, const string &in icon = Icons::ArrowCircleRight)
	{
		m_description = description;
		m_icon = icon;
	}

	string Icon()
	{
		return m_icon;
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
