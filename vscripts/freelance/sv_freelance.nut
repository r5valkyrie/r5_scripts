global function ServerInit_Freelance

global function Freelance_RateSpawnpoints
global function Freelance_MissionEnd

global function PVE_CommonPlayerRespawn
////
global function TeamSpawn_SetStartSpawnDisabled
global function TeamSpawn_SetStartSpawnCustom
global function TeamSpawn_SetForcedSpawnpointForTeam
global function TeamSpawn_SetFallbackSpawnpointForTeam
global function TeamSpawn_SetTeamWipe
global function TeamSpawn_SetSpawnOnTeammates
//
global function TeamSpawn_SetKeepInventoryOnRespawn
global function TeamSpawn_GetKeepInventoryOnRespawn
global function TeamSpawn_MarkTeamAsFinishedWithMatchForVictory

global function PlayRespawnedFX
////

global function PlayerHasAnyInventory

global function GiveSpawnLoadout
global function GiveSimplePVELoadout

#if DEVELOPER
global function DEV_Freelance_KillAllAI
global function DEV_Freelance_ToggleOverlay

global function DEV_FreelanceSmoketest
#endif // DEV

void function ServerInit_Freelance()
{
	FlagSet( "ForceStartSpawn" )

	SetTeamRelationshipRulesForPVE()

	////////////////
	////////////////
	////////////////
	GamemodeSurvival_Init()
	////////////////
	////////////////
	////////////////

	// Disabled map ents:
	{
		BlockMapEntityParseCreationOf( "info_target", "apex_screen", "" )					// 950
		BlockMapEntityParseCreationOf( "info_target", "static_loot_tick_spawn", "" )		// 657

		// Loot drone path nodes:
		BlockMapEntityParseCreationOf( "info_target", "loot_drone_path_node", "" )			// 405

		// Training ground stuff:
		//BlockMapEntityParseCreationOf( "info_target", "shooting_range_rotating_target", "" )		// 40
		//BlockMapEntityParseCreationOf( "info_target", "shooting_range_folding_target", "" )		// 20
		//BlockMapEntityParseCreationOf( "prop_dynamic_lightweight", "staging_loot_bin", "" )		// 20

		// Break in case of emergency:
		//BlockMapEntityParseCreationOf( "info_target", "", "info_hover_tank_node" )					// 241
		//BlockMapEntityParseCreationOf( "func_window_hint", "", "" )									// 200
		//BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_survival_flyer_with_corpse" )		//60
	}

	// Circle Cull Controls
	{
		CircleCullClassName( "prop_dynamic" )
		CircleCullClassName( "prop_dynamic_lightweight" )
		CircleCullClassName( "prop_door" )
		CircleCullClassName( "prop_script" )
		CircleCullClassName( "prop_death_box" )
		CircleCullClassName( "trigger_slip" )
		CircleCullClassName( "trigger_no_zipline" )
		CircleCullClassName( "zipline" )
		CircleCullClassName( "zipline_end" )
		CircleCullClassName( "trigger_multiple" )

		//CircleCullKeepScriptName( "leviathan_zone_6" )
		//CircleCullKeepScriptName( "leviathan_zone_9" )
		//CircleCullKeepScriptName( "hatch_bunker_entrance_model_z16" )
		//CircleCullKeepScriptName( "hatch_bunker_exit_model_z16" )
		//CircleCullKeepScriptName( "hatch_bunker_entrance_model_z6" )
		//CircleCullKeepScriptName( "hatch_bunker_exit_model_z6" )
		//CircleCullKeepScriptName( "hatch_bunker_entrance_model_z5" )
		//CircleCullKeepScriptName( "hatch_bunker_exit_model_z5" )
		//CircleCullKeepScriptName( "hatch_bunker_entrance_model_z12" )
		//CircleCullKeepScriptName( "hatch_bunker_exit_model_z12" )
		//CircleCullKeepScriptName( "hatch_bunker_entrance_model_z12_treasure" )
		//CircleCullKeepScriptName( "hatch_bunker_exit_model_z12_treasure" )
		//CircleCullKeepScriptName( "_hover_tank_volume" )

		//CircleCullKeepEditorName( "script_survival_flyer_with_corpse" );
	}

	AddCallback_OnClientConnected( OnPlayerConnected )
	AddCallback_OnClientDisconnected( OnPlayerDisconnected )
	AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	AddCallback_OnPlayerKilled( OnPlayerKilled )

	TeamSpawnLogic_Init()

	NPCGarbageCollection_InitForGameMode()
	PVELoot_InitForGameMode()





	MissionCheckpoints_Init()





	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddCallback_GameStateEnter( eGameState.Prematch, OnGameStateEnterPrematch )
	AddCallback_GameStateEnter( eGameState.Playing, OnGameStateEnterPlaying )
	AddCallback_GameStateEnter( eGameState.Postmatch, OnGameStateEnterPostmatch )
	AddCallback_GameStateEnter( eGameState.Resolution, OnGameStateEnterResolution )
	//CapturePoint_Init() //Any gamemode that uses CapturePoints needs to call this

	FlagClear( "disable_npcs" )

	//
	{
		//FlagSet( "DisableTimeLimit" )
		FlagSet( "DisableScoreLimit" )
		SetTimelimitCompleteFunc( TimeLimitComplete )
	}
}

void function OnGameStateEnterPostmatch()
{
	//
}

int function GetPlayerCount()
{
	array<entity> players = GetPlayerArray()
	int result = players.len()
	return result
}

void function Freelance_RateSpawnpoints( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	if ( spawnpoints.len() == 0 )
		return

	printt( "=== Freelance_RateSpawnpoints ===" )
	foreach ( spawn in spawnpoints )
		DisableSpawnpoint( spawn )

	array<entity> allowedSpawnPoints
	foreach ( int idx, spawn in spawnpoints )
	{
		printt( "  #" + idx + "- Enabling:" + spawn )
		EnableSpawnpoint( spawn )
		float additionalRating = 0.0
		float rating = spawn.CalculateRating( checkclass, team, additionalRating, 0.0 )
		allowedSpawnPoints.append( spawn )
	}

	// fallback
	if ( allowedSpawnPoints.len() == 0 )
	{
		printt( "falling back to whatever spawnpoint")
		foreach ( spawn in spawnpoints )
			EnableSpawnpoint( spawn )
		RateSpawnpoints_Frontline( checkclass, spawnpoints, team, player )
	}
}

bool function TimeLimitComplete()
{
	return false
}

void function OnGameStateEnterPrematch()
{
	if ( Freelance_IsHubLevel() )
		return
}

void function EntitiesDidLoad()
{




	for ( int idx = 0; idx < MAX_TEAMS; ++idx )
	{
		int team = (TEAM_MULTITEAM_FIRST + idx)
		StartTeamSpawningThreadIfNeeded( team )
	}

	if ( !Freelance_IsHubLevel() )
	{






		/////////////////////////////////////////////////
		// Disable resources so we can spawn as needed
		/////////////////////////////////////////////////
		//"Disable" just hides it, removes it from all realms and hibernates it
		//TODO: port these all over to the PvE resource system once we have the mode up and running

		//Jumppad spawns
		DisableAllResourcesByScriptName( "spawner_jump_pad" )

		//Stim gas spawns
		DisableAllResourcesByScriptName( "spawner_stim_gas" )

		//DisableZiplines
		DisableAllResourcesByScriptName( "ziplines_pve" )

		//Disable Harvester Assault resources
		DisableAllResourcesByScriptName( "fx_cableA_generator_swamp_01" )
		DisableAllResourcesByScriptName( "cableA_generator_swamp_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_runoff_west_01" )
		DisableAllResourcesByScriptName( "cableA_generator_runoff_west_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_skulltown_01" )
		DisableAllResourcesByScriptName( "cableA_generator_skulltown_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_bridges_caves_01" )
		DisableAllResourcesByScriptName( "cableA_generator_bridges_caves_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_cascades_hill_base_01" )
		DisableAllResourcesByScriptName( "cableA_generator_cascades_hill_base_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_cascades_hill_base_02" )
		DisableAllResourcesByScriptName( "cableA_generator_cascades_hill_base_02" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_cascades_hill_base_03" )
		DisableAllResourcesByScriptName( "cableA_generator_cascades_hill_base_03" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_repulsor_base_01" )
		DisableAllResourcesByScriptName( "cableA_generator_repulsor_base_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_repulsor_base_02" )
		DisableAllResourcesByScriptName( "cableA_generator_repulsor_base_02" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_repulsor_base_03" )
		DisableAllResourcesByScriptName( "cableA_generator_repulsor_base_03" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_hydro_dam_01" )
		DisableAllResourcesByScriptName( "cableA_generator_hydro_dam_01" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_hydro_dam_02" )
		DisableAllResourcesByScriptName( "cableA_generator_hydro_dam_02" )

		DisableAllResourcesByScriptName( "fx_cableA_generator_repulsor_base_03" )
		DisableAllResourcesByScriptName( "cableA_generator_repulsor_base_03" )

		//Droppod spawns for high octane objectives //TODO: use resources instead
		DisableAllResourcesByScriptName( "high_octane_droppod_spawn" )
	}
}

void function OnPlayerConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_Freelance_OnPlayerConnected" )

	//StartTeamSpawningThreadIfNeeded( player.GetTeam() )
	Assert( player.GetTeam() in s_teamSpawningThreadStatus )
}

void function OnPlayerDisconnected( entity player )
{
	//SavePostGameScoreboardData( player )
}

void function OnPlayerRespawned( entity player )
{
	//
	player.EnableAutoReloadNoAmmo() //HACK - just want autoreload for bait launcher since it is single-fire, but PvP gloabally overrides auto_reload_no_ammo
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	victim.p.lastKilledTime = Time()
}

void function OnGameStateEnterPlaying()
{
	//RunWorldEvents()
#if DEVELOPER
	thread DebugFrameThread()
#endif // DEV
}

void function OnGameStateEnterResolution()
{
	//
}

#if DEVELOPER
void function DEV_Freelance_KillAllAI()
{
	printf( "%s() - Started", FUNC_NAME() )
	array<entity> NPCs = GetNPCArray()
	foreach ( npc in NPCs )
	{
		if ( !IsEnemyTeam( eNpcTeam.FRIENDLY, npc.GetTeam() ) )
			continue
		if ( npc.IsInvulnerable() )
			continue
		if ( npc.ai.isBossMob )
			continue
		npc.Die()
	}
}

bool s_debugDrawFrame = false
void function DEV_Freelance_ToggleOverlay()
{
	s_debugDrawFrame = !s_debugDrawFrame
}

void function DebugFrameThread()
{
	while ( true )
	{
		if ( s_debugDrawFrame )
		{
			//Director_DebugDrawFrame()
		}

		WaitFrame()
	}
}

#endif // #if DEVELOPER



//OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES
//OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES
//OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES
//OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES OBJECTIVES




vector function FindLocationNearPlayer( entity player, float minDist, float maxDist )
{
	array<vector> origins = NavMesh_RandomPositions_LargeArea( player.GetOrigin(), HULL_HUMAN, 1, minDist, maxDist )

	if ( origins.len() > 0 )
		return origins[0]
	return player.GetOrigin()
}

/////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////
//
//	 __  __ _____  _____  _____
//	|  \/  |_   _|/ ____|/ ____|
//	| \  / | | | | (___ | |
//	| |\/| | | |  \___ \| |
//	| |  | |_| |_ ____) | |____
//	|_|  |_|_____|_____/ \_____|
//
///////////////////////////////////////////////////////////////////////////////////////

int function NextPointFartherThan( array<entity> positionArray, int startIndex, float minDistance )
{
	int count = positionArray.len()
	for ( int idx = 0; idx < (count - 1); ++idx )
	{
		int thisIndex = ((startIndex + 1 + idx) % count)
		float dist = Distance( positionArray[startIndex].GetOrigin(), positionArray[thisIndex].GetOrigin() )
		if ( dist >= minDistance )
			return thisIndex
	}

	// fallback:
	return ((startIndex + 1) % count)
}

int function NextPointCloserThan_( array<entity> positionArray, int startIndex, float maxDistance, vector checkOrigin )
{
	int count = positionArray.len()
	for ( int idx = 0; idx < (count - 1); ++idx )
	{
		int thisIndex = ((startIndex + 1 + idx) % count)
		float dist = Distance( checkOrigin, positionArray[thisIndex].GetOrigin() )
		if ( dist <= maxDistance )
			return thisIndex
	}

	// fallback:
	return ((startIndex + 1) % count)
}

int function NextPointCloserThan( array<entity> positionArray, int startIndex, float maxDistance )
{
	return NextPointCloserThan_( positionArray, startIndex, maxDistance, positionArray[startIndex].GetOrigin() )
}

int function NextPointCloseToPlayer( array<entity> positionArray, int startIndex, float maxDistance, entity player )
{
	return NextPointCloserThan_( positionArray, startIndex, maxDistance, player.GetOrigin() )
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void function TeamSpawnLogic_Init()
{
	teamSpawn.teamWipeIsEnabled =			GetCurrentPlaylistVarBool( "freelance_team_wipe", false )
	teamSpawn.spawnOnTeammatesIsEnabled =	GetCurrentPlaylistVarBool( "freelance_respawn_on_teamamtes", true )
	teamSpawn.keepInventoryOnRespawn =		GetCurrentPlaylistVarBool( "freelance_keep_inventory_on_death", false )
	printf( "%s() - ", FUNC_NAME() )
	printf( "  teamSpawn.spawnOnTeammatesIsEnabled: %s",	string( teamSpawn.spawnOnTeammatesIsEnabled ) )
	printf( "  teamSpawn.teamWipeIsEnabled: %s",			string( teamSpawn.teamWipeIsEnabled ) )
	printf( "  teamSpawn.keepInventoryOnRespawn: %s",		string( teamSpawn.keepInventoryOnRespawn ) )

	AddCallback_OnPlayerKilled( TeamSpawnLogic_OnPlayerKilled )
}

void function TeamSpawnLogic_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	int teamNum = victim.GetTeam()
	if( !(teamNum in teamSpawn.teamToLastDeathPosMap) )
		teamSpawn.teamToLastDeathPosMap[teamNum] <- <0,0,0>

	teamSpawn.teamToLastDeathPosMap[teamNum] = victim.GetOrigin()
}

array<entity> function GetFreeplaySpawnPointsForSquad()
{
	array<entity> spawnPoints = SpawnPoints_GetPilot()
	if ( spawnPoints.len() != 0 )
		return spawnPoints

	array<vector> lootPoints = SURVIVAL_GetAllLootLocationsCopy()
	lootPoints.randomize()
	foreach( point in lootPoints )
	{
		if ( point.z < 0.0 )
			continue

		vector droppedPoint = DropSpawnToFloor( point, HULL_HUMAN )
		if ( droppedPoint == INVALID_DROP_RESULT )
			continue

		entity dummy = CreateEntity( "info_target" )
		dummy.SetOrigin( droppedPoint )
		return [dummy]
	}

	entity dummy = CreateEntity( "info_target" )
	dummy.SetOrigin( <0, 0, 3000> )
	return [dummy]
}

void function GiveWrapper( entity player, string ref, int clipCount )
{
	Survival_PickupItem( SpawnGenericLoot( ref, player.GetOrigin() + <0,0,32>, <-1,-1,-1>, clipCount ), player, 0 )
}

void function GiveWrapperLootData( entity player, array<LootData> loot )
{
	foreach ( data in loot )
		GiveWrapper( player, data.ref, data.countPerDrop )
}


struct RestoreItemInfo
{
	entity item
	LootData& data
}

int function RestoreDeathboxSort( RestoreItemInfo a, RestoreItemInfo b )
{
	if ( a.data.lootType == eLootType.BACKPACK && b.data.lootType != eLootType.BACKPACK )
		return -1
	else if ( a.data.lootType != eLootType.BACKPACK && b.data.lootType == eLootType.BACKPACK )
		return 1

	if ( a.data.lootType == eLootType.AMMO && b.data.lootType != eLootType.AMMO )
		return -1
	else if ( a.data.lootType != eLootType.AMMO && b.data.lootType == eLootType.AMMO )
		return 1

	if ( a.data.lootType == eLootType.MAINWEAPON && b.data.lootType != eLootType.MAINWEAPON )
		return -1
	else if ( a.data.lootType != eLootType.MAINWEAPON && b.data.lootType == eLootType.MAINWEAPON )
		return 1

	// tier, priority:
	{
		if ( a.data.tier > b.data.tier )
			return -1
		if ( a.data.tier < b.data.tier )
			return 1

		int aPriority = GetPriorityForLootType( a.data )
		int bPriority = GetPriorityForLootType( b.data )
		if ( aPriority < bPriority )
			return -1
		else if ( aPriority > bPriority )
			return 1

		if ( a.data.lootType < b.data.lootType )
			return -1
		if ( a.data.lootType > b.data.lootType )
			return 1
	}

	return 0
}

void function RestoreDeathboxInventoryToPlayer( entity player, entity box )
{
	array<RestoreItemInfo> infos
	{
		array<entity> items = box.GetLinkEntArray()
		foreach ( int idx, entity item in items )
		{
			RestoreItemInfo info
			info.item = item
			info.data = SURVIVAL_Loot_GetLootDataByIndex( item.GetSurvivalInt() )
			infos.append( info )
		}
	}

	infos.sort( RestoreDeathboxSort )

	foreach( RestoreItemInfo info in infos )
		Survival_PickupItem( info.item, player, 0, box )

	// Equip best weapon:
	{
		array<entity> weapons = SURVIVAL_GetPrimaryWeaponsSorted( player )
		if ( weapons.len() > 0 )
			player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weapons[0].GetWeaponClassName() )
	}
}

bool function PlayerHasAnyInventory( entity player )
{
	array<entity> weapons = SURVIVAL_GetPrimaryWeaponsSorted( player )
	if ( weapons.len() > 0 )
		return true

	if ( SURVIVAL_GetInventoryCount( player ) > 0 )
		return true

	foreach ( slot, slotData in EquipmentSlot_GetAllEquipmentSlots() )
	{
		if ( EquipmentSlot_GetEquippedLootDataForSlot( player, slot ).ref.len() > 0 )
			return true
	}

	return false
}

void function GiveSpawnLoadout( entity player )
{

		if ( IsPlayerShadowZombie( player ) )
			return


	if ( PlayerHasAnyInventory( player ) )
		return

	if ( GetCurrentPlaylistVarBool( "character_loadouts_enabled", false ) )
	{
		CharacterLoadouts_GiveCurrentCharacterLoadoutToPlayer( player )
		return
	}

	string listString = GetCurrentPlaylistVarString( "freelance_spawn_loadout", "" )
	foreach ( string entry in GetTrimmedSplitLoweredString( listString, ", " ) )
	{
		array<string> pair = GetTrimmedSplitString( entry, ":" )
		int countOverride = ((pair.len() > 1) ? int( pair[1] ) : -1)
		GiveLoot( player, pair[0], countOverride )
	}
}

void function GiveSimplePVELoadout( entity player )
{
	GiveWrapper( player, "mp_weapon_rspn101", 1 )
	GiveWrapper( player, BULLET_AMMO, (18 * 4) )
}

void function PVE_CommonPlayerRespawn( entity player )
{
	ClearPlayerEliminated( player )

	//++ Workaround for R5DEV-67027 // (dw): Intended to be temp. The flow of player participation in PVE should be thought through.
	player.p.respawnPodLanded = true // pretend this is a valid survival respawn via dropship
	player.p.hasMatchParticipationEnded = false // override the end-of-participation check flag
	//--
	DoRespawnPlayer( player, null )
	player.p.respawnPodLanded = false // need to be reset before we die again, this is just bad.

	GiveSpawnLoadout( player )

	Bleedout_SetPlayerBleedoutType( player, 0 )
}

void function SpawnSquadAtFreeplayStart( int team )
{
	array<entity> spawns = GetFreeplaySpawnPointsForSquad()

	array<entity> squadMembers = GetPlayerArrayOfTeam( team )
	foreach ( int idx, entity player in squadMembers )
	{
		entity spawn = spawns[idx % spawns.len()]

		if ( !Freelance_IsHubLevel() )
		{
			if ( !player.GetParent() )
			{
				player.SetOrigin( spawn.GetOrigin() + <0, 0, 10> )
				player.SetAngles( spawn.GetAngles() ) // + <60, 0, 0>
			}
		}

		if ( !IsAlive( player ) )
			PVE_CommonPlayerRespawn( player )

		ScreenFadeFromBlack( player, 5.0, 2.0 )
	}
}

const asset PLAYER_RESPAWN_EFFECT = $"P_phase_shift_main"
void function PlayRespawnedFX( entity player )
{
	delaythread( 0.25 ) EmitSoundAtPosition( TEAM_ANY, (player.GetOrigin() + <0, 0, 30.0>), "PvE_RespawnChime_3P", player )
	PlayFX( PLAYER_RESPAWN_EFFECT, player.GetOrigin() )
	ScreenFadeFromBlack( player, 4.0, 0.5 )
}

bool function TryRespawnPlayerOnSquad( entity player )
{
	int team = player.GetTeam()
	array<entity> teamMembers = GetPlayerArrayOfTeam_Alive( team )
	teamMembers.randomize()
	foreach( entity member in teamMembers )
	{
		if ( member == player )
			continue
		if ( Bleedout_IsBleedingOut( member ) )
			continue
		if ( !member.hasConnected )
			continue
		//if ( member.IsCrouched() || member.IsCrouching() )
		//	continue

		entity memberParent = member.GetParent()
		if ( IsValid( memberParent ) )
			continue

		vector angles = member.GetAngles()

		vector fallbackPos = member.GetOrigin()
		vector idealPos = member.GetOrigin() + (AnglesToForward( angles ) * -256.0) + <0,0,32>
		TraceResults result = TraceHull( fallbackPos, idealPos, member.GetBoundingMins(), member.GetBoundingMaxs(), teamMembers, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

		player.SetOrigin( fallbackPos )
		player.SetAngles( angles )
		PVE_CommonPlayerRespawn( player )
		PutEntityInSafeSpot( player, null, null, fallbackPos, result.endPos )

		PlayRespawnedFX( player )
		return true
	}

	return false
}

struct PlayerRespawnInfo
{
	vector origin
	vector angles
}

PlayerRespawnInfo function GetBestSpawnPointForPlayer( entity player )
{
	int teamNum = player.GetTeam()
	vector testPos = (teamNum in teamSpawn.teamToLastDeathPosMap) ? teamSpawn.teamToLastDeathPosMap[teamNum] : player.GetOrigin()

	// Try forced / custom spawn:
	{
		if ( teamNum in teamSpawn.teamToForcedSpawnPointMap )
			return teamSpawn.teamToForcedSpawnPointMap[teamNum]
	}

	// Try fallback spawn:
	{
		if ( teamNum in teamSpawn.teamToFallbackSpawnPointMap )
			return teamSpawn.teamToFallbackSpawnPointMap[teamNum]
	}

	PlayerRespawnInfo result
	result.origin = testPos
	result.angles = player.GetAngles()
	return result
}

bool function RespawnPlayerAtBestSpawnPoint( entity player )
{
	PlayerRespawnInfo info = GetBestSpawnPointForPlayer( player )
	player.SetOrigin( info.origin )
	player.SetAngles( info.angles )
	PVE_CommonPlayerRespawn( player )
	PlayRespawnedFX( player )
	return true
}

struct teamSpawningStatus
{
	bool isActive
	bool finishedVictory
}
table <int, teamSpawningStatus> s_teamSpawningThreadStatus = {}
void function StartTeamSpawningThreadIfNeeded( int teamNumber )
{
	if ( !(teamNumber in s_teamSpawningThreadStatus) )
	{
		teamSpawningStatus newStatus
		s_teamSpawningThreadStatus[teamNumber] <- newStatus
	}
	if ( s_teamSpawningThreadStatus[teamNumber].isActive )
		return

	//Director_SquadInit( teamNumber )
	s_teamSpawningThreadStatus[teamNumber].isActive = true
	thread TeamSpawningThread( teamNumber )
}

array<entity> function GetPlayerArrayOfTeam_Dead( int team )
{
	array<entity> players = GetPlayerArrayOfTeam( team )
	array<entity> result
	foreach( player in players )
	{
		if ( IsValid( player ) && !IsAlive( player ) )
			result.append( player  )
	}

	return result
}

int function GetTeamCanRespawnState( int teamNumber )
{
	array<entity> alivePlayers = GetPlayerArrayOfTeam_Alive( teamNumber )
	if ( alivePlayers.len() == 0 )
		return eTeamCanRespawn.NO

	foreach ( entity player in alivePlayers )
	{
		if ( GetEffectiveDeltaSince( player.GetLastTimeDamagedByNPC() ) < 12.0 )
			return eTeamCanRespawn.NO_BECAUSE_IN_COMBAT
		if ( GetEffectiveDeltaSince( player.GetLastTimeDidDamageToNPC() ) < 10.0 )
			return eTeamCanRespawn.NO_BECAUSE_IN_COMBAT
	}

	foreach ( entity player in alivePlayers )
	{
		array<entity> npcs = GetNPCArrayEx( "any", TEAM_ANY, player.GetTeam(), player.GetOrigin(), 1500.0 )
		if ( npcs.len() > 0 )
			return eTeamCanRespawn.NO_BECAUSE_ENEMIES_NEARBY
	}

	foreach ( entity player in alivePlayers )
	{
		if ( Bleedout_IsBleedingOut( player ) )
			return eTeamCanRespawn.NO_BECAUSE_BLEEDOUT_OUT
	}

	return eTeamCanRespawn.YES
}

struct
{
	bool startSpawnIsDisabled = false
	string startSpawnIsDisabledReason = ""
	void functionref( int ) startSpawnFunc
	string startSpawnFuncReason = "default"

	table<int, vector> teamToLastDeathPosMap

	table<int, PlayerRespawnInfo> teamToForcedSpawnPointMap
	table<int, PlayerRespawnInfo> teamToFallbackSpawnPointMap

	bool spawnOnTeammatesIsEnabled = true
	bool teamWipeIsEnabled = false

	bool keepInventoryOnRespawn = true
} teamSpawn

void function TeamSpawn_SetTeamWipe( bool isEnabled, string debugReason )
{
	if ( teamSpawn.teamWipeIsEnabled == isEnabled )
		return
	teamSpawn.teamWipeIsEnabled = isEnabled
	printf( "%s() set to: %s, reason: %s", FUNC_NAME(), string( isEnabled ), debugReason )
}

void function TeamSpawn_SetSpawnOnTeammates( bool isEnabled, string debugReason )
{
	if ( teamSpawn.spawnOnTeammatesIsEnabled == isEnabled )
		return
	teamSpawn.spawnOnTeammatesIsEnabled = isEnabled
	printf( "%s() set to: %s, reason: %s", FUNC_NAME(), string( isEnabled ), debugReason )
}

void function TeamSpawn_SetStartSpawnDisabled( string debugReason )
{
	teamSpawn.startSpawnIsDisabled = true
	teamSpawn.startSpawnIsDisabledReason = debugReason
}

void function TeamSpawn_SetStartSpawnCustom( void functionref( int ) func, string debugReason )
{
	teamSpawn.startSpawnFunc = func
	teamSpawn.startSpawnFuncReason = debugReason
}

void function TeamSpawn_SetForcedSpawnpointForTeam( int teamNum, vector spawnOrigin, vector spawnAngles )
{
	if ( !(teamNum in teamSpawn.teamToForcedSpawnPointMap) )
	{
		PlayerRespawnInfo newInfo
		teamSpawn.teamToForcedSpawnPointMap[teamNum] <- newInfo
	}

	PlayerRespawnInfo info = teamSpawn.teamToForcedSpawnPointMap[teamNum]
	info.origin = spawnOrigin
	info.angles = spawnAngles
	printf( "%s() set forced spawn for team #%d to %s.", FUNC_NAME(), teamNum, string( spawnOrigin ) )
}

void function TeamSpawn_SetFallbackSpawnpointForTeam( int teamNum, vector spawnOrigin, vector spawnAngles )
{
	if ( !(teamNum in teamSpawn.teamToFallbackSpawnPointMap) )
	{
		PlayerRespawnInfo newInfo
		teamSpawn.teamToFallbackSpawnPointMap[teamNum] <- newInfo
	}

	PlayerRespawnInfo info = teamSpawn.teamToFallbackSpawnPointMap[teamNum]
	info.origin = spawnOrigin
	info.angles = spawnAngles
	printf( "%s() set fallback spawn for team #%d to %s.", FUNC_NAME(), teamNum, string( spawnOrigin ) )
}

bool function TeamSpawn_GetKeepInventoryOnRespawn()
{
	return teamSpawn.keepInventoryOnRespawn
}
void function TeamSpawn_SetKeepInventoryOnRespawn( bool isEnabled, string debugReason )
{
	if ( teamSpawn.keepInventoryOnRespawn == isEnabled )
		return
	teamSpawn.keepInventoryOnRespawn = isEnabled
	printf( "%s() set to: %s, reason: %s", FUNC_NAME(), string( isEnabled ), debugReason )
}

void function TeamSpawn_MarkTeamAsFinishedWithMatchForVictory( int teamNumber )
{
	printf( "%s() - team #%d", FUNC_NAME(), teamNumber )
	s_teamSpawningThreadStatus[teamNumber].finishedVictory = true
}

//
void function TeamSpawningThread( int teamNumber )
{
	printf( "%s() - Started for team #%d.", FUNC_NAME(), teamNumber )
	WaitFrame() // No spawning until first player has finished all OnPlayerConnected()s.

	while ( GetGameState() < eGameState.Playing )
		WaitFrame()

	//Director_SquadMarkStartTime( teamNumber )

	if ( GetGameState() == eGameState.Playing )
	{
		if ( teamSpawn.startSpawnIsDisabled )
		{
			printf( "%s() - Skipping start spawn for team #%d, reason: '%s'", FUNC_NAME(), teamNumber, teamSpawn.startSpawnIsDisabledReason )
		}
		else if ( Freelance_IsHubLevel() )
		{
			printf( "%s() - Skipping start spawn for team #%d, because this is a hub level.", FUNC_NAME(), teamNumber )
		}
		else if ( teamSpawn.startSpawnFunc != null )
		{
			Assert( (GetPlayerArrayOfTeam_Alive( teamNumber ).len() == 0), "Players have been unexpectedly spawned elsewhere." )
			printf( "%s() - Running custom start spawn function for team #%d, reason: '%s'", FUNC_NAME(), teamNumber, teamSpawn.startSpawnFuncReason )
			teamSpawn.startSpawnFunc( teamNumber )
		}
		else
		{
			Assert( (GetPlayerArrayOfTeam_Alive( teamNumber ).len() == 0), "Players have been unexpectedly spawned elsewhere." )
			printf( "%s() - Running default start spawn function for team #%d.", FUNC_NAME(), teamNumber )
			SpawnSquadAtFreeplayStart( teamNumber )
		}
	}

	if ( GetRespawnStyle() != eRespawnStyle.NONE )
		return

	//
	while ( GetPlayerArrayOfTeam_Alive( teamNumber ).len() == 0 )
		WaitFrame()

	// Handle respawning on team:
	for ( ;; )
	{
		int alivePlayers = GetPlayerArrayOfTeam_Alive( teamNumber ).len()
		if ( teamSpawn.teamWipeIsEnabled && (alivePlayers == 0) )
		{
			printf( "%s() - Marking team #%d as failing mission for team-wipe.", FUNC_NAME(), teamNumber )
			//foreach( entity player in GetPlayerArrayOfTeam( teamNumber ) )
			//	PVEMissionInfo_SetResultsEndMission( player, false, 0 )
			wait( 10.0 )
			break
		}

		if ( s_teamSpawningThreadStatus[teamNumber].finishedVictory )
			break

		array<entity> deadPlayers = GetPlayerArrayOfTeam_Dead( teamNumber )
		if ( deadPlayers.len() == 0 )
		{
			wait 1.0
			continue
		}

		if ( teamSpawn.spawnOnTeammatesIsEnabled && (alivePlayers > 0) )
		{
			int teamCanRespawnState = GetTeamCanRespawnState( teamNumber )
			Freelance_SendTeamCanRespawn( teamNumber, teamCanRespawnState )
			if ( teamCanRespawnState != eTeamCanRespawn.YES )
			{
				wait 1.0
				continue
			}

			foreach( entity deadPlayer in deadPlayers )
			{
				float timeSinceKilled = (Time() - deadPlayer.p.lastKilledTime)
				if ( timeSinceKilled > 15.0 )
					TryRespawnPlayerOnSquad( deadPlayer )
			}
		}
		else
		{
			// spawn point

			foreach( entity deadPlayer in deadPlayers )
			{
				float timeSinceKilled = (Time() - deadPlayer.p.lastKilledTime)
				if ( timeSinceKilled > 8.0 )
				{
					bool didSpawn = RespawnPlayerAtBestSpawnPoint( deadPlayer )
					if ( didSpawn )
						break
				}
			}
		}

		wait 1.0
	}

	s_teamSpawningThreadStatus[teamNumber].isActive = false
	printf( "%s() - Finished for team #%d.", FUNC_NAME(), teamNumber )

	if ( Freelance_IsHubLevel() )
		return

	Freelance_MissionEnd( teamNumber )
}

void function Freelance_MissionEnd( int teamNumber )
{
	if ( IsMatchmakingServer() )
	{
		// tell everyone to go back to their bars:
		//if ( returnToHub )
		//{
		//	printf( "%s() - team #%d, telling players to matchmake back to hub playlist.", FUNC_NAME(), teamNumber )
		//	array<entity> players = GetPlayerArrayOfTeam( teamNumber )
		//	//foreach( entity player in players )
		//	//	Freelance_SendPlayerBackToHub( player )
		//	wait( 60.0 )
		//}

		// fallback:
		array<entity> players = GetPlayerArrayOfTeam( teamNumber )
		if ( players.len() > 0 )
		{
			printf( "%s() - team #%d, done waiting for clients to leave on their own; so sending them to party screen.", FUNC_NAME(), teamNumber )
			SendPlayersToPartyScreen( players )
		}
	}
	//else if ( returnToHub )
	//{
	//	//if ( !IsMultiTeamMission() )
	//	//{
	//	//	LevelTransitionStruct trans
	//	//	ChangeLevel( "mp_rr_nobody", trans )
	//	//}
	//	//else
	//	{
	//		// team is in "wiped out" status in a multi-squad environment.
	//	}
	//}
	else
	{
		LevelTransitionStruct trans
		ChangeLevel( "mp_lobby", trans )
	}
}

#if DEVELOPER
const string SIG_SMOKETEST = "SMOKETEST"
void function DEV_FreelanceSmoketest( array<string> objectiveTypes )
{
	RegisterSignal( SIG_SMOKETEST )
	Signal( svGlobal.worldspawn, SIG_SMOKETEST )

	Dev_ForceLaunchCharacterSpawning()

	thread function() : ()
	{
		EndSignal( svGlobal.worldspawn, SIG_SMOKETEST )

		while( GetPlayerArray().len() < MAX_PLAYERS )
		{
			ServerCommand( "bot" )
			wait( 1.0 )
		}
		DEV_RespawnPlayersBySpecifiers( ["alldead"] )

		wait( 5.0 )
		array<vector> lootPoints = SURVIVAL_GetAllLootLocationsCopy()
		array<vector> spots
		foreach( point in lootPoints )
		{
			vector droppedPoint = DropSpawnToFloor( point, HULL_HUMAN )
			if ( droppedPoint == INVALID_DROP_RESULT )
				continue
			spots.append( droppedPoint )
		}

		for( ;; )
		{
			foreach( player in GetPlayerArray_Alive() )
			{
				wait( 1.0 )
				if ( !IsAlive( player ) )
					continue
				if ( !IsInvincible( player ) )
					MakeInvincible( player )

				player.SetOrigin( spots.getrandom() )
			}
			Wait( 5.0 )
		}
	}()

	if ( objectiveTypes.len() == 0 )
		objectiveTypes = split( GetCurrentPlaylistVarString( "freelance_smoketest_objectiveTypes", "" ), ", " )
	if ( objectiveTypes.len() > 0 )
	{
		thread function() : ( objectiveTypes )
		{
			EndSignal( svGlobal.worldspawn, SIG_SMOKETEST )

			for( ;; )
			{
				DEV_ClearAllObjectives()
				wait( 5.0 )

				for ( int idx = 0; idx < 4; ++idx )
				{
					DEV_LaunchObjectiveFarAway( objectiveTypes.getrandom() )
					wait( 1.0 )
				}

				wait( 60.0 )
			}
		}()
	}
}
#endif // DEV

//////////////////
//////////////////
