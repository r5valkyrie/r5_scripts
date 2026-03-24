global function Survival_OnClientConnected
global function Survival_OnResolution

global function SurvivalPlayerRespawnedInit
global function GamemodeSurvival_Init
global function SetPlayerIntroDropSettings
global function ClearPlayerIntroDropSettings
global function Survival_GetPlayerData
global function Survival_RunPlaneLogic_Thread
global function Survival_GenerateSingleRandomPlanePath
global function Survival_RunSinglePlanePath_Thread




global function Survival_HasPlayerJumpedOutOfPlane
global function DoCleanupPlayerPermanents
global function EndThreadOn_PlayerCleanupPermanents
global function EndThreadOn_PlayerChangedClass
global function Survival_GetMapFloorZ
global function Survival_SetMapFloorZ
global function Survival_PlayerWasActive
global function Survival_GetOffhandMeleeWeaponName
global function Survival_GetMeleeWeaponName
global function Survival_ShouldResetInventoryOnRespawn
global function Survival_AirdroppedCarePackagesEnabled

// functions to facilitate writing OnTookDamage and OnTookHeadshot callbacks for npcs elsewhere.
global function Survival_GetPlayerLastDamageSlowTime
global function Survival_GetBodyshotDamageScale
global function Survival_GetHeadshotDamageScale
global function Survival_DamageShouldSlowDownPlayer
global function Survival_ShouldBypassCharacterDamageScale

global function OnPlayerMatchParticipationEnded
global function PlayCharacterSelectMusicToAllPlayersIfNeeded
global function GetReportReasons

global function SURVIVAL_SetDefaultPlayerSettings
global function SURVIVAL_IsCharacterClassLocked

global function Survival_IsJumpFromPlaneEnabled
global function Survival_IsPlaneEnabled

global function GetSurvivalSquadPINData

global function CodeCallback_KillDamagePlayerOrNPC

global function SURVIVAL_SetPlane
global function SURVIVAL_SetPlaneHeight
global function SURVIVAL_GetPlaneHeight
global function SURVIVAL_GetPlaneJumpDuration
global function SURVIVAL_SetMapCenter
global function SURVIVAL_GetMapCenter



global function SURVIVAL_SetFlightAngleAdjustment
global function SURVIVAL_GetFlightAngleAdjustment
global function SURVIVAL_SetPlaneOverridePathRegion
global function SURVIVAL_SetPlaneJumpStartPos
global function SURVIVAL_GetPlaneJumpStartPos
global function SURVIVAL_SetPlaneJumpEndPos
global function SURVIVAL_GetPlaneJumpEndPos
global function SURVIVAL_SetAirburstHeight
global function SURVIVAL_GetAirburstHeight
global function Survival_SetFriendlyHighlight
global function Survival_SetFriendlyOwnerHighlight
global function Survival_ResetPlayerHighlights
global function Survival_SetInventoryEnabled
global function Survival_PlayerRespawnedTeammate
global function Survival_PlayerDealtDamage
global function Survival_PlayerCharacterSetup
global function Survival_GetPlayerRealm
global function Survival_GetPlayerTimeOnGround
global function Survival_GetPlaneJumpPointOverMap
global function Survival_SetPlayerHasJumpedOutOfPlane

global function Survival_SetFreezeControlsOnPrematch
global function Survival_SetForceRandomOnSkippedCharacterSelecttion
global function Survival_AddCallback_OnGameAutoSelectedCharacter
global function Survival_AddCallback_OnPlayerLockedInCharacter
global function Survival_AddCallback_OnPlayerHealingStarted
global function Survival_AddCallback_OnPlayerHealingEnded
global function Survival_AddCallback_OnSquadEliminated
global function Survival_AddCallback_IsSquadReallyEliminated
global function Survival_AddCallback_OnPlayerLandedFromDropshipFreefall
global function Survival_AddCallback_OnPlayerKillDamage

global function Survival_AddCallback_OnPlayerGameSummaryKill
global function Survival_AddCallback_OnPlayerGameSummaryAssist
global function Survival_AddCallback_OnPlayerGameSummaryKnockdown
global function Survival_AddCallback_OnPlayerGameSummaryKnockdownAssist
global function Survival_AddCallback_OnPlayerGameSummaryStatChanged

global function Survival_AddCallback_OnPlayerSetupComplete
global function Survival_SetCallback_ModeShouldSpawnPlayersDuringCharacterSelect
global function Survival_OverrideGetLivingPlayerCountFunction
global function Survival_OverrideGetRemainingSquadsFunction
global function UpdatePlayerCounts

global function _GetSquadRank

global function PlayerGameSummary_GetKills
global function PlayerGameSummary_GetDeaths
global function PlayerGameSummary_GetAssists
////
global function Survival_OnPlayerChangedCharacterClass
////

global function Survival_GetLootTypeForStatString
global function Survival_ShouldProcessSurvivalEventForCurrentMode

global function Survival_OnReloadPressed

global function GameSummary_GetPlayerData
global function GameSummary_GetTeamDataOrNull
global function GameSummary_GetHighestSurvivalTime
global function GameSummary_FinalizeData

global function SURVIVAL_SendWinningSquadDataToPlayer
global function UpdateSquadDataForTeamChange
global function HandleSquadElimination
global function Survival_SquadEliminationCleanup
global function IsSquadReallyEliminated
global function InformPlayerSquadEliminated
global function Survival_WillSquadBeEliminatedIfPlayerLeaves
global function Survival_IsPlayerSquadEliminated
global function CalcSecondsAliveForPlayer

global function Survival_SetCallback_Leviathan_ConsiderLookAtEnt
global function Leviathan_ConsiderLookAtEnt

global entity WORKAROUND_DESERTLANDS_TRAIN = null

global float g_DOOR_OPEN_TIME = 0
global function GiveRandomStartingLoot
global function OpenAndClosePlaneDoor

global function SetPlayerTeleportFunctionOverride

global function Survival_SetGameResultFlags
global function Survival_GetGameResultFlags
global function Survival_SetGameScoreFlags
global function Survival_GetGameScoreFlags

global function ShouldDoBleedout

global function ClientCallback_Sur_RequestSquadDataPersistence
global function ClientCallback_Sur_UpdateCharacterLock
global function ClientCallback_Sur_UseHealthPack
global function ClientCallback_Sur_DropBackpackItem
global function ClientCallback_Sur_DropBackpackItem_Box
global function ClientCallback_Sur_DropEquipment
global function ClientCallback_Sur_EquipOrdnance
global function ClientCallback_Sur_EquipGadget
global function ClientCallback_Sur_EquipAttachment
global function ClientCallback_Sur_UnequipAttachment
global function ClientCallback_Sur_TransferAttachment

global function ClientCallback_Sur_CancelHeal

global function ClientCallback_TPPromptGoToMapPoint
global function CodeCallback_ReportPlayerCustomerService
global function ProjectX_DumpGameSummarySquadData

global function Survival_FiringRange_IsCharacterRespawning
global function OnPlayerTookHeadshot

global function DeadPeriodChecker_PlayerDeadPeriodEnd
global function DeadPeriodChecker_PlayerGrabbedItem

#if DEVELOPER
global function TEMP_PotentiallyAFK
global function DEV_TestNitroSpawning // globalized for dev testing / calling from console

global function DEV_GiveSpawnWeapons
global function Dev_ForceLaunchCharacterSpawning
global function DEV_SimulatePlanePaths

global function TestPrompt_RevealMyLastDeathbox

#if ASSERTS
global function Test_Survival_GenerateSingleRandomPlanePath
#endif //ASSERTS
#endif //DEVELOPER

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

const float GAMETIME_LIMIT_FOR_AFK = 60.0

global const asset SURVIVAL_LOOT_POD_MODEL = $"mdl/vehicle/droppod_loot/droppod_loot_animated.rmdl"
global const asset SURVIVAL_LOOT_POD_DOOR_MODEL = $"mdl/rocks/rock_jagged_granite_small_01_phys.rmdl" // $"mdl/vehicle/doppod_loot/droppod_loot_animated.rmdl"

const string DROPPOD_DOOR_SOUND = "droppod_door_open"
const string KNOCKED_SOUND = "flesh_bulletimpact_downedshot_3p_vs_3p"

global const int AIR_DROP_BAD_PLACE_RADIUS = 196

global const float REALBIG_CIRCLE_GRID_RADIUS = 52500
const float PLANE_HEIGHT_REALBIG = 17000.0

const float KILL_STRING_COOLDOWN = 15.0

const bool MATCH_STORAGE_DEBUG = false

const float SURVIVAL_AUTOTHANKS_TIMEOUT = 5.0

const float SURVIVAL_PLANE_DROP_RADIUS_MIN = 22000

const float CLAMP_TO_RING_BUFFER = 400

const bool DEBUG_PLANE_PATH = false
const bool DEBUG_PLANE_PATH_LIGHTWEIGHT = false
const bool DEBUG_PLANE_PATH_JUMP = true





const bool PLANE_PATH_DEBUG = false

// TODO: CLEANUP if not needed here.
const vector AIRDROP_MAXS = <64,64,256>
const vector AIRDROP_MINS = <-64,-64,0>

typedef CallbackType_Leviathan_ConsiderLookAtEnt void functionref( entity ent, float duration, float careChance )

global enum eDeadPeriodEndReason
{
	UNKNOWN_REASON = -1
	DEALT_DAMAGE_TO_PLAYER = 0
	DEALT_DAMAGE_TO_NPC = 1
	TOOK_DAMAGE_FROM_PLAYER = 2
	TOOK_DAMAGE_FROM_NPC = 3
	RESPAWNED_TEAMMATES = 4
	PINGED_ENEMY = 5
}

global struct GameSummarySquadData
{
	// We store this off because we need the data even if the player disconnects.
	// Also it's cheaper to just store it here globally than to update teammates persistence seperately each time one of these values changes
	string                      playerName
	ItemFlavor&                 character
	int                         eHandle
	int                         survivalTime
	int                         kills
	int                         assists
	int							knockdowns
	int							knockdownAssists
	table<EncodedEHandle, int > playerKills
	int                         damageDealt
	int                         shots
	int                         hits
	int                         headshots
	int                         revivesGiven
	int                         respawnsGiven
	int                         deaths
	string                      platformUid
	string                      hardware
	string                      pid
	string                      nucleus
	bool                        optOutOfSendingSquadInfo
	bool                        dealtDamageLateInTheGame
	bool                        lootedLateInTheGame
	bool                        isUsingSteam

	/* the idea here is to provide a flex table for mode-specific information
	 * and then each mode should have a new set of *global* enum keys for specific stats
	 * the stat enums should correspond to where on the normal death screen UI we want info displayed
	 * table< DISPLAY_ARRAY_IDX, VALUE >
	 */
	table< int, int > modeMetaData

	array< int > displayData = SUMMARY_DISPLAY_EMPTY_SET
	bool displayData3IsTime
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
}

// Cache origin/angles when changing class in Firinge Range, to be reapplied after respawning
struct PlayerChangeClassData
{
	vector respawnPos = <0, 0, 0>
	vector respawnAngles = <0, 0, 0>
	bool   respawnIn3P = false
}

global struct SurvivalSquadPINData
{
	int             numMembers
	table<int, int> memberScores
}

global struct Survival_Plane
{
	entity baseEnt
	entity mover
	entity centerEnt
}

struct
{
	int gameStartUnixTime = -1

	int numPlayerAtStart
	int numSquadsAtStart

	table<int, SurvivalSquadPINData> squadPINData

	vector mapCenter = <0, 0, 0>

	Survival_Plane plane
	vector planeJumpStartPos
	vector planeJumpEndPos
	float  flyOverMapDuration
	float  planeFlightAngleAdjustment





	// Override where the plane goes
	vector planeOverridePathCenter
	float  planeOverridePathRadius
	bool   planeOverridePathSet

	table<EncodedEHandle, SurvivalPlayerData>        playerData
	table<string, EncodedEHandle>                    playerUIDToEncodedEHandleMap
	table<EncodedEHandle, PlayerChangeClassData>	 playerChangeClassData

	float mapFloorZ = -3000
	float planeHeight = 12000
	float airburstHeight = 8000

	array< void functionref(entity) > Callbacks_OnPlayerHealingStarted
	array< void functionref(entity) > Callbacks_OnPlayerHealingEnded

	array< void functionref(int) >                Callbacks_OnSquadEliminated
	bool functionref(int)                         Callbacks_IsSquadReallyEliminated
	array<void functionref(entity, var, int) >    Callbacks_OnPlayerKillDamage

	array<void functionref(entity, entity, int) >  Callbacks_OnPlayerGameSummaryAssist
	array<void functionref(entity, entity, int) >  Callbacks_OnPlayerGameSummaryKill
	array<void functionref(entity, entity, int, var) > Callbacks_OnPlayerGameSummaryKnockdown
	array<void functionref(entity, entity, int) > Callbacks_OnPlayerGameSummaryKnockdownAssist
	array<void functionref(entity, int, int, int)> Callbacks_OnPlayerGameSummaryStatChanged

	array< void functionref(entity) > Callbacks_OnPlayerLandedFromDropshipFreefall
	int functionref() getLivingPlayerCountFunction = null
	int functionref() getRemainingSquadsFunction = null

	bool characterLocksLocked = false
	bool characterLocksFinished = false

	int healthKitHealResourceID

	table< entity, array<int> >                       playerHealResourceIds
	table< entity, table<entity, int> >               triggerPlayerStatusEffects
	table< int, table< int, GameSummarySquadData > >  squadData
	table< int, int >                                 squadRespawnChances

	table< entity, float >         playerLastDamageSlowTime

	array<string>                        connectedUIDsSeenThisMatch = []
	table< entity, array< string > >     cheaterReportsThisMatch

	#if DEVELOPER
		ItemFlavor ornull DEV_overrideSpawnCharacterOrNull = null
		bool			  DEV_overrideSpawnCharacterSimpleEquip = false
		bool              DEV_overrideSpawnCharacterWithLaunchCharacters = false
	#endif

	CallbackType_Leviathan_ConsiderLookAtEnt Leviathan_ConsiderLookAtEnt

	table <int, int> finalTeamRanks

	float headshotDamageScale
	float bodyshotDamageScale

	array< void functionref(entity, ItemFlavor) > Callbacks_OnPlayerLockedInCharacterCallbacks
	array< void functionref(entity, ItemFlavor) > Callbacks_OnGameAutoSelectedCharacterCallbacks

	array< void functionref(entity) > Callbacks_OnPlayerSetupComplete
	bool functionref() Callback_ModeShouldSpawnPlayersDuringCharacterSelect = null

	bool forceRandomOnNoSelect = false
	bool shouldFreezeControlsOnPrematch = true

	int gameResultFlags
	int gameScoreFlags

	array< entity > playersWhoNeedSetupPrematch = []







	table< entity, DeadPeriodData > playerDeadZonePeriodData

	bool isFRCharacterRespawning = false
} file

// ----- file struct field accessors.

float function Survival_GetHeadshotDamageScale()
{
	return file.headshotDamageScale
}

float function Survival_GetBodyshotDamageScale()
{
	return file.bodyshotDamageScale
}

table< entity, float > function Survival_GetPlayerLastDamageSlowTime()
{
	return( file.playerLastDamageSlowTime )
}

// -----

void function GamemodeSurvival_Init()
{
	if ( GameMode_AreRoundsEnabled() )
	{
		SetRoundBased( true )
	}

	Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Generic )

	SURVIVAL_Loot_InitServer()
	SurvivalShip_Init()
	SurvivalFreefall_Init()




		ForcedSpawn_Init()


	// This Init gets run by other modes which do use match_jip and this call to set it to disabled was overriding settings in those mode.
	// Only turn off Join In progress if it is disabled in playlist vars ( which it is by default)
	if ( !GamemodeUtility_IsJIPEnabledInPlaylist() )
		GamemodeUtility_SetJIPEnabled( false )

	PrecacheParticleSystem( $"droppod_trail_smoke_linger" )
	PrecacheParticleSystem( $"droppod_trail_survival" )
	PrecacheParticleSystem( $"veh_blowout_wide_full_loop" )
	PrecacheParticleSystem( $"droppod_airburst" )





	PrecacheImpactEffectTable( "droppod_impact" )

	PrecacheModel( SURVIVAL_LOOT_POD_MODEL )
	PrecacheModel( SURVIVAL_LOOT_POD_DOOR_MODEL )

	FlagSet( "DisableDropships" )
	FlagSet( "DisableTimeLimit" )

	Bleedout_Init()
	Bleedout_AddCallback_OnPlayerStartBleedout( Sur_OnPlayerStartBleedout )
	Bleedout_AddCallback_OnPlayerStopBleedout( Sur_OnPlayerStopBleedout )
	Bleedout_AddCallback_OnPlayerGotFirstAid( Sur_OnPlayerGotFirstAid )
	Bleedout_AddCallback_OnPlayerFirstAidInterrupted( Sur_OnFirstAidInterrupted )

	AddSpawnCallback_ScriptName( "treasurehunt_blocker", PveGeoOnSpawn )
	AddCallback_OnPlayerRespawned( Survival_OnPlayerRespawned )
	AddCallback_ItemFlavorLoadoutSlotDidChange_AnyPlayer( Loadout_Character(), Survival_OnPlayerChangedCharacterClass )
	AddCallback_OnClientConnected( Survival_OnClientConnected )
	AddCallback_OnPreClientDisconnected( Survival_OnClientDisconnected )
	AddCallback_OnPlayerMatchStateChanged( DeadPeriodChecker_OnPlayerMatchStateChanged )
	SetPlayerEliminationCheck( Survival_ShouldPlayerBeEliminated )

	if ( svGlobal.gameModeAbandonPenaltyApplies == null ) //Ranked, Elite_Streak etc can override this.
		SetAbandonCheckFunc( Survival_DidPlayerAbandon )


		BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_survival_pvpcurrency_container" )


		BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_survival_upgrade_station" )


	if ( !Survival_IsCoverEnabled() )
	{
		BlockMapEntityParseCreationOf( "info_node_cover_stand", "", "" )
		BlockMapEntityParseCreationOf( "info_node_cover_left", "", "" )
		BlockMapEntityParseCreationOf( "info_node_cover_right", "", "" )
		BlockMapEntityParseCreationOf( "info_node_cover_crouch", "", "" )
		BlockMapEntityParseCreationOf( "info_node_cover_vantage", "", "" )
	}

	AddSpawnCallback_ScriptName( "walkspeed_water", WalkSpeedWaterThink )

	SetPlayThreeMinuteMusic( true )
	SetTimelimitCompleteFunc( TimeLimitComplete )

	//Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	AddCallback_OnPlayerKilled( OnPlayerKilled )

	ScoreEvent_SetGameModeRelevant( GetScoreEvent( "KillPilot" ) )

	Sh_ArenaDeathField_Init()
	SurvivalCommentary_Init()
	Ultimates_Init()


	ObjectiveResourceSystem_Init()


	AddDamageFinalCallback( "player", Player_OnDamage )

	AddCallback_GameStatePostEnter( eGameState.PickLoadout, Survival_RunCharacterSelection )
	AddCallback_GameStatePostEnter( eGameState.Prematch, Survival_OnPrematch )
	AddCallback_GameStateEnter( eGameState.Playing, Survival_GameStartedPlaying )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, Survival_WinnerDetermined )
	AddCallback_GameStateEnter( eGameState.Epilogue, Survival_OnEpilogue )
	AddCallback_GameStateEnter( eGameState.Resolution, Survival_OnResolution )
	AddCallback_GameStateEnter( eGameState.PickLoadout, Survival_OnEnterPickLoadout )

	if ( IsPrivateMatch() )
	{
		PrivateMatch_Match_Init()
		SetCustomResolutionDuration( 20.0 )
	}
	else
	{
		SetCustomResolutionDuration( 30.0 )
	}

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
	{
		Sh_Rank_InitGameSummary()
	}

	SetEndRoundPlayerState( ENDROUND_FREE )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad_Survival )

	AddDamageCallback( "player", OnPlayerTookDamage )
	AddHeadshotCallback( "player", OnPlayerTookHeadshot )

	AddCallback_OnPlayerReloadPressed( Survival_OnReloadPressed )

	RegisterSignal( "SlowMo" )
	RegisterSignal( "CancelHeal" )
	RegisterSignal( "StartHeal" )
	RegisterSignal( "OnLinked" )
	RegisterSignal( "CleanupOutsideCircle" )
	RegisterSignal( "GunRangeTargetDamaged" )
	RegisterSignal( "SquadEliminated" )
	RegisterSignal( "TEMP_StickyWaterProtection" )
	RegisterSignal( "EnemyDowned" )
	RegisterSignal( "FiringRange_CharacterChanged" )

	#if DEVELOPER
		AddClientCommandCallback( "Sur_SetActiveWeapon", bool function( entity player, array<string> args ) { ClientCommand_Sur_SetActiveWeapon( player, args ); return true } ) // dev
	#endif

	AddClientCommandCallback( "GoToMapPoint", bool function( entity player, array<string> args ) { ClientCommand_GoToMapPoint( player, args ); return true } ) // cheat

	#if DEVELOPER
		AddClientCommandCallback( "dev_sur_force_spawn_character", bool function( entity player, array<string> args ) { ClientCommand_dev_sur_force_spawn_character( player, args ); return true } ) // dev
		AddCallback_BotRecordStart( Survival_BotRecordStart )
		AddCallback_BotPlaybackStart( void function( entity playbackBot ) {
			Survival_BotPlaybackStart( playbackBot )
		} )
		AddClientCommandCallback( "dev_give_random_inventory", bool function( entity player, array<string> args ) {
			// dev
			GiveRandomStartingLoot( player )
			return true
		} )
	#endif

	if ( IsPrivateMatch() )
	{
		if ( GetConVarBool( "customMatch_enabled" ) )
			AddCallback_OnClientDisconnected( OnConnectionLost_Reconnect )
	}
	else
	{
		AddCallback_OnClientConnectionLost( OnConnectionLost_Reconnect )
		AddCallback_OnClientDisconnected( OnConnectionLost_Reconnect )
		AddCallback_OnDNAPickupDestroyed( OnDNAPickupDestroyed_Reconnect )
		AddCallback_OnPlayerKilled( OnPlayerKilled_Reconnect )
	}

	AddCallback_OnPlayerKilled( OnPlayerKilled_DropLoot )

	FlagInit( "PlaneStartMoving" )
	FlagInit( "PlaneDoorOpen" )
	FlagInit( "PlaneAtLaunchPoint" )
	FlagInit( "DeathCircleActive" )
	FlagInit( "BeginCharacterSelect" )
	FlagInit( "PlayersSpawnedInArena" )
	FlagInit( "staging_fx_enabled" )

	OverrideGameModeUsedForEntityRemoval( GetCurrentPlaylistVarString("override_gamemode_for_entity_removal", GameRules_GetGameMode() ) )
	// todo(dw): why are these been set in Survival?
	//OverrideDefaultNPCLoadouts( "npc_stalker", [ "mp_weapon_mastiff", "mp_weapon_lstar" ] )
	//OverrideDefaultNPCLoadouts( "npc_spectre", [ "mp_weapon_volt_smg", "mp_weapon_shotgun" ] )
	AddSpawnCallback( "npc_stalker", DefaultNPCSetup )
	AddSpawnCallback( "npc_spectre", DefaultNPCSetup )

	Loot_AddCallback_OnPlayerLootPickup( OnPlayerLootPickup )


	if ( GetCurrentPlaylistVarBool( "lootbin_bonusLoot_enabled", true ) )
		AddCallback_OnLootBinOpening(GamemodeUtility_SpawnBonusLoot)

	if ( GetCurrentPlaylistVarBool( "airdrop_enabled", true )

		|| UpgradeCore_IsEnabled() // needs to parse these values for lifelines care package ult upgrade

	)
	{
		if ( GetCurrentPlaylistVarBool( "airdrop_pregame_enabled", false ) )
		{
			string preGameData = GetCurrentPlaylistVarString( "airdrop_data_pregame", "-1" )

			if ( int(preGameData) != -1 )
				ParseAirdropData( 0, preGameData, true )
			else
				printf( "Airdrop Data for Pregame does not exist" )
		}

		int numStages = Survival_GetNumDeathfieldStages()
		for ( int i = 0; i < numStages; i++ )
		{
			string roundData = GetCurrentPlaylistVarString( "airdrop_data_round_" + i, "-1" )

			if ( int(roundData) != -1 )
				ParseAirdropData( i, roundData, false )
			else
				printf( "Airdrop Data for Round " + i + " does not exist" )
		}

	}

	//thread TrackSpectatedCount()

	file.headshotDamageScale = GetCurrentPlaylistVarFloat( "headshot_damage_scale", 1 )
	file.bodyshotDamageScale = GetCurrentPlaylistVarFloat( "bodyshot_damage_scale", 1 )


		AddCallback_OnWeaponAttack( Survival_OnWeaponAttack )


	file.gameResultFlags = 0
	file.gameScoreFlags = 0

	file.planeFlightAngleAdjustment = GetCurrentPlaylistVarFloat( "survival_plane_angle_deviation", 0.0 )
}


void function ParseAirdropData( int airdropRound, string airdropRoundData, bool isPregameAirdrop )
{
	array<string> dataSegments = GetTrimmedSplitString( airdropRoundData, " " )

	float minDelayOverride         = GetCurrentPlaylistVarFloat( "airdrop_minDelay_override", -1 )
	float maxDelayOverride         = GetCurrentPlaylistVarFloat( "airdrop_maxDelay_override", -1 )
	string airdropAnimOverride     = GetCurrentPlaylistVarString( "airdrop_anim_override", "" )
	int airdropArea                = isPregameAirdrop ?
	eAirdropRingArea[GetCurrentPlaylistVarString( "airdrop_ring_area_pregame", "CURRENT_RING" )] : eAirdropRingArea[GetCurrentPlaylistVarString( "airdrop_ring_area_round_" + airdropRound, "CURRENT_RING" )]
	float airdropRadiusOverride    = isPregameAirdrop ?
	GetCurrentPlaylistVarFloat( "airdrop_data_radius_override_pregame", -1 ) : GetCurrentPlaylistVarFloat( "airdrop_data_radius_override_round_" + airdropRound, -1 )
	float airdropRadiusOverrideMax = isPregameAirdrop ?
	GetCurrentPlaylistVarFloat( "airdrop_data_radius_out_override_pregame", -1 ) : GetCurrentPlaylistVarFloat( "airdrop_data_radius_out_override_round_" + airdropRound, -1 )
	float airdropRadiusOverrideMin = isPregameAirdrop ?
	GetCurrentPlaylistVarFloat( "airdrop_data_radius_in_override_pregame", -1 ) : GetCurrentPlaylistVarFloat( "airdrop_data_radius_in_override_round_" + airdropRound, -1 )
	int airdropSpeed               = isPregameAirdrop ?
	eAirdropSpeed[GetCurrentPlaylistVarString( "airdrop_speed_pregame", "STANDARD" )] : eAirdropSpeed[GetCurrentPlaylistVarString( "airdrop_speed_round_" + airdropRound, "STANDARD" )]


	entity fakePod = CreatePropDynamic( SURVIVAL_LOOT_POD_MODEL )

	foreach ( segment in dataSegments )
	{
		array<string> airdropData = GetTrimmedSplitString( segment, ":" )

		Assert( airdropData.len() >= 3 && airdropData.len() < 6, "Airdrop Round Data string not structured correctly \tUsage: \"dropCount:preWait:contentsLeft:contentsRight:contentsCenter\"" )

		int dropCount = int(airdropData[0])
		float preWait = float(airdropData[1])

		array< array<string> > content
		for ( int j = 2; j < airdropData.len(); j++ )
		{
			array<string> containerLootGroup = GetTrimmedSplitString( airdropData[j], "," )
			printf( "Airdrop container loot group is length:" + containerLootGroup.len() )
			content.append( containerLootGroup )
		}

		//DEBUG READING
		printf( "Airdrop Data" )
		printf( "\tAirdrop Circle: " + airdropRound )
		printf( "\tAirdrop Count: " + dropCount )
		printf( "\tAirdrop Pre Wait: " + preWait )
		foreach ( group in content )
		{
			print( "\t\tAirdrop Content Group: " )
			for ( int z = 0; z < group.len(); z++ )
			{
				print( group[z] + ", " )
			}
			print( "\n" )
		}

		AirdropRoundData data
		if ( isPregameAirdrop )
			data = Survival_CreatePregameAirDropData( 0, dropCount, preWait, content, airdropArea )
		else
			data = Survival_CreateAirDropData( airdropRound, dropCount, preWait, content, airdropArea )

		if( GetCurrentPlaylistVarBool( "predetermine_airdrop_data_at_game_start", false ) )
		{
			for ( int i = 0; i < data.dropCount; i++ )
			{
				array< array<string> > contentGroups = clone data.contents

					array< array<string> > podContents
					if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) && GoldenHorse_SwordCarePackageEnabled() && i == 0 && contentGroups.len() >= 3 )
					{
						string former = ""
						if ( contentGroups[2].len() >= 1 )
						{
							former              = contentGroups[2][0]
							contentGroups[2][0] = "crate_weapons_sword"
						}
						else
						{
							contentGroups[2].append( "crate_weapons_sword" )
						}
						podContents         = DetermineAirdropContents ( contentGroups )
						contentGroups[2][0] = former
					}
					else
						podContents = DetermineAirdropContents ( contentGroups )




				data.contentsArray.append( podContents )

				int airdropContentsTier = DetermineAirdropTier ( podContents )
				data.rarityArray.append( airdropContentsTier )
			}
		}

		//overrides
		if ( minDelayOverride >= 0 )
			data.minDelayBetweenPods = minDelayOverride
		if ( maxDelayOverride >= 0 )
			data.maxDelayBetweenPods = maxDelayOverride
		if ( airdropAnimOverride != "" )
			data.animation = airdropAnimOverride
		if ( airdropRadiusOverride >= 0 )
		{
			data.airdropRadiusOverride        = airdropRadiusOverride
			data.airdropRadiusOverrideEnabled = true
		}
		if ( airdropRadiusOverrideMax >= 0 )
			data.airdropRadiusOverride_LargeCount_Outer = airdropRadiusOverrideMax
		if ( airdropRadiusOverrideMin >= 0 )
			data.airdropRadiusOverride_LargeCount_Inner = airdropRadiusOverrideMin

		data.animationDuration = fakePod.GetSequenceDuration( data.animation )
		data.airdropSpeed      = airdropSpeed

		if( GetCurrentPlaylistVarBool( "predetermine_airdrop_data_at_game_start", false ) )
			data.delayBetweenPods = RandomFloatRangeForLoot( data.minDelayBetweenPods, data.maxDelayBetweenPods )
	}

	fakePod.Destroy()
}


void function OnConnectionLost_Reconnect( entity player )
{
	Assert( IsValid( player ) )

	int playerTeam = player.GetTeam()

	if ( player.GetPartySize() == 1 )
	{
		// Check if this player has an expired beacon (race condition between detecting disconnection and beacon expiry).
		// IsSquadReallyEliminated is odd in that it always returns true in modes that don't implement it, but it also
		// means we can still check individual player elimination cases in those modes.
		bool isPlayerEliminationFinal = IsSquadReallyEliminated( playerTeam )
		int respawnStatus = GetRespawnStatus( player )
		if ( !player.IsEntAlive() && !IsValid( player.p.respawnBeacon ) && isPlayerEliminationFinal
				&& ( respawnStatus == eRespawnStatus.PICKUP_DESTROYED
					|| respawnStatus == eRespawnStatus.PLAYER_ELIMINATED
					|| respawnStatus == eRespawnStatus.SQUAD_ELIMINATED ) )
		{
			printt( "Reconnect cancel because beacon expired (on timeout) ", player )
			//player.Forfeit() // S3: entity method not available
		}
	}

	thread CheckAndSetReconnectStatusForTeam( playerTeam )
}

void function OnDNAPickupDestroyed_Reconnect( entity player )
{
	// if player cannot be respawned and offline, force disconnect
	Assert( IsValid( player ) )

	if ( player.GetPartySize() > 1 )
		return

	if ( player.IsEntAlive() )
		return

	printt( "Reconnect cancel because beacon expired", player )
	//if ( player.IsConnectionActive() ) // S3: entity method not available
	//	Remote_CallFunction_NonReplay( player, "ServerCallback_ResetReconnectParametersAsync" )
	//else
	//{
	//	//player.Forfeit() // S3: entity method not available
	//}
}

void function OnPlayerKilled_Reconnect( entity player, entity attacker, var damageInfo )
{
	Assert( IsValid( player ) )

	thread CheckAndSetReconnectStatusForTeam( player.GetTeam() )
}

void function CheckAndSetReconnectStatusForTeam( int team )
{
	WaitEndFrame() // don't try to disconnect players recursively

	// ignore if not in game yet
	int gameState = GetGameState()
	if ( gameState <= eGameState.Prematch )
		return

	array<entity> teamplayers = GetPlayerArrayOfTeam( team )
	// if noone is alive, disconnect player disconnected
	if ( gameState <= eGameState.Playing )
	{
		foreach ( teammate in teamplayers )
		{
			if ( teammate.IsEntAlive() )
				return
		}
	}

	// no one on the team is alive or we are not in post match, so kick whoever's left (they won't be able to rejoin)
	if ( !IsPrivateMatch() && IsSquadReallyEliminated( team ) )
	{
		foreach ( teammate in teamplayers )
		{
			printt( "Reconnect cancel because team has been eliminated ", teammate )
			//if ( teammate.IsConnectionActive() ) // S3: entity method not available
			//	Remote_CallFunction_NonReplay( teammate, "ServerCallback_ResetReconnectParametersAsync" )
			//teammate.Forfeit() // S3: entity method not available
		}
	}
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
	DisableEntityOutOfBounds( player )

	// Clear death protection the player had in the staging area. We don't do this when leaving "WaitingForPlayers" state because we don't want players taking damage in PickLoadout state either, which can happen with DOT entities left laying around
	if ( player.p.hasStagingAreaDamageProtection )
	{
		RemoveEntityCallback_OnDamaged( player, StagingAreaPlayerTookDamageCallback )
		player.p.hasStagingAreaDamageProtection = false
	}
}


void function ClearPlayerIntroDropSettings( entity player )
{
	if ( !player.p.hasDropSettings )
		return

	player.p.hasDropSettings = false

	// Called by whatever script is handling the player deployment into the map. Once that script gets the player to the ground it should call this.
	player.ClearInvulnerable()

	if ( IsAlive( player ) )
	{
		vector playerOrigin = player.GetOrigin()
		if ( !player.IsZiplining() )
			PutEntityInSomewhatSafeSpot( player, null, null, playerOrigin, playerOrigin )
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

	Survival_SetFriendlyHighlight( player )
	Highlight_ClearEnemyHighlight( player )

	// Undo stuff we did in SetPlayerIntroDropSettings
	// R5DEV-363382: strange mismatch between these two. Server_IsOffhandWeaponsDisabled seems to not be set in cases where the player disconnects,
	//   even though the entity is valid and we can still manipulate it. This may explain the behaviour needing investigation (read comment above DisableOffhandWeapons in _utility.gnut)
	if ( player.p.holsterAndDisableWeaponCount > 0 || player.Server_IsOffhandWeaponsDisabled() )
		DeployAndEnableWeapons( player )
	EnableEntityOutOfBounds( player )

	Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerBootsOnGround" )

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
			if ( PlayerHasPassive( player, ePassives.PAS_LOBA_EYE_FOR_QUALITY ) )
				ultimateWeapon.SetWeaponPrimaryClipCountAbsolute( int( ultimateWeapon.GetWeaponPrimaryClipCountMax() * 0.5 ) )

			ultimateWeapon.RegenerateAmmoReset()
		}

		PIN_PlayerLandedOnGround( player )
		StatsHook_OnPlayerLandedSkydive( player )

		foreach ( callbackFunc in file.Callbacks_OnPlayerLandedFromDropshipFreefall )
			callbackFunc( player )
	}

	// Allow player to emote
	SetPlayerCanGroundEmote( player, true )

	PlayerMatchState_Set( player, ePlayerMatchState.NORMAL )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )

	Survival_SetInventoryEnabled( player, true )

	file.playerData[ EHIToEncodedEHandle( player ) ].hasJumpedOutOfPlane = true
	file.playerData[ EHIToEncodedEHandle( player ) ].landingOrigin       = player.GetOrigin()
	file.playerData[ EHIToEncodedEHandle( player ) ].landingTime         = Time()

	#if DEVELOPER
		DEV_GiveSpawnWeapons( player )
	#endif

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


void function DefaultNPCSetup( entity npc )
{
	npc.EnableNPCFlag( NPC_NO_WEAPON_DROP )
}


void function OnPlayerKilled_DropLoot( entity player, entity attacker, var damageInfo )
{
	// Don't drop player loot upon death for Firing Range.
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if ( GetGameState() >= eGameState.Playing )
		thread SURVIVAL_Death_DropLoot( player, damageInfo )
}


void function EntitiesDidLoad_Survival()
{
	DisableStagingSpawns()

	if ( file.planeHeight == 0 )
		file.planeHeight = PLANE_HEIGHT_REALBIG

	vector mapCenterOverride = StringToVector( GetCurrentPlaylistVarString( "survival_override_map_center", "-1 -1 -1" ) )
	if ( mapCenterOverride != < -1, -1, -1 > )
	{
		SURVIVAL_SetMapCenter( mapCenterOverride )
	}



















	{

		// Set planes based on proximity to Evac Location
		//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) ) // S3: ShadowArmy not available
		//{
		//	thread Survival_RunPlaneLogic_Thread( ShadowArmy_GenerateSingleRevArmyPlanePath, Survival_RunSinglePlanePath_Thread, false )
		//}
		//else

		{
			if ( Survival_IsJumpFromPlaneEnabled() )
			{
				thread Survival_RunPlaneLogic_Thread( Survival_GenerateSingleRandomPlanePath, Survival_RunSinglePlanePath_Thread, false )
			}
		}
	}

	SURVIVAL_PopulateSpecialZones()
}


void function DisableStagingSpawns()
{
	// Don't delete staging spawns in practice mode
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	// If we're jumping from a plane it must be a legit match, so don't remove them
	if ( Survival_IsPlaneEnabled() )
		return

	array<entity> shipSpawns = GetEntArrayByScriptName( "survival_ship_spawn" )
	foreach ( entity ent in shipSpawns )
	{
		if ( IsValid( ent ) )
			ent.Destroy()
	}
}


entity function GetScriptMoverPath( entity ent )
{
	array<entity> links = ent.GetLinkEntArray()

	foreach ( link in links )
	{
		if ( GetEditorClass( link ) == "script_mover_path" )
		{
			return link
		}
	}

	return null
}


void function SURVIVAL_SetPlaneOverridePathRegion( vector center, float radius )
{
	file.planeOverridePathCenter = center
	file.planeOverridePathRadius = radius
	file.planeOverridePathSet    = true
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

	if ( GetCurrentPlaylistVarInt( "locked_plane_path_random_seed_number", -1 ) != -1 )
	{
		//option to lock the plane path to be the same every match
		int randomSeedInt = GetRandomSeedIntForPlanePath()
		SetRandomSeedForPlanePath( CreateRandomSeed( randomSeedInt ) )
	}

	if ( GetCurrentPlaylistVarBool( "override_map_center_to_deathfield_center", false ) )
	{
		FlagWait( "DeathFieldCalculationComplete" )
		DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData( Survival_Loot_GetDefaultRealm() )
		file.mapCenter = deathFieldData.center
	}

	array< PlanePathData > pathData = generatePlanePathFunc( beQuick, planeInt )
	thread runPlanePathFunc( pathData, planeInt )
}

#if DEVELOPER && ASSERTS
void function CheckPlaneCoordinateValidity( float coordinate, float buffer )
{
	float MAX_COORDS_FOR_PLANE = MAX_WORLD_COORD - buffer
	float MIN_COORDS_FOR_PLANE = -MAX_WORLD_COORD + buffer

	Assert(
		(IsEqualFloat( fabs( coordinate ), MAX_COORDS_FOR_PLANE )
		|| fabs( coordinate ) <= MAX_COORDS_FOR_PLANE) //<= max coords
		&&
		(IsEqualFloat( fabs( coordinate ), MIN_COORDS_FOR_PLANE )
		|| fabs( coordinate ) >= MIN_COORDS_FOR_PLANE) //>= min coords
		,
		"Invalid plane coordinate, please review ClampLineSegmentToRectangle2D and Get2DLineIntersection"
	)
}

//Call this from the dev console, it will keep running the function
//The more asserts we add, the better we can verify it works correctly
void function Test_Survival_GenerateSingleRandomPlanePath()
{
	thread Thread_TestSurvival_GenerateSingleRandomPlanePath()
}

void function Thread_TestSurvival_GenerateSingleRandomPlanePath()
{
	while ( true )
	{
		for ( int i = 0; i < 1000; i++)
			Survival_GenerateSingleRandomPlanePath( true, 0 )

		WaitFrame()
	}
}
#endif //DEVELOPER & ASSERTS

array< PlanePathData > function Survival_GenerateSingleRandomPlanePath( bool beQuick, int unusedInt = 0 )
{
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

	bool clampToRing = Survival_IsDropshipClampedToRing()

	entity fakePlane = CreatePropDynamic( SURVIVAL_PLANE_MODEL )
	while ( !e[ "trace_test" ] )
	{
		if ( !file.planeOverridePathSet )
		{
			float mapAngleRotation = GetCurrentPlaylistVarFloat( "survival_plane_angle_deviation", SURVIVAL_GetFlightAngleAdjustment() )

			// Get the basic angle of approach
			int baseAngle            = RandomIntRangeForPlanePath( 0, 4 ) // 0, 90, 180, 270
			float tightnessFactor    =  GetCurrentPlaylistVarFloat( "survival_plane_start_angle_tightness", 1.5 )
			float baseAngleDeviation = pow( RandomFloatRangeForPlanePath( 0.0, 1.0 ), tightnessFactor )
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

			float moveAmount = RandomFloatRangeForPlanePath( 0.0, maxDeviation )
			vector moveVec = VectorRotate( <moveAmount, 0, 0>, <0, RandomFloatRange( -180, 180 ), 0>)
			vector startCenter = file.mapCenter
			float ringRadius = REALBIG_CIRCLE_GRID_RADIUS

			if ( clampToRing )
			{
				startCenter = SURVIVAL_GetDeathFieldData( Survival_Loot_GetDefaultRealm() ).center
				ringRadius = SURVIVAL_GetDeathFieldData( Survival_Loot_GetDefaultRealm() ).currentRadius - CLAMP_TO_RING_BUFFER
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
		}
		else if ( file.planeOverridePathSet )
		{
			// Get a cone of angles from map center to the drop zone origin
			vector mapCenterToDropZoneCenter = file.planeOverridePathCenter - file.mapCenter
			bool mapCenterInsideDropZone     = Length( mapCenterToDropZoneCenter ) <= file.planeOverridePathRadius

			if ( !mapCenterInsideDropZone )
			{
				// Expand the cone of angles to select from by buffer * 0.5 on either side. The plane path will always be repositioned to be close to drop zone.
				// Helps create more angle variety, while still flying by the zone. Keeps things feeling more natural.
				const float DROP_ZONE_CONE_EXTRA_ANGLE_BUFFER = 120

				vector mapCenterToDropZoneCenterDir = Normalize( mapCenterToDropZoneCenter )
				vector dropZonePerpendicularDir     = CrossProduct( mapCenterToDropZoneCenterDir, < 0, 0, 1 > )
				array<vector> dropZoneConeBounds    = [ file.planeOverridePathCenter + (dropZonePerpendicularDir * file.planeOverridePathRadius), file.planeOverridePathCenter - (dropZonePerpendicularDir * file.planeOverridePathRadius) ]

				array<float> dropZoneConeAngles
				for ( int i; i < 2; i++ )
				{
					vector centerToBound = file.mapCenter - dropZoneConeBounds[ i ]
					dropZoneConeAngles.append( RadToDeg( atan( centerToBound.y / centerToBound.x ) ) )
				}

				float arcLength = GetArcLengthDeg( dropZoneConeAngles[ 0 ], dropZoneConeAngles[ 1 ] )
				if ( arcLength > 180.0 )
					dropZoneConeAngles.reverse()
				arcLength = GetArcLengthDeg( dropZoneConeAngles[ 0 ], dropZoneConeAngles[ 1 ] )

				float angleBufferToUse = DROP_ZONE_CONE_EXTRA_ANGLE_BUFFER
				if ( (arcLength + angleBufferToUse) > 180.0 )
					angleBufferToUse = 180.0 - arcLength

				dropZoneConeAngles[ 0 ] = ClampAngle( dropZoneConeAngles[ 0 ] - (angleBufferToUse * 0.5) )
				dropZoneConeAngles[ 1 ] = ClampAngle( dropZoneConeAngles[ 1 ] + (angleBufferToUse * 0.5) )
				float randFloat   = RandomFloatRange( dropZoneConeAngles[ 0 ], dropZoneConeAngles[ 1 ] )
				float randomAngle = ClampAngle( dropZoneConeAngles[ 0 ] + randFloat )
				angles = < 0, randomAngle, 0 >
			}
			else
				angles = < 0, RandomFloat( 360.0 ), 0 >

			vector fwd         = AnglesToForward( angles )
			float maxDeviation = GetCurrentPlaylistVarFloat( "survival_plane_path_deviation", 17000 )

			centerPos = file.mapCenter + <0, 0, file.planeHeight>
			startPos  = (fwd * -1 * REALBIG_CIRCLE_GRID_RADIUS) + centerPos
			endPos    = (fwd * REALBIG_CIRCLE_GRID_RADIUS) + centerPos

			vector startPosToDropCenter      = file.planeOverridePathCenter - startPos
			vector closestPointOnFlightPath  = GetClosestPointOnLine( startPos, endPos, file.planeOverridePathCenter )
			float distDropCenterToFlightPath = Distance2D( closestPointOnFlightPath, file.planeOverridePathCenter )
			vector adjustmentDirection

			if ( distDropCenterToFlightPath < 512.0 )
				adjustmentDirection = FlattenVec( RandomVecInDome( < 0, 0, 1 > ) )
			else
				adjustmentDirection = Normalize( file.planeOverridePathCenter - closestPointOnFlightPath )

			float distToMove = 0
			if ( distDropCenterToFlightPath > file.planeOverridePathRadius )
				distToMove = distDropCenterToFlightPath - (file.planeOverridePathRadius * RandomFloat( 1 ))
			else
				distToMove = file.planeOverridePathRadius * RandomFloat( 1 )

			vector positionAdjustment = FlattenVec( adjustmentDirection * distToMove )

			startPos += positionAdjustment
			endPos += positionAdjustment
			centerPos += positionAdjustment

			float startToZone = DistanceSqr( startPos, file.planeOverridePathCenter )
			float endToZone   = DistanceSqr( endPos, file.planeOverridePathCenter )
			if ( endToZone < startToZone )
			{
				vector tempEndPos = endPos
				endPos   = startPos
				startPos = tempEndPos
				angles   = AnglesCompose( angles, < 0, 180, 0 > )
			}
		}

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
	float flyOverMapSpeed = Survival_GetPlaneMoveSpeed()
	result.flyOverMapDuration = flyOverMapDist / flyOverMapSpeed
	float jumpDelay              = (beQuick ? 3.0 : Survival_GetPlaneJumpDelay())
	float unitsBeforeJumpAllowed = flyOverMapSpeed * jumpDelay
	float planeLeaveMapDuration  = jumpDelay * Survival_GetPlaneLeaveMapDurationMultiplier()
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
		//DebugDrawLine( planeStart, planeEnd, <255, 255, 0>, true, 10.0 )
	#endif
	LineSegment lineSegment    = ClampLineSegmentToWorldBounds2D( planeStart, planeEnd, SKYBOX_BUFFER )
	vector clampedPlaneStart   = lineSegment.start
	vector clampedPlaneEnd     = lineSegment.end

#if DEVELOPER && ASSERTS
	CheckPlaneCoordinateValidity( clampedPlaneStart.x, SKYBOX_BUFFER )
	CheckPlaneCoordinateValidity( clampedPlaneStart.y, SKYBOX_BUFFER )
	CheckPlaneCoordinateValidity( clampedPlaneStart.z, SKYBOX_BUFFER )
	CheckPlaneCoordinateValidity( clampedPlaneEnd.x, SKYBOX_BUFFER )
	CheckPlaneCoordinateValidity( clampedPlaneEnd.y, SKYBOX_BUFFER )
	CheckPlaneCoordinateValidity( clampedPlaneEnd.z, SKYBOX_BUFFER )
#endif

	if ( PLANE_PATH_DEBUG )
	{
		printt( "clampedPlaneStart:", clampedPlaneStart )
		printt( "clampedPlaneEnd:", clampedPlaneEnd )
	}
	#if DEBUG_PLANE_PATH || DEBUG_PLANE_PATH_LIGHTWEIGHT
		if ( !dev_numTriesFailed )
			//DebugDrawLine( clampedPlaneStart - <0, 0, 10000>, clampedPlaneEnd - <0, 0, 10000>, <0, 255, 0>, true, 240.0 )
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

	file.planeJumpStartPos = result.clampedPlaneStart
	file.planeJumpEndPos   = result.clampedPlaneEnd

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

void function Survival_RunSinglePlanePath_Thread( array< PlanePathData > paths, int planeIndex = 0 )
{
	FlagClear( "PlaneStartMoving" )
	FlagClear( "PlaneDoorOpen" )
	FlagClear( "PlaneAtLaunchPoint" )

	PlanePathData path = paths[0] // This function should only run one plane so just use index 0

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


		// Use a custom model for the Rev Alliance Ship in Rev Army mode
		//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) ) // S3: ShadowArmy not available
		//	ShadowArmy_SetupRevenantDropship( plane )


	DispatchSpawn( plane )
	plane.SetParent( mover )
	plane.Show()
	file.plane.baseEnt           = plane

	plane.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
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
	//	FlagSet( "PlaneStartMoving" )

	file.plane.baseEnt.MakeInvisible()
	FlagWait( "PlaneStartMoving" )
	file.plane.baseEnt.MakeVisible()

	StatsHook_SetPlaneData( path.clampedPlaneStart, path.clampedPlaneEnd, path.totalFlyDuration )
	SetGlobalNetTime( "PlaneDoorsOpenTime", Time() + path.jumpDelay )
	SetGlobalNetTime( "PlaneDoorsCloseTime", Time() + path.totalFlyDuration )

	thread OpenAndClosePlaneDoor( plane, path.jumpDelay, path.flyOverMapDuration )

	EmitSoundOnEntity( file.plane.mover, "Survival_DropSequence_Pegasus_Engine" )

	thread PlaneAttractLeviathan( plane, file.plane.centerEnt )

	mover.NonPhysicsMoveTo( path.clampedPlaneEnd, path.totalFlyDuration, 0, 0 )

	wait path.totalFlyDuration

	FlagSet( "DeathCircleActive" )


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) && GetCurrentPlaylistVarBool( "sur_circle_start_paused", false ) )
		{
			FlagClear( "DeathFieldPaused" )
		}








}

#if DEVELOPER
void function DEV_SimulatePlanePaths( int count = 1 )
{
	thread DEV_SimulatePlanePaths_Internal( count )
}

void function DEV_SimulatePlanePaths_Internal( int count = 1 )
{
	array<PlanePathData> paths = []
	array<float> times = []

	PlanePathData minPath
	PlanePathData maxPath
	PlanePathData averagePath
	PlanePathData meanPath

	float minTime = 1000
	float maxTime = 0
	float totalTime = 0
	float averageTime
	float meanTime

	for ( int i = 0; i < count; i++ )
	{
		PlanePathData path = Survival_GenerateSingleRandomPlanePath( false )[0]

		paths.append( path )

		times.append( path.flyOverMapDuration )
		totalTime += path.flyOverMapDuration

		if ( path.flyOverMapDuration < minTime )
		{
			minTime = path.flyOverMapDuration
			minPath = path
		}
		if ( path.flyOverMapDuration > maxTime )
		{
			maxTime = path.flyOverMapDuration
			maxPath = path
		}
	}

	times.sort( int function ( float a, float b ) { return ( a < b ? -1 : 1 ) } )
	meanTime = times[times.len()/2]

	averageTime = totalTime / count

	printt( "PATH SIMULATION: ", count, " paths"  )
	printt( "MinTime: ", minTime )
	printt( "MaxTime: ", maxTime )
	printt( "AverageTime:", averageTime )
	printt( "MeanTime:", meanTime )

	//DebugDrawLine( minPath.startPos, minPath.endPos, COLOR_MAGENTA, true, 30.0 )
	//DebugDrawLine( maxPath.startPos, maxPath.endPos, <255, 255, 0>, true, 30.0 )

	thread Survival_RunSinglePlanePath_Thread( [ minPath ] )
	thread PlaneTest_threaded_simulated()

	FlagWait( "PlaneAtLaunchPoint" )

	thread Survival_RunSinglePlanePath_Thread( [ maxPath ] )
	thread PlaneTest_threaded_simulated()
}
#endif






































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































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























float function SURVIVAL_GetPlaneJumpDuration()
{
	return file.flyOverMapDuration
}

#if NAVMESH_ALL_SUPPORTED
const int FLIGHTPATH_HULL = HULL_TITAN
#else
const int FLIGHTPATH_HULL = HULL_PROWLER
#endif

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
				//DebugDrawCircle( mapCenter, <0, 0, 1>, SURVIVAL_PLANE_DROP_RADIUS_MIN, <255, 0, 0>, true, 10.0 )
				//DebugDrawLine( pointOnPlanePath, pointOnPlanePath - <0, 0, 10000>, <255, 0, 0>, true, 10.0 )
				return pointOnPlanePath
			}

			vector traceEnd    = <traceStart.x, traceStart.y, -MAP_EXTENTS>
			TraceResults trace = TraceLine( traceStart, traceEnd, [], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )
			if ( trace.fraction < 1.0 && !trace.hitSky && !trace.startSolid )
			{
				vector ornull closestTitanNavMesh = NavMesh_ClampPointForHullWithExtents( trace.endPos, FLIGHTPATH_HULL, <1024, 1024, 1024> )

				#if DEBUG_PLANE_PATH
					//DebugDrawLine( traceStart, trace.endPos, <0, 0, 255>, true, 10.0 )
					if ( closestTitanNavMesh == null )
					{
						//DebugDrawSphere( trace.endPos, 256.0, <255, 0, 0>, true, 10.0 )
					}
					else
					{
						expect vector(closestTitanNavMesh)
						//DebugDrawLine( trace.endPos, closestTitanNavMesh, <0, 255, 0>, true, 10.0 )
						//DebugDrawSphere( closestTitanNavMesh, 256.0, <0, 255, 0>, true, 10.0 )
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











































// Function used by Survival to determine how many living players are remaining in the match
// Takes into account when the functionality is overridden by different modes
int function Survival_GetLivingPlayerCount()
{
	int livingPlayerCount

	if ( file.getLivingPlayerCountFunction != null )
		livingPlayerCount = file.getLivingPlayerCountFunction()
	else
		livingPlayerCount = GetPlayerArray_AliveConnected().len()

	return livingPlayerCount
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

// Override the function that returns the number of remaining living players in the match
// Some modes use different functions for setting this data
void function Survival_OverrideGetLivingPlayerCountFunction( int functionref() func )
{
	Assert( func != null, "Tried setting Survival_OverrideGetLivingPlayerCountFunction with a null function!" )
	if ( func != null )
		file.getLivingPlayerCountFunction = func
}

// Override the function that returns the number of remaining squads in the match
// Some modes use different functions for setting this data
void function Survival_OverrideGetRemainingSquadsFunction( int functionref() func )
{
	Assert( func != null, "Tried setting Survival_OverrideGetRemainingSquadsFunction with a null function!" )
	if ( func != null )
		file.getRemainingSquadsFunction = func
}

void function UpdatePlayerCounts()
{
	SetGlobalNetInt( "connectedPlayerCount", GetPlayerArray_ConnectedNotSpectatorTeam().len() )
	SetGlobalNetInt( "livingPlayerCount", Survival_GetLivingPlayerCount() )
	SetGlobalNetInt( "squadsRemainingCount", Survival_GetRemainingSquadsCount() )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( GetGameState() < eGameState.Playing )
		return

	victim.p.survivalAliveEndTime = Time() // this needs to happen before winner determined, because winner determined awards XP which can use this value

	// non-elimination modes need to set this up themselves
	// TODO: this is weird organisationally, elimination-based stuff is in survival, but everything else is mode-specific? needs revisit
	if ( IsEliminationBased() )
	{
		// needs to happen before OnPlayerKilled_Winner() as the call to WillShowRoundWinningKillReplay() originates from it
		SetDefaultRoundWinningKillReplayEntities( victim, attacker, damageInfo )
	}

	OnPlayerKilled_Winner()

	UpdatePlayerCounts()

	thread Delayed_TryEliminateTeammates( victim )

	entity killer = attacker

	bool isThirdPartyKill = false

	if ( Bleedout_IsBleedingOut( victim ) )
	{
		killer = Bleedout_GetBleedoutAttacker( victim )
		isThirdPartyKill = true
		if ( IsValid( killer ) && killer.IsPlayer() && !killer.p.hasMatchParticipationEnded )
		{
			isThirdPartyKill = false
		}
	}

	if ( !GameModeVariant_IsActive( eGameModeVariants.FREEDM_GUNGAME ) )//OnPlayerKilled in gungame happens first and weapon is switched before this is called

	WeaponStatsHook_OnKillEnemy( victim, attacker, killer, damageInfo )

	//only if the kill was earned
	if ( !isThirdPartyKill &&  killer.IsPlayer() && killer != victim )
	{
		string weaponString           = ""
		string ornull weaponClassName = GetWeaponClassNameFromDamageInfo( damageInfo )
		if ( weaponClassName != null )
			weaponString = string( weaponClassName )

		if ( !killer.p.hasMatchParticipationEnded ) //Don't award kills XP for players who have already been eliminated.
		{
			AddKillStats( killer, victim, weaponString )

			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
				Ranked_UpdateRankedScoreProgressForPlayer( killer )
		}

		if ( !Bleedout_IsBleedingOut( victim ) )
			victim.p.playerToTimeThatAssistCreditLastsTable = GetLatestAssistingPlayersFromSameTeam( victim, attacker ) //Only do this if victim dies without going into bleed out state, because damage while bleeding out should not count towards assist.

		foreach ( entity assistCreditPlayer, float assistTime in victim.p.playerToTimeThatAssistCreditLastsTable )
		{
			if ( !IsValid( assistCreditPlayer ) )
				continue

			if ( assistCreditPlayer.p.hasMatchParticipationEnded )
				continue



			bool doPilotAssist = !UpgradeCore_UsePersonalObituaryNotifications()
			// if upgrades are using the personal obituary, the squad wipe notification will already communicate this
			// only do the notification if this was a thirst
			if( !doPilotAssist )
			{
				array<entity> teammates = GetPlayerArrayOfTeam_Alive( victim.GetTeam() )
				foreach ( entity teammate in teammates )
				{
					if ( teammate == victim )
						continue
					if ( Bleedout_IsBleedingOut( teammate ) )
						continue
					doPilotAssist = true
					break
				}
			}
			if( doPilotAssist )

				AddPlayerScore( assistCreditPlayer, "EliminatePilotAssist", victim )

			AddKillAssistStats( assistCreditPlayer, victim )
			WeaponStatsHook_OnAssistCredited( assistCreditPlayer )

			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
				Ranked_UpdateRankedScoreProgressForPlayer( assistCreditPlayer )

			foreach ( callbackFunc in svGlobal.onPlayerAssistCallbacks )
			{
				callbackFunc( assistCreditPlayer, victim )
			}
		}

		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
		{
			if (GetCurrentPlaylistVarBool( "ranked_team_kp", true ))
			{
				//Note: Can not be broken out into it's own callback because of HandleSquadElimination() below.
				//      Since we will lose assist information
				SurvivalRank_ProcessParticiation ( killer, victim )
			}
		}

		if ( !victim.IsBot() )
		{
			string victimCharacterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( victim ), Loadout_Character() ) )
			TelemetryEvent( "charSel.deaths." + victimCharacterName, 1 )
		}

		if ( !killer.IsBot() )
		{
			string killerCharacterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( killer ), Loadout_Character() ) )
			TelemetryEvent( "charSel.kills." + killerCharacterName, 1 )
		}

		if ( GetCurrentPlaylistVarBool( "survival_autoprompt_taunt_on_squad_wipe", false ) && GetPlayerArrayOfTeam_Alive( victim.GetTeam() ).len() <= 0 )
		{
			if ( GetGameState() < eGameState.WinnerDetermined )
				Remote_CallFunction_NonReplay( killer, "ServerCallback_PromptTaunt" )
		}
	}

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.deathField
			|| (Bleedout_IsBleedingOut( victim ) && Bleedout_GetBleedoutDamageSourceId( victim ) == eDamageSourceId.deathField) )
	{
		HeatMapStat( victim, "Sur_DeathByCircle", victim.GetOrigin() )
		if ( !victim.IsBot() )
			TelemetryEvent( "deaths.circle", 1 )
	}

	if ( SURVIVAL_GetCirclesCompleted() == -1 )
	{
		HeatMapStat( victim, "Sur_DeathBeforeFirstCircleCloses", victim.GetOrigin() )
		if ( !victim.IsBot() )
			TelemetryEvent( "deaths.early", 1 )
	}

	if ( victim.GetMainWeapons().len() == 1 && victim.GetMainWeapons()[0].IsWeaponOffhandMelee() )
	{
		HeatMapStat( victim, "Sur_DiedWithoutWeapon", victim.GetOrigin() )
		if ( !victim.IsBot() )
			TelemetryEvent( "deaths.noweapon", 1 )
	}

	if ( Survival_IsPlayerSquadEliminated( victim ) )
	{




			HandleSquadElimination( victim.GetTeam() )
	}

	AddGameSummaryDeath( victim, 1 )
}


void function AddKillStats( entity killer, entity victim, string weaponString )
{
	int kills = minint( killer.GetPlayerNetInt( "kills" ) + 1, 500 )
	killer.SetPlayerNetInt( "kills", kills )

	AddGameSummaryKill( killer, victim , 1 )

	// Add XP for the kill
	AddXP( killer, eXPType.KILL )
	bool gameModeHasChampXPKill = true


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
			gameModeHasChampXPKill = false // prevent giving repeated XP for killing the champ squad in multiple rounds.


	if ( IsValid( victim ) && victim.GetTeam() == SurvivalCommentary_GetChampionTeam() && gameModeHasChampXPKill )
		AddXP( killer, eXPType.KILL_CHAMPION_MEMBER )

	// Bonus for first game played everyday
	int lastDayFirstKill = killer.GetPersistentVarAsInt( "lastDayBonus" )
	int currentDay       = Daily_GetDayForCurrentTime()
	if ( lastDayFirstKill < currentDay && XpEventTypeData_GetAmount( eXPType.BONUS_FIRST_KILL ) > 0 )
	{
		AddXP( killer, eXPType.BONUS_FIRST_KILL )
		killer.SetPersistentVar( "lastDayBonus", currentDay )
	}
}


void function AddKillAssistStats( entity assistingPlayer, entity victim )
{
	int assists = minint( assistingPlayer.GetPlayerNetInt( "assists" ) + 1, 500 )
	assistingPlayer.SetPlayerNetInt( "assists", assists )
	StatsHook_OnPlayerAssist( assistingPlayer )

	AddGameSummaryKillAssist( assistingPlayer, victim, 1 )
}

void function OnPlayerKilled_Winner()
{
	if ( !IsEliminationBased() )
		return

	if ( GamePlayingOrSuddenDeath() )
		CheckForAndTrySetEliminationModeWinner()
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


void function Player_OnDamage( entity damagedEnt, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( damagedEnt.IsTitan() )
		return

	bool attackerIsPlayerOrNPC = (IsValid( attacker ) && (attacker.IsPlayer() || attacker.IsNPC()))

	if ( attackerIsPlayerOrNPC )
	{
		damagedEnt.Signal( "InterruptSyncedMelee" )

		if ( GameTime_PlayingTime() > GAMETIME_LIMIT_FOR_AFK )
		{
			if ( attacker.IsPlayer() )
			{
				GameSummarySquadData data = GameSummary_GetPlayerData( attacker )
				data.dealtDamageLateInTheGame = true
			}
		}
	}

	float invincibilityTime = GetCurrentPlaylistVarFloat( "survival_bleedout_invincibility_time", 1.5 )
	if ( Bleedout_IsBleedingOut( damagedEnt ) && Bleedout_GetBleedoutStartTime( damagedEnt ) + invincibilityTime > Time()
			&& (attackerIsPlayerOrNPC || DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.deathField) )
	{
		DamageInfo_Print( damageInfo, "bleedout invinc (" + (Time() - Bleedout_GetBleedoutStartTime( damagedEnt )) + ")" )
		DamageInfo_FlagTypicalCase( damageInfo )
		DamageInfo_SetDamage( damageInfo, 0 )
	}

	if ( damagedEnt.ContextAction_IsMeleeExecution() )
	{
		StatusEffect_AddTimed( damagedEnt, eStatusEffect.emp, 1.0, 1.0, 0.0 )
		StatusEffect_AddTimed( damagedEnt, eStatusEffect.move_slow, 0.5, 1.5, 0.5 )
		StatusEffect_AddTimed( damagedEnt, eStatusEffect.turn_slow, 0.85, 1.5, 0.5 )
	}
}

void function Survival_AddCallback_OnPlayerSetupComplete( void functionref(entity) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerSetupComplete.contains( callbackFunc )) )
	file.Callbacks_OnPlayerSetupComplete.append( callbackFunc )
}

void function Survival_AddCallback_OnPlayerKillDamage( void functionref(entity, var, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerKillDamage.contains( callbackFunc )) )
	file.Callbacks_OnPlayerKillDamage.append( callbackFunc )
}

void function Survival_AddCallback_OnPlayerGameSummaryKill( void functionref(entity, entity, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerGameSummaryKill.contains( callbackFunc )) )
	file.Callbacks_OnPlayerGameSummaryKill.append( callbackFunc )
}

void function Survival_AddCallback_OnPlayerGameSummaryAssist( void functionref(entity, entity, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerGameSummaryAssist.contains( callbackFunc )) )
	file.Callbacks_OnPlayerGameSummaryAssist.append( callbackFunc )
}

void function Survival_AddCallback_OnPlayerGameSummaryKnockdown( void functionref(entity, entity, int, var) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerGameSummaryKnockdown.contains( callbackFunc )) )
	file.Callbacks_OnPlayerGameSummaryKnockdown.append( callbackFunc )
}

void function Survival_AddCallback_OnPlayerGameSummaryKnockdownAssist( void functionref(entity, entity, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerGameSummaryKnockdownAssist.contains( callbackFunc )) )
	file.Callbacks_OnPlayerGameSummaryKnockdownAssist.append( callbackFunc )
}

void function Survival_AddCallback_OnPlayerGameSummaryStatChanged( void functionref(entity, int, int, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerGameSummaryStatChanged.contains( callbackFunc )) )
	file.Callbacks_OnPlayerGameSummaryStatChanged.append( callbackFunc )
}

void function Survival_SetCallback_ModeShouldSpawnPlayersDuringCharacterSelect( bool functionref() callbackFunc )
{
	file.Callback_ModeShouldSpawnPlayersDuringCharacterSelect = callbackFunc
}


int function CodeCallback_KillDamagePlayerOrNPC( entity ent, var damageInfo, int actualTotalDamage )
{
	entity damagedEnt = ent






	if ( !damagedEnt.IsPlayer() )
		return 0

	int damageType   = DamageInfo_GetCustomDamageType( damageInfo )
	entity attacker  = GetAttackerOrLastAttacker( ent, damageInfo )
	bool isForceKill = DamageInfo_GetForceKill( damageInfo )
	damagedEnt.p.PIN_VictimWeapon = damagedEnt.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !Bleedout_IsBleedingOut( damagedEnt )
			&& DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.fall
			&& !IsBitFlagSet( damageType, DF_SKIPS_DOOMED_STATE )
			&& !isForceKill )
	{






		StatsHook_OnDoomingDamage( damagedEnt, attacker, damageInfo )
		WeaponStatsHook_OnDownEnemy( damagedEnt, attacker, damageInfo )

		if ( attacker.IsPlayer() && attacker != damagedEnt )
		{
			AddGameSummaryKnockdown( attacker, ent, 1, damageInfo )

			foreach ( entity assistCreditPlayer, float assistTime in ent.p.playerToTimeThatAssistCreditLastsTable )
			{
				if ( !IsValid( assistCreditPlayer ) )
					continue

				if ( assistCreditPlayer.p.hasMatchParticipationEnded )
					continue

				AddGameSummaryKnockdownAssist ( assistCreditPlayer, ent, 1  )
			}
		}

		if ( ShouldDoBleedout( damagedEnt ) )
		{
			if ( attacker.GetTeam() != damagedEnt.GetTeam() )
			{
				foreach ( player in GetPlayerArrayIncludingSpectators() )
				{
					entity weapon = DamageInfo_GetWeapon( damageInfo )
					int weaponSkinItemFlavorGUID = -1

					if ( IsValid( weapon ) && weapon.GetWeaponType() == WPT_MELEE )
					{
						ItemFlavor meleeSkin = MeleeSkin_GetMeleeSkinFromPlayer( player )
						weaponSkinItemFlavorGUID = ItemFlavor_GetGUID( meleeSkin )
					}
					Remote_CallFunction_Replay( player, "ServerCallback_OnEnemyDowned", attacker, damagedEnt, DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamageSourceIdentifier( damageInfo ), weaponSkinItemFlavorGUID )
				}


				if( !UpgradeCore_UsePersonalObituaryNotifications() )

					AddPlayerScore( attacker, "Sur_DownedPilot", damagedEnt )
			}

			damagedEnt.p.playerToTimeThatAssistCreditLastsTable = GetLatestAssistingPlayersFromSameTeam( damagedEnt, attacker )
			DamageInfo_AddCustomDamageType( damageInfo, DF_KNOCKDOWN )

			// add knockdown to the latest damage history entry, it wasn't added earlier because we no longer know that we are going to be knocked down where the histroy is stored.
			Assert( ent.e.recentDamageHistory.len() > 0, "recentDamageHistory didn't have any history when it should" )
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

		// this has to be here to trigger the squad wipe before all the players on the team have been killed from the squad wipe
		else if( UpgradeCore_UsePersonalObituaryNotifications() )
		{
			damagedEnt.p.playerToTimeThatAssistCreditLastsTable = GetLatestAssistingPlayersFromSameTeam( damagedEnt, attacker )
			array<entity> teammates = GetPlayerArrayOfTeam_Alive( attacker.GetTeam() )
			foreach( entity teammate in teammates )
			{
				AddPlayerScore( teammate, "Sur_SquadWipe", damagedEnt, teammate == attacker ? "killer" : "" )
			}
		}

	}

	// this has to be here to detect a thirst as opposed to a death during squad wipe
	else if( UpgradeCore_UsePersonalObituaryNotifications() )
	{
		entity downingPlayer = Bleedout_GetBleedoutAttacker( damagedEnt )
		if ( IsValid( downingPlayer ) && downingPlayer.IsPlayer() )
		{
			attacker = downingPlayer
		}
		AddPlayerScore( attacker, "EliminatePilot", damagedEnt )
	}


	foreach ( func in file.Callbacks_OnPlayerKillDamage )
		func( ent, damageInfo, actualTotalDamage )

	return 0
}

bool function ShouldDoBleedout( entity damagedEnt )
{
	if ( GetCurrentPlaylistVarBool( "bleedout_enabled", true ) == false )
		return false

	if ( !IsValid( damagedEnt ) )
		return false


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) && damagedEnt.IsPlayer() )
		{
			if ( IsPlayerShadowZombie( damagedEnt ) )
				return false //shadow zombies don't bleedout

			if ( AreTeammatesShadowZombies( damagedEnt ) && GetCurrentPlaylistVarBool( "shadow_royale_last_living_squad_mate_can_be_rezzed", false ) == false )
				return false //last
		}



		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) && !ShadowArmy_ShouldEnterBleedout( damagedEnt ) )
			return false


	Bleedout_TryToRemoveInfiniteSelfResOnDownedSquad( damagedEnt )

	if ( Bleedout_GetShouldAlliancePlayerBleedout( damagedEnt ) )
		return true


	if ( Bleedout_AnyOtherSquadmatesAliveAndNotBleedingOut( damagedEnt ) )
		return true

	if ( Flag( "BleedoutDebug" ) )
		return true

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RECRUIT ) )
		return true

	if ( Bleedout_GetSelfResEnabled( damagedEnt ) )
		return true

	if ( Bleedout_CanTeammatesSelfRevive( damagedEnt ) )
		return true

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) && IsTeamRabid( damagedEnt.GetTeam() ))
		return true














	return false

}


void function EndThreadOn_PlayerChangedClass( entity player )
{
	EndSignal( player, "PlayerChangedClass" )
}


void function SignalThatPlayerChangedClass( entity player )
{
	player.Signal( "PlayerChangedClass" )
}


void function EndThreadOn_PlayerCleanupPermanents( entity player )
{
	EndSignal( player, "CleanupPlayerPermanents" )
}


void function DoCleanupPlayerPermanents( entity player )
{
	player.Signal( "CleanupPlayerPermanents" )
	PROTO_CleanupTrackedProjectiles( player )
}


void function CleanupAllPlayerPermanents()
{
	foreach ( entity player in GetPlayerArray() )
		DoCleanupPlayerPermanents( player )
}


void function Survival_OnEnterPickLoadout()
{
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !player.p.hasMatchParticipationStarted )
			OnPlayerMatchParticipationStarted( player )
	}
}


void function Survival_RunCharacterSelection()
{
	array<entity> rankedPlayersToLookUpLeaderBoard
	// Clear settings for capital ship
	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsAlive( player ) )
			thread Survival_ClearStagingAreaSettings( player ) // presumably, if you were alive before character select then you would have staging area setting applied

		// Set invulnerable for character select so left behind DOT ents wont do damage screen effects during the menu
		if ( !player.IsInvulnerable() )
			player.SetInvulnerable()
	}

	// Non-round based OR first round only
	if ( !IsRoundBased() || GetRoundsPlayed() == 0 )
	{
		CleanupAllPlayerPermanents()
		SURVIVAL_ChooseLootLocations()
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
			SurvivalCommentary_PickChampion()
		}
	}


	thread IntroAirdropThink()

	thread Survival_RunCharacterSelectionNew_Thread()
}


string function GetAppropriateCharacterSelectMusicTrack( entity player )
{
	string override = GetCurrentPlaylistVarString( "music_override_charselect", "" )
	if ( override.len() > 0 )
		return override


		// Uses different music tracks depending on which Alliance players are in so I can't use the playlist override
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
		{
			int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
			if ( playerAlliance == SHADOWARMY_LEGEND_ALLIANCE )
				return "Music_RevArmy_CharacterSelect_Legends"
			else
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

float s_characterSelectMusicStartTime = 0.0

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

		float squadPresentationStartTime = ( allSquadsPresentationStartTime + CharSelect_GetOutroAllSquadsPresentDuration() )

		float mvpPresentationStartTime = squadPresentationStartTime + CharSelect_GetOutroSquadPresentDuration()

		// Champion Squad Cards Start Time
		float championSquadPresentationStartTime = ( mvpPresentationStartTime + CharSelect_GetOutroMVPPresentDuration() )

		bool showChampionSquad = GetCurrentPlaylistVarInt( "survival_enable_gladiator_intros", 1 ) == 1

		// Final End Time
		float finalEndTime = championSquadPresentationStartTime
		if ( showChampionSquad)
			finalEndTime += CharSelect_GetOutroChampionPresentDuration()


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

				if (IsRevTakeover() && ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_B ) )
				{
					string REVENANT_GUID_STRING = "SAID00064207844"
					ItemFlavor ornull revOverrideItemFlav = GetItemFlavorOrNullByGUID( ConvertItemFlavorGUIDStringToGUID( REVENANT_GUID_STRING ) )

					if ( revOverrideItemFlav == null )
						break

					expect ItemFlavor( revOverrideItemFlav )
					character = revOverrideItemFlav

					// If the player is changing to a Rev store their original character selection so we can restore it before returning to the lobby
					ShadowArmy_StorePlayersOriginalCharacterSelection(  player, character )

					SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), character )
					forcedSelection = true
				}


				if ( !forcedSelection &&  ( ItemFlavor_GetAsset( character ) == CHARACTER_RANDOM || player.GetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER ) != true || CharacterSelect_CustomIsCharacterLockedForPlayer( character, player ) ) )
				{
					// They didn't lock anyone in, pick for them
					if ( ItemFlavor_GetAsset( character ) == CHARACTER_RANDOM || file.forceRandomOnNoSelect || !IsItemFlavorUnlockedForLoadoutSlot( ToEHI( player ), Loadout_Character(), character ) || CharacterSelect_CustomIsCharacterLockedForPlayer( character, player ) )
					{
						// if their selection is invalid (character is taken by a squadmate), assign them a random character
						array<ItemFlavor> charactersThatCannotBeSelected = takenCharactersByTeam[ player.GetTeam() ]
						if ( CharacterClass_AllowDuplicateCharacterPicksInTeam() )
							charactersThatCannotBeSelected = []

					#if AUTO_PLAYER
						bool isAutoPlayer = player.IsBot() && AutoPlayer_IsAutoPlayer( player )
						if ( isAutoPlayer )
						{
							foreach ( ItemFlavor forbiddenCharacter in AutoPlayer_GetForbiddenCharacters() )
							{
								if ( !charactersThatCannotBeSelected.contains( forbiddenCharacter ) )
									charactersThatCannotBeSelected.append( forbiddenCharacter )
							}
						}
					#else
						const bool isAutoPlayer = false
					#endif

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

				// Report PIN
				if ( player in PIN_ClassesOffered )
					PIN_PlayerClass( player, PIN_ClassesOffered[player] )
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

				if (IsRevTakeover() && ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_B ) )
				{
					string REVENANT_GUID_STRING = "SAID00064207844"
					ItemFlavor ornull revOverrideItemFlav = GetItemFlavorOrNullByGUID( ConvertItemFlavorGUIDStringToGUID( REVENANT_GUID_STRING ) )

					if ( revOverrideItemFlav == null )
						break

					expect ItemFlavor( revOverrideItemFlav )
					character = revOverrideItemFlav

					// If the player is changing to a Rev store their original character selection so we can restore it before returning to the lobby
					ShadowArmy_StorePlayersOriginalCharacterSelection(  player, character )

					SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_Character(), character )
					forcedSelection = true
				}


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


void function ClientCallback_Sur_UpdateCharacterLock( entity player, bool lock )
{
	if ( lock )
	{
		ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
		if ( !IsItemFlavorUnlockedForLoadoutSlot( ToEHI( player ), Loadout_Character(), character ) || CharacterSelect_CustomIsCharacterLockedForPlayer( character, player ) )
		{
			//Remote_CallFunction_UI( player, "ServerToUI_CharacterLockRejected" )
			Remote_CallFunction_NonReplay( player, "ServerCallback_CharacterLockRejected" )
			return
		}

		player.SetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER, true )
		player.SetPlayerNetTime( CHARACTER_SELECT_NETVAR_LOCKED_IN_CHARACTER_TIME, Time() )

		foreach ( func in file.Callbacks_OnPlayerLockedInCharacterCallbacks )
		{
			func( player, character )
		}
	}
	else if ( !file.characterLocksLocked )
	{
		player.SetPlayerNetBool( CHARACTER_SELECT_NETVAR_HAS_LOCKED_IN_CHARACTER, false )
	}
}

void function VerifyGivenLoadoutIsEquippedLoadout( entity player )
{
	// ltm modes have a different loadout flow that make these assumptions incorrect
	// we're just trying to track this down in the BR mode so ignore the checks if we're in a different mode
	if( !GameMode_IsActive( eGameModes.SURVIVAL ) )
		return

	if( !GetCurrentPlaylistVarBool( "force_script_error_on_loadout_class_mismatch", true ) )
		return

	EHI playerEHI = ToEHI( player )
	LoadoutEntry loadoutCharacter = Loadout_Character()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter )

	ItemFlavor skin = LoadoutSlot_GetItemFlavor( playerEHI, Loadout_CharacterSkin( character ) )
	asset loadoutModel = CharacterSkin_GetBodyModel( skin )
	string equippedModel = player.GetModelName()

	int loadoutSkinIndex  = player.GetSkinIndexByName( CharacterSkin_GetSkinName( skin ) )
	int equippedSkinIndex = player.GetSkin()

	int loadoutCamoIndex = CharacterSkin_GetCamoIndex( skin )
	int equippedCamoIndex = player.GetCamo()

	if ( loadoutSkinIndex == -1 )
	{
		loadoutSkinIndex = 0
		loadoutCamoIndex = 0
	}

	foreach ( ItemFlavor passiveAbility in CharacterClass_GetPassiveAbilities( character ) )
	{
		if( !player.HasPassive( CharacterAbility_GetPassiveIndex( passiveAbility ) ) )
		{
			ForceScriptError( "Player was missing a passive for the character they had equipped" )
		}
	}

	if( loadoutModel.tolower() != equippedModel.tolower() )
	{
		ForceScriptError( "Player does not have the model for the skin they had equipped" )
	}

	if( loadoutSkinIndex != equippedSkinIndex )
	{
		ForceScriptError( "Player does not have the skin index for the skin they had equipped" )
	}

	if( loadoutCamoIndex != equippedCamoIndex )
	{
		ForceScriptError( "Player does not have the camo index for the skin they had equipped" )
	}

}

void function Survival_OnPrematch()
{
	SetCommentaryEnabled( true )

	GameRules_MarkGameStatePrematchEnding()
	printt( "startTime: " + GetGameStartTime() + " - " + Time() )

	// TODO - R5DEV-350895: delete me once Loadout_Character callback fix is verified
	if( GetCurrentPlaylistVarBool( "verify_given_loadout_is_equipped_loadout_and_fix", false ) )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			#if ASSERTS
				VerifyGivenLoadoutIsEquippedLoadout( player )
			#endif
			Survival_PlayerCharacterSetup( player, Survival_ValidateAndGetCharacterClass( player ) )
			VerifyGivenLoadoutIsEquippedLoadout( player )
		}
	}
	else // TODO - R5DEV-350895: this should just become the only flow
	{
		foreach ( entity player in file.playersWhoNeedSetupPrematch )
		{
			if ( !IsValid( player ) || !IsAlive( player ) )
				return

			Survival_PlayerCharacterSetup( player, Survival_ValidateAndGetCharacterClass( player ) )
			SURVIVAL_SetDefaultPlayerSettings( player )
		}
		file.playersWhoNeedSetupPrematch.clear()
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
			DestroyAllLootBins()
			CleanupAllPlayerPermanents()
			SURVIVAL_ResetAllDoors()
			SURVIVAL_PopulateSpecialZones()

			SURVIVAL_ChooseLootLocations()
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

			// S3: ShadowArmy variant block commented out
			//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) && ShadowArmy_GetShouldLegendsSpawnOnGround_MatchStart() )
			//{
			//}
			//else

			{
				waitthread Survival_PutPlayersInPlane()
			}

		FlagSet( "PlaneStartMoving" )
	}
	else if ( POIPlayerSpawning_Exists() )
	{
		POIPlayerSpawning_SpawnPlayers()
	}







	else if ( ForcedSpawn_UseForcedSpawning() )
	{
		waitthread ForcedSpawn_SpawnAllPlayers()
	}

	else if ( GetCurrentPlaylistVarInt( "survival_squad_spawn_near_loot", 0 ) == 1 )
	{
		thread SpawnPlayersOnGroundWithSquadNearLoot()
	}
	else if ( GetCurrentPlaylistVarBool( "survival_custom_mode_jump_plane_override", false ) )
	{
		FlagSet( "DeathCircleActive" )
	}
	else
	{
		// If a mode is setting when the deathfield starts manually, don't set the flag here but still clear drop settings (since plane is not enabled )
		if ( !Deathfield_GetHasCustomStart() )
			FlagSet( "DeathCircleActive" )

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

bool function Survival_IsJumpFromPlaneEnabled()
{
	if ( !Survival_IsPlaneEnabled() )
		return false






	return true
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


SurvivalSquadPINData function GetSurvivalSquadPINData( int teamIndex )
{
	return file.squadPINData[teamIndex]
}


void function SpawnPlayersOnGroundWithSquadNearLoot()
{
	// Start the death circle before we spawn the players because we wont know info about the circle until we set this flag
	FlagSet( "DeathFieldPaused" )
	FlagSet( "DeathCircleActive" )
	WaitFrame()

	FlagWait( "DoneCreatingDeathFieldPosition" )

	DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData( Survival_Loot_GetDefaultRealm() )
	vector center                 = deathFieldData.center
	float radius                  = (deathFieldData.endRadius + deathFieldData.currentRadius) / 2.0 // use radius that is in the middle between current circle and the next circle

	_SpawnPlayersOnGroundWithSquadNearLoot_internal( center, radius, GetAllPlayersSortedByTeam(), false )

	FlagClear( "DeathFieldPaused" )
}

#if DEVELOPER
void function DEV_TestNitroSpawning( float radius = 4000 )
{
	_SpawnPlayersOnGroundWithSquadNearLoot_internal( GP().GetOrigin(), radius, GetAllPlayersSortedByTeam(), true )
}
#endif

void function _SpawnPlayersOnGroundWithSquadNearLoot_internal( vector center, float radius, table< int, array< entity > > groupedPlayers, bool debug = false )
{
	int numSquads = groupedPlayers.len()

	if ( debug )
	{
		//DebugDrawCircle( center, <0, 0, 0>, radius, <255, 255, 0>, true, 10.0, 32 )
	}

	// Get all loot locations in the map. This is where we will spawn squads
	array<vector> lootPoints = VectorArrayWithin( SURVIVAL_GetAllLootLocationsCopy(), center, radius )

	vector extents = < 16, 16, 64 >
	RemoveCrampedSpawnPoints( lootPoints, extents, debug )

	if ( lootPoints.len() < numSquads )
	{
		printt( "There weren't enough valid loot positions in the circle. Using random navmesh locations instead!" )
		vector ornull clampedCenter = NavMesh_ClampPointForHullWithExtents( center, HULL_HUMAN, <128, 128, 128> )
		if ( clampedCenter != null )
			lootPoints = NavMesh_RandomPositions_LargeArea( expect vector( clampedCenter ), HULL_HUMAN, numSquads * 3, radius * 0.35, radius )
	}

	Assert( lootPoints.len() >= numSquads, "Couldn't find enough locations near loot on navmesh to spawn players in circle at " + center + " radius " + radius )

	// Get some spaced out spawn points using the loot points as choices
	float spawnSpacingRadius  = radius * 0.5
	array<vector> spawnPoints = GetRandomPointsFromList( lootPoints, center, radius, numSquads, spawnSpacingRadius )

	printt( "Spawning", numSquads, "squads inside circle near loot" )
	Assert( spawnPoints.len() == numSquads )

	if ( debug )
	{
		foreach ( vector spawnPoint in spawnPoints )
		{
			//DebugDrawSphere( spawnPoint, 32.0, COLOR_MAGENTA, true, 10.0 )
			//DebugDrawCircle( spawnPoint, <0, 0, 0>, spawnSpacingRadius, COLOR_MAGENTA, true, 10.0 )
		}
	}

	bool giveRandomLoot = GetCurrentPlaylistVarInt( "survival_squad_spawn_with_random_loot", 0 ) == 1
	int index           = 0
	foreach ( int team, array<entity> players in groupedPlayers )
	{
		ArrayRemoveDead( players )
		if ( players.len() == 0 )
			continue

		int numPositions             = maxint( 2, MAX_TEAM_PLAYERS )
		array<vector> neighborPoints = NavMesh_GetClosestPoints( spawnPoints[index], numPositions )
		Assert( neighborPoints.len() == numPositions )

		vector spawnCenter = <0, 0, 0>
		foreach ( vector p in neighborPoints )
			spawnCenter += p
		spawnCenter /= neighborPoints.len()

		string names
		foreach ( int i, entity player in players )
		{
			names = names + player.GetPlayerName() + ", "
			Assert( players.len() <= MAX_TEAM_PLAYERS, "Tried placing a team of len " + players.len() + " even though the max is " + MAX_TEAM_PLAYERS + ". The players' names are " + names )

			PutPlayerInSafeSpot( player, null, null, neighborPoints[i], neighborPoints[i] )
			vector angles = FlattenAngles( VectorToAngles( spawnCenter - neighborPoints[i] ) )
			player.SetAbsAngles( angles )

			if ( debug )
			{
				DrawAngledBox( neighborPoints[i], angles, <-16, -16, 0>, <16, 16, 72>, 255, 0, 0, true, 10.0 )
				//DebugDrawLine( neighborPoints[i] + <0, 0, 36>, neighborPoints[i] + <0, 0, 36> + (AnglesToForward( angles ) * 128), <255, 0, 0>, true, 10.0 )
			}
			else
			{
				ClearPlayerIntroDropSettings( player )

				if ( giveRandomLoot )
					GiveRandomStartingLoot( player )
			}
		}

		index++
	}
}

void function RemoveCrampedSpawnPoints( array< vector > lootPoints, vector extents = < 16, 16, 64 >, bool debug = false )
{
	// Remove loot points that don't have enough neighboring positions for your teammates. This also gets rid of points not on navmesh because neighboring positions will be 0 if we don't start on navmesh
	for ( int i = lootPoints.len() - 1; i >= 0; i-- )
	{
		// Clamp loot point to navmesh
		vector ornull clampedPoint = NavMesh_ClampPointForHullWithExtents( lootPoints[i], HULL_HUMAN, <16, 16, 64> )
		if ( clampedPoint != null )
		{
			lootPoints[i] = expect vector( clampedPoint )
			int numPositions             = maxint( 2, MAX_TEAM_PLAYERS )
			array<vector> neighborPoints = NavMesh_GetClosestPoints( lootPoints[i], numPositions )
			if ( neighborPoints.len() >= numPositions )
			{
				if ( debug )
				{
					DebugDrawSphere( lootPoints[i], 4.0, 0, 128, 0, true, 10.0, 4 )
					DebugDrawLine( lootPoints[i], lootPoints[i] + <0, 0, 2000>, 0, 128, 0, true, 10.0 )
				}
				continue
			}
		}

		// Failed
		if ( debug )
		{
			DebugDrawSphere( lootPoints[i], 4.0, 255, 128, 128, true, 10.0, 4 )
			DebugDrawLine( lootPoints[i], lootPoints[i] + <0, 0, 2000>, 255, 128, 128, true, 10.0 )
		}
		lootPoints.remove( i )
	}
}

void function GiveRandomStartingLoot( entity player )
{
	if ( player.IsBot() )
		return

	//EndSignal( player, "OnDeath" )

	// Todo: move this gather info about loot stuff so it's only done once, not once per player

	//printt( "#################################" )
	//printt( "     GiveRandomStartingLoot" )
	//printt( "#################################" )

	table< int, array<string> > lootNamesByType
	lootNamesByType[eLootType.MAINWEAPON] <- []
	lootNamesByType[eLootType.ATTACHMENT] <- []
	lootNamesByType[eLootType.ARMOR] <- []
	lootNamesByType[eLootType.HELMET] <- []
	lootNamesByType[eLootType.HEALTH] <- []
	lootNamesByType[eLootType.AMMO] <- []
	lootNamesByType[eLootType.ORDNANCE] <- []
	lootNamesByType[eLootType.BACKPACK] <- []

	table< string, LootData > lootDataTable = SURVIVAL_Loot_GetLootDataTable()
	foreach ( string lootName, LootData lootData in lootDataTable )
	{
		if ( !IsLootTypeValid( lootData.lootType ) )
			continue

		if ( !LootTypeHasAnyChanceToSpawn( lootName ) )
			continue
		if ( lootData.lootType in lootNamesByType )
			lootNamesByType[ lootData.lootType ].append( lootName )
	}

	//################################
	// Give Weapons and Attachments
	//################################

	//printt( "  Possible Weapons:" )
	//foreach( string ref in lootNamesByType[eLootType.MAINWEAPON] )
	//printt( "    ", ref )

	int numWeaponsToGive = CoinFlip() ? 1 : 2
	//printt( "  Giving", numWeaponsToGive, "weapons" )

	lootNamesByType[eLootType.MAINWEAPON].randomize()

	array<string> playerWeapons
	foreach ( int i, string lootRef in lootNamesByType[eLootType.MAINWEAPON] )
	{
		LootData data    = SURVIVAL_Loot_GetLootDataByRef( lootRef )
		// GIVE THE WEAPON
		//printt( "    ", weaponRef )
		string weaponRef = data.baseWeapon
		int slot         = -1
		if ( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) == null )
			slot = WEAPON_INVENTORY_SLOT_PRIMARY_0
		else if ( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 ) == null )
			slot = WEAPON_INVENTORY_SLOT_PRIMARY_1
		if ( slot != -1 )
		{
			player.GiveWeapon( weaponRef, slot, data.baseMods )
			playerWeapons.append( weaponRef )
			//WaitFrame()
			player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, slot )
			//WaitFrame()
		}

		// FIND ALL VALID ATTACHMENTS FOR THIS WEAPON
		array<string> validAttachments
		foreach ( string attachRef in lootNamesByType[eLootType.ATTACHMENT] )
		{
			if ( CanAttachToWeapon( attachRef, weaponRef ) )
				validAttachments.append( attachRef )
		}
		//foreach( string attachRef in validAttachments )
		//	printt( "      -" + attachRef )

		// GIVE RANDOM ATTACHMENTS
		validAttachments.randomize()
		int numAttachmentsToGive = RandomInt( 5 )

		foreach ( int k, string attachRef in validAttachments )
		{
			entity loot = SpawnLoot( attachRef, player.GetOrigin(), false )
			Survival_PickupItem( loot, player, PICKUP_FLAG_ALT )

			if ( k + 1 >= numAttachmentsToGive )
				break
		}

		if ( i + 1 >= numWeaponsToGive )
			break
	}

	//################################
	// Give Armor
	//################################

	//printt( "  Possible Armor:" )
	//foreach( string ref in lootNamesByType[eLootType.ARMOR] )
	//	printt( "    ", ref )

	bool giveArmor = RandomInt( 100 ) < 80
	if ( giveArmor )
	{
		string armorRef    = lootNamesByType[eLootType.ARMOR].getrandom()
		// Get health value for armor so players get it at appropriate value
		LootData armorData = SURVIVAL_Loot_GetLootDataByRef( armorRef )
		int armorHealth    = SURVIVAL_GetArmorShieldCapacity( armorData.tier )

			if ( EvolvingArmor_IsEquipmentEvolvingArmor( armorRef ) )
				armorHealth = EvolvingArmor_GetEvolvingArmorHealthForTier( armorData.tier )

		//printt( "  Giving Armor: ", armorRef )
		SURVIVAL_GivePlayerEquipment( player, armorRef, armorHealth )
	}

	//################################
	// Give Helmet
	//################################

	//printt( "  Possible Helmet:" )
	//foreach( string ref in lootNamesByType[eLootType.HELMET] )
	//	printt( "    ", ref )

	bool giveHelmet = RandomInt( 100 ) < 80
	if ( giveHelmet )
	{
		string helmetRef = lootNamesByType[eLootType.HELMET].getrandom()
		//printt( "  Giving Helmet: ", helmetRef )
		SURVIVAL_GivePlayerEquipment( player, helmetRef )
	}

	//################################
	// Give Health
	//################################

	//printt( "  Possible Health:" )
	//foreach( string ref in lootNamesByType[eLootType.HEALTH] )
	//	printt( "    ", ref )

	int count = RandomInt( 3 )
	for ( int i = 0 ; i < count ; i++ )
	{
		entity loot = SpawnLoot( lootNamesByType[eLootType.HEALTH].getrandom(), player.GetOrigin(), false )
		Survival_PickupItem( loot, player )
	}

	//################################
	// Give Ammo
	//################################

	//printt( "  Ammo:" )
	array<string> neededAmmoTypes
	foreach ( string weaponRef in playerWeapons )
	{
		string ammoType = GetWeaponAmmoType( weaponRef )//GetWeaponInfoFileKeyField_GlobalString( weaponRef, "ammo_pool_type" )
		neededAmmoTypes.append( ammoType )
	}

	foreach ( string ref in lootNamesByType[eLootType.AMMO] )
	{
		if ( neededAmmoTypes.contains( ref ) )
		{
			// Player has a weapon that uses this ammo type
			count = RandomIntRange( 2, 5 )
			//printt( "    ", ref + "*", "(" + count + ")" )
		}
		else
		{
			// Player doesn't need this ammo
			count = RandomInt( 3 )
			//printt( "    ", ref, "(" + count + ")" )
		}

		for ( int i = 0 ; i < count ; i++ )
		{
			entity loot = SpawnLoot( ref, player.GetOrigin(), false )
			Survival_PickupItem( loot, player )
		}
	}

	//################################
	// Give Ordnance
	//################################

	//printt( "  Possible Ordnance:" )
	//foreach( string ref in lootNamesByType[eLootType.ORDNANCE] )
	//	printt( "    ", ref )

	count = RandomInt( 3 )
	for ( int i = 0 ; i < count ; i++ )
	{
		entity loot = SpawnLoot( lootNamesByType[eLootType.ORDNANCE].getrandom(), player.GetOrigin(), false )
		Survival_PickupItem( loot, player )
	}

	//################################
	// Give Backpack
	//################################

	//printt( "  Possible Backpack:" )
	//foreach( string ref in lootNamesByType[eLootType.BACKPACK] )
	//	printt( "    ", ref )

	bool giveBackpack = RandomInt( 100 ) < 50
	if ( giveBackpack )
	{
		entity loot = SpawnLoot( lootNamesByType[eLootType.BACKPACK].getrandom(), player.GetOrigin(), false )
		Survival_PickupItem( loot, player )
	}

	//printt( "#################################" )
	//printt( "#################################" )
}


void function Survival_WinnerDetermined()
{
	// This is a hack we need until the init refactor is done TODO: Justin Moon - remove this
	if ( !GameMode_IsActive( eGameModes.SURVIVAL ) )
		return

	// We do special logic if this is a round based game where remaining match end logic is not run
	bool isRoundBased = IsRoundBased()
	if ( isRoundBased && !IsRoundBasedGameOver() )
	{
		array < entity > allPlayersArray = GetPlayerArray()
		foreach ( player in allPlayersArray )
		{
			if ( IsValid( player ) )
			{
				player.SetInvulnerable()
				StopDialogueForPlayer( player )
			}
		}

		SetGlobalNetBool( "characterSelectionReady", false )
		RoundBased_ResetDeathfield()
		return
	}

	int winningTeam = GetWinningTeam()
	array<entity> winningPlayers = GetPlayerArrayOfTeam( winningTeam )

	foreach ( entity player in winningPlayers )
	{
		//Defensive fix for issue where we fail to set squadRank for winning teams
		if ( file.playerData.len() > 0)
			file.playerData[EHIToEncodedEHandle( player )].squadRank = 1

		if ( !player.IsBot() )
		{
			string characterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() ) )
			TelemetryEvent( "charSel.win." + characterName, 1 )
			PIN_WeaponSummary( player )
		}
	}

	GamemodeUtility_GamemodeSetWinnerCommon( winningTeam, eWinReason.ELIMINATION, Survival_SurvivalOnlySetWinnerFunctionality )
}

// Logic specific to Survival that will get run inside of the GamemodeUtility_GamemodeSetWinnerCommon function.
// All other logic in that function is shared between modes
void function Survival_SurvivalOnlySetWinnerFunctionality( int winningTeam )
{
	array < entity > allPlayersAndSpectatorsArray = GetPlayerArrayIncludingSpectators()
	foreach ( entity player in allPlayersAndSpectatorsArray )
	{
		// moved this here from inside SURVIVAL_SendWinningSquadDataToPlayer() because it has nothing to do with sending squad data to the player
		if ( IsValid( player ) )
		{
			if ( GetCurrentPlaylistVarBool( "play_match_end_music_on_squad_eliminated", true ) )
			{
				// this will retrigger the loss music for the lossers as well as play the win music for the winner.
				// Can't use PlayMusicToPlayer(), because on the client, the music is played on the viewPlayer, so you to hear the wrong music if you are specating.
				StopAllMusicOnPlayer( player )
				Remote_CallFunction_NonReplay( player, "ServerCallback_PlayMatchEndMusic" )
			}
		}
	}
}


void function SURVIVAL_SendWinningSquadDataToPlayer( entity player, int winningTeam )
{
	array<entity> winningPlayers = GetPlayerArrayOfTeam( winningTeam )

	if ( winningTeam in file.squadData )
	{
		// Clear their local squad data
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddWinningSquadData", -1, -1, 0, 0, 0, 0, 0, 0, 0,
																					 true, 0, 0, 0, 0, 0, 0 )

		// Send new squad data for winning squad
		foreach ( int i, GameSummarySquadData data in file.squadData[ winningTeam ] )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_AddWinningSquadData", i, data.eHandle, data.kills, data.assists, data.knockdowns,
																							data.damageDealt, data.survivalTime, data.revivesGiven, data.respawnsGiven,
																							data.displayData3IsTime, data.displayData[3], data.displayData[4], data.displayData[5], data.displayData[6],
																							file.gameResultFlags, file.gameScoreFlags )
		}
	}

	// moved the music stuff out of this function since it had nothing to do with sending winner data to the client.
}


void function Survival_OnEpilogue()
{
	//Survival does nothing with epilogue
}


void function Survival_OnResolution()
{
	entity aWinner
	int winningTeam = GetWinningTeam()
	foreach ( entity player in GetPlayerArray() )
	{

		player.Hide()

		player.FreezeControlsOnServer()
		player.ClearOffhand( eActiveInventorySlot.mainHand )
		player.HolsterWeapon()

		// send to all players that isn't spectating a player.
		if ( winningTeam != TEAM_UNASSIGNED && player.GetObserverMode() != OBS_MODE_IN_EYE )
		{
			aWinner = player
			StatusEffect_StopAll( player )
		}
	}

	if ( !IsPVEMode() )
	{
		array<EncodedEHandle> winnerSquad = GetPlayerSquadSafe( EHIToEncodedEHandle( aWinner ), 3 )
		SvApexScreens_ForceShowSquad( winnerSquad[0], winnerSquad[1], winnerSquad[2] )
	}
}


bool function Survival_HasPlayerJumpedOutOfPlane( entity player )
{
	return ( EHIToEncodedEHandle( player ) in file.playerData && file.playerData[ EHIToEncodedEHandle( player ) ].hasJumpedOutOfPlane == true )
}


void function Survival_ResetPlayerHighlights()
{
	foreach ( player in GetPlayerArray() )
	{
		//Remove ALL player highlights
		Survival_SetFriendlyHighlight( player )

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

		Highlight_SetGameModeEnemyHighlight( player )
	}
}


string function GetHighlightForTeamate( entity player )
{
	if ( IsPVEMode() && IsMultiTeamMission() )
	{
		int squadID = player.GetSquadID()
		return SQUAD_TEAM_HIGHLIGHTS[squadID]
	}


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) && IsPlayerShadowZombie( player ) )
			return "shadow_friendly"


	return "sp_friendly_hero"
}


void function Survival_SetFriendlyOwnerHighlight( entity player, entity highlightEnt )
{
	string highlight = GetHighlightForTeamate( player )
	Highlight_SetFriendlyHighlight( highlightEnt, highlight )
}


void function Survival_SetFriendlyHighlight( entity player )
{






	if ( IsEventFinale() )
		return

	string highlight = GetHighlightForTeamate( player )
	Highlight_SetFriendlyHighlight( player, highlight )
}


void function Survival_PlayerRespawnedTeammate( entity respawnCaller, entity respawningPlayer )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( respawnCaller.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( respawnCaller )
	data.respawnsGiven += 1

	AddXP( respawnCaller, eXPType.RESPAWN_ALLY )
	UnlockAchievement( respawnCaller, achievements.RESPAWN_TEAMMATE )
	StatsHook_PlayerRespawnedTeammate( respawnCaller, respawningPlayer )

	foreach ( func in file.Callbacks_OnPlayerGameSummaryStatChanged )
		func( respawnCaller, eStatNames.respawnsGiven, (data.respawnsGiven - 1), data.respawnsGiven )
}


void function Survival_PlayerDealtDamage( entity player, entity victim, entity weapon, int healthDamage, int shieldDamage, int absorbedDamage, int damageType = -1 )
{
	if ( victim.IsPlayer() )
	{
		AddGameSummaryDamage( player, victim, healthDamage + shieldDamage + absorbedDamage )
	}
	EvolvingArmor_PlayerDealtDamage( player, victim, weapon, healthDamage, shieldDamage, absorbedDamage, damageType )




	Lifesteal_PlayerDealtDamage( player, victim, weapon, healthDamage, shieldDamage, absorbedDamage, damageType )

	if ( player.GetTeam() != victim.GetTeam() )
	{
		int reason = victim.IsPlayer() ? eDeadPeriodEndReason.DEALT_DAMAGE_TO_PLAYER : ( victim.IsNPC() ? eDeadPeriodEndReason.DEALT_DAMAGE_TO_NPC : eDeadPeriodEndReason.UNKNOWN_REASON )
		DeadPeriodChecker_PlayerDeadPeriodEnd( player, reason )
	}
}


string function Survival_GetOffhandMeleeWeaponName( entity player )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	ItemFlavor meleeSkin = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_MeleeSkin( character ) )
	asset meleeWeaponAsset = GetGlobalSettingsAsset( ItemFlavor_GetAsset( meleeSkin ), "parentItemFlavor" )
	ItemFlavor meleeWeapon = GetItemFlavorByAsset( meleeWeaponAsset )

	return MeleeWeapon_GetOffhandWeaponClassname( meleeWeapon )
}


string function Survival_GetMeleeWeaponName( entity player )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	ItemFlavor meleeSkin = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_MeleeSkin( character ) )
	asset meleeWeaponAsset = GetGlobalSettingsAsset( ItemFlavor_GetAsset( meleeSkin ), "parentItemFlavor" )
	ItemFlavor meleeWeapon = GetItemFlavorByAsset( meleeWeaponAsset )

	return MeleeWeapon_GetMainWeaponClassname( meleeWeapon )
}


ItemFlavor function Survival_ValidateAndGetCharacterClass( entity player )
{
	EHI playerEHI = ToEHI( player )
	LoadoutEntry loadoutCharacter = Loadout_Character()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter )
	bool isItemFlavorUnlockedForLoadoutSlot = IsItemFlavorUnlockedForLoadoutSlot( playerEHI, loadoutCharacter, LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter ) )


		if (IsRevTakeover() && ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_B ) )
		{
			string REVENANT_GUID_STRING = "SAID00064207844"
			ItemFlavor ornull revOverrideItemFlav = GetItemFlavorOrNullByGUID( ConvertItemFlavorGUIDStringToGUID( REVENANT_GUID_STRING ) )

			if ( revOverrideItemFlav != null )
			{
				expect ItemFlavor( revOverrideItemFlav )

				if ( LoadoutSlot_GetItemFlavor( playerEHI, loadoutCharacter ) != revOverrideItemFlav )
				{
					// If the player is changing to a Rev store their original character selection so we can restore it before returning to the lobby
					ShadowArmy_StorePlayersOriginalCharacterSelection(  player, revOverrideItemFlav )

					SetItemFlavorLoadoutSlot( playerEHI, loadoutCharacter, revOverrideItemFlav )
				}


				isItemFlavorUnlockedForLoadoutSlot = true
			}
		}









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


void function Survival_OnPlayerRespawned( entity player )
{
	SurvivalPlayerRespawnedInit( player )
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

	// player.GiveOffhandWeapon( HOLO_PROJECTOR_WEAPON_NAME, HOLO_PROJECTOR_INDEX ) // offhand slot 6 not in S3
	// player.GiveOffhandWeapon( GENERIC_OFFHAND_WEAPON_NAME, GENERIC_OFFHAND_INDEX ) // offhand slot 7 not in S3


	player.DisableIdLights()
	player.DisableAutoReloadNoAmmo()

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

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		file.isFRCharacterRespawning = true

	player.TakeOffhandWeapon( OFFHAND_TACTICAL )
	player.TakeOffhandWeapon( OFFHAND_ULTIMATE )
	// OFFHAND_GENERIC (7) not in S3 — range is 0-5
	TakeAllPassives( player )

	// clear all mods (b/c we added a passive weapon mod, we have to
	//  explicitly clear the passive mods if we were to change character types, and we have to
	//  reapply the mods that are true for all survival games.
	ClearExtraWeaponMods( player )
	Survival_SetupWeaponMods( player )

	asset setFile = CharacterClass_GetSetFile( character )
	array<string> existingMods
	if ( !player.IsTitan() )
	{
		existingMods = player.GetPlayerSettingsMods()

		string SLOW_STRAFE_MOD = "slow_strafe"
		bool slowStrafeNeeded  = CharacterClass_HasSlowStrafe( character )
		if ( !slowStrafeNeeded && existingMods.contains( SLOW_STRAFE_MOD ) )
		{
			existingMods.fastremovebyvalue( SLOW_STRAFE_MOD )
		}
		else if ( slowStrafeNeeded && !existingMods.contains( SLOW_STRAFE_MOD ) )
		{
			existingMods.append( SLOW_STRAFE_MOD )
		}
	}


	player.SetPlayerSettingsWithMods( setFile, existingMods )

	// camo and skin are set elsewhere

	// Setup shields ( if player isn't bleeding out ):
	if( !Bleedout_IsBleedingOut( player ) )
	{
		string itemRef = EquipmentSlot_GetLootRefForSlot( player, "armor" )
		if ( SURVIVAL_Loot_IsRefValid( itemRef ) )
		{
			LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )
			player.SetShieldHealthMax( SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data ) )
		}
		else
		{
			player.SetShieldHealthMax( GetPlayerSettingBaseShield( player ) )
		}
		player.SetShieldHealth( player.GetShieldHealthMax() )
	}

	// passives
	{
		foreach ( ItemFlavor passiveAbility in CharacterClass_GetPassiveAbilities( character ) )
		{
			GivePassive( player, CharacterAbility_GetPassiveIndex( passiveAbility ) )

			// Attach passive specific weapon mods to a player

			string passiveWeaponMod = CharacterAbility_GetPassiveWeaponMod( passiveAbility )
			if ( passiveWeaponMod != "" )
				GiveExtraWeaponMod( player, passiveWeaponMod )
		}

		float damageScale = CharacterClass_GetDamageScale( character )
		if ( damageScale < 1.0 ) // TODO: it's a bit backwards the the playlist var drives the passive, that that's how it is for now
			GivePassive( player, ePassives.PAS_FORTIFIED )
		else if ( damageScale > 1.0 )
			GivePassive( player, ePassives.PAS_LOWPROFILE )
	}

	// tactical
	{
		ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )
		player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL, [] )
		entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		tacticalWeapon.SetWeaponPrimaryClipCount( tacticalWeapon.GetWeaponPrimaryClipCountMax() ) // give tactical straight away
		if ( GetCurrentPlaylistVarBool( "survival_give_tactical_on_first_land", true ) )
		{
			if ( !player.p.survivalLandedOnGround && !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
				tacticalWeapon.AddMod( "survival_ammo_regen_paused" )
		}

		Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", tacticalWeapon )
	}

	// ultimate
	{
		ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( character )
		player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE, [] )

		entity ultimateWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )

		float fireDuration = ultimateWeapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
		player.p.lastPilotOffhandUseTime[ OFFHAND_INVENTORY ] = Time() - fireDuration // track ultimate usage
		player.p.lastPilotClipFrac[ OFFHAND_INVENTORY ]       = 0.0

		// If we haven't landed and begun the game yet, let the ultimate charge faster (staging)
		if ( GetGameState() <= eGameState.WaitingForPlayers )
		{
			if ( GetCurrentPlaylistVarBool( "staging_ultimates_enabled", false ) )
			{
				if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
					ultimateWeapon.AddMod( "survival_ammo_regen_staging" )
			}
			else
			{
				ultimateWeapon.AddMod( "survival_ammo_regen_paused" )
			}
		}

		if ( !player.p.survivalLandedOnGround && !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
			ultimateWeapon.AddMod( "survival_ammo_regen_paused" )
	}





	// Put the player in a safe spot if they aren't parented to anything
	// This is needed because they may be switching to a larget character that now is stuck in geo
	entity parentEnt = player.GetParent()
	if ( !IsValid( parentEnt ) && !player.Anim_IsActive() )
	{
		array< vector > navmeshPositions = NavMesh_GetClosestPoints( player.GetOrigin(), 32 )

		foreach ( vector navmeshPosition in navmeshPositions )
		{
			if ( PlayerCanTeleportHere( player, navmeshPosition ) )
			{
				PutPlayerInSafeSpot( player, null, null, navmeshPosition, navmeshPosition )
				break
			}
		}
	}

	if( giveDefaultMelee )
		SURVIVAL_TryGivePlayerDefaultMeleeWeapons( player )

	Inventory_RefreshAllPlayerEquipment( player )

	//Anonymous Mode
	//bool playerIsAnonymous = player.IsHudSettingAnonymousMode() // S3: entity method not available
	bool playerIsAnonymous = false
	player.SetPlayerNetBool( "anonymizePlayerName", playerIsAnonymous )

	foreach ( func in file.Callbacks_OnPlayerSetupComplete )
	{
		func( player )
	}

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		file.isFRCharacterRespawning = false

		if (GetCurrentPlaylistVarBool ("staging_auto_ultimates", true) )
		{
			entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
			int ammoMax = ultWeapon.GetWeaponPrimaryClipCountMax()

			ultWeapon.SetWeaponPrimaryClipCountNoRegenReset( ammoMax )
			Ultimates_OnPlayerUltIsReady( player, ultWeapon )
			StatusEffect_AddTimed( player, eStatusEffect.emp, 0.3, 0.3, 0.3 )
		}
	}
}


void function Survival_OnPlayerChangedCharacterClass( EHI playerEHI, ItemFlavor character )
{
	if ( IsLobby() )
		return

	entity player = FromEHI( playerEHI )
	if ( !IsValid( player ) )
		return

	switch( GetGameState() )
	{
		case eGameState.WaitingForPlayers:
		{
			// Firing Range and Training both stay in this gamestate.
			DoCleanupPlayerPermanents( player )
			break
		}

		case eGameState.PickLoadout:
		{
			if ( !file.playersWhoNeedSetupPrematch.contains( player ) && IsAlive( player ) && player.GetPlayerSettings() != CharacterClass_GetSetFile( character ) )
				file.playersWhoNeedSetupPrematch.append( player ) // late-joiners spawn as spectators early and so don't trigger character-class setup when spawning.

			return // postpone class changes until after character select (Prematch)
		}

		case eGameState.Prematch:
		{
			break
		}

		case eGameState.Playing:
		{
			if ( IsCharacterReselectEnabled() )
			{
				break
			}
			// *DO NOT BREAK!* fallthrough to default
		}

		default:
		{
			if ( player.GetPlayerSettings() != CharacterClass_GetSetFile( character ) )
				 break // catch the case where we have a mismatch between Loadout character & Code class
			else if ( !GetConVarBool( "sv_cheats" ) )
				return

			break
		}
	}

	SignalThatPlayerChangedClass( player )

	FiringRange_PrePlayerChangedCharacterSetup( player, character )
	int respawnIn3P = StagingArea_PrePlayerChangedCharacterSetup( player, character )

	if ( !IsAlive( player ) )
		return

	if( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		if( !(EHIToEncodedEHandle( player ) in file.playerChangeClassData) )
		{
			PlayerChangeClassData pccd
			pccd.respawnPos = player.GetOrigin()
			pccd.respawnAngles = player.GetAngles()
			pccd.respawnIn3P = ( respawnIn3P == 3 )
			file.playerChangeClassData[ EHIToEncodedEHandle( player ) ] <- pccd
		}
	}

	if ( Bleedout_IsBleedingOut( player ) || player.ContextAction_IsMeleeExecution() || GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		if ( player.ContextAction_IsMeleeExecutionTarget() && IsValid( player.e.syncedMeleeAttacker ) )
		{
			entity attacker = player.e.syncedMeleeAttacker
			player.Die( attacker, attacker, {damageType = DMG_MELEE_EXECUTION, damageSourceId = eDamageSourceId.human_execution} )
		}
		else if( GetCurrentPlaylistVarBool( "fr_nodeath_characterchange", false ) && !Bleedout_IsBleedingOut( player ) )
		{
			thread FiringRange_SwitchCharacterPresentation_Thread( player, character )
		}
		else
		{
			player.Die( null, null, {damageSourceId = damagedef_suicide} )
		}
		return
	}

	Survival_PlayerCharacterSetup( player, character )
}

void function FiringRange_SwitchCharacterPresentation_Thread( entity player, ItemFlavor character )
{
	if( !IsValidPlayer( player ) )
		return

	player.Signal( "FiringRange_CharacterChanged" )

	//EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnSyncedMelee" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "StartHeal" )
	EndSignal( player, "FiringRange_CharacterChanged" )

	PassByReferenceBool wasAlreadyInShoulderMode
	PassByReferenceInt forceStandHandle
	PassByReferenceBool respawnIn3P
	PassByReferenceBool weaponsAndMovements_WereDisabled

	OnThreadEnd(
		function() : ( player, wasAlreadyInShoulderMode, forceStandHandle, respawnIn3P, weaponsAndMovements_WereDisabled ) //, emote3pSound )
		{
			if ( !IsValidPlayer( player ) )
				return

			player.SetTrackEntitySpringViewToCenterRate( 1.0 )
			player.RemoveForcedStance( forceStandHandle.value )

			if ( !wasAlreadyInShoulderMode.value )
			{
				//if ( player.Player_IsSkywardLaunching() ) // S3: not available
				//{
					//player.SetTrackEntityOffsetRight( 0 ) // S3: not available
					//player.SetTrackEntityBlendInTimes( 1.0, 0.0, 0.0 ) // S3: not available
					//player.SetTrackEntityBlendOutTime( 1.0 ) // S3: not available
					player.SetTrackEntitySpringViewToCenterRate( 0 )
				//}
				//else
				//{
				//	player.ClearTrackEntitySettings()
				//}
			}

			if ( respawnIn3P.value )
			{
				player.SetThirdPersonShoulderModeOn()
			}
			else
			{
				player.SetThirdPersonShoulderModeOff()
			}

			Remote_CallFunction_NonReplay( player, "SCB_FiringRange_EnableCharacterChange", true )
		}
	)


	Survival_PlayerCharacterSetup( player, character )

	// [ R5DEV-487573 ] If player is bleeding out, don't do the camera flourish.
	if( !IsAlive( player ) || Bleedout_IsBleedingOut( player ))
		return

	// Took the camera transition scripting from emotes, without the emotes:
	const float PITCH = 50.0
	const float YAW = 180.0

	const float MIN_PLAYER_FOV = 70
	const float MAX_PLAYER_FOV = 110
	const float CAM_FOLLOW_DISTANCE_AT_MIN_FOV = 120
	const float CAM_FOLLOW_DISTANCE_AT_MAX_FOV = 70

	const float BASE_OFFSET_HEIGHT					= -24
	const float OUTRO_EASE_TIME						= 0.2

	forceStandHandle.value = player.PushForcedStance( FORCE_STANCE_STAND )

	respawnIn3P.value = false
	if( EHIToEncodedEHandle( player ) in file.playerChangeClassData )
	{
		respawnIn3P.value = file.playerChangeClassData[ EHIToEncodedEHandle( player ) ].respawnIn3P || FRSetting_3rdPerson_IsOn( player )
		delete file.playerChangeClassData[ EHIToEncodedEHandle( player ) ]
	}

	wasAlreadyInShoulderMode.value = IsValid( player.GetTrackEntity() )

	float cameraHeightOffset = 24
	float trackDist = GraphCapped( 70.0 /*player.GetDefaultFOV() S3: not available*/, MIN_PLAYER_FOV, MAX_PLAYER_FOV, CAM_FOLLOW_DISTANCE_AT_MIN_FOV, CAM_FOLLOW_DISTANCE_AT_MAX_FOV )
	weaponsAndMovements_WereDisabled.value = false

	//If player has melee equipped, try equip another weapon before switching character.
	array< entity > allWeapons = player.GetMainWeapons()
	string meeleWeaponName = Survival_GetMeleeWeaponName( player )
	entity playerWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( playerWeapon ) )
	{
		if ( playerWeapon.GetWeaponClassName() == meeleWeaponName )
		{
			foreach ( weapon in allWeapons )
			{
				player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weapon.GetWeaponClassName() )
				break
			}
			//Need to wait at least 0.2s here for the action to complete
			wait 0.2
		}
	}

	if( !IsValidPlayer( player ) )
		return

	StopAllSoundsOnEntity( player )

	Remote_CallFunction_NonReplay( player, "SCB_FiringRange_EnableCharacterChange", false )
	if( !wasAlreadyInShoulderMode.value )
	{
		player.SetTrackEntityDistanceMode( "scriptOffset" )
		player.SetTrackEntityShouldViewAnglesFollowTrackedEntity( true )
		player.SetTrackEntityPitchLookMode( "orbit" )
		player.SetTrackEntityYawLookMode( "orbit" )
		player.SetTrackEntityMinYaw( -YAW )
		player.SetTrackEntityMaxYaw( YAW )
		player.SetTrackEntityMinPitch( -PITCH )
		player.SetTrackEntityMaxPitch( PITCH )
		player.SetTrackEntityOffsetDistance( trackDist )
		player.SetTrackEntityOffsetHeight( cameraHeightOffset + BASE_OFFSET_HEIGHT )
		//player.SetTrackEntityOffsetRight( 12.0 ) // S3: not available
		//player.SetTrackEntityBlendInTimes( 0.2,0.0,0.0 ) // S3: not available
		//player.SetTrackEntityBlendOutTime( OUTRO_EASE_TIME ) // S3: not available
		player.SetTrackEntity( player )
	}
	wait 1.25


}

void function OnPlayerPressedUseLong( entity player )
{
	thread TEMP_PlayerZiplineTryUse( player, IN_USE_LONG, true )
}


void function OnPlayerPressedSpeed( entity player )
{
	thread StatsHook_TrackSprint( player )
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


void function TryDisplayResultForReconnect( entity player )
{
	// late joiner will not get winning information
	Assert( IsValid( player ) )

	if ( GetGameState() < eGameState.WinnerDetermined )
		return

	int winningTeam = GetWinningTeam()
	SURVIVAL_SendWinningSquadDataToPlayer( player, winningTeam )

	Remote_CallFunction_Replay( player, "ServerCallback_ShowWinningSquadSequence" )
}


void function Survival_OnClientConnected( entity player )
{
	const float DEFAULT_ZOOM_LEVEL = 4.0
	player.SetMinimapZoomScale( DEFAULT_ZOOM_LEVEL, 0.0 )

	SurvivalPlayerData data
	file.playerData[EHIToEncodedEHandle( player )] <- data
	file.playerUIDToEncodedEHandleMap[player.GetPlatformUID()] <- EHIToEncodedEHandle( player )

	player.SetPlayerCanToggleObserverMode( false )

	AddButtonPressedPlayerInputCallback( player, IN_USE_LONG, OnPlayerPressedUseLong )
	AddButtonPressedPlayerInputCallback( player, IN_SPEED, OnPlayerPressedSpeed )

	int teamIndex = player.GetTeam()
	if ( !(teamIndex in file.squadPINData) )
	{
		SurvivalSquadPINData squadPINData
		file.squadPINData[teamIndex] <- squadPINData
	}
	file.squadPINData[teamIndex].memberScores[player.GetTeamMemberIndex()] <- 0
	file.squadPINData[teamIndex].numMembers++

	file.playerHealResourceIds[player] <- []
	file.playerLastDamageSlowTime[player] <- 0.0
	file.cheaterReportsThisMatch[player] <- []

	file.connectedUIDsSeenThisMatch.append( player.GetPlatformUID() )

	GameSummary_MatchStart( player )

	TransmitAirdropBadPlaceLocations( player )
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
		else
		{
			if ( GetGameState() >= eGameState.Playing )
				thread SURVIVAL_Disconnect_DropLoot( player )

			if ( !player.IsBot() )
			{
				string characterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() ) )
				TelemetryEvent( "charSel.quit." + characterName, 1 )
			}
		}

		if ( Survival_WillSquadBeEliminatedIfPlayerLeaves( player ) )
		{
			if ( player.p.hasMatchParticipationStarted )
				HandleSquadElimination( player.GetTeam() )
		}
	}


		if ( MatchBehaviorPlayer_HasStarted( player ) && !MatchBehaviorPlayer_HasEnded( player ) )
			MatchBehaviorPlayer_Ended( player, true )


	if ( player.p.hasMatchParticipationStarted && !player.p.hasMatchParticipationEnded )
		OnPlayerMatchParticipationEnded( player, true )

	UpdatePlayerCounts()
	thread Delayed_TryClearTeam( player.GetTeam() )
}

bool function Survival_IsPlayerSquadEliminated( entity player )
{
	int team = player.GetTeam()


	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_STRIKEOUT ) && Strikeout_IsPlayerRespawnDisabled(player) )
		return true



	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) && Sh_Respawn_Token_IsPlayerRespawnDisabled( player ) )
		return true


// TODO: Is this causing the post-disable lockup bug?
//%if HAS_FREERESPAWNS
//	if( FreeRespawns_Feature_Exists() && FreeRespawns_IsPlayerRespawnDisabled( player )  )
//		return true
//%endif // HAS_FREERESPAWNS


	// Mode handles elimination through its own logic. Although it uses eRespawnStyle.SPAWN_GROUP_SKYDIVE we don't want that logic determining elimination state
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
	{
		if ( ShadowArmy_IsSquadReallyEliminated( team ) )
			return true
		else
			return false
	}


	if ( GetRespawnStyle() == eRespawnStyle.SPAWN_GROUP_SKYDIVE && SpawnGroupSkydive_IsSquadEliminated( team ) )
		return true








	if ( GetRespawnStyle() == eRespawnStyle.ROLLING_RESPAWN )
		return false










		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
			return false



		if ( GameMode_IsActive( eGameModes.CONTROL ) )
			return false







	array <entity> teamArray = GetPlayerArrayOfTeam( team )












	if ( teamArray.len() == 0 )
		return true

	if ( GetPlayerArrayOfTeam_Alive( player.GetTeam() ).len() == 0 )
		return true

	return false
}


bool function Survival_WillSquadBeEliminatedIfPlayerLeaves( entity player )
{
	bool willBeEliminated = true
	if ( !ShouldEliminateSquadsInGame() )
	{
		willBeEliminated = false
	}
	else
	{
		array<entity> teamPlayers = GetPlayerArrayOfTeam_Alive( player.GetTeam() )

		foreach ( teamPlayer in teamPlayers )
		{
			if ( teamPlayer == player )
				continue

			if ( !IsAlive( teamPlayer ) )
				continue

			willBeEliminated = false
			break
		}
	}

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return false

	//this should always be checked last
	if ( GetPlayerArrayOfTeam( player.GetTeam() ).len() == 1 )
	{
		willBeEliminated = true
	}


	return willBeEliminated
}


bool function ShouldEliminateSquadsInGame()
{

		if ( GetRespawnStyle() == eRespawnStyle.ROLLING_RESPAWN )
			return false



		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
			return false



		if ( GameMode_IsActive( eGameModes.CONTROL ) )
			return false


	return true
}


bool function IsSquadReallyEliminated( int team )
{
	if ( file.Callbacks_IsSquadReallyEliminated != null )
	{
		if ( !file.Callbacks_IsSquadReallyEliminated( team ) )
			return false
	}

	return true
}


void function RespawnTeamAtRingEdge( int team )
{
	wait 2.0

	array<entity> players = GetPlayerArrayOfTeam( team )

	if ( players.len() <= 0 )
		return

	int stage             = maxint( SURVIVAL_GetCurrentDeathFieldStage( 0 ), 0 )
	DeathFieldStageData d = GetDeathFieldStage( Survival_Loot_GetDefaultRealm(), stage )

	float angleDisplacement = RandomFloat( 360.0 )
	vector center           = d.endPos
	float radius            = d.endRadius * RandomFloatRange( 0.7, 0.9 )
	vector fwd              = AnglesToForward( < 0, angleDisplacement, 0 > )
	vector endPos           = center + (fwd * d.endRadius)
	Point p                 = GetClosestAirdropPoint( endPos ) // GetClosestRespawnDropoff( endPos )

	int tries       = 0
	int MAX_TRIES   = 20
	float angleDiff = 360.0 / float( MAX_TRIES )
	if ( CheckPlayersNearOrigin( p.origin ) && tries < MAX_TRIES )
	{
		angleDisplacement = angleDisplacement + angleDiff
		radius            = d.endRadius * RandomFloatRange( 0.7, 0.9 )
		fwd               = AnglesToForward( < 0, angleDisplacement, 0 > )
		endPos            = center + (fwd * d.endRadius)
		p                 = GetClosestAirdropPoint( endPos ) // GetClosestRespawnDropoff( endPos )
		tries++
	}

	//DebugDrawCircle( center, <0, 0, 1>, d.endRadius, <255, 255, 255>, true, 10.0 )
	//DebugDrawLine( p.origin, p.origin + <0, 0, 10000>, <255, 255, 255>, true, 10.0 )

	//thread RespawnPlayersInDropshipAtPoint( players, p.origin, p.angles, false )
	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
		{
			thread AutoRespawnPlayer( player )
			player.SetOrigin( p.origin )
		}
	}
}


void function AutoRespawnPlayer( entity player )
{
	player.EndSignal( "OnDestroy" )

	player.StopObserverMode()
	ClearPlayerEliminated( player )
	ResetPlayerInventory( player )
	player.p.respawnPodLanded = true
	DecideRespawnPlayer( player, false )
	player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.NONE )
	player.SetPlayerNetTime( "respawnBannerPickedUpTime", -1 )
	player.p.respawnPod       = null
	player.p.respawnPodLanded = false

	WaitFrame()

	#if DEVELOPER
		Remote_CallFunction_Replay( player, "ServerCallback_AnnounceDevRespawn" )
	#endif

	ResetPlayerInventory( player )

	string startingItems = GetCurrentPlaylistVarString( "squad_respawn_startingItems", "mp_weapon_alternator_smg armor_pickup_lv1_evolving bullet bullet bullet bullet" )
	array<string> items  = split( startingItems, WHITESPACE_CHARACTERS )

	foreach ( i in items )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( i )
		entity loot   = SpawnGenericLoot( i, player.GetOrigin(), <0, 0, 0>, data.countPerDrop )
		Survival_PickupItem( loot, player )
	}
}


bool function CheckPlayersNearOrigin( vector origin )
{
	array<entity> players = GetPlayerArray_Alive()

	foreach ( player in players )
	{
		if ( Distance2D( player.GetOrigin(), origin ) < 6000 )
		{
			return true
		}
	}

	return false
}


void function HandleSquadElimination( int team )
{
	foreach ( func in file.Callbacks_OnSquadEliminated )
		func( team )

	if ( !IsSquadReallyEliminated( team ) )
		return

	Survival_SquadEliminationCleanup( team )
}

void function Survival_SquadEliminationCleanup( int team )
{
	RespawnBeacons_OnSquadEliminated( team )

	if ( GetCurrentPlaylistVarInt( "squad_respawn_if_before_ring", -10 ) > SURVIVAL_GetCurrentDeathFieldStage( 0 ) )
	{
		if ( file.squadRespawnChances[ team ] > 0 )
		{
			file.squadRespawnChances[ team ] -= 1

			array<entity> connectedSquadMembers = GetPlayerArrayOfTeam( team )
			foreach ( entity player in connectedSquadMembers )
			{
				player.Signal( "SquadEliminated" )
			}

			thread RespawnTeamAtRingEdge( team )
			return
		}
	}

	int remainingTeams                  = Survival_GetRemainingSquadsCount()
	array<entity> connectedSquadMembers = GetPlayerArrayOfTeam( team )
	foreach ( entity player in connectedSquadMembers )
	{
		thread InformPlayerSquadEliminated( player )

		player.Signal( "SquadEliminated" )

		file.playerData[EHIToEncodedEHandle( player )].squadRank = remainingTeams + 1


			if ( MatchBehaviorPlayer_HasStarted( player ) && !MatchBehaviorPlayer_HasEnded( player ) )
				MatchBehaviorPlayer_Ended( player, false )


		if ( player.p.hasMatchParticipationStarted && !player.p.hasMatchParticipationEnded )
			OnPlayerMatchParticipationEnded( player, false )
	}

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
		Ranked_UpdateRankedScoreProgressForAllPlayers()

	if ( !IsPVEMode() )
		StatsHook_SquadEliminated( connectedSquadMembers )

	file.finalTeamRanks[ team ] <- remainingTeams + 1
}


void function OnPlayerMatchParticipationStarted( entity player )
{
	// (dw): "Participation" includes the time when your respawn has timed out (you are dead and cannot come back) but
	// you are still in the server, spectating your squad. If you have a better word than "participation", please let me
	// know.

	Assert( !player.p.hasMatchParticipationStarted )
	Assert( !player.p.hasMatchParticipationEnded )

	printt( "OnPlayerMatchParticipationStarted " + player )

	if ( player.p.battlePassBoost < GetPlayerBattlePassBoost( player ) )
		player.p.battlePassBoost = GetPlayerBattlePassBoost( player )


	player.p.hasMatchParticipationStarted = true
}

enum eAbandonStatusForPin
{
	NONE,
	BEFORE_PLAYING,
	IS_ALIVE,
	CAN_RESPAWN,
	IN_BLEEDOUT,
	AVERAGE
}

void function OnPlayerParticipationEndedCheckAbandonStateForPIN( entity player, bool wasDisconnection )
{
	// positive play is an initiative to detect bad player behaviour
	// it is strictly for telemetry purpose, not for gameplay
	bool isAbandon = false
	int playerTeam = player.GetTeam()

	if( wasDisconnection )
	{
		PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.NONE )
		return
	}

	int gameState = GetGameState()
	if ( gameState >= eGameState.WinnerDetermined )
	{
		if ( !IsRoundBased() || GetGlobalNonRewindNetBool("roundScoreLimitComplete") )
		{
		PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.NONE )
		return
	}
	}

	if( gameState < eGameState.Playing && GetRoundsPlayed() == 0 )
	{
		PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.BEFORE_PLAYING )
		return
	}

	if( !IsTeamAlive(playerTeam) && !IsRoundBased() )
	{
		PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.NONE )
		return
	}

	if( player.IsEntAlive() )
	{
		array<entity> players = GetPlayerArrayOfTeam( playerTeam )

		if( players.len() > 1 )
		{
			if ( Bleedout_IsBleedingOut( player ) )
			{
				PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.IN_BLEEDOUT )
			}
			else
			{
				PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.IS_ALIVE )
			}
		}
		else
		{
			PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.NONE )
		}
		return
	}

	switch ( GetRespawnStyle() )
	{
		case eRespawnStyle.RESPAWN_CHAMBERS:



		int respawnStatus = GetRespawnStatus( player )
		if ( !IsValid( player.p.respawnBeacon )
				&& ( respawnStatus == eRespawnStatus.PICKUP_DESTROYED
				|| respawnStatus == eRespawnStatus.PLAYER_ELIMINATED
				|| respawnStatus == eRespawnStatus.SQUAD_ELIMINATED ) )
		{
			PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.NONE )
			return
		}
	}

	PIN_PlayerSetAbandonStatus( player, eAbandonStatusForPin.CAN_RESPAWN )
}

void function OnPlayerMatchParticipationEnded( entity player, bool wasDisconnection )
{
	Assert( player.p.hasMatchParticipationStarted )
	Assert( !player.p.hasMatchParticipationEnded )

	// positive play, abandon
	OnPlayerParticipationEndedCheckAbandonStateForPIN( player, wasDisconnection )


		if ( MatchBehaviorPlayer_HasStarted( player ) && !MatchBehaviorPlayer_HasEnded( player ) )
			MatchBehaviorPlayer_Ended( player, wasDisconnection )



		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) && GetGameState() < eGameState.WinnerDetermined && wasDisconnection == false )
			return


	player.p.hasMatchParticipationEnded = true

	//printf( "%s() - '%s'", FUNC_NAME(), string( player ) )

	bool modeIgnoresMatchResults = IsPVEMode()

		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_EXPLORE ) )
			modeIgnoresMatchResults = true









	if ( modeIgnoresMatchResults )
	{
		thread GameSummary_FinalizeData( player )
	}
	else
	{
		StorePlayerMatchStatus( player )
		AwardSurvivalXP( player )

		StatsHook_RecordPlacementStats( player )


			if( IsOrientationMatch() )
				CalculateAndUpdatePlayerGraduationStat( player )


		// this is a pretty simplistic check, but we don't really do much with achievements...
		// this could be improved if we make achievements do more. Checking mode because the call is slow...
		if ( GetCurrentPlaylistVarString( "stats_match_type", "survival" ) == "survival" )
			Achievements_OnPlayerMatchParticipationEnded( player )

		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
			PrepareGameSummaryForPointCalculation( player )


			Cups_OnPlayerMatchParticipationEnded( player )
	}
}


int function _GetSquadRank( EncodedEHandle playerEncodedEHandle )
{
	int returnRank = file.playerData[playerEncodedEHandle].squadRank

	if ( returnRank == 0 ) //Player disconnected before their squad got eliminated
	{
		if ( GetGameState() < eGameState.Playing )
			return GetCurrentPlaylistVarInt( "max_teams", 20 )
		else
			return Survival_GetRemainingSquadsCount() + 1
	}

	return returnRank

}


bool function TEMP_PotentiallyAFK( entity player )
{
	GameSummarySquadData gameSummaryData = GameSummary_GetPlayerData( player )
	if ( gameSummaryData.kills > 0 )
		return false

	if ( gameSummaryData.revivesGiven > 0 )
		return false

	if ( gameSummaryData.respawnsGiven > 0 )
		return false

	if ( gameSummaryData.damageDealt > 120 )
		return false

	if ( gameSummaryData.dealtDamageLateInTheGame )
		return false

	if ( gameSummaryData.lootedLateInTheGame )
		return false

	if ( gameSummaryData.dealtDamageLateInTheGame )
		return false

	if ( gameSummaryData.lootedLateInTheGame )
		return false

	return true
}


void function AwardSurvivalXP( entity player )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( !IsValid( player ) )
		return

	printt( "AwardSurvivalXP " + player )

	Assert( !file.playerData[EHIToEncodedEHandle( player )].xpAwarded || player.p.DEV_hasDevRespawned )
	file.playerData[EHIToEncodedEHandle( player )].xpAwarded = true

	int rank = Survival_GetCurrentRank( player )

	if ( player.p.battlePassBoost < GetPlayerBattlePassBoost( player ) )
		player.p.battlePassBoost = GetPlayerBattlePassBoost( player )

	if ( player.p.battlePassBoost < 1.0 )
		player.p.battlePassBoost = 1.0

	int secondsAlive = !IsRoundBased() ? GameSummary_GetHighestSurvivalTime( player.GetTeam() ) : GetPlayerGameDuration( player )
	int friendCount  = player.GetPartySize() - 1

	// don't give post death survival XP to randos; this can be improved with better AFK detection in the future
	GameSummarySquadData gameSummaryData = GameSummary_GetPlayerData( player )

	if ( GetCurrentPlaylistVarBool( "survival_time_anti_afk_enabled", true ) )
	{
		if ( friendCount == 0 && TEMP_PotentiallyAFK( player ) )
		{
			int mySecondsAlive = gameSummaryData.survivalTime
			int diff           = secondsAlive - mySecondsAlive
			int timeToAdd      = maxint( minint( int(RESPAWN_DNA_LIFETIME), diff ), 0 )
			secondsAlive = mySecondsAlive + timeToAdd
		}
	}

	// XP for seconds alive
	AddXP( player, eXPType.SURVIVAL_DURATION, secondsAlive )

	for ( int index = 0; index < friendCount; index++ )
	{
		AddXP( player, eXPType.BONUS_FRIEND, secondsAlive )
	}

	// XP for damage dealt
	AddXP( player, eXPType.DAMAGE_DEALT, gameSummaryData.damageDealt )

	int currentDay = Daily_GetDayForCurrentTime()

	bool shouldAwardTopFive = true
	if ( GetCurrentPlaylistVarInt( "max_teams", 20 ) <= 5 )
		shouldAwardTopFive = false

	if ( rank > 0 && rank <= 5 )
	{
		if ( rank == 1 )
			AddXP( player, eXPType.WIN_MATCH, int(player.p.battlePassBoost) )
		else if ( shouldAwardTopFive )
			AddXP( player, eXPType.TOP_FIVE, int(player.p.battlePassBoost) )

		int lastDayTopFive = player.GetPersistentVarAsInt( "lastDayTopFive" )
		if ( lastDayTopFive < currentDay && XpEventTypeData_GetAmount( eXPType.BONUS_FIRST_TOP_FIVE ) > 0 && shouldAwardTopFive )
		{
			AddXP( player, eXPType.BONUS_FIRST_TOP_FIVE )
			player.SetPersistentVar( "lastDayTopFive", currentDay )
		}
	}


	// Bonus for first game played everyday
	int lastDayPlayed = player.GetPersistentVarAsInt( "lastDayPlayed" )
	if ( lastDayPlayed < currentDay && XpEventTypeData_GetAmount( eXPType.BONUS_FIRST_GAME ) > 0 )
	{
		AddXP( player, eXPType.BONUS_FIRST_GAME )
		player.SetPersistentVar( "lastDayPlayed", currentDay )
	}

	// PIN data
	int totalSecondsPlayed = expect int( player.GetPersistentVar( "totalSecondsPlayed" ) )
	player.SetPersistentVar( "totalSecondsPlayed", totalSecondsPlayed + secondsAlive )

	// character boost = survival time incorporating remaining bonus
	// play with friends = 5% survival time per friend

	//if ( activeBattlePass != null )
	//{
	//ItemFlavor season = BattlePass_GetSeason( expect ItemFlavor(activeBattlePass) )

	//UpdateCalculatedStatCachedValue( player, ResolveStatEntry( CAREER_STATS ) )
	//}

	thread GameSummary_FinalizeData( player )
}


void function Delayed_TryEliminateTeammates( entity victim )
{
	int team = victim.GetTeam()

	foreach ( player in GetPlayerArrayOfTeam( team ) )
	{
		wait 0.1

		if ( GetGameState() <= eGameState.Playing &&
				IsAlive( player ) &&
				player != victim &&
				Bleedout_IsBleedingOut( player ) &&
						(!Bleedout_AnyOtherSquadmatesAliveAndNotBleedingOut( player ) && !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RECRUIT ) ) &&
				!Bleedout_GetSelfResEnabled( player ) &&
				!Bleedout_CanTeammatesSelfRevive( player )





				)
		{
			Bleedout_PlayerDiesFromBleedout( player )
		}
	}
}


void function Delayed_TryClearTeam( int team )
{
	WaitFrame()

	foreach ( p in GetPlayerArrayOfTeam( team ) )
	{
		if ( IsAlive( p ) &&
				Bleedout_IsBleedingOut( p ) &&
						(!Bleedout_AnyOtherSquadmatesAliveAndNotBleedingOut( p ) && !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RECRUIT ) ) &&
				!Bleedout_IsPlayerSelfReviving( p ) &&
				!Bleedout_CanTeammatesSelfRevive( p ) )
		{
			Bleedout_PlayerDiesFromBleedout( p )
		}
	}

	OnPlayerKilled_Winner()
}


bool function Survival_ShouldPlayerBeEliminated( entity player )
{
	if ( GetGameState() <= eGameState.PickLoadout )
		return false // if there is a capital ship, and the player hasn't launched from a droppod yet, and the plane is still before the midpoint, let them spawn (because they just joined)
	else if ( !HasPlayerDiedAtLeastOnce( player ) )
		return false // if there is no capital ship, always let them spawn if they haven't died yet (or if a dev adds bots mid-game)

	return !player.p.respawnPodLanded
}


bool function Survival_DidPlayerAbandon( entity player )
{
	if ( !GetCurrentPlaylistVarBool( "survival_abandonment_enable", false ) )
		return false

	if ( HasPlayerDiedAtLeastOnce( player ) )
		return false

	if ( player.GetPartySize() > 2 )
		return false

	array<entity> teamPlayers = GetPlayerArrayOfTeam( player.GetTeam() )

	if ( teamPlayers.len() < 3 ) // TODO: handle other player counts gracefully
		return false

	foreach ( entity teamPlayer in teamPlayers )
	{
		if ( HasPlayerDiedAtLeastOnce( teamPlayer ) )
			return false
	}

	if ( GameTime_PlayingTime() > GetCurrentPlaylistVarFloat( "survival_abandonment_timeout", SECONDS_PER_MINUTE * 3 ) ) // todo(bm): make playlist var
		return false

	if ( PlayerMatchState_GetFor( player ) == ePlayerMatchState.TRAINING )
		return false

	return true
}


bool function TimeLimitComplete()
{
	return false
}

// TODO: I think this health pack logic is legacy and no longer needed - it got moved to mp_weapon_consumable - should look at to remove
void function ClientCallback_Sur_UseHealthPack( entity player, int itemIndex )
{
	if ( WeaponDrivenConsumablesEnabled() )
		return

	if ( SURVIVAL_Loot_IsLootIndexValid( itemIndex ) == false )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( itemIndex )

	PlayerUseHealthKitCommand_Internal( player, data.ref )
}


void function PlayerUseHealthKitCommand_Internal( entity player, string itemName )
{
	int itemType = SURVIVAL_Loot_GetHealthPickupTypeFromRef( itemName )

	if ( !Survival_CanUseHealthPack( player, itemType ) )
		return

	int count = SURVIVAL_CountItemsInInventory( player, itemName )
	if ( count <= 0 )
		return

	string animName1p = SURVIVAL_Loot_GetHealthKitDataFromStruct( itemType ).animName1p

	thread HealthPackUse_THREAD( player, itemName, animName1p )
}


void function HealthPackUse_THREAD( entity player, string itemName, string animName1p )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "CancelHeal" )

	Signal( player, "StartHeal" )
	player.SetPlayerNetBool( "isHealing", true )

	HolsterAndDisableWeapons( player )
	player.DisableMantle()

	table<string, int> e
	e["usedHealth"] <- 0
	e["healAmount"] <- 0
	e["healthKitResourceId"] <- 0
	e["TEMP_shieldStatusHandle"] <- 0
	e["TEMP_healthStatusHandle"] <- 0
	e["lastMissingHealth"] <- -1
	e["lastMissingShields"] <- -1
	e["lastCurrentHealth"] <- -1

	SURVIVAL_RemoveFromPlayerInventory( player, itemName, 1 )
	Remote_CallFunction_NonReplay( player, "ServerCallback_RefreshInventory" )

	array<int> ids
	int forceCrouchHandle = -1
	if ( GetCurrentPlaylistVarBool( "survival_healthkits_limit_movement", true ) )
	{
		ids.append( StatusEffect_AddEndless( player, eStatusEffect.move_slow, 0.5 ) )
		ids.append( StatusEffect_AddEndless( player, eStatusEffect.disable_wall_run, 1.0 ) )
		ids.append( StatusEffect_AddEndless( player, eStatusEffect.disable_double_jump, 1.0 ) )
		forceCrouchHandle = player.PushForcedStance( FORCE_STANCE_CROUCH )
	}

	int itemType          = SURVIVAL_Loot_GetHealthPickupTypeFromRef( itemName )
	HealthPickup itemData = SURVIVAL_Loot_GetHealthKitDataFromStruct( itemType )

	if ( itemData.healAmount > 0 )
	{
		PlayBattleChatterLineToSpeakerAndTeam( player, "bc_healing" )
	}

	foreach ( callbackFunc in file.Callbacks_OnPlayerHealingStarted )
	{
		callbackFunc( player )
	}

	PlayFirstPersonAnimation( player, animName1p )

	OnThreadEnd(
		function() : ( player, e, ids, itemName, forceCrouchHandle )
		{
			if ( IsValid( player ) )
			{
				foreach ( effectId in ids )
					StatusEffect_Stop( player, effectId )
			}

			if ( IsAlive( player ) )
			{
				if ( IsPlayingFirstPersonAnimation( player ) )
					StopPlayingAnimation( player )
			}

			if ( IsValid( player ) )
			{
				DeployAndEnableWeapons( player )
				player.EnableMantle()
				if ( GetCurrentPlaylistVarBool( "survival_healthkits_limit_movement", true ) )
				{
					player.RemoveForcedStance( forceCrouchHandle )
				}
			}

			if ( IsAlive( player ) )
			{
				if ( e["usedHealth"] == 0 )
				{
					if ( SURVIVAL_AddToPlayerInventory( player, itemName, 1 ) < 1 )
						SURVIVAL_ThrowLootFromPlayer( player, itemName )
					else
						Remote_CallFunction_NonReplay( player, "ServerCallback_RefreshInventory" )
					//printl( "EntityHealthResource: Removing Resource " + file.healthKitHealResourceID + " from " + player )
					EntityHealResource_Remove( player, e["healthKitResourceId"] )
				}
				else
				{
					StatsHook_PlayerUsedResource( player, null, itemName )
					PIN_OnPlayerHealed( player, e["healAmount"], itemName, player )
				}
			}

			if ( IsValid( player ) )
			{
				if ( e["TEMP_shieldStatusHandle"] != 0 )
					StatusEffect_Stop( player, e["TEMP_shieldStatusHandle"] )

				if ( e["TEMP_healthStatusHandle"] != 0 )
					StatusEffect_Stop( player, e["TEMP_healthStatusHandle"] )

				player.SetPlayerNetBool( "isHealing", false )
				player.SetPlayerNetInt( "healingKitTypeCurrentlyBeingUsed", -1 )
			}

			foreach ( callbackFunc in file.Callbacks_OnPlayerHealingEnded )
				callbackFunc( player )
		}
	)

	float delayScale
	if ( PlayerHasPassive( player, ePassives.PAS_FAST_HEAL ) && (itemData.healAmount > 0) )
		delayScale = 0.5
	else
		delayScale = 1.0
	float delayTime = (itemData.interactionTime * delayScale)

	float healDuration  = max( itemData.healTime, 0.25 )
	float healAmount    = SURVIVAL_CalculateTotalHealFromItem( player, itemType )
	float healPerSecond = healAmount / healDuration

	// todo(dw): healing should use network variables... if I get time I'll fix it
	Remote_CallFunction_Replay( player, "ServerToClient_OnStartedUsingHealthPack", itemType )

	// added this so that I can know what type of healing is used on the client without a remote call to each individual player. Used in unitframes.rui
	player.SetPlayerNetInt( "healingKitTypeCurrentlyBeingUsed", itemType )

	UpdateHealthPackUse( player, itemData, e )
	float endTime = Time() + delayTime
	while ( Time() < endTime )
	{
		UpdateHealthPackUse( player, itemData, e )
		WaitFrame()
	}

	e["usedHealth"] = 1
	UpdateHealthPackUse( player, itemData, e )

	// Not sure if HealthPackUse_THREAD is used, but UltimatePackUse (in this file) is not. Removing. -DS
	//if ( itemData.ultimateAmount > 0 )
	//	UltimatePackUse( player, itemData )

	e["usedHealth"] = 1
	e["healAmount"] = int( healAmount )

	//Create tracking point of intrest for this heal.
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_HEAL, player, player.GetOrigin(), player.GetTeam(), player )
}


void function UpdateHealthPackUse( entity player, HealthPickup itemData, table< string, int > e )
{
	int currentHealth   = player.GetHealth()
	int maxHealth   = player.GetMaxHealth()
	int currentShields  = player.GetShieldHealth()
	int shieldHealthMax = player.GetShieldHealthMax()

	int resourceHealthRemaining = EntityHealResource_GetRemainingTotal( player )
	int virtualHealth           = minint( currentHealth + resourceHealthRemaining, maxHealth )
	int missingHealth           = maxHealth - virtualHealth
	int missingShields          = shieldHealthMax - currentShields

	bool shouldUpdateHealth  = missingHealth != e["lastMissingHealth"]
	bool shouldUpdateShields = missingShields != e["lastMissingShields"]

	if ( itemData.healAmount > 0 )
	{
		int healthToApply = minint( int( itemData.healAmount ), missingHealth )
		Assert( virtualHealth + healthToApply <= 100, "Bad math: " + virtualHealth + " + " + healthToApply + " > 100 " )

		int remainingHealth = int( itemData.healAmount - healthToApply )

		int shieldsToApply = 0
		if ( itemData.healCap > 100 && remainingHealth > 0 )
		{
			shieldsToApply = minint( remainingHealth, missingShields )
		}

		Assert( currentShields + shieldsToApply <= shieldHealthMax, "Bad math: " + currentShields + " + " + shieldsToApply + " > 100 " )

		if ( healthToApply != 0 || itemData.healTime > 0 ) // healTime items can exceed the cap
		{
			if ( e["usedHealth"] > 0 )
			{
				StatusEffect_StopAllOfType( player, eStatusEffect.target_health )
				if ( itemData.healTime == 0 )
				{
					player.SetHealth( minint( currentHealth + healthToApply, player.GetMaxHealth() ) )
				}
				else
				{
					float healTime   = itemData.healTime
					float healAmount = itemData.healAmount
					float HPS        = healAmount / healTime
					if ( resourceHealthRemaining > 0 )
					{
						foreach ( resourceId in file.playerHealResourceIds[player] )
						{
							EntityHealResource_Remove( player, resourceId )
						}

						healAmount += float( resourceHealthRemaining )
						healTime += resourceHealthRemaining / healTime
					}

					e["healthKitResourceId"] = EntityHealResource_Add( player, healTime, (healAmount / healTime), 0.0, itemData.lootData.ref, player )
					file.playerHealResourceIds[player].append( e["healthKitResourceId"] )
				}
			}
			else if ( shouldUpdateHealth )
			{
				StatusEffect_StopAllOfType( player, eStatusEffect.target_health )
				e["TEMP_healthStatusHandle"] = StatusEffect_AddEndless( player, eStatusEffect.target_health, ( healthToApply + resourceHealthRemaining) / float( maxHealth ) )
			}
		}

		if ( shieldsToApply != 0 )
		{
			if ( e["usedHealth"] > 0 )
			{
				StatusEffect_StopAllOfType( player, eStatusEffect.target_shields )
				player.SetShieldHealth( minint( currentShields + shieldsToApply, player.GetShieldHealthMax() ) )
			}
			else if ( shouldUpdateShields )
			{
				StatusEffect_StopAllOfType( player, eStatusEffect.target_shields )
				e["TEMP_shieldStatusHandle"] = StatusEffect_AddEndless( player, eStatusEffect.target_shields, shieldsToApply / float( shieldHealthMax ) )
			}
		}
	}

	if ( itemData.shieldAmount > 0 )
	{
		if ( e["usedHealth"] > 0 )
		{
			player.SetShieldHealth( minint( int( player.GetShieldHealth() + itemData.shieldAmount ), shieldHealthMax ) )
		}
		else if ( shouldUpdateShields )
		{
			StatusEffect_StopAllOfType( player, eStatusEffect.target_shields )
			e["TEMP_shieldStatusHandle"] = StatusEffect_AddEndless( player, eStatusEffect.target_shields, minint( player.GetShieldHealth() + int( itemData.shieldAmount ), shieldHealthMax ) / float( shieldHealthMax ) )
		}
	}

	e["lastMissingHealth"]  = missingHealth
	e["lastMissingShields"] = missingShields
	e["lastCurrentHealth"]  = currentHealth
}


int function EntityHealResource_GetRemainingTotal( entity player )
{
	array<int> activeHealResourceIds
	int totalRemaining

	foreach ( healResourceId in file.playerHealResourceIds[player] )
	{
		int remaining = EntityHealResource_GetRemainingHeals( player, healResourceId )
		if ( remaining <= 0 )
			continue

		activeHealResourceIds.append( healResourceId )
		totalRemaining = remaining
	}

	return totalRemaining
}


void function Survival_SetForceRandomOnSkippedCharacterSelecttion( bool shouldBeRandom )
{
	file.forceRandomOnNoSelect = shouldBeRandom
}


void function Survival_SetFreezeControlsOnPrematch( bool shouldFreeze )
{
	file.shouldFreezeControlsOnPrematch = shouldFreeze
}


void function Survival_AddCallback_OnGameAutoSelectedCharacter( void functionref(entity, ItemFlavor) callbackFunc )
{
	Assert( !file.Callbacks_OnGameAutoSelectedCharacterCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnGameAutoSelectedCharacter" )
	file.Callbacks_OnGameAutoSelectedCharacterCallbacks.append( callbackFunc )
}


void function Survival_AddCallback_OnPlayerLockedInCharacter( void functionref(entity, ItemFlavor) callbackFunc )
{
	Assert( !file.Callbacks_OnPlayerLockedInCharacterCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnPlayerLockedInCharacter" )
	file.Callbacks_OnPlayerLockedInCharacterCallbacks.append( callbackFunc )
}


void function Survival_AddCallback_OnPlayerHealingStarted( void functionref(entity) callbackFunc )
{
	Assert( !file.Callbacks_OnPlayerHealingStarted.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnPlayerHealingStarted" )
	file.Callbacks_OnPlayerHealingStarted.append( callbackFunc )
}


void function Survival_AddCallback_OnPlayerHealingEnded( void functionref(entity) callbackFunc )
{
	Assert( !file.Callbacks_OnPlayerHealingEnded.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnPlayerHealingEnded" )
	file.Callbacks_OnPlayerHealingEnded.append( callbackFunc )
}


void function Survival_AddCallback_OnSquadEliminated( void functionref(int) callbackFunc )
{
	Assert( !file.Callbacks_OnSquadEliminated.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnSquadEliminated" )
	file.Callbacks_OnSquadEliminated.append( callbackFunc )
}


void function Survival_AddCallback_IsSquadReallyEliminated( bool functionref(int) callbackFunc )
{
	file.Callbacks_IsSquadReallyEliminated = callbackFunc
}


void function Survival_AddCallback_OnPlayerLandedFromDropshipFreefall( void functionref(entity) callbackFunc )
{
	Assert( !file.Callbacks_OnPlayerLandedFromDropshipFreefall.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with Survival_AddCallback_OnPlayerLandedFromDropshipFreefall" )
	file.Callbacks_OnPlayerLandedFromDropshipFreefall.append( callbackFunc )
}


void function ClientCallback_Sur_EquipOrdnance( entity player, int index )
{
	if ( !IsAlive( player ) )
		return

	if ( !SURVIVAL_Loot_IsLootIndexValid( index ) )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( index )

	if ( data.lootType != eLootType.ORDNANCE )
		return

	SURVIVAL_EquipOrdnanceFromInventory( player, data.ref )
}

void function ClientCallback_Sur_EquipGadget( entity player, int index )
{
	if ( !IsAlive( player ) )
		return

	if ( !SURVIVAL_Loot_IsLootIndexValid( index ) )
		return

	if ( HoverVehicle_PlayerIsDriving( player ) )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( index )


		if ( data.ref.find( COPYCAT_NAME ) == 0 )
		{
			player.TrySelectOffhand( OFFHAND_GENERIC )
			return
		}


	if ( data.lootType != eLootType.GADGET )
		return

	SURVIVAL_EquipGadgetFromEquipment( player, data.ref )
}

void function ClientCallback_Sur_EquipAttachment( entity player, int attachmentLootIndex, int weaponSlot )
{
	Remote_CallFunction_UI( player, "SurvivalMenu_AckAction" )

	if ( SURVIVAL_Loot_IsLootIndexValid( attachmentLootIndex ) == false )
		return

	if ( !IsAlive( player ) )
		return

	if ( !Survival_PlayerCanDrop( player ) )
		return

	player.Signal( "ThrowItem" )

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( attachmentLootIndex )
	if ( weaponSlot == -1 )
		thread SURVIVAL_EquipAttachmentFromInventory( player, data.ref )
	else
		thread SURVIVAL_EquipAttachmentFromInventoryToSlot( player, data.ref, weaponSlot )
}


void function ClientCallback_Sur_TransferAttachment( entity player, int itemIndex, int slotFrom )
{
	Remote_CallFunction_UI( player, "SurvivalMenu_AckAction" )

	if ( SURVIVAL_Loot_IsLootIndexValid( itemIndex ) == false )
		return

	if ( !IsAlive( player ) )
		return

	if ( !Survival_PlayerCanDrop( player ) )
		return

	player.Signal( "ThrowItem" )

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( itemIndex )
	thread SURVIVAL_TransferAttachmentToOtherWeapon( player, data.ref, slotFrom )
	return
}


void function ClientCallback_Sur_UnequipAttachment( entity player, int itemIndex, int slotFrom, bool toGround )
{
	Remote_CallFunction_UI( player, "SurvivalMenu_AckAction" )

	if ( SURVIVAL_Loot_IsLootIndexValid( itemIndex ) == false )
		return

	if ( !IsAlive( player ) )
		return

	if ( !Survival_PlayerCanDrop( player ) )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( itemIndex )

	player.Signal( "ThrowItem" )

	thread SURVIVAL_RemoveAttachmentFromWeapon( player, data.ref, slotFrom, toGround )
}

#if DEVELOPER
void function ClientCommand_Sur_SetActiveWeapon( entity player, array<string> args )
{
	if ( !IsAlive( player ) )
		return

	if ( args.len() != 1 )
		return

	if ( player.IsTitan() )
		return

	string activeWeaponClassname = args[0]

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	//if ( activeWeapon != null && activeWeapon.GetWeaponClassName() == activeWeaponClassname )
	//	return false
	//
	player.Signal( "ThrowItem" )

	array<int> weaponIndexes = [ WEAPON_INVENTORY_SLOT_PRIMARY_0, WEAPON_INVENTORY_SLOT_PRIMARY_1 ]
	for ( int index = 0; index < weaponIndexes.len(); index++ )
	{
		entity weapon = player.GetNormalWeapon( weaponIndexes[index] )
		if ( !IsValid( weapon ) )
			continue

		if ( weapon.GetWeaponClassName() != activeWeaponClassname )
			continue

		if ( weapon == activeWeapon )
			return

		player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, weaponIndexes[index] )
	}
}
#endif

void function ClientCallback_Sur_CancelHeal( entity player )
{
	if ( IsAlive( player ) )
	{
		player.Signal( "CancelHeal" )
	}
}


void function ClientCallback_Sur_DropBackpackItem_Box( entity player, int itemIndex, int numToThrow, int boxEEH )
{
	entity deathbox = GetEntityFromEncodedEHandle( boxEEH )
	DropBackpackItem_Internal( player, itemIndex, numToThrow, deathbox )
}

void function ClientCallback_Sur_DropBackpackItem( entity player, int itemIndex, int numToThrow)
{
	DropBackpackItem_Internal( player, itemIndex, numToThrow, null )
}


void function DropBackpackItem_Internal( entity player, int itemIndex, int numToThrow, entity box )
{
	Remote_CallFunction_UI( player, "SurvivalMenu_AckAction" )

	if ( SURVIVAL_Loot_IsLootIndexValid( itemIndex ) == false )
		return

	LootData data = SURVIVAL_Loot_GetLootDataByIndex( itemIndex )

	if ( numToThrow <= 0 )
		return

	if ( !Survival_PlayerCanDrop( player ) )
		return

	entity deathBox = null
	if ( IsValid( box ) && box.GetTargetName() == DEATH_BOX_TARGETNAME )
		deathBox = box

	SURVIVAL_DropBackpackItem( player, data.ref, numToThrow, deathBox )
}


void function ClientCallback_Sur_DropEquipment( entity player, int equipmentSlotType )
{
	Remote_CallFunction_UI( player, "SurvivalMenu_AckAction" )

	if ( EquipmentSlot_IsValidEquipmentSlotType( equipmentSlotType ) == false )
		return

	if ( !Survival_PlayerCanDrop( player ) )
		return

	EquipmentSlot e = Survival_GetEquipmentSlotDataByType( equipmentSlotType )

	SURVIVAL_DropPlayerEquipment( player, e.ref )
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


bool function Survival_ShouldBypassCharacterDamageScale( entity damagedEnt, var damageInfo )
{
	bool shouldByPassFortify = false


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
			shouldByPassFortify = true



		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
			shouldByPassFortify = true


	if ( shouldByPassFortify )
	{

			//legends lose fortified when change into zombies
			if ( IsPlayerShadowZombie( damagedEnt ) )
				return true

			//zombies bypass fortified with their melee attacks
			entity attacker = DamageInfo_GetAttacker( damageInfo )
			if ( IsValid( attacker ) && attacker.IsPlayer() && IsPlayerShadowZombie( attacker ) )
				return true

	}


	//Ignore Fortify with Headshot Damage
	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_HEADSHOT ) && damagedEnt.IsPlayer())
		return true

	return false
}


void function OnPlayerTookDamage( entity damagedEnt, var damageInfo )
{
	if ( damagedEnt.IsPlayer() && !damagedEnt.IsTitan() )
	{
		if ( (DamageInfo_GetCustomDamageType( damageInfo ) & (DF_DOOMED_HEALTH_LOSS)) == 0 )
		{
			ItemFlavor victimCharacter = LoadoutSlot_GetItemFlavor( ToEHI( damagedEnt ), Loadout_Character() )

			if ( Survival_DamageShouldSlowDownPlayer( damagedEnt, damageInfo ) )
			{
				//file.playerLastDamageSlowTime[damagedEnt] = Time()
				Survival_GetPlayerLastDamageSlowTime()[ damagedEnt ] = Time()
				StatusEffect_AddTimed_PredictionFriendly( damagedEnt, eStatusEffect.move_slow, CharacterClass_GetDamageSlowAmount( victimCharacter ), CharacterClass_GetDamageSlowDuration( victimCharacter ), CharacterClass_GetDamageSlowEaseOut( victimCharacter ) )
			}

			float damageScale = CharacterClass_GetDamageScale( victimCharacter )








			if ( Survival_ShouldBypassCharacterDamageScale( damagedEnt, damageInfo ) )
				damageScale = 1.0

			if ( !IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_BULLET ) && GetCurrentPlaylistVarBool( "damage_scale_filtered", false ) )
				damageScale = 1.0

			if ( damageScale != 1 )
				DamageInfo_Print( damageInfo, "scl " + damageScale )

			DamageInfo_ScaleDamage( damageInfo, damageScale )

			entity attacker = DamageInfo_GetAttacker( damageInfo )
			if ( IsValid( attacker ) && attacker.GetTeam() != damagedEnt.GetTeam() )
			{
				int reason = attacker.IsPlayer() ? eDeadPeriodEndReason.TOOK_DAMAGE_FROM_PLAYER : ( attacker.IsNPC() ? eDeadPeriodEndReason.TOOK_DAMAGE_FROM_NPC : eDeadPeriodEndReason.UNKNOWN_REASON )
				DeadPeriodChecker_PlayerDeadPeriodEnd( damagedEnt, reason )
			}












			string equippedArmor = Inventory_GetPlayerEquipment( damagedEnt, "armor" )
			LootData data

			if ( SURVIVAL_Loot_IsRefValid( equippedArmor ) )
				data = SURVIVAL_Loot_GetLootDataByRef( equippedArmor )

			switch ( data.tier )
			{
				case 1:
					DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_ARMOR1 )
					break

				case 2:
					DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_ARMOR2 )
					break

				case 3:
					DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_ARMOR3 )
					break

				case 4:
					DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_ARMOR4 )
					break

				case 5:
					DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_ARMOR5 )
					break
			}

			DamageInfo_ScaleDamage( damageInfo, file.bodyshotDamageScale )
			DamageInfo_Print( damageInfo, "scaled by" + file.bodyshotDamageScale + " from playlist var" )
		}
	}
}

//note that the damage has been scaled by the base crit scale already by the time we reach this callback
void function OnPlayerTookHeadshot( entity damagedEnt, var damageInfo )
{
	if ( !damagedEnt.IsPlayer() || damagedEnt.IsTitan() )
		return

	if ( (DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS) != 0 )
		return

	if ( !IsValidHeadShot( damageInfo, damagedEnt ) )
		return

	//Crate Wingman - SKULLPIERCER ELITE - Does flat set damage on headshots. Ignores helmets. Also exists in OnTrainingDummyTookHeadshot
	entity weapon = DamageInfo_GetWeapon( damageInfo )

	if ( IsValid( weapon ) )
	{
		string weaponName = weapon.GetWeaponClassName()

		if ( weapon.HasMod( "hopup_headshot_dmg_elite" ) || weapon.HasMod( "hopup_headshot_dmg_elite_ghorse" ) )
		{
			float damage = DamageInfo_GetDamage( damageInfo )
			damage = GetWeaponInfoFileKeyField_GlobalFloat ( weaponName, "skullpiercer_elite_damage" )
			DamageInfo_SetDamage( damageInfo, damage )
			DamageInfo_Print( damageInfo, "damage " + damage + " ignore helmet from Skullpiercer Elite." )

			//Rampart Walls Amped damage modifier
			entity inflictor = DamageInfo_GetInflictor( damageInfo )

			if ( !IsValid( inflictor ) )
				return

			if ( inflictor.HasWeaponMod( "amped_damage" ) || inflictor.HasWeaponMod( "amped_damage_alt" ) )
			{
				DamageInfo_ScaleDamage( damageInfo, 1.2 )
			}
			return
		}
	}
	//

	string equippedHelmet = Inventory_GetPlayerEquipment( damagedEnt, "helmet" )
	LootData data

	if ( SURVIVAL_Loot_IsRefValid( equippedHelmet ) )
		data = SURVIVAL_Loot_GetLootDataByRef( equippedHelmet )

	float headshotScalar = -1

	switch ( data.tier )
	{
		case 1:
			DamageInfo_AddCustomDamageType( damageInfo, DF_HEADSHOT )
			headshotScalar = GetCurrentPlaylistVarFloat( "helmet_lv1", 0.8 )
			break

		case 2:
			DamageInfo_AddCustomDamageType( damageInfo, DF_HEADSHOT )
			headshotScalar = GetCurrentPlaylistVarFloat( "helmet_lv2", 0.5 ) //0.50
			break

		case 3:
			DamageInfo_AddCustomDamageType( damageInfo, DF_HEADSHOT )
			headshotScalar = GetCurrentPlaylistVarFloat( "helmet_lv3", 0.35 ) //0.35
			break

		case 4:
			DamageInfo_AddCustomDamageType( damageInfo, DF_HEADSHOT )
			headshotScalar = GetCurrentPlaylistVarFloat( "helmet_lv4", 0.35 ) //0.35
			break
	}

	if ( headshotScalar > 0 )
	{
		float damage    = DamageInfo_GetDamage( damageInfo )
		//we might want to look at using DamageInfo_GetDamageCriticalHitScale in the future? For now, I'm using what HandleLocationBasedDamage uses
		float critScale = GetHeadshotDamageMultiplierFromDamageInfo( damageInfo )

		//damage hasn't been rounded yet, so we can divide to get the accurate non-crit damage
		float nonCritDamage = damage / critScale
		float critDamage    = damage - nonCritDamage
		damage = nonCritDamage + headshotScalar * critDamage
		DamageInfo_SetDamage( damageInfo, damage )
		DamageInfo_Print( damageInfo, "damage " + damage + " from hs shld scalar " + headshotScalar )
	}

	DamageInfo_ScaleDamage( damageInfo, file.headshotDamageScale )
	DamageInfo_Print( damageInfo, "scaled by" + file.headshotDamageScale + " from playlist var" )
}


bool function SURVIVAL_IsCharacterClassLocked( entity player )
{
	if ( IsLobby() )
		return false

	if ( PlayerMatchState_GetFor( player ) == ePlayerMatchState.TRAINING )
		return false

	if ( GetCurrentPlaylistVarBool( "sur_dev_unrestricted_character_changes", false ) )
		return false

	// Special cases for modes with character reselect.
	if ( IsCharacterReselectEnabled() )
	{
		// Firingrange is special, we should always allow character swap.
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		{
			return false
		}
		else
		{
			// So in general for all character reselect gamemodes we currently enforce being dead to change your character.
			// But sometimes you are still pondering in the character select screen while alive again, let's check spawn time and be gracious with those players.
			float lastRespawnTimeDelta = Time() - GetPlayerLastRespawnTime( player )
			if ( !IsAlive( player ) || lastRespawnTimeDelta < GetCurrentPlaylistVarFloat( "character_reselect_grace_time_sec", 5.0 ) )
			{
				return false
			}
		}
	}

	return GetGameState() > eGameState.PickLoadout
}


SurvivalPlayerData function Survival_GetPlayerData( EncodedEHandle playerEncodedEHandle )
{
	return file.playerData[ playerEncodedEHandle ]
}


void function Sur_OnPlayerStartBleedout( entity player, entity attacker, var damageInfo )
{
	player.TurnLowHealthEffectsOn()
	Remote_CallFunction_NonReplay( player, "ServerCallback_ClearHints" )

	GivePlayerSettingsMods( player, [ "disable_slide" ] )
	Survival_SetFriendlyHighlight( player )
	Highlight_ClearEnemyHighlight( player )

	float endTime = Time() + Bleedout_GetBleedoutTime( player )

	StopBattleChatterLinesForSpeakerAndTeam( player )
	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_imDown" )

	// Don't play a congrats-on-kill line if the player killed themselves
	if ( attacker.IsPlayer() && attacker != player )
	{
		attacker.p.recentPlayerKnockedEnemyTimes.append( Time() )
		thread Survival_ProcessPlayerKnockedEnemy( attacker )
	}
}


void function Sur_OnPlayerStopBleedout( entity player )
{
	player.TurnLowHealthEffectsOff()

	//on revive, refresh all assist markers on players that downed
	entity bleedoutAttacker = GetLastBleedoutAttackerFromDamageHistory ( player )
	if ( bleedoutAttacker != null )
	{
		if ( IsValid ( bleedoutAttacker ) && bleedoutAttacker.IsPlayer() && !bleedoutAttacker.p.hasMatchParticipationEnded && IsEnemyTeam( bleedoutAttacker.GetTeam(), player.GetTeam() ) )
		{
			array < entity > assister
			foreach ( entity assistCreditPlayer, float assistTime in player.p.playerToTimeThatAssistCreditLastsTable )
			{
				if ( !IsValid( assistCreditPlayer ) )
					continue

				if ( assistCreditPlayer.p.hasMatchParticipationEnded )
					continue

				if( !IsEnemyTeam( assistCreditPlayer.GetTeam(), player.GetTeam() ) )
					continue

				assister.append( assistCreditPlayer )
			}

			AddAssistingPlayerToVictim ( bleedoutAttacker, player )

			foreach ( entity attacker in assister )
			{
				AddAssistingPlayerToVictim ( attacker, player )
			}
		}
	}

	TakePlayerSettingsMods( player, [ "disable_slide" ] )

	Survival_SetFriendlyHighlight( player )

	// DEFENSIVE: clear any slow effect that might have gotten stuck during bleedout
	StatusEffect_StopAllOfType( player, eStatusEffect.move_slow )
}


void function Sur_OnFirstAidInterrupted( entity player, entity reviver )
{
	if ( !ShouldDoBleedout( player ) )
	{
		Bleedout_PlayerDiesFromBleedout( player )
	}
}


void function Sur_OnPlayerGotFirstAid( entity player, entity reviver )
{
	if ( reviver != player )
	{
		AddGameSummaryReviveGiven( reviver, 1 )

		if ( IsAlive( reviver ) && reviver.IsPlayer() )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_PromptSayThanksRevive", reviver )
		}
	}
}


void function SURVIVAL_SetAirburstHeight( float height )
{
	file.airburstHeight = height
}


float function SURVIVAL_GetAirburstHeight()
{
	return file.airburstHeight
}


void function SURVIVAL_SetPlane( Survival_Plane plane )
{
	file.plane.centerEnt = plane.centerEnt
	file.plane.baseEnt = plane.baseEnt
	file.plane.mover = plane.mover
}


void function SURVIVAL_SetPlaneHeight( float height )
{
	file.planeHeight = height
}


float function SURVIVAL_GetPlaneHeight()
{
	return file.planeHeight
}


void function SURVIVAL_SetMapCenter( vector c )
{
	file.mapCenter = c
}


vector function SURVIVAL_GetMapCenter()
{
	return file.mapCenter
}










void function SURVIVAL_SetFlightAngleAdjustment( float angle )
{
	file.planeFlightAngleAdjustment = angle
}


float function SURVIVAL_GetFlightAngleAdjustment()
{
	return file.planeFlightAngleAdjustment
}


void function SURVIVAL_SetPlaneJumpStartPos( vector startPos )
{
	file.planeJumpStartPos = startPos
}


vector function SURVIVAL_GetPlaneJumpStartPos()
{
	return file.planeJumpStartPos
}


void function SURVIVAL_SetPlaneJumpEndPos( vector endPos )
{
	file.planeJumpEndPos = endPos
}


vector function SURVIVAL_GetPlaneJumpEndPos()
{
	return file.planeJumpEndPos
}

//
float function GetTeleportMaxHeightForMap()
{
	switch( GetMapName() )
	{
		case "mp_rr_canyonlands_staging":
			return -21000.0

		case "mp_rr_olympus":
			return 15000.0

		case "mp_rr_box":
			return 3000.0
	}

	return 25000.0
}


vector function GetTeleportPositionForDesired( entity player, vector mapPos2D )
{
	float maxHeight  = GetTeleportMaxHeightForMap()
	vector newPosRaw = <mapPos2D.x, mapPos2D.y, maxHeight>

	const vector TRACEDELTA = <0, 0, -30000>
	TraceResults trace = TraceHull( newPosRaw, (newPosRaw + TRACEDELTA), player.GetPlayerMins(), player.GetPlayerMaxs(), null, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

	if ( trace.startSolid || (trace.fraction == 1.0) )
		return newPosRaw
	return (newPosRaw + (TRACEDELTA * trace.fraction))
}


void function ClientCallback_Sur_RequestSquadDataPersistence( entity player )
{
	if ( GetGameState() < eGameState.WinnerDetermined )
		return

	if ( !IsValid( player ) )
		return

	int winningTeam = GetWinningTeam()

	SURVIVAL_SendWinningSquadDataToPlayer( player, winningTeam )

	if ( IsSquadDataPersistenceEmpty( player ) )
	{
		thread GameSummary_FinalizeData( player )
	}
}


void function ClientCommand_GoToMapPoint( entity player, array<string> args )
{
	if ( args.len() < 2 )
		return

	bool cheatsEnabled = GetConVarBool( "sv_cheats" )
	if ( !cheatsEnabled )
	{
		BigWarningLog( "GoToMapPoint - disabled (server cheats are off): " + player )
		return
	}

	entity parentEnt = player.GetParent()

		if ( IsValid( parentEnt ) && !EntIsHoverVehicle( parentEnt ) )
		{
			BigWarningLog( "GoToMapPoint - Ignoring for parented player: " + player )
			return
		}

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) && !Survival_HasPlayerJumpedOutOfPlane( player ) )
	{
		BigWarningLog( "GoToMapPoint - Ignoring for player still in plane: " + player )
		return
	}

	float argX = float( args[0] )
	float argY = float( args[1] )
	Dev_MapTeleport( player, <argX, argY, 0.0> )
}


void function Dev_MapTeleport( entity player, vector mapPos2D )
{
	vector newPos = GetTeleportPositionForDesired( player, mapPos2D )
	printf( "%s() - Teleporting '%s' to: %s", FUNC_NAME(), string( player ), string( newPos ) )

	entity teleportEnt = player
	entity parentEnt   = player.GetParent()
	if ( IsValid( parentEnt ) )
	{

		if ( EntIsHoverVehicle( parentEnt ) )
		{
			teleportEnt = parentEnt
		}
		else

		{
			Warning( "%s() - Not teleporting '%s', because they are parentEnted to '%s'.", FUNC_NAME(), string( player ), string( parentEnt ) )
			return
		}
	}

	teleportEnt.SetAbsOrigin( newPos )
	player.SnapEyeAngles( <0.0, player.EyeAngles().y, 0.0> )
	ScreenFadeFromBlack( player, 1.0, 0.2 )
}


bool function PlayerIsAllowedToTPCommand( entity player )
{
	if ( IsValid( player.GetParent() ) )
		return false
	if ( !IsAlive( player ) )
		return false

	return player.p.isAllowedToUseTP
}

void functionref( entity player, vector mapPos2D ) s_tpOverrideFunc = null
void function SetPlayerTeleportFunctionOverride( void functionref( entity player, vector mapPos2D ) func )
{
	s_tpOverrideFunc = func
}


void function ClientCallback_TPPromptGoToMapPoint( entity player, float argX, float argY )
{
	if ( !PlayerIsAllowedToTPCommand( player ) )
	{
		Warning( "%s() - Ignoring for player not allowed to teleport: '%s'", FUNC_NAME(), string( player ) )
		return
	}

	if ( s_tpOverrideFunc != null )
		s_tpOverrideFunc( player, <argX, argY, 0.0> )
	else
		MapTeleport( player, <argX, argY, 0.0> )
}


void function PlayMapTeleportFX( vector pos, vector forwardVec, bool comingIn, entity player )
{
	//
	EmitSoundAtPosition( TEAM_ANY, (pos + <0, 0, 20>), "dropship_warpin", player )
	EmitSoundAtPosition( TEAM_ANY, (pos + <0, 0, 100>), "dropship_mp_epilogue_warpout", player )
	vector fxPos = (pos - <0, 0, 64> + (20.0 * forwardVec))
	entity fxEnt = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_veh_hovertank_afterburn" ), fxPos, <-90, 0, 0> )
	thread function() : (fxEnt)
	{
		wait 1.0
		if ( IsValid( fxEnt ) )
			fxEnt.Destroy()
	}()
}


void function MapTeleport( entity player, vector mapPos2D )
{
	vector oldPos = player.GetOrigin()
	PlayMapTeleportFX( oldPos, <0, 0, 0>, false, player)

	vector newPos = GetTeleportPositionForDesired( player, mapPos2D )
	printf( "%s() - Teleporting '%s' to: %s", FUNC_NAME(), string( player ), string( newPos ) )
	player.SetAbsOrigin( newPos + <0, 0, 100> )

	vector newAngles = VectorToAngles( Normalize( oldPos - newPos ) )
	player.SnapEyeAngles( <10.0, newAngles.y, 0.0> )
	ScreenFadeFromBlack( player, 1.0, 0.2 )
	//
	PlayMapTeleportFX( newPos, FlattenNormalizeVec( player.GetViewForward() ), true, player )
}

float function Survival_GetMapFloorZ( vector position )
{
	//Point point = GetClosestAirdropPoint( position )
	//return point.origin.z
	return file.mapFloorZ
}


void function Survival_SetMapFloorZ( float z )
{
	//Point point = GetClosestAirdropPoint( position )
	//return point.origin.z
	file.mapFloorZ = z
}

void function StorePlayerMatchStatus( entity player )
{
	int matchResultsCurrMatchIndex = modint( player.GetPersistentVarAsInt( "matchResults_nextIndex" ), PersistenceGetArrayCount( "matchResults" ) ) // need to mod in case the size of the array changes

	int matchResultsNextMatchIndex = modint( matchResultsCurrMatchIndex + 1, PersistenceGetArrayCount( "matchResults" ) )
	player.SetPersistentVar( "matchResults_nextIndex", matchResultsNextMatchIndex )

	int kills  = player.GetPlayerNetInt( "kills" )
	int rank   = Survival_GetCurrentRank( player )
	int rankOf = (GetGameState() < eGameState.Playing ? 0 : file.numPlayerAtStart)

	//player.SetPersistentVar( "matchResults[" + persistentArrayIndex + "].startUnixTime", file.gameStartUnixTime )
	player.SetPersistentVar( format( "matchResults[%d].placement", matchResultsCurrMatchIndex ), rank - 1 ) // lower is better
	player.SetPersistentVar( format( "matchResults[%d].placementOf", matchResultsCurrMatchIndex ), rankOf )
	player.SetPersistentVar( format( "matchResults[%d].playersKilled", matchResultsCurrMatchIndex ), kills )
	player.SetPersistentVar( format( "matchResults[%d].damageDealt", matchResultsCurrMatchIndex ), 0 )

	if ( MATCH_STORAGE_DEBUG )
	{
		printt( "-----------------------------------------------" )
		printt( "Player Match Storage Information for", player )
		printt( "-----------------------------------------------" )
		for ( int matchOffset = 0; matchOffset < PersistenceGetArrayCount( "matchResults" ); matchOffset++ )
		{
			int matchIndex = modint( matchResultsCurrMatchIndex - matchOffset, PersistenceGetArrayCount( "matchResults" ) )
			if ( matchOffset == 0 )
				printt( "-= Current match =-" )
			else
				printt( format( "-= %d match ago =-", matchOffset ) )
			printt( "  Placement: " + player.GetPersistentVar( format( "matchResults[%d].placement", matchIndex ) ) )
			printt( "  Kills: " + player.GetPersistentVar( format( "matchResults[%d].playersKilled", matchIndex ) ) )
			printt( "  Damage Dealt: " + player.GetPersistentVar( format( "matchResults[%d].damageDealt", matchIndex ) ) )
		}
	}
}


void function Survival_ProcessPlayerKnockedEnemy( entity attacker )
{
	const float KNOCKED_ENEMY_DIALOGUE_DELAY = 1.5
	array<float> recentKnocks = attacker.p.recentPlayerKnockedEnemyTimes
	float currentTime         = Time()

	if ( !IsValid( attacker ) || recentKnocks.len() == 0 )
		return

	thread TrackKillStringTimer( attacker )

	if ( currentTime - attacker.p.timeLastCalledEnemyDown < KNOCKED_ENEMY_DIALOGUE_DELAY )
		return

	attacker.p.timeLastCalledEnemyDown = currentTime

	wait KNOCKED_ENEMY_DIALOGUE_DELAY

	if ( !IsValid( attacker ) || recentKnocks.len() == 0 )
		return

	if ( recentKnocks.len() >= 2 )
	{
		float mostRecentKnock       = recentKnocks[recentKnocks.len() - 1]
		float secondMostRecentKnock = recentKnocks[recentKnocks.len() - 2]

		if ( mostRecentKnock - secondMostRecentKnock < KNOCKED_ENEMY_DIALOGUE_DELAY )
		{
			PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_iDownedMultiple" )
			return
		}
	}

	if ( recentKnocks.len() == 1 )
	{
		PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_iDownedAnEnemy" )
	}
	else if ( recentKnocks.len() == 2 )
	{
		PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_iDownedAnotherEnemy" )
	}
	else if ( recentKnocks.len() >= 3 )
	{
		PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_megaKill" )
		attacker.p.recentPlayerKnockedEnemyTimes = []
	}
}


void function TrackKillStringTimer( entity player )
{
	Signal( player, "EnemyDowned" )
	EndSignal( player, "EnemyDowned" )

	EndSignal( player, "OnDestroy" )

	wait KILL_STRING_COOLDOWN

	player.p.recentPlayerKnockedEnemyTimes = []
}


#if DEVELOPER
void function DEV_GiveSpawnWeapons( entity player )
{
	if ( !IsAlive( player ) )
		return

	if ( (!player.IsBot() && GetCurrentPlaylistVarBool( "sur_clients_spawn_with_random_weapons", false ))
			|| (player.IsBot() && GetCurrentPlaylistVarBool( "sur_bots_spawn_with_random_weapons", false ) && !SmokeTest_IsActive()) )
	{
		string randomWeaponLootRef    = Dev_GetNextBotLootWeapon()
		LootData randomWeaponLootData = SURVIVAL_Loot_GetLootDataByRef( randomWeaponLootRef )
		entity weapon                 = SpawnGenericLoot( randomWeaponLootRef, player.GetOrigin() + <0, 0, 20>, <-1, -1, -1>, randomWeaponLootData.countPerDrop )
		Survival_PickupItem( weapon, player )

		if ( SURVIVAL_Loot_IsRefValid( randomWeaponLootData.ammoType ) )
		{
			entity ammoBox = SpawnGenericLoot( randomWeaponLootData.ammoType, player.GetOrigin() + <0, 0, 20>, <-1, -1, -1>, 80 )
			Survival_PickupItem( ammoBox, player )
		}
	}
}
#endif // DEVELOPER


/////////////////////////////////////////////////////////////////////////////////////
// destroy any entities from other modes until we get granular .ent-level control in bsps
/////////////////////////////////////////////////////////////////////////////////////
void function DestoyNonSurvivalEnt( entity ent )
{
	if ( IsValid( ent ) )
		ent.Destroy()
}


void function DestoyNonSurvivalEntAndLinkedEnts( entity ent )
{
	//destroy ent along with any linked ents
	array<entity> linkedEnts = ent.GetLinkEntArray()
	foreach ( linkedEnt in linkedEnts )
	{
		if ( IsValid( linkedEnt ) )
			linkedEnt.Destroy()
	}
	if ( IsValid( ent ) )
		ent.Destroy()
}


void function WalkSpeedWaterThink( entity trigger )
{
	file.triggerPlayerStatusEffects[trigger] <- {}

	trigger.SetEnterCallback( WaterTriggerEnter )
	trigger.SetLeaveCallback( WaterTriggerLeave )
}


void function WaterTriggerEnter( entity trigger, entity player )
{
	if ( !IsAlive( player ) || !player.IsPlayer() )
		return

	if ( !(player in file.triggerPlayerStatusEffects[trigger]) )
		file.triggerPlayerStatusEffects[trigger][player] <- 0

	int handle = StatusEffect_AddEndless( player, eStatusEffect.move_slow, 0.05 )
	file.triggerPlayerStatusEffects[trigger][player] = handle

	thread TEMP_StickyWaterProtection( player, trigger, handle )
}


void function TEMP_StickyWaterProtection( entity player, entity trigger, int handle )
{
	player.EndSignal( "TEMP_StickyWaterProtection" )

	while ( IsAlive( player ) )
	{
		if ( !trigger.IsTouching( player ) )
		{
			Warning( "TEMP_StickyWaterProtection triggered!" )
			StatusEffect_Stop( player, file.triggerPlayerStatusEffects[trigger][player] )
			file.triggerPlayerStatusEffects[trigger][player] = 0
		}

		wait 1.0
	}
}


void function WaterTriggerLeave( entity trigger, entity player )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	if ( !(player in file.triggerPlayerStatusEffects[trigger]) )
		return

	player.Signal( "TEMP_StickyWaterProtection" )

	StatusEffect_Stop( player, file.triggerPlayerStatusEffects[trigger][player] )
	file.triggerPlayerStatusEffects[trigger][player] = 0
}

#if DEVELOPER
void function Dev_ForceLaunchCharacterSpawning()
{
	file.DEV_overrideSpawnCharacterOrNull               = null
	file.DEV_overrideSpawnCharacterWithLaunchCharacters = true
}

void function ClientCommand_dev_sur_force_spawn_character( entity player, array<string> args )
{
	if ( args.len() == 0 )
	{
		Warning( "Incorrect number of arguments to client command 'dev_sur_force_spawn_character' (got \"" + DEV_ArrayConcat( args, " " ) + "\", expected 1 or more arguments)." )
		return
	}

	if ( args[0] == "random" )
	{
		file.DEV_overrideSpawnCharacterOrNull = null
	}
	else if ( args[0] == "special" )
	{
		Dev_ForceLaunchCharacterSpawning()
	}
	else
	{
		if ( !IsValidItemFlavorCharacterRef( args[0] ) )
		{
			Warning( "Tried to use 'dev_sur_force_spawn_character' with unknown character item flavor ref string \"" + args[0] + "\"." )
			return
		}
		ItemFlavor itemFlavor = GetItemFlavorByCharacterRef( args[0] )
		file.DEV_overrideSpawnCharacterOrNull = itemFlavor
	}

	if ( args.len() > 1 )
	{
		if ( args[1] == "simple" )
			file.DEV_overrideSpawnCharacterSimpleEquip = true
		else
			Warning( "Unknown secondary arg to 'dev_sur_force_spawn_character' - " + args[1] )
	}

	printt( "Override spawn character set to " + args[0] )
}

struct
{
	bool   recordDataValid = false
	int    team
	//array<ConsumableInventoryItem> inventory
	string armorRef
	int    shieldHealth

	string helmetRef
	string backpackRef
	string incapShieldRef

	table<string, int> ordnanceCounts

	string        activeWeaponRef
	array<string> activeWeaponMods
	int           activeWeaponLoadedAmmo
	float         glideMeter
} DEV_survivalBotPlaybackState

void function Survival_BotRecordStart( entity recordPlayer )
{
	DEV_survivalBotPlaybackState.recordDataValid = true
	//DEV_survivalBotPlaybackState.inventory = SURVIVAL_GetPlayerInventory( recordPlayer )
	DEV_survivalBotPlaybackState.armorRef        = Inventory_GetPlayerEquipment( recordPlayer, "armor" )
	DEV_survivalBotPlaybackState.shieldHealth    = recordPlayer.GetShieldHealth()
	DEV_survivalBotPlaybackState.helmetRef       = Inventory_GetPlayerEquipment( recordPlayer, "helmet" )
	DEV_survivalBotPlaybackState.backpackRef     = Inventory_GetPlayerEquipment( recordPlayer, "backpack" )
	DEV_survivalBotPlaybackState.incapShieldRef  = Inventory_GetPlayerEquipment( recordPlayer, "incapshield" )
	DEV_survivalBotPlaybackState.team            = recordPlayer.GetTeam()

	array<ConsumableInventoryItem> playerInventory = SURVIVAL_GetPlayerInventory( recordPlayer )

	foreach( invItem in playerInventory )
	{
		LootData invData = SURVIVAL_Loot_GetLootDataByIndex( invItem.type )
		if( invData.lootType == eLootType.ORDNANCE )
		{
			if ( !( invData.ref in DEV_survivalBotPlaybackState.ordnanceCounts ) )
			{
				DEV_survivalBotPlaybackState.ordnanceCounts[invData.ref] <- 1
			}
			else
			{
				DEV_survivalBotPlaybackState.ordnanceCounts[invData.ref]++
			}
		}
	}

	entity activeWeapon = recordPlayer.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( activeWeapon ) )
	{
		DEV_survivalBotPlaybackState.activeWeaponRef  = activeWeapon.GetWeaponClassName()
		DEV_survivalBotPlaybackState.activeWeaponMods = activeWeapon.GetMods()
		if ( activeWeapon.UsesClipsForAmmo() )
			DEV_survivalBotPlaybackState.activeWeaponLoadedAmmo = activeWeapon.GetWeaponPrimaryClipCount()
		else
			DEV_survivalBotPlaybackState.activeWeaponLoadedAmmo = activeWeapon.GetWeaponPrimaryAmmoCount( activeWeapon.GetActiveAmmoSource() )
	}
	else
	{
		DEV_survivalBotPlaybackState.activeWeaponRef        = ""
		DEV_survivalBotPlaybackState.activeWeaponMods       = []
		DEV_survivalBotPlaybackState.activeWeaponLoadedAmmo = 0
	}
	DEV_survivalBotPlaybackState.glideMeter = recordPlayer.GetGlideMeter()
}

void function Survival_BotPlaybackStart( entity playbackBot )
{
	if ( !DEV_survivalBotPlaybackState.recordDataValid )
	{
		Warning( "Survival_BotPlaybackStart was called before Survival_BotRecordStart" )
		return
	}

	ResetPlayerInventory( playbackBot )

	Inventory_SetPlayerEquipment( playbackBot, DEV_survivalBotPlaybackState.armorRef, "armor", DEV_survivalBotPlaybackState.shieldHealth )
	Inventory_SetPlayerEquipment( playbackBot, DEV_survivalBotPlaybackState.helmetRef, "helmet" )
	Inventory_SetPlayerEquipment( playbackBot, DEV_survivalBotPlaybackState.backpackRef, "backpack" )
	Inventory_SetPlayerEquipment( playbackBot, DEV_survivalBotPlaybackState.incapShieldRef, "incapshield" )
	//playbackBot.SetGlideMeter( DEV_survivalBotPlaybackState.glideMeter ) // S3: entity method not available

	foreach ( string ordnanceName, int count in DEV_survivalBotPlaybackState.ordnanceCounts )
	{
		printt("bot has " + count + " " + ordnanceName)
		for ( int i = 0; i < count; i++ )
		{
			entity ordnance = SpawnGenericLoot( ordnanceName, playbackBot.GetOrigin() + <0, 0, 20> )
			Survival_PickupItem( ordnance, playbackBot )
		}
	}

	string weaponRef = DEV_survivalBotPlaybackState.activeWeaponRef
	if ( SURVIVAL_Loot_IsRefValid( weaponRef ) )
	{
		LootData weaponLootData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
		if ( weaponLootData.lootType == eLootType.MAINWEAPON )
		{
			//entity lootWeapon = SpawnGenericLoot( weaponLootRef, playbackBot.GetOrigin() + <0, 0, 20>, <-1, -1, -1>, weaponLootData.countPerDrop )
			//Survival_PickupItem( lootWeapon, playbackBot )

			entity newWeapon = playbackBot.GiveWeapon_NoDeploy( weaponRef, WEAPON_INVENTORY_SLOT_PRIMARY_0, DEV_survivalBotPlaybackState.activeWeaponMods, false )
			if ( newWeapon.UsesClipsForAmmo() )
				newWeapon.SetWeaponPrimaryClipCount( DEV_survivalBotPlaybackState.activeWeaponLoadedAmmo )
			else
				newWeapon.SetWeaponPrimaryAmmoCount( newWeapon.GetActiveAmmoSource(), DEV_survivalBotPlaybackState.activeWeaponLoadedAmmo )

			playbackBot.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponRef )


			if ( SURVIVAL_Loot_IsRefValid( weaponLootData.ammoType ) )
			{
				entity ammoBox = SpawnGenericLoot( weaponLootData.ammoType, playbackBot.GetOrigin() + <0, 0, 20>, <-1, -1, -1>, 80 )
				Survival_PickupItem( ammoBox, playbackBot )
			}
		}
	}
}
#endif // DEVELOPER

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
	data.platformUid              = player.GetPlatformUID()
	//if( player.IsUsingSteam() ) // S3: entity method not available
	//{
	//	data.platformUid          = player.GetPINNucleusId()
	//}
	data.pid                      = "" //player.GetPINNucleusPid() // S3: not available
	data.nucleus                  = "" //player.GetPINNucleusId() // S3: not available
	data.hardware                 = "" //"" /*player.GetUnspoofedHardware() S3: not available*/ // S3: not available
	data.isUsingSteam             = false //player.IsUsingSteam() // S3: not available
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


void function GameSummary_FinalizeData( entity player )
{
	WaitFrame() // Need to wait a frame so kill callbacks and complete (game goes into WinnerDetermined gamestate before kill callback is even finished)

	if ( !IsValid( player ) )
		return

	if ( player.GetTeam() == TEAM_SPECTATOR )
		return

	// EOG rank
	int rank = Survival_GetCurrentRank( player )
	player.SetPersistentVar( "lastGameRank", rank )
	player.SetPersistentVar( "lastGameTime", GetUnixTimestamp() )
	player.SetPersistentVar( "lastGameBattlePassBoost", player.p.battlePassBoost )
	player.SetPersistentVar( "lastGameMode", GameRules_GetGameMode() )
	player.SetPersistentVar( "lastGameResultFlags", file.gameResultFlags )
	player.SetPersistentVar( "lastGameScoreFlags", file.gameScoreFlags )
	player.SetPersistentVar( "lastGameUIRules", GetPlaylistVarString( GetCurrentPlaylistName(), "ui_rules", "" ) )

	// Update stored player data for squad
	int team                   = player.GetTeam()
	int maxTrackedSquadMembers = PersistenceGetArrayCount( "lastGameSquadStats" )

	#if DEVELOPER
		printt( "PD: Setting Match Summary Persistent Vars for", player, "and", maxTrackedSquadMembers, "maxTrackedSquadMembers" )
		printt( "PD: lastGameRank", rank )
		printt( "PD: lastGameTime", GetUnixTimestamp() )
		printt( "PD: lastGameBattlePassBoost", player.p.battlePassBoost )
		printt( "PD: lastGameResultFlags", file.gameResultFlags )
		printt( "PD: lastGameScoreFlags", file.gameScoreFlags )
		printt( "PD: lastGameUIRules", GetPlaylistVarString( GetCurrentPlaylistName(), "ui_rules", "" ) )
	#endif

	// If this mode doesn't use alliances, set the match summary data for the player for each member of their squad
	if ( !AllianceProximity_IsUsingAlliances() )
	{
		foreach ( int teamMemberIndex, GameSummarySquadData data in file.squadData[ team ] )
		{
			if ( teamMemberIndex >= maxTrackedSquadMembers )
				break

			SetLastGameSquadStatsForPlayer_Internal( player, teamMemberIndex, data )
		}
	}
	else // If we are using alliances, do the same as above but only for the members of the players original squad ( before the team reassignment on match end puts all alliance members on one team )
	{
		int originalTeam = AllianceProximity_GetOriginalPlayerTeam_FromPlayerEHI( ToEHI( player ) ) // This is the team this player was originally in before the end of match team reassignment (their actual squad )
		array < int > originalTeamsCurrentTeamMemberIndexes = AllianceProximity_GetCurrentTeamMemberIndexesOfOriginalTeam( originalTeam ) // These are the current member indexes of that original squad
		int summaryIndex = 0
		#if DEVELOPER
			printt( "PD: Setting Match Summary Persistent Vars for in an alliance based mode for ", player, " originalTeamsCurrentTeamMemberIndexes array contains ", originalTeamsCurrentTeamMemberIndexes.len(), " team member indexes" )
		#endif

		// get the player's data recorded 1st so we don't miss it due to to many records
		int playerIndex = player.GetTeamMemberIndex()
		if( playerIndex in file.squadData[ team ] )
		{
			GameSummarySquadData data = file.squadData[ team ][ playerIndex ]
			SetLastGameSquadStatsForPlayer_Internal( player, summaryIndex, data )
			summaryIndex++
		}
		else
		{
			// we shouldn't ever really hit here, but there have been errors and we want to ensure the player data gets recorded so do a EHI search
			foreach( teamData in file.squadData )
			{
				bool found = false
				foreach( memberData in teamData )
				{
					if( memberData.eHandle == player.GetEncodedEHandle() )
					{
						SetLastGameSquadStatsForPlayer_Internal( player, summaryIndex, memberData )
						summaryIndex++
						found = true
						break;
					}
				}

				if( found )
					break
			}
		}

		foreach ( teamMemberIndex in originalTeamsCurrentTeamMemberIndexes )
		{
			if ( summaryIndex >= maxTrackedSquadMembers )
				break

			// already did player
			if ( teamMemberIndex == playerIndex )
				continue

			if( teamMemberIndex in file.squadData[ team ] )
			{
				GameSummarySquadData data = file.squadData[ team ][ teamMemberIndex ]
				SetLastGameSquadStatsForPlayer_Internal( player, summaryIndex, data )
				summaryIndex++
			}
			else
			{
				Warning( "Failed to record GameSummarySquadData for team '" + team + "', TeamMemberIndex '" + teamMemberIndex + "', OriginalTeam '" + originalTeam + "'" )
			}
		}
	}

	// Force game summary screen at next lobby
	bool showGameSummary = !( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_TRAINING ) || IsPrivateMatch() )
	player.SetPersistentVar( "showGameSummary", showGameSummary )

	#if DEVELOPER
		printt( "PD: showGameSummary", showGameSummary )
	#endif

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
		Ranked_SetXProgMergedPersistenceData( player, RANKED_SHOW_RANKED_SUMMARY_PERSISTENCE_VAR_NAME, showGameSummary ? 1 : 0 )




}

// Set the lastGameSquadStats persistent vars for the passed in player for the passed in team member index
// This needs to be run for the team member index of each squadmate
void function SetLastGameSquadStatsForPlayer_Internal( entity player, int teamMemberIndex, GameSummarySquadData data )
{
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].playerName", data.playerName )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].character", ItemFlavor_GetGUID( data.character ) )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].eHandle", data.eHandle )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].survivalTime", data.survivalTime )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].kills", data.kills )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].assists", data.assists )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].knockdowns", data.knockdowns )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].damageDealt", data.damageDealt )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].revivesGiven", data.revivesGiven )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].respawnsGiven", data.respawnsGiven )

	// mode-specific
	// populate with our defaults
	data.displayData[0] = data.kills
	data.displayData[1] = data.assists
	data.displayData[2] = data.knockdowns
	data.displayData[3] = data.damageDealt
	data.displayData[4] = data.survivalTime
	data.displayData[5] = data.revivesGiven
	data.displayData[6] = data.respawnsGiven

	// now overwrite values with mode-specific meta data values matching enum to array position (e.g. enum 4 --> slot 4)
	// CANNOT overwrite top-line values: kill / assists / knocks
	foreach ( k, v in data.modeMetaData )
	{
		Assert( k != 0 && k != 1 && k != 2, "Modes may not overwrite topline stats of kills / assists / knocks." )
		data.displayData[k] = v
	}

	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].displayData3IsTime", data.displayData3IsTime )

	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].displayData2",  data.displayData[3] )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].displayData3",  data.displayData[4] )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].displayData4",  data.displayData[5] )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].displayData5",  data.displayData[6] )
	// end mode-specific

	#if DEVELOPER
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].playerName", data.playerName )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].character", ItemFlavor_GetGUID( data.character ) )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].eHandle", data.eHandle )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].survivalTime", data.survivalTime )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].kills", data.kills )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].assists", data.assists )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].knockdowns", data.knockdowns )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].damageDealt", data.damageDealt )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].revivesGiven", data.revivesGiven )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].respawnsGiven", data.respawnsGiven )

		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].displayData3IsTime", data.displayData3IsTime )

		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].displayData2",  data.displayData[3] )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].displayData3",  data.displayData[4] )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].displayData4",  data.displayData[5] )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].displayData5",  data.displayData[6] )
	#endif

	//I've moved this above the ShouldSendLastSquadInfo check as Clubs needs it for reporting placement events to the timeline.
	//This doesn't affect the Last Squad reporting, which requires platformUid and hardwareID - ChadA
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].nucleusId", data.nucleus )

	if ( !ShouldSendLastSquadInfo( data ) )
		return

	int hardwareID = GetHardwareFromName( data.hardware )

	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].platformUid", data.platformUid )
	player.SetPersistentVar( "lastGameSquadStats[" + teamMemberIndex + "].hardwareID", hardwareID )

	#if DEVELOPER
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].platformUid", data.platformUid )
		printt( "PD: lastGameSquadStats[", teamMemberIndex, "].hardwareID", hardwareID )
	#endif
}


bool function ShouldSendLastSquadInfo( GameSummarySquadData data )
{
	if ( data.optOutOfSendingSquadInfo )
		return false






	return true
}


GameSummarySquadData function GameSummary_GetPlayerData( entity player )
{
	int team  = player.GetTeam()
	int index = player.GetTeamMemberIndex()
	return file.squadData[ team ][ index ]
}


table< int, GameSummarySquadData > ornull function GameSummary_GetTeamDataOrNull( int team )
{
	if ( team in file.squadData )
		return file.squadData[team]
	return null
}


int function CalcSecondsAliveForPlayer( entity player )
{
	float survivalAliveEndTime = (IsAlive( player ) || player.p.survivalAliveEndTime < player.p.survivalAliveStartTime) ? Time() : player.p.survivalAliveEndTime
	int secondsAlive           = maxint( int( survivalAliveEndTime - player.p.survivalAliveStartTime ), 0 )
	secondsAlive = minint( secondsAlive, int( GameTime_PlayingTime() ) )

	return secondsAlive
}


void function GameSummary_UpdateSurvivalTimes( int team )
{
	array<entity> members = GetPlayerArrayOfTeam( team )
	foreach ( player in members )
	{
		GameSummary_GetPlayerData( player ).survivalTime = CalcSecondsAliveForPlayer( player )
	}
}


int function GameSummary_GetHighestSurvivalTime( int team )
{
	GameSummary_UpdateSurvivalTimes( team )

	int highestTime = 0
	foreach ( memberData in file.squadData[team] )
	{
		if ( memberData.survivalTime > highestTime )
			highestTime = memberData.survivalTime
	}

	return highestTime
}

void function AddGameSummaryKill( entity player, entity victim, int increment )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	data.kills += increment

	EncodedEHandle victimEEH = EHIToEncodedEHandle(victim)
	if ( !(victimEEH in data.playerKills) )
		data.playerKills[victimEEH] <- 0

	data.playerKills[victimEEH]++

	foreach ( func in file.Callbacks_OnPlayerGameSummaryKill )
		func( player, victim, increment )

	foreach ( func in file.Callbacks_OnPlayerGameSummaryStatChanged )
		func( player, eStatNames.kills, (data.kills - increment), data.kills )

}


void function AddGameSummaryKillAssist( entity player, entity victim , int increment )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	data.assists += increment

	foreach ( func in file.Callbacks_OnPlayerGameSummaryAssist )
		func( player, victim, increment )

	foreach ( func in file.Callbacks_OnPlayerGameSummaryStatChanged )
		func( player, eStatNames.assists, (data.assists - increment), data.assists )

}

void function AddGameSummaryKnockdown( entity player, entity victim, int increment, var damageInfo )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	data.knockdowns += increment

	foreach ( func in file.Callbacks_OnPlayerGameSummaryKnockdown )
		func( player, victim, increment, damageInfo )

	foreach ( func in file.Callbacks_OnPlayerGameSummaryStatChanged )
		func( player, eStatNames.knockdowns, (data.knockdowns - increment), data.knockdowns )
}

void function AddGameSummaryKnockdownAssist ( entity player, entity victim, int increment )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	data.knockdownAssists += increment

	foreach ( func in file.Callbacks_OnPlayerGameSummaryKnockdownAssist )
		func( player, victim, increment )

	foreach ( func in file.Callbacks_OnPlayerGameSummaryStatChanged )
		func( player, eStatNames.knockdownAssists, (data.knockdownAssists - increment), data.knockdownAssists )
}

void function AddGameSummaryDeath( entity player, int increment )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	data.deaths += increment
}


void function AddGameSummaryDamage( entity attacker, entity damagedPlayer, int damageAmount )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( !attacker.IsPlayer() || !damagedPlayer.IsPlayer() )
		return

	if ( IsFriendlyTeam( attacker.GetTeam(), damagedPlayer.GetTeam() ) )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( attacker )
	data.damageDealt += damageAmount

	// set damageDealt so the HUD can display it, and rui track it.
	attacker.SetPlayerNetInt( "damageDealt", data.damageDealt )
}


void function AddGameSummaryReviveGiven( entity player, int increment )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	data.revivesGiven += increment

	AddXP( player, eXPType.REVIVE_ALLY )

	foreach ( func in file.Callbacks_OnPlayerGameSummaryStatChanged )
		func( player, eStatNames.revivesGiven, (data.revivesGiven - increment), data.revivesGiven )
}


void function OnPlayerLootPickup( entity player, entity ent, string ref, int unitsPickedUp, bool willDestroy, entity deathBox, int pickupFlags )
{
	if ( GameTime_PlayingTime() > GAMETIME_LIMIT_FOR_AFK )
	{
		GameSummarySquadData data = GameSummary_GetPlayerData( player )
		data.lootedLateInTheGame = true
	}

	if ( ent.e.spawnSource == eSpawnSource.PLAYER_DROP
			&& ent.e.spawnTime + SURVIVAL_AUTOTHANKS_TIMEOUT > 0
			&& IsAlive( ent.GetOwner() )
			&& ent.GetOwner() != player
			&& IsFriendlyTeam( ent.GetOwner().GetTeam(), player.GetTeam() ) )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_PromptSayThanks", ent.GetOwner() )
	}
	else
	{
		entity friendlyWhoPingedLoot = Waypoint_GetFriendlyThatPingedEnt( ent, player )
		if ( IsAlive( friendlyWhoPingedLoot ) )
			Remote_CallFunction_NonReplay( player, "ServerCallback_PromptSayThanks", friendlyWhoPingedLoot )
	}

	file.playerData[EHIToEncodedEHandle( player )].pickedUpLootCount++
}


bool function Survival_PlayerWasActive( entity player )
{
	if ( !GetCurrentPlaylistVarBool( "match_behavior_afk_check_enabled", false ) )
		return true

	GameSummarySquadData summaryData = GameSummary_GetPlayerData( player )
	if ( summaryData.kills > 0 )
		return true

	if ( summaryData.damageDealt > 0 )
		return true

	if ( summaryData.respawnsGiven > 0 )
		return true

	if ( summaryData.revivesGiven > 0 )
		return true

	GameSummary_UpdateSurvivalTimes( player.GetTeam() )
	summaryData = GameSummary_GetPlayerData( player )

	if ( summaryData.survivalTime < 90 )
		return true

	if ( Distance2D( file.playerData[EHIToEncodedEHandle( player )].landingOrigin, player.GetOrigin() ) > GetCurrentPlaylistVarFloat( "match_behavior_travel_dist", 4096.0 ) )
		return true

	return file.playerData[EHIToEncodedEHandle( player )].pickedUpLootCount > 0
}


int function PlayerGameSummary_GetKills( entity player )
{
	if ( player.IsBot() )
		return 0

	return GameSummary_GetPlayerData( player ).kills
}


int function PlayerGameSummary_GetDeaths( entity player )
{
	if ( player.IsBot() )
		return 0

	return GameSummary_GetPlayerData( player ).deaths
}


int function PlayerGameSummary_GetAssists( entity player )
{
	if ( player.IsBot() )
		return 0

	return GameSummary_GetPlayerData( player ).assists
}


string function Survival_GetLootTypeForStatString( LootData data )
{
	switch( data.lootType )
	{
		case eLootType.MAINWEAPON:
			return "MainWeapon"

		case eLootType.AMMO:
			return "Ammo"

		case eLootType.HEALTH:
			return "Health"

		case eLootType.ARMOR:
			return "Armor"

		case eLootType.INCAPSHIELD:
			return "IncapShield"

		case eLootType.JUMPKIT:
			return "Jumpkit"

		case eLootType.ORDNANCE:
			return "Ordnance"

		case eLootType.GADGET:
			return "Gadget"

		case eLootType.ATTACHMENT:
			return "Attachment"

		case eLootType.CUSTOMPICKUP:
			return "CustomPickup"


		case eLootType.CANDY_PICKUP:
			return "CandyPickup"



		case eLootType.EVO_CACHE:
			return "EvoPickup"


		case eLootType.BACKPACK:
			return "Backpack"

		case eLootType.HELMET:
			return "Helmet"



		case eLootType.DATAKNIFE:
			return "Dataknife"


		case eLootType.RESOURCE:
			return "Resource"



		case eLootType.MARVIN_ARM:
			return "MarvinArm"


		default:
			return "UNKNOWN_" + data.lootType
	}
	return ""
}


bool function Survival_ShouldProcessSurvivalEventForCurrentMode( int eventType )
{
	//so multiple modes can handle different event registration
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) )
	{
		if ( eventType == eSurvivalEventType.CIRCLE_MOVES_45SEC )
			return false
		if ( eventType == eSurvivalEventType.CIRCLE_MOVES_10SEC )
			return false
	}

	return true
}

bool function Survival_IsCoverEnabled()
{


	switch ( GetMapName() )
	{
		case "mp_rr_ai_traverse":
		case "mp_rr_ai_wildlife":
		case "mp_rr_ai_testmap":
		case "mp_rr_spectreshack_actionblock_02":
		case "mp_rr_tropic_island_mu1":
		case "mp_rr_tropic_island_mu2":
		case "mp_rr_tropic_island_mu3":
			return true
	}

	// Cover nodes disabled by default
	return false
}


void function Survival_OnWeaponAttack( entity player, entity weapon, string weaponName, int ammoUsed, vector attackOrigin, vector attackDir )
{
	if ( !IsValid( player ) )
		return

	if ( ! player.IsPlayer() )
		return

	if ( ! SURVIVAL_Loot_IsRefValid( weaponName ) )
		return

	LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )
	bool isMainWeapon = weaponData.lootType == eLootType.MAINWEAPON
	bool usesAmmoPool = weapon.GetWeaponSettingBool( eWeaponVar.uses_ammo_pool )

	string ammoTypeRef = AmmoType_GetRefFromIndex( weapon.GetWeaponAmmoPoolType() )
	LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoTypeRef )

	if ( !isMainWeapon || !usesAmmoPool || GetInfiniteAmmo( weapon ) )
		return

	if ( ammoUsed <= 0 )
		return

	if ( weapon.GetWeaponPrimaryClipCount() > 0 )
		return

	int commsAction = -1

	switch( ammoData.ref )
	{
		case BULLET_AMMO:
			if (  player.AmmoPool_GetCount( eAmmoPoolType.bullet ) <= 0 )
				commsAction = eCommsAction.INVENTORY_NO_AMMO_BULLET
			break

		case SPECIAL_AMMO:
			if (  player.AmmoPool_GetCount( eAmmoPoolType.special ) <= 0 )
				commsAction = eCommsAction.INVENTORY_NO_AMMO_SPECIAL
			break

		case HIGHCAL_AMMO:
			if (  player.AmmoPool_GetCount( eAmmoPoolType.highcal ) <= 0 )
				commsAction = eCommsAction.INVENTORY_NO_AMMO_HIGHCAL
			break

		case SHOTGUN_AMMO:
			if (  player.AmmoPool_GetCount( eAmmoPoolType.shotgun ) <= 0 )
				commsAction = eCommsAction.INVENTORY_NO_AMMO_SHOTGUN
			break

		case SNIPER_AMMO:
			if (  player.AmmoPool_GetCount( eAmmoPoolType.sniper ) <= 0 )
				commsAction = eCommsAction.INVENTORY_NO_AMMO_SNIPER
			break

		case ARROWS_AMMO:
			if (  player.AmmoPool_GetCount( eAmmoPoolType.arrows ) <= 0 )
				commsAction = eCommsAction.INVENTORY_NO_AMMO_ARROWS
			break

		default:
			Warning( "Unhandled ammo type in Survival_OnWeaponAttack: " + ammoData.ref )
			return
	}

	if ( commsAction != -1 )
		BroadcastCommsActionToTeam( player, commsAction, weapon, player.GetOrigin(), eCommsFlags.NO_TEXT, "" )
}


void function Survival_OnReloadPressed_Internal( entity player )
{
	EndSignal( player, "OnDestroy" )

	// on gamepad, use_long and reload have the same input
	// if use_long somehow disables our weapon (e.g. execution), we don't want to send the battle chatter
	// so we have to wait a frame for use_long to resolve itself first before we attempt to battle chatter

	WaitFrame()

	if ( !IsAlive( player ) )
		return

	if ( player.GetWeaponDisableFlags() == WEAPON_DISABLE_FLAGS_ALL )
		return

	// should probably also check the altHand in case we're dual wielding
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponType() == WT_ANTITITAN )
		return

	if ( weapon.GetWeaponPrimaryClipCountMax() <= 0 || !weapon.GetWeaponSettingBool( eWeaponVar.uses_ammo_pool ) || player.AmmoPool_GetCount( weapon.GetWeaponAmmoPoolType() ) > 0 )
		return

	int commsAction = eCommsAction.BLANK
	switch ( weapon.GetWeaponAmmoPoolType() )
	{
		case eAmmoPoolType.bullet:
			commsAction = eCommsAction.INVENTORY_NEED_AMMO_BULLET
			break

		case eAmmoPoolType.highcal:
			commsAction = eCommsAction.INVENTORY_NEED_AMMO_HIGHCAL
			break

		case eAmmoPoolType.shotgun:
			commsAction = eCommsAction.INVENTORY_NEED_AMMO_SHOTGUN
			break

		case eAmmoPoolType.special:
			commsAction = eCommsAction.INVENTORY_NEED_AMMO_SPECIAL
			break








		case eAmmoPoolType.sniper:
			commsAction = eCommsAction.INVENTORY_NEED_AMMO_SNIPER
			break

		case eAmmoPoolType.arrows:
			commsAction = eCommsAction.INVENTORY_NEED_AMMO_ARROWS
			break

		default:
			Warning( "Unsupported ammo type!" )
	}

	// BroadcastCommsActionToTeam( player, commsAction, null, player.GetOrigin(), eCommsFlags.NONE, "" )
}


void function Survival_OnReloadPressed( entity player )
{
	thread Survival_OnReloadPressed_Internal( player )
}


bool function Survival_DamageShouldSlowDownPlayer( entity player, var damageInfo )
{
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	int damageFlags    = DamageInfo_GetCustomDamageType( damageInfo )

	if ( PlayerHasPassive( player, ePassives.PAS_FORTIFIED ) )
		return false


		if ( TitanSword_ActiveWeaponIsTitanSword( player ) )
			return false


	// gas will do its own slowdown
	if ( damageSourceId == eDamageSourceId.damagedef_gas_exposure )
		return false


	if( damageSourceId == eDamageSourceId.mp_weapon_mortar_ring && PlayerHasPassive( player, ePassives.PAS_MOTHERLODE_RESISTANCE ) ) //upgrade_fuse_motherlode_resistance
	{
		return false
	}


	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

	if ( Time() - file.playerLastDamageSlowTime[player] < CharacterClass_GetDamageSlowDebounce( character ) )
		return false

	return (CharacterClass_GetDamageSlowAmount( character ) > 0.0)
}


void function Survival_SetInventoryEnabled( entity player, bool enabled )
{
	player.SetPlayerNetBool( "inventoryEnabled", enabled )
}


void function UpdateSquadDataForTeamChange( entity player, int oldIndex, int newIndex, int oldTeam, int newTeam )
{
	//Updating file.squadData
	if ( !(newTeam in file.squadData) )
		file.squadData[newTeam] <- {}

	file.squadData[ newTeam ][ newIndex ] <- file.squadData[ oldTeam ][ oldIndex ]
	delete file.squadData[ oldTeam ][ oldIndex ]

	//Updating file.squadPINData
	if ( !(newTeam in file.squadPINData) )
	{
		SurvivalSquadPINData squadPINData
		file.squadPINData[newTeam] <- squadPINData
	}
	file.squadPINData[newTeam].numMembers++
	file.squadPINData[oldTeam].numMembers--

	file.squadPINData[newTeam].memberScores[newIndex] <- file.squadPINData[oldTeam].memberScores[oldIndex]
	file.squadPINData[oldTeam].memberScores[oldIndex] = 0
}


/*void function TrackSpectatedCount()
{
	table<entity, int> oldPlayerObservedCount

	if ( !GetCurrentPlaylistVarBool( "showSpectatorIndicators", !IsRankedGame() ) )
		return

	while( true )
	{
		table<entity, int> playerObservedCount

		array<entity> playerArray = GetPlayerArray()
		foreach ( player in playerArray )
		{
			WaitFrame()
			// only check one player per frame.
			// it'll take ~6 seconds to go through them all but that should be ok since it gets quicker the fewer players remain.
			// This should probably be a code thing if we want it to be instant.

			if ( IsValid( player ) && player.IsObserver() )
			{
				entity observedTarget = player.GetObserverTarget()
				if ( !IsValid( observedTarget ) || !observedTarget.IsPlayer() )
					continue

				if ( !(observedTarget in playerObservedCount) )
					playerObservedCount[observedTarget] <- 0
				playerObservedCount[observedTarget]++// = playerObservedCount[observedTarget]  + 1
			}
		}
		foreach ( player, count in playerObservedCount )
		{
			if ( !IsValid( player ) )
				continue
			player.SetPlayerNetInt( "playerObservedCount", count )
		}

		// clear old values
		foreach ( player, count in oldPlayerObservedCount )
		{
			if ( !IsValid( player ) || player in playerObservedCount )
				continue
			player.SetPlayerNetInt( "playerObservedCount", 0 )
		}

		oldPlayerObservedCount = clone playerObservedCount
		wait 1
	}
}*/



void function CodeCallback_ReportPlayerCustomerService( entity player, int hardwareID, string uid, string eaid, string reason )
{
	string hardware = GetNameFromHardware( hardwareID )

	if ( !GetCurrentPlaylistVarBool( "eac_report_enable", true ) )
	{
		printt( "CodeCallback_ReportPlayerCustomerService report not enabled" )
		return
	}

	if ( !file.connectedUIDsSeenThisMatch.contains( uid ) )
	{
		// do something about false reports?
		printt( "CodeCallback_ReportPlayerCustomerService uid=" + uid + " not found" )
		return
	}

	bool isReportReasonValid                 = false
	array<string> validFriendlyReportReasons = GetReportReasons( "" )
	isReportReasonValid = isReportReasonValid || validFriendlyReportReasons.contains( reason )

	array<string> validEnemyReportReasons = GetReportReasons( "" )
	isReportReasonValid = isReportReasonValid || validEnemyReportReasons.contains( reason )

	if ( !isReportReasonValid )
	{
		// do something about false reports?
		printt( "CodeCallback_ReportPlayerCustomerService reason=[" + reason + "] not valid" )
		return
	}

	if ( file.cheaterReportsThisMatch[player].contains( hardware + "-" + uid + "_" + reason ) )
	{
		// already reported for this behavior by this player
		printt( "CodeCallback_ReportPlayerCustomerService reason=[" + hardware + "-" + uid + "_" + reason + "] already reported" )
		return
	}

	if ( file.cheaterReportsThisMatch[player].len() >= GetCurrentPlaylistVarInt( "eac_report_player_max", 12 ) )
	{
		// do something about spam
		printt( "CodeCallback_ReportPlayerCustomerService too many reports" )
		return
	}

	string reporterUID      = player.GetPlatformUID()
	string reporterHardware = "" /*player.GetUnspoofedHardware() S3: not available*/

	switch ( reason )
	{
		case "#REPORT_PLAYER_REASON_OFFENSIVE":
		case "#REPORT_PLAYER_REASON_STALKING":
		case "#REPORT_PLAYER_REASON_SUICIDE":
		case "#REPORT_PLAYER_REASON_DRUGSFIREARMS":
		case "#REPORT_PLAYER_REASON_NAME":
		case "#REPORT_PLAYER_REASON_TAG":
		case "#REPORT_PLAYER_REASON_CONTENT":
		case "#REPORT_PLAYER_REASON_SPAM":
		case "#REPORT_PLAYER_REASON_ILLEGAL_HATE_SPEECH":
		case "#REPORT_PLAYER_REASON_ILLEGAL_SEXUAL_CONTENT":
		case "#REPORT_PLAYER_REASON_ILLEGAL_CHILD_SOLICITATION":
		case "#REPORT_PLAYER_REASON_ILLEGAL_SUICIDE_THREAT":
		case "#REPORT_PLAYER_REASON_ILLEGAL_LEWDNESS":
		case "#REPORT_PLAYER_REASON_ILLEGAL_TERRORIST_THREAT":
		case "#REPORT_PLAYER_REASON_ILLEGAL_VIOLENT":
			printt( "CodeCallback_ReportPlayerCustomerService ReportAbusiveChat", player.GetPlayerName() + " reported player " + hardware + "-" + uid + " for " + reason )
			ReportAbusiveChat( uid, hardware, reason )
			break

		default:
			printt( "CodeCallback_ReportPlayerCustomerService ReportCheater", player.GetPlayerName() + " reported player " + hardware + "-" + uid + "/" + eaid + " for " + reason + ". eaid " + eaid )
			ReportCheater( uid, hardware, reason )
	}

	file.cheaterReportsThisMatch[player].append( hardware + "-" + uid + "_" + reason )
}


array<string> function GetReportReasons( string platform )
{
	array<string> prefixes
	array<string> reportReasons = []

	if ( platform.tolower() == "pc" || platform.tolower() == "pc_steam" )
	{
		prefixes.append( "report_player_reason_pc_" + "cheat" + "_" )
		prefixes.append( "report_player_reason_pc_" + "gameplay" + "_" )
		prefixes.append( "report_player_reason_pc_" + "harassment" + "_" )
		prefixes.append( "report_player_reason_pc_" + "content" + "_" )
	}
	else
	{
		prefixes.append( "report_player_reason_console_" + "cheat" + "_" )
		prefixes.append( "report_player_reason_console_" + "gameplay" + "_" )
		prefixes.append( "report_player_reason_console_" + "harassment" + "_" )
		prefixes.append( "report_player_reason_console_" + "content" + "_" )
	}

	foreach ( playlistVarPrefix in prefixes )
	{
		int numReasons = GetCurrentPlaylistVarInt( playlistVarPrefix + "count", 0 )
		for ( int index = 0; index < numReasons; index++ )
		{
			reportReasons.append( GetCurrentPlaylistVarString( playlistVarPrefix + (index + 1), "#UNAVAILABLE" ) )
		}
	}

	return reportReasons
}


struct IntroAirDrop
{
	Point&        airdropPoint
	array<string> lootGroupNames
}


void function IntroAirdropThink()
{
	string playlistString = GetCurrentPlaylistVarString( "airdrop_intro_sets", "" ).tolower()
	if ( playlistString == "" )
		return

	array<string> lootGroupSets = split( playlistString, WHITESPACE_CHARACTERS )
	lootGroupSets.randomize()

	array<IntroAirDrop> introAirdrops
	array<vector> usedPoints
	foreach ( lootGroupString in lootGroupSets )
	{
		array<string> lootGroupNames = split( lootGroupString, ":" )
		Assert( lootGroupNames.len() == 3, "Invalid playlist var airdrop_intro_groups; incorrect group count " + lootGroupNames.len() )
		if ( lootGroupNames.len() != 3 )
			continue

		vector startPos  = SURVIVAL_GetPlaneJumpStartPos()
		vector endPos    = SURVIVAL_GetPlaneJumpEndPos()
		vector planeVec  = Normalize( endPos - startPos )
		float jumpLength = (endPos - startPos).Length()

		float planePathFrac = GetCurrentPlaylistVarFloat( "airdrop_intro_plane_path_frac", 0.6 )
		vector dropOrigin   = startPos + (planeVec * (jumpLength * planePathFrac))
		float dropRadius    = GetCurrentPlaylistVarFloat( "airdrop_intro_radius", 8000.0 )

		array<ActiveHotZone> activeHotZones = SURVIVAL_GetActiveHotZones()
		if ( GetCurrentPlaylistVarBool( "airdrop_intro_use_hotzone", false ) && activeHotZones.len() > 0 )
		{
			ActiveHotZone hotZone = activeHotZones.getrandom()
			dropOrigin = hotZone.zone.origin
			dropRadius = hotZone.zone.radius
		}

		Point airdropPoint
		waitthread FindRandomAirdropDropPoint_Thread( airdropPoint, VectorToAngles( planeVec ).y + RandomFloatRange( -180.0, 180.0 ), dropOrigin, dropRadius, usedPoints )

		foreach ( groupName in lootGroupNames )
		{
			Assert( SURVIVAL_IsValidLootGroup( groupName ), "Invalid loot group in airdrop_intro_groups;" + groupName )
			if ( !SURVIVAL_IsValidLootGroup( groupName ) )
				continue
		}


		IntroAirDrop introAirdrop
		introAirdrop.airdropPoint   = airdropPoint
		introAirdrop.lootGroupNames = lootGroupNames

		introAirdrops.append( introAirdrop )
		CreateNonExpiringAirdropBadPlace( airdropPoint.origin, AIR_DROP_BAD_PLACE_RADIUS )

		usedPoints.append( airdropPoint.origin )
	}

	FlagWait( "PlayersSpawnedInArena" )

	foreach ( introAirdrop in introAirdrops )
	{
		foreach ( player in GetPlayerArray_Alive() )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_SUR_PingMinimap", introAirdrop.airdropPoint.origin, 15.0, 256.0, 50.0, COLORID_FRIENDLY, 0.8, 0.2, eAirdropType.STANDARD )
		}

		array< array<string> > lootGroupsToUse = []
		foreach ( group in introAirdrop.lootGroupNames )
			lootGroupsToUse.append( [group] )

		array< array<string> > podContents = DetermineAirdropContents ( lootGroupsToUse )

		AirdropItemsOptionalInfo optionInfo
		optionInfo.animationName = "droppod_loot_drop_lifeline"

		thread AirdropItems( introAirdrop.airdropPoint.origin, introAirdrop.airdropPoint.angles, podContents, optionInfo )
		wait RandomFloatRange( 1.0, 3.0 )
	}
}


void function Survival_SetCallback_Leviathan_ConsiderLookAtEnt( CallbackType_Leviathan_ConsiderLookAtEnt callback )
{
	file.Leviathan_ConsiderLookAtEnt = callback
}


void function Leviathan_ConsiderLookAtEnt( entity ent, float duration, float careChance )
{
	if ( file.Leviathan_ConsiderLookAtEnt != null )
		thread file.Leviathan_ConsiderLookAtEnt( ent, duration, careChance )
}


void function ProjectX_DumpGameSummarySquadData()
{
	// Temp solution used by esports orgs to collect data from logs for tournaments
	if ( GetConVarBool( "pin_telemetry_debug_script" ) || GetBugReproNum() == 1981 )
	{
		foreach ( int team, table< int, GameSummarySquadData > teamData in file.squadData )
		{
			string line = "\ns_match_end_team_stats_dump: {"
			line += "\n  \"team\": " + team + ","
			line += "\n  \"mid\": \"" + lstrip( rstrip( GameRules_GetUniqueMatchID() ) ) + "\","

			int rank = team == GetWinningTeam() ? 1 : -1
			if ( team in file.finalTeamRanks )
				rank = file.finalTeamRanks[ team ]
			line += "\n  \"rank\": " + rank + ","

			foreach ( int playerIndex, GameSummarySquadData playerData in teamData )
			{
				line += "\n  \"" + playerIndex + "\": {"
				line += "\n    \"name\": \"" + playerData.playerName + "\","
				line += "\n    \"pid\": \"" + playerData.pid + "\","
				line += "\n    \"nucleus\": \"" + playerData.nucleus + "\","
				line += "\n    \"character\": \"" + ItemFlavor_GetCharacterRef( playerData.character ) + "\","
				line += "\n    \"survivalTime\": " + playerData.survivalTime + ","
				line += "\n    \"kills\": " + playerData.kills + ","
				line += "\n    \"assists\": " + playerData.assists + ","
				line += "\n    \"knockdowns\": " + playerData.knockdowns + ","
				line += "\n    \"damageDealt\": " + playerData.damageDealt + ","
				line += "\n    \"revivesGiven\": " + playerData.revivesGiven + ","
				line += "\n    \"respawnsGiven\": " + playerData.respawnsGiven + ","
				line += "\n    \"deaths\": " + playerData.deaths
				line += "\n    \"displayData3IsTime\": " + playerData.displayData3IsTime
				line += "\n    \"displayData[3]\": " + playerData.displayData[3]
				line += "\n    \"displayData[4]\": " + playerData.displayData[4]
				line += "\n    \"displayData[5]\": " + playerData.displayData[5]
				line += "\n    \"displayData[6]\": " + playerData.displayData[6]
				line += "\n  }"
				if ( playerIndex + 1 < teamData.len() )
					line += ","
			}

			line += "\n}"
			printt( line )
		}
	}
}

bool function Survival_FiringRange_IsCharacterRespawning()
{
	return file.isFRCharacterRespawning
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


void function PveGeoOnSpawn( entity blocker )
{
	//disable any added PvE blockers and geo by default and reconnect navmesh
	//no way around this if we are using the same map for both PvE and PvP (currently Kings Canyone Night)
	blocker.Hide()
	blocker.NotSolid()
	ToggleNPCPathsForEntity( blocker, false )
}


const float DEAD_PERIOD_BUFFER = 60.0
void function DeadPeriodChecker_PlayerDeadPeriodEnd( entity player, int reason )
{
	if ( !IsValid( player ) || !IsAlive( player ) || player.IsBot() )
		return

	float currentTime = Time()
	DeadPeriodData dpData
	dpData.startTime = currentTime
	dpData.startPosition = player.GetOrigin()

	if ( !( player in file.playerDeadZonePeriodData ) )
	{
		if ( PlayerMatchState_GetFor( player ) == ePlayerMatchState.NORMAL ) // This is a fall back case for if the player somehow spawns in already in the NORMAL match state
		{
			file.playerDeadZonePeriodData[ player ] <- dpData
		}
		else
		{
			return
		}
	}

	if ( currentTime - file.playerDeadZonePeriodData[ player ].startTime >= DEAD_PERIOD_BUFFER )
	{
		PIN_DeadPeriodEnded( player, GetEnumString( "eDeadPeriodEndReason", reason ), file.playerDeadZonePeriodData[ player ] )
	}

	file.playerDeadZonePeriodData[ player ] = dpData
}


void function DeadPeriodChecker_OnPlayerMatchStateChanged( entity player, int newValue, int oldValue )
{
	if ( IsValid( player ) && newValue == ePlayerMatchState.NORMAL && IsAlive( player ) && !player.IsBot() &&
			!( player in file.playerDeadZonePeriodData ) )
	{
		DeadPeriodData dpData
		dpData.startTime = Time()
		dpData.startPosition = player.GetOrigin()

		file.playerDeadZonePeriodData[ player ] <- dpData
	}
}


void function DeadPeriodChecker_PlayerGrabbedItem( entity player )
{
	if ( IsValid( player ) && IsAlive( player ) && player in file.playerDeadZonePeriodData )
	{
		file.playerDeadZonePeriodData[ player ].itemsGrabbed++
	}
}


#if DEVELOPER

void function TestPrompt_RevealMyLastDeathbox()
{
	Remote_CallFunction_NonReplay( GP(), "ServerCallback_PromptMarkMyLastDeathbox" )
}

#endif

void function Survival_SetGameResultFlags( int flags )
{
	file.gameResultFlags = flags
}

int function Survival_GetGameResultFlags()
{
	return file.gameResultFlags
}

void function Survival_SetGameScoreFlags( int flags )
{
	file.gameScoreFlags = flags
}

int function Survival_GetGameScoreFlags()
{
	return file.gameScoreFlags
}

