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
	bool m_send;

	TimeCommand(TimeCommandType type, bool send)
	{
		m_type = type;
		m_send = send;
	}

	string Description()
	{
		if (m_send) {
			switch (m_type) {
				case TimeCommandType::Author: return "Tells chat the author time.";
				case TimeCommandType::Gold: return "Tells chat the gold medal time.";
				case TimeCommandType::Silver: return "Tells chat the silver medal time.";
				case TimeCommandType::Bronze: return "Tells chat the bronze medal time.";
			}
		} else {
			switch (m_type) {
				case TimeCommandType::Author: return "Prints the author time.";
				case TimeCommandType::Gold: return "Prints the gold medal time.";
				case TimeCommandType::Silver: return "Prints the silver medal time.";
				case TimeCommandType::Bronze: return "Prints the bronze medal time.";
			}
		}
		return "";
	}

	void Run(const string &in text)
	{
		auto map = GetApp().RootMap;
		if (map is null) {
			return;
		}

		string msg;

		switch (m_type) {
			case TimeCommandType::Author: msg = "$<$071" + Icons::Trophy + "$> Author medal: $bbb" + Time::Format(map.TMObjective_AuthorTime); break;
			case TimeCommandType::Gold:   msg = "$<$db4" + Icons::Trophy + "$> Gold medal: $bbb"   + Time::Format(map.TMObjective_GoldTime); break;
			case TimeCommandType::Silver: msg = "$<$899" + Icons::Trophy + "$> Silver medal: $bbb" + Time::Format(map.TMObjective_SilverTime); break;
			case TimeCommandType::Bronze: msg = "$<$964" + Icons::Trophy + "$> Bronze medal: $bbb" + Time::Format(map.TMObjective_BronzeTime); break;
		}

		if (m_send) {
			g_window.SendChatMessage(msg);
		} else {
			g_window.AddSystemLine(msg);
		}
	}
}
