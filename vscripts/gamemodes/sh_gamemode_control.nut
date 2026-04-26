
// ToDo: Can these be consolidated into 1 function ( ProcessSpawnMenu, Control_ManageRespawnWaypoint_Thread, Thread_Control_InGameMapData )
const string CONTROL_MODE_MOVER_SCRIPTNAME = "control_mover"

global function Control_Init

#if SERVER
global function Control_GetCurrentRank
global function Control_SetWinner
global function Control_PlayerChangedCharacter
global function Control_SonarSpawnKiller
global function Control_GetMusicEntity





global function ClientCallback_Control_ProcessRespawnChoice
global function ClientCallback_Control_PlayerRespawningFromMenu

global function Control_PlayCommentaryLineToAlliance

global function Control_OnItemDropped
global function Control_SubtractExp
global function Control_PrintSkydiveDebug
#endif // SERVER

#if CLIENT
global function ServerCallback_Control_ShowSpawnSelection
global function ServerCallback_Control_UpdateSpawnWaveTimerTime
global function ServerCallback_Control_UpdateSpawnWaveTimerVisibility
global function ServerCallback_Control_DeregisterModeButtonPressedCallbacks
global function ServerCallback_Control_SetDeathScreenCallbacks

global function UICallback_Control_UpdatePlayerInfo
global function UICallback_Control_OnMenuPreClosed
global function UICallback_Control_ReportMenu_OnClosed
global function UICallback_Control_ReportMenu_OnOpened
global function UICallback_Control_OnResolutionChanged
global function UICallback_Control_SpawnHeaderUpdated
global function UICallback_Control_SpawnButtonClicked
global function UICallback_Control_LaunchSpawnMenuProcessThread
global function UICallback_ControlMenu_MouseWheelUp
global function UICallback_ControlMenu_MouseWheelDown

global function Control_PingObjectiveFromObjID

global function ServerCallback_Control_ProcessImmediatelyOpenCharacterSelect
global function ServerCallback_Control_OnPlayerChoosingRespawnChoiceChanged
global function ServerCallback_Control_NoVehiclesAvailable
global function ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo
global function ServerCallback_Control_ProcessObjectiveStateChange
global function ServerCallback_Control_DisplayIconAtPosition
global function ServerCallback_Control_BountyActiveAlert
global function ServerCallback_Control_BountyClaimedAlert
global function ServerCallback_Control_AirdropNotification
global function ServerCallback_Control_UpdateExtraScoreBoardInfo
global function ServerCallback_Control_TransferCameraData
global function ServerCallback_PlayMatchEndMusic_Control
global function ServerCallback_PlayPodiumMusic
global function ServerCallback_Control_SetControlGeoValidForAirdropsOnClient
global function ServerCallback_Control_DisplayLockoutUnavailableWarning
global function ServerCallback_Control_MRBTimedEvent_OnMRBPickedUp

global function Control_OpenCharacterSelect
global function ServerCallback_Control_DisplaySpawnAlertMessage
global function ServerCallback_Control_DisplayWaveSpawnBarStatusMessage
global function Control_SendRespawnChoiceToServer

global function Control_InstanceObjectivePing_Thread
global function Control_UpdatePlayerExpHUD
global function	Control_ScoreboardSetup
global function ServerCallback_Control_SetIsPlayerUsingLosingExpTiers
global function UICallback_Control_Loadouts_OnClosed
global function ServerCallback_Control_PlayAllWeaponEvoUpgradeFX
global function ServerCallback_Control_Play3PEXPLevelUpFX
global function ServerCallback_Control_PlayCaptureZoneEnterExitSFX
global function ServerCallback_Control_NewEXPLeader
global function ServerCallback_Control_EXPLeaderKilled

global function Control_ObjectiveScoreTracker_PushAnnouncement
global function Control_PlayEXPGainSFX

global function Control_DeathScreenUpdate
global function Control_PopulateSummaryDataStrings
global function Control_ScoreboardUpdateHeader
global function Control_IsLocalClientInMapCameraView
global function Control_CloseCharacterSelectOnlyIfOpen

global function Control_ToggleMapRui
#endif // CLIENT


#if UI
global function Control_PopulateAboutText
#endif // UI

global function Control_IsSpawningOnObjectiveBAllowed
global function Control_IsPointAnFOB
global function Control_IsSpawnWaypointIndexAnObjective
global function Control_IsSpawnWaypointFOBForAlliance
global function Control_IsSpawnWaypointHomebaseForAlliance

#if CLIENT || SERVER
global function Control_GetPlayerExpTotal
global function Control_GetPlayerExpTier
global function Control_GetStarterPingFromTraceBlockerPing
global function Control_GetDefaultWeaponTier
global function Control_SetHomeBaseBadPlacesForMRBForAlliance
global function Control_GetBestSpawnLocationForAlliance
global function Control_GetRespawnChoiceFromSpawnWaypoint
global function Control_GetValidSpawnWaypointCount

global const float CONTROL_MESSAGE_DURATION = 5.0
const float CONTROL_MESSAGE_DURATION_LONG = 11.0
const float CONTROL_MESSAGE_DURATION_SHORT = 3.0
const float LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_SHORT = 2.5
const float LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_LONG = 3.5
const float ANNOUNCER_DIALOGUE_DELAY = 1.5

global const string CONTROL_FUNC_BRUSH_GEO_NAME = "func_control_geo"
// Scoring Events for EXP gain, points values for EXP events with constant points values are set in score_events.csv ( same place these events are set up in)
const string CONTROL_EXPEVENT_ELIMINATION = "Control_Exp_Elimination"
const string CONTROL_EXPEVENT_ASSIST = "Control_Exp_Assist"
const string CONTROL_EXPEVENT_ATTACKERKILL = "Control_Exp_AttackerKill"
const string CONTROL_EXPEVENT_DEFENDERKILL = "Control_Exp_DefenderKill"
const string CONTROL_EXPEVENT_HIGHTIERKILL = "Control_Exp_HighTierKill"
const string CONTROL_EXPEVENT_REALLYHIGHTIERKILL = "Control_Exp_ReallyHighTierKill"
const string CONTROL_EXPEVENT_CONTESTING = "Control_Exp_ContestingObjective"
const string CONTROL_EXPEVENT_CAPTURING = "Control_Exp_CapturingObjective"
const string CONTROL_EXPEVENT_DEFENDING_ACTIVEPOINT = "Control_Exp_DefendingActiveObjective"
const string CONTROL_EXPEVENT_CAPTURED = "Control_Exp_CapturedObjective"
const string CONTROL_EXPEVENT_TEAM_CAPTURED = "Control_Exp_TeamCapturedObjective"
const string CONTROL_EXPEVENT_NEUTRALIZED = "Control_Exp_NeutralizedObjective"
const string CONTROL_EXPEVENT_TEAM_NEUTRALIZED = "Control_Exp_TeamNeutralizedObjective"
const string CONTROL_EXPEVENT_WITHSQUADBONUS = "Control_Exp_WithSquadBonus"
const string CONTROL_EXPEVENT_KILLEXPLEADER = "Control_Exp_KillEXPLeader"
const string CONTROL_EXPEVENT_DEFENDING = "Control_Exp_DefendingObjective"
const string CONTROL_EXPEVENT_BOUNTYCLAIMED = "Control_Exp_BountyClaimed"
const string CONTROL_EXPEVENT_LOCKOUTBROKEN = "Control_Exp_TeamCanceledLockout"
const string CONTROL_EXPEVENT_SPAWNONBASE = "Control_Exp_SpawnOnBase"
const string CONTROL_EXPEVENT_RESPAWN = "Control_Exp_Respawn"
const string CONTROL_EXPEVENT_MRBCARRIER = "Control_Exp_MRBCarrier"
const string CONTROL_EXPEVENT_MRBDEPLOYED = "Control_Exp_MRBDeployed"

const bool CONTROL_ARE_AIRDROPS_ALLOWED_ON_CONTROL_GEO = false // using a blanket bool right now to allow or not allow airdrops on custom geo made for control. We can investigate changing this in the future, false for now because they drop through the geo
const int CONTROL_VEHICLE_AIRDROP_BAD_PLACE_RADIUS = 300
const int CONTROL_SKYDIVE_LAUNCHER_AIRDROP_BAD_PLACE_RADIUS = 150
const int CONTROL_DEFAULT_MAX_PLAYERS = 18
#endif // CLIENT || SERVER

#if DEVELOPER && SERVER
// Dev Commands for Testing
global function Control_ForceGiveExp_Dev
global function Control_ForceExpTierUp_Dev
global function Control_ForceLockOutBegin_Dev
global function Control_ForceLockoutAbort_Dev
global function Control_ForceCaptureObjective_Dev
global function Control_ForceNeutralizeObjective_Dev
global function Control_ForceSetAllianceScore_Dev
global function Control_ForcePauseOrResumeScoring_Dev
global function Control_ForceEndMatch_Dev
global function Control_FakeJoinInProgressFlow_Dev
global function Control_SetForcedSpawnPointIndex_Dev
global function Control_ForceTriggerTimedEvent_Dev
#endif // #if DEV && SERVER

#if DEV
	const bool CONTROL_SPAWN_DEBUGGING = false
	const bool CONTROL_DISPLAY_DEBUG_DRAWS = false // Display in world draws for things like bad airdrop places, traces
	const float CONTROL_DEBUG_DRAW_DISPLAY_TIME = 1000.0
#endif // DEV

#if SERVER || CLIENT
const bool CONTROL_DETAILED_DEBUG = false // Debug prints behind this check fire very frequently and are turned off by default
const bool CONTROL_PLAYER_SPAWN_DEBUG_PRINTS = true
#endif // SERVER || CLIENT

global const CONTROL_DROPPOD_SCRIPTNAME = "control_droppod"
global const CONTROL_OBJECTIVE_SCRIPTNAME = "control_objective"

// Objective Waypoint
global const CONTROL_INT_OBJ_ALLIANCE_OWNER = 0
const FLOAT_CAP_PERC = 1
const FLOAT_BOUNTY_AMOUNT = 2
const FLOAT_AVG_BOUNDARY_RADIUS = 3
const INT_CAPTURING_ALLIANCE = 3
global const INT_CONTROL_WAYPOINT_TYPE_INDEX = 4
const INT_ALLIANCE_A_PLAYERSONOBJ = 5
const INT_ALLIANCE_B_PLAYERSONOBJ = 6
const CONTROL_INT_OBJ_NEUTRAL_ALLIANCE_OWNER = 7

const float CONTROL_INTRO_DELAY = 2.2

const INT_ALLIANCE_A_SCORE = 4
const INT_ALLIANCE_B_SCORE = 5

const asset CONTROL_OBJ_DIAMOND_EMPTY = $"rui/hud/gametype_icons/winter_express/team_diamond_empty"
const asset CONTROL_OBJ_DIAMOND_YOURS = $"rui/hud/gametype_icons/winter_express/team_a_diamond"
const asset CONTROL_OBJ_DIAMOND_ENEMY = $"rui/hud/gametype_icons/winter_express/team_b_diamond"
const asset TEAMMATE_DEATH_ICON = $"rui/rui_screens/icon_skull_postdeath"
const asset TEAMMATE_SPAWN_ICON = $"rui/hud/pve/extraction_dropship"
const asset AIRDROP_LANDED_ICON = $"rui/hud/ping/icon_ping_loot"
const float CONTROL_TEAMMATE_DEATH_ICON_LIFETIME = 12.0 // needs to be longer than CONTROL_TEAMMATE_DEATH_ICON_DURATION in the rui to allow for fade ins and fade outs in the Rui
const float TEAMMATE_SPAWN_ICON_DURATION = 10.0

const SPAWN_DIST = 1000
const float SPAWN_MIN_RADIUS = 128
const float SPAWN_MIN_RADIUS_NEAR_SQUAD = 712
const float SPAWN_MAX_RADIUS_BASE = 1028
const float SPAWN_MAX_RADIUS_NEAR_SQUAD = 1400
const SPAWN_MAX_TRY_COUNT = 60
const SPAWN_VIEW_DISTANCE_CHECK = 150

// Spawn point Waypoint
const int CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX = 5
const int CONTROL_MRB_SPAWN_WAYPOINT_ENDTIME = 6
const float CONTROL_DEFAULT_MRB_LIFETIME = 120.0
const float CONTROL_DEFAULT_MRB_AIRDROP_DELAY = 15.0
global const string MRB_WEAPON_REF_NAME = "mp_ability_mobile_respawn_beacon" // ToDo: DSwieczko put this in respawn beacon script
global const string MRB_SUPPLY_DROP_NAME = "mp_ability_mobile_supply_drop" // ToDo: DSwieczko put this in respawn beacon script
const string PLAYER_WITH_MRB_NET_NAME = "control_MrbTimedEventPlayerWithMrb"
const string WAYPOINT_CONTROL_MRB = "waypoint_control_mrb"
const int CONTROL_WAYPOINT_TRIGGER_ENTITY_INDEX = 1

// Player Waypoint, used to show teammate location icons on the map
const string WAYPOINT_CONTROL_PLAYERLOC = "waypoint_control_playerloc"
global const int CONTROL_PLAYERLOC_WAYPOINT_PLAYERENTITY_INDEX = 0

global const asset CONTROL_WAYPOINT_FLARE_ASSET = $"P_control_flare"

global const asset CONTROL_WAYPOINT_BASE_ICON = $"rui/hud/gametype_icons/survival/sur_hovertank_minimap"
global const asset CONTROL_WAYPOINT_PLAYER_ICON = $"rui/hud/gamestate/player_count_icon"

const string WAYPOINT_CONTROL_AIRDROP = "waypoint_control_airdrop"
const int AIRDROP_WAYPOINT_LOOTTIER_INT = 0
const asset HOVER_VEHICLE_SPAWN_BASE = $"mdl/olympus/olympus_vehicle_base.rmdl"
const asset FX_VEHICLE_SPAWN_POINT = $"P_veh_vh1_spawnpoint"
const int	VEHICLE_LIMIT = 6
const vector ANNOUNCEMENT_RED = <235, 65, 65>
const asset DEATH_SCREEN_RUI = $"ui/control_squad_summary_header_data.rpak"

global const string CONTROL_SCORINGEVENT_CAPTURED = "Control_CapturedObjective"
global const string CONTROL_EXPEVENT_GUNRACK_PURCHASE = "Control_Exp_GunRackUse"
global const string CONTROL_EXPEVENT_EXPRESET = "Control_Exp_ExpReset"

const string CONTROL_PIN_VICTORYCONDITION_UNKNOWN = "unknown"
const string CONTROL_PIN_VICTORYCONDITION_SCORE = "score_limit_reached"
const string CONTROL_PIN_VICTORYCONDITION_LOCKOUT = "lockout"
const string CONTROL_PIN_VICTORYCONDITION_FORFEIT = "team_forfeit"

global const int CONTROL_MAX_EXP_TIER = 4
global const int CONTROL_MAX_LOOT_TIER = 3

global const int CONTROL_TEAMSCORE_LOCKOUTBROKEN = 50

#if SERVER
const float CONTROL_SPAWNKILLDETECTION_DETECTION_DISTANCE = 1574.8 // 40m
const float CONTROL_SPAWNKILLDETECTION_HIGHLIGHT_DURATION = 25.0
const float CONTROL_TIME_BETWEEN_CONTESTING_ALERTS = 6.0
const float CONTROL_TIME_BEFORE_INIT_SPAWNPOINTS = 2.0
const float CONTROL_MIN_TIME_BEFORE_BOTS_SPAWN = 3.0
const float CONTROL_MAX_TIME_BEFORE_BOTS_SPAWN = 5.0
const float CONTROL_PRE_SPAWN_BUTTON_DISABLE_TIME = 0.5 // When we are this amount of time away from respawning; disable and close the loadout select menu and character select menus to prevent potential timing issues.
Assert( CONTROL_MIN_TIME_BEFORE_BOTS_SPAWN > CONTROL_TIME_BEFORE_INIT_SPAWNPOINTS, "CONTROL_MIN_TIME_BEFORE_BOTS_SPAWN needs to be later than CONTROL_TIME_BEFORE_INIT_SPAWNPOINTS otherwise waypoints might not be ready for first spawn" )

const int DEFAULT_AIRDROP_TIER = 3
const int RESPAWN_ON_TEAM_HULL = HULL_PROWLER
const int CONTROL_TEAMSCORE_FOR_KILL = 0
const int CONTROL_ALERT_INDEX_CAPTURED_OBJECTIVE = 0
const int CONTROL_ALERT_INDEX_NEUTRALIZED_OBJECTIVE = 1
const string CONTROL_DEFAULT_AIRDROP_CONTENTS = "control_airdrop_left control_airdrop_right control_airdrop_center"
const string CONTROL_MRB_EVENT_AIRDROP_CONTENTS = "control_mrb_event_airdrop_left control_mrb_event_airdrop_right control_mrb_event_airdrop_center"

const string CONTROL_SCORINGEVENT_ELIMINATION = "Control_Elimination"
const string CONTROL_SCORINGEVENT_BOUNTYCLAIMED = "Control_BountyClaimed"
const string CONTROL_SCORINGEVENT_LOCKOUTBROKEN = "Control_LockoutCanceled"

const string CONTROL_AIRDROP_ANIMATION = "droppod_loot_drop_lifeline"
const string CONTROL_DEFAULT_WEAPON_LOADOUT = "mp_weapon_vinson_blueset mp_weapon_autopistol_blueset"
const string CONTROL_DEFAULT_CONSUMABLES_LOADOUT = "health_pickup_health_small:1 health_pickup_health_large:1 mp_weapon_frag_grenade:1"
const string CONTROL_DEFAULT_EQUIPMENT_LOADOUT = "backpack_pickup_lv2 armor_pickup_lv2 helmet_pickup_lv2 incapshield_pickup_lv2"
const string CONTROL_LATEJOIN_EQUIPMENT_LOADOUT = "backpack_pickup_lv2 armor_pickup_lv3 helmet_pickup_lv3 incapshield_pickup_lv2"
const array<string> CONTROL_WEAPON_SET_STRINGS_FOR_TIER = [ WEAPON_LOCKEDSET_SUFFIX_WHITESET, WEAPON_LOCKEDSET_SUFFIX_WHITESET, WEAPON_LOCKEDSET_SUFFIX_BLUESET, WEAPON_LOCKEDSET_SUFFIX_PURPLESET, WEAPON_LOCKEDSET_SUFFIX_GOLD ]

const string CONTROL_PINEVENT_CONTESTING = "contesting"
const string CONTROL_PINEVENT_CAPTURING = "capturing"
const string CONTROL_PINEVENT_DEFENDING = "defending"
const string CONTROL_PINEVENT_DEFENDING_ACTIVEPOINT = "defending_active"
const string CONTROL_PINEVENT_CAPTURED = "capture"
const string CONTROL_PINEVENT_NEUTRALIZED = "neutralized"
const string CONTROL_PINEVENT_CAPTUREBONUS = "timed_event"
const string CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT = "Control Objective: "
const string CONTROL_PINEVENT_RESPAWNCHOICE_BASE = "base"
const string CONTROL_PINEVENT_RESPAWNCHOICE_POINT = "control_point"
const string CONTROL_PINEVENT_RESPAWNCHOICE_MRB = "mrb"

const string CONTROL_PINEVENT_SPAWNINFO_ALLIANCEABASE = "ALLIANCE_A Base"
const string CONTROL_PINEVENT_SPAWNINFO_ALLIANCEBBASE = "ALLIANCE_B Base"
const string CONTROL_PINEVENT_RESPAWNCHOICE_FAILED = "spawn failed"

global const string CONTROL_SKYDIVELAUNCHER_SCRIPT_NAME = "control_skydive_launcher"

// Exp weapon Evo VFX and SFX
const float WEAPONEVO_UPGRADE_FX_RANGE = 3937.0 // about 100m

const float SPAWN_GROUPING_DURATION = 3.0 // should prevent always spawning in same area
#endif // SERVER

#if SERVER || CLIENT
const int CONTROL_VICTORY_FLAGS_UNKNOWN = 0
const int CONTROL_VICTORY_FLAGS_SCORE = ( 1 << 1 )
const int CONTROL_VICTORY_FLAGS_LOCKOUT = ( 1 << 2 )
const int CONTROL_VICTORY_FLAGS_FORFEIT = ( 1 << 3 )

const int CONTROL_TEAMSCORE_PER_POINT = 1
const float CONTROL_LOCKOUT_EVENT_DURATION = 90.0

const int CONTROL_MRB_ISMRBAIRDROP_BITFIELD = 1

const float TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES = 1.0
#endif // SERVER || CLIENT

#if CLIENT
// Exp weapon Evo VFX
const FX_WEAPON_EVO_UPGRADE_FP = $"P_wpn_evo_upgrade_FP"
const FX_EXP_LEVELUP_3P = $"P_wpn_evo_upgrade"
const int CONTROL_OBJECTIVE_RUI_SORTING = 301 // HUD_Z_BASE is what fog is at, it is 300
const int CONTROL_TEAMMATE_ICON_SORTING = 302
const float CONTROL_DEFAULT_WEAPON_EVO_VFX_DELAY = 0.5

// SFX
// Weapon Evo
const string CONTROL_SFX_WEAPON_EVO_LVL_1 = "Ctrl_Loadout_Upgrade_lvl1_1P"
const string CONTROL_SFX_WEAPON_EVO_LVL_2 = "Ctrl_Loadout_Upgrade_lvl2_1P"
const string CONTROL_SFX_WEAPON_EVO_LVL_3 = "Ctrl_Loadout_Upgrade_lvl3_1P"
const string CONTROL_SFX_WEAPON_EVO_LVL_4 = "Ctrl_Loadout_Upgrade_lvl4_1P"
const string CONTROL_SFX_WEAPON_EVO_FIRST_ALERT = "Ctrl_Loadout_EvoPending_Alert_A_1p"
const string CONTROL_SFX_WEAPON_EVO_ALERT = "Ctrl_Loadout_EvoPending_Alert_B_1p"
// EXP Gain
const string CONTROL_SFX_EXP_GAIN = "Ctrl_XP_Gain_1p"
// Lockout
const string CONTROL_SFX_LOCKOUT_START = "Ctrl_LockOut_Begin_1p"
const string CONTROL_SFX_LOCKOUT_ABORT = "Ctrl_LockOut_Abort_1p"
// Capture Zone
const string CONTROL_SFX_CAPTURE_ZONE_ENTER = "Ctrl_Zone_Enter_1p"
const string CONTROL_SFX_CAPTURE_ZONE_EXIT = "Ctrl_Zone_EXIT_1p"
const string CONTROL_SFX_ZONE_CAPTURED_FRIENDLY = "Ctrl_Zone_Capture_1p"
const string CONTROL_SFX_ZONE_CAPTURED_ENEMY = "Ctrl_Zone_Capture_Enemy_1p"
const string CONTROL_SFX_ZONE_NEUTRALIZED = "Ctrl_Zone_Neutralized_1p"
// Capture Bonus
const string CONTROL_SFX_CAPTURE_BONUS_ADDED = "Ctrl_CaptureBonus_Added_1p"
const string CONTROL_SFX_CAPTURE_BONUS_CLAIMED_FRIENDLY = "Ctrl_CaptureBonus_Claimed_1p"
const string CONTROL_SFX_CAPTURE_BONUS_CLAIMED_ENEMY = "Ctrl_CaptureBonus_Claimed_Enemy_1p"
// Match End
const string CONTROL_SFX_GAME_END_VICTORY = "Ctrl_Victory_1p"
const string CONTROL_SFX_GAME_END_LOSS = "Ctrl_Loss_1p"
// Last Objective being Captured
const string CONTROL_FINAL_OBJECTIVE_BEING_CAPTURED_WARNING = "Ctrl_Match_End_Warning_1p"

const string CONTROL_SFX_MRB_STATUS_UPDATE = "Ctrl_MRB_Update_1p"
const string CONTROL_SFX_MRB_STATUS_UPDATE_ENEMY = "Ctrl_MRB_Update_Enemy_1p"

global const asset CONTROL_MRB_INWORLD_ICON = $"rui/gamemodes/control/mobile_respawn_beacon_icon_shadow"
const asset CONTROL_MRB_DIAMOND_ICON = $"rui/gamemodes/control/icon_ping_go_inner_darker"
const asset CONTROL_MRB_DIAMOND_ICON_OUTLINE = $"rui/hud/ping/icon_ping_any_outline"
const asset CONTROL_MRB_DIAMOND_ICON_SHADOW = $"rui/hud/ping/icon_ping_any_shadow"
const asset CONTROL_MRB_HELD_OUTER_ICON = $"rui/gamemodes/control/compass_holding_MRB"
const float MRB_ICON_OFFSET = 10
const float MRB_ICON_OFFSET_CARRIED = 100
#endif // CLIENT

#if DEV
const float SPAWNPOINT_RADIUS = 20
const float SPAWNPOINT_HEIGHT = 128
const float SPAWNPOINT_DISPLAY_TIME = 60
#endif // DEV

global const array<string> CONTROL_DISABLED_BATTLE_CHATTER_EVENTS = [
	"bc_anotherSquadAttackingUs",
	"bc_squadsLeft2 ",
	"bc_squadsLeft3 ",
	"bc_squadsLeftHalf",
	"bc_twoSquaddiesLeft",
	"bc_championEliminated",
	"bc_killLeaderNew",
	"bc_podLeaderLaunch",
	"bc_imJumpmaster",
	"bc_firstBlood",
	"bc_weTookFirstBlood",
]

global const array<int> CONTROL_DISABLED_COMMS_ACTIONS = [

	eCommsAction.INVENTORY_NO_AMMO_BULLET,
	eCommsAction.INVENTORY_NO_AMMO_ARROWS,
	eCommsAction.INVENTORY_NO_AMMO_HIGHCAL,
	eCommsAction.INVENTORY_NO_AMMO_SHOTGUN,
	eCommsAction.INVENTORY_NO_AMMO_SNIPER,
	eCommsAction.INVENTORY_NO_AMMO_SPECIAL,

]

global enum eControlPointObjectiveState
{
	CONTESTED,
	CONTROLLED,
}

// Spawn point indexes used to differentiate objectives and spawn points through waypoint int INT_CONTROL_WAYPOINT_TYPE_INDEX
global enum eControlWaypointTypeIndex
{
	// Unless we want to do more refactor work, the Objective Indexes need to match the original point.id values
	OBJECTIVE_A,
	OBJECTIVE_B,
	OBJECTIVE_C,
	// Indexes of these ones don't matter
	HOMEBASE_ALLIANCE_A,
	HOMEBASE_ALLIANCE_B,
	MRB_SPAWN,
	SQUAD_SPAWN,
	_count
}

#if CLIENT || UI
// Used to set which team can use a spawn waypoint so the UI shows the appropriate info
global enum eControlSpawnWaypointUsage
{
	ENEMY_TEAM,
	NOT_USABLE,
	FRIENDLY_TEAM
}
#endif // CLIENT || UI

enum eControlSpawnAlertCode
{
	SPAWN_FAILED,
	SPAWN_CANCELLED,
	SPAWN_LOST_SPAWNPOINT,
	SPAWN_LOST_MRB,
	_count
}

enum eControlIconIndex
{
	DEATH_ICON,
	SPAWN_ICON,

	_count
}

// Enum of timed events, used to trigger them through a function call ( currently only for Lockout )
enum eControlTimedEventType
{
	LOCKOUT,
	AIRDROP,
	MRB,
	BOUNTY,
	_count
}

#if CLIENT
enum eControlMRBTimeEventMRBState
{
	IDLE,
	PERSONAL_HELD,
	FRIENDLY_HELD,
	ENEMY_HELD,
}
#endif // CLIENT

#if SERVER || CLIENT
// NOTE: The order of these is important ( should be in the order these phases occur ) as Client side messaging depends on it
enum eControlMRBTimeEventPhase
{
	INTRO,
	AIRDROP,
	MRB_IN_PLAY,
	MRB_LAUNCHED,
	MRB_DEPLOYED,
}

enum eControlMRBPlacementState
{
	SUCCESS,
	BAD_POSITION,
	NEAR_OBJECTIVE,
	NEAR_HOMEBASE,
	NEAR_HOMEBASE_ENEMY,
	_count
}
#endif // SERVER || CLIENT

#if SERVER
enum eControlWeaponDisableReason
{
	DROPSHIP_SPAWN,
	HOVERTANK,
	_count
}
#endif // SERVER

#if SERVER
enum eControlZoneState
{
	INVALID,
	OPEN,
	CAPTURING,
	CONTESTING,
	NEUTRALIZING,
	CAPTURED,

	_count,
}
#endif // SERVER

#if SERVER
struct ControlPointData
{
	entity trigger
	entity waypoint
	entity flagProp
	array<entity> spawns

	int id = -1
	string name
	string parentMapVariant
	vector location

	int currentObjectiveState = eControlPointObjectiveState.CONTROLLED
	array< entity > playersInControlPoint
	int lastCapturingAlliance = ALLIANCE_NONE
	int controlPointOwner = ALLIANCE_NONE
	int neutralPointOwnership = ALLIANCE_NONE  // Which team made progress to capture the point without fully capturing it yet
	float controlPointPercent = 0

	table<int, float> timeOwnedByTeamForMatch
	table<entity, float> timeCapturingByPlayerForMatch
	table<entity, float> timeOnObjectiveByPlayerForMatch
	float fullControlConversionTime = FLT_MAX

	float lastBountyAward = FLT_MAX
	bool hasBountyBeenSet = false

	int lastZoneState = eControlZoneState.INVALID
}

struct ControlTeamSpawnData
{
	array<entity> spawnTriggers
	array<entity> playersInSpawnTriggers
	table<entity, array<entity> >	spawnTriggerToSpawns
}

struct ControlMapVariantData
{
	string mapID
	string nameString
	vector mapCenter
	float mapRadius

	array<ControlPointData> controlPoints
	table<entity, ControlPointData> triggerToControlPointMap

	table< int, ControlTeamSpawnData > teamSpawnData
	table<entity, ControlTeamSpawnData> triggerToSpawnDataMap
}
#endif // SERVER

struct ControlAnnouncementData
{
	bool isInitialized = false

	entity 		wp
	bool 		shouldTerminateIfWPDies = false
	bool		shouldForcePushAnnouncement = false
	bool		shouldUseTimer

	string 		mainText
	string		subText
	float		displayLength

	float 		displayStartTime
	float		startTime
	float		eventLength

	vector 		overrideColor
}

struct ControlTeamData
{
	int teamScoreFromPoints = 0
	int teamScoreFromBonus = 0
	int teamScorePerSec = 0
}

const ControlTeamData ControlTeamDataDefaults = {
	teamScoreFromPoints =  0
	teamScoreFromBonus = 0
	teamScorePerSec = 0
}

struct {
	entity[eControlWaypointTypeIndex._count] spawnWaypoints
	bool isLockout = false
	bool isRampUp = false

	vector cameraLocation
	vector cameraAngles

	#if SERVER
		array<ControlMapVariantData> mapVariants
		ControlMapVariantData& chosenVariantData

		bool mapInitialized = false
		int				bountiesCreated

		array<entity>				   aliveVehicles
		array<entity>				   lastRecentlyUsedVehicleStack

		//used for map setup from leveled
		array<ControlPointData> controlPoints
		array<entity> teamSpawnAreas
		array<entity> controlProps
		array<entity> flagProps
		array<entity> vehicleSummonPlatforms
		array<entity> controlGunRacks
		array<entity> controlGunRackPanels
		array<entity> controlSkydiveLaunchers
		array<entity> controlBoundaryWalls
		array<entity> controlSpawns
		array<entity> controlFuncGeo
		array<entity> spawnScreenCameras

		entity musicEntity
		bool rampUpLevel1 = false
		bool rampUpLevel2 = false
		bool rampUpLevel3 = false
		bool rampUpLevel4 = false

		//for notifcations for score
		table<int, bool> announcedHalfwayForAlliance
		table<int, bool> announcedLeadingForAlliance
		table<int, bool> announcedImminentWinForAlliance
		// for notifications for lockout
		bool announcedLockoutUnavailable = false

		//spawn selection debounce verification
		table< entity, float >	dropshipToDropshipSpawnTimeTable
		table< entity, array< entity > > dropshipToPlayersOnDropshipTable
		array< entity > playersAbleToSelectSpawnArray
		table< entity, int > playerToRespawnChoice
		array< entity > playersPendingExemptionFromWaveSpawn
		array< entity > playersWithFullUltOnDeath

		// Loot
		int unopenedAirdropCount
		array<entity> droppedItems
		table<entity, entity> airdropToWaypointTable
		table<entity, int> airdropToLootTierTable
		array<vector> usedAirdropPositions
		//array<HoverTank> setHovertank
		table<entity, int> hovertankMoverToAlliance

		// Exp
		array< entity > playersInCombatArray // ToDo: DSwieczko remove if we decide to keep evo on reload
		array< entity > playersWaitingForExpTierUpArray
		array< entity > playersWithWeaponEvoInProgressArray
		table< entity, int > playerToLastRespawnChoice
		int expLeaderExpThreshold = 0
		float timeOfLastExpLeaderSwitch
		entity expLeader
		table< entity, float > playerToLastEXPEvoBadWeaponCheckTimeTable // ToDo: DSwieczko remove if we decide to keep evo on reload

		//Scoreboard
		int team0ScoreFromBonus
		int team1ScoreFromBonus

		// Objective Pings
		array<entity> objectiveStarterPingTraceBlockers

		// PinData
		int lastBountyPointID = -1

		// Misc
		bool isFirstWaveSpawn = true
		array<entity> playerFirstSpawnList

		// MRB Timed Event
		int activeMRBAllianceOwner
		float nextTimeAllowedToPlayMRBSecuredDialogue
		bool didMRBSpawn = false
		bool isMRBInPlay
		bool isMRBEventActive
		entity activeMRBSurvivalItem
		entity activeMRB
		entity activeMRBWaypoint
		entity activeMRBOwner
		entity mrbAirdropWP
		vector mrbSpawnPosition
		vector mrbSpawnAngles

		table< entity, float > spawnPoints_LastUsed
	#endif // SERVER

	#if CLIENT || SERVER
		array< entity > playersUsingLosingTeamExpTiersArray

		//HomeBase Positions for MRB
		array< vector > allianceABlockedHomeBasePositionsForMRB = []
		array< vector > allianceBBlockedHomeBasePositionsForMRB = []
	#endif // CLIENT || SERVER

	#if CLIENT
		array<entity> waypointList
		array<entity> flagPropList

		table<entity, var> waypointToMinimapRui
		table<entity, var> waypointToFullmapRui
		table<entity, var> waypointToObjectiveFlare

		var onObjectiveRui
		table<int, var> scoreTrackerRui
		table<int, var> fullmapScoreTrackerRui

		float characterSelectClosedTime = 0
		bool shouldImmediatelyOpenCharacterSelectOnRespawn = false

		array<var> spawnButtons
		table< entity, var > waypointToSpawnButton
		table< var, entity > spawnButtonToWaypoint
		var			spawnHeader
		float		uiVMUpdateTime
		var			bountyTracker

		var announcementRui
		var fullMapAnnouncementRui
		array<ControlAnnouncementData> announcementData
		ControlAnnouncementData& currentAnnouncement

		entity cameraMover
		bool contextPushed
		bool isPlayerInMapCameraView = false
		array< var > teammateLocationIconRuiArray = []
		array< var > teammateDeathIconRuiArray = []

		var respawnBlurRui
		var inGameMapRui
		bool tutorialShown = false
		table< entity, var > inGameMapPointsToRuis
		array< int > inGameMapPointNestedRuiIndexes

		bool firstTimeRespawnShouldWait = false

		array< ControlTeamData > teamData = [ ControlTeamDataDefaults, ControlTeamDataDefaults ]

		int mrbState
	#endif // CLIENT

	#if DEVELOPER && SERVER
		bool isScoringPaused = false
		int testingSpawnPointIndex = -1
	#endif // DEV && SERVER
} file


// Mode-specific table info for Game Summary Squad Data
// these should be specific to the final display location - e.g., 4 displays in "slot 4" -> 1 / 1a / 1b | 2 | 3 | 4 | 5 -- maps to --> [ 0, ... , 0 ]
// so 4 would be the 4th index - or 5th slot - *in the array* or position 3 on the UI.
global enum eControlStat {
	RATING = 4,
	OBJECTIVES_CAPTURED = 5,
}

/*
   _____    ____    _____    ______     _____   _   _   _____   _______   _____              _        _____   ______             _______   _____    ____    _   _
  / ____|  / __ \  |  __ \  |  ____|   |_   _| | \ | | |_   _| |__   __| |_   _|     /\     | |      |_   _| |___  /     /\     |__   __| |_   _|  / __ \  | \ | |
 | |      | |  | | | |__) | | |__        | |   |  \| |   | |      | |      | |      /  \    | |        | |      / /     /  \       | |      | |   | |  | | |  \| |
 | |      | |  | | |  _  /  |  __|       | |   | . ` |   | |      | |      | |     / /\ \   | |        | |     / /     / /\ \      | |      | |   | |  | | | . ` |
 | |____  | |__| | | | \ \  | |____     _| |_  | |\  |  _| |_     | |     _| |_   / ____ \  | |____   _| |_   / /__   / ____ \     | |     _| |_  | |__| | | |\  |
  \_____|  \____/  |_|  \_\ |______|   |_____| |_| \_| |_____|    |_|    |_____| /_/    \_\ |______| |_____| /_____| /_/    \_\    |_|    |_____|  \____/  |_| \_|


*/



void function Control_Init()
{
	#if CLIENT || SERVER
		AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	#endif // CLIENT || SERVER

	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return


	// Map and Geo Setup ( for culling of geo when Control is disabled see _gamemode_map_cleanup.nut )
	#if SERVER
		// Block creation of BR assets we don't want in Control
		BlockMapEntityParseCreationOf( "zipline", "script_control_omit_zipline", "" ) //TODO SHAWBS - ZIPLINE PROPS NEED TO BE REMOVED TOO
		BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_survival_survey_beacon" )
		BlockMapEntityParseCreationOf( "zipline", "skydive_tower", "" )
		BlockMapEntityParseCreationOf( "prop_dynamic", "jump_tower", "" )
		BlockMapEntityParseCreationOf( "prop_dynamic", "jump_tower_stairs", "" )
		BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_loot_marvin" )
		AddSpawnCallback( "func_brush", Control_OnEditorFuncGeoCreated )

		// Circle Culling Logic has been moved to _gamemode_utility.nut

		// Handle Control Geo
		AddSpawnCallbackEditorClass( "prop_script", "control_vehicle_summon_platform", Control_OnEditorVehicleSummonCreated )
		AddSpawnCallbackEditorClass( "prop_dynamic", "control_flag_prop", Control_OnEditorFlagPropCreated )
		AddSpawnCallbackEditorClass( "prop_dynamic", GUN_RACK_CLASS_NAME, Control_OnEditorGunRackCreated )
		AddSpawnCallbackEditorClass( "prop_dynamic_lightweight", GUN_RACK_CLASS_NAME, Control_OnEditorGunRackCreated )
		AddSpawnCallbackEditorClass( "prop_dynamic", CONTROL_GUN_RACK_CLASS_NAME, Control_OnEditorControlGunRackCreated )
		AddSpawnCallbackEditorClass( "prop_dynamic", CONTROLGUNRACKPANEL_CLASS_NAME, Control_OnEditorControlGunRackPanelCreated )
		AddSpawnCallbackEditorClass( "script_ref", "script_skydive_launcher", Control_OnSpawnedSkydiveLauncherEditorClass )
		AddSpawnCallbackEditorClass( "func_brush", "func_brush_control_wall", Control_OnEditorControlWallCreated )
		AddSpawnCallback( "info_spawnpoint_human", Control_OnSpawnPointCreated )

		AddSpawnCallbackEditorClass( "script_ref", "info_control_map_data", Control_OnMapDataCreated )
		AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_control_objective", Control_OnEditorObjectiveCreated )
		AddSpawnCallbackEditorClass( "script_ref", "info_control_team_spawn_area", Control_OnEditorSpawnAreaCreated )
		AddCallback_OnGetBestObserverTarget( RespawnBeacon_GetBestObserverTarget )
		AddSpawnCallbackEditorClass( "script_ref", "spawn_screen_camera", Control_OnEditorSpawnCameraCreated )

		Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Directional )
	#endif


	#if CLIENT || SERVER
		TimedEvents_Init()
		CausticTT_SetGasFunctionInvertedValue( true )
		PrecacheScriptString( "Control_SetUsableVehicleBase" )
		PrecacheScriptString( CONTROL_MODE_MOVER_SCRIPTNAME )
		PrecacheParticleSystem( $"P_wpn_evo_upgrade_FP" )
		PrecacheParticleSystem( $"P_wpn_evo_upgrade" )
		Control_RegisterTimedEvents()
		CaptureObjectivePing_AddCallback_SetGetCaptureObjectiveIDFromWaypointFunction( Control_GetObjectiveIDFromWaypoint )
		CaptureObjectivePing_AddCallback_SetIsCaptureObjectivePingObjectiveWaypoint( Control_IsObjectiveWaypoint )









		MobileRespawn_SetDeployPositionValidationFunc( Control_MRBTimedEvent_MRBDeployPositionValidation )

		if ( CONTROL_DETAILED_DEBUG )
			printt( "CONTROL: CONTROL_DETAILED_DEBUG is set to true, debug prints that fire very frequently are enabled" )
		else
			printt( "CONTROL: CONTROL_DETAILED_DEBUG is set to false, to enable debug prints that fire frequently set CONTROL_DETAILED_DEBUG to true" )
	#endif // CLIENT || SERVER

	#if SERVER
		GamemodeUtility_AddCallback_SetGamemodeWinnerFunction( Control_SetWinner )
		PrecacheParticleSystem( $"P_ar_cylinder_radius_CP_1x1" )








			AddCallback_GameStateEnter( eGameState.Resolution, Control_OnGameStatePlaying_Resolution )


		SkydiveLauncher_SetDefaultMapInitializationFunction( Control_SkydiveLauncherMapInitialization )

		AddCallback_EntitiesDidLoad( OnEntitiesDidLoad_MapSetup )
		AddCallback_GameStateEnter( eGameState.Playing, Control_OnGameStatePlaying )
		AddCallback_GameStateEnter( eGameState.Prematch, Control_OnGameStatePrematch )

		SetShouldSpawnPlayerOnConnect( Control_SupressGameStartSpawn_Player )
		//todo: look a bit deeper into why this is necessary
		AddCallback_ShouldPlayerSpawnAtStart( Control_SupressGameStartSpawn_Player )
		Survival_SetCallback_ModeShouldSpawnPlayersDuringCharacterSelect( Control_SupressGameStartSpawn )
		AddCallback_OnClientConnected( OnPlayerConnected )
		AddCallback_OnObserverConnected( Control_OnObserverConnected )
		AddCallback_OnClientConnectionRestored( ConnectionRestored_ShowSpawnSelection )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )

		AddCallback_OnPlayerPostRespawned( Control_OnPlayerPostRespawned )
		AddCallback_OnPlayerKilled( Control_OnPlayerKilled )
		AddCallback_OnPlayerAssist( Control_AwardAssist )
		SetExtendedPostDeathLogic( Control_ExtendedPostDeathLogic )
		Survival_AddCallback_IsSquadReallyEliminated( Control_IsSquadReallyEliminated )
		SetDeathCamTimeOverride( Control_DeathCamTimeOverride )

		AddCallback_OnLeaveMatch( OnLeaveMatch )

		Survival_AddCallback_OnPlayerSetupComplete( Control_PlayerChangedCharacter )
		AddCallback_Score_OnPlayerKilled( GAMEMODE_CONTROL, Control_AwardKill )

		//HoverVehicle_AddCallback_OnVehicleDisembarkFinished( Control_VehicleOnDisembark )
		AddSpawnCallback( "prop_script", OnVehicleBaseSpawned )

		AbilityCarePackage_SetContentOverrideCallback(Control_OverrideAbilityCarePackage)

		if ( Control_GetShouldEvoWeaponsOnWeaponSwitch() )
		{
			AddCallback_OnPlayerReload( Control_OnWeaponReload )
			AddCallback_OnPlayerWeaponSwitched( Control_OnWeaponSwitched )
			AddCallback_OnDeployAndEnableWeapons( Control_OnWeaponDeployed )
		}

		if ( IsUsingLoadoutSelectionSystem() )
		{
			AddCallback_LoadoutSelection_OnLoadoutMenuClosed( Control_OnLoadoutSelectMenuClosed )
			AddCallback_LoadoutSelection_OnLoadoutUpdated( Control_OnLoadoutUpdated )
		}

		// Disabled commentary events for LTM
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.PILOT_KILL, false ) // will manually trigger first blood
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVING, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.FINAL_CIRCLE_MOVING, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_CLOSING_TO_NOTHING, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.FIRST_BLOOD, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HALF_PLAYERS_ALIVE, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HALF_SQUADS_ALIVE, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HOVER_TANK_INBOUND, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.ROUND_TIMER_STARTED, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.FIRST_CIRCLE_MOVING, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_1MIN, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_10SEC, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_30SEC, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_45SEC, false )
		RegisterDisabledBattleChatterEvents( CONTROL_DISABLED_BATTLE_CHATTER_EVENTS )
		QuickChat_RegisterDisabledCommsActions( CONTROL_DISABLED_COMMS_ACTIONS )

		SetGlobalNetBoolSafe( "isMapZoneDisplayTextDisabled", true )

		RegisterSignal( "Control_PlayerRespawning" )
		RegisterSignal( "Control_NewEXPLeaderFound" )
		RegisterSignal( "PlayerExitedHovertankVolume" )

		#if DEV
			RegisterSignal( "Control_Dev_PlayerReachedSpawnSelect" )
		#endif // DEV

		Survival_AddCallback_OnAirdropLaunched( Control_OnAirdropLaunched )
		Survival_AddCallback_OnAirdropLanded( Control_OnAirdropLanded )
		Survival_AddCallback_OnAirdropOpened( Control_OnAirdropOpened )

		if ( Control_GetIsMRBTimedEventEnabled() )
		{
			AddSpawnCallback( "prop_script", Control_MRBEntity_Spawned )
			AddSpawnCallback( "prop_survival", Control_MRBSurvivalItem_Spawned )
			RegisterSignal( "Control_MRB_Spawned" )
			RegisterSignal( "Control_MRB_Dropped" )
			RegisterSignal( "Control_MRB_PickedUp" )
			RegisterSignal( "Control_MRB_CalledIn" )
			RegisterSignal( "Control_MRB_Deployed" )
			Survival_AddCallback_OnRespawnDropshipCreated( Control_RespawnDropshipCreated )
			Survival_AddCallback_OnPlayerPutInDropship( Control_OnPlayerPutInDropship )
			Loot_AddCallback_OnPlayerLootPickup( Control_OnPlayerLootPickup )
			RespawnBeacon_AddCallback_OnMobileRespawnBeaconDeployTriggered( Control_MRBTimedEvent_OnMRBDeployTriggered )
		}
	#endif // SERVER


		#if SERVER
			MatchBehaviorPlayer_AddEndedCallback( Control_OnMatchBehaviorEnd )
		#endif // #if SERVER


	#if CLIENT
		Control_ScoreboardSetup()

		SetCustomScreenFadeAsset( $"ui/screen_fade_control.rpak" )
		ClApexScreens_SetCustomApexScreenBGAsset( $"rui/rui_screens/banner_c_control" )
		ClApexScreens_SetCustomLogoImage( $"rui/hud/gametype_icons/control/control_logo" )
		ClApexScreens_SetCustomLogoSize( <400, 400, 0> )

		PakHandle pakHandle = RequestPakFile( "control_mode" )
		PrecacheParticleSystem( CONTROL_WAYPOINT_FLARE_ASSET )
		PrecacheParticleSystem( FX_WEAPON_EVO_UPGRADE_FP )
		PrecacheParticleSystem( FX_EXP_LEVELUP_3P )

		SetDeathCamSpectateTimeOverride( Control_GetMinDeathScreenTime )

		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, Control_WaypointCreated_Spawn )
		SURVIVAL_SetGameStateAssetOverrideCallback( ControlOverrideGameState )
		Waypoints_RegisterCustomType( WAYPOINT_CONTROL_AIRDROP, InstanceWPControlAirdrop )
		Waypoints_RegisterCustomType( WAYPOINT_CONTROL_PLAYERLOC, InstanceWPControlPlayerLoc )

		if ( Control_ShouldShow2DMapIcons() )
		{
			RegisterMinimapPackages()
		}

		AddCallback_GameStateEnter( eGameState.Playing, Control_OnGamestateEnterPlaying_Client )
		AddCallback_GameStateEnter( eGameState.Prematch, Control_OnGamestateEnterPreMatch_Client )
		AddCallback_GameStateEnter( eGameState.WinnerDetermined, Control_OnGamestateEnterWinnerDetermined_Client )
		ClGameState_SetResolutionCleanupFunc( Control_OnGamestateEnterResolution_Client )
		AddCallback_OnCharacterSelectMenuClosed( Control_OnCharacterSelectMenuClosed )

		//for updating player data on scoreboard
		Fullmap_AddCallback_OnFullmapCreated( Control_OnFullmapCreated )
		AddCallback_OnScoreboardCreated( Control_OnScoreboardCreated )
		AddCreateCallback( "player", Control_OnPlayerCreated )
		AddCallback_OnPlayerChangedTeam( Control_OnPlayerTeamChanged_Client )
		AddCallback_PlayerClassChanged( Control_OnPlayerClassChanged )
		AddOnSpectatorTargetChangedCallback( Control_OnSpectatorTargetChanged )
		AddCallback_OnViewPlayerChanged( Control_OnViewPlayerChanged )
		AddCallback_OnPlayerDisconnected( Control_OnPlayerDisconnected )

		AddCreateCallback( "prop_script", OnVehicleBaseSpawned )
		CaptureObjectivePing_AddCallback_SetIsCaptureObjectivePingCommsActionFunction( Control_IsControlObjectiveCommsAction )
		CaptureObjectivePing_AddCallback_SetGetObjectivesArrayFunction( Control_GetObjectiveWaypointsArray )

		CircleAnnouncementsEnable( false )
		CircleBannerAnnouncementsEnable( false )
		DeathScreen_SetSkipDeathRecapAnimation( true )

		RegisterDisabledBattleChatterEvents( CONTROL_DISABLED_BATTLE_CHATTER_EVENTS )
		RunUIScript( "Control_Respawn_SetKillerInfo" ) // Clear old killer info
		SetMapFeatureItem( 400, "#CONTROL_EMPTY_OBJ", "#CONTROL_EMPTY_OBJ_DESC", CONTROL_OBJ_DIAMOND_EMPTY )
		SetMapFeatureItem( 500, "#CONTROL_YOUR_OBJ", "#CONTROL_YOUR_OBJ_DESC", CONTROL_OBJ_DIAMOND_YOURS )
		SetMapFeatureItem( 300, "#CONTROL_ENEMY_OBJ", "#CONTROL_ENEMY_OBJ_DESC", CONTROL_OBJ_DIAMOND_ENEMY )

		RegisterSignal( "Control_PlayerHasChosenRespawn" )
		RegisterSignal( "Control_RequestOpenSpawnMenuOnUI" )
		RegisterSignal( "Control_PlayerStartingRespawnSelection" )
		RegisterSignal( "Control_NewCameraDataReceived" )
		RegisterSignal( "Control_PlayerHideScoreboardMap" )
		RegisterSignal( "OnValidSpawnPointThreadStarted" )
		RegisterSignal( "OnSpawnMenuClosed" )
		RegisterSignal( "Control_OnObjectiveStateChanged_Client" )
		RegisterSignal( "EndUpdateAllianceUIScoreGameState" )
		RegisterSignal( "EndUpdateAllianceUIScoreMap" )
		RegisterSignal( "Control_StopWeaponEvoHints" )


		if ( Control_GetIsMRBTimedEventEnabled() )
			Waypoints_RegisterCustomType( WAYPOINT_CONTROL_MRB, InstanceWPControlMRB)
	#endif // CLIENT

	Control_RegisterNetworking()
}

#if CLIENT || SERVER
void function EntitiesDidLoad()
{
	#if SERVER
		//DELETE THE CONTROL PROPS AFTER ALL ENTITIES HAVE LOADED - SHAWBS
		Control_CheckFuncGeo()
	#endif //SERVER

	#if CLIENT
		if( GameMode_IsActive( eGameModes.CONTROL ) )
		{
			//DESTROY CLIENT SIDE JUMP TOWER FLAGS IF CONTROL IS ENABLED - SHAWBS
			array<entity> jumpTowerFlags = GetEntArrayByScriptName( "jump_tower_flag" )
			foreach( flag in jumpTowerFlags )
				flag.Destroy()
		}
	#endif //CLIENT


		if( GameMode_IsActive( eGameModes.CONTROL ) )
			Control_UpdateCrowdNoiseMeter() // needs to be after entities load as it accesses gameState netvar

}
#endif // CLIENT || SERVER


void function Control_RegisterNetworking()
{







	RegisterNetworkedVariableSafe( "control_WaveStartTime", SNDC_GLOBAL, SNVT_TIME, 0.0 )
	RegisterNetworkedVariableSafe( "control_WaveSpawnTime", SNDC_GLOBAL, SNVT_TIME, 0.0 )
	RegisterNetworkedVariableSafe( "control_IsPlayerOnSpawnSelectScreen", SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, false )
	RegisterNetworkedVariableSafe( "control_IsPlayerExemptFromWaveSpawn", SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, false )
	RegisterNetworkedVariableSafe( "control_ObjectiveIndex", SNDC_PLAYER_EXCLUSIVE, SNVT_INT, -1)
	RegisterNetworkedVariableSafe( "control_PersonalScore", SNDC_PLAYER_GLOBAL, SNVT_BIG_INT, 0 )
	RegisterNetworkedVariableSafe( "control_CurrentExpTotal", SNDC_PLAYER_EXCLUSIVE, SNVT_BIG_INT, 0 )
	RegisterNetworkedVariableSafe( "control_CurrentExpTier", SNDC_PLAYER_EXCLUSIVE, SNVT_INT, 0 )

	Remote_RegisterServerFunction( "ClientCallback_Control_ProcessRespawnChoice", "int", 0, eControlWaypointTypeIndex._count )
	Remote_RegisterServerFunction( "ClientCallback_Control_PlayerRespawningFromMenu" )

	Remote_RegisterClientFunction( "ServerCallback_Control_ShowSpawnSelection" )
	Remote_RegisterClientFunction( "ServerCallback_Control_ProcessImmediatelyOpenCharacterSelect" )
	Remote_RegisterClientFunction( "ServerCallback_Control_UpdateSpawnWaveTimerTime" )
	Remote_RegisterClientFunction( "ServerCallback_Control_UpdateSpawnWaveTimerVisibility", "bool" )
	Remote_RegisterClientFunction( "ServerCallback_Control_DeregisterModeButtonPressedCallbacks" )
	Remote_RegisterClientFunction( "ServerCallback_Control_SetDeathScreenCallbacks" )
	Remote_RegisterClientFunction( "ServerCallback_Control_NoVehiclesAvailable" )
	Remote_RegisterClientFunction( "ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo", "bool", "bool" )
	Remote_RegisterClientFunction( "ServerCallback_Control_ProcessObjectiveStateChange", "entity", "int", -1, 2, "int", ALLIANCE_NONE, 2, "int", ALLIANCE_NONE, 2, "int", ALLIANCE_NONE, 2, "int",ALLIANCE_NONE, 2, "bool" )
	Remote_RegisterClientFunction( "ServerCallback_Control_DisplayIconAtPosition", "vector", -1.0, 1.0, 32, "int", 0, eControlIconIndex._count, "int", INT_MIN, INT_MAX, "float", 0.0, FLT_MAX, 32 )
	Remote_RegisterClientFunction( "ServerCallback_Control_BountyActiveAlert", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_Control_BountyClaimedAlert", "entity", "int", INT_MIN, INT_MAX, "int",ALLIANCE_NONE, 2  )
	Remote_RegisterClientFunction( "ServerCallback_Control_AirdropNotification" )
	Remote_RegisterClientFunction( "ServerCallback_Control_UpdateExtraScoreBoardInfo", "int", 0, 2, "int", INT_MIN, INT_MAX, "int", INT_MIN, INT_MAX )
	Remote_RegisterClientFunction( "ServerCallback_Control_SetIsPlayerUsingLosingExpTiers", "bool" )
	Remote_RegisterClientFunction( "ServerCallback_Control_DisplaySpawnAlertMessage", "int", 0, eControlSpawnAlertCode._count )
	Remote_RegisterClientFunction( "ServerCallback_Control_DisplayWaveSpawnBarStatusMessage", "bool", "int", 0, eControlWaypointTypeIndex._count )
	Remote_RegisterClientFunction( "ServerCallback_Control_TransferCameraData", "vector", -FLT_MAX, FLT_MAX, 32, "vector", -FLT_MAX, FLT_MAX, 32 )
	Remote_RegisterClientFunction( "ServerCallback_Control_SetControlGeoValidForAirdropsOnClient", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_Control_PlayAllWeaponEvoUpgradeFX", "entity", "int", 0, CONTROL_MAX_EXP_TIER + 1, "bool" )
	Remote_RegisterClientFunction( "ServerCallback_Control_Play3PEXPLevelUpFX", "entity", "int", 0, CONTROL_MAX_EXP_TIER + 1 )
	Remote_RegisterClientFunction( "ServerCallback_Control_PlayCaptureZoneEnterExitSFX", "bool" )
	Remote_RegisterClientFunction( "ServerCallback_Control_NewEXPLeader", "entity", "int", INT_MIN, INT_MAX )
	Remote_RegisterClientFunction( "ServerCallback_Control_EXPLeaderKilled", "entity", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_PlayMatchEndMusic_Control", "int", 0, eWinReason._count )
	Remote_RegisterClientFunction( "ServerCallback_PlayPodiumMusic" )
	Remote_RegisterClientFunction( "ServerCallback_Control_DisplayLockoutUnavailableWarning" )

	RegisterNetworkedVariableSafe( PLAYER_WITH_MRB_NET_NAME, SNDC_GLOBAL, SNVT_ENTITY )
	Remote_RegisterClientFunction( "ServerCallback_Control_MRBTimedEvent_OnMRBPickedUp" )

	Remote_RegisterUIFunction( "Control_RemoveAllButtonSpawnIcons" )
	Remote_RegisterUIFunction( "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", "bool" )

	if ( IsUsingLoadoutSelectionSystem() )
	{
		Remote_RegisterUIFunction( "ControlSpawnMenu_UpdatePlayerLoadout" )
		Remote_RegisterUIFunction( "UI_OpenControlSpawnMenu", "bool", "int", INT_MIN, INT_MAX )
	}

	#if CLIENT
		RegisterNetVarBoolChangeCallback( "control_IsPlayerOnSpawnSelectScreen", ServerCallback_Control_OnPlayerChoosingRespawnChoiceChanged )
		RegisterNetVarIntChangeCallback ( "control_CurrentExpTotal", Control_UpdatePlayerExpHUD )
	#endif // CLIENT
}

#if SERVER || CLIENT
bool function Control_ShouldShow2DMapIcons()
{
	// We currently don't use 2D maps in control so this should be false, but we may switch back in the future
	return !MiniMapIsDisabled() && !GameMode_IsActive( eGameModes.CONTROL )
}
#endif // SERVER || CLIENT

float function Control_GetDefaultExpPercentToAwardForPointSpawn()
{
	return GetCurrentPlaylistVarFloat( "exp_percent_award_spawn_on_point", -1 )
}

float function Control_GetDefaultExpPercentToAwardForBaseSpawn()
{
	return GetCurrentPlaylistVarFloat( "exp_percent_award_spawn_on_base", 1 )
}

bool function Control_ShouldUseRecoveredExpPercentIfGreaterThanDefaults()
{
	return GetCurrentPlaylistVarBool( "exp_recover_exp_percent_if_greater_than_default", true )
}

bool function Control_GetIsMRBTimedEventEnabled()
{
	return GetCurrentPlaylistVarBool( "control_enable_mrb_event", true )
}








bool function Control_IsSpawningOnObjectiveBAllowed()
{
	return GetCurrentPlaylistVarBool( "control_is_b_point_spawn_allowed", true )
}

#if SERVER
bool function Control_GetShouldDropLootOnDeath()
{
	return GetCurrentPlaylistVarBool( "control_drop_loot_on_death", false )
}
#endif // SERVER

#if SERVER
bool function Control_GetIsAmmoInfinite()
{
	return GetCurrentPlaylistVarBool( "control_infinite_ammo", false )
}
#endif // SERVER

#if SERVER
bool function Control_GetIsFastHeal()
{
	return GetCurrentPlaylistVarBool( "control_fast_heal", false )
}
#endif // SERVER

#if SERVER
// Should players be awarded their full ult back on respawn if they earned one then died without using it?
bool function Control_GetShouldRestoreFullUltOnRespawn()
{
	return GetCurrentPlaylistVarBool( "control_should_restore_ult_on_respawn", false )
}
#endif // SERVER

#if SERVER
int function Control_GetAirdropCountPerGroup()
{
	return GetCurrentPlaylistVarInt( "control_airdrop_group_count", 1 )
}
#endif // SERVER

#if SERVER
int function Control_GetMaxUnOpenedAirdrops()
{
	return GetCurrentPlaylistVarInt( "control_airdrop_max_count_inworld", 10 )
}
#endif // SERVER

#if SERVER
int function Control_GetDroppedAmmoOnDeathCount_Primary()
{
	return GetCurrentPlaylistVarInt( "ammobrick_ondeath_spawncount", 2 )
}
#endif // SERVER

#if SERVER
int function Control_GetDroppedAmmoOnDeathCount_Random()
{
	return GetCurrentPlaylistVarInt( "random_ammobrick_ondeath_spawncount", 2 )
}
#endif // SERVER

#if SERVER
int function Control_GetDefaultEXPLeaderEXPThreshold()
{
	return GetCurrentPlaylistVarInt( "control_default_expleader_exp_threshold", 700 )
}
#endif // SERVER

#if SERVER
int function Control_GetEXPLeaderEXPThreshold()
{
	if ( file.expLeaderExpThreshold >= Control_GetDefaultEXPLeaderEXPThreshold() )
		return file.expLeaderExpThreshold

	return Control_GetDefaultEXPLeaderEXPThreshold()
}
#endif // SERVER

#if SERVER
float function Control_GetMaxDistFromSquadForOnSquadMultiplier()
{
	return GetCurrentPlaylistVarFloat( "max_dist_from_squad_for_onsquad_multiplier", 2952.75 )
}
#endif // SERVER

#if SERVER
float function Control_GetTimeToCaptureObjective()
{
	return GetCurrentPlaylistVarFloat( "control_objective_capture_time", 20 )
}
#endif // SERVER

#if SERVER
string function Control_GetWeaponLoadoutString()
{
	return GetCurrentPlaylistVarString( "control_default_weapon_loadout", CONTROL_DEFAULT_WEAPON_LOADOUT )
}
#endif // SERVER

#if SERVER
string function Control_GetConsumableLoadoutString()
{
	return GetCurrentPlaylistVarString( "control_default_consumables_loadout", CONTROL_DEFAULT_CONSUMABLES_LOADOUT )
}
#endif // SERVER

#if SERVER
string function Control_GetEquipmentLoadoutString()
{
	return GetCurrentPlaylistVarString( "control_default_equipment_loadout", CONTROL_DEFAULT_EQUIPMENT_LOADOUT )
}
#endif // SERVER

#if SERVER
bool function Control_GetShouldSkydiveRespawn()
{
	return GetCurrentPlaylistVarBool( "control_should_skydive_respawn", false )
}
#endif // SERVER

#if SERVER
bool function Control_GetSpawnWaveEnabled()
{
	return GetCurrentPlaylistVarBool( "control_spawn_wave_enabled", true )
}
#endif // SERVER

// Functions to get variables that are defined in playlist vars
#if CLIENT || SERVER
bool function Control_GetAreAirdropsEnabled()
{
	return GetCurrentPlaylistVarBool( "control_enable_airdrops", true )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
bool function Control_GetAreBonusCaptureTimedEventsEnabled()
{
	return GetCurrentPlaylistVarBool( "control_enable_bonus_capture_events", true )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
bool function Control_GetIsLockoutEnabled()
{
	return GetCurrentPlaylistVarBool( "control_enable_lockout", true )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
bool function Control_GetIsLockoutInstantWin()
{
	return GetCurrentPlaylistVarBool( "control_end_game_on_lockout_start", false )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
bool function Control_GetIsWeaponEvoEnabled()
{
	return GetCurrentPlaylistVarBool( "control_has_evolving_equipment", false )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Do the minimum held objectives rules for generating score only affect the winning team?
bool function Control_GetIsMinHeldObjectivesOnlyForWinningTeam()
{
	return GetCurrentPlaylistVarBool( "control_is_min_objectives_rule_winners_only", false )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Do we trigger catchup mechanics for a team if they have less players than the other team
bool function Control_ShouldTriggerCatchupMechanicsForTeamInBalance()
{
	return GetCurrentPlaylistVarBool( "control_team_inbalance_trigger_catchup", false )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Do we allow the team that has catchup mechanics triggered for them skip the spawn wave
bool function Control_ShouldSkipSpawnWaveForCatchupMechanic()
{
	return GetCurrentPlaylistVarBool( "control_use_spawn_wave_skip_for_catchup", false )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Should weapon evo occur on weapon reload, ignoring combat checks?
bool function Control_GetShouldEvoWeaponsOnWeaponSwitch()
{
	return GetCurrentPlaylistVarBool( "weapon_evo_on_weaponswitch", false )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
int function Control_GetDefaultEquipmentTier()
{
	return GetCurrentPlaylistVarInt( "control_default_equipment_tier", 1 )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
int function Control_GetDefaultWeaponTier()
{
	return GetCurrentPlaylistVarInt( "control_default_weapon_tier", 1 )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// If 0 or 1 game plays the same as release ( you gain score for any held objectives).
// If 2 or higher a team only gains score if they hold the majority of objectives
int function Control_GetMinHeldObjectivesToGenerateScore()
{
	int minHeldObjectives = GetCurrentPlaylistVarInt( "control_min_held_zones_to_score", 0 )

	#if SERVER
		int controlPoints = file.chosenVariantData.controlPoints.len()
		Assert( minHeldObjectives <= controlPoints, "CONTROL: The required number of held zones is set to be higher than the number of available zones" )
	#endif // SERVER

	return minHeldObjectives
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// What is the point difference between the losing team and the winning team before we start giving special mechanics like reduced EXP Tier cost
int function Control_GetPointDiffForCatchupMechanics()
{
	return GetCurrentPlaylistVarInt( "control_point_diff_to_be_losingteam", 0 )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
float function Control_GetMinDeathScreenTime()
{
	return GetCurrentPlaylistVarFloat( "control_min_deathscreen_time", 4.0 )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
float function Control_GetMaxDeathScreenTime()
{
	return GetCurrentPlaylistVarFloat( "control_max_deathscreen_time", 20.0 )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
const float MIN_MRB_LIFETIME = 20.0
float function Control_GetMRBSpawnLifetime()
{
	float mrbLifetime = GetCurrentPlaylistVarFloat("control_mrb_event_spawn_lifetime", CONTROL_DEFAULT_MRB_LIFETIME )
	// Some logic is based around the signal that comes in when the MRB is called in. However, after that signal comes in it still takes time for the MRB to land and be tracked properly
	// Ensure the lifetime is long enough to avoid issues
	Assert( mrbLifetime >= MIN_MRB_LIFETIME, "Control MRB lifetime is set to be shorter than the min lifetime of " + MIN_MRB_LIFETIME )

	return mrbLifetime
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
float function Control_GetMRBAirdropDelay()
{
	return GetCurrentPlaylistVarFloat("control_mrb_event_airdrop_delay", CONTROL_DEFAULT_MRB_AIRDROP_DELAY )
}
#endif // CLIENT || SERVER

#if UI
// Populate the About screen with tabs, text, and images related to Control
array< featureTutorialTab > function Control_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	string playlistUiRules = GetPlaylist_UIRules()

	if ( playlistUiRules != GAMEMODE_CONTROL )
		return tabs

	featureTutorialTab tab1
	featureTutorialTab tab2
	featureTutorialTab tab3
	featureTutorialTab tab4

	array< featureTutorialData > tab1Rules
	array< featureTutorialData > tab2Rules
	array< featureTutorialData > tab3Rules
	array< featureTutorialData > tab4Rules

	int withSquadBonusEXPVal = GetCurrentPlaylistVarInt( "exp_value_playing_with_squad", 5 )

	// Tab 1 contains surface overview of the mode
	tab1.tabName = "#GAMEMODE_RULES_OVERVIEW_TAB_NAME"
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_CAPTURING_HEADER", "#CONTROL_RULES_CAPTURING_BODY", $"rui/hud/gametype_icons/control/about_capture" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_RATINGS_HEADER", "#CONTROL_RULES_RATINGS_BODY", $"rui/hud/gametype_icons/control/about_ratings" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_TIMEDEVENT_HEADER", "#CONTROL_RULES_TIMEDEVENT_BODY", $"rui/hud/gametype_icons/control/about_events" ) )

	// Tab 2 contains breakdown of EXP rewards
	tab2.tabName = "#CONTROL_RULES_RATINGS_TAB_NAME"
	string killRatingsBody = Localize( "#CONTROL_RULES_KILL_RATINGS_BODY", string( GetCurrentPlaylistVarInt( "exp_value_kill", 20 ) ), string( GetCurrentPlaylistVarInt( "exp_value_kill_assist", 20 ) ), string( GetCurrentPlaylistVarInt( "exp_value_mrb_deployed", 50 ) ), string( withSquadBonusEXPVal ) )
	string specialKillRatingsBody = Localize( "#CONTROL_RULES_SPECIAL_KILL_RATINGS_BODY", string( GetCurrentPlaylistVarInt( "exp_value_kill_attacker", 15 ) ), string( GetCurrentPlaylistVarInt( "exp_value_kill_defender", 15 ) ), string( GetCurrentPlaylistVarInt( "exp_value_kill_high_tier", 15 ) ), string( GetCurrentPlaylistVarInt( "exp_value_kill_reallyhigh_tier", 25 ) ), string( GetCurrentPlaylistVarInt( "exp_value_kill_expleader", 50 ) ) )
	string objectiveRatingsBody = Localize( "#CONTROL_RULES_OBJECTIVE_RATINGS_BODY", string( GetCurrentPlaylistVarInt( "exp_value_capturing", 5 ) ), string( GetCurrentPlaylistVarInt( "exp_value_contesting", 10 ) ), string( GetCurrentPlaylistVarInt( "exp_value_defending_active", 10 ) ), string( GetCurrentPlaylistVarInt( "exp_value_neutralize", 50 ) ), string( GetCurrentPlaylistVarInt( "exp_value_capture", 50 ) ), string( withSquadBonusEXPVal ) )
	string teamRatingsBody = Localize( "#CONTROL_RULES_TEAM_RATINGS_BODY", string( GetCurrentPlaylistVarInt( "exp_value_team_neutralize", 25 ) ), string( GetCurrentPlaylistVarInt( "exp_value_team_capture", 25 ) ), string( CONTROL_TEAMSCORE_LOCKOUTBROKEN ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_KILL_RATINGS_HEADER", killRatingsBody, $"rui/hud/gametype_icons/control/about_kill_ratings" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_SPECIAL_KILL_RATINGS_HEADER", specialKillRatingsBody, $"rui/hud/gametype_icons/control/about_special_kill_ratings" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_OBJECTIVE_RATINGS_HEADER", objectiveRatingsBody, $"rui/hud/gametype_icons/control/about_objective_ratings" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_TEAM_RATINGS_HEADER", teamRatingsBody, $"rui/hud/gametype_icons/control/about_team_ratings" ) )

	// Tab 3 contains spawn system info
	tab3.tabName = "#CONTROL_RULES_SPAWNING_TAB_NAME"
	string baseSpawnBody = Localize( "#CONTROL_RULES_BASE_SPAWN_BODY", string( Control_GetDefaultExpPercentToAwardForBaseSpawn() * 100 ) )
	tab3Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_BASE_SPAWN_HEADER", baseSpawnBody, $"rui/hud/gametype_icons/control/about_base_spawns" ) )
	tab3Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_FORWARDBASE_SPAWN_HEADER", "#CONTROL_RULES_FORWARDBASE_SPAWN_BODY", $"rui/hud/gametype_icons/control/about_forwardbase_spawns" ) )
	tab3Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#CONTROL_RULES_CENTRAL_SPAWN_HEADER", "#CONTROL_RULES_CENTRAL_SPAWN_BODY", $"rui/hud/gametype_icons/control/about_central_spawns" ) )

	tab1.rules = tab1Rules
	tab2.rules = tab2Rules
	tab3.rules = tab3Rules
	tab4.rules = tab4Rules

	tabs.append( tab1 )
	tabs.append( tab2 )
	tabs.append( tab3 )







		tabs.append( tab4 )


	GameMode_AboutDialog_AppendRequeueTab(tabs)

	return tabs
}
#endif // UI

//TODO DSwieczko: Investigate Breaking out Map Init logic into separate file ( this was for Mark, he is gone, for me now?)
/*
  __  __              _____      _____   _   _   _____   _______   _____              _        _____   ______             _______   _____    ____    _   _
 |  \/  |     /\     |  __ \    |_   _| | \ | | |_   _| |__   __| |_   _|     /\     | |      |_   _| |___  /     /\     |__   __| |_   _|  / __ \  | \ | |
 | \  / |    /  \    | |__) |     | |   |  \| |   | |      | |      | |      /  \    | |        | |      / /     /  \       | |      | |   | |  | | |  \| |
 | |\/| |   / /\ \   |  ___/      | |   | . ` |   | |      | |      | |     / /\ \   | |        | |     / /     / /\ \      | |      | |   | |  | | | . ` |
 | |  | |  / ____ \  | |         _| |_  | |\  |  _| |_     | |     _| |_   / ____ \  | |____   _| |_   / /__   / ____ \     | |     _| |_  | |__| | | |\  |
 |_|  |_| /_/    \_\ |_|        |_____| |_| \_| |_____|    |_|    |_____| /_/    \_\ |______| |_____| /_____| /_/    \_\    |_|    |_____|  \____/  |_| \_|

                                                                                              launch                                                             */
#if SERVER
void function Control_OnMapDataCreated( entity mapData )
{
	ControlMapVariantData data
	data.mapCenter = mapData.GetOrigin()
	if ( mapData.HasKey( "map_radius" ) )
		data.mapRadius = float(mapData.kv.map_radius)
	if ( mapData.HasKey( "map_id" ) )
		data.mapID = string(mapData.kv.map_id)
	if ( mapData.HasKey( "map_name_loc" ) )
		data.nameString = string(mapData.kv.map_name_loc)

	printt( "CONTROL: Creating map data for map variant: ", data.mapID, " with radius ", data.mapRadius )

	file.mapVariants.append( data )
}
#endif // SERVER

#if SERVER
entity function Control_GetParentMapNode_Internal( entity child, string objectTypeName, bool checkParentIsCurrentMapNode )
{
	//first, look for parent Map Data
	array< entity > parentMapVariants = child.GetLinkParentArray()
	if ( parentMapVariants.len() == 0 )
	{
		Warning( "CONTROL: Found orphaned ", objectTypeName, " at ", child.GetOrigin(), " - Link a map variant to this objective" )
		return null
	}

	entity retVal = null
	foreach ( parentMapVariant in parentMapVariants )
	{
		if ( GetEditorClass( parentMapVariant ) == "info_control_map_data"  )
		{
			if( checkParentIsCurrentMapNode )
			{
				Assert( parentMapVariant.HasKey( "map_id" ), "CONTROL: Found info_control_map_data without map_id. entity: " + parentMapVariant + " child: " + child )
				if( parentMapVariant.kv.map_id == file.chosenVariantData.mapID )
					retVal = parentMapVariant
			}
			else
			{
				retVal = parentMapVariant
			}
		}
		else
		{
			Warning( "CONTROL: Found ", objectTypeName," at ", child.GetOrigin(), " with an incoming link that does not come from an info_control_map_data entity" )
		}
	}

	return retVal
}
#endif // SERVER

#if SERVER
// will return any parent map node, if has multiple it'll be random
entity function Control_GetParentMapNode( entity child, string objectTypeName )
{
	return Control_GetParentMapNode_Internal( child, objectTypeName, false )
}
#endif // SERVER

#if SERVER
bool function Control_IsChildOfCurrentMapNode( entity child, string objectTypeName )
{
	entity mapNode = Control_GetParentMapNode_Internal( child, objectTypeName, true )
	return mapNode != null
}
#endif // SERVER

#if SERVER
void function Control_OnEditorObjectiveCreated( entity objective )
{
	entity parentMapVariant = Control_GetParentMapNode( objective, "objective" )
	if( parentMapVariant == null )
		return

	string parentMapVariantName = string(parentMapVariant.kv.map_id)

	ControlPointData data
	data.trigger = objective
	data.location = objective.GetOrigin()
	data.parentMapVariant = parentMapVariantName

	array<entity> linkedEnts = objective.GetLinkEntArray()
	foreach( ent in linkedEnts )
	{
		if ( GetEditorClass( ent ) == "control_flag_prop" )
			data.flagProp = ent
	}

	printt( "CONTROL: Creating objective data for objective ", data.name, " in map variant ", data.parentMapVariant )

	file.controlPoints.append( data )
}
#endif // SERVER

#if SERVER
void function Control_OnEditorSpawnAreaCreated( entity spawnArea )
{
	entity parentMapVariant = Control_GetParentMapNode( spawnArea, "team spawn area" )
	if( parentMapVariant == null )
		return
	string parentMapVariantName = string(parentMapVariant.kv.map_id)

	printt( "CONTROL: created spawn area at ", spawnArea.GetOrigin(), " with parent map variant ", parentMapVariantName )

	file.teamSpawnAreas.append( spawnArea )
}
#endif // SERVER

#if SERVER
void function Control_OnSpawnPointCreated( entity spawn )
{
	//first, look for parent entity, if it's null, it's unrelated to Control
	array< entity > parentEnts = spawn.GetLinkParentArray()
	if ( parentEnts.len() == 0 )
		return

	//look for parent with control in editor class
	foreach( parentEnt in parentEnts )
	{
		if ( GetEditorClass( parentEnt ).find( GAMEMODE_CONTROL ) != -1 )
		{
			file.controlSpawns.append( spawn )
			return
		}
	}
}
#endif // SERVER

#if SERVER
void function Control_OnEditorSpawnCameraCreated( entity spawnScreenCamera )
{
	entity parentMapVariant = Control_GetParentMapNode( spawnScreenCamera, "spawn camera" )
	if( parentMapVariant == null )
		return

	file.spawnScreenCameras.append( spawnScreenCamera )
}
#endif // SERVER

#if SERVER
void function Control_OnEditorVehicleSummonCreated( entity summonPlatform )
{
	entity parentMapVariant = Control_GetParentMapNode( summonPlatform, "summonPlatform" )
	if( parentMapVariant == null )
		return

	string parentMapVariantName = string(parentMapVariant.kv.map_id)

	printt( "CONTROL: created summon platform at ", summonPlatform.GetOrigin(), " with parent map variant ", parentMapVariantName )

	file.vehicleSummonPlatforms.append( summonPlatform )
}
#endif // SERVER

#if SERVER
void function Control_OnEditorFuncGeoCreated( entity funcBrush )
{
	//ADD FUNC BRUSH TO ARRAY FOR LATER CHECKFUNCGEO() ON ENTITIES DID LOAD
	if( funcBrush.GetScriptName() == CONTROL_FUNC_BRUSH_GEO_NAME )
	{
		#if DEV
			printt("CONTROL: ADDING FUNC BRUSH TO ARRAY")
		#endif // DEV

		file.controlFuncGeo.append( funcBrush )
	}
}
#endif // SERVER

#if SERVER
void function Control_CheckFuncGeo() //SHAWBS
{
	//Iterate through all the func brushes inside the FuncGeo array.
	if( file.controlFuncGeo.len() > 0 )
	{
		for( int i = 0; i< file.controlFuncGeo.len(); i++ )
		{
			entity funcBrush = file.controlFuncGeo[i]

			if( GameMode_IsActive( eGameModes.CONTROL ) )
			{
				//Make all func brushes geo mantlable
				funcBrush.AllowMantle()

				// Determine if the func brush should allow airdrops
				if ( CONTROL_ARE_AIRDROPS_ALLOWED_ON_CONTROL_GEO )
				{
					// Make func brushes allow airdrops
					AddToAllowedAirdropDynamicEntities( funcBrush )
				}
			}
			else
			{
				#if DEV
					printt( "CONTROL: destroying func brush at ", funcBrush.GetOrigin() )
				#endif // DEV

				funcBrush.Destroy()
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Add func brushes to the allowed airdrop list on the Client when a player joins so the Client is synced with the Server regarding what func brush entities allow airdrops
void function Control_SetFuncGeoToAllowedAirdropEntitiesForPlayer( entity player )
{
	if ( !IsValid( player ) )
		return

	//Iterate through all the func brushes inside the FuncGeo array.
	if ( file.controlFuncGeo.len() > 0 )
	{
		for ( int i = 0; i < file.controlFuncGeo.len(); i++ )
		{
			entity funcBrush = file.controlFuncGeo[i]

			if ( GameMode_IsActive( eGameModes.CONTROL ) )
			{
				// Determine if the func brush should allow airdrops or block them
				if ( CONTROL_ARE_AIRDROPS_ALLOWED_ON_CONTROL_GEO )
				{
					// Make func brush allow airdrops on the client
					Remote_CallFunction_NonReplay( player, "ServerCallback_Control_SetControlGeoValidForAirdropsOnClient", funcBrush )
				}
			}
		}
	}
}
#endif // SERVER

#if SERVER
void function Control_OnEditorControlWallCreated( entity wall )
{
	entity parentMapVariant = Control_GetParentMapNode( wall, "boundary wall" )
	if( parentMapVariant == null )
		return

	string parentMapVariantName = string(parentMapVariant.kv.map_id)

	#if DEV
		printt( "CONTROL: created boundary wall at ", wall.GetOrigin(), " with parent map variant ", parentMapVariantName )
	#endif // DEV

	wall.kv.contents = CONTENTS_SOLID | CONTENTS_NOGRAPPLE | CONTENTS_NOCLIMB
	file.controlBoundaryWalls.append( wall )
}
#endif // SERVER

#if SERVER
void function Control_OnEditorFlagPropCreated( entity prop )
{
	if( Control_GetParentMapNode( prop, "prop" ) == null )
		return

	prop.e.ignoreJumpPad = true
	prop.DisablePhysics()

	file.flagProps.append( prop )
}
#endif // SERVER

#if SERVER
void function Control_OnSpawnedSkydiveLauncherEditorClass( entity prop )
{
	if ( prop.GetScriptName() != CONTROL_SKYDIVELAUNCHER_SCRIPT_NAME )
		return

	array< entity > parentSpawns = prop.GetLinkParentArray()
	if ( parentSpawns.len() != 0 )
	{
		bool foundMapNodeParent = false
		foreach( parentSpawn in parentSpawns )
		{
			if ( GetEditorClass( parentSpawn ) == "info_control_map_data" )
			{
				foundMapNodeParent = true
				break
			}
		}

		Assert( foundMapNodeParent, "CONTROL: Found launcher at " + prop.GetOrigin() + " with an incoming link that does not come from an info_control_map_data entity" )

		file.controlSkydiveLaunchers.append( prop )
	}
	else
	{
		//do nothing for orphaned skydive launchers if mode is active
	}

	// Don't allow airdrops in the locations of the launchers
	if ( IsValid( prop ) )
	{
		CreateNonExpiringAirdropBadPlace( prop.GetOrigin(), CONTROL_SKYDIVE_LAUNCHER_AIRDROP_BAD_PLACE_RADIUS )

		#if DEV
			if ( CONTROL_DISPLAY_DEBUG_DRAWS )
				DebugDrawSphere( prop.GetOrigin(), CONTROL_SKYDIVE_LAUNCHER_AIRDROP_BAD_PLACE_RADIUS, COLOR_RED, true, CONTROL_DEBUG_DRAW_DISPLAY_TIME )
		#endif // DEV
	}
}
#endif // SERVER

#if SERVER
// Destroy non Control Mode GunRacks
void function Control_OnEditorGunRackCreated( entity prop )
{
	if ( GameMode_IsActive( eGameModes.CONTROL ) )
	{
		prop.Destroy()
	}
}
#endif // SERVER

#if SERVER
void function Control_OnEditorControlGunRackCreated( entity prop )
{
	entity parentMapVariant = Control_GetParentMapNode( prop, "Control Gun Rack" )
	if( parentMapVariant == null )
		return

	string parentMapVariantName = string( parentMapVariant.kv.map_id )

	#if DEV
		printt( "CONTROL: created Control Gun Rack at ", prop.GetOrigin(), " with parent map variant ", parentMapVariantName )
	#endif // DEV

	file.controlGunRacks.append( prop )
}
#endif // SERVER

#if SERVER
void function Control_OnEditorControlGunRackPanelCreated( entity prop )
{
	if ( GetCurrentPlaylistVarBool( "control_enable_gunracks", false ) && !GetCurrentPlaylistVarBool( "control_gunracks_self_replenish", false ) && !GetCurrentPlaylistVarBool( "control_gunracks_reset_all_group_loot_on_pickup", false ) )
	{
		entity parentMapVariant = Control_GetParentMapNode( prop, "team spawn area" )
		if( parentMapVariant == null )
			return

		string parentMapVariantName = string( parentMapVariant.kv.map_id )

		#if DEV
			printt( "CONTROL: created Control Gun Rack Panel at ", prop.GetOrigin(), " with parent map variant ", parentMapVariantName )
		#endif // DEV

		file.controlGunRackPanels.append( prop )
	}
	else
	{
		prop.Destroy()
	}
}
#endif // SERVER

#if SERVER
void function OnEntitiesDidLoad_MapSetup()
{
	thread Control_MapSetup()
}
#endif // SERVER

#if SERVER
void function Control_MapSetup()
{
	// Use the first map variant available if we don't override from playlist vars
	int index = 0
	bool wasMapIDOverrideUsed = false
	string mapOverrideString = GetCurrentPlaylistVarString( "control_map_id_override", "" )

	// The playlist should override the map variant here
	if ( mapOverrideString != "" )
	{
		for( int i = 0; i< file.mapVariants.len(); i++ )
		{
			if ( file.mapVariants[i].mapID == mapOverrideString )
			{
				index = i
				wasMapIDOverrideUsed = true
				break
			}
		}
	}

	// If the variant wasn't set by the playlist vars, grab an error message so we can debug it
	if ( !wasMapIDOverrideUsed )
	{
		string mapOverrideErrorMessage = "CONTROL: Map Setup Error, requested map node: '" + mapOverrideString + "'.  Available map nodes: "
		for( int i = 0; i< file.mapVariants.len(); i++ )
		{
			if( i != 0 )
				mapOverrideErrorMessage += ", "

			mapOverrideErrorMessage += file.mapVariants[i].mapID
		}

		Assert( false, mapOverrideErrorMessage )
		PIN_GameError( mapOverrideErrorMessage, "custom" )
	}

	file.chosenVariantData = file.mapVariants[index]

	printt( "CONTROL: Done setting up Map Variant data, using index: ", index, " the variant name is: ", file.chosenVariantData.mapID, " The playlist override was: ", mapOverrideString )

	ParseSpawnAreaDataForChosenMap()
	ParseControlPointDataForChosenMap()
	ParsePropDataForChosenMap()
	ParseVehicleSummonPlatformsForChosenMap()
	ParseSkydiveLauncherDataForChosenMap()
	ParseGunRackDataForChosenMap()
	ParseGunRackPanelDataForChosenMap()

	//setup control points
	Control_SpawnAreaSetup()
	Control_ControlPointSetup()

	//parse attached spawn data after control points and spawn areas has been created
	ParseSpawnDataForChosenMap()

	ParseSpawnScreenCameraForChosenMap()

	FlagSet( "MapSetupComplete" )

	array < entity > connectedPlayersArray = GetConnectedPlayers()
	foreach( player in connectedPlayersArray )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_TransferCameraData", file.cameraLocation, file.cameraAngles )
	}
}
#endif // SERVER

#if SERVER
void function ParseControlPointDataForChosenMap()
{
	array<ControlPointData> dataCopy  = clone file.controlPoints
	for(int i = 0; i<file.controlPoints.len(); i++)
	{
		ControlPointData point = file.controlPoints[i]
		if ( point.parentMapVariant == file.chosenVariantData.mapID )
		{
			file.chosenVariantData.controlPoints.append( point )
		}
		else
		{
			//clear any attached props
			array<entity> objectiveChildren = point.trigger.GetLinkEntArray()
			foreach( child in objectiveChildren )
			{
				if ( file.flagProps.contains( child ) )
					file.flagProps.fastremovebyvalue( child )
				child.Destroy()
			}

			point.trigger.Destroy()
			dataCopy.fastremovebyvalue( point )
		}
	}
	file.controlPoints = dataCopy

	foreach ( controlPoint in file.controlPoints)
	{
		//Don't allow airdrops at control points
		vector boundingMins = controlPoint.trigger.GetBoundingMins()
		vector boundingMaxs = controlPoint.trigger.GetBoundingMaxs()
		int radius = int( Distance( boundingMaxs, boundingMins ) / 2 )
		CreateNonExpiringAirdropBadPlace( controlPoint.location, radius )

		#if DEV
			if ( CONTROL_DISPLAY_DEBUG_DRAWS )
				DebugDrawSphere( controlPoint.location, float( radius ), COLOR_RED, true, CONTROL_DEBUG_DRAW_DISPLAY_TIME )
		#endif // DEV
	}
}
#endif // SERVER

#if SERVER
void function ParseSpawnAreaDataForChosenMap()
{
	array<entity> areaCopy = clone file.teamSpawnAreas
	for( int i = 0; i<file.teamSpawnAreas.len(); i++ )
	{
		entity spawnArea = file.teamSpawnAreas[i]
		if( !Control_IsChildOfCurrentMapNode( spawnArea, "team spawn area" ) )
		{
			areaCopy.fastremovebyvalue( spawnArea )
		}
	}
	file.teamSpawnAreas = areaCopy
}
#endif // SERVER

#if SERVER
void function ParsePropDataForChosenMap()
{
	array<entity> propCopy = clone file.controlProps
	for( int i = 0; i<file.controlProps.len(); i++ )
	{
		entity prop = file.controlProps[i]
		if( !Control_IsChildOfCurrentMapNode( prop, "prop" ) )
		{
			propCopy.fastremovebyvalue( prop )
			prop.Destroy()
		}
	}
	file.controlProps = propCopy
}
#endif // SERVER

#if SERVER
void function ParseSpawnDataForChosenMap()
{
	foreach( spawn in file.controlSpawns )
	{
		entity parentEntity = spawn.GetLinkParent()
		if( !IsValid( parentEntity ) )
			continue

		if( Control_IsChildOfCurrentMapNode( parentEntity, "spawn" ) )
		{
			if ( GetEditorClass( parentEntity ) == "info_control_team_spawn_area" )
			{
				entity spawnTrigger
				foreach( linkedEnt in parentEntity.GetLinkEntArray() )
				{
					if ( linkedEnt.GetClassName() == "trigger_cylinder" )
					{
						spawnTrigger = linkedEnt
						break
					}
				}

				//spawn is a base spawn
				if ( spawnTrigger in file.chosenVariantData.triggerToSpawnDataMap[spawnTrigger].spawnTriggerToSpawns )
				{
					file.chosenVariantData.triggerToSpawnDataMap[spawnTrigger].spawnTriggerToSpawns[spawnTrigger].append( spawn )
				}
				else
				{
					array<entity> spawns
					spawns.append( spawn )
					file.chosenVariantData.triggerToSpawnDataMap[spawnTrigger].spawnTriggerToSpawns[spawnTrigger] <- spawns
				}
			}
			else if ( GetEditorClass( parentEntity ) == "trigger_control_objective" )
			{
				//spawn is an objective spawn
				file.chosenVariantData.triggerToControlPointMap[parentEntity].spawns.append( spawn )
			}
		}
	}
	RemoveAllOtherSpawnpoints( file.controlSpawns )
}
#endif // SERVER

#if SERVER
void function ParseSkydiveLauncherDataForChosenMap()
{
	array<entity> propCopy = clone file.controlSkydiveLaunchers
	for( int i = 0; i<file.controlSkydiveLaunchers.len(); i++ )
	{
		entity prop = file.controlSkydiveLaunchers[i]
		if( !Control_IsChildOfCurrentMapNode( prop, "skydive launcher" ) )
		{
			propCopy.fastremovebyvalue( prop )
			prop.Destroy()
		}
	}
	file.controlSkydiveLaunchers = propCopy
}
#endif // SERVER

#if SERVER
void function ParseBoundaryWallDataForChosenMap()
{
	array<entity> wallCopy = clone file.controlBoundaryWalls
	for( int i = 0; i<file.controlBoundaryWalls.len(); i++ )
	{
		entity wall = file.controlBoundaryWalls[i]
		if( !Control_IsChildOfCurrentMapNode( wall, "boundary wall" ) )
		{
			wallCopy.fastremovebyvalue( wall )
			wall.Destroy()
		}
	}
	file.controlBoundaryWalls = wallCopy
}
#endif // SERVER

#if SERVER
// Cleanup GunRacks if they are not meant for this map variant
void function ParseGunRackDataForChosenMap()
{
	array<entity> gunRacksCopy = clone file.controlGunRacks
	for( int i = 0; i<file.controlGunRacks.len(); i++ )
	{
		entity gunRack = file.controlGunRacks[i]
		if( !Control_IsChildOfCurrentMapNode( gunRack, "gunRack" ) )
		{
			gunRacksCopy.fastremovebyvalue( gunRack )
			gunRack.Destroy()
		}
	}
	file.controlGunRacks = gunRacksCopy
}
#endif // SERVER

#if SERVER
// Cleanup GunRack Panels if they are not meant for this map variant
void function ParseGunRackPanelDataForChosenMap()
{
	array<entity> gunRackPanelsCopy = clone file.controlGunRackPanels
	for( int i = 0; i<file.controlGunRackPanels.len(); i++ )
	{
		entity gunRackPanel = file.controlGunRackPanels[i]
		if( !Control_IsChildOfCurrentMapNode( gunRackPanel, "gunRackPanel" ) )
		{
			gunRackPanelsCopy.fastremovebyvalue( gunRackPanel )
			gunRackPanel.Destroy()
		}
	}
	file.controlGunRackPanels = gunRackPanelsCopy
}
#endif // SERVER

#if SERVER
void function ParseSpawnScreenCameraForChosenMap()
{
	array<entity> spawnScreenCamerasCopy = clone file.spawnScreenCameras
	for( int i = 0; i < file.spawnScreenCameras.len(); i++ )
	{
		entity spawnScreenCamera = file.spawnScreenCameras[i]
		if( !Control_IsChildOfCurrentMapNode( spawnScreenCamera, "spawnScreenCamera" ) )
		{
			spawnScreenCamerasCopy.fastremovebyvalue( spawnScreenCamera )
			spawnScreenCamera.Destroy()
		}
	}

	file.spawnScreenCameras = spawnScreenCamerasCopy

	if( file.spawnScreenCameras.len() > 1 )
		Warning( "CONTROL: %d spawn cameras found! Using first camera found", file.spawnScreenCameras.len() )

	if( file.spawnScreenCameras.len() == 0 )
	{
		CalculateSpawnScreenCamera()
	}
	else
	{
		file.cameraLocation = file.spawnScreenCameras[0].GetOrigin()
		file.cameraAngles   = file.spawnScreenCameras[0].GetAngles()
	}
}
#endif // SERVER

#if SERVER
void function CalculateSpawnScreenCamera()
{
	//cache camera information
	array<entity> spawnOptionList
	foreach( point in file.chosenVariantData.controlPoints )
		spawnOptionList.append( point.trigger )
	foreach( spawnData in file.chosenVariantData.teamSpawnData )
		spawnOptionList.extend( spawnData.spawnTriggers )

	vector center = GetAverageOriginOfEnts( spawnOptionList )
	vector furthestFromCenter = center
	foreach( point in spawnOptionList )
	{
		if ( Distance( point.GetOrigin(), center ) >= Distance( furthestFromCenter, center ) )
			furthestFromCenter = point.GetOrigin()
	}

	float boundaryRadius = Distance( furthestFromCenter, center )
	float fov = DegToRad( DEFAULT_FOV )
	float cameraDistance = ( boundaryRadius * 1.9 ) / tan( fov / 2.0 )

	vector centerLine = center - furthestFromCenter
	centerLine = CrossProduct( centerLine, <0,0,1> )
	vector cameraDirectionUp = <0,0,1>
	vector cameraDirectionFinal = Normalize( ( 0.5 * Normalize( centerLine ) ) + ( cameraDirectionUp ) )
	vector cameraPosition = center + ( cameraDirectionFinal * cameraDistance )
	vector cameraLookDirection = center - cameraPosition

	file.cameraLocation = cameraPosition
	file.cameraAngles   = VectorToAngles(cameraLookDirection )
}
#endif // SERVER

#if SERVER
void function Control_ControlPointSetup()
{
	ControlTeamSpawnData spawnData = file.chosenVariantData.teamSpawnData[ALLIANCE_A]
	vector avgOrigin = GetAverageOriginOfEnts( spawnData.spawnTriggers )

	array<ControlPointData> pointData
	for(int i = 0; i<file.chosenVariantData.controlPoints.len(); i++ )
	{
		ControlPointData point = file.chosenVariantData.controlPoints[i]
		if ( pointData.len() == 0 )
		{
			pointData.append( point )
		}
		else
		{
			vector origin = point.trigger.GetOrigin()
			float distanceToSpawn = Distance2D( origin, avgOrigin )
			int insertionIndex = pointData.len()
			for(int j = 0; j<pointData.len(); j++ )
			{
				vector testOrigin = pointData[j].trigger.GetOrigin()
				float testDistanceToSpawn = Distance2D( testOrigin, avgOrigin )
				if ( distanceToSpawn < testDistanceToSpawn )
				{
					insertionIndex = j
					break
				}
			}
			pointData.insert( insertionIndex, point )
		}
	}
	file.chosenVariantData.controlPoints = pointData

	int pointIndex = 0
	foreach( point in file.chosenVariantData.controlPoints )
	{
		entity trigger = point.trigger

		trigger.kv.triggerFilterUseNew = 1
		trigger.kv.triggerFilterPlayer = "all"
		trigger.kv.triggerFilterPhaseShift = "nonphaseshift"
		trigger.SetPhaseShiftCanTouch( false )
		trigger.kv.triggerFilterNpc = "none"
		trigger.kv.triggerFilterNonCharacter = 0
		trigger.kv.triggerFilterTeamMilitia = 1
		trigger.kv.triggerFilterTeamIMC = 1
		trigger.kv.triggerFilterTeamNeutral = 1
		trigger.kv.triggerFilterTeamBeast = 1
		trigger.kv.triggerFilterTeamOther = 1
		trigger.SetEnterCallback( Control_OnObjectiveTriggerEnter )
		trigger.SetLeaveCallback( Control_OnObjectiveTriggerExit )
		trigger.Enable()
		trigger.SearchForNewTouchingEntity()

		point.id = pointIndex
		point.name = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_UnLocalized( pointIndex )

		pointIndex++
		file.chosenVariantData.triggerToControlPointMap[trigger] <- point
	}
}
#endif // SERVER

#if SERVER
void function Control_SpawnAreaSetup()
{
	ControlTeamSpawnData allianceAData
	ControlTeamSpawnData allianceBData

	foreach( spawnArea in file.teamSpawnAreas )
	{
		#if DEV
			printt( "CONTROL: setting up spawn area at ", spawnArea.GetOrigin() )
		#endif // DEV

		//setup triggers here
		int radius
		int height
		int assignedTeam

		if ( spawnArea.HasKey( "area_radius" ) )
			radius = int(spawnArea.kv.area_radius)
		if ( spawnArea.HasKey( "area_height" ) )
			height = int(spawnArea.kv.area_height)
		if ( spawnArea.HasKey( "team" ) )
			assignedTeam = int(spawnArea.kv.team)

		entity spawnTrigger = CreateTriggerCylinder( spawnArea.GetOrigin(), radius, height/2, height/2 )
		spawnTrigger.SetEnterCallback( Control_OnSpawnAreaTriggerEnter )
		spawnTrigger.SetLeaveCallback( Control_OnSpawnAreaTriggerExit )
		spawnTrigger.SearchForNewTouchingEntity()

		if ( assignedTeam == ALLIANCE_A )
			allianceAData.spawnTriggers.append( spawnTrigger )
		else if ( assignedTeam == ALLIANCE_B )
			allianceBData.spawnTriggers.append( spawnTrigger )
		else
			Assert( false, "CONTROL: Spawn Area at " + spawnArea.GetOrigin() + " is not assigned to a valid team. Assign to 0 for ALLIANCE_A or 1 for ALLIANCE_B in leveled and recompile" )

		spawnArea.LinkToEnt( spawnTrigger )
	}

	table<int, ControlTeamSpawnData > teamSpawnData
	teamSpawnData[ALLIANCE_A] <- allianceAData
	teamSpawnData[ALLIANCE_B] <- allianceBData

	file.chosenVariantData.teamSpawnData = teamSpawnData

	foreach( spawnTriggerA in allianceAData.spawnTriggers )
		file.chosenVariantData.triggerToSpawnDataMap[ spawnTriggerA ] <- allianceAData
	foreach( spawnTriggerB in allianceBData.spawnTriggers )
		file.chosenVariantData.triggerToSpawnDataMap[ spawnTriggerB ] <- allianceBData
}
#endif // SERVER

#if SERVER
entity function Control_GetMusicEntity()
{
	return file.musicEntity
}
#endif // SERVER

#if SERVER
const vector TRACEBLOCKER_BOXMINS =  < -10, -10, 0 >
const vector TRACEBLOCKER_BOXMAXS = < 10, 10, 65 >
const float DEFAULT_WAYPOINT_OFFSET = 256.0
const float FLAG_PROP_WAYPOINT_OFFSET = 80.0
void function Control_OnGameStatePlaying()
{
	if ( file.mapInitialized )
		return

	CreateMusicEntityIfNotValid()

	foreach( point in file.chosenVariantData.controlPoints )
	{
		entity trigger = point.trigger
		entity waypointObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", trigger.GetOrigin() )

		float waypointOffset = DEFAULT_WAYPOINT_OFFSET
		entity parentObj = waypointObj
		if ( IsValid( point.flagProp ) )
		{
			waypointOffset = FLAG_PROP_WAYPOINT_OFFSET
			parentObj = point.flagProp
		}

		//setup waypoints for data transmission
		entity wp = CreatePlayerWaypoint_Wrapper( eWaypoint.CONTROL_OBJECTIVE )
		wp.SetOwner( point.trigger )
		wp.SetWaypointEntity( CONTROL_WAYPOINT_TRIGGER_ENTITY_INDEX, point.trigger ) //ToDo DSwieczko: Determine if you will still need this to get the Border Color Stuff working
		wp.SetParent( parentObj )
		wp.SetLocalOrigin( <0, 0, waypointOffset> )

		point.waypoint = wp

		//spawn minimap obj
		if ( Control_ShouldShow2DMapIcons() )
		{
			entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", trigger.GetOrigin() )
			minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.CONTROL_OBJECTIVE )
			minimapObj.Minimap_SetObjectScale( 1 )
			minimapObj.SetParent( waypointObj )
			minimapObj.Minimap_SetAlignUpright( true )
			SetTargetName( minimapObj, "controlIcon" )
			minimapObj.Minimap_AlwaysShow( TEAM_UNASSIGNED, null )
			minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
			minimapObj.DisableHibernation()
		}

		wp.SetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX, point.id )

		if ( trigger.HasKey( "avg_boundary_radius" ) )
			wp.SetWaypointFloat( FLOAT_AVG_BOUNDARY_RADIUS, float( trigger.kv.avg_boundary_radius ) )
		else
			wp.SetWaypointFloat( FLOAT_AVG_BOUNDARY_RADIUS, 1000 )
		// Need a parent entity for pings. Also allow players to ping the in world representation of the objective marker directly.
		entity traceBlocker = CaptureObjectivePing_CreateObjectivePingTraceBlocker( wp, TRACEBLOCKER_BOXMINS, TRACEBLOCKER_BOXMAXS, CONTROL_OBJECTIVE_SCRIPTNAME, false )
		// Create a ping on the objective for each alliance so players can ping through geo
		//CaptureObjectivePing_CreateStarterPingsOnObjective( wp, traceBlocker, ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )
		file.objectiveStarterPingTraceBlockers.append( traceBlocker )

		thread Control_PointCaptureThread( point )
	}

	thread SetupBasePointWaypoints()

	// Start a thread that looks for dropped loot and cleans it up
	thread DroppedLootCleanUp_Thread()
	//Start a thread that manages wave respawn timing
	thread Control_ManageWaveSpawnIntervals_Thread( )

	thread Control_ScoreManagementThread()

	file.mapInitialized = true

	thread SetupHovertanksIfApplicable()
	thread HandleDeathfieldUpdate()
}
#endif // SERVER

#if SERVER
void function CreateMusicEntityIfNotValid()
{
	if ( !IsValid( file.musicEntity ) )
	{
		file.musicEntity = CreateEntity( "prop_script" )
		file.musicEntity.SetOrigin( <0,0,10000> )
		file.musicEntity.DisableHibernation()
		DispatchSpawn( file.musicEntity )
	}
}
#endif // SERVER

#if SERVER
void function HandleDeathfieldUpdate()
{
	//FlagWaitClear( "AllowDeathFieldUpdate" )
	//FlagSet( "DeathFieldPaused" )
}
#endif // SERVER

#if SERVER
void function SetupHovertanksIfApplicable()
{
	/*if ( GetMapName().find( "canyonlands" ) == -1 )
		return

	FlagWait( "IntroHovertanksSet" )

	array<HoverTank> hoverTankList = GetAllHoverTanks()
	if ( hoverTankList.len() == 0 )
		return

	if ( hoverTankList.len() < 2 )
		Assert( false, "CONTROL: not enough hovertanks set in playlist - change hovertanks_count_intro to 2" )

	//-1 is no hovertanks, 0 is hovertank for alliance 0, 1 is hovertank for alliance 1, 2 is hovertanks for both
	int hovertanksToSet = GetCurrentPlaylistVarInt( "control_hovertank_setup", -1 )
	if ( hovertanksToSet == -1 )
		return

	array<entity> hovertankPlacementNodes
	//try to find default positions
	for( int i = 0; i<2; i++ )
	{
		foreach( hovertank in GetEntArrayByScriptName( "control_hovertank_spawn_" + i ) )
		{
			if( Control_IsChildOfCurrentMapNode( hovertank, "hovertank" ) )
			{
				hovertankPlacementNodes.append( hovertank )
				break
			}
		}
	}

	//fall back to hardcoded defaults if we couldn't find control spawns
	if ( hovertankPlacementNodes.len() == 0 )
	{
		entity defaultALocation = CreateInfoTarget( <-51, -19244, 4954>, <0, 28, 0> ) //A side
		entity defaultCLocation = CreateInfoTarget( <14095.9, -21326.6, 3398.5>, <0, -10, 0> ) //C side //BUG - must subtract 90 from editor placed rotation.

		if ( hovertanksToSet == 0 )
		{
			hovertankPlacementNodes.append( defaultALocation )
			Warning( "CONTROL: could not find info target for placing hovertank on C side, placing at fixed location - see compiled map for Placement Node setup" )
		}
		else if ( hovertanksToSet == 1 )
		{
			hovertankPlacementNodes.append( defaultCLocation )
			Warning( "CONTROL: could not find info target for placing hovertank on C side, placing at fixed location - see compiled map for Placement Node setup" )
		}
		else if ( hovertanksToSet == 2 )
		{
			hovertankPlacementNodes.append( defaultALocation )
			hovertankPlacementNodes.append( defaultCLocation )
			Warning( "CONTROL: could not find info target for placing hovertank either A or C side, placing at fixed location - see compiled map for Placement Node setup" )
		}
	}

	if ( hovertanksToSet == 0 || hovertanksToSet == 2 )
	{
		file.setHovertank.append( hoverTankList[0] )
		entity placementNode = hovertankPlacementNodes[0]
		HoverTankTeleportToPosition( hoverTankList[0], placementNode.GetOrigin(), placementNode.GetAngles() )
		SetSpawnpointsForHovertank( hoverTankList[0], ALLIANCE_A )
		file.hovertankMoverToAlliance[ hoverTankList[0].flightMover ] <- ALLIANCE_A
	}
	if ( hovertanksToSet == 1 || hovertanksToSet == 2 )
	{
		file.setHovertank.append( hoverTankList[1] )
		entity placementNode = hovertankPlacementNodes.len() == 1 ? hovertankPlacementNodes[0] : hovertankPlacementNodes[1]
		HoverTankTeleportToPosition( hoverTankList[1], placementNode.GetOrigin(), placementNode.GetAngles() )
		SetSpawnpointsForHovertank( hoverTankList[1], ALLIANCE_B )
		file.hovertankMoverToAlliance[ hoverTankList[1].flightMover ] <- ALLIANCE_B
	}

	HoverTank_AddCallback_OnPlayerEnteredVolume( Control_OnPlayerEnteredHovertankVolume )
	HoverTank_AddCallback_OnPlayerExitedVolume( Control_OnPlayerExitedHovertankVolume )*/
}
#endif // SERVER

#if SERVER
void function SetSpawnpointsForHovertank(  int alliance )
{

}
#endif // SERVER

#if SERVER
//HOVER TANK SPAWN POSITIONS
vector function Control_GetHoverTankSpawnOffset( int index )
{
	switch( index )
	{
		case 0:
			return <-0.912109375, 336.949219, -122.897949> //left side steps -good
		case 1:
			return <-173.166992, 85.5214844, -97.9375> //bottom mid, back right -good
		case 2:
			return <121.615234, 37.8632813, -97.9375> //bottom mid, back left -good
		case 3:
			return <236.799805, -55.984375, 85.1015625> //left side 1 -good
		case 4:
			return <329.90918, 274.744141, 85.1018066> //left side 2 -good
		case 5:
			return <411.385742, -6.63867188, 85.1015625> //left side 3 -good
		case 6:
			return <-71.3154297, 417.398438, 85.1018066> //back ramp right 1 -good
		case 7:
			return <-132.998047, 460.384766, 85.1018066> //back ramp mid 2 -good
		case 8:
			return <-820.617188, 150.070313, 149.101563> //top 1 -good
		case 9:
			return <368.827148, 99.2382813, 229.101563> //top 2 -good
		default:
			return <0,0,0>
	}
	unreachable
}
#endif // SERVER

#if SERVER
void function Control_SkydiveLauncherMapInitialization()
{
	printt( "CONTROL: Running Control_SkydiveLauncherMapInitialization" )

	FlagWait( "MapSetupComplete" )
}
#endif // SERVER

#if SERVER
void function SetupBasePointWaypoints()
{
	wait CONTROL_TIME_BEFORE_INIT_SPAWNPOINTS

	int alliance = ALLIANCE_A

	// Setup homebase spawns for each alliance. Expect 2
	foreach ( spawnData in file.chosenVariantData.teamSpawnData )
	{
		if ( alliance == ALLIANCE_A || alliance == ALLIANCE_B )
		{
			vector spawnAvg
			foreach( spawnArea in spawnData.spawnTriggers )
				spawnAvg = spawnAvg + spawnArea.GetOrigin()
			spawnAvg = spawnAvg / spawnData.spawnTriggers.len()

			SetupHomebaseSpawnWaypoint( alliance, spawnAvg )
		}
		else
		{
			break
		}

		alliance++
	}

	// Setup spawns on the Objectives
	// ToDo: Could the objective waypoints be used for this now since they share the INT_CONTROL_WAYPOINT_TYPE_INDEX
	foreach ( point in file.chosenVariantData.controlPoints )
	{
		SetupObjectiveSpawnWaypoint( point )
	}
}
#endif // SERVER

#if SERVER || CLIENT
// Set the positions that block MRB placement around Home Base spawns for an alliance
void function Control_SetHomeBaseBadPlacesForMRBForAlliance( int alliance, array < vector > locations )
{
	if ( alliance == ALLIANCE_A )
	{
		file.allianceABlockedHomeBasePositionsForMRB.extend( locations )
	}
	else if ( alliance == ALLIANCE_B )
	{
		file.allianceBBlockedHomeBasePositionsForMRB.extend( locations )
	}
}
#endif // SERVER || CLIENT


#if SERVER
// Setup a homebase spawn for the specified alliance
entity function SetupHomebaseSpawnWaypoint( int alliance, vector location )
{
	entity waypointObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", location + <0,0,256> )
	entity spawnWP = CreateWaypoint_BasicEntLocation( waypointObj, ePingType.NON_PINGABLE_SPAWN_LOCATION )
	spawnWP.SetParent( waypointObj )
	spawnWP.SetLocalOrigin( <0, 0, 256> )

	if ( alliance == ALLIANCE_A )
	{
		// Add to spawn waypoints array and identify the index
		spawnWP.SetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX, eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A )
		file.spawnWaypoints[ eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A ] = spawnWP

		// Add no mrb deploy allowed locations for homebase spawns
		file.allianceABlockedHomeBasePositionsForMRB.append( spawnWP.GetOrigin() )
	}
	else
	{
		// Add to spawn waypoints array and identify the index
		spawnWP.SetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX, eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B )
		file.spawnWaypoints[ eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B ] = spawnWP

		// Add no mrb deploy allowed locations for homebase spawns
		file.allianceBBlockedHomeBasePositionsForMRB.append( spawnWP.GetOrigin() )
	}

	return spawnWP
}
#endif // SERVER

#if SERVER
entity function SetupSquadSpawnWaypoint( entity player )
{
	entity spawnWP = CreateWaypoint_BasicEntLocation( player, ePingType.NON_PINGABLE_SPAWN_LOCATION )
	spawnWP.SetParent( player )
	spawnWP.SetLocalOrigin( <0, 0, 256> )
	spawnWP.SetOnlyTransmitToSingleTeam( player.GetTeam() )
	spawnWP.SetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX, eControlWaypointTypeIndex.SQUAD_SPAWN )

	return spawnWP
}
#endif // SERVER

#if SERVER
// Setup a spawn waypoint on an Objective
entity function SetupObjectiveSpawnWaypoint( ControlPointData point )
{
	entity spawnWP = CreateWaypoint_BasicEntLocation( point.waypoint, ePingType.NON_PINGABLE_SPAWN_LOCATION )
	spawnWP.SetParent( point.waypoint )
	spawnWP.SetLocalOrigin( <0, 0, 256> )
	spawnWP.SetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX, point.id )
	file.spawnWaypoints[ point.id ] = spawnWP

	return spawnWP
}
#endif // SERVER

#if SERVER
void function Control_OnPlayerEnteredHovertankVolume( entity player )
{
	#if DEV
		printt( "CONTROL: Player entering hovertank: ", player )
	#endif // DEV

	Control_PrintSkydiveDebug( player, " Control Control_OnPlayerEnteredHovertankVolume" )

	thread Control_DisablePlayerWeapons_Thread( player, eControlWeaponDisableReason.HOVERTANK )
}
#endif // SERVER

#if SERVER
void function Control_OnPlayerExitedHovertankVolume( entity player )
{
	#if DEV
		printt( "CONTROL: Player leaving hovertank: ", player )
	#endif // DEV

	Control_PrintSkydiveDebug( player, " Control player leaving hovertank" )

	if ( IsValid( player ) )
	{
		Control_PrintSkydiveDebug( player, " Control_OnPlayerExitedHovertankVolume going to trigger PlayerSkydiveFromCurrentPosition" )
		PlayerMatchState_Set( player, ePlayerMatchState.SKYDIVE_FALLING )
		thread PlayerSkydiveFromCurrentPosition( player )
		player.Signal( "PlayerExitedHovertankVolume" )
	}
}
#endif // SERVER

#if CLIENT
// Add entities to allowed for airdrop list on the Client ( they have been added on the server but the client needs to know as well so abilities like Lifeline's Ult will show the correct icon when trying to place it)
void function ServerCallback_Control_SetControlGeoValidForAirdropsOnClient( entity geo )
{
	if ( IsValid( geo ) && !GetAllowedAirdropDynamicEntitiesArray().contains( geo ) )
		AddToAllowedAirdropDynamicEntities( geo )
}
#endif // CLIENT

#if CLIENT
// Close all menus and de-register buttons when the player exits the mode
void function ServerCallback_Control_DeregisterModeButtonPressedCallbacks()
{
	Control_DeregisterModeButtonPressedCallbacks()
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_SetDeathScreenCallbacks()
{
	DeathScreen_SetModeSpecificRuiUpdateFunc( Control_DeathScreenUpdate )
	DeathScreen_SetDataRuiAssetForGamemode( DEATH_SCREEN_RUI )
	SetSummaryDataDisplayStringsCallback( Control_PopulateSummaryDataStrings )
}
#endif // CLIENT

#if SERVER || CLIENT
//Register timed events that are enabled so they can trigger at different time intervals
// NOTE: the repeat interval is based off of the event start time, not its end time
// Example: An Event that has a startTimeDelay of 60, repeatInterval of 120, eventLength 60 would trigger 1 min into the match, last for 1 min, and trigger again 1 min later
// Events on a single schedule ignore the startTimeDelay and repeatInterval set on the event itself, they abide by the settings on the function TimedEvents_SetSingleScheduleVars
// Events set to be on the single schedule trigger in the order they are registered.
void function Control_RegisterTimedEvents()
{
	//Register Lockouts if they are enabled
	if (  Control_GetIsLockoutEnabled() )
	{
		TimedEventData lockoutData
		lockoutData.eventType = eControlTimedEventType.LOCKOUT
		lockoutData.shouldShowPreamble = false

		#if SERVER
			lockoutData.isTriggeredByFunctionCall = true
			lockoutData.isRepeatingEvent = true
			lockoutData.shouldDestroyWPOnEventEnd = true
			lockoutData.timedEventFunctionThread = Control_LockoutThread
			lockoutData.startTimeDelay = 10.0
			lockoutData.repeatInterval = 1.0
			lockoutData.eventLength = CONTROL_LOCKOUT_EVENT_DURATION
			lockoutData.timedEventFunctionStartValidation = Control_LockoutStartValidation
			lockoutData.shouldCancelOtherTimedEvents = true
		#endif // SERVER

		#if CLIENT
			lockoutData.eventName = "#EVENT_LOCKOUT_NAME"
			lockoutData.infoOverrideFunctionThread = Control_LockoutInfoOverride_Thread
			lockoutData.shouldHideTimer = false
		#endif // CLIENT

		TimedEvents_RegisterTimedEvent( lockoutData )
	}

	//Register Airdrops if they are enabled
	if ( Control_GetAreAirdropsEnabled() )
	{
		TimedEventData airdropData
		airdropData.eventType = eControlTimedEventType.AIRDROP
		airdropData.shouldShowPreamble = false
		#if SERVER
			airdropData.isTriggeredByFunctionCall = false
			airdropData.isRepeatingEvent = true
			airdropData.shouldDestroyWPOnEventEnd = true
			airdropData.shouldUseSingleSchedule = true
			airdropData.timedEventFunctionThread = Control_ManageAirdrops_Thread
			airdropData.startTimeDelay = 75.0
			airdropData.repeatInterval = 400.0
			airdropData.eventLength = 30.0
			airdropData.timedEventFunctionStartValidation = Control_AirdropStartValidation
		#endif // SERVER

		#if CLIENT
			airdropData.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
			airdropData.eventName = "#EVENT_AIRDROP_NAME"
			airdropData.eventDesc = "#EVENT_AIRDROP_DESC"
			airdropData.shouldHideTimer = true
		#endif // CLIENT

		TimedEvents_RegisterTimedEvent( airdropData )
	}

	// Register the MRB event if it is enabled
	if ( Control_GetIsMRBTimedEventEnabled() )
	{
		TimedEventData mrbEventData
		mrbEventData.eventType = eControlTimedEventType.MRB
		mrbEventData.shouldShowPreamble = true
		mrbEventData.shouldHideUntilPrembleDone = true
		#if SERVER
			mrbEventData.isTriggeredByFunctionCall = false
			mrbEventData.isRepeatingEvent = true
			mrbEventData.shouldDestroyWPOnEventEnd = false
			mrbEventData.shouldUseSingleSchedule = true
			mrbEventData.timedEventFunctionThread = Control_MRBTimedEvent_Thread
			mrbEventData.startTimeDelay = 300.0
			mrbEventData.repeatInterval = 400.0
			mrbEventData.eventLength = 100.0
			mrbEventData.timedEventFunctionStartValidation = Control_MRBTimedEventStartValidation
		#endif // SERVER

		#if CLIENT
			mrbEventData.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
			mrbEventData.eventName = "#EVENT_STARTS_IN"
			mrbEventData.eventDesc = "#EVENT_MRB_DESC"
			mrbEventData.shouldHideTimer = false
			mrbEventData.shouldAutoShowSuddenDeathText = false
			mrbEventData.infoOverrideFunctionThread = Control_MRBTimedEvent_InfoOverride_Thread
		#endif // CLIENT

		TimedEvents_RegisterTimedEvent( mrbEventData )
	}

	//Register Bounties if they are enabled
	if ( Control_GetAreBonusCaptureTimedEventsEnabled() )
	{
		TimedEventData bountyData
		bountyData.eventType = eControlTimedEventType.BOUNTY
		bountyData.shouldShowPreamble = true
		bountyData.shouldHideUntilPrembleDone = true
		#if SERVER
			bountyData.isTriggeredByFunctionCall = false
			bountyData.isRepeatingEvent = true
			bountyData.shouldDestroyWPOnEventEnd = false
			bountyData.shouldUseSingleSchedule = true
			bountyData.timedEventFunctionThread = Control_BountyThread
			bountyData.startTimeDelay = 150.0
			bountyData.repeatInterval = 350.0
			bountyData.eventLength = 80.0
			bountyData.timedEventFunctionStartValidation = Control_BountyStartValidation
		#endif // SERVER

		#if CLIENT
			bountyData.eventName = "#EVENT_STARTS_IN"
			bountyData.eventDesc = "#EVENT_BOUNTY_DESC"
			bountyData.infoOverrideFunctionThread = Control_BountyInfoOverride_Thread
			bountyData.shouldHideTimer = false
		#endif // CLIENT

		TimedEvents_RegisterTimedEvent( bountyData )
	}

	#if SERVER
		TimedEvents_SetSingleScheduleVars( true, false, 100.0, 120.0 )
	#endif // SERVER
}
#endif // SERVER || CLIENT

#if CLIENT
// Trigger a ping on the objective closest to the cursor on the full map
void function Control_PingObjectiveFromObjID( int objID )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	foreach ( ping in CaptureObjectivePing_GetStarterPingsArray() )
	{
		if ( !IsValid( ping ) )
			continue

		int objectiveWaypointPingType = Waypoint_GetPingTypeForWaypoint( ping )
		if ( objectiveWaypointPingType == ePingType.PING_CAPTURE_OBJECTIVE_DEFEND || objectiveWaypointPingType == ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )
		{
			if ( IsValid( ping.GetParent() ) && IsValid( ping.GetParent().GetOwner() ) )
			{
				entity pingedObjective = ping.GetParent().GetOwner()
				int pingedObjectiveObjID = pingedObjective.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
				if ( pingedObjectiveObjID == objID )
					CaptureObjectivePing_SetObjectivePing( player, pingedObjective )
			}
		}
	}
}
#endif // CLIENT



/*
  _____    _                  __     __  ______   _____      _____   _   _   _____   _______   _____              _        _____   ______             _______   _____    ____    _   _
 |  __ \  | |          /\     \ \   / / |  ____| |  __ \    |_   _| | \ | | |_   _| |__   __| |_   _|     /\     | |      |_   _| |___  /     /\     |__   __| |_   _|  / __ \  | \ | |
 | |__) | | |         /  \     \ \_/ /  | |__    | |__) |     | |   |  \| |   | |      | |      | |      /  \    | |        | |      / /     /  \       | |      | |   | |  | | |  \| |
 |  ___/  | |        / /\ \     \   /   |  __|   |  _  /      | |   | . ` |   | |      | |      | |     / /\ \   | |        | |     / /     / /\ \      | |      | |   | |  | | | . ` |
 | |      | |____   / ____ \     | |    | |____  | | \ \     _| |_  | |\  |  _| |_     | |     _| |_   / ____ \  | |____   _| |_   / /__   / ____ \     | |     _| |_  | |__| | | |\  |
 |_|      |______| /_/    \_\    |_|    |______| |_|  \_\   |_____| |_| \_| |_____|    |_|    |_____| /_/    \_\ |______| |_____| /_____| /_/    \_\    |_|    |_____|  \____/  |_| \_|

                                                                                                                                                                                       */
#if SERVER
// This function used to trigger off of the gamestate.playing state but we found issues where the player Init wasn't where we wanted it before functions started using the variables set here ( specifically alliance player counts)
void function Control_OnGameStatePrematch()
{
	foreach ( player in GetPlayerArray_Alive() )
	{
		player.SetMinimapZoomScale( 2.0, 3.0 )
	}

	if ( GamemodeUtility_GetMixtapeAbandonPenaltyActive() )
	{
		// Update rankedDidPlayerEverHaveAFullTeam now that faction counts are set
		foreach ( player in GetPlayerArray() )
		{
			if ( AllianceProximity_GetNumPlayersInAlliance( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ), false ) == GetCurrentPlaylistVarInt( "max_players", CONTROL_DEFAULT_MAX_PLAYERS ) / 2 )
				player.SetPlayerNetBool( "rankedDidPlayerEverHaveAFullTeam", true )
		}
	}
}
#endif // SERVER

#if SERVER
bool function Control_SupressGameStartSpawn_Player( entity player )
{
	return false
}
#endif // SERVER

#if SERVER
bool function Control_SupressGameStartSpawn()
{
	return false
}
#endif // SERVER

#if SERVER
void function ConnectionRestored_ShowSpawnSelection( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo", Control_IsPlayerWaitingForWeaponEvo( player ) , false )
	int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_TransferCameraData", file.cameraLocation, file.cameraAngles )

	thread function() : ( player )
	{
		player.EndSignal( "OnDestroy" )
		WaitEndFrame()

		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_ShowSpawnSelection" )

		// Update currently selected Loadout Text on the spawn screen near the Change Loadout Button
		if ( IsUsingLoadoutSelectionSystem() )
		{
			wait 5.0
			LoadoutSelection_UpdateLoadoutInfoForMenus( player )
		}
	}()
}
#endif // SERVER

#if SERVER
void function OnPlayerConnected( entity player )
{

	int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_TransferCameraData", file.cameraLocation, file.cameraAngles )
	Control_SetFuncGeoToAllowedAirdropEntitiesForPlayer( player )

	thread SetupPlayerThread( player )

	if (GamemodeUtility_GetMixtapeAbandonPenaltyActive() && AllianceProximity_GetNumPlayersInAlliance( playerAlliance, false ) == GetCurrentPlaylistVarInt( "max_players", CONTROL_DEFAULT_MAX_PLAYERS ) / 2 )
		player.SetPlayerNetBool( "rankedDidPlayerEverHaveAFullTeam", true )

	// Set whether anonymous mode is turned on for this player. Normally this is done in Survival_PlayerCharacterSetup in _gamemode_survival.nut but that logic runs after we do our intro podium.
	if ( !GamemodeUtility_IsWinnerBeingDetermined() && IsValid( player ) )
	{
		//Anonymous Mode
		bool playerIsAnonymous = false//player.IsHudSettingAnonymousMode()
		player.SetPlayerNetBool( "anonymizePlayerName", playerIsAnonymous )
	}
}
#endif // SERVER

#if SERVER
// Perform special setup on observers when they connect to the match
void function Control_OnObserverConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_TransferCameraData", file.cameraLocation, file.cameraAngles )
}
#endif // SERVER

#if SERVER
// Update player counts per faction on disconnect
void function OnPlayerDisconnected( entity player )
{
	// Test for logic that occurs when players leave the match ( like disabling Leaver Penalty or ending the match if a whole alliance quit )
	thread Control_RunPlayerCountDependantLogicDelayed_Thread()
}
#endif // SERVER

#if SERVER
void function SetupPlayerThread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	while ( !IsValidPlayer(player) || GetGameState() != eGameState.Playing )
		WaitFrame()

	FlagWait( "EntitiesDidLoad" ) // Need this wait otherwise loadout and spawn logic seems to run incorrectly for players that join after the spawn menu opens for other players
	FlagWait( "PlayersSpawnedInArena" )

	if ( Control_GetShouldSkydiveRespawn() )
	{
		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt("CONTROL: SetupPlayerThread going to spawn the player: ", player, " at homebase" )

		Control_RespawnPlayerAtHomeBase(player)
		// Update currently selected Loadout Text on the spawn screen near the Change Loadout Button
		if ( IsUsingLoadoutSelectionSystem() )
		{
			LoadoutSelection_UpdateLoadoutInfoForMenus( player )
			Remote_CallFunction_UI( player, "LoadoutSelectionMenu_OpenLoadoutMenu", false )
		}
	}
	else
	{
		SetPlayerForSpawnSelection( player )
	}

	thread Control_ChooseBotRespawnLocation_Thread( player )

	player.WaitSignal( "Control_PlayerRespawning" )

	if ( player.p.hasStagingAreaDamageProtection )
	{
		RemoveEntityCallback_OnDamaged( player, StagingAreaPlayerTookDamageCallback )
		player.p.hasStagingAreaDamageProtection = false
	}

	ClearPlayerIntroDropSettings( player )
	AddEntityCallback_OnDamaged( player, Control_OnAllianceDamage )

	if ( Control_GetIsAmmoInfinite() )
		SetInfiniteAmmoForGameMode( player, true, ["crate"] )
	if ( Control_GetIsFastHeal() )
		GivePassive( player, ePassives.PAS_FAST_HEAL )

	GivePassive( player, ePassives.PAS_GUARDIAN_ANGEL )
	if ( GetCurrentPlaylistVarBool( "infinite_heal_items", false ) )
		GivePassive( player, ePassives.PAS_INFINITE_HEAL )

	//give tactical
	Control_RestoreChargesOnRespawn( player )

	// Just in case, if a players offhand weapons were disabled for weapon evo and are still disabled, enable them.
	if ( IsValid( player ) && Control_GetIsPlayerWeaponEvoInProgress( player ) )
	{
		EnableOffhandWeapons( player )
		file.playersWithWeaponEvoInProgressArray.fastremovebyvalue( player )
	}

	player.p.respawnPodLanded = true
	// Set so ult and tac is not messed up when use sky dive launchers or spawn on hover tank and sky dive down
	player.p.survivalLandedOnGround = true

	player.SetMinimapZoomScale( 2.0, 3.0 )
}
#endif // SERVER

#if SERVER
void function Control_OnAllianceDamage( entity player, var damageInfo )
{
	//if players are on teams that have an allinace, don't let them damage each other
	if ( !IsValid( player ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) )
	{
		if ( player == attacker )
			return

		int victimTeam = player.GetTeam()
		int attackerTeam = attacker.GetTeam()

		if ( IsFriendlyTeam( victimTeam, attackerTeam ) )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
		}
	}
}
#endif // SERVER







/*
   ____    ____         _   ______    _____   _______   _____  __      __  ______
  / __ \  |  _ \       | | |  ____|  / ____| |__   __| |_   _| \ \    / / |  ____|
 | |  | | | |_) |      | | | |__    | |         | |      | |    \ \  / /  | |__
 | |  | | |  _ <   _   | | |  __|   | |         | |      | |     \ \/ /   |  __|
 | |__| | | |_) | | |__| | | |____  | |____     | |     _| |_     \  /    | |____
  \____/  |____/   \____/  |______|  \_____|    |_|    |_____|     \/     |______|


  __  __              _   _               _____   ______   __  __   ______   _   _   _______
 |  \/  |     /\     | \ | |     /\      / ____| |  ____| |  \/  | |  ____| | \ | | |__   __|
 | \  / |    /  \    |  \| |    /  \    | |  __  | |__    | \  / | | |__    |  \| |    | |
 | |\/| |   / /\ \   | . ` |   / /\ \   | | |_ | |  __|   | |\/| | |  __|   | . ` |    | |
 | |  | |  / ____ \  | |\  |  / ____ \  | |__| | | |____  | |  | | | |____  | |\  |    | |
 |_|  |_| /_/    \_\ |_| \_| /_/    \_\  \_____| |______| |_|  |_| |______| |_| \_|    |_|

                                                                                             */




#if SERVER
void function Control_OnObjectiveTriggerEnter( entity trigger, entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	ControlPointData data = file.chosenVariantData.triggerToControlPointMap[trigger]
	if ( !data.playersInControlPoint.contains( player ) )
		data.playersInControlPoint.append( player )

	player.SetPlayerNetInt( "control_ObjectiveIndex", data.id )
	Remote_CallFunction_Replay( player, "ServerCallback_Control_PlayCaptureZoneEnterExitSFX", true )

	if ( CONTROL_DETAILED_DEBUG )
		printt( "CONTROL: Player entered ", data.name )

}
#endif // SERVER

#if SERVER
void function Control_OnObjectiveTriggerExit( entity trigger, entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	ControlPointData data = file.chosenVariantData.triggerToControlPointMap[trigger]
	if ( data.playersInControlPoint.contains( player ) )
		data.playersInControlPoint.fastremovebyvalue( player )

	player.SetPlayerNetInt( "control_ObjectiveIndex", -1 )
	Remote_CallFunction_Replay( player, "ServerCallback_Control_PlayCaptureZoneEnterExitSFX", false )

	if ( CONTROL_DETAILED_DEBUG )
		printt( "CONTROL: Player left ", data.name )
}
#endif // SERVER

#if SERVER
// The indexes of this array line up with the difference in player counts from both teams capturing the objective.
// For example if there is 1 player from A and 1 player from B the difference is 0 so the multiplier is 0 and no progress is made.
// For example if there is 4 players from A and 1 player from B the difference is 3 so the multiplier is 2.0 so capture rate is increased
const array<float> CONTROL_CAPTURE_PLAYER_COUNT_MULTIPLIERS = [ 0.0, 1.0, 1.5, 2.0, 2.25, 2.5, 2.75, 3.0, 3.0, 3.0 ]
const float CONTROL_NEUTRAL_CAPTURE_PROGRESS_LOSS_MULTIPLIER = 0.1
// While we are playing the game, handle captures and neutralizations for this objective
void function Control_PointCaptureThread( ControlPointData data )
{
	Assert( IsNewThread(), "Must be threaded off" )

	float captureTime = Control_GetTimeToCaptureObjective()
	float lastLoopTime = Time()
	float lastAlertTime = Time()
	float lastBountyAward = Time()

	data.trigger.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( data )
		{
			if ( IsValid( data.waypoint ) )
				data.waypoint.Destroy()
		}
	)

	//process captures
	while ( IsValid( data.trigger ) && IsValid( data.waypoint ) && GetGameState() == eGameState.Playing )
	{
		float currentTime = Time()
		float timeSinceLastLoop = currentTime - lastLoopTime
		float timeSinceLastAlert = currentTime - lastAlertTime
		float percAdv = timeSinceLastLoop / captureTime

		if ( timeSinceLastAlert > CONTROL_TIME_BETWEEN_CONTESTING_ALERTS )
		{
			Control_AwardContesting( data )
			lastAlertTime = currentTime
		}

		int currentZoneState = eControlZoneState.INVALID

		if ( data.playersInControlPoint.len() == 0 && data.controlPointOwner == ALLIANCE_NONE )
		{
			currentZoneState = eControlZoneState.NEUTRALIZING

			// Control the rate at which capture progress is lost on an empty neutral objective
			percAdv *= CONTROL_NEUTRAL_CAPTURE_PROGRESS_LOSS_MULTIPLIER

			//no one is on the objective, it is uncontrolled
			float newPerc = data.controlPointPercent - percAdv
			if ( newPerc < 0 )
			{
				newPerc = 0
				currentZoneState = eControlZoneState.OPEN
			}

			data.controlPointPercent = newPerc
			data.waypoint.SetWaypointFloat( FLOAT_CAP_PERC, data.controlPointPercent )
			data.waypoint.SetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ, 0 )
			data.waypoint.SetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ, 0 )
			UpdateObjectiveStateForTeam( data, eControlPointObjectiveState.CONTROLLED, ALLIANCE_NONE, data.lastCapturingAlliance )
		}
		else
		{
			int numPlayersInAllianceA = 0
			int numPlayersInAllianceB = 0

			foreach( player in data.playersInControlPoint )
			{
				if ( IsValid( player ) )
				{
					if ( IsTeamInAlliance( player.GetTeam(), ALLIANCE_A ) )
						numPlayersInAllianceA++
					else if ( IsTeamInAlliance( player.GetTeam(), ALLIANCE_B ) )
						numPlayersInAllianceB++

					//track time the player has been on this  objective for the match
					if ( player in data.timeOnObjectiveByPlayerForMatch )
						data.timeOnObjectiveByPlayerForMatch[ player ] = data.timeOnObjectiveByPlayerForMatch[ player ] + timeSinceLastLoop
					else
						data.timeOnObjectiveByPlayerForMatch[ player ] <- 0
				}
			}

			data.waypoint.SetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ, numPlayersInAllianceA )
			data.waypoint.SetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ, numPlayersInAllianceB )

			//1. calculate how much the percentage advances by based on the difference between teams
			int teamDifference = maxint( numPlayersInAllianceA, numPlayersInAllianceB ) - minint( numPlayersInAllianceA, numPlayersInAllianceB )
			Assert( teamDifference < CONTROL_CAPTURE_PLAYER_COUNT_MULTIPLIERS.len(), "The capture player count multiplier array doesn't have enough entries to handle a difference of " + teamDifference )
			float differenceMultiplier = CONTROL_CAPTURE_PLAYER_COUNT_MULTIPLIERS[ teamDifference ]
			percAdv = percAdv * differenceMultiplier

			//2. check to see which team is capturing
			int allianceCapturing = ALLIANCE_NONE
			if ( numPlayersInAllianceA > numPlayersInAllianceB )
				allianceCapturing = ALLIANCE_A
			else if ( numPlayersInAllianceB > numPlayersInAllianceA )
				allianceCapturing = ALLIANCE_B

			//there is a stalemate, no team is capturing
			if ( allianceCapturing == ALLIANCE_NONE )
			{
				percAdv = 0
			}
			else
			{
				data.lastCapturingAlliance = allianceCapturing
			}

			//another team currently owns the waypoint instead of the capturing team, decrement
			// Also triggered if a team made progress on capturing a neutral point and then a different team comes in and starts undoing their progress.
			if ( ( data.controlPointOwner != data.lastCapturingAlliance && data.controlPointOwner != ALLIANCE_NONE ) || ( data.controlPointOwner == ALLIANCE_NONE && data.neutralPointOwnership != ALLIANCE_NONE && data.neutralPointOwnership != data.lastCapturingAlliance ) )
				percAdv = percAdv * -1

			float newPerc = data.controlPointPercent + percAdv

			if ( percAdv > FLT_EPSILON )
			{
				currentZoneState = eControlZoneState.CAPTURING
			}
			else if ( percAdv < -FLT_EPSILON )
			{
				currentZoneState = eControlZoneState.NEUTRALIZING
			}
			else
			{
				currentZoneState = eControlZoneState.CONTESTING
			}

			if ( newPerc >= 1 )
			{
				//team has controlled objective
				newPerc = 1
				UpdateObjectiveStateForTeam( data, eControlPointObjectiveState.CONTROLLED, data.lastCapturingAlliance, data.lastCapturingAlliance )
				data.neutralPointOwnership = ALLIANCE_NONE

				currentZoneState = eControlZoneState.CAPTURED
			}
			else if ( newPerc <= 0 && data.lastCapturingAlliance != ALLIANCE_NONE )
			{
				//owner has flipped
				newPerc = 0.01
				SendObjectiveStateAlertToPlayers( data.waypoint, eControlPointObjectiveState.CONTESTED, ALLIANCE_NONE, data.controlPointOwner, data.lastCapturingAlliance, data.lastCapturingAlliance, false )
				UpdateObjectiveStateForTeam( data, eControlPointObjectiveState.CONTESTED, ALLIANCE_NONE, data.lastCapturingAlliance )
				Control_AwardNeutralize( data, data.lastCapturingAlliance )
				data.neutralPointOwnership = data.lastCapturingAlliance
			}
			else if ( data.controlPointOwner == ALLIANCE_NONE && data.neutralPointOwnership == ALLIANCE_NONE )
			{
				data.neutralPointOwnership = data.lastCapturingAlliance
				UpdateObjectiveStateForTeam( data, eControlPointObjectiveState.CONTESTED, data.controlPointOwner, allianceCapturing )
			}
			else
			{
				UpdateObjectiveStateForTeam( data, eControlPointObjectiveState.CONTESTED, data.controlPointOwner, allianceCapturing )
			}

			data.controlPointPercent = newPerc
			data.waypoint.SetWaypointFloat( FLOAT_CAP_PERC, data.controlPointPercent )

			//track time players spent capturing this objective
			if ( allianceCapturing != ALLIANCE_NONE )
			{
				foreach ( player in data.playersInControlPoint )
				{
					if ( IsValid( player ) && IsTeamInAlliance( player.GetTeam(), allianceCapturing ) )
					{
						if ( player in data.timeCapturingByPlayerForMatch )
							data.timeCapturingByPlayerForMatch[ player ] = data.timeCapturingByPlayerForMatch[ player ] + timeSinceLastLoop
						else
							data.timeCapturingByPlayerForMatch[ player ] <- 0
					}
				}
			}
		}

		if ( data.lastZoneState != currentZoneState )
		{
			data.lastZoneState = currentZoneState
		}

		//track time owned by each team
		if ( data.controlPointOwner in data.timeOwnedByTeamForMatch )
			data.timeOwnedByTeamForMatch[ data.controlPointOwner ] = data.timeOwnedByTeamForMatch[ data.controlPointOwner ] + timeSinceLastLoop
		else
			data.timeOwnedByTeamForMatch[ data.controlPointOwner ] <- 0

		lastLoopTime = currentTime
		WaitFrame()
	}
}
#endif // SERVER

#if SERVER
// Get the shortest distance between the given location and all the spawns of the passed in alliance
float function Control_GetShortestDistFromLocToTeamSpawns( int alliance, vector location )
{
	float shortestDistToSpawn = -1
	ControlTeamSpawnData allianceSpawnData = file.chosenVariantData.teamSpawnData[alliance]

	foreach ( spawn in allianceSpawnData.spawnTriggers )
	{
		float positionDistSqr = Distance2DSqr( spawn.GetOrigin(), location )
		if ( shortestDistToSpawn == -1 || positionDistSqr < shortestDistToSpawn )
			shortestDistToSpawn = positionDistSqr
	}
	return shortestDistToSpawn
}
#endif // SERVER

#if SERVER
const float TIME_BETWEEN_SCORE_UPDATES = 1.0
void function Control_ScoreManagementThread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	CreateMusicEntityIfNotValid()
	if ( IsValid( file.musicEntity ) )
	{
		EmitSoundOnEntity( file.musicEntity, "Music_Ctrl_Gameplay" )
		file.musicEntity.UnsetSoundCodeControllerValue()
	}

	int scoreLimit = GetScoreLimit_FromPlaylist()
	int minNumOwnedObjectivesToGainScore = Control_GetMinHeldObjectivesToGenerateScore()

	for( int i = 0; i<2; i++ )
	{
		file.announcedHalfwayForAlliance[i] <- false
		file.announcedLeadingForAlliance[i] <- false
		file.announcedImminentWinForAlliance[i] <- false
	}

	while ( GetGameState() == eGameState.Playing )
	{
		int aOwnedPoints = Control_GetNumOwnedObjectivesByAlliance( ALLIANCE_A )
		int bOwnedPoints = Control_GetNumOwnedObjectivesByAlliance( ALLIANCE_B )
		int minNumOwnedPointsA = Control_GetMinHeldObjectivesToGenerateScore_ForAlliance( ALLIANCE_A )
		int minNumOwnedPointsB = Control_GetMinHeldObjectivesToGenerateScore_ForAlliance( ALLIANCE_B )

		if ( aOwnedPoints >= minNumOwnedPointsA )
		{
			int scoreIncrease = aOwnedPoints
			UpdateScoreForTeam( ALLIANCE_A, scoreIncrease )
		}

		if ( bOwnedPoints >= minNumOwnedPointsB )
		{
			int scoreIncrease = bOwnedPoints
			UpdateScoreForTeam( ALLIANCE_B, scoreIncrease )
		}

		//check if game should end
		int winningTeam = ALLIANCE_NONE

		if ( GamemodeUtility_GetWinningTeamOrAllianceScore() >= scoreLimit )
			winningTeam = GamemodeUtility_GetWinningAlliance( false )

		if ( winningTeam != ALLIANCE_NONE )
		{
			printt( "CONTROL: Match Ending due to Score, winning team is ", winningTeam )

			Control_SetWinner( winningTeam, eWinReason.SCORE_LIMIT )
			break
		}

		//track announcements
		for( int i = 0; i<2; i++ )
		{
			int otherAlliance = AllianceProximity_GetOtherAlliance( i )
			int currentScore = GetAllianceTeamsScore( i )
			int otherScore = GetAllianceTeamsScore( otherAlliance )
			bool isCurrentTeamWinning = currentScore > otherScore

			//halfway score, only play when an alliance is in the lead
			if ( !file.announcedHalfwayForAlliance[i] && isCurrentTeamWinning && ( currentScore >= scoreLimit * 0.5 ) &&  currentScore <= scoreLimit * 0.6)
			{
				PlayBattleChatterToAllianceDelayed( "bc_control_scoreHalfWin", i, 0 )
				PlayBattleChatterToAllianceDelayed( "bc_control_scoreHalfLoss", otherAlliance, 0 )
				file.announcedHalfwayForAlliance[i] <- true


					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( i, eCrowdNoiseMeterModifiers.CONTROL_HALFWAY_POINT_POSITIVE )
					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( otherAlliance, eCrowdNoiseMeterModifiers.CONTROL_HALFWAY_POINT_NEGATIVE )

			}

			//leading score if score differential at 75% for leader is greater than 20%
			if ( !file.announcedLeadingForAlliance[i] && isCurrentTeamWinning && ( currentScore >= scoreLimit * 0.75 ) && ( currentScore - otherScore >= scoreLimit * 0.2 ) )
			{
				PlayBattleChatterToAllianceDelayed( "bc_control_scoreInLead", i, 0 )
				PlayBattleChatterToAllianceDelayed( "bc_control_areBehind", otherAlliance, 0 )
				file.announcedLeadingForAlliance[i] <- true


					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( i, eCrowdNoiseMeterModifiers.CONTROL_HUGE_LEAD_POSITIVE )
					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( otherAlliance, eCrowdNoiseMeterModifiers.CONTROL_HUGE_LEAD_NEGATIVE )

			}

			//imminent win score at 90%
			if ( !file.announcedImminentWinForAlliance[i] && isCurrentTeamWinning && ( currentScore >= scoreLimit * 0.9 ) )
			{
				PlayBattleChatterToAllianceDelayed( "bc_control_scoreNearWin", i, 0 )
				PlayBattleChatterToAllianceDelayed( "bc_control_scoreNearLoss", otherAlliance, 0 )
				file.announcedImminentWinForAlliance[i] <- true


					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( i, eCrowdNoiseMeterModifiers.CONTROL_IMMINENT_WIN_POSITIVE )
					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( otherAlliance, eCrowdNoiseMeterModifiers.CONTROL_IMMINENT_WIN_NEGATIVE )

			}
		}

		//track music layers
		float controllerValue = 0.0

		int higherScore = GamemodeUtility_GetWinningTeamOrAllianceScore()
		if ( higherScore >= 0.8 * scoreLimit && !file.rampUpLevel1 )
		{
			controllerValue = 150.0
			file.isRampUp = true
			file.rampUpLevel1 = true
		}
		if ( higherScore >= 0.85 * scoreLimit && !file.rampUpLevel2 )
		{
			controllerValue = 250.0
			file.rampUpLevel2 = true
		}
		if ( higherScore >= 0.9 * scoreLimit && !file.rampUpLevel3 )
		{
			controllerValue = 350.0
			file.rampUpLevel3 = true
		}
		if ( higherScore >= 0.95 * scoreLimit && !file.rampUpLevel4 )
		{
			controllerValue = 450.0
			file.rampUpLevel4 = true
		}

		// If anything changed, update the controller value on the music ent
		if ( !file.isLockout && controllerValue > 0.0 )
		{
			CreateMusicEntityIfNotValid()
			if ( IsValid( file.musicEntity ) )
				file.musicEntity.SetSoundCodeControllerValue( controllerValue )
		}

		wait TIME_BETWEEN_SCORE_UPDATES
	}
}
#endif // SERVER

#if SERVER
void function UpdateObjectiveStateForTeam( ControlPointData data, int newState, int ownerAlliance, int capturingAlliance )
{
	//storing and checking old data
	int oldOwner = data.waypoint.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
	int oldCapturingAlliance = data.waypoint.GetWaypointInt( INT_CAPTURING_ALLIANCE )
	int oldObjectiveState = data.currentObjectiveState

	data.controlPointOwner = ownerAlliance
	data.waypoint.SetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER, data.controlPointOwner )
	data.waypoint.SetWaypointInt( INT_CAPTURING_ALLIANCE, capturingAlliance )
	data.waypoint.SetWaypointInt( CONTROL_INT_OBJ_NEUTRAL_ALLIANCE_OWNER, data.neutralPointOwnership )
	data.currentObjectiveState = newState

	// If a waypoint that could have previously been used as a spawn has had its owner change, see if any players need their spawns cancelled
	if ( ownerAlliance != oldOwner )
	{
		if ( Control_IsPointAnFOB( data.id ) ) // Objective A or C status has changed
		{
			// Go through all players on the alliance that would have its spawns potentially affected by this change and cancel their spawns if they can no longer spawn on this objective
			// The cancel logic will make sure they had a spawn on this objective
			int alliance = data.id == eControlWaypointTypeIndex.OBJECTIVE_A ? ALLIANCE_A : ALLIANCE_B
			array < entity > alliancePlayers = AllianceProximity_GetAllPlayersInAlliance( alliance, false )

			if ( alliance != ownerAlliance )
			{
				foreach ( player in alliancePlayers )
				{
					if ( IsValid( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
					{
						Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange( player, data.id )
						// Also go through and cancel spawns on Objective B for this alliance because they would lose the ability to spawn on that objective
						if ( Control_IsSpawningOnObjectiveBAllowed() )
							Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange( player, eControlWaypointTypeIndex.OBJECTIVE_B )
					}
				}
			}
		}
		else if ( Control_IsSpawningOnObjectiveBAllowed() ) // Objective B status has changed and spawning is allowed on Objective B
		{
			// Only cancel the spawns for the alliance that can no longer spawn on this objective
			array < entity > nonOwnerAlliancePlayers = AllianceProximity_GetAllPlayersInOtherAlliances( ownerAlliance, false )

			foreach ( player in nonOwnerAlliancePlayers )
			{
				if ( IsValid( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
					Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange( player, data.id )
			}
		}
	}

	//only send update to client if states actually changed
	if ( oldOwner == data.controlPointOwner && oldCapturingAlliance == capturingAlliance && oldObjectiveState == data.currentObjectiveState )
		return

	Control_RefreshObjectivePingsOnObjectiveStateChange( data )
	if ( data.currentObjectiveState == eControlPointObjectiveState.CONTROLLED && data.controlPointOwner != ALLIANCE_NONE )
	{
		//point controlled
		Control_AwardCapture( data, data.lastCapturingAlliance  )
	}

	//only send update from here if new state is CONTROLLED
	if ( data.currentObjectiveState != eControlPointObjectiveState.CONTROLLED )
		return

	data.fullControlConversionTime = Time()

	int newOwnerOwnedPoints = 0
	foreach( point in file.chosenVariantData.controlPoints )
	{
		if ( point.controlPointOwner == capturingAlliance )
			newOwnerOwnedPoints++
	}

	bool didCapturingAllianceBreakLockout = file.isLockout && newOwnerOwnedPoints == 1

	SendObjectiveStateAlertToPlayers( data.waypoint, data.currentObjectiveState, data.controlPointOwner, oldOwner, capturingAlliance, oldCapturingAlliance, didCapturingAllianceBreakLockout )

	// Send a message to players if a lockout should have triggered but didn't because of match state conditions
	if ( file.announcedLockoutUnavailable && Control_AllObjectivesOwnedByOneTeam() && !Control_isValidMatchStateForLockout( CONTROL_LOCKOUT_EVENT_DURATION, false ) && !file.isLockout )
	{
		foreach( player in GetConnectedPlayers() )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DisplayLockoutUnavailableWarning" )
		}
	}
}
#endif // SERVER

#if SERVER
//alert index: 0 for captured, 1 for neutralized
void function SendObjectiveCommentaryToAllPlayers( ControlPointData data, int alertIndex, int allianceToAward )
{
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	int commentaryBucket = -1

	// Play a special announcer line if all 3 points are held by 1 team but we are past the point where lockouts are triggered
	if ( alertIndex == CONTROL_ALERT_INDEX_CAPTURED_OBJECTIVE && !Control_isValidMatchStateForLockout( CONTROL_LOCKOUT_EVENT_DURATION, false ) && Control_AllObjectivesOwnedByOneTeam() )
	{
		commentaryBucket = eSurvivalCommentaryBucket.CONTROL_ALL_ZONES_OWNED
	}
	else if ( !Control_AllObjectivesOwnedByOneTeam() )// Don't play objective captured lines if we are playing all objectives owned by one team or lockout lines
	{
		switch( alertIndex )
		{
			case CONTROL_ALERT_INDEX_CAPTURED_OBJECTIVE: //captured
			switch( data.id )
			{
				case eControlWaypointTypeIndex.OBJECTIVE_A:
					commentaryBucket = eSurvivalCommentaryBucket.CONTROL_A_CAPTURED
					break
				case eControlWaypointTypeIndex.OBJECTIVE_B:
					commentaryBucket = eSurvivalCommentaryBucket.CONTROL_B_CAPTURED
					break
				case eControlWaypointTypeIndex.OBJECTIVE_C:
					commentaryBucket = eSurvivalCommentaryBucket.CONTROL_C_CAPTURED
					break
				default:
					Warning( "CONTROL: Running SendObjectiveCommentaryToAllPlayers function with a captured alertIndex but an valid objective id: %i", data.id )
					break
			}
			break
			case CONTROL_ALERT_INDEX_NEUTRALIZED_OBJECTIVE: //neutralized
			switch( data.id )
			{
				case eControlWaypointTypeIndex.OBJECTIVE_A:
					commentaryBucket = eSurvivalCommentaryBucket.CONTROL_A_NEUTRALIZED
					break
				case eControlWaypointTypeIndex.OBJECTIVE_B:
					commentaryBucket = eSurvivalCommentaryBucket.CONTROL_B_NEUTRALIZED
					break
				case eControlWaypointTypeIndex.OBJECTIVE_C:
					commentaryBucket = eSurvivalCommentaryBucket.CONTROL_C_NEUTRALIZED
					break
				default:
					Warning( "CONTROL: Running SendObjectiveCommentaryToAllPlayers function with a neutralized alertIndex but an valid objective id: %i", data.id )
					break
			}
			break
			default:
				Warning( "CONTROL: Running SendObjectiveCommentaryToAllPlayers function with an invalid alertIndex: %i", alertIndex )
				break
		}
	}

	if ( commentaryBucket != -1 )
		thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( commentaryBucket ), ANNOUNCER_DIALOGUE_DELAY )
}
#endif // SERVER

#if SERVER
void function SendObjectiveStateAlertToPlayers( entity wp, int objectiveState, int currentOwner, int lastOwner, int currentCapturingAlliance, int oldCapturingAlliance, bool didCapturingAllianceBreakLockout )
{
	if ( !IsValid( wp ) )
		return

	foreach( player in GetConnectedPlayers() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_ProcessObjectiveStateChange", wp, objectiveState, currentOwner, lastOwner, currentCapturingAlliance, oldCapturingAlliance, didCapturingAllianceBreakLockout )
}
#endif // SERVER

#if SERVER
void function AwardPointsForBounty( ControlPointData data )
{
	if ( !IsValid( data.waypoint ) )
		return

	// Award Score for the bounty
	int bountyAmount = int( data.waypoint.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) )
	UpdateScoreForTeam( data.controlPointOwner, bountyAmount )

	if ( data.waypoint.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) > 0 )
	{
		Control_AwardBounty( data, data.controlPointOwner )
		SendBountyClaimedAlertToPlayers( data.waypoint, bountyAmount, data.controlPointOwner )
	}

	//reset bounty
	data.waypoint.SetWaypointFloat( FLOAT_BOUNTY_AMOUNT, 0 )
	data.hasBountyBeenSet = false

	PlayBattleChatterToAllianceDelayed( "bc_control_bountyCaptured", data.controlPointOwner )
	PlayBattleChatterToAllianceDelayed( "bc_control_bountyLost", data.controlPointOwner == 0 ? 1 : 0, LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_SHORT )
}
#endif // SERVER

#if SERVER
void function SendBountyClaimedAlertToPlayers( entity wp, int bountyAmount, int capturingAlliance )
{
	if ( !IsValid( wp ) )
		return

	foreach( player in GetConnectedPlayers() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_BountyClaimedAlert", wp, bountyAmount, capturingAlliance )
}
#endif // SERVER

#if SERVER
void function SendBountyActiveAlertToPlayers( entity wp, int waypointID )
{
	if ( !IsValid( wp ) )
		return

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	foreach( player in GetConnectedPlayers() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_BountyActiveAlert", wp )

	int finalIndex = waypointID

	//random chance for generic announcement
	if ( RandomInt( 100 ) < 35 )
		finalIndex = -1

	string commentaryLineToPlay
	switch( finalIndex )
	{
		case eControlWaypointTypeIndex.OBJECTIVE_A:
			commentaryLineToPlay = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_CAPTURE_BONUS_A )
			break
		case eControlWaypointTypeIndex.OBJECTIVE_B:
			commentaryLineToPlay = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_CAPTURE_BONUS_B )
			break
		case eControlWaypointTypeIndex.OBJECTIVE_C:
			commentaryLineToPlay = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_CAPTURE_BONUS_C )
			break
		default:
			commentaryLineToPlay = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_CAPTURE_BONUS_GENERIC )
			break
	}

	thread PlayCommentaryLineToAllPlayers( commentaryLineToPlay )
	// Play a reaction to the announcer line regarding the sponsorship of the event
	Control_PlayReactDialogueToSponsorshipCommentary( commentaryLineToPlay )
}
#endif // SERVER

#if SERVER
// Update the score for an alliance and then update the score board to reflect the changes
void function UpdateScoreForTeam( int allianceIndex, int scoreIncrease )
{
	#if DEV
		if ( file.isScoringPaused )
			return
	#endif // DEV

	int newScore = minint( GetAllianceTeamsScore( allianceIndex ) + scoreIncrease, GetScoreLimit_FromPlaylist() )
	SetAllianceTeamsScore( allianceIndex, newScore )

	Control_UpdateScoreBoardInfo()
}
#endif // SERVER

#if SERVER
void function Control_AwardKill( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValidPlayer( attacker ) || victim == attacker )
		return

	if ( CONTROL_TEAMSCORE_FOR_KILL > 0 )
	{
		int allianceIndex = AllianceProximity_GetAllianceFromTeam( attacker.GetTeam() )
		int waypointIndex = allianceIndex == ALLIANCE_A ? INT_ALLIANCE_A_SCORE : INT_ALLIANCE_B_SCORE

		UpdateScoreForTeam( allianceIndex, CONTROL_TEAMSCORE_FOR_KILL )
		Control_AddScore( attacker, CONTROL_SCORINGEVENT_ELIMINATION, CONTROL_TEAMSCORE_FOR_KILL, false, false, victim )
	}

	if ( Control_GetIsWeaponEvoEnabled() )
	{
		Control_AddScore( attacker, CONTROL_EXPEVENT_ELIMINATION, GetCurrentPlaylistVarInt( "exp_value_kill", 20 ), true, true, victim )
		Control_AwardHigherTierEnemyKillExp( attacker, victim )
		Control_AwardAttackerKillBonusExp( attacker )
		Control_AwardDefenderKillBonusExp( attacker, victim )
		Control_AwardWithSquadScoreBonusExp( attacker )
		Control_AwardEXPLeaderKill( attacker, victim )
	}
}
#endif // SERVER

#if SERVER
void function Control_AwardAssist( entity attacker, entity victim )
{
	if ( !IsValidPlayer( attacker ) || victim == attacker )
		return

	if ( Control_GetIsWeaponEvoEnabled() )
	{
		Control_AddScore( attacker, CONTROL_EXPEVENT_ASSIST, GetCurrentPlaylistVarInt( "exp_value_kill_assist", 20 ), true, true, victim )
		Control_AwardHigherTierEnemyKillExp( attacker, victim )
		Control_AwardAttackerKillBonusExp( attacker )
		Control_AwardDefenderKillBonusExp( attacker, victim )
		Control_AwardWithSquadScoreBonusExp( attacker )
		Control_AwardEXPLeaderKill( attacker, victim )
	}
}
#endif // SERVER

#if SERVER
void function Control_AwardCapture( ControlPointData data, int allianceToAward )
{
	SendObjectiveCommentaryToAllPlayers( data, CONTROL_ALERT_INDEX_CAPTURED_OBJECTIVE, allianceToAward )

	// Test to see if we should trigger a Lockout ( all objectives are owned by one team )
	if ( Control_LockoutStartValidation( CONTROL_LOCKOUT_EVENT_DURATION ) )
	{
		TimedEvents_TriggerTimedEventByEventType( eControlTimedEventType.LOCKOUT )


			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward, eCrowdNoiseMeterModifiers.CONTROL_LOCKOUT_POSITIVE )
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward == 0 ? 1 : 0, eCrowdNoiseMeterModifiers.CONTROL_LOCKOUT_NEGATIVE )

	}
	else // If this capture doesn't trigger a lockout, play capture dialogue
	{
		PlayBattleChatterToAllianceDelayed( "bc_control_capturedFriendly", allianceToAward )
		PlayBattleChatterToAllianceDelayed( "bc_control_capturedEnemy", allianceToAward == 0 ? 1 : 0, LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_SHORT )


			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward, eCrowdNoiseMeterModifiers.CONTROL_CAPTURE_POSITIVE )
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward == 0 ? 1 : 0, eCrowdNoiseMeterModifiers.CONTROL_CAPTURE_NEGATIVE )

	}

	if ( Control_GetIsWeaponEvoEnabled() )
	{
		// Award exp to players when their teammates capture a point
		foreach( player in GetPlayerArray_AliveConnected() )
		{
			if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == allianceToAward )
			{
				Control_AddScore( player, CONTROL_EXPEVENT_TEAM_CAPTURED, GetCurrentPlaylistVarInt( "exp_value_team_capture", 25 ), true, true )
			}
		}
	}

	foreach( player in data.playersInControlPoint )
	{
		if ( IsValid( player ) && AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == allianceToAward )
		{
			//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_CAPTURED, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME )
			if ( Control_GetIsWeaponEvoEnabled() )
			{
				Control_AddScore( player, CONTROL_EXPEVENT_CAPTURED, GetCurrentPlaylistVarInt( "exp_value_capture", 50 ), true, true )
				Control_AwardWithSquadScoreBonusExp( player )
			}
			Control_AddScore( player, CONTROL_SCORINGEVENT_CAPTURED, CONTROL_TEAMSCORE_PER_POINT, false, false )
			StatsHook_Control_OnObjectiveCaptured( player )

			GameSummarySquadData squadData = GameSummary_GetPlayerData( player )
			if ( ( eControlStat.OBJECTIVES_CAPTURED in squadData.modeMetaData ) == false )
				squadData.modeMetaData[ eControlStat.OBJECTIVES_CAPTURED ] <- 0

			squadData.modeMetaData[ eControlStat.OBJECTIVES_CAPTURED ] += 1
		}
	}
}
#endif // SERVER

#if SERVER
// Award Control Score and Exp for winning a Capture Bonus
void function Control_AwardBounty( ControlPointData data, int allianceToAward )
{
	int bountyAmount = int( data.waypoint.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) )
	// Award exp to all players on the team that gained the bonus
	foreach( player in GetPlayerArray_AliveConnected() )
	{
		if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == allianceToAward )
		{
			Control_AddScore( player, CONTROL_SCORINGEVENT_BOUNTYCLAIMED, bountyAmount, false, false )
			//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_CAPTURED, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME, CONTROL_PINEVENT_CAPTUREBONUS )
			StatsHook_Control_OnCaptureBonusClaimedByTeam( player )
			AddXP( player, eXPType.BONUS_OBJECTIVES_COMPLETED )

			if ( Control_GetIsWeaponEvoEnabled() )
			{
				Control_AddScore( player, CONTROL_EXPEVENT_BOUNTYCLAIMED, bountyAmount, true, true )
			}
		}
	}

	if ( allianceToAward == ALLIANCE_A )
	{
		file.team0ScoreFromBonus += bountyAmount
	}
	else
	{
		file.team1ScoreFromBonus += bountyAmount
	}


		int otherAlliance = AllianceProximity_GetOtherAlliance( allianceToAward )
		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward, eCrowdNoiseMeterModifiers.CONTROL_CAPTURE_BONUS_POSITIVE )
		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( otherAlliance, eCrowdNoiseMeterModifiers.CONTROL_CAPTURE_BONUS_NEGATIVE )

}
#endif // SERVER

#if SERVER
// Award exp for neutralizing a point
void function Control_AwardNeutralize( ControlPointData data, int allianceToAward )
{
	// No team neutralized the point, the owner is still neutral
	if ( allianceToAward == ALLIANCE_NONE )
		return

	SendObjectiveCommentaryToAllPlayers( data, CONTROL_ALERT_INDEX_NEUTRALIZED_OBJECTIVE, allianceToAward )
	PlayBattleChatterToAllianceDelayed( "bc_control_neutralizedFriendly", allianceToAward )
	PlayBattleChatterToAllianceDelayed( "bc_control_neutralizedEnemy", allianceToAward == 0 ? 1 : 0, LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_SHORT )


		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward, eCrowdNoiseMeterModifiers.CONTROL_NEUTRALIZE_POSITIVE )
		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward == 0 ? 1 : 0, eCrowdNoiseMeterModifiers.CONTROL_NEUTRALIZE_NEGATIVE )


	if ( Control_GetIsWeaponEvoEnabled() )
	{
		// Award exp to players when their teammates neutralize a point
		foreach ( player in GetPlayerArray_AliveConnected() )
		{
			if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == allianceToAward )
			{
				Control_AddScore( player, CONTROL_EXPEVENT_TEAM_NEUTRALIZED, GetCurrentPlaylistVarInt( "exp_value_team_neutralize", 25 ), true, true )
			}
		}
	}

	// Award exp to the players that neutralized a point
	foreach( player in data.playersInControlPoint )
	{
		if ( IsValid( player ) && AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == allianceToAward )
		{
			//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_NEUTRALIZED, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME )
			if ( Control_GetIsWeaponEvoEnabled() )
			{
				Control_AddScore( player, CONTROL_EXPEVENT_NEUTRALIZED, GetCurrentPlaylistVarInt( "exp_value_neutralize", 50 ), true, true )
				Control_AwardWithSquadScoreBonusExp( player )
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Award exp for contesting a point
void function Control_AwardContesting( ControlPointData data )
{
	int allianceAPlayerCount = 0
	int allianceBPlayerCount = 0

	// Count how many players from each alliance are on the point
	foreach( player in data.playersInControlPoint )
	{
		IsValid( player )
		{
			if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_A )
			{
				allianceAPlayerCount++
			}
			else
			{
				allianceBPlayerCount++
			}
		}
	}

	// Determine what exp values should be awarded to players depending on the status of the point
	foreach( player in data.playersInControlPoint )
	{
		if ( !IsValid( player ) )
			continue

		int numOpposingTeamPlayers = AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_A ? allianceBPlayerCount : allianceAPlayerCount
		int numSameTeamPlayers = AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_A ? allianceAPlayerCount : allianceBPlayerCount

		// Handle Contesting and Capturing the point
		if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) != data.controlPointOwner )
		{
			// If the player is capturing a point give them exp
			if ( numSameTeamPlayers > numOpposingTeamPlayers )
			{
				//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_CAPTURING, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME )
				int capturingEXPVal = GetCurrentPlaylistVarInt( "exp_value_capturing", 5 )
				if ( capturingEXPVal > 0 && Control_GetIsWeaponEvoEnabled() )
				{
					Control_AddScore( player, CONTROL_EXPEVENT_CAPTURING, capturingEXPVal, true, true )
					Control_AwardWithSquadScoreBonusExp( player )
				}
			}
			else if ( numOpposingTeamPlayers >= numSameTeamPlayers  )// If the player is contesting the point award exp
			{
				//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_CONTESTING, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME )
				int contestingEXPVal = GetCurrentPlaylistVarInt( "exp_value_contesting", 10 )
				if ( contestingEXPVal > 0 && Control_GetIsWeaponEvoEnabled() )
				{
					Control_AddScore( player, CONTROL_EXPEVENT_CONTESTING, contestingEXPVal, true, true )
					Control_AwardWithSquadScoreBonusExp( player )
				}
			}
		}

		// Award exp if the player is defending a point
		if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == data.controlPointOwner )
		{
			if ( numOpposingTeamPlayers == 0 ) // Award base exp if the point has no enemies on it
			{
				//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_DEFENDING, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME )
				int defendingEXPVal = GetCurrentPlaylistVarInt( "exp_value_defending", 0 )
				if (  defendingEXPVal > 0 && Control_GetIsWeaponEvoEnabled() )
				{
					Control_AddScore( player, CONTROL_EXPEVENT_DEFENDING, defendingEXPVal, true, true )
					Control_AwardWithSquadScoreBonusExp( player )
				}
			}
			else if ( numOpposingTeamPlayers > 0 ) // Award more exp if there are enemies on the point
			{
				//PIN_ControlGameObjective( player, CONTROL_PINEVENT_OBJECTIVENAME_PRETEXT + data.name, string( data.id ), CONTROL_PINEVENT_DEFENDING_ACTIVEPOINT, Control_GetObjectiveProgressPercentIntFromFloat( data.controlPointPercent ), CONTROL_OBJECTIVE_SCRIPTNAME )
				int defendingActiveEXPVal = GetCurrentPlaylistVarInt( "exp_value_defending_active", 10 )
				if ( defendingActiveEXPVal > 0 && Control_GetIsWeaponEvoEnabled() )
				{
					Control_AddScore( player, CONTROL_EXPEVENT_DEFENDING_ACTIVEPOINT, defendingActiveEXPVal, true, true )
					Control_AwardWithSquadScoreBonusExp( player )
				}
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Award Control Score and Exp when a team captures a point causing a lockout to be canceled
void function Control_AwardLockoutBroken( int allianceToAward )
{
	// Award the team points for breaking Lockout
	UpdateScoreForTeam( allianceToAward,CONTROL_TEAMSCORE_LOCKOUTBROKEN )


		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward, eCrowdNoiseMeterModifiers.CONTROL_LOCKOUT_BROKEN_POSITIVE )
		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( allianceToAward == 0 ? 1 : 0, eCrowdNoiseMeterModifiers.CONTROL_LOCKOUT_BROKEN_NEGATIVE )


	// Award exp to all players on the team that broke the lockout
	foreach( player in GetPlayerArray_AliveConnected() )
	{
		if ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == allianceToAward )
		{
			Control_AddScore( player, CONTROL_SCORINGEVENT_LOCKOUTBROKEN, CONTROL_TEAMSCORE_LOCKOUTBROKEN, false, false )

			if ( Control_GetIsWeaponEvoEnabled() && CONTROL_TEAMSCORE_LOCKOUTBROKEN > 0 )
				Control_AddScore( player, CONTROL_EXPEVENT_LOCKOUTBROKEN, CONTROL_TEAMSCORE_LOCKOUTBROKEN, true, true )
		}
	}

	if ( allianceToAward == ALLIANCE_A )
	{
		file.team0ScoreFromBonus += CONTROL_TEAMSCORE_LOCKOUTBROKEN
	}
	else
	{
		file.team1ScoreFromBonus += CONTROL_TEAMSCORE_LOCKOUTBROKEN
	}
}
#endif // SERVER

#if SERVER
// Add player game score or Exp and display a message on screen
void function Control_AddScore( entity player, string scoreEventName, int scoreValue, bool isExpEvent, bool isPersonalExpEvent, entity associatedEntity = null )
{
	if ( !IsValid( player ) )
		return

	// Get score event info for the Control Specific message popup
	ScoreEvent event = GetScoreEvent( scoreEventName )
	int associatedEntityHandle = 0
	if ( associatedEntity != null )
		associatedEntityHandle = associatedEntity.GetEncodedEHandle()

	if ( isExpEvent )
	{
		int preExpGivenTier = Control_GetPlayerExpTier( player, false )
		int preExpGivenTierExp = Control_GetPlayerExpTotal( player, true, preExpGivenTier )

		player.SetPlayerNetInt( "control_CurrentExpTotal", Control_GetPlayerExpTotal( player ) + scoreValue )
		thread Control_EXPLeaderUpdate_Thread( player, Control_GetPlayerExpTotal( player ) )

		if ( isPersonalExpEvent )
		{
			player.SetPlayerNetInt( "control_PersonalScore", player.GetPlayerNetInt( "control_PersonalScore" ) + scoreValue )
			// Track player personal score with PIN Data
			SurvivalSquadPINData squadPINData = GetSurvivalSquadPINData( player.GetTeam() )
			squadPINData.memberScores[ player.GetTeamMemberIndex() ] += scoreValue
			StatsHook_Control_PersonalEXPPointsEarned( player, scoreValue )

			GameSummarySquadData squadData = GameSummary_GetPlayerData( player )
			if ( ( eControlStat.RATING in squadData.modeMetaData ) == false )
				squadData.modeMetaData[ eControlStat.RATING ] <- 0

			squadData.modeMetaData[ eControlStat.RATING ] += scoreValue
		}

		// Check if the awarded Exp was enough to evolve the players equipment
		Control_AwardedPlayerExp( player, scoreValue, preExpGivenTierExp, preExpGivenTier )
	}

	// Display a popup message
	Remote_CallFunction_NonReplay( player, "ServerCallback_ControlScoreEvent", ScoreEvent_GetEventId( event ), isExpEvent, scoreValue, associatedEntityHandle )
}
#endif // SERVER

#if SERVER
// Deduct Exp points from the players total and display a popup message
void function Control_SubtractExp( entity player, int expLoss, string scoreEvent )
{
	if ( !IsValid( player ) )
		return

	int finalExpLoss = 0
	int finalPersonalScoreLoss = 0
	int currentExpProgress = Control_GetPlayerExpTotal( player )
	int currentTotalPersonalScore = player.GetPlayerNetInt( "control_PersonalScore" )

	if ( currentExpProgress > 0 )
	{
		finalExpLoss = minint( expLoss, currentExpProgress )
		player.SetPlayerNetInt( "control_CurrentExpTotal", currentExpProgress - finalExpLoss )
		currentExpProgress = Control_GetPlayerExpTotal( player )
	}

	// Subtract from Control Personal Score
	if ( currentTotalPersonalScore > 0 && scoreEvent != CONTROL_EXPEVENT_GUNRACK_PURCHASE && scoreEvent != CONTROL_EXPEVENT_EXPRESET )
	{
		finalPersonalScoreLoss = minint( expLoss, currentTotalPersonalScore )
		player.SetPlayerNetInt( "control_PersonalScore", currentTotalPersonalScore - finalPersonalScoreLoss )
	}

	// Get score event info for the Control Specific message popup
	ScoreEvent event = GetScoreEvent( scoreEvent )
	int associatedEntityHandle = 0

	// Display a popup message
	Remote_CallFunction_NonReplay( player, "ServerCallback_ControlScoreEvent", ScoreEvent_GetEventId( event ), true, finalExpLoss, associatedEntityHandle )
}
#endif // SERVER

#if SERVER
// Get a points value with the performed action with Squad multiplier if applicable
void function Control_AwardWithSquadScoreBonusExp( entity player )
{
	int withSquadBonusExpVal = GetCurrentPlaylistVarInt( "exp_value_playing_with_squad", 5 )
	if ( !Control_GetIsWeaponEvoEnabled() || !IsValid( player ) ||  withSquadBonusExpVal <= 0 || Bleedout_IsBleedingOut( player ) )
		return

	bool isPlayerWithSquad = false
	// Determine if the player is near a squadmate to decide if we should apply the action performed with squad multiplier
	foreach( squadmate in GetPlayerArrayOfTeam_AliveConnected( player.GetTeam() ) )
	{
		if ( squadmate != player && IsPositionWithinRadius( Control_GetMaxDistFromSquadForOnSquadMultiplier(), squadmate.GetOrigin(), player.GetOrigin() ) )
		{
			isPlayerWithSquad = true
			break
		}
	}

	if ( isPlayerWithSquad )
		Control_AddScore( player, CONTROL_EXPEVENT_WITHSQUADBONUS, withSquadBonusExpVal, true, true )
}
#endif // SERVER

#if SERVER
// Award bonus Exp to a player defending a capture point against an enemy
void function Control_AwardAttackerKillBonusExp( entity player )
{
	if ( !IsValid( player ) )
		return

	bool isPlayerDefender = false
	// Determine if the player is in a control point to decide if we should award a killed attacker Bonus
	foreach( point in file.chosenVariantData.controlPoints )
	{
		if ( point.playersInControlPoint.contains( player ) && point.controlPointOwner != ALLIANCE_NONE && AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == point.controlPointOwner )
		{
			isPlayerDefender = true
			break
		}
	}

	if ( isPlayerDefender )
	{
		StatsHook_Control_OnKilledObjectiveEnemy( player, true )
		int killAttackerEXPVal = GetCurrentPlaylistVarInt( "exp_value_kill_attacker", 15 )
		if ( killAttackerEXPVal > 0 && Control_GetIsWeaponEvoEnabled() && !Bleedout_IsBleedingOut( player ) )
			Control_AddScore( player, CONTROL_EXPEVENT_ATTACKERKILL, killAttackerEXPVal, true, true )
	}
}
#endif // SERVER

#if SERVER
// Award Bonus Exp for killing a player that was defending a Capture Point
void function Control_AwardDefenderKillBonusExp( entity player, entity victim )
{
	if ( !IsValid( player ) || !IsValid( victim ) )
		return

	bool isVictimDefender = false
	// Determine if the victim is in a control point to decide if we should award a killed defender Bonus
	foreach( point in file.chosenVariantData.controlPoints )
	{
		if ( point.playersInControlPoint.contains( victim ) && point.controlPointOwner != ALLIANCE_NONE && AllianceProximity_GetAllianceFromTeam( victim.GetTeam() ) == point.controlPointOwner )
		{
			isVictimDefender = true
			break
		}
	}

	if ( isVictimDefender )
	{
		StatsHook_Control_OnKilledObjectiveEnemy( player, false )
		int killDefenderEXPVal = GetCurrentPlaylistVarInt( "exp_value_kill_defender", 15 )
		if ( killDefenderEXPVal > 0 && Control_GetIsWeaponEvoEnabled() && !Bleedout_IsBleedingOut( player ) )
			Control_AddScore( player, CONTROL_EXPEVENT_DEFENDERKILL, killDefenderEXPVal, true, true )
	}
}
#endif // SERVER

#if SERVER
// Award players bonus points for killing a higher tier enemy
void function Control_AwardHigherTierEnemyKillExp( entity player, entity victim )
{
	if ( !IsValid( player ) || !IsValid( victim ) )
		return

	int tierDifference = Control_GetPlayerExpTier( victim ) - Control_GetPlayerExpTier( player )
	StatsHook_Control_OnKilledHigherTierEnemy( player, tierDifference )

	if ( Control_GetIsWeaponEvoEnabled() && !Bleedout_IsBleedingOut( player ) )
	{
		if ( tierDifference >= 2 )
		{
			Control_AddScore( player, CONTROL_EXPEVENT_REALLYHIGHTIERKILL, GetCurrentPlaylistVarInt( "exp_value_kill_reallyhigh_tier", 25 ), true, true )
		}
		else if ( tierDifference > 0 )
		{
			Control_AddScore( player, CONTROL_EXPEVENT_HIGHTIERKILL, GetCurrentPlaylistVarInt( "exp_value_kill_high_tier", 15 ), true, true )
		}
	}
}
#endif // SERVER

#if SERVER
// Award players bonus points for killing the EXP Leader
void function Control_AwardEXPLeaderKill( entity player, entity victim )
{
	if ( !IsValid( player ) || !IsValid( victim ) )
		return

	if ( Control_GetIsWeaponEvoEnabled() && GradeFlagsHas( victim, eTargetGrade.EXP_LEADER ) && !Bleedout_IsBleedingOut( player ) )
		Control_AddScore( player, CONTROL_EXPEVENT_KILLEXPLEADER, GetCurrentPlaylistVarInt( "exp_value_kill_expleader", 50 ), true, true, victim )
}
#endif // SERVER

#if SERVER
const int CONTROL_EXPLEADER_THRESHOLD_DECAY_AMOUNT = 10
const int CONTROL_EXPLEADER_SCORE_DIFFERENCE_TO_BEAT_OLD_LEADER = 5
const float CONTROL_EXPLEADER_THRESHOLD_DECAY_RATE = 5.0
const float CONTROL_EXPLEADER_TIME_BEFORE_THRESHOLD_DECAY = 90.0
// If nobody is able to beat the last EXP leaders score, start decreasing the score required to be the Exp leader until we hit the default threshold
void function Control_UpdateEXPLeaderEXPThreshold_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	// End this thread early if we get a new exp Leader
	svGlobal.levelEnt.EndSignal( "Control_NewEXPLeaderFound" )

	// On thread end, if there is a new kill leader, set their exp total as the new exp leader threshold
	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( file.expLeader ) && Control_GetPlayerExpTotal( file.expLeader ) >= Control_GetDefaultEXPLeaderEXPThreshold() )
				file.expLeaderExpThreshold = Control_GetPlayerExpTotal( file.expLeader )
		}
	)

	wait CONTROL_EXPLEADER_TIME_BEFORE_THRESHOLD_DECAY

	int currentThreshold = Control_GetEXPLeaderEXPThreshold()
	while ( Control_GetEXPLeaderEXPThreshold() > Control_GetDefaultEXPLeaderEXPThreshold() )
	{
		currentThreshold = maxint( ( currentThreshold - CONTROL_EXPLEADER_THRESHOLD_DECAY_AMOUNT ), Control_GetDefaultEXPLeaderEXPThreshold() )
		file.expLeaderExpThreshold = currentThreshold
		wait CONTROL_EXPLEADER_THRESHOLD_DECAY_RATE
	}

	file.expLeaderExpThreshold = Control_GetDefaultEXPLeaderEXPThreshold()
}
#endif // SERVER

#if SERVER
const float CONTROL_MINTIME_BETWEEN_EXPLEADERS = 0.2
// Update Ratings Leader
void function Control_EXPLeaderUpdate_Thread( entity player, int exp )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	if ( !player.IsPlayer() )
		return

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	entity expLeader = file.expLeader
	int expGoal = Control_GetEXPLeaderEXPThreshold() // must be greater than or equal to this

	// If the player is the current expLeader and their score has increased, update the exp threshold for exp leader
	if ( IsValid( expLeader ) && player == expLeader )
	{
		StatsHook_Control_OnEXPEarnedWhileEXPLeader( player, exp )
		if ( exp > expGoal )
            file.expLeaderExpThreshold = exp

		return
	}
	else if ( !IsValid( expLeader ) ) // If there is no kill leader, wait for the end of the frame and check who has the highest Exp in case multiple players got a bunch of Exp at the same time
	{
		WaitEndFrame()

		int highestExp = expGoal
		entity highestScoringPlayer
		foreach ( livingPlayer in GetPlayerArray_Alive() )
		{
			if ( IsValid( livingPlayer ) && Control_GetPlayerExpTotal( livingPlayer ) >= highestExp )
			{
				highestExp = Control_GetPlayerExpTotal( livingPlayer )
				highestScoringPlayer = livingPlayer
			}
		}

		// We switch the player over to be the highest scoring player so they get crowned Ratings Leader in the following logic
		if ( IsValid( highestScoringPlayer ) )
		{
			player = highestScoringPlayer
			exp = highestExp
		}
		else
		{
			return
		}
	}
	else
	{
		// If we are not the kill leader already, wait a frame before checking if we beat their score. There are events that are awarded to all players on the same team at the same time.
		// This helps prevent the kill leader flip flopping rapidly in the case where both players are getting the same kill leader events
		WaitFrame()

		expGoal = Control_GetEXPLeaderEXPThreshold()

		// If the current exp leader is alive, the new one must exceed their exp by a set threshold
		if ( IsValid( expLeader ) && IsAlive( expLeader ) )
            expGoal += CONTROL_EXPLEADER_SCORE_DIFFERENCE_TO_BEAT_OLD_LEADER

		if ( exp < expGoal )
			return
	}

	// We have a new exp leader, ensure there has been enough time since the last time a leader was crowned ( don't want spam since many Exp events can come in at the same time )
	if ( Time() <= file.timeOfLastExpLeaderSwitch + CONTROL_MINTIME_BETWEEN_EXPLEADERS || !IsValid( player ) )
		return

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	file.timeOfLastExpLeaderSwitch = Time()
	// Clear kill leader flags on the old exp leader and award them Xp for time as EXP Leader
	if ( IsValid( expLeader ) && GradeFlagsHas( expLeader, eTargetGrade.EXP_LEADER ) )
		GradeFlagsClear( expLeader, eTargetGrade.EXP_LEADER )

	if ( !IsValid( player ) )
		return

	// Set the player as the new exp leader
	file.expLeader = player
    file.expLeaderExpThreshold = exp
	GradeFlagsSet( player, eTargetGrade.EXP_LEADER )
	//PIN_PlayerControlEXPLeader( player )
	StatsHook_Control_OnBecomeEXPLeader( player )

	// If this is the first time the player became Exp Leader, award XP
	if ( GetXPEventCount( player, eXPType.RATINGS_LEADER ) == 0 )
		AddXP( player, eXPType.RATINGS_LEADER )


		int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
		int enemyAlliance = AllianceProximity_GetOtherAlliance( playerAlliance )

		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( playerAlliance, eCrowdNoiseMeterModifiers.CONTROL_NEW_RATINGS_LEADER_POSITIVE )
		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( enemyAlliance, eCrowdNoiseMeterModifiers.CONTROL_NEW_RATINGS_LEADER_NEGATIVE )


	string commentaryRef = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_NEW_RATINGS_LEADER )
	thread PlayCommentaryLineWithSquadBasedResponse( commentaryRef, "bc_control_squadmatesBecomesRatingsLeader", "", player, "bc_control_iBecomeRatingsLeader", -1, true )

	array < entity > allPlayersAndSpectatorsArray = GetPlayerArrayIncludingSpectators()

    // This sucks a bit. This is the only place where we show a players real Exp total. The thing is, the real Exp total includes Exp that is given by default to get players starting at Tier 2.
    // So, before we display the amount to players first subtract that hidden amount that is given before players spawn. The maxint is just there to protect in case somehow subtracting would give us 0 or a negative number.
    int defaultExpAmountAwardedToPlayerOnSpawn = Control_GetExpThresholdForTier( Control_GetDefaultWeaponTier(), player )
    int expToDisplay = maxint( defaultExpAmountAwardedToPlayerOnSpawn, exp - defaultExpAmountAwardedToPlayerOnSpawn )
	foreach ( arrayPlayer in allPlayersAndSpectatorsArray )
	{
		if ( IsValid( arrayPlayer ) )
			Remote_CallFunction_NonReplay( arrayPlayer, "ServerCallback_Control_NewEXPLeader", player, expToDisplay )
	}

	svGlobal.levelEnt.Signal( "Control_NewEXPLeaderFound" )
}
#endif // SERVER

#if SERVER
// Get the percentage of objective capture for Pin Data in int form ( the float comes in as a fraction so 10% would be 0.1, we just multiply that and cast to int so it doesn't appear as 0)
int function Control_GetObjectiveProgressPercentIntFromFloat( float progressPercent )
{
	const int PERCENTAGE_MULTIPLIER = 100
	return int( progressPercent * PERCENTAGE_MULTIPLIER )
}
#endif // SERVER

#if SERVER
const float WINNER_DETERMINED_WAIT_DURATION = 4.0
void function Control_SetWinner( int winningAlliance, int victoryCondition )
{
	#if DEV
		if ( GetConVarInt( "mp_enablematchending" ) == 0 )
		{
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Set winner function triggered but ignoring because mp_enablematchending is set to false" )

			return
		}
	#endif // DEV


	if ( victoryCondition == eWinReason.LOCKOUT )
	{
		UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( winningAlliance, eCrowdNoiseMeterModifiers.WIN_BY_LARGE_MARGIN_POSITIVE )
	}
	else if ( victoryCondition == eWinReason.SCORE_LIMIT )
	{
		int scoreDeltaForMediumWin = GetCurrentPlaylistVarInt( "score_delta_for_medium_win", 1 )
		int scoreDeltaForLargeWin = GetCurrentPlaylistVarInt( "score_delta_for_large_win", 1 )
		int scoreLimit = GetScoreLimit_FromPlaylist()

		array< int > allTeamsOrAlliances = AllianceProximity_GetAllTeamsOrAlliances()
		allTeamsOrAlliances.fastremovebyvalue( winningAlliance )

		int closestScore = 0
		foreach( currentTeamOrAlliance in allTeamsOrAlliances )
		{
			int currentTeamOrAllianceScore = GamemodeUtility_GetTeamOrAllianceScore( currentTeamOrAlliance )
			closestScore = maxint( closestScore, currentTeamOrAllianceScore )
		}

		int scoreDelta = scoreLimit - closestScore
		if ( scoreDelta >= scoreDeltaForLargeWin )
		{
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( winningAlliance, eCrowdNoiseMeterModifiers.WIN_BY_LARGE_MARGIN_POSITIVE )
		}
		else if ( scoreDelta >= scoreDeltaForMediumWin )
		{
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( winningAlliance, eCrowdNoiseMeterModifiers.WIN_BY_MEDIUM_MARGIN_POSITIVE )
		}
		else
		{
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( winningAlliance, eCrowdNoiseMeterModifiers.WIN_BY_SMALL_MARGIN_POSITIVE )
		}
	}


	SetCustomWinnerDeterminedLength( WINNER_DETERMINED_WAIT_DURATION )
	GamemodeUtility_GamemodeSetWinnerCommon( winningAlliance, victoryCondition, Control_ControlOnlySetWinnerFunctionality )
}
#endif // SERVER

#if SERVER
void function Control_ControlOnlySetWinnerFunctionality( int winningAlliance )
{
	int resultFlags = Control_GetFlagsetForVictoryCondition( svGlobal.winReason )
	Survival_SetGameResultFlags( resultFlags )

	// if it's score, set the actual score of the LOSING team (we know the winning team score as it's the limit)
	// otherwise, bitmask for lockout details (if lockout ever becomes not A & B & C)
	if ( svGlobal.winReason == eWinReason.SCORE_LIMIT || svGlobal.winReason == eWinReason.TEAM_FORFEIT )
	{
		// we know what the winner's score MUST be, so just track losing score
		// should NEVER happen in prod - but can often happen in Dev during solo-testing - so check for a valid score. But servers sometimes misbehave...
		int finalScoreForLosingTeam = GetAllianceTeamsScore( AllianceProximity_GetOtherAlliance( winningAlliance ) )
		Survival_SetGameScoreFlags( finalScoreForLosingTeam )
	}
	else if ( svGlobal.winReason == eWinReason.LOCKOUT )
	{
		// is lockout ALWAYS *all* control points?
		// bitmask could store A&C, A&B, B&C, A&B&C ...
		int lockoutMask
		Survival_SetGameScoreFlags( lockoutMask )
	}

	// Award Xp for tracked time events and update stats
	array < entity > allPlayersArray = GetPlayerArray()
	foreach ( point in file.chosenVariantData.controlPoints )
	{
		foreach ( player in allPlayersArray )
		{
			if ( IsValid( player ) )
			{
				if ( player in point.timeCapturingByPlayerForMatch )
					AddXP( player, eXPType.OBJECTIVE_CAPTURE_DURATION )

				if ( player in point.timeOnObjectiveByPlayerForMatch )
					StatsHook_Control_AddPlayerTimeOnObjective( player, 1.0 )
			}
		}
	}

	entity expLeader = file.expLeader
	if ( IsValid( expLeader ) && GradeFlagsHas( expLeader, eTargetGrade.EXP_LEADER ) )
		GradeFlagsClear( expLeader, eTargetGrade.EXP_LEADER )

	array < entity > allPlayerAndSpectatorArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayerAndSpectatorArray )
	{
		if ( IsValid( player ) )
		{
			// this will retrigger the loss music for the lossers as well as play the win music for the winner.
			// Can't use PlayMusicToPlayer(), because on the client, the music is played on the viewPlayer, so you to hear the wrong music if you are specating.
			StopAllMusicOnPlayer( player )

			if ( IsValid( file.musicEntity ) )
				StopSoundOnEntity( file.musicEntity, "Music_Ctrl_Gameplay" )

			Remote_CallFunction_NonReplay( player, "ServerCallback_PlayMatchEndMusic_Control", svGlobal.winReason )
		}

	}
}
#endif // SERVER

#if SERVER
int function Control_GetFlagsetForVictoryCondition( int victoryCondition )
{
	int victoryFlag
	switch( victoryCondition )
	{
		case( eWinReason.SCORE_LIMIT ):
			victoryFlag = CONTROL_VICTORY_FLAGS_SCORE
			break
		case( eWinReason.LOCKOUT ):
			victoryFlag = CONTROL_VICTORY_FLAGS_LOCKOUT
			break
		case( eWinReason.TEAM_FORFEIT ):
			victoryFlag = CONTROL_VICTORY_FLAGS_FORFEIT
			break
		default:
			victoryFlag = CONTROL_VICTORY_FLAGS_UNKNOWN
			break
	}

	return victoryFlag
}
#endif // SERVER

#if SERVER
// On resolution gamestate, play podium music, this used to be done in the set winner function but it is more generalized now and setup in sh_gamemode_utility
void function Control_OnGameStatePlaying_Resolution()
{
	array < entity > allPlayersArray = GetPlayerArray()
	foreach( entity player in allPlayersArray )
	{
		if ( !IsValid( player ) )
			continue

		Remote_CallFunction_NonReplay( player, "ServerCallback_PlayPodiumMusic" )
	}
}
#endif // SERVER
































#if SERVER
int function Control_GetCurrentRank( entity player )
{
	if ( GetAllTeams().len() <= 1 )
		return 1

	if ( GetGameState() <= eGameState.Playing )
		return 2

	int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	return playerAlliance == GamemodeUtility_GetWinningAlliance( false ) ? 1 : 2
}
#endif // SERVER




























#if SERVER
void function Control_PlayCommentaryLineToAlliance( string dialogueRef, int alliance, string dialogueResponseRef )
{
	if ( alliance == ALLIANCE_NONE )
		return

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	array<entity> playerArray

	foreach( team in GetAllTeams() )
	{
		if ( IsTeamInAlliance( team, alliance ) )
		{
			foreach( player in GetPlayerArrayOfTeam( team ) )
				playerArray.append( player )
		}
	}

	thread PlayCommentaryLineToPlayerArrayDelayed( dialogueRef, ANNOUNCER_DIALOGUE_DELAY, playerArray, dialogueResponseRef )
}
#endif // SERVER

#if SERVER
void function PlayBattleChatterToAllianceDelayed( string dialogueRef, int alliance, float delay = LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_SHORT )
{
	if ( alliance == ALLIANCE_NONE )
		return

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	array<entity> playerArray
	foreach( team in GetAllTeams() )
	{
		if ( IsTeamInAlliance( team, alliance ) )
		{
			entity speaker = TryFindSpeakingPlayerOnTeam( team )
			if ( speaker != null )
				thread PlayBattleChatterLineDelayedToSpeakerAndTeam( speaker, dialogueRef, delay )
		}
	}

}
#endif // SERVER

#if SERVER
// Only some characters have lines to play regarding sponsorship in Control. These lines should only play sometimes because there isn't much variety in them and they only play in reaction to specific announcer dialogue.
const float CHANCE_OF_PLAYING_SPONSORSHIP_REACTION = 0.40
const array< string > COMMENTARY_LINES_WITH_SPONSORSHIP = [
	"Host_AI_Control_Care_Package_01_01",
	"Host_AI_Control_Care_Package_01_02",
	"Host_AI_Control_Care_Package_02_01",
	"Host_AI_Control_Care_Package_02_02"]
const array< string > CONTROL_LEGENDS_ALLOWED_TO_PLAY_SPONSORSHIP_DIALOGUE = [ "character_madmaggie", "character_lifeline", "character_octane" ]
const string SPONSORSHIP_CHATTER_DIALOGUE = "bc_control_sponsorshipReact_"
void function Control_PlayReactDialogueToSponsorshipCommentary( string commentaryPlayed )
{
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	// Check if the line of dialogue that played, should have a response at all
	if ( commentaryPlayed == "" || !( COMMENTARY_LINES_WITH_SPONSORSHIP.contains( commentaryPlayed ) ) )
		return

	foreach( team in GetAllTeams() )
	{
		// Do random chance to play the line per squad
		bool playDialogue = RandomFloat( 1.0 ) < CHANCE_OF_PLAYING_SPONSORSHIP_REACTION
		if ( playDialogue )
		{
			entity speaker = TryFindSpeakingPlayerOnTeam_OnlyAllowSpecificCharacters( team, CONTROL_LEGENDS_ALLOWED_TO_PLAY_SPONSORSHIP_DIALOGUE )
			if ( speaker != null && LoadoutSlot_IsReady( ToEHI( speaker ), Loadout_Character() ) )
			{
				string speakerCharacterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( speaker ), Loadout_Character() ) )

				if ( speakerCharacterName != "" )
				{
					string dialogueToPlay = SPONSORSHIP_CHATTER_DIALOGUE + speakerCharacterName
					thread PlayBattleChatterLineDelayedToSpeakerAndTeam( speaker, dialogueToPlay, LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_LONG )
				}
			}
		}
	}
}
#endif // SERVER


#if SERVER
void function Control_SVUpdateCrowdNoiseMeterThread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	while ( GetGameState() < eGameState.WinnerDetermined )
	{
		wait TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES

		foreach ( controlPoint in file.controlPoints )
		{
			entity wp = controlPoint.waypoint
			if ( !IsValid( wp ) )
				continue

			int cpOwner = wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER )
			int cpAllianceAPlayerCount = wp.GetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ )
			int cpAllianceBPlayerCount = wp.GetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ )
			int cpCapturingAlliance = wp.GetWaypointInt( INT_CAPTURING_ALLIANCE )

			if ( cpAllianceAPlayerCount == cpAllianceBPlayerCount )
			{
				// CONTESTING
				if ( cpAllianceAPlayerCount != 0 )
				{
					ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( ALLIANCE_A, eCrowdNoiseMeterModifiers.CONTROL_CONTESTING_ZONE_POSITIVE, TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES )
					ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( ALLIANCE_B, eCrowdNoiseMeterModifiers.CONTROL_CONTESTING_ZONE_POSITIVE, TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES )
				}
			}
			else if ( cpOwner == ALLIANCE_NONE )
			{
				// CAPTURING
				ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( cpCapturingAlliance, eCrowdNoiseMeterModifiers.CONTROL_CAPTURING_ZONE_POSITIVE, TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES )
			}
			else if ( cpOwner != cpCapturingAlliance )
			{
				// NEUTRALIZING
				ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( cpCapturingAlliance, eCrowdNoiseMeterModifiers.CONTROL_NEUTRALIZING_ZONE_POSITIVE, TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES )
				ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( cpOwner, eCrowdNoiseMeterModifiers.CONTROL_NEUTRALIZING_ZONE_NEGATIVE, TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES )
			}
		}
	}
}
#endif // SERVER



/*
   ____  ____       _ ______ _____ _______ _______      ________    _____ _______    _______ ______   __  __          _   _          _____ ______ __  __ ______ _   _ _______    _____ _      _____ ______ _   _ _______
  / __ \|  _ \     | |  ____/ ____|__   __|_   _\ \    / /  ____|  / ____|__   __|/\|__   __|  ____| |  \/  |   /\   | \ | |   /\   / ____|  ____|  \/  |  ____| \ | |__   __|  / ____| |    |_   _|  ____| \ | |__   __|
 | |  | | |_) |    | | |__ | |       | |    | |  \ \  / /| |__    | (___    | |  /  \  | |  | |__    | \  / |  /  \  |  \| |  /  \ | |  __| |__  | \  / | |__  |  \| |  | |    | |    | |      | | | |__  |  \| |  | |
 | |  | |  _ < _   | |  __|| |       | |    | |   \ \/ / |  __|    \___ \   | | / /\ \ | |  |  __|   | |\/| | / /\ \ | . ` | / /\ \| | |_ |  __| | |\/| |  __| | . ` |  | |    | |    | |      | | |  __| | . ` |  | |
 | |__| | |_) | |__| | |___| |____   | |   _| |_   \  /  | |____   ____) |  | |/ ____ \| |  | |____  | |  | |/ ____ \| |\  |/ ____ \ |__| | |____| |  | | |____| |\  |  | |    | |____| |____ _| |_| |____| |\  |  | |
  \____/|____/ \____/|______\_____|  |_|  |_____|   \/   |______| |_____/   |_/_/    \_\_|  |______| |_|  |_/_/    \_\_| \_/_/    \_\_____|______|_|  |_|______|_| \_|  |_|     \_____|______|_____|______|_| \_|  |_|

 OBJECTIVE STATE MANAGEMENT CLIENT
*/

#if CLIENT
void function Control_OnGamestateEnterPlaying_Client()
{
	entity player = GetLocalViewPlayer()

	if ( IsValid( player) )
	{
		player.ClearMenuCameraEntity()
		// Force the minimap to check if it should be visible. Had bug where it would not be updated on reconnect.
		Minimap_UpdateMinimapVisibility( player )

		//If we end the game right away on Lockout, manage when we warn players about the final objective being captured
		if ( Control_GetIsLockoutInstantWin() )
			thread Control_ManageNearLockoutState_Thread()
	}
}
#endif // CLIENT

#if CLIENT
void function Control_OnGamestateEnterPreMatch_Client()
{
	file.firstTimeRespawnShouldWait = true
}
#endif // CLIENT

#if CLIENT
void function Control_OnGamestateEnterWinnerDetermined_Client()
{
	Control_DeregisterModeButtonPressedCallbacks()
	RunUIScript( "UpdateSystemMenu" )
}
#endif // CLIENT

#if CLIENT
void function Control_OnGamestateEnterResolution_Client()
{
	Control_DeregisterModeButtonPressedCallbacks()
	Signal( clGlobal.levelEnt, "GameModes_CompletedResolutionCleanup" )
}
#endif // CLIENT

#if CLIENT
void function Control_DeregisterModeButtonPressedCallbacks( bool shouldCloseCharacterSelect = true )
{
	RunUIScript( "UI_CloseFeatureTutorialDialog" )
	RunUIScript( "Control_SetAllButtonsDisabled" )

	if ( shouldCloseCharacterSelect )
		Control_CloseCharacterSelectOnlyIfOpen()

	if ( IsUsingLoadoutSelectionSystem() )
		RunUIScript( "LoadoutSelectionMenu_CloseLoadoutMenu" )

	RunUIScript( "UI_CloseControlSpawnMenu" )
	DestroyRespawnBlur()
}
#endif // CLIENT

#if CLIENT
void function Control_CloseCharacterSelectOnlyIfOpen()
{
	if ( CharacterSelect_MenuIsOpen() )
		CloseCharacterSelectMenu()
}
#endif // CLIENT

#if CLIENT
void function ControlOverrideGameState()
{
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_control_mode.rpak" )
	ClGameState_RegisterGameStateFullmapAsset( $"ui/gamestate_info_fullmap_control.rpak" )
}
#endif // CLIENT

#if CLIENT
void function Control_OnFullmapCreated( var fullmap )
{
	ObjectiveScoreTrackerSetup( fullmap )
}
#endif // CLIENT

#if CLIENT
void function Control_OnScoreboardCreated()
{
	ObjectiveScoreTrackerSetup( ClGameState_GetRui() )
	ObjectiveScoreTracker_AnnouncementSetup( ClGameState_GetRui() )
}
#endif // CLIENT

#if CLIENT
void function Control_OnPlayerCreated( entity player )
{
	ObjectiveScoreTracker_PopulatePlayerData( GetFullmapGamestateRui() )
	ObjectiveScoreTracker_PopulatePlayerData( ClGameState_GetRui() )
}
#endif // CLIENT

#if CLIENT
void function Control_OnPlayerTeamChanged_Client( entity player, int oldTeam, int newTeam )
{
	ObjectiveScoreTracker_PopulatePlayerData( GetFullmapGamestateRui() )
	ObjectiveScoreTracker_PopulatePlayerData( ClGameState_GetRui() )
}
#endif // CLIENT

#if CLIENT
void function Control_OnPlayerClassChanged( entity player )
{
	ObjectiveScoreTracker_PopulatePlayerData( GetFullmapGamestateRui() )
	ObjectiveScoreTracker_PopulatePlayerData( ClGameState_GetRui() )
}
#endif // CLIENT

#if CLIENT
void function Control_OnSpectatorTargetChanged( entity spectatingPlayer, entity prevSpectatorTarget, entity newSpectatorTarget )
{
	ObjectiveScoreTracker_PopulatePlayerData( GetFullmapGamestateRui() )
	ObjectiveScoreTracker_PopulatePlayerData( ClGameState_GetRui() )

	// Fix for R5DEV-425745
	// Issue was caused because the Observer would open the map which ends up starting the Control_CameraInputManager_Thread thread
	// When the spectator target is automatically changed when players spawn in, the LocalClientPlayer entity that was used to trigger that thread is destroyed
	// What happens after that, is if the player tries to close the map, the Control_PlayerHideScoreboardMap signal is sent but doesn't kill the Control_CameraInputManager_Thread thread because the entity that started that thread is no longer around
	// I couldn't fix this by killing the Control_CameraInputManager_Thread thead when the player is destroyed because it leaves a bunch of the map logic around and starts to create issues with the context ( for the button ) not being in the expected state which causes a crash
	// The ideal solution would be to have a single thread control the whole map and camera logic but it would also cause issues like the map being closed when the target changes.
	// For now this is the best solution although it is obviously hacky
	// ToDo: If we end up with more issues around the map/camera logic with Observer consider refactoring
	entity localPlayer = GetLocalClientPlayer()
	if ( IsValid( localPlayer ) && Control_IsPlayerPrivateMatchObserver( localPlayer ) && localPlayer == spectatingPlayer && file.isPlayerInMapCameraView  )
	{
		Control_HideScoreboardOrMap_Teams()
		Control_ShowScoreboardOrMap_Teams()
	}
}
#endif // CLIENT

#if CLIENT
void function Control_OnViewPlayerChanged( entity player )
{
	ObjectiveScoreTracker_PopulatePlayerData( GetFullmapGamestateRui() )
	ObjectiveScoreTracker_PopulatePlayerData( ClGameState_GetRui() )
}
#endif // CLIENT

#if CLIENT
void function Control_OnPlayerDisconnected( entity player )
{
	entity localPlayer = GetLocalClientPlayer()
	if ( !IsValid( player ) || !IsValid( localPlayer ) )
		return

	if ( player != GetLocalClientPlayer() )
		return

	// Don't close the character select menu on disconnect. It gets closed by other logic and trying to close it here can cause a crash.
	Control_DeregisterModeButtonPressedCallbacks( false )
}
#endif // CLIENT

#if CLIENT
void function Control_InstanceObjectivePing_Thread( entity wp )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( wp ) )
		return

	EndSignal( wp, "OnDestroy" )

	int wpType = wp.GetWaypointType()
	Assert( wpType == eWaypoint.CONTROL_OBJECTIVE )

	entity viewPlayer = GetLocalViewPlayer()
	if ( !IsValid( viewPlayer ) )
	{
		Warning( "CONTROL: %s(): no view-player.", FUNC_NAME() )
		return
	}

	#if DEV
		if ( viewPlayer.GetTeamMemberIndex() < 0 )
			Warning( "CONTROL: %s(): team member index was invalid.", FUNC_NAME() )
	#endif // DEV

	while ( IsValid( viewPlayer ) && viewPlayer.GetTeamMemberIndex() < 0 )
	{
		WaitFrame()
		viewPlayer = GetLocalViewPlayer()
	}

	if ( IsValid( viewPlayer ) )
	{
		var rui = CreateWaypointRui( $"ui/waypoint_control_objective.rpak", CONTROL_OBJECTIVE_RUI_SORTING )
		RuiKeepSortKeyUpdated( rui, true, "targetPos" )

		RuiTrackInt( rui, "viewPlayerTeamMemberIndex", viewPlayer, RUI_TRACK_PLAYER_TEAM_MEMBER_INDEX )
		RuiTrackFloat3( rui, "targetPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat3( rui, "playerAngles", viewPlayer, RUI_TRACK_CAMANGLES_FOLLOW ) //RUI_TRACK_EYEANGLES_FOLLOW

		PlayerMatchState_RuiTrackInt( rui, "matchStateCurrent", viewPlayer )

		bool visible = ShouldWaypointRuiBeVisible()
		RuiSetVisible( rui, visible )

		SetWaypointRui_HUD( wp, rui )
		UpdateResponseIcons( wp )

		SetupObjectiveWaypoint( wp, rui )
	}
}
#endif // CLIENT

#if CLIENT
void function SetupObjectiveWaypoint( entity wp, var rui )
{
	entity localPlayer = GetLocalClientPlayer()
	if ( wp.GetWaypointType() == eWaypoint.CONTROL_OBJECTIVE && IsValid( localPlayer ) )
	{
		thread ManageObjectiveWaypoint( wp, rui )
		int objectiveID = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )

		RuiSetString( rui, "objectiveName", CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveID ) )
		RuiTrackFloat( rui, "capturePercentage", wp, RUI_TRACK_WAYPOINT_FLOAT, FLOAT_CAP_PERC )
		RuiTrackInt( rui, "currentControllingTeam", wp, RUI_TRACK_WAYPOINT_INT, INT_CAPTURING_ALLIANCE )
		RuiTrackInt( rui, "currentOwner", wp, RUI_TRACK_WAYPOINT_INT, CONTROL_INT_OBJ_ALLIANCE_OWNER)
		RuiTrackInt( rui, "neutralPointOwnership", wp, RUI_TRACK_WAYPOINT_INT, CONTROL_INT_OBJ_NEUTRAL_ALLIANCE_OWNER )
		RuiSetInt( wp.wp.ruiHud, "yourTeamIndex", AllianceProximity_GetAllianceFromTeamWithObserverCorrection( localPlayer.GetTeam() ) )
		RuiTrackInt( rui, "team0PlayersOnObj", wp, RUI_TRACK_WAYPOINT_INT, INT_ALLIANCE_A_PLAYERSONOBJ )
		RuiTrackInt( rui, "team1PlayersOnObj", wp, RUI_TRACK_WAYPOINT_INT, INT_ALLIANCE_B_PLAYERSONOBJ )

		thread ObjectiveWaypointThink( wp, rui )
		thread ObjectiveGameStateTrackerThink( wp, ClGameState_GetRui(), true, true )
		thread ObjectiveGameStateTrackerThink( wp, GetFullmapGamestateRui(), true, false )

		thread ManageObjectiveVFX_Client_Thread( wp )
	}
}
#endif // CLIENT

#if CLIENT
void function ManageObjectiveWaypoint( entity wp, var rui )
{
	Assert( IsNewThread(), "Must be threaded off" )

	file.waypointList.append( wp )

	wp.EndSignal( "OnDestroy" )

	OnThreadEnd(
		void function() : ( wp )
		{
			printt( "CONTROL: Objective waypoint destroyed" )

			file.waypointList.fastremovebyvalue( wp )
		}
	)

	WaitForever()
}
#endif // CLIENT

#if CLIENT
array < entity > function Control_GetObjectiveWaypointsArray()
{
	return file.waypointList
}
#endif // CLIENT

#if CLIENT
void function ManageObjectiveVFX_Client_Thread( entity wp )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( wp ) )
		return

	wp.EndSignal( "OnDestroy" )
	wp.EndSignal( SIGNAL_WAYPOINT_RUI_SET )

	entity scriptParent = wp.GetParent()
	entity objectiveFlag = scriptParent
	entity objectiveBorder = wp.GetWaypointEntity( CONTROL_WAYPOINT_TRIGGER_ENTITY_INDEX )

	if ( GetEditorClass( scriptParent ) != "control_flag_prop" )
	{
		array<entity> linkedEnts = scriptParent.GetLinkEntArray()
		foreach( ent in linkedEnts )
		{
			if ( GetEditorClass( ent ) == "control_flag_prop" )
				objectiveFlag = ent
		}
	}

	if ( !IsValid( objectiveFlag ) && !IsValid( objectiveBorder ) )
		return

	#if DEV
		printt( "CONTROL: Setting up flare on objective ", scriptParent, " with flag ent ", objectiveFlag )
	#endif // DEV

	int flareFX
	if ( IsValid( objectiveFlag ) )
	{
		flareFX = StartParticleEffectOnEntity( objectiveFlag, GetParticleSystemIndex( CONTROL_WAYPOINT_FLARE_ASSET ), FX_PATTACH_POINT_FOLLOW_NOROTATE, objectiveFlag.LookupAttachment( "fx_end" ) )
		EffectWake( flareFX )
	}

	entity player = GetLocalViewPlayer()

	OnThreadEnd(
		function() : ( flareFX )
		{
			if ( EffectDoesExist( flareFX ) )
				EffectStop( flareFX, false, false )
		}
	)

	while ( GetGameState() == eGameState.Playing )
	{
		player = GetLocalViewPlayer()

		// If the player is not valid or the objective elements we want to update are not valid, break out and end the function
		if ( !IsValid( player ) || !IsValid( wp ) || !IsValid( objectiveFlag ) && !IsValid( objectiveBorder ) )
			break

		// Figure out what color we want to use for VFX and borders
		bool isPointContested = wp.GetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ ) > 0 && wp.GetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ ) > 0
		vector vfxColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
		int objectiveOwner = wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
		int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )

		if ( isPointContested )
		{
			vfxColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.CONTESTED )
		}
		else if ( objectiveOwner == playerAlliance )
		{
			vfxColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED )
		}
		else if ( objectiveOwner != playerAlliance && objectiveOwner != ALLIANCE_NONE )
		{
			vfxColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
		}

		// Manage the Flag VFX
		if ( IsValid( objectiveFlag ) && EffectDoesExist( flareFX ) )
			EffectSetControlPointVector( flareFX, 1, vfxColor )

		// Manage Objective Border VFX
		// ToDo DSwieczko: This is currently not properly setting the Border Colors, Investigate what Entity this needs
		//if ( IsValid( objectiveBorder ) ) //&& objectiveBorder.HasKey( "model" )
		//	objectiveBorder.kv.rendercolor = vfxColor

		wp.WaitSignal( "Control_OnObjectiveStateChanged_Client" )
	}
}
#endif // CLIENT

#if CLIENT
void function ObjectiveWaypointThink( entity wp, var rui )
{
	wp.EndSignal( "OnDestroy" )
	wp.EndSignal( SIGNAL_WAYPOINT_RUI_SET )

	bool isPointContested = false

	while ( GetGameState() == eGameState.Playing )
	{
		entity player = GetLocalViewPlayer()

		// okirkham: this code relies heavily on the player's team/alliance to display correct objective markers which won't work well for pure observers not spectating another player
		// (so, in cases for observers where GetLocalClientPlayer() == GetLocalViewPlayer()) see: https://jiratf.rspn.ad.ea.com/browse/R5DEV-579228
		if ( IsValid( player ) && player.GetTeam() != TEAM_SPECTATOR )
		{
			int playerTeam = player.GetTeam()
			int playerAlliance = AllianceProximity_GetAllianceFromTeam( playerTeam )

			if ( Control_ShouldShow2DMapIcons() )
			{
				var minimapRui
				var fullmapRui
				if ( wp in file.waypointToMinimapRui )
					minimapRui = file.waypointToMinimapRui[wp]
				if ( wp in file.waypointToFullmapRui )
					fullmapRui = file.waypointToFullmapRui[wp]

				asset iconToSet
				if ( wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER) == ALLIANCE_NONE )
				{
					iconToSet = CONTROL_OBJ_DIAMOND_EMPTY
				}
				else if ( wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER) == playerAlliance )
				{
					iconToSet = CONTROL_OBJ_DIAMOND_YOURS
				}
				else
				{
					iconToSet = CONTROL_OBJ_DIAMOND_ENEMY
				}

				if ( RuiIsAlive( minimapRui ) )
					RuiSetImage( minimapRui, "defaultIcon", iconToSet )
				if ( RuiIsAlive( fullmapRui ) )
					RuiSetImage( fullmapRui, "defaultIcon", iconToSet )
			}

			if ( RuiIsAlive( rui ) )
			{
				bool hasEmphasis = wp.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) > 0
				RuiSetBool( rui,"hasEmphasis", hasEmphasis )
			//	RuiSetInt( rui, "numTeamPings", CaptureObjectivePing_GetPingCountForObjectiveForTeamOrAlliance( wp, playerAlliance ) )
				RuiSetBool( rui, "localPlayerOnObjective",  Control_Client_IsOnObjective( wp, player ) )
				RuiSetBool( rui, "isHidden", file.inGameMapRui != null || IsScoreboardShown() ) //hide in world markers if viewing the map or scoreboard
			}
		}

		// Track whether the objective is contested and then send a signal for VFX to update if the state changes
		bool tempIsPointContested = wp.GetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ ) > 0 && wp.GetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ ) > 0
		if ( isPointContested != tempIsPointContested )
		{
			isPointContested = tempIsPointContested
			Signal( wp, "Control_OnObjectiveStateChanged_Client" )
		}

		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
void function ObjectiveGameStateTrackerThink( entity wp, var gameStateRui, bool shouldTrackOnObjective = true, bool shouldTrackOwner = false )
{
	Assert( IsNewThread(), "Must be threaded off" )
	wp.EndSignal( "OnDestroy" )
	wp.EndSignal( SIGNAL_WAYPOINT_RUI_SET )

	int waypointIndex = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
	var mainTrackerRui = RuiCreateNested( gameStateRui, "objective" + waypointIndex, $"ui/control_mode_progress_tracker.rpak" )
	entity localPlayer = GetLocalClientPlayer()
	entity localPlayerView = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	if( !GamemodeUtility_IsPlayerOnTeamObserver( localPlayer ) )
		localPlayerView.EndSignal( "OnDestroy" )

	//main tracker
	RuiSetString( mainTrackerRui, "name", CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( waypointIndex ) )

	RuiTrackFloat( mainTrackerRui, "capturePercentage", wp, RUI_TRACK_WAYPOINT_FLOAT, FLOAT_CAP_PERC )
	RuiTrackInt( mainTrackerRui, "currentControllingTeam", wp, RUI_TRACK_WAYPOINT_INT, INT_CAPTURING_ALLIANCE )
	RuiTrackInt( mainTrackerRui, "currentOwner", wp, RUI_TRACK_WAYPOINT_INT, CONTROL_INT_OBJ_ALLIANCE_OWNER)
	RuiTrackInt( mainTrackerRui, "neutralPointOwnership", wp, RUI_TRACK_WAYPOINT_INT, CONTROL_INT_OBJ_NEUTRAL_ALLIANCE_OWNER )
	RuiTrackInt( mainTrackerRui, "team0PlayersOnObj", wp, RUI_TRACK_WAYPOINT_INT, INT_ALLIANCE_A_PLAYERSONOBJ )
	RuiTrackInt( mainTrackerRui, "team1PlayersOnObj", wp, RUI_TRACK_WAYPOINT_INT, INT_ALLIANCE_B_PLAYERSONOBJ )

	OnThreadEnd(
		function() : ( gameStateRui, waypointIndex )
		{
			RuiDestroyNestedIfAlive( gameStateRui, "objective" + waypointIndex )
		}
	)

	while ( GetGameState() == eGameState.Playing )
	{
		localPlayerView = GetLocalViewPlayer()
		if ( IsValid( localPlayerView ) )
		{
			int slot = OFFHAND_INVENTORY
			entity weapon = localPlayerView.GetOffhandWeapon( slot )
			if( weapon != null )
			{
				switch ( weapon.GetWeaponSettingEnum( eWeaponVar.cooldown_type, eWeaponCooldownType ) )
				{
					case eWeaponCooldownType.ammo:
						int maxAmmoReady = weapon.UsesClipsForAmmo() ? weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) : weapon.GetWeaponPrimaryAmmoCountMax( weapon.GetActiveAmmoSource() )
						int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )

						RuiSetInt( gameStateRui, "ultimateSegments", maxAmmoReady / ammoPerShot )
						break
					default:
						RuiSetInt( gameStateRui, "ultimateSegments", 1 )
						break
				}
			}
			else
				RuiSetInt( gameStateRui, "ultimateSegments", 1 )

			if ( shouldTrackOnObjective )
			{
				if ( Control_Client_IsOnObjective( wp, localPlayerView ) )
				{
					RuiSetBool( gameStateRui, "isOnObjective" + waypointIndex, true )
					RuiSetBool( mainTrackerRui, "isOnObjective", true )
					RuiSetFloat( mainTrackerRui, "iconScale", 1.35 )
				}
				else
				{
					RuiSetBool( gameStateRui, "isOnObjective" + waypointIndex, false )
					RuiSetBool( mainTrackerRui, "isOnObjective", false )
					RuiSetFloat( mainTrackerRui, "iconScale", 0.7 )
				}
			}
		}
		//do frame logic here

		RuiSetInt( mainTrackerRui, "yourTeamIndex", AllianceProximity_GetAllianceFromTeamWithObserverCorrection( localPlayerView.GetTeam() ) )
		if ( wp.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) > 0 )
			RuiSetBool( mainTrackerRui, "shouldPlayEmphasis", true )
		else
			RuiSetBool( mainTrackerRui, "shouldPlayEmphasis", false )

		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
const float MIN_TIME_BETWEEN_OBJECTIVECAPTURE_ALARMS = 10.0
const float MIN_TIME_BETWEEN_OBJECTIVECAPTURE_ALARM_MSG = 60.0
// Track when the last objective is being captured by the enemy to warn players that the game could be ending soon
void function Control_ManageNearLockoutState_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )
	float timeWarningMessageLastDisplayed = -1

	while ( GetGameState() == eGameState.Playing )
	{
		if ( Control_GetIsMatchNearEnemyLockoutState() )
		{
			bool shouldDisplayMessageWithAlarm = timeWarningMessageLastDisplayed == -1 || Time() > timeWarningMessageLastDisplayed + MIN_TIME_BETWEEN_OBJECTIVECAPTURE_ALARM_MSG
			Control_PlayFinalObjectiveCapturingWarning( shouldDisplayMessageWithAlarm )

			if ( shouldDisplayMessageWithAlarm )
				timeWarningMessageLastDisplayed = Time()

			wait MIN_TIME_BETWEEN_OBJECTIVECAPTURE_ALARMS
		}

		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
// Return whether an enemy is capturing the last objective needed to trigger a lockout
bool function Control_GetIsMatchNearEnemyLockoutState()
{
	bool isNearLockout = false
	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return isNearLockout

	int playerAlliance = AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() )
	int enemyAlliance = AllianceProximity_GetOtherAlliance( playerAlliance )
	int allianceWithObjectiveMajority = Control_GetAllianceWithOwnedObjectiveMajority()

	if ( Control_isValidMatchStateForLockout( CONTROL_LOCKOUT_EVENT_DURATION, false ) && !file.isLockout && allianceWithObjectiveMajority != ALLIANCE_NONE && allianceWithObjectiveMajority != playerAlliance )
	{
		foreach ( wp in file.waypointList )
		{
			// We only care about Neutral Objectives or Ones owned by the players Alliance that are being captured by the Enemy Alliance
			if ( wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER) != enemyAlliance ) //  && objective.GetWaypointInt( INT_CAPTURING_ALLIANCE ) == enemyAlliance
			{
				int numEnemiesOnObjective = playerAlliance == ALLIANCE_A ? wp.GetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ ) : wp.GetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ )

				if ( numEnemiesOnObjective > 0 )
				{
					isNearLockout = true
					break
				}
			}
		}
	}

	return isNearLockout
}
#endif // CLIENT

#if CLIENT
// Return the Alliance that currently controls the most Objectives
int function Control_GetAllianceWithOwnedObjectiveMajority()
{
	int allianceWithObjectiveMajority = ALLIANCE_NONE
	int aOwnedPoints = Control_GetNumOwnedObjectivesByAlliance( ALLIANCE_A )
	int bOwnedPoints = Control_GetNumOwnedObjectivesByAlliance( ALLIANCE_B )

	if ( aOwnedPoints > 1 )
	{
		allianceWithObjectiveMajority = ALLIANCE_A
	}
	else if ( bOwnedPoints > 1 )
	{
		allianceWithObjectiveMajority = ALLIANCE_B
	}

	return allianceWithObjectiveMajority
}
#endif // CLIENT

#if CLIENT
void function ObjectiveScoreTrackerSetup( var rui )
{
	table<int, var> nestedRuiTable

	for( int i = 0; i<2; i++ )
	{
		var childRui = RuiCreateNested( rui, "team" + i + "Tracker", $"ui/control_score_tracker.rpak" )
		RuiSetFloat( childRui, "scoreLimit", float( GetScoreLimit_FromPlaylist() ) )
		RuiSetInt( childRui, "trackerIndex", i )

		if ( i == 1 )
			RuiSetBool( childRui, "reverseOrientation", true )

		nestedRuiTable[i] <- childRui
	}

	if ( rui == ClGameState_GetRui() )
		file.scoreTrackerRui = nestedRuiTable
	else if ( rui == GetFullmapGamestateRui() )
		file.fullmapScoreTrackerRui = nestedRuiTable
	else
		return

	// The ObjectiveScoreTracker_PopulatePlayerData function will try to run this function again if the rui is null. So don't run that function if this rui ended up null or we will end up in an infinite loop
	if ( rui != null )
		ObjectiveScoreTracker_PopulatePlayerData( rui )
}
#endif // CLIENT

#if CLIENT
void function ObjectiveScoreTracker_PopulatePlayerData( var parentRui )
{
	// If the Main Rui is null, try to initialize it again
	if ( parentRui == null )
		ObjectiveScoreTrackerSetup( ClGameState_GetRui() )

	if ( GetLocalClientPlayer() == null || GetGameState() < eGameState.Prematch)
		return // this gets called before the player is created so we have to early out in those cases. Not an issue, since this is called when the player is created as well.

	entity localPlayer = GetLocalClientPlayer()

	int friendlyAlliance = AllianceProximity_GetAllianceFromTeamWithObserverCorrection( localPlayer.GetTeam() )
	int enemyAlliance = AllianceProximity_GetOtherAlliance( friendlyAlliance )

	table<int, var> nestedRuiTable
	if ( parentRui == ClGameState_GetRui() )
	{
		nestedRuiTable = file.scoreTrackerRui
		localPlayer.Signal( "EndUpdateAllianceUIScoreGameState" )
	}
	else if ( parentRui == GetFullmapGamestateRui() )
	{
		nestedRuiTable = file.fullmapScoreTrackerRui
		localPlayer.Signal( "EndUpdateAllianceUIScoreMap" )
	}

	thread UpdateAllianceUIScore( parentRui, localPlayer, nestedRuiTable[1], nestedRuiTable[0], friendlyAlliance, enemyAlliance ) //blue team

	Control_UpdateScoreGenerationOnClient()
}
#endif // CLIENT

#if CLIENT
void function UpdateAllianceUIScore( var parentRui, entity player, var blueRui, var redRui, int blueTeam , int redTeam )
{
	if ( parentRui == ClGameState_GetRui() )
		player.EndSignal( "EndUpdateAllianceUIScoreGameState" )
	else if ( parentRui == GetFullmapGamestateRui() )
		player.EndSignal( "EndUpdateAllianceUIScoreMap" )

	player.EndSignal( "OnDestroy" )

	while( GetGameState() == eGameState.Playing )
	{
		ControlTeamData blueData = file.teamData[ blueTeam ]
		ControlTeamData redData = file.teamData[ redTeam ]

		float blueScore =  float( blueData.teamScoreFromPoints + blueData.teamScoreFromBonus )
		float redScore =  float( redData.teamScoreFromPoints + redData.teamScoreFromBonus )

		RuiSetInt( blueRui, "yourTeamIndex", blueTeam )
		RuiSetFloat( blueRui, "teamScore", blueScore )
		RuiSetFloat( blueRui, "opponentScore", redScore )

		RuiSetInt( redRui, "yourTeamIndex", redTeam )
		RuiSetFloat( redRui, "teamScore", redScore )
		RuiSetFloat( redRui, "opponentScore", blueScore )

		WaitFrame()
	}
}
#endif

#if CLIENT
void function ObjectiveScoreTracker_AnnouncementSetup( var parentRui )
{
	if ( parentRui == null )
		return

	file.announcementRui = RuiCreateNested( parentRui, "announcementTracker", $"ui/control_announcement_tracker.rpak" )
	thread ObjectiveScoreTracker_AnnouncementManagement()
}
#endif // CLIENT

#if CLIENT
void function ObjectiveScoreTracker_AnnouncementManagement()
{
	Assert( IsNewThread(), "Must be threaded off" )

	bool shouldUpdateCatchupMechanicsUI = Control_GetMinHeldObjectivesToGenerateScore() > 0 && Control_GetIsMinHeldObjectivesOnlyForWinningTeam()
	bool isUsingCatchupMechanic = false

	while ( true )
	{
		float currentTime = Time()

		if ( file.currentAnnouncement.isInitialized )
		{
			array<ControlAnnouncementData> announcementCopy = clone file.announcementData
			foreach( announcement in announcementCopy )
			{
				if ( announcement.shouldForcePushAnnouncement )
				{
					Control_DisplayAnnouncement( announcement )
				}
			}

			//there's a current announcement, just check if we need to remove it - dead WP
			if ( file.currentAnnouncement.shouldTerminateIfWPDies && !IsValid(file.currentAnnouncement.wp ) )
				Control_CancelAnnouncementDisplay()

			float announcementDisplayEndTime = file.currentAnnouncement.displayStartTime + file.currentAnnouncement.displayLength
			float eventEndTime = file.currentAnnouncement.startTime + file.currentAnnouncement.eventLength
			float trueEndTime = min( announcementDisplayEndTime, eventEndTime )
			if ( currentTime > trueEndTime )
				Control_CancelAnnouncementDisplay()
		}
		else
		{
			array<ControlAnnouncementData> announcementCopy = clone file.announcementData

			//there's no announcement, see if we need to show one
			foreach( announcement in announcementCopy )
			{
				float announcementEndTime = announcement.startTime + announcement.eventLength
				if ( currentTime > announcementEndTime )
				{
					//announcement is over, no need to announce it
					file.announcementData.removebyvalue( announcement )
				}
				else
				{
					Control_DisplayAnnouncement( announcement )
				}
			}
		}
		entity player = GetLocalClientPlayer()
		bool isPlayerOnSpawnSelectScreen = false
		if ( IsValid( player ) )
			isPlayerOnSpawnSelectScreen = player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" )

		if(file.announcementRui != null)
			RuiSetBool( file.announcementRui, "isRespawnMap", isPlayerOnSpawnSelectScreen )


		// If we need to update the HUD with catchup mechanic info ( EXP tier cost decrease, min held objectives logic)
		// We need to update the Client side info when we switch between using the catchup mechanic and not using it.
		// Because it is based off of score not objective state changes which normally trigger this update.
		if ( shouldUpdateCatchupMechanicsUI && isUsingCatchupMechanic != Control_ShouldUseCatchupMechanics() )
		{
			isUsingCatchupMechanic = Control_ShouldUseCatchupMechanics()
			Control_UpdateScoreGenerationOnClient()
		}

		Control_SetRatingsVisibility( player )

		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
void function Control_SetRatingsVisibility( entity player )
{
	if ( IsValid( player ) )
	{
		var rui = ClGameState_GetRui()
		int gameState = GetGameState()

		HudVisibilityStatus hudStatus = GetHudStatus( player )

		if ( Control_IsPlayerPrivateMatchObserver( GetLocalClientPlayer() ) )
		{
			RuiSetBool( rui, "shouldDisplayExpUI", false )
		}
		else
		{
			RuiSetBool( rui, "shouldDisplayExpUI", Control_GetIsWeaponEvoEnabled() && hudStatus.mainHud && gameState >= eGameState.Playing )
		}
	}
}
#endif

#if CLIENT
void function Control_ObjectiveScoreTracker_PushAnnouncement( 	entity wp,
														bool shouldTerminateIfWPDies,
														string mainText,
														string subText,
														float eventLength,
														float displayLength,
														bool shouldForcePushAnnouncement,
														bool shouldUseTimer,
														vector overrideColor)
{
	ControlAnnouncementData announcementData

	announcementData.isInitialized = true
	announcementData.wp = wp
	announcementData.shouldTerminateIfWPDies = shouldTerminateIfWPDies
	announcementData.shouldForcePushAnnouncement = shouldForcePushAnnouncement
	announcementData.shouldUseTimer = shouldUseTimer

	announcementData.mainText = mainText
	announcementData.subText = subText

	announcementData.startTime = Time()
	announcementData.eventLength = eventLength
	announcementData.displayLength = displayLength
	announcementData.overrideColor = overrideColor

	file.announcementData.append( announcementData )
}
#endif // CLIENT

#if CLIENT
void function Control_ObjectiveScoreTracker_UpdateAnnouncement( entity wp,
		bool shouldTerminateIfWPDies,
		string mainText,
		string subText,
		float eventLength,
		float displayLength,
		bool shouldForcePushAnnouncement,
		bool shouldUseTimer )
{
	entity localViewPlayer = GetLocalViewPlayer()
	entity localClientPlayer = GetLocalClientPlayer()
	if ( !IsValid( localViewPlayer ) )
		return

	if ( !file.currentAnnouncement.isInitialized || !IsValid(file.currentAnnouncement.wp ) )
	{
		if( file.announcementData.len() > 0 )
		{
			Control_DisplayAnnouncement( file.announcementData.top() )
		}
		else
		{
			Warning( "CONTROL: Control_ObjectiveScoreTracker_UpdateAnnouncement - No current announcement!" )
			return
		}

	}

	file.currentAnnouncement.displayLength = file.currentAnnouncement.displayLength + displayLength

	table<int, var> nestedRuiTable
	nestedRuiTable = file.scoreTrackerRui

	RuiSetFloat( nestedRuiTable[0], "announcementLength", file.currentAnnouncement.displayLength )
	RuiSetFloat( nestedRuiTable[1], "announcementLength", file.currentAnnouncement.displayLength )

	nestedRuiTable = file.fullmapScoreTrackerRui

	RuiSetFloat( nestedRuiTable[0], "announcementLength", file.currentAnnouncement.displayLength )
	RuiSetFloat( nestedRuiTable[1], "announcementLength", file.currentAnnouncement.displayLength )

	RuiSetFloat( ClGameState_GetRui(), "announcementLength",  file.currentAnnouncement.displayLength )
	RuiSetFloat( GetFullmapGamestateRui(), "announcementLength", file.currentAnnouncement.displayLength )

	entity linkedEnt = file.currentAnnouncement.wp.GetParent()
	int yourTeamIndex = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )
	vector colorOverride

	if ( IsValid( linkedEnt ) )
	{
		int currentOwner = linkedEnt.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
		if ( currentOwner == ALLIANCE_NONE )
			colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
		else
		{
			if( GamemodeUtility_IsPlayerOnTeamObserver( localClientPlayer ) )
			{
				colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
			}
			if ( yourTeamIndex == currentOwner )
			{
				colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED )
			}
			else
			{
				colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
			}
		}
	}
	else
	{
		colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
	}

	RuiSetString( file.announcementRui, "mainText", mainText )
	RuiSetString( file.announcementRui, "subText", subText )
	RuiSetBool( file.announcementRui, "shouldUseTimer", shouldUseTimer )
	RuiSetFloat( file.announcementRui, "announcementLength", file.currentAnnouncement.displayLength )
	RuiSetFloat3( file.announcementRui, "colorOverride", SrgbToLinear( colorOverride / 255.0 ) )

	RuiSetString( file.fullMapAnnouncementRui, "mainText", mainText )
	RuiSetString( file.fullMapAnnouncementRui, "subText", subText )
	RuiSetBool( file.fullMapAnnouncementRui, "shouldUseTimer", shouldUseTimer )
	RuiSetFloat( file.fullMapAnnouncementRui, "announcementLength", file.currentAnnouncement.displayLength )
	RuiSetFloat3( file.fullMapAnnouncementRui, "colorOverride", SrgbToLinear( colorOverride / 255.0 ) )
}
#endif // CLIENT

#if CLIENT
void function Control_DisplayAnnouncement( ControlAnnouncementData data )
{
	float announcementEndTime = data.startTime + data.eventLength
	float currentTime = Time()
	float timeUntilEnd = announcementEndTime - currentTime
	float displayTime = min( timeUntilEnd, data.displayLength )
//
	data.displayStartTime = currentTime

	RuiSetGameTime( ClGameState_GetRui(), "announcementStartTime", currentTime )
	RuiSetFloat( ClGameState_GetRui(), "announcementLength", displayTime )

	RuiSetGameTime( GetFullmapGamestateRui(), "announcementStartTime", currentTime )
	RuiSetFloat( GetFullmapGamestateRui(), "announcementLength", displayTime )

	table<int, var> nestedRuiTable
	nestedRuiTable = file.scoreTrackerRui

	RuiSetGameTime( nestedRuiTable[0], "announcementStartTime", currentTime )
	RuiSetFloat( nestedRuiTable[0], "announcementLength", displayTime )
	RuiSetGameTime( nestedRuiTable[1], "announcementStartTime", currentTime )
	RuiSetFloat( nestedRuiTable[1], "announcementLength", displayTime )

	nestedRuiTable = file.fullmapScoreTrackerRui

	RuiSetGameTime( nestedRuiTable[0], "announcementStartTime", currentTime )
	RuiSetFloat( nestedRuiTable[0], "announcementLength", displayTime )
	RuiSetGameTime( nestedRuiTable[1], "announcementStartTime", currentTime )
	RuiSetFloat( nestedRuiTable[1], "announcementLength", displayTime )

	RuiSetGameTime( file.announcementRui, "announcementStartTime", currentTime )
	RuiSetFloat( file.announcementRui, "announcementLength", displayTime )
	RuiSetString( file.announcementRui, "mainText", data.mainText )
	RuiSetString( file.announcementRui, "subText", data.subText )
	RuiSetBool( file.announcementRui, "shouldUseTimer", data.shouldUseTimer )
	RuiSetFloat3( file.announcementRui, "colorOverride",  SrgbToLinear( data.overrideColor / 255.0 ) )

	if(file.fullMapAnnouncementRui == null)
		file.fullMapAnnouncementRui = RuiCreateNested( GetFullmapGamestateRui(), "announcementTracker", $"ui/control_announcement_tracker.rpak" )

	RuiSetGameTime( file.fullMapAnnouncementRui, "announcementStartTime", currentTime )
	RuiSetFloat( file.fullMapAnnouncementRui, "announcementLength", displayTime )
	RuiSetString( file.fullMapAnnouncementRui, "mainText", data.mainText )
	RuiSetString( file.fullMapAnnouncementRui, "subText", data.subText )
	RuiSetBool( file.fullMapAnnouncementRui, "shouldUseTimer", data.shouldUseTimer )
	RuiSetFloat3( file.fullMapAnnouncementRui, "colorOverride",  SrgbToLinear( data.overrideColor / 255.0 ) )
	RuiSetBool( file.fullMapAnnouncementRui, "isWorldMap", true )

	file.currentAnnouncement = data
	file.announcementData.removebyvalue( data )
}
#endif // CLIENT

#if CLIENT
void function Control_CancelAnnouncementDisplay()
{
	ControlAnnouncementData rawData
	file.currentAnnouncement = rawData
}
#endif // CLIENT

#if CLIENT
void function Control_BountyInfoOverride_Thread( entity wp, TimedEventLocalClientData data )
{
	Assert( IsNewThread(), "Must be threaded off" )
	entity localViewPlayer = GetLocalViewPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	EndSignal( wp, "OnDestroy" )
	localViewPlayer.EndSignal( "OnDestroy" )

	string originalName = data.eventName

	Control_ObjectiveScoreTracker_PushAnnouncement( wp,
		true,
		"",
		Localize( data.eventName ),
		wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME ) - Time(),
		CONTROL_MESSAGE_DURATION_LONG,
		false,
		true,
		GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL ))

	while ( !IsValid( wp ) || !IsValid( wp.GetParent() ) )
	{
		WaitFrame()
	}

	localViewPlayer = GetLocalViewPlayer()
	entity localClientPlayer = GetLocalClientPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	//Update annoucement with created bounty
	entity linkedEnt = wp.GetParent()
	int currentOwner = linkedEnt.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
	int objectiveID = linkedEnt.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
	string objectiveName = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveID )
	string eventName
	if( GamemodeUtility_IsPlayerOnTeamObserver( localClientPlayer ) )
		eventName = Localize( "#CONTROL_POINT_BOUNTY_CONTROL", objectiveName ) //Keep this generic
	else if ( currentOwner == ALLIANCE_NONE )
		eventName = Localize( "#CONTROL_POINT_BOUNTY_ATTACK", objectiveName )
	else
	{
		int yourTeamIndex = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )
		if ( yourTeamIndex == currentOwner )
			eventName = Localize( "#CONTROL_POINT_BOUNTY_DEFEND", objectiveName )
		else
			eventName = Localize( "#CONTROL_POINT_BOUNTY_ATTACK", objectiveName )
	}

	Control_ObjectiveScoreTracker_UpdateAnnouncement( wp,
											true,
											eventName.toupper(),
											Localize( data.eventName ),
											wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME ) - wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME ),
											CONTROL_MESSAGE_DURATION,
											false,
											true )

	//Keep data up to date for side notifications
	while ( IsValid( localViewPlayer ) )
	{
		linkedEnt = wp.GetParent()
		if ( IsValid( linkedEnt ) )
		{
			currentOwner = linkedEnt.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
			if( GamemodeUtility_IsPlayerOnTeamObserver( localClientPlayer ) )
			{
				data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
				data.eventName = Localize( "#CONTROL_POINT_BOUNTY_CONTROL", objectiveName ) // keep this generic for observers since they can fly around without context
			}
			else if ( currentOwner == ALLIANCE_NONE )
			{
				data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
				data.eventName = Localize( "#CONTROL_POINT_BOUNTY_ATTACK", objectiveName )
			}
			else
			{
				int yourTeamIndex = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() ) // viewPlayer may change over time
				if ( yourTeamIndex == currentOwner )
				{
					data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED )
					data.eventName = Localize( "#CONTROL_POINT_BOUNTY_DEFEND", objectiveName )
				}
				else
				{
					data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
					data.eventName = Localize( "#CONTROL_POINT_BOUNTY_ATTACK", objectiveName )
				}
			}
		}
		else
		{
			data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
			data.eventName = originalName
		}

		WaitFrame()

		localViewPlayer = GetLocalViewPlayer()
	}
}
#endif // CLIENT

#if CLIENT
void function Control_LockoutInfoOverride_Thread( entity wp, TimedEventLocalClientData data )
{
	Assert( IsNewThread(), "Must be threaded off" )

	file.isLockout = true
	string originalName = data.eventName

	while ( !IsValid( wp ) )
	{
		WaitFrame()
	}

	EndSignal( wp, "OnDestroy" )

	float eventEndTime = wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME )
	int majorityTeam = wp.GetWaypointInt( 5 )
	entity localViewPlayer = GetLocalViewPlayer()
	entity localClientPlayer = GetLocalClientPlayer()

	OnThreadEnd(
		function() : ( wp, eventEndTime, majorityTeam, localClientPlayer )
		{
			file.isLockout = false

			foreach( scoreRui in file.scoreTrackerRui )
			{
				RuiSetBool( scoreRui, "isLockout", false )
			}

			foreach( scoreRui in file.fullmapScoreTrackerRui )
			{
				RuiSetBool( scoreRui, "isLockout", false )
			}

			if ( Time() < eventEndTime )
			{
				entity localPlayer = GetLocalViewPlayer()

				int yourTeamIndex = IsValid( localPlayer ) ? AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() ) : 0
				string subText =  yourTeamIndex == majorityTeam ? Localize( "#CONTROL_LOCKOUT_ENEMY_CAPTURED_OBJ" ) : Localize( "#CONTROL_LOCKOUT_FRIENDLY_CAPTURED_OBJ" )
				Control_ObjectiveScoreTracker_PushAnnouncement( null,
					false,
					Localize( "#CONTROL_LOCKOUT_ABORTED" ),
					GamemodeUtility_IsPlayerOnTeamObserver( localClientPlayer )? "": subText,
					CONTROL_MESSAGE_DURATION_LONG,
					CONTROL_MESSAGE_DURATION_LONG,
					false,
					false,
					GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL ) )

				EmitUISound( CONTROL_SFX_LOCKOUT_ABORT )
			}
		}
	)

	if ( IsValid( localViewPlayer ) )
	{
		EmitUISound( CONTROL_SFX_LOCKOUT_START )

		string eventDesc  = Control_GetIsLockoutInstantWin() ? Localize( "#CONTROL_INSTALOCKOUT_EVENT_DESC" ) : Localize( "#CONTROL_LOCKOUT_EVENT_DESC" )
		int yourTeamIndex = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )
		if ( GamemodeUtility_IsPlayerOnTeamObserver( localClientPlayer ) )
		{
			if ( majorityTeam == 0 )
			{
				string descDetails = Control_GetIsLockoutInstantWin() ? Localize( "#CONTROL_INSTALOCKOUT_INSTRUCTIONS_TEAM1" ) : ""
				eventDesc = eventDesc + descDetails
				data.eventDesc = eventDesc
				data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED )
			}
			else
			{
				string descDetails = Control_GetIsLockoutInstantWin() ? Localize( "#CONTROL_INSTALOCKOUT_INSTRUCTIONS_TEAM2" ) : ""
				eventDesc = eventDesc + descDetails
				data.eventDesc = eventDesc
				data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
			}
		}
		else
		{
			if ( yourTeamIndex ==  majorityTeam )
			{
				string descDetails = Control_GetIsLockoutInstantWin() ? Localize( "#CONTROL_INSTALOCKOUT_INSTRUCTIONS_WINNINGTEAM" ) : Localize( "#CONTROL_LOCKOUT_INSTRUCTIONS_WINNINGTEAM" )
				eventDesc = eventDesc + descDetails
				data.eventDesc = eventDesc
				data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED )
			}
			else
			{
				string descDetails = Control_GetIsLockoutInstantWin() ? Localize( "#CONTROL_INSTALOCKOUT_INSTRUCTIONS_LOSINGTEAM" ) : Localize( "#CONTROL_LOCKOUT_INSTRUCTIONS_LOSINGTEAM" )
				eventDesc = eventDesc + descDetails
				data.eventDesc = eventDesc
				data.colorOverride = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
			}
		}


		float eventDuration = eventEndTime - Time()

		Control_ObjectiveScoreTracker_PushAnnouncement( wp,
			true,
			"",
			Localize( data.eventName ),
			eventDuration,
			eventDuration,
			true,
			true,
			data.colorOverride)

		foreach( scoreRui in file.scoreTrackerRui )
		{
			RuiSetBool( scoreRui, "isLockout", true )
		}

		foreach( scoreRui in file.fullmapScoreTrackerRui )
		{
			RuiSetBool( scoreRui, "isLockout", true )
		}
	}

	WaitForever()
}
#endif // CLIENT

#if CLIENT
void function Control_PlayFinalObjectiveCapturingWarning( bool shouldDisplayMessage )
{
	entity player = GetLocalViewPlayer()

	if ( !IsValid( player ) )
		return

	if ( shouldDisplayMessage )
	{
		GamemodeUtility_AnnouncementMessageWarning( player, Localize( "#CONTROL_INSTALOCKOUT_FINAL_OBJECTIVE_CAPTURE" ), GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED ), CONTROL_FINAL_OBJECTIVE_BEING_CAPTURED_WARNING, CONTROL_MESSAGE_DURATION_SHORT )
	}
	else
	{
		EmitUISound( CONTROL_FINAL_OBJECTIVE_BEING_CAPTURED_WARNING )
	}
}
#endif // CLIENT

#if CLIENT
void function RegisterMinimapPackages()
{
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.CONTROL_OBJECTIVE, MINIMAP_OBJECT_DYNAMIC_RUI, MinimapPackage_Objective, FULLMAP_OBJECT_RUI, FullmapPackage_Objective )
}
#endif // CLIENT

#if CLIENT
void function MinimapPackage_Objective( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", CONTROL_OBJ_DIAMOND_EMPTY )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetFloat2( rui, "iconScale", <0.5, 0.5, 0> )

	entity waypoint
	foreach( child in ent.GetParent().GetChildren() )
	{
		if ( child != ent )
		{
			waypoint = child
			break
		}
	}

	if ( IsValid(waypoint ) )
		file.waypointToMinimapRui[waypoint] <- rui
}
#endif // CLIENT

#if CLIENT
void function FullmapPackage_Objective( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", CONTROL_OBJ_DIAMOND_EMPTY )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )

	entity waypoint
	foreach( child in ent.GetParent().GetChildren() )
	{
		if ( child != ent )
		{
			waypoint = child
			break
		}
	}

	if ( IsValid(waypoint ) )
		file.waypointToFullmapRui[waypoint] <- rui
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_ProcessObjectiveStateChange( entity objective, int newState, int owner, int lastOwner, int capturer, int lastCapturer, bool didCapturingAllianceBreakLockout )
{
	if ( !IsValid( objective ) )
		return

	entity localViewPlayer = GetLocalViewPlayer()
	if ( !IsValid( localViewPlayer ) )
		return

	// Let threads waiting to update objective states on the Client know that a state change occurred
	Signal( objective, "Control_OnObjectiveStateChanged_Client" )

	int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )
	int objectiveID = objective.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
	string objectiveName = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveID )

	if ( newState == eControlPointObjectiveState.CONTROLLED )
	{
		if ( owner == ALLIANCE_NONE )
		{
			//point is uncontrolled
			Obituary_Print_Localized( Localize( "#CONTROL_UNCONTROLLED_POINT", objectiveName ), GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL ) )
		}
		else
		{
			//point is controlled by team
			string teamName = localPlayerAlliance == owner ? "#PL_YOUR_TEAM" : "#PL_ENEMY_TEAM"
			vector announcementColor = localPlayerAlliance == owner ? GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED ) : GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
			string soundAlias = localPlayerAlliance == owner ? CONTROL_SFX_ZONE_CAPTURED_FRIENDLY : CONTROL_SFX_ZONE_CAPTURED_ENEMY
			Obituary_Print_Localized( Localize( "#CONTROL_CAPTURED_POINT", Localize( teamName ), objectiveName ), announcementColor )

			if ( !file.isLockout && !didCapturingAllianceBreakLockout )
				EmitSoundOnEntity( objective, soundAlias )
		}
	}
	else if ( newState == eControlPointObjectiveState.CONTESTED )
	{
		if ( owner == ALLIANCE_NONE )
		{
			//objective has flipped
			string teamName = localPlayerAlliance != capturer ? "#PL_YOUR_TEAM" : "#PL_ENEMY_TEAM"
			vector announcementColor = localPlayerAlliance != capturer ? GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED ) : GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
			string warningAnnouncement = "#CONTROL_OBJ_FLIPPED"
			vector warningColor = localPlayerAlliance == capturer ? GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED ) : GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
			Obituary_Print_Localized( Localize( "#CONTROL_LOST_POINT", Localize( teamName ), objectiveName ), announcementColor )

			EmitSoundOnEntity( objective, CONTROL_SFX_ZONE_NEUTRALIZED )
		}
	}

	Control_UpdateScoreGenerationOnClient()
}
#endif // CLIENT

#if CLIENT
// Update how much score each team is generating on the Client and the UI
void function Control_UpdateScoreGenerationOnClient()
{
	entity localViewPlayer = GetLocalViewPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	entity localPlayer = GetLocalClientPlayer()
	bool isObserver = GamemodeUtility_IsPlayerOnTeamObserver( localPlayer )

	int localPlayerAlliance = AllianceProximity_GetAllianceFromTeamWithObserverCorrection( localViewPlayer.GetTeam() )
	int enemyAlliance = AllianceProximity_GetOtherAlliance( localPlayerAlliance )

	// If we block points generation based on min number of owned objectives, update the HUD on required objectives to score.
	// First find out how many objectives each Alliance owns
	int minNumOwnedObjectivesToGainScore = Control_GetMinHeldObjectivesToGenerateScore()
	int numObjectivesOwnedByLocalPlayerAlliance = Control_GetNumOwnedObjectivesByAlliance( localPlayerAlliance )
	int numObjectivesOwnedByEnemyAlliance = Control_GetNumOwnedObjectivesByAlliance( enemyAlliance )
	int minNumOwnedPointsFriendly = Control_GetMinHeldObjectivesToGenerateScore_ForAlliance( localPlayerAlliance )
	int minNumOwnedPointsEnemy = Control_GetMinHeldObjectivesToGenerateScore_ForAlliance( enemyAlliance )

	// Update the RUI to show how many objectives are needed to generate score or show what the current score generation rate is.
	// Only show this info if we have set a min number of objectives to be held in order to generate score
	int numObjectivesNeeded = maxint( minNumOwnedPointsFriendly - numObjectivesOwnedByLocalPlayerAlliance, 0 )
	int teamScorePerSec = numObjectivesOwnedByLocalPlayerAlliance >= minNumOwnedPointsFriendly ? numObjectivesOwnedByLocalPlayerAlliance : 0
	int numObjectivesNeededEnemy = maxint( minNumOwnedPointsEnemy - numObjectivesOwnedByEnemyAlliance, 0 )
	int teamScorePerSecEnemy = numObjectivesOwnedByEnemyAlliance >= minNumOwnedPointsEnemy ? numObjectivesOwnedByEnemyAlliance : 0

	if ( minNumOwnedObjectivesToGainScore > 1 )
	{
		var scoreTrackerRui = file.scoreTrackerRui[1]
		var mapScoreTrackerRui = file.fullmapScoreTrackerRui[1]

		if ( IsValid( scoreTrackerRui ) )
		{
			RuiSetBool( scoreTrackerRui, "shouldDisplayMinOwnedObjectiveMessage", true )
			RuiSetInt( scoreTrackerRui, "yourTeamObjectivesNeededToScore", numObjectivesNeeded )
			RuiSetInt( scoreTrackerRui, "teamScorePerSec", teamScorePerSec )
			RuiSetBool( scoreTrackerRui, "shouldDisplayCatchupMechanicMessage", Control_ShouldUseCatchupMechanics() )
			RuiSetInt( scoreTrackerRui, "catchupMechanicScoreDifference", Control_GetPointDiffForCatchupMechanics() )
		}

		if ( IsValid( mapScoreTrackerRui ) )
		{
			RuiSetBool( mapScoreTrackerRui, "shouldDisplayMinOwnedObjectiveMessage", true )
			RuiSetInt( mapScoreTrackerRui, "yourTeamObjectivesNeededToScore", numObjectivesNeeded )
			RuiSetInt( mapScoreTrackerRui, "teamScorePerSec", teamScorePerSec )
			RuiSetBool( mapScoreTrackerRui, "shouldDisplayCatchupMechanicMessage", Control_ShouldUseCatchupMechanics() )
			RuiSetInt( mapScoreTrackerRui, "catchupMechanicScoreDifference", Control_GetPointDiffForCatchupMechanics() )
		}

		// For the enemy team side UI, show what their score generation is per sec
		var scoreTrackerRuiEnemy = file.scoreTrackerRui[0]
		var mapScoreTrackerRuiEnemy = file.fullmapScoreTrackerRui[0]

		if ( IsValid( scoreTrackerRuiEnemy ) )
		{
			RuiSetBool( scoreTrackerRuiEnemy, "shouldDisplayMinOwnedObjectiveMessage", true )
			RuiSetInt( scoreTrackerRuiEnemy, "teamScorePerSec", teamScorePerSecEnemy )
		}

		if ( IsValid( mapScoreTrackerRuiEnemy ) )
		{
			RuiSetBool( mapScoreTrackerRuiEnemy, "shouldDisplayMinOwnedObjectiveMessage", true )
			RuiSetInt( mapScoreTrackerRuiEnemy, "teamScorePerSec", teamScorePerSecEnemy )
		}
	}

	// Update score generation per sec for other HUD elements while we are here ( this avoids passing this value through a servercallback)
	file.teamData[ALLIANCE_A].teamScorePerSec = Control_GetNumOwnedObjectivesByAlliance( ALLIANCE_A )
	file.teamData[ALLIANCE_B].teamScorePerSec = Control_GetNumOwnedObjectivesByAlliance( ALLIANCE_B )
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_BountyClaimedAlert( entity wp, int bountyAmount, int capturingAlliance )
{
	if ( !IsValid( wp ) )
		return

	entity localViewPlayer = GetLocalViewPlayer()
	entity localClientPlayer = GetLocalClientPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	if ( !IsValid( localClientPlayer ) )
		return

	int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )

	string teamName = localPlayerAlliance == capturingAlliance ? "#PL_YOUR_TEAM" : "#PL_ENEMY_TEAM"
	teamName = Localize( teamName )
	string announcementSFX = localPlayerAlliance == capturingAlliance ? CONTROL_SFX_CAPTURE_BONUS_CLAIMED_FRIENDLY : CONTROL_SFX_CAPTURE_BONUS_CLAIMED_ENEMY
	vector announcementColor = localPlayerAlliance == capturingAlliance ? GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED ) : GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
	int objectiveID = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
	string objectiveName = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveID )
	Obituary_Print_Localized( Localize( "#CONTROL_POINT_BOUNTY_CLAIMED_SPECIFIC_OBIT", objectiveName, Localize( teamName ) ), announcementColor )
	AnnouncementMessageRight( GetLocalClientPlayer(), Localize( "#CONTROL_POINT_BOUNTY_CLAIMED_SPECIFIC", objectiveName, teamName ), "", SrgbToLinear( announcementColor / 255 ), $"rui/hud/gametype_icons/control/capture_bonus", CONTROL_MESSAGE_DURATION, announcementSFX, SrgbToLinear( announcementColor / 255 ) )
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_BountyActiveAlert( entity wp )
{
	if ( !IsValid( wp ) )
		return

	entity localViewPlayer = GetLocalViewPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )
	int ownerAlliance = wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
	vector announcementColor = localPlayerAlliance == ownerAlliance ? GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED ) : GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
	int objectiveID = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
	string objectiveName = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveID )

	Obituary_Print_Localized( Localize( "#CONTROL_POINT_BOUNTY_PLACED_SPECIFIC_OBIT", objectiveName ), announcementColor )
	AnnouncementMessageRight( localViewPlayer, Localize( "#CONTROL_POINT_BOUNTY_PLACED_SPECIFIC", objectiveName ), "", SrgbToLinear( announcementColor / 255), $"rui/hud/gametype_icons/control/capture_bonus", CONTROL_MESSAGE_DURATION, CONTROL_SFX_CAPTURE_BONUS_ADDED, SrgbToLinear( announcementColor / 255 ) )
}
#endif // CLIENT

#if CLIENT
bool function Control_Client_IsOnObjective( entity wp, entity player )
{
	if ( !IsValid( player ) || !IsValid( wp ) )
		return false

	return player.GetPlayerNetInt( "control_ObjectiveIndex" ) == wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
}
#endif // CLIENT


#if CLIENT || SERVER
void function Control_UpdateCrowdNoiseMeter()
{
#if SERVER
	thread Control_SVUpdateCrowdNoiseMeterThread()
#else // CLIENT
	thread Control_CLUpdateCrowdNoiseMeterThread()
#endif
}
#endif //

#if CLIENT
void function Control_CLUpdateCrowdNoiseMeterThread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	bool prevShouldTriggerCrowdOneShot = false
	while ( GetGameState() < eGameState.WinnerDetermined )
	{
		wait TIME_BETWEEN_CONTROL_ZONES_CROWD_NOISE_UPDATES

		entity localViewPlayer = GetLocalViewPlayer()
		if ( !IsValid( localViewPlayer ) || localViewPlayer.IsBot() )
			continue

		int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localViewPlayer.GetTeam() )
		bool shouldTriggerCrowdOneShot = false
		foreach ( wp in file.waypointList )
		{
			int cpOwner = wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER )
			int cpAllianceAPlayerCount = wp.GetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ )
			int cpAllianceBPlayerCount = wp.GetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ )
			int cpCapturingAlliance = wp.GetWaypointInt( INT_CAPTURING_ALLIANCE )

			if ( cpAllianceAPlayerCount == cpAllianceBPlayerCount )
			{
				// CONTESTING
				if ( cpAllianceAPlayerCount != 0 )
				{
					shouldTriggerCrowdOneShot = true
				}
			}
			else if ( cpOwner == ALLIANCE_NONE )
			{
				// CAPTURING
				if ( cpCapturingAlliance == localPlayerAlliance )
				{
					shouldTriggerCrowdOneShot = true
				}
			}
			else if ( cpOwner != cpCapturingAlliance )
			{
				// NEUTRALIZING
				if( cpCapturingAlliance == localPlayerAlliance )
				{
					shouldTriggerCrowdOneShot = true
				}
			}
		}

		if ( shouldTriggerCrowdOneShot != prevShouldTriggerCrowdOneShot )
		{
			// TRIGGER ONE SHOT
			prevShouldTriggerCrowdOneShot = shouldTriggerCrowdOneShot
			ToggleCrowdSoundOnEntity( localViewPlayer, eCrowdSound.CAPTURE_START, prevShouldTriggerCrowdOneShot )
		}
	}
}
#endif // CLIENT


/*
   ____  ____       _ ______ _____ _______ _______      ________   _____ _____ _   _  _____  _____
  / __ \|  _ \     | |  ____/ ____|__   __|_   _\ \    / /  ____| |  __ \_   _| \ | |/ ____|/ ____|
 | |  | | |_) |    | | |__ | |       | |    | |  \ \  / /| |__    | |__) || | |  \| | |  __| (___
 | |  | |  _ < _   | |  __|| |       | |    | |   \ \/ / |  __|   |  ___/ | | | . ` | | |_ |\___ \
 | |__| | |_) | |__| | |___| |____   | |   _| |_   \  /  | |____  | |    _| |_| |\  | |__| |____) |
  \____/|____/ \____/|______\_____|  |_|  |_____|   \/   |______| |_|   |_____|_| \_|\_____|_____/


	OBJECTIVE PINGS
*/


#if SERVER || CLIENT
// Is the waypoint a Control Objective Waypoint
bool function Control_IsObjectiveWaypoint( entity waypoint )
{
	return IsValid( waypoint ) && waypoint.GetWaypointType() == eWaypoint.CONTROL_OBJECTIVE
}
#endif // SERVER || CLIENT

#if SERVER
// When the state of the objective changes, clear off pings that are no longer relevant ( in the future we could update the pings here instead)
// ToDo: R5DEV-567005 : Complete refactor to support Capture Objective Pings using Alliances
void function Control_RefreshObjectivePingsOnObjectiveStateChange( ControlPointData data )
{
	entity objectiveWaypoint = data.waypoint
	if ( !IsValid( objectiveWaypoint ) || objectiveWaypoint.GetWaypointType() != eWaypoint.CONTROL_OBJECTIVE )
		return

	int ownerAlliance = data.controlPointOwner
	array<entity> pingsToUpdate
	array < entity > starterPings = CaptureObjectivePing_GetStarterPingsArray()

	foreach ( ping in starterPings )
	{
		if ( !IsValid( ping ) )
			continue

		// Only look for pings that match the objective that changed state
		if ( IsValid( ping ) && IsValid( ping.GetParent() ) && IsValid( ping.GetParent().GetOwner() ) )
		{
			entity pingedObjective = ping.GetParent().GetOwner()
			if ( pingedObjective == objectiveWaypoint )
			{
				int objectiveWaypointPingType = Waypoint_GetPingTypeForWaypoint( ping )
				int pingAlliance = AllianceProximity_GetAllianceFromTeam( ping.GetTeam() )
				bool isPingOwnedByObjectiveOwner = pingAlliance == ownerAlliance

				if ( objectiveWaypointPingType == ePingType.PING_CAPTURE_OBJECTIVE_DEFEND && !isPingOwnedByObjectiveOwner )
				{
					// If the existing ping says defend but the point is no longer owned by that team, update the ping
					pingsToUpdate.append( ping )
				}
				else if ( objectiveWaypointPingType == ePingType.PING_CAPTURE_OBJECTIVE_ATTACK && isPingOwnedByObjectiveOwner )
				{
					// If the existing ping says attack but the point is now controlled by that team, update the ping
					pingsToUpdate.append( ping )
				}
			}
		}

	}
	// Need a parent entity for pings. Also allow players to ping the in world representation of the objective marker directly.
	entity traceBlocker = null
	// ToDo: R5DEV-567005 : Complete refactor to support Capture Objective Pings using Alliances, needing to store the trace blockers like this seems odd
	foreach ( blocker in file.objectiveStarterPingTraceBlockers )
	{
		if ( blocker.GetOwner() == objectiveWaypoint )
		{
			traceBlocker = blocker
			break
		}
	}

	if ( IsValid( traceBlocker ) )
	{
		foreach ( entity ping in pingsToUpdate )
		{
			if ( IsValid( ping ) )
			{
				// Destroy the old starter ping
				CaptureObjectivePing_DestroyStarterPingOnObjective( ping )
				// Create a new ping on the objective that matches the correct objective state
				int pingAlliance = AllianceProximity_GetAllianceFromTeam( ping.GetTeam() )
				if ( ownerAlliance == ALLIANCE_A )
				{
					if ( pingAlliance == ALLIANCE_A )
						CaptureObjectivePing_CreateStarterPingOnObjectiveForTeamOrAlliance( objectiveWaypoint, traceBlocker, ALLIANCE_A, ePingType.PING_CAPTURE_OBJECTIVE_DEFEND )
					else
						CaptureObjectivePing_CreateStarterPingOnObjectiveForTeamOrAlliance( objectiveWaypoint, traceBlocker, ALLIANCE_B, ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )
				}
				else if ( ownerAlliance == ALLIANCE_B )
				{
					if ( pingAlliance == ALLIANCE_A )
						CaptureObjectivePing_CreateStarterPingOnObjectiveForTeamOrAlliance( objectiveWaypoint, traceBlocker, ALLIANCE_A, ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )
					else
						CaptureObjectivePing_CreateStarterPingOnObjectiveForTeamOrAlliance( objectiveWaypoint, traceBlocker, ALLIANCE_B, ePingType.PING_CAPTURE_OBJECTIVE_DEFEND )
				}
				else
				{
					if ( pingAlliance == ALLIANCE_A )
						CaptureObjectivePing_CreateStarterPingOnObjectiveForTeamOrAlliance( objectiveWaypoint, traceBlocker, ALLIANCE_A, ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )
					else if ( pingAlliance == ALLIANCE_B )
						CaptureObjectivePing_CreateStarterPingOnObjectiveForTeamOrAlliance( objectiveWaypoint, traceBlocker, ALLIANCE_B, ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )
				}
			}
		}
	}
	else
	{
		Assert( false, "CONTROL: " + FUNC_NAME() + " Tried to update starter pings but couldn't find an existing traceblocker for " + objectiveWaypoint )
	}
}
#endif // SERVER


#if SERVER
void function Control_OnMatchBehaviorEnd( entity player, bool wasUnexpectedDisconnect )
{
	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	if ( IsValid( player ) )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_SetDeathScreenCallbacks" )

		// If the player completely disconnected from the game during gameplay ( can't reconnect ) force them to drop their loot.
		// This prevents issues like the MRB getting in a bad state.
		if ( Control_GetShouldDropLootOnDeath() && GetGameState() == eGameState.Playing && IsAlive( player ) && player.p.hasMatchParticipationStarted && !player.p.hasMatchParticipationEnded )
		{
			bool shouldDropWeapons = !Control_GetIsPlayerWeaponEvoInProgress( player )
			GamemodeUtility_DropLoot( player, Control_GetDefaultEquipmentTier(), shouldDropWeapons, shouldDropWeapons, true, true, true )
		}
	}
}
#endif // SERVER


#if SERVER
// Run delayed logic that relies on player count changes
// Need to do this because we want to check for player count changes when players leave. But the match behavior end and player disconnected callbacks occur before the player counts get affected.
const float CHECK_FOR_EMPTY_ALLIANCE_DELAY = 3.0
void function Control_RunPlayerCountDependantLogicDelayed_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	OnThreadEnd(
		function() : ()
		{
			Control_RunPlayerCountDependantLogic()
		}
	)

	wait CHECK_FOR_EMPTY_ALLIANCE_DELAY
}
#endif // SERVER

#if SERVER
// Run logic that is dependant on player count changes ( like turning off Leaver Penalty or ending the match if an Alliance has quit )
void function Control_RunPlayerCountDependantLogic()
{
	// Try to end the game if an alliance has left
	Control_TryEndGameFromAllianceForfeit()

	// See if we should end leaver penalty
	Control_TryEndLeaverPenaltyForMatch()
}
#endif // SERVER

#if SERVER
// Test if leaver penalties should be turned off due to unfair player counts
void function Control_TryEndLeaverPenaltyForMatch()
{
	if ( GetGameState() == eGameState.Playing && GetGlobalNetBoolSafe( "mixtape_isLeaverPenaltyEnabledForMatch" ) )
	{
		// Check if player counts make a fair match (for leaver penalty)
		int ACount = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_A, false )
		int BCount = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_B, false )

		// There needs to be the equivalent of a missing squad between team player counts for it to be reasonable to leave
		// i.e. 12 v 9, 10 v 7, 7 v 4 for squads of 3
		int squadSize           = GetCurrentPlaylistVarInt( "max_players", CONTROL_DEFAULT_MAX_PLAYERS ) / GetCurrentPlaylistVarInt( "max_teams", 6 )
		bool areAlliancesUneven = abs( ACount - BCount ) >= squadSize

		// If we lost too many players (2/3 of total player count)
		int playerCountTarget = int( GetCurrentPlaylistVarInt( "max_players", CONTROL_DEFAULT_MAX_PLAYERS ) * (2.0 / 3.0) )
		bool isPlayerCountLow = ACount + BCount <= playerCountTarget

		SetGlobalNetBoolSafe( "mixtape_isLeaverPenaltyEnabledForMatch", ( !areAlliancesUneven && !isPlayerCountLow ) )
	}
}
#endif // SERVER

#if SERVER
// Test to see if we should be ending the game early because a full alliance is missing
void function Control_TryEndGameFromAllianceForfeit()
{
	// Test to see if there is an empty team, end the game early if there is
	int allianceAPlayerCount = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_A, false )
	int allianceBPlayerCount = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_B, false )

	if ( allianceAPlayerCount == 0 && allianceBPlayerCount == 0 )
		Control_SetWinner( GamemodeUtility_GetWinningAlliance( false ), eWinReason.TEAM_FORFEIT )
	else if ( allianceAPlayerCount == 0 )
		Control_SetWinner( ALLIANCE_B, eWinReason.TEAM_FORFEIT )
	else if ( allianceBPlayerCount == 0 )
		Control_SetWinner( ALLIANCE_A, eWinReason.TEAM_FORFEIT )
}
#endif // SERVER

#if CLIENT || SERVER
// Players are allowed to ping the traceblocker volume around the in world representation of the objective. But, we want these pings to be treated the same as an objective ping.
// This function takes the pinged traceblocker volume and returns the ping that belongs to the objective so we can ping that instead or it returns a null if something else got pinged.
entity function Control_GetStarterPingFromTraceBlockerPing( entity pingedEnt, int playerTeam )
{
	entity starterPing = null

	if ( IsValid( pingedEnt ) && pingedEnt.GetScriptName() == CONTROL_OBJECTIVE_SCRIPTNAME && IsValid( pingedEnt.GetOwner() ) )
	{
		array<entity> objectiveStartPings = CaptureObjectivePing_GetStarterPingsArray()

		if ( objectiveStartPings.len() > 0 )
		{
			entity objective = pingedEnt.GetOwner()
			int pingType

			foreach ( ping in objectiveStartPings )
			{
				if ( !IsValid( ping ) )
					continue

				// Only look for pings that match the objective and player team
				if ( IsValid( ping ) && IsValid( ping.GetParent() ) && IsValid( ping.GetParent().GetOwner() ) )
				{
					entity pingedObjective = ping.GetParent().GetOwner()
					if ( pingedObjective == objective )
					{
						int objectiveWaypointPingType = Waypoint_GetPingTypeForWaypoint( ping )
						bool isPingTeamPlayerTeam = AllianceProximity_GetAllianceFromTeam( playerTeam ) == AllianceProximity_GetAllianceFromTeam( ping.GetTeam() )

						if ( isPingTeamPlayerTeam )
						{
							starterPing = ping
							pingType = objectiveWaypointPingType
						}
					}
				}
			}
		}
	}

	return starterPing
}
#endif // CLIENT || SERVER

#if CLIENT
// Determine if a comms action is related to a Control Objective Ping
bool function Control_IsControlObjectiveCommsAction( int commsAction, entity subjectEnt )
{
	bool isControlObjectiveCommsAction = false

	if ( GameMode_IsActive( eGameModes.CONTROL ) )
	{
		if ( commsAction == eCommsAction.PING_CONTROL_OBJECTIVE_ATTACK || commsAction == eCommsAction.PING_CONTROL_OBJECTIVE_DEFEND )
		{
			entity owner = subjectEnt.GetOwner()
			if ( IsValid( owner ) && IsPlayerWaypoint( owner ) && owner.GetWaypointType() == eWaypoint.CONTROL_OBJECTIVE )
				isControlObjectiveCommsAction = true
		}
	}

	return isControlObjectiveCommsAction
}
#endif // CLIENT

#if CLIENT || SERVER
// Grab the objective index from the objective waypoint
int function Control_GetObjectiveIDFromWaypoint( entity waypoint )
{
	return waypoint.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return whether we are triggering catchup mechanics based on team score difference or player count difference
bool function Control_ShouldUseCatchupMechanics()
{
	return Control_GetAllianceUsingCatchupMechanics() != ALLIANCE_NONE
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return the alliance that has catchup mechanics triggered on it due to score difference or team inbalance. If return ALLIANCE_NONE no catchup mechanics are being used
int function Control_GetAllianceUsingCatchupMechanics()
{
	int allianceUsingCatchupMechanics = ALLIANCE_NONE
	int losingAlliance = ALLIANCE_NONE

	// Determine which Alliance should use catchup mechanics if there is a large enough score difference
	int scoreDifference = AllianceProximity_GetAllianceScoreDifference()

	// We only do catchup mechanics if there is a losing team
	if ( scoreDifference > 0 )
	{
		losingAlliance = AllianceProximity_GetOtherAlliance( GamemodeUtility_GetWinningAlliance( false ) )

		if ( scoreDifference >= Control_GetPointDiffForCatchupMechanics() )
		{
			allianceUsingCatchupMechanics = losingAlliance
		}
		else if ( Control_ShouldTriggerCatchupMechanicsForTeamInBalance() )
		{
			// If the point difference isn't enough to trigger catch up mechanics, check if we enable them for a team player count inbalance ( only if the team is also losing )
			int allianceAPlayerNum = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_A, false )
			int allianceBPlayerNum = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_B, false )

			if ( allianceAPlayerNum != allianceBPlayerNum )
			{
				int allianceWithLessPlayers = allianceAPlayerNum > allianceBPlayerNum ? ALLIANCE_B : ALLIANCE_A
				if ( allianceWithLessPlayers == losingAlliance )
					allianceUsingCatchupMechanics = losingAlliance
			}
		}
	}

	return allianceUsingCatchupMechanics
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the minimum number of objectives a specific Alliance needs to hold in order to generate score.
// This is used because the majority held objectives rule can be applied to only the winning team.
// In that scenario one team might only need to hold 1 objective to generate score while the other team might need to hold 2 points
int function Control_GetMinHeldObjectivesToGenerateScore_ForAlliance( int alliance )
{
	int minNumOwnedObjectivesToGainScore = Control_GetMinHeldObjectivesToGenerateScore()
	return ( minNumOwnedObjectivesToGainScore > 0 && ( !Control_GetIsMinHeldObjectivesOnlyForWinningTeam() || Control_ShouldUseCatchupMechanics() && GamemodeUtility_GetWinningAlliance( true ) == alliance ) ) ? minNumOwnedObjectivesToGainScore : 0
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
int function Control_GetNumOwnedObjectivesByAlliance( int alliance )
{
	int numOwnedObjectives = 0

	#if SERVER
		foreach( point in file.chosenVariantData.controlPoints )
		{
			if ( point.controlPointOwner == alliance )
				numOwnedObjectives++
		}
	#endif // SERVER

	#if CLIENT
		foreach( wp in file.waypointList )
		{
			if ( Control_IsObjectiveWaypoint( wp ) )
			{
				int objectiveOwner = wp.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
				if ( objectiveOwner == alliance )
					numOwnedObjectives++
			}
		}
	#endif // CLIENT

	return numOwnedObjectives
}
#endif // CLIENT || SERVER

/*
   _____   _____              __          __  _   _
  / ____| |  __ \      /\     \ \        / / | \ | |
 | (___   | |__) |    /  \     \ \  /\  / /  |  \| |
  \___ \  |  ___/    / /\ \     \ \/  \/ /   | . ` |
  ____) | | |       / ____ \     \  /\  /    | |\  |
 |_____/  |_|      /_/    \_\     \/  \/     |_| \_|


  __  __              _   _               _____   ______   __  __   ______   _   _   _______
 |  \/  |     /\     | \ | |     /\      / ____| |  ____| |  \/  | |  ____| | \ | | |__   __|
 | \  / |    /  \    |  \| |    /  \    | |  __  | |__    | \  / | | |__    |  \| |    | |
 | |\/| |   / /\ \   | . ` |   / /\ \   | | |_ | |  __|   | |\/| | |  __|   | . ` |    | |
 | |  | |  / ____ \  | |\  |  / ____ \  | |__| | | |____  | |  | | | |____  | |\  |    | |
 |_|  |_| /_/    \_\ |_| \_| /_/    \_\  \_____| |______| |_|  |_| |______| |_| \_|    |_|

                                                                                             */
#if SERVER
void function Control_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	if ( IsValid( victim ) )
	{
		victim.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_RESPAWN )

		// Drop loot, no deathbox
		if ( Control_GetShouldDropLootOnDeath() )
		{
			bool shouldDropWeapons = !Control_GetIsPlayerWeaponEvoInProgress( victim )
			GamemodeUtility_DropLoot( victim, Control_GetDefaultEquipmentTier(), shouldDropWeapons, shouldDropWeapons, true, true, true )
		}
		entity activeWeapon = victim.GetActiveWeapon( eActiveInventorySlot.mainHand )
		entity ultimateWeapon = victim.GetOffhandWeapon( OFFHAND_ULTIMATE )

		if( IsValid( activeWeapon ) && IsValid( ultimateWeapon ))
		{
			int ultimateCharge      = ultimateWeapon.GetWeaponPrimaryClipCount()
			int ultimateAmmoPerShot = ultimateWeapon.GetAmmoPerShot()

			bool hasDropOnDeath = bool(GetWeaponInfoFileKeyField_GlobalInt_WithDefault( ultimateWeapon.GetWeaponClassName(), "drops_on_death", 0 ))

			if ( activeWeapon == ultimateWeapon && hasDropOnDeath )
			{
				ultimateCharge = ultimateCharge - ultimateAmmoPerShot
				ultimateWeapon.SetWeaponPrimaryClipCount( ultimateCharge )
			}
		}

		GamemodeUtility_SpawnBonusLootOnPlayer( victim )

		// Check if the player had a full ult charge on death, if they did, store it for respawn if we are giving it back
		if ( Control_IsPlayerSpawnWithFullUlt( victim ) && !file.playersWithFullUltOnDeath.contains( victim ))
			file.playersWithFullUltOnDeath.append( victim )

		thread Control_RespawnPlayerAfterDelay( victim )
		thread Control_ClearExpLeaderStatusFromPlayer_Thread( victim, attacker )
	}

	if ( victim == attacker )
		return

	if ( IsValidPlayer( attacker ) && victim.e.hasSpawnKillDetection )
	{
		//process spawn kill detection
		Control_SonarSpawnKiller( victim, attacker )

		array<entity> playersToNotify
		foreach ( otherPlayer in GetPlayerArray_AliveConnected() )
		{
			if ( IsFriendlyTeam( victim.GetTeam(), otherPlayer.GetTeam() ) )
				playersToNotify.append( otherPlayer )
		}

		thread PlayCommentaryLineToPlayerArray( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_BASE_CAMPER_DETECTED ), playersToNotify, "" )
	}

	// Show death icon on the map
	Control_DisplayIconForTeammatesAtPlayerPos( victim, eControlIconIndex.DEATH_ICON, CONTROL_TEAMMATE_DEATH_ICON_LIFETIME )
}
#endif // SERVER

#if SERVER
bool function Control_IsPlayerSpawnWithFullUlt( entity victim )
{
	if ( !Control_GetShouldRestoreFullUltOnRespawn() )
		return false

	entity ultimateWeapon = victim.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if ( !IsValid( ultimateWeapon ) )
		return 	false

	int currentUltCharge = ultimateWeapon.GetWeaponPrimaryClipCount()
	int maxUltCharge = ultimateWeapon.GetWeaponPrimaryClipCountMax()
	if ( currentUltCharge >= maxUltCharge )
		return true

	return false
}
#endif // SERVER

#if SERVER
// Manage EXP Leader score thresholds and messaging if the victim was the EXP Leader
void function Control_ClearExpLeaderStatusFromPlayer_Thread( entity player, entity killer )
{
	Assert( IsNewThread(), "Must be threaded off" )

	WaitFrame()

	if ( !IsValid( player ) && !IsValid( killer ) )
		return

	if ( player == file.expLeader )
	{
		file.expLeader = null
		if ( IsValid( player ) && GradeFlagsHas( player, eTargetGrade.EXP_LEADER ) )
			GradeFlagsClear( player, eTargetGrade.EXP_LEADER )

		if ( !GamemodeUtility_IsWinnerBeingDetermined() )
			thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_RATINGS_LEADER_ELIMINATED ) )

		array<entity> allPlayersAndSpectatorsArray = GetPlayerArrayIncludingSpectators()
		foreach ( arrayPlayer in allPlayersAndSpectatorsArray )
		{
			Remote_CallFunction_NonReplay( arrayPlayer, "ServerCallback_Control_EXPLeaderKilled", killer, player )
		}

		thread Control_UpdateEXPLeaderEXPThreshold_Thread()
	}
}
#endif // SERVER

#if SERVER
void function Control_OnSpawnAreaTriggerEnter( entity trigger, entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	file.chosenVariantData.triggerToSpawnDataMap[ trigger ].playersInSpawnTriggers.append( player )
}
#endif // SERVER

#if SERVER
void function Control_OnSpawnAreaTriggerExit( entity trigger, entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	file.chosenVariantData.triggerToSpawnDataMap[ trigger ].playersInSpawnTriggers.fastremovebyvalue( player )
}
#endif // SERVER

#if SERVER
float function Control_DeathCamTimeOverride()
{
	if ( GetGameState() >= eGameState.Epilogue )
		return DEATHCAM_TIME_SHORT

	float currentTime = Time()
	float deathScreenTime = Control_GetNextDeathScreenTime()

	return deathScreenTime - currentTime
}
#endif // SERVER

#if SERVER
// Loop through and manage the state of wave spawns
// Spawn players in groups when each spawn wave ends.
// NOTE: Players that are exempt from wave spawns do not spawn here, they will spawn in the Control_ProcessPlayerRespawnInput function
void function Control_ManageWaveSpawnIntervals_Thread( )
{
	Assert( IsNewThread(), "Must be threaded off" )

	// Prevent players from respawning once we are determining the winner.
	// All players are placed on the same team at the end of the match and there can be issues with respawn checks ( making sure players aren't using dupe characters).
	while ( !GamemodeUtility_IsWinnerBeingDetermined() )
	{
		float currentTime = Time()
		float waveInterval = Control_GetRespawnWaveInterval()
		SetGlobalNetTimeSafe( "control_WaveStartTime", currentTime )
		SetGlobalNetTimeSafe( "control_WaveSpawnTime", currentTime + waveInterval )

		foreach ( player in GetPlayerArray() )
		{
			if ( IsValid( player ) )
			{
				// If a player was waiting on the last wave to finish before being added to wave spawn exemption, add them to it now
				if ( file.playersPendingExemptionFromWaveSpawn.contains( player ) )
				{
					Control_SetPlayerExemptFromWaveSpawn( player )
				}

				// Update time on the Wave Spawn Timer
				Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdateSpawnWaveTimerTime" )
			}
		}

		wait waveInterval - CONTROL_PRE_SPAWN_BUTTON_DISABLE_TIME

		// Prepare to spawn players that were queued up to spawn in this spawn wave
		array< entity > playersPendingSpawn = Control_GetPlayersWaitingToSpawnInWaveArray()

		foreach ( spawnWavePlayer in playersPendingSpawn )
		{
			if ( IsValid( spawnWavePlayer ) )
			{
				bool isFirstSpawn = !file.playerFirstSpawnList.contains( spawnWavePlayer )
				// Disable loadout and legend select menus to prevent issues with switching these right on spawn
				Remote_CallFunction_UI( spawnWavePlayer, "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", false )

				//first time spawn music - wait until only some time is left
				if ( isFirstSpawn )
				{
					string music = GetMusicForJump( spawnWavePlayer )
					if ( music.len() > 0 )
						SignalSoundOnEntity( spawnWavePlayer, music )

					file.playerFirstSpawnList.append( spawnWavePlayer )
				}
			}
		}

		wait CONTROL_PRE_SPAWN_BUTTON_DISABLE_TIME

		// Spawn players that were queued up to spawn in this spawn wave
		array < entity > playersSpawningOnMRB

		// Grab a new list of players since it is possible someone selected a spawn between the last wait time
		playersPendingSpawn = Control_GetPlayersWaitingToSpawnInWaveArray()
		foreach ( spawnWavePlayer in playersPendingSpawn )
		{
			if ( IsValid( spawnWavePlayer ) && spawnWavePlayer in file.playerToRespawnChoice )
			{
				int respawnChoice = file.playerToRespawnChoice[ spawnWavePlayer ]

				Remote_CallFunction_UI( spawnWavePlayer, "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", false )

				// This is a special case, we need to put all these players together and try to split them up in dropships so we don't end up with 1 dropship per player
				if ( respawnChoice == eControlWaypointTypeIndex.MRB_SPAWN )
				{
					playersSpawningOnMRB.append( spawnWavePlayer )
					continue
				}
				Control_AttemptToSpawnPlayerOnSpawnPoint( spawnWavePlayer, respawnChoice )
			}
		}

		// Spawn the players that were spawning on the mrb in a group
		if ( playersSpawningOnMRB.len() > 0 )
			Control_RespawnPlayersOnMRB( playersSpawningOnMRB )

		// If this was the first wave spawn, set to false and handle making players exempt from that spawn wave
		if ( file.isFirstWaveSpawn )
		{
			file.isFirstWaveSpawn = false

			// If any players didn't spawn during the first wave, allow them to skip waiting for another wave.
			foreach ( player in GetPlayerArray() )
			{
				if ( IsValid( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) && !IsAlive( player ) )
				{
					Control_SetPlayerExemptFromWaveSpawn( player )
				}
			}

			// Test to see if the game is missing an alliance or players after the first spawn wave
			Control_RunPlayerCountDependantLogic()
		}
	}
}
#endif // SERVER

#if SERVER
// Get an array of players currently waiting to spawn that have made a spawn selection
array < entity > function Control_GetPlayersWaitingToSpawnInWaveArray()
{
	array< entity > playersPendingSpawn

	foreach( player in GetPlayerArray() )
	{
		if ( player in file.playerToRespawnChoice && !player.GetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn" ) )
			playersPendingSpawn.append( player )
	}

	return playersPendingSpawn
}
#endif // SERVER

#if SERVER
// Allow a player to spawn as soon as they select a spawn point instead of waiting for a spawn wave ( used in a few special situations like if a spawn failed or they stuck around past the first long spawn wave)
void function Control_SetPlayerExemptFromWaveSpawn( entity player )
{
	if ( !IsValid( player ) )
		return

	player.SetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn", true )
	if ( file.playersPendingExemptionFromWaveSpawn.contains( player ) )
		file.playersPendingExemptionFromWaveSpawn.fastremovebyvalue( player )
	// Update the visibility on the Wave Spawn Timer
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdateSpawnWaveTimerVisibility", false )
}
#endif // SERVER

#if SERVER
// Get the current length of time between spawn waves. We can use a different length for first spawn since we force players to open loadout select at that time
float function Control_GetRespawnWaveInterval()
{
	float waveInterval
	if ( !file.isFirstWaveSpawn )
	{
		waveInterval = GetCurrentPlaylistVarFloat( "control_respawn_wave_interval", 10 )
	}
	else
	{
		waveInterval = GetCurrentPlaylistVarFloat( "control_first_respawn_wave_interval", 10 )
	}

	return waveInterval
}
#endif // SERVER

#if SERVER
// Try to spawn the player on their selected spawnpoint
void function Control_AttemptToSpawnPlayerOnSpawnPoint( entity player, int respawnChoice )
{
	entity entityToSpawnOn = Control_GetEntityToSpawnOnFromRespawnChoice( respawnChoice )
	bool success = false
	Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint" )

	if ( IsValid( player ) )
	{
		// Try to spawn, if spawn fails turn off wave spawns for this player so they can attempt to spawn again
		if ( Control_IsSpawnWaypointIndexAHomebase( respawnChoice ) )
		{
			Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint will try to spawn the player at homebase" )
			success = Control_RespawnPlayerAtHomeBase( player, !file.isFirstWaveSpawn )
		}
		else if ( Control_IsSpawnWaypointIndexAnObjective( respawnChoice ) && IsValid( entityToSpawnOn ) && entityToSpawnOn.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER) == AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) )
		{
			Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint will try to spawn the player at an objective" )
			success = Control_RespawnPlayerOnPoint( player, respawnChoice, entityToSpawnOn, !file.isFirstWaveSpawn )
		}
		else
		{
			Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint not spawning the player on anything" )
		}
	}
	else
	{
		Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint not spawning the player is INVALID" )
	}

	// If spawning was successful, disable spawning for the player. Otherwise cancel the failed spawn and let the player try again
	if ( success )
	{
		Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint spawn successful" )
		Control_HandleSpawnSuccess( player, respawnChoice )
	}
	else
	{
		Control_PrintSpawningDebug( player, respawnChoice, entityToSpawnOn, true, "Control_AttemptToSpawnPlayerOnSpawnPoint spawn failed" )
		Control_HandleSpawnFailure( player, respawnChoice, entityToSpawnOn )
	}
}
#endif // SERVER

#if SERVER
// Display a message to the player and make them exempt from the spawn wave if their spawn failed
void function Control_HandleSpawnFailure( entity player, int spawnChoice, entity entityToSpawnOn )
{
	Control_PrintSpawningDebug( player, spawnChoice, entityToSpawnOn, true, "Control_HandleSpawnFailure running" )
	if ( IsValid( player ) )
	{
		if ( !file.playersAbleToSelectSpawnArray.contains( player ) )
			file.playersAbleToSelectSpawnArray.append( player )

		string spawnType = Control_IsSpawnWaypointIndexAnObjective( spawnChoice ) ? CONTROL_PINEVENT_RESPAWNCHOICE_POINT : CONTROL_PINEVENT_RESPAWNCHOICE_BASE
		vector spawnLoc = <-1,-1,-1>
		if ( IsValid( entityToSpawnOn ) )
			spawnLoc = entityToSpawnOn.GetOrigin()

		//PIN_PlayerSpawnedFromMenu( player, spawnLoc, player.GetOrigin(), spawnType, CONTROL_PINEVENT_RESPAWNCHOICE_FAILED )

		player.SetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn", true )
	}

	Control_CancelSpawnSelection( player, eControlSpawnAlertCode.SPAWN_FAILED )
}
#endif // SERVER

#if SERVER
// Clean up the player from the tables and arays that were storing their spawn choices
void function Control_HandleSpawnSuccess( entity player, int respawnChoice )
{
	Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_HandleSpawnSuccess" )
	if ( file.playersAbleToSelectSpawnArray.contains( player ) )
		file.playersAbleToSelectSpawnArray.fastremovebyvalue( player )

	file.playerToLastRespawnChoice[player] <- respawnChoice // Used to determine how much Exp the player should gain on respawn since the player spawn choice is cleared before respawn occurs
	Control_CleanupSpawnState( player )
	player.SetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen", false )
}
#endif // SERVER

#if SERVER
void function Control_RespawnPlayerAfterDelay( entity player )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )

	float deathScreenTime = Control_GetNextDeathScreenTime()
	player.SetPlayerNetTime( "respawnStatusEndTime", deathScreenTime )
	player.SetPlayerNetTime( "hackStartTime", Time() )
	WaitFrame()

	if ( !IsValid( player ) )
		return

	if ( Bleedout_IsBleedingOut( player ) )
	{
		//Temp hack till permanent fix for R5DEV-157040
		Bleedout_ForceStop( player )
		BleedoutState_SetPlayerBleedoutState( player, BS_NOT_BLEEDING_OUT )
	}
	Remote_CallFunction_NonReplay( player, "ServerCallback_RespawnPodStarted", deathScreenTime )

	if ( Control_GetShouldSkydiveRespawn() )
	{
		float spawnTime = deathScreenTime - Time()
		wait deathScreenTime - Time()

		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt("CONTROL: Control_RespawnPlayerAfterDelay going to spawn the player: ", player, " at homebase" )

		Control_RespawnPlayerAtHomeBase(player)
		player.SetPlayerNetBool( "hasDeathFieldImmunity", true )
		PlayerMatchState_Set( player, ePlayerMatchState.SKYDIVE_FALLING )

		thread PlayerSkydiveFromCurrentPosition( player )
	}

}
#endif // SERVER

#if SERVER
// Get the time when the deathscreen should be dismissed
float function Control_GetNextDeathScreenTime()
{
	float currentTime = Time()
	float nextDeathScreenTime = currentTime + Control_GetMaxDeathScreenTime()
	return nextDeathScreenTime
}
#endif // SERVER

#if SERVER
void function Control_ExtendedPostDeathLogic( entity player )
{
	if ( !IsValid( player ) )
		return
	if ( GetGameState() != eGameState.Playing )
		return

	if ( !file.isLockout && !file.isRampUp )
		PlayMusicToPlayer( player, "Music_Ctrl_Spawn" )
	// Update currently selected Loadout Text on the spawn screen near the Change Loadout Button

	if(Control_GetShouldSkydiveRespawn())
	{
		if ( IsUsingLoadoutSelectionSystem() )
			LoadoutSelection_UpdateLoadoutInfoForMenus( player )
	}
	else
	{
		SetPlayerForSpawnSelection( player )
	}

	thread Control_ChooseBotRespawnLocation_Thread( player )

	player.WaitSignal( "Control_PlayerRespawning" )
}
#endif // SERVER

#if SERVER
void function SetPlayerForSpawnSelection( entity player )
{
	player.SetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn", false )

	// Allow late join spawners to bypass spawn waves on their first spawn
	if ( GamemodeUtility_IsJIPPlayerSpawnBonusPending( player ) || !Control_GetSpawnWaveEnabled())
	{
		Control_SetPlayerExemptFromWaveSpawn( player )
	}
	else if ( Control_ShouldSkipSpawnWaveForCatchupMechanic() ) // Set player to skip spawn wave if their alliance is using catchup mechanics
	{
		int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
		if ( playerAlliance != ALLIANCE_NONE && playerAlliance == Control_GetAllianceUsingCatchupMechanics() )
			Control_SetPlayerExemptFromWaveSpawn( player )
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdateSpawnWaveTimerVisibility", false )
	player.SetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen", true )
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_TransferCameraData", file.cameraLocation, file.cameraAngles )

	if ( !file.playersAbleToSelectSpawnArray.contains( player ) )
		file.playersAbleToSelectSpawnArray.append( player )

	// Update currently selected Loadout Text on the spawn screen near the Change Loadout Button
	if ( IsUsingLoadoutSelectionSystem() )
		LoadoutSelection_UpdateLoadoutInfoForMenus( player )

	#if DEV
		Signal( player, "Control_Dev_PlayerReachedSpawnSelect" )
	#endif // DEV
}
#endif // SERVER

#if SERVER
void function Control_ChooseBotRespawnLocation_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( player.IsBot() )
	{
		wait RandomFloatRange( CONTROL_MIN_TIME_BEFORE_BOTS_SPAWN, CONTROL_MAX_TIME_BEFORE_BOTS_SPAWN )

		if ( IsValid( player ) )
		{
			int botAllianceIndex = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
			entity bestSpawnForBot = Control_GetBestSpawnLocationForAlliance( botAllianceIndex )
			int respawnChoice = Control_GetRespawnChoiceFromSpawnWaypoint( bestSpawnForBot )
			thread SpawnBotOnChoice( player, respawnChoice )
		}
	}
}
#endif // SERVER

#if SERVER || CLIENT
// Get the best spawn location based on expected player behaviours
// Note if you are passing the result of this function directly into a function that will spawn the entity;
// you need to get the entity to spawn on using Control_GetEntityToSpawnOnFromRespawnChoice passing in the entity you get from this function.
entity function Control_GetBestSpawnLocationForAlliance( int alliance )
{
	// Populate spawn entities then pick the best one from the valid entities we have
	entity mrbSpawn = null
	entity bSpawn = null
	entity aOrCSpawn = null
	entity homeSpawn = null

	// Go through all Spawns
	foreach( point in file.spawnWaypoints )
	{
		if ( IsValid( point ) )
		{
			int waypointTypeIndex = point.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
			switch( waypointTypeIndex )
			{
				case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
					if ( alliance == ALLIANCE_A )
						homeSpawn = point
					break
				case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
					if ( alliance == ALLIANCE_B )
						homeSpawn = point
					break
				case eControlWaypointTypeIndex.OBJECTIVE_A:
					entity objectiveWaypoint = point.GetParent()
					if ( IsValid( objectiveWaypoint ) )
					{
						int waypointOwner = objectiveWaypoint.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)

						// Make sure the objective is owned by the player alliance and the player alliance is Alliance A ( only allow spawning on A or C objective if it is your teams FOB ( objective closest to alliance homebase ))
						if ( alliance == waypointOwner && alliance == ALLIANCE_A  )
								aOrCSpawn = point
					}
					break
				case eControlWaypointTypeIndex.OBJECTIVE_B:
					entity objectiveWaypoint = point.GetParent()
					if ( IsValid( objectiveWaypoint ) && Control_CanAllianceMemberSpawnOnObjectiveB( alliance ) )
						bSpawn = point
					break
				case eControlWaypointTypeIndex.OBJECTIVE_C:
					entity objectiveWaypoint = point.GetParent()
					if ( IsValid( objectiveWaypoint ) )
					{
						int waypointOwner = objectiveWaypoint.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)

						// Make sure the objective is owned by the player alliance and the player alliance is Alliance B ( only allow spawning on A or C objective if it is your teams FOB ( objective closest to alliance homebase ))
						if ( alliance == waypointOwner && alliance == ALLIANCE_B  )
							aOrCSpawn = point
					}
					break
				case eControlWaypointTypeIndex.MRB_SPAWN:
					int waypointOwner = point.GetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX )
					if ( alliance == waypointOwner )
						mrbSpawn = point
					break
				default:
					break
			}
		}
	}

	// Pick the best spawn point from available spawns
	if ( mrbSpawn != null )
	{
		return mrbSpawn
	}
	else if ( bSpawn != null )
	{
		return bSpawn
	}
	else if ( aOrCSpawn != null )
	{
		return aOrCSpawn
	}
	else if ( homeSpawn != null )
	{
		return homeSpawn
	}

	Assert( false, "CONTROL: No valid spawns found when running the Control_GetBestSpawnLocationForAlliance function" )
	return null
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Get the respawn choice int ( waypoint type index ) from the spawn entity, if it is a valid spawn waypoint otherwise return -1
int function Control_GetRespawnChoiceFromSpawnWaypoint( entity spawnWaypoint )
{
	int respawnChoice = -1

	if ( IsValid( spawnWaypoint ) )
	{
		int waypointTypeIndex = spawnWaypoint.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )

		if ( Control_IsValidRespawnChoice( waypointTypeIndex ) )
			respawnChoice = waypointTypeIndex
		else
			Warning( "Control: Running Control_GetRespawnChoiceFromSpawnWaypoint with an Invalid waypointTypeIndex: %i", waypointTypeIndex )
	}
	else
	{
		printt( "CONTROL: Control_GetRespawnChoiceFromSpawnWaypoint called with an Invalid spawnWaypoint" )
	}

	return respawnChoice
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Respawn choices are based off of spawn waypoints but the entities players actually spawn on sometimes differ. This function returns the entity that should be passed to the spawn system
entity function Control_GetEntityToSpawnOnFromRespawnChoice( int respawnChoice )
{
	entity entityToSpawnOn = null
	entity spawnWaypoint = file.spawnWaypoints[ respawnChoice ]

	if ( IsValid( spawnWaypoint ) )
	{
		switch( respawnChoice )
		{
			case eControlWaypointTypeIndex.OBJECTIVE_A:  // get objective
			case eControlWaypointTypeIndex.OBJECTIVE_B:  // get objective
			case eControlWaypointTypeIndex.OBJECTIVE_C:  // get objective
			case eControlWaypointTypeIndex.MRB_SPAWN: // get mrb entity
			case eControlWaypointTypeIndex.SQUAD_SPAWN: // get player
				entityToSpawnOn = spawnWaypoint.GetParent()
				break
			default:
				break
		}
	}
	else
	{
		printt( "CONTROL: Control_GetEntityToSpawnOnFromRespawnChoice called with an invalid spawnWaypoint" )
	}

	return entityToSpawnOn
}
#endif // SERVER || CLIENT

// Determine if a point is a forward operating base ( objectives closest to alliance homebases)
bool function Control_IsPointAnFOB( int pointIndex )
{
	return pointIndex == eControlWaypointTypeIndex.OBJECTIVE_A || pointIndex == eControlWaypointTypeIndex.OBJECTIVE_C
}

// Return whether the waypoint index represents a spawn point that is the Forward Operating Base ( Objective closest to the Homebase ) of the passed in alliance
bool function Control_IsSpawnWaypointFOBForAlliance( int waypointIndex, int alliance )
{
	return ( waypointIndex == eControlWaypointTypeIndex.OBJECTIVE_A && alliance == ALLIANCE_A ) || ( waypointIndex == eControlWaypointTypeIndex.OBJECTIVE_C && alliance == ALLIANCE_B )
}

// Return whether the waypoint index represents the homebase spawn of the passed in alliance
bool function Control_IsSpawnWaypointHomebaseForAlliance( int waypointIndex, int alliance )
{
	return ( waypointIndex == eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A && alliance == ALLIANCE_A ) || ( waypointIndex == eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B && alliance == ALLIANCE_B )
}

// Determine if a waypoint type index is for an objective waypoint
bool function Control_IsSpawnWaypointIndexAnObjective( int waypointIndex )
{
	return waypointIndex == eControlWaypointTypeIndex.OBJECTIVE_A || waypointIndex == eControlWaypointTypeIndex.OBJECTIVE_B || waypointIndex == eControlWaypointTypeIndex.OBJECTIVE_C
}

#if SERVER || CLIENT
// Determine if a waypoint type index is for a homebase spawn
bool function Control_IsSpawnWaypointIndexAHomebase( int waypointIndex )
{
	return waypointIndex == eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A || waypointIndex == eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Determine if a member of the passed in Alliance would be able to spawn on Objective B
// Objective B Spawning requires that an Alliance controls the Objective closest to their homebase and Objective B in order to spawn on it
bool function Control_CanAllianceMemberSpawnOnObjectiveB( int alliance )
{
	if ( alliance != ALLIANCE_A && alliance != ALLIANCE_B )
		return false

	if ( !Control_IsSpawningOnObjectiveBAllowed() )
		return false

	entity objectiveBWaypoint = file.spawnWaypoints[ eControlWaypointTypeIndex.OBJECTIVE_B ]
	entity fobObjectiveWaypoint = alliance == ALLIANCE_A ? file.spawnWaypoints[ eControlWaypointTypeIndex.OBJECTIVE_A ] : file.spawnWaypoints[ eControlWaypointTypeIndex.OBJECTIVE_C ]
	int objectiveBOwner = ALLIANCE_NONE
	int fobObjectiveOwner = ALLIANCE_NONE

	// Check which alliance owned Objective B
	if ( IsValid( objectiveBWaypoint ) )
	{
		entity waypointParent = objectiveBWaypoint.GetParent()
		if ( IsValid( waypointParent ) )
			objectiveBOwner = waypointParent.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
	}

	// If Objective B is not owned by the alliance they definitely won't be able to spawn on it, break out
	if ( objectiveBOwner != alliance )
		return false

	// Check which alliance owns the FOB
	if ( IsValid( fobObjectiveWaypoint ) )
	{
		entity waypointParent = fobObjectiveWaypoint.GetParent()
		if ( IsValid( waypointParent ) )
			fobObjectiveOwner = waypointParent.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
	}

	// If the FOB is not also owned by the alliance, they will not be able to spawn on Objective B, break out
	if ( fobObjectiveOwner != alliance )
		return false

	// If the alliance owns their FOB and Objective B, they may spawn on Objective B
	return true
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Because the length of the spawn waypoints array is a const, if logic needs to know the current number of spawn waypoints, we need to go through and only count the valid ones
int function Control_GetValidSpawnWaypointCount()
{
	int count = 0
	foreach ( waypoint in file.spawnWaypoints )
	{
		if ( IsValid( waypoint ) )
			count++
	}

	return count
}
#endif // SERVER || CLIENT

#if SERVER
// Callback from the Client with the players respawn choice
void function ClientCallback_Control_ProcessRespawnChoice( entity player, int respawnChoice )
{
	Control_PrintSpawningDebug( player, respawnChoice, null, false, "ClientCallback_Control_ProcessRespawnChoice triggered" )
	Control_ProcessRespawnChoice( player, respawnChoice )
}
#endif // SERVER

#if SERVER
// Determine what should happen when a player selects a spawn ( set to spawn on it, change to new spawn, cancel the spawn)
void function Control_ProcessRespawnChoice( entity player, int respawnChoice )
{
	if ( !IsValid( player ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessRespawnChoice breaking out because the player is not valid" )
		return
	}

	if ( !Control_IsValidRespawnChoice( respawnChoice ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessRespawnChoice breaking out because the respawnChoice is not valid" )
		return
	}

	GameSummarySquadData squadData = GameSummary_GetPlayerData( player )
	if ( ( eControlStat.OBJECTIVES_CAPTURED in squadData.modeMetaData ) == false )
		squadData.modeMetaData[ eControlStat.OBJECTIVES_CAPTURED ] <- 0
	if ( ( eControlStat.RATING in squadData.modeMetaData ) == false )
		squadData.modeMetaData[ eControlStat.RATING ] <- 0

	if ( file.playersAbleToSelectSpawnArray.contains( player ) )
	{
		if ( !( player in file.playerToRespawnChoice ) )
		{
			Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessRespawnChoice going to process player input" )
			// Player doesn't have a spawn set, set them up and get them spawning
			Control_ProcessPlayerRespawnInput( player, respawnChoice )
		}
		else if ( player in file.playerToRespawnChoice && file.playerToRespawnChoice[ player ] == respawnChoice )
		{
			Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessRespawnChoice going to cancel a spawn" )
			// Player selected the same spawn they already had selected, cancel the spawn
			Control_CancelSpawnSelection( player, eControlSpawnAlertCode.SPAWN_CANCELLED )
		}
		else
		{
			Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessRespawnChoice going to store a new player spawn choice" )
			// Player selected a new spawn, update the spawn info but leave them in spawn queue
			Control_StorePlayerSpawnChoice( player, respawnChoice )
		}
	}
	else
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessRespawnChoice not doing anything because the player is not in the file.playersAbleToSelectSpawnArray array" )
	}
}
#endif // SERVER

#if SERVER
// When a spawn point is no longer available, check if it was selected to spawn on, if it was cancel the spawn
void function Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange( entity player, int respawnChoice )
{
	if ( CONTROL_DETAILED_DEBUG )
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange running" )

	if ( !IsValid( player ) )
		return

	if ( !Control_IsValidRespawnChoice( respawnChoice ) )
		return

	if ( file.playersAbleToSelectSpawnArray.contains( player ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange player in select spawn array, going to cancel their spawn" )
		if ( player in file.playerToRespawnChoice && file.playerToRespawnChoice[ player ] == respawnChoice )
		{
			if ( respawnChoice == eControlWaypointTypeIndex.MRB_SPAWN )
				Control_CancelSpawnSelection( player, eControlSpawnAlertCode.SPAWN_LOST_MRB )
			else if ( Control_IsSpawnWaypointIndexAnObjective( respawnChoice ) )
				Control_CancelSpawnSelection( player, eControlSpawnAlertCode.SPAWN_LOST_SPAWNPOINT )
			else
				Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange failed to cancel the players spawn because it wasn't an objective or mrb spawn" )

			// Put the player in an array to remove them from wave spawning as soon as this wave finishes.
			// Don't want to remove them from wave spawning right away because it would make it potentially beneficial to just select points you are about to lose in order to bypass the current spawn wave
			file.playersPendingExemptionFromWaveSpawn.append( player )

			// If the player was a bot, make them select a new point to spawn on
			if ( player.IsBot() )
				thread Control_ChooseBotRespawnLocation_Thread( player )
		}
		else if ( CONTROL_DETAILED_DEBUG )
		{
			Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange failed to cancel the players spawn due to missing respawn choice" )
		}
	}
	else if ( CONTROL_DETAILED_DEBUG )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange player NOT in select spawn array" )
	}
}
#endif // SERVER

#if SERVER
// Cancel a currently selected spawn
void function Control_CancelSpawnSelection( entity player, int spawnAlertMessageCode )
{
	if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
		printt("CONTROL: Control_CancelSpawnSelection running for ", player)

	if ( GetGameState() != eGameState.Playing )
		return

	// Safety so if this gets called outside of the mode due to a button callback, we can cancel the state
	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	// These actions are only needed for players on the spawn select screen
	if ( IsValid( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
	{
		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt("CONTROL: Control_CancelSpawnSelection player: ", player, " is valid and on spawn select screen")

		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DisplaySpawnAlertMessage", spawnAlertMessageCode )
		Remote_CallFunction_UI( player, "Control_RemoveAllButtonSpawnIcons" )
		Remote_CallFunction_UI( player, "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", true )
	}

	Control_CleanupSpawnState( player )
}
#endif // SERVER

#if SERVER
// Cleanup UI settings and spawn table data when a spawn is completed or cancelled
void function Control_CleanupSpawnState( entity player )
{
	if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
		printt( "CONTROL: Control_CleanupSpawnState running for player: ", player )

	// These actions are only needed for players on the spawn select screen
	if ( IsValid( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DisplayWaveSpawnBarStatusMessage", false, 0 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdateSpawnWaveTimerVisibility", false )
	}

	// Cleanup the tables that hold the players spawn choice
	if ( player in file.playerToRespawnChoice )
		delete file.playerToRespawnChoice[ player ]
}
#endif // SERVER

#if SERVER
void function ClientCallback_Control_PlayerRespawningFromMenu( entity player )
{
	if ( !IsValid( player ) )
		return

	//flag player to open character select menu when respawning
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_ProcessImmediatelyOpenCharacterSelect" )

	//don't kill if already choosing respawn
	if ( IsAlive( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" )  )
		return

	//don't kill if already dead
	if ( !IsAlive( player ) )
		return

	//kill player
	KillPlayer( player, eDamageSourceId.damagedef_despawn )
}
#endif // SERVER

#if SERVER
void function SpawnBotOnChoice( entity player, int spawnChoice )
{
	Assert( IsNewThread(), "Must be threaded off" )

	player.EndSignal( "OnRespawned" )

	OnThreadEnd(
		function() : ( player, spawnChoice )
		{
			Control_PrintSpawningDebug( player, spawnChoice, null, false, "SpawnBotOnChoice" )
			Control_ProcessPlayerRespawnInput( player, spawnChoice )
		}
	)
}
#endif // SERVER

#if SERVER
// Store the players spawn selection
void function Control_StorePlayerSpawnChoice( entity player, int respawnChoice )
{
	if ( Control_IsValidRespawnChoice( respawnChoice ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_StorePlayerSpawnChoice is storing the spawn choice" )
		file.playerToRespawnChoice[ player ] <- respawnChoice
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DisplayWaveSpawnBarStatusMessage", true, respawnChoice )
	}
	else
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_StorePlayerSpawnChoice NOT storing the spawn choice" )
	}
}
#endif // SERVER

#if SERVER || CLIENT
// Check through the supported respawn choices and determine if this was a valid respawn choice int
bool function Control_IsValidRespawnChoice( int respawnChoice )
{
	switch( respawnChoice )
	{
		case eControlWaypointTypeIndex.OBJECTIVE_A:
		case eControlWaypointTypeIndex.OBJECTIVE_B:
		case eControlWaypointTypeIndex.OBJECTIVE_C:
		case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
		case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
		case eControlWaypointTypeIndex.MRB_SPAWN:
			return true
		default:
			return false
	}

	return false
}
#endif // SERVER || CLIENT

#if SERVER
// Set the players spawn selection.
// If the player is exempt from the spawn wave, spawn them here as well otherwise they will spawn in the Control_ManageWaveSpawnIntervals_Thread function
void function Control_ProcessPlayerRespawnInput( entity player, int respawnChoice )
{
	if ( !IsValid( player ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessPlayerRespawnInput breaking out because the player is not valid" )
		return
	}

	// Prevent players from respawning once we are determining the winner.
	// All players are placed on the same team at the end of the match and there can be issues with respawn checks ( making sure players aren't using dupe characters).
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessPlayerRespawnInput breaking out because winner is being determined" )
		return
	}

	Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessPlayerRespawnInput running" )

	Control_StorePlayerSpawnChoice( player, respawnChoice )

	// If the player is exempt from the spawnwave, spawn them right away
	if ( player.GetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn" ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessPlayerRespawnInput going to try to spawn the player right away, they are exempt from wave spawns" )
		Remote_CallFunction_UI( player, "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", false )
		Control_AttemptToSpawnPlayerOnSpawnPoint( player, respawnChoice )

		// This is a special case, normally an array of players is passed in. In this case we just trigger the MRB spawn with the single player
		if ( respawnChoice == eControlWaypointTypeIndex.MRB_SPAWN )
		{
			array <entity> players = [ player ]
			Control_RespawnPlayersOnMRB( players )
		}
	}
	else
	{
		Control_PrintSpawningDebug( player, respawnChoice, null, false, "Control_ProcessPlayerRespawnInput NOT spawning the player right away, just updating spawn wave timer visibility" )
		// Only show the wave spawn timer once a player has made a spawn selection and if they are in a wave spawn
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdateSpawnWaveTimerVisibility", true )
	}
}
#endif // SERVER

#if SERVER
bool function Control_IsSquadReallyEliminated( int team )
{
	return false
}
#endif // SERVER

#if SERVER
void function Control_OnPlayerPostRespawned( entity player )
{
	if ( !IsValid( player ) )
		return

	Control_SetPlayerForTransitionFromRespawnSelection( player )
	thread Control_ResetPlayerInventoryAndLoadout_Thread( player )
	player.DeployWeapon()

	Control_DisplayIconForTeammatesAtPlayerPos( player, eControlIconIndex.SPAWN_ICON, TEAMMATE_SPAWN_ICON_DURATION )
}
#endif // SERVER

#if SERVER
const string RESPAWN_DIALOGUE = "bc_respawnAuto"
const float RESPAWN_DIALOGUE_COOLDOWN = 120.0
const float SKYDIVE_SPAWN_HEIGHT_OFFSET = 12500.0
void function Control_CommonRespawn( entity player, entity finalSpawn, bool didSpawnOnHomeBase = false, bool didSpawnOnDropship = false )
{
	if ( !IsValid( player ) )
		return

	if ( IsValid( finalSpawn ) )
		finalSpawn.sp.lastUsedTime = Time()

	DoCommonRespawnForPlayer( player )
	player.p.respawnPodLanded = false // this is weird but necessary
	player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.NONE )
	PlayerMatchState_Set( player, ePlayerMatchState.NORMAL )

	//first time spawn music - play instantly if player spawns after spawn wave
	if ( !file.playerFirstSpawnList.contains( player ) )
	{
		string music = GetMusicForJump( player )
		if ( music.len() > 0 )
			SignalSoundOnEntity( player, music )

		file.playerFirstSpawnList.append( player )
	}
	else
	{
		// Play respawn dialogue ( but not on the first spawn )
		PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( player, RESPAWN_DIALOGUE, RESPAWN_DIALOGUE_COOLDOWN, RESPAWN_DIALOGUE_COOLDOWN, null, true )
	}

	//stop spawn music if playing
	StopMusicOnPlayer( player, "Music_Ctrl_Spawn" )

	if ( player.GetTeam() != TEAM_SPECTATOR )
	{
		// Set the player HUD behaviour (how they see enemies, friendlies displayed)
		GivePlayerSettingsMods( player, [ "targetinfo_alliance" ] )
		//GivePlayerSettingsMods( player, [ "targetinfo_ffa_squad" ] )
		// player.SetNameVisibleToEnemy( true ) // Turning off player names and icons on enemies for now based on playtest feedback
	}

	player.Signal( "Control_PlayerRespawning" )

	// This is all stuff controlling the actual spawning of the character that is already done by the drop ship logic
	if ( !didSpawnOnDropship )
	{
		//set location
		// If spawning in skydive, spawn the player with an offset
		if ( Control_GetShouldSkydiveRespawn() )
			player.SnapToAbsOrigin( finalSpawn.GetOrigin() + < 0,0, SURVIVAL_GetPlaneHeight() - SKYDIVE_SPAWN_HEIGHT_OFFSET > )
		else
			player.SnapToAbsOrigin( finalSpawn.GetOrigin() )

		player.SnapEyeAngles( finalSpawn.GetAngles() )
		player.SnapFeetToEyes()
		player.SetMinimapZoomScale( 2.0, 3.0 )

		#if DEV
			if ( CONTROL_SPAWN_DEBUGGING )
				thread Control_SpawnDebugging_Thread( player, finalSpawn )
		#endif // DEV

		if ( didSpawnOnHomeBase )
			thread Control_SpawnKillDetection_Thread( player )
	}

	// In Case Ratings Leader didn't get cleaned up when the Ratings Leader was killed due to potential timing issue. Make sure it is cleared on spawn
	if ( GradeFlagsHas( player, eTargetGrade.EXP_LEADER ) )
		GradeFlagsClear( player, eTargetGrade.EXP_LEADER )
}
#endif // SERVER

#if SERVER
// Create a waypoint used to track a player's position on the Client to show icons to teammates. Destroy the waypoint when the teammate dies or is destroyed.
// Also keep checking if the player is in Combat to prevent issues with weapon evo ( would previously do a check right when evo was supposed to occur and then start a loop if that check failed, that didn't catch some time sensitive edge cases )
void function Control_TrackPlayer_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	entity wp = CreateWaypoint_Custom( WAYPOINT_CONTROL_PLAYERLOC )
	SetTeam( wp, player.GetTeam() )
	wp.SetWaypointEntity( CONTROL_PLAYERLOC_WAYPOINT_PLAYERENTITY_INDEX, player )

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	EndSignal( svGlobal.levelEnt, "GameEnd" )

	OnThreadEnd(
		function() : ( wp, player )
		{
			wp.Destroy()
		}
	)

	// ToDo: DSwieczko remove if we decide to keep evo on reload
	// Using this tracking to check if the player is in combat

	if ( !Control_GetShouldEvoWeaponsOnWeaponSwitch() )
	{
		bool isPlayerInCombat
		while ( IsValid( player ) && IsAlive( player ) )
		{
			// Check if the player is in Combat
			isPlayerInCombat = Control_PlayerIsInCombat( player, true )

			// Check if the new value is different than the stored one then trigger the value changed function to see if the player's weapons should evo
       		if ( isPlayerInCombat )
        		{
            		if ( !file.playersInCombatArray.contains( player ) )
            		{
               		 file.playersInCombatArray.append( player )
               		 Control_OnPlayerInCombatChanged( player, isPlayerInCombat )
            		}
        		}
       		else
        		{
            		if ( file.playersInCombatArray.contains( player ) )
            		{
                		file.playersInCombatArray.fastremovebyvalue( player )
                		Control_OnPlayerInCombatChanged( player, isPlayerInCombat )
            		}
        		}

			WaitFrame()
		}
	}
	else
	{
		WaitForever()
	}
}
#endif // SERVER

#if SERVER
void function Control_SetPlayerForTransitionFromRespawnSelection( entity player )
{
	if ( !IsValid( player ) )
		return

	ClearPlayerPlaneViewMode( player )
	Survival_SetInventoryEnabled( player, true )

	//give tactical
	Control_RestoreChargesOnRespawn( player )

	// Just in case, if a players offhand weapons were disabled for weapon evo and are still disabled, enable them.
	if ( Control_GetIsPlayerWeaponEvoInProgress( player ) )
	{
		EnableOffhandWeapons( player )
		file.playersWithWeaponEvoInProgressArray.fastremovebyvalue( player )
	}
}
#endif // SERVER

#if SERVER
void function Control_PlayerChangedCharacter( entity player )
{
	thread _PlayerChangedCharacter( player )
}
#endif // SERVER

#if SERVER
void function _PlayerChangedCharacter( entity player )
{
	WaitFrame()

	if ( !IsValid( player ) )
		return

	asset settings = player.GetPlayerSettings()
	if ( settings == SPECTATOR_SETTINGS )
		return

	if ( player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
	{
		player.SetPhysics( MOVETYPE_NONE )
		player.HidePlayer()
		player.NotSolid()
		player.MakeInvisible()
	}
}
#endif // SERVER

#if SERVER
// Sort the list of spawn points to try and get the best spawn
void function SortSpawnList( array< entity > spawnList, int playerTeam, bool shouldTryToSpawnNearLastTeammateSpawn )
{
	// Get most recently used teammate spawn point in list, ignore ties, only last X seconds count
	// ToDo: Investigate team checks, this could potentially be rating spawns where an enemy spawned if the point recently switched ownership. It mostly works right now because capture time ( point conversion ) is working to our advantage
	vector refPoint
	bool doDistSort = false
	if ( shouldTryToSpawnNearLastTeammateSpawn )
	{
		float newestTime = 0
		float invalidTime = Time() - SPAWN_GROUPING_DURATION
		foreach ( spawnPoint in spawnList )
		{
			if ( spawnPoint in file.spawnPoints_LastUsed && newestTime < file.spawnPoints_LastUsed[ spawnPoint ] && invalidTime < file.spawnPoints_LastUsed[ spawnPoint ])
			{
				doDistSort = true
				refPoint = spawnPoint.GetOrigin()
				newestTime = file.spawnPoints_LastUsed[ spawnPoint ]
			}
		}
	}

	spawnList.sort( int function( entity a, entity b ) : ( refPoint, playerTeam, doDistSort ) {
		// Not spawning in view of the enemy is the first priority
		bool aIsVisible = Control_IsSpawnpointVisibleToEnemies( a, playerTeam )
		bool bIsVisible = Control_IsSpawnpointVisibleToEnemies( b, playerTeam )

		if ( aIsVisible != bIsVisible )
		{
			if ( aIsVisible )
				return 1  // b, a

			if ( bIsVisible )
				return -1 // a, b
		}

		// Spawning near the last spawn point used by a teammate is the second priority
		if ( doDistSort )
		{
			float distA = DistanceSqr( refPoint, a.GetOrigin() )
			float distB = DistanceSqr( refPoint, b.GetOrigin() )
			if ( distA < distB )
				return -1 // a, b
			else if ( distA > distB )
				return 1 // b, a

			// do nothing for equal distance
		}

		return 0 // no change
	} )
}
#endif // SERVER

#if SERVER
bool function Control_RespawnPlayerAtHomeBase( entity player, bool shouldTryToSpawnNearLastTeammateSpawn = true, int spawnIndexOverride = -1 )
{
	if ( !IsValid( player ) )
	{
		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt("CONTROL: Control_RespawnPlayerAtHomeBase player not Valid, returning false" )

		return false
	}

	// Prevent players from respawning once we are determining the winner.
	// All players are placed on the same team at the end of the match and there can be issues with respawn checks ( making sure players aren't using dupe characters).
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
	{
		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt("CONTROL: Control_RespawnPlayerAtHomeBase winner being determined, returning false" )

		return false
	}

	entity associatedSpawnArea
	associatedSpawnArea = Control_GetTeamSpawnPoint_FromPlayer( player, spawnIndexOverride )

	if ( associatedSpawnArea == null )
		Assert( false, "CONTROL: Failed to find associated spawn area when attempting to spawn " + player.GetPlayerName() + " at base" )

	int playerTeam = player.GetTeam()
	array<entity> spawnList = file.chosenVariantData.triggerToSpawnDataMap[ associatedSpawnArea ].spawnTriggerToSpawns[ associatedSpawnArea ]
	array<entity> finalSpawnList = Control_GetValidSpawnpoints( spawnList, player, spawnList.len() )
	SortSpawnList( finalSpawnList, playerTeam, shouldTryToSpawnNearLastTeammateSpawn )
	entity finalSpawn = Control_GetFirstSpawnpointFromValidSpawnsArray( finalSpawnList )

	#if DEV
		// If we are using debug to test a specific spawn, just use the specified index from the original unsorted spawn list
		if ( file.testingSpawnPointIndex > -1 )
		{
			if ( file.testingSpawnPointIndex < spawnList.len() )
			{
				finalSpawn = spawnList[ file.testingSpawnPointIndex ]
				printt( "CONTROL: Using the debug forced spawn point index: ", file.testingSpawnPointIndex, " when spawning on HomeBase" )
			}
			else
			{
				printt( "CONTROL: Attempted to use the debug forced spawn point index: ", file.testingSpawnPointIndex, " when spawning on HomeBase but the index is higher than the number of spawns, ignoring." )
			}
		}
	#endif // DEV

	if ( IsValid( finalSpawn ) )
	{
		file.spawnPoints_LastUsed[ finalSpawn ] <- Time()
		Control_CommonRespawn( player, finalSpawn, true )
		string baseString = IsTeamInAlliance( playerTeam, ALLIANCE_A ) ? CONTROL_PINEVENT_SPAWNINFO_ALLIANCEABASE : CONTROL_PINEVENT_SPAWNINFO_ALLIANCEBBASE
		//PIN_PlayerSpawnedFromMenu( player, associatedSpawnArea.GetOrigin(), finalSpawn.GetOrigin(), CONTROL_PINEVENT_RESPAWNCHOICE_BASE, baseString )
		Control_PrintSkydiveDebug( player, " spawned on " + baseString )

		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt("CONTROL: Control_RespawnPlayerAtHomeBase spawn successful, returning true" )

		return true
	}

	if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
		printt("CONTROL: Control_RespawnPlayerAtHomeBase spawn NOT successful, returning false" )

	return false
}
#endif // SERVER

#if SERVER
bool function Control_RespawnPlayerOnPoint( entity player, int respawnChoice, entity spawnWaypoint, bool shouldTryToSpawnNearLastTeammateSpawn = true )
{
	Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint running" )

	if ( !IsValid( spawnWaypoint ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint waypoint is not valid, returning false" )
		return false
	}

	// Prevent players from respawning once we are determining the winner.
	// All players are placed on the same team at the end of the match and there can be issues with respawn checks ( making sure players aren't using dupe characters).
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
	{
		Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint winner being determined, returning false" )
		return false
	}

	#if DEV
		bool showSpawnPoints = GetConVarBool( "spawnpoint_debug" )
	#endif // DEV


	entity objectiveTrigger = spawnWaypoint.GetOwner() //get trigger from objective waypoint

	// Breakout if the trigger is not valid, it is used to get the correct spawn points
	if ( !IsValid( objectiveTrigger ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint objectiveTrigger is not valid, returning false" )
		return false
	}

	// Breakout if the trigger is not in the spawns table, it needs to be in order to get the spawn points
	if ( !( objectiveTrigger in file.chosenVariantData.triggerToControlPointMap ) )
	{
		Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint objectiveTrigger not in triggerToControlPointMap table, returning false" )
		return false
	}

	array < entity > spawnList = file.chosenVariantData.triggerToControlPointMap[ objectiveTrigger ].spawns

	//filter spawns by alliance designator
	int playerTeam = player.GetTeam()
	int playerAlliance = AllianceProximity_GetAllianceFromTeam( playerTeam )
	array < entity > filteredSpawnList
	foreach ( spawn in spawnList )
	{
		if ( spawn.HasKey( "control_teamnumber" ) )
		{
			//we're specifying alliance designation, filter
			if ( int(spawn.kv.control_teamnumber) == ALLIANCE_NONE )
			{
				//spawn is neutral, append
				filteredSpawnList.append( spawn )

				#if DEV
					if ( CONTROL_DISPLAY_DEBUG_DRAWS && showSpawnPoints )
						DebugDrawCylinder( spawn.GetOrigin(), spawn.GetAngles(), 20, 128, COLOR_YELLOW, true, SPAWNPOINT_DISPLAY_TIME )

					if ( CONTROL_DETAILED_DEBUG )
						printt( "CONTROL SPAWN: spawn at ", spawn.GetOrigin(), " is neutral with key ", spawn.kv.control_teamnumber )
				#endif // DEV
				continue
			}

			if ( int(spawn.kv.control_teamnumber) == playerAlliance )
			{
				//spawn is alliance filtered, append
				filteredSpawnList.append( spawn )

				#if DEV
					if ( CONTROL_DISPLAY_DEBUG_DRAWS && showSpawnPoints )
						DebugDrawCylinder( spawn.GetOrigin(), spawn.GetAngles(), 20, 128, COLOR_GREEN, true, SPAWNPOINT_DISPLAY_TIME )

					if ( CONTROL_DETAILED_DEBUG )
						printt( "CONTROL SPAWN: spawn at ", spawn.GetOrigin(), " is friendly with key ", spawn.kv.control_teamnumber )
				#endif // DEV

				continue
			}

			//spawn is neither neutral nor matching player alliance, do nothing
			#if DEV
				if ( CONTROL_DISPLAY_DEBUG_DRAWS && showSpawnPoints )
					DebugDrawCylinder( spawn.GetOrigin(), spawn.GetAngles(), 20, 128, COLOR_RED, true, SPAWNPOINT_DISPLAY_TIME )

				if ( CONTROL_DETAILED_DEBUG )
					printt( "CONTROL SPAWN: spawn at ", spawn.GetOrigin(), " is enemy with key ", spawn.kv.control_teamnumber )
			#endif // DEV
		}
		else
		{
			//map has not been compiled with alliance designation, add all spawns
			filteredSpawnList.append( spawn )

			#if DEV
				if ( CONTROL_DISPLAY_DEBUG_DRAWS && showSpawnPoints )
					DebugDrawCylinder( spawn.GetOrigin(), spawn.GetAngles(), 20, 128, COLOR_BLUE, true, SPAWNPOINT_DISPLAY_TIME )

				if ( CONTROL_DETAILED_DEBUG )
					printt( "CONTROL SPAWN: spawn at ", spawn.GetOrigin(), " does not have teamnumber filter " )
			#endif // DEV
		}
	}

	RateSpawnPointList( player, filteredSpawnList )

	//get 5 valid spawnpoints
	array<entity> finalSpawns = Control_GetValidSpawnpoints( filteredSpawnList, player, filteredSpawnList.len() )
	SortSpawnList( finalSpawns, playerTeam, shouldTryToSpawnNearLastTeammateSpawn )
	entity finalSpawn = Control_GetFirstSpawnpointFromValidSpawnsArray( finalSpawns )

	#if DEV
		// If we are using debug to test a specific spawn, just use the specified index from the original unsorted spawn list
		if ( file.testingSpawnPointIndex > -1 )
		{
			if ( file.testingSpawnPointIndex < filteredSpawnList.len() )
			{
				finalSpawn =  filteredSpawnList[ file.testingSpawnPointIndex ]
				printt( "CONTROL: Using the debug forced spawn point index: ", file.testingSpawnPointIndex, " when spawning on an Objective" )
			}
			else
			{
				printt( "CONTROL: Attempted to use the debug forced spawn point index: ", file.testingSpawnPointIndex, " when spawning on an objective but the index is higher than the number of spawns, ignoring." )
			}
		}
	#endif // DEV

	if ( IsValid( finalSpawn ) )
	{
		Control_CommonRespawn( player, finalSpawn )
		string controlPointInfo = "Control Point: "

		if ( objectiveTrigger in file.chosenVariantData.triggerToControlPointMap )
		{
			ControlPointData controlPoint = file.chosenVariantData.triggerToControlPointMap[ objectiveTrigger ]
			controlPointInfo += controlPoint.name
		}

		//PIN_PlayerSpawnedFromMenu( player, objectiveTrigger.GetOrigin(), finalSpawn.GetOrigin(), CONTROL_PINEVENT_RESPAWNCHOICE_POINT, controlPointInfo )
		Control_PrintSkydiveDebug( player, " spawned on " + controlPointInfo )
		Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint all good, going to return true" )
		return true
	}

	Control_PrintSpawningDebug( player, respawnChoice, spawnWaypoint, true, "Control_RespawnPlayerOnPoint failed, going to return false" )
	return false
}
#endif // SERVER

#if SERVER
// Spawn a group of players on a dropship. Try to put players in existing dropships first, then move on to making new ones if there are no available dropships
void function Control_RespawnPlayersOnMRB( array< entity > players )
{
	// Prevent players from respawning once we are determining the winner.
	// All players are placed on the same team at the end of the match and there can be issues with respawn checks ( making sure players aren't using dupe characters).
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	entity spawnWaypoint = Control_GetEntityToSpawnOnFromRespawnChoice( eControlWaypointTypeIndex.MRB_SPAWN )
	// Put only valid players into the players to spawn array
	array< entity > playersToSpawnArray
	foreach ( player in players )
	{
		if ( IsValid( player ) )
		{
			playersToSpawnArray.append( player )
		}
		else
		{
			if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
				printt("CONTROL: Control_RespawnPlayersOnMRB not adding player to spawn array, they are invalid")

			Control_HandleSpawnFailure( player, eControlWaypointTypeIndex.MRB_SPAWN, spawnWaypoint )
		}
	}

	if ( playersToSpawnArray.len() <= 0 )
		return

	if ( IsValid( file.activeMRB ) )
	{
		vector center = file.activeMRB.GetOrigin()

		// Try to put players into existing dropships first
		table< entity, array< entity > > localDropshipToPlayerOnDropshipTable = clone file.dropshipToPlayersOnDropshipTable
		foreach ( dropship, playersOnDropship in localDropshipToPlayerOnDropshipTable )
		{
			for ( int i = playersToSpawnArray.len() - 1; i >= 0; i-- )
			{
				if ( !IsValid( dropship ) || RespawnBeacon_GetNumRemainingPositionsOnDropship( dropship ) <= 0 )
					break

				entity player = playersToSpawnArray[ i ]
				bool didPlacePlayerInDropship = Control_PutPlayerInExistingDropship( player, dropship, center )
				if ( didPlacePlayerInDropship )
				{
					// Remove the player from the waiting list
					playersToSpawnArray.fastremove( i )

					if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
						printt("CONTROL: Control_RespawnPlayersOnMRB spawn successful for player: ", player )

					Control_HandleSpawnSuccess( player, eControlWaypointTypeIndex.MRB_SPAWN )
					//PIN_PlayerSpawnedFromMenu( player, center, dropship.GetOrigin(), CONTROL_PINEVENT_RESPAWNCHOICE_MRB, "" )
					Control_PrintSkydiveDebug( player, " spawned on MRB in existing dropship" )
				}
			}
		}

		// Put players in new dropships
		array < entity > playersToPutOnDropship
		while ( playersToSpawnArray.len() > 0 )
		{
			// Get a group of players that will fit on an empty dropship
			int positionsLeft = RESPAWN_BEACON_MAX_NUM_POSITIONS_ON_DROPSHIP
			while ( positionsLeft > 0 && playersToSpawnArray.len() > 0 )
			{
				entity playerToPutOnDropship = playersToSpawnArray.pop()
				playersToPutOnDropship.append( playerToPutOnDropship )
				positionsLeft--
			}

			// We know the players are getting on the dropship so set them as spawning successfully.
			// Doing it earlier because there are some issues with the movement type being set on players on the spawn screen conflicting with logic that parents the player to the dropship
			foreach ( playerSpawned in playersToPutOnDropship )
			{
				//PIN_PlayerSpawnedFromMenu( playerSpawned, center, center, CONTROL_PINEVENT_RESPAWNCHOICE_MRB, "" )

				if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
					printt("CONTROL: Control_RespawnPlayersOnMRB spawn successful for player: ", playerSpawned )

				Control_HandleSpawnSuccess( playerSpawned, eControlWaypointTypeIndex.MRB_SPAWN )
				Control_PrintSkydiveDebug( playerSpawned, " spawned on MRB in new dropship" )
			}

			// Put the players on a new dropship
			thread RespawnPlayersInDropship( playersToPutOnDropship, file.activeMRB )

			playersToPutOnDropship.clear()
		}
	}
	else // If the spawn point wasn't valid, throw all the players that were supposed to spawn into the failed spawn list
	{
		foreach ( player in playersToSpawnArray )
		{
			if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
				printt("CONTROL: Control_RespawnPlayersOnMRB spawn point wasn't valid, spawn failed for: ", player )

			Control_HandleSpawnFailure( player, eControlWaypointTypeIndex.MRB_SPAWN, spawnWaypoint )
		}
	}
}
#endif // SERVER

#if SERVER
void function Control_SpawnKillDetection_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( GetGameState() != eGameState.Playing )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	player.e.hasSpawnKillDetection = true

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValidPlayer( player ) )
				player.e.hasSpawnKillDetection = false
		}
	)

	bool isPlayerCloseToSpawn = true
	vector spawnLocation = player.GetOrigin()

	// Don't need to do a check right as the player spawns
	wait 0.5

	// Keep doing checks to see if the player has ventured a certain distance away from their spawn
	while ( isPlayerCloseToSpawn && IsValid( player ) )
	{
		isPlayerCloseToSpawn = Distance2D( player.GetOrigin(), spawnLocation ) < CONTROL_SPAWNKILLDETECTION_DETECTION_DISTANCE
		wait 0.2
	}
}
#endif // SERVER

#if SERVER && DEV
void function Control_SpawnDebugging_Thread( entity player, entity finalSpawn )
{
	Assert( IsNewThread(), "Must be threaded off" )

	WaitFrame()

	OnThreadEnd(
		void function() : ( player, finalSpawn )
		{
			if ( !IsValid( player ) )
				return

			if ( !IsAlive( player ) )
			{
				//draw debug bad spawn
				if ( CONTROL_DISPLAY_DEBUG_DRAWS )
					DebugDrawCylinder( finalSpawn.GetOrigin(), finalSpawn.GetAngles(), 20, 128, COLOR_RED, true, CONTROL_DEBUG_DRAW_DISPLAY_TIME )

				printt( "CONTROL: player died too soon after spawning on ", finalSpawn.GetOrigin() )
			}
		}
	)

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	vector spawnLocation = finalSpawn.GetOrigin()

	wait 10

	//draw debug good spawn
	if ( CONTROL_DISPLAY_DEBUG_DRAWS )
		DebugDrawCylinder( finalSpawn.GetOrigin(), finalSpawn.GetAngles(), 20, 128, COLOR_GREEN, true, CONTROL_DEBUG_DRAW_DISPLAY_TIME )
}
#endif // SERVER && DEV

#if SERVER
// Just grab the first spawn if the provided array has any spawns in it
entity function Control_GetFirstSpawnpointFromValidSpawnsArray( array<entity> spawnpoints )
{
	entity spawn = spawnpoints.len() > 0 ? spawnpoints[ 0 ] : null
	return spawn
}
#endif // SERVER

#if SERVER
array<entity> function Control_GetValidSpawnpoints( array<entity> spawnpoints, entity player, int amount )
{
	#if DEV
		bool showSpawnPoints = GetConVarBool( "spawnpoint_debug" )
	#endif // DEV

	array<entity> validSpawns
	int playerTeam = player.GetTeam()
	foreach ( spawn in spawnpoints )
	{
		if ( validSpawns.len() == amount )
			break

		if ( Control_IsSpawnpointValid( spawn, player ) )
		{
			validSpawns.append( spawn )
			#if DEV
				if ( CONTROL_DISPLAY_DEBUG_DRAWS && showSpawnPoints )
					DebugDrawCylinder( spawn.GetOrigin(), spawn.GetAngles(), SPAWNPOINT_RADIUS, SPAWNPOINT_HEIGHT, COLOR_YELLOW, true, SPAWNPOINT_DISPLAY_TIME )
			#endif // DEV
		}
	#if DEV
		else if ( CONTROL_DISPLAY_DEBUG_DRAWS && showSpawnPoints )
		{
			DebugDrawCylinder( spawn.GetOrigin(), spawn.GetAngles(), SPAWNPOINT_RADIUS, SPAWNPOINT_HEIGHT, COLOR_RED, true, SPAWNPOINT_DISPLAY_TIME )
		}
	#endif // DEV
	}

	return validSpawns
}
#endif // SERVER

#if SERVER
//todo: roll this into more generic spawnpoint validity logic, which doesn't currently support alliances
bool function Control_IsSpawnpointValid( entity spawnpoint, entity player )
{
	if ( !spawnpoint.sp.enabled )
	{
		//if ( IsHighPerfDevServer() )
		//	DebugMarkSpawnpointInvalid( spawnpoint, "not enabled" )
		return false
	}

	// check if this spawnpoint was already selected by someone this frame
	if ( spawnpoint.sp.lastUsedTime == Time() )
	{
		return false
	}

	// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
	if ( spawnpoint.IsOccupied() )
	{
		//if ( IsHighPerfDevServer() )
		//	DebugMarkSpawnpointInvalid( spawnpoint, "occupied" )
		return false
	}

	if ( IsNearAirdropBadPlace( spawnpoint.GetOrigin() ) )
	{
		return false
	}

	if ( IsSpawnpointNearGrenade( spawnpoint, player.GetTeam() ) )
	{
		//if ( IsHighPerfDevServer() )
		//	DebugMarkSpawnpointInvalid( spawnpoint, "near grenade" )
		return false
	}

	return true
}
#endif // SERVER

#if SERVER
//Return whether a spawn point is visible to enemies
bool function Control_IsSpawnpointVisibleToEnemies( entity spawnpoint, int playerTeam )
{
	return spawnpoint.IsVisibleToEnemies( playerTeam )
}
#endif // SERVER

#if SERVER
void function Control_RespawnDropshipCreated( entity dropship )
{
	thread Control_RespawnDropshipAlive_Thread( dropship )
}
#endif // SERVER

#if SERVER
void function Control_RespawnDropshipAlive_Thread( entity dropship )
{
	Assert( IsNewThread(), "Must be threaded off" )

	file.dropshipToDropshipSpawnTimeTable[ dropship ] <- Time() - WARPINFXTIME

	Highlight_SetEnemyHighlight( dropship, "dropship_enemy" )
	Highlight_SetFriendlyHighlight( dropship, "dropship_friendly" )
	dropship.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( dropship )
		{
			if ( dropship in file.dropshipToPlayersOnDropshipTable )
				delete file.dropshipToPlayersOnDropshipTable[ dropship ]

			if ( dropship in file.dropshipToDropshipSpawnTimeTable )
				delete file.dropshipToDropshipSpawnTimeTable[ dropship ]
		}
	)

	WaitForever()
}
#endif // SERVER

#if SERVER
void function Control_OnPlayerPutInDropship( entity player, entity dropship )
{
	thread Control_DisablePlayerWeapons_Thread( player, eControlWeaponDisableReason.DROPSHIP_SPAWN )

	if ( dropship in file.dropshipToPlayersOnDropshipTable )
	{
		if ( !file.dropshipToPlayersOnDropshipTable[ dropship ].contains( player ) )
			file.dropshipToPlayersOnDropshipTable[ dropship ].append( player )
	}
	else
	{
		file.dropshipToPlayersOnDropshipTable[ dropship ] <- [ player ]
	}
	Control_CommonRespawn( player, null, false, true )
}
#endif // SERVER

#if SERVER
// If we want to disable weapons when a player is spawned in, we need to run a thread to manage when we re-enable the weapons
void function Control_DisablePlayerWeapons_Thread( entity player, int weaponDisableReason )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	player.DisableWeaponTypes( WPT_ALL_EXCEPT_VIEWHANDS_OR_INCAP )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.EnableWeaponTypes( WPT_ALL_EXCEPT_VIEWHANDS_OR_INCAP )

				// We want to automatically equip the players primary as long as it is not disabled through a different system
				if ( player.IsWeaponTypeEnabled( WPT_PRIMARY ) )
					player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
			}
		}
	)

	// Handle our normal waits differently depending on what event triggered the weapon disable
	if ( weaponDisableReason == eControlWeaponDisableReason.DROPSHIP_SPAWN ) // Disabled due to dropship spawn, wait until the player has cleared the dropship
	{
		player.WaitSignal( "PlayerRedeployingFromDropship" )
	}
	else if (  weaponDisableReason == eControlWeaponDisableReason.HOVERTANK ) // Disabled due to hovertank spawn, wait until the player has cleared the hovertank
	{
		player.WaitSignal( "PlayerExitedHovertankVolume" )
	}
}
#endif // SERVER

#if SERVER
const string[4] DROPSHIP_SEQUENCES = ["Classic_MP_flyin_exit_playerA_idle", "Classic_MP_flyin_exit_playerB_idle", "Classic_MP_flyin_exit_playerC_idle", "Classic_MP_flyin_exit_playerD_idle"]
const float MIN_TIME_REMAINING_IN_DROPSHIP_SEQUENCE_FOR_SPAWN = 1.5
bool function Control_PutPlayerInExistingDropship( entity player, entity dropship, vector spawnWaypointOrigin )
{
	float spawnTime
	// check if dropship has valid spawn time
	if ( dropship in file.dropshipToDropshipSpawnTimeTable )
	{
		spawnTime = file.dropshipToDropshipSpawnTimeTable[ dropship ]
	}
	else
	{
		return false
	}

	// make sure the player isn't already on a dropship
	table< entity, array< entity > > localDropshipToPlayerOnDropshipTable = clone file.dropshipToPlayersOnDropshipTable

	foreach ( tableDropship, playersInDropship in localDropshipToPlayerOnDropshipTable )
	{
		if ( playersInDropship.contains( player ) )
			return false
	}

	// check if dropship is owned by your alliance
	bool teamCheck = AllianceProximity_GetAllianceFromTeam( dropship.GetTeam() ) == AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	// check if dropship has space
	int numAvailablePositionsOnDropship = RespawnBeacon_GetNumRemainingPositionsOnDropship( dropship )
	int positionIndex = RESPAWN_BEACON_MAX_NUM_POSITIONS_ON_DROPSHIP - numAvailablePositionsOnDropship
	bool spaceCheck = numAvailablePositionsOnDropship > 0 && positionIndex < DROPSHIP_SEQUENCES.len() && positionIndex >= 0
	if ( teamCheck && spaceCheck )
	{
		string sequence = DROPSHIP_SEQUENCES[ positionIndex ]

		if ( player.LookupSequence( sequence ) == -1 )
		{
			ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
			string characterRef  = ItemFlavor_GetCharacterRef( character ).tolower()
			Warning( "CONTROL: trying to spawn player on Dropship with missing sequence ", sequence, " and character ", characterRef, ". Check this characters animations. Failing spawn")
			return false
		}

		float sequenceDuration = 0.0
		sequenceDuration = player.GetSequenceDuration( sequence )

		float timeSinceSpawn = Time() - spawnTime
		float timeToJump = sequenceDuration - timeSinceSpawn

		//if time to jump is too close to the dropship finishing its sequence, let's skip it and move to the next one
		printt( "CONTROL: Trying to spawn ", player, " on dropship with time to jump ", timeToJump )

		// Make sure there is enough time to spawn the player on this dropship and do another sanity check to make sure the dropship still exists
		if ( timeToJump > MIN_TIME_REMAINING_IN_DROPSHIP_SEQUENCE_FOR_SPAWN && IsValid( dropship ) && dropship in file.dropshipToPlayersOnDropshipTable )
		{
			thread PutPlayerInDropship( player, dropship, positionIndex, timeToJump, false, true )
			//PIN_PlayerSpawnedFromMenu( player, spawnWaypointOrigin, dropship.GetOrigin(), CONTROL_PINEVENT_RESPAWNCHOICE_MRB, "" )

			return true
		}
	}

	return false
}
#endif // SERVER

#if SERVER
vector function Control_GetSpawnLook( vector spawnOrigin )
{
	ControlPointData closestPoint = file.chosenVariantData.controlPoints[0]
	for( int i = 1; i<file.chosenVariantData.controlPoints.len(); i++ )
	{
		ControlPointData point = file.chosenVariantData.controlPoints[i]
		if ( Distance2D( point.location, spawnOrigin ) < Distance2D( closestPoint.location, spawnOrigin ) )
			closestPoint = point
	}

	return closestPoint.location
}
#endif // SERVER

#if SERVER
entity function Control_GetTeamSpawnPoint_FromPlayer( entity player, int spawnIndexOverride = -1 )
{
	int teamIndex = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	return Control_GetTeamSpawnPoint( teamIndex, spawnIndexOverride )
}
#endif // SERVER

#if SERVER
entity function Control_GetTeamSpawnPoint( int teamIndex, int spawnIndexOverride = -1 )
{
	entity spawnArea
	ControlTeamSpawnData teamSpawnData = file.chosenVariantData.teamSpawnData[teamIndex]
	if ( spawnIndexOverride == -1 )
		spawnArea = teamSpawnData.spawnTriggers.getrandom()
	else
		spawnArea = teamSpawnData.spawnTriggers[spawnIndexOverride]

	return spawnArea
}
#endif // SERVER

#if SERVER
void function Control_SonarSpawnKiller( entity victim, entity attacker )
{
	if ( !IsAlive( attacker ) )
		return

	thread Control_DelayedStatusEffectHandler( attacker )

	foreach ( team in GetAllTeams() )
	{
		if ( AllianceProximity_GetAllianceFromTeam( victim.GetTeam() ) == AllianceProximity_GetAllianceFromTeam( team ) )
		{
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Starting sonar on ", attacker.GetPlayerName(), " for team ", team )

			SonarStart( attacker, attacker.GetOrigin(), team, victim )
			thread Control_Delayed_SonarEnd( attacker, team, victim )
		}
	}
}
#endif // SERVER

#if SERVER
void function Control_Delayed_SonarEnd( entity attacker, int team, entity victim )
{
	Assert( IsNewThread(), "Must be threaded off" )

	attacker.EndSignal( "OnDeath" )
	attacker.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( attacker, team, victim )
		{
			SonarEnd( attacker, team, victim )
		}
	)

	wait CONTROL_SPAWNKILLDETECTION_HIGHLIGHT_DURATION
}
#endif // SERVER

#if SERVER
void function Control_DelayedStatusEffectHandler( entity attacker )
{
	Assert( IsNewThread(), "Must be threaded off" )

	int effectHandle = StatusEffect_AddEndless( attacker, eStatusEffect.spawnkilling_detected, 1.0 )

	attacker.EndSignal( "OnDeath" )
	attacker.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( attacker, effectHandle )
		{
			StatusEffect_Stop( attacker, effectHandle )
		}
	)

	wait CONTROL_SPAWNKILLDETECTION_HIGHLIGHT_DURATION
}
#endif // SERVER

#if SERVER
void function OnLeaveMatch( entity player )
{
	if ( !IsValid( player ) )
		return

	//safety to deregister callbacks if player leaves
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DeregisterModeButtonPressedCallbacks" )
}
#endif // SERVER

#if SERVER
// Display a Death or Respawn icon at the position of a teammate
void function Control_DisplayIconForTeammatesAtPlayerPos( entity player, int iconIndex, float duration )
{
	if ( !IsValid( player ) )
		return

	if ( Control_ShouldShow2DMapIcons() )
	{
		int playerTeam = player.GetTeam()
		foreach( connectedPlayer in GetPlayerArray_AliveConnected() )
		{
			if ( AllianceProximity_GetAllianceFromTeam( connectedPlayer.GetTeam() ) == AllianceProximity_GetAllianceFromTeam( playerTeam ) && connectedPlayer != player)
			{
				Remote_CallFunction_NonReplay( connectedPlayer, "ServerCallback_Control_DisplayIconAtPosition", player.GetOrigin(), iconIndex, COLORID_FRIENDLY, duration )
			}
		}
	}
}
#endif // SERVER

/*
   _____ _____   __          ___   _   __  __          _   _          _____ ______ __  __ ______ _   _ _______    _____ _      _____ ______ _   _ _______
  / ____|  __ \ /\ \        / / \ | | |  \/  |   /\   | \ | |   /\   / ____|  ____|  \/  |  ____| \ | |__   __|  / ____| |    |_   _|  ____| \ | |__   __|
 | (___ | |__) /  \ \  /\  / /|  \| | | \  / |  /  \  |  \| |  /  \ | |  __| |__  | \  / | |__  |  \| |  | |    | |    | |      | | | |__  |  \| |  | |
  \___ \|  ___/ /\ \ \/  \/ / | . ` | | |\/| | / /\ \ | . ` | / /\ \| | |_ |  __| | |\/| |  __| | . ` |  | |    | |    | |      | | |  __| | . ` |  | |
  ____) | |  / ____ \  /\  /  | |\  | | |  | |/ ____ \| |\  |/ ____ \ |__| | |____| |  | | |____| |\  |  | |    | |____| |____ _| |_| |____| |\  |  | |
 |_____/|_| /_/    \_\/  \/   |_| \_| |_|  |_/_/    \_\_| \_/_/    \_\_____|______|_|  |_|______|_| \_|  |_|     \_____|______|_____|______|_| \_|  |_|


SPAWN MANAGEMENT CLIENT
*/




#if CLIENT
void function UICallback_Control_SpawnButtonClicked( int respawnChoice )
{
	if ( !Control_IsValidRespawnChoice( respawnChoice ) )
		printt( "CONTROL: UICallback_Control_SpawnButtonClicked called with an invalid waypointTypeIndex: ", respawnChoice )

	Control_PrintSpawningDebug( GetLocalClientPlayer(), respawnChoice, null, false, "UICallback_Control_SpawnButtonClicked Sending spawn request" )
	Control_SendRespawnChoiceToServer( respawnChoice )
}
#endif // CLIENT

#if CLIENT
void function Control_WaypointCreated_Spawn( entity wp )
{
	if ( !IsValid( wp ) )
		return

	if ( Waypoint_GetPingTypeForWaypoint( wp ) != ePingType.NON_PINGABLE_SPAWN_LOCATION )
		return

	thread Control_ManageRespawnWaypoint_Thread( wp )
}
#endif // CLIENT

#if CLIENT
void function Control_ManageRespawnWaypoint_Thread( entity wp )
{
	Assert( IsNewThread(), "Must be threaded off" )

	// Need this wait, had issue where late join players would have the waypoints get invalidated somehow and never get added to the spawn list array
	FlagWait( "EntitiesDidLoad" )

	if ( !IsValid( wp ) )
		return

	while ( IsValid( wp ) && wp.wp.ruiHud == null )
	{
		WaitFrame()
	}

	if ( !IsValid( wp ) )
		return

	int waypointTypeIndex
	entity parentObjective

	if ( Waypoint_GetPingTypeForWaypoint( wp ) == ePingType.NON_PINGABLE_SPAWN_LOCATION )
	{
		RuiSetFloat( wp.wp.ruiHud, "maxDrawDistance", 50000 )
		RuiSetBool( wp.wp.ruiHud, "displayDistance", false )
		RuiSetBool( wp.wp.ruiHud, "alwaysShowLargeIcon", true )

		waypointTypeIndex = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
		bool wasSupportedWaypointType = true

		switch( waypointTypeIndex )
		{
			case eControlWaypointTypeIndex.MRB_SPAWN:
				break
			case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
				RuiSetImage( wp.wp.ruiHud, "outerIcon", CONTROL_WAYPOINT_BASE_ICON )
				// Add no mrb deploy allowed locations for homebase spawns
				file.allianceABlockedHomeBasePositionsForMRB.append( wp.GetOrigin() )
				break
			case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
				RuiSetImage( wp.wp.ruiHud, "outerIcon", CONTROL_WAYPOINT_BASE_ICON )
				// Add no mrb deploy allowed locations for homebase spawns
				file.allianceBBlockedHomeBasePositionsForMRB.append( wp.GetOrigin() )
				break
			case eControlWaypointTypeIndex.OBJECTIVE_A:
			case eControlWaypointTypeIndex.OBJECTIVE_B:
			case eControlWaypointTypeIndex.OBJECTIVE_C:
				RuiSetImage( wp.wp.ruiHud, "outerIcon", CONTROL_OBJ_DIAMOND_YOURS )
				parentObjective = wp.GetParent()
				break
			case eControlWaypointTypeIndex.SQUAD_SPAWN:
				RuiSetImage( wp.wp.ruiHud, "outerIcon", CONTROL_WAYPOINT_PLAYER_ICON )
				break
			default:
				wasSupportedWaypointType = false
				Warning( "CONTROL: Got unsupported waypointTypeIndex in switch statement doing initial settings in Control_ManageRespawnWaypoint_Thread, NOT adding to spawnWaypoints array" )
				break
		}

		file.spawnWaypoints[ waypointTypeIndex ] = wp
	}

	int waypointEHI = wp.GetEncodedEHandle()
	wp.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( waypointEHI, waypointTypeIndex )
		{
			RunUIScript( "ClearWaypointDataForUI", waypointEHI )
			file.spawnWaypoints[ waypointTypeIndex ] = null
		}
	)

	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) )
		return

	localPlayer.EndSignal( "OnDestroy" )

	int playerAlliance = AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() )

	while ( true )
	{
		WaitFrame()

		if ( !localPlayer.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		{
			RuiSetBool( wp.wp.ruiHud, "isHidden", true )
			continue
		}

		switch( waypointTypeIndex )
		{
			case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
			case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
				break
			case eControlWaypointTypeIndex.OBJECTIVE_A:
			case eControlWaypointTypeIndex.OBJECTIVE_B:
			case eControlWaypointTypeIndex.OBJECTIVE_C:
				if ( IsValid( parentObjective ) )
				{
					int owner = parentObjective.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
					if ( playerAlliance == owner )
						RuiSetBool( wp.wp.ruiHud, "isHidden", false )
					else
						RuiSetBool( wp.wp.ruiHud, "isHidden", true )
				}
				else
				{
					RuiSetBool( wp.wp.ruiHud, "isHidden", true )
				}
				break
			case eControlWaypointTypeIndex.MRB_SPAWN:
				RuiSetBool( wp.wp.ruiHud, "isHidden", false )
				break
			case eControlWaypointTypeIndex.SQUAD_SPAWN:
				entity playerOwner = wp.GetParent()
				if ( IsValid( playerOwner ) && IsAlive( playerOwner ) && BleedoutState_GetPlayerBleedoutState( playerOwner ) == BS_NOT_BLEEDING_OUT  )
					RuiSetBool( wp.wp.ruiHud, "isHidden", false )
				else
					RuiSetBool( wp.wp.ruiHud, "isHidden", true )
				break
			default:
				Warning( "CONTROL: Got unsupported waypointTypeIndex in switch statement in loop of Control_ManageRespawnWaypoint_Thread" )
				break
		}
	}
}
#endif // CLIENT

#if CLIENT
// Take the players respawn choice and send it to the server
void function Control_SendRespawnChoiceToServer( int respawnChoice )
{
	entity localPlayer = GetLocalClientPlayer()
	entity localViewPlayer = GetLocalViewPlayer()

	Control_PrintSpawningDebug( localPlayer, respawnChoice, null, false, "Control_SendRespawnChoiceToServer called with localPlayer" )
	if ( !IsValid( localPlayer ) || !IsValid( localViewPlayer ) )
	{
		Control_PrintSpawningDebug( localPlayer, respawnChoice, null, false, "Control_SendRespawnChoiceToServer breaking out because localPlayer or localViewPlayer is Not Valid" )
		return
	}

	if ( localPlayer != localViewPlayer )
	{
		if ( CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
			printt( "CONTROL: Control_SendRespawnChoiceToServer breaking out because localPlayer: ",  localPlayer, " is not the same as localViewPlayer: ", localViewPlayer )

		return
	}

	if ( !localPlayer.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
	{
		Control_PrintSpawningDebug( localPlayer, respawnChoice, null, false, "Control_SendRespawnChoiceToServer breaking out because control_IsPlayerOnSpawnSelectScreen is set to false" )
		return
	}

	Remote_ServerCallFunction( "ClientCallback_Control_ProcessRespawnChoice", respawnChoice )
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_ShowSpawnSelection()
{
	entity player = GetLocalClientPlayer()
	if ( IsValid( player ) && player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
	{
		Control_UpdatePlayerExpPercentAmountsForSpawns( player )

		if ( CONTROL_DETAILED_DEBUG )
			printt( "CONTROL: opening spawn menu from connection callback" )

		thread Control_TriggerShowSpawnMenuOnUI_Thread( player, false )
		RunUIScript( "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", true )
		thread Control_CameraInputManager_Thread( player )
	}
}
#endif // CLIENT

#if CLIENT
const float CONTROL_SPAWN_CHECK_INTERVAL = 0.1
const int CONTROL_MIN_EXPECTED_SPAWN_POINTS = 5
// Send information needed to center the cursor on the best spawn point when opening the spawn menu, then trigger opening the spawn menu on the UI
void function Control_TriggerShowSpawnMenuOnUI_Thread( entity player, bool shouldCheckLastScoreboardOpened )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	// We don't want multiples of this thread running at the same time, so kill other threads and just run this one
	//ToDo Dswieczko: Investigate if there is a cleaner way to make sure this triggers after spawn points are available on the Client. Having this cancelling signal and arbitrary expected spawn count is bad
	player.Signal( "Control_RequestOpenSpawnMenuOnUI" )

	// Because we have a looping wait, make sure we kill this thread if the player gets the spawn screen triggered through a different function and respawns
	player.EndSignal( "Control_PlayerHasChosenRespawn" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Control_RequestOpenSpawnMenuOnUI" )

	// Ensure we have enough spawn points to trigger the spawn menu opening
	// ( there is a timing issue that can occur with late joins where this menu is triggered before spawn waypoints are populated)
	while ( Control_GetValidSpawnWaypointCount() < CONTROL_MIN_EXPECTED_SPAWN_POINTS )
	{
		wait CONTROL_SPAWN_CHECK_INTERVAL
	}

	if ( IsValid( player ) )
	{
		int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
		entity bestSpawnWaypoint = Control_GetBestSpawnLocationForAlliance( playerAlliance )
		int bestSpawnWaypointEHI = bestSpawnWaypoint.GetEncodedEHandle()
		RunUIScript( "UI_OpenControlSpawnMenu", shouldCheckLastScoreboardOpened, bestSpawnWaypointEHI )
		Control_SetWaveSpawnTimerTime()
	}
}
#endif // CLIENT

#if CLIENT
// Servercallback to update the wave spawn timer on the client
void function ServerCallback_Control_UpdateSpawnWaveTimerTime()
{
	Control_SetWaveSpawnTimerTime()
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_OnResolutionChanged()
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )    // not sure when this can be invalid
		return

	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	if ( CONTROL_DETAILED_DEBUG )
		printt( "CONTROL: opening spawn menu from resolution changed callback" )

	thread Control_TriggerShowSpawnMenuOnUI_Thread( player, false )
	thread Control_CameraInputManager_Thread( player )
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_ProcessImmediatelyOpenCharacterSelect()
{
	file.shouldImmediatelyOpenCharacterSelectOnRespawn = true
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_OnPlayerChoosingRespawnChoiceChanged( entity player, bool new )
{
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalClientPlayer() )
		return

	if ( GetGameState() >= eGameState.WinnerDetermined ) // If passed the end of the game, do nothing
		return

	var gameStateRui = ClGameState_GetRui()

	if ( !new ) //player is spawning, cancelling state
	{
		RunUIScript( "UICodeCallback_CloseAllMenus" )
		Control_DeregisterModeButtonPressedCallbacks()
		Obituary_SetEnabled( true ) //Re-enable kill feed
		RuiSetBool( gameStateRui, "isRespawning", false )
		player.Signal( "Control_PlayerHasChosenRespawn" )
	}

	if ( new ) //player is in spawn selection screen
	{
		if ( !player.IsBot() )
		{
			player.Signal( "Control_PlayerStartingRespawnSelection" )
			player.Signal( "Bleedout_StopBleedoutEffects" )

			thread Control_CameraInputManager_Thread( player )
			thread Control_UIManager_Thread( player )
		}
	}
}
#endif // CLIENT

#if CLIENT
void function CreateRespawnBlur()
{
	if(file.respawnBlurRui == null)
		file.respawnBlurRui = CreateFullscreenRui( $"ui/control_respawn_screen_blur.rpak" )
}
#endif // CLIENT

#if CLIENT
void function DestroyRespawnBlur()
{
	if ( IsValid( file.respawnBlurRui  ) )
		RuiDestroyIfAlive( file.respawnBlurRui )

	file.respawnBlurRui = null
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_UpdatePlayerInfo( var elem )
{
	thread Control_UpdatePlayerInfo_thread( elem )
}
#endif // CLIENT

#if CLIENT
void function Control_UpdatePlayerInfo_thread( var elem )
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity localPlayer = GetLocalClientPlayer()
	localPlayer.EndSignal( "Control_PlayerHasChosenRespawn" )

	while( IsValid( elem ) )
	{
		entity player = GetLocalClientPlayer()

		ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )

		var rui = Hud_GetRui( elem )

		if ( !IsValid( rui ) )
			break


		if ( IsRevTakeover() && ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_B ) )
		{
			Hud_Hide( elem )
		}


		RuiSetImage( rui, "playerPortrait", CharacterClass_GetCharacterLockedPortrait( character ) )
		RuiSetString( rui, "playerName", player.GetPlayerName() )
		RuiSetInt( rui, "micStatus", GetPlayerMicStatus( player ) )

		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_TransferCameraData( vector cameraPosition, vector cameraAngles )
{
	entity player = GetLocalClientPlayer()
	file.cameraLocation = cameraPosition
	file.cameraAngles   = cameraAngles

	if ( IsValid( player ) )
	{
		player.Signal( "Control_NewCameraDataReceived" )

		if ( player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
			thread Control_CameraInputManager_Thread( player )
	}
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_PlayMatchEndMusic_Control( int victoryCondition )
{
	// ideally we would have a server side music system that could play music not just on the view player but on the clientplayer.
	// but since that isn't the case we'll have to do something special for this case.

	entity clientPlayer = GetLocalClientPlayer()
	if ( !IsValid( clientPlayer ) )
		return

	var endMusic
	var endSound
	// OK to use teams here because this occurs after the whole alliance has been moved to one team
	if ( clientPlayer.GetTeam() == GetWinningTeam() )
	{
		endMusic = EmitSoundOnEntity( clientPlayer, CONTROL_SFX_GAME_END_VICTORY )

		if ( victoryCondition == eWinReason.LOCKOUT || ( file.isLockout && victoryCondition == eWinReason.TEAM_FORFEIT ) ) // If a lockout was active, use lockout victory music
			endSound = EmitSoundOnEntity( clientPlayer, "Music_Ctrl_LockOut_Victory" )
		else
			endSound = EmitSoundOnEntity( clientPlayer, "Music_Ctrl_RampUp_Victory" )
	}
	else
	{
		endMusic = EmitSoundOnEntity( clientPlayer, CONTROL_SFX_GAME_END_LOSS )

		if ( victoryCondition == eWinReason.LOCKOUT || ( file.isLockout && victoryCondition == eWinReason.TEAM_FORFEIT ) ) // If a lockout was active, use lockout defeat music
			endSound = EmitSoundOnEntity( clientPlayer, "Music_Ctrl_LockOut_Loss" )
		else
			endSound = EmitSoundOnEntity( clientPlayer, "Music_Ctrl_RampUp_Loss" )
	}


		SetPlayThroughKillReplay( endMusic )
		SetPlayThroughPOVTransitions( endMusic )
		SetPlayThroughKillReplay( endSound )
		SetPlayThroughPOVTransitions( endSound )

}
#endif // CLIENT

#if CLIENT
void function ServerCallback_PlayPodiumMusic()
{
	entity clientPlayer = GetLocalClientPlayer()
	if ( IsValid( clientPlayer ) )
		EmitSoundOnEntity( clientPlayer, "Music_Ctrl_Podium" )
}
#endif // CLIENT

#if CLIENT
void function ControlMenu_HandleInput( float x, float y, float zoom, bool shouldEase = true )
{
	float processedX = x
	float processedY = y
	float processedZoom = zoom

	//cap delta position
	//processedX = clamp( processedX, -1, 1 )
	//processedY = clamp( processedY, -1, 1 )

	if ( fabs( processedX ) < 0.15 )
		processedX = 0.0
	if ( fabs( processedY ) < 0.15 )
		processedY = 0.0
	if ( fabs( processedZoom ) < 0.15 )
		processedZoom = 0.0

	if ( shouldEase )
	{
		processedX    = Control_CubicEase( processedX )
		processedY    = Control_CubicEase( processedY )
		processedZoom = Control_CubicEase( processedZoom )
	}

	ControlMenu_ReceiveInputContext( processedX, processedY, processedZoom, shouldEase )
}
#endif // CLIENT

#if CLIENT
float function Control_CubicEase( float val )
{
	return val * val * val
}
#endif // CLIENT

#if CLIENT
void function ControlMenu_ReceiveInputContext( float xInput, float yInput, float zoomInput, bool shouldEase = true )
{
	if ( !IsValid( file.cameraMover ) )
		return

	float lateralBoundaryDelta = 4000
	float zoomBoundaryDelta
	if ( zoomInput > 0 )
		zoomBoundaryDelta = 14000
	else
		zoomBoundaryDelta = 4000

	vector defaultCameraPosition = file.cameraLocation
	vector currentCameraPosition = file.cameraMover.GetOrigin()

	vector cameraAngles = file.cameraMover.GetAngles()
	vector cameraForward = Normalize( file.cameraMover.GetForwardVector() )
	vector cameraRight = Normalize( file.cameraMover.GetRightVector() )
	vector cameraUp = Normalize( file.cameraMover.GetUpVector() )

	float rightScalar = 1.0
	float upScalar = 1.0
	float zoomScalar = 1.0

	float processedX = xInput
	float processedY = yInput

	if ( fabs( zoomInput ) > 0.0 )
	{
		//zoom in direction of cursor
		vector cursorPosition = ConvertCursorToScreenPos()
		UISize screenSize     = GetScreenSize()
		vector cursorDelta    = <screenSize.width / 2.0, screenSize.height / 2.0, 0.0> - cursorPosition

		processedX += -9 * ( cursorDelta.x / screenSize.width ) * ( IsControllerModeActive() || zoomInput >= 0 ? 1.0 : -1.0 )
		processedY += -5 * ( cursorDelta.y / screenSize.height ) * ( IsControllerModeActive() || zoomInput >= 0 ? 1.0 : -1.0 )

		if ( IsControllerModeActive() )
		{
			processedX *= 0.6
			processedY *= 0.6
		}
	}

	//clamp movement between deltas
	vector deltaVector = currentCameraPosition - defaultCameraPosition

	float deltaOnRight = cameraRight.Dot( deltaVector )
	if ( fabs( deltaOnRight ) >= lateralBoundaryDelta && deltaOnRight * processedX > 0 )
		rightScalar = 0.0

	float deltaOnUp = cameraUp.Dot( deltaVector )
	if ( fabs( deltaOnUp ) >= lateralBoundaryDelta && -1 * deltaOnUp * processedY > 0)
		upScalar = 0.0

	float deltaOnForward = cameraForward.Dot( deltaVector )
	if ( fabs( deltaOnForward ) >= zoomBoundaryDelta && deltaOnForward * zoomInput > 0)
		zoomScalar = 0.0

	vector pos = currentCameraPosition
	pos += processedX * cameraRight * 500 * rightScalar
	pos += processedY * cameraUp * -500 * upScalar
	pos += zoomInput * cameraForward * 500 * zoomScalar

	file.cameraMover.NonPhysicsMoveTo( pos, 0.2, 0.0, 0.075 )
}
#endif // CLIENT

#if CLIENT
void function UICallback_ControlMenu_MouseWheelUp()
{
	//ControlMenu_HandleInput( 0, 0, 7.0, false )
}
#endif // CLIENT

#if CLIENT
void function UICallback_ControlMenu_MouseWheelDown()
{
	//ControlMenu_HandleInput( 0, 0, -7.0, false )
}
#endif // CLIENT

#if CLIENT
void function Control_UIManager_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	player.EndSignal( "Control_PlayerHasChosenRespawn" )
	player.EndSignal( "OnDestroy" )

	var gameStateRui = ClGameState_GetRui()

	CreateRespawnBlur()
	Control_UpdatePlayerExpPercentAmountsForSpawns( player )

	if ( file.firstTimeRespawnShouldWait )
	{
		//wait for the banner to go away
		wait CONTROL_INTRO_DELAY
	}

	RunUIScript( "ControlSpawnMenu_SetLoadoutAndLegendSelectMenuIsEnabled", true )
	RuiSetBool( gameStateRui, "isRespawning", true )

	//We don't want killfeed appearing over the respawn menu
	Obituary_ClearObituary()
	Obituary_SetEnabled( false )

	if ( file.firstTimeRespawnShouldWait )
	{
		file.firstTimeRespawnShouldWait = false

		// Open the Loadout Select Menu the first time players enter the game
		if ( IsUsingLoadoutSelectionSystem() )
			RunUIScript( "LoadoutSelectionMenu_OpenLoadoutMenu", false )
	}
	else if ( file.shouldImmediatelyOpenCharacterSelectOnRespawn || GamemodeUtility_IsJIPPlayerSpawnBonusPending( player ) )
	{
		// If we want to open the character select menu right away open it instead of the spawn menu
		// This is triggered when a player selects to respawn and change legend in gameplay
		wait 0.1 // These kinds of waits suck but this one is needed to prevent the transition from the death screen breaking the background for the Character Select Menu
		Control_OpenCharacterSelect()
		file.shouldImmediatelyOpenCharacterSelectOnRespawn = false
	}
	else // We only need to trigger the spawn menu if we don't open the Loadout or Character Select Menu ( since they open the spawn menu when closed )
	{
		thread Control_TriggerShowSpawnMenuOnUI_Thread( player, false )
	}
}
#endif // CLIENT

#if CLIENT
void function Control_CameraInputManager_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	EndSignal( player, "Control_NewCameraDataReceived", "Control_PlayerStartingRespawnSelection", "Control_PlayerHasChosenRespawn", "Control_PlayerHideScoreboardMap" )

	file.isPlayerInMapCameraView = true
	Control_UpdateTeammateMapIconVisibility()

	vector cameraPosition = file.cameraLocation
	vector cameraAngles = file.cameraAngles

	entity cameraMover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", cameraPosition, cameraAngles )
	entity camera      = CreateClientSidePointCamera( cameraPosition, cameraAngles, 70.0 )
	player.SetMenuCameraEntity( camera )
	//player.SetMenuCameraBloomAmountOverride( GetMapBloomSettings().control )
	camera.SetTargetFOV( 70.0, true, EASING_CUBIC_INOUT, 0.0 )
	camera.SetParent( cameraMover, "", false )

	file.cameraMover = cameraMover

	OnThreadEnd(
		function() : ( player, camera, cameraMover )
		{
			//todo: ease camera into player if player is alive

			if ( IsValid( player ) )
				player.ClearMenuCameraEntity()
			file.cameraMover = null
			if ( IsValid( camera ) )
				camera.Destroy()
			//cameraMover.MakeSafeForUIScriptHack()
			//if ( IsValid( cameraMover ) )
			//	cameraMover.Destroy()

			file.isPlayerInMapCameraView = false
			Control_UpdateTeammateMapIconVisibility()
		}
	)

	WaitForever()
}
#endif // CLIENT

#if CLIENT
vector function ConvertCursorToScreenPos()
{
	vector mousePos   = GetCursorPosition()
	UISize screenSize = GetScreenSize()
	mousePos = < mousePos.x * screenSize.width / 1920.0, mousePos.y * screenSize.height / 1080.0, 0.0 >
	return mousePos
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_LaunchSpawnMenuProcessThread()
{
	thread ProcessSpawnMenu( GetLocalClientPlayer() )
}
#endif // CLIENT

#if CLIENT
void function ProcessSpawnMenu( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( CONTROL_DETAILED_DEBUG )
		printt( "CONTROL: kicking off ProcessSpawnMenu thread" )

	player.Signal( "OnValidSpawnPointThreadStarted" )

	player.EndSignal( "OnSpawnMenuClosed" )
	player.EndSignal( "OnValidSpawnPointThreadStarted" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			if ( ClGameState_GetRui() != null )
				RuiSetBool( ClGameState_GetRui(), "isInSpawnMenu", false )
		}
	)

	if ( ClGameState_GetRui() != null )
		RuiSetBool( ClGameState_GetRui(), "isInSpawnMenu", true )

	while ( !IsAlive( player ) )
	{
		bool shouldShowWaypoints = player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" )
		int playerTeam = player.GetTeam()
		int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( playerTeam )

		foreach ( wp in file.spawnWaypoints )
		{
			if ( !IsValid( wp ) )
				continue

			// By default, waypoints are set to not usable and not visible
			bool shouldShowThisWaypoint = false
			int spawnWaypointTeamUsability = eControlSpawnWaypointUsage.NOT_USABLE

			if ( shouldShowWaypoints )
			{
				entity wpParentEnt = wp.GetParent()
				if ( IsValid( wpParentEnt ) )
				{
					int waypointTypeIndex = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
					switch( waypointTypeIndex )
					{
						case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A: // Alliance A Homebase
							// Always show Homebase waypoints regardless of whether the player can spawn on it or not
							shouldShowThisWaypoint = true // show base spawns
							// Only allow use of your base
							spawnWaypointTeamUsability = localPlayerAlliance == ALLIANCE_A ? eControlSpawnWaypointUsage.FRIENDLY_TEAM : eControlSpawnWaypointUsage.NOT_USABLE
							break
						case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B: // Alliance B Homebase
							// Always show Homebase waypoints regardless of whether the player can spawn on it or not
							shouldShowThisWaypoint = true // show base spawns
							// Only allow use of your base
							spawnWaypointTeamUsability = localPlayerAlliance == ALLIANCE_B ? eControlSpawnWaypointUsage.FRIENDLY_TEAM : eControlSpawnWaypointUsage.NOT_USABLE
							break
						case eControlWaypointTypeIndex.OBJECTIVE_A:  // Objective A
							// Always show Objective waypoints regardless of whether the player can spawn on it or not
							shouldShowThisWaypoint = true
							int waypointOwner = wpParentEnt.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
							// Determine waypoint usability from this Clients perspective
							if ( waypointOwner == ALLIANCE_A && localPlayerAlliance == ALLIANCE_A ) // This is the Alliance A FOB, only they can use it if they own it
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.FRIENDLY_TEAM
							else
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.NOT_USABLE
							break
						case eControlWaypointTypeIndex.OBJECTIVE_B:  // Objective B
							// Always show Objective waypoints regardless of whether the player can spawn on it or not
							shouldShowThisWaypoint = true
							// Determine waypoint usability from this Clients perspective
							if ( Control_CanAllianceMemberSpawnOnObjectiveB( localPlayerAlliance ) )
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.FRIENDLY_TEAM
							else if ( Control_CanAllianceMemberSpawnOnObjectiveB( AllianceProximity_GetOtherAlliance( localPlayerAlliance ) ) )
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.ENEMY_TEAM
							else
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.NOT_USABLE
							break
						case eControlWaypointTypeIndex.OBJECTIVE_C:  // Objective C
							// Always show Objective waypoints regardless of whether the player can spawn on it or not
							shouldShowThisWaypoint = true
							int waypointOwner = wpParentEnt.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
							// Determine waypoint usability from this Clients perspective
							if ( waypointOwner == ALLIANCE_B && localPlayerAlliance == ALLIANCE_B ) // This is the Alliance B FOB, only they can use it if they own it
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.FRIENDLY_TEAM
							else
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.NOT_USABLE
							break
						case eControlWaypointTypeIndex.MRB_SPAWN: // MRB spawn
							int waypointOwner = wp.GetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX )
							bool isYourWaypoint = waypointOwner == localPlayerAlliance
							spawnWaypointTeamUsability = isYourWaypoint ? eControlSpawnWaypointUsage.FRIENDLY_TEAM : eControlSpawnWaypointUsage.ENEMY_TEAM
							shouldShowThisWaypoint = isYourWaypoint
							break
							case eControlWaypointTypeIndex.SQUAD_SPAWN: // Player spawn ( in spawn on squad logic )
							// If the player for the squad spawn waypoint is alive and not the local player, allow the player to spawn on them
							if ( wpParentEnt.IsPlayer() && wpParentEnt != player && IsAlive( wpParentEnt ) && wpParentEnt.GetTeam() == playerTeam )
							{
								shouldShowThisWaypoint = true
								spawnWaypointTeamUsability = eControlSpawnWaypointUsage.FRIENDLY_TEAM
							}
							break
						default:
							printt( "Control: Unexpected waypoint type: ", waypointTypeIndex, " in ProcessSpawnMenu switch statement" )
							break
					}
				}
			}
			SpawnMenu_ButtonUpdate( wp, shouldShowThisWaypoint, spawnWaypointTeamUsability )
		}

		int lastLocalPingObjID = -1
		entity lastLocalObjectivePing = CaptureObjectivePing_GetLastPingedObjective()
		if ( IsValid( lastLocalObjectivePing ) )
		{
			entity objectiveWaypoint = lastLocalObjectivePing.GetOwner()
			if ( Control_IsObjectiveWaypoint( objectiveWaypoint ) )
				lastLocalPingObjID = objectiveWaypoint.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
		}

		RunUIScript( "SetLastLocalPingObjIDForUI", lastLocalPingObjID )
		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
void function SpawnMenu_ButtonUpdate( entity wp, bool shouldShowWaypoint, int spawnWaypointTeamUsability )
{
	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	if ( !IsValid( wp ) )
	{
		printt( "CONTROL: SpawnMenu_ButtonUpdate running with Invalid wp, breaking out" )
		return
	}

	int waypointEHI = wp.GetEncodedEHandle()

	if ( shouldShowWaypoint )
	{
		int waypointTypeIndex = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
		float[2] screenPos = GetScreenSpace( wp.GetOrigin() )
		string nameInformation = ""
		float capturePercentage = 0
		int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() )

		switch( waypointTypeIndex )
		{
			case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
			case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
				RunUIScript( "SetWaypointDataForUI",
					waypointEHI,
					true,
					spawnWaypointTeamUsability,
					waypointTypeIndex,
					screenPos[0],
					screenPos[1],
					Localize( "#CONTROL_BASE" ),
					capturePercentage,
					ALLIANCE_NONE,
					ALLIANCE_NONE,
					ALLIANCE_NONE,
					localPlayerAlliance,
					false,
					0
				)
				break
			case eControlWaypointTypeIndex.OBJECTIVE_A:
			case eControlWaypointTypeIndex.OBJECTIVE_B:
			case eControlWaypointTypeIndex.OBJECTIVE_C:
				int currentControllingTeam = ALLIANCE_NONE
				int currentOwner = ALLIANCE_NONE
				int neutralPointOwnership = ALLIANCE_NONE
				bool hasEmphasis = false
				entity objective = wp.GetParent()
				int numTeamPings = 0
				int allianceAPlayersOnObjective = 0
				int allianceBPlayersOnObjective = 0
				if ( IsValid( objective ) )
				{
					currentControllingTeam = objective.GetWaypointInt( INT_CAPTURING_ALLIANCE )
					currentOwner = objective.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)
					neutralPointOwnership = objective.GetWaypointInt( CONTROL_INT_OBJ_NEUTRAL_ALLIANCE_OWNER )
					capturePercentage = objective.GetWaypointFloat( FLOAT_CAP_PERC )
					hasEmphasis = objective.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) > 0
					if ( localPlayerAlliance != ALLIANCE_NONE )
						numTeamPings = CaptureObjectivePing_GetPingCountForObjectiveForTeamOrAlliance( objective, localPlayerAlliance )

					allianceAPlayersOnObjective = objective.GetWaypointInt( INT_ALLIANCE_A_PLAYERSONOBJ )
					allianceBPlayersOnObjective = objective.GetWaypointInt( INT_ALLIANCE_B_PLAYERSONOBJ )
				}

				RunUIScript( "SetWaypointDataForUI",
					waypointEHI,
					true,
					spawnWaypointTeamUsability,
					waypointTypeIndex,
					screenPos[0],
					screenPos[1],
					CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( waypointTypeIndex ),
					capturePercentage,
					currentControllingTeam,
					currentOwner,
					neutralPointOwnership,
					localPlayerAlliance,
					hasEmphasis,
					allianceAPlayersOnObjective,
					allianceBPlayersOnObjective,
					numTeamPings
				)
				break
			case eControlWaypointTypeIndex.MRB_SPAWN:
				if ( IsValid( wp.GetParent() ) )
				{
					nameInformation = Localize( "#CONTROL_MRB_SPAWN_NAME" )
					// capturePercentage var is used to transmit the end time for the MRB Icon so the timer can be displayed ( since the MRB icon doesn't show capture progress)
					capturePercentage = wp.GetWaypointFloat( CONTROL_MRB_SPAWN_WAYPOINT_ENDTIME )
					int currentControllingTeam = wp.GetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX )
					int currentOwner = currentControllingTeam

					RunUIScript( "SetWaypointDataForUI",
						waypointEHI,
						true,
						spawnWaypointTeamUsability,
						waypointTypeIndex,
						screenPos[0],
						screenPos[1],
						nameInformation,
						capturePercentage,
						currentControllingTeam,
						currentOwner,
						ALLIANCE_NONE,
						localPlayerAlliance,
						false
					)
				}
				break
			case eControlWaypointTypeIndex.SQUAD_SPAWN:
				if ( IsValid( wp.GetParent() ) && wp.GetParent().IsPlayer() )
					nameInformation = wp.GetParent().GetPlayerName()
				break
			default:
				break
		}
	}
	else
	{
		RunUIScript( "SetWaypointDataForUI", waypointEHI, false, spawnWaypointTeamUsability, 0, -1, -1, "" )
	}
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_ReportMenu_OnOpened()
{

}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_ReportMenu_OnClosed()
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )    // not sure when this can be invalid
		return

	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	thread Control_TriggerShowSpawnMenuOnUI_Thread( player, true )
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_OnMenuPreClosed()
{
	if ( IsValid( GetLocalClientPlayer() ) )
		GetLocalClientPlayer().Signal( "OnSpawnMenuClosed" )

	//reset spawn header state
	if ( IsValid( file.spawnHeader ) )
	{
		var rui = Hud_GetRui( file.spawnHeader )
		if ( IsValid( rui ) )
		{
			RuiSetBool( rui, "spawnSelected", false )
		}
	}

	file.spawnHeader = null
	file.uiVMUpdateTime = 0
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_SpawnHeaderUpdated( var spawnHeader, float time )
{
	file.spawnHeader = spawnHeader
	file.uiVMUpdateTime = time
}
#endif // CLIENT

#if CLIENT
void function Control_OpenCharacterSelectMenu( var button )
{
	if ( GetGameState() != eGameState.Playing )
		return

	Control_OpenCharacterSelect()
}
#endif // CLIENT

#if CLIENT
const float CONTROL_BUTTON_PRESS_BUFFER = 0.5 // Don't recognize button inputs for this long in menus to prevent accidental activation on rapid presses
void function Control_OpenCharacterSelect()
{
	//safety so if this gets called outside of the mode due to a button callback, we can cancel the state
	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	// since we are using BUTTON_A to open the character select and that is also the button that selects the character we need to not open the menu again for that button press.
	if ( file.characterSelectClosedTime + CONTROL_BUTTON_PRESS_BUFFER > Time() )
		return

	entity clientPlayer = GetLocalClientPlayer()

	if ( !IsValid( clientPlayer ) )
		return

	//no character select from this callback if not choosing respawn
	if ( !clientPlayer.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	DestroyRespawnBlur()

	// Update the state of the rui so we know we are currently not in the spawn screen
	if ( ClGameState_GetRui() != null )
		RuiSetBool( ClGameState_GetRui(), "isInSpawnMenu", false )

	const bool browseMode = true
	const bool showLockedCharacters = true
	bool isJIP = GamemodeUtility_IsJIPPlayerSpawnBonusPending( clientPlayer )
	HideScoreboard()

	OpenCharacterSelectMenu( browseMode, showLockedCharacters, isJIP )
}
#endif // CLIENT

#if CLIENT
void function Control_OnCharacterSelectMenuClosed()
{
	file.characterSelectClosedTime = Time()
	entity player = GetLocalClientPlayer()

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	CreateRespawnBlur()
	if ( !file.firstTimeRespawnShouldWait )
	{
		//don't do this while going through character select
		thread Control_TriggerShowSpawnMenuOnUI_Thread( player, false )
	}

	thread Control_CameraInputManager_Thread( player )

	// Update the state of the rui so we know we are currently not in the spawn screen
	if ( ClGameState_GetRui() != null )
		RuiSetBool( ClGameState_GetRui(), "isInSpawnMenu", true )
}
#endif // CLIENT

#if CLIENT
// Determine the time displayed on the wave spawn timer bar on screen while the player is on the spawn select screen ( also displays over the legend select screen and loadout select screen )
void function Control_SetWaveSpawnTimerTime()
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	if ( player.GetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn" ) )
		return

	if ( IsValid( file.spawnHeader ) )
	{
		var rui = Hud_GetRui( file.spawnHeader )

		if ( IsValid( rui ) )
		{
			float startTime = GetGlobalNetTimeSafe( "control_WaveStartTime" )
			float endTime =  GetGlobalNetTimeSafe( "control_WaveSpawnTime" )
			RuiSetGameTime( rui, "respawnStartTime", startTime )
			RuiSetGameTime( rui, "respawnEndTime", endTime )
		}
	}
}
#endif // CLIENT

#if CLIENT
// Determine the visibility of the wave spawn timer bar on screen while the player is on the spawn select screen ( also displays over the legend select screen and loadout select screen )
void function ServerCallback_Control_UpdateSpawnWaveTimerVisibility( bool isVisible )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	// If there is no chance of displaying the timer and it's not created don't bother creating it
	if ( file.spawnHeader == null && ( !isVisible || player.GetPlayerNetBool( "control_IsPlayerExemptFromWaveSpawn" ) ) )
		return

	Control_SetWaveSpawnTimerTime()
}
#endif // CLIENT

#if CLIENT
// Display an alert message related to the state of a selected spawn ( spawn cancelled, spawn no longer available etc)
void function ServerCallback_Control_DisplaySpawnAlertMessage( int spawnAlertMessageCode )
{
	var rui
	if ( !IsValid( file.spawnHeader ) )
		return

	rui = Hud_GetRui( file.spawnHeader )
	if ( !IsValid( rui) )
		return

	RunUIScript( "Control_SetAllButtonsEnabled" )

	string message
	bool isMessageCodeValid = false
	switch ( spawnAlertMessageCode )
	{
		case eControlSpawnAlertCode.SPAWN_FAILED:
			message = "#CONTROL_FAILED_SPAWN"
			isMessageCodeValid = true
			break
		case eControlSpawnAlertCode.SPAWN_CANCELLED:
			message = "#CONTROL_CANCELLED_SPAWN"
			isMessageCodeValid = true
			break
		case eControlSpawnAlertCode.SPAWN_LOST_SPAWNPOINT:
			message = "#CONTROL_LOST_SELECTED_SPAWN"
			isMessageCodeValid = true
			break
		case eControlSpawnAlertCode.SPAWN_LOST_MRB:
			message = "#CONTROL_MRB_SPAWN_NOT_AVAIL"
			isMessageCodeValid = true
			break
		default:
			break
	}

	if ( isMessageCodeValid )
	{
		RuiSetString( rui, "spawnAlertMessage", message )
		RuiSetGameTime( rui, "alertTime", ClientTime() )
	}
}
#endif // CLIENT

#if CLIENT
// Display a message next to the wave spawn timer element that communicates the current spawn state ( has spawn selected for example)
void function ServerCallback_Control_DisplayWaveSpawnBarStatusMessage( bool isShowingMessage, int spawnType )
{
	if ( !IsValid( file.spawnHeader ) )
		return

	var rui = Hud_GetRui( file.spawnHeader )
	if ( IsValid( rui ) )
	{
		if ( isShowingMessage )
		{
			RuiSetBool( rui, "spawnSelected", true )

			float startTime = GetGlobalNetTimeSafe( "control_WaveStartTime" )
			float endTime =  GetGlobalNetTimeSafe( "control_WaveSpawnTime" )
			RunUIScript("SetRespawnOverlayTime", startTime, endTime)

			string spawnChoice
			switch( spawnType )
			{
				case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
				case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
					spawnChoice = "#CONTROL_BASE"
					break
				case eControlWaypointTypeIndex.OBJECTIVE_A:
				case eControlWaypointTypeIndex.OBJECTIVE_B:
				case eControlWaypointTypeIndex.OBJECTIVE_C:
					spawnChoice = "#CONTROL_POINT"
					break
				case eControlWaypointTypeIndex.SQUAD_SPAWN:
					spawnChoice = "#CONTROL_SQUAD"
					break
				case eControlWaypointTypeIndex.MRB_SPAWN:
					spawnChoice = "#CONTROL_MRB"
					break
				default:
					spawnChoice = ""
					break
			}

			RuiSetString( rui, "spawnOptionSelected", spawnChoice )
		}
		else
		{
			RunUIScript("SetRespawnOverlayTime", RUI_BADGAMETIME, RUI_BADGAMETIME)
			RuiSetBool( rui, "spawnSelected", false )
		}
	}
}
#endif // CLIENT

#if CLIENT
// Create and manage the life of a death icon for teammates on the map
void function Control_CreateTeammateDeathIcon_3DMap_Thread( entity victimWP )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( victimWP ) )
		return

	entity localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) )
		return

	bool isLocalPlayerObserver = Control_IsPlayerPrivateMatchObserver( localPlayer )
	int localPlayerTeam = localPlayer.GetTeam()

	if ( !isLocalPlayerObserver && !IsFriendlyTeam( localPlayerTeam, victimWP.GetTeam() ) )
		return

	entity victim = victimWP.GetWaypointEntity( CONTROL_PLAYERLOC_WAYPOINT_PLAYERENTITY_INDEX )

	if ( !IsValid( victim ) || IsAlive( victim ) ) // The WP can get destroyed when switching observer targets which would trigger this function. Don't show death icons in that case
		return

	var rui = CreateFullscreenRui(  $"ui/control_teammate_death_icon.rpak", CONTROL_TEAMMATE_ICON_SORTING )
	file.teammateDeathIconRuiArray.append( rui )

	OnThreadEnd(
		function() : ( rui )
		{
			file.teammateDeathIconRuiArray.fastremovebyvalue( rui )
			if ( IsValid( rui ) )
				RuiDestroy( rui )
		}
	)

	vector deathLoc = victim.GetOrigin()
	int victimTeam = victim.GetTeam()
	bool isVictimSquadmate = localPlayerTeam == victimTeam

	if ( isLocalPlayerObserver )
	{
		RuiSetColorAlpha( rui, "deathIconColor", Teams_GetTeamColor( victimTeam ), 1.0 )
	}
	else if ( isVictimSquadmate )
   	{
	   	RuiSetColorAlpha( rui, "deathIconColor", SrgbToLinear( GetTeammateIconColor( victim ) / 255.0 ), 1.0 )
   	}

	RuiSetGameTime( rui, "deathStartTime", Time() )
	RuiSetFloat3( rui, "deathLocation", deathLoc )
	RuiSetBool( rui, "display", Control_IsLocalClientInMapCameraView() )

	// Wait the icon lifetime before destroying the icon ( note the visibility of the icon is managed by Control_UpdateTeammateMapIconVisibility
	wait CONTROL_TEAMMATE_DEATH_ICON_LIFETIME
}
#endif // CLIENT

#if CLIENT
// Return whether the local player is a private match observer
bool function Control_IsPlayerPrivateMatchObserver( entity player )
{
	return IsPrivateMatch() && player.IsObserver() && player.GetTeam() == TEAM_SPECTATOR
}
#endif // CLIENT

#if CLIENT
// Triggers when a waypoint is created that tracks player location. We use it to display an icon on the map to teammates.
void function InstanceWPControlPlayerLoc( entity wp )
{
	thread Control_TeamLocationWaypointThink_Thread( wp )
}
#endif // CLIENT

#if CLIENT
vector function GetTeammateIconColor( entity player )
{
	return GetKeyColor( COLORID_MEMBER_COLOR0, player.GetTeamMemberIndex() )
}
#endif // CLIENT

#if CLIENT
// Thread that manages the teammate location icon
void function Control_TeamLocationWaypointThink_Thread( entity wp )
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) || !IsValid( wp ) )
		return

	bool isLocalPlayerObserver = Control_IsPlayerPrivateMatchObserver( localPlayer )
	int localPlayerTeam = localPlayer.GetTeam()

	if ( !isLocalPlayerObserver && !IsFriendlyTeam( localPlayerTeam, wp.GetTeam() ) )
		return

	var rui = CreateWaypointRui( $"ui/control_teammate_loc_icon.rpak", CONTROL_TEAMMATE_ICON_SORTING )
	file.teammateLocationIconRuiArray.append( rui )

	wp.EndSignal( "OnDestroy" )
	localPlayer.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( rui, wp )
		{
			entity localPlayer = GetLocalViewPlayer()
			if ( IsValid( localPlayer ) )
				thread Control_CreateTeammateDeathIcon_3DMap_Thread( wp )

			file.teammateLocationIconRuiArray.fastremovebyvalue( rui )
			RuiDestroy( rui )
		}
	)

	entity teammate = wp.GetWaypointEntity( CONTROL_PLAYERLOC_WAYPOINT_PLAYERENTITY_INDEX )

	if ( IsValid( teammate ) )
	{
		int teammateTeam = teammate.GetTeam()
		bool isTeammateSquadmate = localPlayerTeam == teammateTeam
		if ( isLocalPlayerObserver ) // Display alliance color for observer
		{
			RuiSetColorAlpha( rui, "teammateIconColor", Teams_GetTeamColor( teammateTeam ), 1.0 )
		}
		else if ( isTeammateSquadmate )
		{
			RuiSetFloat2( rui, "teammateIconScale", <1.5, 1.5, 0.0> )
		}

		RuiTrackFloat3( rui, "teammateLocation", teammate, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat3( rui, "teammateRotation", teammate, RUI_TRACK_CAMANGLES_FOLLOW )
		RuiSetFloat3( rui, "cameraLookDirection", file.cameraAngles )
		RuiSetGameTime( rui, "spawnStartTime", Time() )
		RuiSetBool( rui, "display", Control_IsLocalClientInMapCameraView() )

		// Wait until the teammate dies ( wp is destroyed ), Note the visibility of the icon is controlled by Control_UpdateTeammateMapIconVisibility
		WaitForever()
	}
}
#endif // CLIENT

#if CLIENT
// Triggered when the local client player switches between being in the map camera view and not being in the map camera view
void function Control_UpdateTeammateMapIconVisibility()
{
	// Update visibility of teammate location icons
	foreach ( var locationIcon in file.teammateLocationIconRuiArray )
	{
		if ( IsValid( locationIcon ) )
			RuiSetBool( locationIcon, "display", Control_IsLocalClientInMapCameraView() )
	}

	// Update visibility of teammate death icons
	foreach ( var deathIcon in file.teammateDeathIconRuiArray )
	{
		if ( IsValid( deathIcon ) )
			RuiSetBool( deathIcon, "display", Control_IsLocalClientInMapCameraView() )
	}
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_Control_DisplayIconAtPosition( vector position, int iconIndex, int colorID, float duration )
{
	asset icon = $""
	switch ( iconIndex )
	{
		case eControlIconIndex.DEATH_ICON:
			icon = TEAMMATE_DEATH_ICON
			break
		case eControlIconIndex.SPAWN_ICON:
			icon = TEAMMATE_SPAWN_ICON
			break
		default:
			break
	}

	thread DisplayIconAtPosition_Thread( position, icon, colorID, duration )
}
#endif // CLIENT

#if CLIENT
void function DisplayIconAtPosition_Thread( vector position, asset icon, int colorID, float duration )
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	vector iconColor = GetKeyColor( colorID ) * ( 1.0 / 255.0 )
	var minimapRui = Minimap_AddIconAtPosition( position, <0,90,0>, icon, 0.9, iconColor )
	var fullmapRui = FullMap_AddIconAtPos( position, <0,0,0>, icon, 6.0, iconColor )

	OnThreadEnd(
		function() : ( minimapRui, fullmapRui )
		{
			Minimap_CommonCleanup( minimapRui )
			Fullmap_RemoveRui( fullmapRui )
			RuiDestroy( fullmapRui )
		}
	)

	wait duration
}
#endif // CLIENT

/*
 __          ________          _____   ____  _   _   ________      ______   __          ________          _____   ____  _   _    _____ _    _ ______ _____ _  __ _____
 \ \        / /  ____|   /\   |  __ \ / __ \| \ | | |  ____\ \    / / __ \  \ \        / /  ____|   /\   |  __ \ / __ \| \ | |  / ____| |  | |  ____/ ____| |/ // ____|
  \ \  /\  / /| |__     /  \  | |__) | |  | |  \| | | |__   \ \  / / |  | |  \ \  /\  / /| |__     /  \  | |__) | |  | |  \| | | |    | |__| | |__ | |    | ' /| (___
   \ \/  \/ / |  __|   / /\ \ |  ___/| |  | | . ` | |  __|   \ \/ /| |  | |   \ \/  \/ / |  __|   / /\ \ |  ___/| |  | | . ` | | |    |  __  |  __|| |    |  <  \___ \
    \  /\  /  | |____ / ____ \| |    | |__| | |\  | | |____   \  / | |__| |    \  /\  /  | |____ / ____ \| |    | |__| | |\  | | |____| |  | | |___| |____| . \ ____) |
     \/  \/   |______/_/    \_\_|     \____/|_| \_| |______|   \/   \____/      \/  \/   |______/_/    \_\_|     \____/|_| \_|  \_____|_|  |_|______\_____|_|\_\_____/

	WEAPON EVO WEAPON CHECKS
*/
// ToDo: DSwieczko remove this whole section if we decide to keep evo on reload
#if SERVER
bool function Control_PlayerIsInCombat( entity player, bool shouldDoWeaponTests )
{
	const float TEAMMATE_NEAR_SPOTTED_ENEMY = 512.0
	const float LAST_DAMAGED_BY_PLAYER_OR_NPC = 2.5
	const float LAST_DID_DAMAGE_TO_PLAYER_OR_NPC = 2.5
	const float LAST_BAD_WEAPON_CHECK = 2.5

	if ( Bleedout_IsBleedingOut( player ) )
		return true

	// Test if the player is being damaged by another player or bot
	if ( GetEffectiveDeltaSince( player.GetLastTimeDamagedByOtherPlayer() ) < LAST_DAMAGED_BY_PLAYER_OR_NPC )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_PlayerIsInCombat() - player damaged by other player" )
		#endif // DEV

		return true
	}

	if ( GetEffectiveDeltaSince( player.GetLastTimeDamagedByNPC() ) < LAST_DAMAGED_BY_PLAYER_OR_NPC )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_PlayerIsInCombat() - player damaged by NPC" )
		#endif // DEV

		return true
	}

	if ( GetEffectiveDeltaSince( player.GetLastTimeDidDamageToOtherPlayer() ) < LAST_DID_DAMAGE_TO_PLAYER_OR_NPC )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_PlayerIsInCombat() - Last did damage to other player" )
		#endif // DEV

		return true
	}

	if ( GetEffectiveDeltaSince( player.GetLastTimeDidDamageToNPC() ) < LAST_DID_DAMAGE_TO_PLAYER_OR_NPC )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_PlayerIsInCombat() - Last did damage to NPC" )
		#endif // DEV

		return true
	}

	if ( Waypoint_AnyEnemySpottedNearPointForPlayer( player.EyePosition(), TEAMMATE_NEAR_SPOTTED_ENEMY, player ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_PlayerIsInCombat() - Any teammate near spotted enemy" )
		#endif // DEV

		return true
	}

	if ( shouldDoWeaponTests && GetEffectiveDeltaSince( Control_GetTimeOfEXPEvoBadWeaponCheck( player ) ) < LAST_BAD_WEAPON_CHECK )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_PlayerIsInCombat() - failed weapon check" )
		#endif // DEV

		return true
	}

	return false
}
#endif // SERVER

#if SERVER
// Check if Evo weapon checks are failing, if they are get the time and send it as the last fail time. Otherwise, return the last time the checks failed.
float function Control_GetTimeOfEXPEvoBadWeaponCheck( entity player )
{
	const float LAST_FIRED_TIME_ALLOWANCE = 0.5
	float lastBadWeaponCheckTime = 0.0

	if ( !IsValid( player ) )
		return lastBadWeaponCheckTime

	bool isWeaponCheckBad = false

	// Weapon Check fails if player is aiming down sights
	if ( PlayerIsInADS( player ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( player in ADS )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon Check fails if the player is using their tactical
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.altHand ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( using tac )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is using their Ult or tac
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( using main  )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

    // weapon check fails if the player is reloading
	if ( IsValid( weapon ) && weapon.IsReloading() )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( reloading )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if the player is trying to use ordnance
	if ( IsValid( weapon ) )
	{
		LootData data = SURVIVAL_GetLootDataFromWeapon( weapon )
		if ( data.lootType == eLootType.ORDNANCE )
		{
			#if DEV
				if ( CONTROL_DETAILED_DEBUG )
					printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( using ordnance )" )
			#endif // DEV

			isWeaponCheckBad = true
		}
	}

	/*if ( IsValid( weapon ) && weapon.GetEnergizeState() == ENERGIZE_ENERGIZING )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( charging )" )
		#endif // DEV

		isWeaponCheckBad = true
	}*/

	// Weapon check fails if player is firing their weapon
	if ( GetEffectiveDeltaSince( player.GetLastFiredTime() ) < LAST_FIRED_TIME_ALLOWANCE )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( firing weapon )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is switching weapons
	if ( player.IsSwitching( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) || player.IsSwitching( WEAPON_INVENTORY_SLOT_PRIMARY_1 ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( switching weapons )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is emoting
	if ( player.Anim_IsActive() )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( Anim_IsActive )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// weapon check fails if the player is using a console or picking something up
	if ( player.IsInputCommandHeld( IN_USE ) || player.IsInputCommandHeld( IN_USE_LONG ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( using interaction )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is phase shifted
	if ( player.IsPhaseShifted() )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( phasing )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is placing a portal
	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( placing phase tunnel )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is trying to heal
	if ( player.GetPlayerNetBool( "isHealing" ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( healing )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if player is using melee
	if ( player.PlayerMelee_GetState() != PLAYER_MELEE_STATE_NONE )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( melee )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	if ( AreWeaponsLockedOrDisabled( player ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( weapons locked )" )
		#endif // DEV

		isWeaponCheckBad = true
	}

	// Weapon check fails if weapon is null
	if ( !IsValid( weapon ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: Control_GetTimeOfEXPEvoBadWeaponCheck - Bad weapon check ( weapon is null )" )
		#endif // DEV

		// There are some issues if weapon evo gets interupted ( ultimate, mantle, possibly others) where weapons are evolved but don't get equipped properly.
		// If that issue occurred, just manually equip a weapon to immediately recover from the issue
		if ( !isWeaponCheckBad && !Control_GetIsPlayerWeaponEvoInProgress( player ) )
		{
			int weaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
			entity unequippedWeapon = player.GetNormalWeapon( weaponSlot )
			if ( IsValid( unequippedWeapon ) )
				player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, weaponSlot )
		}

		isWeaponCheckBad = true
	}

	// If weapon check failed, set the current time as the last failed time
	if ( isWeaponCheckBad )
		file.playerToLastEXPEvoBadWeaponCheckTimeTable[ player ] <- Time()

	// If the player has a last failed time, set it to return
	if ( player in file.playerToLastEXPEvoBadWeaponCheckTimeTable )
		lastBadWeaponCheckTime = file.playerToLastEXPEvoBadWeaponCheckTimeTable[ player ]

	return lastBadWeaponCheckTime
}
#endif // SERVER

/*
 __      __  ______   _    _   _____    _____   _        ______
 \ \    / / |  ____| | |  | | |_   _|  / ____| | |      |  ____|
  \ \  / /  | |__    | |__| |   | |   | |      | |      | |__
   \ \/ /   |  __|   |  __  |   | |   | |      | |      |  __|
    \  /    | |____  | |  | |  _| |_  | |____  | |____  | |____
     \/     |______| |_|  |_| |_____|  \_____| |______| |______|


  __  __              _   _               _____   ______   __  __   ______   _   _   _______
 |  \/  |     /\     | \ | |     /\      / ____| |  ____| |  \/  | |  ____| | \ | | |__   __|
 | \  / |    /  \    |  \| |    /  \    | |  __  | |__    | \  / | | |__    |  \| |    | |
 | |\/| |   / /\ \   | . ` |   / /\ \   | | |_ | |  __|   | |\/| | |  __|   | . ` |    | |
 | |  | |  / ____ \  | |\  |  / ____ \  | |__| | | |____  | |  | | | |____  | |\  |    | |
 |_|  |_| /_/    \_\ |_| \_| /_/    \_\  \_____| |______| |_|  |_| |______| |_| \_|    |_|

 VEHICLE MANAGEMENT
*/


#if SERVER || CLIENT
void function OnVehicleBaseSpawned( entity vehicleBase )
{
	if ( vehicleBase.GetScriptName() != "Control_SetUsableVehicleBase" )
		return
}
#endif // SERVER || CLIENT

#if SERVER
void function ParseVehicleSummonPlatformsForChosenMap()
{
	array<entity> platformCopy = clone file.vehicleSummonPlatforms
	for( int i = 0; i<file.vehicleSummonPlatforms.len(); i++ )
	{
		entity summonPlatform = file.vehicleSummonPlatforms[i]
		if( !Control_IsChildOfCurrentMapNode( summonPlatform, "summonPlatform" ) )
		{
			platformCopy.fastremovebyvalue( summonPlatform )
			summonPlatform.Destroy()
		}
	}
	file.vehicleSummonPlatforms = platformCopy

	foreach( platform in file.vehicleSummonPlatforms )
	{
		Control_SetupVehicleSummonPlatform( platform )
	}
}
#endif // SERVER

#if SERVER
void function Control_SetupVehicleSummonPlatform( entity summonPlatform )
{
	if ( !IsValid( summonPlatform ) )
		return

	summonPlatform.DisableHibernation()
	summonPlatform.SetModel( $"mdl/olympus/olympus_vehicle_base.rmdl" )
	summonPlatform.AllowMantle()
	//summonPlatform.SetUsable()
	//summonPlatform.SetUsableByGroup( "pilot" )
	//summonPlatform.AddUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
	//summonPlatform.SetUsePrompts( "#CONTROL_USE_SPAWN_VEHICLE", "#CONTROL_USE_SPAWN_VEHICLE" )
	summonPlatform.SetScriptName( "Control_SetUsableVehicleBase" )
	// Don't allow airdrops at the location of the vehicle launchers
	CreateNonExpiringAirdropBadPlace( summonPlatform.GetOrigin() + <0,0,200>, CONTROL_VEHICLE_AIRDROP_BAD_PLACE_RADIUS )

	#if DEV
		if ( CONTROL_DISPLAY_DEBUG_DRAWS )
			DebugDrawSphere( summonPlatform.GetOrigin() + <0,0,200>, CONTROL_VEHICLE_AIRDROP_BAD_PLACE_RADIUS, COLOR_RED, true, CONTROL_DEBUG_DRAW_DISPLAY_TIME )
	#endif // DEV

	thread VehicleBaseManagementThread( summonPlatform )
}
#endif // SERVER

#if SERVER
void function SpawnVehicle( entity vehicleBase, entity vehicle = null )
{
	/*vector spawnPosition = vehicleBase.GetOrigin() + <0,0,256>
	vector lookTarget = <0,0,0>
	foreach( point in file.chosenVariantData.controlPoints )
		lookTarget = lookTarget + point.location
	lookTarget = lookTarget / file.chosenVariantData.controlPoints.len()
	vector spawnAngles = VectorToAngles( lookTarget - vehicleBase.GetOrigin() )

	entity finalVehicle = vehicle
	if ( !IsValid( vehicle ) )
	{
		finalVehicle = HoverVehicle_CreateAtPosition( spawnPosition )
	}
	else
	{
		HoverVehicle_Wake( finalVehicle )
		finalVehicle.SetAbsOrigin( spawnPosition )
	}

	finalVehicle.SetAbsAngles( spawnAngles )

	if ( !file.aliveVehicles.contains( finalVehicle ) )
	{
		file.aliveVehicles.append( finalVehicle )
		thread VehicleAliveThread( finalVehicle, vehicleBase )
	}

	file.lastRecentlyUsedVehicleStack.insert( 0, finalVehicle )*/
}
#endif // SERVER

#if SERVER
void function VehicleAliveThread( entity vehicle, entity vehicleBase )
{
	/*Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( vehicle ) )
		return

	vehicle.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( vehicle, vehicleBase )
		{
			if ( file.aliveVehicles.contains( vehicle ) )
				file.aliveVehicles.fastremovebyvalue( vehicle )
		}
	)

	WaitForever()*/
}
#endif // SERVER

#if SERVER
void function VehicleBaseManagementThread( entity vehicleBase )
{
	/*Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( vehicleBase ) )
		return

	vehicleBase.SetSkin( 1 )
	entity beamFX

	//todo: setup minimap icons when available + map feature

	float lastVehicleSpawnTime = 0
	float lastVehicleBusyTime = 0
	float vehicleSpawnTimeDelay = 60
	float vehicleSpawnBusyDelay = 10

	while ( true )
	{
		float loopStartTime = Time()
		bool isVehicleNearby = false
		foreach( vehicle in file.aliveVehicles )
		{
			if ( !IsValid( vehicle ) )
				continue

			if ( Distance( vehicle.GetOrigin(), vehicleBase.GetOrigin() ) < 300 ) // make this a trigger instead
			{
				isVehicleNearby = true
				break
			}
		}

		if ( !isVehicleNearby )
		{
			vehicleBase.SetSkin( 1 )
			if ( IsValid( beamFX ) )
			{
				beamFX.Destroy()
				beamFX = null
			}

			//check if we should spawn a vehicle
			float timeSinceLastSpawn = loopStartTime - lastVehicleSpawnTime
			float timeSinceLastBusy = loopStartTime - lastVehicleBusyTime
			if ( timeSinceLastSpawn >= vehicleSpawnTimeDelay && timeSinceLastBusy >= vehicleSpawnBusyDelay )
			{
				bool didSpawnVehicle = Control_SpawnVehicleOrFindFirstAvailable( vehicleBase )
				if ( didSpawnVehicle )
					lastVehicleSpawnTime = loopStartTime //spawned vehicle - reset start time counter
				else
					lastVehicleBusyTime = loopStartTime //could not find available vehicle, try again in busy time delay
			}
		}
		else if ( isVehicleNearby )
		{
			vehicleBase.SetSkin( 0 )
			if ( beamFX == null )
				beamFX = StartParticleEffectOnEntityWithPos_ReturnEntity( vehicleBase, GetParticleSystemIndex( FX_VEHICLE_SPAWN_POINT ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0, 0, 128>, <-90, 0, 0> )
			lastVehicleBusyTime = Time() //vehicle is on platform - supress spawn
		}

		WaitFrame()
	}*/
}
#endif // SERVER

#if SERVER
bool function Control_SpawnVehicleOrFindFirstAvailable( entity vehicleBase )
{
	/*int vehiclesAvailableToSpawn = VEHICLE_LIMIT - file.aliveVehicles.len()
	if ( vehiclesAvailableToSpawn > 0 )
	{
		SpawnVehicle( vehicleBase, null)
		return true
	}
	else
	{
		foreach( vehicleToSummon in file.lastRecentlyUsedVehicleStack )
		{
			if( IsValid( vehicleToSummon ) && HoverVehicle_IsVehicleEmpty( vehicleToSummon ) && !HoverVehicle_IsAnyPlayerOnVehicle( vehicleToSummon ) )
			{
				file.lastRecentlyUsedVehicleStack.fastremovebyvalue( vehicleToSummon )
				SpawnVehicle( vehicleBase, vehicleToSummon )
				return true
			}
		}
	}
*/
	return false
}
#endif // SERVER

#if SERVER
void function Control_VehicleOnDisembark( entity player, entity vehicle )
{
	/*if ( HoverVehicle_IsVehicleEmpty( vehicle ) )
	{
		if ( file.lastRecentlyUsedVehicleStack.contains( vehicle ) )
			file.lastRecentlyUsedVehicleStack.removebyvalue( vehicle )

		file.lastRecentlyUsedVehicleStack.insert( 0, vehicle )
	}*/
}
#endif // SERVER


#if CLIENT
void function ServerCallback_Control_NoVehiclesAvailable()
{
	AnnouncementMessageRight( GetLocalClientPlayer(), Localize( "#CONTROL_NO_VEHICLES_AVAILABLE" ), "", ANNOUNCEMENT_RED, $"", CONTROL_MESSAGE_DURATION, "WXpress_Train_Update_Small" )
}
#endif // CLIENT


/*
             _   _   _   _    ____    _    _   _   _    _____   ______   __  __   ______   _   _   _______    _____
     /\     | \ | | | \ | |  / __ \  | |  | | | \ | |  / ____| |  ____| |  \/  | |  ____| | \ | | |__   __|  / ____|
    /  \    |  \| | |  \| | | |  | | | |  | | |  \| | | |      | |__    | \  / | | |__    |  \| |    | |    | (___
   / /\ \   | . ` | | . ` | | |  | | | |  | | | . ` | | |      |  __|   | |\/| | |  __|   | . ` |    | |     \___ \
  / ____ \  | |\  | | |\  | | |__| | | |__| | | |\  | | |____  | |____  | |  | | | |____  | |\  |    | |     ____) |
 /_/    \_\ |_| \_| |_| \_|  \____/   \____/  |_| \_|  \_____| |______| |_|  |_| |______| |_| \_|    |_|    |_____/

       ANNOUNCEMENTS
 */

#if CLIENT
// Display a notification when an airdrop is incoming
void function ServerCallback_Control_AirdropNotification()
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	string announcementText = Localize( "#CONTROL_INCOMING_AIRDROP" )
	vector announcementColor = <0, 0, 0>
	Obituary_Print_Localized( announcementText, announcementColor )
	AnnouncementMessageRight( player, announcementText, "", SrgbToLinear( announcementColor / 255 ), $"", CONTROL_MESSAGE_DURATION, SFX_HUD_ANNOUNCE_QUICK, SrgbToLinear( announcementColor / 255 ) )
}
#endif // CLIENT

#if CLIENT
// Update the Exp information on the Player's Hud
void function Control_UpdatePlayerExpHUD( entity player, int newExpTotal )
{
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	// Update the on HUD display
	int expTier = Control_GetPlayerExpTier( player, false )
	float currentTierExp = float( Control_GetPlayerExpTotal( player, true, expTier ) )
	float expTierThreshold = float( Control_GetExpDifferenceBetweenLastTierAndTier( expTier + 1, player ) )
	bool isMaxTier = expTier >= CONTROL_MAX_EXP_TIER
	var rui = ClGameState_GetRui()


	if ( GetGameState() == eGameState.Playing && IsValid( rui ) )
	{
		Control_SetRatingsVisibility( player )
		RuiSetBool( rui, "isMaxTier", isMaxTier )
		RuiSetInt( rui, "expTierColor", Control_GetPlayerExpTier( player ) )
		RuiSetFloat( rui, "expTotal", currentTierExp )
		RuiSetFloat( rui, "expTierThreshold", expTierThreshold )

		if ( currentTierExp > 0 )
			RuiSetGameTime( rui, "expGainedTime", Time() )
	}

	// Update exp percent amounts for spawn selections
	Control_UpdatePlayerExpPercentAmountsForSpawns( player )
}
#endif // CLIENT

#if CLIENT
// Update the Exp Percentages info stored on the spawn screen ( used to show how much Exp the player will gain from spawning on different spawn points)
void function Control_UpdatePlayerExpPercentAmountsForSpawns( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalClientPlayer() )
		return

	// Update exp percent amounts for spawn selections
	float playerExpPercentFromLastLife = Control_GetEXPPercentToNextTier( player )
	int recoveredExpPercentToAward = Control_GetRoundedPercentAsInt( playerExpPercentFromLastLife, 100 )

	// By default we might not be awarding any exp for spawns
	int expPercentToAwardForPointSpawn = 0
	int expPercentToAwardForBaseSpawn = 0

	// We award the percent of exp the player had before they died when they spawn on the objective
	if ( Control_GetDefaultExpPercentToAwardForPointSpawn() < 0 )
		expPercentToAwardForPointSpawn = recoveredExpPercentToAward

	// We award the percent of exp the player had before they died when they spawn on their base
	if ( Control_GetDefaultExpPercentToAwardForBaseSpawn() < 0 )
		expPercentToAwardForBaseSpawn = recoveredExpPercentToAward

	// We award a specific percent of exp when the player spawns on the objective ( or the recovered exp percent from before they died if we allow that and the amount is greater than the set amount)
	if ( playerExpPercentFromLastLife > Control_GetDefaultExpPercentToAwardForPointSpawn() && Control_GetDefaultExpPercentToAwardForPointSpawn() > 0 && Control_ShouldUseRecoveredExpPercentIfGreaterThanDefaults() )
	{
		expPercentToAwardForPointSpawn = recoveredExpPercentToAward
	}
	else if ( Control_GetDefaultExpPercentToAwardForPointSpawn() > 0 )
	{
		expPercentToAwardForPointSpawn = Control_GetRoundedPercentAsInt( Control_GetDefaultExpPercentToAwardForPointSpawn(), 100 )
	}

	// We award a specific percent of exp when the player spawns on their base ( or the recovered exp percent from before they died if we allow that and the amount is greater than the set amount)
	if ( playerExpPercentFromLastLife > Control_GetDefaultExpPercentToAwardForBaseSpawn() && Control_GetDefaultExpPercentToAwardForBaseSpawn() > 0 && Control_ShouldUseRecoveredExpPercentIfGreaterThanDefaults() )
	{
		expPercentToAwardForBaseSpawn = recoveredExpPercentToAward
	}
	else if ( Control_GetDefaultExpPercentToAwardForBaseSpawn() > 0 )
	{
		expPercentToAwardForBaseSpawn = Control_GetRoundedPercentAsInt( Control_GetDefaultExpPercentToAwardForBaseSpawn(), 100 )
	}

	RunUIScript( "Control_UI_SpawnMenu_SetExpPercentAmountsForSpawns", expPercentToAwardForPointSpawn, expPercentToAwardForBaseSpawn, GamemodeUtility_IsJIPPlayerSpawnBonusPending( player ) )
}
#endif // CLIENT

#if CLIENT
// Play SFX anytime the player gains Exp
void function Control_PlayEXPGainSFX()
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	EmitUISound( CONTROL_SFX_EXP_GAIN )
}
#endif // CLIENT

#if CLIENT
string function Control_GetVictoryConditionForFlagset( int gameResultFlags )
{
	string victoryCondition
	switch( gameResultFlags )
	{
		case( CONTROL_VICTORY_FLAGS_SCORE ):
			victoryCondition = CONTROL_PIN_VICTORYCONDITION_SCORE
			break
		case( CONTROL_VICTORY_FLAGS_LOCKOUT ):
			victoryCondition = CONTROL_PIN_VICTORYCONDITION_LOCKOUT
			break
		case( CONTROL_VICTORY_FLAGS_FORFEIT ):
			victoryCondition = CONTROL_PIN_VICTORYCONDITION_FORFEIT
			break
		default:
			victoryCondition = CONTROL_PIN_VICTORYCONDITION_UNKNOWN
			break
	}

	return victoryCondition
}
#endif // CLIENT

#if CLIENT
void function Control_DeathScreenUpdate( var rui )
{
	SquadSummaryData squadData = GetSquadSummaryData()

	string titleString = squadData.squadPlacement == 1 ? "#SQUAD_PLACEMENT_GCARDS_TITLE" : "#SQUAD_HEADER_DEFEAT"
	string killsText   = "#CONTROL_DEATH_SCREEN_SUMMARY_KILLS_ALLIANCE"

	string victoryCondition = Control_GetVictoryConditionForFlagset( squadData.gameResultFlags )
	RuiSetString( rui, "victoryCondition", victoryCondition )
	RuiSetString( rui, "headerText", titleString ) // this may not actually be used. Or, rather, it's hidden behind the "big" one in death_screen_header
	RuiSetString( rui, "killsText", killsText )


	if ( victoryCondition == CONTROL_PIN_VICTORYCONDITION_SCORE || victoryCondition == CONTROL_PIN_VICTORYCONDITION_FORFEIT )
	{
		RuiSetInt( rui, "losingScore", squadData.gameScoreFlags )

		// Just to be safe, still grab the score limit for a score victory to avoid any issues with weird numbers showing up
		int winningScore = victoryCondition == CONTROL_PIN_VICTORYCONDITION_SCORE ?  GetScoreLimit_FromPlaylist() : GamemodeUtility_GetWinningTeamOrAllianceScore()
		RuiSetInt( rui, "winningScore", winningScore )
	}
}
#endif // CLIENT

#if CLIENT
void function Control_PopulateSummaryDataStrings( SquadSummaryPlayerData data )
{
	data.modeSpecificSummaryData[0].displayString = "#DEATH_SCREEN_SUMMARY_KILLS"
	data.modeSpecificSummaryData[1].displayString = "#DEATH_SCREEN_SUMMARY_ASSISTS"
	data.modeSpecificSummaryData[2].displayString = ""
	data.modeSpecificSummaryData[3].displayString = "#DEATH_SCREEN_SUMMARY_DAMAGE_DEALT"
	data.modeSpecificSummaryData[4].displayString = "#DEATH_SCREEN_SUMMARY_CONTROL_RATING"
	data.modeSpecificSummaryData[5].displayString = "#DEATH_SCREEN_SUMMARY_CONTROL_OBJECTIVES_CAPTURED"
	data.modeSpecificSummaryData[6].displayString = ""
}
#endif // CLIENT

#if CLIENT
// Update the Exp information on the Player's Hud to notify of a pending EXP weapon Evo or a completed one
void function ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo( bool isWeaponEvoPending, bool didGainNewExpTier )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	var rui = ClGameState_GetRui()
	if ( GetGameState() == eGameState.Playing && IsValid( rui ) )
	{
		// If we evolve weapons on weapon switch, display a hint and play sfx
		if ( Control_GetShouldEvoWeaponsOnWeaponSwitch() && isWeaponEvoPending )
		{
			player.Signal( "Control_StopWeaponEvoHints" ) // If we are already displaying evo hints, clear them out before triggering a new thread
			thread Control_ManagePendingWeaponEvoHints_Thread( player )
		}

		if ( didGainNewExpTier )
			RuiSetGameTime( rui, "expTierGainedTime", Time() )
	}
}
#endif // CLIENT

#if CLIENT
// Trigger a weapon Evo available notification and manage pending evo hints until the evo occurs or the player dies
const float EVO_PENDING_HINT_INTERVAL = 15.0
void function Control_ManagePendingWeaponEvoHints_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Control_StopWeaponEvoHints" )

	OnThreadEnd(
		function() : ()
		{
			ClWeaponStatus_OverrideReloadHintText( "" )
		}
	)

	bool isFirstHint = true
	while ( GetGameState() == eGameState.Playing )
	{
		string evoHint = "#CONTROL_HUD_EXP_EVO_PENDING"

		// Determine if we should display a reload hint instead of the default switch weapon hint
		if ( Control_IsActiveWeaponUnHolstered( player ) )
		{
			entity primaryWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			if ( primaryWeapon != null && IsValid( primaryWeapon ) && primaryWeapon.UsesClipsForAmmo() )
			{
				int clipCount = primaryWeapon.GetWeaponPrimaryClipCount()
				int clipCountMax = primaryWeapon.GetWeaponPrimaryClipCountMax()

				if ( clipCount < clipCountMax )
					evoHint = "#CONTROL_HUD_EXP_EVO_PENDING_RELOAD"
			}
		}

		// Display a hint letting players know they have Evo Pending.
		AddPlayerHint( CONTROL_MESSAGE_DURATION, 0.5, $"", evoHint )

		// We trigger a different SFX ( that has some delayed audio to avoid clashing with EXP gain audio ) and set a reload hint the first time we display a hint
		if ( isFirstHint )
		{
			ClWeaponStatus_OverrideReloadHintText( "#CONTROL_HUD_EXP_RELOAD_EVO_PENDING" )
			EmitUISound( CONTROL_SFX_WEAPON_EVO_FIRST_ALERT )
			isFirstHint = false
		}
		else
		{
			EmitUISound( CONTROL_SFX_WEAPON_EVO_ALERT )
		}

		wait EVO_PENDING_HINT_INTERVAL
	}
}
#endif // CLIENT

#if CLIENT
// Display an announcement when a new EXP Leader is named
void function ServerCallback_Control_NewEXPLeader( entity expLeader, int exp )
{
	EHI playerEHI = ToEHI( expLeader )

	// player doesn't exist, probably in a different realm
	if ( playerEHI == EHI_null )
		return

	if ( !IsValid( expLeader ) )
		return

	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	string playerName = GetDisplayablePlayerNameFromEHI( playerEHI )
	vector playerNameColor = expLeader.GetTeam() == localPlayer.GetTeam() ? GetPlayerInfoColor( expLeader ) : GetKeyColor( COLORID_ENEMY )

	Obituary_Print_Localized( Localize( "#CONTROL_NEW_EXPLEADER_OBIT", playerName, exp ), playerNameColor )

	if ( localPlayer == expLeader )
	{
		AnnouncementData announcement = Announcement_Create( "" )
		Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_RATING_LEADER )
		Announcement_SetPurge( announcement, true )
		Announcement_SetOptionalTextArgsArray( announcement, [Localize("#CONTROL_YOU_ARE_EXPLEADER"), Localize( "#CONTROL_EXPLEADER_EXP", exp, GetPlayerInfoColor( expLeader ) ), string( exp ) ] )
		Announcement_SetPriority( announcement, 200 )
		Announcement_SetSoundAlias( announcement, SOUND_NEW_KILL_LEADER )
		announcement.duration = CONTROL_MESSAGE_DURATION
		AnnouncementFromClass( localPlayer, announcement )
	}

	SquadLeader_UpdateAllUnitFramesRui()
}
#endif // CLIENT

#if CLIENT
// Display an announcement when the current EXP Leader has been killed
void function ServerCallback_Control_EXPLeaderKilled( entity attacker, entity expLeader )
{
	if ( !IsValid( attacker ) || !IsValid( expLeader ) )
		return

	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	EHI expLeaderEHI = ToEHI( expLeader )
	string expLeaderName = GetDisplayablePlayerNameFromEHI( expLeaderEHI )
	vector expLeaderNameColor = expLeader.GetTeam() == localPlayer.GetTeam() ? GetPlayerInfoColor( expLeader ) : <255, 255, 255>

	SquadLeader_UpdateAllUnitFramesRui()
	Obituary_Print_Localized( Localize( "#CONTROL_EXPLEADER_OBIT", expLeaderName ), expLeaderNameColor )
	if ( localPlayer == attacker && attacker != expLeader )
		AnnouncementMessageSweep( localPlayer, "#CONTROL_YOUKILLED_EXPLEADER", expLeaderName, expLeaderNameColor )
}
#endif // CLIENT

#if CLIENT
// Play sfx when the player enters or exits a Capture Zone
void function ServerCallback_Control_PlayCaptureZoneEnterExitSFX( bool isEnteringZone )
{
	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	if ( isEnteringZone )
	{
		EmitUISound( CONTROL_SFX_CAPTURE_ZONE_ENTER )
	}
	else
	{
		EmitUISound( CONTROL_SFX_CAPTURE_ZONE_EXIT )
	}
}
#endif // CLIENT

/*
   _____  _____ ____  _____  ______ ____   ____          _____  _____
  / ____|/ ____/ __ \|  __ \|  ____|  _ \ / __ \   /\   |  __ \|  __ \
 | (___ | |   | |  | | |__) | |__  | |_) | |  | | /  \  | |__) | |  | |
  \___ \| |   | |  | |  _  /|  __| |  _ <| |  | |/ /\ \ |  _  /| |  | |
  ____) | |___| |__| | | \ \| |____| |_) | |__| / ____ \| | \ \| |__| |
 |_____/ \_____\____/|_|  \_\______|____/ \____/_/    \_\_|  \_\_____/

	SCOREBOARD
*/

#if CLIENT
void function Control_ScoreboardSetup()
{
	clGlobal.showScoreboardFunc = Control_ShowScoreboardOrMap_Teams
	clGlobal.hideScoreboardFunc = Control_HideScoreboardOrMap_Teams

	Teams_AddCallback_ScoreboardData( Control_GetScoreboardData )
	Teams_AddCallback_PlayerScores( Control_GetPlayerScores )
	Teams_AddCallback_SortScoreboardPlayers( Control_SortPlayersByScore )
	Teams_AddCallback_Header( Control_ScoreboardUpdateHeader )
	Teams_AddCallback_GetTeamColor( Control_GetTeamColor )
	Teams_AddCallback_GetTeamName( Control_GetTeamName )
	Teams_AddCallback_GetTeamIcon( Control_GetTeamIcon )
}
#endif // CLIENT

#if CLIENT
void function Control_ShowScoreboardOrMap_Teams()
{
	entity player = GetLocalClientPlayer()
	entity localViewPlayer = GetLocalViewPlayer()
	HudInputContext inputContext

	// Only do these things if we are not on the Deathscreen, otherwise we got a lot of bad UI overlap and the potential to show the map screen over gameplay on Respawn
	if ( !IsViewingDeathScreen() )
	{
		if ( IsValid( player ) )
			thread Control_CameraInputManager_Thread( player )

		Scoreboard_SetVisible( true )
		UpdateFullmapRuiTracks()
		Fullmap_ClearInputContext()

		if ( IsValid( localViewPlayer ) )
			UpdateMainHudVisibility( localViewPlayer )

		Control_OnInGameMapShow()

		inputContext.keyInputCallback = Control_HandleKeyInput
		inputContext.moveInputCallback = Control_ShowScoreboardOrMapHandleMoveInput
		inputContext.viewInputCallback = Control_ShowScoreboardOrMapHandleViewInput
	}
	HudInput_PushContext( inputContext )
}
#endif // CLIENT

#if CLIENT
bool function Control_HandleKeyInput( int key )
{
	bool isSuccessful = false

	switch ( key )
	{
		case BUTTON_B:
			HideScoreboard()
			isSuccessful = true
			break
		case BUTTON_DPAD_UP:
		case KEY_F2:
			RunUIScript( "UI_OpenFeatureTutorialDialog", Cl_GetPlaylistUIRules() )
			isSuccessful = true
			break
		default:
			isSuccessful = !IsViewingDeathScreen() && Fullmap_HandleKeyInput( key ) // We don't want to show the map screen while on the death screen
			break
	}

	return isSuccessful
}
#endif // CLIENT

#if CLIENT
bool function Control_ShowScoreboardOrMapHandleMoveInput( float x, float y )
{
	return Fullmap_HandleMoveInput( x, y )

	unreachable
}
#endif // CLIENT

#if CLIENT
bool function Control_ShowScoreboardOrMapHandleViewInput( float x, float y )
{
	return Fullmap_HandleViewInput( x, y )

	unreachable
}
#endif // CLIENT

#if CLIENT
void function Control_HideScoreboardOrMap_Teams()
{
	entity player = GetLocalClientPlayer()

	HudInput_PopContext()
	Scoreboard_SetVisible( false )

	HideFullmap()
	Control_OnInGameMapHide()

	if ( IsValid( player ) )
		player.Signal( "Control_PlayerHideScoreboardMap" )
}
#endif // CLIENT

#if CLIENT
void function Control_OnInGameMapShow()
{
	if ( IsValid( file.inGameMapRui ) )
		return

	var rui = CreateTransientFullscreenRui( $"ui/control_teams_map.rpak", 0)
	RuiSetBool( rui, "showBottomBar", true )

	string playlist = GetCurrentPlaylistName()
	string playlistUiRules = GetPlaylistVarString( playlist, "ui_rules", "" )
	RuiSetBool( rui, "rulesEnabled", playlistUiRules != "" )

	Control_RefreshInGameMap_SpawnIcons( rui )
	file.inGameMapRui = rui

	thread Thread_Control_InGameMapData()
}
#endif // CLIENT

#if CLIENT
const string NESTED_SPAWN_BUTTON_RUI_PREFIX = "spawn"
void function Control_RefreshInGameMap_SpawnIcons( var rui )
{
	if ( !IsValid( rui ) )
		return

	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	// In Case this is being run when old Rui's exist, clear them out before creating new ones
	foreach ( index in file.inGameMapPointNestedRuiIndexes )
	{
		RuiDestroyNested( rui, NESTED_SPAWN_BUTTON_RUI_PREFIX + index )
	}
	file.inGameMapPointsToRuis.clear()
	file.inGameMapPointNestedRuiIndexes.clear()

	foreach( int idx, wp in file.spawnWaypoints )
	{
		if ( !IsValid( wp ) )
			continue

		int waypointTypeIndex = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
		var nestedRui = RuiCreateNested( rui, NESTED_SPAWN_BUTTON_RUI_PREFIX + idx, $"ui/control_spawn_button.rpak"  )
		file.inGameMapPointsToRuis[ wp ] <- nestedRui
		file.inGameMapPointNestedRuiIndexes.append( idx )

		// Objective Waypoint logic
		if ( Control_IsSpawnWaypointIndexAnObjective( waypointTypeIndex ) )
		{
			entity objective = wp.GetParent()

			if ( IsValid( objective ) )
			{
				RuiTrackFloat( nestedRui, "capturePercentage", objective, RUI_TRACK_WAYPOINT_FLOAT, FLOAT_CAP_PERC )
				RuiTrackInt( nestedRui, "currentControllingTeam", objective, RUI_TRACK_WAYPOINT_INT, INT_CAPTURING_ALLIANCE )
				RuiTrackInt( nestedRui, "currentOwner", objective, RUI_TRACK_WAYPOINT_INT, CONTROL_INT_OBJ_ALLIANCE_OWNER)
				RuiTrackInt( nestedRui, "neutralPointOwnership", objective, RUI_TRACK_WAYPOINT_INT, CONTROL_INT_OBJ_NEUTRAL_ALLIANCE_OWNER )
				RuiTrackInt( nestedRui, "team0PlayersOnObj", objective, RUI_TRACK_WAYPOINT_INT, INT_ALLIANCE_A_PLAYERSONOBJ )
				RuiTrackInt( nestedRui, "team1PlayersOnObj", objective, RUI_TRACK_WAYPOINT_INT, INT_ALLIANCE_B_PLAYERSONOBJ )
			}
		}

		// MRB spawn point logic
		if ( waypointTypeIndex == eControlWaypointTypeIndex.MRB_SPAWN && IsValid( localPlayer ) )
		{
			if ( AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() ) == wp.GetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX ) )
				RuiSetImage( nestedRui, "centerImage", RESPAWN_BEACON_ICON_SMALL )
			else
				RuiSetBool( nestedRui, "isVisible", false )
		}
	}
}
#endif // CLIENT

#if CLIENT
void function Thread_Control_InGameMapData()
{
	entity localPlayer = GetLocalViewPlayer()
	while ( file.inGameMapRui != null && IsValid( localPlayer ) )
	{
		localPlayer = GetLocalViewPlayer()

		// Test to see if the current list we are updating has the same number of elements as the list of icons we have setup.
		// If not, update the elements to make sure everything is in sync
		if ( file.inGameMapPointNestedRuiIndexes.len() != Control_GetValidSpawnWaypointCount() )
			Control_RefreshInGameMap_SpawnIcons( file.inGameMapRui )

		foreach ( int idx, wp in file.spawnWaypoints )
		{
			if ( wp in file.inGameMapPointsToRuis )
			{
				var nestedRui = file.inGameMapPointsToRuis[ wp ]
				int waypointTypeIndex = wp.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )

				float[2] screenPos = GetScreenSpace( wp.GetOrigin() )

				UISize screenSize = GetScreenSize()

				screenPos[0] =  screenPos[0] / screenSize.width
				screenPos[1] =  screenPos[1] / screenSize.height

				int playerTeam = localPlayer.GetTeam()
				int playerAlliance = AllianceProximity_GetAllianceFromTeam( playerTeam )
				string nameInformation = ""
				asset waypointImage = $""
				bool shouldShowObjective = true

				switch( waypointTypeIndex )
				{
					case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
						// Set Common Variables
						nameInformation = ""
						waypointImage = CONTROL_WAYPOINT_BASE_ICON
						shouldShowObjective = false
						// Set homebase variable only if this is the local players Homebase
						if ( playerAlliance == ALLIANCE_A )
							RuiSetFloat2( file.inGameMapRui, "baseSpawnScreenspace", < screenPos[0], screenPos[1], 0.0 >  )
						break
					case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
						// Set Common Variables
						nameInformation = ""
						waypointImage = CONTROL_WAYPOINT_BASE_ICON
						shouldShowObjective = false
						// Set homebase variable only if this is the local players Homebase
						if ( playerAlliance == ALLIANCE_B )
							RuiSetFloat2( file.inGameMapRui, "baseSpawnScreenspace", < screenPos[0], screenPos[1], 0.0 >  )
						break
					case eControlWaypointTypeIndex.OBJECTIVE_A:
					case eControlWaypointTypeIndex.OBJECTIVE_B:
					case eControlWaypointTypeIndex.OBJECTIVE_C:
						// Set Common Variables
						nameInformation = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( waypointTypeIndex )
						shouldShowObjective = true
						// Set Objective only settings
						int waypointOwner = ALLIANCE_NONE
						entity waypointParentEnt = wp.GetParent()
						RuiSetBool( GetFullmapGamestateRui(), "isOnObjective" + waypointTypeIndex,  Control_Client_IsOnObjective( waypointParentEnt, localPlayer ) )
						if ( IsValid( waypointParentEnt ) )
						{
							waypointOwner = waypointParentEnt.GetWaypointInt( CONTROL_INT_OBJ_ALLIANCE_OWNER)

							if ( waypointParentEnt.GetWaypointFloat( FLOAT_BOUNTY_AMOUNT ) > 0 )
								RuiSetBool( nestedRui,"hasEmphasis", true )
							else
								RuiSetBool( nestedRui,"hasEmphasis", false )
						}
						else
						{
							RuiSetBool( nestedRui,"hasEmphasis", false )
						}

						if ( waypointTypeIndex == eControlWaypointTypeIndex.OBJECTIVE_B ) // Objective B only logic
						{
							RuiSetFloat2( file.inGameMapRui, "centralSpawnScreenspace", < screenPos[0], screenPos[1], 0.0 > )
							RuiSetBool( file.inGameMapRui, "canSpawnOnCentral", Control_CanAllianceMemberSpawnOnObjectiveB( playerAlliance ) )
							RuiSetBool( file.inGameMapRui, "isSpawnOnCentralDisabled", !Control_IsSpawningOnObjectiveBAllowed() )
						}
						else // Objective A or C only logic
						{
							bool isFOBForLocalPlayer = ( waypointTypeIndex == eControlWaypointTypeIndex.OBJECTIVE_A && playerAlliance == ALLIANCE_A) || ( waypointTypeIndex == eControlWaypointTypeIndex.OBJECTIVE_C && playerAlliance == ALLIANCE_B )
							if ( isFOBForLocalPlayer )
							{
								bool isYourWaypoint = waypointOwner == playerAlliance && playerTeam != TEAM_SPECTATOR
								RuiSetFloat2( file.inGameMapRui, "fobSpawnScreenspace", < screenPos[0], screenPos[1], 0.0 > )
								RuiSetBool( file.inGameMapRui, "canSpawnOnFOB", isYourWaypoint )
							}
						}
						break
					case eControlWaypointTypeIndex.MRB_SPAWN:
						// Set Common Variables
						nameInformation = Localize( "#CONTROL_MRB_SPAWN_NAME" )
						waypointImage = RESPAWN_BEACON_ICON
						shouldShowObjective = false
						// Set MRB Only Variables
						int waypointOwner = wp.GetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX )
						bool shouldShowMRBIcon = waypointOwner == playerAlliance || playerTeam == TEAM_SPECTATOR
						RuiSetBool( nestedRui, "isVisible", shouldShowMRBIcon )
						float endTime = wp.GetWaypointFloat( CONTROL_MRB_SPAWN_WAYPOINT_ENDTIME )
						RuiSetGameTime( nestedRui, "timerEndTime", endTime )
						RuiSetBool( nestedRui, "shouldShowTimer", shouldShowMRBIcon )
						RuiSetBool( nestedRui, "shouldDisplayMRBIconBacking", shouldShowMRBIcon )
						break
					case eControlWaypointTypeIndex.SQUAD_SPAWN:
						// Set Common Variables
						entity waypointParentEnt = wp.GetParent()
						if ( IsValid( waypointParentEnt ) && waypointParentEnt.IsPlayer() )
							nameInformation = waypointParentEnt.GetPlayerName()
						break
					default:
						// Set Common Variables
						nameInformation = ""
						waypointImage = $""
						shouldShowObjective = false
						break
				}

				// Common settings for all spawn waypoints
				RuiSetString( nestedRui, "objectiveName", nameInformation )
				RuiSetImage( nestedRui, "centerImage", waypointImage )
				RuiSetFloat2( file.inGameMapRui, "posSpawn" + idx, < screenPos[0], screenPos[1], 0.0 > )
				RuiSetInt( nestedRui, "yourTeamIndex", playerAlliance )
				RuiSetBool( nestedRui, "isDisabled", true )
				RuiSetBool( nestedRui, "shouldShowObjective", shouldShowObjective )
			}
		}
		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT

void function Control_ToggleMapRui( bool isVisible )
{
	if ( IsValid( file.inGameMapRui ) )
	{
		RuiSetVisible( file.inGameMapRui, isVisible )
	}

	Fullmap_ToggleChallengeRuis( isVisible )
}

void function Control_OnInGameMapHide()
{
	Fullmap_SetVisible_MapOnly( false )

	if ( IsValid( file.inGameMapRui ) )
	{
		file.inGameMapPointsToRuis.clear()
		file.inGameMapPointNestedRuiIndexes.clear()
		RuiDestroy( file.inGameMapRui )
		file.inGameMapRui = null
	}

	// Large camera jump. ambient_generics should immediately refresh and begin playing their sounds again
	// (otherwise all ambient_generics will be silent for a handful of seconds)
	//RefreshSoundSystem();
}
#endif // CLIENT

#if CLIENT
ScoreboardData function Control_GetScoreboardData()
{
	ScoreboardData data

	if ( Control_GetIsWeaponEvoEnabled() )
	{
		data.columnDisplayIcons.append( $"rui/hud/gametype_icons/control/control_ratings" )
		data.columnNumDigits.append( 5 )
		data.columnDisplayIconsScale.append( 1.0 )
	}

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_kills_icon" )
	data.columnNumDigits.append( 3 )
	data.columnDisplayIconsScale.append( 1.0 )

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_damage_dealt_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 4 )

	data.numScoreColumns = data.columnDisplayIcons.len()

	return data
}
#endif // CLIENT

#if CLIENT
array< string > function Control_GetPlayerScores( entity player )
{
	array< string > scores

	if ( Control_GetIsWeaponEvoEnabled() )
	{
		string points = string( player.GetPlayerNetInt( "control_PersonalScore" ) )
		scores.append( points )
	}

	string kills = string( player.GetPlayerNetInt( "kills" ) )
	scores.append( kills )

	string damage = string( player.GetPlayerNetInt( "damageDealt" ) )
	scores.append( damage )

	return scores
}
#endif // CLIENT

#if CLIENT
array< TeamsScoreboardPlayer > function Control_SortPlayersByScore( array< TeamsScoreboardPlayer > players )
{
	players.sort( int function( TeamsScoreboardPlayer a, TeamsScoreboardPlayer b )
		{
			entity playerA = FromEHI( a.playerEHI )
			entity playerB = FromEHI( b.playerEHI )

			if( !IsValid( playerA ) || !IsValid( playerB ) )
				return 0

			array< string > aScores = Control_GetPlayerScores( playerA )
			array< string > bScores = Control_GetPlayerScores( playerB )

			if ( int (aScores[0] ) > int( bScores[0] ) ) return -1
			else if ( int( aScores[0] ) < int( bScores[0] ) ) return 1

			int aKills = playerA.GetPlayerNetInt( "kills" )
			int bKills = playerB.GetPlayerNetInt( "kills" )

			if ( aKills > bKills ) return -1
			else if ( aKills < bKills ) return 1

			int aDamage = playerA.GetPlayerNetInt( "damageDealt" )
			int bDamage = playerB.GetPlayerNetInt( "damageDealt" )

			if ( aDamage > bDamage ) return -1
			else if ( aDamage < bDamage ) return 1

			return 0
		}
	)

	return players
}
#endif // CLIENT

#if CLIENT
void function Control_ScoreboardUpdateHeader( var headerRui, var frameRui,  int team )
{
	bool isFriendly = team == AllianceProximity_GetAllianceFromTeam( GetLocalViewPlayer().GetTeam() )

	if ( Control_IsPlayerPrivateMatchObserver( GetLocalClientPlayer() ) )
	{
		isFriendly = team == ALLIANCE_A
	}
	else if ( headerRui != null )
	{
		string nameOverride = Control_GetTeamName( team )
		if( nameOverride == "" )
			RuiSetString( headerRui, "headerText", Localize( isFriendly ? "#ALLIES" : "#ENEMIES" ) )
		else
			RuiSetString( headerRui, "headerText", Localize( nameOverride ) )

	}

	int winningTeam = -1
	if( ( GetAllianceTeamsScore( ALLIANCE_A ) + GetAllianceTeamsScore( ALLIANCE_B ) ) > 0 )
		winningTeam = GamemodeUtility_GetWinningAlliance( true )

	RuiSetBool( headerRui, "isWinning", ( winningTeam == team ) )

	if( team >= 0 )
	{
		ControlTeamData data = file.teamData[ team ]
		if( headerRui != null )
		{
			RuiSetInt( headerRui, "teamScoreFromPoints", data.teamScoreFromPoints )
			RuiSetInt( headerRui, "teamScoreFromBonus", data.teamScoreFromBonus )
			RuiSetInt( headerRui, "teamScorePerSec", data.teamScorePerSec )
		}
	}
}
#endif // CLIENT

#if CLIENT
vector function Control_GetTeamColor( int team )
{
	bool isFriendly = team == AllianceProximity_GetAllianceFromTeam( GetLocalViewPlayer().GetTeam() )


		/*if ( IsRevTakeover() )
		{
			if( team != SHADOWARMY_REVENANT_ALLIANCE )
			{
				return SrgbToLinear( GetKeyColor( COLORID_ALLIANCE_0 ) / 255.0 )
			}
			else
			{
				return SrgbToLinear( GetKeyColor( COLORID_ALLIANCE_1 ) / 255.0 )
			}
		}*/

	if ( Control_IsPlayerPrivateMatchObserver( GetLocalClientPlayer() ) )
		isFriendly = team == ALLIANCE_A

	vector color  = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED, true )
	if ( !isFriendly )
		color  = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED, true )

	return color
}
#endif // CLIENT

#if CLIENT
string function Control_GetTeamName( int team )
{
	string teamName = Survival_GetTeamName( team )

	return teamName
}
#endif // CLIENT

#if CLIENT
asset function Control_GetTeamIcon( int team )
{
	asset teamIcon = Survival_GetTeamIcon( team )

	return teamIcon
}
#endif //client

#if CLIENT
// Update the scoreboard on the client with extra info about where points are coming from
void function ServerCallback_Control_UpdateExtraScoreBoardInfo( int alliance, int scoreFromPoints, int scoreFromBonuses )
{
	if ( !IsValid( GetLocalViewPlayer() ) )
		return

	ControlTeamData data
	data.teamScoreFromPoints = scoreFromPoints
	data.teamScoreFromBonus = scoreFromBonuses
	data.teamScorePerSec = file.teamData[alliance].teamScorePerSec

	file.teamData[alliance] = data
}
#endif // CLIENT

#if CLIENT
bool function Control_IsLocalClientInMapCameraView()
{
	return file.isPlayerInMapCameraView
}
#endif // CLIENT

#if SERVER
// Use server data to update client scoreboards with extra info about where points are coming from
void function Control_UpdateScoreBoardInfo()
{
	foreach ( player in GetPlayerArrayIncludingSpectators() )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_Control_UpdateExtraScoreBoardInfo", ALLIANCE_A, GetAllianceTeamsScore( ALLIANCE_A ) - file.team0ScoreFromBonus, file.team0ScoreFromBonus )
		Remote_CallFunction_Replay( player, "ServerCallback_Control_UpdateExtraScoreBoardInfo", ALLIANCE_B, GetAllianceTeamsScore( ALLIANCE_B ) - file.team1ScoreFromBonus, file.team1ScoreFromBonus )
	}
}
#endif // SERVER

/*
		  _      ____          _____   ____  _    _ _______ _____
		 | |    / __ \   /\   |  __ \ / __ \| |  | |__   __/ ____|
		 | |   | |  | | /  \  | |  | | |  | | |  | |  | | | (___
		 | |   | |  | |/ /\ \ | |  | | |  | | |  | |  | |  \___ \
		 | |___| |__| / ____ \| |__| | |__| | |__| |  | |  ____) |
		 |______\____/_/    \_\_____/ \____/ \____/   |_| |_____/

		 LOADOUTS
*/


#if SERVER
// Loadout info has been updated for Clients, update the spawn select screen loadout text and images
void function Control_OnLoadoutUpdated( entity player )
{
	Remote_CallFunction_UI( player, "ControlSpawnMenu_UpdatePlayerLoadout" )
}
#endif // SERVER

#if SERVER
// The loadout select menu has been closed
void function Control_OnLoadoutSelectMenuClosed( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	// If the player had selected a spawn point before opening the loadout select menu, make sure they see the spawn wave timer when they return to the spawn screen
	if ( player in file.playerToRespawnChoice )
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DisplayWaveSpawnBarStatusMessage", true, file.playerToRespawnChoice[ player ] )
}
#endif // SERVER

#if SERVER
const float TIME_TO_WAIT_FOR_WEAPON_EVO = 0.75
void function Control_ResetPlayerInventoryAndLoadout_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	ResetPlayerInventory( player )

	if ( Control_GetIsAmmoInfinite() )
		SetInfiniteAmmoForGameMode( player, true, ["crate"] )
	if ( Control_GetIsFastHeal() )
		GivePassive( player, ePassives.PAS_FAST_HEAL )

	GivePassive( player, ePassives.PAS_GUARDIAN_ANGEL )
	if ( GetCurrentPlaylistVarBool( "infinite_heal_items", false ) )
		GivePassive( player, ePassives.PAS_INFINITE_HEAL )


		if ( IsRevTakeover() && ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_B ) )
		{
			if ( GetCurrentPlaylistVarBool( "enableRevTeamMods", true ) )
				GivePlayerSettingsMods( player, [ "enable_wallrun" ] )
		}


	WaitFrame()

	// Check if the player is respawning on a dropship, in which case, we want to delay giving weapons until they have finished the animated first person sequence
	if ( IsValid( player.p.respawnPod ) && player.p.respawnPod in file.dropshipToPlayersOnDropshipTable )
	{
		if ( file.dropshipToPlayersOnDropshipTable[ player.p.respawnPod ].contains( player ) )
			player.WaitSignal( "PlayerRedeployingFromDropship" )
	}

	// Encountered an issue using debug spawning where the player didn't have valid default settings. In case the player somehow respawns without spawning, make sure they have default settings here
	int lootTier = maxint( Control_GetDefaultWeaponTier(), Control_GetPlayerExpTier( player, false ) )
	player.SetPlayerNetInt( "control_CurrentExpTier", lootTier )
	int currentExp = maxint( Control_GetExpThresholdForTier( lootTier, player ), Control_GetPlayerExpTotal( player ) )
	player.SetPlayerNetInt( "control_CurrentExpTotal", currentExp )

	// Figure out the percent of EXP to next tier to give to the player when they respawn ( don't award the EXP yet until we determine if the player is using reduced EXP tiers for this next life)
	float expPercentToAwardOnRespawn = 0.0
	float expPercentPlayerHadOnDeath = Control_GetEXPPercentToNextTier( player )
	bool isSpawningOnBase = true
	bool isLateJoinPlayerFirstSpawn = GamemodeUtility_IsJIPPlayerSpawnBonusPending( player )

	if ( isLateJoinPlayerFirstSpawn ) // This is the players first spawn as a Late Join Player, give them a full EXP Tier
	{
		expPercentToAwardOnRespawn = 1.0
	}
	else if ( player in file.playerToLastRespawnChoice && Control_IsSpawnWaypointIndexAHomebase( file.playerToLastRespawnChoice[ player ] ) ) // Player is spawning on base
	{
		// We award the percent of exp the player had before they died
		if ( Control_GetDefaultExpPercentToAwardForBaseSpawn() < 0 )
			expPercentToAwardOnRespawn = expPercentPlayerHadOnDeath

		// We award a specific percent of exp when the player spawns on their base ( or the recovered exp percent from before they died if we allow that and the amount is greater than the set amount)
		if ( expPercentPlayerHadOnDeath > Control_GetDefaultExpPercentToAwardForBaseSpawn() && Control_GetDefaultExpPercentToAwardForBaseSpawn() > 0 && Control_ShouldUseRecoveredExpPercentIfGreaterThanDefaults() )
		{
			expPercentToAwardOnRespawn = expPercentPlayerHadOnDeath
		}
		else if ( Control_GetDefaultExpPercentToAwardForBaseSpawn() > 0 )
		{
			expPercentToAwardOnRespawn = Control_GetDefaultExpPercentToAwardForBaseSpawn()
		}

		delete file.playerToLastRespawnChoice[ player ]
	}
	else // Player is not spawning on base
	{
		isSpawningOnBase = false
		// We award the percent of exp the player had before they died
		if ( Control_GetDefaultExpPercentToAwardForPointSpawn() < 0 )
			expPercentToAwardOnRespawn = expPercentPlayerHadOnDeath

		// We award a specific percent of exp when the player spawns on an objective ( or the recovered exp percent from before they died if we allow that and the amount is greater than the set amount)
		if ( expPercentPlayerHadOnDeath > Control_GetDefaultExpPercentToAwardForPointSpawn() && Control_GetDefaultExpPercentToAwardForPointSpawn() > 0 && Control_ShouldUseRecoveredExpPercentIfGreaterThanDefaults() )
		{
			expPercentToAwardOnRespawn = expPercentPlayerHadOnDeath
		}
		else if ( Control_GetDefaultExpPercentToAwardForPointSpawn() > 0 )
		{
			expPercentToAwardOnRespawn = Control_GetDefaultExpPercentToAwardForPointSpawn()
		}
	}

	// Set the player to default tier before we award exp based on where the player spawns
	lootTier = Control_GetDefaultWeaponTier()
	player.SetPlayerNetInt( "control_CurrentExpTier", lootTier )
	player.SetPlayerNetInt( "control_CurrentExpTotal", Control_GetExpThresholdForTier( lootTier, player ) )

	// Determine if the player should be getting decreased Exp Tier costs due to being on the losing team
	bool shouldPlayerUseLosingTeamExpTiers = false
	int playerTeam = player.GetTeam()

	if ( playerTeam != ALLIANCE_NONE )
	{
		int playerAlliance = AllianceProximity_GetAllianceFromTeam( playerTeam )
		shouldPlayerUseLosingTeamExpTiers = playerAlliance == Control_GetAllianceUsingCatchupMechanics()
	}

	if ( shouldPlayerUseLosingTeamExpTiers && !file.playersUsingLosingTeamExpTiersArray.contains( player ) )
	{
		file.playersUsingLosingTeamExpTiersArray.append( player )
	}
	else if ( !shouldPlayerUseLosingTeamExpTiers && file.playersUsingLosingTeamExpTiersArray.contains( player ) )
	{
		file.playersUsingLosingTeamExpTiersArray.fastremovebyvalue( player )
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_SetIsPlayerUsingLosingExpTiers", shouldPlayerUseLosingTeamExpTiers )

	// Use the stored player data to give players back their inventory on respawn
	if ( IsUsingLoadoutSelectionSystem() )
	{
		LoadoutSelection_GivePlayerInventoryAndLoadout( player )
	}
	else
	{
		// Give Equipment
		array<string> defaultEquipment = ParseEquipmentLoadoutText( Control_GetEquipmentLoadoutString(), false, [] )
		CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, defaultEquipment )

		// Give Weapons
		WeaponLoadout defaultWeapons = ParseWeaponLoadoutText( Control_GetWeaponLoadoutString(), false )
		CharacterLoadouts_GiveWeaponLoadoutToPlayer( player, defaultWeapons, "", false )

		// Give Consumables
		array<string> defaultConsumables = ParseConsumableLoadoutText( Control_GetConsumableLoadoutString(), false )
		CharacterLoadouts_GiveConsumableLoadoutToPlayer( player, defaultConsumables )
	}

	// If this is a Late Join Players first spawn give them better equipment
	if ( isLateJoinPlayerFirstSpawn )
	{
		array<string> lateJoinEquipment = ParseEquipmentLoadoutText( CONTROL_LATEJOIN_EQUIPMENT_LOADOUT, false, [] )
		CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, lateJoinEquipment )
		GamemodeUtility_SetJIPPlayerIsWaitingForSpawnBonus( player, false )
	}

	// Need to wait so the player is given weapons before we can Evo them
	wait TIME_TO_WAIT_FOR_WEAPON_EVO

	// Award the player the exp percent they had on death or the percentage awarded for spawning on different zones if that value is bigger
	int expToAward = Control_GetRoundedPercentAsInt( expPercentToAwardOnRespawn, Control_GetExpToNextExpTier( player ) )

	if ( expToAward > 0 )
	{
		if ( isSpawningOnBase )
		{
			Control_AddScore( player, CONTROL_EXPEVENT_SPAWNONBASE, expToAward, true, false )
		}
		else
		{
			Control_AddScore( player, CONTROL_EXPEVENT_RESPAWN, expToAward, true, false )
		}
	}

	// Update the Client HUD
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo", Control_IsPlayerWaitingForWeaponEvo( player ), false )

	// Track the player position for the map and test to see if they are in combat
	thread Control_TrackPlayer_Thread( player )
}
#endif // SERVER

#if SERVER || CLIENT
// Used for awarding Exp and Ult Charge, we want the value rounded and when the percent is really low we want to make sure it displays 1 instead of 0
int function Control_GetRoundedPercentAsInt( float percentFrac, int percentageMultiplier )
{
	int expToAward = int( Round( percentageMultiplier * percentFrac, 1 ) )
	expToAward = percentFrac > 0 && expToAward < 1 ? 1 : expToAward
	return expToAward
}
#endif // SERVER || CLIENT

#if CLIENT
// Set whether this players Exp tier thresholds should be lower (on the Client, already set on Server) because their team is losing by a set threshold
void function ServerCallback_Control_SetIsPlayerUsingLosingExpTiers( bool shouldUseLosingTeamTiers )
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	if ( shouldUseLosingTeamTiers && !file.playersUsingLosingTeamExpTiersArray.contains( player ) )
	{
		file.playersUsingLosingTeamExpTiersArray.append( player )
	}
	else if ( !shouldUseLosingTeamTiers && file.playersUsingLosingTeamExpTiersArray.contains( player ) )
	{
		file.playersUsingLosingTeamExpTiersArray.fastremovebyvalue( player )
	}
}
#endif // CLIENT

#if CLIENT
void function UICallback_Control_Loadouts_OnClosed()
{
	entity player = GetLocalClientPlayer()

	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		return

	CreateRespawnBlur()
	thread Control_TriggerShowSpawnMenuOnUI_Thread( player, true )

	//First time player has playedc control, show them the tutorial to help them. Yay onboarding!
	if( IsValid( player ) && !file.tutorialShown && GetStat_Int( player, ResolveStatEntry( CAREER_STATS.modes_games_played, GAMEMODE_CONTROL ), eStatGetWhen.CURRENT ) == 0 )
		RunUIScript( "UI_OpenFeatureTutorialDialog", Cl_GetPlaylistUIRules() )

	file.tutorialShown = true

	if ( ClGameState_GetRui() != null )
		RuiSetBool( ClGameState_GetRui(), "isInSpawnMenu", true )
}
#endif // CLIENT


/*
		  _      ____   ____ _______
		 | |    / __ \ / __ \__   __|
		 | |   | |  | | |  | | | |
		 | |   | |  | | |  | | | |
		 | |___| |__| | |__| | | |
		 |______\____/ \____/  |_|

		 LOOT
*/

#if SERVER
// Add dropped items to an array so they can be cleaned up
void function Control_OnItemDropped( entity dropEnt )
{
	if ( !IsValid( dropEnt ) )
		return

	// If we are in the MRB Timed Event, manage who is holding the MRB
	if ( Control_MRBTimedEvent_IsEventActive() )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( dropEnt.GetSurvivalInt() )
		if ( SURVIVAL_Loot_IsRefValid( data.ref ) && data.ref == MRB_WEAPON_REF_NAME )
		{
			Control_MRBTimedEvent_OnMRBDropped( file.activeMRBOwner, dropEnt )
			return // We don't want to run cleanup logic on the MRB
		}
	}

	if ( !file.droppedItems.contains( dropEnt ) )
		file.droppedItems.append( dropEnt )
}
#endif // SERVER

#if SERVER
// While the match is in progress, wait for a specified ammount of time then trigger all dropped loot to despawn
const float CONTROL_EMPTY_WEAPON_LIFETIME = 1.0
const float CONTROL_REGULAR_LOOT_LIFETIME = 30.0
const float CONTROL_HIGH_TIER_LOOT_LIFETIME = 60.0
const float CONTROL_LOOT_CLEANUP_SCAN_PERIOD = 5.0
void function DroppedLootCleanUp_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	while( GetGameState() < eGameState.Epilogue )
	{
		PerformDroppedLootCleanUp()
		wait CONTROL_LOOT_CLEANUP_SCAN_PERIOD
	}
}
#endif // SERVER

#if SERVER
// Cleanup all ground loot that has been laying around for too long
void function PerformDroppedLootCleanUp()
{
	array<entity> loot = clone file.droppedItems

	foreach ( item in loot )
	{
		if ( IsValid( item ) )
		{
			float lootLifeTime = CONTROL_REGULAR_LOOT_LIFETIME
			LootData data = SURVIVAL_Loot_GetLootDataByIndex( item.GetSurvivalInt() )

			// Based on the type of loot we sometimes clean it up slower or faster
			if ( SURVIVAL_Loot_IsRefValid( data.ref ) )
			{
				if ( data.lootType == eLootType.ORDNANCE || data.lootType == eLootType.GADGET ) // We want Ordnance and survival slot items to stick around for longer since this is one of the main ways to replenish Ordnance
				{
					lootLifeTime = CONTROL_HIGH_TIER_LOOT_LIFETIME
				}
				else if ( data.lootType == eLootType.MAINWEAPON ) // Weapons have special lifetime rules
				{
					if ( data.tier == eLootTier.MYTHIC && Control_GetAmmoCountForWeaponProp( item ) <= 0 ) // Empty Crate weapons get cleaned up super fast
					{
						lootLifeTime = CONTROL_EMPTY_WEAPON_LIFETIME
					}
					else if ( data.tier > Control_GetDefaultWeaponTier() ) // Weapons that are higher tier than default stick around for longer
					{
						lootLifeTime = CONTROL_HIGH_TIER_LOOT_LIFETIME
					}
				}
				else if ( ( data.lootType == eLootType.ARMOR || data.lootType == eLootType.HELMET ) && data.tier > Control_GetDefaultEquipmentTier() ) // Equipment that is higher tier than normal sticks around for longer
				{
					lootLifeTime = CONTROL_HIGH_TIER_LOOT_LIFETIME
				}
			}

			// If an item has been in the world for the set loot life time destroy it
			if ( item.e.spawnTime + lootLifeTime < Time() )
			{
				file.droppedItems.fastremovebyvalue( item )
				item.Destroy()
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Get the ammo count for the weapon
// NOTE: NEED to make sure the entity you are passing is a weapon prop ( dropped weapon ) entity type:CPropSurvival instead of CWeaponX before running this function
int function Control_GetAmmoCountForWeaponProp( entity weaponProp)
{
	int ammoCount = 0

	if ( !IsValid( weaponProp ) )
	{
		Warning( "CONTROL: Control_GetAmmoCountForWeaponProp was run on an Invalid Entity, returning ", ammoCount )
		return ammoCount
	}

	// Grab special ammo count, if it returns -1 weapon doesn't use special ammo
	int specialAmmoCount = Survival_Loot_GetSpecialAmmoCountForWeaponProp( weaponProp )

	// If the weapon uses special ammo return that as the count, otherwise use GetClipCount
	if ( specialAmmoCount >= 0 )
		ammoCount = specialAmmoCount
	else
		ammoCount = weaponProp.GetClipCount()


	return ammoCount
}
#endif // SERVER

/*
	  ________   _______    _      ____   _____ _____ _____
	 |  ____\ \ / /  __ \  | |    / __ \ / ____|_   _/ ____|
	 | |__   \ V /| |__) | | |   | |  | | |  __  | || |
	 |  __|   > < |  ___/  | |   | |  | | | |_ | | || |
	 | |____ / . \| |      | |___| |__| | |__| |_| || |____
	 |______/_/ \_\_|      |______\____/ \_____|_____\_____|

	 EXP LOGIC ( RATINGS )
*/


#if CLIENT || SERVER
// Get the Current total of Exp points the player has
int function Control_GetPlayerExpTotal( entity player, bool shouldRemoveInitialTierBoostEXP = false, int boostTier = -1 )
{
	int expTotal = 0
	if ( IsValid( player ) )
		expTotal = player.GetPlayerNetInt( "control_CurrentExpTotal" )

	// When players start at a higher tier than 1, they are automatically awarded exp up to that tier threshold when they spawn.
	// Here we get rid of that boost to get the real amount of EXP the player has collected themselves
	if ( shouldRemoveInitialTierBoostEXP )
	{
		if ( boostTier == -1 )
			boostTier = Control_GetDefaultWeaponTier()

		int boostEXP = Control_GetExpThresholdForTier( boostTier, player )
		expTotal = maxint( ( expTotal - boostEXP ), 0 )
	}

	return expTotal
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the players current Exp Tier
int function Control_GetPlayerExpTier( entity player, bool useClampedValue = true )
{
	int expTier = Control_GetDefaultWeaponTier()

	if ( IsValid( player ) && player.GetPlayerNetInt( "control_CurrentExpTier" ) >= expTier )
		expTier = player.GetPlayerNetInt( "control_CurrentExpTier" )

	// When we display the tier we just say the player is at Max but internally we allow them to level up over and over again
	if ( useClampedValue )
		expTier = minint( expTier, CONTROL_MAX_EXP_TIER )

	return expTier
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the player's current Exp Tier based on how much Exp they have
int function Control_GetExpTierFromExpTotal( int expTotal, entity player, bool useClampedValue = true )
{
	int expTier = 1

	if ( !IsValid( player ) )
		return expTier

	int nextExpTier = 2
	int expThreshold = Control_GetExpThresholdForTier( nextExpTier, player )

	while ( expTotal >= expThreshold && expThreshold > 0 )
	{
		expTier++
		nextExpTier++
		expThreshold = Control_GetExpThresholdForTier( nextExpTier, player )
	}

	if ( useClampedValue )
		expTier = minint( expTier, CONTROL_MAX_EXP_TIER )

	return expTier
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the amount of Exp needed by the player to reach the next Exp Tier
int function Control_GetExpToNextExpTier( entity player )
{
	int currentExp = Control_GetPlayerExpTotal( player )
	int nextExpTier = Control_GetExpTierFromExpTotal( currentExp, player, false ) + 1
	int nextExpThreshold = Control_GetExpThresholdForTier( nextExpTier, player )
	int expNeeded = 0

	if ( nextExpThreshold > 0 )
		expNeeded = nextExpThreshold - currentExp

	return expNeeded
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the Exp needed to reach the specified Exp tier
int function Control_GetExpThresholdForTier( int tier, entity player )
{
	int expThreshold = 999
	if ( !IsValid( player ) )
		return expThreshold

	string playlistVarModifier = ""
	bool shouldAdjustToLosingTeam = file.playersUsingLosingTeamExpTiersArray.contains( player )

	if ( shouldAdjustToLosingTeam )
		playlistVarModifier = "losingteam_"

	if ( tier <= CONTROL_MAX_EXP_TIER )
	{
		expThreshold = GetCurrentPlaylistVarInt( "exp_requirement_" + playlistVarModifier + "tier" + tier, 0 )
	}
	else
	{
		// Figure out how many tiers past Max we are
		int tiersPastMax = tier - CONTROL_MAX_EXP_TIER

		// Figure out how much extra Exp past max we need to add
		int expDifferenceToMaxTier = ( GetCurrentPlaylistVarInt( "exp_requirement_" + playlistVarModifier + "tier" + ( CONTROL_MAX_EXP_TIER + 1 ), 0 ) ) - ( GetCurrentPlaylistVarInt( "exp_requirement_" + playlistVarModifier + "tier" + CONTROL_MAX_EXP_TIER, 0 ) )

		expThreshold = GetCurrentPlaylistVarInt( "exp_requirement_" + playlistVarModifier + "tier" + CONTROL_MAX_EXP_TIER, 0 ) + ( tiersPastMax * expDifferenceToMaxTier )
	}
	return expThreshold
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the difference for EXP between the current Tier and the Next Tier
int function Control_GetExpDifferenceBetweenLastTierAndTier( int tier, entity player )
{
	int expDifference = -1

	if ( !IsValid( player ) )
		return expDifference

	// Players are able to keep gaining tiers past the max tier. The cost remains the same no matter how many tiers past max you go.
	if ( tier > CONTROL_MAX_EXP_TIER )
	{
		expDifference = Control_GetExpThresholdForTier( CONTROL_MAX_EXP_TIER + 1, player ) - Control_GetExpThresholdForTier( CONTROL_MAX_EXP_TIER, player )
	}
	else if ( tier >= 2 ) // Shouldn't be calculating tier difference for tiers below tracked tiers
	{
		expDifference = Control_GetExpThresholdForTier( tier, player ) - Control_GetExpThresholdForTier( tier - 1, player )
	}

	Assert( expDifference >= 0, "Control_GetExpDifferenceBetweenLastTierAndTier getting a negative difference value which should never happen" )
	return expDifference
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the percent ( as a fraction ) of EXP the player has to the next tier
float function Control_GetEXPPercentToNextTier( entity player )
{
	float expPercentToNextTier = 0.0

	if ( IsValid( player ) )
	{
		int expTier = Control_GetPlayerExpTier( player, false )
		float currentExp = float( Control_GetPlayerExpTotal( player, true, expTier ) )
		float nextExpThreshold = float( Control_GetExpDifferenceBetweenLastTierAndTier( expTier + 1, player ) )
		if ( nextExpThreshold > 0.0 )
			expPercentToNextTier = ( currentExp / nextExpThreshold )
	}

	return expPercentToNextTier
}
#endif // CLIENT || SERVER

#if SERVER
// Check if the player's Ultimate is ready
bool function Control_IsPlayerUltReady( entity player )
{
	if ( !IsValid( player ) || !IsAlive( player )  )
		return false

	// Need to ensure the player is the weapon owner, not a spectator
	if ( player.IsObserver() || player.GetTeam() == TEAM_SPECTATOR )
		return false

	entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if ( !IsValid( ultimateWeapon ) )
		return false

	int currentUltCharge = ultimateWeapon.GetWeaponPrimaryClipCount()
	int maxUltCharge = ultimateWeapon.GetWeaponPrimaryClipCountMax()

	if ( currentUltCharge >= maxUltCharge )
		return true

	// Don't allow Rampart Ult to keep charging up while in use ( and be refunded on respawn)
	if ( ultimateWeapon.HasMod( MOBILE_HMG_ACTIVE_MOD ) || ultimateWeapon.HasMod( ULTIMATE_ACTIVE_MOD_STRING ) )
		return true

	// Don't allow Bloodhound Ult to keep charging while in use
	if ( StatusEffect_HasSeverity( player, eStatusEffect.hunt_mode ) )
		return true

	// Don't allow Ballistic Ult to keep charging while in use
	if ( DoesPlayerHaveAutoLoaderBuff( player ) )
		return true

	return false
}
#endif // SERVER

#if SERVER
// Check if player equipment should evolve when they are awarded Exp
void function Control_AwardedPlayerExp( entity player, int expGiven, int preExpGivenTierExp, int preExpGivenTier )
{
	if ( !Control_GetIsWeaponEvoEnabled() || !IsValid( player ) )
		return

	int currentExpProgress = Control_GetPlayerExpTotal( player )
	int expTier = Control_GetExpTierFromExpTotal( currentExpProgress, player, false )
	int storedExpTier = Control_GetPlayerExpTier( player, false )
	bool passedScoreReq = ( expTier > storedExpTier )

	if ( passedScoreReq )
	{
		//PIN_PlayerControlEXPLevelUp( player, string( storedExpTier ), string( expTier ) )
		player.SetPlayerNetInt( "control_CurrentExpTier", expTier )

		// Check if the players weapon need to evo
		int clampedTierVal = minint( expTier, CONTROL_MAX_EXP_TIER )
		int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
		int secondaryWeaponSlot =  SURVIVAL_GetStowedWeaponSlot( player )
		entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
		entity activeSecondaryWeapon = player.GetNormalWeapon( secondaryWeaponSlot )
		bool canPrimaryWeaponEvo = Control_IsWeaponAbleToEvo( activePrimaryWeapon, clampedTierVal )
		bool canWeaponsEvo = canPrimaryWeaponEvo || Control_IsWeaponAbleToEvo( activeSecondaryWeapon, clampedTierVal )

		// Check if the Primary weapon is unholstered
		bool isActiveWeaponUnHolstered = Control_IsActiveWeaponUnHolstered(  player )

		// If the player is not in combat or won't be evolving their weapons; allow them to level up right away.
		// Also evo right away if only the secondary is going to evo or the primary weapon is holstered since it doesn't affect combat
		// ToDo: DSwieczko remove the !file.playersInCombatArray.contains( player ) check if we decide to keep evo on reload
		if (  !canPrimaryWeaponEvo || !canWeaponsEvo || !isActiveWeaponUnHolstered || ( !Control_GetShouldEvoWeaponsOnWeaponSwitch() && !file.playersInCombatArray.contains( player ) ) )
		{
			Control_ExpTierUp( player )
		}
		else // The player is added to an array stating they have a pending weapon evo. The evo will now occur in Control_OnPlayerInCombatChanged if we evo out of combat or Control_AttemptWeaponEvo if we evo on reload/switch
		{
			if ( !Control_IsPlayerWaitingForWeaponEvo( player ) )
				file.playersWaitingForExpTierUpArray.append( player )
			Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo", true, false )
		}
	}

	// Set the player Ult Charge based on Exp Given
	Control_GiveUltimateChargeFromExp( player, expGiven, preExpGivenTierExp, preExpGivenTier )
}
#endif // SERVER

#if SERVER
// Handle the flourish, communication, and weapon evo once the player is out of combat and the player has moved to the next Exp Tier
void function Control_ExpTierUp( entity player )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	// Disable Ult and tac while evolving weapons since it can mess up how the weapons are equipped leaving players unable to attack or switch weapons
	thread Control_OffhandWeapons_DisableAndEnableOnDelay_Thread( player )

	// Update UI to not mark the player as waiting to be out of combat
	Remote_CallFunction_NonReplay( player, "ServerCallback_Control_UpdatePlayerExpHUDWeaponEvo", false, true )

	// Evolve the player's weapons
	int currentExpProgress = Control_GetPlayerExpTotal( player )
	int expTier = Control_GetPlayerExpTier( player )

	// Give Weapons
	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	int secondaryWeaponSlot =  SURVIVAL_GetStowedWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
	entity activeSecondaryWeapon = player.GetNormalWeapon( secondaryWeaponSlot )

	bool canSecondarySlotWeaponEvo = Control_IsWeaponAbleToEvo( activeSecondaryWeapon, expTier )
	bool didSecondaryLevelUp = canSecondarySlotWeaponEvo ? Control_EvolveWeapon( player, activeSecondaryWeapon, expTier, canSecondarySlotWeaponEvo ) : false
	bool didPrimaryLevelUp = Control_EvolveWeapon( player, activePrimaryWeapon, expTier, canSecondarySlotWeaponEvo )
	bool didWeaponEvo = didPrimaryLevelUp || didSecondaryLevelUp

	// Play weapon Evo VFX and SFX
	if ( !Bleedout_IsBleedingOut( player ) )
		Control_BroadcastEXPLevelUp( player, minint( expTier, CONTROL_MAX_EXP_TIER ), didWeaponEvo )
}
#endif // SERVER

#if SERVER
const float CONTROL_OFFHANDWEAPON_ENABLE_DELAY = 1.0
// Disable Ult and Tac use for the set time then re-enable it. This is done when we are about to evo weapons for the Exp tier system to avoid issues where a player triggers an ult right as their weapons evo.
// This was causing issues with weapons remaining unequipped and players being unable to attack or use their Ult.
void function Control_OffhandWeapons_DisableAndEnableOnDelay_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	svGlobal.levelEnt.EndSignal( GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	if ( !Control_GetIsPlayerWeaponEvoInProgress( player ) )
	{
		DisableOffhandWeapons( player )
		file.playersWithWeaponEvoInProgressArray.append( player )
	}


	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) && Control_GetIsPlayerWeaponEvoInProgress( player ) )
			{
				EnableOffhandWeapons( player )
				file.playersWithWeaponEvoInProgressArray.fastremovebyvalue( player )
			}
		}
	)

	wait CONTROL_OFFHANDWEAPON_ENABLE_DELAY
}
#endif // SERVER

#if SERVER
// Return whether the player is in the progress of evolving their weapons
bool function Control_GetIsPlayerWeaponEvoInProgress( entity player )
{
	return file.playersWithWeaponEvoInProgressArray.contains( player )
}
#endif // SERVER

#if SERVER
// ToDo: DSwieczko remove if we decide to keep evo on reload
// When the player switches between in combat and out of combat states, check if they have an evo waiting. If they do and are out of combat, evolve their weapons
void function Control_OnPlayerInCombatChanged( entity player, bool isPlayerInCombat )
{
	if ( !IsValid( player ) )
		return

	// if the player is in combat, we don't have to do anything
	if ( isPlayerInCombat )
		return

	// If the player is not waiting to evo, we don't have to do anything
	if ( !Control_IsPlayerWaitingForWeaponEvo( player ) )
		return

	// Remove the player from waiting for evo and evolve their weapons
	file.playersWaitingForExpTierUpArray.fastremovebyvalue( player )
	Control_ExpTierUp( player )
}
#endif // SERVER

#if SERVER
// When the player reloads, check if they have an evo waiting. If they do, evolve their weapons
void function Control_OnWeaponReload( entity player )
{
	if ( !IsValid( player ) )
		return

	Control_PrepareForWeaponEvo( player )
}
#endif // SERVER

#if SERVER
// When the players weapons are deployed ( like after a skydive), check if they have an evo waiting. If they do, evolve their weapons
void function Control_OnWeaponDeployed( entity player )
{
	Control_PrepareForWeaponEvo( player )
}
#endif // SERVER

#if SERVER
// When the player switches weapons, check if they have an evo waiting. If they do, evolve their weapons
void function Control_OnWeaponSwitched( entity player, entity newWeapon, entity oldWeapon )
{
	// If the player is not in a valid state to evo, we don't have to do anything
	if ( !Control_IsPlayerAbleToWeaponEvo( player ) )
		return

	if ( !IsValid( oldWeapon ) )
		return

	// If the player is not switching to one of their evo weapons, we don't do anything
	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	int secondaryWeaponSlot =  SURVIVAL_GetStowedWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
	entity activeSecondaryWeapon = player.GetNormalWeapon( secondaryWeaponSlot )

	if ( newWeapon != activePrimaryWeapon && newWeapon != activeSecondaryWeapon )
		return

	Control_PrepareForWeaponEvo( player, newWeapon )
}
#endif // SERVER

#if SERVER
// Run all the necessary checks before we deal with pending Weapon Evo
void function Control_PrepareForWeaponEvo( entity player, entity weapon = null )
{
	if ( !Control_IsPlayerAbleToWeaponEvo( player ) )
		return

	// If we passed in a valid weapon use that, otherwise grab the primary weapon
	if ( weapon == null || !IsValid( weapon ) )
	{
		int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
		weapon = player.GetNormalWeapon( activeWeaponSlot )
	}

	// Wait for a valid weapon state to change weapons
	if ( IsValid( weapon )  )
		thread Control_AttemptWeaponEvoWhenReady_Thread( player, weapon )
}
#endif // SERVER

#if SERVER
// Wait for a good time to evo after weapon switch to avoid a crash
void function Control_AttemptWeaponEvoWhenReady_Thread( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off" )

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	// Have a minimum 1 frame wait to ensure other callback logic has a chance to fire
	WaitFrame()

	OnThreadEnd(
		function() : ( player )
		{
			Control_AttemptWeaponEvo( player )
		}
	)

	// Make sure the weapon is in a valid state to be evolved and equipped ( otherwise we crash )
	while ( IsValid( weapon ) && weapon.GetWeaponActivity() == ACT_VM_IDLE )
	{
		WaitFrame()
	}
}
#endif // SERVER

#if SERVER
// See if the player was waiting to evo their weapon, if they were, evo it
void function Control_AttemptWeaponEvo( entity player )
{
	if ( !IsValid( player ) )
		return

	// If the player is not waiting to evo, we don't have to do anything
	if ( !Control_IsPlayerWaitingForWeaponEvo( player ) )
		return

	// evolve their weapons if they are still alive
	if ( IsAlive( player ) )
		Control_ExpTierUp( player )

	// Regardless of if we complete an evo or not, we want to remove the player from this list if they are valid
	file.playersWaitingForExpTierUpArray.fastremovebyvalue( player )
}
#endif // SERVER

#if SERVER
// Is this player waiting to evo their weapon
bool function Control_IsPlayerWaitingForWeaponEvo( entity player )
{
	return file.playersWaitingForExpTierUpArray.contains( player )
}
#endif // SERVER

#if SERVER
// Is this player in a valid state for Weapon Evo
bool function Control_IsPlayerAbleToWeaponEvo( entity player )
{
	return IsValid( player ) && IsAlive( player ) && Control_IsPlayerWaitingForWeaponEvo( player )
}
#endif // SERVER

#if SERVER
// Ultimate Charge is tied to EXP, the percent remaining to the next EXP Tier is the percent remaining to a full Ultimate Charge.
void function Control_GiveUltimateChargeFromExp( entity player, int expGiven, int preExpGivenTierExp, int preExpGivenTier )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if ( !IsValid( ultimateWeapon ) )
		return

	if ( Control_IsPlayerUltReady( player ) )
		return

	// Determine if this is a regular Ult or one with multiples charges ( ammo )
	bool isNonSegmentedUltWeapon = true
	if ( ultimateWeapon.GetWeaponSettingEnum( eWeaponVar.cooldown_type, eWeaponCooldownType ) == eWeaponCooldownType.ammo )
		isNonSegmentedUltWeapon = false

	// Based on the percent of EXP given in relation to EXP thresholds. Figure out how much Ultimate Ammo to give.
	// Previously we would only care about the current Tier percentage and give that as an Ult charge. But with characters having segmented Ult Charges ( like Vantages rifle)
	// We have to do extra logic to not award Ult charge at the current Exp Tier Percentage but instead see how much Ult charge has been gained ( fixes for bugs like R5DEV-375272 and R5DEV-375278 )
	int totalChargeToGive = 0
	int maxUltCharge = ultimateWeapon.GetWeaponPrimaryClipCountMax()
	int nextExpThreshold = 0
	int nextExpTierToDisburse = preExpGivenTier + 1
	float expPercentGiven = 0.0

	if ( isNonSegmentedUltWeapon ) // Regular Ults match the Exp Tier Percentage 1 to 1
	{
		nextExpThreshold = Control_GetExpDifferenceBetweenLastTierAndTier( nextExpTierToDisburse, player )
		int expToGive = minint( preExpGivenTierExp + expGiven, nextExpThreshold )
		expPercentGiven = float( expToGive ) / float( nextExpThreshold )
		totalChargeToGive = Control_GetRoundedPercentAsInt( expPercentGiven, maxUltCharge )
		// Some percentages don't translate well to the Ult UI, here we convert the amount back to a percentage of the Ult Max ammo so the amount given matches the players EXP percent
		float totalChargeAsPercentage = float( totalChargeToGive) / 100.0
		if ( totalChargeToGive > 0 && totalChargeAsPercentage <= 0.01 )
			totalChargeToGive = int( maxUltCharge * totalChargeAsPercentage )
	}
	else  // The base charge is based off of the current Ultimate Ammo for segmented weapons to take into account ammo already used
	{
		totalChargeToGive = ultimateWeapon.GetWeaponPrimaryClipCount()
		int remainingExpToDisburse = expGiven
		int expToGiveForTier = 0
		int currentTierExp = preExpGivenTierExp

		// We loop through and figure out how much Ult Charge to give from the Exp that was given based on the percentage of Exp for each Exp Tier

		// This is an example for Vantage based on current tuning:
		// You spawn at homebase and get 50% exp to purple tier which is 100 Exp, so we give you 100 Ult charge (her max charge is 200 and Purple tier is at 200).
		// This is equivalent to 2 and a half Ult Ammo because she gets one every 20% of full ult ammo which is every 40 Ult Charges.
		// You use the 2 Ult shots you gained. This leaves you with 0 Ult ammo plus a remainder of 20 Ult Charges.
		// Now if you were to give 180 Exp, 100 would be given based on Blue Tier values which would award you 2 ult charges, plus a third because you had 20 Ult Charges remainder.
		// At this point if we just gave you the remaining 80 Exp at Blue Tier values you would get 2 more Ult ammo. But, we now test at Purple Tier because you reached purple tier.
		// Purple Tier has a Exp threshold of 400 so now you get an ult charge for every 80 Exp. So the remaining Exp gets you one more Ult Ammo for a total of 4
		// The loops starting at Exp Tiers and levels before the Exp was granted are necessary in case we give players a huge amount of EXP that goes over max Exp Tiers multiple times
		while ( remainingExpToDisburse > 0 && totalChargeToGive < maxUltCharge )
		{
			nextExpThreshold = Control_GetExpDifferenceBetweenLastTierAndTier( nextExpTierToDisburse, player )
			expToGiveForTier = minint( remainingExpToDisburse, ( nextExpThreshold - currentTierExp ) )
			if ( nextExpThreshold > 0 )
			{
				expPercentGiven = float( expToGiveForTier ) / float( nextExpThreshold )
				// Convert Exp given to ammo to give based off of EXP percentage
				totalChargeToGive += Control_GetRoundedPercentAsInt( expPercentGiven, maxUltCharge )
				remainingExpToDisburse -= expToGiveForTier
				currentTierExp = 0
				nextExpTierToDisburse++
			}
			else
			{
				break
			}
		}
	}

	// Ensure the Ult Charge is not over the max possible charge then Give Ultimate charge
	totalChargeToGive = minint( maxUltCharge, totalChargeToGive )
	ultimateWeapon.SetWeaponPrimaryClipCountAbsolute( totalChargeToGive )
}
#endif // SERVER

#if SERVER
// Give players a max tactical charge on respawn
void function Control_RestoreChargesOnRespawn( entity player )
{
	if ( !IsValid( player ) )
		return

	// Give player a Max Tac Charge on spawn
	entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if ( IsValid( tacticalWeapon ) )
	{
		int tacCharge = tacticalWeapon.GetWeaponPrimaryClipCount()
		int maxTacCharge = tacticalWeapon.GetWeaponPrimaryClipCountMax()
		if ( tacCharge != maxTacCharge )
			tacticalWeapon.SetWeaponPrimaryClipCount( maxTacCharge )
	}

	// If we are awarding earned Ult on death, give the player back their Ult if they had a full charge when they died
	if ( Control_GetShouldRestoreFullUltOnRespawn() && file.playersWithFullUltOnDeath.contains( player ) )
	{
		entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( IsValid( ultimateWeapon ) )
		{
			int ultCharge = ultimateWeapon.GetWeaponPrimaryClipCount()
			int maxUltCharge = ultimateWeapon.GetWeaponPrimaryClipCountMax()
			if ( ultCharge != maxUltCharge )
				ultimateWeapon.SetWeaponPrimaryClipCount( maxUltCharge )

			file.playersWithFullUltOnDeath.fastremovebyvalue( player )
		}
	}
}
#endif // SERVER

#if SERVER
// Handle logic that evolves a player's weapon
bool function Control_EvolveWeapon( entity player, entity weapon, int newTier, bool canSecondarySlotWeaponEvo )
{
	bool didWeaponEvolve = false

	if ( !IsValid( player ) || !IsValid( weapon ) )
		return didWeaponEvolve

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return didWeaponEvolve

	string weaponSet = CONTROL_WEAPON_SET_STRINGS_FOR_TIER[ newTier ]

	if ( IsUsingLoadoutSelectionSystem() )
		weaponSet = LoadoutSelection_GetWeaponSetStringForTier( newTier )

	int activeWeaponSlot = GetSlotForWeapon( player, weapon )
	// If the player didn't have this weapon stowed and it is the only weapon the player has, force equip it.
	// There is some weapon logic that doesn't re-equip weapons if there is an empty weapon slot.
	// Also used with the canSecondarySlotWeaponEvo check to fix an issue where the secondary weapon gets equipped on an evo if the main weapon had an evo but the secondary didn't
	bool isActiveWeaponUnHolstered = Control_IsActiveWeaponUnHolstered(  player )

	// force equip weapon in case secondary weapon is active
	if ( isActiveWeaponUnHolstered && ( newTier > CONTROL_MAX_EXP_TIER || !Control_IsWeaponAbleToEvo( weapon, newTier ) ) )
	{
		if ( activeWeaponSlot >= WEAPON_INVENTORY_SLOT_DUALPRIMARY_0 )
		{
			player.SetActiveWeaponBySlot( eActiveInventorySlot.altHand, activeWeaponSlot )
		}
		else
		{
			player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, activeWeaponSlot )
		}

		return didWeaponEvolve
	}

	// If the weapon is valid, give the player a leveled up version of it
	if ( IsValid( weapon ) )
	{
		int ammoCount = weapon.UsesClipsForAmmo() ? weapon.GetWeaponPrimaryClipCount() : weapon.GetWeaponPrimaryAmmoCount( weapon.GetActiveAmmoSource() )
		bool wasWeaponClipFull = false

		if ( weapon.UsesClipsForAmmo() )
			wasWeaponClipFull = ammoCount >= weapon.GetWeaponPrimaryClipCountMax()

		LootData activeWeaponData = SURVIVAL_GetLootDataFromWeapon( weapon )
		string weaponRef = activeWeaponData.baseWeapon
		string newWeaponRef = weaponRef + weaponSet

		if ( SURVIVAL_Loot_IsRefValid( newWeaponRef ) && SURVIVAL_Loot_GetLootDataByRef( newWeaponRef ).lootType == eLootType.MAINWEAPON )
		{
			// Get a ref for the current scope on the weapon ( we don't want to switch out scopes when evolving weapons to preserve player preference)
			array<string> mods = weapon.GetMods()
			string currentScopeRef
			for( int i = 0; i < mods.len(); ++i )
			{
				if( !SURVIVAL_Loot_IsRefValid( mods[i] ) )
					continue

				LootData attachData = SURVIVAL_Loot_GetLootDataByRef( mods[i] )
				if ( attachData.attachmentStyle == "sight" )
				{
					currentScopeRef = mods[i]
					break
				}
			}

			// Get the available attachments for the weapon at the new tier but replace the scope with the old scope the player was using
			array<string> upgrades

			if ( IsUsingLoadoutSelectionSystem() )
			{
				upgrades = clone LoadoutSelection_GetAvailableWeaponUpgradesForWeaponRef( newWeaponRef )
			}
			else
			{
				entity tempWeapon = SpawnGenericLoot( newWeaponRef, player.GetOrigin(), player.GetAngles() )
				upgrades = GetWeaponMods( tempWeapon )
				tempWeapon.Destroy()
			}

			bool replacedOptic =  false
			for( int j = 0; j < upgrades.len(); ++j )
			{
				if( !SURVIVAL_Loot_IsRefValid( upgrades[j] ) )
					continue

				LootData attachData = SURVIVAL_Loot_GetLootDataByRef( upgrades[j] )
				if( attachData.attachmentStyle == ( "sight" ) )
				{
					if ( currentScopeRef == "" )
						upgrades.remove( j )
					else
						upgrades[j] = currentScopeRef
					replacedOptic = true
					break
				}
			}

			if( !replacedOptic && currentScopeRef != "" )
			{
				upgrades.append( currentScopeRef )
			}

			for( int i = 0; i < mods.len(); ++i )
			{
				if ( mods[i].find( "altfire" ) != -1 )
				{
					upgrades.append( mods[i] )
				}
			}

			bool energized = false//weapon.IsEnergizeWeapon() && weapon.GetEnergizeState() == ENERGIZE_ENERGIZED
			float energizedEndTime = 0;
			if ( energized )
			{
				//energizedEndTime = weapon.GetEnergizedEndTime()
			}

			// Drop and Destroy the old weapon, spawn the new weapon, to prevent mod transfer on weapon drop remove all the mods before
			weapon.SetMods( [] )
			SURVIVAL_DropWeapon( player, weapon, <0, 0, 0>, <0, 0, 0> )
			weapon.Destroy()

			entity newActiveWeapon = SpawnGenericLoot( weaponRef, player.GetOrigin(), player.GetAngles() )

			if ( IsValid( newActiveWeapon ) )
			{
				newActiveWeapon.SetWeaponMods( upgrades )

				LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( newWeaponRef )
				array<string> lootTags = weaponData.lootTags
				SURVIVAL_GiveMainWeapon( player, newActiveWeapon, lootTags, weapon, false, null, false, true, [], false )
				SetItemSpawnSource( newActiveWeapon, eSpawnSource.EVOLUTION, player )
				newActiveWeapon.Destroy()

				// ToDo: DS look for a way to handle this better with the weapons team, maybe a refactor of the SURVIVAL_GiveMainWeapon function is in order
				// Normally the active weapon slot matches up with the weapon here
				// However, if the player dropped their main slot weapon and only has their secondary and it evolves, it gets moved into the main weapon slot by SURVIVAL_GiveMainWeapon
				// In that scenario we need to update our slot so equipping, energizing, and ammo refill get applied to the weapon
				if ( player.GetNormalWeapon( activeWeaponSlot ) == null )
					activeWeaponSlot = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) != null ? WEAPON_INVENTORY_SLOT_PRIMARY_0 : WEAPON_INVENTORY_SLOT_PRIMARY_1

				entity newlyEquippedWeapon = player.GetNormalWeapon( activeWeaponSlot )

				if ( newlyEquippedWeapon != null && IsValid( newlyEquippedWeapon ) )
				{
					// Force equip the weapon if it changed slots
					if ( isActiveWeaponUnHolstered )
					{
						if ( activeWeaponSlot >= WEAPON_INVENTORY_SLOT_DUALPRIMARY_0 )
						{
							if ( newlyEquippedWeapon.GetWeaponClassName() == weaponRef )
								player.SetActiveWeaponBySlot( eActiveInventorySlot.altHand, activeWeaponSlot )
						}
						else
						{
							player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, activeWeaponSlot )
						}
					}

					// If the weapon was energized, put it back to the same level it was at before evo
					if ( energized )
					{
						//newlyEquippedWeapon.ForceEnergizeState( ENERGIZE_ENERGIZED )
						//newlyEquippedWeapon.ForceEnergizedEndTime( energizedEndTime )
						newlyEquippedWeapon.AddMod( DRAGON_LMG_ENERGIZED_MOD )
					}

					// If the weapon had a full clip before evo give them a full clip after evo, even though there might be more ammo. Feels weird having to reload after having a full clip pre evo
					if ( newlyEquippedWeapon.UsesClipsForAmmo() )
					{
						if ( wasWeaponClipFull || Control_GetShouldEvoWeaponsOnWeaponSwitch() )
						{
							newlyEquippedWeapon.SetWeaponPrimaryClipCount( newlyEquippedWeapon.GetWeaponPrimaryClipCountMax() )
						}
						else
						{
							newlyEquippedWeapon.SetWeaponPrimaryClipCount( minint( ammoCount, newlyEquippedWeapon.GetWeaponPrimaryClipCountMax() ) )
						}
					}
				}
				didWeaponEvolve = true
			}
		}
	}
	return didWeaponEvolve
}
#endif // SERVER

#if SERVER || CLIENT
// Return whether the active weapon is unholstered
bool function Control_IsActiveWeaponUnHolstered( entity player )
{
	if ( !IsValid( player ) )
		return false

	entity primaryWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	return primaryWeapon != null && IsValid( primaryWeapon ) && primaryWeapon.GetWeaponTypeFlags() == WPT_PRIMARY
}
#endif // SERVER || CLIENT


#if SERVER
// Determine if the weapon can evo
bool function Control_IsWeaponAbleToEvo( entity weapon, int evoTier )
{
	bool isWeaponAbleToEvo = false
	LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )
	string weaponRef = weaponData.baseWeapon
	bool isCrateWeapon = ( weaponData.tier == eLootTier.MYTHIC )
	bool isWeaponHigherTier = ( weaponData.tier >= evoTier ) // Our weapon tiers start at 1 instead of the normal 0 for white gear

	if ( !isCrateWeapon && weaponRef != "" && !isWeaponHigherTier )
		isWeaponAbleToEvo = true

	return isWeaponAbleToEvo
}
#endif // SERVER

#if SERVER
// Play SFX and VFX for weapon Evo
void function Control_BroadcastEXPLevelUp( entity upgradePlayer, int expTier, bool didWeaponEvo )
{
	if ( !IsValid( upgradePlayer ) )
		return

	// If the weapon evolved, play weapon Evo VFX ( 1p ). Run this function either way so the SFX can play
	Remote_CallFunction_Replay( upgradePlayer, "ServerCallback_Control_PlayAllWeaponEvoUpgradeFX", upgradePlayer, expTier, didWeaponEvo )

	if ( expTier <= 0 || expTier > CONTROL_MAX_EXP_TIER )
		return

	// Play 3p VFX regardless of whether the weapon evolved or not, so other players can see what tier this player is at
	vector playerPos = upgradePlayer.GetOrigin()
	// Only play the 3p vfx for the other players if they are in range
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		if ( player == upgradePlayer )
			continue

		vector viewerPos = player.GetOrigin()
		if ( Distance( playerPos, viewerPos ) <= WEAPONEVO_UPGRADE_FX_RANGE )
			Remote_CallFunction_Replay( player, "ServerCallback_Control_Play3PEXPLevelUpFX", upgradePlayer, expTier )
	}

}
#endif // SERVER

#if CLIENT
// Trigger 1p weapon evo fx function if passed in params are valid
void function ServerCallback_Control_PlayAllWeaponEvoUpgradeFX( entity player, int expTier, bool didWeaponEvo )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	// Reset weapon reload override text ( we set this when we have evo pending and then reset it here because an evo has occurred )
	player.Signal( "Control_StopWeaponEvoHints" )

	if ( expTier <= 0 || expTier > CONTROL_MAX_EXP_TIER )
		return

	thread Control_PlayAllWeaponEvoUpgradeFX_Thread( player, expTier, didWeaponEvo )
}
#endif // CLIENT

#if CLIENT
// Play the 1st person VFX on the player's gun if it levels up from Exp level up
void function Control_PlayAllWeaponEvoUpgradeFX_Thread( entity player, int expTier, bool didWeaponEvo )
{
	Assert( IsNewThread(), "Must be threaded off" )

	EndSignal( player, "OnDestroy", "OnDeath" )

	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
	float timeToWait = CONTROL_DEFAULT_WEAPON_EVO_VFX_DELAY

	// If the weapon is valid ( which it should be ) get the time it takes to unholster and add it to the wait time so VFX play once the weapon is out ( unholster time without the initial wait was too short)
	if ( IsValid( activePrimaryWeapon ) )
		timeToWait += activePrimaryWeapon.GetWeaponSettingFloat( eWeaponVar.deploy_time )

	wait timeToWait

	if ( !IsValid( player ) )
		return

	// Play level up SFX regardless of whether anything was granted
	switch ( expTier )
	{
		case 1:
			EmitUISound( CONTROL_SFX_WEAPON_EVO_LVL_1 )
			break

		case 2:
			EmitUISound( CONTROL_SFX_WEAPON_EVO_LVL_2 )
			break

		case 3:
			EmitUISound( CONTROL_SFX_WEAPON_EVO_LVL_3 )
			break

		case 4:
			EmitUISound( CONTROL_SFX_WEAPON_EVO_LVL_4 )
			break
		default:
			EmitUISound( CONTROL_SFX_WEAPON_EVO_LVL_1 )
			break
	}

	// Play 1p and 3p vfx on the weapon
	thread Control_PlayWeaponEvoVFX_Thread( player, expTier, FX_WEAPON_EVO_UPGRADE_FP, FX_EXP_LEVELUP_3P )
}
#endif // CLIENT

#if CLIENT
// Trigger 3p weapon evo fx function if passed in params are valid
void function ServerCallback_Control_Play3PEXPLevelUpFX( entity player, int expTier )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	if ( player == GetLocalClientPlayer() )
		return

	if ( !player.DoesShareRealms( GetLocalClientPlayer() ) )
		return

	if ( expTier <= 0 || expTier > CONTROL_MAX_EXP_TIER )
		return

	thread Control_Play3PEXPLevelUpFX_Thread( player, expTier )
}
#endif // CLIENT

#if CLIENT
// Play 3p effects on a player if they leveled up their Exp Tier
void function Control_Play3PEXPLevelUpFX_Thread( entity player, int expTier )
{
	Assert( IsNewThread(), "Must be threaded off" )

	EndSignal( player, "OnDestroy", "OnDeath" )

	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
	float timeToWait = CONTROL_DEFAULT_WEAPON_EVO_VFX_DELAY

	// If the weapon is valid ( which it should be ) get the time it takes to unholster and add it to the wait time so VFX play once the weapon is out ( unholster time without the initial wait was too short)
	if ( IsValid( activePrimaryWeapon ) )
		timeToWait += activePrimaryWeapon.GetWeaponSettingFloat( eWeaponVar.deploy_time )

	wait timeToWait

	thread Control_PlayWeaponEvoVFX_Thread( player, expTier, $"", FX_EXP_LEVELUP_3P )
}
#endif // CLIENT

#if CLIENT
// Avoid duplicate code for playing weapon vfx on Evo.
// This function ensures the attachment point and weapon are valid and then plays the specified vfx on it
const float VFX_LIFETIME = 3.0
void function Control_PlayWeaponEvoVFX_Thread( entity player, int expTier,  asset firstPersonVFXAsset, asset thirdPersonVFXAsset )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	// Make sure we grab the right weapon once it is awarded and unholstered
	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )

	if ( !IsValid( activePrimaryWeapon ) )
		return

	int fpFXHandle

	EndSignal( player, "OnDestroy", "OnDeath" )
	EndSignal( activePrimaryWeapon, "OnDestroy" )

	OnThreadEnd(
		function() : ( fpFXHandle, activePrimaryWeapon, thirdPersonVFXAsset )
		{
			if ( EffectDoesExist( fpFXHandle ) )
				EffectStop( fpFXHandle, true, false )

			if ( IsValid( activePrimaryWeapon ) )
				activePrimaryWeapon.StopWeaponEffect( $"", thirdPersonVFXAsset )
		}
	)

	// Play vfx on the weapon
	vector tierColor = GetFXRarityColorForTier( expTier )
	// There is a rare bug where this attachment doesn't exist. It isn't a weapon issue as this is a base weapon attachment. Instead of crashing, just don't play the vfx if the attachment point is missing
	int attachmentID = activePrimaryWeapon.LookupAttachment( "hcog" )
	if ( attachmentID != 0 )
	{
		fpFXHandle = activePrimaryWeapon.PlayWeaponEffectReturnViewEffectHandle( firstPersonVFXAsset, thirdPersonVFXAsset, "hcog" )
		EffectSetControlPointVector( fpFXHandle, 1, tierColor )
	}

	wait VFX_LIFETIME
}
#endif // CLIENT


/*
  _______ _____ __  __ ______ _____    ________      ________ _   _ _______ _____
 |__   __|_   _|  \/  |  ____|  __ \  |  ____\ \    / /  ____| \ | |__   __/ ____|
    | |    | | | \  / | |__  | |  | | | |__   \ \  / /| |__  |  \| |  | | | (___
    | |    | | | |\/| |  __| | |  | | |  __|   \ \/ / |  __| | . ` |  | |  \___ \
    | |   _| |_| |  | | |____| |__| | | |____   \  /  | |____| |\  |  | |  ____) |
    |_|  |_____|_|  |_|______|_____/  |______|   \/   |______|_| \_|  |_| |_____/

   Timed Events
*/

#if SERVER || CLIENT
const float CONTROL_TOTALSCOREPERCENTAGE_THRESHOLD_FOR_TIMEDEVENTS = 0.75
// Make sure timed events don't trigger near the end of the game
bool function Control_TimedEventStartValidation( float eventLength, bool testForLockout = true )
{
	int scoreLimit = GetScoreLimit_FromPlaylist()
	float timedEventLimit = scoreLimit * CONTROL_TOTALSCOREPERCENTAGE_THRESHOLD_FOR_TIMEDEVENTS
	bool isScoreUnderThreshold = GamemodeUtility_GetWinningTeamOrAllianceScore() < timedEventLimit

	return ( !file.isLockout || !testForLockout ) && isScoreUnderThreshold
}
#endif // SERVER || CLIENT

#if SERVER
// Check if the match state is appropriate for a Lockout and if all objectives are owned by 1 team
bool function Control_LockoutStartValidation( float eventLength )
{
	bool areAllObjectivesOwnedByOneTeam = Control_AllObjectivesOwnedByOneTeam()
	// Test for Match score conditions when deciding whether to display the lockout unavailable message
	bool isValidMatchStateForLockout = Control_isValidMatchStateForLockout( eventLength, false )

	// Display a message stating Lockout is unavailable when it first becomes unavailable
	if ( !file.announcedLockoutUnavailable && !isValidMatchStateForLockout && !file.isLockout )
	{
		foreach( player in GetConnectedPlayers() )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_Control_DisplayLockoutUnavailableWarning" )
		}
		file.announcedLockoutUnavailable = true
	}

	// Test for lockout being active here to ensure we don't trigger a lockout if one is already active
	return areAllObjectivesOwnedByOneTeam && isValidMatchStateForLockout && !file.isLockout
}
#endif // SERVER

#if SERVER || CLIENT
const int CONTROL_TIMEDEVENT_THRESHOLD_PTS_BUFFER = 80
const int CONTROL_OBJECTIVE_COUNT = 3
// Make sure a lockout doesn't start if the game could be less than the points buffer away from finishing if the lockout played out at the last possible time
bool function Control_isValidMatchStateForLockout( float eventLength, bool shouldTestForActiveLockout )
{
	int scoreLimit = GetScoreLimit_FromPlaylist()
	int scorePerSec = CONTROL_OBJECTIVE_COUNT * CONTROL_TEAMSCORE_PER_POINT
	int lockoutLimit = scoreLimit - ( CONTROL_TIMEDEVENT_THRESHOLD_PTS_BUFFER + int( scorePerSec * eventLength ) )
	bool isScoreUnderThreshold = GamemodeUtility_GetWinningTeamOrAllianceScore() < lockoutLimit

	return isScoreUnderThreshold && Control_TimedEventStartValidation( eventLength, shouldTestForActiveLockout )
}
#endif // SERVER || CLIENT

#if CLIENT
// Display a message on the HUD when lockout is no longer available
void function ServerCallback_Control_DisplayLockoutUnavailableWarning()
{
	var scoreTrackerRui = file.scoreTrackerRui[1]
	var mapScoreTrackerRui = file.fullmapScoreTrackerRui[1]
	float currentTime = Time()

	if ( IsValid( scoreTrackerRui ) )
	{
		RuiSetGameTime( scoreTrackerRui, "lastLockoutBlockedMessageDisplayTime", currentTime )
	}

	if ( IsValid( mapScoreTrackerRui ) )
	{
		RuiSetGameTime( mapScoreTrackerRui, "lastLockoutBlockedMessageDisplayTime", currentTime )
	}
}
#endif // CLIENT

#if SERVER
// Make sure a bounty won't end the game
bool function Control_BountyStartValidation( float eventLength )
{
	int scoreLimit = GetScoreLimit_FromPlaylist()
	int scorePerSec = ( CONTROL_OBJECTIVE_COUNT - 1 ) * CONTROL_TEAMSCORE_PER_POINT
	int bountyLimit = scoreLimit - ( CONTROL_TIMEDEVENT_THRESHOLD_PTS_BUFFER + int( Control_GetCurrentBountyAmount() ) + int( scorePerSec * eventLength ) )
	bool isScoreUnderThreshold = GamemodeUtility_GetWinningTeamOrAllianceScore() < bountyLimit

	// Check if there is an available objective that doesn't already have a bounty set on it
	bool isBountyPointAvailable = false
	foreach ( point in file.chosenVariantData.controlPoints )
	{
		if ( !point.hasBountyBeenSet )
		{
			isBountyPointAvailable = true
			break
		}
	}

	return Control_TimedEventStartValidation( eventLength ) && isScoreUnderThreshold && isBountyPointAvailable
}
#endif // SERVER

#if SERVER
bool function Control_AirdropStartValidation( float eventLength )
{
	int maxAirdropGroupCount = Control_GetMaxUnOpenedAirdrops() - file.unopenedAirdropCount
	bool isNotFullOfAirdrops = maxAirdropGroupCount > 0
	return Control_TimedEventStartValidation( eventLength ) && isNotFullOfAirdrops
}
#endif // SERVER

#if SERVER
bool function Control_MRBTimedEventStartValidation( float eventLength )
{
	return Control_TimedEventStartValidation( eventLength ) && !Control_MRBTimedEvent_IsEventActive()
}
#endif // SERVER

/*
	  ____   ____  _   _ _    _  _____    _____          _____ _______ _    _ _____  ______
	 |  _ \ / __ \| \ | | |  | |/ ____|  / ____|   /\   |  __ \__   __| |  | |  __ \|  ____|
	 | |_) | |  | |  \| | |  | | (___   | |       /  \  | |__) | | |  | |  | | |__) | |__
	 |  _ <| |  | | . ` | |  | |\___ \  | |      / /\ \ |  ___/  | |  | |  | |  _  /|  __|
	 | |_) | |__| | |\  | |__| |____) | | |____ / ____ \| |      | |  | |__| | | \ \| |____
	 |____/ \____/|_| \_|\____/|_____/   \_____/_/    \_\_|      |_|   \____/|_|  \_\______|

	Bonus Capture, Objective Bounty
*/

#if SERVER
void function Control_BountyThread( TimedEventData data, entity eventWP )
{
	Assert( IsNewThread(), "Must be threaded off" )

	const float PERCENT_OF_EVENT_LENGTH_BEFORE_ENDING_SOON_DIALOGUE = 0.4

	EndSignal( svGlobal.levelEnt, "GameEnd" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_CancelTermination" )

	float startTime = eventWP.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME )
	float endTime = eventWP.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME )
	int playersPerTeam = GetCurrentPlaylistVarInt( "max_players", CONTROL_DEFAULT_MAX_PLAYERS ) / 2
	float timeBeforeEventEndingSoonDialogue = data.eventLength * PERCENT_OF_EVENT_LENGTH_BEFORE_ENDING_SOON_DIALOGUE

	printt( "CONTROL: Bounty Event, kicking off bounty thread at ", startTime, " with length ", data.eventLength, " and end time ", endTime )

	float bountyAmount = Control_GetCurrentBountyAmount()

	//1. generate bounty candidate scores
	table<ControlPointData, int> bountyCandidateScore = GetObjectivesScoredToBenefitLosingTeam( true )

	//2. get best candidate based on score
	ControlPointData bestBountyCandidate
	foreach( point, score in bountyCandidateScore )
	{
		// Don't even consider a point if it already has a bounty on it
		if ( point.hasBountyBeenSet == true )
			continue

		if ( bestBountyCandidate.id == -1 ) // this is the first valid point we are checking. Set as current best candidate.
		{
			bestBountyCandidate = point
		}
		else if ( score > bountyCandidateScore[ bestBountyCandidate ] )// We already have a candidate, set this point as a new one if it has a better score than the previous candidate.
		{
			bestBountyCandidate = point
		}
	}

	//3. set bounty on best bounty candidate
	if ( IsValid( bestBountyCandidate.waypoint ) )
	{
		//if candidate is found, create thread end for early bounty termination
		OnThreadEnd(
			function() : ( bestBountyCandidate )
			{
				//reset bounty
				if ( IsValid( bestBountyCandidate.waypoint ) )
					bestBountyCandidate.waypoint.SetWaypointFloat( FLOAT_BOUNTY_AMOUNT, 0 )

				bestBountyCandidate.hasBountyBeenSet = false
			}
		)

		printt( "CONTROL: Bounty Event, bounty set on ", bestBountyCandidate.name, " of value ", bountyAmount )

		eventWP.SetWaypointString( WAYPOINT_EVENT_STRING_AWARD, string( bountyAmount ) )
		bestBountyCandidate.waypoint.SetWaypointFloat( FLOAT_BOUNTY_AMOUNT, bountyAmount )
		bestBountyCandidate.hasBountyBeenSet = true
		bestBountyCandidate.lastBountyAward = Time()

		eventWP.SetParent( bestBountyCandidate.waypoint )

		SendBountyActiveAlertToPlayers( bestBountyCandidate.waypoint, bestBountyCandidate.id )
		file.bountiesCreated++
		file.lastBountyPointID = bestBountyCandidate.id
	}
	else
	{
		printt( "CONTROL: Bounty Event, no suitable bounty candidate has been found" )

		Signal( eventWP, "EventEnd" )
	}

	//4. wait thread for event length
	wait endTime - Time() - timeBeforeEventEndingSoonDialogue

	//announcing bounties are ending soon
	if ( !GamemodeUtility_IsWinnerBeingDetermined() )
		thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_CAPTURE_BONUS_ENDING ) )

	wait timeBeforeEventEndingSoonDialogue

	//5. resolve bounty on event end if possible
	if ( bestBountyCandidate.controlPointOwner != ALLIANCE_NONE )
	{
		AwardPointsForBounty( bestBountyCandidate )

		Signal( eventWP, "EventEnd" )
	}
	else
	{
		//todo: do something here to invalidate end time for RUI display purposes
		//, or busy wait until an owner is declared
		while ( bestBountyCandidate.controlPointOwner == ALLIANCE_NONE )
			WaitFrame()

		AwardPointsForBounty( bestBountyCandidate )

		Signal( eventWP, "EventEnd" )
	}
}
#endif // SERVER

#if SERVER
// Get the points value of the current Bounty Timed Event
float function Control_GetCurrentBountyAmount()
{
	const float CONTROL_MAX_BOUNTY_AMOUNT = 200
	const float CONTROL_BASE_BOUNTY_AMOUNT = 150
	const float PER_BOUNTY_BONUS_AMOUNT = 25

	float bountyAmount = CONTROL_BASE_BOUNTY_AMOUNT
	return min( ( bountyAmount + ( file.bountiesCreated * PER_BOUNTY_BONUS_AMOUNT ) ), CONTROL_MAX_BOUNTY_AMOUNT )
}
#endif // SERVER

/*
		_      ____   _____ _  ______  _    _ _______
		| |    / __ \ / ____| |/ / __ \| |  | |__   __|
		| |   | |  | | |    | ' / |  | | |  | |  | |
		| |   | |  | | |    |  <| |  | | |  | |  | |
		| |___| |__| | |____| . \ |__| | |__| |  | |
		|______\____/ \_____|_|\_\____/ \____/   |_|

   Lockout
*/

#if SERVER
const float INSTANT_MATCH_END_LOCKOUT_DURATION = 5.0
void function Control_LockoutThread( TimedEventData data, entity eventWP )
{
	Assert( IsNewThread(), "Must be threaded off" )

	EndSignal( svGlobal.levelEnt, "GameEnd" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_CancelTermination" )

	table<int, bool> e
	e["has_lockout_expired"] <- false

	OnThreadEnd(
		function() : ( e )
		{
			printt( "CONTROL: Lockout Event, lockout terminated at ", Time() )

			file.isLockout = false

			if ( e[ "has_lockout_expired" ] )
			{
				//turn off music if no ramp up
				if ( IsValid( file.musicEntity ) )
					file.musicEntity.SetSoundCodeControllerValue( 0 )
				//game is over, end
				return
			}
			else
			{
				//play abort stinger, then set music to necessary value
				if ( IsValid( file.musicEntity ) )
					EmitSoundOnEntity( file.musicEntity, "Music_Ctrl_LockOut_Abort" )
			}

			CreateMusicEntityIfNotValid()
			//revert to rampup if active on music entity
			if ( file.isRampUp && IsValid( file.musicEntity ) )
			{
				if ( file.rampUpLevel4 )
					file.musicEntity.SetSoundCodeControllerValue( 350 )
				else if ( file.rampUpLevel3 )
					file.musicEntity.SetSoundCodeControllerValue( 250 )
				else if ( file.rampUpLevel2 )
					file.musicEntity.SetSoundCodeControllerValue( 150 )
				else if ( file.rampUpLevel1 )
					file.musicEntity.SetSoundCodeControllerValue( 50 )
			}
			else if ( IsValid( file.musicEntity ) )
			{
				//turn off music if no ramp up
				file.musicEntity.SetSoundCodeControllerValue( 0 )
			}
		}
	)

	file.isLockout = true

	CreateMusicEntityIfNotValid()
	if ( IsValid( file.musicEntity ) )
		file.musicEntity.SetSoundCodeControllerValue( 50 )

	float startTime = eventWP.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME )
	float endTime = eventWP.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME )

	// If we end the match on Lockout, have a short buffer time for communication
	if ( Control_GetIsLockoutInstantWin() )
	{
		endTime = startTime + INSTANT_MATCH_END_LOCKOUT_DURATION
		eventWP.SetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME, endTime )
	}

	printt( "CONTROL: Lockout Event, kicking off lockout thread at ", startTime, " with length ", data.eventLength, " and end time ", endTime )

	bool hasLockoutExpired = false
	int majorityTeam = file.chosenVariantData.controlPoints[0].controlPointOwner //all points owned by one team, so first point owner is majority
	int minorityTeam = majorityTeam == ALLIANCE_A ? ALLIANCE_B : ALLIANCE_A
	eventWP.SetWaypointInt( 5, majorityTeam )

	if ( !GamemodeUtility_IsWinnerBeingDetermined() && !Control_GetIsLockoutInstantWin() )
	{
		thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_LOCKOUT_BEGIN ) )
		PlayBattleChatterToAllianceDelayed( "bc_ctrlLockoutBeginAdvantage", majorityTeam )
		PlayBattleChatterToAllianceDelayed( "bc_ctrlLockoutBeginDisadvantage", minorityTeam )
	}

	while ( !Control_LockoutExitCondition( majorityTeam ) )
	{
		if ( Time() > endTime )
		{
			e["has_lockout_expired"] <- true
			hasLockoutExpired = true
			break
		}

		WaitFrame()
	}

	if ( hasLockoutExpired )
	{
		printt( "CONTROL: Match Ending due to Lockout" )

		Control_SetWinner( majorityTeam, eWinReason.LOCKOUT )
	}
	else
	{
		Control_AwardLockoutBroken( minorityTeam )
	}

	Signal( eventWP, "EventEnd" )
}
#endif // SERVER

#if SERVER
bool function Control_AllObjectivesOwnedByOneTeam()
{
	int checkTeamOwner = ALLIANCE_NONE
	for( int i = 0; i<file.chosenVariantData.controlPoints.len(); i++ )
	{
		ControlPointData point = file.chosenVariantData.controlPoints[i]

		if ( point.controlPointOwner == ALLIANCE_NONE )
			return false

		if ( i == 0 )
		{
			checkTeamOwner = point.controlPointOwner
		}
		else
		{
			if ( point.controlPointOwner != checkTeamOwner )
				return false
		}
	}

	return true
}
#endif // SERVER

#if SERVER
bool function Control_LockoutExitCondition( int majorityTeam )
{
	int minorityTeam = majorityTeam == ALLIANCE_A ? ALLIANCE_B : ALLIANCE_A
	foreach( point in file.chosenVariantData.controlPoints )
	{
		if ( point.controlPointOwner == minorityTeam )
			return true
	}

	return false
}
#endif // SERVER


/*
			   _____ _____  _____  _____   ____  _____   _____
		 /\   |_   _|  __ \|  __ \|  __ \ / __ \|  __ \ / ____|
		/  \    | | | |__) | |  | | |__) | |  | | |__) | (___
	   / /\ \   | | |  _  /| |  | |  _  /| |  | |  ___/ \___ \
	  / ____ \ _| |_| | \ \| |__| | | \ \| |__| | |     ____) |
	 /_/    \_\_____|_|  \_\_____/|_|  \_\\____/|_|    |_____/

	Airdrops
*/

#if SERVER
// Determine where airdrops should land
void function Control_ManageAirdrops_Thread( TimedEventData data, entity eventWP )
{
	Assert( IsNewThread(), "Must be threaded off" )

	int maxAirdropGroupCount = Control_GetMaxUnOpenedAirdrops() - file.unopenedAirdropCount
	if ( maxAirdropGroupCount <= 0 )
	{
		printt( "CONTROL: Airdrop Event, there are too many unopened airdrops to add anymore" )

		Signal( eventWP, "EventEnd" )
	}
	int airdropGroupCount = minint( maxAirdropGroupCount, Control_GetAirdropCountPerGroup() )
	float startTime = Time()

	printt( "CONTROL: Airdrop Event, kicking off manage airdrops thread at ", startTime, " with length ", data.eventLength, " going to spawn ", airdropGroupCount, " airdrops" )

	OnThreadEnd(
		function() : ( eventWP )
		{
			Signal( eventWP, "EventEnd" )
		}
	)

	array< ControlPointData > airdropCandidatePointsSorted = Control_GetSortedObjectivesListForAirdrop( airdropGroupCount )

	// Decide which final positions to use and launch airdrops
	vector airdropCenterPoint
	for ( int count = 0; count < airdropGroupCount; count++ )
	{
		airdropCenterPoint = file.chosenVariantData.mapCenter

		if ( airdropCandidatePointsSorted.len() > 0 )
		{
			// We have some candidates to use so lets use them
			ControlPointData pointToUse = airdropCandidatePointsSorted.pop()

			if ( pointToUse.waypoint != null )
				 airdropCenterPoint = pointToUse.waypoint.GetOrigin()
		}
		else if ( file.chosenVariantData.controlPoints.len() > 0  )
		{
			// We have no more candidates use random points
			ControlPointData pointToUse = file.chosenVariantData.controlPoints.getrandom()

			if ( pointToUse.waypoint != null )
				airdropCenterPoint = pointToUse.waypoint.GetOrigin()
		}

		// Generate the Loot
		array<string> airdropContents = GenerateAirdropContents( CONTROL_DEFAULT_AIRDROP_CONTENTS )
		// Launch the airdrop
		thread Control_LaunchAirdrop_Thread( airdropCenterPoint, airdropContents, data.eventLength )
	}

	if ( !GamemodeUtility_IsWinnerBeingDetermined() )
	{
		string commentaryLineToPlay = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SPONSORED_CARE_PACKAGE_DROPPING )
		thread PlayCommentaryLineToAllPlayers( commentaryLineToPlay )

		// Play a reaction to the announcer line regarding the sponsorship of the airdrops
		Control_PlayReactDialogueToSponsorshipCommentary( commentaryLineToPlay )
	}

	foreach ( player in GetPlayerArray_Alive() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_Control_AirdropNotification" )
	}

	float timeSinceEventStart = Time() - startTime

	wait data.eventLength + timeSinceEventStart
}
#endif // SERVER

#if SERVER
// Get a sorted list of control points that would benefit the losing team more than the winning team.
// If all points are graded equally an empty array is returned
array< ControlPointData > function Control_GetSortedObjectivesListForAirdrop( int airdropGroupCount )
{
	//1. generate airdrop location candidate scores
	table<ControlPointData, int> airdropCandidateScore = GetObjectivesScoredToBenefitLosingTeam( false )

	//2. sort the candidates based on score
	array< ControlPointData > airdropCandidatePointsSorted = []
	foreach( point, score in airdropCandidateScore )
	{
		// There are no points in the array so add this one
		if ( airdropCandidatePointsSorted.len() == 0 )
		{
			airdropCandidatePointsSorted.append( point )
		}
		else
		{
			int index = 0
			// If the point score is better than the point in the array, insert this point into its position
			foreach ( sortedPoint in airdropCandidatePointsSorted )
			{
				int sortedPointScore = airdropCandidateScore[ sortedPoint ]
				if ( score > sortedPointScore )
				{
					airdropCandidatePointsSorted.insert( index, point )
					break
				}
				index++
			}

			// If the point hasn't been added to the array, add it to the end
			if ( !airdropCandidatePointsSorted.contains( point ) )
				airdropCandidatePointsSorted.append( point )
		}
	}

	// Since we want more airdrops on the best point, add it to the array multiple times
	if ( airdropCandidatePointsSorted.len() > 0 )
	{
		// When points are added to the sorted array they could have all actually had the same candidate score. Check if the top point actually scored highest and the second best was higher than third.
		// Otherwise the points should be distributed differently
		bool isBestPointScoreHigherThanSecondBest = true
		bool isSecondBestPointScoreHigherThanThirdBest = true

		if ( airdropCandidatePointsSorted.len() > 1 )
		{
			int bestPointScore = airdropCandidateScore[ airdropCandidatePointsSorted[ 0 ] ]
			int secondBestPointScore = airdropCandidateScore[ airdropCandidatePointsSorted[ 1 ] ]

			if ( secondBestPointScore >= bestPointScore )
				isBestPointScoreHigherThanSecondBest = false
		}

		if ( airdropCandidatePointsSorted.len() > 2 )
		{
			int secondBestPointScore = airdropCandidateScore[ airdropCandidatePointsSorted[ 1 ] ]
			int thirdBestPointScore = airdropCandidateScore[ airdropCandidatePointsSorted[ 2 ] ]

			if ( thirdBestPointScore >= secondBestPointScore )
				isSecondBestPointScoreHigherThanThirdBest = false
		}

		int numBestPointsToAdd = 0
		// If the best point actually had the highest candidate score, add it to the array the most times
		if ( isBestPointScoreHigherThanSecondBest )
		{
			ControlPointData bestPoint = airdropCandidatePointsSorted[ 0 ]
			// Make most of the airdrops for this group be the best point, subtract 1 because this point is already in the array once.
			numBestPointsToAdd = int( airdropGroupCount * 0.6 ) - 1

			if ( numBestPointsToAdd > 0 )
			{
				for ( int i = 0; i < numBestPointsToAdd; i++ )
				{
					airdropCandidatePointsSorted.insert( 0, bestPoint )
				}
			}
		}

		// If the second best point actually had a higher candidate score than the third best point add it a bunch of times
		if ( isSecondBestPointScoreHigherThanThirdBest )
		{
			int secondBestPointIndex = numBestPointsToAdd + 1
			if ( airdropCandidatePointsSorted.len() > secondBestPointIndex )
			{
				ControlPointData secondBestPoint = airdropCandidatePointsSorted[ secondBestPointIndex ]
				int numSecondBestPointsToAdd = int( airdropGroupCount * 0.3 ) - 1

				for ( int i = 0; i < numSecondBestPointsToAdd; i++ )
				{
					airdropCandidatePointsSorted.insert( secondBestPointIndex, secondBestPoint )
				}
			}
		}
		else if ( isBestPointScoreHigherThanSecondBest ) // If the second best and third best are the same but best had the highest score, split up the remaining array spots evenly amongst the last 2 points
		{
			int secondBestPointIndex = numBestPointsToAdd + 1
			int thirdBestPointIndex = secondBestPointIndex + 1
			if ( airdropCandidatePointsSorted.len() > thirdBestPointIndex )
			{
				ControlPointData secondBestPoint = airdropCandidatePointsSorted[ secondBestPointIndex ]
				ControlPointData thirdBestPoint = airdropCandidatePointsSorted[ thirdBestPointIndex ]
				int numRemainingSpotsInArray = airdropGroupCount - airdropCandidatePointsSorted.len()

				for ( int i = 0; i < numRemainingSpotsInArray; i++ )
				{
					if ( i % 2 == 0)
					{
						airdropCandidatePointsSorted.insert( secondBestPointIndex, secondBestPoint )
					}
					else
					{
						airdropCandidatePointsSorted.insert( secondBestPointIndex, thirdBestPoint )
					}
				}
			}
		}

		// If all the points had the same candidate score, empty the array so we just end up using random points
		if ( !isBestPointScoreHigherThanSecondBest && !isSecondBestPointScoreHigherThanThirdBest )
			airdropCandidatePointsSorted.clear()
	}

	// Reverse the order of the sorted array since we want to be popping the highest scoring points off the top
	if ( airdropCandidatePointsSorted.len() > 0 )
		airdropCandidatePointsSorted.reverse()

	return airdropCandidatePointsSorted
}
#endif // SERVER

#if SERVER
// Return a table of Objectives with associated scoring values. Higher score is given to objectives that will benefit the losing team.
// In the case where there isn't a team losing by a large margin, Objective B is given highest priority
table<ControlPointData, int> function GetObjectivesScoredToBenefitLosingTeam( bool isListForObjectiveBounty )
{
	const int CANDIDATE_SCORE_PREFERRED = 5
	const int CANDIDATE_SCORE_AVOID = -10

	int losingAlliance = Control_GetAllianceUsingCatchupMechanics()

	//1. generate objective candidate scores
	table<ControlPointData, int> objectiveToCandidateScore
	foreach ( point in file.chosenVariantData.controlPoints )
	{
		int score = 0

		// These checks are only done for Bonus Capture events to try and prevent the same objectives from being used back to back
		if ( isListForObjectiveBounty )
		{
			if ( point.hasBountyBeenSet )
			{
				objectiveToCandidateScore[ point ] <- CANDIDATE_SCORE_AVOID
				continue //this point already has a bounty, avoid it
			}

			// try to avoid using the same point as last time
			if ( file.lastBountyPointID == point.id )
				score += CANDIDATE_SCORE_AVOID
		}

		if ( losingAlliance == ALLIANCE_NONE ) // If there is no losing alliance Point B is preferred
		{
			if ( point.id == eControlWaypointTypeIndex.OBJECTIVE_B )
				score += CANDIDATE_SCORE_PREFERRED
		}
		else if ( losingAlliance == ALLIANCE_B ) // If the losing Alliance is B, the point closest to Alliance B spawn is preferred
		{
			if ( point.id == eControlWaypointTypeIndex.OBJECTIVE_C )
				score += CANDIDATE_SCORE_PREFERRED
		}
		else if ( losingAlliance == ALLIANCE_A ) // If the losing Alliance is A, the point closest to Alliance A spawn is preferred
		{
			if ( point.id == eControlWaypointTypeIndex.OBJECTIVE_A )
				score += CANDIDATE_SCORE_PREFERRED
		}

		objectiveToCandidateScore[ point ] <- score
	}

	return objectiveToCandidateScore
}
#endif // SERVER

#if SERVER
// Generate Airdrop loot
array<string> function GenerateAirdropContents( string airdropList )
{
	array<string> airdropContents
	array<int> airdropContentIDs

	array<string> airdropTokenArray = split( airdropList, WHITESPACE_CHARACTERS )
	Assert( airdropTokenArray.len() == 3 )

	array< array<string> > podContents = DetermineAirdropContents( [[airdropTokenArray[0]],  [airdropTokenArray[1]],  [airdropTokenArray[2]]] )
	foreach( array<string> contents in podContents )
	{
		Assert( contents.len() == 1 )
		airdropContents.append( contents[0] )
		airdropContentIDs.append( SURVIVAL_Loot_GetLootDataByRef( contents[0] ).index )
	}

	Assert( airdropContentIDs.len() == 3 )
	return airdropContents
}
#endif // SERVER

#if SERVER
// Trigger an Airdrop
// Note this function needs to be a thread in order to properly clean up vfx once the airdrop lands. The airdrop functions control how long this function runs for.
void function Control_LaunchAirdrop_Thread( vector pointLocation, array<string> airdropContents, float pingDuration, bool isMRBAirdrop = false )
{
	Assert( IsNewThread(), "Must be threaded off" )

	svGlobal.levelEnt.EndSignal( GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	float baseAngle = RandomFloatForLoot( 360.0 )
	const float minSearchRadius = 1500.0 // has to be greater than 0 ( otherwise airdrops can land on top of eachother )
	const float maxSearchRadius = 5000.0

	Point airdropPoint
	waitthread FindRandomAirdropDropPoint_Thread( airdropPoint, baseAngle, pointLocation, maxSearchRadius, file.usedAirdropPositions, false, DEFAULT_MAX_AIRDROP_SEARCH_RUNTIME, -1, minSearchRadius, false, file.controlBoundaryWalls )
	if ( ( airdropPoint.angles == <0,0,0> ) && ( airdropPoint.origin == <0,0,0> ) )
		return //skip airdrop if we failed to find a location

	// Update Airdrop tracking Vars since at this point we know we are launching this Airdrop
	vector airdropPos = airdropPoint.origin
	file.usedAirdropPositions.append( airdropPos )

	// Make sure we clean everything up when the thread ends
	array<entity> fxs
	entity threatIndicator
	entity markerSource

	OnThreadEnd(
		function () : ( fxs, threatIndicator, markerSource )
		{
			foreach ( fx in fxs )
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}

			if ( IsValid( threatIndicator ) )
				threatIndicator.Destroy()

			if ( IsValid( markerSource ) )
				markerSource.Destroy()
		}
	)

	// Set special control settings on the Airdrop ( these control the skin and vfx for the airdrop)
	AirdropItemsOptionalInfo optionInfo
	optionInfo.animationName = CONTROL_AIRDROP_ANIMATION
	optionInfo.skin = CHEVREX_AIRDROP_SKIN_INDEX

	// Make the beam green if this is an airdrop being used for the MRB Timed Event and trigger an icon at the location of the drop
	// We delay the airdrop to give players time to reach the airdrop location before it launches
	if ( isMRBAirdrop )
	{
		const vector AIRDROP_ANGLES = <0,0,0>
		int airdropBeamColorID = COLORID_COLORSWATCH_GREEN
		// Since we artificially delay the airdrop for the MRB timed event, add a ground marker at the location of the incoming airdrop
		int markerIndex = GetParticleSystemIndex( FX_AIRDROP_GROUND_MARKER_DEFAULT_CP )
		entity markerFx = StartParticleEffectInWorld_ReturnEntity( markerIndex, airdropPos, AIRDROP_ANGLES )
		fxs.append( markerFx )
		EffectSetControlPointColorById( markerFx, 1, airdropBeamColorID )
		threatIndicator = CreateThreatIndicator( airdropPos + <0, 0, 48>, eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, 128.0 )

		// Same as above, create beam effects at the location of the delayed airdrop
		int beamIndex       = GetParticleSystemIndex( FX_AIRDROP_BEAM_CP )
		entity beamFx       = StartParticleEffectInWorld_ReturnEntity( beamIndex, airdropPos, AIRDROP_ANGLES )
		fxs.append( beamFx )
		markerSource = CreateScriptMover( CONTROL_MODE_MOVER_SCRIPTNAME, airdropPos,  AIRDROP_ANGLES )
		EffectSetControlPointColorById( beamFx, 1, airdropBeamColorID )

		// Add an airdrop bad place to ensure other airdrops can't be placed here
		CreateNonExpiringAirdropBadPlace( airdropPos, AIR_DROP_BAD_PLACE_RADIUS )

		// Ping map if using it
		if ( Control_ShouldShow2DMapIcons() )
		{
			const float spreadRadius = 1.0
			const float ringRadius = 50.0
			const float frequency = 0.8
			const float freqVariation = 0.2

			foreach ( player in GetPlayerArray_Alive() )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_SUR_PingMinimap", airdropPos, pingDuration, spreadRadius, ringRadius, COLORID_AIRDROP_DEFAULT_COLOR, frequency, freqVariation, eAirdropType.STANDARD )
			}
		}

		// Set MRB specific settings for the Airdrop so when the real airdrop is called in the beam and marker are green
		optionInfo.sourceWeaponClassname = MRB_SUPPLY_DROP_NAME

		// Display an icon for the MRB at the airdrop position so players are drawn to fight over the position until the airdrop arrives
		Control_MRBTimedEvent_TriggerMRBAirdropIcon( airdropPos )

		// Delay the airdrop
		wait Control_GetMRBAirdropDelay()

		// Done waiting, destroy all the effects since the real airdrop will now trigger its own
		foreach ( fx in fxs )
		{
			if ( IsValid( fx ) )
				EffectStop( fx )
		}
		fxs.clear()

		if ( IsValid( threatIndicator ) )
			threatIndicator.Destroy()

		if ( IsValid( markerSource ) )
			markerSource.Destroy()
	}

	// Launch the Airdrop
	array< array<string> > podContents = [[airdropContents[0]], [airdropContents[1]], [airdropContents[2]]]
	thread AirdropItems( airdropPos, <0, RandomFloatRange(-180, 180), 0>, podContents, optionInfo )

	// Track the MRB being in play since we track the MRB logic separate from the event logic in case the event is killed early by Lockout
	if ( isMRBAirdrop )
		thread Control_MRBTimedEvent_ManageMRBSpawnPoint_Thread()
}
#endif // SERVER

#if SERVER
// When an Airdrop first gets launched, store it's loot tier so we can change the look of the icon when it lands based on tier
void function Control_OnAirdropLaunched( entity airdrop, vector airdropPos )
{
	if ( airdrop.GetOwner() != null ) // Lifeline care package, get loot based on player tier
	{
		file.airdropToLootTierTable[ airdrop ] <- Control_GetPlayerExpTier( airdrop.GetOwner() )
	}
	else // Airdrop, just give gold tier loot for now
	{
		file.airdropToLootTierTable[ airdrop ] <- DEFAULT_AIRDROP_TIER
	}
}
#endif // SERVER

#if SERVER
// When an Airdrop lands, display an icon showing the tier of the airdrop and leave the icon until the airdrop gets opened
void function Control_OnAirdropLanded( entity airdrop, vector airdropPos )
{
	// If this is an MRB Airdrop break out, we handle the MRB icon differently at the start ( it appears before the airdrop comes in).
	// The function that handles the MRB Airdrop icon is in Control_MRBTimedEvent_TriggerMRBAirdropIcon
	// However, The logic that cleans up these regular airdrop icons will end up cleaning up the MRB Airdrop icon as well.
	if ( Control_MRBTimedEvent_IsEventActive() && airdrop.e.sourceWeaponClassname == MRB_SUPPLY_DROP_NAME )
	{
		if ( IsValid( file.mrbAirdropWP ) )
			file.airdropToWaypointTable[ airdrop ] <- file.mrbAirdropWP

		return
	}

	int lootTier = 0
	Assert( airdrop in file.airdropToLootTierTable, "Control_OnAirdropLanded airdrop is not in the airdropToLootTierTable" )

	if ( airdrop in file.airdropToLootTierTable )
		lootTier = file.airdropToLootTierTable[ airdrop ]

	entity wp = CreateWaypoint_Custom( WAYPOINT_CONTROL_AIRDROP )
	wp.SetWaypointInt( AIRDROP_WAYPOINT_LOOTTIER_INT, lootTier )
	wp.SetOrigin( airdropPos )

	file.airdropToWaypointTable[ airdrop ] <- wp
	file.unopenedAirdropCount++
}
#endif // SERVER

#if SERVER
// Kill the airdrop icon when the airdrop is opened
void function Control_OnAirdropOpened( entity airdrop, entity player )
{
	Assert( airdrop in file.airdropToWaypointTable, "Control_OnAirdropOpened airdrop is not in the airdropToWaypointTable" )

	if ( airdrop in file.airdropToWaypointTable )
	{
		entity wp = file.airdropToWaypointTable[ airdrop ]
		if ( IsValid( wp ) )
		{
			if ( wp.GetWaypointBitfield() == CONTROL_MRB_ISMRBAIRDROP_BITFIELD )
			{
				file.mrbAirdropWP = null

				if ( IsValid( file.activeMRBSurvivalItem ) )
				{
					entity mrbWP = CreateWaypoint_Custom( WAYPOINT_CONTROL_MRB )
					file.activeMRBWaypoint = mrbWP
					file.activeMRBWaypoint.SetParent( file.activeMRBSurvivalItem )
					file.activeMRBWaypoint.SetAbsOrigin( file.activeMRBSurvivalItem.GetOrigin() )
				}
			}

			wp.Destroy()
			delete file.airdropToWaypointTable[ airdrop ]
			delete file.airdropToLootTierTable[ airdrop ]
		}
	}
	file.unopenedAirdropCount--
}
#endif // SERVER

#if SERVER
array< array<string> > function Control_OverrideAbilityCarePackage( entity player )
{
	array<string> left
	array<string> right
	array<string> center

	if ( GameMode_IsActive( eGameModes.CONTROL ) )
	{
		// The default value for Exp Tier is not valid for care package loot groups because we disable loot that the player spawns with.
		// So in case we don't get an updated loot tier, make sure we atleast use the default plus 1.
		// ( In Control, you should only have your ultimate at levels higher than default since you gain an ult when you get a new tier)
		int minAirdropTier = minint( ( Control_GetDefaultWeaponTier() + 1 ), CONTROL_MAX_EXP_TIER )
		int airdropTier = maxint( minAirdropTier , Control_GetPlayerExpTier( player ) )
		left = ["control_carepackage_left_tier_" + airdropTier]
		right = ["control_carepackage_right_tier_" + airdropTier]
		center = ["control_carepackage_center_tier_" + airdropTier]
	}
	else
	{
		left = ["control_carepackage_left_tier_1"]
		right = ["control_carepackage_right_tier_1"]
		center = ["control_carepackage_center_tier_1"]
	}

	return [ left, center, right ]
}
#endif // SERVER

#if CLIENT
// Track and display an icon on the map and minimap for airdrops until they are opened
const float CONTROL_MRB_AIRDROP_ICON_ZOFFSET = 200.0
void function InstanceWPControlAirdrop( entity wp )
{
	if ( Control_ShouldShow2DMapIcons() )
	{
		int lootTier = wp.GetWaypointInt( AIRDROP_WAYPOINT_LOOTTIER_INT )
		thread Control_CreateAirdropIcon_Thread( wp, lootTier )
	}

	// If this is an MRB Airdrop, display an icon on it
	if ( Control_GetIsMRBTimedEventEnabled() && wp.GetWaypointBitfield() == CONTROL_MRB_ISMRBAIRDROP_BITFIELD )
	{
		thread Control_MRBTimedEvent_ManageMRBIcons_Thread( wp, false, CONTROL_MRB_AIRDROP_ICON_ZOFFSET )
	}
}
#endif // CLIENT

#if CLIENT
// Create the icon for airdrops
void function Control_CreateAirdropIcon_Thread( entity wp, int lootTier )
{
	Assert( IsNewThread(), "Must be threaded off" )

	FlagWait( "EntitiesDidLoad" )
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) || !IsValid( wp ) )
		return

	player.EndSignal( "OnDestroy" )
	wp.EndSignal( "OnDestroy" )

	int airdropIconColorID
	switch( lootTier )
	{
		case -1:
			airdropIconColorID = COLORID_HUD_LOOT_TIER5
			break
		case 1:
			airdropIconColorID = COLORID_HUD_LOOT_TIER2
			break
		case 2:
			airdropIconColorID = COLORID_HUD_LOOT_TIER3
			break
		case 3:
			airdropIconColorID = COLORID_HUD_LOOT_TIER4
			break
		default:
			airdropIconColorID = COLORID_HUD_LOOT_TIER0
			break
	}

	vector iconColor = GetKeyColor( airdropIconColorID ) * ( 1.0 / 255.0 )
	var minimapRui = Minimap_AddIconAtPosition( wp.GetOrigin(), <0,90,0>, AIRDROP_LANDED_ICON, 1.0, iconColor )
	var fullmapRui = FullMap_AddIconAtPos( wp.GetOrigin(), <0,0,0>, AIRDROP_LANDED_ICON, 7.0, iconColor )

	OnThreadEnd(
		function() : ( minimapRui, fullmapRui )
		{
			Minimap_CommonCleanup( minimapRui )
			Fullmap_RemoveRui( fullmapRui )
			RuiDestroy( fullmapRui )
		}
	)

	WaitForever()
}
#endif // CLIENT

/*
	  __  __ _____  ____    _______ _____ __  __ ______ _____    ________      ________ _   _ _______
	 |  \/  |  __ \|  _ \  |__   __|_   _|  \/  |  ____|  __ \  |  ____\ \    / /  ____| \ | |__   __|
	 | \  / | |__) | |_) |    | |    | | | \  / | |__  | |  | | | |__   \ \  / /| |__  |  \| |  | |
	 | |\/| |  _  /|  _ <     | |    | | | |\/| |  __| | |  | | |  __|   \ \/ / |  __| | . ` |  | |
	 | |  | | | \ \| |_) |    | |   _| |_| |  | | |____| |__| | | |____   \  /  | |____| |\  |  | |
	 |_|  |_|_|  \_\____/     |_|  |_____|_|  |_|______|_____/  |______|   \/   |______|_| \_|  |_|

	MRB TIMED EVENT
*/

#if SERVER
// Return whether the MRB event is running ( will still be true even when the payload is charged and a player has the MRB or the MRB has been called in and is alive)
// We never want more than 1 MRB or MRB event active at a time
bool function Control_MRBTimedEvent_IsEventActive()
{
	return file.isMRBInPlay || file.isMRBEventActive
}
#endif // SERVER

#if CLIENT
// Manage the messaging on the Timed Event HUD
// NOTE: Loops with waits are used in this function instead of signals because there is no guarantee that the Client won't join mid event, in which case signals will be missed.
// The current logic is setup in a way that the player should drop down through the checks to the correct point in the event.
const float MRB_INSTRUCTIONS_UPDATE_INTERVAL = 0.5
const float MRB_PHASE_CHECK_INTERVALS = 1.0
void function Control_MRBTimedEvent_InfoOverride_Thread( entity wp, TimedEventLocalClientData data )
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( wp, "OnDestroy" )

	// Waypoint should be valid on start, if not, back out
	if ( !IsValid( wp ) )
		return

	// Trigger the Event incoming countdown
	float timeToWait = wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME ) - Time()
	if ( timeToWait > 0 )
	{
		Control_ObjectiveScoreTracker_PushAnnouncement( wp,
			true,
			"",
			Localize( data.eventName ),
			wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME ) - Time(),
			timeToWait,
			false,
			true,
			GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL ) )

		wait timeToWait
	}

	// Show the default MRB Incoming Message
	data.eventName = "#EVENT_MRB_NAME"
	data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_INCOMING" )

	// Wait until the Intro Phase is complete
	while ( wp.GetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE ) < eControlMRBTimeEventPhase.AIRDROP )
	{
		wait MRB_PHASE_CHECK_INTERVALS
	}

	// Show countdown info until the Airdrop comes in
	float endTime = wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME )

	if ( wp.GetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE ) == eControlMRBTimeEventPhase.AIRDROP && Time() < endTime )
	{
		data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_INCOMING" )
		EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
		data.shouldHideTimer = false
		float airdropDelayTimeRemaining = endTime - Time()
		wait airdropDelayTimeRemaining
	}

	// Hide the timer while the MRB Airdrop comes in and display the Get the MRB text
	data.eventDesc =Localize( "#CONTROL_MRB_INSTRUCTIONS_IDLE" )
	EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
	data.shouldHideTimer = true

	// Wait until someone opens the MRB Airdrop
	while( wp.GetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE ) < eControlMRBTimeEventPhase.MRB_IN_PLAY )
	{
		wait MRB_PHASE_CHECK_INTERVALS
	}

	int lastMRBState
	entity localClientPlayer = GetLocalClientPlayer()
	bool isLocalClientObserver = GamemodeUtility_IsPlayerOnTeamObserver( localClientPlayer )
	vector friendlyObjectiveCol = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED )
	vector enemyObjectiveCol = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED )
	vector neutralObjectiveCol = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL )
	// Display up to date instructions while the MRB is in play
	while( wp.GetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE ) == eControlMRBTimeEventPhase.MRB_IN_PLAY )
	{
		// Only update the messaging or play the notification sound if the state has changed
		if ( lastMRBState != file.mrbState )
		{
			data.shouldHideTimer = true
			switch( file.mrbState )
			{
				case eControlMRBTimeEventMRBState.IDLE:
					data.eventDesc =Localize( "#CONTROL_MRB_INSTRUCTIONS_IDLE" )
					EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
					data.colorOverride = neutralObjectiveCol
					break
				case eControlMRBTimeEventMRBState.PERSONAL_HELD:
					data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_YOU_HELD" )
					EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
					data.colorOverride = ( isLocalClientObserver )?neutralObjectiveCol :friendlyObjectiveCol
					break
				case eControlMRBTimeEventMRBState.FRIENDLY_HELD:
					data.eventDesc = ( isLocalClientObserver )? Localize( "#CONTROL_MRB_INSTRUCTIONS_YOU_HELD" ) :Localize( "#CONTROL_MRB_INSTRUCTIONS_TEAM_HELD" )
					EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
					data.colorOverride = ( isLocalClientObserver )? neutralObjectiveCol :friendlyObjectiveCol
					break
				case eControlMRBTimeEventMRBState.ENEMY_HELD:
					data.eventDesc = ( isLocalClientObserver )? Localize( "#CONTROL_MRB_INSTRUCTIONS_YOU_HELD" ) :Localize( "#CONTROL_MRB_INSTRUCTIONS_ENEMY_HELD" )
					EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE_ENEMY )
					data.colorOverride = ( isLocalClientObserver )? neutralObjectiveCol :enemyObjectiveCol
					break
				default:
					data.eventDesc = Localize( "#EVENT_MRB_DESC" )
					EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
					data.colorOverride = neutralObjectiveCol
					break
			}
			lastMRBState = file.mrbState
		}
		wait MRB_INSTRUCTIONS_UPDATE_INTERVAL
	}

	// Update to MRB launched text
	data.shouldHideTimer = true
	data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_LAUNCHED" )
	EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
	data.colorOverride = neutralObjectiveCol

	// Wait for the MRB to be deployed
	while( wp.GetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE ) < eControlMRBTimeEventPhase.MRB_DEPLOYED )
	{
		wait MRB_PHASE_CHECK_INTERVALS
	}

	int mrbSpawnOwner
	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() )
	data.shouldHideTimer = false

	// Find the spawn point for the MRB which contains alliance info on the Client
	entity mrbSpawnPoint = file.spawnWaypoints[ eControlWaypointTypeIndex.MRB_SPAWN ]
	if ( IsValid( mrbSpawnPoint ) )
	{
		mrbSpawnOwner = mrbSpawnPoint.GetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX )

		if ( mrbSpawnOwner == localPlayerAlliance )
		{
			data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_LIFETIME" )
			data.colorOverride = ( isLocalClientObserver )? neutralObjectiveCol : friendlyObjectiveCol
		}
		else
		{
			data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_LIFETIME_ENEMY" )
			data.colorOverride = ( isLocalClientObserver )? neutralObjectiveCol : enemyObjectiveCol
		}
	}
	else // In case we don't find a spawn, display a generic MRB Deployed Message
	{
		data.eventDesc = Localize( "#CONTROL_MRB_INSTRUCTIONS_LIFETIME" )
		data.colorOverride = neutralObjectiveCol
	}
	EmitUISound( CONTROL_SFX_MRB_STATUS_UPDATE )
}
#endif // CLIENT

#if SERVER
// Manage the MRB timed event logic
// 1. Bring in an Airdrop containing the MRB Payload
// 2. Wait for the player with the MRB to call it in
// 3. Once the MRB is called in, wait its lifetime then destroy it and end the event
// Note: Once the MRB airdrop comes in management of the MRB and called in spawn occur outside of this function.
// This is to ensure everything works even if this function is killed by something like a Lockout triggering
const float MRB_AIRDROP_DROP_TIME = 16.0 // Estimated time of airdrop anim
void function Control_MRBTimedEvent_Thread( TimedEventData data, entity eventWP )
{
	Assert( IsNewThread(), "Must be threaded off" )

	printt( "CONTROL: MRB Event, starting MRB Timed Event" )

	if ( !IsValid( eventWP ) )
		return

	EndSignal( svGlobal.levelEnt, "GameEnd" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_CancelTermination" )

	file.isMRBEventActive = true
	eventWP.SetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE,  eControlMRBTimeEventPhase.INTRO )

	OnThreadEnd(
		function() : ( eventWP )
		{
			printt( "CONTROL: MRB Event, ended MRB Timed Event" )

			file.isMRBEventActive = false

			if ( IsValid( eventWP ) )
				Signal( eventWP, "EventEnd" )
		}
	)

	// Play event starting Announcer Dialogue
	if ( !GamemodeUtility_IsWinnerBeingDetermined() )
		thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_MRB_TIMEDEVENT_START ) )

	array< ControlPointData > airdropCandidatePointsSorted = Control_GetSortedObjectivesListForAirdrop( 1 )

	// Decide which final position to use and launch an airdrop containing the MRB payload
	vector airdropCenterPoint
	if ( airdropCandidatePointsSorted.len() > 0 )
	{
		// We have some candidates to use so lets use them
		ControlPointData pointToUse = airdropCandidatePointsSorted.pop()

		if ( pointToUse.waypoint != null )
			airdropCenterPoint = pointToUse.waypoint.GetOrigin()
	}
	else if ( file.chosenVariantData.controlPoints.len() > 0  )
	{
		// We have no candidates use random point
		ControlPointData pointToUse = file.chosenVariantData.controlPoints.getrandom()

		if ( pointToUse.waypoint != null )
			airdropCenterPoint = pointToUse.waypoint.GetOrigin()
	}

	printt( "CONTROL: MRB Event, Launching Airdrop with MRB" )

	// Generate the Loot
	array<string> airdropContents = GenerateAirdropContents( CONTROL_MRB_EVENT_AIRDROP_CONTENTS )
	// Launch the airdrop
	thread Control_LaunchAirdrop_Thread( airdropCenterPoint, airdropContents, data.eventLength, true )

	// Set the event timer so it displays the countdown to the MRB Airdrop being deployed ( there is a delay before the airdrop actually triggers in the above function )
	float endTime
	if ( IsValid( eventWP ) )
	{
		float startTime = eventWP.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME)
		endTime = Time() + Control_GetMRBAirdropDelay() + MRB_AIRDROP_DROP_TIME
		eventWP.SetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME, endTime )
		eventWP.SetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE, eControlMRBTimeEventPhase.AIRDROP )
	}

	// We are  waiting for the MRB to be spawned
	WaitSignal( svGlobal.levelEnt, "Control_MRB_Spawned" )

	if ( IsValid( eventWP ) )
		eventWP.SetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE, eControlMRBTimeEventPhase.MRB_IN_PLAY )

	// Now we wait for the MRB to be called in
	WaitSignal( svGlobal.levelEnt, "Control_MRB_CalledIn" )

	if ( IsValid( eventWP ) )
		eventWP.SetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE, eControlMRBTimeEventPhase.MRB_LAUNCHED )

	// We are now waiting for the MRB to be deployed
	WaitSignal( svGlobal.levelEnt, "Control_MRB_Deployed" )

	// Make sure a valid respawn point was created, otherwise end the event
	if ( file.activeMRBAllianceOwner != ALLIANCE_NONE )
	{
		// Set the event timer so it displays the countdown to the MRB spawn being destroyed
		if ( IsValid( eventWP ) )
		{
			endTime = Time() + Control_GetMRBSpawnLifetime()
			eventWP.SetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME, endTime )
			eventWP.SetWaypointInt( TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE, eControlMRBTimeEventPhase.MRB_DEPLOYED )
		}

		wait Control_GetMRBSpawnLifetime()
	}
}
#endif // SERVER

#if SERVER
// Manage the lifetime of the called in MRB
void function Control_MRBTimedEvent_ManageMRBSpawnPoint_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( svGlobal.levelEnt, "GameEnd" )
	EndSignal( svGlobal.levelEnt, GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	OnThreadEnd(
		function() : ()
		{
			printt( "CONTROL: MRB Event, ending MRB Spawn Point Management thread. Going to destroy the MRB Spawn" )

			file.isMRBInPlay = false
			file.didMRBSpawn = false
			Control_DestroyMRB()
		}
	)

	file.nextTimeAllowedToPlayMRBSecuredDialogue = Time()
	file.isMRBInPlay = true

	// 50/50 whether we play announcer VO when the MRB gets called in or deployed
	bool shouldTriggerMRBCalledInDialogue = CoinFlip()

	if ( shouldTriggerMRBCalledInDialogue )
	{
		// Wait for the MRB to be called in ( player triggers the MRB deployment )
		WaitSignal( svGlobal.levelEnt, "Control_MRB_CalledIn" )

		// Play MRB called in Announcer Dialogue
		if ( !GamemodeUtility_IsWinnerBeingDetermined() )
			thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_MRB_TIMEDEVENT_MRB_CALLED_IN ), ANNOUNCER_DIALOGUE_DELAY )
	}

	printt( "CONTROL: MRB Event, Waiting for MRB to be deployed" )

	// Wait for the MRB to be deployed ( the called in MRB lands )
	WaitSignal( svGlobal.levelEnt, "Control_MRB_Deployed" )

	// Make sure a valid respawn point was created. Otherwise cleanup the MRB
	if ( file.activeMRBAllianceOwner != ALLIANCE_NONE )
	{
		// If we didn't use the MRB Called in dialogue, use the deployed dialogue instead
		if ( !shouldTriggerMRBCalledInDialogue )
		{
			// Play MRB deployed Announcer Dialogue
			if ( !GamemodeUtility_IsWinnerBeingDetermined() )
				thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_MRB_TIMEDEVENT_MRB_DEPLOYED ) )
		}

		// Set the MRB end time on the spawn point so it can be displayed on the map
		entity mrbSpawnPoint = file.spawnWaypoints[ eControlWaypointTypeIndex.MRB_SPAWN ]
		if ( IsValid( mrbSpawnPoint ) )
			mrbSpawnPoint.SetWaypointFloat( CONTROL_MRB_SPAWN_WAYPOINT_ENDTIME, Time() + Control_GetMRBSpawnLifetime() )

		printt( "CONTROL: MRB Event, MRB deployed waiting for MRB lifetime: ", Control_GetMRBSpawnLifetime() )

		wait Control_GetMRBSpawnLifetime()

		printt( "CONTROL: MRB Event, done waiting MRB lifetime. Destroying the active MRB" )

		// Play MRB Destroyed Announcer Dialogue
		if ( !GamemodeUtility_IsWinnerBeingDetermined() )
			thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_MRB_TIMEDEVENT_MRB_EXPIRED ) )
	}
}

#endif // SERVER

#if SERVER
// Display an MRB Airdrop icon in the world before the MRB airdrop comes in and leave it in world until the airdrop is opened
// The cleanup of the icon is handled by the airdrop script in Control
void function Control_MRBTimedEvent_TriggerMRBAirdropIcon( vector airdropPos )
{
	entity wp = CreateWaypoint_Custom( WAYPOINT_CONTROL_AIRDROP )

	wp.SetOrigin( airdropPos )
	wp.SetWaypointBitfield( CONTROL_MRB_ISMRBAIRDROP_BITFIELD )
	file.mrbAirdropWP = wp
}
#endif // SERVER

#if SERVER
const float MRB_RESET_POSITION_FORWARD_OFFSET = 13
// This gets called when the mrb survival item is spawned inside the airdrop. Here we set the active MRB entity so it's location can be tracked by the Client
void function Control_MRBSurvivalItem_Spawned( entity ent )
{
	// Only run this logic once ( this callback gets triggered any time the item spawns which includes when it is dropped)
	if ( file.didMRBSpawn )
		return

	if ( !IsValid( ent ) )
		return

	int idx = ent.GetSurvivalInt()

	if ( idx < 0 )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( idx )

	if ( data.ref == MRB_WEAPON_REF_NAME )
	{
		file.didMRBSpawn = true
		file.activeMRBSurvivalItem = ent
		// Ensure the mrb is not network culled ( was causing icons to disappear at long distances )
		if ( ent.GetClassName() == "prop_survival" )
			SURVIVAL_Loot_DisableNetworkDistanceCullingManaged( ent )

		// Send a signal so the Timed Event function can track the current state of the event
		Signal( svGlobal.levelEnt, "Control_MRB_Spawned" )

		// Save the position and angles of the spawned MRB in case we need to reset it
		// Need to add an offset to the position because we are storing this position when the MRB spawns but after a player opens the airdrop there is an animation that pushes the MRB out.
		// If we don't add the offset the mrb will reset inside the airdrop model
		file.mrbSpawnAngles = ent.GetAngles()
		vector fwd = ent.GetUpVector()
		vector offset = fwd * MRB_RESET_POSITION_FORWARD_OFFSET
		file.mrbSpawnPosition = ( ent.GetOrigin() + offset )
	}
}
#endif // SERVER

#if CLIENT
// Wait for the MRB to spawn in world, then trigger the management of the MRB icon on the mrb waypoint
void function InstanceWPControlMRB( entity wp )
{
	thread Control_MRBTimedEvent_ManageMRBIcons_Thread( wp, true, MRB_ICON_OFFSET )
}
#endif // CLIENT

#if CLIENT
// Create and manage map and in world icons related to the MRB and the MRB Airdrop
void function Control_MRBTimedEvent_ManageMRBIcons_Thread( entity wp, bool shouldUpdateIconBasedOnMRBState, float defaultIconZOffset )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( wp ) )
		return

	wp.EndSignal( "OnDestroy" )

	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	localPlayer.EndSignal( "OnDestroy" )

	bool shouldDisplayMapIcon = Control_IsLocalClientInMapCameraView()

	// Create an in world icon for the MRB
	var inWorldIconRui = CreateCockpitPostFXRui( $"ui/timed_event_objective_icon.rpak", FULLMAP_Z_BASE )
	Control_MRBTimedEvent_SetMRBIconValues( inWorldIconRui, eControlMRBTimeEventMRBState.IDLE, true, false )
	RuiTrackFloat3( inWorldIconRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetFloat( inWorldIconRui, "zOffset", defaultIconZOffset )
	RuiSetBool( inWorldIconRui, "isVisible", !shouldDisplayMapIcon )
	RuiSetBool( inWorldIconRui, "shouldShowDistIndicator", true )
	RuiSetBool( inWorldIconRui, "isMapIcon", false )

	// Create a map only icon for the MRB
	var mapIconRui = CreateWaypointRui( $"ui/timed_event_objective_icon.rpak", CONTROL_TEAMMATE_ICON_SORTING )
	Control_MRBTimedEvent_SetMRBIconValues( mapIconRui, eControlMRBTimeEventMRBState.IDLE, true, true )
	RuiTrackFloat3( mapIconRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetBool( mapIconRui, "isVisible", shouldDisplayMapIcon )
	RuiSetBool( mapIconRui, "shouldShowDistIndicator", false )
	RuiSetBool( mapIconRui, "isMapIcon", true )

	var mapIconEnemyRui = null
	// We only need this if the icon can change to a state where it is held by an enemy
	if ( shouldUpdateIconBasedOnMRBState )
	{
		// Create a map only icon for the player holding the MRB ( if they are an enemy ). The way this icon was designed, it was meant to fit over the player icon which we normally only show for friendly players
		vector enemyIconColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED, true )
		mapIconEnemyRui = CreateWaypointRui( $"ui/control_teammate_loc_icon.rpak", CONTROL_TEAMMATE_ICON_SORTING )
		RuiSetColorAlpha( mapIconEnemyRui, "teammateIconColor", enemyIconColor, 1.0 )
		RuiTrackFloat3( mapIconEnemyRui, "teammateLocation", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat3( mapIconEnemyRui, "teammateRotation", wp, RUI_TRACK_CAMANGLES_FOLLOW )
		RuiSetFloat3( mapIconEnemyRui, "cameraLookDirection", file.cameraAngles )
		RuiSetGameTime( mapIconEnemyRui, "spawnStartTime", Time() )
		RuiSetBool( mapIconEnemyRui, "display", shouldDisplayMapIcon )
	}

	OnThreadEnd(
		function() : ( inWorldIconRui, mapIconRui, mapIconEnemyRui )
		{
			if ( IsValid( inWorldIconRui ) )
				RuiDestroy( inWorldIconRui )

			if ( IsValid( mapIconRui ) )
				RuiDestroy( mapIconRui )

			if ( IsValid( mapIconEnemyRui ) )
				RuiDestroy( mapIconEnemyRui )

			file.mrbState = eControlMRBTimeEventMRBState.IDLE
		}
	)

	int localPlayerTeam = localPlayer.GetTeam()
	entity ornull currentMRBOwner

	while ( GetGameState() == eGameState.Playing && IsValid( localPlayer ) )
	{
		currentMRBOwner = Control_MRBTimedEvent_GetCurrentMRBOwner()
		shouldDisplayMapIcon = Control_IsLocalClientInMapCameraView()

		if ( currentMRBOwner == null || !shouldUpdateIconBasedOnMRBState ) // No one is holding the mrb, use default icon colors
		{
			if ( IsValid( localPlayer ) && IsValid( wp ) )
			{
				Control_MRBTimedEvent_SetMRBIconVisibility( inWorldIconRui, mapIconRui, mapIconEnemyRui, eControlMRBTimeEventMRBState.IDLE, !shouldDisplayMapIcon, shouldDisplayMapIcon, defaultIconZOffset )
				//MRB State
				if ( shouldUpdateIconBasedOnMRBState )
					file.mrbState = eControlMRBTimeEventMRBState.IDLE
			}
		}
		else if ( IsValid( currentMRBOwner ) && IsValid( localPlayer ) )
		{
			expect entity( currentMRBOwner )

			if ( currentMRBOwner == localPlayer ) // Player is holding mrb, don't show an in world icon
			{
				Control_MRBTimedEvent_SetMRBIconVisibility( inWorldIconRui, mapIconRui, mapIconEnemyRui, eControlMRBTimeEventMRBState.PERSONAL_HELD, false, shouldDisplayMapIcon, defaultIconZOffset )
				//MRB State
				if ( shouldUpdateIconBasedOnMRBState )
					file.mrbState = eControlMRBTimeEventMRBState.PERSONAL_HELD
			}
			else if ( IsFriendlyTeam( localPlayerTeam, currentMRBOwner.GetTeam() ) ) // Friendly is holding the mrb, show icon with friendly colors
			{
				Control_MRBTimedEvent_SetMRBIconVisibility( inWorldIconRui, mapIconRui, mapIconEnemyRui, eControlMRBTimeEventMRBState.FRIENDLY_HELD, !shouldDisplayMapIcon, shouldDisplayMapIcon, MRB_ICON_OFFSET_CARRIED )
				//MRB State
				if ( shouldUpdateIconBasedOnMRBState )
					file.mrbState = eControlMRBTimeEventMRBState.FRIENDLY_HELD
			}
			else // Enemy is holding the mrb, show icon with enemy colors
			{
				Control_MRBTimedEvent_SetMRBIconVisibility( inWorldIconRui, mapIconRui, mapIconEnemyRui, eControlMRBTimeEventMRBState.ENEMY_HELD, !shouldDisplayMapIcon, shouldDisplayMapIcon, MRB_ICON_OFFSET_CARRIED )
				//MRB State
				if ( shouldUpdateIconBasedOnMRBState )
					file.mrbState = eControlMRBTimeEventMRBState.ENEMY_HELD
			}
		}

		WaitFrame()

		localPlayer = GetLocalViewPlayer()
	}
}
#endif // CLIENT

#if CLIENT
// Set the color, icons, and visibility on mrb icons based on mrb state
void function Control_MRBTimedEvent_SetMRBIconVisibility( var inWorldIconRui, var mapIconRui, var mapIconEnemyRui, int mrbState, bool shouldShowInWorldIcon, bool shouldShowMapIcons, float zOffset )
{
	// In World Icon
	if ( IsValid( inWorldIconRui ) )
	{
		Control_MRBTimedEvent_SetMRBIconValues( inWorldIconRui, mrbState, false, false )
		RuiSetBool( inWorldIconRui, "isVisible", shouldShowInWorldIcon )
		RuiSetFloat( inWorldIconRui, "zOffset", zOffset )
	}

	// Map Icon
	if ( IsValid( mapIconRui ) )
	{
		Control_MRBTimedEvent_SetMRBIconValues( mapIconRui, mrbState, false, true )
		RuiSetBool( mapIconRui, "isVisible", shouldShowMapIcons )
	}

	// Enemy Map Icon
	if ( IsValid( mapIconEnemyRui ) )
	{
		if ( mrbState == eControlMRBTimeEventMRBState.ENEMY_HELD )
		{
			RuiSetBool( mapIconEnemyRui, "display", shouldShowMapIcons )
		}
		else
		{
			RuiSetBool( mapIconEnemyRui, "display", false )
		}
	}
}
#endif // CLIENT

#if CLIENT
// Set the color values and icons on the MRB Timed Event MRB and MRB Airdrop icon
const float MRB_MAP_ICON_SCALE_OVERALL = 0.6
const float MRB_ICON_DEFAULT_OBJECT_ALPHA = 0.75
const float MRB_ICON_DEFAULT_INNER_ALPHA = 0.6
const float MRB_ICON_DEFAULT_OUTLINE_ALPHA = 1.0
const float MRB_MAP_ICON_HELD_INNER_ALPHA = 1.0
const float MRB_ICON_DEFAULT_SHADOW_ALPHA = 0.2
void function Control_MRBTimedEvent_SetMRBIconValues( var rui, int mrbOwnershipState, bool shouldDoFullSetup, bool isMapIcon )
{
	vector defaultIconColor = SrgbToLinear( GetKeyColor( COLORID_DEFAULT ) / 255.0 )
	vector blackColor = SrgbToLinear( GetKeyColor( COLORID_COLORSWATCH_BLACK ) / 255.0 )
	vector greyColor = SrgbToLinear( <131, 134, 137> / 255.0 )
	vector whiteColor = SrgbToLinear( GetKeyColor( COLORID_COLORSWATCH_WHITE ) / 255.0 )
	vector friendlyIconColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED, true )
	vector enemyIconColor = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED, true )

	if ( shouldDoFullSetup )
	{
		RuiSetImage( rui, "objectIcon", CONTROL_MRB_INWORLD_ICON )
		RuiSetImage( rui, "objectBGIconOutline", CONTROL_MRB_DIAMOND_ICON_OUTLINE )
		RuiSetImage( rui, "objectBGIconShadow", CONTROL_MRB_DIAMOND_ICON_SHADOW )

		if ( isMapIcon )
			RuiSetFloat( rui, "overallElementScale", MRB_MAP_ICON_SCALE_OVERALL )
	}

	if ( isMapIcon )
	{
		switch( mrbOwnershipState )
		{
			case eControlMRBTimeEventMRBState.PERSONAL_HELD:
			case eControlMRBTimeEventMRBState.FRIENDLY_HELD:
			case eControlMRBTimeEventMRBState.ENEMY_HELD:
					RuiSetColorAlpha( rui, "objectColor", enemyIconColor, 0 )
					RuiSetImage( rui, "objectBGIconInner", CONTROL_MRB_HELD_OUTER_ICON )
					RuiSetColorAlpha( rui, "objectBGIconInnerColor", defaultIconColor, MRB_MAP_ICON_HELD_INNER_ALPHA )
					RuiSetColorAlpha( rui, "objectBGIconOutlineColor", friendlyIconColor, 0 )
					RuiSetColorAlpha( rui, "objectBGIconShadowColor", friendlyIconColor, 0 )
				break
			default:
				break
		}
	}

	switch( mrbOwnershipState )
	{
		case eControlMRBTimeEventMRBState.PERSONAL_HELD:
			break
		case eControlMRBTimeEventMRBState.FRIENDLY_HELD:
			if ( !isMapIcon )
			{
				RuiSetColorAlpha( rui, "objectBGIconInnerColor", friendlyIconColor, MRB_ICON_DEFAULT_INNER_ALPHA )
				RuiSetColorAlpha( rui, "objectBGIconOutlineColor", friendlyIconColor, MRB_ICON_DEFAULT_OUTLINE_ALPHA )
			}
			break
		case eControlMRBTimeEventMRBState.ENEMY_HELD:
			if ( !isMapIcon )
			{
				RuiSetColorAlpha( rui, "objectBGIconInnerColor", enemyIconColor, MRB_ICON_DEFAULT_INNER_ALPHA )
				RuiSetColorAlpha( rui, "objectBGIconOutlineColor", enemyIconColor, MRB_ICON_DEFAULT_OUTLINE_ALPHA )
			}
			break
		default:
			RuiSetColorAlpha( rui, "objectColor", defaultIconColor, MRB_ICON_DEFAULT_OBJECT_ALPHA )
			RuiSetImage( rui, "objectBGIconInner", CONTROL_MRB_DIAMOND_ICON )
			RuiSetColorAlpha( rui, "objectBGIconInnerColor", greyColor, MRB_ICON_DEFAULT_INNER_ALPHA )
			RuiSetColorAlpha( rui, "objectBGIconOutlineColor", whiteColor, MRB_ICON_DEFAULT_OUTLINE_ALPHA )
			RuiSetColorAlpha( rui, "objectBGIconShadowColor", blackColor, MRB_ICON_DEFAULT_SHADOW_ALPHA )
			break
	}
}
#endif // CLIENT

#if SERVER
const float MRB_SECURED_DIALOGUE_COOLDOWN = 45.0
// When the MRB is acquired, manage the mrb icon and give the mrb carrier EXP while holding the mrb
void function Control_MRBTimedEvent_OnMRBAcquired( entity mrbCarrier )
{
	if ( IsValid( mrbCarrier ) )
	{
		// Play MRB secured announcer dialogue if it hasn't played too recently
		if ( !GamemodeUtility_IsWinnerBeingDetermined() && Time() >= file.nextTimeAllowedToPlayMRBSecuredDialogue )
		{
			thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.CONTROL_MRB_TIMEDEVENT_MRB_SECURED ) )
			file.nextTimeAllowedToPlayMRBSecuredDialogue = Time() + MRB_SECURED_DIALOGUE_COOLDOWN
		}

		Remote_CallFunction_NonReplay( mrbCarrier, "ServerCallback_Control_MRBTimedEvent_OnMRBPickedUp" )

		if ( GetCurrentPlaylistVarInt( "exp_value_mrb_carrier", 5 ) > 0 )
			thread Control_MRBTimedEvent_GrantMRBPayloadEXP_Thread( mrbCarrier )

		thread Control_MRBTimedEvent_ManageMRBOwnerStatusEffect( mrbCarrier )
	}
}
#endif // SERVER

#if SERVER
// When the MRB is acquired, manage the status effect that controls the position revealed warning on the carriers screen
void function Control_MRBTimedEvent_ManageMRBOwnerStatusEffect( entity mrbCarrier )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( mrbCarrier ) )
		return

	int effectHandle = StatusEffect_AddEndless( mrbCarrier, eStatusEffect.mrb_carrier, 1.0 )

	mrbCarrier.EndSignal( "OnDeath" )
	mrbCarrier.EndSignal( "OnDestroy" )
	mrbCarrier.EndSignal( "Control_MRB_Dropped" )
	svGlobal.levelEnt.EndSignal( "Control_MRB_CalledIn" )

	OnThreadEnd(
		function() : ( mrbCarrier, effectHandle )
		{
			if ( IsValid( mrbCarrier ) )
				StatusEffect_Stop( mrbCarrier, effectHandle )
		}
	)

	wait CONTROL_MESSAGE_DURATION
}
#endif // SERVER

#if CLIENT || SERVER
entity ornull function Control_MRBTimedEvent_GetCurrentMRBOwner()
{
	#if SERVER
		return file.activeMRBOwner
	#endif // SERVER

	#if CLIENT
		return GetGlobalNetEntSafe( PLAYER_WITH_MRB_NET_NAME )
	#endif // CLIENT
}
#endif // CLIENT || SERVER

#if CLIENT
// After we give a player the MRB trigger the thread that manages use reminder messages
void function ServerCallback_Control_MRBTimedEvent_OnMRBPickedUp()
{
	thread Control_ManageMRBUseReminder_Thread()
}
#endif // CLIENT

#if CLIENT
// After we give a player the MRB, remind them that they are carrying it after some time if they have not used it
const float CONTROL_MRB_TIME_TO_USE_HINT = 45.0
const float CONTROL_MRB_FIRST_USE_HINT_DELAY = CONTROL_MESSAGE_DURATION
void function Control_ManageMRBUseReminder_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	localPlayer.EndSignal( "OnDestroy" )
	localPlayer.EndSignal( "OnDeath" )

	entity ornull mrbOwner

	wait CONTROL_MRB_FIRST_USE_HINT_DELAY

	localPlayer = GetLocalViewPlayer()

	// Display a hint as soon as the MRB is first given and then show the hint again at intervals
	while( IsValid( localPlayer ) )
	{
		// On Each Loop check if the local Player is still the MRB Owner
		mrbOwner = Control_MRBTimedEvent_GetCurrentMRBOwner()

		if ( mrbOwner == null || !IsValid( mrbOwner ) )
			return

		if ( localPlayer != mrbOwner )
			return

		// Display a use MRB Hint
		if ( IsControllerModeActive() )
		{
			int useSurvivalSlotButton = GetConVarInt( "gamepad_toggle_survivalSlot_to_weaponInspect" )

			if ( useSurvivalSlotButton == 0 ) //0 = Survival Slot / 1 = Weapon Inspect
				AnnouncementMessageRight( localPlayer, "#CONTROL_HINT_USE_MRB_CONSOLE" , "Void Ring Warning", <1, 1, 1> )
		}
		else
		{
			AnnouncementMessageRight( localPlayer, "#CONTROL_HINT_USE_MRB_PC" , "Void Ring Warning", <1, 1, 1> )
		}

		// Wait the time interval before displaying the hint again
		wait CONTROL_MRB_TIME_TO_USE_HINT

		localPlayer = GetLocalViewPlayer()
	}
}
#endif // CLIENT

#if SERVER
const float CONTROL_MRBCARRIER_EXP_GRANT_INTERVAL = 5.0
// Award EXP while the MRB is being held by a player.
void function Control_MRBTimedEvent_GrantMRBPayloadEXP_Thread( entity mrbCarrier )
{
	Assert( IsNewThread(), "Must be threaded off" )

	// function is currently only used to award EXP, if we are not using EXP break out now
	if ( !Control_GetIsWeaponEvoEnabled() )
		return

	mrbCarrier.EndSignal( "OnDeath" )
	mrbCarrier.EndSignal( "OnDestroy" )
	mrbCarrier.EndSignal( "Control_MRB_Dropped" )
	svGlobal.levelEnt.EndSignal( "Control_MRB_CalledIn" )

	int mrbCarrierEXPVal = GetCurrentPlaylistVarInt( "exp_value_mrb_carrier", 5 )

	while( true )
	{
		wait CONTROL_MRBCARRIER_EXP_GRANT_INTERVAL
		Control_AddScore( mrbCarrier, CONTROL_EXPEVENT_MRBCARRIER, mrbCarrierEXPVal, true, true )
		Control_AwardWithSquadScoreBonusExp( mrbCarrier )
	}
}
#endif // SERVER

#if SERVER
// When the MRB is dropped, kill the EXP gain thread
void function Control_MRBTimedEvent_OnMRBDropped( entity mrbCarrier, entity mrb )
{
	printt( "CONTROL: MRB Event, MRB Dropped" )

	if ( IsValid( mrbCarrier ) )
		Signal( mrbCarrier, "Control_MRB_Dropped" )

	file.activeMRBOwner = null
	SetGlobalNetEnt( PLAYER_WITH_MRB_NET_NAME, null )
	file.activeMRBSurvivalItem = mrb

	if ( IsValid( file.activeMRBWaypoint ) )
	{
		file.activeMRBWaypoint.SetParent( mrb )
		file.activeMRBWaypoint.SetAbsOrigin( mrb.GetOrigin() )
	}

	thread Control_ManageMRBItemLocationReset_Thread(  mrb )
}
#endif // SERVER

#if SERVER
// Check for a player picking up an MRB so we can set who is currently holding it
void function Control_OnPlayerLootPickup( entity player, entity pickup, string ref, int unitsPickedUp, bool willDestroy, entity deathBox, int pickupFlags )
{
	if ( !IsValid( player ) )
		return

	if ( !Control_MRBTimedEvent_IsEventActive() )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )

	if ( !IsValid( data ) )
		return

	if ( ref == MRB_WEAPON_REF_NAME)
	{
		Signal( pickup, "Control_MRB_PickedUp" )
		file.activeMRBOwner = player
		if ( IsValid( file.activeMRBWaypoint ) )
		{
			file.activeMRBWaypoint.SetParent( file.activeMRBOwner )
			file.activeMRBWaypoint.SetAbsOrigin( file.activeMRBOwner.GetOrigin() )
		}
		file.activeMRBSurvivalItem = null

		SetGlobalNetEnt( PLAYER_WITH_MRB_NET_NAME, player )
		Control_MRBTimedEvent_OnMRBAcquired( player )
	}
}
#endif // SERVER

#if SERVER
const float MRB_RESET_TIME = 60.0
// When the MRB is dropped, manage whether it should reset to its spawn position in case it gets into a bad spot
void function Control_ManageMRBItemLocationReset_Thread( entity mrb )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( mrb ) )
		return

	if ( !Control_MRBTimedEvent_IsEventActive() )
		return

	mrb.EndSignal( "Control_MRB_PickedUp" )

	wait MRB_RESET_TIME

	if ( IsValid( mrb ) )
	{
		printt( "CONTROL: MRB Event, Resetting dropped MRB Position" )

		mrb.ClearParent() // We don't parent anything to the MRB for our own logic. There is world logic where the MRB will be parented to a moving object if it is dropped on it. Clear the parent before resetting the MRB
		mrb.SetOrigin( file.mrbSpawnPosition )
		mrb.SetAngles( file.mrbSpawnAngles )
	}
}
#endif // SERVER

#if CLIENT || SERVER
const float MIN_DIST_FROM_FRIENDLY_HOMEBASE = 2000.0
const float MIN_DIST_FROM_ENEMY_HOMEBASE = 2400.0
const float MIN_DIST_FROM_OBJECTIVES = 1000.0
const bool SHOULD_DO_OBJECTIVE_TESTS = true // We already have bad airdrop places on Objectives but if we decide to do larger distances we can turn this on
const float POSITION_VALIDATION_FAILED_HINT_DURATION = 0.2
const float POSITION_VALIDATION_FAILED_HINT_FADEOUT_TIME = 0.25
const string [eControlMRBPlacementState._count] PLACEMENT_STATE_STRINGS = [
"",
"#CONTROL_MRB_PLACEMENT_FAIL_GENERIC",
"#CONTROL_MRB_PLACEMENT_FAIL_OBJECTIVE",
"#CONTROL_MRB_PLACEMENT_FAIL_HOMEBASE",
"#CONTROL_MRB_PLACEMENT_FAIL_HOMEBASE_ENEMY"]
// Do the same checks the normal mrb deploy function does but then do some extra Control only checks to prevent players from spawning in undesirable locations
CarePackagePlacementInfo function Control_MRBTimedEvent_MRBDeployPositionValidation( entity player )
{
	CarePackagePlacementInfo placementInfo = GetCarePackagePlacementInfo( player )

	// If the player is not valid, return the placementInfo right away
	if ( !IsValid( player ) )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: MRB Event, MRB Deployment failing because player is Invalid" )
		#endif // DEV
		return placementInfo
	}

	// Do the objective and home base spawn checks first since they are radius based checks
	// Clearer to player to know it failed for these reasons rather than getting a bad position hint when they are also too close to an objective
	int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	int placementState = eControlMRBPlacementState.SUCCESS

	// Check if the position is too close to locations around Alliance A Home Base
	bool isEnemyHomebase = playerAlliance == ALLIANCE_A ? false : true
	float minDistFromHomeBase = isEnemyHomebase ? MIN_DIST_FROM_ENEMY_HOMEBASE : MIN_DIST_FROM_FRIENDLY_HOMEBASE
	placementState = Control_GetMRBPlacementStateFromHomeBasePositionChecks( placementState, isEnemyHomebase, minDistFromHomeBase, file.allianceABlockedHomeBasePositionsForMRB, placementInfo.origin )

	// if the Alliance A Home Base checks didn't fail, test for Alliance B Home Base locations
	if ( placementState == eControlMRBPlacementState.SUCCESS )
	{
		isEnemyHomebase = playerAlliance == ALLIANCE_B ? false : true
		minDistFromHomeBase = isEnemyHomebase ? MIN_DIST_FROM_ENEMY_HOMEBASE : MIN_DIST_FROM_FRIENDLY_HOMEBASE
		placementState = Control_GetMRBPlacementStateFromHomeBasePositionChecks( placementState, isEnemyHomebase, minDistFromHomeBase, file.allianceBBlockedHomeBasePositionsForMRB, placementInfo.origin )
	}

	// Set placement info to failed if the above checks failed
	if ( placementState != eControlMRBPlacementState.SUCCESS )
		placementInfo.failed = true

	// If we didn't fail homebase checks, do checks for the position being too close to Objectives
	if ( SHOULD_DO_OBJECTIVE_TESTS && placementState == eControlMRBPlacementState.SUCCESS )
	{
		foreach ( point in file.spawnWaypoints )
		{
			if ( IsValid( point ) )
			{
				int waypointTypeIndex = point.GetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX )
				if ( Control_IsSpawnWaypointIndexAnObjective( waypointTypeIndex ) )
				{
					#if DEV
						if ( CONTROL_DISPLAY_DEBUG_DRAWS )
							DebugDrawSphere( point.GetOrigin(), MIN_DIST_FROM_OBJECTIVES, COLOR_RED, true, 1.0 )
					#endif // DEV
					if ( IsPositionWithinRadius( MIN_DIST_FROM_OBJECTIVES, point.GetOrigin(), placementInfo.origin ) ) // Don't allow placement close to objectives
					{
						placementInfo.failed = true
						placementState = eControlMRBPlacementState.NEAR_OBJECTIVE
						#if DEV
							if ( CONTROL_DETAILED_DEBUG )
								printt( "CONTROL: MRB Event, MRB Deployment failing because of proximity to an Objective" )
						#endif // DEV
						break
					}
				}
			}
		}
	}

	// If the position didn't fail any of the Control specific tests, check if it failed the regular test
	if ( placementInfo.failed && placementState == eControlMRBPlacementState.SUCCESS )
	{
		#if DEV
			if ( CONTROL_DETAILED_DEBUG )
				printt( "CONTROL: MRB Event, MRB Deployment failing regular Airdrop tests" )
		#endif // DEV
		placementState = eControlMRBPlacementState.BAD_POSITION
	}

	#if CLIENT
		// Display a hint message if the MRB can't be placed
		if ( placementState != eControlMRBPlacementState.SUCCESS )
			AddPlayerHint( POSITION_VALIDATION_FAILED_HINT_DURATION,POSITION_VALIDATION_FAILED_HINT_FADEOUT_TIME, $"", PLACEMENT_STATE_STRINGS[ placementState ] )
	#endif // CLIENT

	return placementInfo
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Check if the MRB position is too close to locations around a HomeBase
int function Control_GetMRBPlacementStateFromHomeBasePositionChecks( int currentPlacementState, bool isEnemyHomebase, float minDistFromHomeBase, array< vector > homebasePositions, vector mrbPosition )
{
	int placementState = currentPlacementState
	// Check if the position is too close to locations around Home Base
	foreach ( position in homebasePositions )
	{
		#if DEV
			if ( CONTROL_DISPLAY_DEBUG_DRAWS )
				DebugDrawSphere( position, minDistFromHomeBase, COLOR_RED, true, 1.0 )
		#endif // DEV

		if ( IsPositionWithinRadius( minDistFromHomeBase, position, mrbPosition ) ) // Don't allow placement close to HomeBase
		{
			placementState = isEnemyHomebase ? eControlMRBPlacementState.NEAR_HOMEBASE_ENEMY : eControlMRBPlacementState.NEAR_HOMEBASE

			#if DEV
				if ( CONTROL_DETAILED_DEBUG )
				{
					string debugHomeBaseString = isEnemyHomebase ? "Enemy" : "Friendly"
					printt( "CONTROL: MRB Event, MRB Deployment failing because of proximity to ", debugHomeBaseString, " Homebase, Base Pos: ", position )
				}
			#endif // DEV
			break
		}
	}

	return placementState
}
#endif // CLIENT || SERVER

#if SERVER
// If we are in the MRB Timed Event, set that the MRB is used by a player
// Also set the alliance for the MRB that gets spawned in so we know which team gets to use it
void function Control_MRBTimedEvent_OnMRBDeployTriggered( entity ownerPlayer )
{
	if ( Control_MRBTimedEvent_IsEventActive() )
	{
		if ( IsValid( ownerPlayer ) )
		{
			file.activeMRBAllianceOwner = AllianceProximity_GetAllianceFromTeam( ownerPlayer.GetTeam() )

			// Give the player that calls in the MRB some EXP
			if ( Control_GetIsWeaponEvoEnabled() )
			{
				Control_AddScore( ownerPlayer, CONTROL_EXPEVENT_MRBDEPLOYED, GetCurrentPlaylistVarInt( "exp_value_mrb_deployed", 50 ), true, true )
				Control_AwardWithSquadScoreBonusExp( ownerPlayer )
			}
		}
		else // If we don't have a valid owner we won't create a spawn point and will just end the event
		{
			//ToDo Dswieczko: This should never happen but look at making sure the MRB that landed gets destroyed and maybe put the MRB back in play instead of killing the event?
			file.activeMRBAllianceOwner = ALLIANCE_NONE
		}

		file.activeMRBOwner = null
		SetGlobalNetEnt( PLAYER_WITH_MRB_NET_NAME, null )
		file.activeMRBSurvivalItem = null

		if ( IsValid( file.activeMRBWaypoint ) )
		{
			file.activeMRBWaypoint.Destroy()
			file.activeMRBWaypoint = null
		}

		// Trigger this signal even if the player is not valid so we clean things up
		Signal( svGlobal.levelEnt, "Control_MRB_CalledIn" )
	}
}
#endif // SERVER

#if SERVER
// This gets called when the respawn beacon gets called in and lands. Here we set the owner of the mrb and get spawn point setup
void function Control_MRBEntity_Spawned( entity ent )
{
	if ( IsValid( ent ) && ent.GetTargetName() == MOBILE_RESPAWN_BEACON_TARGETNAME )
	{
		// Only set the spawn point if a valid team deployed the MRB
		if ( file.activeMRBAllianceOwner != ALLIANCE_NONE )
		{
			file.activeMRB = ent
			int beaconTeam = AllianceProximity_GetRepresentativeTeamForAlliance( file.activeMRBAllianceOwner )
			SetTeam( ent, beaconTeam )
			Highlight_SetEnemyHighlight( ent, "dropship_enemy" )
			Highlight_SetFriendlyHighlight( ent, "dropship_friendly" )
			entity spawnWaypoint = SetupSpawnOnActiveMRBWaypoint( file.activeMRBAllianceOwner )
			file.spawnWaypoints[ eControlWaypointTypeIndex.MRB_SPAWN ] = spawnWaypoint
		}

		Signal( svGlobal.levelEnt, "Control_MRB_Deployed" )
	}
}
#endif // SERVER

#if SERVER
// Set the MRB up so players on the same alliance can spawn on it
entity function SetupSpawnOnActiveMRBWaypoint( int alliance )
{
	entity mrbEnt = file.activeMRB
	entity spawnWP = CreateWaypoint_BasicEntLocation( mrbEnt, ePingType.NON_PINGABLE_SPAWN_LOCATION )
	spawnWP.SetParent( mrbEnt )
	spawnWP.SetLocalOrigin( <0, 0, 256> )

	spawnWP.SetWaypointInt( INT_CONTROL_WAYPOINT_TYPE_INDEX, eControlWaypointTypeIndex.MRB_SPAWN )
	spawnWP.SetWaypointInt( CONTROL_WAYPOINT_ALLIANCE_OWNER_INDEX, alliance )

	return spawnWP
}
#endif // SERVER

#if SERVER
// Update spawn availability when the MRB gets destroyed
void function Control_DestroyMRB()
{
	entity mrbEnt = file.activeMRB
	//check if the MRB was already selected as a spawn point when it got destroyed
	foreach ( player in GetPlayerArray() )
	{
		if ( player in file.playerToRespawnChoice && file.playerToRespawnChoice[ player ] == eControlWaypointTypeIndex.MRB_SPAWN )
			Control_CancelRespawnChoiceOnSpawnpointAvailabilityChange( player, eControlWaypointTypeIndex.MRB_SPAWN )
	}

	if ( IsValid( mrbEnt ) )
		mrbEnt.Destroy()

	file.activeMRB = null
	file.activeMRBOwner = null
	file.spawnWaypoints[ eControlWaypointTypeIndex.MRB_SPAWN ] = null
	SetGlobalNetEnt( PLAYER_WITH_MRB_NET_NAME, null )
	file.activeMRBAllianceOwner = ALLIANCE_NONE

	if ( IsValid( file.activeMRBWaypoint ) )
	{
		file.activeMRBWaypoint.Destroy()
		file.activeMRBWaypoint = null
	}

	if ( IsValid( file.activeMRBSurvivalItem ) )
		file.activeMRBSurvivalItem = null
}
#endif // SERVER

/*
	  _____  ______ ____  _    _  _____
	 |  __ \|  ____|  _ \| |  | |/ ____|
	 | |  | | |__  | |_) | |  | | |  __
	 | |  | |  __| |  _ <| |  | | | |_ |
	 | |__| | |____| |_) | |__| | |__| |
	 |_____/|______|____/ \____/ \_____|

	DEV DEBUG COMMANDS
*/

#if SERVER
// Debug print to try and find the cause of R5DEV-429111
// Will remove once the bug is fixed
void function Control_PrintSkydiveDebug( entity player, string message )
{
	// Only need these prints in Control Mode
	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	if ( IsValid( player ) )
		printt( "R5DEV-429111: ", player, message )
	else
		printt( "R5DEV-429111: PlayerInvalid", message )
}
#endif // SERVER

#if SERVER || CLIENT
// Debug print function for spawn related prints
void function Control_PrintSpawningDebug( entity player, int respawnChoice, entity entityToSpawnOn, bool didFunctionHaveEntToSpawnOn, string message )
{
	// Only need these prints in Control Mode
	if ( !GameMode_IsActive( eGameModes.CONTROL ) )
		return

	// Only trigger when we want player spawn debug prints
	if ( !CONTROL_PLAYER_SPAWN_DEBUG_PRINTS )
		return

	string respawnChoiceString = Control_GetDebugStringForRespawnChoiceInt( respawnChoice )
	string playerEntString = IsValid( player ) ? string( player ) : "PlayerInvalid"
	string entToSpawnOnString = "none"

	if ( didFunctionHaveEntToSpawnOn )
		entToSpawnOnString = IsValid( entityToSpawnOn ) ? string( entityToSpawnOn ) : "EntityToSpawnOnInvalid"

	printt( "CONTROL: ", message, " for player: ", playerEntString, " respawnChoice: ", respawnChoiceString, " entityToSpawnOn: ", entToSpawnOnString )
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Get a debug ( non localized ) string for the respawn choice
string function Control_GetDebugStringForRespawnChoiceInt( int respawnChoice )
{
	string respawnChoiceString = "unset"
	switch( respawnChoice )
	{
		case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_A:
			respawnChoiceString = "Homebase A"
			break
		case eControlWaypointTypeIndex.HOMEBASE_ALLIANCE_B:
			respawnChoiceString = "Homebase B"
			break
		case eControlWaypointTypeIndex.OBJECTIVE_A:
			respawnChoiceString = "Objective A"
			break
		case eControlWaypointTypeIndex.OBJECTIVE_B:
			respawnChoiceString = "Objective B"
			break
		case eControlWaypointTypeIndex.OBJECTIVE_C:
			respawnChoiceString = "Objective C"
			break
		case eControlWaypointTypeIndex.MRB_SPAWN:
			respawnChoiceString = "MRB"
			break
		case eControlWaypointTypeIndex.SQUAD_SPAWN:
			respawnChoiceString = "Squad"
			break
		default:
			respawnChoiceString = "Unsupported"
			break
	}

	return respawnChoiceString
}
#endif // SERVER || CLIENT

#if DEVELOPER && SERVER
// Give the player the amount of EXP passed in
void function Control_ForceGiveExp_Dev( int expAmount = 10, bool giveToAllPlayers = false )
{
	if ( giveToAllPlayers )
	{
		foreach ( alivePlayer in GetPlayerArray_Alive() )
		{
			if ( IsValid( alivePlayer ) && IsAlive( alivePlayer ) )
				Control_AddScore( alivePlayer, CONTROL_EXPEVENT_CAPTURED, expAmount, true, true )
		}
	}
	else
	{
		entity player = GetPlayerArray()[0]
		if ( IsValid( player ) && IsAlive( player ) )
			Control_AddScore( player, CONTROL_EXPEVENT_CAPTURED, expAmount, true, true )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Give the player enough EXP to increase their EXP Tier to the next Tier
void function Control_ForceExpTierUp_Dev( bool levelUpAllPlayers = false )
{
	int expToNextTier = 0

	if ( levelUpAllPlayers )
	{
		foreach ( alivePlayer in GetPlayerArray_Alive() )
		{
			if ( IsValid( alivePlayer ) && IsAlive( alivePlayer ) )
			{
				expToNextTier = Control_GetExpToNextExpTier( alivePlayer )
				Control_AddScore( alivePlayer, CONTROL_EXPEVENT_CAPTURED, expToNextTier, true, true )
			}
		}
	}
	else
	{
		entity player = GetPlayerArray()[0]
		if ( IsValid( player ) && IsAlive( player ) )
		{
			expToNextTier = Control_GetExpToNextExpTier( player )
			Control_AddScore( player, CONTROL_EXPEVENT_CAPTURED, expToNextTier, true, true )
		}
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Force a lockout
void function Control_ForceLockOutBegin_Dev( int alliance = ALLIANCE_NONE )
{
	// By default use the only players (or first players ) alliance.
	if ( alliance != ALLIANCE_A && alliance != ALLIANCE_B )
	{
		entity player = GetPlayerArray()[0]
		if ( !IsValid( player ) )
		{
			printt("CONTROL: Control_ForceLockOutBegin_Dev tried to use a player alliance because no valid alliance was passed in, BUT no valid player was found")
			return
		}
		alliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	}

	foreach( point in file.chosenVariantData.controlPoints )
	{
		point.controlPointOwner = alliance
		point.controlPointPercent = 1
		point.currentObjectiveState = eControlPointObjectiveState.CONTROLLED
		point.lastCapturingAlliance = alliance
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Force Abort a lockout
void function Control_ForceLockoutAbort_Dev()
{
	if ( file.chosenVariantData.controlPoints.len() <= 0 )
	{
		printt( "CONTROL: Control_ForceLockoutAbort_Dev failed to find any points to capture, can't abort lockout" )
	}

	Control_ForceCaptureObjective_Dev( CaptureObjectivePing_GetObjectiveNameFromObjectiveID_UnLocalized( eControlWaypointTypeIndex.OBJECTIVE_A ) )
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Force Capture an Objective
void function Control_ForceCaptureObjective_Dev( string pointName, int alliance = ALLIANCE_NONE )
{
	if ( file.chosenVariantData.controlPoints.len() <= 0 )
	{
		printt("CONTROL: Control_ForceCaptureObjective_Dev failed to find any points to capture")
	}

	ControlPointData pointToCapture
	foreach( point in file.chosenVariantData.controlPoints )
	{
		if ( point.name.tolower() == pointName.tolower() )
		{
			pointToCapture = point
			break
		}
	}

	if ( IsValid( pointToCapture.waypoint ) )
	{
		// By default capture the point to the opposite Alliance, but if it is neutral, capture it for the first player in the game
		if ( alliance != ALLIANCE_A && alliance != ALLIANCE_B )
		{
			if ( pointToCapture.controlPointOwner != ALLIANCE_NONE )
			{
				alliance = pointToCapture.controlPointOwner == ALLIANCE_A ? ALLIANCE_B : ALLIANCE_A
			}
			else
			{
				entity player = GetPlayerArray()[0]
				if ( !IsValid( player ) )
				{
					printt("CONTROL: Control_ForceCaptureObjective_Dev tried to use a player alliance because no valid alliance was passed in, BUT no valid player was found")
					return
				}
				alliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
			}
		}

		pointToCapture.controlPointOwner = alliance
		pointToCapture.controlPointPercent = 1
		pointToCapture.currentObjectiveState = eControlPointObjectiveState.CONTROLLED
		pointToCapture.lastCapturingAlliance = alliance
	}
	else
	{
		printt("CONTROL: Control_ForceCaptureObjective_Dev failed to find a control point named ", pointName )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Force Neutralize an Objective
void function Control_ForceNeutralizeObjective_Dev( string pointName )
{
	if ( file.chosenVariantData.controlPoints.len() <= 0 )
	{
		printt("CONTROL: Control_ForceNeutralizeObjective_Dev failed to find any points to neutralize")
	}

	ControlPointData pointToCapture
	foreach( point in file.chosenVariantData.controlPoints )
	{
		if ( point.name.tolower() == pointName.tolower() )
		{
			pointToCapture = point
			break
		}
	}

	if ( IsValid( pointToCapture.waypoint ) )
	{
		pointToCapture.controlPointOwner = ALLIANCE_NONE
		pointToCapture.controlPointPercent = 0
		pointToCapture.currentObjectiveState = eControlPointObjectiveState.CONTROLLED
		pointToCapture.lastCapturingAlliance = ALLIANCE_NONE
	}
	else
	{
		printt("CONTROL: Control_ForceNeutralizeObjective_Dev failed to find a control point named ", pointName )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Force Set the Score of an Alliance
void function Control_ForceSetAllianceScore_Dev( int alliance = ALLIANCE_NONE, int score = 0 )
{
	if ( score < 0 )
	{
		printt("CONTROL: Control_ForceSetAllianceScore_Dev passed in score is less than 0" )
		return
	}

	if ( alliance != ALLIANCE_A && alliance != ALLIANCE_B )
	{
		entity player = GetPlayerArray()[0]
		if ( !IsValid( player ) )
		{
			printt( "CONTROL: Control_ForceSetAllianceScore_Dev tried to use a player alliance because no valid alliance was passed in, BUT no valid player was found" )
			return
		}
		alliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	}

	int newScore = minint( score, GetScoreLimit_FromPlaylist() )
	SetAllianceTeamsScore( alliance, newScore )
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Stop score accumulation or resume it
void function Control_ForcePauseOrResumeScoring_Dev()
{
	file.isScoringPaused = file.isScoringPaused ? false : true
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Force the game to end
void function Control_ForceEndMatch_Dev( int winningAlliance = ALLIANCE_NONE, int victoryCondition = eWinReason.SCORE_LIMIT )
{
	if ( victoryCondition < 0 || victoryCondition >= eWinReason._count )
	{
		printt( "CONTROL: Control_ForceEndMatch_Dev passed in victoryCondition: ", victoryCondition, " is not valid. Use ", eWinReason.DEFAULT, " for UNKOWN, ", eWinReason.SCORE_LIMIT, " for Score, ", eWinReason.LOCKOUT, " for Lockout, ", eWinReason.TEAM_FORFEIT, " for team forfeit.")
		return
	}

	// By default use the only players (or first players ) alliance.
	if ( winningAlliance != ALLIANCE_A && winningAlliance != ALLIANCE_B )
	{
		entity player = GetPlayerArray()[0]
		if ( !IsValid( player ) )
		{
			printt( "CONTROL: Control_ForceEndMatch_Dev tried to use a player alliance because no valid alliance was passed in, BUT no valid player was found" )
			return
		}
		winningAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	}

	printt( "CONTROL: Match Ending due to debug dev command" )
	Control_SetWinner( winningAlliance, victoryCondition )
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Debug command to Kill the player and then set them as if they just connected to the match as a Join In Progress Player
void function Control_FakeJoinInProgressFlow_Dev( bool forceOnAllPlayers = false )
{
	array<entity> players

	if ( forceOnAllPlayers )
	{
		players = GetPlayerArray_Alive()
	}
	else
	{
		players.append( GetPlayerArray_Alive()[0] )
	}

	foreach ( player in players )
	{
		thread Control_ExecuteFakeJoinInProgressFlow_Dev_Thread( player )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Kill the player and then set them as if they just connected to the match as a Join In Progress Player once they reach the spawn screen
void function Control_ExecuteFakeJoinInProgressFlow_Dev_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	player.EndSignal( "Control_Dev_PlayerReachedSpawnSelect" )
	player.EndSignal( "OnDestroy" )
	EndSignal( svGlobal.levelEnt, GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
				GamemodeUtility_SetJIPPlayerIsWaitingForSpawnBonus( player, true )

				foreach ( alliancePlayer in AllianceProximity_GetAllPlayersInAlliance( playerAlliance, false ) )
				{
					Remote_CallFunction_NonReplay( alliancePlayer, "GamemodeUtility_ServerCallback_PlayerJoinedMatchInProgress" )
					Remote_CallFunction_NonReplay( player, "ServerCallback_Control_ShowSpawnSelection" )
				}
			}
		}
	)

	// If the player is alive, kill them
	if ( IsAlive( player ) )
		player.Die()

	// If the player isn't on the spawn select screen wait for the signal to come in telling us they are
	if ( !player.GetPlayerNetBool( "control_IsPlayerOnSpawnSelectScreen" ) )
		WaitForever()
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Set a specific spawn point index to test spawning on specific spawns instead of allowing the spawn system to choose the best spawn for the player.
// Helpful when testing stuff like spawning on the Hover tank in Caustic TT which doesn't happen frequently but can be forced by setting the index to 33.
void function Control_SetForcedSpawnPointIndex_Dev( int spawnPointIndex = -1 )
{
	file.testingSpawnPointIndex = spawnPointIndex
	printt( "CONTROL: Setting the debug forced spawn point index to: ", file.testingSpawnPointIndex )

	if ( spawnPointIndex < 0 )
		printt( "CONTROL: Note the newly set debug forced spawn point index is less than 0 so spawnpoints will be selected as normal ( forced spawn is not set )" )
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Trigger a timed event
void function Control_ForceTriggerTimedEvent_Dev( int eventType = eControlTimedEventType.BOUNTY )
{
	if ( eventType < 0 || eventType >= eControlTimedEventType._count )
	{
		printt( "CONTROL: Control_ForceTriggerTimedEvent_Dev passed in eventType is not valid. See eControlTimedEventType for valid events" )
	}

	// This event seems messed up when not properly setting the points to captured, so just trigger our other dev function
	if ( eventType == eControlTimedEventType.LOCKOUT )
	{
		Control_ForceLockOutBegin_Dev()
		return
	}
	else
	{
		TimedEvents_TriggerTimedEventByEventType( eventType )
	}
}
#endif // #if DEV && SERVER