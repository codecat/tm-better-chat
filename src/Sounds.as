namespace Sounds
{
	enum SoundSet
	{
		None,
		Alpha,
		Pops,
	}

	SoundSet g_currentSet = SoundSet::None;

	Audio::Sample@ g_sndChat;
	Audio::Sample@ g_sndChatMention;
	Audio::Sample@ g_sndChatFavorite;
	Audio::Sample@ g_sndChatSystem;

	void Load()
	{
		g_currentSet = Setting_SoundSet;

		@g_sndChat = null;
		@g_sndChatMention = null;
		@g_sndChatFavorite = null;
		@g_sndChatSystem = null;

		string folder;
		switch (Setting_SoundSet) {
			case SoundSet::Alpha: folder = "alpha"; break;
			case SoundSet::Pops: folder = "pops"; break;
		}

		if (folder == "") {
			return;
		}

		@g_sndChat = Resources::GetAudioSample("audio/" + folder + "/Chat.wav");
		@g_sndChatMention = Resources::GetAudioSample("audio/" + folder + "/ChatMention.wav");
		@g_sndChatFavorite = Resources::GetAudioSample("audio/" + folder + "/ChatFavorite.wav");
		@g_sndChatSystem = Resources::GetAudioSample("audio/" + folder + "/ChatSystem.wav");
	}

	void CheckIfSoundSetChanged()
	{
		if (g_currentSet != Setting_SoundSet) {
			trace("Soundset changed, load sounds");
			Load();
		}
	}
}
