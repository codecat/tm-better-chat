[Setting hidden]
string Setting_FontName = "DroidSans.ttf";

[Setting hidden]
int Setting_FontSize = 16;

bool Setting_FontUpdated = false;
array<string> Setting_AvailableFonts;

void RenderSettingsFontName()
{
	string userFontsFolder = IO::FromDataFolder("Fonts");

	UI::TextWrapped(
		"To use custom fonts, place your ttf fonts here: " + userFontsFolder
	);

	if (UI::BeginCombo("Font", Setting_FontName)) {
		if (UI::IsWindowAppearing()) {
			Setting_AvailableFonts.RemoveRange(0, Setting_AvailableFonts.Length);

			string systemFontsFolder = IO::FromAppFolder("Openplanet/Fonts");
			auto files = IO::IndexFolder(systemFontsFolder, false);
			for (uint i = 0; i < files.Length; i++) {
				string filename = files[i].SubStr(systemFontsFolder.Length + 1);
				if (filename == "ManiaIcons.ttf") {
					continue;
				}
				Setting_AvailableFonts.InsertLast(filename);
			}

			files = IO::IndexFolder(userFontsFolder, false);
			for (uint i = 0; i < files.Length; i++) {
				Setting_AvailableFonts.InsertLast(files[i].SubStr(userFontsFolder.Length + 1));
			}
		}

		for (uint i = 0; i < Setting_AvailableFonts.Length; i++) {
			auto fontName = Setting_AvailableFonts[i];

			string name = fontName;
			if (fontName == "DroidSans.ttf") {
				name += " (Default)";
			}

			if (UI::Selectable(name, Setting_FontName == fontName)) {
				Setting_FontName = fontName;
				Setting_FontUpdated = true;
			}

			if (Setting_FontName == fontName) {
				UI::SetItemDefaultFocus();
			}
		}

		UI::EndCombo();
	}
}

void RenderSettingsFontSize()
{
	const array<int> availableSizes = { 16, 18, 20, 22, 24, 26, 28, 30 };

	if (UI::BeginCombo("Font size", tostring(Setting_FontSize))) {
		for (uint i = 0; i < availableSizes.Length; i++) {
			int size = availableSizes[i];

			string name = tostring(size);
			if (size == 16) {
				name += " (Default)";
			}

			if (UI::Selectable(name, Setting_FontSize == size)) {
				Setting_FontSize = size;
				Setting_FontUpdated = true;
			}

			if (Setting_FontSize == size) {
				UI::SetItemDefaultFocus();
			}
		}
		UI::EndCombo();
	}
}

[SettingsTab name="Font"]
void RenderSettingsFontTab()
{
	UI::TextWrapped(
		"Note: Changing the font is still an experimental feature. Stuff might "
		"look weird when using larger fonts. Please report any issues you find "
		"on Github or Discord."
	);

	RenderSettingsFontName();
	RenderSettingsFontSize();
}
