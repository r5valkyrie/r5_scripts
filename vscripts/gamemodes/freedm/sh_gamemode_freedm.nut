                       

global function FreeDM_GamemodeInitShared
global function FreeDM_GetOtherTeam
global function FreeDM_SetAudioEvent

#if DEVELOPER
#if SERVER
global function DEV_FreeDM_IncrementScore
global function DEV_FreeDM_EndMatch
#endif

#if CLIENT
global function DEV_ScoreTrackAnimateIn
#endif
#endif

#if SERVER
global function FreeDM_GamemodeInitServer
global function FreeDM_AddPlayerSecondaryScore
global function FreeDM_AddTeamScore

global function FreeDM_SetScoreEventRoundWinningKillReplayEnts
global function FreeDM_GetCurrentRank
global function FreeDM_SetCallback_ArmorRefOverride
global function FreeDM_GetSelectedLoadoutArmor
global function FreeDM_SetCallback_PostRespawnOverride
global function FreeDM_GetNumTeams
global function FreeDM_GivePlayerFullTactical
global function FreeDM_SetGameplayMusicFunction
global function FreeDM_SetGameplayMusicStartKillsLeft
global function FreeDM_SetMatchWinner
global function FreeDM_IsMatchWinnerDetermined
global function FreeDM_SetExcludedInfiniteAmmoWeaponTier
global function FreeDM_HasInfiniteAmmoOnAllWeapons
global function FreeDM_SetVOEndScoreDelta
#endif // SERVER

#if CLIENT
global function FreeDM_GamemodeInitClient
global function FreeDM_ScoreboardSetup
global function FreeDM_SetScoreboardSetupFunc
global function FreeDM_SetIsScoreText
global function FreeDM_SetDisplayScoreThread
global function FreeDM_SetCustomIndicatorCallBack
global function FreeDM_SetCharacterInfo
global function FreeDM_GetScoreboardData
global function FreeDM_SortPlayersByScore
global function FreeDM_GetPlayerScores
global function ServerCallback_FreeDM_AirdropNotification
global function ServerCallback_FreeDM_AnnounceRoundWonLost
global function ServerCallback_FreeDM_ChampionSounds
global function UICallback_FreeDM_OpenCharacterSelect
global function FreeDM_CloseCharacterSelect
global function ServerCallback_SetRespawnOverlay
#endif // CLIENT

const string FREEDM_SECONDARY_SCORE_NAME = "FreeDM_SecondaryPoints"
global const float FREEDM_MESSAGE_DURATION = 5.0
const float FREEDM_ROUND_WIN_ANNOUNCMENT_TIME = 2.0
const float FREEDM_POST_ROUND_SCOREBOARD_TIME = 3.0
const float FREEDM_COUNTDOWN_TIMER_SHRINK = 3.0
const int FREEDM_DEFAULT_MAX_PLAYERS = 0

const float FREEDM_INTRO_MUSIC_TIME            = 5.0
const float FREEDM_POST_ROUND_MUSIC_STOP_DELAY = 2.0
const int FREEDM_MUSIC_START_ON_KILLS_LEFT     = 5

#if SERVER
// Music thresholds against score
const float RAMPUP_MUSIC_SCORE_THRESHOLD_1 = 0.7
const float RAMPUP_MUSIC_SCORE_THRESHOLD_2 = 0.5
const float RAMPUP_MUSIC_SCORE_THRESHOLD_3 = 0.2
const float MUSIC_CONTROLLER_LEVEL_NOT_SET = -1.0
const float  MUSIC_CONTROLLER_LEVEL_4 = 200.0
const float  MUSIC_CONTROLLER_LEVEL_3 = 150.0
const float  MUSIC_CONTROLLER_LEVEL_2 = 100.0
const float  MUSIC_CONTROLLER_LEVEL_1 = 50.0
#endif // SERVER

const string FREEDM_MUSIC_GAMEPLAY = "Music_GunGame_Gameplay"
const string FREEDM_MUSIC_VICTORY  = "Music_GunGame_Victory"
const string FREEDM_MUSIC_LOSS     = "Music_GunGame_Loss"
const string FREEDM_MUSIC_PODIUM   = "Music_GunGame_Podium"
const string FREEDM_FIREBALL_SFX_PODIUM   = "TDM_Podium_Pyro_FlameBurst_Sequence"
const string FREEDM_SPARKS_SFX_PODIUM   = "TDM_Podium_Pyro_Sparklers"

const float FREEDM_SCORE_VO_BC_DELAY = 6.0 // Seconds to wait for BC to respond

const string FREEDM_VICTORY_SOUND = "UI_InGame_GunGame_Victory"
const string FREEDM_DEFEAT_SOUND = "UI_InGame_GunGame_Defeat"


const string FDM_PODIUM_FX_SPARKS_L1 = "sparks_L1"
const string FDM_PODIUM_FX_SPARKS_L2 = "sparks_L2"
const string FDM_PODIUM_FX_SPARKS_R1 = "sparks_R1"
const string FDM_PODIUM_FX_SPARKS_R2 = "sparks_R2"
const string FDM_PODIUM_FX_FIREBALL_L1 = "Fireball_L1"
const string FDM_PODIUM_FX_FIREBALL_L2 = "Fireball_L2"
const string FDM_PODIUM_FX_FIREBALL_R1 = "Fireball_R1"
const string FDM_PODIUM_FX_FIREBALL_R2 = "Fireball_R2"
const string FDM_PODIUM_FX_CONFETTI = "confetti_burst"

const string FDM_PODIUM_SCRIPT_FIREBALL = "script_fireballs"
const string FDM_PODIUM_SCRIPT_SPARKS = "script_sparks"

                                          
                                                                              
                                                                            
                                                

#if SERVER
const float FREEDM_MINIMAP_ZOOM_SCALE = 1.3 // since all maps are about the same size just having the one value is probably okay
#endif // SERVER

#if CLIENT
const string FREEDM_SFX_MATCH_TIME_LIMIT = "Ctrl_Match_End_Warning_1p"
const string GUNGAME_COUNTDOWN_SOUND = "UI_InGame_GunGame_Countdown"
const string TDM_COUNTDOWN_SOUND = "TDM_UI_InGame_Countdown"
const string TDM_ROUND_WON = "TDM_UI_RoundWon"
const string TDM_ROUND_LOSS = "TDM_UI_RoundLoss"
const string TDM_ROUND_START = "TDM_UI_StartRoundHUD"
#endif // CLIENT

global enum eFreeDMAudioEvents
{
	Gameplay_Music,
	Victory_Music,
	Loss_Music,
	Podium_Music,
	Podium_Fireball_SFX,
	Podium_Sparks_SFX,
	Victory_Sound,
	Defeat_Sound,

	Count
}

global enum eFreeDMTimedEventType
{
	AIRDROP,
	OBJECTIVE_POINT,
	_count
}

global const array<string> FREEDM_DISABLED_BATTLE_CHATTER_EVENTS = [
"bc_anotherSquadAttackingUs",
"bc_squadsLeft2",
"bc_squadsLeft3",
"bc_squadsLeftHalf",
"bc_twoSquaddiesLeft",
"bc_championEliminated",
"bc_killLeaderNew",
"bc_podLeaderLaunch",
"bc_imJumpmaster",
"bc_returnFromRespawn",
]

global const array<int> FREEDM_DISABLED_COMMS_ACTIONS = [
                         
eCommsAction.INVENTORY_NO_AMMO_BULLET,
eCommsAction.INVENTORY_NO_AMMO_ARROWS,
eCommsAction.INVENTORY_NO_AMMO_HIGHCAL,
eCommsAction.INVENTORY_NO_AMMO_SHOTGUN,
eCommsAction.INVENTORY_NO_AMMO_SNIPER,
eCommsAction.INVENTORY_NO_AMMO_SPECIAL,
      
]

#if SERVER
struct FreeDM_VOData
{
	bool hasPlayedHalfwayVO = false
	bool hasPlayedNearEndVO = false
}
#endif

#if SERVER
                                          
                                      
 
                      
                     
                       
 
                                                
#endif // SERVER

struct {
#if SERVER
	array<string> excludedInfiniteAmmoWeapons = ["crate"]
	void functionref( entity player, string currentShieldRef ) ArmorOverrideCallback = null
	void functionref( entity player ) PlayerPostRespawnOverrideCallback = null

	table< entity, bool > hasPlayerSpawnedOnce
	float lastAirdropTimestamp

	entity                                  musicEntity
	float functionref( int killsRemaining ) gameplayMusicCodeValueFunc = null
	int                                     gameplayMusicStartScoreLeft = FREEDM_MUSIC_START_ON_KILLS_LEFT
	bool 									hasGameplayMusicStarted = false

	table< int, FreeDM_VOData > teamVOData
	int nearEndscoreDeltaForVO = FREEDM_MUSIC_START_ON_KILLS_LEFT
	bool isMatchWinnerFound = false

                                           
                                      
                                                                       
                                                 

#endif // SERVER

#if CLIENT
	bool                          isScoreText = false
	var        					  introCountdownRUI = null
	asset functionref( int team ) getCustomIndicatorCallback = null
	void functionref()			  displayScoreThread = null
	void functionref()			  scoreboardSetupFunc = null
	var							  scoreTrackerHUDRui = null
#endif // CLIENT

	//Shared
	table< int, string > audioEvents
} file

void function FreeDM_GamemodeInitShared()
{
	SetScoreEventOverrideFunc( FreeDM_SetScoreEventOverride )
	GamemodeSurvivalShared_Init()

	TimedEvents_Init()

#if SERVER
	FreeDM_SetGameplayMusicFunction( FreeDM_GetRampUpMusicControllerValueFromScore )
	FreeDM_SetGameplayMusicStartKillsLeft( FreeDM_GetRampUpMusicStartScoreValue() )
	FreeDM_SetVOEndScoreDelta( GetPlayMusicOnScore() )

	FlagInit( FDM_PODIUM_FX_SPARKS_L1 )
	FlagInit( FDM_PODIUM_FX_SPARKS_L2 )
	FlagInit( FDM_PODIUM_FX_SPARKS_R1 )
	FlagInit( FDM_PODIUM_FX_SPARKS_R2 )
	FlagInit( FDM_PODIUM_FX_FIREBALL_L1)
	FlagInit( FDM_PODIUM_FX_FIREBALL_L2)
	FlagInit( FDM_PODIUM_FX_FIREBALL_R1)
	FlagInit( FDM_PODIUM_FX_FIREBALL_R2)
	FlagInit( FDM_PODIUM_FX_CONFETTI)
	GamemodeUtility_AddCallback_SetGamemodeWinnerFunction( FreeDM_SetMatchWinner )


	SetShouldSpawnPlayerOnConnect( FreeDM_ShouldSpawnOnConnect )

	// blocking entity spawning
	//TODO DIVY - Make checkboxes the authoritative enable/disable setting for Ziprails
	BlockMapEntityParseCreationOf( "zipline", "script_control_omit_zipline", "" )
	BlockMapEntityParseCreationOf( "script_mover_train_node", "", "script_control_omit_zipline" )
	//

	BlockMapEntityParseCreationOf( "script_skydive_launcher", "", "" )

	// blocking entity spawning <- Copied from gamemode_control (April 6th, 2023)
	BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_survival_survey_beacon" )
	BlockMapEntityParseCreationOf( "zipline", "skydive_tower", "" )
	BlockMapEntityParseCreationOf( "prop_dynamic", "jump_tower", "" )
	BlockMapEntityParseCreationOf( "prop_dynamic", "jump_tower_stairs", "" )
	BlockMapEntityParseCreationOf( "prop_dynamic", "", "script_loot_marvin" )
	//

                                           
                       
                                           

   
                                             
                                                           
                                                
                                                 
                                                                            

                                                                       
   
   
                                            
                                                           
                                                
                                                 
                                                                           

                                                                       
   
                                                 

#endif

	RegisterNetworkedVariable( FREEDM_SECONDARY_SCORE_NAME, SNDC_PLAYER_GLOBAL, SNVT_BIG_INT, 0 )

	Remote_RegisterClientFunction( "ServerCallback_FreeDM_AirdropNotification")
	Remote_RegisterClientFunction( "ServerCallback_FreeDM_AnnounceRoundWonLost", "int", 0, 128)
	Remote_RegisterClientFunction( "ServerCallback_FreeDM_ChampionSounds", "int", 0, 128)
	Remote_RegisterClientFunction( "FreeDM_CloseCharacterSelect")
	Remote_RegisterClientFunction( "ServerCallback_SetRespawnOverlay" )

	#if CLIENT
		FreeDM_SetDisplayScoreThread( DisplayScore )
		AddCallback_OnPlayerLifeStateChanged( FreeDM_OnPlayerLifeStateChanged )

		SetCustomScreenFadeAsset($"ui/screen_fade_teamdeathmatch.rpak")
		FreeDM_SetScoreboardSetupFunc( FreeDM_BaseScoreboardSetup )
		HudTargetInfo_Enable( false )
		SetShowUnitFrameAmmoTypeIcons(false)
		DeathScreen_SetSkipDeathRecapAnimation( true )

		// The default description mentions join in progress match completed XP, override with blank until we turn that on for freedm modes
		CharacterSelectMenu_SetCustomJIPDescription( "" )
	#endif

	//Register Airdrops if they are enabled
	if ( GetFreeDMAreAirdropsEnabled() )
	{
		TimedEventData airdropData

		airdropData.eventType = eFreeDMTimedEventType.AIRDROP
		#if SERVER
			airdropData.isRepeatingEvent = true
			airdropData.shouldDestroyWPOnEventEnd = true
			airdropData.timedEventFunctionThread = FreeDM_ManageAirdrops_Thread
			airdropData.startTimeDelay = 15
			airdropData.repeatInterval = 1
			airdropData.eventLength = 10
			airdropData.timedEventFunctionStartValidation = FreeDM_AirdropStartValidation
			file.lastAirdropTimestamp = Time()
		#endif

		#if CLIENT
			airdropData.colorOverride = COLOR_WHITE
			airdropData.eventName = "#EVENT_AIRDROP_NAME"
			airdropData.eventDesc = "#EVENT_AIRDROP_DESC"
		#endif

		TimedEvents_RegisterTimedEvent( airdropData )
	}

	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Gameplay_Music, FREEDM_MUSIC_GAMEPLAY )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Victory_Music, FREEDM_MUSIC_VICTORY )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Loss_Music, FREEDM_MUSIC_LOSS )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Podium_Music, FREEDM_MUSIC_PODIUM )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Podium_Fireball_SFX, FREEDM_FIREBALL_SFX_PODIUM )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Podium_Sparks_SFX, FREEDM_SPARKS_SFX_PODIUM )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Victory_Sound, FREEDM_VICTORY_SOUND )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Defeat_Sound, FREEDM_DEFEAT_SOUND )

	FreeDM_RegisterNetworking()
}

#if SERVER
void function FreeDM_GamemodeInitServer()
{
	// Disabling this until QA has a way to launch the game as a single player without using max_nofill_players
	//int num_nofill = GetCurrentPlaylistVarInt( "max_nofill_players", 0 )
	//if ( num_nofill != 0 )
	//{
	//	ForceScriptError( "For FreeDM Gamemodes, the playlist variable 'max_nofill_players' must be 0, current playlist value = " + num_nofill + ", please fix the playlist" )
	//}

	// TODO - rorth: do we really want to init all of survival?
	GamemodeSurvival_Init()

	MapNode_Init()
	// Circle Culling Logic has been moved to _gamemode_utility.nut

	SetCustomIntroCameraSettingsFunction( CustomIntroCameraSettings )

	SetVictoryKillMode( true ) // TODO okirkham: probably don't need this?

	AddCallback_OnPlayerKilled( OnPlayerOrNPCKilled )
	AddCallback_OnPlayerKilled( StoreAllChargeForPlayer )
	AddCallback_OnPlayerRespawned( RestoreChargesForPlayer )
	//AddCallback_OnNPCKilled( TDM_OnPlayerOrNPCKilled )
	AddCallback_OnPlayerPostRespawned( OnPlayerPostRespawned )
	AddCallback_PlayerClassChanged( OnPlayerClassChanged )
	AddCallback_OnClientConnected( OnPlayerConnected )

	// Add back in later for handling in game score events like kill spree, revenge, etc once they are implemented
	//AddCallback_OnPlayerScored( FreeDM_OnPlayerScored )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	AddCallback_OnClientDisconnected( OnFreeDMPlayerDisconnected )

	AddCallback_GameStateEnter( eGameState.Prematch, FreeDM_OnGameStatePrematchEnter )
	AddCallback_GameStateEnter( eGameState.Playing, FreeDM_OnGameStatePlayingEnter )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, FreeDM_OnWinnerDetermined )

	Survival_AddCallback_IsSquadReallyEliminated( FreeDM_IsSquadReallyEliminated )
	// Disable commentary events
	//SurvivalCommentary_SetEventEnabled( eSurvivalEventType.PILOT_KILL, false ) // will manually trigger first blood
	//SurvivalCommentary_SetEventEnabled( eSurvivalEventType.FIRST_BLOOD, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVING, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.FINAL_CIRCLE_MOVING, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_CLOSING_TO_NOTHING, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CARE_PACKAGE_DROPPING, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HALF_PLAYERS_ALIVE, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HALF_SQUADS_ALIVE, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.HOVER_TANK_INBOUND, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.ROUND_TIMER_STARTED, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.FIRST_CIRCLE_MOVING, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_1MIN, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_10SEC, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_30SEC, false )
	SurvivalCommentary_SetEventEnabled( eSurvivalEventType.CIRCLE_MOVES_45SEC, false )
	RegisterDisabledBattleChatterEvents( FREEDM_DISABLED_BATTLE_CHATTER_EVENTS )
	QuickChat_RegisterDisabledCommsActions( FREEDM_DISABLED_COMMS_ACTIONS )

	if ( IsUsingLoadoutSelectionSystem() )
	{
		AddCallback_LoadoutSelection_OnLoadoutUpdated( FreeDM_OnLoadoutUpdated )
		AddCallback_LoadoutSelection_OnLoadoutSelected( FreeDM_OnLoadoutSelected )
	}

	thread DeathFieldReset_Thread()
}
#endif // SERVER

void function FreeDM_RegisterNetworking()
{
	//Remote_RegisterClientFunction( "ServerCallback_FreeDMScoreEvent", "int", INT_MIN, INT_MAX) // Call site commented out (line 454)
	Remote_RegisterClientFunction("UICallback_FreeDM_OpenCharacterSelect")
	GamemodeUtility_RegisterNetworking()
}

bool function FreeDM_ShouldSpawnOnConnect( entity player )
{
	return false
}

#if SERVER
void function DeathFieldReset_Thread()
{
	FlagWait( "DoneCreatingDeathFieldPosition" )
	RoundBased_ResetDeathfield()
}
#endif // SERVER

//#if SERVER
//void function FreeDM_OnPlayerScored( entity player, ScoreEvent scoreEvent )
//{
//	vector textPos = <0, 0, 16>
//	if ( scoreEvent.name == "KillingSpree" )
//	{
//		AddPlayerScore( player, "FreeDM_KillingSpree" )
//	}
//
//	if ( scoreEvent.name == "FreeDM_KillingSpree" )
//	{
//		Remote_CallFunction_NonReplay( player, "ServerCallback_FreeDMScoreEvent", ScoreEvent_GetEventId( scoreEvent ) )
//	}
//}
//#endif // SERVER

#if SERVER
void function FreeDM_OnGameStatePrematchEnter()
{
	int allianceSize = GetCurrentPlaylistVarInt( "max_players", FREEDM_DEFAULT_MAX_PLAYERS ) / 2
	array<entity> allPlayers = GetPlayerArray()
	if ( GamemodeUtility_GetMixtapeAbandonPenaltyActive() )
	{
		foreach ( player in allPlayers )
		{
			if ( AllianceProximity_IsUsingAlliances() )
			{
				int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
				if ( AllianceProximity_GetNumPlayersInAlliance( playerAlliance, false ) == allianceSize )
					player.SetPlayerNetBool( "rankedDidPlayerEverHaveAFullTeam", true )
			}
			else
			{
				if ( GetPlayerArrayOfTeam( player.GetTeam() ).len() == GetMaxTeamPlayers() )
					player.SetPlayerNetBool( "rankedDidPlayerEverHaveAFullTeam", true )
			}
		}
	}

	if ( file.isMatchWinnerFound )
		return

	if (GameState_HasRoundRestarted())
		FreeDM_ResetRound()

	if ( GetFreeDMAreAirdropsEnabled() )
		MapNode_ResetAvailableAirDropLocations()

	float introLength = GetCurrentPlaylistVarFloat( "freedm_prematch_intro_time", 0.0 )
	if (introLength > 0)
		SetCustomIntroLength( introLength )

	array < entity > allPlayersArray = GetPlayerArray()
	foreach( player in allPlayersArray )
	{
		if ( player.GetTeam() != TEAM_SPECTATOR )
			player.StopObserverMode()
	}
}
#endif // SERVER

#if SERVER
void function FreeDM_OnGameStatePlayingEnter()
{
	array < entity > allAlivePlayersArray = GetPlayerArray_Alive()
	foreach ( player in allAlivePlayersArray )
	{
		player.SetMinimapZoomScale( FREEDM_MINIMAP_ZOOM_SCALE, 0.1 )
		StopSoundOnEntity(player, "Ctrl_Duck_Pregame_Podium_Emotes")
		Remote_CallFunction_NonReplay( player, "FreeDM_CloseCharacterSelect" )
		if( file.PlayerPostRespawnOverrideCallback == null )
			thread SetupPlayer( player )
	}
	thread DroppedLootCleanUp( GetDroppedLootCleanupScanPeriod(), GetDroppedLootLifetime())
	thread FreeDM_CheckWinConditions_Thread()

	array < entity > allPlayersAndSpectatorsArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayersAndSpectatorsArray )
	{
		string music = GetMusicForJump( player )
		if ( music.len() > 0 )
			SignalSoundOnEntity( player, music )
	}
	thread _StopJumpMusicThread()

	CreateMusicEntity()
}
#endif // SERVER

#if SERVER
void function FreeDM_OnWinnerDetermined()
{
	FreeDM_StopMusicPlaying()
}
#endif // SERVER

#if SERVER
void function FreeDM_StopMusicPlaying()
{
	if(file.musicEntity != null)
		StopSoundOnEntity( file.musicEntity, file.audioEvents[eFreeDMAudioEvents.Gameplay_Music] )

	array < entity > allPlayersAndSpectatorsArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayersAndSpectatorsArray )
	{
		StopAllMusicOnPlayer( player )
	}
}
#endif // SERVER

#if SERVER
void function _StopJumpMusicThread()
{
	float introLength = GetCurrentPlaylistVarFloat( "freedm_intro_music_stop_delay", FREEDM_INTRO_MUSIC_TIME )

	wait introLength

	array < entity > allPlayersAndSpectatorsArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayersAndSpectatorsArray )
	{
		string music = GetMusicForJump( player )
		if ( music.len() > 0 )
			StopMusicOnPlayer( player, music )
	}
}
#endif // SERVER

#if SERVER
void function CreateMusicEntity()
{
	file.musicEntity = CreateEntity( "prop_script" )
	file.musicEntity.SetOrigin( <0,0,10000> )
	file.musicEntity.DisableHibernation()
	DispatchSpawn( file.musicEntity )
}
#endif //SERVER

#if SERVER
void function UpdateGameplayMusic( int scoringTeamOrAlliance )
{
	int winningTeam = GamemodeUtility_GetWinningTeamOrAlliance( false )

	// Don't change music when non-winning teams/alliances score.  Only when the overall highest score progresses
	if ( scoringTeamOrAlliance != winningTeam )
		return

	int highestScore = GamemodeUtility_GetWinningTeamOrAllianceScore()
	int scoreRemaining = GetScoreLimit_FromPlaylist() - highestScore
	float codeValue    = FreeDM_GetGameplayMusicCodeValue( scoreRemaining )
	if( codeValue >= 0 )
	{
		// Start music based on GetPlayMusicOnScore's kills away from final score
		if ( !file.hasGameplayMusicStarted && scoreRemaining <= file.gameplayMusicStartScoreLeft )
		{
			EmitSoundOnEntity( file.musicEntity, file.audioEvents[ eFreeDMAudioEvents.Gameplay_Music ] )
			file.hasGameplayMusicStarted = true
		}

		file.musicEntity.SetSoundCodeControllerValue( codeValue )
	}
}
#endif //SERVER

#if SERVER
void function FreeDM_SetGameplayMusicFunction( float functionref( int ) gameplayMusicFunc )
{
	file.gameplayMusicCodeValueFunc = gameplayMusicFunc
}
#endif //SERVER

#if SERVER
void function FreeDM_SetGameplayMusicStartKillsLeft( int scoreRemaining )
{
	file.gameplayMusicStartScoreLeft = scoreRemaining
}
#endif // SERVER

#if SERVER
float function FreeDM_GetGameplayMusicCodeValue( int scoreRemaining )
{
	if( file.gameplayMusicCodeValueFunc == null )
	{
		printf( "[FREEDM] - FreeDM_GetGameplayMusicCodeValue no function set!" )
		return -1
	}

	return file.gameplayMusicCodeValueFunc( scoreRemaining )
}

#endif //SERVER

#if SERVER
float function GetGameplayMusicCodeValue( int scoreRemaining )
{
		switch( scoreRemaining )
		{
			case 5: return 0
			case 4: return 50
			case 3: return 100
			case 2: return 150
			case 1: return 200
		}

	return -1
}
#endif //SERVER

void function FreeDM_SetAudioEvent( int event, string eventString )
{
	if( event < 0 || event >= eFreeDMAudioEvents.Count )
	{
		printf( "[FREEDM] - FreeDM_SetMusicEvent invalid event %d", event )
		return
	}

	file.audioEvents[ event ] <- eventString
}

#if SERVER
// Set how many points a team needs to be from the score limit when we trigger the team about to win VO
void function FreeDM_SetVOEndScoreDelta( int endScoreDelta )
{
	Assert( endScoreDelta > 0 && endScoreDelta < GetScoreLimit_FromPlaylist(), "FreeDM: " + FUNC_NAME() + " Tried Setting an Invalid Vo End Score Delta: " + endScoreDelta + " it needs to be greater than 0 and less than the score limit: " + GetScoreLimit_FromPlaylist() )
	file.nearEndscoreDeltaForVO = endScoreDelta
}
#endif //SERVER

#if SERVER
void function EntitiesDidLoad()
{
	SetGlobalNetBool( "isMapZoneDisplayTextDisabled", true )
	SetupAssaultPointKeyValues()

	//no turrets in TDM for now
	array<entity> turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach ( turret in turrets )
	{
		turret.DisableTurret()
	}

	FlagSet( "DisableDropships" )
	//FlagSet( "disable_npcs" )
}
#endif // SERVER

#if SERVER
void function CustomIntroCameraSettings( entity player, IntroCameraSettings view )
{
	if( !MapNode_IsMapDataValid() )
		return

	array<Point> introCameraPoints = MapNode_GetIntroCameraPoints()
	Point introCamera =  introCameraPoints[0]
	if( player.GetTeam() != TEAM_SPECTATOR )
	{
		introCamera = introCameraPoints.getrandom()
	}
	else
	{
		// NOTE: we do this to avoid observers using random
		int randIdx = GetUnixTimestamp() % introCameraPoints.len()
		introCamera = introCameraPoints[randIdx]
	}

	view.origin = introCamera.origin
	view.angles = introCamera.angles

	if ( IsPrivateMatch() )
	{
		if ( player.GetTeam() == TEAM_SPECTATOR )
		{
			player.SetOrigin( view.origin )
			player.SetAngles( view.angles )
		}
	}
}
#endif // Server

#if SERVER
void function OnPlayerOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	// drop loot on death
	if ( GetFreeDMDropLootOnDeath() )
		GamemodeUtility_DropLoot( victim )

		GamemodeUtility_SpawnBonusLootOnPlayer( victim )

	if( IsValid( victim ) )
		Remote_CallFunction_NonReplay(victim, "ServerCallback_SetRespawnOverlay" )
}
#endif // SERVER


#if SERVER
// Essentially identical to SetDefaultRoundWinningKillReplayEntities, but checks freedm-specific gamestate to ensure we always set the right ents
// see R5DEV-562427
void function FreeDM_SetScoreEventRoundWinningKillReplayEnts( entity victim, entity attacker, var damageInfo )
{
	if ( file.isMatchWinnerFound )
		return

	SetDefaultRoundWinningKillReplayEntities( victim, attacker, damageInfo )
}

void function FreeDM_AddTeamScore( int team, int newPoints )
{
    if( file.isMatchWinnerFound )
		return

	                         
		int oldWinningTeamOrAlliance = GamemodeUtility_GetWinningTeamOrAlliance( true )
                                
	int scoringTeamOrAlliance = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllianceFromTeam( team ) : team
	int oldScore = GamemodeUtility_GetTeamOrAllianceScore( scoringTeamOrAlliance )
	int newScore = oldScore + newPoints
	int scoreLimit = GetScoreLimit_FromPlaylist()
	newScore = ClampInt( newScore, 0, GetScoreLimit_FromPlaylist() )

	if ( newScore >= scoreLimit )
		file.isMatchWinnerFound = true

	//Alliances 0 and 1 are being used for the overall team's score
	if( AllianceProximity_IsUsingAlliances() )
	{
		SetAllianceTeamsScore( scoringTeamOrAlliance, newScore )
	}
	else
	{
		GameRules_SetTeamScore( team, newScore )
	}

	                         
		int newWinningTeamOrAlliance = GamemodeUtility_GetWinningTeamOrAlliance( true )

		// Check if the scoring team has taken the lead
		if ( (newWinningTeamOrAlliance != oldWinningTeamOrAlliance) && (newWinningTeamOrAlliance == scoringTeamOrAlliance) )
		{
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.LEAD_CHANGE_POSITIVE )
			UpdateOtherTeamsOrAlliancesCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.LEAD_CHANGE_NEGATIVE )
		}

		// Check if the scoring team is close to winning the match
		int scoreRemaining = scoreLimit - newScore
		if ( scoreRemaining == file.gameplayMusicStartScoreLeft )
		{
			UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.CLOSE_TO_WINNING_MATCH_POSITIVE )
			UpdateOtherTeamsOrAlliancesCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.CLOSE_TO_WINNING_MATCH_NEGATIVE )
		}

		// check if the scoring team reached the halfway point of the match
		if ( scoreLimit > 0 )
		{
			int halfwayScore = scoreLimit / 2
			if ( (oldScore < halfwayScore) && (newScore >= halfwayScore) )
			{
				UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.MATCH_HALFWAY_SCORE_REACHED_POSITIVE )
				UpdateOtherTeamsOrAlliancesCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.MATCH_HALFWAY_SCORE_REACHED_NEGATIVE )
			}
		}

		// If there is a winner, check the magnitude of the win
		if ( file.isMatchWinnerFound )
		{
			int scoreDeltaForMediumWin = GetCurrentPlaylistVarInt( "score_delta_for_medium_win", 1 )
			int scoreDeltaForLargeWin = GetCurrentPlaylistVarInt( "score_delta_for_large_win", 1 )

			array< int > allTeamsOrAlliances = AllianceProximity_GetAllTeamsOrAlliances()
			allTeamsOrAlliances.fastremovebyvalue( scoringTeamOrAlliance )

			int closestScore = 0
			foreach( currentTeamOrAlliance in allTeamsOrAlliances )
			{
				int currentTeamOrAllianceScore = GamemodeUtility_GetTeamOrAllianceScore( currentTeamOrAlliance )
				closestScore = maxint( closestScore, currentTeamOrAllianceScore )
			}

			int scoreDelta = newScore - closestScore
			if ( scoreDelta >= scoreDeltaForLargeWin )
			{
				UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.WIN_BY_LARGE_MARGIN_POSITIVE )
			}
			else if ( scoreDelta >= scoreDeltaForMediumWin )
			{
				UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.WIN_BY_MEDIUM_MARGIN_POSITIVE )
			}
			else
			{
				UpdateTeamOrAllianceCrowdNoiseMeterAndBroadcast( scoringTeamOrAlliance, eCrowdNoiseMeterModifiers.WIN_BY_SMALL_MARGIN_POSITIVE )
			}
		}
                                

                                           
                                
                                                              
                                                 

	thread _PlayScoreVO( scoringTeamOrAlliance )
	UpdateGameplayMusic( scoringTeamOrAlliance )
}
#endif // SERVER

#if SERVER
void function _PlayScoreVO( int scoringTeamOrAlliance )
{
	// Get highest score and winning team
	int numTeams = GetNumTeamsExisting()
	int winningTeamOrAlliance = GamemodeUtility_GetWinningTeamOrAlliance( true )
	int highestScore = GamemodeUtility_GetWinningTeamOrAllianceScore()
	float maxScore = float( GetScoreLimit_FromPlaylist() )

	// Only play Host announce VO on first team hitting halfway
	if( winningTeamOrAlliance != scoringTeamOrAlliance )
	{
		// Check if current scoring team hit halfway and play line to them
		int teamScore = GamemodeUtility_GetTeamOrAllianceScore( scoringTeamOrAlliance )
		FreeDM_VOData voData = GetVODataFromTeamOrAlliance( scoringTeamOrAlliance )
		if( teamScore >= int( maxScore * 0.5 ) && !voData.hasPlayedHalfwayVO)
		{
			voData.hasPlayedHalfwayVO = true
			if( AllianceProximity_IsUsingAlliances() )
			{
				array <int> allianceTeams = AllianceProximity_GetPopulatedTeamsInAlliance( scoringTeamOrAlliance )
				foreach( team in allianceTeams )
				{
					entity speaker = TryFindSpeakingPlayerOnTeam( team )
					PlayBattleChatterLineToSpeakerAndTeam( speaker, "bc_control_scoreHalfWin" )
				}
			}
			else
			{
				entity speaker = TryFindSpeakingPlayerOnTeam( scoringTeamOrAlliance )
				PlayBattleChatterLineToSpeakerAndTeam( speaker, "bc_control_scoreHalfWin" )
			}
		}

		return
	}

	FreeDM_VOData voData = GetVODataFromTeamOrAlliance( winningTeamOrAlliance )

	// Pick either halfway or near VO line if applicable
	string chatterLine = ""
	if( highestScore >= int( maxScore * 0.5 ) && !voData.hasPlayedHalfwayVO )
	{
		voData.hasPlayedHalfwayVO = true
		chatterLine = "bc_control_scoreHalf"

		int commentaryBucket = -1
		if ( AllianceProximity_IsUsingAlliances() )
		{
			commentaryBucket = eSurvivalCommentaryBucket.FREEDM_TEAM_HALFWAY
		}
		else
		{
			switch (Squads_GetSquadName(Squads_GetSquadUIIndex( winningTeamOrAlliance )))
			{
				case ("#TEAM_NAME_0_EASTEREGG"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_NESSIE_HALFWAY
					break
				case ("#TEAM_NAME_0"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_WOLF_HALFWAY
					break
				case ("#TEAM_NAME_1"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_EAGLE_HALFWAY
					break
				case ("#TEAM_NAME_2"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_BEAR_HALFWAY
					break
				case ("#TEAM_NAME_3"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_TIGER_HALFWAY
					break
			}
		}

		thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( commentaryBucket ) )
	}
	else if( highestScore >= int( maxScore - file.nearEndscoreDeltaForVO ) && !voData.hasPlayedNearEndVO )
	{
		voData.hasPlayedNearEndVO = true
		chatterLine = "bc_control_scoreNear"

		int commentaryBucket = -1
		if ( AllianceProximity_IsUsingAlliances() )
		{
				if( GetPlayMusicOnScore() != FREEDM_MUSIC_START_ON_KILLS_LEFT )
				{
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_VO_OVERIDE_TEAM_NEAR_WINNING
				}
				else
				{
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_TEAM_NEAR_WINNING
				}
		}
		else
		{
			switch (Squads_GetSquadName(Squads_GetSquadUIIndex( winningTeamOrAlliance )))
			{
				case ("#TEAM_NAME_0_EASTEREGG"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_NESSIE_WINNING
					break
				case ("#TEAM_NAME_0"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_WOLF_WINNING
					break
				case ("#TEAM_NAME_1"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_EAGLE_WINNING
					break
				case ("#TEAM_NAME_2"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_BEAR_WINNING
					break
				case ("#TEAM_NAME_3"):
					commentaryBucket = eSurvivalCommentaryBucket.FREEDM_TIGER_WINNING
					break
			}
		}

		thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( commentaryBucket) )
	}

	if( chatterLine == "" )
		return

	// Wait for Host announcer to finish before Legends respond with battle chatter
	wait FREEDM_SCORE_VO_BC_DELAY

	// Play VO line to every team, picking a random squad member or the scoring player
	for( int team = TEAM_IMC; team < TEAM_IMC + numTeams; team++ )
	{
		entity speaker = TryFindSpeakingPlayerOnTeam( team )
		if( speaker == null )
			continue

		bool isWinningTeam = ( AllianceProximity_IsUsingAlliances() && AllianceProximity_GetAllianceFromTeam( team ) == winningTeamOrAlliance ) || ( !AllianceProximity_IsUsingAlliances() && team == winningTeamOrAlliance )
		chatterLine = chatterLine + ( isWinningTeam ? "Win" : "Loss" )
		PlayBattleChatterLineToSpeakerAndTeam( speaker, chatterLine )
	}

}
#endif // SERVER

#if SERVER
// Converts to alliance if applicable, otherwise uses team as key
FreeDM_VOData function GetVODataFromTeamOrAlliance( int teamOrAlliance )
{
	return GetVOData( teamOrAlliance )
}
#endif // SERVER

#if SERVER
FreeDM_VOData function GetVOData( int team )
{
	if( !(team in file.teamVOData) )
	{
		FreeDM_VOData voData
		file.teamVOData[team] <- voData
	}

	return file.teamVOData[team]
}
#endif // SERVER

#if SERVER
void function FreeDM_ResetRound()
{
	int numTeams = GetNumTeamsExisting()
	for( int team = TEAM_IMC; team < TEAM_IMC + GetNumTeamsExisting(); team++ )
	{
		if( AllianceProximity_IsUsingAlliances() )
			SetAllianceTeamsScore( AllianceProximity_GetAllianceFromTeam(team), 0 )
		else
			GameRules_SetTeamScore( team, 0 )
	}

	file.hasPlayerSpawnedOnce.clear()
	if (GetShouldShuffleLoadoutsRounds())
	{
		LoadoutSelection_ShuffleLoadoutRotation()
	}
}
#endif // SERVER

                                          
          
                                                                          
 
                                     
        

                             

                               
                                                                          
  
                                                       
   
                                                                                    
                                 
    
                                                                                         
                                      
     
                                                                
                                                                      
     
    
   
  

                                                                                         
                                                                                                      
                                              
  
                            
  
            
                                              
  
                              
  
 
                
                                                

#if SERVER
void function FreeDM_AddPlayerSecondaryScore( entity player, int newPoints )
{
	int newScore = player.GetPlayerNetInt( FREEDM_SECONDARY_SCORE_NAME ) + newPoints
	player.SetPlayerNetInt( FREEDM_SECONDARY_SCORE_NAME, newScore )
}
#endif // SERVER

#if SERVER
int function FreeDM_GetCurrentRank( entity player )
{
	if( !IsValid( player ) || player == null )
		return GetNumTeamsExisting()

	if ( GetGameState() <= eGameState.Playing )
		return GetNumTeamsExisting()

	array<int> allScores
	if( AllianceProximity_IsUsingAlliances() )
	{
		for( int i = 0; i < AllianceProximity_GetMaxNumAlliances(); ++i )
			allScores.append( GetAllianceTeamsScore( i ) )
	}
	else
	{
		int numTeams = GetNumTeamsExisting()
		for( int team = TEAM_IMC; team < TEAM_IMC + numTeams; team++ )
			allScores.append( GameRules_GetTeamScore( team ) )
	}

	// Sort highest score first
	allScores.sort( int function( int a, int b ) {
		if( a > b ) return -1
		if( a < b ) return 1
		return 0
	} )

	int playerTeam = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) : player.GetTeam()
	int playerScore = GamemodeUtility_GetTeamOrAllianceScore( playerTeam )

	for( int i = 0; i < allScores.len(); ++i )
	{
		if( allScores[i] == playerScore )
			return i + 1
	}

	// Should be unreachable
	Warning( "[FreeDM] FreeDM_GetCurrentRank - Player score not found. Default rank returned" )
	return GetNumTeamsExisting()
}
#endif // SERVER

const int FramesToWait = 60 // server so 20fps * 3 seconds = 60 frames
#if SERVER
void function FreeDM_CheckWinConditions_Thread()
{
#if DEVELOPER
	if ( GetConVarInt( "mp_enablematchending" ) == 0 )
		return

	if ( GetCurrentPlaylistVarInt( "match_ending_enabled", 1 ) == 0 )
		return
#endif

	bool winningTeamFound = false
	int winningTeamOrAlliance = TEAM_INVALID
	int scoreLimit = GetScoreLimit_FromPlaylist()

	int frameCounter = 0
	while ( !winningTeamFound )
	{
		WaitFrame() // might as well do this at start since will not be true immediately

		frameCounter++
		winningTeamOrAlliance = GamemodeUtility_GetWinningTeamOrAlliance( false )

		//TO DO: Find a better event or way to run this logic
		if (frameCounter % FramesToWait == 0 && !GamemodeUtility_AreMultipleTeamsPopulated())
		{
			//Assume there's no enemies and just find the first available player and delcare their team the winner
			foreach (player in GetConnectedPlayers() )
			{
				if (player.GetTeam() >= TEAM_MULTITEAM_FIRST)
				{
					if ( AllianceProximity_IsUsingAlliances() )
						winningTeamOrAlliance = AllianceProximity_GetAllianceFromTeam(player.GetTeam())
					else
						winningTeamOrAlliance = player.GetTeam()
					break
				}
			}

			if ( winningTeamOrAlliance == TEAM_INVALID )
			{
				// there are no connected players so just pick the 1st team to win
				winningTeamOrAlliance = TEAM_MULTITEAM_FIRST
			}

			winningTeamFound = true
			break
		}

		if ( winningTeamOrAlliance != TEAM_INVALID && GamemodeUtility_GetTeamOrAllianceScore( winningTeamOrAlliance ) >= scoreLimit )
		{
			winningTeamFound = true
			break
		}
	}

	array < entity > allPlayers = GetPlayerArray()
	foreach ( player in allPlayers )
	{
		Remote_CallFunction_NonReplay( player, "FreeDM_CloseCharacterSelect" )
		if( IsUsingLoadoutSelectionSystem() )
			Remote_CallFunction_UI( player, "LoadoutSelectionMenu_CloseLoadoutMenu" )
	}

	if ( IsRoundBased() && GamemodeUtility_AreMultipleTeamsPopulated())
	{
		// We cannot rely on RoundScoreLimit_Complete() for now.
		// TDM hasn't set the winner yet at this point, because first we show round transitions,
		// and after some delay we call SetWinner to finish the round and change the gamemode state
		// in this case, we gotta check for the (round score + 1) to determine if round score has been reached the limit
		// The logic checking for rounds and in the SetWinner function doesn't really fully support alliances so we pass in a team
		// The FreeDM_SetMatchWinner function supports alliances so we pass in the alliance ( or team if not using alliances )
		int winningTeam = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetRepresentativeTeamForAlliance( winningTeamOrAlliance ) : winningTeamOrAlliance
		if ( winningTeamFound && GameRules_GetTeamScore2( winningTeam ) + 1 >= GetRoundScoreLimit_FromPlaylist() )
		{
			//FreeDM_SetMatchWinner doesn't actually increment round score so we do it manually beforehand here
			GamemodeUtility_IncrementRoundScore(winningTeam, 1)
			FreeDM_SetMatchWinner( winningTeamOrAlliance, eWinReason.SCORE_LIMIT )
			thread PlayCommentaryLineToAllPlayers( PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.FREEDM_ROUND_COMPLETE) )
		}
		else
		{
			file.hasPlayerSpawnedOnce.clear()
			array < entity > allPlayersArray = GetPlayerArrayIncludingSpectators()
			foreach ( player in allPlayersArray )
			{
				if ( IsValid( player ) )
				{
					player.SetInvulnerable()
					Remote_CallFunction_NonReplay(player, "ServerCallback_FreeDM_AnnounceRoundWonLost", winningTeamOrAlliance )
				}
			}
			FreeDM_StopMusicPlaying()
			wait FREEDM_POST_ROUND_SCOREBOARD_TIME + FREEDM_ROUND_WIN_ANNOUNCMENT_TIME

			// SetWinner function used for round end doesn't support alliances, using a team instead
			if (!GetHasGameTimedOut())
				SetWinner( winningTeam, eWinReason.SCORE_LIMIT, "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
		}
	}
	else
	{
		FreeDM_SetMatchWinner( winningTeamOrAlliance, eWinReason.SCORE_LIMIT )
	}
}
#endif // SERVER

#if SERVER
// Because FreeDM can run with alliances or with teams, make sure you are passing in the winning team for non alliance modes and the winning alliance for alliance modes here.
void function FreeDM_SetMatchWinner( int winningTeamOrAlliance, int victoryCondition )
{
	if ( GetHasGameTimedOut() )
		return

	file.isMatchWinnerFound = true

	array < entity > allPlayersArray = GetPlayerArrayIncludingSpectators()
	foreach ( player in allPlayersArray )
	{
		if ( IsValid( player ) )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_FreeDM_ChampionSounds", winningTeamOrAlliance )
		}
	}

	GamemodeUtility_GamemodeSetWinnerCommon( winningTeamOrAlliance, victoryCondition, FreeDM_FreeDMOnlySetWinnerFunctionality )
}

bool function FreeDM_IsMatchWinnerDetermined()
{
	return file.isMatchWinnerFound
}
#endif // SERVER

#if SERVER
void function FreeDM_FreeDMOnlySetWinnerFunctionality( int localWinningTeam )
{
	array < entity > allPlayerAndSpectatorArray = GetPlayerArrayIncludingSpectators()
	foreach( entity player in allPlayerAndSpectatorArray )
	{
		if ( IsValid( player ) )
		{
			// this will retrigger the loss music for the lossers as well as play the win music for the winner.
			// Can't use PlayMusicToPlayer(), because on the client, the music is played on the viewPlayer, so you to hear the wrong music if you are specating.
			StopAllMusicOnPlayer( player )

			if ( GetCurrentPlaylistVarBool( "freedm_play_standard_match_end_music", true ) )
				Remote_CallFunction_NonReplay( player, "ServerCallback_PlayMatchEndMusic" )
		}
	}

	// TODO okirkham: shouldn't this be in the treasure hunt file?
	                             
		if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_LOCKDOWN ) )
		{
			array < entity > allPlayersArray = GetPlayerArray()
			foreach ( player in allPlayersArray )
			{
				float playerTimeOnObjectives =  player.GetPlayerNetTime( "treasureHunt_PlayerTimeOnObjectives" )
				if ( playerTimeOnObjectives > 0.0 )
					AddXP( player, eXPType.OBJECTIVE_CAPTURE_DURATION, int( playerTimeOnObjectives ) )
			}
		}
       
}
#endif // SERVER

#if SERVER
bool function GetFreeDMDropLootOnDeath()
{
	return GetCurrentPlaylistVarBool( "freedm_drop_loot_on_death", false )
}
#endif // SERVER

#if SERVER
// Loadout info has been updated for Clients, make sure weapon icons are updated on screens that use them
void function FreeDM_OnLoadoutUpdated( entity player )
{

}

// Loadout Menu has closed, update the rui that shows the current selected loadout
void function FreeDM_OnLoadoutSelected( entity player )
{

}
#endif // SERVER

#if SERVER
// Triggers when the player has respawned as a different character
void function OnPlayerClassChanged( entity player )
{

}
#endif

#if SERVER
void function OnPlayerConnected( entity player )
{
	if ( !IsValid( player ) )
		return
	player.SetMinimapZoomScale( FREEDM_MINIMAP_ZOOM_SCALE, 0.1 )

	if ( GamemodeUtility_IsJIPPlayerSpawnBonusPending( player ) || GetGameState() >= eGameState.Prematch ) // R5DEV-564332: ensure people can spawn if they connect after character select but before server is JIP-able
	{
		ClientToServer_OnCharacterReselectMenuOpen( player )
		SetPlayerIntroDropSettings( player )
		thread FreeDM_OnJIPSelectedCharacter( player )
	}
}
#endif

#if SERVER
void function FreeDM_OnJIPSelectedCharacter( entity player )
{
	player.EndSignal( "OnDestroy" )

	AssertIsNewThread()
	WaittillGameStateOrHigher( eGameState.Playing )
	wait 3.0

	Remote_CallFunction_NonReplay( player, "UICallback_FreeDM_OpenCharacterSelect" )
	while ( IsPlayerReselectingCharacter( player ) )
		wait 1.0

	thread SpawnConnectedPlayer_thread( player )
}
#endif

#if SERVER
void function SpawnConnectedPlayer_thread( entity player )
{
	AssertIsNewThread()
	WaittillGameStateOrHigher( eGameState.Playing )

	if ( IsValid( player ) )
	{
		ClearPlayerIntroDropSettings( player )
		DoCommonRespawnForPlayer( player )
	}
}
#endif

#if SERVER
string function FreeDM_GetSelectedLoadoutArmor( entity player )
{
	string selectedArmor = "armor_pickup_lv1"
	int loadoutIndex = LoadoutSelection_GetSelectedLoadoutSlotIndex_Server( player )
	array< string > equipmentRefs = LoadoutSelection_GetEquipmentLoadoutByLoadoutSlotIndex( loadoutIndex )
	foreach( equipment in equipmentRefs )
	{
		if ( SURVIVAL_Loot_GetLootDataByRef( equipment ).lootType == eLootType.ARMOR )
		{
			selectedArmor = equipment
			break;
		}
	}

	return selectedArmor
}
#endif // SERVER

#if SERVER
void function FreeDM_SetCallback_ArmorRefOverride( void functionref( entity player, string currentShieldRef ) func )
{
	file.ArmorOverrideCallback = func
}
#endif // SERVER

#if SERVER
void function FreeDM_SetCallback_PostRespawnOverride( void functionref( entity player ) func )
{
	file.PlayerPostRespawnOverrideCallback = func
}
#endif // SERVER

#if SERVER
void function ApplyLoadout( entity player )
{
	if (!IsValid(player))
		return

	//add infinite heal/ammo
	GivePassive( player, ePassives.PAS_INFINITE_HEAL )
	SetInfiniteAmmoForGameMode( player, true, file.excludedInfiniteAmmoWeapons )

	asset settings = player.GetPlayerSettings()
	if ( settings != SPECTATOR_SETTINGS )
		GivePlayerSettingsMods( player, [ "targetinfo_alliance" ] )
		//GivePlayerSettingsMods( player, [ "targetinfo_ffa_squad" ] )

	ResetPlayerInventory( player )
	FreeDM_GivePlayerFullTactical( player )

	if ( IsUsingLoadoutSelectionSystem() )
	{
		LoadoutSelection_GivePlayerInventoryAndLoadout( player, false, false, false, true )
	}

	if( file.ArmorOverrideCallback != null )
	{
		string armorRef = EquipmentSlot_GetLootRefForSlot( player, "armor" )
		file.ArmorOverrideCallback( player, armorRef )
	}

	                            
	if ( IsRevTakeover() && ( AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) == ALLIANCE_B ) )
	{
		if ( GetCurrentPlaylistVarBool( "enableRevTeamMods", true ) )
			GivePlayerSettingsMods( player, [ "enable_wallrun" ] )
	}
       
}

#endif // SERVER

#if SERVER
void function DroppedLootCleanUp( float scanPeriod, float lootLifeTime)
{
	int realm = Survival_Loot_GetDefaultRealm()

	while( GetGameState() < eGameState.WinnerDetermined )
	{
		PerformDroppedLootCleanUp( realm, lootLifeTime )
		wait scanPeriod
	}
}
#endif // SERVER

#if SERVER
void function PerformDroppedLootCleanUp( int realm, float lootLifeTime )
{
	array<entity> loot = GetEntArrayByClass_Expensive( "prop_survival" )

	foreach ( item in loot )
	{
		if ( IsValid( item ) && item.IsInRealm( realm ) )
		{
			LootData data = SURVIVAL_Loot_GetLootDataByIndex( item.GetSurvivalInt() )
			if ( data.tier >= eLootTier.LEGENDARY)
				continue

			if ( item.e.spawnTime + lootLifeTime < Time() )
			{
				item.Destroy()
			}
		}
	}
}
#endif // SERVER

#if SERVER
const string RESPAWN_DIALOGUE = "bc_respawnAuto"
const float RESPAWN_DIALOGUE_COOLDOWN = 90.0
void function OnPlayerPostRespawned( entity player )
{
	PIN_PlayerLandedOnGround(player)
	if( file.PlayerPostRespawnOverrideCallback != null )
	{
		file.PlayerPostRespawnOverrideCallback( player )
	}
	else
		thread SetupPlayer( player )

	// Play respawn dialogue but not on the first spawn
	if ( GetGameState() == eGameState.Playing )
		PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( player, RESPAWN_DIALOGUE, RESPAWN_DIALOGUE_COOLDOWN, RESPAWN_DIALOGUE_COOLDOWN, null, true )
}
#endif // SERVER

#if SERVER
bool function FreeDM_IsSquadReallyEliminated( int team )
{
	return false
}
#endif // SERVER

#if SERVER
void function SetupPlayer( entity player )
{
	if ( GetGameState() > eGameState.Playing )
		return

	player.EndSignal( "OnDestroy" )

	bool isFirstSpawn = !(player in file.hasPlayerSpawnedOnce)

	if( isFirstSpawn && IsUsingLoadoutSelectionSystem() && LoadoutSelection_GetAvailableLoadoutCount() > 1 )
	{
		LoadoutSelection_UpdateLoadoutInfoForMenus( player )
		WaittillGameStateOrHigher(eGameState.Prematch)
		wait 2.1 //Allow loadout menu to finish updating before trying to open it from prematch
		file.hasPlayerSpawnedOnce[ player ] <- true
		ClearPlayerIntroDropSettings( player )
		if ( !player.IsBot() )
		{
			Remote_CallFunction_UI( player, "LoadoutSelectionMenu_OpenLoadoutMenu", false )
			player.WaitSignal( "LoadoutSelection_LoadoutSelectMenuClosed" )
		}
	}
	WaittillGameStateOrHigher(eGameState.Playing)
	ApplyLoadout( player )

	// Allow us to give a better loadout in the ApplyLoadout function for Join In Progress players if we want.
	// If this was the players first spawn, set them to no longer be treated as Join In Progress players waiting for Spawn Bonus
	if ( isFirstSpawn )
		GamemodeUtility_SetJIPPlayerIsWaitingForSpawnBonus( player, false )

	if ( GetCurrentPlaylistVarBool( "allow_third_person", false ) == true )
	{
		player.SetThirdPersonShoulderModeOn()
	}
}
#endif // SERVER

#if SERVER
void function FreeDM_GivePlayerFullTactical( entity player )
{
	if( !IsValid( player ) || player == null )
		return

	if( !GetCurrentPlaylistVarBool( "spawn_with_full_tactical", true ) )
		return

	entity tacticalWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if ( IsValid( tacticalWeapon ) )
	{
		int tacCharge = tacticalWeapon.GetWeaponPrimaryClipCount()
		int maxTacCharge = tacticalWeapon.GetWeaponPrimaryClipCountMax()
		if ( tacCharge != maxTacCharge )
			tacticalWeapon.SetWeaponPrimaryClipCount( maxTacCharge )
	}
}
#endif

#if SERVER
void function FreeDM_SetExcludedInfiniteAmmoWeaponTier( array<string> excludedInfiniteAmmoWeapons )
{
	file.excludedInfiniteAmmoWeapons = excludedInfiniteAmmoWeapons
}

bool function FreeDM_HasInfiniteAmmoOnAllWeapons()
{
	return GetCurrentPlaylistVarBool( "freedm_infinite_ammo_for_all_weapons", false )
}
#endif //SERVER

/*
			   _____ _____  _____  _____   ____  _____   _____
		 /\   |_   _|  __ \|  __ \|  __ \ / __ \|  __ \ / ____|
		/  \    | | | |__) | |  | | |__) | |  | | |__) | (___
	   / /\ \   | | |  _  /| |  | |  _  /| |  | |  ___/ \___ \
	  / ____ \ _| |_| | \ \| |__| | | \ \| |__| | |     ____) |
	 /_/    \_\_____|_|  \_\_____/|_|  \_\\____/|_|    |_____/

	Airdrops
*/

#if SERVER
// Determine where airdrops should land
void function FreeDM_ManageAirdrops_Thread( TimedEventData data, entity eventWP )
{
	Assert( IsNewThread(), "Must be threaded off" )
	if( !MapNode_IsMapDataValid() || MapNode_GetAirdropLocations().len() == 0)
		return

	float startTime = Time()
	file.lastAirdropTimestamp = startTime
	int cratesPerDrops = int(min(FreeDM_GetCratesPerAirDrop(), MapNode_GetAvailableAirdropLocations().len()))

	for ( int i = 0; i < cratesPerDrops; i++ )
	{
		entity airdrop = MapNode_TakeAvailableAirdropLocation()

		array<string> airdropContents = GenerateAirdropContents()
		thread FreeDM_LaunchAirdrop_Thread( airdrop.GetOrigin(), airdropContents, data.eventLength )
	}

	if ( GetGameState() < eGameState.WinnerDetermined )
	{
		string commentaryLineToPlay = PickCommentaryLineFromBucket( eSurvivalCommentaryBucket.SPONSORED_CARE_PACKAGE_DROPPING )
		thread PlayCommentaryLineToAllPlayers( commentaryLineToPlay )

		// Play a reaction to the announcer line regarding the sponsorship of the airdrops
		FreeDM_PlayReactDialogueToSponsorshipCommentary( commentaryLineToPlay )
	}

	array < entity > allPlayersArray = GetPlayerArray()
	foreach ( player in allPlayersArray )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FreeDM_AirdropNotification" )
	}

	//Don't allow another airdrop until we say so
	float timeSinceEventStart = Time() - startTime

	wait data.eventLength + timeSinceEventStart
}
#endif // SERVER

const string FREEDM_AIRDROP_ANIMATION = "droppod_loot_drop_lifeline"

#if SERVER
// Trigger an Airdrop
// Note this function needs to be a thread in order to properly clean up vfx once the airdrop lands. The airdrop functions control how long this function runs for.
void function FreeDM_LaunchAirdrop_Thread( vector pointLocation, array<string> airdropContents, float pingDuration, bool shouldUseGreenAirdropBeam = false )
{
	Assert( IsNewThread(), "Must be threaded off" )

	array<entity> fxs

	int beamIndex   = GetParticleSystemIndex( FX_AIRDROP_BEAM_CP )
	int markerIndex = GetParticleSystemIndex( $"P_ar_loot_drop_point" )
	entity beamFx   = StartParticleEffectInWorld_ReturnEntity( beamIndex, pointLocation, <0,0,0> + <0, 180, 0> )
	entity markerFx = StartParticleEffectInWorld_ReturnEntity( markerIndex, pointLocation, <0,0,0> )
	fxs.append(beamFx)
	fxs.append(markerFx)

	OnThreadEnd(
		function () : ( fxs )
		{
			foreach ( fx in fxs )
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}
		}
	)

	const float spreadRadius = 1.0
	const float ringRadius = 50.0
	const float frequency = 0.8
	const float freqVariation = 0.2

	array < entity > allAlivePlayersArray = GetPlayerArray_Alive()
	foreach ( player in allAlivePlayersArray )
	{

		Remote_CallFunction_NonReplay( player, "ServerCallback_SUR_PingMinimap", pointLocation, pingDuration, spreadRadius, ringRadius, COLORID_AIRDROP_DEFAULT_COLOR, frequency, freqVariation, eAirdropType.STANDARD )
	}

	// AirdropItems takes flat array<string> + individual params
	array<string> flatContents = [airdropContents[0], airdropContents[1], airdropContents[2]]

	thread AirdropItems( pointLocation, <0, RandomFloatRange(-180, 180), 0>, flatContents, null, FREEDM_AIRDROP_ANIMATION, null, CHEVREX_AIRDROP_SKIN_INDEX, "" )
}
#endif // SERVER

#if SERVER
// Only some characters have lines to play regarding sponsorship in Control. These lines should only play sometimes because there isn't much variety in them and they only play in reaction to specific announcer dialogue.
const float CHANCE_OF_PLAYING_SPONSORSHIP_REACTION = 0.40
const array< string > COMMENTARY_LINES_WITH_SPONSORSHIP = [
	"Host_AI_Control_Care_Package_01_01",
	"Host_AI_Control_Care_Package_01_02",
	"Host_AI_Control_Care_Package_02_01",
	"Host_AI_Control_Care_Package_02_02"]
const array< string > CONTROL_LEGENDS_ALLOWED_TO_PLAY_SPONSORSHIP_DIALOGUE = [ "character_madmaggie", "character_lifeline", "character_octane" ]
const string SPONSORSHIP_CHATTER_DIALOGUE = "bc_control_sponsorshipReact_"
const float LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_LONG = 3.5
void function FreeDM_PlayReactDialogueToSponsorshipCommentary( string commentaryPlayed )
{
	if ( GetGameState() < eGameState.WinnerDetermined )
		return

	// Check if the line of dialogue that played, should have a response at all
	if ( commentaryPlayed == "" || !( COMMENTARY_LINES_WITH_SPONSORSHIP.contains( commentaryPlayed ) ) )
		return

	array < int > allTeamsArray = GetAllTeams()
	foreach( team in allTeamsArray )
	{
		// Do random chance to play the line per squad
		bool playDialogue = RandomFloat( 1.0 ) < CHANCE_OF_PLAYING_SPONSORSHIP_REACTION
		if ( playDialogue )
		{
			entity speaker = TryFindSpeakingPlayerOnTeam_OnlyAllowSpecificCharacters( team, CONTROL_LEGENDS_ALLOWED_TO_PLAY_SPONSORSHIP_DIALOGUE )
			if ( speaker != null && LoadoutSlot_IsReady( ToEHI( speaker ), Loadout_Character() ) )
			{
				string speakerCharacterName = ItemFlavor_GetCharacterRef( LoadoutSlot_GetItemFlavor( ToEHI( speaker ), Loadout_Character() ) )

				if ( speakerCharacterName != "" )
				{
					string dialogueToPlay = SPONSORSHIP_CHATTER_DIALOGUE + speakerCharacterName
					thread PlayBattleChatterLineDelayedToSpeakerAndTeam( speaker, dialogueToPlay, LEGEND_DIALOGUE_DELAY_POST_ANNOUNCER_DIALOGUE_LONG )
				}
			}
		}
	}
}
#endif // OBJECTIVE STATE MANAGEMENT SERVER

#if CLIENT
// Display a notification when an airdrop is incoming until I figure out the VO
void function ServerCallback_FreeDM_AirdropNotification()
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) || player.GetTeam() == TEAM_SPECTATOR)
		return

	string announcementText

	announcementText = Localize( "#FREEDM_INCOMING_AIRDROP" )

	vector announcementColor = <0, 0, 0>
	Obituary_Print_Localized( announcementText, announcementColor )
	AnnouncementMessageRight( player, announcementText, "", SrgbToLinear( announcementColor / 255 ), $"", FREEDM_MESSAGE_DURATION, SFX_HUD_ANNOUNCE_QUICK, SrgbToLinear( announcementColor / 255 ) )
}
#endif // Client

#if SERVER
bool function FreeDM_AirdropStartValidation( float eventLength )
{
	bool dropConditions
	dropConditions = (GameRules_GetTeamScore( TEAM_IMC ) > GetScoreLimit_FromPlaylist() / 2) || (GameRules_GetTeamScore( TEAM_MILITIA ) > GetScoreLimit_FromPlaylist() / 2) || (Time() - GetGameStartTime()) > GetFreeDMAirdropTimeDelay()

	//Should override conditions on per mode basis here
	return GetGameState() == eGameState.Playing && dropConditions && MapNode_IsMapDataValid() && MapNode_GetAvailableAirdropLocations().len() > 0 && (Time() - file.lastAirdropTimestamp) > GetFreeDMAirdropTimeDelay()
}
#endif // SERVER

const string FREEDM_DEFAULT_AIRDROP_CONTENTS = "arenas_red_airdrop_weapons arenas_gold_airdrop_weapons arenas_gold_airdrop_weapons"
                                
                                                                                                    
      


#if SERVER
// Generate Airdrop loot
array<string> function GenerateAirdropContents( )
{
	array<string> airdropContents
	array<int> airdropContentIDs
	string airdropList = FREEDM_DEFAULT_AIRDROP_CONTENTS
                                 
                                                                                                                       
   
                                           
   
       

	array<string> airdropTokenArray = split( airdropList, WHITESPACE_CHARACTERS )
	Assert( airdropTokenArray.len() == 3 )

	array< array<string> > podContents = DetermineAirdropContents( [[airdropTokenArray[0]],  [airdropTokenArray[1]],  [airdropTokenArray[2]]] )

	foreach( array<string> contents in podContents )
	{
		Assert( contents.len() == 1 )
		airdropContents.append( contents[0] )
		airdropContentIDs.append( SURVIVAL_Loot_GetLootDataByRef( contents[0] ).index )
	}

	Assert( airdropContentIDs.len() == 3 )
	return airdropContents
}
#endif // SERVER

#if SERVER
void function OnFreeDMPlayerDisconnected(entity player )
{
 	thread OnFreeDMPlayerDisconnectedThread()
}
#endif // SERVER

#if SERVER
const float CHECK_PLAYER_COUNT_DELAY = 3.0
void function OnFreeDMPlayerDisconnectedThread( )
{
	Assert( IsNewThread(), "Must be threaded off" )

	OnThreadEnd(
		function() : ()
		{
			FreeDMCheckIsValidGame()
		}
	)

	wait CHECK_PLAYER_COUNT_DELAY
}
#endif // SERVER

#if SERVER
void function FreeDMCheckIsValidGame()
{
	// Don't run this logic if Leaver Penalty is already turned off
	if ( !GetGlobalNetBool( "mixtape_isLeaverPenaltyEnabledForMatch" ) )
		return

	bool leaverPenaltyEnabled = true
	if (AllianceProximity_IsUsingAlliances())
	{
		int ACount = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_A, false )
		int BCount = AllianceProximity_GetNumPlayersInAlliance( ALLIANCE_B, false )

		if ( leaverPenaltyEnabled )
			leaverPenaltyEnabled = abs(ACount - BCount) <= 1
	}

	if ( leaverPenaltyEnabled )
	{
		array<entity> currentPlayers = GetPlayerArray()
		leaverPenaltyEnabled = (currentPlayers.len() > (GetCurrentPlaylistVarInt( "max_players", 12 ) * (2.0 / 3.0)))
	}

	SetGlobalNetBool( "mixtape_isLeaverPenaltyEnabledForMatch", leaverPenaltyEnabled)
}
#endif // SERVER

void function FreeDM_SetScoreEventOverride()
{
	ScoreEvent_SetGameModeRelevant( GetScoreEvent( "KillPilot" ) )
}

#if CLIENT
void function FreeDM_OnPlayerLifeStateChanged( entity player, int oldState, int newState )
{

}
#endif

#if CLIENT
void function FreeDM_GamemodeInitClient()
{
	SetGameModeSuddenDeathAnnouncementSubtext( "#GAMEMODE_ANNOUNCEMENT_SUDDEN_DEATH_TDM" )
	SURVIVAL_SetGameStateAssetOverrideCallback( FreeDM_OverrideGameState )

	// TODO - rorth: do we really want to init all of survival?
	//ClGamemodeSurvival_Init() // Already called by sh_init.gnut before GameMode_RunClientInits()
	FreeDM_ScoreboardSetup()

	AddCallback_GameStateEnter( eGameState.Playing, Client_OnGameStatePlaying )
	AddCallback_GameStateEnter( eGameState.Prematch, Client_OnPrematchInit )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, Client_OnWinnerDetermined )
	AddCallback_GameStateEnter( eGameState.Resolution, Client_OnResolution )
}
#endif // CLIENT

#if CLIENT
void function Client_OnPrematchInit()
{
	if ( GameMode_AreRoundsEnabled() && GameRules_GetTeamScore2( GetLocalViewPlayer().GetTeam() ) >= GetRoundScoreLimit_FromPlaylist() )
		return

	float roundStartTime = GetCurrentPlaylistVarFloat( "freedm_prematch_intro_time", 0.0 )

	// observer modes (either spectating or fly cam) need to reset menus, because they don't get the loadout menu open)
	RunUIScript( "UICodeCallback_CloseAllMenus" )

                     
		if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) )
		{
			file.introCountdownRUI = CreateFullscreenPostFXRui( $"ui/gun_game_intro.rpak" /* freedm_countdown_timer not in S15 RPak */ )
			RuiSetGameTime( file.introCountdownRUI, "timerStartTime", GetGameStartTime() - roundStartTime )
			RuiSetGameTime( file.introCountdownRUI, "timerEndTime", GetGameStartTime() )
			RuiSetGameTime( file.introCountdownRUI, "shrinkEndTime", GetGameStartTime() + FREEDM_COUNTDOWN_TIMER_SHRINK )
			RuiSetInt( file.introCountdownRUI, "currentRound", GetRoundsPlayed() + 1 )
			RuiSetBool (file.introCountdownRUI, "roundsEnabled", IsRoundBased())
		}
		else
		{
			file.introCountdownRUI = CreateFullscreenPostFXRui( $"ui/gun_game_intro.rpak" )
			RuiSetFloat( file.introCountdownRUI, "gameStartTime", GetGameStartTime() )
		}
      
                                                                                 
                                                                            
       

	if ( GetCurrentPlaylistVarBool( "use_round_countdown_overlay", true ) )
	{
		RunUIScript("SetRespawnOverlayTime", Time(), Time() + roundStartTime)
		RunUIScript("SetRespawnOverlayString", Localize( "#ROUND_NUM_IN", GetRoundsPlayed() + 1))
		RunUIScript("SetRespawnOverlayIdleString", Localize( "#MATCH_STARTED"))
	}

	thread _CountdownIntroSoundThread()
}
#endif // CLIENT

#if CLIENT
void function _CountdownIntroSoundThread()
{
	// Wait until there are exactly 3 seconds left
	float countdownTime = 3.0
	wait GetGameStartTime() - Time() - countdownTime

	string countdownSound = GUNGAME_COUNTDOWN_SOUND
	                    
		countdownSound = GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) ? TDM_COUNTDOWN_SOUND : GUNGAME_COUNTDOWN_SOUND
       

	//Play audio event 3 times, once for each tick of the timer
	for( int i = 0; i < 3; ++i )
	{
		EmitSoundOnEntity( GetLocalViewPlayer(), countdownSound )
		wait 1.0
	}
}
#endif // CLIENT


#if CLIENT
void function Client_OnGameStatePlaying()
{
	entity localPlayer = GetLocalViewPlayer()
	if ( IsValid( localPlayer ) )
		localPlayer.ClearMenuCameraEntity()

	HudTargetInfo_Enable( true )
	if( file.displayScoreThread != null )
		thread file.displayScoreThread()
	else
		Warning( "FreeDM displayScoreThread is null! No score HUD will be displayed" )

	thread _DelayedDestroyCountdownRUI( )

	                       
		if ( BigTDM_IsModeEnabled() )
		{
			AnnouncementData announcement = Announcement_Create( Localize("#BTDM_NAME") )
			Announcement_SetSubText( announcement, Localize("#BTDM_ANNOUNCEMENT") )
			Announcement_SetHideOnDeath( announcement, true )
			Announcement_SetDuration( announcement, 7.0 )
			Announcement_SetPurge( announcement, true )
			Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
			Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
			Announcement_SetTitleColor( announcement, <0, 0, 0> )
			Announcement_SetIcon( announcement, $"" )
			Announcement_SetLeftIcon( announcement, $"rui/rui_screens/apex_logo_tdm_big" )
			Announcement_SetRightIcon( announcement, $"rui/rui_screens/apex_logo_tdm_big" )
			AnnouncementFromClass( GetLocalClientPlayer(), announcement )
		}
                             
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_SetRespawnOverlay( )
{
	float respawnTime = GetCurrentPlaylistVarFloat( "respawn_cooldown", 5.0 )
	RunUIScript( "SetRespawnOverlayTime", Time(), Time() + respawnTime )
	RunUIScript( "SetRespawnOverlayString", "#RESPAWNING_IN" )
	RunUIScript( "SetRespawnOverlayIdleString", "#READY_TO_SPAWN" )
}
#endif // CLIENT

#if CLIENT
// Countdown RUI has an outro animation, so give it a little time to play out before deleting
void function _DelayedDestroyCountdownRUI( )
{
	wait FREEDM_COUNTDOWN_TIMER_SHRINK / 2

	if( file.introCountdownRUI != null )
	{
		RuiDestroyIfAlive( file.introCountdownRUI )
		file.introCountdownRUI = null
	}
}
#endif // CLIENT

#if CLIENT
void function Client_OnWinnerDetermined( )
{
	SetSummaryDataDisplayStringsCallback(FreeDM_PopulateSummaryDataStrings)
	if( !AllianceProximity_IsUsingAlliances() )
	{
		int winningTeam = GetWinningTeam()
		if( winningTeam < TEAM_MULTITEAM_FIRST )
		{
			printt("FreeDM - Client_OnWinnerDetermined: Could not find valid winner to set winning squad name")
			return
		}
		int squadIndex = Squads_GetSquadUIIndex( winningTeam )

		entity localPlayer = GetLocalViewPlayer()
		if( IsValid( localPlayer ) && winningTeam != localPlayer.GetTeam() ) // We want to show You are the champion to the winning team
		{
			SetVictoryScreenTeamName( Localize( Squads_GetSquadNameLong( squadIndex ) ) )
		}

	}
}
#endif // CLIENT

#if CLIENT
void function Client_OnResolution( )
{
	entity localPlayer = GetLocalViewPlayer()
	if ( IsValid( localPlayer ) )
		EmitSoundOnEntity( localPlayer, file.audioEvents[eFreeDMAudioEvents.Podium_Music] )
}
#endif // CLIENT

#if CLIENT
void function DisplayScore()
{
	                    
		EmitSoundOnEntity( GetLocalViewPlayer(), TDM_ROUND_START )
                           
	
	wait FREEDM_COUNTDOWN_TIMER_SHRINK / 2
	file.scoreTrackerHUDRui = CreateCockpitPostFXRui ( $"ui/freedm_score_tracker.rpak",MINIMAP_Z_BASE + 10 )
	RuiSetGameTime( file.scoreTrackerHUDRui, "fadeInStartTime", ClientTime())

	thread FreeDM_RoundNStartingAnnouncement( FREEDM_COUNTDOWN_TIMER_SHRINK / 2 )

	while( GetGameState() < eGameState.WinnerDetermined )
	{
		WaitFrame()

		entity localPlayer = GetLocalViewPlayer()
		if( !IsValid( localPlayer ) )
			continue

		int myTeam = localPlayer.GetTeam()

		RuiSetInt( file.scoreTrackerHUDRui, "scoreLimit", GetCurrentPlaylistVarInt( "scorelimit", 30 ) )
		RuiSetBool( file.scoreTrackerHUDRui, "roundsEnabled", IsRoundBased() )
		RuiSetInt( file.scoreTrackerHUDRui, "currentRound", GetRoundsPlayed() + 1 )

		if ( AllianceProximity_IsUsingAlliances() )
		{
			for ( int allianceIndex = 0; allianceIndex < AllianceProximity_GetMaxNumAlliances() ; allianceIndex++ )
			{
				int myAlliance = AllianceProximity_GetAllianceFromTeamWithObserverCorrection( myTeam )
				int otherAlliance = AllianceProximity_GetOtherAlliance( myAlliance )

				int allianceScore = GetAllianceTeamsScore(myAlliance )
				int otherAllianceScore = GetAllianceTeamsScore( otherAlliance )

				RuiSetInt( file.scoreTrackerHUDRui, "teamScoreIMC", allianceScore )
				RuiSetInt( file.scoreTrackerHUDRui, "teamScoreMilitia", otherAllianceScore )
				RuiSetInt( file.scoreTrackerHUDRui, "teamRoundsWon0", GameRules_GetTeamScore2(myTeam) )
				RuiSetInt( file.scoreTrackerHUDRui, "teamRoundsWon1", GameRules_GetTeamScore2(AllianceProximity_GetRepresentativeTeamForAlliance( otherAlliance )) )
			}
		}
		else
		{
			RuiSetInt( file.scoreTrackerHUDRui, "teamScoreIMC", GameRules_GetTeamScore( TEAM_IMC ) )
			RuiSetInt( file.scoreTrackerHUDRui, "teamScoreMilitia", GameRules_GetTeamScore( TEAM_MILITIA ) )
		}

		RuiSetImage( file.scoreTrackerHUDRui, "customIndictorIMCTeam", GetCustomIndicator( TEAM_IMC ) )
		RuiSetImage( file.scoreTrackerHUDRui, "customIndictorMilitiaTeam", GetCustomIndicator( TEAM_MILITIA ) )
	}

	RuiDestroy( file.scoreTrackerHUDRui )
}
#endif // CLIENT

#if CLIENT
void function FreeDM_ScoreboardSetup()
{
	if( file.scoreboardSetupFunc != null )
		file.scoreboardSetupFunc()
}
#endif // CLIENT

#if CLIENT
void function FreeDM_SetScoreboardSetupFunc( void functionref() scoreBoardFunc )
{
	file.scoreboardSetupFunc = scoreBoardFunc
}
#endif

#if CLIENT
void function FreeDM_BaseScoreboardSetup()
{
	clGlobal.showScoreboardFunc = ShowScoreboardOrMap_Teams
	clGlobal.hideScoreboardFunc = HideScoreboardOrMap_Teams
	Teams_AddCallback_ScoreboardData( FreeDM_GetScoreboardData )
	Teams_AddCallback_Header( FreeDM_ScoreboardUpdateHeader )
	//Teams_AddCallback_GetTeamColor( FreeDM_ScoreboardGetTeamColor ) // todo: turn me back on when ready to set this
	Teams_AddCallback_PlayerScores( FreeDM_GetPlayerScores )
	Teams_AddCallback_SortScoreboardPlayers( FreeDM_SortPlayersByScore )
}
#endif // CLIENT

#if CLIENT
ScoreboardData function FreeDM_GetScoreboardData()
{
	ScoreboardData data
	data.numScoreColumns = 3

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_kills_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 2 )

	data.columnDisplayIcons.append( $"rui/hud/gamestate/assist_count_icon2" )
	data.columnDisplayIconsScale.append( 0.8 )
	data.columnNumDigits.append( 2 )

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_damage_dealt_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 4 )

	return data
}
#endif // CLIENT

#if CLIENT
array< string > function FreeDM_GetPlayerScores( entity player )
{
	array< string > scores

	string eliminations = string( player.GetPlayerNetInt( "kills" ) )
	scores.append( eliminations )

	string assists = string( player.GetPlayerNetInt( "assists" ) )
	scores.append( assists )

	string damage = string( player.GetPlayerNetInt( "damageDealt" ) )
	scores.append( damage )

	return scores
}
#endif // CLIENT


#if CLIENT
array< TeamsScoreboardPlayer > function FreeDM_SortPlayersByScore( array< TeamsScoreboardPlayer > players )
{
	players.sort( int function( TeamsScoreboardPlayer a, TeamsScoreboardPlayer b )
	{
		entity playerA = FromEHI( a.playerEHI )
		entity playerB = FromEHI( b.playerEHI )

		if( !IsValid( playerA ) || !IsValid( playerB ) )
			return 0

		//if gungame sort by gun number
		int aKills = playerA.GetPlayerNetInt( "kills" )
		int bKills = playerB.GetPlayerNetInt( "kills" )
		int aAssists = playerA.GetPlayerNetInt( "assists" )
		int bAssists = playerB.GetPlayerNetInt( "assists" )
		int aDamage = playerA.GetPlayerNetInt( "damageDealt" )
		int bDamage = playerB.GetPlayerNetInt( "damageDealt" )

		if ( aKills > bKills ) return -1
		else if ( aKills < bKills ) return 1
		else
		{
			if ( aAssists > bAssists ) return -1
			else if ( aAssists < bAssists ) return 1
			else
			{
				if ( aDamage > bDamage ) return -1
				else if ( aDamage < bDamage ) return 1
				return 0
			}
		}
		return 0
	}
	)

	return players
}
#endif // CLIENT

#if CLIENT
void function FreeDM_ScoreboardUpdateHeader( var headerRui, var frameRui, int team )
{

}
#endif // CLIENT

#if CLIENT
vector function FreeDM_ScoreboardGetTeamColor( int team )
{
	return < 0,0,0 >
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_FreeDM_AnnounceRoundWonLost( int winningTeamOrAlliance )
{
	entity localPlayer = GetLocalViewPlayer()
	int localPlayerTeam = localPlayer.GetTeam()
	int localPlayerAlliance = AllianceProximity_GetAllianceFromTeam( localPlayerTeam )
	bool isObserver = GamemodeUtility_IsPlayerOnTeamObserver( localPlayer )

	bool isLocalPlayerOnWinningTeamOrAlliance = AllianceProximity_IsUsingAlliances() ? localPlayerAlliance == winningTeamOrAlliance : localPlayerTeam == winningTeamOrAlliance

	if ( !IsAlive(localPlayer) )
		RunUIScript( "UICodeCallback_CloseAllMenus" )

	if ( isObserver )
	{
		AnnouncementMessageSweep( localPlayer, Localize( "#GAMEMODE_ROUND_WIN") )
	}
	else
	{
		if ( isLocalPlayerOnWinningTeamOrAlliance )
		{
                       
				if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) )
					TDMAnnouncementRoundWon(Localize( "#GAMEMODE_ROUND_WIN"))
				else
					AnnouncementMessageSweep( localPlayer, Localize( "#GAMEMODE_ROUND_WIN"))
        
                                                                            
                             
		}
		else
		{
			AnnouncementMessageSweep( localPlayer, Localize( "#GAMEMODE_ROUND_LOSS"))
			                    
				EmitSoundOnEntity( GetLocalViewPlayer(), TDM_ROUND_LOSS )
                             
		}
	}
	thread FreeDM_DelayedShowScoreboard()
}
#endif // CLIENT

#if CLIENT
void function FreeDM_RoundNStartingAnnouncement( float delay = 0.0 )
{
	wait delay

	if (IsRoundBased())
	{
		wait FREEDM_COUNTDOWN_TIMER_SHRINK / 2
		AnnouncementData announcement = Announcement_Create( Localize( "#GAMESTATE_ROUND_N", GetRoundsPlayed() + 1 ) )
		Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING )
		Announcement_SetPurge( announcement, true )
		Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
		Announcement_SetPriority( announcement, 200 )
		announcement.duration = FREEDM_MESSAGE_DURATION
		AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	}
}
#endif

#if CLIENT
void function TDMAnnouncementRoundWon( string message, string subText = "", float duration = 2.0 )
{
	AnnouncementData announcement = Announcement_Create( message )
	bool displayNow = InitializeAnnouncement_ShouldDisplayNow( announcement, message )
	announcement.subText = subText
	announcement.announcementStyle = ANNOUNCEMENT_STYLE_TDM_ROUND_WON
	announcement.duration = duration
	announcement.drawOverScreenFade = true
	announcement.priority = 1000
	announcement.purge = true

	if ( displayNow )
	{
		thread AnnouncementMessage_Display( GetLocalClientPlayer(), announcement )
		EmitSoundOnEntity( GetLocalViewPlayer(), TDM_ROUND_WON )
	}
}
#endif

#if CLIENT
void function FreeDM_DelayedShowScoreboard()
{
	wait FREEDM_ROUND_WIN_ANNOUNCMENT_TIME

	                    
		if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ))
		{
			wait FREEDM_POST_ROUND_SCOREBOARD_TIME
			RunUIScript( "TDM_ShowScoreboard" )
			wait FREEDM_POST_ROUND_SCOREBOARD_TIME
			RunUIScript( "TDM_HideScoreboard" )
		}
       
}
#endif // CLIENT

#if CLIENT
void function ServerCallback_FreeDM_ChampionSounds( int winningTeamOrAlliance )
{
	entity localPlayer = GetLocalClientPlayer()

	bool isWinner = false

	if ( AllianceProximity_IsUsingAlliances() )
		isWinner = AllianceProximity_GetAllianceFromTeam( localPlayer.GetTeam() ) == winningTeamOrAlliance
	else
		isWinner = localPlayer.GetTeam() == winningTeamOrAlliance

	var endMusic
	var endSound
	if( isWinner )
	{
		endSound = EmitSoundOnEntity_NoTimeScale( localPlayer, file.audioEvents[eFreeDMAudioEvents.Victory_Sound] )
		endMusic = EmitSoundOnEntity_NoTimeScale( localPlayer, file.audioEvents[eFreeDMAudioEvents.Victory_Music] )
	}
	else
	{
		endSound = EmitSoundOnEntity_NoTimeScale( localPlayer, file.audioEvents[eFreeDMAudioEvents.Defeat_Sound] )
		endMusic = EmitSoundOnEntity_NoTimeScale( localPlayer, file.audioEvents[eFreeDMAudioEvents.Loss_Music] )
	}

	                         
		CrowdNoiseMeter_PlayGameEndSound( localPlayer, isWinner )
                                

	                  
		SetPlayThroughKillReplay( endMusic )
		SetPlayThroughPOVTransitions( endMusic )
		SetPlayThroughKillReplay( endSound )
		SetPlayThroughPOVTransitions( endSound )
                             
}
#endif

#if CLIENT
void function AnnouncementMessageWarning( entity player, string messageText, vector titleColor, string soundAlias, float duration )
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
void function UICallback_FreeDM_OpenCharacterSelect()
{
	//safety so if this gets called outside of the mode due to a button callback, we can cancel the state
	Assert( GameMode_IsActive( eGameModes.FREEDM ) )
	if ( !GameMode_IsActive( eGameModes.FREEDM ) )
		return

	entity clientPlayer = GetLocalClientPlayer()

	Assert( IsValid( clientPlayer ), "IsValid( clientPlayer ) in sh_gamemode_freedm.nut UICallback_FreeDM_OpenCharacterSelect" )
	if ( !IsValid( clientPlayer ) )
		return

	const bool browseMode = true
	const bool showLockedCharacters = true
	bool isJIP = GamemodeUtility_IsJIPPlayerSpawnBonusPending( clientPlayer )
	HideScoreboard()
	OpenCharacterSelectMenu( browseMode, showLockedCharacters, isJIP )
}
#endif // CLIENT

#if CLIENT
void function FreeDM_CloseCharacterSelect()
{
	if ( !GameMode_IsActive( eGameModes.FREEDM ) )
		return

	HideScoreboard()
	CloseCharacterSelectMenu()
}
#endif // CLIENT

#if CLIENT
void function FreeDM_OverrideGameState()
{
	// TODO - rorth: Make TDM versions of these ui files
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_freedm_mode.rpak" )
	ClGameState_RegisterGameStateFullmapAsset( $"ui/gamestate_info_fullmap_freedm.rpak" )
}
#endif // CLIENT

#if CLIENT
void function FreeDM_SetIsScoreText( bool val )
{
	file.isScoreText = val
}
#endif // CLIENT

#if CLIENT
bool function IsScoreText( )
{
	return file.isScoreText
}
#endif // CLIENT

#if CLIENT
void function FreeDM_SetDisplayScoreThread( void functionref() displayFunc )
{
	file.displayScoreThread = displayFunc
}
#endif

#if CLIENT
void function FreeDM_SetCustomIndicatorCallBack( asset functionref( int team) func )
{
	file.getCustomIndicatorCallback = func
}
#endif // CLIENT

#if CLIENT
asset function GetCustomIndicator( int team )
{
	return file.getCustomIndicatorCallback == null ? $"" : file.getCustomIndicatorCallback( team )
}
#endif // CLIENT

#if CLIENT
void function FreeDM_SetCharacterInfo( var rui, int infoIndex, entity player )
{
	if( !IsValid( player ) )
		return

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )

	RuiSetImage( rui, "portraitImage_" + infoIndex, CharacterClass_GetGalleryPortrait( character ) )
	RuiSetBool( rui, "portraitImageVisible_" + infoIndex, true )
	RuiSetColorAlpha( rui, "portraitBorderColor_" + infoIndex, GetPlayerInfoColor( player ), 1.0 )
}
#endif // CLIENT

#if CLIENT

void function FreeDM_PopulateSummaryDataStrings( SquadSummaryPlayerData data )
{
	data.modeSpecificSummaryData[0].displayString = "#DEATH_SCREEN_SUMMARY_KILLS"
	data.modeSpecificSummaryData[1].displayString = "#DEATH_SCREEN_SUMMARY_ASSISTS"
	data.modeSpecificSummaryData[2].displayString = ""
	data.modeSpecificSummaryData[3].displayString = "#DEATH_SCREEN_SUMMARY_DAMAGE_DEALT"
	data.modeSpecificSummaryData[4].displayString = ""
	data.modeSpecificSummaryData[5].displayString = ""
	data.modeSpecificSummaryData[6].displayString = ""
}
#endif

int function FreeDM_GetNumTeams()
{
	int teams = 0;
	if ( AllianceProximity_IsUsingAlliances() )
		teams = AllianceProximity_GetMaxNumAlliances()
	else
		teams = GetNumTeamsExisting()
	return teams
}

int function FreeDM_GetOtherTeam( int team )
{
	return -team + ( TEAM_IMC + TEAM_MILITIA )
}

int function FreeDM_GetCratesPerAirDrop()
{
	return GetCurrentPlaylistVarInt( "freedm_airdrops_crates_per_airdrop", 1 )
}

float function GetDroppedLootLifetime()
{
	return GetCurrentPlaylistVarFloat( "freedm_dropped_loot_persist_time", -1.0 )
}

bool function GetFreeDMAreAirdropsEnabled()
{
	return GetCurrentPlaylistVarBool( "freedm_airdrops_enabled", false )
}
float function GetFreeDMAirdropTimeDelay()
{
	return GetCurrentPlaylistVarFloat( "freedm_airdrops_time_delay", 30 )
}

float function GetDroppedLootCleanupScanPeriod()
{
	return GetCurrentPlaylistVarFloat( "freedm_dropped_loot_cleanup_scan_period", 0.0 )
}

bool function GetShouldShuffleLoadoutsRounds()
{
	return GetCurrentPlaylistVarBool( "round_shuffle_loadouts", false )
}

int function GetPlayMusicOnScore()
{
	return GetCurrentPlaylistVarInt( "start_music_and_vo_on_kills_remaining", FREEDM_MUSIC_START_ON_KILLS_LEFT )
}

#if SERVER
// Get the appropriate music controller value for the ramp up music system based on how close we are to the match ending ( based on score )
float function FreeDM_GetRampUpMusicControllerValueFromScore( int scoreLeft )
{
	float controllerValue     = MUSIC_CONTROLLER_LEVEL_NOT_SET
	int scoreLimit            = GetScoreLimit_FromPlaylist()
	int scoreLeftToStartMusic = GetPlayMusicOnScore() + ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) ? 0 : 1 ) // + 1 for Gun Run since score starts at 1 for all teams
	int highestScore          = scoreLimit - scoreLeft

	if (  highestScore >= scoreLimit - int( scoreLeftToStartMusic * RAMPUP_MUSIC_SCORE_THRESHOLD_3 ) )
		controllerValue = MUSIC_CONTROLLER_LEVEL_4
	else if ( highestScore >= scoreLimit - int( scoreLeftToStartMusic * RAMPUP_MUSIC_SCORE_THRESHOLD_2 ) )
		controllerValue = MUSIC_CONTROLLER_LEVEL_3
	else if ( highestScore >= scoreLimit - int( scoreLeftToStartMusic * RAMPUP_MUSIC_SCORE_THRESHOLD_1 ) )
		controllerValue = MUSIC_CONTROLLER_LEVEL_2
	else if ( highestScore >= scoreLimit - scoreLeftToStartMusic )
		controllerValue = MUSIC_CONTROLLER_LEVEL_1

	return controllerValue
}
#endif // Server

#if SERVER
// Start playing ramp up music based on score remaining before the match ends
// Set that value but based on the scoring values we use to first start ramping up the music in FreeDM_GetRampUpMusicControllerValueFromScore
int function FreeDM_GetRampUpMusicStartScoreValue()
{
	int scoreLimit = GetScoreLimit_FromPlaylist()
	int scoreAtFirstThreshold = GetPlayMusicOnScore()
	int scoreRemainingToStartMusic = scoreLimit - scoreAtFirstThreshold

	return scoreRemainingToStartMusic
}
#endif // SERVER

#if DEVELOPER
#if SERVER
void function DEV_FreeDM_IncrementScore(entity player, int amount = 1)
{
	FreeDM_AddTeamScore( player.GetTeam(), amount )
}

void function DEV_FreeDM_EndMatch( int winningTeam )
{
	// TODO: add check that winningTeam is valid, this can go into threaded stuff and we'll lose the callstack when it actually errors on a bad team
	SetRoundBased( false )
	FreeDM_SetMatchWinner( winningTeam, eWinReason.SCORE_LIMIT )
}
#endif
#endif

#if DEVELOPER
#if CLIENT
void function DEV_ScoreTrackAnimateIn()
{
	float roundStartTime = GetCurrentPlaylistVarFloat( "freedm_prematch_intro_time", 0.0 )

	if (file.introCountdownRUI == null)
	{
		// reset score tracker
		RuiSetGameTime( file.scoreTrackerHUDRui, "fadeInStartTime", RUI_BADGAMETIME )

		// recreate countdown timer and animate in
		file.introCountdownRUI = CreateFullscreenPostFXRui( $"ui/gun_game_intro.rpak" /* freedm_countdown_timer not in S15 RPak */ )
		RuiSetGameTime( file.introCountdownRUI, "timerStartTime", ClientTime() )
		RuiSetGameTime( file.introCountdownRUI, "timerEndTime", ClientTime() + roundStartTime )
		RuiSetGameTime( file.introCountdownRUI, "shrinkEndTime", ClientTime() + roundStartTime + FREEDM_COUNTDOWN_TIMER_SHRINK )
		wait roundStartTime + FREEDM_COUNTDOWN_TIMER_SHRINK / 2

		// animate in score tracker
		RuiSetGameTime( file.scoreTrackerHUDRui, "fadeInStartTime", ClientTime() )
		wait FREEDM_COUNTDOWN_TIMER_SHRINK / 2

		// destroy countdown timer
		RuiDestroyIfAlive(file.introCountdownRUI)
		file.introCountdownRUI = null

		if (IsRoundBased())
		{
			AnnouncementData announcement = Announcement_Create( Localize( "#GAMESTATE_ROUND_N", GetRoundsPlayed() + 1 ) )
			Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING )
			Announcement_SetPurge( announcement, true )
			Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
			Announcement_SetPriority( announcement, 200 )
			announcement.duration = FREEDM_MESSAGE_DURATION
			AnnouncementFromClass( GetLocalViewPlayer(), announcement )
		}
	}
}
#endif
#endif

                       