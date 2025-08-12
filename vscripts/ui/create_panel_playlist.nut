global function InitR5RPlaylistPanel
global function RefreshUIPlaylists

struct
{
	var menu
	var panel
	var listPanel

	table<var, string> playlist_button_table
} file

void function InitR5RPlaylistPanel( var panel )
{
	file.panel = panel
	file.menu = GetPanel( "CreatePanel" )
	file.listPanel = Hud_GetChild( panel, "PlaylistList" )
}

void function RefreshUIPlaylists()
{
	var scrollPanel = Hud_GetChild( file.listPanel, "ScrollPanel" )

	array<string> visiblePlaylists = GetVisiblePlaylists()
	Hud_InitGridButtons( file.listPanel, visiblePlaylists.len() )

	foreach ( int id, string playlist in visiblePlaylists )
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + id )
        var rui = Hud_GetRui( button )
	    RuiSetString( rui, "buttonText", GetUIPlaylistName(playlist) )

		// If the button has not already had its event handlers registered, add them!
		if ( !( button in file.playlist_button_table ) )
		{
			// Add button event handlers
			Hud_AddEventHandler( button, UIE_CLICK, SelectServerPlaylist )
			Hud_AddEventHandler( button, UIE_GET_FOCUS, OnPlaylistHover )
			Hud_AddEventHandler( button, UIE_LOSE_FOCUS, OnPlaylistUnHover )

			// Store the playlist name that corresponds with this button
			// so that we can skip adding event handlers on future calls
			file.playlist_button_table[button] <- playlist
		}
	}

	Hud_SetHeight(Hud_GetChild(file.panel, "PanelBG"), Hud_GetHeight(file.listPanel) + 1)
}

array<string> function GetVisiblePlaylists()
{
	array<string> visiblePlaylists

	//Setup available playlists array
	foreach( string playlist in GetAvailablePlaylists())
	{
		//Check playlist visibility
		if(!GetPlaylistVarBool( playlist, "visible", false ))
			continue

		//Add playlist to the array
		visiblePlaylists.append(playlist)
	}

	return visiblePlaylists
}

void function SelectServerPlaylist( var button )
{
	//Set selected server playlist
	EmitUISound( "menu_accept" )
	thread SetSelectedServerPlaylist(file.playlist_button_table[button])
}

void function OnPlaylistHover( var button )
{
	Hud_SetText(Hud_GetChild( file.menu, "PlaylistInfoEdit" ), GetUIPlaylistName( file.playlist_button_table[button] ) )
}

void function OnPlaylistUnHover( var button )
{
	Hud_SetText(Hud_GetChild( file.menu, "PlaylistInfoEdit" ), GetUIPlaylistName( ServerSettings.svPlaylist ) )
}