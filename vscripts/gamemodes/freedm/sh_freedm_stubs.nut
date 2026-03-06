// ============================================================================
// FreeDM Stubs - Functions not yet implemented in s3
// Loaded BEFORE all other FreeDM scripts to provide missing symbols.
// These stubs allow the FreeDM scripts to compile and run.
// ============================================================================

// ======================== CONSTANTS ========================

// ALLIANCE_NONE, ALLIANCE_A, ALLIANCE_B now defined in mp/sh_alliance_proximity.gnut
global const int CHEVREX_AIRDROP_SKIN_INDEX = 2
global const string SNIPERULT_WEAPON_NAME = "mp_ability_sniper_ult" // Vantage sniper ultimate (S14+)

// COLORID_CONTROL_FRIENDLY/ENEMY/CONTESTED now defined in mp/sh_alliance_proximity.gnut

// ======================== ENUMS ========================

// eSurvivalCommentaryBucket: FreeDM values added to existing enum in sh_survival_commentary.gnut
// eGameModes: FREEDM added to existing enum in sh_gamemodes.gnut

global enum eGameModeVariants
{
	FREEDM_TDM = 0
	FREEDM_LOCKDOWN = 1
	SURVIVAL_WINTEREXPRESS = 100
	SURVIVAL_BATTLE_RUSH = 101
	SURVIVAL_SHADOW_ARMY = 102
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

global enum eXPType
{
	OBJECTIVE_CAPTURE_DURATION = 200
	BONUS_FINAL_KILL = 201
}

global enum eUpgradeXPActions
{
	MINGUARANTEEDLOOT_RESPAWN = 0
}

// ======================== CONSTANTS ========================
// NOTE: Only define constants NOT already provided by the engine or other scripts.
// COLORID_AIRDROP_DEFAULT_COLOR, ALLIANCE_A/B, ANNOUNCEMENT_STYLE_*, CHEVREX_AIRDROP_SKIN_INDEX
// are already defined natively — do NOT redefine them here.

global enum eAirdropType
{
	STANDARD = 0
}

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

global struct AirdropItemsOptionalInfo
{
	string animationName = "droppod_loot_drop"
	string targetName = ""
	entity owner = null
	int team = 0
	int skin = 0
	string sourceWeaponClassname = ""
	int realm = -1
	bool animatePod = true
	bool forceDefaultColor = false
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
#if SERVER
global function ForceScriptError
// AllianceProximity_IsUsingAlliances and AllianceProximity_GetMaxNumAlliances now in mp/sh_alliance_proximity.gnut
global function SetGlobalNonRewindNetTime
global function CircleCullClassName
global function CircleCullScriptName
global function SetCustomIntroCameraSettingsFunction
global function SetVictoryKillMode
global function SetShouldSpawnPlayerOnConnect
global function QuickChat_RegisterDisabledCommsActions
global function AddCallback_OnPlayerPostRespawned
global function Survival_AddCallback_IsSquadReallyEliminated
global function GameState_HasRoundRestarted
global function SetDefaultRoundWinningKillReplayEntities
global function SetWinner
global function GetHasGameTimedOut
global function SetInfiniteAmmoForWeapon
global function SetInfiniteAmmoForGameMode
global function ClientToServer_OnCharacterReselectMenuOpen
global function IsPlayerReselectingCharacter
global function IsCharacterReselectEnabled
global function DoCommonRespawnForPlayer
global function GetPlayerArrayIncludingSpectators
// GameRules_GetTeamScore2 is engine-native
global function AbilityCarePackage_SetContentOverrideCallback
global function DetermineAirdropContents
global function WeaponStatsHook_OnKillEnemy
global function Weapon_GetBaseClassName
global function MatchBehaviorPlayer_AddEndedCallback
global function TryFindSpeakingPlayerOnTeam_OnlyAllowSpecificCharacters
global function SetupAssaultPointKeyValues
global function Remote_CallFunction_QueueForNoKillCam
global function GetMusicForJump
global function GetGameStartTime
#endif

#if CLIENT
global function HudTargetInfo_Enable
global function SetShowUnitFrameAmmoTypeIcons
global function CharacterSelectMenu_SetCustomJIPDescription
global function OpenCharacterSelectMenu
global function SetVictoryScreenTeamName
global function SetSummaryDataDisplayStringsCallback
global function CircleBannerAnnouncementsEnable
global function EmitSoundOnEntity_NoTimeScale
global function EmitUISound
global function IsLocalPlayerOnTeamSpectator
global function CloseCharacterSelectMenu
global function GameRules_IsTeamIndexValid
global function SetPlayThroughPOVTransitions
// IsRevTakeover moved to shared scope (used by both SERVER and CLIENT)
global function BigTDM_IsModeEnabled
global function SquadLeader_UpdateAllUnitFramesRui
global function LowerDVSForGameMode
global function ClWaittillGameStateOrHigher
#endif

// --- Utility script dependencies ---
global function SetAbandonCheckFunc
global function IsEliminationBased
global function RegisterNetVarBoolChangeCallback
global function RegisterNetVarTimeChangeCallback
global function ParseWeaponLoadoutText
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
global function Crafting_CloseCraftingMenu
global function IsRevTakeover
global function SURVIVAL_SendWinningSquadDataToPlayer
global function OnPlayerMatchParticipationEnded
global function MatchBehaviorPlayer_HasStarted
global function MatchBehaviorPlayer_HasEnded
global function MatchBehaviorPlayer_Ended
global function MatchBehaviorPlayer_DidAbandonThisMatch
global function MatchBehavior_Enabled
global function GetWinnerDeterminedWait
global function ProjectX_DumpGameSummarySquadData
global function PIN_PlayerClassMidMatchChange
global function HoverVehicle_IsPlayerInAnyVehicle
global function Vehicle_KickPlayer_ForOtherReason
global function CancelPlayerStates
#if SERVER || CLIENT
// These use SERVER/CLIENT-only natives (GetPlayerArray, IsAlive, etc.)
global function GetNearbyPlayers
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
void function SURVIVAL_SendWinningSquadDataToPlayer( entity player, int winningTeam ) {}
void function OnPlayerMatchParticipationEnded( entity player, bool wasUnexpectedDisconnect ) {}
float function GetWinnerDeterminedWait() { return 5.0 }
void function ProjectX_DumpGameSummarySquadData() {}
void function PIN_PlayerClassMidMatchChange( entity player, array<string> classesOffered ) {}
void function CancelPlayerStates( entity player, CancelPlayerStatesData states ) {}
void function Crafting_CloseCraftingMenu( entity player ) {}
bool function IsRevTakeover() { return false }
bool function HoverVehicle_IsPlayerInAnyVehicle( entity player ) { return false }
void function Vehicle_KickPlayer_ForOtherReason( entity player ) {}

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

// --- SERVER-only function stubs ---
#if SERVER
void function ForceScriptError( string message ) { ScriptError( message ) }
void function SetGlobalNonRewindNetTime( string varName, float value )
{
	SetServerVar( varName, value )
}
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
void function QuickChat_RegisterDisabledCommsActions( array<int> actions ) {}
void function AddCallback_OnPlayerPostRespawned( void functionref( entity ) callback ) {}
void function Survival_AddCallback_IsSquadReallyEliminated( bool functionref( int ) callback ) {}
bool function GameState_HasRoundRestarted() { return false }
void function SetDefaultRoundWinningKillReplayEntities( entity victim, entity attacker, var damageInfo ) {}
void function SetWinner( int team, int winReason, string winReasonStr1, string winReasonStr2 ) {}
bool function GetHasGameTimedOut() { return false }
bool function SetInfiniteAmmoForWeapon( entity player, entity weapon, bool ornull infiniteAmmo = null, bool removeOnDrop = true, bool forceApply = false )
{
	if ( !IsValid( player ) || !IsValid( weapon ) )
		return false
	if ( infiniteAmmo == true )
		SetupInfiniteAmmoForWeapon( player, weapon )
	return true
}
void function SetInfiniteAmmoForGameMode( entity player, bool enabled, array<string> excluded = [] ) {}
void function ClientToServer_OnCharacterReselectMenuOpen( entity player ) {}
bool function IsPlayerReselectingCharacter( entity player ) { return false }
bool function IsCharacterReselectEnabled() { return false }
void function DoCommonRespawnForPlayer( entity player ) {}
array<entity> function GetPlayerArrayIncludingSpectators() { return GetPlayerArray() }
void function AbilityCarePackage_SetContentOverrideCallback( array< array<string> > functionref( entity ) callback ) {}
array< array<string> > function DetermineAirdropContents( array< array<string> > contents ) { return contents }
void function WeaponStatsHook_OnKillEnemy( entity victim, entity attacker, entity creditedAttacker, var damageInfo ) {}
string function Weapon_GetBaseClassName( string weaponRef ) { return GetBaseWeaponRef( weaponRef ) }
void function SetupAssaultPointKeyValues() {}
void function MatchBehaviorPlayer_AddEndedCallback( void functionref( entity, bool ) callback ) {}
void function Remote_CallFunction_QueueForNoKillCam( entity player, string funcName, ... ) {}
string function GetMusicForJump( entity player )
{
	string override = GetCurrentPlaylistVarString( "music_override_skydive", "" )
	if ( override.len() > 0 )
		return override
	return MusicPack_GetSkydiveMusic( GetMusicPackForPlayer( player ) )
}
float function GetGameStartTime()
{
	if ( level.nv.gameStartTime == null )
		return Time() + 30.0
	return expect float( level.nv.gameStartTime )
}
#endif // SERVER

#if CLIENT
void function HudTargetInfo_Enable( bool enabled ) {}
void function SetShowUnitFrameAmmoTypeIcons( bool show ) {}
void function CharacterSelectMenu_SetCustomJIPDescription( string desc ) {}
void function OpenCharacterSelectMenu( bool browseMode = false, bool showLocked = false, bool isJIP = false ) {}
void function SetVictoryScreenTeamName( string name ) {}
void function SetSummaryDataDisplayStringsCallback( void functionref( SquadSummaryPlayerData ) callback ) {}
void function CircleBannerAnnouncementsEnable( bool enabled ) {}
var function EmitSoundOnEntity_NoTimeScale( entity ent, string sound ) { EmitSoundOnEntity( ent, sound ); return null }
void function EmitUISound( string sound ) { EmitSoundOnEntity( GetLocalClientPlayer(), sound ) }
bool function IsLocalPlayerOnTeamSpectator() { return GetLocalClientPlayer().GetTeam() == TEAM_SPECTATOR }
void function CloseCharacterSelectMenu() {}
bool function GameRules_IsTeamIndexValid( int teamIndex ) { return teamIndex >= 0 && teamIndex < GetCurrentPlaylistVarInt( "max_teams", 20 ) + 2 }
void function SetPlayThroughPOVTransitions( var soundHandle ) {} // Sound persistence through POV transitions
bool function BigTDM_IsModeEnabled() { return false }
void function SquadLeader_UpdateAllUnitFramesRui() {}
void function LowerDVSForGameMode( bool lower ) {} // Dynamic Visibility Settings tweaks
void function ClWaittillGameStateOrHigher( int state )
{
	while ( GetGameState() < state )
		WaitFrame()
}
// Squads_SetCustomPlayerInfo, Squads_GetReorderedTeamsUIId, Squads_GetSquadColor, Squads_GetSquadIcon exist in _squads_utility.gnut
#endif // CLIENT

#if SERVER
entity function TryFindSpeakingPlayerOnTeam_OnlyAllowSpecificCharacters( int team, array<string> allowedCharacters )
{
	return TryFindSpeakingPlayerOnTeam( team )
}
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


void function RegisterNetVarBoolChangeCallback( string varName, int context, void functionref( entity, bool, bool, bool ) callback ) {}
void function RegisterNetVarTimeChangeCallback( string varName, int context, void functionref( entity, float, float, bool ) callback ) {}

#if CLIENT
bool function RuiHasGameTimeArg( var rui, string argName ) { return false }
#endif
