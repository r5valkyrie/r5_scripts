#if SERVER
global function Sh_Ranked_Bonus_Init
global function Sh_Rank_InitGameSummary

global function Ranked_PointsToMMR
global function Ranked_MMRToPoints
global function Ranked_MMRToPoints_S20
global function Ranked_GetPlayerDamageDealt

global function MMR_Rank_MatchMMRCalculate

global function MMR_Rank_GetPlayerMMR
global function MMR_Rank_GetPlayerMMRVariance
global function MMR_Rank_GetTeamMMRByPlayer
global function MMR_Rank_GetTeamMMRVarianceByPlayer

global function SetDemotionProtectionBuffer

global function AddCallback_OnPlayerParticipation
global function AddCallback_OnPlayerGameSummaryKillParticipation
global function RunCallback_OnPlayerParticipation
global function SurvivalRank_ProcessParticiation

global function PrepareGameSummaryForPointCalculation
global function Ranked_UpdateRankedScoreProgressForAllPlayers
global function Ranked_UpdateRankedScoreProgressForPlayer

global function Ranked_HasFinishedProvisionalMatches
global function Ranked_OnStryderPlayerRankedResultsComplete
global function HasPlayerMMR
global function GetPlayerMMR

#if DEVELOPER
// exposed for debug
global function SetPlayerRankedGameScoringData
global function ValidateAndRecalculateBreakdown
global function RedistributeBonuses
global function AdjustForDemotion
global function AdjustForTierPromotion
global function AdjustForEliminiations
                  
global function AdjustForEliminiations_S20
global function AdjustForProvisionalGames_S20
global function AdjustForTop5Streak
global function AdjustForDivisonPromotion
      
global function AdjustForSkillDifferences
global function AdjustForConvergence
global function AdjustForHighEndTiers
global function AdjustForProvisionalGames
global function GetProvisionalScalingMultiplier
global function GetProvisionalFlatBonus
global function GetProvisionalBonusMultiplier
global function GetTierMMRWidth
global function GetTierPointWidth
global function PostGameCalculateLadderPointResult
#endif // SERVER && DEVELOPER

global const int   LP_TIER_RESET_TARGET = 5000

                  
global const float MMR_TIER_POSITIVE_OVERLAP = 0.0   //1.33  the amount of MMR a player in ranked need to exceed to get promoted (in RP space)
global const float MMR_TIER_NEGATIVE_OVERLAP = 0.0   //1.33  the amount of MMR a player need to lose in order to get demoted (in RP space)
     
                                                                                                                                                    
                                                                                                                                                
      

global const float MMR_STANDARD_DEVIVATION = 50.0 / 6.0     //8.33 the amount of MMR that represents a single standard deviation
global const int   HIGH_END_TIER_INDEX = 5 //diamond

global const float RANKED_KILLVALUE_MAX = 25.0
global const float MMR_SD_MAX = 3.0

global const float MMR_TIER_WIDTH =  50.0 / 6.0
global const int   LP_TIER_WIDTH = 4000

global const float MMR_MASTER_BREAKPOINT = 50.0
global const float MMR_PLATINIUM_BREAKPOINT = 32
global const float MMR_DIAMOND_BREAKPOINT = 121/3
global const float MMR_BRONZE_BREAKPOINT =  MMR_STANDARD_DEVIVATION
global const float MMR_BRONZE_DEMOTION_POINT = MMR_BRONZE_BREAKPOINT - MMR_TIER_NEGATIVE_OVERLAP

global const int MASTER_LP_BREAKPOINT = 24000
global const int RANKED_POSITIVE_PLACEMENT = 10


struct MMR_matchInfo
{
	float mean
	float variance
	float standardDeviation
	float width
	int playerCount //with mmr
}

struct
{
	MMR_matchInfo matchMMRInfo

	//data table for bonus system
	array < array< float> > killValues
	array < array< float> > positivePerformanceScalar

	//callbacks
	array <void functionref( entity attacker, entity victim )> onPlayerParticipationCallbacks
	array <void functionref( entity, entity, int ) >  Callbacks_OnPlayerGameSummaryKillParticipation

} file

// ---------------------------
// Init
// ---------------------------

void function Sh_Rank_InitGameSummary()
{
	//from _gamemode_survival.nut
	AddCallback_GameStateEnter( eGameState.Playing, Rank_Scoring_GameStartedPlaying )

	Survival_AddCallback_OnPlayerGameSummaryKill ( OnPlayerGameSummaryKill )
	Survival_AddCallback_OnPlayerGameSummaryAssist ( OnPlayerGameSummaryAssist )
	Survival_AddCallback_OnPlayerGameSummaryKnockdown ( OnPlayerGameSummaryKnockdown )
	Survival_AddCallback_OnPlayerGameSummaryKnockdownAssist ( OnPlayerGameSummaryKnockdownAssist )
	AddCallback_OnPlayerGameSummaryKillParticipation ( OnPlayerGameSummaryKillParticipation )
}

void function Rank_Scoring_GameStartedPlaying()
{
	//calculate MMR
	#if DEVELOPER
		DEV_script_ranked_debug ("Rank_Scoring_GameStartedPlaying() because eGameState.Playing")
	#endif
	MMR_Rank_MatchMMRCalculate ()
}

void function Sh_Ranked_Bonus_Init ()
{

	#if DEVELOPER
		DEV_script_ranked_debug ("Sh_Ranked_Bonus_Init() .....")
	#endif

                    
                      
                       
                              
       

	#if DEVELOPER
		DEV_script_ranked_debug ("Sh_Ranked_Bonus_Init() End ..... ")
	#endif
}

array < array < float  > > function Ranked_Init_ReadServerBonusDataTableFloat ( string featureName  )
{

	array < array < float > > result

	#if DEVELOPER
		DEV_script_ranked_debug ("Ranked_Init_ReadServerBonusDataTableFloat() for :" + featureName + " ..... ")
	#endif

	var dataTable = GetDataTable( $"datatable/ranked_server_scoring.rpak" )
	int col_feature = GetDataTableColumnByName( dataTable, "featureName" )
	int col_rowCount =  GetDataTableColumnByName( dataTable, "rowCount" )
	int col_columnCount = GetDataTableColumnByName( dataTable, "columnCount" )
	int col_data0 = GetDataTableColumnByName( dataTable, "data0" )

	int baseRow = GetDataTableRowMatchingStringValue( dataTable, col_feature , featureName )

	#if DEVELOPER
		Assert ( baseRow >= 0 , "baseRow for \""+ featureName + "\" not found" ) //mostly for dev
	#endif

	int rowCount = GetDataTableInt ( dataTable, baseRow, col_rowCount )
	int columnCount = GetDataTableInt ( dataTable, baseRow, col_columnCount )

	#if DEVELOPER
	Assert ( rowCount >= 0 , "rowCount for \""+ featureName + "\" not found" ) //mostly for dev
	Assert ( columnCount >= 0 , "columnCount for \""+ featureName + "\" not found" ) //mostly for dev
	#endif

	#if DEVELOPER
		DEV_script_ranked_debug (
			"\t" + featureName + " row on () "+ baseRow + "....." +
			"\n\t" + featureName + " has "+ rowCount + " rows....." +
		    "\n\t" + featureName + " has "+ columnCount + " columns....."
		)
	#endif

	for ( int rowIdx = 0; rowIdx < rowCount; rowIdx++ )
	{
		array< float  > rowValues
		for (int colIdx = 0; colIdx < columnCount -1; colIdx++)
		{
			float cellValue = GetDataTableFloat ( dataTable,rowIdx + baseRow + 1 , colIdx + col_data0 )
			rowValues.append(cellValue)

			#if DEVELOPER
				DEV_script_ranked_debug ( "\t\t [" + rowIdx + "][" + colIdx + "]: " + cellValue + "....." )
			#endif
		}
		#if DEVELOPER
			DEV_script_ranked_debug ("\t\t--------------------------------------------")
		#endif
		result.append (rowValues)
	}

	return result
}

void function Init_KillValueTable ()
{
	file.killValues = Ranked_Init_ReadServerBonusDataTableFloat ( "killValues" )
}

void function Init_PerformanceValueTable ()
{
	file.positivePerformanceScalar = Ranked_Init_ReadServerBonusDataTableFloat ( "performanceScale" )
}

// ---------------------------
// MMR + LP Mapping
// ---------------------------

int function Ranked_MMRToPoints ( float mmr , SharedRankedTierData tier )
{
	float mmrWidth = GetTierMMRWidth ( tier ) //Tier of Master+ results in -1, since Master+ has no defined width
	int pointWidth = GetTierPointWidth ( tier )

	#if DEVELOPER
		//DEV_script_ranked_debug ( mmrWidth + " : "  + pointWidth, 2 )
	#endif

	if ( mmrWidth == -1 )
	{
		return MASTER_LP_BREAKPOINT
	}

	int index = tier.index
	float mmrFloor =  max ( 0, ( index * MMR_TIER_WIDTH ) - MMR_TIER_NEGATIVE_OVERLAP )
	float conversionRate  =  float ( pointWidth ) / mmrWidth

	return tier.scoreMin +  int ( ( mmr - mmrFloor ) * conversionRate )
}

                  
int function Ranked_MMRToPoints_S20 ( float mmr )
{
	//should yield the same result as above.
	Assert ( mmr >= 0 )
	array<SharedRankedTierData> data =  Ranked_GetTiers()
	int index = int  ( mmr / MMR_TIER_WIDTH )
	if ( index >= data.len() )
	{
		index = data.len() - 1
	}

	SharedRankedTierData tier = data [ index ]
	return Ranked_MMRToPoints ( mmr , tier )

}
      

float function Ranked_Get_MMR_Overlap_Negative ()
{
	float result = -1.0 * GetCurrentPlaylistVarFloat ("ranked_tuning_var_python", MMR_TIER_NEGATIVE_OVERLAP )
	Assert ( result <= 0 )
	return result
}

float function Ranked_Get_MMR_Overlap_Positive ()
{
	return GetCurrentPlaylistVarFloat ("ranked_tuning_var_potato", MMR_TIER_POSITIVE_OVERLAP )
}

float function Ranked_PointsToMMR ( int points , SharedRankedTierData tier )
{
	#if DEVELOPER
	DEV_script_ranked_debug ( "-----------------------------------------------------------------------" , 2 )
	DEV_script_ranked_debug ( "------ Points to MMR: LP= " + points + " @ tier " + tier.name , 2 )
	DEV_script_ranked_debug ( "-----------------------------------------------------------------------" ,2  )
	#endif

	float mmrWidth = GetTierMMRWidth ( tier )
	//Tier of Master+ results in -1, since Master+ has no defined width

	if ( mmrWidth == -1 )
	{
		int basePoints = tier.scoreMin //masters and apex have the same min points, so this is okay to do here.

		if ( basePoints >= points )
			return MMR_MASTER_BREAKPOINT + Ranked_Get_MMR_Overlap_Negative ()

		int remaindingPoints = points - basePoints
		float rate = MMR_TIER_WIDTH / float ( LP_TIER_WIDTH )
		return MMR_MASTER_BREAKPOINT + Ranked_Get_MMR_Overlap_Negative () + ( rate * float ( remaindingPoints ) )
	}

	int pointWidth = GetTierPointWidth ( tier )

	if ( tier.index == 0 )
	{
		pointWidth--
		//rookie starts at 1, so to round off number by 1
	}

	int index = tier.index
	float mmrFloor =  max ( 0, ( index * MMR_STANDARD_DEVIVATION ) + Ranked_Get_MMR_Overlap_Negative() )
	float conversionRate  =  mmrWidth / float ( pointWidth )

	int scoreMin = tier.scoreMin

	if (scoreMin == 1) //rookie adjustment
		scoreMin = 0

	#if DEVELOPER
		DEV_script_ranked_debug ( " - mmrWidth " + mmrWidth ,3  )
		DEV_script_ranked_debug ( " - pointWidth " + pointWidth ,3  )
		DEV_script_ranked_debug ( " - index " + index ,3  )
		DEV_script_ranked_debug ( " - mmrFloor " + mmrFloor ,3  )
		DEV_script_ranked_debug ( " - conversionRate " + conversionRate ,3  )
		DEV_script_ranked_debug ( " - conversionRate " + conversionRate ,3  )
		DEV_script_ranked_debug ( " - MMR result: " + max ( 0 , mmrFloor + ( ( points - scoreMin ) * conversionRate ) ) ,3  )
	#endif
	return max ( 0 , mmrFloor + ( ( points - scoreMin ) * conversionRate ) )
}


float function GetTierMMRWidth ( SharedRankedTierData tier )
{


	array<SharedRankedTierData> data =  Ranked_GetTiers()
	int nonLadderTierCount           = 0

	foreach ( SharedRankedTierData d in data )
	{
		if ( d.isLadderOnlyTier )
			continue
		nonLadderTierCount++
	}

	//exclude the last tier before Ladder Tiers - Masters
	if ( tier.index >= nonLadderTierCount - 1 || tier.isLadderOnlyTier ) //todo verify
		return -1

	float tierMMRWidth = MMR_TIER_WIDTH + Ranked_Get_MMR_Overlap_Positive()

	if ( tier.index > 0 )
	{
		//Rookie's MMR can't be lower than zero, nor get demoted
		tierMMRWidth += fabs ( Ranked_Get_MMR_Overlap_Negative() )
	}

	return tierMMRWidth
}

int function GetTierPointWidth ( SharedRankedTierData tier )
{
	SharedRankedTierData ornull nextTier  = Ranked_GetNextTierData( tier )
	int tierWidthPoints = 4000 //default fallback

	if ( nextTier != null )
	{
		expect SharedRankedTierData( nextTier )
		tierWidthPoints = nextTier.scoreMin - tier.scoreMin //this should be 4000
	}

	return tierWidthPoints //effectively always returning 4000
}

// ---------------------------
// Match MMR
// ---------------------------

void function MMR_Rank_MatchMMRCalculate ()
{
	#if DEVELOPER
		DEV_script_ranked_debug ("MMR  Recalculate start")
	#endif

	array<entity> players = GetPlayerArray()

	int numPlayersWithMMR = 0
	float sumMMR = 0.0
	float sumMMRVariance = 0.0
	float lowestMMR = 100
	float highestMMR = 0

	foreach ( entity p in players )
	{
		if ( !HasPlayerMMR ( p  ) )
		{
			continue
		}
		numPlayersWithMMR++

		float playerAdjustedMMR = MMR_Rank_GetPostAdjustedMMR ( p )
		array< float > mmrs = GetPlayerMMR( p )	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance

		sumMMR += playerAdjustedMMR
		sumMMRVariance += mmrs[1]

		if ( playerAdjustedMMR  < lowestMMR )
			lowestMMR = playerAdjustedMMR

		if ( playerAdjustedMMR > highestMMR )
			highestMMR = playerAdjustedMMR
	}


	#if DEVELOPER
	if ( numPlayersWithMMR == 0 )
	{
		DEV_script_ranked_debug ( "MMR_Rank_MatchMMRCalculate - NumPlayerWithMMR = 0, Dev, thus skipping." )
		return
	}
	#endif

	float meanMMR = sumMMR / float ( numPlayersWithMMR )
	float meanMMRVariance = sumMMRVariance / float ( numPlayersWithMMR )

	float sq_diff_sumMMR = 0.0
	float sq_diff_sumMMRVar = 0.0

	foreach ( entity p in players )
	{
		if ( !HasPlayerMMR ( p ) )
			continue

		float playerAdjustedMMR = MMR_Rank_GetPostAdjustedMMR ( p )
		array< float > mmrs = GetPlayerMMR( p )	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance

		float diffMMR    = playerAdjustedMMR - meanMMR
		float diffMMRVar = mmrs[1] - meanMMRVariance

		sq_diff_sumMMR += diffMMR * diffMMR
		sq_diff_sumMMRVar += diffMMRVar * diffMMRVar
	}

	float varianceOfMMR = sq_diff_sumMMR /  float ( numPlayersWithMMR )
	float varianceOfMMRVariance = sq_diff_sumMMRVar /  float ( numPlayersWithMMR )

	file.matchMMRInfo.playerCount = numPlayersWithMMR
	file.matchMMRInfo.standardDeviation = sqrt ( varianceOfMMR )
	file.matchMMRInfo.mean = meanMMR
	file.matchMMRInfo.variance = meanMMRVariance
	file.matchMMRInfo.width = highestMMR - lowestMMR

	#if DEVELOPER
		DEV_script_ranked_debug ("\tMMR_Rank_MatchMMRCalculate end: " )
		DEV_script_ranked_debug ( "\t\tfile.matchMMRInfo.playerCount "  + file.matchMMRInfo.playerCount )
		DEV_script_ranked_debug ( "\t\tfile.matchMMRInfo.standardDeviation " + file.matchMMRInfo.standardDeviation )
		DEV_script_ranked_debug ( "\t\tfile.matchMMRInfo.mean" + file.matchMMRInfo.mean )
		DEV_script_ranked_debug ( "\t\tfile.matchMMRInfo.variance  " + file.matchMMRInfo.variance )
		DEV_script_ranked_debug ( "\t\tfile.matchMMRInfo.width" + file.matchMMRInfo.width )
	#endif
}


float function MMR_Rank_MatchMean ()
{
	return file.matchMMRInfo.mean
}


float function MMR_Rank_MatchMMRSD ()
{
	return file.matchMMRInfo.standardDeviation
}


float function MMR_Rank_MatchWidth ()
{
	return file.matchMMRInfo.width
}


float function MMR_Rank_GetPlayerMMR ( entity player )
{
	if ( !IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_Rank_GetPlayerMMR player has no MMR data" )
		return -1
	}

	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance
	array< float > mmrs = GetPlayerMMR( player )
	return mmrs[0]
}


float function MMR_Rank_GetPlayerMMRVariance ( entity player )
{
	if ( !IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_Rank_GetPlayerMMRVariance player has no MMR data" )
		return -1
	}

	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance
	array< float > mmrs = GetPlayerMMR( player )
	return mmrs[1]
}


float function MMR_Rank_GetTeamMMRByPlayer ( entity player )
{
	if (!IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_Rank_GetTeamMMRByPlayer player has no MMR data" )
		return -1
	}

	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance
	array< float > mmrs = GetPlayerMMR( player )
	return mmrs[2]
}


float function MMR_Rank_GetTeamMMRVarianceByPlayer ( entity player )
{
	if ( !IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_Rank_GetTeamMMRVarianceByPlayer player has no MMR data" )
		return -1
	}

	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance
	array< float > mmrs = GetPlayerMMR( player )
	return mmrs[3]
}

float function MMR_Rank_GetPlayerMMRMod ( entity player )
{
	if ( !IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_OnPlayerConnected player has no MMR data" )
		return -1
	}

	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance 4: playerMod (d value) 5: mmr Adjust (+ up)
	array< float > mmrs = GetPlayerMMR( player )
	return mmrs[4]
}

float function MMR_Rank_GetTeamMMRPremadeAdjust ( entity player )
{
	if ( !IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_OnPlayerConnected player has no MMR data" )
		return -1
	}

	// 0: playerMean, 1: playerVariance, 2:teamMean, 3:teamVariance
	// It is the amount added to the team mean, but it only applies to the members of
	// that players party if your splitting it up individually
	array< float > mmrs = GetPlayerMMR( player )
	return mmrs[5]
}

float function MMR_Rank_GetPostAdjustedMMR ( entity player )
{
	if ( !IsValid (player ) )
		return -1

	if( !HasPlayerMMR( player ) )
	{
		if ( GetConVarBool( "ranked_assert_on_invalid_client_data" ) )
			Assert ( false, "MMR_OnPlayerConnected player has no MMR data" )
		return -1
	}

	array< float > mmrs = GetPlayerMMR( player )

	int premadeSize = GetPlayerPremadeSize ( player )
	float output = mmrs[0]

	if ( premadeSize > 1 )
		output += mmrs[5] / float ( premadeSize )

	return output
}

float function MMR_Rank_GetPlayerEffectiveMMR ( entity player )
{
	array< float > mmrs = GetPlayerMMR( player )
	int score = GetPlayerRankScore( player )

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( score ) //Deliberately only doing score, so will give us Master instead of Apex.
	float pointsInMMR = Ranked_PointsToMMR ( score, oldRank.tier )

	return max ( mmrs[0], pointsInMMR )
}

float function MMR_Rank_GetPlayerEffectiveMMRWithPremadeAdjustment ( entity player )
{
	array< float > mmrs = GetPlayerMMR( player )
	float effectiveMMR =  MMR_Rank_GetPlayerEffectiveMMR ( player )

	int premadeSize = GetPlayerPremadeSize ( player )

	if ( premadeSize > 1 )
		effectiveMMR += mmrs[5] / float ( premadeSize )

	return effectiveMMR
}

int function GetPlayerPremadeSize ( entity player )
{
	int premadeSize = 0

	foreach ( entity teamPlayer in GetPlayerArrayOfTeam( player.GetTeam() ) )
	{
		if ( teamPlayer == player )
			premadeSize++
		else if ( PlayersInSameParty( teamPlayer, player ) )
			premadeSize++
	}

	return premadeSize
}


// ---------------------------
// Bonus Calculation
// ---------------------------

float function GetPerformanceBenchmark ( RankLadderPointsBreakdown breakdown, entity player )
{
	float result = 1.0
	if ( breakdown.placement <= RANKED_POSITIVE_PLACEMENT )
	{
		int idx_placement = breakdown.placement - 1 // array idx is 0-base
		int killMax = file.positivePerformanceScalar [idx_placement].len()
		result += file.positivePerformanceScalar [idx_placement][ minint ( breakdown.kills, killMax - 1 ) ]
	}

	return result
}


float function GetKillValue ( int placement, int kills )
{

	if ( kills == 0 )
		return 0.0

	int idx_placement = placement - 1
	int idx_kills = kills - 1

	int len_placement = file.killValues.len()  //0 indexed

	Assert ( idx_placement < len_placement , idx_placement +" :No such placement found in KillValueBonus Table")

	if ( idx_placement < len_placement)
	{

		int len_kills = file.killValues[idx_placement].len()
		if ( idx_kills < len_kills)
		{
			return file.killValues[idx_placement][idx_kills]
		}
		else
		{
			// For kills exceeding the predefined tuning  - extrapulate linearly up to a cap
			Assert ( len_kills >= 2, "Data table at " + placement + "contains less than 2 kill valuees" )

			float killValueAtMaxKillInData = file.killValues[idx_placement][len_kills-1]
			float killValueAtSecondMaxInData = file.killValues[idx_placement][len_kills-2]
			float delta = killValueAtMaxKillInData - killValueAtSecondMaxInData

			Assert (  delta >= 0 , "KillValue at max decreases")

			int killsDelta = idx_kills - len_kills

			Assert ( killsDelta >= 0 )

			float resultValue = killValueAtMaxKillInData + killsDelta * delta

			return min ( resultValue , RANKED_KILLVALUE_MAX )
		}
	}
	unreachable
}


int function Ranked_GetPlayerDamageDealt ( entity player )
{
	GameSummarySquadData data = GameSummary_GetPlayerData( player )
	return data.damageDealt
}

                  
RankLadderPointsBreakdown function AdjustForEliminiations_S20 ( RankLadderPointsBreakdown breakdown , entity player )
{
	//First kill bonus is based on personal kill score
	breakdown.totalUniqueSquadKills = breakdown.killsUnique + breakdown.assistUnique + breakdown.participationUnique

	breakdown.killBonus = Ranked_GetCombatBonusTotal (  breakdown.killsUnique, breakdown.assistUnique , breakdown.participationUnique, breakdown.placement )     //KP
	//breakdown.firstKillBonus = Ranked_GetPlayerFirstKillBonus ( killAssistUniqueCount , breakdown.placement )

	return breakdown
}
      

RankLadderPointsBreakdown function AdjustForEliminiations ( RankLadderPointsBreakdown breakdown , entity player )
{

	#if DEVELOPER
		//Dev debugging
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "------AdjustForEliminiations for " + player.GetPlayerName() )
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
	#endif

	int killAssistUniqueCount = breakdown.killsUnique + breakdown.assistUnique
	int participationUniqueCount = breakdown.participationUnique

	// Kill switch
	if ( GetConVarBool( "ranked_disable_full_bonus_system" ) || GetConVarBool( "ranked_enable_old_kill_bonus" ) )
	{
		int valuesPerKill = GetCurrentPlaylistVarInt ( "flat_elimination_bonus_value" , 10 )
		breakdown.killBonus =  int ((  Ranked_GetParticipationMutlipler () * participationUniqueCount + killAssistUniqueCount ) * valuesPerKill )
		return breakdown
	}

	// The value of each kill is modified based on if it is a participation or not.
	// We are doing it this way because. the value of a kill might scale based on the number of kills.
	// Ie Diminishing Returns on Kills	
	array < float > multiplier

	//Get the list of multipler for Participation - Particioation is worth 50%
	for ( int i = 0; i < participationUniqueCount; i++  )
		multiplier.append( Ranked_GetParticipationMutlipler() )

	//Value of a kill is unadjusted. So 1.0
	for ( int i = 0; i < killAssistUniqueCount; i++  )
		multiplier.append ( 1.0  )

	//Sort the multiplier from large to small
	multiplier.sort(
		int function( float a, float b ) {
			if ( a < b )
				return -1
			if ( a > b )
				return 1
			return 0
		}
	) // because value of kills increases

	float eliminationPoints = 0

	// Sum  ( the value of N'th kill at i'th placement * Mutliplier )
	// This assumes increasing return on kills.

	for (int i = 0; i < multiplier.len(); i++ )
	{
		float killValue = GetKillValue ( breakdown.placement, i + 1  )
		#if DEVELOPER
			DEV_script_ranked_debug ( "Ascending Multipler["+i+"]: "  + multiplier[i] + " x \t\t\tkillValue["+ (i+1) +"]" + killValue, 2)
		#endif
		eliminationPoints += multiplier[i] * killValue
	}

	#if DEVELOPER
		DEV_script_ranked_debug ( ">>>>> Elimination Bonus "  + eliminationPoints + " <<<<<", 2)
	#endif

	// Tuning Lever: Add multiplier to mod elimination bonus percentage
	eliminationPoints = eliminationPoints * GetCurrentPlaylistVarFloat ( "ranked_tuning_var_fish_tofu" , 1.00 )

	breakdown.killBonus           = int ( eliminationPoints )

	if ( breakdown.killBonus > 0 )
	{
		//Randomization term
		int randomRange = GetCurrentPlaylistVarInt( "ranked_tuning_var_zoom", 2.0 )
		int noise = RandomIntRange ( (eliminationPoints >= randomRange * 2.0 ) ? -1 * randomRange : 0 , randomRange )
		breakdown.killBonus += noise
	}

	breakdown.killBonusUnadjusted = breakdown.killBonus //cache for protected elimination bonus calculation

	return breakdown
}

float function GetEliminationBasedSkillDiffBonus ( RankLadderPointsBreakdown breakdown , entity player )
{

	#if DEVELOPER
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "------GetEliminationBasedSkillDiffBonus for " + player.GetPlayerName() )
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "Player MMR: " +  MMR_Rank_GetPostAdjustedMMR ( player ) , 1 )
	#endif

	//List of Elimination with mmr delta between the victim's MMR and your own MMR
	array< float >  mmrDelta_Kill 		    = GetEliminationMMRDelta ( player, ExtractMMRFromRankedVictimDataByHwUID ( breakdown.killsPlayerByHwUID ) )
	array< float >  mmrDelta_Assists 		= GetEliminationMMRDelta ( player, ExtractMMRFromRankedVictimDataByHwUID ( breakdown.assistsPlayerByHwUID ) )
	array< float >  mmrDelta_Participation  = GetEliminationMMRDelta ( player, ExtractMMRFromRankedVictimDataByHwUID ( breakdown.participationPlayerByHwUID ) )

	int killAssistUniqueCount = breakdown.killsPlayerByHwUID.len() + breakdown.assistsPlayerByHwUID.len()
	int participationUniqueCount = breakdown.participationPlayerByHwUID.len()

	array < float > multiplier
	multiplier.extend ( ArrayMMRDeltaToKillMultiplier ( mmrDelta_Kill ) )
	multiplier.extend ( ArrayMMRDeltaToKillMultiplier ( mmrDelta_Assists ) )
	multiplier.extend ( ArrayMMRDeltaToKillMultiplier ( mmrDelta_Participation ) ) //intentionally no participation mod

	multiplier.sort(
		int function( float a, float b ) {
			if ( a < b )
				return -1
			if ( a > b )
				return 1
			return 0
		}
	) // because value of kills increases

	float skillDiffAdjustment = 0

	for (int i = 0; i < multiplier.len(); i++ )
	{
		float killValue = GetKillValue ( breakdown.placement, i + 1  )
		#if DEVELOPER
			DEV_script_ranked_debug ( "Ascending Multipler["+i+"]: "  + multiplier[i] + " x \t\t\tkillValue["+ (i+1) +"]" + killValue, 2)
		#endif
		skillDiffAdjustment +=  multiplier[i]  * killValue
	}

	#if DEVELOPER
		DEV_script_ranked_debug ( ">>>> skillDiffAdjustment Bonus "  + skillDiffAdjustment + "<<<<" , 2)
	#endif

	return skillDiffAdjustment
}


array < float > function GetEliminationMMRDelta ( entity player, array < float > victimsToMMR )
{
	// In elimniations calculations, we use adjusted MMR based on
	// matchmaking rules, because adjustment is suppose to equalize them
	array < float > result

	if ( victimsToMMR.len() == 0 )
		return result

	float playerMMR = MMR_Rank_GetPostAdjustedMMR ( player )

	Assert ( playerMMR >= 0 , "Player mmr lower than zero; " + player.GetPlayerName() )

	foreach ( float victimAdjustedMMR in victimsToMMR )
	{
		if ( victimAdjustedMMR < 0 )
			continue

		float delta = victimAdjustedMMR - playerMMR
		result.append( delta )
	}

	#if DEVELOPER
		if( GetConVarBool( "script_ranked_debug" ) )
		{
			array <float> victimList
			foreach ( float victimAdjustedMMR in victimsToMMR )
				victimList.append( victimAdjustedMMR )

			string mmrOutput = ""
			foreach ( float v in victimList)
				mmrOutput += v + " "

			//print the array
			string output = ""
			foreach ( float f in result)
				output += f + " "

			DEV_script_ranked_debug ("Victim MMR <" + mmrOutput + ">" , 2 )
			DEV_script_ranked_debug ("GetEliminationMMRDelta() <" + output + ">" , 2 )
		}
	#endif

	return result
}


array < float > function ArrayMMRDeltaToKillMultiplier ( array <float> mmrDelta )
{
	array <float > result

	foreach ( float delta in mmrDelta )
	{
		result.append( MMRDeltaToKillMultiplier ( delta ) )
	}

	return result
}


float function MMRDeltaToKillMultiplier ( float mmrDelta )
{
	// For now linearly, we should update this to be expotential.
	// Every 1 mmr is 10% increase, and if its negative, it's minus.

	float scalar = GetCurrentPlaylistVarFloat( "ranked_tuning_var_banana", 0.1 )
	float mmrStep = GetCurrentPlaylistVarFloat( "ranked_tuning_var_inferno", 1.0 )
	float maxKillMultiplier = GetCurrentPlaylistVarFloat( "ranked_tuning_var_ice",   1.75 )
	float minKillMultiplier = GetCurrentPlaylistVarFloat( "ranked_tuning_var_boba", -0.5 )

	float multiplier = ( mmrDelta / mmrStep ) * scalar

	if ( mmrDelta >= 0 )
	{
		multiplier = min ( multiplier, GetCurrentPlaylistVarFloat( "ranked_tuning_var_chair", maxKillMultiplier ) )
	}
	else
	{
		multiplier = max ( multiplier, GetCurrentPlaylistVarFloat( "ranked_tuning_var_armrest", minKillMultiplier ) )  //<-- diff from simulation
	}

	return multiplier
}

RankLadderPointsBreakdown function AdjustForHighEndTiers ( RankLadderPointsBreakdown breakdown )
{

	#if DEVELOPER
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "------AdjustForHighEndTiers" )
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
	#endif

	//if not high end, please leave OR if we are no longer adjusting for it with bonuses
	if ( !breakdown.isHighTier || GetCurrentPlaylistVarBool ("Ranked_Scaling_EntryCost" , false ))
	{
		#if DEVELOPER
			DEV_script_ranked_debug ( "Not High Tier" , 1 )
		#endif
		return breakdown
	}

	if ( breakdown.netLP < 0 )
	{
		breakdown.highEndAdjustment = int ( breakdown.netLP * ( GetHighEndLostMultiplier() - 1.0 ) )
		breakdown.netLP = int ( float ( breakdown.netLP ) * GetHighEndLostMultiplier() )

		#if DEVELOPER
			DEV_script_ranked_debug ( "startingLP: " + breakdown.startingLP , 1 )
			DEV_script_ranked_debug ( "highEndAdjustment: " + breakdown.highEndAdjustment , 1 )
			DEV_script_ranked_debug ( "net LP: " + breakdown.netLP , 1 )
		#endif
	}

	return breakdown
}

RankLadderPointsBreakdown function AdjustForConvergence ( RankLadderPointsBreakdown breakdown , entity player )
{

	// Convergence Bonus = Rating Bonus

	if ( GetConVarBool( "ranked_disable_full_bonus_system" ) )
		return breakdown

	#if DEVELOPER
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "------AdjustForConvergence for " + player.GetPlayerName() )
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
	#endif
	// in convergences, we use true MMR / unadjusted because it is only MMR <--> LP that we care about.

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP ) //Deliberately only doing score, so will give us Master instead of Apex.

	float playerMMR = MMR_Rank_GetPlayerMMR ( player )
	float pointsInMMR = Ranked_PointsToMMR ( breakdown.startingLP , oldRank.tier )

	bool masterPlusConvergenceToggle = GetCurrentPlaylistVarBool( "ranked_tuning_var_harness", false )


	#if DEVELOPER
		DEV_script_ranked_debug ( "Player MMR: " + playerMMR , 1 )
		DEV_script_ranked_debug ( "Player LP Starting: " +  breakdown.startingLP , 1 )
		DEV_script_ranked_debug ( "Points As MMR: " + pointsInMMR , 1 )

	#endif

	//masters players don't get convergence bonuses if their LP is converged
	if ( playerMMR >= MMR_MASTER_BREAKPOINT + Ranked_Get_MMR_Overlap_Positive () && pointsInMMR >= MMR_MASTER_BREAKPOINT + Ranked_Get_MMR_Overlap_Negative() && masterPlusConvergenceToggle )
		return breakdown

	//this shifts the player's MMR lower or higher to control when the convergence bonus starts
	//negative value here hasten the negative bonuses
	float negativeMMRAdjust = GetCurrentPlaylistVarFloat( "ranked_tuning_var_unicorn", -5.0 )
	playerMMR += negativeMMRAdjust

	playerMMR = max ( playerMMR , 0.0 )

	//positive = MMR >> LP
	//negative = LP >> MMR
	float mmr_deltaLpToMMR = playerMMR - pointsInMMR
	float mmr_deltaLpToMMRAdjusted = mmr_deltaLpToMMR

	float positiveMMRCutoff = GetCurrentPlaylistVarFloat( "ranked_tuning_var_pick_a_book", 15.0 )
	float positiveMMRCutoffSecondary = GetCurrentPlaylistVarFloat( "ranked_tuning_var_let_it_go", 4.0 )

	float negativeMMRCutoff = GetCurrentPlaylistVarFloat( "ranked_tuning_var_reads_like_a_story", -1.0 )
	float negativeMMRCutoffSecondary = GetCurrentPlaylistVarFloat( "ranked_tuning_var_who_cares", -0.5 )

	#if DEVELOPER
		DEV_script_ranked_debug ( "mmr_deltaLpToMMR " + mmr_deltaLpToMMR , 1 )
		DEV_script_ranked_debug ( "positiveMMRCutoff" +  positiveMMRCutoff, 1 )
		DEV_script_ranked_debug ( "positiveMMRCutoffSecondary" +  positiveMMRCutoffSecondary, 1 )
		DEV_script_ranked_debug ( "negativeMMRCutoff" +  negativeMMRCutoff, 1 )
		DEV_script_ranked_debug ( "negativeMMRCutoffSecondary" +  negativeMMRCutoffSecondary, 1 )
	#endif

	if ( mmr_deltaLpToMMR >= positiveMMRCutoff || mmr_deltaLpToMMR <= negativeMMRCutoff )
	{
		//this behavior is only turned ON if the player's MMR is at least more than +- 1.0 from the player's current MMR

		float highEndMultiplier = 1.0

		if ( mmr_deltaLpToMMR >= positiveMMRCutoff  )
		{

			//-----------------------------------------------
			// Positive case
			//-----------------------------------------------
			// - we are trying to actively pull you up. When you are losing LP, you give you points to migiate loses
			/// or more points bonuses to pull you up.

			// positive = MMR >> LP

			float positiveMMRScalar = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_rampart" , 0.05 ) // 7.5% boost per MMR
			float positiveMMRBase = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_mirage" , 0.025 ) // start at 5%


			mmr_deltaLpToMMRAdjusted -= positiveMMRCutoff
			mmr_deltaLpToMMRAdjusted -= positiveMMRCutoffSecondary //determine scaling amount of MMR
			mmr_deltaLpToMMRAdjusted = max ( mmr_deltaLpToMMRAdjusted, 0 ) // from 1 to 1.5, will becomes negative.

			float bonus_mutiplier = positiveMMRBase + mmr_deltaLpToMMRAdjusted * positiveMMRScalar
			#if DEVELOPER
				DEV_script_ranked_debug ( "positiveMMRScalar" +  positiveMMRScalar, 1 )
				DEV_script_ranked_debug ( "positiveMMRBase" +  positiveMMRBase, 1 )
				DEV_script_ranked_debug ( "mmr_deltaLpToMMRAdjusted" +  mmr_deltaLpToMMRAdjusted, 1 )
				DEV_script_ranked_debug ( "pre-cap bonus_mutiplier" +  bonus_mutiplier, 1 )
			#endif
			if ( breakdown.placementScore >= 0 )
			{
				//-----------------------------------------------
				// Winning case, amp gains
				//-----------------------------------------------

				// intended to be done prior to bonuses based on large MMR delta.
				// bonuses normally are capped at 1.5 x of placement score
				float winMultiplerCap = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_wraith" , 1.5 )
				bonus_mutiplier  = min (  bonus_mutiplier, winMultiplerCap)

				#if DEVELOPER
					DEV_script_ranked_debug ( "Positive Delta Winning case - amp gains", 1 )
					DEV_script_ranked_debug ( "winMultiplerCap " + winMultiplerCap , 1 )
					DEV_script_ranked_debug ( "bonus_mutiplier" +  bonus_mutiplier, 1 )
				#endif

				// based on simulation results
				// 10% is NOT enough at the higher end,
				// if their delta is really big, we give it an extra kick on winning
				// so this is done AFTER limit setting.
				bonus_mutiplier *= GetConvergenceMultiplerMod ( mmr_deltaLpToMMR  )

				//win while MMR >> LP
				if ( oldRank.tier.isTopEnd )
					highEndMultiplier *= GetCurrentPlaylistVarFloat ( "ranked_tuning_var_high_plus_positive" , 1.0 )

			}
			else
			{
				//-----------------------------------------------
				// losing case. Reduce loses
				//-----------------------------------------------

				// you must always lose points... cap it.
				float lostMultiplerCap = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_wattson" , 25.0 / 35.0 ) //max lost prevented is 25 LP of 35 LP ~71.4%
				bonus_mutiplier = min ( bonus_mutiplier , lostMultiplerCap )

				//lost while MMR >> LP
				if ( oldRank.tier.isTopEnd )
					highEndMultiplier *= GetCurrentPlaylistVarFloat ( "ranked_tuning_var_high_plus_negative" , 1.0 )

				#if DEVELOPER
					DEV_script_ranked_debug ( "Positive Delta Losing case - reduce loses", 1 )
					DEV_script_ranked_debug ( "lostMultiplerCap " + lostMultiplerCap , 1 )
					DEV_script_ranked_debug ( "bonus_mutiplier" +  bonus_mutiplier, 1 )
				#endif
			}

			#if DEVELOPER
				DEV_script_ranked_debug ( "highEndMultiplier" +  highEndMultiplier, 1 )
			#endif

			// because your MMR >> LP, you are always going to GAIN convergence bonuses,
			// this way, it mitigates losses consistently.
			breakdown.convergenceBonus = int ( fabs ( bonus_mutiplier * breakdown.placementScore * highEndMultiplier )) //<--- PERFORMANCE BASED here
		}
		else //mmr_deltaLpToMMR <= negativeMMRCutoff
		{
			//-----------------------------------------------
			// Negative case
			//-----------------------------------------------
			// - we are trying to
			// negative = LP >> MMR

			float negativeMMRScalar = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_newcastle" , -0.20 ) // 20% boost per MMR
			float negativeMMRBase   = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_bangalore " , -0.20 ) // 20% boost per MMR

			// mmr_deltaLpToMMR is negative
			mmr_deltaLpToMMRAdjusted -= negativeMMRCutoff
			mmr_deltaLpToMMRAdjusted -= negativeMMRCutoffSecondary //determine scaling amount of MMR
			mmr_deltaLpToMMRAdjusted = min (0, mmr_deltaLpToMMRAdjusted )  // from -1 to -1.5, will becomes positive.

			//all variables here are negatives. so we are using - to ensure signs
			float reduction_mutiplier = negativeMMRBase - ( mmr_deltaLpToMMRAdjusted * negativeMMRScalar )

			#if DEVELOPER
				DEV_script_ranked_debug ( "Negative Case: "  )
				DEV_script_ranked_debug ( "negativeMMRScalar" +  negativeMMRScalar, 1 )
				DEV_script_ranked_debug ( "negativeMMRBase" +  negativeMMRBase, 1 )
				DEV_script_ranked_debug ( "mmr_deltaLpToMMRAdjusted" +  mmr_deltaLpToMMRAdjusted, 1 )
				DEV_script_ranked_debug ( "pre-cap reduction_mutiplier" +  reduction_mutiplier, 1 )
			#endif

			if ( breakdown.placementScore >= 0 )
			{
				//-----------------------------------------------
				// Winning case. Reduce other bonuses...
				//-----------------------------------------------

				//maxinum amount of bonus we would take away from
				float winReductionMultiplerCap = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_ontario" , -5.0 )
				reduction_mutiplier  = max (  reduction_mutiplier, winReductionMultiplerCap)

				//win while LP >> MMR
				if ( oldRank.tier.isTopEnd )
					highEndMultiplier *= GetCurrentPlaylistVarFloat ( "ranked_tuning_var_high_minus_positive" , 1.0 )

			}
			else
			{
				//-----------------------------------------------
				// losing case. Reduce other bonuses...
				//-----------------------------------------------

				//since loses are lower than gains, we can be mean here...
				float loseReductionMultiplerCap = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_canada" , -5.0 )
				reduction_mutiplier  = max (  reduction_mutiplier, loseReductionMultiplerCap )

				//loss while LP >> MMR
				if ( oldRank.tier.isTopEnd )
					highEndMultiplier *= GetCurrentPlaylistVarFloat ( "ranked_tuning_var_high_minus_negative" , 1.0 )

			}

			#if DEVELOPER
				DEV_script_ranked_debug ( "reduction_mutiplier" +  reduction_mutiplier, 1 )
			#endif
			// if we need to do some extra negative pull
			// same as above, intentionally applied AFTER caps are set
			// double multiply is easier to tune than a single curve
			float skillAmp = GetConvergenceMultiplerModNegative (mmr_deltaLpToMMR )
			reduction_mutiplier *= skillAmp

			#if DEVELOPER
				DEV_script_ranked_debug ( "reduction_mutiplier post_skill" +  reduction_mutiplier, 1 )
				DEV_script_ranked_debug ( "skillAmp" +  skillAmp, 1 )

                      
					DEV_script_ranked_debug ( "entry cost " +  abs( Ranked_GetCostForEntry( oldRank )), 1 )
         
                                                                                   
          

				DEV_script_ranked_debug ( "highEndMultiplier" +  highEndMultiplier, 1 )
			#endif
			// we don't need to multiple by placement. just always be heavy

                     
				breakdown.convergenceBonus =  int ( reduction_mutiplier * abs( Ranked_GetCostForEntry( oldRank )) * highEndMultiplier  )  //<-- entry cost here. NOT placement
        
                                                                                                                                                         
         
		}
	}

	                  
	//Rookie Speical case
	if ( playerMMR < MMR_TIER_WIDTH + Ranked_Get_MMR_Overlap_Positive () &&
		 pointsInMMR < MMR_TIER_WIDTH + Ranked_Get_MMR_Overlap_Positive ()&&
		 Ranked_HasCompletedProvisionalMatches( player ) )
	{

		// If Roookie, and not in Provisional, and convergence is negative, zero out.
		if ( breakdown.convergenceBonus < 0 )
			breakdown.convergenceBonus = 0

		// If Roookie, and not in Provisional, and convergence bonus gets a boost..  ( ?? )
		int pityMin = GetCurrentPlaylistVarInt( "ranked_tuning_var_splitfire", 5 )
		int pityMax = GetCurrentPlaylistVarInt( "ranked_tuning_var_lstar", 25 )
		int pityBonus = RandomIntRange ( pityMin , pityMax )
		breakdown.convergenceBonus += pityBonus
	}
       

	#if DEVELOPER
		DEV_script_ranked_debug ( "\t>>>>>convergenceBonus: " +  breakdown.convergenceBonus + " <<<<" )
	#endif

	return breakdown
}

float function GetResteMMRDrop ()
{
	float tierOfDrop = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_skyfall" , 2.0 )
	return MMR_TIER_WIDTH * tierOfDrop
}

int function GetResetLPTarget ( float playerTargetMMR )
{
	float targetMMR = playerTargetMMR - GetResteMMRDrop()
	float conversionRate = float ( LP_TIER_WIDTH ) / MMR_TIER_WIDTH
	int targetRP = int ( targetMMR * conversionRate )
	return maxint ( SHARED_RANKED_ROOKIE_FLOOR_VALUE , targetRP )
}


                  
RankLadderPointsBreakdown function AdjustForTop5Streak( RankLadderPointsBreakdown breakdown, entity player )
{

	#if DEVELOPER
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "------AdjustForTop5Streak for " + player.GetPlayerName() )
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
	#endif


	int streakCount = Ranked_GetPlayerTop5StreakCount ( player )
	if ( breakdown.placement <= 5 )
	{
		streakCount++
	}
	else
	{
		streakCount = 0
	}

	breakdown.top5Streak = streakCount
	breakdown.top5StreakBonusValue = Ranked_GetTop5StreakBonusValueFromStreak ( streakCount )

	#if DEVELOPER
		DEV_script_ranked_debug ( "streakCount: " + streakCount, 1 )
		DEV_script_ranked_debug ( "top5StreakBonusValue: " + breakdown.top5StreakBonusValue, 1 )
	#endif

	return breakdown
}


RankLadderPointsBreakdown function AdjustForDemoCrewBonus( RankLadderPointsBreakdown breakdown )
{
	breakdown.demoCrewBonus = Ranked_GetLivingLegendBonus ( breakdown.totalUniqueSquadKills, breakdown.placement )
	return breakdown
}


RankLadderPointsBreakdown function AdjustForHighSkillKill( RankLadderPointsBreakdown breakdown, entity player , int playerRankScore )
{
	array< int > bonusData = Ranked_GetHighSkillKillBonus ( player, playerRankScore, breakdown.killsPlayerByHwUID,  breakdown.assistsPlayerByHwUID,  breakdown.placement  )
	breakdown.highSkillKill = bonusData[0]
	breakdown.highSkillKillBonusValue = bonusData[1]
	return breakdown
}

array< int > function Ranked_GetHighSkillKillBonus ( entity player, int rankScore , table< string, RankedVictimData >  killsPlayerByHwUID, table< string, RankedVictimData > assistsPlayerByHwUID, int placement)
{

	#if DEVELOPER
		DEV_script_ranked_debug ( "-------------------------------------------" )
		DEV_script_ranked_debug ( "Ranked_GetHighSkillKillBonus for player: " + player.GetPlayerName()  )
		DEV_script_ranked_debug ( "-------------------------------------------"  )
	#endif

	int killValue = RankedGetPointsForKillsByPlacement ( placement )

	#if DEVELOPER
		DEV_script_ranked_debug ( "placement: " + placement , 1 )
		DEV_script_ranked_debug ( "killValuer: " + killValue , 1 )
	#endif

	array < int > victimRP
	victimRP.extend ( ( ExtractRPFromRankedVictimDataByHwUID ( killsPlayerByHwUID ) ) )
	victimRP.extend ( ( ExtractRPFromRankedVictimDataByHwUID ( assistsPlayerByHwUID ) ) )


	//float skillDiffReqForBonus = Ranked_GetHighSkillKillSkillDiffRequirement ()

	int playerRankTierIndex = GetCurrentRankedDivisionFromScore( rankScore ).tier.index

	int highSkillKillCount = 0
	int totalBonus = 0

	#if DEVELOPER
		DEV_script_ranked_debug ( "killsPlayerByHwUID.len: " + killsPlayerByHwUID.len() , 1 )
		DEV_script_ranked_debug ( "assistsPlayerByHwUID.len: " + assistsPlayerByHwUID.len() , 1 )
		DEV_script_ranked_debug ( "victimRP.len: " + victimRP.len() , 1 )
		DEV_script_ranked_debug ( "playerRankTierIndex: " + playerRankTierIndex , 1 )
	#endif

	//count number of kills with differences higher than X
	foreach ( int thisVictimRP in victimRP)
	{
		if ( playerRankTierIndex < GetCurrentRankedDivisionFromScore( thisVictimRP ).tier.index )
		{
			highSkillKillCount++
		}
	}

	array <int> result
	float valuePerHighSkillKill = Ranked_GetHighSkillKillBonusValue ()

	result.append ( highSkillKillCount )
	result.append ( int ( valuePerHighSkillKill * highSkillKillCount * killValue ) )

	#if DEVELOPER
		DEV_script_ranked_debug ( "valuePerHighSkillKill: " + valuePerHighSkillKill , 1 )
		DEV_script_ranked_debug ( "highSkillKillCount: " + highSkillKillCount , 1 )
		DEV_script_ranked_debug ( "result[0]: " + result[0] , 1 )
		DEV_script_ranked_debug ( "result[1]: " + result[1] , 1 )
	#endif

	return result
}
      


RankLadderPointsBreakdown function AdjustForSkillDifferences( RankLadderPointsBreakdown breakdown, entity player )
{

	if ( GetConVarBool( "ranked_disable_full_bonus_system" ) )
		return breakdown

	//Kill based Skill bonuses
	int eliminationBasedSkillDiffBonus = int ( GetEliminationBasedSkillDiffBonus ( breakdown, player ) )
	breakdown.skillDiffBonus = eliminationBasedSkillDiffBonus

	//Match level bonuses
	float matchWidth = MMR_Rank_MatchWidth()
	float matchWidthLimit = GetCurrentPlaylistVarFloat( "ranked_tuning_var_firetruck", 20.0 ) //Todo consider  using 10 to 90th percentile.

	//If the match is not wide enough skip.
	if ( matchWidth < matchWidthLimit )
		return breakdown

	float matchMean =  MMR_Rank_MatchMean()
	float matchSD = MMR_Rank_MatchMMRSD()
	float playerMMR = MMR_Rank_GetPostAdjustedMMR( player )
	float standardDevFromMatchMean = ( matchSD == 0.0 ) ? 0.0 : ( playerMMR - matchMean ) / matchSD

	float positiveSDLimit = GetCurrentPlaylistVarFloat( "ranked_tuning_var_mail", 1.0 )
	float negativeSDLimit = GetCurrentPlaylistVarFloat( "ranked_tuning_var_critique", -1.0 )

	//Since this match is kind of wide...
	int mitigation = 0
	if ( breakdown.placementScore < 0 ) //negative;
	{
		if ( standardDevFromMatchMean < negativeSDLimit ) //the match was indeed unfair enough
		{

			//    # Loss mitigation on bottom
			//    ## Checked with dummie data
			//    ### Positive Value when in effect
			//    if (placement_rp < 0) and (player_sd_from_mean < -1): # cut losses by 75% to 15% linearly based on RP tier. (Rookie 75%--> Diamond 15%)
			//        percent_cut = max ( 0.75 - ( starting_rp / 10 * 0.1) , 0.10 )
			//        mitigation = min(int ( abs(placement_rp) * percent_cut ),max(int(abs(placement_rp/2)),10))

			//cut losses by 75% to 10% linearly based on RP tier. (Rookie 75%--> Diamond 10%)
			float lossPreventionMax = GetCurrentPlaylistVarFloat( "ranked_tuning_var_community", 0.75 )
			float lossPreventionMin = GetCurrentPlaylistVarFloat( "ranked_tuning_var_steak", 0.10 )
			float lossPreventRange  = lossPreventionMax - lossPreventionMin

			int lowerLPThreshhold   =  GetCurrentPlaylistVarInt( "ranked_tuning_var_arise", 0 )
			int higherLPThreshhold  =  GetCurrentPlaylistVarInt( "ranked_tuning_var_invisible", 24000 )
			float lpThreshholdRange = float ( higherLPThreshhold - lowerLPThreshhold )

			float lossPrevention    = lossPreventionMax - ( lossPreventRange  * float ( breakdown.startingLP - lowerLPThreshhold ) /  lpThreshholdRange )

			float percentCut        = max ( lossPrevention,lossPreventionMin ) //anyone above diamond, gets 0.1

			int lossPreventionAbsMinValueInLP = GetCurrentPlaylistVarInt( "ranked_tuning_var_teddy", 6 + RandomIntRange ( 0, 4 ))    //min VALUE in LP for mitigation
			mitigation = maxint ( int ( breakdown.placementScore * percentCut ) , lossPreventionAbsMinValueInLP )  //impose an actual min value regardless of placement values
		}
		else if ( standardDevFromMatchMean > positiveSDLimit  )
		{

			//# Loss boost on top
			//    ## Checked with dummie data
			//    ### Negative value when in effect
			//    if (placement_rp < 0) and (player_sd_from_mean > 1): # every 1 SD higher than 1, lose 0.2 (scale)
			//        scale = 0.2
			//        mitigation  =	max(int ( ( 1.0 - ( 3.0  - player_sd_from_mean ) * scale ) * placement_rp ),int(abs(placement_rp/2)*-1))


			//the match was highly flavorable to you
			//and you lost, you get less bonuses
			//every 1 SD higher than 1 SD, lose 0.2 (scale)

			//remember placement is already negative
			float percentLostPerSDFromThreshhold = GetCurrentPlaylistVarFloat( "ranked_tuning_var_catlitter", 0.2 ) //per 1 SD, subtract 20%
			int   mitigiationValuePerAdjust      = int ( ( standardDevFromMatchMean - positiveSDLimit ) * percentLostPerSDFromThreshhold * float ( breakdown.placementScore ) )

			float mitigationPercentageOfPlacement = GetCurrentPlaylistVarFloat( "ranked_tuning_var_daycare", 0.5 ) //the harshest punishment is 50% of their placements
			int   mitigiationFloor                = int ( float ( breakdown.placementScore ) * mitigationPercentageOfPlacement )

			mitigation = maxint ( mitigiationValuePerAdjust,	mitigiationFloor  )  //placement score is a negative!!!

		}
	}
	else
	{
		//positive placement score
		if ( standardDevFromMatchMean < negativeSDLimit  ) //if the match was unfavorable to you
		{

			//   # Win boost on bottom
			//    ### Positive value when in effect
			//    if (placement_rp >= 0) and (player_sd_from_mean < -1): # 10 to 100% of placements if the match was unfavorable to you, where each 1 sd is 45% (scale)
			//        scale = 0.45
			//        mitigated_rp  =	int ( ( 1.0 - ( -3.0  - player_sd_from_mean ) * scale ) * placement_rp  )
			//        mitigation = min(abs ( mitigated_rp ),max(int(abs(placement_rp/2)),10))

			//10 to 100% of placements...

			//each 1 sd is 45% (scale)

			int   mitigationFloor                 = GetCurrentPlaylistVarInt( "ranked_tuning_var_schoolbus", 6 + RandomIntRange ( 0, 4 ) )
			float mitigationPercentageOfPlacement = GetCurrentPlaylistVarFloat( "ranked_tuning_var_slippers", 0.5 )

			float bonusMax = GetCurrentPlaylistVarFloat( "ranked_tuning_var_shoes", 1.00 )
			float bonusMin = GetCurrentPlaylistVarFloat( "ranked_tuning_var_wheels", 0.10 )
			float bonusRange  = bonusMax - bonusMin

			float deltaSDFromThreshhold = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_chris", -3.0 )  //the SD at which MMR max out

			float multiplier = min ( bonusMin + ( bonusRange *  ( standardDevFromMatchMean - negativeSDLimit ) / deltaSDFromThreshhold )  , bonusMax )

			mitigation = maxint ( int (breakdown.placementScore * multiplier ) , mitigationFloor )

		}
		else if ( standardDevFromMatchMean > positiveSDLimit  ) //the match was highly flavorable to you
		{
			//    # Win mitigation on top
			//    ## Checked with dummie data
			//    ### Negative value when in effect
			//    if (placement_rp >= 0) and (player_sd_from_mean > 1): # every 1 SD higher than 1, lose 0.2 (scale)
			//        scale = 0.2
			//        mitigation  =	max(int ( ( 1.0 - ( 3.0  - player_sd_from_mean ) * scale ) * placement_rp ) * -1,int(abs(placement_rp/2)*-1))

			//reduce other bonuses, by presenting a negative value

			//every 1 SD higher than 1, lose 0.2 (scale)

			int   mitigationFloor                 = GetCurrentPlaylistVarInt( "ranked_tuning_var_stripes", 6 + RandomIntRange ( 0, 4 ) )
			float mitigationPercentageOfPlacement = GetCurrentPlaylistVarFloat( "ranked_tuning_var_stars", 0.5 )

			float bonusReductionMax    = GetCurrentPlaylistVarFloat( "ranked_tuning_var_eagle", 0.50 )
			float bonusReductionMin     = GetCurrentPlaylistVarFloat( "ranked_tuning_var_merica", 0.10 )
			float bonusReductionRange  = bonusReductionMax - bonusReductionMin

			float deltaSDFromThreshhold = GetCurrentPlaylistVarFloat ( "ranked_tuning_var_titanfall", 4 )  //the SD at which MMR max out

			float multiplier =  min ( bonusReductionMin + ( bonusReductionRange *  ( standardDevFromMatchMean - positiveSDLimit ) / deltaSDFromThreshhold )  , bonusReductionMax )

			mitigation = minint ( int ( -1 * breakdown.placementScore * multiplier ) , -1 * mitigationFloor  )
		}
	}

	breakdown.skillDiffBonus += mitigation

	if ( breakdown.wasInProvisonalGame )
	{
		if ( breakdown.skillDiffBonus < 0 )
			breakdown.skillDiffBonus = 0      //null out negative bonuses during provisionals
	}

	return breakdown
}

int function GetLPResetTarget ()
{
	return GetCurrentPlaylistVarInt ( "ranked_tuning_var_starfall" , LP_TIER_RESET_TARGET )
}

                  
RankLadderPointsBreakdown function AdjustForProvisionalGames_S20 ( RankLadderPointsBreakdown breakdown, entity player )
{

	#if DEVELOPER
		DEV_script_ranked_debug ( "-------------------------------------------" )
		DEV_script_ranked_debug ( "AdjustForProvisionalGames_S20" + player.GetPlayerName()  )
		DEV_script_ranked_debug ( "-------------------------------------------"  )
	#endif

	if ( GetConVarBool( RANKED_PROVISIONAL_MATCH_CONVAR_KILL_SWITCH ) )
		return breakdown

	if ( !breakdown.wasInProvisonalGame ) // not done Provisional
	{
		return breakdown
	}

	//ensure entry cost was zero
	Assert ( breakdown.entryCost == 0 )


	// Do not count if ( negative && loss forgiven)
	// If Loss Forgiven was given, thus provisional game count was not increased
	// then we are going to skip provisional bonus, since provisional game was not increased.
	if	( breakdown.netLP == 0 && breakdown.lossForgiveness )
	{
		return breakdown
	}
	//save points only if NOT loss forgiven

	int provisionalsGamesCompleted = Ranked_GetNumProvisionalMatchesCompleted ( player )

	Assert ( provisionalsGamesCompleted >= 0, "Number of provisionals games played should not be negative" )
	Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, provisionalsGamesCompleted + 1 )

	#if DEVELOPER
		DEV_script_ranked_debug ( "increasing `rankedProvisionalMatchesCompleted` to :" + ( provisionalsGamesCompleted + 1 ), 1  )
	#endif

	provisionalsGamesCompleted++

	//If it is the final game. determine final placement landing.

	int maxGames = Ranked_GetNumProvisionalMatchesRequired()

	//if the last match of provisonal, we inc counter above
	if ( provisionalsGamesCompleted >= maxGames )
	{

		//Rank based
		ItemFlavor rankedPeriod 						= expect ItemFlavor ( Ranked_GetCurrentActiveRankedPeriod() )
		ItemFlavor previousRankedPeriod 				= expect ItemFlavor ( GetPrecedingRankedPeriod( rankedPeriod ) )
		string previousRankedPeriodRef  				= ItemFlavor_GetGUIDString( previousRankedPeriod )
		int previousRankedScore             			= Ranked_GetHistoricalRankScore( player, previousRankedPeriodRef )
		SharedRankedDivisionData oldDivison 			= Ranked_GetHistoricalRankedDivisionFromScore ( previousRankedScore, previousRankedPeriodRef )
		SharedRankedDivisionData ornull currentDivision = FindRankDivisionWithSameNameInCurrentRankPeriod ( oldDivison.divisionName )

		#if DEVELOPER
			DEV_script_ranked_debug ( "previousRankedScore " + previousRankedScore )
			DEV_script_ranked_debug ( "oldDivison.divisionName " + oldDivison.divisionName )
		#endif

		int lastSeasonDivisionFloor = 0
		if ( currentDivision != null )
		{
			expect SharedRankedDivisionData ( currentDivision )
			int resetIndex = maxint ( 0 , currentDivision.index - int ( GetResteMMRDrop() + GetCurrentPlaylistVarFloat ( "ranked_mmr_reset_tier_drop_ranked" , 1.0 )  * 4 ) )

			SharedRankedDivisionData newDivision 	= GetCurrentRankedDivisions()[resetIndex]
			lastSeasonDivisionFloor 				= newDivision.scoreMin

			#if DEVELOPER
				DEV_script_ranked_debug ( "resetIndex " + resetIndex )
				DEV_script_ranked_debug ( "newDivision.divisionName " + newDivision.divisionName )
			#endif
		}

		#if DEVELOPER
			DEV_script_ranked_debug ( "lastSeasonDivisionFloor " + lastSeasonDivisionFloor )
		#endif

		//MMR based
		float playerMMR                   	= min ( MMR_Rank_GetPlayerMMR ( player ) * MMR_Rank_GetPlayerMMRMod ( player ), MMR_MASTER_BREAKPOINT )
		float mmrTierDrop                 	= GetResteMMRDrop ()
		float targetMMR                   	= max ( 0 , playerMMR - mmrTierDrop )
		int resetPoint                     	= Ranked_MMRToPoints_S20 ( targetMMR )
		resetPoint 							= maxint ( lastSeasonDivisionFloor, resetPoint )
		SharedRankedDivisionData resetRank 	= GetCurrentRankedDivisionFromScore( resetPoint )
		breakdown.provisionalMatchBonus 	= resetRank.scoreMin

		#if DEVELOPER
			DEV_script_ranked_debug ( "-finding new placement spot-" )
			DEV_script_ranked_debug ( "playerMMR "  + playerMMR )
			DEV_script_ranked_debug ( "mmrTierDrop "  + mmrTierDrop )
			DEV_script_ranked_debug ( "targetMMR "  + targetMMR )
			DEV_script_ranked_debug ( "resetPoint "  + resetPoint )
			DEV_script_ranked_debug ( "resetPointTierName "  + resetRank.divisionName )
			DEV_script_ranked_debug ( "provisionalMatchBonus "  + breakdown.provisionalMatchBonus )
		#endif
	}

	return breakdown
}

SharedRankedDivisionData ornull function FindRankDivisionWithSameNameInCurrentRankPeriod ( string divisionName )
{
	array<SharedRankedDivisionData>  data = GetCurrentRankedDivisions()

	foreach ( SharedRankedDivisionData division in data )
	{
		if ( division.divisionName == divisionName )
		{
			return division
		}
	}

	Assert ( false, "Can not find division named: " + divisionName )
	return null
}
      

RankLadderPointsBreakdown function AdjustForProvisionalGames (RankLadderPointsBreakdown breakdown, entity player)
{

	if ( GetConVarBool( "ranked_disable_full_bonus_system" ) )
		return breakdown

	if ( GetConVarBool( RANKED_PROVISIONAL_MATCH_CONVAR_KILL_SWITCH ) )
		return breakdown

	// when in provisionals:
	// - total points is amplifed (including other bonuses)
	// - loses are fully forgiven
	// Do not count placement match if player has loss forgiveness and also lost

	#if DEVELOPER
		DEV_script_ranked_debug ( "-------------------------------------------" )
		DEV_script_ranked_debug ( "Adjusting for Provisional Game " + player.GetPlayerName()  )
		DEV_script_ranked_debug ( "-------------------------------------------"  )
	#endif

	if ( breakdown.wasInProvisonalGame ) // not done Provisional
	{

		if ( breakdown.convergenceBonus < 0 )
		{
			breakdown.convergenceBonus = 0

			#if DEVELOPER
				DEV_script_ranked_debug ( "convergenceBonus < 0, setting to zero " , 1  )
			#endif
		}

		if ( breakdown.skillDiffBonus < 0 )
		{
			breakdown.skillDiffBonus = 0

			#if DEVELOPER
				DEV_script_ranked_debug ( "skillDiffBonus < 0, setting to zero" , 1  )
			#endif
		}

		bool hasLossForgiveness =  breakdown.lossForgiveness
		int provisionalsGamesCompleted = Ranked_GetNumProvisionalMatchesCompleted ( player )

		// Do not count if ( negative && loss forgiven)
		// If Loss Forgiven was given, thus provisional game count was not increased
		// then we are going to skip provisional bonus, since provisional game was not increased.
		if	( breakdown.placement > RANKED_POSITIVE_PLACEMENT && hasLossForgiveness )
		{
			return breakdown
		}

		Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME, provisionalsGamesCompleted + 1 )

		#if DEVELOPER
		DEV_script_ranked_debug ( "increasing `rankedProvisionalMatchesCompleted` to :" + provisionalsGamesCompleted + 1 , 1  )
		#endif

		// Provisional Bonuses has 3 parts

		// 1) Bonus multipler to all other bonuses

		// the following two are given regardless of in game performance
		// and is intended to set the player to a minimum value
		// this infact does mean all games in provisional are up and to the right

		// 2) a flat convergence bonus given regardless of
		// 3) a scaling convergece bonus
		//    all of these scale with mmr


		// Additional Mechancis
		// - we null any negatives in any bonuses
		// - if the values are all too low because the player's MMR is too low, we still give a minimum random term
		// - all losses are forgiven (todo)


		// Elimination bonus can't be negative.


		breakdown.provisionalMatchBonus = 0 //reset

		// 1) Determine Bonus Multiplier  -----------------------------------------------------------------
		SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP ) //Deliberately only doing score, so will give us Master instead of Apex.
		float pointsInMMR = Ranked_PointsToMMR ( breakdown.startingLP , oldRank.tier )
		float playerMMR = MMR_Rank_GetPlayerMMR ( player )
		float mmr_deltaLpToMMR = playerMMR - pointsInMMR //positive = MMR >> LP, where as negative = LP >> MMR

		float bonusMultiplier = GetProvisionalBonusMultiplier ( mmr_deltaLpToMMR )

		//apply bonus multiplier.
		breakdown.provisionalMatchBonus += int ( float ( breakdown.killBonus ) * bonusMultiplier )
		breakdown.provisionalMatchBonus += int ( float ( breakdown.convergenceBonus ) * bonusMultiplier )
		breakdown.provisionalMatchBonus += int ( float ( breakdown.skillDiffBonus ) * bonusMultiplier )

		// 2 + 3 ) provisional convergence  -----------------------------------------------------------------
		int provisionalConvergenceBonus = 0

		int provisionalFlatBonus = GetProvisionalFlatBonus ( mmr_deltaLpToMMR )
		int provisionalScalingBonus = int ( GetProvisionalScalingMultiplier ( mmr_deltaLpToMMR  ) * max ( breakdown.placementScore, 0 ) )

		provisionalConvergenceBonus += provisionalFlatBonus
		provisionalConvergenceBonus += provisionalScalingBonus

		#if DEVELOPER
			DEV_script_ranked_debug ( "---Provisional Convergence---" , 1 )
			DEV_script_ranked_debug ( "Player MMR: " + playerMMR , 1 )
			DEV_script_ranked_debug ( "Player LP Starting: " +  breakdown.startingLP , 1 )
			DEV_script_ranked_debug ( "Points As MMR: " + pointsInMMR , 1 )
			DEV_script_ranked_debug ( "mmr_deltaLpToMMR: " + mmr_deltaLpToMMR , 1 )
			DEV_script_ranked_debug ( "mmr_deltaLpToMMR: " + bonusMultiplier , 1 )
			DEV_script_ranked_debug ( "provisionalFlatBonus: " + provisionalFlatBonus , 1 )
			DEV_script_ranked_debug ( "provisionalScalingBonus: " + provisionalScalingBonus , 1 )
			DEV_script_ranked_debug ( "pre cap provisionalConvergenceBonus: " + provisionalConvergenceBonus , 1 )
		#endif

		// caps of prov. convergence is ... capped by...
		// upper limit is : LP delta / number of provisional games left + 1
		// lower limit is : a litte bit less than LP delta / 10

		float slightlyLessThanOne  = GetCurrentPlaylistVarFloat( "ranked_tuning_var_less_than_one", 0.9 )

		int targetLP = GetResetLPTarget ( playerMMR )
		int lpDelta = maxint ( targetLP - breakdown.startingLP , 0 )
		int   provisionalsRequired = Ranked_GetNumProvisionalMatchesRequired()
		int   provisionalRemaining = maxint ( provisionalsRequired - provisionalsGamesCompleted , 1 )

		int provisionalConvergenceFloor =  int ( slightlyLessThanOne * lpDelta / float ( provisionalsRequired ) )
		provisionalConvergenceBonus = maxint ( provisionalConvergenceBonus , provisionalConvergenceFloor )

		int provisionalConvergenceCap   =  int ( slightlyLessThanOne * lpDelta / float ( provisionalRemaining ) )
		provisionalConvergenceBonus = minint ( provisionalConvergenceBonus ,  provisionalConvergenceCap  )

		breakdown.provisionalMatchBonus += provisionalConvergenceBonus

		#if DEVELOPER
			DEV_script_ranked_debug ( "slightlyLessThanOne: " + slightlyLessThanOne , 1 )
			DEV_script_ranked_debug ( "startingLP: " +  breakdown.startingLP , 1 )
			DEV_script_ranked_debug ( "targetLP: " + targetLP , 1 )
			DEV_script_ranked_debug ( "lpDelta: " + lpDelta , 1 )
			DEV_script_ranked_debug ( "provisionalsRequired: " + provisionalsRequired , 1 )
			DEV_script_ranked_debug ( "provisionalRemaining: " + provisionalRemaining , 1 )
			DEV_script_ranked_debug ( "provisionalConvergenceFloor: " + provisionalConvergenceFloor , 1 )
			DEV_script_ranked_debug ( "provisionalConvergenceCap: " + provisionalConvergenceCap , 1 )
			DEV_script_ranked_debug ( "post cap provisionalConvergenceBonus: " + provisionalConvergenceBonus , 1 )
		#endif

		//pity min gains
		int pityCutoff = GetCurrentPlaylistVarInt( "ranked_tuning_var_happy", 250 )

		if ( breakdown.provisionalMatchBonus <= pityCutoff )
		{
			int pityMin = GetCurrentPlaylistVarInt( "ranked_tuning_var_joy", 60 )
			int pityMax = GetCurrentPlaylistVarInt( "ranked_tuning_var_sadness", 90 )
			int pityBonus = RandomIntRange ( pityMin , pityMax )
			breakdown.provisionalMatchBonus += pityBonus
			#if DEVELOPER
				DEV_script_ranked_debug ( "pityBonus: " + pityBonus , 1 )
			#endif
		}

		#if DEVELOPER
			DEV_script_ranked_debug ( ">>>>>>breakdown.provisionalMatchBonus: " + breakdown.provisionalMatchBonus + " <<<<<<<<<<<" , 1 )
		#endif
	}
	else if ( Ranked_GetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_HAS_PROGRESSED_OUT_PERSISTENCE_VAR_NAME ) == 0 )
	{
		Ranked_SetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_HAS_PROGRESSED_OUT_PERSISTENCE_VAR_NAME, 1 ) // prevents the post-match provisional graduation animation from triggering
		// we invalidate the rewardSeq at season stat; then set it to 0 here so we know to give rewards
		//Assert( !Ranked_PlayerDeservesRewardsInPeriod(  player, Ranked_GetCurrentPeriodGUIDString() ) )
		SetRankedPersistenceData( player, "rewardSeq", 0 )
	}

	return breakdown
}


float function GetProvisionalBonusMultiplier ( float rankedMMRDelta )
{
	array <float> values

	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_havoc"      , 0.0 ) ) //0
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_flatline"   , 1.0 ) ) //1
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_hemlok"     , 1.0 ) ) //2
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_r301"       , 1.0 ) ) //3
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_nemesis"    , 1.2 ) ) //4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_alternator" , 1.4 ) ) //5
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_prowler"    , 1.6 ) ) //6

	//1SD is difference is 1 index
	float mmrPerIndex = GetCurrentPlaylistVarFloat (  "ranked_tuning_var_p2020" , MMR_TIER_WIDTH )

	int numberOfIndex = abs ( int ( rankedMMRDelta / mmrPerIndex ) )     //with int division
	float remainderMMR  = fabs ( rankedMMRDelta ) - ( mmrPerIndex * float ( numberOfIndex ))

	float sign = 1.0
	if ( rankedMMRDelta < 0 )
		sign *= -1

	if ( numberOfIndex >= values.len() - 1 )
	{
		//return max value
		return sign * ( values[values.len() - 1] )
	}

	return  sign  * ( values[numberOfIndex] + (  remainderMMR / mmrPerIndex )  *   ( values[numberOfIndex + 1] - values[numberOfIndex] ) )
}


int function GetProvisionalFlatBonus ( float rankedMMRDelta )
{
	array <int> values

	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_japan"     , 0    ) ) //0
	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_hong_kong" , 200  ) ) //1
	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_sunny"     , 300  ) ) //2
	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_arcadia"   , 400  ) ) //3
	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_rowland"   , 600  ) ) //4
	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_mulitas"   , 800  ) ) //5
	values.append ( GetCurrentPlaylistVarInt ("ranked_tuning_var_vampire"   , 1000 ) ) //6

	//1SD is difference is 1 index
	float mmrPerIndex = GetCurrentPlaylistVarFloat (  "ranked_tuning_var_r99" , MMR_TIER_WIDTH )

	int numberOfIndex = abs ( int ( rankedMMRDelta / mmrPerIndex ) )
	float remainderMMR  = fabs (  rankedMMRDelta ) - ( mmrPerIndex * float ( numberOfIndex ))

	int sign = 1
	if ( rankedMMRDelta < 0 )
		sign *= -1

	if ( numberOfIndex >= values.len() - 1 )
	{
		//return max value
		return sign * (  values[values.len() - 1] )
	}

	return  sign * ( values[numberOfIndex] + int ( (  remainderMMR / mmrPerIndex )  *  ( values[numberOfIndex + 1] - values[numberOfIndex] ) ) )
}

float function GetProvisionalScalingMultiplier ( float rankedMMRDelta )
{

	//multiplier on placement based on mmr delta to target

	array <float> values

	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_ignorant"   , 0.0  ) ) //0
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_concept"    , 1.0  ) ) //1
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_begin"      , 2.0  ) ) //2
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_bounce"     , 4.0  ) ) //3
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_vantage"    , 6.0  ) ) //4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_seize"      , 8.0  ) ) //5
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_mosaic"     , 10.0 ) ) //6

	//1SD is difference is 1 index
	float mmrPerIndex =  GetCurrentPlaylistVarFloat (  "ranked_tuning_var_voltsmg" , MMR_TIER_WIDTH )

	int numberOfIndex = abs ( int ( rankedMMRDelta / mmrPerIndex ) )     //with int division
	float remainderMMR  = fabs ( rankedMMRDelta ) - ( mmrPerIndex * float ( numberOfIndex ))

	float sign = 1.0
	if ( rankedMMRDelta < 0 )
		sign *= -1

	if ( numberOfIndex >= values.len() - 1 )
	{
		//return max value
		return sign * ( values[values.len() - 1] )
	}

	return  sign  * ( values[numberOfIndex] + (  remainderMMR / mmrPerIndex )  *   ( values[numberOfIndex + 1] - values[numberOfIndex] ) )
}


float function GetConvergenceMultiplerMod ( float rankedMMRDelta )
{
	array <float> values

	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_spong"    , 0.05) ) //0
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_starfish" , 0.05) ) //1
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_crab"     , 0.05) ) //2
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_squirrel" , 0.05) ) //3
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_squid"    , 0.05) ) //4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_plankton" , 0.05) ) //5
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_snail"    , 0.05) ) //6


	//1SD is difference is 1 index
	float mmrPerIndex =  GetCurrentPlaylistVarFloat (  "ranked_tuning_var_car_smg" , MMR_TIER_WIDTH )

	int numberOfIndex = abs ( int ( rankedMMRDelta / mmrPerIndex ) )     //with int division
	float remainderMMR  = fabs ( rankedMMRDelta ) - ( mmrPerIndex * float ( numberOfIndex ))

	float sign = 1.0
	if ( rankedMMRDelta < 0 )
		sign *= -1

	if ( numberOfIndex >= values.len() - 1 )
	{
		//return max value
		return sign * ( values[values.len() - 1] )
	}

	return  sign  * ( values[numberOfIndex] + (  remainderMMR / mmrPerIndex )  *   ( values[numberOfIndex + 1] - values[numberOfIndex] ) )
}



float function GetConvergenceMultiplerModNegative ( float rankedMMRDelta )
{
	array <float> values

	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_strike"   , 1.0) ) //0
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_aegis"    , 4.0) ) //1
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_buster"   , 4.5) ) //2
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_blitz"    , 5.0) ) //3
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_duel"     , 5.5) ) //4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_freedom"  , 6.0) ) //5
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_justice"  , 6.0) ) //6

	//1SD is difference is 1 index
	float mmrPerIndex = GetCurrentPlaylistVarFloat (  "ranked_tuning_var_devotion" , MMR_TIER_WIDTH )

	int numberOfIndex = abs ( int ( rankedMMRDelta / mmrPerIndex ) )     //with int division
	float remainderMMR  = fabs ( rankedMMRDelta ) - ( mmrPerIndex * float ( numberOfIndex ))

	float sign = 1.0

	if ( numberOfIndex >= values.len() - 1 )
	{
		//return max value
		return sign * ( values[values.len() - 1] )
	}

	return  sign  * ( values[numberOfIndex] + (  remainderMMR / mmrPerIndex )  *   ( values[numberOfIndex + 1] - values[numberOfIndex] ) )
}

float function GetEliminationBonusMinPercentageByPlayer ( entity player )
{
	return GetEliminationBonusMinPercentage ( MMR_Rank_GetPlayerMMR ( player ) )
}

float function GetEliminationBonusMinPercentage ( float mmr )
{
	//based on this mmr, return the percentage for elimination that should be protected
	array <float> values

	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_aeroacoustics"  , 0.4 ) ) //0 - Rookie 4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_bearing"        , 0.4 ) ) //1 - Bronize 4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_material"       , 0.4 ) ) //2 - Silver 4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_trajectory"     , 0.4 ) ) //3 - Gold 4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_flight_control" , 0.4 ) ) //4 - Plat 4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_airlock"        , 0.4 ) ) //5 - Diamond 4
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_aeronautics"    , 0.4 ) ) //6 - Master ~50
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_asteriod"       , 0.4 ) ) //7 ~ 58.333
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_avionics"       , 0.4 ) ) //8 ~ 66.666
	values.append ( GetCurrentPlaylistVarFloat ("ranked_tuning_var_axial_stress"   , 0.4 ) ) //9 ~ 75 //impossible

	//1SD is difference is 1 index
	float mmrPerIndex = GetCurrentPlaylistVarFloat (  "ranked_tuning_var_devotion" , MMR_TIER_WIDTH )

	int numberOfIndex = abs ( int ( mmr / mmrPerIndex ) )     //with int division
	float remainderMMR  = fabs ( mmr ) - ( mmrPerIndex * float ( numberOfIndex ))

	float sign = 1.0 //positive

	if ( numberOfIndex >= values.len() - 1 )
	{
		//return max value
		return sign * ( values[values.len() - 1] )
	}

	return  sign  * ( values[numberOfIndex] + (  remainderMMR / mmrPerIndex )  *   ( values[numberOfIndex + 1] - values[numberOfIndex] ) )
}

int function GetEliminationBonusMinFlatt ( RankLadderPointsBreakdown breakdown , float mmr )
{
	return int ( breakdown.killBonusUnadjusted * GetEliminationBonusMinPercentage ( mmr ) )
}

RankLadderPointsBreakdown function RedistributeBonuses ( RankLadderPointsBreakdown breakdown , entity player )
{

	bool disableThisFunction = GetCurrentPlaylistVarBool ( "ranked_tuning_var_bocek" , false )
	if ( disableThisFunction == true )
	{
		//we cant show negative bonus values
		if (breakdown.killBonus < 0)
			breakdown.killBonus = 0

		if ( breakdown.convergenceBonus < 0)
			breakdown.convergenceBonus = 0

		if ( breakdown.skillDiffBonus < 0 )
			breakdown.skillDiffBonus = 0

		return breakdown
	}

	//determine amount of protected kill bonus;
	float protectedKillBonus = 0
	if ( breakdown.killBonusUnadjusted  > 0 )
	{
		protectedKillBonus = breakdown.killBonusUnadjusted * GetEliminationBonusMinPercentageByPlayer ( player )
		breakdown.killBonus -= int ( protectedKillBonus )
	}

	//easier to iterate through with an array.
	array < float > bonuses
	bonuses.append( float ( breakdown.killBonus ) )
	bonuses.append( float ( breakdown.convergenceBonus ) )
	bonuses.append( float ( breakdown.skillDiffBonus ) )

	float negativeTotal = 0
	float positiveTotal = 0

	for (int i = 0; i < bonuses.len(); i++ )
	{
		if ( bonuses[i] < 0 )
		{
			negativeTotal += bonuses[i]
			bonuses[i] = 0
		}
		else if ( bonuses [i] > 0)
		{
			positiveTotal += bonuses[i]
		}
	}

	negativeTotal = fabs (negativeTotal)

	//rebalancing Negative values:

	//special case - early out with known results
	if ( negativeTotal  >= positiveTotal )
	{
		breakdown.killBonus = int ( protectedKillBonus )
		breakdown.convergenceBonus = 0
		breakdown.skillDiffBonus = 0
		return breakdown
	}

	float multiplier = 1.0 -  ( negativeTotal /  positiveTotal )

	for (int i = 0; i < bonuses.len(); i++ )
	{
		bonuses[i] =  bonuses[i] * multiplier
	}

	//end remove negatives

	//turning this entire part off since we havee built in checks for each bonuses now.
	bool checkForCaps = GetCurrentPlaylistVarBool ( "ranked_tuning_var_silo" , false ) //master toggle

	if ( checkForCaps )
	{
		//cap = half of placements, but min at half of entry cost
		if ( breakdown.placement > RANKED_POSITIVE_PLACEMENT )
		{
			//Loss mitigation case
			if (  GetCurrentPlaylistVarBool ( "ranked_tuning_var_punchable" , false ) ) //toggle
			{
				float lossProtectionCapMod = GetCurrentPlaylistVarFloat( "ranked_tuning_var_pixel", 0.5 )

                      
					SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP )
					float lossProtectionCap =  Ranked_GetCostForEntry( oldRank ) * lossProtectionCapMod  //positive value
         
                                                                                                 
          

				float net = positiveTotal - negativeTotal //positive value
				if ( net > lossProtectionCap )
				{
					float amountToTrim = net - lossProtectionCap
					float s = 1.0 - ( amountToTrim / net )

					for (int i = 0; i < bonuses.len(); i++ )
					{
						bonuses[i] =  bonuses[i] * s
					}
				}
			}
		}
		else
		{
			//positive gains case
			if (  GetCurrentPlaylistVarBool ( "ranked_tuning_var_kraber" , true ) ) //toggle
			{
				float gainMod = GetCurrentPlaylistVarFloat( "ranked_tuning_var_airship", 1.5 )
				float gainCap = breakdown.placementScore * gainMod
				float net = positiveTotal - negativeTotal
				if ( net > gainCap )
				{
					float amountToTrim = gainCap - net
					float s = 1.0 - ( amountToTrim / net  )

					for (int i = 0; i < bonuses.len(); i++ )
					{
						bonuses[i] =  bonuses[i] * s
					}
				}
			}
		}
	}

	breakdown.killBonus 	   = int ( bonuses [0] + protectedKillBonus )
	breakdown.convergenceBonus = int ( bonuses [1] )
	breakdown.skillDiffBonus   = int ( bonuses [2] )
	return breakdown
}


RankLadderPointsBreakdown function AdjustForGameAbandoned( RankLadderPointsBreakdown breakdown, bool wasGameAbandonded )
{
	if ( !wasGameAbandonded )
	{
		return breakdown
	}

	//Do not null out, because we show the numbers, so dont add in net values
	//breakdown.killBonus        = 0
	//breakdown.convergenceBonus = 0
	//breakdown.skillDiffBonus   = 0

	#if DEVELOPER
		DEV_script_ranked_debug ("AdjustForGameAbandoned() start" )
	#endif

                   
		SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP ) //Deliberately only doing score, so will give us Master instead of Apex.
		breakdown.penaltyPointsForAbandoning = Ranked_GetPenaltyPointsForAbandon ( oldRank )
      
                                                                              
       

	if ( breakdown.isHighTier )
	{
		breakdown.penaltyPointsForAbandoning = int ( breakdown.penaltyPointsForAbandoning * ( GetHighEndLostMultiplier() ) )
	}

	#if DEVELOPER
		DEV_script_ranked_debug ("AdjustForGameAbandoned() After" )
	#endif

	return breakdown
}

RankLadderPointsBreakdown function AdjustForDemotion( RankLadderPointsBreakdown breakdown , entity player )
{

	#if DEVELOPER
		DEV_script_ranked_debug ("AdjustForDemotion() Start" + player.GetPlayerName() ,3 )
		DEV_script_ranked_debug ( "breakdown.startingLP: " + breakdown.startingLP , 3 )
		DEV_script_ranked_debug ( "breakdown.finalLP : " + breakdown.finalLP  , 3 )
	#endif

	if ( breakdown.wasInProvisonalGame )
		return breakdown

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP ) //Deliberately only doing score, so will give us Master instead of Apex.
	SharedRankedDivisionData newRank = GetCurrentRankedDivisionFromScore( breakdown.finalLP ) //Deliberately only doing score, so will give us Master instead of Apex.

	//S13 Enabled Demotions
	if ( newRank.index < oldRank.index && newRank.tier != oldRank.tier ) //Losing enough points to demote.
	{

		int bufferSize = GetDemotionProtectionBuffer ( player )

		#if DEVELOPER
			DEV_script_ranked_debug ( "bufferSize : " + bufferSize  , 3 )
			DEV_script_ranked_debug ( "breakdown.netLP: " + breakdown.netLP , 3 )
		#endif

		if ( bufferSize > 0 || !oldRank.tier.allowsDemotion ) //has buffer or you can't demote out of this tier
		{

			//PROTECTED CASE
			SetDemotionProtectionBuffer ( player, maxint( bufferSize - 1 , 0 ) )

			breakdown.demotionProtectionAdjustment = oldRank.scoreMin - breakdown.finalLP
			breakdown.netLP += breakdown.demotionProtectionAdjustment
			breakdown.finalLP                           = oldRank.scoreMin

			#if DEVELOPER
				DEV_script_ranked_debug ( "---------------PROTECTED CASE---------------------------" , 3 )
				DEV_script_ranked_debug ( "breakdown.demotionProtectionAdjustment: " + breakdown.demotionProtectionAdjustment , 3 )
				DEV_script_ranked_debug ( "breakdown.netLP: " + breakdown.netLP , 3 )
				DEV_script_ranked_debug ( "reakdown.finalLP : " + breakdown.finalLP , 3 )
			#endif
		}
		else
		{
			//DEMOTION CASE
			int demotionalPenality = GetCurrentPlaylistVarInt ( "ranked_tier_demotion_penality", RANKED_LP_DEMOTION_PENALITY )
			breakdown.demotionPenality = demotionalPenality

			breakdown.netLP   -= demotionalPenality
			breakdown.finalLP -= demotionalPenality

			#if DEVELOPER
				DEV_script_ranked_debug ( "---------------DEMOTION ED CASE---------------------------" , 3 )
				DEV_script_ranked_debug ( "breakdown.demotionPenality: " + breakdown.demotionPenality , 3 )
				DEV_script_ranked_debug ( "breakdown.netLP: " + breakdown.netLP , 3 )
				DEV_script_ranked_debug ( "reakdown.finalLP : " + breakdown.finalLP , 3 )
			#endif

			SetDemotionProtectionBuffer ( player, 0 )  //clear buffer
		}
	}

	return breakdown
}

                  
bool function HasRankDivisionSkipping ()
{
	return GetCurrentPlaylistVarBool ("HasRankedDivisionSkip" , true )
}

bool function HasRankTierSkipping ()
{
	return GetCurrentPlaylistVarBool ("HasRankedTierSkip" , true )
}

RankLadderPointsBreakdown function AdjustForDivisonPromotion( RankLadderPointsBreakdown breakdown , entity player )
{
	if ( breakdown.wasInProvisonalGame )
		return breakdown

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP ) //Deliberately only doing score, so will give us Master instead of Apex.
	SharedRankedDivisionData newRank = GetCurrentRankedDivisionFromScore( breakdown.finalLP ) //Deliberately only doing score, so will give us Master instead of Apex.

	//Division promotion, and excludings tier promotions because trials are there
	if ( newRank.index > oldRank.index && newRank.tier == oldRank.tier )
	{
		if ( HasRankDivisionSkipping () )
		{
			//check for divison skip for smurfs
		}
	}

	return breakdown
}
      

RankLadderPointsBreakdown function AdjustForTierPromotion( RankLadderPointsBreakdown breakdown , entity player )
{

	if ( breakdown.wasInProvisonalGame )
		return breakdown

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP ) //Deliberately only doing score, so will give us Master instead of Apex.
	SharedRankedDivisionData newRank = GetCurrentRankedDivisionFromScore( breakdown.finalLP ) //Deliberately only doing score, so will give us Master instead of Apex.

	#if DEVELOPER
	if ( !IsLobby() )
	{
	#endif
	Assert( player.p.placementStatsRecorded ) // final placements stats are required to properly evaluate performance

	#if DEVELOPER
	}
	#endif
	if ( RankedTrials_PlayerHasAssignedTrial( player ) )
	{
		ItemFlavor trial     = RankedTrials_GetAssignedTrial( player )
		breakdown.trialState = RankedTrials_UpdateTrialCompletion( player, trial )

		switch ( breakdown.trialState )
		{
			case eRankedTrialState.INCOMPLETE:

				#if DEVELOPER
					DEV_script_ranked_debug ( "AdjustForPromotion: Ranked Trial - INCOMPLETE" )
				#endif

				RankedTrials_SaveMatchLP( player, breakdown.netLP )

				breakdown.netLP   		 = 0
				breakdown.finalLP 		 = breakdown.startingLP
				break

			case eRankedTrialState.SUCCESS:

				#if DEVELOPER
					DEV_script_ranked_debug ( "AdjustForPromotion: Ranked Trial - SUCCESS" )
				#endif

				SharedRankedDivisionData ornull nextRank = GetNextRankedDivisionFromScore( breakdown.startingLP )
				Assert( nextRank != null )
				expect SharedRankedDivisionData( nextRank )

				breakdown.promotionBonus = ( nextRank.scoreMin - breakdown.startingLP ) + RankedTrials_GetTrialBonusLPGain( trial )
				breakdown.netLP	  		 = breakdown.promotionBonus
				breakdown.finalLP 		 = breakdown.startingLP + breakdown.netLP

				break

			case eRankedTrialState.FAILURE:

				#if DEVELOPER
					DEV_script_ranked_debug ( "AdjustForPromotion: Ranked Trial - FAILURE" )
				#endif

				int storedLP 	  = RankedTrials_GetNetLP( player ) + breakdown.netLP

				//clamp
				storedLP = minint( storedLP, RankedTrials_GetTrialMinLPLoss( trial ) ) // max negative to impose min loss
				storedLP = maxint( storedLP, RankedTrials_GetTrialMaxLPLoss( trial ) ) // least negative to impose max loss

				breakdown.netLP   = storedLP
				breakdown.finalLP = breakdown.startingLP + breakdown.netLP

				break

			default:
				Assert( false )
		}

		return breakdown
	}

	int nextRankTierIdx = oldRank.tier.index + 1
	bool tierUp 		= newRank.index > oldRank.index && newRank.tier != oldRank.tier
	if ( tierUp && RankedTrials_PlayerShouldBePlacedIntoTrialForTier( player, nextRankTierIdx ) ) // they need to enter Trials State
	{
		#if DEVELOPER
			DEV_script_ranked_debug ( "AdjustForPromotion: Ranked Trial - ASSIGNED" )
		#endif

		RankedTrials_AssignTrial( player, nextRankTierIdx )

		breakdown.netLP      = newRank.scoreMin - 1 - breakdown.startingLP  // Net lp should be pushed up to tier cieling, which is score min of next tier minus 1
		breakdown.finalLP    = breakdown.startingLP + breakdown.netLP
		breakdown.trialState = eRankedTrialState.INCOMPLETE

		return breakdown
	}

	//No Promo Trial Behavior. Unreachable when Traisl are enabled.
	if ( newRank.index > oldRank.index && newRank.tier != oldRank.tier ) //CHECK FOR PROMOTION
	{
		int bufferSize = GetDemotionProtectionBuffer ( player )
		int minBufferSize = GetCurrentPlaylistVarInt( "ranked_promotion_min_buffer_size", newRank.tier.minProtection )
		if ( bufferSize <=  minBufferSize )
		{
			SetDemotionProtectionBuffer ( player, minBufferSize )
		}

		breakdown.promotionBonus = GetCurrentPlaylistVarInt ( "ranked_tier_promotion_bonus", RANKED_LP_PROMOTION_BONUS )

		breakdown.finalLP   += breakdown.promotionBonus
		breakdown.netLP 	+= breakdown.promotionBonus
	}

	return breakdown
}

array < float > function Ranked_GetKillValuesForPlacement ( int placement )
{
	//AARLI TODO to be gutted
	if ( placement == 0 )
	{
		array <float > result
		result.append( 0.0 )
		return result
	}
	int index = minint ( file.killValues.len() - 1 , placement - 1 )


	return file.killValues[ index ]
}

bool function Ranked_HasFinishedProvisionalMatches( entity player )
{
	return Ranked_GetNumProvisionalMatchesCompleted( player ) >= Ranked_GetNumProvisionalMatchesRequired()
}

void function SetDemotionProtectionBuffer(entity player, int newValue)
{
	player.SetPersistentVar( "demotionBuffer", newValue )
}

// ---------------------------
// In Game Updates
// ---------------------------

void function Ranked_UpdateRankedScoreProgressForAllPlayers()
{
	foreach ( player in GetPlayerArray() )
	{
		Ranked_UpdateRankedScoreProgressForPlayer( player )
	}
}

void function Ranked_UpdateRankedScoreProgressForPlayer( entity player )
{
	if ( !player.p.hasMatchParticipationStarted || player.p.hasMatchParticipationEnded )
		return

	int placement = GetNumTeamsRemaining()
	int placementScore = Ranked_GetPointsForPlacement ( placement )
	int playerRankScore = GetPlayerRankScore ( player )

                    
                                   

                           
   
                                                                                                            

                                  
    
           
                                                                                              
          
                                                                        
    
   
                                                                      
	     

		RankedGameSummarySquadData rankedGameSummaryData = RankedGameSummary_GetPlayerData( player ) //from ranked scripts

		int entryCost = ( Ranked_HasFinishedProvisionalMatches ( player ) ) ? Ranked_GetCostForEntry ( GetCurrentRankedDivisionFromScore ( GetPlayerRankScore( player ) ) ) : 0
		int combatScore = RankedScoreProgress_GetCombatBonusTotal ( player  )//missing softcap
		int top5Streak = ( placement <= 5 ) ? Ranked_GetTop5StreakBonusValueFromStreak ( Ranked_GetPlayerTop5StreakCount ( player ) + 1 )  : 0
		int highSkillKill = RankedScoreProgress_CalculateCurrentHighSkillKillBonus ( player , playerRankScore, rankedGameSummaryData.killsPlayerByHwUID, rankedGameSummaryData.assistsPlayerByHwUID, placement  )

		int inProgressScore = 0
		inProgressScore -= entryCost
		inProgressScore += placementScore + combatScore + top5Streak + highSkillKill

		#if DEVELOPER
			DEV_script_ranked_debug ( "!!!!!!!!!!!!!Ranked_UpdateRankedScoreProgressForPlayer " + player.GetPlayerName() , 3 )
			DEV_script_ranked_debug ( "Ranked_UpdateRankedScoreProgress for entry cost " + entryCost, 3 )
			DEV_script_ranked_debug ( "Ranked_UpdateRankedScoreProgress for combatScore " + combatScore, 3 )
			DEV_script_ranked_debug ( "Ranked_UpdateRankedScoreProgress for top5Streak " + top5Streak, 3 )
			DEV_script_ranked_debug ( "Ranked_UpdateRankedScoreProgress for high skill kill " + highSkillKill, 3 )
			DEV_script_ranked_debug ( "Ranked_UpdateRankedScoreProgress for placementScore " + placementScore, 3 )
			DEV_script_ranked_debug ( "Ranked_UpdateRankedScoreProgress for total " + inProgressScore, 3 )
		#endif

		player.SetPlayerNetInt( "inMatchRankScoreProgress", inProgressScore )

       
}

                  
int function RankedScoreProgress_GetCombatBonusTotal ( entity player )
{
	int placement = GetNumTeamsRemaining()
	RankedGameSummarySquadData rankedGameSummaryData = RankedGameSummary_GetPlayerData( player ) //from ranked scripts
	int killCount            = rankedGameSummaryData.killsPlayerByHwUID.len()
	int assistsCount         = rankedGameSummaryData.assistsPlayerByHwUID.len()
	int participationCount   = rankedGameSummaryData.participationPlayerByHwUID.len()

	return Ranked_GetCombatBonusTotal ( killCount, assistsCount, participationCount , placement)
}

int function RankedScoreProgress_GetPlayerFirstKillBonus ( entity player )
{
	int placement = GetNumTeamsRemaining()
	RankedGameSummarySquadData rankedGameSummaryData = RankedGameSummary_GetPlayerData( player ) //from ranked scripts
	int killCount         = rankedGameSummaryData.killsPlayerByHwUID.len()
	int assistsCount         = rankedGameSummaryData.assistsPlayerByHwUID.len()

	return Ranked_GetPlayerFirstKillBonus ( killCount + assistsCount, placement )
}

int function RankedScoreProgress_GetLivingLegendBonus ( entity player )
{
	int placement = GetNumTeamsRemaining()
	RankedGameSummarySquadData rankedGameSummaryData = RankedGameSummary_GetPlayerData( player ) //from ranked scripts
	int killCount         = rankedGameSummaryData.killsPlayerByHwUID.len()
	int assistsCount         = rankedGameSummaryData.assistsPlayerByHwUID.len()

	return Ranked_GetLivingLegendBonus ( killCount + assistsCount, placement )
}

int function RankedScoreProgress_CalculateCurrentHighSkillKillBonus ( entity player, int playerScore, table< string, RankedVictimData > killsPlayerMmrByHwUID,	table< string, RankedVictimData > assistsPlayerMmrByHwUID, int placement )
{
	return Ranked_GetHighSkillKillBonus( player, playerScore, killsPlayerMmrByHwUID, assistsPlayerMmrByHwUID, placement )[1]
}



      

// ---------------------------
// Post Game Processing
// ---------------------------

//#matchend #matchending
void function PrepareGameSummaryForPointCalculation( entity player )
{
	#if DEVELOPER
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
		DEV_script_ranked_debug ( "------Game Summary Score Calculation for " + player.GetPlayerName() )
		DEV_script_ranked_debug ( "-----------------------------------------------------------------------" )
	#endif

	//no calculations, only populating information
	RankLadderPointsBreakdown breakdown
	GameSummarySquadData gameSummaryData = GameSummary_GetPlayerData( player ) //from _gamemode_survival
	RankedGameSummarySquadData rankedGameSummaryData = RankedGameSummary_GetPlayerData( player ) //from ranked scripts

	bool wasLastGameAbandoned           = bool ( GetRankedGameData( player,  "lastGameRankedAbandon" ) )
	bool didLastGameHaveLossForgiveness = bool ( GetRankedGameData( player,  "lastGameRankedForgiveness" ) ) || bool ( GetRankedGameData ( player, "lastGameAbandonForgiveness" ) )
	Assert ( ! (wasLastGameAbandoned && didLastGameHaveLossForgiveness) ) //Both can't be true!

	breakdown.wasAbandoned = wasLastGameAbandoned
	breakdown.lossForgiveness = didLastGameHaveLossForgiveness
	breakdown.wasInProvisonalGame = !Ranked_HasFinishedProvisionalMatches ( player )

	breakdown.damage = gameSummaryData.damageDealt

	breakdown.killsPlayerByHwUID           = rankedGameSummaryData.killsPlayerByHwUID
	breakdown.assistsPlayerByHwUID         = rankedGameSummaryData.assistsPlayerByHwUID
	breakdown.participationPlayerByHwUID   = rankedGameSummaryData.participationPlayerByHwUID
	breakdown.knockdownPlayerByHwUID       = rankedGameSummaryData.knockdownPlayerByHwUID
	breakdown.knockdownAssistPlayerByHwUID = rankedGameSummaryData.knockdownAssistPlayerByHwUID

	breakdown.knockdown = gameSummaryData.knockdowns
	breakdown.knockdownAssist = gameSummaryData.knockdownAssists

	breakdown.kills = gameSummaryData.kills
	breakdown.assists = gameSummaryData.assists
	breakdown.participation = rankedGameSummaryData.participationPlayerByHwUID.len()

	int placement = Survival_GetCurrentRank( player )
	breakdown.placement = placement

	                  
	breakdown.killValueModifierByPlacement = RankedGetPointsForKillsByPlacement ( placement )
	breakdown.totalUniqueSquadKills = Ranked_GetTotalSquadKillsUniqueByPlayer ( player )
       

	#if DEVELOPER // DEV simulates Ranked Match flow from Lobby
	if ( GetCurrentPlaylistVarBool ( "ranked_premature_match_end" , true ) && !IsLobby() && GetGameState() < eGameState.Playing )
	#else
	if ( GetCurrentPlaylistVarBool ( "ranked_premature_match_end" , true ) && GetGameState() < eGameState.Playing )
	#endif // #if DEVELOPER
	{
		breakdown.placement = GetCurrentPlaylistVarInt ( "ranked_early_quit_placement", 20 )
	}

	Assert( placement > 0 )
	//player.SetPersistentVar( "lastGameRank", placement )

	breakdown.placementScore = ( breakdown.wasAbandoned ) ? Ranked_GetPointsForPlacement ( 0 ) : Ranked_GetPointsForPlacement ( breakdown.placement )
	breakdown.startingLP = GetPlayerRankScore( player )

	SharedRankedDivisionData oldRank = GetCurrentRankedDivisionFromScore( breakdown.startingLP )
	breakdown.isHighTier = oldRank.tier.isTopEnd

	if ( Ranked_IsDisablePointGain( player ) )
	{
		breakdown.placementScore = 0
		breakdown.finalLP = breakdown.startingLP
	}

	if ( !breakdown.wasInProvisonalGame )
	{
		breakdown.entryCost = oldRank.divisionEntryCost
	}

	breakdown.killsUnique = breakdown.killsPlayerByHwUID.len()
	breakdown.assistUnique = breakdown.assistsPlayerByHwUID.len()
	breakdown.participationUnique = breakdown.participationPlayerByHwUID.len()

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown, 1, "PrepareGameSummaryForPointCalculation for " + player.GetPlayerName()  )
	#endif

	PostGameCalculateLadderPointResult( player, breakdown )
}

void function PostGameCalculateLadderPointResult( entity player, RankLadderPointsBreakdown breakdown )
{
	if ( !Ranked_IsDisablePointGain( player ) )
	{
		//Bonus
                    
			//Transparent scoring model
			breakdown = AdjustForEliminiations_S20 ( breakdown, player )
			breakdown = AdjustForHighSkillKill ( breakdown , player , breakdown.startingLP )
			//breakdown = AdjustForDemoCrewBonus ( breakdown )
			breakdown = AdjustForTop5Streak ( breakdown, player )
			//breakdown = AdjustForProvisionalGames_S20 ( breakdown, player )
       
                              
                                                                                            
                                                                                       
                                                                                                                                        
                                                         
                                                              
        

		#if DEVELOPER
			//QA tools
			breakdown = AdjustForQAPlaylistOverrides ( breakdown, player )
		#endif

		breakdown = AdjustForGameAbandoned (breakdown, breakdown.wasAbandoned )

		breakdown = ValidateAndRecalculateBreakdown ( breakdown )

		breakdown = AdjustForDemotion ( breakdown, player )
		breakdown = AdjustForTierPromotion ( breakdown, player )
	}

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown, 0 , "End of Ranked Adjustments" )
	#endif
	SetPlayerRankedGameScoringData( player, breakdown )
}

RankLadderPointsBreakdown function ValidateAndRecalculateBreakdown ( RankLadderPointsBreakdown breakdown )
{
	//recheck and recaluclate final, and net LP gains
	breakdown.placementScore = ( breakdown.wasAbandoned ) ? Ranked_GetPointsForPlacement ( 0 ) : Ranked_GetPointsForPlacement ( breakdown.placement )

	#if DEVELOPER
		DEV_script_ranked_debug ( "ValidateAndRecalculateBreakdown() start" )
	#endif

	breakdown.netLP =  breakdown.placementScore
                   
		breakdown.netLP -= ( !breakdown.wasInProvisonalGame ) ? breakdown.entryCost : 0
      
                                                 
       

                       
                                                                                                                                                                 
	     
		breakdown.netLP += (breakdown.wasAbandoned) ? 0 : breakdown.demoCrewBonus + breakdown.top5StreakBonusValue + breakdown.killBonus + breakdown.highSkillKillBonusValue + breakdown.provisionalMatchBonus + breakdown.firstKillBonus
       

	breakdown.netLP += breakdown.promotionBonus
	breakdown.netLP -= breakdown.demotionPenality
	breakdown.netLP -= breakdown.penaltyPointsForAbandoning
	breakdown.netLP += breakdown.demotionProtectionAdjustment

	breakdown.finalLP = breakdown.startingLP + breakdown.netLP

	Assert (  !( (breakdown.wasAbandoned && breakdown.lossForgiveness) == true ) )

	if ( breakdown.lossForgiveness && breakdown.startingLP > breakdown.finalLP ) //loss forgiven
	{

		breakdown.lossProtectionAdjustment = abs( breakdown.netLP )
		breakdown.finalLP                  = breakdown.startingLP
		breakdown.netLP 				   = 0

		#if DEVELOPER
			DEV_script_ranked_debug ( "Loss forgiven applied to scoring" )
		#endif
	}

	if ( breakdown.wasInProvisonalGame && breakdown.startingLP > breakdown.finalLP ) //provisional loss
	{
		//Doesnt exactly apply in S20 due to math.
		breakdown.lossProtectionAdjustment = abs( breakdown.netLP )
		breakdown.finalLP                  = breakdown.startingLP
		breakdown.netLP 				   = 0

		#if DEVELOPER
			DEV_script_ranked_debug ( "Provisional loss forgiveneess applied" )
		#endif
	}

	if ( breakdown.finalLP < SHARED_RANKED_ROOKIE_FLOOR_VALUE ) // flooring out at 1 LP
	{
		breakdown.lossProtectionAdjustment = abs( SHARED_RANKED_ROOKIE_FLOOR_VALUE - breakdown.finalLP )
		breakdown.finalLP = SHARED_RANKED_ROOKIE_FLOOR_VALUE
		breakdown.netLP += breakdown.lossProtectionAdjustment
	}

	#if DEVELOPER
		PrintRankLadderPointsBreakdown ( breakdown )
	#endif

	return breakdown
}


void function SetPlayerRankedGameScoringData( entity player, RankLadderPointsBreakdown breakdown )
{
	WritePlayerPostgameResultInPersistence ( player , breakdown )

		#if DEVELOPER
		//it is possible to trigger this flow from the lobby for  testing, and we would want to stop here if that is the case
		if ( IsLobby() )
			return
		#endif

	if ( IsRankedInSeason() )
	{
		#if DEVELOPER
			DEV_script_ranked_debug ("Ranked in season" )
			DEV_script_ranked_debug ("breakdown.finalLP - breakdown.startingLP " + ( breakdown.finalLP - breakdown.startingLP) )
		#endif

		SetPlayerRankScore( player, breakdown.finalLP, breakdown.startingLP ) //Separate function since it triggers checking for PIN events etc.

		//breakdown.FinalLP should already be filtered for < SHARED_RANKED_ROOKIE_FLOOR_VALUE
		SetPlayerRankScoreDiff( player, MATCHRANKEDMODE_RANKED, breakdown.finalLP - breakdown.startingLP , maxint ( breakdown.finalLP, SHARED_RANKED_ROOKIE_FLOOR_VALUE ) , 0 )
	}
	else
	{
		#if DEVELOPER
			DEV_script_ranked_debug ("Ranked NOT in season" )
		#endif

		SetPlayerRankScoreDiff( player, MATCHRANKEDMODE_RANKED, 0, breakdown.startingLP, 0 ) //Zero out any points adjustments for Stryder
	}

	if ( bool ( GetRankedGameData( player,  "lastGameRankedForgiveness" ) ) )
	{
		#if DEVELOPER
			DEV_script_ranked_debug ("Setting lastGameRankedForgiveness" )
		#endif
		//SetPlayerLossForgiveness( player, eLossForgivenessReason.TEAMMATE_ABANDON ) // TODO: Differentiate between this and not full party
	}

	player.p.rankPointBreakdownCache = breakdown

	#if DEVELOPER
	PrintRankLadderPointsBreakdown ( breakdown, 1 , "This is going into SetPlayerMatchResult()" )
	#endif

	int rankedTrialGuid = RankedTrials_PlayerHasIncompleteTrial( player ) ? ItemFlavor_GetGUID( RankedTrials_GetAssignedTrial( player ) ) : 0
	SetPlayerMatchResult( player, breakdown.placement, breakdown.kills, breakdown.damage )
}


void function Ranked_OnStryderPlayerRankedResultsComplete( entity player, int rankScoreFinal, float mmrDelta )
{
	// TODO: add provisional calculations here

	//SetPlayerMatchProvisionalResult( player, 0 )
}


// ---------------------------
// Gameplay Callbacks
// ---------------------------

void function AddCallback_OnPlayerParticipation( void functionref( entity attacker, entity victim ) callbackFunc )
{
	Assert( !file.onPlayerParticipationCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddCallback_OnPlayerParticipation" )
	file.onPlayerParticipationCallbacks.append( callbackFunc )
}


void function AddCallback_OnPlayerGameSummaryKillParticipation( void functionref(entity, entity, int) callbackFunc )
{
	Assert( !(file.Callbacks_OnPlayerGameSummaryKillParticipation.contains( callbackFunc )) )
	file.Callbacks_OnPlayerGameSummaryKillParticipation.append( callbackFunc )
}


void function RunCallback_OnPlayerParticipation( entity helper, entity victim )
{
	foreach ( callbackFunc in file.onPlayerParticipationCallbacks )
	{
		callbackFunc( helper, victim )
	}
}


void function AddGameSummaryKillParticipation( entity player, entity victim, int increment )
{
	if ( GetGameState() < eGameState.Playing )
		return

	if ( player.IsBot() )
		return

	foreach ( callbackFunc in file.Callbacks_OnPlayerGameSummaryKillParticipation )
	{
		callbackFunc( player, victim, increment )
	}
}


void function AddKillParticipationStats( entity helper , entity victim )
{
	int killParticipation = minint( helper.GetPlayerNetInt( "kill_participation" ) + 1, 500 )
	helper.SetPlayerNetInt( "kill_participation", killParticipation )

	AddGameSummaryKillParticipation( helper, victim, 1 )
}

// ---------------------------
// Game Summary Stats
// ---------------------------

int function Ranked_GetPlayerUniqueKills ( entity player  )
{
	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData ( player )
	return data.killsPlayerByHwUID.len()
}


table< string, RankedVictimData > function Ranked_GetPlayerUniqueKillsList ( entity player  )
{
	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData ( player )
	return data.killsPlayerByHwUID
}


int function Ranked_GetPlayerUniqueAssists ( entity player  )
{
	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData ( player )
	return data.assistsPlayerByHwUID.len()
}


table< string, RankedVictimData > function Ranked_GetPlayerUniqueAssistsList ( entity player  )
{
	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData ( player )
	return data.assistsPlayerByHwUID
}


int function Ranked_GetPlayerUniqueParticipation ( entity player  )
{
	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData ( player )
	return data.participationPlayerByHwUID.len()
}


table< string, RankedVictimData > function Ranked_GetPlayerUniqueParticipationList ( entity player  )
{
	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData ( player )
	return data.participationPlayerByHwUID
}


void function OnPlayerGameSummaryKill( entity player, entity victim, int increment )
{
	#if DEVELOPER
		DEV_script_ranked_debug ( player.GetPlayerName() + "has KILLED " + victim.GetPlayerName() )
	#endif

	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData( player )

	string victimHwUID = Ranked_GetPlayerHardwareUIDString( victim )


	float victimAdjustedMMR = MMR_Rank_GetPostAdjustedMMR( victim )
	int victimRP = GetPlayerRankScore ( victim )

	bool inKills = ( victimHwUID in data.killsPlayerByHwUID )
	bool inAssists = ( victimHwUID in data.assistsPlayerByHwUID )
	bool inParticipation = ( victimHwUID in data.participationPlayerByHwUID )

	if ( inParticipation )
	{
		delete data.participationPlayerByHwUID[ victimHwUID ]
		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.killsPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ("\t Victim found in participation list , moving to kills.")
		#endif
	}
	else if ( inAssists )
	{

		delete data.assistsPlayerByHwUID[ victimHwUID ]

		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.killsPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ("\t - Victim found in assists list, moving to kills.")
		#endif
	}
	else if ( !inKills )
	{
		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.killsPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ("\t - This is a unique kill.")
		#endif
	}
	#if DEVELOPER
	else
	{
		DEV_script_ranked_debug ( "This is duplicate kill" )
	}
	#endif
}


void function OnPlayerGameSummaryAssist( entity player, entity victim, int increment )
{
	#if DEVELOPER
		DEV_script_ranked_debug ( player.GetPlayerName() + "has ASSISTED in elimination of " + victim.GetPlayerName() )
	#endif

	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData( player )

	string victimHwUID = Ranked_GetPlayerHardwareUIDString( victim )
	float victimAdjustedMMR = MMR_Rank_GetPostAdjustedMMR( victim )
	int victimRP = GetPlayerRankScore ( victim )

	bool inKills = ( victimHwUID in data.killsPlayerByHwUID )
	bool inAssists = ( victimHwUID in data.assistsPlayerByHwUID )
	bool inParticipation = ( victimHwUID in data.participationPlayerByHwUID )

	if ( inKills || inAssists )
	{
		#if DEVELOPER
			DEV_script_ranked_debug ("\tVictmFound in kills/assists, do nothing.")
		#endif
		return
	}
	else if ( inParticipation )
	{
		delete data.participationPlayerByHwUID[ victimHwUID ]

		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.assistsPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ("\t - Victim found in participation list , moving to kills.")
		#endif
	}
	else
	{
		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.assistsPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ( "This is new assists" )
		#endif
	}
}


void function OnPlayerGameSummaryKillParticipation( entity player, entity victim, int increment )
{
	//Do not give participation if dead
	if ( !IsAlive(player) )
		return

	#if DEVELOPER
		DEV_script_ranked_debug ( player.GetPlayerName() + "has participated in elimination of " + victim.GetPlayerName() )
	#endif

	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData( player )
	//data.participation++

	string victimHwUID = Ranked_GetPlayerHardwareUIDString( victim )
	float victimAdjustedMMR = MMR_Rank_GetPostAdjustedMMR( victim )
	int victimRP = GetPlayerRankScore ( victim )

	bool inKills = ( victimHwUID in data.killsPlayerByHwUID )
	bool inAssists = ( victimHwUID in data.assistsPlayerByHwUID )
	bool inParticipation = ( victimHwUID in data.participationPlayerByHwUID )

	if ( inKills || inAssists || inParticipation )
	{
		#if DEVELOPER
			DEV_script_ranked_debug ( "\t - participation is not unique. Do nothing." )
		#endif

		return
	}
	else
	{
		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.participationPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ( "\t - participation is unique." )
		#endif
	}
}


void function OnPlayerGameSummaryKnockdown( entity player, entity victim, int increment, var damageInfo)
{
	#if DEVELOPER
		DEV_script_ranked_debug ( player.GetPlayerName() + "has knocked down " + victim.GetPlayerName() )
	#endif

	string victimHwUID = Ranked_GetPlayerHardwareUIDString( victim )
	float victimAdjustedMMR = MMR_Rank_GetPostAdjustedMMR( victim )
	int victimRP = GetPlayerRankScore ( victim )

	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData( player )

	if ( victimHwUID in data.knockdownAssistPlayerByHwUID )
	{
		delete data.knockdownAssistPlayerByHwUID[ victimHwUID ]

		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.knockdownPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ( "\tPreviously knocked down assisted, promotion to assists." )
		#endif
	}
	else if ( !( victimHwUID in data.knockdownPlayerByHwUID ) )
	{
		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.knockdownPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ( "\tThis is a new knockdown." )
		#endif
	}
}


void function OnPlayerGameSummaryKnockdownAssist( entity player, entity victim, int increment )
{
	string victimHwUID = Ranked_GetPlayerHardwareUIDString( victim )
	float victimAdjustedMMR = MMR_Rank_GetPostAdjustedMMR( victim )
	int victimRP = GetPlayerRankScore ( victim )

	RankedGameSummarySquadData data = RankedGameSummary_GetPlayerData( player )

	#if DEVELOPER
		DEV_script_ranked_debug ( player.GetPlayerName() + "has assisted knocking down " + victim.GetPlayerName() )
	#endif

	if ( !( victimHwUID in data.knockdownAssistPlayerByHwUID ) && !( victimHwUID in data.knockdownPlayerByHwUID ) )
	{
		RankedVictimData v
		v.mmr = victimAdjustedMMR
		v.playerName = victim.GetPlayerName()
		v.rp = victimRP

		data.knockdownAssistPlayerByHwUID[ victimHwUID ] <- v

		#if DEVELOPER
			DEV_script_ranked_debug ( "\tThis is a new knockdown assits." )
		#endif
	}
}


void function SurvivalRank_ProcessParticiation( entity attacker, entity victim )
{
	foreach ( entity player  in GetPlayerArrayOfTeam( attacker.GetTeam() ) )
	{
		if ( !IsValid ( player ) )
			continue

		if ( player == attacker )
			continue

		if ( player in victim.p.playerToTimeThatAssistCreditLastsTable)
			continue

		if ( IsAlive( player ))
		{
			AddKillParticipationStats( player, victim ) //this triggers Callbacks_OnPlayerGameSummaryKillParticipation
			RunCallback_OnPlayerParticipation ( player, victim )
			Ranked_UpdateRankedScoreProgressForPlayer( player )
		}
	}
}
#endif

array < int > function ExtractRPFromRankedVictimDataByHwUID ( table< string, RankedVictimData >  data )
{
	array <  int > result

	foreach ( string hwID, RankedVictimData d in data )
	{
		result.append ( d.rp )
	}

	return result
}

array < float > function ExtractMMRFromRankedVictimDataByHwUID ( table< string, RankedVictimData >  data )
{
	array <  float > result

	foreach ( string hwID, RankedVictimData d in data )
	{
		result.append ( d.mmr )
	}

	return result
}

bool function HasPlayerMMR(entity player){return false}
array< float > function GetPlayerMMR(entity player){return [0.0,0.1]}

 