                                                           
global function ShGameModeShadowRoyale_Init
#if SERVER
	global function PlayHalloweenKillCommentary
#endif

#if CLIENT
	global function ServerCallback_ModeShadowRoyale_AnnouncementSplash
	global function ServerCallback_PlaySpectatorAnnouncer
	global function ServerCallback_PlayerRespawned
#endif

//const asset ICON_SPAWN_SHADOW_ENEMY		= $"rui/hud/gametype_icons/ltm/deathpos_skull_default_color"
//const asset ICON_SPAWN_SHADOW_FRIEND	= $"rui/hud/gametype_icons/ltm/deathpos_skull_legend"

const asset ICON_SPAWN_SHADOW_ENEMY		= $"rui/gamemodes/shadow_squad/shadow_icon_spawn_temp"
const asset ICON_SPAWN_SHADOW_FRIEND	= $"rui/gamemodes/shadow_squad/shadow_icon_spawn"
const asset DEATH_SCREEN_RUI            = $"ui/header_data_shadow_squad.rpak"

const array<string> SHADOW_ROYALE_DISABLED_BATTLE_CHATTER_EVENTS = [ "bc_killLeaderNew" ]

enum eShadowRoyaleMessage
{
	BLANK,
	SHADOW_LIVES_REMAINING,
	GAME_RULES_INTRO,
	GAME_RULES_LAND,
	REVENGE_KILL_KILLER,
	REVENGE_KILL_VICTIM,
	NO_MORE_SPAWNS_SOON,
	NO_MORE_SPAWNS,
	PETS_FOR_TEAMMATE,
	PETS_FOR_PLAYER,
	SHADOW_ABILITIES,
	PET_FRIENDLYFIRE

	_count
}

enum eShadowRoyaleSpectatorAudio
{
	TAUNT_SQUAD_WIPED,
	TAUNT_SQUAD_WIPED_REV,

	_count
}

enum eShadowAnnouncerCustom
{
	INITIAL_SKYDIVE,
	PLAYER_TOOK_REVENGE,
	SHADOW_RESPAWN_FIRST,
	SHADOW_RESPAWN,
}

struct
{
	#if SERVER
		bool messagingCompleteNoRespawns
		bool messagingCompleteNoRespawnsSoon
	#endif
}file
/*
===========================================================================
===========================================================================
===========================================================================

 ######      ###    ##     ## ########       #### ##    ## #### ########
##    ##    ## ##   ###   ### ##              ##  ###   ##  ##     ##
##         ##   ##  #### #### ##              ##  ####  ##  ##     ##
##   #### ##     ## ## ### ## ######          ##  ## ## ##  ##     ##
##    ##  ######### ##     ## ##              ##  ##  ####  ##     ##
##    ##  ##     ## ##     ## ##              ##  ##   ###  ##     ##
 ######   ##     ## ##     ## ########       #### ##    ## ####    ##

===========================================================================
===========================================================================
===========================================================================
*/

//SHARED
void function ShGameModeShadowRoyale_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	PrecacheSkinName( "ShadowSqaud" )

	#if SERVER
		FlagInit( "MessagingNearingTheEndComplete" )
		AddCallback_OnPlayerKilled( OnPlayerKilled )
		AddCallback_OnPlayerPostRespawned( OnPlayerPostRespawned )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )
		Survival_AddCallback_OnPlayerLaunchedFromPlane( OnPlayerLaunchedFromPlane )
		AddCallback_GameStateEnter( eGameState.PickLoadout, OnPickLoadout )
		AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
		SURVIVAL_AddCallback_OnDeathFieldStartShrink( OnDeathFieldStartShrink )
		SURVIVAL_AddCallback_OnDeathFieldStopShrink( OnDeathFieldStopShrink )
		AddCallback_OnPetSpawnedForPlayer( OnPetSpawnedForPlayer )
		Survival_AddCallback_OnPetFriendlyfireMessaging( OnPetFriendlyfireMessaging )
		Survival_AddCallback_OnSquadEliminated( OnSquadEliminated )
		AddDamageCallback( "player", OnPlayerTookDamage )
	#endif //SERVER

	#if CLIENT
		SetCustomScreenFadeAsset( $"ui/screen_fade_shadow_fall.rpak" )
		ClApexScreens_SetCustomApexScreenBGAsset( $"rui/rui_screens/banner_c_shadowfall" )
		ClApexScreens_SetCustomLogoTint( <1.0, 1.0, 1.0> )
		Survival_SetVictorySoundPackageFunction( GetVictorySoundPackage )
		AddCallback_GameStateEnter( eGameState.Playing, ShadowRoyale_OnPlaying )
		AddCallback_OnVictoryCharacterModelSpawned( OnVictoryCharacterModelSpawned )
		AddCallback_OnPingCreatedByAnyPlayer( OnPingCreatedByAnyPlayer_CustomReviveText )
	#endif //CLIENT

	Gamemode_ShadowRoyale_RegisterNetworking()
}
//END SHARED


//SHARED
void function Gamemode_ShadowRoyale_RegisterNetworking()
{
	Remote_RegisterClientFunction( "ServerCallback_ModeShadowRoyale_AnnouncementSplash", "int", 0, eShadowRoyaleMessage._count )
	Remote_RegisterClientFunction( "ServerCallback_PlaySpectatorAnnouncer", "int", 0, eShadowRoyaleSpectatorAudio._count )
	Remote_RegisterClientFunction( "ServerCallback_PlayerRespawned", "entity" )
}
//END SHARED

//SHARED
void function EntitiesDidLoad()
{
	if ( IsMenuLevel() )
		return

	#if SERVER
		//hack for lootbins not getting usable by shadows
		foreach( bin in GetAllLootBins() )
		{
			if ( IsValid( bin ) )
				bin.AddUsableValue( USABLE_CAN_USE_OVERRIDE )
		}
	#endif //SERVER

	SurvivalCommentary_SetHost( eSurvivalHostType.NOC )
}
//END SHARED

#if CLIENT
void function ShadowRoyale_OnPlaying()
{
	if ( GetCurrentPlaylistVarFloat( "shadow_spawn_pos_display_time", 5 ) > 0 )
	{
		SetMapFeatureItem( 1000, "#SHADOWROYALE_SHADOW_SPAWN_ENEMY", "#SHADOWROYALE_SHADOW_SPAWN_ENEMY_DESC", ICON_SPAWN_SHADOW_ENEMY )
		SetMapFeatureItem( 1000, "#SHADOWROYALE_SHADOW_SPAWN_FRIEND", "#SHADOWROYALE_SHADOW_SPAWN_FRIEND_DESC", ICON_SPAWN_SHADOW_FRIEND )
	}

	// needs to be post-init
	DeathScreen_SetDataRuiAssetForGamemode( DEATH_SCREEN_RUI )
}
#endif //CLIENT


/*
===============================================================================================
===============================================================================================
===============================================================================================

########  ########  ######  ########     ###    ##      ## ##    ## #### ##    ##  ######
##     ## ##       ##    ## ##     ##   ## ##   ##  ##  ## ###   ##  ##  ###   ## ##    ##
##     ## ##       ##       ##     ##  ##   ##  ##  ##  ## ####  ##  ##  ####  ## ##
########  ######    ######  ########  ##     ## ##  ##  ## ## ## ##  ##  ## ## ## ##   ####
##   ##   ##             ## ##        ######### ##  ##  ## ##  ####  ##  ##  #### ##    ##
##    ##  ##       ##    ## ##        ##     ## ##  ##  ## ##   ###  ##  ##   ### ##    ##
##     ## ########  ######  ##        ##     ##  ###  ###  ##    ## #### ##    ##  ######

===============================================================================================
===============================================================================================
===============================================================================================
*/

#if SERVER
void function OnDeathFieldStartShrink( table<int,DeathFieldData> deathFieldData )
{
	int deathStage = SURVIVAL_GetCurrentDeathFieldStage()

	//messaging: no more spawns after this stage
	if ( deathStage == GetSpawnNearSquadEndingStage() && !file.messagingCompleteNoRespawnsSoon )
	{
		file.messagingCompleteNoRespawnsSoon = true
		thread ShadowRoyaleSplashToAllDelayed( eShadowRoyaleMessage.NO_MORE_SPAWNS, 1.0 )
	}

	if ( !Flag( "MessagingNearingTheEndComplete" ) && GetNumTeamsRemaining() < 8 )
		thread PlayNearingTheEndMessagingAndMusic()
}
#endif //SERVER


#if SERVER
void function OnDeathFieldStopShrink( table<int,DeathFieldData> deathFieldData )
{
	int deathStage = SURVIVAL_GetCurrentDeathFieldStage()


	//messaging: no more spawns after this stage
	if ( deathStage == GetSpawnNearSquadEndingStage()-1 && !file.messagingCompleteNoRespawns )
	{
		file.messagingCompleteNoRespawns = true
		thread ShadowRoyaleSplashToAllDelayed( eShadowRoyaleMessage.NO_MORE_SPAWNS_SOON, 1.0 )
	}

	if ( !Flag( "MessagingNearingTheEndComplete" ) && GetNumTeamsRemaining() < 8 )
		thread PlayNearingTheEndMessagingAndMusic()

}
#endif //SERVER


#if SERVER
void function PlayNearingTheEndMessagingAndMusic()
{
	wait 10

	if ( GetGameState() != eGameState.Playing )
		return

	int numTeamsRemaining = GetNumTeamsRemaining()

	if ( numTeamsRemaining < 3 ) //to close to game end...abort
		return


	FlagSet( "MessagingNearingTheEndComplete" )

	array<entity> validPlayers
	foreach( player in GetPlayerArray_AliveConnected() )
	{
		//don't play music for players who just respawned
		if ( Time() < ( player.GetPlayerNetTime( "respawnStatusEndTime" ) + 8 ) )
			continue

		validPlayers.append( player )
		StopAllMusicOnPlayer( player )
		PlayMusicToPlayer( player, "Music_LTM_Halloween20_NinetySeconds" )
	}

	//You can’t keep the dead asleep. Better start running
	//Don't worry...it's almost over.
	//It's nearing the end
	//I like it when you all flee.
	//It'll all be over soon.
	//Enjoy these final moments. Some of you will die.
	thread PlayCommentaryLineToPlayerArray( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.EVAC_SHIP_INCOMING ), validPlayers )

}
#endif //SERVER


#if SERVER
void function OnPlayerKilled( entity victim, entity killer, var damageInfo )
{
	if ( IsPlayerShadowZombie( victim ) )
	{
		ShadowZombieOnDeath( victim )
		if ( IsValid( killer ) && killer.IsPlayer() && IsAlive( killer ) && !IsPlayerShadowZombie( killer ) )
		{
			thread SpawnShadowRoyaleRewardsForPlayer( killer, victim )
			if ( !killer.IsBot() && !killer.e.hasBeenOpened && ( PlayerGameSummary_GetKills( killer ) > 1 ) && CoinFlip() )
			{
				killer.e.hasBeenOpened = true //hackily co-opting this bool to see if we've played this dialogue line yet
				thread function() : ( killer )
				{
					killer.EndSignal( "OnDeath" )
					wait 7.0

					if ( !IsValid( killer ) )
						return

					if ( !IsAlive( killer ) )
						return

					//gotta kill all these motherfuckin shadows on this motherfuckin plane to take down the squad
					PlayBattleChatterLineToSpeakerAndTeam( killer, "bc_shRoyaleMidMatch" )
				}()
			}

		}

	}

	if ( !IsPlayerShadowZombie( victim ) && IsAlive( killer ) && IsValid( killer ) && IsPlayerShadowZombie( killer ) && DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.human_execution )
	{
		//give shadows full health if they execute a player
		int currentHealth = killer.GetHealth()
		int shadowMaxHealth = GetCurrentPlaylistVarInt( "shadow_health", 65 )
		if ( currentHealth < shadowMaxHealth )
		{
			killer.SetHealth( shadowMaxHealth )
			//EmitSoundOnEntity( killer, "health_syringe_holster" )
		}
	}
	if ( victim.IsBot() )
		victim.p.numberOfDeaths++ //needed for debugging with bots

	thread PlayHalloweenKillCommentary( killer, victim )

	/////////////////
	// Revenge Kill?
	/////////////////
	if ( GamemodeUtility_WasRevengeKill( victim, killer ) )
	{
		GamemodeUtility_RemovePlayerFromRevengeKillList( killer, victim )
		thread AnnouncerCustomComms( killer, eShadowAnnouncerCustom.PLAYER_TOOK_REVENGE )
		thread AnnouncerCustomComms( victim, eShadowAnnouncerCustom.PLAYER_TOOK_REVENGE )
		ShadowRoyaleSplashToPlayer( killer, eShadowRoyaleMessage.REVENGE_KILL_KILLER )
		if ( !IsTeamEliminated( victim.GetTeam() ) )
			ShadowRoyaleSplashToPlayer( victim, eShadowRoyaleMessage.REVENGE_KILL_VICTIM )
	}

	if ( !victim.e.previousKillers.contains( killer ) )
		victim.e.previousKillers.append( killer )


	CheckIfVictimsTeamShouldBeEliminated( victim )

	if ( victim.GetPlayerNetInt( "respawnStatus" ) == eRespawnStatus.SQUAD_ELIMINATED )
	{
		//Revenant taunts wiped player
		int tauntAnnouncerIndex = eShadowRoyaleSpectatorAudio.TAUNT_SQUAD_WIPED
		if ( IsPlayerRevenant( victim ) )
			tauntAnnouncerIndex = eShadowRoyaleSpectatorAudio.TAUNT_SQUAD_WIPED_REV

		Remote_CallFunction_NonReplay( victim, "ServerCallback_PlaySpectatorAnnouncer", tauntAnnouncerIndex )
	}

}
#endif //SERVER

#if SERVER
void function SpawnShadowRoyaleRewardsForPlayer( entity player, entity victim )
{
	if ( !IsAlive( player ) )
		return

	AssertIsNewThread()
	vector lootSpawnOrigin = victim.GetOrigin() + <0, 0, 64>
	vector up = player.GetUpVector()

	///////////////////////////////////////
	// Spawn some ammo for current weapons
	//////////////////////////////////////
	int maxWeaponsToSpawnAmmoFor = CoinFlip() ? 1 : 2
	int countOverride = GetCurrentPlaylistVarInt( "kill_reward_ammo_count_override", -1 )
	SURVIVAL_ThrowPlayerAmmoFromPoint( player, lootSpawnOrigin, countOverride, maxWeaponsToSpawnAmmoFor )

	/////////////////////
	// Spawn some health
	/////////////////////
	float healthDropChance = GetCurrentPlaylistVarFloat( "kill_reward_health_chance", 0.15 )
	float diceRoll = RandomFloat( 1 )
	if ( diceRoll <= healthDropChance )
	{
		WaitFrame()
		string healthRef = CoinFlip() ? "health_pickup_combo_small" : "health_pickup_health_small"
		SURVIVAL_ThrowLootFromPoint( lootSpawnOrigin, Normalize( ( RandomVecInDomeWithFOV( <0, 0, 1>, 45 ) * 1.2 ) + ( up * 0.35 ) ), healthRef )
	}

	float phoenixDropChance = GetCurrentPlaylistVarFloat( "kill_reward_phoenix_chance", 0.05 )
	diceRoll = RandomFloat( 1 )
	if ( diceRoll <= phoenixDropChance )
	{
		WaitFrame()
		SURVIVAL_ThrowLootFromPoint( lootSpawnOrigin, Normalize( ( RandomVecInDomeWithFOV( <0, 0, 1>, 45 ) * 1.2 ) + ( up * 0.35 ) ), "health_pickup_combo_full" )
	}
}
#endif //#if SERVER


#if SERVER
void function CheckIfVictimsTeamShouldBeEliminated( entity player )
{
	if ( !IsValid( player ) )
		return

	int team = player.GetTeam()
	if ( AreTeammatesShadowZombies( player ) )
	{
		foreach ( entity teamMate in GetPlayerArrayOfTeam( team ) )
		{
			player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.SQUAD_ELIMINATED )
			if ( IsAlive( teamMate ) )
				KillPlayer( teamMate, eDamageSourceId.damagedef_suicide )
		}
		return
	}
}
#endif //SERVER



#if SERVER
void function OnPlayerPostRespawned( entity player )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( GetTotalNumberOfDeaths( player ) == 0 )
		return

	GiveShadowZombieAbilities( player )
	player.MakeVisible()
	player.Solid()

	thread ShadowRoyaleSplashToPlayerDelayed( player, eShadowRoyaleMessage.SHADOW_LIVES_REMAINING, 0.5 )
	int respawnCustomAnnouncerMessage = eShadowAnnouncerCustom.SHADOW_RESPAWN_FIRST
	int playerDeaths = GetTotalNumberOfDeaths( player )
	if (  playerDeaths > 1 )
		respawnCustomAnnouncerMessage = eShadowAnnouncerCustom.SHADOW_RESPAWN

	bool displayAbilitiesHint
	int numTimesDisplayAbilitiesHint = GetCurrentPlaylistVarInt( "shadow_ability_hint_display_on_respawn_times", 10 )

	if ( numTimesDisplayAbilitiesHint == -1 )
		displayAbilitiesHint = true

	else if ( numTimesDisplayAbilitiesHint == 0 )
		displayAbilitiesHint = false

	else if ( playerDeaths <= numTimesDisplayAbilitiesHint )
		displayAbilitiesHint = true

	else
		displayAbilitiesHint = false

	if ( displayAbilitiesHint )
		thread ShadowRoyaleSplashToPlayerDelayed( player, eShadowRoyaleMessage.SHADOW_ABILITIES, 10 )

	thread AnnouncerCustomComms( player, respawnCustomAnnouncerMessage )
	thread DisplayShadowSpawnLocation( player )
	thread function() : ( player )
	{
		player.EndSignal( "OnDeath" )
		wait 0.5
		if ( !IsAlive( player ) )
			return

		StopAllMusicOnPlayer( player )
		PlayMusicToPlayer( player, "Music_LTM_Halloween20_RespawnAndDrop" )
		EmitSoundAtPositionExceptToPlayer( player.GetTeam(), player.GetOrigin() + < 0, 0, 72>, player, "ShadowLegend_Shadow_SpawnRoar" )
	}()

	array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach( teammate in teammates)
		Remote_CallFunction_NonReplay( teammate, "ServerCallback_PlayerRespawned", player )

	Survival_SetFriendlyHighlight( player )

}
#endif //SERVER


#if SERVER
void function DisplayShadowSpawnLocation( entity shadowPlayer )
{
	AssertIsNewThread()

	if ( !IsValid( shadowPlayer ) )
		return

	shadowPlayer.EndSignal( "OnDeath" )

	float timeToDisplayShadowSpawnPos = GetCurrentPlaylistVarFloat( "shadow_spawn_pos_display_time", 5 )
	if ( timeToDisplayShadowSpawnPos == 0 )
		return

	wait 1.0

	if ( !IsValid( shadowPlayer ) )
		return

	int shadowPlayerTeam = shadowPlayer.GetTeam()

	vector spawnPos = OriginToGround( shadowPlayer.GetOrigin() + <0, 0, 16> ) + <0, 0, 72>

	array<entity> waypoints
	float radiusToDisplayIcon = GetCurrentPlaylistVarFloat( "shadow_spawn_pos_display_dist", 8000 )

	////////////////////////////////////////////////
	// Dislay "friend" shadow icon to squad mates
	////////////////////////////////////////////////
	array<entity> squadMates = GetPlayerArrayOfTeam_AliveConnected( shadowPlayerTeam )
	foreach( squadMate in squadMates )
	{
		//only need to create it for other teammates to see
		if ( squadMate == shadowPlayer )
			continue

		int attachmentID = shadowPlayer.LookupAttachment( "HEADSHOT" )
		vector attachmentOrigin = shadowPlayer.GetAttachmentOrigin( attachmentID ) + <0, 0, 128>
		entity wpFriendly = CreatePlayerWaypoint_Wrapper( eWaypoint.BASIC_ENTITY )
		wpFriendly.SetOrigin( attachmentOrigin )
		wpFriendly.SetWaypointEntity( 0, shadowPlayer )
		wpFriendly.SetWaypointString( 0, "#SPAWN_HINT" )
		wpFriendly.SetWaypointAsset( 0, ICON_SPAWN_SHADOW_FRIEND )
		wpFriendly.SetOnlyTransmitToOnePlayer( squadMate )
		waypoints.append( wpFriendly )
	}

	vector minimapSpawnPos = <spawnPos.x, spawnPos.y, 0>
	if ( squadMates.len() > 0 && IsValidRingPulsePos( minimapSpawnPos ) )
		Minimap_RingPulseForTeam( shadowPlayerTeam, minimapSpawnPos, 20, timeToDisplayShadowSpawnPos, 8, TEAM_COLOR_FRIENDLY / 255.0 )

	////////////////////////////////////////////////
	// Dislay "enemy" shadow icon to all other teams
	////////////////////////////////////////////////
	array<entity> nearbyEnemyPlayers = GetPlayerArrayEx( "any", TEAM_ANY, shadowPlayerTeam, spawnPos, radiusToDisplayIcon )
	array<int> enemyTeamsProcessed
	foreach( enemy in nearbyEnemyPlayers )
	{

		if ( !IsValid( enemy ) )
			continue

		int enemyTeam = enemy.GetTeam()
		if ( enemyTeamsProcessed.contains( enemyTeam ) )
			continue

		entity wp = CreateWaypoint_BasicPos( spawnPos, "#SPAWN_HINT", ICON_SPAWN_SHADOW_ENEMY )
		waypoints.append( wp )
		wp.SetParent( shadowPlayer )
		wp.SetOwner( shadowPlayer )
		wp.SetOnlyTransmitToSingleTeam( enemyTeam )
		if ( IsValidRingPulsePos( minimapSpawnPos ) )
			Minimap_RingPulseForTeam( enemyTeam, minimapSpawnPos, 20, timeToDisplayShadowSpawnPos, 8, TEAM_COLOR_ENEMY / 255.0 )
		enemyTeamsProcessed.append( enemyTeam )

	}

	OnThreadEnd(
		function() : ( waypoints )
		{
			foreach( wp in waypoints )
			{
				if ( IsValid( wp ) )
					wp.Destroy()
			}

			/*
			if ( IsValid( fxBeam ) )
			{
				EffectStop( fxBeam )
				fxBeam.Destroy()
			}
			*/
		}
	)

	wait timeToDisplayShadowSpawnPos
}
#endif //SERVER


#if SERVER
void function OnPickLoadout()
{
	thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CHAR_SELECT_TAUNT ), 0.5 )
}
#endif //SERVER


#if SERVER
void function OnWinnerDetermined()
{
	thread ShadowRoyaleSplashToAll( eShadowRoyaleMessage.BLANK )
	thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.WINNER ), 6.0 )
}
#endif //SERVER

/*
===============================================================================================
===============================================================================================
===============================================================================================

 ######      ###    ##     ## ########       ##        #######   ######   ####  ######
##    ##    ## ##   ###   ### ##             ##       ##     ## ##    ##   ##  ##    ##
##         ##   ##  #### #### ##             ##       ##     ## ##         ##  ##
##   #### ##     ## ## ### ## ######         ##       ##     ## ##   ####  ##  ##
##    ##  ######### ##     ## ##             ##       ##     ## ##    ##   ##  ##
##    ##  ##     ## ##     ## ##             ##       ##     ## ##    ##   ##  ##    ##
 ######   ##     ## ##     ## ########       ########  #######   ######   ####  ######

===============================================================================================
===============================================================================================
===============================================================================================
*/

#if CLIENT
VictorySoundPackage function GetVictorySoundPackage()
{
	VictorySoundPackage victorySoundPackage
	float randomFloat = RandomFloatRange( 0, 1 )
	bool isSoloWin = false
	bool isRevenantInSquad = false
	bool oneHumanRemaining = false
	int playersOnPodium
	int shadowsOnPodium
	LoadoutEntry loadoutSlotCharacter = Loadout_Character()

	//////////////////////////////////////////////////////
	// Solo victory? Revenant in there? All shadows? etc
	//////////////////////////////////////////////////////
	foreach ( SquadSummaryPlayerData data in GetWinnerSquadSummaryData().playerData )
	{
		if ( !LoadoutSlot_IsReady( data.eHandle, loadoutSlotCharacter ) )
			continue

		ItemFlavor character = LoadoutSlot_GetItemFlavor( data.eHandle, loadoutSlotCharacter )
		string characterName = ItemFlavor_GetCharacterRef( character )
		if ( characterName == "character_revenant" )
			isRevenantInSquad = true

		entity playerEnt = GetEntityFromEncodedEHandle( data.eHandle )
		if ( IsPlayerShadowZombie( playerEnt ) )
			shadowsOnPodium++

		playersOnPodium++
	}

	if ( playersOnPodium == 1 )
		isSoloWin = true

	if ( ( playersOnPodium - shadowsOnPodium ) == 1 )
		oneHumanRemaining = true


	if ( isSoloWin && isRevenantInSquad )
	{
		///////////////////////
		// Solo Revenant win
		///////////////////////
		victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_01_3p" //revenant: you are our apex champion squad hahaha they'll be gunning for you now
		victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_winnerDecidedTrios_02_01_3p" //revanant: The winning squad is decided. But death will find them soon.
		if ( randomFloat < 0.25 )
		{
			victorySoundPackage.youAreChampSingular = "diag_ap_nocnotify_legendwintriosrev_01_3p" //( sigh ) My lazy, worthless double won. What a disgrace.
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocnotify_legendwintriosrev_01_3p" //( sigh ) My lazy, worthless double won. What a disgrace.
		}
		else if ( randomFloat >= 0.25 && randomFloat < 0.5 )
		{
			victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_winnerFoundRev_01_02_3p" //We have a winner. You're finally thinking like me. About time.
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_winnerFoundRev_02_01_3p" //My double's the Champion. He'll reach my level. Someday. Maybe.
		}
		else if ( randomFloat >= 0.5 && randomFloat < 0.75 )
		{
			victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_winnerFoundRev_03_01_3p" //The other me won. Keep it up and someday I might have to congratulate you in person
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_winnerFoundRev_02_01_3p" //My double's the Champion. He'll reach my level. Someday. Maybe.
		}
		else
		{
			victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_winnerFoundRev_03_02_3p" //The other me won. Keep it up and someday I might have to congratulate you in person
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocnotify_legendwintriosrev_01_3p" //( sigh ) My lazy, worthless double won. What a disgrace.
		}

	}
	else if ( !isSoloWin && oneHumanRemaining )
	{
		///////////////////
		// Mostly shadows
		///////////////////
		victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_02_3p" //revenant: you are our apex champions...don't get too comfortable
		victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_03_3p" //revenant: you're the apex champion...kill for my entertainment
		victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_02_3p" //revanant: we've got our apex champion.....they got lucky this time
		if ( randomFloat < 0.25 )
		{
			victorySoundPackage.youAreChampPlural = "diag_ap_nocnotify_legendwintrios_01_3p" //One member of our Champion Squad isn't a shadow... yet.
			victorySoundPackage.theyAreChampPlural = "diag_ap_nocnotify_legendwintrios_01_3p" //One member of our Champion Squad isn't a shadow... yet.
		}
		else if ( randomFloat < 0.50 )
		{
			victorySoundPackage.youAreChampPlural = "diag_ap_nocnotify_legendwintrios_01_3p" //One lone skinbag wins. I'm sure his shadowsquad will let him remain that way
			victorySoundPackage.theyAreChampPlural = "diag_ap_nocnotify_legendwintrios_01_3p" //One lone skinbag wins. I'm sure his shadowsquad will let him remain that way
		}
		else if ( randomFloat < 0.75 )
		{
			victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_winnerDecidedTrios_02_01_3p" //revanant: The winning squad is decided. But death will find them soon.
		}
		else
		{
			victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_victorySquad_04_3p" //revanant: meet our champion squad. Targets on their back...every last one
		}

	}
	else if ( randomFloat < 0.33 )
	{
		////////////////////////////
		// Random generic package 1
		////////////////////////////
		victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_01_3p" //revenant: you are our apex champion squad hahaha they'll be gunning for you now
		victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_03_3p" //revenant: you're the apex champion...kill for my entertainment
		victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_01_3p" //revanant: we've got our apex champion.
		victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_winnerDecidedTrios_02_01_3p" //revanant: The winning squad is decided. But death will find them soon.
	}
	else if ( randomFloat < 0.66 )
	{
		////////////////////////////
		// Random generic package 2
		////////////////////////////
		victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_02_3p" //revenant: you are our apex champions...dscrion't get too comfortable
		victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_04_3p" //revenant: ugh...congratulations...you're the apex champion
		victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_02_3p" //revanant: we've got our apex champion.....they got lucky this time
		victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_winnerDecidedTrios_05_02_3p" //revanant: We have our winning squad....maybe next time they'll die.
	}
	else
	{
		////////////////////////////
		// Random generic package 3
		////////////////////////////
		victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_03_3p" //revenant: you are the champions...for now
		victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_05_3p" //revenant: you're my apex champion
		victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_01_3p" //revanant: we've got our apex champion //02
		victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_victorySquad_04_3p" //revanant: meet our champion squad. Targets on their back...every last one
	}


	///////////////////////////////////////////////////////
	// Sometimes call out solo non-shadow winner, if that's the case
	///////////////////////////////////////////////////////
	if ( isSoloWin && !isRevenantInSquad && randomFloat < 0.2 )
	{
		if ( CoinFlip() )
		{
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_legendWin_01_3p" //We have a lone winner. For now
		}
		else
		{
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_legendWin_02_3p" //So a Legend won. They’ll join me soon enough
		}
	}

	return victorySoundPackage
}
#endif // CLIENT




#if SERVER
void function OnPlayerDisconnected( entity player )
{
	CheckIfVictimsTeamShouldBeEliminated( player )
}
#endif //#if SERVER




#if SERVER
void function OnPlayerTookDamage( entity damagedEnt, var damageInfo )
{
	if ( !IsValid( damagedEnt ) )
		return

	if ( !damagedEnt.IsPlayer() )
		return

	if ( !IsPlayerShadowZombie( damagedEnt ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	if ( !attacker.IsPlayer() )
		return

	if ( !IsPlayerShadowZombie( attacker ) )
		return

	//Shadows do one-hit kill to other shadows
	//int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	//if ( IsValid( damageSourceId ) && damageSourceId == eDamageSourceId.melee_shadowsquad_hands )
	DamageInfo_SetDamage( damageInfo, damagedEnt.GetHealth() + 1 )

}
#endif //#if SERVER

/*
===============================================================================================
===============================================================================================
===============================================================================================

##     ## ########  ######   ######     ###     ######   #### ##    ##  ######
###   ### ##       ##    ## ##    ##   ## ##   ##    ##   ##  ###   ## ##    ##
#### #### ##       ##       ##        ##   ##  ##         ##  ####  ## ##
## ### ## ######    ######   ######  ##     ## ##   ####  ##  ## ## ## ##   ####
##     ## ##             ##       ## ######### ##    ##   ##  ##  #### ##    ##
##     ## ##       ##    ## ##    ## ##     ## ##    ##   ##  ##   ### ##    ##
##     ## ########  ######   ######  ##     ##  ######   #### ##    ##  ######

===============================================================================================
===============================================================================================
===============================================================================================
*/


#if SERVER
void function PlayHalloweenKillCommentary( entity killer, entity victim )
{
	AssertIsNewThread()
	wait 1.75

	if ( !ShouldPlayHolloweenKillCommentary( killer ) )
		return

	PlayBattleChatterLineToSpeakerAndTeam( killer, "bc_happyHaloween" )
}
#endif //#if SERVER


#if SERVER
bool function ShouldPlayHolloweenKillCommentary( entity killer )
{
	if ( !IsValid( killer ) )
		return false

	if ( !IsAlive( killer ) )
		return false

	if ( !killer.IsPlayer() )
		return false

	if ( killer.IsBot() )
		return false

	if ( IsPlayerShadowZombie( killer ) )
		return false

	if ( PlayerGameSummary_GetKills( killer ) > 1 )
		return false

	return true
}
#endif //#if SERVER


#if SERVER
void function ShadowRoyaleSplashToPlayer( entity player, int index )
{
	if ( GetGameState() > eGameState.Playing )
		return

	Remote_CallFunction_NonReplay( player, "ServerCallback_ModeShadowRoyale_AnnouncementSplash", index )
}
#endif //SERVER


#if SERVER
void function ShadowRoyaleSplashToPlayerDelayed( entity player, int index, float delay )
{
	AssertIsNewThread()
	wait( delay )
	if ( !IsAlive( player ) )
		return

	ShadowRoyaleSplashToPlayer( player, index )
}
#endif //SERVER

#if SERVER
void function ShadowRoyaleSplashToAll( int index )
{
	foreach ( player in GetPlayerArray() )
		ShadowRoyaleSplashToPlayer( player, index )
}
#endif //SERVER

#if SERVER
void function ShadowRoyaleSplashToAllDelayed( int index, float delay )
{
	AssertIsNewThread()
	wait( delay )
	ShadowRoyaleSplashToAll( index )
}
#endif //SERVER

#if SERVER
void function OnPlayerLaunchedFromPlane( entity player )
{
	ShadowRoyaleSplashToPlayer( player, eShadowRoyaleMessage.GAME_RULES_INTRO )
	thread AnnouncerCustomComms( player, eShadowAnnouncerCustom.INITIAL_SKYDIVE )
	if ( !player.GetPlayerNetBool( "isJumpmaster" ) )
		return

	//threading speaking thread for double revenant announcer lines
	int team = player.GetTeam()
	thread function() : ( player, team )
	{
		wait 10
		entity speakingPlayer
		array<entity> squadMates = GetPlayerArrayOfTeam( team )
		squadMates.randomize()
		foreach ( entity squadMate in squadMates )
		{
			if ( !IsValid( squadMate ) )
				continue

			if ( !IsAlive( squadMate ) )
				continue

			PlayBattleChatterLineToSpeakerAndTeam( squadMate, "bc_shRoyaleRev" )
			break
		}
	}()
}
#endif //SERVER

#if CLIENT || SERVER
bool function IsPlayerRevenant( entity player )
{
	if ( !IsValid( player ) )
		return false

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterName = ItemFlavor_GetCharacterRef( character )
	if ( characterName != "character_revenant" )
		return false

	return true
}
#endif //CLIENT || SERVER

#if SERVER
void function AnnouncerCustomComms( entity player, int customAnnouncement )
{
	AssertIsNewThread()
	array <string> dialogueChoices
	array <string> dialogueChoicesResponsesFromRevenant
	float announcerCommsDelay = 0

	bool isPlayerRevenant = IsPlayerRevenant( player )

	// NOTE: this should have actually all be done with "Category Buckets" in survival_host_dialoguue.csv
	// Re-purposing last year's LTM and didn't have time to update

	switch( customAnnouncement )
	{
		case eShadowAnnouncerCustom.INITIAL_SKYDIVE:
			//Death is never the end. Not in my world
			//Survival is not just for the living
			//New ready up taunts - legends are back
			dialogueChoices.append( "diag_ap_nocNotify_skydiveTaunt_01_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_skydiveTaunt_01_02_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_skydiveTaunt_02_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_skydiveTaunt_02_02_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_readyUpA_05_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_readyUpA_05_02_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_readyUpA_06_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_readyUpA_06_02_3p" )
			announcerCommsDelay = 4.0
			break

		case eShadowAnnouncerCustom.SHADOW_RESPAWN_FIRST:
			if ( isPlayerRevenant )
			{
				//Now maybe you'll see your true potential, as one of my Shadows.
				dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirstRev_01_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirstRev_01_02_3p" )

				//Perhaps time as a Shadow will teach my counterpart humility.
				dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirstRev_02_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirstRev_02_02_3p" )

				//My arrogant doppelganger falls. Not surprising.
				dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirstRev_03_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirstRev_03_02_3p" )

				//another use
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_04_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_04_02_3p" )
				//emptahy, you're supposed to be a killer
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_05_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_05_02_3p" )

				announcerCommsDelay = 2.0

				//PENDING RESPONSES
				//dialogueChoicesResponsesFromRevenant.append( "XXX" )
			}
			else
			{
				float randomFloat = RandomFloatRange( 0, 1 )
				if ( randomFloat <= 0.33 && IsValid( player ) )
				{
					//1/3 chance to get new character specific lines
					ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
					string characterName = ItemFlavor_GetCharacterRef( character )
					string characterNameTruncated = characterName.slice( 10 )
					string characterNameTruncatedCapitalized = characterNameTruncated.slice( 0,1 ).toupper() + characterNameTruncated.slice( 1 )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad" + characterNameTruncatedCapitalized + "_01_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad" + characterNameTruncatedCapitalized + "_01_02_3p" )
				}
				else
				{
					//Now you're mine!
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_04_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_04_02_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_06_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_06_02_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_07_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_07_02_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_07_03_3p" )
					//no time for rest...the shadow squad could use another
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_01_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_01_02_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_01_03_3p" )
					//oh you're far from done....join the shadows
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_02_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_02_02_3p" )
					//the shadows are your home now
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_03_01_3p" )
					dialogueChoices.append( "diag_ap_nocNotify_playerDeathFirst_03_02_3p" )
				}

				announcerCommsDelay = 2.0
			}
			break


		case eShadowAnnouncerCustom.SHADOW_RESPAWN:
			//come back for more? good
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_05_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_05_02_3p" )

			//welcome back
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_02_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_02_02_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_02_03_3p" )

			if ( isPlayerRevenant )
			{
				//I'll keep resurrecting you until you admit you'll always be in my shadow.
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_01_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_01_02_3p" )

				//You shall continue to respawn until I say otherwise.
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_02_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_02_02_3p" )

				//You died again?! I'm ashamed to share a name with you
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_03_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquadRev_03_02_3p" )

				//laugh
				dialogueChoices.append( "diag_ap_nocNotify_revengeKill_01_01_3p" )

			}
			else
			{
				//revenge is calling
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_03_01_3p" )
				dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_03_02_3p" )
			}

			announcerCommsDelay = 2.0
			break

		case eShadowAnnouncerCustom.PLAYER_TOOK_REVENGE:
			//revenge!
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_01_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_01_02_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_playerBecomesShadowSquad_01_03_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_revengeKill_01_01_3p" )
			dialogueChoices.append( "diag_ap_nocNotify_revengeKill_01_02_3p" )

			announcerCommsDelay = 1.5
			break
	}

	string lineToPlay = dialogueChoices.getrandom()

	if ( announcerCommsDelay > 0 )
		wait announcerCommsDelay

	if ( !IsValid( player ) )
		return

	if ( AreTeammatesShadowZombies( player ) )
		return

	EmitSoundOnEntityOnlyToPlayer( player, player, lineToPlay )

	if ( dialogueChoicesResponsesFromRevenant.len() > 0 && isPlayerRevenant )
	{
		string responseLineToPlay = dialogueChoicesResponsesFromRevenant.getrandom()

		thread function() : ( player, responseLineToPlay )
		{
			player.EndSignal( "OnDeath" )
			wait 7.5
			if ( !IsAlive( player ) )
				return

			EmitSoundOnEntityOnlyToPlayer( player, player, responseLineToPlay )
		}()
	}

}
#endif //SERVER

#if CLIENT
void function ServerCallback_ModeShadowRoyale_AnnouncementSplash( int messageIndex )
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	float duration = 8.0
	string messageText
	string subText
	vector titleColor = <0, 0, 0>
	asset icon = $""
	asset leftIcon = $"rui/gamemodes/shadow_squad/shadow_icon_orange"
	asset rightIcon = $"rui/gamemodes/shadow_squad/shadow_icon_orange"
	//asset leftIcon = $"rui/gamemodes/shadow_squad/legend_icon"
	//asset rightIcon = $"rui/gamemodes/shadow_squad/legend_icon"
	string soundAlias = "ui_ingame_shadowsquad_finalsquadmessage" //SFX_HUD_ANNOUNCE_QUICK

	int style = ANNOUNCEMENT_STYLE_SWEEP

	switch( messageIndex )
	{
		case eShadowRoyaleMessage.BLANK:
			messageText = ""
			subText = ""
			duration = 0.0
			break
		case eShadowRoyaleMessage.SHADOW_LIVES_REMAINING:
			messageText = "#SHADOWROYALE_RESPAWNING"
			int count = GetRemainingRespawnsForPlayer( GetLocalViewPlayer() )
			string textBase = "#SHADOWROYALE_RETRIES_NONE"
			if ( count > 1 )
				textBase = "#SHADOWROYALE_RETRIES_PLURAL"
			else if ( count == 1 )
				textBase = "#SHADOWROYALE_RETRIES_ONE"
			else if ( count == -1 )
				textBase = "#SHADOWROYALE_RETRIES_INFINITE"

			subText = Localize( textBase, string( count ) )
			duration = 8.0
			//soundAlias = "ui_callerid_chime_friendly"
			soundAlias = "ui_ingame_shadowsquad_shipincoming"
			//style = ANNOUNCEMENT_STYLE_QUICK
			break
		case eShadowRoyaleMessage.GAME_RULES_INTRO:
			messageText = "#SHADOWROYALE_RULES_TITLE"
			subText = "#SHADOWROYALE_RULES_SUB"
			duration = 16.0
			break
		case eShadowRoyaleMessage.REVENGE_KILL_KILLER:
			messageText = "#SHADOW_SQUAD_REVENGE_KILL_KILLER"
			subText = "#SHADOW_SQUAD_REVENGE_KILL_KILLER_SUB"
			soundAlias = "UI_InGame_ShadowSquad_RevengeKill"
			titleColor = <128, 30, 0>
			duration = 4.0
			break
		case eShadowRoyaleMessage.REVENGE_KILL_VICTIM:
			messageText = "#SHADOW_SQUAD_REVENGE_KILL_VICTIM"
			subText = "#SHADOW_SQUAD_REVENGE_KILL_VICTIM_SUB"
			soundAlias = "ui_ingame_shadowsquad_finalsquadmessage"
			titleColor = <128, 30, 0>
			duration = 4.0
			break
		case eShadowRoyaleMessage.NO_MORE_SPAWNS_SOON:
			messageText = "#SHADOWROYALE_NO_RESPAWNS_SOON"
			soundAlias = "ui_callerid_chime_friendly"
			style = ANNOUNCEMENT_STYLE_QUICK
			duration = 10.0
			break
		case eShadowRoyaleMessage.PETS_FOR_TEAMMATE:
			messageText = "#SHADOWROYALE_PROWLERS_FOR_TEAMMATE_TITLE"
			subText = "#SHADOWROYALE_PROWLERS_FOR_TEAMMATE_DESC"
			soundAlias = "ui_ingame_shadowsquad_finalsquadmessage"
			titleColor = <128, 30, 0>
			duration = 8.0
			break
		case eShadowRoyaleMessage.PETS_FOR_PLAYER:
			messageText = "#SHADOWROYALE_PROWLER_FOR_PLAYER_TITLE"
			subText = "#SHADOWROYALE_PROWLER_FOR_PLAYER_DESC"
			soundAlias = "ui_ingame_shadowsquad_finalsquadmessage"
			titleColor = <128, 30, 0>
			duration = 8.0
			break
		case eShadowRoyaleMessage.SHADOW_ABILITIES:
			int diceRoll = RandomIntRange( 1, 9 )
			messageText = "#SHADOW_HINT_ABILITIES_SHORT_" + diceRoll.tostring()
			soundAlias = "SQ_UI_InGame_Checkpoint"
			style = ANNOUNCEMENT_STYLE_QUICK
			duration = 8.0
			break
		case eShadowRoyaleMessage.PET_FRIENDLYFIRE:
			messageText = "#SHADOWROYALE_PET_FRIENDLYFIRE"
			soundAlias = "SQ_UI_InGame_Checkpoint"
			style = ANNOUNCEMENT_STYLE_QUICK
			duration = 6.0
			break
		case eShadowRoyaleMessage.NO_MORE_SPAWNS:
			messageText = "#SHADOWROYALE_NO_RESPAWNS_TITLE"
			subText = "#SHADOWROYALE_NO_RESPAWNS_SUB"
			soundAlias = "ui_ingame_shadowsquad_finalsquadmessage"
			duration = 8.0
			break

		default:
			Assert( false, "Unhandled messageIndex: " + messageIndex )
	}

	AnnouncementMessageSweepShadowRoyale( style, player, messageText, subText, titleColor, soundAlias, duration, icon, leftIcon, rightIcon )
}
#endif //CLIENT


#if SERVER
void function OnPetSpawnedForPlayer( entity player, entity pet )
{
	if ( !IsValid( player ) )
		return

	if ( !player.e.isLeftDoor )
	{
		player.e.isLeftDoor = true //hack property to determine if we've played the message yet
		int team = player.GetTeam()
		int messageIndex
		foreach ( entity squadMate in GetPlayerArrayOfTeam( team ) )
		{
			if ( !IsValid( squadMate ) )
				continue

			if ( !IsAlive( squadMate ) )
				continue

			if ( player == squadMate )
				messageIndex = eShadowRoyaleMessage.PETS_FOR_PLAYER
			else
				messageIndex = eShadowRoyaleMessage.PETS_FOR_TEAMMATE

			ShadowRoyaleSplashToPlayer( squadMate, messageIndex )
		}
	}
}
#endif //SERVER




#if SERVER
void function OnPetFriendlyfireMessaging( entity player, entity pet )
{
	if ( !IsValid( player ) )
		return

	if ( !IsAlive( player ) )
		return

	player.e.lastHintTimePetFriendlyFire = Time()
	thread ShadowRoyaleSplashToPlayerDelayed( player, eShadowRoyaleMessage.PET_FRIENDLYFIRE, 2.0 )

}
#endif //SERVER



#if CLIENT
void function AnnouncementMessageSweepShadowRoyale( int style, entity player, string messageText, string subText, vector titleColor, string soundAlias, float duration, asset icon = $"", asset leftIcon = $"", asset rightIcon = $"" )
{
	AnnouncementData announcement = Announcement_Create( messageText )
	announcement.drawOverScreenFade = true
	Announcement_SetSubText( announcement, subText )
	Announcement_SetHideOnDeath( announcement, true )
	Announcement_SetDuration( announcement, duration )
	Announcement_SetPurge( announcement, true )
	Announcement_SetStyle( announcement, style )
	Announcement_SetSoundAlias( announcement, soundAlias )
	Announcement_SetTitleColor( announcement, titleColor )
	Announcement_SetIcon( announcement, icon )
	Announcement_SetLeftIcon( announcement, leftIcon )
	Announcement_SetRightIcon( announcement, rightIcon )
	AnnouncementFromClass( player, announcement )
}
#endif //CLIENT

#if SERVER
void function OnSquadEliminated( int team )
{
	foreach ( entity player in GetPlayerArrayOfTeam( team ) )
	{
		if ( !IsValid( player ) )
			continue

		ShadowRoyaleSplashToPlayer( player, eShadowRoyaleMessage.BLANK )
	}
}
#endif // SERVER


#if CLIENT
void function OnVictoryCharacterModelSpawned( entity characterModel, ItemFlavor character, int eHandle )
{
	if ( !IsValid( characterModel ) )
		return

	entity playerEnt = GetEntityFromEncodedEHandle( eHandle )

	if ( !IsValid( playerEnt ) )
		return

	if ( !IsPlayerShadowZombie( playerEnt ) )
		return

	//////////////////////////////////////////////
	// Client prop dynamic needs default base mode
	/////////////////////////////////////////////
	ItemFlavor skin = GetDefaultItemFlavorForLoadoutSlot( eHandle, Loadout_CharacterSkin( character ) )
	CharacterSkin_Apply( characterModel, skin )

	//////////////////////////////////////////////
	// Apply the skin material for shadows
	/////////////////////////////////////////////
	if (  characterModel.GetSkinIndexByName( "ShadowSqaud" ) != -1 )
		characterModel.SetSkin( characterModel.GetSkinIndexByName( "ShadowSqaud" ) )
	else
		characterModel.kv.rendercolor = <0, 0, 0>

	//////////////////////////////////////////////
	// Play smoke and eye glows on prop dynamic character
	////////////////////////////////////////////
	int FX_BODY = StartParticleEffectOnEntity( characterModel, GetParticleSystemIndex( FX_SHADOW_TRAIL ), FX_PATTACH_POINT_FOLLOW, characterModel.LookupAttachment( "CHESTFOCUS" ) )
	int FX_EYE_L = StartParticleEffectOnEntity( characterModel, GetParticleSystemIndex( FX_SHADOW_FORM_EYEGLOW ), FX_PATTACH_POINT_FOLLOW, characterModel.LookupAttachment( "EYE_L" ) )
	int FX_EYE_R = StartParticleEffectOnEntity( characterModel, GetParticleSystemIndex( FX_SHADOW_FORM_EYEGLOW ), FX_PATTACH_POINT_FOLLOW, characterModel.LookupAttachment( "EYE_R" ) )
}
#endif //CLIENT

#if CLIENT
void function ServerCallback_PlayerRespawned( entity respawnedPlayer )
{
	if ( !IsValid( respawnedPlayer ) )
		return

	respawnedPlayer.SetTargetInfoIcon( ICON_SPAWN_SHADOW_FRIEND )
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_PlaySpectatorAnnouncer( int spectatorAudioIndex )
{
	//////////////////////////////////////
	// regular method work on a spectator
	//////////////////////////////////////
	entity clientPlayer = GetLocalClientPlayer()
	if ( !IsValid( clientPlayer ) )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	string dialogueRef

	/////////////////////////////
	// Revenant announcer taunts
	/////////////////////////////
	switch ( spectatorAudioIndex )
	{
		case eShadowRoyaleSpectatorAudio.TAUNT_SQUAD_WIPED:
			// revenant "I'm through with you" lines if no respawn/squad wiped
			dialogueRef = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_PLAYER_DEATH_FINAL )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_01_01_3p" )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_01_02_3p" )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_01_03_3p" )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_02_01_3p" )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_02_02_3p" )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_03_01_3p" )
			//dialogueChoices.append( "diag_ap_nocNotify_playerDeathFinal_03_02_3p" )
			break

		case eShadowRoyaleSpectatorAudio.TAUNT_SQUAD_WIPED_REV:
			// revenant "My doppleger sucks balls"
			dialogueRef = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_PLAYER_DEATH_FINAL_REV )
			break

		default:
			dialogueRef = ""
			break
	}

	if ( dialogueRef == "" )
		return

	string milesAlias = GetAnyDialogueAliasFromName( dialogueRef )
	thread EmitSoundOnEntityDelayed( clientPlayer, milesAlias, 1.0 )

}
#endif //CLIENT


#if CLIENT
void function OnPingCreatedByAnyPlayer_CustomReviveText( entity pingingPlayer, int pingType, entity focusEnt, vector pingLoc, entity wayPoint )
{
	if ( pingType != ePingType.BLEEDOUT )
		return

	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) )
		return

	//if ( !IsAlive( localPlayer() ) )
		//return

	if ( !AreTeammatesShadowZombiesOrRespawning( pingingPlayer ) )
		return

	if ( wayPoint.wp.ruiHud != null )
	{
		string reviveMessage = Localize( "#REVIVE" ).toupper() + " " + Localize( "#SHADOWROYALE_LAST_LIVING_PLAYER" ).toupper()
		RuiSetString( wayPoint.wp.ruiHud, "topLabelText", reviveMessage )
	}
}
#endif //CLIENT

//SHARED
void function EmitSoundOnEntityDelayed( entity player, string alias, float delay )
{
	wait delay

	if ( !IsValid( player ) )
		return

	if ( GetGameState() != eGameState.Playing )
		return


	EmitSoundOnEntity( player, alias )
}
//END SHARED
      