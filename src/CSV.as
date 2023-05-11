bool CsvInText(const string &in csv, const string &in text)
{
	if (csv == "") {
		return false;
	}

	auto values = csv.ToLower().Split(",");
	for (uint i = 0; i < values.Length; i++) {
		if (Regex::Contains(text, "\\b" + values[i] + "\\b", Regex::Flags::CaseInsensitive)) {
			return true;
		}
	}
	return false;
}

bool CsvContainsValue(const string &in csv, const string &in value)
{
	if (csv == "") {
		return false;
	}

	auto values = csv.ToLower().Split(",");
	return values.Find(value.ToLower()) != -1;
}

string CsvRemoveValue(const string &in csv, const string &in value)
{
	if (csv == "") {
		return "";
	}

	auto values = csv.Split(",");

	int index = values.Find(value);
	if (index == -1) {
		return csv;
	}

	values.RemoveAt(index);

	string ret;
	for (uint i = 0; i < values.Length; i++) {
		if (i > 0) {
			ret += ",";
		}
		ret += values[i];
	}
	return ret;
}

string CsvAddValue(const string &in csv, const string &in value)
{
	if (csv == "") {
		return value;
	}
	return csv + "," + value;
}
