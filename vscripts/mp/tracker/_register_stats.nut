//untyped																			
globalize_all_functions
#if TRACKER && HAS_TRACKER_DLL																	//~mkos

const bool STORE_STAT = true 

struct {

	bool RegisterCoreStats 	= true
	bool bStatsIs1v1Type 	= false

} file

void function SetRegisterCoreStats( bool b )
{
	file.RegisterCoreStats = b
}

void function Tracker_Init()
{
	file.bStatsIs1v1Type = g_is1v1GameType()
	
	bool bRegisterCoreStats = !GetCurrentPlaylistVarBool( "disable_core_stats", false )
	SetRegisterCoreStats( bRegisterCoreStats )
	
	Stats__InternalInit()
}

//////////////////////////////////////////////////
// These stats are global stats registered in 	//
//	api backend. 								//
//											  	//
// For server-instance settings, register a   	//
// setting with AddCallback_PlayerData()		//
//												//
// Those settings will be unique to each server //
// for each player.								//
//					Player-persistence settings //	
//					can be fetched with 		//
//					Tracker_FetchPlayerData()	//
//					and saved with				//
//					Tracker_SavePlayerData()	//
//										   ~mkos//
//////////////////////////////////////////////////
void function Script_RegisterAllStats()
{
	// It is not necessary to add stats for core stats to a gamemode (kills,deaths,etc), as r5r.dev is capable
	// of sorting by various factors(todo). However, it is usful if you want to do it for display purposes.
	// Generally, stats are registered here to add new stats specific to that gamemode.

	// void function Tracker_RegisterStat( string statname, void functionref( entity ) ornull inboundCallbackFunc = null, var functionref( string ) ornull outboundCallbackFunc = null, bool bLocalAllowed = false )
	// EXAMPLE: Tracker_RegisterStat( "backend_stat_name", data_in_callback, data_out_callback, USE_LOCAL )
	
	// null can be used as substitutes if specific in/out is not needed.
	// Stats don't need an in function to be fetched from server cache with the getter functions:
	// GetPlayerStat%TYPE%( playerUID, "statname" )  %TYPE% = [Int,Bool,Float,String]

	// They can also, all be fetched at once, when stats for a player loads.
	// see: AddCallback_PlayerDataFullyLoaded below.

	// Each stat will only load in if they get registered here. 
	// After stats load in for a player,
	// your AddCallback_PlayerDataFullyLoaded callbackFunc will get called
	// 
	//
	// Additionally, an api constant REGISTER_ALL will trigger the return of the entire 
	// script-registered live-table stats.
	//
	// There are limits in place:   - int must not exceed 32bit int limit 
	//								- string must not exceed 30char
	//								- bool 0/1 true/false 
	//								- float must not exceed 32bit 
	//								- all numericals are signed. 
	//								
	//								There also exists api rate-limiting. 
	//
	//	Stats registerd under 'recent_match_data' group in the backend do NOT aggregate.
	//	These stats should be prefixed with 'previous_' for clarity.
	
	
	// IF USING: STORE_STAT
	// {
			// Purpose:
			
			// if using any stat value that will be garbage cleaned on disconnect etc
			// ( player net int, player struct var, structs cleared on round end, etc )
			
			// WARNING:	Do not set the same var in an inbound stat func, that the outbound stat func returns. 
			// This will result in player stat data aggregation inflation on next disconnect. 		
			
			// If RegisterStat is passed with fourth parameter of true, 
			// a local copy is maintained of accumulated stats for the round, regardless of disconnects/rejoins.  
			// This means you can use getters based on player entity 
			
			
			// For base stats, the gamemode will have a record associated automatically by uid 
			// Tracker_ReturnKills
			// Tracker_ReturnDeaths
			// Tracker_ReturnDamage    etc... 
	//	}
	
	//Script required stats
	Tracker_RegisterStat( "settings" )
	Tracker_RegisterStat( "isDev" )
	
	//Global mute ( helper controlled set via web panel/mod api only )
	if( Chat_GlobalMuteEnabled() )
		Tracker_RegisterStat( "globally_muted", Chat_CheckGlobalMute )

	//Core stats - can disable for gamemode purposes.
	if( file.RegisterCoreStats )
	{
		Tracker_RegisterStat( "kills", null, Tracker_ReturnKills )
		Tracker_RegisterStat( "deaths", null, Tracker_ReturnDeaths )
		Tracker_RegisterStat( "superglides", null, Tracker_ReturnSuperglides )
		Tracker_RegisterStat( "total_time_played" )
		Tracker_RegisterStat( "total_matches" )
		Tracker_RegisterStat( "score" )
		Tracker_RegisterStat( "previous_champion", null, Tracker_ReturnChampion )
		Tracker_RegisterStat( "previous_kills", null, Tracker_ReturnKills )
		Tracker_RegisterStat( "previous_damage", null, Tracker_ReturnDamage )
		//Tracker_RegisterStat( "previous_survival_time", null,  )
		
		AddCallback_PlayerDataFullyLoaded( Callback_CoreStatInit )
	}
	
	//Reporting
	if( Flowstate_EnableReporting() )
	{	
		Tracker_RegisterStat( "cringe_reports", null, TrackerStats_CringeReports, STORE_STAT )
		Tracker_RegisterStat( "was_reported_cringe", null, TrackerStats_WasReportedCringe, STORE_STAT  )
	}
		
	//Conditional by playlist stats
	switch( Playlist() )
	{
		case ePlaylists.fs_scenarios:
			Tracker_RegisterStat( "scenarios_kills", null, TrackerStats_ScenariosKills )
			Tracker_RegisterStat( "scenarios_deaths", null, TrackerStats_ScenariosDeaths )
			Tracker_RegisterStat( "scenarios_score", null, TrackerStats_ScenariosScore )
			Tracker_RegisterStat( "scenarios_downs", null, TrackerStats_ScenariosDowns )
			Tracker_RegisterStat( "scenarios_team_wipe", null, TrackerStats_ScenariosTeamWipe )
			Tracker_RegisterStat( "scenarios_team_wins", null, TrackerStats_ScenariosTeamWins )
			Tracker_RegisterStat( "scenarios_solo_wins", null, TrackerStats_ScenariosSoloWins )
			Tracker_RegisterStat( "previous_score", null, TrackerStats_ScenariosRecentScore )
			AddCallback_PlayerDataFullyLoaded( Callback_HandleScenariosStats )
		break 

		case ePlaylists.fs_dm_fast_instagib:
			//Tracker_RegisterStat( "shots_hit", null, Tracker_ReturnHits )
			Tracker_RegisterStat( "shots_fired", null, Tracker_ReturnShots )
			Tracker_RegisterStat( "instagib_deaths", null, Tracker_ReturnDeaths )
			Tracker_RegisterStat( "instagib_railjumptimes", null, TrackerStats_FSDMRailjumps, STORE_STAT )
			Tracker_RegisterStat( "instagib_gamesplayed", null, TrackerStats_FSDMGamesPlayed )
			Tracker_RegisterStat( "instagib_wins", null, TrackerStats_FSDMWins )	
		break

		case ePlaylists.fs_haloMod:
			Tracker_RegisterStat( "halo_dm_kills", null, Tracker_ReturnKills )
			Tracker_RegisterStat( "halo_dm_deaths", null, Tracker_ReturnDeaths )
			Tracker_RegisterStat( "halo_dm_gamesplayed", null, TrackerStats_FSDMGamesPlayed )
			Tracker_RegisterStat( "halo_dm_wins", null, TrackerStats_FSDMWins )
		break
		
		case ePlaylists.fs_haloMod_oddball:
			Tracker_RegisterStat( "halo_oddball_kills", null, Tracker_ReturnKills )
			Tracker_RegisterStat( "halo_oddball_deaths", null, Tracker_ReturnDeaths )
			Tracker_RegisterStat( "halo_oddball_heldtime", null, TrackerStats_OddballHeldTime, STORE_STAT )
			Tracker_RegisterStat( "halo_oddball_gamesplayed", null, TrackerStats_FSDMGamesPlayed )
		break

		case ePlaylists.fs_haloMod_ctf:

			Tracker_RegisterStat( "halo_ctf_flags_captured", null, TrackerStats_CtfFlagsCaptured, STORE_STAT )
			Tracker_RegisterStat( "halo_ctf_flags_returned", null, TrackerStats_CtfFlagsReturned, STORE_STAT )
			Tracker_RegisterStat( "halo_ctf_gamesplayed", null, TrackerStats_FSDMGamesPlayed )
			Tracker_RegisterStat( "halo_ctf_wins", null, TrackerStats_CtfWins, STORE_STAT )
		break 
		
		case ePlaylists.fs_realistic_ttv:
			Tracker_RegisterStat( "realistic_kills", null, Tracker_ReturnKills )
			Tracker_RegisterStat( "realistic_deaths", null, Tracker_ReturnDeaths )
			Tracker_RegisterStat( "realistic_portals", null, TrackerStats_GetPortalPlacements, STORE_STAT )
			Tracker_RegisterStat( "realistic_kidnaps", null, TrackerStats_GetPortalKidnaps, STORE_STAT )
		break
		
		//case :
	}
}

////////////////////
// STAT FUNCTIONS //
////////////////////

void function Callback_CoreStatInit( entity player )
{
	// setting frequently computed stats in player struct is cheaper than using 
	// type matching/casting stat fetchers getting vars from untyped table.
	// net ints also used in match making / stat display features.
	
	string uid = player.p.UID
	
	int player_season_kills = GetPlayerStatInt( uid, "kills" )
	player.p.season_kills = player_season_kills
	player.SetPlayerNetInt( "SeasonKills", player_season_kills )

	int player_season_deaths = GetPlayerStatInt( uid, "deaths" )
	player.p.season_deaths = player_season_deaths
	player.SetPlayerNetInt( "SeasonDeaths", player_season_deaths )

	player.p.season_glides = GetPlayerStatInt( uid, "superglides" )

	int player_season_playtime = GetPlayerStatInt( uid, "total_time_played" )	
	player.p.season_playtime = player_season_playtime
	player.SetPlayerNetInt( "SeasonPlaytime", player_season_playtime )

	int player_season_gamesplayed = GetPlayerStatInt( uid, "total_matches" )	
	player.p.season_gamesplayed = player_season_gamesplayed
	player.SetPlayerNetInt( "SeasonGamesplayed", player_season_gamesplayed )

	int player_season_score = GetPlayerStatInt( uid, "score" )
	player.p.season_score = player_season_score
	player.SetPlayerNetInt( "SeasonScore", player_season_score )
}

void function Callback_HandleScenariosStats( entity player )
{
	string uid = player.p.UID
		
	const string strSlice = "scenarios_"
	foreach( string statKey, var statValue in Stats__GetPlayerStatsTable( uid ) ) //Todo: register by script name group ( set in backend )
	{
		#if DEVELOPER
			printw( "found statKey =", statKey, "statValue =", statValue )
		#endif 
		
		if( statKey.find( strSlice ) != -1 )
			ScenariosPersistence_SetUpOnlineData( player, statKey, statValue )
	}
}

var function TrackerStats_FSDMShots( string uid )
{
	entity player = GetPlayerEntityByUID( uid )	
	return player.p.shotsfired
}

var function TrackerStats_FSDMRailjumps( string uid )
{
	entity player = GetPlayerEntityByUID( uid )
	return player.p.railjumptimes 
}

var function TrackerStats_FSDMGamesPlayed( string uid ) //for leaderboard visuals?
{
	return 1
}

var function TrackerStats_FSDMWins( string uid )
{	
	entity player = GetPlayerEntityByUID( uid )
	if( !IsValid( player ) )
		return 0
		
	return player == GetBestPlayer() ? 1 : 0
}

var function TrackerStats_OddballHeldTime( string uid )
{
	entity player = GetPlayerEntityByUID( uid )
	return player.GetPlayerNetInt( "oddball_ballHeldTime" )
}

var function TrackerStats_CtfFlagsCaptured( string uid )
{
	entity player = GetPlayerEntityByUID( uid )
	return player.GetPlayerNetInt( "captures" )
}

var function TrackerStats_CtfFlagsReturned( string uid )
{
	entity player = GetPlayerEntityByUID( uid )
	return player.GetPlayerNetInt( "returns" )
}

var function TrackerStats_CtfWins( string uid )
{
	entity ent = GetPlayerEntityByUID( uid )
	return ent.p.wonctf ? 1 : 0
}

var function TrackerStats_GetPortalPlacements( string uid )
{
	entity ent = GetPlayerEntityByUID( uid )
	return ent.p.portalPlacements
}

var function TrackerStats_GetPortalKidnaps( string uid )
{
	entity ent = GetPlayerEntityByUID( uid )
	return ent.p.portalKidnaps
}


var function TrackerStats_CringeReports( string uid )
{
	entity ent = GetPlayerEntityByUID( uid )		
	return ent.p.submitCringeCount
}

var function TrackerStats_WasReportedCringe( string uid )
{
	entity ent = GetPlayerEntityByUID( uid )
	return ent.p.cringedCount
}


//////////////////////////////////////////////////////////
//														//
//	Any player settings that do not get registered 		//
//	will not be loaded in. To load all settings 		//
//	you can use RegisterAllSettings()					//
//	however, you do not need to register settings		//
//	manually, they will be registered when you add		//
//	a callback via AddCallback_PlayerData()				//
//														//
//////////////////////////////////////////////////////////

void function Script_RegisterAllPlayerDataCallbacks()
{
	////////////////////////////////////////////////////////////////////
	//
	// Add a callback to register a setting to be loaded.
	// Must be in the tracker backend.
	//
	// AddCallback_PlayerData( string setting, void functionref( entity player, string data ) callbackFunc )
	// AddCallback_PlayerData( "setting", func ) -- omit second param or use null for no func. AddCallback_PlayerData( "setting" )
	// void function func( entity player, string data )
	//
	// utility:
	//
	// Tracker_FetchPlayerData( uid, setting ) -- string|string
	// Tracker_SavePlayerData( uid, "settingname", value )  -- value: [bool|int|float|string]
	////////////////////////////////////////////////////////////////////
	
	Chat_RegisterPlayerData()
	
	if( file.bStatsIs1v1Type )
		Gamemode1v1_PlayerDataCallbacks()
		
	switch( Playlist() )
	{
		case ePlaylists.fs_scenarios:
			Scenarios_PlayerDataCallbacks()
		break
		
		default:
			break
	}
		
	//func
	
	if( Flowstate_EnableReporting() )
		AddCallback_PlayerData( "cringe_report_data" )
}

///////////////////////////// QUERIES ////////////////////////////////////////////
// usage=   AddCallback_QueryString("category:query", resultHandleFunction )	//
// 			see r5r.dev/info for details about available categories.		 	//
// 			verfified hosts: Add custom queries from host cp				 	//
//																				//
//			EX: restricted_rank:500   returns minimum player score for var "500"//
//////////////////////////////////////////////////////////////////////////////////

void function Script_RegisterAllQueries()
{
	////// INIT FUNCTIONS FOR GAMEMODES //////
	
	Tracker_QueryInit()
	//CustomGamemodeQueries_Init()
	//Gamemode1v1Queries_Init()
	//etc...etc..
}




///////////////////////////// ON SHIP ////////////////////////////////////////////
// RegisterShipFuction( void functionref( string uid ) callbackFunc )			//
//																				//
//	Registers a function that executes before building Stats/PlayerData out		//
//	If provided with a second paramater of true, runs on player disconnect 		//
//  Usful for performing custom operations with custom stats or cleanup/prep	//
//////////////////////////////////////////////////////////////////////////////////

void function Script_RegisterAllShipFunctions()
{
	if( Flowstate_EnableReporting() )
		tracker.RegisterShipFunction( OnStatsShipped_Cringe, true )
		
	//more
}


/////////////////////////////////
/// ON STATS SHIPPED FUNCTIONS //
/////////////////////////////////


void function OnStatsShipped_Cringe( string uid )
{
	entity ent = GetPlayerEntityByUID( uid )
	
	if( IsValid( ent ) && ent.p.submitCringeCount > 0 )
	{
		string dataAppend
		foreach( CringeReport report in ent.p.cringeDataReports )
		{
			dataAppend += format
			( 
				"| Reported OID= %s | Reported Name= %s | Reported Reason= %s |\n", 
				report.cringedOID,
				report.cringedName,
				report.reason
			)
		}
		
		string currentData = Tracker_FetchPlayerData( uid, "cringe_report_data" )
		string newData = ( currentData + dataAppend )
		
		if( !empty( dataAppend ) )
			Tracker_SavePlayerData( uid, "cringe_report_data", newData )
	}
}



#endif //TRACKER && HAS_TRACKER_DLL