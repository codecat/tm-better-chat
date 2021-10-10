class AutoCompletionItemCommand : IAutoCompletionItem
{
	string m_name;
	string m_nameLower;
	string m_description;
	string m_icon;
	ICommand@ m_command;

	AutoCompletionItemCommand(const string &in name, ICommand@ cmd)
	{
		m_name = name;
		m_nameLower = m_name.ToLower();
		@m_command = cmd;
		m_description = cmd.Description();
		m_icon = cmd.Icon();
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
		return "/" + m_name;
	}

	void Render(UI::DrawList@ dl, const vec2 &in pos) const override
	{
		const float textOffsetX = 20;
		dl.AddText(pos + vec2(0, 6), vec4(1, 1, 1, 1), m_icon);
		dl.AddText(pos + vec2(textOffsetX, -2), vec4(1, 1, 1, 1), m_name);
		dl.AddText(pos + vec2(textOffsetX, 14), vec4(0.7f, 0.7f, 0.7f, 1), m_description);
	}
}
