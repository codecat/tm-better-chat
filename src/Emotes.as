namespace Emotes
{
	dictionary g_emotes;

	Emote@ Find(const string &in name)
	{
		Emote@ ret;
		if (!g_emotes.Get(name, @ret)) {
			return null;
		}
		return ret;
	}

	void LoadFromJson(const Json::Value &in js)
	{
		if (js.GetType() != Json::Type::Object) {
			error("Unable to load emotes: Json is invalid");
			return;
		}

		//TODO: Check the texture path for a URL
		string texturePath = js["texture"];

		auto texture = Resources::GetTexture(texturePath);
		if (texture is null) {
			error("Unable to load emotes texture: \"" + texturePath + "\"");
			return;
		}

		auto jsEmotes = js["emotes"];
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

	class LoadFromURLUserdata
	{
		string m_url;

		LoadFromURLUserdata(const string &in url)
		{
			m_url = url;
		}
	}

	void LoadFromURLAsync(ref@ urlUserdata)
	{
		auto url = cast<LoadFromURLUserdata>(urlUserdata).m_url;

		warn("TODO: Load from URL: \"" + url + "\"");
	}

	void LoadFromURL(const string &in url)
	{
		startnew(LoadFromURLAsync, LoadFromURLUserdata(url));
	}

	void LoadFromFileSource(const string &in path)
	{
		IO::FileSource fileEmotes(path);
		auto jsInfo = Json::Parse(fileEmotes.ReadToEnd());
		LoadFromJson(jsInfo);
	}

	void Load()
	{
		LoadFromFileSource("Emotes.json");
	}
}
