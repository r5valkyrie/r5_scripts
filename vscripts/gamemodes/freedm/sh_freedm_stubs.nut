// ============================================================================
// FreeDM Stubs - Functions not yet implemented
// Loaded BEFORE all other FreeDM scripts to provide missing symbols.
// These stubs allow the FreeDM scripts to compile and run.
// ============================================================================

// ======================== CONSTANTS ========================

// ALLIANCE_NONE, ALLIANCE_A, ALLIANCE_B now defined in mp/sh_alliance_proximity.gnut
global const string SNIPERULT_WEAPON_NAME = "mp_ability_sniper_ult" // Vantage sniper ultimate (S14+)

// COLORID_CONTROL_FRIENDLY/ENEMY/CONTESTED now defined in mp/sh_alliance_proximity.gnut

// ======================== ENUMS ========================

// eSurvivalCommentaryBucket: FreeDM values added to existing enum in sh_survival_commentary.gnut
// eGameModes: FREEDM added to existing enum in sh_gamemodes.gnut

global enum eGameModeVariants
{
	FREEDM_TDM = 0
	FREEDM_LOCKDOWN = 1
	FREEDM_GUNGAME = 2
	SURVIVAL_WINTEREXPRESS = 100
	SURVIVAL_BATTLE_RUSH = 101
	SURVIVAL_SHADOW_ARMY = 102
	SURVIVAL_RANKED = 103
	SURVIVAL_SOLOS = 104
	SURVIVAL_FIRING_RANGE = 105
	SURVIVAL_VALENTINES_S15 = 106
	SURVIVAL_RECRUIT = 107
	SURVIVAL_EXPLORE = 108
	SURVIVAL_QUADS = 109
	SURVIVAL_SHADOW_ROYALE = 110
	SURVIVAL_STRIKEOUT = 111
	SURVIVAL_TRAINING = 112
	SURVIVAL_GOLDEN_HORSE = 113
}

global enum eCrowdNoiseMeterModifiers
{
	LEAD_CHANGE_POSITIVE = 0
	LEAD_CHANGE_NEGATIVE
	CLOSE_TO_WINNING_MATCH_POSITIVE
	CLOSE_TO_WINNING_MATCH_NEGATIVE
	MATCH_HALFWAY_SCORE_REACHED_POSITIVE
	MATCH_HALFWAY_SCORE_REACHED_NEGATIVE
	WIN_BY_LARGE_MARGIN_POSITIVE
	WIN_BY_MEDIUM_MARGIN_POSITIVE
	WIN_BY_SMALL_MARGIN_POSITIVE
}

// eXPType: already defined in sh_xp.gnut with OBJECTIVE_CAPTURE_DURATION=22, BONUS_FINAL_KILL=14
// eUpgradeXPActions: now defined in pilot/sh_pilot_passive_upgrade_core.gnut

// ======================== CONSTANTS ========================
// NOTE: Only define constants NOT already provided by the engine or other scripts.
// COLORID_AIRDROP_DEFAULT_COLOR, ALLIANCE_A/B, ANNOUNCEMENT_STYLE_*, CHEVREX_AIRDROP_SKIN_INDEX
// are already defined natively — do NOT redefine them here.

// ======================== STRUCTS ========================

global struct WeaponLoadout {
	array< string > weaponRefs
	table< string, array< string > > weaponAttachmentsByWeapon
}

global struct TimedEventData
{
	int eventType = 0
	bool isRepeatingEvent = false
	bool shouldDestroyWPOnEventEnd = false
	void functionref( TimedEventData, entity ) timedEventFunctionThread = null
	float startTimeDelay = 0.0
	float repeatInterval = 0.0
	float eventLength = 0.0
	bool functionref( float ) timedEventFunctionStartValidation = null
	vector colorOverride = <1, 1, 1>
	string eventName = ""
	string eventDesc = ""
}

global struct ScoreboardData
{
	int numScoreColumns = 0
	array<asset> columnDisplayIcons
	array<float> columnDisplayIconsScale
	array<int> columnNumDigits
}

global struct TeamsScoreboardPlayer
{
	int playerEHI = 0
}

// SquadSummaryPlayerData: modeSpecificSummaryData field added to existing struct in cl_gamemode_survival.nut
// SummaryDataEntry: added to cl_gamemode_survival.nut

global struct IntroCameraSettings
{
	vector origin = <0, 0, 0>
	vector angles = <0, 0, 0>
}

global struct CancelPlayerStatesData
{
	bool cancelZipline = false
	bool cancelGrapple = false
	bool cancelPhaseTunnel = false
	bool cancelPhaseWalk = false
	bool cancelRevive = false
	bool cancelCryptoDrone = false
	bool cancelTotem = false
	bool cancelMainOrAltHandAbility = false
	bool cancelHuntMode = false // S22: used by firing range challenges
	bool cancelBleedOut = false // S22: used by firing range challenges
}

// ======================== GLOBAL FUNCTION DECLARATIONS ========================

// --- TimedEvents System ---
global function TimedEvents_Init
global function TimedEvents_RegisterTimedEvent

// --- MapNode System ---
global function MapNode_Init
global function MapNode_IsMapDataValid
global function MapNode_GetIntroCameraPoints
global function MapNode_GetAirdropLocations
global function MapNode_GetAvailableAirdropLocations
global function MapNode_ResetAvailableAirDropLocations
global function MapNode_TakeAvailableAirdropLocation

// --- AllianceProximity System ---
// Full implementation now in mp/sh_alliance_proximity.gnut
global function GetAllianceTeamsScore
global function SetAllianceTeamsScore

// --- CrowdNoiseMeter System ---
global function UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast
global function UpdateOtherTeamsOrAlliancesCrowdNoiseMeterAndBroadcast
global function CrowdNoiseMeter_PlayGameEndSound

// --- GameModeVariant System ---
global function GameModeVariant_IsActive
global function GameMode_IsActive
global function GameMode_AreRoundsEnabled

// LoadoutSelection system: real implementation in sh_loadout_selection_system.nut

// --- Teams Scoreboard System ---
global function ShowScoreboardOrMap_Teams
global function HideScoreboardOrMap_Teams
global function Teams_AddCallback_ScoreboardData
global function Teams_AddCallback_Header
global function Teams_AddCallback_PlayerScores
global function Teams_AddCallback_SortScoreboardPlayers
global function Teams_AddCallback_GetTeamColor
global function Teams_AddCallback_IsEnabled
global function Teams_AddCallback_GetTeamName
global function Teams_AddCallback_GetTeamIcon

// --- Missing dependencies for LoadoutSelection system ---
#if SERVER
global function CharacterLoadouts_GiveConsumableLoadoutToPlayer
global function PIN_PlayerWeaponLoadoutChange
#endif

// --- Individual missing functions ---
global function ForceScriptError
#if SERVER
// AllianceProximity_IsUsingAlliances and AllianceProximity_GetMaxNumAlliances now in mp/sh_alliance_proximity.gnut
global function CircleCullClassName
global function CircleCullScriptName
global function SetCustomIntroCameraSettingsFunction
global function SetVictoryKillMode
global function SetShouldSpawnPlayerOnConnect
// QuickChat_RegisterDisabledCommsActions — now in sh_quickchat.gnut (S22)
global function AddCallback_OnPlayerPostRespawned
global function GameState_HasRoundRestarted
global function SetDefaultRoundWinningKillReplayEntities
global function SetWinner
global function GetHasGameTimedOut
global function DoCommonRespawnForPlayer
// GetPlayerArrayIncludingSpectators moved to SERVER || CLIENT scope below
// GameRules_GetTeamScore2 is engine-native
global function WeaponStatsHook_OnKillEnemy
global function MatchBehaviorPlayer_AddEndedCallback
global function SetupAssaultPointKeyValues
global function Remote_CallFunction_QueueForNoKillCam
#endif

#if SERVER || CLIENT
global function EmitSoundOnEntity_NoTimeScale
#endif
#if CLIENT
global function HudTargetInfo_Enable
// Already in sh_character_select.gnut
//global function CharacterSelectMenu_SetCustomJIPDescription
//global function OpenCharacterSelectMenu
global function EmitUISound
global function IsLocalPlayerOnTeamSpectator
//global function CloseCharacterSelectMenu  // Already in sh_character_select.gnut
global function GameRules_IsTeamIndexValid
global function SetPlayThroughPOVTransitions
// IsRevTakeover moved to shared scope (used by both SERVER and CLIENT)
global function BigTDM_IsModeEnabled
global function LowerDVSForGameMode
global function ClWaittillGameStateOrHigher
#endif

// --- Utility script dependencies ---
global function SetAbandonCheckFunc
global function IsEliminationBased
// RegisterNetVarBoolChangeCallback - moved to sh_netvar_callbacks.gnut
// RegisterNetVarTimeChangeCallback - moved to sh_netvar_callbacks.gnut
global function ParseWeaponLoadoutText
global function ParseEquipmentLoadoutText
global function ParseConsumableLoadoutText
#if SERVER
global function CharacterLoadouts_GiveEquipmentLoadoutToPlayer
#endif
#if CLIENT
global function RuiHasGameTimeArg
#endif
global function IsRevTakeover
#if SERVER
global function GetEndTimeForPlaylistInRotation
global function IsNessieEEActive
global function Wattson_TT_Check_Victory
global function MatchBehaviorPlayer_HasStarted
global function MatchBehaviorPlayer_HasEnded
global function MatchBehaviorPlayer_Ended
global function MatchBehaviorPlayer_DidAbandonThisMatch
global function MatchBehavior_Enabled
global function GetWinnerDeterminedWait
global function PIN_PlayerClassMidMatchChange
global function Vehicle_KickPlayer_ForOtherReason
global function CancelPlayerStates
#endif
global function HoverVehicle_IsPlayerInAnyVehicle
#if SERVER || CLIENT
// These use SERVER/CLIENT-only natives (GetPlayerArray, IsAlive, etc.)
global function GetNearbyPlayers
global function GetPlayerArrayIncludingSpectators
#endif
#if SERVER
// These use SERVER-only entity methods (SetHealth, SetShieldHealth, etc.)
global function SetHealthAndShieldByPercentage
global function SetWinningTeam
#endif
// Spawn_SetSpawnpointRatingFunc and Spawn_SetFriendlyRatingCap now live in mp/spawn.nut
// Remote_CallFunction_QueueForNoKillCam declared above in #if SERVER
// SquadLeader_UpdateAllUnitFramesRui declared above in #if CLIENT
// Squads_SetCustomPlayerInfo, Squads_GetReorderedTeamsUIId, Squads_GetSquadColor, Squads_GetSquadIcon exist in _squads_utility.gnut

// ======================== FUNCTION IMPLEMENTATIONS ========================

// --- TimedEvents System (airdrops - disabled for initial port) ---
void function TimedEvents_Init() {}
void function TimedEvents_RegisterTimedEvent( TimedEventData data ) {}

// --- MapNode System (map data for airdrops/cameras - disabled) ---
void function MapNode_Init() {}
bool function MapNode_IsMapDataValid() { return false }
array<Point> function MapNode_GetIntroCameraPoints() { return [] }
array<entity> function MapNode_GetAirdropLocations() { return [] }
array<entity> function MapNode_GetAvailableAirdropLocations() { return [] }
void function MapNode_ResetAvailableAirDropLocations() {}
entity function MapNode_TakeAvailableAirdropLocation() { return null }

// --- AllianceProximity System ---
// Full implementation now in mp/sh_alliance_proximity.gnut
// Only GetAllianceTeamsScore/SetAllianceTeamsScore remain as stubs (not part of alliance proximity file)
int function GetAllianceTeamsScore( int alliance ) { return 0 }
void function SetAllianceTeamsScore( int alliance, int score ) {}

// --- CrowdNoiseMeter System (audio atmosphere - disabled) ---
void function UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( int teamOrAlliance, int modifier ) {}
void function UpdateOtherTeamsOrAlliancesCrowdNoiseMeterAndBroadcast( int teamOrAlliance, int modifier ) {}
void function CrowdNoiseMeter_PlayGameEndSound( entity player, bool isWinner ) {}

// --- GameModeVariant System ---
bool function GameModeVariant_IsActive( int variant )
{
	// Check playlist vars to determine active variant
	if ( variant == eGameModeVariants.FREEDM_TDM )
		return GetCurrentPlaylistVarBool( "freedm_is_tdm", false )
	return false
}

bool function GameMode_IsActive( int gameMode )
{
	#if SERVER || CLIENT
		if ( gameMode == eGameModes.FREEDM )
			return GameRules_GetGameMode() == FREEDM || GameRules_GetGameMode() == FREEDM_TDM || GameRules_GetGameMode() == FREEDM_GUNGAME
	#endif
	return false
}

bool function GameMode_AreRoundsEnabled()
{
	return GetCurrentPlaylistVarBool( "rounds_enabled", false )
}

// --- Missing dependencies for LoadoutSelection system ---
#if SERVER
void function CharacterLoadouts_GiveConsumableLoadoutToPlayer( entity player, array<string> consumableLoadout )
{
	foreach( consumable in consumableLoadout )
	{
		if ( SURVIVAL_Loot_IsRefValid( consumable ) )
			SURVIVAL_AddToPlayerInventory( player, consumable )
	}
}

void function PIN_PlayerWeaponLoadoutChange( entity player, array<string> classesOffered, array<string> previousWeapons, string currentLoadout, bool isMidMatch ) {}
#endif

// --- Teams Scoreboard System ---
void function ShowScoreboardOrMap_Teams() {}
void function HideScoreboardOrMap_Teams() {}
void function Teams_AddCallback_ScoreboardData( ScoreboardData functionref() callback ) {}
void function Teams_AddCallback_Header( void functionref( var, var, int ) callback ) {}
void function Teams_AddCallback_PlayerScores( array<string> functionref( entity ) callback ) {}
void function Teams_AddCallback_SortScoreboardPlayers( array<TeamsScoreboardPlayer> functionref( array<TeamsScoreboardPlayer> ) callback ) {}
void function Teams_AddCallback_GetTeamColor( vector functionref( int ) callback ) {}
void function Teams_AddCallback_IsEnabled( bool functionref() callback ) {}
void function Teams_AddCallback_GetTeamName( string functionref( int ) callback ) {}
void function Teams_AddCallback_GetTeamIcon( asset functionref( int ) callback ) {}

// --- Shared-scope function stubs (declared without #if above) ---
int function GetEndTimeForPlaylistInRotation( string playlistName ) { return 0 }
bool function IsNessieEEActive() { return false }
void function Wattson_TT_Check_Victory( entity player ) {}
bool function MatchBehavior_Enabled() { return false }
bool function MatchBehaviorPlayer_HasStarted( entity player ) { return false }
bool function MatchBehaviorPlayer_HasEnded( entity player ) { return true }
void function MatchBehaviorPlayer_Ended( entity player, bool wasUnexpectedDisconnect ) {}
bool function MatchBehaviorPlayer_DidAbandonThisMatch( entity player ) { return false }
void function CancelPlayerStates( entity player, CancelPlayerStatesData states ) {}
void function Vehicle_KickPlayer_ForOtherReason( entity player ) {}
bool function HoverVehicle_IsPlayerInAnyVehicle( entity player ) { return false }

#if SERVER || CLIENT
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
#endif // SERVER || CLIENT

#if SERVER
bool function SetHealthAndShieldByPercentage( entity player, float healthPercent, float shieldPercent, bool shouldAllowHealthLoss )
{
	bool didHeal = false
	if ( !IsValid( player ) )
		return didHeal
	if ( healthPercent >= 0.0 )
	{
		int healthMax = player.GetMaxHealth()
		int currentHealth = player.GetHealth()
		int targetHealth = int( healthMax * healthPercent )
		int setHealthAmount = shouldAllowHealthLoss ? targetHealth : maxint( targetHealth, currentHealth )
		if ( setHealthAmount != currentHealth )
		{
			player.SetHealth( setHealthAmount )
			didHeal = true
		}
	}
	if ( shieldPercent >= 0.0 )
	{
		int shieldMax = player.GetShieldHealthMax()
		int currentShield = player.GetShieldHealth()
		int targetShieldHealth = int( shieldMax * shieldPercent )
		int setShieldAmount = shouldAllowHealthLoss ? targetShieldHealth : maxint( targetShieldHealth, currentShield )
		if ( setShieldAmount != currentShield )
		{
			player.SetShieldHealth( setShieldAmount )
			didHeal = true
		}
	}
	return didHeal
}
#endif // SERVER

// --- Shared stubs ---
void function ForceScriptError( string message ) { ScriptError( message ) }

// --- SERVER-only function stubs ---
#if SERVER
void function SetWinningTeam( int team )
{
	if ( GameMode_IsActive( eGameModes.FREEDM ) && team >= TEAM_MULTITEAM_FIRST + MAX_TEAMS )
		ForceScriptError( "Invalid TEAM was selected as winning team. team = " + team + ". MAX_TEAMS = " + MAX_TEAMS )
	level.nv.winningTeam = team
}
void function CircleCullClassName( string className ) {}
void function CircleCullScriptName( string scriptName ) {}
void function SetCustomIntroCameraSettingsFunction( void functionref( entity, IntroCameraSettings ) func ) {}
void function SetVictoryKillMode( bool enabled ) {}
void function SetShouldSpawnPlayerOnConnect( bool functionref( entity ) func ) {}
// QuickChat_RegisterDisabledCommsActions — now in sh_quickchat.gnut (S22)
void function AddCallback_OnPlayerPostRespawned( void functionref( entity ) callback ) {}
void function SetDefaultRoundWinningKillReplayEntities( entity victim, entity attacker, var damageInfo ) {}
void function SetWinner( int team, int winReason, string winReasonStr1, string winReasonStr2 ) {}
bool function GetHasGameTimedOut() { return false }
void function DoCommonRespawnForPlayer( entity player ) {}
void function WeaponStatsHook_OnKillEnemy( entity victim, entity attacker, entity creditedAttacker, var damageInfo ) {}
void function SetupAssaultPointKeyValues() {}
void function MatchBehaviorPlayer_AddEndedCallback( void functionref( entity, bool ) callback ) {}
void function Remote_CallFunction_QueueForNoKillCam( entity player, string funcName, ... ) {}
#endif // SERVER

#if CLIENT
void function HudTargetInfo_Enable( bool enabled ) {}
// Already in sh_character_select.gnut
//void function CharacterSelectMenu_SetCustomJIPDescription( string desc ) {}
//void function OpenCharacterSelectMenu( bool browseMode = false, bool showLocked = false, bool isJIP = false ) {}
void function EmitUISound( string sound ) { EmitSoundOnEntity( GetLocalClientPlayer(), sound ) }
bool function IsLocalPlayerOnTeamSpectator() { return GetLocalClientPlayer().GetTeam() == TEAM_SPECTATOR }
//void function CloseCharacterSelectMenu() {}  // Already in sh_character_select.gnut
bool function GameRules_IsTeamIndexValid( int teamIndex ) { return teamIndex >= 0 && teamIndex < GetCurrentPlaylistVarInt( "max_teams", 20 ) + 2 }
void function SetPlayThroughPOVTransitions( var soundHandle ) {} // Sound persistence through POV transitions
bool function BigTDM_IsModeEnabled() { return false }
void function ClWaittillGameStateOrHigher( int state )
{
	while ( GetGameState() < state )
		WaitFrame()
}
// Squads_SetCustomPlayerInfo, Squads_GetReorderedTeamsUIId, Squads_GetSquadColor, Squads_GetSquadIcon exist in _squads_utility.gnut
#endif // CLIENT

#if SERVER
#endif

// --- Utility script dependencies ---
void function SetAbandonCheckFunc( bool functionref( entity ) func ) {}
bool function IsEliminationBased() { return false }

WeaponLoadout function ParseWeaponLoadoutText( string loadoutText, bool useDefaultLoadout = true )
{
	WeaponLoadout weaponLoadout
	array< string > weaponLoadoutArray = []
	if ( loadoutText != "" )
		weaponLoadoutArray = GetTrimmedSplitString( loadoutText, " " )
	foreach( weapon in weaponLoadoutArray )
	{
		array<string> weaponTokens = GetTrimmedSplitString( weapon, ":" )
		string weaponRef           = weaponTokens[0]
		weaponLoadout.weaponRefs.append( weaponRef )

		weaponTokens.remove( 0 )
		array<string> attachmentsToAdd = weaponTokens

		weaponLoadout.weaponAttachmentsByWeapon[weaponRef] <- attachmentsToAdd
	}
	return weaponLoadout
}

array< string > function ParseEquipmentLoadoutText( string loadoutText, bool useDefaultLoadout = true, array<string> displayIgnoredItems = [] )
{
	array<string> equipmentToAdd = []
	if ( loadoutText != "" )
		equipmentToAdd = GetTrimmedSplitString( loadoutText, " " )
	return equipmentToAdd
}

array< string > function ParseConsumableLoadoutText( string loadoutText, bool useDefaultLoadout = true )
{
	array<string> consumableTokens = []
	if ( loadoutText != "" )
		consumableTokens = GetTrimmedSplitString( loadoutText, " " )
	array<string> consumablesToAdd
	foreach( itemType in consumableTokens )
	{
		array<string> tokens = GetTrimmedSplitString( itemType, ":" )
		string itemRef       = tokens[0]
		int numItems         = tokens.len() > 1 ? int( tokens[1] ) : 1
		for ( int i = 0; i < numItems; i++ )
			consumablesToAdd.append( itemRef )
	}
	return consumablesToAdd
}

#if SERVER
void function CharacterLoadouts_GiveEquipmentLoadoutToPlayer( entity player, array<string> equipmentLoadout )
{
	foreach( equipment in equipmentLoadout )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( equipment )
		SURVIVAL_GivePlayerEquipment( player, equipment, 0, null, "", false )
	}
}
#endif


// RegisterNetVarBoolChangeCallback - moved to sh_netvar_callbacks.gnut
// RegisterNetVarTimeChangeCallback - moved to sh_netvar_callbacks.gnut

#if CLIENT
bool function RuiHasGameTimeArg( var rui, string argName ) { return false }
#endif

#if SERVER || CLIENT
void function EmitSoundOnEntity_NoTimeScale( entity ent, string sound ) { EmitSoundOnEntity( ent, sound ) }
array<entity> function GetPlayerArrayIncludingSpectators() { return GetPlayerArray() }
#endif

void function LowerDVSForGameMode( bool enabled = false ) { Warning( "STUB: LowerDVSForGameMode\n" ) }

bool function IsRevTakeover() { return false }

#if SERVER
bool function GameState_HasRoundRestarted() { return false }
float function GetWinnerDeterminedWait() { return GetCurrentPlaylistVarFloat( "winner_determined_wait", 5.0 ) }
void function PIN_PlayerClassMidMatchChange( entity player, array<string> classesOffered ) {}
#endif

