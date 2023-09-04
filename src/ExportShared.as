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
}
