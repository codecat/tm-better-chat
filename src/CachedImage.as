// Modified from plugin manager

class CachedImage
{
	UI::Texture@ m_texture;

	void DownloadFromURLAsync(const string &in url)
	{
		auto req = Net::HttpGet(url);
		while (!req.Finished()) {
			yield();
		}

		int responseCode = req.ResponseCode();
		if (responseCode == 0) {
			error("Unable to download texture at URL \"" + url + "\" due to network error: " + req.Error());
			return;
		} else if (responseCode != 200) {
			error("Unable to download texture at URL \"" + url + "\" due to response code: " + responseCode);
			return;
		}

		@m_texture = UI::LoadTexture(req.Buffer());
		if (m_texture is null) {
			error("Unable to load texture at URL \"" + url + "\" from response buffer");
		} else if (m_texture.GetSize().x == 0) {
			error("Unable to download texture at URL \"" + url + "\" due to an invalid image");
			@m_texture = null;
		}
	}
}

namespace CachedImage
{
	dictionary g_cachedImages;

	CachedImage@ FindExisting(const string &in id)
	{
		CachedImage@ ret = null;
		g_cachedImages.Get(id, @ret);
		return ret;
	}

	CachedImage@ FromString(const string &in str)
	{
		if (str.StartsWith("https://") || str.StartsWith("http://")) {
			return FromURL(str);
		}
		return FromPath(str);
	}

	CachedImage@ FromPath(const string &in path)
	{
		// Return existing image if it already exists
		auto existing = FindExisting(path);
		if (existing !is null) {
			return existing;
		}

		// Try to load the texture
		auto texture = UI::LoadTexture(path);
		if (texture is null) {
			return null;
		}

		// Create a new cached image object and remember it for future reference
		auto ret = CachedImage();
		@ret.m_texture = texture;
		g_cachedImages.Set(path, @ret);
		return ret;
	}

	CachedImage@ FromURL(const string &in url)
	{
		// Return existing image if it already exists
		auto existing = FindExisting(url);
		if (existing !is null) {
			return existing;
		}

		// Create a new cached image object and remember it for future reference
		auto ret = CachedImage();
		g_cachedImages.Set(url, @ret);

		// Begin downloading
		startnew(CoroutineFuncUserdataString(ret.DownloadFromURLAsync), url);
		return ret;
	}
}
