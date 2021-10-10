[Setting category="General" name="Clear chat when switching server"]
bool Setting_ClearOnLeave = true;

[Setting category="General" name="Maximum lines in backlog"]
int Setting_MaximumLines = 100;

[Setting category="General" name="Maximum lines in input history"]
int Setting_MaximumHistory = 25;

[Setting category="General" name="Enable links"]
bool Setting_EnableLinks = true;

[Setting category="General" name="Limit backlog to visible range when not focused" description="Turning this on can slightly increase performance, but will introduce a small glitch when opening chat."]
bool Setting_LimitOnHiddenOverlay = false;

[Setting category="General" name="Lock size & position"]
bool Setting_LockWindowLocation = false;

[Setting category="General" name="Default position"]
vec2 Setting_DefaultPosition = vec2(5, 50);

[Setting category="General" name="Default size" description="You can move and resize the chat like a normal window as well!"]
vec2 Setting_DefaultSize = vec2(1000, 200);

[Setting category="General" name="Trace full debug lines to the logfile (has no effect when streamer mode is enabled)"]
bool Setting_TraceToLog = true;

[Setting category="General" name="Also show Nadeo's chat (used for debugging)"]
bool Setting_ShowNadeoChat = false;



[Setting category="Messages" name="Extra mentions" description="Extra names to get mentioned by, seperated by commas."]
string Setting_ExtraMentions;

[Setting category="Messages" name="Favorite users" description="Favorite users to highlight, separated by commas."]
string Setting_Favorites;

[Setting category="Messages" name="Blocked users" description="Users to block from chat, separated by commas."]
string Setting_Blocked;

[Setting category="Messages" name="Filter regex" description="Regular expression to match for filtering out messages. The regex is case insensitive."]
string Setting_FilterRegex;

[Setting category="Messages" name="Sound set"]
Sounds::SoundSet Setting_SoundSet = Sounds::SoundSet::None;

[Setting category="Messages" name="Sound on system message"]
bool Setting_SoundSystem = true;

[Setting category="Messages" name="Sound on chat message"]
bool Setting_SoundChat = true;

[Setting category="Messages" name="Sound on mention"]
bool Setting_SoundMention = true;

[Setting category="Messages" name="Sound on favorite message"]
bool Setting_SoundFavorite = true;

[Setting category="Messages" name="Sound volume" min=0 max=1]
float Setting_SoundGain = 0.15f;



enum BackgroundStyle
{
	Hidden,
	Transparent,
	TransparentLight,
	Flashing,
}

[Setting category="Appearance" name="Background style" description="Background style when the general overlay is hidden."]
BackgroundStyle Setting_BackgroundStyle = BackgroundStyle::Flashing;

[Setting category="Appearance" name="Show timestamps"]
bool Setting_ShowTimestamp = true;

[Setting category="Appearance" name="Show club tags"]
bool Setting_ShowClubTags = true;

[Setting category="Appearance" name="Show nickname if available"]
bool Setting_ShowNickname = true;

[Setting category="Appearance" name="Show text shadow"]
bool Setting_ShowTextShadow = true;

[Setting category="Appearance" name="Display help line on startup"]
bool Setting_ShowHelp = true;

[Setting category="Appearance" name="Show scrollbar"]
bool Setting_ShowScrollbar = true;



[Setting category="Streamer" name="Enable streamer mode" description="Enables a global block-list of streamer-unfriendly texts."]
bool Setting_StreamerMode = true;

[Setting category="Streamer" name="Censor messages" description="Censors messages in chat instead of dropping them."]
bool Setting_StreamerCensor = true;

[Setting category="Streamer" name="Censor replacement" description="What you see instead of the banned text."]
string Setting_StreamerCensorReplace = "$f33<censored>";

[Setting category="Streamer" name="Automatic 5 minute timeout" description="Automatically time-out censored users for 5 minutes."]
bool Setting_StreamerAutoTimeout = false;

[Setting category="Streamer" name="Also censor system messages" description="Not recommended."]
bool Setting_StreamerCensorSystem = false;
