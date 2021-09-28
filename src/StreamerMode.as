namespace StreamerMode
{
	// Regular expressions of banned words (eg. slurs and stuff generally not allowed on Twitch)
	array<string> g_bannedRegex = {
		// Homophobic
		"(\\b|_)f[^a-z]*[a4]+[^a-z]*g([^a-z]*g[^a-z]*[o0]+[^a-z]*t+|g+)?(\\b|_)",
		"(\\b|_)d[^a-z]*y+[^a-z]*k[^a-z]*[e3]+(\\b|_)",

		// Transphobic
		"(\\b|_)t[^a-z]*r[^a-z]*[a4]+[^a-z]*n[^a-z]*n[^a-z]*(y+|ie+)(\\b|_)",
		"(\\b|_)c[^a-z]*u+[^a-z]*n[^a-z]*t[^a-z]*b[^a-z]*[o0]+[^a-z]*y+(\\b|_)",
		"(\\b|_)s[^a-z]*h[^a-z]*[e3]+[^a-z]*m[^a-z]*[a4]+[^a-z]*l[^a-z]*[e3]+(\\b|_)",
		"(\\b|_)t[^a-z]*r[^a-z]*[a4]+[^a-z]*n[^a-z]*s[^a-z]*v[^a-z]*[e3]+[^a-z]*s[^a-z]*t[^a-z]*[i1]+[^a-z]*t[^a-z]*[e3]+(\\b|_)",

		// Ableist
		"(\\b|_)r[^a-z]*[e3]+[^a-z]*t[^a-z]*[a4]+[^a-z]*r[^a-z]*d+([^a-z]*[e3]+[^a-z]*d+)?(\\b|_)",

		// Racist
		"(\\b|_)n[^a-z]*[i1]+([^a-z]*g)+[^a-z]*([a4e3]+[^a-z]*r+|[a4u]+h?)(s+)?(\\b|_)",
		"(\\b|_)n[i1e3][^a-z]*g[^a-z]*r[^a-z]*[a4o0]+(\\b|_)",
		"(\\b|_)c[^a-z]*h[^a-z]*[i1]+[^a-z]*n[^a-z]*k+(\\b|_)",
	};

	string Censor(string text)
	{
		string textCheck = StripFormatCodes(text);

		int regexFlags = Regex::Flags::ECMAScript | Regex::Flags::CaseInsensitive;

		for (uint i = 0; i < g_bannedRegex.Length; i++) {
			string pattern = g_bannedRegex[i];
			if (pattern == "") {
				continue;
			}
			if (Regex::Contains(textCheck, pattern, regexFlags)) {
				if (!Setting_StreamerCensor) {
					return "";
				}
				text = textCheck = Regex::Replace(textCheck, pattern, "$<" + Setting_StreamerCensorReplace + "$>", regexFlags);
			}
		}

		return text;
	}
}
