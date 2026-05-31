global function MpAbilityConduitArcFlash_Init

global function OnWeaponOwnerChanged_ability_conduit_arc_flash
global function OnWeaponActivate_ability_conduit_arc_flash
global function OnWeaponDeactivate_ability_conduit_arc_flash
global function OnWeaponReadyToFire_ability_conduit_arc_flash
global function OnWeaponAttemptOffhandSwitch_ability_conduit_arc_flash
global function OnWeaponPrimaryAttack_ability_conduit_arc_flash
global function OnWeaponPrimaryAttackAnimEvent_ability_conduit_arc_flash

global function GetArcFlashRangeSqr
global function GetArcFlashState

#if SERVER
#if DEVELOPER
global function DEV_ApplyConduitTac
#endif

global function SetPlayerTempshieldAmt
#endif

#if CLIENT
global function GetConduitShieldRui
#endif

const float TARGETING_CONE_DOT = DOT_50DEGREE//DOT_15DEGREE//DOT_60DEGREE

const float ARC_FLASH_INCLUSIVE_RANGE = 5 * METERS_TO_INCHES
const float ARC_FLASH_MIN_RANGE = 5 * METERS_TO_INCHES
const float ARC_FLASH_MIN_RANGE_SQR = ARC_FLASH_MIN_RANGE * ARC_FLASH_MIN_RANGE
global const float ARC_FLASH_MAX_RANGE = 50 * METERS_TO_INCHES
const float LOS_MAX_TIME_MISSING = 0.5

const float ARC_FLASH_REGEN_DURATION = 9
const float ARC_FLASH_REGEN_SEVERITY = 1.0
const float ARC_FLASH_TEMPSHIELD_DURATION = 20.0
const float ARC_FLASH_TEMPSHIELD_SEVERITY = 0.5
const float ARC_FLASH_REGEN_INTERVAL = 0.2
const int ARC_FLASH_REGEN_SHIELD_PER_FRAME = 3
const float ARC_FLASH_REGEN_DAMAGE_DELAY = 2.0
const float ARC_FLASH_REGEN_SELF_MULTIPLIER = 0.67
const int ARC_FLASH_DECAY_RATE = 2
const float ARC_FLASH_DECAY_SEVERITY = 0.1
global const int MAX_TEMPSHIELD = 125


const string ARC_FLASH_NAME = "mp_ability_conduit_arc_flash"
const string ARC_FLASH_TARGET_FAIL_GENERIC = "No targets found"
const string ARC_FLASH_TARGET_FAIL_NO_SHIELDS = "Not enough shields or health"
const string ARC_FLASH_TARGET_FAIL_LOS = "Line of sight obstructed"
const string ARC_FLASH_TARGET_FAIL_FACING = "No ally in view"
const string ARC_FLASH_TARGET_FAIL_RANGE = "Out of range"
const string ARC_FLASH_TARGET_FAIL_FULL_SHIELDS = "Friendly shields full"
const string ARC_FLASH_TARGET_SUCCESS_USING_HEALTH = "Using health"



const string SOUND_ARC_FLASH_BEAM_1P = "Conduit_Tac_Fire_1p"//"Conduit_Tac_Fire_1p"//
const string SOUND_ARC_FLASH_BEAM_3P	= "Conduit_Tac_Fire_3p"//"Conduit_Tac_Fire_3p"//"Wattson_Ultimate_I"

const string SOUND_ARC_FLASH_LESSER_BEAM_1P = "Conduit_Tac_FireSelf_1p"//"campfire_healing_start_1p"
const string SOUND_ARC_FLASH_LESSER_BEAM_3P	= "Conduit_Tac_FireSelf_3p"//"campfire_healing_start_3p"//"Wattson_Ultimate_I"

const string SOUND_ARC_FLASH_RECEIVE_1P = "Conduit_Tac_ImpactTeam_1p" //"Conduit_Tac_ImpactTeam_3p"
const string SOUND_ARC_FLASH_RECEIVE_3P = "Conduit_Tac_ImpactTeam_3p" //"Conduit_Tac_ImpactTeam_3p"

const string SOUND_TEMPSHIELD_CHARGE_1P = "Conduit_Tac_Healing_Loop_1p"
const string SOUND_TEMPSHIELD_CHARGE_3P = "Conduit_Tac_Healing_Loop_3p"
const string SOUND_TEMPSHIELD_CHARGE_END_1P = "Conduit_Tac_Healing_End_1p"
const string SOUND_TEMPSHIELD_CHARGE_END_3P = "Conduit_Tac_Healing_End_3p"
const string SOUND_TEMPSHIELD_CHARGE_FINISHING_1P = "Conduit_Tac_Healing_Finishing_1p"
const float SOUND_TEMPSHIELD_CHARGE_FINISHING_DURATION = 4.0
const string SOUND_TEMPSHIELD_SHIELD_WARNING_1P = "Conduit_Tac_Shields_Ending_Warning_1p"
const float SOUND_TEMPSHIELD_SHIELD_WARNING_DURATION = 2.0


const asset FX_TAC_MUZZLE_FLASH = $"P_con_tac_MuzzleFX"
const asset FX_TAC_BEAM = $"P_con_tac_energyRope"
const asset FX_TEMPSHIELD_1P = $"P_con_tac_buff_1p"
const asset FX_TEMPSHIELD_3P = $"P_con_tac_regen_test"
const asset FX_TEMPSHIELD_HIT_3P = $"P_con_tac_hitFX"
const string MUZZLE_ATTACH = "attach_l_drone_arm_b"

const asset DEBUG_SPHERE_SOFT_FX = $"debug_sphere_soft"
const asset DEBUG_SPHERE_ADD_EDGE_FX = $"debug_sphere_add_edge"


global const string CONDUIT_ARC_FLASH_BEST_TARGET_NETVAR = "conduit_arc_flash_bestTarget"
global const string TEMPSHIELD_ACTIVE_NETVAR = "tempshields_active"

const bool ARC_FLASH_DEBUG = false

enum eLockResult
{
	FAILED_GENERIC,
	FAILED_NOT_FACING_ALLY,
	FAILED_NO_LOS_TO_ALLY,
	FAILED_OUT_OF_RANGE,
	FAILED_ALREADY_FULL,
	THRESHOLD,
	SUCCESS,
}

global enum eArcFlashState
{
	NONE,
	CHARGE,
	ACTIVE,
	DECAY,
	COUNT
}


#if DEVELOPER
array<string> sArcFlashStateStrings =
[
	"NONE"
	"CHARGE",
	"ACTIVE",
	"DECAY"
]
#endif


#if CLIENT
enum eShieldState
{
	INVALID,
	FULL,
	HIGH,
	LOW,
	CRITICAL,
}
#endif

struct
{
	#if CLIENT
		var shieldsRepairingRui = null
	#endif

	table< entity, array<entity> > trackedAllys
	#if SERVER
		table< entity , bool > shouldConsumeAmmoOnDeactivate
	#endif


} file

void function MpAbilityConduitArcFlash_Init()
{
	PrecacheParticleSystem( FX_TAC_MUZZLE_FLASH )
	PrecacheParticleSystem( FX_TAC_BEAM )
	PrecacheParticleSystem( FX_TEMPSHIELD_1P )
	PrecacheParticleSystem( FX_TEMPSHIELD_3P )
	PrecacheParticleSystem( FX_TEMPSHIELD_HIT_3P )
	PrecacheParticleSystem( DEBUG_SPHERE_SOFT_FX )
	PrecacheParticleSystem( DEBUG_SPHERE_ADD_EDGE_FX )

	RegisterSignal( "TargetingStop" )
	RegisterSignal( "RefreshTempshield" )

	RegisterNetworkedVariable( CONDUIT_ARC_FLASH_BEST_TARGET_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_ENTITY )
	RegisterNetworkedVariable( TEMPSHIELD_ACTIVE_NETVAR, SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )

	#if SERVER
		RegisterSignal( "ArcFlashCompleted" )
	#endif

	#if DEVELOPER
	Assert( eArcFlashState.COUNT == sArcFlashStateStrings.len(), "Must define a string for each state." )
	#endif

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.shields_repairing, ArcFlash_StartShieldsRepairing )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.shields_repairing, ArcFlash_StopShieldsRepairing )

		RegisterSignal( "ArcFlash_EndShieldsRepairing" )
	#endif
}

                    
float function GetArcFlashUpgradedRangeScaler()
{
	return GetCurrentPlaylistVarFloat( "upgrade_arc_flash_range_scaler", 1.2 ) // upgrade_conduit_tac_range
}
      

float function GetArcFlashRange( entity player )
{
	float result = ARC_FLASH_MAX_RANGE

	                    
	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_conduit_tac_range
	{
		result *= GetArcFlashUpgradedRangeScaler()
	}
       

	return result
}

                    
float function TempshieldRegen_GetExtraChargeRegenScaler()
{
	return GetCurrentPlaylistVarFloat( "upgrade_arc_flash_exta_charge_regen_scaler", .5 ) // upgrade_conduit_tac_charge
}
      

float function GetArcFlashDuration( entity player, int state )
{
	float result = 1

	switch ( state )
	{
		case eArcFlashState.CHARGE:
			result = ARC_FLASH_REGEN_DURATION
			                    
			if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_conduit_tac_charge
			{
				result *= TempshieldRegen_GetExtraChargeRegenScaler()
			}
         
			break
		case eArcFlashState.ACTIVE:
			result = ARC_FLASH_TEMPSHIELD_DURATION
			break
	}

	return result
}

float function GetArcFlashRangeSqr( entity player )
{
	float range = GetArcFlashRange( player )
	return range * range
}

void function OnWeaponOwnerChanged_ability_conduit_arc_flash( entity weapon, WeaponOwnerChangedParams changeParams )
{
#if CLIENT
	if ( weapon.GetOwner() == GetLocalClientPlayer() )
#endif // CLIENT
	{
		array<entity> allyList
		file.trackedAllys[ weapon.GetOwner() ] <- allyList
		if ( IsValid( changeParams.oldOwner ) )
		{
			 changeParams.oldOwner.Signal("TargetingStop")
		}

		if ( IsValid( changeParams.newOwner ) )
		{
			//Assert( weapon.IsValid(), "Player receiving \"mp_ability_conduit_arc_flash\" but weapon is invalid" )
			#if SERVER
			thread TargetingThread( weapon, changeParams.newOwner )
			#endif
			#if CLIENT
			thread TargetingHUD_Thread( changeParams.newOwner )
			#endif
		}
	}

}

bool function OnWeaponAttemptOffhandSwitch_ability_conduit_arc_flash( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return false

	return true
}

void function OnWeaponActivate_ability_conduit_arc_flash( entity weapon )
{
	#if SERVER
		entity player = weapon.GetOwner()
		if ( IsValid( player ) )
		{
			file.shouldConsumeAmmoOnDeactivate[ player ] <- false

			thread CheckTarget_thread( player, weapon )
		}
	#endif
}

void function OnWeaponDeactivate_ability_conduit_arc_flash( entity weapon )
{
#if SERVER
	entity player = weapon.GetOwner()
	if ( IsValid( weapon.GetOwner() ) )
	{
		if ( file.shouldConsumeAmmoOnDeactivate[ player ] )
		{
			//Didnt use ammo!
			//printt( "Arc flash exited before using ammo!")
			PlayerUsedOffhand( weapon.GetOwner(), weapon )
			int newAmmo = maxint( weapon.GetWeaponPrimaryClipCount() - weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire ), 0 )
			weapon.SetWeaponPrimaryClipCount( newAmmo )
		}
		else
		{
			//printt( "Arc flash used ammo")
		}
	}
	#endif

}

void function OnWeaponReadyToFire_ability_conduit_arc_flash( entity weapon )
{
	#if SERVER
	if( weapon.GetWeaponActivity() != ACT_VM_DRAW )
		return

	entity player = weapon.GetOwner()
	if ( IsValid( player ) )
	{
		file.shouldConsumeAmmoOnDeactivate[ player ] <- true
		thread DoSelfCast( player, 0.0 )
	}
	#endif
}


#if SERVER
void function CheckTarget_thread( entity player , entity weapon )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )

	EndSignal( player, "ArcFlashCompleted" )

	EndSignal( weapon, "OnDestroy" )

	weapon.SetWeaponChargeFraction( 0.0 )
	OnThreadEnd(
		function() : ( weapon )
		{
		}
	)

	float startTime = Time()
	while ( true )
	{
		float timeElapsed = Time() - startTime

		//if ( !player.IsWeaponSlotDisabled( eActiveInventorySlot.altHand ) )
		{
			entity bestTarget   = player.GetPlayerNetEnt( CONDUIT_ARC_FLASH_BEST_TARGET_NETVAR )
			bool hasValidTarget = IsValid( bestTarget )
			if ( hasValidTarget )
			{
				//DebugDrawSphere( bestTarget.GetWorldSpaceCenter(), 30, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), false, 2.0 )
				weapon.SetWeaponChargeFraction( 1.0 )
				return
			}

			if ( timeElapsed >= 4.0  )
			{
				//weapon.Holster()
				return
			}
		}

		WaitFrame()
	}
}


void function DoSelfCast( entity player, float delay )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "BleedOut_OnStartDying" )

	if ( delay > 0.0)
		wait delay

	if ( IsValid(player) )
	{
		//printt("Selfcast test")
		EmitSoundOnEntityExceptToPlayer( player, player, SOUND_ARC_FLASH_LESSER_BEAM_3P )	//Conduit using tac, Lesser
		EmitSoundOnEntityOnlyToPlayer( player, player, SOUND_ARC_FLASH_LESSER_BEAM_1P ) //Conduit hearing it, Lesser
		thread TempshieldRegen_Thread( player, player, ARC_FLASH_REGEN_SELF_MULTIPLIER )
	}

}
#endif

var function OnWeaponPrimaryAttack_ability_conduit_arc_flash( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return true // Need this to prevent the code from firing a projectile.
}


var function OnWeaponPrimaryAttackAnimEvent_ability_conduit_arc_flash( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	#if CLIENT
	if ( weaponOwner != GetLocalClientPlayer() )
		return
	#endif

	weapon.PlayWeaponEffect( FX_TAC_MUZZLE_FLASH, FX_TAC_MUZZLE_FLASH, MUZZLE_ATTACH )

	#if SERVER
		weaponOwner.Signal( "ArcFlashCompleted" )
		file.shouldConsumeAmmoOnDeactivate[ weaponOwner ] <- false
		if ( weaponOwner.IsPlayer() )
		{
			PlayerUsedOffhand( weaponOwner, weapon )
		}

		PlayBattleChatterLineToPlayer( "bc_tactical", weaponOwner, weaponOwner )

		entity bestTarget = weaponOwner.GetPlayerNetEnt( CONDUIT_ARC_FLASH_BEST_TARGET_NETVAR )
		if ( IsValid(bestTarget ) && bestTarget.IsPlayer() )
			PlayBattleChatterLineToPlayer( "bc_tactical", bestTarget, weaponOwner )
		DoArcFlash( weaponOwner, weapon,bestTarget )
	#endif

	return weapon.GetAmmoPerShot()
}

#if SERVER
void function TargetingThread( entity weapon, entity player )
{
	EndSignal( weapon, "TargetingStop" )
	EndSignal( weapon, "OnDestroy" )

	if ( !IsValid( player ) )
		return

	array<entity> allyArray

	while ( true )
	{
		bool tacticalIncludeAlliances = GetCurrentPlaylistVarBool( "conduit_tactical_includes_alliances", true )
		allyArray = GetArrayOfPossibleAlliesForPlayer( player, tacticalIncludeAlliances )

		float bestScore = 0
		entity bestTarget
		foreach ( ally in allyArray )
		{
			float thisScore = ScoreTarget( player, ally )
			if ( thisScore > bestScore )
			{
				bestScore = thisScore
				bestTarget = ally
			}
		}

		player.SetPlayerNetEnt( CONDUIT_ARC_FLASH_BEST_TARGET_NETVAR, bestTarget )

		#if DEVELOPER
			if ( ARC_FLASH_DEBUG )
			{
				DebugScreenInfo( player,  allyArray, bestTarget )
				DebugDrawLockOns( player, allyArray, bestTarget )
			}
		#endif

		WaitFrame()
	}
}
#endif

bool function ConduitRevNerfOn()
{
	return GetCurrentPlaylistVarBool( "conduit_rev_nerf", true )
}

int function IsValidTacTarget( entity user, entity target, bool ignoreFaceWhenClose )
{
	if ( !IsValid( user ) )
		return eLockResult.FAILED_GENERIC

	if ( !IsValid( target ) )
		return eLockResult.FAILED_GENERIC

	if ( !IsFriendlyTeam( user.GetTeam(), target.GetTeam() ) )
		return eLockResult.FAILED_GENERIC

	if ( Bleedout_IsBleedingOut( target ) )
		return eLockResult.FAILED_GENERIC

	if ( target.IsPhaseShifted() )
		return eLockResult.FAILED_GENERIC

	if ( ConduitRevNerfOn() )
	{
		if ( IsInForgedShadows( target ) )
			return eLockResult.FAILED_GENERIC
	}

	if ( GetRespawnStatus( target ) != eRespawnStatus.NONE )
		return eLockResult.FAILED_GENERIC

	float distanceSqr = DistanceSqr( user.GetOrigin(), target.GetOrigin() )
	if ( ignoreFaceWhenClose && distanceSqr < ARC_FLASH_MIN_RANGE_SQR )
		return eLockResult.SUCCESS

	float EFFECTIVE_RANGE_SQR = GetArcFlashRangeSqr( user )
	if ( distanceSqr > EFFECTIVE_RANGE_SQR )
		return eLockResult.FAILED_OUT_OF_RANGE

	// Check facing/LOS
	float minDot = TARGETING_CONE_DOT
	float dot = DotProduct( Normalize( target.GetWorldSpaceCenter() - user.CameraPosition() ), user.GetViewVector() )
	if ( dot < minDot )
		return eLockResult.FAILED_NOT_FACING_ALLY


	return eLockResult.SUCCESS
}

float function ScoreTarget( entity player, entity target )
{
	const float WEIGHT_SHIELD_FRAC = 25
	const float WEIGHT_DIST = 0
	const float WEIGHT_ANGLE = 35

	float score = 0.0
	if ( !IsValid( target ) )
		return score

	// Skip invalid targets
	bool isValidTacTarget = IsValidTacTarget( player, target, true ) == eLockResult.SUCCESS
	if ( !isValidTacTarget )
		return score

	string scoreDebugString = ""

                                  
                                                
                                                             
       

	float shieldFrac = 0
	if( target.GetShieldHealthMax() > 0 )
		shieldFrac = float(target.GetShieldHealth()) / float(target.GetShieldHealthMax())
                                  
                                           
                                                                        
       
	float shieldScore = GraphCapped( shieldFrac, 0.0, 1.0, WEIGHT_SHIELD_FRAC, 0 )
	score += shieldScore
	scoreDebugString += "-shieldScore: " + shieldScore + "\n"

	//range score
	float distanceSqr = DistanceSqr( target.GetOrigin(), player.GetOrigin() )
	float distanceScore = GraphCapped( distanceSqr, ARC_FLASH_MIN_RANGE_SQR, GetArcFlashRangeSqr( player ), WEIGHT_DIST, 0 )
	score += distanceScore
	scoreDebugString += "-distanceScore: " + distanceScore + "\n"

	// Closest to centre
	float dot = DotProduct( Normalize( target.GetWorldSpaceCenter() - player.CameraPosition() ), player.GetViewVector() )
	float coneScore = GraphCapped( dot, TARGETING_CONE_DOT, DOT_5DEGREE, 0, WEIGHT_ANGLE )
	score += coneScore
	scoreDebugString += "-coneScore: " + coneScore + "\n"

                                 
             
                                     

                                                                         
     
	int overshieldAmt = target.GetTempshieldHealth()
      

	scoreDebugString = "Total: " + score + "\n" + scoreDebugString + "\nOvershield: " + overshieldAmt

	if( ARC_FLASH_DEBUG )
	{
		DebugDrawText( target.GetWorldSpaceCenter(), scoreDebugString ,false, 0.1 )
	}

	return score
}


#if SERVER
void function SetPlayerTempshieldAmt( entity player, int value )
{
	if ( !IsValid( player) )
		return

	Assert( value <= MAX_TEMPSHIELD )
	Assert( value >= 0 )

	player.SetTempshieldHealth( value )
}


#if DEVELOPER
void function DEV_ApplyConduitTac( entity player, entity target )
{
	DoArcFlash(player, null, target)
}
#endif

void function DoArcFlash( entity player, entity weapon, entity target )
{
	//Sounds
	if ( IsValid(target) )
	{
		StopSoundOnEntity( player, SOUND_ARC_FLASH_LESSER_BEAM_1P )
		StopSoundOnEntity( player, SOUND_ARC_FLASH_LESSER_BEAM_3P )

		EmitSoundOnEntityExceptToPlayer( player, player, SOUND_ARC_FLASH_BEAM_3P ) //Conduit using tac
		EmitSoundOnEntityOnlyToPlayer( player, player, SOUND_ARC_FLASH_BEAM_1P ) //Conduit hearing it

		if ( target.IsPlayer() )
		{
			EmitSoundOnEntityOnlyToPlayer( target, target, SOUND_ARC_FLASH_RECEIVE_1P ) //Teammate hearing it used on them
			EmitSoundOnEntityExceptToPlayer( target, target, SOUND_ARC_FLASH_RECEIVE_3P ) //Everyone hearing it used on the target
		}
		else
		{
			EmitSoundOnEntity( target, SOUND_ARC_FLASH_RECEIVE_3P ) //Everyone hearing it used on the target
		}
	}
	else
	{
		if ( SOUND_ARC_FLASH_LESSER_BEAM_1P != "" )
		{
			EmitSoundOnEntityExceptToPlayer( player, player, SOUND_ARC_FLASH_LESSER_BEAM_3P )	//Conduit using tac, Lesser
			EmitSoundOnEntityOnlyToPlayer( player, player, SOUND_ARC_FLASH_LESSER_BEAM_1P ) //Conduit hearing it, Lesser
		}
	}

	thread PlayBeamFX_Thread( player, weapon, target )


	if ( IsValid(target) )
	{
		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_CONDUIT_TACTICAL, target, target.GetOrigin(), target.GetTeam(), target )
		thread TempshieldRegen_Thread( player, target )
	}
}

bool function CanTempshieldRegen( entity target, float startTime )
{
	if ( target.IsPhaseShifted() )
		return false

	if ( AreAbilitiesSilenced( target ) )
		return false

	if ( Bleedout_IsBleedingOut( target ) )
		return false

	if ( ConduitRevNerfOn() )
	{
		if ( IsInForgedShadows( target ) )
			return false
	}

                                  
                                                       
              
       

	float timeSinceStart = Time() - startTime
	float timeSinceDamage = Time() - target.GetLastTimeDamaged()
	bool wasRecentlyDamaged = timeSinceDamage < timeSinceStart && timeSinceDamage < ARC_FLASH_REGEN_DAMAGE_DELAY
	if ( wasRecentlyDamaged )
		return false

	return true
}

void function TempshieldRegen_Thread( entity player, entity target , float multiplier = 1.0 )
{
                                  
                                                       
   
                                                                                     
         
   
       

	// need to do this before signals so that the status effect doesn't get removed
	float duration = GetArcFlashDuration( player, eArcFlashState.CHARGE )
	                    
	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) && GetArcFlashState( target ) == eArcFlashState.CHARGE )
	{
		duration = min( duration + StatusEffect_GetTimeRemaining( target, eStatusEffect.shields_repairing ), ARC_FLASH_REGEN_DURATION )
	}
       

	player.EndSignal( "FiringRange_CharacterChanged" )

	Signal( target, "RefreshTempshield" )
	EndSignal( target, "RefreshTempshield" )
	//target.EndSignal( "BleedOut_OnStartDying" )
	EndSignal( target, "OnDeath" )
	EndSignal( target, "OnDestroy" )


	if ( ARC_FLASH_DEBUG )
	{
		printt("Conduit Arc Flash (START): startTime: " + Time() + " endTime: " + (Time() + duration) )
	}

	// Clear existing in case we recast while already active (existing status effect may be endless)
	if ( StatusEffect_HasSeverity( target, eStatusEffect.shields_repairing ) )
	{
		StatusEffect_StopAllOfType( target, eStatusEffect.shields_repairing )
	}
	int statusEffectHandle = StatusEffect_AddTimed( target, eStatusEffect.shields_repairing, ARC_FLASH_REGEN_SEVERITY, duration, 0.0 )

	target.SetPlayerNetBool( TEMPSHIELD_ACTIVE_NETVAR, true )

	OnThreadEnd(
		function() : ( player, target,  statusEffectHandle )
		{
			if ( IsValid( target ) )
			{
				#if DEVELOPER
					DEV_LogArcFlashState( target )
				#endif

				if ( statusEffectHandle != 0 )
					StatusEffect_Stop( target, statusEffectHandle )

				StopSoundOnEntity( target, SOUND_TEMPSHIELD_CHARGE_1P )
				StopSoundOnEntity( target, SOUND_TEMPSHIELD_CHARGE_3P )

				target.SetPlayerNetBool( TEMPSHIELD_ACTIVE_NETVAR, false )
			}
		}
	)

	waitthread TempshieldRegen_RegenPhase_Thread( player, target, duration, multiplier )


	if ( statusEffectHandle != 0 )
		StatusEffect_Stop( target, statusEffectHandle )


	///////////////////////////////////////////////////////////////////
	// Start Steady time
	statusEffectHandle = StatusEffect_AddTimed( target, eStatusEffect.shields_repairing, ARC_FLASH_TEMPSHIELD_SEVERITY, ARC_FLASH_TEMPSHIELD_DURATION, 0.0 )

	#if DEVELOPER
		DEV_LogArcFlashState( target )
	#endif

	float steadyEndTime  = Time() + ARC_FLASH_TEMPSHIELD_DURATION
	float steadyFinishingSoundTime = steadyEndTime - SOUND_TEMPSHIELD_SHIELD_WARNING_DURATION
	while ( Time() <= steadyEndTime )
	{
		if ( Time() >= steadyFinishingSoundTime )
		{
			EmitSoundOnEntityOnlyToPlayer( target, target, SOUND_TEMPSHIELD_SHIELD_WARNING_1P )
			steadyFinishingSoundTime = FLT_MAX;
		}

		int currentTempshield = target.GetTempshieldHealth()

		if ( currentTempshield == 0 )
		{
			if ( statusEffectHandle != 0 )
				StatusEffect_Stop( target, statusEffectHandle )

			target.SetPlayerNetBool( TEMPSHIELD_ACTIVE_NETVAR, false )

			return
		}

		int missingShields   = target.GetShieldHealthMax() - target.GetShieldHealth()
		int newTempshieldAmt = minint( currentTempshield, missingShields )
		SetPlayerTempshieldAmt( target, newTempshieldAmt )

		#if DEVELOPER
		DEV_VerifyTempShieldAmount( target )
		#endif

		WaitFrame()
	}

	if ( statusEffectHandle != 0 )
		StatusEffect_Stop( target, statusEffectHandle )

	#if DEVELOPER
		DEV_LogArcFlashState( target )
	#endif

	// Decay time
	statusEffectHandle = StatusEffect_AddEndless( target, eStatusEffect.shields_repairing, ARC_FLASH_DECAY_SEVERITY )
	while ( true )
	{
		const float DECAY_INTERVAL = 0.1

		int currentTempshield = target.GetTempshieldHealth()
		int currentMissingShields = target.GetShieldHealthMax() - target.GetShieldHealth()
		int newTempshield     = maxint(currentTempshield-ARC_FLASH_DECAY_RATE, 0)
		newTempshield      = minint( newTempshield, currentMissingShields )
		SetPlayerTempshieldAmt( target, newTempshield )
		if ( newTempshield == 0 )
			break

		#if DEVELOPER
			DEV_VerifyTempShieldAmount( target )
		#endif

		wait DECAY_INTERVAL
	}

	// Decay done
	if ( statusEffectHandle != 0 )
		StatusEffect_Stop( target, statusEffectHandle )

	target.SetPlayerNetBool( TEMPSHIELD_ACTIVE_NETVAR, false )

	#if DEVELOPER
		DEV_LogArcFlashState( target )
	#endif
}

void function TempshieldRegen_RegenPhase_Thread( entity player, entity target, float duration, float multiplier )
{
	EndSignal( target, "OnDestroy" )

	// Set up the FX
	int chestAttachID          = target.LookupAttachment( "CHESTFOCUS" )
	int shieldChargeFXID       = GetParticleSystemIndex( FX_TEMPSHIELD_3P )
	entity shieldChargingFXEnt = StartParticleEffectOnEntity_ReturnEntity( target, shieldChargeFXID, FX_PATTACH_POINT_FOLLOW, chestAttachID )
	shieldChargingFXEnt.SetOwner( target )
	shieldChargingFXEnt.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )

	int shieldHitFXID     = GetParticleSystemIndex( FX_TEMPSHIELD_HIT_3P )
	entity shieldHitFXEnt = StartParticleEffectOnEntity_ReturnEntity( target, shieldHitFXID, FX_PATTACH_POINT_FOLLOW, chestAttachID )
	shieldHitFXEnt.SetOwner( target )
	shieldHitFXEnt.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )

	//Play the start regen sounds
	EmitSoundOnEntityOnlyToPlayer( target, target, SOUND_TEMPSHIELD_CHARGE_1P )
	EmitSoundOnEntityExceptToPlayer( target, target, SOUND_TEMPSHIELD_CHARGE_3P ) //Everyone hearing it on the target

	PassByReferenceInt tempShieldsActuallyAdded
	tempShieldsActuallyAdded.value = 0
	OnThreadEnd(
		function() : ( player, target, shieldChargingFXEnt, shieldHitFXEnt, tempShieldsActuallyAdded )
		{
			if ( IsValid( shieldChargingFXEnt ) )
				EffectStop( shieldChargingFXEnt )

			if ( IsValid( shieldHitFXEnt ) )
				EffectStop( shieldHitFXEnt )

			if ( IsValid( player ) )
			{
				if ( tempShieldsActuallyAdded.value > 0 )
				{
					//printt( "Conduit logging stats: tempShields added " + tempShieldsActuallyAdded.value )
					StatsHook_ConduitTempShieldsApplied( player, tempShieldsActuallyAdded.value )
				}
			}

			if ( IsValid( target ) )
			{
				StopSoundOnEntity( target, SOUND_TEMPSHIELD_CHARGE_1P )
				StopSoundOnEntity( target, SOUND_TEMPSHIELD_CHARGE_3P )
				EmitSoundOnEntityOnlyToPlayer( target, target, SOUND_TEMPSHIELD_CHARGE_END_1P )
				EmitSoundOnEntityExceptToPlayer( target, target, SOUND_TEMPSHIELD_CHARGE_END_3P ) //Everyone hears it stop
			}
		}
	)

	float startTime          = Time()
	float endTime            = Time() + duration
	float finishingSoundTime = endTime - SOUND_TEMPSHIELD_CHARGE_FINISHING_DURATION


	float TUNING_ArcFlashRegenPerFrame = GetCurrentPlaylistVarFloat( "conduit_tac_regend_per_frame", ARC_FLASH_REGEN_SHIELD_PER_FRAME )
	float TUNING_ArcFlashRegenInterval = GetCurrentPlaylistVarFloat( "conduit_tac_regend_interval", ARC_FLASH_REGEN_INTERVAL )

	// Setup some variables to help us track how much we are generating.
	int expectedRegenRate        = int(TUNING_ArcFlashRegenPerFrame * multiplier * (1 / TUNING_ArcFlashRegenInterval))
	int totalBaseTempShieldAdded = 0    //This ignores what we "actually" added due to shield capacity limits but tracks what we could have added without limits and ensures we are in line.

	float timeOfLastUpdate    = Time()    //Tracks when the last update occurred so we can see how much time has passed each loop
	float accumValidRegenTime = 0        //Accumulates the time we spend when we "canRegen", we use this to figure out how much we should have generated.

	//int DEV_tempShieldsMadeup = 0

	bool didFinalAdjust = false
	/////////////////////////////
	// REGEN timeframe
	// The intent of this loop is to deliver the appropriate amount of tempshields each frame based on the given rate until the end of the regen phase.
	// We first check if we are eligible to get temp shields and if not wait until the next frame.
	// If we are eligible then we calculate the nominal amount of tempshields to apply but we compare that with what we "should" have applied by this time.
	// To determine what we should have applied, we accumulate "valid" regen time and multiply by the expected rate to get what we should have.
	// If any adjustments need to be made, we make them along the way to be as accurate as possible as the ability can be interrupted.
	// The reason we do this is script wait times are variable. Waiting 0.2s can result in a wait of 0.199s to 0.299s so we cant rely on the timing for a consistent rate.
	while ( Time() <= endTime && !didFinalAdjust )
	{
		if ( Time() >= finishingSoundTime )
		{
			EmitSoundOnEntityOnlyToPlayer( target, target, SOUND_TEMPSHIELD_CHARGE_FINISHING_1P )
			finishingSoundTime = FLT_MAX;
		}

		bool canRegen = CanTempshieldRegen( target, startTime )
		float timeSinceLastUpdate = Time() - timeOfLastUpdate
		timeOfLastUpdate = Time()

		if ( canRegen && timeSinceLastUpdate > 0.0)
		{
			accumValidRegenTime += timeSinceLastUpdate

			float timeSinceStart = Time() - startTime

			int currentTempShieldAmt         = target.GetTempshieldHealth()
			int currentMissingShields        = target.GetShieldHealthMax() - target.GetShieldHealth()
			int baseTempShieldToAddThisFrame = int(TUNING_ArcFlashRegenPerFrame * multiplier)

			/////////////////////////////
			//Verification time

			int expectedAdded = int(accumValidRegenTime * expectedRegenRate)
			int diff          = expectedAdded - (totalBaseTempShieldAdded + baseTempShieldToAddThisFrame)

			// Adjust if we have a difference
			baseTempShieldToAddThisFrame += diff
			//DEV_tempShieldsMadeup += diff //Just for debugging

			totalBaseTempShieldAdded += baseTempShieldToAddThisFrame

			////////////////////////////
			if ( ARC_FLASH_DEBUG )
			{
				printt( "Conduit Arc Flash, timeSinceStart " + timeSinceStart + "\t accumTime " + accumValidRegenTime + "\t updateTime " + timeSinceLastUpdate + " rate " + expectedRegenRate + " expected " + expectedAdded + " actual " + totalBaseTempShieldAdded + " - DeficitAdjust " + diff )//+ " - tempShieldsMadeup " + DEV_tempShieldsMadeup )
			}
			////////////////////////////

			//////////////////////////////////
			// Last update checking
			// Here we do a check to see if this could be our last update
			// We add in a buffer of 0.1s as if we ask to wait 0.2s, we may come back anywhere between 0.19ps..0.299s
			// If this is our last update then do any final fixup with the remaining time and set the condition to exit the loop.
			float timeLeft = endTime - Time()
			const float UPDATE_VARIANCE = 0.1
			if ( timeLeft <= (TUNING_ArcFlashRegenInterval + UPDATE_VARIANCE) )
			{
				//last update
				accumValidRegenTime = accumValidRegenTime + timeLeft
				int expectedFinal    = int(accumValidRegenTime * expectedRegenRate)
				int adjustmentFinal = expectedFinal - totalBaseTempShieldAdded
				baseTempShieldToAddThisFrame += adjustmentFinal
				totalBaseTempShieldAdded += adjustmentFinal
				didFinalAdjust = true
				if ( ARC_FLASH_DEBUG )
					printt( "** Conduit Arc Flash, Final update. accumTime " + accumValidRegenTime + " expectedFinal " + expectedFinal + " adjustmentFinal " + adjustmentFinal )
			}

			int cappedTempShieldToAdd = minint( baseTempShieldToAddThisFrame, MAX_TEMPSHIELD - currentTempShieldAmt )            // Cap based on the max tempshields can hit
			cappedTempShieldToAdd     = minint( cappedTempShieldToAdd, currentMissingShields - currentTempShieldAmt )    // Cap again based on how much shield capacity is left.
			int newTempshieldAmt      = currentTempShieldAmt + cappedTempShieldToAdd

			int tempShieldsActuallyAddedThisFrame = maxint( 0, newTempshieldAmt - currentTempShieldAmt )
			tempShieldsActuallyAdded.value += tempShieldsActuallyAddedThisFrame

			SetPlayerTempshieldAmt( target, newTempshieldAmt )

			#if DEVELOPER
				DEV_VerifyTempShieldAmount( target )
			#endif
		}


		if ( target.IsCloaked( true ) || target.IsPhaseShifted() )
			shieldChargingFXEnt.SetVisibilityFlags( ENTITY_VISIBLE_TO_NOBODY )
		else
			shieldChargingFXEnt.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )

		if ( !canRegen )
			WaitFrame()
		else
			wait TUNING_ArcFlashRegenInterval

	}

	#if DEVELOPER
		if ( ARC_FLASH_DEBUG )
		{
			float timeSinceStart = Time() - startTime
			int expectedAdded    = int(accumValidRegenTime * expectedRegenRate)
			int deficit          = expectedAdded - totalBaseTempShieldAdded
			printt( "Conduit Arc Flash, accumTime " + accumValidRegenTime + " expected " + expectedAdded + " actual " + totalBaseTempShieldAdded + " - Deficit " + deficit )//+ " - tempShieldsMadeup " + DEV_tempShieldsMadeup )
			printt( "Conduit Arc Flash Ending Regen phase at time " + Time() + " actual time regening " + timeSinceStart + ", should be: " + duration + " Player current temp: " + player.GetTempshieldHealth() )

			if ( expectedAdded != totalBaseTempShieldAdded )
			{
				//Warning( "*** Conduit Arc Flash!!!!! expectedAdded (" + expectedAdded + ") != totalBaseTempShieldAdded (" + totalBaseTempShieldAdded + ")" )
				Assert( expectedAdded == totalBaseTempShieldAdded, "Conduit Arc Flash!!!!! expectedAdded (" + expectedAdded + ") != totalBaseTempShieldAdded (" + totalBaseTempShieldAdded + ")" )
			}
		}
		DEV_LogArcFlashState( target )
	#endif
}

                                 
                                                                                     
 
                                                                                
                                                                      
                     
                                                                                                                         
   
                                                                                                                                  
   
       

                                                   

                                      
                                         
                                              
                               
                                 

                                                                                                 
                                                                           
  
                                                                       
  

                         
                                    

                                                                                                                                   

                                                                     
                                                                        
                                                                                                                                          
                                       
                                                                                               

                                                                       
                                                                                                                                  
                                  
                                                                                          

                                                                                            

                                                                                                                                    
                                                                                                                           

                      
                               
             
                                                                                             
   
                                        
                                     

                                   
                                

                           
    
           
                                   
          

                                  
                                                    

                                                           
                                                           
    

                           
    
                                        
     
                                                                             
     
    
   
  

                              
                   
                            
  
                                                         

                 
   
                                                
                                                                   

                                                                   
                                                            
                                                                                  

                                   

                           
    
                                                                            
                                                         
    
   

                                                            
                                                                     
      
                                                                                                 

                  
              
      
                                    
  

                                 
                              

                                                        
                                                        
                                                                                     

                               
                                                 
 
      

#if DEVELOPER
void function DEV_VerifyTempShieldAmount( entity player )
{
	if ( ARC_FLASH_DEBUG )
	{
		int currentTempshield = player.GetTempshieldHealth()
		int totalShields =  currentTempshield + player.GetShieldHealth()
		int arcFlashState = GetArcFlashState( player )
		string arcFlashStateString = sArcFlashStateStrings[ arcFlashState ]
		string prefixString = "Conduit Arc Flash (" + arcFlashStateString + "): "
		//printt( prefixString + "Total shields: " + totalShields + " (Tempshields: " + currentTempshield + " Reg Shields: " + player.GetShieldHealth() )
		if ( totalShields > player.GetShieldHealthMax() )
		{
			Assert( false, prefixString + "generated too much temp shields")
		}
	}
}

void function DEV_LogArcFlashState( entity player )
{
	if ( ARC_FLASH_DEBUG )
	{
		int arcFlashState = GetArcFlashState( player )
		string arcFlashStateString = sArcFlashStateStrings[ arcFlashState ]
		printt( "Conduit Arc Flash State " + arcFlashStateString )
	}
}

#endif

void function PlayBeamFX_Thread( entity player, entity weapon, entity target )
{
	//Arc Beam VFX
	entity beamFXEnt
	entity controlPoint
	if ( IsValid(target) )
	{
		//entity weaponViewModel = weapon.GetWeaponViewmodel()
		//int droneAttachID = weaponViewModel.LookupAttachment( "attach_l_drone_arm_b" )
		//DebugDrawSphere( weaponViewModel.GetAttachmentOrigin( droneAttachID ), 3, int(COLOR_LIGHT_BLUE.x), int(COLOR_LIGHT_BLUE.y), int(COLOR_LIGHT_BLUE.z), false, 2.0 )
		//printt( "weaponView " + weaponViewModel.GetAttachmentOrigin( droneAttachID ) )

		//Beam start using a control point
		controlPoint = CreateEntity( "info_placement_helper" )
		SetTargetName( controlPoint, UniqueString( "arc_flash_cpBeamStart" ) )

		vector beamStartPos = player.EyePosition()//.GetOrigin()
		+ player.GetViewForward() * 9.0
		+ player.GetViewRight() * -7.0
		+ player.GetViewUp() * 5.0
		vector angles = VectorToAngles( player.GetViewForward() )
		//DebugDrawSphere( beamStartPos, 2, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), false, 2.0 )

		controlPoint.SetOrigin( beamStartPos )
		controlPoint.SetAngles( angles )

		DispatchSpawn( controlPoint )
		controlPoint.SetParent( player, "", true )

		/////////////////////////////////////////
		//Beam target attaching to target player.

		//vector beamTargetPos = target.GetOrigin()
		//beamTargetPos = target.GetAttachmentOrigin( targetAttachID )

		int beamFXID       = GetParticleSystemIndex( FX_TAC_BEAM )
		int targetAttachID   = target.LookupAttachment( "CHESTFOCUS" )
		beamFXEnt = StartParticleEffectOnEntity_ReturnEntity( target, beamFXID, FX_PATTACH_POINT_FOLLOW, targetAttachID )
		EffectSetControlPointEntity( beamFXEnt, 1, controlPoint )
	}

	OnThreadEnd(
		function () : ( beamFXEnt, controlPoint)
		{
			if ( IsValid( beamFXEnt ) )
			{
				EffectStop( beamFXEnt )
				beamFXEnt.Destroy()
			}

			if ( IsValid( controlPoint ) )
				controlPoint.Destroy()
		}
	)

	wait 3
}

#endif

int function GetArcFlashState( entity player )
{
	float severity = StatusEffect_GetSeverity( player, eStatusEffect.shields_repairing )

	// Infer state from status effect severity
	int state = eArcFlashState.NONE
	if ( severity >= ARC_FLASH_REGEN_SEVERITY )
		state = eArcFlashState.CHARGE
	else if ( severity > ARC_FLASH_DECAY_SEVERITY )
		state = eArcFlashState.ACTIVE
	else if ( severity > 0 )
		state = eArcFlashState.DECAY

	return state
}

#if CLIENT
//
//    #####  #       ### ####### #     # #######
//   #     # #        #  #       ##    #    #
//   #       #        #  #       # #   #    #
//   #       #        #  #####   #  #  #    #
//   #       #        #  #       #   # #    #
//   #     # #        #  #       #    ##    #
//    #	####  ####### ### ####### #     #    #
//




asset function GetRealShieldIcon( int shieldState )
{
	asset shieldIcon = $""

	switch ( shieldState )
	{
		case eShieldState.FULL:
			shieldIcon = $"rui/hud/character_abilities/conduit_tactical_spotting_1"
			break
		case eShieldState.HIGH:
			shieldIcon = $"rui/hud/character_abilities/conduit_tactical_spotting_4"
			break
		case eShieldState.LOW:
			shieldIcon = $"rui/hud/character_abilities/conduit_tactical_spotting_2"
			break
		case eShieldState.CRITICAL:
			shieldIcon = $"rui/hud/character_abilities/conduit_tactical_spotting_3"
			break
	}

	return shieldIcon
}

void function TargetingHUD_Thread( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "TargetingStop" )

	while ( true )
	{
		array<entity> allyArray = GetArrayOfPossibleAlliesForPlayer( player )

		foreach ( ally in allyArray )
		{
			if ( !file.trackedAllys[player].contains(ally) )
			{
				thread SingleTargetRui_Thread( player, ally )
			}
		}
		WaitFrame()
	}
}

void function SingleTargetRui_Thread(  entity player, entity target )
{
	if ( !IsValid( target ) )
		return

	EndSignal( target, "OnDestroy", "OnDeath" )
	EndSignal( target, "OnModelChanged" )
	EndSignal( player, "TargetingStop" )
	EndSignal( player, "OnDestroy" )

	file.trackedAllys[player].append(target)

	var rui = RuiCreate( $"ui/conduit_simplified_ally_ui.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RuiCalculateDistanceSortKey( player.EyePosition(), target.GetOrigin() ) )
	InitHUDRui( rui )

	RuiSetBool( rui, "isVisible", false )

	RuiKeepSortKeyUpdated( rui, true, "pos" )

	RuiTrackFloat3( rui, "pos", target, RUI_TRACK_POINT_FOLLOW, target.LookupAttachment( "CHESTFOCUS" )  )

	entity tacticalWeapon       = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	RuiTrackFloat( rui, "tacAmmoFrac", tacticalWeapon, RUI_TRACK_WEAPON_CLIP_AMMO_FRACTION )

	RuiTrackFloat( rui, "healTimeRemaining", target, RUI_TRACK_STATUS_EFFECT_TIME_REMAINING, eStatusEffect.shields_repairing )

	int teamMemberIndex = int( max( target.GetTeamMemberIndex(), 0 ) )
	vector teamMemberColor = GetKeyColor( COLORID_MEMBER_COLOR0, teamMemberIndex )
	RuiSetFloat3( rui, "teamMemberColor", SrgbToLinear( teamMemberColor / 255.0 ) )

	target.DoModelChangeScriptCallback( true )
	OnThreadEnd(
		function() : ( rui, target, player)
		{
			RuiDestroyIfAlive( rui )
			if ( IsValid(player) )
				file.trackedAllys[player].removebyvalue(target)

			if ( IsValid( target ) )
			{
				target.DoModelChangeScriptCallback( false )
				target.SetTargetInfoStatusIcon( $"" )
			}
		}
	)

	int shieldState = eShieldState.INVALID
	float shieldFracLast = -1.0
	while ( true )
	{
		/// Passive
		entity passiveTarget = player.GetPlayerNetEnt( CONDUIT_PASSIVE_BEST_TARGET_NETVAR )
		bool isPassiveTarget = IsValid( passiveTarget ) && target == passiveTarget

		int state = GetArcFlashState( target )
		int tacTargetResult = IsValidTacTarget( player, target, false )
		bool isValidTacTarget = tacTargetResult == eLockResult.SUCCESS
		bool isOutOfRange = tacTargetResult == eLockResult.FAILED_OUT_OF_RANGE

		bool isVisible = ( isValidTacTarget || isPassiveTarget ) && IsPlayerInValidTacState( player )
		RuiSetBool( rui, "isVisible", isVisible )

		//////////////////////////////////////
		// Is an enemy obstructing this target
		bool enemyObstructing = false
		const float CONDUIT_TRACE_EXTENTS = 6
		const vector CONDUIT_TRACE_BOUND_MINS = <-CONDUIT_TRACE_EXTENTS, -CONDUIT_TRACE_EXTENTS, -CONDUIT_TRACE_EXTENTS>
		const vector CONDUIT_TRACE_BOUND_MAXS = <CONDUIT_TRACE_EXTENTS, CONDUIT_TRACE_EXTENTS, CONDUIT_TRACE_EXTENTS>
		array<entity> ignoreEnts = [ player, target ]
		TraceResults enemyTrace = TraceHull( player.EyePosition(), target.GetWorldSpaceCenter(), CONDUIT_TRACE_BOUND_MINS, CONDUIT_TRACE_BOUND_MAXS, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE, UP_VECTOR, player )
		if ( enemyTrace.fraction < 1.0 )
		{
			if ( enemyTrace.hitEnt.IsPlayer() && !IsFriendlyTeam( enemyTrace.hitEnt.GetTeam(), player.GetTeam() ) )
			{
				//DebugDrawLine( player.EyePosition(), enemyTrace.endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 0.1 )
				//DebugDrawBox( enemyTrace.endPos, CONDUIT_TRACE_BOUND_MINS, CONDUIT_TRACE_BOUND_MAXS, COLOR_ORANGE, 1, 0.1 )
				enemyObstructing = true
			}
		}
		RuiSetBool( rui, "enemyObstructing", enemyObstructing )
		//////////////////////////////////////


		/// Is this the "best" target
		entity bestTarget = player.GetPlayerNetEnt( CONDUIT_ARC_FLASH_BEST_TARGET_NETVAR )
		bool isBestTarget = IsValid(bestTarget) && target == bestTarget
		RuiSetBool( rui, "isBestTarget", isBestTarget )

		/// Passive charge
		RuiSetBool( rui, "showPassive", isPassiveTarget )
		if ( isPassiveTarget )
		{
			const float MIN_TIME_TO_TRIGGER = 2.0
			float chargeEndTime = player.GetPlayerNetTime( CONDUIT_PASSIVE_CHARGE_END_NETVAR )
			float chargeTimeRemaining = chargeEndTime != -1 ? max( chargeEndTime - Time(), 0.0 ) : MIN_TIME_TO_TRIGGER
			RuiSetFloat( rui, "passiveFill", 1.0 - chargeTimeRemaining / MIN_TIME_TO_TRIGGER )
		}

		/// Real shield state change
		float shieldFrac = GetShieldHealthFrac( target )
		if ( shieldFracLast != shieldFrac )
		{
			shieldFracLast = shieldFrac

			const float SHIELD_FRAC_CRITICAL = 0.2
			const float SHIELD_FRAC_SAFE = 0.6

			if ( shieldFrac <= SHIELD_FRAC_CRITICAL )
				shieldState = eShieldState.CRITICAL
			else if ( shieldFrac <= SHIELD_FRAC_SAFE )
				shieldState = eShieldState.LOW
			else if ( shieldFrac < 1.0 )
				shieldState = eShieldState.HIGH
			else
				shieldState = eShieldState.FULL

			RuiSetAsset( rui, "shieldIcon", GetRealShieldIcon( shieldState ) )
		}

		/// Active state
		if ( target.IsPlayer() && target.GetPlayerNetBool( TEMPSHIELD_ACTIVE_NETVAR ) )
		{
			// Don't update if we're "none" (there are brief periods of time between states where severity is 0)
			if ( state != eArcFlashState.NONE )
			{
				RuiSetInt( rui, "activeState", state )
				RuiSetFloat( rui, "healTimeDuration", GetArcFlashDuration( player, state ) )
			}

			SetUnitFrameOvershieldChargingState( target, state == eArcFlashState.CHARGE )

			if ( !isOutOfRange )
				target.SetTargetInfoStatusIcon( $"rui/hud/character_abilities/conduit_tactical_enemy_shielded" )
			else
				target.SetTargetInfoStatusIcon( $"" )
		}
		else
		{
			RuiSetInt( rui, "activeState", eArcFlashState.NONE )

			SetUnitFrameOvershieldChargingState( target, false )

			if ( !isOutOfRange )
				target.SetTargetInfoStatusIcon( GetRealShieldIcon( shieldState ) )
			else
				target.SetTargetInfoStatusIcon( $"" )
		}


		WaitFrame()
	}
}

bool function IsPlayerInValidTacState( entity player )
{
	if ( Bleedout_IsBleedingOut(player) )
		return false

	if ( player.Player_IsSkydiving() )
		return false

	if ( player.IsDrivingVehicle() )
		return false

	return true
}




void function ArcFlash_StartShieldsRepairing( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	entity viewPlayer = GetLocalViewPlayer()

	thread ArcFlash_ShieldsRepairingThread( viewPlayer )
}

void function ArcFlash_StopShieldsRepairing( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	ent.Signal( "ArcFlash_EndShieldsRepairing" )
}

var function GetConduitShieldRui()
{
	return file.shieldsRepairingRui
}

var function ArcFlash_DestroyFXAfterDelay_Thread( entity player, int fxHandle, float delay )
{
	Assert( IsNewThread(), "Must be threaded" )

	player.EndSignal( "ArcFlash_EndShieldsRepairing" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	wait delay

	if ( EffectDoesExist( fxHandle ) )
		EffectStop( fxHandle, false, true )
}

void function ArcFlash_ShieldsRepairingThread( entity player )
{
	player.EndSignal( "ArcFlash_EndShieldsRepairing" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	int state = GetArcFlashState( player )
	if ( state == eArcFlashState.NONE )
		return

	///////   UI
	if ( file.shieldsRepairingRui == null )
	{
		file.shieldsRepairingRui = CreateCockpitPostFXRui( $"ui/shields_repairing_indicator.rpak", HUD_Z_BASE )
	}

	RuiTrackFloat( file.shieldsRepairingRui, "timeRemaining", player, RUI_TRACK_STATUS_EFFECT_TIME_REMAINING, eStatusEffect.shields_repairing )

	////// FX
	int fxHandle = -1
	if ( state == eArcFlashState.CHARGE )
	{
		int fxID = GetParticleSystemIndex( FX_TEMPSHIELD_1P )
		entity cockpit = player.GetCockpit()
		if ( !IsValid(cockpit) )
			return
		fxHandle = StartParticleEffectOnEntity( cockpit, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
		EffectSetIsWithCockpit( fxHandle, true )
		EffectSetControlPointVector( fxHandle, 1, TEMPSHIELD_COLOR )
	}

	OnThreadEnd(
		function() : ( player, fxHandle, state )
		{
			if ( IsValid(player) )
			{
				SetCustomPlayerInfoOvershieldChargingState( player, false )
			}

			RuiDestroyIfAlive( file.shieldsRepairingRui )
			file.shieldsRepairingRui = null

			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )

			if ( state == eArcFlashState.DECAY && !player.GetPlayerNetBool( TEMPSHIELD_ACTIVE_NETVAR ) )
				AddPlayerHint( 4.0, 0.5, $"", "#HINT_CONDUIT_SHIELDS_DEPLETED" )
		}
	)

	// FX & sound don't last the entire duration of the charge
	thread ArcFlash_DestroyFXAfterDelay_Thread( player, fxHandle, SOUND_TEMPSHIELD_CHARGE_FINISHING_DURATION )

	// Some things need to get updated every frame because state may change without the RUI getting destroyed/recreated
	while ( true )
	{
		RuiSetInt( file.shieldsRepairingRui, "state", state )
		RuiSetFloat( file.shieldsRepairingRui, "timeTotal", GetArcFlashDuration( player, state ) )

		SetCustomPlayerInfoOvershieldChargingState( player, state == eArcFlashState.CHARGE )

		WaitFrame()
		state = GetArcFlashState( player )
	}
}

#endif // CLIENT

#if DEVELOPER
void function DebugScreenInfo( entity player, array<entity> allyList, entity bestTarget )
{
	//DebugDrawScreenTextWithColor
	//void DebugDrawScreenTextWithColor( float posX, float posY, string text, vector rgb )
	vector color = <0, 100, 200>
	string text  = "Conduit:"

	//State
	text += "\n# Allys: " + allyList.len()

	text += "\nBestTarget:" + bestTarget

	DebugDrawScreenTextWithColor( 0.7, 0.8, text, color )
}

void function DebugDrawLockOns( entity player, array<entity> allyList, entity bestTarget )
{
	if ( !IsValid(player) )
		return


	foreach( target in allyList )
	{
		if( IsValid(target) )
		{
			DebugDrawSphere( target.GetWorldSpaceCenter(), 15, int(COLOR_CYAN.x), int(COLOR_CYAN.y), int(COLOR_CYAN.z), true, 0.1 )
			float thisLockScore = ScoreTarget( player, target )
			if ( target == bestTarget )
			{
				DebugDrawText( target.EyePosition(), "BEST", false, 0.1 )
			}
		}
	}
}
#endif