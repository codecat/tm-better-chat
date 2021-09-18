class ElementPlayerName : Element
{
	string m_text;
	string m_login;
	string m_accountID;

	ElementPlayerName(const string &in text, const string &in login = "", const string &in accountID = "")
	{
		m_text = text;
		m_login = login;
		m_accountID = accountID;
	}

	void Render() override
	{
		UI::Tag(ColoredString(m_text));

		if (UI::BeginPopupContextItem(tostring(m_line.m_id) + " " + m_text)) {
			UI::Text(m_text);

			UI::Separator();

			if (UI::Selectable(Icons::Star + " Favorite", false)) {
				warn("TODO: Implement me"); //TODO
			}

			if (UI::Selectable(Icons::Ban + " Block", false)) {
				warn("TODO: Implement me"); //TODO
			}

			UI::Separator();

			if (m_accountID != "" && UI::Selectable(Icons::ExternalLinkSquare + " Open on Trackmania.io", false)) {
				OpenBrowserURL("https://trackmania.io/#/player/" + m_accountID);
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
