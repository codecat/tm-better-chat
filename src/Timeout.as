class Timeout
{
	string m_name;
	uint64 m_endTime;

	Timeout(const string &in name, uint64 duration)
	{
		m_name = name;
		m_endTime = Time::Now + duration;
	}
}

namespace Timeout
{
	array<Timeout@> g_timeouts;

	Timeout@ GetTimeout(const string &in name)
	{
		for (int i = int(g_timeouts.Length) - 1; i >= 0; i--) {
			auto timeout = g_timeouts[i];

			// Remove timeout if it has ended
			if (Time::Now > timeout.m_endTime) {
				g_timeouts.RemoveAt(i);
				continue;
			}

			// Check if the name matches
			if (timeout.m_name == name) {
				return timeout;
			}
		}

		return null;
	}

	bool IsTimedOut(const string &in name)
	{
		return GetTimeout(name) !is null;
	}

	void Add(const string &in name, uint64 duration)
	{
		if (name == "") {
			warn("Can't time-out player without a name!");
			return;
		}

		// If the timeout already exists, extend the duration
		auto timeout = GetTimeout(name);
		if (timeout !is null) {
			timeout.m_endTime = Time::Now + duration;
			return;
		}

		// Add the new timeout
		g_timeouts.InsertLast(Timeout(name, duration));

		// Notify in chat
		g_window.AddSystemLine("Timed out $<" + name + "$> for " + (duration / 1000) + " seconds");
	}
}
