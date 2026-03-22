untyped

//TODO: Should split this up into server, client and shared versions and just globalize_all_functions
global function WeaponUtility_Init

global function ApplyVectorSpread
global function DebugDrawMissilePath
global function DegreesToTarget
global function EntityCanHaveStickyEnts
global function EntityShouldStick
global function EntityShouldStickEx
global function GetVectorFromPositionToCrosshair
global function GetVelocityForDestOverTime
global function GetPlayerVelocityForDestOverTime
global function InitMissileForRandomDriftForVortexLow
global function IsPilotShotgunWeapon
global function PlantStickyEntity
global function PlantStickyEntityOnConsistentSurface
global function PlantStickyEntityThatBouncesOffWalls
global function PlantStickyEntityOnWorldThatBouncesOffWalls
#if SERVER
global function AddToTrackedEnts
#endif
global function EnergyChargeWeapon_OnWeaponChargeLevelIncreased
global function EnergyChargeWeapon_OnWeaponChargeBegin
global function EnergyChargeWeapon_OnWeaponChargeEnd
global function Fire_EnergyChargeWeapon
global function FireHitscanShotgunBlast
global function FireProjectileShotgunBlast
global function ProjectileShotgun_GetOuterSpread
global function ProjectileShotgun_GetInnerSpread
global function FireProjectileBlastPattern
global function FireGenericBoltWithDrop
global function OnWeaponPrimaryAttack_GenericBoltWithDrop_Player
global function OnWeaponActivate_updateViewmodelAmmo
global function WeaponCanCrit
global function GiveEMPStunStatusEffects
global function GetMaxTrackerCountForTitan
global function FireBallisticRoundWithDrop
global function DoesModExist
global function DoesModExistFromWeaponClassName
global function IsModActive
global function PlayerUsedOffhand
global function GetDistanceString
global function IsWeaponInSingleShotMode
global function IsWeaponInBurstMode
global function IsWeaponOffhand
global function IsWeaponInAutomaticMode
global function IsMeleeWeaponNotFists
global function OnWeaponReadyToFire_ability_tactical
global function GetMeleeWeapon
global function OnWeaponRegenEndGeneric
global function Ultimate_OnWeaponRegenBegin
global function OnWeaponActivate_RUIColorSchemeOverrides
global function PlayDelayedShellEject
global function IsABaseGrenade
global function HandleDisappearingParent
global function CalcProjectileTrajectory
global function SolveBallisticArc
global function GetCrosshairTargetData
global function GetCrosshairTargetDataAngles
global function AreAbilitiesSilenced
global function GetNeededEnergizeConsumableCount
global function HasEnoughEnergizeConsumable
global function OnWeaponEnergizedStart
global function IsWeaponSemiAuto

#if SERVER
global function ArrowsUnstick
global function CreateDamageInflictorHelper
global function DelayedDestroyDamageInflictorHelper
global function StoreOffhandData
global function CreateOncePerTickDamageInflictorHelper
global function WeaponHasCosmetics
global function WeaponSkinCustomizations_AttachmentChanged
global function GetAmmoPoolTypesUsedByPlayer
global function OnWeaponAttachmentChanged_CheckForGoldMag
global function OnProjectileCollision_ThermiteRounds
global function OnWeaponAttachmentChanged_CheckForSmartReload
global function OnWeaponAttachmentChanged_CheckForShatterCaps
global function OnWeaponAttachmentChanged_CheckForKineticLoader
global function OnWeaponAttachmentChanged_CheckForAnvilReceiver
global function HACK_Weapon_OverrideRUIColorSchemeForSkin
global function SavePlayerWeaponData
global function RestorePlayerWeaponData
global function ChargeTactical_ForceEnd
global function Electricity_ShouldStunNPCAndAddImmunity
global function Electricity_DamagedPlayerOrNPC
global function Electricity_ShouldDamageStunNPC
                 
                                            
      
global function SetWeaponLockedSetFromLootTags
#endif

#if SERVER
global function ClientCallback_UpdateLaserSightColor
#endif // #if SERVER
#if CLIENT
global function UICallback_UpdateLaserSightColor
#endif // #if CLIENT

global function Weapon_AddSingleCharge

#if CLIENT
global function ServerCallback_SetWeaponPreviewState
global function ServerCallback_KineticLoaderReloadedThroughSlide
global function ServerCallback_KineticLoaderReloadedThroughSlideEnd
global function ApplyKineticLoaderFunctionality
global function ServerToClient_Activate_Smart_Reload
#endif

global function OnWeaponTryEnergize

global function OnWeaponAttemptOffhandSwitch_Never

#if DEVELOPER
global function DEV_DumpStickinessTable
global function DevPrintAllStatusEffectsOnEnt
#endif // #if DEVELOPER

#if SERVER
global function PROTO_CleanupTrackedProjectiles
global function PROTO_InitTrackedProjectile
global function StartClusterExplosionsThread
global function TrapDestroyOnRoundEnd
global function TrapExplodeOnDamage
global function DisallowWeaponDeploy
global function AllowWeaponDeploy
global function DisallowAllWeaponDeployment
global function AllowAllWeaponUsageDeployment
global function StartForceAllowSpecificWeaponDeployment
global function StopForceAllowSpecificWeaponDeployment
global function GetAllPlayerWeapons
global function EMP_DamagedPlayerOrNPC
global function EMP_FX
global function Thermite_DamagePlayerOrNPCSounds
global function AddThreatScopeColorStatusEffect
global function RemoveThreatScopeColorStatusEffect
global function LimitVelocityHorizontal
global function GiveMatchingAkimboWeapon
global function TakeMatchingAkimboWeapon
global function AddWeaponModChangedCallback
global function TryApplyingBurnDamage
global function TryApplyingOrRefreshingBurnDamage
global function AddEntityBurnDamageStack
global function AddOrRefreshEntityBurnDamageStack
global function ApplyBurnDamageTick
global function SetEntityIsBurning
global function UTILITY_RemoveFromSavedPlayerWeaponData

                         
                                                      
      

#if DEVELOPER
global function ToggleZeroingMode
#endif

const string WEAPON_UTILITY_MOVER_SCRIPTNAME = "weapon_utility_mover"

#endif //SERVER

#if CLIENT
global function GlobalClientEventHandler
global function UpdateViewmodelAmmo
global function IsOwnerViewPlayerFullyADSed
global function GetAmmoColorByType
global function TryCharacterButtonCommonReadyChecks
#endif //CLIENT

global function ShouldShowADSScopeView
global function HasFullscreenScope

global function AddCallback_OnPlayerAddWeaponMod
global function AddCallback_OnPlayerRemoveWeaponMod

global function CodeCallback_OnPlayerAddedWeaponMod
global function CodeCallback_OnPlayerRemovedWeaponMod

global function EnergyChoke_OnWeaponModCommandCheckMods

#if CLIENT
global function DisplayCenterDotRui
#endif

global function IsTurretWeapon
global function IsHMGWeapon
global function IsMeleeWeapon

#if SERVER || CLIENT
global function GetInfiniteAmmo
#if SERVER
global function SetInfiniteAmmoForWeapon
global function SetInfiniteAmmoForPlayer
global function SetInfiniteAmmoForGameMode
#if DEVELOPER
global function DEV_TestSetInfiniteAmmo
#endif
#endif
#endif

global function CodeCallback_GetIsModOptic

// IMPORTANT: Marksman's Tempo uses ScriptInt1 and ScriptTime1, make sure the weapon is not using these for other purposes when using Marksman's Tempo
global struct MarksmansTempoSettings
{
	int   requiredShots
	float graceTimeBuildup
	float graceTimeInTempo
	int  fadeoffMatchGraceTime
	float fadeoffOnPerfectMomentHit
	float fadeoffOnFire

	string weaponDeactivateSignal
}
global const string MOD_MARKSMANS_TEMPO = "hopup_marksmans_tempo"
global const string MOD_MARKSMANS_TEMPO_ACTIVE = "marksmans_tempo_active"
global const string MOD_MARKSMANS_TEMPO_BUILDUP = "marksmans_tempo_buildup"
global const string MARKSMANS_TEMPO_REQUIRED_SHOTS_SETTING = "marksmans_tempo_required_shots"
global const string MARKSMANS_TEMPO_GRACE_TIME_SETTING = "marksmans_tempo_grace_time"
global const string MARKSMANS_TEMPO_GRACE_TIME_IN_TEMPO_SETTING = "marksmans_tempo_grace_time_in_tempo"
global const string MARKSMANS_TEMPO_FADEOFF_MATCH_GRACE_TIME = "marksmans_tempo_fadeoff_match_grace_time"
global const string MARKSMANS_TEMPO_FADEOFF_ON_PERFECT_MOMENT_SETTING = "marksmans_tempo_fadeoff_on_perfect_moment"	////this is more cosmetic, since missing the perfect moment by <grace_time> will fail regardless. Just makes the UI fadeoff eventually
global const string MARKSMANS_TEMPO_FADEOFF_ON_FIRE_SETTING = "marksmans_tempo_fadeoff_on_fire"
global const string MARKSMANS_TEMPO_FADEOFF_THREAD_ABORT = "marksmans_tempo_fadeoff_abort"
// ENERGIZE_STATUS_RUI_ABORT_SIGNAL defined in mp_weapon_sentinel.nut
global const string WEAPON_CHARGED_RUI_ABORT_SIGNAL = "ChargedRuiThinkAbortSignal"
global function MarksmansTempo_Validate
global function MarksmansTempo_OnActivate
global function MarksmansTempo_OnDeactivate
global function MarksmansTempo_AbortFadeoff
global function MarksmansTempo_SetPerfectTempoMoment
global function MarksmansTempo_OnFire
global function MarksmansTempo_RemoveTempo
global function MarksmansTempo_ClearTempo



global enum eShatterRoundsTypes
{
	STANDARD,
	SHATTER_TRI,

	_count
}
global const string SHATTER_ROUNDS_HOPUP_MOD = "hopup_shatter_rounds"
global const string SHATTER_ROUNDS_ALTFIRE_MOD = "altfire_shatter"
global const string SHATTER_ROUNDS_HIPFIRE_MOD = "shatter_rounds_hipfire"
global const string SHATTER_ROUNDS_THINK_END_SIGNAL = "shatter_rounds_think_end"
global const string SHATTER_ROUNDS_ADS_THINK_THREAD_ABORT_SIGNAL = "shatter_rounds_ads_think_end"
global function ShatterRounds_UpdateShatterRoundsThink
#if SERVER
global function ShatterRounds_ADSThink
#endif




global const string SMART_RELOAD_HOPUP = "hopup_smart_reload"
global const string LMG_FAST_RELOAD_MOD = "fast_reload_mod"
global const string LMG_OVERLOADED_AMMO_MOD = "overloaded_ammo"
global const string END_SMART_RELOAD = "end_smart_reload_functionality"
const string ULTIMATE_ACTIVE_MOD_STRING = "ultimate_active"

const vector LOWAMMO_UI_COLOR = <0, 255, 0> / 255.0
const vector OVERLOADAMMO_UI_COLOR = <0, 200, 200> / 255.0
const vector OUTOFAMMO_UI_COLOR = <255, 65, 65> / 255.0
const vector NORMALAMMO_UI_COLOR = ZERO_VECTOR

global const string OVERLOAD_AMMO_SETTING = "smart_reload_overload_ammo_required"
global const string LOW_AMMO_FAC_SETTING = "low_ammo_fraction"

global struct SmartReloadSettings
{
	int OverloadedAmmo
	float LowAmmoFrac
}

const int MIN_AMMO_REQUIRED = 0
const int MAX_AMMO_REQUIRED = 11

global function OnWeaponActivate_Smart_Reload
global function OnWeaponDeactivate_Smart_Reload
global function OnWeaponReload_Smart_Reload


global struct KineticLoaderSettings
{
	float  loadDelay
	float  additiveDelay
	float  maxDelay
	int    ammoToLoad
	string kineticLoaderSFX
}

global function OnWeaponActivate_Kinetic_Loader
global function OnWeaponDeactivate_Kinetic_Loader
#if SERVER
global function AddActiveThermiteBurn
#endif
#if SERVER
global function EMPGrenade_EffectsPlayer
#endif
global function GetPlayerFromTitanWeapon
#if SERVER
global function PROTO_PlayTrapLightEffect
#endif
global function ProximityCharge_PostFired_Init
#if SERVER
global function Satchel_PostFired_Init
global function SetPlayerCooldowns
#endif
#if SERVER
global function StartClusterExplosions
#endif
#if SERVER
global function WeaponAttackWave
#endif
global function FireExpandContractMissiles
global function GetActiveThermiteBurnsWithinRadius
global function GetPrimaryWeapons
global function GetRadiusDamageDataFromProjectile
global function GetWeaponBurnMods
global function GetWeaponModsFromDamageInfo

global const string END_KINETIC_LOADER = "end_kinetic_loader_functionality"
global const string KINETIC_LOADER_HOPUP = "hopup_kinetic_loader"
global const string END_KINETIC_LOADER_CHOKE = "end_kinetic_loader_choke_functionality"

global const string KINETIC_LOAD_DELAY_SETTING = "kinetic_load_delay"
global const string KINETIC_LOAD_ADDITIVE_DELAY_SETTING = "kinetic_load_additive_delay"
global const string KINETIC_LOAD_MAX_DELAY_SETTING = "kinetic_load_max_delay"
global const string KINETIC_AMMO_TO_LOAD_SETTING = "kinetic_ammo_to_load"
global const string KINETIC_LOAD_SFX_SETTING = "kinetic_load_sfx"
#if CLIENT
global const string END_KINETIC_LOADER_RUI = "end_kinetic_loader_functionality"
#endif


                          
                                 
                                           
          
                                            
      
      

global const bool PROJECTILE_PREDICTED = true
global const bool PROJECTILE_NOT_PREDICTED = false

global const bool PROJECTILE_LAG_COMPENSATED = true
global const bool PROJECTILE_NOT_LAG_COMPENSATED = false

global const PRO_SCREEN_IDX_MATCH_KILLS = 1
global const PRO_SCREEN_IDX_AMMO_COUNTER_OVERRIDE_HACK = 2

global const int DAMAGEARROW_WP_INT_INDEX_ID = 0
global const int DAMAGEARROW_WP_INT_INDEX_TEAM = 1
global const int DAMAGEARROW_WP_INT_INDEX_VISIBILITY_TYPE = 2

global const int DAMAGEARROW_WP_ENT_OWNER = 0

#if SERVER
global const float ELECTRICITY_NPC_STUN_IMMUNITY_DURATION = 3.0
#endif

const float DEFAULT_SHOTGUN_SPREAD_INNEREXCLUDE_FRAC = 0.4
const bool DEBUG_PROJECTILE_BLAST = false

const float EMP_SEVERITY_SLOWTURN = 0.7
const float EMP_SEVERITY_SLOWMOVE = 0.50
const float LASER_STUN_SEVERITY_SLOWTURN = 0.4
const float LASER_STUN_SEVERITY_SLOWMOVE = 0.30

const asset FX_EMP_BODY_HUMAN = $"P_emp_body_human"
const asset FX_EMP_BODY_TITAN = $"P_emp_body_titan"
const asset FX_VANGUARD_ENERGY_BODY_HUMAN = $"P_monarchBeam_body_human"
const asset FX_VANGUARD_ENERGY_BODY_TITAN = $"P_monarchBeam_body_titan"
const SOUND_EMP_REBOOT_SPARKS = "marvin_weld"
const FX_EMP_REBOOT_SPARKS = $"weld_spark_01_sparksfly"
const EMP_GRENADE_BEAM_EFFECT = $"wpn_arc_cannon_beam"
const DRONE_REBOOT_TIME = 5.0
const GUNSHIP_REBOOT_TIME = 5.0

const bool DEBUG_BURN_DAMAGE = false

const float BOUNCE_STUCK_DISTANCE = 5.0

const float GOLD_MAG_TIME_BEFORE_STOWED_RELOAD = 5.0

const int ITEM_STICKS = 1
const int ITEM_NOT_FOUND_STICKINESS = -1

global const string ARROWS_UNSTICK_SIGNAL = "arrows_unstick"

global struct RadiusDamageData
{
	int   explosionDamage
	int   explosionDamageHeavyArmor
	float explosionRadius
	float explosionInnerRadius
}

global struct EnergyChargeWeaponData
{
	array<vector> blastPattern
	string fx_barrel_glow_attach
	asset  fx_barrel_glow_final_1p
	asset  fx_barrel_glow_final_3p
}

#if SERVER
global struct PopcornInfo
{
	string weaponName
	array  weaponMods // could be array<string>
	int    damageSourceId
	int    count
	float  initalDelay
	float  delay
	float  offset
	float  range
	float  range_min = 0.0
	vector normal
	float  duration
	int    groupSize
	bool   hasBase
	string burstFXTable
	entity inflictor
	void functionref( vector ) explosionCallback = null
}

struct ColorSwapStruct
{
	int    statusEffectId
	entity weaponOwner
}

global struct HoverSounds
{
	string liftoff_1p
	string liftoff_3p
	string hover_1p
	string hover_3p
	string descent_1p
	string descent_3p
	string landing_1p
	string landing_3p
}
#endif

global struct ArcSolution
{
	bool valid
	vector fire_velocity
	float duration
}

global struct CrosshairTargetData
{
	bool inRange
	vector crosshairStart
	vector groundTarget
	vector groundTargetNormal
	vector airburstTarget
	float distanceToTarget
	vector directionToTarget
}

struct
{
	#if SERVER
		int activeThermiteBurnsManagedEnts = -1

		//store off the primary weapons and ammo the player died with in case the mode wants to restore on respawn (code nukes primary weapons on player death/ragdoll)
		table< entity, array<StoredWeapon> > playerStoredWeapons
		table<entity, string>                playerStoredLastWeapon

		float titanRocketLauncherTitanDamageRadius
		float titanRocketLauncherOtherDamageRadius

		array<ColorSwapStruct> colorSwapStatusEffects

		bool checkThermiteLOS = false

		#if DEVELOPER
			bool inZeroingMode = false
		#endif

		array<entity> 						 npcsWithStunImmunity

	#else // CLIENT
		var satchelHintRUI = null
	#endif

	array<void functionref( entity, entity, string )> playerAddWeaponModCallbacks
	array<void functionref( entity, entity, string )> playerRemoveWeaponModCallbacks
	table<string, array<void functionref( entity, string, bool )> > weaponModChangedCallbacks

	#if CLIENT
		table < entity, bool > weaponReloadedThroughSlideTable
		table < entity, int > weaponAmmoToLoadTotalTable
	#endif

	table< string, table <string, int> > throwableItemStickinessTable
} file

global int HOLO_PILOT_TRAIL_FX


// what classes can sticky thrown entities stick to?
StringSet STICKY_CLASSES = {
	worldspawn = IN_SET,
	player = IN_SET,
	prop_dynamic = IN_SET,
	prop_script = IN_SET,
	prop_death_box = IN_SET,
	func_brush = IN_SET,
	func_brush_lightweight = IN_SET,
	phys_bone_follower = IN_SET,
	door_mover = IN_SET,
	prop_door = IN_SET,
	script_mover = IN_SET,
	player_vehicle = IN_SET,
	turret = IN_SET,
	prop_loot_grabber = IN_SET,
	prop_lootroller = IN_SET,
}

void function WeaponUtility_Init()
{
	level.trapChainReactClasses <- {}
	level.trapChainReactClasses[ "mp_weapon_frag_grenade" ]            <- true
	level.trapChainReactClasses[ "mp_weapon_satchel" ]                <- true
	level.trapChainReactClasses[ "mp_weapon_proximity_mine" ]        <- true
	level.trapChainReactClasses[ "mp_weapon_laser_mine" ]            <- true

	//RegisterSignal( "Planted" )
	RegisterSignal( "OnKnifeStick" )
	RegisterSignal( "EMP_FX" )
	RegisterSignal( "ArcStunned" )
	RegisterSignal( "CleanupPlayerPermanents" )
	RegisterSignal( "PlayerChangedClass" )
	RegisterSignal( "OnSustainedDischargeEnd" )
	RegisterSignal( "EnergyWeapon_ChargeStart" )
	RegisterSignal( "EnergyWeapon_ChargeReleased" )
	RegisterSignal( "WeaponSignal_EnemyKilled" )

	RegisterSignal( "GoldMagPerkEnd" )

	RegisterSignal( MARKSMANS_TEMPO_FADEOFF_THREAD_ABORT )

	RegisterSignal ( END_SMART_RELOAD )

	RegisterSignal ( END_KINETIC_LOADER )
	RegisterSignal ( END_KINETIC_LOADER_CHOKE )
	Remote_RegisterClientFunction( "ServerCallback_KineticLoaderReloadedThroughSlide", "entity", "int", 0, 32 )
	Remote_RegisterClientFunction( "ServerCallback_KineticLoaderReloadedThroughSlideEnd", "entity" )
	Remote_RegisterClientFunction( "ApplyKineticLoaderFunctionality", "entity" , "entity" )
	Remote_RegisterClientFunction( "ServerToClient_Activate_Smart_Reload", "entity" , "int", 0, 64, "float", 0.0, 1.0, 32 )
                           
                                                                 
                                    
	Remote_RegisterServerFunction( "ClientCallback_UpdateLaserSightColor" )
	#if CLIENT
	RegisterSignal ( END_KINETIC_LOADER_RUI )
	#endif

	#if SERVER
		RegisterSignal( ARROWS_UNSTICK_SIGNAL )
		RegisterSignal( "RestoredPlayerWeaponData" )
	#endif // SERVEr

	PrecacheParticleSystem( EMP_GRENADE_BEAM_EFFECT )
	PrecacheParticleSystem( FX_EMP_BODY_TITAN )
	PrecacheParticleSystem( FX_EMP_BODY_HUMAN )
	PrecacheParticleSystem( FX_VANGUARD_ENERGY_BODY_HUMAN )
	PrecacheParticleSystem( FX_VANGUARD_ENERGY_BODY_TITAN )
	PrecacheParticleSystem( FX_EMP_REBOOT_SPARKS )

	PrecacheImpactEffectTable( CLUSTER_ROCKET_FX_TABLE )

                                 
                                                  
       

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_emp, EMP_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.damagedef_ticky_arc_blast, EMP_DamagedPlayerOrNPC )
		AddCallback_OnClientConnected( OnPlayerConnectedOrReconnected )
		AddCallback_OnClientConnectionRestored( OnPlayerConnectedOrReconnected )
		AddCallback_OnPlayerKilled( OnPlayerKilled_StoreWeaponData )
		AddCallback_OnPlayerRespawned( WeaponAllowLogic_OnPlayerRespawed )
		AddCallback_OnPlayerPostRespawned( OnPlayerRespawed_GiveWeapons )
		AddCallback_OnPlayerInventoryChanged( WeaponAllowLogic_OnPlayerInventoryChanged )
		Loot_AddCallback_OnWeaponAttachmentChanged( OnWeaponAttachmentChanged_UpdateWeaponHud )
		Loot_AddCallback_OnWeaponAttachmentChanged( WeaponSkinCustomizations_AttachmentChanged )
		Loot_AddCallback_OnWeaponAttachmentChanged( OnWeaponAttachmentChanged_CheckForGoldMag )
		Loot_AddCallback_OnWeaponAttachmentChanged( OnWeaponAttachmentChanged_CheckForSmartReload )
		Loot_AddCallback_OnWeaponAttachmentChanged( OnWeaponAttachmentChanged_CheckForShatterCaps )
		Loot_AddCallback_OnWeaponAttachmentChanged( OnWeaponAttachmentChanged_CheckForAnvilReceiver )
		Loot_AddCallback_OnWeaponAttachmentChanged( OnWeaponAttachmentChanged_CheckForKineticLoader )
		AddCallback_EntitiesDidLoad( EntitiesDidLoad )
		PrecacheParticleSystem( $"wpn_laser_blink" )
		PrecacheParticleSystem( $"wpn_laser_blink_fast" )
		PrecacheParticleSystem( $"P_ordinance_icon_owner" )

		file.checkThermiteLOS = GetCurrentPlaylistVarBool( "thermite_enable_LOS_check", true )
	#endif

	HOLO_PILOT_TRAIL_FX = PrecacheParticleSystem( $"P_ar_holopilot_trail" )

		RegisterSignal( SHATTER_ROUNDS_THINK_END_SIGNAL )
		#if SERVER
		RegisterSignal( SHATTER_ROUNDS_ADS_THINK_THREAD_ABORT_SIGNAL )
		#endif

		AddCallback_OnPlayerAddWeaponMod( ShatterRounds_OnPlayerAddedWeaponMod )
		AddCallback_OnPlayerRemoveWeaponMod( ShatterRounds_OnPlayerRemovedWeaponMod )

	InitThrowableItemStickinessDatatable()
}

const asset THROWABLE_ITEM_STICKINESS_DATATABLE = $"datatable/throwable_item_stickiness.rpak"
const int ENT_NAME_COL = 0

void function InitThrowableItemStickinessDatatable()
{
	// S3: throwable_item_stickiness.rpak doesn't exist - skip datatable loading
	Warning( "InitThrowableItemStickinessDatatable: datatable not available in S3, skipping" )
	return

	unreachable

	array< string > throwableItems = [
		VOID_RING_WEAPON_REF, BUBBLE_BUNKER_WEAPON_NAME, ECHO_LOCATOR_WEAPON_NAME,
		"mp_weapon_jump_pad", "mp_ability_space_elevator_tac", CAUSTIC_DIRTY_BOMB_WEAPON_CLASS_NAME,
		GRENADE_EMP_WEAPON_NAME, GUNGAME_THROWING_KNIFE_WEAPON_NAME, RIOT_DRILL_SCRIPT_NAME,
		"mp_weapon_cluster_bomb_launcher", "mp_ability_debuff_zone", SPIKE_STRIP_WEAPON_NAME

		TRANSPORT_PORTAL_WEAPON_NAME

	]

	var dataTable = GetDataTable( THROWABLE_ITEM_STICKINESS_DATATABLE )
	int numRows = GetDataTableRowCount( dataTable )

	foreach ( string item in throwableItems )
	{
		table< string, int > columnTable
		int col = GetDataTableColumnByName( dataTable, item )

		Assert( col >= 0 )

		#if ASSERTS
		columnTable.clear()
		#endif

		for ( int j = 0; j < numRows; j++ )
		{
			string entName = GetDataTableString( dataTable, j, ENT_NAME_COL )
			int value = int( GetDataTableString( dataTable, j, col ) )

			Assert( !(entName in columnTable), "Ent " + entName +" already in stickiness table! There is a duplicate row" )

			columnTable[ entName ] <- value
		}

		file.throwableItemStickinessTable[ item ] <- columnTable
	}
}

#if SERVER
void function EntitiesDidLoad()
{
	// if we are going to do this, it should happen in the weapon, not globally
	//float titanRocketLauncherInnerRadius = expect float( GetWeaponInfoFileKeyField_Global( "mp_titanweapon_rocketeer_rocketstream", "explosion_inner_radius" ) )
	//float titanRocketLauncherOuterRadius = expect float( GetWeaponInfoFileKeyField_Global( "mp_titanweapon_rocketeer_rocketstream", "explosionradius" ) )
	//file.titanRocketLauncherTitanDamageRadius = titanRocketLauncherInnerRadius + ( ( titanRocketLauncherOuterRadius - titanRocketLauncherInnerRadius ) * 0.4 )
	//file.titanRocketLauncherOtherDamageRadius = titanRocketLauncherInnerRadius + ( ( titanRocketLauncherOuterRadius - titanRocketLauncherInnerRadius ) * 0.1 )
}
#endif

////////////////////////////////////////////////////////////////////

#if CLIENT
void function GlobalClientEventHandler( entity weapon, string name )
{
	if ( name == "ammo_update" )
		UpdateViewmodelAmmo( false, weapon )

	if ( name == "ammo_full" )
		UpdateViewmodelAmmo( true, weapon )
}

void function UpdateViewmodelAmmo( bool forceFull, entity weapon )
{
	Assert( weapon != null ) // used to be: if ( weapon == null ) weapon = this.self

	if ( !IsValid( weapon ) )
		return
	if ( !IsLocalViewPlayer( weapon.GetWeaponOwner() ) )
		return

	int bodyGroupCount = weapon.GetWeaponSettingInt( eWeaponVar.bodygroup_ammo_index_count )
	if ( bodyGroupCount <= 0 )
		return

	int rounds                = weapon.GetWeaponPrimaryClipCount()
	int maxRoundsForClipSize  = weapon.GetWeaponPrimaryClipCountMax()
	int maxRoundsForBodyGroup = (bodyGroupCount - 1)
	int maxRounds             = minint( maxRoundsForClipSize, maxRoundsForBodyGroup )

	if ( forceFull || (rounds > maxRounds) )
		rounds = maxRounds

	//printt( "ROUNDS:", rounds, "/", maxRounds )
	weapon.SetViewmodelAmmoModelIndex( rounds )
}
#endif // #if CLIENT

void function OnWeaponActivate_updateViewmodelAmmo( entity weapon )
{
	#if CLIENT
		UpdateViewmodelAmmo( false, weapon )
	#endif // #if CLIENT
}

///// CUSTOM WEAPON SKIN STUFF /////

void function OnWeaponActivate_RUIColorSchemeOverrides( entity weapon )
{
	#if SERVER
		HACK_Weapon_OverrideRUIColorSchemeForSkin( weapon )
	#endif
}

#if SERVER
void function WeaponSkinCustomizations_AttachmentChanged( entity player, entity weapon, string modToAdd, string modToRemove )
{
	HACK_Weapon_OverrideRUIColorSchemeForSkin( weapon )
}

// HACK! Currently - gets a skin override index from bakery, which is mapped to a hardcoded color scheme in RUI
// ...in the future, get RGBs from Bakery and send them to RUI. (Expand pro screen or get a different solution)
// only used currently - 2022.10.20 - by two Havoc (energy_ar) legendary skins
void function HACK_Weapon_OverrideRUIColorSchemeForSkin( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	int idx = 0
	if ( IsValidItemFlavorGUID( weapon.GetItemFlavorGUID(), eValidation.DONT_ASSERT ) )
	{
		ItemFlavor weaponSkin = GetItemFlavorByGUID( weapon.GetItemFlavorGUID() )
		idx = WeaponSkin_GetHackyRUISchemeIdentifier( weaponSkin )
	}

	// RUI reads the "pro screen int" which is sent for us by code
	weapon.SetProScreenIntValForIndex( PRO_SCREEN_IDX_AMMO_COUNTER_OVERRIDE_HACK, idx )
}
#endif

int function Fire_EnergyChargeWeapon( entity weapon, WeaponPrimaryAttackParams attackParams, EnergyChargeWeaponData chargeWeaponData, bool playerFired = true, float patternScale = 1.0, bool ignoreSpread = true )
{
	int chargeLevel = EnergyChargeWeapon_GetChargeLevel( weapon )
	//printt( "LVL", chargeLevel )
	if ( chargeLevel == 0 )
		return 0

	// scale spread pattern for weapon charge level
	float spreadChokeFrac = 1.0
	// NOTE uses a switch instead of concatenating the string, so we can search for the same string that is in weaponsettings
	switch( chargeLevel )
	{
		case 1:
			spreadChokeFrac = expect float( weapon.GetWeaponInfoFileKeyField( "projectile_spread_choke_frac_1" ) )
			break

		case 2:
			spreadChokeFrac = expect float( weapon.GetWeaponInfoFileKeyField( "projectile_spread_choke_frac_2" ) )
			break

		case 3:
			spreadChokeFrac = expect float( weapon.GetWeaponInfoFileKeyField( "projectile_spread_choke_frac_3" ) )
			break

		case 4:
			spreadChokeFrac = expect float( weapon.GetWeaponInfoFileKeyField( "projectile_spread_choke_frac_4" ) )
			break

		default:
			Assert( false, "chargeLevel " + chargeLevel + " doesn't have matching weaponsetting for projectile_spread_choke_frac_" + chargeLevel )
	}
	patternScale *= spreadChokeFrac

	float speedScale = 1.0
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, speedScale, patternScale, ignoreSpread )

	if ( weapon.IsChargeWeapon() )
		EnergyChargeWeapon_StopCharge( weapon, chargeWeaponData )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


int function EnergyChargeWeapon_GetChargeLevel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return 0

	entity owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return 0

	if ( !owner.IsPlayer() )
		return 1

	if ( !weapon.IsReadyToFire() )
		return 0

	if ( !weapon.IsChargeWeapon() )
		return 1

	int chargeLevel = weapon.GetWeaponChargeLevel()
	return chargeLevel
}


bool function EnergyChargeWeapon_OnWeaponChargeLevelIncreased( entity weapon, EnergyChargeWeaponData chargeWeaponData )
{
	#if CLIENT
		if ( InPrediction() && !IsFirstTimePredicted() )
			return true
#endif

#if SERVER
		//printt( "charge level", weapon.GetWeaponChargeLevel() )
	#endif

	int level    = weapon.GetWeaponChargeLevel()
	int maxLevel = weapon.GetWeaponChargeLevelMax()

	string tickSound
	string tickSound_3p

	if ( level == maxLevel )
	{
		tickSound = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_final" ) )
		tickSound_3p = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_final_3p" ) )
	}
	else
	{
		switch ( level )
		{
			case 1:
				tickSound = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_1" ) )
				tickSound_3p = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_1_3p" ) )

				break

			case 2:
				if ( chargeWeaponData.fx_barrel_glow_attach != "" )
					weapon.PlayWeaponEffect( chargeWeaponData.fx_barrel_glow_final_1p, chargeWeaponData.fx_barrel_glow_final_3p, chargeWeaponData.fx_barrel_glow_attach )

				tickSound = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_2" ) )
				tickSound_3p = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_2_3p" ) )

				break

			case 3:
				tickSound = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_3" ) )
				tickSound_3p = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_leveltick_3_3p" ) )
				break
		}
	}

	if ( tickSound != "" || tickSound_3p != "" )
		weapon.EmitWeaponSound_1p3p( tickSound, tickSound_3p )

	return true
}


void function EnergyChargeWeapon_StopCharge( entity weapon, EnergyChargeWeaponData chargeWeaponData )
{
	if ( chargeWeaponData.fx_barrel_glow_attach != "" )
		weapon.StopWeaponEffect( chargeWeaponData.fx_barrel_glow_final_1p, chargeWeaponData.fx_barrel_glow_final_3p )

	weapon.StopWeaponSound( expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_loop" ) ) )
	weapon.StopWeaponSound( expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_loop_3p" ) ) )

	#if CLIENT
		// NOTE: sounds weird to wind down if we didn't charge for very long, so let at least one charge cycle pass before winding down
		float chargeTime          = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
		int chargeLevels          = weapon.GetWeaponSettingInt( eWeaponVar.charge_levels )
		int chargeLevelBase       = weapon.GetWeaponSettingInt( eWeaponVar.charge_level_base )
		float chargeLevelsReduced   = (chargeLevels - chargeLevelBase).tofloat()
		float weaponMinChargeTime = 0.0

		if ( chargeLevelsReduced > 0.0 )
		{
			weaponMinChargeTime = chargeTime / chargeLevelsReduced
		}

		if ( Time() - weapon.w.startChargeTime >= weaponMinChargeTime )
		{
			weapon.EmitWeaponSound( expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_end" ) ) )
		}
	#elseif SERVER
		entity owner = weapon.GetWeaponOwner()
		if ( IsValid( owner ) )
		{
			EmitSoundOnEntityExceptToPlayer( weapon, owner, expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_end_3p" ) ) )
		}
	#endif
}


bool function EnergyChargeWeapon_OnWeaponChargeBegin( entity weapon )
{
	weapon.Signal( "EnergyWeapon_ChargeStart" )

	if ( weapon.GetWeaponChargeFraction() == 0 )
	{
		weapon.w.startChargeTime = Time()

		string chargeStart    = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_start" ) )
		string chargeStart_3p = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_start_3p" ) )
		weapon.EmitWeaponSound_1p3p( chargeStart, chargeStart_3p )
	}

	string chargeLoop    = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_loop" ) )
	string chargeLoop_3p = expect string( weapon.GetWeaponInfoFileKeyField( "sound_energy_charge_loop_3p" ) )
	weapon.EmitWeaponSound_1p3p( chargeLoop, chargeLoop_3p )

	return true
}


void function EnergyChargeWeapon_OnWeaponChargeEnd( entity weapon, EnergyChargeWeaponData chargeWeaponData )
{
	//printt( "charge end")
	weapon.Signal( "EnergyWeapon_ChargeReleased" )

	thread EnergyChargeWeapon_StopCharge_Think( weapon, chargeWeaponData )
}


void function EnergyChargeWeapon_StopCharge_Think( entity weapon, EnergyChargeWeaponData chargeWeaponData )
{
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "EnergyWeapon_ChargeStart" )
	weapon.EndSignal( "EnergyWeapon_ChargeReleased" )

	while ( true )
	{
		WaitFrame()

		if ( EnergyChargeWeapon_GetChargeLevel( weapon ) <= 1 )
			break
	}

	EnergyChargeWeapon_StopCharge( weapon, chargeWeaponData )
}


void function FireHitscanShotgunBlast( entity weapon, vector pos, vector dir, int numBlasts, int damageType, float damageScaler = 1.0, float ornull maxAngle = null, float ornull maxDistance = null )
{
	Assert( numBlasts > 0 )
	int numBlastsOriginal = numBlasts

	/*
	Debug ConVars:
		visible_ent_cone_debug_duration_client - Set to non-zero to see debug output
		visible_ent_cone_debug_duration_server - Set to non-zero to see debug output
		visible_ent_cone_debug_draw_radius - Size of trace endpoint debug draw
	*/

	if ( maxDistance == null )
		maxDistance = weapon.GetMaxDamageFarDist()
	expect float( maxDistance )

	if ( maxAngle == null )
		maxAngle = weapon.GetAttackSpreadAngle() * 0.5
	expect float( maxAngle )

	entity owner                  = weapon.GetWeaponOwner()
	array<entity> ignoredEntities = [ owner ]
	int traceMask                 = TRACE_MASK_SHOT
	int visConeFlags              = VIS_CONE_ENTS_TEST_HITBOXES | VIS_CONE_ENTS_CHECK_SOLID_BODY_HIT | VIS_CONE_ENTS_APPOX_CLOSEST_HITBOX | VIS_CONE_RETURN_HIT_VORTEX

	entity antilagPlayer
	if ( owner.IsPlayer() )
	{
		if ( owner.IsPhaseShifted() )
			return

		antilagPlayer = owner
	}

	//JFS - Bug 198500
	Assert( maxAngle > 0.0, "JFS returning out at this instance. We need to investigate when a valid mp_titanweapon_laser_lite weapon returns 0 spread" )
	if ( maxAngle == 0.0 )
		return

	array<VisibleEntityInCone> results = FindVisibleEntitiesInCone( pos, dir, maxDistance, (maxAngle * 1.1), ignoredEntities, traceMask, visConeFlags, antilagPlayer, weapon )
	foreach ( result in results )
	{
		float angleToHitbox = 0.0
		if ( !result.solidBodyHit )
			angleToHitbox = DegreesToTarget( pos, dir, result.approxClosestHitboxPos )

		numBlasts -= HitscanShotgunBlastDamageEntity( weapon, pos, dir, result, angleToHitbox, maxAngle, numBlasts, damageType, damageScaler )
		if ( numBlasts <= 0 )
			break
	}

	//Something in the TakeDamage above is triggering the weapon owner to become invalid.
	owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return

	// maxTracer limit set in /r1dev/src/game/client/c_player.h
	const int MAX_TRACERS = 16
	bool didHitAnything   = ((numBlastsOriginal - numBlasts) != 0)
	bool doTraceBrushOnly = (!didHitAnything)
	if ( numBlasts > 0 )
	{
		WeaponFireBulletSpecialParams fireBulletParams
		fireBulletParams.pos = pos
		fireBulletParams.dir = dir
		fireBulletParams.bulletCount = minint( numBlasts, MAX_TRACERS )
		fireBulletParams.scriptDamageType = damageType
		fireBulletParams.skipAntiLag = false
		fireBulletParams.dontApplySpread = false
		fireBulletParams.doDryFire = true
		fireBulletParams.noImpact = false
		fireBulletParams.noTracer = false
		fireBulletParams.activeShot = false
		fireBulletParams.doTraceBrushOnly = doTraceBrushOnly
		weapon.FireWeaponBullet_Special( fireBulletParams )
	}
}


vector function ApplyVectorSpread( vector vecShotDirection, float spreadDegrees, float bias = 1.0 )
{
	vector angles   = VectorToAngles( vecShotDirection )
	vector vecUp    = AnglesToUp( angles )
	vector vecRight = AnglesToRight( angles )

	float sinDeg = deg_sin( spreadDegrees / 2.0 )

	// get circular gaussian spread
	float x
	float y
	float z

	if ( bias > 1.0 )
		bias = 1.0
	else if ( bias < 0.0 )
		bias = 0.0

	// code gets these values from cvars ai_shot_bias_min & ai_shot_bias_max
	float shotBiasMin = -1.0
	float shotBiasMax = 1.0

	// 1.0 gaussian, 0.0 is flat, -1.0 is inverse gaussian
	float shotBias = ((shotBiasMax - shotBiasMin) * bias) + shotBiasMin
	float flatness = (fabs( shotBias ) * 0.5)

	while ( true )
	{
		x = RandomFloatRange( -1.0, 1.0 ) * flatness + RandomFloatRange( -1.0, 1.0 ) * (1 - flatness)
		y = RandomFloatRange( -1.0, 1.0 ) * flatness + RandomFloatRange( -1.0, 1.0 ) * (1 - flatness)
		if ( shotBias < 0 )
		{
			x = (x >= 0) ? 1.0 - x : -1.0 - x
			y = (y >= 0) ? 1.0 - y : -1.0 - y
		}
		z = x * x + y * y

		if ( z <= 1 )
			break
	}

	vector addX        = vecRight * (x * sinDeg)
	vector addY        = vecUp * (y * sinDeg)
	vector m_vecResult = vecShotDirection + addX + addY

	return m_vecResult
}


float function DegreesToTarget( vector origin, vector forward, vector targetPos )
{
	vector dirToTarget = targetPos - origin
	dirToTarget = Normalize( dirToTarget )
	float dot         = DotProduct( forward, dirToTarget )
	float degToTarget = (acos( dot ) * 180 / PI)

	return degToTarget
}


const SHOTGUN_ANGLE_MIN_FRACTION = 0.1
const SHOTGUN_ANGLE_MAX_FRACTION = 1.0
const SHOTGUN_DAMAGE_SCALE_AT_MIN_ANGLE = 0.8
const SHOTGUN_DAMAGE_SCALE_AT_MAX_ANGLE = 0.1

int function HitscanShotgunBlastDamageEntity( entity weapon, vector barrelPos, vector barrelVec, VisibleEntityInCone result, float angle, float maxAngle, int numPellets, int damageType, float damageScaler )
{
	entity target = result.ent

	//The damage scaler is currently only > 1 for the Titan Shotgun alt fire.
	if ( !target.IsTitan() && damageScaler > 1 )
		damageScaler = max( damageScaler * 0.4, 1.5 )

	entity owner = weapon.GetWeaponOwner()
	// Ent in cone not valid
	if ( !IsValid( target ) || !IsValid( owner ) )
		return 0

	// Fire fake bullet towards entity for visual purposes only
	vector hitLocation = result.visiblePosition
	vector vecToEnt    = (hitLocation - barrelPos)
	vecToEnt.Norm()
	if ( Length( vecToEnt ) == 0 )
		vecToEnt = barrelVec

	// This fires a fake bullet that doesn't do any damage. Currently it triggeres a damage callback with 0 damage which is bad.
	WeaponFireBulletSpecialParams fireBulletParams
	fireBulletParams.pos = barrelPos
	fireBulletParams.dir = vecToEnt
	fireBulletParams.bulletCount = 1
	fireBulletParams.scriptDamageType = damageType
	fireBulletParams.skipAntiLag = true
	fireBulletParams.dontApplySpread = true
	fireBulletParams.doDryFire = true
	fireBulletParams.noImpact = false
	fireBulletParams.noTracer = false
	fireBulletParams.activeShot = false
	fireBulletParams.doTraceBrushOnly = false
	weapon.FireWeaponBullet_Special( fireBulletParams ) // fires perfect bullet with no antilag and no spread

	#if SERVER
		// Determine how much damage to do based on distance
		float distanceToTarget = Distance( barrelPos, hitLocation )

		if ( !result.solidBodyHit ) // non solid hits take 1 blast more
			distanceToTarget += 130

		int extraMods = result.extraMods
		float damageAmount = CalcWeaponDamage( owner, target, weapon, distanceToTarget, extraMods )

		// vortex needs to scale damage based on number of rounds absorbed
		string className = weapon.GetWeaponClassName()
		if ( (className == "mp_titanweapon_vortex_shield") || (className == "mp_titanweapon_vortex_shield_ion") || (className == "mp_titanweapon_heat_shield") )
		{
			damageAmount *= numPellets
			//printt( "scaling vortex hitscan output damage by", numPellets, "pellets for", weaponNearDamageTitan, "damage vs titans" )
		}

		float coneScaler = 1.0
		//if ( angle > 0 )
		//	coneScaler = GraphCapped( angle, (maxAngle * SHOTGUN_ANGLE_MIN_FRACTION), (maxAngle * SHOTGUN_ANGLE_MAX_FRACTION), SHOTGUN_DAMAGE_SCALE_AT_MIN_ANGLE, SHOTGUN_DAMAGE_SCALE_AT_MAX_ANGLE )

		// Calculate the final damage abount to inflict on the target. Also scale it by damageScaler which may have been passed in by script ( used by alt fire mode on titan shotgun to fire multiple shells )
		float finalDamageAmount = damageAmount * coneScaler * damageScaler
		//printt( "angle:", angle, "- coneScaler:", coneScaler, "- damageAmount:", damageAmount, "- damageScaler:", damageScaler, "  = finalDamageAmount:", finalDamageAmount )

		// Calculate impulse force to apply based on damage
		float maxImpulseForce = weapon.GetWeaponSettingFloat( eWeaponVar.impulse_force )
		float impulseForce    = maxImpulseForce * coneScaler * damageScaler
		vector impulseVec     = barrelVec * impulseForce

		int damageSourceID = weapon.GetDamageSourceID()

		//
		float critScale   = weapon.GetWeaponSettingFloat( eWeaponVar.critical_hit_damage_scale )
		float shieldScale = weapon.GetWeaponSettingFloat( eWeaponVar.damage_shield_scale )
		target.TakeDamage( finalDamageAmount, owner, weapon, { origin = hitLocation, force = impulseVec, scriptType = damageType, damageSourceId = damageSourceID, weapon = weapon, hitbox = result.visibleHitbox, criticalHitScale = critScale, shieldDamageScale = shieldScale } )
		if ( IsVortexSphere( target ) )
			VortexSphereDrainHealthForDamage( target, finalDamageAmount )

		//printt( "-----------" )
		//printt( "    distanceToTarget:", distanceToTarget )
		//printt( "    damageAmount:", damageAmount )
		//printt( "    coneScaler:", coneScaler )
		//printt( "    impulseForce:", impulseForce )
		//printt( "    impulseVec:", impulseVec.x + ", " + impulseVec.y + ", " + impulseVec.z )
		//printt( "        finalDamageAmount:", finalDamageAmount )
		//PrintTable( result )
	#endif // #if SERVER

	return 1
}


void function FireProjectileShotgunBlast( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired, float outerSpread, float innerSpread, int numProjectiles )
{
	vector vecFwd   = attackParams.dir
	vector vecRight = AnglesToRight( VectorToAngles( attackParams.dir ) )

	array<vector> spreadVecs = GetProjectileShotgunBlastVectors( attackParams.pos, vecFwd, vecRight, outerSpread, innerSpread, numProjectiles )

	for ( int i = 0; i < spreadVecs.len(); i++ )
	{
		vector spreadVec = spreadVecs[i]
		attackParams.dir = spreadVec

		bool ignoreSpread = true  // don't use the normal code spread for this weapon (ie, slightly adjusting outgoing round angle within spread cone)
		bool deferred     = i > (spreadVecs.len() / 2)
		entity bolt       = FireBallisticRoundWithDrop( weapon, attackParams.pos, attackParams.dir, playerFired, ignoreSpread, i, deferred )
	}
}


array<vector> function GetProjectileShotgunBlastVectors( vector pos, vector forward, vector right, float outerSpread, float innerSpead, int numSegments )
{
	#if DEBUG_PROJECTILE_BLAST
		//DebugDrawLine( pos, pos + forward * 250, <255, 0, 0>, true, 3.0 )
		array<vector> outerVecs
		array<vector> innerVecs
	#endif

	int numRadialSegments = numSegments - 1

	float degPerSegment = 360.0 / numRadialSegments
	array<vector> randVecs

	// PROJECTILES RADIALLY SCATTERED AROUND CENTER
	for ( int i = 0 ; i < numRadialSegments ; i++ )
	{
		vector randVec = VectorRotateAxis( forward, right, RandomFloatRange( innerSpead, outerSpread ) )
		randVec = VectorRotateAxis( randVec, forward, RandomFloatRange( degPerSegment * i, degPerSegment * (i + 1) ) )
		randVec.Norm()
		randVecs.append( randVec )

		#if DEBUG_PROJECTILE_BLAST
			vector innerVec = VectorRotateAxis( forward, right, innerSpead )
			innerVec = VectorRotateAxis( innerVec, forward, degPerSegment * i )
			innerVec.Norm()
			innerVecs.append( innerVec )

			vector outerVec = VectorRotateAxis( forward, right, outerSpread )
			outerVec = VectorRotateAxis( outerVec, forward, degPerSegment * i )
			outerVec.Norm()
			outerVecs.append( outerVec )
		#endif
	}

	// CENTER PROJECTILE
	// For random vec inside center...
	//vector randVec = VectorRotateAxis( forward, right, RandomFloat( innerSpead ) )
	//randVec = VectorRotateAxis( randVec, forward, RandomFloat( 360.0 ) )
	//randVec.Norm()

	// Trying first: always have the center projectile fly straight
	randVecs.append( forward )

	#if DEBUG_PROJECTILE_BLAST
		for ( int i = 0 ; i < numRadialSegments ; i++ )
		{
			vector o1 = pos + outerVecs[i] * 250
			vector o2 = (i == numRadialSegments - 1) ? pos + outerVecs[0] * 250 : pos + outerVecs[i + 1] * 250
			vector i1 = pos + innerVecs[i] * 250
			vector i2 = (i == numRadialSegments - 1) ? pos + innerVecs[0] * 250 : pos + innerVecs[i + 1] * 250

			//DebugDrawLine( o1, o2, <255, 255, 0>, true, 3.0 )
			//DebugDrawLine( i1, i2, <255, 255, 0>, true, 3.0 )
			//DebugDrawLine( i1, o1, <255, 255, 0>, true, 3.0 )
		}

		foreach ( vector vec in randVecs )
		{
			//DebugDrawSphere( pos + vec * 250, 1.0, <255, 0, 0>, true, 3.0, 3 )
		}
	#endif

	return randVecs
}


float function ProjectileShotgun_GetOuterSpread( entity weapon )
{
	return weapon.GetAttackSpreadAngle()
}


float function ProjectileShotgun_GetInnerSpread( entity weapon )
{
	float innerSpread = 0

	var innerSpreadVar = expect float ornull( weapon.GetWeaponInfoFileKeyField( "shotgun_spread_radial_innerexclude" ) )
	if ( innerSpreadVar == null )
		innerSpread = ProjectileShotgun_GetOuterSpread( weapon ) * DEFAULT_SHOTGUN_SPREAD_INNEREXCLUDE_FRAC
	else
		innerSpread = expect float ( weapon.GetWeaponInfoFileKeyField( "shotgun_spread_radial_innerexclude" ) )

	return innerSpread
}


void function FireProjectileBlastPattern( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired, array<vector> blastPattern, float patternScale = 1.0, bool ignoreSpread = true )
{
	if ( !IsValid( weapon ) )
		return

	int projectilesPerShot = weapon.GetProjectilesPerShot()
	int patternLength      = blastPattern.len()
	Assert( projectilesPerShot <= patternLength, "Not enough blast pattern points (" + patternLength + ") for " + projectilesPerShot + " projectiles per shot" )

	float defaultPatternScale = expect float( weapon.GetWeaponInfoFileKeyField( "projectile_blast_pattern_default_scale" ) )
	patternScale *= defaultPatternScale
	#if DEBUG_PROJECTILE_BLAST
		printt( "blast pattern scale:", defaultPatternScale )
	#endif

	array<vector> scaledBlastPattern = clone blastPattern

	if ( patternScale != 1.0 )
	{
		for ( int i = 0; i < scaledBlastPattern.len(); i++ )
		{
			scaledBlastPattern[i] *= patternScale
		}
	}

	float patternZeroDistance = expect float( weapon.GetWeaponInfoFileKeyField( "projectile_blast_pattern_zero_distance" ) )

	array<vector> spreadVecs = GetProjectileBlastPatternVectors( attackParams, scaledBlastPattern, patternZeroDistance )

	for ( int i = 0; i < projectilesPerShot; i++ )
	{
		vector spreadVec = spreadVecs[i]
		attackParams.dir = spreadVec

		bool deferred = i > (spreadVecs.len() / 2)
		entity bolt   = FireBallisticRoundWithDrop( weapon, attackParams.pos, attackParams.dir, playerFired, ignoreSpread, i, deferred )
	}
}


array<vector> function GetProjectileBlastPatternVectors( WeaponPrimaryAttackParams attackParams, array<vector> blastPattern, float patternZeroDistance )
{
	vector startPos            = attackParams.pos
	vector forward             = attackParams.dir
	vector right               = AnglesToRight( VectorToAngles( attackParams.dir ) )
	vector up                  = AnglesToUp( VectorToAngles( forward ) )
	vector patternCenterAtZero = startPos + (forward * patternZeroDistance)

	array<vector> patternVecs

	foreach ( offsetVec in blastPattern )
	{
		vector offsetPos = patternCenterAtZero + (right * offsetVec.x)
		offsetPos += (up * offsetVec.y)

		vector vecToTarget = Normalize( offsetPos - startPos )
		patternVecs.append( vecToTarget )

		#if DEBUG_PROJECTILE_BLAST
			//DebugDrawLine( startPos, offsetPos, <255, 0, 0>, true, 3.0 )
		#endif
	}

	return patternVecs
}


entity function FireBallisticRoundWithDrop( entity weapon, vector pos, vector dir, bool isPlayerFired, bool ignoreSpread, int projectileIndex, bool deferred )
{
	int boltSpeed   = int( weapon.GetWeaponSettingFloat( eWeaponVar.projectile_launch_speed ) )
	int damageFlags = weapon.GetWeaponDamageFlags()

	float boltGravity  = 0.0
	vector originalDir = dir
	if ( weapon.GetWeaponSettingBool( eWeaponVar.bolt_gravity_enabled ) )
	{
		var zeroDistance = weapon.GetWeaponSettingFloat( eWeaponVar.bolt_zero_distance )
		if ( zeroDistance == null )
			zeroDistance = 4096.0

		expect float( zeroDistance )

		boltGravity = weapon.GetWeaponSettingFloat( eWeaponVar.projectile_gravity_scale )
		float worldGravity = GetConVarFloat( "sv_gravity" ) * boltGravity
		float time         = zeroDistance / float( boltSpeed )

		if ( DEBUG_BULLET_DROP <= 1 )
			dir += (GetZVelocityForDistOverTime( zeroDistance, time, worldGravity ) / boltSpeed)
	}

	WeaponFireBoltParams fireBoltParams
	fireBoltParams.pos = pos
	fireBoltParams.dir = dir
	fireBoltParams.speed = 1
	fireBoltParams.scriptTouchDamageType = damageFlags
	fireBoltParams.scriptExplosionDamageType = damageFlags
	fireBoltParams.clientPredicted = isPlayerFired
	fireBoltParams.additionalRandomSeed = 0
	fireBoltParams.dontApplySpread = ignoreSpread
	fireBoltParams.projectileIndex = projectileIndex
	fireBoltParams.deferred = deferred
	entity bolt = weapon.FireWeaponBoltAndReturnEntity( fireBoltParams )

	#if CLIENT
		Chroma_FiredWeapon( weapon )
	#endif

	return bolt
}


string function GetDistanceString( float distInches )
{
	float distFeet   = distInches / 12.0
	float distYards  = distInches / 36.0
	float distMeters = distInches / 39.3701

	return format( "%.2fm %.2fy %.2ff %.2fin", distMeters, distYards, distFeet, distInches )
}


vector function GetZVelocityForDistOverTime( float distance, float duration, float gravity )
{
	vector startPoint = ZERO_VECTOR
	vector endPoint   = <distance, 0, 0>

	float vox = distance / duration
	float voz = 0.5 * gravity * duration * duration / duration
	return <0, 0, voz>

	//float vox = (endPoint.x - startPoint.x) / duration
	//float voy = (endPoint.y - startPoint.y) / duration
	//float voz = (endPoint.z + 0.5 * gravity * duration * duration - startPoint.z) / duration
	//return <vox ,voy, voz>
}


int function FireGenericBoltWithDrop( entity weapon, WeaponPrimaryAttackParams attackParams, bool isPlayerFired )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return 1
	#endif // #if CLIENT

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	const float PROJ_SPEED_SCALE = 1
	const float PROJ_GRAVITY = 1
	int damageFlags = weapon.GetWeaponDamageFlags()
	WeaponFireBoltParams fireBoltParams
	fireBoltParams.pos = attackParams.pos
	fireBoltParams.dir = attackParams.dir
	fireBoltParams.speed = PROJ_SPEED_SCALE
	fireBoltParams.scriptTouchDamageType = damageFlags
	fireBoltParams.scriptExplosionDamageType = damageFlags
	fireBoltParams.clientPredicted = isPlayerFired
	fireBoltParams.additionalRandomSeed = 0
	entity bolt = weapon.FireWeaponBoltAndReturnEntity( fireBoltParams )
	if ( bolt != null )
	{
		bolt.kv.gravity = PROJ_GRAVITY
		bolt.kv.rendercolor = "0 0 0"
		bolt.kv.renderamt = 0
		bolt.kv.fadedist = 1
	}
	#if CLIENT
		Chroma_FiredWeapon( weapon )
	#endif


	return 1
}


var function OnWeaponPrimaryAttack_GenericBoltWithDrop_Player( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireGenericBoltWithDrop( weapon, attackParams, true )
}


var function OnWeaponPrimaryAttack_EPG( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	WeaponFireMissileParams fireMissileParams
	fireMissileParams.pos = attackParams.pos
	fireMissileParams.dir = attackParams.dir
	fireMissileParams.speed = 1
	fireMissileParams.scriptTouchDamageType = damageTypes.largeCaliberExp
	fireMissileParams.scriptExplosionDamageType = damageTypes.largeCaliberExp
	fireMissileParams.doRandomVelocAndThinkVars = false
	fireMissileParams.clientPredicted = false
	entity missile = weapon.FireWeaponMissile( fireMissileParams )
	if ( missile )
	{
		EmitSoundOnEntity( missile, "Weapon_Sidwinder_Projectile" )
		missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
	}

	return missile
}


bool function PlantStickyEntityOnWorldThatBouncesOffWalls( entity ent, DeployableCollisionParams collisionParams, float bounceDot, vector angleOffset = ZERO_VECTOR, bool ignoreHullTrace = false )
{
	entity hitEnt = collisionParams.hitEnt
	if ( HitEntIsValidToStick( hitEnt ) )
	{
		float dot = collisionParams.normal.Dot( <0, 0, 1> )

		if ( dot < bounceDot )
		{
			#if SERVER
				if ( ent.e.lastBouncePosition == ZERO_VECTOR )
				{
					ent.e.lastBouncePosition = ent.GetOrigin()
					return false
				}

				float dist = Distance( ent.e.lastBouncePosition, ent.GetOrigin() )
				ent.e.lastBouncePosition = ent.GetOrigin()

				if ( dist > BOUNCE_STUCK_DISTANCE )
					return false
			#else
				return false
			#endif
		}

		return PlantStickyEntity( ent, collisionParams, angleOffset, ignoreHullTrace )
	}

	return false
}

bool function HitEntIsValidToStick( hitEnt )
{
	if ( !hitEnt || !IsValid( hitEnt ) )
		return false

	var hitEntName = hitEnt.GetScriptName()
	
	if ( hitEnt.IsWorld() )
		return true
	if ( hitEnt.HasPusherAncestor() )
		return true
	if ( hitEnt.IsFuncBrush() )
		return true
	if ( hitEntName == "ziprail_launcher_prop" )
		return true
	if ( hitEntName == "jump_tower" )
		return true

	return false
}

#if DEVELOPER
const bool DEBUG_SURFACE_TEST = false
const float DEBUG_SURFACE_TEST_TIME = 20
#endif
const float SURFACE_TEST_TRACE_LENGTH = 66

bool function PlantStickyEntityOnConsistentSurface( entity projectile, DeployableCollisionParams collisionParams, float consistentDotThreshold, float size, vector angleOffset = ZERO_VECTOR )
{
	bool surfaceIsConsistent = true

	//Test 4 points around the collision point and check if they are consistent with the collision normal.
	vector forward = CrossProduct( collisionParams.normal, <1, 0, 0> ) //cross with arbitrary axis vector to find plane perpendicular to normal
	if ( Length( forward ) == 0.0 )
	{
		forward = CrossProduct( collisionParams.normal, <0, 0, 1> )
	}
	vector surfaceAngles = AnglesOnSurface( collisionParams.normal, forward )
	vector right         = AnglesToRight( surfaceAngles )

	#if DEVELOPER
		if ( DEBUG_SURFACE_TEST )
		{
			//DebugDrawArrow( collisionParams.pos, collisionParams.pos +forward*33, 10, <0, 0, 255>, true, 10.0)
			//DebugDrawArrow( collisionParams.pos, collisionParams.pos +right*33, 10, <255, 0, 0>, true, 10.0)
			 //DebugDrawArrow( collisionParams.pos, collisionParams.pos + collisionParams.normal * SURFACE_TEST_TRACE_LENGTH / 2, 10, <0, 255, 0>, true, DEBUG_SURFACE_TEST_TIME )
		}
	#endif

	int goodHitCount            = 0
	array<vector> testPositions = [ <-1, -1, 0>, <-1, 1, 0>, <1, 1, 0>, <1, -1, 0> ]
	for ( int i = 0; i < testPositions.len(); ++i )
	{
		vector testPos = testPositions[i]

		vector origin    = collisionParams.pos + collisionParams.normal * size
		vector endOrigin = origin + forward * testPos.x * size + right * testPos.y * size - collisionParams.normal * SURFACE_TEST_TRACE_LENGTH

		#if DEVELOPER
			if ( DEBUG_SURFACE_TEST )
			{
				//DebugDrawArrow( origin, endOrigin, 5, COLOR_CYAN, true, DEBUG_SURFACE_TEST_TIME )
			}
		#endif
		TraceResults traceResult = TraceLine( origin, endOrigin, [ projectile ], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )

		if ( traceResult.fraction < 1.0 ) //Trace Hit something
		{
			float dot = traceResult.surfaceNormal.Dot( collisionParams.normal )
			if ( dot < consistentDotThreshold )
			{
				surfaceIsConsistent = false
				#if DEVELOPER
					if ( DEBUG_SURFACE_TEST )
					{
						DebugDrawArrow( traceResult.endPos, traceResult.endPos + traceResult.surfaceNormal * 20, 5, <255, 100, 0>, true, DEBUG_SURFACE_TEST_TIME )
					}
				#endif
			}
			else
			{
				goodHitCount++
				#if DEVELOPER
					if ( DEBUG_SURFACE_TEST )
					{
						DebugDrawArrow( traceResult.endPos, traceResult.endPos + traceResult.surfaceNormal * 20, 5, <100, 255, 0>, true, DEBUG_SURFACE_TEST_TIME )
					}
				#endif
			}
		}
		else
		{
			surfaceIsConsistent = false
			break
		}
	}


	if ( !surfaceIsConsistent )
	{
		#if SERVER
			if ( projectile.IsProjectile() )
			{
				if ( projectile.proj.bounceFunc != null )
					projectile.proj.bounceFunc( projectile, collisionParams )

				if ( projectile.proj.projectileForceBounceWithinDist > 0.0 && projectile.proj.projectileFirstProperBouncePos == null )
					projectile.proj.projectileFirstProperBouncePos = collisionParams.pos
			}
		#endif

		return false
	}

	return PlantStickyEntity( projectile, collisionParams, angleOffset )
}

bool function PlantStickyEntityThatBouncesOffWalls( entity projectile, DeployableCollisionParams cp, float bounceDot, vector angleOffset = ZERO_VECTOR )
{
                     
	if ( IsBitFlagSet( cp.deployableFlags, eDeployableFlags.VEHICLES_LARGE_DEPLOYABLE ) && EntIsHoverVehicle( cp.hitEnt ) )
		return PlantStickyEntity_LargeDeployableOnVehicle( projectile, cp, angleOffset )
                           

	float dot = cp.normal.Dot( UP_VECTOR )
	if ( dot < bounceDot )
	{
		#if SERVER
			if ( projectile.IsProjectile() )
			{
				if ( projectile.proj.bounceFunc != null )
					projectile.proj.bounceFunc( projectile, cp )
				if ( projectile.proj.projectileForceBounceWithinDist > 0.0 && projectile.proj.projectileFirstProperBouncePos == null )
					projectile.proj.projectileFirstProperBouncePos = cp.pos
			}
		#endif
		return false
	}

	#if SERVER
		if ( projectile.IsProjectile()
		&& (projectile.proj.projectileForceBounceWithinDist > 0.0)
		&& (projectile.proj.projectileFirstProperBouncePos != null)
		&& (Distance( projectile.GetOrigin(), expect vector( projectile.proj.projectileFirstProperBouncePos ) ) < projectile.proj.projectileForceBounceWithinDist)
		&& (projectile.proj.projectileBounceCount < 8)
		&& (Length( projectile.GetVelocity() ) > 1.0) )
		{
			return false
		}
	#endif

	return PlantStickyEntity( projectile, cp, angleOffset )
}


#if DEVELOPER
const bool DEBUG_DRAW_PLANT_STICKY = false
#endif

bool function PlantStickyEntity( entity ent, DeployableCollisionParams cp, vector angleOffset = ZERO_VECTOR, bool ignoreHullTrace = false, bool moveOnNoHitTrace = true )
{
	if ( !EntityShouldStickEx( ent, cp ) )
		return false
	Assert( !ent.IsMarkedForDeletion(), "" )
	Assert( !cp.hitEnt.IsMarkedForDeletion(), "" )

	// Update normal from last bounce so when it explodes it can orient the effect properly
	if ( LengthSqr( cp.normal ) <= FLT_EPSILON )
	{
		Warning( "PlantStickyEntity: normal vector " + cp.normal + " is a zero vector. Entity: '" + ent + "' is sticking to HitEnt: '" + cp.hitEnt + "' at position: " + cp.pos )
		cp.normal = UP_VECTOR
	}

	vector plantAngles = AnglesCompose( VectorToAngles( cp.normal ), angleOffset )
	vector plantPosition
	if ( ignoreHullTrace )
	{
		plantPosition = cp.pos
	}
	else
	{
		#if DEVELOPER
		if ( DEBUG_DRAW_PLANT_STICKY )
		{
			//DebugDrawSphere( cp.pos, 5, <255, 255, 0>, false, 60 )
			//DebugDrawArrow( cp.pos, cp.pos + cp.normal*20, 10, <255, 255, 0>, false, 60 )
		}
		#endif
		vector traceDir    = cp.normal * -1
		vector mins        = cp.ignoreHullSize ? ZERO_VECTOR: ent.GetBoundingMins()
		vector maxs        = cp.ignoreHullSize ? ZERO_VECTOR: ent.GetBoundingMaxs()
		vector entPos 	   = cp.pos
		int traceMask 	   = (ent.IsProjectile() && ent.GetProjectileWeaponSettingBool( eWeaponVar.grenade_use_mask_ability )) ? TRACE_MASK_ABILITY : TRACE_MASK_SHOT
		array<entity> ignoreEnts = [ent]
		if ( ent.IsProjectile() && ent.proj.ignoreOwnerForPlaceStickyEnt && IsValid( ent.GetOwner() ) )
			ignoreEnts.append( ent.GetOwner() )

		TraceResults trace
		if( ( cp.hitEnt.IsPlayer() || cp.hitEnt.IsNPC() ) && ent.IsProjectile() && ent.ProjectileGetWeaponClassName() == "mp_weapon_cluster_bomb_launcher" )
		{
			vector center = cp.hitEnt.GetWorldSpaceCenter()
			center.z = entPos.z
			trace = TraceLineHighDetail( entPos, center, ignoreEnts, traceMask, TRACE_COLLISION_GROUP_NONE )
		}
		else if( cp.highDetailTrace ) // useHighDetailCollisionTraceForPlaceStickyEnt not in S3 ClientProjectileStruct
		{
			trace = TraceHull( entPos, ( entPos + ( traceDir * cp.traceLength ) ), mins, maxs, ignoreEnts, ( traceMask & ~CONTENTS_HITBOX ), TRACE_COLLISION_GROUP_NONE ) //TraceHullHighDetail not in S3
		}
		else
		{
			trace = TraceHull( entPos, ( entPos + ( traceDir * cp.traceLength ) ), mins, maxs, ignoreEnts, ( traceMask & ~CONTENTS_HITBOX ), TRACE_COLLISION_GROUP_NONE, cp.normal )
		}

		if( moveOnNoHitTrace || trace.fraction < 1.0 )
		{
			plantPosition = trace.endPos
		
			#if DEVELOPER
			if ( DEBUG_DRAW_PLANT_STICKY )
			{
				//DebugDrawSphere( plantPosition, 3, <255, 0, 0>, false, 60 )
			}
			#endif
		}
		else
		{
			plantPosition = cp.pos
			
			#if DEVELOPER
			if ( DEBUG_DRAW_PLANT_STICKY )
			{
				//DebugDrawSphere( plantPosition, 3, <0, 0, 255>, false, 60 )
			}
			#endif
		}

		if ( !LegalOrigin( plantPosition ) )
			return false

		if ( trace.startSolid && IsValid( trace.hitEnt ) && !trace.hitEnt.IsWorld() && ent.IsProjectile() && ent.GetProjectileWeaponSettingBool( eWeaponVar.grenade_mover_destroy_when_planted ) )
		{
			#if SERVER
				ent.Destroy()
			#endif
			return false
		}
	}

	if ( IsOriginInvalidForPlacingPermanentOnto( plantPosition ) )
		return false

	#if SERVER
		ent.SetAbsOrigin( plantPosition )
		ent.SetAbsAngles( plantAngles )
		if ( ent.IsProjectile() )
			ent.proj.isPlanted = true
	#else
		ent.SetOrigin( plantPosition )
		ent.SetAngles( plantAngles )
	#endif
	ent.SetVelocity( ZERO_VECTOR )

	//run these checks again, since ent can get marked for deletion due to the above movement commands
	if ( !EntityShouldStickEx( ent, cp ) )
		return false
	Assert( !ent.IsMarkedForDeletion(), "" )
	Assert( !cp.hitEnt.IsMarkedForDeletion(), "" )

	//printt( " - Hitbox is:", cp.hitbox, " IsWorld:", cp.hitEnt )
	if ( cp.hitEnt.IsWorld() )
	{
		ent.SetVelocity( ZERO_VECTOR )
		ent.StopPhysics()
	}
	else
	{
		if ( cp.hitBox > 0 )
			ent.SetParentWithHitbox( cp.hitEnt, cp.hitBox, true )
		else
			ent.SetParent( cp.hitEnt )	// Hit something else (like a func_brush or even another grenade)

		if ( cp.hitEnt.IsPlayer() || IsDoor( cp.hitEnt ) || IsReinforced (cp.hitEnt))
			thread HandleDisappearingParent( ent, cp.hitEnt )
	}

	CommonOnSuccessfulStickyPlant( ent, cp )
	return true
}

void function CommonOnSuccessfulStickyPlant( entity ent, DeployableCollisionParams cp )
{
	if ( IsABaseGrenade( ent ) )
	{
		ent.MarkAsAttached()
		ent.AddGrenadeStatusFlag( GSF_PLANTED )
	}
	if ( ent.IsProjectile() )
	{
		ent.proj.isPlanted = true
		if ( ent.proj.deployFunc != null )
			ent.proj.deployFunc( ent, cp )
	}
}

                     
bool function PlantStickyEntity_LargeDeployableOnVehicle( entity ent, DeployableCollisionParams cp, vector angleOffset = ZERO_VECTOR )
{
	if ( !HoverVehicle_AttachEntToNearestAbilityAttachment( ent, cp.hitEnt, false, false, ZERO_VECTOR ) )
		return false
	CommonOnSuccessfulStickyPlant( ent, cp )
	return true
}
                           

#if SERVER
void function ArrowsUnstick( entity ent )
{
	ent.Signal( ARROWS_UNSTICK_SIGNAL )
}
#endif

bool function IsABaseGrenade( entity ent )
{
	#if CLIENT
		return (ent instanceof C_BaseGrenade)
	#else
		return (ent instanceof CBaseGrenade)
	#endif
}

#if SERVER
void function HandleDisappearingParent( entity ent, entity parentEnt )
{
	parentEnt.EndSignal( "OnDeath", "OnDestroy", "PassiveReinforceResetRebuiltDoor", PHASE_DOOR_TELEPORT_SIGNAL, "StartPhaseShift", "DeathTotem_PreRecallPlayer" )
	ent.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( ent )
		{
			if ( IsValid( ent ) )
				ent.ClearParent()
		}
	)

	WaitForever()
}
#else
void function HandleDisappearingParent( entity ent, entity parentEnt )
{
	parentEnt.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	parentEnt.WaitSignal( "StartPhaseShift", "DeathTotem_PreRecallPlayer" )

	ent.ClearParent()
}
#endif

string function GetClassnamefromStickyHitEnt( entity hitEnt )
{
	string ornull classNameRaw = hitEnt.GetNetworkedClassName()
	return ((classNameRaw == null) ? "" : expect string( classNameRaw ))
}

bool function EntityShouldStickEx( entity stickyEnt, DeployableCollisionParams params )
{
	entity hitEnt = params.hitEnt
	if ( !EntityCanHaveStickyEnts( stickyEnt, hitEnt ) )
		return false

	string className = GetClassnamefromStickyHitEnt( hitEnt )
	if ( className == "prop_door" )
	{
		float normal = ((params.normal == ZERO_VECTOR) ? 0.0 : params.normal.Dot( UP_VECTOR ))
		if ( normal > DOT_60DEGREE )
			return false
	}

	if ( stickyEnt.IsMarkedForDeletion() )
		return false
	if ( hitEnt.IsMarkedForDeletion() )
		return false
	if ( hitEnt == stickyEnt )
		return false
	if ( hitEnt == stickyEnt.GetParent() )
		return false

                     
	if ( IsBitFlagSet( params.deployableFlags, eDeployableFlags.VEHICLES_NO_STICK ) && ( className == "player_vehicle" ) )
		return false
                           

	if ( hitEnt.GetScriptName() == DIRTY_BOMB_TARGETNAME && params.hitBox == 0 && stickyEnt.GetScriptName() != RIOT_DRILL_SCRIPT_NAME)
		return false

	return true
}
bool function EntityShouldStick( entity stickyEnt, entity hitEnt )
{
	DeployableCollisionParams params
	params.hitEnt = hitEnt
	return EntityShouldStickEx( stickyEnt, params )
}

bool function EntityCanHaveStickyEnts( entity stickyEnt, entity ent )
{
	if ( !IsValid( ent ) )
		return false

	string stickyEntScriptName = stickyEnt.GetScriptName()
	string entScriptName = ent.GetScriptName()

	if ( ent.GetModelName() == $"" ) // valid case, other projectiles bullets, etc.. sometimes have no model
		return false

	// Don't allow parenting to another "sticky" entity to prevent them parenting onto each other
	if ( ent.IsProjectile() )
		return false

	string stickyEntWeaponClassName = ""

#if SERVER
	if ( stickyEnt instanceof CProjectile )
#else
	if ( stickyEnt instanceof C_Projectile )
#endif
	{
		stickyEntWeaponClassName = stickyEnt.ProjectileGetWeaponClassName()
	}

	var entClassname = ent.GetNetworkedClassName()
	if ( entClassname == null )
		return false

	// todo: Add future throwables and placed ents to the throwable_item_stickiness.csv to gain control over what sticks to things
	// Allows for more case-by-case choices for whether a thrown item will stick or not.
	// IMPORTANT: When adding a new throwable item (a new row) you need to add the row name to the array in InitThrowableItemStickinessDatatable.
	// We can't currently read row headers so we have to match the name in script
	// In the file, a 1 means it will stick, a 0 means it will not stick, and a -1 means we do nothing and default to other logic.
	string stickyThrowableName = stickyEntWeaponClassName == "" ? stickyEntScriptName : stickyEntWeaponClassName
	int stickyValue = GetThrowableEntStickinessToEntity( stickyThrowableName, entScriptName )
	if (  stickyValue != ITEM_NOT_FOUND_STICKINESS )
		return stickyValue == ITEM_STICKS

	// Large doors currently are unnamed on the client, and misnamed on the server...so just bail on them when the server sees a large door
	if ( entClassname == "phys_bone_follower" && stickyEntWeaponClassName == "mp_weapon_throwingknife" )
		return false

	if ( entClassname == "prop_lootroller" && stickyEntWeaponClassName != "" )
		return true

	// Stop items from sticking to deathboxes placed on a trident in relation to R5DEV-554908 which allowed many abilities to be glitched onto tridents.
	if ( entClassname == "prop_death_box" && IsEntParentedToObjectOfScriptname( ent, "hover_vehicle" ) )
		return false

	// Note: these should be covered by the above GetThrowableEntStickinessToEntity check, but they are left in incase
	// the file is missing any types
	if ( entScriptName == WRECKING_BALL_BALL_SCRIPT_NAME )
		return true
	//allows sticking the Tactical (Riot Drill) to things normally flagged ent.e.preventStickyEnts later
	if ( stickyEntScriptName == RIOT_DRILL_SCRIPT_NAME )
		return true

	if ( stickyEntWeaponClassName == "mp_ability_debuff_zone" && DebuffZone_GetAllowableStickyEnts( ent ) )
		return true

	if( IsForgedShadowsShield( ent ) )
		return ShadowShield_IsAllowedStickyEnt( ent, stickyEnt, stickyEntWeaponClassName )

	//allows sticking exceptions to the Newcastle Mobile Shield
	if ( entScriptName == MOBILE_SHIELD_SCRIPTNAME )
		return MobileShield_IsAllowedStickyEnt( ent, stickyEnt, stickyEntWeaponClassName )

	                      
		//For the Gravity Cannons we hit the phys_bone_follower first, need to get the owner to get the actual grav cannon ent.
		if ( entClassname == "phys_bone_follower" && IsValid( ent.GetOwner() ) )
		{
			entity cannonEnt = ent.GetOwner()

			if ( cannonEnt.GetScriptName() == GetEnumString( "eSkydiveLauncherType", eSkydiveLauncherType.GRAVITY_CANNON ) )
			{
				//We don't want to disallow ALL sticky ents on the Grav Cannon.  IE sticking an Arc Star on them is fine, but a Caustic barrel is not because it will block player movement, so when a player is laucnhed they collide with the barrel and fly in a much diff direction.
				//There's an enum INVALID_GRAVITY_CANNON_PLACEABLES that contains a list of all weapon ents to block.  Add any future sticky ents there that we want to block as well.
				if ( INVALID_GRAVITY_CANNON_PLACEABLES.contains( stickyEntWeaponClassName ) )
				{
					return false
				}
			}
		}
       

	if ( !(string( entClassname ) in STICKY_CLASSES) && !ent.IsNPC() )
		return false

	#if SERVER
		if ( entClassname == "prop_dynamic" )
		{
			if ( IsValid( ent.e.ownerWeapon ) && ent.e.ownerWeapon.GetWeaponUtilityEntity() == ent )
				return false
		}
	#endif

	if ( stickyEntWeaponClassName != "" )
	{
		//local stickTitan  =
		//if ( ent.IsTitan() && (GetWeaponInfoFileKeyField_Global( stickyEntWeaponClassName, "stick_titan" ) == 0) )
		//	return false

		if ( ent.IsPlayer() && (GetWeaponInfoFileKeyField_Global( stickyEntWeaponClassName, "stick_pilot" ) == 0) )
			return false
		if ( ent.IsNPC() && (GetWeaponInfoFileKeyField_Global( stickyEntWeaponClassName, "stick_npc" ) == 0) )
			return false
		if ( (ent.GetScriptName() == CRYPTO_DRONE_SCRIPTNAME ) && (GetWeaponInfoFileKeyField_Global( stickyEntWeaponClassName, "stick_drone" ) == 0) )
			return false
	}

	#if SERVER
		if ( ent.e.preventStickyEnts )
			return false
	#endif // SERVER

	return true
}

#if DEVELOPER
void function DEV_DumpStickinessTable()
{
	bool dumpedEnts = false
	foreach( string throwable, table<string, int> ent in file.throwableItemStickinessTable )
	{
		if ( !dumpedEnts )
		{
			printf("Ents: ")
			foreach( string name, int tmp in file.throwableItemStickinessTable[throwable] )
			{
				printf("-> " + name)
			}
			printf("Throwables: ")
			dumpedEnts = true
		}

		printf("-> " + throwable)
	}
}
#endif

int function GetThrowableEntStickinessToEntity( string stickyThrowableName, string entScriptName )
{
	if ( stickyThrowableName in file.throwableItemStickinessTable &&
			entScriptName in file.throwableItemStickinessTable[ stickyThrowableName ] )
		return file.throwableItemStickinessTable[ stickyThrowableName ][ entScriptName ]

	return ITEM_NOT_FOUND_STICKINESS
}

bool function IsEntParentedToObjectOfScriptname( entity ent, string scriptname )
{
	entity parentEnt = ent.GetParent()
	while ( IsValid( parentEnt ) )
	{
		if ( parentEnt.GetScriptName() == scriptname )
			return true

		parentEnt = parentEnt.GetParent()
	}
	return false
}

#if DEVELOPER
void function ShowExplosionRadiusOnExplode( entity ent )
{
	ent.WaitSignal( "OnDestroy" )

	float innerRadius = expect float( ent.GetWeaponInfoFileKeyField( "explosion_inner_radius" ) )
	float outerRadius = expect float( ent.GetWeaponInfoFileKeyField( "explosionradius" ) )

	vector org    = ent.GetOrigin()
	vector angles = ZERO_VECTOR
	//thread DebugDrawCircle( org, angles, innerRadius, <255, 255, 51>, true, 3.0 )
	//thread DebugDrawCircle( org, angles, outerRadius, <255, 255, 255>, true, 3.0 )
}
#endif // DEVELOPER


#if SERVER
// shared between nades, satchels and laser mines
void function TrapExplodeOnDamage( entity trapEnt, int trapEntHealth = 50, float waitMin = 0.0, float waitMax = 0.0, bool destroyOnEnemyDamage = false, bool delayDetonateOnOwnerDamage = false )
{
	Assert( IsValid( trapEnt ), "Given trapEnt entity is not valid, fired from: " + trapEnt.ProjectileGetWeaponClassName() )
	EndSignal( trapEnt, "OnDestroy" )

	trapEnt.SetDamageNotifications( true )
	var results //Really should be a struct
	entity attacker
	entity inflictor

	while ( true )
	{
		if ( !IsValid( trapEnt ) )
			return

		results = WaitSignal( trapEnt, "OnDamaged" )
		attacker = expect entity( results.activator )
		inflictor = expect entity( results.inflictor )

		if ( IsValid( inflictor ) && inflictor == trapEnt )
			continue

		bool shouldDamageTrap = false
		if ( IsValid( attacker ) )
		{
			if ( trapEnt.proj.onlyAllowSmartPistolDamage )
			{
				if ( attacker.IsNPC() || attacker.IsPlayer() )
				{
					foreach ( weapon in attacker.GetAllActiveWeapons() )
					{
						if ( WeaponIsSmartPistolVariant( weapon ) )
						{
							shouldDamageTrap = true
							break
						}
					}
				}
			}
			else
			{
				if ( IsFriendlyTeam( trapEnt.GetTeam(), attacker.GetTeam() ) )
				{
					if ( trapEnt.GetOwner() != attacker )
						shouldDamageTrap = false
					else
						shouldDamageTrap = !ProjectileIgnoresOwnerDamage( trapEnt )
				}
				else
				{
					shouldDamageTrap = true
				}
			}
		}

		if ( shouldDamageTrap )
			trapEntHealth -= int( results.value ) //TODO: This returns float even though it feels like it should return int

		if ( trapEntHealth <= 0 )
			break
	}

	if ( !IsValid( trapEnt ) )
		return

	inflictor = expect entity( results.inflictor ) // waiting on code feature to pass inflictor with OnDamaged signal results table

	if ( waitMin >= 0 && waitMax > 0 )
	{
		float waitTime = RandomFloatRange( waitMin, waitMax )

		if ( waitTime > 0 )
			wait waitTime
	}
	else if ( IsValid( inflictor ) && (inflictor.IsProjectile() || (inflictor instanceof CWeaponX)) )
	{
		int dmgSourceID
		if ( inflictor.IsProjectile() )
			dmgSourceID = inflictor.ProjectileGetDamageSourceID()
		else
			dmgSourceID = inflictor.GetDamageSourceID()

		string inflictorClass = GetObitFromDamageSourceID( dmgSourceID )

		if ( inflictorClass in level.trapChainReactClasses )
		{
			// chain reaction delay
			Wait( RandomFloatRange( 0.2, 0.275 ) )
		}
	}

	if ( !IsValid( trapEnt ) )
		return
	
               
                                                                                           
  
                           
                     
                              
                                     
                                                   
                                   

                                      
  
     
       
	if ( destroyOnEnemyDamage )
	{
		StartParticleEffectInWorld( GetParticleSystemIndex( $"P_fuse_tac_exp_air" ), trapEnt.GetOrigin(), ZERO_VECTOR )
		trapEnt.Destroy()
	}
	else
	{
		trapEnt.GrenadeExplode( trapEnt.GetForwardVector() )
	}
}

bool function ProjectileIgnoresOwnerDamage( entity projectile )
{
	var ignoreOwnerDamage = projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_ignore_owner_damage" )

	if ( ignoreOwnerDamage == null )
		return false

	return ignoreOwnerDamage == 1
}

bool function WeaponIsSmartPistolVariant( entity weapon )
{
	var isSP = weapon.GetWeaponInfoFileKeyField( "is_smart_pistol" )

	//printt( isSP )

	if ( isSP == null )
		return false

	return (isSP == 1)
}

// NOTE: we should stop using this
void function TrapDestroyOnRoundEnd( entity player, entity trapEnt )
{
	trapEnt.EndSignal( "OnDestroy" )
	waitthread WaitForTrapDestroyTriggers( player, trapEnt )
	if ( IsValid( trapEnt ) )
		trapEnt.Destroy()
}

void function WaitForTrapDestroyTriggers( entity player, entity trapEnt )
{
	if ( IsValid( player ) )
		EndThreadOn_PlayerCleanupPermanents( player )

	Assert( IsValid( player ), "WaitForTrapDestroyTriggers passed invalid player for prop " + trapEnt.GetScriptName() )

	svGlobal.levelEnt.WaitSignal( "ClearedPlayers" )
}

void function AddPlayerScoreForTrapDestruction( entity player, entity trapEnt )
{
	// don't get score for killing your own trap
	if ( "originalOwner" in trapEnt.s && trapEnt.s.originalOwner == player )
		return

	string trapClass = trapEnt.ProjectileGetWeaponClassName()
	if ( trapClass == "" )
		return

	string scoreEvent
	if ( trapClass == "mp_weapon_satchel" )
		scoreEvent = "Destroyed_Satchel"
	else if ( trapClass == "mp_weapon_proximity_mine" )
		scoreEvent = "Destored_Proximity_Mine"

	if ( scoreEvent == "" )
		return

	AddPlayerScore( player, scoreEvent, trapEnt )
}
#endif // SERVER

bool function WeaponCanCrit( entity weapon )
{
	// player sometimes has no weapon during titan exit, mantle, etc...
	if ( !weapon )
		return false

	return weapon.GetWeaponSettingBool( eWeaponVar.critical_hit )
}


vector function GetVectorFromPositionToCrosshair( entity player, vector startPos )
{
	Assert( IsValid( player ) )

	// See where we're looking
	vector traceStart        = player.EyePosition()
	vector traceEnd          = traceStart + (player.GetViewVector() * 20000)
	array<entity> ignoreEnts = [ player ]
	TraceResults traceResult = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	// Return vec from startPos to where we are looking
	vector vec = traceResult.endPos - startPos
	vec = Normalize( vec )
	return vec
}

/*
function InitMissileForRandomDriftBasic( missile, startPos, startDir )
{
	missile.s.RandomFloatRange <- RandomFloat( 1.0 )
	missile.s.startPos <- startPos
	missile.s.startDir <- startDir
}
*/

void function InitMissileForRandomDriftForVortexHigh( entity missile, vector startPos, vector startDir )
{
	missile.InitMissileForRandomDrift( startPos, startDir, 8, 2.5, 0, 0, 100, 100, 0 )
}


void function InitMissileForRandomDriftForVortexLow( entity missile, vector startPos, vector startDir )
{
	missile.InitMissileForRandomDrift( startPos, startDir, 0.3, 0.085, 0, 0, 0.5, 0.5, 0 )
}

/*
function InitMissileForRandomDrift( missile, startPos, startDir )
{
	InitMissileForRandomDriftBasic( missile, startPos, startDir )

	missile.s.drift_windiness <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_drift_windiness" )
	missile.s.drift_intensity <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_drift_intensity" )

	missile.s.straight_time_min <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_time_min" )
	missile.s.straight_time_max <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_time_max" )

	missile.s.straight_radius_min <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_radius_min" )
	if ( missile.s.straight_radius_min < 1 )
		missile.s.straight_radius_min = 1
	missile.s.straight_radius_max <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_radius_max" )
	if ( missile.s.straight_radius_max < 1 )
		missile.s.straight_radius_max = 1
}

function SmoothRandom( x )
{
	return 0.25 * (sin(x) + sin(x * 0.762) + sin(x * 0.363) + sin(x * 0.084))
}

function MissileRandomDrift( timeElapsed, timeStep, windiness, intensity )
{
	// This function makes the missile go in a random direction.
	// Windiness is how frequently the missile changes direction.
	// Intensity is how strongly the missile steers in the direction it has chosen.

	local sampleTime = timeElapsed - timeStep * 0.5

	intensity *= timeStep

	local offset = self.s.RandomFloatRange * 1000

	local offsetx = intensity * SmoothRandom( offset     +       sampleTime * windiness )
	local offsety = intensity * SmoothRandom( offset * 2 + 100 + sampleTime * windiness )

	local right = self.GetRightVector()
	local up = self.GetUpVector()

	//DebugDrawLine( self.GetOrigin(), self.GetOrigin() + right * 100, <255, 255, 255>, true, 0 )
	//DebugDrawLine( self.GetOrigin(), self.GetOrigin() + up * 100, <255,128,255>, true, 0 )

	local dir = self.GetVelocity()
	float speed = Length( dir )
	dir = Normalize( dir )
	dir += right * offsetx
	dir += up * offsety
	dir = Normalize( dir )
	dir *= speed

	return dir
}

// designed to be called every frame (GetProjectileVelocity callback) on projectiles that are flying through the air
function ApplyMissileControlledDrift( missile, timeElapsed, timeStep )
{
	// If we have a target, don't do anything fancy; just let code do the homing behavior
	if ( missile.GetMissileTarget() )
		return missile.GetVelocity()

	local s = missile.s
	return MissileControlledDrift( timeElapsed, timeStep, s.drift_windiness, s.drift_intensity, s.straight_time_min, s.straight_time_max, s.straight_radius_min, s.straight_radius_max )
}

function MissileControlledDrift( timeElapsed, timeStep, windiness, intensity, pathTimeMin, pathTimeMax, pathRadiusMin, pathRadiusMax )
{
	// Start with random drift.
	local vel = MissileRandomDrift( timeElapsed, timeStep, windiness, intensity )

	// Straighten our velocity back along our original path if we're below pathTimeMax.
	// Path time is how long it tries to stay on a straight path.
	// Path radius is how far it can get from its straight path.
	if ( timeElapsed < pathTimeMax )
	{
		local org = self.GetOrigin()
		local alongPathLen = self.s.startDir.Dot( org - self.s.startPos )
		local alongPathPos = self.s.startPos + self.s.startDir * alongPathLen
		local offPathOffset = org - alongPathPos
		float pathDist = Length( offPathOffset )

		float speed = Length( vel )

		local lerp = 1
		if ( timeElapsed > pathTimeMin )
			lerp = 1.0 - (timeElapsed - pathTimeMin) / (pathTimeMax - pathTimeMin)

		local pathRadius = pathRadiusMax + (pathRadiusMin - pathRadiusMax) * lerp

		// This circle shows the radius the missile is allowed to be in.
		//if ( IsServer() )
		//	DebugDrawCircle( alongPathPos, VectorToAngles( AnglesToUp( VectorToAngles( self.s.startDir ) ) ), pathRadius, <255, 255, 255>, true, 0.0 )

		local backToPathVel = offPathOffset * -1
		// Cap backToPathVel at speed
		if ( pathDist > pathRadius )
			backToPathVel *= speed / pathDist
		else
			backToPathVel *= speed / pathRadius

		if ( pathDist < pathRadius )
		{
			backToPathVel += self.s.startDir * (speed * (1.0 - pathDist / pathRadius))
		}

		//DebugDrawLine( org, org + vel * 0.1, <255, 255, 255>, true, 0 )
		//DebugDrawLine( org, org + backToPathVel * intensity * lerp * 0.1, <128,255,128>, true, 0 )

		vel += backToPathVel * (intensity * timeStep)
		vel = Normalize( vel )
		vel *= speed
	}

	return vel
}
*/

#if SERVER
void function StartClusterExplosionsThread( entity owner, vector origin, PopcornInfo popcornInfo, string customFxTable = "" )
{
	if ( !IsValid( owner ) )
		return

	owner.EndSignal( "OnDestroy" )

	string weaponName = popcornInfo.weaponName
	float innerRadius
	float outerRadius
	int explosionDamage
	int explosionDamageHeavyArmor

	innerRadius = GetWeaponInfoFileKeyField_GlobalFloat( weaponName, "explosion_inner_radius" )
	outerRadius = GetWeaponInfoFileKeyField_GlobalFloat( weaponName, "explosionradius" )
	if ( owner.IsPlayer() )
	{
		explosionDamage = GetWeaponInfoFileKeyField_GlobalInt( weaponName, "explosion_damage" )
		explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_GlobalInt( weaponName, "explosion_damage_heavy_armor" )
	}
	else
	{
		explosionDamage = GetWeaponInfoFileKeyField_GlobalInt( weaponName, "npc_explosion_damage" )
		explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_GlobalInt( weaponName, "npc_explosion_damage_heavy_armor" )
	}

	float explosionDelay = popcornInfo.initalDelay

	vector rotateFX        = <90, 0, 0>
	entity placementHelper = CreateScriptMover( "", <0,0,0> )
	placementHelper.RemoveFromAllRealms()
	placementHelper.AddToOtherEntitysRealms( owner )
	placementHelper.SetOrigin( origin )
	placementHelper.SetAngles( VectorToAngles( popcornInfo.normal ) )
	SetTeam( placementHelper, owner.GetTeam() )

	int particleSystemIndex = GetParticleSystemIndex( CLUSTER_BASE_FX )
	int attachId            = placementHelper.LookupAttachment( "REF" )
	entity fx

	if ( popcornInfo.hasBase )
	{
		fx = StartParticleEffectOnEntity_ReturnEntity( placementHelper, particleSystemIndex, FX_PATTACH_POINT_FOLLOW, attachId )
		EmitSoundOnEntity( placementHelper, "Explo_ThermiteGrenade_Impact_3P" ) // TODO: wants a custom sound
	}

	OnThreadEnd(
		function() : ( fx, placementHelper )
		{
			if ( IsValid( fx ) )
				EffectStop( fx )
			placementHelper.Destroy()
		}
	)

	if ( explosionDelay > 0.0 )
		wait explosionDelay

	waitthread ClusterRocketBursts( origin, explosionDamage, explosionDamageHeavyArmor, innerRadius, outerRadius, owner, popcornInfo, customFxTable )
}

//------------------------------------------------------------
// ClusterRocketBurst() - does a "popcorn airburst" explosion effect over time around the origin. Total distance is based on popRangeBase
// - returns the entity in case you want to parent it
//------------------------------------------------------------
void function ClusterRocketBursts( vector origin, int damage, int damageHeavyArmor, float innerRadius, float outerRadius, entity owner, PopcornInfo popcornInfo, string customFxTable = "" )
{
	owner.EndSignal( "OnDestroy" )

	// this ent remembers the weapon mods
	entity clusterExplosionEnt = CreateEntity( "info_target" )
	DispatchSpawn( clusterExplosionEnt )

	if ( popcornInfo.weaponMods.len() > 0 )
		clusterExplosionEnt.s.weaponMods <- popcornInfo.weaponMods

	if ( IsValid( owner ) )
	{
		clusterExplosionEnt.RemoveFromAllRealms()
		clusterExplosionEnt.AddToOtherEntitysRealms( owner )
	}

	clusterExplosionEnt.SetOwner( owner )
	clusterExplosionEnt.SetOrigin( origin )

	AI_CreateDangerousArea_Static( clusterExplosionEnt, null, outerRadius, TEAM_INVALID, true, true, origin )

	OnThreadEnd(
		function() : ( clusterExplosionEnt )
		{
			clusterExplosionEnt.Destroy()
		}
	)

	// No Damage - Only Force
	// Push players
	// Test LOS before pushing
	int flags = 11
	// create a blast that knocks pilots out of the way
	//CreatePhysExplosion( origin, outerRadius, PHYS_EXPLOSION_LARGE, flags )

	int count = popcornInfo.groupSize
	for ( int index = 0; index < count; index++ )
	{
		thread ClusterRocketBurst( clusterExplosionEnt, origin, damage, damageHeavyArmor, innerRadius, outerRadius, owner, popcornInfo, customFxTable )
		WaitFrame()
	}

	wait CLUSTER_ROCKET_DURATION
}

void function ClusterRocketBurst( entity clusterExplosionEnt, vector origin, damage, damageHeavyArmor, innerRadius, outerRadius, entity owner, PopcornInfo popcornInfo, string customFxTable = "" )
{
	clusterExplosionEnt.EndSignal( "OnDestroy" )
	Assert( IsValid( owner ), "ClusterRocketBurst had invalid owner" )

	// first explosion always happens where you fired
	//int eDamageSource = popcornInfo.damageSourceId
	int numBursts           = popcornInfo.count
	float popRangeBase      = popcornInfo.range
	float popRangeMin       = popcornInfo.range_min
	float popDelayBase      = popcornInfo.delay
	float popDelayRandRange = popcornInfo.offset
	float duration          = popcornInfo.duration
	int groupSize           = popcornInfo.groupSize

	int counter   = 1
	vector randVec
	float randRangeMod
	float popRange
	vector popVec
	vector popOri = origin
	float popDelay
	float colTrace

	float burstDelay = duration / (numBursts / groupSize)

	vector clusterBurstOrigin = origin + (popcornInfo.normal * 8.0)
	entity clusterBurstEnt    = CreateClusterBurst( clusterBurstOrigin )
	clusterBurstEnt.RemoveFromAllRealms()
	clusterBurstEnt.AddToOtherEntitysRealms( clusterExplosionEnt )
	entity inflictor = IsValid( popcornInfo.inflictor ) ? popcornInfo.inflictor : clusterBurstEnt

	OnThreadEnd(
		function() : ( clusterBurstEnt )
		{
			if ( IsValid( clusterBurstEnt ) )
			{
				foreach ( fx in clusterBurstEnt.e.fxArray )
				{
					if ( IsValid( fx ) )
						fx.Destroy()
				}
				clusterBurstEnt.Destroy()
			}
		}
	)

	while ( IsValid( clusterBurstEnt ) && counter <= numBursts / popcornInfo.groupSize )
	{
		randVec = RandomVecInDome( popcornInfo.normal )
		randRangeMod = RandomFloat( 1.0 )
		popRange = popRangeMin + ((popRangeBase - popRangeMin) * randRangeMod)
		popVec = randVec * popRange
		popOri = origin + popVec
		popDelay = popDelayBase + RandomFloatRange( -popDelayRandRange, popDelayRandRange )

		colTrace = TraceLineSimple( origin, popOri, null )
		if ( colTrace < 1 )
		{
			popVec = popVec * colTrace
			popOri = origin + popVec
		}

		clusterBurstEnt.SetOrigin( clusterBurstOrigin )

		vector velocity = GetVelocityForDestOverTime( clusterBurstEnt.GetOrigin(), popOri, burstDelay - popDelay )
		clusterBurstEnt.SetVelocity( velocity )

		clusterBurstOrigin = popOri

		counter++

		wait burstDelay - popDelay

		Explosion(
			clusterBurstOrigin,
			owner,
			inflictor,
			damage,
			damageHeavyArmor,
			innerRadius,
			outerRadius,
			SF_ENVEXPLOSION_NOSOUND_FOR_ALLIES,
			clusterBurstOrigin,
			damage,
			damageTypes.explosive,
			popcornInfo.damageSourceId,
			popcornInfo.burstFXTable )

		if( popcornInfo.explosionCallback != null )
			popcornInfo.explosionCallback( clusterBurstOrigin )
	}
}


entity function CreateClusterBurst( vector origin )
{
	entity prop_physics = CreateEntity( "prop_physics" )
	prop_physics.SetValueForModelKey( $"mdl/weapons/bullets/projectile_rocket.rmdl" )
	prop_physics.kv.spawnflags = 4 // 4 = SF_PHYSPROP_DEBRIS
	prop_physics.kv.fadedist = 2000
	prop_physics.kv.renderamt = 255
	prop_physics.kv.rendercolor = "255 255 255"
	prop_physics.kv.CollisionGroup = TRACE_COLLISION_GROUP_DEBRIS

	prop_physics.kv.minhealthdmg = 9999
	prop_physics.kv.nodamageforces = 1
	prop_physics.kv.inertiaScale = 1.0

	prop_physics.SetOrigin( origin )
	DispatchSpawn( prop_physics )
	prop_physics.SetModel( $"mdl/weapons/grenades/m20_f_grenade.rmdl" )

	entity fx = PlayFXOnEntity( $"P_wpn_dumbfire_burst_trail", prop_physics )
	prop_physics.e.fxArray.append( fx )

	return prop_physics
}
#endif // SERVER

vector function GetVelocityForDestOverTime( vector startPoint, vector endPoint, float duration )
{
	const GRAVITY = 750

	float vox = (endPoint.x - startPoint.x) / duration
	float voy = (endPoint.y - startPoint.y) / duration
	float voz = (endPoint.z + 0.5 * GRAVITY * duration * duration - startPoint.z) / duration

	return <vox, voy, voz>
}


vector function GetPlayerVelocityForDestOverTime( vector startPoint, vector endPoint, float duration )
{
	// Same as above but accounts for player gravity setting not being 1.0

	float gravityScale = GetGlobalSettingsFloat( DEFAULT_PILOT_SETTINGS, "gravityScale" )
	float GRAVITY      = 750 * gravityScale // adjusted for new gravity scale

	float vox = (endPoint.x - startPoint.x) / duration
	float voy = (endPoint.y - startPoint.y) / duration
	float voz = (endPoint.z + 0.5 * GRAVITY * duration * duration - startPoint.z) / duration

	return <vox, voy, voz>
}

#if CLIENT

bool function IsOwnerViewPlayerFullyADSed( entity weapon )
{
	entity owner = weapon.GetOwner()
	if ( !IsValid( owner ) )
		return false

	if ( !owner.IsPlayer() )
		return false

	if ( owner != GetLocalViewPlayer() )
		return false

	float zoomFrac = owner.GetZoomFrac()
	if ( zoomFrac < 1.0 )
		return false

	return true
}
#endif // CLIENT


void function DebugDrawMissilePath( entity missile )
{
	EndSignal( missile, "OnDestroy" )
	vector lastPos = missile.GetOrigin()
	while ( true )
	{
		WaitFrame()
		if ( !IsValid( missile ) )
			return
		//DebugDrawLine( lastPos, missile.GetOrigin(), <0, 255, 0>, true, 20.0 )
		lastPos = missile.GetOrigin()
	}
}


bool function IsPilotShotgunWeapon( string weaponName )
{
	if ( IsWeaponKeyFieldDefined( weaponName, "weaponSubClass" ) && GetWeaponInfoFileKeyField_GlobalString( weaponName, "weaponSubClass" ) == "shotgun" )
		return true

	return false
}




#if SERVER
void function PROTO_InitTrackedProjectile( entity projectile )
{
	// HACK: accessing ProjectileGetWeaponInfoFileKeyField or ProjectileGetWeaponClassName during CodeCallback_OnSpawned causes a code assert
	projectile.EndSignal( "OnDestroy" )
	WaitFrame()

	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) || !owner.IsPlayer() )
		return

	int maxDeployed = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_max_deployed )
	if ( maxDeployed != 0 )
	{
		AddToTrackedEnts( owner, projectile )

		array<entity> traps = GetScriptManagedEntArray( owner.s.activeTrapArrayId )
		array<entity> sameTypeTrapEnts
		foreach ( ent in traps )
		{
			if ( ent.ProjectileGetWeaponClassName() != projectile.ProjectileGetWeaponClassName() )
				continue

			sameTypeTrapEnts.append( ent )
		}

		int numToDestroy = sameTypeTrapEnts.len() - maxDeployed
		if ( numToDestroy > 0 )
		{
			sameTypeTrapEnts.sort( CompareCreation )
			foreach ( ent in sameTypeTrapEnts )
			{
				ent.Destroy()
				numToDestroy--

				if ( numToDestroy == 0 )
					break
			}
		}
	}
}

void function AddToTrackedEnts( entity player, entity ent )
{
	AddToScriptManagedEntArray( player.s.activeTrapArrayId, ent )
}

void function PROTO_CleanupTrackedProjectiles( entity player )
{
	array<entity> traps = GetScriptManagedEntArray( player.s.activeTrapArrayId )
	foreach ( ent in traps )
	{
		ent.Destroy()
	}
}

int function CompareCreation( entity a, entity b )
{
	if ( a.GetProjectileCreationTime() > b.GetProjectileCreationTime() )
		return 1

	return -1
}

int function CompareCreationReverse( entity a, entity b )
{
	if ( a.GetProjectileCreationTime() > b.GetProjectileCreationTime() )
		return 1

	return -1
}
#endif //SERVER


void function GiveEMPStunStatusEffects( entity target, float duration, float fadeoutDuration = 0.5, float slowTurn = EMP_SEVERITY_SLOWTURN, float slowMove = EMP_SEVERITY_SLOWMOVE )
{
	#if SERVER
		if ( target.IsPlayer() )
		{
			foreach ( statusEffectID in target.p.empStatusEffectsToClearForPhaseShift )
			{
				StatusEffect_Stop( target, statusEffectID )
			}

			target.p.empStatusEffectsToClearForPhaseShift.clear()
		}

		int slowEffect = StatusEffect_AddTimed( target, eStatusEffect.turn_slow, slowTurn, duration, fadeoutDuration )
		int turnEffect = StatusEffect_AddTimed( target, eStatusEffect.move_slow, slowMove, duration, fadeoutDuration )

		if ( target.IsPlayer() )
		{
			target.p.empStatusEffectsToClearForPhaseShift.append( slowEffect )
			target.p.empStatusEffectsToClearForPhaseShift.append( turnEffect )
		}
	#endif
}

#if DEVELOPER
string ornull function FindEnumNameForValue( table searchTable, int searchVal )
{
	foreach ( string keyname, int value in searchTable )
	{
		if ( value == searchVal )
			return keyname
	}
	return null
}

void function DevPrintAllStatusEffectsOnEnt( entity ent )
{
	printt( "Effects:", ent )
	array<float> effects = StatusEffect_GetAllSeverity( ent )
	int length           = effects.len()
	int found            = 0
	for ( int idx = 0; idx < length; idx++ )
	{
		float severity = effects[idx]
		if ( severity <= 0.0 )
			continue
		string ornull name = FindEnumNameForValue( eStatusEffect, idx )
		Assert( name )
		expect string( name )
		printt( " eStatusEffect." + name + ": " + severity )
		found++
	}
	printt( found + " effects active.\n" )
}
#endif // #if DEVELOPER

entity function GetMeleeWeapon( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	foreach ( weaponEnt in weapons )
	{
		if ( weaponEnt.IsWeaponOffhandMelee() )
			return weaponEnt
	}

	return null
}


#if SERVER
void function RunWeaponAllowLogic( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	if ( weapon.w.disallowDeployStackCount > 0 || (IsValid( owner ) && owner.p.allWeaponsDisallowDeployStackCount > 0) )
	{
		if ( !IsValid( owner ) || owner.p.forceAllowDeployOfWeapon != weapon )
			weapon.AllowUse( false )
	}
	else
	{
		weapon.AllowUse( true )
	}
}

void function WeaponAllowLogic_OnPlayerRespawed( entity player )
{
	player.SetInventoryChangedCallbackEnabled( true )
	WeaponAllowLogic_OnPlayerInventoryChanged( player )
}

bool function WeaponAllowLogic_CheckWeaponOwner( entity weapon )
{
	entity currentOwner = weapon.GetWeaponOwner()
	if ( weapon.w.lastKnownOwner != currentOwner )
	{
		weapon.w.lastKnownOwner = currentOwner
		weapon.w.disallowDeployStackCount = 0
		return true
	}
	return false
}

void function WeaponAllowLogic_OnPlayerInventoryChanged( entity player )
{
	foreach ( weapon in GetAllPlayerWeapons( player ) )
	{
		if ( WeaponAllowLogic_CheckWeaponOwner( weapon ) )
			RunWeaponAllowLogic( weapon )
	}

	// force and update of the hud when the weapon inventory changes.
	Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponDataNoEntity" )
}

void function OnWeaponAttachmentChanged_UpdateWeaponHud( entity player, entity weapon, string modToAdd, string modToRemove )
{
	// force and update of the hud when the weapon attachment changes.
	Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponDataNoEntity" )
}

void function DisallowWeaponDeploy( entity weapon )
{
	WeaponAllowLogic_CheckWeaponOwner( weapon )
	weapon.w.disallowDeployStackCount++
	Assert( weapon.w.disallowDeployStackCount <= 99, "Potential DisallowWeaponDeploy/AllowWeaponDeploy mismatch (weapon disabled over 99 times!)" )
	if ( weapon.w.disallowDeployStackCount == 1 )
		RunWeaponAllowLogic( weapon )
}

void function AllowWeaponDeploy( entity weapon )
{
	WeaponAllowLogic_CheckWeaponOwner( weapon )
	weapon.w.disallowDeployStackCount--
	Assert( weapon.w.disallowDeployStackCount >= 0, "Called AllowWeaponDeploy on a weapon more times than DisallowWeaponDeploy was called" )
	if ( weapon.w.disallowDeployStackCount == 0 )
		RunWeaponAllowLogic( weapon )
}

void function DisallowAllWeaponDeployment( entity player )
{
	player.p.allWeaponsDisallowDeployStackCount++
	Assert( player.p.allWeaponsDisallowDeployStackCount <= 99, "Potential DisallowAllWeaponUsage/AllowAllWeaponUsageDeployment mismatch (all weapons disabled over 99 times!)" )
	if ( player.p.allWeaponsDisallowDeployStackCount == 1 )
	{
		foreach ( weapon in GetAllPlayerWeapons( player ) )
			RunWeaponAllowLogic( weapon )
	}
}

void function AllowAllWeaponUsageDeployment( entity player )
{
	player.p.allWeaponsDisallowDeployStackCount--
	Assert( player.p.allWeaponsDisallowDeployStackCount >= 0, "Called AllowAllWeaponUsageDeployment on a player more times than DisallowAllWeaponUsage was called" )
	if ( player.p.allWeaponsDisallowDeployStackCount == 0 )
	{
		foreach ( weapon in GetAllPlayerWeapons( player ) )
			RunWeaponAllowLogic( weapon )
	}
}

void function StartForceAllowSpecificWeaponDeployment( entity weapon )
{
	WeaponAllowLogic_CheckWeaponOwner( weapon )
	entity owner = weapon.GetWeaponOwner()
	Assert( IsValid( owner ), "Tried to call StartForceAllowSpecificWeaponDeployment on a weapon with an invalid owner." )
	Assert( owner.p.forceAllowDeployOfWeapon == null, "Tried to call StartForceAllowSpecificWeaponDeployment on a player twice" )
	owner.p.forceAllowDeployOfWeapon = weapon

	RunWeaponAllowLogic( weapon )
}

void function StopForceAllowSpecificWeaponDeployment( entity weapon )
{
	WeaponAllowLogic_CheckWeaponOwner( weapon )
	entity owner = weapon.GetWeaponOwner()
	Assert( IsValid( owner ), "Tried to call StopForceAllowSpecificWeaponDeployment on a weapon with an invalid owner." )
	Assert( owner.p.forceAllowDeployOfWeapon != null, "Tried to call StopForceAllowSpecificWeaponDeployment without first calling StartForceAllowSpecificWeaponDeployment." )
	Assert( owner.p.forceAllowDeployOfWeapon == weapon, "Tried to call StopForceAllowSpecificWeaponDeployment on a weapon that was not the current force-allow-weapon." )
	owner.p.forceAllowDeployOfWeapon = null

	RunWeaponAllowLogic( weapon )
}

array<entity> function GetAllPlayerWeapons( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	weapons.extend( player.GetOffhandWeapons() )

	return weapons
}

void function EMP_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	Electricity_DamagedPlayerOrNPC( ent, damageInfo )
}


bool function Electricity_ShouldDamageStunNPC( entity ent, var damageInfo )
{
	if ( (DamageInfo_GetCustomDamageType( damageInfo ) & DF_STUN_AI) == 0 )
		return false

	if ( !IsAlive( ent ) )
		return false

	if ( ent.ContextAction_IsActive() )
		return false

	if ( ent.GetParent() != null )
		return false

	//don't stun idling enemies in breachable rooms
	if ( ent.IsNPC() && ent.GetNoTarget() )
		return false

	return true
}

bool function Electricity_ShouldStunNPCAndAddImmunity( entity npc, float immunityTime = ELECTRICITY_NPC_STUN_IMMUNITY_DURATION )
{
	if ( IsValid( npc ) )
	{
		if( file.npcsWithStunImmunity.contains( npc ) )
		{
			return true
		}
		else
		{
			thread GiveNPCImmunityForDuration_Thread( npc, immunityTime )
		}
	}

	return false
}

void function GiveNPCImmunityForDuration_Thread( entity npc, float immunityTime = ELECTRICITY_NPC_STUN_IMMUNITY_DURATION )
{
	file.npcsWithStunImmunity.push( npc )

	npc.EndSignal( "OnDeath" )

	OnThreadEnd( void function() : ( npc ) {
		file.npcsWithStunImmunity.fastremovebyvalue( npc )
	} )

	wait immunityTime
}

void function Electricity_DamagedPlayerOrNPC( entity ent, var damageInfo, float empDurationOverride = -1.0, asset humanFx = FX_EMP_BODY_HUMAN, asset titanFx = FX_EMP_BODY_TITAN, float slowTurn = EMP_SEVERITY_SLOWTURN, float slowMove = EMP_SEVERITY_SLOWMOVE )
{
	if ( !IsValid( ent ) )
		return

	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_DOOMED_HEALTH_LOSS ) )
		return

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	// Do electrical effect on this ent that everyone can see if they are a titan
	string tag = ""
	asset effect

	if ( ent.IsTitan() )
	{
		tag = "exp_torso_front"
		effect = titanFx
	}
	else if ( IsStalker( ent ) || IsSpectre( ent ) || IsProwler( ent ) || IsSpider( ent ) || IsSuperSpectre( ent ) )
	{
                      
                                                      
        
		{
			tag = "CHESTFOCUS"
			effect = humanFx

			thread StunWhenInterruptable( ent, damageInfo )
		}
	}
	else if ( IsNessie( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx

		thread StunWhenInterruptable( ent, damageInfo )
	}
	else if ( IsGrunt( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx

		thread StunWhenInterruptable( ent, damageInfo )
	}
	else if ( IsTrainingDummie( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx
	}
	else if ( IsPilot( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx
	}
	else if ( IsDropship( ent ) )
	{
		tag = "ORIGIN"
		effect = humanFx
	}
	else if ( IsAirDrone( ent ) )
	{
		if ( GetDroneType( ent ) == "drone_type_marvin" )
			return

		if ( GetDroneType( ent ) == "drone_type_flame" )
			return

		tag = "HEADSHOT"
		effect = humanFx
		thread NpcEmpRebootPrototype( ent, damageInfo, humanFx, titanFx )
	}
	else if ( IsGunship( ent ) )
	{
		tag = "ORIGIN"
		effect = titanFx
		thread NpcEmpRebootPrototype( ent, damageInfo, humanFx, titanFx )
	}
                     
	else if ( EntIsHoverVehicle( ent ) )
	{
		tag = "driver"
		effect = titanFx
	}
      

		ent.Signal( "ArcStunned" )

	if ( tag != "" )
	{
		Assert( inflictor == DamageInfo_GetInflictor( damageInfo ) )
		Assert( !(inflictor instanceof CEnvExplosion) )
		if ( IsValid( inflictor ) )
		{
			float duration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX
			if ( inflictor instanceof CBaseGrenade )
			{
				vector entCenter   = ent.GetWorldSpaceCenter()
				float dist         = Distance( DamageInfo_GetDamagePosition( damageInfo ), entCenter )
				float damageRadius = inflictor.GetDamageRadius()
				duration = GraphCapped( dist, damageRadius * 0.5, damageRadius, EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN, EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX )
			}
			thread EMP_FX( effect, ent, tag, duration )
		}
	}

	if ( StatusEffect_HasSeverity( ent, eStatusEffect.destroyed_by_emp ) )
		DamageInfo_SetDamage( damageInfo, ent.GetHealth() )

	// Don't do arc beams to entities that are on the same team... except the owner or if the damage type is specified to ignore friendly fire protection.
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) && IsFriendlyTeam( attacker.GetTeam(), ent.GetTeam() ) && (attacker != ent) && !DamageIgnoresFriendlyFire( damageInfo ) )
		return

	if ( ent.IsPlayer() )
	{
		thread EMPWeapon_EffectsPlayer( ent, damageInfo, empDurationOverride )
	}
	else if ( ent.IsTitan() )
	{
		EMPGrenade_AffectsShield( ent, damageInfo )
		GiveEMPStunStatusEffects( ent, 2.5, 1.0, slowTurn, slowMove )
		thread EMPGrenade_AffectsAccuracy( ent )
	}
	else if ( IsDropship( ent ) )
	{
		DamageInfo_ScaleDamage( damageInfo, 0 )
	}
	else if ( ent.IsMechanical() )
	{
		GiveEMPStunStatusEffects( ent, 2.5, 1.0, slowTurn, slowMove )
		int damageSource  = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		float damageScale = 2.05
		if ( damageSource == eDamageSourceId.mp_ability_crypto_drone_emp )
		{
			float damage = min( DamageInfo_GetDamage( damageInfo ) * damageScale, ent.GetShieldHealth() )
			DamageInfo_SetDamage( damageInfo, damage )
		}
		else
			DamageInfo_ScaleDamage( damageInfo, damageScale )
	}
	else if ( ent.IsHuman() )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.99 )
	}
	else if ( ent.IsNPC() && IsTrainingDummie( ent ) )
	{
		GiveEMPStunStatusEffects( ent, 2.5, 1.0, slowTurn, slowMove )
	}

	if ( inflictor instanceof CBaseGrenade )
	{
		if ( !ent.IsPlayer() || ent.IsTitan() ) //Beam should hit cloaked targets, when cloak is updated make IsCloaked() function.
			EMPGrenade_ArcBeam( DamageInfo_GetDamagePosition( damageInfo ), ent )
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HACK: might make sense to move this to code
void function NpcEmpRebootPrototype( entity npc, var damageInfo, asset humanFx, asset titanFx )
{
	if ( !IsValid( npc ) )
		return

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	if ( !("rebooting" in npc.s) )
		npc.s.rebooting <- null

	if ( npc.s.rebooting ) // npc already knocked down and in rebooting process
		return

	float rebootTime
	vector groundPos
	vector origin    = npc.GetOrigin()
	string classname = npc.GetClassName()
	string soundPowerDown
	string soundPowerUp

	//------------------------------------------------------
	// Custom stuff depending on AI type
	//------------------------------------------------------
	switch ( classname )
	{
		case "npc_drone":
			soundPowerDown = "Drone_Power_Down"
			soundPowerUp = "Drone_Power_On"
			rebootTime = DRONE_REBOOT_TIME
			break

		case "npc_gunship":
			soundPowerDown = "Gunship_Power_Down"
			soundPowerUp = "Gunship_Power_On"
			rebootTime = GUNSHIP_REBOOT_TIME
			break

		default:
			Assert( false, "Unhandled npc type: " + classname )
	}

	//------------------------------------------------------
	// NPC stunned and is rebooting
	//------------------------------------------------------
	npc.Signal( "OnStunned" )
	npc.s.rebooting = true


	//TODO: make drone/gunship slowly drift to the ground while rebooting
	/*
	groundPos = OriginToGround( origin )
	groundPos += <0,0,32>


	//DebugDrawLine(origin, groundPos, <255, 0, 0>, true, 15 )

	//thread AssaultOrigin( drone, groundPos, 16 )
	//thread PlayAnim( drone, "idle" )
	*/


	thread EmpRebootFxPrototype( npc, humanFx, titanFx )
	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( true )
	npc.EnableNPCFlag( NPC_DISABLE_SENSING )    // don't do traces to look for enemies or players

	if ( IsAttackDrone( npc ) )
		npc.SetAttackMode( false )

	EmitSoundOnEntity( npc, soundPowerDown )

	wait rebootTime

	EmitSoundOnEntity( npc, soundPowerUp )
	npc.DisableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( false )
	npc.DisableNPCFlag( NPC_DISABLE_SENSING )    // don't do traces to look for enemies or players

	if ( IsAttackDrone( npc ) )
		npc.SetAttackMode( true )

	npc.s.rebooting = false
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HACK: might make sense to move this to code
void function EmpRebootFxPrototype( entity npc, asset humanFx, asset titanFx )
{
	if ( !IsValid( npc ) )
		return

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	string classname = npc.GetClassName()
	vector origin
	float delayDuration
	entity fxHandle
	asset fxEMPdamage
	string fxTag
	float rebootTime
	string soundEMPdamage

	//------------------------------------------------------
	// Custom stuff depending on AI type
	//------------------------------------------------------
	switch ( classname )
	{
		case "npc_drone":
			if ( GetDroneType( npc ) == "drone_type_marvin" )
				return
			if ( GetDroneType( npc ) == "drone_type_flame" )
				return
			fxEMPdamage = humanFx
			fxTag = "HEADSHOT"
			rebootTime = DRONE_REBOOT_TIME
			soundEMPdamage = "Titan_Blue_Electricity_Cloud"
			break

		case "npc_gunship":
			fxEMPdamage = titanFx
			fxTag = "ORIGIN"
			rebootTime = GUNSHIP_REBOOT_TIME
			soundEMPdamage = "Titan_Blue_Electricity_Cloud"
			break

		default:
			Assert( false, "Unhandled npc type: " + classname )
	}

	//------------------------------------------------------
	// Play Fx/Sound till reboot finishes
	//------------------------------------------------------
	fxHandle = ClientStylePlayFXOnEntity( fxEMPdamage, npc, fxTag, rebootTime )
	EmitSoundOnEntity( npc, soundEMPdamage )

	while ( npc.s.rebooting == true )
	{
		delayDuration = RandomFloatRange( 0.4, 1.2 )
		origin = npc.GetOrigin()


		EmitSoundAtPosition( npc.GetTeam(), origin, SOUND_EMP_REBOOT_SPARKS, npc )
		PlayFX( FX_EMP_REBOOT_SPARKS, origin )
		PlayFX( FX_EMP_REBOOT_SPARKS, origin )

		OnThreadEnd(
			function() : ( fxHandle, npc, soundEMPdamage )
			{
				if ( IsValid( fxHandle ) )
					fxHandle.Fire( "StopPlayEndCap" )
				if ( IsValid( npc ) )
					StopSoundOnEntity( npc, soundEMPdamage )
			}
		)

		wait (delayDuration)
	}
}

void function EMP_FX( asset effect, entity ent, string tag, float duration, int visFlagOverride = -1 )
{
	if ( !IsAlive( ent ) )
		return

	ent.Signal( "EMP_FX" )
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "StartPhaseShift" )
	ent.EndSignal( "EMP_FX" )

	bool isPlayer = ent.IsPlayer()

	int fxId     = GetParticleSystemIndex( effect )
	int attachId = ent.LookupAttachment( tag )

	entity fxHandle
	if ( attachId != 0 )
	{
		fxHandle = StartParticleEffectOnEntity_ReturnEntity( ent, fxId, FX_PATTACH_POINT_FOLLOW, attachId )
		fxHandle.kv.VisibilityFlags = visFlagOverride == -1 ? ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY : visFlagOverride
		fxHandle.SetOwner( ent )
	}

	OnThreadEnd(
		function() : ( fxHandle, ent )
		{
			if ( IsValid( fxHandle ) )
			{
				EffectStop( fxHandle )
			}

			if ( IsValid( ent ) )
				StopSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )
		}
	)

	if ( !isPlayer )
	{
		EmitSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )

                     
		if ( EntIsHoverVehicle( ent ) )
			ent.HoverVehicle_StunBegin()
      

		wait duration
	}
	else
	{
		EmitSoundOnEntityExceptToPlayer( ent, ent, "Titan_Blue_Electricity_Cloud" )

		var endTime        = Time() + duration
		bool effectsActive = true
		while ( endTime > Time() )
		{
			if ( ent.IsPhaseShifted() )
			{
				if ( effectsActive )
				{
					effectsActive = false
					if ( IsValid( fxHandle ) )
						EffectSleep( fxHandle )

					if ( IsValid( ent ) )
						StopSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )
				}
			}
			else if ( effectsActive == false )
			{
				EffectWake( fxHandle )
				EmitSoundOnEntityExceptToPlayer( ent, ent, "Titan_Blue_Electricity_Cloud" )
				effectsActive = true
			}

			WaitFrame()
		}
	}
}

void function EMPGrenade_AffectsShield( entity titan, var damageInfo )
{
}

void function EMPGrenade_AffectsAccuracy( entity npcTitan )
{
	npcTitan.EndSignal( "OnDestroy" )

	npcTitan.kv.AccuracyMultiplier = 0.5
	wait EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX
	npcTitan.kv.AccuracyMultiplier = 1.0
}

bool function ShouldApplySlow( entity ent, var damageInfo )
{
	// ARC STARS: only slow player on explode, not when getting stuck
	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_EXPLOSION ) )
		return true

	if ( IsABaseGrenade( ent ) )
		return false

	return true
}

void function EMPWeapon_EffectsPlayer( entity player, var damageInfo, float durationOverride = -1.0 )
{
	player.Signal( "OnEMPPilotHit" )
	player.EndSignal( "OnEMPPilotHit" )

	if ( player.IsPhaseShifted() )
		return

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	float strength
	float duration
	float fadeoutDuration

	if ( durationOverride >= 0.0 )
	{
		strength 		= EMP_GRENADE_PILOT_SCREEN_EFFECTS_MAX
		duration 		= durationOverride
		fadeoutDuration = min( ( duration * 0.5 ), 1.0 )
	}
	else
	{
		float dist         = Distance( DamageInfo_GetDamagePosition( damageInfo ), player.GetWorldSpaceCenter() )
		float damageRadius = 128
		if ( inflictor instanceof CBaseGrenade )
			damageRadius = inflictor.GetDamageRadius()
		float frac     	= GraphCapped( dist, damageRadius * 0.5, damageRadius, 1.0, 0.0 )
		strength 		= EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN + ((EMP_GRENADE_PILOT_SCREEN_EFFECTS_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN) * frac)
		fadeoutDuration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_FADE * frac
		duration        = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN + ((EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN) * frac) - fadeoutDuration
	}

	if ( player.IsCloaked( true ) )
		player.SetCloakFlicker( 0.5, duration )

	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	int damageType     = DamageInfo_GetDamageType( damageInfo )

	if ( damageSourceId == eDamageSourceId.mp_weapon_grenade_emp && damageType != DMG_BLAST )
	{
		//No move slow if this is a stuck arc star
		GiveEMPStunStatusEffects( player, (duration + fadeoutDuration), fadeoutDuration, 0 )
	}
	                    
	else if ( damageSourceId == eDamageSourceId.golden_horse_green )
	{
		//We handle that in hopup
	}
       
	else
	{
		GiveEMPStunStatusEffects( player, (duration + fadeoutDuration), fadeoutDuration )
	}

	StatusEffect_AddTimed( player, eStatusEffect.emp, strength, duration, fadeoutDuration )
	EmitSoundOnEntityOnlyToPlayer( player, player, "Arcstar_visualimpair" )
}

void function EMPGrenade_ArcBeam( vector grenadePos, entity ent )
{
	if ( !ent.IsPlayer() && !ent.IsNPC() )
		return

	Assert( IsValid( ent ) )
	float lifeDuration = 0.5

	// Control point sets the end position of the effect
	entity cpEnd = CreateEntity( "info_placement_helper" )
	SetTargetName( cpEnd, UniqueString( "emp_grenade_beam_cpEnd" ) )
	cpEnd.SetOrigin( grenadePos )
	DispatchSpawn( cpEnd )

	entity zapBeam = CreateEntity( "info_particle_system" )
	zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
	zapBeam.SetValueForEffectNameKey( EMP_GRENADE_BEAM_EFFECT )
	zapBeam.kv.start_active = 0
	zapBeam.SetOrigin( ent.GetWorldSpaceCenter() )
	if ( !ent.IsMarkedForDeletion() ) // TODO: This is a hack for shipping. Should not be parenting to deleted entities
	{
		zapBeam.SetParent( ent, "", true, 0.0 )
	}

	DispatchSpawn( zapBeam )

	zapBeam.Fire( "Start" )
	zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
	zapBeam.Kill_Deprecated_UseDestroyInstead( lifeDuration )
	cpEnd.Kill_Deprecated_UseDestroyInstead( lifeDuration )
}


array<string> function GetAmmoPoolTypesUsedByPlayer( entity player )
{
	array<string> results
	foreach( entity weapon in player.GetMainWeapons() )
	{
		if ( IsValid( weapon ) && (weapon.GetActiveAmmoSource() == AMMOSOURCE_POOL) )
		{
			string ammoType = GetWeaponAmmoTypeFromWeaponEnt( weapon )
			if ( !results.contains( ammoType ) )
				results.append( ammoType )
		}
	}

	return results
}

void function OnPlayerConnectedOrReconnected( entity player )
{
	Warning( "UpdateLaserSightColor not available in S3\n" )
}

void function OnPlayerKilled_StoreWeaponData( entity player, entity attacker, var damageInfo )
{
	StoreOffhandData( player )

	bool resetPlayerInventoryOnRespawn = Survival_ShouldResetInventoryOnRespawn( player )
	if ( resetPlayerInventoryOnRespawn )
		return

	SavePlayerWeaponData( player )
}

void function StoreOffhandData( entity player, bool waitEndFrame = true, array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_RIGHT ] )
{
	thread StoreOffhandDataThread( player, waitEndFrame, offhandIndices )
}

void function StoreOffhandDataThread( entity player, bool waitEndFrame, array<int> offhandIndices )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )

	if ( waitEndFrame )
		WaitEndFrame() // Need to WaitEndFrame so clip counts can be updated if player is dying the same frame

	// Reset all values for full cooldown
	player.p.lastSuitPower = 0.0

	foreach ( index in offhandIndices )
	{
		player.p.lastPilotOffhandChargeFrac[ index ] = 1.0
		player.p.lastPilotClipFrac[ index ] = 1.0

		player.p.lastTitanClipFrac[ index ] = 1.0
	}

	if ( player.IsTitan() )
		return

	foreach ( index in offhandIndices )
	{
		entity weapon = player.GetOffhandWeapon( index )
		if ( !IsValid( weapon ) )
			continue

		string weaponClassName = weapon.GetWeaponClassName()

		switch ( weapon.GetWeaponSettingEnum( eWeaponVar.cooldown_type, eWeaponCooldownType ) )
		{
			case eWeaponCooldownType.grapple:
				player.p.lastSuitPower = player.GetSuitGrapplePower()
				break

			case eWeaponCooldownType.ammo:
			case eWeaponCooldownType.ammo_instant:
			case eWeaponCooldownType.ammo_deployed:
			case eWeaponCooldownType.ammo_timed:

				if ( player.IsTitan() )
				{
					if ( !weapon.IsWeaponRegenDraining() && weapon.GetWeaponPrimaryClipCountMax() > 0 )
						player.p.lastTitanClipFrac[ index ] = weapon.GetWeaponPrimaryClipCount() / float( weapon.GetWeaponPrimaryClipCountMax() )
					else
						player.p.lastTitanClipFrac[ index ] = 0.0
				}
				else
				{
					if ( !weapon.IsWeaponRegenDraining() && weapon.GetWeaponPrimaryClipCountMax() > 0 )
						player.p.lastPilotClipFrac[ index ] = weapon.GetWeaponPrimaryClipCount() / float( weapon.GetWeaponPrimaryClipCountMax() )
					else
						player.p.lastPilotClipFrac[ index ] = 0.0
				}
				break

			case eWeaponCooldownType.chargeFrac:
				if ( player.IsTitan() )
					player.p.lastTitanOffhandChargeFrac[ index ] = weapon.GetWeaponChargeFraction()
				else
					player.p.lastPilotOffhandChargeFrac[ index ] = weapon.GetWeaponChargeFraction()
				break

			default:
				printt( weaponClassName + " needs to be updated to support cooldown_type setting" )
				break
		}
	}
}
#endif //SERVER


void function PlayerUsedOffhand( entity player, entity offhandWeapon, bool sendPINEvent = true, entity trackedProjectile = null, table pinAdditionalData = {} )
{
	#if SERVER
		array<int> offhandIndices = [ OFFHAND_TACTICAL, OFFHAND_ULTIMATE, OFFHAND_LEFT, OFFHAND_RIGHT, OFFHAND_ANTIRODEO, OFFHAND_INVENTORY, OFFHAND_EQUIPMENT ]

		foreach ( func in svGlobal.onPlayerUsedOffhandCallbacks )
		{
			func( player, offhandWeapon )
		}

		foreach ( index in offhandIndices )
		{
			entity weapon = player.GetOffhandWeapon( index )
			if ( !IsValid( weapon ) )
				continue

			if ( weapon != offhandWeapon )
				continue

			if ( player.IsTitan() )
				player.p.lastTitanOffhandUseTime[ index ] = Time()
			else
				player.p.lastPilotOffhandUseTime[ index ] = Time()
			StoreOffhandData( player, true, [index] )

			// PIN
			if ( sendPINEvent )
			{
				string weaponName = offhandWeapon.GetWeaponClassName()
				if ( index == OFFHAND_TACTICAL )
					PIN_PlayerAbility( player, weaponName, ABILITY_TYPE.TACTICAL, trackedProjectile, pinAdditionalData )
				else if ( index == OFFHAND_ULTIMATE )
					PIN_PlayerAbility( player, weaponName, ABILITY_TYPE.ULTIMATE, trackedProjectile, pinAdditionalData )
			}

			return
		}

	#endif // SERVER

	#if CLIENT
		if ( offhandWeapon == player.GetOffhandWeapon( OFFHAND_ULTIMATE ) )
		{
			if ( offhandWeapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_rate ) == 0 )
				UltimateWeaponStateSet( eUltimateState.CHARGING )
			else
				UltimateWeaponStateSet( eUltimateState.ACTIVE )
		}
		Chroma_PlayerUsedAbility( player, offhandWeapon )
	#endif //CLIENT
}


void function AddCallback_OnPlayerAddWeaponMod( void functionref( entity, entity, string ) callbackFunc )
{
	file.playerAddWeaponModCallbacks.append( callbackFunc )
}


void function AddCallback_OnPlayerRemoveWeaponMod( void functionref( entity, entity, string ) callbackFunc )
{
	file.playerRemoveWeaponModCallbacks.append( callbackFunc )
}


void function CodeCallback_OnPlayerAddedWeaponMod( entity player, entity weapon, string mod )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	foreach ( callback in file.playerAddWeaponModCallbacks )
	{
		callback( player, weapon, mod )
	}

	//printt( "weapon mod added to", weapon.GetWeaponClassName(), "-", mod )

	bool modAdded = true
	RunWeaponModChangedCallbacks( weapon, mod, modAdded )

	#if SERVER
		// local player use prediction, but spectator needs this logic to be called
		Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
	#endif
}


void function CodeCallback_OnPlayerRemovedWeaponMod( entity player, entity weapon, string mod )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	foreach ( callback in file.playerRemoveWeaponModCallbacks )
	{
		callback( player, weapon, mod )
	}

	//printt( "weapon mod removed from", weapon.GetWeaponClassName(), "-", mod )

	bool modAdded = false
	RunWeaponModChangedCallbacks( weapon, mod, modAdded )

	#if SERVER
		// local player use prediction, but spectator needs this logic to be called
		Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
	#endif
}

// modAdded: true= was added; false = was removed
void function RunWeaponModChangedCallbacks( entity weapon, string mod, bool modAdded )
{
	string className = weapon.GetWeaponClassName()
	if ( !(className in file.weaponModChangedCallbacks) )
		return

	foreach ( callbackFunc in file.weaponModChangedCallbacks[className] )
		callbackFunc( weapon, mod, modAdded )
}

#if SERVER
bool function WeaponHasCosmetics( entity weapon )
{
	if ( weapon.GetSkin() != 0 )
		return true

	asset modelWithMods    = GetWeaponInfoFileKeyFieldAsset_WithMods_Global( weapon.GetWeaponClassName(), weapon.GetMods(), "playermodel" )
	asset modelWithoutMods = GetWeaponInfoFileKeyFieldAsset_Global( weapon.GetWeaponClassName(), "playermodel" )

	return modelWithMods != modelWithoutMods
}


void function Thermite_DamagePlayerOrNPCSounds( entity ent )
{
	if ( ent.IsTitan() )
	{
		if ( ent.IsPlayer() )
		{
			EmitSoundOnEntityOnlyToPlayer( ent, ent, "titan_thermiteburn_3p_vs_1p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "titan_thermiteburn_1p_vs_3p" )
		}
		else
		{
			EmitSoundOnEntity( ent, "titan_thermiteburn_1p_vs_3p" )
		}
	}
	else
	{
		if ( ent.IsPlayer() )
		{
			EmitSoundOnEntityOnlyToPlayer( ent, ent, "flesh_thermiteburn_3p_vs_1p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "flesh_thermiteburn_1p_vs_3p" )
		}
		else
		{
			EmitSoundOnEntity( ent, "flesh_thermiteburn_1p_vs_3p" )
		}
	}
}

void function RemoveThreatScopeColorStatusEffect( entity player )
{
	for ( int i = file.colorSwapStatusEffects.len() - 1; i >= 0; i-- )
	{
		entity owner = file.colorSwapStatusEffects[i].weaponOwner
		if ( !IsValid( owner ) )
		{
			file.colorSwapStatusEffects.remove( i )
			continue
		}

		if ( owner == player )
		{
			StatusEffect_Stop( player, file.colorSwapStatusEffects[i].statusEffectId )
			file.colorSwapStatusEffects.remove( i )
		}
	}
}

void function AddThreatScopeColorStatusEffect( entity player )
{
	ColorSwapStruct info
	info.weaponOwner = player
	info.statusEffectId = StatusEffect_AddTimed( player, eStatusEffect.cockpitColor, COCKPIT_COLOR_THREAT, 100000, 0 )
	file.colorSwapStatusEffects.append( info )
}

vector function LimitVelocityHorizontal( vector vel, float speed )
{
	vector horzVel = <vel.x, vel.y, 0>
	if ( Length( horzVel ) <= speed )
		return vel

	horzVel = Normalize( horzVel )
	horzVel *= speed
	vel.x = horzVel.x
	vel.y = horzVel.y
	return vel
}

entity function CreateDamageInflictorHelper( float lifetime )
{
	entity inflictor = CreateEntity( "info_target" )
	DispatchSpawn( inflictor )
	inflictor.e.onlyDamageEntitiesOnce = true
	if ( lifetime > 0.0 )
		thread DelayedDestroyDamageInflictorHelper( inflictor, lifetime )
	return inflictor
}

entity function CreateOncePerTickDamageInflictorHelper( float lifetime )
{
	entity inflictor = CreateEntity( "info_target" )
	DispatchSpawn( inflictor )
	inflictor.e.onlyDamageEntitiesOncePerTick = true
	if ( lifetime > 0.0 )
		thread DelayedDestroyDamageInflictorHelper( inflictor, lifetime )
	return inflictor
}

void function DelayedDestroyDamageInflictorHelper( entity inflictor, float lifetime )
{
	inflictor.EndSignal( "OnDestroy" )
	wait lifetime
	inflictor.Destroy()
}


void function GiveMatchingAkimboWeapon( entity weapon, array<string> mods = [], float startDelay = 0.0 )
{
	if ( startDelay > 0 )
		wait startDelay

	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()
	if ( !IsAlive( player ) )
		return

	string akimboClassName = weapon.GetWeaponClassName()

	array<entity> mainWeapons = player.GetMainWeapons()

	if ( weapon.IsAkimboAvailable() )
		return

	/*int foundWeapons          = 0
	foreach ( w in mainWeapons )
		if ( w.GetWeaponClassName() == akimboClassName )
			foundWeapons++

	if ( foundWeapons > 1 )
		return  // already have an akimbo weapon*/

	int slot = weapon.GetInventoryIndex()
	if ( slot > WEAPON_INVENTORY_SLOT_PRIMARY_2 ) // HACK
		return  // only give matching akimbo weapon if this weapon isn't itself in an akimbo slot

	int dualslot = GetDualPrimarySlotForWeapon( weapon )

	entity dualWeapon = player.GiveWeapon( akimboClassName, dualslot, mods )


	//Left weapon matches right weapons skin
	int equippedSkinIndex = weapon.GetSkin()
	ItemFlavor ornull skinOrNull = GetItemFlavorByGUID( weapon.e.skinItemFlavorGUID )

	if ( skinOrNull != null )
	{
		ItemFlavor skin = expect ItemFlavor( skinOrNull )
		WeaponCosmetics_ApplyModelAndSkin ( dualWeapon, skin )
	}

	//AMMO - Match same ammo count of right hand weapon
	int count = weapon.GetWeaponPrimaryClipCount()
	if ( dualWeapon.UsesClipsForAmmo() )
	{
		dualWeapon.SetWeaponPrimaryClipCount( count )
	}

	//Check if infinite ammo is needed
	SetInfiniteAmmoForWeapon( player, dualWeapon, null )

	//if( IsValid( dualWeapon ) )
	//{
	//	dualWeapon.Raise()
	//	dualWeapon.AddMod( "akimbo_althand" )
	//}
}

void function TakeMatchingAkimboWeapon( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()
	if ( !IsAlive( player ) )
		return

	int slot = weapon.GetInventoryIndex()
	if ( slot > WEAPON_INVENTORY_SLOT_PRIMARY_2 ) // HACK
		return  // only take matching akimbo weapon if this isn't itself in an akimbo slot

	int dualslot = GetDualPrimarySlotForWeapon( weapon )

	player.TakeNormalWeaponByIndex( dualslot )
}

int function GetDualPrimarySlotForWeapon( entity weapon )
{
	int slot = weapon.GetInventoryIndex()

	int dualslot = WEAPON_INVENTORY_SLOT_DUALPRIMARY_0
	if ( slot == 1 )
		dualslot = WEAPON_INVENTORY_SLOT_DUALPRIMARY_1
	else if ( slot == 2 )
		dualslot = WEAPON_INVENTORY_SLOT_DUALPRIMARY_2

	return dualslot
}

void function AddWeaponModChangedCallback( string weaponClassName, void functionref( entity, string, bool ) callbackFunc )
{
	if ( !(weaponClassName in file.weaponModChangedCallbacks) )
		file.weaponModChangedCallbacks[weaponClassName] <- []

	file.weaponModChangedCallbacks[weaponClassName].append( callbackFunc )
}


                         
                                                                
                                                                                        
 
                                             
                                                                                                                                              
        

                                
                                                                      
                                                                                                        
                                                                                                      
                                                                                                               
                                                                                                                                     
                                                                                                                         
                                                                                                               

                                         
                                                                                       

                                                                            
 
                                   

const string WEAPON_MOD_THERMITE_ENERGIZE = "energized"

void function OnProjectileCollision_ThermiteRounds( entity projectile, entity hitEnt )
{
	entity weapon = projectile.GetWeaponSource()
	if ( !IsValid( weapon ) || !weapon.HasMod( WEAPON_MOD_THERMITE_ENERGIZE ) || (!hitEnt.IsPlayer() && !hitEnt.IsNPC()) || !IsAlive( hitEnt ) )
		return

	BurnDamageSettings burnSettings
	burnSettings.damageSourceID = eDamageSourceId.mp_weapon_dragon_lmg_thermite
	burnSettings.burnDamage = expect int( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_damage" ) )
	burnSettings.burnTime = expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_time" ) )
	burnSettings.burnTickRate = expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_tick_rate" ) )
	burnSettings.soundBurnDamageTick_1P = expect string( projectile.ProjectileGetWeaponInfoFileKeyField( "sound_burn_damage_tick_1p" ) )
	burnSettings.burnStackDebounce = expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_stack_debounce" ) )
	burnSettings.burnStacksMax = expect int( projectile.ProjectileGetWeaponInfoFileKeyField( "burn_stacks_max" ) )

	entity owner     = projectile.GetOwner()
	entity inflictor = CreateOncePerTickDamageInflictorHelper( burnSettings.burnDuration )

	TryApplyingOrRefreshingBurnDamage( hitEnt, owner, inflictor, burnSettings )
}

bool function EntityCanBurnOverTime( entity ent )
{
	if ( !IsAlive( ent ) )
		return false

	if ( ent.IsPhaseShifted() )
		return false

	return ent.e.canBurn
}

void function TryApplyingBurnDamage( entity ent, entity owner, entity inflictor, BurnDamageSettings burnSettings )
{
	//Fix for R5DEV-487130. Burning stacks could be applied by a friendly fuse to a trident, which would damage the trident, but not the player, and not destroy the trident, but lowr its health to 0 causing bugs related to VFX & damage behavior
	if( EntIsHoverVehicle( ent ) && IsValid( inflictor ) && IsFriendlyTeam( inflictor.GetTeam(), GetEffectiveTeamNumForVehicle( ent ) ))
	{
		return
	}

	if ( ent.IsPlayerDecoy() )
	{
		// dklein: changed this to behave identically to player to support new decoys
		AddEntityBurnDamageStack( ent, owner, inflictor, burnSettings )
	}
	else if ( EntityCanAcceptNewBurnDamageStack( ent, burnSettings ) )
	{
		AddEntityBurnDamageStack( ent, owner, inflictor, burnSettings )
	}
}


void function TryApplyingOrRefreshingBurnDamage( entity ent, entity owner, entity inflictor, BurnDamageSettings burnSettings )
{
	if ( ent.IsPlayerDecoy() )
	{
		// dklein: changed this to behave identically to player to support new decoys
		AddOrRefreshEntityBurnDamageStack( ent, owner, inflictor, burnSettings )
	}
	else if ( EntityCanAcceptNewOrRefreshBurnDamageStack( ent, burnSettings ) )
	{
		AddOrRefreshEntityBurnDamageStack( ent, owner, inflictor, burnSettings )
	}
}

bool function EntityCanAcceptNewBurnDamageStack( entity ent, BurnDamageSettings burnSettings )
{
	return !EntityHasMaxBurnDamageStacks( ent, burnSettings ) && EntityCanAcceptNewOrRefreshBurnDamageStack( ent, burnSettings )
}

bool function EntityCanAcceptNewOrRefreshBurnDamageStack( entity ent, BurnDamageSettings burnSettings )
{
	if ( !EntityCanBurnOverTime( ent ) )
		return false

	// don't add another stack before it's time
	foreach ( stack in GetEntityBurnDamageStacks( ent ) )
		if ( (Time() - stack.startTime) < burnSettings.burnStackDebounce )
			return false

	return true
}

void function AddEntityBurnDamageStack( entity ent, entity owner, entity inflictor, BurnDamageSettings burnSettings )
{
	BurnDamageStack stack
	stack.owner = owner
	stack.inflictor = inflictor
	stack.startTime = Time()
	stack.endTime = stack.startTime + burnSettings.burnTime
	stack.tickInterval = burnSettings.burnTickRate / burnSettings.burnTime
	int numIntervals = int( burnSettings.burnTime / stack.tickInterval )
	stack.damagePerTick = burnSettings.burnDamage / numIntervals
	stack.burnSettings = burnSettings

	ent.e.burnDamageStacks.append( stack )

	#if DEVELOPER && DEBUG_BURN_DAMAGE
		printt( "tickInterval:", stack.tickInterval )
		printt( "numIntervals:", numIntervals )
		printt( "damagePerTick:", stack.damagePerTick )
		printt( "burn stack added, total:", GetEntityBurnDamageStackCount( ent ) )
	#endif

	if ( !EntityIsBurning( ent ) )
		thread EntityBurnDamageThread( ent )
}

void function AddOrRefreshEntityBurnDamageStack( entity ent, entity owner, entity inflictor, BurnDamageSettings burnSettings )
{
	if ( !EntityHasMaxBurnDamageStacks( ent, burnSettings ) )
	{
		AddEntityBurnDamageStack( ent, owner, inflictor, burnSettings )
		return
	}

	array<BurnDamageStack> burnStacks = ent.e.burnDamageStacks
	if ( burnStacks.len() == 0 )
		return        //we must have max burn stacks = 0
	burnStacks.sort( SortEarliestBurnStack )
	ent.e.burnDamageStacks.fastremovebyvalue( burnStacks[0] )

	AddEntityBurnDamageStack( ent, owner, inflictor, burnSettings )
}

int function SortEarliestBurnStack( BurnDamageStack a, BurnDamageStack b )
{
	if ( a.endTime < b.endTime )
		return -1

	if ( b.endTime < a.endTime )
		return 1

	return 0
}

void function RemoveEntityBurnDamageStack( entity ent, BurnDamageStack stack )
{
	ent.e.burnDamageStacks.removebyvalue( stack )

	#if DEVELOPER && DEBUG_BURN_DAMAGE
		printt( "burn stack removed, num stacks is now:", GetEntityBurnDamageStackCount( ent ) )
	#endif
}

void function EntityBurnDamageThread( entity ent )
{
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	SetEntityIsBurning( ent, true )

	OnThreadEnd(
		function () : ( ent )
		{
			#if DEVELOPER && DEBUG_BURN_DAMAGE
				printt( "EntityBurnDamageThread ended" )
			#endif

			if ( IsValid( ent ) )
				SetEntityIsBurning( ent, false )
		}
	)

	while ( GetEntityBurnDamageStackCount( ent ) > 0 )
	{
		table<BurnDamageStack, void> stacksToRemove

		foreach ( int idx, BurnDamageStack stack in GetEntityBurnDamageStacks( ent ) )
		{
			int dmgThisTick = 0

			if ( Time() >= stack.endTime )
			{
				// add to remove list
				stacksToRemove[stack] <- IN_SET

				// process any remaining damage
				int remainderDmg = stack.burnSettings.burnDamage - stack.damageDealt
				if ( remainderDmg > 0 )
				{
					dmgThisTick += remainderDmg
					stack.damageDealt += remainderDmg

					#if DEVELOPER && DEBUG_BURN_DAMAGE
						printt( "applying", remainderDmg, "burn damage remainder, total damage dealt:", stack.damageDealt )
					#endif
				}
			}
			else if ( (Time() - stack.lastDamageTime) >= stack.tickInterval )
			{
				dmgThisTick += stack.damagePerTick
				stack.damageDealt += stack.damagePerTick
				stack.lastDamageTime = Time()

				#if DEVELOPER && DEBUG_BURN_DAMAGE
					printt( "applying", stack.damagePerTick, "burn damage, total damage dealt:", stack.damageDealt )
				#endif
			}

			if ( dmgThisTick > 0 )
			{
				if ( ent.IsPlayer() )
				{
					if ( stack.burnSettings.soundBurnDamageTick_1P != "" )
						EmitSoundOnEntityOnlyToPlayer( ent, ent, stack.burnSettings.soundBurnDamageTick_1P )
				}

				ApplyBurnDamageTick( ent, dmgThisTick, stack.owner, stack.inflictor, stack.burnSettings.damageSourceID )

				// TickDamageInflictorHelper ent only allows one damage event per frame
				if ( GetBugReproNum() != 42069 )
					break
			}
		}

		// process remove list
		foreach ( BurnDamageStack stack, void _ in stacksToRemove )
			RemoveEntityBurnDamageStack( ent, stack )

		WaitFrame()
	}
}

void function ApplyBurnDamageTick( entity ent, int damage, entity owner, entity inflictor, int damageSourceID )
{
#if DEVELOPER
	if ( !Dev_CommandLineHasParm( "-smoketest" ) )
	{
		printt("Take Damage in applyburndamagetick")
	}
#endif
	ent.TakeDamage( damage, owner, inflictor, { damageSourceId = damageSourceID, damageType = DMG_BURN } )
}

bool function EntityHasMaxBurnDamageStacks( entity ent, BurnDamageSettings burnSettings )
{
	return GetEntityBurnDamageStackCount( ent ) >= burnSettings.burnStacksMax
}

array<BurnDamageStack> function GetEntityBurnDamageStacks( entity ent )
{
	return ent.e.burnDamageStacks
}

int function GetEntityBurnDamageStackCount( entity ent )
{
	return ent.e.burnDamageStacks.len()
}

bool function EntityIsBurning( entity ent )
{
	return ent.e.isBurning
}

void function SetEntityIsBurning( entity ent, bool isBurning )
{
	ent.e.isBurning = isBurning

	if ( !isBurning )
		ent.e.burnDamageStacks.clear()
}


#if DEVELOPER
void function ToggleZeroingMode()
{
	if ( GetPlayerArray().len() == 0 )
		return

	entity player = GetPlayerArray()[0]

	if ( file.inZeroingMode )
	{
		RunClientCommandOnPlayer( player, "weapon_sway 1" )
		RunClientCommandOnPlayer( player, "viewDrift 1" )
		RunClientCommandOnPlayer( player, "weaponViewKick 1" )

		file.inZeroingMode = false

		printt( "LEFT ZEROING MODE" )
	}
	else
	{
		RunClientCommandOnPlayer( player, "weapon_sway 0" )
		RunClientCommandOnPlayer( player, "viewDrift 0" )
		RunClientCommandOnPlayer( player, "weaponViewKick 0" )

		file.inZeroingMode = true

		printt( "ENTERED ZEROING MODE" )
	}
}
#endif //DEVELOPER


#endif // SERVER

int function GetMaxTrackerCountForTitan( entity titan )
{
	array<entity> primaryWeapons = titan.GetMainWeapons()
	if ( primaryWeapons.len() > 0 && IsValid( primaryWeapons[0] ) )
	{
		if ( primaryWeapons[0].HasMod( "pas_lotech_helper" ) )
			return 4
	}

	return 3
}


bool function DoesModExist( entity weapon, string modName )
{
	array<string> mods = GetWeaponMods_Global( weapon.GetWeaponClassName() )
	return mods.contains( modName )
}


bool function DoesModExistFromWeaponClassName( string weaponName, string modName )
{
	array<string> mods = GetWeaponMods_Global( weaponName )
	return mods.contains( modName )
}


bool function IsModActive( entity weapon, string modName )
{
	array<string> activeMods = weapon.GetMods()
	return activeMods.contains( modName )
}


bool function IsWeaponInSingleShotMode( entity weapon )
{
	if ( weapon.GetWeaponSettingBool( eWeaponVar.attack_button_presses_melee ) )
		return false

	if ( !weapon.GetWeaponSettingBool( eWeaponVar.is_semi_auto ) )
		return false

	return weapon.GetWeaponSettingInt( eWeaponVar.burst_fire_count ) == 0
}


bool function IsWeaponInBurstMode( entity weapon )
{
	return weapon.GetWeaponSettingInt( eWeaponVar.burst_fire_count ) > 1
}


bool function IsWeaponOffhand( entity weapon )
{
	switch( weapon.GetWeaponSettingEnum( eWeaponVar.fire_mode, eWeaponFireMode ) )
	{
		case eWeaponFireMode.offhand:
		case eWeaponFireMode.offhandInstant:
		case eWeaponFireMode.offhandHybrid:
			return true
	}
	return false
}


bool function IsWeaponInAutomaticMode( entity weapon )
{
	return !weapon.GetWeaponSettingBool( eWeaponVar.is_semi_auto )
}

bool function IsMeleeWeaponNotFists( entity player )
{
	if ( !IsValid(player) )
		return false

	entity meleeWeapon = player.GetOffhandWeapon( OFFHAND_MELEE )
	bool isHeirloom = meleeWeapon.GetWeaponSettingBool( eWeaponVar.is_heirloom )
	bool isArtifact = meleeWeapon.GetWeaponSettingBool( eWeaponVar.is_artifact )

	return isHeirloom || isArtifact
}


bool function OnWeaponAttemptOffhandSwitch_Never( entity weapon )
{
	return false
}


#if CLIENT
void function ServerCallback_SetWeaponPreviewState( bool newState )
{
	#if DEVELOPER
		entity player = GetLocalClientPlayer()

		if ( newState )
		{
			printt( "Weapon Skin Preview Enabled" )
			player.ClientCommand( "bind LEFT \"WeaponPreviewPrevSkin\"" )
			player.ClientCommand( "bind RIGHT \"WeaponPreviewNextSkin\"" )
			player.ClientCommand( "bind UP \"WeaponPreviewNextCamo\"" )
			player.ClientCommand( "bind DOWN \"WeaponPreviewPrevCamo\"" )

			player.ClientCommand( "bind_held LEFT weapon_inspect" )
		}
		else
		{
			player.ClientCommand( "bind LEFT \"+ability 12\"" )
			player.ClientCommand( "bind RIGHT \"+ability 13\"" )
			player.ClientCommand( "bind UP \"+ability 10\"" )
			player.ClientCommand( "bind DOWN \"+ability 11\"" )

			SetStandardAbilityBindingsForPilot( player )
			printt( "Weapon Skin Preview Disabled" )
		}
	#endif
}
#endif

void function OnWeaponReadyToFire_ability_tactical( entity weapon )
{
	#if SERVER
		PIN_PlayerAbilityReady( weapon.GetWeaponOwner(), ABILITY_TYPE.TACTICAL )
	#endif
}


void function OnWeaponRegenEndGeneric( entity weapon )
{
	#if SERVER
		if ( !IsValid( weapon ) )
			return
		ReportOffhandWeaponRegenEnded( weapon )
	#endif
	#if CLIENT
		entity owner = weapon.GetWeaponOwner()
		if ( !IsValid( owner ) || !owner.IsPlayer() )
			return
		if ( owner.GetOffhandWeapon( OFFHAND_ULTIMATE ) == weapon )
			Chroma_UltimateReady()
	#endif
}


void function Ultimate_OnWeaponRegenBegin( entity weapon )
{
	#if CLIENT
		UltimateWeaponStateSet( eUltimateState.CHARGING )
	#endif
}

#if SERVER
void function ReportOffhandWeaponRegenEnded( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) || !owner.IsPlayer() )
		return

	if ( !weapon.IsWeaponOffhand() )
		return

	if ( !weapon.IsReadyToFire() )
		return

	if ( owner.GetOffhandWeapon( OFFHAND_TACTICAL ) == weapon )
		PIN_PlayerAbilityReady( owner, ABILITY_TYPE.TACTICAL )
	else if ( owner.GetOffhandWeapon( OFFHAND_ULTIMATE ) == weapon )
		Ultimates_OnPlayerUltIsReady( owner, weapon )
}
#endif

void function PlayDelayedShellEject( entity weapon, float time, int count = 1, bool persistent = false )
{
	AssertIsNewThread()

	weapon.EndSignal( "OnDestroy" )

	asset vmShell      = weapon.GetWeaponSettingAsset( eWeaponVar.fx_shell_eject_view )
	asset worldShell   = weapon.GetWeaponSettingAsset( eWeaponVar.fx_shell_eject_world )
	string shellAttach = weapon.GetWeaponSettingString( eWeaponVar.fx_shell_eject_attach )

	if ( shellAttach == "" )
		return

	for ( int i = 0; i < count; i++ )
	{
		wait time

		if ( !IsValid( weapon ) )
			return
		entity viewmodel = weapon.GetWeaponViewmodel()
		if ( !IsValid( viewmodel ) )
			return
		weapon.PlayWeaponEffect( vmShell, worldShell, shellAttach, persistent )
	}
}



#if SERVER
void function OnPlayerRespawed_GiveWeapons( entity player )
{
	bool resetPlayerInventoryOnRespawn = Survival_ShouldResetInventoryOnRespawn( player )
	if ( resetPlayerInventoryOnRespawn )
		return

	RestorePlayerWeaponData( player )
}
#endif //SERVER


#if SERVER
void function SavePlayerWeaponData( entity player )
{
	array<StoredWeapon> storedWeapons
	array<entity> currentWeapons = SURVIVAL_GetPrimaryWeaponsIncludingSling( player )

	bool hasBallisticUltBuff = DoesPlayerHaveAutoLoaderBuff( player )

	if( hasBallisticUltBuff && !player.p.infiniteGameModeAmmo)
		SetInfiniteAmmoForPlayer( player, false, ["crate"], true, true )

               
                                                              
                                
  
                                                      
   
                                                     
                                                                  
                                                               

                                          
   
  
       

	for ( int i = 0; i < currentWeapons.len(); i++ )
	{
		StoredWeapon weaponData
		entity currentWeapon = currentWeapons[i]

		if( hasBallisticUltBuff )
			currentWeapon.RemoveMod( "auto_loader" )

		weaponData.inventoryIndex = GetSlotForWeapon( player, currentWeapon )
		weaponData.activeWeapon   = player.GetActiveWeapon( eActiveInventorySlot.mainHand ) == currentWeapon
		weaponData.clipCount      = currentWeapon.GetWeaponPrimaryClipCount()
		weaponData.modBitfield    = expect int( currentWeapon.GetInternalModBitField() )
		weaponData.skinGUID       = currentWeapon.e.skinItemFlavorGUID
		weaponData.charmGUID      = currentWeapon.e.charmItemFlavorGUID
		if( weaponData.inventoryIndex == SLING_WEAPON_SLOT )
			weaponData.name = GetStoredPreSlingWeaponRefForPlayer( player )
		else
			weaponData.name           = currentWeapon.GetWeaponClassName()
		weaponData.lockedSet      = 0 /*GetWeaponLockedSet not in S3*/

		if ( currentWeapon.GetActiveAmmoSource() == AMMOSOURCE_POOL )
		{
			weaponData.ammoCount = currentWeapon.GetWeaponPrimaryClipCount()
			weaponData.lifetimeShots = -1
		}
		else
		{
			weaponData.ammoCount = currentWeapon.GetWeaponPrimaryClipCount()
			weaponData.lifetimeShots = currentWeapon.GetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE )
		}

		storedWeapons.append( weaponData )
	}

	if ( player in file.playerStoredWeapons )
	{
		file.playerStoredWeapons[player] = storedWeapons
	}
	else
	{
		file.playerStoredWeapons[player] <- storedWeapons
	}

	//store off player weapon equipped if it's a primary (no grenades, melee, etc)
	entity playerActiveWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( playerActiveWeapon != null && currentWeapons.contains( playerActiveWeapon ) )
	{
		if ( player in file.playerStoredLastWeapon )
			file.playerStoredLastWeapon[player] = player.GetActiveWeapon( eActiveInventorySlot.mainHand ).GetWeaponClassName()
		else
			file.playerStoredLastWeapon[player] <- player.GetActiveWeapon( eActiveInventorySlot.mainHand ).GetWeaponClassName()
	}
}
#endif //SERVER


#if SERVER
void function UTILITY_RemoveFromSavedPlayerWeaponData( entity player, entity weaponToRemove )
{
	if ( !IsValid( player ) || !(player in file.playerStoredWeapons) )
		return

	if ( !IsValid( weaponToRemove ) )
		return

	array<StoredWeapon> storedWeapons = file.playerStoredWeapons[player]
	int weaponToRemoveInventoryIndex = GetSlotForWeapon( player, weaponToRemove )
	foreach ( StoredWeapon currentStoredWeapon in storedWeapons )
	{
		if ( currentStoredWeapon.inventoryIndex != weaponToRemoveInventoryIndex )
			continue

		storedWeapons.removebyvalue( currentStoredWeapon )
		break
	}
	file.playerStoredWeapons[player] = storedWeapons

	entity playerActiveWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( playerActiveWeapon == weaponToRemove && (player in file.playerStoredLastWeapon) )
	{
		delete file.playerStoredLastWeapon[player]
	}
}
#endif // SERVER


#if SERVER
void function RestorePlayerWeaponData( entity player )
{
	if ( player in file.playerStoredWeapons && IsValid( player ) )
	{
		array<StoredWeapon> storedWeapons = file.playerStoredWeapons[player]

		for ( int i = 0; i < storedWeapons.len(); i++ )
		{
			StoredWeapon weaponData = storedWeapons[i]

			if ( weaponData.name == "" )
				continue

			if( DoesPlayerHaveWeaponSling( player ) && weaponData.inventoryIndex == SLING_WEAPON_SLOT )
			{
				GivePlayerSlingWeaponByRef( player, weaponData.name, weaponData.activeWeapon )
				continue
			}

			entity weapon
			if ( weaponData.activeWeapon )
			{
				weapon = player.GiveWeapon( weaponData.name, weaponData.inventoryIndex, [], false )
			}
			else
			{
				weapon = player.GiveWeapon_NoDeploy( weaponData.name, weaponData.inventoryIndex, [], true )
			}

			weapon.SetModBitField( weaponData.modBitfield )
			weapon.SetWeaponLockedSet( weaponData.lockedSet )

			array<string> mods = weapon.GetMods()
			foreach ( mod in mods )
			{
				OnWeaponAttachmentChanged_CheckForGoldMag( player, weapon, mod, "" )
			}

			if ( weapon.UsesClipsForAmmo() )
			{
				if ( weaponData.lifetimeShots == -1 && weapon.GetWeaponPrimaryClipCountMax() > 0 )
				{
					weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
				}
				else
				{
					weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
					weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, weaponData.lifetimeShots )
				}
			}

			ItemFlavor ornull weaponSkin = null
			if ( IsValidItemFlavorGUID( weaponData.skinGUID, eValidation.DONT_ASSERT ) )
				weaponSkin = GetItemFlavorByGUID( weaponData.skinGUID )

			ItemFlavor ornull weaponCharm = null
			if ( IsValidItemFlavorGUID( weaponData.charmGUID, eValidation.DONT_ASSERT ) )
				weaponCharm = GetItemFlavorByGUID( weaponData.charmGUID )

			if ( weaponSkin != null || weaponCharm != null )
				WeaponCosmetics_Apply( weapon, weaponSkin, weaponCharm )
		}

		delete file.playerStoredWeapons[player]
	}

	//Equip whatever weapon player had equipped, or just the first primary if was holding a grenade on death, etc
	if ( player in file.playerStoredLastWeapon && IsValid( player ) )
	{
		string lastWeapon = file.playerStoredLastWeapon[player]
		player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, lastWeapon )
		delete file.playerStoredLastWeapon[player]
	}
	else if ( player.GetMainWeapons().len() > 0 )
	{
		player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	}

	player.Signal( "RestoredPlayerWeaponData" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_RefreshInventory" )
}

const string magAttachmentName = "mag"
void function OnWeaponAttachmentChanged_CheckForGoldMag( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if ( IsValid( player ) && IsValid( weapon ) )
	{
		LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )

		if ( weaponData.ref == "" )
			return

                
                                   
          
        
		
		string modAttachmentStyle = GetAttachmentPointStyle( magAttachmentName, weaponData.ref )

		string modInstalled = GetInstalledWeaponAttachmentForPoint( weapon, magAttachmentName )
		int ammoPoolType = weapon.GetWeaponAmmoPoolType()

		// If a gold mag was just removed, then kill the auto-reload.
		if ( modToRemove != "" && SURVIVAL_Loot_IsRefValid( modToRemove ) )
		{
			LootData modToRemoveData = SURVIVAL_Loot_GetLootDataByRef( modToRemove )
			if ( modToRemoveData.attachmentStyle == modAttachmentStyle &&
			     modToRemoveData.tier >= eLootTier.LEGENDARY )
			{
				weapon.w.autoReloadStartTime = -1.0
				weapon.Signal( "GoldMagPerkEnd" )
				Remote_CallFunction_NonReplay( player, "ServerCallback_KineticLoaderReloadedThroughSlideEnd", weapon )
				weapon.Signal( END_KINETIC_LOADER )
			}
		}

		// Regardless of whether or not the gold mag was just equipped, if we have one
		// we need to fire up a new thread for the weapon as the previous entity will have
		// been replaced (destroyed) when new attachments are added/removed.
		if ( modInstalled != "" )
		{
			LootData modInstalledData = SURVIVAL_Loot_GetLootDataByRef( modInstalled )
			if ( modInstalledData.tier >= eLootTier.LEGENDARY )
			{
				if ( ammoPoolType == eAmmoPoolType.shotgun )
				{
					weapon.Signal( END_KINETIC_LOADER )
					ApplyKineticLoaderFunctionality( player, weapon )
					Remote_CallFunction_Replay( player, "ApplyKineticLoaderFunctionality", player, weapon )
				}
				else
				{
					weapon.Signal( "GoldMagPerkEnd" )
					thread GoldMagPerkThread( player, weapon, weaponData.baseMods.contains( WEAPON_LOCKEDSET_MOD_CRATE ) )
				}
			}
		}
	}
}

void function GoldMagPerkThread( entity player, entity weapon, bool isCrateWeap )
{
	player.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "GoldMagPerkEnd" )

	string modInstalled = ""
	LootData modInstalledData
	while( true )
	{
		modInstalled = GetInstalledWeaponAttachmentForPoint( weapon, magAttachmentName )
		if(  modInstalled == ""  )
			return
		modInstalledData = SURVIVAL_Loot_GetLootDataByRef( modInstalled )
		if ( modInstalledData.tier < eLootTier.LEGENDARY )
			return

		// While the weapon is stowed with the gold mag:
		// 1) If the mag is not full and there is ammo in stock, start a timer. If the mag is full or no ammo in stock, retry next frame
		// 2) At the end of the timer, fill the mag with whatever is in stock
		// 3) Go back to step 1
		while( player.GetActiveWeapon( eActiveInventorySlot.mainHand ) != weapon &&
		       !Bleedout_IsBleedingOut( player ) )
		{
			modInstalled = GetInstalledWeaponAttachmentForPoint( weapon, magAttachmentName )
			if(  modInstalled == ""  )
				return
			modInstalledData = SURVIVAL_Loot_GetLootDataByRef( modInstalled )
			if ( modInstalledData.tier < eLootTier.LEGENDARY )
				return

			int ammoPoolType = weapon.GetWeaponAmmoPoolType()
			int clipCount = weapon.GetWeaponPrimaryClipCount()
			int clipCountMax = weapon.GetWeaponPrimaryClipCountMax()
			int ammoPoolCount = isCrateWeap ? weapon.GetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE ) : player.AmmoPool_GetCount( ammoPoolType )
			bool infiniteAmmo = GetInfiniteAmmo( weapon )

			// If infinite ammo, make a full clip of ammo available in the pool to draw from for reloading
			if( infiniteAmmo )
				ammoPoolCount = clipCountMax

			if( weapon.w.autoReloadStartTime < 0 &&
				clipCount < clipCountMax &&
				ammoPoolCount > 0 )
			{
				weapon.w.autoReloadStartTime = Time()
			}
			else if( weapon.w.autoReloadStartTime >= 0 && Time() - weapon.w.autoReloadStartTime > GOLD_MAG_TIME_BEFORE_STOWED_RELOAD )
			{
				if( ammoPoolCount > 0 && clipCount < clipCountMax )
				{
					Weapon_FillClipAmmoFromStock (weapon, player)

					EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_GoldMag_Reload" )
					Remote_CallFunction_Replay( player, "ServerCallback_AutoReloadComplete", weapon )
					HandleGoldMagCarAmmoSwap(weapon)
				}
				weapon.w.autoReloadStartTime = -1.0
			}
			WaitFrame()
		}

		// weapon is not equipped, make sure the auto-reload timer isn't running (but only after the active weapon check, in case the thread was restarted)
		weapon.w.autoReloadStartTime = -1.0
		WaitFrame()
	}
}

void function Weapon_FillClipAmmoFromStock( entity weapon, entity player, int count = 0 )
{
	if( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	//Fill Main Weapon
	FillWeaponAmmo ( weapon, player, count )

              
                     
                                                               
  
                                                       
                                                                
                                                               
                              
   
                                                  
   
  
      
}


void function FillWeaponAmmo( entity weapon, entity player, int count = 0 )
{

	if( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return


	LootData weaponData 	= SURVIVAL_GetLootDataFromWeapon( weapon )
	bool isCrateWeap 		= weaponData.baseMods.contains( WEAPON_LOCKEDSET_MOD_CRATE )

	int ammoPoolType 		= weapon.GetWeaponAmmoPoolType()
	int clipCount 			= weapon.GetWeaponPrimaryClipCount()
	int clipCountMax 		= weapon.GetWeaponPrimaryClipCountMax()
	int ammoPoolCount 		= isCrateWeap ? weapon.GetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE ) : player.AmmoPool_GetCount( ammoPoolType )
	bool infiniteAmmo 		= GetInfiniteAmmo( weapon )

	// If infinite ammo, make a full clip of ammo available in the pool to draw from for reloading
	if( infiniteAmmo )
		ammoPoolCount = clipCountMax

	if( ammoPoolCount > 0 && clipCount < clipCountMax )
	{
		//Apply the new clip count. AKA Fill the gun with ammo
		int newClipCount
		if ( count == 0 )
			newClipCount = ClampInt( clipCount + ammoPoolCount, 0, clipCountMax ) //Fill the max amount the gun can hold
		else
			newClipCount = ClampInt( clipCount + count, 0, clipCountMax ) //Fill the requested count

		weapon.SetWeaponPrimaryClipCount( newClipCount )

		//Adjust invntory ammo count
		int ammoPoolMax 	= isCrateWeap ? weapon.GetWeaponPrimaryAmmoCountMax( AMMOSOURCE_STOCKPILE) : player.AmmoPool_GetCapacity()
		int newAmmoPoolSize = ClampInt( ammoPoolCount - ( newClipCount - clipCount ), 0, ammoPoolMax )

		if ( isCrateWeap )
		{
			if ( infiniteAmmo )
				weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, ammoPoolMax )
			else
				weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, newAmmoPoolSize )
		}
		else if( !infiniteAmmo )
		{
			player.AmmoPool_SetCount( ammoPoolType, newAmmoPoolSize )
		}
	}
}

void function HandleGoldMagCarAmmoSwap(entity weapon)
{
	if(!IsValid(weapon))
		return

	LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )

	if ( weaponData.ref == "mp_weapon_car" && weapon.HasMod("ammo_type_swap") )
		weapon.RemoveMod("ammo_type_swap")
}

void function ClientCallback_UpdateLaserSightColor( entity player )
{
	player.UpdateLaserSightColor()
}
#endif //SERVER

#if SERVER
// Used to set a weapon locked set properly when a weapon is being given to a player from a loot ref
void function SetWeaponLockedSetFromLootTags( array < string > lootTags, entity weapon )
{
	if ( lootTags.len() <= 0 || !IsValid( weapon ) )
		return

	if ( lootTags.contains( WEAPON_LOCKEDSET_MOD_WHITESET ) )
		weapon.SetWeaponLockedSet( eWeaponLockedSet.WHITESET )
	else if ( lootTags.contains( WEAPON_LOCKEDSET_MOD_BLUESET ) )
		weapon.SetWeaponLockedSet( eWeaponLockedSet.BLUESET )
	else if ( lootTags.contains( WEAPON_LOCKEDSET_MOD_PURPLESET ) )
		weapon.SetWeaponLockedSet( eWeaponLockedSet.PURPLESET )
	else if ( lootTags.contains( WEAPON_LOCKEDSET_MOD_GOLD ) )
		weapon.SetWeaponLockedSet( eWeaponLockedSet.GOLD )
}
#endif //SERVER

#if CLIENT
void function UICallback_UpdateLaserSightColor()
{
	Remote_ServerCallFunction( "ClientCallback_UpdateLaserSightColor" )
}

bool function TryCharacterButtonCommonReadyChecks( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return false
	if ( player != GetLocalClientPlayer() )
		return false
                     
	if ( HoverVehicle_PlayerIsDriving( player ) )
		return false
      

	return true
}
#endif // CLIENT

//following logic of ShouldShowADSScopeView in code
bool function ShouldShowADSScopeView( entity weapon )
{
	if ( !IsValid( weapon ) )
		return false

	if ( !HasFullscreenScope( weapon ) )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return false

	if ( player.GetZoomFrac() < weapon.GetWeaponSettingFloat( eWeaponVar.ads_fov_zoomfrac_end ) )
		return false

	return true
}


bool function HasFullscreenScope( entity weapon )
{
	if ( !IsValid( weapon ) )
		return false

	if ( weapon.GetWeaponSettingInt( eWeaponVar.bodygroup_ads_scope_set ) <= 0 )
		return false

	if ( weapon.GetWeaponInfoFileKeyField( "bodygroup_ads_scope_name" ) == null )
		return false

	return true
}

#if CLIENT
vector function GetAmmoColorByType( string ammoType )
{
	int colorID  = ammoColors[ammoType]
	vector color = GetKeyColor( colorID ) / 255.0
	return color
}
#endif


bool function EnergyChoke_OnWeaponModCommandCheckMods( entity player, entity weapon, string mod, bool isAdd )
{
	weapon.ForceChargeEndNoAttack()
	weapon.Signal( END_KINETIC_LOADER_CHOKE )
	weapon.RemoveMod( "kinetic_choke" )
	if ( isAdd && weapon.HasMod( KINETIC_LOADER_HOPUP ) && mod == "choke")
	{
		if( !weapon.HasMod( "hopup_kinetic_choke" ) )
		{
			weapon.AddMod( "hopup_kinetic_choke" )
			thread KineticLoaderChokeFunctionality_ServerThink( player, weapon )
		}
	}
	else if ( !isAdd && weapon.HasMod( KINETIC_LOADER_HOPUP ) && mod == "choke")
	{
		weapon.RemoveMod( "hopup_kinetic_choke" )
	}
	return true
}

#if SERVER
void function ChargeTactical_ForceEnd( entity player )
{
	entity tactical = player.GetOffhandWeapon( OFFHAND_LEFT )
	if ( IsValid( tactical ) )
	{
		if ( tactical.IsChargeWeapon() )
		{
			if ( tactical.IsWeaponCharging() )
			{
				tactical.ForceChargeEndNoAttack()
				tactical.SetWeaponPrimaryClipCount( 0 )
			}
			else
			{
				array <entity> activeWeapons = player.GetAllActiveWeapons()
				if ( activeWeapons.len() > 1 )
				{
					entity offhandWeapon = activeWeapons[1]
					if ( offhandWeapon == tactical )
					{
						player.ClearOffhand( eActiveInventorySlot.altHand )
					}
				}
			}
		}
	}
}
#endif

vector function CalcProjectileTrajectory( vector startPos, vector targetPos, float desiredTravelTime, bool debugDraw )
{
	//float velX = ( Xend - Xstart) / t
	//
	//	float velY = sqrt( velYStart*velYStart - 2*( Yend - Ystart ) )
	//	velStartY = (yDiff + 0.5*g*t*t) / t

	vector startToTarget     = targetPos - startPos
	vector startToTargetFlat = FlattenVec( startToTarget )
	float xDiff              = Length( startToTargetFlat )
	float yDiff              = startToTarget.z


	float velX = (xDiff) / desiredTravelTime

	float gravity = GetConVarFloat( "sv_gravity" )

	float velY = (yDiff + 0.5 * gravity * desiredTravelTime * desiredTravelTime) / desiredTravelTime

	vector horizontalLaunchVel = Normalize( startToTargetFlat ) * velX

	vector launchVel = <horizontalLaunchVel.x, horizontalLaunchVel.y, velY>

	if ( debugDraw )
	{
		const float DRAW_TIME = 0.1
		//DebugDrawSphere( startPos, 5, <255, 255, 0>, false, DRAW_TIME )
		//DebugDrawSphere( targetPos, 5, <255, 255, 0>, false, DRAW_TIME )
		//DebugDrawArrow( startPos, startPos + launchVel, 10, <255, 255, 0>, false, DRAW_TIME )
	}

	return launchVel
}

//If possible, returns a starting velocity and flight duration for a projectile starting at launchOrigin and going to targetOrigin at launchSpeed against gravity
ArcSolution function SolveBallisticArc( vector launchOrigin, float launchSpeed, vector targetOrigin, float gravity, bool lowAngle = true )
{
	ArcSolution as

	// Derivation
	//   (1) x = v*t*cos O
	//   (2) y = v*t*sin O - .5*g*t^2
	//
	//   (3) t = x/(cos O*v)                                        [solve t from (1)]
	//   (4) y = v*x*sin O/(cos O * v) - .5*g*x^2/(cos^2 O*v^2)     [plug t into y=...]
	//   (5) y = x*tan O - g*x^2/(2*v^2*cos^2 O)                    [reduce; cos/sin = tan]
	//   (6) y = x*tan O - (g*x^2/(2*v^2))*(1+tan^2 O)              [reduce; 1+tan O = 1/cos^2 O]
	//   (7) 0 = ((-g*x^2)/(2*v^2))*tan^2 O + x*tan O - (g*x^2)/(2*v^2) - y    [re-arrange]
	//   Quadratic! a*p^2 + b*p + c where p = tan O
	//
	//   (8) let gxv = -g*x*x/(2*v*v)
	//   (9) p = (-x +- sqrt(x*x - 4gxv*(gxv - y)))/2*gxv           [quadratic formula]
	//   (10) p = (v^2 +- sqrt(v^4 - g(g*x^2 + 2*y*v^2)))/gx        [multiply top/bottom by -2*v*v/x; move 4*v^4/x^2 into root]
	//   (11) O = atan(p)

	vector diff = targetOrigin - launchOrigin
	vector diffXZ =FlattenVec( diff );
	float groundDist = Length( diffXZ );

	float speed2 = launchSpeed*launchSpeed;
	float speed4 = launchSpeed*launchSpeed*launchSpeed*launchSpeed;
	float y = diff.z;
	float x = groundDist;
	float gx = gravity*x;

	float root = speed4 - gravity*(gravity*x*x + 2*y*speed2);

	// No solution
	if (root < 0)
		return as;

	as.valid = true
	root = sqrt( root );

	float lowAng = atan2(speed2 - root, gx)
	float highAng = atan2(speed2 + root, gx)

	float goodAngle = ( lowAngle ) ? lowAng : highAng

	vector groundDir = Normalize( diffXZ )
	as.fire_velocity = ( groundDir * cos( goodAngle ) *launchSpeed ) + ( < 0, 0, 1 > * sin( goodAngle ) * launchSpeed )
	float groundSpeed = Length( FlattenVec( as.fire_velocity ) )
	groundSpeed = ( groundSpeed > 0 ) ? groundSpeed : 1.0
	as.duration = groundDist / groundSpeed

	return as;
}

CrosshairTargetData function GetCrosshairTargetData( entity player, float minDistance, float maxDistance, float airBurstHeight, bool capAtMaxRange = false )
{
	CrosshairTargetData data
	data.crosshairStart = player.CameraPosition()
	vector crosshairEnd = data.crosshairStart + player.GetViewForward() * maxDistance
	DoTraceCoordCheck( false )
	array< entity > ignoreEnts = [ player ]
	ignoreEnts.extend( GetEntArrayByScriptName( CRYPTO_DRONE_SCRIPTNAME ) )
	TraceResults crosshairResults = TraceLineHighDetail( data.crosshairStart, crosshairEnd, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
	data.groundTarget = crosshairResults.endPos
	data.groundTargetNormal = crosshairResults.surfaceNormal
	data.airburstTarget = data.groundTarget + < 0, 0, airBurstHeight >
	data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
	data.directionToTarget =  Normalize( data.groundTarget - data.crosshairStart )
	float flattenedDistanceToTarget = Distance2D( data.groundTarget, data.crosshairStart )
	if( flattenedDistanceToTarget < minDistance )
	{
		data.groundTarget = crosshairResults.endPos + ( FlattenNormalizeVec ( data.directionToTarget ) * ( minDistance - flattenedDistanceToTarget ) )
		vector downTraceEnd = < data.groundTarget.x, data.groundTarget.y, data.groundTarget.z - 250 >
		TraceResults downTraceResults = TraceLineHighDetail( data.groundTarget, downTraceEnd, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
		if( downTraceResults.startSolid || downTraceResults.fraction < 1.0 )
			data.groundTarget = downTraceResults.endPos
		data.airburstTarget = data.groundTarget + < 0, 0, airBurstHeight >
		data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
		data.inRange = true
	}
	else if ( capAtMaxRange && crosshairResults.fraction == 1.0 )
	{
		vector downTraceStart = data.crosshairStart + ( FlattenNormalizeVec ( data.directionToTarget ) *  maxDistance )
		vector downTraceEnd = < data.groundTarget.x, data.groundTarget.y, data.groundTarget.z - 25000 >
		TraceResults downTraceResults = TraceLineHighDetail( data.groundTarget, downTraceEnd, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
		if( downTraceResults.startSolid || downTraceResults.fraction < 1.0 )
			data.groundTarget = downTraceResults.endPos
		data.airburstTarget = data.groundTarget + < 0, 0, airBurstHeight >
		data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
		data.inRange = true

	}
	else
	{
		data.inRange = ( crosshairResults.fraction < 1.0 )
	}
	DoTraceCoordCheck( true )

	return data
}

CrosshairTargetData function GetCrosshairTargetDataAngles( entity player, float minDistance, float maxDistance, float airBurstHeight, bool capAtMaxRange = false )
{
	const bool DEBUG_AIRBUST_TARGET = false
	CrosshairTargetData data

	vector cameraAngles           = player.CameraAngles()
	vector cameraFwd              = AnglesToForward( cameraAngles )
	vector cameraFwdFlat          = FlattenNormalizeVec( cameraFwd )

	DoTraceCoordCheck( false )
	array< entity > ignoreEnts = [ player ]
	ignoreEnts.extend( GetEntArrayByScriptName( CRYPTO_DRONE_SCRIPTNAME ) )
	TraceResults testTrace = TraceLineHighDetail( player.CameraPosition(), player.CameraPosition() + cameraFwd*maxDistance*2.0, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
	float heightDiff = testTrace.endPos.z - player.CameraPosition().z
	float PITCH_ADJUST = GraphCapped( heightDiff, 300, -1000, -10, 20 )

	if ( DEBUG_AIRBUST_TARGET )
		printt( "GetCrosshairTargetDataAngles - heightDiff: " + heightDiff + " PITCH_ADJUST: " + PITCH_ADJUST )

	float MIN_PITCH = 25 + PITCH_ADJUST
	float MAX_PITCH = -10  + PITCH_ADJUST

	float desiredDistanceToTarget = GraphCapped( cameraAngles.x, MIN_PITCH, MAX_PITCH, minDistance, maxDistance )


	data.crosshairStart = player.CameraPosition()
	vector crosshairEnd = player.GetOrigin() + cameraFwdFlat*desiredDistanceToTarget

	TraceResults initialCameraTrace = TraceLineHighDetail( data.crosshairStart, crosshairEnd, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )

	if ( DEBUG_AIRBUST_TARGET )
	{
		//DebugDrawLine( data.crosshairStart + <0, 0, 1>, crosshairEnd, COLOR_ORANGE, false, 0.1 )
		//DebugDrawSphere( crosshairEnd, 5, COLOR_ORANGE, true, 0.1 )
		//DebugDrawSphere( initialCameraTrace.endPos, 10, <0, 255, 0>, false, 0.1 )
	}

	data.groundTarget = initialCameraTrace.endPos
	data.groundTargetNormal = initialCameraTrace.surfaceNormal
	data.airburstTarget = data.groundTarget + < 0, 0, airBurstHeight >
	data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
	data.directionToTarget =  Normalize( data.groundTarget - data.crosshairStart )
	float flattenedDistanceToTarget = Distance2D( data.groundTarget, data.crosshairStart )

	if ( initialCameraTrace.fraction < 1.0 ) //flattenedDistanceToTarget < (desiredDistanceToTarget - 2*METERS_TO_INCHES ) )
	{
		if ( DEBUG_AIRBUST_TARGET )
			DebugDrawText( initialCameraTrace.endPos, "Initial cant see", false, 0.1 )

		// Can I see a point above it
		bool canTraceAbove = false
		float heightMult = 0.0
		TraceResults traceAbove
		while ( !canTraceAbove && heightMult < 10.0)
		{
			heightMult += 1.0
			traceAbove = TraceLineHighDetail( data.crosshairStart, crosshairEnd + < 0, 0, airBurstHeight*heightMult >, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
			canTraceAbove = traceAbove.fraction == 1.0
		}

		if ( canTraceAbove )
		{
			TraceResults traceDown = TraceLineHighDetail( traceAbove.endPos, crosshairEnd, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
			data.groundTarget = traceDown.endPos
			data.groundTargetNormal = traceDown.surfaceNormal
			data.airburstTarget = data.groundTarget + < 0, 0, airBurstHeight >
			data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
			data.directionToTarget =  Normalize( data.groundTarget - data.crosshairStart )

			if ( DEBUG_AIRBUST_TARGET )
			{
				DebugDrawText( traceAbove.endPos, "Can see this point", false, 0.1 )
				//DebugDrawLine( traceAbove.endPos, traceDown.endPos, <0, 255, 0>, false, 0.1)
				//DebugDrawSphere( traceDown.endPos, 10, <0, 255, 0>, false, 0.1 )
			}
		}

	}
	else
	{
		//Make sure we arent up in the air.
		TraceResults traceDown = TraceLineHighDetail( initialCameraTrace.endPos, initialCameraTrace.endPos - <0,0,6000>, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
		data.groundTarget = traceDown.endPos
		data.groundTargetNormal = traceDown.surfaceNormal
		data.airburstTarget = data.groundTarget + < 0, 0, airBurstHeight >

		if ( DEBUG_AIRBUST_TARGET )
		{
			//DebugDrawLine( initialCameraTrace.endPos, traceDown.endPos, <0, 255, 0>, false, 0.1)
			//DebugDrawSphere( traceDown.endPos, 10, <0, 255, 0>, false, 0.1 )
		}

		////Make sure I can see the airburst
		//TraceResults traceToAirburst = TraceLineHighDetail( player.GetWorldSpaceCenter(), data.airburstTarget, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
		//float heightMult = 1.0
		//while ( traceToAirburst.fraction < 1.0 &&  heightMult < 5.0 )
		//{
		//	heightMult += 0.5
		//	data.airburstTarget = data.groundTarget + < 0, 0, heightMult*airBurstHeight >
		//	traceToAirburst = TraceLineHighDetail( player.GetWorldSpaceCenter(), data.airburstTarget, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
		//}
		//
		//data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
		//data.directionToTarget =  Normalize( data.groundTarget - data.crosshairStart )
		//
		//if ( DEBUG_AIRBUST_TARGET )
		//{
		//	DebugDrawLine(player.GetWorldSpaceCenter(), data.airburstTarget, COLOR_PURPLE, false, 0.1  )
		//	printt( "GetCrosshairTargetDataAngles - heightMult needed: " + heightMult )
		//}
	}


	//Make sure I can see the airburst
	TraceResults traceToAirburst = TraceLineHighDetail( player.GetWorldSpaceCenter(), data.airburstTarget, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
	if( traceToAirburst.fraction < 1.0 )
	{
		float heightMult = 1.0
		while ( traceToAirburst.fraction < 1.0 &&  heightMult < 5.0 )
		{
			heightMult += 0.5
			data.airburstTarget = data.groundTarget + < 0, 0, heightMult*airBurstHeight >
			traceToAirburst = TraceLineHighDetail( player.GetWorldSpaceCenter(), data.airburstTarget, ignoreEnts, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS ) & ~CONTENTS_WINDOW, TRACE_COLLISION_GROUP_PROJECTILE )
		}

		data.distanceToTarget = Distance( data.groundTarget, data.crosshairStart )
		data.directionToTarget =  Normalize( data.groundTarget - data.crosshairStart )

		if ( DEBUG_AIRBUST_TARGET )
		{
			//DebugDrawLine(player.GetWorldSpaceCenter(), data.airburstTarget, COLOR_PURPLE, false, 0.1  )
			printt( "GetCrosshairTargetDataAngles - heightMult needed: " + heightMult )
		}
	}

	data.inRange = true

	DoTraceCoordCheck( true )


	if ( DEBUG_AIRBUST_TARGET )
	{
		//DebugDrawSphere( data.groundTarget , 5, COLOR_PURPLE, false, 0.1 )
		DebugDrawText( data.groundTarget, "ground", false, 0.1 )
		//DebugDrawSphere( data.airburstTarget , 15, COLOR_PURPLE, false, 0.1 )
		DebugDrawText( data.airburstTarget, "air", false, 0.1 )
		//DebugDrawLine( data.groundTarget, data.airburstTarget, COLOR_PURPLE, false, 0.1  )
	}

	return data
}

void function Weapon_AddSingleCharge( entity weapon )
{
	int ammoReq = weapon.GetAmmoPerShot()
	int maxClip = weapon.GetWeaponPrimaryClipCountMax()
	int fullAdd = weapon.GetWeaponPrimaryClipCount() + ammoReq
	int newClip = minint( maxClip, fullAdd )
	weapon.SetWeaponPrimaryClipCount( newClip )

	if ( fullAdd > maxClip )
	{
		int diff = fullAdd - maxClip
		int maxAmmo = weapon.GetWeaponPrimaryAmmoCountMax( AMMOSOURCE_STOCKPILE )
		int fullAmmoAdd = weapon.GetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE ) + diff
		int newAmmo = minint( maxAmmo, fullAmmoAdd )
		weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, newAmmo )
	}
}

#if SERVER || CLIENT
bool function AreAbilitiesSilenced( entity player )
{
	if ( !IsValid( player ) )
		return true

	if ( StatusEffect_HasSeverity( player, eStatusEffect.silenced ) )
		return true
	if ( StatusEffect_HasSeverity( player, eStatusEffect.is_boxing ) )
		return true

	return false
}
#endif

int function GetNeededEnergizeConsumableCount( entity weapon, entity player )
{
	string weaponRef = weapon.GetWeaponClassName()
	string consumableRef = GetWeaponInfoFileKeyField_GlobalString ( weaponRef, "energized_consumable" )
	int consumableRequiredCount = GetWeaponInfoFileKeyField_GlobalInt ( weaponRef, "energized_consumable_needed_amount" )

	int requiredCountWithPassive = consumableRequiredCount
	// Put all passive cases on different consumables here
	{
		if ( consumableRef == "health_pickup_combo_small" )
			requiredCountWithPassive = player.HasPassive( ePassives.PAS_BONUS_SMALL_HEAL ) ? maxint( 1, consumableRequiredCount - 1 ) : consumableRequiredCount
	}

	return requiredCountWithPassive
}

bool function HasEnoughEnergizeConsumable( entity weapon, entity player )
{
	string weaponRef = weapon.GetWeaponClassName()
	string consumableRef = GetWeaponInfoFileKeyField_GlobalString ( weaponRef, "energized_consumable" )
	int consumableRequiredCount = GetNeededEnergizeConsumableCount( weapon, player )
	int consumableCurrentCount = SURVIVAL_CountItemsInInventory( player, consumableRef )

	LootData lootData = SURVIVAL_Loot_GetLootDataByRef( consumableRef )

	//If we have infinite healing and the consumable is a healing item... we have enough
	if ( PlayerHasPassive( player, ePassives.PAS_INFINITE_HEAL ) && lootData.lootType == eLootType.HEALTH )
		return true

	return consumableCurrentCount >= consumableRequiredCount
}

bool function OnWeaponTryEnergize( entity weapon, entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( !IsValid( weapon ) )
		return false

	string weaponName = weapon.GetWeaponClassName()
	float maxInputFrac = GetWeaponInfoFileKeyField_GlobalFloat( weaponName, "energized_max_reenergize_frac" )
	float energizedDuration = GetWeaponInfoFileKeyField_GlobalFloat( weaponName, "energized_duration" )
	float chargeFrac = max( weapon.GetEnergizedEndTime() - Time(), 0 ) / energizedDuration

	if ( !(weapon.GetEnergizeState() == ENERGIZE_ENERGIZED && weapon.GetLastEnergizeState() == ENERGIZE_ENERGIZING) )
	{
		if ( chargeFrac > maxInputFrac )
		{
			#if CLIENT
				string pingStringData = GetWeaponInfoFileKeyField_GlobalString ( weaponName, "energized_full_text" )
				AnnouncementMessageRight( player, Localize( pingStringData ) )
			#endif
			return false
		}
	}

	if( !HasEnoughEnergizeConsumable( weapon, player ) )
	{
		#if CLIENT
		int consumableRequiredCount = GetNeededEnergizeConsumableCount( weapon, player )
		string consumableName = GetWeaponInfoFileKeyField_GlobalString( weaponName, consumableRequiredCount > 1 ? "energized_consumable_name_plural" : "energized_consumable_name_singular" )
		string pingStringData = GetWeaponInfoFileKeyField_GlobalString ( weaponName, "energized_consumable_required_hint" )

		// TODO: we might want to make sure these hints take the same number of parameters
		if( weaponName == "mp_weapon_dragon_lmg"  )
			AnnouncementMessageRight( player, Localize( pingStringData, Localize( consumableName ) ) )
		else
			AnnouncementMessageRight( player, Localize( pingStringData, consumableRequiredCount, Localize( consumableName ) ) )

		string commsData = GetWeaponInfoFileKeyField_GlobalString ( weaponName, "energized_comms" )
		Quickchat( eCommsAction[commsData], null )
		#endif

		return false
	}

	return true
}

void function OnWeaponEnergizedStart( entity weapon, entity player, bool costConsumable )
{
	if ( !IsValid( weapon ) || !costConsumable )
		return

	string weaponRef = weapon.GetWeaponClassName()
	string consumableRef = GetWeaponInfoFileKeyField_GlobalString ( weaponRef, "energized_consumable" )
	int consumableRequiredCount = GetNeededEnergizeConsumableCount( weapon, player )

	LootData lootData = SURVIVAL_Loot_GetLootDataByRef( consumableRef )

	//If we have infinite healing and the consumable is a healing item... do NOT remove from inventory
	if ( PlayerHasPassive( player, ePassives.PAS_INFINITE_HEAL ) && lootData.lootType == eLootType.HEALTH )
		return

	SURVIVAL_RemoveFromPlayerInventory( player, consumableRef, consumableRequiredCount )
}

#if CLIENT
void function DisplayCenterDotRui( entity weapon, string abortSignal, float appearDelay, float duration, float dotAlpha, float fadeInDuration, float fadeOutDuration )
{
	AssertIsNewThread()
	if ( !IsValid( weapon ) )
		return
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( abortSignal )

	var rui = CreateCockpitPostFXRui( $"ui/crosshair_single_dot_helper.rpak" )
	RuiSetBool( rui, "isActive", false )

	OnThreadEnd(
		function() : ( rui, weapon, player )
		{
			RuiDestroy( rui )
		}
	)

	wait appearDelay

	if ( !IsValid( weapon ) )
		return

	float endTime = Time() + duration

	RuiSetBool( rui, "isActive", true )
	RuiSetFloat( rui, "birthTime", Time() )
	RuiSetFloat( rui, "deathTime", endTime )
	RuiSetFloat( rui, "dotAlpha", dotAlpha )
	RuiSetFloat( rui, "fadeInDuration", fadeInDuration )
	RuiSetFloat( rui, "fadeOutDuration", fadeOutDuration )

	while ( Time() < endTime )
	{
		WaitFrame()
	}

	RuiSetBool( rui, "isActive", false )
}
#endif

// --------------------------------------------------------------------------------------
//
//	Marksmans Tempo
//
// --------------------------------------------------------------------------------------
// ! === !
// IMPORTANT: Marksman's Tempo uses ScriptInt1 and ScriptTime1, make sure the weapon is not using these for other purposes when using Marksman's Tempo
// ! === !

bool function MarksmansTempo_Validate( entity weapon, MarksmansTempoSettings settings )
{
	#if CLIENT
		if ( !InPrediction() )
			return weapon.HasMod( MOD_MARKSMANS_TEMPO )
	#endif

	if ( !weapon.HasMod( MOD_MARKSMANS_TEMPO ) )
	{
		MarksmansTempo_RemoveTempo( weapon, settings )
		return false
	}

	return true
}

void function MarksmansTempo_OnActivate( entity weapon, MarksmansTempoSettings settings )
{
	AssertIsNewThread()
	weapon.EndSignal( "OnDestroy" )

	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	#if SERVER
		if ( !weapon.w.modsToRemoveOnDrop.contains( MOD_MARKSMANS_TEMPO_ACTIVE ) )
			weapon.w.modsToRemoveOnDrop.append( MOD_MARKSMANS_TEMPO_ACTIVE )
		if ( !weapon.w.modsToRemoveOnDrop.contains( MOD_MARKSMANS_TEMPO_BUILDUP ) )
			weapon.w.modsToRemoveOnDrop.append( MOD_MARKSMANS_TEMPO_BUILDUP )
	#endif

	WaitFrame()	//activate is called before old script vars are copied back over when we create new guns for attach swaps and such, so we have to wait a frame

	bool valid = MarksmansTempo_Validate( weapon, settings )
	#if SERVER
	if ( valid )
	{
		weapon.SetScriptFloat0( float(settings.requiredShots) )
		weapon.SetScriptInt1( 0 )
	}
	#endif

}

void function MarksmansTempo_OnDeactivate( entity weapon, MarksmansTempoSettings settings )
{
	#if CLIENT
	if ( !InPrediction() )
		return
	#endif

	if ( MarksmansTempo_Validate( weapon, settings ) )
		MarksmansTempo_ClearTempo( weapon, settings )
}

void function MarksmansTempo_AbortFadeoff( entity weapon, MarksmansTempoSettings settings )
{
	weapon.Signal( MARKSMANS_TEMPO_FADEOFF_THREAD_ABORT )
}

void function MarksmansTempo_SetPerfectTempoMoment( entity weapon, MarksmansTempoSettings settings, entity player, float time, bool useOnPerfectMomentFadeoff )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	if ( weapon.HasMod( MOD_MARKSMANS_TEMPO ) && (!IsClient() || InPrediction()) )
	{
		weapon.SetScriptTime1( time )

		if ( useOnPerfectMomentFadeoff )
		{
			weapon.Signal( MARKSMANS_TEMPO_FADEOFF_THREAD_ABORT )
			float fadeoffDelay = time - Time()
			float fadeoffTime
			if ( settings.fadeoffMatchGraceTime > 0 )
				fadeoffTime = weapon.HasMod( MOD_MARKSMANS_TEMPO_ACTIVE ) ? settings.graceTimeInTempo : settings.graceTimeBuildup
			else
				fadeoffTime = settings.fadeoffOnPerfectMomentHit
			thread MarksmansTempo_Fadeoff( weapon, settings, fadeoffTime + fadeoffDelay )
		}
	}
}

void function MarksmansTempo_Fadeoff( entity weapon, MarksmansTempoSettings settings, float fadeTime )
{
	AssertIsNewThread()
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( settings.weaponDeactivateSignal )
	weapon.EndSignal( MARKSMANS_TEMPO_FADEOFF_THREAD_ABORT )

	wait fadeTime
	MarksmansTempo_ClearTempo( weapon, settings )
}

void function MarksmansTempo_OnFire( entity weapon, MarksmansTempoSettings settings, bool useOnFireFadeoff )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	weapon.RemoveMod( MOD_MARKSMANS_TEMPO_BUILDUP )
	weapon.Signal( MARKSMANS_TEMPO_FADEOFF_THREAD_ABORT )
	if ( MarksmansTempo_Validate( weapon, settings ) )
	{
		float graceTime = weapon.HasMod( MOD_MARKSMANS_TEMPO_ACTIVE ) ? settings.graceTimeInTempo : settings.graceTimeBuildup
		if ( Time() <= weapon.GetScriptTime1() + graceTime  )
		{
			int newShotCount = minint( weapon.GetScriptInt1() + 1, settings.requiredShots )
			weapon.SetScriptInt1( newShotCount )
			if ( newShotCount >= settings.requiredShots )
			{
				weapon.AddMod( MOD_MARKSMANS_TEMPO_ACTIVE )
			}

			if ( !weapon.HasMod( MOD_MARKSMANS_TEMPO_ACTIVE ) )
			{
				weapon.AddMod( MOD_MARKSMANS_TEMPO_BUILDUP )
			}

			if ( useOnFireFadeoff )
				thread MarksmansTempo_Fadeoff( weapon, settings, settings.fadeoffOnFire )
		}
		else
		{
			MarksmansTempo_ClearTempo( weapon, settings )
		}
	}
}

void function MarksmansTempo_ClearTempo( entity weapon, MarksmansTempoSettings settings )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	weapon.SetScriptInt1( 0 )
	MarksmansTempo_ClearMods( weapon )
}

void function MarksmansTempo_RemoveTempo( entity weapon, MarksmansTempoSettings settings )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	weapon.SetScriptInt1( -1 ) //set script int to -1 when marksmans tempo isn't active so UI knows whether to draw marksmans tempo UI or not
	MarksmansTempo_ClearMods( weapon )
}

void function MarksmansTempo_ClearMods( entity weapon )
{
	weapon.RemoveMod( MOD_MARKSMANS_TEMPO_ACTIVE )
	weapon.RemoveMod( MOD_MARKSMANS_TEMPO_BUILDUP )
}



// --------------------------------------------------------------------------------------
//
//	SHATTER ROUNDS
//
// --------------------------------------------------------------------------------------
// ! === !
// IMPORTANT: Shatter rounds uses ScriptInt0, make sure the weapon is not using these for other purposes when using shatter rounds
// ! === !
//these are only called from mod commands, but the toggle mods use a mod command
void function ShatterRounds_OnPlayerAddedWeaponMod( entity player, entity weapon, string mod )
{
	if ( mod != SHATTER_ROUNDS_HIPFIRE_MOD )
		return

	if ( !IsValid( weapon ) )
		return

	ShatterRounds_AddShatterRounds( weapon )
}

//these are only called from mod commands, but the toggle mods use a mod command
void function ShatterRounds_OnPlayerRemovedWeaponMod( entity player, entity weapon, string mod )
{
	if ( mod != SHATTER_ROUNDS_HIPFIRE_MOD )
		return

	if ( !IsValid( weapon ) )
		return

	ShatterRounds_RemoveShatterRounds( weapon )
}

//backup logic to update arrow types if it is messed with not using mod commands (so doesn't hit the above callbacks)
void function ShatterRounds_UpdateShatterRoundsThink( entity weapon )
{
	AssertIsNewThread()
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( SHATTER_ROUNDS_THINK_END_SIGNAL )
	weapon.EndSignal( "OnDestroy" )

	Assert( eShatterRoundsTypes._count == 2 )

	WaitFrame()		//This gets called on activate, and then the old script vals get copied over, overwriting anything done on the first frame here unless we wait 1 frame. blech

	int curState = -1
	while ( true )
	{
		if ( !IsValid( player ) || !IsValid( weapon ) )
			return

		if ( weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD ) && curState != 0 )
		{
			ShatterRounds_AddShatterRounds( weapon )
			curState = 0
		}
		else if ( !weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD ) && curState != 1 )
		{
			ShatterRounds_RemoveShatterRounds( weapon )
			curState = 1
		}

		WaitFrame()
	}
}

void function ShatterRounds_AddShatterRounds( entity weapon )
{
	#if SERVER
		if ( weapon.GetScriptInt0() != eShatterRoundsTypes.SHATTER_TRI )
			weapon.SetScriptInt0( eShatterRoundsTypes.SHATTER_TRI )
	#endif
	#if CLIENT
		if ( weapon.GetWeaponClassName() == "mp_weapon_bow" )
			WeaponBow_UpdateArrowColor( weapon, eShatterRoundsTypes.SHATTER_TRI )

	#endif
}

void function ShatterRounds_RemoveShatterRounds( entity weapon )
{
	#if SERVER
		if ( weapon.GetScriptInt0() != eShatterRoundsTypes.STANDARD )
			weapon.SetScriptInt0( eShatterRoundsTypes.STANDARD )
	#endif
	#if CLIENT
		if ( weapon.GetWeaponClassName() == "mp_weapon_bow" )
			WeaponBow_UpdateArrowColor( weapon, eShatterRoundsTypes.STANDARD )
	#endif
}
#if SERVER
void function ShatterRounds_ADSThink ( entity player, entity weapon )
{
	AssertIsNewThread()
	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( SHATTER_ROUNDS_ADS_THINK_THREAD_ABORT_SIGNAL )

	OnThreadEnd(
		function() : ( player, weapon )
		{
			if ( IsValid( weapon ) )
				weapon.RemoveMod( SHATTER_ROUNDS_HIPFIRE_MOD )
		}
	)

	while ( true )
	{
		if ( !IsValid( weapon ) || !IsValid( player ) )
			return

		if ( weapon.IsWeaponInAds() &&  weapon.HasMod( SHATTER_ROUNDS_ALTFIRE_MOD ) )
		{
			if ( weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD ) )
			{
				weapon.RemoveMod( SHATTER_ROUNDS_HIPFIRE_MOD )
				ShatterRounds_RemoveShatterRounds( weapon )
			}
		}
		else if ( !weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD )  )
		{
			weapon.AddMod( SHATTER_ROUNDS_HIPFIRE_MOD )
			ShatterRounds_AddShatterRounds( weapon )
		}

		if ( !weapon.HasMod( SHATTER_ROUNDS_ALTFIRE_MOD ) )
		{
			weapon.RemoveMod( SHATTER_ROUNDS_HIPFIRE_MOD )
			ShatterRounds_RemoveShatterRounds( weapon )
			return
		}

		WaitFrame()
	}
}
#endif

#if SERVER
void function OnWeaponAttachmentChanged_CheckForShatterCaps( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	if ( IsValid( player ) && IsValid( weapon ) )
	{
		if( weapon.HasMod(SHATTER_ROUNDS_ALTFIRE_MOD) )
		{
			thread ShatterRounds_ADSThink ( player, weapon )
		}
	}

}
#endif


#if SERVER
void function OnWeaponAttachmentChanged_CheckForAnvilReceiver( entity player, entity weapon, string modToAdd, string modToRemove )
{
                      

	if( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	if ( modToAdd == "hopup_highcal_rounds" )
	{
		if (( weapon.HasMod ( "altfire" )) && (weapon.HasMod ( "hopup_highcal_rounds" )) )
		{
			weapon.RemoveMod ( "altfire" )
			weapon.AddMod( "altfire_highcal" )
		}
	}

                           
}
#endif


#if CLIENT
void function ServerToClient_Activate_Smart_Reload( entity weapon, int overloadAmmo, float lowAmmoFrac )
{
	SmartReloadSettings settings
	settings.OverloadedAmmo = overloadAmmo
	settings.LowAmmoFrac = lowAmmoFrac

	OnWeaponActivate_Smart_Reload( weapon, settings )
}
#endif // CLIENT


//Boosted Loader Start
void function OnWeaponActivate_Smart_Reload( entity weapon, SmartReloadSettings settings )
{
	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()

	if ( IsValid( player ) )
	{
		#if CLIENT
		int slot = GetSlotForWeapon( player, weapon )
		if ( slot >= 0 )
			weapon.w.activeOptic = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, "sight" )
		else
			weapon.w.activeOptic = ""
		#endif
		ApplySmartReloadFunctionality ( player, weapon, settings )
	}
}

void function ApplySmartReloadFunctionality( entity player, entity weapon, SmartReloadSettings settings )
{
#if SERVER
	thread ApplySmartReloadFunctionality_ServerThink ( player, weapon, settings )
#endif
#if CLIENT
	thread ApplySmartReloadFunctionality_ClientThink ( player, weapon, settings )
#endif
}

void function OnWeaponReload_Smart_Reload( entity weapon, int milestoneIndex )
{
	LootData weaponLootData = SURVIVAL_Loot_GetLootDataByRef( weapon.GetWeaponClassName() )

	SmartReloadSettings settings
	settings.OverloadedAmmo				 = GetWeaponInfoFileKeyField_GlobalInt( weaponLootData.baseWeapon, OVERLOAD_AMMO_SETTING )

	entity player = weapon.GetWeaponOwner()
	int clipCount = weapon.GetWeaponPrimaryClipCount()
	int maxClipCount = weapon.GetWeaponPrimaryClipCountMax ()
	int maxClipWithoutOverloadedAmmo = maxClipCount - settings.OverloadedAmmo
	int overFlowAmmo = clipCount - maxClipWithoutOverloadedAmmo
	string ammoType = AmmoType_GetRefFromIndex( weapon.GetWeaponAmmoPoolType() )
	int ammoPoolType = eAmmoPoolType[ ammoType ]


	if ( !weapon.HasMod( SMART_RELOAD_HOPUP ) )
	{
		weapon.RemoveMod( LMG_OVERLOADED_AMMO_MOD )
		weapon.RemoveMod( LMG_FAST_RELOAD_MOD )
	}

	if ( weapon.HasMod( LMG_FAST_RELOAD_MOD ) )
	{
		#if CLIENT
		if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
			return

		EmitSoundOnEntity( player, "UI_InGame_BoostedLoader_Reload" )
		#endif
	}
	else
	{
		#if SERVER
		if( overFlowAmmo > 0 && weapon.HasMod( LMG_OVERLOADED_AMMO_MOD ) && !GetInfiniteAmmo( weapon ))
		{
			int amountAdded = SURVIVAL_AddToPlayerInventory( player, ammoType, overFlowAmmo, false )
			LootData weaponData 	= SURVIVAL_GetLootDataFromWeapon( weapon )
			bool isCrateWeap 		= weaponData.baseMods.contains( WEAPON_LOCKEDSET_MOD_CRATE )

			//If inventory is full, drop excess. Otherwise put it in inventory
			if ( amountAdded == 0 && !isCrateWeap)
			{
				entity ammoDrop = SpawnGenericLoot( ammoType, GetThrowOrigin( player ), < -1, -1, -1 >, overFlowAmmo )
				SetItemSpawnSource( ammoDrop, eSpawnSource.PLAYER_DROP, player )

				vector vel = AnglesToForward( player.EyeAngles() ) * 100
				FakePhysicsThrow( player, ammoDrop, vel, true )
			}
			else
			{
				int ammoPoolCount

				if (isCrateWeap)
				{
					//AddRoundsToWeapon( player, weapon,  overFlowAmmo )
					ammoPoolCount = weapon.GetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE )
					weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, ammoPoolCount + overFlowAmmo )
				}
				else
				{
					ammoPoolCount = player.AmmoPool_GetCount( ammoPoolType )
					if ( ammoPoolCount < 2000 ) //Fix for a possible dev crash.
					{
						player.AmmoPool_SetCount( ammoPoolType, ammoPoolCount + overFlowAmmo )
					}
				}
			}
		}
		#endif

		weapon.RemoveMod( LMG_OVERLOADED_AMMO_MOD )
	}
}

#if SERVER
void function OnWeaponAttachmentChanged_CheckForSmartReload( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if ( IsValid( player ) && IsValid( weapon ) )
	{
			if(weapon.HasMod(SMART_RELOAD_HOPUP))
			{
				LootData weaponLootData = SURVIVAL_Loot_GetLootDataByRef(weapon.GetWeaponClassName())
				SmartReloadSettings settings

				settings.OverloadedAmmo = GetWeaponInfoFileKeyField_GlobalInt( weaponLootData.baseWeapon , OVERLOAD_AMMO_SETTING )
				settings.LowAmmoFrac = GetWeaponInfoFileKeyField_GlobalFloat( weaponLootData.baseWeapon, LOW_AMMO_FAC_SETTING )

				weapon.Signal( END_SMART_RELOAD )

				OnWeaponActivate_Smart_Reload( weapon, settings )
				Remote_CallFunction_NonReplay( player, "ServerToClient_Activate_Smart_Reload", weapon, settings.OverloadedAmmo, settings.LowAmmoFrac )
			}
		}
}

#endif
void function OnWeaponDeactivate_Smart_Reload ( entity weapon )
{
	weapon.Signal ( END_SMART_RELOAD )
	entity player = weapon.GetWeaponOwner()

	if( !IsValid( weapon ) || !IsValid( player) )
		return

	#if SERVER
		if ( IsDisconnected( player ) )
			return
	#endif

	#if SERVER
	if ( weapon.HasMod( SMART_RELOAD_HOPUP ) && !weapon.HasMod( LMG_FAST_RELOAD_MOD ) && !weapon.HasMod( LMG_OVERLOADED_AMMO_MOD ))
	{
		weapon.RemoveMod( LMG_OVERLOADED_AMMO_MOD )
		Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
	}
	#endif
}

void function ApplySmartReloadFunctionality_ClientThink ( entity player, entity weapon, SmartReloadSettings settings )
{
	#if CLIENT
		AssertIsNewThread()
		weapon.EndSignal( "OnDestroy" )
		weapon.EndSignal( END_SMART_RELOAD )

		if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
			return
		player.EndSignal( "OnDeath" )

		vector lowAmmoColor      = SrgbToLinear( LOWAMMO_UI_COLOR )
		vector normalAmmoColor   = SrgbToLinear( NORMALAMMO_UI_COLOR )
		vector overloadAmmoColor = SrgbToLinear( OVERLOADAMMO_UI_COLOR )
		vector outofAmmoColor    = SrgbToLinear( OUTOFAMMO_UI_COLOR )

		int clipCount
		int maxClipCount
		int overloadClipCount
		int maxAmmoRequiredCount
		float clipCountFrac = 1.0
		float offset = 0.05
		var rui = ClWeaponStatus_GetWeaponHudRui( player )
		var reloadRui = GetAmmoStatusHintRui()
		var crosshairRui = CreateCockpitPostFXRui( $"ui/ammo_status_hint.rpak", HUD_Z_BASE )
		var chargeBarRui = CreateCockpitPostFXRui( $"ui/crosshair_reload_hopup_bar.rpak" )

		OnThreadEnd(
			function() : ( player, weapon, rui, reloadRui, crosshairRui, chargeBarRui )
			{
				RuiDestroy( crosshairRui )
				RuiDestroy( chargeBarRui )
				RuiSetBool( reloadRui, "showHopupReloadIcon", false )
				RuiSetFloat3( rui, "ammoGlowColor", SrgbToLinear( NORMALAMMO_UI_COLOR ) )
			}
		)

		while ( true )
		{
			clipCount = weapon.GetWeaponPrimaryClipCount()
			maxClipCount = weapon.GetWeaponPrimaryClipCountMax()
			overloadClipCount = maxClipCount - settings.OverloadedAmmo
			maxAmmoRequiredCount = int( maxClipCount * settings.LowAmmoFrac)
			clipCountFrac = float( clipCount) / float( maxClipCount )

			if ( weapon.HasMod( LMG_FAST_RELOAD_MOD ) && weapon.IsReloading() )
			{
				RuiSetFloat3( chargeBarRui, "bracketColor", normalAmmoColor )
				RuiSetBool( crosshairRui, "showFastReloadText", true )
				RuiSetBool( crosshairRui, "showHopupReloadBG", true )
				RuiSetBool( reloadRui, "showHopupReloadIcon", false )
			}
			else if ( weapon.HasMod( SMART_RELOAD_HOPUP ) && weapon.HasMod( LMG_OVERLOADED_AMMO_MOD ) && clipCount > overloadClipCount )
			{
				RuiSetFloat3( rui, "ammoGlowColor", overloadAmmoColor )
				RuiSetFloat3( chargeBarRui, "bracketColor", overloadAmmoColor )
				RuiSetBool( crosshairRui, "showFastReloadText", false )
				RuiSetBool( crosshairRui, "showHopupReloadBG", false )
				RuiSetBool( reloadRui, "showHopupReloadIcon", false )
				RuiSetBool( chargeBarRui, "showExtraAmmo", true )
			}
			else if ( weapon.HasMod( SMART_RELOAD_HOPUP ) && clipCount > MIN_AMMO_REQUIRED && clipCount <= maxAmmoRequiredCount )
			{
				RuiSetFloat3( rui, "ammoGlowColor", lowAmmoColor )
				RuiSetFloat3( chargeBarRui, "bracketColor", lowAmmoColor )
				RuiSetBool( reloadRui, "showHopupReloadIcon", true )
				RuiSetBool( crosshairRui, "showFastReloadText", false )
				RuiSetBool( crosshairRui, "showHopupReloadBG", false )
			}
			else if ( weapon.HasMod( SMART_RELOAD_HOPUP ) && clipCount == 0 )
			{
				RuiSetFloat3( chargeBarRui, "bracketColor", outofAmmoColor )
				RuiSetBool( crosshairRui, "showFastReloadText", false )
				RuiSetBool( reloadRui, "showHopupReloadIcon", false )
				RuiSetBool( crosshairRui, "showHopupReloadBG", false )
				RuiSetBool( chargeBarRui, "showExtraAmmo", false )
			}
			else
			{
				RuiSetFloat3( chargeBarRui, "bracketColor", normalAmmoColor )
				RuiSetFloat3( rui, "ammoGlowColor", normalAmmoColor )
				RuiSetBool( crosshairRui, "showFastReloadText", false )
				RuiSetBool( reloadRui, "showHopupReloadIcon", false )
				RuiSetBool( crosshairRui, "showHopupReloadBG", false )
				RuiSetBool( chargeBarRui, "showExtraAmmo", false )
			}

			if ( weapon.HasMod( SMART_RELOAD_HOPUP ) )
			{
				RuiSetBool( chargeBarRui, "isActive", true )
				RuiSetFloat( chargeBarRui, "energizeFrac", clipCountFrac )
				RuiSetFloat( chargeBarRui, "adsFrac", player.GetZoomFrac() )

				switch ( weapon.w.activeOptic )
				{
					case "":	//ironsights
					offset = 0.05
					break
					case "optic_cq_hcog_classic":
						offset = 0.08
						break
					case "optic_cq_holosight":
						offset = 0.11
						break
					case "optic_cq_hcog_bruiser":
						offset = 0.09
						break
					case "optic_cq_holosight_variable":
						offset = 0.09
						break
					case "optic_ranged_hcog":
						offset = 0.11
						break
					case "optic_ranged_aog_variable":
						offset = 0.14
						break
					case "optic_cq_threat":
						offset = 0.07
						break
				}
				RuiSetFloat( chargeBarRui, "offset", offset )
			}
			WaitFrame()
		}
	#endif
}

void function ApplySmartReloadFunctionality_ServerThink ( entity player, entity weapon, SmartReloadSettings settings )
{
	#if SERVER
		AssertIsNewThread()
		weapon.EndSignal( "OnDestroy" )
		weapon.EndSignal( END_SMART_RELOAD )
		player.EndSignal( "OnDeath" )

		while ( true )
		{
			int clipCount = weapon.GetWeaponPrimaryClipCount()
			int maxClipCount = weapon.GetWeaponPrimaryClipCountMax ()
			int MaxAmmoRequiredCount = int( maxClipCount * settings.LowAmmoFrac)
			int overloadClipCount = maxClipCount - settings.OverloadedAmmo

			if ( weapon.HasMod( SMART_RELOAD_HOPUP ) && clipCount > MIN_AMMO_REQUIRED && clipCount <= MaxAmmoRequiredCount )
			{
				weapon.AddMod( LMG_FAST_RELOAD_MOD )
				weapon.AddMod( LMG_OVERLOADED_AMMO_MOD )
			}
			else if ( weapon.HasMod( SMART_RELOAD_HOPUP ) && weapon.HasMod( LMG_OVERLOADED_AMMO_MOD ) && clipCount <= overloadClipCount )
				weapon.RemoveMod( LMG_OVERLOADED_AMMO_MOD )
			else
				weapon.RemoveMod( LMG_FAST_RELOAD_MOD )

			WaitFrame()
		}
	#endif
}

bool function IsTurretWeapon( entity weapon )
{
	if( !IsValid( weapon ) || !weapon.IsWeaponX() )
		return false

	return ( GetWeaponInfoFileKeyField_GlobalInt_WithDefault( weapon.GetWeaponClassName(), "is_turret_weapon" , 0 ) == 1 )
}

bool function IsHMGWeapon( entity weapon )
{
	if( !IsValid( weapon ) || !weapon.IsWeaponX() )
		return false

	return ( GetWeaponInfoFileKeyField_GlobalInt_WithDefault( weapon.GetWeaponClassName(), "is_hmg_weapon" , 0 ) == 1 )
}

bool function IsMeleeWeapon( entity weapon )
{
	if( !IsValid( weapon ) || !weapon.IsWeaponX() )
		return false

	return ( GetWeaponInfoFileKeyField_GlobalInt_WithDefault( weapon.GetWeaponClassName(), "is_Melee_Weapon" , 0 ) == 1 )
}

bool function IsWeaponSemiAuto( entity weapon )
{
	return weapon.GetWeaponSettingBool( eWeaponVar.is_semi_auto )
}

void function OnWeaponActivate_Kinetic_Loader( entity weapon)
{
	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	entity player = weapon.GetWeaponOwner()

	if ( IsValid( player ) )
	{
		if ( weapon.HasMod ( KINETIC_LOADER_HOPUP ) )
		{
			#if CLIENT
			if ( InPrediction() )
			#endif
			{
				//OnWeaponActivate if the gun has a Kinetic Choke remove it.
				if ( weapon.HasMod( "hopup_kinetic_choke" ) && weapon.HasMod( "kinetic_choke" ) )
				{
						weapon.RemoveMod( "kinetic_choke" )
				}
			}

			ApplyKineticLoaderFunctionality( player, weapon )
		}

	}
}

void function OnWeaponDeactivate_Kinetic_Loader( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	weapon.Signal( END_KINETIC_LOADER )
	weapon.Signal( END_KINETIC_LOADER_CHOKE )

	#if CLIENT
	weapon.Signal( END_KINETIC_LOADER_RUI )
	#endif
}

void function ApplyKineticLoaderFunctionality( entity player, entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	if ( !IsValid( player ) )
		return

	weapon.Signal( END_KINETIC_LOADER )
	weapon.Signal( END_KINETIC_LOADER_CHOKE )

	#if SERVER
		thread KineticLoaderFunctionality_ServerThink( player, weapon )
		thread KineticLoaderChokeFunctionality_ServerThink( player, weapon )
	#endif

	#if CLIENT
		weapon.Signal( END_KINETIC_LOADER_RUI )
		thread ApplyKineticLoader_ClientThink( player, weapon )
	#endif
}

void function KineticLoaderChokeFunctionality_ServerThink( entity player, entity weapon )
{
	#if SERVER
		player.EndSignal( "OnDeath" )
		player.EndSignal( "OnDestroy" )
		weapon.EndSignal( END_KINETIC_LOADER_CHOKE )

		WaitFrame()

		if ( !IsValid( weapon ) || !IsValid( player ) )
			return

		while ( IsValid( weapon ) && IsValid( player ) )
		{
			if ( !weapon.HasMod( KINETIC_LOADER_HOPUP ) )
			{
				weapon.RemoveMod( "kinetic_choke" )
				break
			}

			if ( player.IsSliding() && player.IsOnGround() )
			{
				if ( weapon.HasMod( "hopup_kinetic_choke" ) )
				{
					float chargeTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )

					if ( chargeTime > 0 )
					{
						if ( !weapon.IsWeaponCharging() )
						{
							if ( weapon.HasMod( "choke" ) )

							if ( !weapon.HasMod( "kinetic_choke" ) )
								weapon.AddMod( "kinetic_choke" )
						}
					}
					else if ( chargeTime == 0 )
					{
						weapon.RemoveMod( "kinetic_choke" )
						break
					}
				}
				WaitFrame()
			}
			//If Airborn, do nothing
			else if ( !player.IsOnGround() && !player.IsZiplining() && !weapon.HasMod ( "elevator_shooter" ) )
			{
				WaitFrame()
			}
			//If anything else, reset count
			else
			{
				if(weapon.HasMod("kinetic_choke"))
				{
					thread KineticLoaderChokeGraceWindow_ServerThink( player, weapon )
				}
				WaitFrame()
			}
		}
	#endif
}
void function KineticLoaderFunctionality_ServerThink( entity player, entity weapon )
{
	#if SERVER
		player.EndSignal( "OnDeath" )
		player.EndSignal( "OnDestroy" )
		weapon.EndSignal( END_KINETIC_LOADER )

		if (!IsValid( weapon ) || !IsValid( player ) )
			return

		string ammoType = AmmoType_GetRefFromIndex( weapon.GetWeaponAmmoPoolType() )
		int ammoPoolType = eAmmoPoolType[ ammoType ]

		LootData weaponLootData = SURVIVAL_Loot_GetLootDataByRef( weapon.GetWeaponClassName() )

		KineticLoaderSettings settings
		settings.loadDelay				 = GetWeaponInfoFileKeyField_GlobalFloat  ( weaponLootData.baseWeapon,  KINETIC_LOAD_DELAY_SETTING )
		settings.additiveDelay			 = GetWeaponInfoFileKeyField_GlobalFloat  ( weaponLootData.baseWeapon,  KINETIC_LOAD_ADDITIVE_DELAY_SETTING )
		settings.maxDelay				 = GetWeaponInfoFileKeyField_GlobalFloat  ( weaponLootData.baseWeapon,  KINETIC_LOAD_MAX_DELAY_SETTING )
		settings.ammoToLoad				 = GetWeaponInfoFileKeyField_GlobalInt    ( weaponLootData.baseWeapon,  KINETIC_AMMO_TO_LOAD_SETTING)
		settings.kineticLoaderSFX 		 = GetWeaponInfoFileKeyField_GlobalString ( weaponLootData.baseWeapon,  KINETIC_LOAD_SFX_SETTING)

		int loops
		float waitValue = settings.loadDelay
		int ammoToLoadTotal = 0

		bool isCrateWeap = SURVIVAL_GetLootDataFromWeapon( weapon ).baseMods.contains( WEAPON_LOCKEDSET_MOD_CRATE )

		while ( IsValid( weapon ) && IsValid( player ))
		{
			//If Sliding and onGround, reward 1 bullet, increase count, and delay next bullet reward
			if ( player.IsSliding() )
			{
				wait (waitValue)

				if (!IsValid( weapon ) || !IsValid( player ) )
					return

				bool infiniteAmmo = GetInfiniteAmmo( weapon )
				int ammoPoolCount = isCrateWeap ? weapon.GetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE ) : player.AmmoPool_GetCount( ammoPoolType )

				if ( player.IsSliding() && !weapon.IsReloading() && ( ( ammoPoolCount > 0 ) || infiniteAmmo ) )
				{
					//Adjust rounds loaded if gun is mostly full
					int ammoRequested = ( minint( weapon.GetWeaponPrimaryClipCountMax(), weapon.GetWeaponPrimaryClipCount() + settings.ammoToLoad ) - weapon.GetWeaponPrimaryClipCount() )

					//Adjust rounds loaded based on inventory
					int ammoToLoad = infiniteAmmo ? ammoRequested : minint (ammoPoolCount, ammoRequested )

					if ( weapon.GetWeaponPrimaryClipCountMax() > weapon.GetWeaponPrimaryClipCount() )
					{
						Weapon_FillClipAmmoFromStock (weapon, player, ammoToLoad)

						EmitSoundOnEntityOnlyToPlayer( player, player, settings.kineticLoaderSFX )

						if( weapon.GetWeaponPrimaryClipCount() == 1 && weapon.GetWeaponClassName() == "mp_weapon_energy_shotgun" )
						{
							weapon.ForceRechamberMilestone( 0 )
						}

						ammoToLoadTotal = ClampInt( (ammoToLoadTotal + ammoToLoad), 0, 31 )
						Remote_CallFunction_NonReplay( player, "ServerCallback_KineticLoaderReloadedThroughSlide", weapon,ammoToLoadTotal )

						//Increase delay
						loops++
						waitValue = Clamp( ( settings.loadDelay + (loops * settings.additiveDelay) ), 0, settings.maxDelay )
					}
				}
			}
			//If anything else, reset count
			else
			{
				if ( loops > 0 )
				{
					loops = 0
					Remote_CallFunction_NonReplay( player, "ServerCallback_KineticLoaderReloadedThroughSlideEnd", weapon )
				}
				waitValue = settings.loadDelay
				ammoToLoadTotal = 0
				WaitFrame()
			}
		}
	#endif
}
void function KineticLoaderChokeGraceWindow_ServerThink( entity player, entity weapon )
{
	#if SERVER
		player.EndSignal( "OnDeath" )
		player.EndSignal( "OnDestroy" )
		weapon.EndSignal( END_KINETIC_LOADER_CHOKE )
		const float KINETIC_LOADER_GRACE_WINDOW = 1.0
		float entryTime = Time()

		if (!IsValid( weapon ) || !IsValid( player ))
			return

		while ( IsValid( weapon ) && IsValid( player ) )
		{
			if ( !weapon.HasMod( "hopup_kinetic_choke") || !weapon.HasMod( KINETIC_LOADER_HOPUP ))
			{
				weapon.RemoveMod( "kinetic_choke" )
				break
			}

			if( !weapon.HasMod( "choke" ) && !weapon.HasMod( "kinetic_choke" ) )
			{
				if ( weapon.HasMod( "hopup_kinetic_choke") )
				{
					weapon.AddMod( "kinetic_choke" )
				}
			}

			if ( player.IsSliding() )
				break

			if ( Time() - entryTime > KINETIC_LOADER_GRACE_WINDOW )
			{
				if ( player.IsSliding() )
				{
					break
				}
				else
				{
					float chargeTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )

					if ( chargeTime > 0 )
					{
						if ( !weapon.IsWeaponCharging() )
						{
							if ( weapon.HasMod( "kinetic_choke" ) )
								weapon.RemoveMod( "kinetic_choke" )

							break
						}
					}
					else if ( chargeTime == 0 )
					{
						weapon.RemoveMod( "kinetic_choke" )
						break
					}

					WaitFrame()
				}
			}
			else
			{
				WaitFrame()
			}
		}
	#endif
}

#if SERVER
void function OnWeaponAttachmentChanged_CheckForKineticLoader( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if( !weapon.IsWeaponX() )
		return

	if ( weapon.HasMod ( KINETIC_LOADER_HOPUP ) && ( player.GetActiveWeapon( eActiveInventorySlot.mainHand ) == weapon) )
	{
		OnWeaponDeactivate_Kinetic_Loader ( weapon )

		OnWeaponActivate_Kinetic_Loader ( weapon )
	}

	if ( modToAdd == KINETIC_LOADER_HOPUP )
	{
		if ( weapon.HasMod( "choke" ) || weapon.HasMod( "kinetic_choke" ))
		{
			if( !weapon.HasMod( "hopup_kinetic_choke" ) )
				weapon.AddMod( "hopup_kinetic_choke" )
		}


	}
	else if ( modToRemove == KINETIC_LOADER_HOPUP )
	{
		weapon.RemoveMod( "hopup_kinetic_choke")
		weapon.RemoveMod( "kinetic_choke" )

		OnWeaponDeactivate_Kinetic_Loader ( weapon )
	}

}

#endif

#if CLIENT
void function ServerCallback_KineticLoaderReloadedThroughSlide( entity weapon, int ammoToLoadTotal )
{
	if ( !IsValid( weapon ) )
		return

	file.weaponReloadedThroughSlideTable[weapon] <- true
	file.weaponAmmoToLoadTotalTable[weapon] <- ammoToLoadTotal
}
void function ServerCallback_KineticLoaderReloadedThroughSlideEnd( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	if( weapon in file.weaponReloadedThroughSlideTable )
		delete file.weaponReloadedThroughSlideTable[ weapon ]

	if( weapon in file.weaponAmmoToLoadTotalTable )
		delete file.weaponAmmoToLoadTotalTable[ weapon ]
}
#endif

void function ApplyKineticLoader_ClientThink( entity player, entity weapon )
{
	#if CLIENT
		AssertIsNewThread()
		weapon.EndSignal( "OnDestroy" )
		weapon.EndSignal( END_KINETIC_LOADER_RUI )

		if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
			return

		player.EndSignal( "OnDeath" )

		vector lowAmmoColor      = SrgbToLinear( OVERLOADAMMO_UI_COLOR )
		vector normalAmmoColor   = SrgbToLinear( NORMALAMMO_UI_COLOR )

		var rui = ClWeaponStatus_GetWeaponHudRui( player )
		var crosshairRui = CreateCockpitPostFXRui( $"ui/ammo_status_hint.rpak", HUD_Z_BASE )

		OnThreadEnd(
			function() : ( player, weapon, crosshairRui )
			{
				RuiDestroy( crosshairRui )
				if( weapon in file.weaponReloadedThroughSlideTable )
					delete file.weaponReloadedThroughSlideTable[ weapon ]

				if( weapon in file.weaponAmmoToLoadTotalTable )
					delete file.weaponAmmoToLoadTotalTable[ weapon ]
			}
		)

		if (!IsValid( weapon ) || !IsValid( player ) )
			return


		string ammoTypeRef = AmmoType_GetRefFromIndex( weapon.GetWeaponAmmoPoolType() )
		asset ammoIcon = $""
		if ( SURVIVAL_Loot_IsRefValid( ammoTypeRef ) )
		{
			LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoTypeRef )
			ammoIcon = ammoData.hudIcon
		}

		// Get mag data
		string mod = GetInstalledWeaponAttachmentForPoint( weapon, "mag" )
		int magTier = 4
		asset magIcon = $""
		LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )

		if ( SURVIVAL_Loot_IsRefValid ( mod ) ) //Guard against R5DEV-370615
		{
			LootData magData = SURVIVAL_Loot_GetLootDataByRef( mod )
			magTier = magData.tier
			magIcon = magData.hudIcon
		}

		float UiStartTime = -1

		while ( IsValid( weapon ) && IsValid( player ))
		{
			int ammoToLoadTotal = 0
			bool reloadedThroughSlide = false

			if( weapon in file.weaponAmmoToLoadTotalTable )
				ammoToLoadTotal = file.weaponAmmoToLoadTotalTable[ weapon ]

			if( weapon in file.weaponReloadedThroughSlideTable )
				reloadedThroughSlide = file.weaponReloadedThroughSlideTable[ weapon ]

			if ( reloadedThroughSlide )
			{
				if( player.GetActiveWeapon( eActiveInventorySlot.mainHand ) == weapon  )
				{
					if( UiStartTime != -1 )
					{
						RuiSetFloat( rui, "passiveHoldTime", 0 )
					}

					string ammoToLoadSting = Localize( "#WPN_HOPUP_KINETIC_LOADER_RELOAD_HINT", ammoToLoadTotal )
					RuiSetString( crosshairRui, "ammoToLoadString", ammoToLoadSting )
					RuiSetFloat3( rui, "ammoGlowColor", lowAmmoColor )
					RuiSetBool( crosshairRui, "showKineticReloadText", true )
					RuiSetBool( crosshairRui, "showHopupKineticReloadBG", true )

				}
				else
				{
					if( UiStartTime == -1 )
					{
						UiStartTime = Time()
						RuiSetFloat3( rui, "ammoGlowColor", normalAmmoColor )
						RuiSetBool( crosshairRui, "showKineticReloadText", false )
						RuiSetBool( crosshairRui, "showHopupKineticReloadBG", false )
					}

					RuiSetString( rui, "passiveDesc", Localize( "#WPN_HOPUP_KINETIC_LOADER_RELOAD_HINT", ammoToLoadTotal ) )
					RuiSetImage( rui, "passiveMagIcon", magIcon )
					RuiSetImage( rui, "passiveIcon", weapon.GetWeaponSettingAsset( eWeaponVar.hud_icon ) )
					RuiSetImage( rui, "passiveAmmoIcon", ammoIcon )
					RuiSetInt( rui, "passiveTier", magTier )
					RuiSetInt( rui, "passiveAltTier", weaponData.tier )
					RuiSetBool( rui, "displayPassiveBonusPopup", !GetCurrentPlaylistVarBool( "hud_hide_infopopup", false ) )

					float timeDiff = Time() - UiStartTime // used to extend the time the notifcation stays on the screen
					RuiSetGameTime( rui, "passiveActivationTime", UiStartTime )
					RuiSetFloat( rui, "passiveHoldTime", max( timeDiff, 3.0 ) )

				}
			}
			else
			{
				UiStartTime = -1

				RuiSetFloat3( rui, "ammoGlowColor", normalAmmoColor )
				RuiSetBool( crosshairRui, "showKineticReloadText", false )
				RuiSetBool( crosshairRui, "showHopupKineticReloadBG", false )
			}

			WaitFrame()
		}
	#endif
}

                          
                                                   
 
                          
        

                                                                
                                                             

                        
        

                                            
   
                                             
                                                                               
                                               
                                                

                                              
                                                                                                                                                     

                                           
                                                                
                                                                                        

                                                                                                      
   
                             
                       
                                                                          

                        
                                                                                      

             
                                                                                            
                                                                          
         
   
  

 


                                              
 
           
                                           
                                                                                  
       
 
      

//INFINITE AMMO
#if SERVER || CLIENT
bool function GetInfiniteAmmo( entity weapon )
{
	return weapon.GetInfiniteAmmoState() != INFINITEAMMO_NONE
}

#if SERVER
bool function SetInfiniteAmmoForWeapon( entity player, entity weapon, bool ornull infiniteAmmo = null, bool removeOnDrop = true, bool forceApply = false )
{
	if ( !IsValidPlayer( player ) || ! IsValid( weapon ) || !weapon.IsWeaponX() )
		return false

	return SetInfiniteAmmoForWeapon_Internal( player, weapon, infiniteAmmo, removeOnDrop, forceApply )
}

bool function SetInfiniteAmmoForPlayer( entity player, bool infiniteAmmo, array<string> exceptTags = [], bool removeOnDrop = true, bool applyImmediately = false, bool forceApply = false )
{
	if ( !IsValidPlayer( player ) )
		return false

	player.p.infiniteAmmo           = infiniteAmmo
	player.p.infiniteAmmoExceptTags = exceptTags

	if ( applyImmediately )
	{
		return SetInfiniteAmmoForMainWeapons_Internal( player, player.p.infiniteAmmo, removeOnDrop, forceApply )
	}

	return player.p.infiniteAmmo
}

bool function SetInfiniteAmmoForGameMode( entity player, bool infiniteAmmo, array<string> exceptTags = [], bool removeOnDrop = true, bool applyImmediately = false, bool forceApply = false )
{
	if ( !IsValidPlayer( player ) )
		return false

	player.p.infiniteGameModeAmmo           = infiniteAmmo
	player.p.infiniteGameModeAmmoExceptTags = exceptTags

	if ( applyImmediately )
		return SetInfiniteAmmoForMainWeapons_Internal( player, player.p.infiniteGameModeAmmo, removeOnDrop, forceApply )

	return player.p.infiniteGameModeAmmo

}

bool function SetInfiniteAmmoForMainWeapons_Internal( entity player, bool infiniteAmmo, bool removeOnDrop, bool forceApply )
{
	bool result = infiniteAmmo
	const int[3] PRIMARY_SLOTS_TO_CHECK = [ WEAPON_INVENTORY_SLOT_PRIMARY_0, WEAPON_INVENTORY_SLOT_PRIMARY_1, SLING_WEAPON_SLOT ]

	foreach ( int slot in PRIMARY_SLOTS_TO_CHECK )
	{
		entity weapon = player.GetNormalWeapon( slot )
		if ( ! IsValid( weapon ) || !weapon.IsWeaponX() )
			continue
		result = SetInfiniteAmmoForWeapon_Internal( player, weapon, infiniteAmmo, removeOnDrop, forceApply ) && result
	}
	return result //false if all main weapons do not have infinite ammo, true if all main weapons have infinite ammo
}

bool function SetInfiniteAmmoForWeapon_Internal( entity player, entity weapon, bool ornull infiniteAmmo, bool removeOnDrop, bool forceApply )
{
	#if DEVELOPER
		InfiniteAmmo_PrintWeaponValues( weapon )
	#endif

	string weaponClass = weapon.GetWeaponClassName()

	//Generally, we want the rules here, but there may be a rare case where we want to skip them
	if ( !forceApply )
	{
		bool isCrateWeapon = weapon.HasMod( "crate" )

		bool alwaysInfiniteAmmo = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "alwaysInfiniteAmmo" ) )
		bool neverInfiniteAmmo  = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "neverInfiniteAmmo" ) )
		bool crateInfiniteAmmo  = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "crateInfiniteAmmo" ) )

		LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )

		//Game Mode Infinite Ammo
		if ( player.p.infiniteGameModeAmmo )
		{
			//Test for infinite ammo exception rules....
			if ( WeaponHasInfiniteAmmoException( weapon, weaponData, player.p.infiniteGameModeAmmoExceptTags ) )
				infiniteAmmo = false
			else
				infiniteAmmo = true
		}

		//Player Infinite Ammo has authority on the game mode setting if we have it
		if ( player.p.infiniteAmmo )
		{
			//Test for infinite ammo exception rules....
			if ( WeaponHasInfiniteAmmoException( weapon, weaponData, player.p.infiniteAmmoExceptTags ) )
				infiniteAmmo = false
			else
				infiniteAmmo = true
		}

		if ( alwaysInfiniteAmmo )
		{
			//If weapon is set to not have infinite ammo if a crate weapon, take away infiniteAmmo
			if ( isCrateWeapon && !crateInfiniteAmmo )
				infiniteAmmo = false
			else //Otherwise we always want infinite ammo on this weapon
				infiniteAmmo = true
		}

		//If we never want infinite ammo on this weapon, take away infiniteAmmo
		if ( neverInfiniteAmmo )
			infiniteAmmo = false

		//No preference, use defaults on weapon
		if ( infiniteAmmo == null )
		{
			if ( GetInfiniteAmmo( weapon ) )
			{
				//If it already has infinite ammo, don't take it away when we drop it again
				removeOnDrop = false
				infiniteAmmo = true
			}
			else
				infiniteAmmo = false
		}
	}
	else
	{
		//If we force apply but haven't set a value, default to false
		if ( infiniteAmmo == null )
		{
			infiniteAmmo = false
		}
	}

	bool usesAmmoPool     = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "uses_ammo_pool" ) )
	bool usesClipsForAmmo = weapon.UsesClipsForAmmo()

	weapon.SetInfiniteAmmoState( infiniteAmmo ? INFINITEAMMO_CLIPS : INFINITEAMMO_NONE )

	weapon.w.infiniteAmmoSaveStateOnDrop = !removeOnDrop

	Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )

	return expect bool(infiniteAmmo)
}

bool function WeaponHasInfiniteAmmoException( entity weapon, LootData weaponData, array<string> tags )
{
	Assert( IsValid( weapon ), "Trying to test infinite ammo tags on invalid weapon" )

	foreach ( string tag in tags )
	{
		//Tests for locked sets + gun names
		if ( weaponData.ref.find( tag ) >= 0 )
			return true

		//Tests for weapon mods (crate)
		if ( weaponData.baseMods.contains( tag ) )
			return true

		//Tests for loot tags
		if ( weaponData.lootTags.contains( tag ) )
			return true
	}

	return false
}


#if DEVELOPER
void function DEV_TestSetInfiniteAmmo( entity player, bool infiniteAmmo, bool removeOnDrop, bool forceApply )
{
	SetInfiniteAmmoForMainWeapons_Internal( player, infiniteAmmo, removeOnDrop, forceApply )
}

void function InfiniteAmmo_PrintWeaponValues( entity weapon )
{
	string weaponClass = weapon.GetWeaponClassName()
	printt ( "Infinite Ammo Settings For " + weaponClass )
	bool alwaysInfiniteAmmo = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "alwaysInfiniteAmmo" ) )
	bool neverInfiniteAmmo  = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "neverInfiniteAmmo" ) )
	bool crateInfiniteAmmo  = bool ( GetWeaponInfoFileKeyField_Global( weaponClass, "crateInfiniteAmmo" ) )
	printt( "alwaysInfiniteAmmo			" + alwaysInfiniteAmmo )
	printt( "neverInfiniteAmmo			" + neverInfiniteAmmo )
	printt( "crateInfiniteAmmo			" + crateInfiniteAmmo )
	printt( "hasInfiniteAmmo			" + GetInfiniteAmmo( weapon ) )
}
#endif

#endif

#endif//INFINITE AMMO

bool function CodeCallback_GetIsModOptic( entity weapon, string modName )
{
	return SURVIVAL_Loot_IsRefValid( weapon.GetWeaponClassName() ) && SURVIVAL_Loot_IsRefValid( modName ) && GetAttachPointForAttachmentOnWeapon( weapon.GetWeaponClassName(), modName ) == "sight"
}

// Legacy S3 functions restored

#if SERVER
void function AddActiveThermiteBurn( entity ent )
{
	AddToScriptManagedEntArray( file.activeThermiteBurnsManagedEnts, ent )
}
#endif

#if SERVER
void function EMPGrenade_EffectsPlayer( entity player, var damageInfo )

{

	if( Flowstate_IsHaloMode() )

		return



	player.Signal( "OnEMPPilotHit" )

	player.EndSignal( "OnEMPPilotHit" )



	if ( player.IsPhaseShifted() )

		return



	entity inflictor   = DamageInfo_GetInflictor( damageInfo )

	float dist         = Distance( DamageInfo_GetDamagePosition( damageInfo ), player.GetWorldSpaceCenter() )

	float damageRadius = 128

	if ( inflictor instanceof CBaseGrenade )

		damageRadius = inflictor.GetDamageRadius()

	float frac            = GraphCapped( dist, damageRadius * 0.5, damageRadius, 1.0, 0.0 )

	float strength        = EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN + ((EMP_GRENADE_PILOT_SCREEN_EFFECTS_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN) * frac)

	float fadeoutDuration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_FADE * frac

	float duration        = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN + ((EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN) * frac) - fadeoutDuration

	//vector origin = inflictor.GetOrigin()



	int dmgSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	//if ( dmgSource == eDamageSourceId.mp_weapon_proximity_mine || dmgSource == eDamageSourceId.mp_titanweapon_stun_laser )

		//strength *= 0.1



	if( dmgSource == eDamageSourceId.mp_weapon_tesla_trap )

		duration = 3



	if ( player.IsTitan() )

	{

		// Hit player should do EMP screen effects locally

		Remote_CallFunction_Replay( player, "ServerCallback_TitanCockpitEMP", duration )



		EMPGrenade_AffectsShield( player, damageInfo )

	}

	else

	{

		if ( IsCloaked( player ) )

			player.SetCloakFlicker( 0.5, duration )



		// duration = 0

		// fadeoutDuration = 0



		//DamageInfo_SetDamage( damageInfo, 0 )

	}



	StatusEffect_AddTimed( player, eStatusEffect.emp, strength, duration, fadeoutDuration )

	GiveEMPStunStatusEffects( player, (duration + fadeoutDuration), fadeoutDuration )



	EmitSoundOnEntityOnlyToPlayer( player, player, "Arcstar_visualimpair" )

}
#endif


entity function GetPlayerFromTitanWeapon( entity weapon )

{

	entity titan = weapon.GetWeaponOwner()

	entity player



	if ( titan == null )

		return null



	if ( !titan.IsPlayer() )

		player = titan.GetBossPlayer()

	else

		player = titan



	return player

}




#if SERVER
void function PROTO_PlayTrapLightEffect( entity ent, string tag, int team )

{

	asset ownerFx = ent.ProjectileGetWeaponInfoFileKeyFieldAsset( "trap_warning_owner_fx" )

	if ( ownerFx != $"" )

	{

		entity ownerFxEnt = CreateServerEffect_Owner( ownerFx, ent.GetOwner() )

		SetServerEffectControlPoint( ownerFxEnt, 0, FRIENDLY_COLOR )

		StartServerEffectOnEntity( ownerFxEnt, ent, tag )

	}



	asset friendlyFx = ent.ProjectileGetWeaponInfoFileKeyFieldAsset( "trap_warning_friendly_fx" )

	if ( friendlyFx != $"" )

	{

		entity friendlyFxEnt = CreateServerEffect_Friendly( friendlyFx, team )

		SetServerEffectControlPoint( friendlyFxEnt, 0, FRIENDLY_COLOR_FX )

		StartServerEffectOnEntity( friendlyFxEnt, ent, tag )

	}



	asset enemyFx = ent.ProjectileGetWeaponInfoFileKeyFieldAsset( "trap_warning_enemy_fx" )

	if ( enemyFx != $"" )

	{

		entity enemyFxEnt = CreateServerEffect_Enemy( enemyFx, team )

		SetServerEffectControlPoint( enemyFxEnt, 0, ENEMY_COLOR_FX )

		StartServerEffectOnEntity( enemyFxEnt, ent, tag )

	}

}
#endif


void function ProximityCharge_PostFired_Init( entity proximityMine, entity player )

{

	#if SERVER

		proximityMine.proj.onlyAllowSmartPistolDamage = false

	#endif

}


#if SERVER
void function Satchel_PostFired_Init( entity satchel, entity player )
{
	satchel.proj.onlyAllowSmartPistolDamage = false
	thread SatchelThink( satchel, player )
}
#endif


#if SERVER
void function SetPlayerCooldowns( entity player, array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_RIGHT ] )

{

	if ( player.IsTitan() )

		return



	foreach ( index in offhandIndices )

	{

		float lastUseTime    = player.p.lastPilotOffhandUseTime[ index ]

		float lastChargeFrac = player.p.lastPilotOffhandChargeFrac[ index ]

		float lastClipFrac   = player.p.lastPilotClipFrac[ index ]



		// if ( lastUseTime >= 0.0 )

		{

			entity weapon = player.GetOffhandWeapon( index )

			if ( !IsValid( weapon ) )

				continue



			string weaponClassName = weapon.GetWeaponClassName()



			switch ( weapon.GetWeaponSettingEnum( eWeaponVar.cooldown_type, eWeaponCooldownType ) )

			{

				case eWeaponCooldownType.grapple:

					// GetPlayerSettingsField isn't working for moddable fields? - Bug 129567

					float powerRequired = 100.0 // GetPlayerSettingsField( "grapple_power_required" )

					float regenRefillDelay = 3.0 // GetPlayerSettingsField( "grapple_power_regen_delay" )

					float regenRefillRate = 5.0 // GetPlayerSettingsField( "grapple_power_regen_rate" )

					float suitPowerToRestore = powerRequired - player.p.lastSuitPower

					float regenRefillTime = suitPowerToRestore / regenRefillRate



					float regenStartTime = lastUseTime + regenRefillDelay



					float newSuitPower = GraphCapped( Time() - regenStartTime, 0.0, regenRefillTime, player.p.lastSuitPower, powerRequired )



					player.SetSuitGrapplePower( newSuitPower )

					break



				case eWeaponCooldownType.ammo:

				case eWeaponCooldownType.ammo_instant:

				case eWeaponCooldownType.ammo_deployed:

				case eWeaponCooldownType.ammo_timed:

					int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()



					if ( maxAmmo > 0 )

					{

						float fireDuration     = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )

						float regenRefillDelay = weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_start_delay )

						float regenRefillRate  = weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_rate )



						if ( regenRefillRate == 0 )

						{

							if( weapon.GetWeaponSettingBool( eWeaponVar.grapple_weapon ) )

							{

								weapon.SetWeaponPrimaryClipCount( 0 )

								if( weapon.HasMod( "grapple_regen_stop" ) )

									weapon.RemoveMod( "grapple_regen_stop" )

								weapon.RegenerateAmmoReset()

							}

							continue

						}



						int startingClipCount = int( lastClipFrac * maxAmmo )

						int ammoToRestore     = maxAmmo - startingClipCount

						float regenRefillTime = ammoToRestore / regenRefillRate



						float regenStartTime = lastUseTime + fireDuration + regenRefillDelay



						int newAmmo = int( GraphCapped( Time() - regenStartTime, 0.0, regenRefillTime, startingClipCount, maxAmmo ) )



						weapon.SetWeaponPrimaryClipCountAbsolute( newAmmo )

					}

					break



				case eWeaponCooldownType.chargeFrac:

					float chargeCooldownDelay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )

					float chargeCooldownTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_time )

					float regenRefillTime = lastChargeFrac * chargeCooldownTime

					float regenStartTime = lastUseTime + chargeCooldownDelay



					float newCharge = GraphCapped( Time() - regenStartTime, 0.0, regenRefillTime, lastChargeFrac, 0.0 )



					weapon.SetWeaponChargeFraction( newCharge )

					break



				default:

					printt( weaponClassName + " needs to be updated to support cooldown_type setting" )

					break

			}

		}

	}

}
#endif


#if SERVER
void function StartClusterExplosions( entity projectile, entity owner, PopcornInfo popcornInfo, string customFxTable = "" )

{

	Assert( IsValid( owner ) )

	owner.EndSignal( "OnDestroy" )



	string weaponName = popcornInfo.weaponName

	float innerRadius

	float outerRadius

	int explosionDamage

	int explosionDamageHeavyArmor



	innerRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosion_inner_radius )

	outerRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius )

	if ( owner.IsPlayer() )

	{

		explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage )

		explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor )

	}

	else

	{

		explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage )

		explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage_heavy_armor )

	}



	local explosionDelay = projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_explosion_delay" )



	if ( owner.IsPlayer() )

		owner.EndSignal( "OnDestroy" )



	vector origin = projectile.GetOrigin()



	vector rotateFX        = <90, 0, 0>

	entity placementHelper = CreateScriptMover("")

	placementHelper.SetOrigin( origin )

	placementHelper.SetAngles( VectorToAngles( popcornInfo.normal ) )

	SetTeam( placementHelper, owner.GetTeam() )



	array<entity> players = GetPlayerArray()

	foreach ( player in players )

		Remote_CallFunction_NonReplay( player, "SCB_AddGrenadeIndicatorForEntity", owner, placementHelper, outerRadius )



	int particleSystemIndex = GetParticleSystemIndex( CLUSTER_BASE_FX )

	int attachId            = placementHelper.LookupAttachment( "REF" )

	entity fx



	if ( popcornInfo.hasBase )

	{

		fx = StartParticleEffectOnEntity_ReturnEntity( placementHelper, particleSystemIndex, FX_PATTACH_POINT_FOLLOW, attachId )

		EmitSoundOnEntity( placementHelper, "Explo_ThermiteGrenade_Impact_3P" ) // TODO: wants a custom sound

	}



	OnThreadEnd(

		function() : ( fx, placementHelper )

		{

			if ( IsValid( fx ) )

				EffectStop( fx )

			placementHelper.Destroy()

		}

	)



	if ( explosionDelay )

		wait explosionDelay



	waitthread ClusterRocketBursts( origin, explosionDamage, explosionDamageHeavyArmor, innerRadius, outerRadius, owner, popcornInfo, customFxTable )



	if ( IsValid( projectile ) )

		projectile.Destroy()

}
#endif // SERVER


#if SERVER
void function WeaponAttackWave( entity ent, int projectileCount, entity inflictor, vector pos, vector dir, bool functionref( entity, int, entity, entity, vector, vector, int ) waveFunc )

{

	ent.EndSignal( "OnDestroy" )



	entity weapon

	entity projectile

	int maxCount

	float step

	entity owner

	int damageNearValueTitanArmor

	int count       = 0

	vector lastDownPos

	bool firstTrace = true



	dir.z = 0

	dir = Normalize( dir )

	vector angles = VectorToAngles( dir )



	if ( ent.IsProjectile() )

	{

		projectile = ent

		string chargedPrefix = ""

		if ( ent.proj.isChargedShot )

			chargedPrefix = "charge_"



		maxCount = expect int( ent.ProjectileGetWeaponInfoFileKeyField( chargedPrefix + "wave_max_count" ) )

		step = expect float( ent.ProjectileGetWeaponInfoFileKeyField( chargedPrefix + "wave_step_dist" ) )

		owner = ent.GetOwner()

		damageNearValueTitanArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )

	}

	else

	{

		weapon = ent

		maxCount = expect int( ent.GetWeaponInfoFileKeyField( "wave_max_count" ) )

		step = expect float( ent.GetWeaponInfoFileKeyField( "wave_step_dist" ) )

		owner = ent.GetWeaponOwner()

		damageNearValueTitanArmor = weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )

	}



	owner.EndSignal( "OnDestroy" )



	for ( int i = 0; i < maxCount; i++ )

	{

		vector newPos = pos + dir * step



		vector traceStart    = pos

		vector traceEndUnder = newPos

		vector traceEndOver  = newPos



		if ( !firstTrace )

		{

			traceStart = lastDownPos + <0, 0, 80>

			traceEndUnder = <newPos.x, newPos.y, traceStart.z - 40>

			traceEndOver = <newPos.x, newPos.y, traceStart.z + step * 0.57735056839> // The over height is to cover the case of a sheer surface that then continues gradually upwards (like mp_box)

		}

		firstTrace = false



		VortexBulletHit ornull vortexHit = VortexBulletHitCheck( owner, traceStart, traceEndOver )

		if ( vortexHit )

		{

			expect VortexBulletHit( vortexHit )

			entity vortexWeapon = vortexHit.vortex.GetOwnerWeapon()



			if ( vortexWeapon && vortexWeapon.GetWeaponClassName() == "mp_titanweapon_vortex_shield" )

				VortexDrainedByImpact( vortexWeapon, weapon, projectile ) // drain the vortex shield

			else if ( IsVortexSphere( vortexHit.vortex ) )

				VortexSphereDrainHealthForDamage( vortexHit.vortex, damageNearValueTitanArmor )



			WaitFrame()

			continue

		}



		//DebugDrawLine( traceStart, traceEndUnder, 0, 255, 0, true, 25.0 )

		array ignoreArray = []

		if ( IsValid( inflictor ) && inflictor.GetOwner() != null )

			ignoreArray.append( inflictor.GetOwner() )



		TraceResults forwardTrace = TraceLine( traceStart, traceEndUnder, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		if ( forwardTrace.fraction == 1.0 )

		{

			//DebugDrawLine( forwardTrace.endPos, forwardTrace.endPos + <0,0,-1000>, 255, 0, 0, true, 25.0 )

			TraceResults downTrace = TraceLine( forwardTrace.endPos, forwardTrace.endPos + <0, 0, -1000>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			if ( downTrace.fraction == 1.0 )

				break



			entity movingGeo = null

			if ( downTrace.hitEnt && downTrace.hitEnt.HasPusherAncestor() && !downTrace.hitEnt.IsMarkedForDeletion() )

				movingGeo = downTrace.hitEnt



			if ( !waveFunc( ent, projectileCount, inflictor, movingGeo, downTrace.endPos, angles, i ) )

				return



			lastDownPos = downTrace.endPos

			pos = forwardTrace.endPos



			WaitFrame()

			continue

		}

		else

		{

			if ( IsValid( forwardTrace.hitEnt ) && (StatusEffect_GetSeverity( forwardTrace.hitEnt, eStatusEffect.pass_through_amps_weapon ) > 0) && !CheckPassThroughDir( forwardTrace.hitEnt, forwardTrace.surfaceNormal, forwardTrace.endPos ) )

				break

		}



		TraceResults upwardTrace = TraceLine( traceStart, traceEndOver, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		//DebugDrawLine( traceStart, traceEndOver, 0, 0, 255, true, 25.0 )

		if ( upwardTrace.fraction < 1.0 )

		{

			if ( IsValid( upwardTrace.hitEnt ) )

			{

				if ( upwardTrace.hitEnt.IsWorld() || upwardTrace.hitEnt.IsPlayer() || upwardTrace.hitEnt.IsNPC() )

					break

			}

		}

		else

		{

			TraceResults downTrace = TraceLine( upwardTrace.endPos, upwardTrace.endPos + <0, 0, -1000>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			if ( downTrace.fraction == 1.0 )

				break



			entity movingGeo = null

			if ( downTrace.hitEnt && downTrace.hitEnt.HasPusherAncestor() && !downTrace.hitEnt.IsMarkedForDeletion() )

				movingGeo = downTrace.hitEnt



			if ( !waveFunc( ent, projectileCount, inflictor, movingGeo, downTrace.endPos, angles, i ) )

				return



			lastDownPos = downTrace.endPos

			pos = forwardTrace.endPos

		}



		WaitFrame()

	}

}
#endif // SERVER WeaponAttackWave


array<entity> function FireExpandContractMissiles( entity weapon, WeaponPrimaryAttackParams attackParams, vector attackPos, vector attackDir, int damageType, int explosionDamageType, bool shouldPredict, int rocketsPerShot, missileSpeed, launchOutAng, launchOutTime, launchInAng, launchInTime, launchInLerpTime, launchStraightLerpTime, applyRandSpread, int burstFireCountOverride = -1, debugDrawPath = false )

{

	array<table> missileVecs = GetExpandContractRocketTrajectories( weapon, attackParams.burstIndex, attackPos, attackDir, rocketsPerShot, launchOutAng, launchInAng, burstFireCountOverride )

	entity owner             = weapon.GetWeaponOwner()

	array<entity> firedMissiles



	vector missileEndPos = owner.EyePosition() + (attackDir * 5000)



	for ( int i = 0; i < rocketsPerShot; i++ )

	{

		WeaponFireMissileParams fireMissileParams

		fireMissileParams.pos = attackPos

		fireMissileParams.dir = attackDir

		fireMissileParams.speed = expect float( missileSpeed )

		fireMissileParams.scriptTouchDamageType = damageType

		fireMissileParams.scriptExplosionDamageType = explosionDamageType

		fireMissileParams.doRandomVelocAndThinkVars = false

		fireMissileParams.clientPredicted = shouldPredict

		entity missile = weapon.FireWeaponMissile( fireMissileParams )



		if ( missile )

		{

			/*

			missile.s.flightData <- {

								launchOutVec = missileVecs[i].outward,

								launchOutTime = launchOutTime,

								launchInLerpTime = launchInLerpTime,

								launchInVec = missileVecs[i].inward,

								launchInTime = launchInTime,

								launchStraightLerpTime = launchStraightLerpTime,

								endPos = missileEndPos,

								applyRandSpread = applyRandSpread

							}

			*/



			missile.InitMissileExpandContract( missileVecs[i].outward, missileVecs[i].inward, launchOutTime, launchInLerpTime, launchInTime, launchStraightLerpTime, missileEndPos, applyRandSpread )



			if ( IsServer() && debugDrawPath )

				thread DebugDrawMissilePath( missile )



			//InitMissileForRandomDrift( missile, attackPos, attackDir )

			missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )



			firedMissiles.append( missile )

		}

	}



	return firedMissiles

}


array<entity> function GetActiveThermiteBurnsWithinRadius( vector origin, float dist, int team = TEAM_ANY )
{
	#if SERVER
		return GetScriptManagedEntArrayWithinCenter( file.activeThermiteBurnsManagedEnts, team, origin, dist )
	#else
		return []
	#endif
}


array<entity> function GetPrimaryWeapons( entity player )

{

	array<entity> primaryWeapons

	array<entity> weapons = player.GetMainWeapons()

	foreach ( weaponEnt in weapons )

	{

		int weaponType = weaponEnt.GetWeaponType()

		if ( weaponType == WT_SIDEARM || weaponType == WT_ANTITITAN )

			continue



		primaryWeapons.append( weaponEnt )

	}

	return primaryWeapons

}


RadiusDamageData function GetRadiusDamageDataFromProjectile( entity projectile, entity owner )

{

	RadiusDamageData radiusDamageData



	radiusDamageData.explosionDamage = -1

	radiusDamageData.explosionDamageHeavyArmor = -1



	if ( owner.IsNPC() )

	{

		radiusDamageData.explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage )

		radiusDamageData.explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage_heavy_armor )

	}



	if ( radiusDamageData.explosionDamage == -1 )

		radiusDamageData.explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage )



	if ( radiusDamageData.explosionDamageHeavyArmor == -1 )

		radiusDamageData.explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor )



	radiusDamageData.explosionRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius )

	radiusDamageData.explosionInnerRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosion_inner_radius )



	Assert( radiusDamageData.explosionRadius > 0, "Created RadiusDamageData with 0 radius" )

	Assert( radiusDamageData.explosionDamage > 0 || radiusDamageData.explosionDamageHeavyArmor > 0, "Created RadiusDamageData with 0 damage" )

	return radiusDamageData

}


array<string> function GetWeaponBurnMods( string weaponClassName )

{

	array<string> burnMods = []

	array<string> mods     = GetWeaponMods_Global( weaponClassName )

	string prefix          = "burn_mod"

	foreach ( mod in mods )

	{

		if ( mod.find( prefix ) == 0 )

			burnMods.append( mod )

	}



	return burnMods

}


array<string> function GetWeaponModsFromDamageInfo( var damageInfo )

{

	entity weapon    = DamageInfo_GetWeapon( damageInfo )

	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	int damageType   = DamageInfo_GetCustomDamageType( damageInfo )



	if ( IsValid( weapon ) )

	{

		return weapon.GetMods()

	}

	else if ( IsValid( inflictor ) )

	{

		if ( "weaponMods" in inflictor.s && inflictor.s.weaponMods )

		{

			array<string> temp

			foreach ( string mod in inflictor.s.weaponMods )

			{

				temp.append( mod )

			}



			return temp

		}

		else if ( inflictor.IsProjectile() )

			return inflictor.ProjectileGetMods()

		else if ( damageType & DF_EXPLOSION && inflictor.IsPlayer() && IsValid( inflictor.GetActiveWeapon( eActiveInventorySlot.mainHand ) ) )

			return inflictor.GetActiveWeapon( eActiveInventorySlot.mainHand ).GetMods()

		//Hack - Splash damage doesn't pass mod weapon through. This only works under the assumption that offhand weapons don't have mods.

	}

	return []

}


#if SERVER
void function SatchelThink( entity satchel, entity player )

{

	player.EndSignal( "OnDestroy" )

	satchel.EndSignal( "OnDestroy" )



	int satchelHealth = 15

	thread TrapExplodeOnDamage( satchel, satchelHealth )



	#if DEVELOPER

		// temp HACK for FX to use to figure out the size of the particle to play

		if ( Flag( "ShowExplosionRadius" ) )

			thread ShowExplosionRadiusOnExplode( satchel )

	#endif



	player.EndSignal( "OnDeath" )



	OnThreadEnd(

		function() : ( satchel )

		{

			if ( IsValid( satchel ) )

			{

				satchel.Destroy()

			}

		}

	)



	WaitForever()

}

bool function IsValidSatchel( entity satchel )

{

	if ( satchel.ProjectileGetWeaponClassName() != "mp_weapon_satchel" )

		return false



	if ( satchel.e.isDisabled == true )

		return false



	return true

}
#endif // SERVER SatchelThink + IsValidSatchel

#if CLIENT
void function ServerCallback_SatchelPlanted()
{
	entity player = GetLocalViewPlayer()
	thread SatchelDetonationHint( player )
}

void function SatchelDetonationHint( entity player )

{

	player.EndSignal( "OnDeath" )

	player.EndSignal( "DetonateSatchels" )



	OnThreadEnd(

		function() : ( player )

		{

			if ( IsValid( player ) )

				SatchelDetonationHint_Destroy( player )

		}

	)



	string satchelClassName = "mp_weapon_satchel"



	if ( SHOW_SATCHEL_DETONATION_HINT_WITH_CLACKER )

		SatchelDetonationHint_Show( player )



	while ( PlayerHasWeapon( player, satchelClassName ) )

	{

		wait 0.1



		if ( !SHOW_SATCHEL_DETONATION_HINT_WITH_CLACKER )

		{

			// only show when detonator isn't actively held

			if ( player.GetActiveWeapon( OFFHAND_ORDNANCE ).GetWeaponClassName() != satchelClassName )

			{

				SatchelDetonationHint_Show( player )

			}

			else

			{

				SatchelDetonationHint_Destroy( player )

			}

		}

	}

}

void function SatchelDetonationHint_Show( entity player )

{

	if ( file.satchelHintRUI != null )

		return



	SatchelDetonationHint_Destroy( player )



	int sorting = 0

	file.satchelHintRUI = RuiCreate( $"ui/satchel_detonation_hint.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, sorting )

}

void function SatchelDetonationHint_Destroy( entity player )

{

	if ( file.satchelHintRUI != null )

		RuiDestroyIfAlive( file.satchelHintRUI )



	file.satchelHintRUI = null

}
#endif // CLIENT


array<table> function GetExpandContractRocketTrajectories( entity weapon, int burstIndex, vector attackPos, vector attackDir, int rocketsPerShot, launchOutAng, launchInAng, int burstFireCount = -1 )

{

	bool DEBUG_DRAW_MATH = false



	if ( burstFireCount == -1 )

		burstFireCount = weapon.GetWeaponBurstFireCount()



	float additionalRotation = ((360.0 / rocketsPerShot) / burstFireCount) * burstIndex

	//printt( "burstIndex:", burstIndex )

	//printt( "rocketsPerShot:", rocketsPerShot )

	//printt( "burstFireCount:", burstFireCount )



	vector ang     = VectorToAngles( attackDir )

	vector forward = AnglesToForward( ang )

	vector right   = AnglesToRight( ang )

	vector up      = AnglesToUp( ang )



	if ( DEBUG_DRAW_MATH )

		DebugDrawLine( attackPos, attackPos + (forward * 1000), 255, 0, 0, true, 30.0 )



	// Create points on circle

	float offsetAng = 360.0 / rocketsPerShot

	for ( int i = 0; i < rocketsPerShot; i++ )

	{

		float a    = offsetAng * i + additionalRotation

		vector vec = <0, 0, 0>

		vec += up * deg_sin( a )

		vec += right * deg_cos( a )



		if ( DEBUG_DRAW_MATH )

			DebugDrawLine( attackPos, attackPos + (vec * 50), 10, 10, 10, true, 30.0 )

	}



	// Create missile points

	vector x  = right * deg_sin( launchOutAng )

	vector y  = up * deg_sin( launchOutAng )

	vector z  = forward * deg_cos( launchOutAng )

	vector rx = right * deg_sin( launchInAng )

	vector ry = up * deg_sin( launchInAng )

	vector rz = forward * deg_cos( launchInAng )

	array<table> missilePoints

	for ( int i = 0; i < rocketsPerShot; i++ )

	{

		table points



		// Outward vec

		float a       = offsetAng * i + additionalRotation

		float s       = deg_sin( a )

		float c       = deg_cos( a )

		vector vecOut = z + x * c + y * s

		vecOut = Normalize( vecOut )

		points.outward <- vecOut



		// Inward vec

		vector vecIn = rz + rx * c + ry * s

		points.inward <- vecIn



		// Add to array

		missilePoints.append( points )



		if ( DEBUG_DRAW_MATH )

		{

			DebugDrawLine( attackPos, attackPos + (vecOut * 50), 255, 255, 0, true, 30.0 )

			DebugDrawLine( attackPos + vecOut * 50, attackPos + vecOut * 50 + (vecIn * 50), 255, 0, 255, true, 30.0 )

		}

	}



	return missilePoints

}

