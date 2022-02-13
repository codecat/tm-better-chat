class ElementTimestamp : ElementTag
{
	ElementTimestamp(int64 time)
	{
		super(Time::FormatString("%H:%M:%S", time));
	}

	void Render() override
	{
		m_color = m_line.GetHighlightColor(UI::TAG_COLOR);
		ElementTag::Render();
	}

	bool IsVisible() override
	{
		return Setting_ShowTimestamp;
	}
}
