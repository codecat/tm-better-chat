class Emote
{
	Resources::Texture@ m_texture;
	vec2 m_pos;
	vec2 m_size;

	Emote(const Json::Value &in js, Resources::Texture@ texture)
	{
		@m_texture = texture;

		auto jsPos = js["pos"];
		m_pos.x = jsPos[0];
		m_pos.y = jsPos[1];

		auto jsSize = js["size"];
		m_size.x = jsSize[0];
		m_size.y = jsSize[1];
	}

	void Render(float maxheight = 24)
	{
		auto dl = UI::GetWindowDrawList();

		vec2 size = m_size;
		size *= maxheight / m_size.y;

		UI::Dummy(size);
		vec4 rect = UI::GetItemRect();

		vec4 uv;
		uv.x = m_pos.x;
		uv.y = m_pos.y;
		uv.z = m_size.x;
		uv.w = m_size.y;
		dl.AddImage(m_texture, vec2(Math::Round(rect.x), Math::Round(rect.y)), size, 0xFFFFFFFF, uv);
	}
}

dictionary g_emotes;

Emote@ FindEmote(const string &in name)
{
	Emote@ ret;
	if (!g_emotes.Get(name, @ret)) {
		return null;
	}
	return ret;
}

void LoadEmotes()
{
	IO::FileSource fileEmotes("Emotes.json");

	auto jsInfo = Json::Parse(fileEmotes.ReadToEnd());
	if (jsInfo.GetType() != Json::Type::Object) {
		error("Unable to load emotes: Json is invalid");
		return;
	}

	string texturePath = jsInfo["texture"];
	//TODO: Check for URL?
	auto texture = Resources::GetTexture(texturePath);
	if (texture is null) {
		error("Unable to load emotes texture: \"" + texturePath + "\"");
		return;
	}

	auto jsEmotes = jsInfo["emotes"];
	if (jsEmotes.GetType() != Json::Type::Object) {
		error("Unable to load emotes: Json emotes object is invalid");
		return;
	}

	auto keys = jsEmotes.GetKeys();
	for (uint i = 0; i < keys.Length; i++) {
		string key = keys[i];
		auto jsEmote = jsEmotes[key];
		g_emotes.Set(key, @Emote(jsEmote, texture));
	}
}
