namespace BetterChat
{
	void RegisterCommand(const string &in name, ICommand@ cmd)
	{
		Commands::Register(name, cmd);
	}

	void UnregisterCommand(const string &in name)
	{
		Commands::Unregister(name);
	}

	void RegisterListener(IChatMessageListener@ listener)
	{
		g_chatMessageListeners.InsertLast(listener);
	}

	void UnregisterListener(IChatMessageListener@ listener)
	{
		int index = g_chatMessageListeners.FindByRef(listener);
		if (index != -1) {
			g_chatMessageListeners.RemoveAt(index);
		}
	}

	void AddSystemLine(const string &in text)
	{
		g_window.AddSystemLine(text);
	}
}
