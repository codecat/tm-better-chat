ChatWindow g_window;

void Update(float dt)
{
	g_window.Update(dt);
}

void Render()
{
	g_window.Render();
}

void RenderMenu()
{
	g_window.RenderMenu();
}

bool OnKeyPress(bool down, VirtualKey key)
{
	return g_window.OnKeyPress(down, key);
}

void Main()
{
	g_window.Initialize();

	Emotes::Load();

	startnew(ChatMessageLoop, @g_window);

	while (true) {
		auto ctlRoot = GameInterface::GetRoot();
		if (ctlRoot !is null) {
			auto ctlChat = GameInterface::ControlFromID(ctlRoot, "FrameChat");
			if (ctlChat !is null) {
				ctlChat.IsHiddenExternal = true;
			}
		}
		yield();
	}
}
