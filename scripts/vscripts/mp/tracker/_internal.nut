untyped //stub script - mkos
#if !TRACKER
global function Stats__GetStatKeys

global function GetPlayerStatInt
global function GetPlayerStatString
global function GetPlayerStatBool
global function GetPlayerStatFloat

global function SetPlayerStatInt
global function SetPlayerStatString
global function SetPlayerStatBool
global function SetPlayerStatFloat

global function GetPlayerStatArray
global function GetPlayerStatArrayInt
global function GetPlayerStatArrayString
global function GetPlayerStatArrayBool
global function GetPlayerStatArrayFloat
global function PlayerStatArray_Append

array<string> function Stats__GetStatKeys(){ return [] }

int function GetPlayerStatInt( string player, string statname ){ return 0 }
string function GetPlayerStatString( string player, string statname ){ return "" }
bool function GetPlayerStatBool( string player, string statname ){ return false }
float function GetPlayerStatFloat( string player, string statname ){ return 0.0 }

void function SetPlayerStatInt( string player, string statname, int value ){}
void function SetPlayerStatString( string player, string statname, string value ){}
void function SetPlayerStatBool( string player, string statname, bool value ){}
void function SetPlayerStatFloat( string player, string statname, float value ){}

array<var> function GetPlayerStatArray( string player_oid, string statname ){ return [] }
array<int> function GetPlayerStatArrayInt( string player_oid, string statname ){ return [] }
array<string> function GetPlayerStatArrayString( string player_oid, string statname ){ return [] }
array<float> function GetPlayerStatArrayFloat( string player_oid, string statname ){ return [] }
array<bool> function GetPlayerStatArrayBool( string player_oid, string statname ){ return [] }
void function PlayerStatArray_Append( string player_oid, string statname, var value ){}
#endif // !TRACKER
