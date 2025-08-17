global function InitLobbyMenu

global function GetUIPlaylistName
global function GetUIMapName
global function GetUIMapAsset
global function GetUIVisibilityName
global function UpdateServerAndPlayerCountButtons

struct
{
	var  menu
	bool updatingLobbyUI = false
	bool inputsRegistered = false
	bool tabsInitialized = false
	bool newnessInitialized = false

	var postGameButton
	var newsButton
	var socialButton
	var gameMenuButton
	var datacenterButton
	var DcButton
	var BlogButton

	var serversButton
	var playersButton
} file

// do not change this enum without modifying it in code at gameui/IBrowser.h
global enum eServerVisibility
{
	OFFLINE,
	HIDDEN,
	PUBLIC
}

global int CurrentPresentationType = ePresentationType.PLAY

//Map to asset
global table<string, asset> MapAssets = {
	[ "mp_rr_canyonlands_staging" ] = $"rui/menu/maps/mp_rr_canyonlands_staging_big_icon",
	[ "mp_rr_canyonlands_64k_x_64k" ] = $"rui/menu/maps/mp_rr_canyonlands_64k_x_64k_big_icon",
	[ "mp_rr_canyonlands_64k_x_64k_ps4" ] = $"rui/menu/maps/mp_rr_canyonlands_64k_x_64k_big_icon",
	[ "mp_rr_canyonlands_mu1" ] = $"rui/menu/maps/mp_rr_canyonlands_mu1_big_icon",
	[ "mp_rr_canyonlands_mu2" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_big_icon",
	[ "mp_rr_canyonlands_mu2_tt" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_tt_big_icon",
	[ "mp_rr_canyonlands_mu2_mv" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_mv_big_icon",
	[ "mp_rr_canyonlands_mu2_ufo" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_ufo_big_icon",
	[ "mp_rr_canyonlands_mu1_night" ] = $"rui/menu/maps/mp_rr_canyonlands_mu1_night_big_icon",
	[ "mp_rr_desertlands_64k_x_64k" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_big_icon",
	[ "mp_rr_desertlands_64k_x_64k_nx" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_nx_big_icon",
	[ "mp_rr_desertlands_64k_x_64k_tt" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_tt_big_icon",
	[ "mp_rr_desertlands_64k_x_64k_mv" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_mv_big_icon",
	[ "mp_rr_desertlands_holiday" ] = $"rui/menu/maps/mp_rr_desertlands_holiday_big_icon",
	[ "mp_rr_desertlands_mu1" ] = $"rui/menu/maps/mp_rr_desertlands_mu1_big_icon",
	[ "mp_rr_desertlands_mu1_tt" ] = $"rui/menu/maps/mp_rr_desertlands_mu1_tt_big_icon",
	[ "mp_rr_desertlands_mu2" ] = $"rui/menu/maps/mp_rr_desertlands_mu2_big_icon",
	[ "mp_rr_arena_composite" ] = $"rui/menu/maps/mp_rr_arena_composite_big_icon",
	[ "mp_rr_party_crasher" ] = $"rui/menu/maps/mp_rr_party_crasher_big_icon",
	[ "mp_rr_arena_phase_runner" ] = $"rui/menu/maps/mp_rr_arena_phase_runner_big_icon",
	[ "mp_rr_aqueduct" ] = $"rui/menu/maps/mp_rr_aqueduct_big_icon",
	[ "mp_rr_olympus" ] = $"rui/menu/maps/mp_rr_olympus_big_icon",
	[ "mp_rr_olympus_tt" ] = $"rui/menu/maps/mp_rr_olympus_tt_big_icon",
	[ "mp_lobby" ] = $"rui/menu/maps/mp_lobby_big_icon"
}

global table<string, asset> MapAssetsSquare = {
	[ "mp_rr_canyonlands_staging" ] = $"rui/menu/maps/mp_rr_canyonlands_staging_square_icon",
	[ "mp_rr_canyonlands_64k_x_64k" ] = $"rui/menu/maps/mp_rr_canyonlands_64k_x_64k_square_icon",
	[ "mp_rr_canyonlands_64k_x_64k_ps4" ] = $"rui/menu/maps/mp_rr_canyonlands_64k_x_64k_square_icon",
	[ "mp_rr_canyonlands_mu1" ] = $"rui/menu/maps/mp_rr_canyonlands_mu1_square_icon",
	[ "mp_rr_canyonlands_mu2" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_square_icon",
	[ "mp_rr_canyonlands_mu2_tt" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_tt_square_icon",
	[ "mp_rr_canyonlands_mu2_mv" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_mv_square_icon",
	[ "mp_rr_canyonlands_mu2_ufo" ] = $"rui/menu/maps/mp_rr_canyonlands_mu2_ufo_square_icon",
	[ "mp_rr_canyonlands_mu1_night" ] = $"rui/menu/maps/mp_rr_canyonlands_mu1_night_square_icon",
	[ "mp_rr_desertlands_64k_x_64k" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_square_icon",
	[ "mp_rr_desertlands_64k_x_64k_nx" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_nx_square_icon",
	[ "mp_rr_desertlands_64k_x_64k_tt" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_tt_square_icon",
	[ "mp_rr_desertlands_64k_x_64k_mv" ] = $"rui/menu/maps/mp_rr_desertlands_64k_x_64k_mv_square_icon",
	[ "mp_rr_desertlands_holiday" ] = $"rui/menu/maps/mp_rr_desertlands_holiday_square_icon",
	[ "mp_rr_desertlands_mu1" ] = $"rui/menu/maps/mp_rr_desertlands_mu1_square_icon",
	[ "mp_rr_desertlands_mu1_tt" ] = $"rui/menu/maps/mp_rr_desertlands_mu1_tt_square_icon",
	[ "mp_rr_desertlands_mu2" ] = $"rui/menu/maps/mp_rr_desertlands_mu2_square_icon",
	[ "mp_rr_arena_composite" ] = $"rui/menu/maps/mp_rr_arena_composite_square_icon",
	[ "mp_rr_party_crasher" ] = $"rui/menu/maps/mp_rr_party_crasher_square_icon",
	[ "mp_rr_arena_phase_runner" ] = $"rui/menu/maps/mp_rr_arena_phase_runner_square_icon",
	[ "mp_rr_aqueduct" ] = $"rui/menu/maps/mp_rr_aqueduct_square_icon",
	[ "mp_rr_olympus" ] = $"rui/menu/maps/mp_rr_olympus_square_icon",
	[ "mp_rr_olympus_tt" ] = $"rui/menu/maps/mp_rr_olympus_tt_square_icon",
	[ "mp_lobby" ] = $"rui/menu/maps/mp_lobby"
}

//Map to readable name
global table<string, string> MapNames = {
	[ "mp_rr_canyonlands_staging" ] = "Firing Range",
	[ "mp_rr_canyonlands_64k_x_64k_ps4" ] = "King's Canyon Beta",
	[ "mp_rr_canyonlands_64k_x_64k" ] = "King's Canyon S1",
	[ "mp_rr_canyonlands_mu1" ] = "King's Canyon S2",
	[ "mp_rr_canyonlands_mu2" ] = "King's Canyon S5",
	[ "mp_rr_canyonlands_mu2_tt" ] = "King's Canyon S5 - Map Room",
	[ "mp_rr_canyonlands_mu2_ufo" ] = "King's Canyon S5 - Olympus Teaser",
	[ "mp_rr_canyonlands_mu2_mv" ] = "King's Canyon S7 - Mirage Voyage",
	[ "mp_rr_canyonlands_mu1_night" ] = "King's Canyon S2 - After Dark",
	[ "mp_rr_desertlands_64k_x_64k" ] = "World's Edge S3",
	[ "mp_rr_desertlands_64k_x_64k_nx" ] = "World's Edge S3 - After Dark",
	[ "mp_rr_desertlands_64k_x_64k_mv" ] = "World's Edge S3 - Mirage Voyage",
	[ "mp_rr_desertlands_64k_x_64k_tt" ] = "World's Edge S3 - Holiday Theme",
	[ "mp_rr_desertlands_holiday" ] = "World's Edge S7 - Winter Express",
	[ "mp_rr_desertlands_mu1" ] = "World's Edge S4",
	[ "mp_rr_desertlands_mu1_tt" ] = "World's Edge S4 - Trials",
	[ "mp_rr_desertlands_mu2" ] = "World's Edge S6",
	[ "mp_rr_arena_composite" ] = "Drop Off",
	[ "mp_rr_party_crasher" ] = "Party Crasher",
	[ "mp_rr_aqueduct" ] = "Overflow",
	[ "mp_rr_arena_empty" ] = "Creative",
	[ "mp_rr_arena_phase_runner" ] = "Phase Runner",
	[ "mp_rr_olympus" ] = "Olympus S7",
	[ "mp_rr_olympus_tt" ] = "Olympus S7 - Boxing Ring",
	[ "mp_lobby" ] = "Lobby"
}

//Vis to readable name
global table<int, string> VisibilityNames = {
	[ eServerVisibility.OFFLINE ] = "Offline",
	[ eServerVisibility.HIDDEN ] = "Hidden",
	[ eServerVisibility.PUBLIC ] = "Public"
}

void function InitLobbyMenu( var newMenuArg )
{
	var menu = GetMenu( "LobbyMenu" )
	file.menu = menu

	RegisterSignal( "LobbyMenuUpdate" )

	RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "Logo" ) ), "basicImage", $"rui/menu/lobby/logo" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnLobbyMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnLobbyMenu_Close )

	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnLobbyMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, OnLobbyMenu_Hide )

	AddMenuEventHandler( menu, eUIEvent.MENU_GET_TOP_LEVEL, OnLobbyMenu_GetTopLevel )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnLobbyMenu_NavigateBack )

	AddMenuVarChangeHandler( "isFullyConnected", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPartyLeader", UpdateFooterOptions )
	
	#if DURANGO_PROG
		AddMenuVarChangeHandler( "DURANGO_canInviteFriends", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isJoinable", UpdateFooterOptions )
	#elseif PS4_PROG
		AddMenuVarChangeHandler( "PS4_canInviteFriends", UpdateFooterOptions )
	#elseif PC_PROG
		AddMenuVarChangeHandler( "ORIGIN_isEnabled", UpdateFooterOptions )
		AddMenuVarChangeHandler( "ORIGIN_isJoinable", UpdateFooterOptions )
	#endif

	var postGameButton = Hud_GetChild( menu, "PostGameButton" )
	file.postGameButton = postGameButton
	ToolTipData postGameToolTip
	postGameToolTip.descText = "#MATCH_SUMMARY"
	Hud_SetToolTipData( postGameButton, postGameToolTip )
	HudElem_SetRuiArg( postGameButton, "icon", $"rui/menu/lobby/postgame_icon" )
	HudElem_SetRuiArg( postGameButton, "shortcutText", "%[BACK|TAB]%" )
	Hud_AddEventHandler( postGameButton, UIE_CLICK, PostGameButton_OnActivate )

	var newsButton = Hud_GetChild( menu, "NewsButton" )
	file.newsButton = newsButton
	ToolTipData newsToolTip
	newsToolTip.descText = "#NEWS"
	Hud_SetToolTipData( newsButton, newsToolTip )
	HudElem_SetRuiArg( newsButton, "icon", $"rui/menu/lobby/news_icon" )
	HudElem_SetRuiArg( newsButton, "shortcutText", "%[R_TRIGGER|ESCAPE]%" )
	Hud_AddEventHandler( newsButton, UIE_CLICK, NewsButton_OnActivate )

	var DcButton = Hud_GetChild( menu, "DcButton" )
	file.DcButton = DcButton
	ToolTipData dcToolTip
	dcToolTip.descText = "#MENU_TITLE_DISCORD"
	Hud_SetToolTipData( DcButton, dcToolTip )
	HudElem_SetRuiArg( DcButton, "icon", $"rui/menu/lobby/dc_icon" )
	HudElem_SetRuiArg( DcButton, "shortcutText", "%[STICK2|]%" )
	Hud_AddEventHandler( DcButton, UIE_CLICK, DCButton_OnActivate )
	
	var BlogButton = Hud_GetChild( menu, "BlogButton" )
	file.BlogButton = BlogButton
	ToolTipData blogToolTip
	blogToolTip.descText = "#MENU_TITLE_BLOG"
	Hud_SetToolTipData( BlogButton, blogToolTip )
	HudElem_SetRuiArg( BlogButton, "icon", $"rui/menu/lobby/blog_icon" )
	HudElem_SetRuiArg( BlogButton, "shortcutText", "%[STICK2|]%" )
	Hud_AddEventHandler( BlogButton, UIE_CLICK, BlogButton_OnActivate )

	var playersButton = Hud_GetChild( menu, "PlayersButton" )
	file.playersButton = playersButton
	ToolTipData playersToolTip
	playersToolTip.descText = "Total Player Count"
	Hud_SetToolTipData( playersButton, playersToolTip )
	HudElem_SetRuiArg( playersButton, "icon", $"rui/menu/lobby/friends_icon" )

	var serversButton = Hud_GetChild( menu, "ServersButton" )
	file.serversButton = serversButton
	ToolTipData serversToolTip
	serversToolTip.descText = "Total Server Count"
	Hud_SetToolTipData( serversButton, serversToolTip )
	HudElem_SetRuiArg( serversButton, "icon", $"rui/hud/gamestate/net_latency" )

	var gameMenuButton = Hud_GetChild( menu, "GameMenuButton" )
	file.gameMenuButton = gameMenuButton
	ToolTipData gameMenuToolTip
	gameMenuToolTip.descText = "#GAME_MENU"
	Hud_SetToolTipData( gameMenuButton, gameMenuToolTip )
	HudElem_SetRuiArg( gameMenuButton, "icon", $"rui/menu/lobby/settings_icon" )
	HudElem_SetRuiArg( gameMenuButton, "shortcutText", "%[START|ESCAPE]%" )
	Hud_AddEventHandler( gameMenuButton, UIE_CLICK, GameMenuButton_OnActivate )

	var datacenterButton = Hud_GetChild( menu, "DatacenterButton" )
	file.datacenterButton = datacenterButton
	ToolTipData datacenterTooltip
	datacenterTooltip.descText = "#LOWPOP_DATACENTER_BUTTON"
	Hud_SetToolTipData( datacenterButton, datacenterTooltip )
	HudElem_SetRuiArg( datacenterButton, "icon", $"rui/hud/gamestate/net_latency" )
	Hud_AddEventHandler( datacenterButton, UIE_CLICK, OpenLowPopDialogFromButton )
}


void function OnLobbyMenu_Open()
{
	thread ServerBrowser_RefreshServerListing()

	//ClientCommand( "gameCursor_ModeActive 1" )

	if ( !file.tabsInitialized )
	{
		array<var> panels = GetAllMenuPanels( file.menu )
		foreach ( panel in panels )
			AddTab( file.menu, panel, GetPanelTabTitle( panel ) )

		file.tabsInitialized = true
	}

	if ( uiGlobal.lastMenuNavDirection == MENU_NAV_FORWARD )
	{
		TabData tabData = GetTabDataForPanel( file.menu )
		ActivateTab( tabData, 0 )
	}
	else
	{
		TabData tabData = GetTabDataForPanel( file.menu )
		ActivateTab( tabData, tabData.activeTabIdx )
	}

	UpdateNewnessCallbacks()

	thread UpdateLobbyUI()

	Lobby_UpdatePlayPanelPlaylists()

	AddCallbackAndCallNow_OnGRXOffersRefreshed( OnGRXStateChanged )
	AddCallbackAndCallNow_OnGRXInventoryStateChanged( OnGRXStateChanged )
}


void function OnLobbyMenu_Show()
{
	thread LobbyMenuUpdate()
	RegisterInputs()

	Chroma_Lobby()
}


void function OnLobbyMenu_GetTopLevel()
{
	thread TryRunDialogFlowThread()
}


void function OnLobbyMenu_Hide()
{
	Signal( uiGlobal.signalDummy, "LobbyMenuUpdate" )
	DeregisterInputs()
}


void function OnLobbyMenu_Close()
{
	ClearNewnessCallbacks()
	DeregisterInputs()

	RemoveCallback_OnGRXOffersRefreshed( OnGRXStateChanged )
	RemoveCallback_OnGRXInventoryStateChanged( OnGRXStateChanged )
}


void function OnGRXStateChanged()
{
	bool ready = true //GRX_IsInventoryReady() && GRX_AreOffersReady()

	string bpPanel = "PassPanelV2"

	array<var> panels = [
		GetPanel( "CharactersPanel" ),
		GetPanel( "ArmoryPanel" ),
		//GetPanel( bpPanel ),
		//GetPanel( "StorePanel" ),
	]

	foreach ( var panel in panels )
	{
		SetPanelTabEnabled( panel, ready )
	}

	//if ( ready )
	//{
	//	if ( ShouldShowPremiumCurrencyDialog() )
	//		ShowPremiumCurrencyDialog( false )
	//}
}


void function UpdateNewnessCallbacks()
{
	ClearNewnessCallbacks()

	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.GladiatorTab, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharactersPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.ArmoryTab, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "ArmoryPanel" ) )
	//Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.StoreTab, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "StorePanel" ) )
	file.newnessInitialized = true
}


void function ClearNewnessCallbacks()
{
	if ( !file.newnessInitialized )
		return

	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.GladiatorTab, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharactersPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.ArmoryTab, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "ArmoryPanel" ) )
	//Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.StoreTab, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "StorePanel" ) )
	file.newnessInitialized = false
}


void function UpdateLobbyUI()
{
	if ( file.updatingLobbyUI )
		return

	file.updatingLobbyUI = true

	thread UpdateMatchmakingStatus()

	WaitSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	file.updatingLobbyUI = false
}


void function LobbyMenuUpdate()
{
	Signal( uiGlobal.signalDummy, "LobbyMenuUpdate" )
	EndSignal( uiGlobal.signalDummy, "LobbyMenuUpdate" )
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( true )
	{
		PlayPanelUpdate()
		UpdateCornerButtons()
		UpdateTabs()
		WaitFrame()
	}
}

void function UpdateServerAndPlayerCountButtons()
{
	HudElem_SetRuiArg( file.playersButton, "buttonText", "" + MS_GetPlayerCount() )
	Hud_SetWidth( file.playersButton, Hud_GetBaseWidth( file.playersButton ) * 2 )

	HudElem_SetRuiArg( file.serversButton, "buttonText", "" + MS_GetServerCount() )
	Hud_SetWidth( file.serversButton, Hud_GetBaseWidth( file.serversButton ) * 2 )
}

void function UpdateCornerButtons()
{
	var playPanel = GetPanel( "PlayPanel" )
	bool isPlayPanelActive  = IsTabPanelActive( playPanel )
	var postGameButton      = Hud_GetChild( file.menu, "PostGameButton" )
	bool showPostGameButton = isPlayPanelActive && IsPostGameMenuValid()
	Hud_SetVisible( postGameButton, showPostGameButton )
	if ( showPostGameButton )
		Hud_SetX( postGameButton, Hud_GetBaseX( postGameButton ) )
	else
		Hud_SetX( postGameButton, Hud_GetBaseX( postGameButton ) - Hud_GetWidth( postGameButton ) - Hud_GetBaseX( postGameButton ) )

	Hud_SetVisible( file.newsButton, isPlayPanelActive )
	Hud_SetVisible( file.playersButton, isPlayPanelActive )
	Hud_SetVisible( file.serversButton, isPlayPanelActive )
	Hud_SetVisible( file.gameMenuButton, isPlayPanelActive )

	var accessibilityHint = Hud_GetChild( playPanel, "AccessibilityHint" )
	Hud_SetVisible( accessibilityHint, isPlayPanelActive && IsAccessibilityChatHintEnabled() )

	Hud_SetEnabled( file.gameMenuButton, !IsDialog( GetActiveMenu() ) )

	//int count = GetOnlineFriendCount( false )
	//if ( count > 0 )
	//{
	//	HudElem_SetRuiArg( file.socialButton, "buttonText", "" + count )
	//	Hud_SetWidth( file.socialButton, Hud_GetBaseWidth( file.socialButton ) * 2 )
	//	InitButtonRCP( file.socialButton )
	//}
	//else
	//{
	//	HudElem_SetRuiArg( file.socialButton, "buttonText", "" )
	//	Hud_ReturnToBaseSize( file.socialButton )
	//	InitButtonRCP( file.socialButton )
	//}

	{
		bool datacenterButtonVisible = false
		if ( Lobby_GetSelectedPlaylist() != "" && IsFullyConnected() )
		{
			bool lowPop = IsLowPopPlaylist( Lobby_GetSelectedPlaylist() )
			bool sameDC = GetCurrentMatchmakingDatacenterETA( Lobby_GetSelectedPlaylist() ).datacenterIdx == GetCurrentRankedMatchmakingDatacenterETA( Lobby_GetSelectedPlaylist() ).datacenterIdx
			datacenterButtonVisible = isPlayPanelActive && lowPop && !sameDC && !AreWeMatchmaking()
		}

		Hud_SetVisible( file.datacenterButton, datacenterButtonVisible )
	}
}


void function UpdateTabs()
{
	if ( IsFullyConnected() )
	{
		//
	} // todo(dw)
}


void function RegisterInputs()
{
	if ( file.inputsRegistered )
		return

	RegisterButtonPressedCallback( BUTTON_START, GameMenuButton_OnActivate )
	RegisterButtonPressedCallback( BUTTON_BACK, PostGameButton_OnActivate )
	RegisterButtonPressedCallback( KEY_TAB, PostGameButton_OnActivate )
	RegisterButtonPressedCallback( KEY_ENTER, OnLobbyMenu_FocusChat )
	RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, NewsButton_OnActivate )
	//RegisterButtonPressedCallback( BUTTON_STICK_RIGHT, SocialButton_OnActivate )
	file.inputsRegistered = true
}


void function DeregisterInputs()
{
	if ( !file.inputsRegistered )
		return

	DeregisterButtonPressedCallback( BUTTON_START, GameMenuButton_OnActivate )
	DeregisterButtonPressedCallback( BUTTON_BACK, PostGameButton_OnActivate )
	DeregisterButtonPressedCallback( KEY_TAB, PostGameButton_OnActivate )
	DeregisterButtonPressedCallback( KEY_ENTER, OnLobbyMenu_FocusChat )
	DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, NewsButton_OnActivate )
	//DeregisterButtonPressedCallback( BUTTON_STICK_RIGHT, SocialButton_OnActivate )
	file.inputsRegistered = false
}


void function NewsButton_OnActivate( var button )
{
	if ( !IsPromoDialogAllowed() )
		return

	if ( !IsTabPanelActive( GetPanel( "PlayPanel" ) ) )
		return

	AdvanceMenu( GetMenu( "R5RNews" ) )
}


void function SocialButton_OnActivate( var button )
{
	if ( IsDialog( GetActiveMenu() ) )
		return

	if ( !IsTabPanelActive( GetPanel( "PlayPanel" ) ) )
		return

	#if PC_PROG
		if ( !MeetsAgeRequirements() )
		{
			ConfirmDialogData dialogData
			dialogData.headerText = "#UNAVAILABLE"
			dialogData.messageText = "#ORIGIN_UNDERAGE_ONLINE"
			dialogData.contextImage = $"ui/menu/common/dialog_notice"

			OpenOKDialogFromData( dialogData )
			return
		}
	#endif

	AdvanceMenu( GetMenu( "SocialMenu" ) )
}

void function DCButton_OnActivate( var button )
{
	if ( IsDialog( GetActiveMenu() ) )
		return

	if ( !IsTabPanelActive( GetPanel( "PlayPanel" ) ) )
		return

	LaunchExternalWebBrowser( "https://discord.gg/8nYYzSvf", WEBBROWSER_FLAG_NONE )
}

void function BlogButton_OnActivate( var button )
{
	if ( IsDialog( GetActiveMenu() ) )
		return

	if ( !IsTabPanelActive( GetPanel( "PlayPanel" ) ) )
		return

	LaunchExternalWebBrowser( "https://blog.playvalkyrie.org", WEBBROWSER_FLAG_NONE )
}

void function GameMenuButton_OnActivate( var button )
{
	if ( InputIsButtonDown( BUTTON_STICK_LEFT ) ) // Avoid bug report shortcut
		return

	if ( IsDialog( GetActiveMenu() ) )
		return

	AdvanceMenu( GetMenu( "SystemMenu" ) )
}


void function PostGameButton_OnActivate( var button )
{
	if ( IsDialog( GetActiveMenu() ) )
		return

	if ( !IsTabPanelActive( GetPanel( "PlayPanel" ) ) )
		return

	thread OnLobbyMenu_PostGameOrChat( button )
}


void function OnLobbyMenu_NavigateBack()
{
	if ( GetMenuActiveTabIndex( file.menu ) == 0 )
	{
		if ( !IsControllerModeActive() )
			AdvanceMenu( GetMenu( "SystemMenu" ) )
	}
	else
	{
		if(pmatch_MenuOpen)
			return
			
		TabData tabData = GetTabDataForPanel( file.menu )
		ActivateTab( tabData, 0 )
	}
}


void function OnLobbyMenu_PostGameOrChat( var button )
{
	var savedMenu = GetActiveMenu()

	#if CONSOLE_PROG
		const float HOLD_FOR_CHAT_DELAY = 1.0
		float startTime = Time()
		while ( InputIsButtonDown( BUTTON_BACK ) || InputIsButtonDown( KEY_TAB ) && GetConVarInt( "hud_setting_accessibleChat" ) != 0 )
		{
			if ( Time() - startTime > HOLD_FOR_CHAT_DELAY )
			{
				if ( GetPartySize() > 1 )
				{
					printt( "starting message mode", Hud_IsEnabled( GetLobbyChatBox() ) )
					Hud_StartMessageMode( GetLobbyChatBox() )
				}
				else
				{
					ConfirmDialogData dialogData
					dialogData.headerText = "#ACCESSIBILITY_NO_CHAT_HEADER"
					dialogData.messageText = "#ACCESSIBILITY_NO_CHAT_MESSAGE"
					dialogData.contextImage = $"ui/menu/common/dialog_notice"

					OpenOKDialogFromData( dialogData )
				}
				return
			}

			WaitFrame()
		}
	#endif

	if ( IsPostGameMenuValid() && savedMenu == GetActiveMenu() )
	{
		{
			thread PostGameFlow()
		}
	}
}


void function PostGameFlow()
{
	bool showRankedSummary = GetPersistentVarAsInt( "showRankedSummary" ) != 0
	bool isFirstTime       = GetPersistentVarAsInt( "showGameSummary" ) != 0

	OpenPostGameMenu( null )

	if ( GetActiveBattlePass() != null )
	{
		OpenPostGameBattlePassMenu( isFirstTime )
	}

	if ( showRankedSummary )
		OpenRankedSummary( isFirstTime )
}


void function OnLobbyMenu_FocusChat( var panel )
{
	#if PC_PROG
		if ( IsDialog( GetActiveMenu() ) )
			return

		if ( !IsTabPanelActive( GetPanel( "PlayPanel" ) ) )
			return

		if ( GetPartySize() > 1 )
		{
			var playPanel = Hud_GetChild( file.menu, "PlayPanel" )
			var textChat  = Hud_GetChild( playPanel, "ChatRoomTextChat" )
			Hud_SetFocused( Hud_GetChild( textChat, "ChatInputLine" ) )
		}
	#endif
}

string function GetUIPlaylistName(string playlist)
{
	if(!IsLobby() || !IsConnected())
		return ""

	return GetPlaylistVarString( playlist, "name", playlist )
}

string function GetUIMapName(string map)
{
	if(map in MapNames)
		return MapNames[map]

	return map
}

string function GetUIVisibilityName(int vis)
{
	if(vis in VisibilityNames)
		return VisibilityNames[vis]

	return ""
}

asset function GetUIMapAsset(string map, bool gamemode_assets = false)
{
	if(map in MapAssets && !gamemode_assets)
		return MapAssets[map]

	if(map in MapAssetsSquare && gamemode_assets)
		return MapAssetsSquare[map]

	if(gamemode_assets)
		return $"rui/menu/maps/map_not_found_square_icon"

	return $"rui/menu/maps/map_not_found_big_icon"
}