[Setting category="General" name="Clear chat when switching server"]
bool Setting_ClearOnLeave = true;

[Setting category="General" name="Maximum lines in backlog"]
int Setting_MaximumLines = 100;

[Setting category="Messages" name="Enable links"]
bool Setting_EnableLinks = true;

[Setting category="General" name="Limit backlog to visible range when not focused" description="Turning this on can slightly increase performance, but will introduce a small glitch when opening chat."]
bool Setting_LimitOnHiddenOverlay = false;

[Setting category="General" name="Default position"]
vec2 Setting_DefaultPosition = vec2(5, 50);

[Setting category="General" name="Default size" description="You can move and resize the chat like a normal window as well!"]
vec2 Setting_DefaultSize = vec2(800, 200);

[Setting category="General" name="Trace full debug lines to the logfile"]
bool Setting_TraceToLog = false;



[Setting category="Messages" name="Extra mentions" description="Extra names to get mentioned by, seperated by commas."]
string Setting_ExtraMentions;

[Setting category="Messages" name="Favorite users" description="Favorite users to highlight, separated by commas."]
string Setting_Favorites;

[Setting category="Messages" name="Blocked users" description="Users to block from chat, separated by commas."]
string Setting_Blocked;

[Setting category="Messages" name="Filter regex" description="Regular expression to match for filtering out messages."]
string Setting_FilterRegex;

[Setting category="Messages" name="Sound on system message"]
bool Setting_SoundSystem = false;

[Setting category="Messages" name="Sound on chat message"]
bool Setting_SoundChat = false;

[Setting category="Messages" name="Sound on mention"]
bool Setting_SoundMention = false;

[Setting category="Messages" name="Sound on favorite message"]
bool Setting_SoundFavorite = false;

[Setting category="Messages" name="Sound volume" min=0 max=2]
float Setting_SoundGain = 0.3f;



enum BackgroundStyle
{
	Hidden,
	Transparent,
	TransparentLight,
}

[Setting category="Appearance" name="Background style" description="Background style when the general overlay is hidden."]
BackgroundStyle Setting_BackgroundStyle = BackgroundStyle::TransparentLight;

[Setting category="Appearance" name="Flash background" description="Flash window transparency on new messages."]
bool Setting_BackgroundFlash = true;

[Setting category="Appearance" name="Show timestamp"]
bool Setting_ShowTimestamp = true;

[Setting category="Appearance" name="Text shadow" description="Makes text more readable. This can have a small impact on performance."]
bool Setting_TextShadow = true;

[Setting category="Appearance" name="Add club tags"]
bool Setting_ClubTags = true;

[Setting category="Appearance" name="Display help line on startup"]
bool Setting_ShowHelp = true;
