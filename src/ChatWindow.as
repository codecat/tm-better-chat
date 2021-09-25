class ChatWindow : IChatMessageReceiver
{
	bool m_visible = true;

	array<ChatLine@> m_lines;
	uint m_lineIdIterator = 0;

	bool m_displaySystem = true;
	bool m_displayOnlyFavorites = false;

	bool m_overlayInputWasEnabled = false;
	bool m_showInput = false;
	string m_input;
	uint64 m_inputShownTime = 0;

	float m_chatLineFrameHeight = 30.0f;
	string m_previousServer;
	bool m_overlayWasShown = false;

	bool m_scrollToBottom = false;

	uint64 m_lastMessageTime = 0;

	void Initialize()
	{
	}

	void Clear()
	{
		m_lines.RemoveRange(0, m_lines.Length);

		if (Setting_ShowHelp) {
			auto plugin = Meta::ExecutingPlugin();
			AddLine("$96f" + Icons::Bolt + " $ef7Better Chat " + plugin.Version + " $eee- Open the overlay for options");
		}
	}

	void SendChatMessage(const string &in text)
	{
		auto playgroundInterface = GetApp().CurrentPlayground.Interface;
		playgroundInterface.ChatEntry = text;
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

	void AddLine(const string &in line)
	{
		ChatLine@ newLine = ChatLine(m_lineIdIterator++, Time::Stamp, line);

		// Check if this line should be filtered out
		if (newLine.m_isFiltered) {
			return;
		}

		// Add the line to the list of messages
		m_lines.InsertLast(newLine);
		if (m_lines.Length > uint(Setting_MaximumLines)) {
			m_lines.RemoveRange(0, m_lines.Length - Setting_MaximumLines);
		}

		m_lastMessageTime = Time::Now;

		// Maybe play a sound
		if (Setting_SoundGain > 0) {
			Audio::Sample@ sound = null;
			if (Setting_SoundChat) {
				@sound = g_sndChat;
			}
			if (newLine.m_isSystem && Setting_SoundSystem) {
				@sound = g_sndChatSystem;
			}
			if (newLine.m_isMention && Setting_SoundMention) {
				@sound = g_sndChatMention;
			}
			if (newLine.m_isFavorite && Setting_SoundFavorite) {
				@sound = g_sndChatFavorite;
			}
			if (sound !is null) {
				Audio::Play(sound, Setting_SoundGain);
			}
		}
	}

	void OnChatMessage(const string &in line)
	{
		AddLine(line);
	}

	bool OnKeyPress(bool down, VirtualKey key)
	{
		if (down) {
			if (key == VirtualKey::F4) {
				m_visible = !m_visible;
			}

			if (m_visible && key == VirtualKey::Return) {
				ShowInput();
			}
		}

		return false;
	}

	void OnNewServerAsync()
	{
		while (GetApp().CurrentPlayground is null) {
			yield();
		}
		trace("Telling server about Better Chat's format via /setformat");
		SendChatMessage("/setformat json");
	}

	void OnServerChanged(const string &in login)
	{
		if (login != "") {
			Clear();
			return;
		}
		startnew(CoroutineFunc(OnNewServerAsync));
	}

	void Update(float dt)
	{
		bool isOverlayShown = UI::IsOverlayShown();
		if (m_overlayWasShown != isOverlayShown) {
			m_scrollToBottom = true;
			m_overlayWasShown = isOverlayShown;
		}

		if (Setting_ClearOnLeave) {
			auto network = GetApp().Network;
			auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);

			string serverLogin;
			if (serverInfo !is null) {
				serverLogin = serverInfo.ServerLogin;
			}

			if (serverLogin != m_previousServer) {
				m_previousServer = serverLogin;
				OnServerChanged(serverLogin);
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
			float alpha = 0;
			switch (Setting_BackgroundStyle) {
				case BackgroundStyle::Hidden: alpha = 0; break;
				case BackgroundStyle::Transparent: alpha = 0.75f; break;
				case BackgroundStyle::TransparentLight: alpha = 0.5f; break;
			}
			if (Setting_BackgroundFlash) {
				int timeSinceLastMessage = Time::Now - m_lastMessageTime;
				const int FLASH_TIME = 1000;
				if (timeSinceLastMessage < FLASH_TIME) {
					alpha *= 1.0 - timeSinceLastMessage / float(FLASH_TIME);
				} else {
					alpha = 0;
				}
			}
			UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, alpha));
			windowFlags |= UI::WindowFlags::NoInputs;
			m_showInput = false;
		} else {
			UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0.75f));
		}

		if (!UI::IsOverlayShown()) {
			windowFlags |= UI::WindowFlags::NoDecoration;
		}

		bool shouldHideInput = false;

		UI::SetNextWindowPos(
			int(Setting_DefaultPosition.x),
			Draw::GetHeight() - int(Setting_DefaultSize.y - Setting_DefaultPosition.y),
			UI::Cond::FirstUseEver
		);
		UI::SetNextWindowSize(
			int(Setting_DefaultSize.x),
			int(Setting_DefaultSize.y),
			UI::Cond::FirstUseEver
		);
		UI::Begin("Better Chat", windowFlags);

		vec2 windowPos = UI::GetWindowPos();
		vec2 windowSize = UI::GetWindowSize();

		if (UI::IsOverlayShown()) {
			vec2 startingCursorPos = UI::GetCursorPos();

			// Button to reset position and size
			if (UI::Button(Icons::Undo)) {
				UI::SetWindowPos(vec2(
					Setting_DefaultPosition.x,
					Draw::GetHeight() - Setting_DefaultSize.y - Setting_DefaultPosition.y
				));
				UI::SetWindowSize(Setting_DefaultSize);
			}
			UI::SetPreviousTooltip("Reset position & size");

			// Button to clear the chat
			if (UI::RedButton(Icons::Trash)) {
				Clear();
			}
			UI::SetPreviousTooltip("Clear the chat");

			// Button to toggle timestamps
			if (UI::ToggledButton(Setting_ShowTimestamp, Icons::ClockO)) {
				Setting_ShowTimestamp = !Setting_ShowTimestamp;
			}
			UI::SetPreviousTooltip("Toggle timestamps");

			// Button to toggle system message visibility
			if (UI::ToggledButton(m_displaySystem, Icons::Bolt)) { // Icons::Terminal?
				m_displaySystem = !m_displaySystem;
			}
			UI::SetPreviousTooltip("Toggle system messages");

			// Button to toggle only favorites mode
			if (UI::ToggledButton(m_displayOnlyFavorites, Icons::Star)) {
				m_displayOnlyFavorites = !m_displayOnlyFavorites;
			}
			UI::SetPreviousTooltip("Toggle favorite-only mode");

			// Begin second half of the window
			UI::SetCursorPos(startingCursorPos + vec2(40, 0));
			UI::BeginChild("ChatContainer");
		}

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
			auto line = m_lines[i];

			// Hide line if we want to filter out system messages
			if (!m_displaySystem && line.m_isSystem) {
				continue;
			}

			// Hide line if we're in favorites-only mode and this is not a favorite, system, or self message
			if (m_displayOnlyFavorites) {
				if (!line.m_isSystem && !line.m_isSelf && !line.m_isFavorite) {
					continue;
				}
			}

			UI::PushID(line.m_id);
			line.Render();
			UI::PopID();

			float frameHeight = UI::GetFrameHeightWithSpacing();
			if (frameHeight != m_chatLineFrameHeight) {
				m_chatLineFrameHeight = frameHeight;
			}
		}

		// Automatically scroll down if overlay input is not enabled or if the user is at the bottom of the scrolling area
		if (m_scrollToBottom || !UI::IsOverlayInputEnabled() || (UI::GetScrollY() >= UI::GetScrollMaxY())) {
			UI::SetScrollHereY(1.0f);
			m_scrollToBottom = false;
		}
		if (UI::IsOverlayShown()) {
			UI::EndChild();
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
			if (pressedEnter && (m_input != "" || (Time::Now - m_inputShownTime) > 250)) {
				SendChatMessage(m_input);
				shouldHideInput = true;
			}

			UI::PopStyleColor();
			UI::PopItemWidth();
			UI::End();
		}

		UI::PopStyleColor();

		if (shouldHideInput) {
			HideInput();
		}
	}

	//TODO: Remove this entire menu, it doesn't make sense in this class
	void RenderMenu()
	{
		if (UI::BeginMenu("Better Chat Debug")) {
			if (UI::MenuItem("Add a line of nonsense")) {
				auto emoteKeys = Emotes::g_emotes.GetKeys();

				string line = "[$<" + DummyData::PlayerName() + "$>] ";

				string msg = DummyData::Lipsum();
				auto parse = msg.Split(" ");
				for (uint j = 0; j < parse.Length; j++) {
					if (j > 0) {
						line += " ";
					}
					line += parse[j];
					if (Math::Rand(0, 10) == 0) {
						line += " " + emoteKeys[Math::Rand(0, emoteKeys.Length)];
					}
					if (Math::Rand(0, 20) == 0) {
						line += " miss";
					}
					if (Math::Rand(0, 20) == 0) {
						line += " poop";
					}
				}

				AddLine(line);
			}
			UI::EndMenu();
		}
	}
}
