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

void RenderMenu()
{
	g_window.RenderMenu();
}

bool OnKeyPress(bool down, VirtualKey key)
{
	return g_window.OnKeyPress(down, key);
}

void OnSettingsChanged()
{
	Sounds::CheckIfSoundSetChanged();
}

void Main()
{
	Sounds::Load();
	Emotes::Load();
	Commands::Load();

	g_window.Initialize();

	startnew(ChatMessageLoop, @g_window);

	while (true) {
		auto ctlRoot = GameInterface::GetRoot();
		if (ctlRoot !is null) {
			auto ctlChat = cast<CControlContainer>(GameInterface::ControlFromID(ctlRoot, "FrameChat"));
			if (ctlChat !is null) {
#if MP41
				// On MP4, we can't simply hide FrameChat by setting IsHiddenExternal
				// Instead, we use a trick with IsClippingContainer and BoxMin
				ctlChat.IsClippingContainer = !Setting_ShowNadeoChat;
				ctlChat.BoxMin = vec2();

				auto ctlChatInput = GameInterface::ControlFromID(ctlChat, "OverlayChatInput");
				if (ctlChatInput !is null) {
					ctlChatInput.IsHiddenExternal = !Setting_ShowNadeoChat;
				}
#else
				ctlChat.IsHiddenExternal = !Setting_ShowNadeoChat;
#endif
			}
		}
		yield();
	}
}
