global function ClSquadRequeue_RegisterNetworkFunctions
global function SvSquadRequeue_RegisterNetworkFunctions


#if CLIENT
global function ServerCallback_SquadRequeueOptIn
global function ServerCallback_SquadRequeueOptOut
global function ServerCallback_SquadRequeuePartyMerge
global function ClSquadRequeue_OptIn
#endif // #if CLIENT


#if SERVER
global function ClientCallback_SquadRequeueOptIn
global function ClientCallback_SquadRequeueOptOut
global function SvSquadRequeue_MergeCompleted
#endif // #if SERVER


#if CLIENT
struct
{
	array<EHI> squadOptIns
	string optInLeaderUid
	bool amIOptedIn
	bool partyUpdateCallbackAdded
	float optInStartTime = -1.0
} clFile
#endif // #if CLIENT


#if SERVER
const float TIMER_GRACE_SECONDS = 1.0
struct SquadRequeueOptInPlayerEntry
{
	entity optInPlayer
	entity partyLeaderPlayer
}

struct SquadRequeueTeamEntry
{
	float optInStartTime
	bool finalized
	array<SquadRequeueOptInPlayerEntry> playerOptIns
}

struct
{
	array<int> teamNumsOnTimerArr
	table<int, SquadRequeueTeamEntry> squadOptInTeams
	bool anyPlayerOptedIn
	bool isTimerThreadRunning
} svFile
#endif // #if SERVER


void function ClSquadRequeue_RegisterNetworkFunctions()
{
	Remote_RegisterClientFunction( "ServerCallback_SquadRequeueOptIn", "entity", "float", 0.0, FLT_MAX, 32 )
	Remote_RegisterClientFunction( "ServerCallback_SquadRequeueOptOut", "int", 0, INT_MAX )
	Remote_RegisterClientFunction( "ServerCallback_SquadRequeuePartyMerge", "int", 0, INT_MAX, "bool" )
}

void function SvSquadRequeue_RegisterNetworkFunctions()
{
	Remote_RegisterServerFunction( "ClientCallback_SquadRequeueOptIn", "typed_entity", "player" )
	Remote_RegisterServerFunction( "ClientCallback_SquadRequeueOptOut" )
}


#if CLIENT
entity ornull function ClGetLeaderIfPartyMembersInSquad()
{
	entity player = GetLocalClientPlayer()
	table< string, bool > activeSquadMembers
	Party party = GetParty()
	int team = player.GetTeam()
	entity leaderPlayer = null

	foreach ( entity teammate in GetPlayerArrayOfTeam( team ) )
	{
		if ( IsValid( teammate ) && teammate.IsConnectionActive() )
		{
			string uid = teammate.GetUserID()
			activeSquadMembers[uid] <- true
			if ( uid == party.originatorUID )
				leaderPlayer = teammate
		}
	}

	foreach ( partyMember in party.members )
	{
		if ( !( partyMember.uid in activeSquadMembers ) )
			return null
	}

	return leaderPlayer
}

void function OnPartyUpdated_AfterOptIn()
{
	if ( !clFile.amIOptedIn )
		return

	entity player = GetLocalClientPlayer()
	string uid = player.GetUserID()

	if ( clFile.optInLeaderUid == uid )
	{
		// For leader - check if party all still present in squad
		entity ornull leaderPlayer = ClGetLeaderIfPartyMembersInSquad()
		if ( leaderPlayer == null )
			ClSquadRequeue_OptOut()
	}
	else
	{
		// For member - check if the leader changed to myself or someone outside of the match
		// It is okay if it changed to another member of the squad - likely a result of party merging
		Party party = GetParty()
		if ( party.originatorUID != clFile.optInLeaderUid )
		{
			if ( party.originatorUID == uid || ClGetLeaderIfPartyMembersInSquad() == null )
				ClSquadRequeue_OptOut()
		}
	}
}

void function ServerCallback_SquadRequeueOptOut( EHI optOutPlayerEHI )
{
	if ( optOutPlayerEHI == EHI_null )
		return

	int idx = clFile.squadOptIns.find( optOutPlayerEHI )
	if ( idx == -1 )
		return

	if ( LocalClientEHI() == optOutPlayerEHI )
	{
		clFile.amIOptedIn = false
		if ( clFile.partyUpdateCallbackAdded )
		{
			clFile.partyUpdateCallbackAdded = false
			RemoveCallback_OnPartyUpdated( OnPartyUpdated_AfterOptIn )
		}
	}

	clFile.squadOptIns.remove( idx )

	if ( clFile.squadOptIns.len() == 0 )
		clFile.optInStartTime = -1.0

	// TODO: UI hookup - squad member opted out
}

void function ServerCallback_SquadRequeueOptIn( entity optInPlayer, float optInStartTime )
{
	if ( !( IsValid( optInPlayer ) && optInPlayer.IsConnectionActive() ) )
		return

	EHI optInEHI = ToEHI( optInPlayer )
	if ( clFile.squadOptIns.find( optInEHI ) != -1 )
		return

	entity player = GetLocalClientPlayer()
	if ( optInPlayer == player )
	{
		clFile.amIOptedIn = true
		clFile.partyUpdateCallbackAdded = true
		AddCallback_OnPartyUpdated( OnPartyUpdated_AfterOptIn )
	}
	else
	{
		// opt me in if it was my party leader and party is still valid for opt in
		entity ornull leaderPlayerOrNull = ClGetLeaderIfPartyMembersInSquad()
		if ( leaderPlayerOrNull != null )
		{
			entity leaderPlayer = expect entity( leaderPlayerOrNull )
			if ( leaderPlayer.GetUserID() == optInPlayer.GetUserID() )
				ClSquadRequeue_OptIn()
		}
	}

	clFile.squadOptIns.append( optInEHI )
	clFile.optInStartTime = optInStartTime
	// GetConVarFloat( "matchSquadRequeue_timeLimit" ) - time limit in seconds for opting in

	// TODO: UI hookup - squad member opted in
}

void function ServerCallback_SquadRequeuePartyMerge( EHI leaderPlayerEHI, bool success )
{
	if ( success && leaderPlayerEHI == LocalClientEHI() )
	{
		if ( leaderPlayerEHI == LocalClientEHI() )
		{
			printt( "ServerCallback_SquadRequeuePartyMerge success!" )

			// Success - leader should matchmake
			//TODO: UI hookup - may want to delete the following function in favor of how its set up for party requeue
			RunUIScript( "StartMatchmakingFromMatch" )
		}
		else
		{
			entity leaderPlayer = FromEHI( leaderPlayerEHI )
			if ( IsValid( leaderPlayer ) && leaderPlayer.IsConnectionActive() )
			{
				// Success: party member should follow leader's matchmaking
			}
			else
			{
				// Fail: leader left the match
			}
		}
	}
	else
	{
		// Fail: merge parties failed
	}

	if ( clFile.partyUpdateCallbackAdded )
	{
		clFile.partyUpdateCallbackAdded = false
		RemoveCallback_OnPartyUpdated( OnPartyUpdated_AfterOptIn )
	}
}

// Calling function should check if squad eliminated / winner determined
bool function ClSquadRequeue_OptIn()
{
	if ( clFile.amIOptedIn )
		return false

	entity localPlayer = GetLocalClientPlayer()
	if ( !IsMatchmakingFromMatchAllowed( localPlayer ) )
		return false

	if ( !GetConVarBool( "matchSquadRequeue_enabled" ) )
		return false

	entity ornull partyLeaderPlayerOrNull = ClGetLeaderIfPartyMembersInSquad()
	if ( partyLeaderPlayerOrNull == null )
		return false

	entity partyLeaderPlayer = expect entity( partyLeaderPlayerOrNull )
	clFile.optInLeaderUid = partyLeaderPlayer.GetUserID()
	Remote_ServerCallFunction( "ClientCallback_SquadRequeueOptIn", partyLeaderPlayer )
	return true
}

bool function ClSquadRequeue_OptOut()
{
	if ( !clFile.amIOptedIn )
		return false

	entity localPlayer = GetLocalClientPlayer()
	if ( !IsMatchmakingFromMatchAllowed( localPlayer ) )
		return false

	if ( !GetConVarBool( "matchSquadRequeue_enabled" ) )
		return false

	if ( clFile.partyUpdateCallbackAdded )
	{
		clFile.partyUpdateCallbackAdded = false
		RemoveCallback_OnPartyUpdated( OnPartyUpdated_AfterOptIn )
	}

	Remote_ServerCallFunction( "ClientCallback_SquadRequeueOptOut" )
	return true
}
#endif // #if CLIENT


#if SERVER
void function SvSquadRequeue_MergeCompleted( int teamNum, entity leaderPlayer, bool mergeSuccess )
{
	if ( !( teamNum in svFile.squadOptInTeams ) )
		return

	foreach ( SquadRequeueOptInPlayerEntry playerEntry in svFile.squadOptInTeams[teamNum].playerOptIns )
	{
		entity player = playerEntry.optInPlayer
		if ( IsValid( player ) && player.IsConnectionActive() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_SquadRequeuePartyMerge", leaderPlayer.GetEncodedEHandle(), mergeSuccess )
	}
}

void function SvSquadRequeue_CheckFinalizeOptIns_Thread( int teamNum )
{
	WaitFrame()

	if ( !( teamNum in svFile.squadOptInTeams ) )
		return

	SquadRequeueTeamEntry teamEntry = svFile.squadOptInTeams[teamNum]
	array<entity> teamPlayerArr = GetPlayerArrayOfTeam( teamNum )

	if ( !teamEntry.finalized && teamPlayerArr.len() == teamEntry.playerOptIns.len() )
		SvSquadRequeue_FinalizeOptIns( teamNum )
}

void function SvSquadRequeue_FinalizeOptIns( int teamNum )
{
	if ( !( teamNum in svFile.squadOptInTeams ) )
		return

	SquadRequeueTeamEntry teamEntry = svFile.squadOptInTeams[teamNum]
	bool isMultipleParties = false
	entity firstPartyLeader = teamEntry.playerOptIns[0].partyLeaderPlayer
	foreach ( SquadRequeueOptInPlayerEntry playerEntry in teamEntry.playerOptIns )
	{
		if ( playerEntry.optInPlayer == playerEntry.partyLeaderPlayer )
		{
			//SquadRequeueOptIn( playerEntry.optInPlayer )
			if ( !isMultipleParties && ( firstPartyLeader != playerEntry.partyLeaderPlayer ) )
				isMultipleParties = true
		}
	}

	teamEntry.finalized = true
	//if ( isMultipleParties )
	//	MergeSquadRequeueParties( teamNum )
//	else
	//	SvSquadRequeue_MergeCompleted( teamNum, firstPartyLeader, true )
}

void function SvSquadRequeue_OptInTimer_Thread()
{
	while ( svFile.teamNumsOnTimerArr.len() != 0 )
	{
		int teamNum = svFile.teamNumsOnTimerArr[0]
		float maxWaitTime = GetConVarFloat( "matchSquadRequeue_timeLimit" ) + TIMER_GRACE_SECONDS
		float waitTimeLeft = maxWaitTime - ( Time() - svFile.squadOptInTeams[teamNum].optInStartTime )
		if ( waitTimeLeft > 0.0 )
			wait( waitTimeLeft )

		if ( !( teamNum in svFile.squadOptInTeams ) )
			continue

		SvSquadRequeue_FinalizeOptIns( teamNum )
		svFile.teamNumsOnTimerArr.remove( 0 )
	}

	svFile.isTimerThreadRunning = false
}

void function ClientCallback_SquadRequeueOptIn( entity optInPlayer, entity partyLeader )
{
	if ( !IsMatchmakingFromMatchAllowed( optInPlayer ) )
		return

	if ( !GetConVarBool( "matchSquadRequeue_enabled" ) )
		return

	if ( !( IsValid( optInPlayer ) && optInPlayer.IsConnectionActive() ) )
		return

	if ( !( IsValid( partyLeader ) && partyLeader.IsConnectionActive() ) )
		return

	if ( optInPlayer.GetTeam() != partyLeader.GetTeam() )
		return

	int optInPlayerTeamNum = optInPlayer.GetTeam()
	if ( optInPlayerTeamNum in svFile.squadOptInTeams )
	{
		SquadRequeueTeamEntry teamEntry = svFile.squadOptInTeams[optInPlayerTeamNum]
		if ( teamEntry.finalized )
			return

		foreach ( prevOptInPlayer in teamEntry.playerOptIns )
		{
			if ( optInPlayer == prevOptInPlayer.optInPlayer )
				return
		}
	}
	else
	{
		if ( optInPlayer != partyLeader )
			return

		SquadRequeueTeamEntry newTeamEntry
		newTeamEntry.optInStartTime = Time()
		newTeamEntry.finalized = false
		array<SquadRequeueOptInPlayerEntry> newPlayerOptInArr
		svFile.squadOptInTeams[optInPlayerTeamNum] <- newTeamEntry
	}

	if ( !svFile.anyPlayerOptedIn )
	{
		svFile.anyPlayerOptedIn = true
		AddCallback_OnClientDisconnected( SvOnPlayerDisconnected )
	}

	SquadRequeueOptInPlayerEntry newPlayerEntry
	newPlayerEntry.optInPlayer = optInPlayer
	newPlayerEntry.partyLeaderPlayer = partyLeader

	SquadRequeueTeamEntry teamEntry = svFile.squadOptInTeams[optInPlayerTeamNum]
	teamEntry.playerOptIns.append( newPlayerEntry )
	svFile.teamNumsOnTimerArr.append( optInPlayerTeamNum )

	if ( !svFile.isTimerThreadRunning )
	{
		svFile.isTimerThreadRunning = true
		thread SvSquadRequeue_OptInTimer_Thread()
	}

	array<entity> teamPlayerArr = GetPlayerArrayOfTeam( optInPlayerTeamNum )
	foreach ( entity teammate in teamPlayerArr )
	{
		if ( IsValid( teammate ) && teammate.IsConnectionActive() )
			Remote_CallFunction_NonReplay( teammate, "ServerCallback_SquadRequeueOptIn", optInPlayer, teamEntry.optInStartTime )
	}

	if ( !teamEntry.finalized && teamPlayerArr.len() == teamEntry.playerOptIns.len() )
		SvSquadRequeue_FinalizeOptIns( optInPlayerTeamNum )
}

void function SvSquadRequeue_OptOutPlayer( entity player )
{
	int teamIdx = player.GetTeam()
	if ( teamIdx in svFile.squadOptInTeams )
	{
		array<entity> removedPlayers
		SquadRequeueTeamEntry teamEntry = svFile.squadOptInTeams[teamIdx]
		entity ornull leaderPlayer = null
		for ( int i = 0; i < teamEntry.playerOptIns.len(); i++ )
		{
			SquadRequeueOptInPlayerEntry optInEntry = teamEntry.playerOptIns[i]
			if ( leaderPlayer == null )
			{
				if ( optInEntry.optInPlayer == player )
				{
					removedPlayers.append( optInEntry.optInPlayer )
					teamEntry.playerOptIns.remove( i-- )
					if ( player == optInEntry.partyLeaderPlayer )
					{
						leaderPlayer = player
					}
					else
					{
						break
					}
				}
			}
			else
			{
				if ( teamEntry.playerOptIns[i].partyLeaderPlayer == leaderPlayer )
				{
					removedPlayers.append( optInEntry.optInPlayer )
					teamEntry.playerOptIns.remove( i-- )
				}
			}
		}

		foreach ( entity removedPlayer in removedPlayers )
		{
			array<entity> teamPlayerArr = GetPlayerArrayOfTeam( teamIdx )
			foreach ( entity teammate in teamPlayerArr )
			{
				if ( IsValid( teammate ) && teammate.IsConnectionActive() )
					Remote_CallFunction_NonReplay( teammate, "ServerCallback_SquadRequeueOptOut", removedPlayer.GetEncodedEHandle() )
			}
		}

		if ( teamEntry.playerOptIns.len() == 0 )
		{
			delete svFile.squadOptInTeams[teamIdx]
			svFile.teamNumsOnTimerArr.removebyvalue( teamIdx )
		}
		else
		{
			thread SvSquadRequeue_CheckFinalizeOptIns_Thread( teamIdx )
		}
	}
}

void function ClientCallback_SquadRequeueOptOut( entity optOutPlayer )
{
	if ( !IsMatchmakingFromMatchAllowed( optOutPlayer ) )
		return

	if ( !GetConVarBool( "matchSquadRequeue_enabled" ) )
		return

	if ( !(IsValid( optOutPlayer ) && optOutPlayer.IsConnectionActive()) )
		return

	SvSquadRequeue_OptOutPlayer( optOutPlayer )
}

void function SvOnPlayerDisconnected( entity player )
{
	SvSquadRequeue_OptOutPlayer( player )
}
#endif // #if SERVER 