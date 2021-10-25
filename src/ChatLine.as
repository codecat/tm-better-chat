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

	ChatLine(uint id, int64 time, const string &in line)
	{
		m_id = id;
		m_time = time;
		ParseLine(line);
	}

	vec4 GetHighlightColor(const vec4 &in def = vec4(0, 0, 0, 1))
	{
		switch (m_highlight) {
			case Highlight::System: return vec4(0.4f, 0, 0.5f, 1);
			case Highlight::Self: return vec4(0.2f, 0.2f, 0.2f, 1);
			case Highlight::Mention: return vec4(0.6f, 0.2f, 0, 1);
			case Highlight::Favorite: return vec4(0, 0.5f, 1, 1);
		}
		return def;
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
		bool teamChat = false;

		string authorName;
		string authorLogin;
		string authorNickname;

		//NOTE: we can't keep this handle around because it will be invalidated on disconnect
		CGamePlayer@ authorInfo;

		string text;

		// Trace the message to the log if needed by settings (and not in streamer mode)
		if (Setting_TraceToLog && !Setting_StreamerMode) {
			trace(line);
		}

		// If the line starts with "$FFFCHAT_JSON:", we have a json object providing us juicy details
		//NOTE: The "$FFF" at the start is prepended by the game to chat messages sent through XMLRPC (for whatever reason)
		if (line.StartsWith("$FFFCHAT_JSON:")) {
			auto js = Json::Parse(line.SubStr(14));

			if (js.HasKey("login")) {
				authorLogin = js["login"];
			}

			if (js.HasKey("nickname")) {
				authorNickname = js["nickname"];
			}

			if (js.HasKey("text")) {
				text = js["text"];
			}

			@authorInfo = FindPlayerByLogin(authorLogin);
			if (authorInfo !is null) {
				authorName = authorInfo.User.Name;
			}

		} else {
			// We don't have a json object, so we have to extract author & message contents manually
#if TMNEXT
			//TODO: This regex only works for basic uplay player names!
			auto parse = Regex::Match(line, "^([<\\[])\\$<([^\\$]+)\\$>[\\]>] (.*)");
#else
			auto parse = Regex::Match(line, "^([<\\[])\\$<(.+?)\\$>[\\]>] (.*)");
#endif
			if (parse.Length > 0) {
				if (parse[1] == "<") {
					teamChat = true;
				}
				authorName = parse[2];
				text = parse[3];
			} else {
				// Check if this is an EvoSC message
				parse = Regex::Match(line, "^\\$FFF\\$z\\$s(\\$[0-9a-fA-F]{3}.+)\\[\\$<\\$<\\$fff\\$eee(.*)\\$>\\$>\\]\\$z\\$s (.*)");
				if (parse.Length > 0) {
					authorName = parse[1] + "$z " + parse[2];
					text = parse[3];
				} else {
					// This is a system message (or something else)
					text = line;
				}
			}

			// If we have an author display name, find the player associated
			@authorInfo = FindPlayerByName(authorName);
			if (authorInfo !is null) {
				authorLogin = authorInfo.User.Login;
			}
		}

		// Check if this user is timed out
		if (!m_isFiltered && Timeout::IsTimedOut(authorName)) {
			m_isFiltered = true;
		}

		// Check if this user is blocked
		if (!m_isFiltered && CsvContainsValue(Setting_Blocked, authorName)) {
			m_isFiltered = true;
		}

		// Check if the message should be blocked by streamer mode
		if (!m_isFiltered && Setting_StreamerMode && (authorName != "" || Setting_StreamerCensorSystem)) {
			string censored = StreamerMode::Censor(text);
			if (censored == "") {
				m_isFiltered = true;
			}

			if (censored != text) {
				text = censored;
				if (Setting_StreamerAutoTimeout) {
					Timeout::Add(authorName, 5 * 60 * 1000);
				}
			}
		}

		// Check if the message matches the filter regex
		if (!m_isFiltered) {
			try {
				if (Setting_FilterRegex != "" && Regex::Contains(text, Setting_FilterRegex, Regex::Flags::ECMAScript | Regex::Flags::CaseInsensitive)) {
					m_isFiltered = true;
				}
			} catch {
				warn("There's a problem with the filter regex!");
			}
		}

		// Get some more information about this player
		auto network = cast<CTrackManiaNetwork>(GetApp().Network);

		string authorId;
		string authorClubTag;
		bool isLocalPlayer = false;
		int teamNumber = 0;
		float linearHue = 0;

		if (authorInfo !is null) {
			auto user = authorInfo.User;

#if TMNEXT
			authorId = user.WebServicesUserId;
			authorClubTag = user.ClubTag;
#endif

			isLocalPlayer = (user.Login == network.PlayerInfo.Login);

#if !UNITED
			auto smPlayer = cast<CSmPlayer>(authorInfo);
			if (smPlayer !is null) {
				teamNumber = smPlayer.EdClan;
				linearHue = smPlayer.LinearHue;
			}
#endif

#if !TURBO
			auto tmPlayer = cast<CTrackManiaPlayer>(authorInfo);
			if (tmPlayer !is null) {
				// 0 in time attack
				// 1 in team blue
				// 2 in team red
				teamNumber = tmPlayer.ScriptAPI.CurrentClan;
				if (teamNumber == 1) {
					linearHue = 0.5f;
				} else if (teamNumber == 2) {
					linearHue = 0.0f;
				}
			}
#endif

			//TODO: What else can we do with the player object here?
		}

		bool coloredTags = (teamNumber > 0);

		// System message
		if (authorName == "") {
			m_isSystem = true;
			SetHighlight(Highlight::System);
		}

		// Highlight if this is the local player
		if (isLocalPlayer) {
			m_isSelf = true;
			SetHighlight(Highlight::Self);
		}

		// Highlight if the player's exact name is mentioned
		string localPlayerName = network.PlayerInfo.Name;
		if (text.ToLower().Contains(localPlayerName.ToLower())) {
			m_isMention = true;
			SetHighlight(Highlight::Mention);
		}

		// Highlight if any extra names are mentioned
		if (CsvInText(Setting_ExtraMentions, text)) {
			m_isMention = true;
			SetHighlight(Highlight::Mention);
		}

		// Highlight if this is a favorite user
		if (CsvContainsValue(Setting_Favorites, authorName)) {
			m_isFavorite = true;
			SetHighlight(Highlight::Favorite);
		}

		// Add timestamp element
		AddColorableElement(ElementTimestamp(Time::Stamp), coloredTags, linearHue);

		// If this is a team chat message, add secret tag here
		if (teamChat) {
			AddElement(ElementTag(Icons::UserSecret));
		}

		// Add club tag
		if (authorClubTag != "") {
			AddColorableElement(ElementClubTag(authorClubTag), coloredTags, linearHue);
		}

		if (authorName != "") {
			// Add author name
			AddColorableElement(ElementPlayerName(authorName, authorNickname, authorLogin, authorId, authorClubTag), coloredTags, linearHue);
		}

		ParseMessageText(text);
	}

	void ParseMessageText(const string &in text)
	{
		AddElement(ElementFormatGroup(true));

		string buffer;

		auto parseText = text.Split(" ");
		for (uint i = 0; i < parseText.Length; i++) {
			string word = parseText[i];

			// Strip colons from word if they exist
			string emoteKey = word;
			if (emoteKey.Length > 2 && emoteKey.StartsWith(":") && emoteKey.EndsWith(":")) {
				emoteKey = emoteKey.SubStr(1, emoteKey.Length - 2);
			}

			auto emote = Emotes::Find(emoteKey);
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
		// $lhttps://openplanet.nl/ yes$l ytes
		//   ^^^^^^^^^^^^^^^^^^^^^^^^^^
		// $l[https://openplanet.nl/]yes
		//                           ^^^
		// $l[https://openplanet.nl/]yes$>yes
		//                           ^^^
		// $l[https://openplanet.nl/]yes$lyes
		//                           ^^^
		// $l[https://openplanet.nl/]yes$zyes
		//                           ^^^
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
		vec2 rectPos = UI::GetCursorPos();

		UI::SetCursorPos(rectPos + vec2(8, 0));

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

		vec2 rectSize = vec2(
			endPos.x - rectPos.x,
			newLinePos.y - rectPos.y - 6
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

			dl.AddRectFilled(vec4(
				rectPos.x, rectPos.y,
				2, rectSize.y
			), borderColor, 2);
		}
	}
}
