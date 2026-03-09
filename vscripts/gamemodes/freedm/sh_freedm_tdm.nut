                    

// What is TDM (Team Death Match)?
// 1. Team vs Team
// 2. Kill the enemy, respawning active
// 3. First team to kill X enemies wins

global function TDM_Init
global function TDM_IsSWATLoadout
global function TDM_SetIsRoundTransition
global function TDM_GetIsRoundTransition

const string TDM_VICTORY_SOUND = "TDM_UI_Victory"
const string TDM_LOSS_SOUND = "TDM_UI_Loss"

struct
{
	bool isRoundTransition = false
}
file

void function TDM_Init()
{
	#if SERVER
		if ( GameMode_AreRoundsEnabled() )
			SetRoundBased( true )

		Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Directional )

		AddCallback_OnPlayerKilled( OnPlayerKilled )

		if ( FreeDM_HasInfiniteAmmoOnAllWeapons() )
		{
			FreeDM_SetExcludedInfiniteAmmoWeaponTier([])
		}

		if ( TDM_IsSWATLoadout() )
		{
			AbilityCarePackage_SetContentOverrideCallback( SWAT_OverrideAbilityCarePackage )
			FreeDM_SetExcludedInfiniteAmmoWeaponTier([])
		}
		else
		{
			AbilityCarePackage_SetContentOverrideCallback(TDM_OverrideAbilityCarePackage)
		}
	#endif

	#if CLIENT
		PakHandle pakHandle = RequestPakFile( "ui_arenas" ) // TRACK_FEATURE_UI not available
		FreeDM_SetScoreboardSetupFunc( TDM_ScoreboardSetup() )
	#endif

	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Victory_Sound, TDM_VICTORY_SOUND )
	FreeDM_SetAudioEvent( eFreeDMAudioEvents.Defeat_Sound, TDM_LOSS_SOUND )
}

#if SERVER
void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !( attacker.IsPlayer() ) )
		return

	if ( attacker.GetTeam() == victim.GetTeam() )
		return // Friendly Fire, for now we ignore it

	FreeDM_SetScoreEventRoundWinningKillReplayEnts( victim, attacker, damageInfo )
	FreeDM_AddTeamScore( attacker.GetTeam(), 1 )
}
#endif // SERVER


bool function TDM_IsSWATLoadout()
{
	return GetCurrentPlaylistVarBool( "tdm_is_swat_loadout", false)
}

void function TDM_SetIsRoundTransition( bool isRoundTransition = false )
{
	file.isRoundTransition = isRoundTransition
}

bool function TDM_GetIsRoundTransition()
{
	return file.isRoundTransition
}

array< array<string> > function SWAT_OverrideAbilityCarePackage(entity player)
{
	array<string> left = ["armor_pickup_lv1"]
	array<string> right = ["armor_pickup_lv1"]
	array<string> center = ["armor_pickup_lv1"]

	return ([ left, center, right ])
}

array< array<string> > function TDM_OverrideAbilityCarePackage(entity player)
{
	array<string> left = ["armor_pickup_lv3"]
	array<string> right = ["armor_pickup_lv3"]
	array<string> center = ["armor_pickup_lv3"]

	return ([ left, center, right ])
}

#if CLIENT
void function TDM_ScoreboardSetup()
{
	clGlobal.showScoreboardFunc = ShowScoreboardOrMap_Teams
	clGlobal.hideScoreboardFunc = HideScoreboardOrMap_Teams

	Teams_AddCallback_ScoreboardData( FreeDM_GetScoreboardData )
	Teams_AddCallback_Header( TDM_ScoreboardUpdateHeader )
	Teams_AddCallback_PlayerScores( FreeDM_GetPlayerScores )
	Teams_AddCallback_SortScoreboardPlayers( FreeDM_SortPlayersByScore )
	Teams_AddCallback_GetTeamColor( TDM_ScoreboardGetTeamColor )
	Teams_AddCallback_IsEnabled(TDM_SetScoreboardEnabled)
}
#endif // CLIENT

#if CLIENT
void function TDM_ScoreboardUpdateHeader( var headerRui, var frameRui, int team )
{
	if( headerRui != null )
	{
		entity player = GetLocalViewPlayer()
		bool isEndOfMatch = GetGameState() >= eGameState.Resolution
		bool isObserver = GamemodeUtility_IsPlayerOnTeamObserver( player ) || IsSpectatorSpectatingPlayer( player )
		int maxScore = GetCurrentPlaylistVarInt( "scorelimit", 30 )

		int localTeam = team + TEAM_IMC

		// observer mode cameras set the scoreboards players always on the same position (team 1 on left and team 2 on the right)
		// so we gotta force the allies score and round score to be always on the left side,
		// so, for each case, we'll be grabbing the data, thinking it's always allies
		bool isAllies = isObserver ? true : team == AllianceProximity_GetAllianceFromTeam( localTeam )

		// allies data
		int alliesCurrentScore = GetAllianceTeamsScore( team )
		int alliesRoundsWon = GameRules_GetTeamScore2( localTeam )

		// enemies data
		int enemiesCurrentScore = GetAllianceTeamsScore( AllianceProximity_GetOtherAlliance( team ) )
		int enemiesRoundsWon = GameRules_GetTeamScore2(FreeDM_GetOtherTeam( localTeam ) )

		// TO DO: at the end of the match, for some reason rounds still don't get updated, need to check why, but this solves for now
		if (isEndOfMatch)
		{
			if (GetWinningTeam() == localTeam)
				alliesRoundsWon += 1

			if (GetWinningTeam() == FreeDM_GetOtherTeam( localTeam ) )
				enemiesRoundsWon += 1
		}

		// we only want to set the allies/enemies header title if is not observer
		if (!isObserver)
		{
			RuiSetString( headerRui, "headerText", Localize( team == AllianceProximity_GetAllianceFromTeam( player.GetTeam() ) ? "#ALLIES" : "#ENEMIES" ) )
		}
		RuiSetInt( headerRui, "score", isAllies ? alliesCurrentScore : enemiesCurrentScore )
		RuiSetInt( headerRui, "maxScore", maxScore )
		RuiSetInt( headerRui, "roundsWon", isAllies ? alliesRoundsWon : enemiesRoundsWon )
		RuiSetBool( headerRui, "isWinning", TDM_GetIsRoundTransition() || isEndOfMatch ? ( alliesRoundsWon > enemiesRoundsWon ) : false )
		RuiSetInt( headerRui, "gameState", TDM_GetIsRoundTransition() ? eGameState.Playing : GetGameState() )
	}
}
#endif // CLIENT

#if CLIENT
vector function TDM_ScoreboardGetTeamColor( int team )
{
	entity player = GetLocalViewPlayer()
	bool isObserver = GamemodeUtility_IsPlayerOnTeamObserver( player ) || IsSpectatorSpectatingPlayer( player )
	bool isAllies = team == AllianceProximity_GetAllianceFromTeamWithObserverCorrection( player.GetTeam() )

	if ( isObserver )
		isAllies = team == ALLIANCE_A

	vector color  = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.FRIENDLY_OWNED, true )
	if( !isAllies )
		color  = GamemodeUtility_GetColorVectorForCaptureObjectiveState( eGamemodeUtilityCaptureObjectiveColorState.ENEMY_OWNED, true )

	return color
}
#endif // CLIENT

#if CLIENT
bool function TDM_SetScoreboardEnabled()
{
	return !TDM_GetIsRoundTransition()
}
#endif // CLIENT

      