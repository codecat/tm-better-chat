class ChatWindow : IChatMessageReceiver
{
	bool m_visible = true;
	bool m_big = false;

	array<ChatLine@> m_lines;
	uint m_lineIdIterator = 0;

	bool m_displaySystem = true;
	bool m_displayOnlyFavorites = false;

	bool m_overlayInputWasEnabled = false;
	bool m_showInput = false;
	string m_input;
	int m_setInputCursor = -1;

	float m_chatLineFrameHeight = 30.0f;
	string m_previousServer;
	bool m_overlayWasShown = false;

	bool m_scrollToBottom = false;

	uint64 m_lastMessageTime = 0;

	AutoCompletion m_auto;

	void Initialize()
	{
	}

	void Clear()
	{
		m_lines.RemoveRange(0, m_lines.Length);

		if (Setting_ShowHelp) {
			auto plugin = Meta::ExecutingPlugin();
			AddSystemLine("$<$ef7Better Chat " + plugin.Version + "$> - Open the overlay for options");
		}
	}

	void SendChatMessage(const string &in text)
	{
		auto pg = GetApp().CurrentPlayground;
		if (pg is null) {
			//TODO: Queue the message for later
			warn("Can't send message right now because there's no playground!");
			return;
		}
		pg.Interface.ChatEntry = text;
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
		m_setInputCursor = m_input.Length;
	}

	void HideInput()
	{
		if (!m_overlayInputWasEnabled) {
			UI::DisableOverlayInput();
		}
		m_showInput = false;
		m_input = "";
	}

	void LimitLineCount()
	{
		if (m_lines.Length > uint(Setting_MaximumLines)) {
			m_lines.RemoveRange(0, m_lines.Length - Setting_MaximumLines);
		}
	}

	void AddSystemLine(const string &in line)
	{
		string text = "$96f" + Icons::Bolt + " $eee" + line;
		m_lines.InsertLast(ChatLine(m_lineIdIterator++, Time::Stamp, text));
	}

	void AddLine(const string &in line)
	{
		if (line == "") {
			return;
		}

		ChatLine@ newLine = ChatLine(m_lineIdIterator++, Time::Stamp, line);

		// Check if this line should be filtered out
		if (newLine.m_isFiltered) {
			return;
		}

		// Add the line to the list of messages
		m_lines.InsertLast(newLine);
		LimitLineCount();

		// Remember when the last message was received
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
			} else if (key == VirtualKey::C) {
				m_big = !m_big;
			}

			if (m_visible) {
				if (key == VirtualKey::Return || key == VirtualKey::T) {
					ShowInput();
				} else if (key == VirtualKey::Y) {
					ShowInput();
					m_input = "/t ";
				}
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

	void InputCallback(UI::InputTextCallbackData@ data)
	{
		if (data.EventFlag == UI::InputTextFlags::CallbackAlways) {
			m_auto.Update(data);

			if (m_setInputCursor != -1) {
				data.CursorPos = m_setInputCursor;
				m_setInputCursor = -1;
			}

		} else if (data.EventFlag == UI::InputTextFlags::CallbackCharFilter) {
			if (data.EventChar == 58 /* ':' */) {
				m_auto.Begin(AutoCompletionType::Emote);
			} else if (data.EventChar == 64 /* '@' */) {
				m_auto.Begin(AutoCompletionType::Mention);
			}
			m_auto.CharFilter(data);

		} else if (data.EventFlag == UI::InputTextFlags::CallbackCompletion) {
			m_auto.Accept();

		} else if (data.EventFlag == UI::InputTextFlags::CallbackHistory) {
			if (m_auto.IsVisible()) {
				m_auto.Navigate(data);
			} else {
				//TODO: History (pressed up or down arrow)
			}
		}
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

	string GetWindowTitle()
	{
		string ret = "Better Chat";
		if (m_big) {
			ret += "##Big";
		}
		return ret;
	}

	int GetWindowFlags()
	{
		int ret = UI::WindowFlags::NoTitleBar;

		if (m_big) {
			ret |= UI::WindowFlags::NoResize;
			ret |= UI::WindowFlags::NoSavedSettings;
		}

		if (!UI::IsOverlayInputEnabled()) {
			ret |= UI::WindowFlags::NoInputs;
		}

		if (!UI::IsOverlayShown()) {
			ret |= UI::WindowFlags::NoDecoration;
		}

		return ret;
	}

	vec4 GetWindowBackground()
	{
		if (!UI::IsOverlayInputEnabled() && !m_big) {
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

			return vec4(0, 0, 0, alpha);
		}

		return vec4(0, 0, 0, 0.75f);
	}

	void RenderLines()
	{
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
	}

	void RenderSidebar()
	{
		if (m_big) {
			// Button to get out of big mode
			if (UI::Button(Icons::Backward)) {
				m_big = false;
			}
			UI::SetPreviousTooltip("Get out of big chat");
		} else {
			// Button to reset position and size
			if (UI::Button(Icons::Undo)) {
				UI::SetWindowPos(vec2(
					Setting_DefaultPosition.x,
					Draw::GetHeight() - Setting_DefaultSize.y - Setting_DefaultPosition.y
				));
				UI::SetWindowSize(Setting_DefaultSize);
			}
			UI::SetPreviousTooltip("Reset position & size");
		}

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
	}

	void SetNextWindowLocation()
	{
		if (m_big) {
			float screenWidth = Draw::GetWidth();
			float screenHeight = Draw::GetHeight();

			float chatWidth = screenWidth / 2.0f;
			float chatHeight = screenHeight / 2.0f;

			UI::SetNextWindowPos(
				int(screenWidth / 2.0f - chatWidth / 2.0f),
				int(screenHeight / 2.0f - chatHeight / 2.0f),
				UI::Cond::Always
			);
			UI::SetNextWindowSize(
				int(chatWidth),
				int(chatHeight),
				UI::Cond::Always
			);

		} else {
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

		string windowTitle = GetWindowTitle();
		int windowFlags = GetWindowFlags();

		UI::PushStyleColor(UI::Col::WindowBg, GetWindowBackground());

		SetNextWindowLocation();

		UI::Begin(windowTitle, windowFlags);

		vec2 windowPos = UI::GetWindowPos();
		vec2 windowSize = UI::GetWindowSize();

		if (UI::IsOverlayShown()) {
			vec2 startingCursorPos = UI::GetCursorPos();

			RenderSidebar();

			// Begin second half of the window
			UI::SetCursorPos(startingCursorPos + vec2(40, 0));
			UI::BeginChild("ChatContainer");
		}

		RenderLines();

		// Automatically scroll down if overlay input is not enabled or if the user is at the bottom of the scrolling area
		if (m_scrollToBottom || !UI::IsOverlayInputEnabled() || (UI::GetScrollY() >= UI::GetScrollMaxY())) {
			UI::SetScrollHereY(1.0f);
			m_scrollToBottom = false;
		}

		if (UI::IsOverlayShown()) {
			UI::EndChild();
		}
		UI::End();

		// Hide the input box if the overlay is disabled
		if (!UI::IsOverlayInputEnabled()) {
			m_showInput = false;
		}

		// Whether we have to hide the input at the end of the frame
		// This is required at end of frame because... I forgot why
		//TODO: Check if this is still needed and if so, why
		bool shouldHideInput = false;

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

			m_input = UI::InputText("", m_input, pressedEnter,
				UI::InputTextFlags::EnterReturnsTrue |
				UI::InputTextFlags::CallbackAlways |
				UI::InputTextFlags::CallbackCharFilter |
				UI::InputTextFlags::CallbackCompletion |
				UI::InputTextFlags::CallbackHistory,
				UI::InputTextCallback(InputCallback)
			);

			if (pressedEnter) {
				if (m_auto.IsVisible()) {
					m_auto.Accept();
				} else {
					SendChatMessage(m_input);
					shouldHideInput = true;
				}
			}

			UI::PopStyleColor();
			UI::PopItemWidth();
			UI::End();
		}

		UI::PopStyleColor();

		if (m_showInput && !shouldHideInput) {
			m_auto.Render(windowPos, windowSize);
		}

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
