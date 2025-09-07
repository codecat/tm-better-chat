namespace Emotes
{
	dictionary g_emotes;
	dictionary g_emotesLower;
	array<Emote@> g_sortedEmotes;

	Emote@ Find(const string &in name, bool caseSensitive = true)
	{
		Emote@ ret;
		if (caseSensitive) {
			if (!g_emotes.Get(name, @ret)) {
				return null;
			}
		} else {
			if (!g_emotesLower.Get(name.ToLower(), @ret)) {
				return null;
			}
		}
		return ret;
	}

	void LoadFromJson(const Json::Value &in js)
	{
		if (js.GetType() != Json::Type::Object) {
			error("Unable to load emotes: Json is invalid");
			return;
		}

		string texturePath = js["texture"];

		auto texture = CachedImage::FromString(texturePath);
		if (texture is null) {
			error("Unable to load emotes texture: \"" + texturePath + "\"");
			return;
		}

		auto jsEmotes = js["emotes"];
		if (jsEmotes.GetType() != Json::Type::Object) {
			error("Unable to load emotes: Json emotes object is invalid");
			return;
		}

		EmoteSource@ source = EmoteSource();
		source.m_name = js["name"];

		auto keys = jsEmotes.GetKeys();
		for (uint i = 0; i < keys.Length; i++) {
			string key = keys[i];
			auto jsEmote = jsEmotes[key];

			Emote@ newEmote = Emote(jsEmote, key, texture, source);
			g_emotes.Set(key, @newEmote);
			g_emotesLower.Set(key.ToLower(), @newEmote);
			g_sortedEmotes.InsertLast(newEmote);
		}
	}

	void LoadFromUrlAsync(const string &in url)
	{
		trace("Loading emote list from URL: \"" + url + "\"");

		auto req = Net::HttpGet(url);
		while (!req.Finished()) {
			yield();
		}

		int responseCode = req.ResponseCode();
		if (responseCode == 0) {
			error("Unable to download emote list at URL \"" + url + "\" due to network error: " + req.Error());
			return;
		} else if (responseCode != 200) {
			error("Unable to download emote list at URL \"" + url + "\" due to response code: " + responseCode);
			return;
		}

		LoadFromJson(req.Json());
	}

	awaitable@ LoadFromUrl(const string &in url)
	{
		return startnew(LoadFromUrlAsync, url);
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
