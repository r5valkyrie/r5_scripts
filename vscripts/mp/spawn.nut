untyped

global function Spawn_Init
global function Spawn_SetFriendlyRatingCap
global function Spawn_SetSpawnpointRatingFunc

global function IsSpawnpointValid
global function IsSpawnpointValidDrop
global function CreateNoSpawnArea
global function DeleteNoSpawnArea
global function IsSpawnpointVisibleToTurret
global function IsSpawnpointNearGrenade
global function IsOriginInNoSpawnArea

global function SwapSpawnpointTeams

global function FilterSpawnpointsByTeam
global function RateSpawnPointList
global function FindSpawnPoint
global function FindStartSpawnPoint

global function RateSpawnpoints_Frontline
global function RateSpawnpoints_Generic
global function RateSpawnpoints_Directional
global function RateSpawnpoints_SpawnZones
global function RateSpawnpoints_SecondClosest

global function EnableSpawnpoint
global function DisableSpawnpoint
global function RemoveAllOtherSpawnpoints
global function IsSpawnpointEnabled

global function SetFrontlineDistanceFalloffStart
global function SetFrontlineDistanceFalloffEnd

global function CodeCallback_SpawnpointDebugText
#if DEV
global function randomspawnzone
global function DebugSpawnZone
global function SpawnZone_GetById
global function DebugSpawnZones
#endif
global function SpawnZoneTeamLosesZone

//global function SpawnRandomTitan

global function CreateNewSpawnPoint
global function TestNextScriptSpawnPoint
global function TestPreviousScriptSpawnPoint

global function SetSpawnZonesVisibleOnMinimap

global struct SvSpawnGlobals
{
	array<entity> allNormalAndStartSpawnpoints
	array<entity> allNormalSpawnpoints
	array<entity> infoIntermissions

	float frontlineDistanceFalloffStart = 3072.0
	float frontlineDistanceFalloffEnd = 4096.0
}
global SvSpawnGlobals svSpawnGlobals

global const float FRIENDLY_SPAWNPOINT_RATING_CAP = 1.25

const int MAX_ZONE_SPAWNS = 20
const float MIN_ZONE_TIME = 60.0
const float MAX_ZONE_TIME = 120.0
const float MAX_ZONE_FAILED_SPAWNS = 3.0

global const bool SPAWNING_DEBUG = false
const bool DEBUG_SPAWN_ZONES = false

const bool SHOW_ZONES_ON_MINIMAP = true

struct SpawnZone
{
	int id = -1
	int teamId = TEAM_UNASSIGNED
	bool isActive = false
	entity trigger = null
	array<entity> spawnPoints
	array<int> linkedZones
	vector origin
	float radius

	entity radiusTrigger

	float failureScore = 0
	int spawnCount = 0
	float endTime

	float[2] worstSpawnpointRating
	float[2] bestSpawnpointRating
	int[2] invalidSpawnpointCount
	int[2] validSpawnpointCount

	float[2] repeatUseCount

	float aiCampDist

	bool fullDebug = false
}

struct
{
	table noSpawnArea
	array<SpawnZone> spawnZones
	bool initializedSpawnZones
	int[16] activeTeamZoneIds = [-1, ...]
	bool spawnZonePushBack = false
	#if SHOW_ZONES_ON_MINIMAP
		entity[2] minimapSpawnZones
	#endif
	bool choosingNewZones = false
	bool gameOver = false
	float friendlyRatingCap = FRIENDLY_SPAWNPOINT_RATING_CAP

	bool spawnZonesVisibleOnMinimap = false

	void functionref( int, array<entity>, int, entity ) spawnpointRatingFunc
} file

global const bool VERBOSE_SPAWN_DEBUG_PRINTS = false
const float TURRET_SPAWN_DISTANCE_BUFFER = 512.0

global const float FRONTLINE_DISTANCE_MULTIPLIER = -2.0

void function Spawn_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	AddSpawnCallback( "info_player_teamspawn", InitSpawnpoints )
	AddSpawnCallback( "info_player_start", InitInfoPlayerStart )
	AddSpawnCallback( "info_spawnpoint_droppod", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_dropship_start", InitStartSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_droppod_start", InitStartSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitStartSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_human_start", InitStartSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_dropship", InitSpawnpoints )
	AddSpawnCallback( "info_replacement_titan_spawn", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_marvin", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_flag", InitSpawnpoints )

	SpawnPoints_SetRatingMultiplier_PetTitan( 2.5 )
	RefreshRatingMultipliers()

	AddTriggerEditorClassFunc( "trigger_mp_spawn_zone", SpawnZoneTriggerInit )
	AddCallback_OnPlayerRespawned( Spawn_OnPlayerRespawned )

	#if SHOW_ZONES_ON_MINIMAP
		AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
	#endif
}

void function Spawn_SetSpawnpointRatingFunc( void functionref( int, array<entity>, int, entity ) func )
{
	file.spawnpointRatingFunc = func
}

#if SHOW_ZONES_ON_MINIMAP
void function OnWinnerDetermined()
{
	file.gameOver = true
	foreach ( entity ent in file.minimapSpawnZones )
	{
		if ( IsValid( ent ) )
			ent.Destroy()
	}

	SpawnZone oldActiveZone = SpawnZone_GetActiveForTeam( TEAM_IMC )
	if ( oldActiveZone.id != -1 )
		ClearActiveSpawnZone( oldActiveZone )
	oldActiveZone = SpawnZone_GetActiveForTeam( TEAM_MILITIA )
	if ( oldActiveZone.id != -1 )
		ClearActiveSpawnZone( oldActiveZone )

	file.activeTeamZoneIds[TEAM_IMC] = -1
	file.activeTeamZoneIds[TEAM_MILITIA] = -1
}
#endif

void function Spawn_SetFriendlyRatingCap( float cap )
{
	file.friendlyRatingCap = cap
}

void function RefreshRatingMultipliers()
{
	SpawnPoints_SetRatingMultipliers_Friendly( TD_TITAN, 1.25, 0.25, 0.0 )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_PILOT, 0.25, GetSpawnRating_ScaleFriendly(), 0.0 )

	SpawnPoints_SetRatingMultipliers_Enemy( TD_TITAN, -8.0, -4.0, -1.0 )
	SpawnPoints_SetRatingMultipliers_Enemy( TD_PILOT, -8.0, GetSpawnRating_ScaleEnemy(), -1.0 )
}

void function UseSpawnZoneRatingMultipliers()
{
	SpawnPoints_SetRatingMultipliers_Friendly( TD_TITAN, 3.0, 2.0, 0.0 )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_PILOT, 3.0, 2.0, 0.0 )

	SpawnPoints_SetRatingMultipliers_Enemy( TD_TITAN, -2.0, -1.5, -0.25 )
	SpawnPoints_SetRatingMultipliers_Enemy( TD_PILOT, -2.0, -1.5, -0.25 )
}

void function EntitiesDidLoad()
{
	InitSpawnsVisibleToTurret()
	InitSpawnZones()

	printt( "Pilot spawnpoints rating func: " + string( file.spawnpointRatingFunc ) )
}

void function InitSpawnpoints( entity spawnpoint )
{
	if ( GameModeRemove( spawnpoint ) )
		return

	spawnpoint.sp.enabled = true
	spawnpoint.sp.lastUsedTime = -9999.0

	Assert( IsValid( spawnpoint ) )
	svSpawnGlobals.allNormalSpawnpoints.append( spawnpoint )
	svSpawnGlobals.allNormalAndStartSpawnpoints.append( spawnpoint )
}

void function InitStartSpawnpoints( entity spawnpoint )
{
	if ( GameModeRemove( spawnpoint ) )
		return

	spawnpoint.sp.enabled = true
	spawnpoint.sp.lastUsedTime = -9999.0

	Assert( IsValid( spawnpoint ) )
	svSpawnGlobals.allNormalAndStartSpawnpoints.append( spawnpoint )
}

void function InitInfoPlayerStart( entity spawnpoint )
{
	if ( GameModeRemove( spawnpoint ) )
		return

	Assert( IsValid( spawnpoint ) )
	svSpawnGlobals.allNormalAndStartSpawnpoints.append( spawnpoint )
}

void function EnableSpawnpoint( entity spawnpoint )
{
	spawnpoint.sp.enabled = true
}

void function DisableSpawnpoint( entity spawnpoint )
{
	spawnpoint.sp.enabled = false
}

void function RemoveAllOtherSpawnpoints( array<entity> allowedSpawnpoints )
{
	RemoveOtherSpawnpointsFromSpawnZones( allowedSpawnpoints )

	for( int i = svSpawnGlobals.allNormalSpawnpoints.len() - 1; i >= 0; --i )
	{
		if( !allowedSpawnpoints.contains( svSpawnGlobals.allNormalSpawnpoints[i] ) )
			svSpawnGlobals.allNormalSpawnpoints.remove( i )
	}

	for( int i = svSpawnGlobals.allNormalAndStartSpawnpoints.len() - 1; i >= 0; --i )
	{
		if( !allowedSpawnpoints.contains( svSpawnGlobals.allNormalAndStartSpawnpoints[i] ) )
		{
			if ( IsValid( svSpawnGlobals.allNormalAndStartSpawnpoints[i] ) )
				svSpawnGlobals.allNormalAndStartSpawnpoints[i].Destroy()
			svSpawnGlobals.allNormalAndStartSpawnpoints.remove( i )
		}
	}
}

void function RemoveOtherSpawnpointsFromSpawnZones( array<entity> allowedSpawnpoints )
{
	foreach( spawnZone in file.spawnZones )
	{
		for( int i = spawnZone.spawnPoints.len() - 1; i >= 0; --i )
		{
			if( !allowedSpawnpoints.contains( spawnZone.spawnPoints[i] ) )
				spawnZone.spawnPoints.remove( i )
		}
	}
}

bool function IsSpawnpointEnabled( entity spawnpoint )
{
	return spawnpoint.sp.enabled
}

void function InitSpawnsVisibleToTurret()
{
	array<entity> turretArray = GetNPCArrayByClass( "npc_turret_mega" )

	foreach ( turret in turretArray )
	{
		float turretSpawnDistance = 3000.0 * 3000.0 // default, queried below

		entity turretWeapon = turret.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( IsValid( turretWeapon ) )
		{
			string turretWeaponClassName = turretWeapon.GetWeaponClassName()

			float turretMaxRange = expect float( GetWeaponInfoFileKeyField_Global( turretWeaponClassName, "npc_max_range" ) )
			turretSpawnDistance = ( turretMaxRange * turretMaxRange ) + TURRET_SPAWN_DISTANCE_BUFFER
		}

		vector eyePos = turret.EyePosition()

		foreach ( spawnpoint in svSpawnGlobals.allNormalSpawnpoints )
		{
			vector origin = spawnpoint.GetOrigin()
			if ( spawnpoint.GetClassName() == "info_spawnpoint_titan" )
				origin += <0,0,185>
			else
				origin += <0,0,60>

			if ( DistanceSqr( origin, eyePos ) > turretSpawnDistance )
				continue

			TraceResults trace = TraceLine( eyePos, origin, turret, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

			if ( trace.fraction < 1.0 )
				continue // trace was blocked

			spawnpoint.sp.visibleToTurret.append( turret )
		}
	}
}

#if DEV
void function DebugSpawnsVisibleToTurret()
{
	for ( ;; )
	{
		foreach ( spawnpoint in svSpawnGlobals.allNormalSpawnpoints )
		{
			foreach ( turret in spawnpoint.sp.visibleToTurret )
			{
				DebugDrawLine( spawnpoint.GetOrigin(), turret.GetOrigin(), COLOR_WHITE, true, 0.2 )
			}
		}
		WaitFrame()
	}
}
#endif

// Control wants to manage spawn points on their own, so this function doesn't use SpawnPoints_GetPilot() and SpawnPoints_SortPilot()
void function RateSpawnPointList( entity player, array<entity> spawnpoints )
{
	Assert( IsValid( player ), player + " is invalid!" )

	int team = player.GetTeam()

	if ( VERBOSE_SPAWN_DEBUG_PRINTS )
		printl( "spawnpoints.len() = " + spawnpoints.len() )

	SpawnPoints_InitRatings( player, file.friendlyRatingCap )

	file.spawnpointRatingFunc( TD_PILOT, spawnpoints, team, player )
	spawnpoints.sort( int function ( entity a, entity b ) : () {
		float aRating = expect float( a.GetRating() )
		float bRating = expect float( b.GetRating() )
		if ( aRating > bRating )
			return 1
		else if ( aRating < bRating )
			return -1
		return 0
	} )

	SpawnPoints_DiscardRatings()
}

entity function NoSpawnpointsFallback()
{
	array<entity> spawnpoints = SpawnPoints_GetTitan()
	if ( spawnpoints.len() == 0 )
	{
		array<entity> start = GetEntArrayByClass_Expensive( "info_player_start" )
		Assert( start.len() > 0, "No info_player_start entities exist, Failed to find any valid Spawnpoints" )

		if ( start.len() > 0 )
			return start.getrandom()

		return null
	}

	int idx = RandomInt( spawnpoints.len() )
	return spawnpoints[idx]
}


entity function FindSpawnPoint( entity player )
{
	Assert( IsValid( player ), player + " is invalid!" )

	int team = player.GetTeam()
 	array<entity> spawnpoints = SpawnPoints_GetPilot()

 	if ( file.spawnZones.len() > 0 && file.activeTeamZoneIds[team] >= 0 && !file.choosingNewZones )
 	{
 		SpawnZone activeSpawnZone = SpawnZone_GetActiveForTeam( team )
		if ( Time() > activeSpawnZone.endTime )
		{
			printt( "zone " + activeSpawnZone.id + " timed out" )
			SpawnZoneTeamLosesZone( team )
		}
	}

	if ( VERBOSE_SPAWN_DEBUG_PRINTS )
		printl( "spawnpoints.len() = " + spawnpoints.len() )

	if ( spawnpoints.len() == 0 )
		return NoSpawnpointsFallback()

	SpawnPoints_InitRatings( player, file.friendlyRatingCap )
	file.spawnpointRatingFunc( TD_PILOT, spawnpoints, team, player )
	SpawnPoints_SortPilot()

	spawnpoints =  SpawnPoints_GetPilot()

	entity spawnpoint = GetFirstValidSpawnpoint( spawnpoints, team, GetSpawnRating_TestLOS() )
	if ( !spawnpoint && GetSpawnRating_TestLOS() )
	{
		spawnpoint = GetFirstValidSpawnpoint( spawnpoints, team, false )
	}

	if ( !spawnpoint )
	{
		#if DEV
			PrintNoValidSpawnpoint( spawnpoints, player, team )
		#endif
		spawnpoint = spawnpoints[ 0 ]
	}

	Assert( spawnpoint )

	spawnpoint.sp.lastUsedTime = Time()

	player.SetLastSpawnPoint( spawnpoint )

	return spawnpoint
}



entity function FindStartSpawnPoint( entity player )
{
	int team = player.GetTeam()
	array< entity > spawnpoints

	// Alliance start spawns not available (SpawnPoints_GetPilotAllianceStart)
	// AllianceProximity_IsUsingAlliances() returns false, so this path is never taken

	// fallback to teams
	if ( spawnpoints.len() == 0 )
	{
		if ( Is2TeamPvPGame() || IsMultiTeamPvPGame() )
		{
			spawnpoints = SpawnPoints_GetPilotStart( team )
		}
		else
		{
			spawnpoints = SpawnPoints_GetPilot()
		}
	}

	if ( spawnpoints.len() == 0 )
	{
		return FindSpawnPoint( player )
	}

	SpawnPoints_InitRatings( player, file.friendlyRatingCap )
	file.spawnpointRatingFunc( TD_PILOT, spawnpoints, team, player )
	SpawnPoints_SortPilotStart()

	entity spawnpoint = GetFirstValidSpawnpoint( spawnpoints, team, false )
	if ( !spawnpoint )
	{
		if ( VERBOSE_SPAWN_DEBUG_PRINTS )
			printl( "No valid start spawns found, calling FindSpawnPoint()" )
		return FindSpawnPoint( player )
	}

	spawnpoint.sp.lastUsedTime = Time()
	player.SetLastSpawnPoint( spawnpoint )

	return spawnpoint
}

void function FilterSpawnpointsByTeam( array<entity> spawnpoints, int team )
{
	array<entity> oldspawnpoints = clone spawnpoints
	spawnpoints.clear()

	foreach ( spawnpoint in oldspawnpoints )
	{
		if ( spawnpoint.GetTeam() != team )
			continue

		spawnpoints.append( spawnpoint )
	}
}

entity function GetFirstValidSpawnpoint( array<entity> spawnpoints, int team, bool testLOS = true )
{
	foreach ( spawn in spawnpoints )
	{
		if ( !IsSpawnpointValid( spawn, team, testLOS ) )
			continue

		return spawn
	}
	return null
}

void function RateSpawnpoints_Directional( int checkClass, array<entity> spawnPoints, int teamId, entity player )
{
	array<entity> friendlyPlayers = []
	array<entity> enemyPlayers = []

	// Under normal circumstances just get the friendly and enemy team of players
	if ( !AllianceProximity_IsUsingAlliances() )
	{
		int otherTeamId = GetOtherTeam( teamId )
		friendlyPlayers = GetPlayerArrayOfTeam_Alive( teamId )
		enemyPlayers = GetPlayerArrayOfTeam_Alive( otherTeamId )
	}
	else // If using Alliances, get Alliance players instead of team players
	{
		int friendlyAlliance = AllianceProximity_GetAllianceFromTeam( teamId )
		friendlyPlayers = AllianceProximity_GetAllPlayersInAlliance( friendlyAlliance, true )
		enemyPlayers = AllianceProximity_GetAllPlayersInOtherAlliances( friendlyAlliance, true )
	}


	if ( enemyPlayers.len() == 0 || friendlyPlayers.len() == 0 )
	{
		RateSpawnpoints_Generic( checkClass, spawnPoints, teamId, player )
		return
	}

	vector friendlyOrigin = GetMedianOriginOfEntities( friendlyPlayers )
	vector enemyOrigin = GetMedianOriginOfEntities( enemyPlayers )

	float distToEnemies = Distance( enemyOrigin, friendlyOrigin )

	foreach ( spawnPoint in spawnPoints )
	{
		float dist = Distance( spawnPoint.GetOrigin(), friendlyOrigin )
		float distMultiplier = GraphCapped( dist, 0, distToEnemies, 1.0, 0.0 )

		float additionalRating = 0.0
		vector vecToEnemies = Normalize( enemyOrigin - spawnPoint.GetOrigin() )
		additionalRating = vecToEnemies.Dot( spawnPoint.GetForwardVector() ) * distMultiplier

		float rating = spawnPoint.CalculateRating( checkClass, teamId, additionalRating, 0.0 )
#if SPAWNING_DEBUG
		spawnPoint.e.spawnPointData.lastRatingData = spawnPoint.GetRatingData()
		spawnPoint.e.spawnPointData.lastRatingData.rating <- rating
#endif
	}
}

void function RateSpawnpoints_Generic( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	foreach ( spawnpoint in spawnpoints )
	{
		float rating = spawnpoint.CalculateRating( checkclass, team, 0.0, 0.0 )
	}
}

void function RateSpawnpoints_Frontline( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	Frontline frontline = GetFrontline( team )

	foreach ( spawnpoint in spawnpoints )
	{
		vector spawnpointOrg = spawnpoint.GetOrigin()
		vector spawnpointToFrontline = Normalize( frontline.origin - spawnpointOrg )
		float dot = DotProduct( spawnpointToFrontline, frontline.combatDir )

		// Magic math: This rates the best spawn area 1.0, at 90 degrees the rating is close to 0.0, and at 180 degrees it's -4.0
		float frontlineRating = GraphCapped( dot, -1.0, 1.0, 1.0, 0.0 )
		frontlineRating *= frontlineRating
		frontlineRating = GraphCapped( frontlineRating, 0.0, 1.0, 1.0, -4.0 )

		float distanceFromFrontline = Distance( spawnpointOrg, frontline.origin )

		if ( distanceFromFrontline > svSpawnGlobals.frontlineDistanceFalloffStart )
			frontlineRating += Graph( distanceFromFrontline, svSpawnGlobals.frontlineDistanceFalloffStart, svSpawnGlobals.frontlineDistanceFalloffEnd, 0.0, FRONTLINE_DISTANCE_MULTIPLIER )

		float facing = DotProduct( spawnpoint.GetForwardVector(), spawnpointToFrontline )

		float rating = spawnpoint.CalculateRating( checkclass, team, frontlineRating + facing, 0.0 )
	}
}

void function RateSpawnpoints_SecondClosest( int checkClass, array<entity> spawnPoints, int team, entity player )
{
	vector playerPos = player.GetOrigin()

	float closest = 0
	float secondClosest = 0
	entity closestSpawnPoint = null
	entity secondClosestSpawnPoint = null

	foreach ( spawnPoint in spawnPoints )
	{
		float rating = -Length2DSqr( playerPos - spawnPoint.GetOrigin() )
		spawnPoint.SetRating( rating )
		if ( closest == 0 || closest < rating )
		{
			secondClosest = closest
			closest = rating
			secondClosestSpawnPoint = closestSpawnPoint
			closestSpawnPoint = spawnPoint
		}
		else if ( secondClosest == 0 || secondClosest < rating )
		{
			secondClosest = rating
			secondClosestSpawnPoint = spawnPoint
		}
	}

	if ( closestSpawnPoint != null && secondClosestSpawnPoint != null )
	{
		closestSpawnPoint.SetRating( secondClosest )
		secondClosestSpawnPoint.SetRating( closest )
	}
}

bool function IsSpawnpointValid( entity spawnpoint, int team, bool testLOS = true )
{
	vector spawnPointOrigin = spawnpoint.GetOrigin()

	// organize these checks by performance cost, cheaper first

	// check if drop pod is en route to this spawnpoint
	if ( spawnpoint.e.spawnPointInUse )
	{
		return false
	}

	if ( !spawnpoint.sp.enabled )
	{
		return false
	}

	// check if this spawnpoint was already selected by someone this frame
	if ( spawnpoint.sp.lastUsedTime == Time() )
	{
		return false
	}

	// if we're using alliances the array should already be filtered by alliance, CURRENTLY ONLY START SPAWN POINTS
	if ( ( Is2TeamPvPGame() || IsMultiTeamPvPGame() ) && !AllianceProximity_IsUsingAlliances() && !IsSpawnPointForTeam( spawnpoint, team ) )
	{
		return false
	}

	// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
	if ( spawnpoint.IsOccupied() )
	{
		return false
	}

	if ( IsNearAirdropBadPlace( spawnPointOrigin ) )
	{
		return false
	}

	if ( IsSpawnpointVisibleToTurret( spawnpoint, team ) )
	{
		return false
	}

	if ( IsSpawnpointNearGrenade( spawnpoint, team ) )
	{
		return false
	}

	if ( testLOS && spawnpoint.IsVisibleToEnemies( team ) )
	{
		return false
	}

	if ( testLOS && IsVisibleToEnemyNPCTitans( spawnpoint.GetOrigin() + <0,0,64>, team ) )
	{
		return false
	}

	if ( IsOriginInNoSpawnArea( spawnpoint.GetOrigin(), team ) )
	{
		return false
	}

	return true
}

bool function IsSpawnPointForTeam( entity spawnpoint, int team )
{
	int spawnpointTeam = spawnpoint.GetTeam()
	if ( spawnpointTeam == 0 && spawnpoint.HasKey( "teamnumber" ) )
		spawnpointTeam = int( spawnpoint.kv.teamnumber )

	return spawnpointTeam == 0 || spawnpointTeam == team
}

bool function IsVisibleToEnemyNPCTitans( vector origin, int team )
{
	array<entity> titans = GetTitanArrayOfEnemies( team )

	foreach ( titan in titans )
	{
		if ( IsFriendlyTeam( titan.GetTeam(), team ) )
			continue

		if ( titan.IsPlayer() == true )
			continue

		TraceResults trace = TraceLine( titan.EyePosition(), origin, titan, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
		if ( trace.fraction == 1.0 )
		{
			if ( VERBOSE_SPAWN_DEBUG_PRINTS )
				printt( "Origin " + origin + " visible to NPC Titan" )
			return true
		}
	}

	return false
}

bool function IsSpawnpointNearGrenade( entity spawnpoint, int team )
{
	array<entity> enemyGrenades = GetProjectileArrayEx( "grenade_frag", TEAM_ANY, team, spawnpoint.GetOrigin(), 1000 )
	foreach ( grenade in enemyGrenades )
	{
 		if ( !IsValid( grenade ) )
			continue

 		float radiusSqr = grenade.GetDamageRadius() * 2.0
		radiusSqr *= radiusSqr
		float distSqr = DistanceSqr( spawnpoint.GetOrigin(), grenade.GetOrigin() )
		if ( distSqr < radiusSqr )
			return true
	}

	return false
}

bool function IsSpawnpointVisibleToTurret( entity spawnpoint, int team )
{
	foreach ( entity turret in spawnpoint.sp.visibleToTurret )
	{
		if ( !IsValid( turret ) )
			continue

		int turretState = turret.GetTurretState()
		if ( turretState != TURRET_ACTIVE && turretState != TURRET_SEARCHING && turretState != TURRET_DEPLOYING )
			continue

		int turretTeam = turret.GetTeam()
		if ( turretTeam == team || turretTeam == TEAM_UNASSIGNED )
			continue

		return true
	}

	return false
}

bool function IsOriginInNoSpawnArea( vector origin, int team )
{
	PerfStart( PerfIndexServer.NoSpawnAreaCheck )

	foreach ( area in file.noSpawnArea )
	{
		if ( (area.blockSpecificTeam > TEAM_INVALID) && (area.blockSpecificTeam != team) )
			continue
		if ( (area.blockEnemiesOfTeam > TEAM_INVALID) && !IsEnemyTeam( area.blockEnemiesOfTeam, team ) )
			continue

		if ( DistanceSqr( origin, area.origin ) > area.lengthSqr )
			continue

		if ( !area.rectangle )
		{
			PerfEnd( PerfIndexServer.NoSpawnAreaCheck )
			return true	// inside radius of no spawn area, return true
		}
		// check to see if it's inside the rectangle
		vector lowerVector = origin - expect vector( area.lowerRight )
		vector upperVector = origin - expect vector( area.upperLeft )
		if ( DotProduct( area.forward, lowerVector ) < 0 )
			continue
		if ( DotProduct( area.left, lowerVector ) < 0 )
			continue
		if ( DotProduct( area.right, upperVector ) < 0 )
			continue

		PerfEnd( PerfIndexServer.NoSpawnAreaCheck )
		return true	// inside the rectangle, return true
	}

	PerfEnd( PerfIndexServer.NoSpawnAreaCheck )
	return false
}

/*
	if you only pass length it will treat it as a circle and use the length as the radius.
	if you pass the length, width and angles it will become a rectangle the extends from the origin out.
	direction is based on the forward vector of the angles passed.
*/
string function CreateNoSpawnArea( int blockSpecificTeam, int blockEnemiesOfTeam, vector origin, float timeout, float length, float width = -1, angles = null )
{
	table area
	area.blockSpecificTeam <- blockSpecificTeam
	area.blockEnemiesOfTeam <- blockEnemiesOfTeam
	area.origin <- origin
	area.lengthSqr <- length * length
	area.rectangle <- width == -1 ? false : true

	if ( area.rectangle )
	{
		Assert( angles )
		area.forward <- AnglesToForward( angles )
		area.right <- AnglesToRight( angles )
		area.left <- area.right * -1
		area.lowerRight <- origin + area.right * ( width / 2 )
		area.upperLeft <- origin + area.forward * length - area.right * ( width / 2 )
	}

	string id = UniqueString( string( Time() ) )
	file.noSpawnArea[id] <- area

	if ( timeout >= 0 )
		thread NoSpawnAreaTimeout( id, timeout )

	return id
}

void function NoSpawnAreaTimeout( string id, float timeout )
{
	wait timeout
	DeleteNoSpawnArea( id )
}

void function DeleteNoSpawnArea( string id )
{
	if ( id in file.noSpawnArea )
		delete file.noSpawnArea[ id ]
}

bool function IsSpawnpointValidDrop( entity spawnpoint, int team )
{
	// check if drop pod is en route to this spawnpoint
	if ( spawnpoint.e.spawnPointInUse )
	{
		return false
	}

	if ( !spawnpoint.sp.enabled )
	{
		return false
	}

	int spawnpointTeam = spawnpoint.GetTeam()
	if ( spawnpointTeam != TEAM_UNASSIGNED && spawnpointTeam != team )
	{
		return false
	}

	// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
	if ( spawnpoint.IsOccupied() )
	{
		return false
	}

	return true
}

#if DEV
void function PrintNoValidSpawnpoint( array<entity> spawnpoints, entity player, int team )
{
	Assert( spawnpoints.len() > 0 )

	string spawnpointType = spawnpoints[ 0 ].GetClassName()

	int inUseCount = 0
	int visibleCount = 0
	int occupiedCount = 0

	foreach ( spawnpoint in spawnpoints )
	{
		if ( spawnpoint.e.spawnPointInUse )
			inUseCount++

		if ( spawnpoint.IsVisibleToEnemies( team ) )
			visibleCount++

		if ( spawnpoint.IsOccupied() )
			occupiedCount++
	}

	printl( "   SPAWNING BUG " + player.GetPlayerName() + " using: " + spawnpointType )
	printl( " " + spawnpoints.len() + " total" )
	printl( " " + inUseCount + " are in use by drop pods" )
	printl( " " + visibleCount + " are visible to enemies" )
	printl( " " + occupiedCount + " are occupied" )
}
#endif

void function SwapSpawnpointTeams()
{
	foreach ( spawnPoint in svSpawnGlobals.allNormalAndStartSpawnpoints )
	{
		if ( !IsValid( spawnPoint ) )
			continue

		int spawnPointTeam = spawnPoint.GetTeam()

		if ( spawnPointTeam == TEAM_IMC )
			SetTeam( spawnPoint, TEAM_MILITIA )
		else if ( spawnPointTeam == TEAM_MILITIA )
			SetTeam( spawnPoint, TEAM_IMC )
	}
}

void function SetFrontlineDistanceFalloffStart( float minDistance )
{
	svSpawnGlobals.frontlineDistanceFalloffStart = minDistance
}


void function SetFrontlineDistanceFalloffEnd( float maxDistance )
{
	svSpawnGlobals.frontlineDistanceFalloffEnd = maxDistance
}

void function SpawnZoneTriggerInit( entity trigger )
{
	if ( trigger.GetLinkParentArray().len() == 0 && trigger.GetLinkEntArray().len() == 0 )
		return

	Assert( !file.initializedSpawnZones )

	SpawnZone spawnZone
	spawnZone.trigger = trigger
	spawnZone.id = file.spawnZones.len()
	trigger.s.zoneIndex <- spawnZone.id

	file.spawnZones.append( spawnZone )
}

#if DEV
void function randomspawnzone( int index )
{
	entity player = gp()[0]

	int teamId = player.GetTeam()
	int otherTeamId = GetOtherTeam( teamId )

	SpawnZone teamZone = file.spawnZones[index]
	SpawnZone_SetActiveForTeam( teamZone, teamId )

	SpawnZone enemyZone = file.spawnZones[teamZone.linkedZones[0]]
	SpawnZone_SetActiveForTeam( enemyZone, otherTeamId )
}


void function DebugSpawnZone( int index )
{
	foreach ( spawnZone in file.spawnZones )
	{
		spawnZone.fullDebug = (spawnZone.id == index)
	}
}

SpawnZone function SpawnZone_GetById( int zoneId )
{
	return file.spawnZones[zoneId]
}
#endif

const float ZONE_REPEAT_USE_COST = 1.5
const float ZONE_REPEAT_USE_COUNT_DECAY = 0.3
const float ZONE_TWO_THIRDS_INVALID_COST = 1.5
const float ZONE_ALMOST_ALL_INVALID_COST = 4.0
const float ZONE_ALL_INVALID_COST = 10.0
const float ZONE_CAMP_DIST_COST_PER_UNIT = 0.001

float function RateZone( SpawnZone zone, int teamIndex, int team )
{
	float rating = 0.5 * (zone.worstSpawnpointRating[teamIndex] + zone.bestSpawnpointRating[teamIndex])

	float invalidFrac = float( zone.invalidSpawnpointCount[teamIndex] ) / float( zone.invalidSpawnpointCount[teamIndex] + zone.validSpawnpointCount[teamIndex] )
	if ( invalidFrac > 0.33 )
	{
		if ( invalidFrac >= 1.0 )
		{
			rating -= ZONE_ALL_INVALID_COST
		}
		else if ( invalidFrac > 0.66 )
		{
			invalidFrac = (invalidFrac - 0.66) / (1.0 - 0.66)
			rating -= (ZONE_TWO_THIRDS_INVALID_COST + invalidFrac * (ZONE_ALMOST_ALL_INVALID_COST - ZONE_TWO_THIRDS_INVALID_COST))
		}
		else
		{
			invalidFrac = (invalidFrac - 0.33) / (0.66 - 0.33)
			rating -= invalidFrac * ZONE_TWO_THIRDS_INVALID_COST
		}
	}

	rating = rating - ZONE_REPEAT_USE_COST * zone.repeatUseCount[team - TEAM_IMC]

	if ( zone.validSpawnpointCount[teamIndex] < 2 )
		rating -= 100000.0

	return rating
}


void function SelectBestZonePair_Threaded( int losingTeam, SpawnZone&[2] bestZones )
{
	// This function is threaded to amortize the cost over multiple server frames.

	printt( "Beginning selection of new spawn zone pair" )

	Assert( !file.choosingNewZones )
	file.choosingNewZones = true

	int otherTeam = GetOtherTeam( losingTeam )

	UseSpawnZoneRatingMultipliers()
	SpawnPoints_InitRatings( null, 999999999.0 )

	foreach ( zone in file.spawnZones )
	{
		zone.worstSpawnpointRating[0] = 999999999.0
		zone.worstSpawnpointRating[1] = 999999999.0
		zone.bestSpawnpointRating[0] = -999999999.0
		zone.bestSpawnpointRating[1] = -999999999.0
		zone.invalidSpawnpointCount[0] = 0
		zone.invalidSpawnpointCount[1] = 0
		zone.validSpawnpointCount[0] = 0
		zone.validSpawnpointCount[1] = 0
		zone.aiCampDist = 0
	}

	int[2] teams
	teams[0] = losingTeam
	teams[1] = otherTeam

	foreach ( i, spawnpoint in svSpawnGlobals.allNormalSpawnpoints )
	{
		if ( spawnpoint.sp.zones.len() == 0 )
			continue

		bool validForEitherTeam = true

		foreach ( teamIndex, team in teams )
		{
			// Check things that makes spawnpoints invalid for long periods of time
			if ( ( Is2TeamPvPGame() || IsMultiTeamPvPGame() ) && !IsSpawnPointForTeam( spawnpoint, team ) )
				continue

			bool valid = validForEitherTeam

			if ( IsSpawnpointVisibleToTurret( spawnpoint, team ) || IsOriginInNoSpawnArea( spawnpoint.GetOrigin(), team ) || spawnpoint.IsVisibleToEnemies( team ) )
			{
				valid = false
			}

			float rating = spawnpoint.CalculateRatingDontCache( TD_PILOT, team, 0.0, 0.0 )

			foreach ( zoneId in spawnpoint.sp.zones )
			{
				SpawnZone zone = file.spawnZones[zoneId]
				zone.bestSpawnpointRating[teamIndex] = max( zone.bestSpawnpointRating[teamIndex], rating )
				zone.worstSpawnpointRating[teamIndex] = min( zone.worstSpawnpointRating[teamIndex], rating )
				if ( valid )
					zone.validSpawnpointCount[teamIndex]++
				else
					zone.invalidSpawnpointCount[teamIndex]++
			}
		}

		if ( i % 8 == 7 )
		{
			SpawnPoints_DiscardRatings()
			RefreshRatingMultipliers()

			WaitFrame()

			UseSpawnZoneRatingMultipliers()
			SpawnPoints_InitRatings( null, 999999999.0 )
		}
	}

	SpawnPoints_DiscardRatings()
	RefreshRatingMultipliers()

	WaitFrame()

	if ( DEBUG_SPAWN_ZONES )
	{
		int militiaIndex
		if ( losingTeam == TEAM_MILITIA )
			militiaIndex = 0
		else
			militiaIndex = 1
		int imcIndex = 1 - militiaIndex
		foreach ( zone in file.spawnZones )
		{
			float militiaRating = RateZone( zone, militiaIndex, TEAM_MILITIA )
			float imcRating = RateZone( zone, imcIndex, TEAM_IMC )

			DebugDrawText( zone.origin, militiaRating + "; " + imcRating, false, 4.0 )
		}
	}

	int curLosingZone = SpawnZone_GetActiveForTeam( losingTeam ).id

	if ( losingTeam == TEAM_MILITIA )
		printt( "Selecting zones for militia and IMC" )
	else
		printt( "Selecting zones for IMC and militia" )

	bestZones[0] = file.spawnZones[0]
	bestZones[1] = file.spawnZones[file.spawnZones[0].linkedZones[0]]
	float bestZoneRating = -99999999999999.0
	foreach ( zone in file.spawnZones )
	{
		float rating = RateZone( zone, 0, teams[0] )
		rating += RandomFloat( 0.001 ) // tie breaker

		if ( zone.id == curLosingZone && zone.failureScore >= MAX_ZONE_FAILED_SPAWNS * 0.666 )
			rating -= 10000000.0

		foreach ( enemyZoneId in zone.linkedZones )
		{
			SpawnZone enemyZone = file.spawnZones[enemyZoneId]

			float enemyRating = RateZone( enemyZone, 1, teams[1] )
			enemyRating += RandomFloat( 0.001 ) // tie breaker

			float pairRating = rating + enemyRating

			pairRating -= fabs( zone.aiCampDist - enemyZone.aiCampDist ) * ZONE_CAMP_DIST_COST_PER_UNIT

			printt( " zones " + zone.id + " and " + enemyZone.id + ": " + rating + ", " + enemyRating + " : " + pairRating )

			if ( pairRating > bestZoneRating )
			{
				bestZones[0] = zone
				bestZones[1] = enemyZone
				bestZoneRating = pairRating
			}
		}
	}

	if ( !file.gameOver )
	{
		printt( "Selected spawn zones " + bestZones[0].id + " at " + bestZones[0].origin + " and " + bestZones[1].id + " at " + bestZones[1].origin )
		printt( "Ratings: " + RateZone( bestZones[0], 0, teams[0] ) + ", " + RateZone( bestZones[1], 1, teams[1] ) )

		SpawnZone_SetActiveForTeam( bestZones[0], losingTeam )
		SpawnZone_SetActiveForTeam( bestZones[1], otherTeam )

		// Decay repeat use count on other zones
		foreach ( zone in file.spawnZones )
		{
			if ( zone == bestZones[0] || zone == bestZones[1] )
				continue
			zone.repeatUseCount[0] = max( zone.repeatUseCount[0] - ZONE_REPEAT_USE_COUNT_DECAY, 0.0 )
			zone.repeatUseCount[1] = max( zone.repeatUseCount[1] - ZONE_REPEAT_USE_COUNT_DECAY, 0.0 )
		}
	}

	file.choosingNewZones = false
}


void function SpawnZoneTeamLosesZone( int losingTeam )
{
	SpawnZone&[2] bestZones
	Assert( !file.choosingNewZones )
	thread SelectBestZonePair_Threaded( losingTeam, bestZones )
}


void function ClearActiveSpawnZone( SpawnZone oldActiveZone )
{
	oldActiveZone.isActive = false
	oldActiveZone.teamId = TEAM_UNASSIGNED
	oldActiveZone.failureScore = 0
	oldActiveZone.spawnCount = 0
}

void function SpawnZone_SetActiveForTeam( SpawnZone spawnZone, int teamId )
{
	SpawnZone oldActiveZone = SpawnZone_GetActiveForTeam( teamId )

	if ( oldActiveZone.id != -1 )
	{
		ClearActiveSpawnZone( oldActiveZone )
	}

	file.activeTeamZoneIds[teamId] = spawnZone.id
	spawnZone.teamId = teamId
	spawnZone.isActive = true
	spawnZone.failureScore = 0
	spawnZone.spawnCount = 0
	spawnZone.repeatUseCount[teamId - TEAM_IMC]++
	spawnZone.endTime = Time() + RandomFloatRange( MIN_ZONE_TIME, MAX_ZONE_TIME )

	#if SHOW_ZONES_ON_MINIMAP
		entity minimapSpawnZone
		if ( teamId == TEAM_MILITIA )
			minimapSpawnZone = file.minimapSpawnZones[0]
		else
			minimapSpawnZone = file.minimapSpawnZones[1]
		minimapSpawnZone.SetOrigin( spawnZone.origin )
		minimapSpawnZone.Minimap_SetObjectScale( max( spawnZone.radius, 128 ) / 16834 )
		if ( SpawnZonesVisibleOnMinimap() )
		{
			minimapSpawnZone.Minimap_AlwaysShow( teamId, null )
			minimapSpawnZone.Minimap_Hide( GetOtherTeam( teamId ), null )
		}
	#endif
}

void function SetSpawnZonesVisibleOnMinimap( bool visible )
{
	file.spawnZonesVisibleOnMinimap = visible
}

bool function SpawnZonesVisibleOnMinimap()
{
	return file.spawnZonesVisibleOnMinimap
}

SpawnZone function SpawnZone_GetActiveForTeam( int teamId )
{
	int activeId = file.activeTeamZoneIds[teamId]
	if ( activeId != -1 )
		return file.spawnZones[activeId]

	SpawnZone dummyZone
	return dummyZone
}


void function SpawnZone_ChooseOnFirstDeath()
{
	entity player
	for ( ;; )
	{
		var result = svGlobal.levelEnt.WaitSignal( "PlayerKilled" )

		player = expect entity( result.player )

		if ( IsValid( player ) )
			break
	}

	int team = player.GetTeam()
	SpawnZone&[2] bestZones
	Assert( !file.choosingNewZones )
	SelectBestZonePair_Threaded( team, bestZones )

	int otherTeam = GetOtherTeam( team )

	if ( !file.gameOver )
	{
		SpawnZone_SetActiveForTeam( bestZones[0], team )
		SpawnZone_SetActiveForTeam( bestZones[1], otherTeam )
	}
}


void function SpawnZone_ForStartSpawns()
{
	SpawnZone_SetActiveForTeam( SpawnZone_GetForStartSpawns( TEAM_IMC ), TEAM_IMC )
	SpawnZone_SetActiveForTeam( SpawnZone_GetForStartSpawns( TEAM_MILITIA ), TEAM_MILITIA )
}


SpawnZone function SpawnZone_GetForStartSpawns( int teamId )
{
	vector averageOrigin = <0,0,0>
	int originCount = 0

	foreach ( spawnPoint in svSpawnGlobals.allNormalSpawnpoints )
	{
		if ( !IsValid( spawnPoint ) )
			continue

		if ( !spawnPoint.GetClassName().find_olduntyped( "human" ) )
			continue

		if ( spawnPoint.GetTeam() != teamId )
			continue

		averageOrigin += spawnPoint.GetOrigin()
		originCount++
	}

	averageOrigin /= originCount

	float bestDist = 99999.9
	SpawnZone bestZone
	foreach ( spawnZone in file.spawnZones )
	{
		float dist = Distance( spawnZone.origin, averageOrigin )
		if ( dist < bestDist )
		{
			bestDist = dist
			bestZone = spawnZone
		}
	}

	return bestZone
}

void function InitSpawnZones()
{
	if ( file.spawnpointRatingFunc != RateSpawnpoints_SpawnZones )
	{
		file.spawnZones.clear()
		return
	}

	if ( file.spawnZones.len() < 2 )
	{
		if ( file.spawnZones.len() > 0 )
			Warning( "This map has only one spawn zone; need at least one pair, or none at all" )
		Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Directional )
		file.spawnZones.clear()
		return
	}

	printt( "Using Spawn Zones (" + GetMapName() + ")" )
	file.initializedSpawnZones = true

	foreach ( spawnPoint in svSpawnGlobals.allNormalSpawnpoints )
	{
		if ( !IsValid( spawnPoint ) )
			continue

		if ( !spawnPoint.GetClassName().find_olduntyped( "human" ) )
			continue

		vector spawnPointOrigin = spawnPoint.GetOrigin()

		foreach ( SpawnZone spawnZone in file.spawnZones )
		{
			if ( spawnZone.trigger.ContainsPoint( spawnPointOrigin ) )
			{
				spawnZone.spawnPoints.append( spawnPoint )
				spawnPoint.sp.zones.append( spawnZone.id )
			}
		}

		SetTeam( spawnPoint, TEAM_UNASSIGNED )
	}

	foreach ( i, spawnZone in file.spawnZones )
	{
		printt( "SpawnZone " + i + " " + spawnZone.trigger.GetOrigin() )
	}

	foreach ( spawnZone in file.spawnZones )
	{
		if ( spawnZone.spawnPoints.len() == 0 )
		{
			Warning( "Spawn zone at " + spawnZone.trigger.GetOrigin() + " has no spawnpoints." )
			file.spawnZones.clear()
			break
		}

		if ( spawnZone.spawnPoints.len() < 4 )
		{
			Warning( "Spawn zone at " + spawnZone.trigger.GetOrigin() + " only has " + spawnZone.spawnPoints.len() + "  spawnpoints." )
			file.spawnZones.clear()
			break
		}

		spawnZone.origin = <0,0,0>
		foreach ( spawnPoint in spawnZone.spawnPoints )
		{
			spawnZone.origin += spawnPoint.GetOrigin()
		}
		spawnZone.origin /= spawnZone.spawnPoints.len()

		float radiusSq = 0
		foreach ( spawnPoint in spawnZone.spawnPoints )
		{
			radiusSq = max( radiusSq, DistanceSqr( spawnZone.origin, spawnPoint.GetOrigin() ) )
		}
		spawnZone.radius = sqrt( radiusSq ) + 128

		entity trigger = CreateEntity( "trigger_cylinder" )

		spawnZone.radiusTrigger = trigger

		trigger.SetCylinderRadius( spawnZone.radius )
		trigger.SetAboveHeight( 150 )
		trigger.SetBelowHeight( 150 )
		trigger.SetOrigin( spawnZone.origin )
		DispatchSpawn( trigger )
		trigger.SetEnterCallback( OnEnterSpawnZoneRadiusTrigger )
		trigger.SetLeaveCallback( OnLeaveSpawnZoneRadiusTrigger )

		array<entity> linkedTriggers = spawnZone.trigger.GetLinkParentArray()
		linkedTriggers.extend( spawnZone.trigger.GetLinkEntArray() )

		foreach ( otherZone in file.spawnZones )
		{
			if ( otherZone == spawnZone )
				continue

			if ( !linkedTriggers.contains( otherZone.trigger ) )
				continue

			spawnZone.linkedZones.append( otherZone.id )
		}

		if ( spawnZone.linkedZones.len() == 0 )
		{
			Warning( "SpawnZone at " + spawnZone.trigger.GetOrigin() + " is not linked to any other spawn zones." )
			file.spawnZones.clear()
			break
		}
	}

	if ( file.spawnZones.len() == 0 )
	{
		Warning( "Spawn zones disabled. One or more spawn zones are invalid." )
		Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Directional )
		file.spawnZones.clear()
		return
	}

	if ( GetMapName() == "mp_crashsite3" )
	{
		LinkZonesAt( <-32,-800,1120>, <-4272,-2416,1104> ) // 1, 3
		LinkZonesAt( <-8149.56,-3144,1104>, <-4272,-2416,1104> ) // 2, 3
	}

	Assert( file.spawnZones.len() >= 2 )

	if ( GetCurrentPlaylistVarInt( "spawn_zone_force_start", 0) == 0 )
		thread SpawnZone_ChooseOnFirstDeath()
	else
		thread SpawnZone_ForStartSpawns()

	#if SHOW_ZONES_ON_MINIMAP
		for ( int i = 0; i < 2; i++ )
		{
			entity minimapSpawnZone = CreatePropScript( $"mdl/dev/empty_model.rmdl", <9999,9999,0>, <0,0,0>, 6 )
			minimapSpawnZone.NotSolid()
			minimapSpawnZone.Hide()
			minimapSpawnZone.DisableHibernation()
			Assert( TEAM_MILITIA - 1 == TEAM_IMC )
			SetTeam( minimapSpawnZone, TEAM_MILITIA - i )
			minimapSpawnZone.Minimap_SetObjectScale( 1000.0 / 16834 )
			minimapSpawnZone.Minimap_SetAlignUpright( true )
			minimapSpawnZone.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
			minimapSpawnZone.Minimap_SetClampToEdge( true )
			minimapSpawnZone.Minimap_Hide( TEAM_IMC, null )
			minimapSpawnZone.Minimap_Hide( TEAM_MILITIA, null )
			Assert( eMinimapObject_prop_script.SPAWNZONE_MIL + 1 == eMinimapObject_prop_script.SPAWNZONE_IMC )
			minimapSpawnZone.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_MIL + i )

			file.minimapSpawnZones[i] = minimapSpawnZone
		}
	#endif

	#if DEBUG_SPAWN_ZONES
		thread DebugSpawnZones()
	#endif
}

void function LinkZonesAt( vector a, vector b )
{
	int founda = 0
	int foundb = 0
	SpawnZone zonea
	SpawnZone zoneb
	foreach ( zone in file.spawnZones )
	{
		if ( DistanceSqr( zone.trigger.GetOrigin(), a ) < 25.0 )
		{
			founda++
			zonea = zone
		}
		if ( DistanceSqr( zone.trigger.GetOrigin(), b ) < 25.0 )
		{
			foundb++
			zoneb = zone
		}
	}

	Assert( founda == 1 )
	Assert( foundb == 1 )

	zonea.linkedZones.append( zoneb.id )
	zoneb.linkedZones.append( zonea.id )
}

#if DEV
void function DebugSpawnZones()
{
	for ( ;; )
	{
		SpawnZone zoneA = SpawnZone_GetActiveForTeam( TEAM_MILITIA )
		SpawnZone zoneB = SpawnZone_GetActiveForTeam( TEAM_IMC )

		foreach ( spawnpoint in zoneA.spawnPoints )
		{
			DebugDrawLine( zoneA.origin, spawnpoint.GetOrigin(), COLOR_BLUE, true, 0.5 )
		}
		foreach ( spawnpoint in zoneB.spawnPoints )
		{
			DebugDrawLine( zoneB.origin, spawnpoint.GetOrigin(), COLOR_RED, true, 0.5 )
		}

		foreach ( player in GetPlayerArray() )
		{
			if ( player.GetTeam() == TEAM_MILITIA )
				DebugDrawLine( player.GetOrigin(), player.GetOrigin() + <0,0,82>, COLOR_BLUE, true, 0.1 )
			else if ( player.GetTeam() == TEAM_IMC )
				DebugDrawLine( player.GetOrigin(), player.GetOrigin() + <0,0,82>, COLOR_RED, true, 0.1 )
			else
				DebugDrawLine( player.GetOrigin(), player.GetOrigin() + <0,0,82>, <128,128,128>, true, 0.1 )
		}

		WaitFrame()
	}
}
#endif


void function OnEnterSpawnZoneRadiusTrigger( entity trigger, entity ent )
{
}

void function OnLeaveSpawnZoneRadiusTrigger( entity trigger, entity ent )
{
}


void function RateSpawnpoints_SpawnZones( int checkClass, array<entity> spawnPoints, int team, entity player )
{
	if ( file.activeTeamZoneIds[team] == -1 )
	{
		foreach ( spawnPoint in spawnPoints )
		{
			float rating = spawnPoint.CalculateRating( checkClass, team, 0.0, 0.0 )
#if SPAWNING_DEBUG
			spawnPoint.e.spawnPointData.lastRatingData = spawnPoint.GetRatingData()
			spawnPoint.e.spawnPointData.lastRatingData.rating <- rating
#endif
		}
		return
	}

	int otherTeamId = GetOtherTeam( team )
	SpawnZone enemyZone = file.spawnZones[file.activeTeamZoneIds[otherTeamId]]
	SpawnZone friendlyZone = file.spawnZones[file.activeTeamZoneIds[team]]

	array<entity> enemyPlayers = GetPlayerArrayOfTeam_Alive( otherTeamId )
	array<vector> enemyOrigins = EntitiesToOrigins( enemyPlayers )
	enemyOrigins.append( enemyZone.origin )
	vector enemyOrigin = GetMedianOrigin( enemyOrigins )

	array<SpawnZone> nearestInactiveZones = SpawnZone_GetNearestInactiveArray( enemyOrigin )

	foreach ( spawnPoint in spawnPoints )
	{
		vector spawnPointOrigin = spawnPoint.GetOrigin()

		int zoneIndex

		float additionalRating = 0.0

		if ( spawnPoint.sp.zones.contains( friendlyZone.id ) )
		{
			if ( friendlyZone.spawnCount < MAX_ZONE_SPAWNS )
				additionalRating += 4.0
		}
		else if ( GetCurrentPlaylistVarInt( "spawn_zone_force_start", 0) == 1 )
		{
			additionalRating = -1000
		}

		if ( spawnPoint.sp.zones.contains( enemyZone.id ) )
		{
			additionalRating -= 15.0
		}

		if ( additionalRating == 0 && Distance2DSqr( spawnPointOrigin, friendlyZone.origin ) < Distance2DSqr( spawnPointOrigin, enemyZone.origin ) )
		{
			additionalRating += 2.0
		}

		vector vecToEnemies = Normalize( enemyOrigin - spawnPointOrigin )
		additionalRating += GraphCapped( DotProduct( spawnPoint.GetForwardVector(), vecToEnemies ), -1, 0.707, -3, 0 )

		float rating = spawnPoint.CalculateRating( checkClass, team, additionalRating, 0.0 )
#if SPAWNING_DEBUG
		spawnPoint.e.spawnPointData.lastRatingData = spawnPoint.GetRatingData()
		spawnPoint.e.spawnPointData.lastRatingData.rating <- rating
#endif
	}
}


array<array> function CodeCallback_SpawnpointDebugText( entity spawnPoint, int team )
{
	array<array> returnArray = []
	return returnArray
}


vector function SpawnZone_GetVectorToZone( vector origin, SpawnZone spawnZone )
{
	return Normalize( spawnZone.origin - origin )
}


void function Spawn_OnPlayerRespawned( entity player )
{
	if ( !IsValid( player.p.lastSpawnPoint ) )
		return

	entity spawnPoint = player.p.lastSpawnPoint

	if ( !spawnPoint.GetClassName().find_olduntyped( "human" ) )
		return

	if ( file.spawnZones.len() == 0 )
		return

	if ( file.choosingNewZones )
		return

	if ( GetCurrentPlaylistVarInt( "spawn_zone_force_start", 0) != 0 )
		return

	int teamId = player.GetTeam()
	if ( file.activeTeamZoneIds[teamId] < 0 )
		return

	SpawnZone activeSpawnZone = SpawnZone_GetActiveForTeam( teamId )

	bool spawnedInZone = spawnPoint.sp.zones.contains( activeSpawnZone.id )

	if ( !player.IsTitan() )
	{
		if ( spawnedInZone )
		{
			activeSpawnZone.spawnCount++
			activeSpawnZone.failureScore = max( 0.0, activeSpawnZone.failureScore - 0.2 ) // decay a bit
		}
		else
		{
			activeSpawnZone.failureScore++
			printt( "Failed spawn in zone " + activeSpawnZone.id + " (" + player + "): " + activeSpawnZone.failureScore )
		}
	}
	else if ( spawnedInZone )
	{
		activeSpawnZone.spawnCount++
	}

	if ( activeSpawnZone.failureScore >= MAX_ZONE_FAILED_SPAWNS )
	{
		printt( "zone " + activeSpawnZone.id + " failed; switching" )
		SpawnZoneTeamLosesZone( teamId )
	}
	else if ( activeSpawnZone.spawnCount >= MAX_ZONE_SPAWNS )
	{
		printt( "zone " + activeSpawnZone.id + " remaining spawns 0" )
		SpawnZoneTeamLosesZone( teamId )
	}

	if ( activeSpawnZone.spawnCount >= 3 )
	{
		entity minimapSpawnZone
		if ( teamId == TEAM_MILITIA )
			minimapSpawnZone = file.minimapSpawnZones[0]
		else
			minimapSpawnZone = file.minimapSpawnZones[1]
		minimapSpawnZone.Minimap_AlwaysShow( GetOtherTeam( teamId ), null )
	}

	if ( spawnedInZone && !file.choosingNewZones )
		thread TrackBadPlayerSpawn( player, spawnPoint, activeSpawnZone )
}

#if SPAWNING_DEBUG
const ratingScale = 20.0
void function DrawSpawnPointRatings( int teamId )
{
	RegisterSignal( "DrawSpawnPointRatings" )
	svGlobal.levelEnt.Signal( "DrawSpawnPointRatings" )

	foreach ( spawnPoint in svSpawnGlobals.allNormalSpawnpoints )
	{
		if ( !IsValid( spawnPoint ) )
			continue

		if ( !spawnPoint.GetClassName().find_olduntyped( "human" ) )
			continue

		if ( !("ter" in spawnPoint.e.spawnPointData.lastRatingData ) )
			continue

		thread DrawSpawnPointRating( spawnPoint, spawnPoint.e.spawnPointData.lastRatingData )
	}
}

void function DrawSpawnPointRating( entity spawnPoint, table ratingData )
{
	svGlobal.levelEnt.EndSignal( "DrawSpawnPointRatings" )

	if ( ratingData.enemyVis )
		return

	while ( true )
	{
		var enemyRating = ratingData.ter + ratingData.per + ratingData.ner
		DebugDrawBox( spawnPoint.GetOrigin(), <-14, -14, enemyRating * -ratingScale>, <14,14,0>, <255, 128, 0>, 1, 1.1 )

		var friendlyRating = ratingData.tfr + ratingData.pfr + ratingData.nfr
		DebugDrawBox( spawnPoint.GetOrigin(), <-14,-14,0>, <14, 14, friendlyRating * ratingScale>, <0, 128, 255>, 1, 1.1 )

		DebugDrawBox( spawnPoint.GetOrigin(), <-16,-16,0>, <16, 16, ratingData.rating * ratingScale>, COLOR_WHITE, 1, 1.1 )

		wait 1.0
	}
}
#endif // DEV

const BAD_SPAWN_TIME_MIN = 2.0
const BAD_SPAWN_TIME_MAX = 10.0
void function TrackBadPlayerSpawn( entity player, entity spawnPoint, SpawnZone spawnedInSpawnZone )
{
	float spawnTime = Time()

	player.EndSignal( "OnDestroy" )

	table deathParams = player.WaitSignal( "OnDeath" )

	float timePassed = Time() - spawnTime
	if ( timePassed > BAD_SPAWN_TIME_MAX )
		return

	if ( file.choosingNewZones )
		return

	int teamId = player.GetTeam()
	if ( file.activeTeamZoneIds[teamId] < 0 )
		return

	entity attacker = expect entity( deathParams.activator )
	if ( !IsValid( attacker ) )
		return

	if ( !IsEnemyTeam( teamId, attacker.GetTeam() ) )
		return

	SpawnZone activeSpawnZone = SpawnZone_GetActiveForTeam( teamId )
	if ( activeSpawnZone != spawnedInSpawnZone )
		return

	float penalty = GraphCapped( timePassed, BAD_SPAWN_TIME_MIN, BAD_SPAWN_TIME_MAX, 2.0, 0.0 )

	activeSpawnZone.failureScore += penalty
	printt( "Bad spawn in zone " + activeSpawnZone.id + " (" + player + ", " + penalty + "): " + activeSpawnZone.failureScore )
	if ( activeSpawnZone.failureScore >= MAX_ZONE_FAILED_SPAWNS )
	{
		printt( "zone " + activeSpawnZone.id + " failed; switching" )
		SpawnZoneTeamLosesZone( teamId )
	}
}

SpawnZone function SpawnZone_GetNearest( vector origin )
{
	SpawnZone bestZone
	float bestDist = 99999.9
	foreach ( spawnZone in file.spawnZones )
	{
		float dist = Distance( spawnZone.origin, origin )
		if ( dist >= bestDist )
			continue

		bestZone = spawnZone
		bestDist = dist
	}

	return bestZone
}


SpawnZone function SpawnZone_GetNearestInactive( vector origin )
{
	SpawnZone bestZone
	float bestDist = 99999.9
	foreach ( SpawnZone spawnZone in file.spawnZones )
	{
		if ( spawnZone.isActive )
			continue

		float dist = Distance( spawnZone.origin, origin )
		if ( dist >= bestDist )
			continue

		bestZone = spawnZone
		bestDist = dist
	}

	Assert( bestZone.id != -1, "Map should have more than 2 spawn zones" )
	return bestZone
}


struct ZoneSortData
{
	int id = -1
	float distance = 0.0
}

int function ZoneSortCompareClosest( ZoneSortData a, ZoneSortData b )
{
	if ( a.distance > b.distance )
		return 1
	else if ( a.distance < b.distance )
		return -1

	return 0
}

array<SpawnZone> function SpawnZone_GetNearestInactiveArray( vector origin )
{
	array<ZoneSortData> zoneSortDataArray
	foreach ( spawnZone in file.spawnZones )
	{
		if ( spawnZone.isActive )
			continue

		ZoneSortData zoneSortData
		zoneSortData.id = spawnZone.id
		zoneSortData.distance = Distance( spawnZone.origin, origin )
		zoneSortDataArray.append( zoneSortData )
	}

	zoneSortDataArray.sort( ZoneSortCompareClosest )

	array<SpawnZone> spawnZones
	foreach ( zoneSortData in zoneSortDataArray )
	{
		SpawnZone spawnZone = file.spawnZones[zoneSortData.id]
		spawnZones.append( spawnZone )
	}

	return spawnZones
}

void function CreateNewSpawnPoint( string className, vector origin, vector angles )
{
	if ( !( "scriptCreatedSpawnPoints" in level ) )
		level.scriptCreatedSpawnPoints <- []

	if ( !( "scriptCreatedSpawnPointsIndex" in level ) )
		level.scriptCreatedSpawnPointsIndex <- -1

	entity spawnpoint = CreateEntity( className )
	spawnpoint.SetOrigin( origin )
	spawnpoint.SetAngles( angles )
	DispatchSpawn( spawnpoint )

	level.scriptCreatedSpawnPoints.append( spawnpoint )
}

void function TestSpawnPoint()
{
	if ( level.scriptCreatedSpawnPointsIndex < 0 )
		level.scriptCreatedSpawnPointsIndex = level.scriptCreatedSpawnPoints.len() - 1
	if ( level.scriptCreatedSpawnPointsIndex >= level.scriptCreatedSpawnPoints.len() )
		level.scriptCreatedSpawnPointsIndex = 0

	entity spawnpoint = expect entity( level.scriptCreatedSpawnPoints[ level.scriptCreatedSpawnPointsIndex ] )

	GetPlayerArray()[ 0 ].SetOrigin( spawnpoint.GetOrigin() )
	GetPlayerArray()[ 0 ].SetAngles( spawnpoint.GetAngles() )

	printt( "Viewing spawnpoint " + ( level.scriptCreatedSpawnPointsIndex + 1 ) + "/" + level.scriptCreatedSpawnPoints.len() + " at org " + spawnpoint.GetOrigin() + " ang " + spawnpoint.GetAngles() )
}

void function TestNextScriptSpawnPoint()
{
	level.scriptCreatedSpawnPointsIndex++
	TestSpawnPoint()
}

void function TestPreviousScriptSpawnPoint()
{
	level.scriptCreatedSpawnPointsIndex--
	TestSpawnPoint()
}

float function GetSpawnRating_ScaleFriendly()
{
	return GetCurrentPlaylistVarFloat( "spawn_rating_scale_friendly", 0.75 )
}
float function GetSpawnRating_ScaleEnemy()
{
	return GetCurrentPlaylistVarFloat( "spawn_rating_scale_enemy", -4.0 )
}
bool function GetSpawnRating_TestLOS()
{
	return GetCurrentPlaylistVarBool( "spawn_test_los", true )
}
