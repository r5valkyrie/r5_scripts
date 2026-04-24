global function Perk_WeaponInfusion_Init

#if SERVER || CLIENT
#endif

#if SERVER
global function Perk_WeaponInfusion_OnItemDropped
global function ClientCallback_AttemptUse_UnstableHarvester
#endif

#if CLIENT
global function CL_WeaponDurability_ActivateHUDMeter
global function CL_WeaponDurability_DeactivateHUDMeter
global function ServerToClient_AppendUnstableHarvesterEnt
global function ServerToClient_UpdateUsedHarvesters
#endif


const bool PERK_WEAPON_INFUSION_DEBUG 						= true
const bool DEBUG_PERK_WEAPON_INFUSION_AUTO_LOOP		 		= false
const float DEBUG_PERK_WEAPON_INFUSION_LOOP_TEST_TIME 		= 5.0

const string PERK_INFUSED_WEAPON_DURABILITY_NETVAR 			= "perkInfusedWeaponDurability"

const int PERK_INFUSED_WEAPON_MAX_DURABILITY 				= 100 //may need variable durability per weapon.
const float PERK_WEAPON_INFUSION_DURABILITY_DAMAGE_FRAC 	= 0.25 //How much of the damage is converted to durability loss // May need per weapon type.
const float UNSTABLE_HARVESTER_MAX_VISIBLE_WP_RANGE 		= 2500

const float UNSTALBLE_HARVESTER_CREATION_DELAY 				= 10.0	//5s works... 2s does not. Something odd going on here...
const float UNSTABLE_HARVESTER_MIN_SEPARATION_RANGE 		= 6000
const float UNSTABLE_HARVESTER_DISTANCE_TO_INTERACT 		= 150

const asset PERK_WEAPON_INFUSION_DESTROY_WPN_FX				= $"P_exp_hold_exp_emp_med" //$"P_armored_leap_shockwave"
const asset PERK_WEAPON_INFUSION_UNSTABLE_BEAM_FX			= $"P_wpn_orbital_laser"
const string PERK_WEAPON_INFUSION_DESTROY_WPN_SFX 			= "Newcastle_Ultimate_Wall_Destroy"

struct InfusedWeaponInfo
{
	entity weapon
	int durability
}

struct SavedWeaponInfo
{
	entity weapon
	string weaponRef
	array<string> lootTags
	array<string> attachments
}

struct
{
	table<entity, InfusedWeaponInfo > infusedWeaponData
	table<entity, SavedWeaponInfo > savedWeaponData
	table<entity, entity> infusedWeapon
	array<entity> craftingHarvesters
	array<entity> unstableHarvesters
	table<entity, array> playerUsedHarvesters
	#if CLIENT
		var infusedWeaponRui
	#endif
} file

void function Perk_WeaponInfusion_Init()
{
	if ( GetCurrentPlaylistVarBool( "disable_perk_weapon_infusion", true ) )
		return

	PerkInfo weaponInfusion
	weaponInfusion.perkId          = ePerkIndex.WEAPON_INFUSION
	#if SERVER || CLIENT
		weaponInfusion.activateCallback = OnActivate_PerkWeaponInfusion
		weaponInfusion.deactivateCallback = OnDeactivate_PerkWeaponInfusion
	#endif
	Perks_RegisterClassPerk( weaponInfusion )

	RegisterSignal( "Deactivate_PerkWeaponInfusion" )
	RegisterSignal( "OnLeave_UnstableHarvesterRange" )

#if SERVER
	AddCallback_OnClientConnected( Perk_WeaponInfusion_OnClientConnected )
	AddCallback_OnClientConnectionRestored( Perk_WeaponInfusion_OnPlayerReconnected )
	AddCallback_OnClientConnectionLost( Perk_WeaponInfusion_OnClientDisconnected )
	AddCallback_GameStateEnter( eGameState.Playing, Perk_WeaponInfusion_OnGamePlaying )
	AddCallback_OnPlayerKilled( Perk_WeaponInfusion_OnPlayerKilled )
	AddSpawnCallback( "prop_dynamic", OnCraftingHarvesterSpawned )
#endif

	#if SERVER || CLIENT
		RegisterNetworkedVariable( PERK_INFUSED_WEAPON_DURABILITY_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_INT, -1 )

		PrecacheParticleSystem( PERK_WEAPON_INFUSION_DESTROY_WPN_FX )
		PrecacheParticleSystem( PERK_WEAPON_INFUSION_UNSTABLE_BEAM_FX )

		Remote_RegisterClientFunction( "CL_WeaponDurability_ActivateHUDMeter", "entity", "entity" )
		Remote_RegisterClientFunction( "CL_WeaponDurability_DeactivateHUDMeter", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_AppendUnstableHarvesterEnt", "entity", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_UpdateUsedHarvesters", "entity", "entity" )
		Remote_RegisterServerFunction( "ClientCallback_AttemptUse_UnstableHarvester", "typed_entity", "prop_dynamic" )
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+use_alt", AttemptUse_UnstableHarvester ) //%use%
	#endif
}





#if SERVER || CLIENT
void function OnActivate_PerkWeaponInfusion( entity player, string characterName )
{
	#if SERVER
		thread Perk_WeaponInfusion_Active_Thread( player )
	#endif

	#if CLIENT
		thread CL_Track_UnstableHarvesters_Thread( player )
	#endif

}
#endif

#if SERVER || CLIENT
void function OnDeactivate_PerkWeaponInfusion( entity player )
{
	#if SERVER
		Signal( player, "Deactivate_PerkWeaponInfusion" )
	#endif
}
#endif

#if SERVER // || CLIENT
void function Perk_WeaponInfusion_Active_Thread( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "Deactivate_PerkWeaponInfusion" )

	bool unstableHarverstersCreated = false

	table< entity, array< table< entity, entity > > > playerHarvesterWPTables

	playerHarvesterWPTables[ player ] <- []

	OnThreadEnd(
		function() : ( )
		{

		}
	)

	while ( true )
	{
		if( !IsValid( player ) )
			return


		array<entity> unstableHarvesters = file.unstableHarvesters
		if( unstableHarvesters.len() > 0 )
		{
			if( !unstableHarverstersCreated )
			{
				foreach ( ent in unstableHarvesters )
				{
					Remote_CallFunction_Replay( player, "ServerToClient_AppendUnstableHarvesterEnt", player, ent )
				}
				unstableHarverstersCreated = true
			}

			vector pOrigin = player.GetOrigin()

			foreach ( ent in unstableHarvesters )
			{
				if( !IsValid( ent ) )
					continue


				bool isInRange 	= false
				bool isUsed		= false

				if( player in file.playerUsedHarvesters )
				{
					if( file.playerUsedHarvesters[player].contains( ent ) )
						isUsed = true
				}

				float distToHarvester = Distance2D( ent.GetOrigin(), pOrigin )
				if( distToHarvester < UNSTABLE_HARVESTER_MAX_VISIBLE_WP_RANGE )
					isInRange = true

				if( isInRange && !isUsed )
				{
					bool harvesterHasWP = false
					foreach ( harvesterTable in playerHarvesterWPTables[player] )
					{
						if ( ent in harvesterTable ) //If the harvester is already part of a table...
						{
							harvesterHasWP = true
							break
						}

					}

					if( !harvesterHasWP )
					{
						entity wp = Create_UnstableHarvesterWPPing( player, ent )
						table< entity, entity > harvesterWPTable
						harvesterWPTable[ent] <- wp

						playerHarvesterWPTables[player].append( harvesterWPTable )
					}
				}
				else
				{
						foreach ( harvesterTable in playerHarvesterWPTables[player] )
					{
						if ( ent in harvesterTable ) //If the harvester is already part of a table...
						{
							entity wp = harvesterTable[ent]
							if( IsValid( wp ) )
								wp.Destroy()

							playerHarvesterWPTables[player].fastremovebyvalue( harvesterTable )
							break
						}

					}
				}
			}

		}


		//DEV AUTO-CYCLE INFUSE WEAPONS
		#if DEV
			//printt( "Harvester Count: " + file.unstableHarvesters.len()  )

			if( DEBUG_PERK_WEAPON_INFUSION_AUTO_LOOP )
			{
				entity activeWeapon = SURVIVAL_GetLastActiveWeapon( player ) //player.GetActiveWeapon( eActiveInventorySlot.mainHand )


				if( IsValid( activeWeapon ) )
				{

					if( IsWeaponValidForInfusion( player, activeWeapon ) )
						Perk_WeaponInfusion_SwapToInfusedWeapon( player, activeWeapon )
				}
			}

			if( DEBUG_PERK_WEAPON_INFUSION_AUTO_LOOP )
				wait DEBUG_PERK_WEAPON_INFUSION_LOOP_TEST_TIME
			else
		#endif //DEV

		WaitFrame()
	}
}
#endif

#if SERVER || CLIENT
bool function IsWeaponValidForInfusion( entity player, entity weapon )
{
	if( !IsValid( weapon ) )
		return false

	LootData data      	= SURVIVAL_GetLootDataFromWeapon( weapon )
	string weaponRef 	= data.baseWeapon

	//Check if the Weapon is already GOLD / CRATE
	if ( SURVIVAL_Loot_IsRefValid( weaponRef ) )
	{
		array<string> baseWeaponlootTags = data.lootTags
		bool isGoldWeapon = data.lootTags.contains( WEAPON_LOCKEDSET_MOD_GOLD )

		if ( isGoldWeapon )
			return false

		bool usesAmmoPool = bool ( GetWeaponInfoFileKeyField_Global( data.baseWeapon, "uses_ammo_pool" ) )
		if ( !usesAmmoPool ) //isCrateWeapon )
			return false
	}

	//If you already have an Infused Weapon, don't allow infusion
	if( player in file.infusedWeaponData )
	{
		entity infusedWeapon = file.infusedWeaponData[ player ].weapon
		if( IsValid( infusedWeapon ) )
			return false
	}

	return true
}
#endif

#if SERVER
void function Perk_WeaponInfusion_SwapToInfusedWeapon( entity player, entity weapon )
{
	LootData data      = SURVIVAL_GetLootDataFromWeapon( weapon )
	string weaponRef = data.baseWeapon
	int slot = GetSlotForWeapon( player, weapon )

	//Drop any attachments previously held by the weapon before Infusion
	array<string> weaponAttachments
	foreach( attachPoint in data.supportedAttachments )
	{
		string attachment = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, attachPoint )
		if( attachment != "" )
		{
			weaponAttachments.append(attachment)
		}
	}

	//Drop Attachments
	//foreach( attachment in weaponAttachments)
	//{
	//	entity drop		= SpawnGenericLoot( attachment, player.EyePosition(), < 0, 0, 0>, 1 )
	//	FakePhysicsThrow( player, drop, RandomVecInDomeWithFOV( player.GetForwardVector(), 45 ) * RandomFloatRange( 100, 250 ), true ) // player.GetForwardVector(), true )
	//}

	//Save Current Weapon Data
	SavedWeaponInfo savedWeaponData
	savedWeaponData.weapon 				= weapon
	savedWeaponData.weaponRef			= weaponRef
	savedWeaponData.lootTags			= data.lootTags
	savedWeaponData.attachments			= weaponAttachments

	file.savedWeaponData[ player ] <- savedWeaponData

	//Remove the Weapon from the Player
	player.TakeWeaponByEntNow( weapon )

	//Spawn and Give a GOLD Version of the Weapon to the Player
	string newWeaponRef = weaponRef + WEAPON_LOCKEDSET_SUFFIX_GOLD
	entity newWeapon = SpawnGenericLoot( newWeaponRef, player.GetOrigin(), < 0, 0, 0>, 1 )
	array<string> lootTags = data.lootTags
	lootTags.append(WEAPON_LOCKEDSET_MOD_GOLD)

	SURVIVAL_GiveMainWeapon( player, newWeapon, lootTags, newWeapon, false, null, false, false, [], true )

	//Destroy the old weapon & fake loot item used to give the Weapon
	newWeapon.Destroy()
	weapon.Destroy()

	//Create the Player's Infused WeaponData
	entity infusedWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	InfusedWeaponInfo info
	info.weapon 	= infusedWeapon
	info.durability	= PERK_INFUSED_WEAPON_MAX_DURABILITY

	file.infusedWeaponData[player] <- info

	player.SetPlayerNetInt( PERK_INFUSED_WEAPON_DURABILITY_NETVAR, PERK_INFUSED_WEAPON_MAX_DURABILITY )

	thread Track_InfusedWeapon_Thread( player, infusedWeapon )

}
#endif

#if SERVER
void function Track_InfusedWeapon_Thread( entity player, entity weapon )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "Deactivate_PerkWeaponInfusion" ) //todo: Do we actually need something else for disconnects? Or does the the disconnect start this up again?

	EndSignal( weapon, "OnDestroy" )

	OnThreadEnd(
		function() : ( player, weapon )
		{
			if( IsValid( player ) )
			{
				CleanUp_InfusedWeapon( player )
			}
		}
	)

	Remote_CallFunction_NonReplay( player, "CL_WeaponDurability_ActivateHUDMeter", player, weapon )

	while( true )
	{
		if( !(player in file.infusedWeaponData) )
			return

		entity storedWeapon = file.infusedWeaponData[player].weapon
		int durability		= file.infusedWeaponData[player].durability

		if( !IsValid( storedWeapon ) )
			return

		int ammo = storedWeapon.GetWeaponPrimaryClipCount()
		bool isFiring = storedWeapon.IsBurstFireInProgress()
		bool isReloading = storedWeapon.IsReloading()

		//printt( isReloading  + "   <--- Reloading: " + storedWeapon + "  |  AmmoInClip: " + ammo )
		if( durability <= 0 && !isFiring && ( ammo <= 0 || isReloading ) )
			return

		WaitFrame()
	}
}
#endif

#if SERVER
void function CleanUp_InfusedWeapon( entity player )
{
	if( !IsValid( player ) )
		return

	Perk_WeaponInfusion_ReturnWeaponToPlayer( player )
	//SURVIVAL_DropWeapon( player, weapon, player.EyePosition(), RandomVecInDomeWithFOV( player.GetForwardVector(), 45 ) * RandomFloatRange( 300, 500 ) )
	if( player in file.infusedWeaponData )
		delete file.infusedWeaponData[player]

	Remote_CallFunction_NonReplay( player, "CL_WeaponDurability_DeactivateHUDMeter", player )
}
#endif

#if SERVER
void function Perk_WeaponInfusion_ReturnWeaponToPlayer( entity player )
{
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if( !IsValid(weapon) )
		return

	if( !( player in file.savedWeaponData ) )
		return

	SavedWeaponInfo savedWeaponData = file.savedWeaponData[player]
	int slot = GetSlotForWeapon( player, weapon )

	//Remove the Weapon from the Player
	player.TakeWeaponByEntNow( weapon )

	//Spawn and Give the BASIC Version of the Weapon to the Player
	entity newWeapon = SpawnGenericLoot( savedWeaponData.weaponRef, player.GetOrigin(), < 0, 0, 0>, 1 )
	array<string> lootTags 		= savedWeaponData.lootTags
	array<string> attachments	= savedWeaponData.attachments

	//Remove GOLD tags - these seem to persist with the slot.
	if( lootTags.contains( WEAPON_LOCKEDSET_MOD_GOLD ) )
		lootTags.fastremovebyvalue(WEAPON_LOCKEDSET_MOD_GOLD)

	SURVIVAL_GiveMainWeapon( player, newWeapon, lootTags, newWeapon, false, null, false, false, attachments, true )

	//Destroy the old weapon & fake loot item used to give the Weapon
	newWeapon.Destroy()
	weapon.Destroy()

	delete file.savedWeaponData[player]
}
#endif //SERVER


#if SERVER
void function Explode_InfusedWeapon( entity player, entity drop, string ref )
{
	wait 1

	if( IsValid(drop) )
	{
		//Explosion FX//
		vector origin = drop.GetOrigin()
		int fxid = GetParticleSystemIndex( PERK_WEAPON_INFUSION_DESTROY_WPN_FX )
		StartParticleEffectInWorld( fxid, origin, <0,0,0> )
		EmitSoundAtPosition( TEAM_UNASSIGNED, origin, PERK_WEAPON_INFUSION_DESTROY_WPN_SFX, drop )


		//Destroy Gold Weapon & Leave behind old weapon and attachments if dropped
		SavedWeaponInfo savedWeaponData = file.savedWeaponData[player]
		array<string> lootTags 		= savedWeaponData.lootTags
		array<string> attachments	= savedWeaponData.attachments

		//Remove GOLD tags - these seem to persist with the slot.
		if( lootTags.contains( WEAPON_LOCKEDSET_MOD_GOLD ) )
			lootTags.fastremovebyvalue(WEAPON_LOCKEDSET_MOD_GOLD)

		if( savedWeaponData.lootTags.contains( WEAPON_LOCKEDSET_MOD_GOLD ) )
			savedWeaponData.lootTags.fastremovebyvalue(WEAPON_LOCKEDSET_MOD_GOLD)

		//Drop Attachments
		foreach( attachment in savedWeaponData.attachments )
		{
			entity dropEnt		= SpawnGenericLoot( attachment, origin, < 0, 0, 0>, 1 )
			FakePhysicsThrow( player, dropEnt, RandomVecInDomeWithFOV( player.GetForwardVector(), 45 ) * RandomFloatRange( 100, 250 ), true ) // player.GetForwardVector(), true )
		}

		entity newWeapon = SpawnGenericLoot( savedWeaponData.weaponRef, origin, < 0, 0, 0>, 1 )

		drop.Destroy()
	}
}
#endif

#if SERVER
void function Perk_WeaponInfusion_OnItemDropped( entity player, string ref, string wpnRef, entity dropEnt )
{
	if ( !(player in file.infusedWeaponData) )
		return

	entity infusedWeapon = file.infusedWeaponData[player].weapon
	if ( IsValid( infusedWeapon ) )
	{
		LootData data    = SURVIVAL_GetLootDataFromWeapon( infusedWeapon )
		string weaponRef = data.baseWeapon
		printt( weaponRef )
		printt( data.ref )
		if ( weaponRef != wpnRef )
			return

		thread Explode_InfusedWeapon( player, dropEnt, data.ref )
	}
}
#endif


#if CLIENT
void function CL_WeaponDurability_ActivateHUDMeter( entity player, entity weapon )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread CL_WeaponDurability_HUDMeterRui_Thread( player )
}

void function CL_WeaponDurability_DeactivateHUDMeter( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	Signal( player, "Deactivate_PerkWeaponInfusion" )
}
#endif //CLIENT

#if CLIENT
void function CL_WeaponDurability_HUDMeterRui_Thread( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "Deactivate_PerkWeaponInfusion" )

	int durability = 0

	OnThreadEnd(
		function() : ( player )
		{
			if(	file.infusedWeaponRui != null )
			{
				RuiDestroy( file.infusedWeaponRui )
				file.infusedWeaponRui = null
			}
		}
	)

	if(	file.infusedWeaponRui != null )
	{
		RuiDestroy( file.infusedWeaponRui )
		file.infusedWeaponRui = null
	}

	durability = player.GetPlayerNetInt( PERK_INFUSED_WEAPON_DURABILITY_NETVAR )

	file.infusedWeaponRui = CreateCockpitRui( $"ui/infused_weapon_durability.rpak" )

	RuiSetFloat( file.infusedWeaponRui, "progress", 0.0 )
	RuiSetString( file.infusedWeaponRui, "barLabel", "DURABILITY" )

	RuiSetInt( file.infusedWeaponRui, "durability", durability )
	RuiSetInt( file.infusedWeaponRui, "maxDurability", PERK_INFUSED_WEAPON_MAX_DURABILITY )

	float progress = 0.0
	while ( true )
	{
		durability = player.GetPlayerNetInt( PERK_INFUSED_WEAPON_DURABILITY_NETVAR )

		progress = durability.tofloat() / PERK_INFUSED_WEAPON_MAX_DURABILITY
		RuiSetInt( file.infusedWeaponRui, "durability", durability )
		RuiSetFloat( file.infusedWeaponRui, "progress", progress )

		WaitFrame()
	}
}
#endif //CLIENT


#if SERVER
void function Perk_WeaponInfusion_OnClientConnected( entity player )
{
	#if DEV
		if ( PERK_WEAPON_INFUSION_DEBUG )
			printf("Perk_WeaponInfusion_OnClientConnected()")
	#endif

	if ( !IsValid( player ) )
		return

	if ( !player.e.entPostDamageCallbacks.contains( Perk_WeaponInfusion_OnPlayerDamaged ) )
		AddEntityCallback_OnDamaged( player, Perk_WeaponInfusion_OnPlayerDamaged )
}

void function Perk_WeaponInfusion_OnPlayerReconnected( entity player )
{
	#if DEV
		if ( PERK_WEAPON_INFUSION_DEBUG )
			printf( "Perk_WeaponInfusion_OnPlayerReconnected()" )
	#endif

	if ( !player.e.entPostDamageCallbacks.contains( Perk_WeaponInfusion_OnPlayerDamaged ) )
		AddEntityCallback_OnDamaged( player, Perk_WeaponInfusion_OnPlayerDamaged )
}
#endif //SERVER

#if SERVER
void function Perk_WeaponInfusion_OnClientDisconnected( entity player )
{
	#if DEV
		if ( PERK_WEAPON_INFUSION_DEBUG )
			printf("Perk_WeaponInfusion_OnClientDisconnected()")
	#endif

	Signal( player, "Deactivate_PerkWeaponInfusion" )

	if ( player.e.entDamageCallbacks.contains( Perk_WeaponInfusion_OnPlayerDamaged ) )
		RemoveEntityCallback_OnDamaged( player, Perk_WeaponInfusion_OnPlayerDamaged )
}
#endif //SERVER

#if SERVER
void function Perk_WeaponInfusion_OnPlayerDamaged( entity player, var damageInfo )
{
	#if DEV
		if ( PERK_WEAPON_INFUSION_DEBUG )
			printf("Perk_WeaponInfusion_OnPlayerDamaged()")
	#endif

	//Check to see if Attacker has a Gold-Infused Weapon
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if( !( attacker in file.infusedWeaponData ) )
		return

	//Check to see if Weapon used was a Gold-Infused Weapon
	entity weapon 			= DamageInfo_GetWeapon( damageInfo )
	entity infusedWeapon 	= file.infusedWeaponData[attacker].weapon
	int durability			= file.infusedWeaponData[attacker].durability

	if( !IsValid( weapon ) || !IsValid( infusedWeapon ) )
		return

	if( weapon != infusedWeapon )
		return

	//Attacker's Weapon was infused - update its durability
	float damage = DamageInfo_GetDamage( damageInfo )
	float durabilityDMG = damage * PERK_WEAPON_INFUSION_DURABILITY_DAMAGE_FRAC

	int newDurability = maxint( 0, durability - durabilityDMG.tointeger() )
	file.infusedWeaponData[attacker].durability = newDurability

	attacker.SetPlayerNetInt( PERK_INFUSED_WEAPON_DURABILITY_NETVAR, newDurability )

	#if DEV
		if ( PERK_WEAPON_INFUSION_DEBUG )
		{
			printt("IW Durability:  " + durability)
			printt("Damage: " + damage + "  | Durability DMG: " + durabilityDMG + "  | Durability: " + newDurability + "/" + PERK_INFUSED_WEAPON_MAX_DURABILITY )
		}
	#endif

}
#endif // SERVER

#if SERVER
void function Perk_WeaponInfusion_OnPlayerKilled( entity player, entity attacker, var damageInfo )
{
	if ( GetGameState() >= eGameState.Playing )
		CleanUp_InfusedWeapon( player )
}
#endif

#if SERVER
void function Perk_WeaponInfusion_OnGamePlaying()
{
	thread Delayed_CreateUnstableHarvesters()
}
#endif

#if SERVER
void function OnCraftingHarvesterSpawned( entity target )
{
	if ( target.GetScriptName() != HARVESTER_SCRIPTNAME )
		return

	file.craftingHarvesters.append( target )
}

void function Delayed_CreateUnstableHarvesters()
{
	////Need to talk to someone about these Harvesters...they're created then destroyed then re-created for some reason...
	wait UNSTALBLE_HARVESTER_CREATION_DELAY

	array<entity> craftingHarvesters	= file.craftingHarvesters

	foreach( harvester in craftingHarvesters )
	{
		if( !IsValid( harvester ) )
			continue

		bool canBeUnstable = true
		vector origin = harvester.GetOrigin()

		foreach( ent in file.unstableHarvesters )
		{
			if( IsValid(ent) )
			{
				float dist = Distance2D( origin, ent.GetOrigin() )
				if( dist < UNSTABLE_HARVESTER_MIN_SEPARATION_RANGE )
				{
					canBeUnstable = false
					break
				}
			}
		}

		if( canBeUnstable )
		{
			file.unstableHarvesters.append( harvester )
			//DebugDrawSphere( harvester.GetOrigin(), 200.0, COLOR_RED, true, 200 )
		}

	}

#if DEV
	if ( PERK_WEAPON_INFUSION_DEBUG )
	{
		printt( "Total Unstable Harvesters: " + file.unstableHarvesters.len() )
	}
#endif

}
#endif //SERVER


#if CLIENT
void function ServerToClient_AppendUnstableHarvesterEnt( entity player, entity randHarvester )
{
	if ( player != GetLocalClientPlayer() )
		return

	if( file.unstableHarvesters.contains(randHarvester) )
		return

	file.unstableHarvesters.append(randHarvester)
}
#endif //CLIENT

#if CLIENT
void function ServerToClient_UpdateUsedHarvesters( entity player, entity harvester )
{
	if ( player != GetLocalViewPlayer() )
		return

	if( !( player in file.playerUsedHarvesters ) )
		file.playerUsedHarvesters[player] <- []
	else if( file.playerUsedHarvesters[player].contains(harvester) )
		return

	file.playerUsedHarvesters[player].append(harvester)
}
#endif //CLIENT


#if SERVER
bool function IsUnstableHarvesterUsable( entity player, entity harvester )
{
	if( !IsValid( harvester ) )
		return false

	if( !( file.unstableHarvesters.contains( harvester ) ) )
		return false

	if( !( player in file.playerUsedHarvesters ) )
		return false

	if( file.playerUsedHarvesters[player].contains(harvester) )
		return false

	return true
}
#endif //SERVER

#if SERVER || CLIENT
bool function IsUnstableHarvesterInActivationRange( entity player, entity harvester )
{

	//todo: We're buypassing the normal USE functionality here.
	//todo: If we go through with this protptype, we should integrate this into the use flow properly

	float distToHarvester = Distance( player.GetOrigin(), harvester.GetOrigin() )
	if( distToHarvester > UNSTABLE_HARVESTER_DISTANCE_TO_INTERACT )
		return false//continue

	vector dirToHarvester = harvester.GetOrigin() - player.GetOrigin()
	float dotToHarvester = DotProduct( player.GetViewForward(), dirToHarvester  )

	if( dotToHarvester > 0.80 )
	{
		return true
	}


	return false
}
#endif

#if CLIENT
void function AttemptUse_UnstableHarvester( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	if ( !( Perks_DoesPlayerHavePerk( player, ePerkIndex.WEAPON_INFUSION ) ) )
		return

	array<entity> unstableHarvesters = file.unstableHarvesters
	foreach( harvester in unstableHarvesters )
	{
		if ( !IsValid( harvester ) )
			continue

		if ( IsUnstableHarvesterInActivationRange( player, harvester ) )
			Remote_ServerCallFunction( "ClientCallback_AttemptUse_UnstableHarvester", harvester )
	}
}
#endif //CLIENT


#if SERVER
void function ClientCallback_AttemptUse_UnstableHarvester( entity player, entity harvester )
{
	if( !IsValid( player ) )
		return
	//Check to see if the Harvester CAN be used, then Infuse the Weapon.
	if( !( player in file.playerUsedHarvesters ) )
		file.playerUsedHarvesters[player] <- []
	else
	{
		bool isHarvesterUsable = IsUnstableHarvesterUsable( player, harvester )
		if( !isHarvesterUsable )
			return
	}

	entity activeWeapon = SURVIVAL_GetLastActiveWeapon( player ) //player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if( IsValid( activeWeapon ) )
	{
		if( IsWeaponValidForInfusion( player, activeWeapon ) )
		{
			Perk_WeaponInfusion_SwapToInfusedWeapon( player, activeWeapon )
			file.playerUsedHarvesters[player].append(harvester)
			Remote_CallFunction_Replay( player, "ServerToClient_UpdateUsedHarvesters", player, harvester )
			thread Create_GoldenBeamActivationVFX_Thread( player, harvester )
		}
	}
}
#endif // SERVER



#if CLIENT
void function CL_Track_UnstableHarvesters_Thread( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	if( player != GetLocalClientPlayer() )
		return

	array<entity> unstableHarvesters = file.unstableHarvesters
	table<entity,int> harvesterBeamFX
	bool useBeam = false

	OnThreadEnd(
		function() : ( harvesterBeamFX, player )
		{
			if( IsValid( player ) )
			{
				foreach( harvester in file.unstableHarvesters )
				{
					if( !IsValid( harvester ) )
						continue

					if( player in file.playerUsedHarvesters )
					{
						if( file.playerUsedHarvesters[player].contains(harvester) )
						{
							if( harvester in harvesterBeamFX )
							{
								int hBeamFX = harvesterBeamFX[harvester]
								if ( EffectDoesExist( hBeamFX ) )
									EffectStop( hBeamFX, true, true )

								delete harvesterBeamFX[harvester]
							}

						}
					}


				}
			}
		}
	)

	entity lastHarvesterInRange
	bool harvestersCreated

	while( true )
	{
		if( !IsValid( player ) )
			return

		if( file.unstableHarvesters.len() > 0 && !harvestersCreated )
		{
			thread CL_UnstalbeHarvester_DisplayOnMap_Thread( player )
			harvestersCreated = true
		}

		foreach( harvester in file.unstableHarvesters )
		{
			if( !IsValid( harvester )  )
				continue

			if( !( harvester in harvesterBeamFX ) )
			{
				if( useBeam )
				{
					int fxid = GetParticleSystemIndex( PERK_WEAPON_INFUSION_UNSTABLE_BEAM_FX )
					int beamHandleFX = StartParticleEffectInWorldWithHandle( fxid, harvester.GetOrigin(), <0,0,0> )

					harvesterBeamFX[harvester] <- beamHandleFX

					//DebugDrawSphere( harvester.GetOrigin(), 50.0, COLOR_YELLOW, true, 120 )
				}

			}

			bool harvesterIsUsed = false

			if( player in file.playerUsedHarvesters )
			{
				if( file.playerUsedHarvesters[player].contains(harvester) )
				{
					if( harvester in harvesterBeamFX )
					{
						harvesterIsUsed = true
						int hBeamFX = harvesterBeamFX[harvester]
						if ( EffectDoesExist( hBeamFX ) )
							EffectStop( hBeamFX, true, true )
					}
				}
			}

			bool inRange = IsUnstableHarvesterInActivationRange( player, harvester )
			if( inRange && !harvesterIsUsed )
			{
				if( harvester != lastHarvesterInRange )
				{
					thread CL_UnstableHarvester_DisplayInfuseWeaponHint_Thread()
					lastHarvesterInRange = harvester
				}
			}
			else
			{
				if( harvester == lastHarvesterInRange )
				{
					Signal( player, "OnLeave_UnstableHarvesterRange" )
					lastHarvesterInRange = null
				}
			}

		}

		WaitFrame()
	}
}

#endif //CLIENT

#if CLIENT
void function CL_UnstableHarvester_DisplayInfuseWeaponHint_Thread()
{
	entity player = GetLocalViewPlayer()

	if ( !IsValid( player ) )
		return

	if( player != GetLocalClientPlayer() )
		return

	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnLeave_UnstableHarvesterRange" )

	var rui = CreateCockpitRui( $"ui/unstable_harvester_use_prompt.rpak", HUD_Z_BASE )

	const string PERK_WEAPON_INFUSION_ACTIVATE_HINT = "#WEAPON_INFUSION_ACTIVATE_HINT"
	const string PERK_WEAPON_INFUSION_INVALID_WEAPON_HINT = "#WEAPON_INFUSION_INVALID_WEAPON_HINT"
	const string PERK_WEAPON_INFUSION_INVALID_WEAPON_ALT_HINT = "#WEAPON_INFUSION_INVALID_WEAPON_ALT_HINT"

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroyIfAlive( rui )
		}
	)

	while ( IsValid( rui ) )
	{
		entity weapon = SURVIVAL_GetLastActiveWeapon( player )
		entity otherWeapon = GetOtherWeapon ( weapon, player )
		bool mainWeaponIsValid = IsWeaponValidForInfusion( player, weapon )
		bool altWeaponIsValid = true

		if( IsValid( otherWeapon ) )
			altWeaponIsValid = IsWeaponValidForInfusion( player, otherWeapon ) //todo: This is a work-around. Need to make the InfusedWeapon Client&Server

		if( mainWeaponIsValid && altWeaponIsValid )
			RuiSetString( rui, "promptText_Use", PERK_WEAPON_INFUSION_ACTIVATE_HINT )
		else if ( mainWeaponIsValid && !altWeaponIsValid )
			RuiSetString( rui, "promptText_Use", PERK_WEAPON_INFUSION_INVALID_WEAPON_ALT_HINT )
		else
			RuiSetString( rui, "promptText_Use", PERK_WEAPON_INFUSION_INVALID_WEAPON_HINT )

		WaitFrame()
	}
}
#endif //CLIENT


#if CLIENT
void function CL_UnstalbeHarvester_DisplayOnMap_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if( player != GetLocalClientPlayer() )
		return

	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	//setup all the ruis for each pod
	table< entity, var > harvesterMRUI
	table< entity, var > harvesterFRUI

	array<entity> unstableHarvesters 	= file.unstableHarvesters
	array<entity> initalizedUnstableHarvesters

	OnThreadEnd(
		function() : ( initalizedUnstableHarvesters, player, harvesterMRUI, harvesterFRUI )
		{
			if( IsValid( player ) )
			{
				foreach ( harvester in initalizedUnstableHarvesters )
				{
					if( !IsValid( harvester ) )
						continue

					if( harvester in harvesterMRUI )
					{
						var mmRui = harvesterMRUI[harvester]
						if( mmRui != null )
						{
							Minimap_CommonCleanup( mmRui )
							delete harvesterMRUI[harvester]
						}
					}

					if( harvester in harvesterFRUI )
					{
						var fmRui = harvesterFRUI[harvester]
						if( fmRui != null )
						{
							Fullmap_RemoveRui( fmRui )
							RuiDestroyIfAlive( fmRui )
							delete harvesterFRUI[harvester]
						}
					}

				}
			}
		}
	)

	while ( true )
	{

		foreach( harvester in file.unstableHarvesters )
		{
			if( !IsValid( harvester ) )
				continue

			//If we haven't initialized this new Droppod - Setup Map Ruis
			if( !(initalizedUnstableHarvesters.contains( harvester ) ) )
			{
				vector pos 			= harvester.GetOrigin()
				asset icon 			= $"rui/menu/character_select/utility/util_role_offense"
				vector iconColor 	= GetKeyColor( COLORID_HUD_LOOT_TIER4 ) * ( 1.0 / 255.0 )

				float miniMapScale	= 1.5
				float fullMapScale 	= 8.0

				var minimapRui = Minimap_AddIconAtPosition( pos, <0,90,0>, icon, miniMapScale, iconColor )
				var fullmapRui = FullMap_AddIconAtPos( pos, <0,0,0>, icon, fullMapScale, iconColor )

				initalizedUnstableHarvesters.append( harvester )
				harvesterMRUI[harvester] <- minimapRui
				harvesterFRUI[harvester] <- fullmapRui
			}


			if( player in file.playerUsedHarvesters )
			{
				if( file.playerUsedHarvesters[ player ].contains( harvester ) )
				{
					if( harvester in harvesterMRUI )
					{
						var mmRui = harvesterMRUI[harvester]
						if( mmRui != null )
						{
							Minimap_CommonCleanup( mmRui )
							delete harvesterMRUI[harvester]
						}
					}

					if( harvester in harvesterFRUI )
					{
						var fmRui = harvesterFRUI[harvester]
						if( fmRui != null )
						{
							Fullmap_RemoveRui( fmRui )
							RuiDestroyIfAlive( fmRui )
							delete harvesterFRUI[harvester]
						}
					}

				}
			}


		}

		WaitFrame()
	}
}
#endif //CLIENT

#if SERVER
entity function Create_UnstableHarvesterWPPing( entity perkOwner, entity harvester )
{
	if ( perkOwner.IsPlayer() )
		EmitSoundOnEntityOnlyToPlayer( perkOwner, perkOwner, "ui_mapping_item_1p" )

	asset icon = $"rui/menu/character_select/utility/util_role_offense"

	vector wpPosition = harvester.GetOrigin()
	entity wp = CreateWaypoint_BasicPos( wpPosition + <0, 0, 48>, "", icon )
	wp.SetOwner( perkOwner )

	wp.SetOnlyTransmitToOnePlayer( perkOwner )

	return wp
}
#endif //SERVER

#if SERVER
void function Create_GoldenBeamActivationVFX_Thread( entity player, entity harvester)
{
	EndSignal(player, "OnDeath")
	EndSignal(player, "OnDestroy")


	vector startPos = harvester.GetOrigin()
	const string PERK_WEAPON_INFUSION_BEAM_MOVER_SCRIPTNAME = "perk_weapon_infusion_beam_mover"
	entity mover = CreateScriptMover( PERK_WEAPON_INFUSION_BEAM_MOVER_SCRIPTNAME, startPos )
	mover.RemoveFromAllRealms()
	mover.AddToOtherEntitysRealms( player )
	vector endPosition = harvester.GetOrigin() + <0,0,1000>

	vector groundFXNormal = Normalize(harvester.GetUpVector())
	entity fx       = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( PERK_WEAPON_INFUSION_UNSTABLE_BEAM_FX ), startPos, <90, 0, 0> + VectorToAngles( groundFXNormal ) )
	fx.SetOwner( player )
	fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	fx.SetParent( mover )


	OnThreadEnd(
		function() : ( fx, mover, player )
		{
			if ( IsValid( fx ) )
			{
				EffectStop(fx)
				fx.Destroy()
			}
			if ( IsValid( mover ) )
			{
				mover.Destroy()
			}

		}
	)
	const float BEAM_DURATION = 0.5

	mover.NonPhysicsMoveTo( endPosition, BEAM_DURATION, 0.0, 0.0 )
	wait BEAM_DURATION

}
#endif //SERVER 