class AutoCompletionItemMention : IAutoCompletionItem
{
	string m_name;
	string m_nameLower;

	AutoCompletionItemMention(const string &in name)
	{
		m_name = name;
		m_nameLower = m_name.ToLower();
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
		return "@" + m_name;
	}

	void Render(UI::DrawList@ dl, const vec2 &in pos) const override
	{
		dl.AddText(pos + vec2(0, 6), vec4(1, 1, 1, 1), m_name);
	}
}
