class SendTextCommand : ICommand
{
	string m_text;
	string m_description;
	string m_icon;

	SendTextCommand(const string &in text, const string &in description, const string &in icon)
	{
		m_text = text;
		m_description = description;
		m_icon = icon;
	}

	string Icon()
	{
		return "\\$acf" + m_icon;
	}

	string Description()
	{
		return m_description;
	}

	void Run(const string &in text)
	{
		SendChatMessage(m_text);
	}
}
