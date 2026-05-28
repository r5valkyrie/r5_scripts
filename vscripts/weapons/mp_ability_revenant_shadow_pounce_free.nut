global function MpAbilityShadowPounceFree_Init
global function OnWeaponDeactivate_shadow_pounce_free
global function OnWeaponTossPrep_shadow_pounce_free
global function OnWeaponTossCancel_shadow_pounce_free
global function OnWeaponToss_shadow_pounce_free
global function OnWeaponTossReleaseAnimEvent_shadow_pounce_free
global function OnWeaponAttemptOffhandSwitch_shadow_pounce_free
global function OnWeaponOwnerChanged_shadow_pounce_free

////////////////////////////////////////////////

// Sound
// 1P
const string SHADOW_POUNCE_CHARGE_PREP_SOUND_1P = "Revenant_Pounce_Windup_1P"
const string SHADOW_POUNCE_LAUNCH_SOUND_1P = "revenant_pounce_launch_1p"
const string SHADOW_POUNCE_CANCEL_SOUND_1P = "Revenant_Pounce_Cancel_1P"
const string SHADOW_POUNCE_FULL_CHARGE_SOUND_1P = "Revenant_Pounce_FullyCharged_1P"

// 3P
const string SHADOW_POUNCE_CHARGE_PREP_SOUND_3P = "Revenant_Pounce_Windup_3P"
const string SHADOW_POUNCE_LAUNCH_SOUND_3P = "revenant_pounce_launch_3p"
const string SHADOW_POUNCE_AIR_MOVEMENT_SOUND_3P = "Revenant_Pounce_AirborneMvmt_3p"
const string SHADOW_POUNCE_CANCEL_SOUND_3P = "Revenant_Pounce_Cancel_3P"

// FX
// 1P
const asset SHADOW_POUNCE_CHARGE_START_FX_1P = $"P_rev_reborn_FP_tac_charge_hands"
const asset SHADOW_POUNCE_CHARGE_START_ARM_FX_1P = $"P_rev_reborn_FP_tac_charge_arms"
const asset SHADOW_POUNCE_CHARGE_FULL_FX_1P = $"P_rev_reborn_FP_tac_full_charge"
const asset SHADOW_POUNCE_CHARGE_IDLE_FX_1P = $"P_rev_reborn_FP_tac_Idle_hands"
const asset SHADOW_POUNCE_LAUNCH_FX_1P = $"P_rev_reborn_FP_tac_activation_hands"

// 3P
const asset SHADOW_POUNCE_CHARGE_FX_3P = $"P_rev_reborn_3p_tac_charge_hands"
const asset SHADOW_POUNCE_LAUNCH_FX_3P = $"P_rev_reborn_3p_tac_activation_hands"
const asset SHADOW_POUNCE_LAUNCH_BURST_FX_3P = $"P_rev_reborn_3p_tac_activate_jump"
const asset SHADOW_POUNCE_TRAIL_FX_3P = $"P_rev_tac_jump_3P_body_trail"

// IMPACT TABLE
const string SHADOW_POUNCE_LAUNCH_IMPACT_FX_TABLE = "shadow_pounce_launch"

// Strings
const string SHADOW_POUNCE_END_CHARGE_SIGNAL = "shadow_pounce_end_charge"
const string SHADOW_POUNCE_TARGET_INDICATOR_MOD = "shadow_pounce_target_indicator"

// Tuning
// Pounce targeting modifiers
const int MAX_IDEAL_UP_ANGLE = -15 // Max upward pitch before you start losing Velocity
const int MAX_DOWN_ANGLE = 75 // Max downward pitch you're allowed to target
const int GROUND_CHECK_START_ANGLE = 20
const int GROUND_CHECK_ANGLE_ADJUSTMENT = 15
const float GROUND_CHECK_TRACE_DIST = 200.0
const int MAX_VERTICAL_PITCH_ANGLE = -80 // Max upward angle before maximum Velocity reduction is applied
const int MAX_EYE_ANGLE_INCREASE = 35 // Angle modifier to make pounce feel more like an arc
const int VELOCITY_MULTIPLIER_MIN = 700
const int VELOCITY_MULTIPLIER_MAX = 1150
const float HIGH_ANGLE_VELOCITY_DIVISOR_MAX = 1.5

const float SHADOW_POUNCE_MAX_HOLD_TIME = 1.3
const vector SHADOW_POUNCE_VIEWPUNCH = < 35, -35, 5 >
const float MAX_FOV_LERP_OFFSET = -7.0
const float MAX_CODE_FOV = 115.0 // defined in code
const float SHADOW_POUNCE_WALL_CLIMB_DISABLE_DURATION = 0.75
const float SHADOW_POUNCE_WEAPON_STOW_MIN = 0.2
const int SHADOW_POUNCE_WALL_CLIMB_ONLY_FROM_WALL = 0
const int SHADOW_POUNCE_TARGET_INDICATOR = 0
const int SHADOW_POUNCE_CHARGE_UI = 0

const int SHADOW_POUNCE_DISABLE_WEAPON_TYPES = WPT_ALL_EXCEPT_VIEWHANDS_OR_INCAP & ~WPT_TACTICAL

struct
{
	table< entity, string> cachedLastWeaponName
	table< entity, float > chargePercentage
	table< entity, int > disableWallRunHandle
	table< entity, float > weaponStowTime

	#if CLIENT
		int pounceTargetFXHandle
		int pounceDamageRadiusFXHandle
	#endif

	// Live Tuning
	float maxChargeTime
	float wallClimbDisableDuration
	float weaponStowMinTime
	bool shadowPounce_TargetIndicator
	bool shadowPounce_ChargeUI
	bool wallClimbOnlyFromWall

	int maxIdealPitchAngle
	int maxVerticalPitchAngle
	int maxDownAngle
	int groundCheckStartAngle
	int groundCheckAngleAdjustment
	float groundCheckTraceDist
	int maxEyeAngleIncrease
	int minVelocityMultiplier
	int maxVelocityMultiplier
	float maxHighAngleVelocityDivisor
	float maxFovOffset
} file

global const string  REVENANT_SHADOW_POUNCE_FREE_WEAPON_NAME = "mp_ability_revenant_shadow_pounce_free"

void function MpAbilityShadowPounceFree_Init()
{
	PrecacheParticleSystem( SHADOW_POUNCE_CHARGE_START_FX_1P )
	PrecacheParticleSystem( SHADOW_POUNCE_CHARGE_START_ARM_FX_1P )
	PrecacheParticleSystem( SHADOW_POUNCE_CHARGE_FULL_FX_1P )
	PrecacheParticleSystem( SHADOW_POUNCE_CHARGE_IDLE_FX_1P )
	PrecacheParticleSystem( SHADOW_POUNCE_LAUNCH_FX_1P )
	PrecacheParticleSystem( SHADOW_POUNCE_CHARGE_FX_3P )
	PrecacheParticleSystem( SHADOW_POUNCE_LAUNCH_FX_3P )
	PrecacheParticleSystem( SHADOW_POUNCE_LAUNCH_BURST_FX_3P )
	PrecacheParticleSystem( SHADOW_POUNCE_TRAIL_FX_3P )

	PrecacheImpactEffectTable( SHADOW_POUNCE_LAUNCH_IMPACT_FX_TABLE )

	RegisterSignal( SHADOW_POUNCE_END_CHARGE_SIGNAL )

	// Live Tuning
	file.maxChargeTime = GetCurrentPlaylistVarFloat( "shadow_pounce_max_charge_time", SHADOW_POUNCE_MAX_HOLD_TIME )
	file.wallClimbDisableDuration = GetCurrentPlaylistVarFloat( "shadow_pounce_wall_climb_disable_duration", SHADOW_POUNCE_WALL_CLIMB_DISABLE_DURATION )
	file.weaponStowMinTime = GetCurrentPlaylistVarFloat( "shadow_pounce_weapon_stow_time", SHADOW_POUNCE_WEAPON_STOW_MIN )
	file.shadowPounce_TargetIndicator = ( GetCurrentPlaylistVarInt( "shadow_pounce_target_indicator", SHADOW_POUNCE_TARGET_INDICATOR ) > 0 )
	file.shadowPounce_ChargeUI = ( GetCurrentPlaylistVarInt( "shadow_pounce_charge_ui", SHADOW_POUNCE_CHARGE_UI ) > 0 )
	file.wallClimbOnlyFromWall = ( GetCurrentPlaylistVarInt( "shadow_pounce_wall_climb_from_wall", SHADOW_POUNCE_WALL_CLIMB_ONLY_FROM_WALL ) > 0 )

	file.maxIdealPitchAngle = GetCurrentPlaylistVarInt( "shadow_pounce_max_ideal_pitch_angle", MAX_IDEAL_UP_ANGLE )
	file.maxVerticalPitchAngle = GetCurrentPlaylistVarInt( "shadow_pounce_max_vertical_pitch_angle", MAX_VERTICAL_PITCH_ANGLE )
	file.maxDownAngle = GetCurrentPlaylistVarInt( "shadow_pounce_max_down_angle", MAX_DOWN_ANGLE )
	file.groundCheckStartAngle = GetCurrentPlaylistVarInt( "shadow_pounce_ground_check_start_angle", GROUND_CHECK_START_ANGLE )
	file.groundCheckAngleAdjustment = GetCurrentPlaylistVarInt( "shadow_pounce_ground_check_angle_adjustment", GROUND_CHECK_ANGLE_ADJUSTMENT )
	file.groundCheckTraceDist = GetCurrentPlaylistVarFloat( "shadow_pounce_ground_trace_dist", GROUND_CHECK_TRACE_DIST )
	file.maxEyeAngleIncrease = GetCurrentPlaylistVarInt( "shadow_pounce_max_eye_angle_increase", MAX_EYE_ANGLE_INCREASE )
	file.minVelocityMultiplier = GetCurrentPlaylistVarInt( "shadow_pounce_min_velocity_mod", VELOCITY_MULTIPLIER_MIN )
	file.maxVelocityMultiplier = GetCurrentPlaylistVarInt( "shadow_pounce_max_velocity_mod", VELOCITY_MULTIPLIER_MAX )
	file.maxHighAngleVelocityDivisor = GetCurrentPlaylistVarFloat( "shadow_pounce_max_high_angle_velocity_divisor", HIGH_ANGLE_VELOCITY_DIVISOR_MAX )
	file.maxFovOffset                = GetCurrentPlaylistVarFloat( "shadow_pounce_max_fov_offset", MAX_FOV_LERP_OFFSET )
}

bool function OnWeaponAttemptOffhandSwitch_shadow_pounce_free( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return false
	if( HoverVehicle_IsPlayerInAnyVehicle( player ) )
	{
		weapon.DoDryfire()
		return false
	}

	weapon.w.fromWall = player.IsWallRunning()

	entity mainHandWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( mainHandWeapon) )
	{
		if ( !IsBitFlagSet( mainHandWeapon.GetWeaponTypeFlags(), WPT_TACTICAL ) )
			file.cachedLastWeaponName[player] <- mainHandWeapon.GetWeaponClassName()
	}

	return true
}

void function OnWeaponDeactivate_shadow_pounce_free( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( IsValid( weaponOwner ) )
	{
		weaponOwner.Signal( SHADOW_POUNCE_END_CHARGE_SIGNAL )
	}
	#if CLIENT
		if ( !(InPrediction() && weapon.ShouldPredictProjectiles()) )
			return
	#endif

	if( !weapon.w.wasFired )
		ClearWallClimbStatusEffect( weaponOwner )
}

void function OnWeaponOwnerChanged_shadow_pounce_free( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if SERVER
		if( file.shadowPounce_TargetIndicator )
		{
			if( !weapon.HasMod( SHADOW_POUNCE_TARGET_INDICATOR_MOD ) )
			{
				weapon.AddMod( SHADOW_POUNCE_TARGET_INDICATOR_MOD )
			}
		}
		else
		{
			if( weapon.HasMod( SHADOW_POUNCE_TARGET_INDICATOR_MOD ) )
			{
				weapon.RemoveMod( SHADOW_POUNCE_TARGET_INDICATOR_MOD )
			}
		}
	#endif
}

void function OnWeaponTossPrep_shadow_pounce_free( entity weapon, WeaponTossPrepParams prepParams )
{
	entity player = weapon.GetWeaponOwner()
	Assert( player.IsPlayer() )

	#if CLIENT
		if ( !(InPrediction() && weapon.ShouldPredictProjectiles()) )
			return
	#endif

	player.Signal( SHADOW_POUNCE_END_CHARGE_SIGNAL )
	weapon.w.wasFired = false
	ClearWallClimbStatusEffect( player )

	weapon.w.startChargeTime = Time() + weapon.GetWeaponSettingFloat( eWeaponVar.toss_pullout_time )
	if( !file.wallClimbOnlyFromWall || weapon.w.fromWall )
	{
		if( player in file.disableWallRunHandle )
		{
			StatusEffect_Stop( player, file.disableWallRunHandle[player] )
			file.disableWallRunHandle[player] = StatusEffect_AddEndless( player, eStatusEffect.disable_wall_run, 1.0 )
		}
		else
			file.disableWallRunHandle[player] <- StatusEffect_AddEndless( player, eStatusEffect.disable_wall_run, 1.0 )
	}

	#if SERVER
		thread ShadowPounce_ChargeFX_Thread( player, weapon )
	#endif

	#if CLIENT
		if( file.shadowPounce_ChargeUI )
			thread ShadowPounce_ChargeUI_Thread( player, weapon )
		if( file.shadowPounce_TargetIndicator )
			thread ShadowPounce_UpdateIndicator( player, weapon )
		if( file.maxFovOffset != 0.0 )
			thread ShadowPounce_ChargeFov_Thread( player, weapon )
	#endif
}

var function OnWeaponTossCancel_shadow_pounce_free( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
		entity player = weapon.GetOwner()

		if( !IsValid( player ) )
			return

		ShadowPounce_Cleanup( player, weapon )
	#endif

	return 0
}

var function OnWeaponToss_shadow_pounce_free( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()

	float maxChargeTime = ShadowPounce_GetMaxChargeTime( player )
	if( player in file.chargePercentage )
		file.chargePercentage[player] = Clamp( (Time() - weapon.w.startChargeTime ) / maxChargeTime, 0.0, 1.0 )
	else
		file.chargePercentage[player] <- Clamp( (Time() - weapon.w.startChargeTime ) / maxChargeTime, 0.0, 1.0 )

	player.Signal( SHADOW_POUNCE_END_CHARGE_SIGNAL )
}

var function OnWeaponTossReleaseAnimEvent_shadow_pounce_free( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()

	#if CLIENT
		if ( !(InPrediction() && weapon.ShouldPredictProjectiles()) )
			return 0
	#endif

	player.Signal( SHADOW_POUNCE_END_CHARGE_SIGNAL )
	thread ClearWallClimbStatusEffectAfterDelay_Thread( player )

	ShadowPounce_LaunchPlayer( player, weapon.w.startChargeTime  )
	weapon.w.wasFired = true

	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( weapon.GetOwner(), "bc_tactical" )
		player.Zipline_Stop()
		player.ClearTraverse()
		player.DisableWeaponTypes( SHADOW_POUNCE_DISABLE_WEAPON_TYPES )
		RemoveDoubleJump ( player )

		if( player in file.weaponStowTime )
			file.weaponStowTime[player] = Time()
		else
			file.weaponStowTime[player] <- Time()

		thread ShadowPounce_Server_Thread( player, weapon )
	#endif

	PlayerUsedOffhand( player, weapon )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

                    
float function ShadowPounce_UpgradedChargeTimeScaler()
{
	return GetCurrentPlaylistVarFloat( "shadow_pounce_max_charge_time_upgraded_scaler", .8 )
}
      

float function ShadowPounce_GetMaxChargeTime( entity player )
{
	float result = file.maxChargeTime

	                    
	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) )
	{
		result *= ShadowPounce_UpgradedChargeTimeScaler()
	}
       

	return result
}

void function ShadowPounce_LaunchPlayer( entity player, float startTime )
{
	if( !IsValid( player ) )
		return

	vector launchVelocity = ShadowPounce_CalcLaunchVelocity( player, startTime )
	player.PlayerLaunch( launchVelocity, true )

	#if SERVER
		player.ViewPunch( player.GetCenter(), SHADOW_POUNCE_VIEWPUNCH.x, SHADOW_POUNCE_VIEWPUNCH.y, SHADOW_POUNCE_VIEWPUNCH.z )
		EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_POUNCE_LAUNCH_SOUND_3P )
	#endif
	
	#if CLIENT
		EmitSoundOnEntity( player, SHADOW_POUNCE_LAUNCH_SOUND_1P )
	#endif
}

vector function ShadowPounce_CalcLaunchVelocity( entity player, float startTime )
{
	vector launchVelocity = ZERO_VECTOR
	if( !IsValid( player ) )
		return launchVelocity

	// Calculate launch angle based on eye angles
	vector eyeAngles = player.EyeAngles()
	float pitch = eyeAngles.x

	vector modifiedEyeAngles = eyeAngles

	// Ground check when looking down
	if( pitch >= file.groundCheckStartAngle )
	{
		vector traceEnd   = player.EyePosition() + ( AnglesToForward( eyeAngles ) * file.groundCheckTraceDist )
		TraceResults groundTrace = TraceLine( player.EyePosition(), traceEnd, player, TRACE_MASK_SOLID )

		if( IsValid( groundTrace.hitEnt ) )
			pitch = float( file.groundCheckAngleAdjustment )
	}
	// Ideal pounce angles
	if( pitch == clamp( pitch, file.maxIdealPitchAngle, file.maxDownAngle ) )
	{
		float modifiedPitch = pitch - file.maxEyeAngleIncrease // Modify pitch to make it feel more like a hop
		modifiedEyeAngles = < modifiedPitch, eyeAngles.y, eyeAngles.z >
	}
	// High pounce angles
	else if( pitch < file.maxIdealPitchAngle )
	{
		float modifiedPitch = pitch - GraphCapped( pitch, file.maxIdealPitchAngle, file.maxVerticalPitchAngle, file.maxEyeAngleIncrease, 0 )
		modifiedEyeAngles = < modifiedPitch, eyeAngles.y, eyeAngles.z >
	}

	float chargePercentage = 0.0
	if( player in file.chargePercentage )
		chargePercentage = file.chargePercentage[player]

	float velocity = file.minVelocityMultiplier + ( ( file.maxVelocityMultiplier - file.minVelocityMultiplier ) * chargePercentage ) // Find the charge % difference between min and max charge

	//Reduce velocity the more you look up
	float modifiedVelocity = velocity
	if( file.maxIdealPitchAngle >= pitch )
	{
		modifiedVelocity = velocity / GraphCapped( pitch, file.maxIdealPitchAngle, file.maxVerticalPitchAngle, 1.0, file.maxHighAngleVelocityDivisor )
	}

	launchVelocity = AnglesToForward( modifiedEyeAngles ) * modifiedVelocity

	return launchVelocity
}

void function ClearWallClimbStatusEffect( entity player )
{
	if( !IsValid( player ) )
		return

	player.Signal( SHADOW_POUNCE_END_CHARGE_SIGNAL )
	if( player in file.disableWallRunHandle )
	{
		StatusEffect_Stop( player, file.disableWallRunHandle[player] )
		delete file.disableWallRunHandle[player]
	}
}

void function ClearWallClimbStatusEffectAfterDelay_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying" )

	OnThreadEnd(
		function() : ( player )
		{
			#if SERVER
				ClearWallClimbStatusEffect( player )
			#endif
		}
	)

	wait file.wallClimbDisableDuration
}

#if SERVER
void function ShadowPounce_Server_Thread( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if( !IsValid( player ) )
		return

	entity viewModelEntity = player.GetViewModelEntity()
	if ( !IsValid( viewModelEntity ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying" )

	vector startPos = player.GetOrigin()
	vector endPos = player.GetOrigin()
	array <entity> shadowPounceLaunchFx

	OnThreadEnd(
		function() : ( player, weapon, shadowPounceLaunchFx )
		{
			if ( IsValid(player) )
			{
				ShadowPounce_DeployAndEnableWeapons( player )
				ClearWallClimbStatusEffect( player )
				ShadowPounce_Cleanup( player, weapon )
				StopSoundOnEntity( player, SHADOW_POUNCE_AIR_MOVEMENT_SOUND_3P )
				TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_REVENANT_POUNCE_LAND, player, player.GetOrigin(), player.GetTeam(), player )
			}

			foreach( fx in shadowPounceLaunchFx )
			{
				if ( IsValid( fx ) )
				{
					EffectStop( fx )
					fx.Destroy()
				}
			}

			if( IsValid( weapon ) )
				weapon.SetNextAttackAllowedTime( Time() )
		}
	)

	//Impact FX
	PlayImpactFXTable( player.GetOrigin(), player, SHADOW_POUNCE_LAUNCH_IMPACT_FX_TABLE )

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_REVENANT_POUNCE_START, player, player.GetOrigin(), player.GetTeam(), player )

	// Launch FX
	int leftHandAttachID_1P  = viewModelEntity.LookupAttachment( "L_HAND" )
	int rightHandAttachID_1P = viewModelEntity.LookupAttachment( "R_HAND" )
	int leftHandAttachID_3P = player.LookupAttachment( "L_HAND" )
	int rightHandAttachID_3P = player.LookupAttachment( "R_HAND" )
	int chestFocusAttachID_3P = player.LookupAttachment( "CHESTFOCUS" )

	array <entity> fxLaunch1P
	fxLaunch1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_LAUNCH_FX_1P ), FX_PATTACH_POINT_FOLLOW, leftHandAttachID_1P ) )
	fxLaunch1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_LAUNCH_FX_1P ), FX_PATTACH_POINT_FOLLOW, rightHandAttachID_1P ) )
	foreach( fx in fxLaunch1P )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_OWNER )
	}
	shadowPounceLaunchFx.extend( fxLaunch1P )

	array <entity> fxHandLaunch3P
	fxHandLaunch3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_POUNCE_LAUNCH_FX_3P ), FX_PATTACH_POINT_FOLLOW, leftHandAttachID_3P ) )
	fxHandLaunch3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_POUNCE_LAUNCH_FX_3P ), FX_PATTACH_POINT_FOLLOW, rightHandAttachID_3P ) )
	foreach( fx in fxHandLaunch3P )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )
	}
	shadowPounceLaunchFx.extend( fxHandLaunch3P )

	// VFX Launch Burst and Trail
	array <entity> fxLaunch3P
	fxLaunch3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_POUNCE_LAUNCH_BURST_FX_3P ), FX_PATTACH_POINT_FOLLOW, chestFocusAttachID_3P ) )
	fxLaunch3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_POUNCE_TRAIL_FX_3P ), FX_PATTACH_POINT_FOLLOW, chestFocusAttachID_3P ) )
	foreach( fx in fxLaunch3P )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )
		CopyRealmsFromTo( player, fx )
	}
	shadowPounceLaunchFx.extend( fxLaunch3P )

	if( player.IsOnGround() )
		WaitFrame()

	EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_POUNCE_AIR_MOVEMENT_SOUND_3P )

	while ( ShadowPounce_ShouldPounce( player ) )
	{
		endPos = player.GetOrigin()
		WaitFrame()
	}

	int distanceTravelled = int(Distance( startPos, endPos) * INCHES_TO_METERS )
	StatsHook_RevenantTacticalDistance( player, distanceTravelled )
}

bool function ShadowPounce_ShouldPounce( entity player )
{
	// Instant cancel
	//if( player.IsSlipping() || player.IsZiplining() ||  player.e.isInWarpTrigger )
	//	return false

	// Cancel after threshold
	if( player in file.weaponStowTime )
	{
		if( Time() - file.weaponStowTime[player] > file.weaponStowMinTime )
		{
			if( player.IsOnGround() || player.IsSliding() )
				return false
		}
	}

	return true
}

void function ShadowPounce_DeployAndEnableWeapons( entity player )
{
	if ( !IsValid( player ) )
		return

	player.EnableWeaponTypes( SHADOW_POUNCE_DISABLE_WEAPON_TYPES )

	if ( player in file.cachedLastWeaponName )
	{
		string weaponName = file.cachedLastWeaponName[player]

		//R5DEV-369697 - TNordin - I still can't repro this locally, but there's enough videos that I believe it can happen.
		//I believe the issue is that code thinks we already have an offhand active (Vantage tac) and so trying to equip mp_ability_consumable (also offhand) throws an assert.
		//Declan wrote a helper function to solve this back when Crypto could heal while in drone view (what??) and its still in mp_ability_consumable, so using it here to help solve.
		if ( weaponName == CONSUMABLE_WEAPON_NAME )
			TryTriggerConsumableUse( player )
		else
			player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, file.cachedLastWeaponName[player] )
	}
	else
	{
		player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	}
}

void function ShadowPounce_ChargeFX_Thread( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off" )
	if( !IsValid( player ) )
		return
	entity viewModelEntity = player.GetViewModelEntity()
	if( !IsValid( viewModelEntity ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", SHADOW_POUNCE_END_CHARGE_SIGNAL )

	int leftHandAttachID_1P = viewModelEntity.LookupAttachment( "L_HAND" )
	int rightHandAttachID_1P = viewModelEntity.LookupAttachment( "R_HAND" )
	int leftHandAttachID_3P = player.LookupAttachment( "L_HAND" )
	int rightHandAttachID_3P = player.LookupAttachment( "R_HAND" )
	array <entity> shadowPounceChargeFx

	// Charge Start
	EmitSoundOnEntityOnlyToPlayer(player, player, SHADOW_POUNCE_CHARGE_PREP_SOUND_1P  )
	EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_POUNCE_CHARGE_PREP_SOUND_3P )

	array <entity> fxHandCharge1P
	fxHandCharge1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_START_FX_1P ), FX_PATTACH_POINT_FOLLOW, leftHandAttachID_1P ) )
	fxHandCharge1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_START_FX_1P ), FX_PATTACH_POINT_FOLLOW, rightHandAttachID_1P ) )
	foreach( fx in fxHandCharge1P )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_OWNER )
	}
	shadowPounceChargeFx.extend( fxHandCharge1P )

	array <entity> fxHandCharge3P
	fxHandCharge3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_FX_3P ), FX_PATTACH_POINT_FOLLOW, leftHandAttachID_3P ) )
	fxHandCharge3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_FX_3P ), FX_PATTACH_POINT_FOLLOW, rightHandAttachID_3P ) )
	foreach( fx in fxHandCharge3P )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER )
	}
	shadowPounceChargeFx.extend( fxHandCharge3P )

	OnThreadEnd( function() : ( player, shadowPounceChargeFx ) {
		if ( IsValid( player ) )
		{
			StopSoundOnEntity( player, SHADOW_POUNCE_CHARGE_PREP_SOUND_1P )
			StopSoundOnEntity( player, SHADOW_POUNCE_CHARGE_PREP_SOUND_3P )
		}

		foreach( fx in shadowPounceChargeFx )
		{
			if ( IsValid( fx ) )
			{
				EffectStop( fx )
				fx.Destroy()
			}
		}
	} )

	// Full Charge
	while( true)
	{
		float maxChargeTime = ShadowPounce_GetMaxChargeTime( player )
		float chargeTime = clamp( Time() - weapon.w.startChargeTime, 0.0, maxChargeTime )
		float chargeFrac = chargeTime / maxChargeTime
		if( chargeFrac >= 1.0 )
		{
			EmitSoundOnEntityOnlyToPlayer(player, player, SHADOW_POUNCE_FULL_CHARGE_SOUND_1P  )

			array <entity> fxHandFullCharge1P
			fxHandFullCharge1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_FULL_FX_1P ), FX_PATTACH_POINT_FOLLOW, leftHandAttachID_1P ) )
			fxHandFullCharge1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_FULL_FX_1P ), FX_PATTACH_POINT_FOLLOW, rightHandAttachID_1P ) )
			foreach( fx in fxHandFullCharge1P )
			{
				fx.SetOwner( player )
				fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_OWNER )
			}
			shadowPounceChargeFx.extend( fxHandFullCharge1P )

			break
		}
		WaitFrame()
	}

	// Idle Charge
	foreach( fx in fxHandCharge1P )
	{
		shadowPounceChargeFx.fastremovebyvalue( fx )
		EffectStop( fx )
	}

	array <entity> fxHandIdle1P
	fxHandIdle1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_IDLE_FX_1P ), FX_PATTACH_POINT_FOLLOW, leftHandAttachID_1P ) )
	fxHandIdle1P.append( StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, GetParticleSystemIndex( SHADOW_POUNCE_CHARGE_IDLE_FX_1P ), FX_PATTACH_POINT_FOLLOW, rightHandAttachID_1P ) )
	foreach( fx in fxHandIdle1P )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_OWNER )
	}
	shadowPounceChargeFx.extend( fxHandIdle1P )

	WaitForever()
}

void function ShadowPounce_Cleanup( entity player, entity weapon )
{
	Assert( player.IsPlayer() )

	if( !IsValid( weapon ) )
		return

	if( !weapon.w.wasFired )
	{
		EmitSoundOnEntityOnlyToPlayer(player, player, SHADOW_POUNCE_CANCEL_SOUND_1P )
		EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_POUNCE_CANCEL_SOUND_3P )
	}
}
#endif

#if CLIENT
void function ShadowPounce_ChargeUI_Thread( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off" )
	if( !IsValid( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", SHADOW_POUNCE_END_CHARGE_SIGNAL )

	var rui = CreateFullscreenRui( $"ui/shadow_pounce_charge_indicator.rpak", HUD_Z_BASE )

	RuiSetGameTime( rui, "startTime", Time() )

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroyIfAlive( rui )
		}
	)

	while( true )
	{
		float maxChargeTime = ShadowPounce_GetMaxChargeTime( player )
		float chargeTime = clamp( Time() - weapon.w.startChargeTime, 0.0, maxChargeTime )
		float chargeFrac = chargeTime / maxChargeTime
		RuiSetFloat( rui, "chargeFrac", chargeFrac )
		WaitFrame()
	}
}

void function ShadowPounce_ChargeFov_Thread( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off" )
	if( !IsValid( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", SHADOW_POUNCE_END_CHARGE_SIGNAL )

	float maxFovOffset = min( MAX_CODE_FOV - player.GetFOV(), file.maxFovOffset )

	OnThreadEnd( function() : ( player, weapon, maxFovOffset ) {
		if ( IsValid( player ) )
		{
			if( IsAlive( player ) && IsValid( weapon ) )
			{
				float maxChargeTime = ShadowPounce_GetMaxChargeTime( player )
				float chargeTime = clamp( Time() - weapon.w.startChargeTime, 0.0, maxChargeTime )
				float chargeFrac = chargeTime/maxChargeTime
				thread ShadowPounce_LerpOutFov_Thread( player, chargeFrac, maxFovOffset )
			}
			else
			{
				player.SetFOVOffset( 0.0 )
			}
		}
	} )

	bool lowCharge = false
	bool midCharge = false
	bool fullCharge = false
	while( true )
	{
		float maxChargeTime = ShadowPounce_GetMaxChargeTime( player )
		float chargeTime = clamp( Time() - weapon.w.startChargeTime, 0.0, maxChargeTime )
		float chargeFrac = chargeTime/maxChargeTime
		player.SetFOVOffset( chargeFrac * maxFovOffset )
		if( ( chargeFrac >= 0.33 ) && ( !lowCharge ) )
		{
			lowCharge = true
			Rumble_Play( "rumble_burn_card_activate", {} )
		}
		if( ( chargeFrac >= 0.66 ) && ( !midCharge ) )
		{
			midCharge = true
			Rumble_Play( "rumble_burn_card_activate", {} )
		}
		if( ( chargeFrac >= 1.0 ) && ( !fullCharge ) )
		{
			fullCharge = true
			Rumble_Play( "rumble_titanfall_request", {} )
		}
		WaitFrame()
	}
}

void function ShadowPounce_LerpOutFov_Thread( entity player, float initialOffsetFrac, float maxOffset )
{
	EndSignal( player, "OnDeath", "OnDestroy" )

	OnThreadEnd( function() : ( player ) {
		if ( IsValid( player ) )
		{
			player.SetFOVOffset( 0.0 )
		}
	} )

	float initialTime = Time()
	float curOffsetFrac = initialOffsetFrac
	while( curOffsetFrac > 0 )
	{
		float progress = ( Time() - initialTime ) / 0.2
		curOffsetFrac = LerpFloat( initialOffsetFrac, 0, progress )
		player.SetFOVOffset( curOffsetFrac * maxOffset )
		WaitFrame()
	}
}

void function ShadowPounce_UpdateIndicator( entity player, entity weapon )
{
	EndSignal( player, SHADOW_POUNCE_END_CHARGE_SIGNAL )
	EndSignal( weapon, "OnDestroy" )

	OnThreadEnd( function() : ( weapon ) {
		if ( IsValid( weapon ) )
		{
			weapon.ClearIndicatorEffectOverrides()
		}
	} )

	while( true )
	{
		vector vel = ShadowPounce_CalcLaunchVelocity( player, weapon.w.startChargeTime )
		weapon.SetIndicatorEffectVelocityOverride( vel )
		WaitFrame()
	}
}
#endif