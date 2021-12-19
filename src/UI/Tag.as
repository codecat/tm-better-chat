namespace UI
{
	const vec4 TAG_COLOR         = vec4( 30/255.0f,  32/255.0f,  33/255.0f, 1);
	const vec4 TAG_COLOR_PRIMARY = vec4(173/255.0f,   0/255.0f,  87/255.0f, 1);
	const vec4 TAG_COLOR_INFO    = vec4( 28/255.0f, 111/255.0f, 167/255.0f, 1);
	const vec4 TAG_COLOR_SUCCESS = vec4( 46/255.0f, 149/255.0f,  98/255.0f, 1);
	const vec4 TAG_COLOR_WARNING = vec4(152/255.0f, 121/255.0f,   0/255.0f, 1);
	const vec4 TAG_COLOR_DARK    = vec4( 41/255.0f,  44/255.0f,  46/255.0f, 1);
	const vec4 TAG_COLOR_DANGER  = vec4(158/255.0f,  12/255.0f,  41/255.0f, 1);

	const vec2 TAG_PADDING = vec2(8, 4);
	const float TAG_ROUNDING = 4;

	vec4 DrawTag(const vec4 &in rect, const string &in text, const vec4 &in color = TAG_COLOR)
	{
		auto dl = UI::GetWindowDrawList();
		dl.AddRectFilled(rect, color, TAG_ROUNDING);
		dl.AddText(vec2(rect.x, rect.y) + TAG_PADDING, vec4(1, 1, 1, 1), text);
		return rect;
	}

	vec4 DrawTag(const vec2 &in pos, const string &in text, const vec4 &in color = TAG_COLOR)
	{
		vec2 textSize = Draw::MeasureString(text, g_fontChat);
		vec2 tagSize = textSize + TAG_PADDING * 2;
		return DrawTag(vec4(pos.x, pos.y, tagSize.x, tagSize.y), text, color);
	}

	void Tag(const string &in text, const vec4 &in color = TAG_COLOR)
	{
		vec2 textSize = Draw::MeasureString(text, g_fontChat);
		UI::Dummy(textSize + TAG_PADDING * 2, TAG_PADDING.y);
		DrawTag(UI::GetItemRect(), text, color);
	}

	void TagPrimary(const string &in text) { Tag(text, TAG_COLOR_PRIMARY); }
	void TagInfo(const string &in text) { Tag(text, TAG_COLOR_INFO); }
	void TagSuccess(const string &in text) { Tag(text, TAG_COLOR_SUCCESS); }
	void TagWarning(const string &in text) { Tag(text, TAG_COLOR_WARNING); }
	void TagDark(const string &in text) { Tag(text, TAG_COLOR_DARK); }
	void TagDanger(const string &in text) { Tag(text, TAG_COLOR_DANGER); }
}
