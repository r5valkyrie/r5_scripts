global function CodeCallback_MatchIsOver


void function CodeCallback_MatchIsOver()
{
	printf( "%s() - Sending Players back to lobby.", FUNC_NAME() )

	if ( !IsMatchmakingServer() )
		GameRules_ChangeMap( "mp_lobby", GAMETYPE )
}
