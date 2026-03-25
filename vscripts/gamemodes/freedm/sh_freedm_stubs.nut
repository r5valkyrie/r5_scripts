// ============================================================================
// FreeDM Stubs - Functions not yet implemented
// Loaded BEFORE all other FreeDM scripts to provide missing symbols.
// These stubs allow the FreeDM scripts to compile and run.
// ============================================================================

// ======================== CONSTANTS ========================

// ALLIANCE_NONE, ALLIANCE_A, ALLIANCE_B now defined in mp/sh_alliance_proximity.gnut
// CHEVREX_AIRDROP_SKIN_INDEX now defined in mp/sh_airdrops.gnut
global const string SNIPERULT_WEAPON_NAME = "mp_ability_sniper_ult" // Vantage sniper ultimate (S14+)

// COLORID_CONTROL_FRIENDLY/ENEMY/CONTESTED now defined in mp/sh_alliance_proximity.gnut

// ======================== ENUMS ========================

// eSurvivalCommentaryBucket: FreeDM values added to existing enum in sh_survival_commentary.gnut
// eGameModes: FREEDM added to existing enum in sh_gamemodes.gnut


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


// ======================== CONSTANTS ========================
// NOTE: Only define constants NOT already provided by the engine or other scripts.
// COLORID_AIRDROP_DEFAULT_COLOR, ALLIANCE_A/B, ANNOUNCEMENT_STYLE_*, CHEVREX_AIRDROP_SKIN_INDEX
// are already defined natively — do NOT redefine them here.

// eAirdropType now defined in mp/sh_airdrops.gnut

// ======================== STRUCTS ========================

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
global function SetVictoryKillMode
global function DoCommonRespawnForPlayer
// GetPlayerArrayIncludingSpectators moved to SERVER || CLIENT scope below
// GameRules_GetTeamScore2 is engine-native
global function WeaponStatsHook_OnKillEnemy
global function Remote_CallFunction_QueueForNoKillCam
#endif

#if CLIENT
global function HudTargetInfo_Enable
// Already in sh_character_select.gnut
//global function CharacterSelectMenu_SetCustomJIPDescription
//global function OpenCharacterSelectMenu
global function EmitSoundOnEntity_NoTimeScale
global function EmitUISound
//global function CloseCharacterSelectMenu  // Already in sh_character_select.gnut
global function GameRules_IsTeamIndexValid
global function SetPlayThroughPOVTransitions
// IsRevTakeover moved to shared scope (used by both SERVER and CLIENT)
global function LowerDVSForGameMode
#endif

// --- Utility script dependencies ---
// RegisterNetVarBoolChangeCallback - moved to sh_netvar_callbacks.gnut
// RegisterNetVarTimeChangeCallback - moved to sh_netvar_callbacks.gnut
global function ParseEquipmentLoadoutText
global function ParseConsumableLoadoutText
#if SERVER
global function CharacterLoadouts_GiveEquipmentLoadoutToPlayer
#endif
#if CLIENT
global function RuiHasGameTimeArg
#endif
global function GetEndTimeForPlaylistInRotation
global function IsNessieEEActive
global function Wattson_TT_Check_Victory
global function IsRevTakeover
global function PIN_PlayerClassMidMatchChange
global function HoverVehicle_IsPlayerInAnyVehicle
global function Vehicle_KickPlayer_ForOtherReason
global function CancelPlayerStates
#if SERVER || CLIENT
// These use SERVER/CLIENT-only natives (GetPlayerArray, IsAlive, etc.)
global function GetPlayerArrayIncludingSpectators
#endif
#if SERVER
// These use SERVER-only entity methods (SetHealth, SetShieldHealth, etc.)
global function SetHealthAndShieldByPercentage
#endif
#if SERVER || CLIENT
global function GetNearbyPlayers
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
#endif

// --- Shared-scope function stubs (declared without #if above) ---
int function GetEndTimeForPlaylistInRotation( string playlistName ) { return 0 }
bool function IsNessieEEActive() { return false }
void function Wattson_TT_Check_Victory( entity player ) {}
void function PIN_PlayerClassMidMatchChange( entity player, array<string> classesOffered ) {}
void function CancelPlayerStates( entity player, CancelPlayerStatesData states ) {}
bool function IsRevTakeover() { return false }
bool function HoverVehicle_IsPlayerInAnyVehicle( entity player ) { return false }
void function Vehicle_KickPlayer_ForOtherReason( entity player ) {}

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

void function ForceScriptError( string message ) { ScriptError( message ) }

// --- SERVER-only function stubs ---
#if SERVER
void function CircleCullClassName( string className ) {}
void function CircleCullScriptName( string scriptName ) {}
void function SetVictoryKillMode( bool enabled ) {}
void function DoCommonRespawnForPlayer( entity player ) {}
array<entity> function GetPlayerArrayIncludingSpectators() { return GetPlayerArray() }
void function WeaponStatsHook_OnKillEnemy( entity victim, entity attacker, entity creditedAttacker, var damageInfo ) {}
void function Remote_CallFunction_QueueForNoKillCam( entity player, string funcName, ... ) {}
#endif // SERVER

#if CLIENT
void function HudTargetInfo_Enable( bool enabled ) {}
array<entity> function GetPlayerArrayIncludingSpectators() { return GetPlayerArray() }
// Already in sh_character_select.gnut
//void function CharacterSelectMenu_SetCustomJIPDescription( string desc ) {}
//void function OpenCharacterSelectMenu( bool browseMode = false, bool showLocked = false, bool isJIP = false ) {}
var function EmitSoundOnEntity_NoTimeScale( entity ent, string sound ) { EmitSoundOnEntity( ent, sound ); return null }
void function EmitUISound( string sound ) { EmitSoundOnEntity( GetLocalClientPlayer(), sound ) }
//void function CloseCharacterSelectMenu() {}  // Already in sh_character_select.gnut
bool function GameRules_IsTeamIndexValid( int teamIndex ) { return teamIndex >= 0 && teamIndex < GetCurrentPlaylistVarInt( "max_teams", 20 ) + 2 }
void function SetPlayThroughPOVTransitions( var soundHandle ) {} // Sound persistence through POV transitions
void function LowerDVSForGameMode( bool lower ) {} // Dynamic Visibility Settings tweaks
// Squads_SetCustomPlayerInfo, Squads_GetReorderedTeamsUIId, Squads_GetSquadColor, Squads_GetSquadIcon exist in _squads_utility.gnut
#endif // CLIENT

// --- Utility script dependencies ---

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
