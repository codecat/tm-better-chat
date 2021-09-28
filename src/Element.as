class Element
{
	ChatLine@ m_line;
	float m_spacingAfter = 8;

	bool IsVisible()
	{
		return true;
	}

	void OnAdded()
	{
	}

	void Render()
	{
	}

	void Advance()
	{
		UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(m_spacingAfter, 4));
		UI::SameLine();
		UI::PopStyleVar();
	}
}
