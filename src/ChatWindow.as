class ChatWindow
{
	bool m_visible = true;

	array<ChatLine@> m_lines;
	uint m_lineIdIterator;

	void Clear()
	{
		g_lines.RemoveRange(0, g_lines.Length);
	}

	void Update(float dt)
	{
		if (Setting_ClearOnLeave) {
			auto network = GetApp().Network;
			auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
			if (serverInfo is null || serverInfo.ServerLogin == "" && g_lines.Length > 0) {
				Clear();
			}
		}
	}

	void Render()
	{
		if (!m_visible) {
			return;
		}

		auto network = GetApp().Network;
		auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
		if (serverInfo is null || serverInfo.ServerLogin == "") {
			if (g_lines.Length > 0) {
				Clear();
			}
			return;
		}

		//
	}
}
