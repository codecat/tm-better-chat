class ElementLink : Element
{
	string m_text;
	string m_url;

	ElementLink(const string &in text, const string &in url)
	{
		m_text = ColoredString(text);
		m_url = url;

		if (!m_url.StartsWith("https://") && !m_url.StartsWith("http://")) {
			m_url = "https://" + m_url;
		}

		m_spacingAfter = 0;
	}

	void Render() override
	{
		const int FRAME_PADDING = 4;

		vec2 textSize = Draw::MeasureString(m_text);

		if (UI::InvisibleButton(m_url, textSize + vec2(0, FRAME_PADDING * 2))) {
			OpenBrowserURL(m_url);
		}

		vec4 rect = UI::GetItemRect();
		auto dl = UI::GetWindowDrawList();

		string text;
		vec4 color;

		if (UI::IsItemHovered()) {
			text = "\\$<\\$ccf" + m_text + "\\$>";
			color = vec4(0.66f, 0.66f, 1, 1);
		} else {
			text = "\\$<\\$aaf" + m_text + "\\$>";
			color = vec4(0.4f, 0.4f, 1, 1);
		}

		dl.AddText(vec2(rect.x, rect.y + FRAME_PADDING), vec4(1, 1, 1, 1), text);

		float bottomY = rect.y + FRAME_PADDING + textSize.y;
		dl.AddLine(
			vec2(rect.x, bottomY),
			vec2(rect.x + rect.z, bottomY),
			color
		);

		UI::SetPreviousTooltip(m_url);
	}
}
