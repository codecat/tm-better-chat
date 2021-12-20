namespace BetterChat
{
	// Registers a new chat command with the given name. If the name already exists, it
	// is overridden with the given ICommand@.
	import void RegisterCommand(const string &in name, ICommand@ cmd) from "BetterChat";

	// Unregisters a previously registered command with the given name. Consider calling
	// this if you've registered a command and your plugin is about to unload!
	import void UnregisterCommand(const string &in name) from "BetterChat";



	// Registers a new chat filter that you can use to remove or edit messages.
	import void RegisterFilter(IChatMessageFilter@ filter) from "BetterChat";

	// Unregisters a chat filter. Call this if you've registered a filter and your
	// plugin is about to unload!
	import void UnregisterFilter(IChatMessageFilter@ filter) from "BetterChat";



	// Registers a new chat listener that will call on any received message.
	import void RegisterListener(IChatMessageListener@ listener) from "BetterChat";

	// Unregisters a chat listener. Call this if you've registered a listener and your
	// plugin is about to unload!
	import void UnregisterListener(IChatMessageListener@ listener) from "BetterChat";



	// Adds a system message to the chat window.
	import void AddSystemLine(const string &in text) from "BetterChat";

	// Sends a message to the server.
	import void SendChatMessage(const string &in text) from "BetterChat";
}
