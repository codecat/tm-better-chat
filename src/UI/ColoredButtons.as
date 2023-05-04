namespace UI
{
	bool RedButton(const string &in text) { return ButtonColored(text, 0.0f); }
	bool GreenButton(const string &in text) { return ButtonColored(text, 0.33f); }
	bool DarkButton(const string &in text) { return ButtonColored(text, 0.78f, 0.0f, 0.12f); }

	bool ToggledButton(bool toggle, const string &in text)
	{
		if (!toggle) {
			return DarkButton(text);
		}
		return GreenButton(text);
	}
}
