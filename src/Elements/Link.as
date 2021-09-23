class ElementLink : ElementText
{
	string m_url;

	bool m_hovered = false;

	ElementLink(const string &in text, const string &in url)
	{
		super(text);

		m_url = url;
		if (!m_url.StartsWith("https://") && !m_url.StartsWith("http://")) {
			m_url = "https://" + m_url;
		}
	}

	void Render() override
	{
		vec4 color = vec4(0.5f, 0.5f, 1, 1);
		if (m_hovered) {
			color = vec4(0.4f, 0.4f, 1, 1);
		}

		UI::PushStyleColor(UI::Col::Text, color);
		ElementText::Render();
		UI::PopStyleColor();

		if (UI::IsItemClicked()) {
			OpenBrowserURL(m_url);
		}

		m_hovered = UI::IsItemHovered();
		UI::SetPreviousTooltip(m_url);
	}
}
