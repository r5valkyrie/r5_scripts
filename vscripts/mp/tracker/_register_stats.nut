untyped																			
globalize_all_functions
#if TRACKER && HAS_TRACKER_DLL																	//~mkos

const bool STORE_STAT = true //this constant is not a toggle.

struct StatResetData
{
	string uid
	string statKey
	var savedValue
}

struct 
{
	array< StatResetData > shouldResetData
	bool RegisterCoreStats 	= true
	bool bStatsIs1v1Type 	= false

} file

void function SetRegisterCoreStats( bool b )
{
	file.RegisterCoreStats = b	
}

void function Tracker_Internal_Init()
{
	file.bStatsIs1v1Type = g_bIs1v1GameType()
	
	bool bRegisterCoreStats = !GetCurrentPlaylistVarBool( "disable_core_stats", false )
	SetRegisterCoreStats( bRegisterCoreStats )
	
	Stats__InternalInit()
}

void function Tracker_SetShouldResetStatOnShip( string uid, string statKey, var origValue, bool bShouldReset = true )
{
	if( bShouldReset )
	{
		StatResetData statData
		
		statData.uid		= uid
		statData.statKey 	= statKey
		statData.savedValue = origValue
		
		file.shouldResetData.append( statData )
	}
	else 
	{
		int maxIter = file.shouldResetData.len() - 1
		if( maxIter == 0 )
			return
			
		for( int i = maxIter; i >= 0; i-- )
		{
			if( file.shouldResetData[ i ].uid == uid && file.shouldResetData[ i ].statKey == statKey )
				file.shouldResetData.remove( i )
		}
	}
}

void function Tracker_RunStatResets()
{
	foreach( int idx, StatResetData statData in file.shouldResetData )
		Stats__RawSetStat( statData.uid, statData.statKey, statData.savedValue )
}

void function Tracker_ResyncAllForPlayer( entity playerToSync )
{
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "Tracker_ResyncAllForPlayer", playerToSync )
}

void function Tracker_ResyncStatForPlayer( entity playerToSync, string statKey )
{
	int statKeyLen = statKey.len()
	mAssert( statKeyLen <= 9, "Cannot transmit statkey len > 9 chars for resync" )//for now (uses a single remote call this way)
	
	foreach( player in GetPlayerArray() )
	{
		array transmit = [ this, player, "Tracker_ResyncStatForPlayer", playerToSync.GetEncodedEHandle() ]	
		for( int i = 0; i < statKeyLen; i++ )
			transmit.append( statKey[ i ] )
	
		Remote_CallFunction_NonReplay.acall( transmit )
	}
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
	// GetPlayerStat%TYPE%( playerUID, "statname" )  %TYPE% = [ Int, Bool, Float, String, Array, ArrayInt, ArrayBool, ArrayFloat, ArrayString ]

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
			
			// If Tracker_RegisterStat is passed with fourth parameter of true, ( STORE_STAT )
			// a local copy is maintained of accumulated stats for the round, regardless of disconnects/rejoins.  
			// This means you can use getters based on player entity 
			
			// Should be used: if using any stat value that will be garbage cleaned on disconnect etc
			// ( player net int, player struct var, etc )
			
			// WARNING:	Do not set the same var in an inbound stat func, that the outbound stat func returns. 
			// This will result in player stat data aggregation inflation on next disconnect. 		
				
			// For base stats, the player will have a record associated automatically by uid 
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
	
	Tracker_RegisterStat( "unlocked_badges" )
	Tracker_RegisterStat( "badge_1", null, Tracker_Badge1 )
	Tracker_RegisterStat( "badge_2", null, Tracker_Badge2 )
	Tracker_RegisterStat( "badge_3", null, Tracker_Badge3 )
	AddCallback_PlayerDataFullyLoaded( Callback_CheckBadges )
	
	#if DEVELOPER 
		//Tracker_RegisterStat( "test_array", null, TrackerStats_TestStringArray )
		//Tracker_RegisterStat( "test_bool_array", null, TrackerStats_TestBoolArray )
		//Tracker_RegisterStat( "test_int_array", null, TrackerStats_TestIntArray, STORE_STAT )
		//Tracker_RegisterStat( "test_float_array", null, TrackerStats_TestFloatArray )
	#endif 
	
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
			Tracker_RegisterStat( "instagib_gamesplayed", null, TrackerStats_GamesCompleted )
			Tracker_RegisterStat( "instagib_wins", null, TrackerStats_FSDMWins )	
		break

		case ePlaylists.fs_haloMod:
			Tracker_RegisterStat( "halo_dm_kills", null, Tracker_ReturnKills )
			Tracker_RegisterStat( "halo_dm_deaths", null, Tracker_ReturnDeaths )
			Tracker_RegisterStat( "halo_dm_gamesplayed", null, TrackerStats_GamesCompleted )
			Tracker_RegisterStat( "halo_dm_wins", null, TrackerStats_FSDMWins )
		break
		
		case ePlaylists.fs_haloMod_oddball:
			Tracker_RegisterStat( "halo_oddball_kills", null, Tracker_ReturnKills )
			Tracker_RegisterStat( "halo_oddball_deaths", null, Tracker_ReturnDeaths )
			Tracker_RegisterStat( "halo_oddball_heldtime", null, TrackerStats_OddballHeldTime, STORE_STAT )
			Tracker_RegisterStat( "halo_oddball_gamesplayed", null, TrackerStats_GamesCompleted )
		break

		case ePlaylists.fs_haloMod_ctf:

			Tracker_RegisterStat( "halo_ctf_flags_captured", null, TrackerStats_CtfFlagsCaptured, STORE_STAT )
			Tracker_RegisterStat( "halo_ctf_flags_returned", null, TrackerStats_CtfFlagsReturned, STORE_STAT )
			Tracker_RegisterStat( "halo_ctf_gamesplayed", null, TrackerStats_GamesCompleted )
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
			//printw( "found statKey =", statKey, "statValue =", statValue )
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

//Tracker already has a gamemode play count, which is different from this stat.
var function TrackerStats_GamesCompleted( string uid ) //Todo: Handle accumulation from rejoins
{
	entity player = GetPlayerEntityByUID( uid ) 
	if( !IsValid( player ) )
		return 0 //check to make sure player is still in server at round end
	
	int roundTime = fsGlobal.EndlessFFAorTDM ? 600 : FlowState_RoundTime()
	if( ( Time() - player.p.connectTime ) < ( roundTime / 2 )  )
		return 0 // if player did not play 1/2 of the round, or atleast 5 minutes for endless, dont credit a play count.
		
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

var function Tracker_Badge1( string uid )
{
	return GetPlayerStatInt( uid, "badge_1" )
}

var function Tracker_Badge2( string uid )
{
	return GetPlayerStatInt( uid, "badge_2" )
}

var function Tracker_Badge3( string uid )
{
	return GetPlayerStatInt( uid, "badge_3" )
}

// var function TrackerStats_TestStringArray( string uid )
// {
	// return ["test", "test2", "test3"]
// }

// var function TrackerStats_TestBoolArray( string uid )
// {
	// return [ true, false, false, true ]
// }

// var function TrackerStats_TestFloatArray( string uid )
// {
	// return [ 1.0, 3.5188494 ]
// }

// var function TrackerStats_TestIntArray( string uid )
// {
	// return MakeVarArrayInt( GetPlayerEntityByUID( uid ).p.testarray ) // must be plain 'array' or made untyped.
// }

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

void function Callback_CheckBadges( entity player )
{
	string uid = player.p.UID
	
	int badge_1 = GetPlayerStatInt( uid, "badge_1" )
	if( !Tracker_IsValidBadge( badge_1, uid ) )
	{
		Tracker_SetShouldResetStatOnShip( uid, "badge_1", badge_1 ) 
		/* 
			we do this, becase the main stat table is what is synced to clients, however 
			Tracker_IsValidBadge can return false for dev badges or unlocked badges 
			if the player isn't dev or doesn't own a badge, however for servers
			that allow all badges, we must reset this invalid back to the player's 
			chosen badge so that it reflects their choice which may be valid on those 
			allowed servers. 		
		*/
		
		SetPlayerStatInt( uid, "badge_1", 0 )
	}
		
	int badge_2 = GetPlayerStatInt( uid, "badge_2" )
	if( !Tracker_IsValidBadge( badge_2, uid ) )
	{
		Tracker_SetShouldResetStatOnShip( uid, "badge_2", badge_2 )
		SetPlayerStatInt( uid, "badge_2", 0 )
	}
		
	int badge_3 = GetPlayerStatInt( uid, "badge_3" )
	if( !Tracker_IsValidBadge( badge_3, uid ) )
	{
		Tracker_SetShouldResetStatOnShip( uid, "badge_3", badge_3 )
		SetPlayerStatInt( uid, "badge_3", 0 )
	}
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
	
	if( file.bStatsIs1v1Type && Playlist() != ePlaylists.fs_scenarios ) //todo clean up intertwinedness.. 
		Gamemode1v1_PlayerDataCallbacks()
		
	switch( Playlist() )
	{
		case ePlaylists.fs_scenarios:
			Scenarios_PlayerDataCallbacks()
		break
		
		default:
			break
	}
	
	if( Flowstate_EnableReporting() )
		AddCallback_PlayerData( "cringe_report_data" )
		
	//func
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
		tracker.RegisterShipFunction( OnStatsShipping_Cringe, true )
		
	//more
}


///////////////////////////////////
/// ON STATS SHIPPING FUNCTIONS ///
///////////////////////////////////


void function OnStatsShipping_Cringe( string uid ) //todo deprecate
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


#else //!TRACKER && !HAS_TRACKER_DLL

	//non tracker declarations
	void function Tracker_SetShouldResetStatOnShip( string uid, string statKey, var origValue, bool bShouldReset = true ){}
	void function Tracker_ResyncAllForPlayer( entity player ){}
	void function Tracker_ResyncStatForPlayer( entity playerToSync, string statKey ){}
#endif