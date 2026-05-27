                         
global function ForcedSpawn_UseForcedSpawning
global function ForcedSpawn_GetEnemyPingDisplayTime
#if SERVER
global function ForcedSpawn_Init
global function ForcedSpawn_AddSpawnPoint
global function CodeCallback_ForcedSpawn_SetSpawnFromSettings
global function ForcedSpawn_SpawnAllPlayers
global function ForcedSpawn_TrySetTeamSpawnFromLocationIndex

global struct ForcedSpawnPoint
{
	string name
	vector location
	vector angles
	float height
	int idx

	array< int > teams
	array< vector > teamSpawnLocations
}
#endif // SERVER

struct
{
	#if SERVER
		table< int, ForcedSpawnPoint > teamToSpawnPointMap
		array< ForcedSpawnPoint > spawnPoints
	#endif // SERVER
} file


#if SERVER
void function ForcedSpawn_Init()
{
	if ( !ForcedSpawn_UseForcedSpawning() )
		return

	AddCallback_GameStateEnter( eGameState.Prematch, ForcedSpawn_OnGameStatePreMatch )
}


void function ForcedSpawn_AddSpawnPoint( string name, vector location, vector angles = < 0, 0, 0 >, float height = -1 )
{
	if ( height == -1 )
	{
		height = ForcedSpawn_SkydiveStartHeight()
	}

	ForcedSpawnPoint newPoint
	newPoint.name = name
	newPoint.height = GetCurrentPlaylistVarFloat( "forced_spawn_height_" + name, height )

	string locationString = GetCurrentPlaylistVarString( "forced_spawn_location_" + name, "" )
	if ( locationString == "" )
	{
		newPoint.location = location
	}
	else
	{
		newPoint.location = StringToVector( locationString )
	}

	string anglesString = GetCurrentPlaylistVarString( "forced_spawn_angles_" + name, "" )
	if ( anglesString == "" )
	{
		newPoint.angles = angles
	}
	else
	{
		newPoint.angles = StringToVector( anglesString )
	}

	newPoint.idx = file.spawnPoints.len()

	file.spawnPoints.append( newPoint )
}


bool function ForcedSpawn_TrySetTeamSpawnFromLocationIndex( int team, int locationIndex )
{
	if ( locationIndex >= file.spawnPoints.len() || locationIndex < 0 )
	{
		printt( "Team", team, "requested invalid spawn index #", locationIndex )
		return false
	}

	if ( team in file.teamToSpawnPointMap )
	{
		printt( "Team " + team + " already has a spawn index of " + file.teamToSpawnPointMap[team].idx + " so it is ignoring the new index of " + locationIndex )
		return false
	}

	printt( "Setting Team", team, "to spawn #", locationIndex )

	ForcedSpawnPoint spawnPoint = file.spawnPoints[locationIndex]
	spawnPoint.teams.append( team )
	file.teamToSpawnPointMap[team] <- spawnPoint

	return true
}


void function CodeCallback_ForcedSpawn_SetSpawnFromSettings( table<int,int> selections )
{
	printt( "Setting", selections.len(), "team spawn points from Custom Match settings" )
	foreach ( team, spawnPoint in selections )
	{
		// same thing as when we set it through parsing, we have to -1 the index.
		ForcedSpawn_TrySetTeamSpawnFromLocationIndex( team, spawnPoint -1 )
	}
}


void function ForcedSpawn_OnGameStatePreMatch()
{
	array< int > teams = GetAllValidPlayerTeams()
	array< ForcedSpawnPoint > unusedSpawnPoints = clone file.spawnPoints

	if ( unusedSpawnPoints.len() == 0 )
		return

	// Remove any selected locations from the list of unused spawns
	foreach ( team, spawnPoint in file.teamToSpawnPointMap )
	{
		for ( int idx = unusedSpawnPoints.len() - 1; idx >= 0; idx-- )
		{
			if ( unusedSpawnPoints[idx].location == spawnPoint.location )
			{
				unusedSpawnPoints.remove( idx )
			}
		}
	}

	unusedSpawnPoints.randomize()

	// Assign spawns to teams that don't have one
	int count = 0
	foreach ( team in teams )
	{
		if ( !( team in file.teamToSpawnPointMap ) )
		{
			if ( unusedSpawnPoints.len() == 0 )
			{
				Assert( false, "There are not enough locations to choose from currently." )
			}
			else
			{
				ForcedSpawnPoint spawnPoint = unusedSpawnPoints.pop()
				spawnPoint.teams.append( team )
				file.teamToSpawnPointMap[ team ] <- spawnPoint
			}
		}
	}

	thread SpreadOutTeamsInContestedPOIs_Thread()
}


const float DROPSHIP_WIDTH_CLIPPING_OFFSET = 500.0 // An additional offset to pull the dropship closer to the center in case it would still partially clip
const vector DROPSHIP_MINS = < -250, -250, 0 >
const vector DROPSHIP_MAXS = < 250, 250, 200 >
void function SpreadOutTeamsInContestedPOIs_Thread()
{
	foreach ( spawnPoint in file.spawnPoints )
	{
		if ( spawnPoint.teams.len() > 1 )
		{
			spawnPoint.teams.randomize() // randomize the teams so that it isn't the first one to select always gets the same spot
			vector spawnGroundPos = GetGroundPositionOpenToSky( spawnPoint.location ) // GetClosestAirdropPoint
			vector spawnLocation = spawnGroundPos + < 0, 0, 1 > * spawnPoint.height

			array< vector > teamSpawnLocations
			bool foundProperSpawns = false
			float angleIncrement = 360.0 / spawnPoint.teams.len() / 4.0
			float currentAngleAddition = 0

			// See if any spawns would be in geo, and if so rotate the orientation of the spawns to see if that fixes things
			while ( !foundProperSpawns && currentAngleAddition < 360.0 / spawnPoint.teams.len() )
			{
				teamSpawnLocations.clear()
				foreach ( team in spawnPoint.teams )
				{
					int teamIdx = spawnPoint.teams.find( team )
					vector spawnDisplacementUnitVector = AnglesToForward( < 0, 360.0 / spawnPoint.teams.len() * teamIdx + currentAngleAddition, 0 > )
					vector offsetFromSpawnCenter = spawnDisplacementUnitVector * ForcedSpawn_GetContestedSpawnRadius()
					vector possibleTeamSpawn = spawnLocation + offsetFromSpawnCenter
					vector clippingCheck = possibleTeamSpawn + spawnDisplacementUnitVector * DROPSHIP_WIDTH_CLIPPING_OFFSET * 2

					if ( TraceHullSimple( spawnLocation, clippingCheck, DROPSHIP_MINS, DROPSHIP_MAXS, null ) < 1.0 )
						break

					teamSpawnLocations.append( possibleTeamSpawn )
				}

				if ( teamSpawnLocations.len() == spawnPoint.teams.len() )
				{
					foundProperSpawns = true
				}
				else
				{
					currentAngleAddition += angleIncrement
				}
			}

			// If we were unable to find a proper spawn, just move the offending positions further inwards based on where the intersection was
			if ( !foundProperSpawns )
			{
				teamSpawnLocations.clear()

				foreach ( team in spawnPoint.teams )
				{
					int teamIdx = spawnPoint.teams.find( team )
					vector spawnDisplacementUnitVector = AnglesToForward( < 0, 360.0 / spawnPoint.teams.len() * teamIdx, 0 > )
					vector offsetFromSpawnCenter = spawnDisplacementUnitVector * ForcedSpawn_GetContestedSpawnRadius()
					vector possibleTeamSpawn = spawnLocation + offsetFromSpawnCenter
					vector clippingCheck = possibleTeamSpawn + spawnDisplacementUnitVector * DROPSHIP_WIDTH_CLIPPING_OFFSET * 2

					float traceFrac = TraceHullSimple( spawnLocation, clippingCheck, DROPSHIP_MINS, DROPSHIP_MAXS, null )
					if ( traceFrac < 1.0 )
					{
						possibleTeamSpawn = spawnLocation + offsetFromSpawnCenter * traceFrac - spawnDisplacementUnitVector * DROPSHIP_WIDTH_CLIPPING_OFFSET
					}

					teamSpawnLocations.append( possibleTeamSpawn )
				}
			}

			spawnPoint.teamSpawnLocations = teamSpawnLocations
		}
		else if ( spawnPoint.teams.len() == 1 )
		{
			vector spawnGroundPos = GetGroundPositionOpenToSky( spawnPoint.location )
			vector spawnLocation = spawnGroundPos + < 0, 0, 1 > * spawnPoint.height
			spawnPoint.teamSpawnLocations = [ spawnLocation ]
		}
	}
}


const DROPSHIP_FORWARD_FLY_IN_DIST = 5000
const DROPSHIP_UP_FLY_IN_DIST = 2500
const DROPSHIP_RIGHT_FLY_IN_DIST = 800
void function ForcedSpawn_SpawnAllPlayers()
{
	if ( !ForcedSpawn_UseForcedSpawning() )
		return

	// Set the default fields for players. These are normally done when the players are put in the plane
	foreach( player in GetPlayerArray() )
	{
		player.p.skydiveDecoysFired = 0  //Resetting mirage's decoy count so we can keep using it with PlaneTest()

		player.SetPlayerNetBool( "isJumpmaster", false )
		GradeFlagsClear( player, eTargetGrade.JUMPMASTER )
		player.SetPlayerNetBool( "isJumpingWithSquad", true )
		player.ClearInvulnerable()
	}

	array< int > teams = GetAllValidPlayerTeams()

	if ( ForcedSpawn_UseJumpmaster() )
	{
		foreach( team in teams )
		{
			entity jumpMaster = GetNextJumpmaster( team, false )
			SetJumpmaster( team, jumpMaster )
		}
	}

	array < vector > usedLocations
	foreach ( team in teams )
	{
		Assert ( team in file.teamToSpawnPointMap, "Teams must already have selected a location. Send this to @jjodell" )

		ForcedSpawnPoint spawnPoint = file.teamToSpawnPointMap[ team ]

		int teamSpawnIdx = spawnPoint.teams.find( team )
		vector spawnLocation

		if ( teamSpawnIdx != -1 )
		{
			spawnLocation = spawnPoint.teamSpawnLocations[teamSpawnIdx]
		}
		else
		{
			spawnLocation = spawnPoint.location
		}

		usedLocations.append( GetGroundPositionOpenToSky( spawnLocation ) )
		vector spawnAngles = VectorToAngles( < 0, 0, -1 > )

		vector dropshipAngles = spawnPoint.angles
		bool runTraceTest = dropshipAngles == < 0, 0, 0 > // don't run the trace checks if the spawn point has a specific angle set
		float angleAddition = 30
		float totalAddition = 0
		vector dropshipStart = spawnLocation + AnglesToForward( dropshipAngles ) * DROPSHIP_FORWARD_FLY_IN_DIST +
			< 0, 0, 1 > * DROPSHIP_UP_FLY_IN_DIST + AnglesToRight( dropshipAngles ) * DROPSHIP_RIGHT_FLY_IN_DIST // found this formula via trial and error since it is done via an animation

		while( runTraceTest && TraceLineSimple( dropshipStart, spawnLocation, null ) < 1.0 && totalAddition < 360)
		{
			dropshipAngles = AnglesCompose( dropshipAngles, < 0, angleAddition, 0 > )
			dropshipStart = spawnLocation + AnglesToForward( dropshipAngles ) * DROPSHIP_FORWARD_FLY_IN_DIST +
				< 0, 0, 1 > * DROPSHIP_UP_FLY_IN_DIST + AnglesToRight( dropshipAngles ) * DROPSHIP_RIGHT_FLY_IN_DIST
			totalAddition += angleAddition
		}

		entity jumpMaster = GetJumpmasterForTeam( team, false )
		array< entity > players = GetPlayerArrayOfTeam( team )

		if ( ForcedSpawn_DoDropshipFlyInSequence() )
		{
			thread SpawnPlayersInRespawnShipWithSkydive( players, jumpMaster, spawnLocation, spawnAngles, dropshipAngles, ePlayerMatchState.SKYDIVE_PRELAUNCH, < 0, 0, -100 > )
		}
		else
		{
			thread SpawnPlayersInSkydive( players, jumpMaster, spawnLocation, spawnAngles, ePlayerMatchState.SKYDIVE_PRELAUNCH, < 0, 0, -100 > )
		}
	}

	if ( SurvivalSelectedDrop_ShowEnemyStartPings() )
	{
		foreach ( team in teams )
		{
			entity player
			foreach ( p in GetPlayerArrayOfTeam( team ) )
			{
				if ( IsValid( p ) )
				{
					player = p
					break
				}
			}

			if ( !IsValid( player ) )
				continue

			ForcedSpawnPoint spawnPoint = file.teamToSpawnPointMap[ team ]

			int teamSpawnIdx = spawnPoint.teams.find( team )
			vector teamSpawnLocation

			if ( teamSpawnIdx != -1 )
			{
				teamSpawnLocation = spawnPoint.teamSpawnLocations[teamSpawnIdx]
			}
			else
			{
				teamSpawnLocation = spawnPoint.location
			}

			foreach ( location in usedLocations )
			{
				if ( location.x != teamSpawnLocation.x || location.y != teamSpawnLocation.y )
				{
					CreateWaypoint_Ping_Location( player, ePingType.MULTI_ENEMY_POI, null, location, -1, true )
				}
			}
		}
	}

	thread WaitAndActivateDeathField( ForcedSpawn_GetRingWaitTimeAfterSpawn() )
}

void function WaitAndActivateDeathField( float waitTime )
{
	wait waitTime

	FlagSet( "DeathCircleActive" )
}
#endif // SERVER


bool function ForcedSpawn_UseForcedSpawning()
{
	return GetCurrentPlaylistVarBool( "forced_spawn_enabled", false )
}


bool function ForcedSpawn_DoDropshipFlyInSequence()
{
	return GetCurrentPlaylistVarBool( "forced_spawn_do_dropship_fly_in_sequence", true )
}


float function ForcedSpawn_SkydiveStartHeight()
{
	return GetCurrentPlaylistVarFloat( "forced_spawn_height", 5000 )
}


bool function ForcedSpawn_UseJumpmaster()
{
	return GetCurrentPlaylistVarBool( "forced_spawn_use_jumpmaster", false )
}


bool function SurvivalSelectedDrop_ShowEnemyStartPings()
{
	return GetCurrentPlaylistVarBool( "forced_spawn_show_enemy_start_pings", true )
}


float function ForcedSpawn_GetRingWaitTimeAfterSpawn()
{
	return GetCurrentPlaylistVarFloat( "forced_spawn_ring_wait_time_after_spawn", 20.0 )
}


float function ForcedSpawn_GetContestedSpawnRadius()
{
	return GetCurrentPlaylistVarFloat( "forced_spawn_contested_spawn_radius", 500.0 )
}


float function ForcedSpawn_GetEnemyPingDisplayTime()
{
	return GetCurrentPlaylistVarFloat( "forced_spawn_enemy_ping_display_time", 20.0 )
}

// HAS_NEW_ALGS_SPAWNING
       