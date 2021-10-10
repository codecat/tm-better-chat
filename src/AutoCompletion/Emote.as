class AutoCompletionItemEmote : IAutoCompletionItem
{
	string m_nameLower;
	Emote@ m_emote;

	AutoCompletionItemEmote(Emote@ emote)
	{
		@m_emote = emote;
		m_nameLower = m_emote.m_name.ToLower();
	}

	bool Matches(const string &in text) const override
	{
		return m_nameLower.Contains(text);
	}

	int Distance(const string &in text) const override
	{
		if (m_nameLower.StartsWith(text)) {
			return 0;
		}
		return 1;
	}

	string AcceptText() const override
	{
		return m_emote.m_name;
	}

	void Render(UI::DrawList@ dl, const vec2 &in pos) const override
	{
		vec2 size = m_emote.Render(dl, pos, 32);
		dl.AddText(pos + vec2(size.x + 4, 6), vec4(1, 1, 1, 1), m_emote.m_name);
	}
}
