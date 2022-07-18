enum TimeCommandType
{
#if TMNEXT && DEPENDENCY_NADEOSERVICES
	WorldRecord,
	Champion,
#endif
	Author,
	Gold,
	Silver,
	Bronze,
}

class TimeCommand : BetterChat::ICommand
{
	TimeCommandType m_type;
	bool m_send;

	TimeCommand(TimeCommandType type, bool send)
	{
		m_type = type;
		m_send = send;
	}

	string Icon()
	{
		if (m_send) {
			return "\\$acf" + Icons::Trophy;
		}

		switch (m_type) {
#if TMNEXT && DEPENDENCY_NADEOSERVICES
			case TimeCommandType::WorldRecord: return "\\$db4" + Icons::Bullseye;
			case TimeCommandType::Champion:	   return "\\$071" + Icons::Trophy;
#endif
			case TimeCommandType::Author:      return "\\$071" + Icons::Trophy;
			case TimeCommandType::Gold:        return "\\$db4" + Icons::Trophy;
			case TimeCommandType::Silver:      return "\\$899" + Icons::Trophy;
			case TimeCommandType::Bronze:      return "\\$964" + Icons::Trophy;
		}
		return Icons::Trophy;
	}

	string Description()
	{
		if (m_send) {
			switch (m_type) {
#if TMNEXT && DEPENDENCY_NADEOSERVICES
				case TimeCommandType::WorldRecord: return "Tells chat the world record time.";
				case TimeCommandType::Champion:	   return "Tells chat the champion medal time.";
#endif
				case TimeCommandType::Author:      return "Tells chat the author time.";
				case TimeCommandType::Gold:        return "Tells chat the gold medal time.";
				case TimeCommandType::Silver:      return "Tells chat the silver medal time.";
				case TimeCommandType::Bronze:      return "Tells chat the bronze medal time.";
			}
		} else {
			switch (m_type) {
#if TMNEXT && DEPENDENCY_NADEOSERVICES
				case TimeCommandType::WorldRecord: return "Prints the world record time.";
				case TimeCommandType::Champion:	   return "Tells chat the champion medal time.";
#endif
				case TimeCommandType::Author:      return "Prints the author time.";
				case TimeCommandType::Gold:        return "Prints the gold medal time.";
				case TimeCommandType::Silver:      return "Prints the silver medal time.";
				case TimeCommandType::Bronze:      return "Prints the bronze medal time.";
			}
		}
		return "";
	}

#if TMNEXT && DEPENDENCY_NADEOSERVICES
	void RunWorldRecordAsync()
	{
		const string audience = "NadeoLiveServices";
		while (!NadeoServices::IsAuthenticated(audience)) {
			yield();
		}

		auto map = GetApp().RootMap;
		string uid = map.IdName;

		string url = NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/" + uid + "/top";

		auto req = NadeoServices::Get(audience, url);
		req.Start();
		while (!req.Finished()) {
			yield();
		}

		auto res = req.String();
		auto js = Json::Parse(res);
		if (js.GetType() == Json::Type::Null) {
			g_window.AddSystemLine("Unable to fetch world record from Nadeo services! Check log for details.");
			error("Unable to parse world record response: \"" + res + "\"");
			return;
		}

		auto tops = js["tops"];
		if (tops.Length == 0) {
			g_window.AddSystemLine("No zones on this leaderboard!");
			return;
		}

		auto records = tops[0]["top"];
		if (records.Length == 0) {
			g_window.AddSystemLine("No records in this leaderboard!");
			return;
		}

		auto jsWr = records[0];

		string wrAccountId = jsWr["accountId"];
		int wrTime = jsWr["score"];
		string wrDisplayName = NadeoServices::GetDisplayNameAsync(wrAccountId);

		string msg = "$<$db0" + Icons::Bullseye + "$> World record: $<$bbb" + Time::Format(wrTime) + "$> by $bbb" + wrDisplayName;

		if (m_send) {
			BetterChat::SendChatMessage(msg);
		} else {
			g_window.AddSystemLine(msg);
		}
	}

	void RunChampionMedalAsync()
	{
		// modified from https://gitlab.com/naninf/champion-medals/-/blob/main/src/data/Api.as#L90 onward
		// slighly modified to incorporate it as a chat command
		CTrackMania@ app = cast<CTrackMania@>(GetApp());
		string uid = app.RootMap.MapInfo.MapUid;

		Net::HttpRequest@ req = Net::HttpRequest();
		string api_base_url = "https://champion-medals.com";
		string api_map_endpoint = "/api/map/";


        req.Url = api_base_url + api_map_endpoint + Net::UrlEncode(uid);

        req.Start();
        while (!req.Finished()) yield();
		print(req.ResponseCode());

		string msg = "";

        if (req.ResponseCode() == 204) {
            msg += "$<$db0" + Icons::Bullseye + "$> Champion Medal: $<$bbb not found";
        } else if (req.ResponseCode() != 200) {
			msg += "$<$db0" + Icons::Bullseye + "$> Champion Medal: $<$bbb error retrieving";
        }

		// parse champion medal json
		Json::Value res_map = Json::Parse(req.String());
		string champ_time = Time::Format(res_map['cm_time']);
		msg += "$<$f47" + Icons::Trophy + "Champion: $<$bbb" + champ_time + "$>";

		if (m_send) {
			BetterChat::SendChatMessage(msg);
		} else {
			g_window.AddSystemLine(msg);
		}

	}
#endif

	void Run(const string &in text)
	{
#if TMNEXT && DEPENDENCY_NADEOSERVICES
		if (m_type == TimeCommandType::WorldRecord) {
			startnew(CoroutineFunc(RunWorldRecordAsync));
			return;
		}

		if (m_type == TimeCommandType::Champion) {
			startnew(CoroutineFunc(RunChampionMedalAsync));
			return;
		}
#endif

#if TURBO || UNITED
		auto map = GetApp().Challenge;
#else
		auto map = GetApp().RootMap;
#endif
		if (map is null) {
			return;
		}

		string msg;

		switch (m_type) {
			case TimeCommandType::Author: msg = "$<$071" + Icons::Trophy + "$> Author medal: $bbb" + Time::Format(map.TMObjective_AuthorTime); break;
			case TimeCommandType::Gold:   msg = "$<$db4" + Icons::Trophy + "$> Gold medal: $bbb"   + Time::Format(map.TMObjective_GoldTime); break;
			case TimeCommandType::Silver: msg = "$<$899" + Icons::Trophy + "$> Silver medal: $bbb" + Time::Format(map.TMObjective_SilverTime); break;
			case TimeCommandType::Bronze: msg = "$<$964" + Icons::Trophy + "$> Bronze medal: $bbb" + Time::Format(map.TMObjective_BronzeTime); break;
		}

		if (m_send) {
			BetterChat::SendChatMessage(msg);
		} else {
			g_window.AddSystemLine(msg);
		}
	}
}
