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
			if (Setting_TextShadow) {
				UI::Text("\\$s");
			}
		} else {
			UI::EndFormattingGroup();
		}
	}
}
