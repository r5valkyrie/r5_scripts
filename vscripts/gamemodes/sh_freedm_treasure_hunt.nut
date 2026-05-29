                             

global function TreasureHunt_Init

#if CLIENT
global function ServerCallback_TreasureHunt_DisplayMessageToClient
global function TreasureHunt_InstanceObjectivePing
#endif

#if SERVER || CLIENT
global function TreasureHunt_GetStarterPingFromTraceBlockerPing
#endif // SERVER || CLIENT

#if DEVELOPER && SERVER
global function TreasureHunt_ForceCompleteAllObjectives_Dev
global function TreasureHunt_TriggerObjectiveUsingIndex_Dev
global function TreasureHunt_TriggerClosestObjective_Dev
#endif // DEV && SERVER

                  
          
                                                                                                                                                                          
                                                                  
                                                          
      
                        

#if SERVER || CLIENT
global const TREASUREHUNT_OBJECTIVE_SCRIPTNAME = "treasurehunt_objective"
#endif // SERVER || CLIENT

#if SERVER
const float MATCH_START_SCORE_PERCENT_THRESHOLD = 0.01 // What percentage of the max score do we consider the limit for the start of the match
const float MATCH_HALFWAY_SCORE_PERCENT_THRESHOLD = 0.5
const float MATCH_END_SCORE_PERCENT_THRESHOLD = 0.75 // What percentage of the max score do we consider the start of the match end phase of the match
const float DEFAULT_TREASURE_HUNT_ZONE_UPDATE_TIME_SECONDS = 0.5

// Music
const float RAMPUP_MUSIC_SCORE_THRESHOLD_1 = MATCH_END_SCORE_PERCENT_THRESHOLD
const float RAMPUP_MUSIC_SCORE_THRESHOLD_2 = 0.80
const float RAMPUP_MUSIC_SCORE_THRESHOLD_3 = 0.90
const float RAMPUP_MUSIC_SCORE_THRESHOLD_4 = 0.95
const float MUSIC_CONTROLLER_LEVEL_NOT_SET = -1.0
const float  MUSIC_CONTROLLER_LEVEL_4 = 200.0
const float  MUSIC_CONTROLLER_LEVEL_3 = 150.0
const float  MUSIC_CONTROLLER_LEVEL_2 = 100.0
const float  MUSIC_CONTROLLER_LEVEL_1 = 50.0

// SFX
const string CAPTURE_INCOMING_SFX_LOOP = "FreeDM_Zone_Incoming_3P"
const string CAPTURE_SPAWNED_SFX = "FreeDM_Zone_Spawn_3P"
const string CAPTURE_END_SFX = "FreeDM_Zone_Despawn_Uncaptured_3P"
const string CAPTURE_REWARD_SFX = "FreeDM_Zone_Despawn_Captured_3P"

// Tuning
const float PERCENT_TO_HEAL_SHIELDS_ON_CAPTURE = 1.0 // Note this value isn't used unless GetShouldHealScoringPlayersOnCaptureComplete returns true
const float PERCENT_TO_HEAL_HEALTH_ON_CAPTURE = 1.0 // Note this value isn't used unless GetShouldHealScoringPlayersOnCaptureComplete returns true
const int LOOT_CLEANUP_SEARCH_DISTANCE = 1000 // A bit over 25m, just around the objective area
const string LATEJOIN_EQUIPMENT_LOADOUT = "armor_pickup_lv3 helmet_pickup_lv3 incapshield_pickup_lv2"
#endif // SERVER

#if SERVER || CLIENT
const int MAX_SUPPORTED_TEAMS = 4
const int INVALID_OBJ_INDEX_DEFAULT = -1
const int INVALID_OBJ_INDEX_OBJ_COMPLETE = -2

// Models, Icons, VFX
const asset CAPTURE_ZONE_INCOMING_VFX = $"P_lockdown_objective_incoming"
const asset CAPTURE_ZONE_START_VFX = $"P_lockdown_objective_start"
const asset CAPTURE_ZONE_END_VFX = $"P_lockdown_objective_end"
const asset CAPTURE_ZONE_REWARD_VFX = $"P_lockdown_objective_capture"
const asset CAPTURE_ZONE_REWARD_WEAPON_TRAIL_VFX = $"P_lockdown_objective_capture_trail"
const asset PLATFORM_MODEL = $"mdl/props/treasurehunt_platform_01/treasure_hunt_platform_01.rmdl"

// Waypoint used to keep data up to date on Client
const int CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME = 0
const int CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_INDEX = 3
const int CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE = 4
const int CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER = 5

const float DELAYED_MESSAGE_DELAY = 2.5 // When we delay a message, how much do we delay it by?
const float CAPTURE_OBJ_INCOMING_DURATION = 30.0 // Objective timing, objective incoming delay is pretty hardcoded to 30 secs because of VFX and Audio duration for this state
#endif // SERVER || CLIENT

#if CLIENT
// SFX
const string LOCKDOWN_SFX_OBJ_CAPTURE_STARTED = "FreeDM_UI_InGame_FirstOnZone_1p"
const string LOCKDOWN_SFX_OBJ_CAPTURE_FINISHED = "FreeDM_UI_InGame_Zone_Capture_1p"
const string LOCKDOWN_SFX_OBJ_CAPTURING = "FreeDM_UI_InGame_Score_Gained_1P"
const string LOCKDOWN_SFX_CAPTURE_ZONE_ENTER = "FreeDM_UI_InGame_Zone_Enter_1p"
const string LOCKDOWN_SFX_CAPTURE_ZONE_EXIT = "FreeDM_UI_InGame_Zone_Exit_1p"
const string LOCKDOWN_SFX_CAPTURE_OBJ_INCOMING = "FreeDM_UI_InGame_Zone_Incoming_1P"
const string LOCKDOWN_SFX_CAPTURE_OBJ_SUDDEN_DEATH = "FreeDM_UI_InGame_Zone_SuddenDeath_1P"
const string LOCKDOWN_SFX_TEAM_HALFWAY_TO_WIN = "FreeDM_UI_InGame_MatchMidPoint_1P"
const string LOCKDOWN_SFX_TEAM_CLOSE_TO_WIN = "FreeDM_UI_InGame_MatchEndingSoon_1P"
const string LOCKDOWN_SFX_OBJECTIVE_CONTESTED = "FreeDM_UI_InGame_Zone_Contested_1P"
const string LOCKDOWN_SFX_TEAM_GAINED_LEAD = "FreeDM_UI_InGame_GainTheLead_1P"
const string LOCKDOWN_SFX_TEAM_LOST_LEAD = "FreeDM_UI_InGame_Demotion_1P"

// UI
const asset CAPTURE_OBJECTIVE_MAP_ICON = $"rui/hud/gametype_icons/control/capture_point_bg"
#endif

const string LOCKDOWN_VICTORY_SOUND = "FreeDM_UI_InGame_Victory_1P"
const string LOCKDOWN_LOSS_SOUND = "FreeDM_UI_InGame_Loss_1P"

#if SERVER
enum eTreasureHuntMatchScoringPhase
{
	EARLY,
	MID,
	LATE,
	_count,
}

enum eTreasureHuntMessageDisplayType
{
	TEAM,
	DEFINED_PLAYERS,
	TEAM_DEFINED_PLAYERS_COMBO,
	_count,
}

enum eTreasureHuntCatchupLevel
{
	NONE,
	MINOR,
	MAJOR,
	_count,
}
#endif // SERVER

#if SERVER || CLIENT
// Enum of timed events
enum eTreasureHuntTimedEventType
{
	CAPTURE,
	_count
}

enum eTreasureHuntCaptureZoneState
{
	INCOMING,
	NEUTRAL,
	CAPTURING,
	CONTESTED,
	SUDDEN_DEATH,

	_count,
}

enum eTreasureHuntMessageIndex
{
	SCORE_CAPTURE_INITIATED,
	SCORE_CAPTURE_INITIATED_PERSONAL,
	SCORE_CAPTURING,
	SCORE_OBJECTIVE_CAPTURED,
	SCORE_OBJECTIVE_CAPTURED_PERSONAL,
	SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH,
	SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH_PERSONAL,
	SCORE_KILL,
	SCORE_KILL_FROM_ZONE,
	SCORE_KILL_WINNER,
	CAPTURE_OBJECTIVE_INCOMING,
	OBJECTIVE_ENTERS_CONTESTED_STATE,
	OBJECTIVE_ENTERS_SUDDEN_DEATH,
	TEAM_GAINED_LEAD,
	TEAM_LOST_LEAD,
	TEAM_HALFWAY_TO_WIN,
	TEAM_HALFWAY_TO_WIN_PERSONAL,
	TEAM_CLOSE_TO_WIN,
	TEAM_CLOSE_TO_WIN_PERSONAL,
	_count
}
#endif // SERVER || CLIENT

#if SERVER
struct TreasureHuntObjective
{
	entity spawnLocation = null
	entity trigger = null
	entity waypoint = null
	entity model = null
	entity border = null
	entity pingTraceBlocker = null
	bool isActive = false
	string name = ""
	float lastCapturedTime = 0.0
	array<entity> playersInZone
	float objectiveEndTime = 0.0
}
#endif // SERVER

struct
{
	#if SERVER
		array< TreasureHuntObjective > allTreasureHuntObjectives
		array< TreasureHuntObjective > lastActiveObjective
		array < bool > isObjectiveIndexInUse // Array of bools, the index matches the objective index the bool is true if the objective is in use and false if it is available to use
		bool initialCaptureSpawnFinished = false
		bool hasTriggeredTeamHalfwayToWinMsg = false
		bool hasTriggeredTeamCloseToWinMsg = false

		array < entity > allPlayersOnObjectives // Keep track of all players that are on Objectives
		table < string, entity > borderTable
		int winningTeam = TEAM_INVALID

		#if DEVELOPER
			int forcedObjectiveIndex = INVALID_OBJ_INDEX_DEFAULT
		#endif // DEV
	#endif // SERVER

	#if CLIENT
		var captureZoneStatusRui
		var lockdownScoreHud
		var lockdownScoreboardHud
		array < entity > objectiveWaypoints // Objective Waypoints are inserted into this array at the index that matches their objective index
		array < var > objectiveWaypointRuis // Objective Waypoint Ruis are inserted into this array at the index that matches their objective index
	#endif // CLIENT
}file

void function TreasureHunt_Init()
{
	TreasureHunt_RegisterNetworking()

#if SERVER || CLIENT
	PrecacheParticleSystem( CAPTURE_ZONE_INCOMING_VFX )
	PrecacheParticleSystem( CAPTURE_ZONE_START_VFX )
	PrecacheParticleSystem( CAPTURE_ZONE_END_VFX )
	PrecacheParticleSystem( CAPTURE_ZONE_REWARD_VFX )
	PrecacheParticleSystem( CAPTURE_ZONE_REWARD_WEAPON_TRAIL_VFX )
	TreasureHunt_RegisterTimedEvents()

	CaptureObjectivePing_AddCallback_SetGetCaptureObjectiveIDFromWaypointFunction( TreasureHunt_GetObjectiveIDFromWaypoint )
	CaptureObjectivePing_AddCallback_SetIsCaptureObjectivePingObjectiveWaypoint( GetIsWaypointTreasureHuntObjectiveWaypoint )
#endif

	#if SERVER
		Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Directional )

		// Callbacks
		AddSpawnCallbackEditorClass( "script_ref", "info_freedm_map_location", TreasureHunt_OnMapNodeSpawned )
		AddSpawnCallback( "func_brush", TreasureHunt_OnEditorBorderCreated )
		AddCallback_Score_OnPlayerKilled( GAMEMODE_FREEDM, OnPlayerKilled )
		AddCallback_GameStateEnter( eGameState.Playing, TreasureHunt_OnGameStatePlaying )
		AddCallback_OnPlayerPostRespawned( TreasureHunt_OnPlayerPostRespawned )
		FreeDM_SetCallback_ArmorRefOverride( TreasureHunt_GiveJoinInProgressPlayerSpawnBonus )

		// Set all Objective Indexes to Inactive ( these are used to determine how many objectives are active and also which names to use for objectives )
		for ( int index = 0; index < GetMaxActiveObjectiveCount(); index++ )
		{
			file.isObjectiveIndexInUse.append( false )
		}

		// FreeDM Overrides
		FreeDM_SetGameplayMusicFunction( TreasureHunt_GetRampUpMusicControllerValueFromScore )
		FreeDM_SetGameplayMusicStartKillsLeft( TreasureHunt_GetRampUpMusicStartScoreValue() )
		int scoreLimit = GetScoreLimit_FromPlaylist()
		FreeDM_SetVOEndScoreDelta( scoreLimit - int( scoreLimit * MATCH_END_SCORE_PERCENT_THRESHOLD ) )

		// Loot
		AbilityCarePackage_SetContentOverrideCallback( TreasureHunt_OverrideAbilityCarePackage )

		// Register signals
		RegisterSignal( "TreasureHunt_ObjectiveCompleted" )

		#if DEVELOPER
			RegisterSignal( "TreasureHunt_StopTriggeringObjectives" )
		#endif // DEV
	#endif // SERVER

	#if CLIENT
		file.objectiveWaypoints.resize( GetMaxActiveObjectiveCount(), null )
		file.objectiveWaypointRuis.resize( GetMaxActiveObjectiveCount(), null )
		CaptureObjectivePing_AddCallback_SetIsCaptureObjectivePingCommsActionFunction( TreasureHunt_IsTreasureHuntObjectiveCommsAction )
		CaptureObjectivePing_AddCallback_SetGetObjectivesArrayFunction( TreasureHunt_GetObjectiveWaypointsArray )
		CaptureObjectivePing_AddCallback_OnObjectivePingCoundChanged( TreasureHunt_OnObjectiveWaypointPinged )
		FreeDM_SetDisplayScoreThread( TreasureHunt_DisplaySquadScore_Thread )
		FreeDM_SetScoreboardSetupFunc( TreasureHunt_ScoreboardSetup() )
		TreasureHunt_CreateCaptureZoneStatusRui()
		AddClientCallback_OnResolutionChanged( TreasureHunt_OnResolutionChanged )
	#endif

	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Victory_Sound, LOCKDOWN_VICTORY_SOUND )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Defeat_Sound, LOCKDOWN_LOSS_SOUND )
}

void function TreasureHunt_RegisterNetworking()
{
	int pingCountMax = GetExpectedSquadSize() + 1
	Remote_RegisterClientFunction( "ServerCallback_TreasureHunt_DisplayMessageToClient", "int", 0, eTreasureHuntMessageIndex._count, "int", 0, GetScoreLimit_FromPlaylist() + 1 )
	RegisterNetworkedVariable( "treasureHunt_PlayerTimeOnObjectives", SNDC_PLAYER_GLOBAL, SNVT_TIME, 0.0 )
	RegisterNetworkedVariable( "treasureHunt_OccupiedObjectiveID", SNDC_PLAYER_GLOBAL, SNVT_INT, INVALID_OBJ_INDEX_DEFAULT )

	#if CLIENT
		RegisterNetVarIntChangeCallback ( "treasureHunt_OccupiedObjectiveID", OnTreasureHuntOccupiedObjectiveIDChanged_Client )
	#endif

	#if SERVER || CLIENT
                    
                                                             
                                                                                                                                 
                                                                                                                                
                         
	#endif
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PLAYLIST VAR GET FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER || CLIENT
float function GetTreasureHuntZoneHoldTime()
{
                   
                                                                                          
                                 
                            
                         

	return GetCurrentPlaylistVarFloat( "treasure_hunt_zone_hold_time", 20)
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
float function GetCaptureObjectiveSpawnDelayTime()
{
                   
                                                                                         
                                 
                            
                         

	return CAPTURE_OBJ_INCOMING_DURATION
}
#endif // SERVER || CLIENT

#if SERVER
float function GetObjectiveRepeatCooldown()
{
	return GetCurrentPlaylistVarFloat( "treasure_hunt_spawn_repeat_cooldown", 30)
}
#endif // SERVER

#if SERVER
// ToDo: DSwieczko - This is weird, seems like it should be a const or affected by some variable, investigate when have some time
string function GetTreasureBoxLocationEntityName()
{
	return GetCurrentPlaylistVarString( "treasure_hunt_chest_entity_name", "info_treasurehunt_box_location" )
}
#endif // SERVER

#if SERVER || CLIENT
// Get the max number of objectives that can be active at once
// This value is defined in playlists but is limited by the number of objective names we have defined in CaptureObjectivePing_GetObjectiveNameStringsArray which is used to populate file.isObjectiveIndexInUse array
int function GetMaxActiveObjectiveCount()
{
	int nameCount = CaptureObjectivePing_GetObjectiveNameStringsArray().len()
	int playlistDefinedCount = GetCurrentPlaylistVarInt( "treasure_hunt_max_spawn_count", nameCount)

	Assert( playlistDefinedCount <= nameCount, "LOCKDOWN:  treasure_hunt_max_spawn_count playlist var tried to set the max number of active objectives to: " + playlistDefinedCount + " which is higher than the max number of objective names: " + nameCount + " the max will be set to " + nameCount )

	return minint( playlistDefinedCount, nameCount )
}
#endif // SERVER || CLIENT

#if SERVER
// Get the max number of objectives that can be active at once in the early stages of the match
int function GetMaxActiveObjectiveCount_EarlyGame()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_max_spawn_count_earlygame", 1 )
}
#endif // SERVER

#if SERVER
// Get the max number of objectives that can be active at once in the mid stages of the match
int function GetMaxActiveObjectiveCount_MidGame()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_max_spawn_count_midgame", 1 )
}
#endif // SERVER

#if SERVER
// Get the max number of objectives that can be active at once in the late stages of the match
int function GetMaxActiveObjectiveCount_LateGame()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_max_spawn_count_lategame", 1 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForCaptureObjectiveCaptured()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_obj_captured_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForSuddenDeathCaptureObjectiveCaptured()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_suddendeath_obj_captured_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForCaptureObjectiveCapturing()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_obj_capturing_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
float function GetScoringIntervalForObjectiveCapturing()
{
	return GetCurrentPlaylistVarFloat( "treasure_hunt_capturing_score_interval", 5.0 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForCaptureObjectiveCaptureInitiated()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_obj_capturestart_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForKill()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_kill_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForKillFromZone()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_kill_from_zone_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
int function GetScoreToAwardForKillWinner()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_kill_winner_score_amnt", 0 )
}
#endif // SERVER

#if SERVER
bool function GetShouldHealScoringPlayersOnCaptureComplete()
{
	return GetCurrentPlaylistVarBool( "treasure_hunt_should_heal_on_capture", false )
}
#endif // SERVER

#if SERVER
int function GetMinorCatchupMechanicScoreThreshold()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_minor_catchup_threshold", 0 )
}
#endif // SERVER

#if SERVER
int function GetMajorCatchupMechanicScoreThreshold()
{
	return GetCurrentPlaylistVarInt( "treasure_hunt_major_catchup_threshold", 0 )
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EARLY GAMESTATE CALLBACKS AND VAR SETTING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
void function TreasureHunt_OnMapNodeSpawned( entity mapNode )
{
	string boxEntityName = GetTreasureBoxLocationEntityName()
	foreach( childNode in mapNode.GetLinkEntArray() )
	{
		if ( GetEditorClass( childNode ) == "trigger_lockdown_objective" )
			TreasureHunt_CreateObjective( childNode, childNode )
	}
}
#endif // SERVER

#if SERVER
void function TreasureHunt_OnEditorBorderCreated( entity funcBrush )
{
	if ( funcBrush.GetScriptName() == "func_brush_lockdown_border" && funcBrush.HasKey( "script_noteworthy" ) )
	{
		string name = funcBrush.GetValueForKey( "script_noteworthy" )
		Assert( !(name in file.borderTable) , "func_brush_lockdown_border has same script_noteworthy: " + name )
		if ( name != "" )
			file.borderTable[name] <- funcBrush
		funcBrush.Hide()
	}
}
#endif // SERVER

#if SERVER
void function TreasureHunt_CreateObjective( entity node, entity trigger )
{
	TreasureHuntObjective newSpawn
	newSpawn.spawnLocation = node

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
	trigger.SetEnterCallback( OnCaptureZoneEnter )
	trigger.SetLeaveCallback( OnCaptureZoneExit )

	newSpawn.trigger = trigger
	file.allTreasureHuntObjectives.append( newSpawn )

	entity treasurePlatform = CreatePropScript( PLATFORM_MODEL, node.GetOrigin(), node.GetAngles(), SOLID_VPHYSICS )
	treasurePlatform.SetTouchTriggers( true ) //Make it destroyable by triggers e.g. Leviathan stomp
	treasurePlatform.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE )
	treasurePlatform.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it
	treasurePlatform.DisableHibernation()
	treasurePlatform.SetMaxHealth( 1000 )
	treasurePlatform.SetHealth( 1000 )
	treasurePlatform.SetCanBeMeleed( false )
	treasurePlatform.SetTakeDamageType( DAMAGE_NO )
	treasurePlatform.SetBlocksRadiusDamage( false )
	treasurePlatform.e.noFriendlyFireProtection = false
	treasurePlatform.e.canBurn                  = false
	treasurePlatform.e.canBeDamagedFromGas      = false
	newSpawn.model = treasurePlatform

	if ( trigger.HasKey( "script_noteworthy" ) )
		newSpawn.name = trigger.GetValueForKey( "script_noteworthy" )

	if ( newSpawn.name in file.borderTable )
		newSpawn.border = file.borderTable[newSpawn.name]

	array<entity> linkEnts = node.GetLinkEntArray()
	foreach( childNode in linkEnts )
	{
		if ( childNode.GetClassName() == "info_target" )
		{
			newSpawn.model.SetOrigin( childNode.GetOrigin() )
			newSpawn.model.SetAngles( childNode.GetAngles() )
		}
	}

	EnableObjective( newSpawn, false )
}
#endif // SERVER

#if SERVER
void function TreasureHunt_OnGameStatePlaying()
{
	TreasureHunt_SetAllPlayerOverheadTeamIconsVisible()
	thread TreasureHunt_ManageObjectiveSpawnSchedule_Thread()
}
#endif // SERVER

#if SERVER
void function TreasureHunt_OnPlayerPostRespawned( entity player )
{
	if ( GetGameState() != eGameState.Playing )
		return

	if ( !IsValid( player ) )
		return

	TreasureHunt_SetPlayerOverheadTeamIconsVisible( player )
}
#endif // SERVER

#if SERVER
void function TreasureHunt_SetPlayerOverheadTeamIconsVisible( entity player )
{
	if ( player.GetTeam() != TEAM_SPECTATOR )
	{
		GivePlayerSettingsMods( player, [ "targetinfo_ffa_squad" ] )
		player.SetNameVisibleToEnemy( true )
	}
}
#endif // SERVER

#if SERVER
void function TreasureHunt_SetAllPlayerOverheadTeamIconsVisible()
{
	foreach ( player in GetPlayerArray_Alive() )
	{
		if ( player.GetTeam() != TEAM_SPECTATOR )
		{
			TreasureHunt_SetPlayerOverheadTeamIconsVisible( player )
		}
	}
}
#endif // SERVER


#if SERVER
// Give players that join a match in progress better equipment for their first spawn
void function TreasureHunt_GiveJoinInProgressPlayerSpawnBonus( entity player, string currentShieldRef )
{
	if ( !IsValid( player ) )
		return

	// If this is a Late Join Players first spawn give them better equipment
	if ( GamemodeUtility_IsJIPPlayerSpawnBonusPending( player ) )
	{
		array<string> lateJoinEquipment = ParseEquipmentLoadoutText( LATEJOIN_EQUIPMENT_LOADOUT, false, [] )
		CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, lateJoinEquipment )
	}
}
#endif // SERVER



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SUPPORTING GET FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
// Get the number of objectives that are currently active
int function GetCurrentActiveObjectivesCount()
{
	int currentActiveObjectives = 0

	for ( int index = 0; index < file.isObjectiveIndexInUse.len(); index++ )
	{
		if ( file.isObjectiveIndexInUse[index] )
			currentActiveObjectives++
	}

	return currentActiveObjectives
}
#endif // SERVER

#if SERVER
// Pick an objective based on distance from other objectives and whether it has been used before
const float DISTANCE_MODIFIER_FOR_UNUSED_OBJECTIVES_SQR = 8718732.56 // 75m in units, square root, If an objective hasn't been used before, give it an advantage in being picked. But we would still rather have an objective that is further than one that is newer
TreasureHuntObjective function GetAvailableObjectiveSpawn()
{
	TreasureHuntObjective bestObjective
	array < TreasureHuntObjective > objectivesToTest
	array < TreasureHuntObjective > objectivesToTestAgainst

	// Add the objective that was active last to the list of objectives we want to test against since we want to trigger the next objective away from it
	if ( file.lastActiveObjective.len() > 0 && !file.lastActiveObjective[ 0 ].isActive)
		objectivesToTestAgainst.append( file.lastActiveObjective[ 0 ] )

	// We will test distances against all active objectives
	foreach( objective in file.allTreasureHuntObjectives )
	{
		// If the Objective is active, add it to the list of objectives we will test against
		if ( objective.isActive )
			objectivesToTestAgainst.append( objective )
		else if ( IsObjectiveAvailableToSpawn( objective, false ) && ( file.lastActiveObjective.len() == 0 || objective != file.lastActiveObjective[ 0 ] ) ) // If the objective wasn't the last active objective and is available, add it to the list of objectives we will consider
			objectivesToTest.append( objective )
	}

	// If we have no valid objectives to get, return an invalid objective
	if ( objectivesToTest.len() == 0 )
		return bestObjective

	// If we only have 1 objective available, use it
	if ( objectivesToTest.len() == 1 )
		return objectivesToTest[ 0 ]

	// If there are no active objectives to test against, pick the objective based on whether it was ever active or not
	if ( objectivesToTestAgainst.len() == 0 )
	{
		foreach( objective in objectivesToTest )
		{
			if ( objective.lastCapturedTime <= 0.0 )
			{
				bestObjective = objective
				break
			}
		}
	}
	else // Test the available objectives to see which one is the farthest from active objectives
	{
		float furthestSqr = -1.0
		float testDistSqr
		foreach( objective in objectivesToTest )
		{
			// First figure out the closest this objective is to any active objective
			float closestDistToActiveObjectiveSqr = -1
			vector objectiveLocation = objective.spawnLocation.GetOrigin()
			foreach ( activeObjective in objectivesToTestAgainst )
			{
				testDistSqr = Distance2DSqr( objectiveLocation, activeObjective.spawnLocation.GetOrigin() )
				if ( closestDistToActiveObjectiveSqr < 0 || testDistSqr < closestDistToActiveObjectiveSqr )
					closestDistToActiveObjectiveSqr = testDistSqr
			}

			// If this objective wasn't selected before, give it an advantage modifier to the distance
			if ( objective.lastCapturedTime <= 0.0 )
				closestDistToActiveObjectiveSqr += DISTANCE_MODIFIER_FOR_UNUSED_OBJECTIVES_SQR

			// If the closest distance between this objective and any active objective is farther than the current farthest, choose this as the best objective
			if ( furthestSqr < 0 || closestDistToActiveObjectiveSqr > furthestSqr )
			{
				furthestSqr = closestDistToActiveObjectiveSqr
				bestObjective = objective
			}
		}
	}

	// If we didn't find a good objective through other sorting methods, just choose a random available objective
	if ( !IsValid( bestObjective.spawnLocation ) )
		bestObjective = objectivesToTest.getrandom()

	return bestObjective
}
#endif // SERVER

#if SERVER
// Pick the first objective location that should trigger on match start
TreasureHuntObjective function GetRandomFirstObjectiveSpawn()
{
	int currentSpawnCount = 0
	array<TreasureHuntObjective> startObjectives
	foreach ( spawn in file.allTreasureHuntObjectives )
	{
		entity testTrigger = spawn.trigger
		if ( testTrigger.HasKey( "startingTreasureSpawn" ) && IsObjectiveAvailableToSpawn( spawn, false ) )
		{
			if ( bool( int( testTrigger.kv.startingTreasureSpawn ) ) )
				startObjectives.append(spawn)
		}
	}

	// If no start objectives were defined, just grab the best available objective
	if ( startObjectives.len() == 0 )
		return GetAvailableObjectiveSpawn()

	return startObjectives.getrandom()
}
#endif // SERVER

#if SERVER
// Get an objective near a player on the passed in team
TreasureHuntObjective function GetAvailableObjectiveNearTeam( int team )
{
	entity playerToSpawnNear
	TreasureHuntObjective objective
	array< entity > livingTeamPlayersArray = GetPlayerArrayOfTeam_Alive( team )

	if ( livingTeamPlayersArray.len() == 1 )
	{
		playerToSpawnNear = livingTeamPlayersArray[ 0 ]
	}
	else
	{
		// For now just base the best player off of the player with the highest health
		int highestHealthTotal = 0

		foreach ( teamPlayer in livingTeamPlayersArray )
		{
			int currentHealthTotal = teamPlayer.GetHealth() + teamPlayer.GetShieldHealth()
			int maxHealthTotal = teamPlayer.GetMaxHealth() + teamPlayer.GetShieldHealthMax()

			// If this player has full health, use them
			if ( currentHealthTotal >= maxHealthTotal )
			{
				playerToSpawnNear = teamPlayer
				break
			}
			else if ( currentHealthTotal > highestHealthTotal )
			{
				highestHealthTotal = currentHealthTotal
				playerToSpawnNear = teamPlayer
			}
		}
	}

	int closestObjectiveIndex = TreasureHunt_GetObjectiveToTriggerNearPlayer( playerToSpawnNear, false )
	// Make sure we got a valid objective, otherwise just grab a random one
	if ( closestObjectiveIndex < file.allTreasureHuntObjectives.len() && TreasureHunt_IsValidObjectiveIndex( closestObjectiveIndex ) )
		objective = file.allTreasureHuntObjectives[ closestObjectiveIndex ]
	else
		objective = GetAvailableObjectiveSpawn()

	return objective
}
#endif // SERVER

#if SERVER
// Stop objectives from triggering through normal logic and instead trigger the objective closest to you
int function TreasureHunt_GetObjectiveToTriggerNearPlayer( entity player, bool shouldIgnoreLastActiveTime )
{
	int closestObjectiveIndex = INVALID_OBJ_INDEX_DEFAULT
	if ( IsValid( player ) )
	{
		float closestSqr = -1.0
		float testDistSqr
		vector playerPos = player.GetOrigin()

		for ( int index = 0; index < file.allTreasureHuntObjectives.len(); index++ )
		{
			TreasureHuntObjective objective = file.allTreasureHuntObjectives[ index ]
			if ( IsObjectiveAvailableToSpawn( objective, shouldIgnoreLastActiveTime ) )
			{
				testDistSqr = Distance2DSqr( playerPos, objective.spawnLocation.GetOrigin() )
				if ( closestSqr < 0 || testDistSqr < closestSqr )
				{
					closestSqr = testDistSqr
					closestObjectiveIndex = index
				}
			}
		}
	}

	return closestObjectiveIndex
}
#endif // SERVER

#if SERVER
// Return whether the objective we wish to spawn passes the checks for an objective that is available to spawn ( isn't already active, hasn't been active within the cooldown time )
bool function IsObjectiveAvailableToSpawn( TreasureHuntObjective objective, bool shouldIgnoreRepeatCooldown )
{
	bool isObjectiveAvailable = false

	if ( !objective.isActive )
	{
		if ( shouldIgnoreRepeatCooldown || objective.lastCapturedTime <= 0.0 || Time() - objective.lastCapturedTime > GetObjectiveRepeatCooldown() )
			isObjectiveAvailable = true
	}

	return isObjectiveAvailable
}
#endif // SERVER

#if SERVER
TreasureHuntObjective function GetTreasureHuntObjectiveStructByTrigger( entity trigger )
{
	foreach ( objective in file.allTreasureHuntObjectives )
	{
		if ( objective.trigger == trigger)
			return objective
	}

	Assert( false, "LOCKDOWN: " + FUNC_NAME() + " didn't find a TreasureHuntObjective struct that matches the passed in trigger: " + trigger)
	TreasureHuntObjective nullBox
	return nullBox
}
#endif // SERVER

#if SERVER
TreasureHuntObjective function GetTreasureHuntObjectiveStructByWaypoint( entity waypoint )
{
	foreach ( objective in file.allTreasureHuntObjectives )
	{
		if ( objective.waypoint == waypoint)
			return objective
	}

	Assert( false, "LOCKDOWN: " + FUNC_NAME() + " didn't find a TreasureHuntObjective struct that matches the passed in waypoint: " + waypoint)
	TreasureHuntObjective nullBox
	return nullBox
}
#endif // SERVER

#if SERVER
// Control the pacing of the match by having 1 Objective active at a time at the start and finish and a bunch active in the middle
int function GetMatchScoringPhase()
{
	float maxScore = float( GetScoreLimit_FromPlaylist() )
	float currentHighestScore = float( GamemodeUtility_GetWinningTeamOrAllianceScore() )
	int matchScoringPhase

	if ( currentHighestScore <= 0 )
	{
		matchScoringPhase = eTreasureHuntMatchScoringPhase.EARLY
	}
	else
	{
		float matchPercentage = currentHighestScore/maxScore

		if ( matchPercentage <= MATCH_START_SCORE_PERCENT_THRESHOLD )
			matchScoringPhase = eTreasureHuntMatchScoringPhase.EARLY
		else if ( matchPercentage <= MATCH_END_SCORE_PERCENT_THRESHOLD )
			matchScoringPhase = eTreasureHuntMatchScoringPhase.MID
		else
			matchScoringPhase = eTreasureHuntMatchScoringPhase.LATE
	}

	return matchScoringPhase
}
#endif // SERVER

#if SERVER
// Get the max number of objectives that can be active at once during this phase of the match
// We set the pace of the match based on whether it is the start of the match, middle, or end
int function GetMaxActiveObjectiveCountForMatchScoringPhase()
{
	int absoluteMax = GetMaxActiveObjectiveCount()
	int matchPhase = GetMatchScoringPhase()
	int maxObjectivesForPhase = absoluteMax

	switch( matchPhase )
	{
		case eTreasureHuntMatchScoringPhase.EARLY:
			maxObjectivesForPhase = minint( GetMaxActiveObjectiveCount_EarlyGame(), absoluteMax )
			break
		case eTreasureHuntMatchScoringPhase.MID:
			maxObjectivesForPhase = minint( GetMaxActiveObjectiveCount_MidGame(), absoluteMax )
			break
		case eTreasureHuntMatchScoringPhase.LATE:
			maxObjectivesForPhase = minint( GetMaxActiveObjectiveCount_LateGame(), absoluteMax )
			break
		default:
			Assert( false, "LOCKDOWN: " + FUNC_NAME() + " tried to use an invalid match phase: " + matchPhase + " going to default to using the set max number of objectives")
			break
	}

	return maxObjectivesForPhase
}
#endif // SERVER

#if SERVER || CLIENT
// Is the waypoint a Treasure Hunt Objective Waypoint
bool function GetIsWaypointTreasureHuntObjectiveWaypoint( entity waypoint )
{
	return IsValid( waypoint ) && waypoint.GetNetworkedClassName() == PLAYER_WAYPOINT_CLASSNAME && waypoint.GetWaypointType() == eWaypoint.TREASUREHUNT_OBJECTIVE
}
#endif // SERVER

#if SERVER || CLIENT
// Is the objective index a valid index
bool function TreasureHunt_IsValidObjectiveIndex( int objectiveIndex )
{
	return objectiveIndex != INVALID_OBJ_INDEX_DEFAULT && objectiveIndex != INVALID_OBJ_INDEX_OBJ_COMPLETE
}
#endif // SERVER

#if SERVER
// Override the default function that grabs loot for lifeline care packages
// For this mode we base the players level on their current armor. If they have better armor than the default we will give them better gear
// Each slot in the carepackage is determined by each players level on the team
// If a team should have catchup mechanics applied to them we will just give them better loot here instead of basing it on their levels
const int DEFAULT_PLAYER_TIER = 1 // By default players should get the tier 1 airdrop
const int MINOR_CATCHUP_PLAYER_TIER = 2 // Treat the players as having a higher level when using catchup mechanics
const int MAJOR_CATCHUP_PLAYER_TIER = 3 // Treat the players as having a higher level when using catchup mechanics
const int AIRDROP_SLOT_COUNT = 3
const int MIN_AIRDROP_TIER = 1
const int MAX_AIRDROP_TIER = 3
const int ARMOR_TIER_TO_AIRDROP_TIER_DIFF = 1 // Player tier directly relates to the loot tier. The player armor by default is level 2, the first airdrop tier would be 1 that we give ( which has purple armor )
array< array<string> > function TreasureHunt_OverrideAbilityCarePackage( entity player )
{
	array<string> left
	array<string> right
	array<string> center

	if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_LOCKDOWN ) )
	{
		int team = player.GetTeam()
		int catchupLevel = TreasureHunt_GetTeamCatchupMechanicLevel( team )
		int defaultAirdropTier = DEFAULT_PLAYER_TIER
		array < int > airdropSlotTiers

		switch( catchupLevel )
		{
			case eTreasureHuntCatchupLevel.MAJOR:
				defaultAirdropTier = MAJOR_CATCHUP_PLAYER_TIER
				break
			case eTreasureHuntCatchupLevel.MINOR:
				defaultAirdropTier = MINOR_CATCHUP_PLAYER_TIER
				break
			case eTreasureHuntCatchupLevel.NONE:
			default:
				// Do nothing, default already defined
				break
		}

		array < entity > teamPlayersArray = GetPlayerArrayOfTeam_Alive( team )
		for ( int index = 0; index < AIRDROP_SLOT_COUNT; index++ )
		{
			// Try to base the airdrop slot on a player in the squad
			if ( teamPlayersArray.len() > index )
			{
				entity teamPlayer = teamPlayersArray[ index ]
				int playerLevel
				                    
					// If using Legend Upgrades, base the armor level on the player level, otherwise use the armor tier as normal
					if ( UpgradeCore_IsEnabled() )
					{
						playerLevel = UpgradeCore_GetPlayerArmorTier( teamPlayer )
					}
					else
          
					{
						string currentArmor = ArmorData_Get( player ).armorLevel
						// Use the armor level if the player has armor, otherwise set the level to 0
						if ( SURVIVAL_Loot_IsRefValid( currentArmor ) )
							playerLevel = SURVIVAL_Loot_GetLootDataByRef( currentArmor ).tier
						else
							playerLevel = 0
					}

				playerLevel -= ARMOR_TIER_TO_AIRDROP_TIER_DIFF
				playerLevel = playerLevel < defaultAirdropTier ? defaultAirdropTier : playerLevel
				playerLevel = int( clamp( playerLevel, MIN_AIRDROP_TIER, MAX_AIRDROP_TIER ) )
				airdropSlotTiers.append( playerLevel )
			}
			airdropSlotTiers.append( defaultAirdropTier )
		}

		left = ["treasurehunt_carepackage_slot_tier_" + airdropSlotTiers[ 0 ]]
		right = ["treasurehunt_carepackage_slot_tier_" + airdropSlotTiers[ 1 ]]
		center = ["treasurehunt_carepackage_slot_tier_" + airdropSlotTiers[ 2 ]]
	}
	else
	{
		left = ["treasurehunt_carepackage_slot_tier_1"]
		right = ["treasurehunt_carepackage_slot_tier_1"]
		center = ["treasurehunt_carepackage_slot_tier_1"]
	}

	return [ left, center, right ]
}
#endif // SERVER

#if SERVER
// Determine the catchup mechanic level for the passed in team
// We either have minor catchup mechanics or major based on how far behind the leading team this team is
int function TreasureHunt_GetTeamCatchupMechanicLevel( int team )
{
	int minorScoreThreshold = GetMinorCatchupMechanicScoreThreshold()
	int majorScoreThreshold = GetMajorCatchupMechanicScoreThreshold()
	int scoreDifference = GamemodeUtility_GetWinningTeamOrAllianceScore() - GamemodeUtility_GetTeamOrAllianceScore( team )
	int catchupLevel = eTreasureHuntCatchupLevel.NONE

	if ( majorScoreThreshold > 0 && scoreDifference > majorScoreThreshold )
		catchupLevel = eTreasureHuntCatchupLevel.MAJOR
	else if ( minorScoreThreshold > 0 && scoreDifference > minorScoreThreshold )
		catchupLevel = eTreasureHuntCatchupLevel.MINOR

	return catchupLevel
}
#endif // SERVER

#if SERVER
// Get an array of teams at the defined catchup mechanic level
array< int > function TreasureHunt_GetTeamsAtCatchupLevel( int catchupLevel, bool shouldOnlyAddTeamsWithLivingPlayers )
{
	array < int > teamsAtCatchupLevel

	for ( int teamIndex = TEAM_IMC; teamIndex < TEAM_IMC + MAX_SUPPORTED_TEAMS; teamIndex++ )
	{
		if ( TreasureHunt_GetTeamCatchupMechanicLevel( teamIndex ) == catchupLevel )
		{
			if ( shouldOnlyAddTeamsWithLivingPlayers && GetPlayerArrayOfTeam_Alive( teamIndex ).len() > 0 )
				teamsAtCatchupLevel.append( teamIndex )
			else if ( !shouldOnlyAddTeamsWithLivingPlayers )
				teamsAtCatchupLevel.append( teamIndex )
		}
	}

	return teamsAtCatchupLevel
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MANAGE OBJECTIVES
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
// Manage when objectives spawn
const float POST_OBJECTIVE_SPAWN_DELAY = 0.1
void function TreasureHunt_ManageObjectiveSpawnSchedule_Thread()
{
	Assert( IsNewThread(), "Must be threaded off" )

	#if DEVELOPER
		EndSignal( svGlobal.levelEnt, "TreasureHunt_StopTriggeringObjectives" )
	#endif // DEV

	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	float objectiveDuration = GetTreasureHuntZoneHoldTime()
	int maxObjectivesForMatchPhase
	TimedEvents_TriggerTimedEventByEventType( eTreasureHuntTimedEventType.CAPTURE )
	while ( GetGameState() == eGameState.Playing )
	{
		maxObjectivesForMatchPhase = GetMaxActiveObjectiveCountForMatchScoringPhase()

		// By default we will spawn a new objective part way through the lifetime of the old objective
		float nextObjectiveSpawnDelay = CAPTURE_OBJ_INCOMING_DURATION + ( objectiveDuration / maxObjectivesForMatchPhase ) - POST_OBJECTIVE_SPAWN_DELAY

		// If we are spawning only one objective at a time, we will instead wait for an objective to finish
		bool shouldWaitForObjectiveComplete = maxObjectivesForMatchPhase == 1

		// Check if there are any objectives that will finish sooner than the default wait time. If that is the case, wait for the objective instead of the time
		if ( !shouldWaitForObjectiveComplete )
		{
			foreach ( objective in file.allTreasureHuntObjectives )
			{
				if ( objective.isActive )
				{
					float timeToObjectiveEnd = objective.objectiveEndTime - Time()
					if ( timeToObjectiveEnd >= 0.0 && timeToObjectiveEnd < nextObjectiveSpawnDelay )
					{
						shouldWaitForObjectiveComplete = true
						break
					}
				}
			}
		}

		if ( shouldWaitForObjectiveComplete )
			WaitSignal( svGlobal.levelEnt, "TreasureHunt_ObjectiveCompleted" )
		else
			wait nextObjectiveSpawnDelay

		TimedEvents_TriggerTimedEventByEventType( eTreasureHuntTimedEventType.CAPTURE )
		wait POST_OBJECTIVE_SPAWN_DELAY // Wait a little bit to ensure old objective vars get cleaned up nicely and new objective vars get set
	}
}
#endif // SERVER

#if SERVER || CLIENT
//Register timed events that are enabled so they can trigger at different time intervals
// NOTE: the repeat interval is based off of the event start time, not its end time
// Example: An Event that has a startTimeDelay of 60, repeatInterval of 120, eventLength 60 would trigger 1 min into the match, last for 1 min, and trigger again 1 min later
// Events on a single schedule ignore the startTimeDelay and repeatInterval set on the event itself, they abide by the settings on the function TimedEvents_SetSingleScheduleVars
// Events set to be on the single schedule trigger in the order they are registered.
void function TreasureHunt_RegisterTimedEvents()
{
	TimedEventData objectiveData
	objectiveData.eventType = eTreasureHuntTimedEventType.CAPTURE
	objectiveData.shouldShowPreamble = false
	#if SERVER
		objectiveData.isTriggeredByFunctionCall = true
		objectiveData.isRepeatingEvent = false
		objectiveData.shouldDestroyWPOnEventEnd = true
		objectiveData.timedEventFunctionThread = TreasureHunt_StartNewObjectiveTimedEvent_Thread
		objectiveData.startTimeDelay = 10.0
		objectiveData.repeatInterval = 0.0
		objectiveData.eventLength = 10.0
		objectiveData.timedEventFunctionStartValidation = TreasureHunt_SpawnObjectiveValidation
		objectiveData.shouldCancelOtherTimedEvents = false
	#endif

	#if CLIENT
		objectiveData.colorOverride = COLOR_WHITE
		objectiveData.eventName = "#EVENT_AIRDROP_NAME"
		objectiveData.eventDesc = "#EVENT_AIRDROP_DESC"
	#endif

	TimedEvents_RegisterTimedEvent( objectiveData )
}
#endif // SERVER || CLIENT

#if SERVER
// Determine if a new objective can spawn right now
bool function TreasureHunt_SpawnObjectiveValidation( float eventLength )
{
	Assert( file.allTreasureHuntObjectives.len() > 0, "LOCKDOWN: Tried to spawn an Objective but we have no Objective Nodes spawned for this Level" )

	if ( file.allTreasureHuntObjectives.len() == 0 )
		return false

	#if DEVELOPER
		if ( TreasureHunt_IsValidObjectiveIndex( file.forcedObjectiveIndex ) && GetCurrentActiveObjectivesCount() < GetMaxActiveObjectiveCount() )
			return true
	#endif // DEV

	// For now Allow spawning as long as we haven't hit the max number of active objectives. We might add more validations as the mode grows
	return GetCurrentActiveObjectivesCount() < GetMaxActiveObjectiveCountForMatchScoringPhase()
}
#endif // SERVER

#if SERVER
// Manage the spawning of an objective
void function TreasureHunt_StartNewObjectiveTimedEvent_Thread( TimedEventData data, entity eventWP )
{
	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	Assert( IsNewThread(), "Must be threaded off" )

	float startTime = Time()
	int objectiveIndex = INVALID_OBJ_INDEX_DEFAULT

	for ( int index = 0; index < file.isObjectiveIndexInUse.len(); index++ )
	{
		if ( !file.isObjectiveIndexInUse[index] )
		{
			objectiveIndex = index
			break
		}
	}

	Assert( TreasureHunt_IsValidObjectiveIndex( objectiveIndex ), "LOCKDOWN: " + FUNC_NAME() + " Tried to Spawn a New Objective but there is no Available Objective Index, This should have been caught by the tiumed event start validation function" )
	if ( !TreasureHunt_IsValidObjectiveIndex( objectiveIndex ) )
		return

	TreasureHuntObjective newSpawn
	if ( !file.initialCaptureSpawnFinished )
	{
		newSpawn = GetRandomFirstObjectiveSpawn()
		file.initialCaptureSpawnFinished = true
	}
	else
	{
		array < int > teamsAtMajorCatchupLevel = TreasureHunt_GetTeamsAtCatchupLevel( eTreasureHuntCatchupLevel.MAJOR, true )
		// Base the position of the objective at the position of a team in need of help
		if ( teamsAtMajorCatchupLevel.len() > 0 )
		{
			int teamToSpawnObjectiveNear
			// If there is only 1 team to choose from, use it
			if ( teamsAtMajorCatchupLevel.len() == 1 )
			{
				teamToSpawnObjectiveNear = teamsAtMajorCatchupLevel[ 0 ]
			}
			else // Figure out which team we should base the spawn around
			{
				// Pick the team with the lowest score
				int lowestScore = GetScoreLimit_FromPlaylist()
				int currentTeamScore

				foreach ( teamToTest in teamsAtMajorCatchupLevel )
				{
					currentTeamScore = GamemodeUtility_GetTeamOrAllianceScore( teamToTest )

					if ( currentTeamScore < lowestScore )
					{
						lowestScore = currentTeamScore
						teamToSpawnObjectiveNear = teamToTest
					}
				}
			}

			newSpawn = GetAvailableObjectiveNearTeam( teamToSpawnObjectiveNear )
		}
		else // Pick a position based on distance from active objectives
		{
			newSpawn = GetAvailableObjectiveSpawn()
		}
	}

	if ( !IsValid( newSpawn.spawnLocation ) )
	{
		Assert( false, "LOCKDOWN: Tried to grab a new objective but there are no objectives available to spawn" )
		return
	}

	#if DEVELOPER
		if ( TreasureHunt_IsValidObjectiveIndex( file.forcedObjectiveIndex ) )
		{
			newSpawn = file.allTreasureHuntObjectives[ file.forcedObjectiveIndex ]
			file.forcedObjectiveIndex = INVALID_OBJ_INDEX_DEFAULT
		}
	#endif // DEV

	file.isObjectiveIndexInUse[ objectiveIndex ] = true

	// Display an incoming message
	thread TreasureHunt_DisplayMessageToAllPlayersAfterDelay_Thread( eTreasureHuntMessageIndex.CAPTURE_OBJECTIVE_INCOMING, 0, [] )

	// Spawn the objective after a delay
	thread TreasureHunt_SpawnNewCaptureObjective_Thread( newSpawn, objectiveIndex )

	// ToDo: Dswieczko this seems like it might be wrong. Shouldn't the event duration drive everything and cleanup the objectives properly
	// ToDo: DSwieczko Investigate updating this all a bit, we are sort of using the timed event and sort of not, there is a decent chain of threads going here, would prefer 1 per event
	float timeSinceEventStart = Time() - startTime
	wait data.eventLength + timeSinceEventStart
}
#endif // SERVER

#if SERVER
const float OBJECTIVE_WAYPOINT_VERTICAL_OFFSET = 80.0
const vector TRACEBLOCKER_BOXMINS =  < -50, -50, 0>
const vector TRACEBLOCKER_BOXMAXS = < 50, 50, 55 >
void function TreasureHunt_SpawnNewCaptureObjective_Thread( TreasureHuntObjective objective, int objectiveIndex)
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity platform = objective.model

	if ( !IsValid( platform ) )
		return

	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	float objectiveIncomingTime = GetCaptureObjectiveSpawnDelayTime()
	objective.objectiveEndTime = Time() + objectiveIncomingTime + GetTreasureHuntZoneHoldTime()
	objective.isActive = true

	// Show Incoming VFX
	StartParticleEffectInWorld( GetParticleSystemIndex( CAPTURE_ZONE_INCOMING_VFX ), platform.GetOrigin(), <0,0,0> )

	// Start Incoming Loop SFX
	EmitSoundOnEntity( platform, CAPTURE_INCOMING_SFX_LOOP )
	PassByReferenceBool didSpawnObjective
	didSpawnObjective.value = false

	OnThreadEnd(
		function () : ( platform, objective, didSpawnObjective )
		{
			if ( IsValid( platform ) )
				StopSoundOnEntity( platform, CAPTURE_INCOMING_SFX_LOOP )

			// Make sure the zone gets cleaned up on match end if we didn't spawn the objective yet ( if we did it will get cleaned up in the manage zone function )
			if ( !didSpawnObjective.value )
				TreasureHunt_ObjectiveCompleted( objective.trigger, TEAM_INVALID, 0, eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED, [], true )
		}
	)

	entity wp = CreatePlayerWaypoint_Wrapper( eWaypoint.TREASUREHUNT_OBJECTIVE )
	float startingProgress = 1.0 // King of the Hill progress goes down as the point is drained of score
	wp.SetWaypointFloat( CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME, Time() )
	wp.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_INDEX, objectiveIndex )
	wp.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE, eTreasureHuntCaptureZoneState.INCOMING )
	wp.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER, TEAM_INVALID )
	wp.SetOrigin( platform.GetOrigin() + < 0, 0, OBJECTIVE_WAYPOINT_VERTICAL_OFFSET >)
	wp.SetOwner( objective.trigger )
	wp.SetParent( objective.model )
	objective.waypoint = wp

	// Set objective pings
	objective.pingTraceBlocker = CaptureObjectivePing_CreateObjectivePingTraceBlocker( wp, TRACEBLOCKER_BOXMINS, TRACEBLOCKER_BOXMAXS, TREASUREHUNT_OBJECTIVE_SCRIPTNAME, false )
	CaptureObjectivePing_CreateStarterPingsOnObjective( wp, objective.pingTraceBlocker, ePingType.PING_CAPTURE_OBJECTIVE_ATTACK )

	wait objectiveIncomingTime

	SpawnCaptureZone( objective )
	didSpawnObjective.value = true
}
#endif // SERVER

#if SERVER
// Award score for a completed objective ( if the team is valid )
// Cleanup the objective and return it to a default state so it can potentially be used again
const float LOOT_CIRCLE_RADIUS = 32.0
const float LOOT_SPAWN_VERTICAL_OFFSET = 12.0
const float LOOT_THROW_VELOCITY_MIN = 250.0
const float LOOT_THROW_VELOCITY_MAX = 350.0
void function TreasureHunt_ObjectiveCompleted( entity box, int team, int score, int scoringMessageIndex, array < entity > scoringPlayers, bool spawnLoot = false )
{
	if ( team != TEAM_INVALID )
		TreasureHunt_AwardScore( team, score, scoringMessageIndex, scoringPlayers, eTreasureHuntMessageDisplayType.TEAM_DEFINED_PLAYERS_COMBO )
	else
		spawnLoot = false // Only spawn loot if there was a valid capturing team

	TreasureHuntObjective objective = GetTreasureHuntObjectiveStructByTrigger( box )
	file.lastActiveObjective.clear()
	file.lastActiveObjective.append( objective )

	// Cleanup variables
	EnableObjective( objective, false )

	if ( IsValid( objective.pingTraceBlocker ) )
	{
		// Destroy the starter pings on this objective
		for ( int indexTeam = TEAM_IMC; indexTeam < TEAM_IMC + MAX_SUPPORTED_TEAMS; indexTeam++ )
		{
			entity objectiveStarterPing = TreasureHunt_GetStarterPingFromTraceBlockerPing( objective.pingTraceBlocker, indexTeam )
			CaptureObjectivePing_DestroyStarterPingOnObjective( objectiveStarterPing )
		}

		// Destroy the Traceblocker as well
		objective.pingTraceBlocker.Destroy()
	}
	objective.pingTraceBlocker = null

	if ( IsValid( objective.waypoint ) )
	{
		int objectiveNameIndex = objective.waypoint.GetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_INDEX )
		file.isObjectiveIndexInUse[objectiveNameIndex] = false
		objective.waypoint.Destroy()
	}
	objective.waypoint = null

	objective.lastCapturedTime = Time()

	// Clear out players that were in the Zone from the array of players on Zones
	foreach ( zonePlayer in objective.playersInZone )
	{
		file.allPlayersOnObjectives.fastremovebyvalue( zonePlayer )
	}
	// Clear out the array of players on the zone so when the zone respawns the array is empty
	objective.playersInZone = []

	if ( IsValid( objective.model ) )
	{
		// Play end VFX that trigger regardless of whether a capture was successful or not
		StartParticleEffectOnEntity( objective.model, GetParticleSystemIndex( CAPTURE_ZONE_END_VFX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

		// Play different sfx depending on if the zone got captured or if it is just despawning
		if ( team != TEAM_INVALID )
		{
			// Play reward VFX that trigger only if the objective was successful
			StartParticleEffectOnEntity( objective.model, GetParticleSystemIndex( CAPTURE_ZONE_REWARD_VFX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
			EmitSoundOnEntity( objective.model, CAPTURE_REWARD_SFX )
		}
		else
		{
			EmitSoundOnEntity( objective.model, CAPTURE_END_SFX )
		}

		if ( spawnLoot )
		{

			array<string> loot = GenerateRewardLootToSpawn( )
			vector platformLocation = objective.model.GetOrigin() + < 0, 0, LOOT_SPAWN_VERTICAL_OFFSET >
			vector boxUpVector = objective.model.GetUpVector()
			array< vector > lootSpawnLocations = GetPointsOnCircle( platformLocation, <0, 0, 0>, LOOT_CIRCLE_RADIUS, loot.len() )

			for ( int index = 0; index < loot.len(); index++ )
			{
				string item = loot[ index ]
				vector spawnLocation = index < lootSpawnLocations.len() ? lootSpawnLocations[ index ] : platformLocation

				ThrowLootParams params
				params.dropOrg               = spawnLocation
				params.fwd                   = boxUpVector
				params.ref                   = item
				params.count                 = 1
				params.throwVelocityRange[0] = LOOT_THROW_VELOCITY_MIN
				params.throwVelocityRange[1] = LOOT_THROW_VELOCITY_MAX

				entity weaponReward = SURVIVAL_ThrowLootFromPointEx( params )
				StartParticleEffectOnEntity( weaponReward, GetParticleSystemIndex( CAPTURE_ZONE_REWARD_WEAPON_TRAIL_VFX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
			}
		}
	}

	objective.isActive = false
	svGlobal.levelEnt.Signal( "TreasureHunt_ObjectiveCompleted" )
}
#endif // SERVER

#if SERVER
void function EnableObjective( TreasureHuntObjective objective, bool enable )
{
	if ( IsValid( objective.trigger ) )
	{
		if ( enable )
			objective.trigger.Enable()
		else
			objective.trigger.Disable()
	}

	if ( enable && objective.border == null && objective.name in file.borderTable )
		objective.border = file.borderTable[objective.name]

	if ( IsValid( objective.border ) )
	{
		if ( enable )
			objective.border.Show()
		else
			objective.border.Hide()
	}
}
#endif // SERVER

#if SERVER
// Determine what loot to spawn when an objective is completed
const string REWARD_LOOT_GROUPS = "crate_weapons_lategame control_ordnance control_gold_kitted_weapons control_ordnance control_gold_kitted_weapons control_ordnance"
array<string> function GenerateRewardLootToSpawn( )
{
	array<string> lootToSpawn
	array<string> lootTokenArray = split( REWARD_LOOT_GROUPS, WHITESPACE_CHARACTERS )

	array< array<string> > podContents = DetermineAirdropContents( [ [lootTokenArray[0]],  [lootTokenArray[1]],  [lootTokenArray[2]], [lootTokenArray[3]], [lootTokenArray[4]], [lootTokenArray[5]] ] )
	foreach( array<string> contents in podContents )
	{
		Assert( contents.len() == 1 )
		lootToSpawn.append( contents[0] )

	}
	return lootToSpawn
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SPECIFIC OBJECTIVE TYPE - CAPTURE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#if SERVER || CLIENT
const vector ZONE_NEUTRAL_COLOR = <230, 230, 230> //GREY
const vector ZONE_CONTESTED_COLOR = <247, 60, 82> //RED
const vector ZONE_SUDDENDEATH_COLOR = <247, 60, 82> //RED
#endif

#if SERVER
const int ZONE_DEFAULT_RADIUS = 400
const int ZONE_DEFAULT_HEIGHT = 200
void function SpawnCaptureZone( TreasureHuntObjective objective )
{
	if ( !IsValid( objective.spawnLocation ) )
	{
		Warning( "LOCKDOWN: Tried to spawn a new objective with ", FUNC_NAME(), " but the objective spawn location entity is not valid" )
		return
	}

	vector origin = objective.spawnLocation.GetOrigin()
	vector angles = objective.spawnLocation.GetAngles()

	// First clean up any old loot around the objective zone
	array<entity> loot = GetEntArrayByClass_Expensive( "prop_survival" )
	foreach ( item in loot )
	{
		if ( LengthSqr( item.GetOrigin() - origin) < LOOT_CLEANUP_SEARCH_DISTANCE)
			item.Destroy()
	}

	int zoneRadius = ZONE_DEFAULT_RADIUS
	if ( objective.spawnLocation.HasKey( "radius" ) )
		zoneRadius = int(objective.spawnLocation.kv.radius)

	EnableObjective( objective, true )
	SetCaptureBorderColorByState( objective.border, eTreasureHuntCaptureZoneState.INCOMING )

	if ( IsValid( objective.model ) )
	{
		StartParticleEffectOnEntity( objective.model, GetParticleSystemIndex( CAPTURE_ZONE_START_VFX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
		EmitSoundOnEntity( objective.model, CAPTURE_SPAWNED_SFX )
	}

	thread ManageZone_Thread( objective.trigger, objective)
}
#endif // SERVER

#if SERVER
void function ManageZone_Thread( entity zone, TreasureHuntObjective objective )
{
	if ( !IsValid( zone ) )
		return

	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	OnThreadEnd(
		function() : ( zone, objective )
		{
			// Make sure the zone gets cleaned up on match end
			if ( objective.isActive )
				TreasureHunt_ObjectiveCompleted( zone, TEAM_INVALID, 0, eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED, [], true )
		}
	)

	float zoneCaptureTime = GetTreasureHuntZoneHoldTime()
	if ( zoneCaptureTime <= 0.0 )
		return

	// Current dialogue is along the lines of "An Objective has Appeared" so it fits better here than during the incoming state
	// There is an overlap with a point ending and a new one incoming as well so this timing prevents that overlap
	// Also an overlap on Thunderdome with the welcome to Thunderdome dialogue and the first point appearing
	bool didPlayIncomingCommentary = false
	                         
		if ( !file.initialCaptureSpawnFinished && CrowdNoiseMeterEnabled() )
		{
			thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.TH_TD_FIRST_OBJECTIVE_INCOMING ) )
			didPlayIncomingCommentary = true
		}
                                

	if ( !didPlayIncomingCommentary )
		thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.TH_OBJECTIVE_INCOMING ) )

	// Set variables needed for managing this objective
	bool isFirstCaptureOnObjective = true
	PassByReferenceInt previousZoneState
	previousZoneState.value = eTreasureHuntCaptureZoneState.INCOMING
	int previousCapturingTeamOrAlliance = TEAM_INVALID
	float previousScoreAwardTime = Time()
	float scoringIntervals = GetScoringIntervalForObjectiveCapturing() // How long does a team need to own the zone to get points for capturing, after that, how long between scoring events
	int scoreToAwardForCapturing = GetScoreToAwardForCaptureObjectiveCapturing()
	bool isZoneTimeLimitReached = false
	entity platformModel = objective.model
	float accruedProgressTime = 0.0
	bool didZoneEnterSuddenDeath = false

	                         
		array< int > previousCapturingTeamsOrAlliances
                                

	// On Start switch to Neutral state
	previousZoneState.value = eTreasureHuntCaptureZoneState.NEUTRAL
	SetCaptureBorderColorByState( objective.border, eTreasureHuntCaptureZoneState.NEUTRAL )
	objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE, eTreasureHuntCaptureZoneState.NEUTRAL )
	objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER, TEAM_INVALID )
	// Set the start time again as we switch out of the incoming state
	float currentTime = Time()
	objective.waypoint.SetWaypointFloat( CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME, currentTime )

	while( GetGameState() == eGameState.Playing && objective.isActive )
	{
		wait DEFAULT_TREASURE_HUNT_ZONE_UPDATE_TIME_SECONDS

		if ( !IsValid( zone ) )
			break

		int capturingTeamOrAlliance = TEAM_INVALID
		// King of the Hill Style zones are time based so the progress on them drops and drops regardless of whether a team is holding the point or not
		accruedProgressTime += DEFAULT_TREASURE_HUNT_ZONE_UPDATE_TIME_SECONDS
		isZoneTimeLimitReached = accruedProgressTime >= zoneCaptureTime

		// Check what teams/alliances are capturing the zone
		bool isUsingAlliances = AllianceProximity_IsUsingAlliances()
		array< int > capturingTeamsOrAlliances
		foreach ( player in objective.playersInZone )
		{
			if ( !IsValid( player ) || !IsAlive( player ) )
			{
				objective.playersInZone.fastremovebyvalue( player )
				file.allPlayersOnObjectives.fastremovebyvalue( player )
				continue
			}

			int currentPlayerTeam = player.GetTeam()
			int currentPlayerTeamOrAlliance = isUsingAlliances ? AllianceProximity_GetAllianceFromTeam( currentPlayerTeam ) : currentPlayerTeam

			if ( !capturingTeamsOrAlliances.contains( currentPlayerTeamOrAlliance ) )
				capturingTeamsOrAlliances.append( currentPlayerTeamOrAlliance )

			// Track Time on Objective
			float playerTimeOnObjectives = player.GetPlayerNetTime( "treasureHunt_PlayerTimeOnObjectives" ) + DEFAULT_TREASURE_HUNT_ZONE_UPDATE_TIME_SECONDS
			player.SetPlayerNetTime( "treasureHunt_PlayerTimeOnObjectives", playerTimeOnObjectives )
		}

		// Check what state the zone is in
		if ( capturingTeamsOrAlliances.len() == 0 )
		{
			// zone is OPEN to capture
			if ( previousZoneState.value != eTreasureHuntCaptureZoneState.NEUTRAL )
			{
				previousZoneState.value = eTreasureHuntCaptureZoneState.NEUTRAL
				SetCaptureBorderColorByState( objective.border, eTreasureHuntCaptureZoneState.NEUTRAL )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE, eTreasureHuntCaptureZoneState.NEUTRAL )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER, TEAM_INVALID )

				                         
					previousCapturingTeamsOrAlliances.clear()
                                   
			}

			previousCapturingTeamOrAlliance = TEAM_INVALID
		}
		else if ( capturingTeamsOrAlliances.len() == 1 )
		{
			capturingTeamOrAlliance = capturingTeamsOrAlliances[ 0 ]

			// If this is the first team to start capturing award points for initiating a capture ( if we award score for that as defined by playlist vars )
			if ( isFirstCaptureOnObjective && capturingTeamOrAlliance != TEAM_INVALID )
			{
				TreasureHunt_AwardScore( capturingTeamOrAlliance, GetScoreToAwardForCaptureObjectiveCaptureInitiated(), eTreasureHuntMessageIndex.SCORE_CAPTURE_INITIATED, objective.playersInZone, eTreasureHuntMessageDisplayType.TEAM_DEFINED_PLAYERS_COMBO )
				isFirstCaptureOnObjective = false
			}

			// zone is in CAPTURING state
			if ( previousZoneState.value != eTreasureHuntCaptureZoneState.CAPTURING || capturingTeamOrAlliance != previousCapturingTeamOrAlliance )
			{
				previousZoneState.value = eTreasureHuntCaptureZoneState.CAPTURING
				SetCaptureBorderColorByState( objective.border, eTreasureHuntCaptureZoneState.CAPTURING, capturingTeamOrAlliance )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE, eTreasureHuntCaptureZoneState.CAPTURING )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER, capturingTeamOrAlliance )
			}

			// Make sure the capturing team has been on the point for a full capture duration cycle before awarding any points
			if ( capturingTeamOrAlliance == previousCapturingTeamOrAlliance )
			{
				if ( capturingTeamOrAlliance != TEAM_INVALID && Time() >= previousScoreAwardTime + scoringIntervals )
				{
					previousScoreAwardTime = Time()
					TreasureHunt_AwardScore( capturingTeamOrAlliance, scoreToAwardForCapturing, eTreasureHuntMessageIndex.SCORE_CAPTURING, objective.playersInZone, eTreasureHuntMessageDisplayType.DEFINED_PLAYERS )

					                         
						// penalize any team that was capturing and no longer is
						foreach ( int teamOrAlliance in previousCapturingTeamsOrAlliances )
						{
							if ( teamOrAlliance == capturingTeamOrAlliance )
								continue

							UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( teamOrAlliance, eCrowdNoiseMeterModifiers.TREASURE_HUNT_CAPTURING_ZONE_NEGATIVE )
						}

						// clear the list so that we do not penalize the teams more than once
						previousCapturingTeamsOrAlliances.clear()
						previousCapturingTeamsOrAlliances.append( capturingTeamOrAlliance )
                                    
				}
			}
			else // Don't award score but set variables, if this team is still the owner after the expected time, award score
			{
				previousCapturingTeamOrAlliance = capturingTeamOrAlliance
				previousScoreAwardTime = Time()
			}

			                         
				ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( capturingTeamOrAlliance, eCrowdNoiseMeterModifiers.TREASURE_HUNT_CAPTURING_ZONE_POSITIVE, DEFAULT_TREASURE_HUNT_ZONE_UPDATE_TIME_SECONDS )
                                  
		}
		else // zone is CONTESTED or in a Sudden Death state if it was meant to go away but is contested
		{
			if ( isZoneTimeLimitReached && previousZoneState.value != eTreasureHuntCaptureZoneState.SUDDEN_DEATH )
			{
				previousZoneState.value = eTreasureHuntCaptureZoneState.SUDDEN_DEATH
				SetCaptureBorderColorByState( objective.border, eTreasureHuntCaptureZoneState.SUDDEN_DEATH )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE, eTreasureHuntCaptureZoneState.SUDDEN_DEATH )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER, TEAM_INVALID )
				didZoneEnterSuddenDeath = true

				// Play a sound and display a message to the players on the point
				foreach ( zonePlayer in objective.playersInZone )
				{
					TreasureHunt_DisplayMessageToPlayer( zonePlayer, eTreasureHuntMessageIndex.OBJECTIVE_ENTERS_SUDDEN_DEATH, 0 )
				}
			}
			else if ( previousZoneState.value != eTreasureHuntCaptureZoneState.CONTESTED && previousZoneState.value != eTreasureHuntCaptureZoneState.SUDDEN_DEATH )
			{
				previousZoneState.value = eTreasureHuntCaptureZoneState.CONTESTED
				SetCaptureBorderColorByState( objective.border, eTreasureHuntCaptureZoneState.CONTESTED )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE, eTreasureHuntCaptureZoneState.CONTESTED )
				objective.waypoint.SetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER, TEAM_INVALID )

				foreach ( zonePlayer in objective.playersInZone )
				{
					TreasureHunt_DisplayMessageToPlayer( zonePlayer, eTreasureHuntMessageIndex.OBJECTIVE_ENTERS_CONTESTED_STATE, 0 )
				}
			}

			previousCapturingTeamOrAlliance = TEAM_INVALID

			                         
				foreach ( int currentTeamOrAlliance in capturingTeamsOrAlliances )
				{
					ScaledUpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( currentTeamOrAlliance, eCrowdNoiseMeterModifiers.TREASURE_HUNT_CONTESTING_ZONE_POSITIVE, DEFAULT_TREASURE_HUNT_ZONE_UPDATE_TIME_SECONDS )
				}

				// cache the capturing teams into the previous capturing teams
				previousCapturingTeamsOrAlliances = clone capturingTeamsOrAlliances
                                  
		}

		// zone is captured or has run out of time ( don't run this if Zone is in Sudden Death state, it waits until 1 team wins the fight )
		if ( isZoneTimeLimitReached && previousZoneState.value != eTreasureHuntCaptureZoneState.SUDDEN_DEATH )
		{
			// If we have a valid capture team at the time of the zone capture being complete or expiring, award score
			if ( capturingTeamOrAlliance != TEAM_INVALID )
			{
				                         
					UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( capturingTeamOrAlliance, eCrowdNoiseMeterModifiers.TREASURE_HUNT_CAPTURED_ZONE_POSITIVE )

					// penalize any team that was on sudden death and did not capture the zone
					foreach ( int teamOrAlliance in previousCapturingTeamsOrAlliances )
					{
						if ( teamOrAlliance == capturingTeamOrAlliance )
							continue

						UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( teamOrAlliance, eCrowdNoiseMeterModifiers.TREASURE_HUNT_CAPTURED_ZONE_NEGATIVE )
					}

					previousCapturingTeamsOrAlliances.clear()
                                   

				if ( GetShouldHealScoringPlayersOnCaptureComplete() )
				{
					foreach ( scoringPlayer in objective.playersInZone )
					{
						GamemodeUtility_HealPlayerHealthAndShieldsByPercentage( scoringPlayer, PERCENT_TO_HEAL_HEALTH_ON_CAPTURE, PERCENT_TO_HEAL_SHIELDS_ON_CAPTURE, false, true )
					}
				}

				thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.TH_OBJECTIVE_CAPTURED ) )

				// Award different score values for a sudden death capture vs a normal capture
				if ( didZoneEnterSuddenDeath )
					TreasureHunt_ObjectiveCompleted( zone, capturingTeamOrAlliance, GetScoreToAwardForSuddenDeathCaptureObjectiveCaptured(), eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH, objective.playersInZone, true )
				else
					TreasureHunt_ObjectiveCompleted( zone, capturingTeamOrAlliance, GetScoreToAwardForCaptureObjectiveCaptured(), eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED, objective.playersInZone, true )
			}
			else
			{
				// Either way, clean up the point ( the award capture logic will test for an invalid team and not award score if that is the case but still clean up the objective entity )
				TreasureHunt_ObjectiveCompleted( zone, capturingTeamOrAlliance, 0, eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED, [], true )
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Set the color of the capture objective border based on the current state of the objective
void function SetCaptureBorderColorByState( entity border, int zoneState, int capturingTeam = TEAM_INVALID )
{
	vector borderColor = ZONE_NEUTRAL_COLOR
	if ( IsValid( border ) && border.HasKey( "model" ) )
	{
		switch( zoneState )
		{
			case eTreasureHuntCaptureZoneState.INCOMING:
				borderColor = ZONE_NEUTRAL_COLOR
				break
			case eTreasureHuntCaptureZoneState.NEUTRAL:
				borderColor = ZONE_NEUTRAL_COLOR
				break
			case eTreasureHuntCaptureZoneState.CAPTURING:
				if ( capturingTeam != TEAM_INVALID )
					borderColor = TreasureHunt_GetTeamColor( capturingTeam )
				else
					Assert( false, "LOCKDOWN: " + FUNC_NAME() + " trying to set the border color for the capturing state but the capturing team is Invalid" )
				break
			case eTreasureHuntCaptureZoneState.CONTESTED:
				borderColor = ZONE_CONTESTED_COLOR
				break
			case eTreasureHuntCaptureZoneState.SUDDEN_DEATH:
				borderColor = ZONE_SUDDENDEATH_COLOR
				break
			default:
				Assert( false, "LOCKDOWN: " + FUNC_NAME() + " running on unsupported zoneState: " + zoneState )
				break
		}
		// border.SetRenderColor(borderColor.x, borderColor.y, borderColor.z)
	}
}
#endif // SERVER

#if SERVER
void function OnCaptureZoneEnter( entity zone, entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	TreasureHuntObjective objective = GetTreasureHuntObjectiveStructByTrigger(zone)
	objective.playersInZone.append(player)
	file.allPlayersOnObjectives.append( player )
	int objectiveIndex = objective.waypoint.GetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_INDEX )
	player.SetPlayerNetInt( "treasureHunt_OccupiedObjectiveID", objectiveIndex )
}
#endif // SERVER

#if SERVER
void function OnCaptureZoneExit( entity zone, entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	TreasureHuntObjective objective = GetTreasureHuntObjectiveStructByTrigger(zone)
	objective.playersInZone.fastremovebyvalue( player )
	file.allPlayersOnObjectives.fastremovebyvalue( player )

	// Set to a different invalid index depending on if the objective is still active or not
	if ( objective.isActive )
		player.SetPlayerNetInt( "treasureHunt_OccupiedObjectiveID", INVALID_OBJ_INDEX_DEFAULT )
	else
		player.SetPlayerNetInt( "treasureHunt_OccupiedObjectiveID", INVALID_OBJ_INDEX_OBJ_COMPLETE )
}
#endif // SERVER

#if CLIENT
// This triggers when any player enters or exits a Zone trigger. Use it to update player tracking on Zones and also to trigger on Zone Enter/ Exit SFX and logic
void function OnTreasureHuntOccupiedObjectiveIDChanged_Client( entity player, int newOccupiedObjectiveID )
{
	// Only run logic for the local player entering or exiting a trigger if this callback was for the local player
	if ( player == GetLocalClientPlayer() )
	{
		// Player entered a Zone
		if ( TreasureHunt_IsValidObjectiveIndex( newOccupiedObjectiveID ) )
		{
			TreasureHunt_PlayCaptureZoneEnterExitSFX( true )
		}
		else if( newOccupiedObjectiveID == INVALID_OBJ_INDEX_DEFAULT )// Player Exited a Zone
		{
			TreasureHunt_PlayCaptureZoneEnterExitSFX( false )
		}
		// Don't play a SFX if the index is INVALID_OBJ_INDEX_OBJ_COMPLETE, we don't want to play exit sfx while playing zone capture sfx or zone complete sfx
	}
}
#endif // CLIENT




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SCORING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	// Only applies to player vs player kills
	if ( !IsValidPlayer( attacker ) || !IsValidPlayer( victim ) )
		return

	int attackerTeam = attacker.GetTeam()
	int victimTeam =  victim.GetTeam()

	// Don't award for self kills or friendly kills
	if ( IsFriendlyTeam( attackerTeam, victimTeam ) )
		return

	// Determine if we award any score for the kill
	int scoreToAward = 0
	int messageIndex
	// ToDo: look into handling multiple teams in the lead
	if ( victimTeam == GamemodeUtility_GetWinningTeamOrAlliance( true ) && victimTeam != TEAM_INVALID) // For now if there are multiple teams in the lead don't award this
	{
		scoreToAward = GetScoreToAwardForKillWinner()
		messageIndex = eTreasureHuntMessageIndex.SCORE_KILL_WINNER
	}
	else if ( file.allPlayersOnObjectives.contains( attacker ) ) // Award more Score if the attacker was in a Zone when they got the kill
	{
		scoreToAward = GetScoreToAwardForKillFromZone()
		messageIndex = eTreasureHuntMessageIndex.SCORE_KILL_FROM_ZONE
	}
	else
	{
		scoreToAward = GetScoreToAwardForKill()
		messageIndex = eTreasureHuntMessageIndex.SCORE_KILL
	}

	// If we award score for players getting killed, award it now
	if ( scoreToAward > 0 )
	{
		int attackerTeamOrAlliance = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllianceFromTeam( attackerTeam ) : attackerTeam
		TreasureHunt_AwardScore( attackerTeamOrAlliance, scoreToAward, messageIndex, [ attacker ], eTreasureHuntMessageDisplayType.DEFINED_PLAYERS )
	}
}
#endif // SERVER

#if SERVER
// Award score
void function TreasureHunt_AwardScore( int teamOrAlliance, int score, int messageIndex, array < entity > scoringPlayers, int messageDisplayType )
{
	// Don't do anything if score wouldn't actually be added
	if ( teamOrAlliance == TEAM_INVALID || score <= 0 )
		return

	// Add score to team or alliance
	FreeDM_AddTeamScore( teamOrAlliance, score )

	// Award personal contribution score and display a personal message to the scoring players if that message display type was defined
	if ( scoringPlayers.len() > 0 )
	{
		foreach ( scoringPlayer in scoringPlayers )
		{
			if ( !IsValidPlayer( scoringPlayer ) )
				continue

			// If we display a specific message to the scoring players, display it here
			if ( messageDisplayType != eTreasureHuntMessageDisplayType.TEAM )
				TreasureHunt_DisplayMessageToPlayer( scoringPlayer, TreasureHunt_GetPersonalMessageIndexFromTeamMessageIndex( messageIndex ), score )

			// If this was an objective capture, track it for stats and challenges
			if ( messageIndex == eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED || messageIndex == eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH )
				StatsHook_TreasureHunt_OnObjectiveCaptured( scoringPlayer )
		}
	}

	// If we display a message for the whole team, trigger it here
	if ( messageDisplayType == eTreasureHuntMessageDisplayType.TEAM )
		TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( teamOrAlliance, messageIndex, score, [] )
	else if ( messageDisplayType == eTreasureHuntMessageDisplayType.TEAM_DEFINED_PLAYERS_COMBO ) // If we display a different message for the teammates display it here but exclude the players that were shown a personal message
		TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( teamOrAlliance, messageIndex, score, scoringPlayers )

	// Test for a team reaching halfway or close to winning
	int scoreLimit = GetScoreLimit_FromPlaylist()
	int highestScore = GamemodeUtility_GetWinningTeamOrAllianceScore()
	int winningTeam = GamemodeUtility_GetWinningTeamOrAlliance( false )
	if ( !file.hasTriggeredTeamHalfwayToWinMsg && highestScore >= int( scoreLimit * MATCH_HALFWAY_SCORE_PERCENT_THRESHOLD ) )
	{
		file.hasTriggeredTeamHalfwayToWinMsg = true

		// If the scoring event would conflict with the halfway to win message dispay, delay the halfway to win message display
		if ( messageIndex == eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED || messageIndex == eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH )
		{
			thread TreasureHunt_DisplayMessageToAllPlayersAfterDelay_Thread( eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN, 0, GetPlayerArrayOfTeam( winningTeam ) )
			thread TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayersAfterDelay_Thread( winningTeam, TreasureHunt_GetPersonalMessageIndexFromTeamMessageIndex( eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN ), 0, [] )
		}
		else
		{
			TreasureHunt_DisplayMessageToAllPlayers( eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN, 0, GetPlayerArrayOfTeam( winningTeam ) )
			TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( winningTeam, TreasureHunt_GetPersonalMessageIndexFromTeamMessageIndex( eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN ), 0, [] )
		}
	}
	else if ( !file.hasTriggeredTeamCloseToWinMsg && highestScore >= int( scoreLimit * MATCH_END_SCORE_PERCENT_THRESHOLD ) )
	{
		file.hasTriggeredTeamCloseToWinMsg = true

		// If the scoring event would conflict with the close to win message dispay, delay the close to win message display
		if ( messageIndex == eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED || messageIndex == eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH )
		{
			thread TreasureHunt_DisplayMessageToAllPlayersAfterDelay_Thread( eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN, 0, GetPlayerArrayOfTeam( winningTeam ) )
			thread TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayersAfterDelay_Thread( winningTeam, TreasureHunt_GetPersonalMessageIndexFromTeamMessageIndex( eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN ), 0, [] )
		}
		else
		{
			TreasureHunt_DisplayMessageToAllPlayers( eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN, 0, GetPlayerArrayOfTeam( winningTeam ) )
			TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( winningTeam, TreasureHunt_GetPersonalMessageIndexFromTeamMessageIndex( eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN ), 0, [] )
		}
	}

	// Test for team gaining or losing the lead
	if ( winningTeam != TEAM_INVALID && winningTeam != file.winningTeam )
	{
		// Somebody lost the lead, play SFX for them
		if ( file.winningTeam != TEAM_INVALID )
			TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( file.winningTeam, eTreasureHuntMessageIndex.TEAM_LOST_LEAD, 0, [] )

		// Play SFX for the team that gained the lead
		TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( winningTeam, eTreasureHuntMessageIndex.TEAM_GAINED_LEAD, 0, [] )

		// Update current winning team
		file.winningTeam = winningTeam
	}
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// UI/ MAP
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if CLIENT

void function TreasureHunt_InstanceObjectivePing( entity wp )
{
	thread TreasureHunt_CreateObjectiveIcon_Thread( wp )
}
#endif // CLIENT

#if CLIENT
// Create the icon for the objective
const int OBJECTIVE_RUI_SORTING = 301
const int MIN_TEAM_INDEX_FOR_RUI = 0
const int MAX_TEAM_INDEX_FOR_RUI = 3
void function TreasureHunt_CreateObjectiveIcon_Thread( entity wp )
{
	Assert( IsNewThread(), "Must be threaded off" )

	FlagWait( "EntitiesDidLoad" )

	entity localViewPlayer = GetLocalViewPlayer()
	if ( !IsValid( localViewPlayer ) || !IsValid( wp ) )
		return

	localViewPlayer.EndSignal( "OnDestroy" )
	wp.EndSignal( "OnDestroy" )

	vector pos = wp.GetOrigin()
	vector iconColor = GetKeyColor( COLORID_HUD_LOOT_TIER5 ) * ( 1.0 / 255.0 )
	// ToDo: Dswieczko - This is using Placeholder icons
	var minimapRui = Minimap_AddRuitPosition( pos, <0,90,0>, $"ui/minimap_square_object_lockdown_objective.rpak", 1.0, COLOR_WHITE )
	var fullmapRui = FullMap_AddRuiAtPos( pos, <0,90,0>, $"ui/in_world_minimap_square_lockdown_objective.rpak", 1.0, COLOR_WHITE )
	var objectiveRui = CreateWaypointRui( $"ui/waypoint_lockdown_capture_objective.rpak", OBJECTIVE_RUI_SORTING )
	int objectiveNameIndex = wp.GetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_INDEX )

	OnThreadEnd(
		function() : ( minimapRui, fullmapRui, objectiveRui, wp, objectiveNameIndex )
		{
			Minimap_CommonCleanup( minimapRui )
			Fullmap_RemoveRui( fullmapRui )
			RuiDestroy( fullmapRui )
			RuiDestroyIfAlive( objectiveRui )
			file.objectiveWaypoints[ objectiveNameIndex ] = null
			file.objectiveWaypointRuis[ objectiveNameIndex ] = null
		}
	)

	//////////////////////////
	/// SET UP MINIMAP RUI ///
	//////////////////////////
	RuiSetFloat2( minimapRui, "iconScale", < 0.65, 0.65, 0 > )
	RuiSetString( minimapRui, "objectiveName", CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveNameIndex ) )
	RuiTrackInt( minimapRui, "currentOwner", wp, RUI_TRACK_WAYPOINT_INT, CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER )
	RuiTrackInt( minimapRui, "objectiveState", wp, RUI_TRACK_WAYPOINT_INT, CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE )

	for ( int team = TEAM_IMC; team < TEAM_IMC + MAX_SUPPORTED_TEAMS; team++ )
	{
		int squadIndex = Squads_GetSquadUIIndex( team )
		RuiSetColorAlpha( minimapRui, "colorTeam" + squadIndex, TreasureHunt_GetTeamColor( team ), 1.0 )
	}

	//////////////////////////
	/// SET UP FULLMAP RUI ///
	//////////////////////////
	RuiSetString( fullmapRui, "objectiveName", CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveNameIndex ) )
	RuiTrackInt( fullmapRui, "currentOwner", wp, RUI_TRACK_WAYPOINT_INT, CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER )
	RuiTrackInt( fullmapRui, "objectiveState", wp, RUI_TRACK_WAYPOINT_INT, CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE )

	for ( int team = TEAM_IMC; team < TEAM_IMC + MAX_SUPPORTED_TEAMS; team++ )
	{
		int squadIndex = Squads_GetSquadUIIndex( team )
		RuiSetColorAlpha( fullmapRui, "colorTeam" + squadIndex, TreasureHunt_GetTeamColor( team ), 1.0 )
	}

	////////////////////////////
	/// SET UP OBJECTIVE RUI ///
	////////////////////////////

	// Set default vars for the objective icon and tracking vars to keep things up to date
	RuiKeepSortKeyUpdated( objectiveRui, true, "targetPos" )
	RuiSetFloat3( objectiveRui, "targetPos", wp.GetOrigin() )
	RuiTrackFloat3( objectiveRui, "playerAngles", localViewPlayer, RUI_TRACK_CAMANGLES_FOLLOW )
	RuiTrackFloat( objectiveRui, "objectiveStartTime", wp, RUI_TRACK_WAYPOINT_FLOAT, CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME )
	RuiTrackInt( objectiveRui, "objectiveState", wp, RUI_TRACK_WAYPOINT_INT, CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE )
	RuiTrackInt( objectiveRui, "currentOwner", wp, RUI_TRACK_WAYPOINT_INT, CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_OWNER )
	RuiSetVisible( objectiveRui, true )
	RuiSetString( objectiveRui, "objectiveName", CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveNameIndex ) )

	// Store the waypoint in an array
	file.objectiveWaypoints[ objectiveNameIndex ] = wp
	file.objectiveWaypointRuis[ objectiveNameIndex ] = objectiveRui

	// The Rui just needs to know how long each state is expected to be and will figure out the timer durations based off the CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME value
	RuiSetFloat( objectiveRui, "objectiveDuration", GetTreasureHuntZoneHoldTime() )
	RuiSetFloat( objectiveRui, "incomingDuration", GetCaptureObjectiveSpawnDelayTime() )

	// Set Team Colors & Icons
	for ( int team = TEAM_IMC; team < TEAM_IMC + MAX_SUPPORTED_TEAMS; team++ )
	{
		int squadIndex = Squads_GetSquadUIIndex( team )
		RuiSetColorAlpha( objectiveRui, "colorTeam" + squadIndex, TreasureHunt_GetTeamColor( team ), 1.0 )
		RuiSetAsset( objectiveRui, "iconTeam" + squadIndex, TreasureHunt_GetTeamIcon( team ) )
	}

	int yourTeamIndex = -1
	entity localPlayer = GetLocalClientPlayer()
	if ( IsValid( localPlayer ) )
		yourTeamIndex = Squads_GetSquadUIIndex( localPlayer.GetTeam() )
	RuiSetInt( objectiveRui, "yourTeamIndex", yourTeamIndex )

	// ToDo: DSwieczko - leaving as 0 for now, if we need it I will have to hook something up here, if we don't care I will remove this var from the rui
	RuiSetInt( objectiveRui, "friendliesOnObjective", 0 )
	RuiSetInt( objectiveRui, "enemiesOnObjective", 0 )

	WaitForever()
}
#endif // CLIENT

#if CLIENT
array < entity > function TreasureHunt_GetObjectiveWaypointsArray()
{
	return file.objectiveWaypoints
}
#endif // CLIENT

#if CLIENT
// Update ping counts in the Objective Rui when an objective gets pinged or a ping gets destroyed
void function TreasureHunt_OnObjectiveWaypointPinged( entity objectiveWaypoint, int team, int count )
{
	if ( !IsValid( objectiveWaypoint ) || !file.objectiveWaypoints.contains( objectiveWaypoint ) )
		return

	entity localPlayer = GetLocalClientPlayer()

	if ( localPlayer.GetTeam() != team )
		return

	int objectiveIndex = TreasureHunt_GetObjectiveIDFromWaypoint( objectiveWaypoint )
	var rui = file.objectiveWaypointRuis[ objectiveIndex ]
	RuiSetInt( rui, "numTeamPings", count )
}
#endif // CLIENT





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if CLIENT
void function TreasureHunt_ScoreboardSetup()
{
	clGlobal.showScoreboardFunc = ShowScoreboardOrMap_Teams
	clGlobal.hideScoreboardFunc = HideScoreboardOrMap_Teams

	Teams_AddCallback_ScoreboardData( TreasureHunt_GetScoreboardData )
	Teams_AddCallback_Header( TreasureHunt_ScoreboardUpdateHeader )
	Teams_AddCallback_PlayerScores( TreasureHunt_GetPlayerScores )
	Teams_AddCallback_SortScoreboardPlayers( TreasureHunt_SortPlayersByScore )
	Teams_AddCallback_GetTeamColor( TreasureHunt_GetTeamColor )
	Teams_AddCallback_GetTeamName( TreasureHunt_GetTeamName )
	Teams_AddCallback_GetTeamIcon( TreasureHunt_GetTeamIcon )
	Teams_AddCallback_DoModeSpecificWork( TreasureHunt_ModeSpecificScoreboardWork, "LockdownScoreHud" )
}
#endif // CLIENT

#if CLIENT
ScoreboardData function TreasureHunt_GetScoreboardData()
{
	ScoreboardData data
	data.numScoreColumns = 2

	data.columnDisplayIcons.append( $"rui/hud/common/timer_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 4 )

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_kills_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 2 )

	return data
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_OnResolutionChanged()
{
	file.lockdownScoreboardHud = null
}
#endif

#if CLIENT
void function TreasureHunt_ModeSpecificScoreboardWork( var lockdownScoreElement )
{
	var lockdownScoreRui = Hud_GetRui( lockdownScoreElement )

	if ( file.lockdownScoreboardHud == null || !IsValid( file.lockdownScoreboardHud ) )
	{
		file.lockdownScoreboardHud = lockdownScoreRui
	}

	int scoreLimit = GetScoreLimit_FromPlaylist()
	RuiSetInt( lockdownScoreRui, "scoreLimit", scoreLimit )

	// Set Score Variables
	entity localPlayer = GetLocalClientPlayer()
	array< TeamScoreStruct > teamScores = []
	for ( int team = TEAM_IMC; team < TEAM_IMC + MAX_SUPPORTED_TEAMS; team++ )
	{
		int squadIndex = Squads_GetSquadUIIndex( team )

		array< entity > playersOnTeam = GetPlayerArrayOfTeam( team )
		bool isTeamVisible = true
		if ( playersOnTeam.len() <= 0 )
		{
			isTeamVisible = false
			RuiSetBool( lockdownScoreRui, "squadVisible" + squadIndex, false )
		}

		RuiSetBool( lockdownScoreRui, "yourTeam" + squadIndex, IsPlayerOnTeam( localPlayer, team ) )

		int teamScore = GameRules_GetTeamScore( team )
		RuiSetInt( lockdownScoreRui, "score_" + squadIndex, teamScore )

		TeamScoreStruct teamScoreData
		teamScoreData.teamNum = squadIndex
		teamScoreData.score = teamScore
		teamScoreData.isVisible = isTeamVisible
		teamScores.push( teamScoreData )

		if ( isTeamVisible )
			TreasureHunt_SetCharacterInfo( lockdownScoreRui, team, squadIndex )

		Hud_SetVisible( lockdownScoreElement, true )
	}

	// Sort teams by score
	teamScores.sort( TreasureHunt_OrderTeamsByScore )

	// Set the placement rui values
	for ( int placement = 0; placement < MAX_SUPPORTED_TEAMS; placement++ )
	{
		int teamNum = teamScores[ placement ].teamNum
		RuiSetInt( lockdownScoreRui, "placementTeam" + teamNum, placement )
	}

	Hud_SetVisible( lockdownScoreElement, true )
	Hud_Show( lockdownScoreElement )
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_ScoreboardUpdateHeader( var headerRui, var frameRui, int team )
{
	if ( headerRui != null )
	{
		bool isWinning = team == GamemodeUtility_GetWinningTeamOrAlliance( true )
		RuiSetString( headerRui, "headerText", Localize( TreasureHunt_GetTeamName( team ) ) )
		RuiSetBool( headerRui, "isWinning", isWinning )
		RuiSetImage( headerRui, "teamIcon", TreasureHunt_GetTeamIcon(team))
		RuiSetInt( headerRui, "teamScore", GameRules_GetTeamScore( team ) )
		RuiSetInt( headerRui, "scoreLimit", GetScoreLimit_FromPlaylist() )
		RuiSetBool( headerRui, "useScoreLimitElements", true )
		RuiSetBool( headerRui, "useGunGameElements", false )
	}
}
#endif // CLIENT

#if CLIENT
array< string > function TreasureHunt_GetPlayerScores( entity player )
{
	array< string > scores
	int playerTeamOrAlliance = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) : player.GetTeam()

	string timeOnObjective
	DisplayTime dt = SecondsToDHMS( int( player.GetPlayerNetTime( "treasureHunt_PlayerTimeOnObjectives" ) ) )
	if ( dt.hours != 0 )
		timeOnObjective = format( "%d:%.2d:%.2d", dt.hours, dt.minutes, dt.seconds )
	else
		timeOnObjective = format( "%.2d:%.2d", dt.minutes, dt.seconds )
	
	scores.append( timeOnObjective )

	string eliminations = string( player.GetPlayerNetInt( "kills" ) )
	scores.append( eliminations )

	return scores
}
#endif // CLIENT

#if CLIENT
// Sort scoreboard players by score first, then kills second
array< TeamsScoreboardPlayer > function TreasureHunt_SortPlayersByScore( array< TeamsScoreboardPlayer > players )
{
	players.sort( int function( TeamsScoreboardPlayer a, TeamsScoreboardPlayer b )
	{
		entity playerA = FromEHI( a.playerEHI )
		entity playerB = FromEHI( b.playerEHI )

		if( !IsValid( playerA ) || !IsValid( playerB ) )
			return 0

		float aTimeOnObjective = playerA.GetPlayerNetTime( "treasureHunt_PlayerTimeOnObjectives" )
		float bTimeOnObjective = playerB.GetPlayerNetTime( "treasureHunt_PlayerTimeOnObjectives" )
		int aKills = playerA.GetPlayerNetInt( "kills" )
		int bKills = playerB.GetPlayerNetInt( "kills" )

		if ( aTimeOnObjective > bTimeOnObjective ) return -1
		else if ( aTimeOnObjective < bTimeOnObjective ) return 1
		else
		{
			if ( aKills > bKills ) return -1
			else if ( aKills < bKills ) return 1
		}
		return 0
	}
	)

	return players
}
#endif // CLIENT

#if SERVER || CLIENT
vector function TreasureHunt_GetTeamColor( int team )
{
	int squadIndex = Squads_GetSquadUIIndex( team )

	#if SERVER
		return Squads_GetSquadColor_Server( squadIndex )
	#elseif CLIENT
		return Squads_GetSquadColor( squadIndex )
	#endif
}
#endif // SERVER || CLIENT

#if CLIENT
string function TreasureHunt_GetTeamName( int team )
{
	int squadIndex = Squads_GetSquadUIIndex( team )

	return Squads_GetSquadName( squadIndex )
}
#endif //client

#if CLIENT
asset function TreasureHunt_GetTeamIcon( int team )
{
	int squadIndex = Squads_GetSquadUIIndex( team )

	return Squads_GetSquadIcon( squadIndex )
}
#endif //client

#if CLIENT
struct TeamScoreStruct
{
	int teamNum = 0
	int score = 0
	bool isVisible = false
}

void function TreasureHunt_DisplaySquadScore_Thread()
{
	var rui = CreateCockpitPostFXRui( $"ui/lockdown_score.rpak", MINIMAP_Z_BASE + 10 )
	file.lockdownScoreHud = rui

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroyIfAlive( rui )
		}
	)

	                         
		bool prevShouldTriggerCrowdOneShot = false
                                

	int numTeams = GetNumTeamsExisting()
	Assert( numTeams <= MAX_SUPPORTED_TEAMS, "LOCKDOWN: Trying to update scores for " + numTeams + " but this score RUI only supports " + MAX_SUPPORTED_TEAMS + " teams" )
	int maxTeamSize = GetMaxTeamSizeForPlaylist( GetCurrentPlaylistName() )
	int scoreLimit = GetScoreLimit_FromPlaylist()
	RuiSetInt( file.lockdownScoreHud, "scoreLimit", scoreLimit )

	while( GetGameState() < eGameState.WinnerDetermined )
	{
		array < entity > allPlayersArray = GetPlayerArray()
		table < int, array< int > > zoneToTeamsOnZoneTable
		int objectiveLocalPlayerIsOn = -1
		foreach ( entity player in allPlayersArray )
		{
			if ( !IsValid( player ) )
				continue

			Squads_SetCustomPlayerInfo( player )

			// Determine which objectives have players on them
			int objectiveOccupiedByPlayer = player.GetPlayerNetInt( "treasureHunt_OccupiedObjectiveID" )
			int playerTeam = player.GetTeam()
			if ( TreasureHunt_IsValidObjectiveIndex( objectiveOccupiedByPlayer ) )
			{
				if ( !( objectiveOccupiedByPlayer in zoneToTeamsOnZoneTable) ) // This is the first team on this point, add it to the table
					zoneToTeamsOnZoneTable[ objectiveOccupiedByPlayer ] <- [ playerTeam ]
				else if ( !zoneToTeamsOnZoneTable[ objectiveOccupiedByPlayer ].contains( playerTeam ) ) // This Zone already has teams on it but this team isn't tracked yet, add it to the table
					zoneToTeamsOnZoneTable[ objectiveOccupiedByPlayer ].append( playerTeam )

				// If the local player is on an objective, we'll make note of that because we'll also setup their Zone Status Hud
				if ( player == GetLocalClientPlayer() )
				{
					objectiveLocalPlayerIsOn = objectiveOccupiedByPlayer
				}
			}
		}

		// If there are zones with no players on them add them to the zoneToTeamsOnZoneTable anyways so their banners get updated anyways
		for ( int index = 0; index < file.objectiveWaypoints.len(); index++ )
		{
			if ( !( index in zoneToTeamsOnZoneTable ) )
			{
				// Zone is empty but spawned, we want to show it on the score markers
				if ( file.objectiveWaypoints[ index ] != null )
					zoneToTeamsOnZoneTable[ index ] <- []
				else // Zone isn't spawned, make sure we don't display it on the score markers
					TreasureHunt_ScoreHud_SetVisibleCapturePointName( index, "" )
			}
		}

		// Set Hud Variables for teams on objectives
		foreach ( objectiveID, teamsOnObjectiveArray in zoneToTeamsOnZoneTable )
		{
			string objectiveName = CaptureObjectivePing_GetObjectiveNameFromObjectiveID_Localized( objectiveID )

			// All of these zones are active, show the marker
			TreasureHunt_ScoreHud_SetVisibleCapturePointName( objectiveID, objectiveName )

			if ( teamsOnObjectiveArray.len() == 1 ) // Only 1 team on the zone
			{
				int team = teamsOnObjectiveArray[ 0 ]
				int squadIndex = Squads_GetSquadUIIndex( team )
				TreasureHunt_ScoreHud_SetCapturePointColor( objectiveID, TreasureHunt_GetTeamColor( team ) )
				TreasureHunt_ScoreHud_SetCapturePointContested( objectiveID, false )
				TreasureHunt_ScoreHud_SetTeamOnPoint( objectiveID, squadIndex, true )

				// Set Zone Status Hud
				if ( objectiveID == objectiveLocalPlayerIsOn )
				{
					TreasureHunt_CaptureZoneHud_SetStatusColor( TreasureHunt_GetTeamColor( team ) )
					TreasureHunt_CaptureZoneHud_SetStatusText( "#FREEDM_LOCKDOWN_OBJ_STATE_CAPTURING" )
					TreasureHunt_CaptureZoneHud_SetStatusIcon( TreasureHunt_GetTeamIcon( team ) )
					TreasureHunt_CaptureZoneHud_SetObjectiveName( objectiveName )
					TreasureHunt_CaptureZoneHud_SetContested( false )

					float objStartTime = Time()
					if ( IsValid( file.objectiveWaypoints[ objectiveID ] ) )
						objStartTime = file.objectiveWaypoints[ objectiveID ].GetWaypointFloat( CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME )

					float objEndTime = objStartTime + GetTreasureHuntZoneHoldTime()

					TreasureHunt_CaptureZoneHud_SetZoneStartTime( objStartTime )
					TreasureHunt_CaptureZoneHud_SetZoneEndTime( objEndTime )
					TreasureHunt_CaptureZoneHud_SetZoneDuration( GetTreasureHuntZoneHoldTime() )

					int objectiveState = eTreasureHuntCaptureZoneState.CAPTURING
					if ( IsValid( file.objectiveWaypoints[ objectiveID ] ) )
						objectiveState = file.objectiveWaypoints[ objectiveID ].GetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE )
					TreasureHunt_CaptureZoneHud_SetZoneState( objectiveState )

					TreasureHunt_CaptureZoneStatus_SetRuiVisibility( true )
				}
			}
			else if ( teamsOnObjectiveArray.len() > 1 ) // Zone is contested or in sudden death state
			{
				int objectiveState = eTreasureHuntCaptureZoneState.CONTESTED
				if ( IsValid( file.objectiveWaypoints[ objectiveID ] ) )
					objectiveState = file.objectiveWaypoints[ objectiveID ].GetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_STATE )

				vector color = objectiveState == eTreasureHuntCaptureZoneState.SUDDEN_DEATH ? SrgbToLinear( ZONE_SUDDENDEATH_COLOR ) : SrgbToLinear( ZONE_CONTESTED_COLOR )
				TreasureHunt_ScoreHud_SetCapturePointColor( objectiveID, color )
				TreasureHunt_ScoreHud_SetCapturePointContested( objectiveID, true )

				// Set Zone Status Hud
				if ( objectiveID == objectiveLocalPlayerIsOn )
				{
					string statusText = objectiveState == eTreasureHuntCaptureZoneState.SUDDEN_DEATH ? "#FREEDM_LOCKDOWN_OBJ_STATE_SUDDENDEATH" : "#FREEDM_LOCKDOWN_OBJ_STATE_CONTESTED"
					TreasureHunt_CaptureZoneHud_SetStatusColor( color )
					TreasureHunt_CaptureZoneHud_SetStatusText( statusText )
					TreasureHunt_CaptureZoneHud_SetStatusIcon( $"rui/gamemodes/tdm/tdm_contested_icon" )
					TreasureHunt_CaptureZoneHud_SetObjectiveName( objectiveName )
					TreasureHunt_CaptureZoneHud_SetContested( true )

					float objStartTime = Time()
					if ( IsValid( file.objectiveWaypoints[ objectiveID ] ) )
						objStartTime = file.objectiveWaypoints[ objectiveID ].GetWaypointFloat( CAPTURE_OBJ_WAYPOINT_FLOAT_IDX_START_TIME )

					float objEndTime = objStartTime + GetTreasureHuntZoneHoldTime()

					TreasureHunt_CaptureZoneHud_SetZoneStartTime( objStartTime )
					TreasureHunt_CaptureZoneHud_SetZoneEndTime( objEndTime )
					TreasureHunt_CaptureZoneHud_SetZoneDuration( GetTreasureHuntZoneHoldTime() )
					TreasureHunt_CaptureZoneHud_SetZoneState( objectiveState )

					TreasureHunt_CaptureZoneStatus_SetRuiVisibility( true )
				}
			}
			else // Zone is empty, but we still want to show it
			{
				TreasureHunt_ScoreHud_SetCapturePointColor( objectiveID, ZONE_NEUTRAL_COLOR )
				TreasureHunt_ScoreHud_SetCapturePointContested( objectiveID, false )
			}

			// Need to set a true or false value for each team regardless of if they are on the point or not
			for ( int team = TEAM_IMC; team < TEAM_IMC + MAX_SUPPORTED_TEAMS; team++ )
			{
				int squadIndex = Squads_GetSquadUIIndex( team )

				if ( teamsOnObjectiveArray.contains( team ) )
					TreasureHunt_ScoreHud_SetTeamOnPoint( objectiveID, squadIndex, true )
				else
					TreasureHunt_ScoreHud_SetTeamOnPoint( objectiveID, squadIndex, false )
			}
		}

		// If the local player is not on an objective, we'll hide their capture zone status hud
		if ( objectiveLocalPlayerIsOn == -1 )
		{
			TreasureHunt_CaptureZoneStatus_SetRuiVisibility( false )
		}

		// Set Score Variables
		entity localPlayer = GetLocalClientPlayer()
		array< TeamScoreStruct > teamScores = []
		for ( int team = TEAM_IMC; team < TEAM_IMC + MAX_SUPPORTED_TEAMS; team++ )
		{
			int squadIndex = Squads_GetSquadUIIndex( team )

			array< entity > playersOnTeam = GetPlayerArrayOfTeam( team )
			bool isTeamVisible = true
			if ( playersOnTeam.len() <= 0 )
			{
				isTeamVisible = false
				RuiSetBool( file.lockdownScoreHud, "squadVisible" + squadIndex, false )
			}

			RuiSetBool( file.lockdownScoreHud, "yourTeam" + squadIndex, IsPlayerOnTeam( localPlayer, team ) )

			int teamScore = GameRules_GetTeamScore( team )
			RuiSetInt( file.lockdownScoreHud, "score_" + squadIndex, teamScore )

			TeamScoreStruct teamScoreData
			teamScoreData.teamNum = squadIndex
			teamScoreData.score = teamScore
			teamScoreData.isVisible = isTeamVisible
			teamScores.push( teamScoreData )

			if ( isTeamVisible )
				TreasureHunt_SetCharacterInfo( file.lockdownScoreHud, team, squadIndex )
		}

		// Sort teams by score
		teamScores.sort( TreasureHunt_OrderTeamsByScore )

		// Set the placement rui values
		for ( int placement = 0; placement < MAX_SUPPORTED_TEAMS; placement++ )
		{
			int teamNum = teamScores[ placement ].teamNum
			RuiSetInt( file.lockdownScoreHud, "placementTeam" + teamNum, placement )
		}

		                         
			entity localViewPlayer = GetLocalViewPlayer()
			bool shouldTriggerCrowdOneShot = false
			if ( IsValid( localViewPlayer ) )
			{
				foreach ( int objectiveID, array< int > teamsOnObjectiveArray in zoneToTeamsOnZoneTable )
				{
					foreach ( int teamOnObjective in teamsOnObjectiveArray )
					{
						shouldTriggerCrowdOneShot = IsPlayerOnTeam( localViewPlayer, teamOnObjective )

						if ( shouldTriggerCrowdOneShot )
							break
					}

					if ( shouldTriggerCrowdOneShot )
						break
				}
			}

			if ( shouldTriggerCrowdOneShot != prevShouldTriggerCrowdOneShot )
			{
				// TRIGGER ONE SHOT
				ToggleCrowdSoundOnEntity( localViewPlayer, eCrowdSound.CAPTURE_START, shouldTriggerCrowdOneShot )
				prevShouldTriggerCrowdOneShot = shouldTriggerCrowdOneShot
			}
                                 

		WaitFrame()
	}
}
#endif // Client

#if CLIENT
void function TreasureHunt_SetCharacterInfo( var rui, int team, int reorderedIndex )
{
	int squadIndex = Squads_GetSquadUIIndex( team )
	string indexString = string( squadIndex )

	RuiSetAsset( rui, "squadImage" + indexString, Squads_GetSquadIcon(reorderedIndex ) )
	RuiSetString( rui, "squadName" + indexString, Squads_GetSquadName(reorderedIndex ) )
	RuiSetBool( rui, "squadVisible" + indexString, true )
	RuiSetColorAlpha( rui, "squadBorderColor" + indexString, Squads_GetSquadColor( reorderedIndex ), 1.0 )
}
#endif // CLIENT

#if CLIENT
int function TreasureHunt_OrderTeamsByScore( TeamScoreStruct scoreA, TeamScoreStruct scoreB )
{
	// First handle sorting for visible teams
	if ( scoreA.isVisible && !scoreB.isVisible )
		return -1
	else if ( !scoreA.isVisible && scoreB.isVisible )
		return 1

	// Then if visibility didn't handle the sort, sort by score
	if ( scoreA.score > scoreB.score )
		return -1
	else if ( scoreA.score < scoreB.score )
		return 1
	return 0
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CreateCaptureZoneStatusRui()
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
		return

	file.captureZoneStatusRui = CreateCockpitPostFXRui( $"ui/lockdown_capture_zone_status.rpak", MINIMAP_Z_BASE + 10 )
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneStatus_SetRuiVisibility( bool isVisible )
{
	if ( file.captureZoneStatusRui == null || !RuiIsAlive( file.captureZoneStatusRui ) )
		return

	RuiSetBool( file.captureZoneStatusRui, "isVisible", isVisible )
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_ScoreHud_SetVisibleCapturePointName( int pointIndex, string pointName )
{
	if ( file.lockdownScoreHud == null && file.lockdownScoreboardHud == null )
		return

	if ( file.lockdownScoreHud != null && RuiIsAlive( file.lockdownScoreHud ) )
	{
		RuiSetString( file.lockdownScoreHud, "availablePoint" + pointIndex, pointName )
	}

	if ( file.lockdownScoreboardHud != null && RuiIsAlive( file.lockdownScoreboardHud ) )
	{
		RuiSetString( file.lockdownScoreboardHud, "availablePoint" + pointIndex , pointName )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_ScoreHud_SetCapturePointContested( int pointIndex, bool isContested )
{
	if ( file.lockdownScoreHud == null && file.lockdownScoreboardHud == null )
		return

	if ( file.lockdownScoreHud != null && RuiIsAlive( file.lockdownScoreHud )  )
	{
		RuiSetBool( file.lockdownScoreHud, "point" + pointIndex + "Contested", isContested )
	}

	if ( file.lockdownScoreboardHud != null && RuiIsAlive( file.lockdownScoreboardHud ) )
	{
		RuiSetBool( file.lockdownScoreboardHud, "point" + pointIndex + "Contested", isContested )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_ScoreHud_SetCapturePointColor( int pointIndex, vector pointColor )
{
	if ( file.lockdownScoreHud == null && file.lockdownScoreboardHud == null )
		return

	if ( file.lockdownScoreHud != null && RuiIsAlive( file.lockdownScoreHud ) )
	{
		RuiSetColorAlpha( file.lockdownScoreHud, "pointColor" + pointIndex, pointColor, 1 )
	}

	if ( file.lockdownScoreboardHud != null && RuiIsAlive( file.lockdownScoreboardHud ) )
	{
		RuiSetColorAlpha( file.lockdownScoreboardHud, "pointColor" + pointIndex, pointColor, 1 )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_ScoreHud_SetTeamOnPoint( int pointIndex, int teamId, bool isOnPoint )
{
	if ( file.lockdownScoreHud == null && file.lockdownScoreboardHud == null )
		return

	if ( file.lockdownScoreHud != null && RuiIsAlive( file.lockdownScoreHud ) )
	{
		RuiSetBool( file.lockdownScoreHud, "team" + teamId + "OnPoint" + pointIndex, isOnPoint )
	}

	if ( file.lockdownScoreboardHud != null && RuiIsAlive( file.lockdownScoreboardHud ) )
	{
		RuiSetBool( file.lockdownScoreboardHud, "team" + teamId + "OnPoint" + pointIndex, isOnPoint )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetStatusColor( vector statusColor )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetColorAlpha( file.captureZoneStatusRui, "statusColor", statusColor, 1.0 )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetStatusText( string statusText )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetString( file.captureZoneStatusRui, "statusText", Localize( statusText ) )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetStatusIcon( asset statusIcon )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetAsset( file.captureZoneStatusRui, "statusIcon", statusIcon )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetZoneStartTime( float captureStartTime )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetFloat( file.captureZoneStatusRui, "zoneStartTime", captureStartTime )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetZoneEndTime( float captureEndTime )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetFloat( file.captureZoneStatusRui, "zoneEndTime", captureEndTime )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetZoneDuration( float captureDuration )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetFloat( file.captureZoneStatusRui, "zoneDuration", captureDuration )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetZoneState( int zoneState )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetInt( file.captureZoneStatusRui, "objectiveState", zoneState )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetObjectiveName( string objectiveName )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetString( file.captureZoneStatusRui, "objectiveName", Localize( objectiveName ) )
	}
}
#endif // CLIENT

#if CLIENT
void function TreasureHunt_CaptureZoneHud_SetContested( bool isContested )
{
	if ( file.captureZoneStatusRui != null && RuiIsAlive( file.captureZoneStatusRui ) )
	{
		RuiSetBool( file.captureZoneStatusRui, "isContested", isContested )
	}
}
#endif // CLIENT


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CLIENT SIDE MESSAGING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
// Display a Message on the Client for every player in the match
void function TreasureHunt_DisplayMessageToAllPlayers( int messageID, int pointsValue, array< entity > playersToExclude )
{
	array < entity > allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) && !playersToExclude.contains( player ) )
			Remote_CallFunction_NonReplay( player, "ServerCallback_TreasureHunt_DisplayMessageToClient", messageID, pointsValue )
	}
}
#endif // SERVER

#if SERVER
// Display a Message on the Client for every player in the match after a set delay
void function TreasureHunt_DisplayMessageToAllPlayersAfterDelay_Thread( int messageID, int pointsValue, array< entity > playersToExclude )
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	wait DELAYED_MESSAGE_DELAY

	TreasureHunt_DisplayMessageToAllPlayers( messageID, pointsValue, playersToExclude )
}
#endif // SERVER

#if SERVER
// Display a Message on the Client for every player in the passed in team or alliance
void function TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( int teamOrAlliance, int messageID, int pointsValue, array< entity > playersToExclude )
{
	array < entity > teamOrAlliancePlayers = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllPlayersInAlliance( teamOrAlliance, true ) : GetPlayerArrayOfTeam_Alive( teamOrAlliance )
	foreach( teamOrAlliancePlayer in teamOrAlliancePlayers )
	{
		if ( IsValid( teamOrAlliancePlayer ) && !playersToExclude.contains( teamOrAlliancePlayer ) )
			Remote_CallFunction_NonReplay( teamOrAlliancePlayer, "ServerCallback_TreasureHunt_DisplayMessageToClient", messageID, pointsValue )
	}
}
#endif // SERVER

#if SERVER
// Display a Message on the Client for every player in the passed in team or alliance after a delay
void function TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayersAfterDelay_Thread( int teamOrAlliance, int messageID, int pointsValue, array< entity > playersToExclude )
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	wait DELAYED_MESSAGE_DELAY

	TreasureHunt_DisplayMessageToAllTeamOrAlliancePlayers( teamOrAlliance, messageID, pointsValue, playersToExclude )
}
#endif // SERVER

#if SERVER
// Get the message index for the personal text string from the message index of the same message that would normally display for the whole team
// example: Team message: "Team Scored for Capture" the personal message shown to players involved in that action might be "Your Scored for Capture"
// Returns the team message index if there is no personal message index defined
int function TreasureHunt_GetPersonalMessageIndexFromTeamMessageIndex( int messageID )
{
	int personalMessageID = messageID

	switch ( messageID )
	{
		case eTreasureHuntMessageIndex.SCORE_CAPTURE_INITIATED:
			personalMessageID = eTreasureHuntMessageIndex.SCORE_CAPTURE_INITIATED_PERSONAL
			break
		case eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED:
			personalMessageID = eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_PERSONAL
			break
		case eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH:
			personalMessageID = eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH_PERSONAL
			break
		case eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN:
			personalMessageID = eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN_PERSONAL
			break
		case eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN:
			personalMessageID = eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN_PERSONAL
			break
		default:
			break
	}

	return personalMessageID
}
#endif // SERVER

#if SERVER
// Display a Message on the Client for the specific player
void function TreasureHunt_DisplayMessageToPlayer( entity player, int messageID, int pointsValue )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_TreasureHunt_DisplayMessageToClient", messageID, pointsValue )
}
#endif // SERVER

#if CLIENT
// Display a message in the bottom right of the screen
const float SPLASH_TEXT_DURATION = 4.0
void function ServerCallback_TreasureHunt_DisplayMessageToClient( int messageID, int pointsValue )
{
	entity localPlayer = GetLocalViewPlayer()

	if (  !IsValid( localPlayer )  )
		return

	string messageText = ""

	string announcementText = ""
	string announcementSubText = ""
	bool isObituaryMessage = false
	bool isAnnouncementMessage = false
	bool isSplashText = false
	vector announcementColor = <0.8, 0.8, 0.8>

	switch ( messageID )
	{
		case eTreasureHuntMessageIndex.SCORE_CAPTURE_INITIATED:
			isObituaryMessage = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURE_STARTED", pointsValue )
			break
		case eTreasureHuntMessageIndex.SCORE_CAPTURE_INITIATED_PERSONAL:
			isObituaryMessage = true
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURE_STARTED_YOU", pointsValue )
			EmitUISound( LOCKDOWN_SFX_OBJ_CAPTURE_STARTED )
			break
		case eTreasureHuntMessageIndex.SCORE_CAPTURING:
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURING", pointsValue )
			EmitUISound( LOCKDOWN_SFX_OBJ_CAPTURING )
			break
		case eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED:
			isObituaryMessage = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURED", pointsValue )
			break
		case eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_PERSONAL:
			isObituaryMessage = true
			isAnnouncementMessage = true
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURED_YOU", pointsValue )
			announcementText = Localize( "#FREEDM_LOCKDOWN_CAPTURED_YOU_ANNOUNCE" )
			announcementSubText = Localize( "#FREEDM_LOCKDOWN_POINTS", pointsValue )
			EmitUISound( LOCKDOWN_SFX_OBJ_CAPTURE_FINISHED )
			break
		case eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH:
			isObituaryMessage = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURED_SUDDENDEATH", pointsValue )
			break
		case eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED_SUDDENDEATH_PERSONAL:
			isObituaryMessage = true
			isAnnouncementMessage = true
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURED_SUDDENDEATH_YOU", pointsValue )
			announcementText = Localize( "#FREEDM_LOCKDOWN_CAPTURED_SUDDENDEATH_YOU_ANNOUNCE" )
			announcementSubText = Localize( "#FREEDM_LOCKDOWN_POINTS", pointsValue )
			EmitUISound( LOCKDOWN_SFX_OBJ_CAPTURE_FINISHED )
			break
		case eTreasureHuntMessageIndex.SCORE_KILL:
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_KILL_SCORE", pointsValue )
			break
		case eTreasureHuntMessageIndex.SCORE_KILL_FROM_ZONE:
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_KILL_FROM_ZONE_SCORE", pointsValue )
			break
		case eTreasureHuntMessageIndex.SCORE_KILL_WINNER:
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_KILL_WINNER_SCORE", pointsValue )
			break
		case eTreasureHuntMessageIndex.CAPTURE_OBJECTIVE_INCOMING:
			isAnnouncementMessage = true
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_CAPTURE_OBJ_INCOMING" )
			EmitUISound( LOCKDOWN_SFX_CAPTURE_OBJ_INCOMING )
			break
		case eTreasureHuntMessageIndex.OBJECTIVE_ENTERS_SUDDEN_DEATH:
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_OBJ_SUDDEN_DEATH" )
			EmitUISound( LOCKDOWN_SFX_CAPTURE_OBJ_SUDDEN_DEATH )
			break
		case eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN:
			isAnnouncementMessage = true
			isSplashText = true
			int squadIndex = Squads_GetSquadUIIndex( GamemodeUtility_GetWinningTeamOrAlliance( false ) )
			messageText = Localize( "#FREEDM_LOCKDOWN_TEAM_HALFWAY_TO_WIN", Localize( Squads_GetSquadNameLong( squadIndex, false ) ) )
			EmitUISound( LOCKDOWN_SFX_TEAM_HALFWAY_TO_WIN )
			break
		case eTreasureHuntMessageIndex.TEAM_HALFWAY_TO_WIN_PERSONAL:
			isAnnouncementMessage = true
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_TEAM_HALFWAY_TO_WIN", Localize( "#FREEDM_LOCKDOWN_YOUR_TEAM_WINNING_PREFIX" ) )
			EmitUISound( LOCKDOWN_SFX_TEAM_HALFWAY_TO_WIN )
			break
		case eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN:
			isAnnouncementMessage = true
			isSplashText = true
			int squadIndex = Squads_GetSquadUIIndex( GamemodeUtility_GetWinningTeamOrAlliance( false ) )
			messageText = Localize( "#FREEDM_LOCKDOWN_TEAM_CLOSE_TO_WIN", Localize( Squads_GetSquadNameLong( squadIndex, false ) ) )
			EmitUISound( LOCKDOWN_SFX_TEAM_CLOSE_TO_WIN )
			break
		case eTreasureHuntMessageIndex.TEAM_CLOSE_TO_WIN_PERSONAL:
			isAnnouncementMessage = true
			isSplashText = true
			messageText = Localize( "#FREEDM_LOCKDOWN_TEAM_CLOSE_TO_WIN", Localize( "#FREEDM_LOCKDOWN_YOUR_TEAM_WINNING_PREFIX" ) )
			EmitUISound( LOCKDOWN_SFX_TEAM_CLOSE_TO_WIN )
			break
		case eTreasureHuntMessageIndex.OBJECTIVE_ENTERS_CONTESTED_STATE:
			EmitUISound( LOCKDOWN_SFX_OBJECTIVE_CONTESTED )
			break
		case eTreasureHuntMessageIndex.TEAM_GAINED_LEAD:
			EmitUISound( LOCKDOWN_SFX_TEAM_GAINED_LEAD )
			break
		case eTreasureHuntMessageIndex.TEAM_LOST_LEAD:
			EmitUISound( LOCKDOWN_SFX_TEAM_LOST_LEAD )
			break
		default:
			Assert( false, "LOCKDOWN: " + FUNC_NAME() + " was run with an Invalid messageID: " + messageID + " , message will not display in Live for this event." )
			return
	}

	// The announcements will use the same text as the other messaging if not specified
	if ( announcementText == "" )
		announcementText = messageText

	if ( isObituaryMessage )
		Obituary_Print_Localized( messageText )

	if ( isAnnouncementMessage )
	{
		entity localViewPlayer = GetLocalViewPlayer()

		AnnouncementData announcement = Announcement_Create( announcementText )
		announcement.subText = announcementSubText
		announcement.duration = 5.0
		announcement.titleColor = announcementColor
		announcement.priority =	0
		announcement.announcementStyle = ANNOUNCEMENT_STYLE_CIRCLE_WARNING

		AnnouncementFromClass( localPlayer, announcement )
	}

	if ( isSplashText )
		AddImageQueueMessage( messageText, $"", SPLASH_TEXT_DURATION )
}
#endif // CLIENT




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AUDIO SFX, MUSIC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#if CLIENT
// Play sfx when the player enters or exits a Capture Zone
void function TreasureHunt_PlayCaptureZoneEnterExitSFX( bool isEnteringZone )
{
	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	if ( isEnteringZone )
	{
		EmitUISound( LOCKDOWN_SFX_CAPTURE_ZONE_ENTER )
	}
	else
	{
		EmitUISound( LOCKDOWN_SFX_CAPTURE_ZONE_EXIT )
	}
}
#endif // CLIENT

#if SERVER
// Get the appropriate music controller value for the ramp up music system based on how close we are to the match ending ( based on score )
float function TreasureHunt_GetRampUpMusicControllerValueFromScore( int scoreLeft )
{
	float controllerValue = MUSIC_CONTROLLER_LEVEL_NOT_SET
	int scoreLimit = GetScoreLimit_FromPlaylist()
	int highestScore = scoreLimit - scoreLeft

	if ( highestScore >= RAMPUP_MUSIC_SCORE_THRESHOLD_4 * scoreLimit )
		controllerValue = MUSIC_CONTROLLER_LEVEL_4
	else if ( highestScore >= RAMPUP_MUSIC_SCORE_THRESHOLD_3 * scoreLimit )
		controllerValue = MUSIC_CONTROLLER_LEVEL_3
	else if ( highestScore >= RAMPUP_MUSIC_SCORE_THRESHOLD_2 * scoreLimit )
		controllerValue = MUSIC_CONTROLLER_LEVEL_2
	else if ( highestScore >= RAMPUP_MUSIC_SCORE_THRESHOLD_1 * scoreLimit )
		controllerValue = MUSIC_CONTROLLER_LEVEL_1

	return controllerValue
}
#endif // SERVER

#if SERVER
// FreeDM starts playing ramp up music based on score remaining before the match ends
// Set that value but based on the scoring values we use to first start ramping up the music in TreasureHunt_GetRampUpMusicControllerValueFromScore
int function TreasureHunt_GetRampUpMusicStartScoreValue()
{
	int scoreLimit = GetScoreLimit_FromPlaylist()
	int scoreAtFirstThreshold = int( RAMPUP_MUSIC_SCORE_THRESHOLD_1 * scoreLimit )
	int scoreRemainingToStartMusic = scoreLimit - scoreAtFirstThreshold

	return scoreRemainingToStartMusic
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// OBJECTIVE PINGS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if CLIENT
// Determine if a comms action is related to a Treasure Hunt Objective Ping
bool function TreasureHunt_IsTreasureHuntObjectiveCommsAction( int commsAction, entity subjectEnt )
{
	bool isTreasureHuntObjectiveCommsAction = false

	if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_LOCKDOWN ) )
	{
		if ( commsAction == eCommsAction.PING_TREASUREHUNT_OBJ_ATTACK )
		{
			entity owner = subjectEnt.GetOwner()
			if ( IsValid( owner ) && IsPlayerWaypoint( owner ) && owner.GetWaypointType() == eWaypoint.TREASUREHUNT_OBJECTIVE )
				isTreasureHuntObjectiveCommsAction = true
		}
	}

	return isTreasureHuntObjectiveCommsAction
}
#endif // CLIENT

#if CLIENT || SERVER
// Grab the objective index from the objective waypoint
int function TreasureHunt_GetObjectiveIDFromWaypoint( entity waypoint )
{
	return waypoint.GetWaypointInt( CAPTURE_OBJ_WAYPOINT_INT_IDX_OBJ_INDEX )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Players are allowed to ping the traceblocker volume around the in world representation of the objective. But, we want these pings to be treated the same as an objective ping.
// This function takes the pinged traceblocker volume and returns the ping that belongs to the objective so we can ping that instead or it returns a null if something else got pinged.
// ToDo: R5DEV-567005 : Complete refactor to support Capture Objective Pings using Alliances
entity function TreasureHunt_GetStarterPingFromTraceBlockerPing( entity pingedEnt, int playerTeam )
{
	entity starterPing = null

	if ( IsValid( pingedEnt ) && pingedEnt.GetScriptName() == TREASUREHUNT_OBJECTIVE_SCRIPTNAME && IsValid( pingedEnt.GetOwner() ) )
	{
		array < entity > objectiveStarterPings = CaptureObjectivePing_GetStarterPingsArray()
		if ( objectiveStarterPings.len() > 0 )
		{
			entity objective = pingedEnt.GetOwner()

			foreach ( ping in objectiveStarterPings )
			{
				if ( !IsValid( ping ) )
					continue

				// Only look for pings that match the objective and player team
				if ( IsValid( ping ) && IsValid( ping.GetParent() ) && IsValid( ping.GetParent().GetOwner() ) )
				{
					entity pingedObjective = ping.GetParent().GetOwner()
					if ( pingedObjective == objective && playerTeam == ping.GetTeam() )
						starterPing = ping
				}
			}
		}
	}

	return starterPing
}
#endif // CLIENT || SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEBUG AND DEV COMMANDS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if DEVELOPER && SERVER
// Force all objectives to be completed
void function TreasureHunt_ForceCompleteAllObjectives_Dev()
{
	entity player = GetPlayerArray()[0]
	if ( IsValid( player ) )
	{
		printt( "LOCKDOWN: ", FUNC_NAME(), " Completing All Objectives" )
		foreach ( objective in file.allTreasureHuntObjectives )
		{
			if ( objective.isActive )
				TreasureHunt_ObjectiveCompleted( objective.trigger, player.GetTeam(), GetScoreToAwardForCaptureObjectiveCaptured(), eTreasureHuntMessageIndex.SCORE_OBJECTIVE_CAPTURED, [ player ], true )
		}
	}
	else
	{
		Warning( "LOCKDOWN: Tried to force complete all objectives using ", FUNC_NAME(), " but the player entity is not valid, nothing will happen" )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Stop objectives from triggering through normal logic and instead trigger the objective based on the index of objectives in the objective array
void function TreasureHunt_TriggerObjectiveUsingIndex_Dev( int index )
{
	if ( index < file.allTreasureHuntObjectives.len() )
	{
		TreasureHuntObjective objective = file.allTreasureHuntObjectives[ index ]

		if ( IsObjectiveAvailableToSpawn( objective, true ) )
		{
			printt( "LOCKDOWN: ", FUNC_NAME(), " Triggering an objective at index: ", index, " NOTE: This will stop objectives from triggering normally moving forward")
			svGlobal.levelEnt.Signal( "TreasureHunt_StopTriggeringObjectives" )
			file.forcedObjectiveIndex = index
			TimedEvents_TriggerTimedEventByEventType( eTreasureHuntTimedEventType.CAPTURE )
		}
		else
		{
			Warning( "LOCKDOWN: ", FUNC_NAME(), " Tried Triggering an objective at index: ", index, " but the objective is already active")
		}
	}
	else
	{
		Warning( "LOCKDOWN: Tried to trigger an objective using ", FUNC_NAME(), " but the index: ", index, " is too large, the highest available index is: ",  ( file.allTreasureHuntObjectives.len() - 1 ) )
	}
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
// Stop objectives from triggering through normal logic and instead trigger the objective closest to you
void function TreasureHunt_TriggerClosestObjective_Dev()
{
	entity player = GetPlayerArray()[0]
	if ( IsValid( player ) )
	{
		int closestObjectiveIndex = TreasureHunt_GetObjectiveToTriggerNearPlayer( player, true )

		if ( TreasureHunt_IsValidObjectiveIndex( closestObjectiveIndex ) )
		{
			printt( "LOCKDOWN: ", FUNC_NAME(), " found an objective to trigger near the player, it is objective index: ", closestObjectiveIndex, " going to trigger it using TreasureHunt_TriggerObjectiveUsingIndex_Dev" )
			TreasureHunt_TriggerObjectiveUsingIndex_Dev( closestObjectiveIndex )
		}
		else
		{
			Warning( "LOCKDOWN: Tried to force trigger an objective using ", FUNC_NAME(), " but couldn't find an objective that isn't already active" )
		}
	}
	else
	{
		Warning( "LOCKDOWN: Tried to force trigger an objective using ", FUNC_NAME(), " but the player entity is not valid, nothing will happen" )
	}
}
#endif // DEV && SERVER

                  
          
                                                                              
                                                                                  
 
                    
  
                                                                        
                                                                                            
  
     
  
                                                                                                                                                                                                                             
  
 
                 
                        

                  
          
                                                          
                                                                          
 
                    
  
                                                            
                                  
   
                                                                          
                                                                                    
   
      
   
                                                                                                                                                                                                                                                        
   
  
     
  
                                                                                                                                                                                                                    
  
 
                 
                        

       