class SendTextCommand : ICommand
{
	string m_text;
	string m_description;

	SendTextCommand(const string &in text, const string &in description)
	{
		m_text = text;
		m_description = description;
	}

	string Description()
	{
		return m_description;
	}

	void Run(const string &in text)
	{
		g_window.SendChatMessage(m_text);
	}
}
