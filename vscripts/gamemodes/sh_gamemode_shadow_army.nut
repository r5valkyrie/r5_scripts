                            
/*
This is a Survival LTM where 10 squads start on a Rev Alliance and 10 squads start on the Legend Alliance
 - If a Living Legend dies, they can be respawned from Respawn Beacons ( See shadow_army_respawn_beacon.nut )
 - If a Living Legend squad is eliminated, they all respawn as Rev Army Revenants on the Rev Army Alliance
 - If a Revenant Player dies, they respawn after 20 secs as a Rev Army Revenant and will continue to respawn as one
 - Revenant Army players win if they Eliminate all Legends or prevent them from Evac
 - Living Legends win if the required number of players Evac
 - Evac can be triggered in 2 ways:
	 - Time to Evac Reaches 0 ( starts at 10 mins )
	 - Living Legends are down to 3 squads remaining
 - Evac Location is revealed to Legends right away ( first as a general area on the map, eventually the exact location )
 - All Revenant Army players are Rev Army Revs ( melee )
 - 1 Rev Army player at a time can be the Red Eyed Rev ( drops with high tier equipment, armor, and weapons), is marked for whole lobby
*/

global function ShadowArmy_Init
global function IsShadowArmyGamemodeCineVersion
global function ShadowArmy_GetNumRevSquadsForMatchStart

#if SERVER
global function ShadowArmy_GenerateSingleRevArmyPlanePath
global function ShadowArmy_IsSquadReallyEliminated
global function ShadowArmy_DisplayMessageForAllPlayers
global function ShadowArmy_SetupRevenantDropship
global function ShadowArmy_GetAllianceToPlaneIndexAssignment
global function ShadowArmy_GetShouldLegendsSpawnOnGround_MatchStart
global function ShadowArmy_GetLegendMatchStartSpawnLocations
global function ShadowArmy_GetLegendMatchStartSpawnRadius
global function ShadowArmy_StorePlayersOriginalCharacterSelection
global function ShadowArmy_GetCurrentRank
#endif

#if CLIENT
global function ShadowArmy_ServerCallback_ShowAnnouncementMessage
global function ShadowArmy_ServerCallback_ShowHinttMessage
global function ShadowArmy_ServerCallback_GivePlayerRepeatingEnemyMapScans
global function ShadowArmy_ServerCallback_UpdateEvacTargetCountOnHud
global function ShadowArmy_ServerCallback_SetDeathScreenCallbacks
global function ShadowArmy_ServerCallback_PlayMatchEndMusic
global function ShadowArmy_ServerCallback_SetAllianceAssignmentCompleteFlag
global function ShadowArmy_ServerCallback_DestroyLegendStartAreaMapFeature
global function ShadowArmy_PlayIntroBannerSoundForLegends_Thread
#endif

#if SERVER || CLIENT
global function ShadowArmy_ShouldEnterBleedout
global function ShadowArmy_IsPlayerOnShadowArmy
global function ShadowArmy_IsPlayerInShadowForm
global function ShadowArmy_GetEnemySquadPlayersForAllianceIntro
global function ShadowArmy_GetLegendSpawnGroupsNumber
#endif // SERVER || CLIENT

#if UI
global function ShadowArmy_PopulateAboutText
#endif // UI

#if DEVELOPER && SERVER
global function ShadowArmy_SetPlayerToFullRev_Dev
global function ShadowArmy_TriggerEvacShipsAtAllLocations_Dev
global function ShadowArmy_TriggerEvacPhase_Dev
global function ShadowArmy_TriggerMatchEnd_Dev
#endif // DEV && SERVER

#if SERVER || CLIENT
global const float SHADOWARMY_LEGEND_SPAWN_FADE_FROM_BLACK_HOLD_DURATION = 1.0
global const float SHADOWARMY_LEGEND_SPAWN_FADE_FROM_BLACK_FADE_DURATION = 2.0

const int SHADOWARMY_VICTORY_FLAGS_UNKNOWN = 0
const int SHADOWARMY_VICTORY_FLAGS_ELIMINATION = ( 1 << 1 )
global const int SHADOWARMY_VICTORY_FLAGS_EVAC = ( 1 << 2 )
const int SHADOWARMY_VICTORY_FLAGS_PREVENTED_EVAC = ( 1 << 3 )
const int SHADOWARMY_VICTORY_FLAGS_FORFEIT = ( 1 << 4 )

const float SHADOWARMY_DEFAULT_SHORT_SPAWN_DELAY = 5.0
const float SHADOWARMY_SHORTEST_POSSIBLE_SPAWN_DELAY = 1.0
const array < int > SHADOW_ARMY_ALLOWED_ALLIANCE_PINGS = [ ePingType.BLEEDOUT ]
#endif // SERVER || CLIENT

global const string SHADOWARMY_MAP_EVAC_AREA = "shadowarmy_evac_area"
global const string SHADOWARMY_LEGEND_START_AREA = "shadowarmy_legend_start_area"
const string SHADOWARMY_PIN_VICTORYCONDITION_UNKNOWN = "unknown"
const string SHADOWARMY_PIN_VICTORYCONDITION_ELIMINATION = "elimination"
const string SHADOWARMY_PIN_VICTORYCONDITION_EVAC = "evac"
const string SHADOWARMY_PIN_VICTORYCONDITION_PREVENTED_EVAC = "prevented_evac"
const string SHADOWARMY_PIN_VICTORYCONDITION_FORFEIT = "team_forfeit"

const asset DEATH_SCREEN_RUI = $"ui/shadowarmy_squad_summary_header_data.rpak"

global const int SHADOWARMY_LEGEND_ALLIANCE = ALLIANCE_A
global const int SHADOWARMY_REVENANT_ALLIANCE = ALLIANCE_B
const int MAX_EVAC_TARGET_COUNT_FOR_LEGENDS = 6 // The Max number of legends we would ever set as the evac target count ( this lines up with the number of players that keep respawning as Legends near the end of the match and with the Max number of players that can board a single Evac Ship )

#if CLIENT
const float SHADOWARMY_ANNOUNCEMENT_DURATION = 5.0
const asset ANNOUNCEMENT_LOBA_ICON_FG = $"rui/gamemodes/rev_army/loba_banner_icon_outline"
const asset ANNOUNCEMENT_SHADOW_REV_ICON_FG = $"rui/gamemodes/rev_army/soldier_rev_banner_icon_outline"
const asset ANNOUNCEMENT_FULL_REV_ICON_FG = $"rui/gamemodes/rev_army/red_eye_rev_banner_icon_outline"
const vector ANNOUNCEMENT_FULL_REV_BANNER_COLOR = < 1, 0, 0 >
const vector EVAC_INCOMING_HUD_ELEMENT_COL = < 0.945, 0.725, 0.1 >
const vector EVAC_ARRIVED_HUD_ELEMENT_COL = < 0.956, 0.192, 0.192 >

// SFX
global const string SFX_SHADOWARMY_REV_ALLIANCE_CHAR_SEL_START = "Lobby_RevenantArmy_Menu_Team_Attributed"
const string SFX_SHADOWARMY_LEGEND_SPAWN = "InGame_RevenantArmy_FadeFromBlack_Intro"
const string SFX_SHADOWARMY_REVENGE_KILL_MSG = "UI_InGame_ShadowSquad_RevengeKill"
const string SFX_SHADOWARMY_END_MSG = "UI_InGame_ShadowSquad_FinalSquadMessage"
const string SFX_SHADOWARMY_EVAC_MSG_STINGER_NORMAL = "UI_RevenantArmy_EvacSoon_Stinger"
const string SFX_SHADOWARMY_REV_ARMY_REV_RESPAWN_STINGER = "UI_RevenantArmy_Respawning_NormalRev"
const string SFX_SHADOWARMY_REDEYE_REV_RESPAWN_STINGER = "UI_RevenantArmy_Respawning_RedEyedRev"
const string SFX_SHADOWARMY_MATCH_WIN_STINGER = "UI_RevenantArmy_MatchWon_Stinger"
const string SFX_SHADOWARMY_MATCH_LOSE_STINGER = "UI_RevenantArmy_MatchLost_Stinger"

// MUSIC
const string MUSIC_SHADOWARMY_LEGEND_VICTORY = "Music_RevArmy_Victory_Legends"
const string MUSIC_SHADOWARMY_REV_VICTORY = "Music_RevArmy_Victory_Revenants"
const string MUSIC_SHADOWARMY_LEGEND_SPAWN_AS_REV = "Music_RevArmy_Spawn_RevenantArmy"
const string MUSIC_SHADOWARMY_GAMEPLAY_RAMPUP_LEGEND = "Music_RevArmy_Gameplay_Legends"
const string MUSIC_SHADOWARMY_GAMEPLAY_RAMPUP_REV = "Music_RevArmy_Gameplay_Revenants"
const array< float > MUSIC_RAMPUP_CONTROLLER_VALUES = [ 50.0, 150.0, 200.0 ] // Indexed by eShadowArmyMusicRampLevels, these are the controller values for the corresponding music levels
const int MUSIC_RAMPUP_LEVEL_NOT_SET = -1

// UI
const asset EVAC_AREA_ICON = $"rui/gamemodes/shadow_squad/evac_countdown"
const asset LEGEND_START_AREA_ICON = $"rui/hud/ping/icon_ping_attack"
#endif

#if SERVER
// Models
const asset SHADOWARMY_REVENANT_PLANE_MODEL = $"mdl/vehicles_r2/aircraft/widow/veh_air_widow.rmdl"
const asset SHADOWARMY_REVENANT_PLANE_DECAL = $"mdl/vehicles_r2/aircraft/widow/veh_air_widow_revenant_decal_01.rmdl"
const asset SHADOWARMY_REVENANT_PLANE_THRUSTERS = $"mdl/vehicles_r2/aircraft/widow/veh_air_widow_thruster_fx.rmdl"

// VFX
const asset FULL_REV_EYE_VFX = $"P_rev_special_eye"
const asset SHADOWARMY_REVENANT_PLANE_TRAIL = $"P_veh_draconis_flyin_wind"
const asset FULL_REV_CHEST_VFX = $"P_rev_emote_powerup"
const string EVAC_SHIP_BEAM_VFX = "FX_EVAC_SHIP_BEACON_PENDING"

// Dialogue
const array<int> SHADOWARMY_DISABLED_COMMS_ACTIONS = [
	                         
		eCommsAction.INVENTORY_NO_AMMO_BULLET,
		eCommsAction.INVENTORY_NO_AMMO_ARROWS,
		eCommsAction.INVENTORY_NO_AMMO_HIGHCAL,
		eCommsAction.INVENTORY_NO_AMMO_SHOTGUN,
		eCommsAction.INVENTORY_NO_AMMO_SNIPER,
		eCommsAction.INVENTORY_NO_AMMO_SPECIAL,
       
]

// Loadouts
const string SHADOWARMY_DEFAULT_WEAPON_LOADOUT_LEGEND = "mp_weapon_semipistol"
const string SHADOWARMY_DEFAULT_WEAPON_LOADOUT_REVENANT = "mp_weapon_pdw_crate mp_weapon_sniper"
const string SHADOWARMY_DEFAULT_CONSUMABLES_LOADOUT_LEGEND = "health_pickup_health_small:2 health_pickup_combo_small:2 health_pickup_health_large:1 health_pickup_combo_large:1"
const string SHADOWARMY_DEFAULT_CONSUMABLES_LOADOUT_REVENANT = "health_pickup_health_small:2 health_pickup_combo_small:2 health_pickup_health_large:4 health_pickup_combo_large:4 health_pickup_combo_full:1 mp_weapon_thermite_grenade:1 mp_weapon_frag_grenade:1 mp_weapon_grenade_emp:1"
const string SHADOWARMY_DEFAULT_EQUIPMENT_LOADOUT_LEGEND = "armor_pickup_lv1_evolving helmet_pickup_lv1"
const string SHADOWARMY_DEFAULT_EQUIPMENT_LOADOUT_REVENANT = "armor_pickup_lv5_evolving helmet_pickup_lv3 incapshield_pickup_lv3"

//Objective Evac
const string SHADOW_ARMY_MAP_DATA_NODE = "info_shadowarmy_map_data"
const string SHADOW_ARMY_EVAC_LOC_SCRIPT_NAME = "script_rev_army_evacpos"
const string SHADOW_ARMY_EVAC_SHIP_LOC_SCRIPT_NAME = "script_rev_army_evacship_pos"
const float DEFAULT_EVAC_TIME_TO_START	= 480.0 // Legends see the Evac Location Right Away but we don't spawn the Evac Sequence for this long ( can be interupted and Emergency Evac can trigger during this time )
const float DEFAULT_EVAC_SHIP_TIME_TO_ARRIVE = 240.0 // Once the Evac Objective is triggered, after the above wait or through Emergency Evac; how long before the ships actually arrive
const float DEFAULT_EVAC_SHIP_TIME_TO_DEPART = 30.0 // Once Evac Ships arrive, how long before they depart
const float POST_EVAC_SHIP_DEPART_WAIT_DURATION = 6.0
const float EVAC_TARGET_PERCENTAGE_OF_LEGENDS = 0.5 // We take this percent of remaining legends and set that as the evac target count
const float EVAC_CIRCLE_RADIUS = 200.0
const vector EVAC_WAYPOINT_VERTICAL_OFFSET = < 0, 0, 64 >
const array < float > EVAC_AREA_RADII = [ 30000.0, 30000.0, 21000.0, 13000.0, 8000.0 ] // 0 isn't used, need to keep to ensure logic works ( we grab the index based on ring stage )

// General
const int AMMO_TO_DROP_ON_SHADOW_DEATH = 2
const float DEFAULT_FULL_REV_SPAWN_COOLDOWN = 60.0 // After a Full Rev dies, how long before we allow a new one to take their place
const float FULL_REV_WAYPOINT_HEIGHT_OFFSET = 156
const float FULL_REV_LANDING_WARNING_MESSAGE_DURATION = 4
const float DEFAULT_SHADOW_HEALTH = 60.0
const int LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL = 0
const int LEGENDSQUADCOUNT_OFF_TARGET_MIN_LEVEL = -3
const int LEGENDSQUADCOUNT_OFF_TARGET_MAX_LEVEL = 3
const int INVALID_INDEX = -1
const int INVALID_CATCHUP_VALUE = 999
#endif // SERVER

#if SERVER || CLIENT
// Dialogue
const array<string> SHADOWARMY_DISABLED_BATTLE_CHATTER_EVENTS = [
	"bc_anotherSquadAttackingUs",
	"bc_championEliminated",
	"bc_congratsKill",
	"bc_iDownedAnEnemy",
	"bc_iDownedAnotherEnemy",
	"bc_iKilledAnEnemy",
	"bc_returnFromRespawn",
	"bc_squadTeamWipe",
	"bc_tactical",
	"bc_takingFire",
	"bc_imJumpmaster",
	"bc_shieldBreakEnemy",
]
#endif // SERVER || CLIENT

const bool SHADOW_ARMY_SHOW_DETAILED_DEBUG = true
#if DEVELOPER
const bool SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS = false
const float SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME = 20.0
const float SHADOWARMY_SPAWN_DEBUG_DRAW_RADIUS = 150.0
#endif // DEV

enum eShadowArmyGamePhase
{
	GAME_START,
	WAITING_FOR_EVAC_OBJECTIVE,
	EVAC_OBJECTIVE,
	EVAC_SHIP_ARRIVED,
	EVAC_SHIP_DEPARTED,

	_count
}

global enum eShadowArmyMessageIndex
{
	LTM_DROP_ANNOUNCE_LEGEND,
	LTM_DROP_ANNOUNCE_SHADOW,
	RESPAWNING_AS_SHADOW_FIRST_TIME,
	RESPAWNING_AS_SHADOW,
	RESPAWNING_AS_SHADOW_FROM_LEGEND,
	RESPAWNING_AS_FULL_REV,
	RESPAWNING_AS_LEGEND,
	RESPAWNING_AS_LEGEND_EVAC,
	FULL_REV_SPAWNED_LEGEND,
	FULL_REV_SPAWNED_SHADOW,
	FULL_REV_KILLED,
	LEGEND_TEAM_SWITCHED_TO_REV,
	EVAC_CALLED_IN_RING_LEGEND,
	EVAC_CALLED_IN_RING_SHADOW,
	EVAC_CALLED_IN_EMERGENCY_LEGEND,
	EVAC_CALLED_IN_EMERGENCY_SHADOW,
	EVAC_ARRIVED_LEGEND,
	EVAC_ARRIVED_SHADOW,
	SAFE_ON_EVAC_SHIP,
	ALLIANCE_SWITCH_DISABLED_LEGEND,
	ALLIANCE_SWITCH_DISABLED_SHADOW,
	LEGENDS_RESPAWNED,
	LEGEND_ENTERED_EVAC_SHIP,
	EVAC_AREA_UPDATED,
	EVAC_LOCATION_REVEALED,
	BLANK,
	_count
}

global enum eShadowArmyMessageType
{
	ANNOUNCE_ONLY,
	OBIT_ONLY,
	ANNOUNCE_AND_OBIT,
	_count
}

enum eShadowArmyHintIndex
{
	FULL_REV_CANDIDATE_HINT,
	FULL_REV_CRITERIA_NO_DAM_HINT,
	_count
}

enum eShadowArmyRespawnForm
{
	LIVING_LEGEND,
	FULL_REVENANT,
	SHADOW,
	_count
}

#if CLIENT
enum eShadowArmyMusicRampLevels
{
	PRE_EVAC_SEQUENCE,
	EVAC_SEQUENCE_STARTED,
	EVAC_ARRIVED,
	_count
}
#endif //CLIENT

#if SERVER
struct ShadowArmyObjectiveEvacLocationData
{
	vector evacLocation // The exact location of Evac
	array < entity > evacShipLocationNodes
	array < entity > evacShips
	entity evacLocationWaypoint // The waypoint for the Evac Location Icon
	entity evacLocationMapArea // The map entity used to display the general evac area
}
#endif //SERVER

struct
{
#if SERVER
	// Gamestate/Objective Data
	// Objective Evac
	bool isEmergencyEvac = false
	ShadowArmyObjectiveEvacLocationData evacLocationData
	array < entity > evacLocationNodes // Editor nodes defining the different evac locations
	table < entity, array< entity > > evacLocationToEvacShipLocationsTable // Table of Editor nodes for evac locations and the Editor nodes for Evac Ship locations that correspond to them

	// Catchup Mechanics
	int remainingLegendSquadOffTargetLevel = 0 // Based on the desired remaining Legend squads at this ring stage, how off is the actual count ( negative means there are less than desired, positive means more than desired )
	float shadowMaxHealth = DEFAULT_SHADOW_HEALTH
	int healthGainedOnKill_FullRev = LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL
	int healthGainedOnKill_Legend = LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL
	float modifiedRevRespawnTime = SHADOWARMY_DEFAULT_SHORT_SPAWN_DELAY

	// Respawn
	array < entity > spawnedLegendPlayers // Keep track of Legends who have spawned so we know if they are on a first spawn from spawn callbacks
	bool isOnFinalLegend
	bool canLivingLegendsRespawnAsShadows = true
	bool isWaitingOnMeleeRevDamageSignal = false // Are we waiting on a signal from a melee Rev doing damage to a legend to pick a Full Rev Candidate
	entity fullRevOrCandidatePlayer // Player that is marked to be the Full Rev or has respawned and is the full Rev
	table < entity, int > playerToPlayerFormOnDeath // What form was the player in when they last died
	array < entity > previousFullRevsArray // Players who have been in Full Revenant form already ( don't pick them again )
	table < entity, float > shadowPlayerToDamageDealtTable // keep track of players in melee form and the amount of total damage they have done to Legends
	table < entity, ItemFlavor > playerToSelectedCharacterTable // Store the character a player had selected before being put on the Rev team so we can restore them before returning to the lobby
	// Audio
	float timeOfLastRemainingSquadCommentary = -1.0
	bool didPlayHalfLegendSquadRemainingCommentary = false
#endif // SERVER

#if SERVER || CLIENT
	int evacTargetCount = 0
#endif // SERVER || CLIENT

#if CLIENT
	bool areEnemyMapScansActiveOnClient = false

	// Ramp up Music
	entity musicEntity // Music entity used to play ramp up music as the match progresses
	int musicRampUpLevel = MUSIC_RAMPUP_LEVEL_NOT_SET
	array < entity > playersRespawningAfterAllianceSwitch
#endif // CLIENT
} file

void function ShadowArmy_Init()
{
	#if SERVER
		Survival_OverrideGetLivingPlayerCountFunction( GetLivingLegendsCount )
		Survival_OverrideGetRemainingSquadsFunction( GetRemainingLivingLegendSquadsCount )
		AddSpawnCallbackEditorClass( "script_ref", SHADOW_ARMY_MAP_DATA_NODE, ShadowArmy_OnMapDataCreated )
		AddSpawnCallback( "info_target", ShadowArmy_OnSpawnedEvacLocInfoTargetNode )
		AddCallback_EntitiesDidLoad( EntitiesDidLoad )
		AddCallback_OnPlayerPostRespawned( OnPlayerPostRespawned )
		Survival_AddCallback_IsSquadReallyEliminated( ShadowArmy_IsSquadReallyEliminated )
		Survival_SetCallback_ModeShouldSpawnPlayersDuringCharacterSelect( ShadowArmy_SupressGameStartSpawn )
		Bleedout_AddCallback_OnPlayerStartBleedout( OnPlayerDowned )
		AddCallback_OnPlayerKilled( OnPlayerKilled )
		Survival_AddCallback_OnPlayerPutInPlane( OnPlayerPutInIntroDropship )

		if ( GetRespawnStyle() == eRespawnStyle.SPAWN_GROUP_SKYDIVE )
		{
			SpawnGroupSkydive_SetCallback_CanRespawnPlayerOrSquad( CanRespawnPlayerOrSquad )
			SpawnGroupSkydive_SetCallback_GetSquadPlayersToRespawn( GetArrayOfSquadPlayersToRespawn )
		}
		else if ( GetRespawnStyle() == eRespawnStyle.SPAWN_NEAR_SQUAD )
		{
			RespawnNearSquad_SetCallback_GetSpawnDelay( ShadowArmy_GetPlayerSpawnDelay )
			RespawnNearSquad_SetCallback_CanRespawnPlayer( CanRespawnPlayerOrSquad )
			RespawnNearSquad_SetCallback_GetBestRespawnPoint( ShadowArmy_GetRevRespawnPoint )
		}

		AddCallback_AllianceProximity_OnTeamPutIntoAlliance( ShadowArmy_OnTeamChangedAlliance )
		Survival_AddCallback_OnPlayerLaunchedFromPlane( ShadowArmy_AnnouncementSplash )
		AddCallback_OnClientConnectionRestored( OnPlayerReConnected )
		AddCallback_OnClientConnected( OnPlayerConnected )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )
		AddCallback_GameStateEnter( eGameState.Playing, ShadowArmy_OnGamestateEnterPlaying_Server )
		AddCallback_GameStateEnter( eGameState.PickLoadout, ShadowArmy_OnGamestateEnterPickLoadout_Server )
		AddCallback_GameStateEnter( eGameState.Postmatch, ShadowArmy_OnGamestateEnterPostMatch_Server )
		AddCallback_GameStateEnter( eGameState.Resolution, ShadowArmy_OnResolution_Server )
		AddCallback_OnSurvivalDeathFieldStageChanged( ShadowArmy_OnRoundChanged )
		SetOnPlayerSkydiveCustomTrailsCallback( OnSkydiveCustomTrailsInitialized )
		Survival_AddCallback_OnPlayerLandedFromDropshipFreefall( ShadowArmy_OnPlayerLandedFromPlane )

                               
			ShadowZombie_SetCallback_GetMaxHealthValueToSetForShadows( ShadowArmy_GetMaxHealthValueForShadows )
       
                                                                                                                                                     
                                     

		PrecacheParticleSystem( FULL_REV_EYE_VFX )
		PrecacheParticleSystem( SHADOWARMY_REVENANT_PLANE_TRAIL )
		PrecacheParticleSystem( FULL_REV_CHEST_VFX )
		PrecacheModel( SHADOWARMY_REVENANT_PLANE_MODEL )
		PrecacheModel( SHADOWARMY_REVENANT_PLANE_DECAL )
		PrecacheModel( SHADOWARMY_REVENANT_PLANE_THRUSTERS )

		                      
			#if SERVER
				MatchBehaviorPlayer_AddEndedCallback( ShadowArmy_OnMatchBehaviorEnd )
			#endif // #if SERVER
                                  

		FlagInit( "FinalCircleEvacInitialized" )
		FlagInit( "EvacShipArrived" )
		FlagInit( "EvacShipDeparting" )
		RegisterSignal( "EmergencyEvacTriggered" )
		RegisterSignal( "ShadowRevDealtDamage" )

		// Disabled commentary events for LTM
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_CLOSING_TO_NOTHING, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HALF_PLAYERS_ALIVE, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HALF_SQUADS_ALIVE, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HOVER_TANK_INBOUND, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_1MIN, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_10SEC, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_30SEC, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_45SEC, false )
		SurvivalCommentary_SetEventEnabled( eSurvivalEventType.ROUND_TIMER_STARTED, false )
		QuickChat_RegisterDisabledCommsActions( SHADOWARMY_DISABLED_COMMS_ACTIONS )

		// Set default values for variables affected by catchup mechanics
		file.shadowMaxHealth = GetShadowRevBaseHealth()
		file.healthGainedOnKill_FullRev = GetBaseFullRevOnKillHealAmount()
		file.healthGainedOnKill_Legend = GetBaseLegendOnKillHealAmount()
		file.modifiedRevRespawnTime = GetShadowRevBaseSpawnCooldown()
	#endif // SERVER

	#if CLIENT
		SURVIVAL_SetGameStateAssetOverrideCallback( OverrideGameState )
		AddCallback_OnPlayerLifeStateChanged( OnPlayerLifeStateChanged_Client )
		AddCallback_GameStateEnter( eGameState.Playing, ShadowArmy_OnGamestateEnterPlaying_Client )
		AddCallback_AllianceProximity_OnTeamPutIntoAlliance( ShadowArmy_OnTeamChangedAlliance_Client )
		AddCallback_ClientOnPlayerConnectionStateChanged( ShadowArmy_OnPlayerConnectionStateChanged )
		AddCallback_OnYouRespawned( OnYouRespawned )
		AddOnSpectatorTargetChangedCallback( ShadowArmy_OnSpectateTargetChanged )
		Survival_SetVictorySoundPackageFunction( GetVictorySoundPackage )
		AddCallback_OnSurvivalDeathFieldStageChanged( ShadowArmy_OnRoundChanged_Client )

		Obituary_SetVerticalOffset( 90 )

		FlagInit( "WaitingForEvacObjective_Client" )
		FlagInit( "EvacObjective_Client" )
		FlagInit( "EvacShipArrived_Client" )
		FlagInit( "EvacShipDeparting_Client" )
		RegisterSignal( "StartingEvacObjectiveMessagingThread" )
	#endif // CLIENT

	#if SERVER || CLIENT
		FlagInit( "AllianceAssignmentComplete" )
		if ( GetRespawnStyle() == eRespawnStyle.SPAWN_GROUP_SKYDIVE )
			SpawnGroupSkydive_SetCallback_GetSquadSpawnDelay( ShadowArmy_GetSpawnDelay )

		if ( AllianceProximity_ShouldOnlyDisplayPriorityPingsForAlliance() )
			AllianceProximity_SetPriorityPingsForAlliance( SHADOW_ARMY_ALLOWED_ALLIANCE_PINGS )

		RegisterCSVDialogue( $"datatable/dialogue/s19event_dialogue.rpak" )
		RegisterCommentaryBuckets( $"datatable/dialogue/s19event_dialogue.rpak" )
		RegisterDisabledBattleChatterEvents( SHADOWARMY_DISABLED_BATTLE_CHATTER_EVENTS )
	#endif // SERVER || CLIENT

	ShGameMode_ShadowArmy_RegisterNetworking()
}

void function ShGameMode_ShadowArmy_RegisterNetworking()
{
	// Server to Client
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_ShowAnnouncementMessage", "int", 0, eShadowArmyMessageIndex._count, "int", 0, eShadowArmyMessageType._count )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_ShowHinttMessage", "int", 0, eShadowArmyMessageIndex._count, "int", 0, INT_MAX, "int", 0, INT_MAX )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_GivePlayerRepeatingEnemyMapScans" )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_UpdateEvacTargetCountOnHud", "int", 0, MAX_EVAC_TARGET_COUNT_FOR_LEGENDS + 1 )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_SetDeathScreenCallbacks" )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_PlayMatchEndMusic", "bool" )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_SetAllianceAssignmentCompleteFlag" )
	Remote_RegisterClientFunction( "ShadowArmy_ServerCallback_DestroyLegendStartAreaMapFeature" )

	RegisterNetworkedVariable( "shadowArmy_PlayerForm", SNDC_PLAYER_GLOBAL, SNVT_UNSIGNED_INT, eShadowArmyRespawnForm.LIVING_LEGEND )
	RegisterNetworkedVariable( "shadowArmy_GamePhase", SNDC_GLOBAL, SNVT_UNSIGNED_INT, eShadowArmyGamePhase.GAME_START )
	RegisterNetworkedVariable( "shadowArmy_LegendsInEvacShips", SNDC_GLOBAL, SNVT_UNSIGNED_INT, 0 )
	RegisterNetworkedVariable( "shadowArmy_NextEvacPhaseTime", SNDC_GLOBAL, SNVT_TIME, -1 )

	#if CLIENT
		RegisterNetVarIntChangeCallback ( "shadowArmy_GamePhase", OnShadowArmyGamePhaseChanged_Client )
		RegisterNetVarIntChangeCallback ( "shadowArmy_LegendsInEvacShips", UpdateLegendInEvacShipHUDCount )
	#endif // CLIENT
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PLAYLIST VAR GET FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

bool function IsShadowArmyGamemodeCineVersion()
{
	return GetCurrentPlaylistVarBool( "is_shadow_army_cine_version", false )
}

// How many Revenant squads should there be on match start ( remainder are Legend Squads )
const int UNSET_SQUAD_COUNT = -1
int function ShadowArmy_GetNumRevSquadsForMatchStart()
{
	// If we manually set the rev squad count, use it
	string currentPlaylist = ShadowArmy_GetCurrentShadowArmyPlaylist()
	int squadCount = GetPlaylistVarInt( currentPlaylist, "shadow_army_starting_rev_squads", UNSET_SQUAD_COUNT )
	int maxTeams = GetPlaylistVarInt( currentPlaylist, "max_teams", MAX_TEAMS )

	Assert( squadCount < maxTeams, "Shadow Army: Running the mode with all teams assigned to the Rev Alliance. THIS WILL CAUSE A CRASH IN RETAIL. Ensure max_teams, currently: " + maxTeams + " is greater than shadow_army_starting_rev_squads, currently: " + squadCount )

	// Otherwise, split up the squads evenly between the alliances
	if ( squadCount < 0 )
	{
		int maxAlliances = GetPlaylistVarInt( currentPlaylist, "max_alliances", 0 )

		if ( maxTeams > 0 && maxAlliances > 0 )
			squadCount = maxTeams / maxAlliances
		else
			squadCount = 0
	}

	return squadCount
}

// In the Lobby the playlist is set to dev_default which is grabbing data we don't want for the about screen
// In this situation, grab the shadow army base playlist vars instead of the dev defaults
const string DEFAULT_SHADOW_ARMY_PLAYLIST = "survival_shadow_army_base"
string function ShadowArmy_GetCurrentShadowArmyPlaylist()
{
	string currentPlaylist = GetCurrentPlaylistName()

	if ( currentPlaylist == "dev_default" )
		currentPlaylist = DEFAULT_SHADOW_ARMY_PLAYLIST

	return currentPlaylist
}

#if SERVER
string function GetWeaponLoadoutString( bool isLivingLegend )
{
	if ( isLivingLegend )
		return GetCurrentPlaylistVarString( "shadow_army_weapon_loadout_legends", SHADOWARMY_DEFAULT_WEAPON_LOADOUT_LEGEND )

	return GetCurrentPlaylistVarString( "shadow_army_weapon_loadout_revenants", SHADOWARMY_DEFAULT_WEAPON_LOADOUT_REVENANT )
}
#endif // SERVER

#if SERVER
string function GetConsumableLoadoutString( bool isLivingLegend )
{
	if ( isLivingLegend )
		return GetCurrentPlaylistVarString( "shadow_army_consumables_loadout_legends", SHADOWARMY_DEFAULT_CONSUMABLES_LOADOUT_LEGEND )

	return GetCurrentPlaylistVarString( "shadow_army_consumables_loadout_revenants", SHADOWARMY_DEFAULT_CONSUMABLES_LOADOUT_REVENANT )
}
#endif // SERVER

#if SERVER
string function GetEquipmentLoadoutString( bool isLivingLegend )
{
	if ( isLivingLegend )
		return GetCurrentPlaylistVarString( "shadow_army_equipment_loadout_legends", SHADOWARMY_DEFAULT_EQUIPMENT_LOADOUT_LEGEND )

	return GetCurrentPlaylistVarString( "shadow_army_equipment_loadout_revenants", SHADOWARMY_DEFAULT_EQUIPMENT_LOADOUT_REVENANT )
}
#endif // SERVER

#if SERVER
bool function GetShouldUseInfiniteAmmo()
{
	return GetCurrentPlaylistVarBool( "shadow_army_infinite_ammo", false )
}
#endif // SERVER

int function GetNumLivingSquadsToTurnOffAllianceSwitch()
{
	return GetCurrentPlaylistVarInt( "shadow_army_legend_squad_count_to_end_switching", 1 )
}

int function GetNumLivingSquadsForEmergencyEvac()
{
	return GetCurrentPlaylistVarInt( "shadow_army_living_squad_count_emergency_evac", 3 )
}

#if SERVER
// What is the min time between Red Eyed Revs
float function GetFullRevCooldownDurationMatchStart()
{
	return GetCurrentPlaylistVarFloat( "shadow_army_fullrev_cooldown_start", DEFAULT_FULL_REV_SPAWN_COOLDOWN )
}
#endif // SERVER

#if SERVER
// Legends see the Evac Location Right Away but we don't spawn the Evac Sequence for this long ( can be interupted and Emergency Evac can trigger during this time )
float function GetDelayDurationUntilEvacSequenceStarts()
{
	return GetCurrentPlaylistVarFloat( "shadow_army_evac_seq_delay", DEFAULT_EVAC_TIME_TO_START )
}
#endif // SERVER

#if SERVER
// Once the Evac Objective is triggered, after the above wait or through Emergency Evac; how long before the ships actually arrive
float function GetDelayDurationUntilEvacShipsArrive()
{
	return GetCurrentPlaylistVarFloat( "shadow_army_evac_ship_delay", DEFAULT_EVAC_SHIP_TIME_TO_ARRIVE )
}
#endif // SERVER

#if SERVER
// Once Evac Ships arrive, how long before they depart
float function GetDelayDurationUntilEvacShipsDepart()
{
	return GetCurrentPlaylistVarFloat( "shadow_army_evac_depart_delay", DEFAULT_EVAC_SHIP_TIME_TO_DEPART )
}
#endif // SERVER

#if SERVER || CLIENT
// At which stage should we reveal the exact location of the Evac Location
const int DEFAULT_STAGE_TO_REVEAL_EVAC_LOC = 3
int function GetRingStageWhenEvacLocationRevealed()
{
	return GetCurrentPlaylistVarInt( "shadow_army_ring_stage_to_reveal_evac_loc", DEFAULT_STAGE_TO_REVEAL_EVAC_LOC )
}
#endif // SERVER || CLIENT

#if SERVER
// Should players in the Legend Alliance spawn on the ground for match start
bool function ShadowArmy_GetShouldLegendsSpawnOnGround_MatchStart()
{
	return GetCurrentPlaylistVarBool( "shadow_army_legends_spawn_on_ground", false )
}
#endif // SERVER

#if SERVER
// Should we use any catchup mechanics
bool function GetShouldUseCatchupMechanics()
{
	return GetCurrentPlaylistVarBool( "shadow_army_catchup_enabled", true )
}
#endif // SERVER

#if SERVER
// What is the difference in squad counts we would like between the Legend Alliance and the Rev Alliance at this minute interval
// The amount you want should be divided by 2 because when a squad of Legends is eliminated they switch over to the Rev Alliance
// Example: If the Legend alliance starts with 10 squads and we wanted them to be down to 9 squads at the 1 min mark in the match the value for shadow_army_target_squad_diff_for_time_1 would be -1
int function GetTargetSquadDiffForTime( int timeIndex )
{
	int targetDiff = GetCurrentPlaylistVarInt( "shadow_army_target_squad_diff_for_time_" + timeIndex, INVALID_CATCHUP_VALUE )
	Assert( targetDiff != INVALID_CATCHUP_VALUE, "Shadow Army: Tried to get value for shadow_army_target_squad_diff_for_time_" + timeIndex + " but it wasn't defined in the playlist" )

	if ( targetDiff == INVALID_CATCHUP_VALUE )
		targetDiff = 0

	return targetDiff
}
#endif // SERVER

#if SERVER
// What is the minimum squad count difference between the Rev Alliance and the Legend Alliance before we trigger any catchup mechanics
// Example: At the start of the match the target diff is -1 so we would want 9 Legend Squads. If this value is 2 we wouldn't start triggering any catchup mechanics unless we are down to 6 Legend Squads
int function GetMinSquadOffTargetAmountToTriggerCatchupForTime( int timeIndex )
{
	int minOffTarget = GetCurrentPlaylistVarInt( "shadow_army_min_offtarget_for_catchup_for_time_" + timeIndex, INVALID_CATCHUP_VALUE )
	Assert( minOffTarget != INVALID_CATCHUP_VALUE, "Shadow Army: Tried to get value for shadow_army_min_offtarget_for_catchup_for_time" + timeIndex + " but it wasn't defined in the playlist" )

	if ( minOffTarget == INVALID_CATCHUP_VALUE )
		minOffTarget = 0

	return minOffTarget
}
#endif // SERVER

#if SERVER
// Default value for Melee Rev health
float function GetShadowRevBaseHealth()
{
	return GetCurrentPlaylistVarFloat( "shadow_army_base_shadow_health", DEFAULT_SHADOW_HEALTH )
}
#endif // SERVER

#if SERVER
// Default health gained by a Full Rev when they get a kill
int function GetBaseFullRevOnKillHealAmount()
{
	return GetCurrentPlaylistVarInt( "shadow_army_heal_fullrev_onkill_base_amount", LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL )
}
#endif // SERVER

#if SERVER
// Default health gained by a Legend when they get a kill
int function GetBaseLegendOnKillHealAmount()
{
	return GetCurrentPlaylistVarInt( "shadow_army_heal_legends_onkill_base_amount", LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL )
}
#endif // SERVER

#if SERVER || CLIENT
// Default value for Melee Rev spawn delay
float function GetShadowRevBaseSpawnCooldown()
{
	return GetCurrentPlaylistVarFloat( "respawn_cooldown", SHADOWARMY_DEFAULT_SHORT_SPAWN_DELAY )
}
#endif // SERVER || CLIENT

#if SERVER
// How many times can a Melee Rev die and respawn at the starting short time before their respawn time is dictated by catchup mechanics
const int LOW_DEATH_COUNT_FORGIVENESS = 3
int function GetShadowRevLowDeathCountThresholdForSpawnTime()
{
	return GetCurrentPlaylistVarInt( "shadow_army_low_death_count_for_respawn_times", LOW_DEATH_COUNT_FORGIVENESS )
}
#endif // SERVER

#if SERVER
// What is the lowest modifier we can apply for catchup mechanics
int function GetMinLevelForCatchupMechanics()
{
	return GetCurrentPlaylistVarInt( "shadow_army_min_catchup_level", LEGENDSQUADCOUNT_OFF_TARGET_MIN_LEVEL )
}
#endif // SERVER

#if SERVER
// What is the highest modifier we can apply for catchup mechanics
int function GetMaxLevelForCatchupMechanics()
{
	return GetCurrentPlaylistVarInt( "shadow_army_max_catchup_level", LEGENDSQUADCOUNT_OFF_TARGET_MAX_LEVEL )
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EARLY GAMESTATE CALLBACKS AND VAR SETTING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#if SERVER
void function ShadowArmy_OnMapDataCreated( entity mapData )
{
	printt( "Shadow Army: Map Data Node Created" )
}
#endif // SERVER

#if SERVER
// Callback for when an evac location node is created, use these to define the evac zone ( icon ), the ShadowArmy_OnSpawnedEvacShipLocInfoTargetNode will define the evac ship locs for these locations
void function ShadowArmy_OnSpawnedEvacLocInfoTargetNode( entity node )
{
	if ( !IsValid( node ) || node.GetScriptName() != SHADOW_ARMY_EVAC_LOC_SCRIPT_NAME )
		return

	// First, look for parent Map Data
	entity parentMapVariant = node.GetLinkParent()
	if ( parentMapVariant == null )
	{
		Warning( "Shadow Army: Found orphaned Evac Location Info Target Node at " + node.GetOrigin() + " - Link a map variant to this node" )
		return
	}

	if ( GetEditorClass( parentMapVariant ) != SHADOW_ARMY_MAP_DATA_NODE  )
		Warning( "Shadow Army: Found Evac Location Info Target Node at " + node.GetOrigin() + " with an incoming link that does not come from an info_shadowarmy_map_data entity" )

	array< entity > linkedEnts = node.GetLinkEntArray()
	array< entity > evacShipLocationsArray
	foreach( ent in linkedEnts )
	{
		if ( IsValid( ent ) && ent.GetScriptName() == SHADOW_ARMY_EVAC_SHIP_LOC_SCRIPT_NAME )
			evacShipLocationsArray.append( ent )
	}

	file.evacLocationNodes.append( node )
	file.evacLocationToEvacShipLocationsTable[ node ] <- evacShipLocationsArray
	printt( "Shadow Army: Evac Location Info Target Node at " + node.GetOrigin() + " got an array of " +  evacShipLocationsArray.len() + " Evac Ship Locations" )
}
#endif // SERVER

#if SERVER
array< PlanePathData > function ShadowArmy_GenerateSingleRevArmyPlanePath( bool beQuick, int unusedInt = 0 )
{
	PlanePathData result

	table<string, bool> e
	e[ "trace_test" ] <- false
	const int MAX_PLANE_PATH_TRIES = 50
	int numTries

	vector startPos
	vector endPos
	vector angles
	vector centerPos

	bool clampToRing = Survival_IsDropshipClampedToRing()
	Assert( !( clampToRing && GetDeathFieldStartStage() < 1 ), "Cannot clamp dropship to ring bounds for a ring before the first ring" )

	vector mapCenter = SURVIVAL_GetMapCenter()
	float planeHeight = SURVIVAL_GetPlaneHeight()
	int defaultRealm = Survival_Loot_GetDefaultRealm()
	float ringRadius = clampToRing ? SURVIVAL_GetDeathFieldData( defaultRealm ).currentRadius : REALBIG_CIRCLE_GRID_RADIUS
	float nextRingRadius = clampToRing ? SURVIVAL_GetDeathFieldStages( defaultRealm )[ SURVIVAL_GetCurrentDeathFieldStage()  ].endRadius : REALBIG_CIRCLE_GRID_RADIUS

	FlagWait( "FinalCircleEvacInitialized" )

	entity fakePlane = CreatePropDynamic( SURVIVAL_PLANE_MODEL )
	while ( !e[ "trace_test" ] )
	{
		float mapAngleRotation = GetCurrentPlaylistVarFloat( "survival_plane_angle_deviation", SURVIVAL_GetFlightAngleAdjustment() )

		// Get the basic angle of approach
		int baseAngle            = RandomIntRangeForPlanePath( 0, 4 ) // 0, 90, 180, 270
		float tightnessFactor    =  GetCurrentPlaylistVarFloat( "survival_plane_start_angle_tightness", 1.5 )
		float baseAngleDeviation = pow( RandomFloatRangeForPlanePath( 0.0, 1.0 ), tightnessFactor )
		if ( CoinFlip() )
			baseAngleDeviation = -1 * baseAngleDeviation

		vector evacLocation = GetNewEvacWaypointLocation( GetRingStageWhenEvacLocationRevealed() )
		angles = VectorToAngles( FlattenVec( ZERO_VECTOR - evacLocation ) )
		float maxShadowArmyPlaneDisplacement = GetCurrentPlaylistVarFloat( "shadow_army_plane_displacment_angle_max", 30.0 )
		float randAngleDisplacement = RandomFloatRange( -maxShadowArmyPlaneDisplacement, maxShadowArmyPlaneDisplacement )
		angles = AnglesCompose( angles, < 0, randAngleDisplacement, 0 > )

		// Generate the starting position
		vector fwd         = AnglesToForward( angles )

		if ( clampToRing )
		{
			startPos = ( fwd * -1 * ringRadius ) + < mapCenter.x, mapCenter.y, planeHeight >
		}
		else
		{
			startPos  = (fwd * -1 * REALBIG_CIRCLE_GRID_RADIUS) + < mapCenter.x, mapCenter.y, planeHeight >
		}

		// Figure out the "center" position - a position near the center of the map we want to go through
		float maxDeviation = GetCurrentPlaylistVarFloat( "survival_plane_center_deviation_max", 12500 )
		float centerTightnessScale = GetCurrentPlaylistVarFloat( "survival_plane_center_tightness", 0.4 )
		float maxDeviationScale    = (1.0 - fabs( baseAngleDeviation ) * centerTightnessScale )
		maxDeviationScale = clamp( maxDeviationScale, 0.0, 1.0 )
		maxDeviation      = maxDeviation * maxDeviationScale

		float moveAmount = RandomFloatRangeForPlanePath( 0.0, maxDeviation )
		vector moveVec = VectorRotate( < moveAmount, 0, 0 >, < 0, RandomFloatRange( -180, 180 ), 0 >)
		centerPos = mapCenter + < moveVec.x, moveVec.y, planeHeight >
		result.centerPos = centerPos

		// Calculate the ending position, given we want to go from the starting spot
		vector startToCenterPosNorm = Normalize( centerPos - startPos )
		vector startToMapCenter = < mapCenter.x, mapCenter.y, planeHeight > - startPos
		float dot = DotProduct( startToMapCenter, startToCenterPosNorm )
		if ( clampToRing )
		{
			// Use some trig to find where the plane path intersects the next ring
			vector startToClosestApproachToMapCenter = DotProduct( startToCenterPosNorm, startToMapCenter ) * startToCenterPosNorm
			float centerToClosestApproachLen = Length( startToMapCenter - startToClosestApproachToMapCenter )
			float closestApproachToRingExitLength = sqrt( pow( nextRingRadius, 2 ) - pow( centerToClosestApproachLen, 2 ) )

			float startToExitRingDist = Length( startToClosestApproachToMapCenter ) + closestApproachToRingExitLength
			endPos = startPos + startToCenterPosNorm * startToExitRingDist
		}
		else
		{
			endPos = startPos + startToCenterPosNorm * 2.0 * dot
		}
		angles = VectorToAngles( startToCenterPosNorm )
		result.angles = angles

		vector maxs          = fakePlane.GetBoundingMaxs()
		maxs = <maxs.x, maxs.x, maxs.z>
		int traceMask = TRACE_MASK_SOLID & ~( CONTENTS_PHYSICSCLIP )	// Removing this clip because we were hitting skybox clouds on Olympus
		TraceResults results = TraceHull( startPos, endPos, -1 * maxs, maxs, fakePlane, traceMask, TRACE_COLLISION_GROUP_NONE )
		e[ "trace_test" ] = (results.fraction >= 0.99)

		numTries++
		if ( numTries > MAX_PLANE_PATH_TRIES )
		{
			Warning( "%s() - EXCEEDED %d PLANE PATH TRIES! Taking most recent plane path.", FUNC_NAME(), MAX_PLANE_PATH_TRIES )
			break
		}
	}

	fakePlane.Destroy()

	float SKYBOX_BUFFER = 6000

	vector jumpStart = Survival_GetPlaneJumpPointOverMap( startPos, endPos )
	vector jumpEnd   = Survival_GetPlaneJumpPointOverMap( endPos, startPos )

	// Clamp the jump boundaries to world bounds, like we do with the path below
	LineSegment jumpBounds = ClampLineSegmentToWorldBounds2D( jumpStart, jumpEnd, SKYBOX_BUFFER )
	jumpStart = jumpBounds.start
	jumpEnd = jumpBounds.end

	vector planeVec  = Normalize( jumpEnd - jumpStart )

	result.startPos = jumpStart
	result.endPos = jumpEnd

	float flyOverMapSpeed = Survival_GetPlaneMoveSpeed()
	float jumpDelay = (beQuick ? 3.0 : Survival_GetPlaneJumpDelay())
	float unitsBeforeJumpAllowed = flyOverMapSpeed * jumpDelay
	float planeLeaveMapDuration  = jumpDelay * Survival_GetPlaneLeaveMapDurationMultiplier()
	float unitsToLeaveMap        = flyOverMapSpeed * planeLeaveMapDuration

	vector planeStart = jumpStart + (planeVec * -unitsBeforeJumpAllowed)
	vector planeEnd   = jumpEnd + (planeVec * unitsToLeaveMap)

	LineSegment lineSegment    = ClampLineSegmentToWorldBounds2D( planeStart, planeEnd, SKYBOX_BUFFER )
	vector clampedPlaneStart   = lineSegment.start
	vector clampedPlaneEnd     = lineSegment.end
	float MAX_COORDS_FOR_PLANE = MAX_WORLD_COORD - SKYBOX_BUFFER

	// Clamp the start position to the ring so you don't start in the deathfield
	bool adjustedStart = false
	if ( clampToRing && DistanceSqr( < mapCenter.x, mapCenter.y, planeHeight >, clampedPlaneStart ) > DistanceSqr( < mapCenter.x, mapCenter.y, planeHeight >, startPos ) )
	{
		clampedPlaneStart = startPos
		adjustedStart = true
	}

	Assert( IsEqualFloat( fabs( clampedPlaneStart.x ), MAX_COORDS_FOR_PLANE ) || fabs( clampedPlaneStart.x ) <= MAX_COORDS_FOR_PLANE )
	Assert( IsEqualFloat( fabs( clampedPlaneStart.y ), MAX_COORDS_FOR_PLANE ) || fabs( clampedPlaneStart.y ) <= MAX_COORDS_FOR_PLANE )
	Assert( IsEqualFloat( fabs( clampedPlaneStart.z ), MAX_COORDS_FOR_PLANE ) || fabs( clampedPlaneStart.z ) <= MAX_COORDS_FOR_PLANE )
	Assert( IsEqualFloat( fabs( clampedPlaneEnd.x ), MAX_COORDS_FOR_PLANE ) || fabs( clampedPlaneEnd.x ) <= MAX_COORDS_FOR_PLANE )
	Assert( IsEqualFloat( fabs( clampedPlaneEnd.y ), MAX_COORDS_FOR_PLANE ) || fabs( clampedPlaneEnd.y ) <= MAX_COORDS_FOR_PLANE )
	Assert( IsEqualFloat( fabs( clampedPlaneEnd.z ), MAX_COORDS_FOR_PLANE ) || fabs( clampedPlaneEnd.z ) <= MAX_COORDS_FOR_PLANE )

	// We may need to shorten the wait times due to line clamping making the line shorter before and after the playable space
	float actualUnitsBeforeJumpAllowed = Distance( clampedPlaneStart, jumpStart )
	float expectedJumpDelayFrac = actualUnitsBeforeJumpAllowed / unitsBeforeJumpAllowed
	jumpDelay *= ( adjustedStart ? max( 0.6, expectedJumpDelayFrac ) : expectedJumpDelayFrac )
	result.jumpDelay = jumpDelay

	float jumpAllowedDist = Distance( clampedPlaneStart + ( planeVec * jumpDelay * flyOverMapSpeed ), jumpEnd )
	result.flyOverMapDuration = jumpAllowedDist / flyOverMapSpeed

	float actualUnitsToLeaveMap = Distance( jumpEnd, clampedPlaneEnd )
	float leaveMapFrac          = actualUnitsToLeaveMap / unitsToLeaveMap
	planeLeaveMapDuration *= leaveMapFrac

	result.clampedPlaneStart = clampedPlaneStart
	result.clampedPlaneEnd = clampedPlaneEnd

	result.totalFlyDuration = result.flyOverMapDuration + jumpDelay + planeLeaveMapDuration

	SURVIVAL_SetPlaneJumpStartPos( result.clampedPlaneStart )
	SURVIVAL_SetPlaneJumpEndPos( result.clampedPlaneEnd )

	return [ result ]
}
#endif // SERVER

#if SERVER
void function EntitiesDidLoad()
{
	FlagSet( "DeathFieldPaused" )

	// Set Final Circle and Evac Data
	EvacDataInit()

	// Set the announcer to be Rev
	SurvivalCommentary_SetHost( eSurvivalHostType.REV_ARMY )
}
#endif // SERVER

#if SERVER
// Set where the final circle and evac location will be
void function EvacDataInit()
{
	#if DEVELOPER
		Assert( !Flag( "FinalCircleEvacInitialized" ), "ShadowArmy: Initializing final circle twice" )
	#endif // DEV

	// Check if nodes have been placed for evac locations in Level Ed, use them instead of hardcoded positions
	bool didGetValidEvacPositions = false
	if ( file.evacLocationNodes.len() > 0 )
	{
		// Go through and only grab evac locations that have evac ships associated with them
		array < entity > validEvacLocations
		foreach ( evacLocationNode in file.evacLocationNodes )
		{
			if ( IsValid( evacLocationNode ) && evacLocationNode in file.evacLocationToEvacShipLocationsTable && file.evacLocationToEvacShipLocationsTable[ evacLocationNode ].len() > 0 )
				validEvacLocations.append( evacLocationNode )
		}

		// Only continue with valid evac locations
		if ( validEvacLocations.len() > 0 )
		{
			file.evacLocationNodes = validEvacLocations

			// Pick a Random Evac Location to use
			entity evacLocationEnt = file.evacLocationNodes.getrandom()
			file.evacLocationData.evacLocation = evacLocationEnt.GetOrigin()
			file.evacLocationData.evacShipLocationNodes = file.evacLocationToEvacShipLocationsTable[ evacLocationEnt ]
			didGetValidEvacPositions = true
		}
	}

	#if DEVELOPER
		Assert( didGetValidEvacPositions, "ShadowArmy: Didn't get valid Evac Positions" )
	#endif // DEV

	// Circle Data is based on evac location
	SURVIVAL_AddOverrideCircleLocation( file.evacLocationData.evacLocation, 0, true )

	// We have our final circle evac data
	FlagSet( "FinalCircleEvacInitialized" )
}
#endif //SERVER

#if SERVER
// Set data first time the player connects to the match
void function OnPlayerConnected( entity player )
{
	if ( !IsValid( player ) )
		return

	#if DEVELOPER
		if ( GetCurrentPlaylistVarBool( "dev_force_revenant", false ) )
		{
			//AllianceProximity_SetTeamToAlliance_Dev( SHADOWARMY_REVENANT_ALLIANCE )
		}

		if ( GetCurrentPlaylistVarBool( "dev_force_legend", false ) )
		{
			//AllianceProximity_SetTeamToAlliance_Dev( SHADOWARMY_LEGEND_ALLIANCE )
		}
	#endif
}
#endif // SERVER

#if SERVER
// Make sure data on the Client is up to date if a Client connects mid match
void function OnPlayerReConnected( entity player )
{
	if ( !IsValid( player ) )
		return

	// If the player joins a little late, make sure the alliance setting flag is set correctly on the Client
	if ( Flag( "AllianceAssignmentComplete" ) )
		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_SetAllianceAssignmentCompleteFlag" )

	// If the Evac objective is active, update the evac target count on the Client ( setting it to a value over 0 triggers the element to appear )
	if ( file.evacTargetCount > 0 )
		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_UpdateEvacTargetCountOnHud", file.evacTargetCount )

	// If the player is a legend and we have already started the playing gamestate, add a damage callback to track damage done to them by melee revs
	if ( GetGameState() == eGameState.Playing && !ShadowArmy_IsPlayerOnShadowArmy( player ) && !player.e.entPostDamageCallbacks.contains( OnLegendPostDamaged ) )
		AddEntityCallback_OnPostDamaged( player, OnLegendPostDamaged )
}
#endif // SERVER

#if SERVER
// All teams start on the Legend Alliance, we use this function to put some of these teams on to the Rev Alliance for match start
// Currently this allows us to control how many teams end up on the Rev Alliance
// In the future we can do extra logic here to balance the teams or try to avoid putting the same people on to Rev alliance each game
void function ShadowArmy_SetTeamsToRevAllianceOnMatchStart()
{
	array< int > allTeamsSorted = AllianceProximity_GetAllTeamsInAlliances( false )

	// We used to sort teams here based on how many times each player on a team was in a match where they started on the Rev Alliance
	// ToDo: If we want that functionality again we need to undo the changes done to remove the numConsecutiveRevMatches persistent var in R5DEV-511106
	// For now we just set the teams array to be randomized
	allTeamsSorted.randomize()
	// Assign teams to Rev Alliance
	int revTeamCount = 0
	int goalRevTeamCount = ShadowArmy_GetNumRevSquadsForMatchStart()

	#if DEVELOPER
		// Go through and remove teams that have been set to an alliance through Debug. Don't want to change them since it is something someone set for testing
		//array < int > teamsAddedToAllianceThroughDebug = AllianceProximity_GetTeamsSetToAllianceThroughDevCommand_Dev()
		//for ( int i = allTeamsSorted.len() - 1; i >= 0; i-- )
		//{
		//	if ( teamsAddedToAllianceThroughDebug.contains( allTeamsSorted[ i ] ) )
		//		allTeamsSorted.remove( i )
		//}
	#endif // DEV

	foreach ( team in allTeamsSorted )
	{
		if ( revTeamCount < goalRevTeamCount )
		{
			AllianceProximity_SetTeamToAlliance( team, SHADOWARMY_REVENANT_ALLIANCE )
			revTeamCount++
		}
		else
		{
			break
		}
	}

	// Once alliances are set, make sure we update the consecutive matches as Rev value for each player and set Rev Alliance players to Melee Rev Form
	array < entity > allPlayersArray = GetPlayerArray()

	foreach ( player in allPlayersArray )
	{
		if ( !IsValid( player ) )
			continue

		if ( ShadowArmy_IsPlayerOnShadowArmy( player ) )
			player.SetPlayerNetInt( "shadowArmy_PlayerForm", eShadowArmyRespawnForm.SHADOW )

		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_SetAllianceAssignmentCompleteFlag" )
	}

	FlagSet( "AllianceAssignmentComplete" )
}
#endif // SERVER

#if CLIENT
// Set the alliance assignment complete flag on the Client so Character select knows when it is ok to proceed
// This is a safeguard because Character Select Logic and Alliance setting logic is triggered off the same callback.
// Want to make sure alliances are set before character select runs logic based on alliances for players
void function ShadowArmy_ServerCallback_SetAllianceAssignmentCompleteFlag()
{
	FlagSet( "AllianceAssignmentComplete" )
}
#endif // CLIENT

#if SERVER
// When the ring round changes decrease the size of the evac location map area hint
void function ShadowArmy_OnRoundChanged( int stage, float nextCircleStartTime )
{
	printt( "Shadow Army: ShadowArmy_OnRoundChanged stage: " + stage )

	UpdateEvacWaypointVisibility( true, stage )

	// Trigger Announcer Commentary here since we have some custom logic
	if ( GetGameState() == eGameState.Playing )
	{
		if ( stage > GetCurrentPlaylistVarInt( "survival_death_field_start_stage", 0 ) )
			PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOWARMY_BEGIN_ROUND ) )
		else
			thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOWARMY_MATCH_START ), SHADOWARMY_LEGEND_SPAWN_FADE_FROM_BLACK_HOLD_DURATION + SHADOWARMY_LEGEND_SPAWN_FADE_FROM_BLACK_FADE_DURATION )
	}
}
#endif //SERVER

#if CLIENT
// When the ring round changes make sure we trigger the expected music level for players
void function ShadowArmy_OnRoundChanged_Client( int stage, float nextCircleStartTime )
{
	// Trigger music ramp up
	if ( stage == GetRingStageWhenEvacLocationRevealed() )
		UpdateMusicRampUpLevel( eShadowArmyMusicRampLevels.PRE_EVAC_SEQUENCE )
}
#endif //CLIENT

#if SERVER
void function OnSkydiveCustomTrailsInitialized( entity player )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	if ( ShadowArmy_IsPlayerOnShadowArmy( player ) )
	{
		ItemFlavor flav = GetItemFlavorByAsset( SKYDIVE_TRAIL_SHADOWARMY_REV )
		SetOverrideSkydiveTrailPackageForPlayer( SkydiveTrail_GetSkyDiveTrailPackageFromItemFlavor( flav ), player )
	}
}
#endif //SERVER

#if SERVER
// Determine which plane will be assigned to which alliance
// We want the Legends plane to be furthest from Evac
const int EXPECTED_PLANE_COUNT = 2
table < int, int > function ShadowArmy_GetAllianceToPlaneIndexAssignment( int numPlanes, array < vector > centerPos )
{
	#if DEVELOPER
		Assert( numPlanes == EXPECTED_PLANE_COUNT, "ShadowArmy: Running ShadowArmy_GetAllianceToPlaneIndexAssignment with " + numPlanes + " but expect " + EXPECTED_PLANE_COUNT )
		Assert( centerPos.len() >= EXPECTED_PLANE_COUNT, "ShadowArmy: Running ShadowArmy_GetAllianceToPlaneIndexAssignment with " + centerPos.len() + " center positions but need atleast " + EXPECTED_PLANE_COUNT )
	#endif // DEV

	table < int, int > allianceToPlaneIndex
	int furthestPlaneFromEvacIndex = 0
	float furthestDistSqr = 0
	for ( int i = 0; i < EXPECTED_PLANE_COUNT; i++ )
	{
		float distSqr = Length2DSqr( centerPos[i] - file.evacLocationData.evacLocation )
		if ( distSqr > furthestDistSqr )
		{
			furthestPlaneFromEvacIndex = i
			furthestDistSqr = distSqr
		}
	}

	allianceToPlaneIndex[ SHADOWARMY_LEGEND_ALLIANCE ] <- furthestPlaneFromEvacIndex
	int otherPlaneIndex = furthestPlaneFromEvacIndex == 0 ? 1 : 0
	allianceToPlaneIndex[ SHADOWARMY_REVENANT_ALLIANCE ] <- otherPlaneIndex
	return allianceToPlaneIndex
}
#endif //SERVER

#if SERVER
// Set up all the expected elements for the Revenant Dropship
const vector DECAL_OFFSET = < -0.0419921875, -0.1123046875, -199.88671875 >
void function ShadowArmy_SetupRevenantDropship( entity dropship )
{
	if ( !IsValid( dropship ) )
		return

	vector dropshipLoc = dropship.GetOrigin()
	vector dropshipAngles = dropship.GetAngles()

	// Set the model for the ship
	dropship.SetValueForModelKey( SHADOWARMY_REVENANT_PLANE_MODEL )

	// Set the skin for the ship
	dropship.SetSkin( 1 )

	// Add the decal
	entity decal = CreateEntity( "prop_script" )
	decal.SetValueForModelKey( SHADOWARMY_REVENANT_PLANE_DECAL )
	decal.kv.fadedist    = -1
	decal.kv.renderamt   = 255
	decal.kv.rendercolor = "255 255 255"
	decal.kv.solid       = 0 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	decal.SetOrigin( dropshipLoc + DECAL_OFFSET )
	decal.SetAngles( dropshipAngles )
	decal.NotSolid()
	decal.DisableHibernation()
	DispatchSpawn( decal )
	decal.SetParent( dropship )
	decal.Show()

	// Add Thruster Glow
	entity thrusters = CreateEntity( "prop_script" )
	thrusters.SetValueForModelKey( SHADOWARMY_REVENANT_PLANE_THRUSTERS )
	thrusters.kv.fadedist    = -1
	thrusters.kv.renderamt   = 255
	thrusters.kv.rendercolor = "255 255 255"
	thrusters.kv.solid       = 0 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	thrusters.SetOrigin( dropshipLoc )
	thrusters.SetAngles( dropshipAngles )
	thrusters.NotSolid()
	thrusters.DisableHibernation()
	DispatchSpawn( thrusters )
	thrusters.SetParent( dropship )
	thrusters.Show()

	// Add Thruster VFX
	thread ShadowArmy_ManageDropShipVFX_Thread( dropship )
}
#endif //SERVER

#if SERVER
// Thread that spawns and cleans up custom Rev Dropship VFX
void function ShadowArmy_ManageDropShipVFX_Thread( entity dropship )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	// Wait for the dropship to be dispatch spawned ( so the attachment points are available )
	WaitFrame()

	if ( !IsValid( dropship ) )
		return

	array < entity > vfxArray

	EndSignal( dropship, "OnDestroy" )

	OnThreadEnd(
		function() : ( vfxArray )
		{
			foreach ( vfx in vfxArray )
			{
				if ( IsValid( vfx ) )
					vfx.Destroy()
			}
		}
	)

	// Add Trail VFX
	int trailAttachmentID = dropship.LookupAttachment( "ship_bottom" )
	if ( trailAttachmentID > 0 )
	{
		entity trailVFX = StartParticleEffectOnEntity_ReturnEntity( dropship, GetParticleSystemIndex( SHADOWARMY_REVENANT_PLANE_TRAIL ), FX_PATTACH_POINT_FOLLOW, trailAttachmentID )
		trailVFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
		vfxArray.append( trailVFX )
	}

	WaitForever()
}
#endif //SERVER

#if SERVER
// Display a hint for Revs about becoming Red Eyed Rev when they first land in the match
void function ShadowArmy_OnPlayerLandedFromPlane( entity player )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	if ( ShadowArmy_IsPlayerInShadowForm( player ) )
		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowHinttMessage", eShadowArmyHintIndex.FULL_REV_CRITERIA_NO_DAM_HINT, 0, 0 )
}
#endif //SERVER

#if SERVER
// Run logic when a player disconnects
void function OnPlayerDisconnected( entity player )
{
	// Test for logic that occurs when players leave the match ( like ending the match if a whole alliance quit )
	thread RunPlayerCountDependantLogicDelayed_Thread()
}
#endif // SERVER

#if SERVER
// Run delayed logic that relies on player count changes
// Need to do this because we want to check for player count changes when players leave. But the match behavior end and player disconnected callbacks occur before the player counts get affected.
const float CHECK_FOR_EMPTY_ALLIANCE_DELAY = 3.0
void function RunPlayerCountDependantLogicDelayed_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	OnThreadEnd(
		function() : ()
		{
			TryEndGameFromAllianceForfeit()
		}
	)

	wait CHECK_FOR_EMPTY_ALLIANCE_DELAY
}
#endif // SERVER

#if SERVER
// Test to see if we should be ending the game early because a full alliance is missing
void function TryEndGameFromAllianceForfeit()
{
	// Don't want to end the game before the playing gamestate or once we have already determined a winner
	if ( GetGameState() != eGameState.Playing || GamemodeUtility_IsWinnerBeingDetermined() )
		return

	// Test to see if there is an empty team, end the game early if there is
	int legendPlayerCount = AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false )
	int revPlayerCount = AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, false )

	if ( legendPlayerCount == 0 && revPlayerCount == 0 )
		ShadowArmy_SetWinner( SHADOWARMY_REVENANT_ALLIANCE, eWinReason.TEAM_FORFEIT )
	else if ( legendPlayerCount == 0 )
		ShadowArmy_SetWinner( SHADOWARMY_REVENANT_ALLIANCE, eWinReason.TEAM_FORFEIT )
	else if ( revPlayerCount == 0 )
		ShadowArmy_SetWinner( SHADOWARMY_LEGEND_ALLIANCE, eWinReason.TEAM_FORFEIT )
}
#endif // SERVER



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SUPPORTING GET FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#if SERVER
// Get the location where we want to spawn Legends on match start
array< vector > function ShadowArmy_GetLegendMatchStartSpawnLocations( int numSpawnLocations = 1 )
{
	#if DEVELOPER
		Assert( Flag( "FinalCircleEvacInitialized" ), "ShadowArmy: Running ShadowArmy_GetLegendMatchStartSpawnLocations before setting up Evac Location" )
	#endif // DEV
	Assert( numSpawnLocations > 0, "The requested number of spawn locations must be greater than 0" )

	// Find a valid position furthest away from the Evac Location
	// First find the zone furthest away from the Evac point
	array< int > allMapZoneIDs = MapZones_GetAllZoneIDs_Sorted( true, false )

	// Figure out how far away from the ring edge this zone needs to be to be considered good ( don't want to search for spawn points outside of the ring )
	int defaultLootRealm = Survival_Loot_GetDefaultRealm()
	vector circleCenter = SURVIVAL_GetDeathFieldCenter( defaultLootRealm )
	float circleRadius  = SURVIVAL_GetDeathFieldCurrentRadius( defaultLootRealm )
	float startSpawnRadius = ShadowArmy_GetLegendMatchStartSpawnRadius()
	float maxDist = circleRadius - startSpawnRadius
	Assert( maxDist > 0, "Deathfield current radius is too small. circleRadius:" + circleRadius + "startSpawnRadius:" + startSpawnRadius )

	float maxSafeDistSqr = maxDist * maxDist
	int maxTeams = GetCurrentPlaylistVarInt( "max_teams", 20 )
	int maxPlayers = GetCurrentPlaylistVarInt( "max_players", 60 )
	int maxSquadSize = maxPlayers / maxTeams

	array< vector > validLocations
	for ( int i = allMapZoneIDs.len() - 1; i >= 0; i-- )
	{
		vector zonePos = MapZones_GetTriggerForZone( allMapZoneIDs[ i ] ).GetCenter()
		float zonePosToSafeEdgeDistSqr = Length2DSqr( zonePos - circleCenter )
		if ( zonePosToSafeEdgeDistSqr < maxSafeDistSqr )
		{
			array<vector> lootPoints = VectorArrayWithin( SURVIVAL_GetAllLootLocationsCopy(), zonePos, startSpawnRadius )
			if ( lootPoints.len() >= maxSquadSize )
				validLocations.append( zonePos )
		}
	}

	vector evacLocation = file.evacLocationData.evacLocation
	validLocations.sort( int function( vector a, vector b ) : ( evacLocation ) {
		return SortLowestFloat( Distance2DSqr( evacLocation, a ), Distance2DSqr( evacLocation, b ) )
	} )

	int numToSort = minint( validLocations.len(), numSpawnLocations )

	return validLocations.slice( validLocations.len() - numToSort, validLocations.len() )
}
#endif //SERVER

#if SERVER
// Get the radius we want to search for spawn points for Legends at match start
const float DEFAULT_SPAWN_RADIUS = 7874.0 // around 200m
float function ShadowArmy_GetLegendMatchStartSpawnRadius()
{
	float safeZoneRadius = SURVIVAL_GetSafeZoneRadius( Survival_Loot_GetDefaultRealm() )

	// Choose the smaller of the two ( safe zone radius and default radius )
	return min( DEFAULT_SPAWN_RADIUS, safeZoneRadius )
}
#endif //SERVER

#if SERVER || CLIENT
// Get an enemy squad to display on the intro screen for this alliance
// The flow is character select -> your squad -> enemy squad   ( this function gets the squad to display for the enemy squad by passing in the alliance number for the players squad, do NOT pass in the alliance of the enemy squad you want )
array < entity > function ShadowArmy_GetEnemySquadPlayersForAllianceIntro( int alliance )
{
	int enemyAlliance = AllianceProximity_GetOtherAlliance( alliance )

	// If we are running the mode with no teams starting on the Rev Alliance, return an empty array
	if ( enemyAlliance == SHADOWARMY_REVENANT_ALLIANCE && ShadowArmy_GetNumRevSquadsForMatchStart() <= 0 )
		return []

	array < int > populatedEnemySquads = AllianceProximity_GetPopulatedTeamsInAlliance( enemyAlliance )
	int finalSquad
	bool shouldSortFinalSquad = false

	// Check if we have any populated squads ( which we really always should ). If not, just grab any squad in the alliance
	if ( populatedEnemySquads.len() > 0 )
	{
		// Make a list of enemy squads that have all 3 players in them, prioritize using these squads to display
		array < int > fullEnemySquads = []
		int maxTeamSize = GetMaxTeamSizeForPlaylist( GetCurrentPlaylistName() )
		foreach ( enemySquad in populatedEnemySquads )
		{
			if ( GetPlayerArrayOfTeam( enemySquad ).len() == maxTeamSize )
				fullEnemySquads.append( enemySquad )
		}

		// Figure out which array of squads should be used to do further testing
		array < int > finalEnemySquads = fullEnemySquads.len() > 0 ? fullEnemySquads : populatedEnemySquads

		// If the enemy squad is legends, see if there are any squads with Loba selected or secondary story characters
		if ( enemyAlliance == SHADOWARMY_LEGEND_ALLIANCE )
		{
			array < int > lobaSquads
			array < int > secondaryCharSquads
			foreach ( enemySquad in finalEnemySquads )
			{
				array < entity > enemySquadPlayers = GetPlayerArrayOfTeam( enemySquad )
				foreach ( enemyPlayer in enemySquadPlayers )
				{
					if ( ShadowArmy_IsPlayerLoba( enemyPlayer ) )
						lobaSquads.append( enemySquad )
					else if ( ShadowArmy_IsPlayerSecondaryStoryCharacter( enemyPlayer ) )
						secondaryCharSquads.append( enemySquad )
				}
			}

			if ( lobaSquads.len() > 0 )
			{
				finalEnemySquads = lobaSquads
				shouldSortFinalSquad = true
			}
			else if ( secondaryCharSquads.len() > 0 )
			{
				finalEnemySquads = secondaryCharSquads
				shouldSortFinalSquad = true
			}
		}

		// Pick a squad from the filtered squad list
		// We could do additional logic to find the squad with the best placement/kills/damage from the previous match but it doesn't really seem relevant or matter in this context
		// Grabbing the first squad instead of a random one so it is more likely to line up between all the players on the same team. It isn't super important that they do however
		finalSquad = finalEnemySquads[ 0 ]
	}
	else
	{
		// Grab any squad in the alliance
		array < int > teamsInAllianceArray = AllianceProximity_GetTeamsInAlliance( enemyAlliance )
		// Should never happen under normal circumstances, but if there are no teams in the enemy alliance make sure we don't crash and just return an empty array
		if ( teamsInAllianceArray.len() > 0 )
			finalSquad = teamsInAllianceArray[ 0 ]
		else
			return []
	}

	// Grab the array of players to return based on the final squad chosen
	array < entity > finalSquadPlayers = GetPlayerArrayOfTeam( finalSquad )

	// If the final squad has Loba or secondary story characters, sort the squad so those characters appear in the middle
	if ( shouldSortFinalSquad )
	{
		finalSquadPlayers.sort( int function( entity a, entity b ) : ( ) {
			// Loba players take priority
			bool aIsLoba = ShadowArmy_IsPlayerLoba( a )
			bool bIsLoba = ShadowArmy_IsPlayerLoba( b )

			if ( aIsLoba != bIsLoba )
			{
				if ( aIsLoba )
					return -1  // a, b

				if ( bIsLoba )
					return 1 // b, a
			}

			// Secondary story characters take second priority
			bool aIsSecondaryCharacter = ShadowArmy_IsPlayerSecondaryStoryCharacter( a )
			bool bIsSecondaryCharacter = ShadowArmy_IsPlayerSecondaryStoryCharacter( b )

			if ( aIsSecondaryCharacter != bIsSecondaryCharacter )
			{
				if ( aIsSecondaryCharacter )
					return -1  // a, b

				if ( bIsSecondaryCharacter )
					return 1 // b, a
			}

			return 0 // no change
		} )
	}

	return finalSquadPlayers
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Determine if the passed in player is using Loba
bool function ShadowArmy_IsPlayerLoba( entity player )
{
	if ( !IsValid( player ) )
		return false

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetCharacterRef( character ).tolower()

	if ( characterRef == "character_loba" )
		return true

	return false
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Determine if the passed in player is using one of the secondary characters that have been present in lore trailers around this event
bool function ShadowArmy_IsPlayerSecondaryStoryCharacter( entity player )
{
	if ( !IsValid( player ) )
		return false

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetCharacterRef( character ).tolower()
	bool isSecondaryCharacter = false

	switch ( characterRef )
	{
		case "character_lifeline":
		case "character_valkyrie":
		case "character_madmaggie":
		case "character_crypto":
			isSecondaryCharacter = true
			break
		default:
			break
	}

	return isSecondaryCharacter
}
#endif // SERVER || CLIENT

#if SERVER
// Prevent Survival Logic from ending the match
bool function ShadowArmy_IsSquadReallyEliminated( int team )
{
	// Players on the Rev alliance are never eliminated
	if ( AllianceProximity_GetAllianceFromTeam( team ) == SHADOWARMY_REVENANT_ALLIANCE )
		return false

	// Players on the Legend Alliance are eliminated when all 3 players in a squad are downed or dead
	// Except when we turn off alliance switching at the end of the match. Those players can continue to be respawned
	if ( !file.canLivingLegendsRespawnAsShadows )
		return false

	// Check if the squad is eliminated
	array < entity > teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( player in teamPlayers )
	{
		if ( IsValid( player ) && player.GetPlayerNetInt( "respawnStatus" ) != eRespawnStatus.PLAYER_ELIMINATED )
			return false
	}

	return true
}
#endif //#if SERVER

#if SERVER
// Prevent players from being spawned during character select, they are spawning on the ground and then being spawned a second time with the system we actually use for spawning players
bool function ShadowArmy_SupressGameStartSpawn()
{
	return false
}
#endif // SERVER

#if SERVER
// Return whether the player is the final player on the Living Legend Alliance
bool function IsPlayerFinalLivingLegend( entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( !player.IsPlayer() )
		return false

	if ( !file.isOnFinalLegend )
		return false

	if ( ShadowArmy_IsPlayerOnShadowArmy( player ) )
		return false

	return true
}
#endif //#if SERVER

#if SERVER || CLIENT
// Return whether the player is on the Shadow Army alliance
bool function ShadowArmy_IsPlayerOnShadowArmy( entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( !player.IsPlayer() )
		return false

	return AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == SHADOWARMY_REVENANT_ALLIANCE
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return whether the player should enter a bleedout state
bool function ShadowArmy_ShouldEnterBleedout( entity player )
{
	if ( ShadowArmy_IsPlayerOnShadowArmy( player ) )
		return false

	return true
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return whether the player's current form is a shadow form
bool function ShadowArmy_IsPlayerInShadowForm( entity player )
{
	if ( !IsValid( player ) )
		return false

	return player.GetPlayerNetInt( "shadowArmy_PlayerForm" ) == eShadowArmyRespawnForm.SHADOW
}
#endif // SERVER || CLIENT

#if SERVER
// Based on the current form, figure out which form the player should respawn in next
// We might want to limit the number of Full Revenants or only allow players full revenant form after a certain game state or accomplishment
// For now players always respawn as a Revenant and AI spawn as Shadow Revs once their squad gets wiped
int function GetNextPlayerRespawnForm( entity player, int previousForm )
{
	int nextForm

	switch( previousForm )
	{
		case eShadowArmyRespawnForm.LIVING_LEGEND:
			nextForm = eShadowArmyRespawnForm.LIVING_LEGEND
			break
		case eShadowArmyRespawnForm.FULL_REVENANT:
			nextForm = eShadowArmyRespawnForm.SHADOW
			break
		case eShadowArmyRespawnForm.SHADOW:
			nextForm = eShadowArmyRespawnForm.SHADOW
			break
		default:
			#if DEVELOPER
				Assert( false, "Shadow Army: Unsupported previous form passed in for player in GetNextPlayerRespawnForm" )
			#endif // DEV
			break
	}

	return nextForm
}
#endif //SERVER

#if SERVER
// Check to make sure there are still players on the Rev Army who have not been a Full Rev yet
bool function ShouldClearPreviousFullRevsArray()
{
	if ( file.previousFullRevsArray.len() >= AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, false ) )
		return true

	return false
}
#endif // SERVER

#if SERVER || CLIENT
// Get how many players are remaining on the Living Legends Alliance
int function GetLivingLegendsCount()
{
	return AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )
}
#endif //SERVER || CLIENT

#if SERVER || CLIENT
// Get how many players are remaining on the Revenant Alliance
int function GetLivingRevenantsCount()
{
	return AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, true )
}
#endif //SERVER || CLIENT

#if SERVER
// Get how many living legend squads are remaining
// We don't eliminate legends in the last few remaining squads and we switch over teams to the Rev Alliance when we do "eliminate" squads
// So here we return the number of teams in the Legend Alliance
// We do end the match if the living player count drops to 0 at any point, so in that scenario display 0 Legend squads remaining
int function GetRemainingLivingLegendSquadsCount()
{
	return GetLivingLegendsCount() > 0 ? AllianceProximity_GetPopulatedTeamsInAlliance( SHADOWARMY_LEGEND_ALLIANCE ).len() : 0
}
#endif //SERVER

// Get the current phase of the match. Phases are defined in eShadowArmyGamePhase
int function ShadowArmy_GetCurrentGamePhase()
{
	return GetGlobalNetInt( "shadowArmy_GamePhase" )
}

#if SERVER
// Get the player that is spawned in Full Rev form
entity function GetLivingFullRevPlayer()
{
	if ( IsValid( file.fullRevOrCandidatePlayer ) && IsAlive( file.fullRevOrCandidatePlayer ) && file.fullRevOrCandidatePlayer.GetPlayerNetInt( "shadowArmy_PlayerForm" ) == eShadowArmyRespawnForm.FULL_REVENANT )
		return file.fullRevOrCandidatePlayer

	return null
}
#endif //SERVER

#if SERVER
// Get the player that is marked to spawn in Full Rev form
entity function GetSelectedFullRevCandidatePlayer()
{
	if ( IsValid( file.fullRevOrCandidatePlayer ) && file.fullRevOrCandidatePlayer.GetPlayerNetInt( "shadowArmy_PlayerForm" ) != eShadowArmyRespawnForm.FULL_REVENANT )
		return file.fullRevOrCandidatePlayer

	return null
}
#endif //SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HANDLE PLAYER DEATH
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
// Track damage done to Legends by Revs to use as criteria for selecting Red Eyed Revs
void function OnLegendPostDamaged( entity player, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) || !attacker.IsPlayer() )
		return

	// Only track damage done in melee form
	if ( ShadowArmy_IsPlayerInShadowForm( attacker ) )
	{
		float damageDealt = DamageInfo_GetDamage( damageInfo )
		float lifetimeDamageDealt = 0.0

		if ( attacker in file.shadowPlayerToDamageDealtTable )
			lifetimeDamageDealt = file.shadowPlayerToDamageDealtTable[ attacker ]

		file.shadowPlayerToDamageDealtTable[ attacker ] <- lifetimeDamageDealt + damageDealt

		// If we are searching for a Rev, Send a signal when damage is dealt
		if ( file.isWaitingOnMeleeRevDamageSignal && !file.previousFullRevsArray.contains( attacker ) )
			svGlobal.levelEnt.Signal( "ShadowRevDealtDamage" )
	}
}
#endif //SERVER

#if SERVER
// Turn off alliance switching for Living Legends. They can still be respawned from beacons.
void function TurnOffRespawnForLivingLegends()
{
	// Only turn it off if it is currently turned on
	if ( file.canLivingLegendsRespawnAsShadows )
	{
		printt( "Shadow Army: Turning off alliance switching for Living Legends" )
		file.canLivingLegendsRespawnAsShadows = false
		ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.ALLIANCE_SWITCH_DISABLED_LEGEND, eShadowArmyMessageIndex.ALLIANCE_SWITCH_DISABLED_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
	}
}
#endif //SERVER

#if SERVER
// Logic that fires when a player is downed
void function OnPlayerDowned( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( victim ) )
		return

	// If the attacker was a Shadow, give them special boons depending on settings
	int amountToHealShadowOnDown = GetAmountToHealShadowPlayerOnDown( attacker )
	if ( amountToHealShadowOnDown > 0 && attacker.IsPlayer() && ShadowArmy_IsPlayerInShadowForm( attacker ) && attacker != victim && IsAlive( attacker ) )
		GamemodeUtility_HealPlayerByAmount( attacker, amountToHealShadowOnDown, true )
}
#endif //#if SERVER

#if SERVER
// When a player is killed, determine which alliance they are on and then perform the appropriate respawn behaviour based on the result
const float AMMO_THROW_STRENGTH = 125.0 // Finding the default 75 throws ammo too close together making it hard to grab the one you want
void function OnPlayerKilled( entity player, entity attacker, var damageInfo )
{
	// Check win conditions
	TryToDetermineWinner_Elimination()

	if ( !IsValid( player ) )
		return

	// Store the player form the player had on death
	int previousForm = player.GetPlayerNetInt( "shadowArmy_PlayerForm" )
	file.playerToPlayerFormOnDeath[ player ] <- previousForm
	bool isPlayerOnShadowArmy = ShadowArmy_IsPlayerOnShadowArmy( player )
	int currentGamePhase = ShadowArmy_GetCurrentGamePhase()
	int playerTeam = player.GetTeam()

	                           
		// Save the loadout the player had on death so they can potentially respawn with it
		if ( !isPlayerOnShadowArmy && ( Has_BR_Respawn_WithArmor() || Has_BR_Respawn_WithWeapons() ) )
			RespawnEquipped_Save( player )
                                  

	player.e.lastDeathPos = player.GetOrigin()
	player.e.lastDeathTime = Time()

	// Death FX
	vector deathOrigin = player.GetOrigin()
	thread CreateAirShake( deathOrigin, 2, 50, 1 )

	if ( IsValid( attacker ) && attacker.IsPlayer() && attacker != player )
	{
		// Should we heal the attacker?
		int amountToHealAttacker = 0

		if ( IsAlive( attacker ) )
		{
			// If the killer was a Shadow, give them special boons depending on settings
			if ( ShadowArmy_IsPlayerInShadowForm( attacker ) )
				amountToHealAttacker = GetAmountToHealShadowPlayerOnKill( attacker )
			else if ( GetLivingFullRevPlayer() == attacker ) // If the killer is a red eyed Rev, give them special boons depending on settings
				amountToHealAttacker = GetAmountToHealRedEyedRevPlayerOnKill()
			else if ( !ShadowArmy_IsPlayerOnShadowArmy( attacker ) ) // If the killer was a Legend, give them special boons depending on settings
				amountToHealAttacker = GetAmountToHealLegendPlayerOnKill()
		}

		if ( amountToHealAttacker > 0 )
			GamemodeUtility_HealPlayerByAmount( attacker, amountToHealAttacker, true )
	}

	// If the killed player is a Shadow, Spawn ammo and play VFX
	if ( player.IsPlayer() && ShadowArmy_IsPlayerInShadowForm( player ) )
		GamemodeUtility_SpawnDroppedAmmo ( player, attacker, damageInfo, AMMO_TO_DROP_ON_SHADOW_DEATH, AMMO_THROW_STRENGTH )

	// Don't allow a respawn when a squad is eliminated, this function works even if spawn group skydive isn't the set respawn method
	if ( SpawnGroupSkydive_IsSquadEliminated( playerTeam ) )
		return

	// If not on Shadow Army team, check if alliance switching should be turned off
	if ( !isPlayerOnShadowArmy && file.canLivingLegendsRespawnAsShadows && GetNumLivingSquadsToTurnOffAllianceSwitch() >= 0 && GetRemainingLivingLegendSquadsCount() <= GetNumLivingSquadsToTurnOffAllianceSwitch() )
		TurnOffRespawnForLivingLegends()

	SetPlayerUpForRespawn( player )
}
#endif //#if SERVER

#if SERVER
// Determine which form the player will respawn in and do alliance switch if necessary
const float FEW_SQUADS_COMMENTARY_DELAY = 6.0
void function SetPlayerUpForRespawn( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	// Track num times respawned
	player.e.repeatSpawnCount++
	// Figure out Player Respawn Form and store the message index to display on respawn
	int previousForm = player.GetPlayerNetInt( "shadowArmy_PlayerForm" )
	int nextRespawnForm = GetNextPlayerRespawnForm( player, previousForm )
	player.SetPlayerNetInt( "shadowArmy_PlayerForm", nextRespawnForm )

	// Do special logic for the Legends when they die
	int team = player.GetTeam()
	bool wasPreviousFormLivingLegend = previousForm == eShadowArmyRespawnForm.LIVING_LEGEND && AllianceProximity_GetAllianceFromTeam( team ) != SHADOWARMY_REVENANT_ALLIANCE

	if ( wasPreviousFormLivingLegend )
	{
		array < entity > teamPlayersArray = GetPlayerArrayOfTeam( team )

		// The whole squad is wiped and is switching alliances
		if (  GetPlayerArrayOfTeam_Alive( player.GetTeam() ).len() == 0 )
		{
			if ( file.canLivingLegendsRespawnAsShadows )
			{
				printt( "Shadow Army: Setting team: " + team + " to Shadow Army Alliance" )
				AllianceProximity_SetTeamToAlliance( team, SHADOWARMY_REVENANT_ALLIANCE )

				// This logic gets triggered when the last member of a squad is killed, need to set the spawn form for the players in the squad that died before this player to the correct shadow form
				foreach ( teamPlayer in teamPlayersArray )
				{
					if ( IsValid( teamPlayer ) && !IsAlive( teamPlayer ) )
					{
						teamPlayer.SetPlayerNetInt( "shadowArmy_PlayerForm", eShadowArmyRespawnForm.SHADOW )

						// Unlike skydive spawn logic where players respawn in a group, spawn near squad logic spawns players individually and they would have failed the intial checks to respawn because they were still on the Legend Alliance. Trigger a respawn here once the elimination occurred
						if ( GetRespawnStyle() == eRespawnStyle.SPAWN_NEAR_SQUAD )
							SetupPlayerForSpawnNearSquad( teamPlayer )

						// Remove damage callback since these players are no longer on the Legend alliance
						if ( teamPlayer.e.entPostDamageCallbacks.contains( OnLegendPostDamaged ) )
							RemoveEntityCallback_OnPostDamaged( teamPlayer, OnLegendPostDamaged )
					}
				}

				// Display Obituary message
				ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.LEGEND_TEAM_SWITCHED_TO_REV, eShadowArmyMessageIndex.LEGEND_TEAM_SWITCHED_TO_REV, eShadowArmyMessageType.OBIT_ONLY )
			}
		}
		else // Give a hint to go respawn your squadmate
		{
			player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_RESPAWN )
			thread ShadowArmy_RespawnBeacon_PingRespawnBeaconOnDelay_Thread( team, false )
		}

		int currentGamePhase = ShadowArmy_GetCurrentGamePhase()
		// Check if emergency evac should be called in. Need to do this check here because it is AFTER teams switch alliances. Otherwise the living legend squad count will be off by 1
		if ( currentGamePhase < eShadowArmyGamePhase.EVAC_OBJECTIVE && IsEmergencyEvac() )
		{
			printt( "Shadow Army: Going to Trigger Emergency Evac" )
			ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_LEGEND, eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
			svGlobal.levelEnt.Signal( "EmergencyEvacTriggered" )
			thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_ARMY_FEW_SQUADS ), FEW_SQUADS_COMMENTARY_DELAY )
		}

		// Check if we should play last Legend squad remaining announcer commentary
		TryPlayingLastSquadAnnouncerCommentary()

		// check if we should play half legend squad remaining announcer commentary
		TryPlayingHalfRemainingLegendSquadAnnouncerCommentary()
	}
}
#endif //SERVER

#if SERVER
// Determine if the whole squad or individual player is ready to respawn
bool function CanRespawnPlayerOrSquad( entity player )
{
	if ( !IsValid( player ) )
		return false

	// Only Rev Army players spawn using the skydive logic
	if ( ShadowArmy_IsPlayerOnShadowArmy( player ) )
		return true

	// Need to do a special check for squads that have just switched over to Rev Army ( the Alliance switch logic will not have run before this function is run in skydive logic )
	// First check if team switching should be turned off
	if ( file.canLivingLegendsRespawnAsShadows && GetNumLivingSquadsToTurnOffAllianceSwitch() >= 0 && GetRemainingLivingLegendSquadsCount() <= GetNumLivingSquadsToTurnOffAllianceSwitch() )
		TurnOffRespawnForLivingLegends()

	// If team switching is still active and the whole squad is waiting to respawn, respawn the squad together
	if ( file.canLivingLegendsRespawnAsShadows && IsSquadWaitingToRespawn( player.GetTeam() ) )
		return true

	return false
}
#endif //SERVER

#if SERVER
// If a squad just switched over to the Rev Alliance spawn them together in a group. Otherwise spawn players individually, there is logic in place in sh_spawn_group_skydive.nut to spawn any dead revs together
array < entity > function GetArrayOfSquadPlayersToRespawn( entity player )
{
	if ( !IsValid( player ) )
		return []

	if ( !ShadowArmy_IsPlayerOnShadowArmy( player ) )
	{
		int playerTeam = player.GetTeam()
		// If a player just switched over to the Rev Army Alliance, make sure the whole squad spawns
		if ( file.canLivingLegendsRespawnAsShadows && IsSquadWaitingToRespawn( playerTeam ) )
			return GetPlayerArrayOfTeam( playerTeam )
	}

	// Besides the above condition, players are put into spawn groups by themselves
	return [ player ]
}
#endif //SERVER

#if SERVER
array< array<entity> > function GetLegendGroups( array<entity> legendPlayers )
{
	array< array<entity> > legendGroups = []

	if ( legendPlayers.len() == 0 )
		return legendGroups

	while ( legendPlayers.len() > 0 )
	{
		array<entity> legendGroup = [ legendPlayers.pop() ]

		for ( int groupIdx = 0; groupIdx < legendGroup.len(); ++groupIdx )
		{
			for ( int playerIdx = legendPlayers.len() - 1; playerIdx >= 0; --playerIdx )
			{
				if ( DistanceSqr( legendPlayers[playerIdx].GetOrigin(), legendGroup[groupIdx].GetOrigin() ) <= MAX_DISTANCE_IN_GROUP_SQR )
				{
					legendGroup.append( legendPlayers[playerIdx] )
					#if DEVELOPER
						if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
						{
							//DebugDrawArrow( legendPlayers[playerIdx].GetOrigin(), legendGroup[groupIdx].GetOrigin(), 20, COLOR_BLUE, true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
						}
					#endif
					legendPlayers.fastremove( playerIdx )
				}
			}
		}
		legendGroups.append(legendGroup)
	}

	return legendGroups
}
#endif //SERVER

#if SERVER
const float MAX_DISTANCE_IN_GROUP = 1200
const float MAX_DISTANCE_IN_GROUP_SQR = MAX_DISTANCE_IN_GROUP * MAX_DISTANCE_IN_GROUP
const int MAX_ATTEMPTS_TO_FIND_SPAWN_POINT = 20
// Override function for picking a spawn point for Revenants spawning on the ground
Point function ShadowArmy_GetRevRespawnPoint( entity player, vector deathPos, bool shouldForceUseDeathPos )
{
	if ( shouldForceUseDeathPos )
		return GetRandomSpawnPointNearPos( player, deathPos )

	// If the player is the Full Rev, give an invalid spawn point so skydive is triggered instead
	if ( player == file.fullRevOrCandidatePlayer )
	{
		Point spawnPoint
		spawnPoint.origin = SPAWN_NEAR_SQUAD_INVALID_SPAWN_POINT_ORIGIN
		spawnPoint.angles = SPAWN_NEAR_SQUAD_INVALID_SPAWN_POINT_ANGLE
		return spawnPoint
	}

	//------------------ respawn near enemy
	// find Legend group to respawn near them
	array<entity> legendPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )
	int defaultRealm = Survival_Loot_GetDefaultRealm()
	for ( int legendIdx = legendPlayers.len() - 1; legendIdx >= 0; --legendIdx )
	{
		if ( !SURVIVAL_PosInSafeZone( defaultRealm, legendPlayers[legendIdx].GetOrigin() ) )
			legendPlayers.fastremove( legendIdx )
	}

	if ( legendPlayers.len() > 0 )
	{
		array< array<entity> > legendGroups = GetLegendGroups( legendPlayers )

		legendGroups.randomize()

		float safeZoneRadius = SURVIVAL_GetSafeZoneRadius( defaultRealm )
		vector safeZoneCenter = SURVIVAL_GetSafeZoneCenter( defaultRealm )

		foreach ( array<entity> legendGroup in legendGroups )
		{
			// find center
			vector total = <0, 0, 0>
			foreach ( entity legend in legendGroup )
			{
				total += legend.GetOrigin()
			}
			vector center = total / legendGroup.len()
			#if DEVELOPER
				if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
				{
					DebugDrawSphere( center, 20, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
				}
			#endif

			float farDistanceSqr = 0
			foreach ( entity legend in legendGroup )
			{
				float distanceSqr = DistanceSqr( legend.GetOrigin(), center )
				if ( distanceSqr > farDistanceSqr )
					farDistanceSqr = distanceSqr
			}

			// choose spawn point
			float minDist = RespawnNearSquad_GetMinDistFromEnemyForValidSpawn()
			Point spawnPoint

			float spawnRadius = sqrt( farDistanceSqr ) + minDist
			float distanceSqr = DistanceSqr( safeZoneCenter, center )

			if ( safeZoneRadius < spawnRadius )
				continue

			if ( pow( safeZoneRadius - spawnRadius, 2 ) >= distanceSqr )
			{
				spawnPoint.angles = Normalize( <RandomFloatRange(-1, 1), RandomFloatRange(-1, 1), 0> )
				spawnPoint.origin = center + spawnPoint.angles * spawnRadius
			}
			else
			{
				spawnRadius /= 2
				spawnPoint.angles = Normalize( <RandomFloatRange(-1, 1), RandomFloatRange(-1, 1), 0> )
				spawnPoint.origin = center + Normalize( safeZoneCenter - center ) * spawnRadius + spawnPoint.angles * spawnRadius
			}

			#if DEVELOPER
				if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
				{
					DebugDrawSphere( spawnPoint.origin, spawnRadius, int(COLOR_PINK.x), int(COLOR_PINK.y), int(COLOR_PINK.z), true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
				}
			#endif

			entity closestLegend = ShadowArmy_GetClosestLegend( spawnPoint.origin )

			if ( closestLegend == null )
				break

			float closestSqr = DistanceSqr( closestLegend.GetOrigin(), spawnPoint.origin )

			#if DEVELOPER
				if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
				{
					DebugDrawSphere( closestLegend.GetOrigin(), 20, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
				}
			#endif

			bool foundValidSpawnPoint = false

			// adjust spawn point depends on closest enemy position
			float maxDist = RespawnNearSquad_GetMaxDistFromEnemyForValidSpawn()
			float minDistSqr = minDist * minDist
			if ( closestSqr < minDistSqr )
			{
				for ( int i = 0; i < MAX_ATTEMPTS_TO_FIND_SPAWN_POINT; ++i )
				{
					spawnPoint.angles = Normalize( closestLegend.GetOrigin() - spawnPoint.origin )
					spawnPoint.origin = closestLegend.GetOrigin() - spawnPoint.angles * minDist
					closestLegend = ShadowArmy_GetClosestLegend( spawnPoint.origin )
					closestSqr = DistanceSqr( closestLegend.GetOrigin(), spawnPoint.origin )

					if ( closestSqr >= minDistSqr && SURVIVAL_PosInSafeZone( defaultRealm, spawnPoint.origin ) )
					{
						foundValidSpawnPoint = true
						break
					}
				}
			}
			else if ( closestSqr > maxDist * maxDist )
			{
				spawnPoint.angles = Normalize( closestLegend.GetOrigin() - spawnPoint.origin )
				spawnPoint.origin = closestLegend.GetOrigin() - spawnPoint.angles * maxDist
				foundValidSpawnPoint = true
			}
			else
			{
				foundValidSpawnPoint = true
			}

			if ( foundValidSpawnPoint )
			{
				spawnPoint.origin = NavMesh_GetClosestPoint( spawnPoint.origin )
				#if DEVELOPER
					if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
					{
						//DebugDrawArrow( closestLegend.GetOrigin(), spawnPoint.origin, 20, COLOR_YELLOW, true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
					}

					closestSqr = DistanceSqr( closestLegend.GetOrigin(), spawnPoint.origin )
					if ( closestSqr < minDistSqr )
						Warning( "Moved too close to legend after NavMesh_GetClosestPoint closestSqr:" + closestSqr + "minDistSqr:" + minDistSqr )
				#endif
				return spawnPoint
			}
		}
	}

	//------------------ respawn near squad
	int team = player.GetTeam()
	array<entity> playersOnMyTeam = GetPlayerArrayOfTeam_Alive( team )
	playersOnMyTeam.fastremovebyvalue( player )
	if ( playersOnMyTeam.len() > 0 )
	{
		playersOnMyTeam.randomize()
		foreach( entity teammate in playersOnMyTeam )
		{
			Point spawnPoint = GetRandomSpawnPointNearPos( player, teammate.GetOrigin() )
			if ( spawnPoint.origin != SPAWN_NEAR_SQUAD_INVALID_SPAWN_POINT_ORIGIN )
			{
				spawnPoint.origin = NavMesh_GetClosestPoint( spawnPoint.origin )
				if ( SURVIVAL_PosInsideDeathField( defaultRealm, spawnPoint.origin ) )
					return spawnPoint
			}
		}
	}

	//------------------ respawn near the Full Rev
	entity livingFullRevPlayer = GetLivingFullRevPlayer()
	if ( IsValid( livingFullRevPlayer ) && !livingFullRevPlayer.Player_IsSkydiving() )
	{
		Point spawnPoint = GetRandomSpawnPointNearPos( player, OriginToGround( livingFullRevPlayer.GetOrigin() ) )
		if ( spawnPoint.origin != SPAWN_NEAR_SQUAD_INVALID_SPAWN_POINT_ORIGIN )
		{
			spawnPoint.origin = NavMesh_GetClosestPoint( spawnPoint.origin )
			if ( SURVIVAL_PosInsideDeathField( defaultRealm, spawnPoint.origin ) )
				return spawnPoint
		}
	}

	//------------------ respawn near death pos
	Point spawnPoint = GetRandomSpawnPointNearPos( player, deathPos )
	if ( spawnPoint.origin != SPAWN_NEAR_SQUAD_INVALID_SPAWN_POINT_ORIGIN )
	{
		spawnPoint.origin = NavMesh_GetClosestPoint( spawnPoint.origin )
		spawnPoint.angles = <1, 0, 0>
		if ( SURVIVAL_PosInsideDeathField( defaultRealm, spawnPoint.origin ) )
			return spawnPoint
	}

	//------------------ respawn near safezone center
	spawnPoint = GetRandomSpawnPointNearPos( player, SURVIVAL_GetSafeZoneCenter( defaultRealm ) )
	if ( spawnPoint.origin == SPAWN_NEAR_SQUAD_INVALID_SPAWN_POINT_ORIGIN )
		spawnPoint.origin = SURVIVAL_GetSafeZoneCenter( defaultRealm )
	spawnPoint.origin = NavMesh_GetClosestPoint( spawnPoint.origin )
	spawnPoint.angles = <1, 0, 0>
	return spawnPoint
}
#endif //SERVER

#if SERVER
entity function ShadowArmy_GetClosestLegend( vector origin )
{
	array<entity> legendPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )
	if ( legendPlayers.len() == 0 )
		return null

	float closestSqr = DistanceSqr( legendPlayers[0].GetOrigin(), origin )
	entity closestLegend = legendPlayers[0]
	foreach ( entity legend in legendPlayers )
	{
		float distanceSqr = DistanceSqr( legend.GetOrigin(), origin )
		if ( distanceSqr < closestSqr )
		{
			closestSqr = distanceSqr
			closestLegend = legend
		}
	}
	return closestLegend
}
#endif //SERVER

#if SERVER
// Get the player in the array of players that has the most nearby alliance members
const int NEARBY_ALLIANCE_MEMBERS_BREAKOFF_COUNT = 6 // When we pick from an alliance member to spawn near and are checking how many other members are nearby. Break out of the loop if a player has this many nearby allies ( no need to look for someone with more )
entity function ShadowArmy_GetPlayerWithMostAllianceMembersInProximity( array < entity > players, int team )
{
	entity bestPlayer = null
	if ( players.len() > 0 )
	{
		int mostNearbyAllianceMembers = -1
		foreach( player in players )
		{
			if ( !IsValid( player ) )
				continue

			int nearbyAllianceMembersCount = AllianceProximity_GetLivingAllianceMembersInProximity( team, player.GetOrigin() ).len()

			if ( nearbyAllianceMembersCount >= NEARBY_ALLIANCE_MEMBERS_BREAKOFF_COUNT )
			{
				bestPlayer = player
				break
			}
			else if ( nearbyAllianceMembersCount > mostNearbyAllianceMembers )
			{
				bestPlayer = player
				mostNearbyAllianceMembers = nearbyAllianceMembersCount
			}
		}
	}

	return bestPlayer
}
#endif // SERVER

#if SERVER
// Get the player in the array of players that is the closest to an enemy but without being so close to the enemy they would fail spawn logic
entity function ShadowArmy_GetPlayerClosestToEnemyForSpawn( array < entity > players, int alliance )
{
	entity bestPlayer = null
	if ( players.len() > 0 )
	{
		array < entity > enemies = AllianceProximity_GetAllPlayersInOtherAlliances( alliance, true )
		if ( enemies.len() > 0 )
		{
			float closestToEnemyDist = -1
			float minDistFromEnemy = RespawnNearSquad_GetMinDistFromEnemyForValidSpawn()
			foreach ( player in players )
			{
				if ( !IsValid( player ) )
					continue

				vector playerLoc = player.GetOrigin()
				entity targetEnemy = GetClosest( enemies, playerLoc )
				float distToEnemy = DistanceSqr( targetEnemy.GetOrigin(), playerLoc )

				if ( distToEnemy <= minDistFromEnemy )
					continue

				if ( closestToEnemyDist == -1 || distToEnemy < closestToEnemyDist )
				{
					bestPlayer = player
					closestToEnemyDist = distToEnemy
				}
			}
		}
	}

	return bestPlayer
}
#endif // SERVER

#if SERVER || CLIENT
// Give a different spawn delay for Rev Players and Rev Players who just joined the Rev Alliance
// We want you to respawn quickly after switching alliances so players don't leave the game or be confused about what is happening
float function ShadowArmy_GetSpawnDelay( int team )
{
	// This function is triggered before the team switch occurs, which is convenient, we can just test to see if the team is on the Legend alliance
	if ( AllianceProximity_GetAllianceFromTeam( team ) == SHADOWARMY_LEGEND_ALLIANCE )
		return GetCurrentPlaylistVarFloat( "shadow_army_short_respawn_cooldown", SHADOWARMY_DEFAULT_SHORT_SPAWN_DELAY )

	return GetShadowRevBaseSpawnCooldown()
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Get the number of different groups and spawn locations the legends should be split into
int function ShadowArmy_GetLegendSpawnGroupsNumber()
{
	return GetCurrentPlaylistVarInt( "shadow_army_legend_spawn_groups_num", 3 )
}
#endif // SERVER || CLIENT


#if SERVER
// Determine if everyone in the players squad is waiting to respawn
bool function IsSquadWaitingToRespawn( int team )
{
	array < entity > squadPlayersArray = GetPlayerArrayOfTeam( team )
	bool isWholeSquadWaitingToSpawn = true
	foreach ( squadPlayer in squadPlayersArray )
	{
		if ( !IsValid( squadPlayer ) )
			continue

		if ( squadPlayer.GetPlayerNetInt( "respawnStatus" ) != eRespawnStatus.WAITING_FOR_RESPAWN && squadPlayer.GetPlayerNetInt( "respawnStatus" ) != eRespawnStatus.WAITING_FOR_PICKUP )
		{
			isWholeSquadWaitingToSpawn = false
			break
		}
	}

	return isWholeSquadWaitingToSpawn
}
#endif //SERVER

#if SERVER
// On Player respawned, set them up to have proper shadow or Revenant abilities
void function OnPlayerPostRespawned( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player.GetTeam() != TEAM_SPECTATOR )
		GivePlayerSettingsMods( player, [ "targetinfo_alliance" ] )

	UpdatePlayerCounts()

	// If the player was assigned Full Rev status, respawn them as a Full Rev
	if ( GetSelectedFullRevCandidatePlayer() == player )
		player.SetPlayerNetInt( "shadowArmy_PlayerForm", eShadowArmyRespawnForm.FULL_REVENANT )

	// Do different logic based on the player form for respawn
	int respawnForm = player.GetPlayerNetInt( "shadowArmy_PlayerForm" )
	switch( respawnForm )
	{
		case eShadowArmyRespawnForm.LIVING_LEGEND:
			// If we are spawning Legends on the ground we need to handle their first spawn stuff here
			if ( ShadowArmy_GetShouldLegendsSpawnOnGround_MatchStart() && !file.spawnedLegendPlayers.contains( player ) )
			{
				thread GivePlayerLoadout_Thread( player, true )
				thread ManageLegendSpawnOnGroundIntroForPlayer_Thread( player )
				file.spawnedLegendPlayers.append( player )
			}
			else
			{
				thread GivePlayerLoadout_Thread( player, false )
				PlayCharacterOrRadioDialogueToPlayer( PickCommentaryLineFromBucketAndHost( eSurvivalCommentaryBucket.SHADOW_ARMY_LOBA_RESPAWNED, eSurvivalHostType.LOBA ), player, eDialogueFlags.MUTE_PLAYER_PING_DIALOGUE_FOR_DURATION )
			}

			#if DEVELOPER
			if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
			{
				DebugDrawSphere( player.GetOrigin(), SHADOWARMY_SPAWN_DEBUG_DRAW_RADIUS, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
			}
			#endif // DEV
			break
		case eShadowArmyRespawnForm.FULL_REVENANT:
			                             
				RemoveShadowZombieAbilities( player )
                                      

			thread PlayBattleChatterLineDelayedToPlayer( player, "bc_respawnLTM", 1.0 )
			SetPlayerAsRevenant( player )
			thread GivePlayerLoadout_Thread( player, false )
			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_GivePlayerRepeatingEnemyMapScans" )
			ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.FULL_REV_SPAWNED_LEGEND, eShadowArmyMessageIndex.FULL_REV_SPAWNED_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
			thread ManageFullRevLife_Thread( player )
			thread ShadowArmy_FullRev_DelayedStatusEffectHandler( player )

			#if DEVELOPER
				if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
				{
					DebugDrawSphere( player.GetOrigin(), SHADOWARMY_SPAWN_DEBUG_DRAW_RADIUS, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
				}
			#endif // DEV
			break
		case eShadowArmyRespawnForm.SHADOW:
			// Want the player to be a rev shadow
			SetPlayerAsRevenant( player )

			                             
				GiveShadowZombieAbilities( player )
                                      

			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_GivePlayerRepeatingEnemyMapScans" )
			#if DEVELOPER
				if ( SHADOWARMY_DISPLAY_PLAYERSPAWN_DEBUG_DRAWS )
				{
					DebugDrawSphere( player.GetOrigin(), SHADOWARMY_SPAWN_DEBUG_DRAW_RADIUS, int(COLOR_ORANGE.x), int(COLOR_ORANGE.y), int(COLOR_ORANGE.z), true, SHADOWARMY_DEBUG_DRAW_DISPLAY_TIME )
				}
			#endif // DEV
			// Just to be safe, clear Ult if player has one
			entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
			if ( IsValid( ultimateWeapon ) )
				ultimateWeapon.SetWeaponPrimaryClipCount( 0 )
			break
		default:
		#if DEVELOPER
			Assert( false, "Shadow Army: Unsupported spawn form for player in OnPlayerPostRespawned" )
		#endif // DEV
			break
	}

	// Display skydive message
	if ( player in file.playerToPlayerFormOnDeath )
		DisplayRespawnBannerMessageForPlayer( player, file.playerToPlayerFormOnDeath[ player ], respawnForm )

	GamemodeUtility_CheckForMidMatchLegendChange( player )
}
#endif //SERVER

#if SERVER
// Give loadout ( different loadout for Living Legends vs Revenant Army players )
const float SKYDIVE_AWARD_WEAPONS_DELAY = 1.5
void function GivePlayerLoadout_Thread( entity player, bool isFirstSpawn )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy" )

	WaitFrame() // Need to wait for Survival respawn logic to finish up, it resets inventory and sets the player up to be in a good state to give weapons

	if ( !ShadowArmy_IsPlayerInShadowForm( player ) )
	{
		int respawnForm = player.GetPlayerNetInt( "shadowArmy_PlayerForm" )
		bool isLivingLegend = respawnForm == eShadowArmyRespawnForm.LIVING_LEGEND
		array<string> defaultConsumables

	                           
		// Only give a loadout to Legends on first spawn, loadout is restored on respawn through HAS_BR_RESPAWN_EQUIPPED logic in sh_respawn_beacon.gnut
		if ( ( Has_BR_Respawn_WithArmor() || Has_BR_Respawn_WithWeapons() ) && !isLivingLegend || isFirstSpawn )
                                  
		{
			// Give Equipment
			array<string> defaultEquipment = ParseEquipmentLoadoutText( GetEquipmentLoadoutString( isLivingLegend ), false, [] )
			CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, defaultEquipment )

			// Give Weapons
			string weaponLoadoutString = GetWeaponLoadoutString( isLivingLegend )
			if ( weaponLoadoutString != "" )
			{
				WeaponLoadout defaultWeapons = ParseWeaponLoadoutText( weaponLoadoutString, false )
				CharacterLoadouts_GiveWeaponLoadoutToPlayer( player, defaultWeapons, "", true )
			}

			// Give Consumables
			defaultConsumables = ParseConsumableLoadoutText( GetConsumableLoadoutString( isLivingLegend ), false )
			CharacterLoadouts_GiveConsumableLoadoutToPlayer( player, defaultConsumables )
		}

		if ( GetShouldUseInfiniteAmmo() )
			SetInfiniteAmmoForGameMode( player, true, ["crate"] )


		// Handle cases where players spawn in a skydive, we need to wait until weapons are enabled before we can equip them
		if ( !player.IsOnGround() )
		{
			player.WaitSignal( "PlayerBootsOnGround" )
			wait SKYDIVE_AWARD_WEAPONS_DELAY

			foreach ( consumable in defaultConsumables )
			{
				LootData data = SURVIVAL_Loot_GetLootDataByRef( consumable )
				if ( data.lootType == eLootType.ORDNANCE )
					SURVIVAL_EquipOrdnanceFromInventory( player, consumable )
			}
		}

		// Deploy weapons
		if ( player.IsWeaponTypeEnabled( WPT_PRIMARY ) )
		{
			player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
			player.DeployWeapon()
		}
	}
}
#endif //SERVER

#if SERVER
// Run special messaging or other logic on players that have spawned on the ground for match start
const float DIALOGUE_DELAY_1 = 10.0
const float DIALOGUE_DELAY_2 = 3.0
void function ManageLegendSpawnOnGroundIntroForPlayer_Thread( entity player )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV
	
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy" )
	
	// Disable movement
	player.MovementDisable()

	OnThreadEnd(
		function() : ( player )
		{
			// In Case this got killed early, enable movement
			if ( IsValid( player ) )
				player.MovementEnable()
		}
	)

	// Wait the total fade from black duration
	wait SHADOWARMY_LEGEND_SPAWN_FADE_FROM_BLACK_HOLD_DURATION + SHADOWARMY_LEGEND_SPAWN_FADE_FROM_BLACK_FADE_DURATION

	player.MovementEnable()

	// Show the mode announcement splash for the player
	ShadowArmy_AnnouncementSplash( player )

	wait DIALOGUE_DELAY_1

	PlayCharacterOrRadioDialogueToPlayer( PickCommentaryLineFromBucketAndHost( eSurvivalCommentaryBucket.SHADOW_ARMY_CRYPTO_INTRO, eSurvivalHostType.CRYPTO ), player, eDialogueFlags.MUTE_PLAYER_PING_DIALOGUE_FOR_DURATION )
	
	// Need an exact time bc_loba_ltm_cryptoresponse
	wait DIALOGUE_DELAY_2

	PlayCharacterOrRadioDialogueToPlayer( PickCommentaryLineFromBucketAndHost( eSurvivalCommentaryBucket.SHADOW_ARMY_LOBA_CRYPTO_RESPONSE, eSurvivalHostType.LOBA ), player, eDialogueFlags.MUTE_PLAYER_PING_DIALOGUE_FOR_DURATION )
}
#endif //SERVER

#if SERVER
// Change the player into a Revenant
const string REVENANT_GUID_STRING = "SAID00064207844"
void function SetPlayerAsRevenant( entity player )
{
	if ( !IsValid( player ) )
		return

	ItemFlavor ornull itemFlavor = GetItemFlavorOrNullByGUID( ConvertItemFlavorGUIDStringToGUID( REVENANT_GUID_STRING ) )

	#if DEVELOPER
		Assert( itemFlavor != null, "Shadow Army: Didn't get a valid itemFlavor from GUID in SetPlayerAsRevenant" )
	#endif // DEV

	if ( itemFlavor == null )
		return

	expect ItemFlavor( itemFlavor )

	// If the player is changing to a Rev store their original character selection so we can restore it before returning to the lobby
	ShadowArmy_StorePlayersOriginalCharacterSelection(  player, itemFlavor )

	SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), itemFlavor )

	if ( SHADOW_ARMY_SHOW_DETAILED_DEBUG )
		printt( "Shadow Army: Set player: " + player + " to Revenant" )
}
#endif //#if SERVER

#if SERVER
// We force players to use Rev on the Rev Alliance. Try to store the players previously selected character so we can switch them back to it before going back to the lobby
void function ShadowArmy_StorePlayersOriginalCharacterSelection( entity player, ItemFlavor forcedCharacter )
{
	if ( !IsValid( player ) )
		return

	// If the player is changing to a Rev store their original character selection so we can restore it before returning to the lobby
	if ( !( player in file.playerToSelectedCharacterTable ) )
	{
		ItemFlavor currentSelectedCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
		if ( currentSelectedCharacter != forcedCharacter )
			file.playerToSelectedCharacterTable[ player ] <- currentSelectedCharacter
	}
}
#endif //#if SERVER

#if SERVER
// Restore the player to their previously selected character if they got force switched to the Rev Army
void function RestoreRevPlayerToPreviouslySelectedCharacter( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player in file.playerToSelectedCharacterTable )
	{
		                             
			RemoveShadowZombieAbilities( player )
                                     

		SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), file.playerToSelectedCharacterTable[ player ] )
	}
}
#endif //#if SERVER

#if SERVER
// When a team changes alliance, check to see if we need to update Evac Ship waypoints
void function ShadowArmy_OnTeamChangedAlliance( int team, int newAlliance )
{
	// Only need to run before the evac sequence is triggered. Once it is triggered the location is revealed to everyone
	if ( ShadowArmy_GetCurrentGamePhase() < eShadowArmyGamePhase.EVAC_OBJECTIVE )
		UpdateEvacWaypointVisibility( false )
}
#endif //SERVER

#if CLIENT
// Update player hud or teammate squad colors when a team changes alliances
void function ShadowArmy_OnTeamChangedAlliance_Client( int team, int newAlliance )
{
	entity localViewPlayer = GetLocalViewPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	// Need to mark which players switched alliances so we can update their map icons once they respawn.
	// Map icons are created/updated when the player entity is created so we have to perform the update after these players respawn
	// Make sure we update the colors for all the players that switched
	array < entity > teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( teamPlayer in teamPlayers )
	{
		file.playersRespawningAfterAllianceSwitch.append( teamPlayer )
	}
}
#endif //CLIENT

#if SERVER
// Display the LTM Banner Message when players exit the dropship
void function ShadowArmy_AnnouncementSplash( entity player )
{
	if ( IsValid( player ) )
	{
		int messageIndex = ShadowArmy_IsPlayerOnShadowArmy( player ) ? eShadowArmyMessageIndex.LTM_DROP_ANNOUNCE_SHADOW : eShadowArmyMessageIndex.LTM_DROP_ANNOUNCE_LEGEND
		Remote_CallFunction_Replay( player, "ShadowArmy_ServerCallback_ShowAnnouncementMessage", messageIndex, eShadowArmyMessageType.ANNOUNCE_ONLY )
	}
}
#endif //SERVER

#if SERVER
// Manage choosing and setting the Red Eyed Rev on a cooldown
void function ManageFullRevCooldownAndSelection_Thread( bool isMatchStart )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( GetGameState() != eGameState.Playing )
		return

	OnThreadEnd(
		function() : ()
		{
			// Clean up variable around waiting for damage signals from Melee Revs
			file.isWaitingOnMeleeRevDamageSignal = false
		}
	)

	if ( IsValid( svGlobal.levelEnt ) )
		EndSignal( svGlobal.levelEnt, "GameEnd", "OnDestroy" )

	// On match start we handle the Red Eyed Rev hint when players land from skydive so don't do anything here
	// In all other instances, give players a hint showing them their progress towards being Red Eyed Rev
	if ( !isMatchStart )
		wait GetFullRevCooldownDuration() // When not match start, wait this duration
	else
		wait GetFullRevCooldownDurationMatchStart() // Wait a custom duration for match start, don't want red eyed rev right away

	// Keep trying to find a Revenant with the highest damage. If no one has dealt damage, wait until someone valid has
	entity bestFullRevCandidate
	while ( GetGameState() == eGameState.Playing && !IsValid( bestFullRevCandidate ) )
	{
		// Only pick a candidate if we don't already have one. This should never happen but could because of the dev command to spawn a player as a Full Rev
		if ( IsValid( file.fullRevOrCandidatePlayer ) )
			return

		bestFullRevCandidate = GetFullRevCandidate_DamageBased()

		// Didn't get a candidate, wait for damage to be dealt
		if ( !IsValid( bestFullRevCandidate ) )
		{
			file.isWaitingOnMeleeRevDamageSignal = true
			printt( "Shadow Army: ManageFullRevCooldownAndSelection failed to find a good candidate, going to wait for someone to deal damage" )
			svGlobal.levelEnt.WaitSignal( "ShadowRevDealtDamage" )
		}
		else
		{
			printt( "Shadow Army: ManageFullRevCooldownAndSelection picked a candidate based on highest damage dealt: " + bestFullRevCandidate )
		}
	}

	// We got a candidate, set them up to be Rev
	if ( IsValid( bestFullRevCandidate ) )
	{
		SetPlayerAsFullRevCandidate( bestFullRevCandidate )

		#if DEVELOPER
			// If the player is a bot, kill them so they respawn
			if ( bestFullRevCandidate.IsBot() )
				bestFullRevCandidate.TakeDamage( bestFullRevCandidate.GetHealth(), null, null, { scriptType = DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS | DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_weapon_shotgun_pistol } )
		#endif // DEV
	}
}
#endif //SERVER

#if SERVER
// Get the Revenant player with the highest match damage ( and is also able to become Red Eyed Revenant )
entity function GetFullRevCandidate_DamageBased()
{
	// Check to see if we need to clear the previous full revs array before proceeding
	if ( ShouldClearPreviousFullRevsArray() )
		file.previousFullRevsArray.clear()

	entity highestDamRev
	float highestDamage = 0.0
	array < entity > allRevPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, false )

	foreach ( rev in allRevPlayers )
	{
		if ( IsValid( rev ) && !file.previousFullRevsArray.contains( rev ) && rev in file.shadowPlayerToDamageDealtTable )
		{
			float currentRevDamDealt = file.shadowPlayerToDamageDealtTable[ rev ]

			if ( currentRevDamDealt > highestDamage )
			{
				highestDamRev = rev
				highestDamage = currentRevDamDealt
			}
		}
	}

	return highestDamRev
}
#endif //SERVER

#if SERVER
// Run the logic that is involved when setting a player to be the Full Rev Candidate ( will respawn as Full Rev on death )
void function SetPlayerAsFullRevCandidate( entity player )
{
	if ( IsValid( player ) )
	{
		file.fullRevOrCandidatePlayer = player

		// If the full rev candidate is still alive, give them a message letting them know they have been selected to respawn as full rev and give them an ult charge to transform into full rev
		if ( IsAlive( player ) )
		{
			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowHinttMessage", eShadowArmyHintIndex.FULL_REV_CANDIDATE_HINT, 0, 0 )
			entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
			if ( IsValid( ultimateWeapon ) )
			{
				int ultCharge = ultimateWeapon.GetWeaponPrimaryClipCount()
				int maxUltCharge = ultimateWeapon.GetWeaponPrimaryClipCountMax()
				if ( ultCharge != maxUltCharge )
					ultimateWeapon.SetWeaponPrimaryClipCount( maxUltCharge )
			}
		}
	}
}
#endif //SERVER

#if SERVER
void function ShadowArmy_FullRev_DelayedStatusEffectHandler( entity player )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsAlive( player ) )
		return

	player.WaitSignal( "PlayerBootsOnGround" )

	int effectHandle = StatusEffect_AddEndless( player, eStatusEffect.red_revenant_revealed, 1.0 )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player, effectHandle )
		{
			StatusEffect_Stop( player, effectHandle )
		}
	)

	wait FULL_REV_LANDING_WARNING_MESSAGE_DURATION
}
#endif // SERVER

#if SERVER
// Manage the life of a player that is a full revenant ( highlights and keeping track of when they die )
void function ManageFullRevLife_Thread( entity player )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	// Something went wrong, this should only trigger for the full rev player
	if ( file.fullRevOrCandidatePlayer != player )
	{
		Warning( "Shadow Army: ManageFullRevLife_Thread triggered for player: " + player + " who is not the Full Rev Player: " + file.fullRevOrCandidatePlayer )
		return
	}

	file.previousFullRevsArray.append( player )

	EndSignal( player, "OnDeath", "OnDestroy" )
	EndSignal( svGlobal.levelEnt, "GameEnd" )

	// Show an Icon on the Rev
	entity revWaypoint = CreateWaypoint_BasicLocation( player.GetOrigin() + < 0, 0, FULL_REV_WAYPOINT_HEIGHT_OFFSET >, ePingType.REDEYED_REV )
	revWaypoint.SetParent( player )

	// Show Red eye FX
	array <entity> vfxArray
	int leftEyeAttachmentID = player.LookupAttachment( "EYE_L" )
	int rightEyeAttachmentID = player.LookupAttachment( "EYE_R" )
	if ( leftEyeAttachmentID > 0 && rightEyeAttachmentID > 0 )
	{
		int eyeFXIndex = GetParticleSystemIndex( FULL_REV_EYE_VFX )
		vfxArray.append( StartParticleEffectOnEntity_ReturnEntity( player, eyeFXIndex, FX_PATTACH_POINT_FOLLOW, leftEyeAttachmentID ) )
		vfxArray.append( StartParticleEffectOnEntity_ReturnEntity( player, eyeFXIndex, FX_PATTACH_POINT_FOLLOW, rightEyeAttachmentID ) )
	}

	// Show Chest VFX
	int chestAttachmentID = player.LookupAttachment( "CHESTFOCUS" )
	if ( chestAttachmentID > 0 )
		vfxArray.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( FULL_REV_CHEST_VFX ), FX_PATTACH_POINT_FOLLOW, chestAttachmentID ) )

	// Set the VFX to render for everyone except the player
	foreach ( fx in vfxArray )
	{
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )
	}

	// Set Skydive Trail
	ItemFlavor flav = GetItemFlavorByAsset( SKYDIVE_TRAIL_SHADOWARMY_FULLREV )
	SetOverrideSkydiveTrailPackageForPlayer( SkydiveTrail_GetSkyDiveTrailPackageFromItemFlavor( flav ), player )

	OnThreadEnd(
		function() : ( revWaypoint, vfxArray )
		{
			if ( IsValid( revWaypoint ) )
				revWaypoint.Destroy()

			file.fullRevOrCandidatePlayer = null

			foreach ( vfx in vfxArray )
			{
				if ( IsValid( vfx ) )
					vfx.Destroy()
			}

			ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.FULL_REV_KILLED, eShadowArmyMessageIndex.FULL_REV_KILLED, eShadowArmyMessageType.OBIT_ONLY )

			// Trigger the thread to find the next Full Rev
			thread ManageFullRevCooldownAndSelection_Thread( false )
		}
	)

	// Wait until this player dies or the game ends
	WaitForever()
}
#endif //SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GAMEMODE FLOW
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
// Function used to change game phases and trigger logic dependent on different phases
void function ChangeGamePhase( int newGamePhase )
{
	int currentPhase = ShadowArmy_GetCurrentGamePhase()
	// Phases should only go up, we don't go back into completed phases
	if ( newGamePhase <= currentPhase )
	{
		Warning( "Shadow Army: Tried to set the gamephase to an older phase than the current one. Current Phase: " + currentPhase + " New Phase: " + newGamePhase )
		return
	}

	SetGlobalNetInt( "shadowArmy_GamePhase", newGamePhase )

	printt( "Shadow Army: Changing game phase, Current Phase: " + currentPhase + " New Phase: " + newGamePhase )

	// Gamemode logic
	switch ( newGamePhase )
	{
		case eShadowArmyGamePhase.GAME_START:
			break
		case eShadowArmyGamePhase.WAITING_FOR_EVAC_OBJECTIVE:
			thread ManageEvacStart_Thread()
			break
		case eShadowArmyGamePhase.EVAC_OBJECTIVE:
			thread ObjectiveEvac_Thread()
			break
		case eShadowArmyGamePhase.EVAC_SHIP_ARRIVED:
			TurnOffRespawnForLivingLegends()
			break
		case eShadowArmyGamePhase.EVAC_SHIP_DEPARTED:
			break
		default:
			return
	}
}
#endif //SERVER

#if CLIENT
// Run messaging logic on mode gamephase change ( messaging Evac status )
void function OnShadowArmyGamePhaseChanged_Client( entity player, int newGamePhase )
{
	switch ( newGamePhase )
	{
		case eShadowArmyGamePhase.GAME_START:
			break
		case eShadowArmyGamePhase.WAITING_FOR_EVAC_OBJECTIVE:
			FlagSet( "WaitingForEvacObjective_Client" )
			break
		case eShadowArmyGamePhase.EVAC_OBJECTIVE:
			FlagSet( "EvacObjective_Client" )
			UpdateMusicRampUpLevel( eShadowArmyMusicRampLevels.EVAC_SEQUENCE_STARTED )
			break
		case eShadowArmyGamePhase.EVAC_SHIP_ARRIVED:
			FlagSet( "EvacShipArrived_Client" )
			UpdateMusicRampUpLevel( eShadowArmyMusicRampLevels.EVAC_ARRIVED )
			break
		case eShadowArmyGamePhase.EVAC_SHIP_DEPARTED:
			FlagSet( "EvacShipDeparting_Client" )
			break
		default:
			return
	}
}
#endif // CLIENT


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GAME START
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#if SERVER
// Set player to be Revenants on first spawn into the match if they were on the Shadow Alliance
void function OnPlayerPutInIntroDropship( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player.GetTeam() != TEAM_SPECTATOR )
		GivePlayerSettingsMods( player, [ "targetinfo_alliance" ] )

	int team = player.GetTeam()
	int playerAlliance = AllianceProximity_GetAllianceFromTeam( team )

	if ( playerAlliance == SHADOWARMY_REVENANT_ALLIANCE )
	{
		SetPlayerAsRevenant( player )

		                             
			GiveShadowZombieAbilities( player )
                                     

		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_GivePlayerRepeatingEnemyMapScans" )
		player.SetPlayerNetInt( "shadowArmy_PlayerForm", eShadowArmyRespawnForm.SHADOW )
	}

	thread GivePlayerLoadout_Thread( player, true )
}
#endif //SERVER

#if CLIENT
// Trigger Showing enemies on the minimap for the local player
void function ShadowArmy_ServerCallback_GivePlayerRepeatingEnemyMapScans()
{
	thread RunRepeatingEnemyMapScans_Thread()
}
#endif // CLIENT

#if CLIENT
// Show enemies on the minimap for the local player
// First we show a pulse, the we wait:
const float POST_PULSE_WAIT = 1.0
// Then we show enemy markers on the map and minimap, then we wait
const float SCAN_DURATION = 3.0
// Then we destroy the markers and wait:
const float REPEAT_INTERVAL = 2.0
// And repeat
void function RunRepeatingEnemyMapScans_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )

	// Don't run this if we are already running it
	if ( file.areEnemyMapScansActiveOnClient )
		return

	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) || !IsAlive( localPlayer ) )
		return

	EndSignal( localPlayer, "OnDestroy", "OnDeath" )

	int team = localPlayer.GetTeam()
	array< entity > aliveEnemies
	array< entity > scanEntsArray

	float endTime
	float timeToStartFade
	float timeToEndFade

	array<var> fullMapRuis
	array<var> minimapRuis
	array<entity> entsForTracking

	OnThreadEnd(
		function() : ( fullMapRuis, minimapRuis )
		{
			foreach( var ruiToDestroy in fullMapRuis )
			{
				Fullmap_RemoveRui( ruiToDestroy )
				RuiDestroyIfAlive( ruiToDestroy )
			}

			foreach( var ruiToDestroy in minimapRuis)
			{
				Minimap_CommonCleanup( ruiToDestroy )
			}

			file.areEnemyMapScansActiveOnClient = false
		}
	)

	file.areEnemyMapScansActiveOnClient = true

	while ( GetGameState() == eGameState.Playing )
	{
		// Show a pulse on the map
		vector pulseOrigin = localPlayer.GetOrigin()
		FullMap_PlayCryptoPulseSequence( pulseOrigin, true, SCAN_DURATION + POST_PULSE_WAIT )
		wait POST_PULSE_WAIT

		// Set vars for the scan
		aliveEnemies = GetPlayerArrayOfEnemies_Alive( team )

		// Don't want to show bleeding out players on the scan, it makes it harder to find your targets as Rev
		foreach ( enemy in aliveEnemies )
		{
			if ( !Bleedout_IsBleedingOut( enemy ) )
				scanEntsArray.append( enemy )
		}
		endTime = Time() + SCAN_DURATION
		timeToStartFade = Time() + ( SCAN_DURATION/2 )
		timeToEndFade = endTime

		// Show the enemy markers on the map
		foreach( entity enemy in scanEntsArray )
		{
                        
                                      
             
         

			// Full map
			var fRui = FullMap_AddEnemyLocation( enemy )
			fullMapRuis.append( fRui )

			// MiniMap
			var mRui = Minimap_AddEnemyToMinimap( enemy )
			minimapRuis.append( mRui )
			RuiSetGameTime( mRui, "fadeStartTime", timeToStartFade )
			RuiSetGameTime( mRui, "fadeEndTime", timeToEndFade )
		}

		// Wait the lifetime of the markers
		wait SCAN_DURATION

		// Destroy all the markers
		foreach( var ruiToDestroy in fullMapRuis )
		{
			Fullmap_RemoveRui( ruiToDestroy )
			RuiDestroyIfAlive( ruiToDestroy )
		}

		foreach( var ruiToDestroy in minimapRuis)
		{
			Minimap_CommonCleanup( ruiToDestroy )
		}

		// Cleanup Vars
		fullMapRuis.clear()
		minimapRuis.clear()
		aliveEnemies.clear()
		scanEntsArray.clear()

		// Wait the duration of the repeat interval before we do another scan
		wait REPEAT_INTERVAL
	}
}
#endif // CLIENT




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EVAC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if SERVER
void function ShadowArmy_OnGamestateEnterPickLoadout_Server()
{
	printt( "Shadow Army: Entered Pick Loadout GameState" )

	// split up teams into alliances
	ShadowArmy_SetTeamsToRevAllianceOnMatchStart()
}
#endif // SERVER

#if SERVER
void function ShadowArmy_OnGamestateEnterPlaying_Server()
{
	printt( "Shadow Army: Entered Playing GameState" )

	// Test if the game is starting out with a missing alliance
	TryEndGameFromAllianceForfeit()

	ChangeGamePhase( eShadowArmyGamePhase.WAITING_FOR_EVAC_OBJECTIVE )

	// Set to track damage done to Legends by Melee Revs
	array < entity > legendPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false )
	foreach ( legend in legendPlayers )
	{
		if ( !legend.e.entPostDamageCallbacks.contains( OnLegendPostDamaged ) )
			AddEntityCallback_OnPostDamaged( legend, OnLegendPostDamaged )
	}

	// Look for a Full Rev Candidate
	thread ManageFullRevCooldownAndSelection_Thread( true )

	// Display the Legend start location for Revs
	thread ManageRevAllianceLegendStartWaypoint_Thread()

	// Manage catchup mechanics based on time spent in the match
	thread ManageCatchupMechanicLevels_Thread()
}
#endif // SERVER

#if SERVER
void function ShadowArmy_OnGamestateEnterPostMatch_Server()
{
	// Restore players to the character they had before being switched over to the Rev alliance when the game ends.
	// This state triggers after the podium so it shouldn't affect how the characters appear on the podium or in the match summary
	array < entity > allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		RestoreRevPlayerToPreviouslySelectedCharacter( player )
	}
}
#endif // SERVER

#if SERVER
void function ShadowArmy_OnResolution_Server()
{

}
#endif // SERVER

#if SERVER
void function ManageEvacStart_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	EndSignal( svGlobal.levelEnt, "GameEnd", "EmergencyEvacTriggered" )

	OnThreadEnd(
		function() : ()
		{
			printt( "Shadow Army: Changing Game Phase to EVAC_OBJECTIVE, going to trigger the Evac Objective" )
			ChangeGamePhase( eShadowArmyGamePhase.EVAC_OBJECTIVE )
		}
	)

	printt( "Shadow Army: Going to Wait " + GetDelayDurationUntilEvacSequenceStarts() + " before we trigger the Evac Objective" )
	SetGlobalNetTime( "shadowArmy_NextEvacPhaseTime", Time() + GetDelayDurationUntilEvacSequenceStarts() + GetDelayDurationUntilEvacShipsArrive() )
	UpdateEvacWaypointVisibility( false )
	wait GetDelayDurationUntilEvacSequenceStarts()
	printt( "Shadow Army: Finished waiting to trigger Evac Objective, going to trigger it now" )

	if ( !GamemodeUtility_IsWinnerBeingDetermined() )
		ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_LEGEND, eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
}
#endif // SERVER

#if SERVER
// Logic that handles the final circle evac phase, it handles bringing in the evac ship, messaging, and also win states
const float EVAC_INCOMING_COMMENTARY_DELAY = 20.0
void function ObjectiveEvac_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	printt( "Shadow Army: Objective Evac Starting" )

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
	{
		printt( "Shadow Army: Winner is being determined already, exiting Evac Objective Thread" )
		return
	}

	EndSignal( svGlobal.levelEnt, "GameEnd" )
	SetGlobalNetTime( "shadowArmy_NextEvacPhaseTime", Time() + GetDelayDurationUntilEvacShipsArrive() )

	array < entity > evacShipArray
	int legendEvacTargetCount = int( AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false ) * EVAC_TARGET_PERCENTAGE_OF_LEGENDS )
	legendEvacTargetCount = minint( legendEvacTargetCount, MAX_EVAC_TARGET_COUNT_FOR_LEGENDS )
	file.evacTargetCount = legendEvacTargetCount
	array < entity > shipBeamFXArray

	// Ship departed or all Legends eliminated
	OnThreadEnd(
		function() : ( evacShipArray, shipBeamFXArray )
		{
			printt( "Shadow Army: Objective Evac Ended" )

			foreach( fx in shipBeamFXArray )
			{
				if ( IsValid( fx ) )
					fx.Destroy()
			}

			// If winner already determined (all legends eliminated) we can early out
			if ( GamemodeUtility_IsWinnerBeingDetermined() )
				return

			array <entity> livingPlayersArray = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )

			//should have never gotten this far if there are zero legends, but trigger set winner in case it wasn't yet
			if ( TryToDetermineWinner_Elimination() )
				return

			// Not enough legends inside evac....revs win
			if ( GetNumLegendsOnEvacShips() < file.evacTargetCount )
			{
				ShadowArmy_SetWinner( SHADOWARMY_REVENANT_ALLIANCE, eWinReason.OBJECTIVE_COMPLETED )
				return
			}

			// Some living legends inside ship....they win
			foreach( player in livingPlayersArray )
			{
				if ( !player.IsInvulnerable() )
					player.SetInvulnerable()
			}

			ShadowArmy_SetWinner( SHADOWARMY_LEGEND_ALLIANCE, eWinReason.OBJECTIVE_COMPLETED )

			// Cleanup Evac waypoints
			if ( IsValid( file.evacLocationData.evacLocationMapArea ) )
			{
				file.evacLocationData.evacLocationMapArea.Destroy()
				file.evacLocationData.evacLocationMapArea = null
			}

			if ( IsValid( file.evacLocationData.evacLocationWaypoint ) )
			{
				file.evacLocationData.evacLocationWaypoint.Destroy()
				file.evacLocationData.evacLocationWaypoint = null
			}
		}
	)

	// Test to see if there are any Living Players remaining. Calling in the Evac Ship for the Living Alliance Team will cause a crash if there is no team to get
	TryToDetermineWinner_Elimination()

	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	array <entity> aliveConnectedPlayersArray = GetPlayerArray_AliveConnected()
	// Don't bother if no players connected
	if ( aliveConnectedPlayersArray.len() == 0 )
		return

	// Show Evac Target HUD
	array <entity> allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) )
			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_UpdateEvacTargetCountOnHud", file.evacTargetCount )
	}

	// Spawn evac dropships and wait
	int numRemainingLegends = AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false )
	// Only get the number of Evac Ships needed
	int numEvacShips = ( AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false ) / EVAC_SHIP_PASSENGERS_MAX )
	// If there would be a remainder in the division ( ints round down ) add one more ship
	numEvacShips = AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false ) % EVAC_SHIP_PASSENGERS_MAX == 0 ? numEvacShips : numEvacShips + 1
	// make sure we have enough spawn points
	numEvacShips = minint( numEvacShips, file.evacLocationData.evacShipLocationNodes.len() )

	for ( int index = 0; index < numEvacShips; index++ )
	{
		entity shipLocationNode = file.evacLocationData.evacShipLocationNodes[ index ]
		if ( !IsValid( shipLocationNode ) )
			continue

		entity evacShip = CreateEvacShipSequence( shipLocationNode.GetOrigin(), shipLocationNode.GetAngles(), EVAC_CIRCLE_RADIUS, SHADOWARMY_LEGEND_ALLIANCE, GetDelayDurationUntilEvacShipsArrive(), GetDelayDurationUntilEvacShipsDepart(), false, false, false, true )
		evacShipArray.append( evacShip )
		entity beamFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( GetObjectiveAsset_FX( EVAC_SHIP_BEAM_VFX ) ), evacShip.GetOrigin(), <0, 0, 0> )
		beamFX.DisableHibernation()
		shipBeamFXArray.append( beamFX )
	}

	if ( evacShipArray.len() <= 0 )
		return

	// Create a single waypoint icon for the evac location and only display it for the Legend Alliance
	file.evacLocationData.evacShips = evacShipArray
	UpdateEvacWaypointVisibility( false )

	// Most of the callbacks control objective state, just use one of the evac ships to determine those
	entity mainEvacShip = evacShipArray[ 0 ]

	AddEntityCallback_OnEvacShipArrived( mainEvacShip, void function ( entity mainEvacShip ) : ( )
	{
		printt( "Shadow Army: Objective Evac Going to Change Game Phase to EVAC_SHIP_ARRIVED" )

		ChangeGamePhase( eShadowArmyGamePhase.EVAC_SHIP_ARRIVED )
		FlagSet( "EvacShipArrived" )
	} )

	foreach ( evacShip in evacShipArray )
	{
		// evac ship departing callback
		AddEntityCallback_OnEvacShipDeparted( evacShip, void function ( entity evacShip ) : ()
		{
			if ( !Flag( "EvacShipDeparting" ) )
			{
				printt( "Shadow Army: Objective Evac Going to Change Game Phase to EVAC_SHIP_DEPARTED" )
				FlagSet( "EvacShipDeparting" )
				ChangeGamePhase( eShadowArmyGamePhase.EVAC_SHIP_DEPARTED )
			}
		} )
	}

	foreach ( evacShip in evacShipArray )
	{
		// player boarded evac ship
		AddEntityCallback_OnEvacShipPlayerBoarded( evacShip, void function ( entity player, entity evacShip ) : ()
		{
			printt( "Shadow Army: Player: " + player + " Boarded Evac Ship" )

			ShadowArmy_ClearAllAnnouncementSplashes( player )
			thread AnnouncementSplashDelayed_Thread( player, eShadowArmyMessageIndex.SAFE_ON_EVAC_SHIP, POST_EVAC_SHIP_DEPART_WAIT_DURATION, eShadowArmyMessageType.ANNOUNCE_ONLY )
			ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.LEGEND_ENTERED_EVAC_SHIP, eShadowArmyMessageIndex.LEGEND_ENTERED_EVAC_SHIP, eShadowArmyMessageType.OBIT_ONLY )
			SetGlobalNetInt( "shadowArmy_LegendsInEvacShips", GetNumLegendsOnEvacShips() + 1 )
			ShadowArmy_TryToPlayPlayerBoardedEvacCommentary()
			AttemptToTriggerEarlyEvacShipDeparture( GetNumLegendsOnEvacShips() )
		} )
	}

	// Early out if Legends all just die
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	printt( "Shadow Army: Objective Evac going to wait for EvacShipArrived flag" )

	// Play Announcer Commentary Evac Ships Incoming
	thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOWARMY_EVAC_SHIP_INCOMING ), EVAC_INCOMING_COMMENTARY_DELAY )

	FlagWait( "EvacShipArrived" )

	// Set the Objective Timer to show time until the Evac Ship Departs
	SetGlobalNetTime( "shadowArmy_NextEvacPhaseTime", Time() + GetDelayDurationUntilEvacShipsDepart() )

	printt( "Shadow Army: Objective Evac done wait for EvacShipArrived flag" )

	ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_ARRIVED_LEGEND, eShadowArmyMessageIndex.EVAC_ARRIVED_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )

	// Destroy the beam vfx ( evac ship logic creates them on its own once the ships arrive )
	foreach( fx in shipBeamFXArray )
	{
		if ( IsValid( fx ) )
			fx.Destroy()
	}
	shipBeamFXArray.clear()

	printt( "Shadow Army: Objective Evac going to wait for EvacShipDeparting flag" )

	FlagWait( "EvacShipDeparting" )

	printt( "Shadow Army: Objective Evac done wait for EvacShipDeparting flag" )

	thread PlayEndGameDialogueForAliveLegends()

	wait POST_EVAC_SHIP_DEPART_WAIT_DURATION
}
#endif // SERVER

#if SERVER
void function PlayEndGameDialogueForAliveLegends()
{
	array < entity > legendPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )

	int commentaryBucket = ( GetNumLegendsOnEvacShips() >= file.evacTargetCount ) ? eSurvivalCommentaryBucket.SHADOW_ARMY_LOBA_EVAC_COMPLETE : eSurvivalCommentaryBucket.SHADOW_ARMY_LOBA_EVAC_NEARMISS

	foreach( player in legendPlayers )
	{
		if ( !IsValid( player ) || IsDisconnected( player )  || !IsAlive (player ))
			continue

		PlayCharacterOrRadioDialogueToPlayer( PickCommentaryLineFromBucketAndHost( commentaryBucket, eSurvivalHostType.LOBA  ), player, eDialogueFlags.MUTE_PLAYER_PING_DIALOGUE_FOR_DURATION )
	}
}
#endif

#if SERVER
// Check if Evac Ships should depart early and trigger early evac if the evac target has been reached by the Legend Alliance
void function AttemptToTriggerEarlyEvacShipDeparture( int numPlayersOnEvacShips )
{
	if ( !Flag( "EvacShipDeparting" ) && numPlayersOnEvacShips >= file.evacTargetCount )
	{
		foreach ( evacShip in file.evacLocationData.evacShips)
		{
			EvacShipForceEarlyDeparture( evacShip )
		}
	}
}
#endif // SERVER

#if SERVER
// If there are only a few Living Legends Left, call in an emergency evac for them to give them a chance to escape
bool function IsEmergencyEvac()
{
	return GetRemainingLivingLegendSquadsCount() <= GetNumLivingSquadsForEmergencyEvac()
}
#endif // SERVER

#if SERVER
// Update waypoint visibility to either only show the evac ship waypoints to teams that are on the Legend Alliance or to show them for all teams in the lobby
// Need to trigger this when teams switch alliances because waypoint transmit settings do not adjust automatically ( team that was friendly when the waypoint was created might not be friendly anymore )
void function UpdateEvacWaypointVisibility( bool didRoundChange, int ringStage = 0 )
{
	int currentPhase = ShadowArmy_GetCurrentGamePhase()

	// If Evac Location hasn't been revealed we don't have to do anything here
	if ( currentPhase < eShadowArmyGamePhase.WAITING_FOR_EVAC_OBJECTIVE  )
		return

	// If match is ending, break out as well
	if ( GamemodeUtility_IsWinnerBeingDetermined() || GetGameState() > eGameState.Playing )
		return

	// Before the evac location is revealed to Revs, we show the general area of Evac on the map for Legends
	if ( currentPhase < eShadowArmyGamePhase.EVAC_OBJECTIVE )
	{
		// If we haven't created the general area map hint, create it now and show it for all Legends
		if ( !IsValid( file.evacLocationData.evacLocationMapArea ) )
		{
			vector hintLoc = GetNewEvacWaypointLocation( ringStage )
			entity minimapHint = CreatePropScript( $"mdl/dev/empty_model.rmdl", hintLoc )
			minimapHint.Minimap_SetObjectScale( EVAC_AREA_RADII[0]/SURVIVAL_MINIMAP_RING_SCALE )
			minimapHint.Minimap_SetAlignUpright( true )
			minimapHint.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
			minimapHint.Minimap_SetClampToEdge( true )
			minimapHint.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
			minimapHint.DisableHibernation()
			SetTargetName( minimapHint, SHADOWARMY_MAP_EVAC_AREA )
			file.evacLocationData.evacLocationMapArea = minimapHint

			// Show for all Legend Teams
			array < int > allLegendTeams = AllianceProximity_GetPopulatedTeamsInAlliance( SHADOWARMY_LEGEND_ALLIANCE )
			foreach ( legendTeam in allLegendTeams )
			{
				minimapHint.Minimap_AlwaysShow( legendTeam, null )
			}
		}
		else // If we already have the map hint created ensure we hide it for Revs ( new players might be on that team now ) or make the hint more accurate
		{
			// Hide for all Rev Army teams
			array < int > allRevTeams = []

			// Need to check if there is a Rev Alliance in case we started the match with no Revs
			if ( AllianceProximity_GetAllAlliances().contains( SHADOWARMY_REVENANT_ALLIANCE ) )
				allRevTeams = AllianceProximity_GetPopulatedTeamsInAlliance( SHADOWARMY_REVENANT_ALLIANCE )

			foreach ( revTeam in allRevTeams )
			{
				file.evacLocationData.evacLocationMapArea.Minimap_Hide( revTeam, null )
			}

			// Reduce the size of the evac area hint as the match progresses ( gets more accurate )
			if ( didRoundChange )
			{
				// Get the radius of the hint based on current ring stage ( gets more accurate as the game progresses )
				file.evacLocationData.evacLocationMapArea.SetOrigin( GetNewEvacWaypointLocation( ringStage ) )
				int evacAreaRadiiArrayLength = EVAC_AREA_RADII.len()
				float radius = evacAreaRadiiArrayLength > ringStage ? EVAC_AREA_RADII[ ringStage ] : EVAC_AREA_RADII[ evacAreaRadiiArrayLength - 1 ]

				if ( radius > 0 )
					file.evacLocationData.evacLocationMapArea.Minimap_SetObjectScale( radius/SURVIVAL_MINIMAP_RING_SCALE )

				ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_AREA_UPDATED, eShadowArmyMessageIndex.EVAC_AREA_UPDATED, eShadowArmyMessageType.OBIT_ONLY )
			}
		}

		int friendlyTeam = AllianceProximity_GetRepresentativeTeamForAlliance( SHADOWARMY_LEGEND_ALLIANCE )

		// We want to show an icon in the center of the general area for Legends only. If we didn't create it yet, do it now
		if ( !IsValid( file.evacLocationData.evacLocationWaypoint ) )
		{
			entity wp = CreateWaypoint_BasicLocation( GetNewEvacWaypointLocation( ringStage ) + EVAC_WAYPOINT_VERTICAL_OFFSET, ePingType.EVAC_AREA )
			file.evacLocationData.evacLocationWaypoint = wp
			AllianceProximity_SetOnlyTransmitWaypointToFriendlyTeams( wp, friendlyTeam )
		}
		else // If we already have the icon for the area created make sure we set it only visible for Legends and move it to the new general evac area if the round changed
		{
			// Ensure we Hide for all Rev Army teams
			AllianceProximity_SetOnlyTransmitWaypointToFriendlyTeams( file.evacLocationData.evacLocationWaypoint, friendlyTeam )

			// Move the icon to the center of the general area
			if ( didRoundChange )
				file.evacLocationData.evacLocationWaypoint.SetOrigin( GetNewEvacWaypointLocation( ringStage ) + EVAC_WAYPOINT_VERTICAL_OFFSET )
		}
	}
	else // Reveal the exact location of Evac to Legends and Revenants
	{
		// Show the evac area icon for Rev Players now too and move it to the exact Evac Location
		if ( IsValid( file.evacLocationData.evacLocationMapArea ) )
		{
			file.evacLocationData.evacLocationMapArea.SetOrigin( file.evacLocationData.evacLocation )
			float radius = EVAC_AREA_RADII[ EVAC_AREA_RADII.len() - 1 ]
			if ( radius > 0 )
				file.evacLocationData.evacLocationMapArea.Minimap_SetObjectScale( radius/SURVIVAL_MINIMAP_RING_SCALE )

			array < int > allRevTeams = AllianceProximity_GetPopulatedTeamsInAlliance( SHADOWARMY_REVENANT_ALLIANCE )
			foreach ( revTeam in allRevTeams )
			{
				file.evacLocationData.evacLocationMapArea.Minimap_AlwaysShow( revTeam, null )
			}
		}

		// Destroy the old In World Icon and create an Evac Location Icon that shows up for Revs as well
		if ( IsValid( file.evacLocationData.evacLocationWaypoint ) )
			file.evacLocationData.evacLocationWaypoint.Destroy()
		
		entity wp = CreateWaypoint_BasicLocation( file.evacLocationData.evacLocation + EVAC_WAYPOINT_VERTICAL_OFFSET, ePingType.EVAC_SHIP )
		file.evacLocationData.evacLocationWaypoint = wp

		ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_LOCATION_REVEALED, eShadowArmyMessageIndex.EVAC_LOCATION_REVEALED, eShadowArmyMessageType.OBIT_ONLY )
	}
}
#endif //SERVER

#if SERVER
// Get the location where we should display the evac location waypoint or general area on the map
vector function GetNewEvacWaypointLocation( int ringStage )
{
	vector loc
	// On the second to last ring, we use the exact evac location
	if ( ringStage >= GetRingStageWhenEvacLocationRevealed() )
	{
		loc = file.evacLocationData.evacLocation
	}
	else // On other rings we want a location between the exact location and the offset position of the current safezone
	{
		vector safeZonePos = SURVIVAL_GetSafeZoneCenter( Survival_Loot_GetDefaultRealm() )
		float diffModifier = RandomFloatRange( 0.4, 0.6 )
		vector diff = ( file.evacLocationData.evacLocation - safeZonePos ) * diffModifier
		loc = file.evacLocationData.evacLocation - diff // get the half way point between the 2 positions
		// Set the height of the icon to use the evac location height for in world icons
		loc = loc + < 0, 0, file.evacLocationData.evacLocation.z >
	}

	return loc
}
#endif //SERVER

#if CLIENT
void function ObjectiveEvac_ManageHUDMessaging_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	// Since this is on the Client, want to make sure we are only running 1 thread
	localPlayer.Signal( "StartingEvacObjectiveMessagingThread" )
	EndSignal( localPlayer, "OnDestroy", "OnDeath", "StartingEvacObjectiveMessagingThread" )

	int currentPhase = ShadowArmy_GetCurrentGamePhase()
	var rui = ClGameState_GetRui()

	if ( currentPhase < eShadowArmyGamePhase.WAITING_FOR_EVAC_OBJECTIVE )
	{
		FlagWait( "WaitingForEvacObjective_Client" )
	}

	localPlayer = GetLocalViewPlayer()
	currentPhase = ShadowArmy_GetCurrentGamePhase()
	if ( currentPhase < eShadowArmyGamePhase.EVAC_OBJECTIVE )
	{
		if ( rui != null )
		{
			RuiSetBool( rui, "shouldShowEvacInfo", true )
			RuiSetBool( rui, "shouldShowEvacTimer", true )
			RuiSetColorAlpha( rui, "evacFrameColor", SrgbToLinear(< 1.0, 1.0, 1.0 >), 1.0 )
			RuiSetColorAlpha( rui, "evacIconColor", SrgbToLinear(< 1.0, 1.0, 1.0 >), 1.0 )
			RuiSetColorAlpha( rui, "evacBgColor", SrgbToLinear(< 0.1, 0.1, 0.1 >), 1.0 )
			RuiSetGameTime( rui, "nextEvacPhaseTime", GetGlobalNetTime( "shadowArmy_NextEvacPhaseTime" ) )
			if ( !ShadowArmy_IsPlayerOnShadowArmy( localPlayer ) )
			{
				RuiSetString( rui, "evacText", Localize( "#SHADOW_ARMY_OBJ_EVAC_SURVIVE" ) )
				RuiSetImage( rui, "evacIcon", $"rui/gamemodes/rev_army/timer_icon" )
			}
			else
			{
				RuiSetString( rui, "evacText", Localize( "#SHADOW_ARMY_OBJ_EVAC_ELIMINATE" ) )
				RuiSetImage( rui, "evacIcon", $"rui/gamemodes/rev_army/crosshair_icon" )
			}
		}

		FlagWait( "EvacObjective_Client" )

	}

	localPlayer = GetLocalViewPlayer()
	currentPhase = ShadowArmy_GetCurrentGamePhase()
	if ( currentPhase < eShadowArmyGamePhase.EVAC_SHIP_ARRIVED )
	{
		if ( rui != null )
		{
			RuiSetBool( rui, "shouldShowEvacInfo", true )
			RuiSetBool( rui, "shouldShowEvacTimer", true )
			RuiSetImage( rui, "evacIcon", $"rui/gamemodes/shadow_squad/evac_countdown" )
			RuiSetColorAlpha( rui, "evacFrameColor", SrgbToLinear( EVAC_INCOMING_HUD_ELEMENT_COL ), 1.0 )
			RuiSetColorAlpha( rui, "evacIconColor", SrgbToLinear( EVAC_INCOMING_HUD_ELEMENT_COL ), 1.0 )
			RuiSetColorAlpha( rui, "evacBgColor", SrgbToLinear(< 0.1, 0.1, 0.1 >), 1.0 )
			RuiSetGameTime( rui, "nextEvacPhaseTime", GetGlobalNetTime( "shadowArmy_NextEvacPhaseTime" ) )
			RuiSetString( rui, "evacText", Localize( "#SHADOW_ARMY_OBJ_EVAC_WAITING" ) )
		}

		FlagWait( "EvacShipArrived_Client" )
	}

	localPlayer = GetLocalViewPlayer()
	currentPhase = ShadowArmy_GetCurrentGamePhase()
	if ( currentPhase < eShadowArmyGamePhase.EVAC_SHIP_DEPARTED )
	{
		if ( rui != null )
		{
			RuiSetBool( rui, "shouldShowEvacInfo", true )
			RuiSetBool( rui, "shouldShowEvacTimer", true )
			RuiSetBool( rui, "hasEvacArrived", true )
			RuiSetImage( rui, "evacIcon", $"rui/gamemodes/shadow_squad/evac_countdown" )
			RuiSetColorAlpha( rui, "evacFrameColor", SrgbToLinear( EVAC_ARRIVED_HUD_ELEMENT_COL ), 1.0 )
			RuiSetColorAlpha( rui, "evacIconColor", SrgbToLinear(< 1.0, 1.0, 1.0 >), 1.0 )
			RuiSetColorAlpha( rui, "evacBgColor", SrgbToLinear(< 0.4, 0.15, 0.15>), 1.0 )
			RuiSetGameTime( rui, "nextEvacPhaseTime", GetGlobalNetTime( "shadowArmy_NextEvacPhaseTime" ) )
			RuiSetString( rui, "evacText", Localize( "#SHADOW_ARMY_OBJ_EVAC_ARRIVED" ) )
			RuiSetInt( rui, "legendsOnEvacShips", GetNumLegendsOnEvacShips())
			RuiSetInt( rui, "legendEvacTarget", file.evacTargetCount )
		}
		FlagWait( "EvacShipDeparting_Client" )
	}

	if ( rui != null )
	{
		RuiSetBool( rui, "shouldShowEvacInfo", false )
		RuiSetBool( rui, "shouldShowEvacTimer", false )
	}
}
#endif // CLIENT

#if SERVER
// Test to see if a team should win the match
bool function TryToDetermineWinner_Elimination()
{
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return false

	// If at any point, the living legends count drops to 0, Revs win
	if ( GetLivingLegendsCount() <= 0 )
	{
		ShadowArmy_SetWinner( SHADOWARMY_REVENANT_ALLIANCE, eWinReason.ELIMINATION )
		return true
	}

	return false
}
#endif //SERVER

#if SERVER
// Set the winner of the match, gameover
const float WINNER_DETERMINED_WAIT_DURATION = 4.0
void function ShadowArmy_SetWinner( int winningAlliance, int winReason )
{
	#if DEVELOPER
		if ( GetConVarInt( "mp_enablematchending" ) == 0 )
		{
			printt( "Shadow Army: Set winner function triggered but ignoring because mp_enablematchending is set to false" )
			return
		}
	#endif // DEV

	SetCustomWinnerDeterminedLength( WINNER_DETERMINED_WAIT_DURATION )
	GamemodeUtility_GamemodeSetWinnerCommon( winningAlliance, winReason, ShadowArmyOnlySetWinnerFunctionality )
}
#endif // SERVER

#if SERVER
// Logic unique to the Shadow Army gamemode for the set winner function
void function ShadowArmyOnlySetWinnerFunctionality( int winningAlliance )
{
	TurnOffRespawnForLivingLegends()

	int resultFlags = ShadowArmy_GetFlagsetForVictoryCondition( svGlobal.winReason, winningAlliance )
	Survival_SetGameResultFlags( resultFlags )

	// Play a different stinger depending on if the player won or lost and then trigger victory music based on the winning Alliance
	bool didLegendsWin = winningAlliance == SHADOWARMY_LEGEND_ALLIANCE
	array < entity > allPlayerAndSpectatorArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayerAndSpectatorArray )
	{
		if ( IsValid( player ) )
		{
			StopAllMusicOnPlayer( player )
			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_PlayMatchEndMusic", didLegendsWin )
		}

	}
}
#endif // SERVER

                      
#if SERVER
void function ShadowArmy_OnMatchBehaviorEnd( entity player, bool wasUnexpectedDisconnect )
{
	if ( IsValid( player ) )
	{
		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_SetDeathScreenCallbacks" )

		// Only restore the player character if they are leaving the game before the winner is determined. Otherwise we will restore the character before the podium and match results
		// We restore the player when the game ends from the gamestate callback on post match
		if ( GetGameState() < eGameState.WinnerDetermined  )
			RestoreRevPlayerToPreviouslySelectedCharacter( player )
	}
}
#endif // SERVER
                            

#if CLIENT
// Set the data for match summary to show correct text
void function ShadowArmy_ServerCallback_SetDeathScreenCallbacks()
{
	DeathScreen_SetModeSpecificRuiUpdateFunc( ShadowArmy_DeathScreenUpdate )
	DeathScreen_SetDataRuiAssetForGamemode( DEATH_SCREEN_RUI )
}
#endif // CLIENT

#if CLIENT
void function ShadowArmy_DeathScreenUpdate( var rui )
{
	SquadSummaryData squadData = GetSquadSummaryData()

	string titleString = squadData.squadPlacement == 1 ? "#SQUAD_PLACEMENT_GCARDS_TITLE" : "#SHADOW_ARMY_SQUAD_HEADER_DEFEAT"
	string killsText   = "#CONTROL_DEATH_SCREEN_SUMMARY_KILLS_ALLIANCE"

	string victoryCondition = ShadowArmy_GetVictoryConditionForFlagset( squadData.gameResultFlags )
	RuiSetString( rui, "victoryCondition", victoryCondition )
	RuiSetString( rui, "headerText", titleString ) // this may not actually be used. Or, rather, it's hidden behind the "big" one in death_screen_header
	RuiSetString( rui, "killsText", killsText )

	if ( squadData.gameResultFlags == SHADOWARMY_VICTORY_FLAGS_EVAC || squadData.gameResultFlags == SHADOWARMY_VICTORY_FLAGS_PREVENTED_EVAC )
	{
		// losing score always represents the number of players that evacuated, the winning score is the target
		RuiSetInt( rui, "losingScore", GetNumLegendsOnEvacShips() )
		RuiSetInt( rui, "winningScore", file.evacTargetCount )
	}
}
#endif // CLIENT

#if CLIENT
string function ShadowArmy_GetVictoryConditionForFlagset( int gameResultFlags )
{
	string victoryCondition
	switch( gameResultFlags )
	{
		case( SHADOWARMY_VICTORY_FLAGS_ELIMINATION ):
			victoryCondition = SHADOWARMY_PIN_VICTORYCONDITION_ELIMINATION
			break
		case( SHADOWARMY_VICTORY_FLAGS_EVAC ):
			victoryCondition = SHADOWARMY_PIN_VICTORYCONDITION_EVAC
			break
		case( SHADOWARMY_VICTORY_FLAGS_PREVENTED_EVAC ):
			victoryCondition = SHADOWARMY_PIN_VICTORYCONDITION_PREVENTED_EVAC
			break
		case( SHADOWARMY_VICTORY_FLAGS_FORFEIT ):
			victoryCondition = SHADOWARMY_PIN_VICTORYCONDITION_FORFEIT
			break
		default:
			victoryCondition = SHADOWARMY_PIN_VICTORYCONDITION_UNKNOWN
			break
	}

	return victoryCondition
}
#endif // CLIENT

#if SERVER
int function ShadowArmy_GetFlagsetForVictoryCondition( int victoryCondition, int winningAlliance )
{
	int victoryFlag
	switch( victoryCondition )
	{
		case( eWinReason.ELIMINATION ):
			victoryFlag = SHADOWARMY_VICTORY_FLAGS_ELIMINATION
			break
		case( eWinReason.OBJECTIVE_COMPLETED ):
			if ( winningAlliance == SHADOWARMY_LEGEND_ALLIANCE )
			{
				victoryFlag = SHADOWARMY_VICTORY_FLAGS_EVAC
			}
			else if ( winningAlliance == SHADOWARMY_REVENANT_ALLIANCE )
			{
				victoryFlag = SHADOWARMY_VICTORY_FLAGS_PREVENTED_EVAC
			}
			else
			{
				victoryFlag = SHADOWARMY_VICTORY_FLAGS_UNKNOWN
				#if DEVELOPER
					Assert( false, "Shadow Army: ShadowArmy_GetFlagsetForVictoryCondition is running for victory condition eWinReason.OBJECTIVE_COMPLETED on an invalid alliance: " + winningAlliance + " Expect Rev Alliance: " + SHADOWARMY_REVENANT_ALLIANCE + " or Legend Alliance: " + SHADOWARMY_LEGEND_ALLIANCE )
				#endif // DEV
			}
			break
		case( eWinReason.TEAM_FORFEIT ):
			victoryFlag = SHADOWARMY_VICTORY_FLAGS_FORFEIT
			break
		default:
			victoryFlag = SHADOWARMY_VICTORY_FLAGS_UNKNOWN
			break
	}

	return victoryFlag
}
#endif // SERVER

#if SERVER
int function ShadowArmy_GetCurrentRank( entity player )
{
	if ( GetAllTeams().len() <= 1 )
		return 1

	if ( GetGameState() <= eGameState.Playing )
		return 2

	int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
	int winningAlliance = AllianceProximity_GetAllianceFromTeam( GetWinningTeam() )

	return playerAlliance == winningAlliance ? 1 : 2
}
#endif // SERVER

#if CLIENT
const array < string > ELIMINATION_DIALOGUE_LINES = [ "diag_ap_nocNotify_ltm_evacFail_01_01_3p",
	"diag_ap_nocNotify_ltm_evacFail_01_02_3p",
	"diag_ap_nocNotify_ltm_evacFail_02_01_3p",
	"diag_ap_nocNotify_ltm_evacFail_02_02_3p",
	"diag_ap_nocNotify_ltm_evacFail_03_01_3p",
	"diag_ap_nocNotify_ltm_evacFail_03_02_3p",
	"diag_ap_nocNotify_ltm_evacFail_04_01_3p",
	"diag_ap_nocNotify_ltm_evacFail_04_02_3p"
]
const array < string > EVAC_SUCCESS_DIALOGUE_LINES = [ "diag_ap_nocNotify_ltm_evacComplete_01_01_3p",
	"diag_ap_nocNotify_ltm_evacComplete_01_02_3p",
	"diag_ap_nocNotify_ltm_evacComplete_02_01_3p",
	"diag_ap_nocNotify_ltm_evacComplete_02_02_3p",
	"diag_ap_nocNotify_ltm_evacComplete_03_01_3p",
	"diag_ap_nocNotify_ltm_evacComplete_03_02_3p",
	"diag_ap_nocNotify_ltm_evacComplete_04_01_3p",
	"diag_ap_nocNotify_ltm_evacComplete_04_02_3p",
	"diag_ap_nocNotify_ltm_evacComplete_05_01_3p",
	"diag_ap_nocNotify_ltm_evacComplete_05_02_3p",
]
const array < string > EVAC_FAIL_DIALOGUE_LINES = [ "diag_ap_nocNotify_ltm_evacNearMiss_01_01_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_01_02_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_02_01_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_02_02_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_03_01_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_03_02_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_04_01_3p",
	"diag_ap_nocNotify_ltm_evacNearMiss_04_02_3p",
]
VictorySoundPackage function GetVictorySoundPackage()
{
	VictorySoundPackage victorySoundPackage
	SquadSummaryData winningSquadData = GetWinnerSquadSummaryData()

	switch( winningSquadData.gameResultFlags )
	{
		case( SHADOWARMY_VICTORY_FLAGS_ELIMINATION ):
			victorySoundPackage.youAreChampPlural = ELIMINATION_DIALOGUE_LINES.getrandom()
			victorySoundPackage.youAreChampSingular = ELIMINATION_DIALOGUE_LINES.getrandom()
			victorySoundPackage.theyAreChampSingular = ELIMINATION_DIALOGUE_LINES.getrandom()
			victorySoundPackage.theyAreChampPlural = ELIMINATION_DIALOGUE_LINES.getrandom()
			break
		case( SHADOWARMY_VICTORY_FLAGS_EVAC ):
			victorySoundPackage.youAreChampPlural = EVAC_SUCCESS_DIALOGUE_LINES.getrandom()
			victorySoundPackage.youAreChampSingular = EVAC_SUCCESS_DIALOGUE_LINES.getrandom()
			victorySoundPackage.theyAreChampSingular = EVAC_SUCCESS_DIALOGUE_LINES.getrandom()
			victorySoundPackage.theyAreChampPlural = EVAC_SUCCESS_DIALOGUE_LINES.getrandom()
			break
		case( SHADOWARMY_VICTORY_FLAGS_PREVENTED_EVAC ):
			victorySoundPackage.youAreChampPlural = EVAC_FAIL_DIALOGUE_LINES.getrandom()
			victorySoundPackage.youAreChampSingular = EVAC_FAIL_DIALOGUE_LINES.getrandom()
			victorySoundPackage.theyAreChampSingular = EVAC_FAIL_DIALOGUE_LINES.getrandom()
			victorySoundPackage.theyAreChampPlural = EVAC_FAIL_DIALOGUE_LINES.getrandom()
			break
		case( SHADOWARMY_VICTORY_FLAGS_FORFEIT ):
			victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_ltm_evacFail_04_01_3p"
			victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_ltm_evacFail_04_01_3p"
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_ltm_evacComplete_01_01_3p"
			victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_ltm_evacComplete_01_01_3p"
			break
		default: // Do same dialogue as forfeit for default. Better to have wrong audio than a crash
			victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_ltm_evacFail_04_01_3p"
			victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_ltm_evacFail_04_01_3p"
			victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_ltm_evacComplete_01_01_3p"
			victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_ltm_evacComplete_01_01_3p"
			break
	}

	return victorySoundPackage
}
#endif // CLIENT

#if CLIENT
// Play the match intro sound for Legends, it requires some delay to get the timing right
const float SFX_DELAY = 2.5
void function ShadowArmy_PlayIntroBannerSoundForLegends_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )

	wait SFX_DELAY

	EmitUISound( SFX_SHADOWARMY_LEGEND_SPAWN )
}
#endif // CLIENT

#if SERVER || CLIENT
// Get num Legends on Evac Ships
int function GetNumLegendsOnEvacShips()
{
	return GetGlobalNetInt( "shadowArmy_LegendsInEvacShips" )
}
#endif //SERVER || CLIENT

#if CLIENT
// Update the hud element keeping track of Legends on Evac Ships
void function UpdateLegendInEvacShipHUDCount( entity player, int newCount )
{
	var rui = ClGameState_GetRui()

	if ( rui != null )
		RuiSetInt( rui, "legendsOnEvacShips", newCount )
}
#endif // CLIENT

#if CLIENT
// Update the hud element keeping track of Legends on Evac Ships
void function ShadowArmy_ServerCallback_UpdateEvacTargetCountOnHud( int targetCount )
{
	if ( targetCount >= 0 && targetCount <= MAX_EVAC_TARGET_COUNT_FOR_LEGENDS )
	{
		file.evacTargetCount = targetCount
		var rui = ClGameState_GetRui()
		if ( rui != null )
			RuiSetInt( rui, "legendEvacTarget", targetCount )
	}
}
#endif // CLIENT




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CATCHUP MECHANICS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#if SERVER
// Increase the catchup mechanic time index for each minute of gameplay and trigger the setting of catchup mechanics every minute
const float DELAY_BETWEEN_CATCHUP_UPDATES = 60.0
void function ManageCatchupMechanicLevels_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !GetShouldUseCatchupMechanics() )
		return

	#if DEVELOPER
		if ( GetConVarInt( "mp_enablematchending" ) == 0 )
		{
			printt( "Shadow Army: ManageCatchupMechanicLevels_Thread function triggered but breaking out because mp_enablematchending is set to false" )
			return
		}
	#endif // DEV

	if ( IsValid( svGlobal.levelEnt ) )
		EndSignal( svGlobal.levelEnt, "GameEnd", "OnDestroy" )

	// Need to wait for players to be spawned
	FlagWait( "PlaneStartMoving" )

	int timeIndex = 0
	while ( GetGameState() == eGameState.Playing )
	{
		SetCatchupMechanicValues( timeIndex )
		timeIndex++

		wait DELAY_BETWEEN_CATCHUP_UPDATES
	}
}
#endif //SERVER

#if SERVER
// Based on the desired Legend counts at different ring stages, set where the actual squad count is
// A negative number means we have less Legend squads than desired and want to enable some catchup mechanics for the Legends
// A positive number means we have more Legend squads than desired and want to enable some catchup mechanics for the Revs
// Once we have that value determined, set the values of different catchup mechanics like respawn times or health
void function SetCatchupMechanicValues( int timeIndex )
{
	int currentTargetCount = GetTargetSquadDiffForTime( timeIndex ) // What is the ideal number of Legend Squads to have at this stage
	int minOffTargetCountToTrackOffTargetLevel = GetMinSquadOffTargetAmountToTriggerCatchupForTime( timeIndex ) // how far off from the target count does the current count need to be to track the off target level at all

	int currentLivingLegendCount = AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )
	int currentRevPlayerCount = AllianceProximity_GetNumPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, false )
	int expectedSquadSize = GetExpectedSquadSize()
	// We don't want actual squad counts, we want to know how many squads worth of players we have. It doesn't help with catchup mechanics if we count a squad with 1 player the same as a squad with 3
	int currentLivingLegendSquadCount = currentLivingLegendCount > expectedSquadSize ? currentLivingLegendCount/expectedSquadSize : 1
	int currentRevSquadCount = currentRevPlayerCount > expectedSquadSize ? currentRevPlayerCount/expectedSquadSize : 1
	int currentSquadCountDiff = int( ( currentLivingLegendSquadCount - currentRevSquadCount ) * 0.5 ) // divide the count by half because the count differences get doubled ( when 1 legend squad subtracts, it goes to the rev side making a diff of 2 for each 1 squad )
	int currentDiffLevel = currentSquadCountDiff - currentTargetCount // We take the difference between the Legend players and Rev players then see how off target we are from the goal diff
	printt( "Shadow Army: " + FUNC_NAME() +
	" currentTargetCount: " + currentTargetCount +
	" minOffTargetCountToTrackOffTargetLevel: " + minOffTargetCountToTrackOffTargetLevel +
	" currentLivingLegendCount: " + currentLivingLegendCount +
	" currentRevPlayerCount: " + currentRevPlayerCount +
	" currentLivingLegendSquadCount: " + currentLivingLegendSquadCount +
	" currentRevSquadCount: " + currentRevSquadCount +
	" currentDiffLevel: " + currentDiffLevel)

	if ( currentDiffLevel == 0 )
		file.remainingLegendSquadOffTargetLevel = 0
	else if ( abs( currentDiffLevel ) > minOffTargetCountToTrackOffTargetLevel ) // Only track an off target count if the count is off by a minimum amount
		file.remainingLegendSquadOffTargetLevel = currentDiffLevel > 0 ? currentDiffLevel - minOffTargetCountToTrackOffTargetLevel : currentDiffLevel + minOffTargetCountToTrackOffTargetLevel
	else
		file.remainingLegendSquadOffTargetLevel = 0

	printt( "Shadow Army: " + FUNC_NAME() + " final catchup level: " + file.remainingLegendSquadOffTargetLevel )

	ShadowArmy_SetMaxHealthForShadowsValue()
	ShadowArmy_SetModifiedSpawnDelayForShadowsValue()
	ShadowArmy_SetHealthGainedOnKill_FullRev()
	ShadowArmy_SetHealthGainedOnKill_Legend()
}
#endif // SERVER

#if SERVER
// Some catchup mechanics don't trigger at all off target levels unless they reach a certain threshold and then strength of the mechanic is modified
// This function returns a modified off target level based on the off target modifier
int function GetAdjustedLegendSquadOffTargetCount( int offTargetModifier )
{
	int offTargetLevel = file.remainingLegendSquadOffTargetLevel

	if ( offTargetModifier != 0 )
	{
		if ( offTargetLevel >= offTargetModifier )
			offTargetLevel -= offTargetModifier
		else if ( offTargetLevel <= offTargetModifier * -1 )
			offTargetLevel += offTargetModifier
		else
			offTargetLevel = 0
	}

	// Make sure we are still inside the defined bounds
	offTargetLevel = minint( GetMaxLevelForCatchupMechanics(), offTargetLevel )
	offTargetLevel = maxint( GetMinLevelForCatchupMechanics(), offTargetLevel )

	return offTargetLevel
}
#endif // SERVER


#if SERVER
// Set the max health to set for Melee Revs when they spawn
// Give them more health when the current Legend Squad count is higher than the target count ( Revs need a boost )
void function ShadowArmy_SetMaxHealthForShadowsValue()
{
	float healthValue = GetShadowRevBaseHealth()
	float healthValueIncrements = GetCurrentPlaylistVarFloat( "shadow_army_shadow_health_increments", 10 )
	int offTargetModifier = GetCurrentPlaylistVarInt( "shadow_army_shadow_health_offtargetmodifier", 0 ) // In Case we don't want to use this as a catchup mechanic unless the off target count is off by more than this. This also affects the strength of the modifier
	int offTargetLevel = GetAdjustedLegendSquadOffTargetCount( offTargetModifier )
	healthValue += ( offTargetLevel * healthValueIncrements )
	// Stay within bounds, also gives us more control over tunings
	float minHealthValue = GetCurrentPlaylistVarFloat( "shadow_army_shadow_min_health", 90.0 )
	float maxHealthValue = GetCurrentPlaylistVarFloat( "shadow_army_shadow_max_health", 120.0 )
	healthValue = max( healthValue, minHealthValue )
	healthValue = min( healthValue, maxHealthValue )
	file.shadowMaxHealth = healthValue
	printt( "Shadow Army: " + FUNC_NAME() + " offTargetModifier: " + offTargetModifier + " offTargetLevel: " + offTargetLevel + " healthValue: " + healthValue )
}
#endif // SERVER

#if SERVER
// Get the max health to set for Melee Revs when they spawn
float function ShadowArmy_GetMaxHealthValueForShadows()
{
	return file.shadowMaxHealth
}
#endif // SERVER

#if SERVER
// Tune the respawn time for Melee Revs based on how well the Legend Alliance is doing
void function ShadowArmy_SetModifiedSpawnDelayForShadowsValue()
{
	float baseCooldown = GetShadowRevBaseSpawnCooldown()
	float cooldownIncrements = GetCurrentPlaylistVarFloat( "shadow_army_respawn_cooldown_increments", 5 )
	int offTargetModifier = GetCurrentPlaylistVarInt( "shadow_army_respawn_cooldown_offtargetmodifier", 0 ) // In Case we don't want to use this as a catchup mechanic unless the off target count is off by more than this. This also affects the strength of the modifier
	int offTargetLevel = GetAdjustedLegendSquadOffTargetCount( offTargetModifier )

	// When the desired remaining Legend squad count is too low, increase the respawn time. When it is too high, decrease the respawn time
	float additionalCooldown = ( cooldownIncrements * offTargetLevel ) * -1
	float modifiedRevRespawnTime = baseCooldown + additionalCooldown

	// Stay within bounds, also gives us more control over tunings
	float minCooldownValue = GetCurrentPlaylistVarFloat( "shadow_army_shadow_min_respawn_cooldown", 3.0 )
	float maxCooldownValue = GetCurrentPlaylistVarFloat( "shadow_army_shadow_max_respawn_cooldown", 15.0 )
	modifiedRevRespawnTime = max( modifiedRevRespawnTime, minCooldownValue )
	modifiedRevRespawnTime = min( modifiedRevRespawnTime, maxCooldownValue )

	file.modifiedRevRespawnTime = modifiedRevRespawnTime
	printt( "Shadow Army: " + FUNC_NAME() + " offTargetModifier: " + offTargetModifier + " offTargetLevel: " + offTargetLevel + " additionalCooldown: " + additionalCooldown + " modifiedRevRespawnTime: " + file.modifiedRevRespawnTime )
}
#endif // SERVER

#if SERVER
// Give a different spawn delay for Rev Players and Rev Players who just joined the Rev Alliance
// We want you to respawn quickly after switching alliances so players don't leave the game or be confused about what is happening
// Also tune the respawn timers based on how well the Legend Alliance is doing
float function ShadowArmy_GetPlayerSpawnDelay( entity player )
{
	float baseCooldown = GetShadowRevBaseSpawnCooldown()
	float shortCooldown = GetCurrentPlaylistVarFloat( "shadow_army_short_respawn_cooldown", SHADOWARMY_DEFAULT_SHORT_SPAWN_DELAY )
	float shortestPossibleCooldown = GetCurrentPlaylistVarFloat( "shadow_army_shortest_respawn_cooldown", SHADOWARMY_SHORTEST_POSSIBLE_SPAWN_DELAY )
	float cooldownTime = baseCooldown
	if ( IsValid( player ) )
	{
		int team = player.GetTeam()
		// This function is triggered before the team switch occurs, which is convenient, we can just test to see if the team is on the Legend alliance
		if ( AllianceProximity_GetAllianceFromTeam( team ) == SHADOWARMY_LEGEND_ALLIANCE )
		{
			cooldownTime = shortCooldown
		}
		else if ( player == file.fullRevOrCandidatePlayer ) // Full Rev gets respawned almost right away
		{
			cooldownTime = shortestPossibleCooldown
		}
		else // Determine the respawn time for regular melee revs
		{
			cooldownTime = file.modifiedRevRespawnTime

			// If the player hasn't died a lot and the short respawn time is shorter than the expected respawn time, give them a short respawn time ( mostly just don't want rev players near the start of the game or players who have recently switched sides to have long cooldown times )
			int playerDeaths = GetTotalNumberOfDeaths( player )
			if ( playerDeaths <= GetShadowRevLowDeathCountThresholdForSpawnTime() )
				cooldownTime = min( cooldownTime, shortCooldown )
		}
	}

	return max( shortestPossibleCooldown, cooldownTime ) // Make sure we don't mess anything up and have a cooldown that is way too short
}
#endif // SERVER

#if SERVER
// What is the min time between Red Eyed Revs
float function GetFullRevCooldownDuration()
{
	float baseCooldown = GetCurrentPlaylistVarFloat( "shadow_army_fullrev_cooldown_base", DEFAULT_FULL_REV_SPAWN_COOLDOWN )

	if ( !GetShouldUseCatchupMechanics() )
		return baseCooldown

	float cooldownIncrements = GetCurrentPlaylistVarFloat( "shadow_army_fullrev_cooldown_increments", 0 )
	int offTargetModifier = GetCurrentPlaylistVarInt( "shadow_army_fullrev_cooldown_offTargetModifier", 0 ) // In Case we don't want to use this as a catchup mechanic unless the off target count is off by more than this. This also affects the strength of the modifier
	int offTargetLevel = GetAdjustedLegendSquadOffTargetCount( offTargetModifier )

	// When the desired remaining Legend squad count is too low, increase the cooldown time. When it is too high, decrease the cooldown time
	float additionalCooldown = ( cooldownIncrements * offTargetLevel ) * -1
	float modifiedCooldown = baseCooldown + additionalCooldown

	// Stay within bounds, also gives us more control over tunings
	float minCooldownValue = GetCurrentPlaylistVarFloat( "shadow_army_fullrev_min_cooldown", 0.0 )
	float maxCooldownValue = GetCurrentPlaylistVarFloat( "shadow_army_fullrev_max_cooldown", 60.0 )
	modifiedCooldown = max( modifiedCooldown, minCooldownValue )
	modifiedCooldown = min( modifiedCooldown, maxCooldownValue )

	printt( "Shadow Army: " + FUNC_NAME() + " offTargetModifier: " + offTargetModifier + " offTargetLevel: " + offTargetLevel + " additionalCooldown: " + additionalCooldown + " modifiedCooldown: " + modifiedCooldown )
	return modifiedCooldown
}
#endif // SERVER


#if SERVER
// Set How much the Red Eyed Rev is healed on kill depending on the catchup level
void function ShadowArmy_SetHealthGainedOnKill_FullRev()
{
	int baseHeal = GetBaseFullRevOnKillHealAmount()
	int healIncrement = GetCurrentPlaylistVarInt( "shadow_army_heal_fullrev_onkill_increment_amount", LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL )
	int offTargetModifier = GetCurrentPlaylistVarInt( "shadow_army_heal_fullrev_offtarget_modifier", 0 ) // In Case we don't want to use this as a catchup mechanic unless the off target count is off by more than this. This also affects the strength of the modifier
	int offTargetLevel = GetAdjustedLegendSquadOffTargetCount( offTargetModifier )

	// When the desired remaining Legend squad count is too low, decrease the health gained on kill. When it is too high, increase the health gained on kill
	int additionalHealing = ( healIncrement * offTargetLevel )
	int modifiedHealthGained = baseHeal + additionalHealing

	// Stay within bounds, also gives us more control over tunings
	int minHealValue = GetCurrentPlaylistVarInt( "shadow_army_heal_fullrev_onkill_min_amount", 0 )
	int maxHealValue = GetCurrentPlaylistVarInt( "shadow_army_heal_fullrev_onkill_max_amount", 100 )
	modifiedHealthGained = maxint( modifiedHealthGained, minHealValue )
	modifiedHealthGained = minint( modifiedHealthGained, maxHealValue )

	file.healthGainedOnKill_FullRev = modifiedHealthGained
	printt( "Shadow Army: " + FUNC_NAME() + " offTargetModifier: " + offTargetModifier + " offTargetLevel: " + offTargetLevel + " additionalHealing: " + additionalHealing + " healthGainedOnKill_FullRev: " + file.healthGainedOnKill_FullRev )
}
#endif // SERVER

#if SERVER
// How much is the Red Eyed Rev healed on kill
int function GetAmountToHealRedEyedRevPlayerOnKill()
{
	return file.healthGainedOnKill_FullRev
}
#endif // SERVER

#if SERVER
// Set How much Legends are healed on kill, modified by the catchup logic
void function ShadowArmy_SetHealthGainedOnKill_Legend()
{
	int baseHeal = GetBaseLegendOnKillHealAmount()
	int healIncrement = GetCurrentPlaylistVarInt( "shadow_army_heal_legends_onkill_increment_amount", LEGEND_DEFAULT_HEAL_AMOUNT_ON_KILL )
	int offTargetModifier = GetCurrentPlaylistVarInt( "shadow_army_heal_legends_offtarget_modifier", 0 ) // In Case we don't want to use this as a catchup mechanic unless the off target count is off by more than this. This also affects the strength of the modifier
	int offTargetLevel = GetAdjustedLegendSquadOffTargetCount( offTargetModifier )

	// When the desired remaining Legend squad count is too low, increase the health gained on kill. When it is too high, decrease the health gained on kill
	int additionalHealing = ( healIncrement * offTargetLevel ) * -1
	int modifiedHealthGained = baseHeal + additionalHealing

	// Stay within bounds, also gives us more control over tunings
	int minHealValue = GetCurrentPlaylistVarInt( "shadow_army_heal_legends_onkill_min_amount", 0 )
	int maxHealValue = GetCurrentPlaylistVarInt( "shadow_army_heal_legends_onkill_max_amount", 100 )
	modifiedHealthGained = maxint( modifiedHealthGained, minHealValue )
	modifiedHealthGained = minint( modifiedHealthGained, maxHealValue )

	file.healthGainedOnKill_Legend =  modifiedHealthGained
	printt( "Shadow Army: " + FUNC_NAME() + " offTargetModifier: " + offTargetModifier + " offTargetLevel: " + offTargetLevel + " additionalHealing: " + additionalHealing + " healthGainedOnKill_Legend: " + file.healthGainedOnKill_Legend )
}
#endif // SERVER

#if SERVER
// How much are Legends healed on kill
int function GetAmountToHealLegendPlayerOnKill()
{
	return file.healthGainedOnKill_Legend
}
#endif // SERVER

#if SERVER
int function GetAmountToHealShadowPlayerOnDown( entity player )
{
	bool shouldHealShadowsOnDown = GetCurrentPlaylistVarBool( "shadow_army_should_heal_shadows_ondown", true )
	if ( shouldHealShadowsOnDown && IsValid( player ) )
		return player.GetMaxHealth()

	return 0
}
#endif // SERVER

#if SERVER
int function GetAmountToHealShadowPlayerOnKill( entity player )
{
	bool shouldHealShadowsOnKill = GetCurrentPlaylistVarBool( "shadow_army_should_heal_shadows_onkill", true )
	if ( shouldHealShadowsOnKill && IsValid( player ) )
		return player.GetMaxHealth()

	return 0
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AUDIO AND COMMENTARY
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if CLIENT
void function CreateMusicEntityIfNotValid()
{
	if ( !IsValid( file.musicEntity ) )
	{
		file.musicEntity = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", <0,0,10000>, <0, 0, 0> )
		file.musicRampUpLevel = MUSIC_RAMPUP_LEVEL_NOT_SET
	}
}
#endif // CLIENT

#if CLIENT
void function UpdateMusicRampUpLevel( int newLevel )
{
	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) )
		return

	CreateMusicEntityIfNotValid()
	if ( !IsValid( file.musicEntity ) )
		return

	// Only change the level if the ramp is going up
	if ( newLevel > file.musicRampUpLevel && newLevel < MUSIC_RAMPUP_CONTROLLER_VALUES.len() )
	{
		// If setting for first time, start playing the music
		if ( file.musicRampUpLevel == MUSIC_RAMPUP_LEVEL_NOT_SET )
		{
			if ( ShadowArmy_IsPlayerOnShadowArmy( localPlayer ) )
				EmitSoundOnEntity( file.musicEntity, MUSIC_SHADOWARMY_GAMEPLAY_RAMPUP_REV )
			else
				EmitSoundOnEntity( file.musicEntity, MUSIC_SHADOWARMY_GAMEPLAY_RAMPUP_LEGEND )

			file.musicEntity.UnsetSoundCodeControllerValue()
		}

		float controllerValue = MUSIC_RAMPUP_CONTROLLER_VALUES[ newLevel ]
		file.musicEntity.SetSoundCodeControllerValue( controllerValue )
		file.musicRampUpLevel = newLevel
	}
}
#endif // CLIENT

#if CLIENT
// This is used when a player reconnects to a match or switches alliances
// We reset the music entity and then trigger it at the appropriate level
void function ResetMusicRampUpAtLevelForClient()
{
	// We only play ramp up music during the playing gamestate
	if ( GetGameState() != eGameState.Playing )
		return

	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) )
		return

	// Reset ramp up music level so when the ramp up is triggered we start playing the right music track
	ShadowArmy_StopRampUpMusic()

	// Set the music ramp to the appropriate level
	int currentGamePhase = ShadowArmy_GetCurrentGamePhase()
	if ( currentGamePhase == eShadowArmyGamePhase.EVAC_SHIP_ARRIVED )
		UpdateMusicRampUpLevel( eShadowArmyMusicRampLevels.EVAC_ARRIVED )
	else if ( currentGamePhase == eShadowArmyGamePhase.EVAC_OBJECTIVE )
		UpdateMusicRampUpLevel( eShadowArmyMusicRampLevels.EVAC_SEQUENCE_STARTED )
	else if ( currentGamePhase < eShadowArmyGamePhase.EVAC_SHIP_DEPARTED && SURVIVAL_GetCurrentDeathFieldStage() >= GetRingStageWhenEvacLocationRevealed() )
		UpdateMusicRampUpLevel( eShadowArmyMusicRampLevels.PRE_EVAC_SEQUENCE )
}
#endif // CLIENT

#if CLIENT
// Trigger a win or lose stinger when the match ends and then play music depending on which alliance won
void function ShadowArmy_ServerCallback_PlayMatchEndMusic( bool didLegendsWin )
{
	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) )
		return

	bool isPlayerOnLegendAlliance = !ShadowArmy_IsPlayerOnShadowArmy( localPlayer )
	bool didLocalAllianceWin = isPlayerOnLegendAlliance && didLegendsWin || !isPlayerOnLegendAlliance && !didLegendsWin

	// Stop ramp up music
	ShadowArmy_StopRampUpMusic()

	// Play match end music
	if ( didLocalAllianceWin )
		EmitUISound( SFX_SHADOWARMY_MATCH_WIN_STINGER )
	else
		EmitUISound( SFX_SHADOWARMY_MATCH_LOSE_STINGER )

	// Victory music doesn't care about if your alliance won or lost, it is just dependant on which alliance won
	if ( didLegendsWin )
		EmitSoundOnEntity( localPlayer, MUSIC_SHADOWARMY_LEGEND_VICTORY )
	else
		EmitSoundOnEntity( localPlayer, MUSIC_SHADOWARMY_REV_VICTORY )
}
#endif // CLIENT

#if CLIENT
// Stop music playing on ramp up music entity
void function ShadowArmy_StopRampUpMusic()
{
	if ( IsValid( file.musicEntity ) )
	{
		StopSoundOnEntity( file.musicEntity, MUSIC_SHADOWARMY_GAMEPLAY_RAMPUP_LEGEND )
		StopSoundOnEntity( file.musicEntity, MUSIC_SHADOWARMY_GAMEPLAY_RAMPUP_REV )
	}
	file.musicRampUpLevel = MUSIC_RAMPUP_LEVEL_NOT_SET
}
#endif // CLIENT

#if SERVER
// Play a commentary line when the first player boards the Evac Ship
void function ShadowArmy_TryToPlayPlayerBoardedEvacCommentary()
{
	// Play a line when the first player to board a ship boards one
	if ( GetNumLegendsOnEvacShips() == 1 && GetGameState() == eGameState.Playing )
		PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOWARMY_EVAC_SHIP_BOARDED ) )
}
#endif // SERVER



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MESSAGING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if CLIENT
void function OverrideGameState()
{
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_survival_shadowarmy.rpak" )
}
#endif // CLIENT

#if SERVER
// Display a banner message for the player when they respawn
// Message can vary depending on player form and gamestate
void function DisplayRespawnBannerMessageForPlayer( entity player, int previousForm, int respawnForm )
{
	int messageIndex = INVALID_INDEX
	switch( previousForm )
	{
		case eShadowArmyRespawnForm.LIVING_LEGEND:
			if ( respawnForm == eShadowArmyRespawnForm.LIVING_LEGEND )
			{
				if ( ShadowArmy_GetCurrentGamePhase() >= eShadowArmyGamePhase.EVAC_OBJECTIVE )
					messageIndex = eShadowArmyMessageIndex.RESPAWNING_AS_LEGEND_EVAC
				else
					messageIndex = eShadowArmyMessageIndex.RESPAWNING_AS_LEGEND
			}
			else
			{
				messageIndex = eShadowArmyMessageIndex.RESPAWNING_AS_SHADOW_FROM_LEGEND
			}
			break
		case eShadowArmyRespawnForm.FULL_REVENANT:
			messageIndex = eShadowArmyMessageIndex.RESPAWNING_AS_SHADOW_FIRST_TIME
			break
		case eShadowArmyRespawnForm.SHADOW:
			if ( respawnForm == eShadowArmyRespawnForm.FULL_REVENANT )
				messageIndex = eShadowArmyMessageIndex.RESPAWNING_AS_FULL_REV
			else
				messageIndex = eShadowArmyMessageIndex.RESPAWNING_AS_SHADOW
			break
		default:
			#if DEVELOPER
				Assert( false, "Shadow Army: Unsupported previous form passed in for player in DisplayRespawnBannerMessageForPlayer" )
			#endif // DEV
			break
	}

	if ( messageIndex != INVALID_INDEX )
		Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowAnnouncementMessage", messageIndex, eShadowArmyMessageType.ANNOUNCE_ONLY )
}
#endif //SERVER

#if SERVER
// Display a message after a delay
void function AnnouncementSplashDelayed_Thread( entity player, int messageIndex, float delay, int messageType )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsValid( player ) )
		return

	// Don't do messaging if we have passed in an invalid message type
	if ( messageType < 0 || messageType > eShadowArmyMessageType._count )
		return

	EndSignal( player, "OnDeath", "OnDestroy" )

	wait delay

	Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowAnnouncementMessage", messageIndex, messageType )
}
#endif //SERVER

#if SERVER
// Clear out existing messages by displaying a blank one
void function ShadowArmy_ClearAllAnnouncementSplashes( entity player )
{
	if ( !IsValid( player ) )
		return

	Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowAnnouncementMessage", eShadowArmyMessageIndex.BLANK, eShadowArmyMessageType.ANNOUNCE_ONLY )
}
#endif //SERVER

#if SERVER
// Trigger splash messaging for all players
void function ShadowArmy_DisplayMessageForAllPlayers( int messageIndexLivingLegend, int messageIndexShadowLegend, int messageType )
{
	// Don't do messaging if we're already game over
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	// Don't do messaging if we have passed in an invalid message type
	if ( messageType < 0 || messageType > eShadowArmyMessageType._count )
		return

	// send messages to living legend players if the message index is valid
	if ( messageIndexLivingLegend >= 0 && messageIndexLivingLegend < eShadowArmyMessageIndex._count )
	{
		array < entity > legendPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )

		int commentaryBucket = ShadowArmy_GetAnnouncmentBucketFromMessageIndex( messageIndexLivingLegend )

		foreach( player in legendPlayers )
		{
			if ( !IsValid( player ) )
				continue

			if ( IsDisconnected( player ) )
				continue

			if  ( commentaryBucket != -1 )
				PlayCharacterOrRadioDialogueToPlayer( PickCommentaryLineFromBucketAndHost( commentaryBucket, eSurvivalHostType.LOBA  ), player, eDialogueFlags.MUTE_PLAYER_PING_DIALOGUE_FOR_DURATION )

			ShadowArmy_ClearAllAnnouncementSplashes( player )
			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowAnnouncementMessage", messageIndexLivingLegend, messageType )
		}
	}

	// Send messages to shadow army players if the message index is valid
	if ( messageIndexShadowLegend >= 0 && messageIndexShadowLegend < eShadowArmyMessageIndex._count )
	{
		array < entity > shadowPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, true )

		foreach( player in shadowPlayers )
		{
			if ( !IsValid( player ) )
				continue

			if ( IsDisconnected( player ) )
				continue

			ShadowArmy_ClearAllAnnouncementSplashes( player )
			Remote_CallFunction_NonReplay( player, "ShadowArmy_ServerCallback_ShowAnnouncementMessage", messageIndexShadowLegend, messageType )
		}
	}
}

int function ShadowArmy_GetAnnouncmentBucketFromMessageIndex( int messageIndex )
{
	switch ( messageIndex )
	{
		case eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_LEGEND:
		case eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_LEGEND:
			return eSurvivalCommentaryBucket.SHADOW_ARMY_LOBA_EVAC_INCOMING
			break
		case eShadowArmyMessageIndex.EVAC_ARRIVED_LEGEND:
			return eSurvivalCommentaryBucket.SHADOW_ARMY_LOBA_EVAC_ARRIVED
			break
		default:
			break
	}

	return -1
}
#endif //SERVER

#if CLIENT
// Server to Client function that triggers the display of a HUD message using a passed in message index
void function ShadowArmy_ServerCallback_ShowAnnouncementMessage( int messageIndex, int messageType )
{
	ShowAnnouncementMessage( messageIndex, messageType )
}
#endif //CLIENT

#if CLIENT
// Display a HUD message based on the passed in message index. Message indexes are defined in eShadowArmyMessageIndex
void function ShowAnnouncementMessage( int messageIndex, int messageType )
{
	if ( messageIndex < 0 || eShadowArmyMessageIndex._count < messageIndex )
		return

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	string messageText
	string subText
	string obitText
	asset leftIcon
	asset rightIcon
	string soundAlias = SFX_HUD_ANNOUNCE_QUICK
	float duration = SHADOWARMY_ANNOUNCEMENT_DURATION
	vector titleColor

	switch( messageIndex )
	{
		case eShadowArmyMessageIndex.BLANK:
			messageText = ""
			subText = ""
			obitText = ""
			duration = 0.0
			break
		case eShadowArmyMessageIndex.LTM_DROP_ANNOUNCE_LEGEND:
			messageText = GetCurrentPlaylistVarString( "name", "#GAMEMODE_ANNOUNCE_NONE" )
			subText = "#SHADOW_ARMY_LTM_BANNER_MESSAGE_LEGEND"
			soundAlias = SFX_HUD_ANNOUNCE_LTM
			leftIcon = ANNOUNCEMENT_LOBA_ICON_FG
			rightIcon = ANNOUNCEMENT_LOBA_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_0 )
			break
		case eShadowArmyMessageIndex.LTM_DROP_ANNOUNCE_SHADOW:
			messageText = GetCurrentPlaylistVarString( "name", "#GAMEMODE_ANNOUNCE_NONE" )
			subText = "#SHADOW_ARMY_LTM_BANNER_MESSAGE_REV"
			duration = ANNOUNCEMENT_DURATION
			soundAlias = SFX_HUD_ANNOUNCE_LTM
			leftIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_1 )
			break
		case eShadowArmyMessageIndex.RESPAWNING_AS_SHADOW_FIRST_TIME:
			messageText = "#SHADOW_ARMY_RESPAWNING_REV_FIRST_TIME"
			subText = "#SHADOW_ARMY_RESPAWNING_REV_FIRST_TIME_SUB"
			soundAlias = SFX_SHADOWARMY_REV_ARMY_REV_RESPAWN_STINGER
			leftIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_1 )
			break
		case eShadowArmyMessageIndex.RESPAWNING_AS_SHADOW:
			messageText = "#SHADOW_ARMY_RESPAWNING_REV"
			subText = "#SHADOW_ARMY_RESPAWNING_REV_SUB"
			soundAlias = SFX_SHADOWARMY_REV_ARMY_REV_RESPAWN_STINGER
			leftIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_1 )
			break
		case eShadowArmyMessageIndex.RESPAWNING_AS_SHADOW_FROM_LEGEND:
			messageText = "#SHADOW_ARMY_RESPAWNING_REV_FROM_LEGEND"
			subText = "#SHADOW_ARMY_RESPAWNING_REV_FROM_LEGEND_SUB"
			soundAlias = MUSIC_SHADOWARMY_LEGEND_SPAWN_AS_REV
			leftIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_SHADOW_REV_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_1 )
			ResetMusicRampUpAtLevelForClient() // Not really message related but better than a servercallback. Player switched alliances so update the ramp up music
			break
		case eShadowArmyMessageIndex.RESPAWNING_AS_FULL_REV:
			messageText = "#SHADOW_ARMY_RESPAWNING_FULL_REV"
			subText = "#SHADOW_ARMY_RESPAWNING_FULL_REV_SUB"
			soundAlias = SFX_SHADOWARMY_REDEYE_REV_RESPAWN_STINGER
			leftIcon = ANNOUNCEMENT_FULL_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_FULL_REV_ICON_FG
			titleColor = ANNOUNCEMENT_FULL_REV_BANNER_COLOR
			break
		case eShadowArmyMessageIndex.RESPAWNING_AS_LEGEND:
			messageText = "#SHADOW_ARMY_RESPAWNING_LEGEND"
			subText = "#SHADOW_ARMY_RESPAWNING_LEGEND_SUB"
			leftIcon = ANNOUNCEMENT_LOBA_ICON_FG
			rightIcon = ANNOUNCEMENT_LOBA_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_0 )
			break
		case eShadowArmyMessageIndex.RESPAWNING_AS_LEGEND_EVAC:
			messageText = "#SHADOW_ARMY_RESPAWNING_LEGEND_EVAC"
			subText = "#SHADOW_ARMY_RESPAWNING_LEGEND_EVAC_SUB"
			leftIcon = ANNOUNCEMENT_LOBA_ICON_FG
			rightIcon = ANNOUNCEMENT_LOBA_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_0 )
			break
		case eShadowArmyMessageIndex.FULL_REV_SPAWNED_LEGEND:
			messageText = "#SHADOW_ARMY_FULL_REV_SPAWNED_LEGEND"
			subText = "#SHADOW_ARMY_FULL_REV_SPAWNED_LEGEND_SUB"
			obitText = "#SHADOW_ARMY_FULL_REV_SPAWNED_OBIT"
			soundAlias = SFX_SHADOWARMY_REVENGE_KILL_MSG
			leftIcon = ANNOUNCEMENT_FULL_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_FULL_REV_ICON_FG
			titleColor = ANNOUNCEMENT_FULL_REV_BANNER_COLOR
			break
		case eShadowArmyMessageIndex.FULL_REV_SPAWNED_SHADOW:
			messageText = "#SHADOW_ARMY_FULL_REV_SPAWNED_SHADOW"
			subText = "#SHADOW_ARMY_FULL_REV_SPAWNED_SHADOW_SUB"
			obitText = "#SHADOW_ARMY_FULL_REV_SPAWNED_OBIT"
			leftIcon = ANNOUNCEMENT_FULL_REV_ICON_FG
			rightIcon = ANNOUNCEMENT_FULL_REV_ICON_FG
			titleColor = ANNOUNCEMENT_FULL_REV_BANNER_COLOR
			break
		case eShadowArmyMessageIndex.FULL_REV_KILLED:
			obitText = "#SHADOW_ARMY_FULL_REV_KILLED_OBIT"
			break
		case eShadowArmyMessageIndex.LEGEND_TEAM_SWITCHED_TO_REV:
			obitText = "#SHADOW_ARMY_LEGENDS_SWITCH_OBIT"
			break
		case eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_LEGEND:
			messageText = "#SHADOW_ARMY_EVAC_CALLED_IN_RING_LEGEND"
			subText = "#SHADOW_ARMY_EVAC_CALLED_IN_LEGEND_SUB"
			soundAlias = SFX_SHADOWARMY_EVAC_MSG_STINGER_NORMAL
			titleColor = SrgbToLinear( EVAC_INCOMING_HUD_ELEMENT_COL )
			break
		case eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_SHADOW:
			messageText = "#SHADOW_ARMY_EVAC_CALLED_IN_RING_SHADOW"
			subText = "#SHADOW_ARMY_EVAC_CALLED_IN_SHADOW_SUB"
			soundAlias = SFX_SHADOWARMY_EVAC_MSG_STINGER_NORMAL
			titleColor = SrgbToLinear( EVAC_INCOMING_HUD_ELEMENT_COL )
			break
		case eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_LEGEND:
			messageText = "#SHADOW_ARMY_EVAC_CALLED_IN_EMERG_LEGEND"
			subText = "#SHADOW_ARMY_EVAC_CALLED_IN_LEGEND_SUB"
			soundAlias = SFX_SHADOWARMY_EVAC_MSG_STINGER_NORMAL
			titleColor = SrgbToLinear( EVAC_INCOMING_HUD_ELEMENT_COL )
			break
		case eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_SHADOW:
			messageText = "#SHADOW_ARMY_EVAC_CALLED_IN_EMERG_SHADOW"
			subText = "#SHADOW_ARMY_EVAC_CALLED_IN_SHADOW_SUB"
			soundAlias = SFX_SHADOWARMY_EVAC_MSG_STINGER_NORMAL
			titleColor = SrgbToLinear( EVAC_INCOMING_HUD_ELEMENT_COL )
			break
		case eShadowArmyMessageIndex.EVAC_ARRIVED_LEGEND:
			messageText = "#SHADOW_ARMY_EVAC_ARRIVED_LEGEND"
			subText = "#SHADOW_ARMY_EVAC_ARRIVED_LEGEND_SUB"
			titleColor = SrgbToLinear( EVAC_ARRIVED_HUD_ELEMENT_COL )
			break
		case eShadowArmyMessageIndex.EVAC_ARRIVED_SHADOW:
			messageText = "#SHADOW_ARMY_EVAC_ARRIVED_SHADOW"
			subText = "#SHADOW_ARMY_EVAC_ARRIVED_SHADOW_SUB"
			titleColor = SrgbToLinear( EVAC_ARRIVED_HUD_ELEMENT_COL )
			break
		case eShadowArmyMessageIndex.SAFE_ON_EVAC_SHIP:
			messageText = "#SHADOW_ARMY_SAFE_ON_EVAC_SHIP"
			subText = "#SHADOW_ARMY_SAFE_ON_EVAC_SHIP_SUB"
			soundAlias = SFX_SHADOWARMY_END_MSG
			leftIcon = ANNOUNCEMENT_LOBA_ICON_FG
			rightIcon = ANNOUNCEMENT_LOBA_ICON_FG
			titleColor = GetKeyColor( COLORID_ALLIANCE_0 )
			break
		case eShadowArmyMessageIndex.ALLIANCE_SWITCH_DISABLED_LEGEND:
			messageText = "#SHADOW_ARMY_SWITCHING_DISABLED_LEGEND"
			subText = "#SHADOW_ARMY_SWITCHING_DISABLED_LEGEND_SUB"
			obitText = "#SHADOW_ARMY_LEGENDS_SWITCH_DISABLED_OBIT"
			soundAlias = SFX_SHADOWARMY_END_MSG
			titleColor = GetKeyColor( COLORID_ALLIANCE_0 )
			break
		case eShadowArmyMessageIndex.ALLIANCE_SWITCH_DISABLED_SHADOW:
			messageText = "#SHADOW_ARMY_SWITCHING_DISABLED_SHADOW"
			subText = "#SHADOW_ARMY_SWITCHING_DISABLED_SHADOW_SUB"
			obitText = "#SHADOW_ARMY_LEGENDS_SWITCH_DISABLED_OBIT"
			soundAlias = SFX_SHADOWARMY_END_MSG
			titleColor = GetKeyColor( COLORID_ALLIANCE_1 )
			break
		case eShadowArmyMessageIndex.LEGENDS_RESPAWNED:
			obitText = "#SHADOW_ARMY_LEGENDS_RESPAWNED_OBIT"
			break
		case eShadowArmyMessageIndex.LEGEND_ENTERED_EVAC_SHIP:
			obitText = "#SHADOW_ARMY_LEGEND_BOARDED_EVAC"
			break
		case eShadowArmyMessageIndex.EVAC_AREA_UPDATED:
			if ( !ShadowArmy_IsPlayerOnShadowArmy( player ) )
				obitText = "#SHADOW_ARMY_EVAC_LOCATION_UPDATED"
			else
				return // Don't want to print anything here for Rev Army players
			break
		case eShadowArmyMessageIndex.EVAC_LOCATION_REVEALED:
			obitText = "#SHADOW_ARMY_EVAC_LOCATION_REVEALED"
			break
		default:
			#if DEVELOPER
				Assert( false, "Shadow Army: Unhandled messageIndex: " + messageIndex )
			#endif // DEV
			break
	}

	if ( messageType == eShadowArmyMessageType.ANNOUNCE_ONLY || messageType == eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
	{
		AnnouncementData announcement = Announcement_Create( messageText )
		Announcement_SetSubText( announcement, subText )
		Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
		Announcement_SetPurge( announcement, true )
		Announcement_SetPriority( announcement, 200 )
		Announcement_SetSoundAlias( announcement, soundAlias )
		announcement.duration = duration
		Announcement_SetLeftIcon( announcement, leftIcon )
		Announcement_SetRightIcon( announcement, rightIcon )
		Announcement_SetTitleColor( announcement, titleColor )
		AnnouncementFromClass( player, announcement )
	}

	if ( messageType == eShadowArmyMessageType.OBIT_ONLY || messageType == eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
		Obituary_Print_Localized( Localize( obitText ) )

	// Force an update of the respawn HUD
	if ( messageIndex == eShadowArmyMessageIndex.LEGENDS_RESPAWNED )
		UpdateLegendsWaitingToRespawnCountOnHud()
}
#endif //CLIENT

#if CLIENT
// Display a Hint message based on the passed in hint index. Hint indexes are defined in eShadowArmyHintIndex
// Ints can be passed in where needed
const float HINT_DISPLAY_TIME = 5.0
const float HINT_FADE_TIME = 1.0
void function ShadowArmy_ServerCallback_ShowHinttMessage( int hintIndex, int optionalInt1, int optionalInt2 )
{
	if ( hintIndex < 0 || eShadowArmyHintIndex._count < hintIndex )
		return

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	string messageText
	bool shouldDisplayHint = true

	switch( hintIndex )
	{
		case eShadowArmyHintIndex.FULL_REV_CANDIDATE_HINT:
			string buttonHint = IsControllerModeActive() ? "%offhand1% + %ping%" : "%offhand4%"
			messageText = Localize( "#SHADOW_ARMY_FULL_REV_CANDIDATE_HINT", buttonHint )
			break
		case eShadowArmyHintIndex.FULL_REV_CRITERIA_NO_DAM_HINT:
			messageText = "#SHADOW_ARMY_FULL_REV_CRITERIA_NO_DAM_HINT"
			break
		default:
			#if DEVELOPER
				Assert( false, "Shadow Army: Unhandled hintIndex: " + hintIndex )
			#endif // DEV
			shouldDisplayHint = false
			break
	}

	if ( shouldDisplayHint )
		AddPlayerHint( HINT_DISPLAY_TIME, HINT_FADE_TIME, $"", messageText )
}
#endif //CLIENT

#if CLIENT
void function OnPlayerLifeStateChanged_Client( entity player, int oldState, int newState )
{
	UpdateLegendsWaitingToRespawnCountOnHud()

	// Update the map icon colors for this player if they recently switched alliances
	// Need to do the update here after the player spawn callback so the map icon is created
	if ( IsValid( player ) && IsAlive( player ) && Flag( "AllianceAssignmentComplete" ) && file.playersRespawningAfterAllianceSwitch.contains( player ) )
	{
		thread UpdatePlayerHUDOnDelay_Thread( player )
		file.playersRespawningAfterAllianceSwitch.fastremovebyvalue( player )
	}
}
#endif // CLIENT

#if CLIENT
// Need to delay HUD updates even after a player has respawned because it can take a while for the minimap object to be created
const float HUD_UPDATE_DELAY = 0.5
void function UpdatePlayerHUDOnDelay_Thread( entity player )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )

	if ( !IsValid( player ) )
		return

	EndSignal( player, "OnDestroy" )

	wait HUD_UPDATE_DELAY

	Squads_SetCustomPlayerInfo( player )
	ShadowArmy_SetGameStateIsRevArmy( player )
}
#endif // CLIENT

#if CLIENT
// Update the HUD counter showing the number of Legends waiting to Respawn when gameplay starts
void function ShadowArmy_OnGamestateEnterPlaying_Client()
{
	thread RunPostAllianceAssignmentCompleteLogic_Thread( GetLocalClientPlayer() )
}
#endif // CLIENT

#if CLIENT
void function OnYouRespawned()
{
	entity localPlayer = GetLocalViewPlayer()
	if ( IsValid( localPlayer ) && localPlayer.IsPlayer() )
	{
		// Go ahead and update every player including enemies, as you may have just swapped teams
		if ( GetGameState() == eGameState.Playing && Flag( "AllianceAssignmentComplete" ) )
		{
			array < entity > allPlayers = GetPlayerArray()
			foreach ( entity player in allPlayers )
			{
				if ( !IsValid( player ) )
					continue

				Squads_SetCustomPlayerInfo( player )
			}
		}

		thread ObjectiveEvac_ManageHUDMessaging_Thread()
	}
}
#endif // CLIENT

#if CLIENT
void function ShadowArmy_OnPlayerConnectionStateChanged( entity player )
{
	if ( IsValid( player ) && player == GetLocalClientPlayer() )
	{
		// This function runs for connnects and disconnects, we only care about a reconnect
		if ( player.IsConnectionActive() )
		{
			thread ObjectiveEvac_ManageHUDMessaging_Thread()
			ResetMusicRampUpAtLevelForClient()
		}
	}
}
#endif // CLIENT

#if CLIENT
// Run logic for the Client player that needs to fire on reconnect but also needs alliance assignment to be complete to know which alliance the player is on
const int EVAC_AREA_ICON_PRIORITY = 1100
void function RunPostAllianceAssignmentCompleteLogic_Thread( entity localPlayer )
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )

	if ( !IsValid( localPlayer ) )
		return

	EndSignal( localPlayer, "OnDestroy" )

	if ( !Flag( "AllianceAssignmentComplete" ) )
		FlagWait( "AllianceAssignmentComplete" )

	UpdateLegendsWaitingToRespawnCountOnHud()

	// Set a map feature item for the Evac Area
	SetMapFeatureItem( EVAC_AREA_ICON_PRIORITY, "#SHADOW_ARMY_EVAC_AREA", "#SHADOW_ARMY_EVAC_AREA_DESC", EVAC_AREA_ICON )

	// Set a map feature item for the Legend Start Area but only for Revenants
	// Trigger map scans if the Rev is alive
	if ( ShadowArmy_IsPlayerOnShadowArmy( localPlayer ) )
		SetMapFeatureItem( EVAC_AREA_ICON_PRIORITY, "#SHADOW_ARMY_LEGEND_SPAWN_AREA", "#SHADOW_ARMY_LEGEND_SPAWN_AREA_DESC", LEGEND_START_AREA_ICON )

	array < entity > allPlayers = GetPlayerArray()
	foreach ( entity player in allPlayers )
	{
		if ( !IsValid( player ) )
			continue

		Squads_SetCustomPlayerInfo( player )
		ShadowArmy_SetGameStateIsRevArmy( player )
	}
}
#endif // CLIENT

#if CLIENT
void function ShadowArmy_OnSpectateTargetChanged( entity player, entity previousTarget, entity currentTarget )
{
	if ( IsValid( currentTarget ) && currentTarget.IsPlayer() && GetGameState() == eGameState.Playing )
	{
		thread RunPostAllianceAssignmentCompleteLogic_Thread( player )
		thread ObjectiveEvac_ManageHUDMessaging_Thread()
	}
}
#endif // CLIENT

#if CLIENT
void function ShadowArmy_SetGameStateIsRevArmy( entity player )
{
	if( !IsValid( player ) )
		return

	var rui = ClGameState_GetRui()

	if ( rui != null )
		RuiSetBool( rui, "isRevArmy", ShadowArmy_IsPlayerOnShadowArmy( player ) )
}
#endif // CLIENT

#if CLIENT
// Update the HUD counter showing the number of Legends waiting to Respawn
void function UpdateLegendsWaitingToRespawnCountOnHud()
{
	var rui = ClGameState_GetRui()

	if ( rui != null )
		RuiSetInt( rui, "legendsAwaitingRespawn", ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount() )

	// Update count on the map ( respawn beacon feature ) as well
	ShadowArmy_RespawnBeacon_UpdateBeaconMapFeature()
}
#endif // CLIENT

#if UI
// Populate the About screen with tabs, text, and images related to Shadow Army
array< featureTutorialTab > function ShadowArmy_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	string playlistUiRules = GetPlaylist_UIRules()

	if ( playlistUiRules != GAMEMODE_SHADOW_ARMY )
		return tabs

	featureTutorialTab tab1
	featureTutorialTab tab2
	featureTutorialTab tab3
	featureTutorialTab tab4

	array< featureTutorialData > tab1Rules
	array< featureTutorialData > tab2Rules
	array< featureTutorialData > tab3Rules
	array< featureTutorialData > tab4Rules

	// Tab 1 contains surface overview of the mode
	tab1.tabName = "#GAMEMODE_RULES_OVERVIEW_TAB_NAME"
	string currentPlaylist = ShadowArmy_GetCurrentShadowArmyPlaylist()
	int maxTotalPlayers = GetPlaylistVarInt( currentPlaylist, "max_players", MAX_PLAYERS )
	int maxTeams = GetPlaylistVarInt( currentPlaylist, "max_teams", MAX_TEAMS )
	int squadSize = maxTotalPlayers > 0 && maxTeams > 0 ? maxTotalPlayers / maxTeams : 0
	int startingRevs = squadSize * ShadowArmy_GetNumRevSquadsForMatchStart()
	int startingLegends = maxTotalPlayers - startingRevs

	string overview1BodyText = Localize( "#SHADOW_ARMY_ABOUT_OVERVIEW_1_BODY", string( startingLegends ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_OVERVIEW_1_HEADER", overview1BodyText, $"rui/hud/gametype_icons/ltm/about_shadowroyal_1" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_OVERVIEW_2_HEADER", "#SHADOW_ARMY_ABOUT_OVERVIEW_2_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_2" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_OVERVIEW_3_HEADER", "#SHADOW_ARMY_ABOUT_OVERVIEW_3_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_3" ) )

	// Tab 2 contains info about the Legend Alliance
	tab2.tabName = "#SHADOW_ARMY_ABOUT_LEGENDS_TAB_NAME"
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_LEGENDS_1_HEADER", "#SHADOW_ARMY_ABOUT_LEGENDS_1_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_legends_1" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_LEGENDS_2_HEADER", "#SHADOW_ARMY_ABOUT_LEGENDS_2_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_legends_2" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_LEGENDS_3_HEADER", "#SHADOW_ARMY_ABOUT_LEGENDS_3_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_legends_3" ) )

	// Tab 3 contains info about the Revenant Alliance
	tab3.tabName = "#SHADOW_ARMY_ABOUT_REVS_TAB_NAME"
	tab3Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_REVS_1_HEADER", "#SHADOW_ARMY_ABOUT_REVS_1_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_rev_1" ) )
	tab3Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_REVS_2_HEADER", "#SHADOW_ARMY_ABOUT_REVS_2_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_rev_2" ) )
	tab3Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOW_ARMY_ABOUT_REVS_3_HEADER", "#SHADOW_ARMY_ABOUT_REVS_3_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyal_rev_3" ) )

	tab1.rules = tab1Rules
	tab2.rules = tab2Rules
	tab3.rules = tab3Rules
	tab4.rules = tab4Rules

	tabs.append( tab1 )
	tabs.append( tab2 )
	tabs.append( tab3 )
	tabs.append( tab4 )

	return tabs
}
#endif // UI

#if SERVER
// Play announcer commentary when we are down to 1 Legend squad with living players on it, as long as it hasn't been too soon since we played it last
const float LAST_SQUAD_COMMENTARY_COOLDOWN_TIME = 60.0
void function TryPlayingLastSquadAnnouncerCommentary()
{
	// Only continue if there is 1 Legend squad with living players remaining
	if ( AllianceProximity_GetLivingPlayerTeamsInAlliance( SHADOWARMY_LEGEND_ALLIANCE ).len() != 1 )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	bool isPastCooldownTime = file.timeOfLastRemainingSquadCommentary < 0 || Time() > file.timeOfLastRemainingSquadCommentary + LAST_SQUAD_COMMENTARY_COOLDOWN_TIME
	if ( isPastCooldownTime )
	{
		PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_ARMY_LAST_SQUAD ) )
		file.timeOfLastRemainingSquadCommentary = Time()
	}
}
#endif // SERVER

#if SERVER
// Play announcer commentary when we are down to half Legend squads remaining as long as we haven't played this line before
void function TryPlayingHalfRemainingLegendSquadAnnouncerCommentary()
{
	if ( file.didPlayHalfLegendSquadRemainingCommentary )
		return

	// Figure out what half legend squads is
	int maxTeams = GetCurrentPlaylistVarInt( "max_teams", MAX_TEAMS )
	int maxAlliances = GetCurrentPlaylistVarInt( "max_alliances", 0 )
	int totalLegendSquadCount = 0

	if ( maxTeams > 0 && maxAlliances > 0 )
		totalLegendSquadCount = maxTeams / maxAlliances

	// Only play the line if there is ever more than 1 Legend Squad in the game and we are at half squads remaining
	if ( totalLegendSquadCount > 1 && GetRemainingLivingLegendSquadsCount() == totalLegendSquadCount / 2 )
	{
		PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_ARMY_HALF_SQUADS ) )
		file.didPlayHalfLegendSquadRemainingCommentary = true
	}
}
#endif // SERVER

#if SERVER
// Show an area where the Legends started the match for the Rev Alliance on match start to give players a target location to land
// Destroy the marker shortly after the dropship sequence completes
const float EXTRA_WAIT_DURATION = 30.0
const float LEGEND_START_AREA_RADIUS = 24000.0
void function ManageRevAllianceLegendStartWaypoint_Thread()
{
	#if DEVELOPER
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	// Need to wait for players to be spawned
	FlagWait( "PlaneStartMoving" )

	if ( GetGameState() != eGameState.Playing )
		return

	array < entity > livingLegendPlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, true )
	// If no enemies for the Revs, just back out
	if ( livingLegendPlayers.len() == 0 )
		return

	// Create a map hint
	vector hintLoc = GetCenter( livingLegendPlayers )
	entity minimapHint = CreatePropScript( $"mdl/dev/empty_model.rmdl", hintLoc )
	minimapHint.Minimap_SetObjectScale( LEGEND_START_AREA_RADIUS/SURVIVAL_MINIMAP_RING_SCALE )
	minimapHint.Minimap_SetAlignUpright( true )
	minimapHint.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	minimapHint.Minimap_SetClampToEdge( true )
	minimapHint.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
	minimapHint.DisableHibernation()
	SetTargetName( minimapHint, SHADOWARMY_LEGEND_START_AREA )

	// Show for all Rev Teams
	array < int > allRevTeams = AllianceProximity_GetPopulatedTeamsInAlliance( SHADOWARMY_REVENANT_ALLIANCE )
	foreach ( revTeam in allRevTeams )
	{
		minimapHint.Minimap_AlwaysShow( revTeam, null )
	}

	// Hide for Legends
	array < int > legendTeams = AllianceProximity_GetTeamsInAlliance( SHADOWARMY_LEGEND_ALLIANCE )
	foreach ( legendTeam in legendTeams )
	{
		minimapHint.Minimap_Hide( legendTeam, null )
	}

	// Show an in world icon
	entity inWorldMarkerWaypoint = CreateWaypoint_BasicLocation( hintLoc + EVAC_WAYPOINT_VERTICAL_OFFSET, ePingType.LEGEND_START_AREA )
	int friendlyTeam = AllianceProximity_GetRepresentativeTeamForAlliance( SHADOWARMY_REVENANT_ALLIANCE )
	AllianceProximity_SetOnlyTransmitWaypointToFriendlyTeams( inWorldMarkerWaypoint, friendlyTeam )

	OnThreadEnd(
		function() : ( minimapHint, inWorldMarkerWaypoint )
		{
			if ( IsValid( minimapHint ) )
				minimapHint.Destroy()

			if ( IsValid( inWorldMarkerWaypoint ) )
				inWorldMarkerWaypoint.Destroy()

			array < entity > revPlayersArray = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, false )
			foreach ( revPlayer in revPlayersArray )
			{
				if ( IsValid( revPlayer ) )
					Remote_CallFunction_NonReplay( revPlayer, "ShadowArmy_ServerCallback_DestroyLegendStartAreaMapFeature" )
			}
		}
	)

	if ( IsValid( svGlobal.levelEnt ) )
		EndSignal( svGlobal.levelEnt, "GameEnd", "OnDestroy" )

	// Wait for the plane to reach the end of its path
	FlagWait( "PlaneAtLaunchPoint" )

	// Wait additional time
	wait EXTRA_WAIT_DURATION
}
#endif //SERVER

#if CLIENT
// Destroy the map feature we created for the Legend Start Area when we remove the inworld icon and map area
void function ShadowArmy_ServerCallback_DestroyLegendStartAreaMapFeature()
{
	RemoveMapFeatureItemByName( "#SHADOW_ARMY_LEGEND_SPAWN_AREA" )
}
#endif // CLIENT




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEBUGGING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if DEVELOPER && SERVER
// Set the player inputting the command to be a full Rev or a random player
void function ShadowArmy_SetPlayerToFullRev_Dev( bool shouldUseRandomPlayer = false )
{
	entity playerToRev
	if ( shouldUseRandomPlayer )
	{
		array< entity > revPlayersArray =  AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_REVENANT_ALLIANCE, true )
		playerToRev = revPlayersArray.getrandom()
	}
	else
	{
		playerToRev = GetPlayerArray()[0]
	}

	if ( IsValid( playerToRev ) )
	{
		printt( "Shadow Army: Running Debug Command ShadowArmy_SetPlayerToFullRev_Dev on " + playerToRev + " going to kill them and set them to a Full Rev" )
		// If there is already a full rev and they are not the player, kill them
		entity livingFullRev = GetLivingFullRevPlayer()
		if ( IsValid( livingFullRev ) && livingFullRev != playerToRev )
		{
			array < entity > fullRevSquad =  GetPlayerArrayOfTeam( livingFullRev.GetTeam() ) // need to kill everyone in the Full Rev squad so the full Rev doesn't enter bleedout state
			foreach ( fullRevSquadMember in fullRevSquad )
			{
				if ( IsValid( fullRevSquadMember ) && IsAlive( fullRevSquadMember ) )
					fullRevSquadMember.TakeDamage( fullRevSquadMember.GetHealth(), null, null, { scriptType = DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS | DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_weapon_shotgun_pistol } )
			}
		}
		else if ( IsValid( file.fullRevOrCandidatePlayer ) ) // We have a candidate Full Rev but they haven't spawned as Rev yet, just remove them from being a candidate
		{
			file.fullRevOrCandidatePlayer = null
		}

		// Remove the player from previous full Rev list so they can be full Rev again
		file.previousFullRevsArray.clear()

		// Make the player the Full Rev Candidate
		SetPlayerAsFullRevCandidate( playerToRev )

		// If the player is a bot, kill them so they respawn
		if ( playerToRev.IsBot() )
			playerToRev.TakeDamage( playerToRev.GetHealth(), null, null, { scriptType = DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS | DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_weapon_shotgun_pistol } )
	}
	else
	{
		printt( "Shadow Army: Running Debug Command ShadowArmy_SetPlayerToFullRev_Dev but the player was invalid, nothing will be done" )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Trigger Dropship sequences at all the Level Ed Placed Evac Ship Nodes
void function ShadowArmy_TriggerEvacShipsAtAllLocations_Dev()
{
	printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerEvacShipsAtAllLocations_Dev" )
	foreach ( evacLocation, evacShipLocationsArray in file.evacLocationToEvacShipLocationsTable )
	{
		// Display an icon for each Evac Location node
		if ( IsValid( evacLocation ) )
			CreateWaypoint_BasicLocation( evacLocation.GetOrigin() + EVAC_WAYPOINT_VERTICAL_OFFSET, ePingType.EVAC_SHIP )

		// Trigger an Evac Ship test sequence at every evac ship location
		foreach ( evacShipLocation in evacShipLocationsArray )
		{
			if ( IsValid( evacShipLocation ) )
				thread Dev_DebugEvacPos( evacShipLocation.GetOrigin(), evacShipLocation.GetAngles(), false, false )
		}
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// As long as we are not already in the Evac sequence, skip to it
void function ShadowArmy_TriggerEvacPhase_Dev( bool isEmergencyEvac = false )
{
	if ( ShadowArmy_GetCurrentGamePhase() < eShadowArmyGamePhase.EVAC_OBJECTIVE && !GamemodeUtility_IsWinnerBeingDetermined() )
	{
		printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerEvacPhase_Dev going to start the Evac Sequence" )

		if ( !isEmergencyEvac )
		{
			ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_LEGEND, eShadowArmyMessageIndex.EVAC_CALLED_IN_RING_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
			ChangeGamePhase( eShadowArmyGamePhase.EVAC_OBJECTIVE )
		}
		else
		{
			ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_LEGEND, eShadowArmyMessageIndex.EVAC_CALLED_IN_EMERGENCY_SHADOW, eShadowArmyMessageType.ANNOUNCE_AND_OBIT )
			svGlobal.levelEnt.Signal( "EmergencyEvacTriggered" )
		}
	}
	else
	{
		printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerEvacPhase_Dev but the gamephase is already at or past the Evac Sequence, not going to do anything" )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// As long as the match isn't already determining a match winner, set the winner now
void function ShadowArmy_TriggerMatchEnd_Dev( int winningAlliance = SHADOWARMY_LEGEND_ALLIANCE, bool didWinByObjectiveCompletion = true )
{
	if ( !GamemodeUtility_IsWinnerBeingDetermined() )
	{

		if ( winningAlliance == SHADOWARMY_REVENANT_ALLIANCE )
		{
			if ( didWinByObjectiveCompletion )
			{
				printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerMatchEnd_Dev going to set Revs as winning by preventing Legends from Evacuating" )
				ShadowArmy_SetWinner( SHADOWARMY_REVENANT_ALLIANCE, eWinReason.OBJECTIVE_COMPLETED )
			}
			else
			{
				printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerMatchEnd_Dev going to set Revs as winning by Eliminating all Legends" )
				ShadowArmy_SetWinner( SHADOWARMY_REVENANT_ALLIANCE, eWinReason.ELIMINATION )
			}

		}
		else if ( winningAlliance == SHADOWARMY_LEGEND_ALLIANCE )
		{
			printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerMatchEnd_Dev going to set Legends as winning by Evac" )
			ShadowArmy_SetWinner( SHADOWARMY_LEGEND_ALLIANCE, eWinReason.OBJECTIVE_COMPLETED )
		}
		else
		{
			printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerMatchEnd_Dev but an invalid alliance was passed in: " + winningAlliance + " expect 0 for Legend Alliance or 1 for Rev Alliance" )
		}
	}
	else
	{
		printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerMatchEnd_Dev but the winner has already been determined, not going to do anything" )
	}
}
#endif // DEV && SERVER
                                  
