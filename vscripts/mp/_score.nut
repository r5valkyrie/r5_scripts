
global function Score_Init

global function AddPlayerScore
global function AddCallback_OnPlayerScored
global function AddCallback_Score_OnPlayerKilled

global function ScoreEvent_PlayerKilled

global function PreScoreEventUpdateStats
global function PostScoreEventUpdateStats

global function SetVictoryKillMode

//=========================================================
//	_score.nut
//  Handles scoring for MP.
//
//	Interface:
//		- ScoreEvent_*(); called from various places in different scripts to award score to players
//=========================================================

struct
{
	bool victoryKillEnabled = false
	bool firstStrikeGiven = false
	array<void functionref( entity, ScoreEvent )> onPlayerScoredCallbacks
	table< string, void functionref( entity, entity, var ) > onPlayerKilledCallbacks
} file

void function Score_Init()
{
	RegisterSignal( "EventPriority_1" )
	RegisterSignal( "EventPriority_2" )
	RegisterSignal( "EventPriority_3" )
	RegisterSignal( "EventPriority_4" )
	RegisterSignal( "EventPriority_5" )
	RegisterSignal( "EventPriority_6" )
}

void function AddCallback_OnPlayerScored( void functionref( entity, ScoreEvent ) callbackFunc )
{
	file.onPlayerScoredCallbacks.append( callbackFunc )
}

void function AddPlayerScore( entity player, string scoreEventName, entity associatedEntity = null, string associatedString = "", int pointValueOverride = 0, string dialogueOverride = "", bool isTeam = false )
{
	if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
		return

	if ( !player.hasConnected || player.GetTeam() == TEAM_SPECTATOR )
		return

	ScoreEvent event = GetScoreEvent( scoreEventName )

	if ( !ScoreEvent_IsEnabled( event ) )
		return

	if ( pointValueOverride > 0 )
	{
		event = clone event // clone event so we can temporarily modify the point value
		ScoreEvent_SetPointValue( event, pointValueOverride )
	}

	foreach ( func in file.onPlayerScoredCallbacks )
	{
		func( player, event )
	}

	int pointVal = ScoreEvent_GetPointValue( event )

	if ( pointVal > 0 )
	{
		player.AddToPlayerGameStat( PGS_SCORE, pointVal )

		switch ( ScoreEvent_GetPointType( event ) )
		{
			case scoreEventPointType.ASSAULT:
				player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, pointVal )
				break
			case scoreEventPointType.DEFENSE:
				player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, pointVal )
				break
			case scoreEventPointType.DETONATION:
				player.AddToPlayerGameStat( PGS_DETONATION_SCORE, pointVal )
				break
			case scoreEventPointType.DISTANCE:
				player.AddToPlayerGameStat( PGS_DISTANCE_SCORE, pointVal )
				break
		}
	}

	if ( IsBitFlagSet( ScoreEvent_GetDisplayType( event ), eEventDisplayType.CALLINGCARD ) )
		associatedEntity = player

	float valueA
	if ( associatedEntity != null )
	{
		valueA = DamageHistory_GetDamageFromEntity( associatedEntity, player, eDamageHistorySet.DEFAULT )
	}

	int displayType = ScoreEvent_GetDisplayType( event )

	                    
	if( scoreEventName == "Sur_SquadWipe" && IsValid( associatedEntity ) )
	{
		int bitFlag = 0
		array<entity> teammates = GetPlayerArrayOfTeam( associatedEntity.GetTeam() )
		for( int i=0; i < teammates.len(); i++ )
		{
			entity teammate = teammates[i]
			if( ( teammate == associatedEntity && associatedString == "killer" ) || Bleedout_GetBleedoutAttacker( teammate ) == player )
			{
				bitFlag = bitFlag | ( 1 << i )
			}
			table<entity, float> assistingPlayers = teammate.p.playerToTimeThatAssistCreditLastsTable
			if( player in assistingPlayers )
			{
				bitFlag = bitFlag | ( 1 << ( i + teammates.len() ) )
			}
		}
		Remote_CallFunction_NonReplay( player, "ServerCallback_ScoreEventSquadWipe", ScoreEvent_GetEventId( event ), displayType, associatedEntity, bitFlag )
	}
	else if( pointValueOverride > 0 )
	{
		if( associatedEntity == null )
			Remote_CallFunction_NonReplay( player, "ServerCallback_ScoreEventWithXpOverride", ScoreEvent_GetEventId( event ), displayType, valueA, pointValueOverride, isTeam )
		else
			Remote_CallFunction_NonReplay( player, "ServerCallback_ScoreEventWithXpOverrideAndEntity", ScoreEvent_GetEventId( event ), displayType, valueA, pointValueOverride, isTeam, associatedEntity )
	}
	else
       
	if ( associatedEntity != null )
		Remote_CallFunction_NonReplay( player, "ServerCallback_ScoreEvent", ScoreEvent_GetEventId( event ), displayType, associatedEntity, valueA )
	else
		Remote_CallFunction_NonReplay( player, "ServerCallback_ScoreEventNoEnt", ScoreEvent_GetEventId( event ), displayType, valueA )
}


void function ScoreEvent_PlayerKilled( entity player, entity attacker, var damageInfo )
{
	Assert( attacker.IsPlayer() )
	Assert( player.IsPlayer() )

	entity killer = attacker

	if ( Bleedout_IsBleedingOut( player ) )
	{
		killer = Bleedout_GetBleedoutAttacker( player )
		if ( !IsValid( killer ) || !killer.IsPlayer() )
		{
			killer = attacker
		}
	}
	string weaponClassName = GetLastDamageSourceStringForAttacker( player, killer )

	if ( GameRules_GetGameMode() in file.onPlayerKilledCallbacks )
	{
		file.onPlayerKilledCallbacks[ GameRules_GetGameMode() ]( player, attacker, damageInfo )
	}
	                    
	else if( UpgradeCore_UsePersonalObituaryNotifications() )
	{
		// do nothing, eliminated notications are handled by the squadwipe notification
	}
       
	else if ( IsPilotEliminationBased() && IsPlayerEliminated( player ) )
	{
		AddPlayerScore( killer, "EliminatePilot", player, weaponClassName )
	}
	else
	{
		string dialogueOverride = ""
		int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		switch ( damageSourceId )
		{
			case damagedef_titan_step:
				dialogueOverride = "kc_hitandrun"
				break
		}

		AddPlayerScore( killer, "KillPilot", player, weaponClassName, 0, dialogueOverride )
	}

	ScoreCheck_Kill( killer, player, damageInfo )
	if ( IsValidHeadShot( damageInfo, player ) )
		AddPlayerScore( killer, "Headshot", player )
}

void function AddCallback_Score_OnPlayerKilled( string gamemode, void functionref( entity, entity, var ) callbackFunc )
{
	file.onPlayerKilledCallbacks[gamemode] <- callbackFunc
}

void function PreScoreEventUpdateStats( entity attacker, entity victim ) //This is run before the friendly fire team check in PlayerOrNPCKilled
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	entity killer = attacker

	if ( Bleedout_IsBleedingOut( victim ) )
	{
		killer = Bleedout_GetBleedoutAttacker( victim )
		if ( !IsValid( killer ) || !killer.IsPlayer() )
			killer = attacker
	}

	if ( victim.IsPlayer() )
	{
		victim.p.numberOfDeaths++
		victim.p.numberOfDeathsSinceLastKill++

		victim.p.playerOrTitanKillsSinceLastDeath = 0

		victim.p.lastKiller = killer
		victim.p.seekingRevenge = true

		if ( killer.IsPlayer() )
		{
			if ( !( victim in killer.p.playerKillStreaks ) )
				killer.p.playerKillStreaks[ victim ] <- 0
			killer.p.playerKillStreaks[ victim ]++

			for ( int i = killer.p.recentPlayerKilledTimes.len() - 1; i >= 0; i-- )
			{
				if ( killer.p.recentPlayerKilledTimes[ i ] < ( Time() - CASCADINGKILL_REQUIREMENT_TIME ) )
					killer.p.recentPlayerKilledTimes.remove( i )
			}
			killer.p.recentPlayerKilledTimes.append( Time() )
		}
	}

	if ( killer.IsPlayer() )
	{
		killer.p.numberOfDeathsSinceLastKill = 0

		if ( IsAlive( killer ) )
		{
			if ( ShouldIncrementPlayerOrTitanKillsSinceLastDeath( killer, victim ) )
			{
				if ( victim.IsPlayer() && victim.IsTitan() )
					killer.p.playerOrTitanKillsSinceLastDeath+= 2 //Count as 2 kills for kill spree when klling a player titan
				else
					killer.p.playerOrTitanKillsSinceLastDeath++
			}
		}

		for ( int i = killer.p.recentAllKilledTimes.len() - 1; i >= 0; i-- )
		{
			if ( killer.p.recentAllKilledTimes[ i ] < Time() - CASCADINGKILL_REQUIREMENT_TIME )
				killer.p.recentAllKilledTimes.remove( i )
		}
		killer.p.recentAllKilledTimes.append( Time() )
	}
}

bool function ShouldIncrementPlayerOrTitanKillsSinceLastDeath( entity attackerPlayer, entity victim )
{
	if ( victim.IsPlayer() )
		return true

	if ( victim.IsTitan() && victim.GetTeam() != attackerPlayer.GetTeam() ) //NPC titans count for kill spree. The team check is necessary since ejecting from your own undamaged Titan will make it count as you killing the Titan!
		return true

	return false
}

void function PostScoreEventUpdateStats( entity attacker, entity victim ) //This is run before the friendly fire team check in PlayerOrNPCKilled
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	if ( victim.IsPlayer() )
	{
		if ( attacker in victim.p.playerKillStreaks )
			delete victim.p.playerKillStreaks[ attacker ]
	}

	if ( attacker.IsPlayer() )
	{
		if ( victim.IsPlayer() ) //Updating attacker killed times for CASCADINGKILL_REQUIREMENT_TIME checks to be valid.
		{
			for ( int i = 0; i < attacker.p.recentPlayerKilledTimes.len(); i++ )
			{
				attacker.p.recentPlayerKilledTimes[ i ] = Time()
			}
		}

		attacker.p.seekingRevenge = false
	}
}

void function ScoreCheck_Kill( entity attacker, entity victim, var damageInfo )
{
	Assert( IsValid( attacker ) )
	Assert( IsValid_ThisFrame( victim ) )

	if ( !GamePlayingOrSuddenDeath() )
		return

	float currentTime = Time()
	// Score bonuses for killing players
	if ( attacker.IsPlayer() )
	{
		if ( victim.IsPlayer() )
		{
			ScoreCheck_FirstStrike( attacker, victim )
			ScoreCheck_KillingSpree( attacker, victim, damageInfo )
			ScoreCheck_Comeback( attacker )
			ScoreCheck_VictoryKill( attacker, victim )
			ScoreCheck_Nemesis( attacker, victim )
			ScoreCheck_Revenge( attacker, victim, currentTime )
		}
		else if ( victim.IsTitan() )
		{
			ScoreCheck_KillingSpree( attacker, victim, damageInfo ) //Treat NPC Titans as legit target for killing spree. Mainly prompted by challenge unlocks for camo. See bug 207007
		}
	}

	// Score bonuses for killing NPC's and players
	ScoreCheck_MultiKill( attacker, victim, currentTime )
}

void function ScoreCheck_VictoryKill( entity attacker, entity victim )
{
	if ( !IsVictoryKillMode() )
		return

	bool attackerIsOnWinningTeam = GameRules_GetTeamScore( attacker.GetTeam() ) == GetScoreLimit_FromPlaylist()

	if ( !attackerIsOnWinningTeam )
		return

	AddPlayerScore( attacker, "VictoryKill", victim )
}

void function SetVictoryKillMode( bool enabled )
{
	file.victoryKillEnabled = enabled
}

bool function IsVictoryKillMode()
{
	return file.victoryKillEnabled
}

void function ScoreCheck_FirstStrike( entity attacker, entity victim )
{
	if ( file.firstStrikeGiven )
		return
	file.firstStrikeGiven = true

	AddPlayerScore( attacker, "FirstStrike", attacker )
}

void function ScoreCheck_MultiKill( entity attacker, entity victim, float currentTime )
{
	float time = Time()

	// Double Kill, Triple Kill, Mega Kill
	if ( victim.IsPlayer() )
	{
		if ( attacker.p.recentPlayerKilledTimes.len() >= MEGAKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "MegaKill" )
		else if ( attacker.p.recentPlayerKilledTimes.len() == TRIPLEKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "TripleKill" )
		else if ( attacker.p.recentPlayerKilledTimes.len() == DOUBLEKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "DoubleKill" )
	}

	// Mayhem/Onslaught Kill (Killing X grunts or pilots within the amount of time)
	int recentAllKilledLength = attacker.p.recentAllKilledTimes.len()
	if ( time > attacker.p.lastMayhemTime + CASCADINGKILL_REQUIREMENT_TIME && recentAllKilledLength >= MAYHEM_REQUIREMENT_KILLS )
	{
		float elapsedTimeForKills = currentTime - attacker.p.recentAllKilledTimes[ maxint( 0, recentAllKilledLength - MAYHEM_REQUIREMENT_KILLS ) ]
		if ( elapsedTimeForKills <= MAYHEM_REQUIREMENT_TIME )
		{
			AddPlayerScore( attacker, "Mayhem" )
			attacker.p.lastMayhemTime = time
		}
	}
	if ( time > attacker.p.lastOnslaughtTime + CASCADINGKILL_REQUIREMENT_TIME && recentAllKilledLength >= ONSLAUGHT_REQUIREMENT_KILLS )
	{
		float elapsedTimeForKills = currentTime - attacker.p.recentAllKilledTimes[ maxint( 0, recentAllKilledLength - ONSLAUGHT_REQUIREMENT_KILLS ) ]
		if ( elapsedTimeForKills <= ONSLAUGHT_REQUIREMENT_TIME )
		{
			AddPlayerScore( attacker, "Onslaught" )
			attacker.p.lastOnslaughtTime = time
		}
	}
}

// Revenge ( Get killed by a player, respawn and kill them next )
void function ScoreCheck_Revenge( entity attacker, entity victim, float currentTime )
{
	if ( !attacker.p.seekingRevenge )
		return

	if ( attacker.p.lastKiller != victim )
		return

	if ( ( currentTime - attacker.p.lastDeathTime ) <= QUICK_REVENGE_TIME_LIMIT )
		AddPlayerScore( attacker, "QuickRevenge" )
	else
		AddPlayerScore( attacker, "Revenge" )
}

void function ScoreCheck_KillingSpree( entity attacker, entity victim, var damageInfo )
{
	if ( victim.IsPlayer() && victim.p.playerOrTitanKillsSinceLastDeath >= KILLINGSPREE_KILL_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Showstopper" )
	}

	if ( attacker.p.playerOrTitanKillsSinceLastDeath == RAMPAGE_KILL_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Rampage" )
		return
	}

	if ( attacker.p.playerOrTitanKillsSinceLastDeath == KILLINGSPREE_KILL_REQUIREMENT )
	{
		AddPlayerScore( attacker, "KillingSpree" )
		return
	}
}

void function ScoreCheck_Nemesis( entity attacker, entity victim )
{
	if ( attacker.p.playerKillStreaks[ victim ] >= DOMINATING_KILL_REQUIREMENT )
		AddPlayerScore( attacker, "Dominating" )

	if ( attacker in victim.p.playerKillStreaks )
	{
		if ( victim.p.playerKillStreaks[ attacker ] >= NEMESIS_KILL_REQUIREMENT )
			AddPlayerScore( attacker, "Nemesis" )
	}
}

void function ScoreCheck_Comeback( entity attacker )
{
	if ( attacker.p.numberOfDeathsSinceLastKill >= ( COMEBACK_DEATHS_REQUIREMENT ) )
		AddPlayerScore( attacker, "Comeback" )
}