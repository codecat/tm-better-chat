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
		m_emote.Render();
		UI::SetPreviousTooltip(m_emote.m_name);
	}
}
