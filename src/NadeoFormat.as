namespace Nadeo
{
	/**
	 * Formats a Nadeo translatable string into its (naive) English counterpart. This is a
	 * (temporary?) workaround where the chat API will send us localized text before translating it.
	 *
	 * Some examples:
	 *  Welcome to the %1 server.$oOfficial 3v3 - match$o
	 *   $0c0%1The match is over, thank you for playing. You can leave now.
	 *
	 * In the examples above, \xC2\x91 indicates a translatable formatted string, and \xC2\x92
	 * indicates a translatable non-formatted string. The first example is easy: we look for \xC2\x91
	 * and replace "%1" with the first next string, "%2" with the second, etc.
	 *
	 * The second example is a bit more complex, as there are multiple strings to translate; both the
	 * initial formatting string, AND the next string. We must handle this recursively.
	 *
	 * Note that a limitation of this function is that no actual translation is performed here.
	 */
	string Format(const string &in text)
	{
		// Nothing to do if the text is empty or we have no indicator
		if (text.Length <= 2 || text[0] != 0xC2) {
			return text;
		}

		// 0x91 indicates a translated formatted string
		if (text[1] == 0x91) {
			// Split string
			auto parse = text.Split("\xC2\x91");

			// Replace format string with substitutes
			string ret = parse[1];
			for (uint i = 2; i < parse.Length; i++) {
				string substitute = Format(parse[i]);
				ret = ret.Replace("%" + (i - 1), substitute);
			}

			return ret;
		}

		// 0x92 indicates a translated non-formatted string
		if (text[1] == 0x92) {
			return text.SubStr(2);
		}

		// Nothing needs to be done
		return text;
	}
}
