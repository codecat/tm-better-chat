ChatWindow g_window;

Resources::Font@ g_fontHeader;
Resources::Font@ g_fontChat;
Resources::Font@ g_fontObviousChat;

void Update(float dt)
{
	g_window.Update(dt);
}

void Render()
{
	g_window.Render();
	Renderables::Render();
}

UI::InputBlocking OnKeyPress(bool down, VirtualKey key)
{
	return g_window.OnKeyPress(down, key);
}

void OnDisabled()
{
	g_window.SendChatFormat("text");
	ShowNadeoChat(true);
}

void OnDestroyed()
{
	g_window.SendChatFormat("text");
	ShowNadeoChat(true);
}

void OnSettingsChanged()
{
	Sounds::CheckIfSoundSetChanged();
}

void SendChatMessage(const string &in text)
{
#if TMNEXT
	if (!Permissions::InGameChat()) {
		return;
	}
#endif

	auto pg = GetApp().CurrentPlayground;
	if (pg is null) {
		//TODO: Queue the message for later
		warn("Can't send message right now because there's no playground!");
		return;
	}
	pg.Interface.ChatEntry = text;
}

void ShowNadeoChat(bool visible)
{
	auto ctlRoot = GameInterface::GetRoot();
	if (ctlRoot !is null) {
		auto ctlChat = cast<CControlContainer>(GameInterface::ControlFromID(ctlRoot, "FrameChat"));
		if (ctlChat !is null) {
#if MP41 || TURBO
			// On MP4, we can't simply hide FrameChat by setting IsHiddenExternal
			// Instead, we use a trick with IsClippingContainer and BoxMin
			ctlChat.IsClippingContainer = !visible;
			ctlChat.BoxMin = vec2();

			auto ctlChatInput = GameInterface::ControlFromID(ctlChat, "OverlayChatInput");
			if (ctlChatInput !is null) {
				ctlChatInput.IsHiddenExternal = !visible;
			}
#else
			ctlChat.IsHiddenExternal = !visible;
#endif
		}
	}
}

void Main()
{
#if TMNEXT && DEPENDENCY_NADEOSERVICES
	try {
		NadeoServices::AddAudience("NadeoLiveServices");
	} catch {
		UI::ShowNotification("Update Openplanet", "You have to update Openplanet to at least 1.21.1 for Better Chat to work properly.", vec4(0.7f, 0, 0, 1), 30000);
		return;
	}
#endif

	Sounds::Load();
	Emotes::Load();
	Commands::Load();

	@g_fontHeader = Resources::GetFont("DroidSans-Bold.ttf", 22);
	@g_fontObviousChat = @g_fontHeader;

	if (Setting_FontName != "DroidSans.ttf" || Setting_FontSize != 16) {
		@g_fontChat = Resources::GetFont(Setting_FontName, Setting_FontSize, -1, -1, true, true, true);
	}

	g_window.Initialize();

	BetterChat::RegisterListener(g_window);
	startnew(ChatMessageLoop);

	if (!Setting_WizardShown) {
		Renderables::Add(WizardModalDialog());
	}

	while (true) {
#if DEVELOPER
		ShowNadeoChat(Setting_ShowNadeoChat);
#else
		ShowNadeoChat(false);
#endif

		if (g_window.m_requestedChatFormat != "json") {
			g_window.SendChatFormat("json");
		}

		if (Setting_FontUpdated) {
			Setting_FontUpdated = false;
			@g_fontChat = Resources::GetFont(Setting_FontName, Setting_FontSize, -1, -1, true, true, true);
		}

		auto inputport = GetApp().InputPort;
		for (uint i = 0; i < inputport.Script_Pads.Length; i++) {
			auto pad = inputport.Script_Pads[i];

			if (
				pad.Type == CInputScriptPad::EPadType::Keyboard
#if !TURBO
				|| pad.Type == CInputScriptPad::EPadType::Mouse
#endif
				) {
				continue;
			}

			for (uint j = 0; j < pad.ButtonEvents.Length; j++) {
				auto pressedButton = pad.ButtonEvents[j];
				g_window.OnGamepadButton(pressedButton);
			}
		}

		yield();
	}
}
