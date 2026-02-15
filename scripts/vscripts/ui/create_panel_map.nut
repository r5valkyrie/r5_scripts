global function InitR5RMapPanel
global function RefreshUIMaps

struct
{
	var menu
	var panel
	var listPanel
	table<var, string> map_button_table
} file

void function InitR5RMapPanel( var panel )
{
	file.panel = panel
	file.menu = GetPanel( "CreatePanel" )

	file.listPanel = Hud_GetChild( panel, "MapList" )
}

void function RefreshUIMaps()
{
	var scrollPanel = Hud_GetChild( file.listPanel, "ScrollPanel" )

	array<string> availableMapsForPlaylist = GetPlaylistMaps(ServerSettings.svPlaylist)
	Hud_InitGridButtons( file.listPanel, availableMapsForPlaylist.len() )
	
	foreach ( int id, string map in availableMapsForPlaylist )
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + id )
        var rui = Hud_GetRui( button )
	    RuiSetString( rui, "buttonText", GetUIMapName(map) )

		// If the button has not already had its event handlers registered, add them!
		if ( !( button in file.map_button_table ) )
		{
			// Add button event handlers
			Hud_AddEventHandler( button, UIE_CLICK, SelectServerMap )
			Hud_AddEventHandler( button, UIE_GET_FOCUS, OnMapHover )
			Hud_AddEventHandler( button, UIE_LOSE_FOCUS, OnMapUnHover )

			// Store the map name that corresponds with this button
			// so that we can skip adding event handlers on future calls
			file.map_button_table[button] <- map
		}
	}

	Hud_SetHeight(Hud_GetChild(file.panel, "PanelBG"), Hud_GetHeight(file.listPanel) + 1)
}

void function SelectServerMap( var button )
{
	//Set selected server map
	EmitUISound( "menu_accept" )
	SetSelectedServerMap(file.map_button_table[button])
}

void function OnMapHover( var button )
{
	RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "ServerMapImg" ) ), "loadscreenImage", GetUIMapAsset( file.map_button_table[button] ) )
}

void function OnMapUnHover( var button )
{
	RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "ServerMapImg" ) ), "loadscreenImage", GetUIMapAsset( ServerSettings.svMapName ) )
}