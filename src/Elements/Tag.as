class ElementTag : Element
{
	string m_text;
	vec4 m_color = UI::TAG_COLOR;

	ElementTag()
	{
	}

	ElementTag(const string &in text)
	{
		m_text = Text::OpenplanetFormatCodes(text).Replace("\n", " ");
	}

	void SetColorFromChatLineInfo(const ChatLineInfo &in info)
	{
		if (info.m_teamNumber <= 0) {
			return;
		}

		//TODO: The check for $fff is a temporary workaround for 3v3 matchmaking
		if (info.m_teamColorText != "" && info.m_teamColorText != "$fff") {
			SetColorFromText(info.m_teamColorText);
		} else {
			SetColorFromHue(info.m_linearHue);
		}
	}

	void SetColorFromHue(float hue)
	{
		m_color = UI::HSV(hue, 0.6f, 0.6f);
	}

	void SetColorFromText(const string &in text)
	{
		if (text.StartsWith("$")) {
			vec4 color = Text::ParseHexColor(text.SubStr(1));

			//TODO: Switch to UI::ToHSV()
			// Source: https://stackoverflow.com/a/26233318/377618
			float hue = 0;
			float min = Math::Min(color.x, Math::Min(color.y, color.z));
			float max = Math::Max(color.x, Math::Max(color.y, color.z));
			if (min != max) {
				if (max == color.x) {
					hue = (color.y - color.z) / (max - min);
				} else if (max == color.y) {
					hue = 2 + (color.z - color.x) / (max - min);
				} else {
					hue = 4 + (color.x - color.y) / (max - min);
				}
				hue *= 60;
				if (hue < 0) {
					hue += 360;
				}
				hue /= 360;
			}

			SetColorFromHue(hue);
		}
	}

	void Render() override
	{
		m_color.w = Setting_TagTransparency;
		UI::Tag(m_text, m_color);
	}
}
