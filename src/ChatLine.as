class ChatLine
{
	uint m_id;

	int64 m_time;
	array<Element@> m_elements;

	ChatLine(uint id, int64 time, const string &in line)
	{
		m_id = id;
		m_time = time;
		ParseLine(line);
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
			text = line;
		}

		// If we have an author display name, find the player associated
		//NOTE: we can't keep this handle around because it will be invalidated on disconnect
		CGamePlayerInfo@ authorInfo = null;
		auto network = GetApp().Network;
		for (uint i = 0; i < network.PlayerInfos.Length; i++) {
			auto playerInfo = cast<CGamePlayerInfo>(network.PlayerInfos[i]);
			if (playerInfo.Name == author) {
				@authorInfo = playerInfo;
				break;
			}
		}

		string authorLogin;
		string authorId;

		if (authorInfo !is null) {
			// Add club tag
			if (authorInfo.ClubTag != "") {
				AddElement(ElementClubTag(authorInfo.ClubTag));
			}

			authorLogin = authorInfo.Login;
			authorId = authorInfo.WebServicesUserId;

			//TODO: What else can we do with the player info object here?
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
		UI::Tag(Time::FormatString("%H:%M:%S", m_time));
		UI::SameLine();
		for (uint i = 0; i < m_elements.Length; i++) {
			auto element = m_elements[i];
			element.Render();
			if (i < m_elements.Length - 1) {
				UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(element.m_spacingAfter, 4));
				UI::SameLine();
				UI::PopStyleVar();
			}
		}
	}
}
