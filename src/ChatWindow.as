class ChatWindow : IChatMessageReceiver
{
	bool m_visible = true;

	array<ChatLine@> m_lines;
	uint m_lineIdIterator;

	bool m_overlayWasShown;
	bool m_showInput;
	string m_input;
	uint64 m_inputShownTime;

	void Initialize()
	{
	}

	void Clear()
	{
		m_lines.RemoveRange(0, m_lines.Length);
	}

	void ShowInput()
	{
		if (!Permissions::InGameChat()) {
			return;
		}

		m_overlayWasShown = UI::IsOverlayShown();
		UI::ShowOverlay();
		m_showInput = true;
		m_inputShownTime = Time::Now;
	}

	void HideInput()
	{
		if (!m_overlayWasShown) {
			UI::HideOverlay();
		}
		m_showInput = false;
		m_input = "";
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

		if (down && key == VirtualKey::Return) {
			print("Return pressed");
			ShowInput();
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
			UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0.75));
			windowFlags |= UI::WindowFlags::NoDecoration;
			windowFlags |= UI::WindowFlags::NoInputs;

			m_showInput = false;
		}

		bool shouldHideInput = false;

		UI::Begin("Better Chat", windowFlags);
		for (uint i = 0; i < m_lines.Length; i++) {
			m_lines[i].Render();
		}
		if (!UI::IsOverlayShown() || (UI::GetScrollY() >= UI::GetScrollMaxY())) {
			UI::SetScrollHereY(1.0f);
		}
		vec2 windowPos = UI::GetWindowPos();
		vec2 windowSize = UI::GetWindowSize();
		UI::End();

		if (m_showInput) {
			vec2 inputPos = windowPos + vec2(0, windowSize.y + 4);
			if (inputPos.y + 10 > Draw::GetHeight()) {
				inputPos.y = Draw::GetHeight() - 30;
			}
			UI::SetNextWindowPos(int(inputPos.x), int(inputPos.y), UI::Cond::Always);
			UI::SetNextWindowSize(int(windowSize.x), 0, UI::Cond::Always);
			UI::Begin("Better Chat Input", UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoDecoration);
			UI::PushItemWidth(-1);
			UI::SetKeyboardFocusHere();
			UI::PushStyleColor(UI::Col::FrameBg, vec4(0, 0, 0, 0));

			bool pressedEnter = false;
			m_input = UI::InputText("", m_input, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
			if (pressedEnter && (Time::Now - m_inputShownTime) > 100) {
				auto playgroundInterface = GetApp().CurrentPlayground.Interface;
				playgroundInterface.ChatEntry = m_input;
				shouldHideInput = true;
			}

			UI::PopStyleColor();
			UI::PopItemWidth();
			UI::End();
		}

		if (!UI::IsOverlayShown()) {
			UI::PopStyleColor();
		}

		if (shouldHideInput) {
			HideInput();
		}
	}
}
