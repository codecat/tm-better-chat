CSmPlayer@ FindPlayerByName(const string &in name)
{
	if (name == "") {
		return null;
	}

	auto pg = GetApp().CurrentPlayground;
	if (pg is null) {
		return null;
	}

	for (uint i = 0; i < pg.Players.Length; i++) {
		auto player = cast<CSmPlayer>(pg.Players[i]);
		if (player.User.Name == name) {
			return player;
		}
	}

	return null;
}

CSmPlayer@ FindPlayerByLogin(const string &in login)
{
	if (login == "") {
		return null;
	}

	auto pg = GetApp().CurrentPlayground;
	if (pg is null) {
		return null;
	}

	for (uint i = 0; i < pg.Players.Length; i++) {
		auto player = cast<CSmPlayer>(pg.Players[i]);
		if (player.User.Login == login) {
			return player;
		}
	}

	return null;
}

