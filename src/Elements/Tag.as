class ElementTag : Element
{
	string m_text;
	vec4 m_color;

	ElementTag(const string &in text)
	{
		m_text = ColoredString(text).Replace("\n", " ");
		m_color = UI::TAG_COLOR;
	}

	void SetHue(float hue)
	{
		m_color = UI::HSV(hue, 0.6f, 0.6f);
	}

	void Render() override
	{
		UI::Tag(m_text, m_color);
	}
}
