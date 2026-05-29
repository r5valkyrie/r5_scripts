global function MpWeaponFerroWall_Init
global function OnWeaponAttemptOffhandSwitch_weapon_ferro_wall

global function OnWeaponActivate_weapon_ferro_wall
global function OnWeaponDeactivate_weapon_ferro_wall
global function OnWeaponTossReleaseAnimEvent_weapon_ferro_wall
global function OnWeaponChargeBegin_weapon_ferro_wall
global function OnWeaponChargeEnd_weapon_ferro_wall
global function OnProjectileCollision_weapon_ferro_wall
global function GetProjectileVelocity_weapon_ferro_wall
global function OnWeaponPrimaryAttack_weapon_ferro_wall

global function FerroWall_BlockScan
#if CLIENT
global function OnCreateClientOnlyModel_weapon_ferro_wall
#endif


//Assets
const asset FERRO_WALL_MODEL_A_SMALL = $"mdl/fx/ferrofluid_ult_wall_01.rmdl"
const asset FERRO_WALL_MODEL_A_MEDIUM = $"mdl/fx/ferrofluid_ult_wall_01_2x.rmdl"
const asset FERRO_WALL_MODEL_A_LARGE = $"mdl/fx/ferrofluid_ult_wall_01_3x.rmdl"
const asset FERRO_WALL_MODEL_B_SMALL = $"mdl/fx/ferrofluid_ult_wall_02.rmdl"
const asset FERRO_WALL_MODEL_B_MEDIUM = $"mdl/fx/ferrofluid_ult_wall_02_2x.rmdl"
const asset FERRO_WALL_MODEL_B_LARGE = $"mdl/fx/ferrofluid_ult_wall_02_3x.rmdl"
const asset FERRO_WALL_MODEL_C_SMALL = $"mdl/fx/ferrofluid_ult_wall_03.rmdl"
const asset FERRO_WALL_MODEL_C_MEDIUM = $"mdl/fx/ferrofluid_ult_wall_03_2x.rmdl"
const asset FERRO_WALL_MODEL_C_LARGE = $"mdl/fx/ferrofluid_ult_wall_03_3x.rmdl"
const asset FERRO_WALL_MODEL_AR = $"mdl/fx/ferrofluid_ult_ar.rmdl"
const asset FERRO_WALL_MODEL_SLOPE = $"mdl/fx/ferrofluid_ult_slope_01_3x.rmdl"
const array< asset > FERRO_WALL_MODEL_A_ARRAY = [ FERRO_WALL_MODEL_A_SMALL, FERRO_WALL_MODEL_A_MEDIUM, FERRO_WALL_MODEL_A_LARGE ]
const array< asset > FERRO_WALL_MODEL_B_ARRAY = [ FERRO_WALL_MODEL_B_SMALL, FERRO_WALL_MODEL_B_MEDIUM, FERRO_WALL_MODEL_B_LARGE ]
const array< asset > FERRO_WALL_MODEL_C_ARRAY = [ FERRO_WALL_MODEL_C_SMALL, FERRO_WALL_MODEL_C_MEDIUM, FERRO_WALL_MODEL_C_LARGE ]
const array< asset > FERRO_WALL_SMALL_MODEL_ARRAY = [ FERRO_WALL_MODEL_A_SMALL, FERRO_WALL_MODEL_B_SMALL, FERRO_WALL_MODEL_C_SMALL ]
const array< asset > FERRO_WALL_MEDIUM_MODEL_ARRAY = [ FERRO_WALL_MODEL_A_MEDIUM, FERRO_WALL_MODEL_B_MEDIUM, FERRO_WALL_MODEL_C_MEDIUM ]
const array< asset > FERRO_WALL_LARGE_MODEL_ARRAY = [ FERRO_WALL_MODEL_A_LARGE, FERRO_WALL_MODEL_B_LARGE, FERRO_WALL_MODEL_C_LARGE ]
const array< array< asset > > FERRO_WALL_MODEL_TYPE_ARRAY = [ FERRO_WALL_MODEL_A_ARRAY, FERRO_WALL_MODEL_B_ARRAY, FERRO_WALL_MODEL_C_ARRAY ]

const asset FERRO_WALL_BASE_FX_A_SMALL = $"P_ferro_wall_SM_A"
const asset FERRO_WALL_BASE_FX_A_MEDIUM = $"P_ferro_wall_MED_A"
const asset FERRO_WALL_BASE_FX_A_LARGE = $"P_ferro_wall_LRG_A"
const asset FERRO_WALL_BASE_FX_B_SMALL = $"P_ferro_wall_SM_B"
const asset FERRO_WALL_BASE_FX_B_MEDIUM = $"P_ferro_wall_MED_B"
const asset FERRO_WALL_BASE_FX_B_LARGE = $"P_ferro_wall_LRG_B"
const asset FERRO_WALL_BASE_FX_C_SMALL = $"P_ferro_wall_SM_C"
const asset FERRO_WALL_BASE_FX_C_MEDIUM = $"P_ferro_wall_MED_C"
const asset FERRO_WALL_BASE_FX_C_LARGE = $"P_ferro_wall_LRG_C"
const array< asset > FERRO_WALL_BASE_FX_A_ARRAY = [ FERRO_WALL_BASE_FX_A_SMALL, FERRO_WALL_BASE_FX_A_MEDIUM, FERRO_WALL_BASE_FX_A_LARGE ]
const array< asset > FERRO_WALL_BASE_FX_B_ARRAY = [ FERRO_WALL_BASE_FX_B_SMALL, FERRO_WALL_BASE_FX_B_MEDIUM, FERRO_WALL_BASE_FX_B_LARGE ]
const array< asset > FERRO_WALL_BASE_FX_C_ARRAY = [ FERRO_WALL_BASE_FX_C_SMALL, FERRO_WALL_BASE_FX_C_MEDIUM, FERRO_WALL_BASE_FX_C_LARGE ]
const array< array< asset > > FERRO_WALL_BASE_FX_TYPE_ARRAY = [ FERRO_WALL_BASE_FX_A_ARRAY, FERRO_WALL_BASE_FX_B_ARRAY, FERRO_WALL_BASE_FX_C_ARRAY ]

const asset FERRO_WALL_BASE_WATER_FX_A_SMALL = $"P_ferro_wall_SM_A_water"
const asset FERRO_WALL_BASE_WATER_FX_A_MEDIUM = $"P_ferro_wall_MED_A_water"
const asset FERRO_WALL_BASE_WATER_FX_A_LARGE = $"P_ferro_wall_LRG_A_water"
const asset FERRO_WALL_BASE_WATER_FX_B_SMALL = $"P_ferro_wall_SM_B_water"
const asset FERRO_WALL_BASE_WATER_FX_B_MEDIUM = $"P_ferro_wall_MED_B_water"
const asset FERRO_WALL_BASE_WATER_FX_B_LARGE = $"P_ferro_wall_LRG_B_water"
const asset FERRO_WALL_BASE_WATER_FX_C_SMALL = $"P_ferro_wall_SM_C_water"
const asset FERRO_WALL_BASE_WATER_FX_C_MEDIUM = $"P_ferro_wall_MED_C_water"
const asset FERRO_WALL_BASE_WATER_FX_C_LARGE = $"P_ferro_wall_LRG_C_water"
const array< asset > FERRO_WALL_BASE_WATER_FX_A_ARRAY = [ FERRO_WALL_BASE_WATER_FX_A_SMALL, FERRO_WALL_BASE_WATER_FX_A_MEDIUM, FERRO_WALL_BASE_WATER_FX_A_LARGE ]
const array< asset > FERRO_WALL_BASE_WATER_FX_B_ARRAY = [ FERRO_WALL_BASE_WATER_FX_B_SMALL, FERRO_WALL_BASE_WATER_FX_B_MEDIUM, FERRO_WALL_BASE_WATER_FX_B_LARGE ]
const array< asset > FERRO_WALL_BASE_WATER_FX_C_ARRAY = [ FERRO_WALL_BASE_WATER_FX_C_SMALL, FERRO_WALL_BASE_WATER_FX_C_MEDIUM, FERRO_WALL_BASE_WATER_FX_C_LARGE ]
const array< array< asset > > FERRO_WALL_BASE_WATER_FX_TYPE_ARRAY = [ FERRO_WALL_BASE_WATER_FX_A_ARRAY, FERRO_WALL_BASE_WATER_FX_B_ARRAY, FERRO_WALL_BASE_WATER_FX_C_ARRAY ]

const asset FERRO_WALL_DARKEYE_VIGNETTE_FX = $"P_ferro_wall_veil_1p"
const asset FERRO_WALL_DEBUG_SPHERE_VISION_LIMIT_FX = $"P_ferro_wall_veil_dark_sphere"
const asset FERRO_WALL_DARK_ZONE_SHROUD_FX = $"P_ferro_wall_veil_3p_enemy"

const asset FERRO_WALL_BASE_FX_A = $"P_ferro_wall_base"
const asset FERRO_WALL_BASE_FX_B = $"P_ferro_wall_base_02"
const asset FERRO_WALL_BASE_FX_C = $"P_ferro_wall_base_03"
const array< asset > FERRO_WALL_BASE_FX_ARRAY = [ FERRO_WALL_BASE_FX_A, FERRO_WALL_BASE_FX_B, FERRO_WALL_BASE_FX_C ]

const asset FERRO_WALL_LAUNCH_FX_SMALL = $"P_ferro_wall_launch_SM"
const asset FERRO_WALL_LAUNCH_FX_MEDIUM = $"P_ferro_wall_launch_MED"
const asset FERRO_WALL_LAUNCH_FX_LARGE = $"P_ferro_wall_launch_LRG"
const array< asset > FERRO_WALL_LAUNCH_FX_ARRAY = [ FERRO_WALL_LAUNCH_FX_SMALL, FERRO_WALL_LAUNCH_FX_MEDIUM, FERRO_WALL_LAUNCH_FX_LARGE ]

const asset FERRO_WALL_LAUNCH_WATER_FX_SMALL = $"P_ferro_wall_launch_SM_water"
const asset FERRO_WALL_LAUNCH_WATER_FX_MEDIUM = $"P_ferro_wall_launch_MED_water"
const asset FERRO_WALL_LAUNCH_WATER_FX_LARGE = $"P_ferro_wall_launch_LRG_water"
const array< asset > FERRO_WALL_LAUNCH_WATER_FX_ARRAY = [ FERRO_WALL_LAUNCH_WATER_FX_SMALL, FERRO_WALL_LAUNCH_WATER_FX_MEDIUM, FERRO_WALL_LAUNCH_WATER_FX_LARGE ]

const asset FERRO_WALL_IDLE_FX_A = $"P_ferro_wall_idle_A"
const asset FERRO_WALL_IDLE_FX_B = $"P_ferro_wall_idle_B"
const asset FERRO_WALL_IDLE_FX_C = $"P_ferro_wall_idle_C"
const array< asset > FERRO_WALL_IDLE_FX_ARRAY = [ FERRO_WALL_IDLE_FX_A, FERRO_WALL_IDLE_FX_B, FERRO_WALL_IDLE_FX_C ]

const asset FERRO_WALL_IDLE_WATER_FX_A = $"P_ferro_wall_idle_A_water"
const asset FERRO_WALL_IDLE_WATER_FX_B = $"P_ferro_wall_idle_B_water"
const asset FERRO_WALL_IDLE_WATER_FX_C = $"P_ferro_wall_idle_C_water"
const array< asset > FERRO_WALL_IDLE_WATER_FX_ARRAY = [ FERRO_WALL_IDLE_WATER_FX_A, FERRO_WALL_IDLE_WATER_FX_B, FERRO_WALL_IDLE_WATER_FX_C ]

const asset FERRO_WALL_FINISHED_FX_SMALL = $"P_ferro_wall_finish_SM"
const asset FERRO_WALL_FINISHED_FX_MEDIUM = $"P_ferro_wall_finish_MED"
const asset FERRO_WALL_FINISHED_FX_LARGE = $"P_ferro_wall_finish_LRG"
const array< asset > FERRO_WALL_FINISHED_FX_ARRAY = [ FERRO_WALL_FINISHED_FX_SMALL, FERRO_WALL_FINISHED_FX_MEDIUM, FERRO_WALL_FINISHED_FX_LARGE ]

const asset FERRO_WALL_FINISHED_WATER_FX_SMALL = $"P_ferro_wall_finish_SM_water"
const asset FERRO_WALL_FINISHED_WATER_FX_MEDIUM = $"P_ferro_wall_finish_MED_water"
const asset FERRO_WALL_FINISHED_WATER_FX_LARGE = $"P_ferro_wall_finish_LRG_water"
const array< asset > FERRO_WALL_FINISHED_WATER_FX_ARRAY = [ FERRO_WALL_FINISHED_WATER_FX_SMALL, FERRO_WALL_FINISHED_WATER_FX_MEDIUM, FERRO_WALL_FINISHED_WATER_FX_LARGE ]

const asset FERRO_WALL_WALKTHROUGH_SPLASH = $"P_ferro_wall_veil_splash_3p"
const asset FERRO_WALL_PASSTHROUGH_IMPACT = $"P_ferro_wall_impact"

//Sounds
const string FERRO_WALL_ACTIVATE_3P = "Catalyst_Ultimate_Activate_3P"
const string FERRO_WALL_COMPLETE_3P = "Catalyst_Ultimate_Wall_Complete_3p"
const string FERRO_WALL_IDLE_3P = "Catalyst_Ultimate_Idle_3p"
const string FERRO_WALL_BASE_RAISE_START = "Catalyst_Ultimate_Activate_FerroWallRise_3p"
const string FERRO_WALL_BASE_LAUNCH_3P = "Catalyst_Ultimate_Launch_Seq_GroundFerroSpikes_3p"
const string FERRO_WALL_BASE_RISING_3P = "Catalyst_Ultimate_Launch_Seq_FerroWallRising_3p"
const string FERRO_WALL_BASE_RISING_WATER_3P = "Catalyst_Ultimate_WallRising_Impact_Water_3p"
const string FERRO_WALL_BASE_FALLING_3P = "Catalyst_Ultimate_Wall_Dissolve_3p"
const string FERRO_WALL_PLAYER_PASSTHROUGH_1P = "flesh_catalyst_ult_ferrowall_damage_1p"
const string FERRO_WALL_PLAYER_PASSTHROUGH_3P = "flesh_catalyst_ult_ferrowall_damage_3p"
const string FERRO_WALL_FRIENDLY_START_PASSTHROUGH_1P = "Catalyst_Ult_FerroWall_Damage_StartLoop_Friendly_1p"
const string FERRO_WALL_FRIENDLY_END_PASSTHROUGH_1P = "Catalyst_Ult_FerroWall_Damage_End_Friendly_1p"
const string FERRO_WALL_ENEMY_START_PASSTHROUGH_1P = "Catalyst_Ult_FerroWall_Damage_StartLoop_Enemy_1p"
const string FERRO_WALL_ENEMY_END_PASSTHROUGH_1P = "Catalyst_Ult_FerroWall_Damage_End_Enemy_1p"
const string FERRO_WALL_FRIENDLY_START_PASSTHROUGH_3P = "Catalyst_Ult_FerroWall_Damage_StartLoop_Friendly_3p"
const string FERRO_WALL_FRIENDLY_END_PASSTHROUGH_3P = "Catalyst_Ult_FerroWall_Damage_End_Friendly_3p"
const string FERRO_WALL_ENEMY_START_PASSTHROUGH_3P = "Catalyst_Ult_FerroWall_Damage_StartLoop_Enemy_3p"
const string FERRO_WALL_ENEMY_END_PASSTHROUGH_3P = "Catalyst_Ult_FerroWall_Damage_End_Enemy_3p"

//Signals
const string KILL_CLIENT_THREAD_SIGNAL = "ferro_wall_kill_client_thread"
const string START_SOUND_SIGNAL = "ferro_wall_start_sound"

//String consts
const string FERRO_WALL_WEAPON_NAME = "mp_weapon_ferro_wall"
const string ABILITY_ACTIVE_MOD = "ability_active_mod"
const string ABILITY_USED_MOD = "ability_used_mod"
const string FERRO_WALL_INFO_TARGET_NAME = "ferro_wall_info"
global const string FERRO_WALL_SEGMENT_TARGET_NAME = "ferro_wall_segment"

//Tuneables
const bool FERRO_WALL_DEBUG_DRAW = false
const float FERRO_WALL_PILLAR_Z_OFFSET 	= 0
const float FERRO_WALL_STEP_INIT 		= 0
const float FERRO_WALL_STEP 				= 88.0
const float FERRO_WALL_RADIUS 			= FERRO_WALL_STEP / 2.0
const float FERRO_WALL_CLIMB_HEIGHT_INIT		= 80.0
const float FERRO_WALL_CLIMB_HEIGHT 		= 95.0
const float FERRO_WALL_RETRY_CLIMB_HEIGHT_FRAC 		= 0.85
const float FERRO_WALL_RETRY_CLIMB_HEIGHT 		= FERRO_WALL_CLIMB_HEIGHT  * FERRO_WALL_RETRY_CLIMB_HEIGHT_FRAC
const float FERRO_WALL_DOWN_TRACE_LENGTH		= 500.0
const float FERRO_WALL_DEFAULT_FWD_DISTANCE		= 75
const float FERRO_WALL_HEIGHT 		= 120.0
const float FERRO_WALL_WIDTH 		= 15.0
const float FERRO_WALL_WIDTH_SQR 		= FERRO_WALL_WIDTH * FERRO_WALL_WIDTH

const float FERRO_WALL_PILLAR_DURATION = 15.0
                    
const float UPGRADE_FERRO_WALL_PILLAR_DURATION = 20.0
      
const float FERRO_WALL_PILLAR_DELAY_BEFORE_SCALING = 1.2
const float FERRO_WALL_PILLAR_DELAY_FORWARD = 0.05
const float FERRO_WALL_PILLAR_DELAY_HORIZONTAL = FERRO_WALL_PILLAR_DELAY_FORWARD * 2
const float FERRO_WALL_PILLAR_SCALE_TIME = 0.6
const float FERRO_WALL_PILLAR_DESCALE_TIME = 0.85
const int FERRO_WALL_NUM_PILLARS_FORWARD = 20
                    
const int UPGRADE_FERRO_WALL_NUM_PILLARS_FORWARD = 27
      
const int FERRO_WALL_NUM_PILLARS_HORIZONTAL_PER_SIDE = 8
const float FERRO_WALL_PILLAR_HEALTH = 125
const float FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER = 25.0 - FERRO_WALL_PILLAR_Z_OFFSET

const float FERRO_WALL_SLOW_SCALER = 0.5
const float FERRO_WALL_SLOW_NPC_SCALER = 0.8
const float FERRO_WALL_SLOW_NPC_TIME_SCALER = 2.0

const float FERRO_WALL_DARKVISION_FX_ALPHA_START = 0.0
const float FERRO_WALL_DARKVISION_FX_ALPHA_END = 0.9
const float FERRO_WALL_DARKVISION_FX_ALPHA_END_TEAM = 0.3
const float FERRO_WALL_DARKVISION_FX_ALPHA_END_CATALYST = 0.3 //0.95
const int FERRO_WALL_DARKVISION_DISTANCE = 200
const float FERRO_WALL_DARKVISION_OPACITY = 0.7
const float FERRO_WALL_DARKVISION_DURATION = 7.0
const float FERRO_WALL_DARKVISION_TEAM_DURATION = 1.0
const float FERRO_WALL_DARKVISION_FX_SCALAR_ENEMY = 0.5
const float FERRO_WALL_DARKVISION_FX_SCALAR_TEAM = 0.5
const float FERRO_WALL_DARKVISION_FX_SCALAR_CATALYST = 0.5
const float FERRO_WALL_DARKZONE_OPACITY = 0.85

const vector FRIENDLY_FERRO_WALL_COLOR = <100, 160, 255>
const vector ENEMY_FERRO_WALL_COLOR = <223, 66, 30>

const vector FERRO_WALL_SOUND_MOVER_OFFSET = < 0, 0, 20>
const float  FERRO_WALL_SOUND_SNAP_DISTANCE = 300
const float FERRO_WALL_SOUND_MOVER_DURATION = 2.5
const float FERRO_WALL_SOUND_MOVER_DESTROY_BEFORE_START_WAIT_TIME = FERRO_WALL_PILLAR_DURATION * 2

const int FERRO_WALL_FX_VERSION = 1
const int FERRO_WALL_SFX_VERSION = 2
const float FERRO_WALL_ENCAP_DELAY = 0.0
const float FERRO_WALL_SLOPE_MODEL_THRESHOLD_DISTANCE_MIN = 25.0
const float FERRO_WALL_SLOPE_MODEL_THRESHOLD_DISTANCE_MAX = 100.0
const float FERRO_WALL_PASSTHROUGH_SOUND_LOOP_END_THRESHOLD_TIME = 2.0
const float FERRO_WALL_PASSTHROUGH_IMPACT_FX_KILL_TIME = 1.2
const int FERRO_WALL_IMPACT_FX_ENABLED = 1
const int FERRO_WALL_MAX_WALLS_PER_PLAYER = 1 // negative number is infinite
const int FERRO_WALL_MAX_WALLS_PER_GAME = -1 // negative number is infinite

enum eFerroWallOrientation
{
	LEFT_TO_RIGHT
	FORWARD
}

enum eFerroWallModelType
{
	TYPE_A
	TYPE_B
	TYPE_C
	NUM_TYPES
}

enum eFerroWallModelSize
{
	SIZE_SMALL
	SIZE_MEDIUM
	SIZE_LARGE
	NUM_SIZES
}

enum eFerroWallDeployType
{
	DEPLOY_OBJECT_PLACEMENT
	DEPLOY_PROJECTILE
}

struct FerroWallDarkVisionData
{
	int visionHandle
	int moveSlowHandle
	float endTime
}

struct TriggerMoveSlowData
{
	int handle
	int refCount
}

struct FerroWallProjectileData
{
	int lastModel
	float distanceIncrement
	int numSegments
}

struct SoundMoverData
{
	entity groundMover
	entity scaleUpMover
	entity scaleDownMover
}

struct
{
#if SERVER
	table< entity, FerroWallDarkVisionData > darkVisionData
	table<entity, TriggerMoveSlowData > moveSlowTable
	table<entity, FerroWallProjectileData > projectileData
	array< entity > activeWallsPerGame
#endif
#if CLIENT
	int colorCorrection = -1
	int darkVisionFXID      = -1 //Eye Vignette
	int darkVisionLimit0FX  = -1
	int darkVisionLimit1FX  = -1
	int darkVisionLimit2FX  = -1
	int darkVisionLimit3FX  = -1
	float darkVisionFXAlpha = 1.0
	float flashlightFXAlpha = 1.0
#endif //CLIENT

	//Live tuning
	float 	duration
	float	forwardDelay
	float 	scaleUpDelay
	float 	scaleUpTime
	float 	scaleDownTime
	int 	numSegments
	float	darkVisionFXMaxAlphaEnemy
	float	darkVisionFXMaxAlphaTeam
	float	darkVisionFlashlightOpacity
	float	darkVisionDurationEnemy
	float	darkVisionDurationTeam
	float	soundMoverDuration
	float	soundMoverDestroyIfNotStartedTime
	int 	impactFxEnabled
	float	slowServerityPlayer
	float	slowServerityNPC
	float	darkVisionDurationNPC
	int		maxWallsPerPlayer
	int		maxWallsPerGame


}file

void function MpWeaponFerroWall_Init()
{
	#if SERVER
		RegisterSignal( "StopDarkVision" )
		RegisterSignal( START_SOUND_SIGNAL )
		Bleedout_AddCallback_CleanupUtilitySlot( FerroWall_CleanupWeaponOnBleedout )
	#endif //SERVER

	#if CLIENT
		RegisterSignal( "DarkVisionMode_StopColorCorrection" )
		RegisterSignal( "DarkVisionMode_StopActivationScreenFX" )
		RegisterSignal( "DarkVisionMode_CancelFadeOut" )
		RegisterSignal( KILL_CLIENT_THREAD_SIGNAL )
		file.colorCorrection = ColorCorrection_Register( "materials/correction/ability_hunt_mode.raw_hdr" )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.ferro_darkvision, FerroWallDarkVision_StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.ferro_darkvision, FerroWallDarkVision_StopVisualEffect )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.ferro_darkvision_team, FerroWallDarkVision_StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.ferro_darkvision_team, FerroWallDarkVision_StopVisualEffect )
		AddTargetNameCreateCallback( FERRO_WALL_INFO_TARGET_NAME, OnFerroWallPillarCreated )
	#endif

	PrecacheModel( FERRO_WALL_MODEL_A_SMALL )
	PrecacheModel( FERRO_WALL_MODEL_A_MEDIUM )
	PrecacheModel( FERRO_WALL_MODEL_A_LARGE )
	PrecacheModel( FERRO_WALL_MODEL_B_SMALL )
	PrecacheModel( FERRO_WALL_MODEL_B_MEDIUM )
	PrecacheModel( FERRO_WALL_MODEL_B_LARGE )
	PrecacheModel( FERRO_WALL_MODEL_C_SMALL )
	PrecacheModel( FERRO_WALL_MODEL_C_MEDIUM )
	PrecacheModel( FERRO_WALL_MODEL_C_LARGE )
	PrecacheModel( FERRO_WALL_MODEL_AR )
	PrecacheModel( FERRO_WALL_MODEL_SLOPE )
	PrecacheParticleSystem( FERRO_WALL_DARKEYE_VIGNETTE_FX )
	PrecacheParticleSystem( FERRO_WALL_DEBUG_SPHERE_VISION_LIMIT_FX )
	PrecacheParticleSystem( FERRO_WALL_DARK_ZONE_SHROUD_FX )
	PrecacheParticleSystem( FERRO_WALL_WALKTHROUGH_SPLASH )
	PrecacheParticleSystem( FERRO_WALL_PASSTHROUGH_IMPACT )

	AddCallback_OnPassThrough( FerroWallPassThroughFX )

	foreach ( fx in FERRO_WALL_BASE_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}
	foreach ( fx in FERRO_WALL_LAUNCH_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}
	foreach ( fx in FERRO_WALL_LAUNCH_WATER_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}
	foreach ( fx in FERRO_WALL_IDLE_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}
	foreach ( fx in FERRO_WALL_IDLE_WATER_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}
	foreach ( fx in FERRO_WALL_FINISHED_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}
	foreach ( fx in FERRO_WALL_FINISHED_WATER_FX_ARRAY )
	{
		PrecacheParticleSystem( fx )
	}

	foreach ( ar in FERRO_WALL_BASE_FX_TYPE_ARRAY )
	{
		foreach ( fx in ar )
		{
			PrecacheParticleSystem( fx )
		}
	}

	foreach ( ar in FERRO_WALL_BASE_WATER_FX_TYPE_ARRAY )
	{
		foreach ( fx in ar )
		{
			PrecacheParticleSystem( fx )
		}
	}

	//Live tuning
	file.duration 							= GetCurrentPlaylistVarFloat( "catalyst_wall_duration", FERRO_WALL_PILLAR_DURATION )
	file.forwardDelay						= GetCurrentPlaylistVarFloat( "catalyst_wall_forwardDelay", FERRO_WALL_PILLAR_DELAY_FORWARD )
	file.scaleUpDelay 						= GetCurrentPlaylistVarFloat( "catalyst_wall_scaleUpDelay", FERRO_WALL_PILLAR_DELAY_BEFORE_SCALING )
	file.scaleUpTime 						= GetCurrentPlaylistVarFloat( "catalyst_wall_scaleUpTime", FERRO_WALL_PILLAR_SCALE_TIME )
	file.scaleDownTime 						= GetCurrentPlaylistVarFloat( "catalyst_wall_scaleDownTime", FERRO_WALL_PILLAR_DESCALE_TIME )
	file.numSegments 						= GetCurrentPlaylistVarInt( "catalyst_wall_numSegments", FERRO_WALL_NUM_PILLARS_FORWARD )
	file.darkVisionFXMaxAlphaEnemy 			= GetCurrentPlaylistVarFloat( "catalyst_wall_darkVisionFXMaxAlphaEnemy", FERRO_WALL_DARKVISION_FX_ALPHA_END )
	file.darkVisionFXMaxAlphaTeam 			= GetCurrentPlaylistVarFloat( "catalyst_wall_darkVisionFXMaxAlphaTeam", FERRO_WALL_DARKVISION_FX_ALPHA_END_TEAM )
	file.darkVisionFlashlightOpacity 		= GetCurrentPlaylistVarFloat( "catalyst_wall_darkVisionFlashlightOpacity", FERRO_WALL_DARKVISION_OPACITY )
	file.darkVisionDurationEnemy 			= GetCurrentPlaylistVarFloat( "catalyst_wall_darkVisionDurationEnemy", FERRO_WALL_DARKVISION_DURATION )
	file.darkVisionDurationTeam 			= GetCurrentPlaylistVarFloat( "catalyst_wall_darkVisionDurationTeam", FERRO_WALL_DARKVISION_TEAM_DURATION )
	file.soundMoverDuration 				= GetCurrentPlaylistVarFloat( "catalyst_wall_soundMoverDuration", FERRO_WALL_SOUND_MOVER_DURATION )
	file.soundMoverDestroyIfNotStartedTime 	= GetCurrentPlaylistVarFloat( "catalyst_wall_soundMoverDestroyIfNotStartedTime", FERRO_WALL_SOUND_MOVER_DESTROY_BEFORE_START_WAIT_TIME )
	file.impactFxEnabled				 	= GetCurrentPlaylistVarInt( "catalyst_wall_impactFxEnabled", FERRO_WALL_IMPACT_FX_ENABLED )
	file.slowServerityPlayer				= GetCurrentPlaylistVarFloat( "catalyst_wall_slowServerityPlayer", FERRO_WALL_SLOW_SCALER )
	file.slowServerityNPC				 	= GetCurrentPlaylistVarFloat( "catalyst_wall_slowServerityNPC", FERRO_WALL_SLOW_NPC_SCALER )
	file.darkVisionDurationNPC				= GetCurrentPlaylistVarFloat( "catalyst_wall_darkVisionDurationNPC", FERRO_WALL_SLOW_NPC_TIME_SCALER )
	file.maxWallsPerPlayer					= GetCurrentPlaylistVarInt( "catalyst_wall_maxWallsPerPlayer", FERRO_WALL_MAX_WALLS_PER_PLAYER ) // negative number is infinite
	file.maxWallsPerGame					= GetCurrentPlaylistVarInt( "catalyst_wall_maxWallsPerGame", FERRO_WALL_MAX_WALLS_PER_GAME ) // negative number is infinite
}

                    
float function GetUpgradedWallDuration()
{
	return GetCurrentPlaylistVarFloat( "catalyst_ult_upgraded_duration", UPGRADE_FERRO_WALL_PILLAR_DURATION )
}

int function GetUpgradedWallLength()
{
	return GetCurrentPlaylistVarInt( "catalyst_ult_upgraded_length", UPGRADE_FERRO_WALL_NUM_PILLARS_FORWARD )
}
      

float function GetWallDuration( entity player )
{
	float result = file.duration
	                    
		if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_catalyst_ult_duration
		{
			result = GetUpgradedWallDuration()
			file.soundMoverDestroyIfNotStartedTime = UPGRADE_FERRO_WALL_PILLAR_DURATION * 2
		}
       
	return result
}

int function GetWallLength( entity player )
{
	int result = file.numSegments
	                    
		if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_THREE ) ) // upgrade_catalyst_ult_length
		{
			result = GetUpgradedWallLength()
		}
       
	return result
}


void function OnWeaponActivate_weapon_ferro_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	bool serverOrPredicted = IsServer() || (InPrediction() && IsFirstTimePredicted())
	if ( serverOrPredicted )
	{
		weapon.AddMod( ABILITY_ACTIVE_MOD )
		weapon.RemoveMod( ABILITY_USED_MOD )
	}

	#if CLIENT
		if( IsValid( ownerPlayer ) && ownerPlayer == GetLocalViewPlayer() && weapon.GetWeaponSettingEnum( eWeaponVar.fire_mode, eWeaponFireMode ) == eWeaponFireMode.offhandHybrid )
			thread WeaponActive_Client( ownerPlayer, weapon )
	#endif
	#if SERVER
		weapon.w.wasFired = false
	#endif
}


void function OnWeaponDeactivate_weapon_ferro_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		if( ownerPlayer == GetLocalViewPlayer() )
			weapon.Signal( KILL_CLIENT_THREAD_SIGNAL )
	#endif

	#if SERVER
		if( weapon.w.wasFired )
		{
			UnlockWeaponsAndMelee( ownerPlayer, FERRO_WALL_WEAPON_NAME )
			weapon.w.wasFired = false
		}
	#endif

	bool serverOrPredicted = IsServer() || (InPrediction() && IsFirstTimePredicted())
	if ( serverOrPredicted )
	{
		weapon.RemoveMod( ABILITY_ACTIVE_MOD )
	}
}


bool function OnWeaponAttemptOffhandSwitch_weapon_ferro_wall( entity weapon )
{
	if( file.maxWallsPerGame == 0 || file.maxWallsPerPlayer == 0 )
		return false

	return true
}


var function OnWeaponTossReleaseAnimEvent_weapon_ferro_wall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FerroWallAttack_Common( weapon, attackParams )
}

var function OnWeaponPrimaryAttack_weapon_ferro_wall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FerroWallAttack_Common( weapon, attackParams )
}

var function FerroWallAttack_Common( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )


	vector targetOrigin
	entity targetParent
	vector startAngles = ZERO_VECTOR
	vector ownerOrigin = ownerPlayer.EyePosition()
	//int deployMethod = GetPlaylistVarInt( GetCurrentPlaylistName(), "ferro_wall_deploy_type", eFerroWallDeployType.DEPLOY_PROJECTILE )
	int deployMethod = GetPlaylistVarInt( GetCurrentPlaylistName(), "ferro_wall_deploy_type", eFerroWallDeployType.DEPLOY_OBJECT_PLACEMENT )
	if( deployMethod == eFerroWallDeployType.DEPLOY_OBJECT_PLACEMENT )
	{
		
		entity placementParent = weapon.GetObjectPlacementParent()
		array<entity> ignoreArray = GetFerroWallIgnoreArray()
		if( weapon.ObjectPlacementHasValidSpot() && ( !IsValid( placementParent ) || !ignoreArray.contains( placementParent ) ) )
		{
			targetOrigin = weapon.GetObjectPlacementOrigin()
			printt("Ferrofluid targetorigin hasvalidspot" + weapon.GetObjectPlacementOrigin())
		}
		else
		{
			TraceResults fwdTrace = TraceLine( ownerOrigin, ownerOrigin + FlattenNormalizeVec( ownerPlayer.GetViewVector() ) * FERRO_WALL_DEFAULT_FWD_DISTANCE, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
			TraceResults downTrace = TraceLine( fwdTrace.endPos, fwdTrace.endPos + < 0, 0, -400 >, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
			if( downTrace.fraction == 1.0 )
			{
				#if CLIENT
					AddPlayerHint( 1, 0.0, $"", "#WPN_FERRO_WALL_WARNING_NO_GROUND" )
					EmitSoundOnEntity( ownerPlayer, "Survival_UI_Ability_NotReady" )
				#endif
				return 0
			}
			targetOrigin = downTrace.endPos
			printt("Ferrofluid targetorigin hasnotvalidspot" + targetOrigin )
		}

		vector angles = < 0, startAngles.y, 0 >
		#if SERVER
			int type = GetPlaylistVarInt( GetCurrentPlaylistName(), "ferro_wall_type", eFerroWallOrientation.FORWARD )
			if( type == eFerroWallOrientation.FORWARD )
			{
				thread CreateWallThread( weapon, targetOrigin, ownerPlayer.GetViewForward(), GetWallLength( ownerPlayer ) , file.forwardDelay  )
			}
			else if( type == eFerroWallOrientation.LEFT_TO_RIGHT )
			{
				SoundMoverData data
				thread CreateFerroWallPillar( FERRO_WALL_MODEL_A_SMALL, FERRO_WALL_BASE_FX_A, targetOrigin + < 0, 0, FERRO_WALL_PILLAR_Z_OFFSET >, angles, ownerPlayer, null, ownerPlayer.GetTeam(), eFerroWallModelSize.SIZE_SMALL, data )
				thread CreateWallThread( weapon, targetOrigin, ownerPlayer.GetViewRight(), FERRO_WALL_NUM_PILLARS_HORIZONTAL_PER_SIDE, FERRO_WALL_PILLAR_DELAY_HORIZONTAL, FERRO_WALL_STEP )
				thread CreateWallThread( weapon, targetOrigin, -ownerPlayer.GetViewRight(), FERRO_WALL_NUM_PILLARS_HORIZONTAL_PER_SIDE, FERRO_WALL_PILLAR_DELAY_HORIZONTAL, FERRO_WALL_STEP )
			}
			else
			{
				thread CreateWallThread( weapon, targetOrigin, ownerPlayer.GetViewForward(), GetWallLength( ownerPlayer ) , file.forwardDelay  )
			}
		#endif

	}
	else if( deployMethod == eFerroWallDeployType.DEPLOY_PROJECTILE )
	{
		#if CLIENT
			if ( !weapon.ShouldPredictProjectiles() )
				return
		#endif

		WeaponFireGrenadeParams fireGrenadeParams
		fireGrenadeParams.pos = attackParams.pos
		fireGrenadeParams.vel = attackParams.dir
		fireGrenadeParams.scriptTouchDamageType = damageTypes.projectileImpact
		fireGrenadeParams.scriptExplosionDamageType = damageTypes.explosive
		fireGrenadeParams.clientPredicted = true
		fireGrenadeParams.lagCompensated = true
		fireGrenadeParams.useScriptOnDamage = true
		entity grenade = weapon.FireWeaponGrenade( fireGrenadeParams )

		#if SERVER
			if( IsValid( grenade ) )
			{
				grenade.proj.savedOrigin = attackParams.pos
				grenade.proj.savedDir = attackParams.dir
				FerroWallProjectileData data
				data.lastModel = eFerroWallModelSize.SIZE_SMALL
				data.distanceIncrement = FERRO_WALL_STEP
				data.numSegments = 0
				file.projectileData[ grenade ] <- data
				thread ProjectileThread( grenade, ownerPlayer )
			}
		#endif


	}

	PlayerUsedOffhand( ownerPlayer, weapon, true, null, { pos = targetOrigin } )
	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( ownerPlayer, weapon.GetWeaponSettingString( eWeaponVar.battle_chatter_event ) )
		weapon.w.wasFired = true
		LockWeaponsAndMelee( ownerPlayer, FERRO_WALL_WEAPON_NAME )
	#endif
	#if CLIENT
		if( ownerPlayer == GetLocalViewPlayer() )
			weapon.Signal( KILL_CLIENT_THREAD_SIGNAL )
	#endif

	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if ( serverOrPredicted )
	{
		weapon.AddMod( ABILITY_USED_MOD )
	}

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

bool function OnWeaponChargeBegin_weapon_ferro_wall( entity weapon )
{
	return true
}

void function OnWeaponChargeEnd_weapon_ferro_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
}

void function OnProjectileCollision_weapon_ferro_wall( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	projectile.SetVelocity( ZERO_VECTOR )
	#if SERVER
		projectile.Destroy()
	#endif
}

vector function GetProjectileVelocity_weapon_ferro_wall( entity projectile, float timeElapsed, float timeStep )
{
	#if SERVER
		vector launchDirection = projectile.proj.savedDir
		launchDirection = <launchDirection.x, launchDirection.y, 0.0>
		launchDirection = Normalize( launchDirection )
		vector angles = VectorToAngles( launchDirection )
		angles = RotateAnglesAboutAxis( angles, UP_VECTOR, 90 )
		int lastModelType = file.projectileData[ projectile ].lastModel
		int modelSize = eFerroWallModelSize.SIZE_SMALL
		vector lastOrigin = projectile.proj.savedOrigin
		vector projectileOrigin = projectile.GetOrigin()
		projectile.proj.savedOrigin = projectileOrigin
		float flatDistanceTravelledThisFrame = Distance2D( projectileOrigin, lastOrigin )

		if( flatDistanceTravelledThisFrame == 0 )
			return projectile.GetVelocity()

		float distanceInc = file.projectileData[ projectile ].distanceIncrement
		float flatDistance = 0
		vector pathDir = Normalize( projectileOrigin - lastOrigin )
		float adjacentAngle = DotToAngle( pathDir.Dot( launchDirection ) )

		while( ( flatDistance + distanceInc <= flatDistanceTravelledThisFrame ) && ( file.projectileData[ projectile ].numSegments < GetWallLength( projectile.GetOwner() ) ) )
		{
			flatDistance += distanceInc

			float pathLength = ( flatDistance ) / deg_cos( adjacentAngle )
			vector pathOrigin = lastOrigin + ( pathLength * pathDir )

			distanceInc = FERRO_WALL_STEP

			vector endOrigin         = <pathOrigin.x, pathOrigin.y, pathOrigin.z - 2000 >
			array <entity> ignoreArray = GetPlayerArray_Alive()
			ignoreArray.extend( GetNPCArray() )
			ignoreArray.append( projectile )
			TraceResults traceResult = TraceLine( pathOrigin, endOrigin, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, projectile )
			if( IsValid( traceResult.hitEnt ) )
			{
				float minHeight = FERRO_WALL_HEIGHT * eFerroWallModelSize.NUM_SIZES
				vector heightTraceStart = traceResult.endPos
				TraceResults heightCheck = TraceLine( heightTraceStart, heightTraceStart + < 0, 0, FERRO_WALL_HEIGHT * eFerroWallModelSize.NUM_SIZES >, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
				minHeight = min( heightCheck.endPos.z - heightTraceStart.z, minHeight )

				if( minHeight >= ( ( FERRO_WALL_HEIGHT * 3.0 ) - FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER ) )
					modelSize = eFerroWallModelSize.SIZE_LARGE
				else if( minHeight >= ( ( FERRO_WALL_HEIGHT * 2.0 ) - FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER ) )
					modelSize = eFerroWallModelSize.SIZE_MEDIUM
				else
					modelSize = eFerroWallModelSize.SIZE_SMALL

				int modelType = RandomInt( eFerroWallModelType.NUM_TYPES )
				while( lastModelType == modelType )
				{
					modelType = RandomInt( eFerroWallModelType.NUM_TYPES )
				}
				file.projectileData[ projectile ].lastModel = modelType
				asset model = FERRO_WALL_MODEL_TYPE_ARRAY[ modelType ][ modelSize ]
				float rotation = 0.0 // : 180.0
				vector modelAngles = RotateAnglesAboutAxis( angles, UP_VECTOR, rotation )
				SoundMoverData data
				thread CreateFerroWallPillar( model, FERRO_WALL_BASE_FX_A, heightTraceStart + < 0, 0, FERRO_WALL_PILLAR_Z_OFFSET >, modelAngles, projectile.GetOwner(), traceResult.hitEnt, projectile.GetTeam(), modelSize, data )
				file.projectileData[ projectile ].numSegments++
			}
		}
		file.projectileData[ projectile ].distanceIncrement = ( flatDistance + distanceInc ) - flatDistanceTravelledThisFrame
	#endif

	return projectile.GetVelocity()
}

bool function FerroWall_BlockScan( vector startPos, vector endPos )
{
                                 


	return false
     
                                                                                                
                      
                                                              

             
       
}

#if SERVER
void function FerroWall_CleanupWeaponOnBleedout( entity player )
{
	if( !IsValid( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if( IsValid( weapon ) && weapon.GetWeaponClassName() == FERRO_WALL_WEAPON_NAME && weapon.w.wasFired )
	{
		UnlockWeaponsAndMelee( player, FERRO_WALL_WEAPON_NAME )
		weapon.w.wasFired = false
	}
}

void function ProjectileThread( entity grenade, entity weaponOwner )
{
	EndSignal( grenade, "OnDestroy" )
	EndSignal( weaponOwner, "OnDestroy" )
	EndSignal( weaponOwner, "OnDeath" )

	OnThreadEnd( void function() : ( grenade ) {
		if( grenade in file.projectileData )
			delete file.projectileData[ grenade ]
		if( IsValid( grenade ) )
				grenade.Destroy()
		} )

	while( file.projectileData[ grenade ].numSegments < GetWallLength( weaponOwner ) )
	{
		 WaitFrame()
	}
}
vector function TestToGround( vector origin, int traceMask = TRACE_MASK_NPCWORLDSTATIC, entity tracingEnt = null )
{
	vector endOrigin         = <origin.x, origin.y, -MAX_WORLD_COORD_BUFFER >
	array <entity> ignoreArray = GetPlayerArray_Alive()
	if ( IsValid( tracingEnt ) )
		ignoreArray.append( tracingEnt )

	TraceResults traceResult = TraceLine( origin, endOrigin, ignoreArray, traceMask, TRACE_COLLISION_GROUP_NONE, tracingEnt )

	return traceResult.endPos
}

void function SoundMoverThread( entity soundMover, string sound )
{

}

void function DelayedInfoTargetDestroy( entity infoTarget, entity owner )
{
	EndSignal( infoTarget, "OnDestroy" )
	EndSignal( owner, "OnDestroy" )
	EndSignal( owner, "SquadEliminated" )

	OnThreadEnd( void function() : ( infoTarget, owner ) {
		if( IsValid( infoTarget ) || IsInvalidButMemberVarsStillValid( infoTarget ) )
		{
			array< entity > walls = infoTarget.GetLinkEntArray()
			foreach( wall in walls )
			{
				if( IsValid( wall ) )
					wall.Destroy()
			}

			if ( file.activeWallsPerGame.contains( infoTarget ) )
			{
				for ( int i = file.activeWallsPerGame.len() - 1; i >= 0 ; i-- )
				{
					if ( file.activeWallsPerGame[i] == infoTarget )
					{
						file.activeWallsPerGame.remove( i )
					}
				}
			}

			                      
			if ( owner.e.activeCopycatTraps.len() > 0 )
			{
				if ( IsValid( owner ) )
				{
					if ( owner.e.activeCopycatTraps.contains( infoTarget ) )
					{
						for ( int i = owner.e.activeCopycatTraps.len() - 1; i >= 0 ; i-- )
						{
							if ( owner.e.activeCopycatTraps[i] == infoTarget )
							{
								owner.e.activeCopycatTraps.remove( i )
							}
						}
					}
				}
			}
         
			if( IsValid( owner ) )
			{
				if ( owner.e.activeUltimateTraps.contains( infoTarget ) )
				{
					for ( int i = owner.e.activeUltimateTraps.len() - 1; i >= 0 ; i-- )
					{
						if ( owner.e.activeUltimateTraps[i] == infoTarget )
						{
							owner.e.activeUltimateTraps.remove( i )
						}
					}
				}
			}

			if( IsValid( infoTarget ) )
				infoTarget.Destroy()
		}
	} )

	wait file.soundMoverDestroyIfNotStartedTime
}

void function CreateWallThread( entity weapon, vector pos, vector dir, int numPillars, float delay, float initalStep = FERRO_WALL_STEP_INIT )
{
	EndSignal( weapon, "OnDestroy" )

	float traceStep = initalStep
	entity owner = weapon.GetWeaponOwner()
	dir = <dir.x, dir.y, 0.0>
	dir = Normalize( dir )
	vector angles = VectorToAngles( dir )
	angles = RotateAnglesAboutAxis( angles, UP_VECTOR, 90 )

	int teamId = owner.GetTeam()

	bool firstTrace = true
	vector traceStart = pos + < 0, 0, FERRO_WALL_CLIMB_HEIGHT_INIT >
	bool endTraces = false
	int lastModelType = eFerroWallModelType.TYPE_A
	int modelSize = eFerroWallModelSize.SIZE_SMALL
	int lastFxIndex = 0
	bool placed = false
	vector lastPosition = ZERO_VECTOR

	if( file.maxWallsPerGame == 0 || file.maxWallsPerPlayer == 0 )
		return

	//Update global wall count
	if( file.maxWallsPerGame > 0 )
	{
		while ( file.activeWallsPerGame.len() >= file.maxWallsPerGame )
		{
			entity entToDelete = file.activeWallsPerGame.top()
			if ( IsValid( entToDelete ) )
			{
				entToDelete.Destroy()
			}
		}
	}

	                      
		if ( weapon.HasMod( COPYCAT_MOD ) )
		{
			if( file.maxWallsPerPlayer > 0 )
			{
				while ( owner.e.activeCopycatTraps.len() >= file.maxWallsPerPlayer )
				{
					entity entToDelete =  owner.e.activeCopycatTraps.top()
					if ( IsValid( entToDelete ) )
					{
						entToDelete.Destroy()
					}
				}
			}
		}
		else
       
		//Update player wall count
		if( file.maxWallsPerPlayer > 0 )
		{
			while ( owner.e.activeUltimateTraps.len() >= file.maxWallsPerPlayer )
			{
				entity entToDelete =  owner.e.activeUltimateTraps.top()
				if ( IsValid( entToDelete ) )
				{
					entToDelete.Destroy()
				}
			}
		}

	entity infoTarget = CreateEntity( "info_target" )
	infoTarget.RemoveFromAllRealms()
	infoTarget.AddToOtherEntitysRealms( owner )
	infoTarget.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTargetName( infoTarget, FERRO_WALL_INFO_TARGET_NAME )
	SetTeam( infoTarget, teamId )
	DispatchSpawn( infoTarget )
	thread DelayedInfoTargetDestroy( infoTarget, owner )
	EndSignal( infoTarget, "OnDestroy" )
	file.activeWallsPerGame.insert( 0, infoTarget )
	                      
		if ( weapon.HasMod( COPYCAT_MOD ) )
		{
			owner.e.activeCopycatTraps.insert( 0, infoTarget )
		}
		else
       
	owner.e.activeUltimateTraps.insert( 0, infoTarget )

	if( IsValid( owner ) )
	{
		FiringRange_AddToRemoveOnCharacterChange( infoTarget, owner )
	}

	SoundMoverData data
	data.groundMover = CreateScriptMover( "", traceStart )
	data.groundMover.SetParent( infoTarget )
	data.groundMover.RemoveFromAllRealms()
	data.groundMover.AddToOtherEntitysRealms( infoTarget )
	thread SoundMoverThread( data.groundMover, FERRO_WALL_BASE_LAUNCH_3P )
	data.scaleUpMover = CreateScriptMover( "", traceStart )
	data.scaleUpMover.SetParent( infoTarget )
	data.scaleUpMover.RemoveFromAllRealms()
	data.scaleUpMover.AddToOtherEntitysRealms( infoTarget )
	thread SoundMoverThread( data.scaleUpMover, FERRO_WALL_BASE_RISING_3P )
	data.scaleDownMover = CreateScriptMover( "", traceStart )
	data.scaleDownMover.SetParent( infoTarget )
	data.scaleDownMover.RemoveFromAllRealms()
	data.scaleDownMover.AddToOtherEntitysRealms( infoTarget )
	thread SoundMoverThread( data.scaleDownMover, FERRO_WALL_BASE_FALLING_3P )

	for ( int i = 0; i < numPillars; i++ )
	{
		array<entity> ignoreArray = GetFerroWallIgnoreArray()

		array< entity > walls = infoTarget.GetLinkEntArray()
		int wallsCount = walls.len()
		if( wallsCount > 0 && wallsCount == i && IsValid( walls[ 0 ] ) && IsValid( walls[ 0 ].GetParent() ) )
		{
			traceStart = walls[ 0 ].GetOrigin() + < 0, 0, FERRO_WALL_CLIMB_HEIGHT >
		}

		vector traceFwdEnd = traceStart + ( dir * traceStep )
		TraceResults forwardTrace = TraceLine( traceStart, traceFwdEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if( forwardTrace.fraction < 1.0 )
		{
			vector traceUpEnd = forwardTrace.endPos + < 0, 0, FERRO_WALL_RETRY_CLIMB_HEIGHT >
			TraceResults upTrace = TraceLine( forwardTrace.endPos, traceUpEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			traceStart = upTrace.endPos
			traceFwdEnd = traceStart + ( dir * ( traceStep * ( 1.0 - forwardTrace.fraction ) ) )
			forwardTrace = TraceLine( traceStart, traceFwdEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if( forwardTrace.fraction < 1.0 )
				break
		}
		#if DEVELOPER && FERRO_WALL_DEBUG_DRAW
			DebugDrawLine( traceStart, forwardTrace.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
		#endif

		vector traceDownEnd = forwardTrace.endPos + < 0, 0, -FERRO_WALL_DOWN_TRACE_LENGTH >
		TraceResults downTrace = TraceLine( forwardTrace.endPos, traceDownEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if( downTrace.fraction == 1.0 )
		{
			endTraces = true
		}
		else
		{
			float minHeight = FERRO_WALL_HEIGHT * eFerroWallModelSize.NUM_SIZES
			vector heightTraceStart = downTrace.endPos
			TraceResults heightCheck = TraceLine( heightTraceStart, heightTraceStart + < 0, 0, FERRO_WALL_HEIGHT * eFerroWallModelSize.NUM_SIZES >, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			minHeight = min( heightCheck.endPos.z - heightTraceStart.z, minHeight )

			if( minHeight >= ( ( FERRO_WALL_HEIGHT * 3.0 ) - FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER ) )
				modelSize = eFerroWallModelSize.SIZE_LARGE
			else if( minHeight >= ( ( FERRO_WALL_HEIGHT * 2.0 ) - FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER ) )
				modelSize = eFerroWallModelSize.SIZE_MEDIUM
			else
				modelSize = eFerroWallModelSize.SIZE_SMALL

			int modelType = RandomInt( eFerroWallModelType.NUM_TYPES )
			while( !firstTrace && lastModelType == modelType )
			{
				modelType = RandomInt( eFerroWallModelType.NUM_TYPES )
			}
			lastModelType = modelType

			bool inWater = false
			TraceResults waterTraceResult = TraceLineHighDetail( downTrace.endPos, downTrace.endPos + < 0, 0, 300 >, [], TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
			if( waterTraceResult.fraction < 1.0 )
				inWater = true

			asset model = FERRO_WALL_MODEL_TYPE_ARRAY[ modelType ][ modelSize ]
			float rotation = 0.0 // : 180.0
			vector modelAngles = RotateAnglesAboutAxis( angles, UP_VECTOR, rotation )
			int fxIndex = RandomInt( FERRO_WALL_BASE_FX_ARRAY.len() )
			while( !firstTrace && lastFxIndex == fxIndex )
			{
				fxIndex = RandomInt( FERRO_WALL_BASE_FX_ARRAY.len() )
			}
			lastFxIndex = fxIndex
			asset baseFx = FERRO_WALL_BASE_FX_ARRAY[ fxIndex ]
			thread CreateFerroWallPillar( model, baseFx, downTrace.endPos + < 0, 0, FERRO_WALL_PILLAR_Z_OFFSET >, modelAngles, owner, downTrace.hitEnt, teamId, modelSize, data, infoTarget, lastFxIndex, inWater )
			traceStart = downTrace.endPos + < 0, 0, FERRO_WALL_CLIMB_HEIGHT >
			placed = true
			lastPosition = downTrace.endPos + < 0, 0, FERRO_WALL_PILLAR_Z_OFFSET >
			if( i == 0 )
			{
				TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_CATALYST_DARK_VEIL_START, owner, lastPosition, teamId, infoTarget )
			}
		}
		#if DEVELOPER && FERRO_WALL_DEBUG_DRAW
			DebugDrawLine( forwardTrace.endPos, downTrace.endPos, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 25.0 )
		#endif

		if( endTraces )
			break

		if( firstTrace )
		{
			traceStep = FERRO_WALL_STEP
			firstTrace = false
		}

		wait delay
	}

	if( IsValid( infoTarget ) )
	{
		array< entity > walls = infoTarget.GetLinkEntArray()
		int wallsCount = walls.len()
		for( int i = 0; i < wallsCount; i++ )
		{
			if( IsValid( walls[ i ] ) )
			{
				walls[ i ].e.lastWallSegment = true
				if( wallsCount > 1 )
					TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_CATALYST_DARK_VEIL_END, owner, walls[ i ].GetOrigin(), teamId, infoTarget )
				break
			}
		}
	}
}
void function WaitForDestructiveAction( entity pillar )
{
	EndSignal( pillar, "OnDestroy" )

	OnThreadEnd(
		function () : ( pillar )
		{
			if( IsValid( pillar ) )
				pillar.Destroy()
		}
	)

	WaitFrame()

	while( true )
	{
		entity parentEnt = pillar.GetParent()
		if( IsValid( parentEnt ) )
		{
			entity lootBin = GetLootBinForHitEnt( parentEnt )
			if( lootBin && LootBin_IsBusy( lootBin ) )
			{
				return
			}

			entity armoryDoor = GetArmoryDoorEnt( parentEnt )
			if( armoryDoor && armoryDoor.Anim_IsActive() )
			{
				return
			}
		}
		WaitFrame()
	}
}

entity function GetArmoryDoorEnt( entity hitEnt )
{
	if ( hitEnt.GetScriptName() == "armory_entry_hatch_rig" )
		return hitEnt

	entity parentEnt = hitEnt.GetParent()
	if ( IsValid( parentEnt ) && parentEnt.GetScriptName() == "armory_entry_hatch_rig" )
		return parentEnt

	return null
}

void function CreateFerroWallPillar( asset model, asset baseFX, vector pos, vector angles, entity attacker, entity newParent, int teamId, int modelSize, SoundMoverData soundMoverData, entity infoTarget = null, int variationIndex = 0, bool inWater = false )
{
                                 
	int contents = CONTENTS_BLOCK_PING | CONTENTS_BLOCKLOS | CONTENTS_WINDOW
     
                                                                         
        
	entity pillar = CreateResinShard( model, pos, angles, teamId, FERRO_WALL_PILLAR_HEALTH, contents, true, -1, null, false )
	//pillar.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_SCANS
	//pillar.kv.CollisionGroup = TRACE_COLLISION_GROUP_PERMEABLE
	pillar.SetPassThroughThickness( 0 )
	pillar.SetPassThroughDirection( 0 )
	//pillar.SetPassThroughFlags( PTF_ADDS_MODS | PTF_NO_DMG_ON_PASS_THROUGH | PTF_BLOCKS_PING )
	SetVisibleEntitiesInConeQueriableEnabled( pillar, true )
	pillar.SetBlocksRadiusDamage( false )
	MarkEntForCleanupOnRoundEnd( pillar )
	EndSignal( pillar, "OnDestroy" )
	pillar.Solid()
	pillar.SetModelScale( 0 )
	pillar.SetBlocksLOS( true )
	SetTargetName( pillar, FERRO_WALL_SEGMENT_TARGET_NAME )
	pillar.SetUsePrompts( FERRO_WALL_SEGMENT_TARGET_NAME, FERRO_WALL_SEGMENT_TARGET_NAME )
	pillar.e.destroyIfBubbleShieldParentDestroyed = true
	thread WaitForDestructiveAction( pillar )

	if( IsValid( infoTarget ) )
	{
		pillar.RemoveFromAllRealms()
		pillar.AddToOtherEntitysRealms( infoTarget )
		infoTarget.LinkToEnt( pillar )

		if( modelSize == eFerroWallModelSize.SIZE_LARGE )
		{
			array< entity > walls = infoTarget.GetLinkEntArray()
			int wallCount  = walls.len()
			if( wallCount >= 2 )
			{
				entity lastWall = walls[ 1 ]
				if( IsValid( lastWall ) )
				{
					float heightDiff = fabs( lastWall.GetOrigin().z - pillar.GetOrigin().z )
					if( heightDiff >= FERRO_WALL_SLOPE_MODEL_THRESHOLD_DISTANCE_MIN && heightDiff <= FERRO_WALL_SLOPE_MODEL_THRESHOLD_DISTANCE_MAX )
					{
						vector newAngles = angles
						if( lastWall.GetOrigin().z > pillar.GetOrigin().z )
						{
							newAngles = RotateAnglesAboutAxis( angles, UP_VECTOR, 180 )
						}

						pillar.SetModel( FERRO_WALL_MODEL_SLOPE )
						pillar.SetAngles( newAngles )
						if( FERRO_WALL_LARGE_MODEL_ARRAY.contains( lastWall.GetModelName() ) )
						{
							lastWall.SetModel( FERRO_WALL_MODEL_SLOPE )
							entity lastWallParent = lastWall.GetParent()
							lastWall.ClearParent()
							lastWall.SetAngles( newAngles )
							if( IsValid( lastWallParent ) )
								lastWall.SetParent( lastWallParent )
						}
					}
				}

			}
		}

	}

	if( IsValid( newParent ) && !newParent.IsWorld() && newParent.DoesShareRealms( pillar ) )
		pillar.SetParent( newParent )

	OnThreadEnd(
		function () : ( pillar )
		{
			if( IsValid( pillar ) )
				pillar.Destroy()
		}
	)

	entity friendlyBasefx
	entity friendlyLaunchFx
	entity friendlyIdleFx
	entity friendlyFinishedFx

	if( FERRO_WALL_FX_VERSION == 1 )
	{
		int baseFXID  = ( inWater ) ? GetParticleSystemIndex( FERRO_WALL_BASE_WATER_FX_TYPE_ARRAY[ variationIndex ][ modelSize ] ) : GetParticleSystemIndex( FERRO_WALL_BASE_FX_TYPE_ARRAY[ variationIndex ][ modelSize ] )
		friendlyBasefx  = StartParticleEffectOnEntityWithPos_ReturnEntity( pillar, baseFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
		EffectSetControlPointVector( friendlyBasefx, 1, <45, 0, FERRO_WALL_DARKZONE_OPACITY> )
		EffectSetControlPointVector( friendlyBasefx, 2, FRIENDLY_FERRO_WALL_COLOR )
		EffectSetControlPointVector( friendlyBasefx, 3, ENEMY_FERRO_WALL_COLOR )
		//friendlyBasefx.SetEnemyControlPointOverride( 3, 2 )
		SetTeam( friendlyBasefx, teamId )

		OnThreadEnd(
			function () : ( pillar, friendlyBasefx )
			{
				if( IsValid( friendlyBasefx ) )
					EffectStop( friendlyBasefx )
			}
		)
	}
	else if( FERRO_WALL_FX_VERSION == 2 )
	{
		int launchFXId =  ( inWater ) ? GetParticleSystemIndex( FERRO_WALL_LAUNCH_WATER_FX_ARRAY[ modelSize ] ) : GetParticleSystemIndex( FERRO_WALL_LAUNCH_FX_ARRAY[ modelSize ] )
		friendlyLaunchFx  = StartParticleEffectOnEntityWithPos_ReturnEntity( pillar, launchFXId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
		EffectSetControlPointVector( friendlyLaunchFx, 1, <45, 0, FERRO_WALL_DARKZONE_OPACITY> )
		EffectSetControlPointVector( friendlyLaunchFx, 2, FRIENDLY_FERRO_WALL_COLOR )
		EffectSetControlPointVector( friendlyLaunchFx, 3, ENEMY_FERRO_WALL_COLOR )
		//friendlyLaunchFx.SetEnemyControlPointOverride( 3, 2 )
		SetTeam( friendlyLaunchFx, teamId )

		OnThreadEnd(
			function () : (friendlyLaunchFx )
			{
				if( IsValid( friendlyLaunchFx ) )
					EffectStop( friendlyLaunchFx )
			}
		)

		int idleFXId = ( inWater ) ? GetParticleSystemIndex( FERRO_WALL_IDLE_WATER_FX_ARRAY[ variationIndex ] ) : GetParticleSystemIndex( FERRO_WALL_IDLE_FX_ARRAY[ variationIndex ] )
		friendlyIdleFx  = StartParticleEffectOnEntityWithPos_ReturnEntity( pillar, idleFXId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
		EffectSetControlPointVector( friendlyIdleFx, 1, <45, 0, FERRO_WALL_DARKZONE_OPACITY> )
		EffectSetControlPointVector( friendlyIdleFx, 2, FRIENDLY_FERRO_WALL_COLOR )
		EffectSetControlPointVector( friendlyIdleFx, 3, ENEMY_FERRO_WALL_COLOR )
		//friendlyIdleFx.SetEnemyControlPointOverride( 3, 2 )
		SetTeam( friendlyIdleFx, teamId )

		OnThreadEnd(
			function () : ( friendlyIdleFx  )
			{
				if( IsValid( friendlyIdleFx ) )
					EffectStop( friendlyIdleFx )
			}
		)
	}

	entity soundMover = soundMoverData.groundMover
	if( IsValid( soundMover ) )
	{
		if( soundMover.e.isDisabled )
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, pillar.GetOrigin(), FERRO_WALL_ACTIVATE_3P, pillar )
			soundMover.Signal( START_SOUND_SIGNAL )
			soundMover.e.isDisabled = false
		}

		if( Distance( soundMover.GetOrigin(), pillar.GetOrigin() ) > FERRO_WALL_SOUND_SNAP_DISTANCE )
		{
			soundMover.NonPhysicsStop()
			soundMover.SetAbsOrigin( pillar.GetOrigin() + FERRO_WALL_SOUND_MOVER_OFFSET )
		}
		else
		{
			soundMover.NonPhysicsMoveTo( pillar.GetOrigin() + FERRO_WALL_SOUND_MOVER_OFFSET, file.forwardDelay, 0.0, 0.0 )
		}
	}


	float startTime = Time()
	float endTime = startTime + file.scaleUpDelay
	bool killSound = true
	while( endTime > Time() )
	{
		if( killSound && pillar.e.lastWallSegment && IsValid( soundMover ) && Time() >= ( startTime +  file.forwardDelay ) )
		{
			killSound = false
			soundMover.Destroy()
		}
		WaitFrame()
	}

	if( pillar.e.lastWallSegment && IsValid( soundMover ) )
		soundMover.Destroy()

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( pillar )
	trigger.SetCylinderRadius( FERRO_WALL_RADIUS )
	trigger.SetAboveHeight( FERRO_WALL_HEIGHT * ( modelSize + 1 ) )
	trigger.SetBelowHeight( 0 )
	trigger.SetOrigin( pillar.GetOrigin() )
	trigger.SetAngles( pillar.GetAngles() )
	trigger.SetEnterCallback( FerroWallTiggerEnter )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 0
	trigger.SetOwner( attacker )
	DispatchSpawn( trigger )
	SetTeam( trigger, pillar.GetTeam() )
	trigger.SetParent( pillar )
	trigger.SearchForNewTouchingEntity()
	EndSignal( trigger, "OnDestroy" )

	soundMover = soundMoverData.scaleUpMover
	if( IsValid( soundMover) )
	{
		if( soundMover.e.isDisabled )
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, pillar.GetOrigin(), FERRO_WALL_BASE_RAISE_START, pillar )
			soundMover.Signal( START_SOUND_SIGNAL )
			soundMover.e.isDisabled = false
		}

		if( inWater )
			EmitSoundAtPosition( TEAM_UNASSIGNED, pillar.GetOrigin(), FERRO_WALL_BASE_RISING_WATER_3P, pillar )

		if( Distance( soundMover.GetOrigin(), pillar.GetOrigin() ) > FERRO_WALL_SOUND_SNAP_DISTANCE )
		{
			soundMover.NonPhysicsStop()
			soundMover.SetAbsOrigin( pillar.GetOrigin() + FERRO_WALL_SOUND_MOVER_OFFSET )
		}
		else
		{
			soundMover.NonPhysicsMoveTo( pillar.GetOrigin() + FERRO_WALL_SOUND_MOVER_OFFSET, file.forwardDelay, 0.0, 0.0 )
		}
	}

	if( pillar.e.lastWallSegment)
		EmitSoundOnEntity( pillar, FERRO_WALL_COMPLETE_3P )

	startTime = Time()
	endTime = startTime + file.scaleUpTime
	killSound = true
	while( true )
	{
		if( killSound && pillar.e.lastWallSegment && IsValid( soundMover ) && Time() >= ( startTime +  file.forwardDelay ) )
		{
			killSound = false
			soundMover.Destroy()
		}

		float scale = GraphCapped( Time(), startTime, endTime, 0.0, 1.0 )
		pillar.SetModelScale( scale )
		if( scale >= 1.0 )
			break
		WaitFrame()
	}

	if( pillar.e.lastWallSegment && IsValid( soundMover ) )
		soundMover.Destroy()


	if( FERRO_WALL_FX_VERSION == 2 )
	{
		if( IsValid( friendlyLaunchFx ) )
			EffectStop( friendlyLaunchFx )
	}

	#if DEVELOPER && FERRO_WALL_DEBUG_DRAW
		vector pillarOrigin = trigger.GetOrigin()
		vector mins = CalcWorldToLocalOrigin_Entity( pillar, pillarOrigin + ( FERRO_WALL_RADIUS * pillar.GetRightVector() ) + ( FERRO_WALL_WIDTH * pillar.GetForwardVector() ) )
		vector maxs = CalcWorldToLocalOrigin_Entity( pillar, pillarOrigin - ( FERRO_WALL_RADIUS * pillar.GetRightVector() ) - ( FERRO_WALL_WIDTH * pillar.GetForwardVector() ) + < 0, 0, FERRO_WALL_HEIGHT > )
		DebugDrawBox( pillar.GetOrigin(),  mins, maxs, int( COLOR_GREEN.x ), int( COLOR_GREEN.y ), int( COLOR_GREEN.z ), 1, 25.0 )
		//DebugDrawLine( pillarOrigin + < 0, 0, FERRO_WALL_HEIGHT/2.0>, pillarOrigin + < 0, 0, FERRO_WALL_HEIGHT/ 2.0> + ( FERRO_WALL_WIDTH * pillar.GetForwardVector() ), int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
	#endif

	wait GetWallDuration( attacker )

	soundMover = soundMoverData.scaleDownMover
	if( IsValid( soundMover) )
	{
		if( soundMover.e.isDisabled )
		{
			soundMover.Signal( START_SOUND_SIGNAL )
			soundMover.e.isDisabled = false
		}

		if( Distance( soundMover.GetOrigin(), pillar.GetOrigin() ) > FERRO_WALL_SOUND_SNAP_DISTANCE )
		{
			soundMover.NonPhysicsStop()
			soundMover.SetAbsOrigin( pillar.GetOrigin() + FERRO_WALL_SOUND_MOVER_OFFSET )
		}
		else
		{
			soundMover.NonPhysicsMoveTo( pillar.GetOrigin() + FERRO_WALL_SOUND_MOVER_OFFSET, file.forwardDelay, 0.0, 0.0 )
		}
	}

	if( FERRO_WALL_FX_VERSION == 1 )
	{
		if( IsValid( friendlyBasefx ) )
			EffectStop( friendlyBasefx )
		
		int finishedFXId = ( inWater ) ? GetParticleSystemIndex( FERRO_WALL_FINISHED_WATER_FX_ARRAY[ modelSize ] ) : GetParticleSystemIndex( FERRO_WALL_FINISHED_FX_ARRAY[ modelSize ] )
		friendlyFinishedFx  = StartParticleEffectOnEntityWithPos_ReturnEntity( pillar, finishedFXId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
		EffectSetControlPointVector( friendlyFinishedFx, 1, <45, 0, FERRO_WALL_DARKZONE_OPACITY> )
		EffectSetControlPointVector( friendlyFinishedFx, 2, FRIENDLY_FERRO_WALL_COLOR )
		EffectSetControlPointVector( friendlyFinishedFx, 3, ENEMY_FERRO_WALL_COLOR )
		//friendlyFinishedFx.SetEnemyControlPointOverride( 3, 2 )
		SetTeam( friendlyFinishedFx, teamId )

		OnThreadEnd(
			function () : ( friendlyFinishedFx )
			{
				if( IsValid( friendlyFinishedFx ) )
					EffectStop( friendlyFinishedFx )
			}
		)
	}

	if( FERRO_WALL_FX_VERSION == 2 )
	{
		if( IsValid( friendlyIdleFx ) )
			EffectStop( friendlyIdleFx )

		int finishedFXId = ( inWater ) ? GetParticleSystemIndex( FERRO_WALL_FINISHED_WATER_FX_ARRAY[ modelSize ] ) : GetParticleSystemIndex( FERRO_WALL_FINISHED_FX_ARRAY[ modelSize ] )
		friendlyFinishedFx  = StartParticleEffectOnEntityWithPos_ReturnEntity( pillar, finishedFXId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
		EffectSetControlPointVector( friendlyFinishedFx, 1, <45, 0, FERRO_WALL_DARKZONE_OPACITY> )
		EffectSetControlPointVector( friendlyFinishedFx, 2, FRIENDLY_FERRO_WALL_COLOR )
		EffectSetControlPointVector( friendlyFinishedFx, 3, ENEMY_FERRO_WALL_COLOR )
		//friendlyFinishedFx.SetEnemyControlPointOverride( 3, 2 )
		SetTeam( friendlyFinishedFx, teamId )

		OnThreadEnd(
			function () : ( friendlyFinishedFx )
			{
				if( IsValid( friendlyFinishedFx ) )
					EffectStop( friendlyFinishedFx )
			}
		)
	}

	startTime = Time()
	endTime = startTime + file.scaleDownTime
	killSound = true
	while( true )
	{
		if( killSound && pillar.e.lastWallSegment && IsValid( soundMover ) && Time() >= ( startTime +  file.forwardDelay ) )
		{
			killSound = false
			soundMover.Destroy()
		}

		float scale = GraphCapped( Time(), startTime, endTime, 1.0, 0.0 )
		pillar.SetModelScale( scale )
		if( scale <= 0.0 )
			break
		WaitFrame()
	}

	if( pillar.e.lastWallSegment && IsValid( soundMover ) )
		soundMover.Destroy()

	wait FERRO_WALL_ENCAP_DELAY
}

void function FerroWallTiggerEnter( entity trigger, entity ent )
{
	if ( ent.DoesShareRealms( trigger ) && IsAlive( ent ) && ( ent.IsPlayer() || IsTrainingDummie( ent ) || ( ent.IsNPC() && !ent.IsNonCombatAI() ) ) )
		thread FerroWallTiggerEnterThread( trigger, ent )
}

bool function IsTeamVisionCandidate( entity ent, entity trigger )
{
	return ( IsFriendlyTeam( ent.GetTeam(), trigger.GetTeam() ) || ( ent.IsPlayer() && PlayerHasPassive( ent, ePassives.PAS_LOCKDOWN ) ) )
}

void function FerroWallTiggerEnterThread( entity trigger, entity ent )
{
	EndSignal( trigger, "OnDestroy" )
	EndSignal( ent, "OnDestroy" )
	if( ent.IsPlayer() )
		EndSignal( ent, "OnDeath" )

	bool[1] wasInWall = [ false ]
	bool firstLoop = true
	bool rightSideLastFrame = true
	bool phasedLastFrame = false

	OnThreadEnd(
		function () : ( wasInWall , ent )
		{
			if ( wasInWall[ 0 ] && IsValid( ent ) && ent in file.moveSlowTable )
			{
				file.moveSlowTable[ ent ].refCount--
				if( file.moveSlowTable[ ent ].refCount == 0 )
				{
					StatusEffect_Stop( ent, file.moveSlowTable[ ent ].handle )
					delete file.moveSlowTable[ ent ]
				}
			}
		}
	)

	float splashTime = Time()

	while( trigger.IsTouching( ent ) )
	{
		if( !IsAlive( ent ) )
			return

		vector triggerOrigin = trigger.GetOrigin()
		vector entOrigin = ent.GetOrigin()
		vector endPoint1 = triggerOrigin + ( FERRO_WALL_RADIUS * trigger.GetRightVector() )
		vector endPoint2 = triggerOrigin - ( FERRO_WALL_RADIUS * trigger.GetRightVector() )
		vector closestBottomPoint = GetClosestPointOnLineSegment( endPoint1, endPoint2, entOrigin  )
		vector flattenedEntOrigin = FlattenVec( entOrigin )
		vector closestFlattenedPoint = FlattenVec( closestBottomPoint )
		vector startPoint = < closestBottomPoint.x, closestBottomPoint.y, entOrigin.z >
		vector dirToPlayer = Normalize( entOrigin - closestBottomPoint )
		vector rightDir = trigger.GetForwardVector()

		bool isCatalyst = ent.IsPlayer() && PlayerHasPassive( ent, ePassives.PAS_LOCKDOWN )
		bool isPlayer = ent.IsPlayer()
		bool isDummy = IsTrainingDummie( ent )
		bool isNPC = ent.IsNPC()

		if( ent.IsPhaseShifted() )
		{
			phasedLastFrame = true
			WaitFrame()
			continue
		}

		//Inside the wall
		if( DistanceSqr( flattenedEntOrigin, closestFlattenedPoint ) <= FERRO_WALL_WIDTH_SQR )
		{
			if( !wasInWall[ 0 ] )
			{
				splashTime = Time()

				AttemptToApplyDarkStatus( ent, trigger, true )
			}

			if( ent in file.darkVisionData )
			{
				float duration = 0
				if( StatusEffect_HasSeverity( ent, eStatusEffect.ferro_darkvision ) || isDummy || isNPC )
				{
					duration = ( isPlayer || isDummy ) ? file.darkVisionDurationEnemy : file.darkVisionDurationNPC
				}
				else
				{
					duration = file.darkVisionDurationTeam
				}
				file.darkVisionData[ ent ].endTime = Time() + duration
			}
			if( Time() >= splashTime )
			{
				vector pOrigin = ent.GetWorldSpaceCenter()
				if( isPlayer )
				{
					int attachmentID = ent.LookupAttachment( "CHESTFOCUS" )
					pOrigin = ent.GetAttachmentOrigin( attachmentID )
				}
				StartParticleEffectInWorldForRealms( GetParticleSystemIndex( FERRO_WALL_WALKTHROUGH_SPLASH ), pOrigin, ZERO_VECTOR, ent )
				splashTime = Time() + 0.5
			}
			wasInWall[ 0 ] = true
		}
		//In trigger but outside the wall
		else
		{
			if( wasInWall[ 0 ] )
			{
				file.moveSlowTable[ ent ].refCount--
				if( file.moveSlowTable[ ent ].refCount == 0 )
				{
					StatusEffect_Stop( ent, file.moveSlowTable[ ent ].handle )
					delete file.moveSlowTable[ ent ]
				}
			}
			else
			{
				//If we were on one side of the wall last frame, and on the other side next frame without being inside the wall, apply darkness
				bool isRight = ( rightDir.Dot( dirToPlayer ) >= 0.0 )
				if( !firstLoop && !phasedLastFrame && isRight != rightSideLastFrame )
				{
					AttemptToApplyDarkStatus( ent, trigger, false )
					if( ent in file.darkVisionData )
					{
						float duration = 0
						if( StatusEffect_HasSeverity( ent, eStatusEffect.ferro_darkvision ) || isDummy || isNPC )
						{
							duration = ( isPlayer || isDummy ) ? file.darkVisionDurationEnemy : file.darkVisionDurationNPC
						}
						else
						{
							duration = file.darkVisionDurationTeam
						}
						file.darkVisionData[ ent ].endTime = Time() + duration
					}
				}
			}
			rightSideLastFrame = ( rightDir.Dot( dirToPlayer ) >= 0.0 )
			wasInWall[ 0 ] = false
		}
		firstLoop = false
		phasedLastFrame = false
		WaitFrame()
	}
}

void function AttemptToApplyDarkStatus( entity ent, entity trigger, bool applyMoveSlow )
{
	bool isCatalyst = ent.IsPlayer() && PlayerHasPassive( ent, ePassives.PAS_LOCKDOWN )
	bool isPlayer = ent.IsPlayer()
	bool isDummy = IsTrainingDummie( ent )
	bool isNPC = ent.IsNPC()

	if( ent in file.darkVisionData )
	{
		if ( StatusEffect_HasSeverity( ent, eStatusEffect.ferro_darkvision_team ) && !IsTeamVisionCandidate( ent, trigger ) )
		{
			thread DarkVisionVisualsThread_Server( ent )
		}
		else if ( StatusEffect_HasSeverity( ent, eStatusEffect.ferro_darkvision ) && IsTeamVisionCandidate( ent, trigger ) )
		{
			if ( isPlayer )
				thread DarkVisionVisualsTeamThread_Server( ent )
		}
	}
	else if( IsTeamVisionCandidate( ent, trigger ) )
	{
		if( isPlayer )
			thread DarkVisionVisualsTeamThread_Server( ent )
	}
	else
	{
		StatsHook_CatalystDarkVeilEnemiesCrossed( trigger.GetOwner() )
		if( !isCatalyst )
			thread DarkVisionVisualsThread_Server( ent )
	}

	if( !( ent in file.moveSlowTable ) )
	{
		if( applyMoveSlow )
		{
			TriggerMoveSlowData data
			float slowAmount = ( isPlayer || isDummy ) ? file.slowServerityPlayer : file.slowServerityNPC
			slowAmount = ( isCatalyst ) ? 0.0 : slowAmount
			data.handle = StatusEffect_AddEndless( ent, eStatusEffect.move_slow, slowAmount )
			data.refCount = 1
			file.moveSlowTable[ ent ] <- data
		}

		if( FERRO_WALL_SFX_VERSION == 1 )
		{
			if( isPlayer )
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, FERRO_WALL_PLAYER_PASSTHROUGH_3P )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, FERRO_WALL_PLAYER_PASSTHROUGH_1P )
			}
			else
			{
				EmitSoundOnEntity( ent, FERRO_WALL_PLAYER_PASSTHROUGH_3P )
			}
		}
		if( FERRO_WALL_SFX_VERSION == 2 )
		{
			StopSoundOnEntity( ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_1P )
			StopSoundOnEntity( ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_3P )
			StopSoundOnEntity( ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_3P )
			StopSoundOnEntity( ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_1P )
			StopSoundOnEntity( ent, FERRO_WALL_FRIENDLY_END_PASSTHROUGH_1P )
			StopSoundOnEntity( ent, FERRO_WALL_FRIENDLY_END_PASSTHROUGH_3P )
			StopSoundOnEntity( ent, FERRO_WALL_ENEMY_END_PASSTHROUGH_3P )
			StopSoundOnEntity( ent, FERRO_WALL_ENEMY_END_PASSTHROUGH_1P )

			if( IsTeamVisionCandidate( ent, trigger ) )
			{
				if( isPlayer )
				{
					EmitSoundOnEntityExceptToPlayer( ent, ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_3P )
					EmitSoundOnEntityOnlyToPlayer( ent, ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_1P )
				}
				else
				{
					EmitSoundOnEntity( ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_3P )
				}
			}
			else
			{
				if( isPlayer )
				{
					EmitSoundOnEntityExceptToPlayer( ent, ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_3P )
					EmitSoundOnEntityOnlyToPlayer( ent, ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_1P )
				}
				else
				{
					EmitSoundOnEntity( ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_3P )
				}
			}
		}

	}
	else
	{
		if ( applyMoveSlow )
			file.moveSlowTable[ ent ].refCount++
	}

	if( !isCatalyst && isPlayer && ( !ent.IsOnGround() || ent.IsSliding() ) )
	{
		vector vel = ent.GetVelocity()
		ent.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
	}
}

void function DarkVisionVisualsThread_Server( entity ent )
{
	EndSignal( ent, "OnDestroy" )
	ent.Signal( "StopDarkVision" )
	EndSignal( ent, "StopDarkVision" )
	if( ent.IsPlayer() )
		EndSignal( ent, "OnDeath" )
	EndSignal( ent, "BleedOut_OnStartDying" )

	bool isDummy = IsTrainingDummie( ent )
	bool isPlayer = ent.IsPlayer()
	bool isNPC = ent.IsNPC()
	FerroWallDarkVisionData data
	if( isPlayer )
		data.visionHandle = StatusEffect_AddEndless( ent, eStatusEffect.ferro_darkvision, 1.0 )
	else
		data.visionHandle = -1

	if( isNPC && !isDummy )
		data.moveSlowHandle = StatusEffect_AddEndless( ent, eStatusEffect.move_slow, file.slowServerityNPC )
	else
		data.moveSlowHandle = -1
	data.endTime = Time() + ( ( isPlayer || isDummy ) ? file.darkVisionDurationEnemy : file.darkVisionDurationNPC )

	file.darkVisionData[ ent ] <- data

	int fxid         = GetParticleSystemIndex( FERRO_WALL_DARK_ZONE_SHROUD_FX )
	int attachmentID = ent.LookupAttachment( "CHESTFOCUS" )
	entity fx
	if( attachmentID != ATTACHMENTID_INVALID )
		fx = StartParticleEffectOnEntity_ReturnEntity( ent, fxid, FX_PATTACH_POINT_FOLLOW, attachmentID )
	else
		fx = StartParticleEffectOnEntity_ReturnEntity( ent, fxid, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	EffectSetControlPointVector( fx, 2, ENEMY_FERRO_WALL_COLOR )
	fx.SetOwner( ent )

	OnThreadEnd(
		function () : ( ent, fx )
		{
			if( IsValid( fx ) )
				EffectStop( fx )

			if( ent in file.darkVisionData )
			{
				if( IsValid( ent ) )
				{
					StopSoundOnEntity( ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_3P )
					StopSoundOnEntity( ent, FERRO_WALL_ENEMY_START_PASSTHROUGH_1P )
					StatusEffect_Stop( ent, file.darkVisionData[ ent ].visionHandle )
					StatusEffect_Stop( ent, file.darkVisionData[ ent ].moveSlowHandle )
				}
				delete file.darkVisionData[ ent ]
			}
		}
	)

	bool playEndSound = true
	while( true )
	{
		if( !( ent in file.darkVisionData ) )
			return

		if( file.darkVisionData[ ent ].endTime < Time() )
			return

		float delta = file.darkVisionData[ ent ].endTime - Time()
		if( playEndSound && delta <= FERRO_WALL_PASSTHROUGH_SOUND_LOOP_END_THRESHOLD_TIME )
		{
			playEndSound = false
			if( isPlayer )
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, FERRO_WALL_ENEMY_END_PASSTHROUGH_3P )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, FERRO_WALL_ENEMY_END_PASSTHROUGH_1P )
			}
			else
			{
				EmitSoundOnEntity( ent, FERRO_WALL_ENEMY_END_PASSTHROUGH_3P )
			}
		}
		WaitFrame()
	}
}

void function DarkVisionVisualsTeamThread_Server( entity ent )
{
	EndSignal( ent, "OnDestroy" )
	ent.Signal( "StopDarkVision" )
	EndSignal( ent, "StopDarkVision" )
	if( ent.IsPlayer() )
		EndSignal( ent, "OnDeath" )
	EndSignal( ent, "BleedOut_OnStartDying" )

	FerroWallDarkVisionData data
	data.visionHandle = StatusEffect_AddEndless( ent, eStatusEffect.ferro_darkvision_team, 1.0 )
	data.endTime = Time() + file.darkVisionDurationTeam

	file.darkVisionData[ ent ] <- data

	OnThreadEnd(
		function () : ( ent,  )
		{
			if( ent in file.darkVisionData )
			{
				if( IsValid( ent ) )
				{
					StopSoundOnEntity( ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_3P )
					StopSoundOnEntity( ent, FERRO_WALL_FRIENDLY_START_PASSTHROUGH_1P )
					StatusEffect_Stop( ent, file.darkVisionData[ ent ].visionHandle )
				}
				delete file.darkVisionData[ ent ]
			}
		}
	)

	while( true )
	{
		if( !( ent in file.darkVisionData ) )
			return

		if( file.darkVisionData[ ent ].endTime < Time() )
			return

		WaitFrame()
	}
}
void function FerroWallPassThroughFXThread_Server( entity hitOwner, entity wall, vector hitPos )
{
	EndSignal( wall, "OnDestroy" )
	entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( wall, GetParticleSystemIndex( FERRO_WALL_PASSTHROUGH_IMPACT ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, CalcWorldToLocalOrigin_Entity( wall, hitPos ), <0,0,0> )
	if( IsValid( hitOwner ) )
	{
		fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
		fx.SetOwner( hitOwner )
	}

	OnThreadEnd(
		function () : ( fx )
		{
			if ( IsValid( fx ) )
				EffectStop( fx )
		}
	)
	wait FERRO_WALL_PASSTHROUGH_IMPACT_FX_KILL_TIME
}
#endif // SERVER

entity function FerroWall_CreateTrapPlacementProxy( asset modelName )
{
	#if SERVER
		entity proxy = CreatePropDynamic( modelName, <0, 0, 0>, <0, 0, 0> )
	#else
		entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	#endif
	proxy.EnableRenderAlways()
	proxy.kv.rendermode = 3
	proxy.kv.renderamt = 1
	proxy.Hide()

	return proxy
}

void function EndThreadOn_DarkVisionCommon( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "BleedOut_OnStartDying" )

	#if SERVER
		EndThreadOn_PlayerChangedClass( player )
	#endif // SERVER
}

#if CLIENT
void function OnCreateClientOnlyModel_weapon_ferro_wall( entity weapon, entity model, bool validHighlight )
{
	model.Hide()
}

void function FerroWallDarkVision_UpdatePlayerScreenVFX_Thread( entity player, int statusEffect )
{
	if ( !IsValid( player ) || !IsLocalClientPlayer( player ) )
		return

	EndThreadOn_DarkVisionCommon( player )
	player.EndSignal( "DarkVisionMode_StopColorCorrection" )

	ColorCorrection_SetExclusive( file.colorCorrection, true )
	ColorCorrection_SetWeight( file.colorCorrection, 1.0 )

	//Creates the "Dark Eye" Vignette around the Player's Camera
	int index = GetParticleSystemIndex( FERRO_WALL_DARKEYE_VIGNETTE_FX )
	file.darkVisionFXID = StartParticleEffectOnEntity( player, index, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
	EffectSetIsWithCockpit( file.darkVisionFXID, true )

	//NOTE FROM KCRAFT - Reducing this to one geosphere for perf reasons
	//Creates the "Flashlight" Vision Distance Limitation. (I'm testing multiple to mimic a fading flashlight) only for enemies
	if ( StatusEffect_HasSeverity( player, eStatusEffect.ferro_darkvision ) )
	{
		int debuglimitFXID = GetParticleSystemIndex( FERRO_WALL_DEBUG_SPHERE_VISION_LIMIT_FX )
		if ( !PlayerHasPassive( player, ePassives.PAS_LOCKDOWN ) )
		{
			file.darkVisionLimit1FX = StartParticleEffectOnEntity( player, debuglimitFXID, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
			EffectSetControlPointVector( file.darkVisionLimit1FX, 2, <0, 0, 0> )
	//
	//		file.darkVisionLimit2FX = StartParticleEffectOnEntity( player, debuglimitFXID, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
	//		EffectSetControlPointVector( file.darkVisionLimit2FX, 2, <50, 50, 50> )
	//
	//		file.darkVisionLimit3FX = StartParticleEffectOnEntity( player, debuglimitFXID, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
	//		EffectSetControlPointVector( file.darkVisionLimit3FX, 2, <5, 5, 5> )
		}
	//	else //Scryer's "Flashlight" has better vision in the dark
	//	{
	//		file.darkVisionLimit0FX = StartParticleEffectOnEntity( player, debuglimitFXID, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
	//		EffectSetControlPointVector( file.darkVisionLimit0FX, 2, <5, 5, 5> )
	//	}
	}


	OnThreadEnd(
		function() : ( player )
		{
			ColorCorrection_SetWeight( file.colorCorrection, 0.0 )
			ColorCorrection_SetExclusive( file.colorCorrection, false )

			if ( EffectDoesExist( file.darkVisionFXID ) )
			{
				EffectStop( file.darkVisionFXID, false, true )
			}
			if ( EffectDoesExist( file.darkVisionLimit0FX ) )
			{
				EffectStop( file.darkVisionLimit0FX, false, true )
			}
			if ( EffectDoesExist( file.darkVisionLimit1FX ) )
			{
				EffectStop( file.darkVisionLimit1FX, false, true )
			}
			if ( EffectDoesExist( file.darkVisionLimit2FX ) )
			{
				EffectStop( file.darkVisionLimit2FX, false, true )
			}
			if ( EffectDoesExist( file.darkVisionLimit3FX ) )
			{
				EffectStop( file.darkVisionLimit3FX, false, true )
			}
		}
	)

	//Fade VFX up to Max Values
	float fadeTime = 0.5
	thread FerroWallDarkVision_FadePlayerScreenVFX_Thread( player, fadeTime, file.darkVisionFXID, file.darkVisionLimit0FX, file.darkVisionLimit1FX, file.darkVisionLimit2FX, file.darkVisionLimit3FX, file.darkVisionFXAlpha, file.flashlightFXAlpha, false, statusEffect )

	WaitForever()
}

void function FerroWallDarkVision_FadePlayerScreenVFX_Thread( entity player, float fadeTime, int darkVisionFXID, int darkVisionLimit0FX, int darkVisionLimit1FX, int darkVisionLimit2FX, int darkVisionLimit3FX, float darkVisionFXAlpha, float flashlightFXAlpha, bool isFadeOut, int statusEffect )
{
	if ( !IsValid( player ) || !IsLocalClientPlayer( player ) )
		return
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "DarkVisionMode_CancelFadeOut" )

	//ANIMATE THE VFX as they TURN ON.
	const LERP_IN_TIME = 0.0125    // hack! because statusEffect doesn't seem to have a lerp in feature?
	float lerpPercent = 0.0
	float lerpTime    = fadeTime
	float startTime   = Time()
	float endTime     = Time() + (lerpTime)
	float darkVisionAlphaStart = 1.0
	float darkVisionAlphaEnd = 1.0
	float flashlightFXAlphaStart = 0.0
	float flashlightFXAlphaEnd = 1.0

	if (isFadeOut) //Set Values for us to Turn OFF the Effects
	{
		darkVisionAlphaEnd = 0
		flashlightFXAlphaEnd = 0

		if ( !PlayerHasPassive( player, ePassives.PAS_LOCKDOWN ) )
		{
			if ( statusEffect == eStatusEffect.ferro_darkvision_team )
			{
				darkVisionAlphaStart = file.darkVisionFXMaxAlphaTeam
				flashlightFXAlphaStart = file.darkVisionFlashlightOpacity*FERRO_WALL_DARKVISION_FX_SCALAR_TEAM
			}
			if ( statusEffect == eStatusEffect.ferro_darkvision )
			{
				darkVisionAlphaStart = file.darkVisionFXMaxAlphaEnemy
				flashlightFXAlphaStart = file.darkVisionFlashlightOpacity*FERRO_WALL_DARKVISION_FX_SCALAR_ENEMY
			}
		}
		else
		{
			darkVisionAlphaStart = FERRO_WALL_DARKVISION_FX_ALPHA_END_CATALYST
			flashlightFXAlphaStart = file.darkVisionFlashlightOpacity*FERRO_WALL_DARKVISION_FX_SCALAR_CATALYST
		}
	}
	else // Set Values for us to Turn ON the Effects
	{
		darkVisionAlphaStart = FERRO_WALL_DARKVISION_FX_ALPHA_START
		flashlightFXAlphaStart = 0.0

		if ( !PlayerHasPassive( player, ePassives.PAS_LOCKDOWN ) )
		{

			if ( statusEffect == eStatusEffect.ferro_darkvision_team )
			{
				darkVisionAlphaEnd = file.darkVisionFXMaxAlphaTeam
				flashlightFXAlphaEnd = file.darkVisionFlashlightOpacity*FERRO_WALL_DARKVISION_FX_SCALAR_TEAM
			}
			if ( statusEffect == eStatusEffect.ferro_darkvision )
			{
				darkVisionAlphaEnd = file.darkVisionFXMaxAlphaEnemy
				flashlightFXAlphaEnd = file.darkVisionFlashlightOpacity*FERRO_WALL_DARKVISION_FX_SCALAR_ENEMY
			}
		}
		else
		{
			darkVisionAlphaEnd = FERRO_WALL_DARKVISION_FX_ALPHA_END_CATALYST
			flashlightFXAlphaEnd = file.darkVisionFlashlightOpacity*FERRO_WALL_DARKVISION_FX_SCALAR_CATALYST
		}
	}

	//RAMPS DarkVision
	while ( (Time() <= endTime ) )
	{
		lerpPercent = 1 - ((endTime - Time()) / lerpTime)

		file.darkVisionFXAlpha = LerpFloat( darkVisionAlphaStart, darkVisionAlphaEnd, lerpPercent )
		file.flashlightFXAlpha = LerpFloat( flashlightFXAlphaStart, flashlightFXAlphaEnd, lerpPercent )

		if ( EffectDoesExist( darkVisionFXID ) )
		{
			EffectSetControlPointVector( darkVisionFXID, 1, <file.darkVisionFXAlpha, 0, 0> )
		}
		if(EffectDoesExist( darkVisionLimit0FX ))
		{
			EffectSetControlPointVector( darkVisionLimit0FX, 1, < FERRO_WALL_DARKVISION_DISTANCE, 0, file.flashlightFXAlpha > )
		}
		//KCRAFT - modifiying this to be as strong as 3 spheres
		if(EffectDoesExist( darkVisionLimit1FX ))
		{
			EffectSetControlPointVector( darkVisionLimit1FX, 1, < FERRO_WALL_DARKVISION_DISTANCE, 0, file.flashlightFXAlpha * 4.0 > )
		}
		if(EffectDoesExist( darkVisionLimit2FX ))
		{
			EffectSetControlPointVector( darkVisionLimit2FX, 1, < FERRO_WALL_DARKVISION_DISTANCE + 250, 0, file.flashlightFXAlpha > )
		}
		if(EffectDoesExist( darkVisionLimit3FX ))
		{
			EffectSetControlPointVector( darkVisionLimit3FX, 1, < FERRO_WALL_DARKVISION_DISTANCE + 500, 0, file.flashlightFXAlpha > )
		}

		float weight = StatusEffect_GetSeverity( player, eStatusEffect.ferro_darkvision )
		weight = GraphCapped( Time() - startTime, 0, LERP_IN_TIME, 0, weight )
		ColorCorrection_SetWeight( file.colorCorrection, weight*0.5 )

		WaitFrame()
	}

	if ( ( StatusEffect_GetTimeRemaining( player, eStatusEffect.ferro_darkvision ) <= 0 ) && ( StatusEffect_GetTimeRemaining( player, eStatusEffect.ferro_darkvision_team ) <= 0 ) )
	{
		player.Signal( "DarkVisionMode_StopColorCorrection" )
		player.Signal( "DarkVisionMode_StopActivationScreenFX" )
	}
}

void function FerroWallDarkVision_StartVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	if ( ent.IsBot() )
		return

	ent.Signal( "DarkVisionMode_CancelFadeOut" )
	ent.Signal( "DarkVisionMode_StopColorCorrection" )

	if( statusEffect == eStatusEffect.ferro_darkvision )
		GfxDesaturateOn()

	thread FerroWallDarkVision_UpdatePlayerScreenVFX_Thread( ent, statusEffect )

	//turn off always on highlight
	int contextId = HighlightContext_GetId( "always_on_enemy_assist" )

	HighlightContext_SetParam( contextId, 1, < 85, 0, 0 > )
}

void function FerroWallDarkVision_StopVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	if( statusEffect == eStatusEffect.ferro_darkvision )
		GfxDesaturateOff()

	//Fade out Client VFX
	float fadeTime = 1.5
	thread FerroWallDarkVision_FadePlayerScreenVFX_Thread( ent, fadeTime, file.darkVisionFXID, file.darkVisionLimit0FX, file.darkVisionLimit1FX, file.darkVisionLimit2FX, file.darkVisionLimit3FX, file.darkVisionFXAlpha, file.flashlightFXAlpha, true, statusEffect )
	thread FerroWallDarkVision_ClearPlayerScreenFX_Thread( ent, fadeTime)

	//turn on always on highlight

	int contextId = HighlightContext_GetId( "always_on_enemy_assist" )

	HighlightContext_SetParam( contextId, 1, < 85, 1.5, 0 > )
}

void function FerroWallDarkVision_ClearPlayerScreenFX_Thread( entity ent, float fadeTime )
{
	EndSignal( ent, "DarkVisionMode_CancelFadeOut" )

	wait fadeTime

	ent.Signal( "DarkVisionMode_StopColorCorrection" )
	ent.Signal( "DarkVisionMode_StopActivationScreenFX" )
}

void function WeaponActive_Client( entity ownerPlayer, entity weapon )
{
	EndSignal( weapon, KILL_CLIENT_THREAD_SIGNAL )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( ownerPlayer, "OnDestroy" )

	wait 0.2

	array< entity > proxies
	int maxCharges = GetWallLength( ownerPlayer )
	for( int i = 0; i < maxCharges; i++ )
	{
		entity proxy = FerroWallCreatePlacementProxy( FERRO_WALL_MODEL_AR )
		proxy.EnableRenderAlways()
		proxy.Show()
		//DeployableModelHighlight( proxy )
		proxies.append( proxy )
	}

	OnThreadEnd(
		function () : ( ownerPlayer, maxCharges, proxies )
		{
			for( int i = 0; i < maxCharges; i++ )
			{
				if ( IsValid( proxies[ i ] ) )
				{
					proxies[ i ].Destroy()
				}
			}
		}
	)

	int lastCharges = 0
	bool lastGroundValid = true
	while( true )
	{

		for( int i = 0; i < maxCharges; i++ )
		{
			proxies[ i ].Hide()
		}

		vector targetOrigin
		entity targetParent
		vector startAngles = ZERO_VECTOR
		vector ownerOrigin = ownerPlayer.EyePosition()
		entity placementParent = weapon.GetObjectPlacementParent()
		array<entity> ignoreArray = GetFerroWallIgnoreArray()
		if( weapon.ObjectPlacementHasValidSpot() && ( !IsValid( placementParent ) || !ignoreArray.contains( placementParent ) ) )
		{
			targetOrigin = weapon.GetObjectPlacementOrigin()
		}
		else
		{
			TraceResults fwdTrace = TraceLine( ownerOrigin, ownerOrigin + FlattenNormalizeVec( ownerPlayer.GetViewVector() ) * FERRO_WALL_DEFAULT_FWD_DISTANCE, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
			TraceResults downTrace = TraceLine( fwdTrace.endPos, fwdTrace.endPos + < 0, 0, -400 >, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
			if( downTrace.fraction == 1.0 )
			{
				WaitFrame()
				continue
			}
			targetOrigin = downTrace.endPos
		}
		CreatePlacementWall( proxies, ignoreArray, targetOrigin, ownerPlayer.GetViewForward() )
		WaitFrame()
	}
}

entity function FerroWallCreatePlacementProxy( asset modelName )
{
	entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	proxy.EnableRenderAlways()
	proxy.kv.rendermode = 2
	proxy.kv.renderamt = 175
	proxy.Hide()

	return proxy
}

void function CreatePlacementWall( array< entity > proxies, array< entity > ignoreArray, vector pos, vector dir, float initalStep = FERRO_WALL_STEP_INIT )
{
	float traceStep = initalStep
	dir = <dir.x, dir.y, 0.0>
	dir = Normalize( dir )
	vector angles = VectorToAngles( dir )
	angles = RotateAnglesAboutAxis( angles, UP_VECTOR, 90 )

	bool firstTrace = true
	vector traceStart = pos + < 0, 0, FERRO_WALL_CLIMB_HEIGHT_INIT >
	bool endTraces = false

	int numPillars = proxies.len()

	for ( int i = 0; i < numPillars; i++ )
	{
		vector traceFwdEnd = traceStart + ( dir * traceStep )
		TraceResults forwardTrace = TraceLine( traceStart, traceFwdEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if( forwardTrace.fraction < 1.0 )
		{
			vector traceUpEnd = forwardTrace.endPos + < 0, 0, FERRO_WALL_RETRY_CLIMB_HEIGHT >
			TraceResults upTrace = TraceLine( forwardTrace.endPos, traceUpEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			traceStart = upTrace.endPos
			traceFwdEnd = traceStart + ( dir * ( traceStep * ( 1.0 - forwardTrace.fraction ) ) )
			forwardTrace = TraceLine( traceStart, traceFwdEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if( forwardTrace.fraction < 1.0 )
				break
		}
		#if DEVELOPER && FERRO_WALL_DEBUG_DRAW
			DebugDrawLine( traceStart, forwardTrace.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
		#endif

		vector traceDownEnd = forwardTrace.endPos + < 0, 0, -FERRO_WALL_DOWN_TRACE_LENGTH >
		TraceResults downTrace = TraceLine( forwardTrace.endPos, traceDownEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if( downTrace.fraction == 1.0 )
		{
			endTraces = true
		}
		else
		{
			proxies[ i ].SetOrigin( downTrace.endPos + < 0, 0, FERRO_WALL_PILLAR_Z_OFFSET > )
			proxies[ i ].SetAngles( angles )
			proxies[ i ].Show()
			traceStart = downTrace.endPos + < 0, 0, FERRO_WALL_CLIMB_HEIGHT >
		}
		#if DEVELOPER && FERRO_WALL_DEBUG_DRAW
			DebugDrawLine( forwardTrace.endPos, downTrace.endPos, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 25.0 )
		#endif

		if( endTraces )
			break

		if( firstTrace )
		{
			traceStep = FERRO_WALL_STEP
			firstTrace = false
		}
	}
}

void function OnFerroWallPillarCreated( entity infoTarget )
{
	if( IsValid( infoTarget ) )
		thread OnFerroWallPillarCreatedThread( infoTarget )
}

void function OnFerroWallPillarCreatedThread( entity infoTarget )
{
	EndSignal( infoTarget, "OnDestroy" )

	entity localPlayer = GetLocalViewPlayer()
	if( !IsValid( localPlayer ) )
		return
	EndSignal( localPlayer, "OnDestroy" )

	entity clientAG = CreateClientSideAmbientGeneric( infoTarget.GetOrigin() , FERRO_WALL_IDLE_3P, 0 )
	clientAG.RemoveFromAllRealms()
	clientAG.AddToOtherEntitysRealms( infoTarget )
	clientAG.SetParent( infoTarget, "", true )
	SetTeam( clientAG, infoTarget.GetTeam() )
	clientAG.SetEnabled( true )

	OnThreadEnd(
		function() : ( clientAG )
		{
			if ( IsValid( clientAG ) )
			{
				clientAG.Destroy()
			}
		}
	)

	int prevNumSegments = 0
	while( true )
	{
		array< entity > segments = infoTarget.GetLinkEntArray()
		int currentNumSegments   = segments.len()
		if ( currentNumSegments != prevNumSegments )
		{
			prevNumSegments = currentNumSegments
			if ( currentNumSegments == 0 )
			{
				clientAG.SetEnabled( false )
			}
		

			clientAG.RemoveSegmentEndpoints()
			foreach( wallSegment in segments )
			{
				if( IsValid( wallSegment ) )
				{
					vector startPoint = wallSegment.GetOrigin() + < 0, 0, FERRO_WALL_HEIGHT * 0.75 > + wallSegment.GetRightVector() * FERRO_WALL_RADIUS
					vector endPoint = wallSegment.GetOrigin() + < 0, 0, FERRO_WALL_HEIGHT * 0.75 > - wallSegment.GetRightVector() * FERRO_WALL_RADIUS
				
					clientAG.AddSegmentEndpoints( startPoint, endPoint )
				}
			}
		}
		WaitFrame()
	}
}
void function FerroWallPassThroughFXThread_Client( entity hitOwner, entity wall, vector hitPos )
{
	EndSignal( wall, "OnDestroy" )
	int handle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( FERRO_WALL_PASSTHROUGH_IMPACT ), hitPos, wall.GetAngles() )

	OnThreadEnd(
		function () : ( handle )
		{
			if ( EffectDoesExist( handle ) )
				EffectStop( handle, false, true )
		}
	)

	wait FERRO_WALL_PASSTHROUGH_IMPACT_FX_KILL_TIME
}
#endif //CLIENT

void function FerroWallPassThroughFX( entity hitOwner, entity wall, vector hitPos )
{
#if CLIENT
	if( IsValid( hitOwner ) && hitOwner == GetLocalViewPlayer() && InPrediction() )
#endif
	{
		if( file.impactFxEnabled != 0 && IsValid( wall ) && wall.GetTargetName() == FERRO_WALL_SEGMENT_TARGET_NAME )
		{
			float maxHeight = 0
			if( FERRO_WALL_SMALL_MODEL_ARRAY.contains( wall.GetModelName() ) )
			{
				maxHeight = FERRO_WALL_HEIGHT - ( FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER * 0.3 )
			}
			else if( FERRO_WALL_MEDIUM_MODEL_ARRAY.contains( wall.GetModelName() ) )
			{
				maxHeight = FERRO_WALL_HEIGHT * 2.0 - ( FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER * 0.6 )
			}
			else if( FERRO_WALL_LARGE_MODEL_ARRAY.contains( wall.GetModelName() ) )
			{
				maxHeight = FERRO_WALL_HEIGHT * 3.0 - FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER
			}
			else if( wall.GetModelName() == FERRO_WALL_MODEL_SLOPE )
			{
				maxHeight = FERRO_WALL_HEIGHT * 3.0 - FERRO_WALL_PILLAR_HEIGHT_CHECK_BUFFER - 20.0
			}
			else
			{
				return
			}

			vector testPoint = wall.GetOrigin() + ( wall.GetUpVector() * maxHeight )

			if( IsPointInFrontofLine( hitPos, testPoint, wall.GetUpVector() ) )
				return

			#if CLIENT
			thread FerroWallPassThroughFXThread_Client( hitOwner, wall, hitPos )
			#endif
			#if SERVER
			thread FerroWallPassThroughFXThread_Server( hitOwner, wall, hitPos )
			#endif
		}
	}
}

array<entity> function GetFerroWallIgnoreArray()
{
	array<entity> ignoreArray

	ignoreArray.extend( GetPlayerArray() )
	ignoreArray.extend( GetAllResinShards() )
	ignoreArray.extend( GetNPCArray() )
	ignoreArray.extend( GetEntArrayByScriptName( TROPHY_SYSTEM_NAME ) ) 					//Wattson Ult
	ignoreArray.extend( GetEntArrayByScriptName( TESLA_TRAP_NAME ) )						//Wattson Fence
	ignoreArray.extend( GetEntArrayByScriptName( DIRTY_BOMB_TARGETNAME ) )					//Caustic Trap
	ignoreArray.extend( GetEntArrayByScriptName( DEATH_TOTEM_TARGETNAME ) )					//Revenant Totem
	ignoreArray.extend( GetEntArrayByScriptName( BLACKHOLE_PROP_SCRIPTNAME ) )				//Horizon NEWT
	ignoreArray.extend( GetEntArrayByScriptName( BLACK_MARKET_SCRIPTNAME ) )				//Loba Black Market
	ignoreArray.extend( GetEntArrayByScriptName( BASE_WALL_SCRIPT_NAME ) )					//Rampart Wall
	ignoreArray.extend( GetEntArrayByScriptName( MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME ) )	//Planted Shiela
	ignoreArray.extend( GetEntArrayByScriptName( ECHO_LOCATOR_SCRIPT_NAME ) )				//Seer Ult
	ignoreArray.extend( GetEntArrayByScriptName( SHIELD_THROW_SCRIPTNAME ) )				//Mobile shield drone
	ignoreArray.extend( GetEntArrayByScriptName( MOBILE_SHIELD_SCRIPTNAME ) )				//mobile shield shield piece
	ignoreArray.extend( GetEntArrayByScriptName( CRYPTO_DRONE_SCRIPTNAME ) )				//crypto drones
	ignoreArray.extend( GetEntArrayByScriptName( VANTAGE_COMPANION_SCRIPTNAME ) )			//echo
	ignoreArray.extend( GetPlayerDecoyArray() )												//Mirage Decoys
	ignoreArray.extend( GetEntArrayByScriptName( "LootRoller" ) )
	ignoreArray.extend( GetAllDeathBoxes() )
	ignoreArray.extend( GetEntArrayByScriptName( WORKBENCH_CLUSTER_SCRIPTNAME ) )
	ignoreArray.extend( GetEntArrayByScriptName( HOVER_VEHICLE_SCRIPTNAME ) )
	ignoreArray.extend( GetEntArrayByScriptName( "TROPICS_BEACH_BALL" ) )

	return ignoreArray
}
