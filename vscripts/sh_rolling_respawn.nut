const string READY_TO_SPAWN = "#PL_READY_TO_SPAWN"
const asset RESPAWN_BEACON_MOBILE_MODEL = $"mdl/props/pathfinder_beacon_radar/pathfinder_beacon_radar_animated.rmdl"



struct {
	#if SERVER
		table< entity, array< entity > > spawnRegions
		table< entity, entity >          spawnWaypointToSpawnRegion
		array< entity >                  respawnWaypoints
		entity                           resetLocation

		//table < entity, int >	spawnRegionsToLiveDropships
		array< void functionref(entity) > Callbacks_OnPlayerSetForRespawn
		array< void functionref(entity) > Callbacks_OnPlayerRespawnStarted
		array< void functionref(entity) > Callbacks_OnPlayerRespawnFinished

		bool                 		shouldStoreUltimateCharge = false
		table< entity, int > 		playerToStoredUltimateCharge
		table< entity, ItemFlavor >	playerUltimateChargeValidation
	#endif
} file





global function RollingRespawn_Init
global function RollingRespawn_RegisterNetworking

#if SERVER
global function RollingRespawn_SetPlayerForRespawnAfterDelay
global function RollingRespawn_AddCallback_OnPlayerSetForRespawn
global function RollingRespawn_AddCallback_OnPlayerRespawnStarted
global function RollingRespawn_AddCallback_OnPlayerRespawnFinished

global function ClientCallback_TryRespawnPlayer

const string ROLLING_RESPAWN_MOVER_SCRIPTNAME = "rolling_respawn_mover"
#endif

#if CLIENT
global function RollingRespawn_TriggerPlayerRespawn

global function ServerCallback_CL_CreateSpawnRegionRUI
global function ServerCallback_CL_PlayerReadyToSpawn
global function ServerCallback_CL_PlayerRespawned

global function ServerCallback_CL_ShowRespawnUI
global function ServerCallback_CL_HideRespawnUI
#endif




void function RollingRespawn_Init()
{
#if SERVER || CLIENT
	if ( GetRespawnStyle() != eRespawnStyle.ROLLING_RESPAWN )
		return

	Remote_RegisterServerFunction( "ClientCallback_TryRespawnPlayer", "typed_entity", "player_waypoint" )
#endif

	#if SERVER
		if ( GetCurrentPlaylistVarBool( "rolling_respawn_store_ultimate_charge", false ) )
		{
			file.shouldStoreUltimateCharge = true
			AddCallback_OnPlayerKilled( StoreUltimateChargeForPlayer )
		}

		AddCallback_GameStateEnter( eGameState.Playing, OnGameStatePlaying )
	#endif

	#if CLIENT
		AddCallback_OnPingSpawnRequest( RollingRespawn_TriggerPlayerRespawn )
		AddCallback_OnCharacterSelectMenuOpened( Callback_HideRespawnOverlay )
		AddCallback_OnCharacterSelectMenuClosed( Callback_ShowRespawnOverlay )
	#endif
}


void function RollingRespawn_RegisterNetworking()
{
	Remote_RegisterClientFunction( "ServerCallback_CL_CreateSpawnRegionRUI", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_CL_PlayerReadyToSpawn" )
	Remote_RegisterClientFunction( "ServerCallback_CL_PlayerRespawned" )

	Remote_RegisterClientFunction( "ServerCallback_CL_ShowRespawnUI", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_CL_HideRespawnUI", "entity" )
}

#if SERVER
void function RollingRespawn_AddCallback_OnPlayerSetForRespawn( void functionref(entity) callbackFunc )
{
	file.Callbacks_OnPlayerSetForRespawn.append( callbackFunc )
}

void function RollingRespawn_AddCallback_OnPlayerRespawnStarted( void functionref(entity) callbackFunc )
{
	file.Callbacks_OnPlayerRespawnStarted.append( callbackFunc )
}

void function RollingRespawn_AddCallback_OnPlayerRespawnFinished( void functionref(entity) callbackFunc )
{
	file.Callbacks_OnPlayerRespawnFinished.append( callbackFunc )
}
#endif





//////////////////////////////////////////
// Functions for setting up  respawning //
//////////////////////////////////////////
#if SERVER
void function OnGameStatePlaying()
{
	SetupSpawnPoints()
	CreateRespawnUI()

	foreach ( player in GetConnectedPlayers() )
		RemoveRespawnUI( player )
}

void function SetupSpawnPoints()
{
	//todo (my): spawn points aren't named generally which is bad. This allows the script to work without a map recompile but should change in map eventually
	array<entity> winterExpressSpawnRegions = GetEntArrayByScriptName( "winter_express_spawn_point" )
	array<entity> generalSpawnRegions       = GetEntArrayByScriptName( "rolling_respawn_point" )

	generalSpawnRegions.extend( winterExpressSpawnRegions )

	foreach( region in generalSpawnRegions )
	{
		array< entity > spawnPoints = region.GetLinkEntArray()
		file.spawnRegions[region] <- spawnPoints
		printf( "ROLLING RESPAWN: Spawn Region has " + spawnPoints.len() + " points" )

		foreach ( player in GetConnectedPlayers() )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_CL_CreateSpawnRegionRUI", region )
		}

		//file.spawnRegionsToLiveDropships[region] <- 0
	}

	string coordinateData = GetCurrentPlaylistVarString( "rolling_respawn_reset_location", "" )
	array<string> coordinates = GetTrimmedSplitString( coordinateData, "," )
	vector spawnLocation      = <0, 0, 0> //<29489.4902, 28203.8477, 15288.873> //default

	if ( coordinateData != "" )
	{
		Assert( coordinates.len() == 3, "ROLLING RESPAWN: Playlist Coordinates not properly formatted (x,y,z)" )
		float x = float(coordinates[0])
		float y = float(coordinates[1])
		float z = float(coordinates[2])
		spawnLocation = <x, y, z>
	}

	entity resetPosition = CreatePropDynamicLightweight( RESPAWN_BEACON_MOBILE_MODEL, spawnLocation )
	file.resetLocation = resetPosition
}

void function CreateRespawnUI()
{
	foreach ( region, pointArray in file.spawnRegions )
	{
		entity waypoint = CreateWaypoint_BasicEntLocation( region, ePingType.SPAWN_REGION )
		file.spawnWaypointToSpawnRegion[waypoint] <- region
		file.respawnWaypoints.append( waypoint )

		waypoint.SetParent( region )
		waypoint.SetLocalOrigin( <0, 0, 72> )
	}
}
#endif







//////////////////////////////////////////
// Functions for controlling respawning //
//////////////////////////////////////////
#if SERVER
//Purpose: When player dies, handle death and set player for respawn
void function RollingRespawn_SetPlayerForRespawnAfterDelay( entity player, vector deathPos )
{
	EndSignal( player, "OnDestroy" )

	float delay = GetCurrentPlaylistVarFloat( "rolling_respawn_delay", 30.0 )

	player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_DROPPOD )
	player.SetPlayerNetTime( "respawnStatusEndTime", Time() + delay )
	player.SetPlayerNetTime( "hackStartTime", Time() )
	Remote_CallFunction_NonReplay( player, "ServerCallback_RespawnPodStarted", player.GetPlayerNetTime( "respawnStatusEndTime" ) )

	OnThreadEnd( void function() : ( player ) {
		if ( IsValid( player ) )
		{
			if ( GetRespawnStatus( player ) == eRespawnStatus.WAITING_FOR_DROPPOD )
				player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.NONE )
			//player.p.respawnPod = null
			player.p.respawnPodLanded = false
		}
	} )

	wait delay

	if ( IsAlive( player ) )
		return

	ShowRespawnUI( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_CL_PlayerReadyToSpawn" )
	Survival_SetInventoryEnabled( player, false )

	player.StopObserverMode()
	ClearPlayerEliminated( player )
	player.p.respawnPodLanded = true // pretend this is a valid survival respawn via dropship, get match participation errors without it

	DecideRespawnPlayer( player, false )

	vector forwardVector = (SURVIVAL_GetDeathFieldCenter( Survival_GetPlayerRealm( player ) )) - file.resetLocation.GetOrigin()

	player.SetOrigin( file.resetLocation.GetOrigin() + < 0, 0, -500> )
	player.SnapEyeAngles( VectorToAngles( forwardVector ) )
	player.SetParent( file.resetLocation )

	player.HidePlayer()
	player.NotSolid()
	player.MakeInvisible()
	player.DisableWeaponTypes( WPT_MELEE )

	player.RemoveFromAllRealms()
	PutPlayerInDefaultRealms( player )

	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	PlayerMatchState_Set( player, ePlayerMatchState.SKYDIVE_PRELAUNCH )
	GivePlayerSettingsMods( player, [ "disable_targetinfo" ] )

	foreach ( func in file.Callbacks_OnPlayerSetForRespawn )
		func( player )
}


//Purpose: Handle Client trying to Respawn Player from Respawn State
void function ClientCallback_TryRespawnPlayer( entity player, entity waypoint )
{
	if ( !IsValid( waypoint ) )
	{
		Warning( "ROLLING RESPAWN: Trying to spawn on invalid waypoint" )
		return
	}

	entity spawnRegion = file.spawnWaypointToSpawnRegion[waypoint]

	if ( !IsValid( spawnRegion ) )
	{
		Warning( "ROLLING RESPAWN: Trying to spawn in invalid spawn region" )
		return
	}

	if ( !IsValidPlayer( player ) )
	{
		Warning( "ROLLING RESPAWN: Trying to respawn an invalid player" )
		return
	}

	thread RollingRespawn_RespawnPlayer( player, spawnRegion )
}

//Purpose: Place player back into match from respawn menu when respawning
void function RollingRespawn_RespawnPlayer( entity player, entity spawnRegion )
{
	//select spawn point to spawn at
	array<int> teamValues = GetAllValidPlayerTeams()

	int teamIndex = 0

	for ( int i = 0; i < teamValues.len(); i++ )
	{
		if ( teamValues[i] == player.GetTeam() )
		{
			teamIndex = i
			break
		}
	}

	int spawnIndex = (teamIndex * GetExpectedSquadSize( player )) + (player.GetTeamMemberIndex())
	Assert ( spawnIndex < file.spawnRegions[spawnRegion].len(), "ROLLING RESPAWN: Spawn Region does not have enough defined spawn points ( numSquads * squadSize) " )

	foreach( func in file.Callbacks_OnPlayerRespawnStarted )
		func( player )

	printf( "ROLLING RESPAWN: Respawning Player " + player.GetPlayerName() )
	player.ClearInvulnerable()
	player.ClearParent()

	ClearPlayerPlaneViewMode( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_ClearHints" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_CL_PlayerRespawned" )

	entity spawnMover = CreateScriptMover( ROLLING_RESPAWN_MOVER_SCRIPTNAME, file.resetLocation.GetOrigin(), player.GetAngles() )
	player.SetParent( spawnMover )

	entity spawnPoint = file.spawnRegions[ spawnRegion ][ spawnIndex ]
	spawnMover.NonPhysicsMoveTo( spawnPoint.GetOrigin() + <0, 0, 1000>, 2.0, 0.4, 0.4 )

	string entityFaceDirection = GetCurrentPlaylistVarString( "rolling_respawn_spawn_towards_entity", "" )
	vector faceTowards
	if ( entityFaceDirection != "" )
		faceTowards = GetEntByScriptName( entityFaceDirection ).GetOrigin()
	else
		faceTowards = SURVIVAL_GetDeathFieldCenter( Survival_GetPlayerRealm( player ) )

	vector playerToEntity = faceTowards - spawnPoint.GetOrigin()
	vector forwardVector  = VectorToAngles( playerToEntity )
	spawnMover.NonPhysicsRotateTo( forwardVector, 2.0, 0.4, 0.4 )
	ViewConeZeroInstant( player )
	RemoveRespawnUI( player )

	wait GetCurrentPlaylistVarFloat( "rolling_respawn_fly_time", 2.2 )

	ViewConeFree( player )
	player.SnapEyeAngles( forwardVector )
	player.ClearParent()
	spawnMover.Destroy()

	PlayerMatchState_Set( player, ePlayerMatchState.NORMAL )
	player.MakeVisible()
	Survival_SetInventoryEnabled( player, true )
	player.EnableWeaponTypes( WPT_MELEE )

	foreach( func in file.Callbacks_OnPlayerRespawnFinished )
		func( player )

	if ( file.shouldStoreUltimateCharge )
		RestoreChargesForPlayer( player )
}

#endif








//////////////////////////////////////////
// Functions for controlling respawn UI //
//////////////////////////////////////////
#if SERVER
void function ShowRespawnUI( entity player )
{
	foreach ( waypoint in file.respawnWaypoints )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CL_ShowRespawnUI", waypoint )
	}
}

void function RemoveRespawnUI( entity player )
{
	foreach( waypoint in file.respawnWaypoints )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CL_HideRespawnUI", waypoint )
	}
}
#endif

#if CLIENT
void function Callback_HideRespawnOverlay()
{
	//placeholder for hiding respawn UI
}

void function Callback_ShowRespawnOverlay()
{
	//placeholder for showing respawn UI
}

void function RollingRespawn_TriggerPlayerRespawn( entity player, entity waypoint )
{
	Remote_ServerCallFunction( "ClientCallback_TryRespawnPlayer", waypoint )
}

void function ServerCallback_CL_PlayerReadyToSpawn()
{
	AnnouncementMessageRight( GetLocalClientPlayer(), Localize( READY_TO_SPAWN ), "", < 182, 212, 209 >, $"", 7.0 )
}

void function ServerCallback_CL_PlayerRespawned()
{
	//placeholder callback for the player respawning
}

void function ServerCallback_CL_CreateSpawnRegionRUI( entity spawnRegion )
{
	//placeholder for creating RUI for respawn system
}

void function ServerCallback_CL_ShowRespawnUI( entity waypoint )
{
	Waypoint_ShowOnLocalHud( waypoint )
}

void function ServerCallback_CL_HideRespawnUI( entity waypoint )
{
	Waypoint_HideOnLocalHud( waypoint )
}
#endif