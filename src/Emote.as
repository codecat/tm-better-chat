class Emote
{
	string m_name;
	Resources::Texture@ m_texture;
	vec2 m_pos;
	vec2 m_size;
	EmoteSource@ m_source;

	Emote(const Json::Value &in js, const string &in name, Resources::Texture@ texture, EmoteSource@ source)
	{
		m_name = name;
		@m_texture = texture;

		auto jsPos = js["pos"];
		m_pos.x = jsPos[0];
		m_pos.y = jsPos[1];

		auto jsSize = js["size"];
		m_size.x = jsSize[0];
		m_size.y = jsSize[1];

		@m_source = source;
	}

	void Render(UI::DrawList@ dl, const vec4 &in rect)
	{
		vec4 uv;
		uv.x = m_pos.x;
		uv.y = m_pos.y;
		uv.z = m_size.x;
		uv.w = m_size.y;
		dl.AddImage(m_texture, vec2(Math::Round(rect.x), Math::Round(rect.y)), vec2(rect.z, rect.w), 0xFFFFFFFF, uv);
	}

	vec2 Render(UI::DrawList@ dl, const vec2 &in pos, float maxheight = 24)
	{
		vec2 size = m_size;
		if (size.y > maxheight) {
			size *= maxheight / m_size.y;
		}
		Render(dl, vec4(pos.x, pos.y, size.x, size.y));
		return size;
	}

	void Render(float maxheight = 24)
	{
		vec2 size = m_size;
		if (size.y > maxheight) {
			size *= maxheight / m_size.y;
		}

		UI::Dummy(size);
		Render(UI::GetWindowDrawList(), UI::GetItemRect());
	}

	void RenderFixed(float height = 24)
	{
		vec2 size = m_size;
		if (size.y > height) {
			size *= height / m_size.y;
		}

		UI::Dummy(vec2(size.x, height));
		vec4 rect = UI::GetItemRect();
		rect.w = size.y;
		Render(UI::GetWindowDrawList(), rect);
	}
}
