
class ChatChannel {
	string m_title;
	BetterChat::IChatChannelSink@ m_sink;

	array<ChatLine@> m_lines;

	uint64 m_lastMessageTime = 0;

	ChatChannel() {}

	ChatChannel(const string&in title, BetterChat::IChatChannelSink@ sink) {
		m_title = title;
		@m_sink = sink;
	}

	void Clear()
	{
		m_lines.RemoveRange(0, m_lines.Length);
	}

	string GetTitle() {
		return m_title;
	}

	void SendChatMessage(const string&in text) {
		if (@m_sink !is null) {
			m_sink.SendChatMessage(text);
		}
	}

	void InsertLine(ChatLine@ line) {
		m_lines.InsertLast(line);

		if (m_lines.Length > uint(Setting_MaximumLines)) {
			m_lines.RemoveRange(0, m_lines.Length - Setting_MaximumLines);
		}

		// Remember when the last message was received
		m_lastMessageTime = Time::Now;
	}
}

class ChatChannelHook: BetterChat::IChatChannelHook {
	ChatChannel@ m_channel;

	ChatChannelHook(ChatChannel@ channel) {
		@m_channel = channel;
	}

	void Clear() override {
		m_channel.Clear();
	}

	void AddChatEntry(BetterChat::ChatEntry entry) override {
		g_window.AddChatLine(ChatLine(g_window.NextLineId(), Time::Stamp, entry), m_channel);
	}
}
