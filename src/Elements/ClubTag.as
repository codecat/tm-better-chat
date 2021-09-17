class ElementClubTag : Element
{
	string m_text;

	ElementClubTag(const string &in text)
	{
		m_text = text;
	}

	void Render() override
	{
		UI::Tag(ColoredString(m_text));
	}
}
