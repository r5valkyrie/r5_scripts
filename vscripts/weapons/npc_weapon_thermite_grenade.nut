//

#if SERVER
global function OnWeaponNpcTossGrenade_npcweapon_thermite_grenade
#endif //SERVER
global function OnProjectileCollision_npcweapon_thermite_grenade

const asset PREBURN_EFFECT_ASSET = $"P_wpn_meteor_wall_preburn"
const asset BURN_EFFECT_ASSET = $"P_wpn_meteor_wall"

#if SERVER
	const bool DEBUG_THERMITE_GRENADE_TRACES = false
#endif // SERVER

struct SegmentData
{
	//int index
	vector startPos
	vector endPos
	vector angles
	string sound
}

#if SERVER
void function OnWeaponNpcTossGrenade_npcweapon_thermite_grenade( entity weapon, entity grenade )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) && IsValid( grenade ))
	{
		grenade.proj.savedDir = grenade.GetForwardVector()
		return
	}

	if ( IsValid( weaponOwner ) && IsValid( grenade ) )
	{
		Assert( weaponOwner.IsNPC() )
		entity enemy = weaponOwner.GetEnemy()
		if ( IsValid( enemy ) )
			grenade.proj.savedDir = enemy.GetOrigin() - weaponOwner.GetOrigin()
		else
			grenade.proj.savedDir = grenade.GetForwardVector()
	}
}
#endif //SERVER

void function OnProjectileCollision_npcweapon_thermite_grenade( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity npc = projectile.GetOwner()
	if ( hitEnt == npc )
		return

	projectile.proj.projectileBounceCount++
	//printt( "bounceCount:", projectile.proj.projectileBounceCount )

	int maxBounceCount = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_ricochet_max_count )

	bool forceExplode = false
	if ( projectile.proj.projectileBounceCount > maxBounceCount )
	{
		//printt( "max bounceCount hit, forcing explosion" )
		forceExplode = true
	}

	bool projectileIsOnGround = normal.Dot( <0,0,1> ) > 0.75
	if ( !projectileIsOnGround && !forceExplode )
		return

	//if ( !forceExplode )
	//	printt( "projectileIsOnGround with Dot:", normal.Dot( <0,0,1> ) )

	DeployableCollisionParams collisionParams
	collisionParams.pos = pos
	collisionParams.normal = normal
	collisionParams.hitEnt = hitEnt
	collisionParams.hitBox = hitbox
	collisionParams.isCritical = isCritical

	if ( npc && !npc.IsPlayer() )
		collisionParams.hitEnt = GetEntByIndex( 0 )

	if ( !PlantStickyEntity( projectile, collisionParams ) && !forceExplode )
		return

	projectile.SetDoesExplode( false )

#if SERVER
	vector dir = projectile.proj.savedDir
	dir.z = 0
	dir = Normalize( dir )

	projectile.proj.onlyAllowSmartPistolDamage = false

	if ( !IsValid( npc ) )
	{
		projectile.Destroy()
		return
	}
	bool shouldFlipDir = true
	array<string> mods = projectile.ProjectileGetMods()
	foreach ( mod in mods )
	{
		if ( mod == "vertical_firestar" )
			shouldFlipDir = false
	}

	if ( shouldFlipDir )
		dir = CrossProduct( dir, normal )

	BurnDamageSettings burnSettings
	burnSettings.damageSourceID 		= projectile.ProjectileGetDamageSourceID()
	burnSettings.preburnDuration 		= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "preburn_duration" ) )
	burnSettings.burnDuration 			= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_duration" ) )
	burnSettings.burnDamage 			= expect int( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_damage" ) )
	burnSettings.burnTime 				= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_time" ) )
	burnSettings.burnTickRate 			= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_tick_rate" ) )
	burnSettings.burnDamageRadius 		= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_segment_radius" ) )
	burnSettings.burnDamageHeight 		= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_segment_height" ) )
	burnSettings.soundBurnSegmentStart 	= expect string( projectile.ProjectileGetWeaponInfoFileKeyField( "sound_burn_segment_start" ) )
	burnSettings.soundBurnSegmentMiddle = expect string( projectile.ProjectileGetWeaponInfoFileKeyField( "sound_burn_segment_middle" ) )
	burnSettings.soundBurnSegmentEnd 	= expect string( projectile.ProjectileGetWeaponInfoFileKeyField( "sound_burn_segment_end" ) )
	burnSettings.soundBurnDamageTick_1P = expect string( projectile.ProjectileGetWeaponInfoFileKeyField( "sound_burn_damage_tick_1p" ) )
	burnSettings.burnStackDebounce 		= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_stack_debounce" ) )
	burnSettings.burnStacksMax 			= expect int( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_stacks_max" ) )
	burnSettings.segmentSpacingDist 	= expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_segment_spacing_dist" ) )

	int numSegments = expect int( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_segments" ) )

	entity owner = projectile.GetOwner()
	entity inflictor = CreateOncePerTickDamageInflictorHelper( burnSettings.burnDuration )

	if ( shouldFlipDir )
	{
		thread BeginFire( owner, inflictor, projectile.GetOrigin(), dir, numSegments, false, burnSettings )
		thread BeginFire( owner, inflictor, projectile.GetOrigin(), -1 * dir, numSegments, true, burnSettings )
	}
	else
	{
		thread BeginFire( owner, inflictor, projectile.GetOrigin(), dir, numSegments * 2, false, burnSettings )
	}

	projectile.GrenadeExplode( normal )
#endif // SERVER
}


void function FadeModelIntensityOverTime( entity model, float duration, int startColor = 255, int endColor = 0 )
{
	EndSignal( model, "OnDestroy" )

	float startTime = Time()
	float endTime = startTime + duration

	//model.kv.rendermode = 0

	while ( Time() <= endTime )
	{
		float alphaResult = GraphCapped( Time(), startTime, endTime, startColor, endColor )
		string colorString = alphaResult + " " + alphaResult + " " + alphaResult
		model.kv.rendercolor = colorString
		model.kv.renderamt = 255
		//printt ("Entity: " + model + " Time: " + Time() + " Color: " + colorString + " startColor:" + startColor + " endColor:" + endColor + " startTime: " + startTime + " EndTime: " + endTime)
		WaitFrame()
	}

	model.kv.rendercolor = endColor + " " + endColor + " " + endColor
	model.kv.renderamt = 255

}


#if SERVER
void function BeginFire( entity owner, entity inflictor, vector pos, vector dir, int numSegments, bool skipFirstStep, BurnDamageSettings burnSettings )
{
	owner.EndSignal( "OnDestroy" )

	array<SegmentData> segmentsArray = CreateSpreadPattern( owner, inflictor, pos, dir, numSegments, burnSettings )
	// don't try to use an empty array
	if ( segmentsArray.len() == 0 )
		return

	if ( skipFirstStep )
		segmentsArray.remove( 0 )
	waitthread BurnSequence( owner, inflictor, segmentsArray, burnSettings )
}

void function BurnSequence( entity owner, entity inflictor, array<SegmentData> segmentsArray, BurnDamageSettings burnSettings )
{
	owner.EndSignal( "OnDestroy" )

	foreach ( segment in segmentsArray )
	{
		thread DoSegment( owner, inflictor, segment, burnSettings )
		WaitFrame()
	}
}

void function DoSegment( entity owner, entity inflictor, SegmentData segment, BurnDamageSettings burnSettings )
{
	owner.EndSignal( "OnDestroy" )

	entity preburnEffect = CreateSegmentEffect( PREBURN_EFFECT_ASSET, owner, segment.startPos, segment.endPos, segment.angles, burnSettings.preburnDuration )

	wait burnSettings.preburnDuration

	entity burnEffect = CreateSegmentEffect( BURN_EFFECT_ASSET, owner, segment.startPos, segment.endPos, segment.angles, burnSettings.burnDuration )
	AI_CreateDangerousArea_Static( burnEffect, inflictor, burnSettings.burnDamageRadius, TEAM_INVALID, true, true, segment.endPos )
	thread FireSegment_DamageThink( burnEffect, owner, inflictor, burnSettings )

	if ( segment.sound != "" )
		EmitSoundOnEntity( burnEffect, segment.sound )
}

array<SegmentData> function CreateSpreadPattern( entity owner, entity inflictor, vector pos, vector dir, int stepCount, BurnDamageSettings burnSettings )
{
	owner.EndSignal( "OnDestroy" )

	int count = 0
	vector lastDownPos = pos
	bool firstTrace = true
	array<SegmentData> segmentsArray

	dir.z = 0
	dir = Normalize( dir )
	vector angles = VectorToAngles( dir )

	bool staggerDirState = CoinFlip()
	float staggerDegrees = 35
	vector staggerOffsetVec
	vector staggerDir

	for ( int i = 0; i < stepCount; i++ )
	{
		if ( staggerDirState )
			staggerOffsetVec = <0,staggerDegrees,0>
		else
			staggerOffsetVec = <0,-staggerDegrees,0>

		if ( i == 1 ) // half offset for 2nd placement
			staggerOffsetVec *= 0.5

		staggerDir = Normalize( VectorRotate( dir, staggerOffsetVec ) )
		staggerDirState = !staggerDirState

		vector newPos = pos
		if ( !firstTrace )
			newPos += staggerDir * burnSettings.segmentSpacingDist

		vector traceStart = pos
		vector traceEndUnder = newPos
		vector traceEndOver = newPos

		if ( !firstTrace )
		{
			traceStart = lastDownPos + <0,0,80>
			traceEndUnder = <newPos.x, newPos.y, traceStart.z - 40>
			traceEndOver = <newPos.x, newPos.y, traceStart.z + burnSettings.segmentSpacingDist * 0.57735056839> // The over height is to cover the case of a sheer surface that then continues gradually upwards (like mp_box)
		}
		firstTrace = false

		#if DEVELOPER && DEBUG_THERMITE_GRENADE_TRACES
			DebugDrawLine( traceStart, traceEndUnder, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
		#endif

		array ignoreArray = []
		if ( IsValid( inflictor ) && inflictor.GetOwner() != null )
			ignoreArray.append( inflictor.GetOwner() )

		TraceResults forwardTrace = TraceLine( traceStart, traceEndUnder, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if ( forwardTrace.fraction == 1.0 )
		{
			#if DEVELOPER && DEBUG_THERMITE_GRENADE_TRACES
				DebugDrawLine( forwardTrace.endPos, forwardTrace.endPos + <0,0,-225>, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 25.0 )
			#endif

			TraceResults downTrace = TraceLine( forwardTrace.endPos, forwardTrace.endPos + <0,0,-225>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( downTrace.fraction == 1.0 )
				continue

			SegmentData segment
			//segment.index = i
			segment.startPos = lastDownPos
			segment.endPos = downTrace.endPos
			segment.angles = angles
			segment.sound = GetSoundForSegment( i, stepCount, burnSettings )
			//printt( "i:", i, "stepCount:", stepCount, "segment.sound:", segment.sound )
			segmentsArray.append( segment )

			lastDownPos = downTrace.endPos
			pos = forwardTrace.endPos

			continue
		}

		TraceResults upwardTrace = TraceLine( traceStart, traceEndOver, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		#if DEVELOPER && DEBUG_THERMITE_GRENADE_TRACES
			DebugDrawLine( traceStart, traceEndOver, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 25.0 )
		#endif

		if ( upwardTrace.fraction < 1.0 && IsValid( upwardTrace.hitEnt ) && upwardTrace.hitEnt.IsWorld() )
		{
			continue
		}
		else
		{
			TraceResults downTrace = TraceLine( upwardTrace.endPos, upwardTrace.endPos + <0,0,-1000>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( downTrace.fraction == 1.0 )
				continue

			SegmentData segment
			//segment.index = i
			segment.startPos = lastDownPos
			segment.endPos = downTrace.endPos
			segment.angles = angles
			segment.sound = GetSoundForSegment( i, stepCount, burnSettings )
			//printt( "i:", i, "stepCount:", stepCount, "segment.sound:", segment.sound )
			segmentsArray.append( segment )

			lastDownPos = downTrace.endPos
			pos = forwardTrace.endPos
		}
	}

	#if DEVELOPER && DEBUG_THERMITE_GRENADE_TRACES
		printt( "Total segments:", segmentsArray.len() )
	#endif

	return segmentsArray
}

entity function CreateSegmentEffect( asset effectAsset, entity owner, vector startPos, vector endPos, vector angles, float duration )
{
	Assert( IsValid( owner ) )

	entity effect = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( effectAsset ), endPos, angles )
	effect.SetOwner( owner )
	//AddToUltimateRealm( owner, effect )

	EffectSetControlPointVector( effect, 1, startPos )

	if ( duration > 0 )
		EntFireByHandle( effect, "Kill", "", duration, null, null )

	return effect
}

string function GetSoundForSegment( int index, int max, BurnDamageSettings burnSettings )
{
	string weaponSettingKey = ""
	string soundAlias = ""

	if ( index == 0 )
		soundAlias = burnSettings.soundBurnSegmentStart
	else if ( index == ( max - 1 ) )
		soundAlias = burnSettings.soundBurnSegmentEnd
	else if ( index == max / 2 )
		soundAlias = burnSettings.soundBurnSegmentMiddle

	return soundAlias
}

#endif // SERVER