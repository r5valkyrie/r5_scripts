global function StreaksTracker_Init
global function StreaksTrackerEnabled
global function StreaksTracker_AddCallback_OnStreakTriggered

#if DEVELOPER
global function DEV_ToggleStreakTrackerLogging
#endif // DEVELOPER

global enum eStreakType
{
	INVALID,
	CONSECUTIVE_KILLS_3,
	CONSECUTIVE_KILLS_5,
	CONSECUTIVE_KILLS_10,
	CONSECUTIVE_KILLS_15,
	FREQUENT_KILLS_1,
	FREQUENT_KILLS_2,
	FREQUENT_KILLS_3,
	FREQUENT_KILLS_5,

	_count
}


const float FREQUENT_KILLS_TIME_EXPIRATION = 10.0

const table< int, int > CONSECUTIVE_KILLS_STREAKS =
{
	[3] = eStreakType.CONSECUTIVE_KILLS_3,
	[5] = eStreakType.CONSECUTIVE_KILLS_5,
	[10] = eStreakType.CONSECUTIVE_KILLS_10,
	[15] = eStreakType.CONSECUTIVE_KILLS_15,
}

const table< int, int > FREQUENT_KILLS_STREAKS =
{
    [1] = eStreakType.FREQUENT_KILLS_1,
	[2] = eStreakType.FREQUENT_KILLS_2,
	[3] = eStreakType.FREQUENT_KILLS_3,
	[5] = eStreakType.FREQUENT_KILLS_5,
}


struct KillInfo
{
	int timeOfKillUnixTimestamp
	int maxStreak
}

struct StreakData
{
	array< KillInfo >											killsInfo
	int															consecutiveKills
}

struct
{
	table< entity, StreakData >									playersStreakData

	array< void functionref( entity, entity, int ) >			callbacks_OnStreakTriggered

	#if DEVELOPER
		bool 													streakLoggingEnabled						= false
	#endif // DEVELOPER
} file


void function StreaksTracker_Init()
{
	if ( !StreaksTrackerEnabled() )
		return

	file.playersStreakData.clear()

	AddCallback_OnClientConnected( SERVER_OnClientConnected )
	AddCallback_OnPlayerKilled( SERVER_OnPlayerOrNPCKilled )

	#if DEVELOPER
		file.streakLoggingEnabled = GetCurrentPlaylistVarBool( "streaks_tracker_logging_enabled", false )
	#endif // DEVELOPER
}

bool function StreaksTrackerEnabled()
{
	return GetCurrentPlaylistVarBool( "streaks_tracker_enabled", false )
}

void function StreaksTracker_AddCallback_OnStreakTriggered( void functionref( entity, entity, int ) callbackFunc )
{
	Assert( !file.callbacks_OnStreakTriggered.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " to callbacks_OnStreakTriggered" )
	file.callbacks_OnStreakTriggered.append( callbackFunc )
}

void function SERVER_OnClientConnected( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player in file.playersStreakData )
		return

	int team = player.GetTeam()
	if ( team == TEAM_SPECTATOR || team == TEAM_UNASSIGNED )
		return

	StreakData newStreakData
	newStreakData.killsInfo.clear()
	newStreakData.consecutiveKills = 0
	file.playersStreakData[player] <- newStreakData
}

void function SERVER_OnPlayerOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( victim ) )
		return

	// stop the streaks on the victim
	StopStreaks( victim )

	// if victim is the attacker, then this is a suicide and we do not award streaks for it
	if ( victim == attacker )
		return

	if ( !IsValid( attacker ) )
		return

	// update progress on streaks
	UpdateStreaks( attacker, victim, 1 )
}

void function StopStreaks( entity player )
{
	if ( !(player in file.playersStreakData) )
		return

	StreakData playerStreakData = file.playersStreakData[player]
	playerStreakData.killsInfo.clear()
	playerStreakData.consecutiveKills = 0
}

void function UpdateStreaks( entity player, entity victim, int increment )
{
	if ( !(player in file.playersStreakData) )
		return

	UpdateConsecutiveKillsStreaks( player, victim, increment )
	UpdateFrequentKillsStreaks( player, victim, increment )
}

void function UpdateConsecutiveKillsStreaks( entity player, entity victim, int increment )
{
	Assert( (player in file.playersStreakData), "INVALID Player" )
	StreakData playerStreakData = file.playersStreakData[player]

	int oldKillCount = playerStreakData.consecutiveKills
	int newKillCount = oldKillCount + increment
	for ( int killCount = oldKillCount + 1; killCount <= newKillCount; ++killCount )
	{
		if ( !(killCount in CONSECUTIVE_KILLS_STREAKS) )
			continue

		#if DEVELOPER
			if ( file.streakLoggingEnabled )
				printt( "STREAK_SYSTEM: Consecutive Kills Streak Hit - KillCount[ " + killCount + " ]" )
		#endif // DEVELOPER

		int streakType = CONSECUTIVE_KILLS_STREAKS[killCount]
		foreach ( void functionref( entity, entity, int ) callbackFunc in file.callbacks_OnStreakTriggered )
		{
			callbackFunc( player, victim, streakType )
		}
	}

	playerStreakData.consecutiveKills = newKillCount
}

void function UpdateFrequentKillsStreaks( entity player, entity victim, int increment )
{
	Assert( player in file.playersStreakData, "INVALID Player" )
	StreakData playerStreakData = file.playersStreakData[player]

	// Remove expired kills
	int currentUnixTimestamp = GetUnixTimestamp()
	while ( playerStreakData.killsInfo.len() > 0 )
	{
		KillInfo currentKillInfo = playerStreakData.killsInfo[0]

		int timeOfKillUnixTimestamp = currentKillInfo.timeOfKillUnixTimestamp
		int secondsSinceKill = currentUnixTimestamp - timeOfKillUnixTimestamp

		if ( secondsSinceKill < FREQUENT_KILLS_TIME_EXPIRATION )
		{
			break
		}

		playerStreakData.killsInfo.remove( 0 )
	}

	// Add the new kills
	for ( int addedKills = 0; addedKills < increment; ++addedKills )
	{
		KillInfo newKillInfo
		newKillInfo.timeOfKillUnixTimestamp = currentUnixTimestamp
		newKillInfo.maxStreak = 0
		playerStreakData.killsInfo.append( newKillInfo )
	}

	// Check if a new Kill Streak needs to be triggered
	int newStreak = playerStreakData.killsInfo.len()
	int minStreak = 0
	int maxStreak = 0
	foreach ( KillInfo currentKillInfo in playerStreakData.killsInfo )
	{
		maxStreak = maxint( maxStreak, currentKillInfo.maxStreak )

		if ( newStreak <= currentKillInfo.maxStreak )
		{
			--newStreak
			continue
		}

		if ( currentKillInfo.maxStreak > 0 )
		{
			if ( minStreak > 0 )
			{
				minStreak = minint( minStreak, currentKillInfo.maxStreak )
			}
			else
			{
				minStreak = currentKillInfo.maxStreak
			}
		}

		currentKillInfo.maxStreak = newStreak
	}

	#if DEVELOPER
		if ( file.streakLoggingEnabled )
		{
			foreach ( KillInfo currentKillInfo in playerStreakData.killsInfo )
			{
				printt( "STREAK_SYSTEM: Frequent Kills Streak Kills - UnixTime[ " + currentKillInfo.timeOfKillUnixTimestamp + " ] MaxStreak[ " + currentKillInfo.maxStreak + " ]" )
			}

			printt( "STREAK_SYSTEM: Frequent Kills Streak - MinStreak[ " + minStreak + " ] MaxStreak[ " + maxStreak + " ]" )
		}
	#endif // DEVELOPER

	// Trigger the Kill Streaks
	int minStreakLimit = minint( (minStreak + increment), playerStreakData.killsInfo.len() )
	for ( int killCount = minStreak + 1; killCount <= minStreakLimit; ++killCount )
	{
		if ( !(killCount in FREQUENT_KILLS_STREAKS) )
			continue

		#if DEVELOPER
			if ( file.streakLoggingEnabled )
				printt( "STREAK_SYSTEM: Frequent Kills Streak Hit - KillCount[ " + killCount + " ]" )
		#endif // DEVELOPER

		int streakType = FREQUENT_KILLS_STREAKS[killCount]
		foreach ( void functionref( entity, entity, int ) callbackFunc in file.callbacks_OnStreakTriggered )
		{
			callbackFunc( player, victim, streakType )
		}
	}

	if ( minStreak == maxStreak )
		return

	int maxStreakLimit = minint( (maxStreak + increment), playerStreakData.killsInfo.len() )
	for ( int killCount = maxStreak + 1; killCount <= maxStreakLimit; ++killCount )
	{
		if ( !(killCount in FREQUENT_KILLS_STREAKS) )
			continue

		#if DEVELOPER
			if ( file.streakLoggingEnabled )
				printt( "STREAK_SYSTEM: Frequent Kills Streak Hit - KillCount[ " + killCount + " ]" )
		#endif // DEVELOPER

		int streakType = FREQUENT_KILLS_STREAKS[killCount]
		foreach ( void functionref( entity, entity, int ) callbackFunc in file.callbacks_OnStreakTriggered )
		{
			callbackFunc( player, victim, streakType )
		}
	}
}

#if DEVELOPER
void function DEV_ToggleStreakTrackerLogging()
{
	file.streakLoggingEnabled = !file.streakLoggingEnabled

	printt( "STREAK_SYSTEM: Logging " + (file.streakLoggingEnabled ? "ENABLED" : "DISABLED") )
}
#endif // DEVELOPER