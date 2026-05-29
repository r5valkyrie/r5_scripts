#if DEVELOPER
global function SpawnDebugger_Init
global function DEV_EnableSpawnPointTesting
#if SERVER
global function DEV_CheckSpawnsAgainstNavMesh
global function DEV_PrintSpawnPointLocationToFile
global function DEV_SaveSpawnPointLocation
global function DEV_ForceSpawnAtNextSpawnPoint
global function DEV_ForceSpawnAtPreviousSpawnPoint
#endif // SERVER

const string SPAWN_DEBUG_SIGNAL = "ShowOnScreenDebug"
const string SPAWN_DEBUG_MATCHING_POS = "PLAYER POSITION DOES NOT MATCH SPAWN POINT POSITION"
const string DEBUG_FILE_OUTPUT_PATH = "../../dumps/" // Note: this path has to exist in order for files to be written out to. (This is C:\depot\VBRANCH\dumps)

const vector SPAWN_DEBUG_COLOR_GREEN = < 0, 255, 0 > //GREEN
const vector SPAWN_DEBUG_COLOR_RED = < 255, 0, 0 > // RED
const vector TRACE_HULL_MIN = < -16, -16, 0 >
const vector TRACE_HULL_MAX = < 16, 16, 80 >
const vector DEBUG_BOX_CENTER_OFFSET = < 0, 0, 16 >

const float MAX_SPAWNPOINT_HEIGHT_FROM_NAVMESH = 16.01 //From Center to a Side on Spawn Point Asset
const float TRACE_LENGTH = 80 // the height of the tallet character
const float DEBUG_SPHERE_RADIUS = 8.0
const float DEBUG_DRAW_DURATION = 300.0

const int MAX_SPAWNPOINT_TO_DEBUG_DRAW = 20 // This is a safety measure to prevent too many debug draws and crash the game

struct
{
	int spawnPointInt = 0
	vector spawnPointOrigin
	string mapName
	array<vector> spawnPointPosArray
	array<entity> spawnPointOnNavMeshArray
	array<entity> spawnPointHeightCheckArray
	float distanceToNavMesh
} file
#endif // DEV

//////////////////////
// SPAWN DEBUG TOOL //
//////////////////////

#if DEVELOPER
void function SpawnDebugger_Init()
{
	RegisterSignal( SPAWN_DEBUG_SIGNAL )
}

void function DEV_EnableSpawnPointTesting( bool enabled)
{
	entity player = GetPlayerArray()[0]
	Assert( IsValid( player ), "[SPAWN DEBUGGER] Unable to find a local player: DEV_EnableSpawnPointTesting" )

	if ( enabled )
	{
		#if SERVER
			RunClientCommandOnPlayer( player, "script_client DEV_EnableSpawnPointTesting( true )" )

			foreach ( entity spawnPoint in svSpawnGlobals.allNormalAndStartSpawnpoints )
			{
				DebugDrawSpawnpoint( spawnPoint, SPAWN_DEBUG_COLOR_GREEN, true, DEBUG_DRAW_DURATION )
			}
		#endif // SERVER

		#if CLIENT
			player.ClientCommand( "bind KP_RIGHTARROW \"script DEV_ForceSpawnAtNextSpawnPoint()\"" )
			player.ClientCommand( "bind KP_LEFTARROW \"script DEV_ForceSpawnAtPreviousSpawnPoint()\"" )
			player.ClientCommand( "bind KP_DOWNARROW \"script DEV_PrintSpawnPointLocationToFile()\"" )
			player.ClientCommand( "bind KP_5 \"script DEV_SaveSpawnPointLocation()\"" )
			printt( "[SPAWN DEBUGGER] Enabled Spawn Point Testing" )
		#endif // CLIENT

		file.mapName = GetMapName().tolower()
	}
	else
	{
		#if SERVER
			RunClientCommandOnPlayer( player, "script_client DEV_EnableSpawnPointTesting( false )" )
			player.Signal( SPAWN_DEBUG_SIGNAL )
		#endif // SERVER

		#if CLIENT
			player.ClientCommand( "unbind KP_RIGHTARROW" )
			player.ClientCommand( "unbind KP_LEFTARROW" )
			player.ClientCommand( "unbind KP_DOWNARROW" )
			player.ClientCommand( "unbind KP_5" )
			printt( "[SPAWN DEBUGGER] Disabled Spawn Point Testing" )
		#endif // CLIENT

		file.spawnPointPosArray.clear()
	}
}

#if SERVER
void function DEV_CheckSpawnsAgainstNavMesh( bool enabled )
{
	entity player = GetPlayerArray()[0]
	Assert( IsValid( player ), "Unable to find a local player: DEV_CheckSpawnsAgainstNavMesh" )

	file.spawnPointOnNavMeshArray.clear()
	file.spawnPointHeightCheckArray.clear()
	file.mapName = GetMapName().tolower()

	// Toggle NavMesh and Spawn Point visibility
	if ( enabled )
	{
		printt( "[SPAWN DEBUGGER] Enabled NavMesh Debug" )
		RunClientCommandOnPlayer( player, "navmesh_draw 1" )
		RunClientCommandOnPlayer( player, "spawnpoint_debug 1" )

		vector upVector = < 0, 0, 1 >

		// Iterate through all SpawnPoints and mark them if they are not touching or don't have enough vertical space for a player to spawn at
		foreach ( entity spawnPoint in svSpawnGlobals.allNormalAndStartSpawnpoints )
		{
			vector location = spawnPoint.GetOrigin()
			vector safeSpotOnNavmesh = NavMesh_GetClosestPoint( location )
			file.distanceToNavMesh = Distance( spawnPoint.GetOrigin() + DEBUG_BOX_CENTER_OFFSET, safeSpotOnNavmesh )

			vector traceEnd = spawnPoint.GetOrigin() + upVector * TRACE_LENGTH
			TraceResults trace = TraceHull( spawnPoint.GetOrigin(), traceEnd, TRACE_HULL_MIN, TRACE_HULL_MAX, svSpawnGlobals.allNormalAndStartSpawnpoints, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )

			//If Spawn Point is not touching the NavMesh
			if ( file.distanceToNavMesh > MAX_SPAWNPOINT_HEIGHT_FROM_NAVMESH )
			{
				file.spawnPointOnNavMeshArray.append( spawnPoint )
			}

			// If Spawn Point doesn't provide enough vertical space to fit a character
			if ( trace.fraction < 1.0 )
			{
				file.spawnPointHeightCheckArray.append( spawnPoint )
			}
		}

		int debugDraws = 0
		// Draw Debug for spawn points not touching the NavMesh
		foreach ( entity navMeshEnt in file.spawnPointOnNavMeshArray )
		{
			if ( debugDraws > MAX_SPAWNPOINT_TO_DEBUG_DRAW )
			{
				break
			}

			DEV_DrawSphereOnBadSpawnPoints( navMeshEnt )
			file.spawnPointPosArray.append( navMeshEnt.GetOrigin() )
			debugDraws++
		}

		// Draw Debug for spawn points with not enough height clearance
		foreach ( entity heightCheckEnt in file.spawnPointHeightCheckArray )
		{
			if ( debugDraws > MAX_SPAWNPOINT_TO_DEBUG_DRAW )
			{
				break
			}

			DEV_DrawLineForLowHeightSpawnPoint( heightCheckEnt )
			file.spawnPointPosArray.append( heightCheckEnt.GetOrigin() )
			debugDraws++
		}
		DEV_PrintSpawnPointLocationToFile()
	}
	else
	{
		RunClientCommandOnPlayer( player, "navmesh_draw 0" )
		RunClientCommandOnPlayer( player, "spawnpoint_debug 0" )
	}
}
#endif //SERVER

#if SERVER
void function DEV_ForceSpawnAtNextSpawnPoint()
{
	//Moving to next point
	file.spawnPointInt += 1

	if ( file.spawnPointInt > svSpawnGlobals.allNormalAndStartSpawnpoints.len() - 1 )
	{
		file.spawnPointInt = 0
	}

	DEV_ForceSpawn()
}
#endif //SERVER

#if SERVER
void function DEV_ForceSpawnAtPreviousSpawnPoint()
{
	//Move to previous Point
	file.spawnPointInt -= 1

	if ( file.spawnPointInt < 0 )
	{
		file.spawnPointInt = svSpawnGlobals.allNormalAndStartSpawnpoints.len() - 1
	}

	DEV_ForceSpawn()
}
#endif //SERVER

#if SERVER
void function DEV_ForceSpawn()
{
	//Set Position and Rotation
	GetPlayerArray()[0].SetOrigin( svSpawnGlobals.allNormalAndStartSpawnpoints[file.spawnPointInt].GetOrigin() )
	GetPlayerArray()[0].SetAngles( svSpawnGlobals.allNormalAndStartSpawnpoints[file.spawnPointInt].GetAngles() )

	//Start Thread and get it to print DebugDrawScreenText for a duration
	printl( "[SPAWN DEBUGGER] Player Position: " + GetPlayerArray()[0].GetOrigin() )
	printl( "[SPAWN DEBUGGER] Player Rotation: " + GetPlayerArray()[0].GetAngles() )
	file.spawnPointOrigin = svSpawnGlobals.allNormalAndStartSpawnpoints[file.spawnPointInt].GetOrigin()

	thread DEV_DisplayOnScreenText( file.spawnPointOrigin, GetPlayerArray()[0] )
}
#endif //SERVER

#if SERVER
void function DEV_DisplayOnScreenText( vector spawnLocation, entity player )
{
	player.Signal( SPAWN_DEBUG_SIGNAL )
	player.EndSignal( SPAWN_DEBUG_SIGNAL )
	while ( true )
	{
		DebugDrawScreenTextWithColor( 0.01, 0.37, "Spawn Point Position: " + spawnLocation, SPAWN_DEBUG_COLOR_GREEN )

		if( spawnLocation != GetPlayerArray()[0].GetOrigin() )
		{
			DebugDrawScreenTextWithColor( 0.01, 0.4, SPAWN_DEBUG_MATCHING_POS, SPAWN_DEBUG_COLOR_RED )
		}

		WaitFrame()
	}
}
#endif //SERVER

#if SERVER
void function DEV_SaveSpawnPointLocation()
{
	// Save current Spawn Point to array
	file.spawnPointPosArray.append( file.spawnPointOrigin )
}
#endif //SERVER

#if SERVER
void function DEV_PrintSpawnPointLocationToFile()
{
	// Print all Spawn Point locations to local text document
	string fileName =  DEBUG_FILE_OUTPUT_PATH + "spawn_point_debug_" + file.mapName + ".txt"

	printl( "[SPAWN DEBUGGER] Adding Spawn Point Locations to File to depot/r5dev/dumps/" )

	DevTextBufferWrite( file.mapName + "\n" )

	foreach( vector point in file.spawnPointPosArray )
	{
		DevTextBufferWrite( point + "\n" )
	}

	DevTextBufferDumpToFile( fileName )
	DevTextBufferClear()

	//Clear saves spawn point array
	file.spawnPointPosArray.clear()
}
#endif

#if SERVER
void function DEV_DrawLineForLowHeightSpawnPoint( entity spawnPoint )
{
	printl( "[SPAWN DEBUGGER] Low Spawn Point Clearance at: " + spawnPoint.GetOrigin() )
	DebugDrawBox( spawnPoint.GetOrigin(), TRACE_HULL_MIN, TRACE_HULL_MAX, SPAWN_DEBUG_COLOR_RED, 1, DEBUG_DRAW_DURATION )
}
#endif //SERVER

#if SERVER
void function DEV_DrawSphereOnBadSpawnPoints( entity spawnPoint )
{
	printl( "[SPAWN DEBUGGER] Spawn Point off NavMash at: " + spawnPoint.GetOrigin() )
	DebugDrawLine( spawnPoint.GetOrigin(), NavMesh_GetClosestPoint( spawnPoint.GetOrigin() ), int(SPAWN_DEBUG_COLOR_RED.x), int(SPAWN_DEBUG_COLOR_RED.y), int(SPAWN_DEBUG_COLOR_RED.z), true, DEBUG_DRAW_DURATION )
	DebugDrawSphere( spawnPoint.GetOrigin() + DEBUG_BOX_CENTER_OFFSET, DEBUG_SPHERE_RADIUS, int(SPAWN_DEBUG_COLOR_RED.x), int(SPAWN_DEBUG_COLOR_RED.y), int(SPAWN_DEBUG_COLOR_RED.z), true, DEBUG_DRAW_DURATION )
}
#endif // SERVER
#endif // DEV 