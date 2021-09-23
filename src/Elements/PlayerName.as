class ElementPlayerName : ElementTag
{
	string m_name;
	string m_login;
	string m_accountID;
	string m_clubTag;

	bool m_favorited;

	ElementPlayerName(const string &in name, const string &in login, const string &in accountID, const string &in clubTag)
	{
		super(name);

		m_name = name;
		m_login = login;
		m_accountID = accountID;
		m_clubTag = clubTag;
	}

	void Render() override
	{
		ElementTag::Render();

		if (UI::BeginPopupContextItem(tostring(m_line.m_id) + " " + m_name)) {
			if (UI::IsWindowAppearing()) {
				m_favorited = CsvContainsValue(Setting_Favorites, m_name);
			}

			UI::Text(m_text);

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

			if (UI::Selectable(Icons::Ban + " Block", false)) {
				warn("TODO: Implement me"); //TODO
			}

			if (m_accountID != "") {
				UI::Separator();

				if (UI::Selectable(Icons::ExternalLinkSquare + " Open on Trackmania.io", false)) {
					OpenBrowserURL("https://trackmania.io/#/player/" + m_accountID);
				}
			}

			UI::Separator();

			if (UI::Selectable(Icons::Clipboard + " Copy name", false)) {
				IO::SetClipboard(m_name);
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
