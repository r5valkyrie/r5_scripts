untyped

//global function InitLobbyStartMenu
global function InitInGameMPMenu
global function ServerCallback_UI_ObjectiveUpdated
global function SP_ResetObjectiveStringIndex
global function SCB_SetDoubleXPStatus

global function UI_SetPlayerRunningGauntlet

struct
{
	var menuMP
	var menuSP
	var BtnTrackedChallengeBackground
	var BtnTrackedChallengeTitle
	array trackedChallengeButtons
	var BtnLastCheckpoint
	int objectiveStringIndex
	var settingsHeader
	var faqButton
	int titanHeaderIndex
	var titanHeader
	var titanSelectButton
	var titanEditButton
	bool playerRunningGauntlet

	var loadoutHeaderPilot
	array<var> loadoutButtonsPilot
	var loadoutHeaderTitan
	array<var> loadoutButtonsTitan

	//var pilotEditButton
} file

void function InitInGameMPMenu( var newMenuArg )
{
	var menu = GetMenu( "InGameMPMenu" )
	file.menuMP = menu

	SP_ResetObjectiveStringIndex()

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnInGameMPMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnInGameMPMenu_Close )

	AddUICallback_OnLevelInit( OnInGameLevelInit )
	AddMenuFooterOption( menu, LEFT, BUTTON_A, true, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#CLOSE" )
}

void function PilotLoadoutsSelectOnClick( var button )
{
	AdvanceMenu( GetMenu( "PilotLoadoutsMenu" ) )
}

void function OnInGameMPMenu_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	bool faqIsNew = !GetConVarBool( "menu_faq_viewed" ) || HaveNewPatchNotes() || HaveNewCommunityNotes()
	RuiSetBool( Hud_GetRui( file.settingsHeader ), "isNew", faqIsNew )
	UpdateLoadoutButtons()
}

void function OnInGameMPMenu_Close()
{
	UI_SetPresentationType( ePresentationType.INACTIVE )

	if ( IsConnected() && !IsLobby() )
	{
		//printt( "OnInGameMPMenu_Close() uiGlobal.updatePilotSpawnLoadout is:", uiGlobal.updatePilotSpawnLoadout )
		//printt( "OnInGameMPMenu_Close() uiGlobal.updateTitanSpawnLoadout is:", uiGlobal.updateTitanSpawnLoadout )

		string updatePilotSpawnLoadout = uiGlobal.updatePilotSpawnLoadout ? "1" : "0"
		string updateTitanSpawnLoadout = uiGlobal.updateTitanSpawnLoadout ? "1" : "0"

		ClientCommand( "InGameMPMenuClosed " + updatePilotSpawnLoadout + " " + updateTitanSpawnLoadout )

		uiGlobal.updatePilotSpawnLoadout = false
		uiGlobal.updateTitanSpawnLoadout = false

		//RunClientScript( "RefreshIntroLoadoutDisplay", GetLocalClientPlayer(), uiGlobal.pilotSpawnLoadoutIndex, uiGlobal.titanSpawnLoadoutIndex )
	}
}

struct
{
	var loadoutHeader
	array<var> loadoutButtons

	var titansHeader
	array<var> titansButtons

	var inventoryHeader
	array<var> inventoryButtons

	var leaveHeader
	array<var> leaveButtons
} s_pauseMenu

void function UpdateLoadoutButtons()
{
	/*int headerIndex = 0
	int buttonIndex = 0
	var pilotHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_PILOT" )
	file.loadoutHeaderPilot = pilotHeader
	var pilotSelectButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#SELECT" )
	Hud_AddEventHandler( pilotSelectButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "PilotLoadoutsMenu" ) ) )
	file.loadoutButtonsPilot.append( pilotSelectButton )
	var pilotEditButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#EDIT" )
	Hud_AddEventHandler( pilotEditButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditPilotLoadoutsMenu" ) ) )
	file.loadoutButtonsPilot.append( pilotEditButton )*/

	bool pilotLoadoutsEnabled = (GetCurrentPlaylistVarInt( "pilot_loadout_selection_enabled", 0 ) == 1)

	foreach ( button in file.loadoutButtonsPilot )
		Hud_SetEnabled( button, pilotLoadoutsEnabled )

	SetTitanSelectButtonVisibleState( true )

	if ( pilotLoadoutsEnabled )
		Hud_Show( file.loadoutHeaderPilot )
	else
		Hud_Hide( file.loadoutHeaderPilot )

	bool useSurvivalLoadouts = (GetCurrentPlaylistVarInt( "survial_loadouts_enabled", 1 ) == 1)

	//if ( useSurvivalLoadouts )
	//{
	//	ComboButton_SetText( file.pilotEditButton, "" )
	//	Hud_SetEnabled( file.pilotEditButton, false )
	//}
	//else
	//{
	//	ComboButton_SetText( file.pilotEditButton, "#EDIT" )
	//	Hud_SetEnabled( file.pilotEditButton, true )
	//}

	//
	{
		bool titanLoadoutsEnabled = (GetCurrentPlaylistVarInt( "titan_loadout_selection_enabled", 0 ) == 1)

		foreach ( button in file.loadoutButtonsTitan )
			Hud_SetEnabled( button, titanLoadoutsEnabled )

		if ( titanLoadoutsEnabled )
			Hud_Show( file.loadoutHeaderTitan )
		else
			Hud_Hide( file.loadoutHeaderTitan )
	}
}

//////////

//////////


void function PROTO_SetPauseMenuWorldMap()
{
	var elem = Hud_GetChild( file.menuSP, "PROTO_WorldMapImage" )
	//array<var> elems = GetElementsByClassname( file.menuSP, "PROTO_WorldMap" )
	//var elem = elems[0]

	var titleElem = Hud_GetChild( file.menuSP, "ObjectivesTitle" )

	array<var> overlapElems
	overlapElems.append( Hud_GetChild( file.menuSP, "MissionLogDesc" ) )
	overlapElems.append( Hud_GetChild( file.menuSP, "CollectiblesTitle" ) )
	overlapElems.append( Hud_GetChild( file.menuSP, "CollectiblesIcon" ) )
	overlapElems.append( Hud_GetChild( file.menuSP, "CollectiblesFoundDesc" ) )

	elem.Hide()

	Hud_SetText( titleElem, "#MENU_SP_OBJECTIVES_TITLE" )

	foreach ( overlapElem in overlapElems )
		Hud_Show( overlapElem )
}

void function OnLeaveButton_Activate( var button )
{
	LeaveDialog()
}

void function OnResumeGame_Activate( var button )
{
	CloseActiveMenu()
}

void function SP_ResetObjectiveStringIndex()
{
	file.objectiveStringIndex = -1
}

void function ServerCallback_UI_ObjectiveUpdated( int stringIndex )
{
	file.objectiveStringIndex = stringIndex
}

void function SCB_SetDoubleXPStatus( int status )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	RuiSetInt( Hud_GetRui( doubleXPWidget ), "doubleXPStatus", status )
}

void function OnInGameLevelInit()
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )
	RuiSetInt( rui, "doubleXPStatus", 0 )
	RuiSetBool( rui, "isVisible", false )

	Hud_SetVisible( doubleXPWidget, !IsPrivateMatch() )
}

void function TitanSelectButtonHandler( var button )
{
	//if ( !IsFullyConnected() )
	//	return
	//
	//entity player = GetUIPlayer()
	//if ( GetAvailableTitanRefs( player ).len() > 1 )
	//{
	//	AdvanceMenu( GetMenu( "TitanLoadoutsMenu" ) )
	//}
	//else if ( GetAvailableTitanRefs( player ).len() == 1 )
	//{
	//	uiGlobal.updateTitanSpawnLoadout = false
	//	SetEditLoadout( "titan", uiGlobal.titanSpawnLoadoutIndex )
	//
	//	RunMenuClientFunction( "SetEditingTitanLoadoutIndex", uiGlobal.titanSpawnLoadoutIndex )
	//	AdvanceMenu( GetMenu( "EditTitanLoadoutMenu" ) )
	//}
	//else
	//{
	//	// HIDE
	//}
}

void function SetTitanSelectButtonVisibleState( bool state )
{
	if ( state )
	{
		Hud_Show( file.titanHeader )
		Hud_Show( file.titanEditButton )
		Hud_Show( file.titanSelectButton )
	}
	else
	{
		Hud_Hide( file.titanHeader )
		Hud_Hide( file.titanEditButton )
		Hud_Hide( file.titanSelectButton )
	}
}

void function UI_SetPlayerRunningGauntlet( bool playerRunningGauntlet )
{
	file.playerRunningGauntlet = playerRunningGauntlet
}
