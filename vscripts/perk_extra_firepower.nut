global function Perk_ExtraFirepower_Init

const float EXTRA_FIREPOWER_GRENADE_SPAWN_CHANCE = 0.2

void function Perk_ExtraFirepower_Init()
{
	if ( GetCurrentPlaylistVarBool( "disable_perk_extra_firepower", false ) )
		return

	PerkInfo extraFirepower
	extraFirepower.perkId          = ePerkIndex.EXTRA_FIREPOWER
	#if SERVER || CLIENT
		extraFirepower.activateCallback = ExtraFirepower_Activate
		extraFirepower.deactivateCallback = ExtraFirepower_Deactivate
	#endif
	Perks_RegisterClassPerk( extraFirepower )

	                    
		#if SERVER
		AddCallback_OnPassiveChanged( ePassives.PAS_LARGE_AMMO_STACKS, OnPassiveChanged )
		AddCallback_OnPassiveChanged( ePassives.PAS_EXTRA_ARC_STARS, OnPassiveChanged )
		#endif
       

	                       
		#if SERVER
			AddCallback_OnPassiveChanged( ePassives.PAS_EXTRA_ORDINANCE_SLOT, OnPassiveChanged )
		#endif
       
}

                       
#if SERVER
void function OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if( nowHas )
	{
		ExtraFirepower_Activate( player, "" )
	}

	if( didHave )
	{
		ExtraFirepower_Deactivate( player )
	}
}
#endif
      

#if SERVER || CLIENT
void function ExtraFirepower_Activate( entity player, string characterName )
{
	#if SERVER
		if ( !IsAlive( player ) )
			return

		array<ConsumableInventoryItem> playerInventory = SURVIVAL_GetPlayerInventory( player )

		SURVIVAL_ConsolidateInventoryItems( player, playerInventory )
		SetPlayerInventory( player, playerInventory )
	#endif
}

void function ExtraFirepower_Deactivate( entity player )
{
	#if SERVER
		if ( !IsAlive( player ) )
			return

		// TODO: Might need to fix this is perks can be activated during gameplay
		// Lifted this from Wattson but it's not as clean as I'd hoped.  You can lose ammo in the process.

		array<ConsumableInventoryItem> playerInventory = SURVIVAL_GetPlayerInventory( player )

		SURVIVAL_ClearExcessInventoryItems( player, playerInventory )
		SURVIVAL_ConsolidateInventoryItems( player, playerInventory )
		SetPlayerInventory( player, playerInventory )
	#endif
}
#endif

#if SERVER
void function ExtraFirepower_OnLootBinOpening( entity player, entity lootbin, array<entity> regularLootEnts, array<entity> secretLootEnts, void functionref( bool, bool ) preventLootRevealFunc )
{
	if( !IsValid( player) )//Loba's Ult can trigger this (can have null player). So we need to ensure this is only happening when a valid PLAYER activates
		return

	if ( !Perks_DoesPlayerHavePerk( player, ePerkIndex.EXTRA_FIREPOWER ) )
		return

	if ( RandomFloat( 1.0 ) > EXTRA_FIREPOWER_GRENADE_SPAWN_CHANCE )
		return

	thread function() : ( lootbin, player )
	{
		EndSignal( lootbin, "OnDestroy" )
		EndSignal( player, "OnDestroy" )

		wait 0.65

		EmitSoundOnEntityOnlyToPlayer( player, player, "ctrl_capturebonus_added_1p" )

		ThrowLootParams params
		params.dropOrg = lootbin.GetOrigin() + <0,0,32>
		params.fwd = ((lootbin.GetForwardVector() + <0,0,0.75>) * 0.5)
		params.ref = SURVIVAL_GetWeightedItemFromGroup( "ordnance_drops" )
		params.spawnAngles = (lootbin.GetAngles() + <0, RandomFloatRange( -15, 15 ), 0>)
		params.throwVelocityRange[0] = 225
		params.throwVelocityRange[1] = 250
		entity box = SURVIVAL_ThrowLootFromPointEx( params )
	}()
}
#endif