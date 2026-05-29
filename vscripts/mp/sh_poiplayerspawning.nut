global function POIPlayerSpawning_Exists
global function POIPlayerSpawning_Init

#if SERVER
global function POIPlayerSpawning_SpawnPlayers

#if DEVELOPER
global function DEV_PrintLootAroundCuratedSpawns
global function DEV_PrintLootTotalsForCuratedSpawns
global function DEV_PrintLootTotalsAndDrawCuratedSpawns
global function DEV_POISpawn_CheckStartRings
global function DEV_POISpawn_Test
global function DEV_POISpawn_Show
global function DEV_POISpawn_CustomDropship_Test
const POISPAWNING_DEBUGDRAWTIME = 60
#endif // DEV
#endif // SERVER

#if CLIENT
global function CL_POISpawn_LandingMarkers_Destroy
global function ServerToClient_CustomDropship_CameraZoom
global function CL_EnemyPOI_Set_Wp_Size
#endif // CLIENT

// --- Custom Dropship consts
const vector CUSTOM_DROPSHIP_PARALLEL_FACING = < 0, 1, 0 >

// --- Team Type

global enum eTurboBRTeamType
{
	INVALID = -1,
	LOWERMMR,
	HUMAN,
	MIXED,
	BOTS,
	COUNT_
}

// --- CONSTS
const string 	CUSTOMDROPSHIP_ANIM_FLYIN_NAME = "dropship_classic_mp_flyin"
const string	CUSTOMDROPSHIP_SOUND_NAME = "goblin_imc_evac_hover"

const float 	POISPAWN_SQUADS_MINDISTANCE 		= 3937.01 * 2.0 // 200 meters
const float 	POISPAWN_CURATEDSPAWNS_MINDISTANCE 	= 3937.01 * 1.0 // 100 meters
const int 		POISPAWN_MAX_SPAWNPOINTS_PER_ZONE 	= 2
const float 	POISPAWN_GROUPRADIUS 				= 64
const float		POISPAWN_CLEARING_DISTANCE 			= 96 // was 128
const float 	POISPAWN_AIRDROPHEIGHT 				= 12709 // was 25419 // was 19900
const float 	POISPAWN_GROUNDSPAWNHEIGHT 			= 128
const float 	POISPAWN_STARTRADIUS_DEFAULT 		= 65000
const int		SQUADS_PERGROUP_DEFAULT 			= 2

const float 	POISPAWN_CONSTRAINEDDIVE_2DRADIUS = 2952.8 // 75m. Was 1968.5, or 50m

const asset		GROUNDMARKER_FX_RING 	= $"P_ar_target_fuse_instant" // $"P_ar_loot_drop_point_cp" // $"P_ar_fuse_artillery_marker"
const asset 	GROUNDMARKER_FX_CENTER 	= $"P_ar_loot_drop_point_cp"
const asset 	GROUNDMARKER_FX_BEACON 	= $"P_tbr_flare_trail" // $"P_ar_loot_drop_point_far_cp"
const float		GROUNDMARKER_RING_FX_RADIUSDIVISOR = 20.0
const vector 	GROUNDMARKER_RING_FX_COLOR = < 19, 255, 190 >
const vector	GROUNDMARKER_RING_FX_OUTERMOST_COLOR = < 255, 19, 19 >
const vector 	GROUNDMARKER_CENTER_FX_COLOR = < 19, 219, 190 >
const string	POISPAWN_SKYDIVEDESTWP_NAME = "poispawn_wp"
const int		POISPAWN_SKYDIVEDESTWP_NDX_TEAM = 0

#if DEVELOPER
const FORCEDEBUG = false
#endif

// ---

struct sSkydiveLandingMarker
{
	entity landingWP
	entity centerFX
	entity minimapObj
}

struct
{
	#if SERVER
		table< int, array<entity> > groupedPlayers 			// Indexed by Team.

		array< vector > previousAirdropLocs

		vector 	startMatch_Center
		float 	startMatch_Radius

		// --- Curated Spawns
		array< entity > curatedSpawn_Ents					// All curated info_target spawn ents
		array< entity > curatedSpawn_Ents_TooClose			// Curated spawns that are too close to another. For Debugging.
		array< entity > curatedSpawn_Ents_InStartRange		// All curated spawn ents in start range.

		array< vector > curatedSpawn_Locs_InStartRange 		// All curated spawn locations in radius of start center.
		array< entity > curatedSpawn_Ents_WithLinks			// All curated spawn ents with links to other curated spawn ents in the start range.
		array< entity > curatedSpawn_Ents_WithoutLinks		// All curated spawn ents with no links to other curated spawn ents.
		table < entity, entity > curatedSpawn_Map_LinkedEnts// All curated spawn ents mapped to their linked spawns.
		table< int, sSkydiveLandingMarker > landingMarkers_ByTeam	// landing ground marker fx entities.
		array< entity > curatedSpawn_Ents_Used				// Collection of SpawnEnts used. There should be no duplicates in here.

		// Landing Enemy Pinging Stuff.
		table< int, entity > spawnEnt_For_Team			// Chosen Spawn Ents indexed by Team.
		table< entity, int > team_At_SpawnEnt			// Team spawned at spawnEnt index.
		array< int > teams_ThatDidLandingPing 			// Array of teams that have pinged linked enemies.
		table< int, array< entity > > landedPlayers_ByTeam // Tracks players that have landed.

		table< vector, Point  > curatedSpawn_LinkedPoint_BySrcLoc	// Points related to the spawn at the vector index.
		table< vector, entity > curatedSpawn_LinkedEnt_BySrcLoc	// Point linked to the Src ( Source ) spawn at the Loc vector index.

		array< vector > spawnLocsUsed_All 				// Spawn locations chosen for spawning.
		table< int, vector > spawnLoc_Used_ByTeam		// Spawn Point Centers used by each team, indexed by team.
		array< int > allTeams_Spawned_At_CuratedSpawns	// Array of all teams that were spawned.

		// Back-up Loot-Based SpawnPoints system
		array< int > 				zoneIDs_SortedByBounds
		table< int, array< vector > > zoneCenters_ByZoneID
		array< vector > allSpawnLocs_fromLootLocs 							// Loot locations spread out by a minimum distance.

		table< int, array< vector > > crafterBasedZoneCenters_ByZoneID 	// Indexed by ZoneID

		table< int, array< Point > > spawnPoints_ByZoneID 		// Indexed by ZoneID
		table< int, array< int > > teams_Assigned_ToZoneIDs 		// array< int > of teams indexed by zone IDs.

		#if DEVELOPER
			table< int, int > zoneIDs_ByTeam				// zoneIDs indexed by Team
		#endif // DEV

		// --- Team Type Stuff
		array< int > 				teamsToSpawn 			// Array of teams to spawn. Should be empty after all spawning is done.
		table< int, array< int > > 	teamsToSpawn_ByType		// Arrays of teams to spawn indexed by type. Should be empty after all spawning is done.
		table< int, int > teamType	// Team type indexed by team. Example: file.teamType[ 11 ] == Team 11's team type.

		// Dropship Stuff
		array< dropshipAnimData > dropshipAnimDataList
	#endif // SERVER

	#if CLIENT
		array< int > LandingMarker_FX_Rings
		array< int > LandingMarker_FX_Beams
	#endif // CLIENT
} file

// ---

#if SERVER
#if DEVELOPER
void function DEV_POISpawn_CheckStartRings()
{
	float radius_0 = GetCurrentPlaylistVarFloat( "deathfield_radius_0", -1 )
	float radius_Start = GetCurrentPlaylistVarFloat( "survival_death_field_start_radius", -1 )

	printt( format( "%s(): ***** START RING CHECK", FUNC_NAME() ) )
	printt( format( "%s(): deathfield_radius_0: %s", FUNC_NAME(), string( radius_0 )) )
	printt( format( "%s(): survival_death_field_start_radius: %s", FUNC_NAME(), string( radius_Start )) )
	printt( format( "%s(): file.startmatch_Radius: %s", FUNC_NAME(), string( file.startMatch_Radius )) )

	string erroString = format( "%s(): ERROR: Need to define a proper startMatch Radius", FUNC_NAME() )
	Assert( (( radius_0 > 0 ) || ( radius_Start > 0  ) || ( file.startMatch_Radius > 0 )), erroString )

	int numTeams = 0
	foreach( int team, array< entity > teamPlayers in file.groupedPlayers )
	{
		numTeams++
	}
	printt( format( "%s(): numTeams: %s", FUNC_NAME(), string( numTeams )) )

	string startCentersStr = GetCurrentPlaylistVarString( "deathfield_start_positions", "" )
	array<vector> startCenters = GamemodeUtility_ParseStringOfVectors( startCentersStr )

	foreach( center in startCenters )
	{
		array< entity > spawnsInside_Radius_0		= []
		array< entity > spawnsOutside_Radius_0		= []
		array< entity > spawnsInside_Radius_Start 	= []
		array< entity > spawnsOutside_Radius_Start	= []
		array< entity > spawnsInside_startMatchRadius= []
		array< entity > spawnsOutside_startMatchRadius = []

		// Test against the different starting radii
		foreach( spawnPt in file.curatedSpawn_Ents )
		{
			vector spawnLoc = spawnPt.GetOrigin()
			_CheckLocEnt_and_AddToList( spawnPt, center, radius_0, spawnsInside_Radius_0, spawnsOutside_Radius_0 )
			_CheckLocEnt_and_AddToList( spawnPt, center, radius_Start, spawnsInside_Radius_Start, spawnsOutside_Radius_Start )
			_CheckLocEnt_and_AddToList( spawnPt, center, file.startMatch_Radius, spawnsInside_startMatchRadius, spawnsOutside_startMatchRadius )
		}

		int len_inside_Ring_0 = spawnsInside_Radius_0.len()
		int len_inside_Ring_Start = spawnsInside_Radius_Start.len()
		int len_inside_startMatch_Radius = spawnsInside_startMatchRadius.len()
		string checkResults

		printt( format( "%s(): ---------- Report START for Starting Ring @: %s", FUNC_NAME(), string( center )) )
		printt( format( "%s(): 		spawns Inside deathfield_radius_0: %s", FUNC_NAME(), string( len_inside_Ring_0 )) )
		printt( format( "%s(): 		spawns Outside deathfield_radius_0: %s", FUNC_NAME(), string (spawnsOutside_Radius_0.len())) )
		checkResults = len_inside_Ring_0 >= numTeams ? "+++ PASS." : "--- FAILL."
		printt( format( "%s(): --- Check for deathfield_radius_0: %s", FUNC_NAME(), checkResults ) )

		printt( format( "%s(): 		spawns Inside survival_death_field_start_radius: %s", FUNC_NAME(), string( len_inside_Ring_Start )) )
		printt( format( "%s(): 		spawns Outside survival_death_field_start_radius: %s", FUNC_NAME(), string( spawnsOutside_Radius_Start.len())) )
		checkResults = len_inside_Ring_Start >= numTeams ? "+++ PASS." : "--- FAIL."
		printt( format( "%s(): --- Check for survival_death_field_start_radius: %s", FUNC_NAME(), checkResults ) )

		printt( format( "%s(): 		spawns Inside file.startMatch_Radius: %s", FUNC_NAME(), string( len_inside_startMatch_Radius )) )
		printt( format( "%s(): 		spawns Outside file.startMatch_Radius: %s", FUNC_NAME(), string( spawnsOutside_startMatchRadius.len())) )
		checkResults = len_inside_startMatch_Radius >= numTeams ? "+++ PASS." : "--- FAIL."
		printt( format( "%s(): --- Check for file.startMatch_Radius: %s", FUNC_NAME(), checkResults ) )
		printt( format( "%s(): ---------- Report END for Starting Ring @: %s\n", FUNC_NAME(), string( center )) )
	}
}

void function _CheckLocEnt_and_AddToList( entity spawnEnt, vector center, float radius, array< entity > insideArray, array< entity > outsideArray )
{
	float radiusSqr = pow( radius, 2 )
	vector spawnLoc = spawnEnt.GetOrigin()
	if ( Distance2DSqr( center, spawnLoc ) <= radiusSqr )
	{
		insideArray.append( spawnEnt )
	}
	else
	{
		outsideArray.append( spawnEnt )
	}
}

void function DEV_POISpawn_CustomDropship_Test( float dropshipAngleAdjust = 90.0, bool debug = false )
{
	entity player = GetPlayerArray()[0]

	int team = player.GetTeam()

	vector origin = GetPlayerCrosshairOrigin( player )
	vector eyeAngles = player.EyeAngles()
	//vector angles = <0.0, (eyeAngles.y + 180.0), 0.0>
	vector angles = <0.0, eyeAngles.y, 0.0>
	origin = NavMesh_GetClosestPoint( origin )

	Point destination
	destination.origin = origin
	destination.angles = angles

	LandingMarker_Create( team, destination )
	PrepareJump( team, destination)
	thread CustomDropShip_SpawnPlayers_AtPoint( destination, team, dropshipAngleAdjust, debug )
}

void function DEV_POISpawn_Test()
{
	thread POIPlayerSpawning_SpawnPlayers( true )
}

void function DEV_DrawStartArea( float debugTime = POISPAWNING_DEBUGDRAWTIME )
{
	DEVCylinder( true, file.startMatch_Center, < 90, 0, 0 >, file.startMatch_Radius, 10000, COLOR_RED, false, debugTime )
}

void function DEV_POISpawn_Show( bool drawCurated = true, bool drawCuratedLinks = true, bool drawChosen = true, bool drawByZones = true  )
{
	thread function () : ( drawCurated, drawCuratedLinks, drawChosen, drawByZones )
	{
		FlagSet( "DeathFieldPaused" )

		float debugTime = POISPAWNING_DEBUGDRAWTIME * 6

		// Draw the starting Area as cylinder
		DEV_DrawStartArea( debugTime )

		if ( drawCurated )
		{
			// Draw All Raw Curated Spawn Ents inside start circle.
			printt( format( "%s(): Raw Curated Spawn Ents Count == %s ", FUNC_NAME(), string( file.curatedSpawn_Ents.len() ) ) )
			foreach( curatedEnt in file.curatedSpawn_Ents_InStartRange )
			{
				DEVCube( true, curatedEnt.GetOrigin(), 150, COLOR_DARK_GRAY, true, debugTime )
			}
		}

		if ( drawCuratedLinks )
		{
			// Draw All Curated Spawn Ents Links
			foreach( curatedEnt in file.curatedSpawn_Ents_WithLinks )
			{
				entity linkedEnt = curatedEnt.GetLinkEnt()
				DEVLine( true, curatedEnt.GetOrigin(), linkedEnt.GetOrigin(), COLOR_RED, true, debugTime )
			}
		}

		// Draw all chosen spawn points.
		if ( drawChosen )
		{
			table< int, string > teamTypeLabels
			teamTypeLabels[ eTurboBRTeamType.BOTS ] <- "( Bots )"
			teamTypeLabels[ eTurboBRTeamType.MIXED ] <- "( Mixed )"
			teamTypeLabels[ eTurboBRTeamType.HUMAN ] <- "( Human )"
			teamTypeLabels[ eTurboBRTeamType.LOWERMMR ] <- "( Human - Lower MMR )"

			foreach( chosenLoc in file.spawnLocsUsed_All )
			{
				DEVSphere( true, chosenLoc, 500, COLOR_ORANGE, true, debugTime, 8 )
			}

			int teamCount = file.groupedPlayers.len()
			printt( format( "POISPAWN: Team Count == %s", string ( teamCount )) )
			foreach( team, vector loc in file.spawnLoc_Used_ByTeam )
			{
				// Show Team Label
				string teamStr = "Team " + team + teamTypeLabels[ file.teamType[ team ] ]
				DebugDrawText( loc, teamStr, false, debugTime )

				// Show Teammates as Red Cylinders.
				array< entity > playersArray = file.groupedPlayers[ team ]
				foreach( player in playersArray )
				{
					if ( !IsValid( player ) )
						continue

					DEVCylinder( true, player.GetOrigin(), < -90,0,0 >, 32, 84, COLOR_RED, true, debugTime )
				}

				if ( team in file.zoneIDs_ByTeam )
				{
					int teamsZoneID = file.zoneIDs_ByTeam[ team ]
					printt( format( "POISPAWN: Team %s Assigned Zone == %s", string ( team ), string( teamsZoneID ) ) )
					printt( format( "POISPAWN: Team %s spawning at %s", string ( team ), string( loc )) )
				}

				// The location for this team was not in the array of spawnLocs used. ( A loot-based spawn point ).
				if ( !file.spawnLocsUsed_All.contains( loc ) )
				{
					DEVCube( true, loc, 250, COLOR_CYAN, true, debugTime )
				}
			}
		}

		if ( drawByZones )
		{
			// Draw Spawn Points by Zone
			foreach( int zoneID, array< Point > ptArray in file.spawnPoints_ByZoneID )
			{
				foreach( pt in ptArray )
				{
					vector loc = pt.origin
					DEVCube( true, loc, 200, COLOR_DARK_BLUE, true, debugTime )
					// TODO: NEED A BETTER WAY TO OUTPUT ZONE ID. DEBUGDRAWTEXT SUCKS!!!
					DebugDrawText( loc + < 0, 0, 650 >, string( zoneID ), false, debugTime  )
				}
			}
		}

		wait debugTime

		FlagClear( "DeathFieldPaused" )
	}()
}

// Prints everything about each area and their overlaps
void function DEV_PrintLootAroundCuratedSpawns( float radius )
{
	thread DEV_PrintLootAroundCuratedSpawns_Internal( radius, true, true, true, true )
}

// Just prints the total for each area + shared
void function DEV_PrintLootTotalsForCuratedSpawns( float radius )
{
	thread DEV_PrintLootAroundCuratedSpawns_Internal( radius, false, false, false, false )
}

// Prints totals and draws bounds of areas
void function DEV_PrintLootTotalsAndDrawCuratedSpawns( float radius )
{
	thread DEV_PrintLootAroundCuratedSpawns_Internal( radius, false, true, false, false )
}


void function DEV_PrintLootAroundCuratedSpawns_Internal( float radius, bool printAllContents, bool debugDrawAreas, bool debugDrawOverlappingLoot, bool debugDrawAllLoot )
{

}
#endif // DEV
#endif // SERVER

#if DEVELOPER
void function DEVSphere( bool debugParm, vector center, float radius, vector color, bool bShowThruGeo, float showTime, int segments = 4 )
{
	bool doDebug = debugParm || FORCEDEBUG
	if ( doDebug )
	{
		DebugDrawSphere( center, radius, int(color.x), int(color.y), int(color.z), bShowThruGeo, showTime, segments )
	}
}

void function DEVCube( bool debugParm, vector center, float size, vector color, bool bShowThruGeo, float showTime )
{
	bool doDebug = debugParm || FORCEDEBUG
	if ( doDebug )
	{
		DebugDrawCube( center, size, int( color.x ), int( color.y ), int( color.z ), bShowThruGeo, showTime )
	}
}

void function DEVLine( bool debugParm, vector start, vector end, vector color, bool showThruGeo, float showTime )
{
	bool doDebug = debugParm || FORCEDEBUG
	if ( doDebug )
	{
		DebugDrawLine( start, end, int(color.x), int(color.y), int(color.z), showThruGeo, showTime )
	}
}

void function DEVCylinder( bool debugParm, vector center, vector angles, float radius, float height, vector color, bool bShowThruGeo, float showTime )
{
	bool doDebug = debugParm || FORCEDEBUG
	if ( doDebug )
	{
		DebugDrawCylinder( center, angles, radius, height, int( color.x ), int( color.y ), int( color.z ), bShowThruGeo, showTime )
	}
}

void function DEVPrint( bool debugParm, string str )
{
	bool doDebug = debugParm || FORCEDEBUG
	if ( doDebug )
	{
		printt( str )
	}
}
#endif // DEV

// --- POI Spawning
bool function POIPlayerSpawning_Exists()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_exists", false ))	// Only use this for modes with curated spawn points.
}

// Toggles randomized vs. sorted for more deterministic spawn points.
bool function PLV_RandomSpawnPoints()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_randompoints", true ))
}

// Toggles airdrop presentation
bool function PLV_Airdrop()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_airdrop", true ))
}

// Toggles airdrop presentation
float function PLV_Airdrop_Height()
{
	return( GetCurrentPlaylistVarFloat( "poiplayerspawning_airdrop_height", POISPAWN_AIRDROPHEIGHT ))
}

bool function PLV_DropShipJump()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_dropshipjump", true ) )
}

bool function PLV_CustomDropship()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_customdropship", true ) )
}

bool function PLV_CustomDropship_AllShipsParallel()
{
	//	If TRUE, all custom dropships will travel Northward, and yield a view that matches the minimap/fullmap.
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_customdropship_allshipsparallel", true ) )
}

bool function PLV_CustomDropship_SkipOpenHatchShot()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_customdropship_skipopenhatchshot", true ) )
}

bool function PLV_CustomDropship_Skip1P()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_customdropship_skip1p", true ) )
}

bool function PLV_PingPairedEnemyOnLanding()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_pingpairedenemyonlanding", true ) )
}

// Toggles whether zones with 2 teams already in them can be considered to take left-over teams.
int function PLV_TeamsPerGroup()
{
	return( GetCurrentPlaylistVarInt( "poiplayerspawning_teamspergroup", SQUADS_PERGROUP_DEFAULT ))
}

float function PLV_SquadsMinDistance()
{
	return( GetCurrentPlaylistVarFloat( "poiplayerspawning_squadsmindistance", POISPAWN_SQUADS_MINDISTANCE ) )
}

bool function PLV_UseCuratedSpawns()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_usecuratedspawns", true ) )
}

bool function PLV_SpawnWithFreefall()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_spawnwithfreefall", false ) )
}

float function PLV_Skydive2DRadius()
{
	return( GetCurrentPlaylistVarFloat( "poiplayerspawning_skydive2dradius", POISPAWN_CONSTRAINEDDIVE_2DRADIUS ) )
}

bool function PLV_SpawnPointLootTicks_Enabled()
{
	return( GetCurrentPlaylistVarBool( "poiplayerspawning_spawnpointlootticks_enabled", true ))
}

string function PLV_SpawnPointLootTick_LootPool()
{
	return( GetCurrentPlaylistVarString( "poiplayerspawning_loottickloot", "white_kitted_weapons" ))
}

#if SERVER
void function Get_Spawnpoints_ForZone( int zoneID, int numPoints = 8, bool debug = false )
{
	// --- Populate file.spawnPoints_ByZoneID with possible spawn points for given zoneID.

	const float DEFAULTRADIUS 	= 11811		// 300 meters
	const int NUMPOINTS = 8

	entity zoneTrigger = MapZones_GetTriggerForZone( zoneID )
	if ( !IsValid( zoneTrigger ) )
		return

	//Choose a center around which to pick possible spawn points
	array< vector > centersArray
	if (( zoneID in file.crafterBasedZoneCenters_ByZoneID ) && ( file.crafterBasedZoneCenters_ByZoneID[ zoneID ].len() > 0 ))
	{
		if ( PLV_RandomSpawnPoints() )
		{

			centersArray.append( file.crafterBasedZoneCenters_ByZoneID[ zoneID ].getrandom() )
		}
		else
		{
			centersArray = file.crafterBasedZoneCenters_ByZoneID[ zoneID ]
		}
	}
	else
	{
		vector zoneCenter = zoneTrigger.GetCenter()
		zoneCenter = NavMesh_GetClosestPoint( zoneCenter )
		centersArray.append( zoneCenter )
	}

	foreach( ct in centersArray )
	{
		if ( !IsInStartRadius( ct ) )
		{
			centersArray.removebyvalue( ct )
		}
	}

	file.zoneCenters_ByZoneID[ zoneID ] <- centersArray

	vector mins  = zoneTrigger.GetBoundingMins()
	vector maxs  = zoneTrigger.GetBoundingMaxs()
	vector delta = (maxs - mins)

	//float calculatedRadius = min( delta.x, delta.y )
	float calculatedRadius = max( delta.x, delta.y )

	// Assign possible spawnpoints to each zoneID by picking around the given centers within a radius.
	foreach( center in centersArray )
	{
		Assign_Spawnpoints_FromLootLocs_ToZone( zoneID, center, calculatedRadius, numPoints, debug  )
	}
}
#endif // SERVER

#if SERVER
void function Assign_Spawnpoints_FromLootLocs_ToZone( int zoneID, vector center, float radius, int numPoints, bool debug = false )
{
	array< vector > candidateLocs

	const float CLEARING_X = POISPAWN_CLEARING_DISTANCE
	const float CLEARING_Y = POISPAWN_CLEARING_DISTANCE
	const float CLEARING_Z = POISPAWN_CLEARING_DISTANCE

	candidateLocs = VectorArrayWithin( file.allSpawnLocs_fromLootLocs, center, radius )
	foreach( vector candLoc in candidateLocs )
	{
		if ( !IsInStartRadius( candLoc ))
		{
			candidateLocs.removebyvalue( candLoc )
		}
	}

	int pointZoneID
	array< Point > usablePoints

	foreach( loc in candidateLocs )
	{
		vector locOnMesh = NavMesh_GetClosestPoint( loc )

		#if DEVELOPER
			DEVLine( debug, loc, locOnMesh, COLOR_PINK, true, POISPAWNING_DEBUGDRAWTIME )
			DEVCube( debug, locOnMesh, 50, COLOR_DARK_GRAY, true, POISPAWNING_DEBUGDRAWTIME )
		#endif // DEV

		// Test each point to see if it's part of the Zone and the sky is clear above it.
		vector facing = center - locOnMesh
		facing.z = 0
		vector facingAngles = VectorToAngles( facing )
		pointZoneID = MapZones_GetZoneForOrigin( locOnMesh )
		//bool verified = VerifyAirdropPoint( pos, facingAngles.y, false )
		bool verified = false//IsSkyAboveClear( locOnMesh )
		if ( ( pointZoneID == zoneID ) && verified )
		{
			Point newPoint
			newPoint.origin = locOnMesh
			newPoint.angles = facingAngles
			usablePoints.append( newPoint )

			// Remove used Loc from file.allSpawnLocs_fromLootLocs
			file.allSpawnLocs_fromLootLocs.fastremovebyvalue( loc )
		}
	}

	// Add usable points to zone's array.
	if ( !( zoneID in file.spawnPoints_ByZoneID ) )
	{
		file.spawnPoints_ByZoneID[ zoneID ] <- []
	}
	file.spawnPoints_ByZoneID[ zoneID ].extend( usablePoints )

	#if DEVELOPER
		if ( debug )
		{
			printt( format( "POISPAWNING: Zone ID %s usable points == %s.", string( zoneID ), string( usablePoints.len() ) ) )
			if ( usablePoints.len() > 0 )
			{
				DrawStar( center, 240, POISPAWNING_DEBUGDRAWTIME, true )
				DebugDrawText( center + < 0, 0, 50 >, string( zoneID ), true, POISPAWNING_DEBUGDRAWTIME )
			}
			foreach( pt in usablePoints )
			{
				DebugDrawLine( pt.origin, center, int(COLOR_ORANGE.x), int(COLOR_ORANGE.y), int(COLOR_ORANGE.z), true, POISPAWNING_DEBUGDRAWTIME )
				DEVCylinder( true, pt.origin, < -90, 0, 0 >, CLEARING_X, CLEARING_Z, COLOR_ORANGE, true, POISPAWNING_DEBUGDRAWTIME )
			}

		}
	#endif // DEV
}
#endif // SERVER

void function POIPlayerSpawning_Init()
{
	if ( !POIPlayerSpawning_Exists() )
		return

	PrecacheParticleSystem( GROUNDMARKER_FX_RING )
	PrecacheParticleSystem( GROUNDMARKER_FX_CENTER )
	PrecacheParticleSystem( GROUNDMARKER_FX_BEACON )

	#if SERVER
		AddSpawnCallbackEditorClass( "info_target", POISPAWNING_CURATED_SPAWNPOINT_CLASSNAME, OnCuratedSpawnpoint_Spawned )
	#endif // SERVER

	#if CLIENT
		Waypoints_RegisterCustomType( POISPAWN_SKYDIVEDESTWP_NAME, CL_POISpawn_LandingMarkers_Create )
	#endif

	Remote_RegisterClientFunction( "CL_POISpawn_LandingMarkers_Destroy" )
	Remote_RegisterClientFunction( "CL_EnemyPOI_Set_Wp_Size", "entity" )

	//Mind the 8-bit precision on the floats, might need a bump for future use cases
	Remote_RegisterClientFunction( "ServerToClient_CustomDropship_CameraZoom", "entity", "float", 0.0, 60.0, 8, "float", 0.0, 180.0, 8, "float", 0.0, 180.0, 8 )
		
	RegisterSignal( "POISpawn_TeamLanded" )
	RegisterSignal( "POISpawn_CustomDropship_CameraZoom" )
}

#if SERVER
void function POIPlayerSpawning_SpawnPlayers( bool debug = false )
{
	thread function () : ( debug )
	{
		// Start the death circle before we spawn the players because we wont know info about the circle until we set this flag
		FlagSet( "DeathFieldPaused" )
		FlagSet( "DeathCircleActive" )
		WaitFrame()

		FlagWait( "DoneCreatingDeathFieldPosition" )

		//	--- Get number of squads
		table< int, array<entity> > groupedPlayers = GetAllPlayersSortedByTeam()
		file.groupedPlayers = groupedPlayers

		//	--- Get Zone IDs list sorted in descending order by bounds size.
		array< int > zoneIDs_SortedByBounds = MapZones_GetAllZoneIDs_Sorted( true, true )
		file.zoneIDs_SortedByBounds = zoneIDs_SortedByBounds
		if ( zoneIDs_SortedByBounds.len() == 0 )
		{
			string errorStr = format( "%s(): POIPlayerSpawning- Zone IDs Sorted By Bounds is Empty", FUNC_NAME() )
			Warning( errorStr )
			return
		}

		// Get the start area info
		Register_StartRing()

		// - Get All curated spawn points into Zones.
		if ( PLV_UseCuratedSpawns() )
		{
			Register_CuratedSpawns( debug )
		}

		// Use loot-based spawns as a backup if there are no curated spawn points.
		if ( file.curatedSpawn_Ents_InStartRange.len() > 0 )
		{
			Spawn_All_Teams_Using_Curated_Spawns( true )
		}
		else
		{
			// - Populate file.allSpawnLocs_fromLootLocs with loot locations.
			Register_LootBased_SpawnPoints_IntoZones( debug )

			// --- Go through groupedPlayers team-by-team and assign them to their zones, using the larger zones first.
			Assign_TeamsToZones( debug )

			//	--- Spawn each squad in their respective zones.
			Spawn_All_Teams_ByZones( debug )
		}

		// wait for players to be on ground
		array<entity> players = GetPlayerArray()
		float timeout = 60 + Time()
		while( Time() < timeout )
		{
			entity playerNotOnGround = null
			foreach( entity player in players )
			{
				if ( IsValid( player ) && !player.p.survivalLandedOnGround )
				{
					playerNotOnGround = player
					break
				}
			}


			if ( IsValid( playerNotOnGround ) )
				WaitSignalTimeout( playerNotOnGround, 30.0, "PlayerBootsOnGround" )
			else
				break
		}

		// all players on ground, begin death field
		FlagClear( "DeathFieldPaused" )
	}()
}
#endif // SERVER

#if SERVER
void function Register_PlacedSpawnCenters( bool debug = false )
{
	// Grab all the placed Spawn Centers.
	// Notes:
	//		- Spawn Centers are locations around which possible spawn points may be chosen for a zone.
	//		- Placed spawn centers are actually duplicated off of crafting locations for reference.

	array< Point > placedLocsArray = Crafting_PossibleWorkbenchLocations_Get()
	foreach( placedLocPoint in placedLocsArray )
	{
		vector placedLoc = placedLocPoint.origin

		int zoneID = MapZones_GetZoneForOrigin( placedLoc )

		if ( !( zoneID in file.crafterBasedZoneCenters_ByZoneID ) )
		{
			file.crafterBasedZoneCenters_ByZoneID[ zoneID ] <- []
		}

		if ( IsInStartRadius( placedLoc ) )
		{
			file.crafterBasedZoneCenters_ByZoneID[ zoneID ].append( placedLoc )
		}
	}
}
#endif // SERVER

#if SERVER
void function Register_StartRing()
{
	DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData( Survival_Loot_GetDefaultRealm() )
	vector center                 = deathFieldData.center	// Start Area Center

	float radius_0 = GetCurrentPlaylistVarFloat( "deathfield_radius_0", -1 )
	float radius_Start = GetCurrentPlaylistVarFloat( "survival_death_field_start_radius", -1 )
	float radiusTuningOverride = GetRingTuningOverrideVar( "deathfield_radius_" + 0, -1.0 )
	float radiusGetStartRadius = SURVIVAL_Deathfield_GetStartRadius()
	float radiusToUse

	array< float > radiiSorted
	radiiSorted.append( radius_0 )
	radiiSorted.append( radius_Start )
	radiiSorted.append( radiusTuningOverride )
	radiiSorted.append( radiusGetStartRadius )
	radiiSorted.sort()

	// Get the biggest one available.
	radiusToUse = radiiSorted[ radiiSorted.len() - 1 ]

	if ( radiusToUse == -1 )
	{
		radiusToUse = POISPAWN_STARTRADIUS_DEFAULT
	}

	// Bring in radius checks by the constrained dive radius so that the spawn points don't allow players to dive outside of the ring.
	radiusToUse -= POISPAWN_CONSTRAINEDDIVE_2DRADIUS

	file.startMatch_Center = center
	file.startMatch_Radius = radiusToUse // currentRadius // was radius.

	#if DEVELOPER
		printt( format( "%s(): START RING center == %s", FUNC_NAME(), string( center ) ) )

		printt( format( "%s(): deathfield_radius_0 == %s", FUNC_NAME(), string( radius_0 ) ) )
		printt( format( "%s(): survival_death_field_start_radius == %s", FUNC_NAME(), string( radius_Start ) ) )
		printt( format( "%s(): radiusTuningOverride == %s", FUNC_NAME(), string( radiusTuningOverride ) ) )
		printt( format( "%s(): radiusGetStartRadius == %s", FUNC_NAME(), string( radiusGetStartRadius ) ) )

		printt( format( "%s(): START RING radiusToUse == %s", FUNC_NAME(), string( radiusToUse ) ) )

		//printt( format( "%s(): computed radius == %s", FUNC_NAME(), string( radius ) ) )
		//printt( format( "%s(): current radius == %s", FUNC_NAME(), string( currentRadius ) ) )
		//printt( format( "%s(): endRadius == %s", FUNC_NAME(), string( endRadius ) ) )
		DEV_DrawStartArea()
	#endif // DEV
}
#endif // SERVER

#if SERVER
void function OnCuratedSpawnpoint_Spawned( entity ent )
{
	// --- Warn about placed curated spawns that are too close to each other.
	float tooCloseDistanceSqr = pow( 1968.5, 2 ) // 50m squared.
	foreach( savedSpawn in file.curatedSpawn_Ents )
	{
		vector savedSpawnLoc = savedSpawn.GetOrigin()
		vector entLoc = ent.GetOrigin()
		if ( Distance2DSqr( savedSpawnLoc, entLoc ) <= tooCloseDistanceSqr )
		{
			file.curatedSpawn_Ents_TooClose.append( ent )
			string warningStr = format( "CURATED SPAWNS PLACEMENT WARNING: curated Spawns @ %s and %s are too close together.", string( entLoc ), string( savedSpawnLoc ))
			printt( warningStr )
			Warning( warningStr )
			#if DEVELOPER
				DebugDrawSphere( savedSpawnLoc, 64, int(COLOR_DARK_RED.x), int(COLOR_DARK_RED.y), int(COLOR_DARK_RED.z), true, 120 )
				DebugDrawSphere( entLoc, 64, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 120 )
			#endif
		}
	}
	file.curatedSpawn_Ents.append( ent )
}
#endif // SERVER

#if SERVER
void function Register_CuratedSpawns( bool debug = false )
{
	int count_curatedSpawnEnts = file.curatedSpawn_Ents.len()
	if ( count_curatedSpawnEnts == 0 )
	{
		file.curatedSpawn_Ents = GetEntArrayByScriptName( POISPAWNING_CURATED_SPAWNPOINT_SCRIPTNAME )
		#if DEVELOPER
			printt( format( "%s(): Getting file.curatedSpawn_Ents by Scriptname", FUNC_NAME() ) )
		#endif
	}

	count_curatedSpawnEnts				= file.curatedSpawn_Ents.len()
	#if DEVELOPER
		printt( format( "%s(): file.curatedSpawn_Ents.len() == %s", FUNC_NAME(), 	string( count_curatedSpawnEnts ) ) )
	#endif

	// Only consider spawns inside the start range.
	#if DEVELOPER
		printt( format( "%s(): ------ Curated Spawns outside of Start Circle. Center: %s, Radius: %s.",
			FUNC_NAME(),
			string( file.startMatch_Center ),
			string( file.startMatch_Radius ) ))
	#endif // DEV
	foreach( placedSpawn in file.curatedSpawn_Ents )
	{
		vector placedSpawnLoc = placedSpawn.GetOrigin()
		if ( IsInStartRadius( placedSpawnLoc ) )
		{
			file.curatedSpawn_Ents_InStartRange.append( placedSpawn )
		}
		else
		{
			#if DEVELOPER
				printt( format( "%s(): --- @ %s ", FUNC_NAME(), string( placedSpawnLoc )))
				DebugDrawSphere( placedSpawnLoc, 128, int(COLOR_PINK.x), int(COLOR_PINK.y), int(COLOR_PINK.z), true, 120 )
			#endif // DEV
		}
	}
	#if DEVELOPER
		printt( format( "%s(): ------ ", FUNC_NAME()))
	#endif // DEV

	int count_curatedSpawnEntsInRange		= file.curatedSpawn_Ents_InStartRange.len()
	#if DEVELOPER
		printt( format( "%s(): file.curatedSpawn_Ents_InStartRange.len() == %s", FUNC_NAME(), 	string( count_curatedSpawnEntsInRange ) ) )
	#endif

	foreach( placedEnt in file.curatedSpawn_Ents_InStartRange )
	{
		// save each placedEnt in its appropriate array, whether WithLink or WithoutLink.
		entity linkedSpawn = placedEnt.GetLinkEnt()
		if ( IsValid( linkedSpawn ) )
		{
			bool linkedSpawnIsInStartRange = IsInStartRadius( linkedSpawn.GetOrigin() )
			bool linkAlreadySeen = file.curatedSpawn_Ents_WithLinks.contains( placedEnt )
			if ( linkedSpawnIsInStartRange && !linkAlreadySeen )  
			{
				file.curatedSpawn_Ents_WithLinks.append( placedEnt )

				if ( !(placedEnt in file.curatedSpawn_Map_LinkedEnts) )
				{
					file.curatedSpawn_Map_LinkedEnts[placedEnt] <- linkedSpawn
					if ( !(linkedSpawn in file.curatedSpawn_Map_LinkedEnts) )
						file.curatedSpawn_Map_LinkedEnts[linkedSpawn] <- placedEnt
				}

				#if DEVELOPER
					DEVLine( debug, placedEnt.GetOrigin(), linkedSpawn.GetOrigin(), COLOR_LIGHT_GREEN, true, 60 )
					DEVSphere( debug, linkedSpawn.GetOrigin(), 300, COLOR_LIGHT_GREEN, true, 60 )

				#endif
			}
			else 
			{
				if ( !linkedSpawnIsInStartRange )
				{
					file.curatedSpawn_Ents_WithoutLinks.append( placedEnt )
					printt( format( "%s(): Curated Spawn @ %s links to a spawn outside of start radius. Has no link then.", FUNC_NAME(), string( linkedSpawn.GetOrigin() ) ) )
					#if DEVELOPER
						DEVLine( debug, placedEnt.GetOrigin(), linkedSpawn.GetOrigin(), COLOR_RED, true, 60 )
						DEVSphere( debug, linkedSpawn.GetOrigin(), 300, COLOR_RED, true, 60 )
					#endif
				}
				else if ( linkAlreadySeen )
				{
					printt( format( "%s(): Repeat Link @ %s found and discarded", FUNC_NAME(), string( linkedSpawn.GetOrigin() ) ) )
				}
			}
		}
		else
		{
			file.curatedSpawn_Ents_WithoutLinks.append( placedEnt )
			printt( format( "%s(): Curated Spawn with no link @ %s found", FUNC_NAME(), string( placedEnt.GetOrigin() ) ) )
		}
	}
	#if DEVELOPER
		printt( format( "%s(): Curated SpawnEnts WITH Linkeds found == %s", FUNC_NAME(), string( file.curatedSpawn_Ents_WithLinks.len() ) ) )
		printt( format( "%s(): Curated SpawnEnts WITHOUT Linkeds found == %s", FUNC_NAME(), string( file.curatedSpawn_Ents_WithoutLinks.len() ) ) )
	#endif // DEV
}
#endif // SERVER

#if SERVER
void function Register_LootBased_SpawnPoints_IntoZones( bool debug = false )
{
	// - Get All the placed spawn centers duped off of placed crafter locs.
	Register_PlacedSpawnCenters( debug )

	vector center = file.startMatch_Center
	float radius = file.startMatch_Radius

	// Grab all loot points as spawn points, and assign them to the zones in which they reside.
	// --- Loot-points-based.
	table< string, array<BinOrSpawnPoint> > groupedLootSpawnPoints = SURVIVAL_GetGroupLootSpawnLocations()
	//array<vector> lootPoints = VectorArrayWithin( SURVIVAL_GetAllLootLocationsCopy(), center, radius )
	array< vector > lootLocsRaw
	foreach( string name, array< BinOrSpawnPoint > binSpawnArray in groupedLootSpawnPoints )
	{
		foreach( binSpawn in binSpawnArray )
		{
			lootLocsRaw.append( binSpawn.pos )
		}
	}
	array<vector> lootPoints = VectorArrayWithin( lootLocsRaw, center, radius )
	array<vector> lootPointsSorted = ArrayFarthestVector( lootPoints, center )

	int numPointsToGet = file.zoneIDs_SortedByBounds.len() * POISPAWN_MAX_SPAWNPOINTS_PER_ZONE
	file.allSpawnLocs_fromLootLocs = GetRandomPointsFromList( lootPointsSorted, center, radius, numPointsToGet, PLV_SquadsMinDistance()  )

	#if DEVELOPER
		printt( format( "%s(): POISpawning: Loot-based spawn points count BEFORE checking against curated spawns = %s", FUNC_NAME(), string( file.allSpawnLocs_fromLootLocs.len() ) ) )
		if ( debug )
		{
			printt( format( "POISPAWNING: Pre-Operation file.allSpawnLocs_fromLootLocs.len() == %s", string ( file.allSpawnLocs_fromLootLocs.len() ) ) )
		}
	#endif // DEV

	// ---- Remove loot-based Spawns that are too close to curated Spawns.
	foreach( loc in file.allSpawnLocs_fromLootLocs )
	{
		if ( !IsFarEnoughFromCuratedSpawns( loc ) )
		{
			file.allSpawnLocs_fromLootLocs.removebyvalue( loc )
		}
	}

	#if DEVELOPER
		printt( format( "%s(): POISpawning: Loot-based spawn points count AFTER checking against curated spawns = %s", FUNC_NAME(), string( file.allSpawnLocs_fromLootLocs.len() ) ) )
	#endif // DEV

	// --- Populate file.spawnPoints_ByZoneID for each zoneID.
	foreach( zoneID in file.zoneIDs_SortedByBounds )
	{
		int numPoints = 8
		Get_Spawnpoints_ForZone( zoneID, numPoints, debug )
	}

	#if DEVELOPER
		if ( debug )
		{
			printt( format( "*** POISPAWNING: lootPointsSorted.len() == %s", string ( lootPointsSorted.len() ) ) )
			printt( format( "POISPAWNING: Post-Operation file.allSpawnLocs_fromLootLocs.len() == %s", string ( file.allSpawnLocs_fromLootLocs.len() ) ) )

			int zonesWithSpawnPoints = 0
			int spawnPointCount = 0
			foreach( int zoneID, array< Point > spawnPts in file.spawnPoints_ByZoneID )
			{
				int count = spawnPts.len()
				if ( count > 0 )
				{
					zonesWithSpawnPoints++
					spawnPointCount += count
				}
			}
			printt( format( "POISPAWNING: TOTAL Zones With Spawn Points == %s", string( zonesWithSpawnPoints ) ))
			printt( format( "POISPAWNING: TOTAL Usable Spawn Points == %s", string( spawnPointCount ) ))
		}
	#endif // DEV
}
#endif // SERVER

#if SERVER
bool function IsFarEnoughFromCuratedSpawns( vector loc )
{
	// Check distance to curated spawn points.
	if ( file.curatedSpawn_Locs_InStartRange.len() > 0 )
	{
		float minDist_To_Curated_Spawns = PLV_SquadsMinDistance()
		bool isOk = !IsPointWithinDistanceFromAnotherPoint( loc, file.curatedSpawn_Locs_InStartRange, minDist_To_Curated_Spawns )
		return isOk
	}
	return true
}
#endif // SERVER

#if SERVER
bool function IsInStartRadius( vector loc )
{
	float dist2DSqr = Distance2DSqr( loc, file.startMatch_Center )
	float threshold2DSqr = file.startMatch_Radius * file.startMatch_Radius
	return ( dist2DSqr <= threshold2DSqr )
}
#endif // SERVER

#if SERVER
void function Assign_TeamsToZones( bool debug = false )
{
	// 	--- Go through groupedPlayers team-by-team and assign them to their zones, using the larger zones first.
	int numSquads = file.groupedPlayers.len()
	int teamsPerZone = PLV_TeamsPerGroup()
	table< int, array< int > > spawnTeams_ToZoneIDs = file.teams_Assigned_ToZoneIDs
	int zoneIDsLength = file.zoneIDs_SortedByBounds.len()

	array< int > zoneIDs_With_Enough_SpawnPoints
	array< int > zoneIDs_Used_With_Multiple_Teams
	array< int > zoneIDs_With_1_SpawnPoint
	foreach( zoneID, array< Point > spawnPoints in file.spawnPoints_ByZoneID )
	{
		int spawnPointCount = spawnPoints.len()

		if ( spawnPointCount >= teamsPerZone )
		{
			zoneIDs_With_Enough_SpawnPoints.append( zoneID )
		}
		else if ( spawnPointCount == 1 )
		{
			zoneIDs_With_1_SpawnPoint.append( zoneID )
		}
	}

	TeamType_AnalyzeTeams()
	array< int > teamsArray = file.teamsToSpawn
	
	#if DEVELOPER
		if ( debug )
		{
			printt( "*** POIPlayerSpawning: Zones with 2 or more SpawnPoints: " + zoneIDs_With_Enough_SpawnPoints.len() )
			foreach( zID in zoneIDs_With_Enough_SpawnPoints )
			{
				printt( "POIPlayerSpawning: --- zoneID == " + zID )
			}

			printt( "*** POIPlayerSpawning: Zones with 1 SpawnPoint:" + zoneIDs_With_1_SpawnPoint.len() )
			foreach( zID in zoneIDs_With_1_SpawnPoint )
			{
				printt( "POIPlayerSpawning: --- zoneID == " + zID )
			}

			printt( "*** POIPlayerSpawning: NumSquads == " + teamsArray.len() )
			foreach( team in teamsArray )
			{
				printt( "POIPlayerSpawning: --- team == " + team )
			}
		}
	#endif

	// teamsPerZone teams are assigned to each zone that can accomodate them.

	int currentZoneID
	int currentTeam
	bool assignSuccess
	while(( teamsArray.len() > 0 ) && ( zoneIDs_With_Enough_SpawnPoints.len() > 0 ))
	{
		currentZoneID = zoneIDs_With_Enough_SpawnPoints[ 0 ]

		currentTeam = teamsArray[ 0 ]

		assignSuccess = Try_Assign_TeamToZone( currentTeam, currentZoneID, debug )
		if ( assignSuccess )
		{
			// The Team at the front of the line is assigned. Remove it.
			teamsArray.remove( 0 )
		}
		else
		{
			// The zone is full, either at capacity or spawnpoint count == number of teams assigned to it. Remove it.
			zoneIDs_With_Enough_SpawnPoints.remove( 0 )
		}
	}

	// if no more teams to assigned, we're done.
	if ( teamsArray.len() == 0 )
		return

	// Assign any remaining teams to available zones.
	array< int > remaining_Available_Zones
	remaining_Available_Zones.extend( zoneIDs_With_Enough_SpawnPoints )
	remaining_Available_Zones.extend( zoneIDs_With_1_SpawnPoint )

	while(( teamsArray.len() > 0 ) && ( remaining_Available_Zones.len() > 0 ))
	{
		currentZoneID = remaining_Available_Zones[ 0 ]
		currentTeam = teamsArray[ 0 ]

		assignSuccess = Try_Assign_TeamToZone( currentTeam, currentZoneID, debug )
		if ( assignSuccess )
		{
			// Advance to the next team in the list.
			teamsArray.remove( 0 )
		}

		// Whether the zone is full or has been assigned, we need to move on to the next zone.
		remaining_Available_Zones.remove( 0 )
	}

	// If there are teams left unassigned, show an error.
	int teamsLeft = teamsArray.len()
	if ( teamsLeft > 0 )
	{
		printt( "*** POISPAWNING: Teams left unassigned!!!" )

		printt( format( " - POISPAWNING: Total unassigned teams == %s" , string ( teamsLeft ) ))
		foreach( team in teamsArray )
		{
			printt( format( " - POISPAWNING: --- Zone %s was not assigned.", string( team ) ))
		}
		Assert( teamsLeft > 0, "POISPAWNING Team Assignment Error- Teams Left Unassigned!!!" )
	}
}
#endif // SERVER

// --- Team Type Stuff

#if SERVER
void function TeamType_AnalyzeTeams()
{
	for( int i = 0; i < eTurboBRTeamType.COUNT_; i++ )
	{
		file.teamsToSpawn_ByType[ i ] <- [] // Ensure all types are at least initialized.
	}

	foreach( team, array< entity > players in file.groupedPlayers )
	{
		TeamType_Record( team )
	}

	#if DEVELOPER
		for( int i = 0; i < eTurboBRTeamType.COUNT_; i++ )
		{
			printt( format( "%s: %s Teams Count == %s ", FUNC_NAME(), GetEnumString( "eTurboBRTeamType", i ), string( file.teamsToSpawn_ByType[ i ].len() ) ) )
		}
	#endif

	// Construct the teamsToSpawn main array.
	for( int type = 0; type < eTurboBRTeamType.COUNT_; type++  )
	{
		file.teamsToSpawn.extend( file.teamsToSpawn_ByType[ type ] )
	}

	#if DEVELOPER
		printt( format( "%s(): file.teamsToSpawn.len() == ", FUNC_NAME(), string( file.teamsToSpawn.len() ) ) )
	#endif
}
#endif // SERVER

#if SERVER
void function TeamType_Record( int team )
{
	array< entity > teamPlayers = file.groupedPlayers[ team ]
	int validPlayersCount = 0
	int botCount = 0
	foreach( player in teamPlayers )
	{
		if ( IsValid( player ) )
		{
			validPlayersCount++
			if ( player.IsBot() )
			{
				botCount++
			}
		}
	}

	int teamType
	if ( botCount == validPlayersCount  )
	{
		teamType = eTurboBRTeamType.BOTS 
	}
	else if ( botCount > 0 ) // Mixed... which kind?
	{
		teamType = IsTeamForBotPairing( teamPlayers ) ? eTurboBRTeamType.LOWERMMR : eTurboBRTeamType.MIXED
	}
	else // Human... which kind?
	{
		teamType = IsTeamForBotPairing( teamPlayers ) ? eTurboBRTeamType.LOWERMMR : eTurboBRTeamType.HUMAN
	}

	TeamType_Push( teamType, team )
}
#endif // SERVER

#if SERVER
void function TeamType_Push( int teamType, int team )
{
	if (( teamType < 0 ) || ( teamType > eTurboBRTeamType.COUNT_ ))
		return

	file.teamsToSpawn_ByType[ teamType ].append( team )

	file.teamType[ team ] <- teamType
}

int function TeamType_Get( int team )
{
	if ( !( team in file.teamType ) )
		return eTurboBRTeamType.INVALID

	return( file.teamType[ team ] )
}
#endif // SERVER

#if SERVER

// Utility function that pulls from first team type of non-zero length based on given search order.
int function PullTeam_From_SearchOrder( array< int > searchOrder )
{
	Assert( searchOrder.len() == eTurboBRTeamType.COUNT_, "searchOrder by teamType appears to be missing some teamTypes, did a new type get added without updating searchOrder?" )

	int result = TEAM_INVALID

	foreach( searchType in searchOrder )
	{
		if ( file.teamsToSpawn_ByType[ searchType ].len() > 0 )
		{
			result = file.teamsToSpawn_ByType[ searchType ][ 0 ]
			break
		}
	}

	if ( result != TEAM_INVALID )
	{
		TeamToSpawn_Remove( result )
	}
	return result
}

// For 1st team of pair in Curated Spawns. Removes and returns the next team.
// Order: LowerMMR, Human, Mixed, Bots.
int function TeamToSpawn_Pull_Next()
{
	array< int > searchOrder = [ eTurboBRTeamType.LOWERMMR, eTurboBRTeamType.HUMAN, eTurboBRTeamType.MIXED, eTurboBRTeamType.BOTS ]
	int result = PullTeam_From_SearchOrder( searchOrder )
	#if DEVELOPER
		int teamType = TeamType_Get( result )
		printt( format( "%s(): Next Team Pulled: %s of type %s", FUNC_NAME(), string( result ), GetEnumString( "eTurboBRTeamType", teamType )))
	#endif
	return result
}

// For subsequent teams in Curated Spawns: Removes and returns a team to match with the given team
int function TeamToSpawn_Pull_ToMatch( int givenTeam )
{
	int givenTeamType = TeamType_Get( givenTeam )
	
	if ( givenTeamType == eTurboBRTeamType.INVALID )
		return TEAM_INVALID

	int result = TEAM_INVALID
	switch ( givenTeamType )
	{
		case eTurboBRTeamType.LOWERMMR:
			result = TeamToSpawn_Pull_ToMatch_LowerMMR()
			break
		case eTurboBRTeamType.HUMAN:
			result = TeamToSpawn_Pull_ToMatch_Human()
			break
		case eTurboBRTeamType.MIXED:
			result = TeamToSpawn_Pull_ToMatch_Mixed()
			break
		case eTurboBRTeamType.BOTS:
			result = TeamToSpawn_Pull_ToMatch_Bots()
			break
		default:
			string warnStr = format( "%s(): UNKNOWN Team Type %s given.", FUNC_NAME(), string( givenTeamType ) )
			Warning( warnStr )
			break
	}

	if ( result != TEAM_INVALID )
	{
		#if DEVELOPER
			givenTeamType = TeamType_Get( givenTeam )
			int resultTeamType = TeamType_Get( result )
			printt( format( "%s(): Team %s of type %s Matched With Team %s of type %s", FUNC_NAME(), string( givenTeam ), GetEnumString( "eTurboBRTeamType", givenTeamType ), string( result ), GetEnumString( "eTurboBRTeamType", resultTeamType ) ) )
		#endif
	}

	return result
}

// 	If the team is Lower MMR, remove and return matching team.
//	Order: Bot, LowerMMR, Mixed, Human.
int function TeamToSpawn_Pull_ToMatch_LowerMMR()
{
	array< int > searchOrder = [ eTurboBRTeamType.BOTS, eTurboBRTeamType.LOWERMMR, eTurboBRTeamType.MIXED, eTurboBRTeamType.HUMAN ]
	int result = PullTeam_From_SearchOrder( searchOrder )
	return result
}

// 	If the team is Human, remove and return matching team.
//	Order: Bot, Human, Mixed, LowerMMR.
int function TeamToSpawn_Pull_ToMatch_Human()
{
	array< int > searchOrder = [ eTurboBRTeamType.BOTS, eTurboBRTeamType.HUMAN, eTurboBRTeamType.MIXED, eTurboBRTeamType.LOWERMMR ]
	int result = PullTeam_From_SearchOrder( searchOrder )
	return result
}

// 	If the team is Mixed, remove and return matching team.
//	Order: Bot, LowerMMR, Mixed, Human.
int function TeamToSpawn_Pull_ToMatch_Mixed()
{
	array< int > searchOrder = [ eTurboBRTeamType.BOTS, eTurboBRTeamType.LOWERMMR, eTurboBRTeamType.MIXED, eTurboBRTeamType.HUMAN ]
	int result = PullTeam_From_SearchOrder( searchOrder )
	return result
}

// 	If the team is Bots, remove and return matching team.
//	Order: LowerMMR, Mixed, Human, Bots.
int function TeamToSpawn_Pull_ToMatch_Bots()
{
	array< int > searchOrder = [ eTurboBRTeamType.LOWERMMR, eTurboBRTeamType.MIXED, eTurboBRTeamType.HUMAN, eTurboBRTeamType.BOTS ]
	int result = PullTeam_From_SearchOrder( searchOrder )
	return result
}

// Remove the team from the file.teamsToSpawn and file.teamsToSpawn_ByType arrays
void function TeamToSpawn_Remove( int team )
{
	if ( file.teamsToSpawn.contains( team ) )
	{
		file.teamsToSpawn.removebyvalue( team )
	}

	int teamType = TeamType_Get( team )
	if ( file.teamsToSpawn_ByType[ teamType ].contains( team ) )
	{
		file.teamsToSpawn_ByType[ teamType ].removebyvalue( team )
	}

	TeamCounts_Verify()
}

int function TeamsToSpawn_Count()
{
	TeamCounts_Verify()

	int countTeamsToSpawn = file.teamsToSpawn.len()
	return countTeamsToSpawn
}

void function TeamCounts_Verify()
{
	#if ASSERTS
		int countByType
		for( int i = 0; i < eTurboBRTeamType.COUNT_; i++ )
		{
			countByType += file.teamsToSpawn_ByType[ i ].len()
		}

		string errorMsg = format( "%s(): file.teamsToSpawn_ByType count of %s and file.teamsToSpawn.len() == %s are out of sync.", FUNC_NAME(), string( countByType ), string( file.teamsToSpawn.len() ) )
		Assert( file.teamsToSpawn.len() == countByType, errorMsg  )
	#endif // ASSERTS
}

#endif // SERVER

#if SERVER
bool function IsTeamForBotPairing( array< entity > teamPlayers, bool debugForceTrue = false )
{
	bool result = false
	foreach( player in teamPlayers )
	{
		if ( !IsValidPlayer( player ) )
			continue

		if ( player.IsBot() )
			continue

		bool isLowerMMR = IsPlayerOnTeamWithBotPairing( player )
		result = result || isLowerMMR

		#if DEVELOPER
			if( isLowerMMR )
			{
				// TODO: Output member data of interest
				string playerName = player.GetPlayerName()
				string playerID = ""//player.GetPINNucleusPid()
				string uid = ""//player.GetUserID()

				printt( format( "%s(): ----- Low-Damage Player Detected:", FUNC_NAME() ) )
				printt( format( "%s(): Player Name: 		%s", FUNC_NAME(), playerName ) )
				printt( format( "%s(): Player Nucleus ID: 	%s", FUNC_NAME(), playerID ) )
				printt( format( "%s(): Player User ID: 		%s", FUNC_NAME(), uid ) )
				printt( format( "%s(): ----- ", FUNC_NAME() ) )
			}

			// DEV_POISpawn_MMR_Zero() can be used to test the flow of low-MMR Bot Matching Priority.
			// SetPlayerMMR() cannot change the index 6 of the MMR array, unfortunately.
			// I've written a dev workaround to allow the lower MMR logic to go through if file.playerMMRs[ player ][ 0 ] == 0 in dev.
			if ( debugForceTrue )
			{
				result = true
			}
		#endif // DEV
	}
	return result
}
#endif // SERVER

// --- 

#if SERVER
bool function Try_Assign_TeamToZone( int team, int zoneID, bool debug = false )
{
	if ( !( zoneID in file.teams_Assigned_ToZoneIDs ) )
	{
		file.teams_Assigned_ToZoneIDs[ zoneID ] <- []
	}
	
	if ( Zone_Has_Room_For_More_Teams( zoneID ) && ( Zone_Has_Remaining_SpawnPoints( zoneID )))
	{
		if ( !file.teams_Assigned_ToZoneIDs[ zoneID ].contains( team )  )
		{
			file.teams_Assigned_ToZoneIDs[ zoneID ].append( team )
		}
		#if DEVELOPER
			file.zoneIDs_ByTeam[ team ] <- zoneID
			if ( debug )
			{
				printt( format( "POISPAWNING: team %s assigned to Zone %s", string( team ), string( zoneID ) ) )
			}
		#endif // DEV
		return true
	}
	return false
}

bool function Zone_Has_Room_For_More_Teams( int zoneID )
{
	int teamsAllowedPerZone = PLV_TeamsPerGroup()
	int numTeamsAssignedToZone 	= file.teams_Assigned_ToZoneIDs[ zoneID ].len()

	return( numTeamsAssignedToZone < teamsAllowedPerZone )
}

bool function Zone_Has_Remaining_SpawnPoints( int zoneID )
{
	int numSpawnPointsInZone 	= file.spawnPoints_ByZoneID[ zoneID ].len()
	int numTeamsAssignedToZone 	= file.teams_Assigned_ToZoneIDs[ zoneID ].len()
	
	return( numSpawnPointsInZone > numTeamsAssignedToZone )
}

#endif // SERVER

#if SERVER
void function Spawn_All_Teams_ByZones( bool debug = false )
{
	table< int, array< int > > spawnTeams_ToZoneIDs = file.teams_Assigned_ToZoneIDs
	foreach( int zoneID, array< int > teamsArray in spawnTeams_ToZoneIDs )
	{
		Spawn_Zone_Teams( zoneID, teamsArray, debug )
	}
}

// ----- New version!

void function Spawn_All_Teams_Using_Curated_Spawns( bool debug = false )
{
	// 1. Get array of teams.
	// 2. Get array of curated spawns with links. ( Non-repeat )
	// 3. Get array of curated spawns with no links.
	// 4. Assign teams in sets of TeamsPerGroup using linked spawns. If we run out of linked spawns, then use unlinked spawns.
	
	// 1. Get array of teams
	TeamType_AnalyzeTeams()
	array< int > teamsLeftToSpawn = file.teamsToSpawn

	// 2. Get array of curated spawns with links. Discard repeat ( loop ) links.
	array< entity > curatedSpawnEnts_Linked = []
	if ( PLV_RandomSpawnPoints() )
	{
		file.curatedSpawn_Ents_WithLinks.randomize()
	}
	foreach( ent in file.curatedSpawn_Ents_WithLinks )
	{
		if ( !( curatedSpawnEnts_Linked.contains( ent ) ))
		{
			curatedSpawnEnts_Linked.append( ent )

			// Follow and save all its subsequent links until no more links or a repeat (loop) is encountered.
			entity linkEnt = ent.GetLinkEnt()
			while( IsValid( linkEnt ) && !( curatedSpawnEnts_Linked.contains( linkEnt ) ))
			{
				curatedSpawnEnts_Linked.append( linkEnt )
				linkEnt = linkEnt.GetLinkEnt()
			}
		}
	}

	// 3. Get array of curated spawns without links
	array< entity > curatedSpawnEnts_Unlinked
	if ( PLV_RandomSpawnPoints() )
	{
		file.curatedSpawn_Ents_WithoutLinks.randomize()
	}
	foreach( ent in file.curatedSpawn_Ents_WithoutLinks )
	{
		curatedSpawnEnts_Unlinked.append( ent )
	}

	// 4. Assign teams to curated spawns, first using linked spawns then using unlinked spawns.
	while( TeamsToSpawn_Count() > 0 )
	{
		int numTeamsLeftToSpawnForGroup = PLV_TeamsPerGroup()

		// Get first team.
		int team = TeamToSpawn_Pull_Next()

		entity spawnEnt
		if ( curatedSpawnEnts_Linked.len() > 0 )
		{
			spawnEnt = curatedSpawnEnts_Linked[ 0 ]
			curatedSpawnEnts_Linked.remove( 0 )
			Spawn_Team_At_SpawnEnt( team, spawnEnt, debug )
			numTeamsLeftToSpawnForGroup--

			// --- Follow links for rest of teams in group.
			// Get the next linked spawn
			spawnEnt = spawnEnt.GetLinkEnt()
			while( ( numTeamsLeftToSpawnForGroup > 0 ) && ( TeamsToSpawn_Count() > 0 )  &&  IsValid( spawnEnt ) && ( curatedSpawnEnts_Linked.contains( spawnEnt ) ) )
			{
				int lastTeamSpawned = team
				// Get the next team from the back of the array.
				team = TeamToSpawn_Pull_ToMatch( lastTeamSpawned )

				// Spawn the team at the spawnEnt.
				curatedSpawnEnts_Linked.removebyvalue( spawnEnt )
				Spawn_Team_At_SpawnEnt( team, spawnEnt, debug )
				numTeamsLeftToSpawnForGroup--

				// Get the next linked spawn.
				spawnEnt = spawnEnt.GetLinkEnt()
			}
		}
		else if ( curatedSpawnEnts_Unlinked.len() > 0 )
		{
			spawnEnt = curatedSpawnEnts_Unlinked[ 0 ]
			curatedSpawnEnts_Unlinked.remove( 0 )
			Spawn_Team_At_SpawnEnt( team, spawnEnt, debug )
		}
		else
		{
			string errMsg = format( "%s(): ERROR: RAN OUT OF CURATED SPAWN POINTS TO SPAWN TEAMS. %s teams unspawned.", FUNC_NAME(), string( TeamsToSpawn_Count() ) )
			errMsg = errMsg + format( "\n%s(): TO FIX: increase start radius, and/or ensure there are enough points within the start range. ", FUNC_NAME() )
			Assert( false, errMsg )
		}
	}
}
#endif // SERVER

#if SERVER
void function Spawn_Zone_Teams( int zoneID, array< int > teamsArray, bool debug = false )
{
	array< int > teamsLeftToSpawn
	foreach( team in teamsArray )
	{
		teamsLeftToSpawn.append( team )
	}
	
	array< Point > zoneSpawnPointsLeft
	foreach( Point pt in file.spawnPoints_ByZoneID[ zoneID ] )
	{
		zoneSpawnPointsLeft.append( pt )
	}

	#if DEVELOPER
		printt( format( "%s(): zone ID %s Spawn Point Count == %s ( Includes Curated and Loot ).", FUNC_NAME(), string( zoneID ), string( zoneSpawnPointsLeft.len() )) )
	#endif

	if ( PLV_RandomSpawnPoints() )
	{
		zoneSpawnPointsLeft.randomize()
	}

	while( teamsLeftToSpawn.len() > 0 )
	{
		int team = teamsLeftToSpawn[ 0 ]
		teamsLeftToSpawn.remove( 0 )
		Point spawnPoint = zoneSpawnPointsLeft[ 0 ]
		zoneSpawnPointsLeft.remove( 0 )
		
		Spawn_Team_At_SpawnPoint( team, spawnPoint )
	}
}
#endif // SERVER

#if SERVER
void function Spawn_Team_At_SpawnEnt( int team, entity spawnEnt, bool debug = false )
{
	// Check for duplicate spawnEnt usage.
	if ( file.curatedSpawn_Ents_Used.contains( spawnEnt ) )
	{
		string repeatSpawnUsedError = format( "%s(): Repeat SpawnEnt %s @ @s used!", FUNC_NAME(), string( spawnEnt ), string( spawnEnt.GetOrigin() ) )
		Warning( repeatSpawnUsedError )
	}
	else
	{
		file.curatedSpawn_Ents_Used.append( spawnEnt )
	}

	Point spawnPt = GetPointFromEnt( spawnEnt )

	// PINGING LINKED SPAWNENT TEAMS: Store each team with its chosen spawnEnt.
	file.spawnEnt_For_Team[ team ] <- spawnEnt
	file.team_At_SpawnEnt [ spawnEnt ] <- team
	file.allTeams_Spawned_At_CuratedSpawns.append( team )

	Spawn_Team_At_SpawnPoint( team, spawnPt, debug )
	#if DEVELOPER
		DEVPrint( true, format( "%s(): Team %s spawning @ %s, a curated Spawn", FUNC_NAME(), string( team ), string( spawnPt.origin ) ) )
	#endif // DEV
}

void function Spawn_Team_At_SpawnPoint(  int team, Point spawnPoint, bool debug = false )
{
	thread function() : ( team, spawnPoint, debug )
	{
		vector spawnLoc = spawnPoint.origin
		file.spawnLoc_Used_ByTeam[ team ] <- spawnLoc
		file.spawnLocsUsed_All.append( spawnLoc )

		#if DEVELOPER
			DEVPrint( true, format( "%s(): Team %s spawning @ %s", FUNC_NAME(), string( team ), string( spawnLoc ) ) )
		#endif // DEV

		if ( PLV_Airdrop() )
		{
			Spawn_Team_FromSky( team, spawnPoint )
		}
		else
		{
			Spawn_Team_OnGround( team, spawnPoint )
		}
	}()
}
#endif // SERVER

#if SERVER
void function Spawn_Team_OnGround( int team, Point spawnPoint )
{
	array< entity > playersArray = file.groupedPlayers[ team ]

	float spawnOffsetZ = POISPAWN_GROUNDSPAWNHEIGHT
	vector spawnCenterAdjusted = spawnPoint.origin + < 0, 0, spawnOffsetZ >

	int numPlayers = playersArray.len()
	array< vector > spawnLocsArray = GetPointsOnCircle( spawnCenterAdjusted, spawnPoint.angles, POISPAWN_GROUPRADIUS, numPlayers  )

	int spawnPointNDX = 0

	foreach( player in playersArray )
	{
		if ( !IsValidPlayer( player ) )
			continue

		vector spawnLoc = spawnLocsArray[ spawnPointNDX ]
		spawnPointNDX++

		player.SetOrigin( spawnLoc )
		vector angles = VectorToAngles( spawnCenterAdjusted - spawnLoc )
		player.SetAbsAngles( angles )

		ClearPlayerIntroDropSettings( player )
		bool giveRandomLoot = GetCurrentPlaylistVarInt( "survival_squad_spawn_with_random_loot", 0 ) == 1
		if ( giveRandomLoot )
		{
			GiveRandomStartingLoot( player )
		}
	}
}
#endif // SERVER

#if SERVER
entity function Get_JumpLeader( array< entity > playersArray )
{
	// Jump Leader is either party leader or last player in the array.
	entity jumpLeader
	foreach( player in playersArray )
	{
		if ( !IsValidPlayer( player ) )
			continue

		jumpLeader = player
		//if ( player.IsPartyLeader() )
		{
		//	break
		}
	}
	return jumpLeader
}
#endif // SERVER

#if SERVER
void function Spawn_Team_FromSky( int team, Point spawnPoint )
{
	thread function() : ( team, spawnPoint )
	{
		Point destination
		destination.origin = spawnPoint.origin
		destination.angles = spawnPoint.angles

		// Find the Party Leader.
		array< entity > playersArray = file.groupedPlayers[ team ]
		entity jumpLeader = Get_JumpLeader( playersArray )
		
		// Put the PartyLeader at the front of the playersArray.
		playersArray.removebyvalue( jumpLeader )
		playersArray.insert( 0, jumpLeader )

		if ( PLV_DropShipJump() )
		{
			vector skydiveStart = destination.origin + < 0, 0, PLV_Airdrop_Height() >

			LandingMarker_Create( team, destination )
			LootTick_SpawnAtSpawnPoint( destination )
			PrepareJump( team, destination )

			// Custom Dropship spawn sequence so we can control more of it.
			if ( PLV_CustomDropship() )
			{
				thread CustomDropShip_SpawnPlayers_AtPoint( spawnPoint, team )
			}
			else
			{
				thread RespawnPlayersInDropshipAtPoint( playersArray, skydiveStart, destination.angles, true, true )
			}
		}
		else
		{
			foreach( player in playersArray )
			{
				player.ClearParent()
				thread Skydive_Player_Thread( player, playersArray, jumpLeader, destination )
			}
		}

		if ( GetCurrentPlaylistVarBool( "is_limited_mode", false ) )
		{
			foreach( player in playersArray )
			{
				LTM_AnnouncementSplash(player)
			}
		}

	}()
	// ---
}

void function LootTick_SpawnAtSpawnPoint( Point destination, bool debug = false )
{
	if ( !PLV_SpawnPointLootTicks_Enabled() )
		return
	
	string lootPool = PLV_SpawnPointLootTick_LootPool()
	array< string > weaponRefs_All = SURVIVAL_GetAllRefsInLootGroup( lootPool )

	int numGuns = 4
	array< string > gunsToSpawn
	for( int i = 0; i < numGuns; i++ )
	{
		gunsToSpawn.append( weaponRefs_All.getrandom() )
	}
	vector destElevated = destination.origin + < 0,0,5000 >
	vector groundLoc = OriginToGround( destElevated )
	LootTicks_SpawnLootTickAtOrigin( groundLoc, destination.angles, gunsToSpawn, 1 )
	#if DEVELOPER
		if ( debug )
		{
			DebugDrawCube( groundLoc, 64, int( COLOR_CYAN.x ), int( COLOR_CYAN.y ), int( COLOR_CYAN.z ), true, 90 )
		}
	#endif
}

void function PrepareJump( int team, Point destination )
{
	array< entity > playersArray = file.groupedPlayers[ team ]

	foreach( player in playersArray )
	{
		if ( PLV_SpawnWithFreefall() )
		{
			if ( !HasPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround ) )
			{
				AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
			}
		}
		else
		{
			thread DropShipJump_WaitThenDiveDown_Thread( player, playersArray, player, destination, 0.0 )
		}
	}
}
#endif // SERVER

#if SERVER
void function LandingMarker_Create( int team, Point destPt )
{
	vector destination = destPt.origin

	int ringFXIndex = GetParticleSystemIndex( GROUNDMARKER_FX_RING )

	sSkydiveLandingMarker landingMarkerData

	// Create this client-side so players only see their own Landing markers.
	entity wayPt = CreateWaypoint_Custom( POISPAWN_SKYDIVEDESTWP_NAME )
	wayPt.SetOrigin( destination )
	wayPt.SetWaypointInt( POISPAWN_SKYDIVEDESTWP_NDX_TEAM, team )

	// Landing FX on the ground.
	int centerFXIndex = GetParticleSystemIndex( GROUNDMARKER_FX_CENTER )
	entity centerFX = StartParticleEffectInWorld_ReturnEntity( centerFXIndex, destination, < 0, 0, 0 > )
	EffectSetControlPointVector( centerFX, 1, GROUNDMARKER_CENTER_FX_COLOR)

	// Circle on minimap for team
	entity minimapLandingCircle = LandingMinimapCircle_Create( team, "poispawn_landingcircle_minimap", destination )

	// Save all the elements.
	landingMarkerData.landingWP = wayPt
	landingMarkerData.centerFX = centerFX
	landingMarkerData.minimapObj = minimapLandingCircle
	file.landingMarkers_ByTeam[ team ] <- landingMarkerData
}

entity function LandingMinimapCircle_Create( int team, string targetName, vector destination, vector angles = < 0,0,0 > )
{
	// Circle on minimap
	entity minimapLandingCircle = CreateEntity( "prop_script" )
	minimapLandingCircle.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	minimapLandingCircle.kv.fadedist = -1
	minimapLandingCircle.kv.renderamt = 255
	minimapLandingCircle.kv.rendercolor = "255 255 255"
	minimapLandingCircle.kv.solid = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	minimapLandingCircle.SetOrigin( destination + < 0, 0, 256 > )
	minimapLandingCircle.SetAngles( angles )
	minimapLandingCircle.NotSolid()
	minimapLandingCircle.Hide()
	minimapLandingCircle.DisableHibernation()

	minimapLandingCircle.Minimap_SetObjectScale( PLV_Skydive2DRadius() / SURVIVAL_MINIMAP_RING_SCALE )
	minimapLandingCircle.Minimap_SetAlignUpright( true )
	minimapLandingCircle.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	minimapLandingCircle.Minimap_SetClampToEdge( true )
	minimapLandingCircle.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )


	foreach( playerTeam, array< entity > teamPlayers in file.groupedPlayers )
	{
		if ( playerTeam == team  )
		{
			minimapLandingCircle.Minimap_AlwaysShow( playerTeam, null )
		}
		else
		{
			minimapLandingCircle.Minimap_Hide( playerTeam, null )
		}

	}
	SetTargetName( minimapLandingCircle, targetName )
	DispatchSpawn( minimapLandingCircle )

	return minimapLandingCircle
}

void function LandingMarker_Destroy( int team )
{
	if ( !( team in file.landingMarkers_ByTeam ) )
		return

	sSkydiveLandingMarker landingMarker = file.landingMarkers_ByTeam[ team ]

	if ( IsValid( landingMarker.centerFX ) )
	{
		EffectStop( landingMarker.centerFX )
	}
	
	if ( IsValid( landingMarker.landingWP ) )
	{
		landingMarker.landingWP.Destroy()
	}

	if ( IsValid( landingMarker.minimapObj ) )
	{
		landingMarker.minimapObj.Destroy()
	}

	array< entity > teamPlayers = file.groupedPlayers[ team ]
	foreach( player in teamPlayers )
	{
		if ( IsValidPlayer( player ) )
		{
			Remote_CallFunction_Replay( player, "CL_POISpawn_LandingMarkers_Destroy" )
		}
	}
	
	delete file.landingMarkers_ByTeam[ team ]
}
#endif // SERVER

#if CLIENT
void function CL_POISpawn_LandingMarkers_Create( entity wp )
{
	entity player = GetLocalViewPlayer()
	
	int playerTeam = player.GetTeam()
	int wpTeam = wp.GetWaypointInt( POISPAWN_SKYDIVEDESTWP_NDX_TEAM )
	
	if ( playerTeam != wpTeam )
		return

	int ringFXIndex = GetParticleSystemIndex( GROUNDMARKER_FX_RING )
	
	vector destination = wp.GetOrigin()
	
	float skydiveRadius = PLV_Skydive2DRadius()

	//// Rings not drawn, but we can bring them back if they help visibility.
	//int numRings = 3
	//for( int i = 0; i <= numRings; i++ )
	//{
	//	float radiusMod 	= 1 - ( i * 0.025 )
	//	float ringRadius 	= skydiveRadius * radiusMod / GROUNDMARKER_RING_FX_RADIUSDIVISOR
	//
	//	// Create and save client-side ring effects for later destruction.
	//	int ringFX = StartParticleEffectInWorldWithHandle( ringFXIndex, destination, < 0,0,0 > )
	//	vector ringColor = GROUNDMARKER_RING_FX_COLOR * radiusMod
	//	EffectSetControlPointVector( ringFX, 1, ringColor )
	//	EffectSetControlPointVector( ringFX, 2, < ringRadius, 0, 0> )
	//	file.LandingMarker_FX_Rings.append( ringFX )
	//}

	// Ring of markers around center
	int numBeams = 12
	vector destElevated = destination + < 0, 0, 5000 >
	array< vector > destLocsArray = GetPointsOnCircle( destElevated, <0,0,0>, skydiveRadius, numBeams  )
	array< vector > destGroundLocsArray

	int beamFXIndex       = GetParticleSystemIndex( GROUNDMARKER_FX_BEACON )
	foreach( dest in destLocsArray )
	{
		// Cull any flares that are too far above/below the destination point.
		vector destOnGround = OriginToGround( dest )
		float zDistToDest = fabs( destOnGround.z - destination.z )
		if ( zDistToDest > 2000 )
			continue

		int beamFX = StartParticleEffectInWorldWithHandle( beamFXIndex, destOnGround, < 0, 180 ,0 > )
		//EffectSetControlPointVector( beamFX, 1, GROUNDMARKER_RING_FX_COLOR )
		file.LandingMarker_FX_Beams.append( beamFX )
	}
}

void function CL_POISpawn_LandingMarkers_Destroy()
{
	foreach( ringFX in file.LandingMarker_FX_Rings )
	{
		if ( EffectDoesExist( ringFX ) )
		{
			EffectStop( ringFX, true, true )
		}
	}
	file.LandingMarker_FX_Rings.clear()
	
	foreach( beamFX in file.LandingMarker_FX_Beams )
	{
		if ( EffectDoesExist( beamFX ) )
		{
			EffectStop( beamFX, true, true )
		}
	}
	file.LandingMarker_FX_Rings.clear()
}

void function CL_EnemyPOI_Set_Wp_Size( entity wp )
{
	if( IsValid(wp) )
	{
		RuiSetBool( wp.wp.ruiHud, "alwaysShowLargeIcon", true )
	}
}
#endif // CLIENT

#if SERVER
void function DropShipJump_WaitThenDiveDown_Thread( entity player, array< entity > playersArray, entity jumpLeader, Point destination, float delay = 0.25 )
{
	player.EndSignal( "OnDeath", "OnDestroy" )
	player.WaitSignal( "PlayerRedeployingFromDropship" )

	//float fadeTime = 0.25
	//float holdTime = 0.1
	//ScreenFade( player, 255, 255, 255, 255, fadeTime, holdTime, FFADE_IN | FFADE_PURGE )

	player.ClearParent()

	if ( delay > 0.0 )
	{
		wait( delay )
	}

	Dive_Down( player, playersArray, jumpLeader, destination )
}
#endif // SERVER

#if SERVER
void function Skydive_Player_Thread( entity player, array< entity > playersArray, entity jumpLeader, Point destination )
{
	vector skydiveStart = destination.origin + < 0, 0, PLV_Airdrop_Height() >
	player.SetOrigin( skydiveStart )
	player.SetAbsAngles( destination.angles )

	Dive_Down( player, playersArray, jumpLeader, destination )
}

void function Dive_Down( entity player, array< entity > playersArray, entity jumpLeader, Point destination )
{
	// To guard against cases where the player dies out of bounds in the respawn before and the OnPlayerTouchGround was never called
	if ( !HasPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround ) )
	{
		AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
	}

	// Uncomment to visualize bounds.
	//#if DEV
	//	DebugDrawCylinder( destination.origin, < -90, 0, 0>, PLV_Skydive2DRadius(), PLV_Airdrop_Height, COLOR_BLUE, false, 90 )
	//#endif // DEV

	// --- Dive Straight Down.
	// V1
	//vector initVelocity = < 0, 0, -100 >
	//vector dir = player.GetViewVector() * 100 + initVelocity
	//vector driverViewVector = ( Normalize( destination.origin - player.GetOrigin() ))
	//player.SetForwardVector( driverViewVector )
	//float skydiveRadius = PLV_Skydive2DRadius()
	//thread PlayerSkyDive( player, driverViewVector, [player], player, false, true, initVelocity, true, true, destination.origin, skydiveRadius )

	//thread DelayedLockForwardInput( player, 0.05 )

	//// V2
	//vector driverViewVector = Normalize( destination.origin - player.EyePosition() )
	//vector destSkydiveVector = driverViewVector * 300
	//player.SnapEyeAngles( VectorToAngles( driverViewVector ) )	// Look at destination.
	//player.SnapFeetToEyes()
	//thread PlayerSkyDive( player, driverViewVector, [player], player, false, true, destSkydiveVector, true, true, destination.origin, PLV_Skydive2DRadius() )

	//// V3
	//vector driverViewVector = Normalize( destination.origin - player.EyePosition() )
	//vector destSkydiveVector = driverViewVector * 300
	//player.SnapEyeAngles( VectorToAngles( driverViewVector ) )	// Look at destination.
	//thread PlayerSkyDive( player, driverViewVector, [player], player, false, true, destSkydiveVector, true, true, destination.origin, PLV_Skydive2DRadius() )

	//// V4
	//vector driverViewVector = Normalize( destination.origin - player.EyePosition() )
	//vector destSkydiveVector = driverViewVector * 300
	//player.SnapEyeAngles( VectorToAngles( driverViewVector ) )	// Look at destination.
	//thread PlayerSkyDive( player, player.GetViewVector(), [player], player, true, true, destSkydiveVector, true, true, destination.origin, PLV_Skydive2DRadius() )

	// V5
	vector skyPosition = destination.origin + < 0, -190, PLV_Airdrop_Height() >	// Point above destination and slightly back.
	vector driverViewVector = Normalize( destination.origin - skyPosition )
	vector destSkydiveVector = driverViewVector * 300
	player.SnapEyeAngles( VectorToAngles( driverViewVector ) )	// Look at destination.
	float constrainedRadius = player.IsBot() ? 1000.0 : PLV_Skydive2DRadius()	// Constrain bot dives more strictly so they don't land somewhere silly and die.
	thread PlayerSkyDive( player, player.GetViewVector(), [player], player, false, true, destSkydiveVector, true, true, true, destination.origin, constrainedRadius)

	thread DelayedLockForwardInput( player, 0.01 )
}

void function DelayedLockForwardInput( entity player, float delay = 0.25 )
{
	if ( !IsValidPlayer( player ) )
		return

	if ( !IsAlive( player ) )
		return

	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{

		}
	)

	while( !player.Player_IsSkydiving() )
	{
		WaitFrame()
	}

	//player.Player_SkydiveSetScriptInputOverride( 0.0 )
	//wait( delay )
	//player.Player_SkydiveSetScriptInputOverride( 1.0 ) // Note: This auto-clears after Skydive is done.
}
#endif // SERVER

#if SERVER
void function OnPlayerTouchGround( entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	player.ClearParent()

	RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
	player.kv.airSpeed = player.GetPlayerSettingFloat( "airSpeed" )
	player.kv.airAcceleration = player.GetPlayerSettingFloat( "airAcceleration" )

	player.p.lastRespawnTouchGroundTime = Time()

	// TODO: defensive fix for players being perpetually OOB when respawning; this is a reasonable quick fix vs. a rewrite of the OOB trigger system.
	player.SetOutOfBoundsDeadTime( 0.0 )

	PIN_PlayerLandedOnGround( player )

	ClearPlayerIntroDropSettings( player )

	thread ForceCrouchStand_1PCameraRestoreHack_Thread( player, 2, 2 )

	bool giveRandomLoot = GetCurrentPlaylistVarInt( "survival_squad_spawn_with_random_loot", 0 ) == 1
	if ( giveRandomLoot )
	{
		GiveRandomStartingLoot( player )
	}

	if ( PLV_PingPairedEnemyOnLanding() )
	{
		//int team = player.GetTeam()
		//thread Ping_Linked_SpawnEnt_Team_Thread( team )
		Track_PlayersLanded( player )
	}
}
#endif // SERVER

#if SERVER
// WIP.
void function Track_PlayersLanded( entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	int team = player.GetTeam()

	if ( !( team in file.landedPlayers_ByTeam ) )
	{
		file.landedPlayers_ByTeam[ team ] <- []
	}

	if ( !file.landedPlayers_ByTeam[ team ].contains( player ) )
	{
		file.landedPlayers_ByTeam[ team ].append( player )
	}

	// If not all team members have landed, return
	array< entity > teamPlayers = GetPlayerArrayOfTeam( team )
	foreach( teamPl in teamPlayers )
	{
		if ( !file.landedPlayers_ByTeam[ team ].contains( teamPl ) )
			return
	}

	// All team players have landed. Ping linked spawnent team, and turn off ground marker.
	LandingMarker_Destroy( team )
	thread Ping_Linked_SpawnEnt_Team_Thread( team )
}

void function Ping_Linked_SpawnEnt_Team_Thread( int team )
{
	// Only let 1 ping per team to enemy team.
	if ( file.teams_ThatDidLandingPing.contains( team ) )
		return

	file.teams_ThatDidLandingPing.append( team )

	// Ping the enemy team at the linked spawn point, if there is a linked spawn point.
	// This is not an error case, and is possible if we're not using curated linked spawn ents.
	if ( !( team in file.spawnEnt_For_Team ) )
		return

	// --- 0. Wait a small duration  for other teams to touchdown and for round to start.
	wait( 1.9 )

	// --- 1. Get the spawnEnt chosen for the team.
	entity spawnEntForTeam = file.spawnEnt_For_Team[ team ]
	if ( !IsValid( spawnEntForTeam ) )
		return

	// --- 2. Get the linked spawnEnt
	entity linked_SpawnEnt = spawnEntForTeam.GetLinkEnt()

	// --- 3. If there is a linked spawnEnt, make a random player from the given team ping a random player player from the enemy team at the linked spawnEnt.
	if ( !IsValid( linked_SpawnEnt ) )
		return

	// This is possible of there was no paired team to spawn at linked spawnPt. ( odd # teams )
	if ( !( linked_SpawnEnt in file.team_At_SpawnEnt ) )
	{
		vector linkedSpawnLoc = linked_SpawnEnt.GetOrigin()
		printt( format( "%s(): No team spawned at linked spawnEnt at %s.", FUNC_NAME(), string( linkedSpawnLoc ) ) )
		return
	}

	int enemyTeam = file.team_At_SpawnEnt[ linked_SpawnEnt ]

	array< entity > pingingTeamPlayerArray = file.groupedPlayers[ team ]
	ArrayRemoveInvalid( pingingTeamPlayerArray )
	if ( pingingTeamPlayerArray.len() == 0 )
		return

	entity pingingPlayer = pingingTeamPlayerArray.getrandom()

	array< entity > targetTeamPlayerArray = file.groupedPlayers[ enemyTeam ]
	ArrayRemoveInvalid( targetTeamPlayerArray )
	if ( targetTeamPlayerArray.len() == 0 )
		return

	entity targetPlayer = targetTeamPlayerArray.getrandom()

	entity wp = CreateWaypoint_Ping_Location( pingingPlayer, ePingType.ENEMY_POI, linked_SpawnEnt, linked_SpawnEnt.GetOrigin(), -1, true )

	if( IsValid(wp) )
	{
		array< entity > teamPlayers = GetPlayerArrayOfTeam( pingingPlayer.GetTeam() )
		foreach ( entity player in teamPlayers )
		{
			Remote_CallFunction_Replay( player, "CL_EnemyPOI_Set_Wp_Size", wp )
		}
	}


	// Circle on minimap for enemy team
	entity enemyLandingCircle = LandingMinimapCircle_Create( team, "poispawn_landingcircle_enemy_minimap", linked_SpawnEnt.GetOrigin() )

	const float ENEMYLANDINGCIRCLE_DRAWTIME = 30.0
	wait ENEMYLANDINGCIRCLE_DRAWTIME

	if ( IsValid( wp ) )
	{
		wp.Destroy()
	}

	if ( IsValid( enemyLandingCircle ) )
	{
		enemyLandingCircle.Destroy()
	}
}
#endif // SERVER

#if SERVER
void function RemoveCrampedSpawnPoints( array< vector > lootPoints, vector extents = < 32, 32, 64 >, bool debug = false )
{
	// Remove loot points that don't have enough neighboring positions for your teammates. This also gets rid of points not on navmesh because neighboring positions will be 0 if we don't start on navmesh
	for ( int i = lootPoints.len() - 1; i >= 0; i-- )
	{
		// Clamp loot point to navmesh
		vector ornull clampedPoint = NavMesh_ClampPointForHullWithExtents( lootPoints[i], HULL_HUMAN, <16, 16, 64> )
		if ( clampedPoint != null )
		{
			lootPoints[i] = expect vector( clampedPoint )
			int numPositions             = maxint( 2, MAX_TEAM_PLAYERS )
			array<vector> neighborPoints = NavMesh_GetNeighborPositions( lootPoints[i], HULL_HUMAN, numPositions )
			if ( neighborPoints.len() >= numPositions )
			{
				#if DEVELOPER
					DEVSphere( debug, lootPoints[i], 4.0, <0, 128, 0>, true, 10.0 )
					DEVLine( debug, lootPoints[i], lootPoints[i] + <0, 0, 2000>, <0, 128, 0>, true, 10.0 )
				#endif // DEV
				continue
			}
		}

		// Failed
		#if DEVELOPER
			DEVSphere( debug, lootPoints[i], 4.0, <255, 128, 128>, true, 10.0 )
			DEVLine( debug, lootPoints[i], lootPoints[i] + <0, 0, 2000>, <255, 128, 128>, true, 10.0 )
		#endif // DEV

		lootPoints.remove( i )
	}
}
#endif // SERVER

// ---
// ---
// --- Custom DropShip Jump Stuff.

#if SERVER
void function DropShipJump_Init()
{
	// Call from POIPlayerSpawning_Init()

	if ( !PLV_DropShipJump() )
		return

	//front left
	dropshipAnimData dataForPlayerA
	dataForPlayerA.idleAnim = "Classic_MP_flyin_exit_playerA_idle"
	dataForPlayerA.idlePOVAnim = "Classic_MP_flyin_exit_povA_idle"
	dataForPlayerA.jumpAnim = "Classic_MP_flyin_exit_playerA_jump"
	dataForPlayerA.jumpPOVAnim = "Classic_MP_flyin_exit_povA_jump"
	dataForPlayerA.viewConeFunc = DropShipJump_ViewConeWide
	//dataForPlayerA.yawAngle = -18.0
	dataForPlayerA.firstPersonJumpOutSound = "commander_sequence_soldier_a_jump"

	//back right
	dropshipAnimData dataForPlayerB
	dataForPlayerB.idleAnim = "Classic_MP_flyin_exit_playerB_idle"
	dataForPlayerB.idlePOVAnim = "Classic_MP_flyin_exit_povB_idle"
	dataForPlayerB.jumpAnim = "Classic_MP_flyin_exit_playerB_jump"
	dataForPlayerB.jumpPOVAnim = "Classic_MP_flyin_exit_povB_jump"
	dataForPlayerB.viewConeFunc = DropShipJump_ViewConeWide
	//dataForPlayerB.yawAngle = 8.0
	dataForPlayerB.firstPersonJumpOutSound = "commander_sequence_soldier_b_jump"

	//front right
	dropshipAnimData dataForPlayerC
	dataForPlayerC.idleAnim = "Classic_MP_flyin_exit_playerC_idle"
	dataForPlayerC.idlePOVAnim = "Classic_MP_flyin_exit_povC_idle"
	dataForPlayerC.jumpAnim = "Classic_MP_flyin_exit_playerC_jump"
	dataForPlayerC.jumpPOVAnim = "Classic_MP_flyin_exit_povC_jump"
	dataForPlayerC.viewConeFunc = DropShipJump_ViewConeWide
	//dataForPlayerC.yawAngle = 8.0
	dataForPlayerC.firstPersonJumpOutSound = "commander_sequence_soldier_c_jump"

	//back left
	dropshipAnimData dataForPlayerD
	dataForPlayerD.idleAnim = "Classic_MP_flyin_exit_playerD_idle"
	dataForPlayerD.idlePOVAnim = "Classic_MP_flyin_exit_povD_idle"
	dataForPlayerD.jumpAnim = "Classic_MP_flyin_exit_playerD_jump"
	dataForPlayerD.jumpPOVAnim = "Classic_MP_flyin_exit_povD_jump"
	dataForPlayerD.viewConeFunc = DropShipJump_ViewConeWide
	//dataForPlayerD.yawAngle = -16.0
	dataForPlayerD.firstPersonJumpOutSound = "commander_sequence_soldier_d_jump"

	file.dropshipAnimDataList = [ dataForPlayerA, dataForPlayerB, dataForPlayerC, dataForPlayerD ]
}
#endif // SERVER

#if SERVER
void function DropShipJump_ViewConeWide( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 1.0 ) // was 0.5

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -50 )
	player.PlayerCone_SetMaxYaw( 50 )
	player.PlayerCone_SetMinPitch( -35 )
	player.PlayerCone_SetMaxPitch( 35 )
}
#endif // SERVER

#if SERVER
//void function CustomDropShip_SpawnPlayers_AtPoint( Point spawnPoint, array< entity > players, bool debug = false  )
void function CustomDropShip_SpawnPlayers_AtPoint( Point spawnPoint, int team, float dropshipAngleAdjust = 180.0, bool debug = false  )
{
	DropShipJump_Init()

	// Spawn a dropship above the destination.
	vector dropshipOrigin = spawnPoint.origin + < 0, 0, PLV_Airdrop_Height() >
	if ( PLV_CustomDropship_AllShipsParallel() )
	{
		spawnPoint.angles = VectorToAngles( CUSTOM_DROPSHIP_PARALLEL_FACING	) // Every ship moves in the same direction.
	}
	vector dropshipAngles = AnglesCompose( spawnPoint.angles , < 0, dropshipAngleAdjust, 0 > )

	// If we skip 1P, we get better framing by moving the dropship back a little bit.
	dropshipOrigin = PLV_CustomDropship_Skip1P() ? dropshipOrigin + AnglesToForward( dropshipAngles ) * 650 + AnglesToRight( dropshipAngles ) * 190 : dropshipOrigin

	entity dropship = CreateEntity( "npc_dropship" )

	#if DEVELOPER
		DEVSphere( debug, dropshipOrigin, 200, COLOR_PURPLE, true, 30 )
	#endif // DEV

	SetTeam( dropship, eNpcTeam.FRIENDLY )
	SetSpawnOption_AISettings( dropship, "npc_dropship_respawn" )
	SetTargetName( dropship, RESPAWN_DROPSHIP_TARGETNAME )
	DispatchSpawn( dropship )
	dropship.SetInvulnerable()
	dropship.DisableHibernation()
	dropship.DisableGrappleAttachment()
	dropship.SetOrigin( dropshipOrigin )
	dropship.SetAngles( dropshipAngles )
	//dropship.SetNetworkDistanceCullEnabled( false )
	dropship.DisablePhysics()

	dropship.EnableIdLights()

	// TODO: Custom Skin
	if ( dropship.GetSkinIndexByName( "lights_on" ) != -1 )
		dropship.SetSkin( dropship.GetSkinIndexByName( "lights_on" ) )

	thread JetwashFX( dropship )

	// Custom Dropship Timing Values
	float animBlendTime = 0.5
	float flyin_duration = dropship.GetSequenceDuration( CUSTOMDROPSHIP_ANIM_FLYIN_NAME )
	#if DEVELOPER
		printt( format( "%s(): flyin duration == %s", FUNC_NAME(), string( flyin_duration ) ) )
	#endif // DEV

	// This is CUSTOMDROPSHIP_ANIM_FLYIN_NAME's play time on its timeline. The bigger the number, the shorter this sequence.
	float dropship_Flyin_StartPlayAtTime = 3.8 // was 2.5 // was 1.9

	// Note: dropship_Flyin_StartPlayAtTime + firsPersonStartDelay should not exceed flyin_duration.
	// Put players in dropship.
	array< entity > teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( int index, entity player in teamPlayers )
	{
		if ( IsValid( player ) )
		{
			int positionIndex = index
			thread CustomDropship_PutPlayerInDropship( player, dropship, positionIndex, spawnPoint, false )
			#if DEVELOPER
				printt( format( "%s(): Player %s put in position %s", FUNC_NAME(), player.GetPlayerName(), string( positionIndex ) ) )
			#endif
		}
	}

	// TODO: Custom Sound
	// Note - we can't play this any earlier, it can get radius culled if the players have not been moved into the dropship / entered observer mode.
	EmitSoundOnEntityToTeam( dropship, CUSTOMDROPSHIP_SOUND_NAME, team )

	waitthread PlayAnim( dropship, CUSTOMDROPSHIP_ANIM_FLYIN_NAME, dropshipOrigin, dropshipAngles, animBlendTime, dropship_Flyin_StartPlayAtTime )
	dropship.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
}
#endif // SERVER

#if SERVER
void function CustomDropship_PutPlayerInDropship( entity player, entity ship, int positionIndex, Point destination, bool useCameraDown1PAnims = false, bool debug = false )
{
	ship.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDisconnecting" )

	dropshipAnimData animData = file.dropshipAnimDataList[positionIndex]

	FirstPersonSequenceStruct jumpAnimSequence
	jumpAnimSequence.firstPersonAnim = animData.jumpPOVAnim
	jumpAnimSequence.thirdPersonAnim = animData.jumpAnim
	jumpAnimSequence.viewConeFunction = ViewConeTight
	jumpAnimSequence.attachment = animData.attachment
	jumpAnimSequence.hideProxy = animData.hideProxy

	player.Signal( "StopPostDeathLogic" )
	AddCinematicFlag( player, CE_FLAG_INTRO )
	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	AddCinematicFlag( player, CE_FLAG_EMBARK ) // DoF

	entity dummyEnt = CreatePropDynamic( $"mdl/humans/class/medium/pilot_medium_bloodhound.rmdl" ) // TODO: use generic model.  Can't use player settings here since they could be a spectator

	// TODO: Take idleTimeOverride out of parameters and just define the idleTime here based on whether to skip hatch shot.
	//float idleTime  = ((idleTimeOverride > 0.0) ? idleTimeOverride : dummyEnt.GetSequenceDuration( animData.idleAnim ))
	float idleTime = PLV_CustomDropship_SkipOpenHatchShot() ? 5.5 : 8.5

	float jumpTime  = dummyEnt.GetSequenceDuration( animData.jumpAnim )
	float totalTime = idleTime + jumpTime
	dummyEnt.Destroy()

	#if DEVELOPER
		printt( format( "%s(): idleTime == %s", FUNC_NAME(), string( idleTime ) ) )
	#endif

	player.SetInvulnerable() // Allow invulnerable in all cases until after 1P animation.
	MakePlayerVisible( player, false ) 	// Hide the player until ship stuff is done.
	player.SetOrigin( destination.origin )
	player.SetAngles( destination.angles )

	ScreenFadeFromBlack( player, 0.75, 1.0 )

	player.p.respawnPod = ship

	// -- Original View. Kept here for reference.
	//int observerMode = OBS_MODE_CHASE
	//player.p.observerMode = observerMode
	//player.StartObserverMode( observerMode )
	//player.SetObserverTarget( ship )

	// -- New View. Note: Shot1duration + Shot2Duration should <= idleTime.
	// Version: 2 shots
	float shot1Duration
	float shot2Duration
	if ( PLV_CustomDropship_SkipOpenHatchShot() )
	{
		shot1Duration = idleTime + 0.5
		shot2Duration = 0.0
	}
	else
	{
		shot1Duration = idleTime * 0.65
		shot2Duration = idleTime - shot1Duration
	}
	thread CustomDropship_View_Thread( player, ship, destination, shot1Duration, shot2Duration, debug )

	player.EnableVelocityShakeAlwaysOn()

	table<string, bool> e
	e[ "clearDof" ] <- true
	e[ "didHolsterAndDisableWeapons" ] <- false
	e[ "didClearVelocityShakeAlwaysOn" ] <- false

	entity moverHelper = CreateScriptMover( $"mdl/dev/empty_model.rmdl", destination.origin, destination.angles )

	OnThreadEnd(
		function () : ( player, e, ship, moverHelper )
		{
			if ( IsValid( player ) )
			{
				RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
				RemoveCinematicFlag( player, CE_FLAG_INTRO )

				if ( e["clearDof"] )
					RemoveCinematicFlag( player, CE_FLAG_EMBARK )
				if ( e["didHolsterAndDisableWeapons"] )
					DeployAndEnableWeapons( player )
				if ( e["didClearVelocityShakeAlwaysOn"] == false )
					player.DisableVelocityShakeAlwaysOn()

				player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.NONE )
				player.SetPlayerNetTime( "respawnBannerPickedUpTime", -1 )
				player.p.respawnPod = null
				player.p.respawnPodLanded = false
				player.ClearParent()
				ClearPlayerAnimViewEntity( player )
				player.ClearInvulnerable()
			}

			if ( IsValid( ship ) )
			{
				ship.kv.solid = 0
			}

			if ( IsValid( moverHelper ) )
			{
				moverHelper.Destroy()
			}
		}
	)

	if ( PLV_CustomDropship_Skip1P() )
	{
		vector vRight = 	AnglesToRight( destination.angles )
		vector vUp = 		AnglesToUp( destination.angles )
		vector vForward = 	AnglesToForward( destination.angles )

		float spacingXY = 72.0
		float spacingZ = 72.0

		vector posLoc0 = destination.origin + < 0, 0, PLV_Airdrop_Height() >

		vector posLoc
		switch ( positionIndex )
		{
			case 0:
				posLoc = posLoc0 + ( vForward * spacingXY )
				break
			case 1:
				posLoc = posLoc0 - ( vRight * spacingXY )
				break
			case 2:
				posLoc = posLoc0 + ( vRight * spacingXY )
				break
			case 3:
				posLoc = posLoc0 - ( vForward * 2 * spacingXY )
				break
		}

		#if DEVELOPER
			if ( debug )
			{
				float debugDrawDuration = 90
				DebugDrawLine( posLoc0, posLoc0 + AnglesToForward( destination.angles ) * spacingXY * 2, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, debugDrawDuration )
				DebugDrawLine( posLoc0, posLoc0 + vRight * spacingXY * 2, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, debugDrawDuration )
				DebugDrawSphere( posLoc0, 96, int(COLOR_WHITE.x), int(COLOR_WHITE.y), int(COLOR_WHITE.z), true, debugDrawDuration )
				DebugDrawSphere( posLoc, 64, int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), true, debugDrawDuration )
				DebugDrawText( posLoc, string( positionIndex ), false, debugDrawDuration )
			}
		#endif // DEV

		moverHelper.SetOrigin( posLoc )
		moverHelper.SetAngles( destination.angles )
		player.SetOrigin( posLoc )
		player.SetAngles( destination.angles )
		player.SetParent( moverHelper )

		wait idleTime

		player.ClearParent()

		player.kv.airSpeed = 300
		player.kv.airAcceleration = 1000
		player.Signal( "PlayerRedeployingFromDropship" )

		ScreenFadeFromColor( player, 0, 0, 0, 255, 2.5, 0.5 )

		MakePlayerVisible( player, true )
		player.StopObserverMode()
	}
	else
	{
		wait idleTime

		thread FadePlayerView( player, 0.1, e )
		player.StopObserverMode()
		player.SetOrigin( ship.GetOrigin() )

		player.DisableVelocityShakeAlwaysOn()
		e[ "didClearVelocityShakeAlwaysOn" ] <- true

		EmitSoundOnEntityOnlyToPlayer( player, player, animData.firstPersonJumpOutSound )
		ship.Signal( "PlayersDeployingFromDropship" )

		HolsterAndDisableWeapons( player )
		e[ "didHolsterAndDisableWeapons" ] <- true

		if ( useCameraDown1PAnims )
		{
			array< string > jumpAnims = [ 	"Classic_MP_flyin_exit_povA_jump_CameraAngleDown",
											"Classic_MP_flyin_exit_povB_jump_CameraAngleDown",
											"Classic_MP_flyin_exit_povC_jump_CameraAngleDown",
											"Classic_MP_flyin_exit_povD_jump_CameraAngleDown" ]

			if ( ( positionIndex >= 0 ) && ( positionIndex < jumpAnims.len() ) )
			{
				jumpAnimSequence.firstPersonAnim =  jumpAnims[ positionIndex ]
			}

			#if DEVELOPER
				printt( format( "%s(): Player %s 1p Anim == %s ", FUNC_NAME(), player.GetPlayerName(), jumpAnimSequence.firstPersonAnim ) )
			#endif
		}

		MakePlayerVisible( player, true )
		waitthread FirstPersonSequence( jumpAnimSequence, player, ship )
	}

	// Enable inventory if disabled.
	if ( IsInventoryDisabled( player ) )
	{
		EnableInventory( player )
	}

	player.kv.airSpeed = 300
	player.kv.airAcceleration = 1000

	player.Signal( "PlayerRedeployingFromDropship" )
}
#endif // SERVER

#if SERVER
void function MakePlayerVisible( entity player, bool isVisible )
{
	if ( !IsValidPlayer( player ) )
		return

	if ( isVisible )
	{
		player.UnhidePlayer()
		player.SetNameVisibleToFriendly( true )
		player.Solid()
		player.MakeVisible()
	}
	else
	{
		player.HidePlayer()
		player.SetNameVisibleToFriendly( false )
		player.NotSolid()
		player.MakeInvisible()
	}
}
#endif // SERVER

#if SERVER
void function CustomDropship_View_Thread( entity player, entity ship, Point destination, float shot1Duration, float shot2Duration, bool debugShot1 = true, bool debugShot2 = false )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( ship ) )
		return

	ship.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDisconnecting" )

	OnThreadEnd(
		function():( player )
		{

		}
	)

	vector viewOrigin
	vector viewAngles
	float shotDuration
	float fovStart
	float fovEnd

	int observerMode = OBS_MODE_STATIC
	player.p.observerMode = observerMode
	vector shipForward = Normalize( ship.GetForwardVector())
	vector shipRight = Normalize( ship.GetRightVector())
	vector destinationForward = Normalize( AnglesToForward( destination.angles ))
	vector destinationRight =Normalize( AnglesToRight( destination.angles ))

	//// Old version when Dropships were still dropping players off facing west:
	//vector shipLoc_Adjusted = ship.GetOrigin() + < 0, 0, 3000 > - shipForward * 500 - shipRight * 250 // The ship's origin is not actually on the ship.
	//vector shipLoc_Adjusted = ship.GetOrigin() + < 0, 0, 3000 > - < 500, 0, 0 > - < 0, -250, 0 > // More orthogonal than using the slightly slanted ship forward and right.
	//viewOrigin = shipLoc_Adjusted + < 0, 0, 3800 > - shipForward * 550
	//viewAngles = VectorToAngles( VectorRotateAxis( destination.origin - viewOrigin , < 0, 0, 1 >, -90 ))

	// This version frames the ship properly for skip1P with the dropship offset from the destination set in CustomDropship_SpawnPlayers_AtPoint
	float forwardVal = 2500
	float cameraBackVal = forwardVal + 100
	float rightVal = 50
	vector shipLoc_Adjusted = < destination.origin.x, destination.origin.y, ship.GetOrigin().z > + < 0, 0, 2000 > + destinationForward * forwardVal + destinationRight * rightVal
	viewOrigin = shipLoc_Adjusted + < 0, 0, 1900 > - destinationForward * cameraBackVal
	viewAngles = VectorToAngles( destination.origin + destinationRight * rightVal - viewOrigin )
	fovStart = 89 // was 110
	fovEnd = 69 // was 90

	// Shot: Overhead, show destination
	shotDuration = shot1Duration
	#if DEVELOPER
		if ( debugShot1 )
		{
			float debugDuration = 120
			DebugDrawLine( viewOrigin, shipLoc_Adjusted, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, debugDuration )
			DebugDrawSphere( shipLoc_Adjusted, 128, int(COLOR_PURPLE.x), int(COLOR_PURPLE.y), int(COLOR_PURPLE.z), true, debugDuration )
			DebugDrawSphere( ship.GetOrigin(), 128, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, debugDuration )
			DebugDrawSphere( viewOrigin, 128, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, debugDuration )
		}
	#endif

	if ( player.IsBot() )
	{
		wait( shotDuration )
	}
	else
	{
		PutPlayerInObserverModeWithOriginAngles( player, observerMode, viewOrigin, viewAngles )
		Remote_CallFunction_Replay( player, "ServerToClient_CustomDropship_CameraZoom", player, shotDuration, fovStart, fovEnd )
	}

	// Shot: Focus on Ship
	if ( shot2Duration == 0 )
		return

	shotDuration = shot2Duration
	viewOrigin = shipLoc_Adjusted + < 0, 0, 190 > + Normalize( shipForward ) * 900
	//viewOrigin = shipLoc_Adjusted + < 0, 0, 950 > + Normalize( shipForward ) * 1200
	viewAngles = VectorToAngles( shipLoc_Adjusted - viewOrigin )
	fovStart = 75
	fovEnd = 70
	#if DEVELOPER
		if ( debugShot1 )
		{
			float debugDuration = 120
			DebugDrawLine( viewOrigin, shipLoc_Adjusted, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, debugDuration )
			DebugDrawSphere( shipLoc_Adjusted, 128, int(COLOR_PURPLE.x), int(COLOR_PURPLE.y), int(COLOR_PURPLE.z), true, debugDuration )
			DebugDrawSphere( ship.GetOrigin(), 128, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, debugDuration )
			DebugDrawSphere( viewOrigin, 128, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, debugDuration )
		}
	#endif
	if ( !player.IsBot() )
	{
		PutPlayerInObserverModeWithOriginAngles( player, observerMode, viewOrigin, viewAngles )
		Remote_CallFunction_Replay( player, "ServerToClient_CustomDropship_CameraZoom", player, shotDuration, fovStart, fovEnd )
	}
}

#endif // SERVER

#if CLIENT
void function ServerToClient_CustomDropship_CameraZoom( entity player, float duration, float fovStart, float fovEnd )
{
	if ( !IsValid( player ) )
		return

	player.SetObserverModeStaticFOVLerp( fovStart, fovEnd, duration )
}
#endif

// -----
