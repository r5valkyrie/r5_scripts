global function SV_RankedGRX_Init
global function Ranked_CalculateBadgeAwardLevelStat
global function Ranked_GiveRankedSeasonRewards
global function ClientCallback_rankedPeriodRewardAcknowledged

global enum sharedRankedBadgeAwardLevel
{
	// GLOBAL only while Arenas uses
	// DUPLICATED IN RUI SCRIPT
	BRONZE_STATIC,
	BRONZE_ANIMATED,
	SILVER_STATIC,
	SILVER_ANIMATED,
	GOLD_STATIC,
	GOLD_ANIMATED,
	PLATINUM_STATIC,
	PLATINUM_ANIMATED,
	DIAMOND_STATIC,
	DIAMOND_ANIMATED,
	MASTER_STATIC,
	MASTER_ANIMATED,
	APEX_STATIC,
	APEX_ANIMATED,
	ROOKIE,
	NONE,
}

enum eRankedBadgeAwardLevelGRX
{
	// DUPLICATED IN RUI SCRIPT
	NONE              = -1, // does NOT get reward
	ROOKIE            = 0, // does NOT get reward
	BRONZE_STATIC     = 10,
	BRONZE_ANIMATED   = 20,
	SILVER_STATIC     = 30,
	SILVER_ANIMATED   = 40,
	GOLD_STATIC       = 50,
	GOLD_ANIMATED     = 60,
	PLATINUM_STATIC   = 70,
	PLATINUM_ANIMATED = 80,
	DIAMOND_STATIC    = 90,
	DIAMOND_ANIMATED  = 100,
	MASTER_STATIC     = 110,
	MASTER_ANIMATED   = 120,
	APEX_STATIC       = 1000,
	APEX_ANIMATED     = 2000,
}

enum eDivision
{
	// DUPLICATED IN RUI SCRIPT
	DIVISION_IV  = 0,
	DIVISION_III = 1,
	DIVISION_II  = 2,
	DIVISION_I   = 3,
}

const string EMBLEM_IV  = "#RANKED_DIVISION_IV"
const string EMBLEM_III = "#RANKED_DIVISION_III"
const string EMBLEM_II  = "#RANKED_DIVISION_II"
const string EMBLEM_I   = "#RANKED_DIVISION_I"
// "SHOW_RP" // MASTERS
// LADDER_POSITION" // PRED
// "NONE" // NONE

struct
{
	table<string, int> rankedTierNamesToBadgeAwardStaticLevelTable
	table<string, int> rankedTierNamesToBadgeAwardAnimatedLevelTable
	table<string, int> rankedDivisionNameToID
	table<int, int> rankedBadgeStatLevelToGRXTier
	table< entity, bool > rankedPlayerGRXStateIsUpdated
} file


void function SV_RankedGRX_Init()
{
	AddCallback_QueueServersideScriptGRXOperations( Ranked_GiveRankedSeasonRewards )
	Ranked_InitRankedTierNamesToBadgeAwardsLevelTable()
	AddCallback_OnClientDisconnected( Ranked_GRX_OnPlayerDisconnected )
}


// TODO: convert to use a datatable - share datatable with sh_ranked
void function Ranked_InitRankedTierNamesToBadgeAwardsLevelTable()
{
	//Hard coded, but this should be fine to be constant across Ranked Periods; even if we change the rank tier structure by adding tiers etc we're not going to be changing names to not mean the same thing etc.
	//Unranked has no Badges
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_ROOKIE"  ] <- sharedRankedBadgeAwardLevel.ROOKIE
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_BRONZE"  ] <- sharedRankedBadgeAwardLevel.BRONZE_STATIC
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_SILVER"  ] <- sharedRankedBadgeAwardLevel.SILVER_STATIC
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_GOLD"  ] <- sharedRankedBadgeAwardLevel.GOLD_STATIC
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_PLATINUM"  ] <- sharedRankedBadgeAwardLevel.PLATINUM_STATIC
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_DIAMOND"  ] <- sharedRankedBadgeAwardLevel.DIAMOND_STATIC
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_MASTER"  ] <- sharedRankedBadgeAwardLevel.MASTER_STATIC
	file.rankedTierNamesToBadgeAwardStaticLevelTable[ "#RANKED_TIER_APEX_PREDATOR"  ] <- sharedRankedBadgeAwardLevel.APEX_STATIC

	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_ROOKIE"  ] <- sharedRankedBadgeAwardLevel.ROOKIE
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_BRONZE"  ] <- sharedRankedBadgeAwardLevel.BRONZE_ANIMATED
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_SILVER"  ] <- sharedRankedBadgeAwardLevel.SILVER_ANIMATED
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_GOLD"  ] <- sharedRankedBadgeAwardLevel.GOLD_ANIMATED
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_PLATINUM"  ] <- sharedRankedBadgeAwardLevel.PLATINUM_ANIMATED
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_DIAMOND"  ] <- sharedRankedBadgeAwardLevel.DIAMOND_ANIMATED
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_MASTER"  ] <- sharedRankedBadgeAwardLevel.MASTER_ANIMATED
	file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ "#RANKED_TIER_APEX_PREDATOR"  ] <- sharedRankedBadgeAwardLevel.APEX_ANIMATED

	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.NONE ] <- eRankedBadgeAwardLevelGRX.NONE
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.ROOKIE ] <- eRankedBadgeAwardLevelGRX.ROOKIE
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.BRONZE_STATIC ] <- eRankedBadgeAwardLevelGRX.BRONZE_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.BRONZE_ANIMATED ] <- eRankedBadgeAwardLevelGRX.BRONZE_ANIMATED
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.SILVER_STATIC ] <- eRankedBadgeAwardLevelGRX.SILVER_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.SILVER_ANIMATED ] <- eRankedBadgeAwardLevelGRX.SILVER_ANIMATED
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.GOLD_STATIC ] <- eRankedBadgeAwardLevelGRX.GOLD_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.GOLD_ANIMATED ] <- eRankedBadgeAwardLevelGRX.GOLD_ANIMATED
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.PLATINUM_STATIC ] <- eRankedBadgeAwardLevelGRX.PLATINUM_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.PLATINUM_ANIMATED ] <- eRankedBadgeAwardLevelGRX.PLATINUM_ANIMATED
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.DIAMOND_STATIC ] <- eRankedBadgeAwardLevelGRX.DIAMOND_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.DIAMOND_ANIMATED ] <- eRankedBadgeAwardLevelGRX.DIAMOND_ANIMATED
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.MASTER_STATIC ] <- eRankedBadgeAwardLevelGRX.MASTER_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.MASTER_ANIMATED ] <- eRankedBadgeAwardLevelGRX.MASTER_ANIMATED
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.APEX_STATIC ] <- eRankedBadgeAwardLevelGRX.APEX_STATIC
	file.rankedBadgeStatLevelToGRXTier[ sharedRankedBadgeAwardLevel.APEX_ANIMATED ] <- eRankedBadgeAwardLevelGRX.APEX_ANIMATED

	file.rankedDivisionNameToID[ EMBLEM_IV ] <- eDivision.DIVISION_IV
	file.rankedDivisionNameToID[ EMBLEM_III ] <- eDivision.DIVISION_III
	file.rankedDivisionNameToID[ EMBLEM_II ] <- eDivision.DIVISION_II
	file.rankedDivisionNameToID[ EMBLEM_I ] <- eDivision.DIVISION_I
}


int function Ranked_CalculateBadgeAwardLevelStat( entity player, int rankedScore, ItemFlavor rankedPeriod, bool isFirstSplit )
{
	//Note: Make switch statement based on Ranked Period if we change rank tier structure post Ranked Season 04
	string rankedPeriodGUIDString        = ItemFlavor_GetGUIDString( rankedPeriod )
	int ladderPosition                   = Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUIDString, isFirstSplit )

	//Is this ranked period rewarded by highests tier?
	var settingBlockForPeriod = ItemFlavor_GetSettingsBlock ( rankedPeriod )
	bool rewardOnHighestWatermark = GetSettingsBlockBool ( settingBlockForPeriod , "rewardOnHighestWatermark" )

	if ( rewardOnHighestWatermark )
	{
		if ( isFirstSplit )
			rankedScore = Ranked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUIDString , true )
		else
			rankedScore = Ranked_GetHistoricalRankScore( player, rankedPeriodGUIDString , true )
	}

	SharedRankedTierData splitRankedTier = Ranked_GetHistoricalRankedDivisionFromScoreAndLadderPosition( rankedScore, ladderPosition, rankedPeriodGUIDString ).tier

	string tierName = splitRankedTier.name
	Assert( tierName in file.rankedTierNamesToBadgeAwardStaticLevelTable && tierName in file.rankedTierNamesToBadgeAwardAnimatedLevelTable )

	// Ranked 2.0 Periods *only* give *animated* badges
	if ( ItemFlavor_GetType( rankedPeriod ) == eItemType.ranked_2pt0_period )
		return file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ tierName ]

	if ( !SharedRankedPeriod_HasSplits( rankedPeriod ) || isFirstSplit )
		return file.rankedTierNamesToBadgeAwardStaticLevelTable[ tierName ]

	if ( SharedRankedPeriod_HasSplits( rankedPeriod ) && (!isFirstSplit) ) //Technically this is just the else part of the earlier ( !RankedPeriod_HasSplits( rankedPeriod ) || !isSecondSplit ) check but doing it explicitly
	{
		int previousRankedScore                   = Ranked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUIDString, rewardOnHighestWatermark  )
		int firstSplitLadderPosition              = Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUIDString, true )
		SharedRankedTierData firstSplitRankedTier = Ranked_GetHistoricalRankedDivisionFromScoreAndLadderPosition( previousRankedScore, firstSplitLadderPosition, rankedPeriodGUIDString ).tier
		if ( firstSplitRankedTier == splitRankedTier )
		{
			Assert( tierName in file.rankedTierNamesToBadgeAwardAnimatedLevelTable )
			return file.rankedTierNamesToBadgeAwardAnimatedLevelTable[ tierName ]
		}
		else
		{
			SharedRankedTierData higherTierAchieved = Ranked_GetHigherOfTwoTiers( firstSplitRankedTier, splitRankedTier )
			Assert( higherTierAchieved.name in file.rankedTierNamesToBadgeAwardStaticLevelTable )
			return file.rankedTierNamesToBadgeAwardStaticLevelTable[ higherTierAchieved.name ]
		}
	}

	unreachable
}


int function Ranked_CalculateBadgeAwardGRXTier( entity player, ItemFlavor rankedPeriod )
{
	// This logic is reversed in *RUI Script*; changes made here must be reflected there
	string rankedPeriodGUIDString = ItemFlavor_GetGUIDString( rankedPeriod )
	bool hasSplits 				  = SharedRankedPeriod_HasSplits( rankedPeriod )
	int splitLadderPosition       = hasSplits ? Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUIDString, true ) : SHARED_RANKED_INVALID_LADDER_POSITION
	int endLadderPosition         = Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUIDString, false )

	// we want the badge to always reflect highest division / position achieved
	var settingBlockForPeriod     = ItemFlavor_GetSettingsBlock ( rankedPeriod )
	bool rewardOnHighestWatermark = GetSettingsBlockBool ( settingBlockForPeriod , "rewardOnHighestWatermark" )
	int splitRankedScore     	  = hasSplits ? Ranked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUIDString, rewardOnHighestWatermark ) : SHARED_RANKED_INVALID_RANK_SCORE
	int endRankedScore    		  = Ranked_GetHistoricalRankScore ( player, rankedPeriodGUIDString, rewardOnHighestWatermark )

	// score: higher is better
	int highRankedScore = maxint( splitRankedScore, endRankedScore )
	// ladder: lower is better, BUT only if it's > 0
	Assert( splitLadderPosition != 0 && endLadderPosition != 0 ) // we know this *can* happen in Live even though it shouldn't
	int highLadderPosition = SHARED_RANKED_INVALID_LADDER_POSITION
	if ( splitLadderPosition > 0 && endLadderPosition <= 0 ) // if only split ladder pos is valid - check <= 0 for safety
		highLadderPosition = splitLadderPosition // take split
	else if ( splitLadderPosition <= 0 && endLadderPosition > 0 ) // else if only end ladder pos is valid - check <= 0 for safety
		highLadderPosition = endLadderPosition // take end
	else if ( splitLadderPosition > 0 && endLadderPosition > 0 ) // else if both are valid
		highLadderPosition = minint( splitLadderPosition, endLadderPosition ) // take the lower of the two

	SharedRankedDivisionData divData = Ranked_GetHistoricalRankedDivisionFromScoreAndLadderPosition( highRankedScore, highLadderPosition, rankedPeriodGUIDString )

	int statVal = GetStat_Int( player, ResolveStatEntry( CAREER_STATS.rankedperiod_badge_award_level, rankedPeriodGUIDString ) )
	string emblemText = divData.emblemText

	Assert( statVal >= file.rankedTierNamesToBadgeAwardStaticLevelTable[ divData.tier.name ], "RankedGRX: GRX tier doesn't match badge stat." )

	int grxTier = 0
	if ( statVal != sharedRankedBadgeAwardLevel.ROOKIE && statVal != sharedRankedBadgeAwardLevel.NONE )
	{
		grxTier = file.rankedBadgeStatLevelToGRXTier[ statVal ]
		if ( statVal < sharedRankedBadgeAwardLevel.APEX_STATIC )
		{
			if ( emblemText in file.rankedDivisionNameToID )
				grxTier += file.rankedDivisionNameToID[ emblemText ]
		}
		else
		{
			grxTier += highLadderPosition
		}
	}

	return grxTier
}


SharedRankedTierData function Ranked_GetHistoricalTierForPlayerPeriod( entity player, ItemFlavor rankedPeriod )
{
	SharedRankedTierData historicalTier
	var settingBlockForPeriod = ItemFlavor_GetSettingsBlock ( rankedPeriod )
	bool rewardOnHighestWatermark = GetSettingsBlockBool ( settingBlockForPeriod , "rewardOnHighestWatermark" )
	string rankedPeriodGUID = ItemFlavor_GetGUIDString( rankedPeriod )

	if ( SharedRankedPeriod_HasSplits( rankedPeriod ) ) // we always take the higher of two splits, but *within a split*, may or may not reward on highest tier achieved
	{
		historicalTier = Ranked_GetHighestHistoricalTierAcrossSplitsForPlayer( player, rankedPeriod, rewardOnHighestWatermark )
	}
	else
	{
		int historicalRankedScore = Ranked_GetHistoricalRankScore( player, rankedPeriodGUID, rewardOnHighestWatermark )
		if ( !rewardOnHighestWatermark )
		{
			historicalTier = Ranked_GetHistoricalRankedDivisionFromScore( historicalRankedScore, rankedPeriodGUID ).tier
		}
		else
		{
			int historicalLadderScore = Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUID )
			historicalTier = Ranked_GetHistoricalRankedDivisionFromScoreAndLadderPosition( historicalRankedScore, historicalLadderScore, rankedPeriodGUID ).tier
		}
	}

	printf ("Ranked_GiveRankedSeasonRewards DEBUG: historical tier: " + historicalTier.name )
	return historicalTier
}


void function Ranked_GiveRankedSeasonRewards( entity player )
{
	printf ("Ranked_GiveRankedSeasonRewards DEBUG: Ranked_GiveRankedSeasonRewards " + player.GetPlayerName())
	#if DEV
		if ( DEV_ShouldIgnorePersistence() )
			return
	#endif

	//printt( "Ranked_GiveRankedSeasonRewards for player: " + player.GetPINPlatformId()  )
	if ( player in file.rankedPlayerGRXStateIsUpdated )
		return

	file.rankedPlayerGRXStateIsUpdated[ player ] <- true // we will only try this call once per visit to the Lobby

	/* A user who skips a season should get rewards when logging in *EXCEPT* for dive-trails. Those are only granted in the previous-to-current season
	 * E.g: player earns diamond in S5, skips S6, and logs in S7. They should NOT get the S5 dive trail, but should get other rewards
	 * **skydive trails are only given for season that ENDED when our CURRENT season BEGAN**
	 */
	ItemFlavor ornull activeRankedPeriod = Ranked_GetCurrentActiveRankedPeriod()
	if ( activeRankedPeriod == null )
		return // we're probably on an "old" server during rollover period. don't do any rewards on this server.

	// required to know which period to give Skydive trails for
	expect ItemFlavor( activeRankedPeriod )
	ItemFlavor ornull mostRecentClosedPeriod = GetPrecedingRankedPeriod( activeRankedPeriod )
	Assert( mostRecentClosedPeriod != null )
	expect ItemFlavor( mostRecentClosedPeriod )

	array<ItemFlavor> rankedPeriodList = Ranked_GetAllRankedPeriodsInAscendingChronologicalOrder()
	foreach ( ItemFlavor rankedPeriod in rankedPeriodList )
	{
		if ( rankedPeriod == activeRankedPeriod )
			break

		if ( Ranked_IsRankedV2FirstSplit( rankedPeriod ) )
			continue

		string rankedPeriodGUID = ItemFlavor_GetGUIDString( rankedPeriod )

		//If this player never played any ranked games at all in a season, we're not giving them any rewards, so just act as though they are acknowledged
		int numberOfRankedGames = GetStat_Int( player, ResolveStatEntry( CAREER_STATS.rankedperiod_games_played, rankedPeriodGUID ) )
		if ( numberOfRankedGames == 0 )
			continue

		if ( Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUID ) == 0 )
		{
			delete file.rankedPlayerGRXStateIsUpdated[ player ] // allow this to re-run if we get data from Stryder
			return // exit because we're still waiting for Stryder to confirm *some* data.
		}

		if ( !Ranked_PlayerDeservesRewardsInPeriod( player, rankedPeriodGUID ) )
			continue

		printt( "Ranked_GiveRankedSeasonRewards DEBUG: Giving Ranked Rewards for player: " + player.GetPINPlatformId() + " for rankedPeriod: " + string(ItemFlavor_GetAsset( rankedPeriod  ))  )

		SharedRankedTierData historicalTier = Ranked_GetHistoricalTierForPlayerPeriod( player, rankedPeriod )
		if ( historicalTier.index <= 0 && ItemFlavor_GetType( rankedPeriod ) == eItemType.calevent_rankedperiod && ( CompareRankedPeriodStartTime ( rankedPeriod , GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( RANKED_SEASON_13_GUIDSTRING ))) >= 0 ) )
			continue // Rookie was introduced in S13; If a player is in Rookie tier (index zero from S13 - S16), don't give them rewards.

		// always run through this to ensure we set the badge data regardless of rewards having been given
		bool hasRewardsToGive = false
		ItemFlavorBag rewardsBag
		foreach ( SharedRankedReward rewardStruct in historicalTier.rewards )
		{
			// Assert( rewardStruct.rewardAsset != $"", format( "Ranked period %s has a null asset in its reward struct.", rankedPeriodGUID ) )
			if ( rewardStruct.rewardAsset == $"" ) // is often the case when reward setup is behind schedule
				continue

			ItemFlavor rewardFlav = GetItemFlavorByAsset( rewardStruct.rewardAsset )
			if ( ItemFlavor_GetGRXMode( rewardFlav ) != eItemFlavorGRXMode.REGULAR )
			{
				#if ASSERTS
					if ( ItemFlavor_GetType( rankedPeriod ) == eItemType.ranked_2pt0_period )
						Assert( false , "Ranked 2.0 Periods should ONLY have GRX rewards." )
				#endif

				continue
			}

			if ( GRX_HasItem( player, ItemFlavor_GetGRXIndex( rewardFlav ) ) )
			{
				// Retry only if we have the default value from Marketplace; player may have disonnected before setting BUT we also may have corrected the data in Marketplace, so don't check against persistence here
				if ( ItemFlavor_GetType( rewardFlav ) == eItemType.gladiator_card_badge &&
						GRX_GetItemTier( player, ItemFlavor_GetGRXIndex( rewardFlav ) ) == 0 && // Marketplace Default
						historicalTier.index > 0 ) // Rookies SHOULD be tier == 0
					Ranked_GRX_SetBadgeTier( player, rewardFlav, rankedPeriod )

				continue
			}

			// don't award *trails* (only) EXCEPT for the season just prior to current
			if ( rankedPeriod != mostRecentClosedPeriod && ItemFlavor_GetType( rewardFlav ) == eItemType.skydive_trail )
				continue

			printf ("Ranked_GiveRankedSeasonRewards DEBUG: Adding to reward list: " + rewardStruct.previewName )
			rewardsBag.flavors.append( rewardFlav )
			rewardsBag.quantities.append( 1 )
			hasRewardsToGive = true
		}

		if ( !hasRewardsToGive )
			continue // continue on foreach ( ItemFlavor rankedPeriod in rankedPeriodList )

		string sequenceName = format( "rankedPeriodData[%s].rewardSeq", rankedPeriodGUID )
		if ( ItemFlavor_GetType( rankedPeriod ) == eItemType.calevent_rankedperiod )
			sequenceName = format( "allRankedData[%s].rewardSeq", rankedPeriodGUID )

		int sequenceCheckStartIndex = GRX_GetSequenceNumber( player, sequenceName )
		if ( sequenceCheckStartIndex > 0 )
			continue // continue on foreach ( ItemFlavor rankedPeriod in rankedPeriodList )

		ScriptGRXOperationInfo operation
		operation.expectedQueryGoal = GRX_HTTPQUERYGOAL_GIVE_RANKED_SEQUENCE_REWARD
		operation.doOperationFunc = (void function( int opID ) : ( player, sequenceName, sequenceCheckStartIndex, sequenceCheckStartIndex, rewardsBag )
		{
			GRX_GiveSequenceRewardEasy( player, opID, GRX_HTTPQUERYGOAL_GIVE_RANKED_SEQUENCE_REWARD, sequenceName, sequenceCheckStartIndex, 1, rewardsBag )
		})
		operation.onDoneCallback    = (void function( int status ) : ( player, rewardsBag, rankedPeriod ) {
			bool didOperationSucceed = (status == eScriptGRXOperationStatus.DONE_SUCCESS)
			if ( !didOperationSucceed )
				return

			foreach ( ItemFlavor reward in rewardsBag.flavors )
			{
				if ( ItemFlavor_GetType( reward ) == eItemType.gladiator_card_badge )
					Ranked_GRX_SetBadgeTier( player, reward, rankedPeriod )

				GRX_MarkAsNewIfAppropriate( player, reward )
			}
		})
		QueueGRXOperation( player, operation )

	} // foreach ( ItemFlavor rankedPeriod in rankedPeriodList )
}


void function Ranked_GRX_SetBadgeTier( entity player, ItemFlavor badge, ItemFlavor rankedPeriod )
{
	if ( !IsValid( player ) )
		return // this is often called from a GRX operation complete callback

	// make sure we're not accidentally trying to do this for an older non-GRX badge
	Assert( ItemFlavor_GetGRXMode( badge ) == eItemFlavorGRXMode.REGULAR )

	int badgeGRXTier = Ranked_CalculateBadgeAwardGRXTier( player, rankedPeriod )

	ScriptGRXOperationInfo operation
	operation.expectedQueryGoal = GRX_HTTPQUERYGOAL_UPDATE_ITEMS
	operation.doOperationFunc   = (void function( int opID ) : ( player, badge, badgeGRXTier )
	{
		GRX_SetItemTier( player, opID, ItemFlavor_GetGRXIndex( badge ), badgeGRXTier )
		printf ("Ranked_GRX_SetBadgeTier DEBUG: " + string(ItemFlavor_GetAsset( badge )) )
	})
	operation.onDoneCallback    = (void function( int status ) : ( player, badge ) {
		bool didOperationSucceed = (status == eScriptGRXOperationStatus.DONE_SUCCESS)
		if ( !didOperationSucceed )
			return

		GRX_MarkAsNewIfAppropriate( player, badge )
	})
	operation.DEV_goalInfo = ItemFlavor_GetGRXAlias( badge )
	QueueGRXOperation( player, operation, false )
}


void function ClientCallback_rankedPeriodRewardAcknowledged( entity player )
{
	if ( IsValid( player ) && player.IsPlayer() )
		player.SetPersistentVar( "rankedRewardsAcknowledged", true )
}


void function Ranked_GRX_OnPlayerDisconnected( entity player )
{
	if ( IsLobby() )
	{
		if ( player in file.rankedPlayerGRXStateIsUpdated )
			delete file.rankedPlayerGRXStateIsUpdated[ player ]
	}
}
 