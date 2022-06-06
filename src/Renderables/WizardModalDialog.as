class WizardModalDialog : ModalDialog
{
	UI::Texture@ m_imgEmotes;
	UI::Texture@ m_imgEmoteAutocomplete;
	UI::Texture@ m_imgFont;
	UI::Texture@ m_imgCommandAutocomplete;
	UI::Texture@ m_imgMentionAutocomplete;
	UI::Texture@ m_imgContextMenu;

	int m_stage = 0;
	int m_keySetup = 0;

	WizardModalDialog()
	{
		super(Icons::Bolt + " Better Chat introduction");

		m_size = vec2(500, 400);

		@m_imgEmotes = UI::LoadTexture("img/wizard-emotes.png");
		@m_imgEmoteAutocomplete = UI::LoadTexture("img/wizard-emote-autocomplete.png");
		@m_imgFont = UI::LoadTexture("img/wizard-font.png");
		@m_imgCommandAutocomplete = UI::LoadTexture("img/wizard-command-autocomplete.png");
		@m_imgMentionAutocomplete = UI::LoadTexture("img/wizard-mention-autocomplete.png");
		@m_imgContextMenu = UI::LoadTexture("img/wizard-context.png");
	}

	void ImageCenter(UI::Texture@ img)
	{
		vec2 imgSize = img.GetSize();
		vec2 windowSize = UI::GetWindowSize();
		UI::SetCursorPos(vec2(
			Math::Round(windowSize.x / 2 - imgSize.x / 2),
			UI::GetCursorPos().y
		));
		UI::Image(img);
	}

	void RenderKeySettings()
	{
		UI::TextWrapped(
			"Welcome to Better Chat! It looks like this is the first time you are using the plugin."
			" To get started, we'll ask you about some of your chat preferences and show some of its"
			" features."
		);
		UI::NewLine();

		UI::TextWrapped("\\$96f" + Icons::QuestionCircleO + "\\$z Which keys do you use to chat?");

		if (UI::RadioButton("\\$acfT\\$z and \\$acfEnter\\$z for chat, \\$acfY\\$z for team chat", m_keySetup == 0)) {
			m_keySetup = 0;
		}
		if (UI::RadioButton("\\$acfT\\$z and \\$acfSpace\\$z for chat, \\$acfY\\$z for team chat (United style)", m_keySetup == 1)) {
			m_keySetup = 1;
		}

		UI::TextWrapped("\\$666(You can change this later in the plugin settings!)");
	}

	void SaveKeySettings()
	{
		switch (m_keySetup) {
			case 0:
				Setting_KeyInput1 = VirtualKey::Return;
				Setting_KeyInput2 = VirtualKey::T;
				Setting_KeyInputTeam = VirtualKey::Y;
				break;

			case 1:
				Setting_KeyInput1 = VirtualKey::Space;
				Setting_KeyInput2 = VirtualKey::T;
				Setting_KeyInputTeam = VirtualKey::Y;
				break;
		}
	}

	void RenderEmoteSettings()
	{
		UI::TextWrapped(
			"Better Chat supports many popular emotes, including Twitch global emotes, BTTV/FFZ emotes,"
			" and some emotes from Trackmania streamers."
		);
		UI::NewLine();

		ImageCenter(m_imgEmotes);

		UI::NewLine();

		UI::TextWrapped("\\$96f" + Icons::QuestionCircleO + "\\$z Do you want to enable emotes in chat?");

		Setting_EnableEmotes = UI::Checkbox("Yes, enable emotes", Setting_EnableEmotes);

		UI::TextWrapped("\\$666(You can change this later in the plugin settings!)");
	}

	void RenderEmoteHelp()
	{
		UI::TextWrapped(
			"You can autocomplete emotes by typing a colon character, followed by the name of the emote you"
			" are looking for."
		);
		UI::NewLine();

		ImageCenter(m_imgEmoteAutocomplete);

		UI::NewLine();

		UI::TextWrapped(
			"You can find a complete list of available emotes by using the \\$acf/bc-emotes\\$z command."
		);
	}

	void RenderFontSettings()
	{
		UI::TextWrapped(
			"You can change the size of the font used by Better Chat, as well as use custom fonts."
		);
		UI::NewLine();

		ImageCenter(m_imgFont);

		UI::NewLine();

		RenderSettingsFontName();
		RenderSettingsFontSize();
	}

	void RenderCommandHelp()
	{
		UI::TextWrapped(
			"Better Chat comes with many built-in chat commands. They can be autocompleted by typing a slash"
			" followed by what you're looking for."
		);
		UI::NewLine();

		ImageCenter(m_imgCommandAutocomplete);

		UI::NewLine();

		UI::TextWrapped(
			"Some commands start with \\$acf/tell-\\$z, which means the command sends a chat message to the"
			" server on your behalf, as opposed to its regular variant which only you can see. You can find"
			" a complete list of available commands by using the \\$acf/bc-help\\$z command."
		);
	}

	void RenderContextHelp()
	{
		UI::TextWrapped(
			"When the overlay is enabled (\\$acfF3\\$z by default), you can interact with the chat. When you"
			" right click a player's name, you get a dropdown menu with some options."
		);
		UI::NewLine();

		ImageCenter(m_imgContextMenu);
	}

	void RenderFinal()
	{
		UI::TextWrapped(
			"Thanks for installing Better Chat! \\$f39" + Icons::Heart + "\\$z Below are some extra resources"
			" you might find useful. Otherwise, click \\$acfFinish\\$z to close the setup wizard."
		);
		UI::NewLine();

		if (UI::Button(Icons::Github + " Better Chat on Github")) {
			OpenBrowserURL("https://github.com/codecat/tm-better-chat");
		}
		if (UI::Button(Icons::Heart + " Sponsor me with a monthly donation")) {
			OpenBrowserURL("https://github.com/sponsors/codecat");
		}
		if (UI::Button(Icons::DiscordAlt + " Join the Openplanet discord")) {
			OpenBrowserURL("https://openplanet.dev/link/discord");
		}
	}

	bool CanClose() override
	{
		return false;
	}

	void RenderDialog() override
	{
		UI::PushFont(g_fontHeader);
		UI::Text("Setup wizard (" + (m_stage + 1) + " / 7)");
		UI::PopFont();

		UI::Separator();

		UI::BeginChild("Content", vec2(0, -32));
		switch (m_stage) {
			case 0: RenderKeySettings(); break;
			case 1: RenderEmoteSettings(); break;
			case 2: RenderEmoteHelp(); break;
			case 3: RenderFontSettings(); break;
			case 4: RenderCommandHelp(); break;
			case 5: RenderContextHelp(); break;
			case 6: RenderFinal(); break;
		}
		UI::EndChild();

		if (m_stage == 0) {
			if (UI::RedButton(Icons::Times + " Skip")) {
				Setting_WizardShown = true;
				Close();
			}
		} else {
			if (UI::RedButton(Icons::ArrowLeft + " Back")) {
				m_stage--;
			}
		}
		UI::SameLine();

		vec2 currentPos = UI::GetCursorPos();
		vec2 windowSize = UI::GetWindowSize();

		if (m_stage == 6) {
			UI::SetCursorPos(vec2(windowSize.x - 82, currentPos.y));
			if (UI::GreenButton("Finish " + Icons::Check)) {
				Setting_WizardShown = true;
				Close();
			}
		} else {
			UI::SetCursorPos(vec2(windowSize.x - 75, currentPos.y));
			if (UI::GreenButton("Next " + Icons::ArrowRight)) {
				switch (m_stage) {
					case 0: SaveKeySettings(); break;
				}
				m_stage++;
			}
		}
	}
}
