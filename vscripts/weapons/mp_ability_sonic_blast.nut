global function OnWeaponActivate_ability_sonic_blast
global function OnWeaponDeactivate_ability_sonic_blast
global function OnWeaponTossReleaseAnimEvent_weapon_sonic_blast
global function OnWeaponAttemptOffhandSwitch_weapon_sonic_blast
global function OnWeaponTossPrep_weapon_sonic_blast
global function OnWeaponTossCancel_weapon_sonic_blast
global function MpAbilitySonicBlast_Init
global function GetSonicBlastSilenceDuration
global function GetSonicBlastRange
global function GetSonicBlastDoesSonarScan
global function SonicBlast_TargetEntityShouldBeHighlighted

const asset SONIC_BLAST_FX_IMPACT = $"P_wpn_foa_kickup_dust"
const asset SONIC_BLAST_FX_CAST_FP = $"P_wpn_foa_cast_FP"
const asset SONIC_BLAST_FX_WARNING_BEAM = $"P_wpn_foa_beam_warning"
const asset SONIC_BLAST_FX_WARNING_RADIUS = $"P_wpn_foa_radius_MDL_start"
const asset SONIC_BLAST_FX_FRIENDLY_RADIUS = $"P_wpn_foa_radius_MDL_start_friend"
const asset SONIC_BLAST_FX_ENEMY_RADIUS = $"P_wpn_foa_radius_MDL_start_enemy"
const asset SONIC_BLAST_FX_RADIUS = $"P_wpn_foa_radius_MDL"
const asset SONIC_BLAST_FX_HOLD_1P = $"P_wpn_foa_blast_hold"
const asset SONIC_BLAST_FX_HOLD_3P = $"P_wpn_foa_blast_hold_3p"
const asset SONIC_BLAST_FX_TRACER = $"P_foa_warning_mover_spiral"
const asset FX_DRONE_TARGET = $"P_ar_foa_lockon"

const string SONIC_BLAST_MOVER_SCRIPTNAME = "seer_tactical_mover"

#if CLIENT
global function ServerCallback_ApplyScreenShake
global function ServerCallback_DoDamageIndicator
global function ServerToClient_ShowHealthRUI
global function ServerToClient_SpawnedSonicBlast
#endif

global function ShouldBlastHitVictim

global const float SONIC_BLAST_RADIUS = 200.0
global const float SONIC_BLAST_IN_FRONT_START_DISTANCE = 20.0
global const float SONIC_BLAST_RANGE_EXTENSION = 10.0 / INCHES_TO_METERS
const float SONAR_DURATION = 2.5
const float SILENCE_DURATION = 8.0
const float SLOW_DURATION = 0.5

const float SONIC_BLAST_PROJECTILE_TRAVEL_TIME = 0.5
const float SONIC_BLAST_DEBUG_DRAW_SPHERE_DURATION = 3.75

const int SONIC_BLAST_DAMAGE_AMOUNT = 5
const int SONIC_BLAST_RADIUS_FX_SPACING = 200
//const int ORIGINAL_SONIC_BLAST_TUBE_LENGTH = 850 //Best estimate at how long the tube VFX is by using debug draws.  No easy way to get a length from maya and convert to in game units?
//const int SONIC_BLAST_DETONATION_AUDIO_CHECK_SEGMENTS = 5

#if DEVELOPER
const bool SONIC_BLAST_DEBUG = false
#endif

global const string SONIC_BLAST_THREAT_TARGETNAME = "sonic_blast_threat"
const string SONIC_BLAST_MOVESPEED_MOD_NAME = "seer_tac_movespeed_modifier"
const string SONIC_BLAST_3P = "Seer_Tac_Detonate_3p"  //plays in and outside of all tacs - AK
const string SONIC_INITIAL_BLAST_1P = "Seer_Tac_Projectile_3p"  //plays on or very close to player. might not need - AK
const string SONIC_INITIAL_BLAST_3P = "Seer_Tac_Projectile_3p" //moves with projectile probably only needed for 3p - AK
const string SONIC_BLAST_INITIAL_CHARGE_1P = "Seer_Tac_Deploy_1p"  //player deploying Tac - AK
const string SONIC_BLAST_INITIAL_CHARGE_3P = "Seer_Tac_Deploy_3p"  //3p character deploying Tac - AK
const string SONIC_BLAST_DISORIENT_1P = "Seer_Tac_Tinnitus_Loop_1p"
const string SONIC_BLAST_SECOND_CHARGE_1P = "Seer_Tac_Shot_1p"  //player shooting Tac - AK
const string SONIC_BLAST_SECOND_CHARGE_3P = "Seer_Tac_Shot_3p"  //3p char shooting Tac - AK
const string SONIC_BLAST_CYLINDER_FORM_3P = "Seer_Tac_Cylinder_Form_3p"  //3p Tac Cylinder creation before explode. -AK
const string SONIC_BLAST_TARGET_ACQUIRED_SOUND = "Seer_AcquireTarget_1P"

struct
{
	#if SERVER
		table<entity, array<entity> > sonicBlastHandVFX
	#endif

	float sonicBlastRange
	float sonicBlastRangeSqr
	float sonicBlastRadius
	float sonicBlastRadiusSqr
	float sonicBlastSilenceDuration
	float sonicBlastSonarDuration
	float sonicBlastTubeLength
	bool sonicBlastDoesDamage
	bool sonicBlastInterrupts
	bool sonicBlastDoesFullSonarScan
	int sonicBlastDamage
	#if CLIENT
	bool heartbeatSensorActive
	#endif
} file

void function MpAbilitySonicBlast_Init()
{
	PrecacheParticleSystem( SONIC_BLAST_FX_IMPACT )
	PrecacheParticleSystem( SONIC_BLAST_FX_CAST_FP )
	PrecacheParticleSystem( SONIC_BLAST_FX_WARNING_BEAM )
	PrecacheParticleSystem( SONIC_BLAST_FX_RADIUS )
	PrecacheParticleSystem( SONIC_BLAST_FX_WARNING_RADIUS )
	PrecacheParticleSystem( SONIC_BLAST_FX_HOLD_1P )
	PrecacheParticleSystem( SONIC_BLAST_FX_HOLD_3P )
	PrecacheParticleSystem( SONIC_BLAST_FX_TRACER )
	PrecacheParticleSystem( SONIC_BLAST_FX_FRIENDLY_RADIUS )
	PrecacheParticleSystem( SONIC_BLAST_FX_ENEMY_RADIUS )
	PrecacheParticleSystem( FX_DRONE_TARGET )

	file.sonicBlastRange = HEARTBEAT_SENSOR_NATURAL_RANGE / INCHES_TO_METERS + SONIC_BLAST_RANGE_EXTENSION
	file.sonicBlastRangeSqr = pow( file.sonicBlastRange, 2 )
	file.sonicBlastRadius = GetSonicBlastRadius()
	file.sonicBlastRadiusSqr = pow( file.sonicBlastRadius, 2 )
	file.sonicBlastSilenceDuration = GetSonicBlastSilenceDuration()
	file.sonicBlastSonarDuration = GetSonicBlastSonarDuration()
	file.sonicBlastDoesDamage = GetSonicBlastDoesDamage()
	file.sonicBlastInterrupts = GetSonicBlastInterrupts()
	file.sonicBlastTubeLength = file.sonicBlastRadius * 4.175 //Original tube length 835 was for a radius of 200.  835 / 200 = 4.175.  We can override the radius via playlist, so we need to scale tube length to match.
	file.sonicBlastDamage = GetSonicBlastDamage()
	file.sonicBlastDoesFullSonarScan = GetSonicBlastDoesSonarScan()

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.seer_highlight_target, SonarBlast_StartHighlightStatusEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.seer_highlight_target, SonarBlast_StopHighlightStatusEffect )
	#endif

	RegisterSignal( "SonicBlastReleased" )
	RegisterSignal( "SonicBlastCancelled" )
	RegisterSignal( "HitBySeerTact" )
	RegisterSignal( "PlayerHealthRevealed" )
	RegisterSignal( "EndHeartbeatSensorUI" )
	RegisterSignal( "DestroyHeartbeatSensor" )
}

void function OnWeaponActivate_ability_sonic_blast( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( IsValid( weaponOwner ) )
	{
		thread ChargeUpSound_Thread( weapon, weaponOwner )
	}
}

void function OnWeaponDeactivate_ability_sonic_blast( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	#if SERVER
		CleanupHandVFX( weaponOwner )
	#endif

	if ( IsValid( weaponOwner ) )
	{
		weaponOwner.Signal( "EndHeartbeatSensorUI" )
	}
}

void function ChargeUpSound_Thread( entity weapon, entity weaponOwner )
{
	Assert( IsNewThread(), "Must be threaded off" )
	weapon.EndSignal( "OnPrimaryAttack" )
	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "BleedOut_OnStartDying" )
	weaponOwner.EndSignal( "SonicBlastCancelled" )

	#if CLIENT
	if ( weaponOwner != GetLocalViewPlayer() )
	{
		return
	}
	#endif

	#if SERVER
	EmitSoundOnEntityExceptToPlayer( weaponOwner, weaponOwner, SONIC_BLAST_INITIAL_CHARGE_3P )
	#endif

	#if CLIENT
	EmitSoundOnEntity( weaponOwner, SONIC_BLAST_INITIAL_CHARGE_1P )
	#endif

	OnThreadEnd(
		function() : ( weaponOwner )
		{
			if ( IsValid( weaponOwner ) )
			{
				#if SERVER
				StopSoundOnEntity( weaponOwner, SONIC_BLAST_INITIAL_CHARGE_3P )
				#endif

				#if CLIENT
				StopSoundOnEntity( weaponOwner, SONIC_BLAST_INITIAL_CHARGE_1P )
				#endif
			}
		}
	)

	WaitForever()
}

bool function OnWeaponAttemptOffhandSwitch_weapon_sonic_blast( entity weapon )
{
	return true
}

var function OnWeaponTossCancel_weapon_sonic_blast( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	weaponOwner.Signal( "EndHeartbeatSensorUI" )
	weaponOwner.Signal( "SonicBlastCancelled" )

	#if SERVER
		CleanupHandVFX( weaponOwner )
	#endif

	return 0
}

void function OnWeaponTossPrep_weapon_sonic_blast( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.PlayWeaponEffect( SONIC_BLAST_FX_HOLD_1P, $"", "R_HAND" )
	weapon.PlayWeaponEffect( SONIC_BLAST_FX_HOLD_1P, $"", "L_HAND" )

	#if SERVER
		// No weapon worldmodel for the weapon.PlayWeaponEffect to go on, so manually do the 3p VFX on the hands
		entity weaponOwner = weapon.GetWeaponOwner()
		entity lHandFX = StartParticleEffectOnEntity_ReturnEntity( weaponOwner, GetParticleSystemIndex( SONIC_BLAST_FX_HOLD_3P ), FX_PATTACH_POINT_FOLLOW, weaponOwner.LookupAttachment("R_HAND") )
		entity rHandFX = StartParticleEffectOnEntity_ReturnEntity( weaponOwner, GetParticleSystemIndex( SONIC_BLAST_FX_HOLD_3P ), FX_PATTACH_POINT_FOLLOW, weaponOwner.LookupAttachment("L_HAND") )
		CloneWeaponOwnerRealms( lHandFX, weaponOwner )
		CloneWeaponOwnerRealms( rHandFX, weaponOwner )
		lHandFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
		rHandFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
		file.sonicBlastHandVFX[weaponOwner] <- []
		file.sonicBlastHandVFX[weaponOwner].append( lHandFX )
		file.sonicBlastHandVFX[weaponOwner].append( rHandFX )
		thread ApplyDelayedMoveSpeedModifier_Thread( weaponOwner, weapon )
	#endif
	#if CLIENT
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner == GetLocalViewPlayer() )
	{
		thread DoHeartbeatSensorUI_Thread( weaponOwner, weapon )
	}
	#endif
}

#if SERVER
void function CleanupHandVFX( entity weaponOwner )
{
	if ( weaponOwner in file.sonicBlastHandVFX )
	{
		foreach ( entity fx in file.sonicBlastHandVFX[weaponOwner] )
		{
			if ( IsValid( fx ) )
			{
				fx.Destroy()
			}
		}

		delete file.sonicBlastHandVFX[weaponOwner]
	}
}

void function ApplyDelayedMoveSpeedModifier_Thread( entity player, entity weapon )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SonicBlastReleased" )
	player.EndSignal( "SonicBlastCancelled" )

	if ( !IsValid( weapon) )
		return

	OnThreadEnd(
		function() : ( weapon )
		{
			if ( IsValid( weapon ) && weapon.HasMod( SONIC_BLAST_MOVESPEED_MOD_NAME ) )
			{
				weapon.RemoveMod( SONIC_BLAST_MOVESPEED_MOD_NAME )
			}
		}
	)

	float pulloutTime = weapon.GetWeaponSettingFloat( eWeaponVar.toss_pullout_time )

	wait HEARTBEAT_SENSOR_INITIAL_ACTIVATION_DELAY_DEFAULT

	if ( IsValid( weapon ) && !weapon.HasMod( SONIC_BLAST_MOVESPEED_MOD_NAME ) )
	{
		weapon.AddMod( SONIC_BLAST_MOVESPEED_MOD_NAME )
	}

	WaitForever()
}
#endif

#if CLIENT
void function DoHeartbeatSensorUI_Thread( entity player, entity weapon )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SonicBlastReleased" )
	player.EndSignal( "EndHeartbeatSensorUI" )
	player.EndSignal( "DestroyHeartbeatSensor" )
	weapon.EndSignal( "OnDestroy" )

	if ( file.heartbeatSensorActive )
		return

	file.heartbeatSensorActive = true

	OnThreadEnd(
		function() : ( player )
		{
			file.heartbeatSensorActive = false
			DeactivateHeartbeatSensor( player, true )
			player.Signal( "EndHeartbeatSensorUI" )
		}
	)

	//float pulloutTime = weapon.GetWeaponSettingFloat( eWeaponVar.toss_pullout_time )

	wait HEARTBEAT_SENSOR_INITIAL_ACTIVATION_DELAY_DEFAULT

	InitializeHeartbeatSensorUI( player )
	ActivateHeartbeatSensor( player, true )

	while ( true )
	{
		WaitFrame()
	}
}

void function InitializeHeartbeatSensorUI( entity player )
{
	// Stub for UI initialization - full heartbeat sensor UI would go here
}

void function ActivateHeartbeatSensor( entity player, bool fromTac )
{
	// Stub for heartbeat sensor activation - full implementation would go here
}

void function DeactivateHeartbeatSensor( entity player, bool fromTac )
{
	// Stub for heartbeat sensor deactivation - full implementation would go here
}
#endif

var function OnWeaponTossReleaseAnimEvent_weapon_sonic_blast( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	Assert ( weaponOwner.IsPlayer() )
	weapon.Signal( "OnPrimaryAttack" )

	#if SERVER
	thread SonicBlastAttack_Thread( weapon, weaponOwner )
	CleanupHandVFX( weapon.GetWeaponOwner() )
	#elseif CLIENT
	if ( weaponOwner == GetLocalViewPlayer() )
	{
		int weaponOwnerTeam = weaponOwner.GetTeam()
		vector startPos = weaponOwner.GetWorldSpaceCenter() + ( weaponOwner.GetViewVector() * SONIC_BLAST_IN_FRONT_START_DISTANCE )
		float blastDelay = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "sonic_blast_delay" )
		//var initialBlastSoundHandle = EmitSoundAtPosition( weaponOwnerTeam, startPos, SONIC_INITIAL_BLAST_1P )
		if ( InPrediction() && IsFirstTimePredicted() )
		{
			var secondChargeSoundHandle = EmitSoundAtPosition( weaponOwnerTeam, startPos, SONIC_BLAST_SECOND_CHARGE_1P )
		}
	}
	#endif

	weaponOwner.Signal( "SonicBlastReleased" )

	weapon.StopWeaponEffect( SONIC_BLAST_FX_HOLD_1P, SONIC_BLAST_FX_HOLD_3P )
	weapon.StopWeaponEffect( SONIC_BLAST_FX_HOLD_1P, SONIC_BLAST_FX_HOLD_3P )

	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER
void function SonicBlastAttack_Thread( entity weapon, entity weaponOwner )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	weapon.EndSignal( "OnDestroy" )

	int weaponOwnerTeam = weaponOwner.GetTeam()

	vector startPos = weaponOwner.GetAttachmentOrigin( weaponOwner.LookupAttachment( "CHESTFOCUS" ) ) + ( weaponOwner.GetViewVector() * SONIC_BLAST_IN_FRONT_START_DISTANCE )
	vector blastVector = startPos + ( weaponOwner.GetViewVector() * GetSonicBlastRange( weaponOwner ) )
	vector blastAngles = VectorToAngles( blastVector )
	vector blastVecNormalized = Normalize( blastVector - startPos )
	vector weaponOwnerAngles = weaponOwner.GetAngles()
	vector weaponOwnerEyeAngles = weaponOwner.EyeAngles()
	vector playerEyePos         = weaponOwner.EyePosition()
	vector goalAngles = AnglesCompose( weaponOwner.EyeAngles(), <90, 0, 0> )

	float blastDelay = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "sonic_blast_delay" )

	if ( IsValid( weaponOwner ) )
	{
		//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_FOCUS_OF_ATTENTION, weaponOwner, startPos, weaponOwnerTeam, weaponOwner )
	}

	// Do BEAM VFX
	entity blastFX3 = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( SONIC_BLAST_FX_WARNING_BEAM ), startPos, weaponOwnerEyeAngles )
	CloneWeaponOwnerRealms( blastFX3, weaponOwner )
	EffectSetControlPointVector( blastFX3, 1, blastVector )

	CreateTubeFX( weaponOwner, weaponOwnerTeam, weaponOwnerEyeAngles, startPos, blastDelay )

	thread PlayBattleChatterLineDelayedToSpeakerAndTeam( weaponOwner, "bc_tactical", 0.4 )

	entity trigger = CreateTriggerCylinderNoCylinderRadius( startPos, int( file.sonicBlastRadius ), int( GetSonicBlastRange( weaponOwner ) ), 0 )
	CloneWeaponOwnerRealms( trigger, weaponOwner )
	trigger.SetOwner( weaponOwner )
	trigger.SetAbsAngles( goalAngles )
	SetTeam( trigger, weaponOwnerTeam )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 1
	trigger.SetEnterCallback( SonicBlastTriggerEnter )
	trigger.SearchForNewTouchingEntity()

	// Trigger Cylinder still not firing if ent is already inside trigger when its created: R5DEV-261070
	foreach ( entity victim in trigger.GetTouchingEntities() )
	{
		SonicBlastTriggerEnter( trigger, victim )
	}

	OnThreadEnd(
		function() : ( trigger )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)

	// Use a mover to make the sound/VFX travel along the blast path
	entity scriptMover = CreateScriptMover_NEW( SONIC_BLAST_MOVER_SCRIPTNAME, startPos, weaponOwner.GetAngles() )
	CloneWeaponOwnerRealms( scriptMover, weaponOwner )
	EmitSoundOnEntityExceptToPlayer( scriptMover, weaponOwner, SONIC_INITIAL_BLAST_3P )

	int particleSystemID = GetParticleSystemIndex( SONIC_BLAST_FX_TRACER )
	entity tracerFX = StartParticleEffectOnEntity_ReturnEntity( scriptMover, particleSystemID, FX_PATTACH_POINT_FOLLOW, scriptMover.LookupAttachment( "ref" ) )
	CloneWeaponOwnerRealms( tracerFX, weaponOwner )

	EntFireByHandle( tracerFX, "Kill", "", SONIC_BLAST_PROJECTILE_TRAVEL_TIME, null, null )

	OnThreadEnd(
		function() : ( scriptMover )
		{
			if ( IsValid( scriptMover ) )
				scriptMover.Destroy()
		}
	)

	EmitSoundAtPositionExceptToPlayer( weaponOwnerTeam, startPos, weaponOwner, SONIC_BLAST_SECOND_CHARGE_3P )

	float detonationTime = Time() + blastDelay
	foreach ( entity player in GetPlayerArray_AliveConnected() )
	{
		Remote_CallFunction_Replay( player, "ServerToClient_SpawnedSonicBlast", weaponOwner, weaponOwnerTeam, startPos, blastVector, detonationTime )
	}

	wait 0.1

	//Kicking this move off without the wait above meant that in practice since the travel time is quite fast (0.5s) that by the time the sound played on it, the mover was already quite a bit in front of Seer.
	//adding a very small wait here before we move the script mover seems to fix that and the sounds/vfx feel more like they are starting from Seer.
	scriptMover.NonPhysicsMoveTo( blastVector, SONIC_BLAST_PROJECTILE_TRAVEL_TIME, 0.0, 0 )

	wait blastDelay - 0.1

	thread DoSonicBlastVFX_Thread( weaponOwner, startPos, weaponOwnerAngles, goalAngles, weaponOwnerEyeAngles, blastVector, SONIC_BLAST_RADIUS_FX_SPACING )

	array<entity> touchingEnts = trigger.GetTouchingEntities()

	bool hitEnemy = false

	foreach ( entity victim in touchingEnts )
	{
		if ( victim.IsPhaseShifted() )
			continue

		if ( victim == weaponOwner )
			continue

		if ( ShouldBlastHitVictim( startPos, blastVector, blastVecNormalized, victim, weaponOwnerTeam ) )
		{
			SonicBlastHitPlayer( startPos, weapon, weaponOwner, victim )
			hitEnemy = true
		}
	}

	if ( hitEnemy )
	{
		if ( IsValid( weaponOwner ) )
		{
			EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, SONIC_BLAST_TARGET_ACQUIRED_SOUND )
		}
	}
}

void function SonicBlastTriggerEnter( entity trigger, entity ent )
{
	if( !IsValid( ent) || !IsAlive( ent ) )
		return

	if ( !IsValid( trigger ) )
		return

	if ( !ent.DoesShareRealms( trigger ) )
		return

	if ( ent.IsPhaseShifted() )
		return

	if ( IsFriendlyTeam( ent.GetTeam(), trigger.GetTeam() ) )
		return

	//Tnordin - DISABLING Bangalore passive on Seer tac for now.  Found R5DEV-282488 which was caused by us triggering the passive from here.  Need to investigate why for 10.1+
	//this isn't a traditional projectile, but still should trigger the passive for Bangalore as the micro-drones fly out.
	//if ( ent.IsPlayer() && ent.HasPassive( ePassives.PAS_ADRENALINE ) )
	//{
	//	if ( !ent.IsSprinting() )
	//		return
	//
	//	PassiveAdrenaline_Start( ent )
	//}
}

void function CreateTubeFX( entity weaponOwner, int weaponOwnerTeam, vector weaponOwnerEyeAngles, vector spawnPos, float blastDelay )
{
	float randomRot = RandomFloatRange( 0.0, 360.0 )
	vector randomAngles = AnglesCompose( weaponOwnerEyeAngles, <0, 0, randomRot> )
	entity blastRadiusFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( SONIC_BLAST_FX_WARNING_RADIUS ), spawnPos, randomAngles )
	EffectSetControlPointVector( blastRadiusFx, 5, <file.sonicBlastRadius, 0, 0> )

	entity friendlyRadiusFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( SONIC_BLAST_FX_FRIENDLY_RADIUS ), spawnPos, randomAngles )
	EffectSetControlPointVector( friendlyRadiusFx, 5, <file.sonicBlastRadius, 0, 0> )
	SetTeam( friendlyRadiusFx, weaponOwnerTeam )
	friendlyRadiusFx.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )

	entity enemyRadiusFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( SONIC_BLAST_FX_ENEMY_RADIUS ), spawnPos, randomAngles )
	EffectSetControlPointVector( enemyRadiusFx, 5, <file.sonicBlastRadius, 0, 0> )
	SetTeam( enemyRadiusFx, weaponOwnerTeam )
	enemyRadiusFx.SetVisibilityFlags( ENTITY_VISIBLE_TO_ENEMY )

	CloneWeaponOwnerRealms( blastRadiusFx, weaponOwner )
	CloneWeaponOwnerRealms( friendlyRadiusFx, weaponOwner )
	CloneWeaponOwnerRealms( enemyRadiusFx, weaponOwner )

	EntFireByHandle( blastRadiusFx, "Kill", "", blastDelay, null, null )
	EntFireByHandle( friendlyRadiusFx, "Kill", "", blastDelay, null, null )
	EntFireByHandle( enemyRadiusFx, "Kill", "", blastDelay, null, null )
}

void function CloneWeaponOwnerRealms( entity ent, entity weaponOwner )
{
	ent.RemoveFromAllRealms()
	ent.AddToOtherEntitysRealms( weaponOwner )
}

void function SonicBlastHitPlayer( vector startPos, entity weapon, entity weaponOwner, entity victim )
{
	StatsHook_SeerTacHits( weaponOwner, 1 )

	bool immuneToAbilities = ( StatusEffect_HasSeverity( victim, eStatusEffect.immune_to_abilities ) )
	bool isDummy = IsTrainingDummie( victim )



	if ( ( ( victim.IsPlayer() || isDummy ) && !immuneToAbilities ) )
	{
		if ( file.sonicBlastDoesDamage )
		{
			victim.TakeDamage( file.sonicBlastDamage, weaponOwner, weapon, { origin = weaponOwner.GetAttachmentOrigin( weaponOwner.LookupAttachment( "CHESTFOCUS" ) ) + ( weaponOwner.GetViewVector() * SONIC_BLAST_IN_FRONT_START_DISTANCE ), damageType = DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_ability_sonic_blast } )
		}
		else
		{
			//Even though there's no damage done, the indicator goes a long way to giving players an idea of where they got hit from by the Seer tac
			if ( victim.IsPlayer() )
			{
				Server_Broadcast_DamageIndicator( victim, weaponOwner )
			}
			//Damage battle chatter doesn't make sense with no damage, but maybe down the road we can get a scanned battle chatter line
			//PlayBattleChatterLineToSpeakerAndTeam( victim, "bc_takingDamage" )
		}

		int team = weaponOwner.GetTeam()
		thread SonicBlast_Highlight_Thread( victim, team, GetSonicBlast_Silence_Duration_Base( weaponOwner ) )

		if ( !isDummy )
		{
			thread SilenceThink( victim, weaponOwner, GetSonicBlast_Silence_Duration_Base( weaponOwner ), GetSonicBlast_Silence_Duration_Base( weaponOwner ), file.sonicBlastInterrupts )
		}
	}

	thread SonarTrackTarget_Thread( weaponOwner, victim, GetSonicBlast_Scan_Duration_Base( weaponOwner ) )

	if ( victim.IsPlayer() || victim.IsPlayerDecoy() )
	{
		array<entity> playersForTeam = GetFriendlySquadArrayForPlayer_AliveConnected( weaponOwner )
		foreach ( p in playersForTeam )
		{
			Remote_CallFunction_Replay( p, "ServerToClient_ShowHealthRUI", p, victim, GetSonicBlast_Scan_Duration_Base( weaponOwner ) )
		}
	}

	if ( victim.IsPlayer() )
	{
		Server_Broadcast_ApplyScreenShake( victim, startPos )

		// Seer's shift in power from the scan/cancel towards inhibition and silence - This adds a short hit-stun to impact
		const float SONIC_BLACST_EASE_OUT = 0.25
		StatusEffect_AddTimed( victim, eStatusEffect.emp, 0.2, SLOW_DURATION, SONIC_BLACST_EASE_OUT )
		StatusEffect_AddTimed( victim, eStatusEffect.move_slow, 0.25, SLOW_DURATION, SLOW_DURATION )

		EmitSoundOnEntityOnlyToPlayer( victim, victim, SONIC_BLAST_DISORIENT_1P )
		thread KillSoundAfterDelay_Thread( victim, SONIC_BLAST_DISORIENT_1P, GetSonicBlast_Scan_Duration_Base( weaponOwner ) * 0.5 )

		victim.Signal( "HitBySeerTact" )
	}
}

void function SonicBlast_Highlight_Thread( entity victim, int team, float duration )
{
	EndSignal( victim, "OnDeath" )
	EndSignal( victim, "OnDestroy" )

	OnThreadEnd(
		function() : ( victim, team )
		{
			if ( IsValid( victim ) )
			{
				DecrementHighlightEnableForTeam( victim, GetHighlightId( HIGHLIGHT_NOVA_BLACKHOLE_THREAT ), team )
			}
		}
	)

	if( IsValid( victim ) )
	{
		StatusEffect_AddTimed( victim, eStatusEffect.seer_highlight_target, 1.0, duration, 0.5 )
		IncrementHighlightEnableForTeam( victim, GetHighlightId( HIGHLIGHT_NOVA_BLACKHOLE_THREAT ), team )
	}

	wait duration
}

void function SonarTrackTarget_Thread( entity weaponOwner, entity victim, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off." )

	//Fix for R5DEV-318099
	if ( !IsValid( victim ) || !IsAlive( victim ) )
	{
		return
	}

	victim.EndSignal( "OnDeath" )
	victim.EndSignal( "OnDestroy" )

	int ownerTeam = weaponOwner.GetTeam()
	entity diamondFX = null
	table<string, bool> e
	e["trackingOn"] <- false
	float endTime = Time() + duration
	float startTime = Time()

	if ( file.sonicBlastDoesFullSonarScan )
	{
		SonarStart( victim, victim.GetOrigin(), ownerTeam, weaponOwner )
	}
	else
	{
		diamondFX = StartParticleEffectOnEntity_ReturnEntity( victim, GetParticleSystemIndex( FX_DRONE_TARGET ), FX_PATTACH_POINT_FOLLOW_NOROTATE, victim.LookupAttachment( "CHESTFOCUS" ) )
		SetTeam( diamondFX, ownerTeam )
		diamondFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )
	}

	e["trackingOn"] = true

	if ( victim.IsPlayer() )
	{
		//With an ease out value, the status effect check in cl_smart_ammo returns false as soon as this ease out starts, so you'll briefly see the BH scan iconography and colour as it ends.  Adding the ease out on top of the timing fixes this for now.
		float easeOut = 0.1
		StatusEffect_AddTimed_PredictionFriendly( victim, eStatusEffect.seer_detected, 1.0, duration + easeOut, easeOut )
	}

	OnThreadEnd(
		function() : ( victim, ownerTeam, weaponOwner, diamondFX, e )
		{

			if ( e["trackingOn"] )
			{
				if ( file.sonicBlastDoesFullSonarScan )
				{
					SonarEnd( victim, ownerTeam, weaponOwner )
				}
				else
				{
					if ( IsValid( diamondFX ) )
					{
						EffectStop( diamondFX )
					}
				}
			}
		}
	)

	//Seer's scan can be long enough to have players phase at some point in the middle of it, so need to turn the scan on/off as they phase in/out
	while ( Time() < endTime )
	{
		bool phaseShifted = victim.IsPlayer() ? victim.IsPhaseShiftedOrPending() : false
		if ( phaseShifted )
		{
			if ( e["trackingOn"] )
			{
				if ( file.sonicBlastDoesFullSonarScan )
				{
					SonarEnd( victim, ownerTeam, weaponOwner )
				}
				else
				{
					if ( IsValid( diamondFX ) )
					{
						diamondFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_NOBODY )
					}
				}

				e["trackingOn"] = false
			}
		}
		else
		{
			if ( !e["trackingOn"] )
			{
				if ( file.sonicBlastDoesFullSonarScan )
				{
					SonarStart( victim, victim.GetOrigin(), ownerTeam, weaponOwner )
				}
				else
				{
					diamondFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )
				}

				e["trackingOn"] = true
			}
		}

		WaitFrame()
	}
}

void function KillSoundAfterDelay_Thread( entity victim, string sound, float delay )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	victim.EndSignal( "OnDeath" )
	victim.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( victim, sound )
		{
			if ( IsValid( victim ) )
				StopSoundOnEntity( victim, sound )
		}
	)

	wait delay
}

void function DoSonicBlastVFX_Thread( entity weaponOwner, vector startPos, vector weaponOwnerAngles, vector goalAngles, vector weaponOwnerEyeAngles, vector blastVector, int FXScale )
{
	vector blastVecNormalized = Normalize( blastVector - startPos )
	entity blastFX2 = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( SONIC_BLAST_FX_CAST_FP ), startPos, goalAngles )

	CloneWeaponOwnerRealms( blastFX2, weaponOwner )
	EntFireByHandle( blastFX2, "Kill", "", GetSonicBlast_Silence_Duration_Base( weaponOwner ), null, null )

	//Second blast
	entity blastFX  = StartParticleEffectInWorld_ReturnEntity ( GetParticleSystemIndex( SONIC_BLAST_FX_IMPACT ), startPos, weaponOwnerEyeAngles )
	CloneWeaponOwnerRealms( blastFX, weaponOwner )

	entity distortFX = StartParticleEffectInWorld_ReturnEntity ( GetParticleSystemIndex( SONIC_BLAST_FX_RADIUS ), startPos, weaponOwnerEyeAngles )
	CloneWeaponOwnerRealms( distortFX, weaponOwner )

	//Guarding for R5DEV-278381.  With particle_overlay I don't see these kicking around, but these are also the only ones I don't have an EntFireByHandle call to.
	EntFireByHandle( blastFX, "Kill", "", 3.0, null, null )
	EntFireByHandle( distortFX, "Kill", "", 3.0, null, null )
}

void function Server_Broadcast_ApplyScreenShake( entity player, vector sonicOrigin )
{
	vector victimToSonicOriginNormalized = Normalize( player.EyePosition() - sonicOrigin )
	Remote_CallFunction_Replay( player, "ServerCallback_ApplyScreenShake", player, victimToSonicOriginNormalized )
}

void function Server_Broadcast_DamageIndicator( entity player, entity attacker )
{
	Remote_CallFunction_Replay( player, "ServerCallback_DoDamageIndicator", player, attacker )
}
#endif

bool function SonicBlast_TargetEntityShouldBeHighlighted( entity ent )
{
	#if CLIENT
		if( !IsValid(ent) )
			return false

		if( StatusEffect_HasSeverity( ent, eStatusEffect.seer_highlight_target ) )
			return true
	#endif
	return false
}

#if CLIENT
void function SonarBlast_StartHighlightStatusEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	ManageHighlightEntity( ent )
}

void function SonarBlast_StopHighlightStatusEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	ManageHighlightEntity( ent )
}
#endif
bool function ShouldBlastHitVictim( vector startPos, vector blastVector, vector blastVecNormalized, entity victim, int weaponOwnerTeam )
{
	if ( IsValid( victim ) && ( victim.IsPlayer() || victim.IsPlayerDecoy() || IsTrainingDummie( victim ) || IsCombatNPC( victim ) ) )
	{
		vector blastToPlayer = Normalize( victim.GetWorldSpaceCenter() - startPos )

		if( IsTrainingDummie( victim ) && !victim.IsEntAlive() )
		{
			return false
		}

		if ( DotProduct( blastVecNormalized, blastToPlayer ) > 0.0 )
		{
			if ( !IsFriendlyTeam( victim.GetTeam(), weaponOwnerTeam ) )
			{
				vector eyePosition = IsPlayerInCryptoDroneCameraView( victim ) ? victim.GetAttachmentOrigin( victim.LookupAttachment( "HEADFOCUS" ) ) : victim.EyePosition()

				vector projection = GetClosestPointOnLineSegment( startPos, blastVector, eyePosition )
				float distance = Distance( projection, eyePosition )

				bool passedDistanceCheck = ( distance <= file.sonicBlastRadius )

				if ( passedDistanceCheck )
				{
					return true
				}
			}
		}
	}

	return false
}

#if CLIENT
void function ServerCallback_ApplyScreenShake( entity player, vector victimToSonicOriginNormalized )
{
	if ( player == GetLocalViewPlayer() )
	{
		ClientScreenShake( 2.75, 5, 0.75, ZERO_VECTOR )
	}
}

void function ServerCallback_DoDamageIndicator( entity player, entity attacker )
{
	if ( IsValid( player ) && IsValid( attacker ) )
	{
		if ( player == GetLocalViewPlayer() )
		{
			vector damageOrigin = attacker.GetWorldSpaceCenter() + ( attacker.GetViewVector() * SONIC_BLAST_IN_FRONT_START_DISTANCE )
			DamageIndicators( damageOrigin, attacker, eDamageSourceId.mp_ability_sonic_blast )
		}
	}
}

void function ServerToClient_ShowHealthRUI( entity owner, entity victim, float duration )
{
	thread ServerToClient_ShowHealthRUI_Thread( owner, victim, duration )
}

void function ServerToClient_ShowHealthRUI_Thread( entity owner, entity victim, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off." )

	if ( !IsValid( victim ) )
		return

	//Since golden horse can trigger this so many times, we can kill the old threads
	victim.Signal( "PlayerHealthRevealed" )
	victim.EndSignal( "PlayerHealthRevealed" )

	victim.EndSignal( "OnDestroy" )
	victim.EndSignal( "OnDeath" )

	float endTime = Time() + duration
	bool visible = true

	#if DEVELOPER
	if ( SONIC_BLAST_DEBUG )
	{
		printt("ServerToClient_ShowHealthRUI_Thread - Showing HP Bars for " + victim.GetPlayerName())
	}
	#endif

	OnThreadEnd(
		function() : ( owner, victim )
		{
			//ReconScan_RemoveHudForTarget( owner, victim )
		}
	)

	//var rui = ReconScan_ShowHudForTarget( owner, victim, false )

	while ( Time() < endTime )
	{
		bool phaseShifted = victim.IsPlayer() ? victim.IsPhaseShiftedOrPending() : false
		bool scanBlocked = false//IsValid( owner ) && FerroWall_BlockScan( owner.EyePosition(), victim.GetWorldSpaceCenter() )

		//if ( phaseShifted || scanBlocked )
		{
			//if ( visible )
			{
				//RuiSetBool( rui, "isVisible", false )
				//visible = false
			}
		}
		//else
		{
			//if ( !visible )
			{
				//RuiSetBool( rui, "isVisible", true )
				//visible = true
			}
		}

		WaitFrame()
	}
}

void function ServerToClient_SpawnedSonicBlast( entity ownerPlayer, int ownerTeam, vector startPos, vector blastVector, float detonationTime )
{
	entity localViewPlayer = GetLocalViewPlayer()
	bool isEnemy = IsEnemyTeam( ownerTeam, localViewPlayer.GetTeam() )

	var formSound = EmitSoundAtPosition( TEAM_UNASSIGNED, startPos, SONIC_BLAST_CYLINDER_FORM_3P )

	if ( isEnemy && ( localViewPlayer != ownerPlayer) )
	{
		thread DoSonicBlastThreatIndicator_Thread( localViewPlayer, startPos, blastVector, detonationTime )
	}

	thread DoClientSideDetonationSound_Thread( detonationTime, startPos, blastVector )
}

void function DoClientSideDetonationSound_Thread( float detonationTime, vector startPos, vector blastVector )
{
	Assert ( IsNewThread(), "Must be threaded off." )

	float deltaTime = 0.0

	if ( detonationTime > Time() )
	{
		deltaTime = detonationTime - Time()
	}

	#if DEVELOPER
	if ( SONIC_BLAST_DEBUG )
	{
		printt(FUNC_NAME() + " deltaTime for blast: " + deltaTime )
	}
	#endif

	wait deltaTime

	#if DEVELOPER
	if ( SONIC_BLAST_DEBUG )
	{
		printt( FUNC_NAME() + " Sonic Blast Detonation at: " + Time() )
	}
	#endif

	EmitSoundAtPosition( TEAM_UNASSIGNED, startPos, SONIC_BLAST_3P )
}

void function DoSonicBlastThreatIndicator_Thread( entity victim, vector startPos, vector blastVector, float detonationTime )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	victim.EndSignal( "OnDestroy" )

	vector projection = GetClosestPointOnLineSegment( startPos, blastVector, victim.EyePosition() )
	entity threatTarget = CreateClientSidePropDynamic( projection, <0,0,0>, $"mdl/dev/empty_model.rmdl" )

	OnThreadEnd(
		function() : ( threatTarget )
		{
			if ( IsValid( threatTarget ) )
			{
				threatTarget.Destroy()
			}
		}
	)

	threatTarget.SetScriptName( SONIC_BLAST_THREAT_TARGETNAME )
	ShowGrenadeArrow( victim, threatTarget, file.sonicBlastRadius, 0.0, false )

	while ( Time() < detonationTime )
	{
		projection = GetClosestPointOnLineSegment( startPos, blastVector, victim.EyePosition() )
		threatTarget.SetOrigin( projection )
		WaitFrame()
	}
}
#endif

float function GetSonicBlastSonarDuration()
{
	return GetCurrentPlaylistVarFloat( "seer_tac_sonar_duration", SONAR_DURATION )
}

float function GetSonicBlastSilenceDuration()
{
	return GetCurrentPlaylistVarFloat( "seer_tac_silence_duration", SILENCE_DURATION )
}

float function GetSonicBlastRadius()
{
	return GetCurrentPlaylistVarFloat( "seer_tac_radius", SONIC_BLAST_RADIUS )
}

bool function GetSonicBlastDoesDamage()
{
	return GetCurrentPlaylistVarBool( "seer_tac_does_damage", false )
}

int function GetSonicBlastDamage()
{
	return GetCurrentPlaylistVarInt( "seer_tac_damage", SONIC_BLAST_DAMAGE_AMOUNT )
}

float function GetSonicBlast_Duration_Extension()
{
	return GetCurrentPlaylistVarFloat( "sonicblast_scan_duration_upgraded_extension", 1.5 )
}

float function GetSonicBlast_Silence_Extension()
{
	return GetCurrentPlaylistVarFloat( "sonicblast_silence_duration_upgraded_extension", 2.0 )
}

float function GetSonicBlast_Scan_Duration_Base( entity player )
{
	float result = file.sonicBlastSonarDuration

	if( !IsValid( player ) )
		return result

	if( !player.IsPlayer() )
		return result


	return result
}

float function GetSonicBlast_Silence_Duration_Base( entity player )
{
	float result = file.sonicBlastSilenceDuration

	if( !IsValid( player ) )
		return result

	if( !player.IsPlayer() )
		return result


	return result
}

bool function GetSonicBlastDoesSonarScan()
{
	return GetCurrentPlaylistVarBool( "seer_tac_does_sonar_scan", true )
}

bool function GetSonicBlastInterrupts()
{
	return GetCurrentPlaylistVarBool( "seer_tac_interrupts", true )
}

float function GetSonicBlastRange( entity player )
{
	return GetHeartbeatSensorRange( player ) + SONIC_BLAST_RANGE_EXTENSION
}