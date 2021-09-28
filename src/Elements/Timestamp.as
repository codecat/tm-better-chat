class ElementTimestamp : ElementTag
{
	ElementTimestamp(int64 time)
	{
		super(Time::FormatString("%H:%M:%S", time));
	}

	bool IsVisible() override
	{
		return Setting_ShowTimestamp;
	}
}
