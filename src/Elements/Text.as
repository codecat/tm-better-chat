class ElementText : Element
{
	string m_text;

	ElementText(const string &in text)
	{
		m_text = ColoredString(text);
		m_spacingAfter = 2;
	}

	void Render() override
	{
		UI::TextWrappedWindow(m_text);
	}
}
