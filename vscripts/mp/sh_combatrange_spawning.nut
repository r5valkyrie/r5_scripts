                                            

global function PlaylistVar_CRng_Spawning

global function CombatRange_Init
global function GetCombatRangeRealm

#if DEVELOPER
global function DEV_DebugSpawnPrintOn
#endif // DEVELOPER

#if SERVER
// ----- Settings Functions
global function Get_PlayerFacingDummiesByRealm

// ----- Participants
global function Get_CombatRange_Participants

// ----- Dynamic Spawning
const vector SPAWNPT_VISIBILITYCHECK_OFFSET = < 0, 0, 32 >

global function DynSpawns_AutoStart
global function DynDummie_Spawns_IsEnabled
global function Try_DynDummie_Spawns_Start
global function Try_DynDummie_Spawns_Stop
global function DynDummie_Spawns_Stop
global function CRParticipant_Add
global function CRParticipant_Remove

// DUMMIE Respawn & Refresh functions
global function CRDummies_Get
global function CRDummies_RespawnInPlace
global function CRDummies_SpawnNew
global function UICallback_ClearAndSpawnNewDummies
global function UICallback_RespawnDummiesInPlace
global function UCB_DynSpawns_SetActive

#if DEVELOPER
global bool doDebugSpawnPoints = false

global function DEV_CombatRange_Show_SpawnPoints
global function DEV_CombatRange_CountParticipants
global function DEV_CombatRange_CountSpawnPoints
global function DEV_CombatRange_TestSpawn
global function DEV_DynDummie_Spawns_Start
global function DEV_DynDummie_Spawns_Stop
global function DEV_CombatRange_RecentSpawnPoints
global function DEV_CombatRange_IndicateTargets
global function DEV_CombatRange_CountDummies
global function DEV_CombatRange_ForceDistanceSpawns

global function DEV_CR_Respawn_Dummies

global function DEV_CountDummies_AllRealms
global function DEV_CountDummies


#endif // DEVELOPER

#endif // SERVER

#if CLIENT

global function SCB_DynDummie_Spawns_Changed

#endif // CLIENT

// *******************
// ***** Constants, Enums and Structs
// *******************

const string TARGET_SPAWNPOINT_CLASSNAME = "info_spawnpoint_combatrange_target"
const string TARGET_SPAWNPOINT_CLASSNAME_OLD = "info_spawnpoint_spectre"
const string DUMMIE_SPAWNPOINT_CR_SCRIPTNAME = "dummie_spawn_dynamic_cr"
const string DUMMIE_SPAWNPOINT_FR_SCRIPTNAME = "dummie_spawn_dynamic_fr"

const string DYNAMIC_DUMMIE_TARGETNAME = "dynamic_dummie"

const float COMBATRANGE_MAX = 10000.0
const float TARGET_SPAWN_DELAY = 1.0

const string PLV_CRNG_SPAWNING = "has_combatrange_spawning"
const string PLV_CRNG_RANDOMWEAPONS = "has_combatrange_randomweapons"
const string PLV_CRNG_ANNOUNCER = "has_combatrange_announcer"
const string PLV_DYNAMICDUMMIES_EVERYWHERE = "has_dynamicdummies_everywhere"

const int INVALID_REALM = -99

// ---- Tunables
const int COMBATRANGE_SPAWNPOINT_FACING_THRESHOLD = 60
const int COMBATRANGE_SPAWNPOINT_RECENTUSE_ARRAY_LENGTH = 7

enum eCRng_DummieSpawningTypes
{
	NONE,
	FRESH_SPAWN,
	CULL_RESPAWN,
	REFRESH_RESPAWN,
	DESPAWN,
	COUNT_
}

enum eCRng_AnnounceTypes
{
	SPAWN_STARTING,
	SPAWN_ENDINGSOON,
	SPAWN_DISABLED,
	COUNT_
}

struct CRngTarget
{
	entity targetDummy
	int team
}

// Used to send the spawnpt and its test results to PickSpawnPointAndSpawnDummie().
struct sSpawnLoc
{
	entity spawnPt
	bool isInFacing
	bool isVisible
	array< entity > spawnPts_InRanges
}

struct
{
	#if SERVER

	array < int > activeRealms

	array < entity >spawnPoints = []

	table< int, float > rangeMinsSq
	table< int, float > rangeMaxsSq

	// Shared fields
	int maxDynamicDummies = 4
	float delayBetweenSpawns = 1.0

	// Table of Spawn Statuses indexed by realm.
	table< int, bool > dynDummieSpawns_Started

	// Spawn Points indexed by realm.
	table< int, array< entity > > spawnPtsRecentByRealm

	// Dummie Data
	table< int, array< entity > > dummiesSpawnedInRealm
	table< entity, float > dummieHiddenTime
	table< entity, entity > dummieSpawnPts

	// spawnPt is index, dummie is occupant.
	table< int, table< entity, entity > > spawnPtOccupationsByRealm

	table< int, array< entity > > playerFacingDummiesByRealm

	// Table of Participating players in realm.
	// 	-- Added when they enter trigCombatRangeEnter
	//	-- Removed when they leave trigCombatRangeEnter
	table< int, array< entity > > participants

	table< int, float > lastAnnounceTime

	// Clear Then Fill Semaphores
	table< int, bool > clearingAndFillingInProgress

	// Spawn Everywhere fields
	bool dynamicDummiesEveryhere = false

	#endif // SERVER

	#if CLIENT

	#endif // CLIENT

	#if DEVELOPER
		bool dev_PrintsOn = false
		bool dev_spawnPrintsOn = false
	#endif
} file

// *******************
// ***** Initialization
// *******************

#if SERVER
void function EntitiesDidLoad()
{
	if( !PlaylistVar_CRng_Spawning())
		return

	CombatRange_SpawnPoints_Init()
	thread UpdateDummieFacing_Thread()
}
#endif

void function CombatRange_RegisterRemoteFunctions( )
{
	int settingTypesCount = eCRng_SettingTypes.COUNT_
	int settingChangeTypesCount = eDummieSettingChangeType.COUNT_

	Remote_RegisterServerFunction( "DynSpawns_AutoStart" )

	Remote_RegisterServerFunction( "UCB_DynSpawns_SetActive", "bool" )

	Remote_RegisterServerFunction( "UICallback_ClearAndSpawnNewDummies" )
	Remote_RegisterServerFunction( "UICallback_RespawnDummiesInPlace" )

	Remote_RegisterClientFunction ( "SCB_DynDummie_Spawns_Changed" )
}

void function CombatRange_Init()
{
	// TODO: Make the playlistvar default == false and add the playlistvar to the playlist.
	if( !PlaylistVar_CRng_Spawning() )
		return

	// Kludge: In case the playlist var is missing, Check the mapname and return if it's not the right map.
	string mapName = GetMapName()
	#if DEVELOPER
		printt( format( "%s(): Map Name == %s" , FUNC_NAME(), mapName ))
	#endif

	#if DEVELOPER
		DEV_CombatRangePrint( format( " ***** %s", FUNC_NAME()) )
	#endif

	#if SERVER
		AddCallback_EntitiesDidLoad( EntitiesDidLoad )
		
		// Ranges Squared
		file.rangeMinsSq[ eCRng_SpawnDistances.CQB ] <- MetersToInchesSqr( 5.0 )
		file.rangeMaxsSq[ eCRng_SpawnDistances.CQB ] <- MetersToInchesSqr( 25.0 )
		file.rangeMinsSq[ eCRng_SpawnDistances.MID ] <- MetersToInchesSqr( 25.1 )
		file.rangeMaxsSq[ eCRng_SpawnDistances.MID ] <- MetersToInchesSqr( 50.0 )
		file.rangeMinsSq[ eCRng_SpawnDistances.FAR ] <- MetersToInchesSqr( 50.1 )
		file.rangeMaxsSq[ eCRng_SpawnDistances.FAR ] <- MetersToInchesSqr( 125.0 )
		file.rangeMinsSq[ eCRng_SpawnDistances.VFAR ] <- MetersToInchesSqr( 125.1 )
		file.rangeMaxsSq[ eCRng_SpawnDistances.VFAR ] <- COMBATRANGE_MAX * COMBATRANGE_MAX

		AddCallback_OnPlayerRespawned( OnPlayerSpawned )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )

		RegisterSignal( "CombatRange_Spawning_Started" )
		RegisterSignal( "CombatRange_Spawning_Ended" )
		RegisterSignal( "CombatRange_ClearAndSpawnDummies" )
	#endif

	CombatRange_RegisterRemoteFunctions()
}

#if SERVER
void function CombatRange_SpawnPoints_Init()
{
	array< entity > spawnPts = GetEntArrayByClass_Expensive( TARGET_SPAWNPOINT_CLASSNAME )
	//file.spawnPoints = GetEntArrayByScriptName( DUMMIE_SPAWNPOINT_CR_SCRIPTNAME )
	// FAILSAFE in case we're dealing with an export that didn't have the new spawn point types in it for some reason.
	if( spawnPts.len() == 0 )
	{
		Warning( "Combat Range: " + TARGET_SPAWNPOINT_CLASSNAME + " spawnpoints not found in map. Using spectre spawn points." )
		file.spawnPoints = GetEntArrayByClass_Expensive( TARGET_SPAWNPOINT_CLASSNAME_OLD )
	}
	else if ( IsDynamicDummiesEverywhereOn() )
	{
		file.spawnPoints.extend( spawnPts )
	}
	else // if Not doing dynamicDummiesEverywhere, only use all spawnpoints that are not FR Spawnpints.
	{
		file.spawnPoints = []
		foreach( _spawnPt in spawnPts )
		{
			if( _spawnPt.GetScriptName() != DUMMIE_SPAWNPOINT_FR_SCRIPTNAME )
				file.spawnPoints.append( _spawnPt )
		}
	}

	foreach( spawnpoint in file.spawnPoints )
	{
		spawnpoint.sp.enabled = true
	}
}

void function DynSpawns_AutoStart( entity player )
{
	if( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if( !IsValid( player ) )
		return

	if( !IsCombatRangeMap() )
		return

	entity rangeLeader = RangeMaster_Get_ByPlayer( player )

	if( player == rangeLeader )
	{
		// This enables the On/Off switch in the Menu for the Dynamic Spawning.
		Remote_CallFunction_NonReplay( player, "SCB_DynDummie_Spawns_Changed" )

		bool enabled = FRS_PVar_Get_Bool( player, eFRSettingType.DYNAMICDUMMIESON )
		if( enabled )
		{
			//Try_DynDummie_Spawns_Start( player )
			UCB_SV_FRsetting_DynamicDummiesOn_Changed( player, true, false )
		}
	}
}

bool function IsCombatRangeMap()
{
	return( file.spawnPoints.len() > 0 )
}


void function UCB_DynSpawns_SetActive( entity player, bool isOn )
{
	if( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if( !IsValid( player ) || !player.IsPlayer() )
		return

	int realm = GetCombatRangeRealm( player )
	if( isOn && !DynDummie_Spawns_IsEnabled( realm ))
	{
		Try_DynDummie_Spawns_Start( player )
		FR_ResidentDummies_CreateInRealm( realm )
	}
	else
	{
		Try_DynDummie_Spawns_Stop( player )
		FR_ResidentDummies_DestroyInRealm( realm, true )
	}
}

void function Try_DynDummie_Spawns_Start( entity player )
{
	if( !CanBeParticipant( player ) )
		return

	int realm = GetCombatRangeRealm( player )
	if( !DynDummie_Spawns_IsEnabled( realm ) )
	{
		file.dynDummieSpawns_Started[ realm ] <- true
		ActiveRealmsAdd( realm )

		#if DEVELOPER
			printt( format( "%s(): *** About to spawn dynamic dummies!", FUNC_NAME() ) )
		#endif

		StopAnnounceToPlayersInRealm( realm, eCRng_AnnounceTypes.SPAWN_ENDINGSOON )
		StopAnnounceToPlayersInRealm( realm, eCRng_AnnounceTypes.SPAWN_DISABLED )
		thread DynDummie_Spawns_Thread( realm )
	}
}

void function Try_DynDummie_Spawns_Stop( entity player )
{
	int realm = GetCombatRangeRealm( player )
	StopAnnounceToPlayersInRealm( realm, eCRng_AnnounceTypes.SPAWN_ENDINGSOON )
	StopAnnounceToPlayersInRealm( realm, eCRng_AnnounceTypes.SPAWN_DISABLED )
	if( DynDummie_Spawns_IsEnabled( realm ) )
	{
		DynDummie_Spawns_Stop( realm )
	}
}

// *******************
// ***** CRNG Settings Functions
// *******************
                         

                               
#endif // SERVER

// *******************
// ***** Playlist Var Functions
// *******************

bool function PlaylistVar_CRng_Announcer()
{
	return( GetCurrentPlaylistVarBool( PLV_CRNG_ANNOUNCER, false ) )
}

bool function PlaylistVar_CRng_Spawning()
{
	return( GetCurrentPlaylistVarBool( PLV_CRNG_SPAWNING, true ) )
}

bool function PlaylistVar_CRng_RandomWeapons()
{
	return( GetCurrentPlaylistVarBool( PLV_CRNG_RANDOMWEAPONS, false ) )
}

bool function PlaylistVar_DynamicDummiesEverywhere()
{
	return( GetCurrentPlaylistVarBool( PLV_DYNAMICDUMMIES_EVERYWHERE, false ) )
}

// *******************
// ***** Query Functions
// *******************
#if SERVER
bool function IsSpawnPointValid( entity refPlayer, entity spawnPoint, int realm, array< vector > dummieLocs )
{
	if( !IsValid( spawnPoint ) )
		return false

	if( DummieSpawnPt_IsOccupied( realm, spawnPoint ) )
		return false

	if( IsSpawnPointRecentlyUsed( realm, spawnPoint ) )
		return false

	// Test proximity to other spawned dummies. Invalid if too close to an existing dummie.
	if( dummieLocs.len() > 0 )
	{
		const float DUMMIE_MINDIST_SQ = 300 * 300
		vector loc = spawnPoint.GetOrigin()
		foreach( _dummieloc in dummieLocs )
		{
			if( DistanceSqr( loc, _dummieloc ) < DUMMIE_MINDIST_SQ )
				return false
		}
	}

	return true
}

// TEMP Scripted function to check visibility.
bool function IsVisibleTo( entity refPlayer, vector origin  )
{
	TraceResults trace = TraceLine( refPlayer.EyePosition(), origin, refPlayer, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
	if ( trace.fraction == 1.0 )
	{
		//#if DEVELOPER
		//	DEV_CombatRangePrint( format( "Origin %s visible to Player %s", string( origin ), string( refPlayer ) ) )
		//#endif
		return true
	}

	return false
}

bool function IsInRanges( entity player, entity target, table< int, bool > spawnDistSettings )
{
	if( !IsValid( player ) )
		return false

	float distSq = DistanceSqr( player.GetOrigin(), target.GetOrigin())

	if( spawnDistSettings[ eCRng_SpawnDistances.CQB ] )
	{
		if(( distSq >= file.rangeMinsSq[ eCRng_SpawnDistances.CQB ] ) && ( distSq < file.rangeMaxsSq[ eCRng_SpawnDistances.CQB ] ))
			return( true )
	}

	if( spawnDistSettings[ eCRng_SpawnDistances.MID ] )
	{
		if(( distSq >= file.rangeMinsSq[ eCRng_SpawnDistances.MID ] ) && ( distSq < file.rangeMaxsSq[ eCRng_SpawnDistances.MID ] ))
			return( true )
	}

	if( spawnDistSettings[ eCRng_SpawnDistances.FAR ] )
	{
		if(( distSq >= file.rangeMinsSq[ eCRng_SpawnDistances.FAR ] ) && ( distSq < file.rangeMaxsSq[ eCRng_SpawnDistances.FAR ] ))
			return( true )
	}

	if( spawnDistSettings[ eCRng_SpawnDistances.VFAR ] )
	{
		if( distSq >= file.rangeMinsSq[ eCRng_SpawnDistances.VFAR ] )
			return( true )
	}

	return( false )
}

bool function DynDummie_Spawns_IsEnabled( int realm )
{
	if( !( realm in file.dynDummieSpawns_Started ) )
	{
		file.dynDummieSpawns_Started[ realm ] <- false
	}

	return( file.dynDummieSpawns_Started[ realm ] )
}

bool function DynDummie_Spawns_IsAtCapacity( int realm )
{
	//int dummieCount = DummiesInRealm_Count( realm )
	bool atCapacity = file.dummiesSpawnedInRealm[ realm ].len() >= file.maxDynamicDummies
	return( atCapacity )
}

// *******************
// ***** Dynamic Dummies Everywhere Functions
// *******************

bool function IsDynamicDummiesEverywhereOn()
{
	return( PlaylistVar_DynamicDummiesEverywhere() && file.dynamicDummiesEveryhere )
}

void function SetDynamicDummiesEverywhere( bool isOn = true )
{
	file.dynamicDummiesEveryhere = isOn
}

#endif // SERVER

// *******************
// ***** Realm Functions
// *******************

#if SERVER
void function ActiveRealmsAdd( int realm )
{
	if( realm < 0 )
		return

	if( !( file.activeRealms.contains( realm ) ) )
	{
		file.activeRealms.append( realm )
	}
}

void function ActiveRealmsRemove( int realm )
{
	if( file.activeRealms.contains( realm ) )
	{
		file.activeRealms.fastremovebyvalue( realm )
	}
}
#endif // SERVER

// *******************
// ***** Settings Functions
// *******************

#if SERVER
array< entity > function Get_PlayerFacingDummiesByRealm( int realm )
{
	return( file.playerFacingDummiesByRealm[ realm ] )
}

#endif // SERVER

// *******************
// ***** Spawnpoint Functions
// *******************

#if SERVER
array < entity > function Get_TargetSpawnPoints()
{
	return( file.spawnPoints )
}

sSpawnLoc function PickSpawnLoc( entity refPlayer, bool debugDraws = false )
{
	array < entity > spawnPts = Get_TargetSpawnPoints()
	array < entity > spawnPts_InRanges 						= [] // IsSpawnPointValid() and in enabled ranges.
	array < entity > spawnPts_InRangesNotFacing 			= []
	array < entity > spawnPts_InRangesInFacing 				= [] // Also InRanges.

	#if DEVELOPER
		float debugShowTime = 10
		vector debugColor
		float debugSize
	#endif

	// Cache all refplayer-related reused info.
	int realm = GetCombatRangeRealm( refPlayer )
	table< int, bool > spawnDistSettings = GetSpawnDistanceSettings( refPlayer )

	array< vector > dummieLocs
	foreach( spawnedDummie in file.dummiesSpawnedInRealm[ realm ] )
	{
		dummieLocs.append( spawnedDummie.GetOrigin() )
	}

	foreach( spawnPoint in spawnPts )
	{
		// 1. Check Validity
		if( !IsSpawnPointValid( refPlayer, spawnPoint, realm, dummieLocs ) )
			continue

		// 2. Check ranges.
		if( !IsInRanges( refPlayer,spawnPoint, spawnDistSettings ) )
			continue

		#if DEVELOPER
			debugColor = < 64, 64, 64 >
			debugSize = 5.0
		#endif
		spawnPts_InRanges.append( spawnPoint )

		// 3. Check facing.
		// Try 2D for more heigh variety.
		if( IsFacing( refPlayer, spawnPoint, COMBATRANGE_SPAWNPOINT_FACING_THRESHOLD, false, true ) )
		{
			spawnPts_InRangesInFacing.append( spawnPoint )
		}
		else // Not in facing, but still in ranges.
		{
			spawnPts_InRangesNotFacing.append( spawnPoint )
			#if DEVELOPER
				debugColor = COLOR_ORANGE
				debugSize = 25.0
			#endif
		}

		#if DEVELOPER
			if( doDebugSpawnPoints && debugDraws && IsValid( spawnPoint ))
				DEV_debugDrawSpawnPoint( spawnPoint.GetOrigin(), debugSize, debugColor, true, debugShowTime )
		#endif
	}

	// 4: Selection: Pick a valid spawnpoint
	//		1. Visible.
	//		2. Facing.
	//		3. In Ranges.
	#if DEVELOPER
		DEV_CombatRangePrint( format( "Valid Spawn Points in Ranges: %s", string( spawnPts_InRanges.len() )))
		DEV_CombatRangePrint( format( "Valid Spawn Points in Facing: %s", string( spawnPts_InRangesInFacing.len() )))
	#endif

	sSpawnLoc theSpawnLoc
	// New Version
	if( spawnPts_InRangesInFacing.len() > 0 )
	{
		if( RandomInt( 100 ) <= 70 )
		{
			theSpawnLoc.spawnPt = SpawnPoint_GetRandomVisible( refPlayer, spawnPts_InRangesInFacing, 10 )
		}

		if( IsValid( theSpawnLoc.spawnPt ))
		{
			theSpawnLoc.isVisible = true
			theSpawnLoc.isInFacing = true
		}
		else
		{
			theSpawnLoc.isVisible = false
			theSpawnLoc.isInFacing = true
			theSpawnLoc.spawnPt = spawnPts_InRangesInFacing.getrandom()
		}
	}
	else
	{
		theSpawnLoc.isVisible = false
		theSpawnLoc.isInFacing = false

		if( spawnPts_InRangesNotFacing.len() > 0 )
		{
			theSpawnLoc.spawnPt = spawnPts_InRangesNotFacing.getrandom()
		}
	}

	#if DEVELOPER
		if( doDebugSpawnPoints && debugDraws  && IsValid( theSpawnLoc.spawnPt ))
		{
			DEV_debugDrawSpawnPoint( theSpawnLoc.spawnPt.GetOrigin(), 30, COLOR_LIGHT_GREEN, true, 15 )
		}
	#endif

	// Return the residual lists for use if necessary.
	theSpawnLoc.spawnPts_InRanges = spawnPts_InRanges

	return( theSpawnLoc )
}

entity function SpawnPoint_GetRandomVisible( entity refPlayer, array< entity > spawnPoints, int tries = 10 )
{


	int tryCount = 0
	array< entity > spawnPointsToTry = clone spawnPoints
	while(( spawnPointsToTry.len() > 0 ) && ( tryCount < tries ))
	{
		int index = spawnPointsToTry.len() == 1 ? 0 : RandomInt( spawnPointsToTry.len() - 1 )
		entity testPt = spawnPointsToTry[ index ]
		if( IsVisibleTo( refPlayer, testPt.GetOrigin() + SPAWNPT_VISIBILITYCHECK_OFFSET ) )
			return testPt

		spawnPointsToTry.fastremove( index )
		tryCount++
	}

	return null
}

// Max CombatRangeSpawnPointsTracked() is based on the Spawn Distance. The farther, the more.
int function Get_TrackedPointsMax( int realm )
{
	table< int, int > ptTrackThresholds

	// Smaller thresholds == more repeats.
	ptTrackThresholds[ eDummie_Selector_SpawnDists.CQB ] 	<- 4
	ptTrackThresholds[ eDummie_Selector_SpawnDists.MID ] 	<- 5
	ptTrackThresholds[ eDummie_Selector_SpawnDists.FAR ] 	<- 6
	ptTrackThresholds[ eDummie_Selector_SpawnDists.VFAR ] 	<- 4
	ptTrackThresholds[ eDummie_Selector_SpawnDists.RANDOM ] <- 7
	
	int spawnDists = FRSetting_DummieSpawnDists_Get( realm )
	int numPtsToTrack = ptTrackThresholds[ spawnDists ]
	return( numPtsToTrack )
}

void function TrackRecentSpawnPoint( int realm, entity spawnPoint )
{
	if( !IsSpawnPointRecentlyUsed( realm, spawnPoint ))
	{
		file.spawnPtsRecentByRealm[ realm ].append( spawnPoint )
	}

	// If the list of spawn points used >= max spawnpoints to track, then we forget the oldest one.
	int maxPtsToTrack = Get_TrackedPointsMax( realm )
	while( file.spawnPtsRecentByRealm[ realm ].len() >= maxPtsToTrack )
	{
		file.spawnPtsRecentByRealm[ realm ].remove( 0 )
	}
}

bool function IsSpawnPointRecentlyUsed( int team, entity spawnPoint )
{
	if( !IsValid( spawnPoint ) )
		return false

	if( !( team in file.spawnPtsRecentByRealm ) )
	{
		file.spawnPtsRecentByRealm[ team ] <- []
		return false
	}

	array< entity > recentSpawnPts = file.spawnPtsRecentByRealm[ team ]
	bool recentlyUsed = recentSpawnPts.contains( spawnPoint )

	#if DEVELOPER
	if( recentlyUsed )
	{
		DEV_CombatRangePrint( format( "spawnPoint %s was recently used.", string( spawnPoint ) ))
	}
	#endif

	return( recentlyUsed )
}
#endif // SERVER

// *******************
// ***** Spawning & Target Functions
// *******************

#if SERVER
void function SetSpawnsStarted( int realm, bool spawnOn )
{
	bool SpawnsStarted = DynDummie_Spawns_IsEnabled( realm )

	file.dynDummieSpawns_Started[ realm ] <- spawnOn

}

void function DelayedPickSpawnPointAndSpawnDummie_Thread( int realm, entity thePlayer, float delay = TARGET_SPAWN_DELAY, int spawnSoundLevel = eCRng_DummieSpawningTypes.FRESH_SPAWN, bool debugDraws = false )
{
	if ( !IsValid( file.dummiesSpawnedInRealm[ realm ] ) )
		return

	if ( DynDummie_Spawns_IsAtCapacity( realm ) )
		return

	wait delay

	int length = file.dummiesSpawnedInRealm[realm].len()
	if( IsValid( thePlayer ) && ( length < file.maxDynamicDummies ) && ( length > 0 ) )
	{
		PickSpawnPointAndSpawnDummie( realm, thePlayer, spawnSoundLevel, debugDraws )
	}
}

void function EndSignalOnCRRealmInfoEntity( int realm, string signal )
{
	if ( !(realm in file.dummiesSpawnedInRealm) )
		return

	if ( !IsValid( file.dummiesSpawnedInRealm[ realm ] ) )
		return

	EndSignal( file.dummiesSpawnedInRealm[ realm ], signal )
}

// Returns true if spawned successfully, false otherwise.
bool function PickSpawnPointAndSpawnDummie( int realm, entity thePlayer, int dummieSpawningType = eCRng_DummieSpawningTypes.FRESH_SPAWN, bool debugDraws = false )
{
	if ( !DynDummie_Spawns_IsEnabled( realm ) )
		return false

	if ( DynDummie_Spawns_IsAtCapacity( realm ) )
		return false

	sSpawnLoc pickedSpawnLoc = PickSpawnLoc( thePlayer, debugDraws )

	if ( !IsValid( pickedSpawnLoc.spawnPt ) )
		return false

	if( IsTotalDummiePopulationMaxed( realm ))
		return false
	
	entity ornull newDummie = SpawnDummieAtSpawnPoint( realm, pickedSpawnLoc.spawnPt, dummieSpawningType, debugDraws )
	return( newDummie != null )
}

// Checks to see if population is ok to add to.
bool function IsTotalDummiePopulationMaxed( int realm, bool forceOutput = false )
{
	table< string, array< entity > > dummieCollection = Dummies_GetAll( realm )
	int allDummies_Count 		= dummieCollection[ "allDummies" ].len()
	int RealmDummies_Count 		= dummieCollection[ "allDummiesInRealm" ].len()
	int RealmDynDummies_Count 	= dummieCollection[ "allDynDummiesInRealm" ].len()
	
	int playerCount = Get_CombatRange_Participants( realm ).len()
	
	bool maxPopulated_AllDummies		= allDummies_Count >= FIRING_RANGE_AI_BUDGET_MAX
	bool maxPopulated_RealmDummies 		= RealmDummies_Count >= ( file.maxDynamicDummies + 3 )
	bool maxPopulated_RealmDynDummies 	= RealmDynDummies_Count >= file.maxDynamicDummies

	if( maxPopulated_AllDummies || maxPopulated_RealmDummies || maxPopulated_RealmDynDummies || forceOutput )
	{
		printt( format( "%s(): -------------------  ", FUNC_NAME()))

		// --- All Realms
		if( forceOutput || maxPopulated_AllDummies )
		{
			printt( format( "%s(): # Dummies Across Active Realms == %s", FUNC_NAME(), string( allDummies_Count ) ) )
			table< int, int > dummieCountsByRealm
			foreach( dummie in dummieCollection[ "allDummies" ])
			{
				int dummieRealm = dummie.GetRealms()[ 0 ]
				if( !( dummieRealm in dummieCountsByRealm ) )
				{
					dummieCountsByRealm[ dummieRealm ] <- 0
				}
				dummieCountsByRealm[ dummieRealm ] <- dummieCountsByRealm[ dummieRealm ] + 1
			}
			foreach( dRealm, count in dummieCountsByRealm )
			{
				printt( format( "%s(): Realm %s Dummie Count == %s", FUNC_NAME(), string( dRealm ), string( count ) ) )
			}

			if( !forceOutput )
			{
				string errorMsg = format( "%s(): Trying to add to MAXXED OUT Dummie Count in All Realms: %s.", FUNC_NAME(), string( allDummies_Count ))
				Assert( !maxPopulated_AllDummies, errorMsg )
			}
		}

		if( forceOutput || maxPopulated_RealmDummies || maxPopulated_RealmDynDummies )
		{
			// --- Focused Realm
			printt( format( "%s(): -----  ", FUNC_NAME() ) )
			printt( format( "%s(): Test Realm: %s  ", FUNC_NAME(), string ( realm ) ) )
			printt( format( "%s(): Realm %s Player Count == %s ", FUNC_NAME(), string( realm), string ( playerCount ) ) )
			printt( format( "%s(): Realm %s Dynamic Dummies On Record == %s ", FUNC_NAME(), string( realm), string ( RealmDynDummies_Count ) ) )
			printt( format( "%s(): Realm %s All Dummies Count == %s ", FUNC_NAME(), string( realm), string ( RealmDummies_Count ) ) )
			printt( format( "%s(): -----  ", FUNC_NAME() ) )

			if ( !forceOutput )
			{
				if ( maxPopulated_RealmDummies  )
				{
					Warning( format( "%s(): MAXXED OUT Realm %s Dummie Count == %s ", FUNC_NAME(), string( realm ), string( RealmDummies_Count  ) ) )
				}

				if ( maxPopulated_RealmDynDummies )
				{
					Warning( format( "%s(): MAXXED OUT Realm %s Dynamic Dummie Count == %s", FUNC_NAME(), string( realm ), string( RealmDynDummies_Count  ) ) )
				}
			}
		}
		printt( format( "%s(): -------------------  ", FUNC_NAME()))
	}

	return ( maxPopulated_AllDummies || maxPopulated_RealmDummies || maxPopulated_RealmDynDummies )
}

entity ornull function SpawnDummieAtSpawnPoint( int realm, entity spawnPt, int dummieSpawningType, bool debugDraws  )
{
	if( !DynDummie_Spawns_IsEnabled( realm ) )
		return null

	if( DynDummie_Spawns_IsAtCapacity( realm ) )
		return null

	// ---- Do the spawning and set the behavior.
	vector destination = NavMesh_GetClosestPoint( spawnPt.GetOrigin() )
	vector targetFacing = spawnPt.GetAngles()

	targetFacing.x = 0 // Dummies face horizontal plane to start.

	// Radius Spawn placement if appropriate.
	const float SPAWNRADIUS_MAX = 96.0
	if( spawnPt.HasKey( "exact_spawn" ))
	{
		bool radiusSpawn = spawnPt.GetValueForKey( "exact_spawn" ) == "1" ? false : true
		if( radiusSpawn )
		{
			float spawnRadius = SPAWNRADIUS_MAX
			if( spawnPt.HasKey( "script_spawn_radius" ) )
			{
				spawnRadius = float( spawnPt.GetValueForKey( "script_spawn_radius" ))
			}
			array< vector > ptsInRadius = NavMesh_RandomPositions( destination, 0, 5, 3.0, spawnRadius )
			ptsInRadius.append( destination )
			vector randomPoint = ptsInRadius.getrandom()
			#if DEVELOPER
				if( file.dev_spawnPrintsOn )
				{
					float circleTime = 10.0
					float debugRadius = 16.0
					DebugDrawCircle( destination, <0, 0, 0>, spawnRadius, 255, 255, 255, true, circleTime )
					DebugDrawSphere( destination, debugRadius, 255, 0, 0, true, circleTime )
					DebugDrawSphere( randomPoint, debugRadius, 0, 0, 255, true, circleTime )
				}
			#endif
			destination = randomPoint
		}
	}

	// Spawn the new dummie.
	entity newDummie = DoDummieSpawn( realm, destination, targetFacing, dummieSpawningType, debugDraws )
	
	SetTargetName( newDummie, DYNAMIC_DUMMIE_TARGETNAME )

	// Highlight the Target
	if ( FRSetting_DummieHighlightsOn_Get( realm ) )
	{
		Highlight_SetEnemyHighlight( newDummie, COMBATRANGE_DUMMIE_HIGHLIGHT )
	}

	// Track spawned Target and give it the onDeath callback to report its death.
	bool spawnPtFacing = false
	if( spawnPt.HasKey( "does_spawnpt_face" ))
	{
		spawnPtFacing = spawnPt.GetValueForKey( "does_spawnpt_face" ) == "1" ? true : false
	}
	DummieData_Add( newDummie, realm, !spawnPtFacing )

	// Track SpawnPoint Used
	TrackRecentSpawnPoint( realm, spawnPt )
	DummieSpawnPt_Associate( newDummie, spawnPt )

	// Use the Firing Range Behavior Settings
	table< int, bool > behaviorSettings = FRDummie_BehaviorData_Get( realm )
	Dummie_Choose_And_Perform_Behavior_BySpawnPoint( newDummie, spawnPt, behaviorSettings )

	return newDummie
}

entity function DoDummieSpawn( int realm, vector destination, vector targetFacing, int spawnSoundType = eCRng_DummieSpawningTypes.CULL_RESPAWN, bool debugDraws = false )
{
	// Spawn the new dummie.

	int shieldLevel = FRSetting_ShieldLevel_Get( realm )

	bool doCombat = FullCombatDummies_IsEnabled( realm )

	entity newCRDummie

	if ( doCombat )
	{
		newCRDummie = SpawnNPCCombatDummie( destination, targetFacing, shieldLevel )
	}
	else
	{
		newCRDummie = SpawnNPCTrainingDummy( destination, targetFacing, shieldLevel )
	}

	#if DEVELOPER
		if( debugDraws && IsValid( newCRDummie ))
		{
			DebugDrawCube( newCRDummie.GetOrigin(), 64, 255, 0, 0, true, 10 )
		}
	#endif

	newCRDummie.RemoveFromAllRealms()
	newCRDummie.AddToRealm( realm )

	AddEntityCallback_OnDamaged( newCRDummie, On_CRDummie_Damaged )

	// Spawn FX for Combat Range Dummie:
	thread DummieFX_Spawn_Thread( newCRDummie )

	// Thread to wait until the Dummie is destroyed, then remove it from the Dummie Data arrays.
	thread function() : ( newCRDummie, realm )
	{
		WaitSignal( newCRDummie, "OnDestroy" )
		DummieData_Cleanup( newCRDummie, realm )
	}()

	return newCRDummie
}

void function UICallback_RespawnDummiesInPlace( entity player )
{
	if( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if( !IsValid( player ) )
		return

	if( !player.IsPlayer())
		return

	thread Dummies_RespawnInPlace_ByPlayer_Thread( player )
}

void function Dummies_RespawnInPlace_ByPlayer_Thread( entity player )
{
	player.Signal( "CombatRange_ClearAndSpawnDummies" )
	player.EndSignal( "CombatRange_ClearAndSpawnDummies" )

	int realm = GetCombatRangeRealm( player )

	CRDummies_RespawnInPlace( realm )
	#if DEVELOPER
		if( realm in file.dummiesSpawnedInRealm )
			DEV_CombatRangePrint( format( "%s(): Dynamic Dummies in Realm %s == %s ", FUNC_NAME(), string( realm ), string( file.dummiesSpawnedInRealm[ realm ].len() ) ) )
	#endif

}

// This function removes the n spawned Dummies in the Combat Range and respawns them in the last used spawnpoints.
void function CRDummies_RespawnInPlace( int realm, float delayBetweenSpawns = 0.2 )
{
	if( !DynDummie_Spawns_IsEnabled( realm ) )
		return

	if( Is_ClearAndFillSpawnDummies_InProgress( realm ) )
		return

	thread _Dummies_SpawnInPlace_Thread( realm, delayBetweenSpawns )
}

void function _Dummies_SpawnInPlace_Thread( int realm, float delayBetweenSpawns = 0.2 )
{
	file.clearingAndFillingInProgress[ realm ] <- true
	array< entity > spawnPts = []

	array< entity > oldDummies = clone file.dummiesSpawnedInRealm[ realm ]

	foreach( entity dummie in oldDummies )
	{
		entity ornull dummieSpawnPt = DummieSpawnPt_Get( dummie )
		DummieData_Remove( dummie )
		if( dummieSpawnPt != null )
		{
			expect entity( dummieSpawnPt )
			spawnPts.append( dummieSpawnPt )
			wait( delayBetweenSpawns )
			SpawnDummieAtSpawnPoint( realm, dummieSpawnPt, eCRng_DummieSpawningTypes.REFRESH_RESPAWN, false )
		}
	}
	file.clearingAndFillingInProgress[ realm ] <- false
}

void function CRDummies_SpawnNew( int realm, bool doWait = false )
{
	if( Is_ClearAndFillSpawnDummies_InProgress( realm ) )
		return

	thread _Dummies_SpawnNew_Thread( realm, doWait )
}

void function _Dummies_SpawnNew_Thread( int realm, bool doWait )
{
	file.clearingAndFillingInProgress[ realm ] <- true
	CRDummies_Clear( realm )
	WaitFrame()

	Dummies_SpawnFill( realm, doWait )
	
	file.clearingAndFillingInProgress[ realm ] <- false
}

table< string, array< entity > > function Dummies_GetAll( int realm )
{
	array< entity > allDummiesInRealm
	array< entity > allDynDummiesInRealm
	array< entity > allDummies = GetEntArrayByScriptName( FIRING_RANGE_DUMMIE_SCRIPT_NAME )
	allDummies.extend( GetEntArrayByScriptName( FIRING_RANGE_COMBAT_DUMMIE_SCRIPT_NAME ) )
	
	foreach( dummie in allDummies )
	{
		if( dummie.GetRealms()[ 0 ] == realm )
		{
			allDummiesInRealm.append( dummie )
		}
	}
	
	foreach( dummie in allDummiesInRealm )
	{
		if( dummie.GetTargetName() == DYNAMIC_DUMMIE_TARGETNAME )
		{
			allDynDummiesInRealm.append( dummie )
		}
	}
	
	table< string, array< entity > > results
	results[ "allDummies" ] <- allDummies
	results[ "allDummiesInRealm" ] <- allDummiesInRealm
	results[ "allDynDummiesInRealm" ] <- allDynDummiesInRealm
	
	return( results )
}

int function DummiesInRealm_Count( int realm )
{
	array< entity > allDummies = GetEntArrayByScriptName( FIRING_RANGE_DUMMIE_SCRIPT_NAME )
	int result = 0
	foreach( dummie in allDummies )
	{
		if( dummie.GetRealms()[0] == realm )
			result++
	}

	#if DEVELOPER
		DEV_DebugSpawnPrint( format( "Spawn Debug: -------------------"))
		DEV_DebugSpawnPrint( format( "Spawn Debug: All Dummies in All Realms == %s", string( allDummies.len())))
		DEV_DebugSpawnPrint( format( "Spawn Debug: Dynamic Dummies in This Realm == %s", string( result )))
	#endif

	return( result )
}

array< entity > function DummiesInRealm_Get( int realm )
{
	array< entity > allDummies = GetEntArrayByScriptName( FIRING_RANGE_DUMMIE_SCRIPT_NAME )
	array< entity > result = []
	foreach( dummie in allDummies )
	{
		if( dummie.GetRealms()[0] == realm )
			result.append( dummie )
	}

	return( result )
}

// -----

void function DummieSpawnPt_Associate( entity dummie, entity spawnPoint )
{
	file.dummieSpawnPts[ dummie ] <- spawnPoint

	DummieSpawnPt_Occupy( dummie, spawnPoint )
}

void function DummieSpawnPt_Disassociate( entity dummie )
{
	if ( !( dummie in file.dummieSpawnPts ) )
		return

	entity ornull spawnPoint = DummieSpawnPt_Get( dummie )
	if( spawnPoint != null )
	{
		expect entity( spawnPoint )
		DummieSpawnPt_Unoccupy( dummie, spawnPoint )
	}

	delete file.dummieSpawnPts[ dummie ]
}

entity ornull function DummieSpawnPt_Get( entity dummie )
{
	if( !IsValid( dummie ) )
		return null

	if ( !( dummie in file.dummieSpawnPts ) )
		return null

	return( file.dummieSpawnPts[ dummie ] )
}

// ---

void function DummieSpawnPt_Occupy( entity dummie, entity spawnPt )
{
	int realm = GetCombatRangeRealm( dummie )
	
	if( !( realm in file.spawnPtOccupationsByRealm ) )
	{
		file.spawnPtOccupationsByRealm[ realm ] <- { }
	}

	table< entity, entity > spawnPtOccupations = file.spawnPtOccupationsByRealm[ realm ]

	// Removed assert because the Respawn-in-Place requires the intentional re-occupation of the same spawnPoint.

	spawnPtOccupations[ spawnPt ] <- dummie
}

void function DummieSpawnPt_Unoccupy( entity dummie, entity spawnPt )
{
	int realm = GetCombatRangeRealm( dummie )

	if( !( realm in file.spawnPtOccupationsByRealm ) )
		return

	table< entity, entity > spawnPtOccupations = file.spawnPtOccupationsByRealm[ realm ]

	if( !( spawnPt in spawnPtOccupations ) )
		return

	delete spawnPtOccupations[ spawnPt ]
}

bool function DummieSpawnPt_IsOccupied( int realm, entity spawnPt )
{
	if( !( realm in file.spawnPtOccupationsByRealm ) )
	{
		file.spawnPtOccupationsByRealm[ realm ] <- { }
	}

	table< entity, entity > spawnPtOccupations = file.spawnPtOccupationsByRealm[ realm ]

	if( !( spawnPt in spawnPtOccupations ) )
	{
		return false
	}

	if( !IsValid( spawnPtOccupations[ spawnPt ] ))
	{
		delete spawnPtOccupations[ spawnPt ]
		return false
	}

	return true
}

// -----

void function DummieData_Add( entity dummie, int realm, bool facePlayers = true )
{
	if( !IsValid( dummie ) )
		return

	// If new realm, init for it.
	if( !( realm in file.dummiesSpawnedInRealm ) )
	{
		file.dummiesSpawnedInRealm[ realm ] <- []
	}

	if( !( realm in file.playerFacingDummiesByRealm ) )
	{
		file.playerFacingDummiesByRealm[ realm ] <- []
	}

	// Add dummie to tables.
	if( !( file.dummiesSpawnedInRealm[ realm ].contains( dummie )))
	{
		file.dummiesSpawnedInRealm[ realm ].append( dummie )
	}

	if(( facePlayers ) && ( !( file.playerFacingDummiesByRealm[ realm ].contains( dummie ))))
	{
		file.playerFacingDummiesByRealm[ realm ].append( dummie )
	}

	// Initialize hidden time.
	file.dummieHiddenTime[ dummie ] <- 0
}

int function DummieData_Count( int realm )
{
	if( !( realm in file.dummiesSpawnedInRealm ) )
	{
		file.dummiesSpawnedInRealm[ realm ] <- []
		return 0
	}

	return( file.dummiesSpawnedInRealm[ realm ].len() )
}

void function DummieData_Remove( entity dummie, bool doDestroy = true )
{
	int realm = INVALID_REALM

	if( !IsValid( dummie ) ) // S3: IsInvalidButMemberVarsStillValid doesn't exist
		return

	realm = GetCombatRangeRealm( dummie )
	DummieData_Cleanup( dummie, realm )

	if( doDestroy )
	{
		DummieDespawn( dummie )
	}
}

void function DummieData_Cleanup( entity dummie, int realm )
{
	if( dummie in file.dummieHiddenTime )
	{
		delete file.dummieHiddenTime[ dummie ]
	}

	DummieSpawnPt_Disassociate( dummie )

	if( file.dummiesSpawnedInRealm[ realm ].contains( dummie ) )
	{
		file.dummiesSpawnedInRealm[ realm ].fastremovebyvalue( dummie )
	}

	if( file.playerFacingDummiesByRealm[ realm ].contains( dummie ) )
	{
		file.playerFacingDummiesByRealm[ realm ].fastremovebyvalue( dummie )
	}
}

// ---

void function OnPlayerSpawned( entity player )
{
	// STUB. May need for JIP.
}

void function OnPlayerDisconnected( entity player )
{
	CRParticipant_Remove( player )
	DummieTargeting_UnregisterPlayer( player )
}

void function On_CRDummie_Damaged( entity ent, var damageInfo )
{
	entity attacker 			= DamageInfo_GetAttacker( damageInfo )
	float damage 				= DamageInfo_GetDamage( damageInfo )
	int damageSourceId			= DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( !IsValid( damage ) )
		return

	if ( !IsValid( attacker ) )
		return

	if( !IsAlive( ent ) )
		return

	file.dummieHiddenTime[ ent ] <- 0
}

// *******************
// ***** Target Behavior Functions
// *******************

// TODO: Maybe think about 1 thread per realm.

void function UpdateDummieFacing_Thread()
{
	const float DUMMIE_FACINGUPDATE_PERIOD = 0.2
	const float DUMMIE_HIDDENTIME_CULL_THRESHOLD_DEFAULT = 4.0

	while( true )
	{
		if( file.activeRealms.len() > 0 )
		{
			foreach( realm in file.activeRealms )
			{
				bool fcOn = FullCombatDummies_IsEnabled( realm )
				float dummieHiddenTimeCullThreshold = !fcOn ? DUMMIE_HIDDENTIME_CULL_THRESHOLD_DEFAULT : DUMMIE_HIDDENTIME_CULL_THRESHOLD_DEFAULT * 4

				if( DynDummie_Spawns_IsEnabled( realm ) && ( file.dummiesSpawnedInRealm[ realm ].len() > 0 ) && ( file.participants[ realm ].len() > 0 ))
				{
					foreach( dummie in file.dummiesSpawnedInRealm[ realm ])
					{
						if( IsValid( dummie ) )
						{
							entity seeingParticipant = GetEyeingParticipant( dummie )
							if( IsValid( seeingParticipant ))
							{
								file.dummieHiddenTime[ dummie ] <- 0
							}
							else
							{
								if( !( dummie in file.dummieHiddenTime ) )
									file.dummieHiddenTime[ dummie ] <- 0

								file.dummieHiddenTime[ dummie ] += DUMMIE_FACINGUPDATE_PERIOD
								if( file.dummieHiddenTime[ dummie ] >= dummieHiddenTimeCullThreshold )
								{
									DummieData_Remove( dummie ) // Spawn Manager will spawn a new dummie.
								}
							}

							// Face the closest player to dummie if not in paused facing list and full combat is not active.
							if( !dummie.ai.pauseScriptedFaceTarget && !fcOn )
							{
								if(( IsValid( dummie ) ) && ( file.playerFacingDummiesByRealm[ realm ].contains( dummie ) ))
								{
									CRParticipants_RemoveStale( realm )
									array< entity > participants = GetParticipants( realm )
									entity closestPlayer = GetClosest( participants, dummie.GetOrigin() )
									if( IsValid( closestPlayer ) )
									{
										vector facing    = closestPlayer.GetOrigin() - dummie.GetOrigin()
										vector facingAng = VectorToAngles( facing )
										facingAng.x = 0
										dummie.SetAngles( facingAng )
									}
								}
							}
						}
					}
				}
			}
		}
		wait( DUMMIE_FACINGUPDATE_PERIOD )
	}
}

void function Cull_Respawn( entity target )
{
	if( !IsValid( target ) )
		return

	int realm = GetCombatRangeRealm( target )

	DummieData_Remove( target )

	if( DynDummie_Spawns_IsEnabled( realm ) )
	{
		entity randomParticipant = GetRandomParticipant( realm )
		if(( randomParticipant != null ) && ( IsValid( randomParticipant ) ))
		{
			PickSpawnPointAndSpawnDummie( realm, randomParticipant, eCRng_DummieSpawningTypes.CULL_RESPAWN )
		}
	}
}

void function FaceClosestPlayer( entity ent )
{
	int realm = GetCombatRangeRealm( ent )

	if( realm == INVALID_REALM )
		return

	vector entOrigin = ent.GetOrigin()
	entity closestParticipant = GetClosest( file.participants[ realm ], entOrigin )

	if( IsValid( closestParticipant ) && ( !ent.ai.pauseScriptedFaceTarget ))
	{
		vector facing = closestParticipant.GetOrigin() - entOrigin
		vector facingAng = VectorToAngles( facing )
		facingAng.x = 0

		ent.SetAngles( facingAng )
	}
}

// GetEyeingParticipant: Return a player participant that satisfies the criteria of "seeing" this target Dummie:
//		- Target is in minimum range, or
//		- Target is within farthest enabled range and in player's facing, or
//		- Target is beyond enabled ranges but is visible to player.
//
// If no participants satisfy any of the above criteria, the entity returned is null.
entity function GetEyeingParticipant( entity target )
{
	const int TARGET_HIDDEN_FACING_THRESHOLD = 80
	const vector TARGET_VISIBILITY_TEST_HEIGHT_OFFSET = < 0, 0, 40 >
	const float TARGET_VISIBILITY_TEST_FWD_OFFSET = 32.0
	const float TARGET_CHECK_MIN_DIST_SQ = 620001.9 // 20 meters into inches squared

	int realm = GetCombatRangeRealm( target )
	foreach( participant in file.participants[ realm ] )
	{
		if( CanSpawnDummiesForPlayer( participant ) )
		{
			//	Rules:
			//	- If within TARGET_CHECK_MIN_DIST_SQ of any player, is not hidden
			// 	- If within the farthest range from player's settings:
			//		- If IsFacing, is not hidden.
			// 	- Else if visible to anyone and beyond everyone's range, is not hidden.

			float distSq = DistanceSqr( participant.GetOrigin(), target.GetOrigin() )

			if( distSq <= TARGET_CHECK_MIN_DIST_SQ )
				return participant

			if( !IsDistBeyondEnabledSpawnDists( participant, distSq ) )
			{
				if( IsFacing( participant, target, COMBATRANGE_SPAWNPOINT_FACING_THRESHOLD, false )  )
					return participant
			}
			else
			{
				vector direction = Normalize( participant.GetOrigin() - target.GetOrigin())
				vector testloc = target.GetOrigin() + TARGET_VISIBILITY_TEST_HEIGHT_OFFSET + direction * TARGET_VISIBILITY_TEST_FWD_OFFSET
				if( IsVisibleTo( participant, testloc ) )
					return participant
			}
		}
	}

	return null
}

bool function IsDistBeyondEnabledSpawnDists( entity player, float distSq )
{
	table< int, bool > spawnDistSettings = GetSpawnDistanceSettings( player )

	float maxDistSq = file.rangeMaxsSq[ eCRng_SpawnDistances.CQB ]

	if( spawnDistSettings[ eCRng_SpawnDistances.VFAR ] )
	{
		maxDistSq = file.rangeMaxsSq[ eCRng_SpawnDistances.VFAR ]
	}
	else if( spawnDistSettings[ eCRng_SpawnDistances.FAR ] )
	{
		maxDistSq = file.rangeMaxsSq[ eCRng_SpawnDistances.FAR ]
	}
	else if( spawnDistSettings[ eCRng_SpawnDistances.MID ] )
	{
		maxDistSq = file.rangeMaxsSq[ eCRng_SpawnDistances.MID ]
	}

	return( distSq > maxDistSq )
}

// Returns distance settings as a table.
table< int, bool > function GetSpawnDistanceSettings( entity player )
{
	int realm = GetCombatRangeRealm( player )
	int selectionNDX = FRSetting_DummieSpawnDists_Get( realm )

	table< int, bool > results = dummie_SpawnDists_BySelector[ selectionNDX ]
	return results
}

#endif // SERVER

// *******************
// ***** Participants Functions
// *******************
#if SERVER
void function CRParticipants_AddAll( entity player )
{
	if( !IsCombatRangeMap())
		return

	if( !CanBeParticipant( player ) )
		return

	array< entity > realmPlayers = GetAllPlayersInRealm_ByPlayer( player )
	foreach( rp in realmPlayers )
	{
		CRParticipant_Add( rp )
	}
}

void function CRParticipant_Add( entity player )
{
	if( !IsCombatRangeMap())
		return

	if( !CanBeParticipant( player ) )
		return

	int realm = GetCombatRangeRealm( player )
	if( !IsParticipant( player ) )
	{
		file.participants[ realm ].append( player )
	}

	#if DEVELOPER
		printt( format( "%s(): %s Added as a Participant", FUNC_NAME(), player.GetPlayerName()) )
	#endif
}

void function CRParticipants_RemoveAll( entity player )
{
	if( !IsCombatRangeMap())
		return

	if( !CanBeParticipant( player ) )
		return

	array< entity > realmPlayers = GetAllPlayersInRealm_ByPlayer( player )
	foreach( rp in realmPlayers )
	{
		CRParticipant_Remove( rp )
	}
}

void function CRParticipant_Remove( entity player )
{
	if( !IsCombatRangeMap() )
		return

	int realm = GetCombatRangeRealm( player )
	if( !( realm in file.participants ) )
		return

	if( file.participants[ realm ].contains( player ) )
	{
		file.participants[ realm ].fastremovebyvalue( player )
	}
}

bool function CanBeParticipant( entity player )
{
	//if( !PlaylistVar_CRng_Spawning())
	//	return false

	if( !IsValid( player ) )
		return false

	if( !player.IsPlayer() )
		return false

	return true
}

bool function IsParticipant( entity player )
{
	if( !IsValid( player ) )
		return false

	int realm = GetCombatRangeRealm( player )

	CheckRealmParticipants( realm )
	return( file.participants[ realm ].contains( player ) )

	// New version.
	//return( DynDummie_Spawns_IsEnabled( GetCombatRangeRealm( player ) ) )
}

void function CheckRealmParticipants( int realm )
{
	if( !( realm in file.participants ) )
	{
		file.participants[ realm ] <- []
		return
	}
	else
	{
		CRParticipants_RemoveStale( realm )
	}
}

void function CRParticipants_RemoveStale( int realm )
{
	if( file.participants[ realm ].len() == 0 )
		return

	foreach( participant in file.participants[ realm ])
	{
		if( !IsValid( participant ) )
		{
			file.participants[ realm ].removebyvalue( realm )
		}
	}
}

array< entity > function GetParticipants( int realm )
{
	CheckRealmParticipants( realm )
	return( file.participants[ realm ] )
}

array< entity > function Get_CombatRange_Participants( int realm )
{
	return ( GetParticipants( realm ) )
}

entity function GetRandomParticipant( int realm )
{
	entity participant = GetParticipants( realm ).getrandom()
	while( !IsValid( participant ) && file.participants[ realm ].len() > 0 )
	{
		participant = file.participants[ realm ].getrandom()
		if( !IsValid( participant ) && ( file.participants[ realm ].contains( participant ) ) )
		{
			file.participants[ realm ].fastremovebyvalue( participant )
		}
	}

	if( file.participants[ realm ].len() == 0 )
		return null

	return participant
}

#endif // SERVER

int function GetCombatRangeRealm( entity ent )
{
	if( IsValid( ent ) ) // S3: IsInvalidButMemberVarsStillValid doesn't exist
	{
		return( ent.GetRealms()[0]  )
	}

	return INVALID_REALM
}

// *******************
// ***** Exercise Functions
// *******************
#if SERVER
void function DynDummie_Spawns_Thread( int realm, float delay = 0.0 )
{
	// ENSURE There is only one of these running.
	entity realmInfoEnt = RealmInfoEntity_Get( realm )
	realmInfoEnt.Signal( "CombatRange_Spawning_Started" )
	realmInfoEnt.EndSignal( "CombatRange_Spawning_Started" )

	#if DEVELOPER
		printt( format( "%s(): *** Dynamic Dummies Spawning!", FUNC_NAME() ) )
	#endif

	// 	Tell the UI that Dynamic Spawning has started.
	//	Once Dynamic Spawning has been started at least once:
	//		- Dynamic Spawning can be turned on/off forever via Customize Range.
	array< entity > participants = GetParticipants( realm )
	foreach( player in participants )
	{
		// Enable Dynamic Spawning Setting Menu Option.
		Remote_CallFunction_NonReplay( player, "SCB_DynDummie_Spawns_Changed" )
	}

	wait( delay )

	// WIP: Uncomment below to re-enable self-respawning of CR Dummies.
	//Dummies_SpawnFill( realm, false )

	DynDummie_SpawnManager( realm )
}

void function DynDummie_SpawnManager( int realm )
{
	const float DUMMIECHECK_PERIOD = 0.5
	const float DUMMIESPAWN_DELAY = 0.25

	const int NOSPAWN_LOOP_COUNT_THRESHOLD = 90
	int noSpawnLoops = 0

	array< entity > participants
	while( DynDummie_Spawns_IsEnabled( realm ) )
	{
		if( !Is_ClearAndFillSpawnDummies_InProgress( realm ))
		{
			participants = GetParticipants( realm )
			if( participants.len() < 1 )
				break

			// [ R5DEV-483954 ] Start clearing out old recent spawn points for every few seconds there is no spawning happening.
			bool spawnSuccess = false
			foreach( participant in participants )
			{
				if( !DynDummie_Spawns_IsAtCapacity( realm ) && CanSpawnDummiesForPlayer( participant ))
				{
					spawnSuccess = spawnSuccess || PickSpawnPointAndSpawnDummie( realm, participant )
					wait( DUMMIESPAWN_DELAY )
				}
			}

			if( !spawnSuccess )
			{
				noSpawnLoops++
				if( noSpawnLoops >= NOSPAWN_LOOP_COUNT_THRESHOLD )
				{
					if( file.spawnPtsRecentByRealm[ realm ].len() > 0  )
					{
						file.spawnPtsRecentByRealm[ realm ].remove( 0 )
					}
					noSpawnLoops = 0
				}
			}

		}
		wait( DUMMIECHECK_PERIOD )
	}

	if( GetParticipants( realm ).len() < 1 )
	{
		DynDummie_Spawns_Stop( realm )
	}
}

void function Dummies_SpawnFill( int realm, bool doWaits = false )
{
	array< entity > participants = GetParticipants( realm )
	if( !( realm in file.dummiesSpawnedInRealm ) )
	{
		file.dummiesSpawnedInRealm[ realm ] <- []
	}

	float spawnDelay = 0.2

	const int NOSPAWN_LOOP_COUNT_THRESHOLD = 90
	int noSpawnLoops = 0
	while( !DynDummie_Spawns_IsAtCapacity( realm ) )
	{
		bool spawnSuccess = false
		foreach( participant in participants )
		{
			if( doWaits )
				wait( spawnDelay ) // Spread out first spawns by spawnDelay so they appear one-by-one.

			if( CanSpawnDummiesForPlayer( participant ))
			{
				spawnSuccess = spawnSuccess || PickSpawnPointAndSpawnDummie( realm, participant )
			}
		}

		// [ R5DEV-483954 ] Remove oldest recent spawn point to make room if there have been a number of loops without successful spawns.
		if( !spawnSuccess )
		{
			noSpawnLoops++
			if( noSpawnLoops >= NOSPAWN_LOOP_COUNT_THRESHOLD )
			{
				if( file.spawnPtsRecentByRealm[ realm ].len() > 0  )
				{
					file.spawnPtsRecentByRealm[ realm ].remove( 0 )
				}
				noSpawnLoops = 0
			}
		}

		WaitFrame()
	}
}

bool function CanSpawnDummiesForPlayer( entity player )
{
	if( !IsValid( player ) )
		return false

	if( !IsAlive( player ) )
		return false

	if( Bleedout_IsBleedingOut( player ) )
		return false

	return( IsParticipant( player ) )
}

void function DynDummie_Spawns_Stop( int realm )
{
	if( DynDummie_Spawns_IsEnabled( realm ) )
	{
		file.dynDummieSpawns_Started[ realm ] <- false
		ActiveRealmsRemove( realm )
		CRDummies_Clear( realm )

		if( PlaylistVar_CRng_Announcer() )
		{
			AnnounceToPlayersInRealm( realm, eCRng_AnnounceTypes.SPAWN_DISABLED )
		}
	}
}

void function CRDummies_Clear( int realm )
{
	if( !( realm in file.dummiesSpawnedInRealm ) )
		return

	array< entity > oldDummies = clone file.dummiesSpawnedInRealm[ realm ]

	foreach( dynDummie in oldDummies)
	{
		DummieData_Remove( dynDummie )
	}
}

array< entity > function CRDummies_Get( int realm )
{
	// If new realm, init for it.
	if( !( realm in file.dummiesSpawnedInRealm ) )
	{
		file.dummiesSpawnedInRealm[ realm ] <- []
	}

	return( file.dummiesSpawnedInRealm[ realm ] )
}

// -----

void function UICallback_ClearAndSpawnNewDummies( entity player )
{
	if( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if( !IsValid( player ) )
		return

	if( !player.IsPlayer())
		return

	int realm = GetCombatRangeRealm( player )
	if( !DynDummie_Spawns_IsEnabled( realm ) )
		return

	thread CRDummies_ClearThenFillSpawn_Thread( player, false )
}

// Clear out current Dummies then fill-spawn with latest settings and ranges.
void function CRDummies_ClearThenFillSpawn_Thread( entity player, bool doWait = false )
{
	player.Signal( "CombatRange_ClearAndSpawnDummies" )
	player.EndSignal( "CombatRange_ClearAndSpawnDummies" )

	int realm = GetCombatRangeRealm( player )
	CRDummies_SpawnNew( realm, doWait )

	#if DEVELOPER
		DEV_CombatRangePrint( format( "%s(): Dynamic Dummies in Realm %s == %s ", FUNC_NAME(), string( realm ), string( file.dummiesSpawnedInRealm[ realm ].len() ) ) )
	#endif
}

bool function Is_ClearAndFillSpawnDummies_InProgress( int realm )
{
	if( !( realm in file.clearingAndFillingInProgress ) )
	{
		file.clearingAndFillingInProgress[ realm ] <- false
	}

	return( file.clearingAndFillingInProgress[ realm ] )
}

void function AnnounceToPlayersInRealm( int realm, int customAnnouncement, float delay = 0 )
{
	const float ANNOUNCEDEBOUNCE = 9.0 //Min time between announcements

	if( !( realm in file.lastAnnounceTime ) )
	{
		file.lastAnnounceTime[ realm ] <- 0.0
	}

	if( Time() - file.lastAnnounceTime[ realm ] < ANNOUNCEDEBOUNCE )
		return

	array< entity > playersInRealm = GetAllPlayersInRealm( realm )
	foreach( participant in playersInRealm )
	{
		thread AnnouncerCommsTemp( participant, customAnnouncement, delay )
	}

	file.lastAnnounceTime[ realm ] <- Time()
}

void function StopAnnounceToPlayersInRealm( int realm, int customAnnouncement, float delay = 0.0 )
{
	array< entity > playersInRealm = GetAllPlayersInRealm( realm )
	foreach( participant in playersInRealm )
	{
		thread AnnouncerCommsStop( participant, customAnnouncement )
	}
}

array< string > function GetAnnouncementDialog( int customAnnouncement )
{
	array <string> dialogueChoices = []

	switch( customAnnouncement )
	{
		case eCRng_AnnounceTypes.SPAWN_STARTING:
			// TODO: Put real dialog in here if we decide we want announcer VO in the FR.
			//dialogueChoices.append( "diag_ap_aiNotify_combatRangeTargetSpawnStart_01_01" )
			//dialogueChoices.append( "diag_ap_aiNotify_combatRangeTargetSpawnStart_02_01" )
			break
		case eCRng_AnnounceTypes.SPAWN_ENDINGSOON:
			// TODO: Put real dialog in here if we decide we want announcer VO in the FR.
			//dialogueChoices.append( "diag_ap_aiNotify_combatRangeTargetSpawnEnd_01_01" )
			//dialogueChoices.append( "diag_ap_aiNotify_combatRangeTargetSpawnEnd_02_01" )
			break
		case eCRng_AnnounceTypes.SPAWN_DISABLED:
			// TODO: Put real dialog in here if we decide we want announcer VO in the FR.
			//dialogueChoices.append( "diag_ap_aiNotify_combatRangeTargetSpawnDisabled_01_01" )
			//dialogueChoices.append( "diag_ap_aiNotify_combatRangeTargetSpawnDisabled_02_01" )
			break
	}

	return dialogueChoices
}

void function AnnouncerCommsTemp( entity player, int customAnnouncement, float announcerCommsDelay = 0 )
{
	array <string> dialogueChoices = GetAnnouncementDialog( customAnnouncement )

	if( dialogueChoices.len() == 0 )
		return

	string lineToPlay = dialogueChoices.getrandom()

	if ( announcerCommsDelay > 0 )
		wait announcerCommsDelay

	if ( !IsValid( player ) )
		return

	// TODO: Play sound properly with emitters once emitters and trigger_soundscapes are added to the map.
	EmitSoundOnEntityOnlyToPlayer( player, player, lineToPlay )
}

void function AnnouncerCommsStop( entity player, int customAnnouncement )
{
	array <string> dialogueChoices = GetAnnouncementDialog( customAnnouncement )

	if( dialogueChoices.len() == 0 )
		return

	foreach( dialog in dialogueChoices )
	{
		StopSoundOnEntity( player, dialog )
	}
}
#endif // SERVER

#if CLIENT

void function SCB_DynDummie_Spawns_Changed()
{
	// If we want to display a banner, we can do it here.
}

#endif // CLIENT

// *******************
// ***** Debug Functions
// *******************

#if SERVER
#if DEVELOPER
void function DEV_CombatRange_Show_SpawnPoints( float showTime = 10 )
{
	float startTime = Time()
	DEV_CombatRangePrint( "DEV_ShowSpawnPoints(): START" )

	array< entity > players = GetPlayerArray()
	array< entity > spawnPoints = Get_TargetSpawnPoints()

	foreach( player in players )
	{
		int index = GetCombatRangeRealm( player )
		DEV_CombatRangePrint( format( "Player: %s... Realm == %s", string( player ), string( index )))
	}

	entity refPlayer = players[ 0 ]

	foreach( spawnPoint in spawnPoints )
	{
		if( spawnPoint.IsOccupied() ) // S3: IsOccupied takes no params
		{
			DebugDrawSphere( spawnPoint.GetOrigin(), 50, 255, 0, 0, true, showTime )
		}
		else
		{
			if( IsFacing( players[0], spawnPoint, COMBATRANGE_SPAWNPOINT_FACING_THRESHOLD, false ) )
			{
				// Coded visibility check doesn't work.
				//if( spawnPoint.IsVisibleToEnemies( refPlayer.GetTeam() ) )

				// scripted visibility check
				if( IsVisibleTo( refPlayer, spawnPoint.GetOrigin() + SPAWNPT_VISIBILITYCHECK_OFFSET ) )
				{
					DebugDrawCube( spawnPoint.GetOrigin(), 25, 0, 255, 0, true, showTime )
				}
				else
				{
					DebugDrawCube( spawnPoint.GetOrigin(), 25, 255, 165, 0, true, showTime )
				}
			}
			else
			{
				DebugDrawCube( spawnPoint.GetOrigin(), 5, 64, 64, 64, true, showTime )
			}
		}
	}

	float timeTaken = Time() - startTime
	DEV_CombatRangePrint( format( "DEV_ShowSpawnPoints(): DONE, time taken == %s", string( timeTaken ) ))
}

void function DEV_debugDrawSpawnPoint( vector origin, float size, vector color, bool throughGeo = true, float showTime = 5 )
{
	DebugDrawCube( origin, size, int( color.x ), int( color.y ), int( color.z ), throughGeo, showTime )
}

void function DEV_CombatRange_CountParticipants()
{
	entity player = GetPlayerArray()[0]
	int realm = GetCombatRangeRealm( player )
	DEV_CombatRangePrint( format( "Number of Participants: %s", string( file.participants[ realm ].len()) ))
}

void function DEV_CombatRange_CountSpawnPoints()
{
	DEV_CombatRangePrint( format( "Number of Spawn Points: %s", string( file.spawnPoints.len()) ))
}

void function DEV_CombatRange_TestSpawn( entity player )
{
	int realm = GetCombatRangeRealm( player )
	if( realm != INVALID_REALM )
	{
		PickSpawnPointAndSpawnDummie( realm, player, eCRng_DummieSpawningTypes.FRESH_SPAWN, true )
	}
}

void function DEV_DynDummie_Spawns_Start()
{
	entity player = GetPlayerArray()[0]
	Try_DynDummie_Spawns_Start( player )
}

void function DEV_DynDummie_Spawns_Stop()
{
	DynDummie_Spawns_Stop( GetCombatRangeRealm( GetPlayerArray()[0] ) )
}

void function DEV_CombatRange_RecentSpawnPoints()
{
	int index = GetCombatRangeRealm( GetPlayerArray()[0] )
	DEV_CombatRangePrint( format( "Recent SpawnPoints: Count == %s", string( file.spawnPtsRecentByRealm[ index ].len() ) ))
	foreach( spawnPoint in file.spawnPtsRecentByRealm[ index ])
	{
		if( IsValid( spawnPoint ) )
		{
			thread DEV_CombatRangePrint( format( "Recent SpawnPoint: %s", string( spawnPoint ) ))
			thread DEV_debugDrawSpawnPoint( spawnPoint.GetOrigin(), 25, COLOR_DARK_PINK, true, 20 )
		}
	}
}

void function DEV_CombatRange_IndicateTargets()
{
	int index = GetCombatRangeRealm( GetPlayerArray()[0] )
	foreach( enemy in file.dummiesSpawnedInRealm[ index ])
	{
		if( IsValid( enemy ) )
		{
			DEV_debugDrawSpawnPoint( enemy.GetOrigin(), 50, <255, 0, 0>, true, 20 )
		}
		else
		{
			DEV_CombatRangePrint( "Invalid Target found in file.dummiesSpawnedInRealm" )
		}
	}
}

void function DEV_CombatRange_CountDummies()
{
	entity player = GetPlayerArray()[0]
	int realm = GetCombatRangeRealm( player )
	DEV_CombatRangePrint( format( "Realm ==  %s", string( realm )))

	if( IsParticipant( player ) )
	{
		DEV_CombatRangePrint( format( " Dummies Alive == %s", string( file.dummiesSpawnedInRealm[ realm ].len()) ) )
	}
	else
	{
		DEV_CombatRangePrint( " Dummies Alive should be 0.")
		if( realm in file.dummiesSpawnedInRealm )
		{
			DEV_CombatRangePrint( format( " Dummies Alive == %s", string( file.dummiesSpawnedInRealm[ realm ].len()) ) )
		}
	}
}

void function DEV_CombatRange_ForceDistanceSpawns( entity player, bool cqbOn, bool midOn, bool farOn, bool vFarOn  )
{
	thread ForceRangeTargets_Thread( player, cqbOn, midOn, farOn, vFarOn )
}

void function ForceRangeTargets_Thread( entity player, bool cqbOn, bool midOn, bool farOn, bool vFarOn  )
{
	int realm = GetCombatRangeRealm( player )
	CRDummies_Clear( realm )

	file.spawnPtsRecentByRealm[ realm ] <- []

	wait 0.5

	Dummies_SpawnFill( realm )
}

void function DEV_CR_Respawn_Dummies()
{
	int realm = GetCombatRangeRealm( GetPlayerArray()[0] )
	CRDummies_RespawnInPlace( realm )
}

void function DEV_CountDummies_AllRealms()
{
	array< int > realmsCounted = []
	array< entity > allPlayers = GetPlayerArray()
	foreach( player in allPlayers )
	{
		int realm = GetPlayerSquadRealm( player )
		if( realmsCounted.contains( realm ) )
			continue

		DEV_CountDummies( player )
		realmsCounted.append( realm )
	}
}

void function DEV_CountDummies( entity playerParm )
{
	entity player = playerParm
	if( !IsValidPlayer( player ) )
	{
		player = GetPlayerArray()[0]
	}

	//int realm = GetCombatRangeRealm( GetPlayerArray() )
	int realm = GetPlayerSquadRealm( player )
	foreach( dummie in file.dummiesSpawnedInRealm[ realm ] )
	{
		DebugDrawSphere( dummie.GetOrigin(), 48, 0, 255, 0, true, 20 )
	}

	printt( "Spawn Debug: Dynamic Dummies in list == ", file.dummiesSpawnedInRealm[ realm ].len() )

	array< entity > allDummiesByName = GetEntArrayByScriptName( FIRING_RANGE_DUMMIE_SCRIPT_NAME )

	printt( format( "Spawn Debug: All Dummies in Realm %s == %s ", string( realm ), string( allDummiesByName.len() )))

	foreach( dummie in allDummiesByName )
	{
		if( dummie.GetRealms()[ 0 ] == realm )
		{
			// Cubes for the dummies in this realm.
			DebugDrawCube( dummie.GetOrigin(), 32, 176, 224, 230, true, 20 )

			// Dynamic Dummies in the realm that are not recorded.
			if(( dummie.GetTargetName() == DYNAMIC_DUMMIE_TARGETNAME ) && ( !file.dummiesSpawnedInRealm[ realm ].contains( dummie ) ))
			{
				DebugDrawSphere( dummie.GetOrigin(), 64, 255, 0, 0, true, 20 )
			}
		}
	}

	IsTotalDummiePopulationMaxed( realm, true )
}

#endif // DEVELOPER
#endif // SERVER

#if DEVELOPER // DEV for Client || Server
void function DEV_CombatRangePrint( string printMe, bool forcePrint = false )
{
	if( file.dev_PrintsOn || forcePrint )
	{
		printt( format( "COMBATRANGE: %s", printMe ) )
	}
}

void function DEV_DebugSpawnPrint( string printMe )
{
	if( file.dev_spawnPrintsOn )
	{
		printt( format( "SPAWNING DEBUG: %s", printMe ) )
	}
}

void function DEV_DebugSpawnPrintOn( bool isOn )
{
	file.dev_spawnPrintsOn = isOn
}

#endif // DEVELOPER
                                                  


