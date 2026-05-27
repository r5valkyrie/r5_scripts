                            
/*
This is a simplified version of the respawn beacon which relies on a lot of the functions in sh_respawn_beacon.gnut
The purpose of this respawn beacon is to function as a mini objective in the Shadow Army gamemode ( sh_gamemode_shadow_army.nut ) which can be used by the Legend Alliance to respawn dead Legends

We want to preserve the look, vfx, dropship logic of the original but override a lot of how these are used and who gets respawned.
The current respawn logic in Shadow Army is:
- Can only be respawned using Respawn Beacons if you are on the Legend Alliance
- So the Respawn beacons can only be used by the Legend team
- There are no banners, if you are dead but your squad has not been eliminated you can be respawned by a beacon by anyone on the Legends Alliance

Current Respawn Beacon Mini Objective Design:
General:
- Respawn Beacons outside of the ring are deactivated permanently
- If a Respawn Beacon is in use, all other Beacons are temporarily disabled
- If a Respawn Beacon is successfully used by Legends ( completed long hold input ) all other valid beacons are enabled again and the used beacon goes on a long cooldown
- If a Respawn Beacon is abandoned ( player started the interaction then abandoned it ) it goes on a short cooldown and all other valid beacons are enabled again
- Once cooldown is completed a Respawn Beacon can be interacted with again
- Only Legends can activate a Respawn Beacon objective
- Beacons cannot be activated if there are no Legends to respawn
- When a Legend interacts with a Beacon the whole Lobby is notified
- Beacons can be pinged

Legends:
- Are notified when a Beacon is being used by a Legend
- Long interact to trigger the Beacon
- Once the Beacon is triggered all Legends waiting for respawn are respawned from dropships

Revenants:
- Are notified when a Beacon is being used by a Legend
*/

#if SERVER || CLIENT
global function ShadowArmy_RespawnBeacon_Init
global function ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount
global function ShadowArmy_RespawnBeacon_CanBeaconBeUsed
global function ShadowArmy_RespawnBeacon_CanBeaconBeUsedByPlayer
#endif // SERVER || CLIENT

#if SERVER
global function ShadowArmy_RespawnBeacon_PingRespawnBeaconOnDelay_Thread
#endif

#if CLIENT
global function ShadowArmy_RespawnBeacon_ServerCallback_RespawnBeaconOnUse
global function ShadowArmy_RespawnBeacon_ServerCallback_ShowBeaconHint
global function ShadowArmy_RespawnBeacon_UpdateBeaconMapFeature
global function ShadowArmy_RespawnBeacon_ServerCallback_ManageHoloFX
global function ShadowArmy_RespawnBeacon_ServerCallback_OnBeaconStateChanged
#endif

#if DEV && SERVER
global function ShadowArmy_RespawnLegendsFromRespawnBeacon_Dev
global function ShadowArmy_TriggerRespawnBeaconBeamVFX_Dev
#endif // DEV && SERVER

                  
          
                                                                                                                                                                          
                                                      
      
                        

#if SERVER
const float BEACON_REGULAR_COOLDOWN_DURATION = 240.0
const float BEACON_SHORT_COOLDOWN_DURATION = 15.0
//VFX
const asset BEACON_BEAM_VFX = $"CP_test_chamber_beam_revArmy" 	//test effect w/ CP set in system   - delete when CP are set and replace w/ below
const asset BEACON_BEAM_SUCCESS_VFX = $"CP_test_chamber_cele_revArmy"   	//test effect w/ CP set in system   - delete when CP are set and replace w/ below
//const asset BEACON_BEAM_VFX = $"P_chamber_beam_revArmy" 	//set CP5 = Color RGB (0-255,0-255,0-255) ie: 255, 0, 0 = red
//const asset BEACON_BEAM_SUCCESS_VFX = $"P_chamber_celebration_revArmy"   	//set CP5 = Color RGB (0-255,0-255,0-255) ie: 255, 0, 0 = red
const float BEAM_SUCCESS_VFX_DURATION = 10.0
// SFX
const string SHADOWARMY_RESPAWNBEACON_AVAILABLE_SFX = "InGame_RevenantArmy_RespawnBeacon_Activating" // One shot SFX when the beacon becomes available after being on cooldown or disabled
const string SHADOWARMY_RESPAWNBEACON_COOLDOWN_START_SFX = "InGame_RevenantArmy_RespawnBeacon_Cooldown_Start" // One shot SFX when the beacon goes on cooldown
const string SHADOWARMY_RESPAWNBEACON_USE_FAIL_SFX = "InGame_RevenantArmy_RespawnBeacon_Unavailable" // One shot SFX when someone tries to interact with a beacon but it is not available
const string SHADOWARMY_RESPAWNBEACON_USE_COMPLETED = "InGame_RevenantArmy_RespawnBeacon_ActivateBeam" // One shot when the beacon use is successful
const string SHADOWARMY_RESPAWNBEACON_COOLDOWN_SFX = "InGame_RevenantArmy_RespawnBeacon_Cooldown_loop" // Looping SFX when the beacon is on cooldown
const string SHADOWARMY_RESPAWNBEACON_HOLOGRAM_SFX = "InGame_RevenantArmy_RespawnBeacon_Hologram_LP" // Looping SFX for the hologram shown on the beacon
const string SHADOWARMY_RESPAWNBEACON_INUSE_3P_SFX = "InGame_RevenantArmy_RespawnBeacon_PulsatingBeam_3P"
#endif

#if CLIENT
// SFX
const string SHADOWARMY_RESPAWNBEACON_USE_HOLD_SFX= "Survival_RespawnBeacon_Linking_loop" // Looping SFX that only play to the player interacting with the beacon while they are interacting with it
#endif

#if SERVER || CLIENT
const float BEACON_INTERACT_TIME = 12.0
const float SUPPORT_LEGEND_BEACON_INTERACT_TIME = 8.0
const float RESPAWN_BEACON_ICON_FADE_DIST_NEAR = 300.0
const float UNSET_TIME = -1

// Use a waypoint to keep data consistent between the Server and the Client
const string WAYPOINT_SHADOWARMY_RESPAWNBEACON = "waypoint_shadowarmy_rspwnbeacon"
const int WAYPOINT_ENT_IDX_RESPAWN_BEACON_ENT = 0
const int WAYPOINT_INT_IDX_BEACON_STATE = 3
const int WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME = 0
const int WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_DURATION = 1
const int WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_END_TIME = 2
const int WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_DURATION = 3

global enum eShadowArmyRespawnBeaconState
{
	IDLE, // Beacon is available to be interacted with
	IN_USE, // Beacon is being used to Respawn Legends
	COOLDOWN, // Beacon is on cooldown, can't be interacted with
	DISABLED_RING, // Beacon is no longer available for the rest of the match, it is outside of the ring
	TEMP_DISABLED, // Beacon is disabled for now because a different one is in use
	INVALID,
	_count
}

enum eShadowArmyRespawnBeaconHintIndex
{
	RESPAWN_BEACON_SPAWN_LEGENDS_HINT,
	RESPAWN_BEACON_INUSE,
	_count
}

struct ShadowArmyRespawnBeaconData
{
	entity beaconEnt
	entity beaconWaypointEnt
}
#endif // SERVER || CLIENT

#if CLIENT
enum eShadowArmyRespawnBeaconDurationType // Used to get different times from beacon waypoints
{
	TIME_REMAINING_ON_COOLDOWN,
	FULL_COOLDOWN_DURATION,
	TIME_REMAINING_ON_USE,
	FULL_USE_DURATION,
	_count
}
#endif

#if SERVER || CLIENT
struct
{
	table < entity, ShadowArmyRespawnBeaconData > beaconToBeaconDataTable

	#if CLIENT
		table<entity, var> minimapIconRuiTable
		table<entity, var> fullmapIconRuiTable
	#endif

	#if SERVER
		array < entity > respawnBeacons
		float timeOfLastRespawnHint = -1.0
		float timeOfLastUseCommentary = -1.0
		entity beaconBeamVFX = null
	#endif
}
file
#endif // SERVER || CLIENT

#if SERVER || CLIENT
void function ShadowArmy_RespawnBeacon_Init()
{
	#if SERVER
		AddSpawnCallbackEditorClass( "prop_dynamic", "script_survival_revival_chamber", OnRespawnBeaconSpawned )
		AddSpawnCallback( "prop_dynamic", RespawnEntitySpawned )
		AddSpawnCallback( "prop_script", RespawnEntitySpawned )
		AddCallback_OnPlayerKilled( OnPlayerKilled )
		SURVIVAL_AddCallback_OnDeathFieldStartShrink( OnDeathfieldStartShrink )
		SURVIVAL_AddCallback_OnDeathFieldStopShrink( OnDeathfieldStopShrink )
		AddCallback_GameStateEnter( eGameState.Playing, ShadowArmy_RespawnBeacon_OnGamestateEnterPlaying_Server )
		AddCallback_EntitiesDidLoad( EntitiesDidLoad ) // Because the ring starts enabled, need to make sure we disabled any beacons out of the ring on gameplay start

		// VFX
		PrecacheParticleSystem( BEACON_BEAM_VFX )
		PrecacheParticleSystem( BEACON_BEAM_SUCCESS_VFX )

		RegisterSignal( "EndBeaconCooldown" )
	#endif

	#if CLIENT
		AddCreateCallback( "prop_dynamic", RespawnEntitySpawned )
		AddCreateCallback( "prop_script", RespawnEntitySpawned )
		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.RESPAWN_CHAMBER, MINIMAP_OBJECT_RUI, MinimapPackage_ShadowArmyRespawnBeacon, FULLMAP_OBJECT_RUI, FullmapPackage_ShadowArmyRespawnBeacon )
		Waypoints_RegisterCustomType( WAYPOINT_SHADOWARMY_RESPAWNBEACON, OnBeaconWaypointInstanced )
		AddCallback_EntitiesDidLoad( EntitiesDidLoad_Client )
		RegisterSignal( "StopHologramFX" )
		RegisterSignal( "BeaconStateChanged" )
	#endif // CLIENT

                   
                                                                                                                                    
                        

	ShadowArmy_RespawnBeacon_RegisterNetworking()
}
#endif // SERVER || CLIENT

void function ShadowArmy_RespawnBeacon_RegisterNetworking()
{
	// Server to Client
	Remote_RegisterClientFunction( "ShadowArmy_RespawnBeacon_ServerCallback_RespawnBeaconOnUse", "entity", "entity" )
	Remote_RegisterClientFunction( "ShadowArmy_RespawnBeacon_ServerCallback_ShowBeaconHint", "int", 0, eShadowArmyRespawnBeaconHintIndex._count )
	Remote_RegisterClientFunction( "ShadowArmy_RespawnBeacon_ServerCallback_ManageHoloFX", "entity", "bool" )
	Remote_RegisterClientFunction( "ShadowArmy_RespawnBeacon_ServerCallback_OnBeaconStateChanged", "entity" )
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CALLBACKS AND VAR SETTING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER
void function OnRespawnBeaconSpawned( entity ent )
{
	asset model = ent.GetModelName()

	vector origin = ent.GetOrigin()
	vector angles = ent.GetAngles()

	array<entity> links = ent.GetLinkEntArray()
	entity link

	if ( links.len() > 0 )
	{
		link = links[0]
	}

	entity par = ent.GetParent()
	ent.Destroy()

	AddRespawnBeaconLocation( origin ) // We don't run the OnRespawnChamberSpawned callback in sh_respawn_beacon.gnut so we need to add the beacon locations here so spawning and potentially other logic still works

	// spawn a new one with the correct targetname
	entity respawnBeacon = CreatePropScript_NoDispatchSpawn( model, origin, angles, 6 )
	SetTargetName( respawnBeacon, RESPAWN_CHAMBER_TARGETNAME )
	respawnBeacon.SetCanBeMeleed( false )
	DispatchSpawn( respawnBeacon )
	respawnBeacon.SetFadeDistance( 15000 )

	// Populate data
	ShadowArmyRespawnBeaconData beaconData
	beaconData.beaconEnt = respawnBeacon
	entity wp = CreateWaypoint_Custom( WAYPOINT_SHADOWARMY_RESPAWNBEACON )
	wp.SetWaypointEntity( WAYPOINT_ENT_IDX_RESPAWN_BEACON_ENT, respawnBeacon )
	wp.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME, UNSET_TIME )
	wp.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_DURATION, UNSET_TIME )
	wp.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_END_TIME, UNSET_TIME )
	wp.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_DURATION, UNSET_TIME )
	beaconData.beaconWaypointEnt = wp
	file.beaconToBeaconDataTable[ respawnBeacon ] <- beaconData
	// Set the beacon to an invalid state at first so when the state change happens it triggers sfx/vfx as expected ( only counts as valid state change if the state actually changes )
	wp.SetWaypointInt( WAYPOINT_INT_IDX_BEACON_STATE, eShadowArmyRespawnBeaconState.INVALID )
	file.respawnBeacons.append( respawnBeacon )

	if ( IsValid( link ) )
	{
		respawnBeacon.e.hasBomb = true
		respawnBeacon.e.lastBouncePosition = link.GetOrigin()
		respawnBeacon.e.goalAngles = link.GetAngles()
		link.Destroy()
	}

	if ( IsValid( par ) )
		ent.SetParent( par )
}
#endif // SERVER

#if SERVER || CLIENT
void function RespawnEntitySpawned( entity ent )
{
	if ( !IsRespawnBeaconEnt( ent ) )
		return

	#if SERVER
		ent.DisableHibernation()
		ent.AllowMantle()
		ent.SetUsable()
		ent.SetUsableByGroup( "pilot" )
		ent.AddUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
		ent.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE )

		ent.Minimap_SetAlignUpright( true )
		ent.Minimap_SetClampToEdge( false )
		ent.Minimap_SetCustomState( eMinimapObject_prop_script.RESPAWN_CHAMBER )
		ent.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	#endif

	AddBeaconEntToRespawnBeaconsArray( ent )
	SetCallback_CanUseEntityCallback( ent, CanPlayerUseBeacons )
	SetCallback_ShouldUseBlockReloadCallback( ent, SimpleShouldNotBlockReloadCallback )

	AddCallback_OnUseEntity_ClientServer( ent, RespawnBeaconOnUse )
}
#endif // SERVER || CLIENT

#if SERVER
void function EntitiesDidLoad()
{
	thread UpdateBeaconStatesOnDeathfieldStart_Thread()
}
#endif // SERVER

#if CLIENT
void function EntitiesDidLoad_Client()
{
	ShadowArmy_RespawnBeacon_UpdateBeaconMapFeature()
}
#endif // CLIENT

#if SERVER
// Wait for the deathfield to start and then check if any beacons are outside of the ring and disable them
// Because the ring starts enabled, we need to do this to catch any beacons that are outside the ring on match start
void function UpdateBeaconStatesOnDeathfieldStart_Thread()
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	EndSignal( svGlobal.levelEnt, "GameEnd" )

	OnThreadEnd(
		function() : (  )
		{
			OnDeathfieldStateChanged()
		}
	)

	FlagWait( "DeathCircleActive" )
}
#endif // SERVER

#if SERVER
// Set beacons to default state on playing gamestate ( need to do it here so players have joined the game and spawned before we start triggering idle sfx on the beacons )
void function ShadowArmy_RespawnBeacon_OnGamestateEnterPlaying_Server()
{
	foreach ( beacon in file.respawnBeacons )
	{
		// Set the starting state of the beacon. Do Deathfield state check in case beacon is outside the ring
		SetBeaconToDefaultState( beacon )
	}
}
#endif // SERVER

#if SERVER
// Check if any beacons should be disabled when the ring starts moving
void function OnDeathfieldStartShrink( table<int,DeathFieldData> deathFieldData )
{
	OnDeathfieldStateChanged()
}
#endif // SERVER

#if SERVER
// Check if any beacons should be disabled when the ring stops moving
// This is to catch cases of beacons that were active when the ring started moving, the remaining cases should be caught by other beacons state changes that also do ring checks
void function OnDeathfieldStopShrink( table<int,DeathFieldData> deathFieldData )
{
	OnDeathfieldStateChanged()
}
#endif // SERVER

#if SERVER
// Common function used to Disable beacons that are outside of the ring
void function OnDeathfieldStateChanged()
{
	foreach ( beacon in file.respawnBeacons )
	{
		if ( ShouldDisableOutOfDeathfieldBeacon( beacon ) )
			SetBeaconState( beacon, eShadowArmyRespawnBeaconState.DISABLED_RING )
	}
}
#endif // SERVER

#if CLIENT
void function MinimapPackage_ShadowArmyRespawnBeacon( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", RESPAWN_BEACON_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )

	file.minimapIconRuiTable[ent] <- rui
}
void function FullmapPackage_ShadowArmyRespawnBeacon( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", RESPAWN_BEACON_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )

	file.fullmapIconRuiTable[ent] <- rui
}
#endif // CLIENT

#if CLIENT
void function OnBeaconWaypointInstanced( entity wp )
{
	if ( !IsValid( wp ) )
		return

	if ( wp.GetWaypointCustomType() != WAYPOINT_SHADOWARMY_RESPAWNBEACON )
		return

	// Populate data on the Client
	ShadowArmyRespawnBeaconData beaconData
	entity respawnBeacon = wp.GetWaypointEntity( WAYPOINT_ENT_IDX_RESPAWN_BEACON_ENT )
	beaconData.beaconEnt = respawnBeacon
	beaconData.beaconWaypointEnt = wp
	file.beaconToBeaconDataTable[ respawnBeacon ] <- beaconData
	AddEntityCallback_GetUseEntOverrideText( respawnBeacon, RespawnBeacon_TextOverride )
	var rui = AddOverheadIcon( respawnBeacon, RESPAWN_BEACON_ICON, false, $"ui/overhead_icon_respawn_beacon_states.rpak" )
	RuiSetFloat2( rui, "iconSize", <80, 80, 0> )
	RuiSetFloat( rui, "distanceFade", RESPAWN_BEACON_ICON_FADE_DIST_NEAR )
	RuiSetBool( rui, "adsFade", true )
	RuiSetString( rui, "hint", "#RESPAWN_ALLCAPS" )

	thread ManageRespawnBeaconData_Thread( respawnBeacon, rui )
}
#endif // CLIENT

#if SERVER
// Display a hint to respawn Legends at Beacons to the whole alliance
// Only triggered when there are lots of players waiting to respawn and the hint is not on cooldown
const float HINT_COOLDOWN_TIME = 60.0
const int MIN_NUM_PLAYERS_WAITING_TO_RESPAWN = 5
void function OnPlayerKilled( entity player, entity attacker, var damageInfo )
{
	if ( !IsValid( player ) )
		return

	int playerTeam = player.GetTeam()
	int playerAlliance = AllianceProximity_GetAllianceFromTeam( playerTeam )

	// Display a hint to respawn Living Legends if the player that died is on the Legend Alliance and there is an odd number of Legends waiting to respawn
	bool isPastCooldownTime = file.timeOfLastRespawnHint < 0 || Time() > file.timeOfLastRespawnHint + HINT_COOLDOWN_TIME
	if ( isPastCooldownTime && playerAlliance == SHADOWARMY_LEGEND_ALLIANCE && ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount() >= MIN_NUM_PLAYERS_WAITING_TO_RESPAWN )
	{
		thread ShadowArmy_RespawnBeacon_PingRespawnBeaconOnDelay_Thread( playerTeam, true )
		file.timeOfLastRespawnHint = Time()
	}
}
#endif // SERVER



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SUPPORTING GET/SET FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER || CLIENT
// Can this player interact with any beacon
// This determines if the player can interact at all with beacons and determines whether interaction hints appear or not
// NOTE: I allow the player to interact with beacons here even if they can't really perform a meaningful interaction, just so hints display
// The function that determines whether the player actually triggers a real success is ShadowArmy_RespawnBeacon_CanBeaconBeUsedByPlayer
bool function CanPlayerUseBeacons( entity player, entity ent, int useFlags )
{
	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( player.ContextAction_IsActive() )
		return false

	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return false

	if ( ent.e.isBusy )
		return false


	return true
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Can this beacon be used by this player
bool function ShadowArmy_RespawnBeacon_CanBeaconBeUsedByPlayer( entity player, entity beacon )
{
	if ( !IsValid( player ) || !IsValid( beacon ) )
		return false

	// Is this respawn beacon in the correct state to be interacted with by this player
	if ( !GetIsBeaconInInteractableStateForPlayer( player, beacon ) )
		return false

	// Are there any Legends waiting to Respawn?
	if ( !GetAreAnyLegendsWaitingToRespawn() )
		return false

	return true
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Get whether the state of this beacon allows for an interaction from this player
bool function GetIsBeaconInInteractableStateForPlayer( entity player, entity beacon )
{
	if ( !IsValid( player ) || !IsValid( beacon ) )
		return false

	bool isRevPlayer = ShadowArmy_IsPlayerOnShadowArmy( player )

	// Interaction is only supported if the player is a Legend and the Respawn Beacon is in its idle state
	if ( !isRevPlayer && ShadowArmy_RespawnBeacon_CanBeaconBeUsed(  beacon ) )
		return true

	return false
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Get whether the state of this beacon allows for an interaction
bool function ShadowArmy_RespawnBeacon_CanBeaconBeUsed( entity beacon )
{
	if ( !IsValid( beacon ) )
		return false

	int beaconState = GetBeaconState( beacon )
	// Interaction is only supported if the Respawn Beacon is in its idle state
	if ( beaconState == eShadowArmyRespawnBeaconState.IDLE )
		return true

	return false
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return whether there are any Living Legends waiting to respawn
bool function GetAreAnyLegendsWaitingToRespawn()
{
                   
                                                                           
                                                                                                                             
              
                         

	return ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount() > 0
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return the number of Legends waiting to respawn
int function ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount()
{
	return GetArrayOfLegendsWaitingToRespawn().len()
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return the legends that are waiting to respawn
array< entity > function GetArrayOfLegendsWaitingToRespawn()
{
	array < entity > legendsWaitingToRespawn = []

	if ( GetGameState() < eGameState.Playing )
		return legendsWaitingToRespawn

	array < entity > legendsArray = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false )

	foreach ( legend in legendsArray )
	{
		if ( IsValid( legend ) && !IsAlive( legend ) && legend.GetPlayerNetInt( "respawnStatus" ) != eRespawnStatus.PLAYER_ELIMINATED )
			legendsWaitingToRespawn.append( legend )
	}

	return legendsWaitingToRespawn
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return whether this entity is a respawn beacon ( note that for this mode we do not count MRBs )
bool function IsRespawnBeaconEnt( entity ent )
{
	if ( ent.GetTargetName() == RESPAWN_CHAMBER_TARGETNAME )
		return true

	return false
}
#endif // SERVER || CLIENT

#if SERVER
// Check if the beacon should be disabled due to being outside of the ring
bool function ShouldDisableOutOfDeathfieldBeacon( entity beacon )
{
	if ( !IsValid( beacon ) )
		return false

	return !SURVIVAL_PosInsideDeathField( eRealms.DEFAULT, beacon.GetOrigin() )
}
#endif // SERVER

#if SERVER
// Set the beacon to its starting state, but check to make sure it shouldn't be disabled for being outside of the ring
void function SetBeaconToDefaultState( entity beacon )
{
	if ( !IsValid( beacon ) )
		return

	ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
	entity beaconWaypoint = beaconData.beaconWaypointEnt

	if ( !IsValid( beaconWaypoint ) )
		return

	if ( beaconWaypoint.GetWaypointCustomType() != WAYPOINT_SHADOWARMY_RESPAWNBEACON )
	{
		#if DEV
			Assert( false, "Shadow Army Respawn Beacon: Running SetBeaconToDefaultState on an entity that is not a respawn beacon waypoint" )
		#endif // DEV
		return
	}

	bool shouldDisableBeaconOutOfRing = false
	if ( GetGameState() == eGameState.Playing )
		shouldDisableBeaconOutOfRing = ShouldDisableOutOfDeathfieldBeacon( beacon )

	if ( shouldDisableBeaconOutOfRing )
		SetBeaconState( beacon, eShadowArmyRespawnBeaconState.DISABLED_RING )
	else
		SetBeaconState( beacon, eShadowArmyRespawnBeaconState.IDLE )
}
#endif // SERVER

#if SERVER
// Ensure the new state we are trying to set a beacon to is valid based on the beacons current state. Then set the state of a beacon on the Server and the Client ( need to trigger a callback to update on the Client )
void function SetBeaconState( entity beacon, int newBeaconState )
{
	if ( !IsValid( beacon ) )
		return

	int currentBeaconState = GetBeaconState( beacon )

	// No point in setting the same state multiple times
	if ( newBeaconState == currentBeaconState )
		return

	bool isStateChangeValid = false
	bool shouldStartHoloFX = false
	bool shouldStopHoloFX = false

	switch( newBeaconState )
	{
		case eShadowArmyRespawnBeaconState.IDLE:
			if ( currentBeaconState != eShadowArmyRespawnBeaconState.DISABLED_RING )
			{
				isStateChangeValid = true
				shouldStartHoloFX = true
			}
			break
		case eShadowArmyRespawnBeaconState.IN_USE:
			if ( currentBeaconState == eShadowArmyRespawnBeaconState.IDLE )
				isStateChangeValid = true
			break
		case eShadowArmyRespawnBeaconState.COOLDOWN:
			if ( currentBeaconState != eShadowArmyRespawnBeaconState.DISABLED_RING )
			{
				isStateChangeValid = true
				shouldStopHoloFX = true
			}
			break
		case eShadowArmyRespawnBeaconState.DISABLED_RING:
			if ( currentBeaconState != eShadowArmyRespawnBeaconState.IN_USE )
			{
				isStateChangeValid = true
				shouldStopHoloFX = true
			}
			break
		case eShadowArmyRespawnBeaconState.TEMP_DISABLED:
			if ( currentBeaconState != eShadowArmyRespawnBeaconState.IN_USE && currentBeaconState != eShadowArmyRespawnBeaconState.COOLDOWN && currentBeaconState != eShadowArmyRespawnBeaconState.DISABLED_RING )
			{
				isStateChangeValid = true
				shouldStopHoloFX = true
			}
			break
		case eShadowArmyRespawnBeaconState.INVALID:
			isStateChangeValid = true
			break
		default:
			#if DEV
				Assert( false, "Shadow Army Respawn Beacon: Unsupported beacon state: " + newBeaconState + " for beacon: " + beacon + " in SetBeaconState" )
			#endif // DEV
			break
	}

	printt( "Shadow Army Respawn Beacon: Running SetBeaconState on beacon: " + beacon + " isStateChangeValid: " + isStateChangeValid + " currentBeaconState: " + currentBeaconState + " newBeaconState: " + newBeaconState )

	if ( isStateChangeValid )
	{
		ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
		entity beaconWaypoint = beaconData.beaconWaypointEnt

		if ( IsValid( beaconWaypoint ) && beaconWaypoint.GetWaypointCustomType() == WAYPOINT_SHADOWARMY_RESPAWNBEACON )
			beaconWaypoint.SetWaypointInt( WAYPOINT_INT_IDX_BEACON_STATE, newBeaconState )
	#if DEV
		else
			Assert( false, "Shadow Army Respawn Beacon: Couldn't set beacon state in SetBeaconState due to invalid beaconWaypoint" )
	#endif // DEV

		// Trigger a server callback to stop or start the hologram FX on this beacon
		if ( shouldStartHoloFX || shouldStopHoloFX )
		{
			bool isStartingHoloFX = shouldStartHoloFX
			ManageBeaconHologramFX( beacon, isStartingHoloFX )
		}

		// Let the Client know that the beacon changed states
		array < entity > allPlayerArray = GetPlayerArrayIncludingSpectators()
		foreach ( player in allPlayerArray )
		{
			if ( IsValid( player ) )
				Remote_CallFunction_Replay( player, "ShadowArmy_RespawnBeacon_ServerCallback_OnBeaconStateChanged", beacon )
		}
	}
}
#endif // SERVER

#if CLIENT
void function UpdateMapIcons( entity beacon, asset icon )
{
	if ( beacon in file.minimapIconRuiTable )
	{
		RuiSetImage( file.minimapIconRuiTable[beacon], "defaultIcon", icon )
	}
	if ( beacon in file.fullmapIconRuiTable )
	{
		RuiSetImage( file.fullmapIconRuiTable[beacon], "defaultIcon", icon )
	}
}

// Server Callback to tell the beacon script that manages icons that the state of this beacon has changed
void function ShadowArmy_RespawnBeacon_ServerCallback_OnBeaconStateChanged( entity beacon )
{
	if ( !IsValid( beacon ) )
		return

	beacon.Signal( "BeaconStateChanged" )
}
#endif // CLIENT

#if SERVER || CLIENT
// Get the state of a beacon
int function GetBeaconState( entity beacon )
{
	if ( !IsValid( beacon ) )
	{
		#if DEV
			Assert( false, "Shadow Army Respawn Beacon: GetBeaconState is going to return eShadowArmyRespawnBeaconState.INVALID due to Invalid beacon" )
		#endif // DEV
		return eShadowArmyRespawnBeaconState.INVALID
	}

	ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
	entity beaconWaypoint = beaconData.beaconWaypointEnt

	if ( !IsValid( beaconWaypoint ) || beaconWaypoint.GetWaypointCustomType() != WAYPOINT_SHADOWARMY_RESPAWNBEACON )
		return eShadowArmyRespawnBeaconState.INVALID

	return beaconWaypoint.GetWaypointInt( WAYPOINT_INT_IDX_BEACON_STATE )
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Get the beacon data from the beacon entity
ShadowArmyRespawnBeaconData function GetBeaconDataFromBeaconEnt( entity beacon )
{
	ShadowArmyRespawnBeaconData data

	if ( !( beacon in file.beaconToBeaconDataTable ) )
		return data

	return file.beaconToBeaconDataTable[ beacon ]
}
#endif // SERVER || CLIENT

#if CLIENT
// Get the remaining time left for cooldown to be completed on this beacon
float function GetRemainingCooldownDurationOnBeacon( entity beacon )
{
	return GetBeaconDurationForDurationType( beacon, eShadowArmyRespawnBeaconDurationType.TIME_REMAINING_ON_COOLDOWN )
}
#endif //  CLIENT

#if CLIENT
// Get the duration of the cooldown that was set on this beacon ( we have a short cooldown and a long cooldown )
// The GetRemainingCooldownDurationOnBeacon tells us how much time is remaining on the cooldown but we need to know how long the cooldown was originally to show progress on the icons
float function GetFullDurationOfCooldownOnBeacon( entity beacon )
{
	return GetBeaconDurationForDurationType( beacon, eShadowArmyRespawnBeaconDurationType.FULL_COOLDOWN_DURATION )
}
#endif //  CLIENT

#if SERVER || CLIENT
float function GetBeaconUseDuration( entity player, entity beacon )
{
	float duration = BEACON_INTERACT_TIME

	// If we have a valid player and beacon we can see if a special interact time should be used. Otherwise we will just be returning the default
	if ( IsValid( player ) && IsValid( beacon ) )
	{
		// Give a faster interact time for Support Class Legends
		if ( Perks_GetRoleForPlayer( player ) == eCharacterClassRole.SUPPORT )
			duration = SUPPORT_LEGEND_BEACON_INTERACT_TIME
	}

	return duration
}
#endif // SERVER || CLIENT

#if CLIENT
// Get the time remaining on the interaction to call in the respawn on this beacon
float function GetRemainingUseDurationOnBeacon( entity beacon )
{
	return GetBeaconDurationForDurationType( beacon, eShadowArmyRespawnBeaconDurationType.TIME_REMAINING_ON_USE )
}
#endif //  CLIENT

#if CLIENT
// Get the duration of the use interaction that was set on this beacon ( we have a support legend use duration and the regular duration )
// The GetRemainingUseDurationOnBeacon tells us how much time is remaining on the use interaction but we need to know how long the use duration was originally to show progress on the icons and HUD
float function GetFullDurationOfUseInteractOnBeacon( entity beacon )
{
	return GetBeaconDurationForDurationType( beacon, eShadowArmyRespawnBeaconDurationType.FULL_USE_DURATION )
}
#endif //  CLIENT

#if CLIENT
// Common function to get different duration or time values for beacons
float function GetBeaconDurationForDurationType( entity beacon, int durationType )
{
	float duration = UNSET_TIME

	if ( !IsValid( beacon ) )
	{
		Warning( "Shadow Army Respawn Beacon: GetBeaconDurationForDurationType going to return UNSET_TIME because the Beacon was not valid for durationType: " + GetEnumString( "eShadowArmyRespawnBeaconDurationType", durationType ) )
		return duration
	}

	if ( durationType < 0 || durationType >= eShadowArmyRespawnBeaconDurationType._count )
	{
		#if DEV
			Warning( "Shadow Army Respawn Beacon: Tried to run GetBeaconDurationForDurationType with an invalid duration type: " + durationType + " valid types are: " )
			for ( int i = 0; i < eShadowArmyRespawnBeaconDurationType._count; i++ )
			{
				printt( GetEnumString( "eShadowArmyRespawnBeaconDurationType", i ) + " is index: " + i )
			}
		#endif // DEV
		return duration
	}

	ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
	entity beaconWaypoint = beaconData.beaconWaypointEnt

	if ( IsValid( beaconWaypoint ) && beaconWaypoint.GetWaypointCustomType() == WAYPOINT_SHADOWARMY_RESPAWNBEACON )
	{
		switch( durationType )
		{
			case( eShadowArmyRespawnBeaconDurationType.TIME_REMAINING_ON_COOLDOWN ):
				duration = max( 0.0, ( beaconWaypoint.GetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME ) - Time() ) )
				break
			case( eShadowArmyRespawnBeaconDurationType.FULL_COOLDOWN_DURATION ):
				duration = beaconWaypoint.GetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_DURATION )
				break
			case( eShadowArmyRespawnBeaconDurationType.TIME_REMAINING_ON_USE ):
				duration = max( 0.0, ( beaconWaypoint.GetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_END_TIME ) - Time() ) )
				break
			case( eShadowArmyRespawnBeaconDurationType.FULL_USE_DURATION ):
				duration = beaconWaypoint.GetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_DURATION )
				break
			default:
				#if DEV
					Warning( "Shadow Army Respawn Beacon: GetBeaconDurationForDurationType encountered an unsupported duration type in the switch statement: " + durationType )
				#endif // DEV
				break
		}
	}
#if DEV
	else
	{
		Warning( "Shadow Army Respawn Beacon: GetBeaconDurationForDurationType going to return UNSET_TIME because the Beacon Waypoint was not valid for durationType: " + GetEnumString( "eShadowArmyRespawnBeaconDurationType", durationType ) )
	}
#endif // DEV

	return duration
}
#endif //  CLIENT




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HANDLE USAGE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if SERVER || CLIENT
void function RespawnBeaconOnUse( entity pickup, entity player, int pickupFlags )
{
	if ( !IsBitFlagSet( pickupFlags, USE_INPUT_LONG ) )
		return

	float time = Time()
	ShadowArmy_RespawnBeaconOnUse_Common( pickup, player, time )

	#if SERVER
		// Bug fix for http://jiratf.respawn.net:8080/browse/R5DEV-144665
		// The problem occurs if the user holds down the USE key when the chamber's setUsable is turned to true.
		// The server gets the EntityUse call but the client does not because prediction cannot predict that you are about to use the entity (it isn't there or on)
		// So the EntityUse is not triggered on the client. The respawn still ultimately happens because the server triggers.
		// The desire was to keep the predicted method, and run a just-in-case ping on the client.
		Remote_CallFunction_NonReplay( player, "ShadowArmy_RespawnBeacon_ServerCallback_RespawnBeaconOnUse", pickup, player ) // Our just-in-case ping.
	#endif
}
#endif // SERVER || CLIENT

#if CLIENT
void function ShadowArmy_RespawnBeacon_ServerCallback_RespawnBeaconOnUse( entity pickup, entity player )
{
	if ( !IsValid( pickup ) || !IsValid( player ) ) // Cautionary measure in case the remote call is VERY late in being received
		return

	// Note: it is theoretically possible for the client to predict the USE, then remove the USE before we get this remote call leading to
	// an erroneous call to ShadowArmy_RespawnBeaconOnUse_Common.  However, if the player's USE key isn't active, the flag is cleared,
	// as is the UI, through normal "extended_use" logic and we don't see the UI come up when we're not supposed to.
	if ( player.p.isInExtendedUse )
	{
		// We have already brought up the UI
		return
	}
	else
	{
		ShadowArmy_RespawnBeaconOnUse_Common( pickup, player, Time() )
	}
}
#endif

#if SERVER || CLIENT
void function ShadowArmy_RespawnBeaconOnUse_Common( entity beacon, entity player, float startTime )
{
	if ( !IsValid( player ) || !IsValid( beacon ) )
		return

	// We say players can interact with the beacon even if they can't so that hints display.
	// If this is a player that can't actually use the beacon break out here
	if ( !ShadowArmy_RespawnBeacon_CanBeaconBeUsedByPlayer( player, beacon ) )
	{
		#if SERVER
			// Play one off 3p SFX for failed interaction
			EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_USE_FAIL_SFX )
		#endif
		return
	}

	ExtendedUseSettings settings

	#if CLIENT
		HidePlayerHint( "#RESPAWN_AT_BEACONS_HINT" )
		settings.loopSound = SHADOWARMY_RESPAWNBEACON_USE_HOLD_SFX
		settings.displayRui = $"ui/health_use_progress.rpak"
		settings.displayRuiFunc = DisplayRuiForRespawnBeacon
		settings.icon = $""
		settings.hint = GetUseInProgressHint( beacon )
		settings.icon = RESPAWN_BEACON_ICON
		settings.serverStartTime = startTime
	#elseif SERVER
		settings.startFunc = RespawnBeaconStartUse
		settings.endFunc = RespawnBeaconStopUse
		settings.successFunc = RespawnBeaconUseSuccess
		settings.exclusiveUse = true
		settings.movementDisable = true
		settings.holsterWeapon = true
		settings.holsterViewModelOnly = true
	#endif

	settings.duration = GetBeaconUseDuration( player, beacon )
	settings.useInputFlag = IN_USE_LONG

	thread ExtendedUse( beacon, player, settings )
}
#endif // SERVER || CLIENT

#if SERVER
// Set the state of the Respawn Beacon and other beacons in the world when a player starts interacting with it
void function RespawnBeaconStartUse( entity beacon, entity player, ExtendedUseSettings settings )
{
	if ( !IsValid( beacon ) )
		return

	if ( !ShadowArmy_RespawnBeacon_CanBeaconBeUsedByPlayer( player, beacon ) )
		return

	RespawnBeaconStartUse_Common( beacon, player, settings )

	int currentBeaconState = GetBeaconState( beacon )

	if ( currentBeaconState == eShadowArmyRespawnBeaconState.INVALID || currentBeaconState == eShadowArmyRespawnBeaconState.TEMP_DISABLED )
		return

	if ( currentBeaconState == eShadowArmyRespawnBeaconState.IDLE )
	{
		ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
		entity beaconWaypoint = beaconData.beaconWaypointEnt

		if ( IsValid( beaconWaypoint ) )
		{
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_END_TIME, Time() + settings.duration )
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_DURATION, settings.duration )
		}

		SetBeaconState( beacon, eShadowArmyRespawnBeaconState.IN_USE )
		SetStateForAllOtherBeacons( beacon, eShadowArmyRespawnBeaconState.TEMP_DISABLED )

		// Show a beam to the used beacon
		int attachmentID = beacon.LookupAttachment( "FX_EMITTER" )
		if ( attachmentID != 0 )
		{
			file.beaconBeamVFX = StartParticleEffectOnEntity_ReturnEntity( beacon, GetParticleSystemIndex( BEACON_BEAM_VFX ), FX_PATTACH_POINT, attachmentID )
		}

		// Play Beam SFX
		EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_INUSE_3P_SFX )

		// Try playing announcer commentary
		TryPlayingBeaconInUseAnnouncerCommentary()
	}
	#if DEV
	else
	{
		Assert( false, "Shadow Army Respawn Beacon: RespawnBeaconStartUse is running on a beacon: " + beacon + " with an unexpected state: " + currentBeaconState )
	}
	#endif // DEV
}
#endif // SERVER

#if SERVER
// Set the state for all other respawn beacons when the state of this beacon changed
void function SetStateForAllOtherBeacons( entity beaconWithStateChange, int state )
{
	foreach ( beacon in file.respawnBeacons )
	{
		if ( IsValid( beacon ) && beacon != beaconWithStateChange )
			SetBeaconState( beacon, state )
	}
}
#endif // SERVER

#if SERVER
// Set the state of the Respawn Beacon when a player stops interacting with it
void function RespawnBeaconStopUse( entity beacon, entity player, ExtendedUseSettings settings )
{
	if ( !IsValid( beacon ) )
		return

	RespawnBeaconStopUse_Common( beacon, player )

	int currentBeaconState = GetBeaconState( beacon )

	if ( currentBeaconState == eShadowArmyRespawnBeaconState.INVALID || currentBeaconState == eShadowArmyRespawnBeaconState.TEMP_DISABLED )
		return

	if ( currentBeaconState == eShadowArmyRespawnBeaconState.IN_USE )
	{
		// Other beacons were disabled while this one was in use, reactivate them now
		SetStateForAllOtherBeacons( beacon, eShadowArmyRespawnBeaconState.IDLE )

		// Put this beacon on a short cooldown to prevent players from spam starting and canceling beacon use
		thread ManageRespawnBeaconCooldown_Thread( beacon, BEACON_SHORT_COOLDOWN_DURATION )

		// Turn off beam VFX
		if ( IsValid( file.beaconBeamVFX ) )
		{
			file.beaconBeamVFX.Destroy()
			file.beaconBeamVFX = null
		}

		// Turn off beam SFX
		StopSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_INUSE_3P_SFX )

		ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
		entity beaconWaypoint = beaconData.beaconWaypointEnt

		if ( IsValid( beaconWaypoint ) )
		{
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_END_TIME, UNSET_TIME )
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_DURATION, UNSET_TIME )
		}
	}
}
#endif // SERVER

#if SERVER
// Set the respawn beacon and all other beacons to the correct state when a successful interaction has been completed on a beacon
const float OBJECTIVE_WAYPOINT_HEIGHT_OFFSET = 100.0
const float COMMENTARY_DELAY = 6.0
void function RespawnBeaconUseSuccess( entity beacon, entity playerUser, ExtendedUseSettings settings )
{
	if ( !IsValid( beacon ) || !IsValid( playerUser ) )
		return

	// Just in case, only Legends are allowed to use the beacons
	if ( AllianceProximity_GetAllianceFromTeam( playerUser.GetTeam() ) != SHADOWARMY_LEGEND_ALLIANCE )
	{
		RespawnBeaconStopUse( beacon, playerUser, settings )
		return
	}

	int currentBeaconState = GetBeaconState( beacon )

	if ( currentBeaconState == eShadowArmyRespawnBeaconState.INVALID )
		return

	if ( currentBeaconState == eShadowArmyRespawnBeaconState.IN_USE )
	{
		// Success, spawn players
		ShadowArmy_RespawnBeacon_SpawnPlayers( playerUser, beacon )
		// Put this beacon on Cooldown
		thread ManageRespawnBeaconCooldown_Thread( beacon, BEACON_REGULAR_COOLDOWN_DURATION )

		// Display a message for all players
		ShadowArmy_DisplayMessageForAllPlayers( eShadowArmyMessageIndex.LEGENDS_RESPAWNED, eShadowArmyMessageIndex.LEGENDS_RESPAWNED, eShadowArmyMessageType.OBIT_ONLY )

		// Turn off beam VFX
		if ( IsValid( file.beaconBeamVFX ) )
		{
			file.beaconBeamVFX.Destroy()
			file.beaconBeamVFX = null
		}

		// Turn off beam SFX
		StopSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_INUSE_3P_SFX )

		thread PlayRespawnSuccessEffectsOnBeacon_Thread( beacon )

		// Other beacons were disabled while this one was in use, reactivate them now
		SetStateForAllOtherBeacons( beacon, eShadowArmyRespawnBeaconState.IDLE )
		
		// Play announcer Commentary
		thread PlayCommentaryLineToAllPlayersDelayed( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_ARMY_BEACON_COMPLETE ), COMMENTARY_DELAY )

		ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )
		entity beaconWaypoint = beaconData.beaconWaypointEnt

		if ( IsValid( beaconWaypoint ) )
		{
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_END_TIME, UNSET_TIME )
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_USE_DURATION, UNSET_TIME )
		}
	}
}
#endif // SERVER

#if SERVER
// Respawn players in dropships
void function ShadowArmy_RespawnBeacon_SpawnPlayers( entity beaconUser, entity beacon = null )
{
	// Add players in each squad into their own dropship and respawn them
	array < entity > allAlliancePlayers = AllianceProximity_GetAllPlayersInAlliance( SHADOWARMY_LEGEND_ALLIANCE, false )
	array < array < entity > > arrayOfLegendsToRespawnArrays
	int currentArrayIndex = 0

	// Put players into spawn groups that fit individual dropships so we can fit as many players as possible on to each ship and decrease the number of ships that come in
	foreach ( player in allAlliancePlayers )
	{
		if ( !IsValid( player ) || IsAlive( player ) )
			continue

		int playerTeam = player.GetTeam()
		if ( ShadowArmy_IsSquadReallyEliminated( playerTeam ) )
			continue

		// If there is already a spawn group array at this index, use it and append the player to it. Otherwise create a new group and add it to the array
		array < entity > currentSpawnGroupArray
		if ( arrayOfLegendsToRespawnArrays.len() > currentArrayIndex )
			currentSpawnGroupArray = arrayOfLegendsToRespawnArrays[ currentArrayIndex ]
		else
			arrayOfLegendsToRespawnArrays.append( currentSpawnGroupArray )

		currentSpawnGroupArray.append( player )

		// Reached the max number of players that can be in a plane, start a new spawngroup
		if ( currentSpawnGroupArray.len() == RESPAWN_BEACON_MAX_NUM_POSITIONS_ON_DROPSHIP )
			currentArrayIndex++
	}

	// Go through our spawn groups and spawn players in dropships
	foreach ( spawnGroupArray in arrayOfLegendsToRespawnArrays )
	{
		if ( spawnGroupArray.len() > 0 )
		{
			// For testing we allow a null to be passed in, in which case find the closest beacon to a living team member or use a random beacon to respawn players
			if ( !IsValid( beacon ) )
			{
				entity livingTeammate
				foreach ( groupPlayer in spawnGroupArray )
				{
					if ( !IsValid( groupPlayer ) )
						continue

					array < entity > livingTeammatesArray = GetPlayerArrayOfTeam_Alive( groupPlayer.GetTeam() )
					if ( livingTeammatesArray.len() > 0 )
					{
						livingTeammate = livingTeammatesArray[ 0 ]
						break
					}
				}

				if ( IsValid( livingTeammate ) )
					beacon = RespawnBeacon_GetClosestValidBeacon( livingTeammate, livingTeammate.GetOrigin() )
				else
					beacon = file.respawnBeacons.getrandom()
			}

			if ( IsValid( beacon ) )
			{
				thread RespawnPlayersInDropship( spawnGroupArray, beacon )

				// Set match summary data, regardless of how many players are respawned, count it as a single respawn
				if ( IsValid( beaconUser ) )
					Survival_PlayerRespawnedTeammate( beaconUser, spawnGroupArray[ 0 ] )
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Put a respawn beacon on cooldown and manage the cooldown state
void function ManageRespawnBeaconCooldown_Thread( entity beacon, float cooldownDuration )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsValid( beacon ) )
		return
	beacon.Signal( "EndBeaconCooldown" )
	EndSignal( beacon, "EndBeaconCooldown", "OnDestroy" )

	if ( cooldownDuration <= 0 )
		return

	SetBeaconState( beacon, eShadowArmyRespawnBeaconState.COOLDOWN )
	ShadowArmyRespawnBeaconData beaconData = GetBeaconDataFromBeaconEnt( beacon )

	// Play one off SFX
	EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_COOLDOWN_START_SFX )
	// Play looping SFX
	EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_COOLDOWN_SFX )

	entity beaconWaypoint = beaconData.beaconWaypointEnt

	if ( IsValid( beaconWaypoint ) )
	{
		float cooldownEndTime = beaconWaypoint.GetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME )

		// If there is already a thread handling cooldown on this beacon, just update the end time and then break out
		if ( cooldownEndTime > Time() )
		{
			// The current cooldown on this beacon is less than what this cooldown would be, set it to this new cooldown end time
			if ( cooldownEndTime < Time() + cooldownDuration )
			{
				beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME, Time() + cooldownDuration )
				beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_DURATION, cooldownDuration )
			}

			return
		}
		else
		{
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME, Time() + cooldownDuration )
			beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_DURATION, cooldownDuration )
		}
	}

	OnThreadEnd(
		function() : ( beacon, beaconWaypoint )
		{
			if ( IsValid( beacon ) )
			{
				SetBeaconToDefaultState( beacon )
				StopSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_COOLDOWN_SFX )
			}

			if ( IsValid( beaconWaypoint ) )
			{
				beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME, UNSET_TIME )
				beaconWaypoint.SetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_DURATION, UNSET_TIME )
			}
		}
	)

	wait cooldownDuration

	float cooldownEndTime
	float timeToNextCheck

	while ( GetGameState() == eGameState.Playing && IsValid( beaconWaypoint ) )
	{
		cooldownEndTime = beaconWaypoint.GetWaypointFloat( WAYPOINT_FLOAT_IDX_RESPAWN_BEACON_COOLDOWN_END_TIME )

		if ( Time() >= cooldownEndTime )
			break

		// Figure out how long to wait for the next check ( since the time could have been updated by a different cooldown call )
		timeToNextCheck = cooldownEndTime - Time()

		wait timeToNextCheck
	}
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MESSAGING, ICONS, VFX, AUDIO
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if CLIENT
// Manage Client side beacon data ( HUD, in world icons, map icons )
const float POST_SIGNAL_DELAY = 0.1 // Need to wait a little after the status changed signal comes through for the beacon state to update on the Client
void function ManageRespawnBeaconData_Thread( entity beacon, var rui )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	WaitEndFrame() // minimap and map packages register after this waypoint gets instanced so icons won't update properly if we don't do this wait

	if ( !IsValid( beacon ) )
		return

	if ( !IsValid( rui ) )
		return

	beacon.EndSignal( "OnDestroy" )
	UpdateRespawnChamberRuis( rui, GetAreAnyLegendsWaitingToRespawn() ) // ToDo: Tarek: I don't think we need this call once you do your stuff in the switch statement below

	// Wait for beacon state changes and update the icons when there is a state change
	while ( GetGameState() <= eGameState.Playing )
	{
		int currentBeaconState = GetBeaconState( beacon )
		printt("Shadow Army Respawn Beacon: ManageRespawnBeaconData_Thread is updating after beacon changed state to: " + GetEnumString( "eShadowArmyRespawnBeaconState", currentBeaconState ) )
		switch( currentBeaconState )
		{
			case eShadowArmyRespawnBeaconState.INVALID:
				// Update Map Icons
				UpdateMapIcons( beacon, $"" )
				break
			case eShadowArmyRespawnBeaconState.IDLE:
				RuiSetFloat3( rui, "iconColor", <0.67, 0.96, 0.32> )
				RuiSetFloat3( rui, "bgColor", <0, 0, 0> )
				RuiSetFloat3( rui, "borderColor", <1, 1, 1> )
				RuiSetBool( rui, "isOnCooldown", false )
				RuiSetBool( rui, "isInUse", false )
				RuiSetBool( rui, "showHint", true )
				// Update Map Icons
				UpdateMapIcons( beacon, RESPAWN_BEACON_ICON )
				RuiSetFloat( rui, "distanceFade", RESPAWN_BEACON_ICON_FADE_DIST_NEAR )
				break
			case eShadowArmyRespawnBeaconState.IN_USE:
				RuiSetFloat3( rui, "iconColor", <0.67, 0.96, 0.32> )
				RuiSetFloat3( rui, "bgColor", <0, 0, 0> )
				RuiSetFloat3( rui, "borderColor", <1, 1, 1> )
				RuiSetBool( rui, "isOnCooldown", false )
				RuiSetBool( rui, "isInUse", true )
				RuiSetFloat( rui, "remainingInUseTime", GetRemainingUseDurationOnBeacon( beacon ) )
				RuiSetFloat( rui, "maxInUseTime", max( GetFullDurationOfUseInteractOnBeacon( beacon ), 0.01) )
				RuiSetBool( rui, "showHint", false )
				// Update HUD for in use Beacon
				var gameRUI = ClGameState_GetRui()
				if ( gameRUI != null )
				{
					RuiSetGameTime( gameRUI, "respawnStartTime", Time() )
					RuiSetGameTime( gameRUI, "respawnEndTime", Time() + GetRemainingUseDurationOnBeacon( beacon ) )
				}
				// Update Map Icons
				UpdateMapIcons( beacon, RESPAWN_BEACON_INUSE_ICON )
				RuiSetFloat( rui, "distanceFade", 50000 )
				break
			case eShadowArmyRespawnBeaconState.COOLDOWN:
				RuiSetFloat3( rui, "iconColor", <1, 1, 1> )
				RuiSetFloat3( rui, "bgColor", <0, 0, 0> )
				RuiSetFloat3( rui, "borderColor", <1, 1, 1> )
				RuiSetFloat3( rui, "cdStripes" , <0.4, 0.4, 0.4> )
				RuiSetBool( rui, "isOnCooldown", true )
				RuiSetFloat( rui, "remainingCdTime", GetRemainingCooldownDurationOnBeacon( beacon ) )
				RuiSetFloat( rui, "maxCdTime", max(GetFullDurationOfCooldownOnBeacon( beacon ) , 0.01) )
				RuiSetBool( rui, "isInUse", false )
				RuiSetBool( rui, "showHint", false )
				// Update HUD to clear in use beacon
				var gameRUI = ClGameState_GetRui()
				if ( gameRUI != null )
				{
					RuiSetGameTime( gameRUI, "respawnStartTime", RUI_BADGAMETIME )
					RuiSetGameTime( gameRUI, "respawnEndTime", RUI_BADGAMETIME )
				}
				// Update Map Icons
				UpdateMapIcons( beacon, RESPAWN_BEACON_DISABLED_ICON )
				RuiSetFloat( rui, "distanceFade", RESPAWN_BEACON_ICON_FADE_DIST_NEAR )
				break
			case eShadowArmyRespawnBeaconState.DISABLED_RING:
				RuiSetBool( rui, "isRingDisabled", true )
				RuiSetBool( rui, "isOnCooldown", false )
				RuiSetBool( rui, "isInUse", false )
				RuiSetBool( rui, "showHint", false )
				// Update Map Icons
				UpdateMapIcons( beacon, $"" )
				RuiSetFloat( rui, "distanceFade", RESPAWN_BEACON_ICON_FADE_DIST_NEAR )
				break
			case eShadowArmyRespawnBeaconState.TEMP_DISABLED:
				RuiSetFloat3( rui, "iconColor", <0.2, 0.2, 0.2> )
				RuiSetFloat3( rui, "bgColor", <0.5, 0.5, 0.5> )
				RuiSetFloat3( rui, "borderColor", <0, 0, 0> )
				RuiSetBool( rui, "isOnCooldown", false )
				RuiSetBool( rui, "isInUse", false )
				RuiSetBool( rui, "showHint", false )
				// Update Map Icons
				UpdateMapIcons( beacon, RESPAWN_BEACON_DISABLED_ICON )
				RuiSetFloat( rui, "distanceFade", RESPAWN_BEACON_ICON_FADE_DIST_NEAR )
				break
			default:
				// Update Map Icons
				UpdateMapIcons( beacon, $"" )
				#if DEV
					Assert( false, "Shadow Army Respawn Beacon: Unsupported beacon state: " + currentBeaconState + " for beacon: " + beacon + " in ManageRespawnBeaconData_Thread" )
				#endif // DEV
				break
		}

		beacon.WaitSignal( "BeaconStateChanged" )
		wait POST_SIGNAL_DELAY
	}
}
#endif // CLIENT

#if SERVER
// Start and Stop Hologram SFX on the Server and tell the Client to start or stop beacon hologram vfx through a server callback
void function ManageBeaconHologramFX( entity beacon, bool isStartingFX )
{
	if ( !IsValid( beacon ) )
		return

	if ( isStartingFX )
	{
		// Trigger one off SFX when the beacon becomes available
		EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_AVAILABLE_SFX )
		// Trigger looping Hologram VFX
		EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_HOLOGRAM_SFX )
	}
	else
	{
		StopSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_HOLOGRAM_SFX )
	}
	
	array < entity > allPlayerArray = GetPlayerArray()
	foreach ( player in allPlayerArray )
	{
		if ( IsValid( player ) )
			Remote_CallFunction_Replay( player, "ShadowArmy_RespawnBeacon_ServerCallback_ManageHoloFX", beacon, isStartingFX )
	}
}
#endif // SERVER

#if CLIENT
// Server Callback to either start or stop hologram VFX on a beacon
void function ShadowArmy_RespawnBeacon_ServerCallback_ManageHoloFX( entity beacon, bool isStartingFX )
{
	if ( !IsValid( beacon ) )
		return

	if ( isStartingFX )
		PlayBeaconHologramVFX( beacon )
	else
		StopBeaconHologramVFX( beacon )
}
#endif // CLIENT

#if CLIENT
// Will trigger the hologram vfx thread if the beacon is in the appropriate state
void function PlayBeaconHologramVFX( entity beacon )
{
	int currentBeaconState = GetBeaconState( beacon )
	if ( currentBeaconState == eShadowArmyRespawnBeaconState.IDLE || currentBeaconState == eShadowArmyRespawnBeaconState.IN_USE )
		thread ManageRespawnBeaconHologramVFX_Thread( beacon )
}
#endif // CLIENT

#if CLIENT
// Stop the hologram VFX on a beacon
void function StopBeaconHologramVFX( entity beacon )
{
	beacon.Signal( "StopHologramFX" )
}
#endif // CLIENT

#if CLIENT
const float VFX_OFFSET = 100.0
const float RESPAWN_BEACON_HOLO_EFFECT_HEIGHT = 75.0
// Play Beacon Hologram VFX but turn them off if the beacon is enters a cooldown or disabled state
void function ManageRespawnBeaconHologramVFX_Thread( entity beacon )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsValid( beacon ) )
		return

	beacon.Signal( "StopHologramFX" ) // Just in case there is already a thread running for this beacon, kill it
	EndSignal( beacon, "OnDestroy", "StopHologramFX" )

	vector beaconAngles = beacon.GetAngles()
	vector fwd    = AnglesToForward( beaconAngles )
	vector up     = AnglesToUp( beaconAngles )
	vector rgt    = AnglesToRight( beaconAngles )
	vector offset = up * VFX_OFFSET
	vector angles = AnglesCompose( beaconAngles, <0, 0, -10> )

	entity fxHolder = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", beacon.GetOrigin() + up * RESPAWN_BEACON_HOLO_EFFECT_HEIGHT, <-90, 0, 0> )
	array<int> fx
	fx.append( StartParticleEffectOnEntity( fxHolder, GetParticleSystemIndex( RESPAWN_BEACON_EMITTER_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID ) )

	OnThreadEnd(
		function() : ( fx, fxHolder )
		{
			foreach ( effect in fx )
			{
				EffectStop( effect, false, true )
			}
			fxHolder.Destroy()
		}
	)

	WaitForever()
}
#endif // CLIENT

#if CLIENT
// Return the string that should display for the interaction prompt
string function RespawnBeacon_TextOverride( entity beacon )
{
	entity localPlayer = GetLocalClientPlayer()
	string hintString = ""

	if ( !IsValid( localPlayer ) || !IsValid( beacon ) )
		return hintString

	bool isRevPlayer = ShadowArmy_IsPlayerOnShadowArmy( localPlayer )
	int currentBeaconState = GetBeaconState( beacon )

	switch( currentBeaconState )
	{
		case eShadowArmyRespawnBeaconState.INVALID:
			break
		case eShadowArmyRespawnBeaconState.IDLE:
			if ( isRevPlayer )
				hintString = "#SHADOW_ARMY_RESPAWNBEACON_REV_USE"
			else if ( !GetAreAnyLegendsWaitingToRespawn() )
				hintString = "#SHADOW_ARMY_RESPAWNBEACON_NO_RESPAWNS"
			else
				hintString = "#SHADOW_ARMY_RESPAWNBEACON_IDLE_USE"
			break
		case eShadowArmyRespawnBeaconState.IN_USE:
			break
		case eShadowArmyRespawnBeaconState.COOLDOWN:
			hintString = Localize( "#SHADOW_ARMY_RESPAWNBEACON_COOLDOWN", int( GetRemainingCooldownDurationOnBeacon( beacon ) ) )
			break
		case eShadowArmyRespawnBeaconState.DISABLED_RING:
			hintString = "#SHADOW_ARMY_RESPAWNBEACON_DISABLED"
			break
		case eShadowArmyRespawnBeaconState.TEMP_DISABLED:
			hintString = "#SHADOW_ARMY_RESPAWNBEACON_DISABLED_TEMP"
			break
		default:
			#if DEV
				Assert( false, "Shadow Army Respawn Beacon: Unsupported beacon state: " + currentBeaconState + " for beacon: " + beacon + " in RespawnBeacon_TextOverride" )
			#endif // DEV
			break
	}

	return hintString
}

#endif // CLIENT

#if CLIENT
// Return the string that should display while the interaction is in progress
string function GetUseInProgressHint( entity beacon )
{
	entity localPlayer = GetLocalClientPlayer()
	string hintString = ""

	if ( !IsValid( localPlayer ) || !IsValid( beacon ) )
		return hintString

	if ( ShadowArmy_IsPlayerOnShadowArmy( localPlayer ) )
		return hintString

	// Client can be slow to get the IN_USE state, so use the same message if the state is still IDLE ( really the only way you should be able to use the beacon anyways )
	if ( GetBeaconState( beacon ) == eShadowArmyRespawnBeaconState.IN_USE || GetBeaconState( beacon ) == eShadowArmyRespawnBeaconState.IDLE )
	{
		// Give a faster interact time for Support Class Legends so show a different string
		if ( Perks_GetRoleForPlayer( localPlayer ) == eCharacterClassRole.SUPPORT )
			hintString = "#SHADOW_ARMY_RESPAWNBEACON_USING_SUPPORT"
		else
			hintString = "#SHADOW_ARMY_RESPAWNBEACON_USING"
	}

	return hintString
}
#endif // CLIENT

#if CLIENT
void function DisplayRuiForRespawnBeacon( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	float startTime = settings.serverStartTime > 0.0 ? settings.serverStartTime : Time()
	float endTime = startTime + settings.duration
	DisplayRuiForRespawnBeacon_Internal( rui, settings.icon, startTime, endTime, settings.hint )
}
#endif // CLIENT

#if CLIENT
void function DisplayRuiForRespawnBeacon_Internal( var rui, asset icon, float startTime, float endTime, string hint )
{
	RuiSetBool( rui, "isVisible", true )
	RuiSetImage( rui, "icon", icon )
	RuiSetGameTime( rui, "startTime", startTime )
	RuiSetGameTime( rui, "endTime", endTime )
	RuiSetString( rui, "hintKeyboardMouse", hint )
	RuiSetString( rui, "hintController", hint )
}
#endif // CLIENT

#if SERVER
// Play VFX when the beacon is used ( to spawn in Legends or sabotaged by revs )
void function PlayRespawnSuccessEffectsOnBeacon_Thread( entity beacon )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsValid(beacon) )
		return

	// Play Success SFX
	EmitSoundOnEntity( beacon, SHADOWARMY_RESPAWNBEACON_USE_COMPLETED )

	// Get the attachment for VFX, if we can't, don't play VFX
	int attachmentID = beacon.LookupAttachment( "FX_EMITTER" )
	if ( attachmentID == 0 )
		return

	// Trigger success vfx/sfx
	entity successVFX = StartParticleEffectOnEntity_ReturnEntity( beacon, GetParticleSystemIndex( BEACON_BEAM_SUCCESS_VFX ), FX_PATTACH_POINT, attachmentID )

	OnThreadEnd(
		function() : ( successVFX )
		{
			if ( IsValid( successVFX ) )
				successVFX.Destroy()
		}
	)

	wait BEAM_SUCCESS_VFX_DURATION
}
#endif // SERVER

#if SERVER
void function DisplayRespawnBeaconHintForAllPlayers( int hintIndex )
{
	if ( hintIndex >= 0 && hintIndex < eShadowArmyRespawnBeaconHintIndex._count )
	{
		array < entity > allPlayersArray = GetPlayerArray()
		foreach ( player in allPlayersArray )
		{
			if ( IsValid( player ) )
				Remote_CallFunction_NonReplay( player, "ShadowArmy_RespawnBeacon_ServerCallback_ShowBeaconHint", hintIndex )
		}
	}
}
#endif // SERVER

#if SERVER
// Display a hint for all the players in an alliance
void function DisplayRespawnBeaconHintForAllPlayersInAlliance( int hintIndex, int alliance, bool showForLivingPlayersOnly, int teamToIgnore = TEAM_INVALID )
{
	if ( hintIndex >= 0 && hintIndex < eShadowArmyRespawnBeaconHintIndex._count )
	{
		array < entity > alliancePlayersArray = AllianceProximity_GetAllPlayersInAlliance( alliance, showForLivingPlayersOnly )
		foreach ( player in alliancePlayersArray )
		{
			if ( IsValid( player ) )
			{
				int playerTeam = player.GetTeam()

				if ( teamToIgnore == TEAM_INVALID || playerTeam != teamToIgnore )
					Remote_CallFunction_NonReplay( player, "ShadowArmy_RespawnBeacon_ServerCallback_ShowBeaconHint", hintIndex )
			}
		}
	}
}
#endif // SERVER

#if CLIENT
const float HINT_DISPLAY_TIME = 5.0
const float HINT_FADE_TIME = 1.0
void function ShadowArmy_RespawnBeacon_ServerCallback_ShowBeaconHint( int hintIndex )
{
	string hintText = ""

	switch( hintIndex )
	{
		case eShadowArmyRespawnBeaconHintIndex.RESPAWN_BEACON_SPAWN_LEGENDS_HINT:
			hintText = Localize( "#SHADOW_ARMY_RESPAWNBEACON_SPAWN_HINT", ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount() )
			break
		case eShadowArmyRespawnBeaconHintIndex.RESPAWN_BEACON_INUSE:
			hintText = "#SHADOW_ARMY_RESPAWNBEACON_USE_HINT"
			break
		default:
			#if DEV
				Assert( false, "Shadow Army Respawn Beacon: Unhandled hintIndex: " + hintIndex )
			#endif // DEV
			break
	}

	AddPlayerHint( HINT_DISPLAY_TIME, HINT_FADE_TIME, $"", hintText )
}
#endif

#if CLIENT
// Update the map feature shown on the map to display a count of players to respawn or show the beacons as unavailable if there are no players to respawn
const int MAP_FEATURE_PRIORITY = 1100
void function ShadowArmy_RespawnBeacon_UpdateBeaconMapFeature()
{
	int numLegendsWaitingToRespawn = ShadowArmy_RespawnBeacon_GetLegendsWaitingToRespawnCount()
	RemoveMapFeatureItemByName( "#RESPAWN_BEACON" )

	if ( numLegendsWaitingToRespawn > 0 )
		SetMapFeatureItem( MAP_FEATURE_PRIORITY, "#RESPAWN_BEACON", Localize( "#SHADOW_ARMY_RESPAWN_BEACON_DESC_AVAIL", string( numLegendsWaitingToRespawn ) ), RESPAWN_BEACON_ICON )
	else
		SetMapFeatureItem( MAP_FEATURE_PRIORITY, "#RESPAWN_BEACON", "#SHADOW_ARMY_RESPAWN_BEACON_DESC_NOT_AVAIL", RESPAWN_BEACON_ICON )
}
#endif

#if SERVER
// Trigger logic to display a hint to use the respawn beacon on a delay so we are able to verify that the team the player is on, didn't get eliminated
const float PING_DELAY = 1.0
void function ShadowArmy_RespawnBeacon_PingRespawnBeaconOnDelay_Thread( int victimTeam, bool isAlliancePing )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	OnThreadEnd(
		function() : ( victimTeam, isAlliancePing )
		{
			// Only trigger pings if the squad didn't end up getting eliminated
			if ( !SpawnGroupSkydive_IsSquadEliminated( victimTeam ) && GetAreAnyLegendsWaitingToRespawn() && !GamemodeUtility_IsWinnerBeingDetermined() )
			{
				int alliance = AllianceProximity_GetAllianceFromTeam( victimTeam )
				// These should only trigger for the Legend Alliance
				if ( alliance == SHADOWARMY_LEGEND_ALLIANCE )
				{
					if ( isAlliancePing )
						ShadowArmy_RespawnBeacon_PingRespawnBeaconForAlliance( alliance, victimTeam )
					else
						ShadowArmy_RespawnBeacon_PingRespawnBeaconForSquad( victimTeam, true )
				}
			}
		}
	)

	wait PING_DELAY
}
#endif //SERVER

#if SERVER
// Ping Respawn Beacon for everyone in the alliance
void function ShadowArmy_RespawnBeacon_PingRespawnBeaconForAlliance( int alliance, int victimTeam )
{
	array < int > teamsInAlliance =  AllianceProximity_GetPopulatedTeamsInAlliance( alliance )
	foreach ( team in teamsInAlliance )
	{
		ShadowArmy_RespawnBeacon_PingRespawnBeaconForSquad( team, false )
	}

	DisplayRespawnBeaconHintForAllPlayersInAlliance( eShadowArmyRespawnBeaconHintIndex.RESPAWN_BEACON_SPAWN_LEGENDS_HINT, SHADOWARMY_LEGEND_ALLIANCE, true, victimTeam )
}
#endif //SERVER

#if SERVER
// Ping Respawn Beacon for squad
void function ShadowArmy_RespawnBeacon_PingRespawnBeaconForSquad( int team, bool shouldDisplaySquadRespawnHint )
{
	bool didPing = false
	array < entity > teamPlayersArray = GetPlayerArrayOfTeam( team )
	foreach ( teamPlayer in teamPlayersArray )
	{
		if ( IsValid( teamPlayer ) && IsAlive( teamPlayer ) )
		{
			if ( shouldDisplaySquadRespawnHint )
				Remote_CallFunction_Replay( teamPlayer, "ServerCallback_RespawnDNAHint" )

			// Ping the nearest respawn beacon, but only once
			if ( !didPing )
			{
				PingNearestRespawnBeacon( teamPlayer, teamPlayer.GetOrigin() )
				didPing = true
			}
		}
	}
}
#endif //SERVER

#if SERVER
// Play announcer commentary when a player starts using a beacon, if there has been a min amount of time since the last announcement related to this action
const float INUSE_COMMENTARY_COOLDOWN_TIME = 60.0
void function TryPlayingBeaconInUseAnnouncerCommentary()
{
	bool isPastCooldownTime = file.timeOfLastUseCommentary < 0 || Time() > file.timeOfLastUseCommentary + INUSE_COMMENTARY_COOLDOWN_TIME
	if ( isPastCooldownTime )
	{
		PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SHADOW_ARMY_BEACON_USING ) )
		file.timeOfLastUseCommentary = Time()
	}
}
#endif // SERVER




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEBUGGING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




#if DEV && SERVER
// Trigger a respawning of all Legends waiting to spawn
void function ShadowArmy_RespawnLegendsFromRespawnBeacon_Dev()
{
	printt( "Shadow Army: Running Debug Command ShadowArmy_RespawnLegendsFromRespawnBeacon_Dev" )

	ShadowArmy_RespawnBeacon_SpawnPlayers( GP() )
}
#endif // DEV && SERVER

#if DEV && SERVER
// Trigger beam VFX on all the Beacons and then kill them after a time
void function ShadowArmy_TriggerRespawnBeaconBeamVFX_Dev( bool shouldPlaySuccessVFXAtEnd = true )
{
	thread ShadowArmy_ManageBeamVFX_Thread_Dev( shouldPlaySuccessVFXAtEnd )
}
#endif // DEV && SERVER

#if DEV && SERVER
// Manage the debug beam VFX
void function ShadowArmy_ManageBeamVFX_Thread_Dev( bool shouldPlaySuccessVFXAtEnd )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( shouldPlaySuccessVFXAtEnd )
		printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerRespawnBeaconBeamVFX, going to trigger Success VFX at the end as if the beacon would respawn players" )
	else
		printt( "Shadow Army: Running Debug Command ShadowArmy_TriggerRespawnBeaconBeamVFX, not going to trigger Success VFX at the end as if the beacon interaction was abandoned" )

	array < entity > beamVFXArray

	OnThreadEnd(
		function() : ( beamVFXArray )
		{
			// If there are any VFX, kill them
			foreach ( vfx in beamVFXArray )
			{
				if ( IsValid( vfx ) )
					vfx.Destroy()
			}
		}
	)

	// Show a beam
	foreach ( beacon in file.respawnBeacons )
	{
		if ( IsValid( beacon ) )
		{
			int attachmentID = beacon.LookupAttachment( "FX_EMITTER" )
			if ( attachmentID != 0 )
				beamVFXArray.append( StartParticleEffectOnEntity_ReturnEntity( beacon, GetParticleSystemIndex( BEACON_BEAM_VFX ), FX_PATTACH_POINT, attachmentID ) )

			// Trigger hologram VFX for testing ( they would be enabled in any state where you could trigger the beam VFX )
			ManageBeaconHologramFX( beacon, true )
		}
	}

	// Only wait half the time if the beam is meant to be interupted
	if ( shouldPlaySuccessVFXAtEnd )
		wait BEACON_INTERACT_TIME
	else
		wait BEACON_INTERACT_TIME * 0.5


	// Kill the beam vfx
	foreach ( vfx in beamVFXArray )
	{
		if ( IsValid( vfx ) )
			vfx.Destroy()
	}

	// Turn off hologram VFX for testing ( they would be disabled in any state where the beam VFX finished playing )
	foreach ( beacon in file.respawnBeacons )
	{
		if ( IsValid( beacon ) )
			ManageBeaconHologramFX( beacon, false )
	}

	// If we are playing success VFX, trigger them now and wait for them to play out
	if ( shouldPlaySuccessVFXAtEnd )
	{
		foreach ( beacon in file.respawnBeacons )
		{
			if ( IsValid( beacon ) )
			{
				int attachmentID = beacon.LookupAttachment( "FX_EMITTER" )
				if ( attachmentID != 0 )
					beamVFXArray.append( StartParticleEffectOnEntity_ReturnEntity( beacon, GetParticleSystemIndex( BEACON_BEAM_SUCCESS_VFX ), FX_PATTACH_POINT, attachmentID ) )
			}
		}

		wait BEAM_SUCCESS_VFX_DURATION
	}
}
#endif // DEV && SERVER

                  
          
                                                      
                                                                                                                                
 
                                                                             
  
                                                                                                                                                            
                                                                  
   
                                                                                    
   
        
  
     
  
                                                                                                                                                                                                                       
  

                                                               

                                 
                                          
  
                          
   
                                     
                                 
                                

                                                       
                                       

                        
    
                                               
          
                                            
                             
          
                                              
          
                                                
                                   
                            
                                                                          
          
                                                     
                             
          
                                                     
                             
          
            
          
    

                                
    
                                                                                 
                                                        

                                                                                                                   
     
                                                                                

                                                          
                                                                          
                                         
      
                              
                                                                                                                   
      
     
        
     
                                                                                                                                                                  
             
     
    

                                                                               
                                               
    
                                             
                                                      
    
   
  
 
                
                        
                                   