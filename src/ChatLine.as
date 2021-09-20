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

	void ParseLine(const string &in line)
	{
		string author;
		string text;

		if (Setting_TraceToLog) {
			trace(line);
		}

		// Extract author & message contents
		auto parse = Regex::Match(line, "^\\[\\$<([^\\$]+)\\$>\\] (.*)"); //TODO: This regex only works for basic uplay player names!
		if (parse.Length > 0) {
			author = parse[1];
			text = parse[2];
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

		// If we have an author display name, find the player associated
		//NOTE: we can't keep this handle around because it will be invalidated on disconnect
		CGamePlayerInfo@ authorInfo = null;
		auto network = cast<CTrackManiaNetwork>(GetApp().Network);
		for (uint i = 0; i < network.PlayerInfos.Length; i++) {
			auto playerInfo = cast<CGamePlayerInfo>(network.PlayerInfos[i]);
			if (playerInfo.Name == author) {
				@authorInfo = playerInfo;
				break;
			}
		}

		string authorLogin;
		string authorId;
		bool isLocalPlayer = false;

		if (authorInfo !is null) {
			// Add club tag
			if (authorInfo.ClubTag != "") {
				AddElement(ElementClubTag(authorInfo.ClubTag));
			}

			authorLogin = authorInfo.Login;
			authorId = authorInfo.WebServicesUserId;
			isLocalPlayer = (authorInfo.Login == network.PlayerInfo.Login);

			//TODO: What else can we do with the player info object here?
		}

		// Highlight if this is a system message
		if (m_highlight == Highlight::None && author == "") {
			m_highlight = Highlight::System;
		}

		// Highlight if this is the local player
		if (m_highlight == Highlight::None && isLocalPlayer) {
			m_highlight = Highlight::Self;
		}

		// Highlight if this is a favorite user
		if (m_highlight == Highlight::None && CsvContainsValue(Setting_Favorites, author)) {
			m_highlight = Highlight::Favorite;
		}

		// Highlight if the player's exact name is mentioned
		if (m_highlight == Highlight::None) {
			string localPlayerName = network.PlayerInfo.Name;
			if (text.ToLower().Contains(localPlayerName.ToLower())) {
				m_highlight = Highlight::Mention;
			}
		}

		// Highlight if any extra names are mentioned
		if (m_highlight == Highlight::None && CsvInText(Setting_ExtraMentions, text)) {
			m_highlight = Highlight::Mention;
		}

		if (author != "") {
			// Add author name
			AddElement(ElementPlayerName(author, authorLogin, authorId));
		}

		ParseMessageText(text);
	}

	void ParseMessageText(const string &in text)
	{
		string buffer;

		auto parseText = text.Split(" ");
		for (uint i = 0; i < parseText.Length; i++) {
			string word = parseText[i];

			auto emote = Emotes::Find(word);
			if (emote !is null) {
				AddElement(ElementText(buffer));
				buffer = "";
				AddElement(ElementEmote(emote));
				continue;
			}

			if (i > 0) {
				buffer += " ";
			}
			buffer += word;
		}

		AddElement(ElementText(buffer));
	}

	void AddElement(Element@ element)
	{
		@element.m_line = this;
		m_elements.InsertLast(element);
	}

	void Render()
	{
		vec2 rectPos = UI::GetCursorPos();

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
				windowPos.x + 4, rectPos.y,
				2, rectSize.y
			), borderColor, 2);
		}
	}
}
