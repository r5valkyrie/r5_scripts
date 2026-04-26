#if SERVER
	global function ClientCommand_DestroyDummys
	global function MovementRecorder_SetPlaybackRate
#endif

#if CLIENT
	global function FS_MovementRecorder_UpdateHints
	global function FS_MovementRecorder_CreateInputHintsRUI
#endif

global function Sh_FS_MovementRecorder_Init
#if SERVER || CLIENT
global function MeleeSkin_GetMainWeaponClassname
global function MeleeSkin_GetOffhandWeaponClassname
#endif
#if SERVER
global function CharacterSelect_AssignCharacter
#endif

struct RecordingAnimation
{
	vector origin
	vector angles
	var anim
}

const int MAX_SLOT = 5
const int MAX_NPC_BUDGET = 120 //dirty cap
const int DUMMY_MAX_HEALTH = 100

struct
{
	#if CLIENT
		array<var> inputHintLines
		table<string,string> playerOriginalBindings
	#endif

	#if SERVER
		int playbackLimit = -1
		table<int, table<int, array<entity> > > playerDummyMaps //[ehandle][slot] = dummy
		table<int, table<int,int> > playerPlaybackAmounts = {} //[ehandle][slot] = amount

		float helmet_lv4 = 0.65
		float adminSetPlaybackRate = 1.0
		bool bDummyDeathNotifications = true
		bool bAutoRefilAmmoOnHit
		float randomPlaybackDelay = 0.2

		table<int, array<entity> > _dummyMaps__Template = {
			[ 0 ] = [ null ],
			[ 1 ] = [ null ],
			[ 2 ] = [ null ],
			[ 3 ] = [ null ],
			[ 4 ] = [ null ]
		}

		table <int, int> _playbackAmounts__Template = {
			[ 0 ] = 0,
			[ 1 ] = 0,
			[ 2 ] = 0,
			[ 3 ] = 0,
			[ 4 ] = 0
		}

	#endif

} file

const table<string,int> keyNameToKeyCodeMap =
{

}

enum GameMovementImpactEventType
{
	GM_IET_LANDING = 0
	GM_IET_WALLSLAM
	GM_IET_WALLSLAM_AIR
	GM_IET_HUMANFOOTSTEP
	GM_IET_TITANFOOTSTEP

	GM_IET_COUNT
	GM_IET_INVALID
}

void function Sh_FS_MovementRecorder_Init()
{
    if( Playlist() != ePlaylists.Movement_Recorder )
        return

	#if CLIENT
		AddCallback_OnClientScriptInit( FS_MovementRecorder_SetBindings )
		AddClientCallback_OnResolutionChanged( FS_MovementRecorder_OnResolutionChanged )
	#endif

	#if SERVER
		disableoverwrite( file._playbackAmounts__Template )
		disableoverwrite( file._dummyMaps__Template )

		AddCallback_OnClientConnected( FS_MovementRecorder_OnPlayerConnected )
		AddCallback_OnClientDisconnected( _HandlePlayerDisconnect )
		AddCallback_OnPlayerRespawned( _HandleRespawn )
		AddCallback_OnPlayerKilled( _OnPlayerKilled )

		AddClientCommandCallback( "recorder_toggleRecorder", ClientCommand_ToggleMovementRecorder )
		AddClientCommandCallback( "PlayAnimInSlot", ClientCommand_PlayAnimInSlot )
		AddClientCommandCallback( "PlayAllAnims", ClientCommand_PlayAllAnims )
		AddClientCommandCallback( "recorder_recorderHideHud", ClientCommand_HideHud )
		AddClientCommandCallback( "recorder_toggleContinueLoop", ClientCommand_ToggleContinueLoop )
		AddClientCommandCallbackVoid( "DestroyDummys", ClientCommand_DestroyDummys )

		RegisterSignal( "EndDummyThread" )
		RegisterSignal( "FinishedRecording" )
		RegisterSignal( "PlayRandomAnimation" )

		foreach( k,v in file._playbackAmounts__Template )
		{
			RegisterSignal( "EndDummyThread_Slot_" + k.tostring() )
		}

		file.playbackLimit 				= GetCurrentPlaylistVarInt( "flowstate_limit_playback_per_slot_amount", -1 )
		file.helmet_lv4 				= GetCurrentPlaylistVarFloat( "helmet_lv4", 0.65 )
		file.bDummyDeathNotifications 	= GetCurrentPlaylistVarBool( "register_dummie_kill_as_actual_kill", false )
		file.bAutoRefilAmmoOnHit		= GetCurrentPlaylistVarBool( "auto_refill_ammo_on_hit", false )
		file.randomPlaybackDelay		= GetCurrentPlaylistVarFloat( "delay_between_random_playback", 0.2 )
	#endif
}

#if SERVER
bool function MessagePlayer_Disabled( entity player, array<string> args )
{
	LocalEventMsg( player, "#DisabledTDMWeps" )
	return true
}

void function MovementRecorder_SetupWeapons( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return

	if( Playlist() == ePlaylists.fs_movementrecorder && !FlowState_AdminTgive() )
	{
		entity primary = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		entity secondary = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 )

		player.RefillAllAmmo()

		if( IsValid( primary ) )
			SetupInfiniteAmmoForWeapon( player, primary )

		if( IsValid( secondary ) )
			SetupInfiniteAmmoForWeapon( player, secondary )
	}
}

void function MovementRecorder_SetPlaybackRate( float value )
{
	file.adminSetPlaybackRate = value
}

table ornull function MovementRecorder_GetPlayerActiveWeaponData( entity player )
{
	if( !IsValid( player ) )
		return null

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if( !IsValid( weapon ) )
		return null

	string weaponName = weapon.GetWeaponClassName()
	if( weaponName == "" )
		return null

	table data = {}
	data[ "name" ] <- weaponName

	return data
}

void function MovementRecorder_ApplyWeaponToDummy( entity dummy, table ornull weaponData )
{
	if( !IsValid( dummy ) )
		return

	if( weaponData == null )
		return

	table wd = expect table( weaponData )

	if( !( "name" in wd ) )
		return

	string weaponName = string( wd[ "name" ] )
	if( weaponName == "" )
		return

	array<string> mods = []

	entity givenWeapon = null
	if( mods.len() > 0 )
		givenWeapon = dummy.GiveWeapon( weaponName, WEAPON_INVENTORY_SLOT_ANY, mods )
	else
		givenWeapon = dummy.GiveWeapon( weaponName, WEAPON_INVENTORY_SLOT_ANY )

	if( IsValid( givenWeapon ) )
		dummy.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponName )
}

string function MovementRecorder_GetPlayerCharacterRef( entity player )
{
	if( !IsValid( player ) )
		return "character_wraith"

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	return ItemFlavor_GetHumanReadableRef( character )
}

string function MovementRecorder_GetDummyAISettingsFromCharacterRef( string characterRef )
{
	if( characterRef == "" )
		return "npc_dummie_wraith"

	string aiName = characterRef
	const string prefix = "character_"
	if( aiName.find( prefix ) == 0 )
		aiName = aiName.slice( prefix.len() )

	if( aiName == "" )
		aiName = "wraith"

	return "npc_dummie_" + aiName
}
#endif

//shared
string function slotname( int slot )
{
	switch( slot )
	{
		case 1: return "[F3]";
		case 2: return "[F4]";
		case 3: return "[F5]";
		case 4: return "[F6]";
		case 5: return "[F7]";
		default: return "";
	}

	unreachable
}

#if CLIENT

// Todo(mk): Create BindSystem_ framework for any game mode to use during development for client scripts,
// saves current bindings, adds a disconnect callback to restore binds, proper checking.. etc
// will need to handle gamepad as well as various bind types (held) etc.
// save for next release, for now, this recorder specific logic.

const table<string,string> RECORDER_BINDINGS =
{
	["F2"] = "recorder_toggleRecorder",
	["F3"] = "\"PlayAnimInSlot 0\"",
	["F4"] = "\"PlayAnimInSlot 1\"",
	["F5"] = "\"PlayAnimInSlot 2\"",
	["F6"] = "\"PlayAnimInSlot 3\"",
	["F7"] = "\"PlayAnimInSlot 4\"",
	["F8"] = "PlayAllAnims",
	["F12"] = "recorder_toggleContinueLoop"
}

void function FS_MovementRecorder_SetBindings( entity player )
{
	MovementRecorder_SaveCurrentBindings()
	AddCallback_OnPlayerDisconnected( FS_MovementRecorder_ResetAllBindings )

	foreach( key, command in RECORDER_BINDINGS )
		player.ClientCommand( "bind_US_standard " + key + " " + command )

	FS_MovementRecorder_CreateInputHintsRUI( false )
}

void function MovementRecorder_SaveCurrentBindings()
{

}

string function MovementRecorder_GetSavedBindCommand( string keyName )
{
	if( keyName in file.playerOriginalBindings )
		return file.playerOriginalBindings[ keyName ]

	return ""
}

void function FS_MovementRecorder_ResetAllBindings( entity player )
{
	if( player != GetLocalClientPlayer() )
		return

	foreach( keyName, _ in RECORDER_BINDINGS )
	{
		string commandToRestore = MovementRecorder_GetSavedBindCommand( keyName )

		if( commandToRestore == "" )
			player.ClientCommand( "unbind " + keyName )
		else
			player.ClientCommand( "bind_US_standard " + keyName + " " + commandToRestore )
	}
}

void function FS_MovementRecorder_CreateInputHintsRUI( bool state )
{
	foreach( line in file.inputHintLines )
		if( line != null )
		{
			RuiDestroyIfAlive( line )
		}

	file.inputHintLines.clear()

	if( state )
		return

	UISize screenSize = GetScreenSize()
	const float hudScale = 0.7
	var topo = RuiTopology_CreatePlane( <( screenSize.width * 0.33),( screenSize.height * 0 ), 0>, <float( screenSize.width ) * hudScale, 0, 0>, <0, float( screenSize.height ) * hudScale, 0>, false )
	var hintRui = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui, "buttonText", "%F2%" )
	RuiSetString( hintRui, "gamepadButtonText", "%F2%" )
	RuiSetString( hintRui, "hintText", "Start Recording" )
	RuiSetString( hintRui, "altHintText", "" )
	RuiSetInt( hintRui, "hintOffset", 0 )
	RuiSetBool( hintRui, "hideWithMenus", false )
	file.inputHintLines.append( hintRui )

	var hintRui2 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui2, "buttonText", "%F3%" )
	RuiSetString( hintRui2, "gamepadButtonText", "%F3%" )
	RuiSetString( hintRui2, "hintText", "Slot [F3] - Empty" )
	RuiSetString( hintRui2, "altHintText", "" )
	RuiSetInt( hintRui2, "hintOffset", 1 )
	RuiSetBool( hintRui2, "hideWithMenus", false )
	file.inputHintLines.append( hintRui2 )

	var hintRui3 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui3, "buttonText", "%F4%" )
	RuiSetString( hintRui3, "gamepadButtonText", "%F4%" )
	RuiSetString( hintRui3, "hintText", "Slot [F4] - Empty" )
	RuiSetString( hintRui3, "altHintText", "" )
	RuiSetInt( hintRui3, "hintOffset", 2 )
	RuiSetBool( hintRui3, "hideWithMenus", false )
	file.inputHintLines.append( hintRui3 )

	var hintRui4 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui4, "buttonText", "%F5%" )
	RuiSetString( hintRui4, "gamepadButtonText", "%F5%" )
	RuiSetString( hintRui4, "hintText", "Slot [F5] - Empty" )
	RuiSetString( hintRui4, "altHintText", "" )
	RuiSetInt( hintRui4, "hintOffset", 3 )
	RuiSetBool( hintRui4, "hideWithMenus", false )
	file.inputHintLines.append( hintRui4 )

	var hintRui5 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui5, "buttonText", "%F6%" )
	RuiSetString( hintRui5, "gamepadButtonText", "%F6%" )
	RuiSetString( hintRui5, "hintText", "Slot [F6] - Empty" )
	RuiSetString( hintRui5, "altHintText", "" )
	RuiSetInt( hintRui5, "hintOffset", 4 )
	RuiSetBool( hintRui5, "hideWithMenus", false )
	file.inputHintLines.append( hintRui5 )

	var hintRui6 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui6, "buttonText", "%F7%" )
	RuiSetString( hintRui6, "gamepadButtonText", "%F7%" )
	RuiSetString( hintRui6, "hintText", "Slot [F7] - Empty" )
	RuiSetString( hintRui6, "altHintText", "" )
	RuiSetInt( hintRui6, "hintOffset", 5 )
	RuiSetBool( hintRui6, "hideWithMenus", false )
	file.inputHintLines.append( hintRui6 )

	var hintRui7 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui7, "buttonText", "%F8%" )
	RuiSetString( hintRui7, "gamepadButtonText", "%F8%" )
	RuiSetString( hintRui7, "hintText", "Play All Anims" )
	RuiSetString( hintRui7, "altHintText", "" )
	RuiSetInt( hintRui7, "hintOffset", 6 )
	RuiSetBool( hintRui7, "hideWithMenus", false )
	file.inputHintLines.append( hintRui7 )

	var hintRui8 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui8, "buttonText", "%F12%" )
	RuiSetString( hintRui8, "gamepadButtonText", "%F12%" )
	RuiSetString( hintRui8, "hintText", "Loop Anim: ON" )
	RuiSetString( hintRui8, "altHintText", "" )
	RuiSetInt( hintRui8, "hintOffset", 7 )
	RuiSetBool( hintRui8, "hideWithMenus", false )
	file.inputHintLines.append( hintRui8 )

	var hintRui9 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui9, "buttonText", "%$rui/menu/buttons/tip%" )
	RuiSetString( hintRui9, "gamepadButtonText", "%$rui/menu/buttons/tip%" )
	RuiSetString( hintRui9, "hintText", "Crouch + Slot to clear" )
	RuiSetString( hintRui9, "altHintText", "" )
	RuiSetInt( hintRui9, "hintOffset", 8 )
	RuiSetBool( hintRui9, "hideWithMenus", false )
	file.inputHintLines.append( hintRui9 )

	var hintRui10 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui10, "buttonText", "%$rui/menu/buttons/tip%" )
	RuiSetString( hintRui10, "gamepadButtonText", "%$rui/menu/buttons/tip%" )
	RuiSetString( hintRui10, "hintText", "Crouch + %F8% = clearall" )
	RuiSetString( hintRui10, "altHintText", "" )
	RuiSetInt( hintRui10, "hintOffset", 9 )
	RuiSetBool( hintRui10, "hideWithMenus", false )
	file.inputHintLines.append( hintRui10 )

	var hintRui11 = RuiCreate( $"ui/tutorial_hint_line.rpak", topo, RUI_DRAW_POSTEFFECTS, MINIMAP_Z_BASE + 10 )
	RuiSetString( hintRui11, "buttonText", "%$rui/menu/buttons/tip%" )
	RuiSetString( hintRui11, "gamepadButtonText", "%$rui/menu/buttons/tip%" )
	RuiSetString( hintRui11, "hintText", "Crouch + %F2% = random" )
	RuiSetString( hintRui11, "altHintText", "" )
	RuiSetInt( hintRui11, "hintOffset", 10 )
	RuiSetBool( hintRui11, "hideWithMenus", false )
	file.inputHintLines.append( hintRui11 )
}

void function FS_MovementRecorder_UpdateHints( int hint, bool state, float duration )
{
	if( file.inputHintLines[ hint ] == null )
		return

	if( hint == 0 && state )
	{
		RuiSetString( file.inputHintLines[0], "hintText", "Stop Recording" )
		return
	} else if( hint == 0 && !state )
	{
		RuiSetString( file.inputHintLines[0], "hintText", "Start Recording" )
		return
	}

	if( hint == 7 && state )
	{
		RuiSetString( file.inputHintLines[hint], "hintText", "Loop Anim: ON" )
		return
	}
	else if( hint == 7 && !state )
	{
		RuiSetString( file.inputHintLines[hint], "hintText", "Loop Anim: OFF" )
		return
	}

	if( state )
	{
		DisplayTime dt = SecondsToDHMS( duration.tointeger() )
		RuiSetString( file.inputHintLines[hint], "hintText", "Slot " + slotname(hint) + " - Play " + format( "%.2d:%.2d", dt.minutes, dt.seconds ) )
		return
	} else if( !state )
	{
		RuiSetString( file.inputHintLines[hint], "hintText", "Slot " + slotname(hint) + " - Empty" )
		return
	}
}

void function FS_MovementRecorder_OnResolutionChanged()
{
	FS_MovementRecorder_CreateInputHintsRUI( false )
}
#endif //CLIENT

#if SERVER

void function _HandlePlayerDisconnect( entity player )
{
	int playerHandle = player.p.handle

	ForceStopRecording( player )

	foreach ( slot, dummies in file.playerDummyMaps[playerHandle] )
			DestroyDummyForSlot( player, slot, playerHandle )
}

void function _HandleRespawn( entity player )
{
	AssignCharacter( player, 8 )
}

void function _OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	ForceStopRecording( victim )
}

void function FS_MovementRecorder_OnPlayerConnected( entity player )
{
	player.p.recordingAnims.resize( MAX_SLOT )
	player.p.recordingAnimsCoordinates.resize( MAX_SLOT )
	player.p.recordingAnimsChosenCharacters.resize( MAX_SLOT )
	player.p.recordingAnimsWeaponData.resize( MAX_SLOT )

	FS_MovementRecorder_PlayerInit( player )
	SetTeam( player, 2 )

	thread AssignCharacterOnFirstSpawn( player )
}

void function AssignCharacterOnFirstSpawn( entity player )
{
	WaitFrame()
	WaitFrame()

	if ( !IsValid( player ) )
		return

	AssignCharacter( player, 8 )
}

void function FS_MovementRecorder_PlayerInit( entity player )
{
	if ( !IsValid( player ) )
		return

	int playerHandle = player.p.handle

	table<int, array<entity> > init_playerDummyMap 	= clone file._dummyMaps__Template
	table<int,int> init_playerPlaybackAmounts 		= clone file._playbackAmounts__Template

	file.playerPlaybackAmounts[ playerHandle ] <- init_playerPlaybackAmounts
	file.playerDummyMaps[ playerHandle ] <- init_playerDummyMap
}

bool function ClientCommand_ToggleMovementRecorder( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return false

	bool bPlayRandom = player.IsInputCommandHeld( IN_DUCK )

	if( bPlayRandom )
	{
		if( !bDoesAnyAnimationExist( player ) )
		{
			if( !player.p.recorderHideHud )
				LocalEventMsg( player, "#NO_ANIMS", "", 3 )

			return true
		}

		if( !IsOverBudget( player ) )
			thread PlayRandomAnimation( player )

		return true
	}

	if( player.p.isRecording )
	{
		StopRecordingAnimation( player )
	}
	else
	{
		int slot = FS_MovementRecorder_GetEmptySlotForPlayer( player )

		if( slot == -1 )
		{
			if( !player.p.recorderHideHud )
				LocalEventMsg( player, "#NO_SLOTS" )

			return true
		}

		if( !IsAlive( player ) )
			DecideRespawnPlayer( player, true )

		player.p.isRecording = true
		thread StartRecordingAnimation( player )
	}

	return true
}

bool function ClientCommand_PlayAnimInSlot( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return false

	if( !CheckRate( player, "play_anim", COMMAND_RATE_LIMIT, true ) )
		return true

	if( args.len() == 0 )
		return false

	int slot = 0

	if( IsStringNumeric( args[ 0 ] ) )
	{
		slot = args[ 0 ].tointeger()
	}
	else
	{
		#if DEVELOPER
			printt( "Invalid commmand sent" )
		#endif
		return false
	}

	bool remove = player.IsInputCommandHeld( IN_DUCK )

	if( !remove && !HasSlotAllocation( player, slot ) )
	{
		return true
	}

	thread PlayAnimInSlot( player, slot, remove )
		return true
}

bool function ClientCommand_PlayAllAnims( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return false

	bool remove = player.IsInputCommandHeld( IN_DUCK )

	if( !player.p.recorderHideHud )
	{
		string token = remove ? "#REMOVING_ALL_ANIMS" : "#PLAYING_ALL_ANIMS";
		LocalEventMsg( player, token )
	}

	bool removeAll = false

	if( remove )
	{
		removeAll = true
	}


	for( int i = 0; i < MAX_SLOT ; i++ )
		thread PlayAnimInSlot( player, 	i, remove, removeAll )

	return true
}

bool function ClientCommand_HideHud(entity player, array<string> args)
{
	if( !IsValid( player ) )
		return false

	if( player.p.recorderHideHud )
	{
		player.p.recorderHideHud = false
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_CreateInputHintsRUI", false )
	}
	else if( !player.p.recorderHideHud )
	{
		player.p.recorderHideHud = true
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_CreateInputHintsRUI", true )
	}
	return true
}

bool function ClientCommand_ToggleContinueLoop(entity player, array<string> args)
{
	if( !IsValid( player ) )
		return false

	if( player.p.continueLoop )
	{
		player.p.continueLoop = false
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", 7, false, 0 )
	}
	else if( !player.p.continueLoop )
	{
		player.p.continueLoop = true
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", 7, true, 0 )
	}
	return true
}

void function StartRecordingAnimation( entity player )
{
	if( !IsValid( player ) )
		return

	if( !player.p.isRecording )
		mAssert( false, "Tried to spawn recording thread without setting state." )

	player.p.currentOrigin = player.GetOrigin()
	player.p.currentAngles = player.GetAngles()
	player.p.currentRecordingWeaponData = MovementRecorder_GetPlayerActiveWeaponData( player )
	player.p.currentRecordingCharacterRef = MovementRecorder_GetPlayerCharacterRef( player )

	string msg1

	msg1 = "RECORDING MOVEMENT"

	if( !player.p.recorderHideHud )
	{
		LocalEventMsg( player, "#RECORDINGANIM_CUSTOM", msg1, 6 )
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", 0, true, 0 )
	}

	player.StartRecordingAnimation( player.p.currentOrigin, player.p.currentAngles )

	OnThreadEnd
	(
		void function() : ( player )
		{
			if( IsValid( player ) )
			{
				if( player.p.isRecording )
					StopRecordingAnimation( player )
			}
		}
	)

	//(mk): Recording animations disappear after 2:30, hard-set limit of 3000 frames.
	waitthread WaitSignalOrTimeout( player, 148, "OnDestroy", "OnDisconnected", "FinishedRecording" )
}

void function ForceStopRecording( entity player )
{
	if( !player.p.isRecording )
		return

	player.StopRecordingAnimation()
	player.p.isRecording = false

	LocalEventMsg( player, "#SPACE", "", 1 )
	Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", 0, false, -1 )
}

int function FS_MovementRecorder_GetEmptySlotForPlayer( entity player )
{
	foreach( int i, var anim in player.p.recordingAnims )
	{
		if( anim == null )
			return i
	}

	return -1
}
void function StopRecordingAnimation( entity player )
{
	if( !player.p.isRecording )
		return

	int slot = FS_MovementRecorder_GetEmptySlotForPlayer( player )

	if( slot == -1 )
	{
		if( !player.p.recorderHideHud )
			LocalEventMsg( player, "#NO_SLOTS" )

		ForceStopRecording( player )

		return
	}

	LocPair animData
	animData.origin = player.p.currentOrigin
	animData.angles = player.p.currentAngles

	player.p.recordingAnims[ slot ] = player.StopRecordingAnimation(); player.p.isRecording = false
	player.p.recordingAnimsCoordinates[ slot ] = animData
	player.p.recordingAnimsChosenCharacters[ slot ] = player.p.currentRecordingCharacterRef
	player.p.recordingAnimsWeaponData[ slot ] = player.p.currentRecordingWeaponData
	player.Signal( "FinishedRecording" ) //(mk): cleanup watcher thread.

	if( !player.p.recorderHideHud )
	{
		LocalEventMsg( player, "#MOVEMENT_IS_SAVED", slotname( slot + 1 ) )
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", 0, false, 0 )

		var anim = player.p.recordingAnims[ slot ]
		float duration = GetRecordedAnimationDuration( anim )
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", slot + 1, true, duration )
	}
}

const array<string> r5vDevs =
[
	"CafeFPS",
	"zee_x64",
    "LorryLeKral",
	"Glitch"
]

bool function bDoesAnyAnimationExist( entity player )
{
	if( !IsValid( player ) )
		return false

	int playerHandle = player.p.handle

	if( !( playerHandle in file.playerDummyMaps ) )
		return false

	foreach( slot, dummyArray in file._dummyMaps__Template )
	{
		if ( player.p.recordingAnims[ slot ] != null )
			return true
	}

	return false
}

void function PlayRandomAnimation( entity player )
{
	if( !IsValid( player ) )
		return

	ClientCommand_DestroyDummys( player, [] )
	player.Signal( "PlayRandomAnimation" )
	EndSignal( player, "OnDisconnected", "OnDestroy", "PlayRandomAnimation" )

	int slot;
	int playerHandle = player.p.handle

	if( !player.p.recorderHideHud )
		LocalMsg( player, "#PLAYING_RANDOM", "#PLAYING_RANDOM_DESC" )

	OnThreadEnd
	(
		void function() : ( player, slot )
		{
			if( IsValid( player ) )
			{
				DestroyDummyForSlot( player, slot )
			}
		}
	)

	while( true )
	{
		WaitFrame()

		if( !IsValid( player ) )
			return

		if( !( playerHandle in file.playerDummyMaps ) )
			return

		array<int> randomSlots = []

		for( int i = 0; i < file._dummyMaps__Template.len(); i++ )
		{
			if( player.p.recordingAnims[i] != null )
				randomSlots.append( i )
		}

		if( randomSlots.len() <= 0 )
		{
			if( !player.p.recorderHideHud )
				LocalEventMsg( player, "#NO_ANIMS" )

			return
		}

		slot = randomSlots.getrandom()
		var anim = player.p.recordingAnims[slot]

		if( anim == null )
			continue

		if( !HasSlotAllocation( player, slot, true ) )
			continue

		PlayAnimInSlot( player, slot, false, false, true )

		//(mk): No need to wait, PlayAnimInSlot() will wait this thread as well.
		//MovementRecorder_WaitForAnimToFinish( anim )

		wait 0.1

		if( !IsValid( player ) || !player.p.continueLoop )
			return

		wait file.randomPlaybackDelay
	}
}

void function PlayAnimInSlot( entity player, int slot, bool remove = false, bool removeAll = false, bool bIsPlayingRandomSlot = false )
{
	if( !remove && !HasSlotAllocation( player, slot ) )
	{
		return
	}

	if( !remove && IsOverBudget( player ) )
	{
		return
	}

	EndSignal( player, "EndDummyThread", "EndDummyThread_Slot_" + slot.tostring() )
	EndSignal( svGlobal.levelEnt, "EndDummyThread" )

	int playerHandle = player.p.handle

	#if DEVELOPER
		printt( "playaniminslot", slot )
	#endif

	var anim = player.p.recordingAnims[slot]

	if( !remove && anim == null )
	{
		if( !player.p.recorderHideHud )
			LocalEventMsg( player, "#ANIM_NOT_FOUND", "", 3 )

		return
	}

	if( remove && anim != null )
	{
		player.p.recordingAnims[ slot ] = null
		player.p.recordingAnimsWeaponData[ slot ] = null
		Remote_CallFunction_NonReplay( player, "FS_MovementRecorder_UpdateHints", slot + 1, false, -1 )

		if( !player.p.recorderHideHud && !removeAll )
			LocalEventMsg( player, "#ANIM_REMOVED_SLOT", slotname( slot + 1 ), 3 )

		DestroyDummyForSlot( player, slot )

		return
	}
	else if( !remove )
	{
		if( !player.p.recorderHideHud )
			LocalEventMsg( player, "#PLAYING_ANIM", slotname( slot + 1 ), 3 )
	}
	else if ( remove )
	{
		return
	}

	vector initialpos = player.p.recordingAnimsCoordinates[ slot ].origin
	vector initialang = player.p.recordingAnimsCoordinates[ slot ].angles

	string aiFileToUse = MovementRecorder_GetDummyAISettingsFromCharacterRef( player.p.recordingAnimsChosenCharacters[ slot ] )


	while( true )
	{
		entity dummy = CreateDummy( 99, initialpos, initialang )
		file.playerPlaybackAmounts[ player.p.handle ][ slot ]++

			EndSignal( player, "EndDummyThread", "EndDummyThread_Slot_" + slot.tostring() )
			EndSignal( svGlobal.levelEnt, "EndDummyThread" )

			OnThreadEnd
			(
				void function() : ( player, dummy, slot )
				{
					if( IsValid( dummy ) )
						RemoveDummyForPlayer( player, dummy, slot )
				}
			)

		vector pos = dummy.GetOrigin()
		vector angles = dummy.GetAngles()
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, angles )
		SetSpawnOption_AISettings( dummy, aiFileToUse )

		dummy.Hide()

		DispatchSpawn( dummy )
		SetDummyProperties( dummy, 2 )
		MovementRecorder_ApplyWeaponToDummy( dummy, player.p.recordingAnimsWeaponData[ slot ] )

		WaitFrame()

		dummy.PlayRecordedAnimation( anim, initialpos, initialang, 0.5 )
		dummy.SetRecordedAnimationPlaybackRate( file.adminSetPlaybackRate )
		dummy.Show()

		file.playerDummyMaps[ playerHandle ][ slot ].append(dummy)

		if( !IsValid( player ) )
			return

		waitthread function () : ( player, anim, dummy, slot )
		{
			EndSignal( dummy, "OnDeath", "OnDestroy" )
			EndSignal( player, "EndDummyThread", "EndDummyThread_Slot_" + slot.tostring() )
			EndSignal( svGlobal.levelEnt, "EndDummyThread" )

			OnThreadEnd( function() : ( player, dummy, slot )
			{
				RemoveDummyForPlayer( player, dummy, slot )
			})

			MovementRecorder_WaitForAnimToFinish( anim ) //(mk):this can be long

			//wait MovementRecorder_GetSlotDuration( player, slot ) / ( file.adminSetPlaybackRate )
		}()

		if( IsValid( player ) && !player.p.continueLoop || bIsPlayingRandomSlot )
		{
			break
		}
	}
}

void function MovementRecorder_WaitForAnimToFinish( var anim )
{
	Assert( IsThreadTop(), "not thread top" )
	//Todo(mk): Implement wait based on playback rate setting for this player, for this slot. (currently global setting)
	wait GetRecordedAnimationDuration( anim ) / ( file.adminSetPlaybackRate * file.adminSetPlaybackRate ) //(mk): don't worry about it.
}

void function RemoveDummyForPlayer( entity player, entity dummy, int slot )
{
	if( !IsValid( dummy ) )
		return

	if( IsValid( player ) && file.playerDummyMaps[ player.p.handle ][ slot ].contains( dummy ) )
		file.playerDummyMaps[ player.p.handle ][ slot ].removebyvalue( dummy )

	if( dummy.IsEntAlive() ) //(mk): only destroy if dummy was still alive, else let damagecode handle
		dummy.Destroy()

	file.playerPlaybackAmounts[ player.p.handle ][ slot ]--;
}

void function DestroyDummyForSlot( entity player, int slot, int playerHandle = -1 )
{
	if( IsValid( player ) )
	{
		player.Signal( "EndDummyThread_Slot_" + string( slot ) )
		playerHandle = player.p.handle
	}

	#if DEVELOPER
		printf( "Destroy %d dummys for slot %d ", file.playerDummyMaps[ playerHandle ][ slot ].len(), slot )
	#endif

	if( !( playerHandle in file.playerDummyMaps ) )
		return

	if ( slot in file.playerDummyMaps[ playerHandle ] )
	{
		foreach( k,slotDummy in file.playerDummyMaps[ playerHandle ][ slot ] )
		{
			if( !IsValid( slotDummy ) )
			{
				continue
			}

			slotDummy.Destroy()

			#if DEVELOPER
				CheckDummyDestroyed( slotDummy )
			#endif
		}
	}
	else
	{
		return
	}

	file.playerDummyMaps[ playerHandle ][ slot ].resize(0)
	file.playerPlaybackAmounts[ playerHandle ][ slot ] = 0
}

void function CheckDummyDestroyed( entity dummy )
{
	mAssert( !IsValid(dummy), "Dummy was not destroyed!!" )
}

// Melee skin weapon classname functions - return defaults
// Note: These are inside #if SERVER block but declared as SERVER || CLIENT
// The CLIENT implementation is below the #endif
#endif // SERVER - temporarily close for these functions

#if SERVER || CLIENT
string function MeleeSkin_GetMainWeaponClassname( ItemFlavor meleeSkin )
{
	return "mp_weapon_melee_survival"
}

string function MeleeSkin_GetOffhandWeaponClassname( ItemFlavor meleeSkin )
{
	return "melee_survival"
}
#endif // SERVER || CLIENT

#if SERVER // reopen SERVER block

// From sh_character_select_new.gnut (commented out in scripts.rson)
bool function CharacterSelect_AssignCharacter( entity player, ItemFlavor character, bool updateLoadoutSlot = true )
{
	TakeAllPassives( player )

	ItemFlavor playerCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

	if ( updateLoadoutSlot && ItemFlavor_GetHumanReadableRef( playerCharacter ) != ItemFlavor_GetHumanReadableRef( character ) )
	{
		SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), character )
	}

	if( Gamemode() != eGamemodes.WINTEREXPRESS )
		player.SetPlayerNetBool( "hasLockedInCharacter", true )

	if( ItemFlavor_GetHumanReadableRef( character ) == "character_wattson" )
		player.SetArmsModelOverride( $"mdl/Weapons/arms/pov_pilot_light_wattson.rmdl" )
	else
		player.SetArmsModelOverride( GetGlobalSettingsAsset( CharacterClass_GetSetFile( character ), "armsModel" ) )

	return true
}

void function AssignCharacter( entity player, int index )
{
	ItemFlavor Character = GetAllCharacters()[ index ]
	CharacterSelect_AssignCharacter( player, Character )

	ItemFlavor playerCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	asset characterSetFile = CharacterClass_GetSetFile( playerCharacter )
	player.SetPlayerSettingsWithMods( characterSetFile, [] )

	// Enable inventory for pickups (key fix!)
	Survival_SetInventoryEnabled( player, true )

	// Give tactical and ultimate abilities
	ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( playerCharacter )
	ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( playerCharacter )
	player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL )
	player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE )

	// Give melee weapon
	ItemFlavor meleeSkin = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_MeleeSkin( playerCharacter ) )
	string meleePrimary = MeleeSkin_GetMainWeaponClassname( meleeSkin )
	string meleeOffhand = MeleeSkin_GetOffhandWeaponClassname( meleeSkin )

	player.TakeOffhandWeapon( OFFHAND_MELEE )
	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )

	player.GiveWeapon( meleePrimary, WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )
	player.GiveOffhandWeapon( meleeOffhand, OFFHAND_MELEE, [] )

	// Enable offhand weapons and unlock controls
	EnableOffhandWeapons( player )
	player.Server_TurnOffhandWeaponsDisabledOff()
	player.UnlockWeaponChange()
	player.DeployWeapon()
    DoRespawnPlayer( player, null )
}

int function ReturnShieldAmountForDesiredLevel( int shield )
{
	switch(shield)
	{
		case 0:
			return 0
		case 1:
			return 50
		case 2:
			return 75
		case 3:
			return 100
		case 4:
			return 125

		default:
			return 50
	}
	unreachable
}

void function SetDummyProperties( entity dummy, int shield )
{
	dummy.SetTitle( r5vDevs.getrandom() )
	dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel( shield ) )
	dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel( shield ) )
	dummy.SetMaxHealth( DUMMY_MAX_HEALTH )
	dummy.SetHealth( DUMMY_MAX_HEALTH )
	dummy.SetDamageNotifications( true )
	dummy.SetTakeDamageType( DAMAGE_YES )
	dummy.SetCanBeMeleed( true )
	AddEntityCallback_OnDamaged( dummy, RecordingAnimationDummy_OnDamaged )

	if( file.bDummyDeathNotifications )
		dummy.SetDeathNotifications( true )

	dummy.SetForceVisibleInPhaseShift( true )
}

void function RecordingAnimationDummy_OnDamaged( entity dummy, var damageInfo )
{
	entity ent = dummy
	entity attacker = DamageInfo_GetAttacker(damageInfo)

	if( !attacker.IsPlayer() )
		return

	float damage = DamageInfo_GetDamage( damageInfo )

	//fake helmet
	float headshotMultiplier = GetHeadshotDamageMultiplierFromDamageInfo(damageInfo)
	float basedamage = DamageInfo_GetDamage( damageInfo )/headshotMultiplier

	if( IsValidHeadShot( damageInfo, dummy ) )
	{
		int headshot = int(basedamage*(file.helmet_lv4+(1-file.helmet_lv4)*headshotMultiplier))
		DamageInfo_SetDamage( damageInfo, headshot)
	}

	if( file.bAutoRefilAmmoOnHit )
		attacker.RefillAllAmmo()
}



void function ClientCommand_DestroyDummys( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return

	string param = ""
	int playerHandle = player.p.handle

	if( args.len() > 0 )
	{
		param = args[ 0 ]
	}

	switch( param )
	{
		case "":

			if( !( player.p.handle in file.playerDummyMaps ) )
				return

			foreach ( slot, dummies in file.playerDummyMaps[ playerHandle ] )
				DestroyDummyForSlot( player, slot )

			if( !player.p.recorderHideHud )
				LocalEventMsg( player, "#RECORDER_ENDALL" )

			break

		case "Admin":


			if( IsValid( svGlobal.levelEnt ) )
			{
				svGlobal.levelEnt.Signal( "EndDummyThread" )
			}

			foreach( pHandle, playbackTable in file.playerPlaybackAmounts )
			{
				foreach( slot, amount in playbackTable )
				{
					amount = 0
				}
			}

			array<entity> dummysToRemove = GetEntArrayByClass_Expensive( "npc_dummie" )

			foreach( dummy in dummysToRemove )
			{
				if( IsValid(dummy) )
				{
					dummy.Destroy()
				}
			}

			foreach( sPlayer in GetPlayerArray() )
			{
				if( !IsValid( sPlayer ) )
					continue

				if( !player.p.recorderHideHud )
					LocalEventMsg( sPlayer, "#ADMIN_RECORDER_ENDALL" )
			}

			break
	}
}

bool function IsOverBudget( entity player, int amountToPlay = 1 )
{
	if ( ( GetEntArrayByClass_Expensive( "npc_dummie" ).len() + amountToPlay ) < MAX_NPC_BUDGET )
	{
		return false
	}
	else
	{
		if( IsValid( player ) )
		{
			if( !player.p.recorderHideHud )
				LocalEventMsg( player, "#OVER_BUDGET" )
		}

		return true
	}

	unreachable
}

bool function HasSlotAllocation( entity player, int slot, bool hidehud = false )
{
	if ( file.playbackLimit > -1 && file.playerPlaybackAmounts[ player.p.handle ][ slot ] >= file.playbackLimit )
	{
		if( !hidehud && !player.p.recorderHideHud )
			LocalEventMsg( player, "#PLAYBACK_LIMIT" )

		return false
	}

	return true
}

bool function CheckRate( entity player, string key = DEFAULT_RATE_KEY, float rate = COMMAND_RATE_LIMIT, bool notify = NOTIFY_RATELIMIT_FAILED )
{
	if ( !IsValid( player ) )
		return false

	if( !( key in player.p.rateLimitTable ) )
		player.p.rateLimitTable[ key ] <- 0

	if ( Time() - player.p.rateLimitTable[ key ] <= rate )
	{
		if( notify )
			LocalEventMsg( player, "#CMD", "", 2 )

		return false
	}

	player.p.rateLimitTable[ key ] = Time()
	return true
}

// void function MovementRecorder_SetSlotDuration( entity player, int slot, float duration )
// {
	// if( !IsValid( player ) )
		// return

	// int playerHandle = player.p.handle

	// if( playerHandle in file.playerPlaybackDurations )
		// file.playerPlaybackDurations[ playerHandle ][ slot ] = duration
// }

// float function MovementRecorder_GetSlotDuration( entity player, int slot )
// {
	// int playerHandle = player.p.handle

	// if( playerHandle in file.playerPlaybackDurations )
	// {
		// if( slot in file.playerPlaybackDurations[ playerHandle ] )
			// return file.playerPlaybackDurations[ playerHandle ][ slot ]
	// }

	// return 0.0
// }

//////////////////////
//		  DEV		//
//////////////////////

#if DEVELOPER
	void function PrintMovementRecorderTable( table< int, table< int, int > > tbl )
	{
		PrintTableTyped( 0, 0, 2, tbl )
	}

	void function PrintTableTyped( int indent, int depth, int maxDepth, table< int, table< int, int > > tbl )
	{
		printt("\n\n")
		printt("--- TABLE ---")

		if ( depth >= maxDepth )
		{
			printt( "{...}" )
			return
		}

		printt( "{" )
		foreach ( k, v in tbl )
		{
			printt( TableIndent( indent + 2 ) + k + " = " )
			PrintNestedTableTyped( indent + 2, depth + 1, maxDepth, v )
		}
		printt( TableIndent( indent ) + "}" )

		printt("\n\n")
	}

	void function PrintNestedTableTyped( int indent, int depth, int maxDepth, table< int, int > tbl )
	{
		if ( depth >= maxDepth )
		{
			printl( "{...}" )
			return
		}

		printt( TableIndent( indent ) + "{" )
		foreach ( k, v in tbl )
		{
			printt( TableIndent( indent + 2 ) + k + " = " + v )
		}
		printt( TableIndent( indent ) + "}" )
	}
#endif //DEVELOPER


#endif //IF SERVER
