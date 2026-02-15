global function MpWeaponConcussiveBreach_Init

global function OnWeaponTossReleaseAnimEvent_weapon_concussive_breach
global function OnWeaponAttemptOffhandSwitch_weapon_concussive_breach
global function OnWeaponTossPrep_weapon_concussive_breach
global function OnProjectileCollision_weapon_concussive_breach
global function OnWeaponPrimaryAttackAnimEvent_weapon_concussive_breach

const float CONCUSSIVE_BREACH_THROW_POWER = 900.0//575.0

const float CONCUSSIVE_BREACH_DEPLOY_DELAY = 1.0
const float CONCUSSIVE_BREACH_FIRE_DELAY = 2.5

const bool CONCUSSIVE_BREACH_DAMAGE_ENEMIES = false

const float CONCUSSIVE_BREACH_ANGLE_LIMIT = 1.0

const float CONCUSSIVE_BREACH_TEST_DEPTH = 128.0

const vector CONCUSSIVE_BREACH_BOUND_MINS = <-6,-6,-6>
const vector CONCUSSIVE_BREACH_BOUND_MAXS = <6,6,6>

const float CONCUSSIVE_BREACH_BLAST_RADIUS = 768.0
const float CONCUSSIVE_BREACH_BLAST_FORCE = 1500.0

//SONAR SCAN VARS
const float CONCUSSIVE_BREACH_SCAN_CONE_FOV = 180.0
const float CONCUSSIVE_BREACH_SCAN_DURATION = 3.0
const float CONCUSSIVE_BREACH_SCAN_HUD_FEEDBACK_DURATION = 4.0

const float CONCUSSIVE_BREACH_SHELLSHOCK_DURATION = 1.5
const int	CONCUSSIVE_BREACH_DAMAGE = 10

const asset CONCUSSIVE_BREACH_SHIELD_PROJECTILE = $"mdl/weapons/sentry_shield/sentry_shield_proj.rmdl"
const asset CONCUSSIVE_BREACH_AR_DIRECTION_MODEL = $"mdl/fx/ar_marker_big_arrow_down.rmdl"

const asset CONCUSSIVE_BREACH_WORLD_REFRACT_FX = $"accel_impact_CH_Refrac_1"

const string CONCUSSIVE_BREACH_CHARGE_SOUND = "arc_cannon_fastcharge_3p_enemy"//"weapon_coldwar_chargeup_3p_enemy"

const string CONCUSSIVE_BREACH_FX_TABLE = "superSpectre_groundSlam_impact"

global const float AREA_SONAR_SCAN_RADIUS_BREACH = 1250.0
	
struct
{
	//This is an explicit list of traps this ultimate will destroy.
	array<string> destroyTrapNames = [
		"dirty_bomb",
		"tesla_trap_proxy",
		"trophy_system_proxy",
		"crypto_camera",
		"crypto_camera_ultimate",
		"debris_trap",
	]

	//This is an explicit list of placeables this ultimate will damage.
	array<string> damageTrapNames = [
		"cover_wall",
		"mounted_turret_placeable",

	]
}
file

void function MpWeaponConcussiveBreach_Init()
{
	PrecacheModel( CONCUSSIVE_BREACH_SHIELD_PROJECTILE )
	PrecacheModel( CONCUSSIVE_BREACH_AR_DIRECTION_MODEL )
	PrecacheParticleSystem( CONCUSSIVE_BREACH_WORLD_REFRACT_FX )

	#if SERVER
	RegisterSignal( "Concussive_Breach_Detonate" )
	PrecacheImpactEffectTable( CONCUSSIVE_BREACH_FX_TABLE )
	#endif //SERVER

	#if CLIENT
		AddCreateCallback( "prop_script", ConcussiveBreach_OnPropScriptCreated )
	#endif //CLIENT
}

bool function OnWeaponAttemptOffhandSwitch_weapon_concussive_breach( entity weapon )
{
	int ammoReq = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPhaseShifted() )
		return false

	return true
}

var function OnWeaponTossReleaseAnimEvent_weapon_concussive_breach( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable( weapon, attackParams, CONCUSSIVE_BREACH_THROW_POWER, ConcussiveBreach_OnPlanted )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
		deployable.e.isDoorBlocker = true
		deployable.e.burnmeter_wasPreviouslyDeployed = weapon.e.burnmeter_wasPreviouslyDeployed

		string projectileSound = GetGrenadeProjectileSound( weapon )
		if ( projectileSound != "" )
			EmitSoundOnEntity( deployable, projectileSound )

		weapon.w.lastProjectileFired = deployable
		deployable.e.burnReward = weapon.e.burnReward
		#endif

		#if BATTLECHATTER_ENABLED && SERVER
			TryPlayWeaponBattleChatterLine( player, weapon )
		#endif

	}

	return ammoReq
}

void function OnWeaponTossPrep_weapon_concussive_breach( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

void function ConcussiveBreach_OnPlanted( entity projectile )
{
	#if SERVER
		Assert( IsValid( projectile ) )

		entity owner = projectile.GetOwner()

		if ( !IsValid( owner ) )
		{
			projectile.Destroy()
			return
		}

		vector origin = projectile.GetOrigin()
		vector endOrigin = origin - projectile.proj.savedDir * 32

		TraceResults results = TraceLineHighDetail( origin, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

		if ( results.fraction < 1.0 )
			endOrigin = results.endPos

	//	DebugDrawLine( origin, endOrigin,255, 0, 0, true, 30.0 )

	//	TraceResults traceResult = TraceLine( origin, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	//	DebugDrawLine( origin, origin + ( traceResult.surfaceNormal * 32 ),0, 255, 0, true, 30.0 )

		vector attachOrigin = results.endPos

		vector up = VectorToAngles( results.surfaceNormal )
		vector surfaceNormal = results.fraction < 1.0 ? results.surfaceNormal : projectile.proj.savedDir
		vector surfaceAngles = AnglesCompose( VectorToAngles( surfaceNormal ), <90,0,0> )


		entity oldParent = projectile.GetParent()
		projectile.ClearParent()
		projectile.SetAngles( surfaceAngles )
		projectile.SetOrigin( attachOrigin )

		// thread TrapDestroyOnRoundEnd( owner, projectile )

		if ( IsValid( results.hitEnt ) )
		{
			if ( EntityShouldStick( projectile, results.hitEnt ) && !results.hitEnt.IsWorld() )
				projectile.SetParent( results.hitEnt )
		}
		else if ( IsValid( oldParent ) )
		{
			if ( EntityShouldStick( projectile, oldParent ) && !oldParent.IsWorld() )
				projectile.SetParent( oldParent )
		}

		// collision for the bubble shield for sliding doors
		entity collisionProxy = CreateEntity( "script_mover_lightweight" )
		collisionProxy.kv.solid = SOLID_VPHYSICS
		collisionProxy.kv.fadedist = -1
		collisionProxy.SetValueForModelKey( CONCUSSIVE_BREACH_SHIELD_PROJECTILE )
		collisionProxy.kv.SpawnAsPhysicsMover = 0
		collisionProxy.e.isDoorBlocker = true

		collisionProxy.SetOrigin( projectile.GetOrigin() )
		collisionProxy.SetAngles( projectile.GetAngles() )


		DispatchSpawn( collisionProxy )
		collisionProxy.Hide()
		collisionProxy.SetParent( projectile )
		collisionProxy.SetOwner( owner )

		//entity marker = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin - projectile.proj.savedDir * 12, surfaceAngles + <0,90,-90>  )
		entity marker = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin - projectile.GetUpVector() * 12, VectorToAngles( -surfaceNormal ) )
		marker.SetScriptName( "concussive_breach_marker" )
		marker.DisableHibernation()

		OnThreadEnd(
			function() : ( marker )
			{
				if ( IsValid( marker ) )
				{
					marker.Destroy()
				}
			}
		)

		thread ConcussiveBreach_SonarThink( projectile )

		waitthread ConcussiveBreach_WaitForDetonation( owner, projectile )
	#endif //SERVER
}

void function OnProjectileCollision_weapon_concussive_breach( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}

	#if SERVER
		projectile.proj.savedDir 	= normal
		projectile.proj.savedOrigin = pos
	#endif //SERVER

	bool result = PlantStickyEntity( projectile, collisionParams )

	#if SERVER
		entity player = projectile.GetOwner()

		if ( !IsValid( player ) )
		{
			projectile.Destroy()
			return
		}

		EmitSoundOnEntity( projectile, "Weapon_R1_Satchel.Attach" )
		EmitAISoundWithOwner( player, SOUND_PLAYER, 0, player.GetOrigin(), 1000, 0.2 )

		//printt( "PLANTING CONCUSSIVE CHARGE!!!" )

	#endif // SERVER
}

var function OnWeaponPrimaryAttackAnimEvent_weapon_concussive_breach( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	#if SERVER
		ConcussiveBreach_TriggerChargeDetonation( player )
	#endif //SERVER
}

#if SERVER

void function ConcussiveBreach_WaitForDetonation( entity player, entity projectile )
{
	Assert( IsNewThread(), "Must be threaded off." )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	projectile.EndSignal( "OnDestroy" )

//	player.WaitSignal( "Concussive_Breach_Detonate" )

	EmitSoundOnEntity( projectile, CONCUSSIVE_BREACH_CHARGE_SOUND )
	wait CONCUSSIVE_BREACH_FIRE_DELAY

	ConcussiveBreach_DetonateCharge( player, projectile )

}

void function ConcussiveBreach_TriggerChargeDetonation( entity player )
{
	player.Signal( "Concussive_Breach_Detonate" )
}

void function ConcussiveBreach_DetonateCharge( entity player, entity projectile )
{
	//printt( "TOUCHING OFF CONCUSSIVE BREACHING CHARGE!!!" )

	vector origin = projectile.GetOrigin()
	vector depthTestDir = -projectile.proj.savedDir
	vector plantSurfDir = projectile.proj.savedDir

	//DebugDrawLine( origin, origin + ( depthTestDir * 128 ),0, 0, 255, true, 30.0 )

	float testDepth = 8.0 //CONCUSSIVE_BREACH_TEST_DEPTH
	vector startPoint = origin + ( depthTestDir * testDepth )
	vector endPoint = origin + depthTestDir
	TraceResults traceResult
	TraceResults bestResult
	bool exitPoint = false
	int openCount = 0

	for ( int i = 1; i <= 32; i++ )
	{
		traceResult = TraceLine( startPoint, endPoint, [ player, projectile ], TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

		vector color = IsOdd( i ) ? <0,0,255> : <255,255,255>

		//DebugDrawLine( startPoint, traceResult.endPos, color.x, color.y, color.z, true, 30.0 )

		//PrintTraceResults( traceResult )
		//printt( "SURFACE NORMAL: " + depthTestDir )


		endPoint = startPoint
		startPoint = startPoint + ( depthTestDir * testDepth )

		if ( traceResult.fraction < 1.0 )
		{
			bestResult = traceResult
			exitPoint = true
			openCount = 0
		}
		else
		{
			openCount++

			if ( exitPoint && openCount >= 2 )
			{
				//printt("")
				//printt("HULLTRACE!!!")
				TraceResults hullTraceResult = TraceHull( traceResult.endPos, origin, CONCUSSIVE_BREACH_BOUND_MINS, CONCUSSIVE_BREACH_BOUND_MAXS, [ player, projectile ], TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
				//DebugDrawBox( hullTraceResult.endPos, CONCUSSIVE_BREACH_BOUND_MINS, CONCUSSIVE_BREACH_BOUND_MAXS, 255, 0, 0, 1, 30.0 )

				/*
				if ( hullTraceResult.contents )
					DebugDrawBox( traceResult.endPos, CONCUSSIVE_BREACH_BOUND_MINS, CONCUSSIVE_BREACH_BOUND_MAXS, 0, 255, 0, 1, 30.0 )
				else
					DebugDrawBox( traceResult.endPos, CONCUSSIVE_BREACH_BOUND_MINS, CONCUSSIVE_BREACH_BOUND_MAXS, 0, 0, 0, 1, 30.0 )
					*/

				//PrintTraceResults( hullTraceResult )
				//printt("")

				if ( hullTraceResult.fraction != 1.0 )
				{
					bestResult = hullTraceResult
					break
				}

				//else
				//	openCount = 0
			}
		}

		//printt( "TEST DEPTH: " + testDepth )

	}

	TraceResults exitTraceResult = exitPoint ? bestResult : traceResult

	ConcussiveBreach_WallImpactEffect( player, projectile.GetOrigin() )
	ConcussiveBreach_WallImpactEffect( player, exitTraceResult.endPos + depthTestDir )

	ConcussiveBreach_FireSonicRipple( origin, depthTestDir, CONCUSSIVE_BREACH_BLAST_RADIUS )
	ConcussiveBreach_ApplyForceInArc( player, projectile, origin, depthTestDir, CONCUSSIVE_BREACH_BLAST_RADIUS )

	//DebugDrawSphere( exitTraceResult.endPos + depthTestDir, 16.0, 255, 0, 0, true, 30.0 )

	//DebugDrawSphere( origin, CONCUSSIVE_BREACH_BLAST_RADIUS, 255, 0, 0, true, 30.0 )

}

void function ConcussiveBreach_WallImpactEffect( entity player, vector pos )
{
	string fxTable = CONCUSSIVE_BREACH_FX_TABLE

	Explosion(
		pos,															//center,
		player,														//attacker,
		player,														//inflictor,
		0,																	//damage,
		0,																	//damageHeavyArmor,
		50.0,																//innerRadius,
		50.0,																//outerRadius,
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,								//flags,
		pos,												//projectileLaunchOrigin,
		1000.0,																//explosionForce,
		damageTypes.explosive,								//scriptDamageFlags,
		eDamageSourceId.mp_weapon_concussive_breach,	//scriptDamageSourceIdentifier,
		fxTable )										//impactEffectTableName
}

void function ConcussiveBreach_ApplyForceInArc( entity owner, entity projectile, vector origin, vector forceforward, float forceRadius )
{

	int team = owner.GetTeam()

	array<entity> players = GetPlayerArray_Alive()
	foreach ( entity player in players )
	{
		if ( DistanceSqr( origin, player.GetOrigin() ) > ( forceRadius * forceRadius ) )
			continue

		vector originToPlayer = Normalize( player.GetCenter() - origin )

		float dot = DotProduct( forceforward, originToPlayer )

		//printt( "DOT: " + dot )

		if ( dot < 0 )
			continue

		//DebugDrawLine( origin, origin + ( originToPlayer * forceRadius ) , 255, 255, 255, true, 30.0 )

		vector currentVel = player.GetVelocity()
		vector addedVel = originToPlayer * CONCUSSIVE_BREACH_BLAST_FORCE
		vector newVel = currentVel + addedVel
		player.SetVelocity( newVel )
		player.ViewPunch( origin, 50, 50, 0 )

		ShellShock_ApplyForDuration( player, CONCUSSIVE_BREACH_SHELLSHOCK_DURATION )

		if ( IsFriendlyTeam( player.GetTeam(), team ) && (owner != player) )
			continue

		player.TakeDamage( CONCUSSIVE_BREACH_DAMAGE, owner, projectile, { damageSourceId = eDamageSourceId.mp_weapon_concussive_breach } )
	}

	//Destroy traps in radius
	foreach ( string trapName in file.destroyTrapNames )
	{
		array< entity > trapEnts =  GetEntArrayByScriptName( trapName )
		foreach ( entity trapEnt in trapEnts )
		{
			if ( DistanceSqr( origin, trapEnt.GetOrigin() ) > ( forceRadius * forceRadius ) )
				continue

			vector originToTrap = Normalize( trapEnt.GetCenter() - origin )

			float trapDot = DotProduct( forceforward, originToTrap )

			//printt( "TRAP DOT: " + trapDot )

			if ( trapDot < 0 )
				continue

			//DebugDrawLine( origin, origin + ( originToTrap * forceRadius ) , 255, 255, 255, true, 30.0 )

			//Destroy Trap
			trapEnt.TakeDamage( trapEnt.GetHealth() + 1, owner, projectile, { damageSourceId = eDamageSourceId.mp_weapon_concussive_breach } )
		}
	}

	//Damage placeable that should be damaged.
	foreach ( string trapName in file.damageTrapNames )
	{
		array< entity > trapEnts =  GetEntArrayByScriptName( trapName )
		foreach ( entity trapEnt in trapEnts )
		{
			if ( DistanceSqr( origin, trapEnt.GetOrigin() ) > ( forceRadius * forceRadius ) )
				continue

			vector originToTrap = Normalize( trapEnt.GetCenter() - origin )

			float trapDot = DotProduct( forceforward, originToTrap )

			//printt( "TRAP DOT: " + trapDot )

			if ( trapDot < 0 )
				continue

			//DebugDrawLine( origin, origin + ( originToTrap * forceRadius ) , 255, 255, 255, true, 30.0 )

			//Damage Trap for 60% of it's max health.
			trapEnt.TakeDamage( trapEnt.GetMaxHealth() * 0.6 , owner, projectile, { damageSourceId = eDamageSourceId.mp_weapon_concussive_breach } )
		}
	}

	array<entity> breakableDoors = GetEntArrayByClass_Expensive( "prop_door" )
	foreach ( entity door in breakableDoors )
	{
		if ( DistanceSqr( origin, door.GetOrigin() ) > ( forceRadius * forceRadius ) )
			continue

		vector originToDoor = Normalize( door.GetCenter() - origin )

		float doorDot = DotProduct( forceforward, originToDoor )

		//printt( "DOOR DOT: " + trapDot )

		if ( doorDot < 0 )
			continue

		//DebugDrawLine( origin, origin + ( originToTrap * forceRadius ) , 255, 255, 255, true, 30.0 )

		//Destroy door
		door.TakeDamage( door.GetMaxHealth() * 0.75, owner, projectile, { damageSourceId = eDamageSourceId.mp_weapon_concussive_breach, force = originToDoor, scriptType = DF_EXPLOSION } )
		door.OpenDoor( projectile )
	}

}

void function ConcussiveBreach_FireSonicRipple( vector origin, vector dir, float range )
{
	int fxCount = int ( floor( range / 85.333 ) )
	vector angles = VectorToAngles( dir )
	float stepSize = range / fxCount
	float rangeOffset = 0

	int count = 0
	while ( count < fxCount )
	{
		vector offsetOrigin = origin + ( dir * rangeOffset )
		int fxID	= GetParticleSystemIndex( CONCUSSIVE_BREACH_WORLD_REFRACT_FX )
		entity fx 	= StartParticleEffectInWorld_ReturnEntity( fxID, offsetOrigin, angles )
		thread ConcussiveBreach_CleanUpRippleFX( fx )

		count++
		rangeOffset = stepSize * count
	}

}

void function ConcussiveBreach_CleanUpRippleFX( entity fx )
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

	wait 3.0
}

void function ConcussiveBreach_PlaySonarActivateSound( entity projectile )
{
	Assert( IsValid( projectile ) )

	// play the sonar activated sounds here
	EmitSoundOnEntity( projectile, "SonarScan_Activate_3p" )
}

void function ConcussiveBreach_SonarThink( entity projectile )
{
	projectile.EndSignal( "OnDestroy" )

	entity owner = projectile.GetOwner()
	if ( !IsValid( owner ) )
		return

	//StatusEffect_AddTimed( projectile, eStatusEffect.device_detected, 0.01, CONCUSSIVE_BREACH_SCAN_DURATION, 0.0 )
	//StatusEffect_AddTimed( projectile, eStatusEffect.sonar_pulse_visuals, 1, CONCUSSIVE_BREACH_SCAN_DURATION, 0.0 )

	//int attachmentID = projectile.LookupAttachment( "HEADSHOT" )
	//StartParticleEffectOnEntity( owner, GetParticleSystemIndex( FLASHEFFECT ), FX_PATTACH_POINT_FOLLOW, attachmentID )

	int team = owner.GetTeam()
	vector pulseOrigin = projectile.GetOrigin()
	array<entity> ents = []

	entity trigger = CreateTriggerRadiusMultiple_Deprecated( pulseOrigin, AREA_SONAR_SCAN_RADIUS_BREACH, ents, TRIG_FLAG_START_DISABLED | TRIG_FLAG_NO_PHASE_SHIFT )
	trigger.e.sonarConeDirection 	= -projectile.GetUpVector()
	trigger.e.sonarConeFOV 			= CONCUSSIVE_BREACH_SCAN_CONE_FOV
	trigger.e.sonarConeDetections	= 0
	SetTeam( trigger, team )
	trigger.SetOwner( owner )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( projectile )

	//Create a trigger cylinder that only detects collision with prop scripts that have been registered using AddSonarDetectionForPropScript.
	array<entity> sonarRegisteredPropScripts = GetSonarRegisteredPropScripts( pulseOrigin, CONCUSSIVE_BREACH_BLAST_RADIUS )
	if ( sonarRegisteredPropScripts.len() )
	{
		thread ConcussiveBreach_PropScriptUpdate( projectile )
	}

	// IncrementSonarPerTeamGrenade( team )

	/*
	if ( IsValid( projectile ) && projectile.IsPlayer() )
	{
		array<entity> offhandWeapons = projectile.GetOffhandWeapons()
		foreach ( weapon in offhandWeapons )
		{
			//if ( weapon.GetWeaponClassName() == grenade.GetWeaponClassName() ) // function doesn't exist for grenade entities
			if ( weapon.GetWeaponClassName() == "mp_weapon_grenade_sonar" )
			{
				float duration = weapon.GetWeaponSettingFloat( eWeaponVar.grenade_ignition_time ) + 0.75 // buffer cause these don't line up
				StatusEffect_AddTimed( weapon, eStatusEffect.simple_timer, 1.0, duration, duration )
				break
			}
		}
	}
	*/

	OnThreadEnd(
		function() : ( trigger, team )
		{
			/*
			if ( IsValid ( projectile ) )
			{
				if ( trigger.e.sonarConeDetections > 0 )
				{
					// play the target acquisition end sound here
					//EmitSoundOnEntityOnlyToPlayer( projectile, projectile, "SonarScan_AcquiredOut_1p" )
				}

				//int deviceCount = 2 + trigger.e.sonarConeDetections //Two device means no devices for our purposes.
				//float cappedCount = min ( deviceCount, 12 )
				//float convertedCount = cappedCount * 0.01
				//StatusEffect_AddTimed( projectile, eStatusEffect.device_detected, convertedCount, CONCUSSIVE_BREACH_SCAN_HUD_FEEDBACK_DURATION, 0.0 )
			}
			*/

			// DecrementSonarPerTeamGrenade( team )
			trigger.Destroy()
		}
	)

	AddCallback_ScriptTriggerEnter_Deprecated( trigger, ConcussiveBreach_OnSonarTriggerEnter )
	AddCallback_ScriptTriggerLeave_Deprecated( trigger, ConcussiveBreach_OnSonarTriggerLeave )
	ScriptTriggerSetEnabled_Deprecated( trigger, true )

	ConcussiveBreach_PlaySonarActivateSound( projectile )

	if ( IsValid( owner ) && owner.IsPlayer() )
		Signal( projectile, "AreaSonarScan_Activated" )

	//int pulseAttachmentID = projectile.LookupAttachment( "HEADSHOT" )
	array<entity> players = GetPlayerArray()
	ConcussiveBreach_BroadcastPulseConeEffectToPlayers( pulseOrigin, trigger.e.sonarConeDirection, trigger.e.sonarConeFOV, players, team, projectile )
	//StartParticleEffectOnEntity( owner, GetParticleSystemIndex( FLASHEFFECT ), FX_PATTACH_POINT_FOLLOW, pulseAttachmentID )

	wait CONCUSSIVE_BREACH_SCAN_DURATION
}

void function ConcussiveBreach_PropScriptUpdate( entity projectile )
{
	Assert( IsNewThread(), "Must be threaded off." )
	projectile.EndSignal( "OnDestroy" )

	entity owner = projectile.GetOwner()
	if ( !IsValid( owner ) )
		return

	int team = owner.GetTeam()
//int attachmentID = projectile.LookupAttachment( "CHESTFOCUS" )
	vector pulseOrigin = projectile.GetOrigin()

	array<entity> sonarRegisteredPropScripts = GetSonarRegisteredPropScripts( pulseOrigin, CONCUSSIVE_BREACH_BLAST_RADIUS )
	entity triggerPropScript = CreateTriggerRadiusMultiple_Deprecated( pulseOrigin, CONCUSSIVE_BREACH_BLAST_RADIUS, sonarRegisteredPropScripts, TRIG_FLAG_START_DISABLED | TRIG_FLAG_NO_PHASE_SHIFT )
	triggerPropScript.e.sonarConeDirection 	= -projectile.GetUpVector()
	triggerPropScript.e.sonarConeFOV 		= CONCUSSIVE_BREACH_SCAN_CONE_FOV
	SetTeam( triggerPropScript, team )
	triggerPropScript.SetOwner( owner )
	triggerPropScript.RemoveFromAllRealms()
	triggerPropScript.AddToOtherEntitysRealms( projectile )

	triggerPropScript.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( triggerPropScript )
		{
			if ( IsValid( triggerPropScript ) )
				triggerPropScript.Destroy()
		}
	)

	AddCallback_ScriptTriggerEnter_Deprecated( triggerPropScript, ConcussiveBreach_OnSonarTriggerEnter )
	AddCallback_ScriptTriggerLeave_Deprecated( triggerPropScript, ConcussiveBreach_OnSonarTriggerLeave )
	ScriptTriggerSetEnabled_Deprecated( triggerPropScript, true )

	wait CONCUSSIVE_BREACH_SCAN_DURATION
}

void function ConcussiveBreach_BroadcastPulseConeEffectToPlayers( vector pulseConeOrigin, vector pulseConeDir, float pulseConeFOV, array<entity> players, int team, entity owner )
{
	foreach ( player in players )
	{
		bool showTrail = ( owner == player )
		if ( owner.DoesShareRealms( player ) )
			Remote_CallFunction_Replay( player, "ServerCallback_SonarPulseConeFromPosition", pulseConeOrigin, CONCUSSIVE_BREACH_BLAST_RADIUS, pulseConeDir, pulseConeFOV, team, 3.0, true, showTrail )
	}
}

void function ConcussiveBreach_OnSonarTriggerEnter( entity trigger, entity ent )
{
	if ( !IsEnemyTeam( trigger.GetTeam(), ent.GetTeam() ) )
		return

	if ( !ent.DoesShareRealms( trigger ) )
		return

	if ( ent.e.sonarTriggers.contains( trigger ) )
		return

	//Only ping players that are within our sonar cone.
	vector posToTarget = Normalize( ent.GetOrigin() - trigger.GetOrigin() )
	float dot = DotProduct( posToTarget, trigger.e.sonarConeDirection )
	float angle = DotToAngle( dot )

	//If entity is not in sonar cone run a thread to see if they enter it.
	if ( angle > ( trigger.e.sonarConeFOV / 2 ) )
	{
		//thread AreaSonarScan_WaitForEnterCone( trigger, ent )
		return
	}

	if ( trigger.e.sonarConeDetections == 0 )
	{
		// play targer acquisition "start" sound here
		entity owner = trigger.GetOwner()
		EmitSoundOnEntityOnlyToPlayer( owner, owner, "SonarScan_AcquireTarget_1p" )
	}
	trigger.e.sonarConeDetections++

	ent.e.sonarTriggers.append( trigger )
	SonarStart( ent, trigger.GetOrigin(), trigger.GetTeam(), trigger.GetOwner() )
}

void function ConcussiveBreach_WaitForEnterCone( entity trigger, entity ent )
{
	Assert( IsNewThread(), "Must be threaded off." )
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )

	trigger.EndSignal( "OnDestroy" )

	while ( GetAllEntitiesInTrigger_Deprecated( trigger ).contains( ent ) )
	{
		if ( !IsEnemyTeam( trigger.GetTeam(), ent.GetTeam() ) )
			return

		if ( ent.e.sonarTriggers.contains( trigger ) )
			return

		//Only ping players that are within our sonar cone.
		vector posToTarget = Normalize( ent.GetOrigin() - trigger.GetOrigin() )
		float dot = DotProduct( posToTarget, trigger.e.sonarConeDirection )
		float angle = DotToAngle( dot )

		if ( angle <= ( trigger.e.sonarConeFOV / 2 ) )
		{
			ent.e.sonarTriggers.append( trigger )
			SonarStart( ent, trigger.GetOrigin(), trigger.GetTeam(), trigger.GetOwner() )
			return
		}

		WaitFrame()
	}
}

void function ConcussiveBreach_OnSonarTriggerLeave( entity trigger, entity ent )
{
	int triggerTeam = trigger.GetTeam()
	if ( !IsEnemyTeam( triggerTeam, ent.GetTeam() ) )
		return

	OnSonarTriggerLeaveInternal( trigger, ent )
}


#endif //SERVER

#if CLIENT

void function ConcussiveBreach_OnPropScriptCreated( entity ent )
{
	switch ( ent.GetScriptName() )
	{
		case "concussive_breach_marker":
			thread ConcussiveBreach_CreateHUDMarker( ent )
			break
	}
}

void function ConcussiveBreach_CreateHUDMarker( entity marker )
{
	entity localClientPlayer = GetLocalClientPlayer()

	marker.EndSignal( "OnDestroy" )

	if ( !ConcussiveBreach_ShouldShowIcon( localClientPlayer, marker ) )
		return

	vector pos = marker.GetOrigin()
	var topology = CreateRUITopology_Worldspace( marker.GetOrigin(), marker.GetAngles(), 24, 24 )
	var ruiPlane = RuiCreate( $"ui/concussive_breach_timer.rpak", topology, RUI_DRAW_WORLD, 0 )
	RuiSetGameTime( ruiPlane, "startTime", Time() )
	RuiSetFloat( ruiPlane, "lifeTime", CONCUSSIVE_BREACH_FIRE_DELAY )

	//entity arrow = CreateClientSidePropDynamic( marker.GetOrigin() + ( -marker.GetForwardVector() * 32.0 ), marker.GetAngles() - <0,90,90>, CONCUSSIVE_BREACH_AR_DIRECTION_MODEL )
	entity arrow = CreateClientSidePropDynamic( marker.GetOrigin() + ( -marker.GetForwardVector() * 32.0 ), AnglesCompose( marker.GetAngles(), <90,0,0> ), CONCUSSIVE_BREACH_AR_DIRECTION_MODEL )
	arrow.SetModelScale( 0.5 )

	OnThreadEnd(
		function() : ( ruiPlane, topology, arrow )
		{
			RuiDestroy( ruiPlane )
			RuiTopology_Destroy( topology )

			if ( IsValid( arrow ) )
				arrow.Destroy()
		}
	)

	WaitForever()
}

bool function ConcussiveBreach_ShouldShowIcon( entity localPlayer, entity portalMarker )
{
	if ( !GamePlayingOrSuddenDeath() )
		return false

	return true
}

#endif //CLIENT