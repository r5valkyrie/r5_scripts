// This is a collection of gamemode scripts to support the sharing of common logic between different modes
// Some features are big enough to warrant their own files ( like the alliance proximity system or the loadout selection system).
// This file is for small features or support functions we can easily turn on and off with playlist vars
// Please leave function description comments next to global functions to make this script file easier for others to use

global function GamemodeUtility_Init
global function GamemodeUtility_RegisterNetworking
global function GamemodeUtility_IsJIPEnabledInPlaylist	// Check if Join In Progress is enabled through playlist vars
global function GamemodeUtility_GetMixtapeAbandonPenaltyActive
global function GamemodeUtility_ParseCircleString // circle as string -> array<float>.  Format: "<xcoord, ycoord, zcoord> radius"
global function GamemodeUtility_ParseVectorString // vector as string -> vector.  Format: "xcoord ycoord zcoord"
global function GamemodeUtility_ParseStringOfVectors // array of vectors as string -> array<vector>.  Format: "x1 y1 z1, x2 y2 z2, x3 y3 z3"
global function GamemodeUtility_GetKillReplayActive //Check kill replay in playlist
global function GamemodeUtility_GetIsTeamIndexValidPlayerTeam // Return whether the passed in team index is within the valid player team range for the mode

#if SERVER
global function GamemodeUtility_AddCallback_SetGamemodeWinnerFunction // Set the function that sets the winner in a mode. This is needed if you are adding a time limit for your mode
global function GamemodeUtility_SetJIPEnabled // Set Join In Progress to be enabled or disabled
global function GamemodeUtility_ShouldOverrideHealingOnFinisher // Use the playlist values for healing when a finisher is performed ( normally the functionality is behind a flagset and passive check and the value is hardcoded in OnSuccessfulSyncedMelee)
global function GamemodeUtility_GetPercentToSetHealthToOnFinisher // Get what health should be set to when overriding finisher healing
global function GamemodeUtility_GetPercentToSetShieldToOnFinisher // Get what shield should be set to when overriding finisher healing
global function GamemodeUtility_ShouldOverrideHealingOnRevived	// Use the playlist values for healing when a player is revived ( normally the values are hardcoded in Bleedout_PlayerAttemptRes )
global function GamemodeUtility_ShouldOverrideHealingOnRevivedAllowHealthLoss // When using the above logic to override healing on revive. Do we just top up the health values to the defined ones or do we completely override the values even if they are lower
global function GamemodeUtility_GetPercentToSetHealthToOnRevived // Get what health should be set to when overriding revive healing
global function GamemodeUtility_GetPercentToSetShieldToOnRevived // Get what shield should be set to when overriding revive healing
global function GamemodeUtility_HealPlayerHealthAndShieldsByPercentage // Heal a players Health and/or shields and then play VFX and SFX if desired
global function GamemodeUtility_HealPlayerByAmount // Heal a player by a set amount then play VFX and SFX if desired
global function GamemodeUtility_GamemodeSetWinnerCommon // Shared function for modes to do match end logic
global function GamemodeUtility_IsWinnerBeingDetermined // If GamemodeUtility_GamemodeSetWinnerCommon is being used, return if a winner is or already has been determined
global function GamemodeUtility_IncrementRoundScore //Increase a team's number of rounds won
global function GamemodeUtility_AreMultipleTeamsPopulated //Check if we have multiple teams still connected to the match
global function GamemodeUtility_IsPlayerJoiningAsJIP // Get whether a player is joining the match for the first time and will be treated as a join in progress player by the mode
global function GamemodeUtility_SetJIPPlayerIsWaitingForSpawnBonus // Used by modes to set when a JIP player has been granted first spawn bonuses if desired or spawned and the bool is no longer needed. Should only be used to set the value to true when absolutely necessary
global function GamemodeUtility_IsPlayerJIP // Check if this player joined the match late as a JIP player
global function GamemodeUtility_WasRevengeKill // Was the player that was killed someone that previously killed this killer?
global function GamemodeUtility_RemovePlayerFromRevengeKillList // Remove a player from the list that determines if a kill counts as a revenge kill ( GamemodeUtility_WasRevengeKill )
global function GamemodeUtility_DropLoot //Drop a players weapons, ordnance, or equipment
global function GamemodeUtility_SpawnDroppedAmmo // Drop Ammo
global function GamemodeUtility_GetPlayerArmorData // Get the data from the armor that the player has equipped
global function GamemodeUtility_SpawnArmor // Spawn armor from this source
global function GamemodeUtility_DestroyDeathboxOnDelay // Deletes a deathbox after a given duration. Waits to destroy if a player is using/in range of the Deathbox.
global function GamemodeUtility_SpawnBonusLoot // Spawns Bonus Loot when opening a lootbin.
global function GamemodeUtility_SpawnBonusLootOnPlayer // Spawn Bonus Loot on a player (current implementation is OnPlayerKilled)
global function GamemodeUtility_CheckForMidMatchLegendChange // This is normally done automatically, but can be used where needed, check if the player has changed legends mid match and update PIN Data
global function GamemodeUtility_ResetPlayer_Thread // Used to reset player states, destroy Ult and Tacticals etc to prepare players for a reset or redeploy
#endif // SERVER

#if CLIENT || SERVER
global function GamemodeUtility_GetTeamOrAllianceScore // Get the score of the passed in team or alliance. The function does the team vs alliance checks for you
global function GamemodeUtility_GetAllianceScoreFromTeam // Get the alliance score from the passed in team
global function GamemodeUtility_GetScoreDifference	// Get the difference in score between the highest scoring team or alliance ( team vs alliance checks done for you) and the lowest scoring team or alliance
global function GamemodeUtility_GetScoreDifferenceBetweenTeams	// Get the difference in score between the highest scoring team and the lowest scoring team
global function GamemodeUtility_GetWinningTeamOrAlliance	// Get the team or alliance with the highest score ( team vs alliance checks done for you)
global function GamemodeUtility_GetWinningAlliance	// Get the alliance with the highest score
global function GamemodeUtility_GetWinningTeamOrAllianceScore	// Get the score of the team or alliance that has the highest score ( team vs alliance checks done for you)
global function GamemodeUtility_GetAlliancesOrTeamsSortedByScore // Returns an array of teams or alliances ( depending on what the mode is using ) sorted by score
global function GamemodeUtility_GetAlliancesOrTeamsSortedByEliminationAndScore // Returns an array of teams or alliances ( depending on what the mode is using ) sorted by whether they are eliminated first and score second
global function GamemodeUtility_IsTeamOrAllianceEliminated // Returns whether the passed in team or alliance is eliminated ( based on the respawnstatus netvar being eRespawnStatus.PLAYER_ELIMINATED for any player in that team or alliance )
global function GamemodeUtility_IsJIPEnabled	// Check if Join In Progress is enabled ( playlist and convar )
global function GamemodeUtility_IsJIPPlayerSpawnBonusPending // Get whether this JIP player is waiting to receive whatever bonus the mode wants to award on first spawn
global function GamemodeUtility_IsPlayerAbandoning  //Check will a player get a penalty if they leave
global function GamemodeUtility_GetAbandonPenaltyLength //How long will a player be penalized
global function GamemodeUtility_AddCallback_OnPlayerJoinedMatchInProgress // Triggers for players that have joined as a JIP player for the first time in a match
global function GamemodeUtility_GetMatchTimeLimit // Get the time limit set for this mode through playlist vars
global function GamemodeUtility_GetMatchTimeLimitWarning // Get the match time remaining warning for this mode through playlist vars
global function GamemodeUtility_GetMaxPlayersToShowOnPodium // Get max number of players to show on the start/end podium sequences
global function GamemodeUtility_IsSpectatorEnabled // Get whether to enable spectate from playlist
global function GamemodeUtility_IsPlacementPopupEnabled // Get whether placement popup text is enabled from playlist
#endif // CLIENT || SERVER

#if CLIENT
global function GamemodeUtility_ServerCallback_DisplayMatchTimeLimitWarning	// Callback on the Client triggered by the Server to display a warning message when the match time limit is nearing and when it is reached
global function GamemodeUtility_ServerCallback_PlayMatchEndingCountdownAudio // Callback on the Clien triggered by the Server to play a countdown audio near the end of the match
global function GamemodeUtility_AnnouncementMessageWarning	// Function used to display warning messages on the top center of the screen
global function GamemodeUtility_GetColorVectorForCaptureObjectiveState	// Get colors that respect color blind settings used for different capture objective states ( used for modes like Control and Winter Express )
global function GamemodeUtility_IsPlayerOnTeamObserver	// Return whether the player is on the Observer Team
global function GamemodeUtility_GetLocalTeamPlayers // Get an array of players that is on the local players team/alliance or the enemy team/alliance. Adjusts for Observers ( assigns them to a team )
global function GamemodeUtility_ServerCallback_PlayerJoinedMatchInProgress // Play SFX or do other events on the Client when a player has joined as a join in progress player
global function GamemodeUtility_ServerCallback_TriggerScanOfVictimTeam // Server to Client call to trigger a scan showing the locations of all the players in the team of a player that got killed or knocked
#endif // CLIENT

#if UI
global function GamemodeUtility_GetPlaylist	// Return the current playlist name, adjusted for modes to take into account being in the mode or in the lobby ( usually used to get values for the About screen )
#endif // UI

#if DEV && SERVER
// Dev Commands for Testing
global function GamemodeUtility_DebugDrawCullingCircle_Dev	// Dev testing function that draws an in world red circle that shows the boundaries of the entity culling circle
global function GamemodeUtility_DisableMatchTimeLimit_Dev	// Dev testing function that disables the match time limit so matches can go on until score limit is reached
#endif // DEV && SERVER

const float UNSET_PLAYLIST_VAR_FLOAT = -1
const int UNSET_PLAYLIST_VAR_INT = -1
global const int EXPECTED_PARSED_CIRCLE_VALUE_COUNT = 4

#if SERVER
global const string GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME = "Gamemode_WinnerDetermined"
// Healing VFX and SFX
const float HEALING_VFX_DURATION = 0.5
const string HEAL_START_FP = "CampFire_Healing_Start_1P"
const string HEAL_START_3P = "CampFire_Healing_Start_3P"
const asset FX_HEAL_HEALED_3P = $"P_heal_3p_loop"
const asset FX_HEAL_HEALED_FP = $"P_heal_loop_screen"

const float LOOTBIN_SPAWN_TIME = 0.65

// LEGEND_REALM and SHADOW_REALM are engine-native constants
#endif // SERVER

#if CLIENT || SERVER
const float GAMEMODEUTILITY_DEFAULT_MESSAGE_DURATION = 5.0 // How long are UI messages normally displayed for
const float GAMEMODEUTILITY_MATCH_TIME_LIMIT_WARNING_TIME = 300.0 // Time before the match time limit at which we show a warning message
const string GAMEMODEUTILITY_NETVAR_MATCH_START = "matchStartTime"
const string GAMEMODEUTILITY_NETVAR_MATCH_END = "matchEndTime"
const int GAMEMODEUTILITY_FINAL_COUNTDOWN_DURATION = 10
const string GAMEMODEUTILITY_FINAL_COUNTDOWN_SFX = "FreeDM_UI_InGame_Timer_10Seconds_1P"
#endif // CLIENT || SERVER

#if CLIENT
const string SFX_MATCH_TIME_LIMIT = "Ctrl_Match_End_Warning_1p"	// SFX used when the Match Time Limit warnings display
const string SFX_JOIN_MATCH_IN_PROGRESS = "Ctrl_New_Player_Joined" // SFX used when a Player joined a match in progress
#endif // CLIENT

#if CLIENT
// Capture Objective States used to get colors that correspond to these states
global enum eGamemodeUtilityCaptureObjectiveColorState
{
	NEUTRAL,
	CONTESTED,
	FRIENDLY_OWNED,
	ENEMY_OWNED
}
#endif // CLIENT

#if SERVER
struct weaponInfoStruct
{
	string weaponRef = ""
	array< string > modRefs = []
}
#endif // SERVER

struct {
	#if SERVER
	void functionref( int, int ) gamemodeSetWinnerFunction	// The Set Winner function set here by the gamemodes Init function

	// PinData
	table< entity, string > playerToLastUsedLegendClass // Track the last used Legend so we know when the player changes Legends to update PIN Data

	// Set Winner Logic
	bool isWinnerBeingDetermined = false // Are we already running the Set Winner function

	// Join in progress Logic
	bool isMatchInJIPState = false // Should players connecting to the match be considered join in progress players at this point
	array<entity> jipPlayersArray // Keep track of players that joined the match while it was in progress

	// VFX
	bool didPrecacheHealFX = false

	#endif // SERVER

	#if CLIENT
		bool isLoweringDVSForGamemode = false // Track whether we are running special logic to force specific lowered DVS settings
	#endif // CLIENT

	#if SERVER || CLIENT
		array< void functionref( entity ) > onPlayerJoinedMatchInProgressCallbackFuncs // An Array of callback functions to trigger when a player joins a match as a JIP player for the first time
	#endif // SERVER || CLIENT
} file

void function GamemodeUtility_Init()
{
	#if DEV && SERVER
		AddCallback_GeneratePDef( GenerateMixtapeAbandon_PDef )
	#endif // DEV && SERVER

	#if SERVER
		if ( GamemodeUtility_GetIsUsingCullCircleEnts() )
			GamemodeUtility_SetCircleCullEnts()

		RegisterSignal( GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )
		AddCallback_GameStateEnter( eGameState.Playing, GamemodeUtility_OnGameStatePlaying )
		AddCallback_OnPlayerRespawned( GamemodeUtility_OnPlayerRespawned )
		if ( GamemodeUtility_IsJIPEnabledInPlaylist() )
			thread GamemodeUtility_ManageJIPAvailability_Thread()

		AddCallback_OnPlayerKilled( GamemodeUtility_OnPlayerKilled )

		if ( GamemodeUtility_GetPercentToSetHealthToOnKill() > 0 || GamemodeUtility_GetPercentToSetShieldToOnKill() > 0 )
			AddCallback_OnPlayerKilled( GamemodeUtility_OnPlayerKilled_HealOnKill )

		AddCallback_OnClientConnected( GamemodeUtility_OnPlayerConnected )

		if ( Bleedout_GetIsBleedoutDamageBlocked() )
			BleedoutState_AddCallback_OnPlayerBleedoutStateChanged( GamemodeUtility_OnBleedoutStateChanged )
		
		// If we are going to be overriding healing for finishers or revives we need to precache the vfx that will be used
		if ( GamemodeUtility_ShouldOverrideHealingOnFinisher() || GamemodeUtility_ShouldOverrideHealingOnRevived() )
		{
			PrecacheParticleSystem( FX_HEAL_HEALED_3P )
			PrecacheParticleSystem( FX_HEAL_HEALED_FP )
			file.didPrecacheHealFX = true
		}
	                      
		if ( GamemodeUtility_GetMixtapeAbandonPenaltyActive() )
		{
			SetAbandonCheckFunc( GamemodeUtility_IsPlayerAbandoning )
			MatchBehaviorPlayer_AddEndedCallback( GamemodeUtility_OnMatchBehaviorEndHandlePlayerAbandon)
		}
                                 

		if ( GamemodeUtility_ShouldPingVictimSquadLocationOnDown() )
			Bleedout_AddCallback_OnPlayerStartBleedout( GamemodeUtility_PingVictimSquadMapLocationOnPlayerDowned )

		if ( GamemodeUtility_ShouldPingVictimSquadLocationOnKill() )
			AddCallback_OnPlayerKilled( GamemodeUtility_PingVictimSquadMapLocationOnPlayerKilled )

		// If we guarantee a min loadout for the player on spawn or respawn, go through and update their equipment if the min guaranteed equipment is better than what they are spawning with
		if ( GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout() )
			AddCallback_OnPlayerPostRespawned( GamemodeUtility_GivePlayerMinGuaranteedLoadout_OnPostRespawned )
	#endif // SERVER

	#if CLIENT
	if ( GamemodeUtility_GetShouldTweakDVSForGamemode() )
		AddCreateCallback( "player", GamemodeUtility_OnPlayerCreated_DVSCallback_Client ) // Only used for managing DVS overrides when the local Client Player gets created

	if ( GamemodeUtility_ShouldPingVictimSquadLocationOnDown() || GamemodeUtility_ShouldPingVictimSquadLocationOnKill() )
		RegisterSignal( "StartedVictimSquadMapScan" )
	#endif

	#if DEV && SERVER
		RegisterSignal( "GamemodeUtility_DisableMatchTimeLimit" )
	#endif // DEV && SERVER
}

void function GamemodeUtility_RegisterNetworking()
{
	#if CLIENT || SERVER
		RegisterNetworkedVariable( GAMEMODEUTILITY_NETVAR_MATCH_START, SNDC_GLOBAL, SNVT_TIME, -1.0 ) // SNDC_GLOBAL_NON_REWIND
		RegisterNetworkedVariable( GAMEMODEUTILITY_NETVAR_MATCH_END, SNDC_GLOBAL, SNVT_TIME, 0.0 ) // SNDC_GLOBAL_NON_REWIND
	#endif

	Remote_RegisterClientFunction( "GamemodeUtility_ServerCallback_DisplayMatchTimeLimitWarning", "bool" )
	Remote_RegisterClientFunction( "GamemodeUtility_ServerCallback_PlayMatchEndingCountdownAudio" )
	RegisterNetworkedVariable( "mixtape_isLeaverPenaltyEnabledForMatch", SNDC_GLOBAL, SNVT_BOOL, true )

	#if CLIENT
		RegisterNetVarBoolChangeCallback( "mixtape_isLeaverPenaltyEnabledForMatch", SNDC_GLOBAL, GamemodeUtility_OnLeaverPenaltyStatusChanged )
		RegisterNetVarTimeChangeCallback( GAMEMODEUTILITY_NETVAR_MATCH_START, SNDC_GLOBAL, GamemodeUtility_OnMatchStartTimeChanged )
		RegisterNetVarTimeChangeCallback( GAMEMODEUTILITY_NETVAR_MATCH_END, SNDC_GLOBAL, GamemodeUtility_OnMatchEndTimeChanged )
	#endif // CLIENT

#if CLIENT || SERVER
	// Used for Pin Data in non elimination modes
	if ( !IsEliminationBased() )
		RegisterNetworkedVariable( "deaths", SNDC_PLAYER_GLOBAL, SNVT_INT, 0 )

	// Leaver penalty tracking — did this player ever have a full team
	RegisterNetworkedVariable( "rankedDidPlayerEverHaveAFullTeam", SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )

#endif // CLIENT || SERVER

	// Manage JIP player logic ( first spawn, end of game )
	if ( GamemodeUtility_IsJIPEnabledInPlaylist() )
	{
		#if CLIENT || SERVER
			RegisterNetworkedVariable( "GamemodeUtility_HasJIPPlayerReceivedSpawnBonus", SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, false )
		#endif // CLIENT || SERVER
		Remote_RegisterClientFunction( "GamemodeUtility_ServerCallback_PlayerJoinedMatchInProgress", "entity" )
	}

	if ( GamemodeUtility_ShouldPingVictimSquadLocationOnDown() || GamemodeUtility_ShouldPingVictimSquadLocationOnKill() )
		Remote_RegisterClientFunction( "GamemodeUtility_ServerCallback_TriggerScanOfVictimTeam", "int", 0, TEAM_MULTITEAM_FIRST + MAX_TEAMS + 1 )
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Playlist Var Get Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if SERVER
// Get whether the mode is using an entity culling circle or not
bool function GamemodeUtility_GetIsUsingCullCircleEnts()
{
	return GetCurrentPlaylistVarBool( "is_using_cull_circle_ents", false )
}
#endif // SERVER

#if SERVER || CLIENT
bool function GamemodeUtility_IsJIPEnabled()
{
	return GetConVarBool( "match_jip" ) && GamemodeUtility_IsJIPEnabledInPlaylist() && GetGameState() < eGameState.Resolution
}
#endif // SERVER || CLIENT

// Is Join In Progress Enabled through playlist vars
bool function GamemodeUtility_IsJIPEnabledInPlaylist()
{
	return GetCurrentPlaylistVarBool( "match_jip", false )
}

// Should we be force setting DVS settings for the gamemode ( note this should only be enabled if a call has been made for this mode specifically with the mode performance group aka don't set this true unless you know what it does )
bool function GamemodeUtility_GetShouldTweakDVSForGamemode()
{
	return GetCurrentPlaylistVarBool( "should_tweak_dvs_for_gamemode", false )
}

#if SERVER
// Get the maximum score difference between teams before we block Join In Progress, we don't do this check if the difference is set to -1
int function GamemodeUtility_GetMaxScoreDifferenceBeforeDisableJIP()
{
	return GetCurrentPlaylistVarInt( "max_score_difference_for_jip", UNSET_PLAYLIST_VAR_INT )
}
#endif // SERVER

#if SERVER
// Get the minimum time we wait after turning on Join In Progress, before we turn it off
float function GamemodeUtility_GetMinJIPActiveTime()
{
	return GetCurrentPlaylistVarFloat( "min_jip_time", UNSET_PLAYLIST_VAR_FLOAT )
}
#endif // SERVER

#if SERVER
// Get the maximum score before we block Join In Progress, we don't do this check if the max is set to -1
int function GamemodeUtility_GetMaxScoreBeforeDisableJIP()
{
	return GetCurrentPlaylistVarInt( "max_score_for_jip", UNSET_PLAYLIST_VAR_INT )
}
#endif // SERVER

#if SERVER
// Get the maximum number of rounds played in a round based mode before we block Join In Progress, we don't do this check if the max is set to -1
int function GamemodeUtility_GetMaxRoundsPlayedBeforeDisableJIP()
{
	return GetCurrentPlaylistVarInt( "max_rounds_played_for_jip", UNSET_PLAYLIST_VAR_INT )
}
#endif // SERVER

#if SERVER
// Get the maximum time remaining in the match before we disable Join In Progress in modes that have a set time limit, we don't do this check if the max is set to -1 or there is no time limit set on the mode.
float function GamemodeUtility_GetMaxTimeRemaningBeforeDisableJIP()
{
	return GetCurrentPlaylistVarFloat( "max_time_remaining_for_jip", UNSET_PLAYLIST_VAR_FLOAT )
}
#endif // SERVER

#if SERVER
// Get how long we wait after gamestate playing before we consider newly connected players join in progress players
float function GamemodeUtility_GetMatchJIPStateDelay()
{
	return GetCurrentPlaylistVarFloat( "match_jip_state_delay", 0.0 )
}
#endif // SERVER

#if SERVER
// Get how much XP we award the player for completing a match
float function GamemodeUtility_GetXPToAwardOnMatchCompleted()
{
	return GetCurrentPlaylistVarFloat( "xp_match_completed_amount", 0.0 )
}
#endif // SERVER

#if SERVER
// Get how much XP we award the player for completing a match after having joined the match while it was already in progress
float function GamemodeUtility_GetXPToAwardOnJoinInProgressMatchCompleted()
{
	return GetCurrentPlaylistVarFloat( "xp_match_completed_joined_in_progress_amount", 0.0 )
}
#endif // SERVER


#if SERVER || CLIENT
// This function allows us to get a custom maximum match length through playlist vars.
float function GamemodeUtility_GetMatchTimeLimit()
{
	float matchTimeLimit = GetCurrentPlaylistVarFloat( "match_time_limit", UNSET_PLAYLIST_VAR_FLOAT ) // match time limit disabled by default

	#if DEV
		printt( "GAMEMODE UTILITY: Grabbing the match time limit playlist var: match_time_limit. It is returning: " + matchTimeLimit )
	#endif // DEV

	return matchTimeLimit
}

// This function allows us to get a custom match time remaining warning through playlist vars
float function GamemodeUtility_GetMatchTimeLimitWarning()
{
	return GetCurrentPlaylistVarFloat ( "match_time_remaining_warning", GAMEMODEUTILITY_MATCH_TIME_LIMIT_WARNING_TIME )
}

int function GamemodeUtility_GetMaxPlayersToShowOnPodium()
{
	return GetCurrentPlaylistVarInt( "podium_max_players_to_show", 3 ) // S22: GetExpectedSquadSize() takes no args, S3 requires player param
}

bool function GamemodeUtility_IsSpectatorEnabled()
{
	return GetCurrentPlaylistVarBool( "spectator_enabled", true )
}

bool function GamemodeUtility_IsPlacementPopupEnabled()
{
	return GetCurrentPlaylistVarBool( "placement_popup", false )
}
#endif // SERVER || CLIENT

#if SERVER
bool function GamemodeUtility_ShouldOverrideHealingOnFinisher()
{
	return GetCurrentPlaylistVarBool( "override_healing_values_on_finisher", false )
}
#endif //SERVER

#if SERVER
// Note this value is only respected if GamemodeUtility_ShouldOverrideHealingOnFinisher is true
float function GamemodeUtility_GetPercentToSetHealthToOnFinisher()
{
	return GetCurrentPlaylistVarFloat( "percent_to_set_health_to_on_finisher", 0.0 )
}
#endif //SERVER

#if SERVER
// Note this value is only respected if GamemodeUtility_ShouldOverrideHealingOnFinisher is true
float function GamemodeUtility_GetPercentToSetShieldToOnFinisher()
{
	return GetCurrentPlaylistVarFloat( "percent_to_set_shields_to_on_finisher", 0.0 )
}
#endif //SERVER

#if SERVER
bool function GamemodeUtility_ShouldOverrideHealingOnRevived()
{
	return GetCurrentPlaylistVarBool( "override_healing_values_on_revived", false )
}
#endif //SERVER

#if SERVER
// When we override healing on revive do we only top up the health that was set by the other systems ( if false ) or do we set the health to the defined values even if it is lower ( if true )
bool function GamemodeUtility_ShouldOverrideHealingOnRevivedAllowHealthLoss()
{
	return GetCurrentPlaylistVarBool( "override_healing_allows_health_loss", false )
}
#endif //SERVER

#if SERVER
// Note this value is only respected if GamemodeUtility_ShouldOverrideHealingOnRevived is true
float function GamemodeUtility_GetPercentToSetHealthToOnRevived()
{
	return GetCurrentPlaylistVarFloat( "percent_to_set_health_to_on_revived", 0.0 )
}
#endif //SERVER

#if SERVER
// Note this value is only respected if GamemodeUtility_ShouldOverrideHealingOnRevived is true
float function GamemodeUtility_GetPercentToSetShieldToOnRevived()
{
	return GetCurrentPlaylistVarFloat( "percent_to_set_shields_to_on_revived", 0.0 )
}
#endif //SERVER

#if SERVER
// If greater than 0, what should we set a players health to when they get a kill
// Note, we will not lower health, we only set to this value if it would result in a heal
float function GamemodeUtility_GetPercentToSetHealthToOnKill()
{
	return GetCurrentPlaylistVarFloat( "percent_to_set_health_to_on_kill", 0.0 )
}
#endif //SERVER

#if SERVER
// If greater than 0, what should we set a players shield to when they get a kill
// Note, we will not lower shield, we only set to this value if it would result in a heal
float function GamemodeUtility_GetPercentToSetShieldToOnKill()
{
	return GetCurrentPlaylistVarFloat( "percent_to_set_shields_to_on_kill", 0.0 )
}
#endif //SERVER

// When a player knocks a player. Should we show the location of the remaining members of the victim squad to the members of the attacker squad on the map?
bool function GamemodeUtility_ShouldPingVictimSquadLocationOnDown()
{
	return GetCurrentPlaylistVarBool( "map_ping_victim_squad_on_down", false )
}

// When a player kills a player. Should we show the location of the remaining members of the victim squad to the members of the attacker squad on the map?
bool function GamemodeUtility_ShouldPingVictimSquadLocationOnKill()
{
	return GetCurrentPlaylistVarBool( "map_ping_victim_squad_on_kill", false )
}

// If we show the location of the victim squad on death or knock, how long is the location pinged for before it fades away
float function GamemodeUtility_GetDurationOfVictimSquadMapPing()
{
	return GetCurrentPlaylistVarFloat( "victim_squad_map_ping_duration", 0.0 )
}

#if SERVER
// If the player is invulnerable during bleedout ( Bleedout_GetIsBleedoutDamageBlocked ), what is the transparency value to be applied to the bleeding out player
int function GamemodeUtility_GetTransparencyAmountForInvulnerableBleedout()
{
	return GetCurrentPlaylistVarInt( "invulnerable_bleedout_transparency_amount", 140 )
}
#endif //SERVER

bool function GamemodeUtility_GetKillReplayActive()
{
	return GetCurrentPlaylistVarBool( "killreplay_enabled", false )
}

#if SERVER
// If true, we compare the gear, weapons, and consumables that the player is spawning with and replace them with the defined gear if the defined gear is of greater quality or quantity
bool function GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout()
{
	return GetCurrentPlaylistVarBool( "is_using_min_guaranteed_loadout", false )
}
#endif //SERVER

#if SERVER
// If GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout() is true, this is the min guranteed weapon loadout string for the specified ring stage
// If the player has better weapons they keep theirs, otherwise these weapons will be given instead
string function GamemodeUtility_GetMinGuaranteedWeaponLoadoutStringForRingStage( int ringStage )
{
	return GetCurrentPlaylistVarString( "min_guaranteed_weaponloadout_ring_" + ringStage, "" )
}
#endif //SERVER

#if SERVER
// If GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout() is true, this is the min guranteed equipment loadout string for the specified ring stage
// If the player has better equipment they keep theirs, otherwise this equipment will be given instead
string function GamemodeUtility_GetMinGuaranteedEquipmentLoadoutStringForRingStage( int ringStage )
{
	return GetCurrentPlaylistVarString( "min_guaranteed_equipmentloadout_ring_" + ringStage, "" )
}
#endif //SERVER

#if SERVER
// If GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout() is true, this is the min guranteed consumable loadout string for the specified ring stage
// If the player has better consumables they keep theirs, otherwise this equipment will be given instead
string function GamemodeUtility_GetMinGuaranteedConsumableLoadoutStringForRingStage( int ringStage )
{
	return GetCurrentPlaylistVarString( "min_guaranteed_consumableloadout_ring_" + ringStage, "" )
}
#endif //SERVER

#if SERVER
// If GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout() is true, this is the amount of ammo to give for each weapon for the specified ring stage
// If the player has more ammo they keep theirs, otherwise this ammo will be given
int function GamemodeUtility_GetMinGuaranteedAmmoCountPerWeaponForRingStage( int ringStage )
{
	return GetCurrentPlaylistVarInt( "min_guaranteed_ammocount_ring_" + ringStage, 0 )
}
#endif //SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Set Override Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if SERVER
// Store a callback function for the mode to use to Set the Winner in the Match Time Limit function ( or any other game ending future functions)
void function GamemodeUtility_AddCallback_SetGamemodeWinnerFunction( void functionref( int, int ) func )
{
	file.gamemodeSetWinnerFunction = func
}
#endif // SERVER

#if SERVER || CLIENT
// Store an array of callback functions that will trigger when a player joins a match that is already in progress for the first time
void function GamemodeUtility_AddCallback_OnPlayerJoinedMatchInProgress( void functionref( entity ) func )
{
	Assert( !file.onPlayerJoinedMatchInProgressCallbackFuncs.contains( func ), "GAMEMODE UTILITY: Already added " + string( func ) + " to onPlayerJoinedMatchInProgressCallbackFuncs" )
	file.onPlayerJoinedMatchInProgressCallbackFuncs.append( func )
}
#endif // SERVER || CLIENT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Callback Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if SERVER
void function GamemodeUtility_OnGameStatePlaying()
{
	// Start a time limit thread if the mode has a hard time limit
	float matchTimeLimit = GamemodeUtility_GetMatchTimeLimit()
	if ( matchTimeLimit > 0.0 )
		thread GamemodeUtility_MatchTimeLimit_Thread( matchTimeLimit )

	// Set when the match is in a state where newly connected players are considered to be joining a match in progress
	if ( GamemodeUtility_IsJIPEnabledInPlaylist() )
		thread GamemodeUtility_SetMatchJIPState_Thread()
}
#endif // SERVER

#if SERVER
// Callback when a player is respawned
void function GamemodeUtility_OnPlayerRespawned( entity player )
{
	if ( !IsValid( player ) )
		return

	// If this is a mode that allows players to change characters mid match, update PIN data when character changes occur
	if ( IsCharacterReselectEnabled() )
		GamemodeUtility_CheckForMidMatchLegendChange( player )
}
#endif // SERVER

#if SERVER
// Callback when a player is killed
void function GamemodeUtility_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	// Non Elimination modes set deaths on a NetInt for Pin Data
	if ( !IsEliminationBased() && IsValid( victim ) )
		victim.SetPlayerNetInt( "deaths", victim.GetPlayerNetInt( "deaths" ) + 1 )
}
#endif // SERVER

#if SERVER
// Heal the attacker when they kill someone when heal on kill logic is enabled
void function GamemodeUtility_OnPlayerKilled_HealOnKill( entity victim, entity attacker, var damageInfo )
{
	// Check if we should be healing the attacker
	if ( IsValid( attacker ) && IsValid( victim ) && attacker != victim && attacker.IsPlayer() && IsAlive( attacker ) )
	{
		// Final check to make sure attacker is not related to the victim in any way
		int attackerTeam = attacker.GetTeam()
		int victimTeam = victim.GetTeam()
		if ( !IsFriendlyTeam( attackerTeam, victimTeam ) )
			GamemodeUtility_HealPlayerHealthAndShieldsByPercentage( attacker, GamemodeUtility_GetPercentToSetHealthToOnKill(), GamemodeUtility_GetPercentToSetShieldToOnKill(), false, true )
	}
}
#endif // SERVER

#if SERVER
// Callback when a player connects to the match
void function GamemodeUtility_OnPlayerConnected( entity player )
{
	//Put join in progress players into an array tracking them for post match XP Rewards. Also set the NetBool that determines the players spawn flow
	if ( GamemodeUtility_IsPlayerJoiningAsJIP( player ) )
	{
		printt( "GAMEMODE UTILITY: player: " + player + " joined a match in progress" )

		file.jipPlayersArray.append( player )
		player.SetPlayerNetBool( "GamemodeUtility_HasJIPPlayerReceivedSpawnBonus", true )
		array < entity > allPlayersArray = GetPlayerArray()

		foreach ( arrayPlayer in allPlayersArray )
		{
			if ( IsValid( arrayPlayer ) )
				Remote_CallFunction_QueueForNoKillCam( arrayPlayer, "GamemodeUtility_ServerCallback_PlayerJoinedMatchInProgress", player )
		}

		// Trigger callbacks for player joining match in progress
		foreach( playerJoinedMatchInProgressFunc in file.onPlayerJoinedMatchInProgressCallbackFuncs )
		{
			playerJoinedMatchInProgressFunc( player )
		}
	}
}
#endif // SERVER

#if CLIENT
// Callback for when a player is created on the Client, used for DVS overrides
void function GamemodeUtility_OnPlayerCreated_DVSCallback_Client( entity player )
{
	// Run a thread to enable DVS tweak for the gamemode when players land from skydive if we do DVS tweaks in the mode ( done for performance reasons )
	if ( GetGameState() <= eGameState.Playing )
	{
		entity localClientPlayer = GetLocalClientPlayer()

		if ( IsValid( player ) && IsValid( localClientPlayer ) && player == GetLocalClientPlayer() )
			thread GamemodeUtility_ManageDVSTweakOnPlayer_Thread()
	}
}
#endif

#if SERVER
// Callback for when a player enters or leaves the bleedout state. Used to block damage on the player
void function GamemodeUtility_OnBleedoutStateChanged(entity player, int newState)
{
	if ( !IsValid( player ) )
		return

	if ( newState == BS_ENTERING_BLEEDOUT )
	{
		player.SetInvulnerable()
		thread GamemodeUtility_StartKnockdownInvulnerabilityFX_Thread(player)
	}

	if ( newState == BS_NOT_BLEEDING_OUT )
	{
		player.ClearInvulnerable()
		GamemodeUtility_StopKnockdownInvulnerabilityFX(player)
	}
}
#endif //SERVER

#if SERVER
// Make bleeding out players that are invulnerable look transparent
void function GamemodeUtility_StartKnockdownInvulnerabilityFX_Thread(entity player)
{
	float fadeStartTime = Time()
	float fadeEndTime = fadeStartTime + 0.4
	player.kv.rendermode = 4 //Rendmode TransAlpha
	int alphaAmount = GamemodeUtility_GetTransparencyAmountForInvulnerableBleedout()
	while ( ( Time() <= fadeEndTime ) && IsValid( player ) )
	{
		float alphaResult = GraphCapped( Time(), fadeStartTime, fadeEndTime, 255, alphaAmount )
		player.kv.renderamt = alphaResult
		WaitFrame()
	}
}
#endif //SERVER

#if SERVER
// Once a player is no longer bleeding out ( and invulnerable ), turn off the invulnerability vfx
void function GamemodeUtility_StopKnockdownInvulnerabilityFX( entity player )
{
	player.kv.rendermode = 0
}
#endif //SERVER

#if CLIENT
// Client function that triggers when the mixtape_NoPenaltyForLeaving NetVarBool changes.
// Currently used to display an Obituary message when the leaver penalty is no longer active for a match
void function GamemodeUtility_OnLeaverPenaltyStatusChanged( entity player, bool newValue, bool oldValue, bool didChange )
{
	if ( !newValue )
		Obituary_Print_Localized( Localize( "#GAMEMODES_LEAVER_PENALTY_DEACTIVATED" ).toupper() )
}
#endif //CLIENT

#if SERVER
// When a player downs a player. Show the location of the remaining members of the victims squad to the attackers squad on the map
void function GamemodeUtility_PingVictimSquadMapLocationOnPlayerDowned( entity player, entity attacker, var attackerDamageInfo )
{
	GamemodeUtility_PingVictimSquadMapLocation( player, attacker )
}
#endif //SERVER

#if SERVER
// When a player kills a player. Show the location of the remaining members of the victims squad to the attackers squad on the map
void function GamemodeUtility_PingVictimSquadMapLocationOnPlayerKilled( entity player, entity attacker, var attackerDamageInfo )
{
	GamemodeUtility_PingVictimSquadMapLocation( player, attacker )
}
#endif //SERVER

#if SERVER
// When a player kills or downs a player. Show the location of the remaining members of the victims squad to the attackers squad on the map
void function GamemodeUtility_PingVictimSquadMapLocation( entity player, entity attacker )
{
	if ( !IsValid( player ) || !IsValid( attacker ) )
		return

	int victimTeam = player.GetTeam()
	array < entity > victimTeamPlayersArray = GetPlayerArrayOfTeam_Alive( victimTeam )

	// Let the living players on the victim team know that they have been scanned, also count how many of these players there are to determine if we should even do the scan
	int victimsToScanCount = 0
	foreach ( victimTeamPlayer in victimTeamPlayersArray )
	{
		if ( IsValid( victimTeamPlayer ) && !Bleedout_IsBleedingOut( victimTeamPlayer ) )
		{
			victimsToScanCount++
		}
	}

	// Only proceed if there are still living victim players not bleeding out
	if ( victimsToScanCount > 0 )
	{
		int attackerTeam = attacker.GetTeam()
		// Show the locations of the remaining living players on the victim team on the map of all the players on the attacker team
		array < entity > attackerTeamPlayersArray = GetPlayerArrayOfTeam_Alive( attackerTeam )
		foreach ( attackerTeamPlayer in attackerTeamPlayersArray )
		{
			if ( IsValid( attackerTeamPlayer ) )
				Remote_CallFunction_NonReplay( attackerTeamPlayer, "GamemodeUtility_ServerCallback_TriggerScanOfVictimTeam", victimTeam )
		}
	}
}
#endif //SERVER

#if CLIENT
// Trigger Showing enemies on the minimap for the local player
void function GamemodeUtility_ServerCallback_TriggerScanOfVictimTeam( int victimTeam )
{
	// Ensure the validity of the team variable being passed in
	if ( GetAllTeams().contains( victimTeam ) )
		thread RunVictimSquadMapScan_Thread( victimTeam )
}
#endif // CLIENT

#if CLIENT
// Show the remaining members of the victim team on the minimap for the local player
const float POST_PULSE_WAIT = 1.0 // First we show a pulse on the map, then we wait this long before showing the enemy locations
const float SCAN_FADE_DURATION = 1.5
void function RunVictimSquadMapScan_Thread( int victimTeam )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )

	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) || !IsAlive( localPlayer ) )
		return

	// Kill an old thread if it is already running for the player
	localPlayer.Signal( "StartedVictimSquadMapScan" )

	EndSignal( localPlayer, "OnDestroy", "OnDeath", "StartedVictimSquadMapScan" )

	array<var> fullMapRuis
	array<var> minimapRuis

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
		}
	)

	float scanDuration = GamemodeUtility_GetDurationOfVictimSquadMapPing()
	if ( scanDuration > 0.0 )
	{
		// Show a pulse on the map
		vector pulseOrigin = localPlayer.GetOrigin()
		FullMap_PlayCryptoPulseSequence( pulseOrigin, true, scanDuration + POST_PULSE_WAIT )

		// Wait a little before showing the victim locations on the map
		wait POST_PULSE_WAIT

		// Get an array of the players we are going to scan
		int team = localPlayer.GetTeam()
		array< entity > livingVictimsArray = GetPlayerArrayOfTeam_Alive( victimTeam )
		array< entity > scanEntsArray
		// Don't want to show bleeding out players on the scan
		foreach ( victim in livingVictimsArray )
		{
			if ( !Bleedout_IsBleedingOut( victim ) )
				scanEntsArray.append( victim )
		}

		// Set time variables
		float startTime = Time()
		float totalScanDurationWithFadeOut = scanDuration + SCAN_FADE_DURATION
		float endTime = startTime + totalScanDurationWithFadeOut
		float timeToStartFade = startTime + scanDuration

		// Show the markers on the map
		foreach( entity victim in scanEntsArray )
		{
                        
                                       
             
         

			// Full map
			var fRui = FullMap_AddEnemyLocation( victim )
			fullMapRuis.append( fRui )

			// MiniMap
			var mRui = Minimap_AddEnemyToMinimap( victim )
			minimapRuis.append( mRui )
			RuiSetGameTime( mRui, "fadeStartTime", timeToStartFade )
			RuiSetGameTime( mRui, "fadeEndTime", endTime )
		}

		// Wait the lifetime of the markers
		wait totalScanDurationWithFadeOut
	}
}
#endif // CLIENT

#if SERVER
// If we guarantee a min loadout for the player on spawn or respawn, go through and update their equipment if the min guaranteed equipment is better than what they are spawning with
// NOTE: THIS FUNCTION ONLY RUNS IF GamemodeUtility_IsUsingMinGuaranteedSpawnLoadout() IS TRUE
void function GamemodeUtility_GivePlayerMinGuaranteedLoadout_OnPostRespawned( entity player )
{
	thread GivePlayerMinGuaranteedLoadout_Thread( player )
}
#endif //SERVER

#if SERVER
weaponInfoStruct function GetWeaponInfoFromLoadout( WeaponLoadout weapons, int weaponIndex )
{
	weaponInfoStruct weaponInfo

	string weaponRef = weapons.weaponRefs[ weaponIndex ]
	if ( SURVIVAL_Loot_IsRefValid( weaponRef ) )
	{
		weaponInfo.weaponRef = weaponRef
		weaponInfo.modRefs   = weapons.weaponAttachmentsByWeapon[ weaponRef ]

		// Ensure that if this is a tiered weapon we give the player the appropriate attachments
		if ( WeaponLootRefIsLockedSet( weaponRef ) && weaponInfo.modRefs.len() == 0 )
		{
			LootData weaponLootData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
			weaponInfo.modRefs = weaponLootData.baseMods
		}
	}

	return weaponInfo
}
#endif //SERVER

#if SERVER
bool function GetPlaylistVar_MinGuaranteedLoadout_ReplaceMythicWithMin()
{
	return GetCurrentPlaylistVarBool( "min_guaranteed_loadout_replace_mythic_with_min", false )
}
#endif //SERVER

#if SERVER
// This function is built for modes like 3 Strikes that have respawning in BR.
// We can define a min guaranteed loadout in playlist vars and then when the player is respawned we give them consumables, equipment, and weapons/weapon attachments from the min loadout if they are better than what the player has
const float SKYDIVE_AWARD_WEAPONS_DELAY = 1.5
const array< int > RESTORABLE_WEAPON_SLOTS = [ WEAPON_INVENTORY_SLOT_PRIMARY_0, WEAPON_INVENTORY_SLOT_PRIMARY_1 ]
const array< int > UPGRADEABLE_ATTACHMENT_TYPES = [ eWeaponAttachmentType.STOCK, eWeaponAttachmentType.MAG, eWeaponAttachmentType.BARREL, eWeaponAttachmentType.HOPUP]
const UNSET_LOOT_TIER = -1
const BASE_LOOT_TIER = 0
void function GivePlayerMinGuaranteedLoadout_Thread( entity player )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( GetGameState() != eGameState.Playing )
		return

	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy" )

	WaitFrame() // Need to wait for Survival respawn logic to finish up, it resets inventory and sets the player up to be in a good state to give weapons

	int currentRingStage = maxint( SURVIVAL_GetCurrentDeathFieldStage(), 0 ) // If the ring hasn't started moving, treat it as the first ring

	// Populate the min guaranteed loadouts for this ring stage
	WeaponLoadout minGuaranteedWeapons = ParseWeaponLoadoutText( GamemodeUtility_GetMinGuaranteedWeaponLoadoutStringForRingStage( currentRingStage ), false )
	array< string > minGuaranteedEquipment = ParseEquipmentLoadoutText( GamemodeUtility_GetMinGuaranteedEquipmentLoadoutStringForRingStage( currentRingStage ), false, [] )
	array< string > minGuaranteedConsumables = ParseConsumableLoadoutText( GamemodeUtility_GetMinGuaranteedConsumableLoadoutStringForRingStage( currentRingStage ), false )
	int minGuaranteedAmmoCountPerWeapon = GamemodeUtility_GetMinGuaranteedAmmoCountPerWeaponForRingStage( currentRingStage )

	// Populate Current Weapon Data
	array < entity > currentWeapons
	foreach( int weaponSlot in RESTORABLE_WEAPON_SLOTS )
	{
		entity weapon = player.GetNormalWeapon( weaponSlot )

		if ( IsValid( weapon ) )
			currentWeapons.append( weapon )
	}

	#if DEV
		{
			printt( "--------Loot Upgrade---------" )
			printt( "Min Weapons: " + GamemodeUtility_GetMinGuaranteedWeaponLoadoutStringForRingStage( currentRingStage ) )

			int weaponNumber = 0
			foreach ( weapon in currentWeapons )
			{
				string msg = "Current Weapon #" + weaponNumber + " - " + GetWeaponClassNameWithLockedSet( weapon ) + ", Attachments: "

				array < string > attachments = weapon.GetMods()
				foreach ( attachment in attachments )
				{
					msg += attachment + ", "
				}

				printt( msg )
				++weaponNumber
			}
		}
	#endif // DEV

	// Populate Current Equipment Data
	LootData currentHelmet = EquipmentSlot_GetEquippedLootDataForSlot( player, "helmet" )
	LootData currentBackpack = EquipmentSlot_GetEquippedLootDataForSlot( player, "backpack" )
	LootData currentIncapShield = EquipmentSlot_GetEquippedLootDataForSlot( player, "incapshield" )
	LootData currentSurvivalItem = EquipmentSlot_GetEquippedLootDataForSlot( player, "gadgetslot" )

	// Parse through the guaranteed consumable data to figure out what we will actually end up giving the player
	array< string > ordnanceToGive
	table < string, int > healingItemToNumToGiveTable
	foreach ( guaranteedConsumable in minGuaranteedConsumables )
	{
		if ( !SURVIVAL_Loot_IsRefValid( guaranteedConsumable ) )
			continue

		LootData guaranteedConsumableData = SURVIVAL_Loot_GetLootDataByRef( guaranteedConsumable )
		switch ( guaranteedConsumableData.lootType )
		{
			case eLootType.ORDNANCE:
				ordnanceToGive.append( guaranteedConsumable )
				break
			case eLootType.HEALTH:
				if ( guaranteedConsumable in healingItemToNumToGiveTable )
					healingItemToNumToGiveTable[ guaranteedConsumable ]++
				else
					healingItemToNumToGiveTable[ guaranteedConsumable ] <- 1
				break
			case eLootType.AMMO:
				#if DEV
					Assert( false, "GAMEMODE UTILITY: " + FUNC_NAME() + " an ammo type: " + guaranteedConsumable + " was added to the guaranteed consumables list using the min_guaranteed_consumableloadout_ring_ playlist var.\n This is not supported, to guarantee ammo for the players weapon use the min_guaranteed_ammocount_ring_ playlist var" )
				#endif // DEV
				break
			default:
				#if DEV
					Warning( "GAMEMODE UTILITY: ", FUNC_NAME(), " encountered unsupported loot type: ", GetEnumString( "eLootType", guaranteedConsumableData.lootType ) , " when parsing through the guaranteed consumable list"  )
				#endif // DEV
				break
		}
	}

	// Give, Update, or Replace loot based on the quality of the players current loot to ensure it is better or the same quality/quantity as the guaranteed loot
	// First let's update the players weapons
	array < string > weaponsToRemove
	array< weaponInfoStruct > weaponsToGive
	int guaranteedWeaponsCount = minint( minGuaranteedWeapons.weaponRefs.len(), RESTORABLE_WEAPON_SLOTS.len() ) // Make sure we don't go over any limits
	if ( guaranteedWeaponsCount > 0 )
	{
		int weaponIndex = 0
		foreach ( currentWeapon in currentWeapons )
		{
			// If player has more weapons than we would guarantee them, break out. They already have it better
			if ( weaponIndex >= guaranteedWeaponsCount )
				break

			// Ensure we have a valid weapon ref to give the player
			string guaranteedWeaponRef = minGuaranteedWeapons.weaponRefs[ weaponIndex ]
			LootData guaranteedWeaponLootData = SURVIVAL_Loot_GetLootDataByRef( guaranteedWeaponRef )
			if ( SURVIVAL_Loot_IsRefValid( guaranteedWeaponRef ) )
			{
				int guaranteedWeaponLootTier = LoadoutSelection_GetWeaponLootTierForMenu( guaranteedWeaponLootData )
				string currentWeaponClassName = currentWeapon.GetWeaponClassName()
				weaponInfoStruct weaponToGive

				// If we are using kitted weapons, just update the current weapon tier if the guaranteed tier is worse
				bool isCrate = currentWeapon.HasMod( "crate" )
				string currentWeaponLockedSetName = GetWeaponClassNameWithLockedSet( currentWeapon )
				if( isCrate )
				{
					// normally for crate just do nothing, but sometimes we want to replace mythic with min because mythics are too powerful to keep through death
					if( GetPlaylistVar_MinGuaranteedLoadout_ReplaceMythicWithMin() )
					{
						weaponsToRemove.append( currentWeaponClassName )
						weaponInfoStruct weaponInfo = GetWeaponInfoFromLoadout( minGuaranteedWeapons, weaponIndex )
						if ( SURVIVAL_Loot_IsRefValid( weaponInfo.weaponRef ) )
							weaponsToGive.append( weaponInfo )
					}
				}
				else if ( WeaponLootRefIsLockedSet( currentWeaponLockedSetName ) )
				{
					LootData currentWeaponLootData = SURVIVAL_Loot_GetLootDataByRef( currentWeaponLockedSetName )
					int currentWeaponLootTier = LoadoutSelection_GetWeaponLootTierForMenu( currentWeaponLootData )

					// Only do something if the weapon the player currently has is at a lower tier than the guaranteed weapon
					if ( currentWeaponLootTier < guaranteedWeaponLootTier )
					{
						string upTieredCurrentWeapon = currentWeaponLootData.baseWeapon + LoadoutSelection_GetWeaponSetStringForTier( guaranteedWeaponLootTier )
						// Only replace the current weapon if the new weapon we will be giving is actually valid
						if ( SURVIVAL_Loot_IsRefValid( upTieredCurrentWeapon ) )
						{
							LootData upTieredCurrentWeaponLootData = SURVIVAL_Loot_GetLootDataByRef( upTieredCurrentWeapon )
							// Put the old weapon in a list of weapons to remove
							weaponsToRemove.append( currentWeaponClassName )
							// Put the up tiered current weapon in a list of weapons to give
							weaponToGive.weaponRef = upTieredCurrentWeapon
							weaponToGive.modRefs = upTieredCurrentWeaponLootData.baseMods
							weaponsToGive.append( weaponToGive )
						}
					}
				}
				else // Go through and update the attachments one by one if the guaranteed attachments are better
				{
					array< string > finalAttachmentsListForCurrentWeapon
					array< int > finalAttachmentTypesForCurrentWeapon
					array < string > currentAttachments = currentWeapon.GetMods()
					array < string > guaranteedAttachments = minGuaranteedWeapons.weaponAttachmentsByWeapon[ guaranteedWeaponRef ]
					bool doesCurrentWeaponHaveScope = false

					// We support passing in a tiered weapon as a guaranteed weapon ref even if we are not using tiered weapons ( easier than defining each attachment individually )
					// So if no attachments got passed in, grab the attachments that would be on this weapon at the guaranteed weapon tier
					if ( guaranteedAttachments.len() == 0 && guaranteedWeaponLootTier > BASE_LOOT_TIER )
						guaranteedAttachments = LootHelper_GetAllCompatibleAttachmentsForWeapon( currentWeapon, false, [ guaranteedWeaponLootTier ], UPGRADEABLE_ATTACHMENT_TYPES )

					// Go through the current attachments and upgrade them to the new tier unless it is a scope ( keep the players scope preferance )
					foreach ( attachment in currentAttachments )
					{
						// The choke mod attachment would fail SURVIVAL_Loot_IsRefValid, so it need to be in manually
						if ( attachment.find( "choke" ) >= 0 )
						{
							finalAttachmentsListForCurrentWeapon.append( attachment )
							continue
						}

						if ( !SURVIVAL_Loot_IsRefValid( attachment ) )
							continue

						LootData attachmentLootData = SURVIVAL_Loot_GetLootDataByRef( attachment )
						finalAttachmentTypesForCurrentWeapon.append( attachmentLootData.attachmentType )

						if ( attachmentLootData.attachmentType == eWeaponAttachmentType.SCOPE )
						{
							doesCurrentWeaponHaveScope = true
							finalAttachmentsListForCurrentWeapon.append( attachment )
						}
						else
						{
							finalAttachmentsListForCurrentWeapon.append( LootHelper_UpgradeLootRefToTier( attachment, guaranteedWeaponLootTier ) )
						}
					}

					// Go through the attachment types that would be on the weapon at the new tier and if they aren't already present add them
					foreach ( guaranteedWeaponAttachment in guaranteedAttachments )
					{
						if ( !SURVIVAL_Loot_IsRefValid( guaranteedWeaponAttachment ) )
							continue

						int guaranteedType = SURVIVAL_Loot_GetLootDataByRef( guaranteedWeaponAttachment ).attachmentType
						if ( !finalAttachmentTypesForCurrentWeapon.contains( guaranteedType ) )
						{
							finalAttachmentsListForCurrentWeapon.append( guaranteedWeaponAttachment )
							finalAttachmentTypesForCurrentWeapon.append( guaranteedType )
						}
					}

					// If the weapon didn't have a scope, give one now
					if ( !doesCurrentWeaponHaveScope && guaranteedWeaponLootTier > BASE_LOOT_TIER)
					{
						//Commenting out to unblock testing on Three Strikes upgrades. The current setup is not rewarding a sight. R5DEV-558359
						string scope = "optic_cq_hcog_classic"//= LootHelper_GetDefaultScopeForWeaponRef( currentWeaponClassName )
						if ( SURVIVAL_Loot_IsRefValid( scope ) )
							finalAttachmentsListForCurrentWeapon.append( scope )
					}

					// Put the old weapon in a list of weapons to remove
					weaponsToRemove.append( currentWeaponClassName )

					// Put the up tiered version of the current weapon into the list of weapons to give
					weaponToGive.weaponRef = currentWeaponClassName
					weaponToGive.modRefs = finalAttachmentsListForCurrentWeapon
					weaponsToGive.append( weaponToGive )
				}
			}
			weaponIndex++
		}

		// If there are more guaranteed weapons than current weapons, give them to the player
		while ( weaponIndex < guaranteedWeaponsCount )
		{
			string guaranteedWeaponRef = minGuaranteedWeapons.weaponRefs[ weaponIndex ]
			if ( SURVIVAL_Loot_IsRefValid( guaranteedWeaponRef ) )
			{
				weaponInfoStruct weaponToGive = GetWeaponInfoFromLoadout( minGuaranteedWeapons, weaponIndex )
				weaponsToGive.append( weaponToGive )
			}
			weaponIndex++
		}

		// Finally, take away weapons that need to be taken away
		foreach ( weaponToRemove in weaponsToRemove )
		{
			printt("Removing weapon: " + weaponToRemove )
			player.TakeWeaponNow( weaponToRemove )
		}

		#if DEV
			{
				int weaponNumber = 0
				foreach ( weapon in weaponsToGive )
				{
					string msg = "New Weapon #" + weaponNumber + " - " + weapon.weaponRef + " Attachments: "

					array < string > attachments = weapon.modRefs
					foreach ( attachment in attachments )
					{
						msg += attachment + ", "
					}

					printt( msg )
					++weaponNumber
				}
				printt( "--------Loot Upgrade END---------" )
			}
		#endif // DEV

		// Give the player their updated weapons
		for ( int i = 0; i < weaponsToGive.len(); i++ )
		{
			int slotNDX = RESTORABLE_WEAPON_SLOTS[ i ]
			string weaponRef = weaponsToGive[ i ].weaponRef
			array < string > weaponAttachments = weaponsToGive[ i ].modRefs
			LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
			// Only lock attachments and make the weapon a locked set weapon if the mode us using locked set weapons
			array<string> lootTags
			if ( WeaponLootRefIsLockedSet( weaponRef ) )
				lootTags = weaponData.lootTags

			entity newActiveWeapon = SpawnGenericLoot( weaponData.baseWeapon, player.GetOrigin(), player.GetAngles(), -1 )
			newActiveWeapon.SetWeaponMods( weaponAttachments )
			SURVIVAL_GiveMainWeapon( player, newActiveWeapon, lootTags, null, false, null, false, false, [], true )
			SetItemSpawnSource( newActiveWeapon, eSpawnSource.GAME, player )
			newActiveWeapon.Destroy()
		}
	}

	// Go through the players current consumables to determine what consumables need to be given
	array< string > currentOrdnance
	array< string > inventoryItemsToRemove

	array< ConsumableInventoryItem > playerInventory = SURVIVAL_GetPlayerInventory( player )
	for ( int i = 0; i < playerInventory.len(); i++ )
	{
		LootData consumableData = SURVIVAL_Loot_GetLootDataByIndex( playerInventory[i].type )
		string consumableRef = consumableData.ref

		switch ( consumableData.lootType )
		{
			case eLootType.ORDNANCE:
				currentOrdnance.append( consumableRef )
				break
			case eLootType.HEALTH:
				// Don't do anything with healing items here. We count them before giving them to make it easier, otherwise we could count the number of healing items multiple times
				break
			case eLootType.AMMO:
				// If the ammo matches the ammo type of a weapon the player is carrying, subtract it from ammo to give the player. Otherwise, add it to the list of things to get rid of
				if ( !IsAmmoInUse( player, consumableRef ) && !inventoryItemsToRemove.contains( consumableRef ) )
				{
					inventoryItemsToRemove.append( consumableRef )
				}
				break
			case eLootType.ATTACHMENT:
				inventoryItemsToRemove.append( consumableRef )
			default:
				#if DEV
					Warning( "GAMEMODE UTILITY: ", FUNC_NAME(), " encountered unsupported loot type: ", GetEnumString( "eLootType", consumableData.lootType ) , " when generating players current loot list"  )
				#endif // DEV
				break
		}
	}

	// Remove ammo that doesn't match the players weapons
	foreach ( itemToRemove in inventoryItemsToRemove )
	{
		int inventoryItemsToRemoveCount = SURVIVAL_CountItemsInInventory( player, itemToRemove )
		SURVIVAL_RemoveFromPlayerInventory( player, itemToRemove, inventoryItemsToRemoveCount )
	}

	// Give the player their equipment
	array < string > equipmentToGive
	array < string > equipmentToRemove

	foreach ( guaranteedEquipment in minGuaranteedEquipment )
	{
		LootData guaranteedEquipmentData = SURVIVAL_Loot_GetLootDataByRef( guaranteedEquipment )
		int guaranteedEquipmentTier = guaranteedEquipmentData.tier
		int currentEquipmentTier = UNSET_LOOT_TIER
		string currentEquipmentRef

		// Grab the loot tier of the current equipment that matches the equipment type for the guaranteed equipment so we can compare them
		switch ( guaranteedEquipmentData.lootType )
		{
			case eLootType.HELMET:
				if ( SURVIVAL_Loot_IsRefValid( currentHelmet.ref ) )
				{
					currentEquipmentTier = currentHelmet.tier
					currentEquipmentRef = currentHelmet.ref
				}
				break
			case eLootType.BACKPACK:
				if ( SURVIVAL_Loot_IsRefValid( currentBackpack.ref ) )
				{
					currentEquipmentTier = currentBackpack.tier
					currentEquipmentRef = currentBackpack.ref
				}
				break
			case eLootType.INCAPSHIELD:
				if ( SURVIVAL_Loot_IsRefValid( currentIncapShield.ref ) )
				{
					currentEquipmentTier = currentIncapShield.tier
					currentEquipmentRef = currentIncapShield.ref
				}
				break
			case eLootType.GADGET:
				if ( SURVIVAL_Loot_IsRefValid( currentSurvivalItem.ref ) )
				{
					currentEquipmentTier = currentSurvivalItem.tier
					currentEquipmentRef = currentSurvivalItem.ref
				}
				break
			case eLootType.ARMOR:
					currentEquipmentRef = ""
				                    
					{
						string currentArmor = ArmorData_Get( player ).armorLevel
						// Use the armor level if the player has armor, otherwise set the level to 0
						if ( SURVIVAL_Loot_IsRefValid( currentArmor ) )
						{
							currentEquipmentTier = SURVIVAL_Loot_GetLootDataByRef( currentArmor ).tier
							currentEquipmentRef = currentArmor
						}
						else
						{
							currentEquipmentTier = 0
						}
					}
				break
			default:
				#if DEV
					Warning( "GAMEMODE UTILITY: ", FUNC_NAME(), " encountered unsupported loot type: ", GetEnumString( "eLootType", guaranteedEquipmentData.lootType ) , " when determining if the guaranteed equipment is better than current equipment."  )
				#endif // DEV
				break
		}

		// Don't do actual tier comparisons on gadgets. If the player had a gadget don't try to give them a different one from the guaranteed set
		if ( guaranteedEquipmentData.lootType == eLootType.GADGET && currentEquipmentTier != UNSET_LOOT_TIER )
		{
			continue
		}
	                    
		else if ( guaranteedEquipmentTier > currentEquipmentTier ) // If the guaranteed equipment is better, add it to an array to give to the player
		{
		 	equipmentToGive.append( guaranteedEquipmentData.ref )

			// If there was an existing piece of equipment that was worse, have it removed from inventory
			if ( SURVIVAL_Loot_IsRefValid( currentEquipmentRef ) )
		 		equipmentToRemove.append( currentEquipmentRef )
		}
	}

	// Remove the equipment that is worse
	foreach ( worseEquipment in equipmentToRemove )
	{
		SURVIVAL_RemoveFromPlayerInventory( player, worseEquipment )
	}

	// Give the player the equipment that is better than their current equipment
	CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, equipmentToGive )

	// Give Consumables
	// Give ammo first
	if ( minGuaranteedAmmoCountPerWeapon > 0 )
	{
		// Figure out how much ammo to give based on the weapons the player is holding
		foreach( int weaponSlot in RESTORABLE_WEAPON_SLOTS )
		{
			entity weapon = player.GetNormalWeapon( weaponSlot )

			if ( IsValid( weapon ) )
			{
				LootData weaponLootData = SURVIVAL_Loot_GetLootDataByRef( weapon.GetWeaponClassName() )

				// Don't give ammo if the weapon is a Crate Weapon
				if ( weaponLootData.tier == eLootTier.MYTHIC )
					continue

				string ammoType = weaponLootData.ammoType
				int ammoTypeInt = AmmoType_GetTypeFromRef( ammoType )
				LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoType )

				int currentAmmoPool = player.AmmoPool_GetCount( ammoTypeInt )
				int minAmmoPool = minGuaranteedAmmoCountPerWeapon * ammoData.inventorySlotCount
				if( currentAmmoPool < minAmmoPool )
				{
					player.AmmoPool_SetCount( ammoTypeInt, minAmmoPool )
				}
			}
		}
	}

	// Give healing items second
	foreach ( healingItem, amountToGive in healingItemToNumToGiveTable )
	{
		// Only give healing items to the player if they have less in current inventory than what we guarantee
		int finalAmountToGive = amountToGive - SURVIVAL_CountItemsInInventory( player, healingItem )
		if ( finalAmountToGive > 0 )
			SURVIVAL_AddToPlayerInventory( player, healingItem, amountToGive )
	}

	// Give ordnance if the player has less than we want them to have. We don't sort ordnance by any type of tier
	if ( ordnanceToGive.len() > 0 )
	{
		int amountOrdnanceLeftToGive = ordnanceToGive.len() - currentOrdnance.len()
		int ordnanceIndex = 0

		while ( amountOrdnanceLeftToGive > 0 && ordnanceIndex < ordnanceToGive.len() )
		{
			string ordnanceToGiveRef = ordnanceToGive[ ordnanceIndex ]
			if ( SURVIVAL_Loot_IsRefValid( ordnanceToGiveRef ) )
			{
				SURVIVAL_AddToPlayerInventory( player, ordnanceToGiveRef, 1 )
				currentOrdnance.append( ordnanceToGiveRef ) // We need a full list of the players ordnance to equip it later
				amountOrdnanceLeftToGive--
			}
			ordnanceIndex++
		}
	}

	// Handle cases where players spawn in a skydive, we need to wait until weapons are enabled before we can equip them
	if ( !player.IsOnGround() )
	{
		player.WaitSignal( "PlayerBootsOnGround" )
		wait SKYDIVE_AWARD_WEAPONS_DELAY

		foreach ( ordnance in currentOrdnance )
		{
			SURVIVAL_EquipOrdnanceFromInventory( player, ordnance )
		}
	}

	// Deploy weapons
	// S22+ uses player.IsWeaponTypeEnabled( WPT_PRIMARY ) — not available in S3.
	// Primary weapons are always enabled in FreeDM, so check for a valid weapon instead.
	entity primaryWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if ( IsValid( primaryWeapon ) )
	{
		player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		player.DeployWeapon()
	}
}
#endif //SERVER

#if CLIENT
void function GamemodeUtility_OnMatchStartTimeChanged( entity player, float newValue, float oldValue, bool didChange )
{
	float time = newValue
	var rui = ClGameState_GetRui()
	if ( rui != null )
	{
		if ( RuiHasGameTimeArg( rui, "matchStartTime" ) )
		{
			RuiSetGameTime( rui, "matchStartTime", time )
		}
	}
}
#endif // CLIENT

#if CLIENT
void function GamemodeUtility_OnMatchEndTimeChanged( entity player, float newValue, float oldValue, bool didChange )
{
	float time = newValue
	var rui = ClGameState_GetRui()
	if ( rui != null )
	{
		if ( RuiHasGameTimeArg( rui, "matchEndTime" ) )
		{
			RuiSetGameTime( rui, "matchEndTime", time )
		}
	}
}
#endif // CLIENT


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Utility Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
// Set entities to be culled outside of a cull circle entity
void function GamemodeUtility_SetCircleCullEnts()
{
	// Circle Cull Memory Optimizations
	// `edict_dump_distribution` in the console to see current entity usage
	CircleCullClassName( "prop_door" )
	CircleCullClassName( "prop_script" )
	CircleCullClassName( "prop_dynamic_lightweight" )
	CircleCullClassName( "prop_survival" )

	CircleCullClassName( "trigger_slip" )
	CircleCullClassName( "trigger_out_of_bounds" )
	CircleCullClassName( "trigger_no_zipline" )
	CircleCullClassName( "trigger_no_object_placement" )
	CircleCullClassName( "trigger_no_object_placement_special" )

	CircleCullClassName( "zipline" )
	CircleCullClassName( "zipline_end" )

	// World's Edge has hundreds of these
	CircleCullClassName( "script_mover_train_node" )

	// World's Edge Vault Panels are linked to some prop_door's
	CircleCullScriptName( "LootVaultPanel" )

	                  
		CircleCullScriptName( "ShipVaultPanel" )
                         

	// Big memory users, but difficult to remove easily
	// Lots of level script requires these entities:
	//CircleCullClassName( "info_target" )
	//CircleCullClassName( "prop_dynamic" )
	//CircleCullClassName( "trigger_multiple" )
}
#endif // SERVER}

#if SERVER
// Wait the specified time and then end the game when the match time limit is reached
void function GamemodeUtility_MatchTimeLimit_Thread( float matchTimeLimit  )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	#if DEV
		// Signal from Dev Command to turn off the Match Time Limit
		EndSignal( svGlobal.levelEnt, "GamemodeUtility_DisableMatchTimeLimit" )

		// Make sure we have enough time defined in the time limit to display the necessary warnings
		float maxTimesNeededForWarnings = GAMEMODEUTILITY_MATCH_TIME_LIMIT_WARNING_TIME + GAMEMODEUTILITY_DEFAULT_MESSAGE_DURATION
		Assert( matchTimeLimit > maxTimesNeededForWarnings, "GAMEMODE UTILITY: Match time limit is set to a value that is lower than the time needed to display the warnings which is: " + maxTimesNeededForWarnings )

		// Make sure we have a Set Winner function defined
		string currentGamemode = GameRules_GetGameMode()
		Assert( file.gamemodeSetWinnerFunction != null, "GAMEMODE UTILITY: Current Gamemode doesn't have a SetWinner function defined in file.gamemodeSetWinnerFunction, use the GamemodeUtility_AddCallback_SetGamemodeWinnerFunction function to set one for: " + currentGamemode )
	#endif // DEV

	printt( "GAMEMODE UTILITY: Starting GamemodeUtility_MatchTimeLimit_Thread at " + Time() + " Match Time Limit is set to " + matchTimeLimit )

	SetGlobalNonRewindNetTime( GAMEMODEUTILITY_NETVAR_MATCH_START, Time() )
	SetGlobalNonRewindNetTime( GAMEMODEUTILITY_NETVAR_MATCH_END, Time() + matchTimeLimit )

	float timeToWaitForMatchLimitWarningMessage = matchTimeLimit - GamemodeUtility_GetMatchTimeLimitWarning()

	// Wait match time limit time minus the warning message time so we display the warning before the match ends
	wait timeToWaitForMatchLimitWarningMessage

	// Display a warning message letting players know the match will time out soon
	array < entity > allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) )
			Remote_CallFunction_NonReplay( player, "GamemodeUtility_ServerCallback_DisplayMatchTimeLimitWarning", false )
	}

	printt( "GAMEMODE UTILITY: Displayed Match Time limit Warning at " + Time() + " Match Time Limit Warning was set to " + GamemodeUtility_GetMatchTimeLimitWarning() )

	// Wait the remaining match time after the warning message before ending the game
	wait GamemodeUtility_GetMatchTimeLimitWarning() - GAMEMODEUTILITY_FINAL_COUNTDOWN_DURATION

	// Begin audio countdown tick for all players
	allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) )
			Remote_CallFunction_NonReplay( player, "GamemodeUtility_ServerCallback_PlayMatchEndingCountdownAudio" )
	}

	wait GAMEMODEUTILITY_FINAL_COUNTDOWN_DURATION

	// Show a game is ending warning message to player
	allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) )
			Remote_CallFunction_NonReplay( player, "GamemodeUtility_ServerCallback_DisplayMatchTimeLimitWarning", true )
	}

	printt( "GAMEMODE UTILITY: Displayed Match Time limit Ending Message at " + Time() )

	// Wait for the message duration to give it time to display before we end the match
	wait GAMEMODEUTILITY_DEFAULT_MESSAGE_DURATION

	// End the match because the time limit was reached
	#if DEV
		if ( GetConVarInt( "mp_enablematchending" ) == 0 )
		{
			printt( "GAMEMODE UTILITY: Match time limit reached but ignoring because mp_enablematchending is set to false" )
			return
		}
		else
	#endif // DEV
		{
			printt( "GAMEMODE UTILITY: Match Ending due to time limit reached at " + Time() + " Match time limit was set to " + matchTimeLimit )
		}


	// End the game using the set winner function defined by the active gamemode
	if ( GetGameState() < eGameState.WinnerDetermined )
	{
		int winningTeamOrAllianceRAW = GamemodeUtility_GetWinningTeamOrAlliance( false ) // This function will now grab the first team it checks that has the highest score instead of returning invalid if there is a tie
		int winningTeamOrAlliance = winningTeamOrAllianceRAW
		if ( winningTeamOrAlliance <= TEAM_INVALID )
		{
			// Leaving this logic in case an invalid team is returned for reasons other than a tie
			// The logic below is actually bad for dealing with ties because it grabs a random winning team or alliance instead of a random team or alliance from the teams or alliances tied in the lead
			if (AllianceProximity_IsUsingAlliances())
				winningTeamOrAlliance = RandomInt(AllianceProximity_GetMaxNumAlliances())
			else
				winningTeamOrAlliance = TEAM_MULTITEAM_FIRST + RandomInt( GetAllValidPlayerTeams().len() )
		}

		//
		// Debug for series of bugs where the winning team is not a valid team - eg: R5DEV-507314
		if( AllianceProximity_IsUsingAlliances() )
		{
			if( ( winningTeamOrAlliance < 0 || winningTeamOrAlliance >= AllianceProximity_GetMaxNumAlliances() ) )
			{
				int arrayLength = AllianceProximity_GetMaxNumAlliances()
				ForceScriptError( "Match Time limit was reached, but an Invalid ALLIANCE was selected as winning team. winningTeamOrAlliance = " + winningTeamOrAlliance + ". winningTeamOrAllianceRAW = " +  winningTeamOrAllianceRAW + ". ArrayLength = " + arrayLength )
			}
		}
		else
		{
			if ( !GamemodeUtility_GetIsTeamIndexValidPlayerTeam( winningTeamOrAlliance ) )
			{
				int arrayLength = GetAllValidPlayerTeams().len()
				ForceScriptError( "Match Time limit was reached, but an Invalid TEAM was selected as winning team. winningTeamOrAlliance = " + winningTeamOrAlliance + ". winningTeamOrAllianceRAW = " +  winningTeamOrAllianceRAW + ". ArrayLength = " + arrayLength )
			}
		}
		// End Debug

		file.gamemodeSetWinnerFunction( winningTeamOrAlliance, eWinReason.TIME_LIMIT )
	}
}
#endif // SERVER

#if CLIENT
// Display a warning message mins before we end the match due to time limit or right before we do
void function GamemodeUtility_ServerCallback_DisplayMatchTimeLimitWarning( bool isFinalWarning )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	// Don't want to deal with division issues, the warning time should be in secs, minute multiples. //todo: allow this timer to represent sub-60 seconds and display on hud appropriately
	if ( GamemodeUtility_GetMatchTimeLimitWarning() < 60 )
		return

	string message = Localize( "#CONTROL_MATCH_TIMELIMIT_WARNING", GamemodeUtility_GetMatchTimeLimitWarning()/ 60 )
	if ( isFinalWarning )
		message = Localize( "#CONTROL_MATCH_TIMELIMIT_GAMEEND" )

	GamemodeUtility_AnnouncementMessageWarning( player, message, GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED ), SFX_MATCH_TIME_LIMIT, GAMEMODEUTILITY_DEFAULT_MESSAGE_DURATION )
}
#endif // CLIENT

#if CLIENT
void function GamemodeUtility_ServerCallback_PlayMatchEndingCountdownAudio()
{
	thread GamemodeUtility_ServerCallback_PlayMatchEndingCountdownAudio_Thread()
}
#endif // CLIENT

#if CLIENT
void function GamemodeUtility_ServerCallback_PlayMatchEndingCountdownAudio_Thread()
{
	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )
	
	int secondsElapsed = 0
	while ( secondsElapsed < GAMEMODEUTILITY_FINAL_COUNTDOWN_DURATION )
	{
		if ( IsValid( GetLocalClientPlayer() ) )
			EmitSoundOnEntity( GetLocalClientPlayer(), GAMEMODEUTILITY_FINAL_COUNTDOWN_SFX )

		secondsElapsed += 1
		wait 1.0
	}
}
#endif // CLIENT

#if SERVER
// Manage how long after gamestate playing before we consider newly connected players as join in progress players
void function GamemodeUtility_SetMatchJIPState_Thread()
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	OnThreadEnd(
		function() : ()
		{
			if ( GetGameState() < eGameState.WinnerDetermined && !GamemodeUtility_IsWinnerBeingDetermined() )
			{
				// Players joining the match at this point are considered join in progress players
				printt( "GAMEMODE UTILITY: Setting Match JIP State to True. Players joining the game after this point are considered Join In Progress players by the mode" )

				file.isMatchInJIPState = true
			}
			else
			{
				printt( "GAMEMODE UTILITY: GamemodeUtility_SetMatchJIPState_Thread ending but not seeing match to JIP state because match is ending/ended." )
			}
		}
	)

	if ( GamemodeUtility_GetMatchJIPStateDelay() > 0 )
		wait GamemodeUtility_GetMatchJIPStateDelay()
}
#endif // SERVER


#if SERVER
// Manage how long after Init until we turn off Join In Progress for modes that support it
const float JIP_CRITERIA_CHECK_INTERVAL = 1.0
void function GamemodeUtility_ManageJIPAvailability_Thread()
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	printt( "GAMEMODE UTILITY: Setting Allow Join In Progress to True for Match Start" )
	GamemodeUtility_SetJIPEnabled( true )

	OnThreadEnd(
		function() : ()
		{
			// No longer allow Join in Progress
			printt( "GAMEMODE UTILITY: Setting Allow Join In Progress to False" )

			GamemodeUtility_SetJIPEnabled( false )
		}
	)

	WaitFrame() // Need to wait for signals to get registered in other scripts to do the following wait

	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	// We want to wait until atleast the playing gamestate is reached
	WaittillGameStateOrHigher( eGameState.Playing )

	// Determine if we want to wait a set minimum amount of time before turning off Join in Progress
	// If this is the only criteria set to turn off Join In Progress, it will be turned off after this wait
	float minJIPActiveTime = GamemodeUtility_GetMinJIPActiveTime()
	bool isUsingMinJIPActiveTime = minJIPActiveTime > UNSET_PLAYLIST_VAR_FLOAT

	if ( isUsingMinJIPActiveTime )
		wait ( minJIPActiveTime )

	// Determine what criteria we will use to turn off Join In Progress
	float matchTimeLimit = GamemodeUtility_GetMatchTimeLimit()
	bool shouldCheckMatchEndTime = matchTimeLimit > UNSET_PLAYLIST_VAR_FLOAT && matchTimeLimit > GamemodeUtility_GetMaxTimeRemaningBeforeDisableJIP() && GamemodeUtility_GetMaxTimeRemaningBeforeDisableJIP() > UNSET_PLAYLIST_VAR_FLOAT

	// Disable JIP either when playlist rotates or we've reached max allowed time
	float allowedJIPTime = matchTimeLimit - GamemodeUtility_GetMaxTimeRemaningBeforeDisableJIP()
	int endTime = GetEndTimeForPlaylistInRotation( GetCurrentPlaylistName() )
	if( endTime > 0 )
	{
		int timeRemaining = endTime - GetUnixTimestamp()
		if( timeRemaining < allowedJIPTime )
			allowedJIPTime = float(timeRemaining)
	}

	float timeToEndJIP = Time() + allowedJIPTime

	int maxScoreDifference = GamemodeUtility_GetMaxScoreDifferenceBeforeDisableJIP()
	bool shouldCheckScoreDifference = maxScoreDifference > UNSET_PLAYLIST_VAR_INT
	int maxScore = GamemodeUtility_GetMaxScoreBeforeDisableJIP()
	bool shouldCheckHighestScore = maxScore > UNSET_PLAYLIST_VAR_INT
	int maxRoundsPlayed = GamemodeUtility_GetMaxRoundsPlayedBeforeDisableJIP()
	bool shouldCheckRoundsPlayed = IsRoundBased() && maxRoundsPlayed > 0

	bool didMeetEndJIPCriteria = false
	// If the only criteria we use is the minimum join in progress time, turn off join in progress now ( we already did the wait above )
	if ( isUsingMinJIPActiveTime && !shouldCheckMatchEndTime && !shouldCheckScoreDifference && !shouldCheckHighestScore && !shouldCheckRoundsPlayed )
		didMeetEndJIPCriteria = true

	// Once the playing gamestate is reached, we want to leave Join in Progress open until we reach different score/time criteria
	while ( !didMeetEndJIPCriteria && GetGameState() == eGameState.Playing )
	{
		// Disable JIP if the score difference between teams is too great
		if ( shouldCheckScoreDifference && GamemodeUtility_GetScoreDifference() >= maxScoreDifference )
		{
			didMeetEndJIPCriteria = true
			printt( "GAMEMODE UTILITY: Going to set Join In Progress to False due to score difference: ", GamemodeUtility_GetScoreDifference(), " maxScoreDifference: ", maxScoreDifference )
		}

		// Disable JIP if the highest score is too high
		if ( shouldCheckHighestScore && GamemodeUtility_GetWinningTeamOrAllianceScore() >= maxScore )
		{
			didMeetEndJIPCriteria = true
			printt( "GAMEMODE UTILITY: Going to set Join In Progress to False due to highest score: ", GamemodeUtility_GetWinningTeamOrAllianceScore(), " maxScore: ", maxScore )
		}

		// Disable JIP if there is not enough time left in the match
		if ( shouldCheckMatchEndTime && Time() >= timeToEndJIP )
		{
			didMeetEndJIPCriteria = true
			printt( "GAMEMODE UTILITY: Going to set Join In Progress to False due to time remaining in match, timeToEndJIP: ", timeToEndJIP, " time: ", Time(), " allowedJIPTime: ", allowedJIPTime  )
		}

		// Disable JIP if a certain number of rounds have been played in a round based mode
		if ( shouldCheckRoundsPlayed && GetRoundsPlayed() >= maxRoundsPlayed )
		{
			didMeetEndJIPCriteria = true
			printt( "GAMEMODE UTILITY: Going to set Join In Progress to False due to rounds played: ", GetRoundsPlayed(), " maxRoundsPlayed: ", maxRoundsPlayed )
		}

		wait JIP_CRITERIA_CHECK_INTERVAL
	}
}
#endif // SERVER

#if SERVER
void function GamemodeUtility_SetJIPEnabled( bool enabled )
{
	#if DEV
		Assert( !enabled || GamemodeUtility_IsJIPEnabledInPlaylist(), "GAMEMODE UTILITY: Attempting to enable JIP while the match_jip playlist variable is set to false, it needs to be set to true" )
	#endif // DEV

	SetConVarBool( "match_jip", enabled )
}
#endif // SERVER

#if SERVER
// Get whether the connecting player will be treated as a first time join in progress player
bool function GamemodeUtility_IsPlayerJoiningAsJIP( entity player )
{
	return GamemodeUtility_IsJIPEnabledInPlaylist() && file.isMatchInJIPState && !( file.jipPlayersArray.contains( player ) )
}
#endif // SERVER

#if CLIENT || SERVER
// Return whether this join in progress player has yet to receive their first spawn bonus ( up to the mode to give bonuses or not )
bool function GamemodeUtility_IsJIPPlayerSpawnBonusPending( entity player )
{
	if ( !IsValid( player ) || !GamemodeUtility_IsJIPEnabledInPlaylist() )
		return false

	return player.GetPlayerNetBool( "GamemodeUtility_HasJIPPlayerReceivedSpawnBonus" )
}
#endif // CLIENT || SERVER

#if SERVER
// Should only be used to turn off GamemodeUtility_HasJIPPlayerReceivedSpawnBonus since the timing of that event will be very different for each mode
// For example, Control Mode only sets this to false after using the bool to determine what extras to give these players which happens several frames after a player spawned callback
// Allow for this function to set it to true, mostly for debugging purposes
void function GamemodeUtility_SetJIPPlayerIsWaitingForSpawnBonus( entity player, bool hasJIPPlayerReceivedBonus )
{
	if ( IsValid( player ) && GamemodeUtility_IsJIPEnabledInPlaylist() )
	{
		#if DEV
			printt( "GAMEMODE UTILITY: Setting GamemodeUtility_HasJIPPlayerReceivedSpawnBonus to : " + hasJIPPlayerReceivedBonus + " for : " + player )
		#endif // DEV

		player.SetPlayerNetBool( "GamemodeUtility_HasJIPPlayerReceivedSpawnBonus", hasJIPPlayerReceivedBonus )
	}
}
#endif // SERVER

#if SERVER
// Get an array of players that have joined the match in progress
bool function GamemodeUtility_IsPlayerJIP( entity player )
{
	return file.jipPlayersArray.contains( player )
}
#endif // SERVER

#if CLIENT
void function GamemodeUtility_ServerCallback_PlayerJoinedMatchInProgress( entity jipPlayer )
{
	entity localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) || !IsValid( jipPlayer ) )  // maybe while the player is in kill cam the joining player could drop so there's a small window where this could still be null
		return

	// Trigger player joined match in progress callbacks for everyone
	foreach( playerJoinedMatchInProgressFunc in file.onPlayerJoinedMatchInProgressCallbackFuncs )
	{
		playerJoinedMatchInProgressFunc( jipPlayer )
	}

	// Trigger SFX for the alliance/team of a join in progress player when they join the match
	int jipPlayerTeamOrAlliance = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllianceFromTeam( jipPlayer.GetTeam() ) : jipPlayer.GetTeam()
	int localPlayerTeamOrAlliance = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() ) : localPlayer.GetTeam()
	if ( jipPlayerTeamOrAlliance == localPlayerTeamOrAlliance )
		EmitUISound( SFX_JOIN_MATCH_IN_PROGRESS )
}
#endif // CLIENT

#if CLIENT || SERVER
// Return the score difference between the highest scoring team or alliance and the lowest scoring team or alliance
int function GamemodeUtility_GetScoreDifference()
{
	if ( AllianceProximity_IsUsingAlliances() )
		return AllianceProximity_GetAllianceScoreDifference()

	return GamemodeUtility_GetScoreDifferenceBetweenTeams()
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the score difference between the highest scoring team and the lowest scoring team in a game
int function GamemodeUtility_GetScoreDifferenceBetweenTeams()
{
	int lowestScore = -1
	int highestScore = 0
	int currentTeamScore = 0
	array < int > allTeamsArray = GetAllValidPlayerTeams()

	foreach( team in allTeamsArray )
	{
		currentTeamScore = GameRules_GetTeamScore( team )
		lowestScore = currentTeamScore < lowestScore || lowestScore == -1 ? currentTeamScore : lowestScore
		highestScore = currentTeamScore > highestScore ? currentTeamScore : highestScore
	}

	return highestScore - lowestScore
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return the highest scoring team or alliance
int function GamemodeUtility_GetWinningTeamOrAlliance( bool shouldReturnInvalidInCaseOfTie )
{
	if ( AllianceProximity_IsUsingAlliances() )
		return GamemodeUtility_GetWinningAlliance( shouldReturnInvalidInCaseOfTie )

	int winningTeam = GetWinningTeam( shouldReturnInvalidInCaseOfTie )

	// GetWinningTeam can return TEAM_UNASSIGNED if teams are tie for the lead, but TEAM_UNASSIGNED maps to a valid alliance value
	// so we need to make sure it's not mistaken for a valid value by making it TEAM_INVALID, or TEAM_MULTITEAM_FIRST if we don't want invalid return values
	int fallbackTeam = TEAM_INVALID
	if ( !shouldReturnInvalidInCaseOfTie )
		fallbackTeam = TEAM_MULTITEAM_FIRST

	return winningTeam < TEAM_MULTITEAM_FIRST ? fallbackTeam : winningTeam
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return the highest scoring alliance
int function GamemodeUtility_GetWinningAlliance( bool shouldReturnInvalidInCaseOfTie )
{
	int winningAlliance = ALLIANCE_NONE
	int highestScore = 0
	int currentScoreBeingTested = 0
	array < int > allAlliancesArray = AllianceProximity_GetAllAlliances()

	foreach( alliance in allAlliancesArray )
	{
		currentScoreBeingTested = GetAllianceTeamsScore( alliance )

		if ( shouldReturnInvalidInCaseOfTie && currentScoreBeingTested == highestScore && winningAlliance != alliance ) //Treat multiple alliances as having the same score as no alliance winning
		{
			winningAlliance = ALLIANCE_NONE
		}
		else if ( currentScoreBeingTested > highestScore )
		{
			winningAlliance = alliance
			highestScore = currentScoreBeingTested
		}
	}

	return winningAlliance
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return the highest score for a team or Alliance in the game
int function GamemodeUtility_GetWinningTeamOrAllianceScore()
{
	int winningTeamOrAlliance = GamemodeUtility_GetWinningTeamOrAlliance( false )

	return GamemodeUtility_GetTeamOrAllianceScore( winningTeamOrAlliance )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the score of a specific Team or Alliance
int function GamemodeUtility_GetTeamOrAllianceScore( int teamOrAlliance )
{
	int teamScore = 0

	if ( teamOrAlliance != TEAM_INVALID )
	{
		if ( AllianceProximity_IsUsingAlliances() )
			teamScore = GetAllianceTeamsScore( teamOrAlliance )
		else
			teamScore = GameRules_GetTeamScore( teamOrAlliance )
	}

	return teamScore
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return the alliance score for the passed in team ( used sometimes when playing in Alliance Games but setting team data )
int function GamemodeUtility_GetAllianceScoreFromTeam( int team )
{
	int allianceIndex = AllianceProximity_GetAllianceFromTeam( team )
	return GetAllianceTeamsScore( allianceIndex )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return an array of teams or alliances ( depending on what the mode is using ) sorted by score
// if shouldExcludeEliminated is set to true, the sorted list of teams or alliances will not exclude teams or alliances that have been eliminated
array < int > function GamemodeUtility_GetAlliancesOrTeamsSortedByScore( bool shouldExcludeEliminated )
{
	array < int > teamsOrAlliances = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllAlliances() : GetAllValidPlayerTeams()

	if ( shouldExcludeEliminated )
	{
		array < int >  nonEliminatedTeamsOrAlliances = []

		foreach( teamOrAlliance in teamsOrAlliances )
		{
			if ( !GamemodeUtility_IsTeamOrAllianceEliminated( teamOrAlliance ) )
				nonEliminatedTeamsOrAlliances.append( teamOrAlliance )
		}

		teamsOrAlliances = nonEliminatedTeamsOrAlliances
	}

	teamsOrAlliances.sort( int function( int a, int b )
	{
		int aScore = GamemodeUtility_GetTeamOrAllianceScore( a )
		int bScore = GamemodeUtility_GetTeamOrAllianceScore( b )

		if ( aScore > bScore )
			return -1
		else if ( aScore < bScore )
			return 1

		return 0
	}
	)

	return teamsOrAlliances
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return an array of teams or alliances ( depending on what the mode is using ) sorted by score with eliminated teams at the bottom
array < int > function GamemodeUtility_GetAlliancesOrTeamsSortedByEliminationAndScore()
{
	array < int > teamsOrAlliances = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllAlliances() : GetAllValidPlayerTeams()

	teamsOrAlliances.sort( int function( int a, int b )
	{
		int aScore = GamemodeUtility_GetTeamOrAllianceScore( a )
		int bScore = GamemodeUtility_GetTeamOrAllianceScore( b )
		bool aIsEliminated = GamemodeUtility_IsTeamOrAllianceEliminated( a )
		bool bIsEliminated = GamemodeUtility_IsTeamOrAllianceEliminated( b )

		// Primary sorting is based on if one team is eliminated and the other isn't
		if ( bIsEliminated && !aIsEliminated )
			return -1
		else if ( aIsEliminated && !bIsEliminated )
			return 1

		// If elimination status is the same, sort by score instead
		if ( aScore > bScore )
			return -1
		else if ( aScore < bScore )
			return 1

		return 0
	}
	)

	return teamsOrAlliances
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Return whether a team or alliance is eliminated based on the "respawnStatus" netvar
bool function GamemodeUtility_IsTeamOrAllianceEliminated( int teamOrAlliance )
{
	array < entity > teamOrAlliancePlayers = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllPlayersInAlliance( teamOrAlliance, false ) : GetPlayerArrayOfTeam( teamOrAlliance )

	foreach ( player in teamOrAlliancePlayers )
	{
		if ( !IsValid( player ) )
			continue

		// Return false if any player is not eliminated ( every player in the squad or alliance needs to be set to eliminated otherwise the whole squad or alliance isn't eliminated )
		if ( player.GetPlayerNetInt( "respawnStatus" ) != eRespawnStatus.SQUAD_ELIMINATED )
			return false
	}

	return true
}
#endif // CLIENT || SERVER

#if SERVER
// Shared Set Winner function to be used by Gamemodes.
// It handles Alliance Team reassignment for modes using Alliances and allows the gamemode to define an additional function to call that will take care of the mode specific game end logic
void function GamemodeUtility_GamemodeSetWinnerCommon( int winningTeamOrAlliance, int victoryCondition, void functionref( int ) modeSpecificSetWinnerFunctionality )
{
	// Don't let this run more than once
	if ( GamemodeUtility_IsWinnerBeingDetermined() )
		return

	file.isWinnerBeingDetermined = true
	thread GamemodeUtility_GamemodeSetWinnerCommon_Thread( winningTeamOrAlliance, victoryCondition, modeSpecificSetWinnerFunctionality )
}
#endif // SERVER

#if SERVER
void function GamemodeUtility_GamemodeSetWinnerCommon_Thread( int winningTeamOrAlliance, int victoryCondition, void functionref( int ) modeSpecificSetWinnerFunctionality )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	// Don't allow dialogue between Legends ( don't want this once game is over anyways but could also cause issues with players all being on the same team)
	SetCommentaryEnabled( false )
	array < entity > allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) )
		{
			                  
			if ( IsNessieEEActive() )
			{
				Wattson_TT_Check_Victory( player )
			}
         

			player.SetInvulnerable()
			StopDialogueForPlayer( player )
		}
	}

	// This is the team that will be communicated as winning, when alliances are used we override this value below
	// Because alliances are not supported, we put a whole alliance on to a single team
	int localWinningTeam = winningTeamOrAlliance

	// ALLIANCE ONLY LOGIC
	if ( AllianceProximity_IsUsingAlliances() )
	{
		localWinningTeam = TEAM_INVALID

		// Reassign all players to new teams based on alliance. This needs to be done so squad data is populated correctly and end of match flow works
		AllianceProximity_ReassignAlliancePlayersToTeams()

		// Set the Local Winning team and new game state
		if ( victoryCondition != eWinReason.DEFAULT && winningTeamOrAlliance != ALLIANCE_NONE )
			localWinningTeam = AllianceProximity_GetRepresentativeTeamForAlliance( winningTeamOrAlliance )
	}

	svGlobal.winReason = victoryCondition
	svGlobal.levelEnt.Signal( GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	SetWinningTeam( localWinningTeam )
	if ( GetGameState() < eGameState.WinnerDetermined ) // private match leave early can sometimes set the gamestate to resolution before this
		SetGameState( eGameState.WinnerDetermined )

	// Award XP for completing the match if set to through vars
	if ( GamemodeUtility_GetXPToAwardOnMatchCompleted() > 0 )
	{
		foreach ( player in allPlayersArray )
		{
			if ( IsValid( player ) )
				AddXP( player, eXPType.MATCH_COMPLETED )
		}
	}

	// Award XP for completing the match after joining while the match was in progress if set to through vars
	if ( GamemodeUtility_IsJIPEnabledInPlaylist() && GamemodeUtility_GetXPToAwardOnJoinInProgressMatchCompleted() > 0 )
	{
		foreach ( player in file.jipPlayersArray )
		{
			if ( IsValid( player ) )
				AddXP( player, eXPType.MATCH_COMPLETED_JOINED_IN_PROGRESS )
		}
	}

	// Allow mode script to perform mode specific functionality here ( Control mode rewards XP and cleans up Ratings Leader for example, FreeDM and Control play unique music )
	if ( modeSpecificSetWinnerFunctionality != null )
		modeSpecificSetWinnerFunctionality( winningTeamOrAlliance )

	WaitFrame() // let stat accrual callbacks finish

	// Update Squad Data and end player participation
	array < entity > allPlayerAndSpectatorArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayerAndSpectatorArray )
	{
		// We need to do this stuff even if the player entity is invalid, so not doing validity check here
		SURVIVAL_SendWinningSquadDataToPlayer( player, localWinningTeam )

		if ( IsValid( player ) )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_MatchEndAnnouncement", player.GetTeam() == localWinningTeam, localWinningTeam )

			// The next functions need a valid player
			if ( player.GetTeam() != TEAM_SPECTATOR )
			{
				                      
					if ( MatchBehaviorPlayer_HasStarted( player ) && !MatchBehaviorPlayer_HasEnded( player ) )
						MatchBehaviorPlayer_Ended( player, false )
                                

				// S22+ match participation tracking — player.p fields not in S3 ServerPlayerStruct
				// if ( player.p.hasMatchParticipationStarted && !player.p.hasMatchParticipationEnded )
				// 	OnPlayerMatchParticipationEnded( player, false )
			}
		}
	}

	// Wait until we transition to the podium
	wait GetWinnerDeterminedWait()

	// Enter the resolution gamestate and dump our squad data ( normally this is done in survival logic but respawning gamemodes don't use that match end function)
	if ( GetGameState() < eGameState.Resolution ) // private match leave early can sometimes set the gamestate to resolution before this
		SetGameState( eGameState.Resolution )

	ProjectX_DumpGameSummarySquadData()
}
#endif // SERVER

#if SERVER
bool function GamemodeUtility_IsWinnerBeingDetermined()
{
	return file.isWinnerBeingDetermined
}
#endif // SERVER

                      
#if SERVER
void function GamemodeUtility_OnMatchBehaviorEndHandlePlayerAbandon(entity  player, bool wasUnexpectedDisconnect )
{
	if ( !MatchBehavior_Enabled())
		return

	if ( MatchBehaviorPlayer_DidAbandonThisMatch( player ) && !wasUnexpectedDisconnect )
	{
		// set player ban before setting numControlAbandons because Control_GetAbandonPenaltyLength returns numMixtapeAbandons + 1 penalty time
		SetPlayerBan( player, MATCHBANREASON_ABANDONED, GamemodeUtility_GetAbandonPenaltyLength( player ) )

		int numGamesAbandoned = expect int ( player.GetPersistentVar( "numControlAbandons" ) ) + 1

		//player abandoned match, apply behavior penalty
		player.SetPersistentVar( "lastGameControlAbandon", true )
		player.SetPersistentVar( "lastTimeGameWasControlAbandoned", GetCurrentTimeForPersistence() )
		player.SetPersistentVar( "numControlAbandons", numGamesAbandoned )
	}
	else
	{
		//player not abandoning match, potentially due to unexpected disconnect
		player.SetPersistentVar( "lastGameControlAbandon", false )

		// If the player has gone a day without abandoning, reset the abandons counter
		int timeBetweenAbandonResetsAllowed = GetCurrentPlaylistVarInt( "ranked_time_between_abandon_resets_allowed", SECONDS_PER_DAY )
		int lastTimeControlAbandoned = expect int( player.GetPersistentVar( "lastTimeGameWasControlAbandoned" ) )

		if ( lastTimeControlAbandoned > 0 && GetCurrentTimeForPersistence() >= lastTimeControlAbandoned + timeBetweenAbandonResetsAllowed )
		{
			player.SetPersistentVar( "numControlAbandons", 0 )
		}
	}

}
#endif // SERVER
                            

                      
#if CLIENT || SERVER
bool function GamemodeUtility_IsPlayerAbandoning( entity player )
{
	if ( !GamemodeUtility_GetMixtapeAbandonPenaltyActive() )
		return false

	if ( GetGameState() >= eGameState.WinnerDetermined )
		return false

	if ( !GetGlobalNetBool( "mixtape_isLeaverPenaltyEnabledForMatch" ) )
		return false

	if ( GetGameState() >= eGameState.Prematch && !player.GetPlayerNetBool( "rankedDidPlayerEverHaveAFullTeam" ) )
		return false

	return true
}
#endif // CLIENT || SERVER
                            

#if CLIENT || SERVER
int function GamemodeUtility_GetAbandonPenaltyLength( entity player )
{
	if( !IsValid( player ) )
		return 0

	int numGamesAbandoned = expect int ( player.GetPersistentVar( "numControlAbandons" ) ) + 1

	int banLength
	if ( numGamesAbandoned >= 4 )
		banLength = GetCurrentPlaylistVarInt( "mixtape_abandon_penalty_time_4", 60 * 20 ) // 20 minutes
	else
		banLength = GetCurrentPlaylistVarInt( "mixtape_abandon_penalty_time_" + numGamesAbandoned , 60 * 2 ) //2 minutes

	return banLength
}
#endif // CLIENT || SERVER

//TODO: Rename these to mixtape instead of control
#if DEV && SERVER
void function GenerateMixtapeAbandon_PDef()
{
	DEV_PDefGen_BeginFieldGroup( "Control Vars" )

	DEV_PDefGen_AddField_Bool( "lastGameControlAbandon" )
	DEV_PDefGen_AddField_Int( "lastTimeGameWasControlAbandoned" )
	DEV_PDefGen_AddField_Int( "numControlAbandons" )

	DEV_PDefGen_EndFieldGroup()
}
#endif // DEV && SERVER

#if CLIENT
// Display a warning message announcement in the top center of the screen
void function GamemodeUtility_AnnouncementMessageWarning( entity player, string messageText, vector titleColor, string soundAlias, float duration )
{
	AnnouncementData announcement = Announcement_Create( messageText )
	Announcement_SetHeaderText( announcement, " " )
	Announcement_SetSubText( announcement, " " )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_GENERIC_WARNING )
	Announcement_SetSoundAlias( announcement, soundAlias )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetDuration( announcement, duration )

	Announcement_SetTitleColor( announcement, titleColor )
	Announcement_SetVerticalOffset( announcement, 140 )
	AnnouncementFromClass( player, announcement )
}
#endif // CLIENT

#if CLIENT
// Get colors defined in color palettes for objective gamemodes. These were originally defined for Control but other objective/capture gamemode should be using the same colors
vector function GamemodeUtility_GetColorVectorForCaptureObjectiveState( int objectiveState, bool isRuiUIColor = false )
{
	vector color

	switch( objectiveState )
	{
		case eGamemodeUtilityCaptureObjectiveColorState.NEUTRAL:
			color = GetKeyColor( COLORID_COLORSWATCH_WHITE )
			break
		case eGamemodeUtilityCaptureObjectiveColorState.CONTESTED:
			color = GetKeyColor( COLORID_CONTROL_CONTESTED )
			break
		case eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED:
			color = GetKeyColor( COLORID_CONTROL_FRIENDLY )
			break
		case eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED:
			color = GetKeyColor( COLORID_CONTROL_ENEMY )
			break
		default:
			color = GetKeyColor( COLORID_COLORSWATCH_WHITE )
			break
	}

	if ( isRuiUIColor )
		color = SrgbToLinear( color / 255 )

	return color
}
#endif // CLIENT

#if CLIENT
bool function GamemodeUtility_IsPlayerOnTeamObserver( entity player )
{
	if( !IsValid( player ) )
		return false

	return player.GetTeam() == TEAM_SPECTATOR
}
#endif

#if CLIENT
// Get an array of players that are either on the same team/alliance as the local player or the enemy team/alliance
// This function is adjusted for spectators as well
array<entity> function GamemodeUtility_GetLocalTeamPlayers( bool friendly )
{
	// If the player is spectating, give them a set team so there is consistency between what they see as friendly vs enemy
	int localPlayerTeam = GetLocalClientPlayer().GetTeam()
	if ( IsLocalPlayerOnTeamSpectator() )
		localPlayerTeam = TEAM_IMC

	// If we are grabbing the friendly team of players we base it off the players team, otherwise we want to grab the enemy team
	int teamOrAllianceToReturn
	array<entity> localTeamPlayersArray

	if ( AllianceProximity_IsUsingAlliances() )
	{
		int localPlayerAlliance = AllianceProximity_GetAllianceFromTeamWithObserverCorrection( localPlayerTeam )
		// For now modes only use 2 alliances, this will need to be updated if we change this. The AllianceProximity_GetOtherAlliance function will assert if we are in a mode with more than 2 alliances
		teamOrAllianceToReturn = friendly ? localPlayerAlliance : AllianceProximity_GetOtherAlliance( localPlayerAlliance )
		localTeamPlayersArray = AllianceProximity_GetAllPlayersInAlliance( teamOrAllianceToReturn, false )
	}
	else
	{
		teamOrAllianceToReturn = friendly ? localPlayerTeam : GetOtherTeam( localPlayerTeam )
		localTeamPlayersArray = GetPlayerArrayOfTeam( teamOrAllianceToReturn )
	}

	return localTeamPlayersArray
}
#endif

#if SERVER
// Check if the player changed legends; if they did update PIN data
void function GamemodeUtility_CheckForMidMatchLegendChange( entity player )
{
	if ( !IsValid( player ) || !LoadoutSlot_IsReady( ToEHI( player ), Loadout_Character() ) )
		return

	string currentLegend = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() ) )
	if ( player in file.playerToLastUsedLegendClass )
	{
		if ( currentLegend != file.playerToLastUsedLegendClass[ player ] )
		{
			array<string> legendClassesOffered
			legendClassesOffered = GetStringArrayAvailableClassesForPlayer( player )
			PIN_PlayerClassMidMatchChange( player, legendClassesOffered )
			file.playerToLastUsedLegendClass[ player ] = currentLegend
		}
	}
	else
	{
		file.playerToLastUsedLegendClass[ player ] <- currentLegend
	}
}
#endif // SERVER

#if SERVER
// Heal health and shields and then play healing VFX if desired, support function for OnExecute and OnFinisher healing callbacks
// If shouldAllowHealthLoss is true we don't care what the current health values are and we just set to the passed in values, otherwise we only increase health\shield
// Return whether health values were affected
bool function GamemodeUtility_HealPlayerHealthAndShieldsByPercentage( entity player, float percentToSetHealth, float percentToSetShield, bool shouldAllowHealthLoss, bool shouldPlayEffectsOnHeal )
{
	bool didHeal = false
	if ( percentToSetHealth >= 0.0 || percentToSetShield >= 0.0 )
	{
		didHeal = SetHealthAndShieldByPercentage( player, percentToSetHealth, percentToSetShield, shouldAllowHealthLoss )

		if ( shouldPlayEffectsOnHeal && didHeal )
			GamemodeUtility_PlayHealEffects( player )
	}

	return didHeal
}
#endif //SERVER

#if SERVER
// Heal health and if it is full go on to heal shields by the specified amount and then play healing VFX if desired
// Return whether health values were affected
bool function GamemodeUtility_HealPlayerByAmount( entity player, int healingAmount, bool shouldPlayEffectsOnHeal )
{
	bool didHeal = false
	if ( healingAmount >= 0)
	{
		didHeal = GiveHealthAndShieldToPlayer( player, healingAmount ) > 0

		if ( shouldPlayEffectsOnHeal && didHeal )
			GamemodeUtility_PlayHealEffects( player )
	}

	return didHeal
}
#endif //SERVER

#if SERVER
// Play healing VFX, Audio, and screen effects
void function GamemodeUtility_PlayHealEffects( entity player )
{
	// This function can get called from global function calls to the heal function which could result in these effects not being precached. If that is the case, precache them now
	if ( !file.didPrecacheHealFX )
	{
		PrecacheParticleSystem( FX_HEAL_HEALED_3P )
		PrecacheParticleSystem( FX_HEAL_HEALED_FP )
		file.didPrecacheHealFX = true
	}

	thread GamemodeUtility_PlayHealEffects_Thread( player )
}
#endif // SERVER

#if SERVER
void function GamemodeUtility_IncrementRoundScore( int teamToIncrement, int roundsToIncrement )
{
	if ( teamToIncrement >= TEAM_MULTITEAM_FIRST )
	{
		int roundWins = GameRules_GetTeamScore2( teamToIncrement )
		int newRoundWins = roundWins + roundsToIncrement

		if ( AllianceProximity_IsUsingAlliances() )
		{
			int winningAlliance = AllianceProximity_GetAllianceFromTeam(teamToIncrement)
			array < int > teamsInWinningAllianceArray = AllianceProximity_GetTeamsInAlliance( winningAlliance )

			foreach ( team in teamsInWinningAllianceArray )
			{
				GameRules_SetTeamScore2( team, newRoundWins )

				if ( IsRoundBasedUsingTeamScore() == false && !GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) )
					GameRules_SetTeamScore( team, newRoundWins ) // HACK; client scorebars don't know how to display TeamScore2
			}
		}
		else
		{
			GameRules_SetTeamScore2( teamToIncrement, newRoundWins )

			if ( IsRoundBasedUsingTeamScore() == false && !GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) )
				GameRules_SetTeamScore( teamToIncrement, newRoundWins ) // HACK; client scorebars don't know how to display TeamScore2
		}
	}
}
#endif // SERVER

#if SERVER
// Play healing VFX and SFX when triggering health/shield healing through script
void function GamemodeUtility_PlayHealEffects_Thread( entity player )
{
	AssertIsNewThread()

	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy" )
	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )

	entity bodyFX3p
	entity bodyFX1p
	int bodyFX3pFXID = GetParticleSystemIndex( FX_HEAL_HEALED_3P )
	int bodyFX1pFXID = GetParticleSystemIndex( FX_HEAL_HEALED_FP )

	EmitSoundOnEntityOnlyToPlayer( player, player, HEAL_START_FP )
	EmitSoundOnEntityExceptToPlayer( player, player, HEAL_START_3P )

	bodyFX3p = StartParticleEffectOnEntity_ReturnEntity( player, bodyFX3pFXID, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	bodyFX3p.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER )

	if ( player.GetShieldHealth() == 0 || player.GetShieldHealth() >= player.GetShieldHealthMax() ) // play an effect for players wen we're healing health, cl_pilot_health_hud.gnut handles shield FP vfxs otherwise
	{
		bodyFX1p = StartParticleEffectOnEntity_ReturnEntity( player, bodyFX1pFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
		bodyFX1p.kv.VisibilityFlags = ( ENTITY_VISIBLE_ONLY_PARENT_PLAYER )
	}

	OnThreadEnd(
		function() : ( player, bodyFX3p, bodyFX1p )
		{
			if ( IsValid( bodyFX3p ) )
			{
				EffectStop( bodyFX3p )
			}

			if ( IsValid( bodyFX1p ) )
			{
				EffectStop( bodyFX1p )
			}
		}
	)

	Wait( HEALING_VFX_DURATION )
}
#endif // SERVER

#if SERVER
bool function GamemodeUtility_AreMultipleTeamsPopulated()
{
	array<entity> connectedPlayers = GetConnectedPlayers()

	if ( AllianceProximity_IsUsingAlliances() )
	{
		int populatedAllianceCount = 0
		foreach( alliance in AllianceProximity_GetAllAlliances() )
		{
			array<entity> players = AllianceProximity_GetAllPlayersInAlliance(alliance, false)
			if ( players.len() > 0 )
				populatedAllianceCount++
		}
		if ( populatedAllianceCount > 1 )
			return true
	}
	else
	{
		int firstFoundTeam = TEAM_INVALID
		foreach( player in connectedPlayers )
		{
			int currentPlayersTeam = player.GetTeam()
			if ( currentPlayersTeam < TEAM_MULTITEAM_FIRST)
				continue

			if (firstFoundTeam == TEAM_INVALID)
			{
				firstFoundTeam = currentPlayersTeam
			}
			else if (firstFoundTeam != currentPlayersTeam)
			{
				return true
			}
		}
	}

	return false
}
#endif // SERVER

bool function GamemodeUtility_GetMixtapeAbandonPenaltyActive()
{
	return GetCurrentPlaylistVarBool( "mixtape_match_abandon_penalty", false )
}

#if SERVER
// Did the victim previously kill the killer player?
bool function GamemodeUtility_WasRevengeKill( entity victim, entity killer )
{
	if ( !IsValid( killer ) )
		return false

	if ( !IsAlive( killer ) )
		return false

	if ( !killer.IsPlayer() )
		return false

	if ( IsValid( victim ) && !victim.IsPlayer() )
		return false

	if ( killer.Player_IsFreefalling() ) // S3: Player_IsSkydiving() renamed to Player_IsFreefalling()
		return false //don't do delayed revenge

	if ( killer.e.previousKillers.len() == 0 )
		return false

	if ( killer.e.previousKillers.contains( victim ) )
		return true

	return false
}
#endif //SERVER

#if SERVER
// Remove a player from the revenge list for the killer player
void function GamemodeUtility_RemovePlayerFromRevengeKillList( entity victim, entity killer )
{
	if ( killer.e.previousKillers.contains( victim ) )
		killer.e.previousKillers.fastremovebyvalue( victim )

}
#endif //SERVER

#if SERVER
const float THROW_STRENGTH = 75.0
const string GADGET_SLOT = "gadgetslot"
const string ARMOR_SLOT = "armor"
const string HELMET_SLOT = "helmet"
const string INCAPSHIELD_SLOT = "incapshield"
const string BACKPACK_SLOT = "backpack"
void function GamemodeUtility_DropLoot( entity player, int defaultEquipmentTier = 2, bool dropMainHand = true, bool dropSecondary = false, bool dropOrdance = true, bool dropGadget = false, bool dropEquipment = false, bool shouldResetArmorEvoLevelOnDrop = false )
{
	if ( !IsValid( player ) )
		return

	// Don't want to be dropping loot once the game is ended
	if ( GetGameState() != eGameState.Playing )
		return

	if ( dropOrdance )
	{
		// Drop held ordnance
		array<ConsumableInventoryItem> playerInventory = SURVIVAL_GetPlayerInventory( player )
		int remainingOrdnanceToDrop                    = GamemodeUtility_GetMaxDroppedGrenadesOnDeath()
		int ordnanceToDrop                             = 0

		foreach ( index, item in playerInventory )
		{
			if ( remainingOrdnanceToDrop <= 0 )
				break

			if ( !IsValid( item ) )
				continue

			LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( item.type )

			if ( lootData.lootType == eLootType.ORDNANCE )
			{
				ordnanceToDrop = minint( remainingOrdnanceToDrop, item.count )
				remainingOrdnanceToDrop -= ordnanceToDrop

				SURVIVAL_DropBackpackItem( player, lootData.ref, ordnanceToDrop, null, true, true, false )
			}
		}
	}

	// Drop the players weapons
	array<entity> weapons = SURVIVAL_GetPrimaryWeaponsSorted( player )
	int weaponIndex = 0
	foreach( weapon in weapons )
	{
		if ( IsValid( weapon ) && (dropMainHand && weaponIndex == 0) || (dropSecondary && weaponIndex == 1))
			SURVIVAL_DropWeapon( player, weapon, player.EyePosition(), RandomVecInDomeWithFOV( <0, 0, 1>, 45 ) * RandomFloatRange( 100, 250 ) )

		weaponIndex++
	}

	// Drop the players equipment
	foreach ( slot, slotData in EquipmentSlot_GetAllEquipmentSlots() )
	{
		switch( slot )
		{
			case GADGET_SLOT: // Drop whatever survival slot items are being held
				if(dropGadget)
					SURVIVAL_DropPlayerEquipment( player, slot, false, false )
				break
			case ARMOR_SLOT: // For equipment we only want to drop it if it is better than the default players are getting on spawn
			case HELMET_SLOT:
			case INCAPSHIELD_SLOT:
			case BACKPACK_SLOT:
				string equipment = Inventory_GetPlayerEquipment( player, slot )
				entity droppedEquipment
				if ( equipment != "" && SURVIVAL_Loot_IsRefValid( equipment ) && dropEquipment )
				{
					LootData data = SURVIVAL_Loot_GetLootDataByRef( equipment )
					if ( data.tier > defaultEquipmentTier )
						droppedEquipment = SURVIVAL_DropPlayerEquipment( player, slot, false, false )

					if ( IsValid( droppedEquipment ) && data.lootType == eLootType.ARMOR )
						GamemodeUtility_SetArmorSettingsOnDrop( player, data, droppedEquipment, shouldResetArmorEvoLevelOnDrop )
				}
				break
			default:
				break
		}
	}
}
#endif //SERVER

#if SERVER
// Set proper armor evo level and health when we drop it
void function GamemodeUtility_SetArmorSettingsOnDrop( entity player, LootData armorData, entity armor, bool shouldResetEvoProgress )
{
	if ( armorData.lootType != eLootType.ARMOR )
		return

	// If the Player is alive, leave the armor at its current health. If the player died, refill the armor
	if ( !IsAlive( player ) )
	{
		int shieldHealth = SURVIVAL_GetArmorShieldCapacity( armorData.tier )
		SetPropSurvivalMainPropertyOnEnt( armor, shieldHealth )

		// If we want Evo Progress to reset on armor, reset it here
		if ( shouldResetEvoProgress && EvolvingArmor_IsEquipmentEvolvingArmor( armorData.ref ) )
		{
			SetPropSurvivalExtraPropertyOnEnt( armor, EvolvingArmor_GetRequirementForEvolution( armorData.tier ) )
		}
	}
}
#endif //SERVER

#if SERVER
array< entity > function GamemodeUtility_SpawnDroppedAmmo ( entity victim, entity attacker, var attackerDamageInfo, int ammoCount, float throwStrength = THROW_STRENGTH )
{
	array< entity > droppedLoot = []

	if ( SURVIVAL_Loot_IsAmmoSpawningDisabled() )
		return droppedLoot

	// Drop ammo at the victim's death location
	// Figure out the ammo type for one of the attackers weapons and spawn some of that ammo type
	string ammoTypePrimary = ""
	if ( attackerDamageInfo != null )
	{
		entity damageWeapon = DamageInfo_GetWeapon( attackerDamageInfo )
		if ( IsValid( damageWeapon ) && damageWeapon.GetActiveAmmoSource() == AMMOSOURCE_POOL )
		{
			ammoTypePrimary = GetWeaponAmmoTypeFromWeaponEnt( damageWeapon )
		}
	}

	if ( ammoTypePrimary != "" )
	{
		droppedLoot.extend( SpawnAndThrowItems_ReturnItems( victim, ammoTypePrimary, ammoCount, throwStrength, eSpawnSource.PLAYER_DEATH ) )
	}
	else
	{
		SpawnRandomAmmoTypeOnVictim( ammoCount, victim, throwStrength )
	}
	// Spawn some random ammo type as well
	SpawnRandomAmmoTypeOnVictim( ammoCount, victim, throwStrength )
	return droppedLoot
}
#endif //SERVER

#if SERVER
LootData function GamemodeUtility_GetPlayerArmorData( entity player )
{
	LootData armorData

	if ( !IsValid( player ) )
	{
		return armorData
	}

	armorData = EquipmentSlot_GetEquippedLootDataForSlot( player, "armor" )
	if ( armorData.ref == "" )
	{
		return armorData
	}

	// Store the EVO progress
	{
		int evoProgress = 0
		if ( EvolvingArmor_IsEquipmentEvolvingArmor( armorData.ref ) )
		{
			evoProgress = IsValid( player ) ? EvolvingArmor_GetEvolutionProgress( player ) : EvolvingArmor_GetRequirementForEvolution( armorData.tier )
		}

		armorData.extraData[ eExtraDataType.INT_ARMOR_EVO ] <- evoProgress
	}

	// Give the armor full shields
	{
		int shieldsContainedInArmor = SURVIVAL_GetArmorShieldCapacity( armorData.tier )
		if ( EvolvingArmor_IsEquipmentEvolvingArmor( armorData.ref ) )
		{
			shieldsContainedInArmor = EvolvingArmor_GetEvolvingArmorHealthForTier( armorData.tier )
		}
		                    
		armorData.extraData[ eExtraDataType.INT_ARMOR_SHIELDS ] <- shieldsContainedInArmor
	}

	return armorData
}
#endif // SERVER

#if SERVER
entity function GamemodeUtility_SpawnArmor( entity armorSource, LootData armorData, float throwStrength = THROW_STRENGTH, int spawnSource = eSpawnSource.PLAYER_DEATH, bool spawnInSafeLocation = false )
{
	entity armorLoot

	if ( !IsValid( armorSource ) )
	{
		return armorLoot
	}

	if ( armorData.ref == "" )
	{
		return armorLoot
	}

	vector armorSpawnOrigin = armorSource.GetOrigin()
	if ( spawnInSafeLocation )
	{
		armorSpawnOrigin = GetSafeLocation( armorSpawnOrigin )
	}

	if ( throwStrength > 0.0 )
	{
		array< entity > spawnedLoot = SpawnAndThrowItems_ReturnItems( armorSource, armorData.ref, 1, throwStrength, spawnSource )
		armorLoot = spawnedLoot[0]
	}
	else
	{
		armorLoot = SpawnGenericLoot( armorData.ref, armorSpawnOrigin )
		SetItemSpawnSource( armorLoot, spawnSource, armorSource )
	}

	int shieldsContainedInArmor = SURVIVAL_GetArmorShieldCapacity( armorData.tier )
	if ( eExtraDataType.INT_ARMOR_SHIELDS in armorData.extraData )
	{
		shieldsContainedInArmor = expect int( armorData.extraData[ eExtraDataType.INT_ARMOR_SHIELDS ] )
	}

	int evoProgress = 0
	if ( eExtraDataType.INT_ARMOR_EVO in armorData.extraData )
	{
		evoProgress = expect int( armorData.extraData[ eExtraDataType.INT_ARMOR_EVO ] )
	}

	SetPropSurvivalMainPropertyOnEnt( armorLoot, shieldsContainedInArmor )
	SetPropSurvivalExtraPropertyOnEnt( armorLoot, evoProgress )

	return armorLoot
}
#endif // SERVER

#if SERVER
// Spawn random types of ammo at the location of a killed player
void function SpawnRandomAmmoTypeOnVictim( int count, entity victim, float throwStrength = THROW_STRENGTH )
{
	for ( int i = 0; i < count; i++ )
	{
		string randAmmoType = SURVIVAL_Loot_GetRandomLootOfSpecifiedTierAndType( 1, eLootType.AMMO )
		array< entity > droppedLoot = SpawnAndThrowItems_ReturnItems( victim, randAmmoType, 1, throwStrength, eSpawnSource.PLAYER_DEATH )
	}
}
#endif // SERVER

int function GamemodeUtility_GetMaxDroppedGrenadesOnDeath()
{
	return GetCurrentPlaylistVarInt( "grenade_ondeath_max_spawncount", 1 )
}

#if SERVER
void function GamemodeUtility_DestroyDeathboxOnDelay( entity box,  entity attacker, int damageSourceID )
{
	thread DestroyDeathboxOnDelay_Thread(box)
}
#endif

#if SERVER
void function DestroyDeathboxOnDelay_Thread( entity box )
{
	EndSignal( svGlobal.levelEnt, "GameEnd", GAMEMODE_WINNER_DETERMINED_SIGNAL_NAME )
	EndSignal( box, "OnDestroy" )

	if ( !IsValid( box ) )
		return

	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	float duration = GetPlaylistVar_DeathboxDuration()
	float endTime = Time() + duration
	while ( Time() < endTime && GetGameState() <= eGameState.Playing)
	{
		WaitFrame()
	}
	// If someone is sitting near/using a Deathbox, don't destroy it.
	array<entity> nearbyPlayers = GetNearbyPlayers(box.GetOrigin(), DEATH_BOX_MAX_DIST )
	while( nearbyPlayers.len() > 0 )
	{
		nearbyPlayers = GetNearbyPlayers( box.GetOrigin(), DEATH_BOX_MAX_DIST )
		WaitFrame()
	}

	if ( IsValid( box ) )
		box.Destroy()
}
#endif

float function GetPlaylistVar_DeathboxDuration()
{
	return GetCurrentPlaylistVarFloat( "deathbox_duration", 60.0 )
}

// Spawn a bonus item from opening a LootBin. Simillar to how Treasure packs spawn.
#if SERVER
void function GamemodeUtility_SpawnBonusLoot ( entity player, entity lootBin, array<entity> regularLootEnts, array<entity> secretLootEnts, void functionref( bool, bool ) preventLootRevealFunc )
{
	if ( !IsValid( player ) )
		return

	float percentChance = GetCurrentPlaylistVarFloat( "lootbin_bonusloot_percentchance", 0.0 )

	float diceRoll = RandomFloatRange(0.0 , 1.0)

	if ( diceRoll < percentChance)
	{
		thread function() : (player, lootBin)
		{
			string itemToSpawn = GetCurrentPlaylistVarString( "lootbin_bonusloot_itemstring", "" )

			lootBin.EndSignal( "OnDestroy" )

			wait(LOOTBIN_SPAWN_TIME)
			ThrowLootParams params
			params.dropOrg               = lootBin.GetOrigin() + <0, 0, 32>
			params.fwd                   = ((lootBin.GetForwardVector() + <0, 0, 0.75>) * 0.5)
			params.ref                   = itemToSpawn
			params.spawnAngles           = (lootBin.GetAngles() + <0, RandomFloatRange( -15, 15 ), 0>)
			params.throwVelocityRange[0] = 225
			params.throwVelocityRange[1] = 250
			entity money = SURVIVAL_ThrowLootFromPointEx( params )
		}()
	}


}
#endif

#if SERVER
// Spawn a list of loot items when a player is killed
void function GamemodeUtility_SpawnBonusLootOnPlayer(entity player, float throwStrength = THROW_STRENGTH, int spawnSource = eSpawnSource.PLAYER_DEATH, bool spawnInSafeLocation = false )
{
	if ( !IsValid ( player ) )
	{
		return
	}

	string lootToDropString = GetCurrentPlaylistVarString( "bonus_loot_to_spawn_on_player_kill", "" )
	if ( lootToDropString != "" )
	{
		array<string> lootStrings = GetTrimmedSplitLoweredString( lootToDropString, " ")
		foreach ( string lootDef in lootStrings )
		{
			array<string> splitBonusLootToSpawn = GetTrimmedSplitString( lootDef, ":" )
			Assert( splitBonusLootToSpawn.len() == 2 )
			string lootRef = splitBonusLootToSpawn[0]
			int lootDistribution = int( splitBonusLootToSpawn[1] )

			SpawnAndThrowItems_ReturnItems( player, lootRef, lootDistribution, throwStrength, eSpawnSource.PLAYER_DEATH )
		}
	}
}
#endif //SERVER

#if CLIENT
// Thread function that waits for the player to land from free fall at the start of the match before enabling DVS Tweak
// DVS tweak lowers visual fidelity to improve performance in performance intensive modes
// It must be triggered after the skydive state because the skydive state has its own DVS settings and they conflict and cause and error if both are enabled at the same time
void function GamemodeUtility_ManageDVSTweakOnPlayer_Thread()
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	entity localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) )
		return

	printt( "GAMEMODE UTILITY: " +  FUNC_NAME() + " is running for " + localPlayer )

	EndSignal( localPlayer, "OnDestroy" )

	OnThreadEnd(
		function() : ( localPlayer )
		{
			printt( "GAMEMODE UTILITY: GamemodeUtility_ManageDVSTweakOnPlayer_Thread is going to set LowerDVSForGameMode to false from thread end function" )
			GamemodeUtility_SetDVSSettingsForGamemode( false )
		}
	)

	// If the player isn't at the point where they have landed from the match start free fall, wait until they do
	if ( localPlayer.GetPlayerNetBool( "isJumpingWithSquad" ) || localPlayer.GetPlayerNetBool( "isJumpmaster" ) ||  GetGameState() < eGameState.Playing )
		localPlayer.WaitSignal( "DroppodLanded" )

	if ( GetGameState() < eGameState.WinnerDetermined )
	{
		printt( "GAMEMODE UTILITY: " +  FUNC_NAME() + " is going to set LowerDVSForGameMode to true ( player landed from free fall )" )
		GamemodeUtility_SetDVSSettingsForGamemode( true )
	}

	// Turn off DVS tweak when the match ends or the player disconnects/crashes
	ClWaittillGameStateOrHigher( eGameState.WinnerDetermined )
}
#endif

#if CLIENT
// Set whether we force DVS settings ( on/ off ) for the gamemode
// This is done for modes with performance concerns to force the settings for the player. There is a script error if you try to force the settings On if they are already On or off if they are not On yet
// This should only be done if the mode specifically needs it, it temporarily overrides the players own settings
// If a player overrides the settings manually while they have been set here, we don't do anything to force the settings again
// The settings can only be turned on after the player has landed from skydive, skydive sets its own DVS overrides so there would be a conflict
// The settings need to be turned off when the match ends for the player
void function GamemodeUtility_SetDVSSettingsForGamemode( bool shouldEnableForcedDVSSettings )
{
	printt( "GAMEMODE UTILITY: " +  FUNC_NAME() + " Running with shouldEnableForcedDVSSettings : " + shouldEnableForcedDVSSettings )

	// Only enable DVS override when the playlist has it enabled
	if ( shouldEnableForcedDVSSettings && GamemodeUtility_GetShouldTweakDVSForGamemode() && !file.isLoweringDVSForGamemode )
	{
		LowerDVSForGameMode ( true )
		file.isLoweringDVSForGamemode = true
		printt( "GAMEMODE UTILITY: " +  FUNC_NAME() + " Set LowerDVSForGameMode to : true" )
	}

	// Allow disabling of the DVS override at any time, it should only be active when a gamemode explicitly needs it but should be disabled at all other times
	if ( !shouldEnableForcedDVSSettings && file.isLoweringDVSForGamemode)
	{
		LowerDVSForGameMode ( false )
		file.isLoweringDVSForGamemode = false
		printt( "GAMEMODE UTILITY: " +  FUNC_NAME() + " Set LowerDVSForGameMode to : false" )
	}
}
#endif // CLIENT

// Return whether the passed in team index is within the valid player team range for the mode
bool function GamemodeUtility_GetIsTeamIndexValidPlayerTeam( int teamIndex )
{
	return TEAM_MULTITEAM_FIRST <= teamIndex && teamIndex < MAX_TEAMS + TEAM_MULTITEAM_FIRST
}

#if UI
// Return the expected playlist name for a mode depending on whether the mode is active or we are in the Lobby ( usually used to get correct gamemode values for the About screen )
string function GamemodeUtility_GetPlaylist()
{
	// LobbyPlaylist_GetSelectedPlaylist not available, GetCurrentPlaylistName works in all contexts
	return GetCurrentPlaylistName()
}
#endif // UI

#if SERVER
// Used to reset player states, destroy Ult and Tacticals etc to prepare players for a reset or redeploy
void function GamemodeUtility_ResetPlayer_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	foreach ( trap in player.e.activeTraps )
	{
		if ( IsValid( trap ) )
			trap.Destroy()
	}
	foreach ( trap in player.e.activeUltimateTraps )
	{
		if ( IsValid( trap ) )
			trap.Destroy()
	}
	if ( !player.IsBot() && IsValid( player.p.decoy ) )
		player.p.decoy.Destroy()

	if ( !IsAlive( player ) )
		return

	if ( Bleedout_IsBleedingOut( player ) )
	{
		Bleedout_ForceStop( player )
		Bleedout_ReviveForceStop( player )
		WaitFrame()
	}

	Crafting_CloseCraftingMenu( player )

	player.Signal( "DeathTotem_PreRecallPlayer" )

	CancelPlayerStatesData states
	states.cancelZipline = true
	states.cancelGrapple = true
	states.cancelPhaseTunnel = true
	states.cancelPhaseWalk = true
	states.cancelRevive = true
	states.cancelCryptoDrone = true
	states.cancelTotem = true
	states.cancelMainOrAltHandAbility = true
	CancelPlayerStates( player, states )

	player.Signal( "PhaseTunnel_EndPlacement" )
	player.Signal( "PhaseTunnel_DestroyPlacement" )
	player.Signal( "PhaseTunnel_CancelPhaseTunnelUse" )
	player.Signal( "HuntMode_ForceAbilityStop" )
	player.Signal( "ScriptAnimStop" )

	WaitFrame()

	                     
		if ( HoverVehicle_IsPlayerInAnyVehicle( player ) )
		{
			Vehicle_KickPlayer_ForOtherReason( player )
			WaitFrame()
		}
       

	if ( player.Player_IsFreefalling() ) // S3: Player_IsSkydiving() renamed to Player_IsFreefalling()
	{
		Signal( player, "PlayerSkyDive" )
		WaitFrame()
	}

	// S22+ player.GetTurret() entity method not available in S3
	// if ( IsValid( player.GetTurret() ) )
	// {
	// 	MountedTurretPlaceable_ClearDriver_ForOtherReason( player.GetTurret() )
	// 	WaitFrame()
	// }
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Dev Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if DEV && SERVER
// Do an in world debug draw of the culling circle used in gamemodes to cull gameplay objects/triggers/doors etc that are outside of the circle
void function GamemodeUtility_DebugDrawCullingCircle_Dev()
{
	if ( !GamemodeUtility_GetIsUsingCullCircleEnts() )
	{
		printt( "GAMEMODE UTILITY: Attempting to debug draw the culling circle but it is not enabled for this playlist" )
		return
	}

	string playlistCircle = GetCurrentPlaylistVarString( "cull_entity_spawn_circle", "" )

	if ( playlistCircle != "" )
	{
		printt( "GAMEMODE UTILITY: Attempting to debug draw the culling circle the playlist value we are using is: " + playlistCircle )

		array< float > circleValuesArray = GamemodeUtility_ParseCircleString( playlistCircle )

		// Make sure we are getting the expected number of float values. If we are, do the debug draw
		if ( circleValuesArray.len() == EXPECTED_PARSED_CIRCLE_VALUE_COUNT )
		{
			vector circlePos = < circleValuesArray[ 0 ], circleValuesArray[ 1 ], circleValuesArray[ 2 ] >
			float circleRadius = circleValuesArray[ 3 ]

			printt( "GAMEMODE UTILITY: Going to debug draw the culling circle with the position: " + circlePos + " and the radius: " + circleRadius )
			DebugDrawCylinder( circlePos, < -90, 0, 0 >, circleRadius, 128, COLOR_RED, true, 999999 )
		}
	}
}
#endif // DEV && SERVER

array< vector > function GamemodeUtility_ParseStringOfVectors( string positionsRawString )
{
	array<string> positionStrings = GetTrimmedSplitString( positionsRawString, "," )
	array<vector> positions
	foreach( positionString in positionStrings )
	{
		vector pos = GamemodeUtility_ParseVectorString( positionString )
		positions.append( pos )
	}

	return positions
}

vector function GamemodeUtility_ParseVectorString( string vectorString )
{
	array< string > valuesAsStrings = GetTrimmedSplitString( vectorString, WHITESPACE_CHARACTERS )
	Assert( valuesAsStrings.len() == 3, "vectorString should have format \"x y z\"")

	vector vec = < float( valuesAsStrings[0] ), float( valuesAsStrings[1] ), float( valuesAsStrings[2] ) >
	return vec
}

// Support function for getting a parsed array of floats from the playlist vars for the culling circle in the GamemodeUtility_DebugDrawCullingCircle_Dev function
array< float > function GamemodeUtility_ParseCircleString( string circleString )
{
	// This kind of sucks but the way I get the values needed is very hardcoded here.
	// The array basically consists of the following values: "<", pos x value, pos y value, pos z value, ">", radius, null
	// I strip out the bad values and then convert the values I want to floats
	array< float > circleValuesArray
	// First strip out the "," in the string
	array< string > circleStringValuesArray = GetTrimmedSplitString( circleString, "," )

	// Strip out the "<" symbol in the string
	circleString            = GamemodeUtility_GetParsedStringForCircleValues( circleStringValuesArray )
	circleStringValuesArray = GetTrimmedSplitString( circleString, "<" )

	// Strip out the ">" symbol in the string
	circleString            = GamemodeUtility_GetParsedStringForCircleValues( circleStringValuesArray )
	circleStringValuesArray = GetTrimmedSplitString( circleString, ">" )

	// Finally we separate the values into just the floats with no spaces
	circleString            = GamemodeUtility_GetParsedStringForCircleValues( circleStringValuesArray )
	circleStringValuesArray = GetTrimmedSplitString( circleString, " " )

	// Put together an array of the float values we need
	foreach( item in circleStringValuesArray )
	{
		circleValuesArray.append( float( item ) )
	}

	return circleValuesArray
}

// Support function for getting a parsed string out of the values we get from the playlist vars for the culling circle in the GamemodeUtility_DebugDrawCullingCircle_Dev function
string function GamemodeUtility_GetParsedStringForCircleValues( array< string > stringValuesArray )
{
	string parsedPlaylistString = ""
	foreach( item in stringValuesArray )
	{
		parsedPlaylistString += " " + item
	}

	return parsedPlaylistString
}

#if DEV && SERVER
// Disable Match Time Limit
void function GamemodeUtility_DisableMatchTimeLimit_Dev()
{
	printt( "GAMEMODE UTILITY: Disabling Match Time Limit through Debug Command" )
	svGlobal.levelEnt.Signal( "GamemodeUtility_DisableMatchTimeLimit" )
}
#endif // DEV && SERVER
