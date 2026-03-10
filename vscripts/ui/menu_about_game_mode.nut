global function InitAboutGameModeMenu
global function OpenAboutGameModePage

struct
{
	var menu

	var aboutElem

} file

void function InitAboutGameModeMenu( var newMenuArg )                                               
{
	var menu = newMenuArg
	file.menu = newMenuArg
    
	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnAboutGameModeMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnAboutGameModeMenu_Close )

	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnAboutGameModeMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, OnAboutGameModeMenu_Hide )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )

	file.aboutElem = Hud_GetChild( newMenuArg, "AboutText" )
}

void function OpenAboutGameModePage( var button )
{
	AdvanceMenu( file.menu )
}

void function FocusAboutForScrolling( ... )
{
	if( !Hud_IsFocused( file.aboutElem ) )
		Hud_SetFocused( file.aboutElem )
}

void function OnAboutGameModeMenu_Open()
{
	var rui = Hud_GetRui( Hud_GetChild( file.menu, "InfoMain" ) )
	UISize screenSize = GetScreenSize()
	RuiSetFloat2( rui, "actualRes", < screenSize.width, screenSize.height, 0 > )

	string playlist = Lobby_GetSelectedPlaylist()

	// Emblem color - R5Valkyrie blue/purple theme fallback
	array<int> emblemColor = GetEmblemColor( playlist )
	if ( emblemColor[0] == 128 && emblemColor[1] == 128 && emblemColor[2] == 128 ) // default grey = no playlist color set
		emblemColor = [100, 140, 230, 255]
	RuiSetColorAlpha( rui, "emblemColor", SrgbToLinear( <emblemColor[0],emblemColor[1],emblemColor[2]> / 255.0 ), emblemColor[3] / 255.0 )

	// Mode emblem image - use survival emblem as fallback
	asset modeImage = GetModeEmblemImage( playlist )
	if ( modeImage == $"" )
		modeImage = $"rui/menu/gamemode/survival"
	RuiSetImage( rui, "modeImage", modeImage )

	// Title
	string aboutTitle = GetPlaylistVarString( playlist, "survival_takeover_name", GetPlaylistVarString( playlist, "name", "" ) )
	if ( aboutTitle == "" )
		aboutTitle = "R5Valkyrie"
	RuiSetString( rui, "aboutTitle", aboutTitle )

	// Body text (RichText panel)
	string aboutText = GetPlaylistVarString( playlist, "about_text", "" )
	if ( aboutText == "" )
		aboutText = "Welcome to R5Valkyrie!\n\nThis is a custom server running on the cafe-r5sdk.\n\nYou can edit this text in:\nmenu_about_game_mode.nut\n\nOr set the playlist var 'about_text' to change it dynamically."
	Hud_SetText( file.aboutElem, aboutText )
}

void function OnAboutGameModeMenu_Close()
{

}

void function OnAboutGameModeMenu_Show()
{
	RegisterStickMovedCallback( ANALOG_RIGHT_Y, FocusAboutForScrolling )
}

void function OnAboutGameModeMenu_Hide()
{
	DeregisterStickMovedCallback( ANALOG_RIGHT_Y, FocusAboutForScrolling )
}