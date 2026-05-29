global function ShPlayerPet_Init
global function PlayerPetsEnabled

#if SERVER
	global function AddCallback_OnPetSpawnedForPlayer
	global function Survival_AddCallback_OnPetFriendlyfireMessaging
	global function SquadPets_OnPlayerBleedoutStateChanged
#endif

const int DICE_MAX_INT = 21

struct
{
	int 			petType

	#if SERVER
		array< void functionref(entity, entity) > Callbacks_OnPetSpawnedForPlayer
		array< void functionref(entity, entity) > Callbacks_OnPetFriendlyfireMessaging
		array<entity>	playerPets
		int				numPetsActive
		array<entity>	petsActive
		int 			maxPetsServer
		int				maxPetsSquad
		float 			maxPetDistFromOwner
		int 			petsGarbageCollectedDueToDist

	#endif //#if SERVER
} file

#if SERVER || CLIENT
void function ShPlayerPet_Init()
{
	if ( !PlayerPetsEnabled() )
		return

	string petType = GetCurrentPlaylistVarString( "squad_pet_type", "shadow_prowler" )
	switch( petType )
	{
		case "shadow_prowler":
			file.petType = eNPC.DIRE_PROWLER
			#if CLIENT
				AddCreateCallback( "npc_prowler", OnPetCreatedClient )
			#endif
			break
		case "prowler":
			file.petType = eNPC.PROWLER
			#if CLIENT
				AddCreateCallback( "npc_prowler", OnPetCreatedClient )
			#endif
			break
		default:
			Assert( false, "Unhandled playlist var 'squad_pet_type': " + petType )
	}

	#if SERVER
		FlagInit( "SquadPetsActive" )
		FlagInit( "SquadPetsNumSquadsNeededToSpawnReached" )

		AddCallback_OnPlayerKilled( OnPlayerKilled )
		AddDamageCallback( "player", OnPlayerTookDamage )
		AddCallback_OnPlayerPostRespawned( OnPlayerPostRespawned )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )
		AddCallback_GameStateEnter( eGameState.Playing, OnGameStart )
		SURVIVAL_AddCallback_OnDeathFieldStartShrink( OnDeathFieldStartShrink )
		SURVIVAL_AddCallback_OnDeathFieldStopShrink( OnDeathFieldStopShrink )
		file.maxPetsServer = GetCurrentPlaylistVarInt( "squad_pet_max_num_per_server", 0 )
		file.maxPetsSquad = GetCurrentPlaylistVarInt( "squad_pet_max_num_per_squad", 0 )
		file.maxPetDistFromOwner = GetCurrentPlaylistVarFloat( "squad_pet_max_dist_from_owner", 8000 )
		BleedoutState_AddCallback_OnPlayerBleedoutStateChanged( SquadPets_OnPlayerBleedoutStateChanged )
	#endif

}
#endif //SERVER || CLIENT

#if SERVER || CLIENT
bool function PlayerPetsEnabled()
{
	return GetCurrentPlaylistVarBool( "squad_pets_enabled", false )
}
#endif // SERVER || CLIENT


#if SERVER
void function OnPlayerPostRespawned( entity player )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( !Flag( "SquadPetsActive" ) )
		return

	if ( player.GetNoTarget() == true )
		player.SetNoTarget( false )

	                             
		if ( IsPlayerShadowZombie( player ) )
			CleanupPlayerPets( player )
                                    

}
#endif //SERVER


#if SERVER
void function OnPlayerKilled( entity victim, entity killer, var damageInfo )
{
	if ( !Flag( "SquadPetsActive" ) )
		return

	CleanupPlayerPets( victim )
	int team = victim.GetTeam()
	thread function() : ( team )
	{
		if ( GetCurrentPlaylistVarBool( "respawn_queue_active", true ) )
		{
			float timeout = GetCurrentPlaylistVarFloat( "squad_pet_respawn_wait_for_queue_timeout", 1.0 )
			waitthread WaitTillSpawnQueueFree( timeout )
			TrySpawnPetsForTeam( team )
		}
		else
		{
			TrySpawnPetsForTeam( team )
		}

	}()

}
#endif //SERVER

#if SERVER
void function OnPlayerDisconnected( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	if ( !Flag( "SquadPetsActive" ) )
		return

	CleanupPlayerPets( player )
	int team = player.GetTeam()
	thread function() : ( team )
	{
		if ( GetCurrentPlaylistVarBool( "respawn_queue_active", true ) )
		{
			float timeout = GetCurrentPlaylistVarFloat( "squad_pet_respawn_wait_for_queue_timeout", 1.0 )
			waitthread WaitTillSpawnQueueFree( timeout )
			TrySpawnPetsForTeam( team )
		}
		else
		{
			TrySpawnPetsForTeam( team )
		}
	}()
}
#endif //#if SERVER


#if SERVER
void function OnGameStart()
{
	thread SquadPetsThread()
}
#endif //SERVER


#if SERVER
void function SquadPetsThread()
{
	FlagWait( "GamePlaying" )
	FlagWait( "Survival_LootSpawned" )

	#if DEVELOPER
		string playlistName = GetCurrentPlaylistName()
		if ( playlistName  == "shadow_royale_test" )
		{
			//start trying to spawn pets immediately instead for waiting on circle shrink
			wait 10.0
			if ( !Flag( "SquadPetsActive" ) )
				FlagSet( "SquadPetsActive" )

			foreach( team in GetAllValidPlayerTeams() )
				TrySpawnPetsForTeam( team )

		}
	#endif //DEV

	FlagWait( "SquadPetsActive" )

	float interval = GetCurrentPlaylistVarFloat( "squad_pet_cleanup_interval", 60 )
	float intervalSpawnAddon = GetCurrentPlaylistVarFloat( "squad_pet_spawn_interval_addon", 5 )
	bool respawnQueueActive = GetCurrentPlaylistVarBool( "respawn_queue_active", true )
	float respawnQueueTimeout = GetCurrentPlaylistVarFloat( "squad_pet_respawn_wait_for_queue_timeout", 1.0 )
	while( GetGameState() == eGameState.Playing )
	{

		if ( GetCurrentPlaylistVarBool( "squad_pets_respawn_on_interval", true ) )
		{
			wait intervalSpawnAddon
			//respawning pets per team/player also  happens on player death,
			//pet death, player disconnect and on round 1 start
			foreach( team in GetAllValidPlayerTeams() )
			{
				WaitFrame()

				if ( respawnQueueActive )
				{
					waitthread WaitTillSpawnQueueFree( respawnQueueTimeout )
					TrySpawnPetsForTeam( team )
				}
				else
				{
					TrySpawnPetsForTeam( team )
				}
			}
		}

		wait interval

		//Clean up orphan pets or ones that are too far from owners
		CleanupServerPets()
	}

}
#endif //SERVER



/*
===========================================================================
===========================================================================
===========================================================================

 ######  ########     ###    ##      ## ##    ## #### ##    ##  ######
##    ## ##     ##   ## ##   ##  ##  ## ###   ##  ##  ###   ## ##    ##
##       ##     ##  ##   ##  ##  ##  ## ####  ##  ##  ####  ## ##
 ######  ########  ##     ## ##  ##  ## ## ## ##  ##  ## ## ## ##   ####
      ## ##        ######### ##  ##  ## ##  ####  ##  ##  #### ##    ##
##    ## ##        ##     ## ##  ##  ## ##   ###  ##  ##   ### ##    ##
 ######  ##        ##     ##  ###  ###  ##    ## #### ##    ##  ######

===========================================================================
===========================================================================
===========================================================================
*/
#if SERVER
bool function TeamCanSpawnPet( array<entity> players )
{
	//no players
	if ( players.len() == 0 )
		return false

	//squad already has max pets active
	array<entity> teamPets = GetTeamPets( players )
	int numTeamPets = teamPets.len()
	int maxPetsSquad = file.maxPetsSquad
	Assert( numTeamPets <= maxPetsSquad )
	if ( numTeamPets >= maxPetsSquad )
		return false

	return true
}
#endif //SERVER


#if SERVER
bool function ServerCanSpawnPet()
{
	if ( GetGameState() != eGameState.Playing )
		return false

	if ( !Flag( "SquadPetsActive" ) )
		return false

	//already at max pets on server
	int maxPetsServer = file.maxPetsServer
	if ( file.numPetsActive >= maxPetsServer )
		return false

	//0 pets allowed per squad
	int maxPetsSquad = file.maxPetsSquad
	if ( maxPetsSquad < 1 )
		return false

	if ( !Flag( "SquadPetsNumSquadsNeededToSpawnReached" ) )
	{
		//number of discrete squads needed to allow spawning not reached
		//(don't want to keep checking this so we'll set a flag when it's true)
		if ( GetNumTeamsRemaining() > GetCurrentPlaylistVarInt( "squad_pet_max_teams_to_allow_spawn", 20 ) )
			return false
		else
			FlagSet( "SquadPetsNumSquadsNeededToSpawnReached" )
	}

	return true
}
#endif //SERVER


#if SERVER
bool function PlayerCanSpawnPet( entity player, array<entity> squad = [] )
{

	if ( !IsValid( player ) )
		return false

	if ( !IsAlive( player ) )
		return false

	                             
		if ( IsPlayerShadowZombie( player ) )
			return false
                                    

	if ( PlayerHasPet( player ) )
		return false

	if ( player.IsZiplining() )
		return false

	if ( player.Player_IsSkydiving() )
		return false

	if ( !player.IsOnGround() )
		return false

	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return false

	if ( player.IsPhaseShifted() )
		return false

	if ( player.GetPlayerNetBool( "playerInPlane" ) )
		return false

	if ( player.IsNoclipping() )
		return false

	if ( player.IsMountingZipline() )
		return false

	if ( player.Player_IsSkydiveAnticipating() )
		return false

	int team = player.GetTeam()
	if ( squad.len() == 0 )
		squad = GetPlayerArrayOfTeam_AliveConnected( team )

	int numPlayers = squad.len()

	if ( GetCurrentPlaylistVarBool( "squad_pet_shadow_zombies_count_as_squad_mates", true ) == false )
	{
		//are we bothering to count shadow zombie squadmates?
		int numShadowPlayers
		foreach( squadMate in squad )
		{
			if ( squadMate == player )
				continue

			                             
				if ( IsPlayerShadowZombie( squadMate ) )
					numShadowPlayers++
                                      
		}

		numPlayers = ( numPlayers - numShadowPlayers )
	}

	if ( numPlayers < GetCurrentPlaylistVarInt( "squad_pet_min_squad_size_to_spawn", 1 ) )
		return false

	if ( numPlayers > GetCurrentPlaylistVarInt( "squad_pet_max_squad_size_to_spawn", 1 ) )
		return false

	return true

}
#endif //#if SERVER

#if SERVER
void function TrySpawnPetsForTeam( int team )
{
	if ( !ServerCanSpawnPet() )
		return

	array<entity>players = GetPlayerArrayOfTeam_AliveConnected( team )
	if ( players.len() == 0 )
		return

	if ( !TeamCanSpawnPet( players ) )
		return

	array<entity> playerPetCandidates
	foreach( player in players )
	{
		if ( !PlayerCanSpawnPet( player, players ) )
			continue

		playerPetCandidates.append( player )
	}

	if ( playerPetCandidates.len() == 0 )
		return

	array<entity> teamPets = GetTeamPets( players )
	int numTeamPets = teamPets.len()
	int maxPetsSquad = file.maxPetsSquad
	Assert( numTeamPets <= maxPetsSquad )
	int numPetsToSpawn = ( maxPetsSquad - numTeamPets )
	numPetsToSpawn = minint( playerPetCandidates.len(), numPetsToSpawn )
	if ( numPetsToSpawn < 1 )
		return

	Assert( numPetsToSpawn <= playerPetCandidates.len() )

	for( int i = 0; i < numPetsToSpawn; i++ )
	{
		entity bestOwner = GetBestPetOwnerForTeam( playerPetCandidates )
		if ( !IsValid( bestOwner ) )
			return //no bother trying to find additional candidates if first was a dud

		Point spawnPoint = GetRandomPetSpawnPointNearPos( bestOwner, bestOwner.GetOrigin() )
		if ( spawnPoint.origin == <0, 0, 0> )
		{
			Warning( "%s() -- Couldn't find pet spawn point near player %s", FUNC_NAME(), string( bestOwner ) )
			continue
		}

		SpawnPetForPlayer( bestOwner, spawnPoint.origin, spawnPoint.angles )
	}
}
#endif //SERVER

#if SERVER
void function OnEnemyChanged( entity pet )
{
	entity owner = PetGetOwner( pet )
	if ( !IsValid( owner ) )
		return

	AssertPetFlags( pet )
	entity enemy = pet.GetEnemy()

	if ( enemy == null )
		PetStartFollowingOwner( pet, owner )

	else if ( enemy.IsNPC() || enemy.IsPlayer() )
		PetStopFollowingOwner( pet )

	else
		PetStartFollowingOwner( pet, owner )

}
#endif //SERVER


#if SERVER
void function PetStopFollowingOwner( entity pet )
{
	ClearFollowBehavior( pet )
}
#endif //SERVER


#if SERVER
entity function PetGetOwner( entity pet )
{
	return pet.e.firstOwner
}
#endif //SERVER


#if SERVER
void function PetStartFollowingOwner( entity pet, entity owner )
{
	if ( !IsAlive( pet ) )
		return

	if ( !IsAlive( owner ) )
		return

	//Set target move tolerance to change follow position when follow target moves
	float followTargetMoveTolerance = GetCurrentPlaylistVarFloat( "player_pet_follow_move_tolerence", 1024 )

	//Set goal tolerance when in combat
	float followGoalCombatTolerance = GetCurrentPlaylistVarFloat( "player_pet_follow_combat_tolerence", 512 )

	//Set goal tolerance when not in combat
	float followGoalTolerance = GetCurrentPlaylistVarFloat( "player_pet_follow_goal_tolerence", 512 )

	//float attackRadius = 1024				//will auto attack enemies within this radius

	if ( GetCurrentPlaylistVarBool( "squad_pet_force_clear_enemy", true ) )
	{
		pet.ClearEnemy()
	}

	if ( GetCurrentPlaylistVarBool( "squad_pet_force_clear_enemy_memory", true ) )
	{
		pet.ClearAllEnemyMemory()
	}

	NPCFollowsPlayer( pet, owner, followTargetMoveTolerance, followGoalCombatTolerance, followGoalTolerance )

	//designate owner/pet relationship
	pet.SetBossPlayer( owner )
	pet.e.firstOwner = owner
	owner.e.pet = pet
}
#endif //SERVER

#if CLIENT
void function OnPetCreatedClient( entity pet )
{
	thread function() : ( pet )
	{
		if ( !IsValid( pet ) )
			return

		pet.EndSignal( "OnDeath" )
		entity petOwner = pet.GetBossPlayer()
		float timeOutFrames
		while( !IsValid( petOwner ) || timeOutFrames > 1000 )
		{
			WaitFrame()
			if ( !IsAlive( pet ) )
				return
			petOwner = pet.GetBossPlayer()
		}

		vector infoColor
		if ( IsValid( petOwner ) )
			infoColor = GetPlayerInfoColor( petOwner )
		else
			infoColor = <255, 255, 255>

		SetCustomPlayerInfoColor( pet, infoColor )

	}()

}
#endif //CLIENT

#if SERVER
void function SpawnPetForPlayer( entity player, vector origin, vector angles )
{
	Assert( !IsValid( GetPlayerPet( player ) ) )
	Assert( Flag( "SquadPetsActive" ) )

	int team = player.GetTeam()
	entity pet = SpawnNPC( file.petType, origin, angles )
	pet.kv.alwaysalert = true
	SetTeam( pet, team )
	file.numPetsActive++
	//if ( GetCurrentPlaylistVarBool( "squad_pets_debug", false ) )
		printt( "***ACTIVE PETS: " + file.numPetsActive )

	Assert( !file.petsActive.contains( pet ) )
	file.petsActive.append( pet )
	Assert( file.numPetsActive <= file.maxPetsServer )
	AssertPetFlags( pet )
	PetStartFollowingOwner( pet, player )
	pet.SetEnemyChangeCallback( OnEnemyChanged )

	//pet.SetValidHealthBarTarget( false )
	int health = GetCurrentPlaylistVarInt( "squad_pet_health", 50 )
	pet.SetMaxHealth( health )
	pet.SetHealth( health )

	string petName
	if ( player.e.lootRef != "" )
	{
		petName = player.e.lootRef
	}
	else if ( GetCurrentPlaylistVarBool( "squad_pet_use_names", true ) )
	{
		int diceRoll = RandomIntRange( 1, DICE_MAX_INT )
		petName = "#PET_NAME_" + diceRoll.tostring()
	}
	else
	{
		petName = "#NPC_PROWLER_UI_TITLE"
	}
	player.e.lootRef = petName
	pet.SetTitle( petName )
	pet.SetNameVisibleToFriendly( true )
	pet.SetNameVisibleToOwner( true )
	pet.SetNameVisibleToEnemy( false )
	pet.SetNameVisibleToNeutral( true )

	string friendlyHighlight = "sp_pet_hero"
	if ( GetCurrentPlaylistVarBool( "squad_pet_use_default_highlight", true ) )
		friendlyHighlight = "sp_friendly_hero"

	Highlight_SetFriendlyHighlight( pet, friendlyHighlight )

	if ( GetCurrentPlaylistVarBool( "squad_pet_use_nightmap_enemy_highlight", true ) )
		Highlight_SetEnemyHighlight( pet, "enemy_nightmap" )

	foreach ( callbackFunc in file.Callbacks_OnPetSpawnedForPlayer )
		callbackFunc( player, pet )

	//create "no spawn" area for a few seconds where prowler spawns
	float timeout = GetCurrentPlaylistVarFloat( "squad_pet_no_spawn_area_timeout", 5.0 )
	float radius = GetCurrentPlaylistVarFloat( "squad_pet_no_spawn_area_radius", 96 )
	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, timeout, radius )

	AddEntityCallback_OnKilled( pet, void function ( entity npc, var damageInfo ) : ( player )
	{
		file.numPetsActive--
		if ( file.petsActive.contains( npc ) )
			file.petsActive.fastremovebyvalue( npc )

		//if ( GetCurrentPlaylistVarBool( "squad_pets_debug", false ) )
			printt( "***ACTIVE PETS: " + file.numPetsActive )

		int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

		entity killer = DamageInfo_GetAttacker( damageInfo )
		bool isKillerShadow = false

		                             
			isKillerShadow = IsPlayerShadowZombie( killer )
                                     

		if ( IsValid( killer ) && killer.IsPlayer() && !isKillerShadow )
			thread SpawnKilledPetRewardsForPlayer( killer, npc )

		thread function() : ( player, damageSourceId )
		{
			if ( !IsValid( player ) )
				return

			//try to spawn a new pet for player after cooldown
			player.EndSignal( "OnDeath" )

			if ( damageSourceId != damagedef_despawn )
				wait GetCurrentPlaylistVarFloat( "squad_pet_respawn_cooldown", 5 )
			else
				wait 1.0 //no cooldown if pet was just cleaned up because he was stuck

			if ( GetCurrentPlaylistVarBool( "respawn_queue_active", true ) )
			{
				float timeout = GetCurrentPlaylistVarFloat( "squad_pet_respawn_wait_for_queue_timeout", 1.0 )
				waitthread WaitTillSpawnQueueFree( timeout )
			}

			if ( !IsValid( player ) )
				return

			if ( !IsAlive( player ) )
				return

			if ( !ServerCanSpawnPet() )
				return

			int team = player.GetTeam()
			array<entity>players = GetPlayerArrayOfTeam_AliveConnected( team )
			if ( !TeamCanSpawnPet( players ) )
				return

			if ( !PlayerCanSpawnPet( player ) )
				return

			Point spawnPoint = GetRandomPetSpawnPointNearPos( player, player.GetOrigin() )

			if ( spawnPoint.origin == <0, 0, 0> )
			{
				Warning( "%s() -- Couldn't find pet spawn point near player %s", FUNC_NAME(), string( player ) )
				return
			}

			SpawnPetForPlayer( player, spawnPoint.origin, spawnPoint.angles )
		}()
	} )

	AddEntityCallback_OnDamaged( pet, void function ( entity npc, var damageInfo ) : ()
	{

		entity attacker = DamageInfo_GetAttacker( damageInfo )

		AssertPetFlags( npc )

		if ( !IsAlive( attacker ) )
			return

		if ( !attacker.IsPlayer() )
			return

		if ( IsValid( npc ) && IsFriendlyTeam( attacker.GetTeam(), npc.GetTeam() ) )
		{
			DamageInfo_SetDamage( damageInfo, 0 )

			if ( ( Time() - attacker.e.lastHintTimePetFriendlyFire ) > GetCurrentPlaylistVarFloat( "squad_pet_friendlyfire_hint_cooldown", 20 ) )
			{
				//callback is for messaging only so we don't spam the callback
				foreach ( callbackFunc in file.Callbacks_OnPetFriendlyfireMessaging )
					callbackFunc( attacker, npc )
			}
		}
	} )

	#if DEVELOPER
		if ( GetCurrentPlaylistVarBool( "squad_pets_debug", false ) )
			thread DebugPlayerPet( pet, player )
	#endif

}
#endif //SERVER




#if SERVER
void function OnDeathFieldStartShrink( table<int,DeathFieldData> deathFieldData )
{
	int deathStage = SURVIVAL_GetCurrentDeathFieldStage()
	int stageToStartSpawningPets = GetCurrentPlaylistVarInt( "squad_pet_round_to_start_spawning", 1 )
	if ( stageToStartSpawningPets != -1 && deathStage == stageToStartSpawningPets )
	{
		if ( !Flag( "SquadPetsActive" ) )
			FlagSet( "SquadPetsActive" )
	}

}
#endif //SERVER


#if SERVER
void function OnDeathFieldStopShrink( table<int,DeathFieldData> deathFieldData )
{

	//if ( Flag( "SquadPetsActive" ) )
		//CleanupServerPets()

}
#endif //SERVER


#if SERVER
void function OnPlayerTookDamage( entity damagedEnt, var damageInfo )
{
	if ( !IsValid( damagedEnt ) )
		return

	if ( !damagedEnt.IsPlayer() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	if ( !attacker.IsPlayer() )
		return

}
#endif //#if SERVER


#if SERVER
void function SquadPets_OnPlayerBleedoutStateChanged( entity player, int newState )
{
	if ( GetCurrentPlaylistVarBool( "squad_pet_attacks_downed_players", false ) == true )
		return

	if ( !IsValid( player ) )
		return

	if ( !IsAlive( player ) )
		return

	if ( newState == BS_ENTERING_BLEEDOUT )
	{
		player.SetNoTarget( true ) //prowlers leave you alone
	}
	else if ( newState == BS_NOT_BLEEDING_OUT )
	{
		player.SetNoTarget( false )
	}
}
#endif //#if SERVER


#if SERVER
void function SpawnKilledPetRewardsForPlayer( entity player, entity victim )
{
	if ( !IsAlive( player ) )
		return

	AssertIsNewThread()
	vector lootSpawnOrigin = victim.GetOrigin() + <0, 0, 64>
	vector up = player.GetUpVector()

	///////////////////////////////////////
	// Spawn some ammo for current weapons
	//////////////////////////////////////
	int maxWeaponsToSpawnAmmoFor = 1
	int countOverride = GetCurrentPlaylistVarInt( "kill_reward_ammo_count_override", -1 )
	float diceRoll = RandomFloat( 1 )
	float ammoDropChance = GetCurrentPlaylistVarFloat( "squad_pet_kill_reward_ammo_chance", 0.07 )
	if ( diceRoll <= ammoDropChance )
		SURVIVAL_ThrowPlayerAmmoFromPoint( player, lootSpawnOrigin, countOverride, maxWeaponsToSpawnAmmoFor )

	/////////////////////
	// Spawn some health
	/////////////////////
	float healthDropChance = GetCurrentPlaylistVarFloat( "squad_pet_kill_reward_health_chance", 0.06 )
	diceRoll = RandomFloat( 1 )
	if ( diceRoll <= healthDropChance )
	{
		WaitFrame()
		string healthRef = CoinFlip() ? "health_pickup_combo_small" : "health_pickup_health_small"
		SURVIVAL_ThrowLootFromPoint( lootSpawnOrigin, Normalize( ( RandomVecInDomeWithFOV( <0, 0, 1>, 45 ) * 1.2 ) + ( up * 0.35 ) ), healthRef )
	}

	float phoenixDropChance = GetCurrentPlaylistVarFloat( "squad_pet_kill_reward_phoenix_chance", 0.04 )
	diceRoll = RandomFloat( 1 )
	if ( diceRoll <= phoenixDropChance )
	{
		WaitFrame()
		SURVIVAL_ThrowLootFromPoint( lootSpawnOrigin, Normalize( ( RandomVecInDomeWithFOV( <0, 0, 1>, 45 ) * 1.2 ) + ( up * 0.35 ) ), "health_pickup_combo_full" )
	}
}
#endif //#if SERVER

/*
==========================================================
==========================================================
==========================================================

##     ## ######## #### ##       #### ######## ##    ##
##     ##    ##     ##  ##        ##     ##     ##  ##
##     ##    ##     ##  ##        ##     ##      ####
##     ##    ##     ##  ##        ##     ##       ##
##     ##    ##     ##  ##        ##     ##       ##
##     ##    ##     ##  ##        ##     ##       ##
 #######     ##    #### ######## ####    ##       ##

==========================================================
==========================================================
==========================================================
*/

#if SERVER
bool function PlayerHasPet( entity player )
{
	entity pet = GetPlayerPet( player )
	if ( !IsValid( pet ) )
		return false

	if ( !IsAlive( pet ) )
		return false

	return true
}
#endif //#if SERVER



#if SERVER
entity function GetPlayerPet( entity player )
{
	return player.e.pet
}
#endif //#if SERVER




#if SERVER
void function AddCallback_OnPetSpawnedForPlayer( void functionref(entity, entity) callbackFunc )
{
	Assert( !file.Callbacks_OnPetSpawnedForPlayer.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPetSpawnedForPlayer" )
	file.Callbacks_OnPetSpawnedForPlayer.append( callbackFunc )
}

#endif //#if SERVER




#if SERVER
array<entity> function GetTeamPets( array<entity> players )
{
	array<entity> pets
	foreach( player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( !IsAlive( player ) )
			continue

		entity pet = GetPlayerPet( player )
		if ( !IsValid( pet ) )
			continue

		pets.append( pet )
	}

	return pets
}
#endif //SERVER


#if SERVER
entity function GetBestPetOwnerForTeam( array<entity> players )
{
	Assert( players.len() > 0 )
	entity bestPetOwner = null


	int lowestHealth = 999
	foreach( player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( !IsAlive( player ) )
			continue

		                             
			if ( IsPlayerShadowZombie( player ) )
				continue
                                     

		if ( PlayerHasPet( player ) )
			continue

		int health = ( player.GetHealth() + player.GetShieldHealth() )
		if ( health < lowestHealth )
		{
			bestPetOwner = player
			lowestHealth = health
		}
	}

	return bestPetOwner
}
#endif //SERVER


#if SERVER
void function AssertPetFlags( entity pet )
{
	if ( GetBugReproNum() != 165717 )
		return

	if ( !IsValid( pet ) )
		return

	if ( !IsAlive( pet ) )
		return

	Assert( !pet.GetNPCFlag( NPC_IGNORE_ALL ) )
	Assert( !pet.GetNPCFlag( NPC_DISABLE_SENSING ) )
}

#endif //SERVER





#if SERVER
void function CleanupServerPets()
{
	PerfStart( PerfIndexServer.CleanupServerPets )

	array<entity> petsOnServer = clone file.petsActive
	array<entity> updatedPetsOnServer
	float maxDistSqFromOwner = file.maxPetDistFromOwner * file.maxPetDistFromOwner

	foreach( pet in petsOnServer )
	{
		if ( !IsValid( pet ) )
			continue

		if ( !IsAlive( pet ) )
			continue

		AssertPetFlags( pet )

		entity owner = pet.e.firstOwner
		if ( !IsAlive( owner ) )
		{
			//owner is gone
			GarbageCollectPet( pet )
			continue
		}
		else if ( pet.GetEnemy() == null && Distance2DSqr( owner.GetOrigin(), pet.GetOrigin() ) > maxDistSqFromOwner )
		{
			// pet is stuck somewhere and can't nav or has fallen too far behind
			// garbage collect and game will respawn one for the player
			GarbageCollectPet( pet )
			file.petsGarbageCollectedDueToDist++
			printt( "**PET CLEANUP - TOO FAR FROM OWNER: " + file.petsGarbageCollectedDueToDist )
			continue
		}

		updatedPetsOnServer.append( pet )
	}

	file.petsActive = updatedPetsOnServer

	PerfEnd( PerfIndexServer.CleanupServerPets )
}
#endif //SERVER


#if SERVER
void function CleanupPlayerPets( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !Flag( "SquadPetsActive" ) )
		return

	entity pet = GetPlayerPet( player )
	if ( IsValid( pet ) )
		GarbageCollectPet( pet )

}
#endif //SERVER


#if SERVER
void function GarbageCollectPet( entity pet )
{
	if ( !IsValid( pet ) )
		return

	if ( !IsAlive( pet ) )
		return

	if ( !Flag( "SquadPetsActive" ) )
		return

	pet.Die( svGlobal.worldspawn, svGlobal.worldspawn, { scriptType = DF_INSTANT, damageSourceId = damagedef_despawn } )

}
#endif //SERVER

#if SERVER
void function Survival_AddCallback_OnPetFriendlyfireMessaging( void functionref(entity, entity) callbackFunc )
{
	Assert( !file.Callbacks_OnPetFriendlyfireMessaging.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnPetFriendlyfireMessaging" )
	file.Callbacks_OnPetFriendlyfireMessaging.append( callbackFunc )
}
#endif //SERVER



#if SERVER && DEVELOPER
void function DebugPlayerPet( entity npc, entity owner )
{
	if ( !IsValid( npc ) )
		return

	if ( !IsValid( owner ) )
		return

	npc.EndSignal( "OnDeath" )
	owner.EndSignal( "OnDeath" )

	while( true )
	{
		DebugDrawLine( npc.GetOrigin(), owner.GetOrigin() + <0, 0, 36>, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 )
		DebugDrawSphere( npc.GetOrigin(), 16, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 )
		wait 0.05
	}

}
#endif //SERVER


