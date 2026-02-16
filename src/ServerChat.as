
class ChatMessageSink: BetterChat::IChatChannelSink {
    void SendChatMessage(const string&in text) override {
#if TMNEXT
		if (!Permissions::InGameChat()) {
			return;
		}
#endif

		auto pg = GetApp().CurrentPlayground;
		if (pg is null) {
			//TODO: Queue the message for later
			warn("Can't send message right now because there's no playground!");
			return;
		}

		if (text.Length > 2000) {
			pg.Interface.ChatEntry = text.SubStr(0, 2000) + " (...)";
		} else {
			pg.Interface.ChatEntry = text;
		}
    }
}

// Useful for debugging purposes
class EchoSink: BetterChat::IChatChannelSink {
    BetterChat::IChatChannelHook@ m_hook;

    void SetHook(BetterChat::IChatChannelHook@ hook) {
        @m_hook = hook;
    }

    void SendChatMessage(const string&in text) override {
        m_hook.AddChatEntry(BetterChat::ChatEntry(text, "", "", 0., true));
    }
}
