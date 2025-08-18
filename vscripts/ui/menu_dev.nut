untyped

global function InitDevMenu
global function DEV_InitLoadoutDevSubMenu
global function SetupDevCommand // for dev
global function SetupDevFunc // for dev
global function SetupDevMenu
global function RepeatLastDevCommand
global function UpdatePrecachedSPWeapons
global function ServerCallback_OpenDevMenu
global function RunCodeDevCommandByAlias
global function DEV_ExecBoundDevMenuCommand
global function DEV_InitCodeDevMenu
global function UpdateCheatsState
global function AddLevelDevCommand
global function ChangeToThisMenu
global function UpdateDevMenuButtons
global function OnDevButton_Activate
global function OnDevButton_GetFocus
global function OnDevButton_LoseFocus
global function BackOnePage_Activate
global function RepeatLastCommand_Activate
global function BindCommandToGamepad_Activate
global function ClearCodeDevMenu
global function PushPageHistory

global function AddUICallback_OnDevMenuLoaded
global function GetCheatsState

const string DEV_MENU_NAME = "[LEVEL]"

struct DevMenuPage
{
	void functionref()      devMenuFunc
	void functionref( var ) devMenuFuncWithOpParm
	var                     devMenuOpParm
}

struct DevCommand
{
	string                  label
	string                  command
	var                     opParm
	void functionref( var ) func
	bool                    isAMenuCommand = false
}


struct
{
	array<DevMenuPage> pageHistory = []
	DevMenuPage &      currentPage
	var                header
	array<var>         buttons
	array<table>       actionBlocks
	array<DevCommand>  devCommands
	DevCommand&        lastDevCommand
	bool               lastDevCommandAssigned
	string             lastDevCommandLabel
	string             lastDevCommandLabelInProgress
	bool               precachedWeapons

	DevCommand& focusedCmd
	bool        focusedCmdIsAssigned

	DevCommand boundCmd
	bool       boundCmdIsAssigned

	var footerHelpTxtLabel

	bool                      initializingCodeDevMenu = false
	string                    codeDevMenuPrefix = DEV_MENU_NAME + "/"
	table<string, DevCommand> codeDevMenuCommands
	
	array<void functionref()>                   OnDevMenuLoaded

	array<DevCommand> levelSpecificCommands = []
	bool cheatsState
} file

void function AddUICallback_OnDevMenuLoaded( void functionref() callback ) //(cafe) New callback to add dev menu entries from mods
{
	if(file.OnDevMenuLoaded.contains(callback))
		return
	
	file.OnDevMenuLoaded.append( callback )
}

function Dummy_Untyped( param )
{

}

void function UpdateCheatsState(bool cheatsState)
{
	file.cheatsState = cheatsState
}

bool function GetCheatsState()
{
	return file.cheatsState
}


void function InitDevMenu( var newMenuArg )
{
		var menu = GetMenu( "DevMenu" )

		AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenDevMenu )

		file.header = Hud_GetChild( menu, "MenuTitle" )
		file.buttons = GetElementsByClassname( menu, "DevButtonClass" )
		foreach ( button in file.buttons )
		{
			Hud_AddEventHandler( button, UIE_CLICK, OnDevButton_Activate )
			Hud_AddEventHandler( button, UIE_GET_FOCUS, OnDevButton_GetFocus )
			Hud_AddEventHandler( button, UIE_GET_FOCUS, OnDevButton_LoseFocus )

			RuiSetString( Hud_GetRui( button ), "buttonText", "" )
			Hud_SetEnabled( button, false )
		}

		AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "%[B_BUTTON|]% Back", "Back" )
		AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, BackOnePage_Activate )
		AddMenuFooterOption( menu, LEFT, BUTTON_Y, true, "%[Y_BUTTON|]% Repeat Last Dev Command:", "Repeat Last Dev Command:", RepeatLastCommand_Activate )
		AddMenuFooterOption( menu, LEFT, BUTTON_BACK, true, "%[BACK|]% Bind Selection to Gamepad", "", BindCommandToGamepad_Activate )
		file.footerHelpTxtLabel = GetElementsByClassname( menu, "FooterHelpTxt" )[0]

		RegisterSignal( "DEV_InitCodeDevMenu" )
		AddUICallback_LevelLoadingFinished( DEV_InitCodeDevMenu )
		AddUICallback_LevelShutdown( ClearCodeDevMenu )
		//OnOpenDevMenu()
}


void function AddLevelDevCommand( string label, string command )
{
		string codeDevMenuAlias = DEV_MENU_NAME + "/" + label
		DevMenu_Alias_DEV( codeDevMenuAlias, command )

		DevCommand cmd
		cmd.label = label
		cmd.command = command
		file.levelSpecificCommands.append( cmd )
}

void function OnOpenDevMenu()
{
	file.pageHistory.clear()
	file.currentPage.devMenuFunc = null
	file.currentPage.devMenuFuncWithOpParm = null
	file.currentPage.devMenuOpParm = null
	file.lastDevCommandLabelInProgress = ""

	SetDevMenu_MP()

	//DelayedFocusFirstButton()
}


//void function DelayedFocusFirstButton()
//{
//	//Hud_SetFocused( file.buttons[0] )
//	//Hud_SetSelected( file.buttons[0], true )
//	//vector screenSize = <GetScreenSize().width, GetScreenSize().height, 0>
//	vector buttonPos = <Hud_GetAbsX( file.buttons[0] ), Hud_GetAbsY( file.buttons[1] ), 0>
//	buttonPos += 0.5 * <Hud_GetWidth( file.buttons[0] ), -1 * Hud_GetHeight( file.buttons[0] ), 0>
//	WarpMouseCursorDEV( <buttonPos.x, buttonPos.y, 0> )
//}


void function ServerCallback_OpenDevMenu()
{
	AdvanceMenu( GetMenu( "DevMenu" ) )
}


void function DEV_InitCodeDevMenu()
{
	thread DEV_InitCodeDevMenu_Internal()
}


void function DEV_InitCodeDevMenu_Internal()
{
	Signal( uiGlobal.signalDummy, "DEV_InitCodeDevMenu" )
	EndSignal( uiGlobal.signalDummy, "DEV_InitCodeDevMenu" )

	while ( !IsFullyConnected() || !IsItemFlavorRegistrationFinished() )
	{
		WaitFrame()
	}

	file.initializingCodeDevMenu = true
	DevMenu_Alias_DEV( DEV_MENU_NAME, "" )
	DevMenu_Rm_DEV( DEV_MENU_NAME )
	OnOpenDevMenu()
	file.initializingCodeDevMenu = false
}


void function ClearCodeDevMenu()
{
	DevMenu_Alias_DEV( DEV_MENU_NAME, "" )
	DevMenu_Rm_DEV( DEV_MENU_NAME )
}


void function UpdateDevMenuButtons()
{
	file.devCommands.clear()

	if ( file.initializingCodeDevMenu )
		return

	// Title:
	{
		string titleText = file.lastDevCommandLabelInProgress
		if ( titleText == "" )
			titleText = ("Developer Menu    -    " + GetActiveLevel())
		Hud_SetText( file.header, titleText )
	}

	if ( file.currentPage.devMenuOpParm != null )
		file.currentPage.devMenuFuncWithOpParm( file.currentPage.devMenuOpParm )
	else
		file.currentPage.devMenuFunc()

	foreach ( index, button in file.buttons )
	{
		int buttonID = int( Hud_GetScriptID( button ) )

		if ( buttonID < file.devCommands.len() )
		{
			RuiSetString( Hud_GetRui( button ), "buttonText", file.devCommands[buttonID].label )
			Hud_SetEnabled( button, true )
		}
		else
		{
			RuiSetString( Hud_GetRui( button ), "buttonText", "" )
			Hud_SetEnabled( button, false )
		}

		if ( buttonID == 0 )
			Hud_SetFocused( button )
	}

	RefreshRepeatLastDevCommandPrompts()
}

void function SetDevMenu_MP()
{
	if ( file.initializingCodeDevMenu )
	{
		SetupDefaultDevCommandsMP()
		return
	}
	PushPageHistory()
	file.currentPage.devMenuFunc = SetupDefaultDevCommandsMP
	UpdateDevMenuButtons()
}


void function ChangeToThisMenu( void functionref() menuFunc )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFunc()
		return
	}
	PushPageHistory()
	file.currentPage.devMenuFunc = menuFunc
	file.currentPage.devMenuFuncWithOpParm = null
	file.currentPage.devMenuOpParm = null
	UpdateDevMenuButtons()
}


void function ChangeToThisMenu_WithOpParm( void functionref( var ) menuFuncWithOpParm, opParm = null )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFuncWithOpParm( opParm )
		return
	}

	PushPageHistory()
	file.currentPage.devMenuFunc = null
	file.currentPage.devMenuFuncWithOpParm = menuFuncWithOpParm
	file.currentPage.devMenuOpParm = opParm
	UpdateDevMenuButtons()
}

const array<int> allowedWeaponChangeModes = [

	ePlaylists.fs_dm,
	ePlaylists.fs_1v1,
	ePlaylists.fs_lgduels_1v1,
	ePlaylists.fs_realistic_ttv
]

void function SetupDefaultDevCommandsMP()
{
	//Player is fully connected at this point, a check was made before
	RunClientScript("DEV_SendCheatsStateToUI")

	foreach ( callback in file.OnDevMenuLoaded )
		callback()
	
	if( allowedWeaponChangeModes.contains( Playlist() ) )
	{
		SetupDevMenu( "FSDM: Change Primary weapon", SetDevMenu_TDMPrimaryWeapons )
		SetupDevMenu( "FSDM: Change Secondary weapon", SetDevMenu_TDMSecondaryWeapons )
		SetupDevCommand( "FSDM: Save Current Weapons", "saveguns" )
		SetupDevCommand( "FSDM: Reset Saved Weapons", "resetguns" )
	}

	if( GetCheatsState() )
	{
		SetupDevMenu( "Equip Legend Abilities", SetDevMenu_Abilities )
		//SetupDevMenu( "Equip Custom Abilities", SetDevMenu_CustomAbilities )
		SetupDevMenu( "Equip Apex Weapons", SetDevMenu_Weapons )
		//if( Playlist() != ePlaylists.survival_firingrange )
			//SetupDevMenu( "Equip Titanfall Weapons", SetDevMenu_R2Weapons )

		if ( IsSurvivalMenuEnabled() )
		{
			SetupDevCommand( "", "give blank" )
			SetupDevMenu( "Change Character Class", SetDevMenu_SurvivalCharacter )
			SetupDevMenu( "Survival: Dev Tools", SetDevMenu_Survival )
			SetupDevMenu( "Survival: Weapons", SetDevMenu_SurvivalLoot, "main_weapon" )
			SetupDevMenu( "Survival: Attachments", SetDevMenu_SurvivalLoot, "attachment" )
			string GearsString = "helmet armor backpack incapshield"
			SetupDevMenu( "Survival: Gears", SetDevMenu_SurvivalLoot, GearsString )
			string itemsString = "ordnance ammo health custom_pickup data_knife ship_keycard marvin_arm"
			SetupDevMenu( "Survival: Consumables", SetDevMenu_SurvivalLoot, itemsString )
			SetupDevCommand( "", "give blank" )
		}

		if( GetCurrentPlaylistVarBool( "custom_loot", true ) )
		{
			SetupDevMenu( "Custom: Weapons (All)", SetDevMenu_SurvivalLoot, "weapon_custom" )
			SetupDevMenu( "Custom: Attachments", SetDevMenu_SurvivalLoot, "attachment_custom" )
			SetupDevCommand( "", "give blank" )
		}
		SetupDevMenu( "Equip Custom Loadouts", SetDevMenu_CustomCosmetics )
		SetupDevMenu( "Equip Custom Heirlooms", SetDevMenu_CustomHeirlooms )
		SetupDevCommand( "", "give blank" )
		SetupDevMenu( "Respawn Players", SetDevMenu_RespawnPlayers )
		SetupDevCommand( "Recharge Abilities", "recharge" )
		SetupDevCommand( "Start Skydive", "script thread SkydiveTest()" )
		SetupDevCommand( "", "give blank" )

		SetupDevMenu( "Spawn NPC at Crosshair [Friendly]", SetDevMenu_AISpawnFriendly )
		SetupDevMenu( "Spawn NPC at Crosshair [Enemy]", SetDevMenu_AISpawnEnemy )

		SetupDevCommand( "", "give blank" )

		SetupDevCommand( "Toggle NoClip", "noclip" )
		SetupDevCommand( "Toggle Infinite Ammo", "infinite_ammo" )
		SetupDevCommand( "Toggle HUD", "ToggleHUD" )		
		SetupDevCommand( "Toggle God Mode", "demigod" )
		SetupDevCommand( "Toggle Third Person Mode", "ToggleThirdPerson" )

		SetupDevCommand( "", "give blank" )

		SetupDevCommand( "===============DEV ONLY===============", "give blank" )
		SetupDevMenu( "Prototypes & Misc", SetDevMenu_Prototypes )
		SetupDevCommand( "=========================================", "give blank" )
	}
	else
	{
		SetupDevCommand( "Cheats are disabled! Type 'sv_cheats 1' in console to enable dev menu if you're the server admin.", "empty" )
	}
}


void function SetDevMenu_LevelCommands( var _ )
{
	ChangeToThisMenu( SetupLevelDevCommands )
}


void function SetupLevelDevCommands()
{
	string activeLevel = GetActiveLevel()
	if ( activeLevel == "" )
		return

	switch ( activeLevel )
	{
		case "model_viewer":
			SetupDevCommand( "Toggle Rebreather Masks", "script ToggleRebreatherMasks()" )
			break
	}
}
void function SetDevMenu_Abilities( var _ )
{
	thread ChangeToThisMenu( SetupAbilities )
}
void function SetDevMenu_CustomAbilities( var _ )
{
	thread ChangeToThisMenu( SetupCustomAbilities )
}
void function SetDevMenu_Weapons( var _ )
{
	thread ChangeToThisMenu( SetupRetailWeapons )
}
void function SetDevMenu_R2Weapons( var _ )
{
	thread ChangeToThisMenu( SetupTitanfallWeapons )
}
void function SetDevMenu_Throwables( var _ )
{
	thread ChangeToThisMenu( SetupThrowables )
}
void function SetDevMenu_TDMPrimaryWeapons( var _ )
{
	thread ChangeToThisMenu( SetupTDMPrimaryWeapons )
}
void function SetDevMenu_TDMSecondaryWeapons( var _ )
{
	thread ChangeToThisMenu( SetupTDMSecondaryWeapons )
}
void function SetDevMenu_SurvivalCharacter( var _ )
{
	thread ChangeToThisMenu( SetupChangeSurvivalCharacterClass )
}
void function SetDevMenu_AISpawnFriendly( var _ )
{
	thread ChangeToThisMenu( SetupFriendlyNPC )
}
void function SetDevMenu_AISpawnEnemy( var _ )
{
	thread ChangeToThisMenu( SetupEnemyNPC )
}
void function SetDevMenu_Editor( var _ )
{
	thread ChangeToThisMenu( SetupEditor )
}
void function SetDevMenu_CustomPRModel( var _ )
{
	thread ChangeToThisMenu( SetupChangeCharacterModel )
}
void function DEV_InitLoadoutDevSubMenu()
{
	file.initializingCodeDevMenu = true
	string codeDevMenuPrefix = file.codeDevMenuPrefix
	//file.codeDevMenuPrefix = "Alter Loadout"
	//DevMenu_Alias_DEV( file.codeDevMenuPrefix, "" )
	//DevMenu_Rm_DEV( file.codeDevMenuPrefix )
	//file.codeDevMenuPrefix += "/"
	file.codeDevMenuPrefix += "Alter Loadout/"
	DevMenu_Rm_DEV( file.codeDevMenuPrefix + "(Click to load this menu..)" )
	thread ChangeToThisMenu( SetupAlterLoadout )
	file.codeDevMenuPrefix = codeDevMenuPrefix
	file.initializingCodeDevMenu = false
}


void function SetDevMenu_AlterLoadout( var _ )
{
	if ( file.initializingCodeDevMenu )
	{
		//return
		DevMenu_Alias_DEV( file.codeDevMenuPrefix + "(Click to load this menu..)", "script_ui DEV_InitLoadoutDevSubMenu()" )
	}
	else
	{
		thread ChangeToThisMenu( SetupAlterLoadout )
	}
}


void function SetupAlterLoadout()
{
	array<string> categories = []
	foreach( LoadoutEntry entry in GetAllLoadoutSlots() )
	{
		if ( !categories.contains( entry.DEV_category ) )
			categories.append( entry.DEV_category )
	}
	categories.sort()
	foreach( string category in categories )
	{
		SetupDevMenu( category, void function( var unused ) : ( category ) {
			thread ChangeToThisMenu( void function() : ( category ) {
				SetupAlterLoadout_CategoryScreen( category )
			} )
		} )
	}
}


void function SetupAlterLoadout_CategoryScreen( string category )
{
	array<LoadoutEntry> entries = clone GetAllLoadoutSlots()
	entries.sort( int function( LoadoutEntry a, LoadoutEntry b ) {
		if ( a.DEV_name < b.DEV_name )
			return -1
		if ( a.DEV_name > b.DEV_name )
			return 1
		return 0
	} )

	array<string> charactersUsed = []

	foreach( LoadoutEntry entry in  entries)
	{
		if ( entry.DEV_category != category )
			continue

		string prefix = "character_"

		if ( entry.DEV_name.find( prefix ) == 0 )
		{
			string character = GetCharacterNameFromDEV_name( entry.DEV_name )

			if ( !charactersUsed.contains( character ) )
			{
				charactersUsed.append( character )
				SetupDevMenu( character, void function( var unused ) : ( category, character ) {
					thread ChangeToThisMenu( void function() : ( category, character ) {
						SetupAlterLoadout_CategoryScreenForCharacter( category, character )
					} )
				} )
			}
		}
		else
		{
			SetupDevMenu( entry.DEV_name, void function( var unused ) : ( entry ) {
				thread ChangeToThisMenu( void function() : ( entry ) {
					SetupAlterLoadout_SlotScreen( entry )
				} )
			} )
		}
	}
}

void function SetupAlterLoadout_CategoryScreenForCharacter( string category, string character )
{
	array<LoadoutEntry> entries = clone GetAllLoadoutSlots()
	entries.sort( int function( LoadoutEntry a, LoadoutEntry b ) {
		if ( a.DEV_name < b.DEV_name )
			return -1
		if ( a.DEV_name > b.DEV_name )
			return 1
		return 0
	} )

	array< LoadoutEntry > entriesToUse

	foreach( LoadoutEntry entry in entries )
	{
		if ( entry.DEV_category != category )
			continue

		string entryCharacter = GetCharacterNameFromDEV_name( entry.DEV_name )

		if ( entryCharacter != character )
			continue

		entriesToUse.append( entry )
	}


	if ( entriesToUse.len() > 1 )
	{
		foreach ( LoadoutEntry entry in entriesToUse )
		{
			SetupDevMenu( entry.DEV_name, void function( var unused ) : ( entry ) {
				thread ChangeToThisMenu( void function() : ( entry ) {
					SetupAlterLoadout_SlotScreen( entry )
				} )
			} )
		}
	}
	else if ( entriesToUse.len() == 1 )
	{
		LoadoutEntry entry = entriesToUse[ 0 ]
		SetupAlterLoadout_SlotScreen( entry )
	}
}

string function GetCharacterNameFromDEV_name( string DEV_name )
{
	string prefix = "character_"
	return split( DEV_name.slice( prefix.len() ), " " )[ 0 ]
}

void function SetupAlterLoadout_SlotScreen( LoadoutEntry entry )
{
	// todo(dw): 368482
	//if ( entry.canBeEmpty )
	//{
	//	SetupDevFunc( "(empty)", void function( var unused ) : ( entry ) {
	//		DEV_RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), entry, null )
	//	} )
	//}

	array<ItemFlavor> flavors = clone DEV_GetValidItemFlavorsForLoadoutSlotForDev( LocalClientEHI(), entry )
	flavors.sort( int function( ItemFlavor a, ItemFlavor b ) {
		string textA = Localize( ItemFlavor_GetLongName( a ) )
		string textB = Localize( ItemFlavor_GetLongName( b ) )

		//
		if ( textA.slice( 0, 1 ) == "[" && textB.slice( 0, 1 ) != "[" )
			return -1

		if ( textA.slice( 0, 1 ) != "[" && textB.slice( 0, 1 ) == "[" )
			return 1

		if ( textA < textB )
			return -1

		if ( textA > textB )
			return 1

		return 0
	} )

	foreach( ItemFlavor flav in flavors )
	{
		SetupDevFunc( Localize( ItemFlavor_GetLongName( flav ) ), void function( var unused ) : ( entry, flav ) {
			DEV_RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), entry, flav )
		} )
	}
}


void function SetDevMenu_OverrideSpawnSurvivalCharacter( var _ )
{
	thread ChangeToThisMenu( SetupOverrideSpawnSurvivalCharacter )
}


void function SetDevMenu_Survival( var _ )
{
	thread ChangeToThisMenu( SetupSurvival )
}


void function SetDevMenu_SurvivalLoot( var categories )
{
	thread ChangeToThisMenu_WithOpParm( SetupSurvivalLoot, categories )
}


void function SetDevMenu_SurvivalIncapShieldBots( var _ )
{
	thread ChangeToThisMenu( SetupSurvivalIncapShieldBot )
}



void function ChangeToThisMenu_PrecacheWeapons( void functionref() menuFunc )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFunc()
		return
	}

	waitthread PrecacheWeaponsIfNecessary()

	PushPageHistory()
	file.currentPage.devMenuFunc = menuFunc
	file.currentPage.devMenuFuncWithOpParm = null
	file.currentPage.devMenuOpParm = null
	UpdateDevMenuButtons()
}


void function ChangeToThisMenu_PrecacheWeapons_WithOpParm( void functionref( var ) menuFuncWithOpParm, opParm = null )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFuncWithOpParm( opParm )
		return
	}

	waitthread PrecacheWeaponsIfNecessary()

	PushPageHistory()
	file.currentPage.devMenuFunc = null
	file.currentPage.devMenuFuncWithOpParm = menuFuncWithOpParm
	file.currentPage.devMenuOpParm = opParm
	UpdateDevMenuButtons()
}


void function PrecacheWeaponsIfNecessary()
{
	if ( file.precachedWeapons )
		return

	file.precachedWeapons = true
	CloseAllMenus()

	DisablePrecacheErrors()
	wait 0.1
	ClientCommand( "script PrecacheSPWeapons()" )
	wait 0.1
	ClientCommand( "script_client PrecacheSPWeapons()" )
	wait 0.1
	RestorePrecacheErrors()

	AdvanceMenu( GetMenu( "DevMenu" ) )
}


void function UpdatePrecachedSPWeapons()
{
	file.precachedWeapons = true
}

void function SetDevMenu_RespawnPlayers( var _ )
{
	ChangeToThisMenu( SetupRespawnPlayersDevMenu )
}

void function SetDevMenu_CustomHeirlooms( var _ )
{
	ChangeToThisMenu( SetupHeirloomsDevMenu )
}

void function SetupRespawnPlayersDevMenu()
{
	SetupDevCommand( "Respawn me", "respawn" )
	SetupDevCommand( "Respawn all players", "respawn all" )
	SetupDevCommand( "Respawn all dead players", "respawn alldead" )
	SetupDevCommand( "Respawn random player", "respawn random" )
	SetupDevCommand( "Respawn random dead player", "respawn randomdead" )
	SetupDevCommand( "Respawn bots", "respawn bots" )
	SetupDevCommand( "Respawn dead bots", "respawn deadbots" )
	SetupDevCommand( "Respawn my teammates", "respawn allies" )
	SetupDevCommand( "Respawn my enemies", "respawn enemies" )
}

void function SetupHeirloomsDevMenu()
{
	SetupDevCommand( "Default Melee", "giveheirloom -1" )
	if ( IsKralStuffActive() )
	{
		SetupDevCommand( "Bolo Sword", "giveheirloom 0" )
		SetupDevCommand( "Diamond Sword", "giveheirloom 2" )
		SetupDevCommand( "Mjolnir", "giveheirloom 3" )
		SetupDevCommand( "Le Karambit", "giveheirloom 4" )
	}
	
	SetupDevCommand( "Dragonfly Knife", "giveheirloom 1" )
}

void function SetupTDMPrimaryWeapons()
{
	//Assault Rifles
	SetupDevCommand( "R-301", "tgive p mp_weapon_rspn101 optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "Flatline", "tgive p mp_weapon_vinson optic_cq_hcog_bruiser stock_tactical_l3 highcal_mag_l3")
	SetupDevCommand( "Hemlok", "tgive p mp_weapon_hemlok optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 highcal_mag_l3" )
	SetupDevCommand( "Havoc", "tgive p mp_weapon_energy_ar optic_cq_hcog_bruiser stock_tactical_l3 energy_mag_l1 hopup_turbocharger" )
	//LMGs
	SetupDevCommand( "Spitfire", "tgive p mp_weapon_lmg optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 highcal_mag_l2" )
	SetupDevCommand( "Devotion", "tgive p mp_weapon_esaw optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 energy_mag_l1 hopup_turbocharger" )
	SetupDevCommand( "L-STAR EMG", "tgive p mp_weapon_lstar energy_mag_l3 optic_cq_hcog_bruiser" )
	//SMGs
	SetupDevCommand( "R-99 SMG", "tgive p mp_weapon_r97 optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "Alternator SMG", "tgive p mp_weapon_alternator_smg optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "Prowler Burst SMG", "tgive p mp_weapon_pdw optic_cq_hcog_classic stock_tactical_l3 highcal_mag_l3" )
	SetupDevCommand( "Volt SMG", "tgive p mp_weapon_volt_smg optic_cq_hcog_classic barrel_stabilizer_l3 stock_tactical_l3 energy_mag_l3" )
	// SetupDevCommand( "CAR SMG", "tgive p mp_weapon_car optic_cq_hcog_classic barrel_stabilizer_l3 stock_tactical_l3 bullets_mag_l3" )
	//Marksman Weapons
	SetupDevCommand( "G7 Scout", "tgive p mp_weapon_g2 optic_ranged_hcog stock_sniper_l3 barrel_stabilizer_l3 bullets_mag_l3 hopup_double_tap" )
	SetupDevCommand( "Triple Take", "tgive p mp_weapon_doubletake energy_mag_l3 optic_ranged_hcog stock_sniper_l3 hopup_energy_choke" )
	//Pistols
	SetupDevCommand( "RE-45", "tgive p mp_weapon_autopistol optic_cq_hcog_classic barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "P2020", "tgive p mp_weapon_semipistol optic_cq_hcog_classic bullets_mag_l3 hopup_unshielded_dmg" )
	SetupDevCommand( "Wingman", "tgive p mp_weapon_wingman optic_cq_hcog_classic sniper_mag_l3" )
	//Shotguns
	SetupDevCommand( "EVA-8", "tgive p mp_weapon_shotgun shotgun_bolt_l3 optic_cq_threat hopup_double_tap" )
	SetupDevCommand( "Mozambique", "tgive p mp_weapon_shotgun_pistol shotgun_bolt_l3 optic_cq_threat hopup_unshielded_dmg" )
	SetupDevCommand( "Peacekeeper", "tgive p mp_weapon_energy_shotgun shotgun_bolt_l3 optic_cq_threat hopup_energy_choke" )
	SetupDevCommand( "Mastiff","tgive p mp_weapon_mastiff shotgun_bolt_l3")
	//Sniper Rifles
	SetupDevCommand( "Longbow", "tgive p mp_weapon_dmr optic_sniper_variable barrel_stabilizer_l3 stock_sniper_l3 sniper_mag_l3" )
	SetupDevCommand( "Charge Rifle", "tgive p mp_weapon_defender optic_sniper_threat stock_sniper_l3" )
	//SetupDevCommand( "Kraber", "tgive p mp_weapon_sniper" )
}

void function SetupTDMSecondaryWeapons()
{
	//Assault Rifles
	SetupDevCommand( "R-301", "tgive s mp_weapon_rspn101 optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "Flatline", "tgive s mp_weapon_vinson optic_cq_hcog_bruiser stock_tactical_l3 highcal_mag_l3")
	SetupDevCommand( "Hemlok", "tgive s mp_weapon_hemlok optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 highcal_mag_l3" )
	SetupDevCommand( "Havoc", "tgive s mp_weapon_energy_ar optic_cq_hcog_bruiser stock_tactical_l3 energy_mag_l1 hopup_turbocharger" )
	//LMGs
	SetupDevCommand( "Spitfire", "tgive s mp_weapon_lmg optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 highcal_mag_l2" )
	SetupDevCommand( "Devotion", "tgive s mp_weapon_esaw optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 energy_mag_l1 hopup_turbocharger" )
	SetupDevCommand( "L-STAR EMG", "tgive s mp_weapon_lstar energy_mag_l3 optic_cq_hcog_bruiser" )
	//SMGs
	SetupDevCommand( "R-99 SMG", "tgive s mp_weapon_r97 optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "Alternator SMG", "tgive s mp_weapon_alternator_smg optic_cq_hcog_bruiser stock_tactical_l3 barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "Prowler Burst SMG", "tgive s mp_weapon_pdw optic_cq_hcog_classic stock_tactical_l3 highcal_mag_l3" )
	SetupDevCommand( "Volt SMG", "tgive s mp_weapon_volt_smg optic_cq_hcog_classic barrel_stabilizer_l3 stock_tactical_l3 energy_mag_l3" )
	// SetupDevCommand( "CAR SMG", "tgive s mp_weapon_car optic_cq_hcog_classic barrel_stabilizer_l3 stock_tactical_l3 bullets_mag_l3" )
	//Marksman Weapons
	SetupDevCommand( "G7 Scout", "tgive s mp_weapon_g2 optic_ranged_hcog stock_sniper_l3 barrel_stabilizer_l3 bullets_mag_l3 hopup_double_tap" )
	SetupDevCommand( "Triple Take", "tgive s mp_weapon_doubletake energy_mag_l3 optic_ranged_hcog stock_sniper_l3 hopup_energy_choke" )
	//Pistols
	SetupDevCommand( "RE-45", "tgive s mp_weapon_autopistol optic_cq_hcog_classic barrel_stabilizer_l3 bullets_mag_l3" )
	SetupDevCommand( "P2020", "tgive s mp_weapon_semipistol optic_cq_hcog_classic bullets_mag_l3 hopup_unshielded_dmg" )
	SetupDevCommand( "Wingman", "tgive s mp_weapon_wingman optic_cq_hcog_classic sniper_mag_l3" )
	//Shotguns
	SetupDevCommand( "EVA-8", "tgive s mp_weapon_shotgun shotgun_bolt_l3 optic_cq_threat hopup_double_tap" )
	SetupDevCommand( "Mozambique", "tgive s mp_weapon_shotgun_pistol shotgun_bolt_l3 optic_cq_threat hopup_unshielded_dmg" )
	SetupDevCommand( "Peacekeeper", "tgive s mp_weapon_energy_shotgun shotgun_bolt_l3 optic_cq_threat hopup_energy_choke" )
	SetupDevCommand( "Mastiff","tgive s mp_weapon_mastiff shotgun_bolt_l3")
	//Sniper Rifles
	SetupDevCommand( "Longbow", "tgive s mp_weapon_dmr optic_sniper_variable barrel_stabilizer_l3 stock_sniper_l3 highcal_mag_l3" )
	SetupDevCommand( "Charge Rifle", "tgive s mp_weapon_defender optic_sniper_threat stock_sniper_l3" )
	//SetupDevCommand( "Kraber", "tgive s mp_weapon_sniper" )
}

void function SetDevMenu_RespawnOverride( var _ )
{
	ChangeToThisMenu( SetupRespawnOverrideDevMenu )
}


void function SetupRespawnOverrideDevMenu()
{
	SetupDevCommand( "Use gamemode behaviour", "set_respawn_override off" )
	SetupDevCommand( "Override: Allow all respawning", "set_respawn_override allow" )
	SetupDevCommand( "Override: Deny all respawning", "set_respawn_override deny" )
	SetupDevCommand( "Override: Allow bot respawning", "set_respawn_override allowbots" )
}


void function SetDevMenu_ThreatTracker( var _ )
{
	ChangeToThisMenu( SetupThreatTrackerDevMenu )
}


void function SetupThreatTrackerDevMenu()
{
	SetupDevCommand( "Reload Threat Data", "fs_report_sync_opens 0; script ReloadScripts(); script ThreatTracker_ReloadThreatData()" )
	SetupDevCommand( "Threat Tracking ON", "script ThreatTracker_SetActive( true )" )
	SetupDevCommand( "Threat Tracking OFF", "script ThreatTracker_SetActive( false )" )
	SetupDevCommand( "Overhead Debug ON", "script ThreatTracker_DrawDebugOverheadText( true )" )
	SetupDevCommand( "Overhead Debug OFF", "script ThreatTracker_DrawDebugOverheadText( false )" )
	SetupDevCommand( "Console Debug Level 0", "script ThreatTracker_SetDebugLevel( 0 )" )
	SetupDevCommand( "Console Debug Level 1", "script ThreatTracker_SetDebugLevel( 1 )" )
	SetupDevCommand( "Console Debug Level 2", "script ThreatTracker_SetDebugLevel( 2 )" )
	SetupDevCommand( "Console Debug Level 3", "script ThreatTracker_SetDebugLevel( 3 )" )
}


void function SetDevMenu_HighVisNPCTest( var _ )
{
	ChangeToThisMenu( SetupHighVisNPCTest )
}


void function SetupHighVisNPCTest()
{
	SetupDevCommand( "Spawn at Crosshair", "script PROTO_SpawnHighVisNPCs()" )
	SetupDevCommand( "Delete Test NPCs", "script PROTO_DeleteHighVisNPCs()" )
	SetupDevCommand( "Use R5 Art Settings", "script PROTO_HighVisNPCs_SetTestEnv( \"r5\" )" )
	SetupDevCommand( "Use R2 Art Settings", "script PROTO_HighVisNPCs_SetTestEnv( \"r2\" )" )
}

void function SetDevMenu_Prototypes( var _ )
{
	thread ChangeToThisMenu( SetupPrototypesDevMenu )
}

void function SetupPrototypesDevMenu()
{
	SetupDevCommand( "Toggle Akimbo Weapon", "script DEV_ToggleAkimboWeapon(gp()[0])" )
	//SetupDevCommand( "Toggle Akimbo With Holstered Weapon", "script DEV_ToggleAkimboWeaponAlt(gp()[0])" )
	SetupDevCommand( "Cubemap Viewer", "give weapon_cubemap" )
	SetupDevCommand( "Toggle Shadow Form", "ShadowForm" )
	SetupDevCommand( "Teleport to Skybox Camera", "script thread ToggleSkyboxView()" )
	SetupDevCommand( "Spawn Deathbox With Random Loots", "script DEV_SpawnDeathBoxWithRandomLoot(gp()[0])" )
	SetupDevMenu( "Loot Marvin Debug (Olympus Only)", SetDevMenu_LootMarvin )
	SetupDevMenu( "Vault System Debug", SetDevMenu_VaultDebug )
	SetupDevCommand( "Summon Players to player 0", "script summonplayers()" )
	SetupDevCommand( "Summon Trident", "spawntrident" )
	//SetupDevMenu( "Incap Shield Debugging", SetDevMenu_SurvivalIncapShieldBots )
}

void function SetDevMenu_LootMarvin( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_LootMarvinPanel )
}

void function SetDevMenu_LootMarvinPanel()
{
	SetupDevCommand( "Debug Draw Marvin Locations", "script SeeMarvinSpawnLocations()" )
	SetupDevCommand( "Teleport to Random Marvin", "script TeleportToRandomMarvinLocations()" )
	SetupDevCommand( "Ping Nearest Marvin", "script AttemptPingNearestValidMarvinForPlayer(gp()[0])" )
	SetupDevCommand( "Create Loot Marvin At Crosshair", "script CreateMarvin_Loot()" )
	SetupDevCommand( "Create Loot Marvin With Detachable Arm At Crosshair", "script CreateMarvin_Loot( true )" )
	SetupDevCommand( "Create Story Marvin At Crosshair", "script CreateMarvin_Story()" )
}

void function SetDevMenu_VaultDebug( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_VaultDebugPanel )
}

void function SetDevMenu_VaultDebugPanel()
{
	SetupDevCommand( "Debug Draw Vault Loot", "script DEV_ShowVaults()" )
	SetupDevCommand( "Debug Draw Vault Keys", "script DEV_ShowVaultKeys()" )
	SetupDevCommand( "Teleport to Available Vault Key", "script DEV_TPToVaultKeys()" )
	SetupDevCommand( "Equip Every Vault Key", "script DEV_GiveVaultKeys(gp()[0])" )
	SetupDevCommand( "Debug Draw Vault Panel Infos", "script DEV_ShowVaultPanelInfos()" )
}

void function RunCodeDevCommandByAlias( string alias )
{
	RunDevCommand( file.codeDevMenuCommands[alias], false )
}


void function SetupDevCommand( string label, string command )
{
	if ( command.slice( 0, 5 ) == "give " )
		command = "give_server " + command.slice( 5 )

	DevCommand cmd
	cmd.label = label
	cmd.command = command

	file.devCommands.append( cmd )
	if ( file.initializingCodeDevMenu )
	{
		string codeDevMenuAlias = file.codeDevMenuPrefix + label
		//string codeDevMenuCommand = format( "script_ui RunCodeDevCommandByAlias( \"%s\" )", codeDevMenuAlias )
		//file.codeDevMenuCommands[codeDevMenuAlias] <- cmd
		DevMenu_Alias_DEV( codeDevMenuAlias, command )
	}
}


void function SetupDevFunc( string label, void functionref( var ) func, var opParm = null )
{
	DevCommand cmd
	cmd.label = label
	cmd.func = func
	cmd.opParm = opParm

	file.devCommands.append( cmd )
	if ( file.initializingCodeDevMenu )
	{
		string codeDevMenuAlias   = file.codeDevMenuPrefix + label
		string codeDevMenuCommand = format( "script_ui RunCodeDevCommandByAlias( \"%s\" )", codeDevMenuAlias )
		file.codeDevMenuCommands[codeDevMenuAlias] <- cmd
		DevMenu_Alias_DEV( codeDevMenuAlias, codeDevMenuCommand )
	}
}


void function SetupDevMenu( string label, void functionref( var ) func, var opParm = null )
{
	DevCommand cmd
	cmd.label = (label + "  ->")
	cmd.func = func
	cmd.opParm = opParm
	cmd.isAMenuCommand = true

	file.devCommands.append( cmd )

	if ( file.initializingCodeDevMenu )
	{
		string codeDevMenuPrefix = file.codeDevMenuPrefix
		file.codeDevMenuPrefix += label + "/"
		cmd.func( cmd.opParm )
		file.codeDevMenuPrefix = codeDevMenuPrefix
	}
}


void function OnDevButton_Activate( var button )
{
	if ( level.ui.disableDev )
	{
		Warning( "Dev commands disabled on matchmaking servers." )
		return
	}

	int buttonID   = int( Hud_GetScriptID( button ) )
	DevCommand cmd = file.devCommands[buttonID]

	RunDevCommand( cmd, false )
}


void function OnDevButton_GetFocus( var button )
{
	file.focusedCmdIsAssigned = false

	int buttonID = int( Hud_GetScriptID( button ) )
	if ( buttonID >= file.devCommands.len() )
		return

	if ( file.devCommands[buttonID].isAMenuCommand )
		return

	file.focusedCmd = file.devCommands[buttonID]
	file.focusedCmdIsAssigned = true
}


void function OnDevButton_LoseFocus( var button )
{
}


void function RunDevCommand( DevCommand cmd, bool isARepeat )
{
	if ( !isARepeat )
	{
		if ( file.lastDevCommandLabelInProgress.len() > 0 )
			file.lastDevCommandLabelInProgress += "  "
		file.lastDevCommandLabelInProgress += cmd.label

		if ( !cmd.isAMenuCommand )
		{
			file.lastDevCommand = cmd
			file.lastDevCommandAssigned = true
			file.lastDevCommandLabel = file.lastDevCommandLabelInProgress
		}
	}

	if ( cmd.command != "" )
	{
		ClientCommand( cmd.command )
		if ( IsLobby() )
		{
			CloseAllMenus()
			AdvanceMenu( GetMenu( "LobbyMenu" ) )
		}
		else
		{
			//CloseAllMenus() // Temporarily disable dev menu closing itself - todo: revert this later, -lorrylekral
		}
	}
	else
	{
		cmd.func( cmd.opParm )
	}
}


void function RepeatLastDevCommand( var _ )
{
	if ( !file.lastDevCommandAssigned )
		return

	RunDevCommand( file.lastDevCommand, true )
}


void function RepeatLastCommand_Activate( var button )
{
	RepeatLastDevCommand( null )
}


void function PushPageHistory()
{
	DevMenuPage page = file.currentPage
	if ( page.devMenuFunc != null || page.devMenuFuncWithOpParm != null )
		file.pageHistory.push( clone page )
}


void function BackOnePage_Activate()
{
	if ( file.pageHistory.len() == 0 )
	{
		CloseActiveMenu( true )
		return
	}

	file.currentPage = file.pageHistory.pop()
	UpdateDevMenuButtons()
}


void function RefreshRepeatLastDevCommandPrompts()
{
	string newText = ""
	//if ( AreOnDefaultDevCommandMenu() )
	{
		if ( file.lastDevCommandAssigned )
			newText = file.lastDevCommandLabel    // file.lastDevCommand.label
		else
			newText = "<none>"
	}

	if ( AreOnDefaultDevCommandMenu() )
		file.lastDevCommandLabelInProgress = ""

	Hud_SetText( file.footerHelpTxtLabel, newText )
}


bool function AreOnDefaultDevCommandMenu()
{
	if ( file.currentPage.devMenuFunc == SetupDefaultDevCommandsMP )
		return true

	return false
}


void function BindCommandToGamepad_Activate( var button )
{
	if ( !BindCommandToGamepad_ShouldShow() )
		return

	// Binding:
	{
		string cmdText = "bind back \"script_ui DEV_ExecBoundDevMenuCommand()\""
		ClientCommand( cmdText )
	}

	file.boundCmd.command = file.focusedCmd.command
	file.boundCmd.isAMenuCommand = file.focusedCmd.isAMenuCommand
	file.boundCmd.label = file.focusedCmd.label
	file.boundCmd.func = file.focusedCmd.func
	file.boundCmd.opParm = file.focusedCmd.opParm
	file.boundCmdIsAssigned = true

	// Feedback:
	{
		string fullName = ""
		if ( file.lastDevCommandLabelInProgress.len() > 0 )
			fullName = file.lastDevCommandLabelInProgress + " -> "
		fullName += file.focusedCmd.label

		string prompt = "Bound to gamepad BACK: " + fullName
		printt( prompt )
		//string cmdText = "script Dev_PrintMessage( gp()[0], \"" + prompt + "\" )"
		//ClientCommand( cmdText )
		EmitUISound( "wpn_pickup_titanweapon_1p" )
	}

	CloseAllMenus()
}


bool function BindCommandToGamepad_ShouldShow()
{
	if ( !file.focusedCmdIsAssigned )
		return false
	if ( file.focusedCmd.command.len() == 0 )
		return false
	return true
}


void function DEV_ExecBoundDevMenuCommand()
{
	if ( !file.boundCmdIsAssigned )
		return

	RunDevCommand( file.boundCmd, true )
}

void function SetupChangeSurvivalCharacterClass()
{
// TODO: FIX [Undefined variable "SetupDevFunc"] //done?
	#if UI
		array<ItemFlavor> characters = clone GetAllCharacters()
		characters.sort( int function( ItemFlavor a, ItemFlavor b ) {
			if ( Localize( ItemFlavor_GetLongName( a ) ) < Localize( ItemFlavor_GetLongName( b ) ) )
				return -1
			if ( Localize( ItemFlavor_GetLongName( a ) ) > Localize( ItemFlavor_GetLongName( b ) ) )
				return 1
			return 0
		} )
		foreach( ItemFlavor character in characters )
		{
			SetupDevFunc( Localize( ItemFlavor_GetLongName( character ) ), void function( var unused ) : ( character ) {
				DEV_RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), Loadout_CharacterClass(), character )
			} )
		}
	#endif
}

void function SetupChangeCharacterModel()
{
	#if UI
		SetupDevCommand( "TF2 Ash", "Flowstate_AssignCustomCharacterFromMenu 6")
		SetupDevCommand( "TF2 Blisk", "Flowstate_AssignCustomCharacterFromMenu 1")
		SetupDevCommand( "TF2 Jack Cooper", "Flowstate_AssignCustomCharacterFromMenu 8")
		SetupDevCommand( "Ballistic", "Flowstate_AssignCustomCharacterFromMenu 12")
		SetupDevCommand( "Fade", "Flowstate_AssignCustomCharacterFromMenu 2")
		SetupDevCommand( "Rhapsody", "Flowstate_AssignCustomCharacterFromMenu 5")
		SetupDevCommand( "Crewmate [3p only]", "Flowstate_AssignCustomCharacterFromMenu 3")
		SetupDevCommand( "MRVN [3p only]", "Flowstate_AssignCustomCharacterFromMenu 13")
		SetupDevCommand( "Pete", "Flowstate_AssignCustomCharacterFromMenu 16" )
	#endif
}


void function SetupOverrideSpawnSurvivalCharacter()
{
	#if(UI)
		SetupDevCommand( "Random (default)", "dev_sur_force_spawn_character random" )
		SetupDevCommand( "Shipping only", "dev_sur_force_spawn_character special" )
		array<ItemFlavor> characters = clone GetAllCharacters()
		characters.sort( int function( ItemFlavor a, ItemFlavor b ) {
			if ( Localize( ItemFlavor_GetLongName( a ) ) < Localize( ItemFlavor_GetLongName( b ) ) )
				return -1
			if ( Localize( ItemFlavor_GetLongName( a ) ) > Localize( ItemFlavor_GetLongName( b ) ) )
				return 1
			return 0
		} )
		foreach( ItemFlavor characterClass in characters )
		{
			SetupDevCommand( Localize( ItemFlavor_GetLongName( characterClass ) ), "dev_sur_force_spawn_character " + ItemFlavor_GetHumanReadableRef( characterClass ) )
		}
	#endif
}

void function SetupWeapons()
{
	#if UI
	// Rifles
	SetupDevCommand( "Rifle: Flatline", "give mp_weapon_vinson" )
	SetupDevCommand( "Rifle: G7 Scout", "give mp_weapon_g2" )
	SetupDevCommand( "Rifle: Havoc", "give mp_weapon_energy_ar" )
	SetupDevCommand( "Rifle: Hemlok", "give mp_weapon_hemlok" )
	SetupDevCommand( "Rifle: R-301", "give mp_weapon_rspn101" )

	// SMGs
	SetupDevCommand( "SMG: Alternator", "give mp_weapon_alternator_smg" )
	SetupDevCommand( "SMG: Prowler", "give mp_weapon_pdw" )
	SetupDevCommand( "SMG: R-99", "give mp_weapon_r97" )
	SetupDevCommand( "SMG: Volt SMG", "give mp_weapon_volt_smg" )

	// LMGs
	SetupDevCommand( "LMG: Devotion", "give mp_weapon_esaw" )
	SetupDevCommand( "LMG: L-Star", "give mp_weapon_lstar" )
	SetupDevCommand( "LMG: Spitfire", "give mp_weapon_lmg" )

	// Snipers
	SetupDevCommand( "Sniper: Charge Rifle", "give mp_weapon_defender" )
	SetupDevCommand( "Sniper: Kraber", "give mp_weapon_sniper" )
	SetupDevCommand( "Sniper: Longbow", "give mp_weapon_dmr" )
	SetupDevCommand( "Sniper: Triple Take", "give mp_weapon_doubletake" )
	SetupDevCommand( "Sniper: Sentinel", "give mp_weapon_sentinel" )

	// Shotguns
	SetupDevCommand( "Shotgun: EVA-8 Auto", "give mp_weapon_shotgun" )
	SetupDevCommand( "Shotgun: Mastiff", "give mp_weapon_mastiff" )
	SetupDevCommand( "Shotgun: Mozambique", "give mp_weapon_shotgun_pistol" )
	SetupDevCommand( "Shotgun: Peacekeeper", "give mp_weapon_energy_shotgun" )

	// Pistols
	SetupDevCommand( "Pistol: P2020", "give mp_weapon_semipistol" )
	SetupDevCommand( "Pistol: RE-45", "give mp_weapon_autopistol" )
	SetupDevCommand( "Pistol: Wingman", "give mp_weapon_wingman" )

	// Custom
	//SetupDevCommand( "Custom: Flame Thrower", "give mp_weapon_flamethrower" )
	//SetupDevCommand( "Custom: Raygun ", "give mp_weapon_raygun" )
	//SetupDevCommand( "Custom: Flowstate Sword", "playerRequestsSword")
	#endif
}

void function SetupRetailWeapons()
{
	#if UI
	// Marksman
	SetupDevCommand( "Marksman Rifle: G7 Scout", "give mp_weapon_g2" )
	SetupDevCommand( "Marksman: Triple Take", "give mp_weapon_doubletake" )
	SetupDevCommand( "Marksman: 30-30 Repeater", "give mp_weapon_3030" )
	SetupDevCommand( "", "give blank" )

	// LMGs
	SetupDevCommand( "Light Machine Gun: Devotion", "give mp_weapon_esaw" )
	SetupDevCommand( "Light Machine Gun: L-Star", "give mp_weapon_lstar" )
	SetupDevCommand( "Light Machine Gun: Spitfire", "give mp_weapon_lmg" )
	SetupDevCommand( "", "give blank" )

	// Snipers
	SetupDevCommand( "Sniper: Charge Rifle", "give mp_weapon_defender" )
	SetupDevCommand( "Sniper: Longbow", "give mp_weapon_dmr" )
	SetupDevCommand( "Sniper: Sentinel", "give mp_weapon_sentinel" )
	SetupDevCommand( "", "give blank" )

	// Pistols
	SetupDevCommand( "Pistol: P2020", "give mp_weapon_semipistol" )
	SetupDevCommand( "Pistol: RE-45", "give mp_weapon_autopistol" )
	SetupDevCommand( "Pistol: Wingman", "give mp_weapon_wingman" )
	SetupDevCommand( "", "give blank" )

	// SMGs
	SetupDevCommand( "Submachine Gun: Alternator", "give mp_weapon_alternator_smg" )
	SetupDevCommand( "Submachine Gun: Prowler", "give mp_weapon_pdw" )
	SetupDevCommand( "Submachine Gun: R-99", "give mp_weapon_r97" )
	SetupDevCommand( "Submachine Gun: Volt SMG", "give mp_weapon_volt_smg" )

	// Rifles
	SetupDevCommand( "Assault Rifle: Flatline", "give mp_weapon_vinson" )
	SetupDevCommand( "Assault Rifle: Hemlok", "give mp_weapon_hemlok" )
	SetupDevCommand( "Assault Rifle: R-301", "give mp_weapon_rspn101" )
	SetupDevCommand( "Assault Rifle:  Havoc AR", "give mp_weapon_energy_ar" )
	SetupDevCommand( "", "give blank" )

	// Shotguns
	SetupDevCommand( "Shotgun: EVA-8 Auto", "give mp_weapon_shotgun" )
	SetupDevCommand( "Shotgun: Mastiff", "give mp_weapon_mastiff" )
	SetupDevCommand( "Shotgun: Mozambique", "give mp_weapon_shotgun_pistol" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "", "give blank" )


	//Drop Weapons
	SetupDevCommand( "Crate: Triple Take", "give mp_weapon_doubletake_crate crate optic_ranged_aog_variable" )
	SetupDevCommand( "Crate: Peacekeeper", "give mp_weapon_energy_shotgun_crate crate optic_cq_hcog_classic shotgun_bolt_l4" )
	SetupDevCommand( "Crate: Kraber", "give mp_weapon_sniper" )
	//SetupDevCommand( "Crate: Bocek Bow", "give mp_weapon_bow" )
	#endif
}

void function SetupTitanfallWeapons()
{
	#if UI
	SetupDevCommand( "Titanfall 2 Pilot Weapon: EPG", "give mp_weapon_epg" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Sidewinder", "give mp_weapon_smr" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Archer", "give mp_weapon_rocket_launcher" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Softball", "give mp_weapon_softball" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Car", "give mp_weapon_car_r2" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: MGL", "give mp_weapon_mgl" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: ColdWar", "give mp_weapon_pulse_lmg" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Thunderbolt", "give mp_weapon_arc_launcher" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Smart Pistol", "give mp_weapon_smart_pistol" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Arc Tool", "give sp_weapon_arc_tool" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Wingman Elite", "give mp_weapon_wingman_n" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: R101 Assault Rifle", "give mp_weapon_rspn101_og iron_sights" )
	SetupDevCommand( "Titanfall 2 Pilot Weapon: Proximity Mine", "give mp_weapon_proximity_mine" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( " ", "give mp" )

	SetupDevMenu( "Titanfall 2 Titan Weapon: Predator Cannon", SetDevMenu_PredCannon )
	SetupDevMenu( "Titanfall 2 Titan Weapon: Splitter Rifle", SetDevMenu_SplitRifle )
	SetupDevMenu( "Titanfall 2 Titan Weapon: Quad Rocket", SetDevMenu_QuadRocket )
	SetupDevMenu( "Titanfall 2 Titan Weapon: Leadwall", SetDevMenu_LeadWall )
	SetupDevMenu( "Titanfall 2 Titan Weapon: T-203 Thermite Launcher", SetDevMenu_Thermite )
	SetupDevMenu( "Titanfall 2 Titan Weapon: Plasma Railgun", SetDevMenu_TSniper )
	SetupDevMenu( "Titanfall 2 Titan Weapon: XO-16", SetDevMenu_XO )
	SetupDevCommand( " ", "give mp" )

	// Dev
	SetupDevCommand( "Dev: Softball Apex Version", "give mp_weapon_softball apex_model" )
	SetupDevCommand( "Dev: Flight Core", "give mp_titanweapon_flightcore_rockets")
	SetupDevCommand( "Dev: Satchel", "give mp_weapon_satchel")
	SetupDevCommand( "Dev: Disable Titan POV Hands", "script ResetCharacterSkin(gp()[0])")
	#endif
}

void function SetDevMenu_PredCannon( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_PredCannonPanel )
}

void function SetDevMenu_SplitRifle( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_SplitRiflePanel )
}

void function SetDevMenu_QuadRocket( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_QuadRocketPanel )
}

void function SetDevMenu_LeadWall( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_LeadWallPanel )
}

void function SetDevMenu_Thermite( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_ThermitePanel )
}

void function SetDevMenu_TSniper( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_TSniperPanel )
}

void function SetDevMenu_XO( var _ )
{
	thread ChangeToThisMenu( SetDevMenu_XOPanel )
}

void function SetDevMenu_SplitRiflePanel()
{
	#if UI
	SetupDevCommand( "Equip Splitter Rifle", "give mp_titanweapon_particle_accelerator; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Particle Accelerator", "give mp_titanweapon_particle_accelerator proto_particle_accelerator; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Upgraded Particle Accelerator", "give mp_titanweapon_particle_accelerator fd_upgraded_proto_particle_accelerator; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Balance", "give mp_titanweapon_particle_accelerator fd_balance; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}

void function SetDevMenu_PredCannonPanel()
{
	#if UI
	SetupDevCommand( "Equip Predator Cannon", "give mp_titanweapon_predator_cannon; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Long Range Ammo", "give mp_titanweapon_predator_cannon LongRangeAmmo; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Smart Core", "give mp_titanweapon_predator_cannon Smart_Core; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Close Range Power Shot", "give mp_titanweapon_predator_cannon CloseRangePowerShot; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Siege Mode", "give mp_titanweapon_predator_cannon SiegeMode; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Long Range Power Shot", "give mp_titanweapon_predator_cannon LongRangePowerShot; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Piercing Shots", "give mp_titanweapon_predator_cannon fd_piercing_shots; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}

void function SetDevMenu_QuadRocketPanel()
{
	#if UI
	SetupDevCommand( "Equip Quad Rocket", "give mp_titanweapon_rocketeer_rocketstream; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Rocket Core Rocket Stream", "give mp_titanweapon_rocketeer_rocketstream RocketCore_RocketStream; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Mortar Titan", "give mp_titanweapon_rocketeer_rocketstream coop_mortar_titan; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Burn Mod", "give mp_titanweapon_rocketeer_rocketstream burn_mod_titan_rocket_launcher; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Singleplayer s2s Settings", "give mp_titanweapon_rocketeer_rocketstream sp_s2s_settings; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Singleplayer s2s Settings NPC", "give mp_titanweapon_rocketeer_rocketstream sp_s2s_settings_npc; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}

void function SetDevMenu_LeadWallPanel()
{
	#if UI
	SetupDevCommand( "Equip Leadwall", "give mp_titanweapon_leadwall; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Insta Load", "give mp_titanweapon_leadwall instaload; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Burn Mod", "give mp_titanweapon_leadwall burn_mod_titan_leadwall; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Ronin Weapon", "give mp_titanweapon_leadwall pas_ronin_weapon; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}

void function SetDevMenu_ThermitePanel()
{
	#if UI
	SetupDevCommand( "Equip T-203 Thermite Launcher", "give mp_titanweapon_meteor; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Scorch Weapon", "give mp_titanweapon_meteor pas_scorch_weapon; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: WPN Upgrade 1", "give mp_titanweapon_meteor fd_wpn_upgrade_1; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: WPN Upgrade 2", "give mp_titanweapon_meteor fd_wpn_upgrade_2; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}

void function SetDevMenu_TSniperPanel()
{
	#if UI
	SetupDevCommand( "Equip Plasma Railgun", "give mp_titanweapon_sniper; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Fast Reload", "give mp_titanweapon_sniper fast_reload; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Extended Ammo", "give mp_titanweapon_sniper extended_ammo; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Power Shot", "give mp_titanweapon_sniper power_shot; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Quick Shot", "give mp_titanweapon_sniper quick_shot; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Instant Shot", "give mp_titanweapon_sniper instant_shot; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Burn mod", "give mp_titanweapon_sniper burn_mod_titan_sniper; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Northstar Optics", "give mp_titanweapon_sniper pas_northstar_optics; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Upgrade Charge", "give mp_titanweapon_sniper fd_upgrade_charge; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Upgrade Critical", "give mp_titanweapon_sniper fd_upgrade_crit; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}

void function SetDevMenu_XOPanel()
{
	#if UI
	SetupDevCommand( "Equip XO-16", "give mp_titanweapon_xo16_shorty; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( " ", "give mp" )
	SetupDevCommand( "Weapon Mod: Accelerator", "give mp_titanweapon_xo16_shorty accelerator; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Electric Rounds", "give mp_titanweapon_xo16_shorty electric_rounds; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Fast Reload", "give mp_titanweapon_xo16_shorty fast_reload; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Extended Ammo", "give mp_titanweapon_xo16_shorty extended_ammo; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Burst", "give mp_titanweapon_xo16_shorty burst; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Fire Rate Max Zoom", "give mp_titanweapon_xo16_shorty fire_rate_max_zoom; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod: Burn Mod", "give mp_titanweapon_xo16_shorty burn_mod_titan_xo16; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Arc Rounds", "give mp_titanweapon_xo16_vanguard arc_rounds; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Arc Rounds With Battle Rifle", "give mp_titanweapon_xo16_vanguard arc_rounds_with_battle_rifle; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Battle Rifle", "give mp_titanweapon_xo16_vanguard battle_rifle; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Rapid Reload", "give mp_titanweapon_xo16_vanguard rapid_reload; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Vanguard Weapon 1", "give mp_titanweapon_xo16_vanguard fd_vanguard_weapon_1; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Vanguard Weapon 2", "give mp_titanweapon_xo16_vanguard fd_vanguard_weapon_2; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	SetupDevCommand( "Weapon Mod (Vanguard): Balance", "give mp_titanweapon_xo16_vanguard fd_balance; script Dev_PrintMessage( gp()[0], \"DETECTED A TITAN WEAPON\", \"Switching player POV to titan. To reset, simply choose Disable Titan POV Hands in the dev menu!\", 7, \"UI_CraftingTable_Purchase_Accept_1P\" ); script gp()[0].SetArmsModelOverride( $\"mdl/weapons/arms/buddypov.rmdl\" )" )
	#endif
}


void function SetupThrowables()
{
	#if UI
	// Grenades
	SetupDevCommand( "Grenade: Arc Star", "give mp_weapon_grenade_emp" )
	SetupDevCommand( "Grenade: Frag", "give mp_weapon_frag_grenade" )
	SetupDevCommand( "Grenade: Thermite", "give mp_weapon_thermite_grenade" )

	// Custom Grenades
	if( GetCurrentPlaylistVarBool( "is_halo_gamemode", false ) )
	{
		SetupDevCommand( "Grenade: Halo Frag", "give mp_weapon_frag_grenade_halomod" )
		SetupDevCommand( "Grenade: Halo Plasma  Frag", "give mp_weapon_plasma_grenade_halomod" )
	}
	#endif
}

void function SetupSurvival()
{
	#if UI
		SetupDevCommand( "Toggle Training Completed", "script GP().SetPersistentVar( \"trainingCompleted\", (GP().GetPersistentVarAsInt( \"trainingCompleted\" ) == 0 ? 1 : 0) )" )
		SetupDevCommand( "Enable Survival Dev Mode", "playlist survival_dev" )
		SetupDevCommand( "Disable Match Ending", "mp_enablematchending 0" )
		SetupDevCommand( "Enable Match Ending", "mp_enablematchending 1" )
		SetupDevCommand( "Drop Care Package R1", "script thread AirdropForRound( gp()[0].GetOrigin(), gp()[0].GetAngles(), 0, null )" )
		SetupDevCommand( "Drop Care Package R2", "script thread AirdropForRound( gp()[0].GetOrigin(), gp()[0].GetAngles(), 1, null )" )
		SetupDevCommand( "Drop Care Package R3", "script thread AirdropForRound( gp()[0].GetOrigin(), gp()[0].GetAngles(), 2, null )" )
		SetupDevCommand( "Force Circle Movement", "script thread FlagWait( \"DeathCircleActive\" );script svGlobal.levelEnt.Signal( \"DeathField_ShrinkNow\" );script FlagClear( \"DeathFieldPaused\" )" )
		SetupDevCommand( "Pause Circle Movement", "script FlagSet( \"DeathFieldPaused\" )" )
		SetupDevCommand( "Unpause Circle Movement", "script FlagClear( \"DeathFieldPaused\" )" )
		//SetupDevCommand( "Gladiator Intro Sequence", "script thread DEV_StartGladiatorIntroSequence()" )
		SetupDevCommand( "Bleedout Debug Mode", "script FlagSet( \"BleedoutDebug\" )" )
		SetupDevCommand( "Disable Loot Drops on Death", "script FlagSet( \"DisableLootDrops\" )" )
		SetupDevCommand( "Drop My Death Box", "script thread SURVIVAL_Death_DropLoot_Internal( gp()[0], null, 100, true )" )
	#endif
}


void function SetupSurvivalLoot( var categories )
{
	#if UI
		RunClientScript( "SetupSurvivalLoot", categories )
	#endif
}

void function SetupAbilities()
{
	#if UI
	SetupDevCommand( "Bangalore Tactical", "give mp_weapon_grenade_bangalore" )
	SetupDevCommand( "Bangalore Ultimate", "give mp_weapon_grenade_creeping_bombardment" )
	SetupDevCommand( "Bloodhound Tactical", "give mp_ability_area_sonar_scan" )
	SetupDevCommand( "Bloodhound Ultimate", "give mp_ability_hunt_mode" )
	SetupDevCommand( "Caustic Tactical", "give mp_weapon_dirty_bomb" )
	SetupDevCommand( "Caustic Ultimate", "give mp_weapon_grenade_gas" )
	SetupDevCommand( "Crypto Tactical", "give mp_ability_crypto_drone" )
	SetupDevCommand( "Crypto Ultimate", "give mp_ability_crypto_drone_emp" )
	SetupDevCommand( "Gibraltar Tactical", "give mp_weapon_bubble_bunker" )
	SetupDevCommand( "Gibraltar Ultimate", "give mp_weapon_grenade_defensive_bombardment" )
	SetupDevCommand( "Lifeline Tactical", "give mp_weapon_deployable_medic" )
	SetupDevCommand( "Lifeline Ultimate", "give mp_ability_care_package" )
	SetupDevCommand( "Mirage Tactical", "give mp_ability_holopilot" )
	SetupDevCommand( "Mirage Ultimate", "give mp_ability_mirage_ultimate" )
	SetupDevCommand( "Octane Tactical", "give mp_ability_heal" )
	SetupDevCommand( "Octane Ultimate", "give mp_weapon_jump_pad" )
	SetupDevCommand( "Pathfinder Tactical", "give mp_ability_grapple" )
	SetupDevCommand( "Pathfinder Ultimate", "give mp_weapon_zipline" )
	SetupDevCommand( "Wattson Tactical", "give mp_weapon_tesla_trap" )
	SetupDevCommand( "Wattson Ultimate", "give mp_weapon_trophy_defense_system"  )
	SetupDevCommand( "Wraith Tactical", "give mp_ability_phase_walk" )
	SetupDevCommand( "Wraith Ultimate", "give mp_weapon_phase_tunnel" )
	SetupDevCommand( "Revenant Tactical", "give mp_ability_silence" )
	SetupDevCommand( "Revenant Ultimate", "give mp_ability_revenant_death_totem" )
	#endif
}


void function SetupCustomAbilities()
{
	#if UI
	SetupDevCommand( "Tf2: Pulse Blade", "give mp_weapon_grenade_sonar" )
	SetupDevCommand( "Tf2: Amped Wall", "give mp_weapon_deployable_cover" )
	SetupDevCommand( "Tf2: Electric Smoke", "give mp_weapon_grenade_electric_smoke" )

	SetupDevCommand( "Dev: 3Dash", "give mp_ability_3dash" )
	SetupDevCommand( "Dev: Cloak", "give mp_ability_cloak" )

	//Husaria
	SetupDevCommand( "Dev: Concussive Breach", "give mp_weapon_concussive_breach" )
	SetupDevCommand( "Dev: Flashbang Grenade", "give mp_weapon_grenade_flashbang" )
	// + passive Shotgun Kick (PAS_SHOTGUN_KICK)

	//Jericho
	SetupDevCommand( "Dev: Riot Shield", "give mp_ability_riot_shield" )
	SetupDevCommand( "Dev: Malestrom Javelin", "give mp_ability_maelstrom_javelin" )

	//Prophet
	SetupDevCommand( "Dev: Spotter Sight", "give mp_ability_spotter_sight" )

	//Nomad
	SetupDevCommand( "Dev: Loot Compass", "give mp_ability_loot_compass" )

	//Forge
	SetupDevCommand( "Dev: Ground Slam", "give mp_ability_ground_slam" )

	//Skunner
	SetupDevCommand( "Dev: Debris Trap", "give mp_weapon_debris_trap" )
	SetupDevCommand( "Dev: Grenade Barrier", "give mp_weapon_grenade_barrier" )
	// + passive light step (PAS_LIGHT_STEP)

	SetupDevCommand( "Dev: Cover Wall", "give mp_weapon_cover_wall_proto" )

	SetupDevCommand( "Dev: Split Timeline", "give mp_ability_split_timeline" )
	SetupDevCommand( "Dev: Sonic Shout", "give mp_ability_sonic_shout" )

	SetupDevCommand( "Dev: Haunt", "give mp_ability_haunt" )
	SetupDevCommand( "Dev: Dodge Roll", "give mp_ability_dodge_roll" )

	// SetupDevCommand( "Tf2: Gravity Star", "give mp_weapon_grenade_gravity" ) //(cafe) it needs to be added to the datatable, but this means a new grenade, we should probably find a different approach for this weapon, probably make it offhand like an ultimate
	#endif
}

void function SetupSurvivalIncapShieldBot()
{
	#if UI
	SetupDevCommand( "Spawn Bot with Lv 1 Incap Shield", "script Dev_SpawnBotWithIncapShieldToView( 1 )" )
	SetupDevCommand( "Spawn Bot with Lv 2 Incap Shield", "script Dev_SpawnBotWithIncapShieldToView( 2 )" )
	SetupDevCommand( "Spawn Bot with Lv 3 Incap Shield", "script Dev_SpawnBotWithIncapShieldToView( 3 )" )
	SetupDevCommand( "Spawn Bot with Lv 4 Incap Shield", "script Dev_SpawnBotWithIncapShieldToView( 4 )" )
	SetupDevCommand( "Spawn Bot with a Random Incap Shield", "script Dev_SpawnBotWithIncapShieldToView( -1 )" )
	#endif
}

void function SetupFriendlyNPC()
{
	#if UI
	//Friendly NPCs
	//SetupDevCommand( "Friendly NPC: Stalker", "script DEV_SpawnStalkerAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Gunship", "script DEV_SpawnGunshipAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Dummie",  "script DEV_SpawnDummyAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Plasma Drone", "script DEV_SpawnPlasmaDroneAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Rocket Drone", "script DEV_SpawnRocketDroneAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Loot Tick", "script SpawnLootTickAtCrosshair()" )
	SetupDevCommand( "Friendly NPC: Prowler", "script DEV_SpawnProwlerAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Marvin", "script DEV_SpawnMarvinAtCrosshair(gp()[0].GetTeam())" )
	//SetupDevCommand( "Friendly NPC: Soldier", "script DEV_SpawnSoldierAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Spider", "script DEV_SpawnSpiderAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Infected", "script DEV_SpawnInfectedSoldierAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Tick", "script DEV_SpawnExplosiveTickAtCrosshair(gp()[0].GetTeam())" )
	#endif
}

void function SetupEnemyNPC()
{
	#if UI
	//Enemy NPCs
	//SetupDevCommand( "Enemy NPC: Stalker", "script DEV_SpawnStalkerAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Gunship", "script DEV_SpawnGunshipAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Dummie", "script DEV_SpawnDummyAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Plasma Drone", "script DEV_SpawnPlasmaDroneAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Rocket Drone", "script DEV_SpawnRocketDroneAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Legend", "script DEV_SpawnLegendAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Prowler", "script DEV_SpawnProwlerAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Marvin", "script DEV_SpawnMarvinAtCrosshair()" )
	//SetupDevCommand( "Enemy NPC: Soldier", "script DEV_SpawnSoldierAtCrosshair()" )//Come back to this NPC later, we have animations and models but they are unstable -lorrylekral
	SetupDevCommand( "Enemy NPC: Spider", "script DEV_SpawnSpiderAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Infected", "script DEV_SpawnInfectedSoldierAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Tick", "script DEV_SpawnExplosiveTickAtCrosshair()" )
	#endif
}

void function SetupEditor()
{
	#if UI
	SetupDevCommand( "Start Editing", "give mp_weapon_editor" )
	SetupDevCommand( "Zipline", "give mp_weapon_zipline" )
	#endif
}

const array<string> CUSTOM_COSMETICS_FILTER_LIST = [
	"None",
	"Empty"
]

const bool CUSTOM_COSMETICS_FILTERING_ENABLED = true

void function SetDevMenu_CustomCosmetics( var _ )
{
	thread ChangeToThisMenu( SetupCustomCosmetics )
}


void function SetupCustomCosmetics()
{
	array<string> categories = []
	foreach( LoadoutEntry entry in GetAllLoadoutSlots() )
	{
		if ( !categories.contains( entry.DEV_category ) )
			categories.append( entry.DEV_category )
	}
	categories.sort()
	foreach( string category in categories )
	{
		// Only show categories that have available items after filtering
		if ( CategoryHasAvailableItems( category ) )
		{
			SetupDevMenu( category, void function( var unused ) : ( category ) {
				thread ChangeToThisMenu( void function() : ( category ) {
					SetupCustomCosmetics_CategoryScreen( category )
				} )
			} )
		}
	}
}


void function SetupCustomCosmetics_CategoryScreen( string category )
{
	array<LoadoutEntry> entries = clone GetAllLoadoutSlots()
	entries.sort( int function( LoadoutEntry a, LoadoutEntry b ) {
		if ( a.DEV_name < b.DEV_name )
			return -1
		if ( a.DEV_name > b.DEV_name )
			return 1
		return 0
	} )

	array<string> charactersUsed = []

	foreach( LoadoutEntry entry in  entries)
	{
		if ( entry.DEV_category != category )
			continue

		string prefix = "character_"

		if ( entry.DEV_name.find( prefix ) == 0 )
		{
			string character = GetCharacterNameFromDEV_name( entry.DEV_name )

			if ( !charactersUsed.contains( character ) )
			{
				charactersUsed.append( character )

				// Check if character has available items after filtering
				if ( CharacterHasAvailableItems( category, character ) )
				{
					SetupDevMenu( character, void function( var unused ) : ( category, character ) {
						thread ChangeToThisMenu( void function() : ( category, character ) {
							SetupCustomCosmetics_CategoryScreenForCharacter( category, character )
						} )
					} )
				}
			}
		}
		else
		{
			SetupDevMenu( entry.DEV_name, void function( var unused ) : ( entry ) {
				thread ChangeToThisMenu( void function() : ( entry ) {
					SetupCustomCosmetics_SlotScreen( entry )
				} )
			} )
		}
	}
}

void function SetupCustomCosmetics_CategoryScreenForCharacter( string category, string character )
{
	array<LoadoutEntry> entries = clone GetAllLoadoutSlots()
	entries.sort( int function( LoadoutEntry a, LoadoutEntry b ) {
		if ( a.DEV_name < b.DEV_name )
			return -1
		if ( a.DEV_name > b.DEV_name )
			return 1
		return 0
	} )

	array< LoadoutEntry > entriesToUse

	foreach( LoadoutEntry entry in entries )
	{
		if ( entry.DEV_category != category )
			continue

		string entryCharacter = GetCharacterNameFromDEV_name( entry.DEV_name )

		if ( entryCharacter != character )
			continue

		entriesToUse.append( entry )
	}


	if ( entriesToUse.len() > 1 )
	{
		foreach ( LoadoutEntry entry in entriesToUse )
		{
			SetupDevMenu( entry.DEV_name, void function( var unused ) : ( entry ) {
				thread ChangeToThisMenu( void function() : ( entry ) {
					SetupCustomCosmetics_SlotScreen( entry )
				} )
			} )
		}
	}
	else if ( entriesToUse.len() == 1 )
	{
		LoadoutEntry entry = entriesToUse[ 0 ]
		SetupCustomCosmetics_SlotScreen( entry )
	}
}

bool function ShouldFilterCustomCosmeticItem( ItemFlavor item )
{
	if ( !CUSTOM_COSMETICS_FILTERING_ENABLED )
		return false

	string itemName = Localize( ItemFlavor_GetLongName( item ) )

	foreach ( string filteredName in CUSTOM_COSMETICS_FILTER_LIST )
	{
		if ( itemName == filteredName )
			return true
	}

	return false
}

bool function CharacterHasAvailableItems( string category, string character )
{
	if ( !CUSTOM_COSMETICS_FILTERING_ENABLED )
		return true  // If filtering is disabled, always show characters

	array<LoadoutEntry> entries = clone GetAllLoadoutSlots()

	foreach( LoadoutEntry entry in entries )
	{
		if ( entry.DEV_category != category )
			continue

		string entryCharacter = GetCharacterNameFromDEV_name( entry.DEV_name )

		if ( entryCharacter != character )
			continue

		// Get items for this entry and check if any remain after filtering
		array<ItemFlavor> flavors = DEV_GetValidCustomItemFlavorsForLoadoutSlot( LocalClientEHI(), entry )

		foreach( ItemFlavor item in flavors )
		{
			if ( !ShouldFilterCustomCosmeticItem( item ) )
				return true  // Found at least one non-filtered item
		}
	}

	return false  // No items available after filtering
}

// Helper function to check if a category has any available items after filtering
bool function CategoryHasAvailableItems( string category )
{
	if ( !CUSTOM_COSMETICS_FILTERING_ENABLED )
		return true  // If filtering is disabled, always show categories

	array<LoadoutEntry> entries = clone GetAllLoadoutSlots()

	foreach( LoadoutEntry entry in entries )
	{
		if ( entry.DEV_category != category )
			continue

		// Check if this entry has any available items
		string prefix = "character_"

		if ( entry.DEV_name.find( prefix ) == 0 )
		{
			// Character-specific entry - check if character has available items
			string character = GetCharacterNameFromDEV_name( entry.DEV_name )
			if ( CharacterHasAvailableItems( category, character ) )
				return true
		}
		else
		{
			// Non-character entry - check items directly
			array<ItemFlavor> flavors = DEV_GetValidCustomItemFlavorsForLoadoutSlot( LocalClientEHI(), entry )

			foreach( ItemFlavor item in flavors )
			{
				if ( !ShouldFilterCustomCosmeticItem( item ) )
					return true  // Found at least one non-filtered item
			}
		}
	}

	return false  // No items available after filtering in this category
}

void function SetupCustomCosmetics_SlotScreen( LoadoutEntry entry )
{
	array<ItemFlavor> flavors = clone DEV_GetValidCustomItemFlavorsForLoadoutSlot( LocalClientEHI(), entry )

	// Apply filtering if enabled
	if ( CUSTOM_COSMETICS_FILTERING_ENABLED )
	{
		for ( int i = flavors.len() - 1; i >= 0; i-- )
		{
			if ( ShouldFilterCustomCosmeticItem( flavors[i] ) )
			{
				flavors.remove( i )
			}
		}
	}

	flavors.sort( int function( ItemFlavor a, ItemFlavor b ) {
		string textA = Localize( ItemFlavor_GetLongName( a ) )
		string textB = Localize( ItemFlavor_GetLongName( b ) )

		//
		if ( textA.slice( 0, 1 ) == "[" && textB.slice( 0, 1 ) != "[" )
			return -1

		if ( textA.slice( 0, 1 ) != "[" && textB.slice( 0, 1 ) == "[" )
			return 1

		if ( textA < textB )
			return -1

		if ( textA > textB )
			return 1

		return 0
	} )

	foreach( ItemFlavor flav in flavors )
	{
		SetupDevFunc( Localize( ItemFlavor_GetLongName( flav ) ), void function( var unused ) : ( entry, flav ) {
			DEV_RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), entry, flav )
		} )
	}
}