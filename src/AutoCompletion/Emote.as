class AutoCompletionItemEmote : IAutoCompletionItem
{
	string m_name;
	string m_nameLower;
	Emote@ m_emote;

	AutoCompletionItemEmote(const string &in name, Emote@ emote)
	{
		m_name = name;
		m_nameLower = m_name.ToLower();
		@m_emote = emote;
	}

	bool Matches(const string &in text) override
	{
		return m_nameLower.Contains(text);
	}

	string AcceptText()
	{
		return m_name;
	}

	void Render(UI::DrawList@ dl, const vec2 &in pos)
	{
		vec2 size = m_emote.Render(dl, pos, 32);
		dl.AddText(pos + vec2(size.x + 4, 0), vec4(1, 1, 1, 1), m_name);
	}
}
