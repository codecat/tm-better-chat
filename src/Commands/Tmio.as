class TmioCommand : ICommand
{
	string Description()
	{
		return "Tells chat the Trackmania.io link for this map.";
	}

	void Run(const string &in text)
	{
		auto map = GetApp().RootMap;
		if (map is null) {
			return;
		}

		g_window.SendChatMessage("$l[https://trackmania.io/#/leaderboard/" + map.IdName + "]" + StripFormatCodes(map.MapName) + " on Trackmania.io");
	}
}
