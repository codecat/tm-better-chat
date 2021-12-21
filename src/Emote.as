class EmoteFrame
{
	uint m_time;
	vec2 m_pos;
}

class Emote
{
	string m_name;
	Resources::Texture@ m_texture;

	array<EmoteFrame> m_frames;
	uint m_framesTime = 0;

	vec2 m_size;
	EmoteSource@ m_source;

	Emote(const Json::Value &in js, const string &in name, Resources::Texture@ texture, EmoteSource@ source)
	{
		m_name = name;
		@m_texture = texture;

		auto jsFrames = js["frames"];
		if (jsFrames.GetType() == Json::Type::Array) {
			m_frames.Reserve(jsFrames.Length);
			for (uint i = 0; i < jsFrames.Length; i++) {
				auto jsFrame = jsFrames[i];

				int time = jsFrame["time"];
				auto jsPos = jsFrame["pos"];

				EmoteFrame newFrame;
				newFrame.m_time = uint(time);
				newFrame.m_pos.x = jsPos[0];
				newFrame.m_pos.y = jsPos[1];
				m_frames.InsertLast(newFrame);

				m_framesTime += uint(time);
			}

		} else {
			auto jsPos = js["pos"];

			EmoteFrame newFrame;
			newFrame.m_time = 0;
			newFrame.m_pos.x = jsPos[0];
			newFrame.m_pos.y = jsPos[1];
			m_frames.InsertLast(newFrame);
		}

		auto jsSize = js["size"];
		m_size.x = jsSize[0];
		m_size.y = jsSize[1];

		@m_source = source;
	}

	void Render(UI::DrawList@ dl, const vec4 &in rect)
	{
		uint frameIndex = 0;

		if (m_frames.Length > 1) {
			uint time = 0;
			if (m_framesTime > 0) {
				time = uint(Time::Now % m_framesTime);
			}
			uint timeCounted = 0;
			for (uint i = 0; i < m_frames.Length; i++) {
				auto@ frame = m_frames[i];
				if (time < timeCounted + frame.m_time) {
					break;
				}
				frameIndex++;
				timeCounted += frame.m_time;
			}
		}

		vec4 uv;

		auto@ currentFrame = m_frames[frameIndex];
		uv.x = currentFrame.m_pos.x;
		uv.y = currentFrame.m_pos.y;

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
