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
// author, so care will need to be taken with this. Below is some very basic code you can take inspiration from:
//
//
// auto parse = Regex::Match(line, "^\\[\\$<([^\\$]+)\\$>\\] (.*)"); //NOTE: This regex only works for basic uplay player names!
// if (parse.Length > 0) {
//   author = parse[1];
//   text = parse[2];
// } else {
//   text = line;
// }
//

array<BetterChat::IChatMessageFilter@> g_chatMessageFilters;
array<BetterChat::IChatMessageListener@> g_chatMessageListeners;

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
			string line = string(network.ChatHistoryLines[i]).Replace("\n", " ");
			uint time = network.ChatHistoryTimestamp[i];

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

				// Let the filter modify the message text
				line = filter.GetMessageText(line);
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
