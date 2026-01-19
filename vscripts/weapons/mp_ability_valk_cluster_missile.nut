global function MpAbilityValkClusterMissile_Init
global function OnWeaponActivate_ability_valk_cluster_missile
global function OnProjectileCollision_ability_valk_cluster_missile
global function OnWeaponAttemptOffhandSwitch_ability_valk_cluster_missile
global function OnWeaponPrimaryAttack_valk_cluster_missile
global function OnWeaponDeactivate_ability_valk_cluster_missile

#if CLIENT
global function OnClientAnimEvent_ability_valk_cluster_missile
global function ValkTacShowTargetLocsThread
#endif

#if SERVER
global function ShowFinalLocsThread
#endif



// Ability settings -- should these go into the txt instead?

const float MAX_ATTACK_RANGE = 16000.0 // max range from current position that barrage can start
const float MIN_ATTACK_RANGE = 500.0 // for safety: minimum range
const float MIN_TRAVEL_TIME = 2.0
const float MAX_TRAVEL_TIME = 6.0
const int SIDE_STEPS = 2
const int FORWARD_STEPS = 4
// Total number of rockets = ((1 + (sideSteps *2)) * (forwardSteps+1))
const float STEP_HEIGHT = 300.0 // how far we step up before stepping to the side or forward
const float STEP_SIDE = 155.0 // how far we step to the side
const float STEP_FORWARD = 300.0 // how far we step forward
const float MISSILE_SPEED = 1200 // max speed
const float MISSILE_APEX_HEIGHT = 400
const float GRENADE_LOB_TIME = 0.75

const float STUN_DURATION = 2.0
const float STUN_EASEOUT = 1.5

const float STUN_MOVESLOW = 0.5
const float STUN_TURNSLOW = 0.0

const float EXPLOSION_DAMAGE = 25
const float EXPLOSION_FOLLOWUP_FACTOR = 0.15 // percentage of full damage you take from rockets beyond the first
const float EXPLOSION_FOLLOWUP_TIME = 5 // amount of time since the last hit; if less than this, take reduced dmg
const float EXPLOSION_RADIUS = 125

const float IN_ROW_DELAY = 0.05
const float ROW_TO_ROW_DELAY = 0.3

const float INITIAL_DELAY = 0.75 // delay before the first missile flies off

global const VALK_TAC_WARNING_ENTITY = "valk_tac_warning_entity"
const asset CREEPING_BOMBARDMENT_WEAPON_BOMB_MODEL = $"mdl/weapons_r5/misc_bangalore_rockets/bangalore_rockets_projectile.rmdl"

struct {
	#if SERVER
		table <entity, table<entity, float> >       valkToLastHitEntTable
		table <entity, float>                       valkToLastFrameGlideMeter
		table <entity, int>                         thisValkRocketsInFlight
		table <entity, table <int, entity> >        thisValkTacWarningEnts
		table <entity, float>                       thisValkToMissileImpactSoundDebounceTime
	#endif
	#if CLIENT
		array<entity> valkTacWarnEntities
	#endif

} file

struct ValkMissileInfo
{
	float  missileSpeed
	vector phase1Vector
	vector phase2Vector
	vector firePos
	vector targetPos
	float  phase1Time
	float  phase1To2Time
	float  phase2Time
	float  phase2To3Time
}

array< int > fanAdjustments =
[
	-1,
	1,
	-2,
	2,
	-3,
	3,
	-4,
	4,
	-5,
	5,
	-6,
	6

	,
	-7,
	7,
	-8

]


struct TraceStepResult
{
	vector pos
	vector normal
}

enum eCanFireTactical
{
	YES,
	NO_CLEARANCE,
	NO_OTHER
}

const asset FX_BOMBARDMENT_MARKER = $"P_valk_rckt_AR_marker"
const asset FX_BOMBARDMENT_LOCKED = $"P_valk_rckt_AR_lock"


const asset FX_MUZZLE_FLASH_FP = $"P_wpn_mflash_bang_rocket_FP"
const asset FX_MUZZLE_FLASH_3P = $"P_wpn_mflash_bang_rocket"
const asset MISSILE_TRAIL = $"P_valk_rckt_stg2"
const asset GRENADE_TRAIL = $"P_valk_rckt_stg1"
const asset ROCKET_PROJECTILE = $"mdl/weapons/bullets/projectile_rocket_launcher_sram.rmdl"

void function MpAbilityValkClusterMissile_Init()
{
	PrecacheModel( ROCKET_PROJECTILE )
	PrecacheParticleSystem( FX_MUZZLE_FLASH_FP )
	PrecacheParticleSystem( FX_MUZZLE_FLASH_3P )
	PrecacheParticleSystem( FX_BOMBARDMENT_MARKER )
	PrecacheParticleSystem( FX_BOMBARDMENT_LOCKED )
	PrecacheParticleSystem( GRENADE_TRAIL )
	PrecacheParticleSystem( MISSILE_TRAIL )
	RegisterSignal( "ValkTacTargetingEnd" )
	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_valk_cluster_missile, ValkTac_OnEntityDamagedByPlayer )
	#endif
	#if CLIENT
		AddTargetNameCreateCallback( VALK_TAC_WARNING_ENTITY, ValkTacAddWarning )
	#endif //CLIENT


	PrecacheImpactEffectTable( "exp_valk_rocket" )
}

#if SERVER
void function ValkTac_OnEntityDamagedByPlayer( entity hitEnt, var damageInfo )
{
	int dmgSrcID = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	float now   = Time()
	entity valk = DamageInfo_GetAttacker( damageInfo )
	if ( !(valk in file.valkToLastHitEntTable) )
	{
		table <entity, float> targetToLastTimeHit
		file.valkToLastHitEntTable[valk] <- targetToLastTimeHit
	}

	table<entity, float> entLastHitTimeMap = file.valkToLastHitEntTable[valk]

	if ( !(hitEnt in entLastHitTimeMap) )
	{
		entLastHitTimeMap[hitEnt] <- 0.0
	}

	float lastHitTime = entLastHitTimeMap[hitEnt]
	entLastHitTimeMap[hitEnt] = now

	bool recentlyHitPlayer = false

	if ( now < lastHitTime + EXPLOSION_FOLLOWUP_TIME )
	{
		//recently hit; handle special casing
		if ( hitEnt.IsPlayer() || hitEnt.IsNPC() )
		{
			// this is a player; do reduced follow up damage
			DamageInfo_SetDamage( damageInfo, floor( DamageInfo_GetDamage(damageInfo) * GetCurrentPlaylistVarFloat( "valk_tac_followup_dmg_mult", EXPLOSION_FOLLOWUP_FACTOR ) ) )
			recentlyHitPlayer = true
		}
	}

	if ( hitEnt.IsPlayer() || hitEnt.IsNPC() )
	{
		// Players and NPCs are also stunned
		StatusEffect_AddTimed( hitEnt, eStatusEffect.emp, 0.2, STUN_DURATION, STUN_EASEOUT )
		GiveEMPStunStatusEffects( hitEnt, STUN_DURATION, STUN_EASEOUT, STUN_TURNSLOW, STUN_MOVESLOW )
		// We do want to slow down NPCs like Prowlers but we can't call EmitSound...ToPlayer on them
		if ( hitEnt.IsPlayer() )
			EmitSoundOnEntityOnlyToPlayer( hitEnt, hitEnt, "Arcstar_visualimpair" )

		thread EMP_FX( FX_EMP_BODY_HUMAN, hitEnt, "CHESTFOCUS", STUN_DURATION )
	}
}
#endif

void function ValkTac_Cancelled( entity valk )
{
	//printt("CANCELLED")
}


void function OnWeaponActivate_ability_valk_cluster_missile( entity weapon )
{
#if CLIENT

	entity owner = weapon.GetOwner()
	if ( GetLocalViewPlayer() == owner )
	{
		thread ValkTacShowTargetLocsThread( owner, weapon )
	}
#endif
	#if SERVER
		thread ValkTac_CheckForReasonToDeactivate( weapon )
	#endif
}

#if SERVER
void function ValkTac_CheckForReasonToDeactivate( entity weapon )
{
	entity valk = weapon.GetWeaponOwner()
	EndSignal( valk, "OnDestroy" )
	EndSignal( valk, "BleedOut_OnStartDying" )
	EndSignal( valk, "ValkTacTargetingEnd" )

	OnThreadEnd(
		function() : ( weapon, valk )
		{

		}
	)

	Wait( 0.1 )
	while ( ValkCanFireTactical( weapon ) == eCanFireTactical.YES )
	{
		Wait( 0.1 )
	}
	// stop targeting here
	if ( valk.GetOffhandWeapon( OFFHAND_TACTICAL ) == weapon )
		valk.ClearOffhand( eActiveInventorySlot.altHand )
	//
	if ( valk.GetActiveWeapon( eActiveInventorySlot.mainHand ) == weapon )
		SwapToLastEquippedPrimary( valk )
}

void function ShowFinalLocsThread( entity player, entity weapon )
{
	// this shows the locked in target locations for Valk's tactical to all players in game
	// will display all locations so long as there's at least one rocket in flight

	EndSignal( player, "OnDestroy" )
	EndThreadOn_PlayerChangedClass( player )

	array<WeaponMissileMultipleTargetData> locArray = weapon.w.valkTac_targetData
	array<entity> FXArray
	entity thisFX

	foreach ( loc in locArray )
	{
		int systemIndex    = GetParticleSystemIndex( FX_BOMBARDMENT_LOCKED )
		vector normalAngle = VectorToAngles( loc.normal )
		normalAngle = FlattenVec( normalAngle )
		thisFX      = StartParticleEffectInWorld_ReturnEntity( systemIndex, loc.pos, normalAngle )
		thisFX.RemoveFromAllRealms()
		thisFX.AddToOtherEntitysRealms( player )
		EffectSetControlPointAngles( thisFX, 0, normalAngle )
		FXArray.append( thisFX )
	}
	float startTime = Time()

	OnThreadEnd(
		function() : ( FXArray )
		{
			foreach ( FX in FXArray )
			{
				EffectStop( FX )
			}
		}
	)
	while( file.thisValkRocketsInFlight[player] > 0 )
	{
		Wait( 0.25 )
		if ( (Time() - startTime) > 5 )
			break
	}
}
#endif

void function OnWeaponDeactivate_ability_valk_cluster_missile( entity weapon )
{
	entity owner = weapon.GetOwner()
	if ( IsValid( owner ) )
		owner.Signal( "ValkTacTargetingEnd" )
}

// pass in the weapon
// this can be rewritten to be way simpler because we don't have jetpack anymore
#if CLIENT
void function ValkTacShowTargetLocsThread( entity owner, entity weapon )
{
	EndSignal( owner, "ValkTacTargetingEnd", "OnDeath" )
	EndSignal( weapon, "OnDestroy" )
	array<int> vfxRefs = []

	OnThreadEnd( void function() : ( vfxRefs ) {
		foreach ( ref in vfxRefs )
		{
			CleanupFXHandle( ref, true, false )
		}
	} )

	// Create 12 target circles

	int systemIndex = GetParticleSystemIndex( FX_BOMBARDMENT_MARKER )

	array<WeaponMissileMultipleTargetData> targetLocs = GetValkTacTargets( weapon, owner )
	vector normalAngle

	for ( int i = 0; i < targetLocs.len(); i++ )
	{
		WeaponMissileMultipleTargetData res = targetLocs[i]

		normalAngle = VectorToAngles( res.normal )
		normalAngle = FlattenVec( normalAngle )
		int thisRef = StartParticleEffectInWorldWithHandle( systemIndex, res.pos, normalAngle )
		// Fix for R5DEV-253916
		//EffectSetDistanceCullingScalar( thisRef, 999.0 )
		vfxRefs.append( thisRef )
	}

	// Until this thread is killed, update their locations and orientations
	while ( true )
	{
		targetLocs = GetValkTacTargets( weapon, owner )

		for ( int i = 0; i < targetLocs.len() && i < vfxRefs.len(); i++ )
		{
			WeaponMissileMultipleTargetData res = targetLocs[i]
			normalAngle = VectorToAngles( res.normal )
			EffectSetControlPointVector( vfxRefs[i], 0, res.pos )
			EffectSetControlPointAngles( vfxRefs[i], 0, normalAngle )
		}
		WaitFrame()
	}
}
#endif

array<WeaponMissileMultipleTargetData> function GetValkTacTargets( entity weapon, entity owner )
{
	vector attackDir = weapon.GetAttackDirection()
	vector attackPos = weapon.GetAttackPosition()
	int forwardSteps = FORWARD_STEPS
	int sideSteps = SIDE_STEPS

	array<WeaponMissileMultipleTargetData> targetLocs = GetWeaponMissileMultipleTargets( attackPos, attackDir, owner, forwardSteps, sideSteps, STEP_FORWARD, STEP_SIDE, STEP_HEIGHT, INITIAL_DELAY, IN_ROW_DELAY, ROW_TO_ROW_DELAY, MAX_ATTACK_RANGE, MIN_ATTACK_RANGE )
	return targetLocs
}

array<WeaponMissileMultipleTargetData> function GetWeaponMissileMultipleTargets( vector attackPos, vector attackDir, entity owner, int forwardSteps, int sideSteps, float stepForward, float stepSide, float stepHeight, float initialDelay, float inRowDelay, float rowToRowDelay, float maxAttackRange, float minAttackRange )
{
	array<WeaponMissileMultipleTargetData> targetLocs

	vector rightVec = CrossProduct( attackDir, Vector( 0, 0, 1 ) )
	vector upVec = Vector( 0, 0, 1 )

	float currentDelay = initialDelay

	for ( int forwardIndex = 0; forwardIndex <= forwardSteps; forwardIndex++ )
	{
		for ( int sideIndex = -sideSteps; sideIndex <= sideSteps; sideIndex++ )
		{
			vector targetPos = attackPos
			targetPos = targetPos + (attackDir * (forwardIndex * stepForward))
			targetPos = targetPos + (rightVec * (sideIndex * stepSide))
			targetPos = targetPos + (upVec * stepHeight)

			// Trace down to ground to get actual impact point
			vector traceStart = targetPos
			vector traceEnd = targetPos - <0, 0, 20000>
			TraceResults groundTrace = TraceLine( traceStart, traceEnd, [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )

			vector surfaceNormal = attackDir  // Default to attack direction
			if ( groundTrace.fraction < 1.0 )
			{
				targetPos = groundTrace.endPos + <0, 0, 0.1>  // Small offset to prevent being inside ground
				surfaceNormal = groundTrace.surfaceNormal
			}

			float distToTarget = Distance( attackPos, targetPos )

			if ( distToTarget >= minAttackRange && distToTarget <= maxAttackRange )
			{
				WeaponMissileMultipleTargetData newTarget
				newTarget.pos = targetPos
				newTarget.normal = surfaceNormal
				newTarget.delay = currentDelay

				targetLocs.append( newTarget )

				currentDelay += inRowDelay
			}
		}

		currentDelay += rowToRowDelay
	}

	return targetLocs
}

vector function SanitizePos ( vector pos )
{
	float posX = Clamp( pos.x, -64000, 64000  ) //Map extents are *not* guaranteed to be within [-64,000, 64,000], but for our existing maps (and certainly for the intended playable game space) it is close enough
	float posY = Clamp( pos.y, -64000, 64000  ) //Map extents are *not* guaranteed to be within [-64,000, 64,000], but for our existing maps (and certainly for the intended playable game space) it is close enough
	float posZ = Clamp( pos.z, -64000, 64000  ) //Map extents are *not* guaranteed to be within [-64,000, 64,000], but for our existing maps (and certainly for the intended playable game space) it is close enough
	return <posX, posY, posZ>
}

#if SERVER
void function AddTacWarnEntity( entity owner, int grenadeHandle, vector tarPos )
{
	tarPos = SanitizePos( tarPos )
	entity warnEnt = CreatePropDynamic( CREEPING_BOMBARDMENT_WEAPON_BOMB_MODEL, tarPos + <0, 0, 55>, <0, 0, 0>, 0, 1 )
	warnEnt.RemoveFromAllRealms()
	warnEnt.AddToOtherEntitysRealms( owner )
	//printt("Adding target name")
	SetTargetName( warnEnt, VALK_TAC_WARNING_ENTITY )
	if ( !(owner in file.thisValkTacWarningEnts) )
		file.thisValkTacWarningEnts[owner] <- {}

	file.thisValkTacWarningEnts[owner][grenadeHandle] <- warnEnt

	warnEnt.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( owner, grenadeHandle, warnEnt )
		{
			if ( IsValid( warnEnt ) )
				warnEnt.Destroy()

			//printt("--> OTE for add tac warn")
			if ( IsValid( file.thisValkTacWarningEnts[owner][grenadeHandle] ) )
				delete file.thisValkTacWarningEnts[owner][grenadeHandle]
		}
	)

	wait(5) // for safety: a warning should never have to exist longer than 5s, clear it up then if it isn't cleared up before
	//printt("waited longer than 5 seconds")
}
#endif

#if SERVER
void function RemoveTacWarnEntity( int grenadeHandle, entity owner )
{
	//printt("removetacwarnentity")
	if ( !(owner in file.thisValkTacWarningEnts) )
		return

	if ( !(grenadeHandle in file.thisValkTacWarningEnts[owner]) )
	{
		//printt("couldn't find grenadeHandle in warningent array")
	}

	entity warnEnt = file.thisValkTacWarningEnts[owner][grenadeHandle]
	if ( !IsValid( warnEnt ) )
	{
		//printt("warnent wasn't valid!")
		return
	}

	warnEnt.Destroy()
	// will be cleaned up in the OTE for AddTacWarnEntity
}
#endif

#if CLIENT
void function ValkTacAddWarning( entity warnEntity )
{
	//printt("valktacaddwarning")
	file.valkTacWarnEntities.append( warnEntity )
	thread Thread_WaitForWarnEntDeletion( warnEntity )

	// if we're going from 0 to 1, turn on the management thread
	if ( file.valkTacWarnEntities.len() == 1 )
		thread ValkTacManageThreatIndicator()
}
#endif

#if CLIENT

void function Thread_WaitForWarnEntDeletion( entity warnEnt )
{
	warnEnt.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( warnEnt )
		{
			file.valkTacWarnEntities.fastremovebyvalue( warnEnt )
		}
	)

	WaitForever()
}

#endif

#if CLIENT
void function ValkTacManageThreatIndicator()
{
	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	localPlayer.EndSignal( "OnDestroy" )

	asset indicatorModel   = GRENADE_INDICATOR_GENERIC
	vector indicatorOffset = <-5, 0, 0>

	entity arrow = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, GRENADE_INDICATOR_ARROW_MODEL )
	entity mdl   = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, indicatorModel )
	EndSignal( arrow, "OnDestroy" )

	OnThreadEnd(
		function() : ( arrow, mdl )
		{
			if ( IsValid( arrow ) )
			{
				arrow.Destroy()
			}
			if ( IsValid( mdl ) )
			{
				mdl.Destroy()
			}
		}
	)
	entity cockpit = localPlayer.GetCockpit()
	if ( !cockpit )
		return

	EndSignal( cockpit, "OnDestroy" )

	arrow.SetParent( cockpit, "CAMERA_BASE" )
	arrow.SetAttachOffsetOrigin( <25, 0, -4> )

	mdl.SetParent( arrow, "BACK" )
	mdl.SetAttachOffsetOrigin( indicatorOffset )

	float lastVisibleTime = 0
	bool shouldBeVisible  = true

	while ( IsValid( localPlayer ) && file.valkTacWarnEntities.len() > 0 )
	{
		cockpit = localPlayer.GetCockpit()
		vector playerOrigin = localPlayer.GetOrigin()

		bool firstLoop = true
		vector closestPoint
		foreach ( warningLoc in file.valkTacWarnEntities )
		{
			if ( !IsValid( warningLoc ) )
				continue

			vector point = warningLoc.GetOrigin()
			//DebugDrawSphere( point, 25, <100, 0, 0>, true, 0.1 )
			if ( firstLoop )
			{
				closestPoint = point
			}
			else if ( DistanceSqr( playerOrigin, closestPoint ) > DistanceSqr( playerOrigin, point ) )
			{
				closestPoint = point
			}
			firstLoop = false
		}
		float dist = Distance( playerOrigin, closestPoint )
		if ( dist > (EXPLOSION_RADIUS * 1.3) || !cockpit || localPlayer.IsPhaseShifted() )
		{
			shouldBeVisible = false
		}
		else
		{
			TraceResults result = TraceLine( closestPoint, localPlayer.EyePosition(), [ localPlayer ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

			if ( result.fraction == 1.0 )
			{
				lastVisibleTime = Time()
			}
			else
			{
				shouldBeVisible = false
			}
		}

		if ( shouldBeVisible || Time() - lastVisibleTime < 0.25 )
		{
			arrow.EnableDraw()
			mdl.EnableDraw()

			arrow.kv.rendercolor = GetKeyColor( COLORID_LOOT_TIER4 )
			mdl.kv.rendercolor = GetKeyColor( COLORID_LOOT_TIER4 )

			arrow.DisableRenderWithViewModelsNoZoom()
			arrow.EnableRenderWithCockpit()
			arrow.EnableRenderWithHud()
			mdl.DisableRenderWithViewModelsNoZoom()
			mdl.EnableRenderWithCockpit()
			mdl.EnableRenderWithHud()

			vector damageArrowAngles = AnglesInverse( localPlayer.EyeAngles() )
			vector vecToDamage       = closestPoint - (localPlayer.EyePosition() + (localPlayer.GetViewVector() * 20.0))

			// reparent for embark/disembark
			if ( arrow.GetParent() == null )
				arrow.SetParent( cockpit, "CAMERA_BASE", true )

			arrow.SetAttachOffsetAngles( AnglesCompose( damageArrowAngles, VectorToAngles( vecToDamage ) ) )
		}
		else
		{
			mdl.DisableDraw()
			arrow.DisableDraw()
		}
		WaitFrame()
	}
}

#endif


var function OnWeaponPrimaryAttack_valk_cluster_missile( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !InPrediction() || !IsFirstTimePredicted() )
		{
			return
		}
	#endif

	entity owner     = weapon.GetOwner()
	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir



	if ( attackParams.burstIndex == 0 )
	{
		// first rocket
		owner.Signal( "ValkTacTargetingEnd" )
		#if CLIENT
			ClientScreenShake( 10, 100, 0.5, attackDir )
			EmitSoundOnEntity( owner, "Valk_ShoulderRocket_Fire_Comp_1P" )

		#endif
		weapon.w.valkTac_targetData = GetValkTacTargets( weapon, owner )

		#if SERVER
			//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VALK_TACTICAL, owner, owner.GetOrigin(), owner.GetTeam(), owner )

			// this doesn't work with infinite ammo

			file.thisValkRocketsInFlight[owner] <- 1
			thread ShowFinalLocsThread( owner, weapon )
			PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_valk_tactical" )
			EmitSoundOnEntityExceptToPlayer( owner, owner, "Valk_ShoulderRocket_Fire_Comp_3P" )
			EmitSoundOnEntityOnlyToPlayer( owner, owner, "Valk_ShoulderRocket_Fire_Comp_1P" ) // for spectators
		#endif

	}
	else
	{
		#if SERVER
			file.thisValkRocketsInFlight[owner]++
		#endif
	}

	// Dklein: moving this snippet that bounces out spectators down to fix http://jiratf.respawn.net:8080/browse/R5DEV-256421
	#if CLIENT
		if ( GetLocalViewPlayer() != owner )
			return
	#endif

	if (weapon.w.valkTac_targetData.len() < 1)
		return

	if( attackParams.burstIndex >= weapon.w.valkTac_targetData.len() )
		return

	WeaponMissileMultipleTargetData thisResult = weapon.w.valkTac_targetData[attackParams.burstIndex]
	vector curTar                              = thisResult.pos


	float curDownDelay = thisResult.delay

	// new grenade first then missile model; fireMissileParam contains the mundane missile info,
	// thisMissileInfo contains the valk missile curve specific info, and fireGrenadeParams
	// contains the params for the initial stage 1 grenade

	ValkMissileInfo thisMissileInfo

	WeaponFireMissileParams fireMissileParams
	fireMissileParams.pos                       = attackPos
	fireMissileParams.dir                       = attackDir
	fireMissileParams.scriptTouchDamageType     = damageTypes.projectileImpact// | DF_IMPACT
	fireMissileParams.scriptExplosionDamageType = damageTypes.explosive
	fireMissileParams.clientPredicted           = false
	fireMissileParams.speed                     = 1.0  // Base speed, InitMissileExpandContract handles actual velocity

	vector swarmVector = attackParams.dir
	swarmVector = Normalize( swarmVector )

	vector flatRight = RotateVector( attackParams.dir, <0, -90, 0> )
	flatRight.z = 0
	flatRight   = Normalize( flatRight )

	float fanAdjust = float(fanAdjustments[attackParams.burstIndex])

	swarmVector += flatRight * fanAdjust * 0.1 // the last number decides how broadly they fan out
	swarmVector.z = 0.7
	swarmVector   = Normalize( swarmVector )


	// Calculate vectors
	vector dir2d = (curTar - attackPos);
	dir2d.z = 0;
	dir2d   = Normalize( dir2d )
	vector phase1Vec = Normalize( swarmVector ) * 0.6
	vector phase2Vec = Normalize ( dir2d + <0, 0, 0.7> ) * 0.8
	thisMissileInfo.phase1Vector = phase1Vec
	thisMissileInfo.phase2Vector = phase2Vec

	// Give the missile an initial direction and a better spawn location
	fireMissileParams.dir     = phase1Vec
	fireMissileParams.pos     = attackPos
	thisMissileInfo.firePos   = fireMissileParams.pos // don't use this; recalculate from grenade's position
	thisMissileInfo.targetPos = curTar

	WeaponFireGrenadeParams fireGrenadeParams

	// while we're waiting for specific attachments, we're adjusting the rockets' spawn locations manually toward our pods
	if ( fanAdjust < 0 )
	{
		fireGrenadeParams.pos = attackPos + (flatRight * -18) + <0, 0, 0>
	}
	else
	{
		fireGrenadeParams.pos = attackPos + (flatRight * 10) + <0, 0, 0>
	}

	fireGrenadeParams.angVel            = <180, 0, 0>
	fireGrenadeParams.fuseTime          = 10
	fireGrenadeParams.clientPredicted   = true
	fireGrenadeParams.lagCompensated    = true
	fireGrenadeParams.useScriptOnDamage = true

	int rocketsInRow = 1 + (SIDE_STEPS * 2)

	// Calculate travel times and overall missile speed
	int row = attackParams.burstIndex / rocketsInRow

	// calculate speed
	float distance = (curTar - attackPos).Length()

	float travelTime = log( distance )
	travelTime = GraphCapped( travelTime, log( MIN_ATTACK_RANGE ), log( MAX_ATTACK_RANGE ), MIN_TRAVEL_TIME, MAX_TRAVEL_TIME )
	travelTime += row * ROW_TO_ROW_DELAY
	int indexInRow = attackParams.burstIndex % rocketsInRow
	travelTime += indexInRow * IN_ROW_DELAY
	//printt("Travel time desired is: " + string(travelTime))
	float thisLobTime          = GRENADE_LOB_TIME + RandomFloatRange( -0.2, 0.1 ) // randomize lob time
	fireGrenadeParams.vel      = (swarmVector + <0, 0, 0.75>) * (0.04 * (0.8 + thisLobTime))
	//printt( string(thisLobTime) )
	float rocketTravelTime     = travelTime - thisLobTime
	float rocketTravelDistance = distance - 200 // rough distance the grenade travels
	float speed                = (rocketTravelDistance / rocketTravelTime) * 3


	//printt("Calculated speed is: " + string(speed))
	float phase1Time      = 0.01
	float phase1To2Time   = 0.01
	float phase2Time      = rocketTravelTime * 0.1
	float phase2To3Time   = rocketTravelTime * 0.16
	thisMissileInfo.phase1Time      = phase1Time
	thisMissileInfo.phase1To2Time   = phase1To2Time
	thisMissileInfo.phase2Time      = phase2Time
	thisMissileInfo.phase2To3Time   = phase2To3Time
	thisMissileInfo.missileSpeed    = speed

	// Fire grenade
	entity grenade    = weapon.FireWeaponGrenade( fireGrenadeParams )
	if( IsValid(grenade) )
	{
		int grenadeHandle = grenade.GetEncodedEHandle()

		grenade.SetPhysics( MOVETYPE_FLYGRAVITY )
		grenade.SetAngles( FlattenAngles( VectorToAngles( attackParams.dir ) ) + <-15, 0, 0> ) // fire grenade rotated upward
		#if SERVER
			thread Thread_CreateMissileTrail( grenade, GRENADE_TRAIL )
			grenade.SetAngularVelocity( 480, 0, 0 )
			thread AddTacWarnEntity( owner, grenadeHandle, curTar )

		#endif

		grenade.SetProjectileLifetime( thisLobTime )
	}

#if SERVER
	thread Thread_WaitForIgnition( owner, weapon, grenade, fireMissileParams, thisMissileInfo, thisLobTime, rocketTravelTime, attackParams.burstIndex )

	if ( attackParams.burstIndex == 0 )
	{
		PlayerUsedOffhand( owner, weapon, true, grenade )
		//EmitSoundOnEntity_PredictedByPlayer( grenade, owner, "Bangalore_Ultimate_Whoosh" )
	}
#endif
	//#if CLIENT
	//	if ( IsFirstTimePredicted() )
	//		//EmitSoundOnEntity( grenade, "Bangalore_Ultimate_Whoosh" )
	//#endif








	// on last shot, return whatever the correct number is for max ammo; otherwise return 0
	if ( attackParams.burstIndex == weapon.GetWeaponSettingInt( eWeaponVar.burst_fire_count ) - 1 )
	{
		#if SERVER
			//printt("LAST SHOT -- returning " + string(weapon.GetWeaponPrimaryClipCount() - 1))
		#endif
		int curAmmo = weapon.GetWeaponPrimaryClipCount()
		owner.Signal( "ValkTacTargetingEnd" )
		return curAmmo
	}
	else
	{
		#if SERVER
			//printt("pew")
		#endif
		return weapon.GetAmmoPerShot()
	}
}


#if SERVER
void function Thread_WaitForIgnition( entity owner, entity weapon, entity grenade, WeaponFireMissileParams fireMissileParams, ValkMissileInfo valkMissileInfo, float delay, float expectedTime, int burstIndex )
{
	if ( !IsValid( grenade ) )
		return

	int grenadeHandle = grenade.GetEncodedEHandle()

	grenade.EndSignal( "OnDestroy" )
	OnThreadEnd(
		function() : ( owner, weapon, grenade, fireMissileParams, valkMissileInfo, expectedTime, burstIndex, grenadeHandle )
		{
			if ( !IsValid( weapon ) || !IsValid( owner ) )
				return


			// first, let's extract the valkMissileInfo struct for ease of access
			float speed           = valkMissileInfo.missileSpeed
			vector phase1Vec      = valkMissileInfo.phase1Vector
			vector phase2Vec      = valkMissileInfo.phase2Vector
			float phase1Time      = 0.01
			float phase1To2Time   = 0.01
			float phase2Time      = valkMissileInfo.phase2Time
			float phase2To3Time   = valkMissileInfo.phase2To3Time
			vector curTar         = valkMissileInfo.targetPos
			vector attackPos      = grenade.GetOrigin()
			fireMissileParams.pos = grenade.GetOrigin()
			// Fire ze missile
			entity missile        = weapon.FireWeaponMissile( fireMissileParams )

			if ( !IsValid( missile ) )
				return


			if ( burstIndex == 0 )
			{
				EmitSoundOnEntity( missile, "weapon_ValkShoulderRocket_incoming_projectile" )
				EmitSoundAtPositionExceptToPlayer( TEAM_ANY, attackPos, owner, "valk_shoulderrocket_blastoff_comp_3p" )
				EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, attackPos, owner, "valk_shoulderrocket_blastoff_comp_1p" )
			}

			missile.proj.valkTacGrenadeHandle = grenadeHandle

			// missile.SetGracePeriod( 0.5 ) // Native function not available - missile should work without it
			missile.SetModel( ROCKET_PROJECTILE )
			//thread DebugTimeMissile( missile, burstIndex, expectedTime )
			thread Thread_CreateMissileTrail( missile )

			// Simple trace to check for obstacles above - adjust phase2Vec if needed
			vector estimatedHighPoint = attackPos + (phase2Vec * 300)
			TraceResults upTrace = TraceLine( attackPos, estimatedHighPoint, [ owner ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
			if ( upTrace.fraction < 1.0 )
			{
				// Reduce upward movement if there's a ceiling
				phase2Vec *= clamp( (upTrace.fraction - 0.5), 0.1, 1 )
			}

			missile.InitMissileExpandContract( phase1Vec, phase2Vec, phase1Time, phase1To2Time, phase2Time, phase2To3Time, curTar, false )
		}
	)
	WaitForever()
}
#endif

void function DebugTimeMissile( entity missile, int burstNumber, float expectedTime )
{
	float startTime = Time()
	missile.EndSignal( "OnDestroy" )
	OnThreadEnd( function(): (missile, burstNumber, startTime, expectedTime)
	{
		float totalTravelTime = Time() - startTime
		#if SERVER
			printt( "Total travel time for missile " + string(burstNumber) + " was " + string(totalTravelTime + GRENADE_LOB_TIME) + "; expected: " + string(expectedTime) )
		#endif
	} )
	WaitForever()
}


bool function OnWeaponAttemptOffhandSwitch_ability_valk_cluster_missile( entity weapon )
{
	int canFire = ValkCanFireTactical( weapon )

	#if CLIENT
		if ( canFire == eCanFireTactical.NO_CLEARANCE )
		{
			entity owner = weapon.GetWeaponOwner()
			AddPlayerHint( 1.0, 0.75, $"rui/hud/tactical_icons/tactical_valk", "#CLUSTER_MISSILE_CLEARANCE_FAIL" )
			EmitSoundOnEntity( owner, "Valk_Hover_VerticalClearanceWarning_1P" )
		}
	#endif

	return canFire == eCanFireTactical.YES

}


int function ValkCanFireTactical( entity weapon )
{
	if ( weapon.GetWeaponPrimaryClipCount() < weapon.GetWeaponPrimaryClipCountMax() )
		return eCanFireTactical.NO_OTHER

	entity owner = weapon.GetWeaponOwner()
	if ( StatusEffect_HasSeverity( owner, eStatusEffect.skyward_embark ) )
	{
		return eCanFireTactical.NO_OTHER
	}
	float traceDist      = 300
	TraceResults results = TraceLine( owner.EyePosition(), owner.GetOrigin() + <0, 0, traceDist>, [ owner ], TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
	float dist           = traceDist * results.fraction
	if ( dist < 160 )
	{
		return eCanFireTactical.NO_CLEARANCE
	}

	if ( owner.IsPhaseShifted() )
		return eCanFireTactical.NO_OTHER

	return eCanFireTactical.YES
}

#if SERVER
void function Thread_CreateMissileTrail( entity projectile, asset trailName = MISSILE_TRAIL )
{
	if ( !IsValid( projectile ) )
		return

	projectile.EndSignal( "OnDestroy" )
	int trailIndex = GetParticleSystemIndex( trailName )
	entity VFX     = StartParticleEffectOnEntity_ReturnEntity( projectile, trailIndex, FX_PATTACH_POINT_FOLLOW, projectile.LookupAttachment( "exhaust" ) )
	OnThreadEnd(
		function() : ( projectile, VFX )
		{
			VFX.Destroy()
		}
	)
	WaitForever()
}
#endif

void function OnProjectileCollision_ability_valk_cluster_missile( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{


	#if SERVER
		// Valk rockets are inert during their grenade stage
		if ( projectile.GetClassName() == "grenade" )
			return

		float damage = GetCurrentPlaylistVarFloat( "valk_tac_dmg", EXPLOSION_DAMAGE )
		float radius = EXPLOSION_RADIUS
		entity owner = projectile.GetOwner()

		if ( !IsValid( owner ) )
			return

		if ( !(owner in file.thisValkToMissileImpactSoundDebounceTime) )
			file.thisValkToMissileImpactSoundDebounceTime[owner] <- 0

		float timeSinceLastImpactSound = Time() - file.thisValkToMissileImpactSoundDebounceTime[owner]
		if ( timeSinceLastImpactSound > 5 )
			EmitSoundAtPosition( TEAM_ANY, pos, "Explo_Valk_ShoulderRocket_Impact_Sustained", owner )

		file.thisValkToMissileImpactSoundDebounceTime[owner] = Time()

		RemoveTacWarnEntity( projectile.proj.valkTacGrenadeHandle, owner )

		Explosion( pos, owner, projectile.GetOwner(), damage, damage, radius, radius, SF_ENVEXPLOSION_NOSOUND_FOR_ALLIES, projectile.proj.valkTacMissileStartPos, 10, damageTypes.explosive, eDamageSourceId.mp_ability_valk_cluster_missile, "exp_valk_rocket" )
		CreateShake( pos, 16, 140, 0.25, 800 )
		projectile.Destroy()
		file.thisValkRocketsInFlight[owner]--
	#endif

}


#if CLIENT
void function OnClientAnimEvent_ability_valk_cluster_missile( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )
}
#endif // CLIENT