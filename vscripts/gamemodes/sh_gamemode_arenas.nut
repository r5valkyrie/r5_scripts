global function Sh_Arenas_ItemRegistrationInit
global function ShGamemodeArenas_Init
global function ShArenas_RegisterNetworking

global function GameMode_GetWinBy2MinScore
global function GameMode_GetWinBy2MaxTies

global function Arenas_SharedInit
#if SERVER
global function Arenas_ServerInit
#endif
#if CLIENT
global function Arenas_ClientInit
#endif


#if(DEV)

//
#if(CLIENT)
global function TestApexLogo
global function TestAshRoom
global function Arenas_DevPostRoundSummary
#elseif(false)

#endif

#endif //

#if(CLIENT)
global function ServerCallback_EnableDeathScreenBanner
global function ServerCallback_DisplayArenasPrematch
global function ServerCallback_DisplayRoundLost
global function ServerCallback_DisplayRoundWon
global function ServerCallback_Arenas_AnnounceResourcesCollected
global function ServerCallback_Arenas_UpdateAirdropPreview
global function ServerCallback_Arenas_AnnounceRoundStart
global function Arenas_PopulatePrematchInfoRui
global function Arenas_PopulatePlayerLoadouts
global function Arenas_GetPurchasedItemRui
global function Arenas_GetNumPurchasedItemRuis
global function Arenas_GetTeammatePurchasedItemRuis
global function Arenas_GetTeammatePurchasedItemRuiIndex
global function Arenas_OnBuyMenuOpen
global function Arenas_OnBuyMenuClose
//global function Arenas_GetArenaSquadClubName // clubs not available in R5V
global function UICallback_Arenas_UpdateCash

#if(DEV)
global function PupulateGamestatePlayerData //
global function TriggerShrinkAnim
#endif
#endif

#if(false)




#endif

global function Arenas_GetOpposingTeam
global function Arenas_GetCashAmountForRound
global function Arenas_GetTeamWins
global function Arenas_IsMatchComplete
global function Arenas_IsFinalRound
global function IsArenaMode

#if(CLIENT)
const asset LOOT_BIN_ICON = $"rui/hud/ping/icon_arenas_loot_bin"
#endif

global const int ARENAS_BACKGROUND_SKIN_INDEX = 20

const float ROUND_SUMMARY_FADE_FROM_BLACK_DURATION = 0.35
const float ROUND_SUMMARY_INTRO_DURATION = 2.5
const float ROUND_SUMMARY_OUTRO_DURATION = 1.5
const float ROUND_SUMMARY_DURATION = ROUND_SUMMARY_INTRO_DURATION + ROUND_SUMMARY_OUTRO_DURATION
const float ARENAS_INTRO_DELAY = 2.2
const float ASH_ROUND_SUMMARY_ASH_HOLD_TIME = 1.933

const int MAX_PURCHASE_RUIS = 5

const string ARENAS_AIRDROP_ANIMATION = "droppod_loot_drop_lifeline"
const float ARENAS_AIRDROP_DELAY = 20.0

const float ROUND_START_COMMENTARY_DELAY = ROUND_SUMMARY_DURATION + 2.0
const float ARENAS_MATCHEND_COMMENTARY_DEALY = 2.0
const float ARENAS_ROUNDSTART_BC_DELAY = 4.0
const float ARENAS_ROUNDEND_DELAY = 2.75
const float ARENAS_ROUNDEND_BC_DELAY = 2.0
const float ARENAS_ONKILL_BC_DELAY = 3.0

const float ARENAS_DEFAULT_MINIMAP_ZOOM = 2.0
const float ARENAS_PREMATCH_MINIMAP_ZOOM = 3.0

const string ARENAS_ASH_EMITTER_SCRIPT_NAME				= "Arenas_Spawnroom_Emit_Ash_Hologram"
const string ARENAS_SPAWNROOMWALL_EMITTER_SCRIPT_NAME	= "arenas_spawnroomwall_emitter"
const string ARENAS_SPAWNROOMWALL_SOUND_EVENT_NAME		= "Arena_SpawnRoom_Emit_BoundaryWall"
const string ARENAS_SPAWNROOMWALL_DISSOLVE_SOUND		= "arenas_spawnroomwall_dissolve"

const string ARENAS_SPAWNROOM_TIMER			= "ui_arenas_spawnroomtimer"		//
const string ARENAS_SPAWNROOM_TIMER_URGENT	= "ui_arenas_spawnroomtimer_urgent" //
const string ARENAS_SPAWNROOM_TIMER_END		= "ui_arenas_spawnroomtimer_end"	//

const string SOUND_ROUND_WON_ANNOUNCE = "UI_InGame_RoundWin"
const string SOUND_ROUND_WON_SUB_TEXT_ANNOUNCE = "UI_InGame_RoundWin_Perfect"
const string SOUND_ROUND_SUMMARY_ROUND_END = "UI_InGame_RoundSummary"
const string SOUND_ROUND_SUMMARY_NEXT_ROUND = "UI_InGame_NextRound"
const string SOUND_ROUND_SUMMARY_SUDDEN_DEATH = "UI_InGame_SuddenDeath"
const string SOUND_ROUND_SUMMARY_TIEBREAKER = "UI_InGame_TieBreaker"

struct FightStruct
{
	int leftTeam = -1
	int rightTeam = -1
	Point& leftPosition
	Point& rightPosition
	bool fightComplete = false
	int realm = eRealms.DEFAULT
}

struct ArenaLocationData
{
	array<Point> spawnPoints
	array<vector> circleEndPoints
	float circleStartRadius
	array<float> circleStagesRadius
	float minimapDefaultZoom //
	array<float> minimapZoomScales
	array<Point> introCameras
}

struct TeamMatchData
{
	bool isComeback = false
	bool isPerfectMatch = true
}

struct PlayerStateData
{
	int tacAmmo 	= 0
	int tacStockpile 	= 0
	int ultAmmo		= 0
	int passiveCharges = 0
	string weapon0	= ""
	string weapon1	= ""

	bool firstSpawn = true
	bool hasBeenPositioned = false
}

struct PlayerRoundData
{
	bool hasBeenDamaged = false
	bool hasBeenDowned = false
	int killCount = 0
	int savedCash = 0
	int capturedHarvestors = 0
	bool hasPlayedDoubleKillVO = false
}

struct InvalidEndZone
{
	vector position
	float radius
}

global enum eArenasRoundStartAnnounce
{
	ROUND_NUM,
	MATCHPOINT_ENEMY,
	MATCHPOINT_YOU,
	TIEBREAKER,
	SUDDEN_DEATH,
}

global enum eArenasRoundWonDescriptor
{
	DEFAULT,
	PERFECT,
	FLAWLESS,
	CLUTCH,

	MAX_COUNT
}

struct {
	#if(false)





























#endif

	#if(CLIENT)
		int lastRoundUpdated = -1
		int startStreak
		var arenasScoreRui
		var roundStartRui
		bool useCustomArenasWinnerScreen
		array<var> weaponPurchaseRuis
		table<entity,var> teammatePurchaseRuis
		table<entity,int> teammateIndex
		bool areBuyMenuCallBacksRegistered = false
		int lastRoundKills = 0
		int lastRoundSavedCash = 0
		int lastRoundCanisters = 0

		//
		int roomSparks = -1
		entity bgModel
		bool inAshRoom = false
		bool hasEnteredBuyPhase = false
		bool charSelectMenuClosed = false
		int ashParticle = -1
		var waitingOverlay = null
	#if(DEV)
		bool devBuyMenu = false
	#endif

		//table<int, string> clubNames // clubs not available in R5V
	#endif
} file

const asset ARENAS_ASH = $"P_arena_menu_ash_CP"
const asset ARENAS_LOGO = $"P_menu_arena_logo"
const asset ARENAS_ROOM_SPARKS = $"P_menu_arena_BG_embers_fall"
//
//
const vector ARENAS_ROOM_SPARKS_COLOR = <255, 124, 60>
const vector ARENAS_ASH_COLOR_DEFAULT = <206, 255, 245>
const vector ARENAS_ASH_COLOR_COOL = <120, 199, 255>
const vector ARENAS_ASH_COLOR_WARM = <240, 70, 70>
const float ARENAS_ASH_SHOP_UP_OFFSET = 55.0
const float ARENAS_ASH_SUMMARY_UP_OFFSET = 68.0
const float ARENAS_ASH_SHOP_SIDE_OFFSET = -65.0
const float ARENAS_ASH_SHOP_ROTATE = -30.0

const asset HOLOGRAM_FX_LOGO = $"P_holospray_arenas_logo"
const asset HOLOGRAM_FX_ASH = $"P_holo_ash_readyroom"
const asset HOLOGRAM_FX_PROJECTOR = $"P_arenas_holo_projector"

const asset ARENAS_MUSICPACK = $"settings/itemflav/musicpack/arenas_default.rpak"

void function Sh_Arenas_ItemRegistrationInit()
{
	AddCallback_RegisterRootItemFlavors( OnRegisterRootItemFlavors )
}

void function ShGamemodeArenas_Init()
{
#if(false)

#endif


	if ( !IsArenaMode() )
	{
	#if(false)












#endif
		return
	}

#if(false)







//
//














//


//



//

//
//
//
//
//

#endif

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	PrecacheParticleSystem( ARENAS_ASH )
	PrecacheParticleSystem( ARENAS_ROOM_SPARKS )
	PrecacheParticleSystem( ARENAS_LOGO )
	PrecacheParticleSystem( HOLOGRAM_FX_ASH )
	PrecacheParticleSystem( HOLOGRAM_FX_PROJECTOR )
	PrecacheParticleSystem( HOLOGRAM_FX_LOGO )

	RegisterDisabledBattleChatterEvents(
		[ "bc_anotherSquadAttackingUs",
		"bc_engagingEnemy",
		"bc_squadsLeft2 ",
		"bc_squadsLeft3 ",
		"bc_squadsLeftHalf",
		"bc_twoSquaddiesLeft",
		"bc_championEliminated",
		"bc_killLeaderNew",
		"bc_scatteredNag",
		"bc_firstBlood",
		"bc_weTookFirstBlood",]
	)

#if(false)

//
//




































//














//
//































































#elseif CLIENT
	RegisterSignal( "GameStateChanged" )
	RegisterSignal( "Arenas_WaitFullyConnected" )

	PakHandle pakHandle = RequestPakFile( "arenas" )

	SetCustomScreenFadeAsset( $"ui/screen_fade_arenas.rpak" )
	ClApexScreens_SetCustomApexScreenBGAsset( $"rui/rui_screens/banner_c_arenas" )
	ClApexScreens_SetCustomLogoTint( <1.0, 1.0, 1.0> )
	ClApexScreens_SetCustomLogoImage( $"rui/rui_screens/arenas_logo" )
	ClApexScreens_SetCustomLogoSize( <640,640,0> )
	ClApexScreens_SetAnimatedLogoAsset( $"ui/arenas_logo_glitch.rpak" )

	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, ClSurvivalArenas_OnWaitingForPlayers )
	AddCallback_GameStateEnter( eGameState.Prematch, CLSurvivalArenas_OnPrematch )
	AddCallback_GameStateEnter( eGameState.Playing, ClSurvivalArenas_OnPlaying )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, ClSurvivalArenas_OnWinnerDetermined )
	AddCallback_ShouldRunCharacterSelection( ShouldShowCharacterSelection )
	AddCallback_OnClientScriptInit( void function( entity player ) : ()
	{
		SetGameModeScoreBarUpdateRulesWithFlags( GameModeScoreBarRules, sbflag.SKIP_STANDARD_UPDATE )
		if ( GetGameState() < eGameState.Playing )
		{
			if ( file.waitingOverlay != null )
			{
				RuiDestroyIfAlive( file.waitingOverlay )
				file.waitingOverlay = null
			}
			file.waitingOverlay = CreatePermanentCockpitRui( $"ui/waiting_for_players_blackscreen.rpak", -1 )
			RuiSetResolutionToScreenSize( file.waitingOverlay )
			RuiSetBool( file.waitingOverlay, "isOpaque", true )
		}
	} )
	SURVIVAL_SetGameStateAssetOverrideCallback( ArenasOverrideGameState )

	Survival_SetVictorySoundPackageFunction( GetVictorySoundPackage )
	SetChampionScreenRuiAssetExtraFunc( Arenas_VictoryScreen )
	SetPreVictoryScreenCallback( OnPreVictory )
	DeathScreenSetBannerEnabled( false )
	RegisterMinimapPackages()
	AddCallback_OnCharacterSelectBackgroundCreated( OnCharacterSelectBackgroundCreated )
	AddCallback_OnCharacterSelectModelChanged( OnCharacterSelectModelChanged )
	AddCallback_OnCharacterSelectUpdateLights( OnCharacterSelectUpdateLights )
	AddCallback_OnCharacterSelectMenuClosed( OnCharacterSelectMenuClosed )

	//
	AddCallback_OnScoreboardCreated( ClSurvivalArenas_OnScoreboardCreated )
	AddCreateCallback( "player", ClSurvivalArenas_OnPlayerCreated )
	AddCallback_OnPlayerChangedTeam( ClSurvivalArenas_OnPlayerTeamChanged )
	AddCallback_PlayerClassChanged( ClSurvivalArenas_OnPlayerClassChanged )
	AddOnSpectatorTargetChangedCallback( ClSurvivalArenas_OnSpectatorTargetChanged )
	AddCallback_OnViewPlayerChanged( ClSurvivalArenas_OnViewPlayerChanged )

	AddScoreboardShowCallback( Arenas_OnScoreboardShow )
	AddScoreboardHideCallback( Arenas_OnScoreboardHide )

	AddClientCallback_OnResolutionChanged( Arenas_OnResolutionChanged )

	RegisterConCommandTriggeredCallback( "+use", UsePressed )
#endif

	ShGamemodeArenasBuySystemV2_Init()
	ShArenasPostRoundSummary_Init()
	ShCashStation_Init()
}

void function OnRegisterRootItemFlavors()
{
 	ItemFlavor ornull musicPack = RegisterItemFlavorFromSettingsAsset( ARENAS_MUSICPACK )
}

void function ShArenas_RegisterNetworking()
{
	if ( IsLobby() )
		return

	if ( !IsArenaMode() )
	{
		return
	}
	// Remote functions and base netvars already registered in _remote_functions_mp.gnut
	// roundsPlayed needs to be a networked variable for client RUI tracking
	RegisterNetworkedVariable( "roundsPlayed", SNDC_GLOBAL, SNVT_INT, 0 )

	// Buy system netvars not covered in _remote_functions_mp.gnut
	ShArenasBuy_RegisterNetworkingV2()
}

// R5V init entry points
void function Arenas_SharedInit()
{
	ShGamemodeArenas_Init()
}

#if SERVER
void function Arenas_ServerInit()
{
	Arenas_ServerGamemode_Init()
}
#endif

#if CLIENT
void function Arenas_ClientInit()
{
	// Client initialization is handled inside ShGamemodeArenas_Init()
}
#endif

// R5V: WinBy2 system not present in R5V gamemodes framework
// Arenas needs 3 round wins, win-by-2 until 2 ties, then sudden death
const int ARENAS_WIN_BY_2_MIN_SCORE = 3
const int ARENAS_WIN_BY_2_MAX_TIES  = 2

int function GameMode_GetWinBy2MinScore( string gameMode )
{
	return ARENAS_WIN_BY_2_MIN_SCORE
}

int function GameMode_GetWinBy2MaxTies( string gameMode )
{
	return ARENAS_WIN_BY_2_MAX_TIES
}

void function EntitiesDidLoad()
{
	SurvivalCommentary_SetHost( eSurvivalHostType.ARENAS )

#if(false)












































#endif

#if(CLIENT)
	array<entity> jumpTowerFlags = GetEntArrayByScriptName( "jump_tower_flag" )
	foreach( flag in jumpTowerFlags )
		flag.Destroy()
#endif
}

#if(false)























































































































//
//
//

//























































































//
//


























































































































//















//


































































































//


































































































//




























































































//


























//













































//










































//






















//


























//











































//


































//



















































































































































//
//
//
//
//
//











































































































































































//








































































//












































































































#endif //

#if(CLIENT)
void function Arenas_CreateWaitingOverlay()
{
	if ( file.waitingOverlay != null )
	{
		RuiDestroyIfAlive( file.waitingOverlay )
		file.waitingOverlay = null
	}

	file.waitingOverlay = CreatePermanentCockpitRui( $"ui/waiting_for_players_blackscreen.rpak", -1 )
	RuiSetResolutionToScreenSize( file.waitingOverlay )
	RuiSetBool( file.waitingOverlay, "isOpaque", true )
}

void function ClSurvivalArenas_OnWaitingForPlayers()
{
	Arenas_CreateWaitingOverlay()
}

void function CLSurvivalArenas_OnPrematch()
{
	// Destroy the waiting for players overlay
	if ( file.waitingOverlay != null )
	{
		RuiDestroyIfAlive( file.waitingOverlay )
		file.waitingOverlay = null
	}

	// Close the character select menu if it's still open from PickLoadout.
	// The squad/champion presentations leave the menu open (footer bars, camera,
	// background model). In BR the dropship takes over, but arenas needs explicit cleanup.
	// Only do this once, and only if character select actually ran.
	if ( !file.charSelectMenuClosed && Survival_CharacterSelectEnabled() )
	{
		file.charSelectMenuClosed = true
		CloseCharacterSelectNewMenu()
	}

	entity viewPlayer = GetLocalViewPlayer()
	RefreshUnitframesForPlayer( viewPlayer )

	clGlobal.levelEnt.Signal( "AnnoucementPurge" )
}

void function ClSurvivalArenas_OnPlaying()
{
	// Safety cleanup of waiting overlay in case Prematch was skipped
	if ( file.waitingOverlay != null )
	{
		RuiDestroyIfAlive( file.waitingOverlay )
		file.waitingOverlay = null
	}

	__DestroyRoundRuis()

	// Only play the timer-end sound when transitioning from a buy phase to combat.
	// The initial Playing state entry from onboarding should not trigger this.
	if ( file.hasEnteredBuyPhase )
		EmitSoundOnEntity( GetLocalClientPlayer(), ARENAS_SPAWNROOM_TIMER_END )
}

void function ClSurvivalArenas_OnWinnerDetermined()
{
	int winningTeam = GetWinningTeam()
	printt( "[Arenas Client] WinnerDetermined - winningTeam:", winningTeam )

	entity clientPlayer = GetLocalClientPlayer()
	if ( !IsValid( clientPlayer ) )
		return

	ShowChampionVictoryScreen( winningTeam )
}

void function __DestroyRoundRuis()
{
	file.weaponPurchaseRuis.clear()

	file.teammatePurchaseRuis.clear()
	file.teammateIndex.clear()

	if ( file.roundStartRui != null )
	{
		RuiDestroyIfAlive( file.roundStartRui )
		file.roundStartRui = null
	}
}

var function Arenas_GetPurchasedItemRui( int index )
{
	if ( index >= file.weaponPurchaseRuis.len() )
		return null

	return file.weaponPurchaseRuis[index]
}

int function Arenas_GetNumPurchasedItemRuis( )
{
	return file.weaponPurchaseRuis.len()
}

var function Arenas_GetTeammatePurchasedItemRuis( entity player )
{
	if ( player in file.teammatePurchaseRuis )
		return file.teammatePurchaseRuis[ player ]

	return null
}

int function Arenas_GetTeammatePurchasedItemRuiIndex( entity player )
{
	if ( player in file.teammateIndex )
		return file.teammateIndex[ player ]

	return -1
}

void function ServerCallback_DisplayArenasPrematch( int leftTeam, int rightTeam, int savedCash, int kills, int canisters )
{
	printt( "[Arenas Client] ServerCallback_DisplayArenasPrematch - leftTeam:", leftTeam, "rightTeam:", rightTeam, "savedCash:", savedCash, "kills:", kills, "canisters:", canisters )
	printt( "[Arenas Client] roundsPlayed:", GetRoundsPlayed(), "gameStartTime:", GetGameStartTime() )

	file.lastRoundKills = kills
	file.lastRoundSavedCash = savedCash
	file.lastRoundCanisters = canisters

	if( GetRoundsPlayed() == 0 )
	{
		printt( "[Arenas Client] First round - showing buy menu with intro delay" )
		thread Arenas_ShowBuyMenu( leftTeam, rightTeam, false, ARENAS_INTRO_DELAY )
	}
	else
	{
		int lastWonTeam = GetGlobalNetInt( "arenas_lastWonTeam" )
		int localPlayerTeam = GetLocalClientPlayer().GetTeam()
		bool roundWon = ( lastWonTeam == localPlayerTeam )
		printt( "[Arenas Client] Round > 0 - showing post-round summary, lastWonTeam:", lastWonTeam, "localPlayerTeam:", localPlayerTeam, "roundWon:", roundWon )
		thread Arenas_ShowPostRoundSummary( leftTeam, rightTeam, roundWon )
	}
}

void function UICallback_Arenas_UpdateCash( var panel )
{
	if ( panel == null )
		return

	entity localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) )
		return

	int cash = localPlayer.GetPlayerNetInt( "arenas_current_cash" )
	printt( "[Arenas Client] UICallback_Arenas_UpdateCash - cash:", cash, "roundNum:", GetRoundsPlayed() )

	var rui = Hud_GetRui( panel )
	RuiSetInt( rui, "cash", cash )
	RuiSetInt( rui, "savedMaterials", file.lastRoundSavedCash )
	RuiSetInt( rui, "kills", file.lastRoundKills )
	RuiSetInt( rui, "canisters", file.lastRoundCanisters )
	RuiSetInt( rui, "roundNum", GetRoundsPlayed() )
	RuiSetInt( rui, "killAmount", GetCurrentPlaylistVarInt( "arenas_kill_reward", ARENAS_KILL_REWARD ) )
	RuiSetInt( rui, "canisterAmount", GetCurrentPlaylistVarInt( "arenas_cash_station_small_reward", ARENAS_CANISTER_REWARD ) )
	RuiSetInt( rui, "nextRoundMaterials", Arenas_GetCashAmountForRound( GetRoundsPlayed() ) )
}

void function Arenas_ShowBuyMenu( int leftTeam, int rightTeam, bool playIntroTransition, float delay = 0.0 )
{
	printt( "[Arenas Client] ShowBuyMenu called, delay:", delay, "playIntro:", playIntroTransition )
	if ( delay > 0 )
		wait delay

	float endTime = GetGameStartTime()
	printt( "[Arenas Client] ShowBuyMenu - endTime from GetGameStartTime():", endTime, "currentTime:", Time() )

	#if(DEV)
	if ( file.devBuyMenu )
	{
		endTime = Time() + 6.0
	}
	#endif

	thread _PlayCountdownTimerSFX( endTime )

	// Ensure the ash room is set up before spawning effects.
	// Creates camera, character models, and background entities.
	if ( !file.inAshRoom )
		SetupAshRoom()

	Arenas_OpenBuyMenu( endTime, playIntroTransition )
	SpawnAsh( ARENAS_ASH_COLOR_DEFAULT, ARENAS_ASH_SHOP_UP_OFFSET, ARENAS_ASH_SHOP_SIDE_OFFSET, ARENAS_ASH_SHOP_ROTATE )
	UpdateBackgroundViaFunc( UpdateMenuBackground )

	__DestroyRoundRuis()

	var rui = CreateFullscreenRui( $"ui/arenas_intro.rpak", 500 )
	file.roundStartRui = rui

	RunUIScript( "ClientToUI_Arenas_SetRoundNumber", GetRoundsPlayed() + 1 )
	Arenas_PopulatePrematchInfoRui( rui, leftTeam, rightTeam )
	if( playIntroTransition )
		RuiSetBool( file.roundStartRui, "startTransition", true )
}

void function _PlayCountdownTimerSFX( float endTime )
{
	const float startTimer		 = 10.0 //
	const float startUrgentTimer = 5.0  //
	float totalShopTime = endTime - Time()

	wait totalShopTime - startTimer

	EmitSoundOnEntity( GetLocalClientPlayer(), ARENAS_SPAWNROOM_TIMER )

	wait startTimer - startUrgentTimer

	EmitSoundOnEntity( GetLocalClientPlayer(), ARENAS_SPAWNROOM_TIMER_URGENT )
}

void function SetupAshRoom()
{
	EffectStop( file.roomSparks, true, true )
	file.roomSparks = -1

	file.inAshRoom = true
	CharacterSelect_EnsureMenuEntsReady()
	CreateCharacterSelectClientEnts()
	SetCharacterSelectSceneForChampionSquad()
	UpdateCamera()
}

void function _UpdateRoundSummaryAshEffect( bool roundWon )
{
	EffectStop( file.ashParticle, true, true )

	wait ROUND_SUMMARY_FADE_FROM_BLACK_DURATION

	SpawnAsh( roundWon ? ARENAS_ASH_COLOR_COOL : ARENAS_ASH_COLOR_WARM, ARENAS_ASH_SUMMARY_UP_OFFSET, 0.0, 0.0 )

	wait ASH_ROUND_SUMMARY_ASH_HOLD_TIME

	EffectStop( file.ashParticle, false, true )
}

void function _PlayerRoundSummaryAudio( bool isTied )
{
	wait ROUND_SUMMARY_FADE_FROM_BLACK_DURATION

	EmitSoundOnEntity( GetLocalClientPlayer(), SOUND_ROUND_SUMMARY_ROUND_END )

	wait ROUND_SUMMARY_INTRO_DURATION

	if( Arenas_IsFinalRound() )
		EmitSoundOnEntity( GetLocalClientPlayer(), SOUND_ROUND_SUMMARY_SUDDEN_DEATH )
	else if( isTied )
		EmitSoundOnEntity( GetLocalClientPlayer(), SOUND_ROUND_SUMMARY_TIEBREAKER )
	else
		EmitSoundOnEntity( GetLocalClientPlayer(), SOUND_ROUND_SUMMARY_NEXT_ROUND )
}

void function Arenas_ShowPostRoundSummary( int leftTeam, int rightTeam, bool roundWon )
{
	SetupAshRoom()

	float endTime = GetGameStartTime() - GetShopDuration()

	#if(DEV)
	if ( file.devBuyMenu )
	{
		endTime = Time() + 5.0
	}
	#endif

	Arenas_OpenPostRoundSummary( leftTeam, rightTeam, endTime )

	thread _UpdateRoundSummaryAshEffect( roundWon )
	thread _PlayerRoundSummaryAudio( Arenas_IsTiebreakerRound( leftTeam, rightTeam ) )

	while ( Time() < endTime )
		WaitFrame()

	thread Arenas_ShowBuyMenu( leftTeam, rightTeam, true )
}

void function Arenas_PopulatePrematchInfoRui( var rui, int leftTeam, int rightTeam )
{
	RuiSetInt( rui, "leftTeamScore", Arenas_GetTeamWins( leftTeam ) )
	RuiSetInt( rui, "rightTeamScore", Arenas_GetTeamWins( rightTeam ) )
	RuiSetInt( rui, "maxScore", GameMode_GetWinBy2MinScore( GameRules_GetGameMode() ) )
	RuiSetInt( rui, "numTies", GetGlobalNetInt( "arenas_numties" ) )
	RuiSetInt( rui, "maxTies", GameMode_GetWinBy2MaxTies( GameRules_GetGameMode() ) )
	RuiSetInt( rui, "roundNum", GetRoundsPlayed() )
	RuiSetBool( rui, "roundWon", GetGlobalNetInt( "arenas_lastWonTeam" ) == GetLocalClientPlayer().GetTeam() )

	float gameStartTime = GetGameStartTime()
	float shopDuration = GetShopDuration()
	printt( "[Arenas Client] PopulatePrematchInfoRui - gameStartTime:", gameStartTime, "shopDuration:", shopDuration, "startTime:", gameStartTime - shopDuration, "currentTime:", Time() )
	RuiSetGameTime( rui, "startTime", gameStartTime - shopDuration )
	RuiSetGameTime( rui, "endTime", gameStartTime )

	{
		array<entity> teamPlayers = GetPlayerArrayOfTeam( leftTeam )
		Arenas_PopulateTeamRuis( rui, leftTeam, teamPlayers, "L" )
	}

	{
		array<entity> teamPlayers = GetPlayerArrayOfTeam( rightTeam )
		Arenas_PopulateTeamRuis( rui, rightTeam, teamPlayers, "R" )
	}
}

void function Arenas_PopulateSquadmateWeapons( var rui, entity player )
{
	for( int weaponIndex = 0; weaponIndex < 2; ++weaponIndex )
	{
		RuiSetBool( rui, "showWeapon" + weaponIndex, false )

		entity weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 + weaponIndex )
		if( !IsValid( weapon ) )
			continue

		string weaponRef = GetWeaponClassNameWithLockedSet( weapon )
		if ( !SURVIVAL_Loot_IsRefValid( weaponRef ) )
			continue

		LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
		int tier = weaponRef == weapon.GetWeaponClassName() ? 0 : weaponData.tier

		RuiSetBool( rui, "showWeapon" + weaponIndex, true )
		RuiSetImage( rui, "weapon" + weaponIndex + "Image", weaponData.hudIcon )
		RuiSetInt( rui, "weapon" + weaponIndex + "Tier", tier )
	}
}

void function Arenas_PopulatePlayerLoadouts( var playerRui, array<var> squadmateRuis )
{
	entity player = GetLocalClientPlayer()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

	RuiSetBool( playerRui, "show", true )
	RuiSetBool( playerRui, "isLocalPlayer", true )
	RuiSetImage( playerRui, "playerPortrait", CharacterClass_GetGalleryPortrait( character ) )
	RuiSetImage( playerRui, "backgroundImage", CharacterClass_GetGalleryPortraitBackground( character ) )
	RuiSetInt( playerRui, "teamMemberIndex", player.GetTeamMemberIndex() )
	RuiSetString( playerRui, "playerName", player.GetPlayerName() )

	Arenas_PopulateSquadmateWeapons( playerRui, player )

	array<entity> squadmateArray = GetPlayerArrayOfTeam( player.GetTeam() )
	squadmateArray.fastremovebyvalue( player )

	for( int i = 0; i < squadmateRuis.len(); ++i )
	{
		if( i >= squadmateArray.len() || !IsValid( squadmateArray[i] ) )
		{
			RuiSetBool( squadmateRuis[i], "show", false )
			RuiSetBool( squadmateRuis[i], "isLocalPlayer", false )
			continue
		}

		character = LoadoutSlot_GetItemFlavor( ToEHI( squadmateArray[i] ), Loadout_Character() )

		RuiSetBool( squadmateRuis[i], "show", true )
		RuiSetBool( squadmateRuis[i], "isLocalPlayer", false )
		RuiSetBool( squadmateRuis[i], "isSquadmate", true )
		RuiSetImage( squadmateRuis[i], "playerPortrait", CharacterClass_GetGalleryPortrait( character ) )
		RuiSetImage( squadmateRuis[i], "backgroundImage", CharacterClass_GetGalleryPortraitBackground( character ) )
		RuiSetInt( squadmateRuis[i], "teamMemberIndex", squadmateArray[i].GetTeamMemberIndex() )
		RuiSetString( squadmateRuis[i], "playerName", squadmateArray[i].GetPlayerName() )

		Arenas_PopulateSquadmateWeapons( squadmateRuis[i], squadmateArray[i] )
	}
}

void function _AnnounceMessageSweepAfterDelay( string message, vector color, float duration, float delay )
{
	wait delay

	AnnouncementMessageSweep( GetLocalClientPlayer(), message, "", color, $"", SFX_HUD_ANNOUNCE_QUICK, duration )
}

void function _AnnounceMessageRoundStartAfterDelay( string main, string subtext, vector color, float duration, float delay )
{
	wait delay

	AnnouncementData announcement = Announcement_Create( main )
	Announcement_SetOptionalTextArgsArray( announcement, [ subtext ] )
	announcement.announcementStyle = ANNOUNCEMENT_STYLE_CIRCLE_WARNING
	announcement.icon = $""
	//
	announcement.duration = duration
	announcement.drawOverScreenFade = true
	announcement.purge = true

	AnnouncementFromClass( GetLocalClientPlayer(), announcement )
}

void function _AnnounceMessageRoundWonAfterDelay( int roundWonDesc, vector color, float duration, float delay )
{
	if ( delay > 0 )
		wait delay

	string message = Localize( "#ARENAS_ROUND_WON" )

	switch( roundWonDesc )
	{
		case eArenasRoundWonDescriptor.PERFECT:
			//
			//
			message = Localize( "#ARENAS_ROUND_PERFECT" )
			break

		case eArenasRoundWonDescriptor.CLUTCH:
			//
			//
			message = Localize( "#ARENAS_ROUND_CLUTCH" )
			break

		case eArenasRoundWonDescriptor.FLAWLESS:
			//
			//
			message = Localize( "#ARENAS_ROUND_FLAWLESS" )
			break
	}

	AnnouncementData announcement = Announcement_Create( message )
	announcement.subText = ""
	announcement.announcementStyle = ANNOUNCEMENT_STYLE_ROUND_WON
	announcement.soundAlias = SOUND_ROUND_WON_ANNOUNCE
	announcement.icon = $""
	announcement.duration = duration
	announcement.drawOverScreenFade = true
	announcement.priority = 1000
	announcement.purge = true

	clGlobal.levelEnt.Signal( "AnnoucementPurge" )

	AnnouncementFromClass( GetLocalClientPlayer(), announcement )
}

void function ServerCallback_DisplayRoundLost()
{
	if ( IsViewingDeathScreen() )
		SwitchDeathScreenTab( eDeathScreenPanel.SPECTATE )

	thread _AnnounceMessageSweepAfterDelay( Localize( "#ARENAS_ROUND_LOST" ), <220,220,220>, 5.0, 0.0 )
}

void function ServerCallback_DisplayRoundWon( int roundWonDesc )
{
	if ( IsViewingDeathScreen() )
		SwitchDeathScreenTab( eDeathScreenPanel.SPECTATE )

	thread _AnnounceMessageRoundWonAfterDelay( roundWonDesc, <220,220,220>, 5.0, 0.01 )
}

void function ServerCallback_Arenas_AnnounceResourcesCollected( int amount )
{
	AnnouncementMessageRight( GetLocalClientPlayer(), Localize( "#CRAFTING_HARVESTER_AWARD", amount ), "", <214,214,214>, $"", 2, "" )
}

void function ServerCallback_Arenas_UpdateAirdropPreview( int contentID0, int contentID1, int contentID2 )
{
	RunUIScript( "ClientToUI_Arenas_UpdateAirdropPreview", contentID0, contentID1, contentID2 )
}

void function ServerCallback_Arenas_AnnounceRoundStart( int announceStyle )
{
	string main = Localize( "#ARENAS_ROUND_NUM", string( GetRoundsPlayed() + 1 ) )
	string subtext = ""
	vector color = <200, 200, 200>

	switch( announceStyle )
	{
		case eArenasRoundStartAnnounce.MATCHPOINT_ENEMY:
			main = Localize( "#ARENAS_MATCH_POINT" )
			subtext = Localize( "#ARENAS_MATCH_POINT_ENEMY_SUBTEXT" )
			color = <255, 80, 80>
			break

		case eArenasRoundStartAnnounce.MATCHPOINT_YOU:
			main = Localize( "#ARENAS_MATCH_POINT" )
			subtext = Localize( "#ARENAS_MATCH_POINT_YOU_SUBTEXT" )
			color = <80, 200, 255>
			break

		case eArenasRoundStartAnnounce.TIEBREAKER:
			main = Localize( "#ARENAS_TIEBREAKER" )
			color = <255, 200, 50>
			break

		case eArenasRoundStartAnnounce.SUDDEN_DEATH:
			main = Localize( "#ARENAS_SUDDEN_DEATH" )
			subtext = Localize( "#ARENAS_SUDDEN_DEATH_SUBTEXT" )
			color = <255, 50, 50>
			break
	}

	thread _AnnounceMessageRoundStartAfterDelay( main, subtext, color, 5.0, 1.5 )
}

void function Arenas_OnScoreboardShow()
{
	if ( file.roundStartRui == null )
		return

	if ( !GetCurrentPlaylistVarBool( "fullmap_enabled", true ) )
		return

	RuiSetBool( file.roundStartRui, "isFullMapOpen", true )
}

void function Arenas_OnScoreboardHide()
{
	if ( file.roundStartRui == null )
		return

	RuiSetBool( file.roundStartRui, "isFullMapOpen", false )
}

void function Arenas_OnResolutionChanged()
{
	//

	entity player = GetLocalClientPlayer()
	if ( file.roundStartRui == null || !IsValid( player ) )
		return

	RuiDestroyIfAlive( file.roundStartRui )
	var rui = CreateFullscreenRui( $"ui/arenas_intro.rpak", 500 )
	file.roundStartRui = rui

	int leftTeam = player.GetTeam()
	int rightTeam = Arenas_GetOpposingTeam( player.GetTeam() )
	Arenas_PopulatePrematchInfoRui( rui, leftTeam, rightTeam )
}

void function Arenas_OnBuyMenuOpen( )
{
	file.hasEnteredBuyPhase = true

	// Destroy waiting for players overlay now that buy menu is visible
	if ( file.waitingOverlay != null )
	{
		RuiDestroyIfAlive( file.waitingOverlay )
		file.waitingOverlay = null
	}

	if( !file.inAshRoom )
		SetupAshRoom()
}

void function Arenas_OnBuyMenuClose( )
{
	WaitFrame()

	if( file.inAshRoom )
	{
		file.inAshRoom = false
		CharacterSelect_RestorePlayerView()
	}
}

bool function TryOpenInventoryMenu( entity player )
{
	if ( GetGameState() != eGameState.Prematch )
		return true

	HideScoreboard()
	OpenSurvivalInventory( player )

	return true
}

void function UsePressed( entity player )
{
	TryOpenBuyMenu()
}

void function TryOpenBuyMenu()
{
	if( GetGameState() != eGameState.Prematch )
		return

	float endTime = GetGameStartTime()
	if( Time() >= endTime - 0.1 )
		return

	if ( GetGlobalNetTime( "arenas_buyMenuStartTime" ) > Time() )
		return

	if ( !file.inAshRoom )
		SetupAshRoom()

	Arenas_OpenBuyMenu( endTime )
	SpawnAsh( ARENAS_ASH_COLOR_DEFAULT, ARENAS_ASH_SHOP_UP_OFFSET, ARENAS_ASH_SHOP_SIDE_OFFSET, ARENAS_ASH_SHOP_ROTATE )

	UpdateBackgroundViaFunc( UpdateMenuBackground )

	return
}

bool function ShouldShowCharacterSelection()
{
	return true
}

void function ArenasOverrideGameState()
{
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_arenas.rpak" )
	ClGameState_RegisterGameStateFullmapAsset( $"ui/gamestate_info_fullmap_arenas.rpak" )
}

void function ClSurvivalArenas_OnScoreboardCreated()
{
	var rui = ClGameState_GetRui()
	file.arenasScoreRui = RuiCreateNested( rui, "modeNestedHandle", $"ui/gamestate_arenas_nested.rpak" )

	RuiTrackInt( file.arenasScoreRui, "gamestate", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "gameState" ) )
	RuiTrackInt( file.arenasScoreRui, "numTies", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "arenas_numties" ) )
	RuiTrackInt( file.arenasScoreRui, "roundNum", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "roundsPlayed" ) )

	RuiSetInt( file.arenasScoreRui, "maxTies", GameMode_GetWinBy2MaxTies( GameRules_GetGameMode() ) ) //
	RuiSetInt( file.arenasScoreRui, "maxScore", GameMode_GetWinBy2MinScore( GameRules_GetGameMode() ) ) //

	PupulateGamestatePlayerData()
}

#if(DEV)
void function TriggerShrinkAnim()
{
	RuiSetFloat( file.arenasScoreRui, "triggerAnimTime", Time() )
}
#endif

void function ClSurvivalArenas_OnPlayerCreated( entity player )
{
	thread PupulateGamestate_WaitForFullyConnected( player )
}

void function ClSurvivalArenas_OnPlayerTeamChanged( entity player, int oldTeam, int newTeam )
{
	thread PupulateGamestate_WaitForFullyConnected( player )
}

void function ClSurvivalArenas_OnPlayerClassChanged( entity player )
{
	thread PupulateGamestate_WaitForFullyConnected( player )
}

void function ClSurvivalArenas_OnSpectatorTargetChanged( entity spectatingPlayer, entity prevSpectatorTarget, entity newSpectatorTarget )
{
	if ( IsValid( newSpectatorTarget ) )
		thread PupulateGamestate_WaitForFullyConnected( newSpectatorTarget )
}

void function ClSurvivalArenas_OnViewPlayerChanged( entity player )
{
	UpdateGamestateRuiTracking( GetLocalViewPlayer() )
	thread PupulateGamestate_WaitForFullyConnected( player )
}

void function PupulateGamestatePlayerData()
{
	Assert( file.arenasScoreRui != null )

	if ( GetLocalClientPlayer() == null )
		return //

	#if(DEV)
		//
		RuiTrackInt( file.arenasScoreRui, "gamestate", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "gameState" ) )
		RuiTrackInt( file.arenasScoreRui, "numTies", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "arenas_numties" ) )
		RuiTrackInt( file.arenasScoreRui, "roundNum", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "roundsPlayed" ) )
	#endif

	int currentTeam = GetLocalClientPlayer().GetTeam()
	int otherTeam = Arenas_GetOpposingTeam( currentTeam )

	PopulateFightRui( file.arenasScoreRui )

	array<entity> leftTeamPlayers = GetPlayerArrayOfTeam( currentTeam )
	Arenas_PopulateTeamRuis( file.arenasScoreRui, currentTeam, leftTeamPlayers, "L" )

	array<entity> rightTeamPlayers = GetPlayerArrayOfTeam( otherTeam )
	Arenas_PopulateTeamRuis( file.arenasScoreRui, otherTeam, rightTeamPlayers, "R" )
}

void function PupulateGamestate_WaitForFullyConnected( entity player )
{
	//

	Signal( player, "Arenas_WaitFullyConnected" )
	EndSignal( player, "Arenas_WaitFullyConnected" )

	EHI playerEHI = ToEHI( player )
	while ( !EHIHasValidScriptStruct( playerEHI ) )
		WaitFrame()
	LoadoutSlot_WaitForItemFlavor( playerEHI, Loadout_Character() )

	PupulateGamestatePlayerData()
}


void function GameModeScoreBarRules( var rui )
{
	if ( GetLocalViewPlayer() == null )
		return

	if ( file.lastRoundUpdated != GetRoundsPlayed() )
	{
		file.lastRoundUpdated = GetRoundsPlayed()
		PopulateFightRui( file.arenasScoreRui ) //
	}
}

void function PopulateFightRui( var rui )
{
	RuiSetInt( rui, "maxScore", GameMode_GetWinBy2MinScore( GameRules_GetGameMode() ) )

	int teamNum = 1
	int currentTeam = GetLocalClientPlayer().GetTeam()
	int otherTeam = Arenas_GetOpposingTeam( currentTeam )
	RuiSetBool( rui, "team" + teamNum + "MyTeam", true )
	RuiSetInt( rui, "score" + teamNum, Arenas_GetTeamWins( currentTeam ) )
	RuiSetString( rui, "teamName" + teamNum, GetTeamName( currentTeam ) )

	teamNum = 2
	RuiSetBool( rui, "team" + teamNum + "MyTeam", false )
	RuiSetInt( rui, "score" + teamNum, Arenas_GetTeamWins( otherTeam ) )
	RuiSetString( rui, "teamName" + teamNum, GetTeamName( otherTeam ) )
}

void function RegisterMinimapPackages()
{
	// Loot bin minimap disabled for now - causes registration order issue
	//RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.LOOT_BIN, MINIMAP_OBJECT_RUI, MinimapPackage_LootBin, FULLMAP_OBJECT_RUI, FullmapPackage_LootBin )
}

void function FullmapPackage_LootBin( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", LOOT_BIN_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetBool( rui, "hasSmallIcon", false )
}

void function MinimapPackage_LootBin( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", LOOT_BIN_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetBool( rui, "hasSmallIcon", false )
}
#endif

bool function Arenas_IsFinalRound()
{
	// R5V: GameState_IsFinalRound not available, check sudden death via ties
	int numTies = GetGlobalNetInt( "arenas_numties" )
	return numTies >= GameMode_GetWinBy2MaxTies( GameRules_GetGameMode() )
}

//
bool function Arenas_IsTiebreakerRound( int leftTeam, int rightTeam )
{
	int leftTeamScore = Arenas_GetTeamWins( leftTeam )
	int rightTeamScore = Arenas_GetTeamWins( rightTeam )
	return leftTeamScore == rightTeamScore && leftTeamScore + 1 >= GameMode_GetWinBy2MinScore( GameRules_GetGameMode() )
}

float function GetShopDuration()
{
	return GetCurrentPlaylistVarFloat( "arenas_shop_duration", 30.0 )
}

int function Arenas_GetCashAmountForRound( int round )
{
	int cash = GetCurrentPlaylistVarInt( "arenas_round_" + round + "_currency", -1 )
	if( cash != -1 )
		return cash

	switch ( round )
	{
		case 0:
			return 550
		case 1:
			return 800
		case 2:
			return 1150
		case 3:
			return 1500
		case 4:
			return 1750
		case 5:
			return 2000
		case 6:
			return 2150
		case 7:
			return 2300
		case 8:
			return 2500
		default:
			return 1800
	}

	unreachable
}

string function GetTeamName( int team )
{
	#if(CLIENT)
	if ( GetLocalViewPlayer().GetTeam() == team )
		return "My Team"
	else
		return "Enemy Team"
	#endif
	return "Team"
}

int function Arenas_GetTeamWins( int team )
{
	return GameRules_GetTeamScore2( team )
}

bool function IsArenaMode()
{
	return GameRules_GetGameMode() == GAMEMODE_ARENAS
}

#if(false)



















































//












































































//
























































//













//
//
//
//
//
//




#endif

#if(CLIENT)
VictorySoundPackage function GetVictorySoundPackage()
{
	VictorySoundPackage victorySoundPackage

	//
	//
	//
	//
	//
	//
	//
	//

	string winAlias = GetAnyDialogueAliasFromName( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.WINNER ) )

	victorySoundPackage.youAreChampPlural = winAlias
	victorySoundPackage.youAreChampSingular = winAlias
	victorySoundPackage.theyAreChampPlural = winAlias
	victorySoundPackage.theyAreChampSingular = winAlias

	return victorySoundPackage
}

void function OnPreVictory( bool onWinningTeam )
{

}

void function Arenas_VictoryScreen( var rui )
{
}

void function OnCharacterSelectBackgroundCreated( var bgRui )
{
	RuiSetImage( bgRui, "customShape", $"rui/rui_screens/arenas_logo" )

	if ( file.inAshRoom )
	{
		RuiSetFloat( bgRui, "gcardsStartTime", 1.0 )
		RuiSetFloat( bgRui, "customShapeAlpha", 0.0 )
	}
}

void function OnCharacterSelectModelChanged( ItemFlavor character, entity characterModel, entity backgroundModel, entity smokeModel, var backgroundRui )
{
	UpdateMenuBackground( backgroundModel, smokeModel, backgroundRui )
}

void function UpdateMenuBackground( entity backgroundModel, entity smokeModel, var backgroundRui )
{
	if ( IsValid( smokeModel ) )
		smokeModel.SetSkin( ARENAS_BACKGROUND_SKIN_INDEX )

	if ( IsValid( backgroundModel ) )
	{
		backgroundModel.SetSkin( ARENAS_BACKGROUND_SKIN_INDEX )
		file.bgModel = backgroundModel
	}
	else
	{
		Warning( "Arenas UpdateMenuBackground - background model is invalid!" )
		return
	}

	if ( file.roomSparks == -1 )
	{
		int pIndex = GetParticleSystemIndex( ARENAS_ROOM_SPARKS )
		file.roomSparks = StartParticleEffectInWorldWithHandle( pIndex, backgroundModel.GetOrigin(), AnglesCompose( backgroundModel.GetAngles(), <0,0,0> ) )
		EffectSetControlPointVector( file.roomSparks, 1, ARENAS_ROOM_SPARKS_COLOR )
	}
}

#if(DEV)
void function TestApexLogo()
{
	entity backgroundModel = GetEntByScriptName( "target_char_sel_bg_new" )
	vector fwd = AnglesToForward( backgroundModel.GetAngles() )
	vector origin = backgroundModel.GetOrigin() + <0,0,50> + ( -50 * fwd )

	int pIndex = GetParticleSystemIndex( ARENAS_LOGO )
	EffectStop( file.ashParticle, true, true )
	file.ashParticle = StartParticleEffectInWorldWithHandle( pIndex, origin, AnglesCompose( backgroundModel.GetAngles(), <0,0,0> ) )

	//
	//
	EffectSetControlPointVector( file.ashParticle, 1, ARENAS_ASH_COLOR_WARM )

	//
	EffectSetControlPointVector( file.ashParticle, 2, <0, 0, 0> )

}

void function TestAshRoom()
{
	file.inAshRoom = true
	CreateCharacterSelectClientEnts()
	SetCharacterSelectSceneForChampionSquad()
	UpdateCamera()
	SpawnAsh( ARENAS_ASH_COLOR_WARM, ARENAS_ASH_SHOP_UP_OFFSET, 0.0, 0.0 )
}
#endif

void function SpawnAsh( vector ashColor, float heightOffset, float sideOffset, float zRotation )
{
	entity backgroundModel = GetEntByScriptName( "target_char_sel_bg_new" )

	vector up = <0,0,1>
	vector fwd = AnglesToForward( backgroundModel.GetAngles() )
	vector side = CrossProduct( fwd, up )

	float forwardOffset = -20.0
	float forwardOffsetNX = 35.0
	
	vector origin = backgroundModel.GetOrigin() + ( heightOffset * up) + ( forwardOffset * fwd ) + ( sideOffset * side )
	vector newFwd = VectorRotateAxis( fwd, up, zRotation )
	
	int pIndex = GetParticleSystemIndex( ARENAS_ASH )
	EffectStop( file.ashParticle, true, true )
	file.ashParticle = StartParticleEffectInWorldWithHandle( pIndex, origin, AnglesCompose( VectorToAngles( newFwd ), <0,0,0> ) )

	EffectSetControlPointVector( file.ashParticle, 1, ashColor )
}

void function OnCharacterSelectUpdateLights( entity lightRig, entity key, entity fill, entity rimL, entity rimR )
{
	key.SetTweakLightColor( <0.996, 1, 0.808> )
	fill.SetTweakLightColor( <1, 0.549, 0.216> )
	rimL.SetTweakLightColor( <.85, 0.55, 0.25> )
	rimR.SetTweakLightColor( <0.263, 0.2, 0.161> )
}
#endif

#if(false)











































































#endif

#if(DEV)
#if(false)




#endif

#if(CLIENT)
void function Arenas_DevPostRoundSummary( bool won = true, int leftTeamScore = 1, int rightTeamScore = 0, int numTies = 0 )
{
	file.devBuyMenu = true
	Arenas_DevSetScoreSettings( leftTeamScore+rightTeamScore+1, leftTeamScore, rightTeamScore, numTies, won )
	thread Arenas_ShowPostRoundSummary( GP().GetTeam(), GP().GetTeam(), won )
}
#endif
#endif //

//
//
//
//
//
//
//
//
//

#if(CLIENT)
void function OnCharacterSelectMenuClosed()
{
	// Do NOT call SetupAshRoom() here. CloseCharacterSelectNewMenu() fires this
	// callback BEFORE DeleteMenuEntities(), so any entities created by SetupAshRoom
	// would be immediately destroyed while file.inAshRoom stays true.
	// The ash room is set up in Arenas_ShowBuyMenu() instead.
}

#endif

#if(CLIENT)
void function ServerCallback_EnableDeathScreenBanner()
{
	// R5V: DeathScreenSetBannerEnabled not available
}
#endif

int function Arenas_GetOpposingTeam( int myTeam )
{
	return GetOtherTeam( myTeam )
}

bool function Arenas_IsMatchComplete()
{
	return GetGlobalNetBool("roundScoreLimitComplete")
}