class ElementClubTag : Element
{
	string m_text;

	ElementClubTag(const string &in text)
	{
		m_text = ColoredString(text);
	}

	void Render() override
	{
		UI::Tag(m_text);
	}
}
