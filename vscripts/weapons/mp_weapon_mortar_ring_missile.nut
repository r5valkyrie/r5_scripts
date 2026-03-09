global function MpWeapon_Mortar_Ring_Missile_Init
global function OnProjectileCollision_ability_mortar_ring_missile

#if SERVER
global function MortarRingAirburst
#endif

#if CLIENT
global function ClientCodeCallback_MortarRingFireSegmentCreated
global function ServerCallback_MortarRingFireSegmentCreated
#endif

const asset MORTAR_RING_MISSILE_PLAYER_BURN_FX	= $"P_mortar_victim_burning_1p"
const string MORTAR_RING_MISSILE_EXPLOSION_SFX = "Firebomb_Mortar_Missile_Explode"
const string MORTAR_RING_MISSILE_FIRE_START_SFX = "Firebomb_Mortar_Ring_Flame_Start"
const string MORTAR_RING_MISSILE_FIRE_LOOP_SFX = "Firebomb_Mortar_Ring_Flame_Burn"
const string MORTAR_RING_MISSILE_MOVEMENT_SFX = "Firebomb_Mortar_Missile_Trails"
const string MORTAR_RING_AIRBURST_EXPLOSION_VFX = $"P_mortar_air_burst"
const string MORTAR_RING_AIRBURST_EXPLOSION_SFX = "Firebomb_Mortar_Explode"
const asset MORTAR_RING_MISSILE_BURN_FX = $"P_wpn_mortar_firewall"
const asset MORTAR_RING_MISSILE_PREBURN_FX = $"P_mortar_preburn"
const string MORTAR_RING_MISSILE_EXPLOSION_VFX = $"P_wpn_mortar_nade_impact"
const string MORTAR_RING_MISSILE_PLAYER_BURN_COLOR_CORRECTION = "materials/correction/mortar_fire.raw_hdr"
const string KILL_THREAT_INDICATOR_THREAD_SIGNAL = "KillThreatIndicatorThread"
const float MORTAR_RING_MISSILE_WAIT_TIME_SECS = 0.0
const vector MORTAR_RING_MISSILE_EXPLOSION_OFFSET = < 0, 0, 10.0 >
global const string MORTAR_RING_FIRE_TARGETNAME = "mortar_ring_fire"
const float MORTAR_RING_MISSILE_THREAT_INDICATOR_DIST = 165.0
const float MORTAR_RING_MISSILE_SHELLSHOCK_DURATION_PER_TICK = 3.8
const float MORTAR_RING_MISSILE_FIRE_FWD_TRACE_HEIGHT = 60.0
const float MORTAR_RING_MISSILE_FIRE_FWD_TRACE_STEP = 15.0
const float MORTAR_RING_MISSILE_FIRE_DOWN_TRACE_LENGTH = 125.0
const float MORTAR_RING_MISSILE_FIRE_HEIGHT_THRESHOLD = 90.0
const float MORTAR_RING_MISSILE_FIRE_DISTANCE_THRESHOLD = 450.0
const string MORTAR_RING_MISSILE_WEAPON = "mp_weapon_mortar_ring_missle"
const float MORTAR_RING_MISSILE_POST_IMPACT_LIFETIME = 2.5
const float MORTAR_RING_MISSILE_PLAYER_BURN_FX_SEVERITY	= 0.3
const float MORTAR_RING_MISSILE_AMBIENT_GENERIC_HEIGHT_OFFSET= 30.0
const float MORTAR_RING_MISSILE_PREBURN_DURATION = 1.0
const float MORTAR_RING_MISSILE_BURN_DURATION = 15.0
global const float MORTAR_RING_FIRE_SEGMENT_HEIGHT = 65.0
const float MORTAR_RING_FIRE_SEGMENT_WIDTH = 50.0
const float MORTAR_RING_FIRE_SEGMENT_WIDTH_SQR = MORTAR_RING_FIRE_SEGMENT_WIDTH * MORTAR_RING_FIRE_SEGMENT_WIDTH
const float MORTAR_RING_FIRE_SEGMENT_DEFAULT_RADIUS = 50.0
const float MORTAR_RING_MISSILE_EXPLOSION_FX_DURATION = 1.0
const float MORTAR_RING_IN_FIRE_DAMAGE_MULTIPLIER = 1.5
const float MORTAR_RING_COLOR_CORRECTION_BASE_SEVERITY = 0.5
const float MORTAR_RING_COLOR_CORRECTION_LERP_TIME = 1.0
const bool MORTAR_RING_MISSILE_DEBUG = false
const int TT_MORTAR_RING_SEGMENT = 3
const int SE_INVALID_HANDLE = -1

//Player burn values
const float MORTAR_RING_FIRST_TICK_DAMAGE = 35.0
const float MORTAR_RING_SUBSEQUENT_TICK_DAMAGE = 8.0
const float MORTAR_RING_PREBURN_DAMAGE_PLAYER = 5.0
const float MORTAR_RING_PREBURN_DAMAGE_NON_PLAYER = 10.0
const float MORTAR_RING_MISSILE_DAMAGE_PER_TICK = 12
const int MORTAR_RING_MISSILE_NUM_TICKS = 6
const float MORTAR_RING_MISSILE_TICK_INTERVAL = 0.83

//Non player burn values
const int MORTAR_RING_NON_PLAYER_BURN_DAMAGE = 50
const float MORTAR_RING_NON_PLAYER_BURN_TIME = 2.8
const int MORTAR_RING_NON_PLAYER_BURN_STACKS_MAX = 4
const float MORTAR_RING_NON_PLAYER_BURN_STACK_DEBOUNCE = 0.7
const float MORTAR_RING_NON_PLAYER_BURN_TICK_RATE = 1.2

const string KILL_BURN_FX_SIGNAL = "MortarRingBurn_Stop"


const float FUSE_MORTAR_SCAN_RADIUS_BASE 	= 300.0
const float FUSE_MORTAR_SCAN_LENGTH_BASE 	= 1000.0
const float FUSE_MORTAR_SCAN_LENGTH_MIN		= 350.0



const float FUSE_MORTAR_SCAN_UPGRADE_EXTEND_TIME_MAX = 4.0


struct
{
	#if SERVER
		table< entity, array<entity> > fireTargets
		table< entity, array<int> >    entityRevealHandles

		table< entity, float >		   playerMortarScanStartTime

	#endif
	#if CLIENT
		array<entity> mortarRingClientAGs
		int colorCorrection
	#endif
} file

struct FireSegmentData
{
	vector startPos
	vector endPos
	vector angles
	vector dirToCenter
	array<int> realms
	entity moveParent
}

vector function CalcWorldToLocalOrigin_Entity( entity moveParent, vector worldPos )
{
	if ( !IsValid( moveParent ) )
		return worldPos

	vector offset = worldPos - moveParent.GetOrigin()
	vector forward = AnglesToForward( moveParent.GetAngles() )
	vector right = AnglesToRight( moveParent.GetAngles() )
	vector up = AnglesToUp( moveParent.GetAngles() )
	return < offset.Dot( forward ), offset.Dot( right ), offset.Dot( up ) >
}

vector function CalcLocalToWorldOrigin_Entity( entity moveParent, vector localPos )
{
	if ( !IsValid( moveParent ) )
		return localPos

	vector origin = moveParent.GetOrigin()
	vector forward = AnglesToForward( moveParent.GetAngles() )
	vector right = AnglesToRight( moveParent.GetAngles() )
	vector up = AnglesToUp( moveParent.GetAngles() )
	return origin + forward * localPos.x + right * localPos.y + up * localPos.z
}

vector function CalcWorldToLocalAngles_Entity( entity moveParent, vector worldAngles )
{
	if ( !IsValid( moveParent ) )
		return worldAngles
	return AnglesCompose( worldAngles, AnglesInverse( moveParent.GetAngles() ) )
}

vector function CalcLocalToWorldAngles_Entity( entity moveParent, vector localAngles )
{
	if ( !IsValid( moveParent ) )
		return localAngles
	return AnglesCompose( moveParent.GetAngles(), localAngles )
}

bool function PositionHasLOSToObject( vector startPoint, entity target, array<entity> ornull additionalIgnore = null )
{
	if ( !IsValid( target ) )
		return false

	array<entity> ignoreList = []
	if ( additionalIgnore != null )
	{
		foreach ( entity ent in expect array<entity>( additionalIgnore ) )
		{
			if ( IsValid( ent ) )
				ignoreList.append( ent )
		}
	}

	ignoreList.append( target )
	TraceResults losTrace = TraceLineHighDetail( startPoint, target.GetWorldSpaceCenter(), ignoreList, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	if ( losTrace.fraction == 1.0 )
		return true

	TraceResults fallbackTrace = TraceLineHighDetail( startPoint, target.EyePosition(), ignoreList, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	return fallbackTrace.fraction == 1.0
}

void function MpWeapon_Mortar_Ring_Missile_Init()
{
#if CLIENT
	StatusEffect_RegisterEnabledCallback( eStatusEffect.mortar_ring_burn, MortarRingBurn_StartVisualEffect )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.mortar_ring_burn, MortarRingBurn_StopVisualEffect )
	RegisterSignal( KILL_BURN_FX_SIGNAL )
	RegisterSignal( KILL_THREAT_INDICATOR_THREAD_SIGNAL )
	file.colorCorrection = ColorCorrection_Register( MORTAR_RING_MISSILE_PLAYER_BURN_COLOR_CORRECTION )


	StatusEffect_RegisterEnabledCallback( eStatusEffect.mortar_ring_reveal, MortarRingReveal_RevealStatusChanged )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.mortar_ring_reveal, MortarRingReveal_RevealStatusChanged )

#endif
#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_mortar_ring, MortarRing_FireDamagedTarget )



		RegisterSignal( "EndMotherlodeCenterDamage" )
		RegisterSignal( "MortarRing_OnEnterArea" )


#endif

	PrecacheParticleSystem( MORTAR_RING_MISSILE_BURN_FX )
	PrecacheParticleSystem( MORTAR_RING_MISSILE_PREBURN_FX )
	PrecacheParticleSystem( MORTAR_RING_MISSILE_PLAYER_BURN_FX )
	PrecacheParticleSystem( MORTAR_RING_MISSILE_EXPLOSION_VFX )
	PrecacheParticleSystem( MORTAR_RING_AIRBURST_EXPLOSION_VFX )
	PrecacheWeapon( MORTAR_RING_MISSILE_WEAPON )
}

void function OnProjectileCollision_ability_mortar_ring_missile( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		entity player = projectile.GetOwner()

		if ( hitEnt == player )
			return

		if ( !EntityShouldStick( projectile, hitEnt ) )
			return

		if ( hitEnt.IsProjectile() )
			return

		if ( hitEnt.IsPlayer() )
			return

		if ( !LegalOrigin( pos ) )
			return

		//if( IsValid( hitEnt ) && hitEnt.GetScriptName() == BUBBLE_SHIELD_SCRIPTNAME )
		//	return

		projectile.proj.projectileBounceCount++
		int maxBounceCount = 16//projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_ricochet_max_count )

		bool forceExplode = false
		if ( projectile.proj.projectileBounceCount > maxBounceCount )
		{
			//printt( "max bounceCount hit, forcing explosion" )
			forceExplode = true
		}

		bool projectileIsOnGround = normal.Dot( <0,0,1> ) > 0.75
		DeployableCollisionParams cp
		cp.pos = pos
		cp.normal = normal
		cp.hitEnt = hitEnt
		cp.hitBox = hitbox
		cp.isCritical = isCritical

			//cp.deployableFlags = eDeployableFlags.VEHICLES_NO_STICK

		table collisionParams =
		{
			pos = cp.pos,
			normal = cp.normal,
			hitEnt = cp.hitEnt,
			hitbox = cp.hitBox
		}

		if( !forceExplode )
		{
			if ( !projectileIsOnGround || !PlantStickyEntity( projectile, collisionParams ) )
				return
		}

		thread BombletExplosion( pos, projectile.GetAngles(), normal, hitEnt, player, projectile )
	#endif // SERVER

}

#if SERVER

void function MortarRingSendSegmentEndpointsToClients( entity trigger, entity effect, entity controlPoint )
{
	if ( !IsValid( trigger ) || !IsValid( effect ) || !IsValid( controlPoint ) )
		return

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( !player.DoesShareRealms( trigger ) )
			continue

		Remote_CallFunction_Replay( player, "ServerCallback_MortarRingFireSegmentCreated", trigger, effect, controlPoint )
	}
}

void function BombletExplosion( vector origin, vector angles, vector normal, entity hitEnt, entity owner, entity projectile )
{
	projectile.EndSignal( "OnDestroy" )

	vector fireDir = projectile.proj.mortarRingDirForFireEffect
	vector dirFromCenter = projectile.proj.mortarRingDirFromCenter
	projectile.proj.bombletLanded = true
	projectile.Hide()
	projectile.StopPhysics()
	vector bombExplosionOrigin = projectile.GetOrigin() + MORTAR_RING_MISSILE_EXPLOSION_OFFSET
	entity partnerBomblet = projectile.proj.trackedEnt

	thread BombletExplosionFX( projectile, bombExplosionOrigin, dirFromCenter )

	//Apply damage to all in range
	array<entity> victimPlayers = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, bombExplosionOrigin, 80 )
	foreach ( victim in victimPlayers )
	{
		if ( !IsValid( victim ) || !victim.IsPlayer() || !IsAlive( victim ) || victim.IsPhaseShifted() || StatusEffect_HasSeverity( victim, eStatusEffect.mortar_ring_push ) )
			continue

		vector startOrigin  = bombExplosionOrigin
		TraceResults result = TraceLineHighDetail( startOrigin, victim.GetWorldSpaceCenter(), [projectile, victim], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction != 1.0 )
			result = TraceLineHighDetail( startOrigin, victim.EyePosition(), [projectile, victim], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

		if ( result.fraction == 1.0 )
		{
			float inputForward = victim.GetInputAxisForward()
			float inputRight   = victim.GetInputAxisRight()
			vector inputVector = Normalize( <inputForward, inputRight, 0> )

			StatusEffect_AddTimed( victim, eStatusEffect.mortar_ring_push, 1.0, 1.0, 0.25 )

			//If they aren't sprinting or trying to move very fast, blow them out
			if ( !victim.IsSprinting() && Length( inputVector ) < 0.45 )
			{
				vector bombToPlayer = FlattenNormalizeVec( victim.GetOrigin() - startOrigin )
				vector v = ( dirFromCenter.Dot( bombToPlayer ) > 0 ) ? dirFromCenter : -dirFromCenter
				v *= 350
				victim.SetVelocity( victim.GetVelocity() + v )
			}

			entity damageOwner = IsValid( owner ) ? owner : svGlobal.worldspawn



			if( !IsFriendlyTeam( damageOwner.GetTeam(), victim.GetTeam() ) || ( damageOwner == victim ) )

				victim.TakeDamage( 5, owner, projectile, { damageSourceId = eDamageSourceId.mp_weapon_mortar_ring } )
		}
	}

	//printt( "MORTAR projectile " + projectile + " landed  at " + Time() + " partnerBomblet is " + partnerBomblet )
	float timeoutTime = Time() + MORTAR_RING_MISSILE_POST_IMPACT_LIFETIME
	while( true )
	{
		if( Time() > timeoutTime )
		{
			thread BeginBombletFire( owner, projectile, null, fireDir, -dirFromCenter )
			break
		}
		else if( IsValid( partnerBomblet ) )
		{
			if( partnerBomblet.proj.bombletLanded )
			{
				thread BeginBombletFire( owner, projectile, partnerBomblet, fireDir, -dirFromCenter )
				partnerBomblet.proj.bombletFireLinked = true
				break
			}
		}
		WaitFrame()
	}

	projectile.proj.bombletIgnited = true

	// Try to wait the min time.
	while ( true )
	{
		if ( projectile.proj.bombletFireLinked )
			break

		if ( Time() > timeoutTime )
			break

		WaitFrame()
	}
	projectile.Destroy()
}

void function BombletExplosionFX( entity projectile, vector bombExplosionOrigin, vector dirFromCenter )
{
	entity explosionFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( MORTAR_RING_MISSILE_EXPLOSION_VFX ), bombExplosionOrigin, ZERO_VECTOR )
	explosionFX.RemoveFromAllRealms()
	explosionFX.AddToOtherEntitysRealms( projectile )
	EffectSetControlPointVector( explosionFX, 2, -dirFromCenter )
	EmitSoundAtPosition( TEAM_ANY, bombExplosionOrigin, MORTAR_RING_MISSILE_EXPLOSION_SFX, projectile )

	OnThreadEnd(
		function() : ( explosionFX )
		{
			if ( IsValid( explosionFX ) )
				EffectStop( explosionFX )
		}
	)

	wait MORTAR_RING_MISSILE_EXPLOSION_FX_DURATION
}

void function BeginBombletFire( entity owner, entity projectile, entity projectile2, vector dir, vector dirToCenter )
{
	array<FireSegmentData> segmentsArray

	vector startPos = projectile.GetOrigin()
	entity hitEnt = projectile.GetParent()
	entity hitEnt2 = null
	vector endPos = startPos
	if( IsValid( projectile2 ) )
	{
		endPos = projectile2.GetOrigin()
		hitEnt2 = projectile2.GetParent()
	}

	if( !IsValid( projectile2 ) ||
			Distance2DSqr( startPos , endPos ) >  MORTAR_RING_MISSILE_FIRE_DISTANCE_THRESHOLD * MORTAR_RING_MISSILE_FIRE_DISTANCE_THRESHOLD )
	{
		FireSegmentData segment = CreateFireSegmentData( startPos, startPos, dir, dirToCenter, projectile, hitEnt )
		segmentsArray.append( segment )
	}
	else
	{
		array< entity > ignoreArray = [ ]
		ignoreArray.append( projectile )
		ignoreArray.append( projectile2 )
		float flattenedDistance = Distance2D( startPos , endPos )

		vector newEndPos = FindValidEndPosForFireSegment( startPos, endPos - startPos, flattenedDistance, hitEnt, ignoreArray )
		if( Distance( newEndPos , endPos  ) < 20 )
		{
			FireSegmentData segment = CreateFireSegmentData( startPos, endPos, dir, dirToCenter, projectile, hitEnt )
			segmentsArray.append( segment )
		}
		else
		{
			FireSegmentData segment = CreateFireSegmentData( startPos, newEndPos, dir, dirToCenter, projectile, hitEnt )
			segmentsArray.append( segment )

			flattenedDistance = Distance2D( endPos , newEndPos )
			newEndPos = FindValidEndPosForFireSegment( endPos, startPos - endPos, flattenedDistance,  hitEnt2, ignoreArray )
			FireSegmentData segment2 = CreateFireSegmentData( endPos, newEndPos, dir, dirToCenter, projectile2, hitEnt2 )
			segmentsArray.append( segment2 )
		}
	}


	foreach ( segment in segmentsArray )
	{
		#if DEVELOPER && MORTAR_RING_MISSILE_DEBUG
			DebugDrawSphere( segment.startPos + <0, 0, 10> , 10, COLOR_RED, true, 25.0 )
			DebugDrawArrow( segment.startPos, segment.endPos, 25, COLOR_BLUE, true, 25.0)
			DebugDrawSphere( segment.endPos, 10, COLOR_GREEN, true, 25.0 )
		#endif
	}

	waitthread MortarRingCreateFireSegmentsFromArray( owner, segmentsArray )
}

FireSegmentData function CreateFireSegmentData( vector startPos, vector endPos, vector dir, vector dirToCenter, entity projectile, entity hitEnt )
{
	FireSegmentData segment
	segment.startPos = startPos
	segment.endPos = endPos
	segment.angles = VectorToAngles( dir )
	segment.dirToCenter = dirToCenter
	segment.realms = projectile.GetRealms()

	if ( IsValid( hitEnt ) )
	{
		segment.moveParent = hitEnt
		segment.endPos = CalcWorldToLocalOrigin_Entity( hitEnt, segment.endPos )
		segment.startPos = CalcWorldToLocalOrigin_Entity( hitEnt, segment.startPos )
		segment.angles = CalcWorldToLocalAngles_Entity( hitEnt, segment.angles )
	}

	return segment
}

vector function FindValidEndPosForFireSegment( vector startPos, vector dir, float maxFlattnedDistance, entity moveParent, array< entity > ignoreArray )
{
	vector flattenedDir = FlattenNormalizeVec( dir )
	vector traceStart = startPos + < 0, 0, MORTAR_RING_MISSILE_FIRE_FWD_TRACE_HEIGHT >
	vector lastGoodEndPos = startPos
	bool endTraces = false
	float distanceRemaining = maxFlattnedDistance


	// Start at MORTAR_RING_MISSILE_FIRE_FWD_TRACE_HEIGHT above the startPos
	// Do successive traces forward along flattenedDir and down MORTAR_RING_MISSILE_FIRE_DOWN_TRACE_LENGTH units
	// Set new startPos at MORTAR_RING_MISSILE_FIRE_FWD_TRACE_HEIGHT above the end of the down trace in the previous step
	// Continue the loop until the fwd trace hits something(wall, object), the downtrace doesn't hit something (we're going off a cliff ), or we've travelled maxFlattnedDistance
	// Return the last valid down trace end pos
	while( !endTraces )
	{
		float traceStep = MORTAR_RING_MISSILE_FIRE_FWD_TRACE_STEP
		if( max( 0, distanceRemaining ) < traceStep )
		{
			traceStep = distanceRemaining
			endTraces = true
		}

		vector traceFwdEnd = traceStart + flattenedDir * traceStep
		TraceResults forwardTrace = TraceLine( traceStart, traceFwdEnd, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if( forwardTrace.fraction < 1.0 )
		{
			endTraces = true
		}
		#if DEVELOPER && MORTAR_RING_MISSILE_DEBUG
			DebugDrawLine( traceStart, forwardTrace.endPos, COLOR_GREEN, true, 25.0 )
		#endif

		vector traceDownEnd = forwardTrace.endPos + < 0, 0, -MORTAR_RING_MISSILE_FIRE_DOWN_TRACE_LENGTH >
		TraceResults downTrace = TraceLine( forwardTrace.endPos, traceDownEnd, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if( downTrace.fraction == 1.0 ||
			( IsValid( moveParent ) && moveParent != downTrace.hitEnt ) ||
			( !IsValid( moveParent ) && IsValid( downTrace.hitEnt ) && !downTrace.hitEnt.IsWorld()))
		{
			endTraces = true
		}
		else
		{
			lastGoodEndPos = downTrace.endPos
			traceStart = downTrace.endPos + < 0, 0, MORTAR_RING_MISSILE_FIRE_FWD_TRACE_HEIGHT >
		}
		#if DEVELOPER && MORTAR_RING_MISSILE_DEBUG
			DebugDrawLine( forwardTrace.endPos, downTrace.endPos, COLOR_BLUE, true, 25.0 )
		#endif

		if( Distance( FlattenVec( startPos ), FlattenVec( downTrace.endPos ) ) >= maxFlattnedDistance )
		{
			endTraces = true
		}
		distanceRemaining = maxFlattnedDistance - Distance( FlattenVec( startPos ), FlattenVec( traceStart ) )
	}

	return lastGoodEndPos
}

void function MortarRingCreateFireSegmentsFromArray( entity owner, array<FireSegmentData> segmentsArray )
{
	foreach ( segment in segmentsArray )
	{
		thread MortarRingCreateFireSegment( owner, segment )
		WaitFrame()
	}
}


void function MortarRingCreateFireSegment( entity owner, FireSegmentData segment )
{
	vector effectWorldOrigin = segment.endPos
	vector effectWorldAngles = segment.angles
	vector controlPointWorldOrigin = segment.startPos
	if ( IsValid( segment.moveParent ) )
	{
		effectWorldOrigin = CalcLocalToWorldOrigin_Entity( segment.moveParent, segment.endPos )
		effectWorldAngles = CalcLocalToWorldOrigin_Entity( segment.moveParent, segment.angles )
		controlPointWorldOrigin = CalcLocalToWorldOrigin_Entity( segment.moveParent, segment.startPos )
	}
	float radius = Distance( FlattenVec( effectWorldOrigin ), FlattenVec( controlPointWorldOrigin ) ) / 2.0
	if( radius == 0.0 )
		radius = MORTAR_RING_FIRE_SEGMENT_DEFAULT_RADIUS

	entity preBurnControlPointEntity = CreateEntity( "info_target" )
	preBurnControlPointEntity.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( preBurnControlPointEntity )
	//SetRealms( preBurnControlPointEntity, segment.realms )
	preBurnControlPointEntity.SetOrigin( controlPointWorldOrigin )
	entity preburnEffect = CreateFireSegmentEffect( MORTAR_RING_MISSILE_PREBURN_FX, preBurnControlPointEntity, effectWorldOrigin, effectWorldAngles, segment.dirToCenter, MORTAR_RING_MISSILE_PREBURN_DURATION )
	if( IsValid( segment.moveParent ) )
	{
		preburnEffect.SetParent( segment.moveParent )
		preburnEffect.SetLocalOrigin( segment.endPos )
		preburnEffect.SetLocalAngles( segment.angles )
		preBurnControlPointEntity.SetParent( segment.moveParent )
		preburnEffect.SetLocalOrigin( segment.startPos )
		preburnEffect.SetLocalAngles( segment.angles )
	}
	thread MortarRingFireSegmentTriggerThread( preburnEffect, preBurnControlPointEntity, segment.moveParent, owner, radius, true )

	wait MORTAR_RING_MISSILE_PREBURN_DURATION

	entity burnControlPointEntity = CreateEntity( "info_target" )
	burnControlPointEntity.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( burnControlPointEntity )
	//SetRealms( burnControlPointEntity, segment.realms )
	burnControlPointEntity.SetOrigin( controlPointWorldOrigin )
	entity burnEffect = CreateFireSegmentEffect( MORTAR_RING_MISSILE_BURN_FX, burnControlPointEntity, effectWorldOrigin, effectWorldAngles, segment.dirToCenter, MORTAR_RING_MISSILE_BURN_DURATION )
	if( IsValid( segment.moveParent ) )
	{
		burnEffect.SetParent( segment.moveParent )
		burnEffect.SetLocalOrigin( segment.endPos )
		burnEffect.SetLocalAngles( segment.angles )
		burnControlPointEntity.SetParent( segment.moveParent )
		burnControlPointEntity.SetLocalOrigin( segment.startPos )
		burnControlPointEntity.SetLocalAngles( segment.angles )
	}
	AI_CreateDangerousArea_Static( burnEffect, owner, radius, TEAM_INVALID, true, true, segment.endPos )
	thread MortarRingFireSegmentTriggerThread( burnEffect, burnControlPointEntity, segment.moveParent, owner, radius, false )

	if ( MORTAR_RING_MISSILE_FIRE_START_SFX != "" )
		EmitSoundOnEntity( burnEffect, MORTAR_RING_MISSILE_FIRE_START_SFX )
}


void function MortarRingFireSegmentTriggerThread( entity effect, entity controlPoint, entity moveParent, entity owner, float radius, bool preburn )
{
	vector effectPos = effect.GetOrigin()
	vector controlPointPos = controlPoint.GetOrigin()
	vector trigOrigin = ( effectPos + controlPointPos ) / 2.0
	float height = fabs( effectPos.z - controlPointPos.z  ) / 2.0

	entity trigger = CreateEntity( "trigger_cylinder_heavy" )
	trigger.SetOrigin( trigOrigin )
	trigger.SetAngles( effect.GetAngles() )
	trigger.SetRadius( radius )
	trigger.SetAboveHeight( height + MORTAR_RING_FIRE_SEGMENT_HEIGHT )
	trigger.SetBelowHeight( height )
	trigger.SetTriggerType( TT_MORTAR_RING_SEGMENT )
	if( !preburn )
		MortarRingSendSegmentEndpointsToClients( trigger, effect, controlPoint )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 1
	trigger.e.attachedEnts.append( effect )
	trigger.e.attachedEnts.append( controlPoint )
	trigger.e.isBusy = preburn
	trigger.e.usePlayer = owner
	DispatchSpawn( trigger )

	if ( IsValid( moveParent ) )
	{
		trigger.SetParent( moveParent )
		moveParent.EndSignal( "OnDestroy" )
	}

	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( controlPoint )

	effect.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( effect, trigger, controlPoint, preburn )
		{
			EffectStop( effect )

			if ( IsValid( trigger ) )
				trigger.Destroy()

			if ( IsValid( controlPoint ) )
				controlPoint.Destroy()
		}
	)

	trigger.SetEnterCallback( MortarRingFireSegmentTriggerEnter )
	trigger.SearchForNewTouchingEntity()

	while ( true )
	{
		#if DEVELOPER && MORTAR_RING_MISSILE_DEBUG
			DebugDrawCylinder( trigger.GetOrigin(), <270,0,0>, radius, height + MORTAR_RING_FIRE_SEGMENT_HEIGHT, COLOR_WHITE, true, 0.1 )
			DebugDrawCylinder( trigger.GetOrigin(), <270,0,0>, radius, -height, COLOR_WHITE, true, 0.1 )
			DebugDrawSphere( effect.GetOrigin(), 10, COLOR_GREEN, true, 0.1 )
			DebugDrawSphere( controlPoint.GetOrigin() + <0, 0, 10> , 10, COLOR_RED, true, 0.1 )
			DebugDrawArrow( controlPoint.GetOrigin(), effect.GetOrigin(), 25, COLOR_BLUE, true, 0.1)
			DebugDrawLine( effect.GetOrigin(), controlPoint.GetOrigin(), COLOR_GREEN, true, 0.1 )
		#endif
		WaitFrame()
	}
}

void function MortarRingFireSegmentTriggerEnter( entity trigger, entity ent )
{
	if ( !ent.DoesShareRealms( trigger ) )
		return

	if( !IsAlive( ent ) )
		return

	thread MortarRingFireSegmentInTriggerThread( trigger, ent )
}

void function MortarRingFireSegmentInTriggerThread( entity trigger, entity ent )
{
	ent.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )

	entity effect = trigger.e.attachedEnts[ 0 ]
	if( !IsValid( effect ) )
		return
	effect.EndSignal( "OnDestroy" )

	entity controlPoint = trigger.e.attachedEnts[ 1 ]
	if( !IsValid( controlPoint ) )
		return
	controlPoint.EndSignal( "OnDestroy" )

	entity owner = trigger.e.usePlayer
	bool preburn = trigger.e.isBusy
	bool isPlayer = ent.IsPlayer() || ent.IsNPC()
	//bool isTurret = ent.IsTurretEnt()
	entity lastDriver = null

	BurnDamageSettings nonPlayerBurnSettings
	nonPlayerBurnSettings.burnDamage = MORTAR_RING_NON_PLAYER_BURN_DAMAGE
	nonPlayerBurnSettings.burnTime= MORTAR_RING_NON_PLAYER_BURN_TIME
	nonPlayerBurnSettings.burnStacksMax = MORTAR_RING_NON_PLAYER_BURN_STACKS_MAX
	nonPlayerBurnSettings.burnStackDebounce = MORTAR_RING_NON_PLAYER_BURN_STACK_DEBOUNCE
	nonPlayerBurnSettings.burnTickRate = MORTAR_RING_NON_PLAYER_BURN_TICK_RATE
	nonPlayerBurnSettings.damageSourceID = eDamageSourceId.mp_weapon_mortar_ring

	table<entity, int> effectHandleMap
	effectHandleMap[ ent ] <- -1
	OnThreadEnd(
		function() : ( ent, effectHandleMap )
		{
			foreach ( entity mapEnt, int effecthandle in effectHandleMap )
			{
				if( IsValid( mapEnt ) && effecthandle != -1 )
				{
					StatusEffect_Stop( mapEnt, effecthandle )
				}
			}
		}
	)

	while ( trigger.IsTouching( ent ) )
	{
		vector effectOrigin = effect.GetOrigin()
		vector cpOrigin = controlPoint.GetOrigin()
		vector entOrigin = ent.GetOrigin()
		vector closestBottomPoint = GetClosestPointOnLineSegment( effectOrigin, cpOrigin, entOrigin  )
		float entHeight = entOrigin.z
		float bottomHeight = closestBottomPoint.z - 5.0 // Slightly below the line to give some bugger
		float topHeight = bottomHeight + MORTAR_RING_FIRE_SEGMENT_HEIGHT
		vector flattenedEntOrigin = FlattenVec( entOrigin )
		vector closestFlattenedPoint = FlattenVec( closestBottomPoint )
		vector startPoint = < closestBottomPoint.x, closestBottomPoint.y, entOrigin.z >

		// To be considered 'in the fire':
		// 1) The ent z value must be at or above the line created by the effect and control points but below the height of the fire
		// 2) The ent must be less than or at MORTAR_RING_FIRE_SEGMENT_WIDTH from middle of the fire segment
		// 3) The ent must have line of sight from the closest point to it in the middle of the fire segment. This lets walls block damage.
		if( entHeight >= bottomHeight &&
			entHeight <= topHeight &&
			DistanceSqr( flattenedEntOrigin, closestFlattenedPoint ) <= MORTAR_RING_FIRE_SEGMENT_WIDTH_SQR &&
			PositionHasLOSToObject( startPoint, ent ) )
		{
			if( preburn )
			{
				if( !ent.e.mortarRingPreburnInflictors.contains( owner ) )
					thread PreburnDamageThink( ent, owner, trigger )
			}
			else
			{
				if ( isPlayer && !ent.IsPhaseShifted() )
				{
					if( effectHandleMap[ ent ] == -1 )
						effectHandleMap[ ent ] = StatusEffect_AddEndless( ent, eStatusEffect.in_mortar_ring, 1.0 )

					if( !ent.e.mortarRingBurnInflictors.contains( owner ) )
						thread BurnDamageThink( ent, owner, trigger )
				}
				else
				{
					//If this is a turret then do damage to the driver as they won't detected by the trigger
					/*if( isTurret )
					{
						entity driver = ent.GetDriver()
						if( IsValid( lastDriver ) && lastDriver != driver )
						{
							StatusEffect_Stop( lastDriver, effectHandleMap[ lastDriver ] )
							effectHandleMap[ lastDriver ] = -1
						}
						if( IsValid( driver ) )
						{
							lastDriver = driver

							if( !( driver in effectHandleMap ) )
								effectHandleMap[ driver ] <- -1

							if( effectHandleMap[ driver ] == -1 )
								effectHandleMap[ driver ] = StatusEffect_AddEndless( driver, eStatusEffect.in_mortar_ring, 1.0 )

							if( !driver.e.mortarRingBurnInflictors.contains( owner ) )
								thread BurnDamageThink( driver, owner, trigger )
						}
						else
						{
							lastDriver = null
						}
					}*/
					TryApplyingBurnDamage( ent, owner, owner, nonPlayerBurnSettings )
				}
			}
		}
		else
		{
			foreach ( entity mapEnt, int effecthandle in effectHandleMap )
			{
				if( IsValid( mapEnt ) && effecthandle != -1 )
				{
					StatusEffect_Stop( mapEnt, effecthandle )
					effectHandleMap[ ent ] = -1
				}
			}
		}
		WaitFrame()
	}
}
void function PreburnDamageThink( entity target, entity attacker, entity trigger )
{
	target.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( target, attacker )
		{
			if ( IsValid( target ) )
				target.e.mortarRingPreburnInflictors.fastremovebyvalue( attacker )
		}
	)

	bool targetIsPlayer = target.IsPlayer() || target.IsNPC()
	target.e.mortarRingPreburnInflictors.append( attacker )
	entity damageOwner = IsValid( attacker ) ? attacker : svGlobal.worldspawn
	if( targetIsPlayer )
	{



		if( !IsFriendlyTeam( damageOwner.GetTeam(), target.GetTeam() ) || ( damageOwner == target ) )

			target.TakeDamage( MORTAR_RING_PREBURN_DAMAGE_PLAYER, damageOwner, trigger, { damageSourceId = eDamageSourceId.mp_weapon_mortar_ring } )
	}
	else
	{
		target.TakeDamage( MORTAR_RING_PREBURN_DAMAGE_NON_PLAYER, damageOwner, trigger, { damageSourceId = eDamageSourceId.mp_weapon_mortar_ring } )
	}

	WaitForever()
}

void function BurnDamageThink( entity target, entity attacker, entity trigger )
{
	if( target.IsPlayer() )
	{
		target.EndSignal( "OnDeath" )
		target.EndSignal( DEATH_TOTEM_RECALL_SIGNAL )
	}
	target.EndSignal( "OnDestroy" )

	int moveSlowEffectID = SE_INVALID_HANDLE

	if( !target.IsPlayer() || !PlayerHasPassive( target, ePassives.PAS_MOTHERLODE_RESISTANCE ) ) //upgrade_fuse_motherlode_resistance

		moveSlowEffectID = StatusEffect_AddEndless( target, eStatusEffect.move_slow, 0.25 )
	int burnEffectID = StatusEffect_AddEndless( target, eStatusEffect.mortar_ring_burn, 1.0 )
	target.e.mortarRingBurnInflictors.append( attacker )

	if( target.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( target, target, "Firebomb_damaging_loop_1p" )
		EmitSoundOnEntityExceptToPlayer( target, target, "Firebomb_damaging_loop_3p" )
	}
	else
	{
		EmitSoundOnEntity( target, "Firebomb_damaging_loop_3p" )
	}

	OnThreadEnd(
		function() : ( target, burnEffectID, moveSlowEffectID, attacker )
		{
			if ( IsValid( target ) )
			{
				if( moveSlowEffectID != SE_INVALID_HANDLE )
					StatusEffect_Stop( target, moveSlowEffectID )
				StatusEffect_Stop( target, burnEffectID )
				StopSoundOnEntity( target, "Firebomb_damaging_loop_1p" )
				StopSoundOnEntity( target, "Firebomb_damaging_loop_3p" )
				target.e.mortarRingBurnInflictors.fastremovebyvalue( attacker )
			}
		}
	)

	float startTime = Time()
	int tickIndex = 0
	while ( true )
	{
		tickIndex++
		//If owner is valid owner is damage owner, if owner is invalid world is damage owner
		entity damageOwner = IsValid( attacker ) ? attacker : svGlobal.worldspawn
		float multiplier = StatusEffect_HasSeverity( target, eStatusEffect.in_mortar_ring ) ? MORTAR_RING_IN_FIRE_DAMAGE_MULTIPLIER : 1.0
		float damage  = ( tickIndex == 1 ) ? MORTAR_RING_FIRST_TICK_DAMAGE : ( MORTAR_RING_SUBSEQUENT_TICK_DAMAGE * multiplier )


		if( target.IsPlayer() && PlayerHasPassive( target, ePassives.PAS_MOTHERLODE_RESISTANCE ) ) //upgrade_fuse_motherlode_resistance
		{
			if ( tickIndex == 1 )
				damage = 20.0
			else
			{
				wait 1.0
				return
			}
		}





		if( !IsFriendlyTeam( damageOwner.GetTeam(), target.GetTeam() ) || ( damageOwner == target ) )

			target.TakeDamage( damage, damageOwner, trigger, { damageSourceId = eDamageSourceId.mp_weapon_mortar_ring } )

		wait MORTAR_RING_MISSILE_TICK_INTERVAL

		if( tickIndex == MORTAR_RING_MISSILE_NUM_TICKS )
			break
	}
}

entity function CreateFireSegmentEffect( asset effectAsset, entity controlPoint, vector endPos, vector angles, vector dirToCenter, float duration )
{
	entity effect = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( effectAsset ), endPos, angles )
	effect.RemoveFromAllRealms()
	effect.AddToOtherEntitysRealms( controlPoint )

	EffectSetControlPointEntity( effect, 1, controlPoint )
	EffectSetControlPointVector( effect, 2, dirToCenter )

	if ( duration > 0 )
		EntFireByHandle( effect, "Kill", "", duration, null, null )

	return effect
}

void function MortarRing_FireDamagedTarget( entity victim, var damageInfo )
{
	// Seems like we need this since the invulnerability from phase shift has not kicked in at this point yet
	if ( victim.IsPhaseShifted() )
		return
}

entity function AddMortarRingBombletWeapon( entity player )
{
	return VerifyBombardmentWeapon( player, MORTAR_RING_MISSILE_WEAPON )
}

void function MortarRingAirburst( entity player, entity projectile, int numBombs, float launchAngle, float launchSpeed, float radiusModMin = 1.0, float radiusModMax = 1.0 )
{
	vector projectileOrigin = projectile.GetOrigin()
	StartParticleEffectInWorld( GetParticleSystemIndex( MORTAR_RING_AIRBURST_EXPLOSION_VFX ), projectileOrigin, ZERO_VECTOR )
	EmitSoundAtPosition( TEAM_ANY, projectileOrigin, MORTAR_RING_AIRBURST_EXPLOSION_SFX, projectile )

	projectile.Destroy()

	if( !IsValid( player ) )
		return

	entity mortarRingBombletWeapon = AddMortarRingBombletWeapon( player )
	if ( !IsValid( mortarRingBombletWeapon ) )
		return

	vector groundPos = OriginToGround( projectileOrigin )

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_MORTAR_RING_END, player, groundPos, player.GetTeam(), player )


	//if ( !Trophy_PointInRangeOfAnyTrophy( groundPos ) )
		//thread MortarRingReveal_SonarThink( player, projectileOrigin, Normalize( groundPos - projectileOrigin ), Distance( projectileOrigin, groundPos ) )


	array<vector> orderedTargetPoints = GetTargetPointsAroundOrigin( projectileOrigin, numBombs, 420.0, -750.0, radiusModMin, radiusModMax )
	#if DEVELOPER && MORTAR_RING_MISSILE_DEBUG
		DebugDrawSphere( projectileOrigin, 10, COLOR_BLUE, true, 10.0 )
	#endif

	int currentIndex = 0
	array<vector> randomizedTargetPoints = clone orderedTargetPoints
	randomizedTargetPoints.randomize()
	array< entity > bombletArray
	foreach ( testPoint in randomizedTargetPoints )
	{
		if( bombletArray.len() != currentIndex )
			break

		currentIndex++

		if( currentIndex % 3 == 0 )
			wait 0.1

		thread LaunchBomblet( player, mortarRingBombletWeapon, projectileOrigin, testPoint, launchSpeed, bombletArray )
	}

	int bombletArrayLength = bombletArray.len()
	for( int randIndex = 0; randIndex < bombletArrayLength; randIndex++ )
	{
		int nextNormalIndex = 0
		int normalIndex =  orderedTargetPoints.find( randomizedTargetPoints[ randIndex ] )
		if( normalIndex != numBombs - 1 )
		{
			nextNormalIndex = normalIndex + 1
		}

		int nextRandIndex = randomizedTargetPoints.find( orderedTargetPoints[ nextNormalIndex ] )
		if( nextRandIndex < bombletArrayLength )
		{
			entity bomblet = bombletArray[ randIndex ]
			if( IsValid( bomblet ) )
			{
				bomblet.proj.trackedEnt = IsValid( bombletArray[ nextRandIndex ] ) ? bombletArray[ nextRandIndex ] : null
			}
		}
	}

	//StatsHook_MotherlodeEnemiesCaptured( player, bombletArray )
}

void function LaunchBomblet( entity player, entity weapon, vector origin, vector target, float launchSpeed, array<entity> bombArray )
{
	if( !IsValid( weapon ) )
		return

	vector dirFromCenter = FlattenNormalizeVec( target - origin )
	ArcSolution as = SolveBallisticArc( origin, launchSpeed, target, GetConVarFloat( "sv_gravity" ) )
	vector velocity = ( as.valid ) ? as.fire_velocity : dirFromCenter * launchSpeed
#if DEVELOPER && MORTAR_RING_MISSILE_DEBUG
	if( !as.valid )
		DebugDrawSphere( target, 10, COLOR_RED, true, 10.0 )
	else
		DebugDrawSphere( target, 10, COLOR_BLUE, true, 10.0 )
#endif


	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = origin
	fireGrenadeParams.vel = velocity
	fireGrenadeParams.angVel = <RandomFloatRange( 30, 50 ), 900, 0>
	fireGrenadeParams.scriptTouchDamageType = damageTypes.projectileImpact
	fireGrenadeParams.scriptExplosionDamageType = damageTypes.explosive
	fireGrenadeParams.clientPredicted = false
	fireGrenadeParams.lagCompensated = true
	fireGrenadeParams.useScriptOnDamage = true
	entity bomb = weapon.FireWeaponGrenade( fireGrenadeParams )

	if( IsValid( bomb ) )
	{
		bomb.SetInvulnerable()
		bomb.proj.mortarRingDirFromCenter = dirFromCenter
		bomb.proj.mortarRingDirForFireEffect = FlattenNormalizeVec( CrossProduct( bomb.proj.mortarRingDirFromCenter, < 0, 0, 1> ) )
		thread PlayBombMovementSFX( bomb )

	}

	bombArray.append( bomb )
}

void function PlayBombMovementSFX( entity bomb )
{
	bomb.EndSignal( "OnDestroy" )

	if( MORTAR_RING_MISSILE_MOVEMENT_SFX == "" )
		return

	OnThreadEnd(
		function() : ( bomb )
		{
			if ( IsValid( bomb ) )
			{
				StopSoundOnEntity( bomb, MORTAR_RING_MISSILE_MOVEMENT_SFX )
			}
		}
	)

	EmitSoundOnEntity( bomb, MORTAR_RING_MISSILE_MOVEMENT_SFX )
	while( !bomb.proj.bombletLanded )
		WaitFrame()
}

array<vector> function GetTargetPointsAroundOrigin( vector centerOrigin, int pointCount, float radius, float verticalOffset, float radiusModMin = 1.0, float radiusModMax = 1.0 )
{
	array<vector> points
	for ( int i = 0; i < pointCount; i++ )
	{
		//Get our position
		float aStep = GraphCapped( i, 0, pointCount, 0.0, 1.0 )
		//printt( aStep )

		float a     = aStep
		float b     = 1
		float theta = (PI * 2) * a
		float r     = sqrt( b )

		float offsetX = (r * cos( theta ))
		float offsetY = (r * sin( theta ))

		vector initialDirection = Normalize( (centerOrigin + < offsetX, offsetY, 0 >) - centerOrigin )
		vector targetPoint = centerOrigin + ( initialDirection * radius * RandomFloatRange( radiusModMin, radiusModMax ) )
		targetPoint.z += verticalOffset

		points.append( targetPoint )
	}

	return points
}


void function MortarRingReveal_SonarThink( entity owner, vector scanOrigin, vector scanDirection, float distToGround )
{
	float scanDuration = 18.0
	bool showCone = false

	EndSignal( owner, "OnDeath", "OnDestroy" )

	int team = owner.GetTeam()
	vector pulseOrigin = scanOrigin
	array<entity> ents = []

	float heightFrac = ( distToGround / MORTAR_RING_BOMB_AIRBURST_HEIGHT )
	float scanRadius = FUSE_MORTAR_SCAN_RADIUS_BASE * heightFrac
	float scanLength = max( FUSE_MORTAR_SCAN_LENGTH_BASE * heightFrac, FUSE_MORTAR_SCAN_LENGTH_MIN )
	entity trigger = CreateTriggerRadiusMultiple_Deprecated( pulseOrigin, scanRadius, ents, TRIG_FLAG_START_DISABLED | TRIG_FLAG_NO_PHASE_SHIFT, scanLength )
	trigger.e.sonarConeDirection 	= scanDirection
	trigger.e.sonarConeFOV 			= 125.0 //AreaSonarScan_GetConeFOV()
	trigger.e.sonarConeDetections	= 0
	SetTeam( trigger, team )
	trigger.SetOwner( owner )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( owner )

	OnThreadEnd(
		function() : ( trigger )
		{
			trigger.Destroy()
		}
	)

	AddCallback_ScriptTriggerEnter_Deprecated( trigger, MortarRingReveal_OnTriggerEnter )
	AddCallback_ScriptTriggerLeave_Deprecated( trigger, MortarRingReveal_OnTriggerLeave )

	ScriptTriggerSetEnabled_Deprecated( trigger, true )

	if ( showCone )
		MortarRingReveal_BroadcastPulseConeEffectToPlayers( pulseOrigin, trigger.e.sonarConeDirection, trigger.e.sonarConeFOV, GetPlayerArray(), team, owner, 1200.0 )

	wait scanDuration
}

void function MortarRingReveal_BroadcastPulseConeEffectToPlayers( vector pulseConeOrigin, vector pulseConeDir, float pulseConeFOV, array<entity> players, int team, entity owner, float scanRadius )
{
	foreach ( player in players )
	{
		bool showTrail = ( owner == player )
		if ( owner.DoesShareRealms( player ) )
			Remote_CallFunction_Replay( player, "ServerCallback_SonarPulseConeFromPosition", pulseConeOrigin, scanRadius, pulseConeDir, pulseConeFOV, team, 1.0, true, showTrail )
	}
}


float function MortarRingCenterDamagePerTick()
{
	return GetCurrentPlaylistVarFloat( "mortar_ring_center_damage_per_tick" , 5.0 )
}

float function MortarRingCenterWaitTime()
{
	return GetCurrentPlaylistVarFloat( "mortar_ring_center_damage_wait_time" , 2.0 )
}

void function MortarRingCenterDamage_Thread( entity victim, entity owner )
{
	owner.EndSignal( "EndMotherlodeCenterDamage" )

	while( true )
	{
		victim.TakeDamage( MortarRingCenterDamagePerTick(), owner, owner, { damageSourceId = eDamageSourceId.mp_weapon_mortar_ring } )
		Wait( MortarRingCenterWaitTime() )
	}
}


void function MortarRingReveal_OnTriggerEnter( entity trigger, entity victim )
{
	if ( !IsValid( victim ) )
		return

	if ( !victim.IsPlayer() && !victim.IsNPC() )
		return

	if ( !IsEnemyTeam( trigger.GetTeam(), victim.GetTeam() ) )
		return

	if ( !victim.DoesShareRealms( trigger ) )
		return

	//Only ping players that are within our sonar cone.
	vector posToTarget = Normalize( victim.GetCenter() - trigger.GetOrigin() )
	float dot = DotProduct( posToTarget, trigger.e.sonarConeDirection )
	float angle = DotToAngle( dot )
	entity owner = trigger.GetOwner()


	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_fuse_motherlode_inner_damage
	{
		//thread MortarRingCenterDamage_Thread( victim, owner ) //todo: Upgrade Removed - needs design iteration & production support for future consideration
	}


	//If entity is not in sonar cone don't add it as a target. fudge angle when target is very close
	float distSqr = Distance2DSqr( victim.GetCenter(), trigger.GetOrigin() )
	float matchAngle = GraphCapped( distSqr, 32*32, 128*128, trigger.e.sonarConeFOV, trigger.e.sonarConeFOV / 2 )
	if ( angle > matchAngle )
		return


		victim.Signal( "MortarRing_OnEnterArea" )


	if ( !(victim in file.entityRevealHandles) )
	{
		file.entityRevealHandles[victim] <- []

			if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_fuse_motherlode_extend_scan
			{
				file.playerMortarScanStartTime[victim] <- Time()

			}

	}

	//SonarStart( victim, victim.GetOrigin(), owner.GetTeam(), owner )
	//IncrementHighlightEnableForTeam( victim, GetHighlightId( HIGHLIGHT_ABILITY_REVEAL ), trigger.GetTeam() )
	int revealHandle = StatusEffect_AddEndless( victim, eStatusEffect.mortar_ring_reveal, 1.0 )
	file.entityRevealHandles[victim].append( revealHandle )
}

void function MortarRingReveal_OnTriggerLeave( entity trigger, entity victim )
{
	int triggerTeam = trigger.GetTeam()
	if ( !IsEnemyTeam( triggerTeam, victim.GetTeam() ) )
		return

	if ( !victim.IsPlayer() && !victim.IsNPC() )
		return


	entity owner = trigger.GetOwner()
	owner.Signal( "EndMotherlodeCenterDamage" )


	if ( !(victim in file.entityRevealHandles) )
		return

	//SonarEnd( victim, triggerTeam, trigger.GetOwner() )

	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_fuse_motherlode_extend_scan
	{
		float scanExtention = MortarRing_GetScanExtensionTime( victim )
		thread MortarRing_DelayRemoveEnemyScan_Thread( victim, trigger.GetTeam(), scanExtention )
	}
	else

	{
	//DecrementHighlightEnableForTeam( victim, GetHighlightId( HIGHLIGHT_ABILITY_REVEAL ), trigger.GetTeam() )

	if ( !IsValid( victim ) )
		return

	if ( file.entityRevealHandles[victim].len() > 0 )
	{
		int revealHandle = file.entityRevealHandles[victim][0]
		StatusEffect_Stop( victim, revealHandle )
		file.entityRevealHandles[victim].fastremovebyvalue( revealHandle )
	}
	}
}



float function MortarRing_GetScanExtensionTime( entity victim )
{
	float extTime = 0.0
	if( !IsValid( victim ) )
		return extTime

	if( victim in file.playerMortarScanStartTime )
		extTime = min( MortarRing_GetMaxScanExtendTime(), 1 + ( Time() - file.playerMortarScanStartTime[victim] ) )

	return extTime
}

float function MortarRing_GetMaxScanExtendTime()
{
	return GetCurrentPlaylistVarFloat( "mortar_ring_scan_extend_time_max" , FUSE_MORTAR_SCAN_UPGRADE_EXTEND_TIME_MAX )
}

void function MortarRing_DelayRemoveEnemyScan_Thread( entity victim, int team, float scanExtension )
{
	EndSignal( victim, "OnDeath" )
	EndSignal( victim, "OnDestroy" )
	EndSignal( victim, "MortarRing_OnEnterArea" )

	OnThreadEnd(
		function() : ( victim, team )
		{
			if( IsValid( victim ) )
			{
				//DecrementHighlightEnableForTeam( victim, GetHighlightId( HIGHLIGHT_ABILITY_REVEAL ), team)
				if ( file.entityRevealHandles[victim].len() > 0 )
				{
					int revealHandle = file.entityRevealHandles[victim][0]
					StatusEffect_Stop( victim, revealHandle )
					file.entityRevealHandles[victim].fastremovebyvalue( revealHandle )
				}
			}
		}
	)

	wait scanExtension
}

#endif

#if CLIENT

void function MortarRingReveal_RevealStatusChanged( entity ent, int statusEffect, bool actuallyChanged )
{
	ManageHighlightEntity( ent )
}


void function AddThreatIndicator( entity bomb )
{
	entity player = GetLocalViewPlayer()
	ShowGrenadeArrow( player, bomb, MORTAR_RING_MISSILE_THREAT_INDICATOR_DIST, 0.0 )
}

void function MortarRingBurn_StartVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	ent.Signal( KILL_BURN_FX_SIGNAL )
	thread MortarRingBurnVFXThink( ent )
}

void function MortarRingBurn_StopVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	ent.Signal( KILL_BURN_FX_SIGNAL )
}

void function MortarRingBurnVFXThink( entity player )
{
	player.EndSignal( KILL_BURN_FX_SIGNAL )
	player.EndSignal( "OnDeath" )

	int fxid = GetParticleSystemIndex( MORTAR_RING_MISSILE_PLAYER_BURN_FX )
	int fxHandle = StartParticleEffectOnEntityWithPos( player, fxid, FX_PATTACH_ABSORIGIN_FOLLOW, -1, player.EyePosition(), <0,0,0> )
	//EffectSetIsWithCockpit( fxHandle, true )
	EffectSetControlPointVector( fxHandle, 1, <MORTAR_RING_MISSILE_PLAYER_BURN_FX_SEVERITY, 999, 0> )
	thread ColorCorrection_LerpWeight( file.colorCorrection, 0, MORTAR_RING_COLOR_CORRECTION_BASE_SEVERITY, MORTAR_RING_COLOR_CORRECTION_LERP_TIME )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			thread ColorCorrection_LerpWeight( file.colorCorrection, MORTAR_RING_COLOR_CORRECTION_BASE_SEVERITY, 0, MORTAR_RING_COLOR_CORRECTION_LERP_TIME )
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)
	WaitForever()
}

void function ColorCorrection_LerpWeight( int colorCorrection, float startWeight, float endWeight, float lerpTime = 0 )
{
	float startTime = Time()
	float endTime = startTime + lerpTime
	ColorCorrection_SetExclusive( colorCorrection, true )

	while ( Time() <= endTime )
	{
		WaitFrame()
		float weight = GraphCapped( Time(), startTime, endTime, startWeight, endWeight )
		ColorCorrection_SetWeight( colorCorrection, weight )
	}

	ColorCorrection_SetWeight( colorCorrection, endWeight )
}

void function ServerCallback_MortarRingFireSegmentCreated( entity trigger, entity start, entity end )
{
	ClientCodeCallback_MortarRingFireSegmentCreated( trigger, start, end )
}

void function ClientCodeCallback_MortarRingFireSegmentCreated( entity trigger, entity start, entity end )
{
	if ( !IsValid( trigger ) || !IsValid( start ) || !IsValid( end ) ) //This can happen now that this is a deferred callback
		return

	//SetAllowForKillreplayProjectileCam( trigger )
	//SetCustomKillreplayChaseCamFromWeaponClass( trigger, MORTAR_RING_MISSILE_WEAPON )

	thread MortarRingFireSegmentClientEffects( trigger, start, end )
}

void function MortarRingFireSegmentClientEffects( entity trigger, entity start, entity end )
{
	trigger.EndSignal( "OnDestroy" )
	start.EndSignal( "OnDestroy" )
	end.EndSignal( "OnDestroy" )

	entity localPlayer = GetLocalViewPlayer()
	if( !IsValid( localPlayer ) )
		return
	localPlayer.EndSignal( "OnDestroy" )

	vector startPoint = start.GetOrigin() + ( < 0, 0, 1 > * MORTAR_RING_MISSILE_AMBIENT_GENERIC_HEIGHT_OFFSET )
	vector endPoint = end.GetOrigin() + ( < 0, 0, 1 > * MORTAR_RING_MISSILE_AMBIENT_GENERIC_HEIGHT_OFFSET )
	entity clientAG = CreateClientSideAmbientGeneric( startPoint , MORTAR_RING_MISSILE_FIRE_LOOP_SFX, 0 )
	clientAG.SetSegmentEndpoints( startPoint, endPoint )
	clientAG.SetEnabled( true )
	clientAG.RemoveFromAllRealms()
	clientAG.AddToOtherEntitysRealms( trigger )
	clientAG.SetParent( trigger, "", true )
	file.mortarRingClientAGs.append( clientAG )

	if( file.mortarRingClientAGs.len() == 1 )
		thread ThreatIndicatorThink( localPlayer, MORTAR_RING_MISSILE_THREAT_INDICATOR_DIST )

	OnThreadEnd(
		function() : ( clientAG, localPlayer )
		{
			if ( IsValid( clientAG ) )
			{
				clientAG.Destroy()
			}

			file.mortarRingClientAGs.fastremovebyvalue( clientAG )
			if( IsValid( localPlayer ) && file.mortarRingClientAGs.len() == 0 )
				localPlayer.Signal( KILL_THREAT_INDICATOR_THREAD_SIGNAL )
		}
	)

	WaitForever()
}

void function ThreatIndicatorThink( entity player, float damageRadius )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, KILL_THREAT_INDICATOR_THREAD_SIGNAL )

	asset indicatorModel  = GRENADE_INDICATOR_GENERIC
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

	entity cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	EndSignal( cockpit, "OnDestroy" )

	arrow.SetParent( cockpit, "CAMERA_BASE" )
	arrow.SetAttachOffsetOrigin( <25, 0, -4> )

	mdl.SetParent( arrow, "BACK" )
	mdl.SetAttachOffsetOrigin( indicatorOffset )

	float lastVisibleTime = 0
	bool shouldBeVisible  = true

	while ( true )
	{
		cockpit = player.GetCockpit()
		vector playerOrigin = player.GetOrigin()

		bool firstLoop = true
		vector closestPoint
		foreach ( clientAG in file.mortarRingClientAGs )
		{
			/*vector point = clientAG.GetSoundPositionForLocalPlayer()
			if( firstLoop )
			{
				closestPoint = point
			}
			else if( DistanceSqr( playerOrigin, closestPoint ) > DistanceSqr( playerOrigin, point) )
			{
				closestPoint = point
			}*/
			firstLoop = false
		}

		float dist = Distance( playerOrigin, closestPoint )
		if ( dist > damageRadius || !cockpit || player.IsPhaseShifted() )
		{
			shouldBeVisible = false
		}
		else
		{
			TraceResults result = TraceLine( closestPoint, player.EyePosition(), [ player ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

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

			arrow.kv.rendercolor = <0,255,0>//GetKeyColor( COLORID_HUD_INDICATOR_ARROW )
			mdl.kv.rendercolor = <0,255,0>//GetKeyColor( COLORID_HUD_INDICATOR_GRENADE_MODEL )

			arrow.DisableRenderWithViewModelsNoZoom()
			arrow.EnableRenderWithCockpit()
			arrow.EnableRenderWithHud()
			mdl.DisableRenderWithViewModelsNoZoom()
			mdl.EnableRenderWithCockpit()
			mdl.EnableRenderWithHud()

			vector damageArrowAngles = AnglesInverse( player.EyeAngles() )
			vector vecToDamage       = closestPoint - (player.EyePosition() + (player.GetViewVector() * 20.0))

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
#endif //CLIENT
 