// ============================================================================
// FreeDM Stubs - Functions not yet implemented
// Loaded BEFORE all other FreeDM scripts to provide missing symbols.
// These stubs allow the FreeDM scripts to compile and run.
// ============================================================================

global const string SNIPERULT_WEAPON_NAME = "mp_ability_sniper_ult" // Vantage sniper ultimate (S14+)

// ======================== STRUCTS ========================

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

// --- MapNode System ---
global function MapNode_Init
global function MapNode_IsMapDataValid
global function MapNode_GetIntroCameraPoints
global function MapNode_GetAirdropLocations
global function MapNode_GetAvailableAirdropLocations
global function MapNode_ResetAvailableAirDropLocations
global function MapNode_TakeAvailableAirdropLocation

// --- AllianceProximity System ---
global function GetAllianceTeamsScore
global function SetAllianceTeamsScore

// --- Individual missing functions ---
global function ForceScriptError
#if SERVER
global function CircleCullClassName
global function CircleCullScriptName
global function SetVictoryKillMode
// GetPlayerArrayIncludingSpectators moved to SERVER || CLIENT scope below
// GameRules_GetTeamScore2 is engine-native
global function WeaponStatsHook_OnKillEnemy
global function Remote_CallFunction_QueueForNoKillCam
#endif

#if CLIENT
global function HudTargetInfo_Enable
global function EmitSoundOnEntity_NoTimeScale
global function EmitUISound
global function GameRules_IsTeamIndexValid
global function SetPlayThroughPOVTransitions
// IsRevTakeover moved to shared scope (used by both SERVER and CLIENT)
global function LowerDVSForGameMode
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

// ======================== FUNCTION IMPLEMENTATIONS ========================

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
array<entity> function GetPlayerArrayIncludingSpectators() { return GetPlayerArray() }
void function WeaponStatsHook_OnKillEnemy( entity victim, entity attacker, entity creditedAttacker, var damageInfo ) {}
void function Remote_CallFunction_QueueForNoKillCam( entity player, string funcName, ... ) {}
#endif // SERVER

#if CLIENT
void function HudTargetInfo_Enable( bool enabled ) {}
array<entity> function GetPlayerArrayIncludingSpectators() { return GetPlayerArray() }
var function EmitSoundOnEntity_NoTimeScale( entity ent, string sound ) { EmitSoundOnEntity( ent, sound ); return null }
void function EmitUISound( string sound ) { EmitSoundOnEntity( GetLocalClientPlayer(), sound ) }
bool function GameRules_IsTeamIndexValid( int teamIndex ) { return teamIndex >= 0 && teamIndex < GetCurrentPlaylistVarInt( "max_teams", 20 ) + 2 }
void function SetPlayThroughPOVTransitions( var soundHandle ) {} // Sound persistence through POV transitions
void function LowerDVSForGameMode( bool lower ) {} // Dynamic Visibility Settings tweaks
#endif // CLIENT


#if CLIENT
bool function RuiHasGameTimeArg( var rui, string argName ) { return false }
#endif
