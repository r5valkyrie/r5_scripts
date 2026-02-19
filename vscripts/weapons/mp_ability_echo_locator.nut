global function MpWeaponEchoLocator_Init
global function OnWeaponTossReleaseAnimEvent_WeaponEchoLocator
global function OnWeaponTossPrep_WeaponEchoLocator
global function OnWeaponDeactivate_WeaponEchoLocator

const int ECHO_LOCATOR_RADIUS_SCRIPT = 1350
const int ECHO_LOCATOR_HP = 125
const int ECHO_LOCATOR_MAX_FOOTSTEP_TARGETS_TO_SHOW = 12 //4 squads, can't imagine too many fights being larger than this.
int COCKPIT_ECHO_LOCATOR_SCREEN_FX

const float TICK_RATE = 0.1
const float SPRINT_FX_WAIT_TIME = 0.15
const float JOG_FX_WAIT_TIME = 0.25
const float WEAPON_FIRE_FX_MIN_WAIT_TIME = 0.15
const float CROUCH_WALK_SPEED = 100
const float MAX_SPRINT_SPEED = 300.0
const float ECHO_LOCATOR_DEPLOY_DELAY = 0.4
const float ECHO_LOCATOR_DEPLOY_CLIENT_DELAY = 1.25
const float ECHO_LOCATOR_AMBIENT_SOUND_RADIUS = 3000
const float INITIAL_IDLE_ANIMATION_PERCENTAGE = 0.95
const float ECHO_LOCATOR_INITIAL_MARKER_DURATION = 1.25
const float LOCK_FX_RESET_TIME = 3.0
const float LOCK_FX_DEBOUNCE_TIME = 0.75
const float MINIMAP_MARKER_DEBOUNCE_TIME = 0.75
const float LOCK_FX_LIFETIME = 1.25
const float TOTAL_FIRE_TIME_BUFFER = 1.75
const float ECHO_LOCATOR_TUNING_DEATHFIELD_DAMAGE_SCALAR = 1.0
const float ECHO_LOCATOR_MOVEMENT_SPEED_CHECK = 170 //roughly walk speed (hold W with weapon in hand)
const float ECHO_LOCATOR_DUMMIE_SPEED_CHECK = 100 //actual crouch speed is observed to be 92, but using this to be safe.

const asset ECHO_LOCATOR_HEART_MODEL = $"mdl/props/pariah_heart/pariah_heart.rmdl"
const asset DRONE_CLUSTER_MODEL = $"mdl/props/pariah_drone_cluster/pariah_drone_cluster.rmdl"
const asset KILL_ROOM_VIEW_FX = $"P_killroom_hud_static"
const asset ECHO_LOCATOR_VISUAL_FOOT_PING = $"P_killroom_ground_ping_CP" //P_ar_echo_locator_ground_CP
const asset ECHO_LOCATOR_VISUAL_FOOT_PING_AI = $"P_killroom_ground_ping_CP_AI"
const asset ECHO_LOCATOR_HEART_1P_FX = $"P_killroom_heart_hold"    //added 1p fx for heart
const asset ECHO_LOCATOR_HEART_3P_FX = $"P_killroom_heart_hold_3p"    //added 3p fx for heart
const asset ECHO_LOCATOR_SCAN_FX = $"P_killroom_radius_init"
const asset ECHO_LOCATOR_DESTRUCTION_FX = $"P_killroom_exp"         // lets update to
const asset ECHO_LOCATOR_RADIUS_FX = $"P_killroom_radius_marker"
const asset ECHO_LOCATOR_HEART_FX = $"P_killroom_heart"
const asset ECHO_LOCATOR_HEART_ENEMY_FX = $"P_killroom_heart_enemy"
const asset ECHO_LOCATOR_TARGET_NON_ANIMATED = $"P_killroom_lockon_no_intro"
const asset ECHO_LOCATOR_TARGET_ANIMATED = $"P_killroom_lockon"
const asset ECHO_LOCATOR_DRONE_CLUSTER_FX = $"P_killroom_heart_drone_cluster" //Dfranco: updated drones on heart, following only pos not rotation.

const string ECHO_LOCATOR_THRESHOLD_SOUND = "Seer_Ultimate_Threshold"
const string ECHO_LOCATOR_AMBIENT_SOUND = "Seer_Ultimate_Dome_And_Center"
const string ECHO_LOCATOR_MOVEMENT_REVEALED_1P = "Seer_Ultimate_StatusEffect_Loop_1P"
const string ECHO_LOCATOR_SPHERE_ENDING = "Seer_Ultimate_Dome_Ending_1p"
const string ECHO_LOCATOR_AMBIENT_LOOP_START = "Seer_Ultimate_Dome_Perimeter_Start"
const string ECHO_LOCATOR_AMBIENT_LOOP = "Seer_Ultimate_Dome_Perimeter"
const string ECHO_LOCATOR_AMBIENT_LOOP_ENDING = "Seer_Ultimate_Dome_Perimeter_Ending"
const string ECHO_LOCATOR_TARGET_ACQUIRED_SOUND = "Seer_AcquireTarget_1P"

global const string ECHO_LOCATOR_SCRIPT_NAME = "echo_locator_script"
global const string ECHO_LOCATOR_TARGET_NAME = "echo_locator_target"
global const string ECHO_LOCATOR_WEAPON_NAME = "mp_ability_echo_locator"
const string ECHO_LOCATOR_DESTRUCTION_SOUND = "Seer_Ultimate_Dome_Destroy"
const string ECHO_LOCATOR_PLAYER_HAS_MOVEMENT_INPUT_NETVAR = "echoLocatorPlayerHasMovementInput"

#if DEVELOPER
const bool ECHO_LOCATOR_DEBUG = false
#endif //DEV

struct lastPingData
{
	entity victim
	float time
}

struct lockFXData
{
	int  fxHandle
	bool initialLock
}

struct weaponCheckData
{
	bool checkPassed
	float totalFireTime
}

struct insideEchoLocatorStateData
{
	int insideState
	int numEnemies
}

struct aiVelocityData
{
	float time
	vector origin
	float speed
}

enum eInsideEchoLocatorState
{
	INSIDE_NONE,
	INSIDE_ALLIED,
	INSIDE_ENEMY,
	_count
}

struct
{
	array<entity> echoLocators
	int echoLocatorRadius
	int echoLocatorRadiusSqr
	int echoLocatorHP
	float echoLocatorSphereModelScale
	bool useWalkSpeedForMovementCheck
	#if CLIENT
	array<entity> playersInsideEchoLocators
	table<entity, int> enemiesInsideEchoLocator
	table<entity, var> echoLocatorRui
	float echoLocatorDuration
	table<entity, aiVelocityData> aiVelocity
	#endif //CLIENT
	#if SERVER
	table<entity, entity> echoLocatorToTriggerMap
	table<entity, array<entity> > echoLocatorsPlayerInside
	table<entity, array<entity> > playerEchoLocatorEnemiesVisited
	#endif //SERVER
} file

/**********************************************************************************************************************
Init Functions
**********************************************************************************************************************/
void function MpWeaponEchoLocator_Init()
{
	COCKPIT_ECHO_LOCATOR_SCREEN_FX = PrecacheParticleSystem( KILL_ROOM_VIEW_FX )
	PrecacheModel( ECHO_LOCATOR_HEART_MODEL )
	PrecacheParticleSystem( ECHO_LOCATOR_VISUAL_FOOT_PING )
	PrecacheParticleSystem( ECHO_LOCATOR_VISUAL_FOOT_PING_AI )
	PrecacheParticleSystem( ECHO_LOCATOR_SCAN_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_DESTRUCTION_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_RADIUS_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_HEART_1P_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_HEART_3P_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_HEART_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_HEART_ENEMY_FX )
	PrecacheParticleSystem( ECHO_LOCATOR_TARGET_ANIMATED )
	PrecacheParticleSystem( ECHO_LOCATOR_TARGET_NON_ANIMATED )
	PrecacheParticleSystem( ECHO_LOCATOR_DRONE_CLUSTER_FX )

	PrecacheModel( DRONE_CLUSTER_MODEL )

	RegisterSignal( "EchoLocator_Exit" )
	RegisterSignal( "EchoLocatorShuttingDown" )
	RegisterNetworkedVariable( ECHO_LOCATOR_PLAYER_HAS_MOVEMENT_INPUT_NETVAR, SNDC_PLAYER_GLOBAL, SNVT_BOOL )

	file.echoLocatorRadius           = GetEchoLocatorRadius()
	file.echoLocatorRadiusSqr        = int( pow( file.echoLocatorRadius, 2 ) )
	file.echoLocatorSphereModelScale = file.echoLocatorRadius / 1050.0 //model was originally setup for 1050 radius, scale the model accordingly
	file.echoLocatorHP 		 = GetEchoLocatorHP()
	file.useWalkSpeedForMovementCheck = GetEchoLocatorUseWalkSpeed()

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.inside_echo_locator, EchoLocator_StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.inside_echo_locator, EchoLocator_StopVisualEffect )
		AddCreateCallback( "script_mover", OnClientEchoLocationChamberCreated )
		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )

		file.echoLocatorDuration = GetWeaponInfoFileKeyField_GlobalFloat( ECHO_LOCATOR_WEAPON_NAME, "fire_duration" )
	#endif //CLIENT

	#if SERVER
		RegisterSignal( "DeployEchoLocator" )
		AddSpawnCallback_ScriptName( ECHO_LOCATOR_SCRIPT_NAME, OnServerEchoLocationChamberCreated )
	#endif //SERVER
}

/**********************************************************************************************************************
Weapon Functions
**********************************************************************************************************************/
var function OnWeaponTossReleaseAnimEvent_WeaponEchoLocator( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable_Retail( weapon, attackParams, 1.0, OnEchoLocatorPlanted, null, <0, 0, 850> )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
		thread ProjectileMonitorForTrohpyZap( deployable )
		deployable.e.isDoorBlocker = true
		deployable.proj.refundAmount = ammoReq

		string projectileSound = GetGrenadeProjectileSound( weapon )
		if ( projectileSound != "" )
			EmitSoundOnEntity( deployable, projectileSound )

		weapon.w.lastProjectileFired = deployable

		TryPlayWeaponBattleChatterLine( player, weapon )
		#endif //SERVER
	}

	return ammoReq
}

void function OnWeaponTossPrep_WeaponEchoLocator( entity weapon, WeaponTossPrepParams prepParams )
{
	//added fx for 1p/3p on hold for heart
	//wait ECHO_LOCATOR_HEART_1P_FX_DELAY
	weapon.PlayWeaponEffect( ECHO_LOCATOR_HEART_1P_FX, ECHO_LOCATOR_HEART_3P_FX, "muzzle_flash" )

	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

void function OnWeaponDeactivate_WeaponEchoLocator( entity weapon )
{
	weapon.StopWeaponEffect( ECHO_LOCATOR_HEART_1P_FX, ECHO_LOCATOR_HEART_3P_FX )
}

/**********************************************************************************************************************
Gameplay Functions
**********************************************************************************************************************/
#if SERVER
//TODO - Travis - build this out into generic system.  Suspect all other legend ults that get zapped by Wattson ult won't immediately start their cooldowns either.
void function ProjectileMonitorForTrohpyZap( entity projectile )
{
	Assert( IsNewThread(), "Must be threaded off" )
	projectile.EndSignal( "OnDeath" )
	projectile.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( projectile, )
		{
			//50 is the cutoff inside of OnProjectileCollision_weapon_deployableInternal where it gives up on finding a deploy position and just destroys the projectile.
			//We want to make sure we only hit this logic if the projetile is under that cap, which means it was destroyed via Wattson ult / something else.
			if ( !projectile.proj.isPlanted && projectile.proj.projectileBounceCount < 50 )
			{
				RestartEchoLocatorCooldown( projectile )
			}
		}
	)

	WaitForever()
}
#endif //SERVER

void function OnEchoLocatorPlanted( entity projectile, DeployableCollisionParams collisionParams )
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

		vector endOrigin = origin - <0,0,32>
		vector surfaceAngles = projectile.proj.savedAngles
		vector oldUpDir = AnglesToUp( surfaceAngles )
		vector finalUpDir

		TraceResults traceResult = TraceLine( origin, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )

		entity oldParent = projectile.GetParent()
		projectile.ClearParent()

		asset model = ECHO_LOCATOR_HEART_MODEL
		float radius = float( file.echoLocatorRadius )
		float duration = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.fire_duration )

		//create as a script mover so that doors will interact with it:
		//-swinging door: pushes it out of the way
		//-sliding door: stops when it hits it
		entity echoLocator = CreateEntity( "script_mover" )
		echoLocator.kv.solid = SOLID_VPHYSICS
		echoLocator.kv.fadedist = -1
		echoLocator.SetValueForModelKey( model )
		echoLocator.e.isDoorBlocker = false
		echoLocator.e.ignoreSafePushMode = true
		echoLocator.SetOrigin( origin )
		echoLocator.SetAngles( surfaceAngles )
		echoLocator.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
		echoLocator.RemoveFromAllRealms()
		echoLocator.AddToOtherEntitysRealms( projectile )
		echoLocator.SetScriptName( ECHO_LOCATOR_SCRIPT_NAME )
		echoLocator.SetBossPlayer( owner )
		projectile.Destroy()
		SetTeam( echoLocator, owner.GetTeam() )
		echoLocator.DisableHibernation()
		echoLocator.SetMaxHealth( file.echoLocatorHP )
		echoLocator.SetHealth( file.echoLocatorHP )
		echoLocator.SetTakeDamageType( DAMAGE_YES )
		echoLocator.SetDamageNotifications( true )
		echoLocator.SetDeathNotifications( true )
		echoLocator.SetBlocksRadiusDamage( false )
		echoLocator.e.noOwnerFriendlyFire = true
		echoLocator.e.noFriendlyFireProtection = false
		echoLocator.e.canBeDamagedFromGas = false
		echoLocator.e.canBurn = true
		echoLocator.SetCanBeMeleed( true )
		echoLocator.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE )
		AddEntityCallback_OnDamaged( echoLocator, OnEchoLocatorDamaged )
		AddEntityCallback_OnPostDamaged( echoLocator, OnEchoLocatorPostDamaged )
		AddEntityCallback_OnKilled( echoLocator, OnEchoLocatorKilled )
		echoLocator.e.preventStickyEnts = true
		//echoLocator.SetDoOnBeingCrushedEntityCallback( true )
		//AddCallback_OnEntityBeingCrushed( echoLocator, ShouldEchoLocatorBeCrushed ) //Avoid being crushed by doors in this callback.

		DispatchSpawn( echoLocator )

		//script_movers can't be used for minimap so need a prop_script one
		entity echoLocatorMinimap = CreatePropScript( EMPTY_MODEL, origin, surfaceAngles )//, SOLID_NONE )
		echoLocatorMinimap.SetParent( echoLocator )
		SetTeam( echoLocatorMinimap, owner.GetTeam() )
		SetTargetName( echoLocatorMinimap, ECHO_LOCATOR_TARGET_NAME )
		echoLocatorMinimap.Minimap_SetObjectScale( radius / SURVIVAL_MINIMAP_RING_SCALE )
		echoLocatorMinimap.Minimap_SetAlignUpright( true )
		echoLocatorMinimap.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
		echoLocatorMinimap.Minimap_SetClampToEdge( true )
		echoLocatorMinimap.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
		SetupMinimapIconForEchoLocator( echoLocatorMinimap, owner.GetTeam(), duration )

		echoLocator.SetTouchTriggers( true ) //Make it destroyable by triggers e.g. Leviathan stomp
		echoLocator.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it
		//echoLocator.DisallowObjectPlacement() //Don't allow Rampart turrets or anything else to be placed on Seer's ult.

		AddEMPDamageDevice( echoLocator )

		AddWreckingBallEMPDamageDevice( echoLocator )

		AddSonarDetectionForPropScript( echoLocator )

		echoLocator.SetOwner( owner )
		AddToUltimateRealm( owner, echoLocator )

		thread PropCheckDamageFromDeathfield( echoLocator, ECHO_LOCATOR_TUNING_DEATHFIELD_DAMAGE_SCALAR )

		if ( IsValid( owner ) )
		{
			thread TrapDestroyOnRoundEnd( owner, echoLocator )
		}

		if ( IsValid( traceResult.hitEnt ) && EntityShouldStick( projectile, traceResult.hitEnt ) && !traceResult.hitEnt.IsWorld() )
		{
			echoLocator.SetParent( traceResult.hitEnt )
		}
		else if ( IsValid( oldParent ) )
		{
			echoLocator.SetParent( oldParent )
		}

		thread DeployEchoLocator_Thread( echoLocator, echoLocatorMinimap, duration )
	#endif //SERVER
}

#if SERVER
bool function ShouldEchoLocatorBeCrushed( entity pusher, entity pushed )
{
	if ( !IsValid( pusher ) || !IsValid( pushed ) )
		return false

	if ( pushed.GetScriptName() == ECHO_LOCATOR_SCRIPT_NAME )
	{
		entity doorEnt = null

		//We don't want doors to crush the ult.
		if ( IsDoor( pusher ) )
		{
			doorEnt = pusher
		}
		else
		{
			//Sometimes it can be the phys_bone_follower doing the crushing.
			entity parentEnt = pusher.GetParent()

			if ( IsValid( parentEnt ) && IsDoor( parentEnt ) )
			{
				doorEnt = parentEnt
			}
		}

		if ( IsValid( doorEnt ) )
		{
			AvoidBeingPutInsideDoorFromCrush( doorEnt, pushed )
			return false
		}
	}

	return true
}

void function OnEchoLocatorDamaged( entity echoLocator, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if ( !IsValid( echoLocator ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( !IsValid( inflictor ) )
		return

	int echoLocatorTeam = echoLocator.GetTeam()
	int attackerTeam    = attacker.GetTeam()

	if ( IsFriendlyTeam( attackerTeam, echoLocatorTeam ) || attacker == echoLocator.GetBossPlayer() )
		return

	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( StatusEffect_HasSeverity( echoLocator, eStatusEffect.ring_immunity ) )
	{
		if ( damageSourceIdentifier == eDamageSourceId.deathField )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}
	}

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	float damage    = DamageInfo_GetDamage( damageInfo )

	if ( damageSourceIdentifier == eDamageSourceId.mp_ability_crypto_drone_emp_trap )
	{
		float damageScale = echoLocator.GetMaxHealth() / damage
		DamageInfo_ScaleDamage( damageInfo, damageScale )
	}

	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_MELEE ) )
		DamageInfo_SetDamage( damageInfo, ( echoLocator.GetMaxHealth() / 2.9 ) )
}

void function OnEchoLocatorPostDamaged( entity echoLocator, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	entity weapon    = DamageInfo_GetWeapon ( damageInfo )

	if ( !IsValid( echoLocator ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( !IsValid( inflictor ) )
		return

	int echoLocatorTeam = echoLocator.GetTeam()
	int attackerTeam    = attacker.GetTeam()

	if ( IsFriendlyTeam( attackerTeam, echoLocatorTeam ) || attacker == echoLocator.GetBossPlayer() )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	float damage    = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	bool echoLocatorDestroyed = (echoLocator.GetHealth() - damage) <= 0

	if ( attacker.IsPlayer() && !IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		if ( echoLocatorDestroyed )
			DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
		else
			DamageInfo_AddCustomDamageType( damageInfo, 1 )


		attacker.NotifyDidDamage( echoLocator, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
		DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
		DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	int maxHealth = echoLocator.GetMaxHealth()
	int health    = echoLocator.GetHealth()

	float newHealth  = max( health - damage, 0.0 )

	if ( echoLocatorDestroyed )
	{
		EmitSoundAtPosition( echoLocator.GetTeam(), echoLocator.GetAttachmentOrigin( echoLocator.LookupAttachment( "HEART_CENTER" ) ), ECHO_LOCATOR_DESTRUCTION_SOUND, echoLocator )
	}

	echoLocator.SetHealth( newHealth )
}

void function OnEchoLocatorKilled( entity echoLocator, var damageInfo )
{
	//in case we were already near the end and someone shoots it in that window, we don't want these sounds to stack.
	StopSoundOnEntity( echoLocator, ECHO_LOCATOR_SPHERE_ENDING )
	EmitSoundOnEntity( echoLocator, ECHO_LOCATOR_SPHERE_ENDING )
	StartParticleEffectInWorld( GetParticleSystemIndex( ECHO_LOCATOR_DESTRUCTION_FX ), echoLocator.GetOrigin(), echoLocator.GetAngles() )

	//start the cooldown now, instead of waiting for the entire fire_duration
	RestartEchoLocatorCooldown( echoLocator )
}

void function RestartEchoLocatorCooldown( entity echoLocator )
{
	//start the cooldown now, instead of waiting for the entire fire_duration
	entity weaponOwner = echoLocator.GetOwner()
	if ( IsValid( weaponOwner ) )
	{
		entity ultimateWeapon = weaponOwner.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( IsValid( ultimateWeapon ) )
		{
			//setting the ammo to 0 will start the weapon refilling again (otherwise it will wait the full fire_duration regardless of if the ult was destroyed early).
			ultimateWeapon.SetWeaponPrimaryClipCount( 0 )
		}
	}
}

void function DeployEchoLocator_Thread( entity echoLocator, entity echoLocatorMinimap, float duration )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDeath" )
	echoLocator.EndSignal( "OnDestroy" )

	entity owner = echoLocator.GetOwner()

	if ( !IsValid( owner ) )
	{
		echoLocator.Destroy()
		return
	}
	int ownerTeam = owner.GetTeam()
	file.playerEchoLocatorEnemiesVisited[owner] <- []

	echoLocator.Anim_PlayOnly( "prop_pariah_heart_deploy" )
	WaittillAnimDone( echoLocator )

	thread EchoLocatorIdleAnims_Thread( echoLocator )

	owner.Signal( "DeployEchoLocator" )
	owner.EndSignal( "SquadEliminated" )

	entity wp = null

	//R5DEV-280617 - Owner becoming invalidated somehow, guarding against that (wp needs a player owner)
	if ( IsValid( owner ) )
	{
		//wp = CreateWaypoint_Ping_Location( owner, ePingType.ABILITY_ECHO_LOCATOR, echoLocator, echoLocator.GetOrigin() + <0, 0, 20>, -1, false )
		//wp.SetAbsOrigin( echoLocator.GetOrigin() + <0, 0, 20> )
		//wp.SetParent( echoLocator )
	}

	OnThreadEnd(
		function() : ( owner, echoLocator, echoLocatorMinimap)//, wp )
		{
			//if ( IsValid( wp ) )
				//wp.Destroy()

			if ( owner in file.playerEchoLocatorEnemiesVisited )
			{
				int numEnemiesVisited = file.playerEchoLocatorEnemiesVisited[owner].len()
				delete file.playerEchoLocatorEnemiesVisited[owner]
			}

			if ( IsValid( echoLocator ) )
			{
				thread ProjectileShutdown_Thread( echoLocator )
			}
			if ( IsValid( echoLocatorMinimap ) )
			{
				echoLocatorMinimap.Destroy()
			}
		}
	)

	thread TrapDestroyOnRoundEnd( owner, echoLocator )

	thread CreateDroneCluster_Thread( owner, ownerTeam, echoLocator, duration )

	entity heartAlliedVFX = StartParticleEffectOnEntity_ReturnEntity ( echoLocator, GetParticleSystemIndex( ECHO_LOCATOR_HEART_FX ), FX_PATTACH_POINT_FOLLOW, echoLocator.LookupAttachment( "HEART_CENTER" ) )
	SetTeam( heartAlliedVFX, ownerTeam )
	heartAlliedVFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )

	entity heartEnemyVFX = StartParticleEffectOnEntity_ReturnEntity ( echoLocator, GetParticleSystemIndex( ECHO_LOCATOR_HEART_ENEMY_FX ), FX_PATTACH_POINT_FOLLOW, echoLocator.LookupAttachment( "HEART_CENTER" ) )
	SetTeam( heartEnemyVFX, ownerTeam )
	heartEnemyVFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_ENEMY )

	entity clusterVFX = StartParticleEffectOnEntity_ReturnEntity ( echoLocator, GetParticleSystemIndex( ECHO_LOCATOR_DRONE_CLUSTER_FX ), FX_PATTACH_POINT_FOLLOW, echoLocator.LookupAttachment( "ref" ) )

	wait ECHO_LOCATOR_DEPLOY_DELAY

	thread CreateEchoLocatorTrigger_Thread( echoLocator, duration, ownerTeam )

	EntFireByHandle( heartAlliedVFX, "Kill", "", duration, null, null )
	EntFireByHandle( heartEnemyVFX, "Kill", "", duration, null, null )
	EntFireByHandle( clusterVFX, "Kill", "", duration, null, null )

	wait duration
}

void function CreateDroneCluster_Thread( entity owner, int ownerTeam, entity echoLocator, float duration )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDestroy" )

	entity droneClusterAllied = CreatePropScript( DRONE_CLUSTER_MODEL, echoLocator.GetOrigin(), echoLocator.GetAngles(), -1 )
	entity droneClusterEnemies = CreatePropScript( DRONE_CLUSTER_MODEL, echoLocator.GetOrigin(), echoLocator.GetAngles(), -1 )

	droneClusterAllied.SetModelScale( file.echoLocatorSphereModelScale )
	droneClusterEnemies.SetModelScale( file.echoLocatorSphereModelScale )

	#if DEVELOPER
	if ( ECHO_LOCATOR_DEBUG )
	{
		DebugDrawSphere( echoLocator.GetOrigin(), file.echoLocatorRadius, COLOR_RED, true, duration )
	}
	#endif //DEV

	SetTeam( droneClusterAllied, ownerTeam )
	SetTeam( droneClusterEnemies, ownerTeam )

	droneClusterAllied.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )
	droneClusterEnemies.SetVisibilityFlags( ENTITY_VISIBLE_TO_ENEMY )

	droneClusterAllied.SetParent( echoLocator )
	droneClusterEnemies.SetParent( echoLocator )

	thread DoDroneClusterAnims_Thread( owner, ownerTeam, echoLocator, droneClusterAllied, duration, true )
	thread DoDroneClusterAnims_Thread( owner, ownerTeam, echoLocator, droneClusterEnemies, duration, false )

}

void function DoDroneClusterAnims_Thread( entity owner, int ownerTeam, entity echoLocator, entity droneCluster, float duration, bool allied )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDestroy" )
	echoLocator.EndSignal( "EchoLocatorShuttingDown" )
	droneCluster.EndSignal( "OnDestroy" )

	AddToUltimateRealm( owner, droneCluster )

	float initialAnimTime = duration * INITIAL_IDLE_ANIMATION_PERCENTAGE
	float remainingAnimTime = duration - initialAnimTime

	OnThreadEnd(
		function() : ( droneCluster )
		{
			if ( IsValid( droneCluster ) )
			{
				//put the ending anims in a thread here so that no matter what (echoLocator is shot, or times out or whatever) we always play the correct ending anims for the droneCluster
				thread DoDroneClusterEndingAnims_Thread( droneCluster )
			}
		}
	)

	droneCluster.Anim_PlayOnly( "prop_pariah_drone_cluster_ult_start" )
	WaittillAnimDone( droneCluster )

	string idleAnim = allied ? "prop_pariah_drone_cluster_ult_idle" : "prop_pariah_drone_cluster_ult_idle_enemy"
	droneCluster.Anim_PlayOnly( idleAnim )

	wait initialAnimTime

	droneCluster.Anim_PlayOnly( "prop_pariah_drone_cluster_ult_vibrate" )

	wait remainingAnimTime
}

void function DoDroneClusterEndingAnims_Thread( entity droneCluster )
{
	Assert( IsNewThread(), "Must be threaded off" )
	droneCluster.EndSignal( "OnDestroy" )

	droneCluster.Anim_PlayOnly( "prop_pariah_drone_cluster_ult_end" )
	WaittillAnimDone( droneCluster )
	droneCluster.Destroy()
}


void function SetupMinimapIconForEchoLocator( entity echoLocator, int team, float duration )
{
	foreach( entity player in GetPlayerArray_AliveConnected() )
	{
		bool isFriendly = IsFriendlyTeam( player.GetTeam(), team )
		if ( !isFriendly )
		{
			echoLocator.Minimap_Hide( player.GetTeam(), null )
		}
	}

	echoLocator.Minimap_AlwaysShow( team, null )

	// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
	//AllianceProximity_SetMinimapAlwaysShow_ForAlliance( team, echoLocator, echoLocator.GetOwner() )
}

void function EchoLocatorIdleAnims_Thread( entity projectile )
{
	Assert( IsNewThread(), "Must be threaded off" )
	projectile.EndSignal( "OnDestroy" )

	projectile.Anim_PlayOnly( "prop_pariah_heart_deploy_trans" )
	WaittillAnimDone( projectile )
	projectile.Anim_PlayOnly( "prop_pariah_heart_deploy_idle" )
}

void function ProjectileShutdown_Thread( entity echoLocator )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDestroy" )

	echoLocator.Signal( "EchoLocatorShuttingDown" )

	echoLocator.Anim_PlayOnly( "prop_pariah_heart_shutdown" )
	WaittillAnimDone( echoLocator )
	echoLocator.Dissolve( ENTITY_DISSOLVE_CORE, <0, 0, 0>, 500 )
	WaitSignal( echoLocator, "OnDestroy" )
}

void function EchoLocatorTriggerEnter( entity trigger, entity ent )
{
	if ( !ent.DoesShareRealms( trigger ) )
		return

	if( !IsAlive( ent ) )
		return

	thread EchoLocatorTriggerTouching_Thread( trigger, ent )
}

void function EchoLocatorTriggerTouching_Thread( entity trigger, entity ent )
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( trigger, "OnDestroy" )
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "OnDeath" )

	#if DEVELOPER
	string playerName = ent.IsPlayer() ? ent.GetPlayerName() : "DECOY"

	if ( ECHO_LOCATOR_DEBUG )
	{
		printt("EchoLocatorTriggerTouching_Thread started for: " + playerName )
	}
	#endif //DEV

	bool isTrainingDummie = IsTrainingDummie( ent )
	bool isCombatNPC = IsCombatNPC( ent )

	if ( !IsValid( ent ) )
		return

	if ( !ent.IsPlayer() && !ent.IsPlayerDecoy() && !isTrainingDummie && !isCombatNPC )
		return

	if ( !ent.DoesShareRealms( trigger ) )
		return

	entity projectile = trigger.GetOwner()
	entity owner = projectile.GetOwner()

	bool isFriendly = IsFriendlyTeam( ent.GetTeam(), trigger.GetTeam() )

	if ( ent.IsPlayer() && !isFriendly )
	{
		if ( owner in file.playerEchoLocatorEnemiesVisited )
		{
			if ( !file.playerEchoLocatorEnemiesVisited[owner].contains( ent ) )
			{
				file.playerEchoLocatorEnemiesVisited[owner].append( ent )
			}
		}
	}

	OnThreadEnd(
		function() : ( ent, trigger )
		{
			if ( IsValid( ent ) )
			{
				#if DEVELOPER
				string playerName = ent.IsPlayer() ? ent.GetPlayerName() : "DECOY"
				if ( ECHO_LOCATOR_DEBUG )
				{
					printt("EchoLocatorTriggerTouching_Thread ended for: " + playerName + " trigger: " + trigger.GetEntIndex())
				}
				#endif //DEV

				if ( file.echoLocatorsPlayerInside[ent].contains( trigger ) )
				{
					#if DEVELOPER
						if ( ECHO_LOCATOR_DEBUG )
						{
							printt( "Removing trigger from file.echoLocatorsPlayerInside for " + playerName + " triggerID: " + trigger.GetEntIndex() )
						}
					#endif //DEV
					file.echoLocatorsPlayerInside[ent].fastremovebyvalue( trigger )
				}

				if ( file.echoLocatorsPlayerInside[ent].len() == 0 )
				{
					if ( StatusEffect_GetTimeRemaining( ent, eStatusEffect.inside_echo_locator ) > 0 )
					{
						#if DEVELOPER
						if ( ECHO_LOCATOR_DEBUG )
						{
							printt("Last echo locator, removing status effect thread end for " + playerName)
						}
						#endif //DEV
						StatusEffect_StopAllOfType( ent, eStatusEffect.inside_echo_locator )
						ent.Signal( "EchoLocator_Exit" )
					}
				}

				if ( ent.IsPlayer() )
				{
					ent.SetPlayerNetBool( ECHO_LOCATOR_PLAYER_HAS_MOVEMENT_INPUT_NETVAR, false )
				}
			}
		}
	)

	if ( !( ent in file.echoLocatorsPlayerInside ) )
	{
		array<entity> echoLocators
		file.echoLocatorsPlayerInside[ent] <- echoLocators
	}

	while( trigger.IsTouching( ent ) )
	{
		if ( !IsValid( ent ) )
		{
			return
		}

		float distanceSqr = DistanceSqr( trigger.GetOrigin(), ent.GetOrigin() )

		if ( distanceSqr < file.echoLocatorRadiusSqr )
		{
			if ( StatusEffect_GetTimeRemaining( ent, eStatusEffect.inside_echo_locator ) == 0 )
			{
				#if DEVELOPER
					if ( ECHO_LOCATOR_DEBUG )
					{
						printt( "Adding eStatusEffect.inside_echo_locator" )
					}
				#endif //DEV
				StatusEffect_AddEndless( ent, eStatusEffect.inside_echo_locator, 1.0 )
			}
			if ( !file.echoLocatorsPlayerInside[ent].contains( trigger ) )
			{
				#if DEVELOPER
				if ( ECHO_LOCATOR_DEBUG )
				{
					printt( "Adding trigger to file.echoLocatorsPlayerInside for " + playerName + " triggerID: " + trigger.GetEntIndex() )
				}
				#endif //DEV

				file.echoLocatorsPlayerInside[ent].append( trigger )

				if ( !isFriendly && !ent.IsPlayerDecoy() && !isTrainingDummie && !isCombatNPC )
				{
					if ( IsValid( projectile ) )
					{
						projectile.Minimap_AlwaysShow( 0, ent )
					}
				}
			}

			if ( ent.IsPlayer() )
			{
				bool doesPlayerHaveMovementInput = (ent.GetInputAxisForward() != 0 || ent.GetInputAxisRight() != 0)
				ent.SetPlayerNetBool( ECHO_LOCATOR_PLAYER_HAS_MOVEMENT_INPUT_NETVAR, doesPlayerHaveMovementInput )
			}
		}

		else
		{
			if ( !isFriendly && !ent.IsPlayerDecoy() && !isTrainingDummie && !isCombatNPC )
			{
				if ( IsValid( projectile ) )
				{
					projectile.Minimap_Hide( 0, ent )
				}
			}

			if ( ent in file.echoLocatorsPlayerInside )
			{
				if ( file.echoLocatorsPlayerInside[ent].contains( trigger ) )
				{
					#if DEVELOPER
					if ( ECHO_LOCATOR_DEBUG )
					{
						printt( "Removing trigger from file.echoLocatorsPlayerInside for " + playerName + " triggerID: " + trigger.GetEntIndex() )
					}
					#endif //DEV
					file.echoLocatorsPlayerInside[ent].fastremovebyvalue( trigger )
				}
			}

			if ( file.echoLocatorsPlayerInside[ent].len() == 0 )
			{
				if ( StatusEffect_GetTimeRemaining( ent, eStatusEffect.inside_echo_locator ) > 0 )
				{

					#if DEVELOPER
					if ( ECHO_LOCATOR_DEBUG )
					{
						printt( "Last Echo Locator Trigger detected Ent outside of sphere radius - removing eStatusEffect.inside_echo_locator" )
					}
					#endif //DEV
					StatusEffect_StopAllOfType( ent, eStatusEffect.inside_echo_locator )
					ent.Signal( "EchoLocator_Exit" )
				}
			}

			if ( ent.IsPlayer() )
			{
				ent.SetPlayerNetBool( ECHO_LOCATOR_PLAYER_HAS_MOVEMENT_INPUT_NETVAR, false )
			}
		}

		wait TICK_RATE
	}

}
#endif //SERVER
/**********************************************************************************************************************
Helper Functions
**********************************************************************************************************************/
#if SERVER
void function CreateEchoLocatorTrigger_Thread( entity projectile, float duration, int team )
{
	Assert( IsNewThread(), "Must be threaded off" )
	projectile.EndSignal( "OnDestroy" )

	vector origin = projectile.GetOrigin()
	//Kill room is a sphere (trigger is a cylinder)
	int radius = file.echoLocatorRadius
	int aboveHeight = radius
	int belowHeight = radius

	entity trigger = CreateTriggerCylinderNoCylinderRadius( origin, radius, aboveHeight, belowHeight )
	trigger.RemoveFromAllRealms()
	trigger.SetRadius(radius)
	trigger.AddToOtherEntitysRealms( projectile )
	trigger.SetOwner( projectile )
	trigger.SetParent( projectile )
	SetTeam( trigger, team )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 1

	trigger.SetEnterCallback( EchoLocatorTriggerEnter )
	trigger.SearchForNewTouchingEntity()  // set this to catch an entity in the trigger right away

	file.echoLocatorToTriggerMap[projectile] <- trigger


	EndSignal( trigger, "OnDestroy" )

	OnThreadEnd(
		function () : ( projectile, trigger )
		{
			if ( projectile in file.echoLocatorToTriggerMap )
			{
				delete file.echoLocatorToTriggerMap[projectile]
			}

			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)

	wait duration
}
#endif //SERVER

#if SERVER
void function OnServerEchoLocationChamberCreated( entity echoLocator )
{
	file.echoLocators.append( echoLocator )

	thread EchoLocationChamberMonitor_Thread( echoLocator )
}
#endif //SERVER

void function EchoLocationChamberMonitor_Thread( entity echoLocator )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDestroy" )
	echoLocator.EndSignal( "OnDeath" )

	OnThreadEnd(
		function () : ( echoLocator )
		{
			if ( file.echoLocators.contains( echoLocator ) )
			{
				file.echoLocators.removebyvalue( echoLocator )
			}
		}
	)

	WaitForever()
}

#if CLIENT
void function OnClientEchoLocationChamberCreated( entity echoLocator )
{
	if ( echoLocator.GetScriptName() != ECHO_LOCATOR_SCRIPT_NAME )
		return

	thread ClientEchoLocatorManager_Thread( echoLocator )
}

void function OnWaypointCreated( entity wp )
{
	int wpType = wp.GetWaypointType()
	entity localViewPlayer = GetLocalViewPlayer()
}

void function UpdateWayPointEnemyCount_Thread( entity waypoint )
{
	Assert( IsNewThread(), "Must be threaded off" )
	waypoint.EndSignal( "OnDestroy" )


	entity echoLocator = GetPingedEntForLocWaypoint( waypoint )

	while ( true )
	{
		if ( IsValid( waypoint.wp.ruiHud ) )
		{
			int enemiesInside = 0

			if ( IsValid( echoLocator ) )
			{
				enemiesInside = GetEnemyCountInsideEchoLocator( echoLocator )

				entity localViewPlayer = GetLocalViewPlayer()
				if ( IsValid( localViewPlayer ) )
				{
					if ( IsFriendlyTeam( localViewPlayer.GetTeam(), echoLocator.GetTeam() ) || echoLocator.GetBossPlayer() == localViewPlayer )
					{
						if ( IsPlayerInsideEchoLocator( localViewPlayer, echoLocator ) )
						{
							RuiSetBool( waypoint.wp.ruiHud, "isHidden", true )
						}
						else
						{
							RuiSetBool( waypoint.wp.ruiHud, "isHidden", false )
						}
					}
				}

				string messageText 		= enemiesInside == 1 ? "#WPN_ECHO_LOCATOR_SINGLE_ENEMY_HINT" : "#WPN_ECHO_LOCATOR_HINT"
				string messageTextShort 	= enemiesInside == 1 ? "#WPN_ECHO_LOCATOR_SINGLE_ENEMY_HINT_SHORT" : "#WPN_ECHO_LOCATOR_HINT_SHORT"
				string prompt      		= string( enemiesInside ) + " " + Localize( messageText )
				string promptShort      	= string( enemiesInside ) + " " + Localize( messageTextShort )
				RuiSetString( waypoint.wp.ruiHud, "pingPrompt", prompt )
				RuiSetString( waypoint.wp.ruiHud, "pingPromptForOwner", prompt )
				RuiSetString( waypoint.wp.ruiHud, "additionalInfoText", promptShort )
			}
		}

		WaitFrame()
	}
}

void function ClientEchoLocatorManager_Thread( entity echoLocator )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDeath" )
	echoLocator.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( echoLocator )
		{
			delete file.enemiesInsideEchoLocator[echoLocator]
		}
	)

	//TODO - Tnordin - Do we need this check?  Does a client get this callback once per dome or do all clients get it for each client?  Investigate and adjust as needed.
	if ( !file.echoLocators.contains( echoLocator ) )
	{
		file.echoLocators.append( echoLocator )
		file.enemiesInsideEchoLocator[echoLocator] <- 0

		//shared threads for all echo locators
		thread EchoLocationChamberMonitor_Thread( echoLocator )
		thread EchoLocatorAmbientSound_Thread( echoLocator )

		wait ECHO_LOCATOR_DEPLOY_CLIENT_DELAY

		//IsFriendlyTeam returns false when friendly fire is enabled inside of firing range.  However the Seer that the ult belongs to should still get to have the ult work for him.
		if ( IsFriendlyTeam( echoLocator.GetTeam(), GetLocalViewPlayer().GetTeam() ) || echoLocator.GetBossPlayer() == GetLocalViewPlayer() )
		{
			//only allies need to see the footstep VFX or UI
			thread EchoLocatorFootstepVFX_Thread( echoLocator )
			thread EchoLocatorRUI_Thread( echoLocator )
		}
	}

	wait file.echoLocatorDuration
}

void function EchoLocatorAmbientSound_Thread( entity echoLocator )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDeath" )
	echoLocator.EndSignal( "OnDestroy" )

	vector echoLocatorCenter = echoLocator.GetOrigin()

	EmitSoundAtPosition( TEAM_ANY, echoLocator.GetOrigin(), ECHO_LOCATOR_AMBIENT_LOOP_START )

	float deployAnimDuration = echoLocator.GetSequenceDuration( "prop_pariah_heart_deploy" )
	wait deployAnimDuration

	echoLocatorCenter = echoLocator.GetAttachmentOrigin( echoLocator.LookupAttachment( "HEART_CENTER" ) )

	var ambientLoop = EmitSoundAtPosition( TEAM_ANY, echoLocator.GetOrigin(), ECHO_LOCATOR_AMBIENT_LOOP )
	EmitSoundOnEntity( echoLocator, ECHO_LOCATOR_AMBIENT_SOUND )

	float endTime = Time() + file.echoLocatorDuration
	float initialAnimTime = file.echoLocatorDuration * INITIAL_IDLE_ANIMATION_PERCENTAGE
	float loopEndingTime = Time() + initialAnimTime
	bool playingLoopEndingSound = false

	OnThreadEnd(
		function() : ( echoLocator, ambientLoop, echoLocatorCenter, loopEndingTime )
		{
			StopSoundOnEntity( echoLocator, ECHO_LOCATOR_AMBIENT_SOUND )

			//EmitSoundAtPosition in code will check the localViewPlayer's team for playback and assert if invalid.  Guard against this case.
			if ( IsValid( GetLocalViewPlayer() ) )
			{
				//if we're over loopEndingTime then the while loop below would have already started playing this sound.
				//if not, then someone has killed it early and we need to play it.
				if ( Time() < loopEndingTime )
				{
					EmitSoundAtPosition( TEAM_ANY, echoLocator.GetOrigin(), ECHO_LOCATOR_AMBIENT_LOOP_ENDING )
					EmitSoundAtPosition( TEAM_ANY, echoLocatorCenter, ECHO_LOCATOR_SPHERE_ENDING )
				}
			}

			StopSound( ambientLoop )
		}
	)

	while ( Time() < endTime )
	{
		//echo locator will be playing prop_pariah_heart_shutdown when shutting down.  EchoLocatorShuttingDown signal isn't transmitted from server to client, so ending thread this way on client.
		if ( echoLocator.GetCurrentSequenceName() == $"animseq/props/pariah_heart/pariah_heart/prop_pariah_heart_shutdown.rseq" )
			break

		if ( ( Time() > loopEndingTime ) && ( !playingLoopEndingSound ) )
		{
			playingLoopEndingSound = true
			EmitSoundAtPosition( TEAM_ANY, echoLocator.GetOrigin(), ECHO_LOCATOR_AMBIENT_LOOP_ENDING )
			EmitSoundOnEntity( echoLocator, ECHO_LOCATOR_SPHERE_ENDING )
		}

		WaitFrame()
	}
}


void function EchoLocatorRUI_Thread( entity echoLocator )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDeath" )
	echoLocator.EndSignal( "OnDestroy" )

	entity localViewPlayer = GetLocalViewPlayer()

	localViewPlayer.EndSignal( "OnDeath" )
	localViewPlayer.EndSignal( "OnDestroy" )

	int lastEnemyCount = -1
	float endTime = Time() + file.echoLocatorDuration
	return

	var rui = CreateCockpitRui( $"ui/echo_locator.rpak" )
	file.echoLocatorRui[echoLocator] <- rui

	int attachment = echoLocator.LookupAttachment( "ref" )
	RuiTrackFloat3( rui, "pos", echoLocator, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiTrackFloat( rui, "bleedoutEndTime", localViewPlayer, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
	RuiTrackFloat( rui, "reviveEndTime", localViewPlayer, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )

	OnThreadEnd(
		function () : ( echoLocator )
		{
			if ( echoLocator in file.echoLocatorRui )
			{
				if ( file.echoLocatorRui[echoLocator] != null )
				{
					RuiDestroy( file.echoLocatorRui[echoLocator] )
					delete file.echoLocatorRui[echoLocator]
				}
			}
		}
	)

	while ( Time() < endTime )
	{
		int currentEnemyCount = file.enemiesInsideEchoLocator[echoLocator]
		bool insideEchoLocator = IsPlayerInsideEchoLocator( localViewPlayer, echoLocator )
		bool subtitlesEnabled = GetConVarBool( "closecaption" )
		int ccSize = GetConVarInt( "cc_text_size" )
		UISize screenSize = GetScreenSize()

		RuiSetBool( file.echoLocatorRui[echoLocator], "insideEchoLocator", insideEchoLocator )

		if ( lastEnemyCount != currentEnemyCount )
		{
			RuiSetInt( file.echoLocatorRui[echoLocator], "enemiesInside", currentEnemyCount )
			lastEnemyCount = currentEnemyCount
		}

		if ( PlayerHasPassive( localViewPlayer, ePassives.PAS_PARIAH ) )
		{
			RuiSetBool( file.echoLocatorRui[echoLocator], "playerIsSeer", true )
		}
		else
		{
			RuiSetBool( file.echoLocatorRui[echoLocator], "playerIsSeer", false )
		}

		RuiSetBool( file.echoLocatorRui[echoLocator], "closecaptionEnabled", subtitlesEnabled )
		RuiSetInt( file.echoLocatorRui[echoLocator], "closeCaptionSize", ccSize )

		RuiSetFloat2( file.echoLocatorRui[echoLocator], "screenSize", <screenSize.width, screenSize.height, 0> )

		wait TICK_RATE
	}
}


int function GetEnemyCountInsideEchoLocator( entity echoLocator )
{
	if ( echoLocator in file.enemiesInsideEchoLocator )
	{
		return file.enemiesInsideEchoLocator[echoLocator]
	}

	return 0
}

insideEchoLocatorStateData function GetPlayerInsideEchoLocatorState( entity player )
{
	insideEchoLocatorStateData data
	data.insideState = eInsideEchoLocatorState.INSIDE_NONE
	data.numEnemies = 0
	int maxEnemies = 0

	foreach ( entity echoLocator in file.echoLocators )
	{
		if ( IsPlayerInsideEchoLocator( player, echoLocator ) )
		{
			if ( !IsFriendlyTeam( echoLocator.GetTeam(), player.GetTeam() )  && echoLocator.GetBossPlayer() != player )
			{
				data.insideState = eInsideEchoLocatorState.INSIDE_ENEMY
				data.numEnemies = 0
				return data
			}

			data.insideState = eInsideEchoLocatorState.INSIDE_ALLIED
			maxEnemies = maxint( maxEnemies, GetEnemyCountInsideEchoLocator( echoLocator ) )
		}
	}

	data.numEnemies = maxEnemies
	return data
}
#endif //CLIENT

bool function IsPlayerInsideAlliedEchoLocator( entity localViewPlayer, entity player, int friendlyTeam )
{
	foreach ( entity echoLocator in file.echoLocators )
	{
		if ( IsPlayerInsideEchoLocator( player, echoLocator ) )
		{
			//inside a friendly echo locator
			if ( IsFriendlyTeam( echoLocator.GetTeam(), friendlyTeam ) || echoLocator.GetBossPlayer() == localViewPlayer )
			{
				return true
			}
		}
	}

	return false
}

bool function IsPlayerInsideEchoLocator( entity player, entity echoLocator )
{





	float distance = Distance( player.EyePosition(), echoLocator.GetOrigin() )

	return distance <= file.echoLocatorRadius
}

#if CLIENT
float function GetPlayerSpeedForEchoLocator( entity player )
{
	float playerSpeed = 0.0

	vector playerVelocity = GetIsolatedPlayerVelocityFromGround( player )

	if ( player.IsPlayerDecoy() )
	{
		playerSpeed = Length( playerVelocity )
	}
	else if ( IsTrainingDummie( player ) || player.IsNPC() )
	{
		if ( player in file.aiVelocity )
		{
			playerSpeed = file.aiVelocity[player].speed
		}
	}
	else
	{
		//player is sliding, we want to get their velocity regardless of player input since they could be sliding down a hill (no input required)
		if ( player.IsSliding() )
		{
			playerSpeed = Length( playerVelocity )
		}
		else
		{
			//player isn't actively pressing any input movements so we just return 0 as their GetVelocity() could return some BaseVelocity from a mover (WE train, etc)
			bool playerMovementInput = player.GetPlayerNetBool( ECHO_LOCATOR_PLAYER_HAS_MOVEMENT_INPUT_NETVAR )

			if ( !playerMovementInput )
			{
				playerSpeed = 0
			}
			else
			{
				playerSpeed = Length( player.GetVelocity() )
			}
		}
	}

	return playerSpeed
}

vector function GetIsolatedPlayerVelocityFromGround( entity player )
{
	vector playerVelocity = player.GetVelocity()
	entity groundEnt = player.GetGroundEntity()

	if ( IsValid( groundEnt ) )
	{
		//this isn't perfect, but at least try and subtract the ground ent velocity from the players to get an approximate value for their movement velocity since we don't network BaseVelocity to all clients.
		playerVelocity -= groundEnt.GetVelocity()
	}

	return playerVelocity
}

bool function GetIsPlayerOnGroundForEchoLocator( entity player )
{
	bool isOnGround = true
	{
		isOnGround = player.IsOnGround()
	}

	//IsOnGround is unreliable when player is bunny hopping.  Trace down to verify not on ground.
	if ( !isOnGround )
	{
		TraceResults traceResult = TraceLine( player.GetOrigin() + ( player.GetUpVector() * 2 ), player.GetOrigin() - ( player.GetUpVector() * 5 ), [ player ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )
		isOnGround = ( traceResult.fraction < 0.99 )
	}

	return isOnGround
}

bool function DoesPlayerPassEchoLocatorMovementCheck( entity player, float playerSpeed )
{
	//speed check
	if ( playerSpeed > 0 )
	{
		if ( file.useWalkSpeedForMovementCheck )
		{
			bool isADS = false

			if ( player.IsPlayer() )
				isADS = PlayerIsInADS( player )
			else if ( player.IsPlayerDecoy() )
			{
				if ( player.GetScriptName() == CONTROLLED_DECOY_SCRIPTNAME)
				{
					entity owner = player.GetOwner()

					if ( IsValid( owner ) )
					{
						isADS = PlayerIsInADS( owner )
					}
				}
			}

			if ( playerSpeed >= ECHO_LOCATOR_MOVEMENT_SPEED_CHECK && !isADS )
			{
				return true
			}
		}
		else
		{
			bool isTrainingDummie = IsTrainingDummie( player )

			if ( isTrainingDummie || player.IsNPC() )
			{
				if ( isTrainingDummie )
				{
					if ( playerSpeed >= ECHO_LOCATOR_DUMMIE_SPEED_CHECK )
						return true
					else
						return false

				}
				else
					return true
			}
			else
			{
				//actual crouch check
				//TODO - Travis - Investigate why IsSliding is returning false for client ents?
				if ( !player.IsCrouched() || player.IsSliding() )
				{
					return true
				}
			}
		}
	}

	return false
}

weaponCheckData function DoesPlayerPassEchoLocatorWeaponDischargeCheck( entity player )
{
	weaponCheckData result
	result.checkPassed = false
	result.totalFireTime = 0.0

	if ( player.IsPlayer() )
	{
		entity weapon     = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( IsValid( weapon ) )
		{
			float rechamberDuration = weapon.GetWeaponSettingFloat( eWeaponVar.rechamber_time )
			float fireRate = weapon.GetWeaponSettingFloat( eWeaponVar.fire_rate )

			float fireCooldown = fireRate > 0.0 ? 1.0 / fireRate : 0.0
			float totalFireTime = rechamberDuration + fireCooldown

			float lastFireTimeWeapon = player.GetLastFiredTime()
			float fireTimeDelta = Time() - lastFireTimeWeapon

			float checkTime = max( totalFireTime, WEAPON_FIRE_FX_MIN_WAIT_TIME )

			result.checkPassed = fireTimeDelta < checkTime
			result.totalFireTime = totalFireTime
		}
	}
	else if ( IsTrainingDummie( player ) )
	{
		entity weapon     = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( IsValid( weapon ) )
		{
			float rechamberDuration = weapon.GetWeaponSettingFloat( eWeaponVar.rechamber_time )
			float fireCooldown      = 1.0 / weapon.GetWeaponSettingFloat( eWeaponVar.fire_rate )
			float totalFireTime = rechamberDuration + fireCooldown

			int weaponActivity = weapon.GetWeaponActivity()
			//In my testing all dummies used ACT_RANGE_ATTACK_SMG1 for their attacks but figured I'd try and cover the range here to be safe.
			if ( ( weaponActivity >= ACT_RANGE_ATTACK1 ) && ( weaponActivity <= ACT_RANGE_ATTACK_SMG1 ) )
			{
				result.checkPassed = true
			}
			else
			{
				result.checkPassed = false
			}

			result.totalFireTime = totalFireTime
		}
	}

	return result
}

/**********************************************************************************************************************
VFX Functions
**********************************************************************************************************************/
void function EchoLocator_StartVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !file.playersInsideEchoLocators.contains( ent ) )
	{
		file.playersInsideEchoLocators.append( ent )
	}

	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	EmitSoundOnEntity( ent, ECHO_LOCATOR_THRESHOLD_SOUND )

	entity viewPlayer = GetLocalViewPlayer()

	int fxHandle = StartParticleEffectOnEntityWithPos( viewPlayer, COCKPIT_ECHO_LOCATOR_SCREEN_FX, FX_PATTACH_ABSORIGIN_FOLLOW, -1, viewPlayer.EyePosition(), <0,0,0> )
	EffectSetIsWithCockpit( fxHandle, true )

	thread EchoLocator_UpdateIntensity_Thread( viewPlayer, fxHandle )
	thread EchoLocatorScreenFXThink( viewPlayer, fxHandle )
}

void function EchoLocatorFootstepVFX_Thread( entity echoLocator )
{
	Assert( IsNewThread(), "Must be threaded off" )
	echoLocator.EndSignal( "OnDeath" )
	echoLocator.EndSignal( "OnDestroy" )

	table<entity, float> lastPingTimeForLoco
	table<entity, float> lastPingTimeForWeapon
	table<entity, bool> wasInAir

	table<entity, lockFXData> lockFXID
	table<entity, var> minimapMarkerRui
	array<entity> dummiesAddedToInsideEchoLocatorList

	float endTime = Time() + file.echoLocatorDuration

	OnThreadEnd(
		function () : ( echoLocator, lockFXID, minimapMarkerRui, dummiesAddedToInsideEchoLocatorList )
		{
			foreach ( entity ent, lockFXData data in lockFXID )
			{
				if ( EffectDoesExist( data.fxHandle ) )
				{
					EffectStop( data.fxHandle, false, true )
				}
			}

			foreach ( entity ent, var minimapRui in minimapMarkerRui )
			{
				if ( minimapRui != null )
				{
					Minimap_CommonCleanup( minimapRui )
				}
			}

			file.aiVelocity.clear()
		}
	)

	bool firstLoopIteration = true

	while ( true )
	{
		bool echoLocatorOwner = GetLocalViewPlayer() == echoLocator.GetBossPlayer()

		if ( file.echoLocators.len() == 0 )
		{
			return
		}

		if ( Time() > endTime )
		{
			return
		}

		array<entity> validTouchingEnts

		foreach ( entity ent in file.playersInsideEchoLocators )
		{
			if ( !IsValid( ent ) )
			{
				continue
			}

			bool isCombatNPC = IsCombatNPC( ent )

			if ( !ent.IsPlayer() && !ent.IsPlayerDecoy() && !IsTrainingDummie( ent ) && !isCombatNPC )
			{
				continue
			}

			if ( isCombatNPC )
			{
				if ( !( ent in file.aiVelocity ) )
				{
					aiVelocityData data
					data.time                  = Time()
					data.origin                = ent.GetOrigin()
					data.speed                 = 0
					file.aiVelocity[ent] <- data
				}
			}

			if ( ent.IsPhaseShifted() )
			{
				continue
			}

			if ( IsFriendlyTeam( ent.GetTeam(), GetLocalViewPlayer().GetTeam() ) || ( ent == echoLocator.GetBossPlayer() ) )
			{
				continue
			}

			//is this player inside an echo locator that is allied to me (if so, then we want to show the visuals for them inside of it)
			if ( IsPlayerInsideAlliedEchoLocator( GetLocalViewPlayer(), ent, GetLocalViewPlayer().GetTeam() ) )
			{
				validTouchingEnts.append( ent )

				if ( !( ent in lastPingTimeForLoco ) )
				{
					lastPingTimeForLoco[ent] <- 0.0
				}

				if ( !( ent in lastPingTimeForWeapon ) )
				{
					lastPingTimeForWeapon[ent] <- 0.0
				}

				if ( !( ent in wasInAir ) )
				{
					wasInAir[ent] <- false
				}

				if ( !( ent in lockFXID ) )
				{
					lockFXData data
					data.fxHandle    = -1
					data.initialLock = false
					lockFXID[ent] <- data
				}

				if ( !( ent in minimapMarkerRui ) )
				{
					minimapMarkerRui[ent] <- null
				}
			}
		}

		file.enemiesInsideEchoLocator[echoLocator] = validTouchingEnts.len()

		//cap off how many players footsteps we track.
		if ( validTouchingEnts.len() > ECHO_LOCATOR_MAX_FOOTSTEP_TARGETS_TO_SHOW )
		{
			validTouchingEnts.sort( SortPlayersByDistFromLocalViewPlayer )
			validTouchingEnts.resize( ECHO_LOCATOR_MAX_FOOTSTEP_TARGETS_TO_SHOW )
		}

		foreach ( entity potentialVictim in validTouchingEnts )
		{
			#if DEVELOPER
			string playerName = potentialVictim.IsPlayer() ? potentialVictim.GetPlayerName() : "DECOY" + potentialVictim.GetEntIndex()
			#endif //DEV

			bool onGround = GetIsPlayerOnGroundForEchoLocator( potentialVictim )
			bool isCombatDummie = IsTrainingDummie( potentialVictim )

			if ( onGround )
			{
				float playerSpeed = GetPlayerSpeedForEchoLocator( potentialVictim )

				float deltaTime                 = ( Time() - lastPingTimeForLoco[potentialVictim] )
				bool movementCheckPassed        = DoesPlayerPassEchoLocatorMovementCheck( potentialVictim, playerSpeed )
				weaponCheckData weaponCheckResult = DoesPlayerPassEchoLocatorWeaponDischargeCheck( potentialVictim )

				if ( movementCheckPassed || weaponCheckResult.checkPassed )
				{
					float footstepFxDelta = Time() - lastPingTimeForLoco[potentialVictim]

					if ( !EffectDoesExist( lockFXID[potentialVictim].fxHandle ) && weaponCheckResult.checkPassed  )
					{
						lastPingTimeForWeapon[potentialVictim] = Time()
						if ( potentialVictim.IsPlayer() || isCombatDummie || potentialVictim.IsPlayerDecoy() )
						{
							//Player hasn't been revealed in some time, so animate in the marker
							if ( footstepFxDelta > LOCK_FX_RESET_TIME )
							{
								if ( echoLocatorOwner )
								{
									EmitSoundOnEntity( GetLocalViewPlayer(), ECHO_LOCATOR_TARGET_ACQUIRED_SOUND )
								}

								lockFXID[potentialVictim].fxHandle    = StartParticleEffectOnEntity( potentialVictim, GetParticleSystemIndex( ECHO_LOCATOR_TARGET_ANIMATED ), FX_PATTACH_POINT_FOLLOW, potentialVictim.LookupAttachment( "CHESTFOCUS" ) )

									Effects_SetParticleFlag( lockFXID[potentialVictim].fxHandle, PARTICLE_SCRIPT_FLAG_NO_DESATURATE, true )

								lockFXID[potentialVictim].initialLock = false
							}
							//Player was recently revlealed, play the less animated marker
							else
							{
								lockFXID[potentialVictim].fxHandle    = StartParticleEffectOnEntity( potentialVictim, GetParticleSystemIndex( ECHO_LOCATOR_TARGET_NON_ANIMATED ), FX_PATTACH_POINT_FOLLOW, potentialVictim.LookupAttachment( "CHESTFOCUS" ) )

									Effects_SetParticleFlag( lockFXID[potentialVictim].fxHandle, PARTICLE_SCRIPT_FLAG_NO_DESATURATE, true )

								lockFXID[potentialVictim].initialLock = false
							}
						}
					}

					float waitTime = FLT_MAX

					if ( movementCheckPassed )
					{
						waitTime = GraphCapped( playerSpeed, CROUCH_WALK_SPEED, MAX_SPRINT_SPEED, JOG_FX_WAIT_TIME, SPRINT_FX_WAIT_TIME )
					}
					else if ( weaponCheckResult.checkPassed )
					{
						waitTime = max( weaponCheckResult.totalFireTime, WEAPON_FIRE_FX_MIN_WAIT_TIME )
					}

					#if DEVELOPER
						if ( ECHO_LOCATOR_DEBUG )
						{
							printt("EcholocateEnemy_Thread() wait time: " + waitTime + " deltaTime: " + deltaTime + " player name: " + playerName + " player speed: " + playerSpeed + " max speed: " + MAX_SPRINT_SPEED + " fraction: " + GraphCapped( playerSpeed, CROUCH_WALK_SPEED, MAX_SPRINT_SPEED, 0.0, 1.0 ) )
						}
					#endif //DEV

					if ( deltaTime > waitTime )
					{
						thread EchoLocatorFootstepVFXClient( potentialVictim, GetLocalViewPlayer().GetTeam() )
						lastPingTimeForLoco[potentialVictim] = Time()
					}
				}
				if ( wasInAir[potentialVictim] )
				{
					//Just landed
					#if DEVELOPER
						if ( ECHO_LOCATOR_DEBUG )
						{
							printt( "EcholocateEnemy_Thread " + playerName + " Landed." )
						}
					#endif //DEV
					wasInAir[potentialVictim] = false

					//don't want to double up on a marker for a footstep and then a landing one to overwhelm the player with VFX.
					if ( deltaTime > SPRINT_FX_WAIT_TIME )
					{
						thread EchoLocatorFootstepVFXClient( potentialVictim, GetLocalViewPlayer().GetTeam() )
						lastPingTimeForLoco[potentialVictim] = Time()
					}
				}

				wasInAir[potentialVictim] = false
			}
			else
			{
				if ( minimapMarkerRui[potentialVictim] != null )
				{
					Minimap_CommonCleanup( minimapMarkerRui[potentialVictim] )
					minimapMarkerRui[potentialVictim] = null
				}

				if ( !wasInAir[potentialVictim] )
				{
					//Just jumped
					#if DEVELOPER
						if ( ECHO_LOCATOR_DEBUG )
						{
							printt( "EcholocateEnemy_Thread " + playerName + " Jumped." )
						}
					#endif //DEV
					float deltaTime = ( Time() - lastPingTimeForLoco[potentialVictim] )
					if ( deltaTime > SPRINT_FX_WAIT_TIME )
					{
						thread EchoLocatorFootstepVFXClient( potentialVictim, GetLocalViewPlayer().GetTeam() )
						lastPingTimeForLoco[potentialVictim] = Time()
					}
				}

				wasInAir[potentialVictim] = true
			}
		}

		//Keep the minimap icons frame accurate
		foreach ( entity potentialVictim, var minimapRUI in minimapMarkerRui )
		{
			if ( IsValid( minimapRUI ) )
			{
				if ( !IsValid( potentialVictim ) )
				{
					Minimap_CommonCleanup( minimapMarkerRui[potentialVictim] )
					minimapMarkerRui[potentialVictim] = null
				}
				else
				{
					float deltaLastPingTime = Time() - lastPingTimeForLoco[potentialVictim]

					if ( deltaLastPingTime > MINIMAP_MARKER_DEBOUNCE_TIME )
					{
						Minimap_CommonCleanup( minimapMarkerRui[potentialVictim] )
						minimapMarkerRui[potentialVictim] = null
					}
					else
					{
						RuiSetFloat3( minimapRUI, "objectPos", potentialVictim.GetOrigin() )
						RuiSetFloat3( minimapRUI, "objectAngles", potentialVictim.GetAngles() )
					}
				}
			}
		}

		//handle cleanup of lock vfx
		foreach ( entity potentialVictim, lockFXData data in lockFXID )
		{
			if ( EffectDoesExist( data.fxHandle ) )
			{
				if ( !IsValid( potentialVictim ) )
				{
					EffectStop( data.fxHandle, false, true )
				}
				else
				{
					float deltaLastPingTime = Time() - lastPingTimeForLoco[potentialVictim]
					float lastWeaponFireTime = Time() - lastPingTimeForWeapon[potentialVictim]

					float timeDeltaThreshold = LOCK_FX_LIFETIME


							if( PlayerHasPassive( echoLocator.GetBossPlayer(), ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_seer_locator_tracking_extension
							{
								timeDeltaThreshold = GetEchoLocator_Gunfire_Tracking_Extension()
							}


					if ( lastWeaponFireTime > timeDeltaThreshold )
					{
						EffectStop( data.fxHandle, false, true )
					}

					//the initial lock will last longer than the others to help players locate enemies
					float deltaCheck = data.initialLock ? ECHO_LOCATOR_INITIAL_MARKER_DURATION : LOCK_FX_DEBOUNCE_TIME
					bool isPlayerInsideEchoLocator = IsPlayerInsideEchoLocator( potentialVictim, echoLocator )

					if ( deltaLastPingTime > deltaCheck || !isPlayerInsideEchoLocator )
					{
						EffectStop( data.fxHandle, false, true )
					}
				}
			}
		}

		foreach ( entity aiEnt, aiVelocityData data in file.aiVelocity )
		{
			if ( IsValid( aiEnt ) )
			{
				if ( IsAlive( aiEnt ) && aiEnt.IsOnGround() )
				{
					vector distDiff = aiEnt.GetOrigin() - data.origin
					float timeDelta = Time() - data.time
					//Length2D so that stepping up/down stairs doesn't artificially boost the velocity.  Saw training dummies crouch strafing up/down stairs passive the move speed check when I used Length()
					float speed     = ( timeDelta > 0.0 ) ? Length2D( distDiff ) / timeDelta : 0.0

					data.time   = Time()
					data.origin = aiEnt.GetOrigin()
					data.speed  = speed
				}
				else
				{
					data.speed = 0
				}
			}
		}

		firstLoopIteration = false
		WaitFrame()
	}
}

int function SortPlayersByDistFromLocalViewPlayer( entity a, entity b )
{
	entity localViewPlayer = GetLocalViewPlayer()

	float distanceA = Distance( localViewPlayer.EyePosition(), a.EyePosition() )
	float distanceB = Distance( localViewPlayer.EyePosition(), b.EyePosition() )

	if ( distanceA > distanceB )
		return 1

	if ( distanceA < distanceB )
		return -1

	return 0
}

void function EchoLocatorFootstepVFXClient( entity victim, int team )
{
	int particleSystemID = ( victim.IsPlayer() || victim.IsPlayerDecoy() ) ? GetParticleSystemIndex( ECHO_LOCATOR_VISUAL_FOOT_PING ) : GetParticleSystemIndex( ECHO_LOCATOR_VISUAL_FOOT_PING_AI )

	TraceResults traceResult = TraceLine( victim.GetOrigin() + ( victim.GetUpVector() * 20 ), victim.GetOrigin() - ( victim.GetUpVector() * 200 ), [ victim ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )

	vector angles = AnglesOnSurface( traceResult.surfaceNormal, victim.GetForwardVector() )
	int handle = -1

	if ( IsValid( traceResult.hitEnt ) )
	{
		//assuming this ent could be moving, we create a client script mover, parent it to the hitEnt and play the particle on it so that they look like they stick to the moving thing (IE worlds edge train)
		entity mover = CreateClientsideScriptMover( EMPTY_MODEL, traceResult.endPos, angles )
		mover.SetParent( traceResult.hitEnt )
		handle = StartParticleEffectOnEntity( mover, particleSystemID, FX_PATTACH_CUSTOMORIGIN_FOLLOW, -1 )
		thread DelayDestroy( mover )
	}
	else
	{
		handle = StartParticleEffectInWorldWithHandle( particleSystemID, traceResult.endPos, angles )
	}

	//Give the firing range dummies and player decoys the player enemy coloured footsteps instead of the usual neutral AI footstep colour
	vector color = ( victim.IsPlayer() || IsTrainingDummie( victim ) || victim.IsPlayerDecoy() ) ? ENEMY_COLOR_FX : NEUTRAL_COLOR_FX
	EffectSetControlPointVector( handle, 1, color )

		Effects_SetParticleFlag( handle, PARTICLE_SCRIPT_FLAG_NO_DESATURATE, true )

}

void function DelayDestroy( entity mover )
{
	mover.EndSignal( "OnDestroy" )
	wait 2.5
	mover.Destroy()
}

void function EchoLocator_UpdateIntensity_Thread( entity player, int fxHandle )
{
	Assert( IsNewThread(), "Must be threaded off" )
	player.EndSignal( "EchoLocator_Exit" )
	player.EndSignal( "OnDeath" )

	float lastStrength = 0.0
	float goalStrength = 0.1
	float targetStrength = 0.0
	const float goalStrengthRevealed = 1.0
	const float goalStrengthStationary = 0.1
	const float goalStrengthAlliedWithEnemiesInside = 0.5
	const float strengthIncrement = 0.01
	bool lastInsideEnemyEchoLocator = false
	EffectSetControlPointVector( fxHandle, 3, FRIENDLY_COLOR_FX )


	while( true )
	{
		//guard for R5DEV-269610.
		if ( !EffectDoesExist( fxHandle ) )
			return

		insideEchoLocatorStateData insideStateData = GetPlayerInsideEchoLocatorState( player )
		float playerSpeed = GetPlayerSpeedForEchoLocator( player )

		if ( insideStateData.insideState == eInsideEchoLocatorState.INSIDE_ENEMY )
		{
			if ( !lastInsideEnemyEchoLocator )
			{
				lastInsideEnemyEchoLocator = true
				EffectSetControlPointVector( fxHandle, 3, ENEMY_COLOR_FX )
			}

			entity weapon                   = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			bool movementCheckPassed        = DoesPlayerPassEchoLocatorMovementCheck( player, playerSpeed ) && player.IsOnGround()
			weaponCheckData weaponCheckData = DoesPlayerPassEchoLocatorWeaponDischargeCheck( player )

			if ( movementCheckPassed || weaponCheckData.checkPassed )
			{
				goalStrength = goalStrengthRevealed
			}
			else
			{
				goalStrength = goalStrengthStationary
			}
		}
		else if ( insideStateData.insideState == eInsideEchoLocatorState.INSIDE_ALLIED )
		{
			if ( lastInsideEnemyEchoLocator )
			{
				EffectSetControlPointVector( fxHandle, 3, FRIENDLY_COLOR_FX )
				lastInsideEnemyEchoLocator = false
			}

			goalStrength = insideStateData.numEnemies > 0 ? goalStrengthAlliedWithEnemiesInside : goalStrengthStationary
		}
		else
		{
			goalStrength = 0.0
		}

		if ( fabs( goalStrength - lastStrength ) > FLT_EPSILON )
		{
			if ( goalStrength > lastStrength )
			{
				targetStrength = Clamp( lastStrength + strengthIncrement, 0.0, 1.0 )
			}
			else
			{
				targetStrength = Clamp( lastStrength - strengthIncrement, 0.0, 1.0 )
			}

			EffectSetControlPointVector( fxHandle, 2, <targetStrength, 0, 0> )
			lastStrength = targetStrength
		}

		WaitFrame()
	}
}

void function EchoLocator_StopVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( file.playersInsideEchoLocators.contains( ent ) )
	{
		file.playersInsideEchoLocators.fastremovebyvalue( ent )
	}

	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	EmitSoundOnEntity( ent, ECHO_LOCATOR_THRESHOLD_SOUND )

	ent.Signal( "EchoLocator_Exit" )
}

void function EchoLocatorScreenFXThink( entity player, int fxHandle )
{
	Assert( IsNewThread(), "Must be threaded off" )
	player.EndSignal( "EchoLocator_Exit" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )
		}
	)


	for ( ;; )
	{
		if ( !EffectDoesExist( fxHandle ) )
			break

		EffectSetControlPointVector( fxHandle, 1, <1,999,0> )

		WaitFrame()
	}
}

#endif //CLIENT

int function GetEchoLocatorRadius()
{
	return GetCurrentPlaylistVarInt( "seer_ult_radius", ECHO_LOCATOR_RADIUS_SCRIPT )
}

int function GetEchoLocatorHP()
{
	return GetCurrentPlaylistVarInt( "seer_ult_hp", ECHO_LOCATOR_HP )
}

bool function GetEchoLocatorUseWalkSpeed()
{
	return GetCurrentPlaylistVarBool( "seer_ult_speed_override", false )
}


float function GetEchoLocator_Gunfire_Tracking_Extension()
{
	return GetCurrentPlaylistVarFloat( "seer_ult_extended_gunfire_tracking", 3.0 )
}