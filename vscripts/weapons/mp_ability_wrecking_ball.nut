global function MpAbilityWreckingBall_Init
global function OnWeaponAttemptOffhandSwitch_ability_WreckingBall
global function OnWeaponTossReleaseAnimEvent_WeaponWreckingBall
global function OnWeaponTossPrep_WeaponWreckingBall
global function OnProjectileCollision_ability_WreckingBall

#if SERVER
global function CodeCallback_WreckingBallImpact
global function CodeCallback_WreckingBallWallCheck
global function AddWreckingBallEMPDestroyDevice
global function AddWreckingBallEMPDamageDevice
#endif

#if CLIENT
global function ServerCallback_RT_SpeedupHudForPlayer
global function ServerCallback_PrototypeManageHighlight
global function ServerCallback_RT_CleanupSpeedupHudForPlayer
#endif

#if SERVER && DEVELOPER
global function DEV_ClearWreckingBallSpeedTriggers
#endif

global const string WRECKING_BALL_BALL_SCRIPT_NAME			= "wreckingball_ball"
global const string WRECKING_BALL_ANIMCHILD_SCRIPT_NAME		= "wreckingball_animchild"
global const string WRECKING_BALL_MAGNET_SCRIPT_NAME 		= "wreckingball_magnet"
global const string WRECKING_BALL_SPEEDTRIGGER_SCRIPT_NAME 	= "wreckingball_speedtrigger"

// DEFAULT EFFECT VARS
const int WRECKING_BALL_DAMAGE_FINAL				= 20			// see damagedef_wrecking_ball. This value is only used for destroying doors
const float WRECKING_BALL_FINAL_EXPLOSION_RADIUS	= 300.0			// see damagedef_wrecking_ball. This value is only used for displaying the threat indicator
const float WRECKING_BALL_BALL_DURATION 			= 10.0			// how long the ball stays active before exploding
const float WRECKING_BALL_WAKE_DURATION 			= 60.0			// how long the ball pieces linger on the ground before expiring
const float WRECKING_BALL_PROXY_DELAY				= 0.5			// delay before ball explodes after detecting an enemy
const float WRECKING_BALL_WAKE_BUFF_DURATION 		= 2				// duration of the speed/friction buff outside of a speed trigger
const float WRECKING_BALL_SHELLSHOCK_CHARGE_TIME 	= 3.0			// time the ball must be active before the maximum shellshock debuff time is reached. Otherwise, the shellshock time is based on the progressed fraction of this value.
const float WRECKING_BALL_SHELLSHOCK_DURATION_MIN 	= 3.0			// min duration of the shellshock debuff
const float WRECKING_BALL_SHELLSHOCK_DURATION_MAX 	= 6.0			// max duration of the shellshock debuff
const float WRECKING_BALL_SHELLSHOCK_DURATION_ALLY 	= 3.0			// duration of the shellshock debuff for impacted allies (currently the same, consistent with other shellshocks)
const float WRECKING_BALL_WAKE_BUFF_SEVERITY		= 0.15			// severity of the speed/friction buff
const float WRECKING_BALL_PUNT_POWER				= 300.0			// knockback power on players hit with ball explosion
const float WRECKING_BALL_PUNT_POWER_ALLY			= 200.0			// knockback power on allied players hit with ball explosion
const float WRECKING_BALL_PLAYER_PROXIMITY_DIST		= 225.0			// ball detection radius to find enemies for early explosion
const float WRECKING_BALL_SPEED_TRIGGER_RADIUS		= 88.0			// speed trigger radius (around ball piece)
const float WRECKING_BALL_SPEED_TRIGGER_HEIGHT		= 16.0			// speed trigger radius (around ball piece)
const float WRECKING_BALL_JUMP_PAD_WINDOW			= 0.2			// Don't allow a ball bounce in this window to let the jump pad velocity take effect
const float WRECKING_BALL_FORCE_TO_MOVE				= 600.0			// Previous RollerOption entry - force to push the ball forward each bounce
const float WRECKING_BALL_TRACE_RADIUS				= 40.0			// Previous RollerOption entry - Radius extension from the ball's offset for various Trace functions (so that varying Ball size can be adjusted for)
const float WRECKING_BALL_EMP_DEVICE_COLLISION_CHECK_RANGE 	= 1000.0		// How far from the ball to grab entities to evaluate for damage/destroy when the ball collides with something
const float WRECKING_BALL_DESTORY_DEVICE_RANGE 		= 100
const float WRECKING_BALL_DAMAGE_DEVICE_RANGE 		= 100


const float RETRIGGER_DELAY = 2.0


// MODELS
const asset WRECKING_BALL_PROJ_WRECKING_BALL 		= $"mdl/props/madmaggie_ultimate_ball_static/madmaggie_ultimate_ball_static.rmdl"
const asset WRECKING_BALL_ANIM_MODEL 				= $"mdl/props/madmaggie_ultimate_ball/madmaggie_ultimate_ball.rmdl"
const asset WRECKING_BALL_PIECE_MODEL				= $"mdl/props/madmaggie_ultimate_mine/madmaggie_ultimate_mine.rmdl" //$"mdl/props/maggie_ultimate_ball_magnet_TEMP.rmdl"

/// FX/PARTICLES
const asset WRECKING_BALL_GROUND_IMPACT_SMALL_FX	= $"earthshaker_impact_exp_OS_small"
const asset WRECKING_BALL_FINAL_EXPLODE_FX			= $"P_mm_ball_exp_default"
const asset WRECKING_BALL_PIECE_LOOP_FX				= $"P_mm_roll_pcs_hld"
const asset WRECKING_BALL_PIECE_FLYING_FX			= $"P_mm_roll_pcs_brk"
const asset FX_SPEED_BOOST_ACTIVE 					= $"P_mm_boost_body_human"
const asset FX_SPEED_BOOST_HUD 						= $"P_mm_player_boost_screen"
const asset WRECKING_BALL_RADIUS_FX 				= $"P_mm_roll_ball_hld"
const vector COLOR_SPEEDBOOST_START 				= <250, 247, 93>
const vector COLOR_SPEEDBOOST_MID 					= <250, 255, 185>
const vector COLOR_SPEEDBOOST_END 					= <255, 255, 255>


const asset WRECKING_BALL_FIRE_FX_UPGRADE					= $"P_mm_roll_ball_hld_thermite"
const asset WRECKING_BALL_FINAL_EXPLODE_FX_UPGRADE			= $"P_mm_ball_exp_default_thermite"
const asset WRECKING_BALL_GROUND_IMPACT_SMALL_FX_UPGRADE	= $"P_mm_ball_bounce_default_thermite"
const asset WRECKING_BALL_PIECE_LOOP_FX_UPGRADE				= $"P_mm_roll_pcs_hld_thermite"
const asset WRECKING_BALL_RADIUS_FX_UPGRADE					= $"P_mm_roll_ball_st_thermite"


/// SFX/SOUND
const string SOUND_SPEED_BOOST_ACTIVE_1P 			= "Maggie_Ult_SpeedBoost"
const string SOUND_SPEED_BOOST_ACTIVE_3P 			= "Maggie_Ult_SpeedBoost_3p"
const string SOUND_SPEED_BOOST_LOOP_1P				= "Maggie_Ult_SpeedBoost_Loop_1P"
const string SOUND_SPEED_BOOST_END					= "Maggie_Ult_SpeedBoost_Deactivate_1P"
const string SOUND_SPEED_BOOST_REACTIVE_1P 			= "Maggie_Ult_SpeedBoost_Reactive"
const string SOUND_SPEED_BOOST_REACTIVE_3P 			= "Maggie_Ult_SpeedBoost_Reactive_3p"
const string SOUND_WRECKING_BALL_WARNING_SOUND 		= "Maggie_Ultimate_Ball_Enemy_Warning"					//warning sound for when the ball detects an enemy players and is about to explode
const string SOUND_WRECKING_BALL_GROUND_IMPACT		= "Maggie_Ultimate_Phys_Imp_Lootball_Hard_Default"
const string SOUND_WRECKING_BALL_OTHER_IMPACT		= "Maggie_Ultimate_Phys_Imp_Lootball_Hard_Default"
const string SOUND_WRECKING_BALL_FINAL 				= "Maggie_Ult_Ball_Explode"								//explosion sound
const string SOUND_WRECKING_BALL_ACTIVE				= "Maggie_Ultimate_Ball_Actve_Loop"						//looping sound that plays on the ball as it moves
const string SOUND_WRECKING_BALL_EJECT				= "Maggie_Ultimate_Ball_Sides_Eject"

const bool DEBUG_PROP_COUNT							= true
const bool DEBUG_EMP_DAMAGE_DESTRUCTION				= true
const bool DEBUG_BALL_COLLISION_CALLBACK			= true

const string SOUND_WRECKING_BALL_UPGRADE_IGNITE		= "Maggie_Ult_Ball_Upgraded_Ignite"
const string SOUND_WRECKING_BALL_UPGRADE_FINAL		= "Maggie_Ult_Ball_Upgraded_Explode"
const string SOUND_WRECKING_BALL_UPGRADE_ACTIVE		= "Maggie_Ultimate_Ball_Upgraded_Active_Loop"



struct WakeInfo
{
	int touchingTriggers = 0
	array<int> statusEffectHandles = []
	entity fxHandle_3p = null
}

struct
{
	table< entity, WakeInfo > entitiesTouchingSpeedTriggers
	table< entity, WeaponPrimaryAttackParams > storedAttackParams
	table< entity, entity > playerBallWeapons
#if SERVER && DEVELOPER
	int propCount
	int speedTriggerScriptManagedArray
#endif

#if CLIENT
	int fxHandle_1p = -1
#endif

	bool balance_wreckingBallSlipSlide
	bool balance_wreckingBallPauseRegen
	bool balance_wreckingBallFindWayAroundWalls
	bool balance_wreckingBallBounce
	bool balance_wreckingBallPunt
	bool balance_wreckingBallProximityDetonate
	int balance_wreckingBallDamageFinal
	float balance_wreckingBallBallDuration
	float balance_wreckingBallWakeDuration
	float balance_wreckingBallWakeBuffDuration
	float balance_wreckingBallShellshockChargeTime
	float balance_wreckingBallShellshockDurationMin
	float balance_wreckingBallShellshockDurationMax
	float balance_wreckingBallShellshockDurationAlly
	float balance_wreckingBallPuntPower
	float balance_wreckingBallPuntPowerAlly

	float balance_wreckingBallUpgradeScanDist
	float balance_wreckingBallFireChargeTime
	int fireFxId


	//FX stuff for BigRig
	bool fxOption_pieceHighlight
	bool fxOption_pieceLoopFX
	bool fxOption_playTempFX

	bool fxOption_playTempSound

	bool pingWreckingBallOnCast

#if SERVER
	int wreckingBallDestroyArrayID
	int wreckingBallDamageArrayID
	table<entity, bool> ballProxyDetonateTriggered

		table<entity, bool> isBallOnFire

	table<entity, float> ballEndProxyDetonateTime
	table<entity, array< entity > > ballEmpDamagedList
	table<entity, array< entity > > ballEmpDestroyedList


		table<entity, bool> hasBeenHit

#endif
} file

void function MpAbilityWreckingBall_Init()
{
	RegisterSignal( "WreckingBall_CleanupFX" )
	RegisterSignal( "WreckingBall_PieceHitGround" )
	RegisterSignal( "WreckingBall_SpeedBoostEnd" )

	PrecacheParticleSystem( FX_SPEED_BOOST_HUD )
	PrecacheParticleSystem( WRECKING_BALL_GROUND_IMPACT_SMALL_FX )
	PrecacheParticleSystem( WRECKING_BALL_FINAL_EXPLODE_FX )
	PrecacheParticleSystem( FX_SPEED_BOOST_ACTIVE )
	PrecacheParticleSystem( WRECKING_BALL_PIECE_LOOP_FX )
	PrecacheParticleSystem( WRECKING_BALL_PIECE_FLYING_FX )
	PrecacheParticleSystem( WRECKING_BALL_RADIUS_FX )

		PrecacheParticleSystem( WRECKING_BALL_FIRE_FX_UPGRADE )
		PrecacheParticleSystem( WRECKING_BALL_FINAL_EXPLODE_FX_UPGRADE )
		PrecacheParticleSystem( WRECKING_BALL_GROUND_IMPACT_SMALL_FX_UPGRADE )
		PrecacheParticleSystem( WRECKING_BALL_PIECE_LOOP_FX_UPGRADE )
		PrecacheParticleSystem( WRECKING_BALL_RADIUS_FX_UPGRADE )

	PrecacheModel( WRECKING_BALL_PROJ_WRECKING_BALL )
	PrecacheModel( WRECKING_BALL_PIECE_MODEL )
	PrecacheModel( WRECKING_BALL_ANIM_MODEL )

	file.balance_wreckingBallPauseRegen			= GetCurrentPlaylistVarBool( "wrecking_ball_pause_regen_override", false )
	file.balance_wreckingBallFindWayAroundWalls	= GetCurrentPlaylistVarBool( "wrecking_ball_find_way_around_override", true )
	file.balance_wreckingBallBounce 			= GetCurrentPlaylistVarBool( "wrecking_ball_bounce_override", true )
	file.balance_wreckingBallProximityDetonate 	= GetCurrentPlaylistVarBool( "wrecking_ball_proxy_detonate_override", true )
	file.balance_wreckingBallPunt 				= GetCurrentPlaylistVarBool( "wrecking_ball_punt_override", true )
	file.balance_wreckingBallSlipSlide 			= GetCurrentPlaylistVarBool( "wrecking_ball_slipslide_override", true )
	file.balance_wreckingBallDamageFinal 		= GetCurrentPlaylistVarInt( "wrecking_ball_damage_final_override", WRECKING_BALL_DAMAGE_FINAL )
	file.balance_wreckingBallBallDuration 		= GetCurrentPlaylistVarFloat( "wrecking_ball_ball_duration_override", WRECKING_BALL_BALL_DURATION )
	file.balance_wreckingBallWakeDuration 		= GetCurrentPlaylistVarFloat( "wrecking_ball_wake_duration_override", WRECKING_BALL_WAKE_DURATION )
	file.balance_wreckingBallWakeBuffDuration 	= GetCurrentPlaylistVarFloat( "wrecking_ball_wake_duration_override", WRECKING_BALL_WAKE_BUFF_DURATION )
	file.balance_wreckingBallShellshockChargeTime = GetCurrentPlaylistVarFloat( "wrecking_ball_shellshock_charge_time_override", WRECKING_BALL_SHELLSHOCK_CHARGE_TIME )
	file.balance_wreckingBallShellshockDurationMin = GetCurrentPlaylistVarFloat( "wrecking_ball_shellshock_duration_min_override", WRECKING_BALL_SHELLSHOCK_DURATION_MIN )
	file.balance_wreckingBallShellshockDurationMax = GetCurrentPlaylistVarFloat( "wrecking_ball_shellshock_duration_max_override", WRECKING_BALL_SHELLSHOCK_DURATION_MAX )
	if ( file.balance_wreckingBallShellshockDurationMin > file.balance_wreckingBallShellshockDurationMax )
		file.balance_wreckingBallShellshockDurationMin = file.balance_wreckingBallShellshockDurationMax
	file.balance_wreckingBallShellshockDurationAlly = GetCurrentPlaylistVarFloat( "wrecking_ball_shellshock_duration_ally_override", WRECKING_BALL_SHELLSHOCK_DURATION_ALLY )
	file.balance_wreckingBallPuntPower 			= GetCurrentPlaylistVarFloat( "wrecking_ball_punt_power_override", WRECKING_BALL_PUNT_POWER )
	file.balance_wreckingBallPuntPowerAlly 		= GetCurrentPlaylistVarFloat( "wrecking_ball_punt_power_ally_override", WRECKING_BALL_PUNT_POWER_ALLY )

	file.balance_wreckingBallUpgradeScanDist = GetCurrentPlaylistVarFloat( "wrecking_ball_upgrade_scan_range", 400.0 )
	file.balance_wreckingBallFireChargeTime = GetCurrentPlaylistVarFloat( "wrecking_ball_upgrade_fire_charge_time", 1.0 )
	file.fireFxId = GetParticleSystemIndex( WRECKING_BALL_FIRE_FX_UPGRADE )


	//FX stuff for BigRig
	file.fxOption_pieceHighlight				= GetCurrentPlaylistVarBool( "wrecking_ball_fx_piece_highlight", false )
	file.fxOption_pieceLoopFX					= GetCurrentPlaylistVarBool( "wrecking_ball_fx_piece_loop_fx", true )
	file.fxOption_playTempFX					= GetCurrentPlaylistVarBool( "wrecking_ball_fx_play_temp_fx", true )

	//SFX stuff for akalmbach
	file.fxOption_playTempSound					= GetCurrentPlaylistVarBool( "wrecking_ball_fx_play_temp_sounds", true )

	file.pingWreckingBallOnCast					= GetCurrentPlaylistVarBool( "wrecking_ball_ping_on_cast", false )

	#if SERVER
		RegisterDynamicEntCleanupItem_Parented_Scriptname( WRECKING_BALL_MAGNET_SCRIPT_NAME )
		RegisterDynamicEntCleanupItem_Area_Scriptname( WRECKING_BALL_MAGNET_SCRIPT_NAME )
		AddDamageCallbackSourceID( eDamageSourceId.damagedef_wrecking_ball, OnWreckingBallDamaged )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_wrecking_ball_puck, OnMagnetExplosionDamage )
		RegisterSignal( "WreckingBall_EnteredSpeedZone" )
		RegisterSignal( "WreckingBall_LeftSpeedZone" )
		RegisterSignal( "WreckingBall_SpeedZoneCleanup" )
		PrecacheImpactEffectTable( "mm_ball_bounce" )

			PrecacheImpactEffectTable( "mm_fireball_bounce" )

		PrecacheImpactEffectTable( "mm_ball_pcs" )
		PrecacheImpactEffectTable( "mm_ball_pcs_initialimpact" )
		PrecacheWeapon( $"mp_ability_rolling_thunder_piece" )

		file.wreckingBallDestroyArrayID = CreateScriptManagedEntArray()
		file.wreckingBallDamageArrayID = CreateScriptManagedEntArray()

	#endif //SERVER

	#if CLIENT
		RegisterSignal( "WreckingBall_Throw" )
		AddCreateCallback( "prop_rollingthunder", WreckingBall_SetupProjectileKillreplay )
	#endif

	#if SERVER && DEVELOPER
		file.speedTriggerScriptManagedArray = CreateScriptManagedEntArray()
	#endif

	Remote_RegisterClientFunction( "ServerCallback_RT_SpeedupHudForPlayer", "int", 0, 999 )
	Remote_RegisterClientFunction( "ServerCallback_RT_CleanupSpeedupHudForPlayer" )
	Remote_RegisterClientFunction( "ServerCallback_PrototypeManageHighlight", "entity" )
}

//////////////////////////////////
////// ONWEAPON FUNCTIONS ////////
//////////////////////////////////

var function OnWeaponTossReleaseAnimEvent_WeaponWreckingBall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()

	file.storedAttackParams[ player ] <- attackParams
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	vector throwerVelocity = player.GetVelocity()

	bool projectilePredicted      = PROJECTILE_PREDICTED
	bool projectileLagCompensated = PROJECTILE_LAG_COMPENSATED
	#if SERVER
		if ( weapon.IsForceReleaseFromServer() )
		{
			projectilePredicted = false
			projectileLagCompensated = false
		}
	#endif
	entity ballProjectile = WreckingBall_Launch( weapon, attackParams.pos, (attackParams.dir), projectilePredicted, projectileLagCompensated )
	if ( ballProjectile )
	{
		PlayerUsedOffhand( player, weapon, true, ballProjectile )
		#if SERVER
			file.playerBallWeapons[ player ] <- weapon
			ballProjectile.e.isDoorBlocker = true
			ballProjectile.e.spawnTime = Time()

			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( ballProjectile, projectileSound )

			//Parenting another model to the projectile so we can run animations on it
			ballProjectile.Hide()
			entity animatedChild = WreckingBall_CreateAnimatedChildModelForPhysicsObject( ballProjectile, player )
			thread WreckingBall_AnimateChildModelThink( player, animatedChild )

			weapon.w.lastProjectileFired = ballProjectile


			if ( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_maggie_thermite_explosion
			{
				PlayBattleChatterLineToSpeakerAndTeam( player, "bc_superFireball" )
			}
			else

			{
				PlayBattleChatterLineToSpeakerAndTeam( player, "bc_super" )
			}

		if ( file.balance_wreckingBallPauseRegen )
				weapon.AddMod( "survival_ammo_regen_paused" )
		#endif //SERVER

		#if CLIENT
			Signal( weapon, "WreckingBall_Throw" )

		#endif
	}

	return weapon.GetAmmoPerShot()
}

void function OnWeaponTossPrep_WeaponWreckingBall( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

bool function OnWeaponAttemptOffhandSwitch_ability_WreckingBall( entity weapon )
{
	return true
}

void function OnProjectileCollision_ability_WreckingBall( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
#if SERVER
	entity player = projectile.GetOwner()

	if ( !IsValid( player ) )
	{
		projectile.Destroy()
		return
	}
	vector throwDirection = < file.storedAttackParams[ player ].dir.x, file.storedAttackParams[ player ].dir.y, 0.0 >

	entity ball = WreckingBall_DestroyProjectileAndSpawnBall( projectile, throwDirection )
	thread WreckingBall_GetTheBallRolling( ball, throwDirection )
#endif //SERVER
}

entity function WreckingBall_Launch( entity weapon, vector attackPos, vector throwVelocity, bool isPredicted, bool isLagCompensated )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() || !isPredicted )
			return null
	#endif

	int damageFlags = weapon.GetWeaponDamageFlags()
	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = attackPos
	fireGrenadeParams.vel = throwVelocity
	fireGrenadeParams.angVel = <10, 1600, 10>
	fireGrenadeParams.fuseTime = weapon.GetGrenadeFuseTime()
	fireGrenadeParams.scriptTouchDamageType = (damageFlags & ~DF_EXPLOSION) // when a grenade "bonks" something, that shouldn't count as explosive.explosive
	fireGrenadeParams.scriptExplosionDamageType = damageFlags
	fireGrenadeParams.clientPredicted = isPredicted
	fireGrenadeParams.lagCompensated = isLagCompensated
	fireGrenadeParams.useScriptOnDamage = true
	entity ball = weapon.FireWeaponGrenade( fireGrenadeParams )
	if ( ball == null )
		return null

	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		if ( IsValid( owner ) )
		{
			if ( IsWeaponOffhand( weapon ) )
			{
				AddToUltimateRealm( owner, ball )
			}
			else
			{
				ball.RemoveFromAllRealms()
				ball.AddToOtherEntitysRealms( owner )
			}
		}
	#endif

	ball.proj.savedOrigin = attackPos
	Grenade_Init( ball, weapon )

	return ball
}

void function OnWreckingBallDeployed( entity projectile, DeployableCollisionParams collisionParams )
{
	#if SERVER
	entity player = projectile.GetOwner()

	if ( !IsValid( player ) )
		return

	vector throwDirection = < file.storedAttackParams[ player ].dir.x, file.storedAttackParams[ player ].dir.y, 0.0 >

	entity ball = WreckingBall_DestroyProjectileAndSpawnBall( projectile, throwDirection )
	thread WreckingBall_GetTheBallRolling( ball, throwDirection )
	#endif //SERVER
}

#if SERVER
string function GetActiveBallSFX( entity player )
{
	string result = SOUND_WRECKING_BALL_ACTIVE

		if ( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_maggie_thermite_explosion
			result = SOUND_WRECKING_BALL_UPGRADE_ACTIVE

	return result
}

void function OnWreckingBallDamaged( entity victim, var damageInfo )
{
	if ( !IsValid( victim ) )
		return


		if ( !( victim in file.hasBeenHit ) )
			file.hasBeenHit[ victim ] <- false


	if ( victim.GetScriptName() == WRECKING_BALL_MAGNET_SCRIPT_NAME )
	{
		DamageInfo_ScaleDamage( damageInfo, 0 )
		return
	}

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	float shellshockDuration = file.balance_wreckingBallShellshockDurationMax
	float shellshockFullChargeTime = inflictor.e.spawnTime + file.balance_wreckingBallShellshockChargeTime
	float currentTime = Time()

	if ( currentTime < shellshockFullChargeTime )
	{
		float shellshockChargeTimeFrac = ( shellshockFullChargeTime - currentTime ) / file.balance_wreckingBallShellshockChargeTime
		float shellshockDurationBonus = ( file.balance_wreckingBallShellshockDurationMax - file.balance_wreckingBallShellshockDurationMin ) * shellshockChargeTimeFrac

		shellshockDuration = file.balance_wreckingBallShellshockDurationMin + shellshockDurationBonus
	}

	float puntPower = file.balance_wreckingBallPuntPower

	if ( IsValid( attacker ) )
	{
		//prevent damage if the target is friendly
		if ( IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) && (attacker != victim) )
		{
			DamageInfo_ScaleDamage( damageInfo, 0 )
			shellshockDuration = file.balance_wreckingBallShellshockDurationAlly
			puntPower = file.balance_wreckingBallPuntPowerAlly
		}
	}

	if( !file.hasBeenHit[ victim ] )
	{
		if ( victim.IsPlayer() )
			ShellShock_ApplyForDuration( victim, shellshockDuration )
		if ( file.balance_wreckingBallPunt )
		{
			MaggieCommon_KnockbackTargetFromEntity( DamageInfo_GetInflictor( damageInfo ), victim, puntPower, < 0, 0, -WRECKING_BALL_TRACE_RADIUS > )
			file.hasBeenHit[ victim ] <- true
			}
	}
}

void function OnMagnetExplosionDamage( entity victim, var damageInfo )
{
	if ( !IsValid( victim ) )
		return

	if ( DamageInfo_GetInflictor( damageInfo ) == victim || victim.GetScriptName() != WRECKING_BALL_MAGNET_SCRIPT_NAME )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	victim.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 200 )
}

entity function WreckingBall_CreateAnimatedChildModelForPhysicsObject( entity deployable, entity player )
{
	entity animatedChild = CreatePropScript( WRECKING_BALL_ANIM_MODEL, deployable.GetOrigin(), deployable.GetAngles(), 0, 320000 )
	animatedChild.SetScriptName( WRECKING_BALL_ANIMCHILD_SCRIPT_NAME )
	animatedChild.SetOwner( player )
	animatedChild.DisableHibernation()
	animatedChild.NotSolid()
	animatedChild.SetTakeDamageType( DAMAGE_NO )
	animatedChild.SetMaxHealth( 9999 )
	animatedChild.SetHealth( 9999 )
	animatedChild.SetDamageNotifications( false )
	animatedChild.SetDeathNotifications( false )
	animatedChild.SetParent( deployable )

	return animatedChild
}

//TODO: clean this garbage up when real model/animation/sounds come in
//this is all prototype and very ugly
void function WreckingBall_AnimateChildModelThink( entity player, entity animChild )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( animChild ) )
		return

	//ball.Hide()

	EndSignal( animChild, "OnDeath", "OnDestroy" )

	OnThreadEnd(
		function() : ( player, animChild )
		{
			entity ballParent = animChild.GetParent()
			ballParent.Show()

			if ( !ballParent.IsMarkedForDeletion() )
				EmitSoundOnEntity( ballParent, GetActiveBallSFX( player ) )

			if ( IsValid( animChild ) )
				animChild.Destroy()
		}
	)

	// change these two strings to whatever animation names we have for open and idle respectively - JH
	string openAnim = "ultimate_ball_expand"
	string idleAnim = "ultimate_ball_idle"

	EmitSoundOnEntity( animChild, GetActiveBallSFX( player ) )

	if ( openAnim != "" )
	{
		EmitSoundOnEntity( animChild, SOUND_WRECKING_BALL_EJECT )
		animChild.Anim_PlayOnly( openAnim )
		WaittillAnimDone( animChild )
	}

	if ( idleAnim != "" && animChild.GetParent().GetScriptName() != WRECKING_BALL_BALL_SCRIPT_NAME )
	{
		animChild.Anim_PlayOnly( idleAnim )
		while ( animChild.GetParent().GetScriptName() != WRECKING_BALL_BALL_SCRIPT_NAME )
		{
			WaitFrame()
		}
	}
}

entity function WreckingBall_DestroyProjectileAndSpawnBall( entity projectile, vector dir )
{
	entity owner = projectile.GetOwner()
	vector origin = projectile.GetOrigin()
	vector angles = VectorToAngles( dir )

	entity ball = CreateEntity("prop_physics")
	ball.SetOwner( owner )
	ball.SetModel( WRECKING_BALL_PROJ_WRECKING_BALL )
	ball.SetOrigin( origin )
	ball.SetAngles( angles )
	ball.SetModelScale( 1.0 )
	ball.kv.massScale = 1.0
	ball.kv.inertiaScale = 1.0
	ball.kv.gravity = 1
	ball.kv.solid = SOLID_VPHYSICS
	ball.SetScriptName( WRECKING_BALL_BALL_SCRIPT_NAME )
	ball.RemoveFromAllRealms()
	ball.AddToOtherEntitysRealms( owner )
	ball.SetForceVisibleInPhaseShift( true )
	SetTeam( ball, owner.GetTeam() )
	DispatchSpawn( ball )

	if ( IsValid( owner ) )
	{
		AddToUltimateRealm( owner, ball )
	}

	ball.e.spawnTime = projectile.e.spawnTime

	// reparenting he animating child of the projectile to the new physics prop
	bool foundAnimChld = false
	foreach ( child in GetChildren(projectile) )
	{
		if ( child.GetScriptName() != WRECKING_BALL_ANIMCHILD_SCRIPT_NAME )
			continue

		foundAnimChld = true
		child.SetParent( ball )
		child.SetLocalAngles( ball.GetLocalAngles() + <90, 0, 0> )
	}

	if ( foundAnimChld )
		ball.Hide()

	projectile.Destroy()

	return ball
}

void function WreckingBall_GetTheBallRolling( entity ball, vector dir )
{
	const bool DEBUG_TRACE 				= false
	const float CHECK_FOR_GROUND_DELAY 	= 0.1		// how often the ball will potentially bounce
	const float CHECK_FOR_IMPACT_DELAY 	= 0.8		// how often magnet pieces will spawn
	const float FIND_GROUND_Z_OFFSET	= 200.0		// how far down a trace will check to find the ground (to create an impact)
	const float FORWARD_TRACE_OFFSET	= 50.0		// how far forward speed-zone impacts will be created, and how far wall detection extends
	const float RIGHT_TRACE_OFFSET		= 50.0		// how far left/right the ball will check for obstacles when it can't move forward

	const float Z_BOUNCE_POWER_BASE		= 0.4
	const float Z_BOUNCE_POWER_SLOPE 	= 0.6
	const float Z_BOUNCE_POWER_WALL 	= 0.7

	const int CANNOT_MOVE_COUNT_MAX 	= 5			// count of how many cycles the ball can be considered "stuck" before exploding early

	//FOR BIGRIG TESTING - WreckingBall_SpawnRepulsorPropFromEntity values
	const float MAGNET_LAUNCH_FORWARD_FRAC 			= .5	// fraction angle of the launch forward (relative to the ball). Smaller values are more "forward", larger values are more "lateral"
	const float MAGNET_LAUNCH_UP_FRAC 				= -0.5	// fraction angle of the launch upward ( relative to the ball). Smaller values are more "level", larger values are more "vertical. Negative value is "down".
	const bool MAGNET_LAUNCH_DEBUG_DRAW 			= false	// show the launch position and vector of the magnets

	entity owner 				= ball.GetOwner()
	float endImpactDelayTime 	= Time()
	float endRollTime 			= endImpactDelayTime + file.balance_wreckingBallBallDuration
	file.ballEndProxyDetonateTime[ball] <- 0.0
	file.ballProxyDetonateTriggered[ball] <- false
	file.ballEmpDamagedList[ball] <- []
	file.ballEmpDestroyedList[ball] <- []
	vector angles 				= VectorToAngles( dir )
	float force 				= WRECKING_BALL_FORCE_TO_MOVE
	float traceRadius 			= WRECKING_BALL_TRACE_RADIUS
	int cannotMoveCount 		= 0


	float retriggerDelay 		= 0.0
	int hitCount 				= 0


	vector traceStart, groundTraceEnd, impactTraceEnd, forwardTraceEnd, upwardTraceEnd, targetDir
	bool switchProtoPieceDir = false
	entity potentialTrophy = null

#if DEVELOPER
	if ( DEBUG_PROP_COUNT )
		file.propCount = 0
#endif

	entity wreckingBallPing
	if ( file.pingWreckingBallOnCast )
	{
		wreckingBallPing = CreateWaypoint_Ping_Location( owner, ePingType.MAGGIE_WRECKING_BALL, null, ball.GetCenter(), -1, true )
		//wreckingBallPing.SetAbsOrigin( ball.GetCenter() + <0, 0, 60> )
		wreckingBallPing.SetParent( ball, "", true )
	}
	// "piece launcher"
	entity pieceWeapon = VerifyBombardmentWeapon( owner, "mp_ability_rolling_thunder_piece" )
	if ( !IsValid( pieceWeapon ) )
		return

	dir = Normalize( dir )

	// detection radius'
	// TODO: Remove Radius FX when we get better solution for showing radius during initial targeting of the ball, only show to Maggie player

	entity radiusFxEnt

	if ( !( ball in file.isBallOnFire ) )
		file.isBallOnFire[ ball ] <- false

	radiusFxEnt = StartParticleEffectOnEntity_ReturnEntity( ball, GetParticleSystemIndex( WRECKING_BALL_RADIUS_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	EffectSetControlPointVector( radiusFxEnt, 1, <WRECKING_BALL_PLAYER_PROXIMITY_DIST - 25.0, 0, 0> ) //distance of this temp FX is slightly off, -25.0 for correction
	EffectSetControlPointVector( radiusFxEnt, 2, <255, 0, 0> )
	SetTeam( radiusFxEnt, ball.GetTeam() )
	radiusFxEnt.SetOwner( owner )
	radiusFxEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY | ENTITY_VISIBLE_TO_OWNER
	radiusFxEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE

	// threat indicator
	entity threatIndicator = CreateThreatIndicator( ball.GetCenter() , eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, WRECKING_BALL_FINAL_EXPLOSION_RADIUS + 100.0 )
	threatIndicator.RemoveFromAllRealms()
	threatIndicator.AddToOtherEntitysRealms( ball )
	threatIndicator.SetParent( ball )

	OnThreadEnd(
		function() : ( ball, owner, radiusFxEnt )
		{
			if ( ball in file.ballEndProxyDetonateTime )
				delete file.ballEndProxyDetonateTime[ball]

			if ( ball in file.ballProxyDetonateTriggered )
				delete file.ballProxyDetonateTriggered[ball]

			if ( ball in file.ballEmpDamagedList )
				delete file.ballEmpDamagedList[ball]

			if ( ball in file.ballEmpDestroyedList )
				delete file.ballEmpDestroyedList[ball]

			if ( file.balance_wreckingBallPauseRegen && IsValid( owner ) )
			{
				entity weapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
				if ( IsValid( weapon ) && weapon.HasMod( "survival_ammo_regen_paused" ) )
					weapon.RemoveMod( "survival_ammo_regen_paused" )
			}

			if ( IsValid( radiusFxEnt ) )
				radiusFxEnt.Destroy()

			if ( IsValid( ball ) )
			{

					if ( ball in file.isBallOnFire )
						delete file.isBallOnFire[ ball ]

				ball.Destroy()
			}


				file.hasBeenHit.clear()

		}
	)

	vector ballPosLastFrame = ball.GetCenter()

	 table<entity, entity > scannedPlayerToWaypoints
		int team = owner.GetTeam()

		OnThreadEnd(
			function () : ( scannedPlayerToWaypoints, team, owner )
			{
				foreach( entity player, wp in scannedPlayerToWaypoints )
				{
					if( IsValid( wp ) )
						wp.Destroy()
				}
			}
		)
		float startTime = Time()



	// Initial velocity - let physics handle everything
	vector forwardDir = Normalize( <dir.x, dir.y, 0> )
	ball.SetVelocity( forwardDir * 800 + <0,0,300> )

	while ( IsValid( ball ) && ( Time() < endRollTime ) )
	{
		wait CHECK_FOR_GROUND_DELAY

		vector currentPos = ball.GetOrigin()

		// Check for walls and redirect if needed
		vector targetPos = currentPos + (dir * 100)
		TraceResults wallTrace = TraceHull( currentPos + <0,0,16>, targetPos + <0,0,16>, <-16,-16,0>, <16,16,32>, [ball], TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NONE )

		if ( wallTrace.fraction < 1.0 )
		{
			vector normal = wallTrace.surfaceNormal
			dir = dir - 2.0 * DotProduct( dir, normal ) * normal
			dir = Normalize( <dir.x, dir.y, 0> )
		}

		// Only add velocity if moving too slow
		vector currentVel = ball.GetVelocity()
		if ( Length( currentVel ) < 400 )
		{
			forwardDir = Normalize( <dir.x, dir.y, 0> )
			ball.SetVelocity( forwardDir * 600 + <0,0,150> )
		}

		if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_maggie_ball_scan
		{
			array< entity > nearbyPlayers = GetNearbyPlayers( ball.GetOrigin(), file.balance_wreckingBallUpgradeScanDist )
			array< entity > newPlayers
			array< entity > removedPlayers

			foreach( scannedPlayer, wp in scannedPlayerToWaypoints )
			{
				if( !nearbyPlayers.contains( scannedPlayer ) )
					removedPlayers.append( scannedPlayer )
			}

			foreach( nearbyPlayer in nearbyPlayers )
			{
				if( !( nearbyPlayer in scannedPlayerToWaypoints ) )
					newPlayers.append( nearbyPlayer )
			}

			foreach( toRemove in removedPlayers )
			{
				entity wp = scannedPlayerToWaypoints[toRemove]
				if( IsValid( wp ) )
					wp.Destroy()
				delete scannedPlayerToWaypoints[toRemove]
			}

			foreach( toAdd in newPlayers )
			{
				//entity wp = CreateWaypoint_TrackEnt( toAdd, "",  $"rui/hud/poi_icons/poi_madmaggie_ult_deploy", <0, 0, 50> )
				//wp.SetParent( toAdd )
				//wp.SetOwner( owner )
				//scannedPlayerToWaypoints[toAdd] <- wp
				PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_superReconBall", 4.0, 4.0 )
			}
		}

		if( !file.isBallOnFire[ ball ] && Time() > ( startTime + file.balance_wreckingBallFireChargeTime ) && PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_maggie_thermite_explosion
		{
			entity fullburn = StartParticleEffectInWorld_ReturnEntity( file.fireFxId, ball.GetOrigin(), <0,0,0> )
			EffectSetControlPointEntity( fullburn, 1, ball )
			fullburn.SetParent( ball )
			EmitSoundOnEntity( ball, SOUND_WRECKING_BALL_UPGRADE_IGNITE )
			file.isBallOnFire[ ball ] = true
		}


		float distanceFromLastFrame = Distance( ball.GetCenter(), ballPosLastFrame )

		#if DEVELOPER
		if ( DEBUG_EMP_DAMAGE_DESTRUCTION )
		{
			DebugDrawArrow( ballPosLastFrame, ball.GetCenter(), 10, 0, 0, 255, true, 0.5 )
		}
		#endif

		array<entity> destroyDevices = GetNearbyWreckingBallDestroyDeviceArray( ball, ( WRECKING_BALL_DESTORY_DEVICE_RANGE * 4.0) + distanceFromLastFrame )
		foreach ( device in destroyDevices )
		{
			if ( file.ballEmpDestroyedList[ball].contains( device ) )
				continue

			if ( IsFriendlyTeam( device.GetTeam(), ball.GetTeam() ) )
				continue

			vector deviceProjectedPosition = GetClosestPointOnLineSegment( ball.GetCenter(), ballPosLastFrame, device.GetOrigin() )
			float distanceToProjection = Distance( deviceProjectedPosition, device.GetOrigin() )

			#if DEVELOPER
			if ( DEBUG_EMP_DAMAGE_DESTRUCTION )
			{
				vector debugLineColor = ( distanceToProjection > WRECKING_BALL_DAMAGE_DEVICE_RANGE ) ? <255, 165, 0> : <0, 255, 0>
				DebugDrawLine( device.GetOrigin(), deviceProjectedPosition, debugLineColor.x, debugLineColor.y, debugLineColor.z, true, 0.1 )
				DebugDrawText( device.GetOrigin(), "DistToBall: " + distanceToProjection, true, 0.1 )
			}
			#endif

			if ( distanceToProjection > WRECKING_BALL_DESTORY_DEVICE_RANGE * 4.0 )
				continue


			//file.ballProxyDetonateTriggered[ball] = true
			file.ballEmpDestroyedList[ball].append( device )




			file.ballEndProxyDetonateTime[ball] = 0
			EmitSoundOnEntity( ball, SOUND_WRECKING_BALL_WARNING_SOUND )

			device.Signal( "EMP_Destroy", { owner = owner, source = ball } )
		}

		array<entity> damagedDevices = GetNearbyWreckingBallDamageDeviceArray( ball, ( WRECKING_BALL_DAMAGE_DEVICE_RANGE * 2 ) + distanceFromLastFrame )
		foreach ( device in damagedDevices )
		{
			//we can damage a device via proximity or collision ... need to guard against tripping both and doing double damage
			if ( file.ballEmpDamagedList[ball].contains( device ) )
				continue

			if ( IsFriendlyTeam( device.GetTeam(), ball.GetTeam() ) )
				continue

			vector deviceProjectedPosition = GetClosestPointOnLineSegment( ball.GetCenter(), ballPosLastFrame, device.GetOrigin() )
			float distanceToProjection = Distance( deviceProjectedPosition, device.GetOrigin() )

			#if DEVELOPER
			if ( DEBUG_EMP_DAMAGE_DESTRUCTION )
			{
				vector debugLineColor = ( distanceToProjection > WRECKING_BALL_DAMAGE_DEVICE_RANGE ) ? <255, 165, 0> : <0, 255, 0>
				DebugDrawLine( device.GetOrigin(), deviceProjectedPosition, debugLineColor.x, debugLineColor.y, debugLineColor.z, true, 0.1 )
				DebugDrawText( device.GetOrigin(), "DistToBall: " + distanceToProjection, true, 0.1 )
			}
			#endif

			if ( distanceToProjection > WRECKING_BALL_DAMAGE_DEVICE_RANGE )
				continue


				//file.ballProxyDetonateTriggered[ball] = true




			file.ballEndProxyDetonateTime[ball] = 0
			EmitSoundOnEntity( ball, SOUND_WRECKING_BALL_WARNING_SOUND )

			file.ballEmpDamagedList[ball].append( device )
			device.TakeDamage( 300, owner, ball, { damageSourceId = eDamageSourceId.damagedef_wrecking_ball } )

		}

		array<entity> ignoreArray
		if ( IsValid( ball ) )
			ignoreArray.append( ball )

		if ( file.balance_wreckingBallProximityDetonate )
		{

			if ( file.ballProxyDetonateTriggered[ball] && ( Time() > retriggerDelay ) )
			{
				StopSoundOnEntity( ball, SOUND_WRECKING_BALL_WARNING_SOUND )

				if ( hitCount < 1 )
				{
					file.ballProxyDetonateTriggered[ball] = false
					CreateExplosion( ball, owner )
				}
				else
					break

				retriggerDelay = Time() + RETRIGGER_DELAY
				hitCount = hitCount + 1
			}
			else if ( !file.ballProxyDetonateTriggered[ball] && WreckingBall_CheckForNearbyEnemies( ball, ballPosLastFrame,ignoreArray ) && ( Time() > retriggerDelay ) )
			{
				file.ballProxyDetonateTriggered[ball] = true
				EmitSoundOnEntity( ball, SOUND_WRECKING_BALL_WARNING_SOUND )
			}
		}

		if ( ( Time() >= endImpactDelayTime ) )
		{
			vector pieceThrowDir = ball.GetVelocity()
			pieceThrowDir = Normalize( < pieceThrowDir.x, pieceThrowDir.y, 0.0 > ) //< pieceThrowDir.x, pieceThrowDir.y, 0 >

			vector lateralDir
			if ( switchProtoPieceDir )
				lateralDir = < pieceThrowDir.y * MAGNET_LAUNCH_FORWARD_FRAC, -pieceThrowDir.x * MAGNET_LAUNCH_FORWARD_FRAC, MAGNET_LAUNCH_UP_FRAC >
			else
				lateralDir = < -pieceThrowDir.y * MAGNET_LAUNCH_FORWARD_FRAC, pieceThrowDir.x * MAGNET_LAUNCH_FORWARD_FRAC, MAGNET_LAUNCH_UP_FRAC >

			thread WreckingBall_SpawnRepulsorPropFromEntity( ball, pieceThrowDir + lateralDir, MAGNET_LAUNCH_DEBUG_DRAW )

			// Really dislike adding Bloodhound POIs for the ball path, partially because it's already indicated by the ball pieces, partially because player footprints are more important, mostly because it's just a mess
			//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_MAGGIE_WRECKING_BALL_PATH, ball, OriginToGround( ball.GetOrigin(), TRACE_MASK_NPCSOLID, ball ), ball.GetTeam(), ball )

			switchProtoPieceDir = !switchProtoPieceDir

			endImpactDelayTime = Time() + CHECK_FOR_IMPACT_DELAY
		}

		ballPosLastFrame = ball.GetCenter()

		wait CHECK_FOR_GROUND_DELAY
	}

	// not a part of the ThreadEnd function because we don't want the explosion going off if the function ends early
	if ( IsValid( ball ) )
	{

		WreckingBall_CreateFinalExplosion( ball, false )






			if( IsValid( owner ) && file.isBallOnFire[ ball ] )
			{
				BurnDamageSettings burnSettings
				burnSettings.damageSourceID 		= eDamageSourceId.mp_weapon_thermite_grenade
				burnSettings.preburnDuration 		= 0.5
				burnSettings.burnDuration 			= 8.0
				burnSettings.burnDamage 			= 25
				burnSettings.burnTime 				= 2.8
				burnSettings.burnTickRate 			= 1.2
				burnSettings.burnDamageRadius 		= 40.0
				burnSettings.burnDamageHeight 		= 48.0
				burnSettings.soundBurnSegmentStart 	= "thermitegrenade_flamewall_flame_burn_front"
				burnSettings.soundBurnSegmentMiddle = "thermitegrenade_flamewall_flame_burn_middle"
				burnSettings.soundBurnSegmentEnd 	= "thermitegrenade_flamewall_flame_burn_front" // intentionally using front for the end because we are skipping the front and the end has all the real audio
				burnSettings.soundBurnDamageTick_1P = ""
				burnSettings.burnStackDebounce 		= .7
				burnSettings.burnStacksMax 			= 8
				burnSettings.segmentSpacingDist 	= 80.0
				vector lateralVelocity = ball.GetVelocity()
				lateralVelocity.z = 0
				lateralVelocity = Normalize( lateralVelocity )
				vector upVector = ball.GetUpVector()
				vector vectorSpreadDirRight = VectorRotateAxis( lateralVelocity, <0,0,1>, 45 )
				vector vectorSpreadDirLeft = VectorRotateAxis( lateralVelocity, <0,0,1>, -45 )

				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), vectorSpreadDirRight, 4, true, burnSettings )
				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), -vectorSpreadDirRight, 4, true, burnSettings )
				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), vectorSpreadDirLeft, 4, true, burnSettings )
				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), -vectorSpreadDirLeft, 4, true, burnSettings )
			}

	}
}

void function BeginProjectileFire( entity projectile, entity owner, entity inflictor, entity hitEnt, vector pos, vector dir, int numSegments, bool skipFirstStep, BurnDamageSettings burnSettings )
{
	Assert( IsValid( owner ) )
	Assert( IsValid( inflictor ) )

	owner.EndSignal( "OnDestroy" )

	array<SegmentData> segmentsArray = CreateSpreadPattern( owner, inflictor, pos, dir, numSegments, burnSettings )
	// don't try to use an empty array
	if ( segmentsArray.len() == 0 )
		return

	if ( skipFirstStep )
		segmentsArray.remove( 0 )
	waitthread BurnSequence( owner, inflictor, segmentsArray, burnSettings )
}


array<entity> function GetNearbyPlayers( vector pos, float maxDist )
{
	array<entity> players = GetPlayerArray()
	array<entity> nearbyPlayers
	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			continue
		if ( Distance( pos, player.GetOrigin() ) > maxDist )
			continue
		nearbyPlayers.append( player )
	}

	return nearbyPlayers
}


void function CreateExplosion( entity ball, entity owner, bool IsFirstHit = false )
{
	if ( IsValid( ball ) )
	{
		WreckingBall_CreateFinalExplosion( ball, IsFirstHit )



			if( IsValid( owner ) && file.isBallOnFire[ ball ] )
			{
				BurnDamageSettings burnSettings
				burnSettings.damageSourceID 		= eDamageSourceId.mp_weapon_thermite_grenade
				burnSettings.preburnDuration 		= 0.5
				burnSettings.burnDuration 			= 8.0
				burnSettings.burnDamage 			= 25
				burnSettings.burnTime 				= 2.8
				burnSettings.burnTickRate 			= 1.2
				burnSettings.burnDamageRadius 		= 40.0
				burnSettings.burnDamageHeight 		= 48.0
				burnSettings.soundBurnSegmentStart 	= "thermitegrenade_flamewall_flame_burn_front"
				burnSettings.soundBurnSegmentMiddle = "thermitegrenade_flamewall_flame_burn_middle"
				burnSettings.soundBurnSegmentEnd 	= "thermitegrenade_flamewall_flame_burn_front" // intentionally using front for the end because we are skipping the front and the end has all the real audio
				burnSettings.soundBurnDamageTick_1P = ""
				burnSettings.burnStackDebounce 		= .7
				burnSettings.burnStacksMax 			= 8
				burnSettings.segmentSpacingDist 	= 80.0
				vector lateralVelocity = ball.GetVelocity()
				lateralVelocity.z = 0
				lateralVelocity = Normalize( lateralVelocity )
				vector upVector = ball.GetUpVector()
				vector vectorSpreadDirRight = VectorRotateAxis( lateralVelocity, <0,0,1>, 45 )
				vector vectorSpreadDirLeft = VectorRotateAxis( lateralVelocity, <0,0,1>, -45 )

				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), vectorSpreadDirRight, 4, true, burnSettings )
				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), -vectorSpreadDirRight, 4, true, burnSettings )
				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), vectorSpreadDirLeft, 4, true, burnSettings )
				thread BeginProjectileFire( ball, owner, owner, null, ball.GetOrigin(), -vectorSpreadDirLeft, 4, true, burnSettings )
			}

	}
}


array<entity> function GetNearbyWreckingBallDestroyDeviceArray( entity ball, float checkRange )
{
	return GetScriptManagedEntArrayWithinCenter( file.wreckingBallDestroyArrayID, TEAM_ANY, ball.GetCenter(), checkRange )
}

array<entity> function GetNearbyWreckingBallDamageDeviceArray( entity ball, float checkRange )
{
	return GetScriptManagedEntArrayWithinCenter( file.wreckingBallDamageArrayID, TEAM_ANY, ball.GetCenter(), checkRange )
}

void function AddWreckingBallEMPDestroyDevice( entity ball )
{
	AddToScriptManagedEntArray( file.wreckingBallDestroyArrayID, ball )
}

void function AddWreckingBallEMPDamageDevice( entity device )
{
	AddToScriptManagedEntArray( file.wreckingBallDamageArrayID, device )
}

//////////////////////////////////////////
////// IMPACT EXPLOSION FUNCTIONS ////////
//////////////////////////////////////////

void function WreckingBall_CreateImpact( entity projectile, vector pos, vector angles, entity hitEnt )
{
	entity owner = projectile.GetOwner()

	if ( file.fxOption_playTempFX )

		if( projectile in file.isBallOnFire && file.isBallOnFire[ projectile ] ) // upgrade_maggie_thermite_explosion
			StartParticleEffectInWorld( GetParticleSystemIndex( WRECKING_BALL_GROUND_IMPACT_SMALL_FX_UPGRADE ), pos, angles )
		else

			StartParticleEffectInWorld( GetParticleSystemIndex( WRECKING_BALL_GROUND_IMPACT_SMALL_FX ), pos, angles )
}

bool function WreckingBall_CheckForNearbyEnemies( entity ball, vector ballPosLastFrame, array<entity> ignoreArray )
{
	vector enemyDetectionOriginOffset = <0.0, 0.0, WRECKING_BALL_TRACE_RADIUS>
	vector ballPos = ball.GetOrigin() + enemyDetectionOriginOffset

	float distanceFromLastFrame = Distance( ball.GetCenter(), ballPosLastFrame )

	array<entity> enemyPlayersNearby = WreckingBall_GetNearbyEnemiesToBall( ball, ballPos, ( WRECKING_BALL_PLAYER_PROXIMITY_DIST * 2 ) + distanceFromLastFrame )

	foreach( enemy in enemyPlayersNearby )
	{
		vector enemyProjectedPosition = GetClosestPointOnLineSegment( ball.GetCenter(), ballPosLastFrame, enemy.GetOrigin() )
		entity enemyParent = enemy.GetParent()

		if ( Distance( enemy.GetOrigin(), enemyProjectedPosition ) > WRECKING_BALL_PLAYER_PROXIMITY_DIST )
			continue

		if ( IsValid( enemyParent ) )
		{
			vector enemyParentProjectedPosition = GetClosestPointOnLineSegment( ball.GetCenter(), ballPosLastFrame, enemyParent.GetOrigin() )

			if ( Distance( enemyParent.GetOrigin(), enemyParentProjectedPosition ) > WRECKING_BALL_PLAYER_PROXIMITY_DIST )
				continue
		}

		TraceResults traceToEnemy = TraceLine( ballPos,  enemy.GetOrigin() + enemyDetectionOriginOffset, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( traceToEnemy.hitEnt == enemy )
			return true

		if ( IsValid( enemyParent ) && ( traceToEnemy.hitEnt == enemyParent ) )
			return true

		if ( traceToEnemy.fraction >= 0.95 )
			return true
	}

	return false
}

void function WreckingBall_CreateFinalExplosion( entity ball, bool isFirstHit )
{
	vector explosionPos = ball.GetCenter()
	entity owner = ball.GetOwner()

	if ( !IsValid ( owner ) )
		Warning ( "Mad Maggie ball owner is invalid! Damage effects and final magnets not created!" )

	vector explosionDir = ball.GetVelocity()
	explosionDir = VectorToAngles( Normalize( < explosionDir.x, explosionDir.y, 0.0 > ) )
	Warning ( "Maggie ball exploded" )
	StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( WRECKING_BALL_FINAL_EXPLODE_FX ), explosionPos, explosionDir  )

	if ( file.fxOption_playTempSound )
	{

		if ( ball in file.isBallOnFire && file.isBallOnFire[ ball ] ) // upgrade_maggie_thermite_explosion
		{
			EmitSoundAtPosition( TEAM_ANY, explosionPos, SOUND_WRECKING_BALL_UPGRADE_FINAL, ball )
			EmitSoundAtPosition( TEAM_ANY, explosionPos, "thermitegrenade_flamewall_flame_burn_front", ball )
		}
		else

			EmitSoundAtPosition( TEAM_ANY, explosionPos, SOUND_WRECKING_BALL_FINAL, ball )
	}

	Explosion_DamageDefSimple( eDamageSourceId.damagedef_wrecking_ball, explosionPos, owner, ball, explosionPos )
	entity shake = CreateShake( explosionPos, 16, 140, 0.25, 800 )
	shake.RemoveFromAllRealms()
	shake.AddToOtherEntitysRealms( ball )

	vector pieceThrowDir = ball.GetVelocity()
	pieceThrowDir = Normalize( < pieceThrowDir.x, pieceThrowDir.y, 0 > )


	if( !isFirstHit )
	{
		thread WreckingBall_SpawnRepulsorPropFromEntity( ball, pieceThrowDir + < pieceThrowDir.y, -pieceThrowDir.x, 0 > )
		thread WreckingBall_SpawnRepulsorPropFromEntity( ball, pieceThrowDir + < -pieceThrowDir.y, pieceThrowDir.x, 0 > )
	}




}

//////////////////////////////////////////
////// SPEED TRIGGER WAKE FUNCTIONS //////
//////////////////////////////////////////

void function WreckingBall_CreateSpeedTrigger( entity owner, vector position, vector angles, entity hostEnt )
{
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( owner )
	trigger.SetRadius( WRECKING_BALL_SPEED_TRIGGER_RADIUS )
	trigger.SetAboveHeight( WRECKING_BALL_SPEED_TRIGGER_HEIGHT )
	trigger.SetBelowHeight( 0.0 )
	trigger.SetOrigin( position )
	trigger.SetAngles( angles )
	trigger.SetEnterCallback( WreckingBall_OnTriggerEnter )
	trigger.SetLeaveCallback( WreckingBall_OnTriggerLeave )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 1
	trigger.kv.triggerFilterTeamOther = 1 // this is key for survival
	trigger.SetScriptName( WRECKING_BALL_SPEEDTRIGGER_SCRIPT_NAME )
	trigger.RemoveFromAllRealms()

	if ( IsValid( hostEnt ) && !hostEnt.IsWorld() )
	{
		trigger.AddToOtherEntitysRealms( hostEnt )
		trigger.SetParent( hostEnt )
	}
	DispatchSpawn( trigger )
	trigger.SearchForNewTouchingEntity()

	EndSignal( trigger, "OnDestroy", "WreckingBall_SpeedZoneCleanup" )
	EndSignal( hostEnt, "OnDeath", "OnDestroy", "WreckingBall_SpeedZoneCleanup" )

	OnThreadEnd(
		function () : ( trigger )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)

	//if ( file.balance_wreckingBallWakeDuration > 0.0 )
	//	wait file.balance_wreckingBallWakeDuration
	//else

	WaitForever()
}

void function WreckingBall_OnTriggerEnter( entity trigger, entity ent )
{
	if( !WreckingBall_ValidateEntityInWake( trigger, ent ) )
		return

	if ( !(ent in file.entitiesTouchingSpeedTriggers) )
	{
		WakeInfo wi
		file.entitiesTouchingSpeedTriggers[ ent ] <- wi
		thread WreckingBall_BoostDistanceTraveled_Think( trigger.GetOwner(), ent )
	}

	if ( file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers <= 0 )
	{
		//resets the HUD presentation, if running in/out of the wake
		Remote_CallFunction_Replay( ent, "ServerCallback_RT_CleanupSpeedupHudForPlayer" )

		if ( !StatusEffect_HasSeverity( ent, eStatusEffect.speed_boost ) )
		{
			EmitSoundOnEntityOnlyToPlayer( ent, ent, SOUND_SPEED_BOOST_ACTIVE_1P )
			EmitSoundOnEntityExceptToPlayer( ent, ent, SOUND_SPEED_BOOST_ACTIVE_3P )
			EmitSoundOnEntityOnlyToPlayer( ent, ent, SOUND_SPEED_BOOST_LOOP_1P )
		}
		else
		{
			EmitSoundOnEntityOnlyToPlayer( ent, ent, SOUND_SPEED_BOOST_REACTIVE_1P )
			EmitSoundOnEntityExceptToPlayer( ent, ent, SOUND_SPEED_BOOST_REACTIVE_3P )
		}

		//endless status effect while in the speed zone trigger
		int handle = StatusEffect_AddEndless( ent, eStatusEffect.speed_boost, WRECKING_BALL_WAKE_BUFF_SEVERITY )
		file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers += 1
		file.entitiesTouchingSpeedTriggers[ ent ].statusEffectHandles.append( handle )

		Signal( ent, "WreckingBall_EnteredSpeedZone" )

		thread WreckingBall_InWakeThink( ent, handle, ( !StatusEffect_HasSeverity( ent, eStatusEffect.stim_visual_effect ) && !ent.IsPhaseShifted() ) )
	}
	else if ( file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers > 0 )
	{
		file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers += 1
	}
}

void function WreckingBall_OnTriggerLeave( entity trigger, entity ent )
{
	if ( IsValid( ent ) && (ent in file.entitiesTouchingSpeedTriggers) && (file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers > 0) )
	{
		file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers -= 1

		if ( file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers  <= 0 )
			Signal( ent, "WreckingBall_LeftSpeedZone" )
	}
}

/*
void function WreckingBall_SpeedBoost_Think( entity player, int statusEffectHandle )
{
	while ( (player in file.entitiesTouchingSpeedTriggers) && file.entitiesTouchingSpeedTriggers[ player ].touchingTriggers <= 0 )
	{

	}
}
*/

void function WreckingBall_InWakeThink( entity player, int statusEffectHandle, bool createFX = true )
{
	EndSignal( player, "WreckingBall_LeftSpeedZone", "OnDeath", "OnDestroy" )

	//TODO: in the event of Octane stim, -don't- add fx per BigRig
	if ( !IsValid( file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p ) && createFX )
	{
		if ( !IsValid( file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p ) )
		{
			WreckingBall_CreateSpeedupFX( player )
			Remote_CallFunction_Replay( player, "ServerCallback_RT_SpeedupHudForPlayer", eStatusEffect.speed_boost )
		}
		else
		{
			thread UpdateSpeedupFXColor_Thread( player, file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p )
		}
	}

	OnThreadEnd(
		function () : ( player, statusEffectHandle )
		{
			if ( IsValid( player ) )
			{
				// timed status effect for a little while after leaving the trigger
				StatusEffect_Stop( player, statusEffectHandle )
				StatusEffect_AddTimed( player, eStatusEffect.speed_boost, WRECKING_BALL_WAKE_BUFF_SEVERITY, file.balance_wreckingBallWakeBuffDuration, 0.25 )

				if ( IsValid( player ) )
					thread WreckingBall_PostWakeThink( player )
			}
		}
	)

	// update ground friction on the player depending on whether they're sliding or not
	const float WRECKING_BALL_WAKE_FRICTION_LOW	= -0.50
	const float WRECKING_BALL_WAKE_FRICTION_MID	= 0.75
	while( true )
	{
		if ( player.IsSliding() && (player.GetGroundFrictionScale() > WRECKING_BALL_WAKE_FRICTION_LOW) )
			player.SetGroundFrictionScale( WRECKING_BALL_WAKE_FRICTION_LOW )
		else if ( !player.IsSliding() && (player.GetGroundFrictionScale() <= WRECKING_BALL_WAKE_FRICTION_LOW) )
			player.SetGroundFrictionScale( WRECKING_BALL_WAKE_FRICTION_MID )

		bool stimVisActive = StatusEffect_HasSeverity( player, eStatusEffect.stim_visual_effect )
		bool isPlayerPhaseShifted = player.IsPhaseShifted()

		if ( !stimVisActive && !isPlayerPhaseShifted )
		{
			if ( !IsValid( file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p ) )
				WreckingBall_CreateSpeedupFX( player )
			Remote_CallFunction_Replay( player, "ServerCallback_RT_SpeedupHudForPlayer", eStatusEffect.speed_boost )
		}
		else if ( IsValid( file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p ) && ( stimVisActive || isPlayerPhaseShifted ) )
		{
			if ( IsValid( file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p ) )
				thread MaggieCommon_CleanUpFX( file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p, 0.0 )
		}
		WaitFrame()
	}
}

void function WreckingBall_CreateSpeedupFX( entity player )
{
	entity speedupFX = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( FX_SPEED_BOOST_ACTIVE ),
		FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	EffectSetControlPointVector( speedupFX, 1, COLOR_SPEEDBOOST_START )
	speedupFX.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
	speedupFX.SetOwner( player )
	file.entitiesTouchingSpeedTriggers[ player ].fxHandle_3p = speedupFX
}

void function WreckingBall_PostWakeThink( entity ent )
{
	// covers "leaving" the wake for character-swap cases
	if ( IsValid( ent ) && ( !IsAlive( ent ) || ent.IsPhaseShifted() ) )
	{
		WreckingBall_EndSpeedupEffects( ent )
		return
	}
	EndSignal( ent, "WreckingBall_EnteredSpeedZone", "WreckingBall_CleanupFX", "OnDeath", "OnDestroy" )

	const float WRECKING_BALL_WAKE_FRICTION_POST = 0.75

	if ( IsValid( file.entitiesTouchingSpeedTriggers[ ent ].fxHandle_3p ) )
		thread UpdateSpeedupFXColor_Thread( ent, file.entitiesTouchingSpeedTriggers[ ent ].fxHandle_3p )

	if ( file.balance_wreckingBallSlipSlide )
		ent.SetGroundFrictionScale( WRECKING_BALL_WAKE_FRICTION_POST )

	OnThreadEnd(
		function () : ( ent )
		{
			if ( IsValid( ent ) && (ent in file.entitiesTouchingSpeedTriggers ) && file.entitiesTouchingSpeedTriggers[ ent ].touchingTriggers <= 0 )
				WreckingBall_EndSpeedupEffects( ent )
			else // we've entered a new zone
				StopSoundOnEntity( ent, SOUND_SPEED_BOOST_END )
		}
	)

	// akalmbach - could put wind-down sound option here
	EmitSoundOnEntityOnlyToPlayer( ent, ent, SOUND_SPEED_BOOST_END )

	wait file.balance_wreckingBallWakeBuffDuration
}

void function WreckingBall_EndSpeedupEffects( entity ent )
{
	if ( IsValid( file.entitiesTouchingSpeedTriggers[ ent ].fxHandle_3p ) )
		thread MaggieCommon_CleanUpFX( file.entitiesTouchingSpeedTriggers[ ent ].fxHandle_3p, 0.0 )

	if ( file.balance_wreckingBallSlipSlide )
		ent.SetGroundFrictionScale( 1.0 )

	// akalmbach - immediate end sound option goes here
	//EmitSoundOnEntityOnlyToPlayer( ent, ent, SOUND_SPEED_BOOST_END )
	StopSoundOnEntity( ent, SOUND_SPEED_BOOST_LOOP_1P )
	delete file.entitiesTouchingSpeedTriggers[ ent ]
	Signal( ent, "WreckingBall_SpeedBoostEnd" )
}

bool function WreckingBall_ValidateEntityInWake( entity trigger, entity ent )
{
	if ( !IsValid( ent ) )
		return false

	if ( !ent.DoesShareRealms( trigger ) )
		return false

	if ( !ent.IsPlayer() )
		return false

	if ( ent.ContextAction_IsZipline() )
		return false

	return true
}

void function UpdateSpeedupFXColor_Thread( entity player, entity fxEnt )
{
	EndSignal( player, "OnDeath", "OnDestroy" )

	float timeLeft

	while ( IsValid( fxEnt ) )
	{
		timeLeft = StatusEffect_GetTimeRemaining( player, eStatusEffect.speed_boost )
		float frac = timeLeft / file.balance_wreckingBallWakeBuffDuration
		vector color = GetTriLerpColor( frac, COLOR_SPEEDBOOST_END, COLOR_SPEEDBOOST_MID, COLOR_SPEEDBOOST_START, 0.3, 0.15 )
		EffectSetControlPointVector( fxEnt, 1, color )

		WaitFrame()
	}
}

array<entity> function WreckingBall_GetNearbyEnemiesToBall( entity ball, vector ballPos, float distance )
{
	int ballTeam = ball.GetTeam()
	array<entity> confirmedList
	array<entity> playerResults = GetPlayerArrayEx( "any", TEAM_ANY, ballTeam, ballPos, distance )
	foreach ( entity ent in playerResults )
	{
		if(ShouldWreckingballHitEntity( ball, ent ))
		{
			confirmedList.append(ent)
		}
	}

	array<entity> nonPlayerResults = GetPlayerDecoyArray()
	nonPlayerResults.extend( GetNPCArrayEx( "any", TEAM_ANY, TEAM_ANY, ballPos, distance ) )

	foreach ( entity ent in nonPlayerResults )
	{
		if ( ShouldWreckingballHitEntity( ball, ent ) && !confirmedList.contains(ent) )
			confirmedList.append(ent)
	}

	return confirmedList
}

bool function ShouldWreckingballHitEntity( entity ball, entity ent )
{
	int ballTeam = ball.GetTeam()

	if ( !IsValid( ent ) || !IsValid( ball ) )
		return false
	else if (  !ent.DoesShareRealms( ball )
			|| ent.IsPhaseShifted()
			|| ent.IsCloaked( true )
			|| ( IsFriendlyTeam( ent.GetTeam(), ballTeam ) )
			|| ( ent.IsNPC() && ( ent.IsNonCombatAI() ) ) )
		return false
	else
		return true

	unreachable
}

// Physics prop method
void function WreckingBall_SpawnRepulsorPropFromEntity( entity ent, vector throwDir, bool debug = false )
{
	const float PIECE_THROW_HEIGHT_OFFSET 		= 10.0	// launch height (z) offset of the magnet puck (relative to the ball's center position)
	const float PIECE_THROW_LATERAL_OFFSET 		= 15.0	// launch lateral (x/y) offset of the magnet puck (relative to the ball's center position)
	const float PIECE_THROW_POWER				= 200	// base throw power
	const float PIECE_THROW_POWER_MOD_MIN 		= 0.75
	const float PIECE_THROW_POWER_MOD_MAX 		= 1.75
	const int PIECE_HEALTH						= 100

	vector throwOffset = <throwDir.x * PIECE_THROW_LATERAL_OFFSET, throwDir.y * PIECE_THROW_LATERAL_OFFSET, PIECE_THROW_HEIGHT_OFFSET>

	entity repulsorProp = CreatePropPhysics( WRECKING_BALL_PIECE_MODEL, ent.GetCenter() + throwOffset, <0,0,0>, SF_PHYSPROP_DEBRIS )
	//entity repulsorProp = CreatePropScript( WRECKING_BALL_PIECE_MODEL, ent.GetCenter() + throwOffset, <0,0,0>, 0 )
	repulsorProp.SetScriptName( WRECKING_BALL_MAGNET_SCRIPT_NAME )
	entity owner = ent.GetOwner()
	repulsorProp.NotSolid()
	repulsorProp.SetOwner( owner )
	repulsorProp.SetMaxHealth( PIECE_HEALTH )
	repulsorProp.SetHealth( PIECE_HEALTH )
	repulsorProp.SetDamageNotifications( true )
	repulsorProp.SetDeathNotifications( false )
	repulsorProp.RemoveFromAllRealms()
	repulsorProp.AddToOtherEntitysRealms( ent )
	repulsorProp.SetForceVisibleInPhaseShift( true )

	#if SERVER && DEVELOPER
		AddToScriptManagedEntArray( file.speedTriggerScriptManagedArray, repulsorProp )
	#endif

	float speed     = RandomFloatRange( PIECE_THROW_POWER_MOD_MIN, PIECE_THROW_POWER_MOD_MAX ) * PIECE_THROW_POWER
	vector vel      = throwDir * speed

	if ( IsValid( owner ) )
	{
		AddToUltimateRealm( owner, repulsorProp )
	}

	/*
	asset model       = repulsorProp.GetModelName()
	entity physicsEnt = CreatePropPhysics( model, repulsorProp.GetOrigin(), repulsorProp.GetAngles(), SF_PHYSPROP_DEBRIS )
	physicsEnt.kv.CollideWithOwner = false
	physicsEnt.NotSolid()
	physicsEnt.SetIgnoreCombatCharacters( true )
	physicsEnt.SetBlocksRadiusDamage( false )
	physicsEnt.SetScriptName( THROWN_OBJECT_PHYSICS_ENT_SCRIPTNAME )
	physicsEnt.Hide()
	physicsEnt.AllowMantle()
	physicsEnt.SetTakeDamageType( DAMAGE_NO )

	repulsorProp.SetParent( physicsEnt )
	*/

#if DEVELOPER
	if ( DEBUG_PROP_COUNT )
	{
		file.propCount ++
		printt( "Repulsor prop count: " + file.propCount )
	}

	if ( debug )
	{
		vector startPos = repulsorProp.GetCenter()
		DebugDrawSphere( ent.GetCenter(), 15.0, 255, 0, 0, false, 10.0 )
		DebugDrawSphere( startPos, 5.0, 0, 150, 255, false, 10.0 )
		DebugDrawLine( startPos, startPos + ( vel ), 0, 200, 0, true, 10.0 )
	}
#endif

	if ( file.fxOption_pieceHighlight )
	{
		SetSurvivalPropHighlight( repulsorProp, "sp_objective_outline", false ) //sp_interact_object //revealed_friendly //enemy_player_decoy
		Remote_CallFunction_Replay( owner, "ServerCallback_PrototypeManageHighlight", repulsorProp )
	}

	repulsorProp.SetVelocity( vel )
	repulsorProp.PhysicsSetDamping( 0.0, 100.0 )
	repulsorProp.e.lastAttacker = repulsorProp
	//thread PhysicsEntCleanup( physicsEnt, repulsorProp )

	thread WreckingBall_RepulsorProp_AirThink( repulsorProp )
	waitthread PhysicsEntDampOnFirstCollision( repulsorProp ) //physicsEnt
	Signal( repulsorProp, "WreckingBall_PieceHitGround")

	thread WreckingBall_RepulsorProp_GroundThink( ent, repulsorProp )
}

void function PhysicsEntDampOnFirstCollision( entity physicsEnt )
{
	Assert( IsValid( physicsEnt ) )
	EndSignal( physicsEnt, "OnDestroy" )
	WaitSignal( physicsEnt, "OnFirstCollision" )

	if ( IsValid( physicsEnt ) )
	{
		physicsEnt.PhysicsSetDamping( 1.0, 100.0 )
		physicsEnt.SetVelocity( <0,0,0> )
		PlayImpactFXTable( physicsEnt.GetOrigin(), physicsEnt, "mm_ball_pcs_initialimpact" )
	}
}

void function PhysicsEntCleanup( entity physicsEnt, entity drop )
{
	EndSignal( physicsEnt, "OnDestroy" )
	EndSignal( drop, "OnDestroy" )

	OnThreadEnd(
		function() : ( physicsEnt, drop )
		{
			if ( IsValid( physicsEnt ) )
				physicsEnt.Destroy()
		}
	)

	WaitSignal( physicsEnt, "OnDestroy" )
}


void function WreckingBall_RepulsorProp_AirThink( entity repulsorProp )
{
	EndSignal( repulsorProp, "OnDestroy", "WreckingBall_SpeedZoneCleanup", "WreckingBall_PieceHitGround" )

	thread WreckingBall_CreateSpeedTrigger( repulsorProp.GetOwner(), repulsorProp.GetOrigin(), repulsorProp.GetAngles(), repulsorProp )

	entity flyFX = StartParticleEffectOnEntity_ReturnEntity( repulsorProp, GetParticleSystemIndex( WRECKING_BALL_PIECE_FLYING_FX ),
		FX_PATTACH_POINT_FOLLOW, repulsorProp.LookupAttachment( "ORIGIN" ) )

	OnThreadEnd(
		function() : ( flyFX )
		{
			if ( IsValid( flyFX ) )
				flyFX.Destroy()
		}
	)

	WaitForever()
}

void function WreckingBall_RepulsorProp_GroundThink( entity ball, entity repulsorProp )
{
	if ( !IsValid( repulsorProp ) )
		return

	const float WRECKING_BALL_PIECE_IMPACTTABLEFX_REFIRE = 1.0
	const float WRECKING_BALL_PIECE_REPEAT_RADIUS = 80.0
	EndSignal( repulsorProp, "OnDestroy", "WreckingBall_SpeedZoneCleanup" )

	// Pucks damage/destroy other nearby pucks. In this way, an enclosed area doesn't get overloaded with unneeded pucks
	RadiusDamage(
		repulsorProp.GetOrigin(),
		repulsorProp.GetOwner(), //attacker
		repulsorProp, //inflictor
		1,
		1,
		WRECKING_BALL_PIECE_REPEAT_RADIUS, // inner radius
		WRECKING_BALL_PIECE_REPEAT_RADIUS, // outer radius
		SF_ENVEXPLOSION_INCLUDE_ENTITIES,
		0, // distanceFromAttacker
		0, // explosionForce
		DF_EXPLOSION,
		eDamageSourceId.mp_weapon_wrecking_ball_puck )


	entity attacker = repulsorProp.GetOwner()
	if ( !IsValid( attacker ) )
		return
	entity groundFxFire

	if ( !( ball in file.isBallOnFire ) )
		file.isBallOnFire[ ball ] <- false

	if ( ball in file.isBallOnFire && file.isBallOnFire[ ball ] ) // upgrade_maggie_thermite_explosion
	{
		groundFxFire = StartParticleEffectOnEntity_ReturnEntity( repulsorProp, GetParticleSystemIndex( WRECKING_BALL_PIECE_LOOP_FX_UPGRADE ),
			FX_PATTACH_POINT_FOLLOW, repulsorProp.LookupAttachment( "ORIGIN" ) )
	}


	entity groundFx = StartParticleEffectOnEntity_ReturnEntity( repulsorProp, GetParticleSystemIndex( WRECKING_BALL_PIECE_LOOP_FX ),
		FX_PATTACH_POINT_FOLLOW, repulsorProp.LookupAttachment( "ORIGIN" ) )

	thread MaggieCommon_ImpactTableFX_Think( repulsorProp, "mm_ball_pcs", WRECKING_BALL_PIECE_IMPACTTABLEFX_REFIRE, file.balance_wreckingBallWakeDuration )

	OnThreadEnd(
		function() : ( repulsorProp, groundFx )
		{
			if ( IsValid( groundFx ) )
				groundFx.Destroy()

			if ( IsValid( repulsorProp ) )
			{
				Signal( repulsorProp, "MaggieCommon_StopImpactTableFX" )
				repulsorProp.Destroy()
			}
		}
	)

	if ( file.balance_wreckingBallWakeDuration > 0.0 )
		wait file.balance_wreckingBallWakeDuration
	else
		WaitForever()
}

void function WreckingBall_BoostDistanceTraveled_Think( entity maggiePlayer, entity boostedPlayer )
{
	const float INCHES_PER_METER = 100 / 2.54
	EndSignal( boostedPlayer, "OnDestroy", "OnDeath", "WreckingBall_SpeedBoostEnd" )

	vector curPos = boostedPlayer.GetOrigin()
	while ( true )
	{
		Wait( 0.2 )

		if ( IsValid( boostedPlayer ) )
		{
			vector boostedPlayerOrigin = boostedPlayer.GetOrigin()
			int distance = int( RoundToNearestInt( Distance2D( curPos, boostedPlayerOrigin ) / INCHES_PER_METER ) )
			curPos = boostedPlayerOrigin
		}
		else
		{
			break
		}
	}
}
#endif //SERVER

#if CLIENT
void function ServerCallback_RT_SpeedupHudForPlayer( int statusEffect )
{
	entity player  = GetLocalViewPlayer()

	if ( !IsValid( player.GetCockpit() ) )
		return

	if ( file.fxHandle_1p != -1 )
		return

	int fxHandle   = StartParticleEffectOnEntity( player.GetCockpit(), GetParticleSystemIndex( FX_SPEED_BOOST_HUD ),
		FX_PATTACH_ABSORIGIN_FOLLOW, -1)
	EffectSetIsWithCockpit( fxHandle, true )
	file.fxHandle_1p = fxHandle

	thread WreckingBall_SpeedupHudThread( player, fxHandle, statusEffect )}

void function ServerCallback_RT_CleanupSpeedupHudForPlayer()
{
	Signal( GetLocalViewPlayer(), "WreckingBall_CleanupFX" )
}

void function ServerCallback_PrototypeManageHighlight( entity prop )
{
	if ( IsValid( prop ) )
		ManageHighlightEntity( prop )
}

void function WreckingBall_SpeedupHudThread( entity viewPlayer, int fxHandle, int statusEffect )
{
	EndSignal( viewPlayer, "OnDeath", "WreckingBall_CleanupFX" )

	OnThreadEnd(
		function() : ( viewPlayer, fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )

			if ( file.fxHandle_1p != -1 )
				file.fxHandle_1p = -1
		}
	)

	while ( StatusEffect_HasSeverity( viewPlayer, statusEffect ) )
		WaitFrame()
}
#endif //CLIENT

#if SERVER && DEVELOPER
void function DEV_ClearWreckingBallSpeedTriggers()
{
	array<entity> triggers = GetAllWreckingBallSpeedTriggers()
	foreach( entity trigger in triggers )
	{
		if( IsValid( trigger ) )
			trigger.Destroy()
	}
}

array<entity> function GetAllWreckingBallSpeedTriggers()
{
	return GetScriptManagedEntArray( file.speedTriggerScriptManagedArray )
}
#endif

#if SERVER
void function CodeCallback_WreckingBallImpact( entity ball, int impactType, vector pos, entity hitEnt )
{
	if( !IsValid( ball ) )
		return

	if ( IsValid( hitEnt ) )
	{
		#if DEVELOPER
		if ( DEBUG_BALL_COLLISION_CALLBACK )
		{
			var classname    = hitEnt.GetNetworkedClassName()
			string debugName = (classname != null) ? expect string( classname ) : hitEnt.GetCodeClassName()
			printt( FUNC_NAME() + " ball hit " + debugName )
		}
		#endif
		if ( hitEnt.IsPlayer() || hitEnt.IsPlayerDecoy()|| hitEnt.IsNPC() )
		{
			if ( ShouldWreckingballHitEntity( ball, hitEnt ) )
			{
				file.ballProxyDetonateTriggered[ball] = true
				file.ballEndProxyDetonateTime[ball] = 0 //This is a direct hit, not a proximity check, so don't have a delay time? //Time() + WRECKING_BALL_PROXY_DELAY
			}
		}

		array<entity> destroyDevices = GetNearbyWreckingBallDestroyDeviceArray( ball, WRECKING_BALL_EMP_DEVICE_COLLISION_CHECK_RANGE )

		if ( destroyDevices.contains( hitEnt ) && !file.ballEmpDestroyedList[ball].contains( hitEnt ) )
		{
			if ( !IsFriendlyTeam( hitEnt.GetTeam(), ball.GetTeam() ) )
			{
				file.ballProxyDetonateTriggered[ball] = true
				file.ballEndProxyDetonateTime[ball] = 0

				file.ballEmpDestroyedList[ball].append( hitEnt )
				hitEnt.Signal( "EMP_Destroy", { owner = ball.GetOwner(), source = ball } )
			}
		}

		array<entity> damagedDevices = GetNearbyWreckingBallDamageDeviceArray( ball, WRECKING_BALL_EMP_DEVICE_COLLISION_CHECK_RANGE )

		if ( damagedDevices.contains( hitEnt ) && !file.ballEmpDamagedList[ball].contains( hitEnt ) )
		{
			if ( !IsFriendlyTeam( hitEnt.GetTeam(), ball.GetTeam() ) )
			{
				file.ballProxyDetonateTriggered[ball] = true
				file.ballEndProxyDetonateTime[ball] = 0

				file.ballEmpDamagedList[ball].append( hitEnt )
				hitEnt.TakeDamage( 300, ball.GetOwner(), ball, { damageSourceId = eDamageSourceId.damagedef_wrecking_ball } )
			}
		}
	}

	PlayImpactFXTable( pos, ball.GetOwner(), "mm_ball_bounce" )
}

bool function CodeCallback_WreckingBallWallCheck( entity ball, entity hitEnt )
{
	bool damageEntity = ( IsCodeDoor( hitEnt ) )

	if ( damageEntity )
	{
		entity owner = ball.GetOwner()
		if ( IsValid(owner) )
		{
			hitEnt.TakeDamage( file.balance_wreckingBallDamageFinal, owner, ball,
				{ damageSourceId = eDamageSourceId.mp_weapon_riot_shield_impact,
					scriptType = ( DF_ELECTRICAL | DF_EXPLOSION | DF_GIB ),
					weapon = file.playerBallWeapons[ owner ]
				} )
		}
		return false
	}

	return true
}
#endif

#if CLIENT
void function WreckingBall_SetupProjectileKillreplay( entity ball )
{
	if ( ball.GetScriptName() != WRECKING_BALL_BALL_SCRIPT_NAME )
		return
}
#endif // #if CLIENT