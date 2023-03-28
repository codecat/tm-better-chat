[Setting hidden]
bool Setting_WizardShown = false;



[Setting category="General" name="Clear chat when switching server"]
bool Setting_ClearOnLeave = true;

[Setting category="General" name="Maximum lines in backlog"]
int Setting_MaximumLines = 100;

[Setting category="General" name="Maximum lines in input history"]
int Setting_MaximumHistory = 25;

[Setting category="General" name="Automatically hide the chat during inactivity"]
bool Setting_AutoHide = false;

[Setting category="General" name="Inactivity time" min="1" max="120" description="Number of seconds of inactivity before the chat is hidden."]
int Setting_AutoHideTime = 60;

[Setting category="General" name="Enable links"]
bool Setting_EnableLinks = true;

[Setting category="General" name="Replace newlines with spaces in messages"]
bool Setting_ReplaceNewlines = false;

[Setting category="General" name="Limit backlog to visible range when not focused" description="Turning this on can slightly increase performance, but will introduce a small glitch when opening chat."]
bool Setting_LimitOnHiddenOverlay = false;

[Setting category="General" name="Cache draft messages on Escape" description="When a chat message has been drafted, if Escape is used to defocus chat then the draft will be kept for next time. Drafted means: written and not yet sent."]
bool Setting_CacheDraftOnEsc = false;

[Setting category="General" name="Lock size & position"]
bool Setting_LockWindowLocation = false;

[Setting category="General" name="Default position"]
vec2 Setting_DefaultPosition = vec2(5, 50);

[Setting category="General" name="Default size" description="You can move and resize the chat like a normal window as well!"]
vec2 Setting_DefaultSize = vec2(800, 200);

[Setting category="General" name="Hide when gamemode hides the chat"]
bool Setting_FollowHideChat = false; // NOTE: This is temporary false until Pyplanet has better support

[Setting category="General" name="Trace full debug lines to the logfile (has no effect when streamer mode is enabled)"]
bool Setting_TraceToLog = true;

[Setting category="General" name="Automatically recover json format when lost"]
bool Setting_RecoverJsonFormat = true;

#if DEVELOPER
[Setting category="General" name="Also show Nadeo's chat (used for debugging)"]
bool Setting_ShowNadeoChat = false;
#endif



[Setting category="Keys" name="Primary input"]
VirtualKey Setting_KeyInput1 = VirtualKey::Return;

[Setting category="Keys" name="Secondary input"]
VirtualKey Setting_KeyInput2 = VirtualKey::T;

[Setting category="Keys" name="Team chat input"]
VirtualKey Setting_KeyInputTeam = VirtualKey::Y;

[Setting category="Keys" name="Open input on slash key"]
bool Setting_KeyInputSlash = true;

[Setting category="Keys" name="Toggle chat window visibility"]
VirtualKey Setting_KeyToggleVisibility = VirtualKey::F4;

[Setting category="Keys" name="Gamepad: Toggle chat window visibility"]
CInputScriptPad::EButton Setting_GamepadToggleVisibility = CInputScriptPad::EButton::None;

[Setting category="Keys" name="Toggle big chat window"]
VirtualKey Setting_KeyToggleBig = VirtualKey::C;

[Setting category="Keys" name="Gamepad: Toggle big chat window"]
CInputScriptPad::EButton Setting_GamepadToggleBig = CInputScriptPad::EButton::None;



[Setting category="Messages" name="Enable emotes"]
bool Setting_EnableEmotes = true;

[Setting category="Messages" name="Extra mentions" description="Extra names to get mentioned by, seperated by commas."]
string Setting_ExtraMentions;

[Setting category="Messages" name="Favorite users" description="Favorite users to highlight, separated by commas."]
string Setting_Favorites;

[Setting category="Messages" name="Blocked users" description="Users to block from chat, separated by commas."]
string Setting_Blocked;

[Setting category="Messages" name="Filter regex" description="Regular expression to match for filtering out messages. The regex is case insensitive."]
string Setting_FilterRegex;

[Setting category="Messages" name="Show system messages" description="Whether to show system messages."]
bool Setting_ShowSystemMessages = true;

[Setting category="Messages" name="Favorite-only mode" description="Show only messages from favorited users."]
bool Setting_FavoriteOnlyMode = false;

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

[Setting category="Appearance" name="Empty space before first lines"]
bool Setting_FirstLineEmptySpace = true;



[Setting category="Colors" name="System color" color]
vec3 Setting_ColorSystem = vec3(0.4f, 0, 0.5f);

[Setting category="Colors" name="Self color" color]
vec3 Setting_ColorSelf = vec3(0.2f, 0.2f, 0.2f);

[Setting category="Colors" name="Mention color" color]
vec3 Setting_ColorMention = vec3(0.6f, 0.2f, 0);

[Setting category="Colors" name="Favorite color" color]
vec3 Setting_ColorFavorite = vec3(0, 0.5f, 1);

[Setting category="Colors" name="Tag element transparency" min=0 max=1]
float Setting_TagTransparency = 1.0f;

[Setting category="Colors" name="Line border transparency" min=0 max=1]
float Setting_BorderTransparency = 1.0f;



[Setting category="Streamer" name="Enable streamer mode" description="Enables a global block-list of streamer-unfriendly texts."]
bool Setting_StreamerMode = false;

[Setting category="Streamer" name="Censor messages" description="Censors messages in chat instead of dropping them."]
bool Setting_StreamerCensor = true;

[Setting category="Streamer" name="Censor replacement" description="What you see instead of the banned text."]
string Setting_StreamerCensorReplace = "$f33<censored>";

[Setting category="Streamer" name="Automatic 5 minute timeout" description="Automatically time-out censored users for 5 minutes."]
bool Setting_StreamerAutoTimeout = false;

[Setting category="Streamer" name="Also censor system messages" description="Not recommended."]
bool Setting_StreamerCensorSystem = false;
