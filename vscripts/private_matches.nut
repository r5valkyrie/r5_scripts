global function PrivateMatch_Init
global function IsPrivateMatchLobby
global function PrivateMatch_RegisterNetworking
global function PrivateMatch_GetSelectedPlaylistName

#if SERVER || CLIENT
global function PrivateMatch_CanAssignPlayers
global function PrivateMatch_CanAssignSelf
global function PrivateMatch_CanRenameTeam
global function PrivateMatch_GetMaxTeamsForSelectedGamemode

                 
global function PrivateMatch_IsObserverHighlightEnabled
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

global function ClientCallback_PrivateMatchToggleStartMatch
global function ClientCallback_PrivateMatchSetStartMatch
global function ClientCallback_PrivateMatchToggleReady
global function ClientCallback_PrivateMatchSetReady
global function ClientCallback_PrivateMatchSetPreloading
global function ClientCallback_PrivateMatchToggleAssignSelf
global function ClientCallback_PrivateMatchToggleTeamRenaming
global function ClientCallback_PrivateMatchToggleAdminOnlyChat
global function ClientCallback_PrivateMatchToggleObserverHighlights
// ClientCallback_RefreshObserverHighlights — moved to sh_highlight.gnut (S22)

#endif


#if CLIENT
global function PrivateMatch_ClientFrame
global function PrivateMatch_GetPlayerTeamStats
global function PrivateMatch_GetTeamName

global function ServerCallback_EnableGameStatusMenu
global function ServerCallback_PrivateMatch_ManageHighlights
global function ServerCallback_PrivateMatch_SquadEliminated
global function PrivateMatch_OpenGameStatusMenu
global function PrivateMatch_ToggleHighlights
global function PrivateMatch_SortPlayersByName
global function PrivateMatch_ToggleSurveyRing

global function PrivateMatch_BeginStartMatch

global function PrivateMatch_ClientOnSquadEliminated
#endif

#if UI
global function PrivateMatch_CreateMatchEndEarlyDialog
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

           
const string NV_OBSERVER_HIGHLIGHT_ENABLED = "PrivateMatch_Observer_HighlightEnabled"
const string NV_OBSERVER_SURVERY_RING_ENABLED = "PrivateMatch_Observer_SurveyRingEnabled"
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

		//Survival_AddCallback_OnSquadEliminated( OnSquadEliminated ) // native not available

		//AddCallback_OnPlayerMatchStateChanged( PrivateMatch_OnPlayerMatchStateChanged )
	#endif //SERVER

	#if CLIENT
		Waypoints_RegisterCustomType( WAYPOINTTYPE_PLAYERTEAMSTATS, InstancePlayerTeamStats )
		AddOnSpectatorTargetChangedCallback( OnSpectatorTargetChanged )
		AddFreeCamSpectateStartedCallback( OnSpectatorModeChanged )
		AddFreeCamSpectateEndedCallback( OnSpectatorModeChanged )
		RegisterConCommandTriggeredCallback( "toggle_obs_highlight", PrivateMatch_ToggleHighlights )
		RegisterConCommandTriggeredCallback( "toggle_obs_ring_survey", PrivateMatch_ToggleSurveyRing )
		AddCallback_GameStateEnter( eGameState.Playing, OnSpectatorStarted )
		AddFirstPersonSpectateStartedCallback( OnFPSSpectatorStarted )
		AddThirdPersonSpectateStartedCallback( OnTPSSpectatorStarted )
		AddFreeCamSpectateStartedCallback( OnFreecamSpectatorStarted )
	#endif
		
	#if CLIENT || SERVER
	
		              
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchKickPlayer", "entity" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetPlayerTeam", "entity", "int", TEAM_UNASSIGNED, TEAM_MULTITEAM_LAST )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleStartMatch" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetStartMatch", "bool" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleReady" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetReady", "bool" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetPreloading", "bool" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleAssignSelf" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleTeamRenaming" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleAdminOnlyChat" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleAimAssist" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleAnonymousMode" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetTeamName", "int", 0, INT_MAX, "string" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetPlaylist", "string" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchSetAdminConfig", "int", 0, INT_MAX, "bool" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchEndMatchEarly" )
	
		                 
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchChangeObserverTarget", "entity" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleObserverHighlights" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchToggleSurveyRing" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchRefreshSurveyRing" )
		Remote_RegisterServerFunction( "ClientCallback_PrivateMatchReportObserverTargetChanged" )
		Remote_RegisterServerFunction( "ClientCallback_RefreshObserverHighlights" )
	#endif

	int maxTeams
}

void function PrivateMatch_RegisterNetworking()
{
	RegisterNetworkedVariable( "canAssignPlayers", SNDC_GLOBAL, SNVT_BOOL, false )
	RegisterNetworkedVariable( "canAssignSelf", SNDC_GLOBAL, SNVT_BOOL, true )
	RegisterNetworkedVariable( "adminOnlyChat", SNDC_GLOBAL, SNVT_BOOL, true )
	RegisterNetworkedVariable( "canPlayersRenameTeams", SNDC_GLOBAL, SNVT_BOOL, false )
	RegisterNetworkedVariable( "readiness", SNDC_PLAYER_GLOBAL, SNVT_BIG_INT, 0 )
	RegisterNetworkedVariable( "selectedPlaylistIndex", SNDC_GLOBAL, SNVT_INT, -1 )
	RegisterNetworkedVariable( "startCountdown", SNDC_GLOBAL, SNVT_INT, -1 )
	RegisterNetworkedVariable( "lastSquadEliminated", SNDC_GLOBAL, SNVT_INT, -1 )

	Remote_RegisterClientFunction( "ServerCallback_EnableGameStatusMenu", "bool" )
	Remote_RegisterClientFunction( "ServerCallback_PrivateMatch_ManageHighlights" )
	Remote_RegisterClientFunction( "ServerCallback_PrivateMatch_SquadEliminated", "int", TEAM_INVALID, 60, "int", 0, 60 )
	RegisterNetworkedVariable( NV_OBSERVER_HIGHLIGHT_ENABLED, SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )


	#if CLIENT || SERVER
		RegisterNetworkedVariable( NV_OBSERVER_SURVERY_RING_ENABLED, SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )
	#endif

	#if SERVER
		// Additional netvars not needed
	#endif

	#if CLIENT
		// NonRewind callbacks — SDK event-driven system
		RegisterNetworkedVariableChangeCallback_intSafe( "selectedPlaylistIndex", void function( entity ent, int oldVal, int newVal, bool changed ) { OnSelectedPlaylistIndexChanged( ent, newVal ) } )
		RegisterNetworkedVariableChangeCallback_intSafe( "startCountdown", void function( entity ent, int oldVal, int newVal, bool changed ) { OnStartCountdownChanged( ent, newVal ) } )
		RegisterNetworkedVariableChangeCallback_boolSafe( NV_OBSERVER_HIGHLIGHT_ENABLED, void function( entity ent, bool oldVal, bool newVal, bool changed ) { ObserverHighlightEnableChanged( ent, newVal ) } )

		AddCallback_OnGameStateChanged( PrivateMatch_OnGameStateChanged )
		RegisterNetworkedVariableChangeCallback_intSafe( "lastSquadEliminated", void function( entity ent, int oldVal, int newVal, bool changed ) { PrivateMatch_ClientOnSquadEliminated( ent, newVal ) } )
	#endif
}

#if CLIENT

string function PrivateMatch_GetTeamName( int teamIndex )
{
	Assert( teamIndex >= TEAM_MULTITEAM_FIRST )
	string teamName = GameRules_GetTeamName( teamIndex )
	string defaultTeamName = ( AllianceProximity_IsUsingAlliances() )?Localize( "#TEAM_NUMBERED", AllianceProximity_GetAllianceFromTeam( teamIndex ) + 1 ) :Localize( "#TEAM_NUMBERED", teamIndex - 1 )

	return teamName != "" ? teamName : defaultTeamName
}

void function PrivateMatch_BeginStartMatch()
{
	if( !true /* HasMatchAdminRole() S3 stub */ || PrivateMatch_IsCountdownRunning() )
		return

	                                                                                    
	                                                                  
	  	                                                                             
	int maxTeams = PrivateMatch_GetMaxTeamsForSelectedGamemode()
	for ( int i = TEAM_MULTITEAM_FIRST; i < TEAM_MULTITEAM_FIRST + maxTeams; ++i )
	{
		if( PrivateMatch_GetTeamName( i ) != GameRules_GetTeamName( i ) )
		{
			Remote_ServerCallFunction( "ClientCallback_PrivateMatchSetTeamName", i, PrivateMatch_GetTeamName( i ) )
		}
	}

	if( !PrivateMatch_IsCountdownRunning() )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchToggleStartMatch" )
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

void function PrivateMatch_ToggleHighlights( entity player )
{
	if ( player.GetTeam() == TEAM_SPECTATOR )
	{
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchToggleObserverHighlights" )
	}
}

void function PrivateMatch_ToggleSurveyRing( entity player )
{
	if( player.GetTeam() == TEAM_SPECTATOR )
	{
		printt( "OBS_SURVEY: toggling Ring Survey for observer "+player )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchToggleSurveyRing" )
	}
}

#endif         

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

	// #if SERVER
	// 	int lastTeamIdx = (TEAM_MULTITEAM_FIRST + file.playlistMaxTeams) <= ABSOLUTE_MAX_TEAMS ? (TEAM_MULTITEAM_FIRST + file.playlistMaxTeams) : ABSOLUTE_MAX_TEAMS
	// 	for ( int i = TEAM_MULTITEAM_FIRST; i < lastTeamIdx; i++ )
	// 		GameRules_SetTeamName( i, "" ) // native not available
	// #endif

	                                                                                                                                      
}


#if SERVER
void function PrivateMatch_OnPlayerConnecting( entity player )
{
	Assert( IsPrivateMatchLobby() )

	if ( true /* player.HasMatchAdminRole() S3 stub */ )
		SetTeam( player, TEAM_SPECTATOR )
	else
		SetTeam( player, TEAM_UNASSIGNED )
}



void function PrivateMatch_OnPlayerConnected( entity player )
{
	Assert( IsPrivateMatchLobby() )

	if ( true /* player.HasMatchAdminRole() S3 stub */ )
		SetTeam( player, TEAM_SPECTATOR )
	else
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

void function ClientCallback_PrivateMatchSetPlaylist( entity player, string playlistName )
{
	if ( !IsPrivateMatchLobby() )
		return

	if ( !true /* player.HasMatchAdminRole() S3 stub */ )
		return

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

		int desiredTeamIndex = teamPlayer.GetTeam()
		SetTeam( teamPlayer, TEAM_UNASSIGNED )
		SetTeam( teamPlayer, desiredTeamIndex )
	}

	printt( "SetPrivateMatchStats - MaxTeams = "+ ( file.playlistMaxTeams + TEAM_MULTITEAM_FIRST ) + "\nCallstack:\n" + GetStack() )
	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < file.playlistMaxTeams + TEAM_MULTITEAM_FIRST; teamIndex++ )
	{
		PrivateMatchStatsStruct privateMatchStats
		privateMatchStats.teamName = GameRules_GetTeamName( teamIndex )
		printf( "PrivateMatchLobbyDebug: Setting team name for team %i to %s", teamIndex, privateMatchStats.teamName )
		SetPrivateMatchStats( teamIndex, privateMatchStats )
	}

	LaunchPrivateMatchPlaylist( file.selectedPlaylist )

	bool aimAssistConfig = GetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME )
	bool globalAimAssistConfig = GetConVarBool( GLOBAL_AIM_ASSIST_CONVAR_NAME )
	if ( aimAssistConfig != globalAimAssistConfig )
	{
		SetConVarBool( GLOBAL_AIM_ASSIST_CONVAR_NAME, aimAssistConfig )
	}
	file.cachedAimAssistOverride = globalAimAssistConfig
}

void function ClientCallback_PrivateMatchToggleStartMatch( entity player )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	if ( PrivateMatch_IsCountdownRunning() )
		SetGlobalNetInt( "startCountdown", -1 )
	else
		thread StartMatch()
}

void function ClientCallback_PrivateMatchSetStartMatch( entity player, bool doStart )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	if ( doStart )
		thread StartMatch()
	else
		SetGlobalNetInt( "startCountdown", -1 )
}

void function ClientCallback_PrivateMatchToggleReady( entity player )
{
	if ( !IsPrivateMatchLobby() )
		return

	int readiness = player.GetPlayerNetInt( "readiness" )
	bool isReady = (readiness & PRIVATEMATCH_ISREADY_BIT) != 0
	if ( isReady )
		player.SetPlayerNetInt( "readiness", readiness & ~PRIVATEMATCH_ISREADY_BIT )
	else
		player.SetPlayerNetInt( "readiness", readiness | PRIVATEMATCH_ISREADY_BIT )
}

void function ClientCallback_PrivateMatchSetReady( entity player, bool ready )
{
	if ( !IsPrivateMatchLobby() )
		return

	int readiness = player.GetPlayerNetInt( "readiness" )
	if ( ready )
		player.SetPlayerNetInt( "readiness", readiness | PRIVATEMATCH_ISREADY_BIT )
	else
		player.SetPlayerNetInt( "readiness", readiness & ~PRIVATEMATCH_ISREADY_BIT )
}

void function ClientCallback_PrivateMatchSetPreloading( entity player, bool preloading )
{
	if ( !IsPrivateMatchLobby() )
		return

	int readiness = player.GetPlayerNetInt( "readiness" )
	if ( preloading )
		player.SetPlayerNetInt( "readiness", readiness | PRIVATEMATCH_ISPRELOADING_BIT )
	else
		player.SetPlayerNetInt( "readiness", readiness & ~PRIVATEMATCH_ISPRELOADING_BIT )
}

void function ClientCallback_PrivateMatchToggleAssignSelf( entity player )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	SetGlobalNetBool( "canAssignSelf", !GetGlobalNetBool( "canAssignSelf" ) )
}

void function ClientCallback_PrivateMatchToggleTeamRenaming( entity player )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	SetGlobalNetBool( "canPlayersRenameTeams", !GetGlobalNetBool( "canPlayersRenameTeams" ) )
}

void function ClientCallback_PrivateMatchToggleAdminOnlyChat( entity player )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	SetGlobalNetBool( "adminOnlyChat", !GetGlobalNetBool( "adminOnlyChat" ) )
}

void function ClientCallback_PrivateMatchToggleAimAssist( entity player )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	bool newAimAssistSetting = !GetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME )
	SetConVarBool( CUSTOM_AIM_ASSIST_CONVAR_NAME, newAimAssistSetting )
}

void function ClientCallback_PrivateMatchToggleAnonymousMode( entity player )
{
	if ( !IsPrivateMatchLobby() || !true /* player.HasMatchAdminRole() S3 stub */ )
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

	printf( "Observer: User %s switched to spectating %s", player.GetPlayerName(), target.GetPlayerName() )
	player.SetObserverTarget( target )
}

void function ClientCallback_PrivateMatchSetAdminConfig( entity player, int chatMode, bool spectatorChat )
{
	if ( !true /* player.HasMatchAdminRole() S3 stub */ )
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

	if ( !true /* player.HasMatchAdminRole() S3 stub */ )
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
	if ( !true /* player.HasMatchAdminRole() S3 stub */ )
		return

	if ( !IsValid( kickPlayer ) )
		return

	PrivateMatchKickPlayer( kickPlayer )
}


void function PrivateMatch_OnWinnerDetermined()
{
	if ( !IsPrivateMatch() )
		return

	if ( IsRoundBased() )
	{
		if( !GetGlobalNetBool("roundScoreLimitComplete") )
		{
			return
		}
	}

	if ( GetGameState() < eGameState.Resolution )
	{
		PrivateMatch_ClearStats()
		thread PrivateMatch_StoreStats()
	}

	string endReason = GameRules_GetTeamName( GetWinningTeam() ) == "Unassigned" ? "Private Match Ended Early" : "Private Match Ended"
	foreach ( entity player in GetPlayerArray() )
	{
		if ( player.GetTeam() == TEAM_SPECTATOR )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_EnableGameStatusMenu", false )
		}

		PIN_PlayerLeft( player, endReason )
	}
}


void function PrivateMatch_OnPickLoadout()
{
	int maxTeams = PrivateMatch_GetMaxTeamsForSelectedGamemode()
	bool hasSpawnPointSelection = ForcedSpawn_UseForcedSpawning()

	for ( int teamIndex = TEAM_MULTITEAM_FIRST; teamIndex < (TEAM_MULTITEAM_FIRST + maxTeams); teamIndex++ )
	{
		string currentTeamName = GameRules_GetTeamName(teamIndex)
		if ( hasSpawnPointSelection && currentTeamName.len() > 1)
		{
			array<string> parts = GetTrimmedSplitString( currentTeamName, "@" )

			int selectedIndex = 0
			if ( parts.len() > 1 && parts[1].len() > 0 )
			{
				selectedIndex = parts[1].tointeger() - 1

				printt("Team", currentTeamName, "request Spawn #", selectedIndex)
				ForcedSpawn_TrySetTeamSpawnFromLocationIndex( teamIndex, selectedIndex )
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
			Remote_CallFunction_Replay( player, "ServerCallback_PrivateMatch_ManageHighlights" )
			Highlight_RefreshObserverHighlights( player )

			Remote_CallFunction_Replay( player, "ServerCallback_EnableGameStatusMenu", true )
		}
	}
}


void function PrivateMatch_ClearStats()
{
	printf( "PrivateMatch_ClearStats()" )
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
	WaitFrame()

	int winningTeamIndex = GetWinningTeam()
	file.teamFinalPlacementArray.insert( 0, winningTeamIndex )

	// Stub: GameSummary_GetTeamDataOrNull always returns null, so this loop is disabled.
	int playerIndex = 0

	if ( !IsPrivateMatch() )
	{
		Warning( "%s() - skipping rest of function because this is not a private match.", FUNC_NAME() )
		return
	}
	FinalizePrivateMatchStats()
}


void function PrivateMatch_InitPostGameStats()
{
	for ( int playerIndex = 0; playerIndex < ABSOLUTE_MAX_TEAMS; playerIndex++ )
	{
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

void function ClientCallback_PrivateMatchToggleObserverHighlights( entity player )
{
	if ( player.GetTeam() != TEAM_SPECTATOR )
		return

	bool current = player.GetPlayerNetBool( NV_OBSERVER_HIGHLIGHT_ENABLED )
	player.SetPlayerNetBool( NV_OBSERVER_HIGHLIGHT_ENABLED, !current )
}

// ClientCallback_RefreshObserverHighlights — moved to sh_highlight.gnut (S22)

#endif //SERVER



string function PrivateMatch_GetSelectedPlaylistName()
{
	int playlistIndex = GetGlobalNetInt( "selectedPlaylistIndex" )
	if ( playlistIndex > 0 )
	{
		string ornull playlistName = GetPlaylistName( playlistIndex )
		return playlistName != null ? expect string( playlistName ) : ""
	}

	return ""
}


bool function IsPrivateMatchLobby()
{
	#if UI
		                                
		if ( !IsConnected() )
			return false
	#endif

	if ( !IsPrivateMatch() )
	{
		if ( GetCurrentPlaylistName() != "private_match" )                
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

#if SERVER || CLIENT
bool function PrivateMatch_IsCountdownRunning()
{
	return GetGlobalNetInt( "startCountdown" ) >= 0
}

bool function PrivateMatch_CanAssignPlayers( entity player )
{
	if( PrivateMatch_IsCountdownRunning() )
		return false

	if ( true /* player.HasMatchAdminRole() S3 stub */ )
		return true

	return GetGlobalNetBool( "canAssignPlayers" )
}

bool function PrivateMatch_CanAssignSelf( entity player )
{
	if( PrivateMatch_IsCountdownRunning() )
		return false

	if ( true /* player.HasMatchAdminRole() S3 stub */ )
		return true

	return GetGlobalNetBool( "canAssignSelf" )
}

bool function PrivateMatch_CanRenameTeam( entity player, int teamIndex )
{
	if ( true /* player.HasMatchAdminRole() S3 stub */ )
		return true

	if ( player.GetTeam() != teamIndex )
		return false

	return GetGlobalNetBool( "canPlayersRenameTeams" )
}
#endif

#if CLIENT
void function OnSelectedPlaylistIndexChanged( entity player, int newIndex )
{
	if ( !IsPrivateMatchLobby() )
		return

	                                                                                     
	RunUIScript( "PrivateMatch_PlaylistNameChanged" )
}

void function OnStartCountdownChanged( entity player, int newVal )
{
	if ( !IsPrivateMatchLobby() )
		return
		
	RunUIScript( "PrivateMatch_RefreshStartCountdown", newVal )
}
#endif         

                                                                                                              
  
                                    
  
                                                                                                              

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

	if ( newTarget.IsNPC() )
		return

	printf( "PrivateMatchObserver: Observer %s changed target to %s (%s)", observer.GetPlayerName(), newTarget.GetPlayerName(), newTarget.GetPlayerName() )
}
#endif //SERVER


#if SERVER || CLIENT
bool function PrivateMatch_IsObserverHighlightEnabled( entity observer )
{
	if ( !IsValid( observer ) )
		return false

	if ( !observer.IsPlayer() )
		return false

	if ( observer.GetTeam() != TEAM_SPECTATOR )
		return false

	return observer.GetPlayerNetBool( NV_OBSERVER_HIGHLIGHT_ENABLED )
}
#endif

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

#if CLIENT
void function ObserverHighlightEnableChanged( entity observer, bool newValue )
{
	if ( observer.GetTeam() != TEAM_SPECTATOR )
		return

	if ( observer == GetLocalClientPlayer() )
	{
		if ( newValue == true )
			Obituary_Print_Localized( Localize( "#TOURNAMENT_OBSERVER_HIGHLIGHT_ENABLED" ) )
		else if ( newValue == false )
			Obituary_Print_Localized( Localize( "#TOURNAMENT_OBSERVER_HIGHLIGHT_DISABLED" ) )
	}

	array<entity> players = GetPlayerArray_Alive()
	foreach ( player in players )
	{
		ManageHighlightEntity( player )
	}
}

void function OnSpectatorStarted()
{
	printt( "Spectator_OnSpectatorStarted" )

	entity localClientPlayer = GetLocalClientPlayer()

	                                          
	if ( !file.buttonHintsCreated && localClientPlayer.GetTeam() == TEAM_SPECTATOR )
	{
		                    
		file.buttonHints.push(CreatePermanentCockpitPostFXRui( $"ui/observer_panel_hints.rpak", MINIMAP_Z_FRAME ) )
		file.buttonHints.push(CreatePermanentCockpitPostFXRui( $"ui/observer_controller_hints.rpak",  MINIMAP_Z_FRAME) )
		file.buttonHints.push(CreatePermanentCockpitPostFXRui( $"ui/observer_keyboard_hints.rpak", MINIMAP_Z_FRAME ) )
		file.buttonHints.push(CreatePermanentCockpitPostFXRui( $"ui/observer_dpads_hints.rpak",  MINIMAP_Z_FRAME ) )
		file.buttonHints.push(CreatePermanentCockpitPostFXRui( $"ui/observer_camera_controls_hints.rpak", MINIMAP_Z_FRAME ) )

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

		                                                                       
		file.buttonHintsCreated = true

		                                                                        
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

                                                             
   
  	                                        
  	                                           
  		      
  
  	                                                               
  	                                                                     
   

void function ServerCallback_PrivateMatch_ManageHighlights()
{
	printf( "ObserverHighlightDebug: Managing observer highlights for observer %s", GetLocalClientPlayer().GetPlayerName() )

	array<entity> players = GetPlayerArray_Alive()
	foreach ( player in players )
	{
		ManageHighlightEntity( player )
	}
}

void function ServerCallback_PrivateMatch_SquadEliminated( int teamIdx, int placement )
{
	PrivateMatch_SquadEliminated( teamIdx, placement )
}

void function OnSpectatorTargetChanged( entity observer, entity prevTarget, entity newTarget )
{
	if ( observer.GetTeam() != TEAM_SPECTATOR )
		return

	bool showTeamName = true
                       
	if (IsGunGameActive())
		showTeamName = false
      
                      
	if (WinterExpress_IsModeEnabled())
		showTeamName = false
      

	if ( IsValid( newTarget ) && ( newTarget.IsPlayer() || newTarget.IsNPC() ) && (newTarget != prevTarget) && showTeamName)
	{
		printf( "PrivateMatchObserver: Observer %s changed target to %s", observer.GetPlayerName(), newTarget.GetPlayerName() )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchReportObserverTargetChanged" )
		Remote_ServerCallFunction( "ClientCallback_PrivateMatchRefreshSurveyRing" )
		PrivateMatch_UpdateChatTarget()
		ShowTeamNameInHud()
	}
	else
	{
		HideTeamNameInHud()
	}

	Remote_ServerCallFunction( "ClientCallback_RefreshObserverHighlights" )

	                                                  
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
			if( player.GetPlayerName() /* GetHashedEadpUserIdStr S3 stub */ == presetPlayerHash )
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
		if( observerTarget != null )
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
		                                                                                                                 
		if ( GameRules_GetTeamName( GetWinningTeam() ) == "Unassigned" )
		{
			                                                            
			thread function() : ( )
			{
				WaitSignal( clGlobal.levelEnt, "GameModes_CompletedResolutionCleanup" )

				if ( IsValid( GetLocalViewPlayer() ) )
					RunUIScript( "PrivateMatch_CreateMatchEndEarlyDialog")


				UpdateBlackBarRui()
			}()
		}

		                                                                     
		                                                   
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

	RuiSetString( rui, "winningTeamName", PrivateMatch_GetTeamName( GetWinningTeam() ).toupper() )
}
#endif         

#if SERVER || CLIENT
int function PrivateMatch_GetMaxTeamsForSelectedGamemode()
{
	string playlist = GetCurrentPlaylistName()
	return GetMaxTeamsForPlaylistName( playlist )
}
#endif