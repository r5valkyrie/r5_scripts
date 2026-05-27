                      

global function Grenade_OnWeaponTossReleaseAnimEvent_RevShell
global function OnWeaponCustomActivityStart_weapon_Revshell
global function OnWeaponCustomActivityEnd_weapon_Revshell
global function OnWeaponActivate_RevShell
global function OnWeaponDeactivate_RevShell
global function RevShell_Init
global function IsRevShellEnabled

#if CLIENT
global function ClientRevShellTargetFX
#endif

const asset REV_SHELL_MODEL = $"mdl/weapons/skull_grenade/skull_grenade_base_v.rmdl"
const asset REV_SHELL_MODEL_V1 = $"mdl/weapons/skull_grenade/skull_grenade_base_v_v1.rmdl"
const asset VFX_REV_SHELL_DESTROY = $"P_destroy_exp_rev"
const asset VFX_REV_SHELL_FIZZLE = $"P_wpn_grenade_rev_fizzle"
const asset VFX_REV_SHELL_LOCK_ON = $"P_revNade_lockon_sprite"
const asset VFX_REV_SHELL_EYE_GLOW = $"P_wpn_grenade_rev_eyeglow"
const asset VFX_REV_SHELL_EYE_GLOW_VOICE = $"P_wpn_grenade_rev_eyeglow_voice"
global const string REV_SHELL_TARGETNAME = "Rev_shell"
global const string REV_SHELL_SCRIPTNAME = "revShell"

const string REV_SHELL_SHELLTARGETVICTIM_SOUND = "diag_mp_nocNotify_bc_shellTargetVictim_3p"
const string REV_SHELL_SHELLTARGE_SOUND = "diag_mp_nocNotify_bc_shellSeek_3p"
const string REV_SHELL_SHELLTAUNTHUMAN = "diag_mp_nocNotify_bc_shellTauntHuman_1p"
const string REV_SHELL_SHELLTAUNTROBOT = "diag_mp_nocNotify_bc_shellTauntRobot_1p"
const string REV_SHELL_SHELLTAUNTREV = "diag_mp_nocNotify_bc_shellTauntRevenant_1p"
const string REV_SHELL_DESTROY_SOUND = "explo_revshellseeker_destroyed_3p"
const string REV_SHELL_LOCKED_ON_VICTIM_SOUND = "ui_revshellseeker_victim_targetlock_1p"
const string REV_SHELL_LOCKED_ON_AGGRESSOR_SOUND = "ui_revshellseeker_aggressor_targetlock_1p"
const string REV_SHELL_ON_THROWN = "weapon_revshellseeker_seekingloop_3p"
const string REV_SHELL_SHELL_TOSS = "diag_mp_nocNotify_bc_shellToss_3p"
const string REV_SHELL_WARNING_BEEP = "weapon_revshellseeker_explosivewarningbeep_3p"


const float SPEED_CHANGE_DISTANCE_THRESHOLD = 800.0 //around 20 meters
global const float REV_SHELL_GIVE_UP_TIME = 30 // seconds
float CLOSE_CHASE_SPEED = 240.0 //units per second
float FAR_CHASE_SPEED = 660.0 //units per second

const vector HEIGHT_OFFSET = < 0.0, 0.0, 50.0 >

string shellTauntVoice = REV_SHELL_SHELLTAUNTHUMAN

struct PathingState
{
	array< vector >	waypoints
	bool 			finished = false
	entity			target = null
	float			velocity = 660.0
}

void function RevShell_Init()
{
	RegisterSignal( "RevShellTauntEnd" )
	RegisterSignal( "RevShellEnd" )
	PrecacheModel( REV_SHELL_MODEL )
	PrecacheModel( REV_SHELL_MODEL_V1 )
	PrecacheParticleSystem( VFX_REV_SHELL_DESTROY )
	PrecacheParticleSystem( VFX_REV_SHELL_FIZZLE )
	PrecacheParticleSystem( VFX_REV_SHELL_LOCK_ON )
	PrecacheParticleSystem( VFX_REV_SHELL_EYE_GLOW )
	PrecacheParticleSystem( VFX_REV_SHELL_EYE_GLOW_VOICE )
	Remote_RegisterClientFunction( "ClientRevShellTargetFX", "entity", "entity" )

	SURVIVAL_Loot_RegisterConditionalCheck( "mp_weapon_grenade_rev_shell", Rev_Shell_ConditionalCheck )

	CLOSE_CHASE_SPEED = GetCurrentPlaylistVarFloat( "rev_shell_close_chase_speed", CLOSE_CHASE_SPEED )
	FAR_CHASE_SPEED = GetCurrentPlaylistVarFloat( "rev_shell_far_chase_speed", FAR_CHASE_SPEED )

}

void function OnWeaponActivate_RevShell( entity weapon )
{
	Grenade_OnWeaponActivate( weapon )

	#if	CLIENT
	thread RevShell_PlayTauntVoice_Thread( weapon )
	thread RevShell_HandleEyeGlowVFX_Voice_Thread( weapon )
	#endif
}

void function OnWeaponDeactivate_RevShell(entity weapon)
{
	Grenade_OnWeaponDeactivate( weapon )
	Signal( weapon, "RevShellTauntEnd" )
}

void function OnWeaponCustomActivityStart_weapon_Revshell( entity weapon, int sequence )
{
	#if CLIENT
		//stop Rev shell VO during Inspect
		if ( weapon.GetWeaponActivity() == ACT_VM_WEAPON_INSPECT )
		{
			StopSoundOnEntityByName( weapon, shellTauntVoice )
		}
	#endif
}

void function OnWeaponCustomActivityEnd_weapon_Revshell( entity weapon, int sequence )
{
	//have the on end function here as well just in case is needed
}

#if CLIENT
void function RevShell_PlayTauntVoice_Thread( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( IsValid( weaponOwner ) == false )
		return

	if ( weaponOwner != GetLocalViewPlayer() )
		return

	EndSignal( weapon, "RevShellTauntEnd" )
	EndSignal( weapon, "OnDestroy" )

	string playerClass = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( weaponOwner ), Loadout_Character() ) )

	if ( playerClass == "character_revenant" )
	{
		shellTauntVoice = REV_SHELL_SHELLTAUNTREV
	}
	else if ( playerClass == "character_ash" || playerClass == "character_pathfinder" )
	{
		shellTauntVoice = REV_SHELL_SHELLTAUNTROBOT
	}

	while ( true )
	{
		wait RandomFloatRange( 3.0, 5.0 )
		if ( weapon.GetWeaponActivity() != ACT_VM_WEAPON_INSPECT )
		{
			EmitSoundOnEntity( weapon, shellTauntVoice )
		}
		wait RandomFloatRange( 7.0, 10.0 )
	}
}
#endif //client

var function Grenade_OnWeaponTossReleaseAnimEvent_RevShell( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( InPrediction() && !IsFirstTimePredicted() )
			return false

		if ( !weapon.ShouldPredictProjectiles() )
			return false

		StopSoundOnEntityByName( weapon, shellTauntVoice )
	#endif


	entity weaponOwner = weapon.GetWeaponOwner()

	weaponOwner.Signal( "ThrowGrenade" )

	int damageFlags = weapon.GetWeaponDamageFlags()

	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = attackParams.pos
	fireGrenadeParams.vel = Normalize( attackParams.dir )
	fireGrenadeParams.angVel = <0, 0, 0>
	fireGrenadeParams.fuseTime = 0
	fireGrenadeParams.scriptTouchDamageType = (damageFlags & ~DF_EXPLOSION) // when a grenade "bonks" something, that shouldn't count as explosive.explosive
	fireGrenadeParams.scriptExplosionDamageType = damageFlags
	fireGrenadeParams.clientPredicted = PROJECTILE_PREDICTED
	fireGrenadeParams.lagCompensated = PROJECTILE_NOT_LAG_COMPENSATED
	fireGrenadeParams.useScriptOnDamage = true

	int team = weaponOwner.GetTeam()

	entity grenade = weapon.FireWeaponGrenade( fireGrenadeParams )
	SetTeam( grenade, team )
	grenade.SetScriptName( REV_SHELL_SCRIPTNAME )
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	EmitSoundOnEntity( grenade, REV_SHELL_SHELL_TOSS )
	PlayerUsedOffhand( weaponOwner, weapon, true, grenade ) // intentionally here and in Hack_DropGrenadeOnDeath - accurate for when cooldown actually begins

	#if SERVER
		vector origin = grenade.GetOrigin()
		vector angles = grenade.GetAngles()
		entity grenadeProxy = CreatePropScript( REV_SHELL_MODEL_V1, origin, angles, SOLID_OBB )
		grenadeProxy.kv.contents = CONTENTS_BULLETCLIP
		grenadeProxy.Hide()
		grenadeProxy.SetScriptName( REV_SHELL_SCRIPTNAME )
		grenadeProxy.SetParent( grenade )
		grenadeProxy.SetMaxHealth( 200 )
		grenadeProxy.SetHealth( 200 )
		grenadeProxy.DisableHibernation()
		//grenade.SetArmorType( ARMOR_TYPE_HEAVY )
		grenadeProxy.SetScriptName( REV_SHELL_TARGETNAME )
		grenadeProxy.SetBlocksRadiusDamage( false )
		SetTargetName( grenadeProxy, REV_SHELL_TARGETNAME )
		grenadeProxy.SetBossPlayer( weaponOwner )
		grenadeProxy.RemoveFromAllRealms()
		grenadeProxy.AddToOtherEntitysRealms( weaponOwner )
		SetTeam( grenadeProxy, team )
		grenadeProxy.SetDamageNotifications( true )
		grenadeProxy.SetTakeDamageType( DAMAGE_YES )
		//AddSonarDetectionForPropScript( grenade )
		AddEntityCallback_OnDamaged( grenadeProxy, OnRevShellDamaged )
		AddEntityCallback_OnPostDamaged( grenadeProxy, OnRevShellPostDamaged )
		thread RevShell_HandleEyeGlowVFX_Thread( grenade, weapon )
		thread RevShell_SearchForEnemies( weaponOwner, grenade, grenadeProxy )
	#endif

	return weapon.GetAmmoPerShot()
}

#if SERVER
void function OnRevShellDamaged( entity grenadeProxy, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )

	entity grenade = grenadeProxy.GetParent()

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( IsValid( attacker ) )
	{
		if ( grenadeProxy.GetTeam() == attacker.GetTeam() )
			return
	}

	if ( IsValid( grenade ) )
	{
		if ( (grenadeProxy.GetHealth() - damage) <= 175.0 )
		{
			Signal( grenade, "RevShellEnd" )
			int fxIndex = GetParticleSystemIndex( VFX_REV_SHELL_DESTROY )
			EmitSoundAtPosition( TEAM_ANY, grenade.GetOrigin(), REV_SHELL_DESTROY_SOUND, grenade )
			StartParticleEffectInWorld( fxIndex, grenade.GetOrigin(), < 0, 0, 0 > )
			grenadeProxy.Destroy()
			grenade.Destroy()
		}
	}
}
#endif

void function OnRevShellPostDamaged( entity grenadeProxy, var damageInfo )
{
#if SERVER
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( grenadeProxy.GetTeam() == attacker.GetTeam() )
		return

	if ( attacker.IsPlayer() && IsAlive( attacker ) )
	{
		attacker.NotifyDidDamage( grenadeProxy, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}
#endif
}

#if SERVER
entity function Create_RevShell_Mover( entity projectile )
{
	//vector playerViewVec = FlattenVec( Normalize( player.GetViewVector() ) )
	vector skullPos = projectile.GetOrigin()
	entity mover = CreateScriptMover( "RevShell_mover", skullPos, < 0, 0, 0 > )
	mover.RemoveFromAllRealms()
	mover.AddToOtherEntitysRealms( projectile )
	projectile.SetParent( mover )

	return mover
}

void function StartSamplingTargetPosition( entity target, PathingState pathingState )
{
	pathingState.target = target
	pathingState.finished = false

	thread KeepSampling( pathingState )
}

void function StopSamplingTargetPosition( PathingState pathingState )
{
	pathingState.finished = true
}

void function KeepSampling( PathingState pathingState )
{
	float failsafeTimeout = Time() + 60.0

	while ( pathingState.finished == false && Time() < failsafeTimeout )
	{
		WaitFrame()

		if ( !IsValid( pathingState.target ) )
			break

		SampleTargetPosition( pathingState )
	}
}

const int MAX_SKIPS_PER_FRAME = 10

vector function GetNextWaypoint( vector currentPosition, PathingState pathingState )
{
	if ( pathingState.waypoints.len() == 0 )
		return < 0, 0, 0 >

	bool foundNextWaypoint = false

	// We have to be careful to not create a massive frametime on the server
	int skips = 0

	vector waypoint = pathingState.waypoints[0]
	pathingState.waypoints.remove( 0 )
	
	while ( !foundNextWaypoint && pathingState.waypoints.len() > 0 && skips < MAX_SKIPS_PER_FRAME )
	{
		vector nextWaypoint = pathingState.waypoints[0]

		//Is it worth checking for super close waypoints?
		// while ( Distance( currentPosition, targetPosition ) < 1.0 )
			// 	targetPosition = GetNextWaypoint( pathingState ) + HEIGHT_OFFSET

		TraceResults results = TraceLine( currentPosition, nextWaypoint, null, TRACE_MASK_OPAQUE, TRACE_COLLISION_GROUP_NONE )
		if ( results.fraction == 1.0 )
		{
			waypoint = nextWaypoint
			pathingState.waypoints.remove( 0 )
		}
		else
		{
			foundNextWaypoint = true
		}

		skips++
	}

#if DEV
	if ( skips >= MAX_SKIPS_PER_FRAME )
		printt( "REVGRENADE: Rev grenade had too many waypoints to skip!" )
#endif

	return waypoint
}

void function SampleTargetPosition( PathingState pathingState )
{
	vector nextPosition = pathingState.target.GetOrigin()

	if ( pathingState.waypoints.len() > 0 )
	{
		vector lastPosition = pathingState.waypoints[pathingState.waypoints.len() - 1]

		if ( DistanceSqr( lastPosition, nextPosition ) <= 0.1 )
			return
	}

	//DebugDrawSphere( nextPosition, 16.0, < 0, 255, 0 >, true, 5.0 )

	pathingState.waypoints.append( nextPosition )
}

void function PathFindToTargetPosition( vector currentPosition, vector targetPosition, PathingState pathingState )
{

}

void function FlyToTarget_Thread( entity target, vector initialPosition, entity projectile )
{
	if ( !IsValid( target ) )
	{
		projectile.ClearParent()

		if ( projectile.GrenadeHasIgnited() == false )
			projectile.GrenadeIgnite()
	}

	entity mover = Create_RevShell_Mover( projectile )

	EndSignal( projectile, "RevShellEnd" )
	EndSignal( projectile, "OnDestroy" )

	PathingState pathingState

	pathingState.waypoints.append( initialPosition )

	//PathFindToTargetPosition( mover.GetOrigin(), target.GetOrigin(), pathingState )
	StartSamplingTargetPosition( target, pathingState )

	vector currentPosition	= mover.GetOrigin()
	vector targetPosition	= GetNextWaypoint( currentPosition, pathingState ) + HEIGHT_OFFSET
	//DebugDrawSphere( targetPosition, 16.0, < 255, 0, 0 >, true, 20.0 )
	vector movementVector 	= targetPosition - currentPosition
	float travelTime		= Length( movementVector ) / pathingState.velocity
	float bailTime 			= Time() + REV_SHELL_GIVE_UP_TIME // Grenade gives up

	projectile.SetLocalAngles( <0, 0, 0> )

	if ( travelTime > 0.0 )
	{
		mover.NonPhysicsMoveTo( targetPosition, travelTime, 0.0, 0.0 )
		mover.NonPhysicsRotateTo( VectorToAngles( movementVector ), 0.4, 0.2, 0.0 )
	}

	PassByReferenceBool destroyedByTrophy
	destroyedByTrophy.value = false

	OnThreadEnd(
		function() : ( mover, projectile, pathingState, destroyedByTrophy )
		{
			if ( destroyedByTrophy.value == false )
				RevShell_Explode( /*pathingState,*/ projectile )

			StopSamplingTargetPosition( pathingState )

			thread RevShell_Cleanup( projectile, mover )
		}
	)

	while ( Time() < bailTime )
	{
		if ( !IsValid( target ) || !IsValid( mover ) )
			break

		//Wattson ult
		entity enemyTrophy = Trophy_GetTrophyInRangeOfEntity( projectile, true )
		if ( enemyTrophy != null && IsValid( enemyTrophy ) )
		{
			//Trophy_RemoteTryZapEntity might call projectile OnDestroy which triggers the EndSignal and ThreadEnd
			//So set to true here in case it succeeds
			destroyedByTrophy.value = true

			if ( Trophy_RemoteTryZapEntity( enemyTrophy, projectile ) )
			{
				break
			}
			else
			{
				destroyedByTrophy.value = false
			}
		}

		//currentPosition really means "Last Current Position" here as it hasn't updated yet
		TraceResults collisionResult  = TraceLine( currentPosition, mover.GetOrigin(), [projectile], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

		//We hit something between our last position and our current position
		//Go back to the last position and explode
		if ( collisionResult.startSolid || collisionResult.fraction < 1.0 )
		{
			mover.SetOrigin( collisionResult.endPos )
			break
		}

		currentPosition = mover.GetOrigin()

		vector enemyPosition = target.GetOrigin() + HEIGHT_OFFSET

		float distanceToEnemy = Distance( currentPosition, enemyPosition )

		if ( distanceToEnemy < 40.0 )
		{
			RevShell_Explode( /*pathingState,*/ projectile )

			movementVector = enemyPosition - currentPosition

			targetPosition = currentPosition + (movementVector * 0.5)

			float ignitionTime = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.grenade_ignition_time )

			mover.NonPhysicsMoveTo( targetPosition, ignitionTime, 0.0, 0.0 )

			mover.NonPhysicsRotateTo( VectorToAngles( movementVector ), 0.1, 0.0, 0.0 )

			break
		}
		if ( distanceToEnemy < SPEED_CHANGE_DISTANCE_THRESHOLD )
			pathingState.velocity = CLOSE_CHASE_SPEED
		else
			pathingState.velocity = FAR_CHASE_SPEED

		TraceResults results = TraceLine( currentPosition, enemyPosition, null, TRACE_MASK_OPAQUE, TRACE_COLLISION_GROUP_NONE )

		if ( results.fraction == 1.0 )
		{
			pathingState.waypoints.clear()
			targetPosition = enemyPosition
			movementVector = targetPosition - currentPosition
			travelTime = Length( movementVector ) / pathingState.velocity
		}
		else
		{
			while ( Distance( currentPosition, targetPosition ) < 1.0 )
				targetPosition = GetNextWaypoint( currentPosition, pathingState ) + HEIGHT_OFFSET

			//DebugDrawText( targetPosition, string( Distance( currentPosition, targetPosition ) ), true, 0.0 )
			//DebugDrawSphere( targetPosition, 16.0, < 255, 0, 0 >, true, travelTime )
		}

		Assert( currentPosition != targetPosition )

		if ( currentPosition != targetPosition )
		{
			movementVector = targetPosition - currentPosition
			travelTime = Length( movementVector ) / pathingState.velocity
			
			mover.NonPhysicsMoveTo( targetPosition, travelTime, 0.0, 0.0 )
			mover.NonPhysicsRotateTo( VectorToAngles( movementVector ), 0.1, 0.0, 0.0 )
		}

		WaitFrame()
	}
}

void function RevShell_Cleanup( entity projectile, entity mover )
{
	if ( IsValid( projectile ) == false )
	{
		if ( IsValid( mover ) )
			mover.Destroy()
	}

	float ignitionTime = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.grenade_ignition_time )

	wait ignitionTime

	if ( IsValid( projectile ) )
		projectile.ClearParent()

	if ( IsValid( mover ) )
		mover.Destroy()
}

#endif //server

#if SERVER
//Leaving those comments in case we decide sticking to the enemy is a better call
void function RevShell_Explode( /*PathingState pathingState,*/ entity projectile )
{
	if ( IsValid( projectile ) == false || projectile.GrenadeHasIgnited() )
		return

	EmitSoundOnEntity( projectile, REV_SHELL_WARNING_BEEP )

	// if ( IsValid( pathingState.target ) )
	// {
	// 	DeployableCollisionParams collisionParams
	// 	collisionParams.pos = pathingState.target.EyePosition()
	// 	collisionParams.normal = < 0, 1, 0 >
	// 	collisionParams.hitEnt = pathingState.target
	// 	collisionParams.isCritical = true
	// 	PlantStickyEntity( projectile, collisionParams, <0, 0, 0>, true )
	// }

	projectile.GrenadeIgnite()
}
#endif

#if SERVER
void function RevShell_SearchForEnemies( entity player, entity projectile, entity proxy )
{
	EndSignal( projectile, "OnDestroy" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )

	float waitBeforeSearch = Time() + 1.0

	//Wait for 1 second before searching for targets
	//Maintain projectile coherent direction in the meantime
	while ( IsValid( projectile ) && Time() <= waitBeforeSearch )
	{
		projectile.SetAngles( VectorToAngles( projectile.GetVelocity() ) )

		WaitFrame()
	}

	float bailTime = Time() + REV_SHELL_GIVE_UP_TIME

	while ( IsValid( projectile ) && IsValid( player ) )
	{
		vector facing    = projectile.GetVelocity()
		vector facingAng = VectorToAngles( facing )
		projectile.SetAngles( facingAng )

		if ( bailTime <= Time() )
		{
			break
		}

		entity target = RevShell_CanISeeNearbyEnemies( projectile )

		if ( IsValid( target ) )
		{
			projectile.SetVelocity( < 0, 0, 0 > )
			projectile.SetPhysics( MOVETYPE_NONE )

			if ( target.IsPlayer() )
			{
				EmitSoundOnEntityOnlyToPlayer( target, target, REV_SHELL_SHELLTARGETVICTIM_SOUND  )
				EmitSoundOnEntityExceptToPlayer( projectile, target, REV_SHELL_SHELLTARGE_SOUND  )
			}
			else
			{
				EmitSoundOnEntity( projectile, REV_SHELL_SHELLTARGE_SOUND  )
			}

			//Create Mover
			thread RevShell_HandleChasingVO_Thread( projectile )
			thread FlyToTarget_Thread( target, target.GetOrigin(), projectile )
			thread TargetedByRevShell_Thread( player, target, projectile )
			thread TargetingThreatIndicator_Thread( projectile, target )
			Remote_CallFunction_NonReplay( player, "ClientRevShellTargetFX", target, projectile )
			return
		}

		WaitFrame()
	}

	OnThreadEnd(
		function() : ( projectile, proxy )
		{
			if ( IsValid( projectile ) )
			{
				int fxIndex = GetParticleSystemIndex( VFX_REV_SHELL_FIZZLE )
				vector facing    = projectile.GetVelocity()
				vector facingAng = VectorToAngles( facing )
				StartParticleEffectInWorld( fxIndex, projectile.GetOrigin(), facingAng )
				projectile.Destroy()
			}

			if ( IsValid( proxy ) )
			{
				proxy.Destroy()
			}
		}
	)
}

entity function RevShell_CanISeeNearbyEnemies( entity projectile )
{
	entity closestPlayer = GetClosest( RevShell_GetNearbyVisibleEnemies( projectile, projectile.GetOrigin(), 5000 ), projectile.GetOrigin() )

	return closestPlayer
}

array< entity > function RevShell_GetNearbyVisibleEnemies( entity projectile, vector projectilePos, float distance )
{
	int grenadeTeam = projectile.GetTeam()
	array< int > badList
	array< entity > results = GetPlayerArrayEx( "any", TEAM_ANY, grenadeTeam, projectilePos, distance )
	results.extend( GetPlayerDecoyArray() )

	foreach ( int index, entity ent in results )
	{
		if (  !ent.IsPlayer()
				||!ent.DoesShareRealms( projectile )
				|| ent.IsPhaseShifted()
				|| ent.IsCloaked( true )
				|| ( ent.GetTeam() == grenadeTeam )
				|| !IsAlive(ent)
				|| BleedoutState_GetPlayerBleedoutState( ent ) == BS_BLEEDING_OUT
				)
		{
			badList.append( index )
		}
		else
		{
			//Use TRACE_MASK_NPCWORLDSTATIC or TraceLineNoEnts instead for testing exploding on dynamic obstacles like doors
			//TraceResults traceResult = TraceLineNoEnts( projectilePos, ent.GetOrigin(), TRACE_MASK_NPCWORLDSTATIC )

			TraceResults traceResult = TraceLine( projectilePos, ent.GetOrigin(), ent, TRACE_MASK_OPAQUE, TRACE_COLLISION_GROUP_NONE )

			//0.99 because the BVH collision check has a cushion
			//So if we run this when the grenade perfectly bounces on the ground the ground might block visibility
			if ( traceResult.fraction < 0.99 )
				badList.append( index )
		}
	}

	int badListLen = badList.len()
	for ( int idx = 0; idx < badListLen; ++idx )
	{
		int badIndex = badList[badListLen - 1 - idx]
		results.remove( badIndex )
	}

	return results
}
#endif //server

#if SERVER
void function TargetedByRevShell_Thread( entity player, entity target, entity projectile )
{
	EndSignal( projectile, "RevShellEnd" )
	EndSignal( projectile, "OnDestroy" )

	int effectHandle = StatusEffect_AddTimed( target, eStatusEffect.rev_shell_targeted, 1.0, REV_SHELL_GIVE_UP_TIME, 0.0 )
	if ( IsValid( player ) && IsValid( target ) )
	{
		EmitSoundOnEntityOnlyToPlayer( target, player, REV_SHELL_LOCKED_ON_AGGRESSOR_SOUND )
	}
	if ( IsValid( target ) )
	{
		EmitSoundOnEntityOnlyToPlayer( target, target, REV_SHELL_LOCKED_ON_VICTIM_SOUND )
	}

	OnThreadEnd(
		function() : ( target, effectHandle )
		{
			if ( IsValid( target ) )
			{
				StatusEffect_Stop( target, effectHandle )
			}
		}
	)

	WaitForever()
}
#endif

#if CLIENT
void function ClientRevShellTargetFX( entity target, entity projectile )
{
	thread ClientRevShellTargetFX_Thread( target, projectile )
}

void function ClientRevShellTargetFX_Thread( entity target, entity projectile )
{
	if ( !IsValid( target ) || !IsValid( projectile ) )
		return

	EndSignal( projectile, "RevShellEnd" )
	EndSignal( projectile, "OnDestroy" )

	int fxIndex = GetParticleSystemIndex( VFX_REV_SHELL_LOCK_ON )
	int attachIdx = target.LookupAttachment( "CHESTFOCUS" )
	Assert( attachIdx != 0, "Attachment index is 0 for some reason, consider checking IsPlayer()" )
	if ( attachIdx <= 0 )
	{
		return
	}

	int effectHandle = StartParticleEffectOnEntity( target, fxIndex, FX_PATTACH_POINT_FOLLOW, attachIdx )

	OnThreadEnd(
		function() : ( effectHandle )
		{
			if ( EffectDoesExist( effectHandle ) )
			{
				EffectStop( effectHandle, true, true )
			}
		}
	)

	WaitForever()
}

void function RevShell_HandleEyeGlowVFX_Voice_Thread( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity viewmodel = weapon.GetWeaponViewmodel()

	if ( !IsValid( viewmodel ) )
		return

	EndSignal( weapon, "RevShellTauntEnd" )
	EndSignal( weapon, "RevShellEnd" )
	EndSignal( weapon, "OnDestroy" )

	int fxIndex = GetParticleSystemIndex( VFX_REV_SHELL_EYE_GLOW_VOICE )
	int attachIdxL = viewmodel.LookupAttachment( "L_EYE_VFX" )
	int attachIdxR = viewmodel.LookupAttachment( "R_EYE_VFX" )
	Assert( attachIdxL != 0, "Attachment index is 0 for some reason, check rev shell" )
	Assert( attachIdxR != 0, "Attachment index is 0 for some reason, check rev shell" )
	if ( attachIdxL <= 0 || attachIdxR <= 0 )
	{
		return
	}

	int effectHandleL = StartParticleEffectOnEntity( viewmodel, fxIndex, FX_PATTACH_POINT_FOLLOW, attachIdxL )
	int effectHandleR = StartParticleEffectOnEntity( viewmodel, fxIndex, FX_PATTACH_POINT_FOLLOW, attachIdxR )

	OnThreadEnd(
		function() : ( effectHandleL, effectHandleR )
		{
			if ( EffectDoesExist( effectHandleL ) )
				EffectStop( effectHandleL, false, true )

			if ( EffectDoesExist( effectHandleR ) )
				EffectStop( effectHandleR, false, true )
		}
	)

	WaitForever()
}
#endif // client

#if SERVER
void function RevShell_HandleEyeGlowVFX_Thread( entity projectile, entity grenade )
{
	if ( !IsValid( projectile ) )
		return

	EndSignal( projectile, "RevShellEnd" )
	EndSignal( projectile, "OnDestroy" )

	EmitSoundOnEntity( projectile, REV_SHELL_ON_THROWN )
	int fxIndex = GetParticleSystemIndex( VFX_REV_SHELL_EYE_GLOW )
	int attachIdxL = grenade.LookupAttachment( "L_EYE_VFX" )
	int attachIdxR = grenade.LookupAttachment( "R_EYE_VFX" )
	Assert( attachIdxL != 0, "Attachment index is 0 for some reason, check rev shell" )
	Assert( attachIdxR != 0, "Attachment index is 0 for some reason, check rev shell" )
	if ( attachIdxL <= 0 || attachIdxR <= 0 )
	{
		return
	}

	entity effectHandleL = StartParticleEffectOnEntity_ReturnEntity( projectile, fxIndex, FX_PATTACH_POINT_FOLLOW, attachIdxL  )
	entity effectHandleR = StartParticleEffectOnEntity_ReturnEntity( projectile, fxIndex, FX_PATTACH_POINT_FOLLOW, attachIdxR  )

	OnThreadEnd(
		function() : ( effectHandleL, effectHandleR )
		{
			if ( IsValid( effectHandleL ) )
			{
				EffectStop( effectHandleL )
			}

			if ( IsValid( effectHandleR ) )
			{
				EffectStop( effectHandleR )
			}
		}
	)

	WaitForever()
}

void function RevShell_HandleChasingVO_Thread( entity projectile )
{
	EndSignal( projectile, "OnDestroy", "RevShellEnd" )

	OnThreadEnd(
		function() : ( projectile )
		{
			if ( IsValid( projectile ) )
			{
				StopSoundOnEntity( projectile, REV_SHELL_SHELLTARGE_SOUND )
			}
		}
	)

	while ( IsValid( projectile ) )
	{
		wait RandomFloatRange( 3.0, 5.0 )
		EmitSoundOnEntity( projectile, REV_SHELL_SHELLTARGE_SOUND )
	}
}

void function TargetingThreatIndicator_Thread( entity projectile, entity target )
{
	EndSignal( projectile, "OnDestroy", "RevShellEnd" )
	EndSignal( target, "OnDestroy", "OnDeath" )

	if ( !target.IsPlayer() )
		return

	entity threatIndicator = CreateThreatIndicator( projectile.GetCenter(), eThreatIndicatorID.GRENADE_INDICATOR_SKULL_MODEL, 3000, <0, 0, 0>, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_SELF, target )
	threatIndicator.RemoveFromAllRealms()
	threatIndicator.AddToOtherEntitysRealms( projectile )
	threatIndicator.SetParent( projectile )

	OnThreadEnd(
		function() : ( threatIndicator )
		{
			if( IsValid( threatIndicator ) )
				threatIndicator.Destroy()
		}
	)

	WaitForever()
}
#endif // server

bool function IsRevShellEnabled()
{
	return GetCurrentPlaylistVarBool( "rev_shell_enabled", false )
}

bool function Rev_Shell_ConditionalCheck( string ref, entity player )
{
	if ( !IsValid( player ) )
		return false

	int itemCount = SURVIVAL_CountItemsInInventory( player, ref )

	//If there are rev shells in this player's inventory.
	if ( itemCount > 0 )
		return true

	return IsRevShellEnabled()
}

                            
 