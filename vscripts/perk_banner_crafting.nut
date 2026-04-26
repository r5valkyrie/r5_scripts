
global function Perk_ExtraBinLoot_Init
global function Perk_ExpiredBannerRecovery_Enabled
global function Perk_Get_CraftedBannerTimeoutDuration
#if SERVER
global function Perk_RetrieveExpiredBanners
#elseif CLIENT
global function ServerCallback_Perk_ShowPlayerCraftingBannerGuidance
#endif

#if SERVER || CLIENT
global function Perk_CanCraftBanners
global function Perk_CanBuyBanners
global function Perk_CanPickUpExpiredBanners
global function Perk_CanExpiredBannerBeRecovered
global function GetCraftableTeamBanners
global function Perk_CanTeammateCraftPlayerBanner
global function DoesTeammateHaveBannerCraftingPerk
#endif

global const string EXPIRED_BANNER_RECOVERY_NETVAR 		= "hasExpiredBannerPerk"
global const string DEATH_BOX_BANNER_EXPIRED_NETVAR 	= "DeathBoxBannerExpired"
global const string CRAFTED_BANNER_REF = "expired_banners"
global const string CRAFTED_BANNER_MODEL_NAME = "mdl/props/ultimate_accelerant/ultimate_accelerant_banner_crafting.rmdl"

const bool ALLOW_EXPIRED_BANNERS_ONLY = false

void function Perk_ExtraBinLoot_Init()
{
	if ( GetCurrentPlaylistVarBool( "disable_perk_extra_bin_loot", false ) )
		return

	PerkInfo bannerCrafting
	bannerCrafting.perkId = ePerkIndex.BANNER_CRAFTING
	#if SERVER || CLIENT
		bannerCrafting.activateCallback = OnActivate_ExpiredBannerRecoveryPerk
		bannerCrafting.deactivateCallback = OnDeactivate_ExpiredBannerRecoveryPerk
		bannerCrafting.minimapPingType = ePingType.SUPPORT_BOX
		Remote_RegisterClientFunction( "ServerCallback_Perk_ShowPlayerCraftingBannerGuidance" )
	#endif
	#if CLIENT
		AddCreateCallback( "prop_survival", OnCraftedBannerPropCreated )
	#endif

	Perks_RegisterClassPerk( bannerCrafting )

	RegisterSignal( "RecoveredExpiredDNA" )
	RegisterSignal( "BannerCraftingDisabled" )

	#if SERVER
		RegisterCustomItemPickupAction( CRAFTED_BANNER_REF, Perk_ExpiredBanner_OnPickup )
		AddCallback_OnDNAPickupDestroyed( Perk_RetrieveExpiredBanners_OnDNAPickupDestroyed )
		AddCallback_OnDNAPickupDestroyed( Perk_HighlightReplicators_OnDNAPickupDestroyed )
		AddCallback_GameStateEnter( eGameState.Playing, Perk_BannerCrafting_OnGameStart )
	#endif
}

bool function Perk_ExpiredBannerRecovery_Enabled()
{
	return GetCurrentPlaylistVarBool( "perk_expired_banner_recovery_enabled", false )
}

bool function Perk_TeammatesCanCraftSupportBanners_Enabled()
{
	return GetCurrentPlaylistVarBool( "teammates_can_craft_support_banners_enabled", true )
}

bool function Perk_SupportCanCraftNonExpiredBanners_Enabled()
{
	return GetCurrentPlaylistVarBool( "support_can_craft_non_expired_banners", true )
}

float function Perk_Get_CraftedBannerTimeoutDuration()
{
	return GetCurrentPlaylistVarFloat( "perk_crafted_banner_timeout_duration", 90.0 )
}

#if SERVER || CLIENT
void function OnActivate_ExpiredBannerRecoveryPerk( entity player, string characterName )
{
	#if SERVER
		thread OnActivate_ExpiredBannerRecoveryPerk_Thread( player, characterName )
	#endif
}
#endif


#if SERVER
void function Perk_BannerCrafting_OnGameStart()
{
	array< entity > allPlayers = GetPlayerArray_Alive()
	table<int, bool> teamsToCanCraftBanners
	foreach( player in allPlayers )
	{
		int team = player.GetTeam()
		if( !( team in teamsToCanCraftBanners ) )
			teamsToCanCraftBanners[team] <- false
		else if( teamsToCanCraftBanners[team] ) // someone else on the team is support already
			continue
		if( !Perks_DoesPlayerHavePerk( player, ePerkIndex.BANNER_CRAFTING ) )
			continue

		teamsToCanCraftBanners[team] <- true
	}

	foreach( team, val in teamsToCanCraftBanners )
	{
		array<entity> teammates = GetPlayerArrayOfTeam( team )
		foreach( teammate in teammates )
		{
			if ( !IsValid( teammate ) )
				continue

			teammate.SetPlayerNetBool( EXPIRED_BANNER_RECOVERY_NETVAR, val )
		}
	}
}

bool function Perk_ExpiredBanner_OnPickup( entity pickup, entity playerUser, int pickupFlags, entity deathBox, int ornull desiredCount, LootData lootData )
{
	entity bannerOwner = GetEntityFromEncodedEHandle( pickup.GetSurvivalProperty() )
	if ( !IsValid( bannerOwner ) || bannerOwner.GetTeam() != playerUser.GetTeam() )
		return true

	if ( !CanCraftPlayersBanner( bannerOwner ) )
		return true


	bannerOwner.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_DELIVERY )
	bannerOwner.SetPlayerNetTime( "respawnStatusEndTime", 0 )
	bannerOwner.SetPlayerNetTime( "respawnBannerPickedUpTime", Time() )
	Signal( bannerOwner, "RecoveredExpiredDNA" )

	//LiveAPI_SendTwoPlayerEvent( eLiveAPI_EventTypes.bannerCollected, playerUser, bannerOwner )
	//PIN_Perks_CraftedBannerRetrieved( playerUser, playerUser.GetOrigin() )

	if ( GetCurrentPlaylistVarBool( "respawn_beacon_fp_gladiator_card", true ) )
	{
		playerUser.SetPlayerNetEnt( "gladCardPlayer", bannerOwner )
		if ( !playerUser.ContextAction_IsInVehicle() )



		{
			thread HandleRespawnBannerPickup_Thread( playerUser )
		}
	}


		UpgradeCore_OnBannerPickup( playerUser, bannerOwner )


	PingNearestRespawnBeacon( bannerOwner, playerUser.GetOrigin() )

	Remote_CallFunction_Replay( playerUser, "ServerCallback_RespawnDNAHint" )
	PlayBattleChatterLineToSpeakerAndTeam( playerUser, "bc_gotFriendlyBanner" )


	return true
}

void function OnActivate_ExpiredBannerRecoveryPerk_Thread( entity player, string characterName )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "BannerCraftingDisabled" )

	while( true )
	{
		wait 1
		//We need other systems to initiate before setting the NetVar.
		//So we check if we're actively playing before setting - Is there a better way to handle this on init?
		if( GetGameState() >= eGameState.Playing )
		{
			if( IsValid( player ) )
			{
				array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
				foreach( teammate in teammates )
				{
					if ( !IsValid( teammate ) )
						continue

					teammate.SetPlayerNetBool( EXPIRED_BANNER_RECOVERY_NETVAR, true )
				}
			}

			return
		}
	}
}
#endif //SERVER


#if SERVER || CLIENT
void function OnDeactivate_ExpiredBannerRecoveryPerk( entity player )
{
	#if SERVER
		bool canCraft = false
		array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
		foreach( teammate in teammates )
		{
			if ( !IsValid( teammate ) )
				continue

			if ( !Perks_DoesPlayerHavePerk( teammate, ePerkIndex.BANNER_CRAFTING ) )
				continue

			canCraft = true
			break
		}

		foreach( teammate in teammates )
		{
			if ( !IsValid( teammate ) )
				continue

			teammate.SetPlayerNetBool( EXPIRED_BANNER_RECOVERY_NETVAR, canCraft )
		}

		player.Signal( "BannerCraftingDisabled" )
	#endif
}
#endif


#if SERVER || CLIENT
bool function CanCraftPlayersBanner( entity player )
{
	int respawnStatus = player.GetPlayerNetInt( "respawnStatus" )
	if( respawnStatus == eRespawnStatus.PICKUP_DESTROYED )
	{
		return true
	}
	else if( Perk_SupportCanCraftNonExpiredBanners_Enabled() && respawnStatus == eRespawnStatus.WAITING_FOR_PICKUP )
	{
		return true
	}
	return false
}

bool function Perk_CanTeammateCraftPlayerBanner( entity player )
{
	int gameState = GetGameState()
	if( gameState >= eGameState.WinnerDetermined || gameState < eGameState.Prematch )
		return false

	if( player.GetPlayerNetInt( "respawnStatus" ) == eRespawnStatus.SQUAD_ELIMINATED )
		return false

	foreach ( teamMember in GetPlayerArrayOfTeam( player.GetTeam() ) )
	{
		if( !Perk_TeammatesCanCraftSupportBanners_Enabled() )
		{
			if ( teamMember == player )
				continue

			if ( !IsAlive( teamMember ) && !PlayerIsMarkedAsCanBeRespawned( teamMember ) )
				continue
		}
		if( Perk_CanBuyBanners( teamMember ) )
		{
			return true
		}
	}

	return false
}

array<entity> function GetCraftableTeamBanners( entity player )
{
	array<entity> bannerPlayers

	if( !IsValid( player ) )
		return bannerPlayers

	foreach ( teamMember in GetPlayerArrayOfTeam( player.GetTeam() ) )
	{
		if ( teamMember == player )
			continue
		if( CanCraftPlayersBanner( teamMember ) )
		{
			bannerPlayers.append( teamMember )
		}
	}
	return bannerPlayers
}
#endif

#if SERVER
void function Perk_RetrieveExpiredBanners( entity player )
{
	bool gotABanner = false
	entity bannerAlly

	array<entity> bannerPlayers = GetCraftableTeamBanners( player )
	foreach( bannerPlayer in bannerPlayers )
	{
		if( IsValid( bannerPlayer ) )
		{
			bannerPlayer.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_DELIVERY )
			bannerPlayer.SetPlayerNetTime( "respawnStatusEndTime", 0 )
			bannerPlayer.SetPlayerNetTime( "respawnBannerPickedUpTime", Time() )
			Signal( bannerPlayer, "RecoveredExpiredDNA" )
			gotABanner = true

			//LiveAPI_SendTwoPlayerEvent( eLiveAPI_EventTypes.bannerCollected, player, bannerAlly )

			bannerAlly = bannerPlayer
		}
	}

	if ( gotABanner )
	{

		if( IsValid( bannerAlly ) )
		{
			if ( GetCurrentPlaylistVarBool( "respawn_beacon_fp_gladiator_card", true ) )
			{
				player.SetPlayerNetEnt( "gladCardPlayer", bannerAlly )
				if ( !player.ContextAction_IsInVehicle() )



				PlayFirstPersonAnimation( player, PICKING_UP_RESPAWN_BANNER_ANIM )
			}

			PingNearestRespawnBeacon( bannerAlly, player.GetOrigin() )
		}

		Remote_CallFunction_Replay( player, "ServerCallback_RespawnDNAHint" )
		PlayBattleChatterLineToSpeakerAndTeam( player, "bc_gotFriendlyBanner" )
	}
}
#endif

#if SERVER || CLIENT
// checks if the player has banners available to be crafted and is able to craft them
bool function Perk_CanBuyBanners( entity player )
{
	array<entity> bannerPlayers = GetCraftableTeamBanners( player )
	if ( bannerPlayers.len() > 0 )
	{
		return Perk_CanCraftBanners( player )
	}

	return false
}

// checks if the player can craft banners in general
bool function Perk_CanCraftBanners( entity player )
{
	if( Perk_TeammatesCanCraftSupportBanners_Enabled() )
	{
		return player.GetPlayerNetBool( EXPIRED_BANNER_RECOVERY_NETVAR )
	}

	//Check if Player has this Perk
	return Perks_DoesPlayerHavePerk( player, ePerkIndex.BANNER_CRAFTING )
}
#endif

#if SERVER || CLIENT
bool function Perk_CanPickUpExpiredBanners( entity player, entity deathbox )
{
	if( !Perk_ExpiredBannerRecovery_Enabled() )
		return false

	entity deathboxOwner = deathbox.GetOwner()

	if( !IsValid( deathboxOwner ) )
		return false

	if( Perks_DoesPlayerHavePerk( player, ePerkIndex.BANNER_CRAFTING ) )
	{
		if( deathboxOwner == player )
			return false

		int ownerTeam = deathboxOwner.GetTeam()
		if ( !IsAlive(deathboxOwner ) && deathboxOwner.GetPlayerNetInt( "respawnStatus" ) == eRespawnStatus.WAITING_FOR_DELIVERY )
			return false

		if ( ownerTeam == player.GetTeam() && IsValid( deathbox.GetOwner() ) )
			return true
	}

	return false
}
#endif

#if SERVER || CLIENT
bool function Perk_CanExpiredBannerBeRecovered( entity player ) //Can this player's banner BE recovered
{
	if( !Perk_ExpiredBannerRecovery_Enabled() )
		return false

	bool canRecoverBanner = false

	int team = player.GetTeam()
	array<entity> teamArray = GetPlayerArrayOfTeam( team )
	foreach ( entity ally in teamArray )
	{
		if( !IsValid( ally ) )
			continue
		//
		//if( ally == player && IsAlive( ally ) )
		//	continue

		//Check if a Teammate has this Perk
		if ( Perks_DoesPlayerHavePerk( ally, ePerkIndex.BANNER_CRAFTING ) ) //&& !IsAlive( ally ))
			return true
	}

	return false
}
#endif

#if SERVER
void function Perk_HighlightReplicators_OnDNAPickupDestroyed( entity player )
{
	bool hasPinged = false

	if( !IsValid( player ) )
		return

	int team = player.GetTeam()
	array<entity> teamArray = GetPlayerArrayOfTeam( team )
	foreach( ally in teamArray )
	{
		if ( !IsValid( ally ) || !IsAlive( ally ) )
			continue

		if ( ally == player )
			continue

		if ( !Perks_DoesPlayerHavePerk( ally, ePerkIndex.BANNER_CRAFTING ) )
			continue

		//Add UX and hints to Craft Banner for the support teammate
		Remote_CallFunction_Replay( ally, "ServerCallback_Perk_ShowPlayerCraftingBannerGuidance" )
		//Auto Ping Nearest Crafter
		if(!hasPinged)
		{
			if ( Crafting_IsDispenserCraftingEnabled() )
			{
				Dispensers_PingNearestDispenser( player, ally.GetOrigin() )
			}
			else
			{
				Crafting_PingNearestWorkbench( player, ally.GetOrigin() )
			}
			hasPinged = true
		}
	}
}

void function Perk_RetrieveExpiredBanners_OnDNAPickupDestroyed( entity player )
{
	if( !Perk_ExpiredBannerRecovery_Enabled() )
		return

	//PLAYER is the character whose banner has expired.
	if( !IsValid( player ) )
		return

	int team = player.GetTeam()
	array<entity> teamArray = GetPlayerArrayOfTeam( team )
	foreach( ally in teamArray )
	{
		//For each ALLY in the EXPIRED PLAYER's TEAM...we check for a SUPPORT PERK CHARACTER
		if( !IsValid( ally ) || !IsAlive( ally ) )
			continue

		if( ally == player )
			continue

		if ( !Perks_DoesPlayerHavePerk( ally, ePerkIndex.BANNER_CRAFTING ) && !Perks_DoesPlayerHavePerk( player, ePerkIndex.BANNER_CRAFTING ) )
			continue

		//Ally of Expired Player has Perk (or Expired Player has Perk) - Ping his Deathbox
		entity allyDeathbox
		array<entity> deathboxArray = GetAllDeathBoxes()
		foreach ( deathbox in deathboxArray )
		{
			//Get the box owner of each deathbox
			entity boxOwner = deathbox.GetOwner()

			if( !IsValid( boxOwner ) )
				continue

			int boxTeam = boxOwner.GetTeam()
			if( boxTeam != team )
				continue

			//If the Deathbox Owner IS our Expired Player
			if( boxOwner == player )
			{
				PingForExpiredDeathboxesTriggered( ally, player, deathbox )
				break
			}
		}
	}
}

entity function PingForExpiredDeathboxesTriggered( entity pingOwner, entity expiredPlayer, entity deathbox )
{
	if ( pingOwner.IsPlayer() )
		EmitSoundOnEntityOnlyToPlayer( pingOwner, pingOwner, "ui_mapping_item_1p" )

	//todo: We likely need to track allies who have been pinged, and re-evaluate pings when we swap classes (minor bugs in box if you flip back and forth)
	entity wp = CreateWaypoint_Ping_Location( expiredPlayer, ePingType.RESPAWN_BANNER, deathbox, deathbox.GetOrigin(), -1, false )
	SetTeam( wp, expiredPlayer.GetTeam() )
	SetTeam( deathbox, expiredPlayer.GetTeam() )
	SetTargetName( wp, RESPAWN_DNA_TARGETNAME )
	wp.SetWaypointGametime( 0, Time() )
	wp.SetOwner( expiredPlayer )
	wp.SetAbsOrigin( deathbox.GetOrigin() )

	thread DelayedDestroyWP( wp, deathbox, pingOwner, expiredPlayer )
	//thread PlayBattleChatterLineDelayedToSpeakerAndTeam( player, "bc_tacticalTaunt", 0.0 ) "Support VO?"
	return wp
}


void function DelayedDestroyWP( entity wp, entity deathbox, entity pingOwner, entity deathboxOwner )
{
	EndSignal( wp, "OnDestroy" )
	EndSignal( deathbox, "OnDestroy" )
	EndSignal( pingOwner, "OnDeath" )
	EndSignal( pingOwner, "OnDestroy" )

	OnThreadEnd(
		function() : ( wp, pingOwner )
		{
			if ( IsValid( wp ) )
				wp.Destroy()
		}
	)

	while( true )
	{
		if( !IsValid( deathbox ) )
			return

		if( !IsValid( deathboxOwner ) )
			return

		if ( !IsAlive(deathboxOwner ) && deathboxOwner.GetPlayerNetInt( "respawnStatus" ) == eRespawnStatus.WAITING_FOR_DELIVERY )
			return

		if( IsValid(wp) )
			wp.SetWaypointGametime( 0, Time() ) //Reset timer - need the RUI script to handle for infinite time overall in final version

		wait 1
	}
}
#endif //SERVER

#if CLIENT

void function ServerCallback_Perk_ShowPlayerCraftingBannerGuidance()
{
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		AddPlayerHint( 10.0, 1.0, $"", "#DISPENSERS_EXPIRED_BANNER_HINT" )
	}
	else

	AddPlayerHint( 10.0, 1.0, $"", "#CRAFT_EXPIRED_BANNER_HINT" )

	//CALL TO CRAFTING TO HIGHLIGHT CRAFTERS FOR PLAYER
	//Perk_HighlightReplicators()
}

void function Perk_HighlightReplicators( )
{
	MarkAllWorkbenches() //This is a temp implementation, it places diagetic UI on screen, but does not create any waypoints or map highlights.
	//TODO: Highlight the Replicators on the Minimap, Possibly with Ping?

	entity player = GetLocalViewPlayer()
	float duration = 15.0

	thread Thread_Perk_ClearDiageticReplicatorHighlights( player, duration )
}

void function Thread_Perk_ClearDiageticReplicatorHighlights( entity player, float duration )
{
	player.EndSignal( "OnDestroy" )

	wait duration

	OnThreadEnd(
		function() : ( )
		{
			DestroyWorkbenchMarkers()
		}
	)
}

void function OnCraftedBannerPropCreated( entity prop )
{
	if( prop.GetModelName() != CRAFTED_BANNER_MODEL_NAME )
		return
	LootData data = SURVIVAL_Loot_GetLootDataByIndex( prop.GetSurvivalInt() )
	if( data.ref != CRAFTED_BANNER_REF )
		return

	thread CreateCraftedBannerRui( prop )
}

const float MAGIC_DEATHBOX_Z_OFFSET = 1.25
void function CreateCraftedBannerRui( entity banner )
{
	EHI ornull ehi = banner.GetSurvivalProperty()
	if ( ehi == null )
		return

	expect EHI( ehi )

	banner.EndSignal( "OnDestroy" )

	float scale  = 0.025
	float width  = 264 * scale
	float height = 720 * scale
	vector right     = <0, 1, 0> * width * 0.5
	vector fwd       = <1, 0, 0> * height * 0.5

	vector org = <0, 0, .4>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, right, fwd, true )
	RuiTopology_SetParent( topo, banner )

	NestedGladiatorCardHandle ornull nestedGCHandleOrNull = null

	var rui
	rui = RuiCreate( $"ui/gladiator_card_deathbox.rpak", topo, RUI_DRAW_WORLD, MINIMAP_Z_BASE + 10 )
	NestedGladiatorCardHandle nestedGCHandle = CreateNestedGladiatorCard( rui, "card", eGladCardDisplaySituation.DEATH_BOX_STILL, eGladCardPresentation.FRONT_DETAILS )
	nestedGCHandleOrNull = nestedGCHandle

	ChangeNestedGladiatorCardOwner( nestedGCHandle, ehi, null, eGladCardLifestateOverride.ALIVE )

	OnThreadEnd (
		void function() : ( topo, rui, nestedGCHandleOrNull )
		{
			if ( nestedGCHandleOrNull != null )
				CleanupNestedGladiatorCard( expect NestedGladiatorCardHandle( nestedGCHandleOrNull ) )
			RuiDestroy( rui )
			RuiTopology_Destroy( topo )
		}
	)

	WaitFrame()
	WaitForever()
}
#endif

#if SERVER||CLIENT
bool function DoesTeammateHaveBannerCraftingPerk( entity player )
{
	bool hasPerk = false
	array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach ( teamMember in teammates )
	{
		if ( Perks_DoesPlayerHavePerk( teamMember, ePerkIndex.BANNER_CRAFTING ) )
		{
			hasPerk = true
			break
		}
	}
	return hasPerk
}
#endif
                         