namespace BetterChat
{
	shared interface ICommand
	{
		string Icon();
		string Description();
		void Run(const string &in text);
	}

	shared interface IChatMessageListener
	{
		void OnChatMessage(const string &in line);
	}
}
