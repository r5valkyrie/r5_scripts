             
global function MpAbilityPhaseDoor_Init
global function OnWeaponActivate_ability_phase_door
global function OnWeaponDeactivate_ability_phase_door
global function OnWeaponTossReleaseAnimEvent_ability_phase_door
global function OnProjectileCollision_ability_phase_door
global function PhaseDoor_CheckInvalidEnt

#if CLIENT
global function OnCreateClientOnlyModel_ability_phase_door
#endif

#if DEV
#if SERVER
global function AlterTacTest
#endif
#endif

const float PHASE_DOOR_WARNING_DURATION = 5.0

const int PHASE_DOOR_TRIGGER_RADIUS 	= 20
const float PHASE_DOOR_PORTAL_EXTENSION_WIDTH = 2

//signals
#if SERVER
const string PHASE_DOOR_RETURN_WEAPONS_SIGNAL = "PhaseDoor_ReturnWeapons"
global const string PHASE_DOOR_TELEPORT_SIGNAL = "PhaseDoor_Teleport"
#endif
#if CLIENT
const string PHASE_DOOR_STOP_VISUAL_EFFECT = "PhaseDoor_StopVisualEffect"
#endif

//script names
global const string PHASE_DOOR_ROOT_ENT_SCRIPTNAME = "phase_door_root_ent"
global const string PHASE_DOOR_WARMUP_ENT_SCRIPTNAME = "phase_door_warmup_ent"
global const string PHASE_DOOR_TRACE_BLOCKER_SCRIPTNAME = "alter_tac_trace_blocker"
global const string PHASE_DOOR_PORTAL_EXTENSION_SCRIPTNAME = "alter_tac_portal_extension"
global const string PHASE_DOOR_PORTAL_EXTENSION_MOVER_SCRIPTNAME = "alter_tac_portal_extension_mover"
const string PHASE_DOOR_WEAPON_NAME = "mp_ability_phase_door"
#if CLIENT
global const string PHASE_DOOR_THREAT_INDICATOR_SCRIPTNAME = "phase_door_threat"
#endif

//sounds
const string PHASE_DOOR_SPAWN_SOUND = "Alter_Tac_Portal_Activate_3p"
const string PHASE_DOOR_LOOP_SOUND = "Alter_Tac_Portal_Active_3p"
const string PHASE_DOOR_WARPIN_SOUND_3P = "Alter_Tac_Portal_Enter_3p"
const string PHASE_DOOR_WARPIN_SOUND_1P = "Alter_Tac_Portal_Enter_1p"
const string PHASE_DOOR_WARPOUT_SOUND_3P = "Alter_Tac_Portal_Exit_3p"
const string PHASE_DOOR_ENDING_WARNING_SOUND = "Alter_Tac_Portal_Ending_3p"
const string PHASE_DOOR_PHASE_IN_LIFT_1P = "Alter_Tac_Portal_Lift_Enter_1p"
const string PHASE_DOOR_PHASE_IN_LIFT_3P = "Alter_Tac_Portal_Lift_Enter_3p"
const string PHASE_DOOR_ROPE_SOUND = "Alter_Tac_Portal_Lift_Base_LP"

//fx
const asset PHASE_DOOR_FX = $"P_alter_tac_portal"
const asset PHASE_DOOR_ENTER_FX = $"P_alter_tac_portal_warp_in"
const asset PHASE_DOOR_EXIT_FX = $"P_alter_tac_portal_warp"
const asset PHASE_DOOR_WARP_SCREEN_FX = $"P_alter_tac_portal_warp_screen"
const asset PHASE_DOOR_SPAWN_FX = $"P_alter_tac_portal_warmup"
const asset PHASE_DOOR_PREVIEW_FX = $"P_alter_tac_portal_preview"
const asset PHASE_DOOR_PREVIEW_EXIT_FX = $"P_alter_tac_portal_preview_exit"
const asset PHASE_DOOR_ROPE_FX = $"P_alter_tac_portal_rope"
const asset PHASE_DOOR_PLAYER_ON_ROPE_FX = $"P_alter_tac_portal_warp_rope"
const asset PHASE_DOOR_PHASED_PLAYER_FX = $"P_alter_tac_portal_warp_body"

const vector PHASE_DOOR_FX_COLOUR_FRIENDLY = <123, 159, 242>
const vector PHASE_DOOR_FX_COLOUR_ENEMY = <185, 52, 52>
const float PHASE_DOOR_FX_ENEMY_SHOW_DIST_MIN = 5 * METERS_TO_INCHES
const float PHASE_DOOR_FX_ENEMY_SHOW_DIST_MAX = 15 * METERS_TO_INCHES

const float surfaceOffset = 1.0

#if CLIENT
global const bool PHASE_DOOR_DEBUG_DRAW = false
#endif
#if SERVER
global const bool PHASE_DOOR_DEBUG_DRAW = false
#endif

//this is just for debugging
const bool PHASE_DOOR_DEBUG_ENABLE_FF_SELF_CHECK = true

global const bool PHASE_DOOR_PORTAL_EXTENSIONS_DEBUG_DRAW = false

#if DEV
global const bool PHASE_DOOR_LOGGING = true
#else
global const bool PHASE_DOOR_LOGGING = false
#endif

enum ePhaseDoorOrientation
{
	PHASE_DOOR_ORIENTATION_WALL,
	PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_UP //going through a ceiling
	PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_DOWN, //going through a floor
}

struct LastPhaseDoorEnteredData
{
	entity triggerEntered
	entity triggerExited
	float enteredTime
}

struct BreachKillerChallengeConditions
{
	bool isActive
	bool knockSecured
	entity entrancePortal
}

struct
{
	//DO NOT CHANGE THIS. It needs to be changed in code too
	float wallThicknessMax = 20.0 * METERS_TO_INCHES
	#if SERVER
	float portalDuration = 15
	float plantDelay = 0.7

	float reEnterDebounce = 1.35

	float exitVelocityMin = 50
	float exitVelocityMax = 300

	bool doPostPortalPhaseShift = true
	float postPortalPhaseShiftDuration = 1.0
	bool teleportTeammatesOnPortalOpen = true
	bool allowWraithUlt = true

	bool portalBlocksOtherPortals = true
	bool portalBlocksObjectPlacement = true

	float extensionTravelSpeed = 400
	#endif

	bool  spawnCeilingPortalExtensions = true
	bool  spawnWallPortalExtensions = false
	float wallExtensionMinLength = 4.5
	float extensionMaxZHeight = 30
	float extensionMaxHeightNoGround = 0.0
	float ceilingPortalExtensionAngle = 60

	#if CLIENT
	bool createThreatIndicator = true
	float threatIndicatorRange = 15.0
	float threatIndicatorLifetime = 1.5
	#endif
} tuning

struct
{
	table<string, bool> invalidEntityScriptNames

	table<entity, float> lastEnteredPhaseDoorTime
	#if SERVER
	table<entity, entity> phaseDoorPairings
	table<entity, vector> portalExitDir
	table<entity, entity> lastPortalEntranceUsed
	table<entity, entity> triggerToRootEntMap
	table<entity, LastPhaseDoorEnteredData> playerLastPhaseDoorEnteredData

	table<entity, array<entity> > portalExtensionToPlayersUsingMap
	#endif
	#if CLIENT
	var placementDepthRui
	entity entrancePortalPlacementFXHolder
	entity exitPortalPlacementFXHolder
	int entrancePortalPlacementVFXHandle
	int exitPortalPlacementVFXHandle

	bool portalFXInitialized = false
	#endif

	// Breach Killer Challenge
	#if SERVER
		table< entity, BreachKillerChallengeConditions > breachKillerConditionsPerAlter
	#endif
} file

#if DEV
#if SERVER
void function AlterTacTest( entity player )
{
	vector triggerPos = <-34956, 4013, 1821>
	vector triggerAng = <0, 130, 0>
	float radius = 8000
	float height = 4000
	DebugDrawCylinder( triggerPos, triggerAng, radius,height, COLOR_RED, false, 15 )
	//DrawAngledBox( triggerPos, triggerAng, <-2000,-2000, -2000>, <2000, 2000, 20>, COLOR_RED, false, 10 )
	//tuning.portalDuration = 60
	//thread AlterTacTest_Thread( player )
}

void function AlterTacTest_Thread( entity player )
{
	while( true )
	{
		DebugDrawMark( player.GetOrigin(), 10, COLOR_RED, true, 5.0 )
		WaitFrame()
	}
}

bool function IsValidMapForAutoReporting()
{
	array<string> validMaps = [
		"mp_rr_box",
		"mp_rr_canyonlands_staging",
		"mp_rr_canyonlands",
		"mp_rr_desertlands",
		"mp_rr_olympus",
		"mp_rr_tropic_island",
		"mp_rr_divided_moon",
		"mp_rr_district",
		"mp_rr_thunderdome",
		"mp_rr_freedm_skulltown",
		"mp_rr_aqueduct",
		"mp_rr_arena_habitat",
		"mp_rr_party_crasher",
		"mp_rr_arena_phase_runner",
		"mp_rr_arena_skygarden"
	]

	string mapName = GetMapName()


	foreach ( string map in validMaps )
	{
		if( mapName.find( map ) >= 0 )
		{
			return true
		}
	}

	return false
}
#endif
#endif

void function MpAbilityPhaseDoor_Init()
{
	SetupTuning()

	PrecacheParticleSystem( PHASE_DOOR_FX )
	PrecacheParticleSystem( PHASE_DOOR_ENTER_FX )
	PrecacheParticleSystem( PHASE_DOOR_EXIT_FX )
	PrecacheParticleSystem( PHASE_DOOR_WARP_SCREEN_FX )
	PrecacheParticleSystem( PHASE_DOOR_SPAWN_FX )
	PrecacheParticleSystem( PHASE_DOOR_PREVIEW_FX )
	PrecacheParticleSystem( PHASE_DOOR_PREVIEW_EXIT_FX )
	PrecacheParticleSystem( PHASE_DOOR_ROPE_FX )
	PrecacheParticleSystem( PHASE_DOOR_PLAYER_ON_ROPE_FX )
	PrecacheParticleSystem( PHASE_DOOR_PHASED_PLAYER_FX )

	PrecacheScriptString( PHASE_DOOR_ROOT_ENT_SCRIPTNAME )
	PrecacheScriptString( PHASE_DOOR_WARMUP_ENT_SCRIPTNAME )
	PrecacheScriptString( PHASE_DOOR_TRACE_BLOCKER_SCRIPTNAME )
	PrecacheScriptString( PHASE_DOOR_PORTAL_EXTENSION_SCRIPTNAME )
	PrecacheScriptString( PHASE_DOOR_PORTAL_EXTENSION_MOVER_SCRIPTNAME )

	#if CLIENT
	RegisterSignal( PHASE_DOOR_STOP_VISUAL_EFFECT )
	AddCreateCallback( "prop_script", OnPropCreated )
	AddCreateCallback( "prop_dynamic", OnPropCreated )
	AddCallback_OnViewPlayerChanged( OnViewPlayerChanged )

	StatusEffect_RegisterEnabledCallback( eStatusEffect.phase_door_teleport_visual_effect, StartVisualEffect )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.phase_door_teleport_visual_effect, StopVisualEffect )
	#endif

	#if SERVER
		RegisterSignal( PHASE_DOOR_RETURN_WEAPONS_SIGNAL )
		RegisterSignal( PHASE_DOOR_TELEPORT_SIGNAL )

		AddNoObjectPlacementSpecialTriggersViaPlaylist()
	#endif

	SetupInvalidScriptNames()

	// Breach Killer Challenge
	if( IsBreachKillerChallengeEnabled() )
	{
		#if SERVER
			Bleedout_AddCallback_OnPlayerStartBleedout( BreachKillerChallenge_OnKnock )
			AddCallback_OnPlayerKilled( BreachKillerChallenge_OnKill )
			RegisterSignal( "CancelBreachKillerChallenge" )
			RegisterSignal( "BreachKillerChallenge_EnemyKnocked" )
			RegisterSignal( "BreachKillerChallenge_ExitPortal" )
		#endif
	}
}

void function SetupTuning()
{
	//do not override this number! It needs to be changed in code too
	//tuning.wallThicknessMax             = GetCurrentPlaylistVarFloat( "alter_tac_wallThicknessMax", tuning.wallThicknessMax )
	#if SERVER
	tuning.portalDuration               = GetCurrentPlaylistVarFloat( "alter_tac_portalDuration", tuning.portalDuration )
	tuning.plantDelay                   = GetCurrentPlaylistVarFloat( "alter_tac_plantDelay", tuning.plantDelay )
	tuning.reEnterDebounce              = GetCurrentPlaylistVarFloat( "alter_tac_reEnterDebounce", tuning.reEnterDebounce )
	tuning.exitVelocityMin              = GetCurrentPlaylistVarFloat( "alter_tac_exitVelocityMin", tuning.exitVelocityMin )
	tuning.exitVelocityMax              = GetCurrentPlaylistVarFloat( "alter_tac_exitVelocityMax", tuning.exitVelocityMax )
	tuning.doPostPortalPhaseShift       = GetCurrentPlaylistVarBool( "alter_tac_doPostPortalPhaseShift", tuning.doPostPortalPhaseShift )
	tuning.postPortalPhaseShiftDuration = GetCurrentPlaylistVarFloat( "alter_tac_postPortalPhaseShiftDuration", tuning.postPortalPhaseShiftDuration )
	tuning.teleportTeammatesOnPortalOpen = GetCurrentPlaylistVarBool( "alter_tac_teleportTeammatesOnPortalOpen", tuning.teleportTeammatesOnPortalOpen )
	tuning.allowWraithUlt               = GetCurrentPlaylistVarBool( "alter_tac_allowWraithUlt", tuning.allowWraithUlt )
	tuning.portalBlocksOtherPortals     = GetCurrentPlaylistVarBool( "alter_tac_portalBlocksOtherPortals", tuning.portalBlocksOtherPortals )
	tuning.portalBlocksObjectPlacement  = GetCurrentPlaylistVarBool( "alter_tac_portalBlocksObjectPlacement", tuning.portalBlocksObjectPlacement )
	tuning.extensionTravelSpeed         = GetCurrentPlaylistVarFloat( "alter_tac_extensionTravelSpeed", tuning.extensionTravelSpeed )
	#endif

	tuning.spawnCeilingPortalExtensions = GetCurrentPlaylistVarBool( "alter_tac_spawnCeilingPortalExtensions", tuning.spawnCeilingPortalExtensions )
	tuning.spawnWallPortalExtensions 	= GetCurrentPlaylistVarBool( "alter_tac_spawnWallPortalExtensions", tuning.spawnWallPortalExtensions )
	tuning.wallExtensionMinLength       = GetCurrentPlaylistVarFloat( "alter_tac_wallExtensionMinLength", tuning.wallExtensionMinLength ) * METERS_TO_INCHES
	tuning.extensionMaxZHeight          = GetCurrentPlaylistVarFloat( "alter_tac_extensionMaxZHeight", tuning.extensionMaxZHeight ) * METERS_TO_INCHES
	tuning.extensionMaxHeightNoGround   = GetCurrentPlaylistVarFloat( "alter_tac_extensionMaxHeightNoGround", tuning.extensionMaxHeightNoGround ) * METERS_TO_INCHES
	tuning.ceilingPortalExtensionAngle  = cos( GetCurrentPlaylistVarFloat( "alter_tac_ceilingPortalExtensionAngle", tuning.ceilingPortalExtensionAngle ) * DEG_TO_RAD )

	#if CLIENT
	tuning.createThreatIndicator        = GetCurrentPlaylistVarBool( "alter_tac_createThreatIndicator", tuning.createThreatIndicator )
	tuning.threatIndicatorRange         = GetCurrentPlaylistVarFloat( "alter_tac_threatIndicatorRange", tuning.threatIndicatorRange ) * METERS_TO_INCHES
	tuning.threatIndicatorLifetime      = GetCurrentPlaylistVarFloat( "alter_tac_threatIndicatorLifetime", tuning.threatIndicatorLifetime )
	#endif
}

void function SetupInvalidScriptNames()
{
	file.invalidEntityScriptNames[ "jump_tower" ] <- true
	file.invalidEntityScriptNames[ "survival_door_plain" ] <- true
	file.invalidEntityScriptNames[ "GRAVITY_CANNON" ] <- true
	file.invalidEntityScriptNames[ "gravity_cannon" ] <- true
	file.invalidEntityScriptNames[ SPIDER_EGG_SCRIPT_NAME ] <- true
	file.invalidEntityScriptNames[ SPIDER_HATCHED_EGG_EDITOR_CLASS_KEYWORD ] <- true
	file.invalidEntityScriptNames[ HATCH_MDL_SCRIPTNAME ] <- true//blood TT
	file.invalidEntityScriptNames[ REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME ] <- true
	file.invalidEntityScriptNames[ CARE_PACKAGE_SCRIPTNAME ] <- true
	//file.invalidEntityScriptNames[ RESPAWN_CHAMBER_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ HARVESTER_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ WORKBENCH_CLUSTER_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ WORKBENCH_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ WORKBENCH_CLUSTER_AIRDROPPED_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ ENEMY_SURVEY_BEACON_SCRIPTNAME ] <- true

	//ignored and invaild (can't start on it, but ignored otherwise)
	file.invalidEntityScriptNames[ ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME ] <- true
	file.invalidEntityScriptNames[ TROPHY_SYSTEM_NAME ] <- true

	file.invalidEntityScriptNames[ UPGRADE_CORE_CONSOLE_SCRIPT_NAME ] <- true

	//file.invalidEntityScriptNames[ JUMP_PAD_SCRIPTNAME ] <- true
	//file.invalidEntityScriptNames[ JUMP_PAD_UPGRADE_TARGETNAME ] <- true

}

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________WeaponFuncs___________________________(){}
#endif
void function OnWeaponActivate_ability_phase_door( entity weapon )
{
	#if CLIENT
		entity player = GetLocalViewPlayer()
		if ( weapon.GetOwner() == player && file.placementDepthRui == null )
		{
			file.placementDepthRui = CreateFullscreenRui( $"ui/alter_depth_meter.rpak" )
		}
		weapon.SetSoundCodeControllerValue_ClientOverride( 0.0 )
	#endif
}

void function OnWeaponDeactivate_ability_phase_door( entity weapon )
{
	#if CLIENT
	entity player = weapon.GetOwner()

	if ( player != GetLocalViewPlayer() )
		return

	DeactivateClientPreviewFxRui()
	weapon.UnsetSoundCodeControllerValue_ClientOverride()
	#endif
}

#if CLIENT
void function OnCreateClientOnlyModel_ability_phase_door( entity weapon, entity model, bool validHighlight )
{
	const vector COLOR_DEPTH_INVALID	= <252, 60, 45>
	const vector COLOR_DEPTH_START 		= <255, 122, 0>
	const vector COLOR_DEPTH_MID 		= <255, 210, 73>
	const vector COLOR_DEPTH_END 		= <255, 255, 255>

	vector entranceOrigin = ZERO_VECTOR//weapon.GetObjectPlacementOrigin()
	vector entranceAngles = ZERO_VECTOR//weapon.GetObjectPlacementAngles()
	vector exitOrigin = weapon.GetObjectPlacementSpecialOrigin()
	vector exitAngles = weapon.GetObjectPlacementSpecialAngles()

	int result = weapon.GetObjectPlacementSpecialPlacementResult()

	int fxID = GetParticleSystemIndex( PHASE_DOOR_PREVIEW_FX )
	int exitFxID = GetParticleSystemIndex( PHASE_DOOR_PREVIEW_EXIT_FX )

	if ( !IsValid( file.entrancePortalPlacementFXHolder ) )
	{
		file.entrancePortalPlacementFXHolder = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, $"mdl/dev/empty_model.rmdl" )
		file.exitPortalPlacementFXHolder = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, $"mdl/dev/empty_model.rmdl" )
	}

	vector entranceFxAngles = AnglesCompose( entranceAngles, <0,90,90> )
	vector entranceOffset = RotateVector(<2,0,0>, entranceAngles)

	vector exitFxAngles = AnglesCompose( exitAngles, <0,90,90> )
	vector exitOffset = RotateVector(<5,0,0>, exitAngles)

	file.entrancePortalPlacementFXHolder.SetOrigin( entranceOrigin + entranceOffset )
	file.entrancePortalPlacementFXHolder.SetAngles( entranceFxAngles )
	file.exitPortalPlacementFXHolder.SetOrigin( exitOrigin + exitOffset )
	file.exitPortalPlacementFXHolder.SetAngles( exitFxAngles )

	float distanceBetweenPortals = -1
	vector color = COLOR_DEPTH_INVALID
	if ( !file.portalFXInitialized )
	{
		file.entrancePortalPlacementVFXHandle = StartParticleEffectOnEntity( file.entrancePortalPlacementFXHolder, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
		file.exitPortalPlacementVFXHandle = StartParticleEffectOnEntity( file.exitPortalPlacementFXHolder, exitFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

		file.portalFXInitialized = true
	}

	distanceBetweenPortals = Distance( entranceOrigin, exitOrigin )
	if ( validHighlight )
	{
		distanceBetweenPortals = min( distanceBetweenPortals, tuning.wallThicknessMax )
		float distanceFrac = distanceBetweenPortals / tuning.wallThicknessMax
		color = GetTriLerpColor( distanceFrac, COLOR_DEPTH_END, COLOR_DEPTH_MID, COLOR_DEPTH_START, 0.6, 0.3 )
	}
	else
	{
		distanceBetweenPortals = max( distanceBetweenPortals, (tuning.wallThicknessMax + 0.02) )
	}

	if ( file.placementDepthRui == null )
	{
		file.placementDepthRui = CreateFullscreenRui( $"ui/alter_depth_meter.rpak" )
	}

	bool showExitFX = true
	bool hasTextOverride = true
	string textOverride
	switch ( result )
	{
		case OPSPR_SUCCESS:
			hasTextOverride = false
			break
		case OPSPR_TOO_FAR:
			textOverride = "#ABL_TAC_PHASE_DOOR_TOO_FAR"
			showExitFX = false
			break
		case OPSPR_TOO_DEEP:
			hasTextOverride = false
			break
		case OPSPR_ENTRANCE_BLOCKED:
		case OPSPR_ENTRANCE_INVALID_SPACE:
		case OPSPR_ENTRANCE_INVALID_OBJECT:
		case OPSPR_ENTRANCE_UNSAFE:
			textOverride = "#ABL_TAC_PHASE_DOOR_ENTRANCE_INVALID"
			showExitFX = false
			break
		case OPSPR_EXIT_BLOCKED:
		case OPSPR_EXIT_INVALID_OBJECT:
		case OPSPR_EXIT_INVALID_SPACE:
		case OPSPR_EXIT_UNSAFE:
			textOverride = "#ABL_TAC_PHASE_DOOR_EXIT_INVALID"
			showExitFX = false
			break
		case OPSPR_EXIT_NORMAL_ALIGNED:
		case OPSPR_TOO_COMPLEX:
		case OPSPR_OTHER:
			textOverride = "#ABL_TAC_PHASE_DOOR_OTHER"
			showExitFX = false
			break
	}

	if ( validHighlight )
	{
		EffectSetControlPointVector( file.entrancePortalPlacementVFXHandle, 3, PHASE_DOOR_FX_COLOUR_FRIENDLY )
		EffectSetControlPointVector( file.exitPortalPlacementVFXHandle, 3, color )
	}
	else
	{
		vector hideColour = <0,0,0>
		EffectSetControlPointVector( file.entrancePortalPlacementVFXHandle, 3, color )
		EffectSetControlPointVector( file.exitPortalPlacementVFXHandle, 3, showExitFX ? color : hideColour )
	}

	bool hasRope = false
	if ( validHighlight )
	{
		vector origin = entranceOrigin
		int portalOrientation = GetPortalDirectionForPortalExtension( AnglesToForward( entranceAngles ) )
		if ( !( portalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_DOWN ) )
		{
			origin = exitOrigin
			portalOrientation = GetPortalDirectionForPortalExtension( AnglesToForward( exitAngles ) )
		}

		PassByReferenceVector portalExtensionStartPos
		PassByReferenceVector portalExtensionEndPos
		if ( tuning.spawnCeilingPortalExtensions && (portalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_DOWN) )
		{
			hasRope = ShouldCreateVerticalPortalExtension( origin, portalExtensionStartPos, portalExtensionEndPos )
		}
	}

	float distanceRatioForSound = validHighlight ? (distanceBetweenPortals / tuning.wallThicknessMax ) * 0.9 : 1.0
	weapon.SetSoundCodeControllerValue_ClientOverride( distanceRatioForSound )

	RuiSetFloat( file.placementDepthRui, "depth", distanceBetweenPortals )
	RuiSetFloat3( file.placementDepthRui, "infoTextColorRGB", (color / 255.0) )
	RuiSetBool( file.placementDepthRui, "hasTextOverride", hasTextOverride )
	RuiSetBool( file.placementDepthRui, "hasRope", hasRope )
	if ( hasTextOverride )
	{
		RuiSetString( file.placementDepthRui, "textOverride", Localize( textOverride ) )
	}
}
#endif

#if CLIENT
void function DeactivateClientPreviewFxRui( )
{
	if ( file.placementDepthRui != null )
	{
		RuiDestroyIfAlive( file.placementDepthRui )
		file.placementDepthRui = null
	}

	if ( EffectDoesExist( file.entrancePortalPlacementVFXHandle ) )
		EffectStop( file.entrancePortalPlacementVFXHandle, true, false )

	if ( EffectDoesExist( file.exitPortalPlacementVFXHandle ) )
		EffectStop( file.exitPortalPlacementVFXHandle, true, false )

	if ( IsValid( file.entrancePortalPlacementFXHolder ) )
		file.entrancePortalPlacementFXHolder.Destroy()

	if ( IsValid( file.exitPortalPlacementFXHolder ) )
		file.exitPortalPlacementFXHolder.Destroy()

	file.portalFXInitialized = false
}
#endif

#if CLIENT
void function OnViewPlayerChanged( entity player )
{
	if ( file.placementDepthRui != null || file.portalFXInitialized )
	{
		DeactivateClientPreviewFxRui()
	}
}
#endif

var function OnWeaponTossReleaseAnimEvent_ability_phase_door( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	vector origin = ZERO_VECTOR//weapon.GetObjectPlacementOrigin()
	vector surfaceNormal = ZERO_VECTOR//AnglesToForward( weapon.GetObjectPlacementAngles() )
	entity entranceParent = weapon.GetParent()
	vector exitOrigin = ZERO_VECTOR//weapon.GetObjectPlacementSpecialOrigin()
	vector exitSurfaceNormal = ZERO_VECTOR//AnglesToForward( weapon.GetObjectPlacementSpecialAngles() )
	entity exitParent = weapon.GetParent()

	// Check for valid spot
	//if ( !weapon.ObjectPlacementHasValidSpot() )
	//{
	//	weapon.StartCustomActivity( "ACT_VM_MISSCENTER", WCAF_PLAYRAISEONCOMPLETE )
	//	return 0
	//}

	entity ownerPlayer = weapon.GetWeaponOwner()
	#if CLIENT
		if ( ownerPlayer == GetLocalViewPlayer() )
		{
			DeactivateClientPreviewFxRui()
		}
	#endif

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	bool projectilePredicted      = PROJECTILE_PREDICTED
	bool projectileLagCompensated = PROJECTILE_LAG_COMPENSATED
	#if SERVER
		if ( weapon.IsForceReleaseFromServer() )
		{
			projectilePredicted = false
			projectileLagCompensated = false
		}
	#endif
	vector projectileVelocity = Normalize( origin - attackParams.pos )
	projectileVelocity *= Length(attackParams.dir)
	entity projectile = Grenade_Launch( weapon, attackParams.pos, projectileVelocity, projectilePredicted, projectileLagCompensated, ZERO_VECTOR )

	PlayerUsedOffhand( ownerPlayer, weapon, true, projectile )

	#if SERVER
		TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )

		Assert( ownerPlayer.IsPlayer() )

		thread ManageDoorLifetime_Thread( ownerPlayer, origin, surfaceNormal, entranceParent, exitOrigin, exitSurfaceNormal, exitParent )

		#if DEV
			OPSPR_SavePortal( weapon, origin + (surfaceNormal * surfaceOffset), exitOrigin + (exitSurfaceNormal * surfaceOffset) )
		#endif
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

void function OnProjectileCollision_ability_phase_door( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
	if ( !IsValid( projectile ) )
	{
		return
	}

	projectile.kv.solid = 0
	projectile.SetDoesExplode( false )

	#if CLIENT
		// We need to still stop the entity and teleport, as the client has a very delayed deletion of the projectile

		vector forward = AnglesToForward( VectorToAngles( projectile.GetVelocity() ) )
		vector stickNormal

		if ( LengthSqr( forward ) > FLT_EPSILON )
			stickNormal = forward
		else
			stickNormal = normal

		projectile.StopPhysics()
		projectile.SetVelocity( <0, 0, 0> )
		projectile.ProjectileTeleport( pos + (projectile.proj.savedDir), AnglesCompose( VectorToAngles( stickNormal ), <90,0,0> ) )
	#endif
	#if SERVER
		projectile.Destroy()
	#endif
}

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________CreatePhaseDoor___________________________(){}
#endif

#if SERVER
entity function GetPhaseDoorWeaponFromOwner( entity owner )
{
	entity tacWeapon = owner.GetOffhandWeapon( OFFHAND_TACTICAL )
	if ( IsValid( tacWeapon ) && tacWeapon.GetWeaponBaseClassName() == PHASE_DOOR_WEAPON_NAME )
	{
		return tacWeapon
	}
	return null
}

void function ManageDoorLifetime_Thread( entity owner, vector startOrigin, vector startSurfaceNormal, entity startParent, vector endOrigin, vector endSurfaceNormal, entity endParent )
{
	Assert ( IsNewThread(), "Must be started as a new thread" )

	PassByReferenceEntity entranceTraceBlocker
	PassByReferenceEntity exitTraceBlocker

	entity entranceWarmup = CreatePhaseDoorWarmupEnt( owner, startOrigin, startSurfaceNormal, startParent, entranceTraceBlocker )
	entity exitWarmup = CreatePhaseDoorWarmupEnt( owner, endOrigin, endSurfaceNormal, endParent, exitTraceBlocker )

	entranceWarmup.LinkToEnt( exitWarmup )
	exitWarmup.LinkToEnt( entranceWarmup )

	thread MonitorForMoversBlockingPortalOrParentMoving_Thread( startOrigin + startSurfaceNormal, startSurfaceNormal, entranceWarmup )
	thread MonitorForMoversBlockingPortalOrParentMoving_Thread( endOrigin, endSurfaceNormal, exitWarmup )

	//Stat Tracking
	StatsHook_AlterSurfacesBreached( owner )

	wait tuning.plantDelay

	if ( !IsValid( entranceWarmup ) || !IsValid( exitWarmup ) )
	{
		if ( IsValid( entranceWarmup ) )
		{
			entranceWarmup.Destroy()
		}
		if ( IsValid( exitWarmup ) )
		{
			exitWarmup.Destroy()
		}

		if ( IsValid( owner ) )
		{
			entity tacWeapon = GetPhaseDoorWeaponFromOwner( owner )
			if ( IsValid( tacWeapon ) )
			{
				tacWeapon.SetWeaponPrimaryClipCountNoRegenReset( tacWeapon.GetWeaponPrimaryClipCountMax() )
			}
		}

		return
	}

	if ( !IsValid( owner ) )
		return

	entity entrance = CreatePhaseDoorRootEnt( owner, startOrigin, startSurfaceNormal, startParent )
	entity exit = CreatePhaseDoorRootEnt( owner, endOrigin, endSurfaceNormal, endParent )

	entrance.LinkToEnt( exit )
	exit.LinkToEnt( entrance )

	if ( IsValid( entranceTraceBlocker.value ) )
	{
		entranceTraceBlocker.value.SetParent( entrance )
	}
	if ( IsValid( exitTraceBlocker.value ) )
	{
		exitTraceBlocker.value.SetParent( exit )
	}
	entranceWarmup.Destroy()
	exitWarmup.Destroy()

	entrance.EndSignal( "OnDestroy" )
	exit.EndSignal( "OnDestroy" )

	thread MonitorForMoversBlockingPortalOrParentMoving_Thread( startOrigin + startSurfaceNormal, startSurfaceNormal, entrance )
	thread MonitorForMoversBlockingPortalOrParentMoving_Thread( endOrigin, endSurfaceNormal, exit )

	entity entranceTrigger = CreatePhaseDoorTriggers( owner, entrance, startOrigin, startSurfaceNormal )
	entity exitTrigger = CreatePhaseDoorTriggers( owner, exit, endOrigin, endSurfaceNormal )

	file.phaseDoorPairings[entranceTrigger] <- exitTrigger
	file.phaseDoorPairings[exitTrigger] <- entranceTrigger

	//fix for bug where trigger won't call enter until an ent that is already inside when it spawns starts moving, if you spawn a portal under a player then we want to grab them right away
	EnterPortalOnPlacement( entranceTrigger, owner )

	OnThreadEnd(
		function() : ( entrance, exit, entranceTrigger, exitTrigger, owner )
		{
			PIN_PlayerAbility( owner, "mp_ability_phase_door", ABILITY_TYPE.TACTICAL, null, { tunnel_start = entranceTrigger.GetOrigin(), tunnel_end = exitTrigger.GetOrigin() }  )

			DoPortalCleanup( entrance, entranceTrigger )
			DoPortalCleanup( exit, exitTrigger )
		}
	)

	wait tuning.portalDuration - PHASE_DOOR_WARNING_DURATION

	EmitSoundAtPosition( TEAM_ANY, entrance.GetOrigin(), PHASE_DOOR_ENDING_WARNING_SOUND, entrance )
	EmitSoundAtPosition( TEAM_ANY, exit.GetOrigin(), PHASE_DOOR_ENDING_WARNING_SOUND, exit )

	wait PHASE_DOOR_WARNING_DURATION

	while( file.portalExtensionToPlayersUsingMap[entranceTrigger].len() != 0 ||  file.portalExtensionToPlayersUsingMap[exitTrigger].len() != 0 )
	{
		WaitFrame()
	}
}

void function DoPortalCleanup( entity portalRootEnt, entity trigger )
{
	if ( trigger in file.phaseDoorPairings )
		delete file.phaseDoorPairings[trigger]

	if ( trigger in file.portalExtensionToPlayersUsingMap )
		delete file.portalExtensionToPlayersUsingMap[trigger]

	#if DEV
		OPSPR_RemovePortal( portalRootEnt.GetOrigin() )
	#endif

	if ( IsValid( portalRootEnt ) )
		portalRootEnt.Destroy()
}

entity function CreatePhaseDoorWarmupEnt( entity owner, vector origin, vector surfaceNormal, entity parentEnt, PassByReferenceEntity traceBlocker )
{
	origin = origin + (surfaceNormal * surfaceOffset)

	vector portalAngles   =  VectorToAngles( surfaceNormal )
	portalAngles = RotateAnglesAboutAxis( portalAngles, AnglesToUp( portalAngles ), 90.0 )

	entity portalWarmupEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin, portalAngles )
	portalWarmupEnt.SetScriptName( PHASE_DOOR_WARMUP_ENT_SCRIPTNAME )
	portalWarmupEnt.SetOwner( owner )
	SetTeam( portalWarmupEnt, owner.GetTeam() )
	portalWarmupEnt.RemoveFromAllRealms()
	portalWarmupEnt.AddToOtherEntitysRealms( owner )

	if ( IsValid( parentEnt ) )
	{
		portalWarmupEnt.SetParent( parentEnt )
	}

	vector traceBlockerMins = <-30, -3, -30>
	vector traceBlockerMaxs = <30, 15, 30>
	traceBlocker.value = CreateTraceBlockerVolume_CustomBox( origin, portalWarmupEnt.GetAngles(), traceBlockerMins, traceBlockerMaxs, CONTENTS_BLOCK_PING | CONTENTS_NOGRAPPLE, owner.GetTeam(), PHASE_DOOR_TRACE_BLOCKER_SCRIPTNAME, owner )
	traceBlocker.value.SetParent( portalWarmupEnt )
	traceBlocker.value.RemoveFromAllRealms()
	traceBlocker.value.AddToOtherEntitysRealms( owner )

	//DrawAngledBox( traceBlocker.GetOrigin(), traceBlocker.GetAngles(), traceBlockerMins, traceBlockerMaxs, COLOR_RED, false, 10 )

	return portalWarmupEnt
}

entity function CreatePhaseDoorRootEnt( entity owner, vector origin, vector surfaceNormal, entity parentEnt )
{
	origin = origin + (surfaceNormal * surfaceOffset)

	#if DEV
		if ( PHASE_DOOR_DEBUG_DRAW )
		{
			DebugDrawArrow( origin - ( surfaceNormal * surfaceOffset ), origin + ( surfaceNormal * 50 ), 2.5, COLOR_PURPLE, true, 5.0 )
		}
	#endif

	vector portalAngles   =  VectorToAngles( surfaceNormal )
	portalAngles = RotateAnglesAboutAxis( portalAngles, AnglesToUp( portalAngles ), 90.0 )

	entity portalRootEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin, portalAngles )
	portalRootEnt.SetScriptName( PHASE_DOOR_ROOT_ENT_SCRIPTNAME )
	portalRootEnt.SetOwner( owner )
	SetTeam( portalRootEnt, owner.GetTeam() )
	portalRootEnt.RemoveFromAllRealms()
	portalRootEnt.AddToOtherEntitysRealms( owner )

	if ( IsValid( parentEnt ) )
	{
		portalRootEnt.SetParent( parentEnt )
	}

	#if DEV
		if ( PHASE_DOOR_DEBUG_DRAW )
		{
			DebugDrawArrow( portalRootEnt.GetCenter(), portalRootEnt.GetCenter() + ( portalRootEnt.GetForwardVector() * 40.0 ), 5, COLOR_RED, true, 15 )
			DebugDrawArrow( portalRootEnt.GetCenter(), portalRootEnt.GetCenter() + ( portalRootEnt.GetUpVector() * 40.0 ), 5, COLOR_GREEN, true, 15 )
			DebugDrawArrow( portalRootEnt.GetCenter(), portalRootEnt.GetCenter() + ( portalRootEnt.GetRightVector() * 40.0 ), 5, COLOR_BLUE, true, 15 )
		}
	#endif

	return portalRootEnt
}

entity function CreatePhaseDoorTriggers( entity owner, entity portalRootEnt, vector origin, vector surfaceNormal )
{
	vector triggerPos
	const float surfaceTriggerOffset = 15

	triggerPos = origin + ( surfaceNormal * surfaceTriggerOffset )

	entity objectPlacementBlockerTrigger
	vector blockerTriggerAngles = VectorToAngles( surfaceNormal )
	blockerTriggerAngles = AnglesCompose( blockerTriggerAngles,  < 90, 90, 90 > )
	const float blockerRadius = 40
	const float blockerAboveHeight = 35
	const float blockerBelowHeight = 5
	if ( tuning.portalBlocksOtherPortals && tuning.portalBlocksObjectPlacement )
	{
		objectPlacementBlockerTrigger = CreateTriggerCylinderNetworked_BlockAllObjectPlacement( origin, blockerRadius, blockerAboveHeight, blockerBelowHeight, blockerTriggerAngles )
		objectPlacementBlockerTrigger.SetParent( portalRootEnt )
	}
	else if ( tuning.portalBlocksOtherPortals )
	{
		objectPlacementBlockerTrigger = CreateTriggerCylinderNetworked_NoObjectPlacementSpecial( origin, blockerRadius, blockerAboveHeight, blockerBelowHeight, blockerTriggerAngles )
		objectPlacementBlockerTrigger.SetParent( portalRootEnt )
	}
	else if ( tuning.portalBlocksObjectPlacement )
	{
		objectPlacementBlockerTrigger = CreateTriggerCylinderNetworked_NoObjectPlacement( origin, blockerRadius, blockerAboveHeight, blockerBelowHeight, blockerTriggerAngles )
		objectPlacementBlockerTrigger.SetParent( portalRootEnt )
	}

	entity trigger = CreateTriggerCylinder( triggerPos, PHASE_DOOR_TRIGGER_RADIUS, PHASE_DOOR_TRIGGER_RADIUS, PHASE_DOOR_TRIGGER_RADIUS )

	trigger.kv.triggerFilterNpc          = "none"
	trigger.kv.triggerFilterPlayer       = "all"
	trigger.kv.triggerFilterNonCharacter = 0
	trigger.SetPhaseShiftCanTouch( false )
	trigger.SetEnterCallback( PortalTriggerEnter )
	trigger.SetParent( portalRootEnt )
	trigger.SetOwner( owner )
	SetTeam( trigger, owner.GetTeam() )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( portalRootEnt )

	file.portalExitDir[trigger] <- surfaceNormal

	file.triggerToRootEntMap[trigger] <- portalRootEnt

	file.portalExtensionToPlayersUsingMap[trigger] <- []

	PassByReferenceVector portalExtensionStartPos
	PassByReferenceVector portalExtensionEndPos

	int portalOrientation = GetPortalDirectionForPortalExtension( surfaceNormal )
	bool createPortalExtension = false
	if ( tuning.spawnCeilingPortalExtensions && (portalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_DOWN) )
	{
		createPortalExtension = ShouldCreateVerticalPortalExtension(portalRootEnt.GetOrigin(), portalExtensionStartPos, portalExtensionEndPos )
	}
	else if ( tuning.spawnWallPortalExtensions && (portalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_WALL))
	{
		createPortalExtension = ShouldCreateHorizontalPortalExtension( portalRootEnt.GetOrigin(), portalRootEnt.GetRightVector(), portalExtensionStartPos, portalExtensionEndPos )
	}

	if ( createPortalExtension )
	{
		CreatePortalExtension( portalExtensionStartPos.value, portalExtensionEndPos.value, portalRootEnt, trigger )
	}

	#if DEV
	if ( PHASE_DOOR_DEBUG_DRAW )
	{
		DebugDrawCylinder( triggerPos - <0, 0, PHASE_DOOR_TRIGGER_RADIUS>, <-90, 0, 0>, PHASE_DOOR_TRIGGER_RADIUS, PHASE_DOOR_TRIGGER_RADIUS * 2, COLOR_GOLDEN_ROD, false, 15 )
	}
	#endif

	return trigger
}

void function EnterPortalOnPlacement( entity trigger, entity owner )
{
	float minDist = PHASE_DOOR_TRIGGER_RADIUS * 2.0

	#if DEV
		if ( PHASE_DOOR_DEBUG_DRAW )
		{
			DebugDrawSphere( trigger.GetCenter(), minDist, COLOR_CYAN, true, 5.0, 8 )
		}
	#endif

	int ownerTeam = owner.GetTeam()

	array<entity> playersToCheck = tuning.teleportTeammatesOnPortalOpen ? GetPlayerArrayOfTeam_Alive( ownerTeam ) : [ owner ]

	foreach ( entity player in playersToCheck )
	{
		float distanceToPortal = Distance( trigger.GetCenter(), player.GetCenter() )

		if ( distanceToPortal <= minDist )
		{
			TeleportPlayerFromPortalTrigger( trigger, player )
		}
	}
}

void function MonitorForMoversBlockingPortalOrParentMoving_Thread( vector origin, vector surfaceNormal, entity portalRootEnt )
{
	EndSignal( portalRootEnt, "OnDestroy" )

	vector initialPos = portalRootEnt.GetOrigin()
	vector initialAng = portalRootEnt.GetAngles()
	while( true )
	{
		WaitFrame()

		if ( initialPos != portalRootEnt.GetOrigin() )
		{
			#if DEV
			printf("Destroying Portal due to entity moving")
			#endif
			break
		}
		if ( initialAng != portalRootEnt.GetAngles() )
		{
			#if DEV
			printf("Destroying Portal due to entity rotating")
			#endif
			break
		}
		//if ( ObjectPlacementSpecial_TraceForMoverBlocking( origin, surfaceNormal, portalRootEnt ) )
		{
			//#if DEV
			//printf("Destroying Portal due to trace")
			//#endif
			//break
		}
	}

	portalRootEnt.Destroy()
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________CreatePortalExtensions___________________________(){}
#endif

int function GetPortalDirectionForPortalExtension( vector surfaceNormal )
{
	float dot = DotProduct( surfaceNormal, <0,0,1> )

	if ( dot > tuning.ceilingPortalExtensionAngle )
	{
		return ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_UP

	}
	else if ( dot < -tuning.ceilingPortalExtensionAngle )
	{
		return ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_DOWN
	}
	return ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_WALL
}

bool function ShouldCreateHorizontalPortalExtension( vector rootEntPos, vector rootEntRightVec, PassByReferenceVector portalExtensionStartPos, PassByReferenceVector portalExtensionEndPos )
{
	array<entity> ignoreArray = GetPlayerArray_AliveConnected()
	ignoreArray.extend( GetPlayerDecoyArray() )

	vector portalNormalFlattened = FlattenNormalizeVec( rootEntRightVec )
	vector startPos = rootEntPos + ( portalNormalFlattened * 32.0 )


	vector endOffset = ( portalNormalFlattened * 45.0 )
	float heightTraceFudgeValue = 5.0
	vector traceEndZPos = startPos - <0, 0, tuning.extensionMaxZHeight + heightTraceFudgeValue> + endOffset
	vector traceHorizontalStep = portalNormalFlattened * tuning.extensionMaxZHeight

	const float heightDiffForBetter = 2 * METERS_TO_INCHES

	float angleStep = DegToRad(10)
	float angle = 0
	float bestAngle = 0
	bool didHit = false
	vector endPos = traceEndZPos
	for ( int i = 0; i < 4; i++ )
	{
		TraceResults groundTrace = TraceLine( startPos, traceEndZPos + ( traceHorizontalStep * tan(angle) ), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

		#if PHASE_DOOR_PORTAL_EXTENSIONS_DEBUG_DRAW
			#if SERVER
			float debugDrawTime = 10
			#else
			float debugDrawTime = 0
			#endif
			DebugDrawArrow( startPos, traceEndZPos + ( traceHorizontalStep * tan(angle) ), 5, COLOR_BLUE, false, debugDrawTime )
		#endif

		if ( groundTrace.fraction < 0.99 )
		{
			if ( !didHit || (endPos.z - groundTrace.endPos.z) > heightDiffForBetter )
			{
				endPos = groundTrace.endPos
				bestAngle = angle
			}
			didHit = true
		}

		angle += angleStep
	}

	float ziplineLength = Distance( startPos, endPos )
	if ( ziplineLength < tuning.wallExtensionMinLength )
		return false

	if ( !didHit )
	{
		if ( tuning.extensionMaxHeightNoGround == 0.0 )
			return false

		endPos = startPos - <0,0,tuning.extensionMaxHeightNoGround> + ( portalNormalFlattened * tuning.extensionMaxHeightNoGround * tan(bestAngle) ) + endOffset
	}

	portalExtensionStartPos.value = startPos
	portalExtensionEndPos.value = endPos

	return true
}

bool function ShouldCreateVerticalPortalExtension( vector rootEntPos, PassByReferenceVector portalExtensionStartPos, PassByReferenceVector portalExtensionEndPos )
{
	array<entity> ignoreArray = GetPlayerArray_AliveConnected()
	ignoreArray.extend( GetPlayerDecoyArray() )

	vector startPos = rootEntPos

	TraceResults groundTrace = TraceLine( startPos, startPos - <0,0,3000.0>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	//TraceResults groundTrace = TraceHull( startPos - <0,0,owner.GetPlayerStandingMaxs().z>, startPos - <0,0,3000.0>, owner.GetPlayerStandingMins(), owner.GetPlayerStandingMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

	#if PHASE_DOOR_PORTAL_EXTENSIONS_DEBUG_DRAW
		#if SERVER
			float debugDrawTime = 10
		#else
			float debugDrawTime = 0
		#endif
		DebugDrawArrow( startPos, startPos - <0,0,3000.0>, 5, COLOR_BLUE, false, debugDrawTime )
	#endif

	vector endPos = groundTrace.endPos

	if ( (startPos.z - endPos.z) >= ( tuning.extensionMaxZHeight - FLT_EPSILON ) )
	{
		if ( tuning.extensionMaxHeightNoGround == 0.0 )
			return false

		endPos = startPos - <0,0,tuning.extensionMaxHeightNoGround>
	}
	else if ( (startPos.z - endPos.z) < 72 )
	{
		//if it's a really short rope, don't bother. Helps to tell people they won't be getting rope if the rope would hit a little piece of geo
		return false
	}
	else
	{
		endPos += <0,0,5>
	}

	portalExtensionStartPos.value = startPos
	portalExtensionEndPos.value = endPos

	return true
}

#if SERVER
entity function CreatePortalExtension( vector startPos, vector endPos, entity portalRootEnt, entity ownerTrigger )
{
	vector diff = endPos - startPos
	float length = diff.Length()
	float halfLength = length/2
	vector middle = startPos + (diff/2)
	vector mins = <-PHASE_DOOR_PORTAL_EXTENSION_WIDTH, -PHASE_DOOR_PORTAL_EXTENSION_WIDTH, -halfLength>
	vector maxes = -mins
	vector upVec = diff / length
	vector angles = <0,0,0>
	if ( (1 - upVec.z) > FLT_EPSILON )
	{
		vector rightVec = CrossProduct( upVec, <0,0,1> )
		vector forwardVec = CrossProduct( upVec, rightVec )
		angles = VectorToAngles( forwardVec )
	}

	entity portalExtension = CreatePropDynamic( $"mdl/dev/empty_model.rmdl", middle, angles )
	portalExtension.SetScriptName( PHASE_DOOR_PORTAL_EXTENSION_SCRIPTNAME )
	portalExtension.SetParent( portalRootEnt )
	portalExtension.SetOwner( ownerTrigger )
	portalExtension.SetSize( mins, maxes )

	CopyRealmsFromTo( portalRootEnt, portalExtension )

	portalExtension.SetUsable()
	portalExtension.SetUsableByGroup( "pilot" )
	portalExtension.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE )
	portalExtension.SetUsableDistanceOverride( 64 )
	portalExtension.SetUsePrompts( "#ABL_TAC_PHASE_DOOR_USE_PROMPT" , "#ABL_TAC_PHASE_DOOR_USE_PROMPT" )
	SetCallback_CanUseEntityCallback( portalExtension, PortalExtension_CanUseCallback )
	AddCallback_OnUseEntity_ClientServer( portalExtension, OnUse_PortalExtension )

	#if PHASE_DOOR_LOGGING
		printf("ALTER LENGTH: " + length/METERS_TO_INCHES)
	#endif

	#if PHASE_DOOR_PORTAL_EXTENSIONS_DEBUG_DRAW
		DrawAngledBox( middle, angles, mins, maxes, COLOR_PURPLE, false, 15 )
	#endif

	int beamFXID = GetParticleSystemIndex( PHASE_DOOR_ROPE_FX )
	entity beamFXEnt = StartParticleEffectOnEntity_ReturnEntity( portalRootEnt, beamFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	EffectSetControlPointVector( beamFXEnt, 1, endPos )
	EffectSetControlPointVector( beamFXEnt, 2, endPos )
	EffectSetControlPointVector( beamFXEnt, 3, endPos )

	return portalExtension
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________Teleport___________________________(){}
#endif
#if SERVER
void function PortalTriggerEnter( entity trigger, entity ent )
{
	TeleportPlayerFromPortalTrigger( trigger, ent )
}

void function DelayTriggerEnter_Thread( entity trigger, entity player )
{
	WaitFrame()

	if ( IsValid( trigger ) && IsValid( player ) )
	{
		TeleportPlayerFromPortalTrigger( trigger, player )
	}
}
#endif

bool function PortalStandardChecks( entity player )
{
	if ( player.Player_IsSkywardLaunching() )
		return false

	if ( player.Player_IsSkywardFollowing() )
		return false

	if ( player.ContextAction_IsActive() )
		return false

	if ( player.ContextAction_IsBusy() )
		return false

	//if ( player.IsPlayerInAnyVehicle() )
	//	return false

	if ( player.Anim_IsActive() )
		return false

	//if ( player.IsArmoredLeapActive() )
	//	return false

	return true
}

#if SERVER
void function TeleportPlayerFromPortalTrigger( entity trigger, entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !player.IsPlayer() )
		return

	if ( !player.DoesShareRealms( trigger ) )
		return

	if( !IsAlive( player ) )
		return

	if ( !PortalStandardChecks( player ) )
		return

	if ( player.e.isInPhaseTunnel )
		return

	if ( player.ContextAction_IsBeingRevived() || player.ContextAction_IsReviving() )
		return

	if ( player.ContextAction_IsMeleeExecution() || player.ContextAction_IsMeleeExecutionTarget() )
		return

	if ( !tuning.allowWraithUlt && StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return

	if ( !( trigger in file.phaseDoorPairings ) )
		return

	//this basically should only happen if you land a loba tac right on a portal trigger


	if ( player in file.playerLastPhaseDoorEnteredData )
	{
		if ( ( trigger == file.playerLastPhaseDoorEnteredData[player].triggerExited ) || ( trigger == file.playerLastPhaseDoorEnteredData[player].triggerEntered ) )
		{
			float deltaTime = Time() - file.playerLastPhaseDoorEnteredData[player].enteredTime

			#if PHASE_DOOR_LOGGING
				printf("ALTER: delta time since tp: " + deltaTime + " (time: " + Time() + ")")
			#endif
			if ( deltaTime <= tuning.reEnterDebounce )
			{
				#if PHASE_DOOR_LOGGING
					printf("ALTER: skipping teleport because player recently entered portal")
				#endif

				return
			}
		}
	}

	if ( tuning.doPostPortalPhaseShift )
	{
		if ( !player.IsPhaseShifted() )
		{
			bool didPhaseShift = PhaseShift( player, 0, tuning.postPortalPhaseShiftDuration, PHASETYPE_DOOR )

			if ( !didPhaseShift )
				return
			
			if ( !tuning.allowWraithUlt || !StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
			{
				thread TakeWeaponsAndReturnLater_Thread( player, tuning.postPortalPhaseShiftDuration )
			}
		}

		thread PhaseFX_Thread( player )
		                   
			//Sending null as the end portal since we're already on this side and don't want any sorta wallhacks
			VoidVisionStartPhaseShift( player, null )
        
	}

	StatsHook_AlterBreachUsed( player )

	entity endTrigger = file.phaseDoorPairings[trigger]

	LastPhaseDoorEnteredData data

	data.enteredTime = Time()
	data.triggerEntered = trigger
	data.triggerExited = endTrigger

	file.playerLastPhaseDoorEnteredData[player] <- data

	file.lastEnteredPhaseDoorTime[player] <- Time()
	file.lastPortalEntranceUsed[player] <- trigger

	StatusEffect_AddTimed( player, eStatusEffect.phase_door_teleport_visual_effect, 1.0, tuning.reEnterDebounce, 1.0 )

	vector playerVelocity = player.GetVelocity()

	EndPlayerSkyDive( player )

	player.Signal( PHASE_DOOR_TELEPORT_SIGNAL )



	//PlayerMelee_ClearPlayerAsLungeTarget( player, true )
	//player.Server_InvalidateMeleeLungeLagCompensationRecords() // EXTREMELY DANGEROUS - Talk to Code before using!!!

	Assert( endTrigger in file.portalExitDir, "Trigger isn't in map??" )
	vector outDir = ( endTrigger in file.portalExitDir ) ? file.portalExitDir[endTrigger] : endTrigger.GetRightVector()

	int exitPortalOrientation = 0//GetObjectPlacementSpecialOrientationFromAngles( outDir )
	float exitPositionOffset = (exitPortalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_DOWN ) ? 82.0 : 10.0
	float verticalOffset = (exitPortalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_WALL ) ? 32.0 : 0.0
	vector endPos = endTrigger.GetCenter() + ( outDir * exitPositionOffset ) - <0,0, verticalOffset>
	vector velocityDirection = outDir

	if ( exitPortalOrientation != ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_WALL )
	{
		//clear the horizontal component to make sure you come straight out of the portal, so you don't get yeeted off the platform
		velocityDirection = exitPortalOrientation == ePhaseDoorOrientation.PHASE_DOOR_ORIENTATION_CEILING_OR_FLOOR_UP ? <0,0,1> : <0,0,-1>
	}

	#if DEV
		if ( PHASE_DOOR_DEBUG_DRAW )
		{
			DebugDrawArrow( endTrigger.GetCenter(), endPos, 2.5, COLOR_BLUE, true, 5.0 )
			DebugDrawSphere( endPos, 5.0, COLOR_DARK_GREEN, true, 5.0)
		}
	#endif

	vector currentPos = player.GetOrigin()

	entity entranceRootEnt = trigger.GetParent()
	entity exitRootEnt = endTrigger.GetParent()
	StartParticleEffectInWorld( GetParticleSystemIndex( PHASE_DOOR_ENTER_FX ), entranceRootEnt.GetOrigin(), entranceRootEnt.GetAngles()+ <0, 0, 90> )
	StartParticleEffectInWorld( GetParticleSystemIndex( PHASE_DOOR_EXIT_FX ), exitRootEnt.GetOrigin(), exitRootEnt.GetAngles()+ <0, 0, 90> )

	EmitSoundAtPositionExceptToPlayer( player.GetTeam(), currentPos, player,PHASE_DOOR_WARPIN_SOUND_3P )
	EmitSoundAtPositionExceptToPlayer( player.GetTeam(), endPos, player,PHASE_DOOR_WARPOUT_SOUND_3P )

	printf("ALTER: Teleporting " + player + " from " + player.GetOrigin() + " to " + endPos)

	TeleportPlayerNoInterp( player, endPos )
	PutPlayerInSafeSpot( player, null, null, endPos, endPos )

	if ( trigger in file.portalExtensionToPlayersUsingMap )
	{
		if ( file.portalExtensionToPlayersUsingMap[trigger].contains( player ) )
		{
			playerVelocity = <0,0, playerVelocity.z>
		}
	}

	// PIN Event Data Collection
	PIN_Interact( player, "alter_phase_door", endTrigger.GetOrigin() )

	// Unlock Challenge Tracking Start
	if( IsBreachKillerChallengeEnabled() )
		thread PhaseDoor_BreachKillerChallenge_Thread( trigger, player )

	#if ASSERTS
	if ( endTrigger in file.phaseDoorPairings )
	{
		float sqrDistToNearPortal = LengthSqr( player.GetOrigin()- endTrigger.GetCenter() )
		float sqrDistToFarPortal = LengthSqr( player.GetOrigin() - trigger.GetCenter() )

		if ( sqrDistToNearPortal > sqrDistToFarPortal )
		{
			// Put player in safe space likely put us back :(

			Warning("ALTER: Player entered portal, but ended up on the same side! TP: " + endPos + ", Player Pos: " + player.GetOrigin())

			#if DEV
				if ( IsValidMapForAutoReporting() )
				{
					OPSPR_ReportBadPortal( trigger.GetParent().GetOrigin() )
				}
			#endif
		}
	}
	else
	{
		Assert( false, "Paired trigger not in the table!" )
	}
	#endif

	Assert( fabs(Length( outDir ) - 1) < 0.01, "Out Dir is not normalize!!" )

	float speedInPortalDir = DotProduct( playerVelocity, velocityDirection )

	float outputPlayerSpeed = clamp( speedInPortalDir, tuning.exitVelocityMin, tuning.exitVelocityMax )
	player.SetVelocity( ( velocityDirection * outputPlayerSpeed ) )

	#if PHASE_DOOR_LOGGING
		printf( "PHASE DOOR - Player Vel Post TP: " + (velocityDirection * outputPlayerSpeed) )
	#endif

	//player.EndTeleport()

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ALTER_TACTICAL_USED, player, endTrigger.GetCenter(), player.GetTeam(), player )
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ALTER_TACTICAL_USED, player, trigger.GetCenter(), player.GetTeam(), player )
}

void function PhaseFX_Thread( entity player )
{
	player.EndSignal("OnDeath", "OnDestroy")

	Assert( player.IsPhaseShifted() )
	                   
	VoidVision_GrantVoidVision( player )
       

	int fxid = GetParticleSystemIndex( PHASE_DOOR_PHASED_PLAYER_FX )

	int attachId = player.LookupAttachment( "CHESTFOCUS" )
	entity travelFX = StartParticleEffectOnEntity_ReturnEntity( player, fxid, FX_PATTACH_POINT_FOLLOW, attachId )
	travelFX.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	travelFX.SetOwner( player )

	OnThreadEnd(
		function() : ( travelFX, player )
		{
			#if PHASE_DOOR_LOGGING
			if ( player in file.playerLastPhaseDoorEnteredData )
			{
				float deltaTime = Time() - file.playerLastPhaseDoorEnteredData[player].enteredTime

				printf( "ALTER: unphased - delta time since tp: " + deltaTime + " (time: " + Time() + ")" )

			}
			#endif
			travelFX.Destroy()
			                   
				if ( PlayerHasPassive( player, ePassives.PAS_ALTER_UPGRADE_TAC_SCAN ) )
				{
					thread TakeVoidVisionPassiveDelayed_Thread( player )
				}
				else
				{
					VoidVision_TakeVoidVision( player )
				}

         
		}
	)

	while ( player.IsPhaseShifted() )
	{
		WaitFrame()
	}
}

void function TravelingThroughPortalExtension_Thread( entity player, entity extension )
{
	EndSignal( player, "OnDeath", "OnDestroy" )

	entity trigger = extension.GetOwner()

	entity portalRootEnt = null
	if ( trigger in file.phaseDoorPairings )
	{
		entity exitTrigger = file.phaseDoorPairings[trigger]
		if ( IsValid( exitTrigger ) )
		{
			if ( exitTrigger in file.triggerToRootEntMap )
			{
				portalRootEnt = file.triggerToRootEntMap[ exitTrigger ]
			}
		}
		else
		{
			Assert( false, "Paired trigger isn't valid!" )
		}
	}

	vector playerPos = player.GetOrigin()
	vector endPos = trigger.GetOrigin()
	float playerHeight = player.GetBoundingMaxs().z

	vector extensionBottom = extension.GetOrigin() + extension.GetUpVector() * extension.GetBoundingMins().z

	#if PHASE_DOOR_PORTAL_EXTENSIONS_DEBUG_DRAW
		DebugDrawLine( endPos, extensionBottom, COLOR_GOLDEN_ROD, false, 10 )
	#endif

	vector closestPointOnLine = GetClosestPointOnLineSegment( endPos, extensionBottom, playerPos )

	vector dir = closestPointOnLine - endPos
	vector dirNormalized = Normalize( dir )

	//we add an extra frame to the length of the mover path to make sure that we're still moving when we try and do the teleport
	//to avoid any race conditions
	endPos += dirNormalized * ( playerHeight - (tuning.extensionTravelSpeed * 0.1) )
	dir = closestPointOnLine - endPos

	#if PHASE_DOOR_PORTAL_EXTENSIONS_DEBUG_DRAW
		DebugDrawSphere( closestPointOnLine, 5, COLOR_GREEN, false, 10 )
		DebugDrawSphere( endPos, 5, COLOR_RED, false, 10 )
	#endif

	float pathDistance = dir.Length()
	float pathTime = pathDistance / tuning.extensionTravelSpeed

	if ( pathTime < 0.05 )
	{
		//we don't even need to travel, just teleport them
		TeleportPlayerFromPortalTrigger( trigger, player )
		return
	}

	EmitSoundOnEntityOnlyToPlayer( player, player, PHASE_DOOR_PHASE_IN_LIFT_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, PHASE_DOOR_PHASE_IN_LIFT_3P )

	int attachID = player.LookupAttachment( "CHESTFOCUS" )
	entity fxEnt = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex(PHASE_DOOR_PLAYER_ON_ROPE_FX), FX_PATTACH_ABSORIGIN_FOLLOW, attachID )

	if ( trigger in file.portalExtensionToPlayersUsingMap )
	{
		file.portalExtensionToPlayersUsingMap[ trigger ].append( player )

		#if PHASE_DOOR_LOGGING
			printf( "PHASE DOOR - adding " +  player + " to " + trigger )
		#endif
	}
	else
	{
		Assert( false, "Trigger not in map!" )
	}

	float extraPhaseShiftTime = (tuning.doPostPortalPhaseShift ? tuning.postPortalPhaseShiftDuration : 0.0)
	float phaseShiftDuration = pathTime + extraPhaseShiftTime
	PhaseShift( player, 0, phaseShiftDuration, PHASETYPE_DOOR )
	thread TakeWeaponsAndReturnLater_Thread( player, phaseShiftDuration )

	                   
		Assert( IsValid( portalRootEnt ), "exit ring isn't valid!" )
		VoidVision_GrantVoidVision( player )
		VoidVisionStartPhaseShift( player, portalRootEnt )
       

	#if PHASE_DOOR_LOGGING
		printf( "PHASE DOOR - pathTime: " + pathTime )
	#endif

	entity mover = CreateScriptMover( PHASE_DOOR_PORTAL_EXTENSION_MOVER_SCRIPTNAME, player.GetOrigin(), player.GetAngles() )

	vector oldAngles = player.GetAngles()
	vector oldEyeAngles = player.CameraAngles()
	player.SetParent( mover, "REF", false )
	player.SetAbsAngles( oldAngles )
	player.SnapEyeAngles( oldEyeAngles )

	mover.NonPhysicsMoveTo( endPos, max (pathTime, 0.1), min( max( pathTime - 0.1, 0.1), 1 ), 0 )

	PassByReferenceBool needClear
	needClear.value = true
	OnThreadEnd(
		function() : ( player, trigger, mover, needClear, fxEnt )
		{
			if ( needClear.value )
			{
				vector oldEyeAngles = player.CameraAngles()
				vector oldAngles = player.GetAngles()
				player.ClearParent()
				player.SetAbsAngles( oldAngles )
				player.SnapEyeAngles( oldEyeAngles )
				mover.Destroy()

				if ( IsValid( fxEnt ) )
				{
					fxEnt.Destroy()
				}

				if ( trigger in file.portalExtensionToPlayersUsingMap )
				{
					file.portalExtensionToPlayersUsingMap[ trigger ].fastremovebyvalue ( player )

					#if PHASE_DOOR_LOGGING
						printf( "PHASE DOOR - removing " +  player + " from " + trigger + "END SIGNAL" )
					#endif
				}

				CancelPhaseShift( player )
			}

			                   
				VoidVision_TakeVoidVision( player )
         

			player.Signal( PHASE_DOOR_RETURN_WEAPONS_SIGNAL )
		}
	)

	wait pathTime - 0.1

	#if PHASE_DOOR_LOGGING
		printf( "PHASE DOOR - Player Vel " + player.GetVelocity() )
	#endif
	oldEyeAngles = player.CameraAngles()
	oldAngles = player.GetAngles()
	player.ClearParent()
	player.SetAbsAngles( oldAngles )
	player.SnapEyeAngles( oldEyeAngles )
	mover.Destroy()
	if ( IsValid( fxEnt ) )
	{
		fxEnt.Destroy()
	}

	if ( IsValid( trigger ) )
	{
		TeleportPlayerFromPortalTrigger( trigger, player )
	}
	else
	{
		Warning( "ALTER: Trigger is invalid at end of portal extension!" )
	}

	if ( trigger in file.portalExtensionToPlayersUsingMap )
	{
		file.portalExtensionToPlayersUsingMap[ trigger ].fastremovebyvalue ( player )

		#if PHASE_DOOR_LOGGING
			printf( "PHASE DOOR - removing " +  player + " from " + trigger )
		#endif
	}

	needClear.value = false

	wait extraPhaseShiftTime
}

void function TakeVoidVisionPassiveDelayed_Thread( entity player )
{
	player.EndSignal( "OnDeath" )

	OnThreadEnd( function() : ( player ) {
		if ( IsValid( player ) )
			VoidVision_TakeVoidVision( player )
	} )

	wait VoidVision_GetPostPhaseVisionTime()
}

void function TakeWeaponsAndReturnLater_Thread( entity player, float delay )
{
	HolsterAndDisableWeapons( player )

	player.EndSignal( PHASE_DOOR_RETURN_WEAPONS_SIGNAL )
	player.EndSignal( "OnDeath" )

	OnThreadEnd( function() : ( player ) {
		if ( IsValid( player ) )
			DeployAndEnableWeapons( player )
	} )

	if ( delay <= 0 )
	{
		WaitForever()
	}

	wait delay
}

void function OnUse_PortalExtension( entity extension, entity player, int useInputFlags )
{
	entity trigger = extension.GetParent()

	if ( !IsValid( trigger ) )
	{
		Assert( false, "Portal extension has an invalid parent!" )
		return
	}

	thread TravelingThroughPortalExtension_Thread( player, extension)
}

#endif


bool function PortalExtension_CanUseCallback( entity player, entity extension, int useFlags )
{
	if ( !IsValid ( player ) || !IsValid( extension ) )
		return false

	if ( !PortalStandardChecks( player ) )
		return false

	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return false

	if ( player.Player_IsSkydiving() )
		return false

	if ( player.IsPhaseShifted() )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( GetCurrentPlaylistVarBool( "alter_tac_use_better_rope_fix", true ) )
	{
		if ( StatusEffect_HasSeverity( player, eStatusEffect.phase_door_teleport_visual_effect ) )
			return false
	}
	else
	{
		#if SERVER
		if ( player in file.playerLastPhaseDoorEnteredData )
		{
			entity trigger = extension.GetOwner()

			if ( ( trigger == file.playerLastPhaseDoorEnteredData[player].triggerExited ) || ( trigger == file.playerLastPhaseDoorEnteredData[player].triggerEntered ) )
			{
				float deltaTime = Time() - file.playerLastPhaseDoorEnteredData[player].enteredTime

				#if PHASE_DOOR_LOGGING
					printf("ALTER: extension - delta time since tp: " + deltaTime + " (time: " + Time() + ")")
				#endif
				if ( deltaTime <= tuning.reEnterDebounce )
				{
					#if PHASE_DOOR_LOGGING
						printf("ALTER: extension - skipping using extension because player recently entered portal")
					#endif

					return false
				}
			}
		}
		#endif
	}

	return true
}

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________ClientWork___________________________(){}
#endif
#if CLIENT
void function OnPropCreated( entity ent )
{
	if ( ent.GetScriptName() == PHASE_DOOR_WARMUP_ENT_SCRIPTNAME )
	{
		ManageWarmupFX( ent )
		if ( tuning.createThreatIndicator )
		{
			thread ManageThreatIndicator_Thread( ent )
		}
	}
	if ( ent.GetScriptName() == PHASE_DOOR_ROOT_ENT_SCRIPTNAME )
	{
		ManagePortalFX( ent )
                                  
                                                                                                                                    
   
                                                             
   
        
	}
	if ( ent.GetScriptName() == PHASE_DOOR_PORTAL_EXTENSION_SCRIPTNAME )
	{
		SetCallback_CanUseEntityCallback( ent, PortalExtension_CanUseCallback )
		SetCallback_ShouldUseBlockReloadCallback( ent, SimpleShouldNotBlockReloadCallback )
		thread ManageRopeSFX_Thread( ent )
	}
}

void function ManageThreatIndicator_Thread( entity portal )
{
	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	int team = portal.GetTeam()
	vector position = portal.GetOrigin()

	if ( IsFriendlyTeam( localPlayer.GetTeam(), team ) )
		return

	#if PHASE_DOOR_DEBUG_ENABLE_FF_SELF_CHECK
	//if friendly fire is on, you're an enemy of your own team
	if ( portal.GetOwner() == localPlayer )
		return
	#endif

	entity dummyProp = CreateClientSidePropDynamic( position, portal.GetAngles(), $"mdl/dev/empty_model.rmdl" )
	dummyProp.SetScriptName( PHASE_DOOR_THREAT_INDICATOR_SCRIPTNAME )

	ShowGrenadeArrow( GetLocalViewPlayer(), dummyProp, tuning.threatIndicatorRange, 0, true, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ALL )

	wait tuning.threatIndicatorLifetime

	if ( IsValid( dummyProp ) )
	{
		dummyProp.Destroy()
	}
}

void function ManageRopeSFX_Thread( entity portalExtension )
{
	portalExtension.EndSignal( "OnDestroy" )

	entity soundEnt = CreateClientSidePropDynamic( <0,0,0>, <0, 0, 0>, $"mdl/dev/empty_model.rmdl" )
	EmitSoundOnEntity( soundEnt, PHASE_DOOR_ROPE_SOUND )

	OnThreadEnd(
		function() : ( soundEnt )
		{
			if ( IsValid( soundEnt ) )
			{
				StopSoundOnEntity( soundEnt, PHASE_DOOR_ROPE_SOUND )
				soundEnt.Destroy()
			}
		}
	)

	vector extensionBottom = portalExtension.GetOrigin() + portalExtension.GetUpVector() * portalExtension.GetBoundingMins().z
	vector extensionTop = portalExtension.GetOrigin() + portalExtension.GetUpVector() * portalExtension.GetBoundingMaxs().z

	while ( true )
	{
		if ( IsValid( GetLocalViewPlayer() ) )
		{
			vector closestPointOnLine = GetClosestPointOnLineSegment( extensionTop, extensionBottom, GetLocalViewPlayer().EyePosition() )

			soundEnt.SetOrigin( closestPointOnLine )
		}

		WaitFrame()
	}
}

void function ManageWarmupFX( entity portalRootEnt )
{
	thread ManageFX_Thread( portalRootEnt, PHASE_DOOR_SPAWN_SOUND, GetParticleSystemIndex( PHASE_DOOR_SPAWN_FX ), true )
}
void function ManagePortalFX( entity portalRootEnt )
{
	thread ManageFX_Thread( portalRootEnt, PHASE_DOOR_LOOP_SOUND, GetParticleSystemIndex( PHASE_DOOR_FX ), false )
}

void function ManageFX_Thread( entity portalEnt, string sound, int fxID, bool isWarmup )
{
	entity linkedPortal = portalEnt.GetLinkEnt()

	if ( !linkedPortal )
	{
		Warning("No linked portal!")
		return
	}
	portalEnt.EndSignal( "OnDestroy" )
	linkedPortal.EndSignal( "OnDestroy" )

	entity tracingEnt = portalEnt.GetOwner()
	if ( !IsValid( tracingEnt ) )
	{
		tracingEnt = GetLocalViewPlayer()
	}

	int team = portalEnt.GetTeam()

	bool isFriendlyTeam = IsFriendlyTeam( tracingEnt.GetTeam(), team)

	#if PHASE_DOOR_DEBUG_ENABLE_FF_SELF_CHECK
	if ( portalEnt.GetOwner() == GetLocalViewPlayer() )
	{
		isFriendlyTeam = true
	}
	#endif

	const float FX_OFFSET = 3
	vector fxPos = portalEnt.GetOrigin() + ( FX_OFFSET * portalEnt.GetRightVector() )
	int portalFX = StartParticleEffectInWorldWithHandle( fxID, fxPos, portalEnt.GetAngles() + <0, 0, 90> )

	const float TEAMMATE_ALPHA = 0.2
	const float OBSCURED_ALPHA = 0.6

	EffectSetControlPointVector( portalFX, 3, <TEAMMATE_ALPHA,0,0> )

	if ( IsValid( tracingEnt ) )
	{
		EffectSetControlPointVector( portalFX, 2, isFriendlyTeam ? PHASE_DOOR_FX_COLOUR_FRIENDLY : PHASE_DOOR_FX_COLOUR_ENEMY )
	}

	if ( isWarmup )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, portalEnt.GetOrigin(), sound )
	}
	else
	{
		// We update the sound info (i.e. codeValue) first so that the sound event starts with the correct controller values for play action switches to work.
		SendMilesInfoForOPSPoint( portalEnt, tracingEnt, portalEnt.GetOrigin(), portalEnt.GetRightVector() )
		EmitSoundOnEntity( portalEnt, sound )
	}

	OnThreadEnd(
		function() : ( portalFX, portalEnt, sound )
		{
			StopSoundOnEntity( portalEnt, sound )
			EffectStop( portalFX, false, true )
		}
	)

	while ( true )
	{
		entity player = GetLocalViewPlayer()

		if ( !IsValid( player ) )
		{
			WaitFrame()
			continue
		}

		isFriendlyTeam = IsFriendlyTeam( player.GetTeam(), team)

		#if PHASE_DOOR_DEBUG_ENABLE_FF_SELF_CHECK
		if ( portalEnt.GetOwner() == player )
		{
			isFriendlyTeam = true
		}
		#endif

		if ( !isFriendlyTeam )
		{
			float alpha = 0

			float distanceToLinkedPortal = Distance( player.GetOrigin(), linkedPortal.GetOrigin() )
			if ( distanceToLinkedPortal < PHASE_DOOR_FX_ENEMY_SHOW_DIST_MAX )
			{
				if ( PlayerCanSee( player, linkedPortal, true, 180 ) )
				{
					alpha = GetValueFromFraction( distanceToLinkedPortal, PHASE_DOOR_FX_ENEMY_SHOW_DIST_MIN, PHASE_DOOR_FX_ENEMY_SHOW_DIST_MAX, OBSCURED_ALPHA, 0 )
				}
			}
			EffectSetControlPointVector( portalFX, 3, <alpha,0,0> )

			EffectSetControlPointVector( portalFX, 2, PHASE_DOOR_FX_COLOUR_ENEMY )
		}
		else
		{
			EffectSetControlPointVector( portalFX, 3, <TEAMMATE_ALPHA,0,0> )
			EffectSetControlPointVector( portalFX, 2, PHASE_DOOR_FX_COLOUR_FRIENDLY )
		}

		WaitFrame()
	}
}

void function StartVisualEffect( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() || (GetLocalViewPlayer() == GetLocalClientPlayer() && !actuallyChanged) )
		return

	if ( StatusEffect_GetSeverity( player, statusEffect ) < 1 )
		return

	EmitSoundOnEntity( player, PHASE_DOOR_WARPIN_SOUND_1P )

	thread (void function() : ( player, statusEffect ) {
		EndSignal( player, "OnDeath", PHASE_DOOR_STOP_VISUAL_EFFECT )

		int fxHandle = StartParticleEffectOnEntityWithPos( player,
			GetParticleSystemIndex( PHASE_DOOR_WARP_SCREEN_FX ),
			FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )

		EffectSetIsWithCockpit( fxHandle, true )

		OnThreadEnd( function() : ( fxHandle ) {
			CleanupFXHandle( fxHandle, false, true )
		} )

		while( true )
		{
			if ( !EffectDoesExist( fxHandle ) )
				break

			float severity = StatusEffect_GetSeverity( player, statusEffect )
			//DebugDrawScreenText( 0.47, 0.68, "severity: " + severity )
			EffectSetControlPointVector( fxHandle, 1, <severity, 999, 0> )

			WaitFrame()
		}
	})()
}

void function StopVisualEffect( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() || (GetLocalViewPlayer() == GetLocalClientPlayer() && !actuallyChanged) )
		return

	player.Signal( PHASE_DOOR_STOP_VISUAL_EFFECT )
}

#endif

#if SERVER
void function AddNoObjectPlacementSpecialTriggersViaPlaylist()
{
	Assert( GetGamemodeVarOrUseValue( "defaults", "ops_trigger_fix_count", "no" ) == "no", "Cannot define ops_trigger_fix_count variables in defaults gamemode vars" )

	int numOOBTriggers = GetCurrentPlaylistVarInt( "ops_trigger_fix_count", 0 )

	for ( int index = 0; index < numOOBTriggers; index++ )
	{
		string opsTriggerPrefix = "ops_trigger_fix_" + index + "_"

		vector triggerOrigin = StringToVector( GetCurrentPlaylistVarString( opsTriggerPrefix + "origin", "0 0 0" ) )
		vector triggerAngles = StringToVector( GetCurrentPlaylistVarString( opsTriggerPrefix + "angles", "0 0 0" ) )
		float triggerRadius = GetCurrentPlaylistVarFloat( opsTriggerPrefix + "radius", 0.0  )
		float triggerAboveHeight = GetCurrentPlaylistVarFloat( opsTriggerPrefix + "aboveHeight", 0.0  )
		float triggerbelowHeight = GetCurrentPlaylistVarFloat( opsTriggerPrefix + "belowHeight", 0.0  )

		printf("Alter: Creating no portal volume at " + triggerOrigin + ", " + triggerAngles, ", radius: " + triggerRadius )
		CreateTriggerCylinderNetworked_NoObjectPlacementSpecial( triggerOrigin, triggerRadius, triggerAboveHeight, triggerbelowHeight, triggerAngles )
	}
}
#endif

bool function PhaseDoor_CheckInvalidEnt( entity ent )
{
	if ( IsValid( ent ) && (ent.GetScriptName() in file.invalidEntityScriptNames) )
	{
		return true
	}

	if ( IsValid( ent.GetParent() ) && (ent.GetParent().GetScriptName() in file.invalidEntityScriptNames) )
	{
		return true
	}

	return false
}

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________BreachKillerChallenge___________________________(){}
#endif

bool function IsBreachKillerChallengeEnabled()
{
	return GetCurrentPlaylistVarBool( "alter_breach_killer_challenge_enabled", false )
}

#if SERVER
void function PhaseDoor_BreachKillerChallenge_Thread( entity trigger, entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if( !IsValid( trigger ) || !IsValid( player ) )
		return

	// Check if using exit portal with knock secured
	if( player in file.breachKillerConditionsPerAlter )
	{
		if( file.breachKillerConditionsPerAlter[player].knockSecured )
		{
			if( trigger in file.phaseDoorPairings )
			{
				entity entrancePortal = file.phaseDoorPairings[trigger]
				if( entrancePortal == file.breachKillerConditionsPerAlter[player].entrancePortal )
				{
					player.Signal( "BreachKillerChallenge_ExitPortal" )
					return
				}
			}
		}
	}

	player.Signal( "CancelBreachKillerChallenge" )
	EndSignal( player, "OnDeath", "OnDestroy", "CancelBreachKillerChallenge" )
	EndSignal( trigger, "OnDestroy"  )

	OnThreadEnd(
		function() : ( player )
		{
			if( player in file.breachKillerConditionsPerAlter )
				delete file.breachKillerConditionsPerAlter[player]
		}
	)

	BreachKillerChallengeConditions challengeConditions
	file.breachKillerConditionsPerAlter[player] <- challengeConditions

	file.breachKillerConditionsPerAlter[player].isActive = true
	file.breachKillerConditionsPerAlter[player].entrancePortal = trigger

	// Step 1: Knock enemy while portal is still active
	WaitSignal( player, "BreachKillerChallenge_EnemyKnocked" )

	// Step 2: After Knock, exit through the exit portal of the portal you first breached with
	WaitSignal( player, "BreachKillerChallenge_ExitPortal" )

	StatsHook_AlterBreachKillerChallengeCompleted( player )
}

void function BreachKillerChallenge_OnKnock( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValidPlayer( victim ) || !IsValidPlayer( attacker ) )
		return

	BreachKillerChallenge_EnemyKnockStep( attacker, victim )
}

void function BreachKillerChallenge_OnKill( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValidPlayer( victim ) || !IsValidPlayer( attacker ) )
		return

	if( !Bleedout_IsBleedingOut( victim ) )
		BreachKillerChallenge_EnemyKnockStep( attacker, victim )
}

void function BreachKillerChallenge_EnemyKnockStep( entity attacker, entity victim )
{
	Assert( IsValidPlayer( victim ) && IsValidPlayer( attacker ) )

	if( !PlayerHasPassive( attacker, ePassives.PAS_ALTER ) )
		return
	if ( IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) )
		return
	if( !( attacker in file.breachKillerConditionsPerAlter ) )
		return

	if( file.breachKillerConditionsPerAlter[attacker].isActive == true )
	{
		file.breachKillerConditionsPerAlter[attacker].knockSecured = true
		attacker.Signal( "BreachKillerChallenge_EnemyKnocked" )
	}
}
#endif

                                
          
                                                                                   
 
                                              
                                            
                                                                                                                                                     

                                                         
                                                          

                                           
                                
                                          

                                                        
                                                     
 

                                                                      
 
                                

             
                      
   
                    
   
  

              
  
                                           
                        
                                
   
                                                                 
                                            
                                                                           

                                                                                            

                  
    
                                   
                                   
    
   
                                                        

             
  
 

                                                                         
 
                                    

              
  
                                           

                                   
                                 
                                                                                                               
                                     
   
                                      
   
      
   
                                      
                                                                        
   
             
  

 
      
      

                  
 