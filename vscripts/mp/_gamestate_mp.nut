untyped

global function GameState_Init_MP
global function GameState_EntitiesDidLoad
global function GameState_OnPlayerChangedTeam

global function SetGameState

global function WaittillGameStateOrHigher

global function CodeCallback_GamerulesThink
global function CheckMap

global function SetSwitchSidesBased
global function SetRoundBasedUsingTeamScore
global function SetRoundBasedUsingTeamScore_RoundReset
global function SetForceNoMoreRounds
global function SetForceNoFinalRoundDraws

global function GetGameWonAnnouncement
global function SetGameWonAnnouncement
global function GetGameLostAnnouncement
global function SetGameLostAnnouncement

global function GetResolutionDuration
global function GetCustomResolutionDuration
global function SetCustomResolutionDuration

global function CheckForAndTrySetEliminationModeWinner

global function GetWinnerDeterminedWait
global function RoundScoreLimit_Complete

global function SetWinner

global function PerfInitLabels
global function ForceResolutionEnd

global function ForceEliminationModeWinner

global function AddPilotEliminationDialogueCallback

global function GetCustomIntroLength
global function SetCustomIntroLength
global function SetCustomWinnerDeterminedLength

global function SetEndRoundPlayerState
global function PlayerEnterEndRoundState
global function AwardEndOfMatchAwards
global function ClearPlayers
global function ClearWeapons
global function ShouldClearPlayersInWinnerDetermined
global function IsWinnerDeterminedPlayable
global function IsRoundBasedGameOver
global function ProtectTeamFromElimination
global function ClearTeamEliminationProtection
global function SetRoundWinningKillEnabled
global function SetRoundWinningKillReplayEntities
global function ClearRoundWinningKillReplayEntities
global function SetDefaultRoundWinningKillReplayEntities
global function RoundWinningKillReplay
global function CleanUpMarkedEntsOnRoundStart

global function RoundBasedTimeOver
global function SetTimelimitCompleteFunc
global function SetAnnounceRoundWinnerRules

global function SetAbandonCheckFunc

global function SetClearTitanTimersOnPlayingEnter
global function SetClearBurnRewardsOnPlayingEnter
global function ClearBurnRewardsOnPlayingEnter
global function ClearTitanTimersOnPlayingEnter
global function ClearPlayer

global function WillShowRoundWinningKillReplay

global function SetPlayThreeMinuteMusic

global function GetMatchWinnerFromScore

global function GameState_SetTimeLimitOverride
global function GameState_GetTimeLimitOverride

global function GetConnectedPlayers
global function AllTeamsConnected

global function InitialPlayerSpawnOccurred

global function MarkEntForCleanupOnRoundEnd
global function MarkEntForCleanupOnWinnerDetermined
#if DEVELOPER
global function TestRoundWinningReplay
#endif
global function GameState_HasRoundRestarted

global function AddCallback_ShouldPlayerSpawnAtStart
global function DoesCurrentModeHaveMapSetup
global function DoesCurrentModeHaveDeathfield
global function GetHasGameTimedOut

enum eMatchScoreCloseness
{
	BLOWOUT,
	CLOSE,
	AVERAGE
}


struct {
	table teamProtectedFromElimination = {
		[ TEAM_MILITIA ] = false,
		[ TEAM_IMC ] = false
	}

	bool clearTitanTimersOnPlayingEnter = true
	bool clearBurnRewardsOnPlayingEnter = true

	int gameState = -1

	bool endingMatch = false
	void functionref( int )	announceRoundWinnerRules
	bool functionref( entity ) shouldPlayerSpawnAtStartCallback
	bool shouldPlayThreeMinuteMusic = false
	bool hasTriggeredThirtySecondCallbacks = false

	float timeLimitOverride = -1
	bool initialPlayerSpawnOccurred = false

	float waitForPlayersStartTime
	float waitForPlayersEndTime

	int gamePermanentsIdx
	int roundPermanentsIdx

	float customIntroLength
	float customWinnerDeterminedLength = -1.0

	bool gameTimedOut = false

	//RoundWinningKillReplay related
	entity roundWinningKillReplayViewEnt = null
	entity roundWinningKillReplayVictim = null
	int roundWinningKillReplayInflictorEHandle = -1
	bool watchingRoundWinningKillReplay = false
	float roundWinningKillReplayKillTime = -1

	void functionref() resolutionCompletedCleanupFunc
} file

float function GameState_GetTimeLimitOverride()
{
	return file.timeLimitOverride
}

void function GameState_SetTimeLimitOverride( float timeLimitOverride )
{
	if ( IsPrivateMatch() )
		return

	file.timeLimitOverride = timeLimitOverride
}

void function SetGameState( int newState )
{
	Assert( newState >= 0 )
	Assert( newState < eGameState._count_ )

	if ( newState == GetGameState() )
		return

	printf( "Setting game state to: " + GetEnumString( "eGameState", newState ) )

	SvDemo_ConsistencyCheckString( "SetGameState()" )
	SvDemo_ConsistencyCheckInt( GetGameState() )
	SvDemo_ConsistencyCheckInt( newState )

	SetGameStateChangeTime( Time() )
	SetGlobalNonRewindNetInt("gameState", newState)

	try { Signal( svGlobal.levelEnt, "GameStateChanged", { newState = newState } ) }
	catch (e) {}

	foreach ( callbackFunc in svGlobal.gameStateEnterCallbacks[ newState ] )
	{
		callbackFunc()
	}

	SvDemo_ConsistencyCheckString( "SetGameState() B" )

	switch ( newState )
	{
		case eGameState.WaitingForCustomStart:
			GameStateEnter_WaitingForCustomStart()
			break

		case eGameState.WaitingForPlayers:
			GameStateEnter_WaitingForPlayers()
			break

		case eGameState.PickLoadout:
			GameStateEnter_PickLoadOut()
			break

		case eGameState.Prematch:
			GameStateEnter_Prematch()
			break

		case eGameState.Playing:
			GameStateEnter_Playing()
			break

		case eGameState.SuddenDeath:
			GameStateEnter_SuddenDeath()
			break

		case eGameState.WinnerDetermined:
			GameStateEnter_WinnerDetermined()
			break

		case eGameState.SwitchingSides:
			GameStateEnter_SwitchingSides()
			break

		case eGameState.Epilogue:
			GameStateEnter_Epilogue()
			break

		case eGameState.Resolution:
			//if ( !level.isTestmap && IsHighPerfDevServer() ) //Commenting out again before we make the real build
			//	delaythread( GAME_RESOLUTION_PLAYER_RESPAWN_LEEWAY + 5 ) DumpSpawnData()
			GameStateEnter_Resolution()
			break

		case eGameState.Postmatch:
			GameStateEnter_Postmatch()
			break

		default:
			Assert( false, "Unknown game state" )
	}

	SvDemo_ConsistencyCheckString( "SetGameState() C" )

	foreach ( callbackFunc in svGlobal.gameStateEnteredCallbacks[ newState ] )
	{
		callbackFunc()
	}

	SvDemo_ConsistencyCheckString( "SetGameState() D" )
}

void function GameStateEnter_WaitingForCustomStart()
{
	FlagClear( "GamePlaying" )
	SetGameStartTime( Time() + 980)
}

void function GameStateEnter_WaitingForPlayers()
{
	FlagClear( "GamePlaying" )

	//ConnectionTempBanClear() // release temporary bans

	SetGameStartTime( Time() + 980)

	// start failsafe timer
	file.waitForPlayersStartTime = (Time() + PreGame_GetWaitingForPlayersDelayMin())
	file.waitForPlayersEndTime = (Time() + PreGame_GetWaitingForPlayersDelayMax())

	if ( Freelance_IsHubLevel() )
		file.waitForPlayersEndTime = Time() + 1.0

	GameStartSpawnPlayers()
}

void function GameStateEnter_PickLoadOut()
{
	if ( GameState_HasRoundRestarted() )
	{
		ClearWeapons()
		CleanUpMarkedEntsOnRoundStart()
	}
}

void function GameStateEnter_Prematch()
{
	FlagSet( "ReadyToStartMatch" )
	FlagClear( "GamePlaying" )
	file.gameTimedOut = false
	PerfInitLabels()

	SetPrematchStartTime()

	ClearWeapons()

	level.clearedPlayers = false
	level.lastTimeLeftSeconds = 0

	if ( GameState_HasRoundRestarted() )
		CleanUpMarkedEntsOnRoundStart()
	GameStartSpawnPlayers()
}

void function GameStartSpawnPlayers()
{
	file.initialPlayerSpawnOccurred = true

	array<entity> players = GetPlayerArrayIncludingSpectators()
	foreach ( player in players )
	{
		if ( !IsValid( player ) )
			continue
		if ( IsAlive( player ) )
			continue
		if ( (file.shouldPlayerSpawnAtStartCallback != null) && !file.shouldPlayerSpawnAtStartCallback( player ) )
			continue

		ClearPlayerEliminated( player )

		if ( GameState_HasRoundRestarted() )
			ScreenFadeFromBlack( player, 0.25, 0.25 )

		UnMuteAll( player )
		TakeAllPassives( player )
		DecideRespawnPlayer( player, false )
	}

	AllPlayersUnMuteAll()
}

void function GameStateEnter_Playing()
{
	//Reset Titan timers at the very start of match start, in case of late connects, intros, etc
	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		player.UnfreezeControlsOnServer()

		UnMuteAll( player )
	}

	if ( IsRoundBased() )
	{
		if ( GetRoundTimeLimit_ForGameMode() > 0.0 )
		{
			int timeLimit = int( GetRoundTimeLimit_ForGameMode() * 60.0 )

			if ( timeLimit > 0 )
				SetRoundEndTime( Time() + timeLimit )
		}

		SetRoundStartTime( Time() )
		StatsHook_RoundStart( GetRoundsPlayed() + 1 )
	}
	else
	{
		if ( GetTimeLimit_ForGameMode() > 0.0 )
		{
			int timeLimit = int( GetTimeLimit_ForGameMode() * 60.0 )

			if ( timeLimit > 0 )
				SetGameEndTime(Time() + timeLimit)
			else
				Assert( false, "TimeLimit is enabled but TimeLimitFromPlaylist is 0" )
		}
	}

	//GameRules_UpdateCrossPlayGen5Pc()

	FlagSet( "GamePlaying" )
}

void function GameStateEnter_SuddenDeath()
{
	int timeExtension = int( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 )

	if ( IsRoundBased() )
		SetRoundEndTime( GetRoundEndTime() + timeExtension )
	else
		SetGameEndTime( GetGameEndTime() + timeExtension)

	//Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
}

int function CalcSecondsAliveForPlayer( entity player )
{
	printt("stub CalcSecondsAliveForPlayer, implement")
	return 1
}

void function GameStateEnter_WinnerDetermined()
{
	array<entity> players = GetPlayerArray()

	if ( IsRoundBased() )
	{
		int roundNum = GetRoundsPlayed() + 1

		SetRoundsPlayed( roundNum )
		SetRoundEndTime( Time() )

		foreach ( player in players )
		{
			int secondsAlive = CalcSecondsAliveForPlayer( player )
			player.p.savedSecondsAlive += secondsAlive
			GameSummary_GetPlayerData( player ).survivalTime = player.p.savedSecondsAlive
		}

		if ( !RoundScoreLimit_Complete() )
		{
			//Call the function specified for the round win.
			int  winningTeam = GetNetWinningTeam()

			if ( file.announceRoundWinnerRules != null )
				file.announceRoundWinnerRules( winningTeam )

			foreach ( player in players )
			{
				if ( player.GetTeam() == winningTeam )
					AddPlayerScore( player, "RoundVictory" )

				AddPlayerScore( player, "RoundComplete" )
				ScreenFade( player, 0, 0, 0, 255, GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER, 0, FFADE_OUT | FFADE_STAYOUT )

				SetPlayerEliminated( player )
				PlayerEnterEndRoundState( player )

			}

			if ( !WillShowRoundWinningKillReplay() && ShouldClearPlayersInWinnerDetermined() )
				thread RoundEndMuteAllAfterDelay( GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER )

			if ( WillShowRoundWinningKillReplay() )
				thread RoundWinningKillReplay()

			StatsHook_RoundEnd( roundNum )
			return
		}

		SetGlobalNonRewindNetBool("roundScoreLimitComplete", true)

		StatsHook_RoundEnd( roundNum )
	}

	SetGameEndTime( Time() )

	if ( !IsPrivateMatch() )
		thread AwardEndOfMatchAwards()

	if ( WillShowRoundWinningKillReplay() )
	{
		players = GetPlayerArray()
		foreach ( player in players )
			SetPlayerEliminated( player )

		thread RoundWinningKillReplay()
	}
	//#if HAS_EVAC
	//else if ( ShouldRunEvac() ) //RoundWinningKillReplay doesn't work with Evac!
	//
	//	if (GetCurrentPlaylistVarInt( "at_coop_rules", 0 ) == 0)
	//		thread EvacMain( GetOtherTeam( expect int( level.nv.winningTeam ) ) )
	//	else
	//		//thread EvacMain( expect int( level.nv.winningTeam ) )
	//		thread EvacOnDemand(GetPlayerArray()[0].GetTeam(), 1000, 1000)
	//#endif

	CheckForEmptyTeamVictory()

	StatsHook_GameEnd()

	CleanUpMarkedEntsOnWinnerDetermined()
}

void function RoundEndMuteAllAfterDelay( float delay )
{
	wait delay

	if ( IsRoundBased() )
	{	// Round Based only - use a specific mute all sound that doesn't duck VO
		array<entity> players = GetPlayerArray()
		foreach ( player in players )
			EmitSoundOnEntityOnlyToPlayer( player, player, "2_second_fadeout_ArenasRoundEnd" )
	}
	else
	{
		AllPlayersMuteAll()
	}
}

void function GameStateEnter_SwitchingSides()
{
	thread GameStateEnter_SwitchingSides_threaded()
}

void function GameStateEnter_SwitchingSides_threaded() //Threaded off primarily because GameStateEnter functions shouldn't have time passing in them, but we want RoundWinningKillReplay stuff to go first before SwitchingSides stuff happens. Would be easier if we could make RoundWinningKillReplay its own gamestate
{
	if ( WillShowRoundWinningKillReplay() )
		thread RoundWinningKillReplay()

	if ( IsRoundBased() )
		SetSwitchedSides( GetRoundsPlayed() )
	else
		SetSwitchedSides( 1 )

	int attackingTeam = GetGlobalNetInt( "attackingTeam" )

	if ( attackingTeam != TEAM_UNASSIGNED )
		SetGlobalNetInt( "attackingTeam", GetOtherTeam( attackingTeam ) )

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		player.p.respawnCount = 0
		SetPlayerEliminated( player )
		ScreenFade( player, 0, 0, 2, 255, GetSwitchingSidesWait() - CLEAR_PLAYERS_BUFFER, CLEAR_PLAYERS_BUFFER, FFADE_OUT )
		PlayerEnterEndRoundState( player )

		//MuteAll( player )
		UnMuteAll( player )

		//Only mute halftime if we've already shown our kill replay or we aren't going to show it.
		//Handles cases, such as ctf, where the kill replay is shown after the half-time announcement.
		if ( !WillShowRoundWinningKillReplay() )
			MuteHalfTime( player ) //Mute everything except halftime sounds and dialogue
	}

	SwapSpawnpointTeams()

	//EmitSoundToTeamPlayers( "UI_InGame_SwitchingSides", TEAM_MILITIA )
	//EmitSoundToTeamPlayers( "UI_InGame_SwitchingSides", TEAM_IMC )

	//delaythread( 0.75 ) PlayConversationToTeam( "SwitchingSides", TEAM_MILITIA )
	//delaythread( 0.75 ) PlayConversationToTeam( "SwitchingSides", TEAM_IMC )

	//#if FACTION_DIALOGUE_ENABLED
	//	ForcePlayFactionDialogueToAll( "mp_halftime" )
	//#endif
}


void function GameStateEnter_Epilogue()
{

}

void function GameStateEnter_Resolution()
{
	StatsInternals_EndStats()

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		SaveDatePlayed( player )
		SaveDateLoggedIn( player )

		if( player.IsEntAlive() )
			player.StopPhysics() //stops player from playing falling audio during winner screen
	}
}

void function GameStateEnter_Postmatch()
{
	FlagClear( "GamePlaying" )
	svGlobal.levelEnt.Signal( "GameEnd" )

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( ShouldShowLossProtectionOnEOG( player ) )
			SendHudMessage( player, "#LATE_JOIN_NO_LOSS_EOG_SCOREBOARD", -1, 0.4, 255, 255, 255, 255, 1.0, 2.0, 5.0 ) //Janky, need it to show up past the screenfade. Fix with better hud next game

		ScreenFade( player, 0, 2, 1, 255, 1.0, 0.0, FFADE_OUT | FFADE_STAYOUT )
		player.FreezeControlsOnServer()
		thread DelayedHolsterViewModelAndDisableWeapons( player ) //To stop stuff like weapon rumble
		player.SetInvulnerable() // Don't let the player get killed when controls are frozen
	}

	AllPlayersMuteAll( 4 )
}

void function SetPrematchStartTime()
{
	float newGameStartTime = Time() + GetCustomIntroLength()
	SetGameStartTime( newGameStartTime )
	if ( IsRoundBased() )
		SetRoundStartTime( newGameStartTime )
}

bool function WillShowRoundWinningKillReplay()
{
	if ( IsRoundWinningKillReplayEnabled() != true )
		return false

	int currentGameState = GetGameState()
	if ( (currentGameState != eGameState.WinnerDetermined) && (currentGameState != eGameState.SwitchingSides) )
		return false

	if ( file.roundWinningKillReplayViewEnt == null ) //Check for null specifically instead of IsValid because players can disconnect and become invalid, and we only want this to be false because we set it to null explicitly. ( Want to tell people that round winning kill replay was cancelled if a player disconnected)
		return false

	if ( (svGlobal.winReason != eWinReason.SCORE_LIMIT) && (svGlobal.winReason != eWinReason.ELIMINATION) )
		return false

	if ( IsRoundBased() ) //Note the order of the checks: RoundBasedModes that are also SwitchSidesBased will show in WinnerDetermined.
		return (currentGameState == eGameState.WinnerDetermined)

	if ( IsSwitchSidesBased() )
		return (currentGameState == eGameState.SwitchingSides)

	return true
}

float function GetSwitchingSidesWait()
{
	float waitTime = SWITCHING_SIDES_DELAY

	if ( WillShowRoundWinningKillReplay() )
		waitTime = SWITCHING_SIDES_DELAY_REPLAY + GetRoundWinningKillReplayTotalLength()

	return waitTime
}

bool function ShouldClearPlayersInWinnerDetermined()
{
	if ( !IsRoundBased() )
		return false

	if ( WillShowRoundWinningKillReplay() )
	{
		if ( RoundScoreLimit_Complete() ) //Don't do clear players in final round to avoid a bug with not consuming Titan Burn Cards
			return false
		else
			return true
	}

	if ( !RoundScoreLimit_Complete() )
		return true

	return false
}

float function GetWinnerDeterminedWait()
{
	if ( file.customWinnerDeterminedLength >= 0.0 )
		return file.customWinnerDeterminedLength

	if ( IsRoundBased() )
	{
		if ( WillShowRoundWinningKillReplay() )
		{
			if ( RoundScoreLimit_Complete() )
				return GetRoundWinningKillReplayTotalLength() + GAME_WINNER_DETERMINED_FINAL_ROUND_ROUND_WINNING_KILL_REPLAY_DELAY
			else
				return GetRoundWinningKillReplayTotalLength() + GAME_WINNER_DETERMINED_ROUND_WAIT_ROUND_WINNING_KILL_REPLAY_DELAY
		}
		else if ( RoundScoreLimit_Complete() )
		{
			//#if HAS_EVAC
			//if ( ShouldRunEvac() )
			//	return GAME_WINNER_DETERMINED_FINAL_ROUND_WAIT
			//else
			//	return GAME_WINNER_DETERMINED_WAIT
			//#else
			return GAME_WINNER_DETERMINED_WAIT
			//#endif
		}
		else
		{
			return GetCurrentPlaylistVarFloat( "round_end_fade_time", GAME_WINNER_DETERMINED_ROUND_WAIT )
		}
	}
	else
	{
		if ( IsPVEMode() )
			return GetCurrentPlaylistVarFloat( "freelance_gamestate_duration_winnerdetermined", 5.0 )

		if ( WillShowRoundWinningKillReplay() )
			return GetRoundWinningKillReplayTotalLength() + GAME_WINNER_DETERMINED_FINAL_ROUND_ROUND_WINNING_KILL_REPLAY_DELAY
		else
			return GAME_WINNER_DETERMINED_WAIT
	}

	unreachable
}

void function GameState_Init_MP()
{
	file.gamePermanentsIdx = CreateScriptManagedEntArray()
	file.roundPermanentsIdx = CreateScriptManagedEntArray()

}

void function GameState_EntitiesDidLoad()
{
	SvDemo_ConsistencyCheckString( "GameState_EntitiesDidLoad()" )
	SetRoundWinningKillEnabled( GetCurrentPlaylistVarBool( "roundwinningkillreplay_enabled", false ) )
}

void function GameState_OnPlayerChangedTeam( entity player, int oldTeam, int newTeam )
{
	if ( oldTeam == newTeam )
		return

	if ( IsValid( player ) )
	{
		int oldIndex = player.GetTeamMemberIndex()
		if ( oldIndex > -1 && oldTeam > -1)
		{
			int newIndex = GetLowestUnusedMemberIndexForTeam( newTeam )
			player.SetTeamMemberIndex( newIndex )
			UpdateSquadDataForTeamChange( player, oldIndex, newIndex, oldTeam, newTeam )

			if ( AllianceProximity_IsUsingAlliances() )
				AllianceProximity_OnPlayerTeamChanged_Server( player, oldIndex, newIndex, oldTeam, newTeam )
		}
	}
}

void function WaittillGameStateOrHigher( int state )
{
	for ( ;; )
	{
		if ( GetGameState() >= state )
			return
		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
	}
}

void function GameStateWait( int gameState )
{
	while ( GetGameState() != gameState )
	{
		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
	}
}

void function SetEndRoundPlayerState( int endRoundType )
{
	level.endOfRoundPlayerState = endRoundType
}

void function PlayerEnterEndRoundState( entity player )
{
	switch ( level.endOfRoundPlayerState )
	{
		case ENDROUND_MOVEONLY:
			TakeAmmoFromPlayer( player )
			break

		case ENDROUND_FREE:
			break

		case ENDROUND_FREEZE:
			player.FreezeControlsOnServer()
			break

		default:
			player.FreezeControlsOnServer()
			break
	}
}

void function Coop_DelayedWinnerDetermined( entity player )
{
	player.EndSignal( "OnDestroy" )

	float fadeTime = 0.35

	wait GetWinnerDeterminedWait() - fadeTime - CLEAR_PLAYERS_BUFFER

	ScreenFade( player, 0, 2, 0, 255, fadeTime, GetWinnerDeterminedWait(), FFADE_OUT | FFADE_STAYOUT )  // the next fade up will cancel the long hold time

	SetPlayerEliminated( player )
	PlayerEnterEndRoundState( player )
}

void function AwardEndOfMatchAwards()
{
	float waitTime = GetWinnerDeterminedWait() / 2
	wait waitTime

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		//if ( player.GetTeam() == level.nv.winningTeam )
		//	AddPlayerScore( player, "MatchVictory", null, GetFactionChoice( player ) )
		AddPlayerScore( player, "MatchComplete" )
	}

	GameRules_MarkGameStateWinnerDetermined( GetWinningTeam() )
}

void function DelayedHolsterViewModelAndDisableWeapons( entity player )
{
	player.EndSignal( "OnDeath" )

	wait( 1.25 )

	if ( IsValid( player ) )
		HolsterViewModelAndDisableWeapons( player )
}

void function CodeCallback_GamerulesThink()
{
	int gameState = GetGameState()
	if ( gameState != file.gameState )
	{
		string oldPrintVal = file.gameState == -1 ? "-1" : string( file.gameState )
		string newPrintVal = gameState == -1 ? "-1" : string( gameState )
		printt( "GameState changed from", oldPrintVal, "to", newPrintVal )

		file.gameState = gameState
	}

	SvDemo_ConsistencyCheckString( "CodeCallback_GamerulesThink()" )
	SvDemo_ConsistencyCheckInt( gameState )

	switch ( gameState )
	{
		case eGameState.WaitingForCustomStart:
			//printt( "STATE: waiting for custom start" )
			GameRulesThink_WaitingForCustomStart()
			break

		case eGameState.WaitingForPlayers:
			//printt( "STATE: waiting for players" )
			GameRulesThink_WaitingForPlayers()
			break

		case eGameState.PickLoadout:
			//printt( "STATE: Pick Loadout" )
			GameRulesThink_PickLoadout()
			break

		case eGameState.Prematch:
			//printt( "STATE: prematch" )
			GameRulesThink_Prematch()
			break

		case eGameState.Playing:
			//printt( "STATE: playing" )
			GameRulesThink_Playing()
			break

		case eGameState.SuddenDeath:
			//printt( "STATE: SuddenDeath" )
			GameRulesThink_SuddenDeath()
			break

		case eGameState.WinnerDetermined:
			//printt( "STATE: WinnerDetermined" )
			GameRulesThink_WinnerDetermined()
			break

		case eGameState.SwitchingSides:
			//printt( "STATE: SwitchingSides" )
			GameRulesThink_SwitchingSides()
			break

		case eGameState.Epilogue:
			//printt( "STATE: Epilogue" )
			GameRulesThink_Epilogue()
			break

		case eGameState.Resolution:
			//printt( "STATE: Resolution" )
			GameRulesThink_Resolution()
			break

		case eGameState.Postmatch:
			//printt( "STATE: post" )
			GameRulesThink_Postmatch()
			break
	}

	UpdateMatchStateToCode()
}

array<entity> function GetConnectedPlayers()
{
	array<entity> players = GetPlayerArray()
	array<entity> guys
	foreach ( player in players )
	{
		if ( !player.hasConnected )
			continue

		guys.append( player )
	}

	return guys
}

bool function AllTeamsConnected()
{
	if ( IsFFAGame() )
		return true

	table<int, int> teamToPlayerCountTable

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !player.hasConnected )
			continue

		int playerTeam = player.GetTeam()
		if ( playerTeam in teamToPlayerCountTable )
		{
			teamToPlayerCountTable[ playerTeam ]++
		}
		else
		{
			teamToPlayerCountTable[ playerTeam ] <- 1
			if ( teamToPlayerCountTable.len() == MAX_TEAMS )
				return true
		}
	}

	return false
}

bool function DoneWaitingForPlayers()
{
	SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() A" )

	if ( GetCurrentPlaylistVarInt( "wait_for_players_forever", 0 ) == 1 )
	{
		SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() B" )
		return false
	}


	if ( Time() < file.waitForPlayersStartTime )
	{
		SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() C" )
		return false
	}

	int autoplayerCount = 0
	array<entity> connectedPlayers = GetConnectedPlayers()
	int connectedPlayersCount = connectedPlayers.len()

	// wait for one player to connect
	if ( connectedPlayersCount < 1 )
	{
		SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() D" )
		return false
	}

	int knownPlayersCount = GetConnectingAndConnectedPlayerArray().len() + GetPendingClientsCount()

	int minPlayers = GetCurrentPlaylistVarInt( "min_players", 0 )
	if ( IsPrivateMatch() && GetConVarBool("customMatch_fastStart") )
	{
		minPlayers = minint( minPlayers, GetCurrentPlaylistVarInt( "cm_public_min_players", minPlayers ) )
	}

	int expectedPlayers = maxint( minPlayers, knownPlayersCount )
	#if DEVELOPER
		minPlayers = knownPlayersCount
		expectedPlayers = knownPlayersCount
	#endif
	// bool allTeamsConnected = AllTeamsConnected()

	SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() E" )
	SvDemo_ConsistencyCheckFloat( Time() )
	SvDemo_ConsistencyCheckFloat( file.waitForPlayersEndTime )
	SvDemo_ConsistencyCheckInt( GetCurrentPlaylistVarInt( "min_players", 0 ) )
	SvDemo_ConsistencyCheckInt( knownPlayersCount )
	SvDemo_ConsistencyCheckInt( GetCurrentPlaylistVarInt( "waiting_for_players_percentage_desired", 100 ) )

	// test that we haven't hit the failsafe timeout
	if ( Time() < file.waitForPlayersEndTime )
	{
		//// need at least one player from each team connected
		//if ( !allTeamsConnected && !IsSingleTeamMode() && !FFA )
		//	return false

		// wait for minPlayers to connect or a portion of all expectedPlayers, whichever is greater
		int playersDesiredForCountdownStart = maxint( minPlayers, int( expectedPlayers * GetCurrentPlaylistVarInt( "waiting_for_players_percentage_desired", 70 ) * 0.01 ) )
		if ( connectedPlayersCount < playersDesiredForCountdownStart )
		{
			SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() F" )
			return false
		}
	}

	// all expectedPlayers are here, done waiting
	//if ( connectedPlayersCount == expectedPlayers )
	//{
	//	SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() G" )
	//	return true
	//}

	float countdownSeconds = PreGame_GetWaitingForPlayersCountdown()

	// only wait X more seconds if the playlist var is greater than 0
	if ( countdownSeconds <= 0.0 )
	{
		SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() H" )
		return true
	}

	// start X second countdown
	if ( GetNV_PreGameStartTime() <= 0.0 )
	{
		SetNV_PreGameStartTime( Time() + countdownSeconds )
		ExecuteSetPreGameStartTimeCallback()
	}

	SvDemo_ConsistencyCheckString( "DoneWaitingForPlayers() I" )

	return (Time() >= GetNV_PreGameStartTime())
}

void function GameRulesThink_WaitingForCustomStart()
{
	SetGameState( eGameState.WaitingForPlayers )
}

void function ShowTransitionToCharSelectStart( float duration )
{
	if ( IsTestMap() )
		return

	bool continueHoldOver = false

		if ( IsRevTakeover()  )
			continueHoldOver = true


	float transitionEndTime = (Time() + duration)
	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerToClient_ScreenCoverTransition", transitionEndTime, continueHoldOver )
	}
}

float s_pickLoadoutStartTime = -1.0
void function GameRulesThink_WaitingForPlayers()
{
	SvDemo_ConsistencyCheckString( "GameRulesThink_WaitingForPlayers() A" )

	bool hasPreCountdown = (PreGame_GetWaitingForPlayersCountdown() > 0.0)
	if ( hasPreCountdown && Survival_CharacterSelectEnabled() )
	{
		float endTime = GetNV_PreGameStartTime()
		if ( (endTime > 0.0) && ((Time() - endTime) > CharSelect_GetIntroMusicStartTime()) )
			PlayCharacterSelectMusicToAllPlayersIfNeeded()
	}

	if ( !DoneWaitingForPlayers() )
	{
		SvDemo_ConsistencyCheckString( "GameRulesThink_WaitingForPlayers() B" )
		return
	}

	if ( hasPreCountdown )
	{
		if ( s_pickLoadoutStartTime < 0 )
		{
			float transitionTime = CharSelect_GetIntroTransitionDuration()
			ShowTransitionToCharSelectStart( transitionTime )
			s_pickLoadoutStartTime = (Time() + (transitionTime * 0.5))
		}

		if ( Time() < s_pickLoadoutStartTime )
			return
	}

	SvDemo_ConsistencyCheckString( "GameRulesThink_WaitingForPlayers() C" )
	SetGameState( eGameState.PickLoadout )
}

void function GameRulesThink_PickLoadout()
{
	float pickLoadoutEndTime = GetGlobalNetTime( "pickLoadoutGamestateEndTime" )
	if ( pickLoadoutEndTime < 0 )
		return

	if ( Time() < pickLoadoutEndTime )
		return

	SetGameState( eGameState.Prematch )
}

void function GameRulesThink_Prematch()
{
	float gameStartTime = GetGameStartTime( )

	SvDemo_ConsistencyCheckString( "GameRulesThink_Prematch()" )
	SvDemo_ConsistencyCheckFloat( gameStartTime )

	if ( Time() < gameStartTime )
		return

	SvDemo_ConsistencyCheckString( "GameRulesThink_Prematch() B" )
	SetGameState( eGameState.Playing )
	SetWinningTeam( -1 )
	file.hasTriggeredThirtySecondCallbacks = false

	GameRules_MarkGameStatePrematchEnding()
}

void function ClearPlayers()
{
	array<entity> players = GetPlayerArray()

	foreach ( player in players )
	{
		ClearPlayer( player )
	}

	array<entity> batteries = GetEntArrayByClass_Expensive( "item_titan_battery" )

	foreach ( battery in batteries )
		battery.Destroy()

	ResetNPCs()

	// TODO: delete projectiles and lingering effects
	svGlobal.levelEnt.Signal( "ClearedPlayers" )
}

void function ClearPlayer( entity player )
{
	//Depend on SwitchingSides etc to screenfade correctly
	PROTO_CleanupTrackedProjectiles( player )

	player.ClearInvulnerable()
	player.ClearParent()

	SetPlayerEliminated( player )

	if ( IsAlive( player ) )
		player.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )

	Assert( !IsAlive( player ), player.GetHealth() + " " + player.IsInvulnerable() + " " + player.IsBuddhaMode() + " " + player.IsGodMode() )

	SetPlayerSettings( player, SPECTATOR_SETTINGS )
}

void function ClearPetTitan( entity player )
{
	entity petTitan = player.GetPetTitan()
	if ( IsAlive( petTitan ) )
		petTitan.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )

	if ( IsValid( petTitan ) )
		petTitan.Destroy()
}

void function ClearWeapons()
{
	#if DEVELOPER
		if ( GetMapName() == "mp_test_engagement_range" )
			return
	#endif

	array<entity> weapons = GetWeaponArray( true )
	foreach ( weapon in weapons )
		weapon.Destroy()
}

bool function ShouldEnterSuddenDeath( int winningTeam )
{
	if ( GetGameState() == eGameState.SuddenDeath )
		return false

	if ( !( winningTeam == TEAM_UNASSIGNED ) )
		return false

	if ( !IsSuddenDeathGameMode() )
		return false

	if ( GetTeamPlayerCount( TEAM_MILITIA ) == 0 || GetTeamPlayerCount( TEAM_IMC ) == 0 )
		return false

	return true
}

void function SetWinner( int winningTeam, int winReason, string winReasonText, string lossReasonText, bool overrideWinLossReasonForLastRound = true )
{
	Assert( GamePlayingOrSuddenDeath() || level.devForcedWin )
	#if DEVELOPER
	if ( !Is2TeamPvPGame() )
	{
		printt( "SETTING WINNER", winningTeam, winReason, winReasonText, lossReasonText )
		printt( "%s", GetStack() )
	}
	#endif

	svGlobal.winReason = winReason

	if ( GetGameState() == eGameState.SuddenDeath )
	{
		//Riff_ForceSetEliminationMode( eEliminationMode.Default )
	}
	else if ( ShouldEnterSuddenDeath( winningTeam ) )
	{
		SetGameState( eGameState.SuddenDeath )
		return
	}

	svGlobal.winReasonText = winReasonText
	svGlobal.lossReasonText = lossReasonText

	if ( IsRoundBased() )
	{
		GamemodeUtility_IncrementRoundScore(winningTeam, 1)

		if ( ShouldStopPlayingRounds() == true ) //No more rounds to play, set the winning team to the team that won the match, not the team that won the round
		{
			if ( overrideWinLossReasonForLastRound )
			{
				winningTeam = GetMatchWinnerFromScore()

				if ( HasAnyTeamMetOrExceededScoreLimit() )
				{
					svGlobal.winReasonText =  "#GAMEMODE_SCORE_LIMIT_REACHED"
					svGlobal.lossReasonText = "#GAMEMODE_SCORE_LIMIT_REACHED"
				}
				else if ( winningTeam == TEAM_UNASSIGNED )
				{
					svGlobal.winReasonText =  "#GAMEMODE_ROUND_LIMIT_REACHED_ROUND_SCORE_DRAW"
					svGlobal.lossReasonText = "#GAMEMODE_ROUND_LIMIT_REACHED_ROUND_SCORE_DRAW"
				}
				else
				{
					svGlobal.winReasonText =  "#GAMEMODE_ROUND_LIMIT_REACHED_WON_MORE_ROUNDS"
					svGlobal.lossReasonText = "#GAMEMODE_ROUND_LIMIT_REACHED_LOSS_MORE_ROUNDS"
				}
			}
		}
	}

	SetWinningTeam( winningTeam )


	//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_BATTLE_RUSH ) )
	//	BattleRush_PlayEndMusic(winningTeam)


	SetGameState( eGameState.WinnerDetermined )
}


bool function IsEliminationModeComplete_TrySetWinner()
{
	if ( !IsEliminationBased() )
		return false

	if ( GameTime_PlayingTime() < ELIM_FIRST_SPAWN_GRACE_PERIOD )
		return false

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !IsPlayerEliminated( player ) && player.p.respawnCount == 0 )
		{
			SetPlayerEliminated( player )
		}
	}

	return ( CheckForAndTrySetEliminationModeWinner() )
}


void function ForceEliminationModeWinner()
{
	AttemptSetEliminationModeWinner_ReturnTeam( true )
}


bool function CheckForAndTrySetEliminationModeWinner()
{
	int winningTeam = NO_DETERMINED_WINNING_TEAM_YET

	winningTeam = AttemptSetEliminationModeWinner_ReturnTeam()

	return winningTeam != NO_DETERMINED_WINNING_TEAM_YET
}


int function AttemptSetEliminationModeWinner_ReturnTeam( forceSetWinner = false ) //TODO: Make sure setting the winner if we run out of rounds to play correctly!
{
	if ( GetConVarInt( "mp_enablematchending" ) == 0 )
		return TEAM_UNASSIGNED

	if ( GetCurrentPlaylistVarInt( "match_ending_enabled", 1 ) == 0 )
		return TEAM_UNASSIGNED

	expect bool( forceSetWinner )

	array<int> teams
	teams.resize( ABSOLUTE_MAX_TEAMS, 0 )

	array<entity> playersAlive = GetPlayerArray_Alive()

	foreach ( player in playersAlive )
	{
		int playerTeam = player.GetTeam()
		teams[ playerTeam ]++
	}

	int winningTeam = NO_DETERMINED_WINNING_TEAM_YET
	int winReason = eWinReason.DEFAULT
	string winReasonText = "#GENERIC_DRAW_ANNOUNCEMENT"
	string lossReasonText = "#GENERIC_DRAW_ANNOUNCEMENT"















	if ( playersAlive.len() == 0 )
	{
		winningTeam = TEAM_UNASSIGNED
		SetWinner( winningTeam, eWinReason.ELIMINATION, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
		return winningTeam
	}
































	if ( playersAlive.len() == 1 || AllPlayersAreOnSameTeam( playersAlive ) )
	{
		entity winner = playersAlive[0]
		winningTeam = winner.GetTeam()
		SetWinner( winningTeam, eWinReason.ELIMINATION, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOT_ELIMINATED" )
		return winningTeam
	}

	return NO_DETERMINED_WINNING_TEAM_YET
}

bool function AllPlayersAreOnSameTeam( array<entity> playerArray )
{
	Assert( playerArray.len() > 0 )
	int teamOfPlayerOne = playerArray[0].GetTeam()
	for ( int i = 1; i < playerArray.len(); ++i )
	{
		if ( playerArray[i].GetTeam() != teamOfPlayerOne )
			return false
	}

	return true
}

void function AddPilotEliminationDialogueCallback( pilotEliminationDialogueCallbackType callbackFunc )
{
	svGlobal.pilotEliminationDialogueCallbacks.append( callbackFunc )
}

void function PlayPilotEliminationDialogue( array<entity> IMCPlayersAlive, array<entity> MilitiaPlayersAlive )
{
	int winningTeam = GetNetWinningTeam()
	if ( winningTeam != -1 )
		return

	int numIMCPlayersAlive = IMCPlayersAlive.len()
	int numMilitiaPlayersAlive = MilitiaPlayersAlive.len()

	if ( level.lastTeamPilots[TEAM_MILITIA] != numMilitiaPlayersAlive && winningTeam == -1 )
	{
		if ( numMilitiaPlayersAlive == 2 )
		{
			if ( GetCurrentPlaylistVarInt( "max_players", 12 ) > 4 )
			{
				foreach ( aliveIMCPlayer in IMCPlayersAlive )
					PlayConversationToPlayer( "EnemyPilotsLeftTwo", aliveIMCPlayer )

				foreach ( aliveMilitiaPlayer in MilitiaPlayersAlive )
					PlayConversationToPlayer( "FriendlyPilotsLeftTwo", aliveMilitiaPlayer )
			}
		}
		else if ( numMilitiaPlayersAlive == 1 )
		{
			foreach ( aliveIMCPlayer in IMCPlayersAlive )
				PlayConversationToPlayer( "EnemyPilotsLeftOne", aliveIMCPlayer )

			entity player = MilitiaPlayersAlive[0]
			Assert( IsAlive( player ) ) //Just in case!
			PlayConversationToPlayer( "YouAreTheLastPilot", player )
		}
	}

	if ( level.lastTeamPilots[TEAM_IMC] != numIMCPlayersAlive )
	{
		if ( numIMCPlayersAlive == 2 )
		{
			if ( GetCurrentPlaylistVarInt( "max_players", 12 ) > 4 )
			{
				foreach ( aliveIMCPlayer in IMCPlayersAlive )
					PlayConversationToPlayer( "FriendlyPilotsLeftTwo", aliveIMCPlayer )

				foreach ( aliveMilitiaPlayer in MilitiaPlayersAlive )
					PlayConversationToPlayer( "EnemyPilotsLeftTwo", aliveMilitiaPlayer )
			}
		}
		else if ( numIMCPlayersAlive == 1 )
		{
			foreach ( aliveMilitiaPlayer in MilitiaPlayersAlive )
				PlayConversationToPlayer( "EnemyPilotsLeftOne", aliveMilitiaPlayer )

			entity player = IMCPlayersAlive[0]
			Assert( IsAlive( player ) ) //Just in case!
			PlayConversationToPlayer( "YouAreTheLastPilot", player )
		}
	}
}

entity function GetTitanPlayer( entity titan )
{
	if ( titan.IsPlayer() )
		return titan

	return titan.GetBossPlayer()
}


bool function ScoreLimit_Complete()
{
	int scoreLimit = GetScoreLimit_FromPlaylist()
	if ( scoreLimit == 0 )
		return false

	if ( Flag( "DisableScoreLimit" ) )
		return false

	if ( !GameRules_AllowMatchEnd() )
		return false

	array<entity> players = GetPlayerArray()
	foreach ( entity player in players )
	{
		int playerTeam = player.GetTeam()
		int score = GameRules_GetTeamScore( playerTeam )
		if ( score >= scoreLimit )
		{
			SetWinner( playerTeam, eWinReason.SCORE_LIMIT, "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
			return true
		}
	}

	if ( Is2TeamPvPGame() )
	{
		if ( IsSwitchSidesBased() && HasSwitchedSides() == 0 ) //Switching sides only really makes sense with 2TeamPvP games
		{
			int militiaScore = GameRules_GetTeamScore( TEAM_MILITIA )
			int imcScore = GameRules_GetTeamScore( TEAM_IMC )

			if ( militiaScore >= (scoreLimit * 0.5) ||  imcScore >= (scoreLimit * 0.5) )
			{
				svGlobal.winReason = eWinReason.SCORE_LIMIT
				SetGameState( eGameState.SwitchingSides )
				return true
			}
		}
	}

	return false
}


bool function RoundScoreLimit_Complete()
{
	if ( !GameRules_AllowMatchEnd() )
		return false

	if ( Flag( "DisableScoreLimit" ) )
		return false

	int roundScoreLimit = GetRoundScoreLimit_FromPlaylist()

	if ( roundScoreLimit == 0 ) // no round score limit defined?
		return false

	//TODO: Reexamine this next game? RoundScoreLimit_Complete shouldn't have side effect of setting winner sometimes

	if ( ShouldStopPlayingRounds() )
	{
		int winningTeam = GetMatchWinnerFromScore()
		string winReason = "#GAMEMODE_SCORE_LIMIT_REACHED"
		string lossReason = "#GAMEMODE_SCORE_LIMIT_REACHED"

		if ( GetNetWinningTeam() == -1 )
		{
			if ( level.privateMatchForcedEnd )
			{
				svGlobal.winReasonText = "#GAMEMODE_HOST_ENDED_MATCH"
				svGlobal.lossReasonText = "#GAMEMODE_HOST_ENDED_MATCH"
			}
			else if ( winningTeam == TEAM_UNASSIGNED )
			{
				svGlobal.winReasonText = "#GAMEMODE_ROUND_LIMIT_REACHED"
				svGlobal.lossReasonText = "#GAMEMODE_ROUND_LIMIT_REACHED"
			}
			SetWinningTeam( winningTeam)
		}
		return true
	}

	return false
}

bool function ShouldStopPlayingRounds()
{
	if ( HasAnyTeamMetOrExceededScoreLimit() )
		return true

	if ( level.forceNoMoreRounds == true )
		return true

	int roundsPlayed = GetRoundsPlayed()
	if ( GetGameState() < eGameState.WinnerDetermined ) //Somewhat Hacky. Need to do this as level.nv.roundsPlayed is only incremented in winner determined, but we should be able to call this function before that to see if we'll play more rounds after this
		roundsPlayed++

	int maxExtraRounds = GetCurrentPlaylistVarInt( "maxExtraRounds", -1 )
	int extraRoundsPlayed = roundsPlayed - GetMaxRoundsToPlay()
	if ( svGlobal.forceNoFinalRoundDraws == true && ( maxExtraRounds < 0 || extraRoundsPlayed <= maxExtraRounds ) ) //If true the mode will keep going until a clear winner is determined. It will not end in a draw.
		return false

	if ( roundsPlayed >= GetMaxRoundsToPlay() )
		return true

	if ( level.privateMatchForcedEnd == true )
		return true

	return false
}

bool function HasAnyTeamWonWinBy2Rules()
{
	if ( GameMode_Rounds_IsWinBy2( GameRules_GetGameMode() ) )
	{
		int minScore = GameMode_GetWinBy2MinScore( GameRules_GetGameMode() )
		array< int > allTeams = GetAllValidPlayerTeams()
		foreach( int team in allTeams )
		{
			int myTeamScore = GameRules_GetTeamScore2( team )
			if ( myTeamScore >= minScore )
			{
				bool hasCloseMatch = false
				foreach( int enemyTeam in allTeams )
				{
					if ( enemyTeam != team )
					{
						int enemyTeamScore = GameRules_GetTeamScore2( enemyTeam )
						if ( myTeamScore <= enemyTeamScore + 1 )
						{
							hasCloseMatch = true
							break
						}
					}
				}

				if ( !hasCloseMatch )
				{
					return true
				}
			}
		}
	}

	return false
}

bool function HasAnyTeamMetOrExceededScoreLimit()
{
	int roundScoreLimit = GetRoundScoreLimit_FromPlaylist()
	array< int > allTeams = GetAllValidConnectedPlayerTeams()

	if ( allTeams.len() == 1 )
	{
		GameRules_SetTeamScore2( allTeams[ 0 ] , roundScoreLimit )
	}

	foreach( int team in allTeams )
	{
		if ( GameRules_GetTeamScore2( team ) >= roundScoreLimit )
			return true
	}

	if ( HasAnyTeamWonWinBy2Rules() )
		return true

	return false
}

bool function TimeLimit_Complete()
{
	//Need to check with code how to set mp_enabletimelimit
	//and mp_timelimit
	if ( !GameRules_TimeLimitEnabled() )
		return false

	if ( !GameRules_AllowMatchEnd() )
		return false

	if ( Flag( "DisableTimeLimit" ) )
		return false

	int timeLimit
	if ( GetGameState() == eGameState.SuddenDeath )
		timeLimit = int( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 )
	else if ( IsRoundBased() )
		timeLimit = int( GetRoundTimeLimit_ForGameMode() * 60.0 )
	else
		timeLimit = int( GetTimeLimit_ForGameMode() * 60.0 )

	if ( timeLimit == 0 )
		return false

	int timeLeftSeconds = GameTime_TimeLeftSeconds()

	if ( timeLeftSeconds < 15 && timeLeftSeconds != level.lastTimeLeftSeconds )
	{
		array<entity> players = GetPlayerArray()

		foreach ( player in players )
		{
			EmitSoundOnEntity( player, "Menu_Match_Countdown" )

			if ( timeLeftSeconds < 5 && timeLeftSeconds >= 0 )
				EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.5 )
		}
	}

	if ( IsSwitchSidesBased() && HasSwitchedSides() == 0 && !IsRoundBased() ) // TODO: fix LTS switching sides announcement
	{
		if ( timeLeftSeconds == 30 && timeLeftSeconds != level.lastTimeLeftSeconds )
		{
			PlayConversationToTeam( "SwitchingSidesSoon", TEAM_MILITIA )
			PlayConversationToTeam( "SwitchingSidesSoon", TEAM_IMC )
		}
	}

	level.lastTimeLeftSeconds = timeLeftSeconds

	if ( GameTime_TimeSpentInCurrentState() > timeLimit )
	{
		if ( svGlobal.timelimitCompleteFunc != null )
		{
			return svGlobal.timelimitCompleteFunc()
		}

		if ( IsSwitchSidesBased() && HasSwitchedSides() == 0 && !IsRoundBased() )
		{
			SetGameState( eGameState.SwitchingSides )
			return true
		}
		else if ( IsEliminationBased() )
		{
			ForceEliminationModeWinner()
			return true
		}

		if ( IsRoundBased() )
			return RoundBasedTimeOver()

		int winningTeam = GetMatchWinnerFromScore()

		file.gameTimedOut = true
		SetWinner( winningTeam, eWinReason.TIME_LIMIT, "#GAMEMODE_TIME_LIMIT_REACHED", "#GAMEMODE_TIME_LIMIT_REACHED" )
		return true
	}

	return false
}


bool function RoundBasedTimeOver()
{
	int roundWinningTeam = GetRoundWinnerFromScore()
	SetWinner( roundWinningTeam, eWinReason.TIME_LIMIT, "#GAMEMODE_TIME_LIMIT_REACHED", "#GAMEMODE_TIME_LIMIT_REACHED" )
	return true
}


int function GetRoundWinnerFromScore()
{
	Assert( IsRoundBased() )

	if ( !IsRoundBasedUsingTeamScore() )
		return TEAM_UNASSIGNED

	Assert( Is2TeamPvPGame() ) //TODO: No real requirement for this, we just don't have a non 2TeamPvPGame that uses rounds yet, so not rewriting this function till we need it

	int militiaScore
	int imcScore

	int winningTeam = TEAM_UNASSIGNED

	militiaScore = GameRules_GetTeamScore( TEAM_MILITIA )
	imcScore = GameRules_GetTeamScore( TEAM_IMC )

	if ( imcScore > militiaScore )
		winningTeam = TEAM_IMC
	else if ( imcScore < militiaScore )
		winningTeam = TEAM_MILITIA

	return winningTeam
}


int function GetMatchWinnerFromScore()
{
	int bestTeam = TEAM_UNASSIGNED
	int bestScore = 0

	array<entity> players = GetPlayerArray()
	foreach ( entity player in players )
	{
		int playerTeam = player.GetTeam()
		if ( playerTeam == bestTeam )
			continue

		int score = IsRoundBased() ? GameRules_GetTeamScore2( playerTeam ) : GameRules_GetTeamScore( playerTeam )
		if ( score > bestScore )
		{
			bestTeam = playerTeam
			bestScore = score
		}
		else if ( (score == bestScore) && (bestTeam != TEAM_UNASSIGNED) )
		{
			// tie game:
			return TEAM_UNASSIGNED
		}
	}

	return bestTeam
}



void function GameRulesThink_Playing()
{
	if ( (Time() - level.lastPlayingEmptyTeamCheck) > 1.0 )
	{
		level.lastPlayingEmptyTeamCheck = Time()
		if( CheckForEmptyTeamVictory() )
			return
	}

	if ( IsEliminationModeComplete_TrySetWinner() )
		return

	if ( TimeLimit_Complete() )
		return

	foreach ( callbackFunc in svGlobal.playingThinkFuncTable )
	{
		callbackFunc()
	}
}


void function GameRulesThink_WinnerDetermined()
{
	if ( GameTime_TimeSpentInCurrentState() < GetWinnerDeterminedWait() )
	{
		if ( ShouldClearPlayersInWinnerDetermined() )
		{
			if ( GameTime_TimeSpentInCurrentState() > GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER && !level.clearedPlayers )
			{
				svGlobal.levelEnt.Signal( "RoundEnd" )
				ClearPlayers()
				level.clearedPlayers = true
			}
		}

		return
	}

	level.clearedPlayers = false

	if ( !IsRoundBased() ) //Should probably do a check for ShouldRunEvac() here. One annoying thing though is that for O2 cinematic, ShouldRunEvac() will return false but it should still run a resolution
	{
		SetGameState( eGameState.Resolution )
	}
	else if ( IsRoundBasedGameOver() )
	{
		SetGlobalNonRewindNetBool( "roundScoreLimitComplete", true )
		SetGameState( eGameState.Resolution )
	}
	else
	{
		FlagClear( "GamePlaying" )

		int roundLimit = GetRoundScoreLimit_FromPlaylist()

		float idealMinSwitchSides = roundLimit * 0.5
		float idealMaxSwitchSides = ( ( roundLimit * 2 ) - 1 ) * 0.5
		int idealSwitchSides = int( floor( ( ( idealMinSwitchSides + idealMaxSwitchSides ) * 0.5 ) + 0.49 ) ) // average, round to closest (1.5 rounds to 1.0, 1.6 to 2.0)

		if ( roundLimit > 0 && GetRoundsPlayed() == idealSwitchSides && IsSwitchSidesBased() )
		{
			SetGameState( eGameState.SwitchingSides )
			return
		}

		int pickLoadoutInterval = GetCurrentPlaylistVarInt( "pick_loadout_interval", 1 )
		if ( ( GetRoundsPlayed() % pickLoadoutInterval ) == 0 )
		{
			SetGameState( eGameState.WaitingForPlayers )
		}
		else
		{
			SetGameState( eGameState.Prematch )
		}
	}
}


bool function IsWinnerDeterminedPlayable()
{
	if ( IsRoundBased() )
		return ShouldStopPlayingRounds()

	return true
}


bool function IsRoundBasedGameOver()
{
	// maybe no players left on enemy team
	int defaultWinner = TEAM_UNASSIGNED

	if ( GetCurrentPlaylistVarBool( "has_default_winner", true ) )
	{
		if ( Is2TeamPvPGame() )
		{
			if ( GetTeamPlayerCount( TEAM_MILITIA ) == 0 )
				defaultWinner = TEAM_IMC
			else if ( GetTeamPlayerCount( TEAM_IMC ) == 0 && !IsSingleTeamMode() )
				defaultWinner = TEAM_MILITIA
		}
		else
		{
			array< int > allTeams = GetAllValidPlayerTeams()
			array< int > populatedTeams
			// If there's only one populated team, they're the winner
			foreach( int team in allTeams )
			{
				if ( GetPlayerArrayOfTeam( team ).len() > 0 )
				{
					populatedTeams.append( team )

					if ( populatedTeams.len() > 1 )
						break
				}
			}

			if ( populatedTeams.len() == 1 )
				defaultWinner = populatedTeams[ 0 ]
		}
	}

	if ( RoundScoreLimit_Complete() || (defaultWinner != TEAM_UNASSIGNED && GetRoundsPlayed() > 1) )
		return true

	return false
}

void function GameRulesThink_SwitchingSides()
{
	if ( GameTime_TimeSpentInCurrentState() < GetSwitchingSidesWait() )
	{
		if ( GameTime_TimeSpentInCurrentState() > GetSwitchingSidesWait() - CLEAR_PLAYERS_BUFFER && !level.clearedPlayers )
		{
			ClearPlayers()
			level.clearedPlayers = true
		}
		return
	}

	level.clearedPlayers = false

	ClearPlayers() // JFS: R2DLC-305 SCRIPT ERROR: PHONE_HOME: [SERVER] Cannot set properties on a null

	int pickLoadoutInterval = GetCurrentPlaylistVarInt( "pick_loadout_interval", 1 )
	if ( ( GetRoundsPlayed() % pickLoadoutInterval ) == 0 )
	{
		SetGameState( eGameState.WaitingForPlayers )
	}
	else
	{
		SetGameState( eGameState.Prematch )
	}
}

void function GameRulesThink_SuddenDeath()
{
	if ( !IsRoundBased() )
	{
		int militiaScore = GameRules_GetTeamScore( TEAM_MILITIA )
		int imcScore = GameRules_GetTeamScore( TEAM_IMC )

		if ( militiaScore != imcScore )
		{
			int winningTeam = ( militiaScore > imcScore? TEAM_MILITIA : TEAM_IMC )
			SetWinner( winningTeam, eWinReason.SCORE_LIMIT, "#SUDDEN_DEATH_WIN_ANNOUNCEMENT","#SUDDEN_DEATH_LOSS_ANNOUNCEMENT" )
		}
	}

	TimeLimit_Complete()
}


void function GameRulesThink_Epilogue()
{

}


void function GameRulesThink_Resolution()
{
	foreach ( player in GetPlayerArray() )
	{
		if ( !IsPlayerEliminated( player ) && ShouldPlayerBeEliminated( player ) )
			SetPlayerEliminated( player )
	}

	if ( GameTime_TimeSpentInCurrentState() > GetResolutionDuration() )
		SetGameState( eGameState.Postmatch )
}

void function GameRulesThink_Postmatch()
{
	if ( file.endingMatch || ( GameTime_TimeSpentInCurrentState() < GAME_POSTMATCH_LENGTH && !IsPrivateMatch() ) )
		return
	file.endingMatch = true

	if ( !IsPrivateMatch() || GetConVarBool( "customMatch_enabled" ) )
	{
		//foreach ( player in GetPlayerArrayIncludingSpectators() )
			//player.Forfeit() // S3: entity method not available
	}

	GameRules_EndMatch()
}

enum eGameClosenessHistory
{
	VeryClose,
	Close,
	BadGame,
	Blowout,
}

/*function GetMatchClosenessHistory( scores ) //TODO: This will not work with FFA Game modes! Also consider using eMatchScoreCloseness instead of eGameClosenessHistory
{
	local highScore = (scores[TEAM_IMC] > scores[TEAM_MILITIA] ? scores[TEAM_IMC] : scores[TEAM_MILITIA]).tofloat()
	local lowScore = (scores[TEAM_IMC] > scores[TEAM_MILITIA] ? scores[TEAM_MILITIA] : scores[TEAM_IMC]).tofloat()

	if ( !highScore )
		return eGameClosenessHistory.VeryClose

	local closeFrac = lowScore / highScore

	if ( closeFrac <= 0.49 )
		return eGameClosenessHistory.Blowout
	else if ( closeFrac <= 0.74 )
		return eGameClosenessHistory.BadGame
	else if ( closeFrac <= 0.85 )
		return eGameClosenessHistory.Close
	else
		return eGameClosenessHistory.VeryClose
}*/

/*function GetMatchHistory( num )
{
	local matchHistory = []
	local maxMapIndex = num * 2
	string mapName
	local teams = [ TEAM_IMC, TEAM_MILITIA ]

	local scores = {}
	scores[TEAM_IMC] <- null
	scores[TEAM_MILITIA] <- null

	local scoresValid
	local winner

	for ( int i = 0; i < maxMapIndex; i++ )  // 0 is the just finished match I'm in
	{
		mapName = GameRules_GetRecentMap( i )

		foreach ( team in teams )
		{
			if ( i == 0 )
				scores[team] = GameRules_GetTeamScore( team ) //TODO: Make this work with teamscore2
			else
				scores[team] = GameRules_GetRecentTeamScore( team, i )

			if ( scores[team] == -1 )
			{
				scoresValid = false
				//printt( "mapName:", mapName, "team:", team, "scoresValid = false" )
				//printt( "mapName:", mapName, "breaking" )
				break
			}

			scoresValid = true
			//printt( "mapName:", mapName, "team:", team, "scoresValid = true" )
		}

		if ( (!IsLobbyMapName( mapName ) && mapName != "") && scoresValid )
		{
			if ( scores[TEAM_IMC] == scores[TEAM_MILITIA] )
				winner = null
			else if ( scores[TEAM_IMC] > scores[TEAM_MILITIA] )
				winner = TEAM_IMC
			else
				winner = TEAM_MILITIA

			matchHistory.append( { map = mapName, scores = clone( scores ), winner = winner, closeness = GetMatchClosenessHistory( scores ) } )
			//printt( "Appending to matchHistory, mapName:", mapName, "scores:" )
			//PrintTable( scores )
		}
	}

	return matchHistory
}*/

/*function GetMatchHistoryWinner( matchHistory )
{
	local wins = {}
	wins[TEAM_IMC] <- 0
	wins[TEAM_MILITIA] <- 0

	foreach ( match in matchHistory )
	{
		if ( match.winner )
			wins[match.winner]++
	}

	local winningTeam

	if ( wins[TEAM_IMC] == wins[TEAM_MILITIA] )
		winningTeam = null
	else if ( wins[TEAM_IMC] > wins[TEAM_MILITIA] )
		winningTeam = TEAM_IMC
	else
		winningTeam = TEAM_MILITIA

	return winningTeam
}*/

int function GetCodeMatchPhaseForGameState()
{
	int gameState = GetGameState()
	switch ( gameState )
	{
		case eGameState.WaitingForPlayers:
		case eGameState.PickLoadout:
		case eGameState.Prematch:
			return MATCHPHASE_PREMATCH

		case eGameState.Playing:
		case eGameState.SwitchingSides:
			return MATCHPHASE_MATCH

		case eGameState.SuddenDeath:
		case eGameState.WinnerDetermined:
		case eGameState.Epilogue:
		case eGameState.Resolution:
		case eGameState.Postmatch:
			return MATCHPHASE_EPILOGUE

		default:
			printt( " ** Warning: GetCodeMatchPhaseForGameState() - Unhandeled eGameState", gameState )
	}
	return MATCHPHASE_UNSPECIFIED
}

void function UpdateMatchStateToCode()
{
	int maxRounds
	int roundsIMC
	int roundsMilitia
	int scoreLimit
	int scoreIMC
	int scoreMilitia
	if ( IsRoundBased() )
	{
		maxRounds = GetRoundScoreLimit_FromPlaylist()
		roundsIMC = GameRules_GetTeamScore2( TEAM_IMC )
		roundsMilitia = GameRules_GetTeamScore2( TEAM_MILITIA )
		scoreLimit = GetRoundScoreLimit_FromPlaylist()
		scoreIMC = GameRules_GetTeamScore2( TEAM_IMC )
		scoreMilitia = GameRules_GetTeamScore2( TEAM_MILITIA )
	}
	else
	{
		maxRounds = 1
		roundsIMC = 0
		roundsMilitia = 0
		scoreLimit = GetScoreLimit_FromPlaylist()
		scoreIMC = GameRules_GetTeamScore( TEAM_IMC )
		scoreMilitia = GameRules_GetTeamScore( TEAM_MILITIA )
	}

	int timeLimit
	int timePassed
	if ( GameRules_TimeLimitEnabled() )
	{
		timeLimit = int( GetTimeLimit_ForGameMode() * 60.0 )
		timePassed = int( GameTime_PlayingTime() )
	}
	else
	{
		timeLimit = 0
		timePassed = int( GameTime_PlayingTime() )
	}

	// Use `sv_matchstate_dump` to see current values
	int phase = GetCodeMatchPhaseForGameState()
	NoteMatchState( phase, maxRounds, roundsIMC, roundsMilitia, timeLimit, timePassed, scoreLimit, scoreIMC, scoreMilitia )
}


void function ForceResolutionEnd()
{
	if ( GetGameState() >= eGameState.WinnerDetermined )
		SetGameState( eGameState.Postmatch )
}


int function CalculateHowCloseScoresAre( int winningTeamScore, int losingTeamScore )
{
	Assert( losingTeamScore <= winningTeamScore ) //Can be equal in the case of a sudden death game.

	int absoluteDifference = winningTeamScore - losingTeamScore

	if ( absoluteDifference <= 1 ) //Regardless of how many points it takes to win, if there's only a 1 or 0 point gap in the end it should be considered close.
		return eMatchScoreCloseness.CLOSE

	if ( losingTeamScore == 0 )
		return eMatchScoreCloseness.BLOWOUT

	float blowoutPercentageThreshold
	float neckAndNeckPercentageThreshold


	//Do proportion based judging of how close this is. Even though we use mainly the same numbers I'm splitting out the categories based on the total score limit based on feedback from R1/easily allow tuning for different score ranges
	if ( winningTeamScore <= 5 )
	{
		//At score limit of 5, score of 2 - 5 is considered a blowout, 4/5 is considered close.
		blowoutPercentageThreshold = 0.4
		neckAndNeckPercentageThreshold = 0.8
	}
	else if ( winningTeamScore > 5 && winningTeamScore <= 10 )
	{
		//At score limit of 5, score of 5 - 10 is considered a blowout, 8 - 10 is considered close.
		blowoutPercentageThreshold = 0.5
		neckAndNeckPercentageThreshold = 0.8
	}
	else if ( winningTeamScore > 10 && winningTeamScore <= 100 )
	{
		//At score limit of 5, score of 50 - 100 is considered a blowout, 80 - 100 is considered close.
		blowoutPercentageThreshold = 0.5
		neckAndNeckPercentageThreshold = 0.8
	}
	else
	{
		blowoutPercentageThreshold = 0.5
		neckAndNeckPercentageThreshold = 0.8
	}

	float losingScoreOverWinningScore = ( losingTeamScore * 1.0 ) / winningTeamScore

	printt( "losingScoreOverWinningScore: " + losingScoreOverWinningScore + ", blowoutPercentageThreshold: " + blowoutPercentageThreshold + ", neckAndNeckPercentageThreshold: " + neckAndNeckPercentageThreshold )
	if ( losingScoreOverWinningScore <= blowoutPercentageThreshold )
		return eMatchScoreCloseness.BLOWOUT

	if ( losingScoreOverWinningScore >= neckAndNeckPercentageThreshold )
		return eMatchScoreCloseness.CLOSE

	return eMatchScoreCloseness.AVERAGE
}


void function CheckMap()
{
	//look for titan starts
	//check if there are 6 of the militia team, 6 imc team
	array<entity> titan_starts_array = GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" )
	int titan_starts = titan_starts_array.len()
	printl( titan_starts + " (12 min) info_spawnpoint_titan_start entities" )

	int militia_starts = 0
	int imc_starts = 0
	foreach ( start in titan_starts_array )
	{
		if ( start.GetTeam() == TEAM_MILITIA )
			militia_starts++
		if ( start.GetTeam() == TEAM_IMC )
			imc_starts++
	}
	printl( militia_starts + " (6 min) info_spawnpoint_titan_start entities for team MILITIA" )
	printl( imc_starts + " (6 min) info_spawnpoint_titan_start entities for team IMC" )


	//look for titan spawns
	int titan_spawns = GetEntArrayByClass_Expensive( "info_spawnpoint_titan" ).len()
	printl( titan_spawns + " (6 min) info_spawnpoint_titan entities" )

	//look for human spawns
	int human_spawns = GetEntArrayByClass_Expensive( "info_spawnpoint_human" ).len()
	printl( human_spawns + " (6 min) info_spawnpoint_human entities" )


	//look for NPC starts
	//check if there are 6 of the militia team, 6 imc team
	array<entity> npc_starts_array = SpawnPoints_GetDropPodStart( TEAM_ANY )
	int npc_starts = npc_starts_array.len()
	printl( npc_starts + " (12 min) info_spawnpoint_droppod_start entities" )

	int militia_npc_starts = 0
	int imc_npc_starts = 0
	foreach ( start in npc_starts_array )
	{
		if ( start.GetTeam() == TEAM_MILITIA )
			militia_npc_starts++
		if ( start.GetTeam() == TEAM_IMC )
			imc_npc_starts++
	}
	printl( militia_npc_starts + " (6 min) info_spawnpoint_droppod_start entities for team MILITIA " )
	printl( imc_npc_starts + " (6 min) info_spawnpoint_droppod_start entities for team IMC" )

	//look for NPC spawns
	int npc_spawns = SpawnPoints_GetDropPod().len()
	printl( npc_spawns + " (6 min) info_spawnpoint_droppod entities" )


	Assert( titan_starts >= 12, "Less than 12 info_spawnpoint_titan_start entities" )
	Assert( militia_starts >= 6, "Less than 6 info_spawnpoint_titan_start entities for team MILITIA" )
	Assert( imc_starts >= 6, "Less than 6 info_spawnpoint_titan_start entities for team IMC" )
	Assert( titan_spawns >= 6, "Less than 6 info_spawnpoint_titan entities" )
	Assert( human_spawns >= 6, "Less than 6 info_spawnpoint_human entities" )
	Assert( npc_starts >= 12, "Less than 12 info_spawnpoint_droppod_start entities" )
	Assert( militia_npc_starts >= 6, "Less than 6 info_spawnpoint_droppod_start entities for team MILITIA" )
	Assert( imc_npc_starts >= 6, "Less than 6 info_spawnpoint_droppod_start entities for team IMC" )
	Assert( npc_spawns >= 6, "Less than 6 info_spawnpoint_droppod entities" )
}

string function GetGameWonAnnouncement()
{
	return svGlobal.gameWonAnnouncement
}

void function SetGameWonAnnouncement( string announcement )
{
	svGlobal.gameWonAnnouncement = announcement
}

string function GetGameLostAnnouncement()
{
	return svGlobal.gameLostAnnouncement
}

void function SetGameLostAnnouncement( string announcement )
{
	svGlobal.gameLostAnnouncement = announcement
}

void function PerfInitLabels()
{
	PerfClearAll()

	table Table = expect table( getconsttable().PerfIndexServer )
    foreach ( label, intval in Table )
         PerfInitLabel( intval, string( label ) )

	table sharedTable = expect table( getconsttable().PerfIndexShared )
    foreach ( label, intval in sharedTable )
         PerfInitLabel( intval + SharedPerfIndexStart, string( label ) )
}

void function SetSwitchSidesBased( bool state )
{
	if ( state )
		SetSwitchedSides( 0 )
	else
		SetSwitchedSides( -1 )
}

void function SetRoundBasedUsingTeamScore( bool state )
{
	Assert( IsRoundBased() )
	level.roundBasedUsingTeamScore = state
}

void function SetRoundBasedUsingTeamScore_RoundReset( bool state )
{
	Assert( IsRoundBased() )
	Assert( IsRoundBasedUsingTeamScore() )
	svGlobal.roundBasedTeamScore_RoundReset = state
}

void function SetForceNoMoreRounds( bool state )
{
	Assert( IsRoundBased() )
	level.forceNoMoreRounds = state
}

void function SetForceNoFinalRoundDraws( bool state )
{
	Assert( IsRoundBased() )
	svGlobal.forceNoFinalRoundDraws = state
}

void function SetClearTitanTimersOnPlayingEnter( bool state )
{
	file.clearTitanTimersOnPlayingEnter = state
}

float function GetResolutionDuration()
{
	if ( IsPVEMode() )
		return GetCurrentPlaylistVarFloat( "freelance_gamestate_duration_resolution", 10.0 )

	float customDuration = GetCustomResolutionDuration()
	if ( customDuration > 0 )
		return customDuration

	return 2.0
}

void function SetCustomResolutionDuration( float time )
{
	level.customResolutionDuration = time
}

float function GetCustomResolutionDuration()
{
	return expect float( level.customResolutionDuration )
}

void function ProtectTeamFromElimination( int team )
{
	file.teamProtectedFromElimination[ team ] = true
}

void function ClearTeamEliminationProtection()
{
	foreach ( team, protected in file.teamProtectedFromElimination )
	{
		file.teamProtectedFromElimination[ team ] = false
	}
}

// Get is defined in utility_shared since we need it on the client too
void function SetRoundWinningKillEnabled( bool value )
{
	SetGlobalNonRewindNetBool("roundWinningKillReplayEnabled", value)
}

void function SetRoundWinningKillReplayEntities( entity viewEnt, entity victim, int inflictorEHandle )
{
	file.roundWinningKillReplayViewEnt = viewEnt
	file.roundWinningKillReplayVictim = victim
	file.roundWinningKillReplayInflictorEHandle = inflictorEHandle

	// Not sure if this is great: should we assume that the time we call this function is when the kill actually happens?
	file.roundWinningKillReplayKillTime = Time()
}

void function ClearRoundWinningKillReplayEntities( )
{
	file.roundWinningKillReplayViewEnt = null
	file.roundWinningKillReplayVictim = null
	file.roundWinningKillReplayInflictorEHandle = -1

	file.roundWinningKillReplayKillTime = -1
}

void function SetDefaultRoundWinningKillReplayEntities( entity victim, entity attacker, var damageInfo )
{
	entity replayViewEntity = attacker
	if ( !attacker.IsPlayer() && !attacker.IsNPC() )
		replayViewEntity = victim //Set view to victim in case of jumping into hurt triggers, etc. More work to be done here

	entity damageInfoAttacker = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = GetInflictorForKillreplayFromDamageInfo( damageInfoAttacker, DamageInfo_GetInflictor( damageInfo ) )
	SetRoundWinningKillReplayEntities( replayViewEntity, victim, IsValid( inflictor ) ? inflictor.GetEncodedEHandle() : -1 )
}

void function RoundWinningKillReplay()
{
	entity viewEntity = file.roundWinningKillReplayViewEnt
	if ( !IsValid( viewEntity ) )
		return

	int viewEntIdx = viewEntity.GetIndexForEntity()
	entity victim = file.roundWinningKillReplayVictim
	int inflictorEHandle = file.roundWinningKillReplayInflictorEHandle
	array<entity> playersWatchingRoundWinningKillReplay = GetPlayerArrayIncludingSpectators()

	OnThreadEnd(
		function() : ( playersWatchingRoundWinningKillReplay )
		{
			foreach ( player in playersWatchingRoundWinningKillReplay )
			{
				if ( !IsValid( player ) )
					continue

				player.ClearReplayDelay()
				player.ClearViewEntity()
			}

			SetReplayDisabled( false )
			SetRoundWinningKillReplayPlaying( false )
			//ClearRoundWinningKillReplayEntities isn't done here, but instead in prematch instead to not change the time spent in winnerdetermined
		}
	)

	SetRoundWinningKillReplayPlaying( true )
	SetReplayDisabled( true )

	float prefadeWait = GetRoundWinningKillReplayStartupWait() - ROUND_WINNING_KILL_REPLAY_FADE_LENGTH
	wait prefadeWait

	foreach ( entity player in playersWatchingRoundWinningKillReplay )
	{
		player.Signal( "StopPostDeathLogic" )

		EmitSoundOnEntityOnlyToPlayer( player, player, "duck_for_death_slowmo_killcam" )
		ScreenFade( player, 0, 0, 2, 255, ROUND_WINNING_KILL_REPLAY_FADE_LENGTH - 1.5, 0.0, FFADE_OUT | FFADE_STAYOUT ) // Don't use the util ScreenFadeToBlack function because we don't want to purge the existing black screen fades that might be called from elsewhere
	}

	wait ROUND_WINNING_KILL_REPLAY_FADE_LENGTH - 0.5 // Delay before we start kill replay proper
	foreach ( entity player in playersWatchingRoundWinningKillReplay )
	{
		if ( !IsValid( player ) )
			continue

		Remote_CallFunction_NonReplay( player, "ServerCallback_PreKillReplaySounds" )
	}

	wait 0.5

	float actualReplayDelay = GetRoundWinningKillReplayLength() + prefadeWait
	foreach ( entity player in playersWatchingRoundWinningKillReplay )
	{
		if ( !IsValid( player ) )
			continue

		if ( !player.p.clientScriptInitialized )
			continue

		// Bad things happen if we try to do a kill replay that lasts longer than the player entity existing on the server
		if ( Time() - player.p.connectTime <= GetRoundWinningKillReplayLength() )
			continue

		if ( player.IsObserver() )
		{
			// okirkham: this is primarily to prevent issues with freecam observers (since they'll stay freecam-ed when going into a killreplay)
			// 			 ideally, I would've preferred to call player.StopObserverMode() here, but it prevents the player from being recognised as an observer later, and i'm worried that'll cause issues in the end match flow
			//			 using OBS_MODE_STATIC_LOCKED is a hack that seems to prevent any observer-induced issues, without stopping us from being considered an observer by script
			player.StartObserverMode( OBS_MODE_STATIC_LOCKED )
		}

		StopSoundOnEntity( player, "duck_for_death_slowmo_killcam" )

		player.SetKillReplayDelay( actualReplayDelay, GetCurrentPlaylistVarBool( "roundwinningkillreplay_thirdperson", false ) )
		player.SetKillReplayInflictorEHandle( inflictorEHandle )
		player.SetViewIndex( viewEntIdx )
		player.SetIsReplayRoundWinning( true )
		if ( IsValid( victim ) )
			player.SetKillReplayVictim( victim )
	}

	if ( GetCurrentPlaylistVarBool( "roundwinningkillreplay_slowmo", false ) )
	{
		float slowmoBefore = GetCurrentPlaylistVarFloat( "roundwinningkillreplay_slowmo_before_time", 0.5 )
		float slowmoAfter = GetCurrentPlaylistVarFloat( "roundwinningkillreplay_slowmo_after_time", 0.3 )

		float timeLeft = GetRoundWinningKillReplayLength()
		float timeToKill = file.roundWinningKillReplayKillTime - ( Time() - actualReplayDelay )

		printt( format( "RoundWinningKillReplay(): scaling timescale - before kill, %f seconds until kill", timeToKill ) )
		timeLeft -= timeToKill - slowmoBefore
		wait timeToKill - slowmoBefore
		//SetTimescale( GetCurrentPlaylistVarFloat( "roundwinningkillreplay_slowmo_timescale", 0.25 ) )

		printt( "RoundWinningKillReplay(): scaling timescale - after kill" )
		timeLeft -= slowmoBefore + slowmoAfter
		wait slowmoBefore + slowmoAfter
		//SetTimescale( 1.0 )

		printt( "RoundWinningKillReplay(): scaling timescale - done" )

		wait timeLeft
	}
	else
	{
		wait GetRoundWinningKillReplayLength()
	}

	//NOTE: This loop was originally called for all players, but this would result in players who connected during the kill replay gettting a permently black screen.
	foreach ( player in playersWatchingRoundWinningKillReplay )
	{
		if ( !IsValid( player ) )
			continue

		// if we're not watching a killreplay now then code has cancelled it, or something else has gone weird
		PIN_KillreplayFinished( player, viewEntity, GetRoundWinningKillReplayLength(), GetRoundWinningKillReplayLength(), player.IsWatchingKillReplay() ? ePINKillreplayExitReason.EXPIRED : ePINKillreplayExitReason.ERROR, true )
		ScreenFade( player, 0, 0, 1, 255, 1.5, 1.5, FFADE_STAYOUT | FFADE_PURGE | FFADE_NOT_IN_REPLAY ) //Instant screen black as opposed to screen fade
	}
}

void function SetRoundWinningKillReplayPlaying( bool value )
{
	SetGlobalNonRewindNetBool( "roundWinningKillReplayPlaying", value )
}

float function GetCustomIntroLength()
{
	return file.customIntroLength
}

void function SetCustomIntroLength( float len )
{
	file.customIntroLength = len
}

void function SetCustomWinnerDeterminedLength( float len )
{
	file.customWinnerDeterminedLength = len
}

void function SetAbandonCheckFunc( bool functionref( entity ) func )
{
	svGlobal.gameModeAbandonPenaltyApplies = func
}

void function SetTimelimitCompleteFunc( bool functionref() timeLimitCompleteFunc )
{
	svGlobal.timelimitCompleteFunc = timeLimitCompleteFunc
}

bool function ClearTitanTimersOnPlayingEnter()
{
	return file.clearTitanTimersOnPlayingEnter
}

void function SetClearBurnRewardsOnPlayingEnter( bool state )
{
	file.clearBurnRewardsOnPlayingEnter = state
}

bool function ClearBurnRewardsOnPlayingEnter()
{
	return file.clearBurnRewardsOnPlayingEnter
}

void function SetAnnounceRoundWinnerRules( void functionref( int ) rules )
{
	file.announceRoundWinnerRules = rules
}

void function SetPlayThreeMinuteMusic( bool value )
{
	file.shouldPlayThreeMinuteMusic = value
}

bool function InitialPlayerSpawnOccurred()
{
	return file.initialPlayerSpawnOccurred
}

#if DEVELOPER
void function TestRoundWinningReplay()
{
	SetRoundWinningKillReplayEntities( GetPlayerArray().getrandom(), GetPlayerArray().getrandom(), -1 )
	waitthread RoundWinningKillReplay()
	ScreenFade( GetPlayerArray()[0], 255, 255, 255, 255, 0.1, 0, FFADE_PURGE )
	UnMuteAll( GetPlayerArray()[0] )
}
#endif

const ARRAY_REMOVE_INVALID_INTERVAL = 100
void function MarkEntForCleanupOnRoundEnd( entity ent )
{
	if ( !IsLootRoundBased() )
		return

	if ( !IsValid( ent ) )
		return

	AddToScriptManagedEntArray( file.roundPermanentsIdx, ent )
}

void function CleanUpMarkedEntsOnRoundStart()
{
	foreach ( ent in GetScriptManagedEntArray( file.roundPermanentsIdx ) )
	{
		ent.Destroy()
	}
}

void function MarkEntForCleanupOnWinnerDetermined( entity ent )
{
	if ( !IsValid( ent ) )
		return

	AddToScriptManagedEntArray( file.gamePermanentsIdx, ent )
}

void function CleanUpMarkedEntsOnWinnerDetermined()
{
	foreach ( ent in GetScriptManagedEntArray( file.gamePermanentsIdx ) )
	{
		ent.Destroy()
	}
}

bool function GameState_HasRoundRestarted()
{
	return ( IsRoundBased() && GetRoundsPlayed() > 0 )
}

void function AddCallback_ShouldPlayerSpawnAtStart( bool functionref( entity  ) func )
{
	file.shouldPlayerSpawnAtStartCallback = func
}

bool function DoesCurrentModeHaveMapSetup()
{

		if ( GameMode_IsActive( eGameModes.CONTROL ) )
			return true


	return false
}

bool function DoesCurrentModeHaveDeathfield()
{
	return GetCurrentPlaylistVarBool( "deathfield_is_enabled", true )
}

bool function GetHasGameTimedOut()
{
	return file.gameTimedOut
}