//
// In case anyone comes across this file trying to implement a hook into chat messages, you can either use this file as a starting
// point (together with the shared interface BetterChat::IChatMessageListener in src/ExportShared.as), or you could add a dependency
// on BetterChat and use its exported functions:
//
//
// class MyListener : BetterChat::IChatMessageListener
// {
//   void OnChatMessage(NGameScriptChat_SEntry@ entry)
//   {
//     print("Chat: \"" + entry.Text + "\"");
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
// Note: Do not keep the NGameScriptChat_SEntry handle around! Consider the handle invalid as soon as when your callback returns.
//

array<BetterChat::IChatMessageFilter@> g_chatMessageFilters;
array<BetterChat::IChatMessageListener@> g_chatMessageListeners;

#if TMNEXT
NGameScriptChat_SHistory@ g_chatHistory;

NGameScriptChat_SContext@ GetChatContext()
{
	auto chatManager = GetApp().ChatManagerScriptV2;
	return chatManager.Contextes[0];
}
#endif

void ChatMessageEnd()
{
#if TMNEXT
	if (g_chatHistory !is null) {
		GetChatContext().History_Destroy(g_chatHistory);
		@g_chatHistory = null;
	}
#endif
}

#if TMNEXT

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

			// Check if the event is a new entry event
			auto newEntryEvent = cast<NGameScriptChat_SEvent_NewEntry>(event);
			if (newEntryEvent is null) {
				continue;
			}

			auto entry = newEntryEvent.Entry;

			// Go through the chat filters
			bool canDisplay = true;
			for (uint j = 0; j < g_chatMessageFilters.Length; j++) {
				auto filter = g_chatMessageFilters[j];

				// Stop if we can't display the message
				if (!filter.CanDisplayMessage(entry)) {
					canDisplay = false;
					break;
				}
			}

			// Stop if a filter told us we can't deliver this message
			if (!canDisplay) {
				continue;
			}

			// Fire off the chat message event
			for (uint j = 0; j < g_chatMessageListeners.Length; j++) {
				auto listener = g_chatMessageListeners[j];
				listener.OnChatMessage(entry);
			}
		}
		yield();
	}
}

#else

void ChatMessageLoop()
{
	auto network = GetApp().Network;

	uint lastTime = 0;
	if (network.ChatHistoryTimestamp.Length > 0) {
		lastTime = network.ChatHistoryTimestamp[0];
	}

	while (true) {
		uint highestTime = 0;

		for (uint i = 0; i < network.ChatHistoryTimestamp.Length; i++) {
			string line = string(network.ChatHistoryLines[i]);
			uint time = network.ChatHistoryTimestamp[i];

			if (Setting_ReplaceNewlines) {
				line = line.Replace("\n", " ");
			}

			// Sometimes, the most recent message is empty in the history lines for 1 frame, so we ignore any empty lines.
			// If we do that before we handle timestamps, we can resume on messages that get their line filled in on the next frame.
			if (line == "") {
				continue;
			}

			// Stop if we've reached the time since the last poll
			if (time <= lastTime) {
				break;
			}

			// Remember the highest timestamp
			if (time > highestTime) {
				highestTime = time;
			}

			// Go through the chat filters
			bool canDisplay = true;
			for (uint j = 0; j < g_chatMessageFilters.Length; j++) {
				auto filter = g_chatMessageFilters[j];

				// Stop if we can't display the message
				if (!filter.CanDisplayMessage(line)) {
					canDisplay = false;
					break;
				}
			}

			// Stop if a filter told us we can't deliver this message
			if (!canDisplay) {
				continue;
			}

			// Fire off the chat message event
			for (uint j = 0; j < g_chatMessageListeners.Length; j++) {
				auto listener = g_chatMessageListeners[j];
				listener.OnChatMessage(line);
			}
		}

		if (highestTime > 0) {
			lastTime = highestTime;
		}

		yield();
	}
}

#endif
