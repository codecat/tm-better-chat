class TmioCommand : ICommand
{
	bool m_send;

	TmioCommand(bool send)
	{
		m_send = send;
	}

	string Description()
	{
		if (m_send) {
			return "Tells chat the Trackmania.io link for this map.";
		} else {
			return "Opens the Trackmania.io page for this map.";
		}
	}

	void Run(const string &in text)
	{
		auto map = GetApp().RootMap;
		if (map is null) {
			return;
		}

		string url = "https://trackmania.io/#/leaderboard/" + map.IdName;

		if (m_send) {
			g_window.SendChatMessage("$l[" + url + "]\"" + StripFormatCodes(map.MapName) + "\" on Trackmania.io");
		} else {
			OpenBrowserURL(url);
		}
	}
}
