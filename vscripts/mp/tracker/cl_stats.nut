untyped																											//mkos
global function Tracker_ClientStats_Init

global function Tracker_SetPlayerStatBool
global function Tracker_SetPlayerStatInt
global function Tracker_SetPlayerStatFloat
global function Tracker_ResyncAllForPlayer
global function Tracker_ResyncStatForPlayer

global function Tracker_StatRequestFailed
global function Tracker_PreloadStatArray
global function Tracker_PreloadStat
global function Tracker_FetchStat
global function Tracker_StatExists

global const float MAX_PRELOAD_TIMEOUT = 0.35

typedef EntityStatStruct table < entity, table < string, var > >
const bool DEBUG_CL_STATS = false
const float MAX_FETCH_TIMEOUT = 5.0

struct StatKeyData
{
	bool 	_bkeyInProcess
	string	_currentKey
}

struct StatData
{
	entity player
	string statname
}

struct
{
	EntityStatStruct playerStatTables
	array<StatData> statDataQueue
	table< entity, table<string, bool> > lockTable
	table infoSignal
	
	table< entity, StatKeyData > _currentStatKey
	
} file 

// In order to use this feature on the client, 
// stats need preloaded on the client before fetching.

// Use the entity of the player to lookup and the statname. 

// If you call Tracker_FetchStat on a stat not preloaded, it will return null and 
// preload the stat for you in the background via the stat queue thread. 
// Use Tracker_StatExists( player, "statname" ) to check 

// You can preload all of the stats you want from other connected players 
// by iterating with Tracker_PreloadStatArray( [ player1 ], [ "stat1","stat2" ] ) for example.
// This should only be done when a player is ready to be stat fetch requested. 
// The preloader waits for this by default foreach player if not done before called.
// Use Tracker_IsStatsReadyFor( player ) to get a bool of the status for that player.

void function Tracker_ClientStats_Init()
{
	RegisterSignal( "StatDataReceived" )
	RegisterSignal( "RequestStatFailed" )
	RegisterSignal( "PreloadStat" )
	
	if( GetCurrentPlaylistVarBool( "disable_r5rdev_clientstats", false ) )
		return
	
	thread ClientStats_Think()
	
	#if DEVELOPER && DEBUG_CL_STATS
		printw( "NOTICE: DEBUG_CL_STATS is set to true in", FILE_NAME() )
	#endif
}

void function Tracker_SetPlayerStatBool( entity player, bool value )
{
	Signal( file.infoSignal, "StatDataReceived", { value = value } )
}

void function Tracker_SetPlayerStatInt( entity player, int value )
{
	Signal( file.infoSignal, "StatDataReceived", { value = value } )
}

void function Tracker_SetPlayerStatFloat( entity player, float value )
{
	Signal( file.infoSignal, "StatDataReceived", { value = value } )
}

void function ClientStats_Think()
{
	FlagWait( "EntitiesDidLoad" )
	if( !GetServerVar("tracker_enabled") )
	{
		#if DEVELOPER 
			printl( "Connected server is not running tracker. ending ClientStats_Think()" )
		#endif
		
		return
	}

	for( ; ; )
	{
		if( !StatQueueHasItems() )
			WaitSignal( file.infoSignal, "PreloadStat" )
			
		while( StatQueueHasItems() )
		{
			StatData statData 	= __DequeueStatQueue()
			
			entity lookupPlayer = statData.player
			string stat 		= statData.statname
			
			if( !IsValid_ThisFrame( lookupPlayer ) )
				continue
			
			while( !Tracker_IsStatsReadyFor( lookupPlayer ) )
			{
				WaitFrames( 5 )
				
				if( !IsValid( lookupPlayer ) )
					break
			}
				
			if( !IsValid( lookupPlayer ) )
				continue
			
			var data = __FetchPlayerStatInThread( lookupPlayer, stat )
			
			#if DEVELOPER && DEBUG_CL_STATS
				printw( "stat", stat, "=", data, "was preloaded on the client for player ", lookupPlayer )
			#endif
		}
	}
}

bool function StatQueueHasItems()
{
	return ( file.statDataQueue.len() > 0 )
}

void function __StatQueueRemoveDuplicates()
{
	array<StatData> returnQueue = []
	table<string, bool> keyMap = {}
	
	foreach( StatData data in file.statDataQueue )
	{	
		if( !IsValid( data.player ) )
			continue
	
		string key = format( "%s%s", data.player.GetPlatformUID(), data.statname )
		
		if( !( key in keyMap ) )
		{
			keyMap[ key ] <- true 
			returnQueue.append( data )
		}
	}
	
	file.statDataQueue = returnQueue
}

var function Tracker_FetchStat( entity player, string stat )
{
	if( !IsValid( player ) )
		return null 
		
	ValidatePlayerStatTable( player )
	
	if( !( stat in file.playerStatTables[ player ] ) )
	{
		#if DEVELOPER && DEBUG_CL_STATS
			Warning( "Stat \"%s\" was not fetched for \"%s\" and is being preloaded now.", stat, string( player ) )
		#endif 
		
		Tracker_PreloadStat( player, stat )
	}
	else 
	{
		return file.playerStatTables[ player ][ stat ]
	}
	
	return null
}

void function Tracker_PreloadStat( entity player, string stat )
{
	__AddToStatQueue( player, stat )
	Signal( file.infoSignal, "PreloadStat" )
}

void function Tracker_PreloadStatArray( array<entity> players, array<string> stats )
{
	foreach( player in players )
	{
		if( !IsValid( player ) )
			continue 
			
		foreach( statname in stats )
			__AddToStatQueue( player, statname )
	}
		
	Signal( file.infoSignal, "PreloadStat" )
}

void function __AddToStatQueue( entity player, string stat )
{	
	string checkName = player.GetPlayerName()
	if( checkName.slice( 0, 1 ).find( "[" ) != -1 || checkName == "Unknown" ) //msgbot hack
		return
		
	#if DEVELOPER && DEBUG_CL_STATS
		printf( "Adding stat \"%s\" to statqueue for \"%s\"", stat, string( player ) )
	#endif
	
	StatData data
	
	data.player = player 
	data.statname = stat 
	
	file.statDataQueue.append( data )
}

StatData function __DequeueStatQueue()
{
	__StatQueueRemoveDuplicates()
	return file.statDataQueue.remove( 0 )
}

bool function IsLocked( entity player, string stat )
{
	CheckPlayerForLock( player )
	return ( stat in file.lockTable[ player ] && file.lockTable[ player ][ stat ] == true )
}

void function LockStat( entity player, string stat )
{
	CheckPlayerForLock( player )
	file.lockTable[ player ][ stat ] <- true
}

void function UnlockStat( entity player, string stat )
{
	CheckPlayerForLock( player )
	
	if( stat in file.lockTable[ player ] )
		file.lockTable[ player ][ stat ] = false
}

void function CheckPlayerForLock( entity player )
{
	if( !( player in file.lockTable ) )
		file.lockTable[ player ] <- {}
}

var function __FetchPlayerStatInThread( entity player, string stat )
{
	float startTime = Time()
	while( !Tracker_IsStatsReadyFor( player ) )
	{
		#if DEVELOPER && DEBUG_CL_STATS
			printw( "Waiting for player stats to load for lookup: \"" + stat + "\" Player:", player )
		#endif
		
		WaitFrames( 5 )
		
		if( Time() > startTime + MAX_FETCH_TIMEOUT )
		{
			#if DEVELOPER && DEBUG_CL_STATS
				printw( "Timeout during fetch for stat:", stat, "on player:", player )
			#endif
			
			return null
		}
	}
		
	ValidatePlayerStatTable( player )
	
	if( !( stat in file.playerStatTables[ player ] ) )
	{
		waitthread __RequestPlayerStat( player, stat )
		WaitFrame()
	}
	
	if( ( stat in file.playerStatTables[ player ] ) )
		return file.playerStatTables[ player ][ stat ]
		
	return null
}

void function ValidatePlayerStatTable( entity player )
{
	if( !PlayerStatTableExists( player ) )
		file.playerStatTables[ player ] <- {}	
}

bool function PlayerStatTableExists( entity player )
{
	return( player in file.playerStatTables )	
}

void function __RequestPlayerStat( entity player, string stat )
{
	OnThreadEnd
	(
		void function() : ( player, stat )
		{
			UnlockStat( player, stat )
		}
	)

	player.EndSignal( "OnDestroy" )
	//EndSignal( file.infoSignal, "RequestStatFailed" )
	
	ValidatePlayerStatTable( player )
	
	entity localPlayer = GetLocalClientPlayer()
	if( !IsValid( localPlayer ) )
		return 
		
	if( IsLocked( player, stat ) )
		return
	
	LockStat( player, stat )
	
	localPlayer.ClientCommand( format( "requestStat %s %s", string( player.GetEncodedEHandle() ), stat ) )
	table statData = WaitSignal( file.infoSignal, "StatDataReceived", "RequestStatFailed" )
	
	if( expect string( statData.signal ) == "RequestStatFailed" )
		__SetStatValue( player, stat, null )
	else
		__SetStatValue( player, stat, statData.value )
		
	#if DEVELOPER && DEBUG_CL_STATS
		printw( "Stat set for player: ", player, stat, "=", __GetStatValue( player, stat ) )
	#endif
}

void function __SetStatValue( entity player, string stat, var value )
{
	if( stat in file.playerStatTables[ player ] )
		file.playerStatTables[ player ][ stat ] = value
	else 
		file.playerStatTables[ player ][ stat ] <- value
}

var function __GetStatValue( entity player, string stat )
{
	if( stat in file.playerStatTables[ player ] )
		return file.playerStatTables[ player ][ stat ]
	else 
		return null 
		
	unreachable
}

void function Tracker_StatRequestFailed()
{
	#if DEVELOPER && DEBUG_CL_STATS
		printw( "Stat request failed" )
	#endif
	
	Signal( file.infoSignal, "RequestStatFailed" )
}

bool function Tracker_StatExists( entity player, string statname )
{
	if( !( player in file.playerStatTables ) )
		return false 
	
	return ( statname in file.playerStatTables[ player ] )
}

void function Tracker_ResyncAllForPlayer( entity remotePlayer ) //this is more expensive. if only updating one key, call "Tracker_ResyncStatForPlayer" on server instead
{
	if( PlayerStatTableExists( remotePlayer ) )
	{
		array<string> resyncKeys
		
		foreach( string statKey, var statValue in file.playerStatTables[ remotePlayer ]  )
			resyncKeys.append( statKey )
		
		file.playerStatTables[ remotePlayer ] = {}
		
		foreach( int idx, string key in resyncKeys )
			__AddToStatQueue( remotePlayer, key )
			
		Signal( file.infoSignal, "PreloadStat" )
	}
}

void function Tracker_ResyncStatForPlayer( int remotePlayerEHandle, ... )
{
	entity remotePlayer = GetEntityFromEncodedEHandle( remotePlayerEHandle )
	if( !IsValid( remotePlayer ) )
		return
	
	__CheckCurrentStatKey( remotePlayer )
	
	if( file._currentStatKey[ remotePlayer ]._bkeyInProcess )
		return
	
	file._currentStatKey[ remotePlayer ]._bkeyInProcess = true
			
	int charCount = expect int( vargc )
	array chars = [ this, RepeatString( "%c", charCount ) ]
	
	for( int i = 0; i < vargc; i++ )
		chars.append( vargv[ i ] )
		
	file._currentStatKey[ remotePlayer ]._currentKey = expect string( format.acall( chars ) )
	
	string currentKey = file._currentStatKey[ remotePlayer ]._currentKey
	
	if( currentKey in file.playerStatTables[ remotePlayer ] )
	{
		delete file.playerStatTables[ remotePlayer ][ currentKey ]
		Tracker_PreloadStat( remotePlayer, currentKey )
	}
	
	file._currentStatKey[ remotePlayer ]._currentKey 	= ""
	file._currentStatKey[ remotePlayer ]._bkeyInProcess = false
}

void function __CheckCurrentStatKey( entity remotePlayer )
{
	if( !( remotePlayer in file._currentStatKey ) )
	{
		StatKeyData data 
		
		data._currentKey 	= ""
		data._bkeyInProcess = false
		
		file._currentStatKey[ remotePlayer ] <- data
	}
}