global function Arenas_ServerGamemode_Init

// GAME LOOP:
//   WaitingForPlayers -> Prematch -> [BuyPhase -> CombatPhase -> RoundEnd] x N -> MatchEnd
//   - Buy phase: Players confined by start zone walls, buy menu open (Prematch game state)
//   - Combat phase: Walls toggled off, canisters spawned, elimination polling (Playing game state)
//   - First to ARENAS_ROUNDS_TO_WIN wins (win-by-2 at high scores, sudden death after max ties)
//
// MAP ENTITIES (via AddSpawnCallbackEditorClass):
//   info_arenas_spawn_location (2)         - Team spawn origins, players spread in triangle formation
//   func_brush_arenas_start_zone (9)       - Spawn room walls, toggled solid/invisible between phases
//   info_arenas_materials_canister (3)      - Positions where prop_script canisters are spawned each round
//   info_arenas_airdrop_location (2)        - Care package drop points
//   info_arenas_circle_end_location (2)     - Ring/deathfield closure endpoints
//   info_arenas_defensive_end_location (2)  - Defensive positions with script_radius
//   info_arenas_intro_camera (4)            - Cinematic intro camera positions
//   info_arenas_map_location (1)            - Master config: map name, radius, deathfield stages
//   info_arenas_med_lootbin_location (2)    - Loot bin placement positions
//
// ECONOMY:
//   - Base materials per round from Arenas_GetCashAmountForRound() (escalating per round)
//   - Kill bonus: ARENAS_KILL_REWARD awarded in real-time, carried over via materialsCarryover
//   - Canister bonus: ARENAS_CANISTER_REWARD on use, configurable via playlist var
//   - Client buy menu sends "Arenas_Select <idx> <cost> <ref>" via ClientCommand
//   - Server validates, deducts, syncs arenas_current_cash netvar -> client UI refresh
//
// DEPENDENCIES:
//   - sh_gamemode_arenas.nut: Networking registration, client callbacks, Arenas_GetCashAmountForRound()
//   - sh_arenas_buy_system.nut: Economy constants, client buy menu UI, store data
//   - sh_cash_station.gnut: Model precache, client canister UI (ServerToClient_OnUseCashStationSmall)
// ============================================================================

// Economy constants defined in sh_arenas_buy_system.nut (shared):
// ARENAS_MAX_CASH, ARENAS_KILL_REWARD, ARENAS_CANISTER_REWARD, ARENAS_ROUND_PER_LOSE_CASH

// Dev mode: skip buy phase, give default loadout, jump straight to combat
const bool ARENAS_DEV_MODE = false

// Timing constants
const float ARENAS_BUY_PHASE_DURATION = 30.0
const float ARENAS_ROUND_END_DELAY = 3.0
const float ARENAS_ROUND_RESTART_DELAY = 2.0
const float ARENAS_MATCH_END_DELAY = 8.0
const float ARENAS_PREMATCH_DELAY = 3.0
const float ARENAS_RING_CLOSURE_DELAY = 90.0

// Post-round summary duration (fade-to-black, score animation, Ash effects).
// Client calculates summary window as: gameStartTime - shopDuration.
// Must match sh_gamemode_arenas.nut ROUND_SUMMARY_DURATION (intro 2.5 + outro 1.5 = 4.0)
// plus margin for fade-from-black (0.35) and audio cues.
const float ARENAS_POST_ROUND_SUMMARY_DURATION = 5.0

// Win condition constants
const int ARENAS_ROUNDS_TO_WIN = 3
const int ARENAS_MAX_TIES = 2

// Game phase enum
global enum eArenaPhase
{
	PREMATCH,
	BUY_PHASE,
	COMBAT,
	ROUND_END,
	MATCH_END
}

struct ArenasSelectedItem
{
	string ref = ""
	int cost = 0
}

struct ArenaPlayerData
{
	int materials = 0
	int materialsCarryover = 0
	int killsThisRound = 0
	int killsThisMatch = 0
	int killsLastRound = 0
	int damageThisRound = 0
	int canistersThisRound = 0
	int canistersThisMatch = 0
	int canistersLastRound = 0
	array<ArenasSelectedItem> selectedItems
	string selectedOptic = ""
	bool hasConfirmedLoadout = false
	bool isEliminated = false
}

// Spawn offset pattern for spreading players around a single spawn location
// 3v3 triangle formation: center, left, right
const array<vector> ARENAS_SPAWN_OFFSETS = [
	<0, 0, 0>,
	<-100, -80, 0>,
	<100, -80, 0>
]

struct
{
	int currentPhase = eArenaPhase.PREMATCH
	int roundNumber = 0
	int leftTeam = TEAM_IMC
	int rightTeam = TEAM_MILITIA
	int leftTeamScore = 0
	int rightTeamScore = 0
	int numTies = 0
	int lastWonTeam = 0
	bool matchOver = false

	table<entity, ArenaPlayerData> playerData

	// Map entities collected via AddSpawnCallbackEditorClass
	array<entity> spawnLocations              // info_arenas_spawn_location (2 per map, one per team)
	array<entity> startZoneBrushes            // func_brush_arenas_start_zone (spawn room walls)
	array<entity> canisterInfoEnts            // info_arenas_materials_canister (canister position markers)
	array<entity> airdropLocations            // info_arenas_airdrop_location (care package drop points)
	array<entity> circleEndLocations          // info_arenas_circle_end_location (ring closure endpoints)
	array<entity> defensiveEndLocations       // info_arenas_defensive_end_location
	array<entity> introCameras                // info_arenas_intro_camera
	array<entity> medLootbinLocations         // info_arenas_med_lootbin_location
	entity        mapLocationEnt = null       // info_arenas_map_location (master config, one per map)

	// Spawned canister props (created from canisterInfoEnts positions)
	array<entity> activeCanisters

	// Spawned loot bins (created from medLootbinLocations)
	array<entity> activeLootBins

	// Legacy spawn arrays (populated from spawnLocations)
	array<entity> leftSpawns
	array<entity> rightSpawns

	float buyPhaseEndTime = 0.0
	bool mainLoopStarted = false
	bool teamsAssigned = false
	bool deathfieldOverridesSet = false
	bool forceNextRound = false
	bool firstBloodThisRound = false

	// Map config extracted from info_arenas_map_location
	string mapName = ""
	float mapRadius = 6000.0
	array<float> deathfieldStagesRadius
} file

// ============================================================================
// INITIALIZATION
// ============================================================================
void function Arenas_ServerGamemode_Init()
{
	printt( "[Arenas] ServerGamemode_Init called" )

	AddCallback_OnClientConnected( Arenas_OnClientConnected )
	AddCallback_OnClientDisconnected( Arenas_OnClientDisconnected )
	AddCallback_OnPlayerKilled( Arenas_OnPlayerKilled )
	AddDamageCallback( "player", Arenas_OnPlayerDamaged )
	AddCallback_EntitiesDidLoad( Arenas_EntitiesDidLoad )
	// Onboarding system handles WaitingForPlayers -> PickLoadout -> Prematch -> Playing
	// Assign teams early so character select draft and UI work correctly.
	// PickLoadout may be skipped if char select is disabled, so also hook Prematch as fallback.
	AddCallback_GameStateEnter( eGameState.PickLoadout, Arenas_OnPickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, Arenas_OnPrematch )
	AddCallback_GameStateEnter( eGameState.Playing, Arenas_OnGameStatePlaying )

	// Buy system client commands
	AddClientCommandCallback( "Arenas_Select", ClientCommand_Arenas_Select )
	AddClientCommandCallback( "Arenas_Unselect", ClientCommand_Arenas_Unselect )
	AddClientCommandCallback( "Arenas_SetOptic", ClientCommand_Arenas_SetOptic )
	AddClientCommandCallback( "Arenas_ChangeWeaponTab", ClientCommand_Arenas_ChangeWeaponTab )
	AddClientCommandCallback( "Arenas_OnBuyMenuOpen", ClientCommand_Arenas_OnBuyMenuOpen )
	AddClientCommandCallback( "Arenas_OnBuyMenuClose", ClientCommand_Arenas_OnBuyMenuClose )
	AddClientCommandCallback( "next_round", ClientCommand_Arenas_ForceNextRound )

	// Register editorclass spawn callbacks for all arenas entity types
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_spawn_location", Arenas_OnSpawnLocationCreated )
	AddSpawnCallbackEditorClass( "func_brush", "func_brush_arenas_start_zone", Arenas_OnStartZoneBrushCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_materials_canister", Arenas_OnCanisterInfoCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_airdrop_location", Arenas_OnAirdropLocationCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_circle_end_location", Arenas_OnCircleEndLocationCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_defensive_end_location", Arenas_OnDefensiveEndLocationCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_intro_camera", Arenas_OnIntroCameraCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_map_location", Arenas_OnMapLocationCreated )
	AddSpawnCallbackEditorClass( "script_ref", "info_arenas_med_lootbin_location", Arenas_OnMedLootbinLocationCreated )

	SetRoundBased( true )

	// Equipment netvars are set in EntitiesDidLoad (SetGlobalNetIntSafe requires entity system)

	printt( "[Arenas] ServerGamemode_Init complete" )
}

void function Arenas_EntitiesDidLoad()
{
	printt( "[Arenas] EntitiesDidLoad - gathering spawn points" )
	Arenas_GatherSpawnPoints()

	// Set equipment netvars here - loot datatables loaded (sh_init.gnut:185) and
	// entity system is up so SetGlobalNetIntSafe works
	Arenas_SetEquipmentNetvars()
}

// WaitingForPlayers -> PickLoadout -> Prematch -> Playing is handled by
// the standard gamestate system.
// Team assignment uses GiveInitialTeamToPlayer which respects max_team_size
// and max_players playlist vars (TEAM_IMC and TEAM_MILITIA for 2-team arenas).

void function Arenas_OnPickLoadout()
{
	// Assign teams before character select begins. GiveInitialTeamToPlayer fills
	// teams sequentially up to max_team_size, which puts all players on TEAM_IMC
	// when player count < max_team_size. Rebalance to alternate teams here.
	if ( !file.teamsAssigned )
	{
		file.teamsAssigned = true
		Arenas_AssignTeams()
		printt( "[Arenas] PickLoadout - teams assigned. IMC:", GetPlayerArrayOfTeam( file.leftTeam ).len(),
			"MILITIA:", GetPlayerArrayOfTeam( file.rightTeam ).len() )
	}
}

void function Arenas_OnPrematch()
{
	// Assign teams on first Prematch (from onboarding). Subsequent Prematch
	// transitions (from BuyPhase each round) skip this.
	if ( !file.teamsAssigned )
	{
		file.teamsAssigned = true
		Arenas_AssignTeams()
		printt( "[Arenas] Prematch - teams assigned (charselect skipped). IMC:", GetPlayerArrayOfTeam( file.leftTeam ).len(),
			"MILITIA:", GetPlayerArrayOfTeam( file.rightTeam ).len() )
	}

	// Set up deathfield circle overrides once from map entities
	if ( !file.deathfieldOverridesSet )
	{
		file.deathfieldOverridesSet = true

		foreach ( entity endLoc in file.circleEndLocations )
		{
			if ( IsValid( endLoc ) )
				SURVIVAL_AddOverrideCircleLocation( endLoc.GetOrigin(), 250.0 )
		}

		SURVIVAL_SetDeathFieldOverrideStartRadius( file.mapRadius )

		if ( file.deathfieldStagesRadius.len() > 0 )
			SURVIVAL_SetDeathFieldStagesOverrideRadius( file.deathfieldStagesRadius )

		// Reinitialize deathfield data now that overrides are set
		RoundBased_ResetDeathfield()

		printt( "[Arenas] Deathfield overrides set. Locations:",
			file.circleEndLocations.len(), "radius:", file.mapRadius )
	}

	// Start the main game loop on first Prematch from onboarding.
	// Onboarding stops at Prematch for arenas; we take over from here.
	if ( !file.mainLoopStarted )
	{
		file.mainLoopStarted = true
		printt( "[Arenas] Prematch -> starting main game loop" )
		thread Arenas_MainGameLoop()
	}
}

void function Arenas_OnGameStatePlaying()
{
	// Game loop is started from Arenas_OnPrematch. This callback exists
	// as a safety guard only.
	if ( file.mainLoopStarted )
		return

	file.mainLoopStarted = true
	printt( "[Arenas] GameState -> Playing, starting main game loop (fallback)" )
	thread Arenas_MainGameLoop()
}

// ============================================================================
// EDITORCLASS ENTITY SPAWN CALLBACKS
// ============================================================================
void function Arenas_OnSpawnLocationCreated( entity ent )
{
	file.spawnLocations.append( ent )
	printt( "[Arenas] Spawn location registered at", ent.GetOrigin() )
}

void function Arenas_OnStartZoneBrushCreated( entity ent )
{
	if ( GetEditorClass( ent ) != "func_brush_arenas_start_zone" )
		return

	file.startZoneBrushes.append( ent )
	// Start zone brushes spawn already solid from the BSP, keep them that way
	printt( "[Arenas] Start zone brush registered at", ent.GetOrigin() )
}

void function Arenas_OnCanisterInfoCreated( entity ent )
{
	file.canisterInfoEnts.append( ent )
	printt( "[Arenas] Canister info entity registered at", ent.GetOrigin() )
}

void function Arenas_OnAirdropLocationCreated( entity ent )
{
	file.airdropLocations.append( ent )
	printt( "[Arenas] Airdrop location registered at", ent.GetOrigin() )
}

void function Arenas_OnCircleEndLocationCreated( entity ent )
{
	file.circleEndLocations.append( ent )
	printt( "[Arenas] Circle end location registered at", ent.GetOrigin() )
}

void function Arenas_OnDefensiveEndLocationCreated( entity ent )
{
	file.defensiveEndLocations.append( ent )
	printt( "[Arenas] Defensive end location registered at", ent.GetOrigin() )
}

void function Arenas_OnIntroCameraCreated( entity ent )
{
	file.introCameras.append( ent )
	printt( "[Arenas] Intro camera registered at", ent.GetOrigin() )
}

void function Arenas_OnMapLocationCreated( entity ent )
{
	file.mapLocationEnt = ent

	// Extract map configuration from KV pairs
	if ( ent.HasKey( "script_noteworthy" ) )
		file.mapName = ent.GetValueForKey( "script_noteworthy" )

	if ( ent.HasKey( "script_radius" ) )
		file.mapRadius = ent.GetValueForKey( "script_radius" ).tofloat()

	if ( ent.HasKey( "deathfield_stages_radius" ) )
	{
		string radiusStr = ent.GetValueForKey( "deathfield_stages_radius" )
		array<string> parts = split( radiusStr, " " )
		file.deathfieldStagesRadius.clear()
		foreach ( string part in parts )
			file.deathfieldStagesRadius.append( part.tofloat() )
	}

	printt( "[Arenas] Map location registered:", file.mapName, "radius:", file.mapRadius, "deathfield stages:", file.deathfieldStagesRadius.len() )
}

void function Arenas_OnMedLootbinLocationCreated( entity ent )
{
	file.medLootbinLocations.append( ent )
	printt( "[Arenas] Med lootbin location registered at", ent.GetOrigin() )
}

// ============================================================================
// SPAWN POINT SETUP (from editorclass entities)
// ============================================================================
void function Arenas_GatherSpawnPoints()
{
	// Spawn locations are collected via AddSpawnCallbackEditorClass callbacks
	// by the time EntitiesDidLoad fires. Assign them to teams.
	if ( file.spawnLocations.len() >= 2 )
	{
		// Two spawn locations: first = left team, second = right team
		file.leftSpawns.clear()
		file.rightSpawns.clear()
		file.leftSpawns.append( file.spawnLocations[0] )
		file.rightSpawns.append( file.spawnLocations[1] )
	}
	else if ( file.spawnLocations.len() == 1 )
	{
		// Only one spawn location found, use it for both teams
		file.leftSpawns.append( file.spawnLocations[0] )
		file.rightSpawns.append( file.spawnLocations[0] )
		Warning( "[Arenas] Only 1 spawn location found, using for both teams" )
	}
	else
	{
		// No editorclass spawn locations found, fall back to info_player_start
		Warning( "[Arenas] No info_arenas_spawn_location entities found, using generic spawns" )
		array<entity> genericSpawns = GetEntArrayByClass_Expensive( "info_player_start" )
		if ( genericSpawns.len() >= 2 )
		{
			file.leftSpawns.append( genericSpawns[0] )
			file.rightSpawns.append( genericSpawns[1] )
		}
		else if ( genericSpawns.len() >= 1 )
		{
			file.leftSpawns = clone genericSpawns
			file.rightSpawns = clone genericSpawns
		}
	}

	printt( "[Arenas] Spawn setup complete - Left:", file.leftSpawns.len(), "Right:", file.rightSpawns.len(),
		"Walls:", file.startZoneBrushes.len(), "Canisters:", file.canisterInfoEnts.len(),
		"Airdrops:", file.airdropLocations.len(), "CircleEnds:", file.circleEndLocations.len() )
}

// ============================================================================
// PLAYER CONNECTION CALLBACKS
// ============================================================================
void function Arenas_OnClientConnected( entity player )
{
	ArenaPlayerData data
	data.materials = Arenas_GetCashAmountForRound( file.roundNumber )
	file.playerData[player] <- data

	// Sync initial cash to client
	player.SetPlayerNetInt( "arenas_current_cash", data.materials )

	// If joining mid-match during buy phase, open buy menu
	if ( file.currentPhase == eArenaPhase.BUY_PHASE )
	{
		thread Arenas_LateJoinBuyPhase( player )
	}
}

void function Arenas_OnClientDisconnected( entity player )
{
	if ( player in file.playerData )
		delete file.playerData[player]

	// Check if a team was eliminated by this disconnect
	if ( file.currentPhase == eArenaPhase.COMBAT )
	{
		thread Arenas_CheckTeamEliminated()
	}
}

void function Arenas_LateJoinBuyPhase( entity player )
{
	wait 1.0
	if ( !IsValid( player ) )
		return
	if ( file.currentPhase != eArenaPhase.BUY_PHASE )
		return

	int leftTeam = file.leftTeam
	int rightTeam = file.rightTeam
	int savedCash = 0
	int kills = 0
	int canisters = 0

	Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayArenasPrematch", leftTeam, rightTeam, savedCash, kills, canisters )
}

// ============================================================================
// ECONOMY SYSTEM
// ============================================================================
void function Arenas_AwardMaterials( entity player, int amount )
{
	if ( !( player in file.playerData ) )
		return

	ArenaPlayerData data = file.playerData[player]
	data.materials = minint( data.materials + amount, ARENAS_MAX_CASH )
	file.playerData[player] = data
}

void function Arenas_SetMaterials( entity player, int amount )
{
	if ( !( player in file.playerData ) )
		return

	ArenaPlayerData data = file.playerData[player]
	data.materials = minint( maxint( amount, 0 ), ARENAS_MAX_CASH )
	file.playerData[player] = data
}

int function Arenas_GetMaterials( entity player )
{
	if ( !( player in file.playerData ) )
		return 0

	return file.playerData[player].materials
}

bool function Arenas_DeductMaterials( entity player, int cost )
{
	if ( !( player in file.playerData ) )
		return false

	ArenaPlayerData data = file.playerData[player]
	if ( data.materials < cost )
		return false

	data.materials -= cost
	file.playerData[player] = data
	return true
}

void function Arenas_SyncCashToClient( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !( player in file.playerData ) )
		return

	player.SetPlayerNetInt( "arenas_current_cash", file.playerData[player].materials )
}

void function Arenas_SyncCashToAllClients()
{
	foreach ( entity player, ArenaPlayerData data in file.playerData )
	{
		if ( !IsValid( player ) )
			continue
		player.SetPlayerNetInt( "arenas_current_cash", data.materials )
	}
}

void function Arenas_ResetEconomyForRound()
{
	int baseMaterials = Arenas_GetCashAmountForRound( file.roundNumber )

	foreach ( entity player, ArenaPlayerData data in file.playerData )
	{
		if ( !IsValid( player ) )
			continue

		// Save previous round stats before resetting (used by prematch callback)
		data.killsLastRound = data.killsThisRound
		data.canistersLastRound = data.canistersThisRound

		// Base materials for this round + carryover from previous round
		// Kill rewards are already awarded in real-time during combat and
		// included in materialsCarryover, so no additional kill bonus here
		int totalMaterials = baseMaterials + data.materialsCarryover

		data.materials = minint( totalMaterials, ARENAS_MAX_CASH )
		data.killsThisRound = 0
		data.damageThisRound = 0
		data.canistersThisRound = 0
		data.selectedItems.clear()
		data.selectedOptic = ""
		data.hasConfirmedLoadout = false
		data.isEliminated = false
		file.playerData[player] = data

		// Sync materials to client for buy menu display
		player.SetPlayerNetInt( "arenas_current_cash", data.materials )
	}
}

// ============================================================================
// MAIN GAME LOOP
// ============================================================================
void function Arenas_MainGameLoop()
{
	// Teams were already assigned in Arenas_OnPickLoadout before character select.
	printt( "[Arenas] MainGameLoop started, players:", GetPlayerArray().len(),
		"IMC:", GetPlayerArrayOfTeam( file.leftTeam ).len(),
		"MILITIA:", GetPlayerArrayOfTeam( file.rightTeam ).len() )

	// Prematch notification
	file.currentPhase = eArenaPhase.PREMATCH
	file.roundNumber = 0
	file.leftTeamScore = 0
	file.rightTeamScore = 0
	file.numTies = 0
	file.matchOver = false

	// Update networked vars
	SetGlobalNetIntSafe( "arenas_numties", 0 )
	SetGlobalNetIntSafe( "arenas_lastWonTeam", 0 )
	SetGlobalNetIntSafe( "roundsPlayed", 0 )
	level.nv.roundsPlayed = 0
	printt( "[Arenas] Prematch setup complete, entering round loop" )

	// Main round loop
	while ( !file.matchOver )
	{
		printt( "[Arenas] === ROUND", file.roundNumber + 1, "=== Score:", file.leftTeamScore, "-", file.rightTeamScore )
		Arenas_ResetEconomyForRound()
		printt( "[Arenas] Economy reset, entering buy phase" )
		Arenas_BuyPhase()
		printt( "[Arenas] Buy phase complete, entering combat phase" )
		Arenas_CombatPhase()
		printt( "[Arenas] Combat phase complete, matchOver:", file.matchOver )

		// Wait handled inside RoundEnd
		if ( file.matchOver )
			break

		file.roundNumber++
		SetGlobalNetIntSafe( "roundsPlayed", file.roundNumber )
		level.nv.roundsPlayed = file.roundNumber
	}

	printt( "[Arenas] Match over! Final score:", file.leftTeamScore, "-", file.rightTeamScore )
	// Match end sequence
	Arenas_MatchEnd()
}

// ============================================================================
// TEAM ASSIGNMENT
// ============================================================================
void function Arenas_AssignTeams()
{
	array<entity> allPlayers = GetPlayerArray()

	// Shuffle players for random team assignment
	allPlayers.randomize()

	int halfSize = allPlayers.len() / 2

	for ( int i = 0; i < allPlayers.len(); i++ )
	{
		entity player = allPlayers[i]
		if ( i < halfSize )
			SetTeam( player, file.leftTeam )
		else
			SetTeam( player, file.rightTeam )
	}

	printt( "[Arenas] Teams assigned - IMC:", GetPlayerArrayOfTeam( file.leftTeam ).len(), "MILITIA:", GetPlayerArrayOfTeam( file.rightTeam ).len() )
}

// ============================================================================
// BUY PHASE
// ============================================================================
void function Arenas_BuyPhase()
{
	printt( "[Arenas] BuyPhase started" )
	file.currentPhase = eArenaPhase.BUY_PHASE
	SetGameState( eGameState.Prematch )
	SetGlobalNetIntSafe( "gameState", eGameState.Prematch )
	SetGlobalNetIntSafe( "roundsPlayed", file.roundNumber )
	level.nv.roundsPlayed = file.roundNumber

	// Start deathfield paused — ring visible at full size during buy phase
	FlagSet( "DeathCircleActive" )
	FlagSet( "DeathFieldPaused" )
	thread SURVIVAL_RunArenaDeathField()

	// Static ring netvars until combat activates shrinking
	SetGlobalNetIntSafe( "currentDeathFieldStage", GetDeathFieldStartStage() )
	SetGlobalNetTimeSafe( "nextCircleStartTime", Time() + 99999.0 )
	SetGlobalNetTimeSafe( "circleCloseTime", Time() + 199999.0 )

	if ( ARENAS_DEV_MODE )
	{
		Arenas_DevMode_SetupPlayers()
		Arenas_SetStartZoneWalls( false )
		return
	}

	// Enable spawn room blockers
	Arenas_SetStartZoneWalls( true )

	// Reset and teleport all players BEFORE setting the timer,
	// so processing time doesn't eat into the buy phase duration.
	array<entity> allPlayers = GetPlayerArray()
	foreach ( entity player in allPlayers )
	{
		if ( !IsValid( player ) )
			continue

		// Respawn dead players
		if ( !IsAlive( player ) )
		{
			DecideRespawnPlayer( player, false )
			wait 0.1 // Brief yield for respawn to process
			if ( !IsValid( player ) )
				continue
		}

		// Unfreeze controls (frozen during WaitingForPlayers for safe parking)
		player.UnfreezeControlsOnServer()

		// Zoom minimap in for buy phase
		player.SetMinimapZoomScale( ARENAS_PREMATCH_MINIMAP_ZOOM, 0.0 )

		// Reset player state
		Arenas_ResetPlayerForRound( player )

		// Teleport to spawn room
		Arenas_TeleportToSpawn( player )
	}

	// Brief delay for respawns to settle
	wait 0.5

	// Fade from black after teleport (round 0 has no prior fade, but harmless to call)
	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
			ScreenFadeFromBlack( player, 0.5, 0.0 )
	}

	// gameStartTime marks when combat begins. The client uses it to derive:
	//   summaryEndTime = gameStartTime - shopDuration  (post-round summary window)
	//   buyPhaseEndTime = gameStartTime                (buy menu countdown target)
	// For round 0 there is no summary, so gameStartTime = now + buyDuration.
	// For rounds > 0 we prepend the post-round summary window.
	// IMPORTANT: Set timer AFTER player processing so the full duration is available.
	float totalDuration = ARENAS_BUY_PHASE_DURATION
	if ( file.roundNumber > 0 )
		totalDuration += ARENAS_POST_ROUND_SUMMARY_DURATION

	file.buyPhaseEndTime = Time() + totalDuration
	// Set level.nv.gameStartTime directly -- this is the engine networked variable
	// that GetGameStartTime() reads on the client. SetServerVar writes to a separate
	// script-level variable table that GetGameStartTime() does NOT read.
	level.nv.gameStartTime = file.buyPhaseEndTime
	SetServerVar( "gameStartTime", file.buyPhaseEndTime )
	SetGlobalNetTimeSafe( "arenas_buyMenuStartTime", Time() )
	printt( "[Arenas] Buy phase timer set, totalDuration:", totalDuration, "gameStartTime:", file.buyPhaseEndTime )

	// Notify all clients to open buy menu
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		ArenaPlayerData data = Arenas_GetPlayerData( player )

		// Send previous round's stats to the client for the cash breakdown display:
		// savedCash = unspent materials carried from last round
		// kills = kills scored in the last round (for kill bonus line)
		// canisters = canisters collected in the last round (for canister bonus line)
		Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayArenasPrematch",
			file.leftTeam, file.rightTeam,
			data.materialsCarryover, data.killsLastRound, data.canistersLastRound )
	}

	// Wait for buy phase timer to expire or all players to confirm
	float endTime = file.buyPhaseEndTime
	while ( Time() < endTime )
	{
		if ( Arenas_AllPlayersConfirmed() )
			break
		if ( file.forceNextRound )
			break
		WaitFrame()
	}

	// Timer expired: close buy menu and open doors immediately so the RUI
	// transition and door opening happen at the same moment for players.
	SetGlobalNetTimeSafe( "arenas_buyMenuStartTime", -1.0 )
	Arenas_SetStartZoneWalls( false )

	// Items were already granted immediately on purchase via Arenas_GrantItem.
	// Just save carryover materials for next round.
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue
		if ( player in file.playerData )
		{
			ArenaPlayerData data = file.playerData[player]
			data.materialsCarryover = data.materials
			file.playerData[player] = data
		}
	}
	printt( "[Arenas] Buy phase ended, carryover saved" )
}

void function Arenas_ResetPlayerForRound( entity player )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return

	// Full health restore
	player.SetHealth( player.GetMaxHealth() )

	// Shield restore
	int maxShields = player.GetShieldHealthMax()
	player.SetShieldHealth( maxShields )

	// Strip all weapons and inventory (clean slate for new buy phase)
	TakeAllWeapons( player )
	SetPlayerInventory( player, [] )

	// Give melee back
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE, [] )
	player.GiveWeapon( "mp_weapon_melee_survival", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )

	// Abilities are NOT given for free - player must purchase them through buy menu
	// (tactical_upgrade, arenas_full_ultimate, buy_passive)

	// Give consumable slot (so heals are usable during buy phase if granted)
	player.GiveOffhandWeapon( CONSUMABLE_WEAPON_NAME, OFFHAND_SLOT_FOR_CONSUMABLES, [] )

	// Give default equipment (backpack, helmet, armor) so inventory and buy menu work during buy phase
	Survival_SetInventoryEnabled( player, true )
	Inventory_SetPlayerEquipment( player, "backpack_pickup_lv3", "backpack" )
	Inventory_SetPlayerEquipment( player, "helmet_pickup_lv3", "helmet" )
	Inventory_SetPlayerEquipment( player, "armor_pickup_lv3", "armor" )

	// Set ability netvars to base values (no abilities purchased yet)
	// passiveCharges: 0 = no tactical charges (must purchase)
	// ultimateCooldown: 1 = on cooldown/not ready (must purchase)
	player.SetPlayerNetInt( "passiveCharges", 0 )
	player.SetPlayerNetInt( "ultimateCooldown", 1 )

	// Reset elimination state (economy/selections cleared by Arenas_ResetEconomyForRound)
	if ( player in file.playerData )
	{
		ArenaPlayerData data = file.playerData[player]
		data.isEliminated = false
		file.playerData[player] = data
	}
}

void function Arenas_GiveLegendAbilities( entity player )
{
	if ( !IsValid( player ) )
		return

	// Give character's tactical and ultimate abilities
	ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
	ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( character )
	ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )

	player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL, [] )
	player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE, [] )
}

void function Arenas_DevMode_SetupPlayers()
{
	printt( "[Arenas] DEV MODE - skipping buy phase, giving default loadout" )

	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		if ( !IsAlive( player ) )
		{
			DecideRespawnPlayer( player, false )
			wait 0.1
			if ( !IsValid( player ) || !IsAlive( player ) )
				continue
		}

		player.UnfreezeControlsOnServer()
		Arenas_ResetPlayerForRound( player )
		Arenas_TeleportToSpawn( player )

		// Give wingman + full ammo
		player.GiveWeapon( "mp_weapon_wingman", WEAPON_INVENTORY_SLOT_PRIMARY_0, [] )
		entity weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		if ( IsValid( weapon ) )
		{
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
			player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		}

		// Give legend abilities
		Arenas_GiveLegendAbilities( player )

		// Give full armor and health
		player.SetHealth( player.GetMaxHealth() )
		player.SetShieldHealth( player.GetShieldHealthMax() )

		ScreenFadeFromBlack( player, 0.3, 0.0 )
	}
}

void function Arenas_TeleportToSpawn( entity player )
{
	if ( !IsValid( player ) )
		return

	int team = player.GetTeam()
	array<entity> spawns = ( team == file.leftTeam ) ? file.leftSpawns : file.rightSpawns

	if ( spawns.len() == 0 )
		return

	entity spawnEnt = spawns[0]
	vector spawnOrigin = spawnEnt.GetOrigin()
	vector spawnAngles = spawnEnt.GetAngles()

	// Spread players around the spawn location in a triangle formation
	array<entity> teammates = GetPlayerArrayOfTeam( team )
	int playerIndex = teammates.find( player )
	if ( playerIndex == -1 )
		playerIndex = 0

	// Apply offset relative to spawn facing direction
	vector offset = <0, 0, 0>
	if ( playerIndex < ARENAS_SPAWN_OFFSETS.len() )
		offset = ARENAS_SPAWN_OFFSETS[playerIndex]

	// Rotate offset by spawn facing angle
	vector forward = AnglesToForward( spawnAngles )
	vector right = AnglesToRight( spawnAngles )
	vector finalPos = spawnOrigin + ( forward * offset.y ) + ( right * offset.x )

	player.SetOrigin( finalPos )
	player.SetAngles( spawnAngles )
}

bool function Arenas_AllPlayersConfirmed()
{
	foreach ( entity player, ArenaPlayerData data in file.playerData )
	{
		if ( !IsValid( player ) )
			continue
		if ( !data.hasConfirmedLoadout )
			return false
	}
	return true
}

void function Arenas_SetStartZoneWalls( bool enabled )
{
	foreach ( entity wall in file.startZoneBrushes )
	{
		if ( !IsValid( wall ) )
			continue

		if ( enabled )
		{
			wall.Solid()
			wall.MakeVisible()
			EmitSoundOnEntity( wall, ARENAS_SPAWNROOMWALL_SOUND_EVENT_NAME )
		}
		else
		{
			StopSoundOnEntity( wall, ARENAS_SPAWNROOMWALL_SOUND_EVENT_NAME )
			EmitSoundOnEntity( wall, ARENAS_SPAWNROOMWALL_DISSOLVE_SOUND )
			wall.NotSolid()
			wall.MakeInvisible()
		}
	}
	printt( "[Arenas] Start zone walls", enabled ? "enabled" : "disabled", "(" + file.startZoneBrushes.len() + " brushes)" )
}

// ============================================================================
// MATERIAL CANISTERS (Cash Stations)
// ============================================================================
void function Arenas_SpawnCanisters()
{
	// Clean up any existing canisters from a previous round
	Arenas_CleanupCanisters()

	foreach ( entity infoEnt in file.canisterInfoEnts )
	{
		if ( !IsValid( infoEnt ) )
			continue

		vector origin = infoEnt.GetOrigin()
		vector angles = infoEnt.GetAngles()

		// Create a usable prop_script at the canister position
		entity canister = CreatePropScript( CASH_STATION_MODEL_SMALL, origin, angles, 6 )

		if ( !IsValid( canister ) )
			continue

		canister.SetScriptName( CASH_STATION_SMALL_SCRIPTNAME )
		canister.SetUsable()
		canister.SetUsableByGroup( "pilot" )
		canister.SetUsablePriority( USABLE_PRIORITY_LOW )
		canister.SetUsePrompts( "#ARENAS_GET_CASH", "#ARENAS_GET_CASH" )
		AddCallback_OnUseEntity( canister, Arenas_OnCanisterUsed )

		thread PlayAnim( canister, "source_full_idle" )

		file.activeCanisters.append( canister )
		printt( "[Arenas] Spawned canister at", origin )
	}

	printt( "[Arenas] Spawned", file.activeCanisters.len(), "material canisters" )
}

void function Arenas_CleanupCanisters()
{
	foreach ( entity canister in file.activeCanisters )
	{
		if ( IsValid( canister ) )
			canister.Destroy()
	}
	file.activeCanisters.clear()
}

// ============================================================================
// LOOT BINS
// ============================================================================
void function Arenas_SpawnLootBins()
{
	// Med loot bins contain healing items for mid-round recovery
	array<string> healingRefs = [
		"health_pickup_health_small",
		"health_pickup_health_large",
		"health_pickup_combo_small",
		"health_pickup_combo_large"
	]

	foreach ( entity locationEnt in file.medLootbinLocations )
	{
		if ( !IsValid( locationEnt ) )
			continue

		vector origin = locationEnt.GetOrigin()
		vector angles = locationEnt.GetAngles()

		// Spawn loot bin with random healing items (2-3 items per bin)
		int numItems = RandomIntRangeInclusive( 2, 3 )
		array<string> lootRefs
		for ( int i = 0; i < numItems; i++ )
			lootRefs.append( healingRefs.getrandom() )

		entity lootbin = CreateCustomLootBin( origin, angles, lootRefs )
		file.activeLootBins.append( lootbin )
		printt( "[Arenas] Loot bin spawned at", origin, "with", numItems, "items" )
	}
}

void function Arenas_CleanupLootBins()
{
	foreach ( entity lootbin in file.activeLootBins )
	{
		if ( IsValid( lootbin ) )
			lootbin.Destroy()
	}
	file.activeLootBins.clear()
}

// ============================================================================
// DEATHFIELD / RING MANAGEMENT
// ============================================================================
void function Arenas_ActivateRing()
{
	svGlobal.levelEnt.EndSignal( "GenerateDeathFieldData" )

	wait ARENAS_RING_ACTIVATION_DELAY

	if ( file.matchOver || file.currentPhase != eArenaPhase.COMBAT )
		return

	FlagClear( "DeathFieldPaused" )
}

void function Arenas_FreezeDeathfield()
{
	// Stop the deathfield stage loop, keep entities alive
	svGlobal.levelEnt.Signal( "GenerateDeathFieldData" )
	FlagClear( "SUR_DeathFieldShrinking" )
	FlagClear( "DeathCircleActive" )
	FlagSet( "DeathFieldPaused" )

	// Freeze ring at current interpolated radius
	int realm = Survival_Loot_GetDefaultRealm()
	DeathFieldData data = SURVIVAL_GetDeathFieldData( realm )

	float now = Time()
	float totalTime = data.endTime - data.startTime
	float frac = 0.0
	if ( totalTime > 0.0 )
		frac = clamp( (now - data.startTime) / totalTime, 0.0, 1.0 )
	float frozenRadius = data.startRadius + (data.endRadius - data.startRadius) * frac

	data.startRadius = frozenRadius
	data.endRadius = frozenRadius
	data.currentRadius = frozenRadius
	data.startTime = now
	data.endTime = now + 99999.0

	SetGlobalNetTimeSafe( "nextCircleStartTime", now + 99999.0 )
	SetGlobalNetTimeSafe( "circleCloseTime", now + 199999.0 )
}

void function Arenas_StopDeathfield()
{
	RoundBased_ResetDeathfield()
}

// ============================================================================
// CARE PACKAGE AIRDROPS
// ============================================================================
void function Arenas_AirdropTimer()
{
	svGlobal.levelEnt.EndSignal( "GenerateDeathFieldData" )

	wait ARENAS_AIRDROP_DELAY

	if ( file.matchOver || file.currentPhase != eArenaPhase.COMBAT )
		return

	Arenas_SpawnAirdrops()
}

void function Arenas_SpawnAirdrops()
{
	// Loot pool for arenas care packages: high-tier healing and shields
	array< array<string> > airdropLootPool = [
		[ "health_pickup_combo_full", "health_pickup_combo_large", "health_pickup_combo_large" ],
		[ "health_pickup_combo_full", "health_pickup_health_large", "health_pickup_combo_large" ],
		[ "health_pickup_combo_large", "health_pickup_combo_large", "health_pickup_health_large" ]
	]

	foreach ( entity locationEnt in file.airdropLocations )
	{
		if ( !IsValid( locationEnt ) )
			continue

		vector origin = locationEnt.GetOrigin()
		vector angles = locationEnt.GetAngles()

		// Pick random loot loadout for this care package
		array<string> contents = airdropLootPool[ RandomInt( airdropLootPool.len() ) ]

		// Spawn the airdrop
		AirdropItemsOptionalInfo optionInfo
		optionInfo.animationName = ARENAS_AIRDROP_ANIMATION
		thread AirdropItems( origin, angles, [contents], optionInfo )

		printt( "[Arenas] Care package airdrop spawned at", origin )
	}

	// Announce care packages to all players via minimap ping
	if ( file.airdropLocations.len() > 0 && IsValid( file.airdropLocations[0] ) )
	{
		vector pingOrigin = file.airdropLocations[0].GetOrigin()
		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsValid( player ) )
				Remote_CallFunction_NonReplay( player, "ServerCallback_SUR_PingMinimap", pingOrigin, 10.0, 500.0, 50.0, 2 )
		}
	}
}

void function Arenas_CleanupAirdrops()
{
	// Care packages spawned by AirdropItems are tracked in the global array
	array<entity> carePackages = ReturnCarePackagesNewArray()
	for ( int i = carePackages.len() - 1; i >= 0; i-- )
	{
		entity pod = carePackages[i]
		if ( IsValid( pod ) )
			pod.Destroy()
	}
	printt( "[Arenas] Airdrops cleaned up" )
}

void function Arenas_OnCanisterUsed( entity canister, entity player, int useInputFlags )
{
	if ( file.currentPhase != eArenaPhase.COMBAT )
		return

	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	if ( !( player in file.playerData ) )
		return

	// Award materials
	int reward = GetCurrentPlaylistVarInt( "arenas_cash_station_small_reward", ARENAS_CANISTER_REWARD )
	Arenas_AwardMaterials( player, reward )
	Arenas_SyncCashToClient( player )

	// Track canister collection (both per-round and cumulative)
	ArenaPlayerData data = file.playerData[player]
	data.canistersThisRound++
	data.canistersThisMatch++
	file.playerData[player] = data

	// Prevent double-use
	canister.UnsetUsable()
	file.activeCanisters.fastremovebyvalue( canister )

	// Play collection sounds
	EmitSoundOnEntityOnlyToPlayer( canister, player, "Crafting_Extractor_Collect_1P" )
	EmitSoundOnEntityExceptToPlayer( canister, player, "Crafting_Extractor_Collect_3P" )

	// Notify client while entity is still alive (needed for remote call entity param)
	Remote_CallFunction_NonReplay( player, "ServerCallback_Arenas_AnnounceResourcesCollected", reward )
	Remote_CallFunction_NonReplay( player, "ServerToClient_OnUseCashStationSmall", canister, reward )

	printt( "[Arenas] Player", player.GetPlayerName(), "collected canister for", reward, "materials" )

	// Play collection animation then destroy
	thread Arenas_CanisterCollectedAnim( canister )
}

void function Arenas_CanisterCollectedAnim( entity canister )
{
	if ( !IsValid( canister ) )
		return

	waitthread PlayAnim( canister, "source_full_to_empty" )

	if ( IsValid( canister ) )
	{
		thread PlayAnim( canister, "source_empty_idle" )
		wait 2.0
	}

	if ( IsValid( canister ) )
		canister.Destroy()
}

// ============================================================================
// LOADOUT GRANTING
// ============================================================================

// Strips all weapons and inventory from a player to prepare for loadout grant.
// Follows the same pattern as TakeLoadoutRelatedWeapons + TakeAllWeapons.
void function Arenas_StripPlayerLoadout( entity player )
{
	// Strip primary weapon slots
	if ( IsValid( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) ) )
		player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if ( IsValid( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 ) ) )
		player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_1 )

	// Strip ordnance (BR grenades use ANTI_TITAN slot, not OFFHAND_ORDNANCE)
	entity ordnance = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
	if ( IsValid( ordnance ) )
		player.TakeWeaponByEnt( ordnance )

	// Strip consumable slot
	if ( IsValid( player.GetOffhandWeapon( OFFHAND_SLOT_FOR_CONSUMABLES ) ) )
		player.TakeOffhandWeapon( OFFHAND_SLOT_FOR_CONSUMABLES )

	// Clear survival inventory (heals, ammo, etc.)
	SetPlayerInventory( player, [] )
}

// Determines if a loot ref is a main weapon (not ordnance, melee, or attachment).
// Uses the survival loot data system for proper classification.
bool function Arenas_IsWeaponRef( string ref )
{
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )
		return data.lootType == eLootType.MAINWEAPON
	}
	// Fallback: check prefix for weapons not in loot table
	return ref.find( "mp_weapon_" ) == 0
		&& ref.find( "melee" ) == -1
		&& ref.find( "frag_grenade" ) == -1
		&& ref.find( "thermite_grenade" ) == -1
		&& ref.find( "arc_star" ) == -1
		&& ref.find( "grenade_" ) == -1
}

// Determines if a loot ref is ordnance (grenades, arc stars, thermites).
bool function Arenas_IsOrdnanceRef( string ref )
{
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )
		return data.lootType == eLootType.ORDNANCE
	}
	return ref.find( "frag_grenade" ) != -1
		|| ref.find( "thermite_grenade" ) != -1
		|| ref.find( "arc_star" ) != -1
}

// Determines if a loot ref is a healing item (syringes, medkits, cells, batteries).
bool function Arenas_IsHealingRef( string ref )
{
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )
		return data.lootType == eLootType.HEALTH
	}
	return ref.find( "health_pickup_" ) == 0
}

// Gets the base weapon classname and mods array from a loot ref.
// For locked set weapons (whiteset/blueset/purpleset), the baseMods contain
// the tier mod which tells the engine what attachments to apply.
// Returns: [baseWeapon, modsArray]
string function Arenas_GetBaseWeaponFromRef( string ref )
{
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )
		if ( data.baseWeapon != "" )
			return data.baseWeapon
	}
	return ref
}

array<string> function Arenas_GetWeaponModsFromRef( string ref )
{
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )
		return clone data.baseMods
	}
	return []
}

// Main loadout granting function. Called at the end of each buy phase.
// Grants weapons based on selectedItems, following CTF/WinterExpress patterns.
void function Arenas_GrantPurchasedLoadout( entity player )
{
	printt( "[Arenas Grant] ENTER" )

	if ( !IsValid( player ) || !IsAlive( player ) )
	{
		printt( "[Arenas Grant] BAIL - invalid or dead" )
		return
	}

	if ( !( player in file.playerData ) )
	{
		printt( "[Arenas Grant] BAIL - not in playerData" )
		return
	}

	ArenaPlayerData data = file.playerData[player]
	printt( "[Arenas Grant] selections:", data.selectedItems.len(), "materials:", data.materials )

	// Save unspent materials as carryover for next round
	data.materialsCarryover = data.materials

	// Strip primary weapon slots only (melee, abilities, consumable already set by ResetPlayerForRound)
	printt( "[Arenas Grant] Stripping primary weapons" )
	if ( IsValid( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) ) )
		player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if ( IsValid( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 ) ) )
		player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_1 )

	Survival_SetInventoryEnabled( player, true )
	Inventory_SetPlayerEquipment( player, "backpack_pickup_lv3", "backpack" )
	Inventory_SetPlayerEquipment( player, "helmet_pickup_lv3", "helmet" )
	Inventory_SetPlayerEquipment( player, "armor_pickup_lv3", "armor" )

	printt( "[Arenas Grant] Base equipment given, granting purchases" )

	// Deduplicate weapon selections: when a player buys a base weapon then upgrades it,
	// both the base and upgrade refs are in selectedItems. Only grant the highest tier.
	table<string, string> highestWeaponByBase
	for ( int i = 0; i < data.selectedItems.len(); i++ )
	{
		string ref = data.selectedItems[i].ref
		if ( ref.find( "mp_weapon_" ) != 0 )
			continue
		if ( !SURVIVAL_Loot_IsRefValid( ref ) )
			continue
		LootData wData = SURVIVAL_Loot_GetLootDataByRef( ref )
		if ( wData.lootType != eLootType.MAINWEAPON )
			continue
		string baseRef = wData.baseWeapon != "" ? wData.baseWeapon : ref
		highestWeaponByBase[baseRef] <- ref
	}

	int weaponSlot = 0

	for ( int i = 0; i < data.selectedItems.len(); i++ )
	{
		string ref = data.selectedItems[i].ref
		printt( "[Arenas Grant] Item", i, "ref:", ref )

		// Ability purchases - grant weapon and apply charges/cooldown
		if ( ref == "tactical_upgrade" )
		{
			// Give tactical weapon if not already given this round
			entity existingTactical = player.GetOffhandWeapon( OFFHAND_TACTICAL )
			if ( !IsValid( existingTactical ) )
			{
				ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
				ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )
				player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL, [] )
				printt( "[Arenas Grant] Tactical weapon given" )
			}
			int currentCharges = player.GetPlayerNetInt( "passiveCharges" )
			player.SetPlayerNetInt( "passiveCharges", currentCharges + 1 )
			printt( "[Arenas Grant] Tactical upgrade applied, charges now:", currentCharges + 1 )
			continue
		}
		if ( ref == "arenas_full_ultimate" )
		{
			// Give ultimate weapon if not already given this round
			entity existingUlt = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
			if ( !IsValid( existingUlt ) )
			{
				ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
				ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( character )
				player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE, [] )
				printt( "[Arenas Grant] Ultimate weapon given" )
			}
			// Set ultimate to ready (0 = not on cooldown = ready to use)
			player.SetPlayerNetInt( "ultimateCooldown", 0 )
			// Charge the ultimate weapon to full
			entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
			if ( IsValid( ultWeapon ) )
			{
				ultWeapon.SetWeaponPrimaryClipCount( ultWeapon.GetWeaponPrimaryClipCountMax() )
			}
			printt( "[Arenas Grant] Full ultimate applied" )
			continue
		}
		if ( ref == "buy_passive" )
		{
			// Passive ability purchase - increment passive charges
			int currentCharges = player.GetPlayerNetInt( "passiveCharges" )
			player.SetPlayerNetInt( "passiveCharges", currentCharges + 1 )
			printt( "[Arenas Grant] Passive upgrade applied, charges now:", currentCharges + 1 )
			continue
		}

		// Check if it's a weapon by prefix
		if ( ref.find( "mp_weapon_" ) == 0 && weaponSlot < 2 )
		{
			// Skip lower tiers of same weapon (only grant highest purchased tier)
			if ( SURVIVAL_Loot_IsRefValid( ref ) )
			{
				LootData skipCheck = SURVIVAL_Loot_GetLootDataByRef( ref )
				string skipBase = skipCheck.baseWeapon != "" ? skipCheck.baseWeapon : ref
				if ( skipBase in highestWeaponByBase && highestWeaponByBase[skipBase] != ref )
				{
					printt( "[Arenas Grant] Skipping lower tier:", ref, "highest:", highestWeaponByBase[skipBase] )
					continue
				}
			}

			// Get base weapon and mods from loot data if available
			string baseWeapon = ref
			array<string> mods = []
			if ( SURVIVAL_Loot_IsRefValid( ref ) )
			{
				LootData lootData = SURVIVAL_Loot_GetLootDataByRef( ref )
				if ( lootData.baseWeapon != "" )
					baseWeapon = lootData.baseWeapon
				mods = clone lootData.baseMods
			}

			int slot = WEAPON_INVENTORY_SLOT_PRIMARY_0 + weaponSlot
			printt( "[Arenas Grant] GiveWeapon:", baseWeapon, "slot:", slot, "mods:", mods.len() )
			entity weapon = player.GiveWeapon( baseWeapon, slot, mods )

			if ( IsValid( weapon ) )
			{
				GetWeaponClassNameWithLockedSet( weapon ) // Initialize locked set entity var for client replication
				// Fill clip and give ammo
				if ( weapon.UsesClipsForAmmo() )
					weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
				player.AmmoPool_SetCapacity( 999 )
				SetupPlayerReserveAmmo( player, weapon )
				printt( "[Arenas Grant] Weapon given successfully:", baseWeapon )
			}
			else
			{
				printt( "[Arenas Grant] GiveWeapon FAILED for:", baseWeapon )
			}

			weaponSlot++
			continue
		}

		// Ordnance (grenades) - uses WEAPON_INVENTORY_SLOT_ANTI_TITAN with survival_finite_ordnance mod
		if ( Arenas_IsOrdnanceRef( ref ) )
		{
			string ordWeapon = Arenas_GetBaseWeaponFromRef( ref )
			SURVIVAL_AddToPlayerInventory( player, ref, 1 )

			entity existingOrd = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
			if ( IsValid( existingOrd ) && existingOrd.GetWeaponClassName() == ordWeapon )
			{
				int count = SURVIVAL_CountItemsInInventory( player, ref )
				existingOrd.SetWeaponPrimaryClipCount( minint( count, existingOrd.GetWeaponPrimaryClipCountMax() ) )
			}
			else
			{
				if ( IsValid( existingOrd ) )
					player.TakeWeaponByEnt( existingOrd )
				player.GiveWeapon( ordWeapon, WEAPON_INVENTORY_SLOT_ANTI_TITAN, ["survival_finite_ordnance"] )
				entity newOrd = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
				if ( IsValid( newOrd ) )
				{
					int count = SURVIVAL_CountItemsInInventory( player, ref )
					newOrd.SetWeaponPrimaryClipCount( minint( count, newOrd.GetWeaponPrimaryClipCountMax() ) )
				}
			}
			printt( "[Arenas Grant] Ordnance given:", ordWeapon )
			continue
		}

		// Healing items
		if ( ref.find( "health_pickup_" ) == 0 )
		{
			SURVIVAL_AddToPlayerInventory( player, ref, 1 )
			printt( "[Arenas Grant] Heal given:", ref )
			continue
		}

		// Everything else - try adding to inventory
		printt( "[Arenas Grant] Unknown ref:", ref )
		if ( SURVIVAL_Loot_IsRefValid( ref ) )
			SURVIVAL_AddToPlayerInventory( player, ref, 1 )
	}

	// Set active weapon
	if ( weaponSlot > 0 && IsValid( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) ) )
		player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )

	file.playerData[player] = data

	printt( "[Arenas Grant] DONE - weapons:", weaponSlot )
}

// ============================================================================
// IMMEDIATE GRANT / REVOKE (called on buy/sell during buy phase)
// ============================================================================

// Grants a single item immediately when purchased during buy phase.
// Called from ClientCommand_Arenas_Select after materials are deducted.
void function Arenas_GrantItem( entity player, string ref )
{
	if ( !IsValid( player ) )
		return

	printt( "[Arenas GrantItem]", ref )

	// Tactical ability upgrade
	if ( ref == "tactical_upgrade" )
	{
		entity existingTactical = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		if ( !IsValid( existingTactical ) )
		{
			ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
			ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )
			player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL, [] )
		}
		int currentCharges = player.GetPlayerNetInt( "passiveCharges" )
		player.SetPlayerNetInt( "passiveCharges", currentCharges + 1 )
		return
	}

	// Full ultimate
	if ( ref == "arenas_full_ultimate" )
	{
		entity existingUlt = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( !IsValid( existingUlt ) )
		{
			ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
			ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( character )
			player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE, [] )
		}
		player.SetPlayerNetInt( "ultimateCooldown", 0 )
		entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( IsValid( ultWeapon ) )
			ultWeapon.SetWeaponPrimaryClipCount( ultWeapon.GetWeaponPrimaryClipCountMax() )
		return
	}

	// Passive ability
	if ( ref == "buy_passive" )
	{
		int currentCharges = player.GetPlayerNetInt( "passiveCharges" )
		player.SetPlayerNetInt( "passiveCharges", currentCharges + 1 )
		return
	}

	// Ordnance (grenades) - use correct BR slot
	if ( Arenas_IsOrdnanceRef( ref ) )
	{
		string ordWeapon = Arenas_GetBaseWeaponFromRef( ref )
		SURVIVAL_AddToPlayerInventory( player, ref, 1 )

		entity existingOrd = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
		if ( IsValid( existingOrd ) && existingOrd.GetWeaponClassName() == ordWeapon )
		{
			int count = SURVIVAL_CountItemsInInventory( player, ref )
			existingOrd.SetWeaponPrimaryClipCount( minint( count, existingOrd.GetWeaponPrimaryClipCountMax() ) )
		}
		else
		{
			if ( IsValid( existingOrd ) )
				player.TakeWeaponByEnt( existingOrd )
			player.GiveWeapon( ordWeapon, WEAPON_INVENTORY_SLOT_ANTI_TITAN, ["survival_finite_ordnance"] )
			entity newOrd = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
			if ( IsValid( newOrd ) )
			{
				int count = SURVIVAL_CountItemsInInventory( player, ref )
				newOrd.SetWeaponPrimaryClipCount( minint( count, newOrd.GetWeaponPrimaryClipCountMax() ) )
			}
		}
		return
	}

	// Healing items
	if ( Arenas_IsHealingRef( ref ) )
	{
		SURVIVAL_AddToPlayerInventory( player, ref, 1 )
		return
	}

	// Weapons
	if ( Arenas_IsWeaponRef( ref ) )
	{
		string baseWeapon = Arenas_GetBaseWeaponFromRef( ref )
		array<string> mods = Arenas_GetWeaponModsFromRef( ref )

		// Check if player already has same base weapon (upgrade scenario)
		for ( int slot = WEAPON_INVENTORY_SLOT_PRIMARY_0; slot <= WEAPON_INVENTORY_SLOT_PRIMARY_1; slot++ )
		{
			entity existing = player.GetNormalWeapon( slot )
			if ( !IsValid( existing ) )
				continue

			string existingClass = existing.GetWeaponClassName()
			// Check if existing weapon matches this base weapon
			if ( existingClass == baseWeapon )
			{
				// Same base weapon - upgrade in place: take old, give new with mods
				player.TakeNormalWeaponByIndexNow( slot )
				entity weapon = player.GiveWeapon( baseWeapon, slot, mods )
				if ( IsValid( weapon ) )
				{
					GetWeaponClassNameWithLockedSet( weapon ) // Initialize locked set entity var for client replication
					if ( weapon.UsesClipsForAmmo() )
						weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
					player.AmmoPool_SetCapacity( 999 )
					SetupPlayerReserveAmmo( player, weapon )
				}
				player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, slot )
				printt( "[Arenas GrantItem] Weapon upgraded in slot", slot )
				return
			}
		}

		// New weapon - find first free slot
		for ( int slot = WEAPON_INVENTORY_SLOT_PRIMARY_0; slot <= WEAPON_INVENTORY_SLOT_PRIMARY_1; slot++ )
		{
			entity existing = player.GetNormalWeapon( slot )
			if ( IsValid( existing ) )
				continue

			entity weapon = player.GiveWeapon( baseWeapon, slot, mods )
			if ( IsValid( weapon ) )
			{
				GetWeaponClassNameWithLockedSet( weapon ) // Initialize locked set entity var for client replication
				if ( weapon.UsesClipsForAmmo() )
					weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
				player.AmmoPool_SetCapacity( 999 )
				SetupPlayerReserveAmmo( player, weapon )
			}
			player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, slot )
			printt( "[Arenas GrantItem] Weapon given to slot", slot )
			return
		}

		printt( "[Arenas GrantItem] No free weapon slot for:", ref )
		return
	}

	// Fallback
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
		SURVIVAL_AddToPlayerInventory( player, ref, 1 )
}

// Revokes a single item immediately when sold during buy phase.
// Called from ClientCommand_Arenas_Unselect after materials are refunded.
void function Arenas_RevokeItem( entity player, string ref, ArenaPlayerData data )
{
	if ( !IsValid( player ) )
		return

	printt( "[Arenas RevokeItem]", ref )

	// Tactical ability
	if ( ref == "tactical_upgrade" )
	{
		int currentCharges = player.GetPlayerNetInt( "passiveCharges" )
		player.SetPlayerNetInt( "passiveCharges", maxint( 0, currentCharges - 1 ) )
		if ( currentCharges <= 1 )
		{
			entity tactical = player.GetOffhandWeapon( OFFHAND_TACTICAL )
			if ( IsValid( tactical ) )
				player.TakeOffhandWeapon( OFFHAND_TACTICAL )
		}
		return
	}

	// Full ultimate
	if ( ref == "arenas_full_ultimate" )
	{
		player.SetPlayerNetInt( "ultimateCooldown", 1 )
		entity ult = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( IsValid( ult ) )
			player.TakeOffhandWeapon( OFFHAND_ULTIMATE )
		return
	}

	// Passive ability
	if ( ref == "buy_passive" )
	{
		int currentCharges = player.GetPlayerNetInt( "passiveCharges" )
		player.SetPlayerNetInt( "passiveCharges", maxint( 0, currentCharges - 1 ) )
		return
	}

	// Ordnance
	if ( Arenas_IsOrdnanceRef( ref ) )
	{
		SURVIVAL_RemoveFromPlayerInventory( player, ref, 1 )
		int remaining = SURVIVAL_CountItemsInInventory( player, ref )
		entity ordWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
		if ( remaining <= 0 )
		{
			if ( IsValid( ordWeapon ) )
				player.TakeWeaponByEnt( ordWeapon )
		}
		else if ( IsValid( ordWeapon ) )
		{
			ordWeapon.SetWeaponPrimaryClipCount( minint( remaining, ordWeapon.GetWeaponPrimaryClipCountMax() ) )
		}
		return
	}

	// Healing items
	if ( Arenas_IsHealingRef( ref ) )
	{
		SURVIVAL_RemoveFromPlayerInventory( player, ref, 1 )
		return
	}

	// Weapons
	if ( Arenas_IsWeaponRef( ref ) )
	{
		string baseWeapon = Arenas_GetBaseWeaponFromRef( ref )

		// Find which slot has this weapon
		for ( int slot = WEAPON_INVENTORY_SLOT_PRIMARY_0; slot <= WEAPON_INVENTORY_SLOT_PRIMARY_1; slot++ )
		{
			entity existing = player.GetNormalWeapon( slot )
			if ( !IsValid( existing ) )
				continue
			if ( existing.GetWeaponClassName() != baseWeapon )
				continue

			// Found the weapon in this slot - take it
			player.TakeNormalWeaponByIndexNow( slot )

			// Check if there's a lower tier still purchased for same base weapon
			string remainingRef = Arenas_GetHighestRemainingTier( data, baseWeapon, ref )
			if ( remainingRef != "" )
			{
				string remainBase = Arenas_GetBaseWeaponFromRef( remainingRef )
				array<string> remainMods = Arenas_GetWeaponModsFromRef( remainingRef )
				entity weapon = player.GiveWeapon( remainBase, slot, remainMods )
				if ( IsValid( weapon ) )
				{
					GetWeaponClassNameWithLockedSet( weapon ) // Initialize locked set entity var for client replication
					if ( weapon.UsesClipsForAmmo() )
						weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
					player.AmmoPool_SetCapacity( 999 )
					SetupPlayerReserveAmmo( player, weapon )
				}
				printt( "[Arenas RevokeItem] Downgraded to:", remainingRef )
			}
			else
			{
				printt( "[Arenas RevokeItem] Weapon removed from slot", slot )
			}
			return
		}
		return
	}

	// Fallback
	if ( SURVIVAL_Loot_IsRefValid( ref ) )
		SURVIVAL_RemoveFromPlayerInventory( player, ref, 1 )
}

// Finds the highest tier weapon ref still in selectedItems for the given base weapon,
// excluding a specific ref (the one being sold). Returns "" if none found.
string function Arenas_GetHighestRemainingTier( ArenaPlayerData data, string baseWeapon, string excludeRef )
{
	string bestRef = ""
	int bestTier = -1

	foreach ( ArenasSelectedItem item in data.selectedItems )
	{
		if ( item.ref == excludeRef )
			continue
		if ( !Arenas_IsWeaponRef( item.ref ) )
			continue

		string itemBase = Arenas_GetBaseWeaponFromRef( item.ref )
		if ( itemBase != baseWeapon )
			continue

		// Determine tier from loot data
		int tier = 0
		if ( SURVIVAL_Loot_IsRefValid( item.ref ) )
		{
			LootData lootData = SURVIVAL_Loot_GetLootDataByRef( item.ref )
			tier = lootData.tier
		}

		if ( tier > bestTier )
		{
			bestTier = tier
			bestRef = item.ref
		}
	}

	return bestRef
}

// ============================================================================
// COMBAT PHASE
// ============================================================================
void function Arenas_CombatPhase()
{
	printt( "[Arenas] CombatPhase started" )
	file.currentPhase = eArenaPhase.COMBAT
	SetGameState( eGameState.Playing )
	SetGlobalNetIntSafe( "gameState", eGameState.Playing )

	// Log team state at combat start for debugging
	array<entity> leftAll = GetPlayerArrayOfTeam( file.leftTeam )
	array<entity> rightAll = GetPlayerArrayOfTeam( file.rightTeam )
	printt( "[Arenas] Combat teams - IMC total:", leftAll.len(), "alive:", GetPlayerArrayOfTeam_Alive( file.leftTeam ).len(),
		"MILITIA total:", rightAll.len(), "alive:", GetPlayerArrayOfTeam_Alive( file.rightTeam ).len() )

	// Walls already opened at end of BuyPhase (synced with client RUI timer)

	// Zoom minimap out for combat
	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
			player.SetMinimapZoomScale( ARENAS_DEFAULT_MINIMAP_ZOOM, 1.0 )
	}

	// Reset first blood flag for this round
	file.firstBloodThisRound = false

	// Spawn material canisters and loot bins for this round
	Arenas_SpawnCanisters()
	Arenas_SpawnLootBins()

	// Notify all clients that combat has begun (per-player announcement style)
	Arenas_SendRoundStartAnnouncement()

	// Round start battle chatter
	thread SurvivalCommentary_HostAnnounce( GetRoundCommentaryBucket( file.roundNumber ), ARENAS_ROUNDSTART_BC_DELAY )

	// Activate ring shrink after delay
	thread Arenas_ActivateRing()

	// Care package airdrop timer
	if ( file.airdropLocations.len() > 0 )
		thread Arenas_AirdropTimer()

	// Wait for one team to be eliminated or timeout
	float combatStartTime = Time()
	bool roundResolved = false

	while ( !roundResolved )
	{
		// Force next round via debug command
		if ( file.forceNextRound )
		{
			printt( "[Arenas] Force next round triggered" )
			file.forceNextRound = false
			Arenas_RoundEnd( file.leftTeam )
			roundResolved = true
			break
		}

		// Check if either team is fully eliminated
		array<entity> leftAlive = GetPlayerArrayOfTeam_Alive( file.leftTeam )
		array<entity> rightAlive = GetPlayerArrayOfTeam_Alive( file.rightTeam )

		if ( leftAlive.len() == 0 && rightAlive.len() == 0 )
		{
			// Both teams eliminated simultaneously - draw/tie
			Arenas_RoundEnd( 0 ) // 0 = draw
			roundResolved = true
		}
		else if ( leftAlive.len() == 0 )
		{
			// Left team eliminated - right team wins
			Arenas_RoundEnd( file.rightTeam )
			roundResolved = true
		}
		else if ( rightAlive.len() == 0 )
		{
			// Right team eliminated - left team wins
			Arenas_RoundEnd( file.leftTeam )
			roundResolved = true
		}

		if ( !roundResolved )
			WaitFrame()
	}
}

// ============================================================================
// ROUND END
// ============================================================================
void function Arenas_RoundEnd( int winningTeam )
{
	file.currentPhase = eArenaPhase.ROUND_END

	// Clean up any remaining canisters, loot bins, airdrops
	Arenas_CleanupCanisters()
	Arenas_CleanupLootBins()
	Arenas_CleanupAirdrops()

	// Freeze ring in place (stays visible during round-end celebration)
	Arenas_FreezeDeathfield()

	// Clean up player abilities, tracked projectiles (traps, gas, drones, etc.), and deathboxes
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		PROTO_CleanupTrackedProjectiles( player )
		player.Signal( "CleanUpPlayerAbilities" )
	}

	// Destroy all deathboxes
	array<entity> deathboxes = GetEntArrayByClass_Expensive( "prop_death_box" )
	foreach ( entity deathbox in deathboxes )
	{
		if ( IsValid( deathbox ) )
			deathbox.Destroy()
	}

	// Destroy all dropped loot
	array<entity> droppedLoot = GetEntArrayByClass_Expensive( "prop_survival" )
	foreach ( entity loot in droppedLoot )
	{
		if ( IsValid( loot ) )
			loot.Destroy()
	}

	if ( winningTeam == 0 )
	{
		// Draw - counts as a tie
		file.numTies++
		SetGlobalNetIntSafe( "arenas_numties", file.numTies )
	}
	else
	{
		// Update scores
		if ( winningTeam == file.leftTeam )
			file.leftTeamScore++
		else
			file.rightTeamScore++

		file.lastWonTeam = winningTeam
		SetGlobalNetIntSafe( "arenas_lastWonTeam", winningTeam )

		// Update team scores in game rules (used by scoreboard and win detection)
		GameRules_SetTeamScore( file.leftTeam, file.leftTeamScore )
		GameRules_SetTeamScore( file.rightTeam, file.rightTeamScore )
	}

	// Determine round won descriptor
	int roundWonDesc = Arenas_GetRoundWonDescriptor( winningTeam )

	// Notify clients
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		if ( winningTeam == 0 )
		{
			// Draw round - display as lost for everyone
			Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayRoundLost" )
		}
		else if ( player.GetTeam() == winningTeam )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayRoundWon", roundWonDesc )
		}
		else
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayRoundLost" )
		}
	}

	// Round end battle chatter
	thread SurvivalCommentary_HostAnnounce( eSurvivalCommentaryBucket.ROUND_WIN_BY_ELIM, ARENAS_ROUNDEND_BC_DELAY )

	wait ARENAS_ROUND_END_DELAY

	// Check match end conditions
	if ( Arenas_CheckMatchEnd() )
	{
		file.matchOver = true
		Arenas_StopDeathfield()
		return
	}

	// Fade to black before round restart (players will be teleported during black screen)
	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
			ScreenFadeToBlack( player, 1.0, ARENAS_ROUND_RESTART_DELAY + 1.0 )
	}

	// Wait for fade before destroying ring
	wait 1.0

	Arenas_StopDeathfield()

	wait ARENAS_ROUND_RESTART_DELAY - 1.0
}

int function Arenas_GetRoundWonDescriptor( int winningTeam )
{
	if ( winningTeam == 0 )
		return eArenasRoundWonDescriptor.DEFAULT

	// Check for perfect round (winning team took no damage)
	bool perfectRound = true
	bool flawlessRound = true

	array<entity> winners = GetPlayerArrayOfTeam( winningTeam )
	foreach ( entity player in winners )
	{
		if ( !IsValid( player ) )
			continue
		if ( player in file.playerData )
		{
			// If anyone on the winning team died, not perfect
			if ( file.playerData[player].isEliminated )
				perfectRound = false
		}
		// Check health - if any damage taken at all, not flawless
		if ( IsAlive( player ) && player.GetHealth() < player.GetMaxHealth() )
			flawlessRound = false
	}

	// Check for clutch (1 alive vs full team)
	array<entity> aliveWinners = GetPlayerArrayOfTeam_Alive( winningTeam )
	int losingTeam = ( winningTeam == file.leftTeam ) ? file.rightTeam : file.leftTeam
	array<entity> losingTeamPlayers = GetPlayerArrayOfTeam( losingTeam )

	if ( aliveWinners.len() == 1 && losingTeamPlayers.len() >= 3 )
		return eArenasRoundWonDescriptor.CLUTCH

	if ( flawlessRound )
		return eArenasRoundWonDescriptor.FLAWLESS

	if ( perfectRound )
		return eArenasRoundWonDescriptor.PERFECT

	return eArenasRoundWonDescriptor.DEFAULT
}

bool function Arenas_CheckMatchEnd()
{
	int leftScore = file.leftTeamScore
	int rightScore = file.rightTeamScore
	int minWinScore = ARENAS_ROUNDS_TO_WIN

	// Sudden death: if max ties reached, first to win takes it
	if ( file.numTies >= ARENAS_MAX_TIES )
	{
		if ( leftScore > rightScore || rightScore > leftScore )
			return true
	}

	// Standard win: need minimum score AND lead by at least 1
	// Win-by-2 logic: if both teams are at minWinScore-1 or higher, need 2 point lead
	if ( leftScore >= minWinScore || rightScore >= minWinScore )
	{
		int scoreDiff = leftScore - rightScore
		if ( scoreDiff < 0 )
			scoreDiff = -scoreDiff

		// At high scores, need win-by-2
		if ( leftScore >= minWinScore - 1 && rightScore >= minWinScore - 1 )
		{
			if ( scoreDiff >= 2 )
				return true
		}
		else
		{
			// One team reached win threshold with clear lead
			if ( leftScore >= minWinScore && leftScore > rightScore )
				return true
			if ( rightScore >= minWinScore && rightScore > leftScore )
				return true
		}
	}

	return false
}

// ============================================================================
// MATCH END
// ============================================================================
void function Arenas_MatchEnd()
{
	file.currentPhase = eArenaPhase.MATCH_END

	// Signal to client that the match is complete (used by Arenas_IsMatchComplete())
	SetServerVar( "roundScoreLimitComplete", true )

	int winningTeam = 0
	if ( file.leftTeamScore > file.rightTeamScore )
		winningTeam = file.leftTeam
	else if ( file.rightTeamScore > file.leftTeamScore )
		winningTeam = file.rightTeam

	printt( "[Arenas] Match ended - Winner:", winningTeam, "Score:", file.leftTeamScore, "-", file.rightTeamScore )

	// Match end battle chatter
	thread SurvivalCommentary_HostAnnounce( eSurvivalCommentaryBucket.WINNER, ARENAS_MATCHEND_COMMENTARY_DEALY )

	// Set winning team so GetWinningTeam() works on client for champion screen
	level.nv.winningTeam = winningTeam

	// Send winning squad data for champion screen display.
	// First clear existing data, then populate with each winning team member's stats.
	array<entity> winningPlayers = GetPlayerArrayOfTeam( winningTeam )
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		// Clear previous squad data (S3 split: Base only needed for clear)
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddWinningSquadData_Base", -1, -1, 0, 0, 0, 0, 0, 0 )

		// Send each winning team member's stats (S3 split: Base + Extra)
		foreach ( int idx, entity winner in winningPlayers )
		{
			if ( !IsValid( winner ) )
				continue

			int kills = 0
			int damage = 0
			if ( winner in file.playerData )
			{
				ArenaPlayerData data = file.playerData[winner]
				kills = data.killsThisMatch
				damage = winner.GetPlayerNetInt( "damageDealt" )
			}

			Remote_CallFunction_NonReplay( player, "ServerCallback_AddWinningSquadData_Base",
				idx, winner.GetEncodedEHandle(), kills, damage, 0, 0, 0, 0 )
			Remote_CallFunction_NonReplay( player, "ServerCallback_AddWinningSquadData_Extra",
				0, false, 0, 0, 0, 0, 0, 0 )
		}
	}

	// Make all players invincible and show champion screen
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		MakeInvincible( player )
		Remote_CallFunction_NonReplay( player, "ServerCallback_MatchEndAnnouncement", player.GetTeam() == winningTeam, winningTeam )
	}

	wait ARENAS_MATCH_END_DELAY

	// Trigger the victory sequence (3D character poses)
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue
		Remote_CallFunction_NonReplay( player, "ServerCallback_ShowWinningSquadSequence" )
	}

	// End the match via game state transition
	SetGameState( eGameState.WinnerDetermined )
	SetGlobalNetIntSafe( "gameState", eGameState.WinnerDetermined )

	// Restart map after champion screen
	wait 15.0
	GameRules_ChangeMap( GetMapName(), GetCurrentPlaylistName() )
}

// ============================================================================
// PLAYER KILL TRACKING
// ============================================================================
void function Arenas_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( file.currentPhase != eArenaPhase.COMBAT )
		return

	if ( !IsValid( victim ) )
		return

	// Mark player as eliminated
	if ( victim in file.playerData )
	{
		ArenaPlayerData data = file.playerData[victim]
		data.isEliminated = true
		file.playerData[victim] = data
	}

	// Track kill for attacker and award kill bonus materials
	if ( IsValid( attacker ) && attacker.IsPlayer() && attacker != victim )
	{
		if ( attacker.GetTeam() != victim.GetTeam() )
		{
			if ( attacker in file.playerData )
			{
				ArenaPlayerData attackerData = file.playerData[attacker]
				attackerData.killsThisRound++
				attackerData.killsThisMatch++
				attackerData.materials = minint( attackerData.materials + ARENAS_KILL_REWARD, ARENAS_MAX_CASH )
				file.playerData[attacker] = attackerData
				Arenas_SyncCashToClient( attacker )

				// Sync kills to client netvar for HUD display
				attacker.SetPlayerNetInt( "kills", attackerData.killsThisMatch )
			}

			// First blood commentary
			if ( !file.firstBloodThisRound )
			{
				file.firstBloodThisRound = true
				thread SurvivalCommentary_KilledPlayerAnnounce( eSurvivalCommentaryBucket.FIRST_BLOOD, attacker, ARENAS_ONKILL_BC_DELAY, "bc_firstBlood", "bc_weTookFirstBlood" )
			}
		}
	}

	// Note: Team elimination check happens in the combat phase loop
	// via GetPlayerArrayOfTeam_Alive() polling
}

// ============================================================================
// DAMAGE TRACKING
// ============================================================================
void function Arenas_OnPlayerDamaged( entity victim, var damageInfo )
{
	if ( file.currentPhase != eArenaPhase.COMBAT )
		return

	if ( !IsValid( victim ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	int damage = int( DamageInfo_GetDamage( damageInfo ) )

	if ( damage <= 0 )
		return

	// Track damage dealt by attacker
	if ( IsValid( attacker ) && attacker.IsPlayer() && attacker != victim )
	{
		if ( attacker.GetTeam() != victim.GetTeam() && attacker in file.playerData )
		{
			ArenaPlayerData attackerData = file.playerData[attacker]
			attackerData.damageThisRound += damage
			file.playerData[attacker] = attackerData

			// Sync damage to client netvar for HUD display (accumulates across match)
			attacker.SetPlayerNetInt( "damageDealt", attacker.GetPlayerNetInt( "damageDealt" ) + damage )
		}
	}
}

// ============================================================================
// TEAM ELIMINATION CHECK (for disconnects during combat)
// ============================================================================
void function Arenas_CheckTeamEliminated()
{
	wait 0.1 // Brief yield to let disconnect process

	if ( file.currentPhase != eArenaPhase.COMBAT )
		return

	// The combat loop will naturally detect the elimination
	// via GetPlayerArrayOfTeam_Alive() returning 0
}

// ============================================================================
// BUY SYSTEM SERVER CALLBACKS
// ============================================================================
// Buy flow:
// 1. Client clicks item in buy menu
// 2. Client sends "Arenas_Select <idx> <cost> <ref>" via ClientCommand
// 3. Server validates affordability, deducts materials, tracks selection
// 4. Server syncs arenas_current_cash netvar -> client OnCurrentCashChanged -> UI refresh
// 5. Server sends ServerCallback_FinishedProcessingClickEvent to unblock UI

// ============================================================================
// ANNOUNCE STYLE PER-PLAYER (server sends appropriate style to each player)
// ============================================================================
void function Arenas_SendRoundStartAnnouncement()
{
	int leftScore = file.leftTeamScore
	int rightScore = file.rightTeamScore
	int minWinScore = ARENAS_ROUNDS_TO_WIN

	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		int announceStyle = eArenasRoundStartAnnounce.ROUND_NUM

		// Sudden death
		if ( file.numTies >= ARENAS_MAX_TIES )
		{
			announceStyle = eArenasRoundStartAnnounce.SUDDEN_DEATH
		}
		// Tiebreaker
		else if ( leftScore == rightScore && leftScore + 1 >= minWinScore )
		{
			announceStyle = eArenasRoundStartAnnounce.TIEBREAKER
		}
		// Match point
		else
		{
			int myTeam = player.GetTeam()
			int myScore = ( myTeam == file.leftTeam ) ? leftScore : rightScore
			int enemyScore = ( myTeam == file.leftTeam ) ? rightScore : leftScore

			bool enemyMatchPoint = enemyScore >= (minWinScore - 1) && enemyScore - myScore >= 1
			bool myMatchPoint = myScore >= (minWinScore - 1) && myScore - enemyScore >= 1

			if ( enemyMatchPoint )
				announceStyle = eArenasRoundStartAnnounce.MATCHPOINT_ENEMY
			else if ( myMatchPoint )
				announceStyle = eArenasRoundStartAnnounce.MATCHPOINT_YOU
		}

		Remote_CallFunction_NonReplay( player, "ServerCallback_Arenas_AnnounceRoundStart", announceStyle )
	}
}

// ============================================================================
// CLIENT COMMAND HANDLERS (Buy System)
// ============================================================================
bool function ClientCommand_Arenas_Select( entity player, array<string> args )
{
	// Expected args: <index> <cost> <ref>
	if ( !IsValid( player ) || args.len() < 3 )
		return false

	if ( file.currentPhase != eArenaPhase.BUY_PHASE )
		return false

	if ( !( player in file.playerData ) )
		return false

	int itemIndex = args[0].tointeger()
	int cost = args[1].tointeger()
	string ref = args[2]

	// Validate cost is reasonable
	if ( cost < 0 || cost > ARENAS_MAX_CASH )
		return false

	ArenaPlayerData data = file.playerData[player]

	// Enforce ability purchase limits server-side
	if ( ref == "tactical_upgrade" || ref == "arenas_full_ultimate" || ref == "buy_passive" )
	{
		int refCount = 0
		foreach ( sel in data.selectedItems )
			if ( sel.ref == ref )
				refCount++

		int maxCount = 1
		if ( ref == "tactical_upgrade" )
			maxCount = GetCurrentPlaylistVarInt( "arenas_max_tactical_upgrades", 2 )

		if ( refCount >= maxCount )
		{
			printt( "[Arenas] Player", player.GetPlayerName(), "already at max for", ref, "count:", refCount )
			Remote_CallFunction_NonReplay( player, "ServerCallback_FinishedProcessingClickEvent" )
			return true
		}
	}

	// Check if player can afford it
	if ( data.materials < cost )
	{
		printt( "[Arenas] Player", player.GetPlayerName(), "cannot afford", ref, "cost:", cost, "has:", data.materials )
		Remote_CallFunction_NonReplay( player, "ServerCallback_FinishedProcessingClickEvent" )
		return true
	}

	// Deduct materials and track selection
	data.materials -= cost
	ArenasSelectedItem selection
	selection.ref = ref
	selection.cost = cost
	data.selectedItems.append( selection )
	file.playerData[player] = data

	// Immediately grant the purchased item
	Arenas_GrantItem( player, ref )

	// Sync cash to client (triggers OnCurrentCashChanged -> UI refresh)
	Arenas_SyncCashToClient( player )

	// Tell client we finished processing
	Remote_CallFunction_NonReplay( player, "ServerCallback_FinishedProcessingClickEvent" )

	printt( "[Arenas] Player", player.GetPlayerName(), "bought", ref, "for", cost, "remaining:", data.materials )
	return true
}

bool function ClientCommand_Arenas_Unselect( entity player, array<string> args )
{
	// Expected args: <index> <cost> <ref>
	if ( !IsValid( player ) || args.len() < 3 )
		return false

	if ( file.currentPhase != eArenaPhase.BUY_PHASE )
		return false

	if ( !( player in file.playerData ) )
		return false

	int itemIndex = args[0].tointeger()
	int cost = args[1].tointeger()
	string ref = args[2]

	if ( cost < 0 || cost > ARENAS_MAX_CASH )
		return false

	// Find and remove the matching item from selections
	ArenaPlayerData data = file.playerData[player]
	bool found = false
	for ( int i = 0; i < data.selectedItems.len(); i++ )
	{
		if ( data.selectedItems[i].ref == ref )
		{
			cost = data.selectedItems[i].cost // Use server-tracked cost for refund
			data.selectedItems.remove( i )
			found = true
			break
		}
	}

	if ( !found )
	{
		printt( "[Arenas] Player", player.GetPlayerName(), "tried to unselect", ref, "but it was not found" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_FinishedProcessingClickEvent" )
		return true
	}

	// Refund materials
	data.materials = minint( data.materials + cost, ARENAS_MAX_CASH )
	file.playerData[player] = data

	// Immediately revoke the sold item
	Arenas_RevokeItem( player, ref, data )

	// Sync cash to client
	Arenas_SyncCashToClient( player )

	// Tell client we finished processing
	Remote_CallFunction_NonReplay( player, "ServerCallback_FinishedProcessingClickEvent" )

	printt( "[Arenas] Player", player.GetPlayerName(), "refunded", ref, "for", cost, "remaining:", data.materials )
	return true
}

bool function ClientCommand_Arenas_SetOptic( entity player, array<string> args )
{
	if ( !IsValid( player ) || args.len() < 2 )
		return false

	if ( file.currentPhase != eArenaPhase.BUY_PHASE )
		return false

	int weaponIndex = args[0].tointeger()
	int opticIndex = args[1].tointeger()

	// TODO: Validate optic assignment
	printt( "[Arenas] Player", player.GetPlayerName(), "set optic:", opticIndex, "on weapon:", weaponIndex )
	return true
}

bool function ClientCommand_Arenas_ChangeWeaponTab( entity player, array<string> args )
{
	if ( !IsValid( player ) || args.len() < 1 )
		return false

	// Tab change is client-side only, server just acknowledges
	return true
}

bool function ClientCommand_Arenas_OnBuyMenuOpen( entity player, array<string> args )
{
	if ( !IsValid( player ) )
		return false

	return true
}

bool function ClientCommand_Arenas_OnBuyMenuClose( entity player, array<string> args )
{
	if ( !IsValid( player ) )
		return false

	// Track that the player has closed/confirmed their buy menu
	if ( player in file.playerData )
		file.playerData[player].hasConfirmedLoadout = true

	return true
}

bool function ClientCommand_Arenas_ForceNextRound( entity player, array<string> args )
{
	if ( !IsValid( player ) )
		return false

	if ( !GetDeveloperLevel() )
		return false

	file.forceNextRound = true
	printt( "[Arenas] Force next round requested by", player.GetPlayerName() )
	return true
}

// ============================================================================
// EQUIPMENT NETVAR SETUP
// ============================================================================
// Sets arenas_available_equipment_0..10 global netvars so the client buy menu
// knows which store indices to display in the heal/ordnance/ability slots.
// Called directly from Arenas_ServerGamemode_Init (loot datatables already loaded by then).
//
// UI layout expects:
//   Slots 0-2 = Ability section  (tactical_upgrade, arenas_full_ultimate, buy_passive)
//   Slots 3-10 = Consumable section (heals, ordnance, utility items)
//
// The datatable row order may not match this layout, so we sort items
// by type before assigning them to slots.
void function Arenas_SetEquipmentNetvars()
{
	// The client builds store indices as:
	//   [0..N-1] = weapons from SURVIVAL_Loot_GetLootDataTable() (MAINWEAPON entries)
	//   [N..N+M-1] = rows from arenas_items datatable
	// We need to count weapons the same way the client does to get the offset.

	table<string, LootData> allLootData = SURVIVAL_Loot_GetLootDataTable()
	array<string> disabledWeapons = split( GetCurrentPlaylistVarString( "survival_disabled_weapons", "" ).tolower(), " " )

	int weaponCount = 0
	foreach ( ref, data in allLootData )
	{
		if ( data.lootType != eLootType.MAINWEAPON || ref.find( WEAPON_LOCKEDSET_SUFFIX_GOLD ) >= 0 )
			continue
		if ( data.baseMods.contains( WEAPON_LOCKEDSET_MOD_CRATE ) )
			continue
		if ( disabledWeapons.contains( data.baseWeapon ) )
			continue
		weaponCount++
	}

	printt( "[Arenas] Equipment netvar setup - weapon count offset:", weaponCount )

	// Read arenas_items datatable (same one the client reads)
	var dataTable = GetDataTable( $"datatable/arenas/arenas_items.rpak" )
	int numRows = GetDatatableRowCount( dataTable )

	printt( "[Arenas] Equipment netvar setup - datatable rows:", numRows )

	// Separate items into abilities and consumables.
	// The client UI has hardcoded expectations:
	//   Slot 0 = buy_passive       (Ability_0 in UI)
	//   Slot 1 = tactical_upgrade  (Ability_1 in UI, also read by arenas_player_tactical)
	//   Slot 2 = arenas_full_ultimate (Ability_2 in UI, also read by arenas_player_ultimate)
	//   Slots 3-10 = consumable items (Equipment_0..7 in UI)
	int passiveRow = -1
	int tacticalRow = -1
	int ultimateRow = -1
	array<int> consumableRows

	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "ref" ) )
		if ( itemRef == "buy_passive" )
			passiveRow = i
		else if ( itemRef == "tactical_upgrade" )
			tacticalRow = i
		else if ( itemRef == "arenas_full_ultimate" )
			ultimateRow = i
		else
			consumableRows.append( i )

		printt( "[Arenas] Datatable row", i, "ref:", itemRef )
	}

	// Assign abilities to their fixed slots
	if ( passiveRow != -1 )
	{
		SetGlobalNetIntSafe( "arenas_available_equipment_0", weaponCount + passiveRow )
		printt( "[Arenas] Slot 0 (passive) = store index", weaponCount + passiveRow, "(row", passiveRow, ")" )
	}
	if ( tacticalRow != -1 )
	{
		SetGlobalNetIntSafe( "arenas_available_equipment_1", weaponCount + tacticalRow )
		printt( "[Arenas] Slot 1 (tactical) = store index", weaponCount + tacticalRow, "(row", tacticalRow, ")" )
	}
	if ( ultimateRow != -1 )
	{
		SetGlobalNetIntSafe( "arenas_available_equipment_2", weaponCount + ultimateRow )
		printt( "[Arenas] Slot 2 (ultimate) = store index", weaponCount + ultimateRow, "(row", ultimateRow, ")" )
	}

	// Assign consumables to slots 3-10
	int slotIndex = 3
	foreach ( int row in consumableRows )
	{
		if ( slotIndex >= 11 )
			break
		int storeIndex = weaponCount + row
		SetGlobalNetIntSafe( "arenas_available_equipment_" + slotIndex, storeIndex )
		string itemRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "ref" ) )
		printt( "[Arenas] Consumable slot", slotIndex, "= store index", storeIndex, "ref:", itemRef, "(row", row, ")" )
		slotIndex++
	}

	int abilityCount = ( passiveRow != -1 ? 1 : 0 ) + ( tacticalRow != -1 ? 1 : 0 ) + ( ultimateRow != -1 ? 1 : 0 )
	printt( "[Arenas] Equipment netvars set:", abilityCount, "abilities +", consumableRows.len(), "consumables =", slotIndex, "total slots" )
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================
ArenaPlayerData function Arenas_GetPlayerData( entity player )
{
	if ( player in file.playerData )
		return file.playerData[player]

	ArenaPlayerData data
	return data
}
