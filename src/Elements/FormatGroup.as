class ElementFormatGroup : Element
{
	bool m_start;

	ElementFormatGroup(bool start)
	{
		m_start = start;
		m_spacingAfter = 0;
	}

	void Render() override
	{
		if (m_start) {
			UI::BeginFormattingGroup();
			if (Setting_ShowTextShadow) {
				UI::Text("\\$s");
			}
		} else {
			UI::EndFormattingGroup();
		}
	}

	void Advance() override
	{
		if (Setting_ShowTextShadow) {
			Element::Advance();
		}
	}
}
