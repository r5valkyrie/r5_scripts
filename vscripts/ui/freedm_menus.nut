global function SetRespawnOverlayTime
global function SetRespawnOverlayString
global function SetRespawnOverlayIdleString
global function TDM_ShowScoreboard
global function TDM_HideScoreboard
global function LoadoutSelectionMenu_ResetLoadoutButtons
global function ClientToUI_LoadoutSelectionOptics_OpenSelectOpticDialog

struct
{
	float respawnStartTime = 0.0
	float respawnEndTime = 0.0
	string respawnString = ""
	string respawnIdleString = ""
} file

void function SetRespawnOverlayTime( float startTime, float endTime )
{
	file.respawnStartTime = startTime
	file.respawnEndTime = endTime
}

void function SetRespawnOverlayString( string text )
{
	file.respawnString = text
}

void function SetRespawnOverlayIdleString( string text )
{
	file.respawnIdleString = text
}

void function TDM_ShowScoreboard()
{
	// TDM scoreboard menu — UI panels not yet ported
}

void function TDM_HideScoreboard()
{
	// TDM scoreboard menu — UI panels not yet ported
}

void function LoadoutSelectionMenu_ResetLoadoutButtons()
{
	// Called after LoadoutSelection_UpdateLoadoutInfo_UI pushes all loadout data
	// Refresh/rebuild the loadout menu button elements — not yet ported
}

void function ClientToUI_LoadoutSelectionOptics_OpenSelectOpticDialog( int loadoutIndex )
{
	// Optic picker dialog — UI panels not yet ported
}
