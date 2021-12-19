CGamePlayer@ FindPlayerByName(const string &in name)
{
	if (name == "") {
		return null;
	}

	auto pg = GetApp().CurrentPlayground;
	if (pg is null) {
		return null;
	}

	for (uint i = 0; i < pg.Players.Length; i++) {
		auto player = cast<CGamePlayer>(pg.Players[i]);
		if (player.User.Name == name) {
			return player;
		}
	}

	return null;
}

CGamePlayerInfo@ FindPlayerInfoByName(const string &in name)
{
	if (name == "") {
		return null;
	}

	auto network = GetApp().Network;
	for (uint i = 0; i < network.PlayerInfos.Length; i++) {
		auto player = cast<CGamePlayerInfo>(network.PlayerInfos[i]);
		if (player.Name == name) {
			return player;
		}
	}

	return null;
}

CGamePlayer@ FindPlayerByLogin(const string &in login)
{
	if (login == "") {
		return null;
	}

	auto pg = GetApp().CurrentPlayground;
	if (pg is null) {
		return null;
	}

	for (uint i = 0; i < pg.Players.Length; i++) {
		auto player = cast<CGamePlayer>(pg.Players[i]);
		if (player.User.Login == login) {
			return player;
		}
	}

	return null;
}

CGamePlayerInfo@ FindPlayerInfoByLogin(const string &in login)
{
	if (login == "") {
		return null;
	}

	auto network = GetApp().Network;
	for (uint i = 0; i < network.PlayerInfos.Length; i++) {
		auto player = cast<CGamePlayerInfo>(network.PlayerInfos[i]);
		if (player.Login == login) {
			return player;
		}
	}

	return null;
}
