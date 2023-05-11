class ElementPlayerName : ElementTag
{
	string m_name;
	string m_nameColored;

	string m_nickname;
	string m_nicknameColored;

	string m_login;
	string m_accountID;
	string m_clubTag;

	bool m_favorited;
	bool m_blocked;

	ElementPlayerName(const string &in name, const string &in nickname, const string &in login, const string &in accountID, const string &in clubTag)
	{
		super();

		m_name = name;
		m_nameColored = ColoredString(name);

		m_nickname = nickname;
		m_nicknameColored = ColoredString(nickname);

		if (Setting_ShowPlayerNameShadow) {
			m_nameColored = "\\$s" + m_nameColored;
			m_nicknameColored = "\\$s" + m_nicknameColored;
		}

		m_login = login;
		m_accountID = accountID;
		m_clubTag = clubTag;
	}

	void Render() override
	{
		m_color.w = Setting_TagTransparency;

		if (Setting_ShowNickname && m_nickname != "") {
			UI::Tag(m_nicknameColored, m_color);
			UI::SetPreviousTooltip(m_nameColored);
		} else {
			UI::Tag(m_nameColored, m_color);
		}

		if (UI::BeginPopupContextItem(tostring(m_line.m_id) + " " + m_name)) {
			if (UI::IsWindowAppearing()) {
				m_favorited = CsvContainsValue(Setting_Favorites, m_name);
				m_blocked = CsvContainsValue(Setting_Blocked, m_name);
			}

			if (m_nickname != "") {
				UI::Text(m_nicknameColored);
			}
			UI::Text(m_nameColored);
#if !TMNEXT
			UI::TextDisabled(m_login);
#endif

			if (!m_line.m_isSelf) {
				if (m_login != "") {
					UI::Separator();

					if (UI::Selectable(Icons::Eye + " Spectate", false)) {
						auto api = GetApp().Network.PlaygroundClientScriptAPI;
						api.RequestSpectatorClient(true);
						api.SetSpectateTarget(m_login);
					}
				}

				UI::Separator();

				if (m_favorited) {
					if (UI::Selectable(Icons::StarO + " Unfavorite", false)) {
						Setting_Favorites = CsvRemoveValue(Setting_Favorites, m_name);
					}
				} else {
					if (UI::Selectable(Icons::Star + " Favorite", false)) {
						Setting_Favorites = CsvAddValue(Setting_Favorites, m_name);
					}
				}

				if (m_blocked) {
					if (UI::Selectable(Icons::Check + " Unblock", false)) {
						Setting_Blocked = CsvRemoveValue(Setting_Blocked, m_name);
					}
				} else {
					if (UI::Selectable(Icons::Ban + " Block", false)) {
						Setting_Blocked = CsvAddValue(Setting_Blocked, m_name);
					}
				}

				if (UI::BeginMenu(Icons::ClockO + " Timeout")) {
					if (UI::MenuItem("1 minute")) {
						Timeout::Add(m_name, 60 * 1000);
					}
					if (UI::MenuItem("10 minutes")) {
						Timeout::Add(m_name, 10 * 60 * 1000);
					}
					if (UI::MenuItem("30 minutes")) {
						Timeout::Add(m_name, 30 * 60 * 1000);
					}
					if (UI::MenuItem("1 hour")) {
						Timeout::Add(m_name, 60 * 60 * 1000);
					}
					UI::EndMenu();
				}
			}

#if TMNEXT
			if (m_accountID != "") {
				UI::Separator();

				if (UI::Selectable(Icons::ExternalLinkSquare + " Open on Trackmania.io", false)) {
					OpenBrowserURL("https://trackmania.io/#/player/" + m_accountID);
				}
			}
#endif

			UI::Separator();

			if (UI::Selectable(Icons::Clipboard + " Copy name", false)) {
				IO::SetClipboard(m_name);
			}
			if (m_nickname != "" && UI::Selectable(Icons::Clipboard + " Copy nickname", false)) {
				IO::SetClipboard(m_nickname);
			}
			if (m_clubTag != "" && UI::Selectable(Icons::Clipboard + " Copy clubtag", false)) {
				IO::SetClipboard(m_clubTag);
			}
			if (m_login != "" && UI::Selectable(Icons::Clipboard + " Copy login", false)) {
				IO::SetClipboard(m_login);
			}
			if (m_accountID != "" && UI::Selectable(Icons::Clipboard + " Copy account ID", false)) {
				IO::SetClipboard(m_accountID);
			}
			UI::EndPopup();
		}
	}
}
