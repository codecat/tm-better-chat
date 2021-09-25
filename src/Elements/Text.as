class ElementText : Element
{
	string m_text;

	ElementText(const string &in text)
	{
		m_text = ColoredString(text);
		m_spacingAfter = 0;
	}

	void Render() override
	{
		UI::TextWrappedWindow(m_text, 8);
	}
}
