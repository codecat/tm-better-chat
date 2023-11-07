enum ChatLineScope
{
	Everyone,
	SpectatorCurrent,
	SpectatorAll,
	Team,
	YouOnly,
}

class ChatLineInfo
{
	bool m_isJson = false;

	ChatLineScope m_scope = ChatLineScope::Everyone;
	int m_teamNumber = 0;
	string m_teamColorText;

	bool m_isSystem = false;
	bool m_isLocalPlayer = false;
	float m_linearHue = 0;

	string m_authorId;
	string m_authorName;
	string m_authorLogin;
	string m_authorNickname;

	string m_authorClubTag;
	bool m_overrideClubTag = false;

	//NOTE: we can't keep this handle around because it will be invalidated on disconnect
	CGamePlayer@ m_authorPlayer;
	CGamePlayerInfo@ m_authorPlayerInfo;

	string m_text;

	ChatLineInfo(BetterChat::ChatEntry entry) {
		FromSharedEntry(entry);
	}

	void FromSharedEntry(BetterChat::ChatEntry entry) {
		m_text = entry.m_text;
		m_authorName = entry.m_authorName;
		m_authorClubTag = entry.m_clubTag;
		m_overrideClubTag = entry.m_clubTag != "";
		m_linearHue = entry.m_linearHue;
		m_teamNumber = entry.m_linearHue != 0. ? 1 : 0;
		m_isSystem = entry.m_system;
		m_scope = FromSharedScope(entry.m_scope);
	}

	ChatLineScope FromSharedScope(BetterChat::ChatEntryScope scope) {
		switch (scope) {
			case BetterChat::ChatEntryScope::Everyone:
				return ChatLineScope::Everyone;
			case BetterChat::ChatEntryScope::SpectatorCurrent:
				return ChatLineScope::SpectatorCurrent;
			case BetterChat::ChatEntryScope::SpectatorAll:
				return ChatLineScope::SpectatorAll;
			case BetterChat::ChatEntryScope::Team:
				return ChatLineScope::Team;
			default:
				return ChatLineScope::YouOnly;
		}
	}

#if TMNEXT
	ChatLineInfo(NGameScriptChat_SEntry@ entry)
	{
		FromEntry(entry);
		FetchAdditionalPlayerInfo();
	}

	void FromEntry(NGameScriptChat_SEntry@ entry)
	{
		m_text = Nadeo::Format(entry.Text); //TODO: Remove Nadeo::Format call if Nadeo pre-translates the string for us

		// If the line starts with "$FFFCHAT_JSON:", we have a json object providing us juicy details
		//NOTE: The "$FFF" at the start is prepended by the game to chat messages sent through XMLRPC (for whatever reason)
		if (m_text.StartsWith("CHAT_JSON:")) {
			ParseFromJson(m_text.SubStr(10));
		} else {
			m_isSystem = entry.IsSystemMessage;

			if (!m_isSystem) {
				m_authorLogin = entry.SenderLogin;
				m_authorName = entry.SenderDisplayName;
			}

			switch (entry.ChatScope) {
				case EChatScope::ToEveryone: m_scope = ChatLineScope::Everyone; break;
				case EChatScope::ToSpectatorCurrent: m_scope = ChatLineScope::SpectatorCurrent; break;
				case EChatScope::ToSpectatorAll: m_scope = ChatLineScope::SpectatorAll; break;
				case EChatScope::ToTeam: m_scope = ChatLineScope::Team; break;
				case EChatScope::ToYouOnly: m_scope = ChatLineScope::YouOnly; break;
				default: error("Unhandled chat scope " + tostring(entry.ChatScope)); break;
			}

			m_teamColorText = entry.SenderTeamColorText;

			@m_authorPlayer = FindPlayerByLogin(m_authorLogin);
			if (m_authorPlayer !is null) {
				@m_authorPlayerInfo = m_authorPlayer.User;
			} else {
				@m_authorPlayerInfo = FindPlayerInfoByLogin(m_authorLogin);
			}
		}
	}
#else
	ChatLineInfo(const string &in line)
	{
		// If the line starts with "$FFFCHAT_JSON:", we have a json object providing us juicy details
		//NOTE: The "$FFF" at the start is prepended by the game to chat messages sent through XMLRPC (for whatever reason)
		if (line.StartsWith("$FFFCHAT_JSON:")) {
			ParseFromJson(line.SubStr(14));
		} else {
			// We don't have a json object, so we have to extract author & message contents manually
			ParseFromText(line);
		}
		FetchAdditionalPlayerInfo();

		// This is a system message if there is no author name
		m_isSystem = (m_authorName == "");
	}

	void ParseFromText(const string &in line)
	{
		if (
			!ParseFromNadeo(line) &&
			!ParseFromNadeoLegacy(line) &&
			!ParseFromEvoSC(line)
		) {
			// This is a system message (or something else)
			m_text = line;
			return;
		}

		// If we have an author display name, find the player associated
		@m_authorPlayer = FindPlayerByName(m_authorName);
		if (m_authorPlayer !is null) {
			@m_authorPlayerInfo = m_authorPlayer.User;
		} else {
			@m_authorPlayerInfo = FindPlayerInfoByName(m_authorName);
		}
	}

	bool ParseFromNadeo(const string &in line)
	{
		/*
		Global: "$<$BBB[$> $<$<Miss-tm$>$> $<$BBB]$> test"
		Team:   "$<$???<$> $<$<Miss-tm$>$> $<$???>$> test"
		*/

		//NOTE: This regex only works for basic uplay player names!
		auto parse = Regex::Match(line,
			"^(\\$FFF)?"                         // "$FFF"             XMLRPC adds $FFF to the start of messages, so we keep this here optionally
			"\\$<\\$[A-Fa-f0-9]{3}([<\\[])\\$> " // "$<$BBB[$> "       First colored bracket, either [ or < in $BBB or $fff for global and team, respectively
			"\\$<\\$<([^\\$]+)\\$>\\$> "         // "$<$<Miss-tm$>$> " Player name, wrapped in double scopes (likely Nadeo not realizing names are already scoped)
			"\\$<\\$[A-Fa-f0-9]{3}[\\]>]\\$> "   // "$<$BBB]$> "       Second colored bracket, either ] or > in $BBB or $fff for global and team, respectively
			"([\\S\\s]*)"                        // "test"             The actual chat message text
		);
		if (parse.Length == 0) {
			return false;
		}

		if (parse[2] == "<") {
			m_scope = ChatLineScope::Team;
		}
		m_authorName = parse[3];
		m_text = parse[4];

		return true;
	}

	bool ParseFromNadeoLegacy(const string &in line)
	{
#if TMNEXT
		//NOTE: This regex only works for basic uplay player names!
		auto parse = Regex::Match(line, "^(\\$FFF)?([<\\[])\\$<([^\\$]+)\\$>[\\]>] ([\\S\\s]*)");
#else
		auto parse = Regex::Match(line, "^(\\$FFF)?([<\\[])\\$<(.+?)\\$>[\\]>] ([\\S\\s]*)");
#endif
		if (parse.Length == 0) {
			return false;
		}

		if (parse[2] == "<") {
			m_scope = ChatLineScope::Team;
		}
		m_authorName = parse[3];
		m_text = parse[4];

		return true;
	}

	bool ParseFromEvoSC(const string &in line)
	{
		auto parse = Regex::Match(line, "^\\$FFF\\$z\\$s(\\$[0-9a-fA-F]{3}.+)\\[\\$<\\$<\\$fff\\$eee(.*)\\$>\\$>\\]\\$z\\$s ([\\S\\s]*)");
		if (parse.Length == 0) {
			return false;
		}

		m_authorName = parse[1] + "$z " + parse[2];
		m_text = parse[3];

		return true;
	}
#endif

	void ParseFromJson(const string &in json)
	{
		m_isJson = true;

		auto js = Json::Parse(json);

		if (js.HasKey("login")) {
			m_authorLogin = js["login"];
		}

		if (js.HasKey("nickname")) {
			m_authorNickname = js["nickname"];
		}

		if (js.HasKey("clubtag")) {
			m_authorClubTag = js["clubtag"];
			m_overrideClubTag = true;
		}

		if (js.HasKey("text")) {
			m_text = js["text"];
		}

		@m_authorPlayer = FindPlayerByLogin(m_authorLogin);
		if (m_authorPlayer !is null) {
			@m_authorPlayerInfo = m_authorPlayer.User;
		} else {
			@m_authorPlayerInfo = FindPlayerInfoByLogin(m_authorLogin);
		}

		if (m_authorPlayerInfo !is null) {
			m_authorName = m_authorPlayerInfo.Name;
		}

		m_isSystem = (m_authorPlayer is null);
	}

	void FetchAdditionalPlayerInfo()
	{
		if (m_authorPlayerInfo is null) {
			return;
		}

		if (m_authorLogin == "") {
			m_authorLogin = m_authorPlayerInfo.Login;
		}

#if TMNEXT
		m_authorId = m_authorPlayerInfo.WebServicesUserId;
		if (!m_overrideClubTag) {
			m_authorClubTag = m_authorPlayerInfo.ClubTag;
		}
#endif

		auto network = cast<CTrackManiaNetwork>(GetApp().Network);
		m_isLocalPlayer = (m_authorPlayerInfo.Login == network.PlayerInfo.Login);

#if !UNITED
		auto smPlayer = cast<CSmPlayer>(m_authorPlayer);
		if (smPlayer !is null) {
			m_teamNumber = smPlayer.EdClan;
			m_linearHue = smPlayer.LinearHue;
		}
#endif

#if MP41
		auto tmPlayer = cast<CTrackManiaPlayer>(m_authorPlayer);
		if (tmPlayer !is null) {
			// 0 in time attack
			// 1 in team blue
			// 2 in team red
			m_teamNumber = tmPlayer.ScriptAPI.CurrentClan;
			if (m_teamNumber == 1) {
				m_linearHue = 0.5f;
			} else if (m_teamNumber == 2) {
				m_linearHue = 0.0f;
			}
		}
#endif

		//TODO: What else can we do with the player object here?
	}
}
