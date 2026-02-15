global function OnWeaponPrimaryAttack_sonic_shout
global function MpAbilitySonicShoutWeapon_Init
global function MpAbilitySonicShoutWeapon_OnWeaponTossPrep

global function MpAbilitySonicShoutWeapon_OnWeaponTossPrep_devices_jammer
global function OnWeaponPrimaryAttack_sonic_shout_devices_jammer

#if CLIENT
	global function PlayScreenFXSonicShout
#endif // CLIENT

const float SONIC_SHOUT_MAX_ANGLE = 25.0
const float SONIC_SHOUT_PUSH_VELOCITY = 1000.0//800.0//600.0
const float SONIC_SHOUT_PUSH_PROJECTILE_VELOCITY = 2400.0
const float SONIC_SHOUT_ROCKET_JUMP_VEL = 1200.0//600.0
const float SONIC_SHOUT_ROCKER_JUMP_DIST = 256.0

const float SONIC_SHOUT_PLAYER_DEAFEN_DURATION = 3.0

const float SONIC_SHOUT_VIEW_PUNCH_SOFT = 30.0
const float SONIC_SHOUT_VIEW_PUNCH_HARD = 5.0
const float SONIC_SHOUT_VIEW_PUNCH_RAND = 5.0

const string SONIC_SHOUT_PLAYER_DEAFEN_SOUND_1P = "1_second_fadeout"
const string SONIC_SHOUT_PLAYER_RELEASE_SOUND_3P = "roger_pulsefail_fire"
const string SONIC_SHOUT_PLAYER_RELEASE_SOUND_1P = "roger_pulsefail_fire" //"roger_pulsefail_fire"
const string SONIC_SHOUT_PLAYER_BUILD_SOUND_1P = "roger_pulsesuccess_build"

const SMALL_SONIC_SHOUT_FX_TABLE = "exp_medium"
const MEDIUM_SONIC_SHOUT_FX_TABLE = "exp_large"
const LARGE_SONIC_SHOUT_FX_TABLE = "exp_xlarge"
const SONIC_SHOUT_FX_TABLE = "superSpectre_groundSlam_impact"//"titan_exp_ground"//"exp_super_spectre"

const asset SONIC_SHOUT_SCREEN_REFRACT_FX = $"Sonar_CH_pulse_refract"
const asset SONIC_SHOUT_WORLD_REFRACT_FX = $"accel_impact_CH_Refrac_1"

struct
{
} file

void function MpAbilitySonicShoutWeapon_Init()
{

	PrecacheParticleSystem( SONIC_SHOUT_WORLD_REFRACT_FX )

	#if SERVER
		PrecacheImpactEffectTable( SMALL_SONIC_SHOUT_FX_TABLE )
		PrecacheImpactEffectTable( MEDIUM_SONIC_SHOUT_FX_TABLE )
		PrecacheImpactEffectTable( LARGE_SONIC_SHOUT_FX_TABLE )
		PrecacheImpactEffectTable( SONIC_SHOUT_FX_TABLE )
		PrecacheParticleSystem( $"P_exp_artillery_plasma" )
	#endif //SERVER

	#if CLIENT
		PrecacheParticleSystem( SONIC_SHOUT_SCREEN_REFRACT_FX )
	#endif //CLIENT
}

void function MpAbilitySonicShoutWeapon_OnWeaponTossPrep( entity weapon, WeaponTossPrepParams prepParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.SetScriptTime0( 0.0 )
}

const float PMMOD_ENDLESS_STRENGTH = 0.8
var function OnWeaponPrimaryAttack_sonic_shout( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	int damageType = DF_KNOCK_BACK
	SonicBlastCone( weapon, attackParams.pos, attackParams.dir, 1, damageType, 1.0, SONIC_SHOUT_MAX_ANGLE )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}

void function SonicBlastCone( entity weapon, vector pos, vector dir, int numBlasts, int damageType, float damageScaler = 1.0, float ornull maxAngle = null, float ornull maxDistance = null )
{
	Assert( numBlasts > 0 )
	int numBlastsOriginal = numBlasts

	float minDistance = weapon.GetWeaponSettingFloat( eWeaponVar.damage_near_distance )

	if ( maxDistance == null )
		maxDistance	= 1000.0//weapon.GetMaxDamageFarDist()
	expect float( maxDistance )

	if ( maxAngle == null )
		maxAngle = 45.0//weapon.GetAttackSpreadAngle() * 0.5
	expect float( maxAngle )

	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
	if ( owner.IsPlayer() )
		thread PlayScreenFXSonicShout( owner )
	#endif //CLIENT

	/*
	Debug ConVars:
		visible_ent_cone_debug_duration_client - Set to non-zero to see debug output
		visible_ent_cone_debug_duration_server - Set to non-zero to see debug output
		visible_ent_cone_debug_draw_radius - Size of trace endpoint debug draw
	*/

	float minDistSqr = minDistance * minDistance
	float maxDistSqr = maxDistance * maxDistance

	array<entity> ignoredEntities 	= [ owner ]
	int traceMask 					= TRACE_MASK_PLAYERSOLID_BRUSHONLY
	int collisionGroup				= TRACE_COLLISION_GROUP_PLAYER
	int visConeFlags				= VIS_CONE_ENTS_TEST_HITBOXES | VIS_CONE_ENTS_CHECK_SOLID_BODY_HIT | VIS_CONE_ENTS_APPOX_CLOSEST_HITBOX

	entity antilagPlayer
	if ( owner.IsPlayer() )
	{
		if ( owner.IsPhaseShifted() )
			return

		antilagPlayer = owner
	}

	#if SERVER

	float chargeFrac = 1.0 //weapon.GetWeaponChargeFraction()
	float chargeScalar = GraphCapped( chargeFrac, 0.0, 1.0, 0.5, 1.0 )

	TraceResults trace
	vector mins = owner.GetPlayerMins()
	vector maxs = owner.GetPlayerMaxs()
	trace = TraceLine( pos, pos + ( dir * maxDistance), ignoredEntities, traceMask, collisionGroup )

	float cappedDistance = maxDistance
	if ( trace.hitEnt != null && !trace.hitSky )
	{
		//printt( "WE HIT SOMETHING EARLY" )

		vector offset = pos + ( dir * maxDistance)
		vector dif = ( offset - pos ) * trace.fraction
		vector hitPos = pos + dif
		//DebugDrawSphere( hitPos, 32.0, 255, 0, 0, true, 10.0 )
		//DebugDrawLine( pos, hitPos, 255, 0, 0, true, 5.0 )
		//DebugDrawLine( pos, trace.endPos, 0, 255, 0, true, 5.0 )
		//DebugDrawLine( pos, pos + ( -dir * 128 ), 0, 0, 255, true, 5.0 )
		cappedDistance *= trace.fraction

		//if player is close to a surface and uses sonic shout, push them back ala rocket jump.
		if ( cappedDistance <= SONIC_SHOUT_ROCKER_JUMP_DIST )
		{
			float rJumpPower = 1.0
			if ( owner.IsOnGround() )
			{
				float dot = DotProduct( <0,0,-1.0>, dir )
				rJumpPower = GraphCapped( dot, 0.30, .31, 0.0, 1.0 )
			}
			//Apply rocket jump force
			SonicShout_PushPlayer( owner, -dir * ( ( SONIC_SHOUT_ROCKET_JUMP_VEL * chargeScalar ) * rJumpPower ) )

			//Punch rocket jumping players view based on dist from hit surface and charge frac.
			float distScalar 	= GraphCapped( cappedDistance, 0.0, SONIC_SHOUT_ROCKER_JUMP_DIST, 1.0, 0.0 )
			float forceScalar 	= ( distScalar * chargeScalar ) * rJumpPower
			float punchSoft 	= SONIC_SHOUT_VIEW_PUNCH_SOFT * forceScalar
			float punchHard 	= SONIC_SHOUT_VIEW_PUNCH_HARD * forceScalar
			float punchRand 	= SONIC_SHOUT_VIEW_PUNCH_RAND * forceScalar
			owner.ViewPunch( hitPos, punchSoft, punchHard, punchRand ) // vector, softAmount, hardAmount, randomBoost

			float dmgScalar 	= distScalar * chargeScalar
			int damage 			= weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )
			float damageScaled 	= damage * dmgScalar

			//deal rocket jump damage to player
			owner.TakeDamage( damageScaled, owner, owner, { origin = pos, damageSourceId = eDamageSourceId.damagedef_sonic_blast } )
		}

		SonicShout_ImpactExplosion( owner, hitPos )

	}

	/*
	entity hitEnt
	vector endPos
	vector surfaceNormal
	string surfaceName
	int surfaceProp
	float fraction
	float fractionLeftSolid
	int hitGroup
	int staticPropID
	bool startSolid
	bool allSolid
	bool hitSky
	int contents
	*/

	SonicShout_FireSonicRipple( pos, dir, cappedDistance )

	array<VisibleEntityInCone> results = FindVisibleEntitiesInCone( pos, dir, cappedDistance, (maxAngle * 1.1), ignoredEntities, traceMask, visConeFlags, antilagPlayer, weapon )
	foreach ( result in results )
	{
		entity target = result.ent
		vector posToTarget = Normalize( result.approxClosestHitboxPos - pos )

		//printt( target )

		//DebugDrawLine( pos, pos + ( posToTarget * cappedDistance ), 255, 0, 0, true, 5.0 )
		//DebugDrawLine( pos, pos + ( dir * cappedDistance ), 0, 255, 0, true, 5.0 )

		float dot = DotProduct( posToTarget, dir )
		float accuracyScalar = GraphCapped( dot, 0.90, 1.0, 0.0, 1.0 )
		float dmgAccuracyScalar = GraphCapped( dot, 0.95, 1.0, 0.0, 1.0 )

		//printt( dot )
		//printt( accuracyScalar )

		float distSqr 		= DistanceSqr( target.GetOrigin(), pos )
		float distScalar 	= GraphCapped( distSqr, minDistSqr, maxDistSqr, 1.0, 0.0 )
		float forceScalar 	= ( distScalar * accuracyScalar ) * chargeScalar
		float dmgScalar 	= ( distScalar * dmgAccuracyScalar ) * chargeScalar

		float punchSoft 	= SONIC_SHOUT_VIEW_PUNCH_SOFT * forceScalar
		float punchHard 	= SONIC_SHOUT_VIEW_PUNCH_HARD * forceScalar
		float punchRand 	= SONIC_SHOUT_VIEW_PUNCH_RAND * forceScalar
		float pushVel 		= SONIC_SHOUT_PUSH_VELOCITY * forceScalar

		int damage = weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )
		float damageScaled = damage * dmgScalar

		//printt ( damageScaled )

		if ( target.IsPlayer() )
		{
			if ( SonicShout_ShouldPushPlayerOrNPC( target ) )
			{
				//if the player is hanging on a ledge, blow them off the ledge.
				if ( target.IsMantling() || target.IsWallHanging() )
					target.ClearTraverse()

				target.ViewPunch( pos, punchSoft, punchHard, punchRand ) // vector, softAmount, hardAmount, randomBoost
				SonicShout_PushPlayer( target, dir * pushVel )

//				EmitSoundOnEntityExceptToPlayer( owner, owner, SONIC_SHOUT_PLAYER_RELEASE_SOUND_3P )
				thread SonicShout_DeafenPlayerForTime( target, SONIC_SHOUT_PLAYER_DEAFEN_DURATION )

				entity shake = CreateShake( pos, 5, 150, 1, 1000 )
				shake.kv.spawnflags = 4 // SF_SHAKE_INAIR
				shake.Destroy()

				if ( target.GetTeam() != owner.GetTeam() )
					target.TakeDamage( damageScaled, owner, owner, { origin = pos, damageSourceId = eDamageSourceId.damagedef_sonic_blast } )
			}
		}
		else if ( target.IsNPC() )
		{
			if ( SonicShout_ShouldPushPlayerOrNPC( target ) )
			{
				SonicShout_PushPlayer( target, dir * pushVel )
				if ( target.GetTeam() != owner.GetTeam() )
					target.TakeDamage( damageScaled, owner, owner, { origin = pos, damageSourceId = eDamageSourceId.damagedef_sonic_blast } )
			}
		}
	}

	//push projectiles
	array<entity> projectiles = GetProjectileArrayEx( "any", TEAM_ANY, TEAM_ANY, pos, cappedDistance )
	foreach ( entity projectile in projectiles )
	{
		//Don't push planted projectiles.
		if ( projectile.proj.isPlanted )
			continue

		vector posToTarget = Normalize( projectile.GetOrigin() - pos )

		//printt( projectile )

	//	DebugDrawLine( pos, pos + ( posToTarget * cappedDistance ), 255, 0, 0, true, 5.0 )
	//	DebugDrawLine( pos, pos + ( dir * cappedDistance ), 0, 255, 0, true, 5.0 )

		float dot = DotProduct( posToTarget, dir )
		float accuracyScalar = GraphCapped( dot, 0.90, 1.0, 0.0, 1.0 )

		//printt( dot )
		//printt( accuracyScalar )

		float distSqr 		= DistanceSqr( projectile.GetOrigin(), pos )
		float distScalar 	= GraphCapped( distSqr, minDistSqr, maxDistSqr, 1.0, 0.0 )
		float forceScalar 	= chargeScalar //accuracyScalar * chargeScalar //1.0//( distScalar * accuracyScalar ) * chargeScalar

		float pushVel 		= SONIC_SHOUT_PUSH_PROJECTILE_VELOCITY * forceScalar

		PushProjectileAway( projectile, dir * pushVel )
	}

	#endif //SERVER
}

//PushPlayerAway( entity target, vector velocity )
//PushEntWithDamageInfoAndDistanceScale( entity ent, var damageInfo, float nearRange, float farRange, float nearScale, float farScale, float forceMultiplier_dotBase = 0.5 )

#if SERVER
bool function SonicShout_ShouldPushPlayerOrNPC( entity target )
{
	if ( target.IsTitan() )
		return false

	if ( IsSuperSpectre( target ) )
		return false

	if ( IsTurret( target ) )
		return false

	if ( IsDropship( target ) )
		return false

	return true
}

void function PushProjectileAway( entity projectile, vector velocity )
{
	Assert ( projectile.IsProjectile() )

	//Don't push planted projectiles.
	if ( projectile.proj.isPlanted )
		return

	vector result = velocity // + projectile.GetVelocity()
	result.z = max( 200, fabs( velocity.z ) )
	projectile.SetVelocity( result )
	//DebugDrawLine( projectile.GetOrigin(), projectile.GetOrigin() + result * 5, 255, 0, 0, true, 5.0 )
}

void function SonicShout_DeafenPlayerForTime( entity player, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
				StopSoundOnEntity( player, SONIC_SHOUT_PLAYER_DEAFEN_SOUND_1P )
		}
	)

	EmitSoundOnEntityOnlyToPlayer( player, player, SONIC_SHOUT_PLAYER_DEAFEN_SOUND_1P )

	wait duration

}

void function SonicShout_FireSonicRipple( vector origin, vector dir, float range )
{
	int fxCount = int ( floor( range / 85.333 ) )
	vector angles = VectorToAngles( dir )
	float stepSize = range / fxCount
	float rangeOffset = 0

	int count = 0
	while ( count < fxCount )
	{
		vector offsetOrigin = origin + ( dir * rangeOffset )
		int fxID	= GetParticleSystemIndex( SONIC_SHOUT_WORLD_REFRACT_FX )
		entity fx 	= StartParticleEffectInWorld_ReturnEntity( fxID, offsetOrigin, angles )
		thread CleanUpRippleFX( fx )

		count++
		rangeOffset = stepSize * count
	}

}

void function SpiesLegends_DevicesJammerFX( vector origin, float range )
{
    // how many radial spokes (you can bump this up for a smoother circle)
    int numSpokes = 32;  
	
    // reuse your spacing logic
    int fxPerSpoke = 10
    float stepSize    = range / fxPerSpoke;
	
	// StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_exp_artillery_plasma" ), origin, <0,0,0> )

    // for each spoke, sweep yaw from 0 to 360
    for ( int s = 0; s < numSpokes; s++ )
    {
        float yawDeg   = (360.0 / numSpokes) * s;
        // build a pure‐horizontal direction vector from that yaw
        vector dirSpoke = Vector( 0, yawDeg, 0 );
        // you may want the effect to face outward
        vector fxAngles = VectorToAngles( dirSpoke );

        // step out along this spoke
        for ( int i = 0; i < fxPerSpoke; i++ )
        {
            float dist      = stepSize * i;
            vector spawnPos = origin + (dirSpoke * dist);

            int    fxID = GetParticleSystemIndex( SONIC_SHOUT_WORLD_REFRACT_FX );
            entity fx   = StartParticleEffectInWorld_ReturnEntity( fxID, spawnPos, fxAngles );
            thread CleanUpRippleFX( fx );
        }
    }
}

void function CleanUpRippleFX( entity fx, float duration = 3.0 )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	fx.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( fx )
		{
			if ( IsValid( fx ) )
			{
				fx.Destroy()
			}
		}
	)

	wait duration
}

void function SonicShout_ImpactExplosion( entity player, vector pos )
{
	string fxTable = SONIC_SHOUT_FX_TABLE
	
	int damageId = eDamageSourceId.mp_ability_ground_slam
	
	if( Gamemode() == eGamemodes.fs_spieslegends )
	{
		damageId = eDamageSourceId.mp_ability_devices_jammer
		fxTable = "exp_electric_smoke_grenade"
	}
	
	Explosion(
		pos,											//center,
		player,											//attacker,
		player,											//inflictor,
		0,												//damage,
		0,												//damageHeavyArmor,
		50.0,											//innerRadius,
		50.0,											//outerRadius,
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,					//flags,
		pos,											//projectileLaunchOrigin,
		1000.0,											//explosionForce,
		damageTypes.explosive,							//scriptDamageFlags,
		damageId,			//scriptDamageSourceIdentifier,
		fxTable )										//impactEffectTableName
}

void function SonicShout_PushPlayer( entity target, vector velocity )
{
	if ( !target.IsPlayer() && !target.IsNPC() )
		return

	vector result = velocity
	if ( result.z > 0 )
		result.z = max( 200, fabs( velocity.z ) )
	target.SetVelocity( result )
	//DebugDrawLine( target.GetOrigin(), target.GetOrigin() + result * 5, 255, 0, 0, true, 5.0 )
}

#endif //SERVER

#if CLIENT
	void function PlayScreenFXSonicShout( entity clientPlayer )
	{
		Assert ( IsNewThread(), "Must be threaded off." )
		clientPlayer.EndSignal( "OnDeath" )
		clientPlayer.EndSignal( "OnDestroy" )

		entity viewPlayer = GetLocalViewPlayer()
		int indexD        = GetParticleSystemIndex( SONIC_SHOUT_SCREEN_REFRACT_FX )
		int fxHandle      = -1

		fxHandle = StartParticleEffectOnEntityWithPos( viewPlayer, indexD, FX_PATTACH_ABSORIGIN_FOLLOW, -1, viewPlayer.EyePosition(), <0,0,0> )
		EffectSetIsWithCockpit( fxHandle, true )

		OnThreadEnd(
			function() : ( clientPlayer, fxHandle )
			{
				if ( IsValid( clientPlayer ) && !IsAlive( clientPlayer ) )
				{
					if ( fxHandle > -1 )
						EffectStop( fxHandle, true, false )
				}
			}
		)

		wait 3.0
	}
#endif


//////////////////
//////////////////
// Spies legends

void function MpAbilitySonicShoutWeapon_OnWeaponTossPrep_devices_jammer( entity weapon, WeaponTossPrepParams prepParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.SetScriptTime0( 0.0 )
}

var function OnWeaponPrimaryAttack_sonic_shout_devices_jammer( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	SpiesLegends_jammer_devices( weapon, attackParams.pos, attackParams.dir )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}

void function SpiesLegends_jammer_devices( entity weapon, vector pos, vector dir )
{
	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
	if ( owner.IsPlayer() )
		thread PlayScreenFXSonicShout( owner )
	#endif //CLIENT
	
	#if SERVER
	float punchSoft 	= SONIC_SHOUT_VIEW_PUNCH_SOFT
	float punchHard 	= SONIC_SHOUT_VIEW_PUNCH_HARD
	float punchRand 	= SONIC_SHOUT_VIEW_PUNCH_RAND
	
	owner.ViewPunch( owner.GetOrigin(), 5, 1, 1)
	
	SonicShout_ImpactExplosion( owner, owner.GetOrigin() )
	SpiesLegends_DevicesJammerFX( pos, 1000.0 )

	entity circle = CreateEntity( "prop_dynamic" )
	circle.SetValueForModelKey( $"mdl/fx/ar_edge_sphere_512.rmdl" )
	circle.kv.modelscale = 1.17 // 300
	circle.kv.rendercolor = "255, 255, 255"
	circle.SetOrigin( owner.GetOrigin() + <0.0, 0.0, -25>)
	circle.SetAngles( <0, 0, 0> )
	DispatchSpawn(circle)
	thread CleanUpRippleFX( circle, 1.5 )
	
	
	float destructionRadius = 300.0
	
	//Deshabilitar mercs devices
	//Proximity Mines DONE
	//Electric Smoke "smokeScreenInfoTarget" DONE
	//Pulse Blade (or its ping effect) "grenadeSonarProjectile" DONE
	//Rev Shell "Rev_shell" DONE
	//Suppressor Turret "flowstateTurret" DONE
	foreach( ent in GetTrackedEnts_Level() )
	{
		if( IsValid( ent ) && ent.GetScriptName() == "flowstateTurret" && Distance(ent.GetOrigin(), owner.GetOrigin() ) <= destructionRadius )
		{
			//Sound for zap
			EmitSoundOnEntity( ent, "Wattson_Ultimate_J" )

			//Effects for zap
			entity zap = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_wpn_trophy_imp_lite" ), ent.GetOrigin(), ent.GetAngles() )
			EffectSetControlPointVector( zap, 1, ent.GetOrigin() )
			
			foreach(entity part in ent.e.turretparts)
			{
				if(IsValid(part)) 
					part.Dissolve( ENTITY_DISSOLVE_CORE, <0, 0, 0>, 5000 )
			}
			
			if( IsValid( ent ) )
				ent.Destroy()
			continue
		}
		
		if( !IsValid( ent ) ||
			ent.GetScriptName() != "proximityMine" && ent.GetScriptName() != "smokeScreenInfoTarget" && ent.GetScriptName() != "grenadeSonarProjectile" && ent.GetScriptName() != "Rev_shell"  ||
			Distance(ent.GetOrigin(), owner.GetOrigin() ) > destructionRadius )
			continue

		//Sound for zap
		EmitSoundOnEntity( ent, "Wattson_Ultimate_J" )

		//Effects for zap
		entity zap = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_wpn_trophy_imp_lg" ), ent.GetOrigin(), ent.GetAngles() )
		EffectSetControlPointVector( zap, 1, ent.GetOrigin() )
		
		entity zapp = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_tesla_trap_link_CP" ), owner.GetAttachmentOrigin( owner.LookupAttachment( "R_HAND" ) ), <0, 0, 0> )
		EffectSetControlPointVector( zapp, 1, ent.GetOrigin() )
		
		thread function () : (zapp)
		{
			wait 1.5
			if(IsValid(zapp))
				zapp.Destroy()
		}()
		ent.Destroy()
	}

	
	#endif //SERVER
}
