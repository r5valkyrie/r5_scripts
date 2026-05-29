globalize_all_functions

#if SERVER && DEVELOPER
RankLadderPointsBreakdown function AdjustForQAPlaylistOverrides ( RankLadderPointsBreakdown breakdown, entity player )
{
	bool hasQAOverride = GetCurrentPlaylistVarBool ( "DEV_Ranked_QA_Override" , false )
	if ( hasQAOverride )
	{
		breakdown.finalLP = GetCurrentPlaylistVarInt ("DEV_Ranked_SetRP", breakdown.finalLP )
		SetDemotionProtectionBuffer ( player, GetCurrentPlaylistVarInt ("DEV_Ranked_SetDemotionProtection", GetDemotionProtectionBuffer( player )) )
	}
	return breakdown
}

void function DEV_PrintTiersAndDivisions ()
{
	array<SharedRankedTierData> tierData =  Ranked_GetTiers()
	array<SharedRankedDivisionData>  divisonData = GetCurrentRankedDivisions()



	foreach ( SharedRankedTierData d in tierData )
	{
		printf ( "--------------------------------------------" )
		printf ( "--name " + d.name)
		printf ( "--scoreMin " +d.scoreMin )
		printf ( "--index " + d.index)
		printf ( "--icon " + d.icon )
		printf ( "--iconRuiAsset " + d.iconRuiAsset)
		printf ( "--bgImage " + d.bgImage)
		printf ( "--glowImage " + d.glowImage)
		printf ( "--levelUpRuiAsset " + d.levelUpRuiAsset)
		printf ( "--promotionalMetallicImage " + d.promotionalMetallicImage )
		printf ( "--entryCost " + d.entryCost)
		printf ( "--maxProtection " + d.maxProtection)
		printf ( "--minProtection " + d.minProtection)
		printf ( "--allowsDemotion " + d.allowsDemotion)
		printf ( "--isTopEnd " + d.isTopEnd )
		printf ( "--lpDecayAmount " + d.lpDecayAmount )
		printf ( "--promotionAnnouncement " + d.promotionAnnouncement)
		printf ( "--isLadderOnlyTier" + d.isLadderOnlyTier)
	}
	printf ( "--------------------------------------------/n" )

	foreach ( SharedRankedDivisionData d in divisonData )
	{
		printf ( "--------------------------------------------" )
		printf ( "--divisionName " + d.divisionName )
		printf ( "--emblemText " + d.emblemText)
		printf ( "--tier " + d.tier.name )
		printf ( "--scoreMin " + d.scoreMin )
		printf ( "--index " + d.index )
		printf ( "--emblemDisplayMode " + d.emblemDisplayMode )
		printf ( "--isLadderOnlyDivision " + d.isLadderOnlyDivision )
		printf ( "--divisionEntryCost " + d.divisionEntryCost )
	}
	printf ( "--------------------------------------------/n" )

}

void function DEV_PrintRankScoreInCurrentPeriodForPlayer ( entity player )
{
	Assert( Ranked_GetCurrentActiveRankedPeriod() != null )
	ItemFlavor currentRankedPeriod = expect ItemFlavor( Ranked_GetCurrentActiveRankedPeriod() )
	string currentRankedPeriodGUID = ItemFlavor_GetGUIDString( currentRankedPeriod )

	printf ("Current Period GUID: " + currentRankedPeriodGUID + " - " + string(ItemFlavor_GetAsset (currentRankedPeriod)) )

	DEV_PrintRankScoreForPeriod ( player, currentRankedPeriod )
}


void function DEV_PrintRankScoreInPreviousPeriodForPlayer ( entity player )
{
	Assert( Ranked_GetCurrentActiveRankedPeriod() != null )
	ItemFlavor currentRankedPeriod = expect ItemFlavor( Ranked_GetCurrentActiveRankedPeriod() )
	string currentRankedPeriodGUID = ItemFlavor_GetGUIDString( currentRankedPeriod )
	printf ("Current Period GUID: " + currentRankedPeriodGUID + " - " + string(ItemFlavor_GetAsset (currentRankedPeriod)) )


	ItemFlavor  previousRankedPeriod = expect ItemFlavor ( GetPrecedingRankedPeriod( currentRankedPeriod ) )
	string previousPeriodGUID = ItemFlavor_GetGUIDString( previousRankedPeriod )

	printf ("Current Period GUID: " + previousPeriodGUID + " - " + string(ItemFlavor_GetAsset (previousRankedPeriod)) )

	DEV_PrintRankScoreForPeriod ( player, previousRankedPeriod )
}


void function DEV_PrintRankScoreForPeriod ( entity player, ItemFlavor currentRankedPeriod )
{
	string rankedPeriodGUID = ItemFlavor_GetGUIDString( currentRankedPeriod )
	int endfirstSplitRankedScore = Ranked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUID, false )
	int endfirstSplitHighScore = Ranked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUID, true )
	int currentRankedScore = Ranked_GetHistoricalRankScore ( player, rankedPeriodGUID, false )
	int currentHighScore = Ranked_GetHistoricalRankScore ( player, rankedPeriodGUID, true )

	printf ( "\tendfirstSplitRankedScore:" + endfirstSplitRankedScore )
	printf ( "\tendfirstSplitHighScore:" + endfirstSplitHighScore )
	printf ( "\tcurrentRankedScore:" + currentRankedScore )
	printf ( "\tcurrentHighScore:" + currentHighScore )
}


void function TestRankedPostGamePrep()
{

	entity player = GetPlayerArray()[0]
	SetDemotionProtectionBuffer ( player , DEMOTION_BUFFER_MAX )

	RankLadderPointsBreakdown breakdown

	int provisionalGameCount = 1

	breakdown.wasInProvisonalGame = ( provisionalGameCount < Ranked_GetNumProvisionalMatchesRequired() )
	breakdown.wasAbandoned        = false
	breakdown.lossForgiveness     = false
	breakdown.damage              = 123

	breakdown.knockdown       = 1
	breakdown.knockdownAssist = 1

	breakdown.kills         = 1
	breakdown.assists       = 1
	breakdown.participation = 1

	breakdown.killsUnique         = 0
	breakdown.assistUnique        = 0
	breakdown.participationUnique = 0

	breakdown.placement      = 2
	player.SetPersistentVar( "lastGameRank" ,breakdown.placement )
	breakdown.placementScore = Ranked_GetPointsForPlacement ( breakdown.placement )

	breakdown.killBonus             = 0
	breakdown.convergenceBonus      = 0
	breakdown.skillDiffBonus        = 0
	breakdown.provisionalMatchBonus = 0

	breakdown.promotionBonus = 0
	breakdown.demotionPenality = 0
	breakdown.penaltyPointsForAbandoning = 0
	breakdown.demotionProtectionAdjustment = 0
	breakdown.lossProtectionAdjustment = 0


	//output
	breakdown.startingLP = 1337
	//breakdown.netLP     //these needs to be validated by script
	//breakdown.finalL


	DEV_script_ranked_debug ( "TestRankedPostGamePrep() start "  )
	breakdown = RedistributeBonuses (breakdown,player)
	breakdown = ValidateAndRecalculateBreakdown (breakdown)

	breakdown = AdjustForDemotion ( breakdown, player )
	breakdown = AdjustForTierPromotion( breakdown, player )

	if( GetConVarBool( "script_ranked_debug" ) )
	{
		PrintRankLadderPointsBreakdown ( breakdown )
	}

	TestRankedPostGame( breakdown , provisionalGameCount )
}





void function TestRankedPostGame( RankLadderPointsBreakdown breakdown, int provisionalGameCount = 11)
{
	foreach ( entity player in GetPlayerArray() )
	{
		Assert( ! (breakdown.lossForgiveness && breakdown.wasAbandoned) ) //Can't be marked as abandon AND be forgiven for it

		Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, provisionalGameCount )
		WritePlayerPostgameResultInPersistence ( player, breakdown )

		if ( breakdown.wasAbandoned )
		{
			SharedRanked_SetMatchmakingDelayDuration( player )
		}

		int rankedTrialGuid = RankedTrials_PlayerHasIncompleteTrial( player ) ? ItemFlavor_GetGUID( RankedTrials_GetAssignedTrial( player ) ) : 0
		SetPlayerMatchResult( player, breakdown.placement, breakdown.kills, breakdown.damage )

		string ornull currentRankedGUID = GetCurrentStatRankedPeriodRefOrNullByType( eItemType.calevent_rankedperiod )
		if ( currentRankedGUID != null )
		{
			expect string(  currentRankedGUID )

			if ( GetStat_Int( player, ResolveStatEntry( CAREER_STATS.rankedperiod_games_played_base, currentRankedGUID ) )  == 0 )
				__SetStat_Int( player, ResolveStatEntry( CAREER_STATS.rankedperiod_games_played_base, currentRankedGUID ), 1, true )  //Make sure we get past sanity checks for giving rewards for ranked which make sure you play at least one game
		}

		DEV_SetShowRankedSummary( player )
	}
}


void function DEV_SetShowRankedSummary( entity player )
{
	Ranked_SetXProgMergedPersistenceData( player, RANKED_SHOW_RANKED_SUMMARY_PERSISTENCE_VAR_NAME, 1 )

	player.SetPersistentVar( "showArenasRankedSummary", false )
	player.SetPersistentVar( "showGameSummary", true )
	player.SetPersistentVar( "lastGameTime", GetUnixTimestamp() )
	player.SetPersistentVar( "lastPlaylist", "survival_dev_ranked" )
	player.SetPersistentVar( "lastGamePlayers", 6 )
}


void function DEV_ClearCurrentSharedRankedPeriodAbandonCountPersistence()
{
	foreach ( entity player in GetPlayerArray() )
	{
		player.SetPersistentVar( "totalRankedGamesAbandoned", 0 )
		player.SetPersistentVar( "lastTimeGameWasRankedAbandoned", 0 )
		player.SetPersistentVar( "numUsedForgivenessAbandons", 0 )
		player.SetPersistentVar( "lastGameAbandonForgiveness", false )
	}
}


void function DEV_ClearRankedRewardsPersistence( bool onlyDoPrevious = false )
{
	foreach ( entity player in GetPlayerArray() )
	{
		if ( onlyDoPrevious )
		{
			Assert( Ranked_GetCurrentActiveRankedPeriod() != null )
			ItemFlavor latestRankedPeriod = expect ItemFlavor( Ranked_GetCurrentActiveRankedPeriod() )
			Ranked_SetHistoricalRankedPersistenceData( player, "rankedInitialized", false, ItemFlavor_GetGUIDString( latestRankedPeriod ) )

			ItemFlavor expiredRankedPeriod = expect ItemFlavor( GetPrecedingRankedPeriod( latestRankedPeriod ) )
			string expiredRankedPeriodGUID = ItemFlavor_GetGUIDString( expiredRankedPeriod )
			Ranked_SetHistoricalRankedPersistenceData( player, "endSeriesLadderPosition", 0, expiredRankedPeriodGUID )
		}
		else
		{
			foreach ( ItemFlavor rankedPeriod in GetAllRankedPeriodCalEventFlavorsByType( eItemType.calevent_rankedperiod ) )
			{
				string rankedPeriodGUID = ItemFlavor_GetGUIDString( rankedPeriod )
				Ranked_SetHistoricalRankedPersistenceData( player, "rankedInitialized", false, rankedPeriodGUID )
				Ranked_SetHistoricalRankedPersistenceData( player, "endSeriesLadderPosition", 0, rankedPeriodGUID )
			}
		}

		player.SetPersistentVar( "rankedRewardsAcknowledged", true )
		Ranked_SetHistoricalRankedPersistenceData( player, "endSeriesLadderPosition", -1, RANKED_SEASON_02_GUIDSTRING ) //Series 1 didn't have a ladder, treat it slightly differently when resetting
	}
}

//script DEV_TEST_MmrToLpConversion ( 0.2 )
void function DEV_TEST_MmrToLpConversion ( float mmrSteps = 0.25 ) {


	array<SharedRankedTierData> tiers = Ranked_GetTiers()

	//Points To MMR First
	//Adjusted MMR bands

	//we are going to test all the tiers
	for ( float mmr = 0 ; mmr < 60; mmr += mmrSteps )
	{
		array<SharedRankedTierData> data =  Ranked_GetTiers()
		int index = int  ( mmr / MMR_TIER_WIDTH )
		if ( index >= data.len() )
		{
			index = data.len() - 1
		}

		SharedRankedTierData rankTier = data [ index ]

		int answer = Ranked_MMRToPoints ( mmr ,rankTier  )
		int answer2 = Ranked_MMRToPoints_S20 ( mmr )
		DEV_script_ranked_debug ( "(input) tier: " + rankTier.name + "\tmmr: " + mmr + "\t\tLP: "  +answer   + "\t\tLP2: "  + answer2, 5 )
	}


	//These are the two function under consideration for test.
	//float function Ranked_PointsToMMR ( int points , SharedRankedTierData tier )
	//int function Ranked_MMRToPoints ( float mmr , SharedRankedTierData tier )
}

void function DEV_TEST_LpToMmrConversion ( int startLP = 0 , int stopLP = 26000, int lpSteps = 100 ) {


	array<SharedRankedTierData> tiers = Ranked_GetTiers()
	array<string> dataOutputString
	dataOutputString.append("Results\n\n\n")

	//Points To MMR First
	//Adjusted MMR bands
	foreach ( SharedRankedTierData rankTier in tiers )
	{
		dataOutputString.append( "Tier Point Width = " + GetTierPointWidth ( rankTier ) + " LP \n" )
			//we are going to test all the tiers

		for ( int lp = startLP ; lp < stopLP; lp += lpSteps )
		{
			if ( lp < rankTier.scoreMin  ) //|| lp > rankTier.scoreMin + GetTierMMRWidth ( rankTier )
				continue

			if ( lp > ( rankTier.scoreMin + GetTierPointWidth ( rankTier )  ) )
				continue

			float answer = Ranked_PointsToMMR ( lp , rankTier  )
			DEV_script_ranked_debug ( "(input) tier: " + rankTier.name + "\t\tLP: "  +lp + "\t\tmmr: " + answer , 5 )
			dataOutputString.append("(input) tier: " + rankTier.name + "\t\tLP: "  +lp + "\t\tmmr: " + answer + "\n" )
		}
	}



	//These are the two function under consideration for test.
	//float function Ranked_PointsToMMR ( int points , SharedRankedTierData tier )
	//int function Ranked_MMRToPoints ( float mmr , SharedRankedTierData tier )

	foreach (string s in dataOutputString)
		printf ( s )
}

void function DEV_TEST_SimulateGetProvisionalBonusMultiplierOutput ( float start = -50, float stop = 50, float step = 0.25 )
{
	for ( float i = start; i < stop; i += step )
	{
		float answer = GetProvisionalBonusMultiplier ( i  )
		DEV_script_ranked_debug ( "(input) mmr: " + i + "\t\toutput: "  +answer , 5 )
	}
}

void function DEV_TEST_SimulateGetProvisionalFlatBonusOutput ( float start = -50, float stop = 50, float step = 0.25 )
{
	for ( float i = start; i < stop; i += step )
	{
		int answer = GetProvisionalFlatBonus ( i  )
		DEV_script_ranked_debug ( "(input) mmr: " + i + "\t\toutput: "  +answer , 5 )
	}
}

void function DEV_TEST_SimulateGetProvisionalScalingMultiplierOutput ( float start = -50, float stop = 50, float step = 0.25 )
{
	for ( float i = start; i < stop; i += step )
	{
		float answer = GetProvisionalScalingMultiplier ( i  )
		DEV_script_ranked_debug ( "(input) mmr: " + i + "\t\toutput: "  +answer , 5 )
	}
}

void function DEV_TEST_TierWidths (  )
{
	array<SharedRankedTierData> tiers = Ranked_GetTiers()

	DEV_script_ranked_debug ("MMR TierWidth")
	foreach ( SharedRankedTierData rankTier in tiers )
	{
		float answer = GetTierMMRWidth ( rankTier )
		DEV_script_ranked_debug ( "(input) tier: " + rankTier.name + "\t\toutput: "  +answer , 5 )
	}

	DEV_script_ranked_debug ("LP TierWidth")
	foreach ( SharedRankedTierData rankTier in tiers )
	{
		int answer = GetTierPointWidth ( rankTier )
		DEV_script_ranked_debug ( "(input) tier: " + rankTier.name + "\t\toutput: "  +answer , 5 )
	}
}

void function SimulateGameResultWithoutWritePrep ()
{
	SimulateGameResultWithoutWrite ( 20, 12400, 25, 25, [25.0, 25.0, 25.0] , [25.2, 25.2], [25.2], 10, false, false)
}

void function SimulateGameResultWithoutWritePrep_S20 ()
{
	SimulateGameResultWithoutWrite_S20 ( 20, 12400, 25, 25, 0.23, [25.0, 25.0, 25.0] , [25.2, 25.2], [25.2], 4, 10, false, false, 3 )
	//script SimulateGameResultWithoutWrite_S20 ( 20, 12400, 25, 25, 0.23, [25.0, 25.0, 25.0] , [25.2, 25.2], [25.2], 4, 10, false, false, 3 )
}

void function SimulateGameResultWithoutWrite_S20( int placement = 1, int startingLP = 1231, float mmr = 12 , float variance = 23, float d = 0,
		array<float> killsMMR = [12.2, 23.2, 0.1], array<float> assistsMMR = [12.2, 23.2, 0.1],	array<float> participationMMR = [12.2, 23.2, 0.1] ,
	    int top5Count = 0, int provisionalGameCount = 1 , bool wasAbandon = false, bool wasLossForgiven = false, int demotionProtection = 3 )
{
	if ( !IsLobby() )
	{
		printf ("ONLY RUN SimulateGameResultWithoutWrite() from the lobby please")
		return
	}

	entity player = GetPlayerArray()[0]
	SetDemotionProtectionBuffer ( player , demotionProtection )
	Ranked_SetPlayerTop5StreakCount ( player, top5Count )
	SetPlayerMmrUtil (  player,  mmr,  variance , d )

	RankLadderPointsBreakdown breakdown

	Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, maxint( 0, provisionalGameCount - 1 ) )

	breakdown.wasInProvisonalGame = ( provisionalGameCount <= Ranked_GetNumProvisionalMatchesRequired() )
	breakdown.wasAbandoned        = wasAbandon
	if ( wasAbandon )
	{
		SetRankedGameData( player, "lastGameRankedAbandon", 1 )
	}
	else
	{
		SetRankedGameData( player, "lastGameRankedAbandon", 0 )
	}

	breakdown.lossForgiveness     = wasLossForgiven
	breakdown.damage              = 123

	table< string, RankedVictimData > killsPlayerByHwUID
	table< string, RankedVictimData > assistsPlayerByHwUID
	table< string, RankedVictimData > participationPlayerByHwUID
	table< string, RankedVictimData > knockdownPlayerByHwUID
	table< string, RankedVictimData > knockdownAssistPlayerByHwUID

	int victimCount = 0

	//populate from input array
	foreach ( float kill in killsMMR )
	{
		RankedVictimData v
		v.mmr = kill
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		killsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float assist in assistsMMR )
	{
		RankedVictimData v
		v.mmr = assist
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		assistsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float p in participationMMR )
	{
		RankedVictimData v
		v.mmr = p
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		participationPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}

	breakdown.killsPlayerByHwUID           = killsPlayerByHwUID
	breakdown.assistsPlayerByHwUID         = assistsPlayerByHwUID
	breakdown.participationPlayerByHwUID   = participationPlayerByHwUID
	breakdown.knockdownPlayerByHwUID       = knockdownPlayerByHwUID
	breakdown.knockdownAssistPlayerByHwUID = knockdownAssistPlayerByHwUID

	breakdown.knockdown       = 1
	breakdown.knockdownAssist = 1

	breakdown.kills         = 1
	breakdown.assists       = 1
	breakdown.participation = 1

	breakdown.killsUnique         = killsPlayerByHwUID.len()
	breakdown.assistUnique        = assistsPlayerByHwUID.len()
	breakdown.participationUnique = participationPlayerByHwUID.len()

	//breakdown.totalUniqueSquadKills = breakdown.killsUnique + breakdown.assistUnique + breakdown.participationUnique
	breakdown.placement      = placement
	player.SetPersistentVar( "lastGameRank" ,breakdown.placement )
	breakdown.placementScore = Ranked_GetPointsForPlacement ( breakdown.placement )

	breakdown.killBonus             = 0
	breakdown.convergenceBonus      = 0
	breakdown.skillDiffBonus        = 0
	breakdown.provisionalMatchBonus = 0

	breakdown.promotionBonus = 0
	breakdown.demotionPenality = 0
	breakdown.penaltyPointsForAbandoning = 0
	breakdown.demotionProtectionAdjustment = 0
	breakdown.lossProtectionAdjustment = 0

	//output
	breakdown.startingLP = startingLP

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP )
	breakdown.isHighTier = oldRank.tier.isTopEnd
	//breakdown.netLP     //these needs to be validated by script
	//breakdown.finalL

	                  
		if ( !breakdown.wasInProvisonalGame )
			breakdown.entryCost = oldRank.divisionEntryCost
		//breakdown.totalUniqueSquadKills = victimCount

		breakdown.top5Streak = 0
		breakdown.top5StreakBonusValue = 0

		breakdown.highSkillKill = 0
		breakdown.highSkillKillBonusValue = 0

		breakdown.killValueModifierByPlacement = 0
		breakdown.firstKillBonus = 0

		breakdown.demoCrewBonus = 0
       

	if ( Ranked_IsDisablePointGain( player )  )
	{
		breakdown.placementScore = 0
		breakdown.finalLP = breakdown.startingLP
	}

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown, 0, "DEV S20 PrepareGameSummaryForPointCalculation for " + player.GetPlayerName()  )
	#endif

	PostGameCalculateLadderPointResult( player, breakdown )
}

void function SimulateGameResultWithoutWrite ( int placement = 1, int startingLP = 1231, float mmr = 12 , float variance = 23, array<float> killsMMR = [12.2, 23.2, 0.1], array<float> assistsMMR = [12.2, 23.2, 0.1],
		array<float> participationMMR = [12.2, 23.2, 0.1] , int provisionalGameCount = 1 , bool wasAbandon = false, bool wasLossForgiven = false, int demotionProtection = 3 )
{
	if ( !IsLobby() )
	{
		printf ("ONLY RUN SimulateGameResultWithoutWrite() from the lobby please")
		return
	}

	// Building data
	// this needs to mirror PrepareGameSummaryForPointCalculation() in data provided

	entity player = GetPlayerArray()[0]
	SetDemotionProtectionBuffer ( player , demotionProtection )

	SetPlayerMmrUtil (  player,  mmr,  variance )

	RankLadderPointsBreakdown breakdown

	Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, maxint( 0, provisionalGameCount - 1 ) )

	breakdown.wasInProvisonalGame = ( provisionalGameCount < Ranked_GetNumProvisionalMatchesRequired() )
	breakdown.wasAbandoned        = wasAbandon
	if ( wasAbandon )
	{
		SetRankedGameData( player, "lastGameRankedAbandon", 1 )
	}
	else
	{
		SetRankedGameData( player, "lastGameRankedAbandon", 0 )
	}
	breakdown.lossForgiveness     = wasLossForgiven
	breakdown.damage              = 123

	table< string, RankedVictimData > killsPlayerByHwUID
	table< string, RankedVictimData > assistsPlayerByHwUID
	table< string, RankedVictimData > participationPlayerByHwUID
	table< string, RankedVictimData > knockdownPlayerByHwUID
	table< string, RankedVictimData > knockdownAssistPlayerByHwUID

	int victimCount = 0

	//populate from input array
	foreach ( float kill in killsMMR )
	{
		RankedVictimData v
		v.mmr = kill
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		killsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float assist in assistsMMR )
	{
		RankedVictimData v
		v.mmr = assist
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		assistsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float p in participationMMR )
	{
		RankedVictimData v
		v.mmr = p
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		participationPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}

	breakdown.killsPlayerByHwUID           = killsPlayerByHwUID
	breakdown.assistsPlayerByHwUID         = assistsPlayerByHwUID
	breakdown.participationPlayerByHwUID   = participationPlayerByHwUID
	breakdown.knockdownPlayerByHwUID       = knockdownPlayerByHwUID
	breakdown.knockdownAssistPlayerByHwUID = knockdownAssistPlayerByHwUID

    breakdown.knockdown       = 1
	breakdown.knockdownAssist = 1

	breakdown.kills         = 1
	breakdown.assists       = 1
	breakdown.participation = 1

	breakdown.killsUnique         = killsPlayerByHwUID.len()
	breakdown.assistUnique        = assistsPlayerByHwUID.len()
	breakdown.participationUnique = participationPlayerByHwUID.len()

	breakdown.placement      = placement
	player.SetPersistentVar( "lastGameRank" ,breakdown.placement )
	breakdown.placementScore = Ranked_GetPointsForPlacement ( breakdown.placement )

	breakdown.killBonus             = 0
	breakdown.convergenceBonus      = 0
	breakdown.skillDiffBonus        = 0
	breakdown.provisionalMatchBonus = 0

	breakdown.promotionBonus = 0
	breakdown.demotionPenality = 0
	breakdown.penaltyPointsForAbandoning = 0
	breakdown.demotionProtectionAdjustment = 0
	breakdown.lossProtectionAdjustment = 0

	//output
	breakdown.startingLP = startingLP

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP )
	breakdown.isHighTier = oldRank.tier.isTopEnd
	//breakdown.netLP     //these needs to be validated by script
	//breakdown.finalL

	if ( Ranked_IsDisablePointGain( player )  )
	{
		breakdown.placementScore = 0
		breakdown.finalLP = breakdown.startingLP
	}

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown, 0, "PrepareGameSummaryForPointCalculation for " + player.GetPlayerName()  )
	#endif

	PostGameCalculateLadderPointResult( player, breakdown )
}


void function SimulateAdjustForConvergence ( int placement = 2 , int startingLP = 123, float mmr = 12 , float variance = 23, array<float> killsMMR = [12.2, -23.2, 0.1], array<float> assistsMMR = [12.2, -23.2, 0.1],
		array<float> participationMMR = [12.2, -23.2, 0.1] )
{
	if ( !IsLobby() )
	{
		printf ("ONLY RUN SimulateGameResultWithoutWrite() from the lobby please")
		return
	}

	// Building data
	// this needs to mirror PrepareGameSummaryForPointCalculation() in data provided

	entity player = GetPlayerArray()[0]
	SetDemotionProtectionBuffer ( player , DEMOTION_BUFFER_MAX )

	SetPlayerMmrUtil (  player,  mmr,  variance )

	RankLadderPointsBreakdown breakdown
	int provisionalGameCount = 1

	Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, maxint( 0, provisionalGameCount - 1 ) )

	breakdown.wasInProvisonalGame = ( provisionalGameCount < Ranked_GetNumProvisionalMatchesRequired() )
	breakdown.wasAbandoned        = false
	breakdown.lossForgiveness     = false
	breakdown.damage              = 123

	table< string, RankedVictimData > killsPlayerByHwUID
	table< string, RankedVictimData > assistsPlayerByHwUID
	table< string, RankedVictimData > participationPlayerByHwUID
	table< string, RankedVictimData > knockdownPlayerByHwUID
	table< string, RankedVictimData > knockdownAssistPlayerByHwUID

	int victimCount = 0

	//populate from input array
	foreach ( float kill in killsMMR )
	{
		RankedVictimData v
		v.mmr = kill
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		killsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float assist in assistsMMR )
	{
		RankedVictimData v
		v.mmr = assist
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		assistsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float p in participationMMR )
	{
		RankedVictimData v
		v.mmr = p
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		participationPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}

	breakdown.killsPlayerByHwUID           = killsPlayerByHwUID
	breakdown.assistsPlayerByHwUID         = assistsPlayerByHwUID
	breakdown.participationPlayerByHwUID   = participationPlayerByHwUID
	breakdown.knockdownPlayerByHwUID       = knockdownPlayerByHwUID
	breakdown.knockdownAssistPlayerByHwUID = knockdownAssistPlayerByHwUID

	breakdown.knockdown       = 1
	breakdown.knockdownAssist = 1

	breakdown.kills         = 1
	breakdown.assists       = 1
	breakdown.participation = 1

	breakdown.killsUnique         = killsPlayerByHwUID.len()
	breakdown.assistUnique        = assistsPlayerByHwUID.len()
	breakdown.participationUnique = participationPlayerByHwUID.len()

	breakdown.placement      = placement
	player.SetPersistentVar( "lastGameRank" ,breakdown.placement )
	breakdown.placementScore = Ranked_GetPointsForPlacement ( breakdown.placement )

	breakdown.killBonus             = 0
	breakdown.convergenceBonus      = 0
	breakdown.skillDiffBonus        = 0
	breakdown.provisionalMatchBonus = 0

	breakdown.promotionBonus = 0
	breakdown.demotionPenality = 0
	breakdown.penaltyPointsForAbandoning = 0
	breakdown.demotionProtectionAdjustment = 0
	breakdown.lossProtectionAdjustment = 0

	//output
	breakdown.startingLP = startingLP
	//breakdown.netLP     //these needs to be validated by script
	//breakdown.finalL

	if ( Ranked_IsDisablePointGain( player )  )
	{
		breakdown.placementScore = 0
		breakdown.finalLP = breakdown.startingLP
	}

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown, 0, "PrepareGameSummaryForPointCalculation for " + player.GetPlayerName()  )
	#endif

	AdjustForConvergence( breakdown , player)
}



void function SimulateAdjustForProvisional ( int placement = 2 , int startingLP = 123, float mmr = 12 , float variance = 23, array<float> killsMMR = [12.2, 23.2, 0.1], array<float> assistsMMR = [12.2, 4.2, 0.1],
		array<float> participationMMR = [12.2, 23.2, 0.1] , int provisionalGameCount = 1 , bool wasAbandon = false, bool wasLossForgiven = false )
{
	if ( !IsLobby() )
	{
		printf ("ONLY RUN SimulateGameResultWithoutWrite() from the lobby please")
		return
	}

	// Building data
	// this needs to mirror PrepareGameSummaryForPointCalculation() in data provided

	entity player = GetPlayerArray()[0]
	SetDemotionProtectionBuffer ( player , DEMOTION_BUFFER_MAX )

	SetPlayerMmrUtil (  player,  mmr,  variance )

	RankLadderPointsBreakdown breakdown

	Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, maxint( 0, provisionalGameCount - 1 ) )

	breakdown.wasInProvisonalGame = ( provisionalGameCount < Ranked_GetNumProvisionalMatchesRequired() )
	breakdown.wasAbandoned        = wasAbandon
	breakdown.lossForgiveness     = wasLossForgiven
	breakdown.damage              = 123

	table< string, RankedVictimData > killsPlayerByHwUID
	table< string, RankedVictimData > assistsPlayerByHwUID
	table< string, RankedVictimData > participationPlayerByHwUID
	table< string, RankedVictimData > knockdownPlayerByHwUID
	table< string, RankedVictimData > knockdownAssistPlayerByHwUID

	int victimCount = 0

	//populate from input array
	foreach ( float kill in killsMMR )
	{
		RankedVictimData v
		v.mmr = kill
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		killsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float assist in assistsMMR )
	{
		RankedVictimData v
		v.mmr = assist
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		assistsPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}
	foreach ( float p in participationMMR )
	{
		RankedVictimData v
		v.mmr = p
		v.playerName = "victim"+victimCount+"name"
		v.rp = 1

		participationPlayerByHwUID[ "victim"+victimCount ] <- v
		victimCount++
	}

	breakdown.killsPlayerByHwUID           = killsPlayerByHwUID
	breakdown.assistsPlayerByHwUID         = assistsPlayerByHwUID
	breakdown.participationPlayerByHwUID   = participationPlayerByHwUID
	breakdown.knockdownPlayerByHwUID       = knockdownPlayerByHwUID
	breakdown.knockdownAssistPlayerByHwUID = knockdownAssistPlayerByHwUID

	breakdown.knockdown       = 1
	breakdown.knockdownAssist = 1

	breakdown.kills         = 1
	breakdown.assists       = 1
	breakdown.participation = 1

	breakdown.killsUnique         = killsPlayerByHwUID.len()
	breakdown.assistUnique        = assistsPlayerByHwUID.len()
	breakdown.participationUnique = participationPlayerByHwUID.len()

	breakdown.placement      = placement
	player.SetPersistentVar( "lastGameRank" ,breakdown.placement )
	breakdown.placementScore = Ranked_GetPointsForPlacement ( breakdown.placement )

	breakdown.killBonus             = 0
	breakdown.convergenceBonus      = 0
	breakdown.skillDiffBonus        = 0
	breakdown.provisionalMatchBonus = 0

	breakdown.promotionBonus = 0
	breakdown.demotionPenality = 0
	breakdown.penaltyPointsForAbandoning = 0
	breakdown.demotionProtectionAdjustment = 0
	breakdown.lossProtectionAdjustment = 0

	//output
	breakdown.startingLP = startingLP
	//breakdown.netLP     //these needs to be validated by script
	//breakdown.finalL

	if ( Ranked_IsDisablePointGain( player )  )
	{
		breakdown.placementScore = 0
		breakdown.finalLP = breakdown.startingLP
	}

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown, 0, "PrepareGameSummaryForPointCalculation for " + player.GetPlayerName()  )
	#endif

	breakdown = AdjustForEliminiations ( breakdown, player )
	breakdown = AdjustForConvergence ( breakdown, player )
	breakdown = AdjustForSkillDifferences ( breakdown , player )

	breakdown = RedistributeBonuses ( breakdown,player )

	breakdown = AdjustForProvisionalGames( breakdown , player)

	DEV_script_ranked_debug ( breakdown.provisionalMatchBonus + " <------------- PROVISON BONUS" , 4)
}


void function SimulateRedistributeBonuses ( int k = 123, int c = 423, int s = 323 , int placement = 1 )
{
	if ( !IsLobby() )
	{
		printf ("ONLY RUN SimulateGameResultWithoutWrite() from the lobby please")
		return
	}

	entity player = GetPlayerArray()[0]
	// Building data
	// this needs to mirror PrepareGameSummaryForPointCalculation() in data provided

	RankLadderPointsBreakdown breakdown

	breakdown.placement = placement
	breakdown.placementScore = Ranked_GetPointsForPlacement ( breakdown.placement )

	breakdown.killBonus          = k
	breakdown.convergenceBonus   = c
	breakdown.skillDiffBonus     = s

	DEV_script_ranked_debug ( "input: killBonus: " + breakdown.killBonus  + "\tconvergenceBonus: " + breakdown.convergenceBonus  +  "\tskillDiffBonus: " + breakdown.skillDiffBonus )
	breakdown = RedistributeBonuses ( breakdown , player )
	DEV_script_ranked_debug ( "output: killBonus: " + breakdown.killBonus  + "\tconvergenceBonus: " + breakdown.convergenceBonus  +  "\tskillDiffBonus: " + breakdown.skillDiffBonus )
}

void function SimTop5Streak ( int maxCount = 5  )
{
	for ( int i = 0; i < maxCount; i++  )
	{
		printf ( i + ": streak couunt /t points: "  + Ranked_GetTop5StreakBonusValueFromStreak (i) )
	}
}

#endif // SERVER

#if DEVELOPER
void function DEV_script_ranked_debug ( string message,int indent = 0 )
{

	string tabs = ""

	for (int i = 0; i < indent; i++)
	{
		tabs += "\t"
	}

	if( GetConVarBool( "script_ranked_debug" ) )
	{
		printf ("script_ranked_debug:" + tabs + " " + message )
	}
}

void function PrintRankLadderPointsBreakdown ( RankLadderPointsBreakdown data , int indent = 0, string memo = "")
{

	DEV_script_ranked_debug ( "------------------------------------------------------", indent )
	DEV_script_ranked_debug ( "-----------PrintRankLadderPointsBreakdown() start ----", indent )
	DEV_script_ranked_debug ( "------------------------------------------------------", indent )

	indent++

	if ( memo != "" )
	{
		DEV_script_ranked_debug ( "memo:" + memo, indent++ )
	}

	DEV_script_ranked_debug ( "isHighTier: " + data.isHighTier, indent )
	DEV_script_ranked_debug ( "wasInProvisonalGame: " + data.wasInProvisonalGame, indent )
	DEV_script_ranked_debug ( "wasAbandoned: " + data.wasAbandoned, indent )
	DEV_script_ranked_debug ( "lossForgiveness: " + data.lossForgiveness , indent)
	DEV_script_ranked_debug ( "damage: " + data.damage , indent)
	DEV_script_ranked_debug ( "knockdown " + data.knockdown, indent )
	DEV_script_ranked_debug ( "knockdownAssist: " + data.knockdownAssist , indent)
	DEV_script_ranked_debug ( "kills: " + data.kills, indent )
	DEV_script_ranked_debug ( "assists: " + data.assists, indent)
	DEV_script_ranked_debug ( "participation: " + data.participation, indent )
	DEV_script_ranked_debug ( "killsUnique: " + data.killsUnique, indent)
	DEV_script_ranked_debug ( "assistUnique: " + data.assistUnique, indent)
	DEV_script_ranked_debug ( "participationUnique: " + data.participationUnique, indent)
	DEV_script_ranked_debug ( "totalUniqueSquadKills: " + data.totalUniqueSquadKills, indent)
	DEV_script_ranked_debug ( "placement: " + data.placement, indent)
	DEV_script_ranked_debug ( "placementScore: " + data.placementScore, indent)

	//DEV_script_ranked_debug ( "killBonus " + data.killBonus)
	//DEV_script_ranked_debug ( "convergenceBonus " + data.convergenceBonus)
	//DEV_script_ranked_debug ( "skillDiffBonus " + data.skillDiffBonus)
	//DEV_script_ranked_debug ( "provisionalBonus " + data.provisionalBonus)

	DEV_script_ranked_debug ( "killBonus: " + data.killBonus, indent)
	DEV_script_ranked_debug ( "convergenceBonus: " + data.convergenceBonus, indent)
	DEV_script_ranked_debug ( "skillDiffBonus: " + data.skillDiffBonus, indent)

	DEV_script_ranked_debug ( "provisionalMatchBonus: " + data.provisionalMatchBonus, indent)

	DEV_script_ranked_debug ( "promotionBonus: " + data.promotionBonus, indent)
	DEV_script_ranked_debug ( "demotionPenality: " + data.demotionPenality, indent)
	DEV_script_ranked_debug ( "penaltyPointsForAbandoning: " + data.penaltyPointsForAbandoning, indent)
	DEV_script_ranked_debug ( "demotionProtectionAdjustment: " + data.demotionProtectionAdjustment, indent)
	DEV_script_ranked_debug ( "lossProtectionAdjustment: " + data.lossProtectionAdjustment, indent)

	                  
	DEV_script_ranked_debug ( "entryCost: " + data.entryCost, indent)
	DEV_script_ranked_debug ( "totalUniqueSquadKills: " + data.totalUniqueSquadKills, indent)
	DEV_script_ranked_debug ( "top5Streak: " + data.top5Streak, indent)
	DEV_script_ranked_debug ( "top5StreakBonusValue: " + data.top5StreakBonusValue, indent)
	DEV_script_ranked_debug ( "highSkillKill: " + data.highSkillKill, indent)
	DEV_script_ranked_debug ( "highSkillKillBonusValue: " + data.highSkillKillBonusValue, indent)
	DEV_script_ranked_debug ( "killValueModifierByPlacement: " + data.killValueModifierByPlacement, indent)
	DEV_script_ranked_debug ( "demoCrewBonus: " + data.demoCrewBonus, indent)
       

	DEV_script_ranked_debug ( "currentLP: " + data.startingLP, indent)
	DEV_script_ranked_debug ( "netLP: " + data.netLP, indent)
	DEV_script_ranked_debug ( "finalLP: " + data.finalLP, indent)

	DEV_script_ranked_debug ( "PrintRankLadderPointsBreakdown() end ----" , indent)
}
#endif