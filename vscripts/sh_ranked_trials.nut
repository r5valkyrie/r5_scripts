global function Sh_RankedTrials_Init
global function RankedTrials_IsKillswitchEnabled
global function RankedTrials_GetTrialToEnterTier
global function RankedTrials_RegisterAllRankedTrials

// Bakery data accessors
global function RankedTrials_GetTrialMatchCount
global function RankedTrials_GetTrialMaxMatchCount
global function RankedTrials_GetTrialBonusLPGain
global function RankedTrials_GetTrialMaxLPLoss
global function RankedTrials_GetTrialMinLPLoss
global function RankedTrials_SecondaryTrialRequiresSingleMatchPerformance
global function RankedTrials_GetSecondaryTrialSingleMatchComboCount
global function RankedTrials_GetTrialStatGoalByIndex
global function RankedTrials_GetTrialStatEntryByIndex
global function RankedTrials_HasSecondaryTrial
global function RankedTrials_HasDualStatSecondaryTrial

// Persistence accessors
global function RankedTrials_PlayerHasAssignedTrial
global function RankedTrials_GetAssignedTrial
global function RankedTrials_GetNetLP
global function RankedTrials_GetSecondaryStatMatchComboStatProgress
global function RankedTrials_GetGamesPlayedInTrialsState
global function RankedTrials_GetGamesAllowedInTrialsState
global function RankedTrials_GetTimesFailedTrial
global function RankedTrials_GetProgressValueForStatByIndex
global function RankedTrials_GetTrialState
global function RankedTrials_PlayerHasIncompleteTrial

#if CLIENT || UI
global function RankedTrials_GetDescription
global function RankedTrials_GetTrialsCountForTrial
global function RankedTrials_NextRankHasTrial
#endif // #if CLIENT || UI

#if SERVER
global function RankedTrials_OnPlayerConnected
global function RankedTrials_AssignTrial
global function RankedTrials_UpdateTrialCompletion
global function RankedTrials_SaveMatchLP
global function RankedTrials_PlayerShouldBePlacedIntoTrialForTier
global function RankedTrials_ResetXMergePlatformPersistenceData
#endif // #if SERVER

#if DEVELOPER
#if SERVER
global function DEV_TrialsUnitTest
#endif
#endif

global const string RANKED_TRIALS_PERSISTENCE_STATE_KEY = "trialState"

global enum eRankedTrialState
{
	NOT_IN_TRIAL,
	INCOMPLETE,
	SUCCESS,
	FAILURE,
	COUNT,
}

global enum eRankedTrialGoalIdx
{
	PRIMARY,
	SECONDARY_ONE,
	SECONDARY_TWO,
}

struct
{
	table< string, int > rankedTierToTrialMap // string is tier LOC - #RANKED_TIER_BRONZE; int is ItemFlavor guid
	table< int, array< string > > trialStatRefCache // int is ItemFlavor guid
} file

const string CONVAR_KILL_SWITCH = "ranked_disable_promo_trials"

// Bakery Data Keys
const string R2P0_SETTINGS_KEY_RANKED_TRIAL = "rankedTrialToEnterTier" // on parent ranked2Pt0Period
const string SETTINGS_KEY_ENTERS_TIER = "entersTier" // NO override
const string SETTINGS_KEY_MATCH_COUNT = "matchCount"
const string SETTINGS_KEY_MATCH_COUNT_MAX = "matchCountMax"
const string SETTINGS_KEY_BONUS_LP_GAIN = "bonusLPGain"
const string SETTINGS_KEY_MAX_LP_LOSS = "maxLPLoss"
const string SETTINGS_KEY_MIN_LP_LOSS = "minLPLoss"
const string SETTINGS_KEY_PRIMARY_GOAL_VAL = "goalVal" // primary
const string SETTINGS_KEY_PRIMARY_STAT_REF = "statRef" // primary
const string SETTINGS_KEY_SECONDARY_REQUIRES_SINGLE_MATCH = "singleMatch" // secondary
const string SETTINGS_KEY_SECONDARY_SINGLE_MATCH_COMBO_COUNT = "singleMatchComboCount" // secondary
const string SETTINGS_KEY_SECONDARY_GOAL_VAL_ONE = "goalValAltOne" // secondary
const string SETTINGS_KEY_SECONDARY_STAT_REF_ONE = "statRefAltOne" // secondary
const string SETTINGS_KEY_SECONDARY_GOAL_VAL_TWO = "goalValAltTwo" // secondary
const string SETTINGS_KEY_SECONDARY_STAT_REF_TWO = "statRefAltTwo" // secondary
const string SETTINGS_KEY_DESCRIPTION_PRIMARY = "description" // use LOC key override
const string SETTINGS_KEY_DESCRIPTION_SECONDARY_ONE = "descriptionAltOne" // use LOC key override
const string SETTINGS_KEY_DESCRIPTION_SECONDARY_TWO = "descriptionAltTwo" // use LOC key override

const string PLAYLIST_OVERRIDE_FORMAT_STRING = "ranked_trials_%s_%s" // ranked_trials_SAID_KEY = override

// Persistence Var Keys
const string RANKED_TRIALS_PERSISTENCE_STRUCT = "rankedTrials"
const string PERSISTENCE_KEY_FORMAT_STRING = XPROG_PERSISTENCE_PREFIX_FORMAT_STRING + RANKED_TRIALS_PERSISTENCE_STRUCT + ".%s"
const string PERSISTENCE_KEY_GUID = "guid" // Bakery SAID
const string PERSISTENCE_KEY_PRIMARY_STAT_PROGRESS = "primaryStatProgress" // tracks explicitly - not a diff like Challenges - because underlying stats are not per-platform
const string PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_ONE = "secondaryStatProgressOne" // tracks explicitly - not a diff like Challenges - because underlying stats are not per-platform
const string PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_TWO = "secondaryStatProgressTwo" // tracks explicitly - not a diff like Challenges - because underlying stats are not per-platform
const string PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_COMBO = "secondaryTrialCombinedProgress" // --> for when a single match, tick this. like (3x, get A & B in a single match)
const string PERSISTENCE_KEY_GAMES_IN_TRIAL_STATE = "gamesPlayedInTrialState"
const string PERSISTENCE_KEY_NET_LP_DURING_TRIAL = "netLPDuringTrial" // where we track LP gains/losses during Trial
const string PERSISTENCE_KEY_TRIAL_STATE = "state" // see eRankedTrialState
const string PERSISTENCE_KEY_TIMES_FAILED_TRIAL = "timesFailedTrial" // reset only upon succesful completion --> Tier Up

const array< string > PERSISTENCE_KEYS =
[
	PERSISTENCE_KEY_GUID,
	PERSISTENCE_KEY_PRIMARY_STAT_PROGRESS,
	PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_ONE,
	PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_TWO,
	PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_COMBO,
	PERSISTENCE_KEY_GAMES_IN_TRIAL_STATE,
	PERSISTENCE_KEY_NET_LP_DURING_TRIAL,
	PERSISTENCE_KEY_TRIAL_STATE,
	PERSISTENCE_KEY_TIMES_FAILED_TRIAL, // MUST be last entry
]

const table< string, string > BAKERY_LABEL_TO_STAT_REF =
{
	["PLACEMENTS_WIN"] = "stats.rankedperiods[%s].placements_win",
	["PLACEMENTS_TOP_5"] = "stats.rankedperiods[%s].placements_top_5",
	["PLACEMENTS_TOP_10"] = "stats.rankedperiods[%s].placements_top_10",
	["KILLS_OR_ASSISTS"] = "stats.kills_or_assists", // just reuses the base kills-or-assists because we only increment underlying progress markers in Ranked Games
	["KILLS"] = "stats.rankedperiods[%s].kills",
	["DAMAGE_DONE"] = "stats.rankedperiods[%s].damage_done",
	["NONE"] = "",
}

#if DEVELOPER
const string DEV_RUN_PLAYLIST_OVERRIDE_CHECK = "ranked_trials_dev_playlist_check"
const int DEV_FORCE_COMPLETION_STATUS = -1 // -1 disables
#endif

void function Sh_RankedTrials_Init()
{
	_CacheStatEntries() // do this every level load - even in UIVM - because the cache needs to purge any playlist overrides during a session
	#if DEVELOPER
		Assert( PERSISTENCE_KEYS.find( PERSISTENCE_KEY_TIMES_FAILED_TRIAL ) == PERSISTENCE_KEYS.len() - 1 )
		Assert( DEV_CheckPlaylistOverrides() )
	#endif
}

bool function RankedTrials_IsKillswitchEnabled()
{
	return GetConVarBool( CONVAR_KILL_SWITCH )
}

void function RankedTrials_RegisterAllRankedTrials()
{
	ItemFlavor ornull currentRankedPeriod = Ranked_GetCurrentActiveRankedPeriod()
	if ( currentRankedPeriod == null )
		return

	expect ItemFlavor( currentRankedPeriod )
	if ( ItemFlavor_GetType( currentRankedPeriod ) != eItemType.ranked_2pt0_period )
		return

	foreach ( var tierBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( currentRankedPeriod ), "tiers" ) )
	{
		asset trialAsset = GetSettingsBlockAsset( tierBlock, R2P0_SETTINGS_KEY_RANKED_TRIAL )
		if ( trialAsset != $"" )
		{
			ItemFlavor ornull rankedTrial = RegisterItemFlavorFromSettingsAsset( trialAsset )
			if ( rankedTrial == null )
			{
				printt( "Failed to register ItemFlavor from Settings Asset ", trialAsset )
			}
			else
			{
				expect ItemFlavor( rankedTrial )
				var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
				string entersTier = GetSettingsBlockString( settingsBlock, SETTINGS_KEY_ENTERS_TIER )
				Assert( TIER_ORDERING_BY_LOC_KEY.contains( entersTier ) )
				file.rankedTierToTrialMap[ entersTier ] <- ItemFlavor_GetGUID( rankedTrial )
			}
		}
	}
}

ItemFlavor function RankedTrials_GetTrialToEnterTier( string tierName )
{
	Assert( tierName in file.rankedTierToTrialMap )
	Assert( IsValidItemFlavorGUID( file.rankedTierToTrialMap[ tierName ] ) )
	return GetItemFlavorByGUID( file.rankedTierToTrialMap[ tierName ] )
}

// Bakery Data Accessors With Playlist Overrides
int function RankedTrials_GetTrialMatchCount( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	int matchCount    = GetSettingsBlockInt( settingsBlock, SETTINGS_KEY_MATCH_COUNT )

	return GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_MATCH_COUNT ), matchCount )
}

int function RankedTrials_GetTrialMaxMatchCount( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	int matchCountMax = GetSettingsBlockInt( settingsBlock, SETTINGS_KEY_MATCH_COUNT_MAX )

	return GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_MATCH_COUNT_MAX ), matchCountMax )
}

int function RankedTrials_GetTrialBonusLPGain( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	int maxLpGain     = GetSettingsBlockInt( settingsBlock, SETTINGS_KEY_BONUS_LP_GAIN )

	return GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_BONUS_LP_GAIN ), maxLpGain )
}

int function RankedTrials_GetTrialMaxLPLoss( ItemFlavor rankedTrial )
{
	// returns a NEGATIVE number. Assumes all INPUTS are POSITIVE numbers.
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	int maxLpLoss     = GetSettingsBlockInt( settingsBlock, SETTINGS_KEY_MAX_LP_LOSS )
	Assert( maxLpLoss > 0 )
	int maxLpLossPl   = GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_MAX_LP_LOSS ), maxLpLoss )
	Assert( maxLpLossPl > 0 )
	return ( -1 * abs( maxLpLossPl ) )
}

int function RankedTrials_GetTrialMinLPLoss( ItemFlavor rankedTrial )
{
	// returns a NEGATIVE number. Assumes all INPUTS are POSITIVE numbers.
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	int minLpLoss     = GetSettingsBlockInt( settingsBlock, SETTINGS_KEY_MIN_LP_LOSS )
	Assert( minLpLoss > 0 )
	int minLpLossPl   = GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_MIN_LP_LOSS ), minLpLoss )
	Assert( minLpLossPl > 0 )
	return ( -1 * abs( minLpLossPl ) )
}

bool function RankedTrials_SecondaryTrialRequiresSingleMatchPerformance( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock        = ItemFlavor_GetSettingsBlock( rankedTrial )
	bool requiresSingleMatch = GetSettingsBlockBool( settingsBlock, SETTINGS_KEY_SECONDARY_REQUIRES_SINGLE_MATCH )

	return GetCurrentPlaylistVarBool( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_SECONDARY_REQUIRES_SINGLE_MATCH ), requiresSingleMatch )
}

int function RankedTrials_GetSecondaryTrialSingleMatchComboCount( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock   = ItemFlavor_GetSettingsBlock( rankedTrial )
	int matchComboCount = GetSettingsBlockInt( settingsBlock, SETTINGS_KEY_SECONDARY_SINGLE_MATCH_COMBO_COUNT )

	return GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), SETTINGS_KEY_SECONDARY_SINGLE_MATCH_COMBO_COUNT ), matchComboCount )
}

int function RankedTrials_GetTrialStatGoalByIndex( ItemFlavor rankedTrial, int statIdx )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	string keyStr = ""
	switch ( statIdx )
	{
		case eRankedTrialGoalIdx.PRIMARY:
			keyStr = SETTINGS_KEY_PRIMARY_GOAL_VAL
			break

		case eRankedTrialGoalIdx.SECONDARY_ONE:
			keyStr = SETTINGS_KEY_SECONDARY_GOAL_VAL_ONE
			break

		case eRankedTrialGoalIdx.SECONDARY_TWO:
			keyStr = SETTINGS_KEY_SECONDARY_GOAL_VAL_TWO
			break
	}
	Assert( keyStr != "" )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	int statGoal      = GetSettingsBlockInt( settingsBlock, keyStr )

	return GetCurrentPlaylistVarInt( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), keyStr ), statGoal )
}

bool function RankedTrials_HasSecondaryTrial( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )
	int idx1 = eRankedTrialGoalIdx.SECONDARY_ONE
	return (idx1 >= 0 && idx1 < file.trialStatRefCache[ ItemFlavor_GetGUID( rankedTrial ) ].len())
}

bool function RankedTrials_HasDualStatSecondaryTrial( ItemFlavor rankedTrial )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )
	int idx2 = eRankedTrialGoalIdx.SECONDARY_TWO
	return (idx2 >= 0 && idx2 < file.trialStatRefCache[ ItemFlavor_GetGUID( rankedTrial ) ].len())
}

#if CLIENT || UI
int function RankedTrials_GetTrialsCountForTrial( ItemFlavor rankedTrial )
{
	int trialsCount = 1
	bool hasSecondaryTrial = RankedTrials_HasSecondaryTrial( rankedTrial )
	bool dualStatSecondary = hasSecondaryTrial && RankedTrials_HasDualStatSecondaryTrial( rankedTrial )  && !RankedTrials_SecondaryTrialRequiresSingleMatchPerformance( rankedTrial )
	if ( hasSecondaryTrial )
	{
		trialsCount += dualStatSecondary ? 2: 1
	}
	return trialsCount
}
#endif

void function _CacheStatEntries()
{
	foreach ( string _, int rankedTrialGUID in file.rankedTierToTrialMap )
	{
		Assert( IsValidItemFlavorGUID( rankedTrialGUID ) )
		ItemFlavor rankedTrial = GetItemFlavorByGUID( rankedTrialGUID )
		array< string > statArray = []
		foreach ( int statIdx in eRankedTrialGoalIdx )
		{
			string keyStr = ""
			switch ( statIdx )
			{
				case eRankedTrialGoalIdx.PRIMARY:
					keyStr = SETTINGS_KEY_PRIMARY_STAT_REF
					break

				case eRankedTrialGoalIdx.SECONDARY_ONE:
					keyStr = SETTINGS_KEY_SECONDARY_STAT_REF_ONE
					break

				case eRankedTrialGoalIdx.SECONDARY_TWO:
					keyStr = SETTINGS_KEY_SECONDARY_STAT_REF_TWO
					break
			}
			Assert( keyStr != "" )

			var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
			string statRefKey = GetSettingsBlockString( settingsBlock, keyStr )
			string statRef    = format( BAKERY_LABEL_TO_STAT_REF[ statRefKey ], Ranked_GetCurrentPeriodGUIDString() )
			Assert( ( statRef == "" && statIdx >= eRankedTrialGoalIdx.SECONDARY_ONE ) || IsValidStatEntryRef( statRef ) )

			string playlistRef = GetCurrentPlaylistVarString( format( PLAYLIST_OVERRIDE_FORMAT_STRING, ItemFlavor_GetGUIDString( rankedTrial ), keyStr ), statRef )
			if ( IsValidStatEntryRef( playlistRef ) )
			{
				statArray.append( playlistRef )
			}
			else if ( statRef != "" )
			{
				Assert( false, format( "Ranked Trials: Playlist override is broken for Trial %d - invalid statRef %s", ItemFlavor_GetGUID( rankedTrial ), playlistRef ) )
				statArray.append( statRef )
			}
			else
			{
				Assert( statIdx >= eRankedTrialGoalIdx.SECONDARY_ONE )
				break
			}
		}
		file.trialStatRefCache[ ItemFlavor_GetGUID( rankedTrial ) ] <- statArray
	}
	Assert( file.trialStatRefCache.len() == file.rankedTierToTrialMap.len() )
}

StatEntry function RankedTrials_GetTrialStatEntryByIndex( ItemFlavor rankedTrial, int statIdx )
{
	int guid = ItemFlavor_GetGUID( rankedTrial )
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )
	Assert( statIdx == eRankedTrialGoalIdx.PRIMARY || RankedTrials_HasSecondaryTrial( rankedTrial ) )
	Assert( statIdx != eRankedTrialGoalIdx.SECONDARY_TWO || RankedTrials_HasDualStatSecondaryTrial( rankedTrial ) )
	Assert( _IsValidTrialStatEntryIndex( rankedTrial, statIdx ) )
	Assert( IsValidStatEntryRef( file.trialStatRefCache[ guid ][ statIdx ] ) )

	return GetStatEntryByRef( file.trialStatRefCache[ guid ][ statIdx ] )
}

bool function _IsValidTrialStatEntryIndex( ItemFlavor rankedTrial, int statIdx )
{
	int guid = ItemFlavor_GetGUID( rankedTrial )
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )
	Assert( guid in file.trialStatRefCache )

	return (statIdx >= 0 && statIdx < file.trialStatRefCache[ guid ].len())
}


#if CLIENT || UI
string function RankedTrials_GetDescription( ItemFlavor rankedTrial, int statIdx )
{
	Assert( ItemFlavor_GetType( rankedTrial ) == eItemType.ranked_trial )

	var settingsBlock = ItemFlavor_GetSettingsBlock( rankedTrial )
	switch ( statIdx )
	{
		case eRankedTrialGoalIdx.PRIMARY:
			return GetSettingsBlockString( settingsBlock, SETTINGS_KEY_DESCRIPTION_PRIMARY )

		case eRankedTrialGoalIdx.SECONDARY_ONE:
			return GetSettingsBlockString( settingsBlock, SETTINGS_KEY_DESCRIPTION_SECONDARY_ONE )

		case eRankedTrialGoalIdx.SECONDARY_TWO:
			return GetSettingsBlockString( settingsBlock, SETTINGS_KEY_DESCRIPTION_SECONDARY_TWO )

		default:
			Assert( false )
			return ""
	}

	unreachable
}
#endif // #if CLIENT || UI
// End Bakery Data Accessors

// Persistence Accessors
int function _GetPersistenceData( entity player, string persistenceValueKey )
{
	Assert( PERSISTENCE_KEYS.contains( persistenceValueKey ) )
	string platformId = GetMergedPlatformIdForPlayer( player )
	string persistenceKey = format( PERSISTENCE_KEY_FORMAT_STRING, platformId, persistenceValueKey )

	#if UI
	return GetPersistentVarAsInt( persistenceKey )
	#endif

	return player.GetPersistentVarAsInt( persistenceKey )
}

bool function RankedTrials_PlayerHasAssignedTrial( entity player )
{
	if ( GetConVarBool( CONVAR_KILL_SWITCH ) )
		return false

	string platformId = GetMergedPlatformIdForPlayer( player )
	#if UI
	int guid = GetPersistentVarAsInt( format( PERSISTENCE_KEY_FORMAT_STRING, platformId, PERSISTENCE_KEY_GUID ) )
	#else
	int guid = player.GetPersistentVarAsInt( format( PERSISTENCE_KEY_FORMAT_STRING, platformId, PERSISTENCE_KEY_GUID ) )
	#endif

	return ( IsValidItemFlavorGUID( guid, eValidation.DONT_ASSERT ) )
}

ItemFlavor function RankedTrials_GetAssignedTrial( entity player )
{
	string platformId = GetMergedPlatformIdForPlayer( player )
	#if UI
	int guid = GetPersistentVarAsInt( format( PERSISTENCE_KEY_FORMAT_STRING, platformId, PERSISTENCE_KEY_GUID ) )
	#else
	int guid = player.GetPersistentVarAsInt( format( PERSISTENCE_KEY_FORMAT_STRING, platformId, PERSISTENCE_KEY_GUID ) )
	#endif

	Assert( IsValidItemFlavorGUID( guid, eValidation.ASSERT ) )
	return GetItemFlavorByGUID( guid )
}

int function RankedTrials_GetNetLP( entity player )
{
	return _GetPersistenceData( player, PERSISTENCE_KEY_NET_LP_DURING_TRIAL )
}

int function RankedTrials_GetSecondaryStatMatchComboStatProgress( entity player )
{
	return _GetPersistenceData( player, PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_COMBO )
}

int function RankedTrials_GetGamesPlayedInTrialsState( entity player )
{
	return _GetPersistenceData( player, PERSISTENCE_KEY_GAMES_IN_TRIAL_STATE )
}

int function RankedTrials_GetGamesAllowedInTrialsState( entity player, ItemFlavor rankedTrial )
{
	int timesFailed  = _GetPersistenceData( player, PERSISTENCE_KEY_TIMES_FAILED_TRIAL )
	int matchCount   = RankedTrials_GetTrialMatchCount( rankedTrial )

	return minint( ( timesFailed + matchCount ), RankedTrials_GetTrialMaxMatchCount( rankedTrial ) )
}

int function RankedTrials_GetTimesFailedTrial( entity player )
{
	return _GetPersistenceData( player, PERSISTENCE_KEY_TIMES_FAILED_TRIAL )
}

int function RankedTrials_GetTrialState( entity player )
{
	int state = _GetPersistenceData( player, PERSISTENCE_KEY_TRIAL_STATE )
	Assert( state >= 0 && state < eRankedTrialState.COUNT )
	return state
}

bool function RankedTrials_PlayerHasIncompleteTrial( entity player )
{
	return RankedTrials_PlayerHasAssignedTrial( player ) && RankedTrials_GetTrialState( player ) == eRankedTrialState.INCOMPLETE
}

#if CLIENT || UI
bool function RankedTrials_NextRankHasTrial( SharedRankedDivisionData currentDivision, SharedRankedDivisionData ornull nextDivision )
{
	if ( nextDivision != null )
	{
		expect SharedRankedDivisionData( nextDivision )
		return currentDivision.tier != nextDivision.tier
	}
	return false
}
#endif

int function RankedTrials_GetProgressValueForStatByIndex( entity player, int statIdx )
{
	switch ( statIdx )
	{
		case eRankedTrialGoalIdx.PRIMARY:
			return _GetPersistenceData( player, PERSISTENCE_KEY_PRIMARY_STAT_PROGRESS )

		case eRankedTrialGoalIdx.SECONDARY_ONE:
			return _GetPersistenceData( player, PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_ONE )

		case eRankedTrialGoalIdx.SECONDARY_TWO:
			return _GetPersistenceData( player, PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_TWO )
	}
	Assert( false )
	unreachable
}

#if SERVER
void function _SetPersistenceDataByXMergePlatform( entity player, string persistenceValueKey, string platformId, int valToSet )
{
	Assert( PERSISTENCE_KEYS.contains( persistenceValueKey ) )
	string persistenceKey = format( PERSISTENCE_KEY_FORMAT_STRING, platformId, persistenceValueKey )
	player.SetPersistentVar( persistenceKey, valToSet )
}

void function _SetPersistenceData( entity player, string persistenceValueKey, int valToSet )
{
	Assert( PERSISTENCE_KEYS.contains( persistenceValueKey ) )
	string platformId = GetMergedPlatformIdForPlayer( player )
	_SetPersistenceDataByXMergePlatform( player, persistenceValueKey, platformId, valToSet )
}

void function _InitializePersistenceData( entity player, bool resetTimesFailedTrials )
{
	#if DEVELOPER
		Assert( PERSISTENCE_KEYS[ PERSISTENCE_KEYS.len() - 1 ] == PERSISTENCE_KEY_TIMES_FAILED_TRIAL )
	#endif

	int failedTrialsIdx = PERSISTENCE_KEYS.len() - 1
	foreach( int idx, string key in PERSISTENCE_KEYS )
	{
		if ( !resetTimesFailedTrials && idx == failedTrialsIdx )
			break

		_SetPersistenceData( player, key, 0 )
	}
}

void function RankedTrials_ResetXMergePlatformPersistenceData( entity player, string platformId )
{
	foreach ( int idx, string key in PERSISTENCE_KEYS )
		_SetPersistenceDataByXMergePlatform( player, key, platformId, 0 )
}

void function RankedTrials_SaveMatchLP( entity player, int matchLP )
{
	int currentNetLP = RankedTrials_GetNetLP( player )
	int newLP = currentNetLP + matchLP

	_SetPersistenceData( player, PERSISTENCE_KEY_NET_LP_DURING_TRIAL, newLP )
}

void function _IncrementMatchComboStatProgress( entity player )
{
	int currentComboStatProgress = RankedTrials_GetSecondaryStatMatchComboStatProgress( player )

	_SetPersistenceData( player, PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_COMBO, currentComboStatProgress + 1 )
}

void function _IncrementGamesPlayedInTrialsState( entity player )
{
	int currentGamesPlayedCount = RankedTrials_GetGamesPlayedInTrialsState( player )

	_SetPersistenceData( player, PERSISTENCE_KEY_GAMES_IN_TRIAL_STATE, currentGamesPlayedCount + 1 )
}

void function _IncrementTimesFailedTrial( entity player )
{
	int currentTimesFailedTrial = RankedTrials_GetTimesFailedTrial( player )

	_SetPersistenceData( player, PERSISTENCE_KEY_TIMES_FAILED_TRIAL, currentTimesFailedTrial + 1 )
}

void function _UpdateProgressValueForStatByIndex( entity player, int statIdx, int newVal )
{
	switch ( statIdx )
	{
		case eRankedTrialGoalIdx.PRIMARY:
			_SetPersistenceData( player, PERSISTENCE_KEY_PRIMARY_STAT_PROGRESS, newVal )
			break

		case eRankedTrialGoalIdx.SECONDARY_ONE:
			_SetPersistenceData( player, PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_ONE, newVal )
			break

		case eRankedTrialGoalIdx.SECONDARY_TWO:
			_SetPersistenceData( player, PERSISTENCE_KEY_SECONDARY_STAT_PROGRESS_TWO, newVal )
			break

		default:
			Assert( false )
	}
}

void function _UpdateTrialState( entity player, int state )
{
	Assert( state >= 0 && state < eRankedTrialState.COUNT )
	_SetPersistenceData( player, PERSISTENCE_KEY_TRIAL_STATE, state )
}
#endif // #if SERVER
// End Persistence Accessors

#if SERVER
void function RankedTrials_OnPlayerConnected( entity player, bool isReconnecting )
{
	if ( GetConVarBool( CONVAR_KILL_SWITCH ) )
		return

	Assert( !IsLobby() )
	Assert( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )

	if ( !RankedTrials_PlayerHasAssignedTrial( player ) )
		return

	Assert( ( !isReconnecting && !player.p.hasRankedTrialsStatsCallbacksAdded ) || isReconnecting )
	if ( isReconnecting && player.p.hasRankedTrialsStatsCallbacksAdded )
		return

	// RESET Trial Completion due Success or Failure based on *PREVIOUS* Match. We store state and keep data in the Lobby so UI can use it.
	if ( RankedTrials_GetTrialState( player ) == eRankedTrialState.SUCCESS || RankedTrials_GetTrialState( player ) == eRankedTrialState.FAILURE )
	{
		bool shouldResetFailures = ( RankedTrials_GetTrialState( player ) == eRankedTrialState.SUCCESS )
		_RemoveTrial( player, shouldResetFailures )
		return
	}

	Assert( RankedTrials_GetTrialState( player ) == eRankedTrialState.INCOMPLETE )
	ItemFlavor assignedTrialForPlatform = RankedTrials_GetAssignedTrial( player )

	foreach ( string enumKey, int statIdx in eRankedTrialGoalIdx )
	{
		if ( !_IsValidTrialStatEntryIndex( assignedTrialForPlatform, statIdx ) )
			break

		StatEntry statEntry = RankedTrials_GetTrialStatEntryByIndex( assignedTrialForPlatform, statIdx )
		AddCallback_StatChanged_Int( player, statEntry, void function( entity player, int oldValue, int newValue ) : ( statEntry ) {
				Callback_OnStatChanged_Int( player, statEntry, oldValue, newValue )
		} )
	}
	player.p.hasRankedTrialsStatsCallbacksAdded = true
}

int function RankedTrials_UpdateTrialCompletion( entity player, ItemFlavor rankedTrial )
{
	#if DEVELOPER
		if ( DEV_FORCE_COMPLETION_STATUS != -1 )
			return DEV_FORCE_COMPLETION_STATUS
	#endif

	Assert( !GetConVarBool( CONVAR_KILL_SWITCH ) )
	Assert( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) && player.p.placementStatsRecorded )
	Assert( RankedTrials_GetAssignedTrial( player ) == rankedTrial )
	Assert( RankedTrials_GetTrialState( player ) == eRankedTrialState.INCOMPLETE )

	_IncrementGamesPlayedInTrialsState( player )

	int trialState = eRankedTrialState.INCOMPLETE
	if ( RankedTrials_GetProgressValueForStatByIndex( player, eRankedTrialGoalIdx.PRIMARY ) >= RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.PRIMARY ) )
	{
		trialState = eRankedTrialState.SUCCESS // completed Primary
	}
	else if ( RankedTrials_HasSecondaryTrial( rankedTrial ) )
	{
		if ( !RankedTrials_SecondaryTrialRequiresSingleMatchPerformance( rankedTrial ) )
		 {
			 bool success = RankedTrials_GetProgressValueForStatByIndex( player, eRankedTrialGoalIdx.SECONDARY_ONE ) >= RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_ONE )
			 if ( RankedTrials_HasDualStatSecondaryTrial( rankedTrial ) )
				 success = success && RankedTrials_GetProgressValueForStatByIndex( player, eRankedTrialGoalIdx.SECONDARY_TWO ) >= RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_TWO )

			 if ( success )
				 trialState = eRankedTrialState.SUCCESS // completed Secondary
		 }
		 else // calculate whether they match the single-match requirement for the secondary stat(s)
		 {
			 StatEntry stat  = RankedTrials_GetTrialStatEntryByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_ONE )
			 int statValSOM  = GetStat_Int( player, stat, eStatGetWhen.START_OF_CURRENT_MATCH )
			 int statValEOM  = GetStat_Int( player, stat, eStatGetWhen.CURRENT )
			 bool didSucceed = ((statValEOM - statValSOM) >= RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_ONE ))

			 if ( RankedTrials_HasDualStatSecondaryTrial( rankedTrial ) )
			 {
				 stat       = RankedTrials_GetTrialStatEntryByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_TWO )
				 statValSOM = GetStat_Int( player, stat, eStatGetWhen.START_OF_CURRENT_MATCH )
				 statValEOM = GetStat_Int( player, stat, eStatGetWhen.CURRENT )
				 didSucceed = didSucceed && ((statValEOM - statValSOM) >= RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_TWO ))
			 }

			 if ( didSucceed )
				 _IncrementMatchComboStatProgress( player )

			 if ( RankedTrials_GetSecondaryStatMatchComboStatProgress( player ) >= RankedTrials_GetSecondaryTrialSingleMatchComboCount( rankedTrial ) )
				 trialState = eRankedTrialState.SUCCESS // completed Secondary combo
		 }
	}

	if ( trialState != eRankedTrialState.SUCCESS && RankedTrials_GetGamesPlayedInTrialsState( player ) >= RankedTrials_GetGamesAllowedInTrialsState( player, rankedTrial ) )
	{
		trialState = eRankedTrialState.FAILURE
		_IncrementTimesFailedTrial( player )
	}

	Assert( trialState != eRankedTrialState.NOT_IN_TRIAL && trialState < eRankedTrialState.COUNT )
	_UpdateTrialState( player, trialState )
	return trialState
}

void function RankedTrials_AssignTrial( entity player, int tierToProgressTo )
{
	Assert( tierToProgressTo >= 0 && tierToProgressTo < TIER_ORDERING_BY_LOC_KEY.len() )
	// regular Ranked script should check if player is ready to change Tiers and, if so, call this
	_InitializePersistenceData( player, false )
	ItemFlavor rankedTrial = RankedTrials_GetTrialToEnterTier( TIER_ORDERING_BY_LOC_KEY[ tierToProgressTo ] )
	_SetPersistenceData( player, PERSISTENCE_KEY_GUID, ItemFlavor_GetGUID( rankedTrial ) )
	_SetPersistenceData( player, PERSISTENCE_KEY_TRIAL_STATE, eRankedTrialState.INCOMPLETE )
}

void function _RemoveTrial( entity player, bool resetTimesFailedTrials )
{
	_InitializePersistenceData( player, resetTimesFailedTrials )
}

bool function RankedTrials_PlayerShouldBePlacedIntoTrialForTier( entity player, int tierIdx )
{
	if ( GetConVarBool( CONVAR_KILL_SWITCH ) )
		return false

	if ( !( TIER_ORDERING_BY_LOC_KEY[ tierIdx ] in file.rankedTierToTrialMap ) )
		return false

	if ( !Ranked_HasCompletedProvisionalMatches( player ) || ( Ranked_GetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_HAS_PROGRESSED_OUT_PERSISTENCE_VAR_NAME ) == 0 ) )
		return false

	return true
}

void function Callback_OnStatChanged_Int( entity player, StatEntry statEntry, int oldValue, int newValue )
{
	if ( GetConVarBool( CONVAR_KILL_SWITCH ) )
		return

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED ) )
	{
		Assert( false, "Ranked Trials: trial stats updated outside of a Ranked match." )
		return
	}

	Assert( RankedTrials_PlayerHasAssignedTrial( player ) )
	ItemFlavor assignedTrialForPlatform = RankedTrials_GetAssignedTrial( player )

	int statIdxToUpdate = -1
	foreach ( string enumKey, int statIdx in eRankedTrialGoalIdx )
	{
		StatEntry trialStatEntry = RankedTrials_GetTrialStatEntryByIndex( assignedTrialForPlatform, statIdx )
		if ( statEntry == trialStatEntry )
		{
			statIdxToUpdate = statIdx
			break
		}
	}
	Assert( statIdxToUpdate != -1 )

	// for single match, diff with SOPM and only update once they meet the threshold
	if ( statIdxToUpdate > eRankedTrialGoalIdx.PRIMARY && RankedTrials_SecondaryTrialRequiresSingleMatchPerformance( assignedTrialForPlatform ) )
	{
		return // only calculate combo results at match end
	}
	else // otherwise, tick the stat
	{
		int currProgressValue = RankedTrials_GetProgressValueForStatByIndex( player, statIdxToUpdate )
		currProgressValue += ( newValue - oldValue )
		_UpdateProgressValueForStatByIndex( player, statIdxToUpdate, currProgressValue )
	}
}
#endif // #if SERVER

#if DEVELOPER
bool function DEV_CheckPlaylistOverrides()
{
	if ( !GetCurrentPlaylistVarBool( DEV_RUN_PLAYLIST_OVERRIDE_CHECK, false ) )
		return true

	/* // Playlist Overrides for Ranked Trial: replace SAID01753960760 with Asset SAID
	ranked_trials_SAID01753960760_matchCount 1
	ranked_trials_SAID01753960760_matchCountMax 1
	ranked_trials_SAID01753960760_bonusLPGain 1
	ranked_trials_SAID01753960760_maxLPLoss 1
	ranked_trials_SAID01753960760_goalVal 1
	ranked_trials_SAID01753960760_statRef "stats.placements_win"
	ranked_trials_SAID01753960760_singleMatch 1 // bool
	ranked_trials_SAID01753960760_singleMatchComboCount 1
	ranked_trials_SAID01753960760_goalValAltOne 1
	ranked_trials_SAID01753960760_statRefAltOne "stats.placements_win"
	ranked_trials_SAID01753960760_goalValAltTwo 1
	ranked_trials_SAID01753960760_statRefAltTwo "stats.placements_win" // can be empty string --> disables secondary_two stat
	*/

	foreach ( string _, int rankedTrialGUID in file.rankedTierToTrialMap )
	{
		ItemFlavor rankedTrial = GetItemFlavorByGUID( rankedTrialGUID )
		printf( "RANKED_TRIALS_DBG: listing playlist overrides for Ranked Trial %s", ItemFlavor_GetGUIDString( rankedTrial ) )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialMatchCount: %d", RankedTrials_GetTrialMatchCount( rankedTrial ) )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialMaxMatchCount: %d", RankedTrials_GetTrialMaxMatchCount( rankedTrial ) )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialBonusLPGain: %d", RankedTrials_GetTrialBonusLPGain( rankedTrial ) )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialMaxLPLoss: %d", RankedTrials_GetTrialMaxLPLoss( rankedTrial ) )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_SecondaryTrialRequiresSingleMatchPerformance: %s", RankedTrials_SecondaryTrialRequiresSingleMatchPerformance( rankedTrial ) ? "true" : "false" )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetSecondaryTrialSingleMatchComboCount: %d", RankedTrials_SecondaryTrialRequiresSingleMatchPerformance( rankedTrial ) ? RankedTrials_GetSecondaryTrialSingleMatchComboCount( rankedTrial ) : -1 )

		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialStatGoalByIndex | PRIMARY: %d", RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.PRIMARY ) )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialStatGoalByIndex | SECONDARY_ONE: %d", RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_ONE ) )
		if ( RankedTrials_HasDualStatSecondaryTrial( rankedTrial ) )
			printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialStatGoalByIndex | SECONDARY_TWO: %d", RankedTrials_GetTrialStatGoalByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_TWO ) )

		StatEntry stat = RankedTrials_GetTrialStatEntryByIndex( rankedTrial, eRankedTrialGoalIdx.PRIMARY )
		printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialStatEntryByIndex | PRIMARY: %s", stat.persistenceFullKey_Current )
		if ( RankedTrials_HasSecondaryTrial( rankedTrial ) )
		{
			stat = RankedTrials_GetTrialStatEntryByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_ONE )
			printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialStatEntryByIndex | SECONDARY_ONE: %s", stat.persistenceFullKey_Current )
			if ( RankedTrials_HasDualStatSecondaryTrial( rankedTrial ) )
			{
				stat = RankedTrials_GetTrialStatEntryByIndex( rankedTrial, eRankedTrialGoalIdx.SECONDARY_TWO )
				printf( "RANKED_TRIALS_DBG: playlist override - RankedTrials_GetTrialStatEntryByIndex | SECONDARY_TWO: %s", stat.persistenceFullKey_Current )
			}
		}
	}

	if ( file.rankedTierToTrialMap.len() == 0 )
		printt( "RANKED_TRIALS_DBG: rankedTierToTrialMap is empty!" )

	if ( file.trialStatRefCache.len() == 0 )
		printt( "RANKED_TRIALS_DBG: trialStatRefCache is empty!" )

	return true
}

#if SERVER
void function DEV_TrialsUnitTest()
{
	foreach ( ItemFlavor trial in clone GetAllItemFlavorsOfType( eItemType.ranked_trial ) )
	{
		foreach ( string enumKey, int statIdx in eRankedTrialGoalIdx )
		{
			if ( !_IsValidTrialStatEntryIndex( trial, statIdx ) )
				break

			StatEntry statEntry = RankedTrials_GetTrialStatEntryByIndex( trial, statIdx )
			AddCallback_StatChanged_Int( GP(), statEntry, void function( entity player, int oldValue, int newValue ) : ( statEntry ) {
				Callback_OnStatChanged_Int( player, statEntry, oldValue, newValue )
			} )
		}
	}
}
#endif // #if SERVER
#endif // #if DEVELOPER
