class ElementText : Element
{
	string m_text;
	string m_textPlain;

	ElementText(const string &in text)
	{
		m_text = ColoredString(text);
		m_textPlain = StripFormatCodes(text);
		m_spacingAfter = 0;
	}

	void Render() override
	{
		if (Setting_TextShadow) {
			UI::TextWrappedWindow("\\$s" + m_text, 8);
		} else {
			UI::TextWrappedWindow(m_text, 8);
		}
	}
}
