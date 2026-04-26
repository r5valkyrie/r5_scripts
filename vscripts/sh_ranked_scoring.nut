//in match shared scripts
global function Sh_RankedScoring_Init
global function Ranked_GetPointsForPlacement
global function Ranked_GetPenaltyPointsForAbandon
global function Ranked_GetParticipationMutlipler
global function Ranked_GetNumProvisionalMatchesCompleted
global function Ranked_GetNumProvisionalMatchesRequired
global function Ranked_HasCompletedProvisionalMatches
                  
global function RankedGetPointsForKillsByPlacement
global function Ranked_GetPlayerTop5StreakCount
global function Ranked_GetTop5StreakBonusValue
global function Ranked_GetTop5StreakMax
global function Ranked_GetSoftKillCapMod
global function Ranked_GetSoftKillCapStartCount
global function Ranked_GetFirstKillBonusMod
global function Ranked_GetDemoCrewBonus
global function Ranked_GetDemoCrewPlacement
global function Ranked_GetDemoCrewKills
global function Ranked_GetLivingLegendBonus
global function Ranked_GetTop5StreakBonusValueFromStreak
//global function Ranked_GetHighSkillKillSkillDiffRequirement
global function Ranked_GetHighSkillKillBonusValue
global function Ranked_GetValueOfFirstKillBonus
global function Ranked_GetPlayerFirstKillBonus
global function Ranked_GetCombatBonusTotal
global function Ranked_GetProvisionalMatchResult
global function Ranked_GetPointsPerKillForPlacement
global function Ranked_GetPointsForKillsPlacement
      

#if SERVER
global function WritePlayerPostgameResultInPersistence
                  
global function Ranked_GetTotalSquadKillsUniqueByTeam
global function Ranked_GetTotalSquadKillsUniqueByPlayer
global function Ranked_AppendProvisionalMatchResult
global function Ranked_SetPlayerTop5StreakCount
      
#endif

#if UI
global function LoadLPBreakdownFromPersistance
#endif
global function GetHighEndLostMultiplier

global const RANKED_LP_PROMOTION_BONUS = 250
global const RANKED_LP_DEMOTION_PENALITY = 150
global const float PARTICIPATION_MODIFIER = 0.5
global const int RANKED_NUM_PROVISIONAL_MATCHES = 10
global const float HIGH_END_LOST_MULTIPLIER = 1.5

                  
global const int     RANKED_BONUS_TOP5STREAK = 10
global const int 	 RANKED_BONUS_TOP5STREAK_MAX = 5
global const float   RANKED_BONUS_PER_HIGH_SKILL_KILL_VALUE = 0.5
//global const float   RANKED_BONUS_MMR_REQUIRED_FOR_HIGH_SKILL_KILL = 6.33
global const float   RANKED_BONUS_KILL_SOFT_CAP_MOD = 0.5
global const int     RANKED_BONUS_KILL_SOFT_CAP_COUNT_START = 6
global const float   RANKED_BONUS_FIRST_KILL_MOD = 1.0
global const int     RANKED_BONUS_DEMO_CREW_BONUS = 50
global const int     RANKED_BONUS_DEMO_CREW_PLACEMENT = 10
global const int     RANKED_BONUS_DEMO_CREW_KILLS = 10
      

global struct RankLadderPointsBreakdown
{
	// when the server sends back data to the client about how the bonus is broken down
	// this is then converted to persistence, then back again, for post game screen.

	bool isHighTier
	bool wasInProvisonalGame			// if this game was a provisional game .. for displaying  Placement
	bool wasAbandoned					// if the player early quit out
	bool lossForgiveness				// if losses are forgiven because a teammate did not connect
	int  damage							// amount of damage dealt by the player

	int  knockdown						// the number of knockdowns the player made
	int  knockdownAssist				// the number of knockdown assists the player made

	int kills							// the number of kills the player made
	int assists							// the number of assists the player made
	int participation					// the number of elimination participation this player was involved in

	int killsUnique = 0					// the number of unique kills
	int assistUnique = 0				// the number of unique assits
	int participationUnique = 0			// the number of unique participations

	int placement						// the player's placement in the game (out of 20)
	int totalSquads						// number of total squads in the game
	int placementScore					// the score given for the player's placement

	#if SERVER
		table< string, RankedVictimData > killsPlayerByHwUID
		table< string, RankedVictimData > assistsPlayerByHwUID
		table< string, RankedVictimData > participationPlayerByHwUID
		table< string, RankedVictimData > knockdownPlayerByHwUID
		table< string, RankedVictimData > knockdownAssistPlayerByHwUID

		int killBonusUnadjusted = -1 			//caching
	#endif

	// all values are positive (net LP excluded)
	//all values are based on percentage of PLACEMENT score

	int killBonus = 0                      // actual value for kill bonus
	int convergenceBonus = 0               // actual value of convergence bonus
	int skillDiffBonus = 0                 // actual value of skill diff bonus
	int provisionalMatchBonus = 0               // if provisional game, show this number (even if it is zero)
	int promotionBonus = 0							// amount of LP Bonus given for promotion

	int demotionPenality = 0						//amount of LP punished for demotion
	int penaltyPointsForAbandoning = 0				//amount of LP punished for leaving
	int demotionProtectionAdjustment = 0			//amount of LP absorb by demotion protection
	int lossProtectionAdjustment = 0				//amount of LP given for loss protection

	int highEndAdjustment = 0    //speical adjustment for top end players

	// output
	int startingLP
	int netLP
	int finalLP

	                  
		int entryCost = 0
		int totalUniqueSquadKills = 0

		int top5Streak = 0
		int top5StreakBonusValue = 0

		int highSkillKill = 0
		int highSkillKillBonusValue = 0

		int	killValueModifierByPlacement = 0
		int firstKillBonus = 0

		int demoCrewBonus = 0
       

	int trialState = 0 // eRankedTrialState
}

global struct RankedPlacementScoreStruct
{
	// loading from shared data table
	int   placementPosition
	int   placementPoints
	int   pointsPerKill
}

struct
{
	array< RankedPlacementScoreStruct > placementScoringData
} file


void function Sh_RankedScoring_Init()
{
	Ranked_InitPlacementScoring()
}

void function Ranked_InitPlacementScoring()
{
	// Sources of references ooutside of in game - More info page
	var dataTable = GetDataTable( $"datatable/ranked_placement_scoring.rpak" ) //Force precache
	int numRows   = GetDataTableRowCount( dataTable )

	file.placementScoringData.clear()

	// script_ranked_debug ConVar not available
	// #if DEVELOPER && SERVER
	// if( GetConVarBool( "script_ranked_debug" ) )
	// {
	// 	DEV_script_ranked_debug ( "Placement Init: ")
	// }
	// #endif

	for ( int i = 0; i < numRows; ++i )
	{
		RankedPlacementScoreStruct placementScoringData
		placementScoringData.placementPosition            = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "placement" ) )
		placementScoringData.placementPoints              = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "placementPoints" ) )
		                  
		placementScoringData.pointsPerKill            = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "pointsPerKill" ) )
        
		file.placementScoringData.append( placementScoringData )

		// script_ranked_debug ConVar not available
		// #if DEVELOPER && SERVER
		// if( GetConVarBool( "script_ranked_debug" ) )
		// {
		// 	DEV_script_ranked_debug ("\t placementPosition: " + placementScoringData.placementPosition + "\t\t\t placementPoints: " + placementScoringData.placementPoints + "\t\t\tKillValue: " + placementScoringData.pointsPerKill )
		// }
		// #endif
	}
}


bool function Ranked_HasCompletedProvisionalMatches( entity player )
{
	return ( Ranked_GetNumProvisionalMatchesCompleted( player ) >= Ranked_GetNumProvisionalMatchesRequired() )
}

int function Ranked_GetNumProvisionalMatchesRequired()
{
	if ( GetConVarBool( RANKED_PROVISIONAL_MATCH_CONVAR_KILL_SWITCH ) )
		return 0

	return GetCurrentPlaylistVarInt( "ranked_num_provisional_matches", RANKED_NUM_PROVISIONAL_MATCHES )
}

int function Ranked_GetNumProvisionalMatchesCompleted( entity player )
{
#if UI
	if ( !IsFullyConnected() )
		return 0
#endif

#if CLIENT
	if ( !IsConnected() )
		return 0
#endif

	return Ranked_GetXProgMergedPersistenceData( player, RANKED_PROVISIONAL_MATCH_COUNT_PERSISTENCE_VAR_NAME )
}

                  
array < int > function Ranked_GetProvisionalMatchResult ( entity player )
{
	array < int > results
	#if UI
	if ( !IsFullyConnected() )
		return results
	#endif

	#if CLIENT
		if ( !IsConnected() )
			return results
	#endif

	for ( int i = 0 ; i < Ranked_GetNumProvisionalMatchesRequired(); i++ )
	{
		results.append ( Ranked_GetXProgMergedPersistenceData( player, format ( RANKED_PROVISONAL_MATCH_RESULTS_FORMAT_STRINGS, string ( i ) ) ) )
	}

	//#if DEVELOPER
	//foreach ( int i in results)
	//	printf ( string (i) )
	//#endif
	return results

	unreachable
}

#if SERVER
void function Ranked_AppendProvisionalMatchResult ( entity player , int netLP )
{
	int matchesCompleted = Ranked_GetNumProvisionalMatchesCompleted( player )
	#if DEVELOPER
	DEV_script_ranked_debug ("for append ; num provisonal matches completed" + matchesCompleted)
	#endif

	if ( matchesCompleted <= 0 ) //didnt play a game... how can you set a game??
	{
		Assert ( false, "provisional matches completed less than 1, and write was attempted " )
		return
	}

	if ( matchesCompleted > 10 )
	{
		return
	}

	int writeIndex = matchesCompleted - 1
	Assert ( writeIndex >= 0 )
	Assert ( writeIndex <= RANKED_NUM_PROVISIONAL_MATCHES )
	Ranked_SetProvisionalMatchResult ( player, writeIndex, netLP )
}

void function Ranked_SetProvisionalMatchResult( entity player, int i , int value )
{
	#if DEVELOPER
	DEV_script_ranked_debug ("-------------------------------------------------------" )
	DEV_script_ranked_debug ("--Ranked_SetProvisionalMatchResult" )
		DEV_script_ranked_debug ("--player " + player.GetPlayerName() )
		DEV_script_ranked_debug ("--i " + i )
		DEV_script_ranked_debug ("--value " + value )
	DEV_script_ranked_debug ("-------------------------------------------------------" )

	Assert ( i >= 0 )
	Assert ( i <= RANKED_NUM_PROVISIONAL_MATCHES )

	#endif

	Ranked_SetXProgMergedPersistenceData( player, format ( RANKED_PROVISONAL_MATCH_RESULTS_FORMAT_STRINGS, string ( i ) ), value )
}

#endif

int function Ranked_GetPlayerTop5StreakCount ( entity player )
{
	#if UI
	if ( !IsFullyConnected() )
		return 0
	#endif

	#if CLIENT
		if ( !IsConnected() )
			return 0
	#endif

	return Ranked_GetXProgMergedPersistenceData( player, RANKED_TOP_5_STREAK_PERSISTENCE_VAR_NAME )
}
      

int function Ranked_GetPointsForPlacement( int placement )
{
	int lookupPlacement    = minint( file.placementScoringData.len() - 1, placement )
	int csvValue           = file.placementScoringData[ lookupPlacement ].placementPoints
	string playlistVarName = "rankedPointsForPlacement_" + lookupPlacement

	return GetCurrentPlaylistVarInt( playlistVarName, csvValue )
}

                  
int function RankedGetPointsForKillsByPlacement ( int placement )
{
	int lookupPlacement    = minint( file.placementScoringData.len() - 1, placement )
	int csvValue           = file.placementScoringData[ lookupPlacement ].pointsPerKill
	string playlistVarName = "rankedPointsForKillsByPlacement_" + lookupPlacement

	return GetCurrentPlaylistVarInt( playlistVarName, csvValue )
}

#if SERVER
int function Ranked_GetTotalSquadKillsUniqueByPlayer ( entity player )
{
	int team = player.GetTeam()
	return Ranked_GetTotalSquadKillsUniqueByTeam ( team )
}

int function Ranked_GetTotalSquadKillsUniqueByTeam ( int team )
{
	//test me lots.
	table< int, RankedGameSummarySquadData > ornull data = RankedGameSummary_GetTeamDataOrNull ( team )

	if ( data == null )
	{
		return 0
	}

	expect table < int, RankedGameSummarySquadData > ( data )
	array < string > killsByHwUID

	foreach ( RankedGameSummarySquadData teammate in data )
	{
		foreach ( string hwUID, RankedVictimData d in teammate.killsPlayerByHwUID )
		{
			if ( !killsByHwUID.contains( hwUID ) )
			{
				killsByHwUID.append( hwUID )
			}
		}
	}

	#if DEVELOPER
		//DEV_script_ranked_debug ( format (" Ranked_GetTotalSquadKillsUniqueByTeam for team %i has %i unique kills", team, killsByHwUID.len() ))
	#endif

	return killsByHwUID.len()
}
#endif
      

float function Ranked_GetParticipationMutlipler( )
{
	return GetCurrentPlaylistVarFloat( "ranked_participation_mod", PARTICIPATION_MODIFIER )
}

                  
int function Ranked_GetPenaltyPointsForAbandon( SharedRankedDivisionData currentRank )
     
                                                 
      
{
	//updated to reflect divisional cost from Ranked Reloaded
	string playlistVarString      = "ranked_abandon_cost"

                   
		return GetCurrentPlaylistVarInt( playlistVarString, Ranked_GetCostForEntry( currentRank ) )
      
                                                                                
       
}

#if SERVER

void function WritePlayerPostgameResultInPersistence ( entity player, RankLadderPointsBreakdown breakdown  ) {

	                  
		SharedRankedDivisionData currentDivision = GetCurrentRankedDivisionFromScore( breakdown.startingLP )

		if ( GetCurrentPlaylistVarBool ( "ranked_store_provisional_results" , false ) )
		{
			if ( breakdown.wasInProvisonalGame )
			{
				if	( ! ( breakdown.netLP == 0 && breakdown.lossForgiveness ) )
				{
					//only record provisionals if the game was NOT loss forgivened
					Ranked_AppendProvisionalMatchResult ( player , breakdown.netLP - breakdown.provisionalMatchBonus )
				}
			}
		}
       

	#if DEVELOPER
		DEV_script_ranked_debug ("-------------------------------------------------------" )
		DEV_script_ranked_debug ("--Writing Player Post Game results to persistence" )
		DEV_script_ranked_debug ("-------------------------------------------------------" )
		DEV_script_ranked_debug ("\tSetPlayerRankedGameScoringData START for Player " + player.GetPlayerName() )
		//DEV_script_ranked_debug ("\tlastGameParticipationCount: " + breakdown.participation )
		DEV_script_ranked_debug ("\tlastGameAssistCount: " + breakdown.assists )

                    
			DEV_script_ranked_debug ("\tlastGamePlacementScore: " + ( breakdown.placementScore ) )
       
                                                                                                                   
        

		DEV_script_ranked_debug ("\tlastGameBonus[4]: " + breakdown.highEndAdjustment )
		DEV_script_ranked_debug ("\tlastGamePenaltyPointsForAbandoning: " + breakdown.penaltyPointsForAbandoning )
		DEV_script_ranked_debug ("\tlastGameLossProtectionAdjustment: " + breakdown.lossProtectionAdjustment )
		DEV_script_ranked_debug ("\tlastGameTierDerankingProtectionAdjustment: " + breakdown.demotionProtectionAdjustment )
		DEV_script_ranked_debug ("\tlastGameBonus[0]: " + breakdown.killBonus )
		DEV_script_ranked_debug ("\tlastGameBonus[1]: " + breakdown.convergenceBonus )
		DEV_script_ranked_debug ("\tlastGameBonus[2]: " + breakdown.skillDiffBonus )
		DEV_script_ranked_debug ("\tlastGameBonus[3]: " + breakdown.provisionalMatchBonus )
		DEV_script_ranked_debug ("\tlastGameBonus[4]: " + breakdown.highEndAdjustment )
		DEV_script_ranked_debug ("\tlastGameStartingScore: " + breakdown.startingLP )
		DEV_script_ranked_debug ("\tlastGameScoreDiff: " + breakdown.netLP )
	#endif

	//SetRankedGameData( player, "lastGameRankedAbandon", int (breakdown.wasAbandoned))  //done in prior methods
                   
		SetRankedGameData( player, "lastGamePlacementScore", breakdown.placementScore )

      
                                                                                                            
       

	SetRankedGameData( player, "lastGameParticipationCount", breakdown.participationUnique )

	SetRankedGameData( player, "lastGamePenaltyPointsForAbandoning", breakdown.penaltyPointsForAbandoning )
	SetRankedGameData( player, "lastGameLossProtectionAdjustment", breakdown.lossProtectionAdjustment )
	SetRankedGameData( player, "lastGameTierDerankingProtectionAdjustment", breakdown.demotionProtectionAdjustment )
	SetRankedGameData( player, "lastGameScoreDiff", breakdown.netLP )
	SetRankedGameData ( player, "lastGameStartingScore" , breakdown.startingLP )


	SetRankedGameData ( player, "lastGameBonus[5]" , breakdown.promotionBonus )
	SetRankedGameData ( player, "lastGameBonus[3]" , breakdown.provisionalMatchBonus )

                    
                                                                       
                                                                              
                                                                            
                                                                               
	     
	SetRankedGameData ( player, "lastGameBonus[0]" , breakdown.killBonus )
	SetRankedGameData ( player, "lastGameBonus[1]" , breakdown.highSkillKill )
	SetRankedGameData ( player, "lastGameBonus[2]" , breakdown.highSkillKillBonusValue )
	SetRankedGameData ( player, "lastGameBonus[7]" , breakdown.demoCrewBonus )
	SetRankedGameData ( player, "lastGameBonus[4]" , breakdown.totalUniqueSquadKills )
	SetRankedGameData ( player, "lastGameBonus[6]" , breakdown.firstKillBonus )
	SetRankedGameData ( player, "lastGameKillsUnique" , breakdown.killsUnique )
	SetRankedGameData ( player, "lastGameAssistUnique" , breakdown.assistUnique )
       

	SetRankedGameData ( player, RANKED_TRIALS_PERSISTENCE_STATE_KEY , breakdown.trialState )
	                  
	Ranked_SetPlayerTop5StreakCount ( player, breakdown.top5Streak )
       
	Ranked_SetLastGameParticipationScore( player, breakdown.participationUnique )
}

void function Ranked_SetPlayerTop5StreakCount ( entity player, int value )
{
	Ranked_SetXProgMergedPersistenceData( player, RANKED_TOP_5_STREAK_PERSISTENCE_VAR_NAME, value )
}
#endif //server

#if UI
void function LoadLPBreakdownFromPersistance ( RankLadderPointsBreakdown breakdown , entity player)
{
	// Inverse of SetPlayerRankedScoringData in sv_ranked_bonus.nut
	// Used in menu_post_game_ranked.nut
	//breakdown.participation  = GetRankedGameData( player, "lastGameParticipationCount" )
	//breakdown.assists 		 = GetRankedGameData( player, "lastGameAssistCount" )

	string myName 					   	   = GetPlayerName()
	int mySquadIndex					   = -1
	int maxTrackedSquadMembers 			   = PersistenceGetArrayCount( "lastGameSquadStats" )
	for ( int i = 0 ; i < maxTrackedSquadMembers ; i++ )
	{

		string squadMemberName = expect string( player.GetPersistentVar( "lastGameSquadStats[" + i + "].playerName" ) )
		if ( squadMemberName == myName )
		{
			mySquadIndex = i
			break
		}
	}

	if ( mySquadIndex >= 0 )
	{
		breakdown.kills 				   = GetPersistentVarAsInt( "lastGameSquadStats[" + mySquadIndex + "].kills" )
		breakdown.assists 				   = GetPersistentVarAsInt( "lastGameSquadStats[" + mySquadIndex + "].assists" )
		breakdown.participationUnique  	   = GetRankedGameData( player, "lastGameParticipationCount" )
	}

	breakdown.wasAbandoned 				   =  bool ( GetRankedGameData( player,  "lastGameRankedAbandon" ) )
	breakdown.placement 				   = player.GetPersistentVarAsInt( "lastGameRank" )
	breakdown.totalSquads				   = player.GetPersistentVarAsInt( "lastGameSquads" )
	breakdown.placementScore 			   = GetRankedGameData( player, "lastGamePlacementScore" )

	breakdown.wasInProvisonalGame          = Ranked_GetNumProvisionalMatchesCompleted( player ) <= Ranked_GetNumProvisionalMatchesRequired()
	breakdown.penaltyPointsForAbandoning   = GetRankedGameData( player,  "lastGamePenaltyPointsForAbandoning" )
	breakdown.lossProtectionAdjustment     = GetRankedGameData ( player, "lastGameLossProtectionAdjustment"  )
	breakdown.demotionProtectionAdjustment = GetRankedGameData ( player, "lastGameTierDerankingProtectionAdjustment" )
	breakdown.startingLP                   = GetRankedGameData ( player, "lastGameStartingScore" )
	breakdown.netLP 					   = GetRankedGameData ( player, "lastGameScoreDiff" )

	breakdown.killBonus                    = GetRankedGameData ( player, "lastGameBonus[0]" )
	breakdown.provisionalMatchBonus        = GetRankedGameData ( player, "lastGameBonus[3]" )
	breakdown.promotionBonus               = GetRankedGameData ( player, "lastGameBonus[5]" )

                    
                                                                                          
                                                                                          
                                                                                          
       

	breakdown.finalLP 					   = breakdown.startingLP + breakdown.netLP

	breakdown.demotionPenality 			   = ( GetCurrentRankedDivisionFromScore( breakdown.finalLP ).tier.index  < GetCurrentRankedDivisionFromScore( breakdown.startingLP ).tier.index )
													? GetCurrentPlaylistVarInt ( "ranked_tier_demotion_penality", RANKED_LP_DEMOTION_PENALITY )
													: 0

	breakdown.trialState = GetRankedGameData( player, RANKED_TRIALS_PERSISTENCE_STATE_KEY )

	                  
		breakdown.entryCost 			  		= GetCurrentRankedDivisionFromScore( breakdown.startingLP ).divisionEntryCost

		breakdown.top5Streak  			  		= Ranked_GetPlayerTop5StreakCount ( player )
		breakdown.top5StreakBonusValue   		= Ranked_GetTop5StreakBonusValueFromStreak ( breakdown.top5Streak )

		breakdown.killValueModifierByPlacement  = RankedGetPointsForKillsByPlacement ( breakdown.placement )

		breakdown.highSkillKill 		 		= GetRankedGameData ( player, "lastGameBonus[1]" )
		breakdown.highSkillKillBonusValue 		= GetRankedGameData ( player, "lastGameBonus[2]" )
		breakdown.demoCrewBonus 				= GetRankedGameData ( player, "lastGameBonus[7]" )
		breakdown.totalUniqueSquadKills  		= GetRankedGameData ( player, "lastGameBonus[4]" )
		breakdown.firstKillBonus        		= GetRankedGameData ( player, "lastGameBonus[6]" )
		breakdown.killsUnique        		= GetRankedGameData ( player, "lastGameKillsUnique" )
		breakdown.assistUnique        		= GetRankedGameData ( player, "lastGameAssistUnique" )
       

	//PrintRankLadderPointsBreakdown (breakdown, 1, "LoadLPBreakdownFromPersistance" ) // removed: debug function not available
}
#endif

float function GetHighEndLostMultiplier ()
{
	return GetCurrentPlaylistVarFloat( "ranked_tuning_var_high_end_multiplier", HIGH_END_LOST_MULTIPLIER ) //1.5
}

                  
int function Ranked_GetTop5StreakBonusValue ()
{
	return GetCurrentPlaylistVarInt ( "rankedtop5streakbonusvalue", RANKED_BONUS_TOP5STREAK )
}

int function Ranked_GetTop5StreakMax ()
{
	return GetCurrentPlaylistVarInt ( "rankedtop5streakbonusvalue", RANKED_BONUS_TOP5STREAK_MAX )
}

float function Ranked_GetSoftKillCapMod ()
{
	return GetCurrentPlaylistVarFloat ( "rankedSoftKillCapMod", RANKED_BONUS_KILL_SOFT_CAP_MOD )
}

int function Ranked_GetSoftKillCapStartCount ()
{
	return GetCurrentPlaylistVarInt ( "rankedSoftKillCapStartCount", RANKED_BONUS_KILL_SOFT_CAP_COUNT_START )
}

float function Ranked_GetFirstKillBonusMod ()
{
	return GetCurrentPlaylistVarFloat ( "rankedFirstKillBonusMod", RANKED_BONUS_FIRST_KILL_MOD )
}

int function Ranked_GetDemoCrewBonus ()
{
	return GetCurrentPlaylistVarInt ( "rankedDemoCrewBonus", RANKED_BONUS_DEMO_CREW_BONUS )
}

int function Ranked_GetDemoCrewPlacement ()
{
	return GetCurrentPlaylistVarInt ( "rankedDemoCrewPlacement", RANKED_BONUS_DEMO_CREW_PLACEMENT )
}

int function Ranked_GetDemoCrewKills ()
{
	return GetCurrentPlaylistVarInt ( "rankedDemoCrewKills", RANKED_BONUS_DEMO_CREW_KILLS )
}

int function Ranked_GetTop5StreakBonusValueFromStreak ( int streakCount )
{
	int streakSlope  = GetCurrentPlaylistVarInt ( "ranked_top5_StreakBonus", RANKED_BONUS_TOP5STREAK ) //10
	int streakCap =  GetCurrentPlaylistVarInt ( "ranked_top5_StreakBonusCap", RANKED_BONUS_TOP5STREAK_MAX ) //5
	return maxint ( 0 , ( minint ( streakCount, streakCap)  - 1 ) *  streakSlope )
}

int function Ranked_GetLivingLegendBonus ( int kills, int placement )
{
	if ( kills >= Ranked_GetDemoCrewKills() && placement <= Ranked_GetDemoCrewPlacement () )
	{
		return Ranked_GetDemoCrewBonus ()
	}
	return 0
}

//float function Ranked_GetHighSkillKillSkillDiffRequirement ()
//{
//	return GetCurrentPlaylistVarFloat ( "ranked_bonus_skillDiff_high_skill_kill", RANKED_BONUS_MMR_REQUIRED_FOR_HIGH_SKILL_KILL )
//}

float function Ranked_GetHighSkillKillBonusValue (  )
{
	return GetCurrentPlaylistVarFloat ( "ranked_bonus_value_for_high_skill_kill" , RANKED_BONUS_PER_HIGH_SKILL_KILL_VALUE )
}

int function Ranked_GetValueOfFirstKillBonus ( int placement )
{
	return int ( float ( RankedGetPointsForKillsByPlacement ( placement ))  * Ranked_GetFirstKillBonusMod() )
}

int function Ranked_GetPlayerFirstKillBonus ( int killCount , int placement)
{
	if ( killCount > 0  )
	{
		return int ( float ( Ranked_GetValueOfFirstKillBonus ( placement )) * Ranked_GetFirstKillBonusMod () )
	}
	return 0
}

int function Ranked_GetCombatBonusTotal ( int kill, int assist, int participation, int placement )
{
	float count = kill + assist +  ( participation * Ranked_GetParticipationMutlipler() )

	if ( count >  Ranked_GetSoftKillCapStartCount () )
	{
		count = Ranked_GetSoftKillCapStartCount () + ( ( count -  Ranked_GetSoftKillCapStartCount () ) * Ranked_GetSoftKillCapMod () )
	}

	return int ( count * float ( RankedGetPointsForKillsByPlacement ( placement ) ) )
}
      



int function Ranked_GetPointsPerKillForPlacement( int placement )
{
	return GetCurrentPlaylistVarInt( "rankedPointsPerKillForPlacement_" + placement, 10 )
}

int function Ranked_GetPointsForKillsPlacement( int placement )
{
	return GetCurrentPlaylistVarInt( "ranked_placementKill_" + placement, 10 )
}
