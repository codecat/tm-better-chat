class EmotesModalDialog : ModalDialog
{
	EmotesModalDialog()
	{
		super("Emotes");

		m_size = vec2(500, 500);
	}

	void RenderDialog() override
	{
		UI::Text("This is a list of all emotes available in Better Chat.");

		UI::Separator();

		UI::BeginChild("Emotes");
		UI::ListClipper clipper(Emotes::g_sortedEmotes.Length);
		while (clipper.Step()) {
			for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
				auto emote = Emotes::g_sortedEmotes[i];
				auto source = emote.m_source;

				emote.RenderFixed();
				UI::SameLine();
				UI::Text(emote.m_name + " \\$777(" + source.m_name + ")");
			}
		}
		UI::EndChild();
	}
}
