ChatWindow g_window;

void Update(float dt)
{
	g_window.Update(dt);
}

void Render()
{
	g_window.Render();
	Renderables::Render();
}

bool OnKeyPress(bool down, VirtualKey key)
{
	return g_window.OnKeyPress(down, key);
}

void OnDisabled()
{
	ShowNadeoChat(true);
}

void OnDestroyed()
{
	ShowNadeoChat(true);
}

void OnSettingsChanged()
{
	Sounds::CheckIfSoundSetChanged();
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
	Sounds::Load();
	Emotes::Load();
	Commands::Load();

	g_window.Initialize();

	startnew(ChatMessageLoop, @g_window);

	while (true) {
#if DEVELOPER
		bool showNadeoChat = Setting_ShowNadeoChat;
#else
		bool showNadeoChat = false;
#endif

		ShowNadeoChat(showNadeoChat);
		yield();
	}
}
