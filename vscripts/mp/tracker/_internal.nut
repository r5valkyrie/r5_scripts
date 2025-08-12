untyped																					//~mkos

#if TRACKER && HAS_TRACKER_DLL
//////////////////////////////
// INTERNAL STATS FUNCTIONS //
//////////////////////////////

global function Stats__InternalInit

global function Stats__RegisterStatOutboundData
global function Stats__GenerateOutBoundJsonData
global function Stats__ClearOutboundCache

global function Stats__AddPlayerStatsTable
global function Stats__GetPlayerStatsTable
global function Stats__GetRoundStatsTables
global function Stats__ResetTableByValueType
global function Stats__PlayerExists
global function Stats__RawGetStat

global function Stats__SetStatKeys
global function Stats__GetStatKeys

global function GetPlayerStatInt
global function GetPlayerStatString
global function GetPlayerStatBool
global function GetPlayerStatFloat

global function SetPlayerStatInt
global function SetPlayerStatString
global function SetPlayerStatBool
global function SetPlayerStatFloat

global function GetPlayerRoundStatInt
global function GetPlayerRoundStatString
global function GetPlayerRoundStatBool
global function GetPlayerRoundStatFloat

global typedef StatsTable table< string, var >
typedef UIDString string

struct
{
	table< UIDString, StatsTable > onlineStatsTables
	table< UIDString, StatsTable > localStatsTables //populated on disconnect.
	table< UIDString, string > generatedOutBoundJsonData
	array< string > statKeys
	
	table< string, var functionref( string UID ) > registeredStatOutboundValues

} file

void function Stats__InternalInit()
{
	AddCallback_OnClientDisconnected( OnDisconnected )
}

void function OnDisconnected( entity player )
{
	if( !Stats__PlayerExists( player.p.UID ) )
		return
		
	__AggregateStats( player )
}

StatsTable function Stats__GetPlayerStatsTable( string uid )
{	
	if( !Stats__PlayerExists( uid ) ) //Tracker_IsStatsReadyFor( entity player )
	{
		#if DEVELOPER
			//Assert( false, "Attempted to use " + FUNC_NAME() + "() on a player who's stats were not yet available" )
		#endif
	
		return EmptyStats()
	}
	
	return file.onlineStatsTables[ uid ]
}

table< UIDString, StatsTable > function Stats__GetRoundStatsTables()
{	
	return file.localStatsTables
}

StatsTable function EmptyStats()
{
	StatsTable emptyStats
	return emptyStats
}

bool function Stats__PlayerExists( string uid )
{
	return ( uid in file.onlineStatsTables )
}

void function Stats__SetStatKeys( array<string> keys )
{
	file.statKeys = keys
}

array<string> function Stats__GetStatKeys()
{
	return file.statKeys
}

var function Stats__RawGetStat( string player_oid, string statname, bool online = true )
{
	switch( online )
	{
		case true:
		
			if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
				return file.onlineStatsTables[ player_oid ][ statname ]
				
			break 
			
		case false: 
		
			if ( player_oid in file.localStatsTables && statname in file.localStatsTables[ player_oid ] ) 
				return file.localStatsTables[ player_oid ][ statname ]
			
			break
	}
	
	return null
}

function __RawSetStat( string uid, string statKey, var value, bool online = true )
{
	switch( online )
	{
		case true:
		
			if ( uid in file.onlineStatsTables && statKey in file.onlineStatsTables[ uid ] ) 
				file.onlineStatsTables[ uid ][ statKey ] = value
				
			break 
			
		case false: 
		
			if ( uid in file.localStatsTables && statKey in file.localStatsTables[ uid ] ) 
				file.localStatsTables[ uid ][ statKey ] = value
			
			break
	}
	
	return null
}

array<string> function Stats__AddPlayerStatsTable( string player_oid ) 
{
	var rawStatsTable = GetPlayerStats__internal( player_oid )
	array<string> statKeys = []
	
	if ( typeof rawStatsTable == "table" && rawStatsTable.len() > 0 ) 
	{
		table<string, var> statsTable = {}

        foreach ( key, value in rawStatsTable )
        {
            statsTable[ expect string( key ) ] <- value;
			statKeys.append( expect string( key ) )
        }
		
		file.onlineStatsTables[ player_oid ] <- statsTable
		
		entity player = GetPlayerEntityByUID( player_oid )
		
		if( IsValid( player ) && !Tracker_IgnoreResync( player ) )
		{
			StatsTable localTable = clone statsTable
			Stats__ResetTableByValueType( localTable )
			
			file.localStatsTables[ player_oid ] <- localTable
		}
	}
	
	return statKeys
}

int function GetPlayerStatInt( string player_oid, string statname ) 
{
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		return expect int( file.onlineStatsTables[ player_oid ][ statname ] )
	
	return 0
}

string function GetPlayerStatString( string player_oid, string statname ) 
{
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		return expect string( file.onlineStatsTables[ player_oid ][ statname ] )
	
	return ""
}

bool function GetPlayerStatBool( string player_oid, string statname ) 
{
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		return expect bool( file.onlineStatsTables[ player_oid ][ statname ] )
	
	return false
}

float function GetPlayerStatFloat( string player_oid, string statname ) 
{
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		return expect float( file.onlineStatsTables[ player_oid ][ statname ] )
	
	return 0.0
}

void function SetPlayerStatInt( string player_oid, string statname, int value ) 
{	
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		file.onlineStatsTables[ player_oid ][ statname ] = value
}

void function SetPlayerStatString( string player_oid, string statname, string value ) 
{
	#if DEVELOPER
		//This will be thrown out in the backend if exceeded.
		mAssert( value.len() <= 30, "Invalid string length for the value of statname \"" + statname + "\" value: \"" + value )
	#endif
	
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		file.onlineStatsTables[ player_oid ][ statname ] = value
}

void function SetPlayerStatBool( string player_oid, string statname, bool value ) 
{
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		file.onlineStatsTables[ player_oid ][ statname ] = value
}

void function SetPlayerStatFloat( string player_oid, string statname, float value ) 
{
	if ( player_oid in file.onlineStatsTables && statname in file.onlineStatsTables[ player_oid ] ) 
		file.onlineStatsTables[ player_oid ][ statname ] = value
}

// These are not handled by script registered stats and it is futile to send out, 
// as they will be dropped in the backend.
const array<string> IGNORE_STATS = 
[
	"player",
	"jumps",
	"settings",
	"total_time_played",
	"total_matches",
	"score"
]

array<string> function GenerateOutBoundDataList()
{
	array<string> generatedOutboundList = []
	
	foreach( key in file.statKeys )
	{
		if( !IGNORE_STATS.contains( key ) )
			generatedOutboundList.append( key )
	}
	
	return generatedOutboundList
}

string function Stats__GenerateOutBoundJsonData( string UID )
{
	if( empty( UID ) )
	{
		mAssert( false, "empty UID passed to " + FUNC_NAME() )
		return ""
	}
	
	if( ( UID in file.generatedOutBoundJsonData ) && !empty( file.generatedOutBoundJsonData[ UID ] ) )
		return file.generatedOutBoundJsonData[ UID ]
			
	tracker.RunShipFunctions( UID )
	
	string json = "";
	array<string> validOutBoundStats = GenerateOutBoundDataList()
	
	foreach( statKey in validOutBoundStats )
	{
		if( statKey in file.registeredStatOutboundValues )
		{		
			var data 			
			switch( __ShouldUseLocal_internal( UID, statKey ) )
			{
				case true:
					data = Stats__RawGetStat( UID, statKey, false )
					break 
					
				case false:
					data = file.registeredStatOutboundValues[ statKey ]( UID )
					break
			}
			
			string vType = typeof( data )
			
			switch( vType )
			{
				case "string":
					json += "\"" + statKey + "\": \"" + expect string( data ) + "\", ";
					break 
				
				case "int":
					json += "\"" + statKey + "\": " + expect int( data ).tostring() + ", ";
					break
					
				case "float":
					json += "\"" + statKey + "\": " + expect float( data ).tostring() + ", ";
					break
				
				case "bool":
					json += "\"" + statKey + "\": " + expect bool( data ).tostring() + ", ";
					break 
					
				#if DEVELOPER 
					default:
						printw( "Unsupported stat value type for", "\""+ statKey + "\":", vType )
				#endif
			}
		}
	}
	
	file.generatedOutBoundJsonData[ UID ] <- json
	return json
}

void function Stats__ClearOutboundCache()
{
	file.generatedOutBoundJsonData = {} //reassign reference
}

void function Stats__RegisterStatOutboundData( string statname, var functionref( string UID ) func )
{
	if( ( statname in file.registeredStatOutboundValues ) )
	{
		sqerror( "Tried to add func " + string( func ) + "() as an outbound data func for [" + statname + "] but func " + string( file.registeredStatOutboundValues[statname] ) + "() is already defined to handle outbound data for stat." )
		return
	}
	
	file.registeredStatOutboundValues[ statname ] <- func
}

void function __AggregateStats( entity player )
{
	string uid = player.p.UID
	array<string> validOutBoundStats = GenerateOutBoundDataList()
	
	foreach( statKey in validOutBoundStats )
	{
		if( !( statKey in file.registeredStatOutboundValues ) )
			continue 
			
		__AggregateStat_internal( player, statKey )
	}
}

void function __AggregateStat_internal( entity player, string statKey )
{	
	string uid = player.p.UID
	
	var data = file.registeredStatOutboundValues[ statKey ]( uid )
	string vType = typeof( data )
		
	switch( vType )
	{		
		case "int":
			
			int addValue = expect int( data )
			int storedValue = GetPlayerRoundStatInt( uid, statKey )
			__RawSetStat( uid, statKey, MakeVar( addValue + storedValue ), false )		
			break
			
		case "float":
			float addValue = expect float( data )
			float storedValue = GetPlayerRoundStatFloat( uid, statKey )
			__RawSetStat( uid, statKey, MakeVar( addValue + storedValue ), false )
			break
		
		case "bool":
			__RawSetStat( uid, statKey, data, false )

		case "string":
			__RawSetStat( uid, statKey, data, false )
			break
	}
}

var function MakeVar( ... )
{
	if( vargc > 0 )
		return vargv[ 0 ]
	
	mAssert( false, "Called MakeVar with no arguments." )
	return null
}

void function Stats__ResetTableByValueType( StatsTable statsTbl )
{
	foreach( string statKey, var statValue in statsTbl )
	{
		string vType = typeof( statValue )
		switch( vType )
		{
			case "int":
				statsTbl[ statKey ] = 0
				break 
			
			case "float":
				statsTbl[ statKey] = 0.0
				break
			
			case "string":
				statsTbl[ statKey ] = ""
				break
				
			case "bool":
				statsTbl[ statKey ] = false
				break
			
			default:
				#if DEVELOPER 
					mAssert( false, "Unsupported stat type \"" + vType + "\" for stat key \"" + statKey + "\"" )
				#endif
		}
	}
}

int function GetPlayerRoundStatInt( string player_oid, string statname ) 
{
	if ( player_oid in file.localStatsTables && statname in file.localStatsTables[ player_oid ] ) 
		return expect int( file.localStatsTables[ player_oid ][ statname ] )
	
	return 0
}

string function GetPlayerRoundStatString( string player_oid, string statname ) 
{
	if ( player_oid in file.localStatsTables && statname in file.localStatsTables[ player_oid ] ) 
		return expect string( file.localStatsTables[ player_oid ][ statname ] )
	
	return ""
}

bool function GetPlayerRoundStatBool( string player_oid, string statname ) 
{
	if ( player_oid in file.localStatsTables && statname in file.localStatsTables[ player_oid ] ) 
		return expect bool( file.localStatsTables[ player_oid ][ statname ] )
	
	return false
}

float function GetPlayerRoundStatFloat( string player_oid, string statname ) 
{
	if ( player_oid in file.localStatsTables && statname in file.localStatsTables[ player_oid ] ) 
		return expect float( file.localStatsTables[ player_oid ][ statname ] )
	
	return 0.0
}

bool function __ShouldUseLocal_internal( string uid, string statKey )
{
	if( !Tracker_StatLocalAllowed( statKey ) )
		return false
		
	entity player = GetPlayerEntityByUID( uid )
	if( IsValid( player ) )
	{
		if( Tracker_GetPlayerLeftFlag( player ) )
		{
			__AggregateStat_internal( player, statKey )			
			return true
		}
		
		return false
	}
	
	return true
}
#else //TRACKER && HAS_TRACKER_DLL

global function Stats__GetStatKeys

global function GetPlayerStatInt
global function GetPlayerStatString
global function GetPlayerStatBool
global function GetPlayerStatFloat

global function SetPlayerStatInt
global function SetPlayerStatString
global function SetPlayerStatBool
global function SetPlayerStatFloat

array<string> function Stats__GetStatKeys(){ return [] }

int function GetPlayerStatInt( string player, string statname ){ return 0 }
string function GetPlayerStatString( string player, string statname ){ return "" }
bool function GetPlayerStatBool( string player, string statname ){ return false }
float function GetPlayerStatFloat( string player, string statname ){ return 0.0 }

void function SetPlayerStatInt( string player, string statname, int value ){}
void function SetPlayerStatString( string player, string statname, string value ){}
void function SetPlayerStatBool( string player, string statname, bool value ){}
void function SetPlayerStatFloat( string player, string statname, float value ){}
#endif // ELSE !TRACKER && !HAS_TRACKER_DLL
