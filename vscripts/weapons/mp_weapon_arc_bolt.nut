global function MpWeaponArcBolt_Init
global function OnWeaponActivate_arc_bolt
global function OnWeaponDeactivate_arc_bolt
global function OnWeaponAttemptOffhandSwitch_arc_bolt
global function OnWeaponToss_arc_bolt
global function OnWeaponTossReleaseAnimEvent_arc_bolt
global function OnProjectileCollision_arc_bolt

#if SERVER
global function CodeCallback_OnTetherRemoveApex

global function ArcBolt_IsBoltPlanted
#elseif CLIENT
global function ArcBolt_ServerToClient_NewTetherAdded
global function ArcBolt_ServerToClient_TetherRemoved
#endif

// SOUNDS
const string ARC_BOLT_SOUND_PROJECTILE_FIRE_3P      = "ash_tactical_glaive_fire_3p"
const string ARC_BOLT_SOUND_PROJECTILE_FIRE_1P      = "ash_tactical_glaive_fire_1p"
const string ARC_BOLT_SOUND_PROJECTILE_HOLD_3P      = "ash_tactical_glaive_hold_3p"
const string ARC_BOLT_SOUND_PROJECTILE_HOLD_1P      = "ash_tactical_glaive_hold_1p"
const string ARC_BOLT_SOUND_PROJECTILE_IDLE_1P	    = "Ash_Tactical_Glaive_Idle_1p"
const string ARC_BOLT_SOUND_PROJECTILE_LOOP         = "Ash_Tactical_Glaive_Projectile_Loop_3p"
const string ARC_BOLT_SOUND_TRAP_LOOP				= "Phys_Glaive_Imp_Loop"

const string ARC_BOLT_SOUND_IMP_UPGRADE				= "Phys_Glaive_LastingSnare_Imp"
const string ARC_BOLT_SOUND_TRAP_LOOP_UPGRADE		= "Ash_Tactical_Glaive_Projectile_LegendUpgrade_Loop_3p"
const string ARC_BOLT_SOUND_END_WARNING_UPGRADE		= "Ash_Tactical_Glaive_LegendUpgrade_5sec_Ending_Beep"
const float ARC_BOLT_LIFETIME_NOTI_TIME_UPGRADE		= 5.0

const string ARC_BOLT_SOUND_TETHER_CONNECT_3P       = "Ash_Tactical_Glaive_Connect_3P"
const string ARC_BOLT_SOUND_TETHER_CONNECT_1P       = "Ash_Tactical_Glaive_Connect_1P"
const string ARC_BOLT_SOUND_TETHER_CONNECT_FEEDBACK = "Ash_Tactical_Glaive_Connect_Feedback_1p"
const string ARC_BOLT_SOUND_TETHER_LOOP_3P          = "Ash_Tactical_Glaive_TetherLoop_3P"
const string ARC_BOLT_SOUND_TETHER_LOOP_1P          = "Ash_Tactical_Glaive_TetherLoop_1P"
const string ARC_BOLT_SOUND_TETHER_LOOP_FEEDBACK    = "Ash_Tactical_Glaive_TetherLoop_Feedback_1P"
const string ARC_BOLT_SOUND_DAMAGE_BREAK_3P         = "Ash_Tactical_Glaive_tetherbreak_3P"
const string ARC_BOLT_SOUND_DAMAGE_BREAK_1P         = "Ash_Tactical_Glaive_tetherbreak_1P"
const string ARC_BOLT_SOUND_DAMAGE_BREAK_FEEDBACK   = "Ash_Tactical_Glaive_tetherbreak_Feedback_1p"

const float ARC_BOLT_SOUND_FEEDBACK_FALLOUT_DISTANCE_SQR = 1000.0 * 1000.0

// VFX
const asset ARC_BOLT_PROJECTILE_FX = $"P_ash_arcbolt_projectile"  // Projectile
const asset ARC_BOLT_PROJECTILE_CRAWL_FX = $"P_ash_arcbolt_crawl" //goes between bolt and ground
const asset ARC_BOLT_PROJECTILE_PLANTED_FX = $"P_ash_arcbolt_trap"
const asset ARC_BOLT_TETHER_RADIUS_FX_UPGRADED = $"P_LU_Ash_LastingSnare"  // Upgraded element indicating that the arc snare will last longer

const asset ARC_BOLT_ZAP_CONNECT_FX = $"P_ash_arcbolt_active_hit"
const asset ARC_BOLT_ZAP_FX = $"P_ash_arcbolt_tether" //discharge + tether
const asset ARC_BOLT_TETHER_RADIUS_FX = $"P_ash_arcbolt_tether_radius" // Radius Marker for Tether
const asset ARC_BOLT_TETHER_SCREEN_FX = $"P_ash_tether_screen_edge"    //$"P_ash_tether_screen"
const asset ARC_BOLT_TETHER_INDICATOR_FX = $"P_ash_tether_indicator_cp10"  //$"P_ash_tether_indicator"
const asset ARC_BOLT_TETHER_BREAK_CORE = $"P_emp_body_human"
const asset ARC_BOLT_TETHER_BREAK_SNAP = $"P_tesla_trap_dmg"

const asset ARC_BOLT_TETHER_ANCHOR = $"mdl/weapons_r5/misc_ash_glaive/ash_glaive_solo_fx.rmdl"

// ORGANIZATION AND DEBUG
const string SIGNAL_TETHER_CREATED = "ArcBolt_TetherCreated"
const string SIGNAL_TETHER_REMOVED = "ArcBolt_TetherRemoved"
const string SIGNAL_KILL_CRAWL_FX = "ArcBolt_ArcEffectCreated"

const bool DEBUG_CONNECT_POINT 	= false  // false/true Debug view of octodad points
const bool DEBUG_PLANT_POINT	= false

const string FUNCNAME_NEW_TETHER = "ArcBolt_ServerToClient_NewTetherAdded"
const string FUNCNAME_REMOVED_TETHER = "ArcBolt_ServerToClient_TetherRemoved"
global const string TETHER_TRAP_SCRIPTNAME = "arc_snare"
global const string TETHER_SCRIPTNAME = "arc_tether"
global const string TETHER_BLOCKER_SCRIPTNAME = "tether_blocker"
#if CLIENT
global const string ARCBOLT_THREAT_INDICATOR_SCRIPTNAME = "arcbolt_threat"
#endif

// GAMEPLAY
const float TETHER_DURATION_DEFAULT = 5.0

const float TETHER_DURATION_UPGRADE = 15.0

const float SHIELD_SCALE_DAMAGE_MULT_DEFAULT = 2.0

const float TETHER_MAX_PULL_VELOCITY_DEFAULT = 100.0
const float TETHER_DEFAULT_STRENGTH = 80.0
const float TETHER_STRENGTH_HEALTH_SCALE = 0.6
const float TETHER_HEALTH_BASE = 1000.0







const float TETHER_RADIUS_DEFAULT = 190
const float TETHER_HEALTH_DRAIN_PER_SEC_DEFAULT = 250.0
const float TETHER_MAX_STRETCH_DAMAGE_DEFAULT = 4.0    // Per-frame, maximum amont of damage dealt by stretching + velocity
const float TETHER_HEALTH_STRETCH_DAMAGE_SCALE_DEFAULT = 0.11

const float TETHER_HEALTH_DRAIN_DELAY = 1.0
const float TETHER_HEALTH_DRAIN_CUTOFF_PCT = 0.0

const float TETHER_HEALTH_VELOCITY_DAMAGE_SCALE_DEFAULT = 0.011

const float TETHER_GRAV_DMG_FRAC_PER_SEC = 0.5
const float TETHER_ZIPLINE_SCALING_MIN_VEL = 200
const float TETHER_ZIPLINE_STRENGTH_SCALE = 0.15

const vector TETHER_SPAWN_OFFSET = <0, 0, 12>

const float PROJECTILE_REFUND_MAX_LIFETIME = 1.0
const float PROJECTILE_REFUND_AMOUNT_DEFAULT = 0.5

enum eBoltType
{
	PROJECTILE,
	PLANTED,
}

struct boltState
{
	entity threatIndicator
	int    type
	float  timeBeforePlanted
	entity plantedRadiusFx


	#if SERVER
		array<entity> tetheredEntities
	#endif

}

struct
{
	#if SERVER
		table<entity, entity>    ownerToBoltTable
		table<entity, boltState> boltStateTable

		bool  hasSettingsData
		int   shockRadius
		int   shockDamage



			float boltRadiusGrowTime = 0.5

		float boltRadiusExponent = 1.5
		float shieldDamageScale
		float healthDrainPerSec
		float tetherStretchDamageScale
		float tetherVelocityDamageScale
		float projectileRefundAmount
	#elseif CLIENT
		var        tetherRui
		array<int> affectedTethers
	#endif
	float tetherRadius
	float tetherRadiusSqr
	bool  doOnHitPing
	float boltLifetime

		float upgradedBoltLifetime

} file

void function MpWeaponArcBolt_Init()
{
	PrecacheParticleSystem( ARC_BOLT_PROJECTILE_FX )
	PrecacheParticleSystem( ARC_BOLT_ZAP_FX )
	PrecacheParticleSystem( ARC_BOLT_TETHER_RADIUS_FX )
	PrecacheParticleSystem( ARC_BOLT_PROJECTILE_CRAWL_FX )
	PrecacheParticleSystem( ARC_BOLT_TETHER_SCREEN_FX )
	PrecacheParticleSystem( ARC_BOLT_PROJECTILE_PLANTED_FX )
	PrecacheParticleSystem( ARC_BOLT_ZAP_CONNECT_FX )
	PrecacheParticleSystem( ARC_BOLT_TETHER_INDICATOR_FX )
	PrecacheParticleSystem( ARC_BOLT_TETHER_RADIUS_FX_UPGRADED )

	PrecacheModel( ARC_BOLT_TETHER_ANCHOR )

	file.doOnHitPing = GetCurrentPlaylistVarBool( "ash_tether_do_hit_ping", true )

	file.boltLifetime 				= GetCurrentPlaylistVarFloat( "ash_tether_duration", TETHER_DURATION_DEFAULT )

		file.upgradedBoltLifetime		= GetCurrentPlaylistVarFloat( "ash_tether_duration_upgraded", TETHER_DURATION_UPGRADE )


	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_arc_bolt, OnDamaged_Shock )
		//AddCallback_OnPlayerShieldDamage( OnShieldDamaged )

		file.shieldDamageScale          = GetCurrentPlaylistVarFloat( "ash_tether_shield_dmg_scale", SHIELD_SCALE_DAMAGE_MULT_DEFAULT )
		file.healthDrainPerSec          = GetCurrentPlaylistVarFloat( "ash_tether_health_drain_per_sec", TETHER_HEALTH_DRAIN_PER_SEC_DEFAULT )
		file.tetherStretchDamageScale   = GetCurrentPlaylistVarFloat( "ash_tether_stretch_dmg_scale", TETHER_HEALTH_STRETCH_DAMAGE_SCALE_DEFAULT )
		file.tetherVelocityDamageScale  = GetCurrentPlaylistVarFloat( "ash_tether_velocity_dmg_scale", TETHER_HEALTH_VELOCITY_DAMAGE_SCALE_DEFAULT )
		file.projectileRefundAmount     = GetCurrentPlaylistVarFloat( "ash_tether_refund_amount", PROJECTILE_REFUND_AMOUNT_DEFAULT )
	#elseif CLIENT
		AddCreateCallback( "prop_script", ArcBolt_OnPropScriptCreated )
		if ( file.doOnHitPing )
			AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )
	#endif
	file.tetherRadius                   = GetCurrentPlaylistVarFloat( "ash_tether_radius", TETHER_RADIUS_DEFAULT )
	file.tetherRadiusSqr                = file.tetherRadius * file.tetherRadius

	RegisterSignal( SIGNAL_TETHER_CREATED )
	RegisterSignal( SIGNAL_TETHER_REMOVED )
	RegisterSignal( SIGNAL_KILL_CRAWL_FX )

	Remote_RegisterClientFunction( FUNCNAME_NEW_TETHER, "int", INT_MIN, INT_MAX, "entity" )
	Remote_RegisterClientFunction( FUNCNAME_REMOVED_TETHER, "int", INT_MIN, INT_MAX )

	SetConVarFloat( "tether_maxvel", GetCurrentPlaylistVarFloat( "ash_tether_pull_maxvel", TETHER_MAX_PULL_VELOCITY_DEFAULT ) )
	//SetConVarFloat( "tether_default_strength", TETHER_DEFAULT_STRENGTH )
	//SetConVarFloat( "tether_strength_healthScale", TETHER_STRENGTH_HEALTH_SCALE )
	//SetConVarFloat( "tether_maxStretchDamage", GetCurrentPlaylistVarFloat( "ash_tether_max_stretch_damage", TETHER_MAX_STRETCH_DAMAGE_DEFAULT ) )

	//SetConVarFloat( "tether_gravity_dmg_frac_per_sec", TETHER_GRAV_DMG_FRAC_PER_SEC )
	//SetConVarFloat( "tether_zipline_scaling_min_vel", TETHER_ZIPLINE_SCALING_MIN_VEL )
	//SetConVarFloat( "tether_zipline_strength_scale", TETHER_ZIPLINE_STRENGTH_SCALE )

}


void function OnWeaponActivate_arc_bolt( entity weapon )
{
	#if SERVER
		if ( !file.hasSettingsData )    // Weapons data not initialize on script init
		{
			file.shockRadius     = expect int( weapon.GetWeaponInfoFileKeyField( "shock_radius" ) )
			file.shockDamage     = expect int( weapon.GetWeaponInfoFileKeyField( "shock_damage" ) )
			file.hasSettingsData = true
		}
	#endif

	weapon.EmitWeaponSound_1p3p( ARC_BOLT_SOUND_PROJECTILE_HOLD_1P, ARC_BOLT_SOUND_PROJECTILE_HOLD_3P )
}


void function OnWeaponDeactivate_arc_bolt( entity weapon )
{
	weapon.StopWeaponSound( ARC_BOLT_SOUND_PROJECTILE_HOLD_1P )
	weapon.StopWeaponSound( ARC_BOLT_SOUND_PROJECTILE_HOLD_3P )

	if ( IsValid( weapon.GetOwner() ) )
		StopSoundOnEntity( weapon.GetOwner(), ARC_BOLT_SOUND_PROJECTILE_IDLE_1P )	// R5DEV-316987 - This stops a bakery sound that isn't always stopping itself
}


bool function OnWeaponAttemptOffhandSwitch_arc_bolt( entity weapon )
{
	return true
}


var function OnWeaponToss_arc_bolt( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
		if ( IsValid( weapon.GetOwner() ) )
			PlayBattleChatterLineToSpeakerAndTeam( weapon.GetOwner(), "bc_tactical" )
	#endif
	return true
}


var function OnWeaponTossReleaseAnimEvent_arc_bolt( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !(InPrediction() && IsFirstTimePredicted()) )
			return
	#endif

	weapon.StopWeaponSound( ARC_BOLT_SOUND_PROJECTILE_HOLD_1P )
	weapon.StopWeaponSound( ARC_BOLT_SOUND_PROJECTILE_HOLD_3P )
	weapon.EmitWeaponSound_1p3p( ARC_BOLT_SOUND_PROJECTILE_FIRE_1P, ARC_BOLT_SOUND_PROJECTILE_FIRE_3P )

	entity player = weapon.GetWeaponOwner()
	if ( IsValid( player ) )
		StopSoundOnEntity( weapon.GetOwner(), ARC_BOLT_SOUND_PROJECTILE_IDLE_1P )	// R5DEV-316987 - This stops a bakery sound that isn't always stopping itself

	{
		if ( player.IsPlayer() )
			PlayerUsedOffhand( player, weapon )

		float lifetime = weapon.GetWeaponSettingFloat( eWeaponVar.projectile_lifetime )
		thread WeaponAttackBolt( weapon, attackParams.pos, attackParams.dir, lifetime )
	}

	return weapon.GetAmmoPerShot()
}


void function WeaponAttackBolt( entity weapon, vector pos, vector dir, float lifetime )
{
	entity owner = weapon.GetOwner()
	if ( !IsValid( weapon.GetOwner() ) )
		return

	int damage = weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )

	WeaponFireBoltParams fireBoltParams
	fireBoltParams.pos                       = pos
	fireBoltParams.dir                       = dir
	fireBoltParams.speed                     = 1
	fireBoltParams.scriptTouchDamageType     = damage
	fireBoltParams.scriptExplosionDamageType = damage
	fireBoltParams.clientPredicted           = true
	fireBoltParams.additionalRandomSeed      = 0
	fireBoltParams.dontApplySpread           = true
	fireBoltParams.projectileIndex           = 0
	fireBoltParams.deferred                  = false

	DeployableCollisionParams emptyParams
	entity bolt = CreateBolt( weapon.GetOwner(), weapon, fireBoltParams, false, emptyParams )

	if ( bolt == null )
		return

	#if SERVER
		thread Bolt_Thread( bolt, owner, lifetime, 0.0, false )
	#endif
}


entity function CreateBolt( entity owner, entity weapon, WeaponFireBoltParams fireBoltParams, bool isPlanted, DeployableCollisionParams collisionParams )
{
	entity bolt

	if ( !IsValid( owner ) )
		return bolt

	if ( !isPlanted )
	{
		bolt = weapon.FireWeaponBoltAndReturnEntity( fireBoltParams )
	}
	else
	{
		#if SERVER
			bolt = CreatePropScript( $"mdl/dev/empty_model.rmdl", collisionParams.pos, VectorToAngles( collisionParams.normal ) )
			bolt.SetScriptName( TETHER_TRAP_SCRIPTNAME )
			bolt.SetOwner( owner )
			bolt.RemoveFromAllRealms()
			bolt.AddToOtherEntitysRealms( owner )
		#endif
	}

	#if SERVER
		if ( IsValid( bolt ) )
		{
			file.ownerToBoltTable[ owner ] <- bolt

			boltState state
			state.type            = isPlanted ? eBoltType.PLANTED : eBoltType.PROJECTILE
			file.boltStateTable[ bolt ] <- state
		}
	#endif

	return bolt
}

void function OnProjectileCollision_arc_bolt( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical )
{
	#if SERVER
		if ( !IsValid( projectile ) || !(projectile in file.boltStateTable) )
			return

		if ( !IsValid( hitEnt ) )
			return

		entity owner = projectile.GetOwner()
		if ( IsValid( owner ) && hitEnt == owner )
			return

		if ( hitEnt.IsPlayer() || hitEnt.IsNPC() && (!hitEnt.IsNonCombatAI() || hitEnt.GetClassName() == "npc_dummie" ) )
		{
			if ( IsEnemyTeam( hitEnt.GetTeam(), projectile.GetTeam() ) && owner in file.ownerToBoltTable )
			{
				hitEnt.TakeDamage( file.shockDamage, owner, projectile, { origin = projectile.GetOrigin(), damageSourceId = eDamageSourceId.mp_weapon_arc_bolt } )
				return
			}
			else if ( IsFriendlyTeam( hitEnt.GetTeam(), projectile.GetTeam() ) )
				return
		}

		DeployableCollisionParams collisionParams
		collisionParams.pos = pos
		collisionParams.normal = normal
		collisionParams.hitEnt = hitEnt
		collisionParams.hitBox = 0
		collisionParams.isCritical = isCritical

		if ( !PlantBolt( collisionParams, owner, projectile, GetBoltLifetime( owner ) ) )
			return

		CleanUpBolt( projectile )
	#endif
}

float function GetBoltLifetime( entity player )
{
	float result = file.boltLifetime


	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) //upgrade_ash_longer_tac_duration
	{
		result = file.upgradedBoltLifetime
	}


	return result
}

#if SERVER
bool function PlantBolt( DeployableCollisionParams collisionParams, entity owner, entity projectile, float lifetime )
{
	WeaponFireBoltParams emptyParams
	entity newBolt = CreateBolt( owner, null, emptyParams, true, collisionParams )

	if ( newBolt == null )
		return false

	if ( !PlantStickyEntity( newBolt, collisionParams, <0, 0, 0>, true ) )
	{
		CleanUpBolt( newBolt )
		return false
	}

	file.boltStateTable[ newBolt ].timeBeforePlanted = projectile.GetTimeSinceSpawning()


	if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_ONE ) ) //upgrade_ash_longer_tac_duration
	{
		EmitSoundOnEntity( newBolt, ARC_BOLT_SOUND_IMP_UPGRADE )
		thread UpgradedBoltEndingSoundBeep_Thread( owner, newBolt )
	}

	thread Bolt_Thread( newBolt, owner, lifetime, 0.3, true )

	return true
}


void function UpgradedBoltEndingSoundBeep_Thread( entity owner, entity newBolt )
{
	EndSignal( newBolt, "OnDestroy" )
	wait GetBoltLifetime( owner ) - ARC_BOLT_LIFETIME_NOTI_TIME_UPGRADE
	while ( true )
	{
		EmitSoundOnEntity( newBolt, ARC_BOLT_SOUND_END_WARNING_UPGRADE )
		wait 1.0
	}
}



void function Bolt_Thread( entity bolt, entity owner, float lifetime, float activationDelay, bool boltIsPlanted )
{
	EndSignal( bolt, "OnDestroy" )
	EndSignal( owner, "OnDestroy", "OnDeath" )

	// VFX
	array<entity> boltFxArray
	if ( !boltIsPlanted )
	{
		boltFxArray.append( StartParticleEffectOnEntity_ReturnEntity ( bolt, GetParticleSystemIndex( ARC_BOLT_PROJECTILE_FX ), FX_PATTACH_POINT_FOLLOW, bolt.LookupAttachment( "ORIGIN" ) ) )
		EffectSetControlPointVector( boltFxArray[ boltFxArray.len() - 1 ], 1, <file.shockRadius, 0, 0>)
	}
	else
	{
		boltFxArray.append( StartParticleEffectOnEntity_ReturnEntity ( bolt, GetParticleSystemIndex( ARC_BOLT_PROJECTILE_PLANTED_FX ), FX_PATTACH_POINT_FOLLOW, bolt.LookupAttachment( "ORIGIN" ) ) )

		entity plantedFx = StartParticleEffectOnEntity_ReturnEntity( bolt, GetParticleSystemIndex( ARC_BOLT_TETHER_RADIUS_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		EffectSetControlPointVector( plantedFx, 1, <0, 0, 0> )
		EffectSetControlPointVector( plantedFx, 2, <255, 0, 0> )
		SetTeam( plantedFx, owner.GetTeam() )
		plantedFx.SetOwner( owner )
		plantedFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY | ENTITY_VISIBLE_TO_OWNER
		boltFxArray.append( plantedFx )


		if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_ONE ) ) //upgrade_ash_longer_tac_duration
			boltFxArray.append( StartParticleEffectOnEntity_ReturnEntity ( bolt, GetParticleSystemIndex( ARC_BOLT_TETHER_RADIUS_FX_UPGRADED ), FX_PATTACH_POINT_FOLLOW, bolt.LookupAttachment( "ORIGIN" ) ) )


		file.boltStateTable[ bolt ].plantedRadiusFx = plantedFx
	}

	// Audio
	if ( !boltIsPlanted )
		EmitSoundOnEntity( bolt, ARC_BOLT_SOUND_PROJECTILE_LOOP )
	else
	{

		if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_ONE ) ) //upgrade_ash_longer_tac_duration
			EmitSoundOnEntity( bolt, ARC_BOLT_SOUND_TRAP_LOOP_UPGRADE )
		else

			EmitSoundOnEntity( bolt, ARC_BOLT_SOUND_TRAP_LOOP )
	}

	// Gameplay
	entity traceBlocker
	if ( !boltIsPlanted )
	{
		file.boltStateTable[ bolt ].threatIndicator = CreateProjectileBoltThreatIndicator( bolt, eBoltType.PROJECTILE, owner )
	}
	else
	{
		traceBlocker = CreateTraceBlockerVolume( bolt.GetOrigin(), file.tetherRadius * 0.75, false, CONTENTS_BLOCK_PING, owner.GetTeam(), TETHER_BLOCKER_SCRIPTNAME )
		traceBlocker.RemoveFromAllRealms()
		traceBlocker.AddToOtherEntitysRealms( owner )
		traceBlocker.SetTouchTriggers( true )
		traceBlocker.SetOwner( owner )
	}






	OnThreadEnd(
		function() : ( bolt, boltFxArray, traceBlocker, owner )
		{
			if ( owner in file.ownerToBoltTable )
				delete file.ownerToBoltTable[ owner ]

			foreach ( fx in boltFxArray )
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}

			if ( IsValid( traceBlocker ) )
				traceBlocker.Destroy()

			if ( IsValid( bolt ) )
			{

				if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_ONE ) ) //upgrade_ash_longer_tac_duration
					StopSoundOnEntity( bolt, ARC_BOLT_SOUND_TRAP_LOOP_UPGRADE )

				StopSoundOnEntity( bolt, ARC_BOLT_SOUND_PROJECTILE_LOOP )
				StopSoundOnEntity( bolt, ARC_BOLT_SOUND_TRAP_LOOP )
			}

			// Often, we won't be able to clean up the bolt here - the bolt is already invalid (marked for deletion) even though the data is still around
			// R5DEV-309619 was opened to look into handling this in a better way, so we can index the entity into a table to clean things up
			// Luckily, we know when the bolt will be destroyed ahead of time in most cases so the bolt will get cleaned up then.
			CleanUpBolt( bolt )
		}
	)

	wait activationDelay

	if ( !IsValid( bolt ) || !(bolt in file.boltStateTable) )
		return

	entity radiusFxEnt
	if ( !boltIsPlanted )
	{
		// These effects should be moved to the client (since we're doing some traces) but there's no great way to do that at the moment
		// There's an initial projectile created on the client, but that gets deleted and replaced once the server projectile is created
		// ClientCodeCallback_OnPredictedEntityRemove doesn't work anymore, and ClientCodeCallback_OnEntityCreation doesn't get called for the bolt
		// If need be, we could try creating a lightweight entity on the server and parenting it to the bolt, and have the client play FX on that
		CreateArcFX( bolt )
	}

	OnThreadEnd(
		function() : ( radiusFxEnt )
		{
			if ( IsValid( radiusFxEnt ) )
				radiusFxEnt.Destroy()
		}
	)

	float startTime = Time()
	if ( boltIsPlanted )
		startTime -= file.boltStateTable[ bolt ].timeBeforePlanted

	float curTime = Time()
	float endTime = curTime + lifetime
	bool  didSetMaxRadiusFx = false
	while ( curTime <= endTime )
	{
		if ( !IsValid( owner ) || !IsValid( bolt ) || !(bolt in file.boltStateTable) )
			return

		// Grow radius over time
		int effectiveRadius = file.shockRadius
		if ( (startTime + file.boltRadiusGrowTime) > curTime )
		{
			float numerator = pow( min( curTime - startTime, file.boltRadiusGrowTime ), file.boltRadiusExponent )
			float divisor = pow( file.boltRadiusGrowTime, file.boltRadiusExponent )




				const int MIN_PROJECTILE_RADIUS = 1
				effectiveRadius = int( max( effectiveRadius * numerator / divisor, MIN_PROJECTILE_RADIUS ) )


			if ( boltIsPlanted && IsValid( file.boltStateTable[bolt].plantedRadiusFx ) )
			{
				EffectSetControlPointVector( file.boltStateTable[ bolt ].plantedRadiusFx, 1, <effectiveRadius, 0, 0> )
			}
		}
		else if ( !didSetMaxRadiusFx && boltIsPlanted && IsValid( file.boltStateTable[bolt].plantedRadiusFx ) )
		{
			EffectSetControlPointVector( file.boltStateTable[ bolt ].plantedRadiusFx, 1, <effectiveRadius, 0, 0> )
			didSetMaxRadiusFx = true
		}

		vector effectiveOrigin = bolt.GetOrigin()
		if ( boltIsPlanted )
		{
			// Being planted on doors (among other things) kept the origin inside the parent object's collision
			// This should help the tether stay out of the parent's collision while keeping the model partially embedded
			effectiveOrigin += bolt.GetForwardVector() * 4.0
		}

		RadiusDamage(
			effectiveOrigin,
			owner, //attacker
			bolt, //inflictor
			file.shockDamage,
			file.shockDamage,
			effectiveRadius, // inner radius
			effectiveRadius, // outer radius
			SF_ENVEXPLOSION_MASK_BRUSHONLY,
			0, // distanceFromAttacker
			0, // explosionForce
			DF_ELECTRICAL | DF_NO_SELF_DAMAGE,
			eDamageSourceId.mp_weapon_arc_bolt )

		WaitFrame()
		curTime = Time()
	}
}

void function CreateArcFX( entity bolt )
{
	vector boltForward = bolt.GetForwardVector()

	thread ArcConnect_Thread( bolt, <boltForward.x * 0.5, boltForward.y * 0.5, 0> + <0, 0, -1.0>, <30, 0, 0> )
	thread ArcConnect_Thread( bolt, bolt.GetRightVector(), <30, 0, 0> )
	thread ArcConnect_Thread( bolt, -bolt.GetRightVector(), <30, 0, 0> )
	thread ArcConnect_Thread( bolt, bolt.GetUpVector(), <30, 0, 0> )
}


void function ArcConnect_Thread( entity bolt, vector dir, vector maxAngleDeviations )
{
	EndSignal( bolt, "OnDestroy" )

	while ( true )
	{
		vector ornull arcPos = GetArcConnectPoint( bolt, dir, maxAngleDeviations )

		if ( arcPos == null )
		{
			WaitFrame()
			continue
		}

		expect vector( arcPos )

		int crawlFxId     = GetParticleSystemIndex( ARC_BOLT_PROJECTILE_CRAWL_FX )
		entity crawlFxEnt = StartParticleEffectOnEntity_ReturnEntity( bolt, crawlFxId, FX_PATTACH_POINT_FOLLOW, bolt.LookupAttachment( "ORIGIN" ) )
		EffectSetControlPointVector( crawlFxEnt, 1, arcPos )

		wait RandomFloatRange( 0.4, 0.8 )

		if ( IsValid ( crawlFxEnt ) )
			crawlFxEnt.Destroy()
	}
}


vector ornull function GetArcConnectPoint( entity bolt, vector dir, vector maxAngleDeviations )
{
	vector moddedAngles = < RandomFloatRange( -maxAngleDeviations.x, maxAngleDeviations.x ), RandomFloatRange( -maxAngleDeviations.y, maxAngleDeviations.y ), RandomFloatRange( -maxAngleDeviations.z, maxAngleDeviations.z ) >
	vector dirModified  = dir

	if ( maxAngleDeviations.x > 0)
		dirModified = VectorRotateAxis( dirModified, bolt.GetForwardVector(),moddedAngles.x )
	if ( maxAngleDeviations.y > 0)
		dirModified = VectorRotateAxis( dirModified, bolt.GetRightVector(),moddedAngles.y )
	if ( maxAngleDeviations.z > 0)
		dirModified = VectorRotateAxis( dirModified, bolt.GetUpVector(),moddedAngles.z )

	dirModified = Normalize( dirModified )

	TraceResults arcTrace = TraceLine( bolt.GetOrigin(), bolt.GetOrigin() + dirModified * file.shockRadius, [ bolt ], TRACE_MASK_SOLID )

	if ( DEBUG_CONNECT_POINT )
	{
		if ( arcTrace.fraction == 1.0 )
		{
			DebugDrawSphere( arcTrace.endPos, 10, 255, 0, 0, false, 5.0 )
		}
		else
		{
			DebugDrawSphere( arcTrace.endPos, 10, 255, 255, 0, false, 5.0 )
		}
	}

	return arcTrace.fraction == 1.0 ? null : arcTrace.endPos
}
#endif

#if SERVER
void function OnDamaged_Shock( entity victim, var damageInfo )
{
	thread OnDamaged_Shock_Thread( victim, damageInfo )





}


void function OnDamaged_Shock_Thread( entity victim, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if ( !IsValid( attacker ) || !IsValid( inflictor ) || !IsValid( victim ) || victim == attacker )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( !IsEnemyTeam( victim.GetTeam(), attacker.GetTeam() ) && attacker != victim )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( victim.IsNPC() )
	{
		if ( victim.IsNonCombatAI() && victim.GetClassName() != "npc_dummie" )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}

		EMP_DamagedPlayerOrNPC( victim, damageInfo )
	}
	else if ( !victim.IsPlayer() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	thread CreateTether_Thread( attacker, victim, inflictor )
}

float function OnShieldDamaged( entity player, var damageInfo )
{
	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.mp_weapon_arc_bolt )
		return 1.0

	return file.shieldDamageScale
}

void function CreateTether_Thread( entity attacker, entity victim, entity inflictor )
{
	if ( !(inflictor in file.boltStateTable) )
		return

	EndSignal( victim, "OnDeath", "OnDestroy", "PlayerSkyDive", "StartPhaseShift", SIGNAL_TELEPORTED )

	entity owner = inflictor.GetOwner()

	bool wasPlanted = file.boltStateTable[ inflictor ].type == eBoltType.PLANTED
	bool useProjectilePos = wasPlanted || ( victim.IsPlayer() )

	vector tetherPos = useProjectilePos ? inflictor.GetOrigin() : victim.GetOrigin() + TETHER_SPAWN_OFFSET  // Slight height boost so it doesn't fall through geo below the player

	// Create the tether anchor entity
	entity tetherEnt = CreateEntity( "prop_physics" )
	tetherEnt.SetValueForModelKey( ARC_BOLT_TETHER_ANCHOR )
	tetherEnt.kv.spawnflags       = 0
	tetherEnt.kv.fadedist         = -1
	tetherEnt.kv.physdamagescale  = 0.1
	tetherEnt.kv.inertiaScale     = 1.0
	tetherEnt.kv.renderamt        = 255
	tetherEnt.kv.rendercolor      = "255 255 255"
	tetherEnt.SetOrigin( tetherPos )
	tetherEnt.SetScriptName( TETHER_SCRIPTNAME )
	tetherEnt.kv.CollisionGroup = TRACE_COLLISION_GROUP_DEBRIS
	tetherEnt.kv.CollideWithOwner = false
	tetherEnt.SetOwner( victim )
	tetherEnt.RemoveFromAllRealms()
	tetherEnt.AddToOtherEntitysRealms( victim )
	tetherEnt.e.ignoreJumpPad = true

	vector tetherVelocity = victim.GetVelocity()
	if ( victim.IsOnGround() || wasPlanted )
		tetherVelocity = <0, 0, 0>
	else
		tetherVelocity = < tetherVelocity.x, tetherVelocity.y, min( -60.0, tetherVelocity.z ) >

	tetherEnt.SetVelocity( tetherVelocity )
	tetherEnt.PhysicsSetDamping( 0.0, 100.0 )
	DispatchSpawn( tetherEnt )
	if ( !wasPlanted )
	{
		thread TetherAnchor_PlantOnFirstCollision( tetherEnt )
	}
	else
	{
		tetherEnt.SetAngles( inflictor.GetAngles() + <0, 180, 0> )	// TODO: This isn't quite right - probably an issue with how the angles are created from surface normal when planting
		if ( IsValid( inflictor.GetParent() ) )	// Being planted to world objects doesn't parent you to them
			tetherEnt.SetParent( inflictor.GetParent() )
		tetherEnt.DisablePhysics()
	}

	// Tether VFX
	array<entity> tetherFxArray
	{
		entity shockEnt = StartParticleEffectOnEntity_ReturnEntity( victim, GetParticleSystemIndex( ARC_BOLT_ZAP_FX ), FX_PATTACH_POINT_FOLLOW, victim.LookupAttachment( "CHESTFOCUS" ) )
		EffectSetControlPointEntity( shockEnt, 1, tetherEnt )
		shockEnt.SetOwner( victim )
		shockEnt.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
		tetherFxArray.append( shockEnt )
	}

	if ( file.boltStateTable[ inflictor ].type != eBoltType.PLANTED  )
	{
		entity shockConnectEnt = StartParticleEffectOnEntity_ReturnEntity( victim, GetParticleSystemIndex( ARC_BOLT_ZAP_CONNECT_FX ), FX_PATTACH_POINT_FOLLOW, victim.LookupAttachment( "CHESTFOCUS" ) )
		EffectSetControlPointEntity( shockConnectEnt, 0, victim )
		EffectSetControlPointVector( shockConnectEnt, 1, inflictor.GetOrigin() )
		tetherFxArray.append( shockConnectEnt )
	}

	{
		entity radiusFxEnt = StartParticleEffectOnEntity_ReturnEntity( tetherEnt, GetParticleSystemIndex( ARC_BOLT_TETHER_RADIUS_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		EffectSetControlPointVector( radiusFxEnt, 1, <file.tetherRadius, 0, 0> )
		EffectSetControlPointVector( radiusFxEnt, 2, <255, 0, 0> )
		SetTeam( radiusFxEnt, victim.GetTeam() )
		radiusFxEnt.SetOwner( victim )
		radiusFxEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY | ENTITY_VISIBLE_TO_OWNER
		tetherFxArray.append( radiusFxEnt )
	}

	entity ropeConnector1p
	array<entity> ropeFxArray
	{
		// 3p Rope (following a 2-rope pattern Lifeline's drone - even with visibility flags set to Everyone, this doesn't show up in 1p)
		entity ropeFxEnt = CreateRope( <0, 0, 0>, <0, 0, 0>, file.tetherRadius, tetherEnt, victim, 0, victim.LookupAttachment( "CHESTFOCUS" ), 1, $"models/cable/ash_arcbolt_chain_cable", 1 )
		ropeFxEnt.Rope_SetCanEnterRestingState( false )
		ropeFxEnt.SetOwner( victim )
		ropeFxEnt.RemoveFromAllRealms()
		ropeFxEnt.AddToOtherEntitysRealms( victim )
		ropeFxEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
		ropeFxArray.append( ropeFxEnt )

		// 1p Rope
		ropeConnector1p = CreateExpensiveScriptMover( tetherEnt.GetOrigin() )
		// ropeConnector1p.RenderWithViewModels( true ) - Doesn't seem needed but is called with Lifeline's drone's rope so keeping it around for now
		SetForceDrawWhileParented( ropeConnector1p, true )
		ropeConnector1p.SetParent( victim, "CHESTFOCUS" )
		entity rope1pFxEnt = CreateRope( <0, 0, 0>, <0, 0, 0>, file.tetherRadius, tetherEnt, ropeConnector1p, 0, 0, 1, $"models/cable/ash_arcbolt_chain_cable", 1 )
		rope1pFxEnt.Rope_SetCanEnterRestingState( false )
		rope1pFxEnt.SetOwner( victim )
		rope1pFxEnt.RemoveFromAllRealms()
		rope1pFxEnt.AddToOtherEntitysRealms( victim )
		rope1pFxEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
		ropeFxArray.append( rope1pFxEnt )
	}

	// Create the "gameplay" tether
	int tetherId = 1//victim.AddEntityUpdatedTether( tetherEnt, TETHER_HEALTH_BASE, file.healthDrainPerSec, TETHER_HEALTH_DRAIN_DELAY, TETHER_HEALTH_DRAIN_CUTOFF_PCT, file.tetherStretchDamageScale, file.tetherVelocityDamageScale, file.tetherRadius, "", "", "" )
	if ( victim.IsPlayer() )
		Remote_CallFunction_Replay( victim, FUNCNAME_NEW_TETHER, tetherId, tetherEnt )

	entity wp
	if ( IsValid( owner ) )
	{
		PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_ash_tactical_onHit" )
		if ( file.doOnHitPing )
		{
			//wp = CreateWaypoint_Ping_Location( owner, ePingType.ENEMY_TETHERED, tetherEnt, tetherEnt.GetOrigin(), -1, true )
			//wp.SetLocalOrigin( <-16,0,0> )
		}
	}

	float startTime = Time()

	OnThreadEnd(
		function() : ( victim, owner, tetherId, ropeConnector1p, tetherFxArray, ropeFxArray, tetherEnt, wp, startTime )
		{




















			if ( IsValid( tetherEnt ) )
			{
				StopSoundOnEntity( tetherEnt, ARC_BOLT_SOUND_TETHER_LOOP_FEEDBACK )
				StopSoundOnEntity( tetherEnt, ARC_BOLT_SOUND_TETHER_LOOP_3P )
				StopSoundOnEntity( tetherEnt, ARC_BOLT_SOUND_TETHER_LOOP_1P )
				StopSoundOnEntity( tetherEnt, ARC_BOLT_SOUND_TETHER_CONNECT_FEEDBACK )
				StopSoundOnEntity( tetherEnt, ARC_BOLT_SOUND_TETHER_CONNECT_3P )
				StopSoundOnEntity( tetherEnt, ARC_BOLT_SOUND_TETHER_CONNECT_1P )

				if ( IsValid( victim ) )
					EmitDifferentSoundsOnEntityForPlayerAndWorld( ARC_BOLT_SOUND_DAMAGE_BREAK_1P, ARC_BOLT_SOUND_DAMAGE_BREAK_3P, tetherEnt, victim )

				if ( IsValid( owner ) && Distance2DSqr( owner.GetOrigin(), tetherEnt.GetOrigin() ) > ARC_BOLT_SOUND_FEEDBACK_FALLOUT_DISTANCE_SQR )
					EmitSoundOnEntityOnlyToPlayer( tetherEnt, owner, ARC_BOLT_SOUND_DAMAGE_BREAK_FEEDBACK )

				thread DestroyAfterDelay( tetherEnt, 2.0 )
			}

			if ( IsValid( victim ) )
			{
				if ( victim.IsPlayer() )
					SetCanDoDamageCallout( victim, true )

				if ( victim.IsValidTetherID( tetherId ) )
					victim.RemoveTether( tetherId )
			}

			foreach ( fx in tetherFxArray )
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}

			foreach ( rope in ropeFxArray )
			{
				if ( IsValid( rope ) )
					rope.Destroy()
			}

			if ( IsValid( ropeConnector1p ) )
				ropeConnector1p.Destroy()

			if ( IsValid( wp ) )
				wp.Destroy()

			float timeElapsed = Time() - startTime
			printt( "Tether removed, time elapsed: " + timeElapsed )
		}
	)

	if ( IsValid( victim ) )
	{
		if ( victim.IsPlayer() )
		{
			PlayBattleChatterLineToSpeakerAndTeam( victim, "bc_imSnared" )
			SetCanDoDamageCallout( victim, false )
		}

		EmitDifferentSoundsOnEntityForPlayerAndWorld( ARC_BOLT_SOUND_TETHER_CONNECT_1P, ARC_BOLT_SOUND_TETHER_CONNECT_3P, victim, victim )
		if ( IsValid( owner ) )
			EmitSoundOnEntityOnlyToPlayer( victim, owner, ARC_BOLT_SOUND_TETHER_CONNECT_FEEDBACK )
	}

	if ( IsValid( tetherEnt ) )
	{
		EmitDifferentSoundsOnEntityForPlayerAndWorld( ARC_BOLT_SOUND_TETHER_LOOP_1P, ARC_BOLT_SOUND_TETHER_LOOP_3P, tetherEnt, victim )
		if ( IsValid( owner ) )
			EmitSoundOnEntityOnlyToPlayer( tetherEnt, owner, ARC_BOLT_SOUND_TETHER_LOOP_FEEDBACK )
	}

	thread TrackTetherHealthForAudio_Thread( victim, owner, tetherEnt, tetherId )


	if( PlayerHasPassive( attacker, ePassives.PAS_TAC_UPGRADE_ONE ) ) //upgrade_ash_longer_tac_duration
	{
		thread TetherTimeOut( attacker, victim )
	}
	else

	{
		CleanUpBolt( inflictor )
		thread TetherTimeOut( attacker, victim )
	}

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ASH_ENEMY_TETHERED, victim, tetherEnt.GetOrigin(), victim.GetTeam(), victim )

	while ( true )
	{
		table tetherData    = WaitSignal( victim, SIGNAL_TETHER_REMOVED )

		if ( !victim.IsValidTetherID( tetherId ) )
			return
	}
}


void function TetherTimeOut( entity attacker, entity victim )
{
	if( !IsValid( attacker ) )
		return

	wait( GetBoltLifetime( attacker ) )

	if( !IsValid( victim ) )
		return
	victim.Signal( SIGNAL_TETHER_REMOVED )
}


void function TetherAnchor_PlantOnFirstCollision( entity physicsEnt )
{
	Assert( IsValid( physicsEnt ) )
	physicsEnt.EndSignal( "OnDestroy" )

	// If it's already close to geo, just plant it there.
	TraceResults lineTrace = TraceLine( physicsEnt.GetOrigin(), physicsEnt.GetOrigin() - TETHER_SPAWN_OFFSET * 1.5,GetPlayerArray() )
	bool plantSuccessful = false
	if ( lineTrace.fraction < 1.0 )
	{
		DeployableCollisionParams cp
		cp.normal = lineTrace.surfaceNormal
		cp.hitEnt = lineTrace.hitEnt
		cp.pos    = lineTrace.endPos

		plantSuccessful = PlantStickyEntity( physicsEnt, cp, ZERO_VECTOR, true )
	}
	if ( plantSuccessful )
	{
		physicsEnt.DisablePhysics()
		return
	}

	physicsEnt.WaitSignal( "OnFirstCollision" )
	if ( IsValid( physicsEnt ) )
	{
		TraceResults hullTrace = TraceHull( physicsEnt.GetOrigin(), physicsEnt.GetOrigin(), <-3,-3,-3>, <3,3,3>, GetPlayerArray() )
		if ( IsValid( hullTrace.hitEnt ) )
		{
			DeployableCollisionParams cp
			cp.normal = hullTrace.startSolid ? UP_VECTOR : hullTrace.surfaceNormal
			cp.hitEnt = hullTrace.hitEnt
			cp.pos    = hullTrace.endPos

			PlantStickyEntity( physicsEnt, cp, ZERO_VECTOR, true )
		}
		physicsEnt.DisablePhysics()
	}
}

void function TrackTetherHealthForAudio_Thread( entity victim, entity tetherPlayer, entity tetherEnt, int tetherId )
{
	EndSignal( tetherEnt, "OnDestroy" )
	EndSignal( victim, "OnDestroy" )

	float prevTetherHealth = 10.0

	wait 0.2

	float nextSoundTime = Time()
	while( true )
	{
		if ( !victim.IsValidTetherID( tetherId ) )
			return

		float curTetherHealth = 10.0
		float healthDiff = prevTetherHealth - curTetherHealth

		tetherEnt.SetSoundCodeControllerValue( curTetherHealth / TETHER_HEALTH_BASE )

		prevTetherHealth = 10.0
		WaitFrame()
	}
}
#endif

#if CLIENT
void function ArcBolt_ServerToClient_NewTetherAdded( int tetherID, entity tetherEnt )
{
	entity player = GetLocalViewPlayer()

	if ( IsValid( player ) && IsValid( tetherEnt ) )
	{
		file.affectedTethers.append( tetherID )
		Signal( player, SIGNAL_TETHER_CREATED )

		thread TetherScreenEffects_Thread( player, tetherID, tetherEnt )
		thread TetherDirectionalEffect_Thread( player, tetherID, tetherEnt )
	}
}

void function TetherScreenEffects_Thread( entity player, int tetherID, entity tetherEnt )
{
	EndSignal( player, "OnDeath", "OnDestroy")
	int tetheredScreenFx = StartParticleEffectOnEntity( player, GetParticleSystemIndex( ARC_BOLT_TETHER_SCREEN_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	OnThreadEnd(
		function() : ( tetheredScreenFx )
		{
			EffectStop( tetheredScreenFx, true, true )
		}
	)

	WaitFrame()

	while ( true )
	{
		if ( !file.affectedTethers.contains( tetherID ) || !IsValid( tetherEnt ) )
			return

		float dist = DistanceSqr( player.GetOrigin(), tetherEnt.GetOrigin() )
		if ( dist > file.tetherRadiusSqr )
			EffectSetControlPointVector( tetheredScreenFx, 1, <100, 0, 0> )
		else
			EffectSetControlPointVector( tetheredScreenFx, 1, <25, 0, 0> )

		WaitFrame()
	}
}

void function TetherDirectionalEffect_Thread( entity player, int tetherID, entity tetherEnt )
{
	EndSignal( player, "OnDeath", "OnDestroy")
	EndSignal( tetherEnt, "OnDestroy" )

	// Don't spawn effects yet if too many tethers on us
	while ( file.affectedTethers.len() > 2 )
	{
		WaitFrame()
	}

	int tetherDirectionalIndicator = StartParticleEffectOnEntity( player, GetParticleSystemIndex( ARC_BOLT_TETHER_INDICATOR_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	OnThreadEnd(
		function() : ( tetherDirectionalIndicator )
		{
			EffectStop( tetherDirectionalIndicator, true, true )
		}
	)

	float i = 0
	while ( true )
	{
		bool tetherIsAttached = false
		foreach ( tether in file.affectedTethers )
		{
			if ( tether == tetherID )
			{
				tetherIsAttached = true
				break
			}
		}

		if ( !tetherIsAttached || !EffectDoesExist( tetherDirectionalIndicator ) )
			return

		vector playerToTether = tetherEnt.GetOrigin() - player.GetOrigin()

		vector playerToTetherAngles = VectorToAngles( FlattenVec( playerToTether ) )
		playerToTetherAngles -= <0, 180.0, 0>

		vector eyeAngles = player.EyeAngles()
		eyeAngles = FlattenAngles( eyeAngles )

		vector fxAngle = playerToTetherAngles - eyeAngles + <0, 90, 0>
		fxAngle.y = AngleNormalize( fxAngle.y )
		if ( fabs( fxAngle.y + 90.0 ) < 70.0 )
			fxAngle.y = fxAngle.y > -90.0 ? -20.0 : -160.0

		EffectSetControlPointAngles( tetherDirectionalIndicator, 10, fxAngle )
		EffectSetControlPointVector( tetherDirectionalIndicator, 4, tetherEnt.GetOrigin() )

		float tetherHealth = 10.0
		tetherHealth =  tetherHealth / TETHER_HEALTH_BASE
		EffectSetControlPointVector( tetherDirectionalIndicator, 1, <tetherHealth * 70.0 + 30.0, 0, 0> )

		WaitFrame()
	}
}

void function ArcBolt_ServerToClient_TetherRemoved( int tetherID )
{
	file.affectedTethers.removebyvalue( tetherID )
}

void function OnWaypointCreated( entity wp )
{
	/*if ( !IsValid( wp ) || Waypoint_GetPingTypeForWaypoint( wp ) != ePingType.ENEMY_TETHERED )
		return

	thread RemoveWaypointPopout( wp )*/
}

void function RemoveWaypointPopout( entity wp )
{
	// Our callback runs before the main OnWaypointCreated callback that sets doCenterOffset to true, so need to wait
	WaitFrame()

	if ( IsValid( wp ) && wp.wp.ruiHud != null )
		RuiSetBool( wp.wp.ruiHud, "doCenterOffset", false )
}

void function ArcBolt_OnPropScriptCreated( entity ent )
{
	// Client side management of threat indicators once bolt is planted (to allow turning on/off per player after being tethered).
	if ( ent.GetScriptName() == TETHER_TRAP_SCRIPTNAME )
	{
		thread ManagePlantedBoltThreatIndicator_Thread( ent )
	}
}

void function ManagePlantedBoltThreatIndicator_Thread( entity bolt )
{
	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	entity owner = bolt.GetOwner()
	vector position = bolt.GetOrigin()

	if ( !IsValid( owner ) )
		return

	if ( IsFriendlyTeam( localPlayer.GetTeam(), owner.GetTeam() ) )
		return

	EndSignal( bolt, "OnDestroy" )
	EndSignal( localPlayer, SIGNAL_TETHER_CREATED )

	entity dummyProp = CreateClientSidePropDynamic( position, bolt.GetAngles(), $"mdl/dev/empty_model.rmdl" )
	dummyProp.SetScriptName( ARCBOLT_THREAT_INDICATOR_SCRIPTNAME )
	ShowGrenadeArrow( GetLocalViewPlayer(), dummyProp, 256.0, 0, true )

	OnThreadEnd(
		function() : ( dummyProp )
		{
			if ( IsValid( dummyProp ) )
			{
				dummyProp.Destroy()
			}
		}
	)

	wait GetBoltLifetime( owner )
}
#endif

#if SERVER
void function CodeCallback_OnTetherRemoveApex( entity victim, int removedTetherID )
{
	// I could send the removed tether ID with this signal, but if two tethers die at the same time then WaitSignal in the tether threads only receive 1
	// Checking victim.IsValidTetherID() works reliably, even with multiple tethers attached to the same person being removed at the same time
	// R5DEV-309620 was opened to look into the signal issue.
	Signal( victim, SIGNAL_TETHER_REMOVED )
	if ( victim.IsPlayer() )
	{
		Remote_CallFunction_Replay( victim, FUNCNAME_REMOVED_TETHER, removedTetherID )
	}
}

entity function CreateProjectileBoltThreatIndicator( entity bolt, int type, entity owner )
{
	if ( type == eBoltType.PROJECTILE )
	{
		vector warningOffset = bolt.GetForwardVector() * 350.0
		entity indicator = CreateThreatIndicator( bolt.GetOrigin() + warningOffset, eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, 512.0, -warningOffset, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ENEMIES, owner )
		indicator.RemoveFromAllRealms()
		indicator.AddToOtherEntitysRealms( bolt )
		indicator.SetParent( bolt )
		return indicator
	}
	unreachable
}

void function CleanUpBolt( entity bolt )
{
	if ( IsValid( bolt ) )
	{
		if ( bolt in file.boltStateTable )
		{
			boltState state = file.boltStateTable[ bolt ]

			if ( IsValid( state.threatIndicator ) )
				state.threatIndicator.Destroy()

			delete file.boltStateTable[ bolt ]
		}

		bolt.Destroy()
	}
}

bool function ArcBolt_IsBoltPlanted( entity bolt )
{
	if ( !(bolt in file.boltStateTable) )
		return false

	return file.boltStateTable[bolt].type == eBoltType.PLANTED
}
#endif