global function PrivateMatch_Init
global function IsPrivateMatchLobby
global function PrivateMatch_RegisterNetworking

#if SERVER || CLIENT
global function PrivateMatch_GetMaxTeamsForSelectedGamemode
#endif

#if SERVER
global function PrivateMatch_OnPlayerConnected
global function PrivateMatch_OnPlayerConnecting
global function PrivateMatch_GetTeamFinalPlacement

//Match Functions
global function PrivateMatch_Match_Init

global function ClientCallback_PrivateMatchChangeObserverTarget
global function ClientCallback_PrivateMatchToggleSurveyRing
global function ClientCallback_PrivateMatchRefreshSurveyRing
global function ClientCallback_PrivateMatchReportObserverTargetChanged

global function ClientCallback_PrivateMatchSetPlayerTeam
global function ClientCallback_PrivateMatchKickPlayer
global function ClientCallback_PrivateMatchSetTeamName
global function ClientCallback_PrivateMatchSetPlaylist
global function ClientCallback_PrivateMatchSetAdminConfig
global function ClientCallback_PrivateMatchEndMatchEarly
global function ClientCallback_PrivateMatchToggleAimAssist
global function ClientCallback_PrivateMatchToggleAnonymousMode

#endif


#if CLIENT
global function PrivateMatch_ClientFrame
global function PrivateMatch_GetPlayerTeamStats
global function PrivateMatch_GetTeamName

global function ServerCallback_EnableGameStatusMenu
global function ServerCallback_PrivateMatch_SquadEliminated
global function PrivateMatch_OpenGameStatusMenu
global function PrivateMatch_SortPlayersByName
global function PrivateMatch_ToggleSurveyRing

global function PrivateMatch_ClientOnSquadEliminated
#if DEVELOPER
global function DEV_ShowSpectatorButtonHints
#endif//DEV
#endif

#if UI
global function PrivateMatch_CreateMatchEndEarlyDialog
global function PrivateMatch_SetSelectedPlaylist
#endif

global const string MAX_PLAYERS_PLAYLIST_VAR = "max_players"
global const string MAX_TEAMS_PLAYLIST_VAR = "max_teams"
global const int PRIVATEMATCH_ISREADY_BIT = 1
global const int PRIVATEMATCH_ISPRELOADING_BIT = 2

global const string CUSTOM_AIM_ASSIST_CONVAR_NAME = "sv_private_assist_style_override"
global const string GLOBAL_AIM_ASSIST_CONVAR_NAME = "sv_tournament_assist_style_override"
global const string CUSTOM_ANONYMOUS_MODE_CONVAR_NAME = "sv_tournament_anonymous_mode"
global const string OBSERVER_PRESET_TEAM_CONVAR_NAME = "cl_observer_preset_team"
global const string OBSERVER_PRESET_PLAYERSLOT_CONVAR_NAME = "cl_observer_preset_playerSlot"
global const string OBSERVER_PRESET_PLAYERHASH_CONVAR_NAME = "cl_observer_preset_playerHash"

const string WAYPOINTTYPE_PLAYERTEAMSTATS = "team_stats"

const int WP_STRING_INDEX_PLAYERNAME = 0
const int WP_STRING_INDEX_TEAMNAME = 1

const int WP_INT_INDEX_PLAYERINDEX = 0
const int WP_INT_INDEX_PLACEMENT = 1
const int WP_INT_INDEX_TEAMINDEX = 2
const int WP_INT_INDEX_PLAYERKILLS = 3
const int WP_INT_INDEX_PLAYERDAMAGE = 4
const int WP_INT_INDEX_SURVIVALTIME = 5
const int WP_INT_INDEX_PLAYERASSISTS = 6

global const int TEAM_SPECTATOR_MAX_PLAYERS = 10

const asset PM_CHAMPION_SCREEN = $"ui/private_match_champion_screen.rpak"

//Observers
const float PM_OBSERVER_HIGHLIGHT_TOGGLE_DEBOUNCE = 0.5

global struct RosterStruct
{
	var           headerPanel
	var           framePanel
	var           listPanel
	int           teamIndex
	int           teamSize
	int           teamDisplayNumber
	array<entity> playerRoster

	array<var>      _listButtons

	array<PrivateMatchStatsStruct> playerPlacementData
}

struct
{
	string		selectedPlaylist = ""
	int			playlistMaxTeams
	int			playlistTeamSize
	int			lastObserverCommand = -1
	PrivateMatchChatConfigStruct chatConfig
	
	table< int, PrivateMatchStatsStruct > privateMatchStats

	array<int> teamFinalPlacementArray = []

	bool 		cachedAimAssistOverride = false

	table signalDummy = {}
	array <var> buttonHints = []
	bool buttonHintsCreated = false
	bool buttonHintsHidden = true
} file



void function PrivateMatch_Init()
{
	if ( !IsPrivateMatch() && !IsPrivateMatchLobby() )
		return

	array<string> privateMatchPlaylists = GetVisiblePlaylistNames( true )

	#if SERVER
		AddCallback_EntitiesDidLoad( PrivateMatch_EntitiesDidLoad )
		AddCallback_GameStateEnter( eGameState.PickLoadout, PrivateMatch_OnPickLoadout )
		AddCallback_GameStateEnter( eGameState.Playing, PrivateMatch_OnPlaying )
		AddCallback_GameStatePostEnter( eGameState.WinnerDetermined, PrivateMatch_OnWinnerDetermined )

		Survival_AddCallback_OnSquadEliminated( OnSquadEliminated )

		//AddCallback_OnPlayerMatchStateChanged( PrivateMatch_OnPlayerMatchStateChanged )
	#endif //SERVER

	#if CLIENT
		Waypoints_RegisterCustomType( WAYPOINTTYPE_PLAYERTEAMSTATS, InstancePlayerTeamStats )
		AddOnSpectatorTargetChangedCallback( OnSpectatorTargetChanged )
		AddFreeCamSpectateStartedCallback( OnSpectatorModeChanged )
		AddFreeCamSpectateEndedCallback( OnSpectatorModeChanged )
		RegisterConCommandTriggeredCallback( "toggle_obs_ring_survey", PrivateMatch_ToggleSurveyRing )
		AddCallback_GameStateEnter( eGameState.Playing, OnSpectatorStarted )
		AddCallback_GameStateEnter( eGameState.Resolution, PrivateMatch_OnResolution )
		AddFirstPersonSpectateStartedCallback( OnFPSSpectatorStarted )
		AddThirdPersonSpectateStartedCallback( OnTPSSpectatorStarted )
		AddFreeCamSpectateStartedCallback( OnFreecamSpectatorStarted )
	#endif
		
	#if CLIENT || SERVER
	
		// admin logic
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchKickPlayer", "typed_entity", "player" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetPlayerTeam", "typed_entity", "player", "int", TEAM_UNASSIGNED, TEAM_MULTITEAM_LAST )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleAimAssist" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleAnonymousMode" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetPlaylist", "int", 0, GetPlaylistCount() - 1 )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetAdminConfig", "int", 0, ACM_COUNT, "bool" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchEndMatchEarly" )
	
		// observer logic
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchChangeObserverTarget", "typed_entity", "player" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleSurveyRing" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchRefreshSurveyRing" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchReportObserverTargetChanged" )
	#endif

	int maxTeams
}

void function PrivateMatch_RegisterNetworking()
{
	RegisterNetworkedVariable( "lastSquadEliminated", SNDC_GLOBAL, SNVT_INT, -1 )

	Remote_RegisterClientFunction( "ServerCallback_EnableGameStatusMenu", "bool" )
	Remote_RegisterClientFunction( "ServerCallback_PrivateMatch_SquadEliminated", "int", TEAM_INVALID, 60, "int", 0, 60 )


	#if CLIENT || SERVER
		RegisterNetworkedVariable( NV_OBSERVER_SURVERY_RING_ENABLED, SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )
	#endif

	#if CLIENT
		AddCallback_OnGameStateChanged( PrivateMatch_OnGameStateChanged )
		RegisterNetVarIntChangeCallback( "lastSquadEliminated", PrivateMatch_ClientOnSquadEliminated )
	#endif
}

#if CLIENT
// Note value passed in needs to be a Team, if an alliance is passed in the logic breaks
string function PrivateMatch_GetTeamName( int teamIndex )
{
	Assert( teamIndex > TEAM_INVALID ) // Make sure team is not invalid
	string teamName = GameRules_GetTeamName( teamIndex )
	string defaultTeamName = ( AllianceProximity_IsUsingAlliances() )?Localize( "#TEAM_NUMBERED", AllianceProximity_GetAllianceFromTeam( teamIndex ) + 1 ) :Localize( "#TEAM_NUMBERED", teamIndex - 1 )

	return teamName != "" ? teamName : defaultTeamName
}

int function PrivateMatch_SortPlayersByName( entity a, entity b )
{
	if ( a.GetPlayerName() > b.GetPlayerName() )
		return 1

	if ( a.GetPlayerName() < b.GetPlayerName() )
		return -1

	return 0
}

void function PrivateMatch_ClientFrame()
{
	PerfStart( PerfIndexClient.PrivateLobbyThread )
	array<entity> players = GetPlayerArrayIncludingSpectators()

	table< int, array< entity > > teamPlayersMap
	foreach ( player in players )
	{
		if ( !(player.GetTeam() in teamPlayersMap) )
			teamPlayersMap[player.GetTeam()] <- []

		teamPlayersMap[player.GetTeam()].append( player )
	}

	foreach ( teamIndex, teamRoster in teamPlayersMap )
	{
		teamPlayersMap[teamIndex].sort( PrivateMatch_SortPlayersByName )
	}

	PrivateMatch_TeamRosters_Update( teamPlayersMap )

	PerfEnd( PerfIndexClient.PrivateLobbyThread )
}

void function InstancePlayerTeamStats( entity wp )
{
	PrivateMatchStatsStruct privateMatchStats
	privateMatchStats.platformUid = wp.GetWaypointGroupName()
	privateMatchStats.playerName = wp.GetWaypointString( WP_STRING_INDEX_PLAYERNAME )
	privateMatchStats.teamName = wp.GetWaypointString( WP_STRING_INDEX_TEAMNAME )
	privateMatchStats.teamPlacement = wp.GetWaypointInt( WP_INT_INDEX_PLACEMENT )
	privateMatchStats.teamNum = wp.GetWaypointInt( WP_INT_INDEX_TEAMINDEX )
	privateMatchStats.kills = wp.GetWaypointInt( WP_INT_INDEX_PLAYERKILLS )
	privateMatchStats.damageDealt = wp.GetWaypointInt( WP_INT_INDEX_PLAYERDAMAGE )
	privateMatchStats.survivalTime = wp.GetWaypointInt( WP_INT_INDEX_SURVIVALTIME )
	privateMatchStats.assists = wp.GetWaypointInt( WP_INT_INDEX_PLAYERASSISTS )

	int playerIndex = wp.GetWaypointInt( WP_INT_INDEX_PLAYERINDEX )
	file.privateMatchStats[playerIndex] <- privateMatchStats
}


PrivateMatchStatsStruct ornull function PrivateMatch_GetPlayerTeamStats( int playerIndex )
{
	if ( !(playerIndex in file.privateMatchStats) )
		return null

	return file.privateMatchStats[playerIndex]
}

void function ServerCallback_EnableGameStatusMenu( bool doEnable )
{
	RunUIScript( "EnablePrivateMatchGameStatusMenu", doEnable )

	if ( doEnable == false )
		RunUIScript( "ClosePrivateMatchGameStatusMenu", null )
}

void function PrivateMatch_OpenGameStatusMenu()
{
	if ( GetLocalClientPlayer().GetTeam() == TEAM_SPECTATOR )
		RunUIScript( "OpenPrivateMatchGameStatusMenu", null )
}

void function PrivateMatch_ToggleSurveyRing( entity player )
{
	if( player.GetTeam() == TEAM_SPECTATOR )
	{
		printt( "OBS_SURVEY: toggling Ring Survey for observer "+player )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchToggleSurveyRing" )
	}
}

#endif //CLIENT

#if SERVER
void function PrivateMatch_KickPlayersInBadTeams( string playlistName )
{
	foreach ( player in GetPlayerArray() )
	{
		if ( player.GetTeam() >= TEAM_MULTITEAM_FIRST + file.playlistMaxTeams )
			SetTeam( player, TEAM_UNASSIGNED )
	}
}
#endif

void function PrivateMatch_SetUpTeamRosters( string playlistName )
{
	file.selectedPlaylist = playlistName

	int maxPlayers = GetPlaylistVarInt( file.selectedPlaylist, MAX_PLAYERS_PLAYLIST_VAR, 60 )
	file.playlistMaxTeams = GetPlaylistVarInt( file.selectedPlaylist, MAX_TEAMS_PLAYLIST_VAR, 20 )
	file.playlistTeamSize = maxPlayers / file.playlistMaxTeams

	#if SERVER
		int lastTeamIdx = (TEAM_MULTITEAM_FIRST + file.playlistMaxTeams) <= ABSOLUTE_MAX_TEAMS ? (TEAM_MULTITEAM_FIRST + file.playlistMaxTeams) : ABSOLUTE_MAX_TEAMS
		for ( int i = TEAM_MULTITEAM_FIRST; i < lastTeamIdx; i++ )
			GameRules_SetTeamName( i, "" )
	#endif

	//printf( "PrivateMatchLobbyDebug: Rosters initialized: %i players per team, %i teams", file.playlistTeamSize, file.playlistMaxTeams )
}


#if SERVER
void function PrivateMatch_OnPlayerConnecting( entity player )
{
	Assert( IsPrivateMatchLobby() )

	//if ( player.HasMatchAdminRole() )
	//	SetTeam( player, TEAM_SPECTATOR )
	//else
		SetTeam( player, TEAM_UNASSIGNED )
}



void function PrivateMatch_OnPlayerConnected( entity player )
{
	Assert( IsPrivateMatchLobby() )
	
	// TODO: This is where we would need to load from the private match settings JSON
	//if ( player.HasMatchAdminRole() )
	//	SetTeam( player, TEAM_SPECTATOR )
	//else
		SetTeam( player, TEAM_UNASSIGNED )
}


void function PrivateMatch_EntitiesDidLoad()
{
	if ( !IsPrivateMatchLobby() )
		return

	array<string> privateMatchPlaylists = GetVisiblePlaylistNames( true )
	PrivateMatch_SetUpTeamRosters( privateMatchPlaylists.len() > 0 ? privateMatchPlaylists[0] : "" )

	PrivateMatch_InitPostGameStats()
}

void function ClientCallback_PrivateMatchSetPlaylist( entity player, int playlistIndex )
{
	if ( !IsPrivateMatchLobby() )
		return

	//if ( !player.HasMatchAdminRole() )
		return

	Assert( 0 <= playlistIndex && playlistIndex < GetPlaylistCount(), "Invalid playlistIndex passed through callback, did the playlist count change since registration?"  )
	string playlistName = expect string( GetPlaylistName( playlistIndex ) )

	// this seems weird, but the index here isn't the same as the above, this is from
	// as script defined cache, where as the one passed in is the global one from the playlist interface
	if ( GetPlaylistIndexForName( playlistName ) < 0 )
		return

	PrivateMatch_SetUpTeamRosters( playlistName )
	PrivateMatch_KickPlayersInBadTeams( playlistName )
}

void function ClientCallback_PrivateMatchSetPlayerTeam( entity player, entity reassignPlayer, int newTeam )
{
	if ( !IsPrivateMatchLobby() )
		return

	if ( newTeam <= TEAM_INVALID || newTeam > TEAM_MULTITEAM_LAST )
		return

	if ( !IsValid( reassignPlayer ) )
		return

	if ( newTeam != TEAM_UNASSIGNED && newTeam != TEAM_SPECTATOR && GetPlayerArrayOfTeam( newTeam ).len() >= file.playlistTeamSize )
		return

	int maxObservers = GetPlaylistVarInt( "private_match", "max_observers", TEAM_SPECTATOR_MAX_PLAYERS )
	if ( newTeam == TEAM_SPECTATOR && GetPlayerArrayOfTeam( TEAM_SPECTATOR ).len() >= maxObservers )
		return

	SetTeam( reassignPlayer, newTeam )
}

void function ClientCallback_PrivateMatchSetTeamName( entity player, int teamIndex, string newTeamName )
{
	Assert(1 == 0, "ClientCallback_PrivateMatchSetTeamName is legacy code and not expected to be used, fix usage of string in rpc to use")
	if ( !IsPrivateMatchLobby() )
		return

	if ( teamIndex < TEAM_MULTITEAM_FIRST )
		return

	GameRules_SetTeamName( teamIndex, newTeamName )
}

void function StartMatch()
{
	foreach ( teamPlayer in GetPlayerArrayIncludingSpectators() )
	{
		if ( teamPlayer.GetTeam() == TEAM_UNASSIGNED )
		{
			string unassignedPlayerBehavior = GetCurrentPlaylistVarString( "private_match_unassigned_behavior", "kick" )
			switch ( unassignedPlayerBehavior )
			{
				case "halt":
					return

				case "kick":
					DisconnectWithMessage( teamPlayer, "#DISCONNECT_PRIVATEMATCH_UNASSIGNED" )
					continue

				case "ignore":
				default:
					break
			}
		}

		// TODO: Matchmaking teams and code/script teams seem to disagree
		int desiredTeamIndex = teamPlayer.GetTeam()
		SetTeam( teamPlayer, TEAM_UNASSIGNED )
		SetTeam( teamPlayer, desiredTeamIndex )
	}

	// TODO: Temp hack to transfer team names from lobby
	printt( "SetPrivateMatchStats - MaxTeams = "+ ( file.playlistMaxTeams + TEAM_MULTITEAM_FIRST ) + "\nCallstack:\n" + GetStack() )
	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < file.playlistMaxTeams + TEAM_MULTITEAM_FIRST; teamIndex++ )
	{
		PrivateMatchStatsStruct privateMatchStats
		privateMatchStats.teamName = GameRules_GetTeamName( teamIndex )
		printf( "PrivateMatchLobbyDebug: Setting team name for team %i to %s", teamIndex, privateMatchStats.teamName )
		SetPrivateMatchStats( teamIndex, privateMatchStats )
	}
	// TODO: End temp hack
		
	LaunchPrivateMatchPlaylist( file.selectedPlaylist )

	// If the aim assist configurations differ, set the global aim assist value to match the
	// private match configuration.
	bool aimAssistConfig = GetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME )
	bool globalAimAssistConfig = GetConVarBool( GLOBAL_AIM_ASSIST_CONVAR_NAME )
	if ( aimAssistConfig != globalAimAssistConfig )
	{
		SetConVarBool( GLOBAL_AIM_ASSIST_CONVAR_NAME, aimAssistConfig )
	}
	// Store the global state here
	file.cachedAimAssistOverride = globalAimAssistConfig
}

void function ClientCallback_PrivateMatchToggleAimAssist( entity player )
{
	if ( !IsPrivateMatchLobby())// || !player.HasMatchAdminRole() )
		return

	bool newAimAssistSetting = !GetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME )
	SetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME, newAimAssistSetting )
}

void function ClientCallback_PrivateMatchToggleAnonymousMode( entity player )
{
	if ( !IsPrivateMatchLobby())// || !player.HasMatchAdminRole() )
		return

	bool anonymize = !GetConVarBool( CUSTOM_ANONYMOUS_MODE_CONVAR_NAME )
	SetConVarBool( CUSTOM_ANONYMOUS_MODE_CONVAR_NAME, anonymize )
}

void function ClientCallback_PrivateMatchChangeObserverTarget( entity player, entity target )
{
	if ( !IsValid( target ) )
		return

	if ( !IsAlive( target ) )
		return

	if ( player.GetTeam() != TEAM_SPECTATOR )
		return

	printf( "Observer: User %s switched to spectating %s", player.GetPINNucleusPid(), target.GetPINNucleusPid() )
	player.SetObserverTarget( target )
}

void function ClientCallback_PrivateMatchSetAdminConfig( entity player, int chatMode, bool spectatorChat )
{
	//if ( !player.HasMatchAdminRole() )
		return

	if ( player.GetTeam() != TEAM_SPECTATOR )
		return

	PrivateMatchAdminChatConfigStruct adminConfig
	adminConfig.chatMode = chatMode
	adminConfig.spectatorChat = spectatorChat

	switch ( chatMode )
	{
		case ACM_TEAM:
		{
			entity target = player.GetObserverTarget()
			adminConfig.targetIndex = IsValid( target ) && target.IsPlayer() ? target.GetTeam() : -1
			break
		}
		case ACM_PLAYER:
		{
			entity target = player.GetObserverTarget()
			adminConfig.targetIndex = IsValid( target ) && target.IsPlayer() ? target.GetPlayerIndex() : -1
			break
		}
		default:
		{
			adminConfig.targetIndex = -1
			break
		}
	}

	PrivateMatchSetChatConfig( player.entindex(), adminConfig )
}

void function ClientCallback_PrivateMatchEndMatchEarly( entity player )
{
	if ( !IsPrivateMatch() )
	{
		printf( "Attempting to end match early from none admin player" )
		return
	}

	//if ( !player.HasMatchAdminRole() )
	{
		printf( "Attempting to end match early from none admin player" )
		return
	}

	if ( GetGameState() >= eGameState.WinnerDetermined || GamemodeUtility_IsWinnerBeingDetermined() )
	{
		printf( "Attempting to end match early when match has already finished" )
		return
	}

	SetWinner( TEAM_UNASSIGNED, eWinReason.ELIMINATION, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
	SetGameState( eGameState.WinnerDetermined )
	SetGameState( eGameState.Resolution )
	return
}

void function ClientCallback_PrivateMatchKickPlayer( entity player, entity kickPlayer )
{
	//if ( !player.HasMatchAdminRole() )
		return
		
	if ( !IsValid( kickPlayer ) )
		return
		
	PrivateMatchKickPlayer( kickPlayer )
}


void function PrivateMatch_OnWinnerDetermined()
{
	if ( !IsPrivateMatch() )
		return

	                        
	if ( GameMode_IsActive( eGameModes.CONTROL ) )
		return
       

	                        
	if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_GUNGAME ) ) //TODO: Remove this an set up post game stats for private matches
		return
       

	if ( IsRoundBased() )
	{
		if( !GetGlobalNonRewindNetBool("roundScoreLimitComplete") )
		{
			return
		}
	}

	if ( GetGameState() < eGameState.Resolution )
	{
		PrivateMatch_ClearStats()
		thread PrivateMatch_StoreStats()
	}

	string endReason = GameRules_GetTeamName( GetWinningTeam() ) ==  "Unassigned" ? "Private Match Ended Early" : "Private Match Ended"
	foreach ( entity player in GetPlayerArray() )
	{
		if ( player.GetTeam() == TEAM_SPECTATOR )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_EnableGameStatusMenu", false )
		}

		//PIN_PlayerLeft( player, endReason, false )
	}
}


void function PrivateMatch_OnPickLoadout()
{
	                         
	//PrivateMatch_ClearStats()
	int maxTeams = PrivateMatch_GetMaxTeamsForSelectedGamemode()
	bool hasSpawnPointSelection = ForcedSpawn_UseForcedSpawning()

	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < (TEAM_MULTITEAM_FIRST + maxTeams); teamIndex++ )
	{
		string currentTeamName = GameRules_GetTeamName(teamIndex)
		if ( hasSpawnPointSelection && currentTeamName.len() > 1)
		{
			// We expect team names to be something like "MyTeam @ 52" indicating
			array<string> parts = GetTrimmedSplitString( currentTeamName, "@" )

			int selectedIndex = 0
			//if ( parts.len() > 1 && parts[1].isnumeric() )
			{
				//selectedIndex = ConvertStringToInt( parts[1] ) - 1

				printt("Team", currentTeamName, "request Spawn #", selectedIndex)
				//ForcedSpawn_TrySetTeamSpawnFromLocationIndex( teamIndex, selectedIndex )
			}
		}
	}
                                
}


void function PrivateMatch_OnPlaying()
{
	printt( "PrivateMatchGameStateDebug: OnPlaying" )

	array<entity> observers = GetPlayerArrayOfTeam( TEAM_SPECTATOR )
	{
		foreach ( observer in observers )
		{
			PutPlayerInObserverMode( observer, OBS_MODE_IN_EYE )
		}
	}

	foreach ( entity player in GetPlayerArray() )
	{
		if ( player.GetTeam() == TEAM_SPECTATOR )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_ManageHighlights" )
			Highlight_RefreshObserverHighlights( player )

			//PutPlayerInObserverMode( player, OBS_MODE_IN_EYE )
			Remote_CallFunction_Replay( player, "ServerCallback_EnableGameStatusMenu", true )
		}
	}
}


void function PrivateMatch_ClearStats()
{
	printf( "PrivateMatch_ClearStats()" )
	printt( "SetPrivateMatchStats - MaxTeams = "+ ( GetCurrentPlaylistVarInt( "maxTeams", 20 ) + TEAM_MULTITEAM_FIRST ) + "\nCallstack:\n" + GetStack() )
	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < GetCurrentPlaylistVarInt( "maxTeams", 20 ) + TEAM_MULTITEAM_FIRST; teamIndex++ )
	{
		PrivateMatchStatsStruct pmss
		SetPrivateMatchStats( teamIndex, pmss )
	}
}


int function PrivateMatch_GetTeamFinalPlacement( int teamIndex )
{
	int placement = GetAllValidPlayerTeams().len() - file.teamFinalPlacementArray.len()

	if ( file.teamFinalPlacementArray.contains( teamIndex ) )
		placement += file.teamFinalPlacementArray.find( teamIndex ) + 1

	 return placement > 0 ? placement : 0
}


void function PrivateMatch_StoreStats()
{
	WaitFrame() // Need to wait a frame so kill callbacks and complete (game goes into WinnerDetermined gamestate before kill callback is even finished)

	int winningTeamIndex = GetWinningTeam()
	file.teamFinalPlacementArray.insert( 0, winningTeamIndex )

	int playerIndex = 0
	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < TEAM_MULTITEAM_LAST; teamIndex++ )
	{
		table< int, GameSummarySquadData > ornull squadDataMap = GameSummary_GetTeamDataOrNull( teamIndex )

		if ( squadDataMap == null )
		{
			continue
		}

		expect table<int, GameSummarySquadData>( squadDataMap )

		int rank = file.teamFinalPlacementArray.find( teamIndex ) + 1
		printt( "PrivateMatch_StoreStats", teamIndex, rank )

		printt( "SetPrivateMatchStats - squadDataMap.Len = " + squadDataMap.len() + "\nCallstack:\n" + GetStack() )
		foreach ( teamMemberIndex, playerSummaryData in squadDataMap )
		{
			PrivateMatchStatsStruct privateMatchStats
			privateMatchStats.playerName = playerSummaryData.playerName
			privateMatchStats.characterName = ItemFlavor_GetCharacterRef( playerSummaryData.character )
			privateMatchStats.kills = playerSummaryData.kills
			privateMatchStats.assists = playerSummaryData.assists
			privateMatchStats.knockdowns = playerSummaryData.knockdowns
			privateMatchStats.damageDealt = playerSummaryData.damageDealt
			privateMatchStats.shots = playerSummaryData.shots
			privateMatchStats.hits = playerSummaryData.hits
			privateMatchStats.headshots = playerSummaryData.headshots
			privateMatchStats.revivesGiven = playerSummaryData.revivesGiven
			privateMatchStats.respawnsGiven = playerSummaryData.respawnsGiven
			privateMatchStats.survivalTime = playerSummaryData.survivalTime
			privateMatchStats.hardware = playerSummaryData.hardware
			privateMatchStats.platformUid = playerSummaryData.platformUid
			privateMatchStats.teamName = GameRules_GetTeamName( teamIndex )
			privateMatchStats.teamPlacement = rank
			privateMatchStats.teamNum = teamIndex
			entity player = GetEntityFromEncodedEHandle( playerSummaryData.eHandle )
			privateMatchStats.alive = player ? player.IsEntAlive() : false

			printt( "PrivateMatch_StoreStats: Team %i Player %i: Name: %s, kills: %i, team name: %s, team placement: %i", teamIndex, teamMemberIndex, privateMatchStats.playerName, privateMatchStats.kills, privateMatchStats.teamName, privateMatchStats.teamPlacement )
			SetPrivateMatchStats( playerIndex, privateMatchStats )

			playerIndex++
		}
	}

	if ( !IsPrivateMatch() )
	{
		Warning( "%s() - skipping rest of function because this is not a private match.", FUNC_NAME() )
		return
	}
	FinalizePrivateMatchStats()
}


PrivateMatchStatsStruct function MOCK_GetPrivateMatchStats( int index )
{
	var randomSeed = CreateRandomSeed( index )
	PrivateMatchStatsStruct privateMatchStats
	if ( index < 60 )
	{
		privateMatchStats.playerName = "PlayerName" + index
		privateMatchStats.kills = RandomIntSeeded( randomSeed, 20 )
		privateMatchStats.assists = RandomIntSeeded( randomSeed, 10 )
		privateMatchStats.damageDealt = RandomIntSeeded( randomSeed, 800 )
		privateMatchStats.survivalTime = RandomIntSeeded( randomSeed, 900 )
		privateMatchStats.hardware = "hardware" + index
		privateMatchStats.platformUid = "platformUID" + index
		privateMatchStats.teamName = "TeamName" + (TEAM_MULTITEAM_FIRST + (index % 20))
		privateMatchStats.teamPlacement = RandomIntSeeded( randomSeed, 19 )
		privateMatchStats.teamNum = TEAM_MULTITEAM_FIRST + (index % 20)
	}

	return privateMatchStats
}


void function PrivateMatch_DumpStats()
{
	for ( int playerIndex = 0; playerIndex < ABSOLUTE_MAX_TEAMS; playerIndex++ )
	{
		PrivateMatchStatsStruct privateMatchStats = GetPrivateMatchStats( playerIndex )
		if ( privateMatchStats.teamName == "" )
			continue

		printt( "privateMatchStats.playerName", privateMatchStats.playerName )
		printt( "privateMatchStats.kills", privateMatchStats.kills )
		printt( "privateMatchStats.assists", privateMatchStats.assists )
		printt( "privateMatchStats.damageDealt", privateMatchStats.damageDealt )
		printt( "privateMatchStats.survivalTime", privateMatchStats.survivalTime )
		printt( "privateMatchStats.hardware", privateMatchStats.hardware )
		printt( "privateMatchStats.platformUid", privateMatchStats.platformUid )
		printt( "privateMatchStats.teamName", privateMatchStats.teamName )
		printt( "privateMatchStats.teamPlacement", privateMatchStats.teamPlacement )
		printt( "privateMatchStats.teamNum", privateMatchStats.teamNum )
		printt( "" )
	}
}


void function PrivateMatch_InitPostGameStats()
{
	for ( int playerIndex = 0; playerIndex < ABSOLUTE_MAX_TEAMS; playerIndex++ )
	{
		/*
				{
					PrivateMatchStatsStruct tempStats = MOCK_GetPrivateMatchStats( playerIndex )
					SetPrivateMatchStats( playerIndex, tempStats )
				}
		*/

		PrivateMatchStatsStruct privateMatchStats = GetPrivateMatchStats( playerIndex )
		if ( privateMatchStats.teamName == "" )
		{
			PrivateMatchStatsStruct privateMatchDummyStats
			privateMatchDummyStats.teamName = " "
			privateMatchDummyStats.playerName = " "
			privateMatchDummyStats.teamPlacement = -1
			CreatePlayerTeamStats( privateMatchDummyStats, playerIndex )
			continue
		}

		CreatePlayerTeamStats( privateMatchStats, playerIndex )
	}
}


entity function CreatePlayerTeamStats( PrivateMatchStatsStruct privateMatchStats, int playerIndex )
{
	entity wp = CreateWaypoint_Custom( WAYPOINTTYPE_PLAYERTEAMSTATS )
	wp.SetWaypointGroupName( privateMatchStats.platformUid )
	wp.SetWaypointString( WP_STRING_INDEX_PLAYERNAME, privateMatchStats.playerName )
	wp.SetWaypointString( WP_STRING_INDEX_TEAMNAME, privateMatchStats.teamName )
	wp.SetWaypointInt( WP_INT_INDEX_PLAYERINDEX, playerIndex )
	wp.SetWaypointInt( WP_INT_INDEX_PLACEMENT, privateMatchStats.teamPlacement )
	wp.SetWaypointInt( WP_INT_INDEX_TEAMINDEX, privateMatchStats.teamNum )
	wp.SetWaypointInt( WP_INT_INDEX_PLAYERKILLS, privateMatchStats.kills )
	wp.SetWaypointInt( WP_INT_INDEX_PLAYERDAMAGE, privateMatchStats.damageDealt )
	wp.SetWaypointInt( WP_INT_INDEX_SURVIVALTIME, privateMatchStats.survivalTime )
	wp.SetWaypointInt( WP_INT_INDEX_PLAYERASSISTS, privateMatchStats.assists )
	return wp
}

void function OnSquadEliminated( int teamIndex )
{
	file.teamFinalPlacementArray.insert( 0, teamIndex )
	SetGlobalNetInt( "lastSquadEliminated", teamIndex )

	foreach ( player in GetPlayerArrayIncludingSpectators() )
		if ( player.GetTeam() == TEAM_SPECTATOR )
			Remote_CallFunction_NonReplay( player, "ServerCallback_PrivateMatch_SquadEliminated", teamIndex, PrivateMatch_GetTeamFinalPlacement( teamIndex ) )
}
#endif //SERVER


bool function IsPrivateMatchLobby()
{
	#if UI
		//Defensive fix for R5DEV-131893
		if ( !IsConnected() )
			return false
	#endif

	if ( !IsPrivateMatch() )
	{
		if ( GetCurrentPlaylistName() != "private_match" ) // TODO: R5DEV-
			return false
	}

	string mapName

	#if UI
		mapName = GetActiveLevel()
	#else
		mapName = GetMapName()
	#endif

	return IsLobbyMapName( mapName )
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Private Match Non-Lobby Functions
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if SERVER
void function PrivateMatch_Match_Init()
{
	if ( IsPrivateMatchLobby() )
		return

	if ( !IsPrivateMatch() )
		return

	int maxTeams = PrivateMatch_GetMaxTeamsForSelectedGamemode()

	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < (TEAM_MULTITEAM_FIRST + maxTeams); teamIndex++ )
	{
		string currentTeamName       = GameRules_GetTeamName( teamIndex )
		PrivateMatchStatsStruct pmss = GetPrivateMatchStats( teamIndex )
		string savedTeamName         = pmss.teamName
		printf( "PrivateMatchDebug: Team %i name is %s, PMSS says it should be %s", teamIndex, currentTeamName, savedTeamName )

		if ( currentTeamName != savedTeamName )
		{
			printf( "PrivateMatchDebug: Team Name Mismatch! Renaming team %i to %s (was %s)", teamIndex, savedTeamName, currentTeamName )
			GameRules_SetTeamName( teamIndex, savedTeamName )
		}
	}

	//Used to update Game Status Menu
	AddCallback_OnClientConnectionRestored( PrivateMatch_OnClientConnectionRestored )
}

void function PrivateMatch_OnClientConnectionRestored( entity player )
{
	if ( player.GetTeam() != TEAM_SPECTATOR )
		return

	foreach ( teamIdx in file.teamFinalPlacementArray )
		Remote_CallFunction_NonReplay( player, "ServerCallback_PrivateMatch_SquadEliminated", teamIdx, PrivateMatch_GetTeamFinalPlacement( teamIdx ) )
}

void function ClientCallback_PrivateMatchToggleSurveyRing( entity observer )
{
	if( observer.GetTeam() != TEAM_SPECTATOR )
		return

	OBSERVER_ToggleSurveyRingEnabled( observer )
}

void function ClientCallback_PrivateMatchRefreshSurveyRing( entity observer )
{
	if( observer.GetTeam() != TEAM_SPECTATOR )
		return

	OBSERVER_RefreshSurveryRing( observer )
}

void function ClientCallback_PrivateMatchReportObserverTargetChanged( entity observer )
{
	entity newTarget = observer.GetObserverTarget()
	if ( !IsValid( newTarget ) )
		return

	if ( !newTarget.IsPlayer() )
		return

	if ( newTarget.IsBot() )
		return

	printf( "PrivateMatchObserver: Observer %s changed target to %s (%s)", observer.GetPINNucleusPid(), newTarget.GetPINNucleusPid(), newTarget.GetPlayerName() )
}
#endif //SERVER

#if UI
void function PrivateMatch_CreateMatchEndEarlyDialog()
{
	DialogData dialogData
	dialogData.header = Localize( "GAMEMODE_ENDED" )
	dialogData.message = Localize( "#TOURNAMENT_END_MATCH_EARLY" )
	dialogData.darkenBackground = true
	dialogData.noChoiceWithNavigateBack = true
	dialogData.noChoice = true
	dialogData.useFullMessageHeight = true
	OpenDialog( dialogData )
}
#endif

#if UI
void function PrivateMatch_SetSelectedPlaylist( string playlistName )
{
	// to avoid passing string across network, find the index for this playlist name
	// possible TODO: refactor system so the index is used through out, and name is only found when need to be displayed
	int playlistCount = GetPlaylistCount()
	int playlistIndex = -1
	for( playlistIndex = 0; playlistIndex < playlistCount; playlistIndex++ )
	{
		if( playlistName == GetPlaylistName( playlistIndex ) )
			break
	}

	if( playlistIndex < playlistCount )
	{
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchSetPlaylist", playlistIndex )
	}
}
#endif

#if CLIENT
#if DEVELOPER
void function DEV_ShowSpectatorButtonHints()
{
	OnSpectatorStarted()
	OnToggleButtonHintsVisibility( KEY_B )
}
#endif//DEV

void function OnSpectatorStarted()
{
	printt( "Spectator_OnSpectatorStarted" )

	entity localClientPlayer = GetLocalClientPlayer()

	// we create the hints only the first time
	if ( !file.buttonHintsCreated && localClientPlayer.GetTeam() == TEAM_SPECTATOR )
	{
		// creating the ruis
		file.buttonHints.push(CreateFullscreenPostFXRui( $"ui/observer_panel_hints.rpak", RUI_SORT_SCREENFADE + 1 ) )
		file.buttonHints.push(CreateFullscreenPostFXRui( $"ui/observer_controller_hints.rpak",  RUI_SORT_SCREENFADE + 1) )
		file.buttonHints.push(CreateFullscreenPostFXRui( $"ui/observer_keyboard_hints.rpak", RUI_SORT_SCREENFADE + 1 ) )
		file.buttonHints.push(CreateFullscreenPostFXRui( $"ui/observer_dpads_hints.rpak",  RUI_SORT_SCREENFADE + 1 ) )
		file.buttonHints.push(CreateFullscreenPostFXRui( $"ui/observer_camera_controls_hints.rpak", RUI_SORT_SCREENFADE + 1 ) )

#if NX_PROG || PC_PROG_NX_UI		
		RuiSetString( file.buttonHints[1], "yButtonLabel", "#OBSERVER_CONTROLLER_X_BUTTON" )
		RuiSetString( file.buttonHints[1], "yButtonDescLabel", "#OBSERVER_CONTROLLER_X_BUTTON_DESC" )
		RuiSetString( file.buttonHints[1], "xButtonLabel", "#OBSERVER_CONTROLLER_Y_BUTTON" )
		RuiSetString( file.buttonHints[1], "xButtonDescLabel", "#OBSERVER_CONTROLLER_Y_BUTTON_DESC_ALT" )
		RuiSetString( file.buttonHints[1], "bButtonLabel", "#OBSERVER_CONTROLLER_A_BUTTON" )
		RuiSetString( file.buttonHints[1], "bButtonDescLabel", "#OBSERVER_CONTROLLER_A_BUTTON_DESC" )
		RuiSetString( file.buttonHints[1], "aButtonLabel", "#OBSERVER_CONTROLLER_B_BUTTON" )
		RuiSetString( file.buttonHints[1], "aButtonDescLabel", "#OBSERVER_CONTROLLER_B_BUTTON_DESC" )
#else
		RuiSetString( file.buttonHints[1], "yButtonLabel", "#OBSERVER_CONTROLLER_Y_BUTTON" )
		RuiSetString( file.buttonHints[1], "yButtonDescLabel", "#OBSERVER_CONTROLLER_Y_BUTTON_DESC_ALT" )
		RuiSetString( file.buttonHints[1], "xButtonLabel", "#OBSERVER_CONTROLLER_X_BUTTON" )
		RuiSetString( file.buttonHints[1], "xButtonDescLabel", "#OBSERVER_CONTROLLER_X_BUTTON_DESC" )
		RuiSetString( file.buttonHints[1], "bButtonLabel", "#OBSERVER_CONTROLLER_B_BUTTON" )
		RuiSetString( file.buttonHints[1], "bButtonDescLabel", "#OBSERVER_CONTROLLER_B_BUTTON_DESC" )
		RuiSetString( file.buttonHints[1], "aButtonLabel", "#OBSERVER_CONTROLLER_A_BUTTON" )
		RuiSetString( file.buttonHints[1], "aButtonDescLabel", "#OBSERVER_CONTROLLER_A_BUTTON_DESC" )
#endif

		// just setting this so we use it to verify if the HUD has been created
		file.buttonHintsCreated = true

		// allow players to toggle button hints visibility by pressing B or Back
		RegisterButtonPressedCallback( KEY_B, OnToggleButtonHintsVisibility )
		RegisterConCommandTriggeredCallback( "toggle_observer_btn_hints", OnToggleButtonHintsVisibility )
	}
}

void function OnFPSSpectatorStarted( entity player, entity currentTarget )
{
	printt( "Spectator_OnFPSSpectatorStarted" )

	if (file.buttonHintsCreated)
	{
		for ( int i = 0; i < file.buttonHints.len(); i++ )
		{
			RuiSetBool( file.buttonHints[i], "isObserverMode", true )
			RuiSetBool( file.buttonHints[i], "isFPS", true )
		}
	}
	if(file.buttonHints.len() > 0)
	{
#if NX_PROG || PC_PROG_NX_UI	
		RuiSetString( file.buttonHints[1], "xButtonDescLabel", "#OBSERVER_CONTROLLER_Y_BUTTON_DESC_ALT" )
#else
		RuiSetString( file.buttonHints[1], "yButtonDescLabel", "#OBSERVER_CONTROLLER_Y_BUTTON_DESC_ALT" )
#endif
	}
}

void function OnTPSSpectatorStarted( entity player, entity currentTarget )
{
	printt( "Spectator_OnTPSSpectatorStarted" )

	if (file.buttonHintsCreated)
	{
		for ( int i = 0; i < file.buttonHints.len(); i++ )
		{
			RuiSetBool( file.buttonHints[i], "isObserverMode", true )
			RuiSetBool( file.buttonHints[i], "isFPS", false )
		}
	}
	
	if(file.buttonHints.len() > 0)
	{
#if NX_PROG || PC_PROG_NX_UI
		RuiSetString( file.buttonHints[1], "xButtonDescLabel", "#OBSERVER_CONTROLLER_Y_BUTTON_DESC" )
#else
		RuiSetString( file.buttonHints[1], "yButtonDescLabel", "#OBSERVER_CONTROLLER_Y_BUTTON_DESC" )
#endif
	}
}

void function OnFreecamSpectatorStarted( entity spectatingPlayer )
{
	printt( "Spectator_OnFreecamSpectatorStarted" )

	if (file.buttonHintsCreated)
	{
		for ( int i = 0; i < file.buttonHints.len(); i++ )
		{
			RuiSetBool( file.buttonHints[i], "isObserverMode", false )
		}
	}
}

void function OnToggleButtonHintsVisibility( var button )
{
	printt("Spectator_OnToggleButtonHintsVisibility", file.buttonHintsHidden)

	if (file.buttonHintsHidden)
	{
		for ( int i = 0; i < file.buttonHints.len(); i++ )
		{
			RuiSetBool( file.buttonHints[i], "isOpen", true )
			RuiSetBool( file.buttonHints[i], "animateIn", true )
		}
	}
	else
	{
		for ( int i = 0; i < file.buttonHints.len(); i++ )
		{
			RuiSetBool( file.buttonHints[i], "isOpen", false )
			RuiSetBool( file.buttonHints[i], "animateOut", true )
		}
	}
	file.buttonHintsHidden = !file.buttonHintsHidden
}

void function PrivateMatch_OnResolution()
{
	Signal( clGlobal.levelEnt, "GameModes_CompletedResolutionCleanup" )
}

//void function ServerCallback_PrivateMatch_ApplyHighlights()
//{
//	entity observer = GetLocalClientPlayer()
//	if ( observer.GetTeam() != TEAM_SPECTATOR )
//		return
//
//	observer.ClientCommand( "PrivateMatchToggleObserverHighlight" )
//	//RefreshObserverHighlights( observer, observer.GetObserverTarget() )
//}

void function ServerCallback_PrivateMatch_SquadEliminated( int teamIdx, int placement )
{
	PrivateMatch_SquadEliminated( teamIdx, placement )
}

void function OnSpectatorTargetChanged( entity observer, entity prevTarget, entity newTarget )
{
	if ( observer.GetTeam() != TEAM_SPECTATOR )
		return

	if ( IsValid( newTarget ) && newTarget.IsPlayer() && (newTarget != prevTarget) )
	{
		printf( "PrivateMatchObserver: Observer %s changed target to %s", observer.GetPINNucleusPid(), newTarget.GetPINNucleusPid() )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchReportObserverTargetChanged" )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchRefreshSurveyRing" )
		PrivateMatch_UpdateChatTarget()
	}
}

void function OnSpectatorModeChanged( entity observer )
{
	Remote_ServerCallFunction( "ClientCallback_PrivateMatchRefreshSurveyRing" )
}

entity function GetObserverPresetTarget()
{
	string presetPlayerHash = GetConVarString( OBSERVER_PRESET_PLAYERHASH_CONVAR_NAME )
	if( presetPlayerHash != "" )
	{
		foreach( entity player in GetPlayerArray() )
		{
			if( player.GetHashedEadpUserIdStr() == presetPlayerHash )
				return player
		}
	}

	int presetTeam = GetConVarInt( OBSERVER_PRESET_TEAM_CONVAR_NAME )
	if( presetTeam < 0 )
		return null

	array<entity> teamPlayers = GetPlayerArrayOfTeam(presetTeam + TEAM_MULTITEAM_FIRST - 1)

	if( teamPlayers.len() == 0 )
		return null

	teamPlayers.sort( PrivateMatch_SortPlayersByName )

	int playerSlot = abs((GetConVarInt( OBSERVER_PRESET_PLAYERSLOT_CONVAR_NAME ) - 1) % teamPlayers.len())

	return teamPlayers[playerSlot]

}

void function PrivateMatch_OnGameStateChanged( int newVal )
{
	if ( !IsPrivateMatch() )
		return

	if( newVal == eGameState.Playing )
	{
		entity observerTarget = GetObserverPresetTarget()
		if ( observerTarget != null && observerTarget.IsPlayer() )
			Remote_ServerCallFunction( "ClientCallback_PrivateMatchChangeObserverTarget", observerTarget )
	}
	else if ( newVal == eGameState.WinnerDetermined )
	{
		if( GameRules_GetTeamName( GetWinningTeam() ) != "Unassigned" )
		{
			SetChampionScreenRuiAsset( PM_CHAMPION_SCREEN )
			SetChampionScreenRuiAssetExtraFunc( ChampionScreenSetWinningTeamName )
		}
	}
	else if ( newVal == eGameState.Resolution )
	{
		DeathScreenCreateNonMenuBlackBars()
		// If the game was ended by the host, display a special message letting the players know the game was ended early
		if ( GameRules_GetTeamName( GetWinningTeam() ) == "Unassigned" )
		{
			// Need to wait for mode script to first cleanup any open UI
			thread function() : ( )
			{
				WaitSignal( clGlobal.levelEnt, "GameModes_CompletedResolutionCleanup" )

				if ( IsValid( GetLocalViewPlayer() ) )
					RunUIScript( "PrivateMatch_CreateMatchEndEarlyDialog")


				UpdateBlackBarRui()
			}()
		}

		// If the cached aim assist override (the value we want to revert to)
		// is different to what we already have, change it.
		bool aimAssistConfig = GetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME )
		if ( aimAssistConfig != file.cachedAimAssistOverride )
		{
			SetConVarBool( GLOBAL_AIM_ASSIST_CONVAR_NAME, file.cachedAimAssistOverride )
		}
	}
}

void function PrivateMatch_ClientOnSquadEliminated( entity player, int newVal )
{
	bool anonymousModeActive = GetConVarBool( CUSTOM_ANONYMOUS_MODE_CONVAR_NAME )
	if ( anonymousModeActive && GameRules_IsTeamIndexValid( newVal ) )
		Obituary_Print_Localized( Localize( "#SURVIVAL_OBITUARY_SQUADELIMINATED", PrivateMatch_GetTeamName( newVal ) ).toupper(), <255, 244, 79> )
}

void function ChampionScreenSetWinningTeamName( var rui )
{
	if ( !IsPrivateMatch() )
		return

	int winningTeamOrAlliance = GamemodeUtility_GetWinningTeamOrAlliance( true )
	if( winningTeamOrAlliance != TEAM_INVALID )
	{
		int winningTeamIndex = AllianceProximity_IsUsingAlliances() ? AllianceProximity_GetRepresentativeTeamForAlliance( winningTeamOrAlliance ) : winningTeamOrAlliance
		RuiSetString( rui, "winningTeamName", PrivateMatch_GetTeamName( winningTeamIndex ).toupper() )
	}
}
#endif //CLIENT

#if SERVER || CLIENT
int function PrivateMatch_GetMaxTeamsForSelectedGamemode()
{
	string playlist = GetCurrentPlaylistName()
	return GetMaxTeamsForPlaylistName( playlist )
}
#endif