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
			auto ctlChat = GameInterface::ControlFromID(ctlRoot, "FrameChat");
			if (ctlChat !is null) {
				ctlChat.IsHiddenExternal = !Setting_ShowNadeoChat;
			}
		}
		yield();
	}
}
