class ElementPlayerName : ElementTag
{
	string m_login;
	string m_accountID;

	bool m_favorited;

	ElementPlayerName(const string &in text, const string &in login = "", const string &in accountID = "")
	{
		super(text);
		m_login = login;
		m_accountID = accountID;
	}

	void Render() override
	{
		ElementTag::Render();

		if (UI::BeginPopupContextItem(tostring(m_line.m_id) + " " + m_text)) {
			if (UI::IsWindowAppearing()) {
				m_favorited = CsvContainsValue(Setting_Favorites, m_text);
			}

			UI::Text(m_text);

			UI::Separator();

			if (m_favorited) {
				if (UI::Selectable(Icons::StarO + " Unfavorite", false)) {
					Setting_Favorites = CsvRemoveValue(Setting_Favorites, m_text);
				}
			} else {
				if (UI::Selectable(Icons::Star + " Favorite", false)) {
					Setting_Favorites = CsvAddValue(Setting_Favorites, m_text);
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
				IO::SetClipboard(m_text);
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
