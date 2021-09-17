array<ChatLine@> g_lines;
uint g_lineIdIterator;
bool g_visible = true;

void Render()
{
	auto network = GetApp().Network;
	auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
	if (serverInfo is null || serverInfo.ServerLogin == "") {
		if (g_lines.Length > 0) {
			g_lines.RemoveRange(0, g_lines.Length);
		}
		return;
	}

	if (!g_visible) {
		return;
	}

	int windowFlags = UI::WindowFlags::NoTitleBar;
	if (!UI::IsOverlayShown()) {
		UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0.4));
		windowFlags |= UI::WindowFlags::NoDecoration;
	}

	if (UI::Begin("Better Chat", windowFlags)) {
		for (uint i = 0; i < g_lines.Length; i++) {
			g_lines[i].Render();
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

string SanitizeLine(const string &in line)
{
	return line.Replace("\n", " ");
}

bool OnKeyPress(bool down, VirtualKey key)
{
	if (down && key == VirtualKey::F4) {
		g_visible = !g_visible;
	}
	return false;
}

void Main()
{
	LoadEmotes();

	auto network = GetApp().Network;

	uint lastTime = 0;
	if (network.ChatHistoryTimestamp.Length > 0) {
		lastTime = network.ChatHistoryTimestamp[0];
	}

	while (true) {
		uint highestTime = 0;

		for (uint i = 0; i < network.ChatHistoryTimestamp.Length; i++) {
			string line = SanitizeLine(network.ChatHistoryLines[i]);
			uint time = network.ChatHistoryTimestamp[i];

			// Sometimes, the most recent message is empty in the history lines for 1 frame, so we ignore any empty lines.
			// If we do that before we handle timestamps, we can resume on messages that get their line filled in on the next frame.
			if (line == "") {
				continue;
			}

			// Stop if we've reached the time since the last poll
			if (time <= lastTime) {
				break;
			}

			// Remember the highest timestamp
			if (time > highestTime) {
				highestTime = time;
			}

			// Add the message to the list
			g_lines.InsertLast(ChatLine(g_lineIdIterator++, line));
		}

		if (highestTime > 0) {
			lastTime = highestTime;
		}

		yield();
	}
}
