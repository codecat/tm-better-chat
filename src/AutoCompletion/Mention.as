class AutoCompletionItemMention : IAutoCompletionItem
{
	string m_name;
	string m_nameLower;

	AutoCompletionItemMention(const string &in name)
	{
		m_name = name;
		m_nameLower = m_name.ToLower();
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
		dl.AddText(pos, vec4(1, 1, 1, 1), m_name);
	}
}
