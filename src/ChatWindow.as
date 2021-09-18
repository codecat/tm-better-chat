class ChatWindow : IChatMessageReceiver
{
	bool m_visible = true;

	array<ChatLine@> m_lines;
	uint m_lineIdIterator;

	void Initialize()
	{
	}

	void Clear()
	{
		m_lines.RemoveRange(0, m_lines.Length);
	}

	void OnChatMessage(const string &in line)
	{
		// Add the message to the list
		m_lines.InsertLast(ChatLine(m_lineIdIterator++, line));
	}

	bool OnKeyPress(bool down, VirtualKey key)
	{
		if (down && key == VirtualKey::F4) {
			m_visible = !m_visible;
		}
		return false;
	}

	void Update(float dt)
	{
		if (Setting_ClearOnLeave) {
			auto network = GetApp().Network;
			auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
			if ((serverInfo is null || serverInfo.ServerLogin == "") && m_lines.Length > 0) {
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
			return;
		}

		int windowFlags = UI::WindowFlags::NoTitleBar;
		if (!UI::IsOverlayShown()) {
			UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0.4));
			windowFlags |= UI::WindowFlags::NoDecoration;
		}

		if (UI::Begin("Better Chat", windowFlags)) {
			for (uint i = 0; i < m_lines.Length; i++) {
				m_lines[i].Render();
			}
		}
		if (UI::GetScrollY() >= UI::GetScrollMaxY()) {
			UI::SetScrollHereY(1.0f);
		}
		UI::End();

		if (!UI::IsOverlayShown()) {
			UI::PopStyleColor();
		}
	}
}
