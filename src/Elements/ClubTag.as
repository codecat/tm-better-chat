class ElementClubTag : ElementTag
{
	ElementClubTag(const string &in text)
	{
		super(text);
	}

	bool IsVisible() override
	{
		return Setting_ShowClubTags;
	}
}
