global function ShArenasPostRoundSummary_Init

#if(CLIENT)
global function Arenas_OpenPostRoundSummary

#if(DEVELOPER)
global function Arenas_DevSetScoreSettings
#endif

struct ArenasPostRoundDetails
{
	int roundNum
	int leftTeamScore
	int rightTeamScore
	int numTies
	bool roundWon
}

struct {
	var gladCardRui = null
	NestedGladiatorCardHandle& nestedGCHandleFront
	var materialsSummary = null
	var score = null

	#if(DEVELOPER)
	bool isDevMode = false
	ArenasPostRoundDetails& devScoreDetails
	#endif
} file
#endif

void function ShArenasPostRoundSummary_Init()
{

}

#if(CLIENT)
void function Arenas_OpenPostRoundSummary( int leftTeam, int rightTeam, float endTime )
{
	thread _OpenPostRoundSummary( leftTeam, rightTeam, endTime )
}

void function _OpenPostRoundSummary( int leftTeam, int rightTeam, float endTime )
{
	if ( Time() >= endTime )
		return

	RunUIScript( "ClientToUI_Arenas_OpenPostRoundSummary" )
	ShowScore( leftTeam, rightTeam )

	while ( Time() < endTime )
	{
		WaitFrame()
	}

	RunUIScript( "ClientToUI_Arenas_ClosePostRoundSummary" )
	CleanupScore()
}

#if(DEVELOPER)
void function Arenas_DevSetScoreSettings( int roundNum, int leftTeamScore, int rightTeamScore, int numTies, bool won )
{
	file.isDevMode = true
	ArenasPostRoundDetails d
	d.leftTeamScore = leftTeamScore
	d.rightTeamScore = rightTeamScore
	d.numTies = numTies
	d.roundNum = roundNum
	d.roundWon = won
	file.devScoreDetails = d
}
#endif

void function ShowScore( int leftTeam, int rightTeam )
{
	CleanupScore()

	int roundNum = GetRoundsPlayed()
	int leftTeamScore = Arenas_GetTeamWins( leftTeam )
	int rightTeamScore = Arenas_GetTeamWins( rightTeam )
	int numTies = GetGlobalNetInt( "arenas_numties" )
	bool roundWon = GetGlobalNetInt( "arenas_lastWonTeam" ) == GetLocalClientPlayer().GetTeam()

	file.score = CreateFullscreenRui( $"ui/arenas_round_summary_score.rpak", RUI_SORT_GLADCARD )
	RuiSetInt( file.score, "roundNum", roundNum )
	RuiSetInt( file.score, "leftTeamScore", leftTeamScore )
	RuiSetInt( file.score, "rightTeamScore", rightTeamScore )
	RuiSetInt( file.score, "numTies", numTies )
	RuiSetInt( file.score, "maxTies", GameMode_GetWinBy2MaxTies( GameRules_GetGameMode() ) )
	RuiSetBool( file.score, "roundWon", roundWon )

	#if(DEVELOPER)
		if ( file.isDevMode )
		{
			ArenasPostRoundDetails d = file.devScoreDetails
			RuiSetInt( file.score, "roundNum", d.roundNum )
			RuiSetInt( file.score, "leftTeamScore", d.leftTeamScore )
			RuiSetInt( file.score, "rightTeamScore", d.rightTeamScore )
			RuiSetInt( file.score, "numTies", d.numTies )
			RuiSetBool( file.score, "roundWon", d.roundWon )

			RunUIScript( "ClientToUI_Arenas_PopulatePostRoundSummary", d.roundNum, d.leftTeamScore, d.rightTeamScore, d.roundWon, d.numTies )
		}
		else
		{
			RunUIScript( "ClientToUI_Arenas_PopulatePostRoundSummary", roundNum, leftTeamScore, rightTeamScore, roundWon, numTies )
		}
	#else
		RunUIScript( "ClientToUI_Arenas_PopulatePostRoundSummary", roundNum, leftTeamScore, rightTeamScore, roundWon, numTies )
	#endif

	{
		array<entity> teamPlayers = GetPlayerArrayOfTeam( leftTeam )
		Arenas_PopulateTeamRuis( file.score, leftTeam, teamPlayers, "L" )
		int maxPortraits = minint( teamPlayers.len(), 3 )
		for( int i = 0; i < maxPortraits; ++i )
		{
			RuiSetInt( file.score, "portraitTeamMemberIndex_L" + (i+1), teamPlayers[i].GetTeamMemberIndex() )
		}
	}

	{
		array<entity> teamPlayers = GetPlayerArrayOfTeam( rightTeam )
		Arenas_PopulateTeamRuis( file.score, rightTeam, teamPlayers, "R" )
	}
}

void function CleanupScore()
{
	if( file.score != null )
		RuiDestroyIfAlive( file.score )

	file.score = null
}

#endif
