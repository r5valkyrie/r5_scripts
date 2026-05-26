global function InitKillReplayHud
global function OpenKillReplayHud
global function CloseKillReplayHud
global function ReplayHud_UpdatePlayerData
global function UI_FlowstateCustomSetSpectateTargetCount

struct
{
	var menu
    int basehealthwidth
    int basesheildwidth
	int spectateTargetCount
	string spectatorTarget
	int currentSpectateTarget = 1
	bool ObserverReverse
} file

void function OpenKillReplayHud(asset image, string killedby, int tier, bool islocalclient, bool isProphunt)
{

}

void function ReplayHud_UpdatePlayerData(float health, float sheild, int tier, string name, asset image)
{
    Hud_SetWidth( Hud_GetChild( file.menu, "PlayerSheild" + tier ), file.basesheildwidth * sheild )
    Hud_SetWidth( Hud_GetChild( file.menu, "PlayerHealth" ), file.basehealthwidth * health )
	Hud_SetText( Hud_GetChild( file.menu, "KillReplayPlayerName" ), name)
	RuiSetImage(Hud_GetRui(Hud_GetChild(file.menu, "PlayerImage")), "basicImage", image)
}

void function CloseKillReplayHud(bool isProphunt)
{

}

void function InitKillReplayHud( var newMenuArg )
{
	var menu = GetMenu( "KillReplayHud" )
	file.menu = menu

    file.basehealthwidth = Hud_GetWidth( Hud_GetChild( file.menu, "PlayerHealth" ) )
    file.basesheildwidth = Hud_GetWidth( Hud_GetChild( file.menu, "PlayerSheild1" ) )

	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, On_NavigateBack )
}

void function UI_FlowstateCustomSetSpectateTargetCount( int targetCount, bool reverse )
{
	file.ObserverReverse = reverse
	file.spectateTargetCount = targetCount
}

bool function FlowstateCustomCanChangeSpectateTarget()
{
	return file.spectateTargetCount	> 1
}
void function SpecNext( var panel )
{
	printt("trying to change spectate target. Max Targets " + file.spectateTargetCount + " | Target Count " + file.currentSpectateTarget )
	ClientCommand( "spec_next" )
}

void function SpecPrev( var panel )
{
	ClientCommand( "spec_prev" )
}

void function FocusChat( var panel )
{
	if(!Hud_IsFocused( Hud_GetChild( Hud_GetChild( file.menu, "KillReplayChatBox"), "ChatInputLine" ) ))
	{
		Hud_StartMessageMode( Hud_GetChild( file.menu, "KillReplayChatBox") )
		Hud_SetEnabled( Hud_GetChild( Hud_GetChild( file.menu, "KillReplayChatBox"), "ChatInputLine" ), true)
		Hud_SetVisible( Hud_GetChild( Hud_GetChild( file.menu, "KillReplayChatBox"), "ChatInputLine" ), true )
		Hud_SetFocused( Hud_GetChild( Hud_GetChild( file.menu, "KillReplayChatBox"), "ChatInputLine" ) )
	} 
}

void function On_NavigateBack()
{
	// Needs to be here so people cant close the menu
}