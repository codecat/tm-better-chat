class ChatWindow : IChatMessageReceiver
{
	bool m_visible = true;

	array<ChatLine@> m_lines;
	uint m_lineIdIterator;

	bool m_overlayInputWasEnabled;
	bool m_showInput;
	string m_input;
	uint64 m_inputShownTime;

	float m_chatLineFrameHeight = 30.0f;

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

		m_overlayInputWasEnabled = UI::IsOverlayInputEnabledExternally();
		if (!m_overlayInputWasEnabled) {
			UI::EnableOverlayInput();
		}
		m_showInput = true;
		m_inputShownTime = Time::Now;
	}

	void HideInput()
	{
		if (!m_overlayInputWasEnabled) {
			UI::DisableOverlayInput();
		}
		m_showInput = false;
		m_input = "";
	}

	void OnChatMessage(const string &in line)
	{
		// Add the message to the list
		m_lines.InsertLast(ChatLine(m_lineIdIterator++, Time::Stamp, line));

		if (m_lines.Length > uint(Setting_MaximumLines)) {
			m_lines.RemoveRange(0, m_lines.Length - Setting_MaximumLines);
		}
	}

	bool OnKeyPress(bool down, VirtualKey key)
	{
		if (down) {
			if (key == VirtualKey::F4) {
				m_visible = !m_visible;
			}

			if (key == VirtualKey::Return) {
				ShowInput();
			}
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

		if (!UI::IsOverlayInputEnabled()) {
			UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0.75));
			windowFlags |= UI::WindowFlags::NoInputs;
			m_showInput = false;
		}

		if (!UI::IsOverlayShown()) {
			windowFlags |= UI::WindowFlags::NoDecoration;
		}

		bool shouldHideInput = false;

		UI::SetNextWindowPos(5, Draw::GetHeight() - 200 - 50, UI::Cond::FirstUseEver);
		UI::SetNextWindowSize(700, 200, UI::Cond::FirstUseEver);
		UI::Begin("Better Chat", windowFlags);

		vec2 windowPos = UI::GetWindowPos();
		vec2 windowSize = UI::GetWindowSize();

		// Decide on start index
		uint startIndex = 0;
		if (Setting_LimitOnHiddenOverlay && !UI::IsOverlayInputEnabled()) {
			int numLines = int(windowSize.y / m_chatLineFrameHeight) + 1;
			if (uint(numLines) < m_lines.Length) {
				startIndex = m_lines.Length - numLines;
			}
		}

		// Render each line
		for (uint i = startIndex; i < m_lines.Length; i++) {
			m_lines[i].Render();

			float frameHeight = UI::GetFrameHeightWithSpacing();
			if (frameHeight != m_chatLineFrameHeight) {
				m_chatLineFrameHeight = frameHeight;
			}
		}

		// Automatically scroll down if overlay input is not enabled or if the user is at the bottom of the scrolling area
		if (!UI::IsOverlayInputEnabled() || (UI::GetScrollY() >= UI::GetScrollMaxY())) {
			UI::SetScrollHereY(1.0f);
		}
		UI::End();

		// Render the input box
		if (m_showInput) {
			vec2 inputPos = windowPos + vec2(0, windowSize.y + 4);
			if (inputPos.y + 10 > Draw::GetHeight()) {
				inputPos.y = Draw::GetHeight() - 30;
			}
			UI::SetNextWindowPos(int(inputPos.x), int(inputPos.y), UI::Cond::Always);
			UI::SetNextWindowSize(int(windowSize.x), 0, UI::Cond::Always);
			UI::Begin("Better Chat Input", UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoDecoration | UI::WindowFlags::NoSavedSettings);
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

		if (!UI::IsOverlayInputEnabled()) {
			UI::PopStyleColor();
		}

		if (shouldHideInput) {
			HideInput();
		}
	}

	//TODO: Remove this entire menu, it doesn't make sense in this class
	void RenderMenu()
	{
		if (UI::BeginMenu("Better Chat Debug")) {
			if (UI::MenuItem("Add 100 lines of nonsense")) {
				auto emoteKeys = Emotes::g_emotes.GetKeys();

				for (int i = 0; i < 100; i++) {
					string line = "[$<" + DummyData::PlayerName() + "$>] ";

					string msg = DummyData::Lipsum();
					auto parse = msg.Split(" ");
					for (uint j = 0; j < parse.Length; j++) {
						if (j > 0) {
							line += " ";
						}
						line += parse[j];
						if (Math::Rand(0, 2) == 0) {
							line += DummyData::FormattedColor();
						}
						if (Math::Rand(0, 10) == 0) {
							line += " " + emoteKeys[Math::Rand(0, emoteKeys.Length)];
						}
					}

					OnChatMessage(line);
				}
			}
			UI::EndMenu();
		}
	}
}
