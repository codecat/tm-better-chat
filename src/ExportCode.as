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

	void RegisterFilter(IChatMessageFilter@ filter)
	{
		g_chatMessageFilters.InsertLast(filter);
	}

	void UnregisterFilter(IChatMessageFilter@ filter)
	{
		int index = g_chatMessageFilters.FindByRef(filter);
		if (index != -1) {
			g_chatMessageFilters.RemoveAt(index);
		}
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

	void SendChatMessage(const string &in text)
	{
#if TMNEXT
		if (!Permissions::InGameChat()) {
			return;
		}
#endif

		g_window.SendChatMessage(text);
	}

	IChatChannelHook@ AquireChatChannelHook(const string&in title, IChatChannelSink@ sink) {
		auto channel = ChatChannel(title, sink);
		g_window.AddChannel(channel);
		return ChatChannelHook(channel);
	}

	void ReleaseChatChannelHook(IChatChannelHook@ hook) {
		g_window.RemoveChannel(cast<ChatChannelHook@>(hook).m_channel);
	}
}
