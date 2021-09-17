namespace UI
{
	bool ColoredButton(const string &in text, float h, float s = 0.6f, float v = 0.6f)
	{
		UI::PushStyleColor(UI::Col::Button, UI::HSV(h, s, v));
		UI::PushStyleColor(UI::Col::ButtonHovered, UI::HSV(h, s + 0.1f, v + 0.1f));
		UI::PushStyleColor(UI::Col::ButtonActive, UI::HSV(h, s + 0.2f, v + 0.2f));
		bool ret = UI::Button(text);
		UI::PopStyleColor(3);
		return ret;
	}

	bool RedButton(const string &in text) { return ColoredButton(text, 0.0f); }
	bool GreenButton(const string &in text) { return ColoredButton(text, 0.33f); }
	bool DarkButton(const string &in text) { return ColoredButton(text, 0.78f, 0.0f, 0.12f); }
}
