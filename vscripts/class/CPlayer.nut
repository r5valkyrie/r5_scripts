untyped


global function CodeCallback_RegisterClass_CPlayer
global function PlayerDropsScriptedItems
global function IsDemigod
global function EnableDemigod
global function DisableDemigod
global function ApplyAppropriateCharacterSkin

global function HasPlayerSettingMod

var function CodeCallback_RegisterClass_CPlayer()
{
	//printl( "Class Script: CPlayer" )

	CPlayer.ClassName <- "CPlayer"
	CPlayer.hasSpawned <- null
	CPlayer.hasConnected <- null
	CPlayer.disableWeaponSlots <- false
	CPlayer.supportsXRay <- null

	CPlayer.lastTitanTime <- 0

	CPlayer.titansBuilt <- 0
	CPlayer.spawnTime <- 0

	RegisterSignal( "OnRespawnPlayer" )
	RegisterSignal( "NewViewAnimEntity" )
	RegisterSignal( "PlayerDisconnected" )

	function CPlayer::constructor()
	{
		CBaseEntity.constructor()
	}

	function CPlayer::RespawnPlayer( ent )
	{
		this.Signal( "OnRespawnPlayer", { ent = ent } )

		// hack. Players should clear all these on spawn.
		this.ViewOffsetEntity_Clear()
		ClearPlayerAnimViewEntity( expect entity( this ) )
		this.spawnTime = Time()

		this.ClearReplayDelay()
		this.ClearViewEntity()

		// titan melee can set these vars, and they need to clear on respawn:
		this.SetOwner( null )
		this.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE

		Assert( !this.GetParent(), this + " should not have a parent yet! - Parent: " + this.GetParent() )

		this.Code_RespawnPlayer( ent )
	}

	/*
	CPlayer.__SetTrackEntity <- CPlayer.SetTrackEntity
	function CPlayer::SetTrackEntity( ent )
	{
		printl( "\nTime " + Time() + " Ent " + ent )

		printt( "%s", GetStack() )
		this.__SetTrackEntity( ent )
	}
	*/

	function CPlayer::GetDropEntForPoint( origin )
	{
		return null
	}

	function CPlayer::GiveScriptWeapon( weaponName, equipSlot = null )
	{
		this.scope().GiveScriptWeapon( weaponName, equipSlot )
	}

	function CPlayer::Disconnected()
	{
		if ( IsLobby() )
			return

		this.Signal( "_disconnectedInternal" )
		svGlobal.levelEnt.Signal( "PlayerDisconnected" )

		entity titan = GetPlayerTitanInMap( expect entity( this ) )
		if ( IsAlive( titan ) && titan.IsNPC() )
			titan.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_suicide } )

		PROTO_CleanupTrackedProjectiles( expect entity( this ) )
	}

	function CPlayer::RecordLastMatchContribution( contribution )
	{
		// replace with code function
	}

	function CPlayer::RecordLastMatchPerformance( matchPerformance )
	{
		// replace with code function
	}

	function CPlayer::RecordSkill( skill )
	{
		// replace with code function
		this.SetPersistentVar( "ranked.recordedSkill", skill )
	}
}


void function PlayerDropsScriptedItems( entity player )
{
	foreach ( callbackFunc in svGlobal.onPlayerDropsScriptedItemsCallbacks )
		callbackFunc( player )
}


bool function IsDemigod( entity player )
{
	return player.p.demigod
}


void function EnableDemigod( entity player )
{
	Assert( player.IsPlayer() )
	player.p.demigod = true
}


void function DisableDemigod( entity player )
{
	Assert( player.IsPlayer() )
	player.p.demigod = false
}

void function ApplyAppropriateCharacterSkin( entity player )
{
	// Gets called every time you spawn but also when player mods are changed
	// (SetPlayerSettingsWithMods() resets character skins, health, etc. so we need to manually reapply here)

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		printt( "FiringRangeDebug: ApplyAppropriateCharacterSkin called for " + player )
		printt( "%s", GetStack() )
	}

	if ( !LoadoutSlot_IsReady( ToEHI( player ), Loadout_Character() ) )
		return

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

	if ( !LoadoutSlot_IsReady( ToEHI( player ), Loadout_CharacterSkin( character ) ) )
		return

	ItemFlavor skin      = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterSkin( character ) )
	CharacterSkin_Apply( player, skin )
	bool isShadowPlayer = false

	                             
		isShadowPlayer = IsPlayerShadowZombie( player )
                                    

	if ( isShadowPlayer || ( player.IsShadowForm() && !IsInForgedShadows( player ) ) )
	{
		ShadowSquadApplyCharacterSkin( player )
	}
	else if( IsInForgedShadows( player ) )
	{
		//ShadowForm_ApplyShadowSkin( player )
	}

	if ( IsEventFinale() )
	{
		ApplyDefaultCharacterSkin( player )
	}

	                            
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) && ShadowArmy_IsPlayerInShadowForm( player ) )
	{
		ItemFlavor ornull armySkin = GetItemFlavorOrNullByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00097700436" ) )
		if ( armySkin == null )
			return

		expect ItemFlavor( armySkin )
		CharacterSkin_Apply( player, armySkin )
	}
       
}

void function ApplyDefaultCharacterSkin( entity player )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	ItemFlavor skin = GetDefaultItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_CharacterSkin( character ) )
	CharacterSkin_Apply( player, skin )
}


bool function HasPlayerSettingMod( entity player, string mod )
{
	array<string> mods = player.GetPlayerSettingsMods()
	return mods.contains( mod )
}