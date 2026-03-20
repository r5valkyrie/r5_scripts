global function GamemodeSurvival_Init
// RateSpawnpoints_Directional now lives in mp/spawn.nut
global function Survival_SetFriendlyOwnerHighlight
global function SURVIVAL_AddSpawnPointGroup
global function SURVIVAL_IsCharacterClassLocked
global function SURVIVAL_IsValidCircleLocation
global function _GetSquadRank
global function JetwashFX
global function Survival_PlayerRespawnedTeammate
global function UpdateDeathBoxHighlight
global function HandleSquadElimination
// these probably doesn't belong here
//----------------------------------
global function Survival_GetMapFloorZ
global function SURVIVAL_GetClosestValidCircleEndLocation
global function SURVIVAL_CalculateAirdropPositions
global function SURVIVAL_AddLootBin
global function SURVIVAL_AddLootGroupRemapping
global function SURVIVAL_DebugLoot
global function Survival_AddCallback_OnAirdropLaunched
global function Survival_CleanupPlayerPermanents
global function Survival_SetCallback_Leviathan_ConsiderLookAtEnt
global function Leviathan_ConsiderLookAtEnt
global function Survival_IsArenaMap

global entity WORKAROUND_DESERTLANDS_TRAIN = null

global function CreateSurvivalDeathBoxForPlayer
global function UpdateMatchSummaryPersistentVars
global function EnemyDownedDialogue
global function TakingFireDialogue
global function GetAllDroppableItems

global function Flowstate_CheckForLv4MagazinesAndRefillAmmo
global function EnemyKilledDialogue

global function SURVIVAL_SetMapCenter
global function SURVIVAL_GetMapCenter
global function SURVIVAL_GetPlaneHeight
global function SURVIVAL_SetPlaneHeight

global function Survival_RunPlaneLogic_Thread
global function Survival_GenerateSingleRandomPlanePath
global function Survival_RunSinglePlanePath_Thread
global function Survival_PlayerDealtDamage
global function Survival_GetPlayerRealm

global function SetPlayerIntroDropSettings
global function ClearPlayerIntroDropSettings

global function EndThreadOn_PlayerChangedClass
global function SignalThatPlayerChangedClass
global function ClientCommand_Flowstate_AssignCustomCharacterFromMenu
global function Survival_SetPlayerHasJumpedOutOfPlane

global function Survival_HasPlayerJumpedOutOfPlane
global function Survival_GetPlayerTimeOnGround
global function Survival_GetPlayerData
global function Survival_OnClientConnected

global function Survival_GetPlaneJumpPointOverMap
global function InformPlayerSquadEliminated
global function Survival_IsPlayerSquadEliminated

global function CodeCallback_KillDamagePlayerOrNPC
global function Survival_AddCallback_OnPlayerKillDamage
global function Survival_AddCallback_OnAttackerSquadWipe
global function Survival_AddCallback_OnAttackerSoloRatEliminated

global function Survival_OnEnterPickLoadout
global function OnPlayerMatchParticipationStarted
global function Survival_OnPrematch
global function Survival_GameStartedPlaying
global function Survival_GameStartedPlaying_Thread
global function Survival_RunCharacterSelection
global function Survival_RunCharacterSelectionNew_Thread
global function GetAppropriateCharacterSelectMusicTrack
global function PlayCharacterSelectMusicToAllPlayersIfNeeded
global function CharacterSelect_OnPlayerConnected

//updated. Cafe
global const float REALBIG_CIRCLE_GRID_RADIUS = 52500
const float PLANE_HEIGHT_REALBIG = 17000.0
const float CLAMP_TO_RING_BUFFER = 400
const float SURVIVAL_PLANE_DROP_RADIUS_MIN = 22000
const string KNOCKED_SOUND = "flesh_bulletimpact_downedshot_3p_vs_3p"

const float SURVIVAL_MINIMAP_ZOOM_DEFAULT = 4.0
const float SURVIVAL_MINIMAP_ZOOM_HALOMOD = 1.5
const float SURVIVAL_MINIMAP_ZOOM_ARENA = 1.0
const string PLAYLISTVAR_ARENA_MINIMAP_ZOOM = "arena_minimap_default_zoom_scale"

//fix debug draws calls
const bool DEBUG_PLANE_PATH = false
const bool DEBUG_PLANE_PATH_LIGHTWEIGHT = false
const bool DEBUG_PLANE_PATH_JUMP = false
const bool PLANE_PATH_DEBUG = false

global float g_DOOR_OPEN_TIME = 0

global struct PlanePathData
{
	vector startPos
	vector endPos
	float totalFlyDuration
	float flyOverMapDuration
	vector clampedPlaneStart
	vector clampedPlaneEnd
	vector centerPos
	vector angles
	float jumpDelay
}

global struct Survival_Plane
{
	entity baseEnt
	entity mover
	entity centerEnt
}

global struct SurvivalPlayerData
{
	int    savedHealth = 100
	int    savedMaxHealth = 100
	int    savedArmor = 0
	bool   hasJumpedOutOfPlane = false
	int    savedTacticalAmmo = 0
	bool   linkSoundPlaying = false
	asset  savedUltimate
	entity swapOnUseItem
	int    squadRank
	bool   xpAwarded = false
	int    pickedUpLootCount = 0
	vector landingOrigin = <0, 0, 0>
	float  landingTime = 0
	bool   hasMatchParticipationStarted = false
	bool   hasMatchParticipationEnded = false
}

// Cache origin/angles when changing class in Firinge Range, to be reapplied after respawning
struct PlayerChangeClassData
{
	vector respawnPos = <0, 0, 0>
	vector respawnAngles = <0, 0, 0>
	bool   respawnIn3P = false
}

struct
{
	table< int, table< int, GameSummarySquadData > >  squadData
	table< int, int >                                 squadRespawnChances
	int gameStartUnixTime = -1
	int numPlayerAtStart
	int numSquadsAtStart

	int gameResultFlags
	int gameScoreFlags

	int functionref() getRemainingSquadsFunction = null
    void functionref( entity, float, float ) leviathanConsiderLookAtEntCallback = null

	#if DEVELOPER
		ItemFlavor ornull DEV_overrideSpawnCharacterOrNull = null
		bool			  DEV_overrideSpawnCharacterSimpleEquip = false
		bool              DEV_overrideSpawnCharacterWithLaunchCharacters = false
	#endif

	table<EncodedEHandle, PlayerChangeClassData>	 playerChangeClassData

	//updated
	vector mapCenter = <0, 0, 0>
	float planeHeight = 0.0
	Survival_Plane plane
	bool shouldFreezeControlsOnPrematch = true
	table<EncodedEHandle, SurvivalPlayerData>        playerData
	table< entity, float >         playerLastDamageSlowTime

	//Callbacks new
	array<void functionref(entity, var, int) >    Callbacks_OnPlayerKillDamage
	array<void functionref(entity, entity) >    Callbacks_OnAttackerSquadWipe
	array<void functionref(entity, entity) >    Callbacks_OnAttackerSoloRatEliminated

	// Character selection
	bool characterLocksLocked = false
	bool characterLocksFinished = false
	bool forceRandomOnNoSelect = false
	array< entity > playersWhoNeedSetupPrematch = []
	array< void functionref(entity, ItemFlavor) > Callbacks_OnPlayerLockedInCharacterCallbacks
	array< void functionref(entity, ItemFlavor) > Callbacks_OnGameAutoSelectedCharacterCallbacks
	bool functionref() Callback_ModeShouldSpawnPlayersDuringCharacterSelect = null
} file

void function GamemodeSurvival_Init()
{
	if(GetCurrentPlaylistVarBool("enable_global_chat", true))
		SetConVarBool("sv_forceChatToTeamOnly", false) //thanks rexx
	else
		SetConVarBool("sv_forceChatToTeamOnly", true)

	Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Generic )
	SurvivalFreefall_Init()
	Sh_ArenaDeathField_Init()
	SurvivalShip_Init()

	FlagInit( "PlaneStartMoving" )
	FlagInit( "PlaneDoorOpen" )
	FlagInit( "PlaneAtLaunchPoint" )
	FlagInit( "SpawnInDropship", false )
	FlagInit( "PlaneDrop_Respawn_SetUseCallback", false )

	RegisterSignal( "CleanupOutsideCircle" )

	AddCallback_OnPlayerKilled( OnPlayerKilled )

	if ( Gamemode() == eGamemodes.SURVIVAL )
		AddCallback_OnPlayerKilled( OnPlayerKilled_DropLoot )

	AddCallback_OnClientConnected( OnClientConnected )
	AddCallback_OnPreClientDisconnected( Survival_OnClientDisconnected )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad_Survival )
	AddCallback_OnPlayerRespawned( Survival_OnPlayerRespawned )

	#if DEVELOPER //uncommented dev defines
		AddClientCommandCallback("forceBleedout", ClientCommand_bleedout)
		AddClientCommandCallback("lsm_restart", ClientCommand_restartServer)
		AddClientCommandCallback("playerRequestsSword", ClientCommand_GiveSword)

		// AddClientCommandCallback("forceChampionScreen", ClientCommand_ForceChampionScreen)
		AddClientCommandCallback("forceGameOverScreen", ClientCommand_ForceGameOverScreen)
		AddClientCommandCallback("forceRingMovement", ClientCommand_ForceRingMovement )

		AddClientCommandCallback("destroyEndScreen", ClientCommand_DestroyEndScreen)
		AddClientCommandCallback("setLegendary", ClientCommand_SetLegendaryWeapon)
		AddClientCommandCallback("giveGoodLoot", ClientCommand_GiveGoodLootToPlayers)
		AddClientCommandCallback("enableGodMode", ClientCommand_EnableDemigod)
		AddClientCommandCallback("disableGodMode", ClientCommand_EnableDemigod)
	#endif

	FillSkyWithClouds()

	AddCallback_GameStateEnter(
		eGameState.Playing,
		void function()
		{
			thread Sequence_Playing()
		}
	)

	AddCallback_GameStatePostEnter( eGameState.PickLoadout, Survival_RunCharacterSelection )
	AddCallback_GameStatePostEnter( eGameState.Prematch, Survival_OnPrematch )
	AddCallback_GameStateEnter( eGameState.Playing, Survival_GameStartedPlaying )
	AddCallback_GameStateEnter( eGameState.PickLoadout, Survival_OnEnterPickLoadout )

	if( GetCurrentPlaylistVarBool( "deathfield_starts_in_prematch", false ) )
		thread SURVIVAL_RunArenaDeathField()

	// Halo audios, make callback and move when fixed
	// if( Playlist() == ePlaylists.fs_haloMod_survival )
	// {
		// BannerAssets_SetAllGroupsFunc
		// (
			// void function()
			// {
				// BannerAssets_RegisterAudioGroup
				// (
					// "halo_audio",
					// false //(audio interruptable, false = queued for audio from this group. )
				// )
			// }
		// )

		// BannerAssets_SetAllAssetsFunc
		// (
			// void function()
			// {
				// array<string> haloAudio = WorldDrawAsset_GetAssetArrayByCategory( "halo" )

				// foreach( assetRef in haloAudio )
				// {
					// BannerAssets_GroupAppendAsset
					// (
						// "halo_audio",
						// WorldDrawAsset_AssetRefToID( assetRef )
					// )
				// }
			// }
		// )

		// BannerAssets_Init()

		// //Move faster while adsing
		// AddCallback_OnPlayerZoomIn( FS_HaloMod_OnPlayerZoomIn )
		// AddCallback_OnPlayerZoomOut( FS_HaloMod_OnPlayerZoomOut )
	// }
}

#if DEVELOPER
bool function ClientCommand_GreenWall(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	entity shieldWallFX = CreatePropDynamic( $"mdl/fx/pilot_shield_wall_01.rmdl", player.GetOrigin() + <0,0,230> - player.GetForwardVector() * 2800, ClampAngles( <0,player.GetAngles().y,90> + <0,180,0> ) )
	// shieldWallFX.SetModelScale( 50 )
	shieldWallFX.kv.renderamt = 0
	shieldWallFX.kv.rendercolor = "0, 255, 0"
	shieldWallFX.kv.modelscale = 35
	return true
}

bool function ClientCommand_BecomeRhapsody(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	player.SetBodyModelOverride( $"mdl/Humans/pilots/w_rhapsody.rmdl" )
	player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_rhapsody.rmdl" )
	player.TakeOffhandWeapon(OFFHAND_TACTICAL)
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)
	TakeAllPassives( player )


	// GivePassive(player, ePassives.PAS_SLIPSTREAM)
	return true
}

bool function ClientCommand_BecomeFade(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	player.SetBodyModelOverride( $"mdl/Humans/pilots/w_phantom.rmdl" )
	player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_phantom.rmdl" )
	player.TakeOffhandWeapon(OFFHAND_TACTICAL)
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)
	TakeAllPassives( player )

	player.GiveOffhandWeapon( "mp_ability_phase_chamber", OFFHAND_ULTIMATE)
	player.GiveOffhandWeapon( "mp_ability_phase_rewind", OFFHAND_TACTICAL)
	GivePassive(player, ePassives.PAS_SLIPSTREAM)
	return true
}

bool function ClientCommand_EnableDemigod(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	EnableDemigod( player )
	return true
}

bool function ClientCommand_GiveGoodLootToPlayers(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	foreach( int k, entity bot in GetPlayerArray() )
	{
		array<string> lootRefs = CreateLootForFlyerDeathBox( null, true )
		ResetPlayerInventory( bot )
		lootRefs.fastremovebyvalue( "blank" )
		foreach( ref in lootRefs )
		{
			if ( ref == "" )
				continue

			LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )
			if ( data.lootType == eLootType.MAINWEAPON )
			{
				player.GiveWeapon( ref, WEAPON_INVENTORY_SLOT_ANY, [] )
			} else
			{
				SURVIVAL_AddToPlayerInventory( bot, ref)
			}
		}
	}

	return false
}

bool function ClientCommand_SetLegendaryWeapon(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 || args.len() != 2)
		return false

	int index2 = -1

	if( args.len() > 1 )
		index2 = args[1].tointeger()

	//FS_SetLegendarySkinIndex( player, args[0].tointeger(), index2 )

	return true
}

bool function ClientCommand_GiveSword(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	GiveSword( player )
	return true
}

bool function ClientCommand_bleedout(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	Bleedout_StartPlayerBleedout( player, player, null )
	return true
}

bool function ClientCommand_restartServer(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	GameRules_ChangeMap( GetMapName(), GetCurrentPlaylistName() )
	return true
}

bool function ClientCommand_ForceRingMovement(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	thread function () : ( player )
	{
		FlagSet( "DeathCircleActive" )
		svGlobal.levelEnt.Signal( "DeathField_ShrinkNow" )
		FlagClear( "DeathFieldPaused" )
	}()

	return true
}

bool function ClientCommand_ForceChampionScreen(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	Remote_CallFunction_NonReplay( player, "ServerCallback_MatchEndAnnouncement", true, gp()[0].GetTeam() )
	ToggleHudForPlayer( player )

	return true
}

bool function ClientCommand_ForceGameOverScreen(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	Remote_CallFunction_NonReplay( player, "ServerCallback_MatchEndAnnouncement", true, gp()[0].GetTeam() + 1 )
	ToggleHudForPlayer( player )

	return true
}

bool function ClientCommand_DestroyEndScreen(entity player, array<string> args)
{
	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	//Remote_CallFunction_NonReplay( player, "ServerCallback_DestroyEndAnnouncement" )
	Remote_CallFunction_ByRef( player, "ServerCallback_DestroyEndAnnouncement" )
	ToggleHudForPlayer( player )

	return true
}
#endif

void function EntitiesDidLoad_Survival()
{
	if ( file.planeHeight == 0 )
		file.planeHeight = PLANE_HEIGHT_REALBIG

	//defaulting to false crashes survival game modes expecting a plane
	if( GetCurrentPlaylistVarBool( "jump_from_plane_enabled", true ) || GetCurrentPlaylistVarBool( "force_plane_to_spawn_without_players", false ) )
		thread Survival_RunPlaneLogic_Thread( Survival_GenerateSingleRandomPlanePath, Survival_RunSinglePlanePath_Thread, false )
	else
	{
		if ( GetCurrentPlaylistVarBool( "survival_deathfield_enabled", true ) )
			FlagSet( "DeathCircleActive" )

		if ( GetCurrentPlaylistVarBool( "sur_circle_start_paused", false ) )
		{
			FlagSet( "DeathFieldPaused" )
		}
	}
}

void function Survival_RunPlaneLogic_Thread( array< PlanePathData > functionref( bool, int = 0 ) generatePlanePathFunc, void functionref( array< PlanePathData >, int = 0 ) runPlanePathFunc, bool beQuick, int planeInt = 0 )
{
	if ( IsTestMap() )
		FlagSet( "DeathCircleActive" )

	if ( IsValid( file.plane.baseEnt ) )
		file.plane.baseEnt.Destroy()
	if ( IsValid( file.plane.centerEnt ) )
		file.plane.centerEnt.Destroy()
	if ( IsValid( file.plane.mover ) )
		file.plane.mover.Destroy()

	array< PlanePathData > pathData = generatePlanePathFunc( beQuick, planeInt )
	thread runPlanePathFunc( pathData, planeInt )
}


array< PlanePathData > function Survival_GenerateSingleRandomPlanePath( bool beQuick, int unusedInt = 0 )
{
	printt( "Generating path for survival plane" )
	PlanePathData result

	table<string, bool> e
	e[ "trace_test" ] <- false
	const int MAX_PLANE_PATH_TRIES = 50
	int numTries
	bool dev_numTriesFailed

	vector startPos
	vector endPos
	vector angles
	vector centerPos

	bool clampToRing = GetCurrentPlaylistVarBool( "dropship_bounds_clamp_to_ring", false )

	entity fakePlane = CreatePropDynamic( SURVIVAL_PLANE_MODEL )
	while ( !e[ "trace_test" ] )
	{
		float mapAngleRotation = GetCurrentPlaylistVarFloat( "survival_plane_angle_deviation", 0.0 )

		// Get the basic angle of approach
		int baseAngle            = RandomIntRange( 0, 4 ) //RandomIntRangeForPlanePath( 0, 4 ) // 0, 90, 180, 270
		float tightnessFactor    =  GetCurrentPlaylistVarFloat( "survival_plane_start_angle_tightness", 1.5 )
		float baseAngleDeviation = pow( RandomFloatRange( 0.0, 1.0 ), tightnessFactor ) //RandomFloatRangeForPlanePath( 0.0, 1.0 )
		if ( CoinFlip() )
			baseAngleDeviation = -1 * baseAngleDeviation

		float f_baseAngle = 90.0 * float( baseAngle ) + mapAngleRotation
		float startAngleMax = GetCurrentPlaylistVarFloat( "survival_plane_start_angle_max", 40.0 )
		angles = AnglesCompose( < 0.0, f_baseAngle, 0.0 >, < 0.0, baseAngleDeviation * startAngleMax, 0.0 > )

		// Generate the starting position
		vector fwd         = AnglesToForward( angles )

		// Figure out the "center" position - a position near the center of the map we want to go through
		float maxDeviation = GetCurrentPlaylistVarFloat( "survival_plane_center_deviation_max", 12500 )
		float centerTightnessScale = GetCurrentPlaylistVarFloat( "survival_plane_center_tightness", 0.4 )
		float maxDeviationScale    = (1.0 - fabs( baseAngleDeviation ) * centerTightnessScale )
		maxDeviationScale = clamp( maxDeviationScale, 0.0, 1.0 )
		maxDeviation      = maxDeviation * maxDeviationScale

		float moveAmount = RandomFloatRange( 0.0, maxDeviation ) //RandomFloatRangeForPlanePath( 0.0, maxDeviation )
		vector moveVec = VectorRotate( <moveAmount, 0, 0>, <0, RandomFloatRange( -180, 180 ), 0>)
		vector startCenter = file.mapCenter
		float ringRadius = REALBIG_CIRCLE_GRID_RADIUS

		if ( clampToRing )
		{
			startCenter = SURVIVAL_GetDeathFieldData().center
			ringRadius = SURVIVAL_GetDeathFieldData().currentRadius - CLAMP_TO_RING_BUFFER
		}

		centerPos = startCenter + <moveVec.x, moveVec.y, file.planeHeight>
		result.centerPos = centerPos

		startPos  = (fwd * -1 * ringRadius) + <centerPos.x, centerPos.y, file.planeHeight>

		// Calculate the ending position, given we want to go from the starting spot
		vector startToCenterPosNorm = Normalize( centerPos - startPos )
		vector startToMapCenter = <startCenter.x, startCenter.y, file.planeHeight> - startPos
		float dot = DotProduct( startToMapCenter, startToCenterPosNorm )
		endPos = startPos + startToCenterPosNorm * 2.0 * dot
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
			dev_numTriesFailed = true
			Warning( "%s() - EXCEEDED %d PLANE PATH TRIES! Taking most recent plane path.", FUNC_NAME(), MAX_PLANE_PATH_TRIES )
			break
		}
	}

	fakePlane.Destroy()

	float SKYBOX_BUFFER        = 6000 // Todo: eventually we should just do a trace up and down the plane path and find the skybox instead of assuming it's 6000 units from max bounds

	vector jumpStart = Survival_GetPlaneJumpPointOverMap( startPos, endPos )
	vector jumpEnd   = Survival_GetPlaneJumpPointOverMap( endPos, startPos )

	// Clamp the jump boundaries to world bounds, like we do with the path below
	LineSegment jumpBounds = ClampLineSegmentToWorldBounds2D( jumpStart, jumpEnd, SKYBOX_BUFFER )
	jumpStart = jumpBounds.start
	jumpEnd = jumpBounds.end

	vector planeVec  = Normalize( jumpEnd - jumpStart )

	result.startPos = jumpStart
	result.endPos = jumpEnd

	float flyOverMapDist  = Distance( jumpStart, jumpEnd )
	float flyOverMapSpeed = GetCurrentPlaylistVarFloat( "survival_plane_move_speed", 2000.0 )
	result.flyOverMapDuration = flyOverMapDist / flyOverMapSpeed
	float jumpDelay              = (beQuick ? 3.0 : GetCurrentPlaylistVarFloat( "survival_plane_jump_delay", 9.0 ))
	float unitsBeforeJumpAllowed = flyOverMapSpeed * jumpDelay
	float planeLeaveMapDuration  = jumpDelay * GetCurrentPlaylistVarFloat( "survival_plane_leave_map_duration_multiplier", 3.0 )
	float unitsToLeaveMap        = flyOverMapSpeed * planeLeaveMapDuration

	vector planeStart = jumpStart + (planeVec * -unitsBeforeJumpAllowed)
	vector planeEnd   = jumpEnd + (planeVec * unitsToLeaveMap)

	// Clamp the plane start and end path to max world coords
	if ( PLANE_PATH_DEBUG )
	{
		printt( "planeStart:", planeStart )
		printt( "planeEnd:", planeEnd )
	}
	#if DEBUG_PLANE_PATH
		// DebugDrawLine( planeStart, planeEnd, COLOR_YELLOW, true, 10.0 )
	#endif
	LineSegment lineSegment    = ClampLineSegmentToWorldBounds2D( planeStart, planeEnd, SKYBOX_BUFFER )
	vector clampedPlaneStart   = lineSegment.start
	vector clampedPlaneEnd     = lineSegment.end

	if ( PLANE_PATH_DEBUG )
	{
		printt( "clampedPlaneStart:", clampedPlaneStart )
		printt( "clampedPlaneEnd:", clampedPlaneEnd )
	}
	#if DEBUG_PLANE_PATH || DEBUG_PLANE_PATH_LIGHTWEIGHT
		// if ( !dev_numTriesFailed )
			// DebugDrawLine( clampedPlaneStart - <0, 0, 10000>, clampedPlaneEnd - <0, 0, 10000>, COLOR_GREEN, true, 240.0 )
	#endif

	// We may need to shorten the waittimes due to line clamping making the line shorter before and after the playable space
	float actualUnitsBeforeJumpAllowed = Distance( clampedPlaneStart, jumpStart )
	float jumpDelayFrac                = actualUnitsBeforeJumpAllowed / unitsBeforeJumpAllowed
	jumpDelay *= jumpDelayFrac
	result.jumpDelay = jumpDelay

	float actualUnitsToLeaveMap = Distance( jumpEnd, clampedPlaneEnd )
	float leaveMapFrac          = actualUnitsToLeaveMap / unitsToLeaveMap
	planeLeaveMapDuration *= leaveMapFrac

	result.clampedPlaneStart = clampedPlaneStart
	result.clampedPlaneEnd = clampedPlaneEnd

	result.totalFlyDuration = result.flyOverMapDuration + jumpDelay + planeLeaveMapDuration

	// file.planeJumpStartPos = result.clampedPlaneStart
	// file.planeJumpEndPos   = result.clampedPlaneEnd

	if ( PLANE_PATH_DEBUG )
	{
		printt( "flyOverMapDuration:", result.flyOverMapDuration )
		printt( "totalFlyDuration:", result.totalFlyDuration )
	}
	#if DEBUG_PLANE_PATH || DEBUG_PLANE_PATH_JUMP
		if ( PLANE_PATH_DEBUG )
		{
			printt( "jumpDelayFrac:", jumpDelayFrac )
			printt( "leaveMapFrac:", leaveMapFrac )
		}
	#endif

	return [ result ]
}

const int FLIGHTPATH_HULL = HULL_TITAN

vector function Survival_GetPlaneJumpPointOverMap( vector pathStart, vector pathEnd )
{
	float INCREMENT_DIST    = 2000.0
	float SIDE_CHECK_DIST   = 4000.0
	vector pointOnPlanePath = pathStart
	vector forwardVec       = Normalize( pathEnd - pathStart )
	vector rightVec         = AnglesToRight( VectorToAngles( forwardVec ) )

	while( true )
	{
		for ( int i = 0 ; i < 3 ; i++ )
		{
			vector traceStart = pointOnPlanePath
			if ( i == 1 )
				traceStart += rightVec * SIDE_CHECK_DIST
			if ( i == 2 )
				traceStart -= rightVec * SIDE_CHECK_DIST

			vector mapCenter = SURVIVAL_GetMapCenter()
			if ( Distance2D( pointOnPlanePath, mapCenter ) < SURVIVAL_PLANE_DROP_RADIUS_MIN )
			{
				// DebugDrawCircle( mapCenter, <0, 0, 1>, SURVIVAL_PLANE_DROP_RADIUS_MIN, COLOR_RED, true, 10.0 )
				// DebugDrawLine( pointOnPlanePath, pointOnPlanePath - <0, 0, 10000>, COLOR_RED, true, 10.0 )
				return pointOnPlanePath
			}

			vector traceEnd    = <traceStart.x, traceStart.y, -MAP_EXTENTS>
			TraceResults trace = TraceLine( traceStart, traceEnd, [], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )
			if ( trace.fraction < 1.0 && !trace.hitSky && !trace.startSolid )
			{
				vector ornull closestTitanNavMesh = NavMesh_ClampPointForHullWithExtents( trace.endPos, FLIGHTPATH_HULL, <1024, 1024, 1024> )

				#if DEBUG_PLANE_PATH
					DebugDrawLine( traceStart, trace.endPos, COLOR_BLUE, true, 10.0 )
					if ( closestTitanNavMesh == null )
					{
						DebugDrawSphere( trace.endPos, 256.0, COLOR_RED, true, 10.0 )
					}
					else
					{
						expect vector(closestTitanNavMesh)
						// DebugDrawLine( trace.endPos, closestTitanNavMesh, COLOR_GREEN, true, 10.0 )
						// DebugDrawSphere( closestTitanNavMesh, 256.0, COLOR_GREEN, true, 10.0 )
					}
				#endif

				if ( closestTitanNavMesh != null )
				{
					expect vector(closestTitanNavMesh)
					return pointOnPlanePath
				}
			}
		}

		if ( Distance( pointOnPlanePath, pathEnd ) < INCREMENT_DIST )
			break

		pointOnPlanePath = pointOnPlanePath + (forwardVec * INCREMENT_DIST)
	}

	return pathStart
}

void function Survival_RunSinglePlanePath_Thread( array< PlanePathData > paths, int planeIndex = 0 )
{
	FlagClear( "PlaneStartMoving" )
	FlagClear( "PlaneDoorOpen" )
	FlagClear( "PlaneAtLaunchPoint" )

	PlanePathData path = paths[0] // This function should only run one plane so just use index 0

	printt( "Survival_RunSinglePlanePath_Thread", path.startPos )

	entity pathCenter = CreateEntity( "prop_script" )
	pathCenter.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	pathCenter.kv.fadedist    = -1
	pathCenter.kv.renderamt   = 255
	pathCenter.kv.rendercolor = "255 255 255"
	pathCenter.kv.solid       = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	pathCenter.SetOrigin( path.centerPos )
	pathCenter.SetAngles( path.angles )
	pathCenter.NotSolid()
	pathCenter.Hide()
	pathCenter.DisableHibernation()
	pathCenter.Minimap_SetObjectScale( 1 )
	pathCenter.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	pathCenter.Minimap_SetClampToEdge( true )
	SetTargetName( pathCenter, "pathCenterEnt" )
	DispatchSpawn( pathCenter )
	file.plane.centerEnt       = pathCenter

	Sur_SetPlaneCenterEnt( pathCenter )

	entity mover = CreateEntity( "script_mover" )
	mover.e.moverPathPrecached   = true // HACK so it doesn't get deleted
	mover.kv.solid               = 6
	mover.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	mover.kv.SpawnAsPhysicsMover = 0
	mover.SetOrigin( path.clampedPlaneStart )
	mover.SetAngles( path.angles )
	mover.NotSolid()
	DispatchSpawn( mover )
	file.plane.mover              = mover

	entity plane = CreateEntity( "prop_script" )
	plane.SetValueForModelKey( SURVIVAL_PLANE_MODEL )
	plane.kv.fadedist    = -1
	plane.kv.renderamt   = 255
	plane.kv.rendercolor = "255 255 255"
	plane.kv.solid       = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	plane.SetOrigin( path.clampedPlaneStart )
	plane.SetAngles( path.angles )
	plane.NotSolid()
	plane.DisableHibernation()
	plane.Minimap_SetObjectScale( 1 )
	plane.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	plane.Minimap_SetClampToEdge( false )
	SetTargetName( plane, SURVIVAL_PLANE_NAME )

	DispatchSpawn( plane )
	plane.SetParent( mover )
	plane.Show()

	if( Playlist() == ePlaylists.fs_haloMod_survival )
	{
		entity pelican = CreateEntity( "prop_script" )
		pelican.kv.solid = 0
		pelican.kv.fadedist = -1
		pelican.SetValueForModelKey( $"mdl/flowstate_custom/pelican.rmdl" )
		pelican.kv.SpawnAsPhysicsMover = 0
		pelican.SetOrigin( path.clampedPlaneStart )
		pelican.SetAngles( path.angles )
		DispatchSpawn( pelican )
		pelican.SetParent( plane )
		pelican.SetModelScale( 13.0 )
		pelican.SetAbsOrigin( path.clampedPlaneStart + <0,0,-100> )
		plane.Hide()
	}

	file.plane.baseEnt           = plane

	plane.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			printt( "plane destroyed" )
			if ( IsValid( file.plane.baseEnt ) )
			{
				KickEveryoneOutOfPlane( file.plane.baseEnt ) // This is defensive, it should never happen because we call the same command when the plane leaves the playable space
				file.plane.baseEnt.MakeInvisible()
				file.plane.baseEnt.Minimap_Hide( 0, null )
			}
			if ( IsValid( file.plane.centerEnt ) )
				file.plane.centerEnt.Destroy()
			if ( IsValid( file.plane.mover ) )
			{
				StopSoundOnEntity( file.plane.mover, "Survival_DropSequence_Pegasus_Engine" )
				file.plane.mover.Hide()
			}
		}
	)

	Sur_SetPlaneEnt( plane )

	//if ( IsTestMap() )
		// FlagSet( "PlaneStartMoving" )

	file.plane.baseEnt.MakeInvisible()
	FlagWait( "PlaneStartMoving" )
	file.plane.baseEnt.MakeVisible()

	// StatsHook_SetPlaneData( path.clampedPlaneStart, path.clampedPlaneEnd, path.totalFlyDuration )
	SetGlobalNetTime( "PlaneDoorsOpenTime", Time() + path.jumpDelay )
	SetGlobalNetTime( "PlaneDoorsCloseTime", Time() + path.totalFlyDuration )

	thread OpenAndClosePlaneDoor( plane, path.jumpDelay, path.flyOverMapDuration )

	EmitSoundOnEntity( file.plane.mover, "Survival_DropSequence_Pegasus_Engine" )

	thread PlaneAttractLeviathan( plane, file.plane.centerEnt )

	mover.NonPhysicsMoveTo( path.clampedPlaneEnd, path.totalFlyDuration, 0, 0 )
	printt( "plane started moving", path.totalFlyDuration )
	wait path.totalFlyDuration

	if ( GetCurrentPlaylistVarBool( "survival_deathfield_enabled", true ) )
		FlagSet( "DeathCircleActive" )

	if ( GetCurrentPlaylistVarBool( "sur_circle_start_paused", false ) )
	{
		FlagSet( "DeathFieldPaused" )
	}
}

void function PlaneAttractLeviathan( entity plane, entity entDestroyedWhenPlaneIsDone )
{
	plane.EndSignal( "OnDestroy" )
	entDestroyedWhenPlaneIsDone.EndSignal( "OnDestroy" )

	for ( ; ; )
	{
		wait RandomFloatRange( 3.0, 8.0 )
		Leviathan_ConsiderLookAtEnt( plane, RandomFloatRange( 5, 20 ), 0.3 )
	}
}

void function OpenAndClosePlaneDoor( entity plane, float openDelay, float openDuration )
{
	EndSignal( plane, "OnDestroy" )

	if ( openDelay > 2.5 )
	{
		wait openDelay - 2.5
		EmitSoundOnEntity( plane, "Survival_DropSequence_LaunchDoorOpen" )
		EmitSoundOnEntity( plane, "Survival_DropSequence_Pegasus_Wind" )
		wait 2.5
	}
	else
	{
		wait openDelay
		EmitSoundOnEntity( plane, "Survival_DropSequence_LaunchDoorOpen" )
	}

	FlagSet( "PlaneDoorOpen" )

	g_DOOR_OPEN_TIME = Time()

	wait openDuration

	FlagSet( "PlaneAtLaunchPoint" )

	KickEveryoneOutOfPlane( plane )
}
// #if DEVELOPER
bool function ClientCommand_Flowstate_AssignCustomCharacterFromMenu(entity player, array<string> args)
{
	if( !IsValid(player) || !IsAlive( player) || args.len() != 1 )
		return false

	if ( GetConVarInt( "sv_cheats" ) != 1 )
		return false

	CharacterSelect_AssignCharacter( ToEHI( player ), GetAllCharacters()[5] )

	ItemFlavor playerCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	asset characterSetFile = CharacterClass_GetSetFile( playerCharacter )
	player.SetPlayerSettingsWithMods( characterSetFile, [] )

	player.TakeOffhandWeapon(OFFHAND_TACTICAL)
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)
	TakeAllPassives(player)

	switch( args[0] )
	{
		case "0":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_master_chief.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_master_chief.rmdl" )
		break

		/*case "1":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_blisk.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/pov_blisk.rmdl" )
		break*/

		case "2":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_phantom.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_phantom.rmdl" )
		break

		case "3":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_amogino.rmdl" )
		player.SetArmsModelOverride( $"mdl/dev/empty_model.rmdl" )
		break

		// case "4":
		// player.SetBodyModelOverride( $"mdl/Humans/pilots/w_petergriffing.rmdl" )
		// player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_petergriffing.rmdl" )
		// break

		case "5":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_rhapsody.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_rhapsody.rmdl" )
		break

		/*case "6":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_ash_legacy.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/pov_ash_legacy.rmdl" )
		break*/

		// case "7":
		// player.SetBodyModelOverride( $"mdl/Humans/pilots/w_cj.rmdl" )
		// player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_amogino.rmdl" )
		// break

		/*case "8":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_jackcooper.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_jackcooper.rmdl" )
		break

		case "9":
		player.SetBodyModelOverride( $"mdl/Humans/pilots/pilot_medium_loba.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/pov_pilot_medium_loba.rmdl" )
		break*/

		// case "10":
		// player.SetBodyModelOverride( $"mdl/Humans/pilots/pilot_heavy_revenant.rmdl" )
		// player.SetArmsModelOverride( $"mdl/Humans/pilots/pov_pilot_heavy_revenant.rmdl" )
		// break

		// case "11": //loba ss
		// player.SetBodyModelOverride( $"mdl/Humans/pilots/pilot_medium_loba_swimsuit.rmdl" )
		// player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_loba_swimsuit.rmdl" )
		// break

		case "12": // ballistic
		player.SetBodyModelOverride( $"mdl/Humans/pilots/ballistic_base_w.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ballistic_base_v.rmdl" )
		break

		/*case "13": // mrvn
		player.SetBodyModelOverride( $"mdl/flowstate_custom/w_marvin.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_amogino.rmdl" )
		break*/

		// case "14": // gojo
		// player.SetBodyModelOverride( $"mdl/flowstate_custom/w_gojo.rmdl" )
		// player.SetArmsModelOverride( $"mdl/flowstate_custom/ptpov_gojo.rmdl" )
		// break

		// case "15": // naruto
		// player.SetBodyModelOverride( $"mdl/flowstate_custom/w_naruto.rmdl" )
		// player.SetArmsModelOverride( $"mdl/flowstate_custom/ptpov_naruto.rmdl" )
		// break

		case "16": // pete
		player.SetBodyModelOverride( $"mdl/flowstate_custom/w_pete_mri.rmdl" )
		player.SetArmsModelOverride( $"mdl/flowstate_custom/ptpov_pete_mri.rmdl" )
		break
	}

	// player.TakeOffhandWeapon(OFFHAND_MELEE)
	// player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	// player.GiveWeapon( "mp_weapon_vctblue_primary", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )
	// player.GiveOffhandWeapon( "melee_vctblue", OFFHAND_MELEE, [] )

	return true
}
// #endif

void function Survival_SetCallback_Leviathan_ConsiderLookAtEnt( void functionref( entity, float, float ) callback )
{
	file.leviathanConsiderLookAtEntCallback = callback
}

void function Leviathan_ConsiderLookAtEnt( entity ent, float duration, float careChance )
{
	if ( file.leviathanConsiderLookAtEntCallback != null )
		thread file.leviathanConsiderLookAtEntCallback( ent, duration, careChance )
}

void function OnPlayerMatchParticipationStarted( entity player )
{
	Assert( !player.p.hasMatchParticipationStarted )
	Assert( !player.p.hasMatchParticipationEnded )

	printt( "OnPlayerMatchParticipationStarted " + player )

	if ( player.p.battlePassBoost < GetPlayerBattlePassBoost( player ) )
		player.p.battlePassBoost = GetPlayerBattlePassBoost( player )

	player.p.hasMatchParticipationStarted = true
}

void function Survival_OnEnterPickLoadout()
{
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !player.p.hasMatchParticipationStarted )
			OnPlayerMatchParticipationStarted( player )
	}
}

void function Survival_OnPrematch()
{
	SetCommentaryEnabled( true )

	GameRules_MarkGameStatePrematchEnding()
	printt( "startTime: " + GetGameStartTime() + " - " + Time() )

	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) || !IsAlive( player ) )
			continue

		Survival_PlayerCharacterSetup( player, Survival_ValidateAndGetCharacterClass( player ) )
		SURVIVAL_SetDefaultPlayerSettings( player )
	}

	if ( IsRoundBased() )
	{
		if( GetRoundsPlayed() > 0 )
		{
			foreach ( entity player in GetPlayerArray() )
			{
				player.SetInvulnerable()
				player.p.doomedEnemies.clear()
			}

			SURVIVAL_RoundStartLootCleanup()
			//DestroyAllLootBins()
			//CleanupAllPlayerPermanents()
			//SURVIVAL_ResetAllDoors()
			//SURVIVAL_PopulateSpecialZones()

			//SURVIVAL_ChooseLootLocations()
		}
		else
		{
			foreach ( entity player in GetPlayerArray() )
			{
				player.StopObserverMode()
			}
		}
	}

	if( GetCurrentPlaylistVarBool( "deathfield_starts_in_prematch", false ) )
		thread SURVIVAL_RunArenaDeathField()
}

void function Survival_GameStartedPlaying()
{
	thread Survival_GameStartedPlaying_Thread()
}

void function Survival_GameStartedPlaying_Thread()
{
	file.gameStartUnixTime = GetUnixTimestamp() // todo(dw): GMT?

	if( !GetCurrentPlaylistVarBool( "deathfield_starts_in_prematch", false ) )
		thread SURVIVAL_RunArenaDeathField()

	if( Survival_AirdroppedCarePackagesEnabled() )
		thread AirdropLogic()

	FlagClear( "staging_fx_enabled" )


	// Set settings for the drop-in
	foreach ( entity player in GetPlayerArray() )
	{
		player.StopObserverMode()
		Survival_ClearPrematchSettings( player )

		bool shouldSetDropSettings = true

			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
				shouldSetDropSettings = false


			if ( GameMode_IsActive( eGameModes.CONTROL ) )
				shouldSetDropSettings = false

		if ( shouldSetDropSettings )
				SetPlayerIntroDropSettings( player )
	}

	if ( GetCurrentPlaylistVarBool( "bots_skydive_to_safezone_center", false ) )
		BotsSetSkydiveTargetPos( GetDeathfieldFinalCenter( Survival_Loot_GetDefaultRealm() ) )

	// Do drop-in of choice, or spawn on ground by default
	//--------------------------------------------------------

	if ( Survival_IsPlaneEnabled() )
	{
		waitthread Survival_PutPlayersInPlane()

		FlagSet( "PlaneStartMoving" )
	}
	else if ( ( GetCurrentPlaylistVarBool( "poiplayerspawning_exists", false )) )
	{
		//POIPlayerSpawning_SpawnPlayers()
	}

	else if ( ForcedSpawn_UseForcedSpawning() )
	{
		//waitthread ForcedSpawn_SpawnAllPlayers()
	}

	else if ( GetCurrentPlaylistVarInt( "survival_squad_spawn_near_loot", 0 ) == 1 )
	{
		//thread SpawnPlayersOnGroundWithSquadNearLoot()
	}
	else if ( GetCurrentPlaylistVarBool( "survival_custom_mode_jump_plane_override", false ) )
	{
		FlagSet( "DeathCircleActive" )
	}
	else
	{
		// If a mode is setting when the deathfield starts manually, don't set the flag here but still clear drop settings (since plane is not enabled )
		//if ( !Deathfield_GetHasCustomStart() )
		//	FlagSet( "DeathCircleActive" )

		foreach ( entity player in GetPlayerArray() )
			ClearPlayerIntroDropSettings( player )
	}

	UpdatePlayerCounts()
	if ( IsPVEMode() )
	{
		file.numPlayerAtStart = GetPlayerArray().len()
		file.numSquadsAtStart = GetNumTeamsExisting()
	}
	else
	{
		file.numPlayerAtStart = GetGlobalNetInt( "livingPlayerCount" )
		file.numSquadsAtStart = Survival_GetRemainingSquadsCount()
	}

	int count = 0
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) || player == null )
			continue

		count++
		player.p.survivalAliveStartTime = Time()

		if ( ! IsRoundBased() || GetRoundsPlayed() == 0 )
		{
			player.p.survivalMatchStartTime = Time()
			GameSummary_MatchStart( player )
			// run this again now that we have player character locked in
			if ( !player.IsBot() )
			{
				string characterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() ) )
				TelemetryEvent( "charSel.pick." + characterName, 1 )
			}
		}
		if ( count % 15 == 0 ) // spread this out over a few frames when there are a lot of players
			WaitFrame()
	}

	FlagSet( "PlayersSpawnedInArena" )
}

void function GameSummary_MatchStart( entity player )
{
	// Don't run this if you've just connected to a server and haven't started playing yet.
	// This is needed because this is called on client connect in dev when we add bots mid-game, or connect a client for testing
	//if ( GetGameState() < eGameState.Playing )
	//	return

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

	// Player's squad data for EOG
	GameSummarySquadData data
	data.playerName               = player.GetPlayerNameOriginal()
	data.character                = character
	data.eHandle                  = player.GetEncodedEHandle()
	data.survivalTime             = 0
	data.kills                    = 0
	data.playerKills              = {}
	data.assists				  = 0
	data.knockdowns				  = 0
	data.damageDealt              = 0
	data.revivesGiven             = 0
	data.platformUid          	  = player.GetPINNucleusId()
	data.pid                      = player.GetPINNucleusPid()
	data.nucleus                  = player.GetPINNucleusId()
	data.hardware                 = player.GetHardware()
	data.isUsingSteam             = true
	data.optOutOfSendingSquadInfo = player.IsBot() || (player.GetPersistentVarAsInt( "matchPreferences" ) & eMatchPreferenceFlags.LAST_SQUAD_INVITE_OPT_OUT) == 1
	data.displayData3IsTime		  = true

	// this block could be improved and made more generic / mode-agnostic, but it's a challenge to know when to reliably set some of these values
	// possibly could have a generic "match start" callback function that handles this...








		if ( GameMode_IsActive( eGameModes.CONTROL ) )
		{
			data.displayData3IsTime = false
			UpdatePlayerCounts()
			// do this here because we don't spawn players until match start.
			file.numPlayerAtStart = GetGlobalNetInt( "livingPlayerCount" )
		}


	// For alliance modes, treat the alliances as starting squads for squad count
	if ( AllianceProximity_IsUsingAlliances() )
		file.numSquadsAtStart = AllianceProximity_GetMaxNumAlliances()

	// end refactor block

	int teamIndex       = player.GetTeam()
	int teamMemberIndex = player.GetTeamMemberIndex()
	if ( !(teamIndex in file.squadData) )
		file.squadData[ teamIndex ] <- {}

	if ( !(teamIndex in file.squadRespawnChances) )
		file.squadRespawnChances[ teamIndex ] <- GetCurrentPlaylistVarInt( "squad_respawn_chances", 3 )

	file.squadData[ teamIndex ][ teamMemberIndex ] <- data

	player.p.survivalAliveStartTime = Time() // initialize this here to catch late connecting players
	player.p.survivalMatchStartTime = Time() // initialize this here to catch late connecting players

	//TODO convert to callback later
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
	{
		Sh_Rank_GameSummary_MatchStart ( player )
	}

	// Clear all game summary data from previous match
	player.SetPersistentVar( "lastGameRank", 0 )
	player.SetPersistentVar( "lastGamePlayers", file.numPlayerAtStart )
	player.SetPersistentVar( "lastGameSquads", file.numSquadsAtStart )
	player.SetPersistentVar( "lastGameResultFlags", file.gameResultFlags )
	player.SetPersistentVar( "lastGameScoreFlags", file.gameScoreFlags )

	#if DEVELOPER
		printt( "PD: lastGameRank", 0 )
		printt( "PD: lastGamePlayers", file.numPlayerAtStart )
		printt( "PD: lastGameSquads", file.numSquadsAtStart )
		printt( "PD: lastGameResultFlags", file.gameResultFlags )
		printt( "PD: lastGameScoreFlags", file.gameScoreFlags )
	#endif

	int maxTrackedSquadMembers = PersistenceGetArrayCount( "lastGameSquadStats" )
	for ( int i = 0 ; i < maxTrackedSquadMembers ; i++ )
	{
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].playerName", "" )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].eHandle", -1 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].survivalTime", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].kills", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].assists", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].knockdowns", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].damageDealt", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].revivesGiven", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].respawnsGiven", 0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].platformUid", "" )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].nucleusId", "" )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].hardwareID", HARDWARE_PC ) // there is no good "no hardware" id so we default to PC.

		// mode-specific
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].displayData3IsTime", true )
		// shows on line N: displayData2 - line 2 of summary screen
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].displayData2",  0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].displayData3",  0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].displayData4",  0 )
		player.SetPersistentVar( "lastGameSquadStats[" + i + "].displayData5",  0 )

		player.SetPersistentVar( "lastGameResultFlags", 0 )
		player.SetPersistentVar( "lastGameScoreFlags", 0 )
		// end mode-specific

	}

	#if DEVELOPER
		printt( "PD: Cleared Match Sumnmary Persistent Vars for", player, "and", maxTrackedSquadMembers, "maxTrackedSquadMembers" )
	#endif

	if ( !player.p.hasMatchParticipationStarted )
		OnPlayerMatchParticipationStarted( player )
}

// Function used by Survival to determine how many squads are remaining in the match
// Takes into account when the functionality is overridden by different modes
int function Survival_GetRemainingSquadsCount()
{
	int squadsCount

	if ( file.getRemainingSquadsFunction != null )
		squadsCount = file.getRemainingSquadsFunction()
	else
		squadsCount = GetNumTeamsRemaining()

	return squadsCount
}

bool function Survival_IsPlaneEnabled()
{
	if ( !GetCurrentPlaylistVarBool( "jump_from_plane_enabled", true ) )
		return false

	if ( IsTestMap() )
		return false

	return true
}


bool function Survival_AirdroppedCarePackagesEnabled()
{
	return GetCurrentPlaylistVarBool( "survival_airdropped_carepackages_enabled", true )
}


ItemFlavor function Survival_ValidateAndGetCharacterClass( entity player )
{
	EHI playerEHI = ToEHI( player )
	LoadoutEntry loadoutCharacter = Loadout_Character()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter )
	bool isItemFlavorUnlockedForLoadoutSlot = IsItemFlavorUnlockedForLoadoutSlot( playerEHI, loadoutCharacter, LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter ) )

	// We assign all alliance players to the same team at the end of modes that use alliances. With a lot of players on one team and the game ending we don't care if duplicate Legends are used
	if ( AllianceProximity_IsUsingAlliances() && GetGameState() >= eGameState.WinnerDetermined )
			isItemFlavorUnlockedForLoadoutSlot = true

	// if their selection is invalid (character is taken by a squadmate), assign them a random character
	if ( !isItemFlavorUnlockedForLoadoutSlot )
	{
		#if DEVELOPER
			if ( file.DEV_overrideSpawnCharacterOrNull == null )
				SetItemFlavorLoadoutSlot( playerEHI, loadoutCharacter, GetRandomGoodItemFlavorForLoadoutSlot( playerEHI, loadoutCharacter ) )
		#else
			SetItemFlavorLoadoutSlot( playerEHI, loadoutCharacter, GetRandomGoodItemFlavorForLoadoutSlot( playerEHI, loadoutCharacter ) )
		#endif
	}

	return LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter )
}

void function Survival_RunCharacterSelection()
{
	array<entity> rankedPlayersToLookUpLeaderBoard
	// Clear settings for capital ship
	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsAlive( player ) )
			thread Survival_ClearStagingAreaSettings( player )

		// Set invulnerable for character select so left behind DOT ents wont do damage screen effects during the menu
		if ( !player.IsInvulnerable() )
			player.SetInvulnerable()
	}

	// Non-round based OR first round only
	if ( !IsRoundBased() || GetRoundsPlayed() == 0 )
	{
		//CleanupAllPlayerPermanents()
		//SURVIVAL_ChooseLootLocations()
	}

	bool modePicksChampion = GetCurrentPlaylistVarBool( "enable_champion", true ) && !IsPVEMode()

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_EXPLORE ) )
		modePicksChampion = false

	if ( modePicksChampion )
	{
		bool pickChampion = true

		if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_GUNGAME ) )
			pickChampion = false

		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
			pickChampion = false

		if ( pickChampion )
		{
			//SurvivalCommentary_PickChampion()
		}
	}

	//thread IntroAirdropThink()

	thread Survival_RunCharacterSelectionNew_Thread()
}

float s_characterSelectMusicStartTime = 0.0

string function GetAppropriateCharacterSelectMusicTrack( entity player )
{
	string override = GetCurrentPlaylistVarString( "music_override_charselect", "" )
	if ( override.len() > 0 )
		return override

	// Uses different music tracks depending on which Alliance players are in so I can't use the playlist override
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
	{
		int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
		//if ( playerAlliance == SHADOWARMY_LEGEND_ALLIANCE )
		//	return "Music_RevArmy_CharacterSelect_Legends"
		//else
			return "Music_RevArmy_CharacterSelect_Revenants"
	}

	string track
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) )
		track = MusicPack_GetCharacterSelectMusic_Solo( GetMusicPackForPlayer( player ) )
	else if ( IsDuoMode() )
		track = MusicPack_GetCharacterSelectMusic_Duo( GetMusicPackForPlayer( player ) )
	else if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_QUADS ) )
		track = MusicPack_GetCharacterSelectMusic_Quad( GetMusicPackForPlayer( player ) )
	else
		track = MusicPack_GetCharacterSelectMusic_Squad( GetMusicPackForPlayer( player ) )
	return track
}

void function PlayCharacterSelectMusicToAllPlayersIfNeeded()
{
	if ( s_characterSelectMusicStartTime != 0.0 )
		return

	s_characterSelectMusicStartTime = Time()

	// Try to play the character select music on late joiners
	AddCallback_OnClientConnected( CharacterSelect_OnPlayerConnected )

	foreach ( entity player in GetPlayerArray() )
	{
		string musicTrack = GetAppropriateCharacterSelectMusicTrack( player )

		if ( !IsMusicPlayingToPlayer( player, musicTrack ) )
			PlayMusicToPlayer( player, musicTrack, Time() - s_characterSelectMusicStartTime )
	}
}

void function CharacterSelect_OnPlayerConnected( entity player )
{
	Assert( IsValid( player ), "ClientConnected callback called with invalid player" )
	if ( !IsValid( player ) )
		return

	string musicTrack = GetAppropriateCharacterSelectMusicTrack( player )

	if ( !IsMusicPlayingToPlayer( player, musicTrack ) )
		PlayMusicToPlayer( player, musicTrack, Time() - s_characterSelectMusicStartTime )
}

void function Survival_RunCharacterSelectionNew_Thread()
{
	if ( Survival_CharacterSelectEnabled() )
	{

			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
				FlagWait( "AllianceAssignmentComplete" )


		AssignLockStepOrder()
		SetGlobalNetInt( CHARACTER_SELECT_NETVAR_LOCK_STEP_INDEX, -2 )

		// PIN event data
		table<entity, array<string> > PIN_ClassesOffered
		foreach ( entity player in GetPlayerArray() )
			PIN_ClassesOffered[player] <- GetStringArrayAvailableClassesForPlayer( player )

		// Picks Start Time
		float characterSelectPicksStartTime = (Time() + CharSelect_GetIntroCountdownDuration())

		// Picks End Time
		float characterSelectPicksEndTime
		{
			float dur = 0.0

			dur += CharSelect_GetPickingDelayBeforeAll()
			for ( int idx = 0 ; idx < MAX_TEAM_PLAYERS ; ++idx )
			{
				if ( idx == 0 )
					dur += CharSelect_GetPickingDelayOnFirst()
				dur += Survival_GetCharacterSelectDuration( idx )
				dur += CharSelect_GetPickingDelayAfterEachLock()
			}
			dur += CharSelect_GetPickingDelayAfterAll()

			characterSelectPicksEndTime = (characterSelectPicksStartTime + dur)
		}

		// Squad Cards Start Time
		float outroSceneChangeDuration   = CharSelect_GetOutroSceneChangeDuration()

		// look at all squads and add the 0 + (outroSceneChangeDuration * 0.5)
		float allSquadsPresentationStartTime = ( characterSelectPicksEndTime + (outroSceneChangeDuration * 0.5) )

		float squadPresentationStartTime = ( allSquadsPresentationStartTime + GetCurrentPlaylistVarFloat( "charselect_outro_all_squads_present_duration", 0.0 ) )

		float mvpPresentationStartTime = squadPresentationStartTime +  GetCurrentPlaylistVarFloat( "charselect_outro_squad_present_duration", 6.0  )

		// Champion Squad Cards Start Time
		float championSquadPresentationStartTime = ( mvpPresentationStartTime + GetCurrentPlaylistVarFloat( "charselect_outro_mvp_present_duration", 0.0 ) )

		bool showChampionSquad = GetCurrentPlaylistVarInt( "survival_enable_gladiator_intros", 1 ) == 1

		// Final End Time
		float finalEndTime = championSquadPresentationStartTime
		if ( showChampionSquad)
			finalEndTime += GetCurrentPlaylistVarFloat( "charselect_outro_champion_present_duration", 8.0 )


		SetGlobalNetTime( "pickLoadoutGamestateStartTime", characterSelectPicksStartTime )
		SetGlobalNetTime( "characterSelectPicksEndTime", characterSelectPicksEndTime )
		SetGlobalNetTime( "allSquadsPresentationStartTime", allSquadsPresentationStartTime )
		SetGlobalNetTime( "squadPresentationStartTime", squadPresentationStartTime )
		SetGlobalNetTime( "mvpPresentationStartTime", mvpPresentationStartTime )
		SetGlobalNetTime( "championSquadPresentationStartTime", championSquadPresentationStartTime )
		SetGlobalNetTime( "pickLoadoutGamestateEndTime", finalEndTime )
		SetGlobalNetBool( "characterSelectionReady", true )

		WaitFrame()

		foreach ( entity player in GetPlayerArray() )
		{
			player.FreezeControlsOnServer()
			//if ( !IsAlive( player ) )
			//	DecideRespawnPlayer( player )
		}

		float musicStartTime = CharSelect_GetIntroMusicStartTime()
		if ( musicStartTime >= 0.0 )
		{
			thread function() : (musicStartTime)
			{
				wait musicStartTime
				PlayCharacterSelectMusicToAllPlayersIfNeeded()
			}()
		}

		while( Time() < characterSelectPicksStartTime )
			WaitFrame()

		SetGlobalNetInt( CHARACTER_SELECT_NETVAR_LOCK_STEP_INDEX, -1 )
		wait CharSelect_GetPickingDelayBeforeAll()

		// Identify who each players default character will be
		foreach ( player in GetPlayerArray() )
		{
			ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
			int characterGUID = ItemFlavor_GetGUID( character )
			player.SetPlayerNetInt( CHARACTER_SELECT_NETVAR_FOCUS_CHARACTER_GUID, characterGUID )
			Remote_CallFunction_NonReplay( player, "ServerToClient_SetInitialSelection", characterGUID )
		}

		int pickIndex = 0
		for ( pickIndex = 0 ; pickIndex < MAX_TEAM_PLAYERS ; pickIndex++ )
		{
			float preSelectDelay          = ((pickIndex == 0) ? CharSelect_GetPickingDelayOnFirst() : 0.0)
			float characterSelectDuration = Survival_GetCharacterSelectDuration( pickIndex )

			SetGlobalNetInt( CHARACTER_SELECT_NETVAR_LOCK_STEP_INDEX, pickIndex )
			SetGlobalNetTime( CHARACTER_SELECT_NETVAR_LOCK_STEP_START_TIME, Time() + preSelectDelay )
			SetGlobalNetTime( CHARACTER_SELECT_NETVAR_LOCK_STEP_END_TIME, Time() + preSelectDelay + characterSelectDuration )

			wait (preSelectDelay + characterSelectDuration)

			table < int, array<ItemFlavor> > takenCharactersByTeam

			foreach ( entity player in GetPlayerArray() )
			{
				if ( !(player.GetTeam() in takenCharactersByTeam) )
				{
					takenCharactersByTeam[ player.GetTeam() ] <- []

					if ( CharacterClass_GetRandomCharacterSentinel() != null )
						takenCharactersByTeam[ player.GetTeam() ].append( expect ItemFlavor( CharacterClass_GetRandomCharacterSentinel() ) )
				}


				if ( player.GetPlayerNetInt( CHARACTER_SELECT_NETVAR_LOCK_STEP_PLAYER_INDEX ) < pickIndex )
				{
					ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

					takenCharactersByTeam[ player.GetTeam() ].append( character )
				}
			}

			// Finalize:
			foreach ( entity player in GetPlayerArray() )
			{
				if ( player.GetPlayerNetInt( CHARACTER_SELECT_NETVAR_LOCK_STEP_PLAYER_INDEX ) != pickIndex )
					continue

				bool hadLockedIn = player.GetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER )

				ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
				bool forcedSelection = false


				if ( !forcedSelection &&  ( ItemFlavor_GetAsset( character ) == CHARACTER_RANDOM || player.GetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER ) != true || CharacterSelect_CustomIsCharacterLockedForPlayer( character, player ) ) )
				{
					// They didn't lock anyone in, pick for them
					if ( ItemFlavor_GetAsset( character ) == CHARACTER_RANDOM || file.forceRandomOnNoSelect || !IsItemFlavorUnlockedForLoadoutSlot( ToEHI( player ), Loadout_Character(), character ) || CharacterSelect_CustomIsCharacterLockedForPlayer( character, player ) )
					{
						// if their selection is invalid (character is taken by a squadmate), assign them a random character
						array<ItemFlavor> charactersThatCannotBeSelected = takenCharactersByTeam[ player.GetTeam() ]
						if ( CharacterClass_AllowDuplicateCharacterPicksInTeam() )
							charactersThatCannotBeSelected = []

						const bool isAutoPlayer = false

						if ( !isAutoPlayer && GetPlaylistVarBool( GetCurrentPlaylistName(), "forced_select_gets_most_played", true ) )
							character = GetMostPlayedCharacterItemFlavor( ToEHI( player ), Loadout_Character(), false, charactersThatCannotBeSelected )
						else
							character = GetRandomGoodItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_Character(), false, charactersThatCannotBeSelected )

						SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), character )

						foreach ( func in file.Callbacks_OnGameAutoSelectedCharacterCallbacks )
						{
							func( player, character )
						}
					}
					player.SetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER, true )

					if ( hadLockedIn )
					{
						foreach ( teammate in GetPlayerArrayOfTeam( player.GetTeam() ) )
						{
							Remote_CallFunction_NonReplay( teammate, "ServerCallback_ForceCharacterLockFeedback", player, true )
						}
					}
				}

				// Report Stryder
				QueueUpdateStryderWithPlayersStryderCharDataArray( player )


			}

			wait CharSelect_GetPickingDelayAfterEachLock()
		}

		table < int, array<ItemFlavor> > takenCharactersByTeam

		foreach ( entity player in GetPlayerArray() )
		{
			if ( !(player.GetTeam() in takenCharactersByTeam) )
			{
				takenCharactersByTeam[ player.GetTeam() ] <- []

				if ( CharacterClass_GetRandomCharacterSentinel() != null )
					takenCharactersByTeam[ player.GetTeam() ].append( expect ItemFlavor( CharacterClass_GetRandomCharacterSentinel() ) )
			}

			ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

			if ( ItemFlavor_GetAsset( character ) != CHARACTER_RANDOM && player.GetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER ) == true )
			{
				takenCharactersByTeam[ player.GetTeam() ].append( character )
			}
		}

		//TODO(chin): This is super screwed up, we're essentially copy pasting a bunch of script again instead of trying to fix the root problem (HOW COME WE HAVE 4 PLAYERS?!)
		// Make sure all players have a character. This is a failsafe for having too many players on your team. If teamsize is 3 but you have 4 players (happens in dev) the last player wont get handled above
		foreach ( entity player in GetPlayerArray() )
		{
			ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

			if ( ItemFlavor_GetAsset( character ) != CHARACTER_RANDOM && player.GetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER ) == true )
			{

					MatchBehaviorPlayer_RecordPickInfo( player, character )

				continue
			}

			bool hadLockedIn = player.GetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER )

			bool forcedSelection = false



			// They didn't lock anyone in, pick for them
			if ( !forcedSelection && ( ItemFlavor_GetAsset( character ) == CHARACTER_RANDOM || file.forceRandomOnNoSelect || !IsItemFlavorUnlockedForLoadoutSlot( ToEHI( player ), Loadout_Character(), character ) || CharacterSelect_CustomIsCharacterLockedForPlayer( character, player ) ) )
			{
				// if their selection is invalid (character is taken by a squadmate), assign them a random character asd
				array<ItemFlavor> charactersThatCannotBeSelected = takenCharactersByTeam[ player.GetTeam() ]
				if ( CharacterClass_AllowDuplicateCharacterPicksInTeam() )
					charactersThatCannotBeSelected = []

				if ( GetPlaylistVarBool( GetCurrentPlaylistName(), "forced_select_gets_most_played", true ) )
					character = GetMostPlayedCharacterItemFlavor( ToEHI( player ), Loadout_Character(), false, charactersThatCannotBeSelected )
				else
					character = GetRandomGoodItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_Character(), false, charactersThatCannotBeSelected )

				SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), character )

				takenCharactersByTeam[ player.GetTeam() ].append( character )
			}
			player.SetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER, true )

			if ( hadLockedIn )
			{
				foreach ( teammate in GetPlayerArrayOfTeam( player.GetTeam() ) )
				{
					Remote_CallFunction_NonReplay( teammate, "ServerCallback_ForceCharacterLockFeedback", player, true )
				}
			}
		}

		// for progress bar only
		SetGlobalNetInt( CHARACTER_SELECT_NETVAR_LOCK_STEP_INDEX, MAX_TEAM_PLAYERS )

		file.characterLocksFinished = true

		// Gamemodes like Control have a podium sequence in the intro that displays right after Character Select.
		// We want to start playing the drop music earlier so it plays during the podium. So we only do this first wait for modes without the intro podium.
		int introPodiumSequenceCount = GetCurrentPlaylistVarInt( "podium_intro_screen_count", 0 )
		if ( introPodiumSequenceCount <= 0 )
		{
			wait max( 0, ( squadPresentationStartTime - Time() ) ) + ( outroSceneChangeDuration / 3.0 )
		}
		else
		{
			// Modes with an intro podium need a custom wait before music triggers that doesn't interfere with the other timings.
			// We can't just edit charselect_outro_scene_change_duration or charselect_outro_all_squads_present_duration because causes the char select screen to remain too long or the whole sequence to end early
			wait GetCurrentPlaylistVarFloat( "podium_intro_post_charselect_wait", 5.0 )
		}

		if ( GetRoundsPlayed() == 0 )
		{
			// Stop trying to play the character select music on late joiners
			RemoveCallback_OnClientConnected( CharacterSelect_OnPlayerConnected )
		}

		foreach ( entity player in GetPlayerArray() )
		{
			string music = GetMusicForJump( player )
			if ( music.len() > 0 )
				PlayMusicToPlayer( player, music )
		}
	}
	else
	{
		SetGlobalNetTime( "pickLoadoutGamestateEndTime", Time() )
	}

	file.characterLocksLocked = true

	thread function() : ()
	{
		// Spawning players causes hitching due to managing highlights on loot objects around where the player spawns in on the ground.
		// hiding it under the black screen before displaying the champion squad.
		// If we don't spawn players here, it will happen when entering gamestate prematch. GameStateEnter_Prematch(). The hitch there causes the transition banner to play twice.
		float waitTime = GetGlobalNetTime( "championSquadPresentationStartTime" ) - Time()
		if ( waitTime > 0 )
		{
			wait waitTime
			wait 0.6 // the time until the screen is completely black is 0.5 but waiting a bit more seemed to make it match up better.
		}

		//check if we should spawn players here based on mode
		if ( file.Callback_ModeShouldSpawnPlayersDuringCharacterSelect != null )
		{
			bool shouldSpawn = file.Callback_ModeShouldSpawnPlayersDuringCharacterSelect()
			if ( !shouldSpawn )
				return
		}

		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsValid( player ) && !IsAlive( player ) )
			{
				//printf( "%s() - Spawning player: %s", FUNC_NAME(), string( player ) )
				DecideRespawnPlayer( player, true )
			}
			else
			{
				//if ( IsAlive( player ) )
				//	printf( "%s() - Already alive: %s", FUNC_NAME(), string( player ) )
			}
		}
	}()
}

void function Sequence_Playing()
{
	SetServerVar( "minimapState", IsFiringRangeGameMode() ? eMinimapState.Hidden : eMinimapState.Default )

	if ( IsFiringRangeGameMode() || IsSurvivalTraining() )
	{
		SetGameState( eGameState.WaitingForPlayers )
		return
	}

	// FreeDM has its own game flow (FreeDM_OnGameStatePlayingEnter) — skip survival sequence
	if ( GameMode_IsActive( eGameModes.FREEDM ) )
		return

	FlagSet( "GamePlaying" )

	if( !GetCurrentPlaylistVarBool( "deathfield_starts_in_prematch", false ) )
		thread SURVIVAL_RunArenaDeathField()

	// if( Survival_AirdroppedCarePackagesEnabled() )
		// thread AirdropLogic()

	foreach ( entity player in GetPlayerArray() )
	{
		player.StopObserverMode()
		Survival_ClearPrematchSettings( player )

		if( !IsAlive( player ) )
			DecideRespawnPlayer( player, false )
	}

	// Set settings for the drop-in
	bool shouldSetDropSettings = true
	if ( Gamemode() == eGamemodes.WINTEREXPRESS || Playlist() == ePlaylists.survival_dev || Playlist() == ePlaylists.dev_default || GetCurrentPlaylistVarBool( "is_practice_map", false ) || Playlist() == ePlaylists.fs_movementrecorder )
		shouldSetDropSettings = false

	if ( shouldSetDropSettings )
	{
		foreach ( entity player in GetPlayerArray() )
			SetPlayerIntroDropSettings( player )
	}

	FlagClear( "PlaneStartMoving" )
	FlagClear( "PlaneDoorOpen" )
	FlagClear( "PlaneAtLaunchPoint" )

	foreach( entity player in GetPlayerArray() )
	{
		player.ClearParent()
		ClearPlayerPlaneViewMode( player )
		player.p.survivalLandedOnGround = false
	}

	if( GetCurrentPlaylistVarBool( "jump_from_plane_enabled", true ) )
	{
		waitthread Survival_PutPlayersInPlane()
	}

	FlagSet( "PlaneStartMoving" )
	UpdatePlayerCounts()

	thread CircleRemainingTimeChatter_Think()

	if( GetCurrentPlaylistVarBool( "lsm_mod11", false ) )
	{
		while( GetPlayerArray().len() < 2 )
		{
			WaitFrame()
		}
	}
	else if ( !GetCurrentPlaylistVarBool( "match_ending_enabled", true ) || GetConVarInt( "mp_enablematchending" ) < 1 )
	{
		WaitForever() // match never ending
	}

	while ( GetGameState() == eGameState.Playing )
	{
		if ( GetNumTeamsRemaining() <= 1 )
		{
			int winnerTeam
			if( GetTeamsForPlayers( GetPlayerArray_AliveConnected() ).len() > 0 )
				winnerTeam = GetTeamsForPlayers( GetPlayerArray_AliveConnected() )[0]
			else
				winnerTeam = -1

			level.nv.winningTeam = winnerTeam

			SetGameState( eGameState.WinnerDetermined )
			printt( "ending game", GetNumTeamsRemaining() )
		}
		WaitFrame()
	}

	thread Sequence_WinnerDetermined()
}

void function CircleRemainingTimeChatter_Think()
{
	while( true )
	{
		wait 1.0

		int remainingTime = int( GetGlobalNetTime( "nextCircleStartTime" ) - Time() )

		if( remainingTime < 0 )
			continue

		string line = ""
		array< int > alreadySaidTeam = []

		switch( remainingTime )
		{
			case 60:
				line = "bc_circleMovesNag1Min"
				break

			case 45:
				line = "bc_circleMovesNag45Sec"
				break

			case 30:
				line = "bc_circleMovesNag30Sec"
				break

			case 10:
				line = "bc_circleMovesNag10Sec"
				break
		}

		if( line == "" )
			continue

		foreach( player in GetPlayerArray_Alive() )
		{
			if( !IsValid( player ) )
				continue

			if( alreadySaidTeam.contains( player.GetTeam() ) )
				continue

			alreadySaidTeam.append( player.GetTeam() )
			string distance = ""
			entity speaker = GetPlayerArrayOfTeam_Alive( player.GetTeam() ).getrandom()

			if( SURVIVAL_PosInSafeZone( speaker.GetOrigin() ) )
				continue

			if( Distance( SURVIVAL_GetSafeZoneCenter(), speaker.GetOrigin() ) >= FAR_FROM_CIRCLE_DISTANCE * 17500 )
				distance = "_far"
			else
				distance = "_close"

			PlayBattleChatterLineToSpeakerAndTeam( speaker, line + distance )
		}
	}
}

void function Sequence_WinnerDetermined()
{
	FlagSet( "DeathFieldPaused" )

	foreach ( player in GetPlayerArray() )
	{
		MakeInvincible( player )
		//Remote_CallFunction_NonReplay( player, "ServerCallback_PlayMatchEndMusic" )
		Remote_CallFunction_ByRef( player, "ServerCallback_PlayMatchEndMusic" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_MatchEndAnnouncement", player.GetTeam() == GetWinningTeam(), GetWinningTeam() )

		if( Bleedout_IsBleedingOut( player ) )
		{
			player.Signal( "BleedOut_OnRevive" )
			player.Signal( "OnContinousUseStopped" )
		}

	}

	thread SurvivalCommentary_HostAnnounce( eSurvivalCommentaryBucket.WINNER, 3.0 )

	wait 15.0

	thread Sequence_Epilogue()
}

void function Sequence_Epilogue()
{
	SetGameState( eGameState.Resolution )

	UpdateMatchSummaryPersistentVars( GetWinningTeam() )

	foreach ( player in GetPlayerArray() )
	{
		player.FreezeControlsOnServer()

		// Clear all residue data
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddWinningSquadData", -1, -1, 0, 0, 0, 0, 0 )

		foreach ( int i, entity champion in GetPlayerArrayOfTeam( GetWinningTeam() ) )
		{
			GameSummarySquadData gameSummaryData = GameSummary_GetPlayerData( champion )

			Remote_CallFunction_NonReplay(
				player,
				"ServerCallback_AddWinningSquadData",
				i, // Champion index
				champion.GetEncodedEHandle(), // Champion EEH
				gameSummaryData.kills,
				gameSummaryData.damageDealt,
				gameSummaryData.survivalTime,
				gameSummaryData.revivesGiven,
				gameSummaryData.respawnsGiven
			)
		}

		Remote_CallFunction_ByRef( player, "ServerCallback_ShowWinningSquadSequence" )
	}

	if( GetCurrentPlaylistVarBool( "survival_server_restart_after_end", false ) )
	{
		wait GetCurrentPlaylistVarFloat( "survival_server_restart_after_end_time", 30 )

		GameRules_ChangeMap( GetMapName(), GameRules_GetGameMode() )
	}
}

void function UpdateMatchSummaryPersistentVars( int team )
{
	array<entity> squadMembers = GetPlayerArrayOfTeam( team )
	int maxTrackedSquadMembers = PersistenceGetArrayCount( "lastGameSquadStats" )

	foreach ( teamMember in squadMembers )
	{
		teamMember.SetPersistentVar( "lastGameRank", Survival_GetCurrentRank( teamMember ) )

		for ( int i = 0; i < squadMembers.len(); i++ )
		{
			if ( i >= maxTrackedSquadMembers )
				continue

			entity statMember = squadMembers[i]
			GameSummarySquadData statSummaryData = GameSummary_GetPlayerData( statMember )

			teamMember.SetPersistentVar( "lastGameSquadStats[" + i + "].eHandle", statMember.GetEncodedEHandle() )
			teamMember.SetPersistentVar( "lastGameSquadStats[" + i + "].kills", statSummaryData.kills )
			teamMember.SetPersistentVar( "lastGameSquadStats[" + i + "].damageDealt", statSummaryData.damageDealt )
			teamMember.SetPersistentVar( "lastGameSquadStats[" + i + "].survivalTime", statSummaryData.survivalTime )
			teamMember.SetPersistentVar( "lastGameSquadStats[" + i + "].revivesGiven", statSummaryData.revivesGiven )
			teamMember.SetPersistentVar( "lastGameSquadStats[" + i + "].respawnsGiven", statSummaryData.respawnsGiven )
		}
	}
}

void function HandleSquadElimination( int team )
{
	RespawnBeacons_OnSquadEliminated( team )
	StatsHook_SquadEliminated( GetPlayerArrayOfTeam_Connected( team ) )

	UpdateMatchSummaryPersistentVars( team )

	foreach ( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SquadEliminated", team )

	array< table< int, var > > squadData
	array< entity > squadList = GetPlayerArrayOfTeam( team )

	foreach ( squadPlayer in squadList )
	{
		squadData.append( LiveAPI_GetPlayerIdentityTable( squadPlayer ) )
	}

	LiveAPI_WriteLogUsingDefinedFields( eLiveAPI_EventTypes.squadEliminated,
		[ squadData ], [ 3/*players*/ ]
	)
}

// Fully doomed, no chance to respawn, game over
void function PlayerFullyDoomed( entity player )
{
	player.p.respawnChanceExpiryTime = Time()
	player.p.squadRank = 0 // Survival_GetCurrentRank( player )

	StatsHook_RecordPlacementStats( player )
}

void function OnPlayerDamaged( entity victim, var damageInfo )
{
	if ( !IsValid( victim ) || !victim.IsPlayer() || Bleedout_IsBleedingOut( victim ) )
		return

	entity attacker = InflictorOwner( DamageInfo_GetAttacker( damageInfo ) )

	int sourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	// #if DEVELOPER
	// Warning( "OnPlayerDamaged " + victim )
	// #endif
	if ( sourceId == eDamageSourceId.bleedout || sourceId == eDamageSourceId.human_execution )
		return

	float damage = DamageInfo_GetDamage( damageInfo )

	int currentHealth = victim.GetHealth()
	if ( !( DamageInfo_GetCustomDamageType( damageInfo ) & DF_BYPASS_SHIELD ) )
		currentHealth += victim.GetShieldHealth()

	vector damagePosition = DamageInfo_GetDamagePosition( damageInfo )
	int damageType = DamageInfo_GetCustomDamageType( damageInfo )
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	TakingFireDialogue( attacker, victim, weapon )
}

//Centralized start bleedout
int function CodeCallback_KillDamagePlayerOrNPC( entity ent, var damageInfo, int actualTotalDamage )
{
	entity damagedEnt = ent

	if ( !damagedEnt.IsPlayer() )
		return 0

	int damageType   = DamageInfo_GetCustomDamageType( damageInfo )
	entity attacker  = GetAttackerOrLastAttacker( ent, damageInfo )
	bool isForceKill = DamageInfo_GetForceKill( damageInfo )
	// damagedEnt.p.PIN_VictimWeapon = damagedEnt.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !Bleedout_IsBleedingOut( damagedEnt )
			&& DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.fall
			&& !( damageType & DF_SKIPS_DOOMED_STATE )
			&& !isForceKill )
	{
		// StatsHook_OnDoomingDamage( damagedEnt, attacker, damageInfo )
		// WeaponStatsHook_OnDownEnemy( damagedEnt, attacker, damageInfo )

		if ( attacker.IsPlayer() && attacker != damagedEnt )
		{
			// if( Playlist() == ePlaylists.fs_haloMod_survival )
				// HisWattsons_HaloModFFA_KillStreakAnnounce( attacker )

			// AddGameSummaryKnockdown( attacker, ent, 1, damageInfo )

			foreach ( entity assistCreditPlayer, float assistTime in ent.p.playerToTimeThatAssistCreditLastsTable )
			{
				if ( !IsValid( assistCreditPlayer ) )
					continue

				// if ( assistCreditPlayer.p.hasMatchParticipationEnded )
					// continue

				// AddGameSummaryKnockdownAssist ( assistCreditPlayer, ent, 1  )
			}
		}

		if ( ShouldDoBleedout( damagedEnt ) )
		{
			if ( attacker.GetTeam() != damagedEnt.GetTeam() )
			{
				foreach ( player in GetPlayerArray() )
				{
					Remote_CallFunction_Replay( player, "ServerCallback_OnEnemyDowned", attacker, damagedEnt, DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamageSourceIdentifier( damageInfo ) )
				}

				if( attacker.IsPlayer() && IsPlaylistAllowedForDefaultKillNotifications() )
					AddPlayerScore( attacker, "Sur_DownedPilot", damagedEnt )


				// if( attacker.IsPlayer() && Playlist() == ePlaylists.fs_scenarios )
					// FS_Scenarios_UpdatePlayerScore( attacker, FS_ScoreType.DOWNED, damagedEnt )
			}

			damagedEnt.p.playerToTimeThatAssistCreditLastsTable = GetLatestAssistingPlayersFromSameTeam( damagedEnt, attacker )
			DamageInfo_AddCustomDamageType( damageInfo, DF_KNOCKDOWN )

			// add knockdown to the latest damage history entry, it wasn't added earlier because we no longer know that we are going to be knocked down where the histroy is stored.
			// Assert( ent.e.recentDamageHistory.len() > 0, "recentDamageHistory didn't have any history when it should" )
			if( ent.e.recentDamageHistory.len() == 0 )
			{
				Warning( "recentDamageHistory didn't have any history when it should. Len: " + ent.e.recentDamageHistory.len() ) //Cafe
			} else
				ent.e.recentDamageHistory[0].damageType = ent.e.recentDamageHistory[0].damageType | DF_KNOCKDOWN

			if ( attacker.IsPlayer() )
				EmitSoundOnEntityExceptToPlayer( damagedEnt, attacker, KNOCKED_SOUND )
			else
				EmitSoundOnEntity( damagedEnt, KNOCKED_SOUND )

			Bleedout_StartPlayerBleedout( damagedEnt, attacker, damageInfo )
			damagedEnt.SetNPCPriorityOverride( 1 )

			//TODO - the follow can cause Callbacks_OnPlayerKillDamage below to be skipped
			return damagedEnt.GetMaxHealth()
		}

		//After this is full team bleedout. Cafe
		thread Delayed_TryEliminateTeammates( damagedEnt, attacker ) //Now we ensure it will be triggered only one time. Cafe

		if( attacker.IsPlayer() )
		{
			damagedEnt.p.playerToTimeThatAssistCreditLastsTable = GetLatestAssistingPlayersFromSameTeam( damagedEnt, attacker )
		}
	}

	foreach ( func in file.Callbacks_OnPlayerKillDamage )
		func( ent, damageInfo, actualTotalDamage )

	return 0
}


bool function ShouldDoBleedout( entity damagedEnt )
{
	#if DEVELOPER
	Warning( "ShouldDoBleedout " + damagedEnt )
	#endif

	if ( !GetCurrentPlaylistVarBool( "bleedout_enabled", false ) ) //Bleedout system will remain disabled by default. Cafe
		return false

	if( GetCurrentPlaylistVarBool( "is_practice_map", false ) ) //Don't enable bleedout logic in practice maps made by the community. Cafe
		return false

	if ( !IsValid( damagedEnt ) )
		return false

	Bleedout_TryToRemoveInfiniteSelfResOnDownedSquad( damagedEnt )

	if ( Bleedout_AnyOtherSquadmatesAliveAndNotBleedingOut( damagedEnt ) )
		return true

	if ( Flag( "BleedoutDebug" ) )
		return true

	if ( Bleedout_GetSelfResEnabled( damagedEnt ) )
		return true

	if ( Bleedout_CanTeammatesSelfRevive( damagedEnt ) )
		return true

	return false

}


void function Delayed_TryEliminateTeammates( entity victim, entity attacker = null )
{
	int bleedingMatesKilled = 0
	foreach ( player in GetPlayerArrayOfTeam( victim.GetTeam() ) )
	{
		wait 0.1
		if( !IsValid( player ) ) //
			continue

		if ( GetGameState() <= eGameState.Playing &&
				IsAlive( player ) &&
				player != victim &&
				Bleedout_IsBleedingOut( player ) &&
						!Bleedout_AnyOtherSquadmatesAliveAndNotBleedingOut( player ) && Playlist() != ePlaylists.fs_duckhunt &&
				!Bleedout_GetSelfResEnabled( player ) &&
				!Bleedout_CanTeammatesSelfRevive( player )
				)
		{
			Bleedout_PlayerDiesFromBleedout( player )
			bleedingMatesKilled++
		}
	}

	if( !IsValid( attacker ) )
		return

	EndSignal( attacker, "OnDestroy" )
	wait 0.1


	if( !IsValid( attacker ) || !IsValid( victim ) ) //check again since waited frames...
		return

	if( attacker.IsPlayer() && bleedingMatesKilled != 0 ) //Squad wipe logic should only be triggered if there are not bleeding teammates
	{
		if( IsPlaylistAllowedForDefaultKillNotifications() )
		{
			array<entity> teammates = GetPlayerArrayOfTeam_Alive( attacker.GetTeam() )
			foreach( entity teammate in teammates )
			{
				AddPlayerScore( teammate, "Sur_SquadWipe", victim, teammate == attacker ? "killer" : "" )
			}
		}

		foreach ( func in file.Callbacks_OnAttackerSquadWipe )
			func( victim, attacker )
	}
	else if( attacker.IsPlayer() && bleedingMatesKilled == 0 )
	{
		if( IsPlaylistAllowedForDefaultKillNotifications() && GetCurrentPlaylistVarBool( "flowstate_rat_wipe_notification", false ) )
		{
			array<entity> teammates = GetPlayerArrayOfTeam_Alive( attacker.GetTeam() )
			foreach( entity teammate in teammates )
			{
				AddPlayerScore( teammate, "Sur_SquadWipeRat", victim, teammate == attacker ? "killer" : "" )
			}
		}

		foreach ( func in file.Callbacks_OnAttackerSoloRatEliminated )
			func( victim, attacker )
	}
}

void function Delayed_TryClearTeam( int team )
{
	WaitFrame()

	foreach ( p in GetPlayerArrayOfTeam( team ) )
	{
		if ( IsAlive( p ) &&
				Bleedout_IsBleedingOut( p ) &&
						!Bleedout_AnyOtherSquadmatesAliveAndNotBleedingOut( p ) && Playlist() != ePlaylists.fs_duckhunt &&
				!Bleedout_IsPlayerSelfReviving( p ) &&
				!Bleedout_CanTeammatesSelfRevive( p ) )
		{
			Bleedout_PlayerDiesFromBleedout( p )
		}
	}

	// OnPlayerKilled_Winner()
}

void function EnemyDownedDialogue( entity attacker, entity victim )
{
	if( !attacker.IsPlayer() || attacker == victim )
		return

	attacker.p.downedEnemy++

	string dialogue = ""
	float delay = 2
	float anotherDelay = 10
	if( Time() <= anotherDelay )
		attacker.p.lastDownedEnemyTime -= anotherDelay // rare

	float time = Time() - attacker.p.lastDownedEnemyTime
	int currentDownedEnemy = attacker.p.downedEnemy

	if( attacker.p.downedEnemy > 1 )
		dialogue = "bc_iDownedMultiple"
	else if( time <= anotherDelay )
		dialogue = "bc_iDownedAnotherEnemy"
	else
		dialogue = "bc_iDownedAnEnemy"

	wait delay

	if( attacker.p.downedEnemy == currentDownedEnemy )
	{
		PlayBattleChatterLineToSpeakerAndTeam( attacker, dialogue )
		attacker.p.downedEnemy = 0
		attacker.p.lastDownedEnemyTime = Time()
	}
}

void function TakingFireDialogue( entity attacker, entity victim, entity weapon )
{
	if( !attacker.IsPlayer() || !victim.IsPlayer() || attacker == victim )
		return

	float returnTime = 30
	float farTime = 5
	int attackerTeam = attacker.GetTeam()

	bool inTime = false
	foreach( player in GetPlayerArrayOfTeam( victim.GetTeam() ) )
	{
		if( !IsValid(player) )
			continue

		if( !(attackerTeam in player.p.attackedTeam) )
			player.p.attackedTeam[ attackerTeam ] <- -returnTime

		if( attackerTeam in player.p.attackedTeam && Time() - player.p.attackedTeam[ attackerTeam ] <= returnTime )
			inTime = true
	}

	if( IsValid(weapon) )
	{
		if( Distance( attacker.GetOrigin(), victim.GetOrigin() ) >= 4000 && Time() - victim.p.attackedTeam[ attackerTeam ] >= farTime )
			PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_damageEnemy" )
		else if( !inTime )
			PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_engagingEnemy" )
	}

	foreach( player in GetPlayerArrayOfTeam( victim.GetTeam() ) )
	{
		if( attackerTeam in player.p.attackedTeam )
			player.p.attackedTeam[ attackerTeam ] = Time()
	}

	if( inTime )
		return

	int attackerTotalTeam = 0
	foreach( team, time in victim.p.attackedTeam )
		if( Time() - time < returnTime )
			attackerTotalTeam++

	if( attackerTotalTeam > 1 )
		PlayBattleChatterLineToSpeakerAndTeam( victim, "bc_anotherSquadAttackingUs" )
	else
		if( weapon == null )
			PlayBattleChatterLineToSpeakerAndTeam( victim, "bc_takingDamage" )
		else
			PlayBattleChatterLineToSpeakerAndTeam( victim, "bc_takingFire" )
}

void function Survival_PlayerDealtDamage( entity player, entity victim, entity weapon, int healthDamage, int shieldDamage, int absorbedDamage, int damageType = -1 )
{

	EvolvingArmor_PlayerDealtDamage( player, victim, weapon, healthDamage, shieldDamage, absorbedDamage, damageType )




	//Lifesteal_PlayerDealtDamage( player, victim, weapon, healthDamage, shieldDamage, absorbedDamage, damageType )

	if ( player.GetTeam() != victim.GetTeam() )
	{
		//int reason = victim.IsPlayer() ? eDeadPeriodEndReason.DEALT_DAMAGE_TO_PLAYER : ( victim.IsNPC() ? eDeadPeriodEndReason.DEALT_DAMAGE_TO_NPC : eDeadPeriodEndReason.UNKNOWN_REASON )
		//DeadPeriodChecker_PlayerDeadPeriodEnd( player, reason )
	}
}


array<ConsumableInventoryItem> function GetAllDroppableItems( entity player )
{
	array<ConsumableInventoryItem> final = []

	// Consumable inventory
	final.extend( SURVIVAL_GetPlayerInventory( player ) )

	// Weapon related items
	foreach ( weapon in SURVIVAL_GetPrimaryWeapons( player ) )
	{
		LootData data = SURVIVAL_GetLootDataFromWeapon( weapon )
		if ( data.ref == "" )
			continue

		// Add the weapon
		ConsumableInventoryItem item

		item.type = data.index
		item.count = weapon.GetWeaponPrimaryClipCount()

		final.append( item )

		foreach ( esRef, mod in GetAllWeaponAttachments( weapon ) )
		{
			if ( !SURVIVAL_Loot_IsRefValid( mod ) )
				continue

			if ( data.baseMods.contains( mod ) )
				continue

			LootData attachmentData = SURVIVAL_Loot_GetLootDataByRef( mod )

			// Add the attachment
			ConsumableInventoryItem attachmentItem

			attachmentItem.type = attachmentData.index
			attachmentItem.count = 1

			final.append( attachmentItem )
		}
	}

	// Non-weapon equipment slots
	foreach ( string ref, EquipmentSlot es in EquipmentSlot_GetAllEquipmentSlots() )
	{
		if ( EquipmentSlot_IsMainWeaponSlot( ref ) || EquipmentSlot_IsAttachmentSlot( ref ) )
			continue

		LootData data = EquipmentSlot_GetEquippedLootDataForSlot( player, ref )
		if ( data.ref == "" )
			continue

		// Add the equipped loot
		ConsumableInventoryItem equippedItem

		equippedItem.type = data.index
		equippedItem.count = 1

		final.append( equippedItem )
	}

	return final
}

void function CreateSurvivalDeathBoxForPlayer( entity victim, entity attacker, var damageInfo )
{
	entity deathBox = SURVIVAL_CreateDeathBox( victim, true )

	foreach ( invItem in GetAllDroppableItems( victim ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( invItem.type )

		entity loot = SpawnGenericLoot( data.ref, deathBox.GetOrigin(), deathBox.GetAngles(), invItem.count )
		AddToDeathBox( loot, deathBox )
	}

	UpdateDeathBoxHighlight( deathBox )

	foreach ( func in svGlobal.onDeathBoxSpawnedCallbacks )
		func( deathBox, attacker, damageInfo != null ? DamageInfo_GetDamageSourceIdentifier( damageInfo ) : 0 )
}

void function OnPlayerKilled_DropLoot( entity player, entity attacker, var damageInfo )
{
	if ( GetGameState() >= eGameState.Playing )
		thread SURVIVAL_Death_DropLoot( player, damageInfo )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( victim ) || !IsValid( attacker ) || !victim.IsPlayer() )
		return

	int attackerEHandle = -1
	int victimEHandle = -1

	if( attacker.IsPlayer() && !IsFiringRangeGameMode() )
	{
		attackerEHandle = attacker ? attacker.GetEncodedEHandle() : -1
		victimEHandle = victim ? victim.GetEncodedEHandle() : -1
	}

	SetPlayerEliminated( victim )

	if ( Flowstate_PlayerDoesRespawn() )
	{
		thread function() : ( victim )
		{
			wait GetDeathCamLength(victim)

			if( !IsValid(victim) )
				return

			//SetRandomStagingPositionForPlayer( victim )
			DecideRespawnPlayer( victim, false )
		}()

		return
	}

	int victimTeamNum = victim.GetTeam()
	array<entity> victimTeam = GetPlayerArrayOfTeam_Alive( victimTeamNum )
	bool teamEliminated = victimTeam.len() == 0
	bool canPlayerBeRespawned = PlayerRespawnEnabled() && !teamEliminated

	// PlayerFullyDoomed MUST be called before HandleSquadElimination
	// HandleSquadElimination accesses player.p.respawnChanceExpiryTime which is set by PlayerFullyDoomed
	// if it isn't called in this order, the survivalTime will be 0
	if ( !canPlayerBeRespawned )
	{
		PlayerFullyDoomed( victim )
	}

	if ( teamEliminated )
		HandleSquadElimination( victimTeamNum )

	//Disable until I debug it, Idk what this is for rn. Cafe
	// // Restore weapons for deathbox
	// if ( victim.p.storedWeapons.len() > 0 )
		// RetrievePilotWeapons( victim )

	thread EnemyKilledDialogue( attacker, victimTeamNum, victim )
}

void function EnemyKilledDialogue( entity attacker, int victimTeam, entity victim )
{
	if( !attacker.IsPlayer() || attacker == victim )
		return

	attacker.p.killedEnemy++

	string dialogue = ""
	string responseName = ""
	entity responsePlayer = null
	float delay = 2
	int currentKilledEnemy = attacker.p.killedEnemy

	if( GetPlayerArrayOfTeam_Alive( victimTeam ).len() == 0 )
	{
		dialogue = "bc_squadTeamWipe"
		responseName = "bc_congratsKill"
		responsePlayer = TryFindSpeakingPlayerOnTeamDisallowSelf( attacker.GetTeam(), attacker )
	}
	else if( attacker.p.killedEnemy > 1 )
		dialogue = "bc_megaKill"
	else
		dialogue = "bc_iKilledAnEnemy"

	EndSignal( attacker, "OnDeath" )
	EndSignal( attacker, "OnDestroy" )

	wait delay

	if( attacker.p.killedEnemy == currentKilledEnemy )
	{
		PlayBattleChatterLineToSpeakerAndTeam( attacker, dialogue )
		if( responsePlayer != null )
			PlayBattleChatterLineToSpeakerAndTeam( responsePlayer, responseName )

		attacker.p.killedEnemy = 0
	}
}

void function OnClientConnected( entity player )
{
	Survival_OnClientConnected( player )

	player.p.squadRank = 0

	if( GetCurrentPlaylistVarBool( "lsm_mod4", false ) )
	{
		AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, LSM_OnPlayerTouchGround )
		AddPlayerMovementEventCallback( player, ePlayerMovementEvents.LEAVE_GROUND, LSM_OnPlayerLeaveGround )
	}

	AddEntityCallback_OnPostDamaged( player, OnPlayerDamaged ) //(mk): changed to post damage

	if ( IsFiringRangeGameMode() )
	{
		SetRandomStagingPositionForPlayer( player )
		DecideRespawnPlayer( player, false )
		GiveBasicSurvivalItems( player )
		return
	}
	else if ( IsSurvivalTraining() )
	{
		return
	}

	switch ( GetGameState() )
	{
		case eGameState.Resolution:
			Remote_CallFunction_ByRef( player, "ServerCallback_ShowWinningSquadSequence" )
			break
	}

	if( Playlist() == ePlaylists.fs_haloMod_survival ) //Assign random stance and frame for halo mod survival, which always uses bloodhound character. Cafe
	{
		LoadoutEntry entry = GetAllLoadoutSlots()[56] //character_bloodhound GCard Frame
		ItemFlavor itemFlavor = ConvertLoadoutSlotContentsIndexToItemFlavor( entry, RandomIntRangeInclusive(2, 17) ) //1 does not exists, starts from 2
		SetItemFlavorLoadoutSlot( ToEHI( player ), entry, itemFlavor )

		LoadoutEntry entry2 = GetAllLoadoutSlots()[57] //character_bloodhound GCard Stance
		ItemFlavor itemFlavor2 = ConvertLoadoutSlotContentsIndexToItemFlavor( entry2, RandomIntRangeInclusive(2, 17) ) //1 does not exists, starts from 2
		SetItemFlavorLoadoutSlot( ToEHI( player ), entry2, itemFlavor2 )

		LoadoutEntry entry3 = GetAllLoadoutSlots()[37] //character_bloodhound Execution
		ItemFlavor itemFlavor3 = ConvertLoadoutSlotContentsIndexToItemFlavor( entry3, RandomIntRangeInclusive(2, 4) ) //1 does not exists, starts from 2
		SetItemFlavorLoadoutSlot( ToEHI( player ), entry3, itemFlavor3 )
	}
}

bool function Survival_IsArenaMap()
{
	string mapName = GetMapName()

	if ( mapName.len() == 0 )
		return false

	if ( mapName.find( "_arena_" ) != -1 )
		return true

	switch ( mapName )
	{
		case "mp_rr_party_crasher":
		case "mp_rr_aqueduct":
			return true
	}

	return false
}

float function Survival_GetDefaultMinimapZoomScale()
{
	if ( Playlist() == ePlaylists.fs_haloMod_survival )
		return SURVIVAL_MINIMAP_ZOOM_HALOMOD

	if ( Survival_IsArenaMap() )
		return GetCurrentPlaylistVarFloat( PLAYLISTVAR_ARENA_MINIMAP_ZOOM, SURVIVAL_MINIMAP_ZOOM_ARENA )

	return SURVIVAL_MINIMAP_ZOOM_DEFAULT
}

void function Survival_OnClientConnected( entity player )
{
	float defaultZoom = Survival_GetDefaultMinimapZoomScale()
	player.SetMinimapZoomScale( defaultZoom, 0.0 )

	SurvivalPlayerData data
	file.playerData[EHIToEncodedEHandle( player )] <- data

	player.SetPlayerCanToggleObserverMode( false )

	AddButtonPressedPlayerInputCallback( player, IN_USE_LONG, OnPlayerPressedUseLong )

	file.playerLastDamageSlowTime[player] <- 0.0
}

void function Survival_OnClientDisconnected( entity player )
{
	if ( IsAlive( player ) )
	{
		//quitting in combat counts as death
		entity lastAttacker = GetLastAttacker( player ) //Attacker doesn't work, get last attacker
		if ( !IsValid( lastAttacker ) )
		{
			//last attacker didn't work, get latestAssistingPlayerInfo
			AssistingPlayerStruct attackerInfo = GetLatestAssistingPlayerInfo( player )
			if ( IsValid( attackerInfo.player ) )
			{
				lastAttacker = attackerInfo.player
			}
		}

		// bleedout + execution check
		if ( Bleedout_IsBleedingOut( player ) )
		{
			entity attacker    = Bleedout_GetBleedoutAttacker( player )
			int damageSourceID = GetLastDamageSourceIDForAttacker( player, attacker )

			bool playerWasBeingExecuted = false

			if ( player.ContextAction_IsMeleeExecutionTarget() && IsValid( player.e.syncedMeleeAttacker ) )
			{
				attacker               = player.e.syncedMeleeAttacker
				damageSourceID         = eDamageSourceId.human_execution
				playerWasBeingExecuted = true
			}

			if ( IsValid( attacker ) && attacker.IsPlayer() )
			{
				if ( playerWasBeingExecuted )
					player.Die( attacker, attacker, { damageType = DMG_MELEE_EXECUTION, damageSourceId = damageSourceID } )
				else
					player.Die( attacker, attacker, { damageSourceId = damageSourceID } )
			}
		}
		else if ( IsValid (lastAttacker ) ) //non-bleedout assist check
		{
			//quitting while in combat
			int damageSourceID = GetLastDamageSourceIDForAttacker(player , lastAttacker )
			player.Die( lastAttacker, lastAttacker, { damageSourceId = damageSourceID } )
		}
		// else
		// {
			// if ( GetGameState() >= eGameState.Playing )
				// thread SURVIVAL_Disconnect_DropLoot( player )
		// }
	}

	UpdatePlayerCounts()
	thread Delayed_TryClearTeam( player.GetTeam() )
}

void function OnPlayerPressedUseLong( entity player )
{
	thread TEMP_PlayerZiplineTryUse( player, IN_USE_LONG, true )
}

bool function Survival_IsPlayerSquadEliminated( entity player )
{
	int team = player.GetTeam()



// TODO: Is this causing the post-disable lockup bug?
//%if HAS_FREERESPAWNS
//	if( FreeRespawns_Feature_Exists() && FreeRespawns_IsPlayerRespawnDisabled( player )  )
//		return true
//%endif // HAS_FREERESPAWNS









	array <entity> teamArray = GetPlayerArrayOfTeam( team )












	if ( teamArray.len() == 0 )
		return true

	if ( GetPlayerArrayOfTeam_Alive( player.GetTeam() ).len() == 0 )
		return true

	return false
}

void function InformPlayerSquadEliminated( entity victim )
{
	victim.EndSignal( "OnDestroy" )
	victim.EndSignal( "OnRespawned" )

	if ( GetCurrentPlaylistVarBool( "play_match_end_music_on_squad_eliminated", true ) && ( GetGameState() < eGameState.WinnerDetermined ))
	{
		// Can't use PlayMusicToPlayer(), because on the client, the music is played on the viewPlayer, so you to hear the wrong music if you are specating.
		StopAllMusicOnPlayer( victim )
		Remote_CallFunction_NonReplay( victim, "ServerCallback_PlayMatchEndMusic" )
	}

	Remote_CallFunction_NonReplay( victim, "ServerCallback_SquadEliminated", victim.GetTeam() )
	return
}


void function TEMP_PlayerZiplineTryUse( entity player, int heldCommand, bool groundCheck = false )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	while ( player.IsInputCommandHeld( heldCommand ) )
	{
		if ( !groundCheck || !player.IsOnGround() )
			player.Zipline_TryUse()
		WaitFrame()
	}
}

void function Survival_SetFriendlyOwnerHighlight( entity player, entity characterModel )
{

}

void function SURVIVAL_AddSpawnPointGroup( string ref )
{

}

// RateSpawnpoints_Directional implementation moved to mp/spawn.nut

bool function SURVIVAL_IsCharacterClassLocked( entity player )
{
	int stepIndex = Playlist() == ePlaylists.fs_scenarios ? player.GetPlayerNetInt( "characterSelectLockstepIndex" ) : GetGlobalNetInt( "characterSelectLockstepIndex" )
	return player.GetPlayerNetBool( "hasLockedInCharacter" ) || player.GetPlayerNetInt( "characterSelectLockstepPlayerIndex" ) != stepIndex
}

bool function SURVIVAL_IsValidCircleLocation( vector origin )
{
	return false
}

int function _GetSquadRank( entity player )
{
	return player.p.squadRank
}

void function JetwashFX( entity dropship )
{

}

void function Survival_PlayerRespawnedTeammate( entity playerWhoRespawned, entity respawnedPlayer )
{
	playerWhoRespawned.p.respawnsGiven++

	respawnedPlayer.p.respawnChanceExpiryTime = 0.0
	ClearPlayerEliminated( respawnedPlayer )

	StatsHook_PlayerRespawnedTeammate( playerWhoRespawned, respawnedPlayer )
}

void function UpdateDeathBoxHighlight( entity box, bool longerdist = false )
{
	if ( !IsValid( box ) )
		return

	if ( box.e.blockActive )
		return

	// if ( box.GetScriptName() == BLACK_MARKET_SCRIPTNAME )
		// return

	// foreach ( func in file.onDeathboxLootUpdatedCallbacks )
	// {
		// func( box )
	// }

	array<entity> itemsInBox = box.GetLinkEntArray()

	if ( itemsInBox.len() > 0 )
	{
		int maxTier = 1
		foreach ( loot in itemsInBox )
		{
			LootData data = SURVIVAL_Loot_GetLootDataByRef( loot.e.lootRef )
			if ( data.tier > maxTier )
				maxTier = data.tier
		}

		box.SetNetInt( "lootRarity", maxTier )
		Highlight_SetNeutralHighlight( box, SURVIVAL_GetHighlightForTier( maxTier, longerdist ) )
	}
	else
	{
		if ( box.GetTeam() == TEAM_UNASSIGNED )
		{
			vector o = box.GetOrigin()
			vector a = box.GetAngles()
			asset m  = box.GetModelName()
			entity p = box.GetParent()

			bool inBound = PositionIsInMapBounds( box.GetOrigin() )

			box.Destroy()

			if ( inBound )
			{
				entity newBox = CreatePropDynamic( m, o, a )
				if ( IsValid( p ) )
				{
					newBox.SetParent( p )
				}
				else
				{
					newBox.ClearParent()
				}
				EmitSoundAtPosition( TEAM_UNASSIGNED, o, "Object_Dissolve", newBox)
				newBox.Dissolve( ENTITY_DISSOLVE_CORE, < 0, 0, 0 >, 1000 )
			}

			return
		}
	}
}

float function Survival_GetMapFloorZ( vector field )
{
	field.z = SURVIVAL_GetPlaneHeight()
	vector endOrigin = field - < 0, 0, 50000 >
	TraceResults traceResult = TraceLine( field, endOrigin, [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	vector endPos = traceResult.endPos
	return endPos.z
}

vector function SURVIVAL_GetClosestValidCircleEndLocation( vector origin )
{
	return origin
}

void function SURVIVAL_CalculateAirdropPositions()
{
    calculatedAirdropData.clear()

    array<vector> previousAirdrops

    array<DeathFieldStageData> deathFieldData = SURVIVAL_GetDeathFieldStages()

    for ( int i = deathFieldData.len() - 1; i >= 0; i-- )
    {
        string airdropPlaylistData = GetCurrentPlaylistVarString( "airdrop_data_round_" + i, "" )

        if (airdropPlaylistData.len() == 0) //if no airdrop data for this ring, continue to next
            continue;

        //Split the PlaylistVar that we can parse it
        array<string> dataArr = split(airdropPlaylistData, ":" )
        if(dataArr.len() < 5)
            return;

        //First part of the playlist string is the number of airdrops for this round.
        int numAirdropsForThisRound = dataArr[0].tointeger()

        //Create our AirdropData entry now.
        AirdropData airdropData;
        airdropData.dropCircle = i
        airdropData.dropCount = numAirdropsForThisRound
        airdropData.preWait = dataArr[1].tofloat()

        //Get the deathfield data.
        DeathFieldStageData data = deathFieldData[i]

        vector center = data.endPos
        float radius = data.endRadius
        for (int j = 0; j < numAirdropsForThisRound; j++)
        {
            Point airdropPoint = FindRandomAirdropDropPoint(AIRDROP_ANGLE_DEVIATION, center, radius, previousAirdrops)

            if(!VerifyAirdropPoint( airdropPoint.origin, airdropPoint.angles.y % 360 ))
            {
                //force this to loop again if we didn't verify our airdropPoint
                j--;
            }
            else
            {
                previousAirdrops.push(airdropPoint.origin)
                //printt("Added airdrop with origin ", airdropPoint.origin, " to the array")
                airdropData.originArray.append(airdropPoint.origin)
                airdropData.anglesArray.append( Vector(airdropPoint.angles.x % 360, airdropPoint.angles.y % 360, airdropPoint.angles.z % 360) )

                //Should impl contents here.
                airdropData.contents.append([dataArr[2], dataArr[3], dataArr[4]])
            }
        }
        calculatedAirdropData.append(airdropData)
    }
    thread AirdropSpawnThink()
}

void function SURVIVAL_AddLootBin( entity lootbin )
{
	// InitLootBin( lootbin )
}

void function SURVIVAL_AddLootGroupRemapping( string hovertank, string supplyship )
{
	Survival_Loot_RegisterLootGroupRemap( hovertank, supplyship )
}

void function SURVIVAL_DebugLoot( string lootBinsLootInside, vector origin )
{

}

void function Survival_AddCallback_OnAirdropLaunched( void functionref( entity dropPod, vector origin ) callbackFunc )
{

}

void function Survival_AddCallback_OnPlayerKillDamage( void functionref(entity, var, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerKillDamage.contains( callbackFunc )) )
	file.Callbacks_OnPlayerKillDamage.append( callbackFunc )
}

void function Survival_AddCallback_OnAttackerSquadWipe( void functionref(entity, entity) callbackFunc ) //Cafe
{
	Assert( !(file.Callbacks_OnAttackerSquadWipe.contains( callbackFunc )) )
	file.Callbacks_OnAttackerSquadWipe.append( callbackFunc )
}

void function Survival_AddCallback_OnAttackerSoloRatEliminated( void functionref(entity, entity) callbackFunc ) //Cafe
{
	Assert( !(file.Callbacks_OnAttackerSoloRatEliminated.contains( callbackFunc )) )
	file.Callbacks_OnAttackerSoloRatEliminated.append( callbackFunc )
}


void function Survival_CleanupPlayerPermanents( entity player )
{

}

bool function IsValidLegendaryMagazine( string mod )
{
	switch( mod )
	{
		case "sniper_mag_l4":
		case "highcal_mag_l4":
		case "bullets_mag_l4":
		case "shotgun_bolt_l4":
		case "energy_mag_l4":

		return true
	}

	return false
}

void function Flowstate_CheckForLv4MagazinesAndRefillAmmo( entity player )
{
	if( !IsValid( player ) )
		return

	entity oldActiveWeapon
	entity activeWeapon

	while( IsValid( player ) )
	{
		wait 0.1

		if( !IsValid( player ) )
			break

		activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if( oldActiveWeapon == activeWeapon )
			continue

		oldActiveWeapon = activeWeapon

		array<entity> weapons = player.GetMainWeapons()

		foreach ( weapon in weapons )
		{
			if( !IsValid( weapon ) )
				continue

			if( weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
			{
				Signal( weapon, "Flowstate_RestartLv4MagazinesThread" )
				continue
			}

			string weaponRef = weapon.GetWeaponClassName()
			if ( !SURVIVAL_Loot_IsRefValid( weaponRef ) )
				continue

			LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
			if ( weaponData.lootType != eLootType.MAINWEAPON )
				continue

			array<string> mods = clone weapon.GetMods()

			foreach( mod in mods )
				if( IsValidLegendaryMagazine( mod ) )
					thread Flowstate_Lv4MagazinesRefillAmmo_Thread( player, weapon )
		}
	}
}

void function Flowstate_Lv4MagazinesRefillAmmo_Thread( entity player, entity weapon )
{
	Signal( weapon, "Flowstate_RestartLv4MagazinesThread" )
	EndSignal( weapon, "Flowstate_RestartLv4MagazinesThread" )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( player, "OnDeath" )

	wait 5

	if( !IsValid( weapon ) || !IsValid( player ) || !IsAlive( player ) || weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) || !weapon.UsesClipsForAmmo() )
		return

	int ammoType = weapon.GetWeaponAmmoPoolType()
	string ammoRef = AmmoType_GetRefFromIndex( ammoType )
	int ammoInInventory = SURVIVAL_CountItemsInInventory( player, ammoRef )

	if( ammoInInventory == 0 )
		return

	int currentAmmo = weapon.GetWeaponPrimaryClipCount()
	int maxAmmo = weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size )

	if( currentAmmo == maxAmmo )
		return

	int requiredAmmo = maxAmmo - currentAmmo
	int ammoToRemove = int( min( requiredAmmo, ammoInInventory ) )

	weapon.SetWeaponPrimaryClipCount( currentAmmo + ammoToRemove )
	SURVIVAL_RemoveFromPlayerInventory( player, ammoRef, ammoToRemove )
	weapon.SetWeaponPrimaryAmmoCount( AMMOSOURCE_POOL, min( SURVIVAL_CountItemsInInventory( player, ammoRef ), weapon.GetWeaponPrimaryAmmoCountMax( AMMOSOURCE_POOL ) ) )
	EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_Boost_Card_Earned_1P" )
}

float MaxFallDistanceForDamage = 400.0

void function LSM_OnPlayerTouchGround( entity player )
{
	if( !player.e.IsFalling )
		return

	if ( player.IsNoclipping() )
		return

	player.e.IsFalling = false

	vector landingdist = <player.e.FallDamageJumpOrg.x, player.e.FallDamageJumpOrg.y, player.GetOrigin().z>
	float fallDist = Distance(player.e.FallDamageJumpOrg, landingdist)

	printf("Fall Distance: " + fallDist)

	if(fallDist < MaxFallDistanceForDamage)
		return

	float Damagemultiplier = 0.035

	if(fallDist > 1000)
		Damagemultiplier = 0.05

	player.TakeDamage( Damagemultiplier * fallDist, null, null, { damageSourceId=damagedef_suicide } )
}

void function LSM_OnPlayerLeaveGround( entity player )
{
	if( player.e.IsFalling )
		return

	if( player.IsNoclipping() )
		return

	player.e.IsFalling = true

	player.e.FallDamageJumpOrg = player.GetOrigin()
}

void function SURVIVAL_SetMapCenter( vector c )
{
	file.mapCenter = c
}

vector function SURVIVAL_GetMapCenter()
{
	return file.mapCenter
}

void function SURVIVAL_SetPlaneHeight( float height )
{
	file.planeHeight = height
}

float function SURVIVAL_GetPlaneHeight()
{
	return file.planeHeight
}


void function SetPlayerIntroDropSettings( entity player )
{
	if ( player.p.hasDropSettings )
		return

	player.p.hasDropSettings = true
	HolsterAndDisableWeapons( player )
	player.ResetIdleTimer()

	//if ( !player.p.survivalLandedOnGround && !player.IsInvulnerable() )
	//	player.SetInvulnerable()
	player.ClearInvulnerable()
	// DisableEntityOutOfBounds( player ) //FIXME. Cafe

	// Clear death protection the player had in the staging area. We don't do this when leaving "WaitingForPlayers" state because we don't want players taking damage in PickLoadout state either, which can happen with DOT entities left laying around
	// if ( player.p.hasStagingAreaDamageProtection )
	// {
		// RemoveEntityCallback_OnDamaged( player, StagingAreaPlayerTookDamageCallback )
		// player.p.hasStagingAreaDamageProtection = false
	// }
}


void function ClearPlayerIntroDropSettings( entity player )
{
	if ( !player.p.hasDropSettings )
		return

	player.p.hasDropSettings = false

	// Called by whatever script is handling the player deployment into the map. Once that script gets the player to the ground it should call this.
	player.ClearInvulnerable()
	player.UnforceStand()

	if ( IsAlive( player ) )
	{
		vector playerOrigin = player.GetOrigin()
		if ( !player.IsZiplining() )
			PutEntityInSafeSpot( player, null, null, playerOrigin, playerOrigin )
	}

	player.p.survivalLandedStartTime = Time()

	if ( player.GetPlayerNetBool( "isJumpmaster" ) )
	{
		player.p.wasJumpmaster = true //used for tracking stats at the end of the game
		player.p.wasLastJumpmaster = true
	}
	else
	{
		player.p.wasLastJumpmaster = false
	}
	// remove jumpmaster star from the unitframe
	player.SetPlayerNetBool( "isJumpmaster", false )
	GradeFlagsClear( player, eTargetGrade.JUMPMASTER )

	Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )
	Highlight_ClearEnemyHighlight( player )

	// Undo stuff we did in SetPlayerIntroDropSettings
	// R5DEV-363382: strange mismatch between these two. Server_IsOffhandWeaponsDisabled seems to not be set in cases where the player disconnects,
	//   even though the entity is valid and we can still manipulate it. This may explain the behaviour needing investigation (read comment above DisableOffhandWeapons in _utility.gnut)
	if ( player.Server_IsOffhandWeaponsDisabled() )
		DeployAndEnableWeapons( player )
	// EnableEntityOutOfBounds( player )

	//Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerBootsOnGround" )
	Remote_CallFunction_ByRef( player, "ServerCallback_PlayerBootsOnGround" )

	// Only modify the player's ultimate and tactical the first time they land on the ground, not again when using balloon towers, etc.
	if ( !player.p.survivalLandedOnGround )
	{
		entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		if ( IsValid( tacticalWeapon ) && GetCurrentPlaylistVarBool( "survival_give_tactical_on_first_land", true ))
		{
			// Give player their tactical when they land, or all but 1 of their charges if tac has multiple charges
			tacticalWeapon.RemoveMod( "survival_ammo_regen_paused" )
			tacticalWeapon.SetWeaponPrimaryClipCountAbsolute( tacticalWeapon.GetWeaponSettingInt( eWeaponVar.ammo_default_total ) )
			tacticalWeapon.RegenerateAmmoReset()
		}

		entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( IsValid( ultimateWeapon ) && GetCurrentPlaylistVarBool( "survival_reset_ultimate_on_first_land", true ) )
		{
			// Restart ultimate cooldown from the beginning when we land on the ground
			ultimateWeapon.RemoveMod( "survival_ammo_regen_staging" )
			ultimateWeapon.RemoveMod( "survival_ammo_regen_paused" )
			ultimateWeapon.SetWeaponPrimaryClipCountAbsolute( 0 )
			// if ( PlayerHasPassive( player, ePassives.PAS_LOBA_EYE_FOR_QUALITY ) )
				// ultimateWeapon.SetWeaponPrimaryClipCountAbsolute( int( ultimateWeapon.GetWeaponPrimaryClipCountMax() * 0.5 ) )

			ultimateWeapon.RegenerateAmmoReset()
		}

		PIN_PlayerLandedOnGround( player )
		// StatsHook_OnPlayerLandedSkydive( player )

		// foreach ( callbackFunc in file.Callbacks_OnPlayerLandedFromDropshipFreefall )
			// callbackFunc( player )
	}

	// Allow player to emote
	// SetPlayerCanGroundEmote( player, true )

	PlayerMatchState_Set( player, ePlayerMatchState.NORMAL )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )

	Survival_SetInventoryEnabled( player, true )

	if( !(EHIToEncodedEHandle( player ) in file.playerData) )
	{
		SurvivalPlayerData data
		file.playerData[EHIToEncodedEHandle( player )] <- data
	}

	file.playerData[ EHIToEncodedEHandle( player ) ].hasJumpedOutOfPlane = true
	file.playerData[ EHIToEncodedEHandle( player ) ].landingOrigin       = player.GetOrigin()
	file.playerData[ EHIToEncodedEHandle( player ) ].landingTime         = Time()

	// #if DEVELOPER
		// DEV_GiveSpawnWeapons( player )
	// #endif

	thread PlayerFallAssistanceDetection( player )

	player.p.survivalLandedOnGround = true
}

void function Survival_SetPlayerHasJumpedOutOfPlane( entity player )
{
	file.playerData[ EHIToEncodedEHandle( player ) ].hasJumpedOutOfPlane = true
}

float function Survival_GetPlayerTimeOnGround( entity player )
{
	if ( file.playerData[ EHIToEncodedEHandle( player ) ].landingTime <= 0 )
		return 0

	return Time() - file.playerData[ EHIToEncodedEHandle( player ) ].landingTime
}

bool function Survival_HasPlayerJumpedOutOfPlane( entity player )
{
	return ( EHIToEncodedEHandle( player ) in file.playerData && file.playerData[ EHIToEncodedEHandle( player ) ].hasJumpedOutOfPlane == true )
}

SurvivalPlayerData function Survival_GetPlayerData( EncodedEHandle playerEncodedEHandle )
{
	return file.playerData[ playerEncodedEHandle ]
}

//  Mackey suggested we create a passive weapon mod (new!).
//  To get this to work we needed to move where this gets called, originally in Survival_OnPlayerRespawnedInit
//  to Survival_PlayerCharacterSetup (so that the passive can get a chance to be removed when we switch characters).
void function Survival_SetupWeaponMods( entity player )
{
	array mods = player.GetExtraWeaponMods()
	if ( GetCurrentPlaylistVarBool( "survival_viewkick_patterns", false ) )
		mods.append( "vkp" )

	string extraModsStr     = GetCurrentPlaylistVarString( "player_extra_weapon_mods", "" )
	array<string> extraMods = GetTrimmedSplitString( extraModsStr, " " )
	mods.extend( extraMods )

	mods.append( "survival_finite_ordnance" )
	player.SetExtraWeaponMods( mods ) // gets cleared on death
}

void function Survival_PlayerCharacterSetup( entity player, ItemFlavor character, bool giveDefaultMelee = true )
{
	if ( !IsAlive( player ) )
		return

	if ( IsLobby() )
		return

	player.TakeOffhandWeapon( OFFHAND_TACTICAL )
	player.TakeOffhandWeapon( OFFHAND_ULTIMATE )

	TakeAllPassives( player )

	// clear all mods (b/c we added a passive weapon mod, we have to
	//  explicitly clear the passive mods if we were to change character types, and we have to
	//  reapply the mods that are true for all survival games.
	ClearExtraWeaponMods( player )
	Survival_SetupWeaponMods( player )

	if( Playlist() == ePlaylists.fs_haloMod_survival )
	{
		asset setFile = CharacterClass_GetSetFile( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00898565421" ) ) ) //Give bloodhound always in halo mod survival
		player.SetPlayerSettingsWithMods( setFile, [] )
	} else
	{
		asset setFile = CharacterClass_GetSetFile( character )
		player.SetPlayerSettingsWithMods( setFile, [] )
	}

	// GiveLoadoutRelatedWeapons( player )

	// camo and skin are set elsewhere

	// Setup shields ( if player isn't bleeding out ):
	// if( !Bleedout_IsBleedingOut( player ) )
	// {
		// string itemRef = EquipmentSlot_GetLootRefForSlot( player, "armor" )
		// if ( SURVIVAL_Loot_IsRefValid( itemRef ) )
		// {
			// LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )
			// player.SetShieldHealthMax( SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data ) )
		// }
		// else
		// {
			// player.SetShieldHealthMax( GetPlayerSettingBaseShield( player ) )
		// }
		// player.SetShieldHealth( player.GetShieldHealthMax() )
	// }

	// passives
	// {
		// foreach ( ItemFlavor passiveAbility in CharacterClass_GetPassiveAbilities( character ) )
		// {
			// GivePassive( player, CharacterAbility_GetPassiveIndex( passiveAbility ) )

			// // Attach passive specific weapon mods to a player

			// string passiveWeaponMod = CharacterAbility_GetPassiveWeaponMod( passiveAbility )
			// if ( passiveWeaponMod != "" )
				// GiveExtraWeaponMod( player, passiveWeaponMod )
		// }

		// float damageScale = CharacterClass_GetDamageScale( character )
		// if ( damageScale < 1.0 ) // TODO: it's a bit backwards the the playlist var drives the passive, that that's how it is for now
			// GivePassive( player, ePassives.PAS_FORTIFIED )
		// else if ( damageScale > 1.0 )
			// GivePassive( player, ePassives.PAS_LOWPROFILE )
	// }

	// // tactical
	// {
		// ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )
		// player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL, [] )
		// entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		// tacticalWeapon.SetWeaponPrimaryClipCount( tacticalWeapon.GetWeaponPrimaryClipCountMax() ) // give tactical straight away
		// if ( GetCurrentPlaylistVarBool( "survival_give_tactical_on_first_land", true ) )
		// {
			// if ( !player.p.survivalLandedOnGround )
				// tacticalWeapon.AddMod( "survival_ammo_regen_paused" )
		// }

		// Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", tacticalWeapon )
	// }

	// // ultimate
	// {
		// ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( character )
		// player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE, [] )

		// entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )

		// float fireDuration = ultimateWeapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
		// player.p.lastPilotOffhandUseTime[ OFFHAND_INVENTORY ] = Time() - fireDuration // track ultimate usage
		// player.p.lastPilotClipFrac[ OFFHAND_INVENTORY ]       = 0.0

		// // If we haven't landed and begun the game yet, let the ultimate charge faster (staging)
		// if ( GetGameState() <= eGameState.WaitingForPlayers )
		// {
			// ultimateWeapon.AddMod( "survival_ammo_regen_paused" )
		// }

		// if ( !player.p.survivalLandedOnGround )
			// ultimateWeapon.AddMod( "survival_ammo_regen_paused" )
	// }

	// // Put the player in a safe spot if they aren't parented to anything
	// // This is needed because they may be switching to a larget character that now is stuck in geo
	// entity parentEnt = player.GetParent()
	// if ( !IsValid( parentEnt ) && !player.Anim_IsActive() )
	// {
		// array< vector > navmeshPositions = NavMesh_GetClosestPoints( player.GetOrigin(), 32 )

		// foreach ( vector navmeshPosition in navmeshPositions )
		// {
			// if ( PlayerCanTeleportHere( player, navmeshPosition ) )
			// {
				// PutPlayerInSafeSpot( player, null, null, navmeshPosition, navmeshPosition )
				// break
			// }
		// }
	// }

	// if( giveDefaultMelee )
		// SURVIVAL_TryGivePlayerDefaultMeleeWeapons( player )

	// Inventory_RefreshAllPlayerEquipment( player )

	// foreach ( func in file.Callbacks_OnPlayerSetupComplete )
	// {
		// func( player )
	// }
}

void function Survival_OnPlayerRespawned( entity player )
{
	SurvivalPlayerRespawnedInit( player )
}


void function SurvivalPlayerRespawnedInit( entity player )
{
	bool resetPlayerInventoryOnRespawn = Survival_ShouldResetInventoryOnRespawn( player )

	UpdatePlayerCounts()

	player.SetAimAssistAllowed( true )
	player.TurnLowHealthEffectsOff()
	player.AmmoPool_SetCapacity( SURVIVAL_MAX_AMMO_PICKUPS )

	#if DEVELOPER
		if ( file.DEV_overrideSpawnCharacterOrNull != null )
		{
			SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), expect ItemFlavor(file.DEV_overrideSpawnCharacterOrNull) )

			if ( file.DEV_overrideSpawnCharacterSimpleEquip )
			{
				LoadoutEntry meleeSkinSlot = Loadout_MeleeSkin( expect ItemFlavor(file.DEV_overrideSpawnCharacterOrNull) )
				// ensure no special weapons
				DEV_RequestSetItemFlavorLoadoutSlot( ToEHI( player ), meleeSkinSlot, meleeSkinSlot.defaultItemFlavor )
				// if Dummie, ensure black skin
				if ( file.DEV_overrideSpawnCharacterOrNull == GetItemFlavorByAsset( CHARACTER_DUMMIE ) )
				{
					const int DUMMIE_BLACK_SKIN = 1524874502
					if ( IsValidItemFlavorGUID( DUMMIE_BLACK_SKIN ) )
						DEV_RequestSetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_CharacterSkin( GetItemFlavorByAsset( CHARACTER_DUMMIE ) ), GetItemFlavorByGUID( DUMMIE_BLACK_SKIN ) )
				}
			}
		}
	#endif

	Survival_PlayerCharacterSetup( player, Survival_ValidateAndGetCharacterClass( player ) )

	SURVIVAL_SetDefaultPlayerSettings( player )

	if ( WeaponDrivenConsumablesEnabled() )
	{
		player.TakeOffhandWeapon( OFFHAND_SLOT_FOR_CONSUMABLES )
		player.GiveOffhandWeapon( CONSUMABLE_WEAPON_NAME, OFFHAND_SLOT_FOR_CONSUMABLES )
	}

	if ( resetPlayerInventoryOnRespawn && player.p.survivalLandedOnGround ) // Only take ammo on a respawn and not on first drop
		TakeAmmoFromPlayer( player )

	Ultimates_OnPlayerRespawned( player )

	//player.GiveOffhandWeapon( HOLO_PROJECTOR_WEAPON_NAME, HOLO_PROJECTOR_INDEX )
	//player.GiveOffhandWeapon( "mp_ability_generic_offhand", 7 )


	//player.DisableIdLights()
	//player.DisableAutoReloadNoAmmo()

	if ( GetGameState() == eGameState.WaitingForPlayers )
	{
		if( EHIToEncodedEHandle( player ) in file.playerChangeClassData )
		{
			EncodedEHandle handle = EHIToEncodedEHandle( player )
			player.SetOrigin( file.playerChangeClassData[handle].respawnPos )
			player.SetAngles( file.playerChangeClassData[handle].respawnAngles )
			if ( file.playerChangeClassData[handle].respawnIn3P )
				player.SetThirdPersonShoulderModeOn()
			else
				player.SetThirdPersonShoulderModeOff()
		}

		thread Survival_SetStagingAreaSettings( player )
	}
	else if ( GetGameState() < eGameState.Playing )
	{
		if ( GetGameState() == eGameState.Prematch )
		{
			if ( !player.p.hasMatchParticipationStarted )
				OnPlayerMatchParticipationStarted( player )
		}

		Survival_SetPrematchSettings( player )
	}
	else if ( !player.p.respawnPodLanded )
	{
		// respawnPodLanded will be set during a respawn from a respawn beacon, so we don't want to do anything special there. This only runs if it's not a respawn beacon

		// This shouldn't be allowed, but it's happening, either in DEV through manual connect or slow loading and server wait for player timeout

		if ( !player.p.hasMatchParticipationStarted )
			OnPlayerMatchParticipationStarted( player )
		SetPlayerIntroDropSettings( player )

		array<entity> teammates = GetPlayerArrayOfTeam_Alive( player.GetTeam() )

		// If we have no teammates and the plane exists we put the player in the plane
		// Or, if we have teammates in the plane we also put them in the plane with their team
		bool putInPlane                  = teammates.len() == 1 && IsValid( Sur_GetPlaneEnt() ) && !Flag( "PlaneAtLaunchPoint" )
		entity skydiveFollowPlayer
		bool skydiveFollowPlayerIsLeader = false
		entity groundPlayer
		foreach ( entity teammate in teammates )
		{
			if ( teammate == player )
				continue

			if ( teammate.GetPlayerNetBool( "playerInPlane" ) == true )
				putInPlane = true

			if ( PlayerMatchState_GetFor( teammate ) == ePlayerMatchState.SKYDIVE_FALLING && !skydiveFollowPlayerIsLeader )
			{
				skydiveFollowPlayer = teammate
				if ( teammate.GetPlayerNetBool( "isJumpmaster" ) )
				{
					skydiveFollowPlayerIsLeader = true
				}
			}

			if ( PlayerMatchState_GetFor( teammate ) == ePlayerMatchState.NORMAL )
				groundPlayer = teammate
		}

		if ( putInPlane )
		{
			// Put in plane with teammates, or by themselves if the plane is still flying over
			Survival_PutPlayerInPlane( player )
		}
		else if ( IsValid( skydiveFollowPlayer ) )
		{
			// no teammates are still in the plane, follow someone who's skydiving
			thread PlayerSkyDive( player, <0, 0, 0>, teammates, skydiveFollowPlayer )
		}
		else
		{
			// if a player is on the ground already, just spawn them near that player
			ClearPlayerIntroDropSettings( player )
			if ( IsValid( groundPlayer ) )
				player.SetOrigin( groundPlayer.GetOrigin() )
		}
	}

	// Player has respawned, remove change class data
	if( EHIToEncodedEHandle( player ) in file.playerChangeClassData )
		delete file.playerChangeClassData[ EHIToEncodedEHandle( player ) ]

	#if !HAS_ENEMY_NAMES_OVERHEAD
		player.SetNameVisibleToEnemy( false )
	#endif

	thread Survival_ResetPlayerHighlights()

	if ( GetCurrentPlaylistVarBool( "thirdperson_match", false ) )
		player.SetThirdPersonShoulderModeOn()
}

bool function Survival_ShouldResetInventoryOnRespawn( entity player )
{
	if( !IsValid( player ) )
	{
		Warning( "Survival_ShouldResetInventoryOnRespawn called with invalid player!" )
		return true
	}

	bool resetPlayerInventoryOnRespawn = true
	if( GetCurrentPlaylistVarBool( "reset_player_inventory_on_respawn", true ) == false && player.p.respawnCount > 1 )
		resetPlayerInventoryOnRespawn = false

	if( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_TRAINING ) )
		resetPlayerInventoryOnRespawn = true

	if( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) && !FRC_IsPlayerActiveForChallenge ( player ) )
		resetPlayerInventoryOnRespawn = false

	if ( IsEventFinale() )
		resetPlayerInventoryOnRespawn = false







	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) )
		resetPlayerInventoryOnRespawn = false



	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_STRIKEOUT )  )
		resetPlayerInventoryOnRespawn = false


//%if HAS_FREERESPAWNS
//	if( FreeRespawns_DontResetInventory() )
//		resetPlayerInventoryOnRespawn = false
//%endif // HAS_FREERESPAWNS

	if( RespawnEquipped_DontResetInventory() )
		resetPlayerInventoryOnRespawn = false
















	return resetPlayerInventoryOnRespawn
}


void function SURVIVAL_SetDefaultPlayerSettings( entity player )
{
	if ( player.GetTeam() == TEAM_SPECTATOR )
		return

	asset settings = player.GetPlayerSettings()
	if ( settings == SPECTATOR_SETTINGS )
		return

	if ( GetCurrentPlaylistVarInt( "survival_jumpkit_enabled", 0 ) > 0 )
		GivePlayerSettingsMods( player, ["enable_doublejump"] )

	if ( GetCurrentPlaylistVarInt( "survival_wallrun_enabled", 0 ) > 0 )
		GivePlayerSettingsMods( player, ["enable_wallrun"] )
}


void function Survival_SetPrematchSettings( entity player )
{
	if ( file.shouldFreezeControlsOnPrematch )
		player.FreezeControlsOnServer()
}


void function Survival_ClearPrematchSettings( entity player )
{
	if ( file.shouldFreezeControlsOnPrematch )
		player.UnfreezeControlsOnServer()
}

int function Survival_GetPlayerRealm( entity player )
{
	foreach ( realm in Survival_Loot_GetRealmsToPopulate() )
	{
		if ( player.IsInRealm( realm ) )
			return realm
	}

	return eRealms.DEFAULT
}

void function Survival_ResetPlayerHighlights()
{
	foreach ( player in GetPlayerArray() )
	{
		//Remove ALL player highlights
		Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )

		//array<entity> teamMemberList = GetPlayerArrayOfTeam_Alive( player.GetTeam() )
		//teamMemberList.sort( SortByEntIndex )
		//int playerTeamSlot = teamMemberList.find( player ) % 3
		//switch ( playerTeamSlot ) {
		//	case 0:
		//		Highlight_SetFriendlyHighlight( player, "survival_friendly_0" )
		//		break
		//	case 1:
		//		Highlight_SetFriendlyHighlight( player, "survival_friendly_1" )
		//		break
		//	case 2:
		//		Highlight_SetFriendlyHighlight( player, "survival_friendly_2" )
		//		break
		//}

		player.e.hasDefaultEnemyHighlight = false
		Highlight_ClearEnemyHighlight( player )

		Highlight_SetOwnedHighlight( player, "survival" )
		Highlight_SetNeutralHighlight( player, "survival" )

		// ClientCommand( player, "force_id_lights_off 1" )

		// Highlight_SetEnemyHighlight( player, "" )
	}
}

void function EndThreadOn_PlayerChangedClass( entity player )
{
	EndSignal( player, "PlayerChangedClass" )
}


void function SignalThatPlayerChangedClass( entity player )
{
	player.Signal( "PlayerChangedClass" )
}

void function FS_HaloMod_OnPlayerZoomIn( entity player )
{
	if( !IsValid( player ) )
		return

	GiveExtraWeaponMod( player, "unsc_super_soldier" )
}

void function FS_HaloMod_OnPlayerZoomOut( entity player )
{
	if( !IsValid( player ) )
		return

	TakeExtraWeaponMod( player, "unsc_super_soldier" )
}