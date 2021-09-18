//
// In case anyone comes across this file trying to implement a hook into chat messages, this file is the only file you need!
// Here's a quick example of how to use this code.
//
//
// class MyReceiver : IChatMessageReceiver
// {
//   void OnChatMessage(const string &in line)
//   {
//     print("Chat: \"" + line + "\"");
//   }
// }
//
// MyReceiver g_receiver;
//
// void Main()
// {
//   ChatMessageLoop(@g_receiver);
// }
//
//
// You can also start ChatMessageLoop via startnew (in case you want to start a new coroutine instead of using Main). For example,
// it's possible to start the loop from a UI context like this:
//
//
// void RenderInterface()
// {
//   if (UI::Begin("My window")) {
//     if (UI::Button("Begin message loop")) {
//       startnew(ChatMessageLoop, g_receiver);
//     }
//   }
//   UI::End();
// }
//
//
// Multiple loops can be running at the same time, but don't go too crazy with this. Prefer to use only 1 loop to save on CPU.
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

interface IChatMessageReceiver
{
	void OnChatMessage(const string &in line);
}

void ChatMessageLoop(ref@ receiverUserdata)
{
	auto receiver = cast<IChatMessageReceiver>(receiverUserdata);

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

			// Fire off the chat message event
			receiver.OnChatMessage(line);
		}

		if (highestTime > 0) {
			lastTime = highestTime;
		}

		yield();
	}
}
