globalize_all_functions

struct
{
	var randomSeedLoot = null
	var randomSeedPlanePath = null
	int randomSeedIntPlanePathOverride = -1

} file



/*
======================================================================================================
======================================================================================================
======================================================================================================

##        #######   ######  ##    ## ######## ########        ##        #######   #######  ########
##       ##     ## ##    ## ##   ##  ##       ##     ##       ##       ##     ## ##     ##    ##
##       ##     ## ##       ##  ##   ##       ##     ##       ##       ##     ## ##     ##    ##
##       ##     ## ##       #####    ######   ##     ##       ##       ##     ## ##     ##    ##
##       ##     ## ##       ##  ##   ##       ##     ##       ##       ##     ## ##     ##    ##
##       ##     ## ##    ## ##   ##  ##       ##     ##       ##       ##     ## ##     ##    ##
########  #######   ######  ##    ## ######## ########        ########  #######   #######     ##

======================================================================================================
======================================================================================================
======================================================================================================
*/

// randomly seed the loot distribution and lock it (playlist var loot_lock_random_seed_number)
void function SetRandomSeedForLoot( var seed )
{
	file.randomSeedLoot = seed
}

var function GetRandomSeedForLoot()
{
	return file.randomSeedLoot
}

int function GetRandomSeedIntForLoot()
{
	int randomSeedInt = GetCurrentPlaylistVarInt( "loot_lock_random_seed_number", -1 ).tointeger()
	Assert( randomSeedInt != -1, "playlist var loot_lock_random_seed_number is not defined" )

	return randomSeedInt
}

bool function IsLockedLootActive()
{
	if ( file.randomSeedLoot )
		return true

	return false
}


float function RandomFloatForLoot( float max )
{
	if ( IsLockedLootActive() )
		return RandomFloatSeeded( file.randomSeedLoot, max )

	return RandomFloat( max )
}


float function RandomFloatRangeForLoot( float min, float max )
{
	if ( IsLockedLootActive() )
		return RandomFloatRangeSeeded( file.randomSeedLoot, min, max )

	return RandomFloatRange( min, max )
}


int function RandomIntForLoot( int max )
{
	if ( IsLockedLootActive() )
		return RandomIntSeeded( file.randomSeedLoot, max )

	return RandomInt( max )
}


int function RandomIntRangeForLoot( int min, int max )
{
	if ( IsLockedLootActive() )
		return RandomIntRangeSeeded( file.randomSeedLoot, min, max )

	return RandomIntRange( min, max )
}


int function RandomIntRangeInclusiveForLoot( int min, int max )
{
	if ( IsLockedLootActive() )
		return RandomIntRangeInclusiveSeeded( file.randomSeedLoot, min, max )

	return RandomIntRangeInclusive( min, max )
}



/*
==============================================================================================================================================================
==============================================================================================================================================================
==============================================================================================================================================================

##        #######   ######  ##    ## ######## ########        ########  ##          ###    ##    ## ########       ########     ###    ######## ##     ##
##       ##     ## ##    ## ##   ##  ##       ##     ##       ##     ## ##         ## ##   ###   ## ##             ##     ##   ## ##      ##    ##     ##
##       ##     ## ##       ##  ##   ##       ##     ##       ##     ## ##        ##   ##  ####  ## ##             ##     ##  ##   ##     ##    ##     ##
##       ##     ## ##       #####    ######   ##     ##       ########  ##       ##     ## ## ## ## ######         ########  ##     ##    ##    #########
##       ##     ## ##       ##  ##   ##       ##     ##       ##        ##       ######### ##  #### ##             ##        #########    ##    ##     ##
##       ##     ## ##    ## ##   ##  ##       ##     ##       ##        ##       ##     ## ##   ### ##             ##        ##     ##    ##    ##     ##
########  #######   ######  ##    ## ######## ########        ##        ######## ##     ## ##    ## ########       ##        ##     ##    ##    ##     ##

==============================================================================================================================================================
==============================================================================================================================================================
==============================================================================================================================================================
*/

// randomly seed the plane path and lock it (playlist var locked_plane_path_random_seed_number)

void function SetRandomSeedForPlanePath( var seed )
{
	file.randomSeedPlanePath = seed
}

int function GetRandomSeedIntForPlanePath()
{
	//Use the seed integer in the playlist unless the mode is overriding it (example: loot lock changes the seed daily)
	int randomSeedInt

	if ( file.randomSeedIntPlanePathOverride != -1 )
	{
		randomSeedInt = file.randomSeedIntPlanePathOverride
	}
	else
	{
		randomSeedInt = GetCurrentPlaylistVarInt( "locked_plane_path_random_seed_number", -1 ).tointeger()
		Assert( randomSeedInt != -1, "playlist var locked_plane_path_random_seed_number is not defined" )
	}

	return randomSeedInt
}

void function OverrideRandomSeedIntForPlanePath( int number )
{
	file.randomSeedIntPlanePathOverride = number
}

var function GetRandomSeedForPlanePath()
{
	return file.randomSeedPlanePath
}


bool function IsLockedPlanePathActive()
{
	if ( file.randomSeedPlanePath )
		return true

	return false
}

float function RandomFloatForPlanePath( float max )
{
	if ( IsLockedPlanePathActive() )
		return RandomFloatSeeded( file.randomSeedPlanePath, max )

	return RandomFloat( max )
}

float function RandomFloatRangeForPlanePath( float min, float max )
{
	if ( IsLockedPlanePathActive() )
		return RandomFloatRangeSeeded( file.randomSeedPlanePath, min, max )

	return RandomFloatRange( min, max )
}

int function RandomIntForPlanePath( int max )
{
	if ( IsLockedPlanePathActive() )
		return RandomIntSeeded( file.randomSeedPlanePath, max )

	return RandomInt( max )
}


int function RandomIntRangeForPlanePath( int min, int max )
{
	if ( IsLockedPlanePathActive() )
		return RandomIntRangeSeeded( file.randomSeedPlanePath, min, max )

	return RandomIntRange( min, max )
}

int function RandomIntRangeInclusiveForPlanePath( int min, int max )
{
	if ( IsLockedPlanePathActive() )
		return RandomIntRangeInclusiveSeeded( file.randomSeedPlanePath, min, max )

	return RandomIntRangeInclusive( min, max )
}
