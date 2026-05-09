untyped

global function MpWeaponTrophy_Init
global function OnWeaponAttemptOffhandSwitch_weapon_trophy_defense_system

global function OnWeaponActivate_weapon_trophy_defense_system
global function OnWeaponDeactivate_weapon_trophy_defense_system
global function OnWeaponPrimaryAttack_weapon_trophy_defense_system

#if SERVER
global function Trophy_RemoteTryZapProjectile
global function Trophy_RemoteTryZapEntity
global function Trophy_EntInTrophyTrigger
global function Trophy_SetAdditionalTrophysForPlayer
global function Trophy_PointInRangeOfAnyTrophy
global function Trophy_GetTrophyInRangeOfEntity
global function Trophy_GetShieldsPercentRemaining
global function Trophy_IsDecoyInRangeOfTrophy
#if DEV
global function DEV_Trophy_SetHealAmount
#endif
#endif

#if CLIENT
global function SCB_WattsonRechargeHint
global function OnCreateClientOnlyModel_weapon_trophy_defense_system
#endif

const vector TROPHY_RING_COLOR = <134, 182, 255>

//TROPHY FX VARS
const asset TROPHY_START_FX = $"P_wpn_trophy_loop_st"
const asset TROPHY_NO_SHIELDS_FX = $"P_trophy_no_shields"
const asset TROPHY_ELECTRICITY_FX = $"P_wpn_trophy_loop_1"

const asset TROPHY_ELECTRICITY_FX_UPGRADE = $"P_wpn_trophy_loop_1_pow"

const asset TROPHY_INTERCEPT_PROJECTILE_SMALL_FX = $"P_wpn_trophy_imp_sm"//$"wpn_arc_cannon_beam"
const asset TROPHY_INTERCEPT_PROJECTILE_LARGE_FX = $"P_wpn_trophy_imp_lg"
const asset TROPHY_INTERCEPT_PROJECTILE_CLOSE_FX = $"P_wpn_trophy_imp_lite"
const asset TROPHY_DAMAGE_SPARK_FX = $"P_trophy_sys_dmg"
const asset TROPHY_DESTROY_FX = $"P_trophy_sys_exp"
const asset TROPHY_COIL_ON_FX = $"P_wpn_trophy_coil_spin"
const asset TROPHY_PLAYER_TACTICAL_CHARGE_FX = $"P_wat_menu_coil_loop"

const asset TROPHY_RANGE_RADIUS_REMINDER_FX = $"P_ar_edge_ring_gen"

#if CLIENT
const float TROPHY_COOLDOWN_DRAW_DIST_MIN = 200.0
const float TROPHY_COOLDOWN_DRAW_DIST_MAX = 3000.0
const asset TROPHY_PLACEMENT_RADIUS_FX = $"P_ar_edge_ring_gen"
#endif //CLIENT

const float TROPHY_AR_EFFECT_SIZE = 768.0 // coresponds with the size of the sphere model used for the AR effect

// TROPHY SCRIPT NAME AND TARGETNAME
global const string TROPHY_SYSTEM_NAME = "trophy_system"
global const string TROPHY_SYSTEM_MOVER_NAME = "trophy_system_mover"

//TROPHY IMPACT TABLE
const TROPHY_TARGET_EXPLOSION_IMPACT_TABLE = "exp_medium"

//TROPHY MODEL VARS
const asset TROPHY_MODEL = $"mdl/props/wattson_trophy_system/wattson_trophy_system.rmdl"

//TROPHY SOUNDS
const string TROPHY_PLACEMENT_ACTIVATE_SOUND = "wattson_tactical_a"
const string TROPHY_PLACEMENT_DEACTIVATE_SOUND = "wattson_tactical_b"

const string TROPHY_EXPAND_SOUND = "Wattson_Ultimate_E"
const string TROPHY_EXPAND_ENEMY_SOUND = "Wattson_Ultimate_E_Enemy"
const string TROPHY_ELECTRIC_IDLE_SOUND = "Wattson_Ultimate_F"
const string TROPHY_TACTICAL_CHARGE_SOUND = "Wattson_Ultimate_G"

const string TROPHY_INTERCEPT_BEAM_SOUND = "Wattson_Ultimate_H"
const string TROPHY_INTERCEPT_LARGE = "Wattson_Ultimate_I"
const string TROPHY_INTERCEPT_SMALL = "Wattson_Ultimate_J"

const string TROPHY_INTERCEPT_BEAM_SOUND_UPGRADE = "Wattson_Ultimate_H_Upgraded"
const string TROPHY_INTERCEPT_SMALL_UPGRADE = "Wattson_Ultimate_J_Upgraded"

const string TROPHY_DESTROY_SOUND = "Wattson_Ultimate_K"
const string TROPHY_SHIELD_REPAIR_START = "Wattson_Ultimate_L"
const string TROPHY_SHIELD_REPAIR_END = "Wattson_Ultimate_N"

//TROPHY PLACEMENT VARS
const float TROPHY_PLACEMENT_RANGE_MAX = 94
const float TROPHY_PLACEMENT_RANGE_MIN = 64
const float TROPHY_PLACEMENT_SPACING_MIN = 64
const float TROPHY_PLACEMENT_SPACING_MIN_SQR = TROPHY_PLACEMENT_SPACING_MIN * TROPHY_PLACEMENT_SPACING_MIN
const vector TROPHY_BOUND_MINS = <-32, -32, 0>
const vector TROPHY_BOUND_MAXS = <32, 32, 72>
const vector TROPHY_PLACEMENT_TRACE_OFFSET = <0, 0, 94>
const float TROPHY_PLACEMENT_MAX_GROUND_DIST = 12.0

//TROPHY INTERSECTION VARS
const vector TROPHY_INTERSECTION_BOUND_MINS = <-16, -16, 0>
const vector TROPHY_INTERSECTION_BOUND_MAXS = <16, 16, 32>

//TROPHY DEPLOY VARS
const int TROPHY_DEPLOY_COUNT = 3
const float TROPHY_ANGLE_LIMIT = 0.74
const float TROPHY_DEPLOY_DELAY = 1.0

//TROPHY HEALH VARS
const int TROPHY_HEALTH_AMOUNT = 150
const float TROPHY_DAMAGE_FX_INTERVAL = 0.25

//TROPHY ARC SCREEN EFFECT VARS - REPAIR RADIUS
const float WATTSON_TROPHY_CHARGE_POPUP_COOLDOWN = 3.5

//TROPHY SHIELD REPAIR VARS
const float TROPHY_SHIELD_REPAIR_INTERVAL = 0.5
const int TROPHY_SHIELD_REPAIR_AMOUNT = 1
const int TROPHY_DEPLOY_COUNT_UPDATE = 1
const float TROPHY_SHIELD_REPAIR_INTERVAL_UPDATE = 0.2
const int TROPHY_SHIELD_REPAIR_AMOUNT_UPDATE = 1
const float TROPHY_SHIELD_DAMAGED_DELAY = 1.0
const float TROPHY_LOS_CHARGE_TIMEOUT = 1.0
const asset TACTICAL_CHARGE_FX = $"P_player_boost_screen"//$"P_armor_regen_IPD"

//TROPHY REMINDER AREA VARS
const float TROPHY_REMINDER_TRIGGER_RADIUS = 300.0
const float TROPHY_REMINDER_TRIGGER_DBOUNCE = 30.0
const float TROPHY_REMINDER_DURATION = 1.0
const float TROPHY_REMINDER_TRIGGER_DBOUNCE_UPDATE = 5.0
const float TROPHY_REMINDER_DURATION_UPDATE = 3.0

//TROPHY DEBUG DRAWING
const bool TROPHY_DEBUG_DRAW = false
const bool TROPHY_DEBUG_DRAW_PLACEMENT = false
const bool TROPHY_DEBUG_DRAW_INTERSECTION = false

const int TROPHY_SHIELD_AMOUNT = 250

#if CLIENT
const float TROPHY_ICON_HEIGHT = 96.0
#endif //CLIENT

global enum eTrophySystemIgnores
{
	none = 0,
	friendlyOnly = 1,
	enemyOnly = 2,
	always = 3,
	allowBounce = 4
}

struct TrophyPlacementInfo
{
	vector origin
	vector angles
	entity parentTo
	bool   success = false
}

struct HealData
{
	entity healTarget
	int    healResourceID
}

struct TrophyShieldData
{
	int healResource = 1
	array<entity> healTargets = []
}

#if SERVER
struct TrophyVortexData
{
	entity trophy
}

struct StatusEffectHandleStruct
{
	int handle
}
#endif //SERVER


struct
{
	#if SERVER
		table < entity, TrophyVortexData >        vortexData
		table < entity, TrophyShieldData >        shieldData
		table < entity, float >					  recentlyDamaged
		table < entity, entity >                  trophyZapTag
		table < entity, table < entity, float > > playerReminderDBounces
		table < entity, entity >                  reminderTriggerTrophyPairing
		table < entity, entity >                  playerTrophyCharging
		table < entity, array<entity> >           trophyLoSToPlayers
		table < entity, float >                   lastDamageFxTime
		table < entity, array<entity> >           trophyTriggerEntArray
		table < entity, array<entity> >           entTrophyTriggerArray
		table < entity, int >                     playerToAdditionalTrophyCount
		table < entity, int >                     decoyToTrophyCount
#if DEV
		table < entity, entity >				  playerToTrophyLookup
#endif
	#else
		int tacticalChargeFXHandle
	#endif

	float trophy_interceptProjectileRange
	float trophy_interceptProjectileRangeMin
	float trophy_interceptProjectileRangeSqr
	float trophy_interceptProjectileRangeMinSqr
	int   trophy_maxCount
	int trophy_shieldPoolAmount
	int trophy_shieldRegenAmount
	float trophy_shieldRegenInterval
	float trophy_shieldRegenDelayOnDamage

	bool alwaysReminderVersion


	table< entity, float >			trophyLastConvertTime
	table< entity, array<entity> > 	trophy_ConvertedArcStars

} file

function MpWeaponTrophy_Init()
{
	PrecacheScriptString( TROPHY_SYSTEM_NAME )
	PrecacheParticleSystem( TROPHY_START_FX )
	PrecacheParticleSystem( TROPHY_ELECTRICITY_FX )

		PrecacheParticleSystem( TROPHY_ELECTRICITY_FX_UPGRADE )

	PrecacheParticleSystem( TROPHY_INTERCEPT_PROJECTILE_SMALL_FX )
	PrecacheParticleSystem( TROPHY_INTERCEPT_PROJECTILE_LARGE_FX )
	PrecacheParticleSystem( TROPHY_INTERCEPT_PROJECTILE_CLOSE_FX )
	PrecacheParticleSystem( TROPHY_DAMAGE_SPARK_FX )
	PrecacheParticleSystem( TROPHY_DESTROY_FX )
	PrecacheParticleSystem( TROPHY_COIL_ON_FX )
	PrecacheParticleSystem( TROPHY_PLAYER_TACTICAL_CHARGE_FX )
	PrecacheParticleSystem( TROPHY_RANGE_RADIUS_REMINDER_FX )
	PrecacheParticleSystem( TROPHY_NO_SHIELDS_FX )

	file.trophy_interceptProjectileRange = GetCurrentPlaylistVarFloat( "wattson_trophy_interceptProjectileRange", 512.0 )
	file.trophy_interceptProjectileRangeMin = GetCurrentPlaylistVarFloat( "wattson_trophy_interceptProjectileRangeMin", 498.0 )

	file.trophy_maxCount = GetCurrentPlaylistVarInt( "wattson_trophy_max_count", TROPHY_DEPLOY_COUNT )
	PrecacheParticleSystem( TROPHY_NO_SHIELDS_FX )
	file.trophy_shieldPoolAmount 			= GetCurrentPlaylistVarInt( "wattson_trophy_shieldPoolAmount", TROPHY_SHIELD_AMOUNT )
	file.trophy_shieldRegenAmount 			= GetCurrentPlaylistVarInt( "wattson_trophy_shieldRegenAmount", TROPHY_SHIELD_REPAIR_AMOUNT_UPDATE )
	file.trophy_shieldRegenInterval 		= GetCurrentPlaylistVarFloat( "wattson_trophy_shieldRegenTick", TROPHY_SHIELD_REPAIR_INTERVAL_UPDATE )
	file.trophy_shieldRegenDelayOnDamage	= GetCurrentPlaylistVarFloat( "wattson_trophy_shieldRegenDelayOnDamage", TROPHY_SHIELD_DAMAGED_DELAY )
	file.trophy_maxCount 					= GetCurrentPlaylistVarInt( "wattson_trophy_max_count", TROPHY_DEPLOY_COUNT_UPDATE )

	file.alwaysReminderVersion = GetCurrentPlaylistVarBool( "wattson_trophy_always_reminder", false )

	file.trophy_interceptProjectileRangeSqr = file.trophy_interceptProjectileRange * file.trophy_interceptProjectileRange
	file.trophy_interceptProjectileRangeMinSqr = file.trophy_interceptProjectileRangeMin * file.trophy_interceptProjectileRangeMin
	#if SERVER
		PrecacheImpactEffectTable( TROPHY_TARGET_EXPLOSION_IMPACT_TABLE )
		RegisterSignal( "Trophy_Deploy" )
		RegisterSignal( "Trophy_StopPlayerTacticalChargeFX" )
		RegisterSignal( "Trophy_ZappedProjectile" )
		SurvivalLoot_AddCallback_OnPlayerBackpackOpened( Trophy_CancelPlacement )

		RegisterDynamicEntCleanupItem_Parented_Scriptname( TROPHY_SYSTEM_NAME )
		RegisterDynamicEntCleanupItem_Area_Scriptname( TROPHY_SYSTEM_NAME )

		AddDamageCallback( "player", Trophy_PlayerOnDamage )
	#endif //SERVER

	#if CLIENT
		PrecacheParticleSystem( TACTICAL_CHARGE_FX )
		PrecacheParticleSystem( TROPHY_PLACEMENT_RADIUS_FX )

		RegisterSignal( "Trophy_StopPlacementProxy" )
		RegisterSignal( "EndTacticalChargeRepair" )
		RegisterSignal( "EndTacticalShieldRepair" )

		StatusEffect_RegisterEnabledCallback( eStatusEffect.trophy_tactical_charge, TacticalChargeVisualsEnabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.trophy_tactical_charge, TacticalChargeVisualsDisabled )

		AddCallback_OnWeaponStatusUpdate( Trophy_OnWeaponStatusUpdate )

		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )
		AddCallback_MinimapEntShouldCreateCheck_Scriptname( TROPHY_SYSTEM_NAME, Minimap_DontCreateRuisForEnemies )

		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.TROPHY_SYSTEM, MINIMAP_OBJ_AREA_RUI, MinimapPackage_TrophySystem, FULLMAP_OBJECT_RUI, FullmapPackage_TrophySystem )
	#endif //CLIENT

	thread MpWeaponTrophyLate_Init()
}


void function MpWeaponTrophyLate_Init()
{
	WaitEndFrame()
}


void function OnWeaponActivate_weapon_trophy_defense_system( entity weapon )
{
}


void function OnWeaponDeactivate_weapon_trophy_defense_system( entity weapon )
{
}


bool function OnWeaponAttemptOffhandSwitch_weapon_trophy_defense_system( entity weapon )
{
	return true
}


var function OnWeaponPrimaryAttack_weapon_trophy_defense_system( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	TrophyPlacementInfo placementInfo

	// Check for valid spot
	if ( !weapon.ObjectPlacementHasValidSpot() )
	{
		weapon.DoDryfire()
		return 0
	}

	#if SERVER

	#endif
	PlayerUsedOffhand( ownerPlayer, weapon, true, null, {pos = placementInfo.origin} )

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

/*
 ____  _        _    ____ _____ __  __ _____ _   _ _____   _____ _   _ _   _  ____ _____ ___ ___  _   _ ____
|  _ \| |      / \  / ___| ____|  \/  | ____| \ | |_   _| |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
| |_) | |     / _ \| |   |  _| | |\/| |  _| |  \| | | |   | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
|  __/| |___ / ___ \ |___| |___| |  | | |___| |\  | | |   |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
|_|   |_____/_/   \_\____|_____|_|  |_|_____|_| \_| |_|   |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/

*/

TrophyPlacementInfo function Trophy_GetPlacementInfo( entity player, entity proxy )
{
	vector eyePos              = player.EyePosition()
	vector viewVec             = player.GetViewVector()

	TrophyPlacementInfo info = _GetPlacementInfo( player, proxy, eyePos, viewVec )

	if ( !info.success && player.IsStanding() )
	{
		TrophyPlacementInfo crouchInfo = _GetPlacementInfo( player, proxy, eyePos - <0,0,32>, viewVec, false )

		if ( crouchInfo.success )
			return crouchInfo
	}

	return info
}

TrophyPlacementInfo function _GetPlacementInfo( entity player, entity proxy, vector eyePos, vector viewVec, bool doUpTrace = true )
{
	vector angles              = < 0, VectorToAngles( viewVec ).y, 0 >
	array< entity > ignoreEnts = [player, proxy]

	float maxRange = TROPHY_PLACEMENT_RANGE_MAX

	TraceResults viewTraceResults = TraceLine( eyePos, eyePos + player.GetViewVector() * (TROPHY_PLACEMENT_RANGE_MAX * 2), ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )
	if ( viewTraceResults.fraction < 1.0 )
	{
		float slope = fabs( viewTraceResults.surfaceNormal.x ) + fabs( viewTraceResults.surfaceNormal.y )
		if ( slope < TROPHY_ANGLE_LIMIT )
			maxRange = min( Distance( eyePos, viewTraceResults.endPos ), TROPHY_PLACEMENT_RANGE_MAX )
	}

	int collisionGroup 	= TRACE_COLLISION_GROUP_PLAYER
	int traceMask		= TRACE_MASK_NPCSOLID

	vector idealPos          = player.GetOrigin() + (AnglesToForward( angles ) * TROPHY_PLACEMENT_RANGE_MAX)
	vector defaultUpVector   = < 0, 0, 1.0 >
	TraceResults fwdResults  = TraceHull( eyePos, eyePos + viewVec * maxRange, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, ignoreEnts, traceMask, collisionGroup, defaultUpVector, player )
	TraceResults downResults = TraceHull( fwdResults.endPos, fwdResults.endPos - TROPHY_PLACEMENT_TRACE_OFFSET, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, ignoreEnts, traceMask, collisionGroup, defaultUpVector, player )
	TraceResults useResults  = downResults

	bool isScriptedPlaceable = false
	bool isUpTraced = false

	vector upStart	= ( fwdResults.endPos + viewVec * 60.0 ) + <0, 0, 40.0>
	vector upEnd	= upStart - <0, 0, 80.0>
	TraceResults upResults = TraceHull( upStart, upEnd, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, ignoreEnts, traceMask, collisionGroup, <0, 0, 1>, player )

	vector roofTraceEnd = <eyePos.x, eyePos.y, upResults.endPos.z> + ( <viewVec.x, viewVec.y, 0> * 20.0 )
	TraceResults roofTraceResults = TraceLine( eyePos, roofTraceEnd, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )


	if ( doUpTrace && roofTraceResults.fraction >= 0.99 )
	{
		if ( IsValid( upResults.hitEnt ) )
			isScriptedPlaceable = Placement_IsHitEntScriptedPlaceable( upResults.hitEnt, 1 )

		if ( !upResults.startSolid && upResults.fraction < 1.0 && (upResults.hitEnt.IsWorld() || isScriptedPlaceable) )
		{
			useResults = upResults
			isUpTraced = true
		}
	}

	if ( TROPHY_DEBUG_DRAW_PLACEMENT )
	{
		DebugDrawBox( fwdResults.endPos, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, COLOR_GREEN, 1, 1.0 ) //Forward Hull Cast Bounding Box
		DebugDrawBox( downResults.endPos, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, COLOR_BLUE, 1, 1.0 ) //Downward Hull Cast Bounding Box
		DebugDrawLine( eyePos + viewVec * min( TROPHY_PLACEMENT_RANGE_MIN, maxRange ), fwdResults.endPos, COLOR_GREEN, true, 1.0 ) //Forward Hull Cast
		DebugDrawLine( fwdResults.endPos, eyePos + viewVec * maxRange, COLOR_RED, true, 1.0 ) //Forward Hull Cast Blocked
		DebugDrawLine( fwdResults.endPos, downResults.endPos, COLOR_BLUE, true, 1.0 ) //Downward Hull Cast
		DebugDrawBox( upResults.endPos, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, COLOR_CYAN, 1, 1.0 ) //"Upward" Hull Cast Bounding Box
		DebugDrawLine( upStart, upResults.endPos, COLOR_CYAN, true, 1.0 ) //"Upward" Hull Cast
		DebugDrawLine( eyePos, roofTraceEnd, COLOR_MAGENTA, true, 1.0 ) //Roof Check
		DebugDrawLine( player.GetOrigin(), player.GetOrigin() + (AnglesToForward( angles ) * TROPHY_PLACEMENT_RANGE_MAX), COLOR_GREEN, true, 1.0 ) //Max Placement Dist
		DebugDrawLine( eyePos + <0, 0, 8>, eyePos + <0, 0, 8> + (viewVec * TROPHY_PLACEMENT_RANGE_MAX), COLOR_GREEN, true, 1.0 ) //Max Placement Dist
	}

	//Handle placement of prop_scripts that support placeables.
	if ( !isUpTraced && IsValid( useResults.hitEnt ) )
		isScriptedPlaceable = Placement_IsHitEntScriptedPlaceable( useResults.hitEnt, 1 )

	bool success = isUpTraced || ( !useResults.startSolid && useResults.fraction < 1.0 && (useResults.hitEnt.IsWorld() || isScriptedPlaceable) )

	entity parentTo
	if ( IsValid( useResults.hitEnt ) && (useResults.hitEnt.GetNetworkedClassName() == "func_brush" || useResults.hitEnt.GetNetworkedClassName() == "script_mover") )
	{
		parentTo = useResults.hitEnt
	}

	if ( downResults.startSolid && downResults.fraction < 1.0 && (downResults.hitEnt.IsWorld() || isScriptedPlaceable) )
	{
		TraceResults hullResults = TraceHull( downResults.endPos, downResults.endPos, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		if ( hullResults.startSolid )
			success = false
	}

	vector surfaceAngles = angles

	//WALL OBSTRUCTION CHECK
	//Just to stop players from putting placeable through thin walls
	if ( !isUpTraced )
	{
		if ( success && !PlayerCanSeePos( player, useResults.endPos, true, 90 ) )
		{
			surfaceAngles = angles
			success = false
			//printt( "PLACEMENT FAILED: TRYING TO PLACE THROUGH WALL." )
		}
	}

	//IN AIR CHECK
	if ( success && viewTraceResults.hitEnt != null && (!viewTraceResults.hitEnt.IsWorld() && !isScriptedPlaceable) )
	{
		surfaceAngles = angles
		success = false
		//	printt( "PLACEMENT FAILED: PLACEMENT LOCATION IS IN THE AIR." )
	}

	//EVEN GROUND CHECK AND SURFACE ANGLE CHECK
	if ( success && useResults.fraction < 1.0 )
	{
		surfaceAngles = AnglesOnSurface( useResults.surfaceNormal, AnglesToForward( angles ) )
		vector newUpDir = AnglesToUp( surfaceAngles )
		vector oldUpDir = AnglesToUp( angles )

		//EVEN GROUND CHECK
		proxy.SetOrigin( useResults.endPos )
		proxy.SetAngles( surfaceAngles )

		vector right   = proxy.GetRightVector()
		vector forward = proxy.GetForwardVector()

		float length = Length( TROPHY_BOUND_MINS ) / 1.5
		length = length / 1.5

		array< vector > groundTestOffsets = [
			Normalize( right * 2 + forward ) * length,
			Normalize( -right * 2 + forward ) * length,
			Normalize( right * 2 + -forward ) * length,
			Normalize( -right * 2 + -forward ) * length
		]

		if ( TROPHY_DEBUG_DRAW_PLACEMENT )
		{
			DebugDrawLine( proxy.GetOrigin(), proxy.GetOrigin() + (right * 64), COLOR_GREEN, true, 1.0 ) //Ground Right Vector
			DebugDrawLine( proxy.GetOrigin(), proxy.GetOrigin() + (forward * 64), COLOR_BLUE, true, 1.0 ) //Ground Forward Vector
		}

		//Make sure we are getting placed on solid ground
		foreach ( vector testOffset in groundTestOffsets )
		{
			vector testPos           = proxy.GetOrigin() + testOffset
			TraceResults traceResult = TraceLine( testPos + (proxy.GetUpVector() * TROPHY_PLACEMENT_MAX_GROUND_DIST), testPos + (proxy.GetUpVector() * -TROPHY_PLACEMENT_MAX_GROUND_DIST), ignoreEnts, traceMask, collisionGroup )

			if ( TROPHY_DEBUG_DRAW_PLACEMENT )
				DebugDrawLine( testPos + (proxy.GetUpVector() * TROPHY_PLACEMENT_MAX_GROUND_DIST), traceResult.endPos, COLOR_RED, true, 1.0 ) //Ground Hull Cast

			if ( traceResult.fraction == 1.0 )
			{
				surfaceAngles = angles
				success = false
				//printt( "PLACEMENT FAILED: PROXY ORIGIN IS TOO FAR FROM GROUND." )
				break
			}
		}

		//SURFACE ANGLE CHECK
		if ( success && DotProduct( newUpDir, oldUpDir ) < TROPHY_ANGLE_LIMIT )
		{
			//surfaceAngles = angles
			success = false
			//printt( "PLACEMENT FAILED: SURFACE ANGLE TOO STEEP." )
		}
	}

	// CUSTOM INVALID ENT CHECK
	if ( success && IsValid( useResults.hitEnt ) && IsEntInvalidForPlacingPermanentOnto( useResults.hitEnt ) )
		success = false

	if ( success && IsOriginInvalidForPlacingPermanentOnto( useResults.endPos, proxy ) )
		success = false


	if( success )
	{
		TraceResults playerResults = TraceHull( useResults.endPos, useResults.endPos, TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS, [proxy], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, defaultUpVector, player  )
		if( IsValid( playerResults.hitEnt ) && playerResults.hitEnt.IsPlayer() )
			success = false
	}

	TrophyPlacementInfo placementInfo
	placementInfo.success = success
	placementInfo.origin = useResults.endPos
	placementInfo.angles = surfaceAngles
	placementInfo.parentTo = parentTo

	return placementInfo
}


entity function Trophy_CreateTrapPlacementProxy( asset modelName )
{
	#if SERVER
		entity proxy = CreatePropDynamic( modelName, <0, 0, 0>, <0, 0, 0> )
	#else
		entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	#endif
	proxy.EnableRenderAlways()
	proxy.kv.rendermode = 3
	proxy.kv.renderamt = 1
	proxy.Anim_PlayOnly( "prop_trophy_idle_closed" )
	proxy.Hide()

	return proxy
}

#if CLIENT
void function SCB_WattsonRechargeHint()
{
	if ( !IsAlive( GetLocalClientPlayer() ) )
		return

	CreateTransientCockpitRui( $"ui/wattson_ult_charge_tactical.rpak", HUD_Z_BASE )
}

void function OnCreateClientOnlyModel_weapon_trophy_defense_system( entity weapon, entity model, bool validHighlight )
{
	model.Anim_PlayOnly( "prop_trophy_idle_closed" )

	int fxHandle = StartParticleEffectOnEntity( model, GetParticleSystemIndex( TROPHY_PLACEMENT_RADIUS_FX ), FX_PATTACH_POINT_FOLLOW, model.LookupAttachment( "REF" ) )

	EffectSetControlPointVector( fxHandle, 1, <10.0, file.trophy_interceptProjectileRange / TROPHY_AR_EFFECT_SIZE, 0> )
	EffectSetControlPointVector( fxHandle, 2, TROPHY_RING_COLOR )

	if ( validHighlight )
		DeployableModelHighlight( model )
	else
		DeployableModelInvalidHighlight( model )
}
#endif //CLIENT

/*
 ____           _____ ______   _______ _____   ____  _____  _    ___     __  ______ _    _ _   _  _____ _______ _____ ____  _   _  _____
|  _ \   /\    / ____|  ____| |__   __|  __ \ / __ \|  __ \| |  | \ \   / / |  ____| |  | | \ | |/ ____|__   __|_   _/ __ \| \ | |/ ____|
| |_) | /  \  | (___ | |__       | |  | |__) | |  | | |__) | |__| |\ \_/ /  | |__  | |  | |  \| | |       | |    | || |  | |  \| | (___
|  _ < / /\ \  \___ \|  __|      | |  |  _  /| |  | |  ___/|  __  | \   /   |  __| | |  | | . ` | |       | |    | || |  | | . ` |\___ \
| |_) / ____ \ ____) | |____     | |  | | \ \| |__| | |    | |  | |  | |    | |    | |__| | |\  | |____   | |   _| || |__| | |\  |____) |
|____/_/    \_\_____/|______|    |_|  |_|  \_\\____/|_|    |_|  |_|  |_|    |_|     \____/|_| \_|\_____|  |_|  |_____\____/|_| \_|_____/
*/

#if SERVER
void function Trophy_Deploy( entity owner, TrophyPlacementInfo placementInfo, int vehicleAttachmentIndex )
{
	const RUI_RADIUS_SCALE = 16384

	//owner.EndSignal( "OnDestroy" )
	PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_super" )

	vector origin = placementInfo.origin
	vector angles = placementInfo.angles

	//Create Trophy System.
	entity trophy = CreatePropScript( TROPHY_MODEL, origin, angles, SOLID_OBB, 320000 )
	trophy.kv.collisionGroup = TRACE_COLLISION_GROUP_NONE
	trophy.SetCollisionBounds( TROPHY_BOUND_MINS, TROPHY_BOUND_MAXS )
	trophy.AllowMantle()
	trophy.SetOwner( owner )
	trophy.SetBossPlayer( owner )
	trophy.e.noFriendlyFireProtection = true
	SetTeam( trophy, owner.GetTeam() )
	trophy.DisableHibernation()
	trophy.SetMaxHealth( GetTrophySystem_MaxHealth(owner) )
	trophy.SetHealth( GetTrophySystem_MaxHealth(owner) )
	trophy.SetTakeDamageType( DAMAGE_YES )
	trophy.SetDamageNotifications( true )
	trophy.SetDeathNotifications( false )
	trophy.SetArmorType( ARMOR_TYPE_HEAVY )
	trophy.SetScriptName( TROPHY_SYSTEM_NAME )
	SetTargetName( trophy, TROPHY_SYSTEM_NAME )
	trophy.SetBlocksRadiusDamage( false )
	trophy.SetTouchTriggers( true ) //Make it destroyable by triggers e.g. Leviathan stomp
	trophy.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it
	trophy.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD  | TT_GRAVITY_LIFT | TT_BLACKHOLE  ) // So it ignores jump pads placed underneath later


	FiringRange_AddToPermanentDeployableQuota( trophy, owner )

	//Create and store shield-regen trigger data so we can retrive it later.
	TrophyShieldData  data
	data.healResource = GetTrophySystem_MaxShieldCapacity( trophy )
	file.shieldData[ trophy ] <- data

	trophy.SetCanBeMeleed( true )
	SetVisibleEntitiesInConeQueriableEnabled( trophy, false )
	thread TrapDestroyOnRoundEnd( owner, trophy )
	AddToUltimateRealm( owner, trophy )

	bool doEMPDestroy = false
	bool doEMPDamage = false

	if ( GetCurrentPlaylistVarBool( "crypto_emp_destroy_wattson_trophy", true ) )
		doEMPDestroy = true
	else
		doEMPDamage = true

	PlayerObjects_CommonInit( owner, trophy, true, "sp_friendly_hero", true, doEMPDamage, doEMPDestroy, null, eEmpDestroyType.EMP_DESTROY_DAMAGE )





	trophy.e.canBurn = true
	trophy.e.canBeDamagedFromGas = true
	trophy.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_PRIORITY_NO_THREAT )

	trophy.Minimap_SetCustomState( eMinimapObject_prop_script.TROPHY_SYSTEM )
	trophy.Minimap_AlwaysShow( trophy.GetTeam(), null )

	// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
	AllianceProximity_SetMinimapAlwaysShow_ForAlliance( trophy.GetTeam(), trophy, null )

	trophy.Minimap_SetObjectScale( file.trophy_interceptProjectileRange / RUI_RADIUS_SCALE )
	trophy.Minimap_SetAlignUpright( true )
	trophy.DisableHibernation()

	trophy.Anim_PlayOnly( "prop_trophy_idle_closed" )
	trophy.EndSignal( "OnDestroy" )

	AddEntityCallback_OnDamaged( trophy, Trophy_OnTrophyDamaged )
	AddEntityCallback_OnPostDamaged( trophy, Trophy_OnTrophyPostDamaged )

	int attachID    = trophy.LookupAttachment( "handle" )
	vector trOrigin = trophy.GetAttachmentOrigin( attachID )
	vector trAngles = trophy.GetAttachmentAngles( attachID )

	entity fakeTag = CreateExpensiveScriptMover( trOrigin, trAngles )
	fakeTag.SetParent( trophy, "fx_center" )
	SetTargetName( fakeTag, UniqueString( "trophyTag" ) )

	file.trophyZapTag[ trophy ] <- fakeTag
	file.lastDamageFxTime[trophy] <- Time()
	file.trophyLoSToPlayers[ trophy ] <- []

	entity mover
	if ( placementInfo.parentTo != null )
	{
		mover = CreateScriptMover( TROPHY_SYSTEM_MOVER_NAME, origin, angles )
		mover.SetParent( placementInfo.parentTo )
		trophy.SetParent( mover )

		if( EntIsHoverVehicle( placementInfo.parentTo ) )
		{
			placementInfo.parentTo.HoverVehicle_SetAbilityAttachmentEntity( vehicleAttachmentIndex, mover )
		}

	}
	else
	{
		mover = trophy
	}

	OnThreadEnd(
		function() : ( owner, trophy, mover )
		{
			if ( IsValid( owner ) )
			{
				for ( int i = owner.e.activeUltimateTraps.len() - 1; i >= 0 ; i-- )
				{
					if ( owner.e.activeUltimateTraps[i] == trophy )
					{
						owner.e.activeUltimateTraps.remove( i )
					}
				}
			}

			if ( IsValid_ThisFrame( trophy ) )
			{
				if ( trophy in file.trophyZapTag )
				{
					if ( IsValid( file.trophyZapTag[ trophy ] ) )
						file.trophyZapTag[ trophy ].Destroy()

					delete file.trophyZapTag[ trophy ]
				}

				if ( trophy in file.trophyLoSToPlayers )
				{
					delete file.trophyLoSToPlayers[trophy]
				}

				delete file.lastDamageFxTime[trophy]

				//Remove sonar detection from trophy.
				RemoveSonarDetectionForPropScript( trophy )
				Trophy_DestroyExplosion( trophy )
				trophy.Destroy()
			}

			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

	thread Trophy_CheckForGeoIntersection( trophy )

	EmitSoundOnEntity( trophy, "Wattson_Ultimate_C" )

	trophy.e.isBusy = true
	thread PlayAnim( trophy, "prop_trophy_expand", mover )
	//trophy.Anim_DisableUpdatePosition()

	wait 0.66

	if ( !IsValid( owner ) )
		return

	EmitSoundOnEntityToTeam( trophy, TROPHY_EXPAND_SOUND, owner.GetTeam() )
	EmitSoundOnEntityToEnemies( trophy, TROPHY_EXPAND_ENEMY_SOUND, owner.GetTeam() )

	//Wait Before Turning the Trophy System On.
	wait TROPHY_DEPLOY_DELAY - 0.66

	// since there is no endsignal on destroy we have to check the validity of the owner after the waits.
	if ( !IsValid( owner ) )
		return

	thread PlayAnim( trophy, "prop_trophy_idle_open", mover )
	trophy.e.isBusy = false

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOrigin( trophy.GetOrigin() )
	trigger.SetParent( trophy )
	trigger.SetOwner( trophy )
	trigger.SetCylinderRadius( file.trophy_interceptProjectileRange )
	trigger.SetAboveHeight( 256 )
	trigger.SetBelowHeight( 256 )
	trigger.kv.triggerFilterPlayer = "all"

	DispatchSpawn( trigger )

	//Set the enter callback and set the origin and angles of the trigger so it touches entities that are already in the trigger bounds.
	trigger.SetEnterCallback( Trophy_OnChargeTriggerEnter )
	trigger.SetPhaseShiftCanTouch( false )

	AddToUltimateRealm( owner, trigger )
	trigger.SearchForNewTouchingEntity()

	EmitSoundOnEntity( trophy, "Wattson_Ultimate_E" )

	int idleAttachID = trophy.LookupAttachment( "fx_center_spin" )
	int idleFXID

	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) //upgrade_wattson_ult_pylon_hp_inc
	{
		idleFXID = GetParticleSystemIndex( TROPHY_ELECTRICITY_FX_UPGRADE )
	}
	else

	{
		idleFXID = GetParticleSystemIndex( TROPHY_ELECTRICITY_FX )
	}
	entity idleFX    = StartParticleEffectOnEntity_ReturnEntity ( trophy, idleFXID, FX_PATTACH_POINT_FOLLOW, idleAttachID )

	int leftAttachID  = trophy.LookupAttachment( "L_POINT" )
	int rightAttachID = trophy.LookupAttachment( "R_POINT" )
	int coilFXID      = GetParticleSystemIndex( TROPHY_COIL_ON_FX )

	entity leftFX  = StartParticleEffectOnEntity_ReturnEntity ( trophy, coilFXID, FX_PATTACH_POINT_FOLLOW, leftAttachID )
	entity rightFX = StartParticleEffectOnEntity_ReturnEntity ( trophy, coilFXID, FX_PATTACH_POINT_FOLLOW, rightAttachID )

	entity loopAG = CreateEntity( "ambient_generic" )
	SetTeam( loopAG, trophy.GetTeam() )
	loopAG.SetOrigin( trophy.GetAttachmentOrigin( idleAttachID ) )
	loopAG.SetParent( trophy, "fx_center_spin" )
	loopAG.SetSoundName( TROPHY_ELECTRIC_IDLE_SOUND )
	loopAG.SetEnabled( true )

	//Radius Reminder Trigger
	entity reminderTrigger = CreateEntity( "trigger_cylinder" )
	SetTeam( reminderTrigger, owner.GetTeam() )
	reminderTrigger.SetOrigin( trophy.GetOrigin() )
	reminderTrigger.SetParent( trophy )
	reminderTrigger.SetOwner( trophy )
	reminderTrigger.SetCylinderRadius( file.alwaysReminderVersion ? file.trophy_interceptProjectileRange : TROPHY_REMINDER_TRIGGER_RADIUS )
	reminderTrigger.SetAboveHeight( TROPHY_REMINDER_TRIGGER_RADIUS )
	reminderTrigger.SetBelowHeight( TROPHY_REMINDER_TRIGGER_RADIUS )
	reminderTrigger.kv.triggerFilterPlayer = "all"
	reminderTrigger.SetPhaseShiftCanTouch( false )

	DispatchSpawn( reminderTrigger )

	//Set the enter callback and set the origin and angles of the trigger so it touches entities that are already in the trigger bounds.
	table <entity, float> dbounceTable
	file.playerReminderDBounces[ reminderTrigger ] <- dbounceTable
	file.reminderTriggerTrophyPairing[ reminderTrigger ] <- trophy
	reminderTrigger.SetEnterCallback( Trophy_OnReminderTriggerEnter )
	reminderTrigger.SearchForNewTouchingEntity()
	AddToUltimateRealm( owner, reminderTrigger )

	OnThreadEnd(
		function() : ( owner, trigger, reminderTrigger, idleFX, leftFX, rightFX, loopAG )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()

			if ( IsValid( reminderTrigger ) )
			{
				delete file.playerReminderDBounces[ reminderTrigger ]
				delete file.reminderTriggerTrophyPairing[ reminderTrigger ]
				reminderTrigger.Destroy()
			}

			if ( IsValid( idleFX ) )
				EffectStop( idleFX )

			if ( IsValid( leftFX ) )
				EffectStop( leftFX )

			if ( IsValid( rightFX ) )
				EffectStop( rightFX )

			if ( IsValid( loopAG ) )
				loopAG.Destroy()
		}
	)

	owner.e.activeUltimateTraps.insert( 0, trophy )
	while ( owner.e.activeUltimateTraps.len() > GetTrophySystem_MaxTrophyCount( owner ) + Trophy_GetAdditionalTrophysForPlayer( owner ) )
	{
		entity entToDelete = owner.e.activeUltimateTraps.pop()
		if ( IsValid( entToDelete ) )
			entToDelete.Destroy()
	}

	// some ceremony
	int startAttachID = trophy.LookupAttachment( "fx_center" )
	int StartFxId     = GetParticleSystemIndex( TROPHY_START_FX )
	StartParticleEffectOnEntity( trophy, StartFxId, FX_PATTACH_POINT_FOLLOW, startAttachID )

	thread Trophy_InterceptProjectiles( trophy )

	WaitForever()
}

int function Trophy_GetAdditionalTrophysForPlayer( entity player )
{
	if ( !(player in file.playerToAdditionalTrophyCount) )
		return 0

	return file.playerToAdditionalTrophyCount[ player ]
}

void function Trophy_SetAdditionalTrophysForPlayer( entity player, int count )
{
	if ( !(player in file.playerToAdditionalTrophyCount) )
		file.playerToAdditionalTrophyCount[ player ] <- 0

	file.playerToAdditionalTrophyCount[ player ] = count
}

void function Trophy_OnReminderTriggerEnter( entity trigger, entity ent )
{
	if ( !ent.IsPlayer() )
		return

	//Only show reminder radius to n
	if ( ent.GetTeam() != trigger.GetTeam() )
		return

	if ( GetCurrentPlaylistVarBool( "wattson_trophy_no_reminder", false ) )
		return


	if ( file.alwaysReminderVersion )
	{
		thread Trophy_OnReminderTriggerEnter_AlwaysReminder_Internal( trigger, ent )
	}
	else
	{
		thread Trophy_OnReminderTriggerEnter_Internal( trigger, ent )
	}

}

void function Trophy_OnReminderTriggerEnter_Internal( entity trigger, entity ent )
{
	trigger.EndSignal( "OnDestroy" )
	EndSignal( ent, "OnDeath", "OnDestroy" )

	float losLastTime = 0.0
	float dBounceTime = TROPHY_REMINDER_TRIGGER_DBOUNCE
	float rangeFXTime = TROPHY_REMINDER_DURATION
	dBounceTime = TROPHY_REMINDER_TRIGGER_DBOUNCE_UPDATE
	rangeFXTime = TROPHY_REMINDER_DURATION_UPDATE

	while ( trigger.IsTouching( ent ) )
	{
		entity trophy = file.reminderTriggerTrophyPairing[ trigger ]
		if ( Trophy_RecordedAsHavingLoSToPlayer( trophy, ent ) )
		{
			losLastTime = Time()
		}

		if ( losLastTime + TROPHY_LOS_CHARGE_TIMEOUT > Time() )
		{
			if ( ent in file.playerReminderDBounces[trigger] )
			{
				if ( file.playerReminderDBounces[trigger][ ent ] + dBounceTime <= Time() )
				{
					int StartFxId = GetParticleSystemIndex( TROPHY_RANGE_RADIUS_REMINDER_FX )
					entity fx     = StartParticleEffectOnEntity_ReturnEntity( trophy, StartFxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
					EffectSetControlPointVector( fx, 1, <10.0, file.trophy_interceptProjectileRange / TROPHY_AR_EFFECT_SIZE, 0> )
					EffectSetControlPointVector( fx, 2, TROPHY_RING_COLOR )
					thread DestroyAfterDelay( fx, rangeFXTime )
					fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
					fx.SetOwner( ent )
				}

				file.playerReminderDBounces[trigger][ ent ] = Time()
			}
			else
			{
				int StartFxId = GetParticleSystemIndex( TROPHY_RANGE_RADIUS_REMINDER_FX )
				entity fx     = StartParticleEffectOnEntity_ReturnEntity( trophy, StartFxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
				EffectSetControlPointVector( fx, 1, <10.0, file.trophy_interceptProjectileRange / TROPHY_AR_EFFECT_SIZE, 0> )
				EffectSetControlPointVector( fx, 2, TROPHY_RING_COLOR )
				thread DestroyAfterDelay( fx, rangeFXTime )
				fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
				fx.SetOwner( ent )

				file.playerReminderDBounces[trigger][ ent ] <- Time()
			}

			return
		}

		WaitFrame()
	}
}

void function Trophy_OnReminderTriggerEnter_AlwaysReminder_Internal( entity trigger, entity ent )
{
	trigger.EndSignal( "OnDestroy" )
	EndSignal( ent, "OnDeath", "OnDestroy" )

	entity fx

	while ( trigger.IsTouching( ent ) )
	{
		entity trophy = file.reminderTriggerTrophyPairing[ trigger ]
		if ( Trophy_RecordedAsHavingLoSToPlayer( trophy, ent ) )
		{
			if(! ( ent in file.playerReminderDBounces[trigger] ) )
			{
				int StartFxId = GetParticleSystemIndex( TROPHY_RANGE_RADIUS_REMINDER_FX )
				fx     = StartParticleEffectOnEntity_ReturnEntity( trophy, StartFxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
				EffectSetControlPointVector( fx, 1, <10.0, file.trophy_interceptProjectileRange / TROPHY_AR_EFFECT_SIZE, 0> )
				EffectSetControlPointVector( fx, 2, TROPHY_RING_COLOR )
				fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
				fx.SetOwner( ent )

				file.playerReminderDBounces[trigger][ ent ] <- Time()
			}
		}
		else if(ent in file.playerReminderDBounces[trigger])
		{
			delete file.playerReminderDBounces[trigger][ent]
			if( IsValid(fx) )
			{
				fx.Destroy()
			}
		}

		WaitFrame()
	}
	if(ent in file.playerReminderDBounces[trigger])
	 {
		 delete file.playerReminderDBounces[trigger][ent]
		 if( IsValid(fx) )
		 {
			 fx.Destroy()
		 }
	 }
}

bool function Trophy_PointInRangeOfAnyTrophy( vector pos )
{
	foreach( vData in file.vortexData )
	{
		if ( !IsValid (vData.trophy) )
			continue

		if ( Distance( vData.trophy.GetOrigin(), pos ) <= file.trophy_interceptProjectileRange )
			return true
	}
	return false
}

entity function Trophy_GetTrophyInRangeOfEntity( entity ent, bool requireEnemy = false )
{
	foreach( vData in file.vortexData )
	{
		if ( !IsValid ( vData.trophy ) )
			continue

		if ( requireEnemy && IsFriendlyTeam( vData.trophy.GetTeam(), ent.GetTeam() ) )
			continue

		if ( Distance( vData.trophy.GetOrigin(), ent.GetOrigin() ) <= file.trophy_interceptProjectileRange )
			return vData.trophy
	}
	return null
}

int function Trophy_GetShieldsPercentRemaining( entity trophy )
{
	if ( !(trophy in file.shieldData) )
		return 0

	return int( ( float(file.shieldData[ trophy ].healResource) / float( GetTrophySystem_MaxShieldCapacity( trophy ) ) ) * 100 )
}

entity function Trophy_EntInTrophyTrigger( entity ent )
{
	foreach ( trigger, entArray in file.trophyTriggerEntArray )
	{
		if ( entArray.contains( ent ) )
			return trigger.GetParent()
	}
	return null
}

bool function Trophy_RemoteTryZapProjectile( entity trophy, entity projectile )
{
	if ( !IsValid( trophy ) || !IsValid( projectile ) )
		return false

	// find the vortex sphere associated with this projectile
	entity vortexSphere
	foreach ( vSphere, vData in file.vortexData )
	{
		if ( vData.trophy == trophy )
		{
			vortexSphere = vSphere
			break
		}
	}

	if ( IsValid( vortexSphere ) && !Trophy_ProjectileIsValidIgnoreType( projectile, trophy ) )
	{
		//If we can see the projectile, zap it.
		if ( Trophy_HasLOSToTarget( trophy, projectile, projectile.GetOrigin() ) )
		{
			projectile.RoundOriginAndAnglesToNearestNetworkValue()
			thread Trophy_ZapProjectile( trophy, projectile )
			int projectileTeam = projectile.GetTeam()
			projectile.Destroy()
			vortexSphere.Signal( "Trophy_ZappedProjectile" )
			StatsHook_Trophy_OnProjectileDestroyed( trophy.GetOwner(), projectileTeam )
			return true
		}
	}

	return false
}

// Zaps ANYTHING, because it skips the projectile check. Use with caution!!
bool function Trophy_RemoteTryZapEntity( entity trophy, entity ent )
{
	if ( !IsValid( trophy ) || !IsValid( ent ) )
		return false

	// find the vortex sphere associated with this projectile
	entity vortexSphere
	foreach ( vSphere, vData in file.vortexData )
	{
		if ( vData.trophy == trophy )
		{
			vortexSphere = vSphere
			break
		}
	}

	if ( IsValid( vortexSphere ) )
	{
		//If we can see the projectile, zap it.
		if ( Trophy_HasLOSToTarget( trophy, ent, ent.GetOrigin() ) )
		{
			ent.RoundOriginAndAnglesToNearestNetworkValue()
			thread Trophy_ZapProjectile( trophy, ent )
			int projectileTeam = ent.GetTeam()
			ent.Destroy()
			vortexSphere.Signal( "Trophy_ZappedProjectile" )
			StatsHook_Trophy_OnProjectileDestroyed( trophy.GetOwner(), projectileTeam )
			return true
		}
	}

	return false
}

void function Trophy_OnChargeTriggerEnter( entity trigger, entity ent )
{
	if ( ent.IsPlayerDecoy() )
	{
		thread Trophy_ManageDecoyHealFX_Thread( trigger, ent )
		return
	}






	if ( !ent.IsPlayer() )
		return


	// add touching ent array for this trigger
	if ( !(trigger in file.trophyTriggerEntArray) )
		file.trophyTriggerEntArray[ trigger ] <- []

	//tracking how many triggers are currently being touched by this ent, if they overlap
	if ( !(ent in file.entTrophyTriggerArray ) )
		file.entTrophyTriggerArray[ ent ] <- []

	thread Trophy_OnChargeTriggerEnter_Internal( trigger, ent )
	thread Trophy_RepairShields( trigger, ent )





	// add ent to touching trigger array. This lets us not run the above threads more then once if they are already running.
	if ( !file.trophyTriggerEntArray[ trigger ].contains( ent ) )
		file.trophyTriggerEntArray[ trigger ].append( ent )

	//tracking how many triggers are currently being touched by this ent, if they overlap
	if ( !file.entTrophyTriggerArray[ ent ].contains( trigger ) )
		file.entTrophyTriggerArray[ ent ].append( trigger )
}

void function Trophy_ManageDecoyHealFX_Thread( entity trigger, entity decoy )
{
	entity player = decoy.GetBossPlayer()
	entity trophy = trigger.GetOwner()

	if ( !IsValid( player ) || !IsValid( trophy ) )
		return

	EndSignal( decoy, "OnDestroy", "OnDeath" )
	EndSignal( player, "OnDestroy", "OnDeath" )
	EndSignal( trigger, "OnDestroy" )

	if ( decoy in file.decoyToTrophyCount )
	{
		file.decoyToTrophyCount[decoy]++
	}
	else
	{
		file.decoyToTrophyCount[decoy] <- 1
	}

	RecoveryHealingFXRequest healingFXRequest =  Player3pHealFXAddRequest( player, eHealingRequestType.Trophy )

	OnThreadEnd(
		function() : ( decoy, player, healingFXRequest )
		{
			Player3pHealFXRemoveRequest( player, healingFXRequest )

			if ( file.decoyToTrophyCount[decoy] > 1 )
			{
				file.decoyToTrophyCount[decoy]--
			}
			else
			{
				delete file.decoyToTrophyCount[decoy]
			}
		}
	)

	while ( true )
	{
		WaitFrame()
		healingFXRequest.decoyShieldFXIfValidatorPasses = false
		if ( file.shieldData[ trophy ].healResource <= 0 )
			return

		if ( !trigger.IsTouching( decoy ) )
			return

		if (player.GetShieldHealth() == player.GetShieldHealthMax())
			continue

		if ( player in file.recentlyDamaged && file.recentlyDamaged[ player ] >= Time() )
			continue

		if ( !Trophy_HasLOSToDecoy( trophy, decoy ) )
			continue

		healingFXRequest.decoyShieldFXIfValidatorPasses = true
	}
}

bool function Trophy_HasLOSToDecoy( entity trophy, entity decoy )
{
	int attachID       = trophy.LookupAttachment( "fx_center" )
	vector startOrigin = trophy.GetAttachmentOrigin( attachID )

	int traceMask = TRACE_MASK_BLOCKLOS | CONTENTS_WINDOW_NOCOLLIDE | CONTENTS_WINDOW

	array<entity> ignoreEnts = GetPlayerArray_AliveConnected()
	ignoreEnts.append( trophy )

	TraceResults traceResults = TraceLineHighDetail( startOrigin, decoy.EyePosition(), ignoreEnts, traceMask, TRACE_COLLISION_GROUP_BLOCK_WEAPONS, trophy )

	if ( traceResults.fraction == 1.0 )
		return true

	return false
}

bool function Trophy_IsDecoyInRangeOfTrophy( entity decoy )
{
	return decoy in file.decoyToTrophyCount
}

void function Trophy_OnChargeTriggerEnter_Internal( entity trigger, entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	EndSignal( player, "OnDestroy", "OnDeath", "StartPhaseShift" )
	EndSignal( trigger, "OnDestroy" )

	// if we the ent is already running this thread, early out. For some reason this happens when a revive is started. The trigger enter gets called again.
	Assert( trigger in file.trophyTriggerEntArray )
	if ( file.trophyTriggerEntArray[ trigger ].contains( player ) )
		return

	table<int, int> effectID
	effectID[eStatusEffect.trophy_tactical_charge] <- -1

	entity trophy = trigger.GetOwner()

	if ( !IsValid( trophy ) )
		return





	if ( !player.IsPlayer() )
		return


	trophy.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player, effectID, trophy, trigger )
		{
			if ( IsValid( player ) )
			{
				if ( effectID[eStatusEffect.trophy_tactical_charge] != -1 )
				{
					//printt( "STOPPING EFFECT: FINAL" )
					StatusEffect_Stop( player, effectID[eStatusEffect.trophy_tactical_charge] )
					player.Signal( "Trophy_StopPlayerTacticalChargeFX" )
				}

				// potentially swap to a new trophy if the current trophy is no good (out of range, dead, etc)
				if ( player in file.playerTrophyCharging && file.playerTrophyCharging[ player ] == trophy )
				{
					entity newTrophy
					foreach ( trophyTrigger in file.entTrophyTriggerArray[ player ] )
					{
						if ( trophyTrigger == trigger )
							continue

						if ( ( trophyTrigger.GetOwner() in file.shieldData ) && file.shieldData[ trophyTrigger.GetOwner() ].healResource > 0 )
						{
							newTrophy = trophyTrigger.GetOwner()







							Trophy_SetPlayerAsHealTarget( newTrophy, player, !( player.GetShieldHealth() == player.GetShieldHealthMax() ) )

							break
						}
					}

					if ( !IsValid( newTrophy ))
						Trophy_SetPlayerAsHealTarget( trophy, player, false )
				}
			}

			if ( trigger in file.trophyTriggerEntArray )
			{
				file.trophyTriggerEntArray[ trigger ].fastremovebyvalue( player )
				if ( file.trophyTriggerEntArray[ trigger ].len() == 0 )
					delete file.trophyTriggerEntArray[ trigger ]
			}

			if ( player in file.entTrophyTriggerArray )
			{
				file.entTrophyTriggerArray[ player ].fastremovebyvalue( trigger )
				if ( file.entTrophyTriggerArray[ player ].len() == 0 )
					delete file.entTrophyTriggerArray[ player ]
			}
		}
	)

	float losLastTime = 0.0
	while ( true )
	{
		if ( !trigger.IsTouching( player ) )
		{
			wait 1.0
			if ( !trigger.IsTouching( player ) )
				return
		}

		if( trophy in file.trophyLoSToPlayers )
		{
			if( Trophy_HasLOSToPlayer( trophy, player ) )
			{
				if( !file.trophyLoSToPlayers[trophy].contains( player ) )
				{
					file.trophyLoSToPlayers[trophy].append( player )
				}
			}
			else
			{
				if( file.trophyLoSToPlayers[trophy].contains( player ) )
				{
					file.trophyLoSToPlayers[trophy].removebyvalue( player )
				}
			}
		}

		bool playerAtFullShields = ( player.GetShieldHealth() == player.GetShieldHealthMax() )








		if ( Trophy_CanHealPlayer( trophy, player ) )
		{
			if ( !(player in file.playerTrophyCharging) || 	// player is not being charged by a trophy
			( file.playerTrophyCharging[ player ] && !Trophy_CanHealPlayer( file.playerTrophyCharging[ player ], player ) ) || // player is being charged but no longer valid
			( file.playerTrophyCharging[ player ] && file.shieldData[ file.playerTrophyCharging[ player ] ].healResource <= 0) && file.shieldData[ trophy ].healResource > 0 ) // player is being charged but no longer has shields
			{
				//add trophy as the one charging the player
				Trophy_SetPlayerAsHealTarget( trophy, player, !playerAtFullShields )
			}
			losLastTime = Time()
		}

		if ( losLastTime + TROPHY_LOS_CHARGE_TIMEOUT > Time() && playerAtFullShields )
		{
			if ( effectID[eStatusEffect.trophy_tactical_charge] == -1 )
			{
				//printt( "STARTING EFFECT" )
				effectID[eStatusEffect.trophy_tactical_charge] = StatusEffect_AddEndless( player, eStatusEffect.trophy_tactical_charge, 1.0 )
			}
		}
		else if ( effectID[eStatusEffect.trophy_tactical_charge] != -1 )
		{
			//printt( "STOPPING EFFECT" )
			if ( player in file.playerTrophyCharging && file.playerTrophyCharging[ player ] == trophy )
			{
				Trophy_SetPlayerAsHealTarget( trophy, player, false )
			}
			StatusEffect_Stop( player, effectID[eStatusEffect.trophy_tactical_charge] )
			effectID[eStatusEffect.trophy_tactical_charge] = -1
		}

		WaitFrame()
	}
}

void function Trophy_PlayTacticalChargeFXOnPlayer( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	EndSignal( player, "Trophy_StopPlayerTacticalChargeFX", "OnDeath", "OnDestroy", "Trophy_StopPlayerTacticalChargeFX" )

	entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	if ( !IsValid( tacticalWeapon ) )
		return

	string weaponName = tacticalWeapon.GetWeaponClassName()
	if ( weaponName != "mp_weapon_tesla_trap" )
		return

	int leftAttachID  = player.LookupAttachment( "fx_coil_left" )
	int rightAttachID = player.LookupAttachment( "fx_coil_right" )
	int coilFXID      = GetParticleSystemIndex( TROPHY_PLAYER_TACTICAL_CHARGE_FX )

	if ( leftAttachID == 0 || rightAttachID == 0 )
	{
		// model is wrong
		return
	}

	entity leftFX = StartParticleEffectOnEntity_ReturnEntity ( player, coilFXID, FX_PATTACH_POINT_FOLLOW, leftAttachID )
	leftFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	leftFX.SetOwner( player )

	entity rightFX = StartParticleEffectOnEntity_ReturnEntity ( player, coilFXID, FX_PATTACH_POINT_FOLLOW, rightAttachID )
	rightFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	rightFX.SetOwner( player )

	OnThreadEnd(
		function() : ( player, leftFX, rightFX )
		{
			if ( IsValid( player ) )
			{
				if ( IsValid( leftFX ) )
					leftFX.Destroy()

				if ( IsValid( rightFX ) )
					rightFX.Destroy()
			}
		}
	)

	WaitForever()
}

void function Trophy_RepairShields( entity trigger, entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "StartPhaseShift" )
	EndSignal( trigger, "OnDestroy" )

	if ( !player.IsPlayer() )
		return

	// if we the player is already running this thread, early out.
	Assert( trigger in file.trophyTriggerEntArray )
	if ( file.trophyTriggerEntArray[ trigger ].contains( player ) )
		return

	entity trophy = trigger.GetOwner()

#if DEV
	if ( !(player in file.playerToTrophyLookup) )
	{
		file.playerToTrophyLookup[player] <- trophy
	}
	else
	{
		file.playerToTrophyLookup[player] = trophy
	}
#endif

	if ( !IsValid( trophy ) )
		return

	RecoveryHealingFXRequest healingRequest = Player3pHealFXAddRequest( player, eHealingRequestType.Trophy )
	bool repairingShields = false

	//this is a struct so its passed by value into the thread end
	StatusEffectHandleStruct statusEffectHandle
	statusEffectHandle.handle = -1

	OnThreadEnd(
		function() : ( player, trigger, statusEffectHandle, healingRequest )
		{
			if ( IsValid( player ) )
			{
				foreach ( weapon in Trophy_GetAllowableWeaponsToCharge( player ) )
				{
					if ( weapon.HasMod( "interception_pylon_super_charge" ) )
						weapon.RemoveMod( "interception_pylon_super_charge" )
				}

				player.Signal( "Trophy_StopPlayerTacticalChargeFX" )
				if ( healingRequest.requestShieldFX )
				{
					EmitSoundOnEntityOnlyToPlayer( player, player, TROPHY_SHIELD_REPAIR_END )
				}
				Player3pHealFXRemoveRequest( player, healingRequest )

				entity trophy = trigger.GetOwner()

				if ( statusEffectHandle.handle != -1 )
				{
					StatusEffect_Stop( player, statusEffectHandle.handle )
				}
			}

			if ( trigger in file.trophyTriggerEntArray )
			{
				file.trophyTriggerEntArray[ trigger ].fastremovebyvalue( player )
				if ( file.trophyTriggerEntArray[ trigger ].len() == 0 )
					delete file.trophyTriggerEntArray[ trigger ]
			}

			#if DEV
				if( IsValid(trigger) && (player in file.playerToTrophyLookup) && file.playerToTrophyLookup[player] == trigger.GetOwner() )
				{
					delete file.playerToTrophyLookup[player]
				}
			#endif
		}
	)

	EndSignal( trophy, "OnDestroy" )

	float debugStartChargeTime = -1.0

	float losLastTime = 0.0
	float lastRechargeTime = 0.0
	array <entity> abilityWeapons
	while ( true )
	{
		WaitFrame()

		if ( !trigger.IsTouching( player ) )
		{
			wait 1.0
			if ( !trigger.IsTouching( player ) )
				return
		}

		abilityWeapons = Trophy_GetAllowableWeaponsToCharge( player )

		if ( !(player in file.playerTrophyCharging) || (file.playerTrophyCharging[ player ] == trophy) )
		{
			if( Trophy_RecordedAsHavingLoSToPlayer( trophy, player ) )
			{
				losLastTime = Time()
			}

			if ( losLastTime + TROPHY_LOS_CHARGE_TIMEOUT <= Time() )
			{
				foreach ( weapon in abilityWeapons )
				{
					if ( weapon.HasMod( "interception_pylon_super_charge" ) )
					{
						weapon.RemoveMod( "interception_pylon_super_charge" )
						player.Signal( "Trophy_StopPlayerTacticalChargeFX" )
					}
				}

				if ( repairingShields )
				{
					repairingShields = false
					healingRequest.requestShieldFX = false
					EmitSoundOnEntityOnlyToPlayer( player, player, TROPHY_SHIELD_REPAIR_END )
				}

				continue
			}

			if ( !Bleedout_IsBleedingOut( player ) && ( abilityWeapons.len() > 0 ) )
			{
				bool wattsonWeapon
				foreach ( weapon in abilityWeapons )
				{
					if ( !weapon.HasMod( "interception_pylon_super_charge" ) )
					{
						weapon.AddMod( "interception_pylon_super_charge" )
						if ( weapon.GetWeaponClassName() == "mp_weapon_tesla_trap" )
							wattsonWeapon = true
					}
				}

				if ( wattsonWeapon )
				{
					thread Trophy_PlayTacticalChargeFXOnPlayer( player )

					if ( Time() - player.p.wattsonTrophyChargePopupLastShowTime > WATTSON_TROPHY_CHARGE_POPUP_COOLDOWN )
					{
						Remote_CallFunction_NonReplay( player, "SCB_WattsonRechargeHint" )
						player.p.wattsonTrophyChargePopupLastShowTime = Time()
					}
				}
			}

			if ( player.GetShieldHealth() != player.GetShieldHealthMax() && !Bleedout_IsBleedingOut( player ) &&
					Trophy_CanHealPlayer( trophy, player ) && file.shieldData[ trophy ].healTargets.contains( player ))
			{
				if ( file.shieldData[ trophy ].healResource <= 0 )
				{
					if ( statusEffectHandle.handle != -1 )
					{
						StatusEffect_Stop( player, statusEffectHandle.handle )
						statusEffectHandle.handle = -1
					}

					if ( repairingShields )
					{
						repairingShields = false
						healingRequest.requestShieldFX = false
						EmitSoundOnEntityOnlyToPlayer( player, player, TROPHY_SHIELD_REPAIR_END )
					}

					continue
				}

				if ( Time() >= lastRechargeTime )
				{
					if ( debugStartChargeTime < 0.0 )
					{
						//printt( "CHARGE TIME START: " + Time() )
						debugStartChargeTime = Time()
					}
					int shieldRepairAmount = TROPHY_SHIELD_REPAIR_AMOUNT
					shieldRepairAmount = file.trophy_shieldRegenAmount

					int newShieldHealth = minint( player.GetShieldHealthMax(), player.GetShieldHealth() + shieldRepairAmount )

					int repairAmount    = newShieldHealth - player.GetShieldHealth()

					if ( repairAmount > 0 )
					{
						file.shieldData[ trophy ].healResource = file.shieldData[ trophy ].healResource - repairAmount

						player.SetShieldHealth( newShieldHealth )
						StatsHook_Trophy_OnEntityShieldCharged( trophy.GetOwner(), player, repairAmount )
					}

					if ( !repairingShields )
					{
						repairingShields = true
						healingRequest.requestShieldFX = true
						EmitSoundOnEntityOnlyToPlayer( player, player, TROPHY_SHIELD_REPAIR_START )
					}

					lastRechargeTime = Time() + file.trophy_shieldRegenInterval - 0.01
				}


				int targetCount = Trophy_GetHealTargetCount( trophy )
				int healAmountDistributed = file.shieldData[ trophy ].healResource / targetCount

				if ( statusEffectHandle.handle != -1 )
				{
					StatusEffect_Stop( player, statusEffectHandle.handle )
				}

				statusEffectHandle.handle = StatusEffect_AddEndless( player, eStatusEffect.target_shields,
					healAmountDistributed / float( player.GetShieldHealthMax() ) )
			}
			else if ( repairingShields )
			{
				repairingShields = false
				healingRequest.requestShieldFX = false
				EmitSoundOnEntityOnlyToPlayer( player, player, TROPHY_SHIELD_REPAIR_END )

				//printt( "CHARGE TIME: " + ( Time() - debugStartChargeTime ) )
				debugStartChargeTime = -1.0

				if ( statusEffectHandle.handle != -1 )
				{
					StatusEffect_Stop( player, statusEffectHandle.handle )
				}
			}
		}
	}
}























































































































































#if DEV
void function DEV_Trophy_SetHealAmount( entity player, int amount )
{
	if ( !IsValid(player) )
		return

	entity trophy = file.playerToTrophyLookup[player]

	if ( !IsValid(trophy) )
		return

	file.shieldData[ trophy ].healResource = amount
}
#endif

void function Trophy_SetPlayerAsHealTarget( entity trophy, entity player, bool isHealTarget )
{
	if ( isHealTarget && !file.shieldData[ trophy ].healTargets.contains( player ) )
	{
		if ( player in file.playerTrophyCharging )
		{
			int index = file.shieldData[ file.playerTrophyCharging[ player ] ].healTargets.find( player )
			if ( index >= 0 )
				file.shieldData[ file.playerTrophyCharging[ player ] ].healTargets.fastremove( index )
		}

		file.playerTrophyCharging[ player ] <- trophy
		file.shieldData[ trophy ].healTargets.append( player )
	}
	else
	{
		if ( player in file.playerTrophyCharging )
			delete file.playerTrophyCharging[ player ]

		int index = file.shieldData[ trophy ].healTargets.find( player )
		if ( index >= 0 )
			file.shieldData[ trophy ].healTargets.fastremove( index )
	}
}

int function Trophy_GetHealTargetCount( entity trophy )
{
	if ( !(trophy in file.shieldData) )
		return 0

	return file.shieldData[ trophy ].healTargets.len()
}

void function Trophy_PlayerOnDamage( entity player, var damageInfo )
{
	Assert( IsValid( player ), "Player ent got a damage callback but it wasn't vaild." )

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	switch( damageSourceID )
	{
		case eDamageSourceId.outOfBounds:
		case eDamageSourceId.deathField:



		case eDamageSourceId.damagedef_gas_exposure:
			return

		default:
			break
	}

	//if ( !(player in file.recentlyDamaged ) )
	file.recentlyDamaged[ player ] <- Time() + file.trophy_shieldRegenDelayOnDamage
}

array<entity> function Trophy_GetAllowableWeaponsToCharge( entity player )
{
	array <entity> abilityWeapons

	entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )

	if (  IsValid( tacticalWeapon ) && tacticalWeapon.GetWeaponClassName() == "mp_weapon_tesla_trap" )
		abilityWeapons.append( tacticalWeapon )

	return abilityWeapons
}

bool function Trophy_CanHealPlayer( entity trophy, entity player )
{
	if ( !CanBeHealedByDroneMedic( player ) )
		return false

	if ( player in file.recentlyDamaged && file.recentlyDamaged[ player ] >= Time() )
		return false

	return ( Trophy_RecordedAsHavingLoSToPlayer( trophy, player ) )
}

bool function Trophy_HasLOSToPlayer( entity trophy, entity player )
{
	int attachID       = trophy.LookupAttachment( "fx_center" )
	vector startOrigin = trophy.GetAttachmentOrigin( attachID )

	float maxDist    = file.trophy_interceptProjectileRange
	int traceMask    = TRACE_MASK_SOLID | CONTENTS_WINDOW_NOCOLLIDE
	int visConeFlags = VIS_CONE_ENTS_TEST_HITBOXES | VIS_CONE_ENTS_CHECK_SOLID_BODY_HIT | VIS_CONE_ENTS_APPOX_CLOSEST_HITBOX | VIS_CONE_ENTS_IGNORE_VORTEX
	vector dir       = Normalize( player.GetWorldSpaceCenter() - startOrigin )

	array<VisibleEntityInCone> results = FindVisibleEntitiesInCone( startOrigin, dir, maxDist, 45, [ trophy ], traceMask, visConeFlags, player.IsPlayer() ? player : null )

	foreach ( result in results )
	{
		if ( result.ent == player )
			return true
	}

	array<entity> ignoreEnts = GetPlayerArray_AliveConnected()
	ignoreEnts.append( trophy )

	array<vector> testEndVectors = [
		player.EyePosition(),
		(player.EyePosition() + player.GetWorldSpaceCenter()) / 2,
		((player.EyePosition() + player.GetWorldSpaceCenter()) / 2) + (player.GetRightVector() * 8),
		((player.EyePosition() + player.GetWorldSpaceCenter()) / 2) + (player.GetRightVector() * -8),
		player.GetWorldSpaceCenter(),
	]

	//If Cone Trace Fails, perform high-detail trace.
	foreach ( testVector in testEndVectors )
	{
		vector traceStart = startOrigin
		vector traceEnd   = testVector

		TraceResults traceResults = TraceLineHighDetail( traceStart, traceEnd, ignoreEnts, traceMask, TRACE_COLLISION_GROUP_BLOCK_WEAPONS, trophy )

		if ( TROPHY_DEBUG_DRAW )
		{
			DebugDrawLine( traceResults.endPos, traceEnd, COLOR_RED, true, 1.0 )
			DebugDrawLine( traceStart, traceResults.endPos, COLOR_GREEN, true, 1.0 )
		}

		if ( traceResults.fraction == 1.0 )
			return true
	}

	return false
}

bool function Trophy_RecordedAsHavingLoSToPlayer( entity trophy, entity player )
{
	return ( trophy in file.trophyLoSToPlayers && file.trophyLoSToPlayers[trophy].contains( player ) )
}

void function Trophy_CheckForGeoIntersection( entity trophy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	trophy.EndSignal( "OnDestroy" )

	while ( true )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		ignoreEnts.append( trophy )

		vector startPos = trophy.GetOrigin() + (trophy.GetUpVector() * 32)
		vector endPos   = startPos + trophy.GetUpVector()

		TraceResults results = TraceHull( startPos, endPos, TROPHY_INTERSECTION_BOUND_MINS, TROPHY_INTERSECTION_BOUND_MAXS, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

		if ( TROPHY_DEBUG_DRAW_INTERSECTION )
		{
			DebugDrawBox( results.endPos, TROPHY_INTERSECTION_BOUND_MINS, TROPHY_INTERSECTION_BOUND_MAXS, COLOR_GREEN, 1, 1.0 ) //Forward Hull Cast Bounding Box
		}

		//PrintTraceResults( results )

		if ( results.startSolid )
		{
			entity hitEnt = results.hitEnt
			if ( IsValid( hitEnt ) )
			{
				string hitEntClassname = hitEnt.GetClassName()

				if ( hitEntClassname == "phys_bone_follower" || hitEntClassname == "func_brush" || hitEntClassname == "script_mover" || hitEntClassname == "func_brush_lightweight" || hitEntClassname == "prop_dynamic" )
				{
					Trophy_DestroyExplosion( trophy )
					trophy.Destroy()
				}
			}
		}

		wait 0.25
	}
}


void function Trophy_InterceptProjectiles( entity trophy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	trophy.EndSignal( "OnDestroy" )

	int attachmentID        = trophy.LookupAttachment( "handle" )
	vector attachmentOrigin = trophy.GetAttachmentOrigin( attachmentID )

	//------------------------------
	// Vortex to detect bullets, projectiles, and mortars entering our defensive perimiter.
	//------------------------------
	entity vortexSphere = CreateEntity( "vortex_sphere" )

	vortexSphere.kv.spawnflags = SF_BLOCK_OWNER_WEAPON
	vortexSphere.kv.enabled = 0
	vortexSphere.kv.radius = file.trophy_interceptProjectileRange
	vortexSphere.kv.height = file.trophy_interceptProjectileRange
	vortexSphere.kv.bullet_fov = 360
	vortexSphere.kv.physics_pull_strength = 0//25
	vortexSphere.kv.physics_side_dampening = 0//6
	vortexSphere.kv.physics_fov = 360
	vortexSphere.kv.physics_max_mass = 0//2
	vortexSphere.kv.physics_max_size = 0//6

	vortexSphere.SetAngles( <0, 0, 0> ) // viewvec?
	vortexSphere.SetOrigin( attachmentOrigin )
	vortexSphere.SetMaxHealth( 100 )
	vortexSphere.SetHealth( 100 )

	DispatchSpawn( vortexSphere )
	if ( IsValid( trophy.GetOwner() ) )
		AddToUltimateRealm( trophy.GetOwner(), vortexSphere )

	vortexSphere.SetParent( trophy )

	//Create and store vortex data so we can retrive it later.
	TrophyVortexData data
	data.trophy = trophy
	file.vortexData[ vortexSphere ] <- data

	//HACK: Until we get a better way to do this use the vortex's target name to specify that it is a vortex trigger that
	//will run a set callback when a projectile or bullet hits it instead of preforming its normal vortex logic.
	Vortex_ConvertToVortexTriggerArea( vortexSphere )
	SetCallback_VortexSphereTriggerOnBulletHit( vortexSphere, Trophy_OnBulletHitVortexTrigger )
	SetCallback_VortexSphereTriggerOnProjectileHit( vortexSphere, Trophy_OnProjectileHitVortexTrigger )

	vortexSphere.Fire( "Enable" )
	vortexSphere.SetInvulnerable() // make particle wall invulnerable to weapon damage. It will still drain over time

	thread TrophyUpdateShieldCount_Think( trophy )

	OnThreadEnd(
		function() : ( vortexSphere )
		{
			if ( IsValid( vortexSphere ) )
			{
				delete file.vortexData[ vortexSphere ]
				vortexSphere.Destroy()
			}
		}
	)

	WaitForever()
}

void function TrophyUpdateShieldCount_Think( entity trophy )
{
	int count = file.shieldData[ trophy ].healResource

	if ( count == 0 )
		return

	EndSignal( trophy, "OnDestroy" )

	entity wp = CreatePlayerWaypoint( eWaypoint.WATTSON_TROPHY_LIFE )
	wp.SetOrigin( trophy.GetOrigin() )
	wp.SetAngles( trophy.GetAngles() )
	wp.SetWaypointEntity( 0, trophy )
	wp.SetWaypointInt( 0, count )
	wp.SetWaypointInt( 1, count )
	wp.SetWaypointGametime( 0, Time() )
	wp.wp.waypointCreatedTime = Time()
	wp.SetOwner( trophy.GetOwner() )
	wp.SetParent( trophy )
	CopyRealmsFromTo( trophy, wp )
	SetTeam( wp, trophy.GetOwner().GetTeam() )

	OnThreadEnd(
		function() : ( wp )
		{
			wp.Destroy()
		}
	)

	while ( wp.GetWaypointInt( 0 ) > 0 )
	{
		wp.SetWaypointInt( 0, file.shieldData[ trophy ].healResource )
		WaitFrame()
	}

	WaitForever()
}

void function DestroyTrophyAfterZapCount( entity trophy, entity vortexSphere )
{
	int count = GetCurrentPlaylistVarInt( "wattson_trophy_destroy_count", 0 )

	if ( count == 0 )
		return

	vortexSphere.EndSignal( "OnDestroy" )
	trophy.EndSignal( "OnDestroy" )

	entity wp = CreatePlayerWaypoint( eWaypoint.WATTSON_TROPHY_LIFE )
	wp.SetOrigin( trophy.GetOrigin() )
	wp.SetAngles( trophy.GetAngles() )
	wp.SetWaypointInt( 0, count )
	wp.SetWaypointInt( 1, count )
	wp.SetWaypointGametime( 0, Time() )
	wp.wp.waypointCreatedTime = Time()
	wp.SetOwner( trophy.GetOwner() )
	wp.SetParent( trophy )
	CopyRealmsFromTo( trophy, wp )
	SetTeam( wp, trophy.GetOwner().GetTeam() )

	OnThreadEnd(
		function() : ( wp )
		{
			wp.Destroy()
		}
	)

	float refillDelay = GetCurrentPlaylistVarFloat( "wattson_trophy_destroy_refill_delay", 0.0 )

	if ( refillDelay > 0.0 )
		thread RefillPylonCount( wp )

	while ( wp.GetWaypointInt( 0 ) > 0 )
	{
		vortexSphere.WaitSignal( "Trophy_ZappedProjectile" )
		wp.SetWaypointGametime( 0, Time() + refillDelay )
		wp.SetWaypointInt( 0, wp.GetWaypointInt( 0 ) - 1 )
	}

	wait 0.5

	Trophy_DestroyExplosion( trophy )

	trophy.Destroy()
}

void function RefillPylonCount( entity wp )
{
	wp.EndSignal( "OnDestroy" )

	while ( true )
	{
		if ( Time() > wp.GetWaypointGametime( 0 ) && wp.GetWaypointInt( 0 ) < wp.GetWaypointInt( 1 ) )
		{
			EmitSoundOnEntity( wp, "arctool_smallpanel_beep" )
			wp.SetWaypointInt( 0, wp.GetWaypointInt( 0 ) + 1 )
			wait 0.7
		}
		WaitFrame()
	}
}

void function DestroyTrophyAfterZap( entity trophy, entity vortexSphere )
{
	float delay = GetCurrentPlaylistVarFloat( "wattson_trophy_destroy_cooldown", 90.0 )

	if ( delay == 0 )
	{
		thread DestroyTrophyAfterZapCount( trophy, vortexSphere )
		return
	}

	vortexSphere.EndSignal( "OnDestroy" )
	trophy.EndSignal( "OnDestroy" )

	if ( GetCurrentPlaylistVarBool( "wattson_trophy_destroy_cooldown_requires_zap", false ) )
	{
		vortexSphere.WaitSignal( "Trophy_ZappedProjectile" )
	}

	entity wp = CreatePlayerWaypoint( eWaypoint.WATTSON_TROPHY_TIMER )
	wp.SetOrigin( trophy.GetOrigin() )
	wp.SetAngles( trophy.GetAngles() )
	wp.SetWaypointGametime( 0, Time() )
	wp.SetWaypointGametime( 1, Time() + delay )
	wp.wp.waypointCreatedTime = Time()
	CopyRealmsFromTo( trophy, wp )
	wp.SetOwner( trophy.GetOwner() )
	wp.SetParent( trophy )

	OnThreadEnd(
		function() : ( wp )
		{
			wp.Destroy()
		}
	)

	wait delay

	Trophy_DestroyExplosion( trophy )

	trophy.Destroy()
}

void function Trophy_OnBulletHitVortexTrigger( entity weapon, entity vortexSphere, var damageInfo )
{
	//printt( "BULLET HIT VORTEX TRIGGER" )
	return
}

void function Trophy_OnProjectileHitVortexTrigger( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	//printt( "PROJECTILE HIT VORTEX TRIGGER" )
	TrophyVortexData data = file.vortexData[ vortexSphere ]
	entity trophy         = data.trophy

	if ( !IsValid( trophy ) )
		return

	if ( !IsValid( projectile ) )
		return

	// Workaround for R5DEV-103925
	if ( !projectile.DoesShareRealms( trophy ) )
		return

	//Don't destroy planted projectiles
	if ( projectile.proj.isPlanted )
		return

	//printt( projectile.GetClassName() )
	//printt( projectile.ProjectileGetWeaponClassName() )

	//Don't shoot down projectiles we aren't intended to target.
	if ( !Trophy_ShouldTargetProjectile( trophy, projectile, contactPos ) )
		return

	//If we can see the projectile, zap it.
	if ( Trophy_HasLOSToTarget( trophy, projectile, contactPos ) )
	{
		projectile.RoundOriginAndAnglesToNearestNetworkValue()
		thread Trophy_ZapProjectile( trophy, projectile )
		int projectileTeam = projectile.GetTeam()
		projectile.Destroy()
		vortexSphere.Signal( "Trophy_ZappedProjectile" )
		StatsHook_Trophy_OnProjectileDestroyed( trophy.GetOwner(), projectileTeam )
	}
}

void function Trophy_ZapProjectile( entity trophy, entity projectile )
{
	vector projectileOrigin = projectile.GetOrigin()

	EmitSoundOnEntity( trophy, GetTrophySystem_InterceptBeamSound( trophy, projectile ) )

	entity fakeTag = file.trophyZapTag[ trophy ]

	if ( !IsValid( fakeTag ) )
		return

	entity beamFX = CreateEntity( "info_particle_system" )
	beamFX.kv.cpoint1 = fakeTag.GetTargetName()

	asset zapFX = Trophy_GetZapFX( fakeTag.GetOrigin(), projectile )

	string zapSound = Trophy_GetZapSound( trophy, projectile )
	EmitSoundAtPosition( TEAM_UNASSIGNED, projectile.GetOrigin(), zapSound, trophy )

	beamFX.SetValueForEffectNameKey( zapFX )
	beamFX.kv.start_active = 1

	beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFX.SetOrigin( projectileOrigin )
	DispatchSpawn( beamFX )

	entity trophyOwner = trophy.GetOwner()

	if ( IsValid( trophyOwner) )
	{
		AddToUltimateRealm( trophyOwner, beamFX )
	}


		if ( PlayerHasPassive( trophyOwner, ePassives.PAS_ULT_UPGRADE_THREE ) ) //upgrade_wattson_ult_spawn_arcstar
		{
			if( Trophy_ShouldConvertToArcStar( trophyOwner, trophy, projectile ) )
				thread Trophy_CreateArcStar( trophyOwner, trophy, projectile )
		}


	OnThreadEnd(
		function () : ( beamFX )
		{
			if ( IsValid( beamFX ) )
				beamFX.Destroy()
		}
	)

	wait 0.3
}


const float TROPHY_ARC_STAR_CONVERSION_DEBOUNCE = 1.5
const int TROPHY_ARC_STAR_CONVERSION_MAX = 5

bool function Trophy_ShouldConvertToArcStar( entity player, entity trophy, entity projectile )
{
	if ( !IsValid( trophy ) )
		return false

	if ( !IsValid( projectile ) )
		return false

	int projectileTeam = projectile.GetTeam()
	int trophyTeam = trophy.GetTeam()

	// R5DEV-564526
	if ( projectile.GetOwner != null )
		projectileTeam = projectile.GetOwner().GetTeam()

	if( IsFriendlyTeam( trophyTeam, projectileTeam ) )
		return false

	if( IsTeamEliminated( trophyTeam ) )
		return false

	if( trophy in file.trophyLastConvertTime )
	{
		if( Time() - file.trophyLastConvertTime[trophy] < TROPHY_ARC_STAR_CONVERSION_DEBOUNCE )
			return false
	}

	if( trophy in file.trophy_ConvertedArcStars )
	{
		//Clear any invalid arc stars from trophy array before checking max
		foreach( star in file.trophy_ConvertedArcStars[trophy] )
		{
			if( !IsValid( star ) )
				file.trophy_ConvertedArcStars[trophy].fastremovebyvalue( star )
		}

		if( file.trophy_ConvertedArcStars[trophy].len() >= TROPHY_ARC_STAR_CONVERSION_MAX )
			return false
	}
	else
		file.trophy_ConvertedArcStars[trophy] <- []

	return true
}

void function Trophy_CreateArcStar( entity player, entity trophy, entity projectile )
{
	trophy.EndSignal( "OnDestroy" )

	string weaponRef = "mp_weapon_grenade_emp"
	entity dropEnt		= SpawnGenericLoot( weaponRef, trophy.GetOrigin() + <0,0,60>, < 0, 0, 0>, 1 )

	vector upVector = trophy.GetUpVector()
	vector angledVector = VectorRotateAxis( upVector, trophy.GetRightVector(), 30 )
	vector randomizedVector = VectorRotateAxis( angledVector, upVector, RandomFloatRange( 0, 360 ) )
	FakePhysicsThrow( trophy, dropEnt, randomizedVector * RandomFloatRange( 100, 300 ) , true )

	thread Create_ArcStarTrailVFX_Thread( dropEnt )

	if( IsValid( projectile ) )
	{
		entity weaponSource = projectile.IsProjectile() ? projectile.GetWeaponSource() : projectile
		switch ( weaponSource )
		{
			case "mp_weapon_defensive_bombardment_weapon":
			case "mp_weapon_creeping_bombardment_weapon":
			case "mp_ability_valk_cluster_missile":
			{
				file.trophyLastConvertTime[trophy] <- Time() + TROPHY_ARC_STAR_CONVERSION_DEBOUNCE
			}
			default:
				file.trophyLastConvertTime[trophy] <- Time()
		}
	}

	if( trophy in file.trophy_ConvertedArcStars )
	{
		file.trophy_ConvertedArcStars[trophy].append( dropEnt )
	}

	// wait for the arc star to land and check if it landed inside the trophy. if it did rethrow it
	while( IsValid( dropEnt ) && dropEnt.GetParent() != null && dropEnt.GetParent().GetClassName() == "prop_physics" )
	{
		Wait( .5 )
	}

	if( !IsValid( dropEnt ) )
		return

	const float RESPAWN_THRESHOLD_SQR = 25 * 25
	if( DistanceSqr( dropEnt.GetOrigin(), trophy.GetOrigin() ) < RESPAWN_THRESHOLD_SQR )
	{
		dropEnt.Destroy()
		thread Trophy_CreateArcStar( player, trophy, null )
	}
}

void function Create_ArcStarTrailVFX_Thread( entity dropEnt )
{
	EndSignal( dropEnt, "OnDestroy" )

	int arcFXID		= GetParticleSystemIndex( $"wpn_grenade_frag_blue" )
	entity fx		= StartParticleEffectOnEntity_ReturnEntity( dropEnt, arcFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	OnThreadEnd(
		function () : ( fx )
		{
			if ( IsValid( fx ) )
				fx.Destroy()
		}
	)

	float fxDuration = Time() + 1.5
	while( IsValid( dropEnt ) && Time() < fxDuration )
	{
		if( dropEnt.IsOnGround() )
			return

		WaitFrame()
	}
}


asset function Trophy_GetZapFX( vector trophyOrigin, entity projectile )
{
	vector projectileOrigin = projectile.GetOrigin()
	float distSqr           = DistanceSqr( trophyOrigin, projectileOrigin )
	if ( distSqr < (file.trophy_interceptProjectileRangeSqr) )
		return TROPHY_INTERCEPT_PROJECTILE_CLOSE_FX

	if ( projectile.IsProjectile() )
	{
		var large = projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_intercept_large" )
		return large == 1 ? TROPHY_INTERCEPT_PROJECTILE_LARGE_FX : TROPHY_INTERCEPT_PROJECTILE_SMALL_FX
	}

	return TROPHY_INTERCEPT_PROJECTILE_LARGE_FX
}

string function GetTrophySystem_InterceptBeamSound( entity trophy, entity projectile )
{
	string zapInterceptBeamSound = TROPHY_INTERCEPT_BEAM_SOUND
	entity trophyOwner = trophy.GetOwner()


	if ( IsValid( trophyOwner ) && PlayerHasPassive( trophyOwner, ePassives.PAS_BATTERY_POWERED ) && PlayerHasPassive( trophyOwner, ePassives.PAS_ULT_UPGRADE_THREE ) ) //upgrade_wattson_ult_spawn_arcstar
	{
		if( Trophy_ShouldConvertToArcStar( trophyOwner, trophy, projectile ) )
		{
			zapInterceptBeamSound = TROPHY_INTERCEPT_BEAM_SOUND_UPGRADE
		}
	}


	return zapInterceptBeamSound
}

string function Trophy_GetZapSound( entity trophy, entity projectile )
{
	string zapDestroySound = TROPHY_INTERCEPT_LARGE
	entity trophyOwner = trophy.GetOwner()

	if ( projectile.IsProjectile() )
	{
		if ( !projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_intercept_large" ) )
		{
			zapDestroySound = TROPHY_INTERCEPT_SMALL
		}

		if ( IsValid( trophyOwner ) && PlayerHasPassive( trophyOwner, ePassives.PAS_BATTERY_POWERED ) && PlayerHasPassive( trophyOwner, ePassives.PAS_ULT_UPGRADE_THREE ) ) //upgrade_wattson_ult_spawn_arcstar
		{
			if( Trophy_ShouldConvertToArcStar( trophyOwner, trophy, projectile ) )
			{
				zapDestroySound = TROPHY_INTERCEPT_SMALL_UPGRADE
			}
		}

	}

	return zapDestroySound
}

bool function Trophy_ShouldTargetProjectile( entity trophy, entity projectile, vector contactPos )
{

	var large = projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_intercept_large" )
	if ( large == "" || large == null )
		large = false

	if ( Trophy_ProjectileIsValidIgnoreType( projectile, trophy ) )
		return false

	vector trophyOrigin = trophy.GetOrigin()

	// if "large" (Gibraltar or Bangalore Ultimate missile), go ahead and blast it early
	// else, don't worry about it until it's actually within the intended range.
	if ( large )
		return true
	else if ( Distance( trophyOrigin, contactPos ) >= file.trophy_interceptProjectileRange )
		return false

	//Store our contact position for this projectile the first time we contact it.
	//This will allow us to determine if the projectile is incomming or outgoing.
	if ( !(trophy in projectile.proj.trophyFirstDetectionOrigin) )
	{
		projectile.proj.trophyFirstDetectionOrigin[ trophy ] <- contactPos
		projectile.proj.savedDir = projectile.GetVelocity()
	}
	else
	{
		vector relativeAngles = CalcRelativeAngles( VectorToAngles( projectile.GetVelocity() ), projectile.proj.savedDir)
		if ( relativeAngles.x <= 180.0 && relativeAngles.y <= 180.0 )
		{
			projectile.proj.trophyFirstDetectionOrigin[ trophy ] <- contactPos
			projectile.proj.savedDir = projectile.GetVelocity()
		}
	}

	vector projectileOrigin = projectile.GetOrigin()
	vector firstContactPos = projectile.proj.trophyFirstDetectionOrigin[ trophy ]
	vector velocity        = projectile.GetVelocity()
	float velLength        = Length( velocity )

	//Determine if the projectile is incomming or outgoing, do not shoot down outgoing projectiles.
	vector velDirSaved  = Normalize( projectile.proj.savedDir )
	vector velDir       = Normalize( projectile.GetVelocity() )
	vector trophyToProj = Normalize( trophyOrigin - projectileOrigin )

	if ( TROPHY_DEBUG_DRAW )
	{
		DebugDrawLine( projectileOrigin, projectileOrigin + (velDirSaved * 128), COLOR_RED, true, 20.0 )
		DebugDrawLine( projectileOrigin, projectileOrigin + (trophyToProj * 128), COLOR_GREEN, true, 20.0 )
	}

	float dotSaved  = DotProduct( velDirSaved, trophyToProj )
	float dot       = DotProduct( velDir, trophyToProj )
	float newOldDot = DotProduct( velDir, velDirSaved )
	//	printt( "DOT SAVED: " + dotSaved )
	//	printt( "DOT: " + dot )
	//	printt( "VEL: " + velLength )


	//If the projectile originated inside the interception zone, only intercept it if its trajectory indicates it will contact a surface within the zone.
	float distSqr = DistanceSqr( firstContactPos, trophyOrigin )
	bool hitWall = false
	if ( distSqr <= file.trophy_interceptProjectileRangeSqr && newOldDot > 0.0 )
	{
		float predictionTime = 0.1
		predictionTime = 0.2
		TraceResults traceResults = TraceLineHighDetail( projectileOrigin, projectileOrigin + (projectile.GetVelocity() * predictionTime), [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PROJECTILE, trophy )

		if ( traceResults.fraction < 1.0 )
		{
			if ( TROPHY_DEBUG_DRAW )
				DebugDrawLine( projectileOrigin, traceResults.endPos, COLOR_RED, true, 20.0 )

			// this is a wall. If we want the projectile to potentially bounce out of the wall, we should return false here
			// not sure if there's a more procedural way of doing this
			if ( traceResults.surfaceNormal.z <= 0.5 )
				hitWall = true

			float landDistanceSqr = DistanceSqr( traceResults.endPos, trophyOrigin )
			if ( landDistanceSqr >= file.trophy_interceptProjectileRangeSqr )
				return false

		}
		else
		{
			return false
		}
	}

	var ignore = projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_ignores" )
	if ( ignore == "" || ignore == null )
		ignore = "none"

	expect string(ignore)
	printt( ignore )
	Assert( ignore in eTrophySystemIgnores, projectile.ProjectileGetWeaponClassName() + " has invalid value for 'trophy_system_ignores': " + ignore )

	switch ( eTrophySystemIgnores[ ignore ] )
	{
		case eTrophySystemIgnores.allowBounce:
			return !hitWall
			break

		case eTrophySystemIgnores.none:
		default:
			return true
			break
	}

	unreachable
}

bool function Trophy_ProjectileIsValidIgnoreType( entity projectile, entity trophy )
{
	var ignore = projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_ignores" )
	if ( ignore == "" || ignore == null )
		ignore = "none"

	bool projectileTrophyFriendlyTeam = IsFriendlyTeam( projectile.GetTeam(), trophy.GetTeam() )

	if ( eTrophySystemIgnores[ ignore ] == eTrophySystemIgnores.always
	|| 	( eTrophySystemIgnores[ ignore ] == eTrophySystemIgnores.friendlyOnly && projectileTrophyFriendlyTeam )
	|| 	( eTrophySystemIgnores[ ignore ] == eTrophySystemIgnores.enemyOnly && !projectileTrophyFriendlyTeam )
	)
	{
		return true
	}

	return false
}

bool function Trophy_HasLOSToTarget( entity trophy, entity target, vector contactPos )
{
	entity fakeTag     = file.trophyZapTag[ trophy ]
	vector startOrigin = fakeTag.GetOrigin()
	vector endOrigin   = contactPos

	TraceResults results = TraceLineHighDetail( startOrigin, endOrigin, [ trophy, target ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS, trophy )
	//PrintTraceResults( results )

	if ( TROPHY_DEBUG_DRAW )
	{
		DebugDrawLine( results.endPos, endOrigin, COLOR_RED, true, 20.0 )
		DebugDrawLine( startOrigin, results.endPos, COLOR_GREEN, true, 20.0 )
	}

	if ( results.fraction == 1.0 )
		return true

	return false
}

void function Trophy_InterceptProjectileExplosion( vector projectileOrigin, vector trophyOrigin )
{
	string fxTable = TROPHY_TARGET_EXPLOSION_IMPACT_TABLE
	Explosion(
		projectileOrigin, //center,
		svGlobal.worldspawn, //attacker,
		svGlobal.worldspawn, //inflictor,
		0, //damage,
		0, //damageHeavyArmor,
		50.0, //innerRadius,
		50.0, //outerRadius,
		SF_ENVEXPLOSION_NO_DAMAGEOWNER, //flags,
		trophyOrigin, //projectileLaunchOrigin,
		0.0, //explosionForce,
		damageTypes.explosive, //scriptDamageFlags,
		eDamageSourceId.mp_weapon_tesla_trap, //scriptDamageSourceIdentifier,
		fxTable )                    //impactEffectTableName
}

void function Trophy_DestroyExplosion( entity trophy )
{
	int idleAttachID   = trophy.LookupAttachment( "fx_center_spin" )
	vector soundOrigin = trophy.GetAttachmentOrigin( idleAttachID )
	EmitSoundAtPosition( TEAM_ANY, soundOrigin, TROPHY_DESTROY_SOUND, trophy )

	int damageFXID       = GetParticleSystemIndex( TROPHY_DESTROY_FX )
	int damageFXAttachID = trophy.LookupAttachment( "fx_center" )
	entity fx            = StartParticleEffectInWorld_ReturnEntity( damageFXID, trophy.GetAttachmentOrigin( damageFXAttachID ), trophy.GetAttachmentAngles( damageFXAttachID ) )
	if ( IsValid( trophy ) )
	{
		fx.RemoveFromAllRealms()
		fx.AddToOtherEntitysRealms( trophy )
	}
}

void function Trophy_PlayDamagedFX( entity trophy )
{
	int damageFXID       = GetParticleSystemIndex( TROPHY_DAMAGE_SPARK_FX )
	int damageFXAttachID = trophy.LookupAttachment( "fx_center" )

	if ( trophy.IsMarkedForDeletion() )
		return

	entity idleFX = StartParticleEffectOnEntity_ReturnEntity ( trophy, damageFXID, FX_PATTACH_POINT_FOLLOW, damageFXAttachID )

	//EmitSoundOnEntity( trapProxy, TROPHY_DAMAGE_SPARK_SOUND )
}

void function Trophy_OnTrophyDamaged( entity trophy, var damageInfo )
{
	//printt( "TRAP DAMAGED" )

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	int trapTeam     = trophy.GetTeam()
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	int inflictorTeam  = inflictor.GetTeam()
	bool isGasDamage   = (damageSourceID == eDamageSourceId.damagedef_grenade_gas || damageSourceID == eDamageSourceId.damagedef_gas_exposure)
	bool isFriendlyGas = isGasDamage && (IsFriendlyTeam( inflictorTeam, trapTeam ) && (inflictorTeam != TEAM_UNASSIGNED)) //Lots of inflictors have TEAM_UNASSIGNED that need to damage it

	if ( (damageSourceID == eDamageSourceId.mp_weapon_tesla_trap) || isFriendlyGas )
	{
		DamageInfo_ScaleDamage( damageInfo, 0 )
		return
	}
}

void function Trophy_OnTrophyPostDamaged( entity trophy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	int trapTeam     = trophy.GetTeam()
	int attackerTeam = attacker.GetTeam()

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	if ( !IsValid( trophy ) )
		return

	float damage = DamageInfo_GetDamage( damageInfo )

	if ( damage <= 0 )
		return

	DamageInfo_ScaleDamage( damageInfo, 0 )

	int maxHealth = trophy.GetMaxHealth()
	int health    = trophy.GetHealth()

	float newHealth = max( health - damage, 0.0 )

	if ( newHealth <= 0.0 )
		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_TROPHY_SYSTEM, trophy, trophy.GetOrigin(), attackerTeam, attacker )

	float healthFrac = newHealth / maxHealth

	float currTime        = Time()
	float damageTimeDelta = currTime - file.lastDamageFxTime[trophy]
	if ( (healthFrac <= 0.99) && (damageTimeDelta >= TROPHY_DAMAGE_FX_INTERVAL) )
	{
		Trophy_PlayDamagedFX( trophy )
		file.lastDamageFxTime[trophy] = currTime
	}

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	if ( newHealth <= 0 )
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	else
		DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )

	if ( attacker.IsPlayer() && !IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		attacker.NotifyDidDamage( trophy, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			damage, DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}
	trophy.SetHealth( newHealth )
}

void function Trophy_CancelPlacement( entity player )
{
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( activeWeapon ) )
			return

		if ( activeWeapon.GetWeaponClassName() != "mp_weapon_trophy_defense_system" )
			return
		//printt( "PLAYER IS USING OFFHAND WEAPON." )
	}
	else
	{
		//printt( "PLAYER IS NOT USING OFFHAND WEAPON" )
		return
	}

	//Swap back to the player's main weapon when we cancel trophy system placement
	SwapToLastEquippedPrimary( player )
}
#endif //SERVER


#if CLIENT
void function Trophy_OnWeaponStatusUpdate( entity player, var rui, int slot )
{
	if ( slot != OFFHAND_TACTICAL )
		return

	entity weapon = player.GetOffhandWeapon( slot )
	if ( !IsValid( weapon ) )
		return

	bool activeSuperChargeApplied = weapon.HasMod( "interception_pylon_super_charge" )
	RuiSetBool( rui, "rechargeBoosted", activeSuperChargeApplied )
}
#endif


#if CLIENT
void function TacticalChargeVisualsEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent != GetLocalViewPlayer() )
		return

	entity player = ent

	entity cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	thread TacticalChargeFXThink( player, cockpit )
}

void function TacticalChargeVisualsDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent != GetLocalViewPlayer() )
		return

	ent.Signal( "EndTacticalChargeRepair" )
}

void function TacticalChargeFXThink( entity player, entity cockpit )
{
	EndSignal( player, "EndTacticalChargeRepair", "OnDeath" )
	EndSignal( cockpit, "OnDestroy" )

	entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	if ( !IsValid( tacticalWeapon ) )
		return

	string weaponName = tacticalWeapon.GetWeaponClassName()
	if ( weaponName != "mp_weapon_tesla_trap" )
		return

	tacticalWeapon.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			if ( !EffectDoesExist( file.tacticalChargeFXHandle ) )
				return

			EffectStop( file.tacticalChargeFXHandle, false, true )
		}
	)

	for ( ; ; )
	{
		if ( !EffectDoesExist( file.tacticalChargeFXHandle ) )
		{
			file.tacticalChargeFXHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( TACTICAL_CHARGE_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
			EffectSetIsWithCockpit( file.tacticalChargeFXHandle, true )
			EmitSoundOnEntity( player, TROPHY_TACTICAL_CHARGE_SOUND )
		}

		vector controlPoint = <1, 1, 1>
		EffectSetControlPointVector( file.tacticalChargeFXHandle, 1, controlPoint )
		WaitFrame()
	}
}

void function OnWaypointCreated( entity wp )
{
	int wpType = wp.GetWaypointType()

	if ( wpType == eWaypoint.WATTSON_TROPHY_TIMER )
		thread WattsonTimerWaypointThink( wp )
	else if ( wpType == eWaypoint.WATTSON_TROPHY_LIFE )
		thread WattsonShieldsWaypointThink( wp )
}

void function WattsonTimerWaypointThink( entity wp )
{
	wp.SetDoDestroyCallback( true )
	wp.EndSignal( "OnDestroy" )

	float width  = 220
	float height = 220
	vector right = <0, 1, 0> * height * 0.5
	vector fwd   = <1, 0, 0> * width * 0.5 * -1.0
	vector org   = <0, 0, 0>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, fwd, right, true )
	RuiTopology_SetParent( topo, wp )

	array<var> ruis
	var rui = RuiCreate( $"ui/wattson_ult_cooldown_timer.rpak", topo, RUI_DRAW_WORLD, 1 )

	float startTime = wp.GetWaypointGametime( 0 )
	float endTime   = wp.GetWaypointGametime( 1 )

	RuiSetGameTime( rui, "startTime", startTime )
	RuiSetGameTime( rui, "endTime", endTime )

	ruis.append( rui )

	bool isOwned = wp.GetOwner() == GetLocalViewPlayer()

	var ownedRui
	if ( isOwned )
	{
		ownedRui = CreateCockpitRui( $"ui/wattson_ult_cooldown_timer_world.rpak", 1 )
		RuiTrackFloat3( ownedRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiSetGameTime( ownedRui, "startTime", startTime )
		RuiSetGameTime( ownedRui, "endTime", endTime )
		ruis.append( ownedRui )
	}

	OnThreadEnd(
		function() : ( topo, ruis )
		{
			foreach ( rui in ruis )
				RuiDestroy( rui )
			RuiTopology_Destroy( topo )
		}
	)

	if ( isOwned )
	{
		while ( IsValid( wp ) )
		{
			entity player = GetLocalViewPlayer()
			bool canTrace = false
			bool isFar    = Distance( player.EyePosition(), wp.GetOrigin() ) > TROPHY_COOLDOWN_DRAW_DIST_MIN
			if ( !isFar )
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				canTrace = results.fraction > 0.95
			}
			RuiSetBool( ownedRui, "isVisible", !canTrace || isFar )
			WaitFrame()
		}
	}
	else
	{
		WaitForever()
	}
}

void function WattsonLifeWaypointThink( entity wp )
{
	wp.SetDoDestroyCallback( true )
	wp.EndSignal( "OnDestroy" )

	float width  = 220
	float height = 220
	vector right = <0, 1, 0> * height * 0.5
	vector fwd   = <1, 0, 0> * width * 0.5 * -1.0
	vector org   = <0, 0, 0>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, fwd, right, true )
	RuiTopology_SetParent( topo, wp )

	array<var> ruis
	var rui = RuiCreate( $"ui/wattson_ult_cooldown_count.rpak", topo, RUI_DRAW_WORLD, 1 )

	int maxCount = wp.GetWaypointInt( 1 )

	RuiTrackInt( rui, "currentCount", wp, RUI_TRACK_WAYPOINT_INT, 0 )
	RuiTrackInt( rui, "maxCount", wp, RUI_TRACK_WAYPOINT_INT, 1 )

	ruis.append( rui )

	bool isOwned = IsFriendlyTeam( wp.GetTeam(), GetLocalViewPlayer().GetTeam() )

	var ownedRui
	if ( isOwned )
	{
		ownedRui = CreateCockpitRui( $"ui/wattson_ult_cooldown_count_world.rpak", 1 )
		RuiTrackFloat3( ownedRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackInt( ownedRui, "currentCount", wp, RUI_TRACK_WAYPOINT_INT, 0 )
		RuiTrackInt( ownedRui, "maxCount", wp, RUI_TRACK_WAYPOINT_INT, 1 )
		ruis.append( ownedRui )
	}

	OnThreadEnd(
		function() : ( topo, ruis )
		{
			foreach ( rui in ruis )
				RuiDestroy( rui )
			RuiTopology_Destroy( topo )
		}
	)

	if ( isOwned )
	{
		while ( IsValid( wp ) )
		{
			entity player = GetLocalViewPlayer()
			bool canTrace = false
			bool isFar    = Distance( player.EyePosition(), wp.GetOrigin() ) > TROPHY_COOLDOWN_DRAW_DIST_MIN
			if ( !isFar )
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				canTrace = results.fraction > 0.95
			}
			RuiSetBool( ownedRui, "isVisible", !canTrace || isFar )

			WaitFrame()
		}
	}
	else
	{
		WaitForever()
	}
}

void function WattsonShieldsWaypointThink( entity wp )
{
	wp.SetDoDestroyCallback( true )
	EndSignal( wp, "OnDestroy" )

	float width  = 220
	float height = 220
	vector right = <0, 1, 0> * height * 0.5
	vector fwd   = <1, 0, 0> * width * 0.5 * -1.0
	vector org   = <0, 0, 2>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, fwd, right, true )
	RuiTopology_SetParent( topo, wp )

	array<var> ruis
	var rui = RuiCreate( $"ui/wattson_ult_shields.rpak", topo, RUI_DRAW_WORLD, 1 )

	int maxCount = wp.GetWaypointInt( 1 )

	RuiTrackInt( rui, "currentShields", wp, RUI_TRACK_WAYPOINT_INT, 0 )
	RuiTrackInt( rui, "totalShields", wp, RUI_TRACK_WAYPOINT_INT, 1 )

	ruis.append( rui )

	bool isOwned = IsFriendlyTeam( wp.GetTeam(), GetLocalViewPlayer().GetTeam() )

	var ownedRui
	if ( isOwned )
	{
		ownedRui = CreateCockpitRui( $"ui/wattson_ult_shields_world.rpak", 1 )
		RuiTrackInt( ownedRui, "currentShields", wp, RUI_TRACK_WAYPOINT_INT, 0 )
		RuiTrackInt( ownedRui, "totalShields", wp, RUI_TRACK_WAYPOINT_INT, 1 )
		ruis.append( ownedRui )
	}

	OnThreadEnd(
		function() : ( topo, ruis )
		{
			foreach ( rui in ruis )
				RuiDestroy( rui )
			RuiTopology_Destroy( topo )
		}
	)

	if ( isOwned )
	{
		while ( IsValid( wp ) )
		{
			vector waypointOrigin = wp.GetOrigin() + wp.GetUpVector() * TROPHY_ICON_HEIGHT
			RuiSetFloat3( ownedRui, "worldPos", waypointOrigin )

			entity player = GetLocalViewPlayer()
			bool canTrace = false
			float distance = Distance( player.EyePosition(), waypointOrigin )
			bool isPastRangeMax = distance > TROPHY_COOLDOWN_DRAW_DIST_MAX
			bool isPastRangeMin = distance > TROPHY_COOLDOWN_DRAW_DIST_MIN
			if ( !isPastRangeMax && !isPastRangeMin )
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				canTrace = results.fraction > 0.95
			}
			RuiSetBool( ownedRui, "isVisible", !isPastRangeMax && ( !canTrace || isPastRangeMin ) )

			WaitFrame()
		}
	}
	else
	{
		WaitForever()
	}
}

void function FullmapPackage_TrophySystem( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/wattson_ult_map_icon" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
}

void function MinimapPackage_TrophySystem( entity ent, var rui )
{
	RuiSetImage( rui, "centerImage", $"rui/hud/gametype_icons/survival/wattson_ult_map_icon" )
	RuiSetImage( rui, "clampedImage", $"" )
	if ( ent.IsClientOnly() )
		RuiSetFloat( rui, "objectRadius", ent.e.clientEntMinimapScale )
	else
		RuiTrackFloat( rui, "objectRadius", ent, RUI_TRACK_MINIMAP_SCALE )
}
#endif //CLIENT

int function GetTrophySystem_MaxHealth( entity owner )
{
	int maxHealth = TROPHY_HEALTH_AMOUNT


	if ( IsValid( owner ) && PlayerHasPassive( owner, ePassives.PAS_BATTERY_POWERED ) && PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) //upgrade_wattson_ult_pylon_hp_inc
	{
		maxHealth *= 2
	}


	return maxHealth
}

int function GetTrophySystem_MaxShieldCapacity( entity trophy )
{
	int maxCapacity = file.trophy_shieldPoolAmount
	entity owner = trophy.GetOwner()


	if ( IsValid( owner ) && PlayerHasPassive( owner, ePassives.PAS_BATTERY_POWERED ) && PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) //upgrade_wattson_ult_pylon_hp_inc
	{
		maxCapacity *= 2
	}

	return maxCapacity
}

int function GetTrophySystem_MaxTrophyCount( entity owner )
{
	int maxCount = file.trophy_maxCount


	if ( IsValid( owner ) && PlayerHasPassive( owner, ePassives.PAS_BATTERY_POWERED ) && PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_ONE ) )  //upgrade_wattson_ult_max_pylon_inc
	{
		maxCount = 2
	}


	return maxCount
}
 