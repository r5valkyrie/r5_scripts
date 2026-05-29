global function MpWeaponReviveShield_Init

global function OnWeaponOwnerChanged_revive_shield
global function OnWeaponPrimaryAttack_revive_shield
global function OnWeaponPrimaryAttackAnimEvent_revive_shield
global function OnWeaponActivate_revive_shield
global function OnWeaponDeactivate_revive_shield

global function ReviveShield_GetMaxShieldHealthFromTier
global function IsEntNewcastleReviver
global function IsEntNewcastleReviveTarget

#if SERVER
global function PassiveAxiom_OnItemDropped
global function PassiveAxiom_GetAxiomKDShieldHealth
global function PassiveAxiom_ShouldDoNewcastleAutoRevive
global function PassiveAxiom_GiveReviveShield
global function ClientCallback_Cancel_NewcastleRevive
#endif
#if CLIENT
global function PassiveAxiom_BeginClientReviveShield_RUI

global function PassiveAxiom_ActivateKDShieldHUDMeter
global function PassiveAxiom_DeActivateKDShieldHUDMeter

global function ServerToClient_DisplayCancelNewcastleReviveHintForPlayer
global function ServerToClient_RemoveCancelNewcastleReviveHintForPlayer
#endif // #if CLIENT

///// Revive Shield Varaibles /////
const bool REVIVE_SHIELD_DEBUG = false
const bool REVIVE_SHIELD_GIVES_KD_BONUS = true

const REVIVE_SHIELD_FX_WALL_FP 							= $"P_NC_down_shield_CP"
const REVIVE_SHIELD_FX_WALL 							= $"P_NC_down_shield_CP"
const REVIVE_SHIELD_FX_COL 								= $"mdl/fx/down_shield_NC.rmdl"
const REVIVE_SHIELD_FX_BREAK 							= $"P_NC_down_shield_break_CP"
const REVIVE_SHIELD_FX_ARM_BEAM							= $"P_NC_down_shield_arm_glow"

const string REVIVE_SHIELD_IMPACT_FX_TABLE 				= "newcastle_revive_jetwash"

const bool REVIVE_SHIELD_IS_FASTER_THAN_CROUCH			= true
const float REVIVE_SHIELD_MOVE_SLOW_SEVERITY 			= 0.05	//0.05 //Currently Unused in favour of Increased Revive Speed beyond crouch walk default
const float REVIVE_SHIELD_TURN_SLOW_SEVERITY 			= 0.3 	//0.6
const float REVIVE_SHIELD_SPEED_BOOST_SEVERITY			= 0.25	//
const float REVIVE_SHIELD_MAX_SPEED 					= 200
const float REVIVE_TARGET_USE_DEBOUNCE 					= 0.3
const float AUTO_REVIVE_MAX_ALLOWED_DIST_FROM_GROUND 	= 200.0

const string KNOCKDOWN_SHIELD_BASIC 					= "incapshield_pickup_lv0"
const int BLEEDOUT_DISABLED_WEAPON_TYPES 				= WPT_ALL_EXCEPT_VIEWHANDS_OR_INCAP

//SHIELD HEALTH
const int REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_1 		= 200 //150 //200
const int REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_2 		= 300 //350 //450
const int REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_3 		= 500 //750

const string NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR 		= "newcastleReviveShieldHP"

//SHIELD REGEN VARIABLES
const float SHIELD_REGEN_RATE_PER_SECOND 				= 8.5 				// how many points of shields regen per second

const string RECHARGING_START_SOUND 					= "CampFire_Healing_Start_1P"
const string RECHARGING_SHIELDS_SOUND 					= "CampFire_Healing_Loop_1P"
const string RECHARGING_COMPLETE_SOUND 					= "CampFire_Healing_End_1P"

const string RECHARGING_START_SOUND_3P 					= "CampFire_Healing_Start_3P"
const string RECHARGING_SHIELDS_SOUND_3P 				= "CampFire_Healing_Loop_3P"
const string RECHARGING_COMPLETE_SOUND_3P 				= "CampFire_Healing_End_3P"

const string SOUND_REVIVE_BASE_3P 						= "Newcastle_ReviveShield_OgRevive_3p"
const string SOUND_REVIVE_SHIELD_3P 					= "Newcastle_ReviveShield_Sustain_3p"
const string SOUND_REVIVE_SHIELD_1P 					= "Newcastle_ReviveShield_Sustain_1p"

const string SOUND_PILOT_INCAP_SHIELD_END_3P 			= "BleedOut_Shield_Break_3P"
const string SOUND_PILOT_INCAP_SHIELD_END_1P 			= "BleedOut_Shield_Break_1P"

const string REVIVE_SHIELD_SIGNAL_BEGIN_CHARGE			= "ReviveShieldBeginCharge" //passive_kd_shield_charge
const string REVIVE_SHIELD_SIGNAL_END_CHARGE			= "OnPassiveAxiom_ReviveShieldEnd"
const string REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE 	= "ReviveShieldHPTrackingComplete"
const string REVIVE_SHIELD_SIGNAL_ON_DAMAGED			= "ReviveShield_OnDamaged"
const string REVIVE_SHIELD_SIGNAL_END_HUD_METER			= "ReviveShield_EndHUDMeter"
const string REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END		= "OnPassiveAxiom_AutoReviveEnd"

                    
global function ReviveShield_GetUpgradedReviveExtraHealth
      

struct
{
	bool isReviveWithKDShieldValue = REVIVE_SHIELD_GIVES_KD_BONUS

	int reviveShield_HP_LV1			= REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_1
	int reviveShield_HP_LV2			= REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_2
	int reviveShield_HP_LV3			= REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_3
	float reviveShield_RegenRate	= SHIELD_REGEN_RATE_PER_SECOND
	float reviveShield_MoveSlow		= REVIVE_SHIELD_MOVE_SLOW_SEVERITY
	float reviveShield_TurnSlow		= REVIVE_SHIELD_TURN_SLOW_SEVERITY
	float reviveShield_SpeedBoost	= REVIVE_SHIELD_SPEED_BOOST_SEVERITY

	bool isFasterThanCrouchSpeed	= REVIVE_SHIELD_IS_FASTER_THAN_CROUCH

	array<entity> reviveShieldEnts
	table<entity, bool> hasReviveShield = {}
	table<entity, string> reviveShieldRef = {}
	table<entity, bool> isReviveShieldRegen = {}
	table<entity, bool> isReviveIntro = {}
	table<entity, bool> isReviveHPTracking = {}

	#if SERVER
	table<entity, entity> reviveTarget = {}
	#endif

} file


void function MpWeaponReviveShield_Init()
{
	PrecacheWeapon( $"mp_weapon_revive_shield" )

	//Version Output Testing//
	file.isReviveWithKDShieldValue 	= GetCurrentPlaylistVarBool( "axiom_revive_shield_vKDValue", REVIVE_SHIELD_GIVES_KD_BONUS )

	//Live Tunables
	file.reviveShield_HP_LV1			= GetCurrentPlaylistVarInt( "newcastle_revive_shield_HP_lv1", REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_1 )
	file.reviveShield_HP_LV2			= GetCurrentPlaylistVarInt( "newcastle_revive_shield_HP_lv2", REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_2 )
	file.reviveShield_HP_LV3			= GetCurrentPlaylistVarInt( "newcastle_revive_shield_HP_lv3", REVIVE_SHIELD_MAX_SHIELD_HEALTH_TIER_3 )
	file.reviveShield_RegenRate			= GetCurrentPlaylistVarFloat( "newcastle_revive_shield_regen_rate", SHIELD_REGEN_RATE_PER_SECOND )
	file.reviveShield_MoveSlow			= GetCurrentPlaylistVarFloat( "newcastle_revive_shield_move_slow_severity", REVIVE_SHIELD_MOVE_SLOW_SEVERITY )
	file.reviveShield_TurnSlow			= GetCurrentPlaylistVarFloat( "newcastle_revive_shield_turn_slow_severity", REVIVE_SHIELD_TURN_SLOW_SEVERITY )
	file.reviveShield_SpeedBoost		= GetCurrentPlaylistVarFloat( "newcastle_revive_shield_speed_boost_severity", REVIVE_SHIELD_SPEED_BOOST_SEVERITY )
	file.isFasterThanCrouchSpeed		= GetCurrentPlaylistVarBool( "newcastle_revive_shield_isFasterThanCrouchSpeed", REVIVE_SHIELD_IS_FASTER_THAN_CROUCH )

	PrecacheModel( REVIVE_SHIELD_FX_COL )

	PrecacheParticleSystem( REVIVE_SHIELD_FX_WALL_FP )
	PrecacheParticleSystem( REVIVE_SHIELD_FX_WALL )
	PrecacheParticleSystem( REVIVE_SHIELD_FX_BREAK )
	PrecacheParticleSystem( REVIVE_SHIELD_FX_ARM_BEAM )

	PrecacheImpactEffectTable( REVIVE_SHIELD_IMPACT_FX_TABLE )

	RegisterSignal( REVIVE_SHIELD_SIGNAL_BEGIN_CHARGE )
	RegisterSignal( REVIVE_SHIELD_SIGNAL_END_CHARGE )
	RegisterSignal( REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE )
	RegisterSignal( REVIVE_SHIELD_SIGNAL_ON_DAMAGED )
	RegisterSignal( REVIVE_SHIELD_SIGNAL_END_HUD_METER )
	RegisterSignal( REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )

	Remote_RegisterClientFunction( "PassiveAxiom_BeginClientReviveShield_RUI", "entity" )
	Remote_RegisterClientFunction( "PassiveAxiom_ActivateKDShieldHUDMeter", "entity" )
	Remote_RegisterClientFunction( "PassiveAxiom_DeActivateKDShieldHUDMeter", "entity" )

	AddCallback_OnPassiveChanged( ePassives.PAS_AXIOM, OnPassiveChanged )

	RegisterNetworkedVariable( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_INT, -1 )

	Remote_RegisterServerFunction( "ClientCallback_Cancel_NewcastleRevive" )
	Remote_RegisterClientFunction( "ServerToClient_DisplayCancelNewcastleReviveHintForPlayer" )
	Remote_RegisterClientFunction( "ServerToClient_RemoveCancelNewcastleReviveHintForPlayer" )

	#if SERVER
		Loot_AddCallback_OnPlayerLootPickup( PassiveAxiom_OnPlayerLootPickUp )
		Bleedout_AddCallback_OnPlayerStartGiveFirstAid( PassiveAxiom_OnPlayerStartGiveFirstAid )
		Bleedout_AddCallback_OnPlayerGotFirstAid( PassiveAxiom_OnRecievedFirstAid )
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+toggle_duck", AttemptCancel_NewcastleRevive_Console ) //%use% use_alt //"+toggle_duck" //+weaponcycle
		RegisterConCommandTriggeredCallback( "+use", AttemptCancel_NewcastleRevive_PC ) //%use% use_alt
	#endif

	#if CLIENT || UI
		AddCallback_EditLootDesc( Axiom_EditKnockdownLootDesc )
	#endif
}

                    
float function ReviveShield_GetUpgradeCoreHealthMultiplier()
{
	return GetCurrentPlaylistVarFloat( "passive_revive_shield_health_upgrade_multiplier", 1.25 )
}

float function ReviveShield_GetUpgradedReviveExtraHealth()
{
	return GetCurrentPlaylistVarFloat( "passive_revive_shield_upgrade_extra_revive_health", 30 )
}
      

/////
int function ReviveShield_GetMaxShieldHealthFromTier( int tier, entity player )
{
	int shieldHealth
	switch( tier )
	{
		case 0:
			shieldHealth = 0
			break
		case 2:
			shieldHealth = file.reviveShield_HP_LV2
			break
		case 3:
			shieldHealth = file.reviveShield_HP_LV3
			break
		case 4:
			shieldHealth = file.reviveShield_HP_LV3
			break
		default:
			shieldHealth = file.reviveShield_HP_LV1
	}

	                    
	/*if( player.HasPassive( ePassives.PAS_UPGRADED_REVIVE_SHIELD_HEALTH ) )
	{
		shieldHealth = int( shieldHealth * ReviveShield_GetUpgradeCoreHealthMultiplier() )
	}*/
       

	return shieldHealth
}


////


///// Passive Change ////
#if SERVER || CLIENT
void function OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if ( didHave == nowHas )
		return

	if( didHave )
	{
		#if SERVER
			Signal( player, REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE )
		#endif

		#if CLIENT
			Signal( player, REVIVE_SHIELD_SIGNAL_END_HUD_METER )
		#endif
	}

	if ( nowHas )
	{
		#if SERVER
			thread PassiveAxiom_TrackReviveShieldHealth_Thread( player )
		#endif
	}

}
#endif


#if CLIENT || UI
string function Axiom_EditKnockdownLootDesc( string lootRef, entity player, string originalDesc )
{
	string finalDesc = originalDesc
	#if CLIENT
		// skip if crafting, since the extra hint text overlaps other rui elements
		if (Crafting_IsPlayerAtWorkbench(player))
			return finalDesc
	#endif

	if ( SURVIVAL_Loot_GetLootDataByRef( lootRef ).lootType == eLootType.INCAPSHIELD
			&& IsValid( player )
			&& LoadoutSlot_IsReady( ToEHI( player ), Loadout_Character() )
			&& ItemFlavor_GetAsset( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() ) ) == $"settings/itemflav/character/newcastle.rpak" )
	{

		string desc = ""
		switch( lootRef )
		{
			case "incapshield_pickup_lv1":
				desc = Localize( "#SURVIVAL_PICKUP_INCAPSHIELD_LV1_HINT_NEWCASTLE" )
				break
			case "incapshield_pickup_lv2":
				desc = Localize( "#SURVIVAL_PICKUP_INCAPSHIELD_LV2_HINT_NEWCASTLE" )
				break
			case "incapshield_pickup_lv3":
				desc = Localize( "#SURVIVAL_PICKUP_INCAPSHIELD_LV3_HINT_NEWCASTLE" )
				break
			case "incapshield_pickup_lv4_selfrevive":
				desc = Localize( "#SURVIVAL_PICKUP_INCAPSHIELD_LV4_HINT_NEWCASTLE" )
				break
			default:
				desc = Localize( "#SURVIVAL_PICKUP_INCAPSHIELD_LV1_HINT_NEWCASTLE" )
				break
		}
		return desc
	}
	return finalDesc
}
#endif

///////////////////////
/// Loot Management ///
///////////////////////
#if SERVER
void function PassiveAxiom_OnPlayerLootPickUp( entity player, entity lootPickup, string ref, int unitsPickedUp, bool willDestroy, entity deathBox, int pickupFlags )
{
	if ( !(PlayerHasPassive( player, ePassives.PAS_AXIOM )) )
		return

	if ( !IsValid( player ) )
		return

	if ( SURVIVAL_Loot_GetLootDataByRef( ref ).lootType != eLootType.INCAPSHIELD )
		return

	Signal( player, REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE )
	Remote_CallFunction_NonReplay( player, "PassiveAxiom_DeActivateKDShieldHUDMeter", player )

	int shieldHP = GetPropSurvivalMainPropertyFromEnt( lootPickup )

	entity lastOwner = lootPickup.e.lastOwner
	if( lastOwner != player ) //If player was not the last owner - Reset the Shield HP to 0 (default state)
		shieldHP = 0

	if( shieldHP > 0 )
	{
		file.hasReviveShield[ player ] <- true
		player.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, shieldHP )
	}
	else
	{
		int incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )
		if( incapShieldTier > 0 )
		{
			file.hasReviveShield[ player ] <- true
			player.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player ) )
		}
	}

	thread PassiveAxiom_TrackReviveShieldHealth_Thread( player )
}
#endif

#if SERVER
void function PassiveAxiom_OnItemDropped( entity player, string ref, entity dropEnt )
{
	if ( !(PlayerHasPassive( player, ePassives.PAS_AXIOM )) )
		return

	if ( !IsValid( player ) )
		return

	LootData basicShield = SURVIVAL_Loot_GetLootDataByRef( "incapshield_pickup_lv0" )
	string equipSlot     = GetLootTypeData( basicShield.lootType ).equipmentSlot

	string equipRef = EquipmentSlot_GetLootRefForSlot( player, equipSlot )

	if ( equipRef == ref ) //We've dropped our KD shield!
	{
		int shieldHP = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR )
		if( shieldHP <= 0 )
			shieldHP = 1 //Set dropped shields to have 1HP. Default properties are 0, which we use on pickup to determine a new/used shield.

		SetPropSurvivalMainPropertyOnEnt( dropEnt, shieldHP )
		dropEnt.e.lastOwner = player

		Signal( player, REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE )
		Remote_CallFunction_NonReplay( player, "PassiveAxiom_DeActivateKDShieldHUDMeter", player )
		return
	}
}
#endif
//////////////////////////


//////////////////////////////////////
///// REVIVE SHIELD FUNCTIONALITY ////
//////////////////////////////////////
#if SERVER
void function PassiveAxiom_OnPlayerStartGiveFirstAid( entity reviver, entity target, vector animRefAngles, bool endCrouched )
{
	if( !( PassiveAxiom_ShouldDoNewcastleAutoRevive( reviver, target ) ) )
		return

	if ( PlayerHasPassive( reviver, ePassives.PAS_AXIOM ) )
	{
		if( !(file.reviveShieldEnts.contains( reviver ) ) )
		{
			file.reviveShieldEnts.append( reviver )
		}

		file.isReviveIntro[ reviver ] <- true
		//file.reviveTarget[ reviver ] <- target
		thread ReviveShield_DelayedSetReviveTarget( reviver, target )

		entity weapon = reviver.GetActiveWeapon( eActiveInventorySlot.mainHand  ) //The incap shield is given to Axiom when reviving.

		thread ReviveShield_ChargeThread( weapon, reviver )
		thread PassiveAxiom_ReviveInterrupt_Thread( reviver, target )

		Remote_CallFunction_NonReplay( reviver, "PassiveAxiom_BeginClientReviveShield_RUI", reviver )
		Remote_CallFunction_Replay( reviver, "ServerToClient_DisplayCancelNewcastleReviveHintForPlayer")
		thread PassiveAxiom_EndActiveWeaponUse_Thread( reviver, weapon )
		thread PassiveAxiom_TrackReviveIsGrounded_Thread( reviver, weapon, target )

	}
}
#endif

#if SERVER
void function ReviveShield_DelayedSetReviveTarget(entity reviver, entity target)
{
	EndSignal( reviver, "OnDeath" )
	EndSignal( reviver, "OnDestroy" )
	EndSignal( reviver, "BleedOut_OnStartDying" )
	EndSignal( target, "OnDeath" )
	EndSignal( target, "OnDestroy" )

	WaitFrame() //We delay the setting of the target for the cancel prompt to ensure no race conditions/allowance of cancel on the same frame
	if( !IsValid( reviver ) || !IsValid( target ) )
		return

	if( Bleedout_IsPlayerGivingFirstAid( reviver ) && Bleedout_IsPlayerGettingFirstAid( target ) )
		file.reviveTarget[ reviver ] <- target
}
#endif

#if SERVER
void function PassiveAxiom_TrackReviveIsGrounded_Thread( entity reviver, entity weapon, entity target )
{
	EndSignal( reviver, "OnDeath" )
	EndSignal( reviver, "OnDestroy" )
	EndSignal( reviver, "BleedOut_OnStartDying" )
	EndSignal( reviver, REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, REVIVE_SHIELD_SIGNAL_END_CHARGE )
	EndSignal( target, "OnDeath" )
	EndSignal( target, "OnDestroy" )

	OnThreadEnd(
		function() : ( reviver, weapon )
		{
			if( IsValid( reviver ) )
			TakePlayerSettingsMods( reviver, [ "disable_jump" ] )
		}
	)

	//Prevent Jumping/BHopping
	GivePlayerSettingsMods( reviver, [ "disable_jump" ] )

	while( true )
	{
		if( !reviver.IsOnGround() )
		{
			vector origin = reviver.GetOrigin()
			array<entity> ignoreArray = GetPlayerArray_Alive()
			TraceResults groundTrace = TraceLine( origin, origin + <0, 0, -AUTO_REVIVE_MAX_ALLOWED_DIST_FROM_GROUND>, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
			//DebugDrawSphere( groundTrace.endPos, 10.0, int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), true, 10 )
			if ( groundTrace.fraction == 1.0 )
			{
				//We are falling. Break the Revive
				Signal( reviver, "BleedOut_ReviveForceStop" )
				Signal( reviver, REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )
			}
		}
		else
		{
			//With the speed increase on the Newcastle Revive, physics allows you to start sliding downhill.
			//To curb insane speeds, if we're going too fast horizontally during a revive, we kill it each frame until its back under control.
			//We only do this on ground to allow use of Jump-Pads and other legitiamte boosts/knocks to function and separate in air correctly
			vector curVelocity = reviver.GetVelocity()
			if( Length2D( curVelocity ) > REVIVE_SHIELD_MAX_SPEED )
				reviver.SetVelocity( curVelocity * 0.5 )
		}

		WaitFrame()
	}
}
#endif

#if SERVER
void function PassiveAxiom_OnRecievedFirstAid( entity player, entity reviver )
{
	if ( PlayerHasPassive( player, ePassives.PAS_AXIOM ) )
	{
		entity heldKDShield = player.GetNormalWeapon( KNOCKDOWN_SHIELD_SLOT )

		if ( !IsValid( heldKDShield ) )
			return

		if( file.isReviveWithKDShieldValue )
		{
			int shieldHP = heldKDShield.GetScriptInt0()

			int maxReviveShieldHealth = ReviveShield_GetMaxShieldHealthFromTier( IncapShield_GetShieldTier( player ), player )
			if( shieldHP > maxReviveShieldHealth )
				shieldHP = maxReviveShieldHealth

			heldKDShield.SetScriptInt0( shieldHP )
		}
		else
		{
			int maxIncapShieldHealth = IncapShield_GetMaxShieldHealthFromTier( IncapShield_GetShieldTier( player ) )
			int maxReviveShieldHealth = ReviveShield_GetMaxShieldHealthFromTier( IncapShield_GetShieldTier( player ), player )

			int shieldDiff = maxint( maxIncapShieldHealth - maxReviveShieldHealth, 0 )

			int shieldHP = maxint( heldKDShield.GetScriptInt0() - shieldDiff, 0 )

			heldKDShield.SetScriptInt0( minint( shieldHP, maxReviveShieldHealth ) )
		}

		if( player in file.hasReviveShield )
			player.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, heldKDShield.GetScriptInt0() )
	}

}
#endif

#if SERVER
void function PassiveAxiom_EndActiveWeaponUse_Thread( entity reviver, entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( REVIVE_SHIELD_SIGNAL_END_CHARGE )

	//printt( "Distance Travelled:  " + GetStat_Int( reviver, ResolveStatEntry( CAREER_STATS.newcastle_revive_distance ), eStatGetWhen.CURRENT ) )
	thread NewcastleStatTrackerPassiveDistance( reviver, weapon )

	OnThreadEnd(
		function() : ( reviver, weapon )
		{
			if( file.reviveShieldEnts.contains( reviver ) )
				file.reviveShieldEnts.fastremovebyvalue( reviver )

			if( IsValid( weapon ) )
				reviver.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, weapon.GetScriptInt0() )

			if( IsValid( reviver ) )
				Remote_CallFunction_Replay( reviver, "ServerToClient_RemoveCancelNewcastleReviveHintForPlayer")

			if( reviver in file.reviveTarget )
				delete file.reviveTarget[ reviver ]
		}
	)
	WaitForever()

}
#endif

#if SERVER
void function NewcastleStatTrackerPassiveDistance( entity newcastle, entity weapon )
{
	EndSignal( newcastle, "OnDestroy" )
	EndSignal( newcastle, "BleedOut_OnStartDying" )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, REVIVE_SHIELD_SIGNAL_END_CHARGE )

	vector curPos                = newcastle.GetOrigin()
	float distanceSinceLastCheck = 0
	float totalDistance          = 0

	OnThreadEnd(
		function() : ( newcastle, totalDistance, curPos )
		{
			float distanceSinceLastCheck = (Distance( curPos, newcastle.GetOrigin() ) * INCHES_TO_METERS )
			int distanceToAdd          = (totalDistance + distanceSinceLastCheck).tointeger()
			StatsHook_NewcastleReviveDistanceTraveled( newcastle, distanceToAdd )
		}
	)

	while ( true )
	{
		distanceSinceLastCheck = (Distance( curPos, newcastle.GetOrigin() ) * INCHES_TO_METERS )
		totalDistance += distanceSinceLastCheck
		curPos                 = newcastle.GetOrigin()

		Wait( 0.5 )
	}
}
#endif

var function OnWeaponPrimaryAttack_revive_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

var function OnWeaponPrimaryAttackAnimEvent_revive_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

void function OnWeaponOwnerChanged_revive_shield( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if SERVER
		entity newOwner = weapon.GetWeaponOwner()
		if ( IsValid( newOwner ) )
			weapon.SetScriptInt0( ReviveShield_GetMaxShieldHealthFromTier( IncapShield_GetShieldTier( newOwner ), newOwner ))
		else
			weapon.Destroy()
	#endif // #if SERVER
}

void function OnWeaponActivate_revive_shield( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	#if SERVER
		entity oldShieldEnt = weapon.GetWeaponUtilityEntity()
		if ( IsValid( oldShieldEnt ) )
		{
			// Remove any stale CShieldProp entity
			oldShieldEnt.Destroy()
			weapon.SetWeaponUtilityEntity( null )
		}

		if ( !weaponOwner.IsPlayer() )
			return

		if ( PlayerHasPassive( weaponOwner, ePassives.PAS_AXIOM ) )
		{
			if( !(weaponOwner in file.isReviveHPTracking ) )
				thread PassiveAxiom_TrackReviveShieldHealth_Thread( weaponOwner )

			if( !( weaponOwner in file.hasReviveShield ) )
			{
				weaponOwner.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, weapon.GetScriptInt0() )
			}
			else
			{
				weapon.SetScriptInt0( weaponOwner.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ) )
			}
		}
		else
			return //Only Newcastle ( Axiom ) should have a Revive Shield

		float shieldMaxHealth = float( ReviveShield_GetMaxShieldHealthFromTier( IncapShield_GetShieldTier( weaponOwner ), weaponOwner ) )
		if ( shieldMaxHealth <= 0 )
		{
			if ( REVIVE_SHIELD_DEBUG )
				printt( "IncapShield_Activate     NO MAX ENERGY for", weaponOwner )

			return
		}

		int shieldEnergy = weapon.GetScriptInt0()
		if ( shieldEnergy <= 0 )
		{
			if ( REVIVE_SHIELD_DEBUG )
				printt( "IncapShield_Activate     NO ENERGY LEFT for", weaponOwner )

			return
		}

		//Collision Shield//
		GunShieldSettings gs
		gs.invulnerable			= false
		gs.maxHealth			= shieldMaxHealth
		gs.impacteffectcolorID	= IncapShield_GetShieldImpactColorID( weaponOwner )
		gs.ownerWeapon			= weapon
		gs.owner				= weaponOwner
		gs.parentEnt			= weaponOwner
		gs.parentAttachment		= "REVIVE_SHIELD"
		gs.model				= REVIVE_SHIELD_FX_COL
		gs.modelHide			= true
		gs.modelOverrideAngles	= <0, 0, 0>

		entity shieldEnt = CreateGunAttachedShield_PropShield( gs )
		if ( !IsValid( shieldEnt ) )
			return

		shieldEnergy = minint( shieldEnergy, shieldEnt.GetMaxHealth() )
		shieldEnt.SetHealth( shieldEnergy )

		if ( REVIVE_SHIELD_DEBUG )
			printt( "IncapShield_Activate    ", shieldEnergy, "energy for", shieldEnt )

		IncapShield_SetShieldEntCollision( shieldEnt, false )

		weapon.SetWeaponUtilityEntity( shieldEnt )
		AddEntityCallback_OnPostDamaged( shieldEnt, ReviveShield_OnShieldEntDamaged )
	#endif // #if SERVER
}

void function OnWeaponDeactivate_revive_shield( entity weapon )
{
	weapon.Signal( REVIVE_SHIELD_SIGNAL_END_CHARGE )

	#if SERVER
		entity oldShieldEnt = weapon.GetWeaponUtilityEntity()
		if ( IsValid( oldShieldEnt ) )
		{
			oldShieldEnt.Destroy()
			weapon.SetWeaponUtilityEntity( null )
		}
	#endif // #if SERVER
}

#if SERVER
void function ReviveShield_OnShieldEntDamaged( entity shieldEnt, var damageInfo )
{
	int damage			= int( DamageInfo_GetDamage( damageInfo ) )
	entity attacker		= DamageInfo_GetAttacker( damageInfo )
	vector damageOrigin	= DamageInfo_GetDamagePosition( damageInfo )

	if ( damage <= 0 )
		return

	if ( IsValid( attacker ) )
	{
		if ( IsFriendlyTeam( attacker.GetTeam(), shieldEnt.GetTeam() ) )
			return

		if ( attacker.IsPlayer() )
			attacker.NotifyDidDamage( shieldEnt, 0, damageOrigin, 0, damage, DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX, 0, null, 0 )
	}

	int newHealth = maxint( shieldEnt.GetHealth() - damage, 0 )

	if ( REVIVE_SHIELD_DEBUG )
		printt( FUNC_NAME(), "for", shieldEnt, "took", damage, "damage, new health:", newHealth )

	shieldEnt.SetHealth( newHealth )

	if ( newHealth == 0 )
		shieldEnt.SetCollisionAllowed( false )

	entity weapon = shieldEnt.e.ownerWeapon
	entity player = shieldEnt.GetOwner()

	if ( IsValid( weapon ) && IsValid( player ) )
	{
		weapon.SetScriptInt0( newHealth )
		player.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, newHealth )

		Signal( player, REVIVE_SHIELD_SIGNAL_ON_DAMAGED )

		player.ViewPunch( damageOrigin, 2.0, 1.0, 1.0 )
		if ( newHealth == 0 )
		{
			weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, 0 )

			int fxIdx			= GetParticleSystemIndex( REVIVE_SHIELD_FX_BREAK )
			int attachIdx		= player.LookupAttachment( "REVIVE_SHIELD" )
			vector attachOrigin	= player.GetAttachmentOrigin( attachIdx )
			vector attachAngles	= player.GetAttachmentAngles( attachIdx )

			entity fxEnt = StartParticleEffectInWorld_ReturnEntity( fxIdx, attachOrigin, attachAngles )
			EffectSetControlPointVector( fxEnt, 2, GetIncapShieldTriLerpColor( 1.0, IncapShield_GetShieldTier( player ) ) )

			EmitSoundOnEntityExceptToPlayer( player, player, SOUND_PILOT_INCAP_SHIELD_END_3P )
			EmitSoundOnEntityOnlyToPlayer( player, player, SOUND_PILOT_INCAP_SHIELD_END_1P )
		}
	}
}

void function ReviveShield_ChargeThread( entity weapon, entity player )
{
	Assert( weapon )
	Assert( player )
	Assert ( IsNewThread(), "Must be threaded off" )

	entity shieldEnt = weapon.GetWeaponUtilityEntity()
	if ( !IsValid( shieldEnt ) )
	{
		if ( REVIVE_SHIELD_DEBUG )
			printt( FUNC_NAME(), "shieldEnt is INVALID for", player )

		return
	}

	// Only one thread ever exists for this weapon
	weapon.Signal( REVIVE_SHIELD_SIGNAL_BEGIN_CHARGE )
	weapon.EndSignal( REVIVE_SHIELD_SIGNAL_BEGIN_CHARGE )
	weapon.EndSignal( REVIVE_SHIELD_SIGNAL_END_CHARGE )

	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnReviveStart" )
	shieldEnt.EndSignal( "OnDestroy" )

	// DO NOT REMOVE, this WaitFrame is EXTREMELY important
	// shieldEnt collision will be broken without it
	if ( GetBugReproNum() != 201218 )
		WaitFrame()

	if ( REVIVE_SHIELD_DEBUG )
		printt( "IncapShield_ChargeThread BEGIN for", shieldEnt )

	PIN_PlayerUse( player, weapon.GetWeaponClassName(), "REVIVE_SHIELD" ) //

	// Collision
	IncapShield_SetShieldEntCollision( shieldEnt, true )

	while ( Bleedout_IsPlayerSelfReviving( player ) )
	{
		wait 0.2
	}

	// VFX for the Shield //
	GunShieldSettings gs
	gs.owner				= player
	gs.shieldFX				= REVIVE_SHIELD_FX_WALL
	gs.useFriendlyEnemyFx	= false
	gs.useFxColorOverride	= true
	gs.fxColorOverride		= GetIncapShieldColorFromInventory( player )
	gs.fxOverrideAngles		= <-5, 180, 0>
	entity shieldFxEnt		= StartGunAttachedShieldFX( gs, shieldEnt )
	// shieldFxEnt is already added to shieldEnt.e.fxControlPoints

	foreach ( fxEnt in shieldEnt.e.fxControlPoints )
	{
		fxEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	}

	// SFX
	EmitSoundOnEntityOnlyToPlayer( player, player, SOUND_REVIVE_SHIELD_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SOUND_REVIVE_SHIELD_3P )

	//Arm Beam FX
	int fxIdx			= GetParticleSystemIndex( REVIVE_SHIELD_FX_ARM_BEAM )
	int attachIdx		= player.LookupAttachment( "L_FOREARM" )
	vector attachOrigin	= player.GetAttachmentOrigin( attachIdx )
	vector attachAngles	= player.GetAttachmentAngles( attachIdx )

	//attachAngles = AnglesCompose( attachAngles, <0, 90, 0> ) //This angles the forward vector of the L_FOREARM ahead
	attachAngles = AnglesCompose( attachAngles, <90, 180, 90> ) //This angles the current beam "forward"

	//todo: Kevin - Try what you want to get it to align. If we want it to always face the shield, we can probably update the angles dynamically.
	//entity armFXEnt = StartParticleEffectOnEntity_ReturnEntity( player, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx )
	entity armFXEnt = StartParticleEffectOnEntityWithPos_ReturnEntity( player, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx, attachOrigin, attachAngles )
	EffectSetControlPointVector( armFXEnt, 1, GetIncapShieldColorFromInventory( player ) ) //Set the Arm FX Glow color


	OnThreadEnd(
		function () : ( shieldEnt, weapon, player, armFXEnt, )
		{
			if ( REVIVE_SHIELD_DEBUG )
				printt( "IncapShield_ChargeThread END   for", shieldEnt )

			if ( IsValid( shieldEnt ) )
			{
				IncapShield_SetShieldEntCollision( shieldEnt, false )

				foreach ( fxEnt in shieldEnt.e.fxControlPoints )
					EffectStop( fxEnt )

				shieldEnt.e.fxControlPoints.clear()
			}

			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, SOUND_REVIVE_SHIELD_1P )
				StopSoundOnEntity( player, SOUND_REVIVE_SHIELD_3P )

			}

			if( IsValid( armFXEnt ) )
			{
				EffectStop( armFXEnt )
				armFXEnt.Destroy()
			}

		}
	)

	int gurneyAttachIdx		= player.LookupAttachment( "SHIELD" )
	vector gurneyOrigin		= player.GetAttachmentOrigin( gurneyAttachIdx )
	float trackDist			= 0
	vector gurneyPos		= gurneyOrigin
	const float REVIVE_SHIELD_IMPACT_FX_MIN_DIST = 20

	float startTime 	= Time()
	float introBuffer	= 1.0

	while ( true )
	{
		vector playerVelocity = player.GetVelocity()
		//printt( " X:   " + Length( playerVelocity ) )
		if( player in file.isReviveIntro )
			if( Time() > startTime + introBuffer && file.isReviveIntro[player] )
				file.isReviveIntro[player] <- false

		UpdateIncapShieldFX( shieldEnt, GetHealthFrac( shieldEnt ) )

		gurneyOrigin		= player.GetAttachmentOrigin( gurneyAttachIdx )
		trackDist += Distance( gurneyOrigin, gurneyPos )

		if( trackDist >= REVIVE_SHIELD_IMPACT_FX_MIN_DIST )
		{
			PlayImpactFXTable( gurneyOrigin, player, REVIVE_SHIELD_IMPACT_FX_TABLE )
			trackDist = 0
			gurneyPos = gurneyOrigin
		}

		WaitFrame()
	}
}

#endif // #if SERVER


/////////////////////////////////////
//// Revive Shield Health & Regen ///
/////////////////////////////////////

#if SERVER
int function PassiveAxiom_GetAxiomKDShieldHealth( entity player ) ///This function is used externally in mp_weapon_incap_shield (to apply Axiom's shield HP to the Incap Shield when downed)
{
	int shieldHealth = 0
	if( !(PlayerHasPassive( player, ePassives.PAS_AXIOM ) ) )
		return 0

	if( !IsValid( player) )
		return 0

	shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR )

	return shieldHealth
}
#endif

#if SERVER
void function PassiveAxiom_TrackReviveShieldHealth_Thread( entity player )
{
	Signal( player, REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE )
	EndSignal( player, REVIVE_SHIELD_SIGNAL_HP_TRACKING_COMPLETE )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	if ( !(PlayerHasPassive( player, ePassives.PAS_AXIOM )) )
		return

	if ( !IsValid( player ) )
		return

	file.isReviveHPTracking[player] <- true

	if( !( player in file.isReviveShieldRegen ) )
		file.isReviveShieldRegen[player] <- false

	LootData basicShield = SURVIVAL_Loot_GetLootDataByRef( "incapshield_pickup_lv0" )
	string equipSlot     = GetLootTypeData( basicShield.lootType ).equipmentSlot

	string equipRef = EquipmentSlot_GetLootRefForSlot( player, equipSlot )
	while ( equipRef == "" )
	{
		if ( !IsValid( player ) )
			return

		if ( player in file.hasReviveShield )
			delete file.hasReviveShield[ player ]

		Remote_CallFunction_NonReplay( player, "PassiveAxiom_DeActivateKDShieldHUDMeter", player )

		equipRef = EquipmentSlot_GetLootRefForSlot( player, equipSlot )
		if ( equipRef != "" )
		{
			break
		}

		WaitFrame()
	}

	int incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )

	//Set the Initial Player's Revive Shield Reference & Shield Health Value
	if( !( player in file.reviveShieldRef ) )
	{
		file.reviveShieldRef[player] <- equipRef
		Remote_CallFunction_NonReplay( player, "PassiveAxiom_ActivateKDShieldHUDMeter", player )
	}

	if( !( player in file.hasReviveShield ) )
	{
		file.hasReviveShield[ player ] <- true
		if( incapShieldTier > 0 )
		{
			player.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player ) )
		}

	}

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
			{
				Signal( player, REVIVE_SHIELD_SIGNAL_ON_DAMAGED )
				if( player in file.isReviveHPTracking )
					delete file.isReviveHPTracking[player]
			}

			if ( player in file.reviveShieldRef )
				delete file.reviveShieldRef[player]

			if( player in file.hasReviveShield )
			{
				LootData basicShield = SURVIVAL_Loot_GetLootDataByRef( "incapshield_pickup_lv0" )
				string equipSlot     = GetLootTypeData( basicShield.lootType ).equipmentSlot

				string equipRef = EquipmentSlot_GetLootRefForSlot( player, equipSlot )
				if ( equipRef == "" )
				{
					delete file.hasReviveShield[ player ]
				}
			}

			if( player in file.isReviveShieldRegen )
				delete file.isReviveShieldRegen[player]

		}
	)

	const float REVIVE_SHIELD_REGEN_DELAY	= 2.0

	float RegenDelayEndTime		= Time() + REVIVE_SHIELD_REGEN_DELAY
	string lastRef 				= equipRef
	int maxShieldHealth 		= ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player )

	while ( true )
	{
		if( player in file.reviveShieldRef )
		{
			//We have a KDShield
			equipRef = EquipmentSlot_GetLootRefForSlot( player, equipSlot )

			//Check to see if it's a NEW revive Shield
			if( lastRef != equipRef )
			{
				if ( equipRef == "" ) 	//No KD Shield - we shouldn't be in here anymore.
				{
					break
				}
				else   //New KD Shield - Re-Assign and set MaxHP of the new shield for use in Regen
				{
					lastRef = equipRef
					incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )
					if( incapShieldTier > 0 )
						maxShieldHealth = ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player )
				}
			}

			if( player in file.hasReviveShield )
			{
				int shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR )
				if( shieldHealth >= maxShieldHealth )	//Shield HP is Max
				{
					shieldHealth = maxShieldHealth
					RegenDelayEndTime = Time() + REVIVE_SHIELD_REGEN_DELAY

					if( player in file.isReviveShieldRegen )
						file.isReviveShieldRegen[ player ] = false
				}
				else //Shield HP is low, need to start Regen Thread.
				{
					//Don't Allow REGEN if you're actively using the Shield OR in a Bleedout State
					bool isBusy = Bleedout_IsPlayerGivingFirstAid(player) || Bleedout_IsPlayerSelfReviving(player) || player.GetBleedoutState() > 0

					if( isBusy )
					{
						RegenDelayEndTime = Time() + REVIVE_SHIELD_REGEN_DELAY
						if( player in file.isReviveShieldRegen )
							file.isReviveShieldRegen[ player ] = false
					}

					bool isRegen = false
					if( player in file.isReviveShieldRegen )
						isRegen = file.isReviveShieldRegen[ player ]

					if( Time() > RegenDelayEndTime && !isRegen && !isBusy)
					{
						//Start KD SHILED REGEN thread
						thread PassiveAxiom_ReviveShieldRegen_Thread( player, maxShieldHealth )
						if( player in file.isReviveShieldRegen )
							file.isReviveShieldRegen[ player ] = true
					}

				}

			}
		}
		else
			break

		WaitFrame()
	}
}
#endif //SERVER

#if SERVER
void function PassiveAxiom_ReviveShieldRegen_Thread( entity player, int maxShield )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, REVIVE_SHIELD_SIGNAL_ON_DAMAGED ) //This will be needed to RESET the shield regen in some capacity


	OnThreadEnd(
		function() : ( player )
		{
			if( player in file.isReviveShieldRegen )
				file.isReviveShieldRegen[ player ] = false
		}
	)

	WaitFrame() // need this for the player's shield value to update after shield damage so it doesn't ignore it

	if( !( IsValid( player ) ) )
		return

	if( !( player in file.hasReviveShield ) )
		return

	float regenRate = file.reviveShield_RegenRate

	float lastframe = Time()
	float oRegenScalar = 1

	float shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ).tofloat()

	OnThreadEnd(
		function() : (  player )
		{
		}
	)

	while ( shieldHealth < maxShield )
	{
		float elapsedTime = Time() - lastframe
		lastframe = Time()
		float regenAmount = elapsedTime * regenRate

		if( !( player in file.hasReviveShield ) )
			return

		if( Bleedout_IsPlayerGivingFirstAid(player) || Bleedout_IsPlayerSelfReviving(player) || player.GetBleedoutState() > 0 )
			return

		shieldHealth = shieldHealth + regenAmount
		int newShieldHealth = shieldHealth.tointeger()
		if(newShieldHealth >= maxShield )
			newShieldHealth = maxShield

		int repairAmount = newShieldHealth - player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR )
		//printt( "RepairAmount = " + repairAmount + "   || NetInt_sHP: " + player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ) )

		if ( repairAmount > 0 )
			player.SetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR, newShieldHealth )

		WaitFrame()
	}

	//EmitSoundOnEntityExceptToPlayer( player, player, RECHARGING_COMPLETE_SOUND_3P )
	//EmitSoundOnEntityOnlyToPlayer( player, player, RECHARGING_COMPLETE_SOUND )

}
#endif //SERVER


//////////////////////////////
//// PASSIVE HUD & RUI  //////
//////////////////////////////


#if CLIENT
void function PassiveAxiom_ActivateKDShieldHUDMeter( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	thread CL_PassiveAxiom_KDShieldChargeRUI_Thread( player )
}

void function PassiveAxiom_DeActivateKDShieldHUDMeter( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	Signal( player, REVIVE_SHIELD_SIGNAL_END_HUD_METER )
}
#endif //CLIENT

#if CLIENT
void function CL_PassiveAxiom_KDShieldChargeRUI_Thread( entity player )
{
	EndSignal( player, REVIVE_SHIELD_SIGNAL_END_HUD_METER )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	if ( !IsValid( GetLocalClientPlayer() ) )
		return

	array<var> ruis
	var rui = CreateCockpitRui( $"ui/passive_kd_shield_charge.rpak", HUD_Z_BASE )

	ruis.append( rui )

	OnThreadEnd(
		function() : ( ruis )
		{
			foreach ( rui in ruis )
				RuiDestroyIfAlive( rui )
		}
	)

	float shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ).tofloat()
	float maxShieldHealth = 0.0
	int incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )
	if( incapShieldTier > 0 )
	{
		LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "incapshield" )

		maxShieldHealth = float( ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player ) )
		RuiSetInt( rui, "shieldTier", incapShieldTier )
	}

	RuiSetFloat( rui, "shieldHealth", shieldHealth )
	RuiSetFloat( rui, "maxShieldHealth", maxShieldHealth )

	RuiTrackFloat( rui, "bleedoutEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
	RuiTrackFloat( rui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )

	                    
	// If Legend Upgrades are enabled and we are using them in this mode, we'll move the rui over a bit to prevent overlap
	if ( UpgradeCore_ArmorTiedToUpgrades() )
	{
		RuiSetFloat( rui, "startXPos", 400.0 )
		RuiSetFloat( rui, "elementXpos", 400.0 )
	}
       

	while ( IsValid( rui ) )
	{
		shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ).tofloat()

		RuiSetFloat( rui, "shieldHealth", shieldHealth )
		RuiSetFloat( rui, "maxShieldHealth", maxShieldHealth )
		incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )
		if( incapShieldTier > 0 )
		{
			maxShieldHealth = float( ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player ) )
			RuiSetInt( rui, "shieldTier", incapShieldTier )
		}

		bool isWeaponInspect = false
		entity viewWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if( IsValid( viewWeapon ) )
		{
			if ( viewWeapon.GetWeaponActivity() == ACT_VM_WEAPON_INSPECT )
				isWeaponInspect = true
		}

		RuiSetBool( rui, "weaponInspect", isWeaponInspect )
		WaitFrame()
	}
}
#endif //CLIENT


#if CLIENT
void function PassiveAxiom_BeginClientReviveShield_RUI( entity reviver )
{
	if ( reviver != GetLocalClientPlayer() )
		return

	entity weapon = reviver.GetActiveWeapon( eActiveInventorySlot.mainHand  )

	LootData basicShield = SURVIVAL_Loot_GetLootDataByRef( "incapshield_pickup_lv0" )
	string equipSlot = GetLootTypeData( basicShield.lootType ).equipmentSlot

	string equipRef = EquipmentSlot_GetLootRefForSlot( reviver, equipSlot )
	if ( equipRef == "" )
		return

	thread CL_PassiveAxiom_KDShieldReviveChargeRUI_Thread( reviver, weapon )
}
#endif //#if CLIENT


#if CLIENT
void function CL_PassiveAxiom_KDShieldReviveChargeRUI_Thread( entity player, entity weapon )
{
	EndSignal( player, REVIVE_SHIELD_SIGNAL_END_HUD_METER )
	EndSignal( player, REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( REVIVE_SHIELD_SIGNAL_END_CHARGE )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Bleedout_OnRevive" )

	if ( !IsValid( GetLocalClientPlayer() ) )
		return

	array<var> ruis
	var rui = CreateCockpitPostFXRui( $"ui/passive_revive_shield_charge.rpak", HUD_Z_BASE )

	ruis.append( rui )

	OnThreadEnd(
		function() : ( ruis )
		{
			foreach ( rui in ruis )
				RuiDestroyIfAlive( rui )
		}
	)

	float maxShieldHealth = 0.0
	int incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )
	if( incapShieldTier > 0 )
	{
		LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "incapshield" )

		maxShieldHealth = float( ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player ) )
		RuiSetInt( rui, "shieldTier", incapShieldTier )
	}

	float shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ).tofloat()

	RuiSetFloat( rui, "shieldHealth", shieldHealth )
	RuiSetFloat( rui, "maxShieldHealth", maxShieldHealth )

	RuiTrackFloat( rui, "bleedoutEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
	RuiTrackFloat( rui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )

	while ( IsValid( rui ) )
	{
		shieldHealth = player.GetPlayerNetInt( NEWCASTLE_REVIVE_SHIELD_HEALTH_NETVAR ).tofloat()

		RuiSetFloat( rui, "shieldHealth", shieldHealth )
		RuiSetFloat( rui, "maxShieldHealth", maxShieldHealth )
		incapShieldTier = EquipmentSlot_GetEquipmentTier( player, "incapshield" )
		if( incapShieldTier > 0 )
		{
			maxShieldHealth = float( ReviveShield_GetMaxShieldHealthFromTier( incapShieldTier, player ) )
			RuiSetInt( rui, "shieldTier", incapShieldTier )
		}

		bool isVisible = true
		if ( AreAbilitiesSilenced( player ) )
			isVisible = false

		RuiSetBool( rui, "isVisible", isVisible )

		WaitFrame()
	}
}
#endif //CLIENT


#if SERVER
void function PassiveAxiom_GiveReviveShield( entity reviver, entity target )
{
	if( !IsValid( reviver ) || !IsValid( target ) )
		return

	thread PassiveAxiom_EquipReviveShield_Thread( reviver, target )
}

void function PassiveAxiom_EquipReviveShield_Thread( entity reviver, entity target )
{
	reviver.EndSignal( "OnAnimationInterrupted" )
	reviver.EndSignal( "OnDeath" )
	reviver.EndSignal( "ScriptAnimStop" )
	reviver.EndSignal( "OnContinousUseStopped" )
	reviver.EndSignal( "BleedOut_OnStartDying" )
	reviver.EndSignal( "BleedOut_ReviveForceStop" )
	reviver.EndSignal( "OnDestroy" )

	Assert( IsValid( target ) )
	target.EndSignal( "OnDestroy" )
	target.EndSignal( "BleedOut_OnReviveStop" )

	reviver.SetVelocity(ZERO_VECTOR) //Makes the player stop first. Prevents sliding shield res, but maybe less fun?
	reviver.SetUseDoomedAnims( true ) //The Newcastle revive anims no longer have the doomed condition, but without this they break.  Either leave it for now or can investigate later. -TNordin

	reviver.Zipline_Stop()
	reviver.Zipline_Disallow()
	reviver.ClearTraverse()
	reviver.DisableMantle()

	int forceCrouchHandle = reviver.PushForcedStance( FORCE_STANCE_CROUCH )
	reviver.SetOneHandedWeaponUsageOn()

	// Movement Adjustments
	bool isFasterThanCrouchSpeed = file.isFasterThanCrouchSpeed
	int statusEffect 	= eStatusEffect.move_slow
	float severity		= file.reviveShield_MoveSlow
	if( isFasterThanCrouchSpeed )
	{
		statusEffect 	=  eStatusEffect.speed_boost
		severity		= file.reviveShield_SpeedBoost
	}

	int slowTurnHandle	 		= StatusEffect_AddEndless( reviver, eStatusEffect.turn_slow, file.reviveShield_TurnSlow )
	int movementSpeedHandle 	= StatusEffect_AddEndless( reviver, statusEffect , severity )

	int lastActiveSlot = WEAPON_INVENTORY_SLOT_PRIMARY_2
	LootData basicShield = SURVIVAL_Loot_GetLootDataByRef( KNOCKDOWN_SHIELD_BASIC )
	string equipSlot = GetLootTypeData( basicShield.lootType ).equipmentSlot

	entity aw = reviver.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( aw ) )
	{
		array<int> slots = [ WEAPON_INVENTORY_SLOT_PRIMARY_0,
			WEAPON_INVENTORY_SLOT_PRIMARY_1,
			WEAPON_INVENTORY_SLOT_PRIMARY_2,
			WEAPON_INVENTORY_SLOT_ANTI_TITAN,
		]

		foreach ( slot in slots )
		{
			if ( reviver.GetNormalWeapon( slot ) == aw )
			{
				lastActiveSlot = slot
				break
			}
		}
	}

	// All player's must at least have a basic lvl 0 knockdown shield
	if ( Inventory_GetPlayerEquipment( reviver, equipSlot ) == "" )
		Inventory_SetPlayerEquipment( reviver, KNOCKDOWN_SHIELD_BASIC, equipSlot )

	reviver.GiveWeapon( "mp_weapon_revive_shield", KNOCKDOWN_SHIELD_SLOT )
	reviver.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, KNOCKDOWN_SHIELD_SLOT )

	LockWeaponsAndMelee( reviver, "bleedout" ) //todo: What is the "bleedout" tag here for?

	reviver.DeployWeapon()



	OnThreadEnd(
		function() : ( reviver, equipSlot, lastActiveSlot, forceCrouchHandle, movementSpeedHandle, slowTurnHandle )
		{
			if ( IsValid( reviver ) )
			{
				StatusEffect_Stop( reviver, movementSpeedHandle )
				StatusEffect_Stop( reviver, slowTurnHandle )
				reviver.RemoveForcedStance( forceCrouchHandle )
				reviver.SetOneHandedWeaponUsageOff()
				reviver.Zipline_Allow()
				reviver.EnableMantle()
				reviver.SetUseDoomedAnims( false )
				reviver.ClearTrackEntitySettings()

				UnlockWeaponsAndMelee( reviver, "bleedout" )

				reviver.TakeNormalWeaponByIndexNow( KNOCKDOWN_SHIELD_SLOT )

				if ( lastActiveSlot != WEAPON_INVENTORY_SLOT_PRIMARY_0 && lastActiveSlot != WEAPON_INVENTORY_SLOT_PRIMARY_1 )
				{
					bool setActiveWeaponSuccess = false

					if ( IsValid( reviver.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) ) )
					{
						reviver.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
						setActiveWeaponSuccess = true
					}
					else if ( IsValid( reviver.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 ) ) )
					{
						reviver.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_1 )
						setActiveWeaponSuccess = true
					}
					else if ( lastActiveSlot == WEAPON_INVENTORY_SLOT_ANTI_TITAN )
					{
						entity grenadeWeapon = reviver.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )

						if ( IsValid( grenadeWeapon ) )
						{
							string grenadeWeaponName = grenadeWeapon.GetWeaponClassName()
							int ammo = SURVIVAL_NumItemsInInventory( reviver, grenadeWeaponName )
							if ( ammo > 0 )
							{
								reviver.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_ANTI_TITAN )
								setActiveWeaponSuccess = true
							}
						}
					}

					if ( !setActiveWeaponSuccess )
					{
						reviver.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_2 )
					}
				}
				else
				{
					reviver.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, lastActiveSlot )
				}

				reviver.DeployWeapon()
			}

			if ( Inventory_GetPlayerEquipment( reviver, equipSlot ) == KNOCKDOWN_SHIELD_BASIC )
				Inventory_SetPlayerEquipment( reviver, "", equipSlot )

		}
	)

	wait DEFAULT_FIRSTAID_TIME

}
#endif

#if SERVER
bool function PassiveAxiom_ShouldDoNewcastleAutoRevive( entity player, entity target )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_AXIOM ) )
		return false

	if ( player == target  )
		return false

	if ( AreAbilitiesSilenced( player ) )
		return false

	//If the test works out and we want a toggle. Add the toggle setting condition here.

	return true
}
#endif //SERVER


#if SERVER
void function ClientCallback_Cancel_NewcastleRevive( entity player )
{
	//We need to use this to actually interrupt the revive action.
	if( player in file.reviveTarget )
	{
		entity reviveTarget = file.reviveTarget[player]
		Remote_CallFunction_Replay( player, "ServerToClient_RemoveCancelNewcastleReviveHintForPlayer")
		Signal( player, "OnContinousUseStopped" )

		if( IsValid( reviveTarget ) )
			thread  DelayedSetReviveTargetUseable( reviveTarget, REVIVE_TARGET_USE_DEBOUNCE )
	}
}
#endif

#if CLIENT
void function AttemptCancel_NewcastleRevive_PC( entity player )
{
	if (!AttemptCancel_Allow(player) )
		return

	if( !IsControllerModeActive() )
		Remote_ServerCallFunction( "ClientCallback_Cancel_NewcastleRevive" )
}

void function AttemptCancel_NewcastleRevive_Console( entity player )
{
	if (!AttemptCancel_Allow(player) )
		return

	if( IsControllerModeActive() )
		Remote_ServerCallFunction( "ClientCallback_Cancel_NewcastleRevive" )

}

bool function AttemptCancel_Allow( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return false
	if ( player != GetLocalClientPlayer() )
		return false
	if ( !PlayerHasPassive( player, ePassives.PAS_AXIOM ) )
		return false

	return true
}

void function ServerToClient_DisplayCancelNewcastleReviveHintForPlayer()
{
	thread _DisplayCancelNewcastleReviveHintForPlayer()
}

void function ServerToClient_RemoveCancelNewcastleReviveHintForPlayer()
{
	GetLocalViewPlayer().Signal( REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )
}

void function _DisplayCancelNewcastleReviveHintForPlayer()
{
	entity player = GetLocalViewPlayer()

	if ( !IsValid( player ) )
		return

	EndSignal( player, "OnDeath" )
	EndSignal( player, REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )
	if( IsControllerModeActive() )
	{
		AddPlayerHint( 6.5, 0.15, $"", "#NEWCASTLE_PASSIVE_CANCEL_REVIVE_HINT_CONSOLE" )
	}
	else
		AddPlayerHint( 6.5, 0.15, $"", "#NEWCASTLE_PASSIVE_CANCEL_REVIVE_HINT_PC" )

	OnThreadEnd(
		function() : ()
		{
			HidePlayerHint( "#NEWCASTLE_PASSIVE_CANCEL_REVIVE_HINT_PC" )
			HidePlayerHint( "#NEWCASTLE_PASSIVE_CANCEL_REVIVE_HINT_CONSOLE" )
		}
	)

	WaitForever()
}
#endif


#if SERVER
void function DelayedSetReviveTargetUseable( entity target, float delay )
{
	EndSignal( target, "OnDestroy" )
	EndSignal( target, "OnDeath" )

	if ( delay > 0.0 )
	{
		target.UnsetUsable()
		wait delay
	}

	if( !IsValid( target ) )
		return

	//Resetting useable flags for Bleedout State
	target.SetUsableByGroup( "pilot" )
	target.SetUsePrompts( " ", " " )
	target.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_NO_FOV_REQUIREMENTS | USABLE_SHRINK_USEABLE_BOX | USABLE_BLOCK_CONTINUOUS_USE )
}
#endif

bool function IsEntNewcastleReviver( entity ent )
{
	if( !( ent in file.isReviveIntro ) )
		return false

	if( file.isReviveIntro[ent] )
		return false

	if( ent.GetPlayerSettings() == $"settings/player/mp/pilot_survival_newcastle.rpak" && ent.ContextAction_IsReviving() )
		return true

	return false
}

bool function IsEntNewcastleReviveTarget( entity ent )
{
	if( !( ent.ContextAction_IsBeingRevived() ) )
		return false

	entity parentEnt = ent.GetParent()
	if( !IsValid( parentEnt ) )
		return false

	if( IsEntNewcastleReviver( parentEnt ) )
		return true

	return false
}

#if SERVER
void function PassiveAxiom_ReviveInterrupt_Thread( entity ent, entity target )
{
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "OnDeath" )
	EndSignal( ent, "OnContinousUseStopped" )
	EndSignal( ent, "BleedOut_OnStartDying" )
	EndSignal( ent, "BleedOut_ReviveForceStop" )
	EndSignal( ent, "PhaseTunnel_PhaseTunnelEntered" )

	EndSignal( target, "OnDestroy" )
	EndSignal( target, "OnDeath" )
	EndSignal( target, "PhaseTunnel_PhaseTunnelEntered" )
	EndSignal( target, "BleedOut_OnRevive" )

	OnThreadEnd(
		function() : ( ent )
		{
			if( IsValid(ent) )
			{
				Signal( ent, "BleedOut_ReviveForceStop" )
				Signal( ent, REVIVE_SHIELD_SIGNAL_AUTO_REVIVE_END )
				Remote_CallFunction_Replay( ent, "ServerToClient_RemoveCancelNewcastleReviveHintForPlayer")
				Signal( ent, "OnContinousUseStopped" )
				StopSoundOnEntity( ent, SOUND_REVIVE_BASE_3P )
			}

		}
	)

	EmitSoundOnEntity( ent, SOUND_REVIVE_BASE_3P )

	WaitForever()
}
#endif 