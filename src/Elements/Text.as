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
		vec2 pos = UI::GetCursorPos();

		if (Setting_TextShadow) {
			//NOTE: We can't aim the shadow down because the scrolling area increases in height if we add 1 pixel
			UI::SetCursorPos(pos + vec2(1, -1));
			UI::AlignTextToFramePadding();
			UI::PushStyleColor(UI::Col::Text, vec4(0, 0, 0, 1));
			UI::TextWrappedWindow(m_textPlain, 9, 1);
			UI::PopStyleColor();

			UI::SetCursorPos(pos);
			UI::AlignTextToFramePadding();
		}

		UI::TextWrappedWindow(m_text, 8);
	}
}
