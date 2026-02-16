namespace BetterChat
{
	shared interface ICommand
	{
		string Icon();
		string Description();
		void Run(const string &in text);
	}

	shared interface IChatMessageFilter
	{
#if TMNEXT
		bool CanDisplayMessage(NGameScriptChat_SEntry@ entry);
#else
		bool CanDisplayMessage(const string &in line);
#endif
	}

	shared interface IChatMessageListener
	{
#if TMNEXT
		void OnChatMessage(NGameScriptChat_SEntry@ entry);
#else
		void OnChatMessage(const string &in line);
#endif
	}

	shared interface IChatChannelHook
	{
		void AddChatEntry(ChatEntry entry);
		void Clear();
	}

	shared interface IChatChannelSink
	{
		void SendChatMessage(const string&in text);
	}

	shared class ChatEntry {
		string m_text;
		string m_authorName;
		string m_clubTag;
		float m_linearHue;
		bool m_system;
		ChatEntryScope m_scope;

		ChatEntry() {}

		ChatEntry(const string&in text, const string&in authorName, const string&in clubTag = "", float linearHue = 0f, bool system = false, ChatEntryScope scope = BetterChat::ChatEntryScope::Everyone) {
			m_text = text;
			m_authorName = authorName;
			m_clubTag = clubTag;
			m_linearHue = linearHue;
			m_system = system;
			m_scope = scope;
		}
	}

	shared enum ChatEntryScope {
		Everyone,
		SpectatorCurrent,
		SpectatorAll,
		Team,
		YouOnly,
	}
}
