namespace BetterChat
{
	shared interface ICommand
	{
		string Icon();
		string Description();
		void Run(const string &in text);
	}
}
