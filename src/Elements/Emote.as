class ElementEmote : Element
{
	string m_name;
	Emote@ m_emote;

	ElementEmote(const string &in name, Emote@ emote)
	{
		m_name = name;
		@m_emote = emote;
		m_spacingAfter = 0;
	}

	void Render() override
	{
		m_emote.Render();
		UI::SetPreviousTooltip(m_name);
	}
}
