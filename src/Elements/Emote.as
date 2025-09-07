class ElementEmote : Element
{
	Emote@ m_emote;

	ElementEmote(Emote@ emote)
	{
		@m_emote = emote;
		m_spacingAfter = 0;
	}

	void Render() override
	{
		m_emote.Render(24 * UI::GetScale());

		string tooltip = m_emote.m_name;
		if (m_emote.m_source !is null) {
			tooltip += " \\$666(" + m_emote.m_source.m_name + ")";
		}
		UI::SetPreviousTooltip(tooltip);
	}
}
