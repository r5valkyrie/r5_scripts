                   
global function LifelineTT_Init
global function IsLifelineTTEnabled
global function GetLifelineTTAssetsToPrecache

//Playlist Vars
const string LIFELINETT_PLAYLIST_ENABLE_MEDKIT_SPAWNS = "lifeline_tt_medkit_spawns"
const string LIFELINETT_PLAYLIST_ENABLE_JAMROOM = "lifeline_tt_jamroom_enabled"
const string LIFELINETT_PLAYLIST_ENABLE_INSTRUMENTS = "lifeline_tt_jamroom_use_enabled"
const string LIFELINETT_PLAYLIST_SMARTDROP_MODE = "lifeline_tt_smartdrop_mode"
const string LIFELINETT_PLAYLIST_SMARTDROP_DELAY_SEC = "lifeline_tt_smartdrop_delay"
const string LIFELINETT_PLAYLIST_ENABLE_CENTER_LOOT = "lifeline_tt_center_loot"

//Loot
const string LIFELINETT_LOOT_KEYWORD = "lifeline_tt_loot"
const string LIFELINETT_CENTER_LOOT_SCRIPTNAME = "lifeline_tt_medbay_loot"

//Care Package
enum eSmartDropMode
{
	DISABLED,
	SINGLE,
	MULTI,
	AUTO_SINGLE,
	AUTO_MULTI
}

const string CONSOLE_SCRIPT_NAME = "lifeline_tt_smartdrop_console"
const string SMARTDROP_LOCATION_SCRIPT_NAME = "lifeline_tt_smartdrop_location"

const float SMARTDROP_DELAY_SEC = 5

//Instruments
enum eJamRoomInstruments
{
	GUITAR = 0,
	BASS = 1,
	DRUMS = 2
}

const string JAMROOM_INSTRUMENT_SCRIPT_NAME = "jamroom_instrument"

const string JAMROOM_GUITAR_TARGET_NAME = "jamroom_guitar"
const string JAMROOM_BASS_TARGET_NAME = "jamroom_bass"
const string JAMROOM_DRUMS_TARGET_NAME = "jamroom_drums"

const string MDL_JAMROOM_DRUMS = "mdl/olympus/olympus_ll_tt_prop_wall_drums_01.rmdl"

//MUSIC
const string JAMROOM_MUSIC_SCRIPT_NAME = "lifeline_tt_jamroom_music"
const string JAMROOM_MUSIC_SPLINE_SCRIPT_NAME = "Lifeline_TT_Emitter"
const string JAMROOM_MUSIC_CODE_CONTROLLER_SCRIPT_NAME = "lifeline_tt_music_controller"

const int JAMROOM_AMBIENT_CONTROL = 0
const int JAMROOM_DRUM_CONTROL = 100
const int JAMROOM_BASS_CONTROL = 125
const int JAMROOM_GUITAR_CONTROL = 150
const float JAMROOM_STEM_RESET_TIME_SEC = 15

const int JAMROOM_DRUM_USABLE_DIST = 64
const int JAMROOM_GUITAR_USABLE_DIST = 64
const int JAMROOM_BASS_USABLE_DIST = 64

const table<int, int> JAMROOM_INSTRUMENT_STEMS = {
	[eJamRoomInstruments.GUITAR] = JAMROOM_GUITAR_CONTROL,
	[eJamRoomInstruments.BASS] = JAMROOM_BASS_CONTROL,
	[eJamRoomInstruments.DRUMS] = JAMROOM_DRUM_CONTROL
}

struct InstrumentData
{
	int instrumentType
}

//SFX
const string SFX_CONSOLE_USE_1P = "Canyonlands_Scr_Pilon_Initiate"
const string SFX_CONSOLE_USE_3P = "Canyonlands_Scr_Pilon_Initiate_3P"

const string SFX_JAMROOM_MUSIC = "music_tt_lifeline_jamroom"

const string SFX_JAMROOM_GUITAR = "Olympus_LifelineTT_JamRoom_Guitar_Interact"
const string SFX_JAMROOM_BASS = "Olympus_LifelineTT_JamRoom_Bass_Interact"
const string SFX_JAMROOM_DRUMS = "Olympus_LifelineTT_JamRoom_Drums_Interact"

const table<int, string> JAMROOM_INSTRUMENT_SFX = {
	[eJamRoomInstruments.GUITAR] = SFX_JAMROOM_GUITAR,
	[eJamRoomInstruments.BASS] = SFX_JAMROOM_BASS,
	[eJamRoomInstruments.DRUMS] = SFX_JAMROOM_DRUMS
}

struct SmartDropData
{
	vector origin
	vector angles
}

struct
{
	#if SERVER
		table< entity, InstrumentData >                         instruments
		int                                                     musicValue = JAMROOM_AMBIENT_CONTROL
		entity                                                  musicEntity
		int                                                     smartDropMode = eSmartDropMode.SINGLE
		table< entity, array< SmartDropData > >                 smartDrops
		bool													instrumentsInfoTargetsFound = false
	#endif
} file

bool function GetLifelineTTAssetsToPrecache( array< string > models, array< string > particles )
{
	if ( IsLifelineTTEnabled() == false )
	{
		return false
	}

	//This file
	models.append( MDL_JAMROOM_DRUMS )

	//sh_medical_bay.gnut
	models.append( MDL_MEDBAY_EYE_JOINT )
	models.append( MDL_MEDBAY_EYE_STALK )
	models.append( MDL_MEDBAY_RING )

	particles.append( VFX_MEDBAY_HEAL_COCKPIT_1P )
	particles.append( VFX_MEDBAY_PLATFORM )
	particles.append( VFX_MEDBAY_SPARKS )
	particles.append( VFX_MEDBAY_CROSS )
	particles.append( VFX_MEDBAY_CROSS_PULSE )

	return true
}

void function LifelineTT_Init()
{
	#if SERVER
		AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	#endif

	#if CLIENT
		AddCreateCallback( "prop_dynamic", JamRoom_OnPropDynamicCreated )
	#endif
}

void function EntitiesDidLoad()
{
	if ( !IsLifelineTTEnabled() )
		return

	PrecacheScriptString( JAMROOM_MUSIC_CODE_CONTROLLER_SCRIPT_NAME )
	PrecacheScriptString( GENERIC_PING_PANEL_SCRIPTNAME )
	PrecacheScriptString( GENERIC_PING_PANEL_SCRIPTNAME_INACTIVE )

	#if SERVER
		//thread LifelineTT_SpawnLoot() // Moving to mp_rr_olympus_common.nut
		thread LifelineTT_SpawnCenterLoot()
		thread JamRoom_Init()
		thread SmartDrop_Init()
	#endif
}

//Loot Spawning
#if SERVER
//void function LifelineTT_SpawnLoot()
//{
//	if ( !GetCurrentPlaylistVarBool( LIFELINETT_PLAYLIST_ENABLE_MEDKIT_SPAWNS, true ) )
//		return
//
//	ResourceCollection rc = ORS_Find_( ORS_GetGlobalGroup(), eSearchFlags.NONE, [eORType.LOOT_SPAWN], [LIFELINETT_LOOT_KEYWORD], [] )
//	foreach ( lootSpawn in rc.lootSpawns )
//	{
//		if ( lootSpawn.spawned )
//			return
//
//		string lootRef = lootSpawn.lootRef
//		LootData data  = SURVIVAL_Loot_GetLootDataByRef( lootRef )
//		entity loot    = SpawnGenericLoot( lootRef, lootSpawn.core.spawnOrigin, lootSpawn.core.spawnAngles, data.countPerDrop )
//		lootSpawn.spawned = true
//	}
//}

void function LifelineTT_SpawnCenterLoot()
{
	if ( !GetCurrentPlaylistVarBool( LIFELINETT_PLAYLIST_ENABLE_CENTER_LOOT, true ) )
		return

	array<string> lootRefs = SURVIVAL_GetAllRefsInLootGroup( "lifeline_tt_medbay_loot" )
	if ( lootRefs.len() == 0 )
		return

	array<entity> lootTargets = GetEntArrayByScriptName( LIFELINETT_CENTER_LOOT_SCRIPTNAME )

	foreach ( entity target in lootTargets )
	{
		string lootRef = lootRefs.getrandom()
		SpawnGenericLoot( lootRef, target.GetOrigin(), target.GetAngles() )
		target.Destroy()
	}
}
#endif //LOOT

//JAM ROOM - INTERACTIVE STEMS
#if SERVER
void function JamRoom_Init()
{
	if ( !GetCurrentPlaylistVarBool( LIFELINETT_PLAYLIST_ENABLE_JAMROOM, true ) )
		return

	array<entity> controllerTargets = GetEntArrayByScriptName( JAMROOM_MUSIC_SCRIPT_NAME )
	if ( controllerTargets.len() == 1 )
	{
		entity target = controllerTargets[0]
		JamRoom_InitMusicEntity( target.GetOrigin() )
		target.Destroy()
	}

	if ( !GetCurrentPlaylistVarBool( LIFELINETT_PLAYLIST_ENABLE_INSTRUMENTS, true ) )
		return

	array<entity> instrumentsArray = GetEntArrayByScriptName( JAMROOM_INSTRUMENT_SCRIPT_NAME )

	file.instrumentsInfoTargetsFound = instrumentsArray.len() > 0

	foreach ( entity instrumentTarget in instrumentsArray )
	{
		switch( instrumentTarget.GetTargetName() )
		{
			case JAMROOM_GUITAR_TARGET_NAME:
				entity instrument = JamRoom_CreateInstrument( instrumentTarget.GetOrigin(), instrumentTarget.GetAngles(), EMPTY_MODEL )
				JamRoom_CreateUsableInstrument( instrument, eJamRoomInstruments.GUITAR, JAMROOM_GUITAR_USABLE_DIST, "#PRESS_TO_USE_GENERIC" ) //"#LIFELINE_TT_USE_GUITAR" )
				break

			case JAMROOM_BASS_TARGET_NAME:
				entity instrument = JamRoom_CreateInstrument( instrumentTarget.GetOrigin(), instrumentTarget.GetAngles(), EMPTY_MODEL )
				JamRoom_CreateUsableInstrument( instrument, eJamRoomInstruments.BASS, JAMROOM_BASS_USABLE_DIST, "#PRESS_TO_USE_GENERIC" )//"#LIFELINE_TT_USE_BASS")
				break

			case JAMROOM_DRUMS_TARGET_NAME:
				entity instrument = JamRoom_CreateInstrument( instrumentTarget.GetOrigin(), instrumentTarget.GetAngles(), GetAssetFromString( MDL_JAMROOM_DRUMS ) )
				JamRoom_CreateUsableInstrument( instrument, eJamRoomInstruments.DRUMS, JAMROOM_DRUM_USABLE_DIST, "#PRESS_TO_USE_GENERIC" )//"#LIFELINE_TT_USE_DRUMS" )
				break
		}
		instrumentTarget.Destroy()
	}
}

void function JamRoom_InitMusicEntity( vector origin )
{
	file.musicEntity = CreatePropDynamic_NoDispatchSpawn( EMPTY_MODEL, origin, <0, 0, 0>, SOLID_NONE )
	file.musicEntity.SetScriptName( JAMROOM_MUSIC_CODE_CONTROLLER_SCRIPT_NAME )
	DispatchSpawn( file.musicEntity )
}

void function JamRoom_CreateUsableInstrument( entity instrument, int instrumentType, int usableDistanceOverride, string usableString )
{
	JamRoom_SetInstrumentUsableState( instrument )
	instrument.SetUsableDistanceOverride( usableDistanceOverride )
	instrument.SetUsablePriority( USABLE_PRIORITY_LOW )
	instrument.SetUsePrompts( usableString, usableString )
	instrument.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BLOCK_CONTINUOUS_USE )

	AddCallback_OnUseEntity_ServerOnly( instrument, JamRoom_OnUseInstrument )

	Assert( !(instrument in file.instruments), "Jam Room already contains specified instrument" )

	InstrumentData data
	data.instrumentType = instrumentType
	file.instruments[instrument] <- data
}

entity function JamRoom_CreateInstrument( vector origin, vector angles, asset mdl )
{
	entity prop = CreatePropDynamic( mdl, origin, angles, SOLID_NONE )
	prop.Hide()
	return prop
}

void function JamRoom_SetInstrumentUsableState( entity instrument )
{
	if ( !IsValid( instrument ) )
		return

	instrument.SetUsable()
	instrument.SetUsableByGroup( "pilot" )
}

void function JamRoom_OnUseInstrument( entity instrument, entity user, int useInputFlags )
{
	if ( !IsValid( instrument ) )
		return

	Assert( instrument in file.instruments, "Jam Room does not contain specified instrument to play" )

	instrument.UnsetUsable()

	int instrumentType = file.instruments[instrument].instrumentType
	EmitSoundOnEntity( instrument, JAMROOM_INSTRUMENT_SFX[instrumentType] )
	JamRoom_AddStem( JAMROOM_INSTRUMENT_STEMS[instrumentType] )
	thread JamRoom_ResetInstrument_Thread( instrument, JAMROOM_STEM_RESET_TIME_SEC )
}

void function JamRoom_ResetInstrument_Thread( entity instrument, float waitTimeSec )
{
	instrument.EndSignal( "OnDeath" )
	instrument.EndSignal( "OnDestroy" )
	wait waitTimeSec
	//Subtract the stem
	JamRoom_AddStem( -JAMROOM_INSTRUMENT_STEMS[file.instruments[instrument].instrumentType] )
	JamRoom_SetInstrumentUsableState( instrument )
}

void function JamRoom_AddStem( int value )
{
	printt( "Jam Room Adding Value: " + value )
	file.musicValue += value
	if ( IsValid( file.musicEntity ) )
	{
		file.musicEntity.SetSoundCodeControllerValue( float(file.musicValue) )
	}
	printt( "Jam Room New Value: " + file.musicValue )
}


void function JamRoom_ClearStems()
{
	file.musicValue = JAMROOM_AMBIENT_CONTROL
	if ( IsValid( file.musicEntity ) )
	{
		file.musicEntity.SetSoundCodeControllerValue( float(file.musicValue) )
	}
}
#endif

#if CLIENT
void function JamRoom_OnPropDynamicCreated( entity ent )
{
	if ( ent.GetScriptName() == JAMROOM_MUSIC_CODE_CONTROLLER_SCRIPT_NAME )
		JamRoom_InitClientAmbient( ent )
}

void function JamRoom_InitClientAmbient( entity controller )
{
	if ( IsValid( controller ) )
	{
		array<entity> ambientGenerics = GetEntArrayByScriptName( JAMROOM_MUSIC_SPLINE_SCRIPT_NAME )
		if ( ambientGenerics.len() == 1 )
		{
			entity ambient = ambientGenerics[0]
			ambient.SetSoundCodeControllerEntity( controller )
		}
	}
}
#endif

//CARE PACKAGE (SmartDrop)
#if SERVER
void function SmartDrop_Init()
{
	file.smartDropMode = GetCurrentPlaylistVarInt( LIFELINETT_PLAYLIST_ENABLE_JAMROOM, eSmartDropMode.SINGLE )

	if ( file.smartDropMode == eSmartDropMode.DISABLED )
		return

	if ( file.smartDropMode == eSmartDropMode.SINGLE || file.smartDropMode == eSmartDropMode.MULTI )
	{
		array<entity> consoles = GetEntArrayByScriptName( CONSOLE_SCRIPT_NAME )
		foreach ( entity console in consoles )
		{
			SmartDrop_InitConsole( console )
		}
	}
}

void function SmartDrop_InitConsole( entity console )
{
	if ( !IsValid( console ) )
		return
	array<entity> linkedEnts = console.GetLinkEntArray()
	foreach ( entity linkedEnt in linkedEnts )
	{
		if ( linkedEnt.GetScriptName() == SMARTDROP_LOCATION_SCRIPT_NAME )
		{
			SmartDropData data
			data.origin = linkedEnt.GetOrigin()
			data.angles = linkedEnt.GetAngles()

			if ( !(console in file.smartDrops) )
			{
				array<SmartDropData > dropsArray
				file.smartDrops[console] <- dropsArray
			}

			file.smartDrops[console].append( data )

			CreateNonExpiringAirdropBadPlace( data.origin, AIR_DROP_BAD_PLACE_RADIUS )

			linkedEnt.Destroy()
		}
	}

	console.SetScriptName( GENERIC_PING_PANEL_SCRIPTNAME )
	SmartDrop_SetConsoleUsableState( console )
}

void function SmartDrop_SetConsoleUsableState( entity console )
{
	if ( !IsValid( console ) )
		return

	AddCallback_OnUseEntity_ServerOnly( console, SmartDrop_OnUseConsole )

	console.SetUsable()
	console.SetUsePrompts( "#LIFELINE_TT_CAREPACKAGE_ACTIVATE", "#LIFELINE_TT_CAREPACKAGE_ACTIVATE" )
	console.SetUsableByGroup ( "pilot" )
	console.SetUsablePriority( USABLE_PRIORITY_LOW )
	console.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BLOCK_CONTINUOUS_USE )
	console.SetSkin( 1 )
}


void function SmartDrop_SetConsoleUsed( entity console )
{
	if ( !IsValid( console ) )
		return

	console.SetSkin( 2 )
	console.SetScriptName( GENERIC_PING_PANEL_SCRIPTNAME_INACTIVE )
	console.UnsetUsable()
}

array<SmartDropData> function SmartDrop_DataFromConsole( entity console )
{
	Assert( console in file.smartDrops, "Console not found in lifeline tt smart drops table" )

	return file.smartDrops[console]
}

void function SmartDrop_OnUseConsole( entity console, entity user, int useInputFlags )
{
	if ( !IsValid( user ) || !user.IsPlayer() )
		return

	SmartDrop_SetConsoleUsed( console )
	EmitSoundAtPositionOnlyToPlayer( TEAM_UNASSIGNED, console.GetCenter(), user, SFX_CONSOLE_USE_1P )
	EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, console.GetCenter(), user, SFX_CONSOLE_USE_3P )

	array<SmartDropData> dataArray = SmartDrop_DataFromConsole( console )

	if ( dataArray.len() == 0 ) //Bad data, get out
		return

	BroadcastCommsActionToTeam( user, eCommsAction.PING_CAREPACKAGE_INCOMING, user, user.GetOrigin(), eCommsFlags.NO_TEXT, "" )

	if ( file.smartDropMode == eSmartDropMode.SINGLE )
	{
		SmartDropData data = dataArray[0]
		thread SmartDrop_DropCarePackage( user, data.origin, data.angles )
	}
	else if ( file.smartDropMode == eSmartDropMode.MULTI )
	{
		SmartDropData data = dataArray.getrandom()
		dataArray.fastremovebyvalue( data ) //we've already used it, so remove it
		thread SmartDrop_DropCarePackageInRadius( user, data.origin, data.angles, 2000 )
	}
}

void function SmartDrop_DropCarePackage( entity owner, vector origin, vector angles )
{
	if ( !IsValid( owner ) || !owner.IsPlayer() )
		return

	//Play voiceline
	//diag_mp_ash_ping_carepackageincoming_calm_1p

	float airdropDelay = GetCurrentPlaylistVarFloat( LIFELINETT_PLAYLIST_SMARTDROP_DELAY_SEC, SMARTDROP_DELAY_SEC )

	/*
	array<entity> fxs

	int beamIndex   = GetParticleSystemIndex( $"P_ar_loot_drop_point_far" )
	int markerIndex = GetParticleSystemIndex( $"P_ar_loot_drop_point" )
	entity beamFx   = StartParticleEffectInWorld_ReturnEntity( beamIndex, origin, <0, 0, 0> + <0, 180, 0> )
	entity markerFx = StartParticleEffectInWorld_ReturnEntity( markerIndex, origin, <0, 0, 0> )
	beamFx.RemoveFromAllRealms()
	beamFx.AddToOtherEntitysRealms( owner )
	markerFx.RemoveFromAllRealms()
	markerFx.AddToOtherEntitysRealms( owner )
	fxs.append( beamFx )
	fxs.append( markerFx )

	OnThreadEnd(
		function () : ( fxs )
		{
			foreach ( fx in fxs )
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}
		}
	)*/

	float pingDuration = 15.0//airdropDelay + 15.0

	const float spreadRadius = 1.0
	const float ringRadius = 50.0
	const float frequency = 0.8
	const float freqVariation = 0.2

	foreach ( player in GetPlayerArray_Alive() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SUR_PingMinimap", origin, pingDuration, spreadRadius, ringRadius, COLORID_AIRDROP_DEFAULT_COLOR, frequency, freqVariation, eAirdropType.STANDARD )

	/*
	wait airdropDelay

	foreach ( fx in fxs )
	{
		if ( IsValid( fx ) )
			EffectStop( fx )
	}
	fxs.clear()*/

	//AddSurvivalCommentaryEvent( eSurvivalEventType.CARE_PACKAGE_DROPPING )

	array< array<string> > contents //= [ ["blue_kitted_weapons"], ["health_pickup_combo_large"], ["health_pickup_combo_large"] ]

	AirdropItemsOptionalInfo optionInfo
	optionInfo.animationName      = "droppod_loot_drop_lifeline"
	optionInfo.owner              = owner
	optionInfo.team               = owner.GetTeam()
	optionInfo.skin               = 0
	optionInfo.targetName         = CARE_PACKAGE_TARGETNAME//CARE_PACKAGE_LIFELINE_TARGETNAME
	optionInfo.forceDefaultColor  = true
	optionInfo.delayedContentFunc = GenerateSmartCarePackageContents

	thread CreateCarePackageAirdrop( origin, angles, contents, optionInfo )
}

void function SmartDrop_DropCarePackageInRadius( entity player, vector origin, vector angles, float radius )
{
	//printt( "Dropping Care Package Multi" )
}
#endif //CARE PACKAGE (SmartDrop)

bool function IsLifelineTTEnabled()
{
	if ( GetCurrentPlaylistVarBool( "lifeline_tt_enabled", true ) )
	{
		#if SERVER
			return HasEntWithScriptName( JAMROOM_INSTRUMENT_SCRIPT_NAME ) || file.instrumentsInfoTargetsFound
		#else
			return HasEntWithScriptName( JAMROOM_MUSIC_SPLINE_SCRIPT_NAME )
		#endif
	}

	return false
}
                         
 