//
// In case anyone comes across this file trying to implement a hook into chat messages, you can either use this file as a starting
// point (together with the shared interface BetterChat::IChatMessageListener in src/ExportShared.as), or you could add a dependency
// on BetterChat and use its exported functions:
//
//
// class MyListener : BetterChat::IChatMessageListener
// {
//   void OnChatMessage(const string &in line)
//   {
//     print("Chat: \"" + line + "\"");
//   }
// }
//
// MyListener@ g_listener;
//
// void Destroyed()
// {
//   BetterChat::UnregisterListener(g_listener);
// }
//
// void Main()
// {
//   @g_listener = MyListener();
//   BetterChat::RegisterListener(@g_listener);
// }
//
//
// Further parsing will be required in order to separate the author and text of a chat message. Some messages don't have an
// author, so care will need to be taken with this.
//

array<BetterChat::IChatMessageFilter@> g_chatMessageFilters;
array<BetterChat::IChatMessageListener@> g_chatMessageListeners;

NGameScriptChat_SHistory@ g_chatHistory;

NGameScriptChat_SContext@ GetChatContext()
{
	auto chatManager = GetApp().ChatManagerScriptV2;
	return chatManager.Contextes[0];
}

void ChatMessageEnd()
{
	if (g_chatHistory !is null) {
		GetChatContext().History_Destroy(g_chatHistory);
		@g_chatHistory = null;
	}
}

void ChatMessageLoop()
{
	//
	// Filter is reverse Polish notation:
	//   "t"  True
	//   "f"  False
	//   "+"  Or
	//   "*"  And
	//   "!"  Not
	//   "i"  True for "targeted" messages (whispers or team messages)
	//   "l"  True if sender matches login. Ex "lgugli;" means "message sent by Gugli"
	//
	// For example:
	//   "t"                All messages
	//   "f"                No messages
	//   "i * lgugli;"      Targeted messages sent by gugli
	//   "lalice; + lbob;"  Messages sent by alice or bob
	//

	@g_chatHistory = GetChatContext().History_Create("t", 50);

	while (true) {
		for (uint i = 0; i < g_chatHistory.PendingEvents.Length; i++) {
			auto event = g_chatHistory.PendingEvents[i];
			auto newEntryEvent = cast<NGameScriptChat_SEvent_NewEntry>(event);
			if (newEntryEvent !is null) {
				wstring text = newEntryEvent.Entry.Text;
				print(text);
			}
		yield();
	}
}
