class ElementEmote : Element
{
	Emote@ m_emote;

	ElementEmote(Emote@ emote)
	{
		@m_emote = emote;
		m_spacingAfter = 2;
	}

	void Render() override
	{
		m_emote.Render();
	}
}
