global function InitHudOptionsPanel
global function RestoreHUDDefaults
global function GameplayPanel_GetConVarData

struct
{
	table<var, string> buttonTitles
	table<var, string> buttonDescriptions
	var				   panel
	var                detailsPanel
	var                itemDescriptionBox
	var                	crossplayButton
	bool				crossplayEnabled

	array<ConVarData>    conVarDataList

	bool isPanelDisplayed = false
} file


void function InitHudOptionsPanel( var panel )
{
	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, OnHudOptionsPanel_Show )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, OnHudOptionsPanel_Hide )

	var contentPanel = Hud_GetChild( panel, "ContentPanel" )
	file.panel = panel

	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchLootPromptStyle" ), "#HUD_SETTING_LOOTPROMPTYSTYLE", "#HUD_SETTING_LOOTPROMPTYSTYLE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchShotButtonHints" ), "#HUD_SHOW_BUTTON_HINTS", "#HUD_SHOW_BUTTON_HINTS_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchDamageIndicatorStyle" ), "#HUD_SETTING_HITINDICATORSTYLE", "#HUD_SETTING_HITINDICATORSTYLE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchDamageTextStyle" ), "#HUD_SETTING_DAMAGETEXTSTYLE", "#HUD_SETTING_DAMAGETEXTSTYLE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchPingOpacity" ), "#HUD_SETTING_PINGOPACITY", "#HUD_SETTING_PINGOPACITY_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchShowObituary" ), "#HUD_SHOW_OBITUARY", "#HUD_SHOW_OBITUARY_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchRotateMinimap" ), "#HUD_ROTATE_MINIMAP", "#HUD_ROTATE_MINIMAP_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchWeaponAutoCycle" ), "#SETTING_WEAPON_AUTOCYCLE", "#SETTING_WEAPON_AUTOCYCLE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchAutoSprint" ), "#SETTING_AUTOSPRINT", "#SETTING_AUTOSPRINT_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchStickySprintForward" ), "#SETTING_STICKYSPRINTFORWARD", "#SETTING_STICKYSPRINTFORWARD_DESC", $"rui/menu/settings/settings_hud" )
            
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchJetpackControl" ), "#SETTING_JETPACKCONTROL", "#SETTING_JETPACKCONTROL_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchPilotDamageIndicators" ), "#HUD_PILOT_DAMAGE_INDICATOR_STYLE", "#HUD_PILOT_DAMAGE_INDICATOR_STYLE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchDamageClosesMenu" ), "#HUD_DAMAGE_CLOSES_MENU", "#HUD_DAMAGE_CLOSES_MENU_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchHopupPopup" ), "#SETTING_HOPUP_POPUP", "#SETTING_HOPUP_POPUP_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchShowHealthbars" ), "#HUD_SHOW_HEALTHBARS", "#HUD_SHOW_HEALTHBARS_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchStreamerMode" ), "#HUD_STREAMER_MODE", "#HUD_STREAMER_MODE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchAnonymousMode" ), "#HUD_ANON_MODE", "#HUD_ANON_MODE_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchAnalytics" ), "#HUD_PIN_OPT_IN", "#HUD_PIN_OPT_IN_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchNetGraph" ), "#HUD_NET_GRAPH", "#HUD_NET_GRAPH_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchClubInvites" ), "#HUD_CLUB_INVITES", "#HUD_CLUB_INVITES_DESC", $"rui/menu/settings/settings_hud" )
	#if(PC_PROG)
		SetConVarBool( "CrossPlay_user_optin", true )
	#endif
	file.crossplayButton = SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchCrossplay" ), "#HUD_CROSSPLAY_OPT_IN", "#HUD_CROSSPLAY_OPT_IN_DESC", $"rui/menu/settings/settings_hud" )
	AddButtonEventHandler( file.crossplayButton, UIE_CHANGE, CrossplayButton_OnChanged )
	Hud_SetVisible( Hud_GetChild( contentPanel, "AccessibilityHeader" ), IsAccessibilityAvailable() )
	Hud_SetVisible( Hud_GetChild( contentPanel, "AccessibilityHeaderText" ), IsAccessibilityAvailable() )

	SetupSettingsButton( Hud_GetChild( contentPanel, "SwchColorBlindMode" ), "#COLORBLIND_MODE", "#OPTIONS_MENU_COLORBLIND_TYPE_DESC", $"rui/menu/settings/settings_hud", true )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwchSubtitles" ), "#SUBTITLES", "#OPTIONS_MENU_SUBTITLES_DESC", $"rui/menu/settings/settings_hud" )
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwchSubtitlesSize" ), "#SUBTITLE_SIZE", "#OPTIONS_MENU_SUBTITLE_SIZE_DESC", $"rui/menu/settings/settings_hud" )

	SetupSettingsButton( Hud_GetChild( contentPanel, "SwchAccessibility" ), "#MENU_CHAT_ACCESSIBILITY", "#OPTIONS_MENU_ACCESSIBILITY_DESC", $"rui/menu/settings/settings_hud" )
	Hud_SetVisible( Hud_GetChild( contentPanel, "SwchAccessibility" ), IsAccessibilityAvailable() )

	SetupSettingsButton( Hud_GetChild( contentPanel, "SwchChatSpeechToText" ), "#MENU_CHAT_SPEECH_TO_TEXT", "#OPTIONS_MENU_CHAT_SPEECH_TO_TEXT_DESC", $"rui/menu/settings/settings_hud" )
	Hud_SetVisible( Hud_GetChild( contentPanel, "SwchChatSpeechToText" ), IsAccessibilityAvailable() )
	
	#if PC_PROG
		SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchChatMessages" ), "#MENU_CHAT_TEXT_TO_SPEECH", "#OPTIONS_MENU_CHAT_TEXT_TO_SPEECH_DESC", $"rui/menu/settings/settings_hud" )
		Hud_SetVisible( Hud_GetChild( contentPanel, "SwitchChatMessages" ), IsAccessibilityAvailable() )
	#endif //PC_PROG
	
	SetupSettingsButton( Hud_GetChild( contentPanel, "SwitchShowMotd" ), "#HUD_SHOW_MOTD", "#HUD_SHOW_MOTD_DESC", $"rui/menu/settings/settings_hud" )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_BACK, true, "#BACKBUTTON_RESTORE_DEFAULTS", "#RESTORE_DEFAULTS", OpenConfirmRestoreHUDDefaultsDialog )
	AddPanelFooterOption( panel, LEFT, -1, false, "#FOOTER_CHOICE_HINT", "" )
	AddPanelFooterOption( panel, RIGHT, BUTTON_X, true, "#BUTTON_SHOW_CREDITS", "#SHOW_CREDITS", ShowCredits, CreditsVisible )
	#if CONSOLE_PROG
		AddPanelFooterOption( panel, RIGHT, BUTTON_Y, true, "#BUTTON_REVIEW_TERMS", "#REVIEW_TERMS", OpenEULAReviewFromFooter, IsLobbyAndEULAAccepted )
	#endif // CONSOLE_PROG
	
	//#if DURANGO_PROG
		//AddPanelFooterOption( panel, LEFT, BUTTON_Y, false, "#Y_BUTTON_XBOX_HELP", "", OpenXboxHelp )
	//#endif // DURANGO_PROG

	ScrollPanel_InitPanel( panel )
	ScrollPanel_InitScrollBar( panel, Hud_GetChild( panel, "ScrollBar" ) )
	
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_showButtonHints", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_accessibleChat", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_damageIndicatorStyle", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_damageTextStyle", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_pingAlpha", eConVarType.FLOAT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_minimapRotate", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "hud_setting_streamerMode", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "colorblind_mode", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "cc_text_size", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "damage_indicator_style_pilot", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "speechtotext_enabled", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "player_setting_damage_closes_deathbox_menu", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "enable_healthbar", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "net_netGraph2", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "clubs_showInvites", eConVarType.INT ) )
	
	#if PC_PROG
		file.conVarDataList.append( CreateSettingsConVarData( "hudchat_play_text_to_speech", eConVarType.INT ) )
	#endif
	
	file.conVarDataList.append( CreateSettingsConVarData( "motd_enable", eConVarType.INT ) )
	file.conVarDataList.append( CreateSettingsConVarData( "CrossPlay_user_optin", eConVarType.BOOL ) )
}

void function OpenConfirmRestoreHUDDefaultsDialog( var button )
{
	ConfirmDialogData data
	data.headerText = "#RESTORE_HUD_DEFAULTS"
	data.messageText = "#RESTORE_HUD_DEFAULTS_DESC"
	data.resultCallback = OnConfirmDialogResult

	OpenConfirmDialogFromData( data )
	AdvanceMenu( GetMenu( "ConfirmDialog" ) )
}


void function OnConfirmDialogResult( int result )
{
	switch ( result )
	{
		case eDialogResult.YES:
			RestoreHUDDefaults()
	}
}

void function RestoreHUDDefaults()
{
	SetConVarToDefault( "hud_setting_showButtonHints" )
	SetConVarToDefault( "hud_setting_showTips" )
	SetConVarToDefault( "hud_setting_showWeaponFlyouts" )
	SetConVarToDefault( "hud_setting_adsDof" )
	SetConVarToDefault( "hud_setting_damageIndicatorStyle" )
	SetConVarToDefault( "hud_setting_damageTextStyle" )
	SetConVarToDefault( "hud_setting_pingAlpha" )
	SetConVarToDefault( "hud_setting_streamerMode" )
	SetConVarToDefault( "hud_setting_anonymousMode" )

	SetConVarToDefault( "hud_setting_showCallsigns" )
	SetConVarToDefault( "hud_setting_showLevelUp" )
	SetConVarToDefault( "hud_setting_showMedals" )
	SetConVarToDefault( "hud_setting_showMeter" )
	SetConVarToDefault( "hud_setting_showObituary" )
	SetConVarToDefault( "hud_setting_minimapRotate" )
	SetConVarToDefault( "damage_indicator_style_pilot" )
	SetConVarToDefault( "damage_indicator_style_titan" )

	SetConVarToDefault( "weapon_setting_autocycle_on_empty" )
	SetConVarToDefault( "player_setting_autosprint" )
	SetConVarToDefault( "player_setting_stickysprintforward" )
	SetConVarToDefault( "hud_setting_showHopUpPopUp" )
	SetConVarToDefault( "player_setting_damage_closes_deathbox_menu" )
	SetConVarToDefault( "enable_healthbar" )
	SetConVarBool( "toggle_on_jump_to_deactivate", IsControllerModeActive() ? true : false )
	SetConVarToDefault( "toggle_on_jump_to_deactivate_changed" )

	SetConVarToDefault( "colorblind_mode" )
	SetConVarToDefault( "closecaption" )
	SetConVarToDefault( "cc_text_size" )
	SetConVarToDefault( "hud_setting_accessibleChat" )
	SetConVarToDefault( "speechtotext_enabled" )
	SetConVarToDefault( "net_netGraph2" )
	SetConVarToDefault( "clubs_showInvites" )
	SetConVarToDefault( "CrossPlay_user_optin" )

	#if PC_PROG
		SetConVarToDefault( "hudchat_visibility" )
	#endif //PC_PROG
	
	SetConVarToDefault( "motd_enable" )

	SaveSettingsConVars( file.conVarDataList )

	EmitUISound( "menu_advocategift_open" )
}


void function OnHudOptionsPanel_Show( var panel )
{
	ScrollPanel_SetActive( panel, true )
	UpdateCrossplaySettingAvailable()
	file.crossplayEnabled = GetConVarBool( "CrossPlay_user_optin" )
	var contentPanel = Hud_GetChild( panel, "ContentPanel" )
	Hud_Hide( Hud_GetChild( contentPanel, "SwitchCrossplay" ) )
	var nextButton = Hud_GetChild( contentPanel, "SwitchNetGraph" )
	Hud_SetPinSibling( nextButton, "SwitchAnalytics" )
	file.isPanelDisplayed = true
}


void function OnHudOptionsPanel_Hide( var panel )
{
	ScrollPanel_SetActive( panel, false )

	SaveSettingsConVars( file.conVarDataList )
	SavePlayerSettings()

	if ( IsLobby() )
		return

	if ( !CanRunClientScript() )
		return

	RunClientScript( "ClWeaponStatus_RefreshWeaponStatus", GetLocalClientPlayer() )
	RunClientScript( "Cl_ADSDoF_Update", GetLocalClientPlayer() )
	RunClientScript( "Minimap_UpdateNorthFacingOnSettingChange" )
	file.isPanelDisplayed = false
}

bool function IsUserHudOptionsDisplayed()
{
	return file.isPanelDisplayed
}


void function FooterButton_Focused( var button )
{
}


array<ConVarData> function GameplayPanel_GetConVarData()
{
	return file.conVarDataList
}


string function GetCreditsURL()
{
	return GetCurrentPlaylistVarString( "credits_url", "https://www.ea.com/games/apex-legends/credits" )
}
void function ShowCredits( var unused )
{
	string creditsURL = Localize( GetCurrentPlaylistVarString( "credits_url", "" ) )
	LaunchExternalWebBrowser( creditsURL, WEBBROWSER_FLAG_NONE )
}

bool function CreditsVisible()
{
	if ( !IsLobby() )
		return false

	return GetCurrentPlaylistVarString( "credits_url", "" ).len() > 0
}

void function OpenEULAReviewFromFooter( var button )
{
	OpenEULADialog( true, file.panel )
}
void function UpdateCrossplaySettingAvailable()
{
	var button = file.crossplayButton

	bool inMixedParty = false
	string hardware = "pc"
	Party myParty = GetParty()
	foreach ( p in myParty.members )
	{
		if ( hardware != p.hardware )
		{
			inMixedParty = true
			break
		}
	}

	#if(DURANGO_PROG)//
		inMixedParty = true
	#endif

	Hud_SetLocked( file.crossplayButton, inMixedParty )
	Hud_SetLocked( Hud_GetChild( file.crossplayButton, "LeftButton" ), inMixedParty )
	Hud_SetLocked( Hud_GetChild( file.crossplayButton, "RightButton" ), inMixedParty )

	Hud_SetVisible( file.crossplayButton, CrossplayEnabled() )
	Hud_SetVisible( Hud_GetChild( file.crossplayButton, "LeftButton" ), CrossplayEnabled() )
	Hud_SetVisible( Hud_GetChild( file.crossplayButton, "RightButton" ), CrossplayEnabled() )
}

var function GetCrossplaySettingButton()
{
	return file.crossplayButton
}

void function ToggleCrossplaySettingThread()
{
	WaitEndFrame()
	bool isCrossplayEnabled = GetConVarBool( "CrossPlay_user_optin" )
	SetConVarBool( "CrossPlay_user_optin", !isCrossplayEnabled )
	file.crossplayEnabled = !isCrossplayEnabled
}

void function CrossplayButton_OnChanged( var button )
{
	thread CrossplayButton_OnChangedThread()
}

void function CrossplayButton_OnChangedThread()
{
	bool selectionIsEnabled = Hud_GetDialogListSelectionIndex( file.crossplayButton ) == 1
	if ( selectionIsEnabled == file.crossplayEnabled )
		return

	WaitEndFrame()
//Clubs_OpenCrossplayChangeDialog()

	file.crossplayEnabled = CrossplayEnabled()
}