class ElementClubTag : ElementTag
{
	ElementClubTag(const string &in text)
	{
		super(text);

		if (Setting_ShowClubTagShadow) {
			m_text = "\\$s" + m_text;
		}
	}

	bool IsVisible() override
	{
		return Setting_ShowClubTags;
	}
}
