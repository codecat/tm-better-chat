namespace BetterChat
{
	// Registers a new chat command with the given name. If the name already exists, it
	// is overridden with the given ICommand@.
	import void RegisterCommand(const string &in name, ICommand@ cmd) from "BetterChat";

	// Adds a system message to the chat window.
	import void AddSystemLine(const string &in text) from "BetterChat";
}
