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
