enum Highlight
{
	None,
	System,
	Self,
	Mention,
	Favorite,
}

class ChatLine
{
	uint m_id;

	int64 m_time;
	array<Element@> m_elements;

	Highlight m_highlight = Highlight::None;

	bool m_isSystem = false;
	bool m_isSelf = false;
	bool m_isMention = false;
	bool m_isFavorite = false;
	bool m_isFiltered = false;
	bool m_isJson = false;

	ChatLine(uint id, int64 time, const string &in line)
	{
		m_id = id;
		m_time = time;
		ParseLine(line);
	}

	vec4 GetHighlightColor(const vec4 &in def = vec4(0, 0, 0, 1))
	{
		vec3 ret(def.x, def.y, def.z);
		switch (m_highlight) {
			case Highlight::System: ret = Setting_ColorSystem; break;
			case Highlight::Self: ret = Setting_ColorSelf; break;
			case Highlight::Mention: ret = Setting_ColorMention; break;
			case Highlight::Favorite: ret = Setting_ColorFavorite; break;
		}
		return vec4(ret.x, ret.y, ret.z, 1);
	}

	void SetHighlight(Highlight highlight)
	{
		if (m_highlight != Highlight::None) {
			return;
		}
		m_highlight = highlight;
	}

	void ParseLine(const string &in line)
	{
		// Trace the message to the log if needed by settings (and not in streamer mode)
		if (Setting_TraceToLog && !Setting_StreamerMode) {
			trace(line);
		}

		ChatLineInfo info(line);

		// Check if this user is timed out
		if (!m_isFiltered && Timeout::IsTimedOut(info.m_authorName)) {
			m_isFiltered = true;
		}

		// Check if this user is blocked
		if (!m_isFiltered && CsvContainsValue(Setting_Blocked, info.m_authorName)) {
			m_isFiltered = true;
		}

		// Check if the message should be blocked by streamer mode
		if (!m_isFiltered && Setting_StreamerMode && (info.m_authorName != "" || Setting_StreamerCensorSystem)) {
			string censored = StreamerMode::Censor(info.m_text);
			if (censored == "") {
				m_isFiltered = true;
			}

			if (censored != info.m_text) {
				info.m_text = censored;
				if (Setting_StreamerAutoTimeout) {
					Timeout::Add(info.m_authorName, 5 * 60 * 1000);
				}
			}
		}

		// Check if the message matches the filter regex
		if (!m_isFiltered) {
			try {
				if (Setting_FilterRegex != "" && Regex::Contains(info.m_text, Setting_FilterRegex, Regex::Flags::ECMAScript | Regex::Flags::CaseInsensitive)) {
					m_isFiltered = true;
				}
			} catch {
				warn("There's a problem with the filter regex!");
			}
		}

		// Get some more information about the player
		auto network = cast<CTrackManiaNetwork>(GetApp().Network);

		bool coloredTags = (info.m_teamNumber > 0);

		// System message
		if (info.m_authorName == "") {
			m_isSystem = true;
			SetHighlight(Highlight::System);
		}

		// Highlight if this is the local player
		if (info.m_isLocalPlayer) {
			m_isSelf = true;
			SetHighlight(Highlight::Self);
		}

		// Highlight if the player's exact name is mentioned
		string localPlayerName = network.PlayerInfo.Name;
		if (info.m_text.ToLower().Contains(localPlayerName.ToLower())) {
			m_isMention = true;
			SetHighlight(Highlight::Mention);
		}

		// Highlight if any extra names are mentioned
		if (CsvInText(Setting_ExtraMentions, info.m_text)) {
			m_isMention = true;
			SetHighlight(Highlight::Mention);
		}

		// Highlight if this is a favorite user
		if (CsvContainsValue(Setting_Favorites, info.m_authorName)) {
			m_isFavorite = true;
			SetHighlight(Highlight::Favorite);
		}

		// Add timestamp element
		AddColorableElement(ElementTimestamp(Time::Stamp), coloredTags, info.m_linearHue);

		// If this is a team chat message, add secret tag here
		if (info.m_teamChat) {
			AddElement(ElementTag(Icons::UserSecret));
		}

		// Add club tag
		if (info.m_authorClubTag != "") {
			AddColorableElement(
				ElementClubTag(
					info.m_authorClubTag
				),
				coloredTags,
				info.m_linearHue
			);
		}

		if (info.m_authorName != "") {
			// Add author name
			AddColorableElement(
				ElementPlayerName(
					info.m_authorName,
					info.m_authorNickname,
					info.m_authorLogin,
					info.m_authorId,
					info.m_authorClubTag
				),
				coloredTags,
				info.m_linearHue
			);
		}

		ParseMessageText(info.m_text);
	}

	void ParseMessageText(const string &in text)
	{
		AddElement(ElementFormatGroup(true));

		if (Setting_EnableEmotes) {
			// Separate text and emote elements if emotes are enabled
			string buffer;

			auto parseText = text.Split(" ");
			for (uint i = 0; i < parseText.Length; i++) {
				string word = parseText[i];

				string emoteKey = word;
				bool emoteCaseSensitive = true;

				// If there are colons on the emote key, strip them, and search emotes case-insensitively
				if (emoteKey.Length > 2 && emoteKey.StartsWith(":") && emoteKey.EndsWith(":")) {
					emoteKey = emoteKey.SubStr(1, emoteKey.Length - 2);
					emoteCaseSensitive = false;
				}

				auto emote = Emotes::Find(emoteKey, emoteCaseSensitive);
				if (emote !is null) {
					if (buffer != "") {
						AddText(buffer + " ");
						buffer = "";
					}
					AddElement(ElementEmote(emote));
					continue;
				}

				if (i > 0) {
					buffer += " ";
				}
				buffer += word;
			}

			if (buffer != "") {
				AddText(buffer);
			}
		} else {
			// Just add text when emotes are disabled
			AddText(text);
		}

		AddElement(ElementFormatGroup(false));
	}

	//TODO: This can be refactored probably
	void AddColorableElement(ElementTag@ element, bool colored, float hue)
	{
		@element.m_line = this;
		if (colored) {
			element.SetHue(hue);
		}
		m_elements.InsertLast(element);
		element.OnAdded();
	}

	void AddElement(Element@ element)
	{
		@element.m_line = this;
		m_elements.InsertLast(element);
		element.OnAdded();
	}

	void AddText(const string &in text)
	{
		// $lhttps://openplanet.dev/ yes$l ytes
		//   ^^^^^^^^^^^^^^^^^^^^^^^^^^^
		// $l[https://openplanet.dev/]yes
		//                            ^^^
		// $l[https://openplanet.dev/]yes$>yes
		//                            ^^^
		// $l[https://openplanet.dev/]yes$lyes
		//                            ^^^
		// $l[https://openplanet.dev/]yes$zyes
		//                            ^^^
		int index = text.IndexOfI("$l");
		if (index == -1) {
			AddElement(ElementText(text));
			return;
		}

		int pos = 0;
		while (index != -1) {
			// Add text before the link
			if (index > pos) {
				AddElement(ElementText(text.SubStr(pos, index - pos)));
			}

			// Parse link start
			string textWithLink = text.SubStr(index);
			auto parse = Regex::Search(textWithLink, "^\\$[lL](\\[[^\\]]+\\])?(.*?)(\\$[lLzZ>]|$)");
			if (parse.Length == 0) {
				// Invalid link?
				warn("Invalid link in text: \"" + text + "\"");
				break;
			}

			string url = parse[1];
			string linkText = parse[2];
			if (url == "") {
				url = linkText;
			} else {
				url = url.SubStr(1, url.Length - 2);
			}
			AddElement(ElementLink(linkText, url));

			pos = index + parse[0].Length;

			int newIndex = text.SubStr(pos).IndexOfI("$l");
			if (newIndex == -1) {
				break;
			}
			index = pos + newIndex;
		}

		if (pos < text.Length) {
			AddElement(ElementText(text.SubStr(pos)));
		}
	}

	void Render()
	{
		float scale = UI::GetScale();
		vec2 rectPos = UI::GetCursorPos();

		UI::SetCursorPos(rectPos + vec2(8, 0) * scale);

		UI::AlignTextToFramePadding();

		for (uint i = 0; i < m_elements.Length; i++) {
			auto element = m_elements[i];
			if (!element.IsVisible()) {
				continue;
			}

			element.Render();

			if (i < m_elements.Length - 1) {
				element.Advance();
			}
		}

		UI::SameLine();
		vec2 endPos = UI::GetCursorPos();
		UI::NewLine();
		vec2 newLinePos = UI::GetCursorPos();

		vec2 itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing);

		vec2 rectSize = vec2(
			endPos.x - rectPos.x,
			newLinePos.y - rectPos.y - (itemSpacing.y + 2) * scale
		);

		if (endPos.y > rectPos.y) {
			rectSize.x = UI::GetWindowSize().x;
		}

		if (m_highlight != Highlight::None) {
			auto dl = UI::GetWindowDrawList();

			vec2 windowPos = UI::GetWindowPos();
			rectPos += windowPos;
			rectPos.y -= UI::GetScrollY();

			vec4 borderColor = GetHighlightColor();
			borderColor.w = Setting_BorderTransparency;

			dl.AddRectFilled(vec4(
				rectPos.x, rectPos.y,
				2, rectSize.y
			), borderColor, 2);
		}
	}
}
