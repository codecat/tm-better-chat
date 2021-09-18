ChatWindow g_window;

void Update(float dt)
{
	g_window.Update(dt);
}

void Render()
{
	g_window.Render();
}

bool OnKeyPress(bool down, VirtualKey key)
{
	return g_window.OnKeyPress(down, key);
}

void Main()
{
	g_window.Initialize();

	Emotes::Load();

	ChatMessageLoop(@g_window);
}
