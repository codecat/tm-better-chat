ChatWindow g_window;

Audio::Sample@ g_sndChat;
Audio::Sample@ g_sndChatMention;
Audio::Sample@ g_sndChatFavorite;
Audio::Sample@ g_sndChatSystem;

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
	@g_sndChat = Resources::GetAudioSample("audio/Chat.wav");
	@g_sndChatMention = Resources::GetAudioSample("audio/ChatMention.wav");
	@g_sndChatFavorite = Resources::GetAudioSample("audio/ChatFavorite.wav");
	@g_sndChatSystem = Resources::GetAudioSample("audio/ChatSystem.wav");

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
