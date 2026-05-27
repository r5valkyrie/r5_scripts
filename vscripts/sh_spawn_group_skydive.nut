global function ShSpawnSquadSkyDive_Init
global function SpawnGroupSkydive_GetSquadSpawnDelay
global function SpawnGroupSkydive_SetCallback_GetSquadSpawnDelay

#if SERVER
global function SpawnGroupSkydive_IsSquadEliminated
global function SpawnGroupSkydive_SetCallback_CanRespawnPlayerOrSquad
global function SpawnGroupSkydive_SetCallback_GetSquadPlayersToRespawn
global function SpawnGroupSkydive_GetNumAlliancesRemaining
global function SpawnGroupSkydive_GetRemainingAlliances
global function SpawnSquadSkyDive_AddRespawnsForPlayer
global function SpawnSquadSkyDive_SubtractRespawnsFromSquad
global function SpawnSquadSkyDive_RespawnAllWaitingPlayers
global function SpawnGroupSkydive_UseCustomRateFunction
const float MIN_SPAWN_DIST_FROM_RING = 768
#endif //SERVER

global function SpawnSquadSkyDive_GetRemainingRespawnsForAllPlayersInSquad
global function SpawnGroupSkydive_ShouldTeamHavePoolOfRespawns

#if SERVER && DEV
global function Dev_SpawnSquadSkyDive_AddSpawnPoint
global function Dev_SpawnSquadSkyDive_DrawSpawnPoints
global function DEV_DrawGroupSkyDiveSpawnLocations
#endif //SERVER && DEV

const int RESPAWN_ALL_DEAD_PLAYERS_TOGETHER_SPAWNGROUP_IDX = TEAM_INVALID

struct
{
	float functionref( int ) GetSquadSpawnDelay_Callback
	#if SERVER
		array <entity> spawnPoints
		bool functionref( entity ) ShouldRespawnPlayerOrSquad_Callback
		array<entity> functionref( entity ) GetArrayOfPlayersToRespawn_Callback
		table < int, array < entity > > teamsWaitingToRespawnArrays // Only used if SpawnGroupSkydive_ShouldAllDeadPlayersSpawnTogether() is true
		array< int > teamsInRespawnDelay = []
	#endif //SERVER
} file

void function ShSpawnSquadSkyDive_Init()
{
	if ( GetRespawnStyle() != eRespawnStyle.SPAWN_GROUP_SKYDIVE )
		return
	print( "Respawn style is SPAWN_GROUP_SKYDIVE\n" )

	#if SERVER
		RegisterSignal( "SpawnSquadSkyDive_PlayerWaitingRespawnInterrupt" )

		AddCallback_GameStateEnter( eGameState.Prematch, InitSpawnPoints )
		SURVIVAL_AddCallback_OnDeathFieldStartShrink( OnDeathFieldStartShrink )

		// the respawn works in two parts
		// first, when the player dies, check if they're eligible for a respawn and flag them as such
		// then when we finish post death logic (i.e. killreplay etc) actually respawn them
		AddCallback_OnPlayerKilled( SquadSpawnSkydive_SetupDeadPlayerForRespawn )
		AddCallback_OnPostDeathLogicEnd( SquadSpawnSkydive_TryRespawnFlaggedPlayer )

		Survival_AddCallback_IsSquadReallyEliminated( SpawnGroupSkydive_IsSquadEliminated )
		AddCallback_GetNumTeamsRemaining( SpawnGroupSkydive_GetNumTeamsRemaining )

		AddCallback_EntitiesDidLoad( EntitiesDidLoad )

		file.teamsWaitingToRespawnArrays[ RESPAWN_ALL_DEAD_PLAYERS_TOGETHER_SPAWNGROUP_IDX ] <- []
	#endif // SERVER
}

#if SERVER
void function EntitiesDidLoad()
{
	if ( !SpawnGroupSkydive_UseCustomRateFunction() )
		Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_SecondClosest )
}
#endif // SERVER

#if SERVER
void function InitSpawnPoints()
{
	Assert( file.spawnPoints.len() == 0, "Can only initialize spawnpoints once at the start of the match" )
	array <entity> spawnPoints

	/////////////////////////////////////////////////
	// spawnpoints - pos on respawn beacon locations
	//////////////////////////////////////////////////
	foreach ( org in GetRespawnBeaconLocations() )
	{
		entity spawnPoint = CreateEntity( "info_spawnpoint_human" )
		spawnPoint.SetOrigin( PositionOffsetFromOriginAngles( org, <0, 0, 0>, 0, 0, 96 ) )
		spawnPoint.SetAngles( <0, 0, 0> )
		spawnPoint.kv.teamnumber = 0
		spawnPoint.e.isGroupSkydiveSpawnPoint = true
		DispatchSpawn( spawnPoint )
		spawnPoints.append( spawnPoint )
	}
	file.spawnPoints = svSpawnGlobals.allNormalSpawnpoints
}
#endif // SERVER

#if SERVER && DEV
void function Dev_SpawnSquadSkyDive_AddSpawnPoint( vector spawnPointPos = <-16161.1, 14862.8, 0> )
{
	AddSpawnPointOnSafeSpot( spawnPointPos )
}
#endif

#if SERVER && DEV
void function Dev_SpawnSquadSkyDive_DrawSpawnPoints()
{
	foreach ( location in file.spawnPoints )
		DebugDrawSphere( location.GetOrigin(), 100, COLOR_RED, true, 20 )
}
#endif

#if SERVER
array<entity> function SpawnSquadSkyDive_GetSpawnpoints()
{
	return file.spawnPoints
}
#endif //SERVER

//SHARED
// Get the remaining respawns for all players in a single squad
int function SpawnSquadSkyDive_GetRemainingRespawnsForAllPlayersInSquad( int team )
{
	// If we have infinite respawns just return them
	int teamRespawnsCount = GetStartingRespawnCount()
	if ( teamRespawnsCount < 0 )
		return teamRespawnsCount

	// If we don't have infinite respawns, start count from 0
	teamRespawnsCount = 0
	array < entity > teammates = GetPlayerArrayOfTeam( team )

	foreach ( teammate in teammates )
	{
		teamRespawnsCount += GetRemainingRespawnsForPlayer( teammate )
	}

	return teamRespawnsCount
}

#if SERVER
// Used to modify respawn count for the player. Add respawns to the current total, can use a negative value to subtract spawns
void function SpawnSquadSkyDive_AddRespawnsForPlayer( entity player, int amount )
{
	// If we have infinite respawns just break out
	if ( GetStartingRespawnCount() < 0 )
		return

	if ( !IsValid( player ) )
		return

	int remainingSpawns = maxint( 0, GetRemainingRespawnsForPlayer( player ) + amount )
	player.SetPlayerNetInt( "respawnsRemaining", remainingSpawns )
}
#endif // SERVER

#if SERVER
// Used to modify respawn count for a whole squad. Subtract as many respawns as we can from each individual player until we subtract the requested amount
void function SpawnSquadSkyDive_SubtractRespawnsFromSquad( int team, int respawnsToSubtract )
{
	// If we have infinite respawns just break out
	if ( GetStartingRespawnCount() < 0 )
		return

	int remainingRespawnsToSubtract = respawnsToSubtract
	int remainingRespawnsForPlayer = 0
	array < entity > teammates = GetPlayerArrayOfTeam( team )

	foreach ( teammate in teammates )
	{
		remainingRespawnsForPlayer = GetRemainingRespawnsForPlayer( teammate )

		if ( remainingRespawnsForPlayer <= 0 ) // Player doesn't have any respawns, don't do anything
		{
			continue
		}
		else if ( remainingRespawnsForPlayer >= remainingRespawnsToSubtract ) // This player has enough respawns to subtract all we need, just subtract from them and break out
		{
			SpawnSquadSkyDive_AddRespawnsForPlayer( teammate, ( remainingRespawnsToSubtract * -1 ) )
			break
		}
		else // This player only has enough respawns to cover some of the respawns we are subtracting, subtract those and then try with the next player
		{
			SpawnSquadSkyDive_AddRespawnsForPlayer( teammate, ( remainingRespawnsForPlayer * -1 ) )
			remainingRespawnsToSubtract -= remainingRespawnsForPlayer
		}
	}
}
#endif // SERVER
//END SHARED

#if SERVER
void function SetSquadEliminated( int team )
{
	array<entity> players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.SQUAD_ELIMINATED )
	}
}
#endif // SERVER

#if SERVER && DEV
void function DEV_DrawGroupSkyDiveSpawnLocations()
{
	AssertIsNewThread()

	while( true )
	{
		foreach( point in file.spawnPoints )
		{
			DrawAngledBox( point.GetOrigin(), point.GetAngles(), <-16, -16, 0>, <16, 16, 72>, COLOR_GREEN, true, 1.1 )
			DebugDrawArrow( point.GetOrigin(), point.GetOrigin() + AnglesToForward( point.GetAngles() ) * 16, 8, COLOR_GREEN, true, 1.1 )
		}
		wait 1
	}
}
#endif // SERVER

#if SERVER
void function SquadSpawnSkydive_SetupDeadPlayerForRespawn( entity player, entity attacker, var damageInfo )
{
	int team = player.GetTeam()

	// If we are sharing a pool of spawns, see how many spawns are remaining for the whole squad
	int remainingSpawns = SpawnGroupSkydive_ShouldTeamHavePoolOfRespawns() ? SpawnSquadSkyDive_GetRemainingRespawnsForAllPlayersInSquad( team ) : GetRemainingRespawnsForPlayer( player )

	                          
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_STRIKEOUT ) && Strikeout_IsPlayerRespawnDisabled (player) )
			remainingSpawns = 0
       

	                               
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) && Sh_Respawn_Token_IsPlayerRespawnDisabled( player ) )
			remainingSpawns = 0
       

                              
                                                                                                                        
                      
       

	if ( remainingSpawns == 0 )
	{
		player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.PLAYER_ELIMINATED )
		if( SpawnGroupSkydive_IsSquadEliminated( team ) || SpawnGroupSkydive_ShouldTeamHavePoolOfRespawns() ) // If we are pooling lives together, make sure all members of the squad are set to eliminated if the squad is out of spawns
			SetSquadEliminated( team )
	}
	else
	{
		player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_RESPAWN )
		player.SetPlayerNetTime( "respawnStatusEndTime", Time() + GetDeathCamLength( player ) + SpawnGroupSkydive_GetSquadSpawnDelay( team ) )
		player.SetPlayerNetTime( "hackStartTime", Time() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_RespawnPodStarted", player.GetPlayerNetTime( "respawnStatusEndTime" ) )

		// If we are sharing a pool of spawns, subtract remaining spawns from the whole squad
		if ( SpawnGroupSkydive_ShouldTeamHavePoolOfRespawns() )
			SpawnSquadSkyDive_SubtractRespawnsFromSquad( team, 1 )
		else
			SpawnSquadSkyDive_AddRespawnsForPlayer( player, -1 )

		// Determine if the player should respawn now or wait for the whole squad to be ready
		bool shouldTriggerSpawn = false
		if ( file.ShouldRespawnPlayerOrSquad_Callback != null )
			shouldTriggerSpawn = file.ShouldRespawnPlayerOrSquad_Callback( player )
		else
			shouldTriggerSpawn = SpawnGroupSkydive_IsSquadWaitingRespawn( team )

		if ( shouldTriggerSpawn )
		{
			// Determine which players should respawn together
			array< entity > playersToSpawn = GetPlayerArrayOfTeam( team )
			if ( file.GetArrayOfPlayersToRespawn_Callback != null )
				playersToSpawn = file.GetArrayOfPlayersToRespawn_Callback( player )

			// for normal spawns, we spawn invidual teams together
			// if *all* dead players are spawning together, just ignore teams
			if ( SpawnGroupSkydive_ShouldAllDeadPlayersSpawnTogether() )
			{
				foreach ( entity playerToSpawn in playersToSpawn )
				{
					file.teamsWaitingToRespawnArrays[ RESPAWN_ALL_DEAD_PLAYERS_TOGETHER_SPAWNGROUP_IDX ].append( playerToSpawn )
				}
			}
			else
			{
				if ( !( team in file.teamsWaitingToRespawnArrays ) )
				{
					file.teamsWaitingToRespawnArrays[ team ] <- []
				}

				foreach ( entity playerToSpawn in playersToSpawn )
				{
					file.teamsWaitingToRespawnArrays[ team ].append( playerToSpawn )
				}
			}
		}
	}
}
#endif // SERVER

#if SERVER
bool function IsInRespawnDelay( int team )
{
	return file.teamsInRespawnDelay.contains( team )
}
#endif

#if SERVER
array< entity > function GetTeamPlayersToRespawn( entity player, int team )
{
	array< entity > teamPlayersToRespawn = [ player ]
	array< entity > playersToRemove = []
	foreach ( entity spawngroupPlayer in file.teamsWaitingToRespawnArrays[ team ] )
	{
		if ( player == spawngroupPlayer )
			continue

		if ( IsValidPlayer( spawngroupPlayer ) )
			teamPlayersToRespawn.append( spawngroupPlayer )
		else
			playersToRemove.append( spawngroupPlayer )

		if ( teamPlayersToRespawn.len() == MAX_NUM_PLAYERS_PER_SPAWNGROUP )
			break
	}

	foreach ( entity spawnPlayer in teamPlayersToRespawn )
	{
		file.teamsWaitingToRespawnArrays[ team ].removebyvalue( spawnPlayer )

		// Resets pre-jump player vars that are usually set once per game when players are being put in the jump ship,
		// but should be getting reset every drop. See Survival_PutPlayerInPlane for where these vars are initially set.
		spawnPlayer.SetPlayerNetBool( "isJumpingWithSquad", true )
		spawnPlayer.ClearInvulnerable()
	}

	foreach ( entity spawnPlayer in playersToRemove )
	{
		file.teamsWaitingToRespawnArrays[ team ].removebyvalue( spawnPlayer )
	}

	return teamPlayersToRespawn
}
#endif

#if SERVER
entity function GetDiveLeader( array< entity > teamPlayersToRespawn )
{
	Assert( teamPlayersToRespawn.len() > 0, "teamPlayersToRespawn is empty." )
	return teamPlayersToRespawn.getrandom()
}
#endif

#if SERVER
const int MAX_NUM_PLAYERS_PER_SPAWNGROUP = 6
const float SQUAD_SPAWN_SKYDIVE_RESPAWN_DELAY_DEFAULT = 0.5
void function SquadSpawnSkydive_TryRespawnFlaggedPlayer( entity player )
{
	int spawngroupTeam
	if ( SpawnGroupSkydive_ShouldAllDeadPlayersSpawnTogether() )
	{
		// if we're spawning everyone together, we just lump everyone in the same "team"
		spawngroupTeam = RESPAWN_ALL_DEAD_PLAYERS_TOGETHER_SPAWNGROUP_IDX
	}
	else
	{
		spawngroupTeam = player.GetTeam()
	}

	if ( file.ShouldRespawnPlayerOrSquad_Callback != null )
	{
		if ( !file.ShouldRespawnPlayerOrSquad_Callback( player ) )
			return
	}
	else if ( !SpawnGroupSkydive_IsSquadWaitingRespawn( spawngroupTeam ) )
	{
		return
	}

	if ( GetGameState() != eGameState.Playing )
		return

	// the player is removed from the array when they are being respawned. We do this check in order to prevent the server from respawning a player that is in the process of being respawned
	if ( !file.teamsWaitingToRespawnArrays[spawngroupTeam].contains( player ) )
		return

	if ( SpawnGroupSkydive_UseSquadSpawnDelay() )
	{
		if ( IsInRespawnDelay( spawngroupTeam ) )
		{
			float minWaitTime = SpawnGroupSkydive_MinSpawnWaitTime() + Time()

			array< entity > playersToSpawn = file.teamsWaitingToRespawnArrays[ spawngroupTeam ]
			float minEndTime = playersToSpawn[0].GetPlayerNetTime( "respawnStatusEndTime" )
			bool isWaitTooShort = false
			foreach ( playerToSpawn in playersToSpawn )
			{
				if ( !IsValid( playerToSpawn ) || playerToSpawn == player )
					continue

				float respawnEndTime = playerToSpawn.GetPlayerNetTime( "respawnStatusEndTime" )

				if ( minWaitTime > respawnEndTime )
				{
					isWaitTooShort = true
					break
				}

				minEndTime = min( minEndTime, respawnEndTime )
			}

			if ( isWaitTooShort )
			{
				player.SetPlayerNetTime( "respawnStatusEndTime", minWaitTime )
				foreach ( playerToSpawn in playersToSpawn )
				{
					if ( IsValid( playerToSpawn ) )
						playerToSpawn.Signal( "SpawnSquadSkyDive_PlayerWaitingRespawnInterrupt" )
				}

				thread SquadSpawnSkydive_RespawnPlayersAfterDelay_Thread( player, spawngroupTeam )
			}
			else
			{
				player.SetPlayerNetTime( "respawnStatusEndTime", minEndTime )
			}
		}
		else
		{
			thread SquadSpawnSkydive_RespawnPlayersAfterDelay_Thread( player, spawngroupTeam )
		}

		return
	}

	array< entity > teamPlayersToRespawn = GetTeamPlayersToRespawn( player, spawngroupTeam )

	entity leaderPlayer = GetDiveLeader( teamPlayersToRespawn )

	SetJumpmaster( spawngroupTeam, leaderPlayer )
	// Currently we only ever set this in the dropship logic. Since there's a possibility for multiple teammates
	// to be assigned jumpmaster across their 3 jumps, we should be setting this before each jump.
	leaderPlayer.SetPersistentVar( "lastGameWasJumpMaster", true )

	float squadSpawnSkydiveRespawnDelay = GetPlaylistVarFloat( GetCurrentPlaylistName(), "squad_spawn_skydive_respawn_delay", SQUAD_SPAWN_SKYDIVE_RESPAWN_DELAY_DEFAULT )

	thread SquadSpawnSkydive_ActuallyRespawnPlayers_Thread( leaderPlayer, teamPlayersToRespawn, squadSpawnSkydiveRespawnDelay )
}
#endif // SERVER

#if SERVER
void function SquadSpawnSkydive_RespawnPlayersAfterDelay_Thread( entity player, int spawngroupTeam )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "SpawnSquadSkyDive_PlayerWaitingRespawnInterrupt" )
	float waitTime = player.GetPlayerNetTime( "respawnStatusEndTime" ) - Time()
	array< entity > playersToSpawn = file.teamsWaitingToRespawnArrays[ spawngroupTeam ]
	file.teamsInRespawnDelay.append( spawngroupTeam )

	OnThreadEnd
	(
		function() : ( spawngroupTeam )
		{
			if ( file.teamsInRespawnDelay.contains( spawngroupTeam ) )
				file.teamsInRespawnDelay.fastremovebyvalue( spawngroupTeam )
		}
	)

	foreach ( playerToSpawn in playersToSpawn )
	{
		if ( playerToSpawn != player && IsValid( playerToSpawn ) )
			playerToSpawn.SetPlayerNetTime( "respawnStatusEndTime", Time() + waitTime )
	}

	wait waitTime

	if ( !IsValid( player ) )
		return

	array< entity > teamPlayersToRespawn = GetTeamPlayersToRespawn( player, spawngroupTeam )

	entity leaderPlayer = GetDiveLeader( teamPlayersToRespawn )

	float squadSpawnSkydiveRespawnDelay = GetPlaylistVarFloat( GetCurrentPlaylistName(), "squad_spawn_skydive_respawn_delay", SQUAD_SPAWN_SKYDIVE_RESPAWN_DELAY_DEFAULT )

	thread SquadSpawnSkydive_ActuallyRespawnPlayers_Thread( leaderPlayer, teamPlayersToRespawn, squadSpawnSkydiveRespawnDelay )
}
#endif // SERVER

#if SERVER
void function SquadSpawnSkydive_ActuallyRespawnPlayers_Thread( entity leaderPlayer, array< entity > playersToSpawn, float delay )
{
	Assert( IsNewThread() )
	wait delay

	entity lastPlayerKilled = GetLastPlayerKilled( playersToSpawn )

	int defaultRealm = Survival_Loot_GetDefaultRealm()
	vector safeZonePos =  SURVIVAL_GetSafeZoneCenter( defaultRealm )
	vector deathFieldCenter
	if ( SURVIVAL_DeathFieldIsValid( defaultRealm ) )
	{
		entity spawnPoint = SURVIVAL_GetDeathField( defaultRealm )
		deathFieldCenter = spawnPoint.GetOrigin()
	}
	else
	{
		deathFieldCenter = safeZonePos
	}

	vector spawnOrigin
	if ( IsValid( lastPlayerKilled ) )
	{
		entity spawnPoint = FindSpawnPoint( lastPlayerKilled )
		spawnOrigin = spawnPoint.GetOrigin()
	}
	else
	{
		spawnOrigin = deathFieldCenter
	}

	if ( !SURVIVAL_PosInsideDeathField( defaultRealm, spawnOrigin ) )
	{
		spawnOrigin = deathFieldCenter
	}

	spawnOrigin.z = GetJumpHeight()
	vector spawnAngles = VectorToAngles( safeZonePos - spawnOrigin )

	thread SpawnPlayersInSkydive( playersToSpawn, leaderPlayer, spawnOrigin, spawnAngles, ePlayerMatchState.NORMAL )

	foreach ( player in playersToSpawn )
	{
		if ( !IsValid( player ) )
			continue

		ScreenFadeFromBlack( player, 1.0, 0.5 )

		if ( !SURVIVAL_PosInsideDeathField( Survival_Loot_GetDefaultRealm(), spawnOrigin ) )
			Warning( "%s() - Respawn point outside deathfield: %s", FUNC_NAME(), VectorToString( spawnOrigin ) )

		if ( SpawnSquadSkyDive_GetRemainingRespawnsForAllPlayersInSquad( leaderPlayer.GetTeam() ) == 0 )
			PlayBattleChatterLineToSpeakerAndTeam( leaderPlayer, "bc_respawnLastStrike" )
		else
			PlayBattleChatterLineToSpeakerAndTeam( player, "bc_returnFromRespawn" )
	}
}
#endif // SERVER

#if SERVER
void function SpawnSquadSkyDive_RespawnAllWaitingPlayers()
{
	if ( GetGameState() != eGameState.Playing )
		return

	// stop all waiting respawn
	foreach ( team, players in file.teamsWaitingToRespawnArrays )
	{
		foreach( player in players )
			player.Signal( "SpawnSquadSkyDive_PlayerWaitingRespawnInterrupt" )
	}

	file.teamsInRespawnDelay.clear()

	foreach ( team, players in file.teamsWaitingToRespawnArrays )
	{
		while ( players.len() > 0 )
		{
			if ( IsValid( players[0] ) )
			{
				array< entity > teamPlayersToRespawn = GetTeamPlayersToRespawn( players[0], team )
				entity leaderPlayer                  = GetDiveLeader( teamPlayersToRespawn )

				SetJumpmaster( team, leaderPlayer )
				// Currently we only ever set this in the dropship logic. Since there's a possibility for multiple teammates
				// to be assigned jumpmaster across their 3 jumps, we should be setting this before each jump.
				leaderPlayer.SetPersistentVar( "lastGameWasJumpMaster", true )

				float squadSpawnSkydiveRespawnDelay = GetPlaylistVarFloat( GetCurrentPlaylistName(), "squad_spawn_skydive_respawn_delay", SQUAD_SPAWN_SKYDIVE_RESPAWN_DELAY_DEFAULT )

				thread SquadSpawnSkydive_ActuallyRespawnPlayers_Thread( leaderPlayer, teamPlayersToRespawn, squadSpawnSkydiveRespawnDelay )
			}
			else
			{
				players.fastremove( 0 )
			}
		}
	}
}
#endif

#if SERVER
entity function GetLastPlayerKilled( array< entity > players )
{
	// base off last killed player
	bool didSetLastPlayerKilled = false
	entity lastPlayerKilled = null
	float mostRecentTime
	foreach ( player in players )
	{
		if ( !IsValid( player ) )
			continue

		float playerLastDeathTime = player.p.lastDeathTime

		if ( !didSetLastPlayerKilled || playerLastDeathTime > mostRecentTime )
		{
			lastPlayerKilled = player
			mostRecentTime = playerLastDeathTime
			didSetLastPlayerKilled = true
		}
	}
	return lastPlayerKilled
}
#endif // SERVER

#if SERVER
const int MAX_ATTEMPTS_TO_FIND_SPAWN_POINT = 10
void function OnDeathFieldStartShrink( table<int,DeathFieldData> deathFieldData )
{
	//exclude ones outside circle, etc
	array <entity> spawnPointsInsideCircle
	DeathFieldData data = deathFieldData[ Survival_Loot_GetDefaultRealm() ]
	float deathFieldRadius = data.endRadius
	vector deathFieldCenter = data.nextCenter

	float maxDist = deathFieldRadius - MIN_SPAWN_DIST_FROM_RING
	float maxDistSqr = maxDist * maxDist

	foreach ( entity point in file.spawnPoints  )
	{
		if ( !IsValid( point ) )
			continue
		
		float distSqr = Length2DSqr( point.GetOrigin() - deathFieldCenter )
		if ( distSqr < maxDistSqr )
			spawnPointsInsideCircle.append( point )
	}

	// add center of the ring as a spawn point if there is no vaild spawn point
	if ( spawnPointsInsideCircle.len() == 0 )
	{
		int defaultRealm = Survival_Loot_GetDefaultRealm()
		entity spawnPoint = AddSpawnPointOnSafeSpot( SURVIVAL_GetSafeZoneCenter( defaultRealm ) )
		spawnPointsInsideCircle.append( spawnPoint )
	}

	RemoveAllOtherSpawnpoints( spawnPointsInsideCircle )
	file.spawnPoints = svSpawnGlobals.allNormalSpawnpoints
}
#endif //SERVER

#if SERVER
const vector SPAWNPOINT_BOUND_MINS = <-16, -16, 0>
const vector SPAWNPOINT_BOUND_MAXS = <16, 16, 32>
entity function AddSpawnPointOnSafeSpot( vector spawnPointPos )
{
	//spawnPointPos = SPL_GetClosestPosition ( spawnPointPos )
	entity spawnPoint = CreateEntity( "info_spawnpoint_human" )
	spawnPoint.SetOrigin( spawnPointPos )
	spawnPoint.SetBoundingBox( SPAWNPOINT_BOUND_MINS, SPAWNPOINT_BOUND_MAXS )
	PutEntityInSafeSpot( spawnPoint, null, null, spawnPointPos, spawnPointPos )
	spawnPoint.SetAngles( <0, 0, 0> )
	spawnPoint.kv.teamnumber = 0
	spawnPoint.e.isGroupSkydiveSpawnPoint = true
	DispatchSpawn( spawnPoint )
	file.spawnPoints = svSpawnGlobals.allNormalSpawnpoints
	Assert( IsValid( spawnPoint ) )
	return spawnPoint
}
#endif

#if SERVER
bool function CanPlayerStillRespawn( entity player )
{
	int respawnStatus = player.GetPlayerNetInt( "respawnStatus" )
	return respawnStatus != eRespawnStatus.PLAYER_ELIMINATED && respawnStatus != eRespawnStatus.SQUAD_ELIMINATED
}
#endif //SERVER

#if SERVER
bool function SpawnGroupSkydive_IsSquadWaitingRespawn( int team )
{
	array<entity> players = GetPlayerArrayOfTeam( team )
	foreach( player in players )
	{
		if( player.GetPlayerNetInt( "respawnStatus" ) != eRespawnStatus.WAITING_FOR_RESPAWN )
			return false
	}

	return true
}
#endif //SERVER

#if SERVER
int function SpawnGroupSkydive_GetNumTeamsRemaining()
{
	array<entity> players = GetPlayerArray()
	array<int> results
	foreach ( entity p in players )
	{
		if ( p.IsConnectionActive() && ( IsAlive( p ) || CanPlayerStillRespawn( p ) ) )
		{
			int team = p.GetTeam()
			if ( !results.contains( team ) )
				results.append( team )
		}
	}
	return results.len()
}
#endif //SERVER

#if SERVER
int function SpawnGroupSkydive_GetNumAlliancesRemaining()
{
	return SpawnGroupSkydive_GetRemainingAlliances().len()
}
#endif //SERVER

#if SERVER
array < int > function SpawnGroupSkydive_GetRemainingAlliances()
{
	array<entity> players = GetPlayerArray()
	array<int> results
	foreach ( entity p in players )
	{
		if ( p.IsConnectionActive() && ( IsAlive( p ) || CanPlayerStillRespawn( p ) ) )
		{
			int alliance = AllianceProximity_GetAllianceFromTeam( p.GetTeam() )
			if ( !results.contains( alliance ) )
				results.append( alliance )
		}
	}

	return results
}
#endif //SERVER

#if SERVER
bool function SpawnGroupSkydive_IsSquadEliminated( int team )
{
	array<entity> players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		if ( IsAlive( player ) || CanPlayerStillRespawn( player ) )
		{
			return false
		}
	}

	return true
}
#endif //SERVER

#if SERVER
float function GetJumpHeight()
{
	return GetCurrentPlaylistVarFloat( "spawn_group_skydive_height", SURVIVAL_GetPlaneHeight() )
}
#endif //SERVER

#if SERVER
bool function SpawnGroupSkydive_UseSquadSpawnDelay()
{
	return GetCurrentPlaylistVarBool( "spawn_group_skydive_use_squad_spawn_delay", false )
}
#endif

float function SpawnGroupSkydive_GetSquadSpawnDelay( int team )
{
	float spawnDelay = GetCurrentPlaylistVarFloat( "respawn_cooldown", 5.0 )

	if ( file.GetSquadSpawnDelay_Callback != null )
		spawnDelay = file.GetSquadSpawnDelay_Callback( team )

	return spawnDelay
}

// Allow other modes to set different functions to grab the spawn delay
void function SpawnGroupSkydive_SetCallback_GetSquadSpawnDelay( float functionref( int ) func )
{
	Assert( file.GetSquadSpawnDelay_Callback == null )
	file.GetSquadSpawnDelay_Callback = func
}

#if SERVER
// Allow other modes to set different functions to check if a player is ready to respawn
void function SpawnGroupSkydive_SetCallback_CanRespawnPlayerOrSquad( bool functionref( entity ) func )
{
	Assert( file.ShouldRespawnPlayerOrSquad_Callback == null )
	file.ShouldRespawnPlayerOrSquad_Callback = func
}
#endif //SERVER

#if SERVER
// Allow other modes to set different functions to grab the array of players to spawn together
void function SpawnGroupSkydive_SetCallback_GetSquadPlayersToRespawn( array< entity > functionref( entity ) func )
{
	Assert( file.GetArrayOfPlayersToRespawn_Callback == null )
	file.GetArrayOfPlayersToRespawn_Callback = func
}
#endif //SERVER

// Instead of players having individual lives, should the team ( squad ) have a shared pool of lives that get depleted when a player respawns
bool function SpawnGroupSkydive_ShouldTeamHavePoolOfRespawns()
{
	return GetCurrentPlaylistVarBool( "spawn_group_skydive_use_team_lives_pool", false )
}

// Should we respawn all dead players together at the same time?
// The way this works is: A player dies, the SpawnSquadSkyDive thread starts with the defined respawn wait
// Any players that die before the above player respawns are added to the group of players to respawn with the above player
// Once the wait time is over, all these dead players spawn together
// When someone dies now, they start the process again
bool function SpawnGroupSkydive_ShouldAllDeadPlayersSpawnTogether()
{
	return GetCurrentPlaylistVarBool( "spawn_group_skydive_spawn_all_players_together", false )
}

// This is only used if SpawnGroupSkydive_ShouldAllDeadPlayersSpawnTogether() returns true
// What is the minimum time players need to wait to respawn
// If the group of players waiting to respawn has less time remaining to respawn than this time we start a new group of players to spawn instead of adding to the existing group
float function SpawnGroupSkydive_MinSpawnCooldownTime()
{
	return GetCurrentPlaylistVarFloat( "spawn_group_skydive_min_respawn_cooldown", 1.0 )
}

#if SERVER
// This is only used if SpawnGroupSkydive_UseSquadSpawnDelay() returns true
// If the teammate is waiting to respawn and remaining time is smaller than this time, we wait this time together
float function SpawnGroupSkydive_MinSpawnWaitTime()
{
	return GetCurrentPlaylistVarFloat( "spawn_group_skydive_min_respawn_wait", 5.0 )
}
#endif

#if SERVER
bool function SpawnGroupSkydive_UseCustomRateFunction()
{
	return GetCurrentPlaylistVarBool( "spawn_group_skydive_use_custom_rate_function", false )
}
#endif
 