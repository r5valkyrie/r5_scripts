global function MpWeaponDebuffZone_Init
global function OnWeaponTossReleaseAnimEvent_DebuffZone
global function OnWeaponTossPrep_DebuffZone
global function OnProjectileCollision_DebuffZone
global function OnWeaponToss_DebuffZone
global function OnWeaponDeactivate_DebuffZone
global function OnWeaponTossCancel_DebuffZone
global function DoesPlayerHaveOverheatDebuff
global function IsPlayerBeingTargetedByBallistic
global function DebuffZone_GetAllowableStickyEnts

#if CLIENT
global function OnClientAnimEvent_DebuffZone
global function CreateTargetingRui
global function DestroyTargetingRui
global function ServerCallback_CreateOverHeatIconRui
global function DebuffZone_GetOverheatDuration
#endif

int COCKPIT_DEBUFF_ZONE_SCREEN_FX
int COCKPIT_TACT_IDLE

const asset COCKPIT_DEBUFF_1P_SCREEN_FX = $"P_clbr_tac_screen_debuff"
const asset COCKPIT_TACT_IDLE_SCREEN_FX = $"P_clbr_tac_screen_idle"

const float MISSILE_HOMING_SPEED = 1500.0
const float MISSILE_NOTARGET_SPEED = 3000.0
const float MISSILE_LIFETIME = 5.0

const float BEST_TARGET_MAX_RANGE = 3000.0
const int BEST_TARGET_MAX_FOV = 5
const float BEST_TARGET_SHORT_DISTANCE = 120.0
const float BEST_TARGET_SHORT_DISTANCE_SQR = BEST_TARGET_SHORT_DISTANCE * BEST_TARGET_SHORT_DISTANCE
const float LOCKON_DELAY = 0.3

const int DEBUFF_ZONE_RADIUS = 150
const float AOE_TIMEOUT = 5.0
const float AOE_HIT_EFFECT_TIMER = 0.5
const float AOE_SPAWN_DELAY = 1.0
const float DEBUFF_AOE_DAMAGE = 10.0
const float DIRECT_HIT_BUFF_DURATION = 12.0

const float MAX_DEBUFF_OVERHEAT = 100.0
const int OVERHEAT_DAMAGE = 30
const float AMOUNT_BETWEEN_THRESHOLDS = 20.0
const int NUMBER_OF_THRESHOLDS = int( MAX_DEBUFF_OVERHEAT / AMOUNT_BETWEEN_THRESHOLDS )
const float LOCKON_TIMEOUT_DURATION = 4

const asset DEBUFF_WEAPON_EFFECT_1P = $"P_clbr_tac_wpn_overheat_idle"
const asset AOE_RADIUS_FX = $"P_clbr_tac_imp_aoe"
const asset AOE_UPGRADE_TIMER_FX = $"P_LU_Ballistic_tac_timer"
const asset AOE_IMPACT_FX = $"P_clbr_tac_imp_aoe_end"
const asset AOE_WARNING_FX = $"P_clbr_tac_imp"
const asset DEBUFF_EXPLOSION = $"P_clbr_tac_wpn_overheat_exp"
const asset DEBUFF_EXPLOSION_3P = $"P_clbr_tac_wpn_overheat_exp_3p"
const asset DEBUFF_OVERHEAT_LHAND = $"P_clbr_tac_hand_overheat"
                    
const asset AOE_ENDING_FX_UPGRADE = $"P_LU_Ballistic_tac_timer"
      

const asset DEBUFF_ZONE_HEART_MODEL = $"mdl/weapons/ballistic_pistol/w_ballistic_bullet.rmdl"
const asset OVERHEAT_DEBUFF_BODY_FX = $"P_clbr_tac_body_debuff_3p"

const asset LOCK_ON_INIT = $"P_clbr_tac_wpn_Lockon_init"
const asset LOCK_ON_MARKER = $"P_clbr_tac_wpn_Lockon"
const asset FX_TACTICAL_RANGE_INDICATOR = $"P_clbr_tac_distance_sensor"
const asset DEBUFF_ZONE_MUZZLE_FLASH_3P = $"P_clbr_tac_muzzleflash_3p"

const string HOMING_MISSILE_SFX_LOOP = "Ballistic_Tac_Projectile_3P"

const string MISSILE_FIRE_SCREEN_SHAKE = "ballistic_tact_screen_shake"
const float SHAKE_AMPLITUDE = 2.0
const float SHAKE_FREQUENCY = 10.0
const float SHAKE_DURATION = 0.2
const vector SHAKE_DIRECTION = < 0.0, 0.0, 1.0 >

                    
const string PROJECTILE_UPGRADED_TRIGGERED_AOE_SOUND = "Ballistic_Tac_Upgraded_AOE_Start_3P"
const string PROJECTILE_UPGRADED_TRIGGERED_AOE_SOUND_ENEMY = "Ballistic_Tac_Upgraded_AOE_Start_3P_Enemy"
      
const string PROJECTILE_WAITING_TO_TRIGGER_SOUND = "Ballistic_Tac_AOE_Electricity_3P"
const string PROJECTILE_TRIGGERED_AOE_SOUND = "Ballistic_Tac_AOE_Start_3P"
const string PROJECTILE_AOR_END_SOUND = "Ballistic_Tac_AOE_End_3P"
const string PROJECTILE_TRIGGERED_AOE_SOUND_ENEMY = "Ballistic_Tac_AOE_Start_3P_Enemy"
const string PROJECTILE_AOR_END_SOUND_ENEMY = "Ballistic_Tac_AOE_End_3P_Enemy"
const string PROJECTILE_DIRECT_IMPACT_ENEMY_3P = "Ballistic_Tac_Impact_Direct_Enemy_3P"
const string PROJECTILE_DIRECT_IMPACT_ENEMY_1P =  "Ballistic_Tac_Impact_Direct_Player_1P"
const string PROJECTILE_DIRECT_IMPACT_FRIENDLY_3P = "Ballistic_Tac_Impact_Direct_Friendly_3P"
const string OVERHEAT_HIGH_WARNING_1P = "Ballistic_Tac_Overheat_Warning_1P"
const string PLAYER_OVERHEATS_3P_ENEMY = "Ballistic_Tac_Overheat_3P_enemy"
const string PLAYER_OVERHEATS_3P_TEAM = "Ballistic_Tac_Overheat_3P"
const string BALLISTIC_LOCKED_ON_1P = "Ballistic_Tac_TargetLock_1p_to_3p"
const string TARGET_OF_BALLISTIC_LOCK_ON_1P = "Ballistic_Tac_TargetLock_3p_to_1p"
const string BALLISTIC_LOCKED_ON_LOST_1P = "Ballistic_Tac_TargetLock_1p_to_3p_Lost"
const string TARGET_OF_BALLISTIC_LOCK_ON_LOST_1P = "Ballistic_Tac_TargetLock_3p_to_1p_Lost"

const vector ZERO_THRESHOLD_COLOR = < 255, 100, 100 >
const vector FIRST_THRESHOLD_COLOR = < 255, 80, 100 >
const vector SECOND_THRESHOLD_COLOR = < 255, 60, 100 >
const vector THIRD_THRESHOLD_COLOR = < 255, 40, 100 >
const vector LAST_THRESHOLD_COLOR = < 255, 20, 100 >
const array<vector> THRESHOLD_COLORS = [ZERO_THRESHOLD_COLOR, FIRST_THRESHOLD_COLOR, SECOND_THRESHOLD_COLOR, THIRD_THRESHOLD_COLOR, LAST_THRESHOLD_COLOR]

const vector ZERO_THRESHOLD_ALPHA = < 0.3, 0, 0 >
const vector FIRST_THRESHOLD_ALPHA = < 0.6, 0, 0 >
const vector SECOND_THRESHOLD_ALPHA = < 0.8, 0, 0 >
const vector THIRD_THRESHOLD_ALPHA = < 0.9, 0, 0 >
const vector LAST_THRESHOLD_ALPHA = < 1, 0, 0 >
const array<vector> THRESHOLD_ALPHA = [ZERO_THRESHOLD_ALPHA, FIRST_THRESHOLD_ALPHA, SECOND_THRESHOLD_ALPHA, THIRD_THRESHOLD_ALPHA, LAST_THRESHOLD_ALPHA]

const float OVERHEAT_ICON_VISIBILITY_FOV = 110.0

const float MISSILE_FAR_DISTANCE_SQR = 800 * 800
const float MISSILE_CLOSE_DISTANCE_SQR = 200 * 200

const float HOMING_SHORT_DELAY = 0.15
const float HOMING_LONG_DELAY = 0.4

const string BALLISTIC_HAS_LOCKON_TARGET_NETVAR = "hasBallisticLockonTarget"
const string BALLISTIC_IS_BEING_TARGETED_NETVAR = "ballisticIsBeingTargeted"

                               
const float FOLLOW_UP_SPEED_BOOST_DURATION = 2.0

struct FollowUpStatusEffectIndexes
{
	int speedBoostID
	int followUpVisualsID
}
      

struct
{
	float homingSpeed
	float noTargetSpeed
	float bestTargetRange
	float lockOnDelay
	int zoneRadius
	float aoeTimeout
	float aoeSpawnDelay
	float aoeDamage
	float debuffDuration
	int overheatDamage
	float lockoutTimeoutDuration

	#if SERVER
		table<entity, entity> ballisticLockOnTarget
		table<entity, entity> projectileOwner

		                               
			table<entity, FollowUpStatusEffectIndexes> playerStatusEffects
        

	#endif

	#if CLIENT
		var targetingRui
		table<entity, var> overheatIconRui
	#endif
} file

void function MpWeaponDebuffZone_Init()
{
	COCKPIT_TACT_IDLE = PrecacheParticleSystem( COCKPIT_TACT_IDLE_SCREEN_FX )
	COCKPIT_DEBUFF_ZONE_SCREEN_FX = PrecacheParticleSystem( COCKPIT_DEBUFF_1P_SCREEN_FX )
	PrecacheModel( DEBUFF_ZONE_HEART_MODEL )
	PrecacheParticleSystem( LOCK_ON_INIT )
	PrecacheParticleSystem( LOCK_ON_MARKER )
	PrecacheParticleSystem( DEBUFF_WEAPON_EFFECT_1P )
	PrecacheParticleSystem( AOE_RADIUS_FX )
	PrecacheParticleSystem( AOE_UPGRADE_TIMER_FX)
	PrecacheParticleSystem( AOE_IMPACT_FX )
	PrecacheParticleSystem( AOE_WARNING_FX )
	PrecacheParticleSystem( DEBUFF_EXPLOSION )
	PrecacheParticleSystem( DEBUFF_EXPLOSION_3P )
	PrecacheParticleSystem( DEBUFF_OVERHEAT_LHAND )
	PrecacheParticleSystem( FX_TACTICAL_RANGE_INDICATOR )
	PrecacheParticleSystem( OVERHEAT_DEBUFF_BODY_FX )
	PrecacheParticleSystem( DEBUFF_ZONE_MUZZLE_FLASH_3P )
	                    
	PrecacheParticleSystem( AOE_ENDING_FX_UPGRADE )
       

	RegisterSignal( "EndLockon" )
	RegisterSignal( "EndMissileHoming" )
	RegisterSignal( "EndTargeting" )
	RegisterSignal( "EndAOEThreads" )
	RegisterSignal( "EndDebuff" )
	RegisterSignal( "RemoveLockOnThreatIndicator" )

	file.homingSpeed 				= GetCurrentPlaylistVarFloat( "ballistic_tact_homing_speed", MISSILE_HOMING_SPEED )
	file.noTargetSpeed 				= GetCurrentPlaylistVarFloat( "ballistic_tact_no_target_speed", MISSILE_NOTARGET_SPEED )
	file.bestTargetRange 			= GetCurrentPlaylistVarFloat( "ballistic_tact_best_target_range", BEST_TARGET_MAX_RANGE )
	file.lockOnDelay 				= GetCurrentPlaylistVarFloat( "ballistic_tact_lock_on_delay", LOCKON_DELAY )
	file.zoneRadius 				= GetCurrentPlaylistVarInt( "ballistic_tact_zone_radius", DEBUFF_ZONE_RADIUS )
	file.aoeTimeout 				= GetCurrentPlaylistVarFloat( "ballistic_tact_aoe_timeout", AOE_TIMEOUT )
	file.aoeSpawnDelay 				= GetCurrentPlaylistVarFloat( "ballistic_tact_aoe_spawn_delay", AOE_SPAWN_DELAY )
	file.aoeDamage 					= GetCurrentPlaylistVarFloat( "ballistic_tact_aoe_damage", DEBUFF_AOE_DAMAGE )
	file.debuffDuration 			= GetCurrentPlaylistVarFloat( "ballistic_tact_debuff_duration", DIRECT_HIT_BUFF_DURATION )
	file.overheatDamage 			= GetCurrentPlaylistVarInt( "ballistic_tact_overheat_damages", OVERHEAT_DAMAGE )
	file.lockoutTimeoutDuration 	= GetCurrentPlaylistVarFloat( "ballistic_tact_lockout_timeout_duration", LOCKON_TIMEOUT_DURATION )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_debuff_zone_aoe, OnDamaged_DebuffZone )
	#endif

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.has_overheat_debuff, DebuffZone_OverheatDebuffEnabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.has_overheat_debuff, DebuffZone_OverheatDebuffDisabled )

		AddCallback_CreatePlayerPassiveRui( CreateTargetingRui )
		AddCallback_DestroyPlayerPassiveRui( DestroyTargetingRui )
	#endif

	Remote_RegisterClientFunction( "ServerCallback_CreateOverHeatIconRui", "entity" )

	AddCallback_OnPlayerOverheat( DebuffZone_OnPlayerOverheat )

	RegisterNetworkedVariable( BALLISTIC_HAS_LOCKON_TARGET_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL )
	RegisterNetworkedVariable( BALLISTIC_IS_BEING_TARGETED_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL )
	#if CLIENT
		RegisterNetVarBoolChangeCallback( BALLISTIC_HAS_LOCKON_TARGET_NETVAR, SetHasTargetForTargetingRui )
	#endif
}

                    
float function GetUpgradedAOETimeout()
{
	return GetCurrentPlaylistVarFloat( "ballistic_tact_upgraded_aoe_timeout", 15.0 )
}
      

float function GetAOETimeout( entity player )
{
	float result = file.aoeTimeout

                                
		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_ballistic_lasting_bullet
		{
			result = GetUpgradedAOETimeout()
		}
      
                                                                                                     
   
                                   
   
       

	return result
}

bool function DoesPlayerHaveOverheatDebuff( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.has_overheat_debuff )
}

bool function IsPlayerBeingTargetedByBallistic( entity player )
{
	return player.GetPlayerNetBool( BALLISTIC_IS_BEING_TARGETED_NETVAR )
}

void function OnWeaponDeactivate_DebuffZone( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if( !IsValid( player ) )
		return

	player.Signal( "EndTargeting" )

	#if CLIENT
		if( player != GetLocalViewPlayer() )
			return

		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", false )
			RuiSetBool( file.targetingRui, "hasTarget", false )
		}
	#endif
}

void function OnWeaponTossPrep_DebuffZone( entity weapon, WeaponTossPrepParams prepParams )
{
	entity player = weapon.GetWeaponOwner()

	if( !IsValid( player ) )
		return

	#if CLIENT
		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", true )
		}

		thread CreateTacticalTargetingFX( player )
	#endif

	#if SERVER
		thread GetBestHomingTargetThread( weapon, player )
	#endif
}

var function OnWeaponTossReleaseAnimEvent_DebuffZone( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !(InPrediction() && IsFirstTimePredicted()) )
			return
	#endif

	entity player = weapon.GetWeaponOwner()
	player.Signal( "EndTargeting" )

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	weapon.PlayWeaponEffect( $"", DEBUFF_ZONE_MUZZLE_FLASH_3P, "muzzle_flash" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	DebuffZone_FireMissileLogic( weapon, attackParams )

	PlayerUsedOffhand( player, weapon )

	return weapon.GetAmmoPerShot()
}

var function OnWeaponToss_DebuffZone( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetOwner()

	#if SERVER
		if( !IsValid( weaponOwner ) )
			return false

		PlayBattleChatterLineToSpeakerAndTeam( weaponOwner, "bc_tactical" )
	#endif

	#if CLIENT
		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", false )
			RuiSetBool( file.targetingRui, "hasTarget", false )
		}
	#endif

	return true
}

void function DebuffZone_FireMissileLogic( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	bool isHoming = owner.GetPlayerNetBool( BALLISTIC_HAS_LOCKON_TARGET_NETVAR )
	float missileSpeed = isHoming ? file.homingSpeed :  file.noTargetSpeed

	WeaponFireMissileParams fireMissileParams
	fireMissileParams.pos = attackParams.pos
	fireMissileParams.dir = attackParams.dir
	fireMissileParams.speed = missileSpeed
	fireMissileParams.scriptTouchDamageType = DF_GIB
	fireMissileParams.scriptExplosionDamageType = ( damageTypes.explosive | DF_NO_SELF_DAMAGE )
	fireMissileParams.doRandomVelocAndThinkVars = false
	fireMissileParams.clientPredicted = true
	entity firedMissile = weapon.FireWeaponMissile( fireMissileParams )

	#if SERVER
		firedMissile.SetOwner( owner )
	#endif
	EmitSoundOnEntity( firedMissile, HOMING_MISSILE_SFX_LOOP )
	SetTeam( firedMissile, owner.GetTeam() )

	#if SERVER
		entity ballisticLockOnTarget = file.ballisticLockOnTarget[ owner ]
		if( IsValid( ballisticLockOnTarget ) && isHoming )
		{
			thread HomingMissileThread( owner, firedMissile, ballisticLockOnTarget )
		}
	#endif
}

void function OnProjectileCollision_DebuffZone( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
	entity player = projectile.GetOwner()
	if( IsValid( player ) )
		player.Signal( "EndLockon" )
	projectile.Signal( "EndMissileHoming" )

	DeployableCollisionParams collisionParams
	collisionParams.pos = pos
	collisionParams.normal = normal
	collisionParams.hitEnt = hitEnt
	collisionParams.hitBox = 0
	collisionParams.isCritical = isCritical

	if( !PlantStickyEntity( projectile, collisionParams, ZERO_VECTOR, true ) )
	{
	#if SERVER
		if( IsValid( player ) )
		{
			bool IsFriendly = IsFriendlyTeam( player.GetTeam(), hitEnt.GetTeam() )
			if( hitEnt.IsPlayer() || IsTrainingDummie( hitEnt ) )
			{
				if ( !IsFriendly )
				{
					if( hitEnt.IsEntAlive() )
					{
						ApplyEnemyDebuffToTarget( player, hitEnt )
						EmitSoundOnEntityToTeamExceptPlayer( hitEnt, PROJECTILE_DIRECT_IMPACT_FRIENDLY_3P, hitEnt.GetTeam(), hitEnt )
						//if( !hitEnt.IsPlayerOverheating() )
						//	thread OverheatDebuffTargetFX( player, hitEnt )
					}
					                               
						else
						{
							if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_THREE ) )
							{
								SpeedBoostOnDamagePerk( player, hitEnt )
							}
						}
           

					PlayImpactFXTable( projectile.GetOrigin(), player, "tac_ballistic" )
					projectile.Destroy()
				}
			}
			else if( hitEnt.GetScriptName() == GIBRALTAR_GUN_SHIELD_NAME )
			{
				 entity parentEnt = hitEnt.GetParent()
				 bool IsShieldOwnerFriendly = IsFriendlyTeam( player.GetTeam(), hitEnt.GetTeam() )

				 if ( !IsShieldOwnerFriendly )
				 {
					if( hitEnt.IsEntAlive() )
					{
						ApplyEnemyDebuffToTarget( player, parentEnt )
						//if( !parentEnt.IsPlayerOverheating() )
						//	thread OverheatDebuffTargetFX( player, parentEnt )
					}

					PlayImpactFXTable( projectile.GetOrigin(), player, "tac_ballistic" )
					projectile.Destroy()
				 }
			}
			else if( !hitEnt.IsPlayerDecoy() )
			{
				PlayImpactFXTable( projectile.GetOrigin(), player, "tac_ballistic" )
				projectile.Destroy()
			}
			else
			{
				player.Signal( "EndMissileHoming" )
			}
		}
		else
		{
			projectile.Destroy()
		}
	#endif
	}
#if SERVER
	else
	{
		thread CreateDebuffZone( player, collisionParams, projectile )
	}
#endif
}

bool function DebuffZone_GetAllowableStickyEnts( entity ent )
{
	string modelName = ent.GetModelName()

	if ( modelName == "mdl/Robots/mobile_hardpoint/mobile_hardpoint_static.rmdl" )
		return true

	if( modelName == "mdl/props/crafting_siphon/crafting_siphon.rmdl" )
		return true

	return false
}

var function OnWeaponTossCancel_DebuffZone( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetOwner()

	if( !IsValid( player ) )
		return

	#if SERVER
		player.Signal( "EndTargeting" )
		player.Signal( "EndLockon" )
	#endif

	#if CLIENT
		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", false )
			RuiSetBool( file.targetingRui, "hasTarget", false )
		}
	#endif

	return 0
}

void function DebuffZone_OnPlayerOverheat( entity player, entity weapon )
{
	if( !StatusEffect_HasSeverity( player, eStatusEffect.has_overheat_debuff ) )
		return
	
	StatusEffect_StopAllOfType( player, eStatusEffect.has_overheat_debuff )
	player.Signal( "EndDebuff" )

	#if SERVER
		entity attacker = null
		if( player in file.projectileOwner )
		{
			attacker = file.projectileOwner[player]
			if( IsValid( attacker ) )
				 PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_tactical_enemyOverheat" )
			delete file.projectileOwner[player]
		}

		player.TakeDamage( min( player.GetHealth() - 1, file.overheatDamage ), attacker, attacker, { damageSourceId = eDamageSourceId.overheat_explosion } )

		EmitSoundOnEntityToEnemies( player, PLAYER_OVERHEATS_3P_ENEMY, player.GetTeam() )
		EmitSoundOnEntityToTeam( player, PLAYER_OVERHEATS_3P_TEAM, player.GetTeam() )

		StatsHook_BallisticTacticalEnemiesOverheated( attacker )

		thread ExplosionEffect( player, weapon )
	#endif

	weapon.PlayWeaponEffect( DEBUFF_EXPLOSION, $"", "muzzle_flash" )
}

#if SERVER
void function GetBestHomingTargetThread( entity weapon, entity player )
{
	EndSignal( player, "OnDestroy", "OnDeath", "BleedOut_OnStartDying", "EndTargeting" )
	EndSignal( weapon, "OnDestroy" )

	file.ballisticLockOnTarget[ player ] <- null

	while( true )
	{
		array<entity> enemyPlayers = GetPlayerArrayOfEnemies( player.GetTeam() )

		array<PotentialTargetData > functionPotentialList
		entity bestTarget  = SelectBestTargetFromArray( player, enemyPlayers )

		if ( !IsValid( bestTarget ) )
		{
			//No enemy players to target so try and target other objects
			array<entity> otherObjects

			//Drones
			/*array<entity> cameras = GetEntArrayByScriptName( CRYPTO_DRONE_SCRIPTNAME )
			otherObjects.extend( cameras )*/

			//AI
			array<entity> npcArray = GetNPCArray()
			otherObjects.extend( npcArray )

			array<entity> flyers = GetEntArrayByScriptName( DEATHBOX_FLYER_SCRIPT_NAME )
			otherObjects.extend( flyers )

			//Decoys
			array<entity> decoyArray = GetPlayerDecoyArray()
			decoyArray.extend( GetEntArrayByScriptName( MIRAGE_DECOY_DROP_SCRIPTNAME ) )
			otherObjects.extend( decoyArray )

			bestTarget = SelectBestTargetFromArray( player, otherObjects )
		}

		if( IsValid( bestTarget ) && bestTarget != file.ballisticLockOnTarget[ player ] )
		{
			player.Signal( "EndLockon" )

			file.ballisticLockOnTarget[ player ] = bestTarget
			StopSoundOnEntity( player, BALLISTIC_LOCKED_ON_LOST_1P )

			thread AcquireLockon_Thread( player, bestTarget )
			thread TargetingThreatIndicator_Thread( player, bestTarget )
		}

		WaitFrame()
	}
}

entity function SelectBestTargetFromArray( entity player, array<entity> potentialTargets )
{
	array<PotentialTargetData> targetsToTraceCheck

	foreach ( target in potentialTargets )
	{
		bool doesShare = target.DoesShareRealms( player )
		if ( !doesShare )
			continue

		if ( !IsAlive( target ) && target.GetScriptName() != MIRAGE_DECOY_DROP_SCRIPTNAME )
			continue

		if ( target.IsPhaseShifted() )
			continue

		if ( target.IsCloaked( false ) )
			continue

		if ( Bleedout_IsBleedingOut( target ) )
			continue

		bool IsFriendly = IsFriendlyTeam( player.GetTeam(), target.GetTeam() )
		if( target.IsPlayerDecoy() && IsFriendly )
			continue

		if( target.IsNPC() )
		{
			if ( target.Dev_GetAISettingByKeyField( "is_loot_tick" ) )
				continue
		}

		bool skipEyeTest = false
		if ( IsPlayerInCryptoDroneCameraView( target ) )
		{
			//If this is a Crypto and he is in his camera, the "eye" position is at the camera
			skipEyeTest = true
		}

		vector playerToTargetCenter = target.GetWorldSpaceCenter() - player.EyePosition()

		float distanceToTargetSqr = LengthSqr( playerToTargetCenter )
		if ( distanceToTargetSqr > DebuffZone_GetRangeSqr() )
		{
			continue
		}
		if( distanceToTargetSqr <= BEST_TARGET_SHORT_DISTANCE_SQR )
		{
			array<entity> ignoreEnts = [ player ]

			TraceResults trace = TraceLine( player.EyePosition(), player.EyePosition() + player.GetViewVector() * BEST_TARGET_SHORT_DISTANCE, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER )
		
			if( trace.hitEnt == target )
				return target
		}

		float dotToTargetCenter = DotProduct( Normalize(playerToTargetCenter), player.GetViewVector() )

		//Dot test
		if ( dotToTargetCenter < DOT_45DEGREE  )
		{
			continue
		}

		bool targetInCone           = false
		float bestDot               = dotToTargetCenter
		bool canSeeOrigin           = false
		bool canSeeWorldSpaceCenter = false
		bool canSeeEyes             = false
		float minDot                = deg_cos( BEST_TARGET_MAX_FOV )
		if ( dotToTargetCenter >= minDot )
		{
			targetInCone           = true
			canSeeWorldSpaceCenter = true
		}

		if ( !targetInCone ) //If I cant see then check the origin
		{
			vector playerToTarget = Normalize( target.GetOrigin() - player.EyePosition() )
			float dotToTarget = DotProduct( playerToTarget, player.GetViewVector() )
			if ( dotToTarget >= minDot )
			{
				targetInCone = true
				canSeeOrigin = true
				bestDot      = dotToTarget
			}
		}

		if ( !targetInCone && !skipEyeTest ) //If I cant see then check the eyes
		{
			vector playerToTargetEye = Normalize( target.EyePosition() - player.EyePosition() )
			float dotToTargetEye = DotProduct( playerToTargetEye, player.GetViewVector() )
			if ( dotToTargetEye >= minDot )
			{
				targetInCone = true
				canSeeEyes   = true
				bestDot      = dotToTargetEye
			}
		}

		if ( !targetInCone )
		{
			continue
		}

		PotentialTargetData targetData
		targetData.score = bestDot
		targetData.target = target

		targetsToTraceCheck.append( targetData )
	}

	entity bestTarget = null
	if ( targetsToTraceCheck.len() > 0 )
	{
		//Step 2 will be to sort this list and then only do raycasts until we find one we can see
		targetsToTraceCheck.sort( SortByScore )

		//We have a  potential target!
		float bestScore = 0
		foreach( targetData in targetsToTraceCheck )
		{
			if( IsValid( targetData.target ) && FerroWall_BlockScan( player.EyePosition(), targetData.target.EyePosition() ) && FerroWall_BlockScan( player.EyePosition(), targetData.target.GetWorldSpaceCenter() ) )
				continue

			int traceMask = targetData.target.IsPlayer() && MountedTurretPlaceable_IsUsingMountedTurret( targetData.target ) ? TRACE_MASK_SHOT : TRACE_MASK_VISIBLE
			array<entity> ignoreEnts = [ player ]

			TraceResults trace = TraceLine( player.EyePosition(), targetData.target.GetWorldSpaceCenter(), ignoreEnts, traceMask, TRACE_COLLISION_GROUP_NONE )
			if ( trace.fraction >= 1.0  )
			{
				bestScore = targetData.score
				bestTarget = targetData.target
			}

			if ( bestTarget == null ) //If I cant see then check the origin
			{
				trace = TraceLine( player.EyePosition(), targetData.target.GetOrigin(), ignoreEnts, traceMask, TRACE_COLLISION_GROUP_NONE )
				if ( trace.fraction >= 1.0)
				{
					bestScore = targetData.score
					bestTarget = targetData.target
				}
			}

			bool skipEyeTest = false
			if ( IsPlayerInCryptoDroneCameraView(targetData.target) )
			{
				//If this is a Crypto and he is in his camera, the "eye" position is at the camera
				skipEyeTest = true
			}
			if ( bestTarget == null && !skipEyeTest ) //If I cant see then check the eyes
			{
				trace = TraceLine( player.EyePosition(), targetData.target.EyePosition(), ignoreEnts, traceMask, TRACE_COLLISION_GROUP_NONE )
				if ( trace.fraction >= 1.0 )
				{
					bestScore = targetData.score
					bestTarget = targetData.target
				}
			}

			if ( bestTarget != null )
				break
		}
	}

	return bestTarget
}

void function AcquireLockon_Thread( entity player, entity bestTarget )
{
	EndSignal( player, "OnDestroy", "OnDeath", "EndLockon", "EndTargeting", "StartPhaseShift", "EnterMountedTurret", "hasBeenSilenced", "CraftingPlayerAttaching", "OnSkywardAllyUse", "BleedOut_OnStartDying", "HitBySeerTact" )
	EndSignal( bestTarget, "OnDestroy", "OnDeath", SIGNAL_TELEPORTED )

	int targetlockOnFxId  = GetParticleSystemIndex( LOCK_ON_INIT )
	entity targetLockonFX = StartParticleEffectOnEntity_ReturnEntity( bestTarget, targetlockOnFxId, FX_PATTACH_ABSORIGIN_FOLLOW, bestTarget.LookupAttachment( "CHESTFOCUS" ) )
	EffectSetControlPointVector( targetLockonFX, 5, <file.lockOnDelay,0,0> )
	SetTeam( targetLockonFX, player.GetTeam() )
	targetLockonFX.SetOwner( player )
	targetLockonFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER

	EmitSoundOnEntityOnlyToPlayer( player, player, BALLISTIC_LOCKED_ON_1P )

	OnThreadEnd(
		function() : ( targetLockonFX )
		{
			if( IsValid( targetLockonFX ) )
				targetLockonFX.Destroy()
		}
	)

	wait file.lockOnDelay

	if( IsValid( targetLockonFX ) )
		targetLockonFX.Destroy()

	if( IsValid( player ) && IsValid( bestTarget ) )
		thread TrackingTargetLogic_Thread( player, bestTarget )
}

void function TrackingTargetLogic_Thread( entity player, entity bestTarget )
{
	EndSignal( player, "OnDestroy", "OnDeath", "EndLockon", "StartPhaseShift", "EnterMountedTurret", "hasBeenSilenced", "CraftingPlayerAttaching", "OnSkywardAllyUse", "BleedOut_OnStartDying", "HitBySeerTact" )
	EndSignal( bestTarget, "OnDestroy", "OnDeath", SIGNAL_TELEPORTED )

	int targetMarkerFxId  = GetParticleSystemIndex( LOCK_ON_MARKER )
	entity targetMarkerFx = StartParticleEffectOnEntity_ReturnEntity( bestTarget, targetMarkerFxId, FX_PATTACH_ABSORIGIN_FOLLOW, bestTarget.LookupAttachment( "CHESTFOCUS" ) )
	SetTeam( targetMarkerFx, player.GetTeam() )
	targetMarkerFx.SetOwner( player )
	targetMarkerFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER

	OnThreadEnd(
		function() : ( targetMarkerFx )
		{
			if( IsValid( targetMarkerFx ) )
				targetMarkerFx.Destroy()
		}
	)

	player.SetPlayerNetBool( BALLISTIC_HAS_LOCKON_TARGET_NETVAR, true )

	if( bestTarget.IsPlayer() )
	{
		bestTarget.SetPlayerNetBool( BALLISTIC_IS_BEING_TARGETED_NETVAR, true )
		EmitSoundOnEntityOnlyToPlayer( bestTarget, bestTarget, TARGET_OF_BALLISTIC_LOCK_ON_1P )

		OnThreadEnd(
			function() : ( bestTarget )
			{
				if( IsValid( bestTarget ) )
				{
					bestTarget.SetPlayerNetBool( BALLISTIC_IS_BEING_TARGETED_NETVAR, false )
					EmitSoundOnEntityOnlyToPlayer( bestTarget, bestTarget, TARGET_OF_BALLISTIC_LOCK_ON_LOST_1P )
				}
			}
		)
	}

	float lockonTimeout = Time() + file.lockoutTimeoutDuration

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
			{
				player.SetPlayerNetBool( BALLISTIC_HAS_LOCKON_TARGET_NETVAR, false )
				EmitSoundOnEntityOnlyToPlayer( player, player, BALLISTIC_LOCKED_ON_LOST_1P )

				player.Signal( "RemoveLockOnThreatIndicator" )
				file.ballisticLockOnTarget[ player ] = null
			}
		}
	)

	while( !ShouldEndLockonOnTarget( player, bestTarget, lockonTimeout ) )
	{
		vector playerToTargetCenter = bestTarget.GetWorldSpaceCenter() - player.EyePosition()
		float dotToTargetCenter = DotProduct( Normalize(playerToTargetCenter), player.GetViewVector() )
		float distanceToTargetSqr = LengthSqr( playerToTargetCenter )

		if ( distanceToTargetSqr < DebuffZone_GetRangeSqr() && PlayerCanSee( player, bestTarget, true, 60.0 ) )
		{
			lockonTimeout = Time() + file.lockoutTimeoutDuration
		}

		WaitFrame()
	}
}

bool function ShouldEndLockonOnTarget( entity player, entity bestTarget, float lockonTimeout )
{
	if( Time() > lockonTimeout )
		return true

	if( bestTarget.IsPhaseShifted() )
		return true

	if( bestTarget.IsCloaked( true ) )
		return true

	if ( FerroWall_BlockScan( player.EyePosition(), bestTarget.GetCenter() ) )
		return true

	return false
}

void function TargetingThreatIndicator_Thread( entity player, entity bestTarget )
{
	EndSignal( player, "OnDestroy", "OnDeath", "BleedOut_OnStartDying", "EndTargeting", "EndLockon", "RemoveLockOnThreatIndicator" )
	EndSignal( bestTarget, "OnDestroy", "OnDeath", SIGNAL_TELEPORTED )

	if( !bestTarget.IsPlayer() )
		return

	entity threatIndicator = CreateThreatIndicator( player.GetCenter(), eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, file.bestTargetRange, <0, 0, 0>, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_SELF, bestTarget )
	threatIndicator.RemoveFromAllRealms()
	threatIndicator.AddToOtherEntitysRealms( bestTarget )
	threatIndicator.SetParent( player )

	OnThreadEnd(
		function() : ( threatIndicator )
		{
			if( IsValid( threatIndicator ) )
				threatIndicator.Destroy()
		}
	)

	WaitForever()
}

entity function SetupThreatFX( entity projectile, bool isFriendly, int particleSystemID, bool setParent )
{
	entity fx = StartParticleEffectInWorld_ReturnEntity( particleSystemID, projectile.GetOrigin(), projectile.GetAngles() + <-90,0,0> )
	fx .RemoveFromAllRealms()
	fx.AddToOtherEntitysRealms( projectile )
	fx.SetOwner( projectile )
	SetTeam( fx, projectile.GetTeam() )
	fx.kv.VisibilityFlags = isFriendly ? ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER : ENTITY_VISIBLE_TO_ENEMY
	if( isFriendly )
		EffectSetControlPointVector( fx, 1, <100,145,255> )
	else
	{
		EffectSetControlPointVector( fx, 1, <255, 121, 100> )
		EffectSetControlPointVector( fx, 5, <1, 0, 0> )
	}
	fx.DisableHibernation()

	if( setParent )
		fx.SetParent( projectile )

	return fx
}

void function HomingMissileThread( entity owner, entity missile, entity target )
{
	Assert( IsValid( missile ) )
	if( !IsAlive( target ) )
		return
	
	EndSignal( missile, "OnDestroy", "EndMissileHoming" )
	EndSignal( target, "OnDeath", "OnDestroy", SIGNAL_TELEPORTED )

	float endTime = Time() + MISSILE_LIFETIME
	float distanceSqr = DistanceSqr( target.GetWorldSpaceCenter(), missile.GetOrigin() )
	float homingDelay = HOMING_SHORT_DELAY

	if( distanceSqr >= MISSILE_FAR_DISTANCE_SQR )
		homingDelay = HOMING_LONG_DELAY
	else if( distanceSqr < MISSILE_CLOSE_DISTANCE_SQR )
		homingDelay = 0

	entity threatIndicator = CreateThreatIndicator( missile.GetWorldSpaceCenter(), eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, file.bestTargetRange, <0,0,0>, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_SELF, target )
	threatIndicator.RemoveFromAllRealms()
	threatIndicator.AddToOtherEntitysRealms( missile )
	threatIndicator.SetParent( missile )

	OnThreadEnd(
		function() : ( threatIndicator, owner, missile )
		{
			if( IsValid( threatIndicator ) )
				threatIndicator.Destroy()

			if( IsValid( owner ) )
				owner.Signal( "EndLockon" )

			missile.SetMissileTarget( null, <0, 0, 0> )
		}
	)

	wait homingDelay

	missile.SetMissileTarget( target, <0,0,0> )
	missile.SetHomingSpeeds( file.homingSpeed, file.homingSpeed )

	while( !BreakHomingTracking( target ) )
	{
		WaitFrame()
	}
}

bool function BreakHomingTracking( entity target )
{
	if( target.IsPhaseShifted() )
		return true

	if( target.IsCloaked( true ) )
		return true

	return false
}

void function OnDamaged_DebuffZone( entity victim, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if( !IsValid( attacker ) || !IsValid( inflictor ) || inflictor.IsDissolving() || !IsValid( victim ) || victim == attacker )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if( !IsEnemyTeam( victim.GetTeam(), attacker.GetTeam() ) && attacker != victim )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if( victim.IsNPC() && !IsTrainingDummie( victim ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if( victim.IsPlayerDecoy() )
	{
		thread AOEHitEffect( inflictor, attacker )
		inflictor.Signal( "EndAOEThreads" )
		return
	}

	if( !victim.IsPlayer() && !IsTrainingDummie( victim ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if( Bleedout_IsBleedingOut( victim ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if( !victim.IsEntAlive() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	entity shieldingVortexSphere = Trophy_EntInTrophyTrigger( victim )
	if( IsValid( shieldingVortexSphere ) && inflictor.IsProjectile() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		Trophy_RemoteTryZapProjectile( shieldingVortexSphere, inflictor )
		return
	}

	thread AOEHitEffect( inflictor, attacker )

	ApplyEnemyDebuffToTarget( attacker, victim )
	//if( !victim.IsPlayerOverheating() )
	//	thread OverheatDebuffTargetFX( attacker, victim )

	inflictor.Signal( "EndAOEThreads" )
}

void function CreateDebuffZone( entity player, DeployableCollisionParams collisionParams, entity projectile )
{
	entity plantedProjectile = CreateEntity( "prop_script" )
	plantedProjectile.RemoveFromAllRealms()
	plantedProjectile.AddToOtherEntitysRealms( projectile )
	plantedProjectile.SetModelScale( 1.0 )
	plantedProjectile.kv.solid = SOLID_NONE
	plantedProjectile.kv.fadedist = 20000
	plantedProjectile.kv.renderamt = 255
	plantedProjectile.kv.rendercolor = "255 130 0"
	plantedProjectile.kv.renderColorFriendly = "45 237 237"
	plantedProjectile.kv.CollisionGroup = TRACE_COLLISION_GROUP_NONE
	plantedProjectile.SetValueForModelKey( DEBUFF_ZONE_HEART_MODEL )
	entity projectileParent = projectile.GetParent()
	if( IsValid( projectileParent) )
		plantedProjectile.SetParent( projectileParent )
	plantedProjectile.SetAbsAngles( VectorToAngles( projectile.GetForwardVector() * - 1.0 ) )
	plantedProjectile.SetAbsOrigin( projectile.GetOrigin() + plantedProjectile.GetForwardVector() * -1.5 )
	plantedProjectile.SetOwner( player )
	SetTeam( plantedProjectile, projectile.GetTeam() )

	DispatchSpawn( plantedProjectile )
	#if SERVER
		PlayImpactFXTable( projectile.GetOrigin(), player, "tac_ballistic" )
		projectile.Destroy()
	#endif

	int playerTeam = TEAM_INVALID

	EndSignal( plantedProjectile, "OnDestroy", "EndAOEThreads" )
	if( IsValid( player ) )
	{
		EndSignal( player, "SquadEliminated" )
		playerTeam = player.GetTeam()
	}



	entity threatIndicator = CreateThreatIndicator( plantedProjectile.GetCenter() , eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, 200, <0,0,0>, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ENEMIES, player )
	threatIndicator.RemoveFromAllRealms()
	threatIndicator.AddToOtherEntitysRealms( plantedProjectile )
	threatIndicator.SetParent( plantedProjectile )

	int particleSystemID = GetParticleSystemIndex( AOE_WARNING_FX )
	entity plantedFX = StartParticleEffectInWorld_ReturnEntity ( particleSystemID, plantedProjectile.GetOrigin(), plantedProjectile.GetAngles() )
	plantedFX.RemoveFromAllRealms()
	plantedFX.AddToOtherEntitysRealms( plantedProjectile )
	plantedFX.SetParent( plantedProjectile )

	EmitSoundOnEntity( plantedProjectile, PROJECTILE_WAITING_TO_TRIGGER_SOUND )

	if( IsValid( player ) )
		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_BALLISTIC_DEBUFF_ZONE, player, plantedProjectile.GetOrigin(), plantedProjectile.GetTeam(), player )

	OnThreadEnd(
		function() : ( plantedFX, threatIndicator, plantedProjectile, player )
		{
			if( IsValid( player ) )
			{
				EmitSoundOnEntityToEnemies( plantedProjectile, PROJECTILE_AOR_END_SOUND_ENEMY, player.GetTeam() )
				EmitSoundOnEntityToTeam( plantedProjectile, PROJECTILE_AOR_END_SOUND, player.GetTeam() )
			}

			if( IsValid( plantedFX ) )
				plantedFX.Destroy()

			if( IsValid( threatIndicator ) )
				threatIndicator.Destroy()

			if( IsValid( plantedProjectile ) )
				plantedProjectile.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
		}
	)
	wait file.aoeSpawnDelay

	plantedFX.Destroy()

	StopSoundOnEntity( plantedProjectile, PROJECTILE_WAITING_TO_TRIGGER_SOUND )

	string friendlySound = PROJECTILE_TRIGGERED_AOE_SOUND
	string enemySound = PROJECTILE_TRIGGERED_AOE_SOUND_ENEMY

	                    
	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_ballistic_lasting_bullet
	{
		friendlySound = PROJECTILE_UPGRADED_TRIGGERED_AOE_SOUND
		enemySound = PROJECTILE_UPGRADED_TRIGGERED_AOE_SOUND_ENEMY
	}
       

	if( playerTeam != TEAM_INVALID )
	{
		EmitSoundOnEntityToEnemies( plantedProjectile, enemySound, playerTeam )
		EmitSoundOnEntityToTeam( plantedProjectile, friendlySound, playerTeam )
	}
	else
	{
		EmitSoundOnEntity( plantedProjectile, enemySound )
	}


	entity friendlyColoredFX = SetupThreatFX( plantedProjectile, true, GetParticleSystemIndex( AOE_RADIUS_FX ), true )
	entity enemyColoredFX = SetupThreatFX( plantedProjectile, false, GetParticleSystemIndex( AOE_RADIUS_FX ), true )

	float endTime = Time() + GetAOETimeout( player )

	OnThreadEnd(
		function() : ( friendlyColoredFX, enemyColoredFX, plantedProjectile )
		{
			if( IsValid( friendlyColoredFX ) )
				friendlyColoredFX.Destroy()

			if( IsValid( enemyColoredFX ) )
				enemyColoredFX.Destroy()

		}
	)

	                    
		entity endingFxFriendly = null
       

	while ( Time() < endTime )
	{
		RadiusDamage(
			plantedProjectile.GetOrigin() + plantedProjectile.GetForwardVector() * -5.0,
			player, //attacker
			plantedProjectile, //inflictor
			file.aoeDamage,
			file.aoeDamage,
			file.zoneRadius, // inner radius
			file.zoneRadius, // outer radius
			SF_ENVEXPLOSION_MASK_BRUSHONLY | SF_ENVEXPLOSION_ALIVE_ONLY | SF_ENVEXPLOSION_NO_DAMAGEOWNER,
			0, // distanceFromAttacker
			0, // explosionForce
			DF_ELECTRICAL,
			eDamageSourceId.mp_ability_debuff_zone_aoe )

		                    
		if( endTime - Time() < 5.0 && endingFxFriendly == null )
		{
			int aoeEndingIndex = GetParticleSystemIndex( AOE_ENDING_FX_UPGRADE )
			endingFxFriendly = SetupThreatFX( plantedProjectile, true, aoeEndingIndex, true )
			entity endingFxEnemy = SetupThreatFX( plantedProjectile, false, aoeEndingIndex, true )

			OnThreadEnd(
				function() : ( endingFxFriendly, endingFxEnemy )
				{
					if( IsValid( endingFxFriendly ) )
						endingFxFriendly.Destroy()
					if( IsValid( endingFxEnemy ) )
						endingFxEnemy.Destroy()
				}
			)
		}
        

		WaitFrame()
	}
}

void function AOEHitEffect( entity entParent, entity owner )
{
	if( !IsValid( entParent ) )
		return

	if( !IsValid( owner ) )
		return

	int ownerTeam = owner.GetTeam()

	entity friendlyColoredFX = SetupThreatFX( entParent, true, GetParticleSystemIndex( AOE_IMPACT_FX ), false )
	entity enemyColoredFX = SetupThreatFX( entParent, false, GetParticleSystemIndex( AOE_IMPACT_FX ), false )

	OnThreadEnd(
		function() : ( friendlyColoredFX, enemyColoredFX )
		{
			if ( IsValid( friendlyColoredFX ) )
				friendlyColoredFX.Destroy()

			if ( IsValid( enemyColoredFX ) )
				enemyColoredFX.Destroy()
		}
	)

	wait AOE_HIT_EFFECT_TIMER

	return
}

void function OverheatDebuffTargetFX( entity player, entity target )
{
	target.Signal( "EndDebuff" )
	target.EndSignal( "OnDestroy", "OnDeath", "BleedOut_OnStartDying", "EndDebuff" )

	//target.SetPlayerOverheatState( true )

	if( target.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( target, target, PROJECTILE_DIRECT_IMPACT_ENEMY_1P )
		EmitSoundOnEntityExceptToPlayer( target, target, PROJECTILE_DIRECT_IMPACT_ENEMY_3P )
		thread OverheatSFX_Thread( target )
	}
	else
	{
		EmitSoundOnEntity( target, PROJECTILE_DIRECT_IMPACT_ENEMY_3P )
	}

	thread StartDebuff3pFX( target )

	OnThreadEnd(
		function() : ( target )
		{
			if( IsValid( target ) )
			{
				StatusEffect_StopAllOfType( target, eStatusEffect.has_overheat_debuff )
				target.Signal( "EndDebuff" )
				//if( target.IsPlayerOverheating() )
				//	target.SetPlayerOverheatState( false )
			}
		}
	)

	while( DoesPlayerHaveOverheatDebuff( target ) )
		WaitFrame()
}

void function ApplyEnemyDebuffToTarget( entity player, entity target )
{
	                               
		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_THREE ) )
		{
			SpeedBoostOnDamagePerk( player, target )
		}
       

	if( Bleedout_IsBleedingOut( target ) )
		return

                      
                                     
      



	StatusEffect_AddTimed( target, eStatusEffect.has_overheat_debuff, 1.0, file.debuffDuration, 0.5 )
	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_tacticalHit" )
	file.projectileOwner[target] <- player

	StatsHook_BallisticTacticalEnemiesHit( player )

	array<entity> teammates = GetFriendlySquadArrayForPlayer_AliveConnected( player )
	foreach ( teammate in teammates )
	{
		Remote_CallFunction_Replay( teammate, "ServerCallback_CreateOverHeatIconRui", target )
	}
}

void function StartDebuff3pFX( entity target )
{
	EndSignal( target, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )

	entity fxHandle
	int AttachmentID = target.LookupAttachment( "CHESTFOCUS" )
	int fxid = GetParticleSystemIndex( OVERHEAT_DEBUFF_BODY_FX )

	fxHandle = StartParticleEffectOnEntity_ReturnEntity( target, fxid, FX_PATTACH_POINT_FOLLOW, AttachmentID )
	fxHandle.SetOwner( target )

	int visFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	fxHandle.SetVisibilityFlags( visFlags )

	OnThreadEnd(
		function() : ( target, fxHandle )
		{
			if( IsValid( target ) )
			{
				StopSoundOnEntity( target, PROJECTILE_DIRECT_IMPACT_ENEMY_3P )
				StopSoundOnEntity( target, PROJECTILE_DIRECT_IMPACT_ENEMY_1P )
				StopSoundOnEntity( target, PROJECTILE_DIRECT_IMPACT_FRIENDLY_3P )
			}

			if ( IsValid( fxHandle ) )
				fxHandle.Destroy()
		}
	)

	while( IsValid( fxHandle ) )
	{
		if( target.IsCloaked( true ) || target.IsPhaseShifted() )
			fxHandle.SetVisibilityFlags( ENTITY_VISIBLE_TO_NOBODY )
		else
			fxHandle.SetVisibilityFlags( visFlags )

		WaitFrame()
	}
}

void function OverheatSFX_Thread( entity target )
{
	EndSignal( target, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )

	bool shouldTriggerHighHeatWarning = true
	float lastThreasholdValue = MAX_DEBUFF_OVERHEAT - AMOUNT_BETWEEN_THRESHOLDS

	OnThreadEnd(
		function() : ( target )
		{
			StopSoundOnEntity( target, OVERHEAT_HIGH_WARNING_1P )
		}
	)

	while ( true )
	{
		float currentOverheatMeterValue = 0//target.GetPlayerOverheatValue()

		if ( currentOverheatMeterValue > lastThreasholdValue )
		{
			if( shouldTriggerHighHeatWarning )
				EmitSoundOnEntityOnlyToPlayer( target, target, OVERHEAT_HIGH_WARNING_1P )

			shouldTriggerHighHeatWarning = false
		}
		else if ( !shouldTriggerHighHeatWarning )
		{
			StopSoundOnEntity( target, OVERHEAT_HIGH_WARNING_1P )
			shouldTriggerHighHeatWarning = true
		}

		WaitFrame()
	}
}

void function ExplosionEffect( entity player, entity weapon )
{
	if( !IsValid( player ) || !IsAlive( player ) )
		return

	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying" )

	if( player.IsPlayer() )
	{
		entity viewModelEntity = player.GetViewModelEntity()
		if ( IsValid( viewModelEntity ) )
		{
			entity leftHandOverheatEffect
			int leftHandFxAttachmentID = viewModelEntity.LookupAttachment( "l_hand" )
			int leftHandParticleSystemID = GetParticleSystemIndex( DEBUFF_OVERHEAT_LHAND )
			leftHandOverheatEffect                    = StartParticleEffectOnEntity_ReturnEntity( viewModelEntity, leftHandParticleSystemID, FX_PATTACH_POINT_FOLLOW, leftHandFxAttachmentID )
			leftHandOverheatEffect.RemoveFromAllRealms()
			leftHandOverheatEffect.AddToOtherEntitysRealms( player )
			leftHandOverheatEffect.SetOwner( player )
			leftHandOverheatEffect.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER

			OnThreadEnd(
				function() : ( leftHandOverheatEffect )
				{
					if ( IsValid( leftHandOverheatEffect ) )
						leftHandOverheatEffect.Destroy()
				}
			)
		}
	}

	entity explosion3pEffect
	int explosion3pAttachmentID     = player.LookupAttachment( "R_HAND" )
	int explosion3pParticleSystemID = GetParticleSystemIndex( DEBUFF_EXPLOSION_3P )
	explosion3pEffect = StartParticleEffectOnEntity_ReturnEntity( player, explosion3pParticleSystemID, FX_PATTACH_POINT_FOLLOW, explosion3pAttachmentID )
	explosion3pEffect.RemoveFromAllRealms()
	explosion3pEffect.AddToOtherEntitysRealms( player )
	explosion3pEffect.SetOwner( player )
	SetTeam( explosion3pEffect, player.GetTeam() )
	explosion3pEffect.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	OnThreadEnd(
		function() : ( explosion3pEffect )
		{
			if ( IsValid( explosion3pEffect ) )
				explosion3pEffect.Destroy()
		}
	)

	wait 0.5
}

                               
void function SpeedBoostOnDamagePerk( entity attacker, entity victim )
{
	if ( victim.IsPhaseShifted() )
		return

	if( IsValid( victim ) && ( victim.IsPlayer() || victim.IsNPC() ) )
	{
		if( IsValid( attacker ) && victim != attacker )
		{
			if( !( attacker in file.playerStatusEffects ) )
			{
				FollowUpStatusEffectIndexes statusEffectIndexes
				statusEffectIndexes.speedBoostID = -1
				statusEffectIndexes.followUpVisualsID = -1
				file.playerStatusEffects[ attacker ] <- statusEffectIndexes
			}

			FollowUp_Start( attacker, FOLLOW_UP_SPEED_BOOST_DURATION )
		}
	}
}

void function FollowUp_Start( entity player, float duration )
{
	// no need to check both status effect, since he should never have one without the other.

	//if ( file.playerStatusEffects[player].speedBoostID != -1 && StatusEffect_GetTimeRemaining_WithHandle( player, file.playerStatusEffects[ player ].speedBoostID ) > 0 )
	//{
	//	StatusEffect_SetDuration( player, file.playerStatusEffects[ player ].followUpVisualsID, duration )
	//	StatusEffect_SetDuration( player, file.playerStatusEffects[ player ].speedBoostID, duration )
	//}
	//else
	{
		//PlayBattleChatterLineToSpeakerWithDebounceTime( "bc_damageEnemyKCBoost", player, player, 4.0, 4.0 )
		file.playerStatusEffects[ player ].followUpVisualsID = StatusEffect_AddTimed( player, eStatusEffect.adrenaline_visuals, 1, duration, duration )
		file.playerStatusEffects[ player ].speedBoostID = StatusEffect_AddTimed( player, eStatusEffect.speed_boost, 0.15, duration, 0.25 )
		thread StatsHook_TrackAdrenalineDistance( player )
	}
}
      
#endif //SERVER

#if CLIENT
void function CreateTargetingRui( entity player )
{
	if ( file.targetingRui != null )
		return

	if ( DoesPlayerHaveWeaponSling( player ) )
	{
		file.targetingRui = CreateCockpitPostFXRui( $"ui/targeting_rui.rpak", FULLMAP_Z_BASE )
		RuiSetResolutionToScreenSize( file.targetingRui )
	}
}

void function DestroyTargetingRui( entity player )
{
	if ( !DoesPlayerHaveWeaponSling( player ) )
	{
		if ( file.targetingRui != null )
		{
			RuiDestroyIfAlive( file.targetingRui )
			file.targetingRui = null
		}
	}
}

void function CreateTacticalTargetingFX( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "EndTargeting" )

	int fxId = GetParticleSystemIndex( FX_TACTICAL_RANGE_INDICATOR )
	int pulseVFX = StartParticleEffectOnEntity( player, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	float adjustedRange = file.bestTargetRange
	EffectSetControlPointVector( pulseVFX, 1, <adjustedRange, 0, 0> )

	int cockpitVFX = StartParticleEffectOnEntityWithPos( player, COCKPIT_TACT_IDLE, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( cockpitVFX, true )
	EffectSetControlPointVector( cockpitVFX, 2, <1, .25, 0> )

	OnThreadEnd(
		function() : ( pulseVFX, cockpitVFX, player )
		{
			if ( EffectDoesExist( pulseVFX ) )
				EffectStop( pulseVFX, false, true )

			if( EffectDoesExist( cockpitVFX ) )
				EffectStop( cockpitVFX, false, true )
		}
	)

	WaitForever()
}

void function SetHasTargetForTargetingRui( entity player, bool hasTarget )
{
	if (file.targetingRui  != null )
	{
		RuiSetBool( file.targetingRui, "hasTarget", hasTarget )
	}
}

void function OnClientAnimEvent_DebuffZone( entity weapon, string name )
{
	if ( !IsValid( weapon ) )
		return

	if ( name == MISSILE_FIRE_SCREEN_SHAKE )
		ClientScreenShake( SHAKE_AMPLITUDE, SHAKE_FREQUENCY, SHAKE_DURATION, SHAKE_DIRECTION )
}

void function DebuffZone_OverheatDebuffEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if( !OverheatStatusChanged( ent, actuallyChanged ) )
		return

	ent.Signal( "EndDebuff" )
	//if( !ent.IsPlayerOverheating() )
	//	ent.SetPlayerOverheatState( true )

	thread WeaponVFXThread( ent )
	thread StartDebuff1pFX( ent )
}

void function DebuffZone_OverheatDebuffDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if( !OverheatStatusChanged( ent, actuallyChanged ) )
		return

	ent.Signal( "EndDebuff" )
	//if( ent.IsPlayerOverheating() )
	//	ent.SetPlayerOverheatState( false )
}

bool function OverheatStatusChanged( entity ent, bool actuallyChanged )
{
	entity viewPlayer = GetLocalViewPlayer()
	if( ent != viewPlayer || !actuallyChanged )
		return false

	return true
}

void function StartDebuff1pFX( entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )

	var debuffProgressRui = CreateFullscreenRui( $"ui/debuff_progress.rpak", 32000 )

	int fxHandle
	fxHandle = StartParticleEffectOnEntityWithPos( player, COCKPIT_DEBUFF_ZONE_SCREEN_FX, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( fxHandle, true )
	EffectSetControlPointVector( fxHandle, 2, <0, 1, 0> )
	EffectSetControlPointVector( fxHandle, 3, <0.8,0.8,0.8> )

	OnThreadEnd(
		function() : ( fxHandle, debuffProgressRui )
		{
			RuiDestroyIfAlive( debuffProgressRui )

			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)

	while( debuffProgressRui != null )
	{
		float currentOverheatValue = 0
		RuiSetFloat( debuffProgressRui, "progress", currentOverheatValue / MAX_DEBUFF_OVERHEAT )

		int currentOverheatThreshold = int( currentOverheatValue / AMOUNT_BETWEEN_THRESHOLDS )
		if( currentOverheatThreshold < NUMBER_OF_THRESHOLDS - 1 )
		{
			EffectSetControlPointVector( fxHandle, 2, THRESHOLD_COLORS[currentOverheatThreshold] )
			EffectSetControlPointVector( fxHandle, 3, THRESHOLD_ALPHA[currentOverheatThreshold] )
		}

		WaitFrame()
	}
}

void function WeaponVFXThread( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if( IsValid( activeWeapon ) && IsBitFlagSet( activeWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) && activeWeapon.DoesWeaponPlayerOverheat() )
	{
		activeWeapon.PlayWeaponEffect( DEBUFF_WEAPON_EFFECT_1P, $"", "MENU_ROTATE" )

		WaitFrame()
	}

	OnThreadEnd(
		function() : ( player )
		{
			if( !IsValid( player ) )
				return

			entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			if( IsValid( activeWeapon ) && IsBitFlagSet( activeWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) )
			{
				activeWeapon.StopWeaponEffect( DEBUFF_WEAPON_EFFECT_1P, $"" )
			}
		}
	)

	while( true )
	{
		entity currentActiveWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( currentActiveWeapon ) || currentActiveWeapon == activeWeapon || !IsBitFlagSet( currentActiveWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) )
		{
			if ( IsValid( currentActiveWeapon ) && !IsBitFlagSet( currentActiveWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) )
			{
				activeWeapon = null
			}

			WaitFrame()
			continue
		}

		if( currentActiveWeapon.DoesWeaponPlayerOverheat() )
		{
			currentActiveWeapon.PlayWeaponEffect( DEBUFF_WEAPON_EFFECT_1P, $"", "MENU_ROTATE" )
			activeWeapon = currentActiveWeapon
		}

		WaitFrame()
	}
}

void function ServerCallback_CreateOverHeatIconRui( entity target )
{
	if( !IsValid( target ) || target in file.overheatIconRui )
		return

	entity player = GetLocalClientPlayer()
	var rui = RuiCreate( $"ui/overheat_on_player.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RuiCalculateDistanceSortKey( player.EyePosition(), target.GetOrigin() ) )

	InitHUDRui( rui )

	RuiTrackFloat3( rui, "pos", target, RUI_TRACK_OVERHEAD_FOLLOW )
	RuiKeepSortKeyUpdated( rui, true, "pos" )

	file.overheatIconRui[target] <- rui

	thread TrackOverheatIconLifeTimeAndVisibility( player, target )
}

void function TrackOverheatIconLifeTimeAndVisibility( entity player, entity target )
{
	EndSignal( target, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )
	EndSignal( player, "OnDeath", "OnDestroy" )

	OnThreadEnd(
		function() : ( target )
		{
			RuiDestroyIfAlive( file.overheatIconRui[target] )
			delete file.overheatIconRui[target]
		}
	)

	while( DoesPlayerHaveOverheatDebuff( target ) )
	{
		bool isVisible = OverheatIconShouldBeVisible( player, target )

		RuiSetBool( file.overheatIconRui[target], "isDetectedBySeer", StatusEffect_HasSeverity( target, eStatusEffect.seer_detected ) )
		RuiSetBool( file.overheatIconRui[target], "isVisible", isVisible )
		RuiSetFloat( file.overheatIconRui[target], "progress", 100 / MAX_DEBUFF_OVERHEAT )

		WaitFrame()
	}
}

bool function OverheatIconShouldBeVisible( entity player, entity target )
{
	if( target.IsCloaked( true ) )
		return false

	if( target.IsPhaseShiftedOrPending() )
		return false

	if( PlayerCanSee( player, target, true, OVERHEAT_ICON_VISIBILITY_FOV ) )
		return true

	return false
}

float function DebuffZone_GetOverheatDuration()
{
	return file.debuffDuration
}
#endif //CLIENT

float function DebuffZone_GetRangeSqr()
{
	float rangeSqr = file.bestTargetRange * file.bestTargetRange
	return rangeSqr
}
 