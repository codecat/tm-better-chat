enum TimeCommandType
{
	Author,
	Gold,
	Silver,
	Bronze,
}

class TimeCommand : ICommand
{
	TimeCommandType m_type;

	TimeCommand(TimeCommandType type)
	{
		m_type = type;
	}

	string Description()
	{
		switch (m_type) {
			case TimeCommandType::Author: return "Tells chat the author time.";
			case TimeCommandType::Gold: return "Tells chat the gold medal time.";
			case TimeCommandType::Silver: return "Tells chat the silver medal time.";
			case TimeCommandType::Bronze: return "Tells chat the bronze medal time.";
		}
		return "";
	}

	void Run(const string &in text)
	{
		auto map = GetApp().RootMap;

		switch (m_type) {
			case TimeCommandType::Author: g_window.SendChatMessage("$<$071" + Icons::Trophy + "$> Author medal: $bbb" + Time::Format(map.TMObjective_AuthorTime)); break;
			case TimeCommandType::Gold:   g_window.SendChatMessage("$<$db4" + Icons::Trophy + "$> Gold medal: $bbb"   + Time::Format(map.TMObjective_GoldTime)); break;
			case TimeCommandType::Silver: g_window.SendChatMessage("$<$899" + Icons::Trophy + "$> Silver medal: $bbb" + Time::Format(map.TMObjective_SilverTime)); break;
			case TimeCommandType::Bronze: g_window.SendChatMessage("$<$964" + Icons::Trophy + "$> Bronze medal: $bbb" + Time::Format(map.TMObjective_BronzeTime)); break;
		}
	}
}
