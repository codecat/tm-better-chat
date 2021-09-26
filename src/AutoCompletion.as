enum AutoCompletionType
{
	None,
	Emote,
	Mention,
}

interface IAutoCompletionItem
{
	bool Matches(const string &in text);
	string AcceptText();
	void Render(UI::DrawList@ dl, const vec2 &in pos);
}

class AutoCompletion
{
	AutoCompletionType m_type;
	int m_startIndex = -1;
	int m_cursorIndex = -1;

	array<IAutoCompletionItem@> m_items;
	array<IAutoCompletionItem@> m_itemsFiltered;
	bool m_visible = false;

	int m_selectedIndex = 0;
	bool m_accepted = false;
	string m_acceptedText;

	bool IsVisible()
	{
		return m_visible && m_itemsFiltered.Length > 0;
	}

	void Render(const vec2 &in chatPos, const vec2 &in chatSize)
	{
		if (!m_visible) {
			return;
		}

		// Don't show anything if there are no items
		if (m_itemsFiltered.Length == 0) {
			return;
		}

		const float WINDOW_WIDTH = 200;
		const float WINDOW_SPACING = 4;
		const float WINDOW_PADDING = 4;
		const float WINDOW_ROUNDING = 4;
		const float WINDOW_ALPHA = 0.9f;
		const float ITEM_HEIGHT = 32;
		const float ITEM_ROUNDING = 4;

		vec2 windowPos = chatPos + vec2(
			chatSize.x / 2.0f - WINDOW_WIDTH / 2.0f,
			WINDOW_SPACING
		);
		vec2 windowSize = vec2(
			WINDOW_WIDTH,
			chatSize.y - WINDOW_SPACING * 2
		);

		vec4 windowRect = vec4(
			windowPos.x - WINDOW_PADDING,
			windowPos.y - WINDOW_PADDING,
			windowSize.x + WINDOW_PADDING * 2,
			windowSize.y + WINDOW_PADDING * 2
		);

		// Reset selected index if it's outside of the visible range
		if ((m_selectedIndex + 1) * ITEM_HEIGHT > windowSize.y) {
			m_selectedIndex = 0;
		}

		auto dl = UI::GetForegroundDrawList();
		dl.AddRectFilled(windowRect, vec4(0, 0, 0, WINDOW_ALPHA), WINDOW_ROUNDING);
		dl.PushClipRect(windowRect);

		vec2 pos = windowPos + vec2(0, windowSize.y - ITEM_HEIGHT);
		for (uint i = 0; i < m_itemsFiltered.Length; i++) {
			if (int(i) == m_selectedIndex) {
				dl.AddRectFilled(vec4(pos.x, pos.y, WINDOW_WIDTH, 32), vec4(0.4f, 0, 0.5f, 1), ITEM_ROUNDING);
			}

			m_itemsFiltered[i].Render(dl, pos + vec2(2, 2));
			pos.y -= ITEM_HEIGHT;

			if (pos.y < windowPos.y) {
				break;
			}
		}

		dl.PopClipRect();
	}

	void Begin(AutoCompletionType type)
	{
		m_type = type;
		m_startIndex = m_cursorIndex;
		m_visible = false;

		m_items.RemoveRange(0, m_items.Length);

		switch (m_type) {
			case AutoCompletionType::Emote: {
				auto keys = Emotes::g_emotes.GetKeys();
				for (uint i = 0; i < keys.Length; i++) {
					string name = keys[i];
					auto emote = Emotes::Find(name);
					m_items.InsertLast(AutoCompletionItemEmote(name, emote));
				}
			} break;

			case AutoCompletionType::Mention: {
				auto network = GetApp().Network;
				for (uint i = 0; i < network.PlayerInfos.Length; i++) {
					auto playerInfo = cast<CGamePlayerInfo>(network.PlayerInfos[i]);
					m_items.InsertLast(AutoCompletionItemMention(playerInfo.Name));
				}
			} break;
		}
	}

	void Update(UI::InputTextCallbackData@ data)
	{
		if (m_accepted) {
			m_accepted = false;
			data.DeleteChars(m_startIndex, data.CursorPos - m_startIndex);
			data.InsertChars(m_startIndex, m_acceptedText + " ");
			data.CursorPos = m_startIndex + m_acceptedText.Length + 1;
		}

		if (data.CursorPos != m_cursorIndex) {
			m_cursorIndex = data.CursorPos;

			if (m_type != AutoCompletionType::None) {
				int delta = data.CursorPos - m_startIndex;
				if (delta <= 0) {
					Cancel();
					return;

				} else if (delta >= 3) {
					m_visible = true;
				}

				if (m_visible) {
					Filter(data.Text.SubStr(m_startIndex + 1, delta - 1).ToLower());
				}
			}
		}
	}

	void CharFilter(UI::InputTextCallbackData@ data)
	{
		if (m_type != AutoCompletionType::None) {
			// Cancel if we typed something non-alphanumeric
			if (
				data.EventChar != 58 /* ':' */ &&
				(data.EventChar < 48 /* '0' */ || data.EventChar > 57 /* '9' */) &&
				(data.EventChar < 65 /* 'A' */ || data.EventChar > 90 /* 'Z' */) &&
				(data.EventChar < 97 /* 'a' */ || data.EventChar > 122 /* 'z' */)
			) {
				Cancel();
			}
		}
	}

	void Navigate(UI::InputTextCallbackData@ data)
	{
		if (!m_visible) {
			return;
		}

		if (data.EventKey == UI::Key::UpArrow) {
			if (++m_selectedIndex >= int(m_itemsFiltered.Length)) {
				m_selectedIndex = 0;
			}
		} else if (data.EventKey == UI::Key::DownArrow) {
			if (--m_selectedIndex < 0) {
				m_selectedIndex = int(m_itemsFiltered.Length) - 1;
			}
		}
	}

	void Filter(string text)
	{
		text = text.ToLower();

		m_itemsFiltered.RemoveRange(0, m_itemsFiltered.Length);
		for (uint i = 0; i < m_items.Length; i++) {
			auto item = m_items[i];
			if (item.Matches(text)) {
				m_itemsFiltered.InsertLast(item);
			}
		}

		m_selectedIndex = 0;
	}

	void Cancel()
	{
		m_type = AutoCompletionType::None;
		m_visible = false;
	}

	void Accept()
	{
		if (m_selectedIndex < 0 || m_selectedIndex >= int(m_itemsFiltered.Length)) {
			// Shouldn't happen, but let's warn about it
			warn("Autocompletion selected index out of range: " + m_itemsFiltered.Length + " items, index " + m_selectedIndex);
			Cancel();
			return;
		}

		auto selectedItem = m_itemsFiltered[m_selectedIndex];

		m_accepted = true;
		m_acceptedText = selectedItem.AcceptText();

		m_type = AutoCompletionType::None;
		m_visible = false;
	}
}
