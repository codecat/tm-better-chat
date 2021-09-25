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
		string author;
		string text;

		if (Setting_TraceToLog) {
			trace(line);
		}

		// Extract author & message contents
		auto parse = Regex::Match(line, "^([<\\[])\\$<([^\\$]+)\\$>[\\]>] (.*)"); //TODO: This regex only works for basic uplay player names!
		if (parse.Length > 0) {
			if (parse[1] == "<") {
				teamChat = true;
			}
			author = parse[2];
			text = parse[3];
		} else {
			// Check if this is an EvoSC message
			parse = Regex::Match(line, "^\\$FFF\\$z\\$s(\\$[0-9a-fA-F]{3}.+)\\[\\$<\\$<\\$fff\\$eee(.*)\\$>\\$>\\]\\$z\\$s (.*)");
			if (parse.Length > 0) {
				author = parse[1] + "$z " + parse[2];
				text = parse[3];
			} else {
				// This is a system message (or something else)
				text = line;
			}
		}

		auto network = cast<CTrackManiaNetwork>(GetApp().Network);

		// Check if this user is blocked
		if (CsvContainsValue(Setting_Blocked, author)) {
			m_isFiltered = true;
		}

		// Check if the message matches the filter regex
		try {
			if (Setting_FilterRegex != "" && Regex::IsMatch(text, Setting_FilterRegex)) {
				m_isFiltered = true;
			}
		} catch {
			warn("There's a problem with the filter regex!");
		}

		// If we have an author display name, find the player associated
		//NOTE: we can't keep this handle around because it will be invalidated on disconnect
		CSmPlayer@ authorInfo = null;
		if (author != "") {
			auto pg = GetApp().CurrentPlayground;
			if (pg !is null) {
				for (uint i = 0; i < pg.Players.Length; i++) {
					auto player = cast<CSmPlayer>(pg.Players[i]);
					if (player.User.Name == author) {
						@authorInfo = player;
					}
				}
			}
		}

		string authorLogin;
		string authorId;
		string authorClubTag;
		bool isLocalPlayer = false;
		int teamNumber = 0;
		float linearHue = 0;

		if (authorInfo !is null) {
			auto user = authorInfo.User;

			authorLogin = user.Login;
			authorId = user.WebServicesUserId;
			authorClubTag = user.ClubTag;
			isLocalPlayer = (user.Login == network.PlayerInfo.Login);

			teamNumber = authorInfo.EdClan;
			linearHue = authorInfo.LinearHue;

			//TODO: What else can we do with the player object here?
		}

		bool coloredTags = (teamNumber > 0);

		// If this is a team chat message, add secret tag here
		if (teamChat) {
			AddElement(ElementTag(Icons::UserSecret));
		}

		// Add club tag
		if (Setting_ClubTags && authorClubTag != "") {
			AddColorableElement(ElementClubTag(authorClubTag), coloredTags, linearHue);
		}

		// System message
		if (author == "") {
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
		if (CsvContainsValue(Setting_Favorites, author)) {
			m_isFavorite = true;
			SetHighlight(Highlight::Favorite);
		}

		if (author != "") {
			// Add author name
			AddColorableElement(ElementPlayerName(author, authorLogin, authorId, authorClubTag), coloredTags, linearHue);
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

			auto emote = Emotes::Find(word);
			if (emote !is null) {
				if (buffer != "") {
					AddText(buffer + " ");
					buffer = "";
				}
				AddElement(ElementEmote(word, emote));
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
	}

	void AddElement(Element@ element)
	{
		@element.m_line = this;
		m_elements.InsertLast(element);
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
		int index = text.IndexOf("$l");
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

			//TODO: Consider adding links to the end, eg: "Like this[1]." <1>
			//      This way we can keep any formatting

			// Parse link start
			string textWithLink = text.SubStr(index);
			auto parse = Regex::Search(textWithLink, "^\\$l(\\[[^\\]]+\\])?(.*?)(\\$[lz>]|$)");
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

			int newIndex = text.SubStr(pos).IndexOf("$l");
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

		UI::SetCursorPos(rectPos + vec2(4, 0));

		UI::AlignTextToFramePadding();

		if (Setting_ShowTimestamp) {
			UI::Tag(Time::FormatString("%H:%M:%S", m_time), GetHighlightColor(UI::TAG_COLOR));
			UI::SameLine();
		}

		for (uint i = 0; i < m_elements.Length; i++) {
			auto element = m_elements[i];
			element.Render();
			if (i < m_elements.Length - 1) {
				UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(element.m_spacingAfter, 4));
				UI::SameLine();
				UI::PopStyleVar();
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
