global function MpWeaponBlackHole_Init
global function OnWeaponTossPrep_weapon_black_hole
global function OnWeaponPrimaryAttack_weapon_black_hole
global function OnWeaponDeactivate_weapon_black_hole
global function OnProjectileCollision_weapon_black_hole

#if SERVER
global function BlackHole_GetBlackHoleInRangeOfEntity
#endif

global const string BLACKHOLE_PROP_SCRIPTNAME = "newt_blackhole"
const string BLACKHOLE_MOVER_SCRIPTNAME = "newt_blackhole_mover"
global const string BLACKHOLE_THREAT_TARGETNAME = "newt_blackhole_threat"
global const string BLACKHOLE_WEAPON_CLASS_NAME = "mp_ability_horizon_black_hole"

//TROPHY FX VARS
const asset BLACKHOLETROPHY_DESTROY_FX = $"P_newt_exp"
const asset BLACKHOLETROPHY_DAMAGE_SPARK_FX = $"P_newt_dmg"
const asset BLACKHOLETROPHY_DAMAGE_ADD_FX = $"P_newt_dmg2"

//BLACK HOLE FX MAIN
const BLACKHOLE_START_FX = $"Sub_P_black_hole_START"
const BLACKHOLE_MAIN_FX = $"P_wpn_black_hole_main"

const BLACKHOLE_SWIRLING_BLACKHOLE_FX = $"P_wpn_grenade_gravity"

//BLACK HOLE 1P
int BLACKHOLE_1P_SCREEN_FX_ID
const asset BLACKHOLE_1P_SCREEN_FX = $"P_black_hole_1p"
int BLACKHOLE_1P_SCREEN_OTHER_FX_ID
const asset BLACKHOLE_1P_SCREEN_OTHER_FX = $"P_black_hole_1p"

const asset BLACKHOLE_PREVIEW_RING_FX = $"P_wpn_black_hole_preview"

//BLACK HOLE NEWT FX
const BLACKHOLE_NEWT_THRUSTER_FX = $"P_newt_thruster"
const BLACKHOLE_NEWT_THRUSTER_LIGHT_FX = $"P_newt_thruster_main_light"

const float BLACKHOLE_NEWT_DAMAGE_FX_INTERVAL = 0.25

//TROPHY MODEL VARS
const asset BLACKHOLETROPHY_MODEL = $"mdl/props/nova_trophy_system/nova_trophy_system.rmdl"

//TROPHY SOUNDS
const string BLACKHOLETROPHY_SOUND_DESTROY = "Nova_Ultimate_Destroy"
const string BLACKHOLETROPHY_SOUND_DAMAGE = "Nova_Ultimate_NewT_Damage"

const string BLACKHOLE_SOUND_PLAYER_INSIDE_1P = "Nova_Ultimate_BlackHole_Inside_Sustain_1P"

//blackhole sounds
const string BLACKHOLE_SOUND_PHASE_1 = "Nova_Ultimate_BlackHole_Phase1"
const string BLACKHOLE_SOUND_PHASE_2 = "Nova_Ultimate_BlackHole_Phase2"
const string BLACKHOLE_SOUND_PHASE_3 = "Nova_Ultimate_BlackHole_Phase3"
const string BLACKHOLE_SOUND_PHASE_4 = "Nova_Ultimate_BlackHole_Phase4"
const string BLACKHOLE_SOUND_PHASE_1_UPGRADE = "Nova_Ultimate_BlackHole_Phase1_QuickPull"

//NEWT TUNING
const float NEWT_THROWFORCE_MULT = 1
const float NEWT_BOUNCEFORCEMULT = 0.5
      
//NOVA GRAVITY TUNING
const bool BLACKHOLE_DEBUG = false
const bool BLACKHOLE_DEBUG_DRONES = false
const bool BLACKHOLE_DEBUG_TRACE = false
const bool BLACKHOLE_DEBUG_SIZE = false
const bool BLACKHOLE_DEBUG_VORTEX = false

const float BLACKHOLE_TROPHY_HEALTH_AMOUNT = 175
const float BLACKHOLE_TROPHY_HEALTH_AMOUNT_UPGRADED = 90
const float BLACKHOLE_TUNING_RADIUS = 200
const int BLACKHOLE_TUNING_ABOVE_HEIGHT = 200
const int BLACKHOLE_TUNING_BELOW_HEIGHT = 200
const float BLACKHOLE_TUNING_INNER_RADIUS = 100

const float BLACKHOLE_TUNING_PROJECTILE_PULL_SPEED = 40.0

const float BLACKHOLE_TUNING_CODE_PULL_OUTER_SPEED = 300
const float BLACKHOLE_TUNING_CODE_PULL_INNER_SPEED = 400
const float BLACKHOLE_TUNING_CODE_MOVE_OUTER_SPEED = 85
const float BLACKHOLE_TUNING_CODE_MOVE_INNER_SPEED = 135

const float BLACKHOLE_TUNING_DEATHFIELD_DAMAGE_SCALAR = 1.0
const float BLACKHOLE_TUNING_TAKE_EXPLOSIVE_DAMAGE_MULTIPLIER = 1.5

const float BLACKHOLE_TUNING_ACTIVATION_TIME = 1.75
const float BLACKHOLE_TUNING_ACTIVATION_TIME_UPGRADED = 0.9
const float BLACKHOLE_TUNING_DESTROY_REFUND = 0.25
      
const float BLACKHOLE_TUNING_PULL_ACTIVATION_FX_LEAD_TIME = 1.0
const float BLACKHOLE_TUNING_START_FX_STOP_OFFSET = 0.0
const float BLACKHOLE_TUNING_PULL_TIME = 0.8
const float BLACKHOLE_TUNING_STABLE_TIME = 10
const float BLACKHOLE_TUNING_DOOR_CHECK_DELAY = 0.3

const float GRAVITY_PULL_TRAVEL_TIME = 1.2 
const float GRAVITY_PULL_HEIGHT_OFFSET = 0

const float GRAVITY_POP_DELAY = 1
const float GRAVITY_HOLD_RADIUS = 40.0 

const float GRAVITY_PLAYER_PULL_STRENGTH = 130.0
const float GRAVITY_PLAYER_AIR_FRICTION = 0.80
const float GRAVITY_GROUND_LIFT = 25.0  //sad attempt at fixing the stutter, doesnt do much

const float GRAVITY_TEAMMATE_PULL_STRENGTH = 100.0

struct
{
	#if SERVER
		table < entity, float >       lastDamageFxTime
		table < entity, bool >        fullBlackholeEffectsActive
		table<entity, array<entity> > inBlackholeHistoryObjects
	#endif
} file

void function MpWeaponBlackHole_Init()
{
	PrecacheParticleSystem( BLACKHOLETROPHY_DESTROY_FX )
	PrecacheParticleSystem( BLACKHOLETROPHY_DAMAGE_SPARK_FX )
	PrecacheParticleSystem( BLACKHOLETROPHY_DAMAGE_ADD_FX )
	BLACKHOLE_1P_SCREEN_FX_ID = PrecacheParticleSystem( BLACKHOLE_1P_SCREEN_FX )

	PrecacheParticleSystem( BLACKHOLE_SWIRLING_BLACKHOLE_FX )
	PrecacheParticleSystem( BLACKHOLE_NEWT_THRUSTER_FX )
	PrecacheParticleSystem( BLACKHOLE_NEWT_THRUSTER_LIGHT_FX )
	BLACKHOLE_1P_SCREEN_OTHER_FX_ID = PrecacheParticleSystem( BLACKHOLE_1P_SCREEN_OTHER_FX )

	PrecacheParticleSystem( BLACKHOLE_START_FX )
	PrecacheParticleSystem( BLACKHOLE_MAIN_FX )
	PrecacheModel( BLACKHOLETROPHY_MODEL )

	#if SERVER
		RegisterSignal( "Trophy_Deploy" )
		RegisterSignal( "BLACKHOLE_StopEffect" )
	#endif //SERVER

	#if CLIENT
		RegisterSignal( "Blackhole_Stop1PFXSignal" )

		StatusEffect_RegisterEnabledCallback( eStatusEffect.in_black_hole_field, Blackhole_Start1PFX )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.in_black_hole_field, Blackhole_Stop1PFX )

		AddTargetNameCreateCallback( BLACKHOLE_THREAT_TARGETNAME, AddBlackholeThreatIndicator )
		AddCallback_ModifyDamageFlyoutForScriptName( BLACKHOLE_PROP_SCRIPTNAME, BlackHole_OffsetDamageNumbersLower )

	#endif //CLIENT
}
                    
float function GetUpgradedActivationTime()
{
	return GetCurrentPlaylistVarFloat( "horizon_upgraded_blackhole_activation_time", BLACKHOLE_TUNING_ACTIVATION_TIME_UPGRADED )
}

float function GetUpgradedTrophyHealth()
{
	return GetCurrentPlaylistVarFloat( "horizon_upgraded_blackhole_health", BLACKHOLE_TROPHY_HEALTH_AMOUNT_UPGRADED )
}

float function GetUpgradedTrophyDestroyRefund()
{
	return GetCurrentPlaylistVarFloat( "horizon_upgraded_blackhole_destroy_refund", BLACKHOLE_TUNING_DESTROY_REFUND )
}
      
float function GetActivationTime( entity player )
{
	float result = BLACKHOLE_TUNING_ACTIVATION_TIME
		//if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_TWO ) ) 
		//	result = GetUpgradedActivationTime()
       
	return result
}

string function GetActivationSFX( entity player )
{
	string result = BLACKHOLE_SOUND_PHASE_1
		//if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_TWO ) ) 
		//	result = BLACKHOLE_SOUND_PHASE_1_UPGRADE
       
	return result
}

float function GetTrophyHealth( entity player )
{
	float result = BLACKHOLE_TROPHY_HEALTH_AMOUNT
		//if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_TWO ) ) 
		//	result = GetUpgradedTrophyHealth()
       
	return result
}

float function GetBlackholeRadius( entity player )
{
	return BLACKHOLE_TUNING_RADIUS
}

void function OnWeaponTossPrep_weapon_black_hole( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )

	#if CLIENT
		thread ShowBlackHoleRadius( weapon )
	#endif
}

#if CLIENT
void function ShowBlackHoleRadius( entity weapon )
{
	EndSignal( weapon, "OnDestroy" )
	wait 0.2
	int fxHandle
	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( fxHandle != -1 )
				EffectStop( fxHandle, true, false )
		}
	)
}

vector function BlackHole_OffsetDamageNumbersLower( entity newt, vector damageFlyoutPosition )
{
	return ( damageFlyoutPosition - < 0, 0, newt.GetBoundingMaxs().z/2.0 > )
}
#endif

var function OnWeaponPrimaryAttack_weapon_black_hole( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	int ammoReq        = weapon.GetAmmoPerShot()
	Assert( ownerPlayer.IsPlayer() )

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = attackParams.pos
	
	fireGrenadeParams.vel = attackParams.dir * NEWT_THROWFORCE_MULT
	fireGrenadeParams.angVel = <0, 0, 600> 
	fireGrenadeParams.fuseTime = 100.0 
	fireGrenadeParams.scriptTouchDamageType = damageTypes.projectileImpact
	fireGrenadeParams.scriptExplosionDamageType = damageTypes.explosive
	fireGrenadeParams.clientPredicted = true
	fireGrenadeParams.lagCompensated = true
	fireGrenadeParams.useScriptOnDamage = true
	
	entity projectile = weapon.FireWeaponGrenade( fireGrenadeParams )
	
	if ( IsValid( projectile ) )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, projectile )

		#if SERVER
			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( projectile, projectileSound )

			weapon.w.lastProjectileFired = projectile

			int thrusterFXID = GetParticleSystemIndex( BLACKHOLE_NEWT_THRUSTER_FX )
			StartParticleEffectOnEntityWithPos_ReturnEntity( projectile, thrusterFXID, FX_PATTACH_POINT_FOLLOW, projectile.LookupAttachment( "thruster1" ), <0, 0, 0>, <90, 0, 0> )
			StartParticleEffectOnEntityWithPos_ReturnEntity ( projectile, thrusterFXID, FX_PATTACH_POINT_FOLLOW, projectile.LookupAttachment( "thruster2" ), <0, 0, 0>, <90, 0, 0> )
			StartParticleEffectOnEntityWithPos_ReturnEntity ( projectile, thrusterFXID, FX_PATTACH_POINT_FOLLOW, projectile.LookupAttachment( "thruster3" ), <0, 0, 0>, <90, 0, 0> )

		#endif
	}

	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( weapon.GetOwner(), "bc_super" )
	#endif

	return ammoReq
}

void function OnWeaponDeactivate_weapon_black_hole( entity weapon )
{
	#if CLIENT
		if ( weapon.GetWeaponOwner() != GetLocalViewPlayer() )
			return
	#endif
}

void function OnProjectileCollision_weapon_black_hole( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if ( normal.z < 0.7 )
	{
		#if SERVER
			vector velocity = projectile.GetVelocity()
			vector bounceVel = velocity - 2 * DotProduct(velocity, normal) * normal
			projectile.SetVelocity( (bounceVel * NEWT_BOUNCEFORCEMULT) + (normal * 50) )
		#endif
		
		return 
	}

	bool didStick = PlantSuperStickyGrenade( projectile, pos, normal, hitEnt, hitbox )
	if ( !didStick )
		return

	#if SERVER
		if ( projectile.IsMarkedForDeletion() )
			return
			
		entity projOwner = projectile.GetOwner()
		entity parentTo = projectile.GetParent()
		
		vector surfaceAngles = projectile.proj.savedAngles
		TraceResults traceResult = TraceLine( pos, pos - normal * 32, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )
		}
		
		if ( IsValid( projectile ) )
			projectile.Destroy()
			
		vector adjustedPos = pos - <0, 0, 8.0>
			
		thread BLACKHOLE_MainLifetimeThread( projOwner, adjustedPos, surfaceAngles, parentTo )
	#endif
}

#if SERVER
entity function BlackHole_GetBlackHoleInRangeOfEntity( entity ent, bool requireEnemy = false )
{
	foreach( newtProp, entArray in file.inBlackholeHistoryObjects )
	{
		if ( !IsValid ( newtProp ) )
			continue

		if ( requireEnemy && IsFriendlyTeam( newtProp.GetTeam(), ent.GetTeam() ) )
			continue

		if ( Distance( newtProp.GetOrigin(), ent.GetOrigin() ) <= GetBlackholeRadius( newtProp.GetOwner() ) )
			return newtProp
	}
	return null
}

entity function CreateNewtProp( entity owner, vector origin, vector angles, entity parentTo )
{
	bool ownerIsValid = IsValid( owner )

	entity newtProp = CreatePropScript( BLACKHOLETROPHY_MODEL, origin, angles, SOLID_CYLINDER )
	newtProp.kv.collisionGroup = TRACE_COLLISION_GROUP_PLAYER

	if ( ownerIsValid )
	{
		newtProp.SetOwner( owner )
		newtProp.SetBossPlayer( owner )
		SetTeam( newtProp, owner.GetTeam() )
	}

	float blackholeHealthAmount = GetCurrentPlaylistVarFloat( "blackhole_trophy_health_amount", GetTrophyHealth( owner ) )

	newtProp.DisableHibernation()
	newtProp.SetMaxHealth( blackholeHealthAmount )
	newtProp.SetHealth( blackholeHealthAmount )
	newtProp.SetTakeDamageType( DAMAGE_YES )
	newtProp.SetDamageNotifications( true )
	newtProp.SetDeathNotifications( true )
	newtProp.SetArmorType( ARMOR_TYPE_HEAVY )
	newtProp.SetScriptName( BLACKHOLE_PROP_SCRIPTNAME )
	newtProp.SetBlocksRadiusDamage( false )
	newtProp.SetTouchTriggers( true ) 
	newtProp.SetPhysics( MOVETYPE_FLY ) 
	newtProp.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD ) 

	if ( ownerIsValid )
	{
		//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_BLACK_HOLE, owner, newtProp.GetOrigin(), owner.GetTeam(), owner )
	}

	newtProp.SetCanBeMeleed( true )
	SetVisibleEntitiesInConeQueriableEnabled( newtProp, false )
	if ( ownerIsValid )
	{
		thread TrapDestroyOnRoundEnd( owner, newtProp )
		AddToUltimateRealm( owner, newtProp )
	}

	newtProp.Highlight_Enable()
	AddSonarDetectionForPropScript( newtProp )
	AddEMPDamageDevice( newtProp )

	newtProp.e.noOwnerFriendlyFire      = true
	newtProp.e.noFriendlyFireProtection = true
	newtProp.e.canBeDamagedFromGas      = false
	newtProp.e.canBurn                  = true
	newtProp.e.isBusy                   = true

	newtProp.DisableHibernation()

	AddEntityCallback_OnDamaged( newtProp, BLACKHOLE_NEWT_OnDamaged )
	AddEntityCallback_OnPostDamaged( newtProp, BLACKHOLE_NEWT_OnPostDamaged )
	AddEntityCallback_OnKilled( newtProp, BLACKHOLE_NEWT_OnKilled )

	return newtProp
}
void function BLACKHOLE_MainLifetimeThread( entity owner, vector origin, vector angles, entity parentTo )
{
	entity newtProp = CreateNewtProp( owner, origin, angles, parentTo )

	entity mover
	if ( parentTo != null )
	{
		mover = CreateScriptMover_NEW( BLACKHOLE_MOVER_SCRIPTNAME, origin, angles )
		mover.RemoveFromAllRealms()
		mover.AddToOtherEntitysRealms( parentTo )
		mover.SetParent( parentTo )

		newtProp.RemoveFromAllRealms()
		newtProp.AddToOtherEntitysRealms( mover )
		newtProp.SetParent( mover )
	}
	else
	{
		mover = newtProp
	}

	file.lastDamageFxTime[newtProp] <- Time()
	file.fullBlackholeEffectsActive[newtProp] <- false
	file.inBlackholeHistoryObjects[newtProp] <- []

	newtProp.Anim_PlayOnly( "prop_trophy_idle_closed" )
	newtProp.EndSignal( "OnDestroy" )

	entity blackholeThreatProp = CreatePropScript( EMPTY_MODEL, origin, angles, 0, 320000 )

	blackholeThreatProp.RemoveFromAllRealms()
	blackholeThreatProp.AddToOtherEntitysRealms( newtProp )
	blackholeThreatProp.SetParent( newtProp )
	SetTargetName( blackholeThreatProp, BLACKHOLE_THREAT_TARGETNAME )

	vector pingOrigin   = origin + newtProp.GetUpVector() * 55
	entity traceBlocker = CreateTraceBlockerVolume( pingOrigin, 64.0, false, CONTENTS_BLOCK_PING, newtProp.GetTeam(), BLACKHOLE_PROP_SCRIPTNAME )

	array<entity> newtPropFXArray
	entity swirlingBlackHoleFXID = StartParticleEffectOnEntityWithPos_ReturnEntity ( newtProp, GetParticleSystemIndex( BLACKHOLE_SWIRLING_BLACKHOLE_FX ), FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "BLACKHOLE_FX" ), <0, 0, 0>, ZERO_VECTOR )

	int thrusterFXID   = GetParticleSystemIndex( BLACKHOLE_NEWT_THRUSTER_FX )
	entity thruster1FX = StartParticleEffectOnEntityWithPos_ReturnEntity ( newtProp, thrusterFXID, FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "thruster1" ), <0, 0, 0>, <90, 0, 0> )
	entity thruster2FX = StartParticleEffectOnEntityWithPos_ReturnEntity ( newtProp, thrusterFXID, FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "thruster2" ), <0, 0, 0>, <90, 0, 0> )
	entity thruster3FX = StartParticleEffectOnEntityWithPos_ReturnEntity ( newtProp, thrusterFXID, FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "thruster3" ), <0, 0, 0>, <90, 0, 0> )

	int thrusterLightFXID  = GetParticleSystemIndex( BLACKHOLE_NEWT_THRUSTER_LIGHT_FX )
	entity thrusterLightFX = StartParticleEffectOnEntityWithPos_ReturnEntity ( newtProp, thrusterLightFXID, FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "core" ), <0, 0, 0>, <90, 0, 0> )
	newtPropFXArray.append( thruster1FX )
	newtPropFXArray.append( thruster2FX )
	newtPropFXArray.append( thruster3FX )
	newtPropFXArray.append( thrusterLightFX )


	int blackHoleStartFXID  = GetParticleSystemIndex( BLACKHOLE_START_FX )
	entity blackHoleStartFX = StartParticleEffectOnEntityWithPos_ReturnEntity( newtProp, blackHoleStartFXID, FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "BLACKHOLE_FX" ), <0, 0, 0>, <90, 0, 0> )
	EffectSetControlPointVector( blackHoleStartFX, 1, < GetBlackholeRadius( newtProp.GetOwner() ) , 0, 255> )
	EffectSetControlPointVector( blackHoleStartFX, 2, <50, 40, 125> )
	newtPropFXArray.append( blackHoleStartFX )
	thread BlackholeStartFXLifetimeThread( owner, blackHoleStartFX )
	entity vortexCylinder

	OnThreadEnd(
		function() : ( newtProp, mover, vortexCylinder, newtPropFXArray, traceBlocker )
		{
			delete file.lastDamageFxTime[newtProp]
			delete file.fullBlackholeEffectsActive[newtProp]
			delete file.inBlackholeHistoryObjects[newtProp]

			foreach ( fx in newtPropFXArray )
			{
				if ( IsValid( fx ) )
				{
					EffectSetControlPointVector( fx, 1, <0, 0, 0> )
					EffectStop( fx )
					fx.Destroy()
				}
			}

			if ( IsValid( mover ) )
				mover.Destroy()

			if ( IsValid( vortexCylinder ) )
				vortexCylinder.Destroy()

			if ( IsValid( traceBlocker ) )
				traceBlocker.Destroy()
		}
	)

	thread NewtExpandAnimThread( newtProp, mover )

	EmitSoundOnEntity( newtProp, GetActivationSFX( owner ) )

	wait GRAVITY_POP_DELAY

	int blackHoleMainFXID
	blackHoleMainFXID = GetParticleSystemIndex( BLACKHOLE_MAIN_FX )

	entity blackHoleMainFX = StartParticleEffectOnEntityWithPos_ReturnEntity( newtProp, blackHoleMainFXID, FX_PATTACH_POINT_FOLLOW, newtProp.LookupAttachment( "BLACKHOLE_FX" ), <0, 0, 0>, <90, 0, 0> )
	EffectSetControlPointVector( blackHoleMainFX, 1, < GetBlackholeRadius( newtProp.GetOwner() ) , 0, 255> )
	EffectSetControlPointVector( blackHoleMainFX, 2, <255, 0, 0> )
	newtPropFXArray.append( blackHoleMainFX )
	EmitSoundOnEntity( newtProp, BLACKHOLE_SOUND_PHASE_2 )

	if ( IsValid( blackholeThreatProp ) )
		blackholeThreatProp.Destroy()

	file.fullBlackholeEffectsActive[newtProp] = true
	//Highlight_SetOwnedHighlight( newtProp, "nova_blackhole_newt" )
	//Highlight_SetFriendlyHighlight( newtProp, "nova_blackhole_newt" )
	//Highlight_SetEnemyHighlight( newtProp, "nova_blackhole_newt" )

	newtProp.e.isBusy = false
	vortexCylinder    = CreateBlackholeVortexTrigger( newtProp, owner, GetBlackholeRadius( newtProp.GetOwner() ), BLACKHOLE_TUNING_ABOVE_HEIGHT )
	
	waitthread BLACKHOLE_PullTriggerThread( newtProp, blackHoleMainFX )

	Highlight_ClearOwnedHighlight( newtProp )
	Highlight_ClearFriendlyHighlight( newtProp )
	Highlight_ClearEnemyHighlight( newtProp )

	EffectStop( swirlingBlackHoleFXID )
	EffectStop( blackHoleMainFX )
	EmitSoundOnEntity( newtProp, BLACKHOLE_SOUND_PHASE_4 )
	file.fullBlackholeEffectsActive[newtProp] = false

	if ( IsValid( thruster1FX ) )
		EffectStop( thruster1FX )
	if ( IsValid( thruster2FX ) )
		EffectStop( thruster2FX )
	if ( IsValid( thruster3FX ) )
		EffectStop( thruster3FX )

	waitthread BLACKHOLE_NewtPowerDown( newtProp, mover )
}

void function NewtExpandAnimThread( entity newtProp, entity mover )
{
	EndSignal( newtProp, "OnDestroy" )
	waitthread PlayAnim( newtProp, "prop_trophy_expand", mover )
	thread PlayAnim( newtProp, "prop_trophy_idle_open", mover )
}

void function BlackholeStartFXLifetimeThread( entity owner, entity blackholeStartFx )
{
	float blackholeActivationTime = GetCurrentPlaylistVarFloat( "blackhole_activation_time", GetActivationTime( owner ) )
	float lifeTime                = max( blackholeActivationTime - BLACKHOLE_TUNING_PULL_ACTIVATION_FX_LEAD_TIME + BLACKHOLE_TUNING_START_FX_STOP_OFFSET, 0.0 )
	wait lifeTime

	if ( IsValid( blackholeStartFx ) )
	{
		EffectStop( blackholeStartFx )
	}
}

void function TryOpenAndBreakDoors( entity blackholeProp, entity trigger )
{
	EndSignal( blackholeProp, "OnDestroy" )
	EndSignal( trigger, "OnDestroy" )

	while( true )
	{
		entity blackholePropOwner = blackholeProp.GetOwner()
		blackholePropOwner = ( IsValid( blackholePropOwner ) && blackholePropOwner.IsPlayer() ) ? blackholePropOwner : svGlobal.worldspawn

		array<entity> allDoors    = GetAllPropDoors()
		array<entity> nearbyDoors = GetEntsFromArrayInRange( blackholeProp.GetOrigin(), GetBlackholeRadius( blackholePropOwner ), allDoors )

		foreach ( entity door in nearbyDoors )
		{
			vector blackholeToDoor = Normalize( door.GetOrigin() - blackholeProp.GetOrigin() )
			vector damageOrigin    = blackholeProp.GetOrigin() + blackholeToDoor * GetBlackholeRadius( blackholePropOwner )
			door.TakeDamage( door.GetMaxHealth(), blackholePropOwner, blackholePropOwner, { origin = damageOrigin, force = -blackholeToDoor, damageSourceId = eDamageSourceId.invalid, scriptType = DF_EXPLOSION } )
			//damageSourceId = eDamageSourceId.mp_ability_horizon_black_hole
		}

		wait BLACKHOLE_TUNING_DOOR_CHECK_DELAY
	}
}

entity function CreateBlackholeVortexTrigger( entity newtProp, entity owner, float radius, float height )
{
	entity vortexSphere = CreateEntity( "vortex_sphere" )
	vortexSphere.kv.spawnflags             = SF_ABSORB_CYLINDER | SF_BLOCK_OWNER_WEAPON | SF_ABSORB_BULLETS
	vortexSphere.kv.enabled                = 0
	vortexSphere.kv.radius                 = radius
	vortexSphere.kv.bullet_fov             = 360
	vortexSphere.kv.physics_pull_strength  = 25
	vortexSphere.kv.physics_side_dampening = 6
	vortexSphere.kv.physics_fov            = 360
	vortexSphere.kv.physics_max_mass       = 2
	vortexSphere.kv.physics_max_size       = 6
	vortexSphere.SetAngles( <0, 0, 0> )
	vortexSphere.SetOrigin( newtProp.GetOrigin() )
	vortexSphere.SetMaxHealth( 100 )
	vortexSphere.SetHealth( 100 )
	vortexSphere.SetInvulnerable()
	vortexSphere.kv.height                 = fabs( height )

	DispatchSpawn( vortexSphere )

	vortexSphere.RemoveFromAllRealms()
	vortexSphere.AddToOtherEntitysRealms( newtProp )

	Vortex_ConvertToVortexTriggerArea( vortexSphere )
	SetCallback_VortexSphereTriggerOnProjectileHit( vortexSphere, BLACKHOLE_VortexTriggerOnProjectileHit )
	VortexFireEnable( vortexSphere )

	vortexSphere.SetOwner( newtProp )
	vortexSphere.SetParent( newtProp, "", true, 0.0 )

	return vortexSphere
}

void function BLACKHOLE_VortexTriggerOnProjectileHit( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	if ( BLACKHOLE_DEBUG_VORTEX )
	{
		printt( "BLACKHOLE_VortexTriggerOnProjectileHit" )
		printt( "BLACKHOLE HIT " + projectile.GetClassName() )
	}

	if ( IsValid(projectile) && projectile.GetClassName() == "grenade" )
	{
		thread BLACKHOLE_PullThrowableThread( projectile, vortexSphere )
	}
}

void function BLACKHOLE_PullThrowableThread( entity projectile, entity trigger )
{
	EndSignal( projectile, "OnDestroy" )
	EndSignal( trigger, "OnDestroy" )

	while ( true )
	{
		vector oldVelocity  = projectile.GetVelocity()
		vector toCenter     = trigger.GetOrigin() - projectile.GetOrigin()
		vector pullVelocity = Normalize( toCenter ) * BLACKHOLE_TUNING_PROJECTILE_PULL_SPEED

		vector newVelocity = oldVelocity + pullVelocity
		projectile.SetVelocity( newVelocity )

		if ( fabs( toCenter.z ) < 10 )
		{
			break;
		}

		WaitFrame()
	}
}

void function BLACKHOLE_PullTriggerThread( entity newtProp, entity pullSphereFX )
{
	int coreAttachID = newtProp.LookupAttachment( "core" )
	vector origin    = newtProp.GetOrigin()

	int radius      = int( GetBlackholeRadius( newtProp.GetOwner() ) )
	int aboveHeight = BLACKHOLE_TUNING_ABOVE_HEIGHT
	int belowHeight = BLACKHOLE_TUNING_BELOW_HEIGHT

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( radius )
	trigger.SetAboveHeight( aboveHeight )
	trigger.SetBelowHeight( belowHeight )
	trigger.kv.triggerFilterNpc          = "all"
	trigger.kv.triggerFilterPlayer       = "all"
	trigger.kv.triggerFilterNonCharacter = 1
	trigger.SetOrigin( origin )
	DispatchSpawn( trigger )

	trigger.Enable()
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( newtProp )
	trigger.SetParent( newtProp, "", false, 0.0 /*, true*/ )
	trigger.Code_SetTeam( newtProp.GetTeam() )
	trigger.SetEnterCallback( BLACKHOLE_TriggerEnter )
	trigger.SearchForNewTouchingEntity() 

	thread TryOpenAndBreakDoors( newtProp, trigger )

	EndSignal( trigger, "OnDestroy" )

	OnThreadEnd(
		function () : ( trigger, pullSphereFX)
		{
			if ( IsValid( trigger ) )
			{
				trigger.Destroy()
			}
		}
	)

	float blackholePullTime   = GetCurrentPlaylistVarFloat( "blackhole_pull_time", BLACKHOLE_TUNING_PULL_TIME )
	float blackholeStableTime = GetCurrentPlaylistVarFloat( "blackhole_stable_time", BLACKHOLE_TUNING_STABLE_TIME )
	
	wait blackholePullTime
	EmitSoundOnEntity( newtProp, BLACKHOLE_SOUND_PHASE_3 )
	wait blackholeStableTime
}

void function DrawBlackHoleSphere( entity newt, float totalTime, bool expanding )
{
	float timeElapsed = 0.0
	while ( timeElapsed <= totalTime )
	{
		float timeFactor = timeElapsed / totalTime
		if ( !expanding )
		{
			timeFactor = 1.0 - timeFactor
		}
		timeElapsed += 0.05
		wait 0.05
	}
}

void function BLACKHOLE_NewtPowerDown( entity newtProp, entity mover )
{
	int coreAttachID    = newtProp.LookupAttachment( "core" )
	vector corePosition = newtProp.GetAttachmentOrigin( coreAttachID )

	entity playerOwner      = newtProp.GetOwner()
	vector projectileOrigin = newtProp.GetOrigin()
	if ( IsValid ( playerOwner ) )
	{
		projectileOrigin = playerOwner.GetOrigin()
	}

	waitthread PlayAnim( newtProp, "prop_trophy_power_down", mover )

	EmitSoundAtPosition( TEAM_UNASSIGNED, newtProp.GetOrigin(), "Newt_Dissolve", newtProp )
	newtProp.ClearParent()
	newtProp.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )

	wait 1.0
}

void function BLACKHOLE_NEWT_PlayDamagedFX( entity newtProp, bool shouldPlayAddFX )
{
	if ( IsValid( newtProp ) )
	{
		if ( newtProp.IsMarkedForDeletion() )
			return

		int damageFXID       = GetParticleSystemIndex( BLACKHOLETROPHY_DAMAGE_SPARK_FX )
		int damageFXAttachID = newtProp.LookupAttachment( "core" )
		entity idleFX        = StartParticleEffectOnEntity_ReturnEntity ( newtProp, damageFXID, FX_PATTACH_POINT_FOLLOW, damageFXAttachID )

		if ( shouldPlayAddFX )
		{
			int damageAddFXID       = GetParticleSystemIndex( BLACKHOLETROPHY_DAMAGE_ADD_FX )
			int damageAddFXAttachID = newtProp.LookupAttachment( "BLACKHOLE_FX" )
			entity AddFX            = StartParticleEffectOnEntity_ReturnEntity ( newtProp, damageAddFXID, FX_PATTACH_POINT_FOLLOW, damageAddFXAttachID )
		}

		EmitSoundOnEntity( newtProp, BLACKHOLETROPHY_SOUND_DAMAGE )
	}
}

void function BLACKHOLE_NEWT_OnKilled( entity newtProp, var damageInfo )
{
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity owner       = newtProp.GetBossPlayer()

	if ( IsAlive( owner ) )
	{
		if ( damageSourceID == eDamageSourceId.damagedef_crush )
		{
			if ( newtProp.e.isBusy )
			{
				entity weapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
				if ( IsValid( weapon ) && weapon.GetWeaponClassName() == BLACKHOLE_WEAPON_CLASS_NAME )
				{
					Weapon_AddSingleCharge( weapon )
					weapon.SetNextAttackAllowedTime( Time() )
				}
			}
		}
	}
}

void function BLACKHOLE_NEWT_OnDamaged( entity newtProp, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if ( !IsValid( newtProp ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( !IsValid( inflictor ) )
		return

	if ( !newtProp.e.noFriendlyFireProtection )
	{
        int newtPropTeam = newtProp.GetTeam()
        int attackerTeam = attacker.GetTeam()

        if ( IsFriendlyTeam( attackerTeam, newtPropTeam ) )
            return
	}

	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( StatusEffect_HasSeverity( newtProp, eStatusEffect.ring_immunity ) )
	{
		if ( damageSourceIdentifier == eDamageSourceId.deathField )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}
	}

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	float damage    = DamageInfo_GetDamage( damageInfo )

	if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) )
		DamageInfo_ScaleDamage( damageInfo, BLACKHOLE_TUNING_TAKE_EXPLOSIVE_DAMAGE_MULTIPLIER )
	if ( damageSourceIdentifier == eDamageSourceId.mp_ability_crypto_drone_emp_trap )
	{
		float damageScale = newtProp.GetMaxHealth() / damage
		DamageInfo_ScaleDamage( damageInfo, damageScale )
	}
}

void function BLACKHOLE_NEWT_OnPostDamaged( entity newtProp, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	entity weapon    = DamageInfo_GetWeapon ( damageInfo )

	if ( !IsValid( newtProp ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( !IsValid( inflictor ) )
		return

	if ( !newtProp.e.noFriendlyFireProtection )
	{
        int newtPropTeam = newtProp.GetTeam()
        int attackerTeam = attacker.GetTeam()

        if ( IsFriendlyTeam( attackerTeam, newtPropTeam ) )
            return
	}

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	float damage    = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	bool newtDestroyed = (newtProp.GetHealth() - damage) <= 0

	if ( attacker.IsPlayer() )
	{
        if ( newtDestroyed )
            DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )

        attacker.NotifyDidDamage( newtProp, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
            DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
            DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	int maxHealth = newtProp.GetMaxHealth()
	int health    = newtProp.GetHealth()

	float newHealth  = max( health - damage, 0.0 )
	float healthFrac = newHealth / maxHealth

	float currTime = Time()
	if ( !(newtProp in file.lastDamageFxTime) )
		file.lastDamageFxTime[newtProp] <- currTime

	float damageTimeDelta = currTime - file.lastDamageFxTime[newtProp]
	if ( (healthFrac <= 0.99) && (damageTimeDelta >= BLACKHOLE_NEWT_DAMAGE_FX_INTERVAL) )
	{
		bool fullBlackholeEffectsActive = false
		if ( newtProp in file.fullBlackholeEffectsActive )
		{
			fullBlackholeEffectsActive = file.fullBlackholeEffectsActive[newtProp]
		}

		BLACKHOLE_NEWT_PlayDamagedFX( newtProp, fullBlackholeEffectsActive )

		file.lastDamageFxTime[newtProp] = currTime
	}


	if ( newtDestroyed )
	{
		BLACKHOLE_NEWT_DestroyExplosion( newtProp, attacker )
	}
}

void function BLACKHOLE_NEWT_DestroyExplosion( entity newtProp, entity attacker )
{
	int idleAttachID   = newtProp.LookupAttachment( "BLACKHOLE_FX" )
	vector soundOrigin = newtProp.GetAttachmentOrigin( idleAttachID )
	EmitSoundAtPosition( TEAM_ANY, soundOrigin, BLACKHOLETROPHY_SOUND_DESTROY, newtProp )

	int damageFXID       = GetParticleSystemIndex( BLACKHOLETROPHY_DESTROY_FX )
	int damageFXAttachID = newtProp.LookupAttachment( "BLACKHOLE_FX" )
	entity fx            = StartParticleEffectInWorld( damageFXID, newtProp.GetAttachmentOrigin( damageFXAttachID ), newtProp.GetAttachmentAngles( damageFXAttachID ) )

                        
        entity owningHorizon = newtProp.GetOwner()

		if ( !IsValid( owningHorizon ) )
			return

		if ( !IsValid( attacker ) )
			return

		if ( attacker.GetTeam() == owningHorizon.GetTeam() )
			return

        entity weapon = owningHorizon.GetOffhandWeapon( OFFHAND_ULTIMATE )
        if ( IsValid( weapon ) && weapon.GetWeaponClassName() == BLACKHOLE_WEAPON_CLASS_NAME )
        {
	    	if ( PlayerHasPassive( owningHorizon, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_horizon_ult_refund
	    	{
	    		int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
	    		weapon.SetWeaponPrimaryClipCount( maxAmmo * GetUpgradedTrophyDestroyRefund() )
	    	}
        }    
}
                  
#endif //SERVER
void function BLACKHOLE_TriggerEnter( entity trigger, entity ent )
{
	if ( !ent.DoesShareRealms( trigger ) )
		return
		
	//if ( IsFriendlyTeam( trigger.GetTeam(), ent.GetTeam() ) )
	//	return

	#if SERVER
		if ( ent.IsNPC() || ent.GetScriptName() == DEPLOYABLE_MEDIC_SCRIPT_NAME || ent.GetScriptName() == CRYPTO_DRONE_SCRIPTNAME )
		{
			if ( !StatusEffect_HasSeverity( ent, eStatusEffect.in_black_hole_field ) )
			{
				thread BLACKHOLE_PullLogic( trigger, ent )
			}
			return
		}
	#endif //SERVER

	if ( !ent.IsPlayer() )
		return

	thread BLACKHOLE_PullLogic( trigger, ent )
}

void function BLACKHOLE_PullLogic( entity trigger, entity ent )
{
	EndSignal( trigger, "OnDestroy" )
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "OnDeath" )
	
	if ( StatusEffect_HasSeverity( ent, eStatusEffect.in_black_hole_field ) )
		return

	StatusEffect_AddEndless( ent, eStatusEffect.in_black_hole_field, 1.0 )
	
	entity newtProp = trigger.GetParent()

	#if SERVER
		if ( newtProp in file.inBlackholeHistoryObjects )
		{
			if ( !file.inBlackholeHistoryObjects[newtProp].contains( ent ) )
			{
				file.inBlackholeHistoryObjects[newtProp].push( ent )
			}
		}

	if ( ent.IsPlayer() )
	{
		OnThreadEnd(
			function() : ( ent )
			{
				if ( IsValid( ent ) )
				{
					StatusEffect_StopAllOfType( ent, eStatusEffect.in_black_hole_field )
				}
			}
		)

		while( IsValid( trigger ) && IsValid( newtProp ) && trigger.IsTouching( ent ) )
		{
			vector entOrigin = ent.GetOrigin()
			vector centerOrigin = newtProp.GetOrigin()
			vector dir = centerOrigin - entOrigin
			float dist = Length( dir )
			dir = Normalize( dir )

			if ( dist > GRAVITY_HOLD_RADIUS )
			{
				vector currentVel = ent.GetVelocity()
				float pullStrength = GRAVITY_PLAYER_PULL_STRENGTH
				if ( IsFriendlyTeam( ent.GetTeam(), newtProp.GetTeam() ) )
				{
					pullStrength = GRAVITY_TEAMMATE_PULL_STRENGTH
				}
				
				vector newVel = (currentVel * GRAVITY_PLAYER_AIR_FRICTION) + (dir * pullStrength)
				if ( ent.IsOnGround() )
				{
					newVel.z = GRAVITY_GROUND_LIFT
				}
				
				ent.SetVelocity( newVel )
			}
			
			WaitFrame()
		}
	}

	else 
	{
		if ( IsFriendlyTeam( ent.GetTeam(), newtProp.GetTeam() ) )
		{
			StatusEffect_StopAllOfType( ent, eStatusEffect.in_black_hole_field )
			return
		}

		entity mover = CreateOwnedScriptMover( ent )
		ent.SetVelocity( <0,0,0> )
		ent.SetParent( mover, "", true )

		if ( ent.IsNPC() )
		{
			//ent.Anim_Stop()
			//ent.Anim_ScriptedPlayActivityByName( "ACT_FALL", false, 0.2 )
		}

		OnThreadEnd(
			function() : ( ent, mover )
			{
				if ( IsValid( ent ) )
				{
					ent.ClearParent()
					StatusEffect_StopAllOfType( ent, eStatusEffect.in_black_hole_field )
					
					if ( ent.IsNPC() )
					{
						ent.Anim_Stop()
					}
				}

				if ( IsValid( mover ) )
					mover.Destroy()
			}
		)
		
		vector entOrigin = ent.GetOrigin()
		vector centerOrigin = newtProp.GetOrigin()
	   
		vector dir = entOrigin - centerOrigin
		dir.z = 0
		dir = Normalize(dir)
	   
		vector targetPos = centerOrigin + (dir * GRAVITY_HOLD_RADIUS) + <0, 0, GRAVITY_PULL_HEIGHT_OFFSET>
	   
		mover.NonPhysicsMoveTo( targetPos, GRAVITY_PULL_TRAVEL_TIME, 0, 0 )
		
		wait GRAVITY_PULL_TRAVEL_TIME
		
		while( IsValid( trigger ) && IsValid( newtProp ) )
		{
			mover.NonPhysicsMoveTo( targetPos, 0.1, 0, 0 )
			WaitFrame()
		}
	}
	#endif
}

#if CLIENT
void function Blackhole_Start1PFX( entity ent, int statusEffect, bool actuallyChanged )
{
	ManageHighlightEntity( ent )

	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	entity viewPlayer = GetLocalViewPlayer()

	int fxHandle
	fxHandle = StartParticleEffectOnEntityWithPos( viewPlayer, BLACKHOLE_1P_SCREEN_OTHER_FX_ID, FX_PATTACH_ABSORIGIN_FOLLOW, -1, viewPlayer.EyePosition(), <0, 0, 0> )

	EffectSetIsWithCockpit( fxHandle, true )

	thread Blackhole_1PFXThread( viewPlayer, fxHandle )
}

void function Blackhole_Stop1PFX( entity ent, int statusEffect, bool actuallyChanged )
{
	ManageHighlightEntity( ent )

	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	foreach ( player in GetPlayerArray() )
	{
		ManageHighlightEntity( player )
	}

	ent.Signal( "Blackhole_Stop1PFXSignal" )
}

void function  Blackhole_1PFXThread( entity player, int fxHandle )
{
	player.EndSignal( "Blackhole_Stop1PFXSignal" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( fxHandle, player )
		{
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )

			if ( IsValid( player ) )
				StopSoundOnEntity( player, BLACKHOLE_SOUND_PLAYER_INSIDE_1P )
		}
	)

	if ( IsValid( player ) )
	{
		EmitSoundOnEntity( player, BLACKHOLE_SOUND_PLAYER_INSIDE_1P )
	}

	while ( EffectDoesExist( fxHandle ) )
	{
		WaitFrame()
	}
}

void function AddBlackholeThreatIndicator( entity newtProp )
{
	entity player = GetLocalViewPlayer()
	ShowGrenadeArrow( player, newtProp, GetBlackholeRadius( newtProp.GetOwner() ), 0.0 )
}
#endif //CLIENT