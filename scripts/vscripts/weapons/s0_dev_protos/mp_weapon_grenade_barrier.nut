
global function MpWeaponGrenadeBarrier_Init
global function OnWeaponTossReleaseAnimEvent_weapon_grenade_barrier
global function OnProjectileCollision_weapon_grenade_barrier
global function OnProjectileExplode_weapon_grenade_barrier

const asset GRENADE_BARRIER_SPIKE_MODEL = $"mdl/test/grif_test/proto_spike_ball.rmdl"

//EXPLOSION TRACE VARS
const float GRENADE_BARRIER_SPIKE_RADIUS = 32.0
const float GRENADE_BARRIER_SPIKE_PRUNE_RADIUS = 36.0
const float GRENADE_BARRIER_PLAYER_PRUNE_RADIUS = 48.0
const float GRENADE_BARRIER_SPIKE_CLEARANCE_DEPTH = 64.0
const float GRENADE_BARRIER_TRACE_OFFSET = 48.0
const float GRENADE_BARRIER_TRACE_DEPTH = 256.0
const float GRENADE_BARRIER_TRACE_CAST_COUNT = 8

//DAMAGE VARS
const float GRENADE_BARRIER_DAMAGE_TRIGGER_RADIUS = 32.0
const float GRENADE_BARRIER_DAMAGE_INTERVAL = 1.0
const int GRENADE_BARRIER_DAMAGE = 1

//LIFETIME VARS
const float GRENADE_BARRIER_SPIKE_LIFETIME_MIN = 15.0
const float GRENADE_BARRIER_SPIKE_LIFETIME_MAX = 20.0
const float GRENADE_BARRIER_SPIKE_LIFETIME_RAND_RANGE = 2.0

const bool GRENADE_BARRIER_DEBUG_DRAW = false
const bool GRENADE_BARRIER_DEBUG_DRAW_CIRCLES = false
const bool GRENADE_BARRIER_DEBUG_DRAW_CLEARANCE = false

void function MpWeaponGrenadeBarrier_Init()
{
	PrecacheModel( GRENADE_BARRIER_SPIKE_MODEL )
}

var function OnWeaponTossReleaseAnimEvent_weapon_grenade_barrier( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	Grenade_OnWeaponTossReleaseAnimEvent( weapon, attackParams )

	entity weaponOwner = weapon.GetWeaponOwner()
	Assert( weaponOwner.IsPlayer() )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnProjectileCollision_weapon_grenade_barrier( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity player = projectile.GetOwner()
	if ( hitEnt == player )
		return

	if ( projectile.GrenadeHasIgnited() )
		return

	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}

	bool result = PlantStickyEntityOnWorldThatBouncesOffWalls( projectile, collisionParams, 0.7 )

	#if SERVER
		projectile.proj.savedDir = normal
	#endif
	projectile.GrenadeIgnite()
	projectile.SetDoesExplode( true )
}

void function OnProjectileExplode_weapon_grenade_barrier( entity projectile )
{
	//printt ( "FLASH BANG IS EXPLODING!!!" )
	#if SERVER
	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
		return

	vector flashOrigin = projectile.GetOrigin() + ( projectile.proj.savedDir * GRENADE_BARRIER_TRACE_OFFSET )
	thread GrenadeBarrier_CreateSpikes( projectile, flashOrigin )
	#endif //SERVER
}

#if SERVER
void function GrenadeBarrier_CreateSpikes( entity projectile, vector origin )
{
	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
		return

	//Destroy any surviving spikes from a pervious ability use so we don't make too many ents.
	foreach ( entity spike in owner.e.activeUltimateTraps )
	{
		if ( IsValid( spike ) )
			spike.Destroy()
	}

	owner.e.activeUltimateTraps = []

	int pruneCount = 0
	int clearanceCount = 0
	array<entity> spikes
	array<entity> ignoreEnts = GetPlayerArray_Alive()
	ignoreEnts.append( projectile )

	vector surfaceNormal = projectile.proj.savedDir

	for ( int i = 0; i <= GRENADE_BARRIER_TRACE_CAST_COUNT; i++ )
	{
		float zStep = GraphCapped( i, 0, GRENADE_BARRIER_TRACE_CAST_COUNT, -GRENADE_BARRIER_TRACE_DEPTH, GRENADE_BARRIER_TRACE_DEPTH )
		float theta = acos( ( zStep / GRENADE_BARRIER_TRACE_DEPTH ) )

		//Get number of circles we can fit in radius
		float radScalar = 1.0 - fabs( zStep / GRENADE_BARRIER_TRACE_DEPTH )
		float maxRingRadius = GRENADE_BARRIER_TRACE_DEPTH * radScalar
		float circleRadius = GRENADE_BARRIER_SPIKE_RADIUS
		int circleCount = maxRingRadius >= circleRadius ? int ( RoundToNearestInt( PI / asin( circleRadius / maxRingRadius ) ) ) : 1
		float centerAngle = 2 * PI / ( circleCount - 1 )
		float ringRadius = circleRadius / sin( centerAngle / 2 )

		//printt( zStep / GRENADE_BARRIER_TRACE_DEPTH )

		//Debug draw our max radius and our actual radius
		if ( GRENADE_BARRIER_DEBUG_DRAW_CIRCLES )
		{
			DebugDrawCircle( origin + <0,0,zStep>, <0, 0, 0>, maxRingRadius, 255, 0, 0, true, 10.0, 16 )
			DebugDrawCircle( origin + <0,0,zStep>, <0, 0, 0>, circleRadius, 0, 255, 255, true, 10.0, 16 )
		}

		//Determine number of radians to rotate per circle.
		float radiansPerCircle = ( PI * 2 ) / circleCount

		//Generate Circle Origins
		for ( int j = 0; j < circleCount; j++ )
		{
			float angle = j * radiansPerCircle

			float circleX = sin( angle ) * ringRadius
			float circleY = cos( angle ) * ringRadius
			vector circleOrigin = origin + < circleX, circleY, 0 >

			if ( GRENADE_BARRIER_DEBUG_DRAW_CIRCLES )
				DebugDrawCircle( circleOrigin + <0,0,zStep>, <0, 0, 0>, circleRadius, 255, 0, 0, true, 10.0, 16 )
		}

		for ( int j = 0; j < circleCount; j++ )
		{
			float aStep = GraphCapped( j, 0, circleCount, 0.0, 1.0 )
			float b     = 1
			float phi = atan( cos( aStep ) / sin( aStep ) ) * ( PI * 2 )
			float r     = sqrt( b )

			float offsetX = ( sin( theta ) * cos( phi )) * GRENADE_BARRIER_TRACE_DEPTH
			float offsetY = ( sin( theta ) * sin( phi )) * GRENADE_BARRIER_TRACE_DEPTH
			float offsetZ = ( cos( theta )) * GRENADE_BARRIER_TRACE_DEPTH

			vector endPoint = origin + RotateVector( <offsetX,offsetY,offsetZ>, AnglesCompose( VectorToAngles( surfaceNormal ), <-90,0,0> ) )
			vector dir = Normalize( origin - endPoint )
			TraceResults results = TraceLine( origin, endPoint, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

			if ( results.fraction < 1.0 )
			{

				//See if we hit a player or an object parented to a player
				if ( IsValid( results.hitEnt ) )
				{
					if ( results.hitEnt.IsPlayer() )
						continue

					entity hitParent = results.hitEnt.GetParent()
					if ( IsValid( hitParent ) )
					{
						if ( hitParent.IsPlayer() )
							continue
					}
				}

				//Check to see if this new spike will be too close to existing spikes.
				if ( GrenadeBarrier_ShouldPruneSpike( results.endPos, spikes ) )
				{
					pruneCount++
					continue
				}

				vector reflect =  2 * DotProduct( dir, results.surfaceNormal ) * results.surfaceNormal - dir

				//Check to see if this new spike has enough clearance to be worth making.
				if ( !GrenadeBarrier_SpikeHasClearance( results.endPos, reflect, GRENADE_BARRIER_SPIKE_CLEARANCE_DEPTH ) )
				{
					clearanceCount++
					continue
				}

				entity spike = CreatePropScript( GRENADE_BARRIER_SPIKE_MODEL, results.endPos, VectorToAngles( reflect ), SOLID_VPHYSICS )
				spike.SetOwner( owner )
				SetTeam( spike, owner.GetTeam() )

				spike.SetMaxHealth( 25 )
				spike.SetHealth( 25 )
				spike.SetTakeDamageType( DAMAGE_YES )
				SetObjectCanBeMeleed( spike, true )
				spike.SetBlocksRadiusDamage( false )

				// thread TrapDestroyOnRoundEnd( owner, spike )
				thread GrenadeBarrier_CreateDamageTrigger( spike, owner.GetTeam() )

				float lifetime = i < ( GRENADE_BARRIER_TRACE_CAST_COUNT / 2 ) ? GraphCapped( i, 0, GRENADE_BARRIER_TRACE_CAST_COUNT / 2, GRENADE_BARRIER_SPIKE_LIFETIME_MAX, GRENADE_BARRIER_SPIKE_LIFETIME_MIN ) : GraphCapped( i, GRENADE_BARRIER_TRACE_CAST_COUNT / 2, GRENADE_BARRIER_TRACE_CAST_COUNT, GRENADE_BARRIER_SPIKE_LIFETIME_MIN, GRENADE_BARRIER_SPIKE_LIFETIME_MAX )
				lifetime += RandomFloatRange( -GRENADE_BARRIER_SPIKE_LIFETIME_RAND_RANGE, GRENADE_BARRIER_SPIKE_LIFETIME_RAND_RANGE )
				thread GrenadeBarrier_DestroySpikeAfterTime( spike, owner, lifetime )

				if ( IsValid( results.hitEnt ) )
				{
					if ( EntityShouldStick( spike, results.hitEnt ) && !results.hitEnt.IsWorld() )
						spike.SetParent( results.hitEnt, "", true )
				}

				owner.e.activeUltimateTraps.insert( 0, spike )
				spikes.append( spike )
				ignoreEnts.append( spike )

				if ( GRENADE_BARRIER_DEBUG_DRAW )
				{
					DebugDrawLine( origin, endPoint, 0, 255, 0, true, 30.0 )
				}
			}
			else
			{
				if ( GRENADE_BARRIER_DEBUG_DRAW )
				{
					DebugDrawLine( origin, endPoint, 255, 0, 0, true, 30.0 )
				}
			}
		}
	}

	/*
	printt( "ENT COUNT: " + spikes.len() )
	printt( "PRUNE COUNT: " + pruneCount )
	printt( "CLEARANCE COUNT: " + clearanceCount )
	*/
}

array<vector> function GrenadeBarrier_PositionsOnSphereEdge( vector centerOrigin, float radius, int pointCount )
{
	array<vector> targets
	for ( int i = 0; i < pointCount; i++ )
	{
		//Get our position
		float aStep = GraphCapped( i, 0, pointCount, 0.0, 1.0 )
		printt( aStep )

		float a     = aStep
		float b     = 1
		float theta = (PI * 2) * a
		float r     = sqrt( b )

		float offsetX = (r * cos( theta )) * radius
		float offsetY = (r * sin( theta )) * radius
		float offsetZ = (r * tan( theta )) * radius

		vector clusterTarget = (centerOrigin + < offsetX, offsetY, offsetZ >)

		if ( GRENADE_BARRIER_DEBUG_DRAW )
		{
			DebugDrawCircle( centerOrigin, <0, 0, 0>, radius, 255, 0, 0, true, 10.0, 16 )
			DebugDrawSphere( clusterTarget, 32.0, 255, 0, 0, true, 10.0 )
		}

		targets.append( clusterTarget )
	}

	return targets
}

bool function GrenadeBarrier_ShouldPruneSpike( vector origin, array<entity> spikes )
{
	float spikePruneRadSqr = GRENADE_BARRIER_SPIKE_PRUNE_RADIUS * GRENADE_BARRIER_SPIKE_PRUNE_RADIUS
	float playerPruneRadSqr = GRENADE_BARRIER_PLAYER_PRUNE_RADIUS * GRENADE_BARRIER_PLAYER_PRUNE_RADIUS

	foreach ( entity spike in spikes )
	{
		float distSqr = DistanceSqr( origin, spike.GetOrigin() )
		if ( distSqr <= spikePruneRadSqr )
			return true
	}

	array<entity> players = GetPlayerArray_Alive()
	foreach ( entity player in players )
	{
		float distSqr = DistanceSqr( origin, player.GetOrigin() )
		if ( distSqr <= playerPruneRadSqr )
			return true
	}

	return false
}

bool function GrenadeBarrier_SpikeHasClearance( vector origin, vector dir, float testDepth )
{
	array<entity> ignoreEnts = []
	TraceResults results = TraceLine( origin, origin + ( dir * testDepth ), ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	if ( GRENADE_BARRIER_DEBUG_DRAW_CLEARANCE )
	{
		if ( results.fraction < 1.0 )
			DebugDrawLine( origin, results.endPos, 255, 0, 0, true, 30.0 )
		else
			DebugDrawLine( origin, results.endPos, 0, 255, 0, true, 30.0 )
	}

	if ( results.fraction < 1.0 )
		return false

	return true
}

void function GrenadeBarrier_CreateDamageTrigger( entity spike, int team )
{
	spike.EndSignal( "OnDestroy" )
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( spike )
	trigger.SetRadius( GRENADE_BARRIER_DAMAGE_TRIGGER_RADIUS )
	trigger.SetAboveHeight( 64 )
	trigger.SetBelowHeight( 0 )
	trigger.SetOrigin( spike.GetOrigin() + ( spike.GetForwardVector() * 16 ) )
	trigger.SetAngles( spike.GetAngles() + <90,0,0> )
	SetTeam( trigger, team )
	trigger.kv.triggerFilterNonCharacter = "0"
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( spike )
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( GrenadeBarrier_OnTriggerEnter )

	trigger.SetOrigin( spike.GetOrigin() + ( spike.GetForwardVector() * 16 ) )
	trigger.SetAngles( spike.GetAngles() + <90,0,0> )

	trigger.SetParent( spike, "", true, 0.0 )

	OnThreadEnd(
		function() : ( trigger )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)

	WaitForever()
}

void function GrenadeBarrier_OnTriggerEnter( entity trigger, entity player )
{
	if ( !player.IsPlayer() )
		return

	thread GrenadeBarrier_DamageTriggerUpdate( trigger, player )
}

void function GrenadeBarrier_DamageTriggerUpdate( entity trigger, entity player )
{
	trigger.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	entity spike = trigger.GetOwner()

	if ( !IsValid( spike ) )
		return

	entity owner = spike.GetOwner()
	entity damageOwner = IsValid( owner ) ? owner : svGlobal.worldspawn

	while ( trigger.IsTouching( player ) )
	{
		//Don't damage player if they are not moving
		if ( player.GetVelocity() != <0,0,0> )
		{
			if ( player.GetTeam() != trigger.GetTeam() )
			{
				player.TakeDamage( GRENADE_BARRIER_DAMAGE, damageOwner, damageOwner, { damageSourceId = eDamageSourceId.mp_weapon_grenade_barrier } )
			}
		}

		wait GRENADE_BARRIER_DAMAGE_INTERVAL
	}
}

void function GrenadeBarrier_DestroySpikeAfterTime( entity spike, entity owner, float time )
{
	spike.EndSignal( "OnDestroy" )

	wait time

	spike.Dissolve( ENTITY_DISSOLVE_CORE, <0, 0, 0>, 500 )
}

#endif