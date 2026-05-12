                       
// GunGame or GunRun is a squad vs squad vs squad vs squad battle, which we call squad free for all
// Do a search for GUNGAME_RULES_ in text files for a full description of how it works

global function GunGame_Init
global function GunGame_GetPlayerScore
global function GunGame_IsPlayerAhead
#if DEVELOPER
#if SERVER
global function DEV_GunGame_BuildWeaponList
global function DEV_GunGame_TestEndFlow
global function DEV_GunGame_TestDemotion
global function DEV_GunGame_ScorePlayer
#endif
#endif

#if CLIENT
global function ServerCallback_AnnounceScored
global function ServerCallback_AnnounceLostPoint
global function ServerCallback_AnnounceWeaponSkip
global function ServerCallback_UpdateWeaponPreviews
global function ServerCallback_GunGame_SetSummaryScreen
global function GunGame_GetHUDRui
global function GunGame_PopulateSummaryDataStrings

global function GunGame_IsTeamWinning
#endif

#if SERVER
global function ClientCallback_UpdateWeaponPreviewHUD
#endif

global const string GUNGAME_SQUAD_WEAPON_INDEX = "FreeDM_WeaponIndexSquad_"
global const string GUNGAME_THROWING_KNIFE_WEAPON_NAME = "mp_weapon_throwingknife"
const string GUNGAME_PLAYERSCORE = "GunGame_PlayerScore"
const int GUNGAME_WEAPON_SKIP_NUM_DEATHS = 3
const int NUM_TEAMMATE_UI_SLOTS = 2

#if CLIENT
const string GUNGAME_PROMOTION_SOUND = "UI_InGame_GunGame_Promotion"
const string GUNGAME_DEMOTION_SOUND = "UI_InGame_GunGame_Demotion"
const string GUNGAME_FINAL_WEAPON_SOUND = "UI_InGame_GunGame_Leader"
#endif

struct WeightedRef
{
	string ref = ""
	float weight = 1.0
}

struct
{
#if SERVER
	array<string> weaponRefs

	table<entity, int> playerScores
	table<entity, int> playerDeathStreak
#endif

#if CLIENT
	string     announceOnRespawnMsg = ""
	string	   playSoundOnRespawn = ""
	int        currentWeaponNumber = 0
	int		   weaponPreviewLootIndexPrev = 0
	int        weaponPreviewLootIndex0 = 0
	int        weaponPreviewNumber0 = 0
	int        weaponPreviewLootIndex1 = 0
	int        weaponPreviewNumber1 = 0
	array<var> scorePipRUIs
	array<entity> connectedSquadMembers
	var		   gamemodeRUI = null

	bool hasPlayedFinalWeaponSound = false
#endif
} file

// Mode-specific table info for Game Summary Squad Data
// these should be specific to the final display location - e.g., 5 displays in "slot 5" -> 1 / 1a / 1b | 2 | 3 | 4 | 5 -- maps to --> [ 0, ... , 0 ]
// so 5 would be the 5th index - or 6th slot - *in the array* or position 4 on the UI.
#if SERVER
global enum eGunGameDemotion {
	MELEE = 5,
}
#endif

void function GunGame_Init()
{
#if SERVER
	InitSpawning()
	AbilityCarePackage_SetContentOverrideCallback(GunGame_OverrideAbilityCarePackage)

	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnPlayerAssist( OnPlayerAssist )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddCallback_GameStateEnter( eGameState.Playing, GunGame_OnGameStatePlayingEnter )

	FreeDM_SetCallback_PostRespawnOverride( OnPlayerPostRespawned )
#endif

	                      
		#if SERVER
			MatchBehaviorPlayer_AddEndedCallback( GunGame_OnMatchBehaviorEnd )
		#endif // #if SERVER
                                 

	// Passed survival loot item index.
	Remote_RegisterClientFunction( "ServerCallback_AnnounceScored", "int", 0, 512 )
	// Passed attacker entity
	Remote_RegisterClientFunction( "ServerCallback_AnnounceLostPoint", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_AnnounceWeaponSkip", "int", 0, 512 )
	// Parameters are weapon0 loot index, weapon0 score progression, weapon1 loot index, weapon1 score progression
	Remote_RegisterClientFunction( "ServerCallback_UpdateWeaponPreviews", "int", 0, 256, "int", 0, 512, "int", -1, 256, "int", 0, 512, "int", -1, 256 )
	Remote_RegisterClientFunction( "ServerCallback_GunGame_SetSummaryScreen" )
	Remote_RegisterServerFunction( "ClientCallback_UpdateWeaponPreviewHUD" )
	for( int i = 0; i < MAX_TEAMS; ++i )
		RegisterNetworkedVariable( GUNGAME_SQUAD_WEAPON_INDEX + i, SNDC_GLOBAL, SNVT_INT, -1 )

	RegisterNetworkedVariable( GUNGAME_PLAYERSCORE, SNDC_PLAYER_GLOBAL, SNVT_INT, 0 )

#if CLIENT
	AddCallback_LocalClientPlayerSpawned( Client_OnPlayerSpawned )
	AddCallback_OnPlayerChangedTeam( Client_OnTeamChanged )
	AddCallback_OnSelectedWeaponChanged( GunGame_OnSelectedWeaponChanged )

	CircleBannerAnnouncementsEnable( false )
	FreeDM_SetDisplayScoreThread( DisplayGunGameScore_thread )
	FreeDM_SetScoreboardSetupFunc( GunGame_ScoreboardSetup() )
	DeathScreen_SetSkipDeathRecapAnimation( true )

	AddOnSpectatorTargetChangedCallback( GunGame_OnSpectateTargetChanged )

	AddCallback_GameStateEnter( eGameState.Prematch, GunGame_OnPlayerGameStateEntered )
	AddCallback_GameStateEnter( eGameState.PickLoadout, GunGame_OnPlayerGameStateEntered )
#endif
}

#if SERVER

void function EntitiesDidLoad()
{
	// Build list here after survival_loot has been initialized so that we have valid loot refs
	BuildWeaponList()

	if( file.weaponRefs.len() == 0 || !SURVIVAL_Loot_IsRefValid( file.weaponRefs[0] ) )
		return

	LootData lootData = SURVIVAL_Loot_GetLootDataByRef( file.weaponRefs[0] )

	for( int i = 0; i < MAX_TEAMS; ++i )
		SetGlobalNetInt( GUNGAME_SQUAD_WEAPON_INDEX + i, lootData.index )
}

const asset GUNGAME_WEAPON_LIST_DATATABLE = $"datatable/freedm/gungame_weapon_list.rpak"
void function BuildWeaponList()
{
	var dataTable	= GetDataTable( GUNGAME_WEAPON_LIST_DATATABLE )
	int numRows		= GetDataTableRowCount( dataTable )
	int col_group   = GetDataTableColumnByName( dataTable, "groupRef" )

	file.weaponRefs.clear()
	table< string, array<WeightedRef> > weaponGroups = GetWeaponGroups()
	array<string> disabledRefs

	string disabledOverride = GetCurrentPlaylistVarString( "gungame_disabled_weapons", "" )
	disabledRefs.extend( split( strip( disabledOverride ).tolower(), WHITESPACE_CHARACTERS ) )

	for( int i = 0; i < numRows; ++i )
	{
		if( i > GetScoreLimit_FromPlaylist() )
			break

		string weaponRef = ""
		string groupRef = GetCurrentPlaylistVarString( "gungame_weapon_" + i + "_override", "" )
		if( groupRef == "" )
			groupRef = strip( GetDataTableString( dataTable, i, col_group ) )

		if( SURVIVAL_Loot_IsRefValid( groupRef ) )
		{
			weaponRef = groupRef
		}
		else if( groupRef in weaponGroups )
		{
			weaponRef = GetWeightedRef( weaponGroups[groupRef], disabledRefs )
		}
		else
		{
			Warning( "Gun Run: BuildWeaponList - Unrecognized groupRef %s", groupRef )
			continue
		}

		if ( weaponRef == "" )
		{
			Warning( "Gun Run: BuildWeaponList - No available weapons in group: %s", groupRef )
			continue
		}

		file.weaponRefs.append( weaponRef )
		disabledRefs.append( GetBaseWeaponRef( weaponRef ) )

	#if DEVELOPER
		printt( "Gun Run: BuildWeaponList - Weapon %d: %s", i, weaponRef )
	#endif

	}

	// Handle case where we didn't get enough weapons to reach winning score, just fill the gap with the last weapon
	if ( file.weaponRefs.len() < GetScoreLimit_FromPlaylist() )
	{
		// Prints for logs when we don't have enough weapons to reach the score limit
		printt( "Gun Run: BuildWeaponList didn't get enough weapons to reach the winning score. Disabled Refs contained:" )
		foreach ( disabledRef in disabledRefs )
		{
			printt( "Gun Run: ", disabledRef )
		}
		printt( "Gun Run: Weapon Refs contained:" )
		foreach ( weaponRef in file.weaponRefs )
		{
			printt( "Gun Run: ", weaponRef )
		}

		while( file.weaponRefs.len() < GetScoreLimit_FromPlaylist() )
		{
			string lastWeaponRef = file.weaponRefs[ file.weaponRefs.len() - 1 ]
			#if DEVELOPER
				printt( "Gun Run: BuildWeaponList - Weapon %d: %s", file.weaponRefs.len(), lastWeaponRef )
			#endif
			file.weaponRefs.append( lastWeaponRef )
		}
	}
}

const asset GUNGAME_WEAPON_GROUPS_DATATABLE = $"datatable/freedm/gungame_weapon_groups.rpak"
table<string, array<WeightedRef> > function GetWeaponGroups()
{
	var dataTable	= GetDataTable( GUNGAME_WEAPON_GROUPS_DATATABLE )
	int numRows		= GetDataTableRowCount( dataTable )
	int col_group   = GetDataTableColumnByName( dataTable, "weaponGroup" )
	int col_weapon  = GetDataTableColumnByName( dataTable, "weaponRef" )
	int col_weight  = GetDataTableColumnByName( dataTable, "weight" )

	table< string, array<WeightedRef> > weaponGroups

	string currentGroup = ""
	array<WeightedRef> weapons
	for( int i = 0; i < numRows; ++i )
	{
		string groupRef = strip( GetDataTableString( dataTable, i, col_group ) )
		if ( groupRef != "" )
		{
			if( currentGroup != "" && weapons.len() > 0 )
			{
				if( !( currentGroup in weaponGroups ) )
				{
					string groupOverride = GetCurrentPlaylistVarString( "gungame_weapon_group_" + currentGroup + "_override", "" )
					if( groupOverride != "" )
						weaponGroups[currentGroup] <- GetWeaponGroupFromString( groupOverride )
					else
						weaponGroups[currentGroup] <- clone weapons
				}
				else
					Warning( "Gun Run: GetWeaponGroups - Error reading gungame_weapon_groups datatable. Already contains weaponGroup: %s", currentGroup )
			}

			weapons.clear()
			currentGroup = groupRef
		}
		else if( currentGroup != "" )
		{
			WeightedRef weapon
			weapon.ref = strip( GetDataTableString( dataTable, i, col_weapon ) ).tolower()
			weapon.weight = GetDataTableFloat(dataTable, i, col_weight )
			weapons.append( weapon )
		}
		else
		{
			Warning( "Gun Run: GetWeaponGroups - Error reading gungame_weapon_groups datatable. Expected new group" )
		}
	}

	if( currentGroup != "" && weapons.len() > 0 )
	{
		if( !( currentGroup in weaponGroups ) )
		{
			string groupOverride = GetCurrentPlaylistVarString( "gungame_weapon_group_" + currentGroup + "_override", "" )
			if( groupOverride != "" )
				weaponGroups[currentGroup] <- GetWeaponGroupFromString( groupOverride )
			else
				weaponGroups[currentGroup] <- clone weapons
		}
		else
			Warning( "Gun Run: GetWeaponGroups - Error reading gungame_weapon_groups datatable. Already contains weaponGroup: %s", currentGroup )
	}

	return weaponGroups
}

array<WeightedRef> function GetWeaponGroupFromString( string groupString )
{
	array<string> weightedRefs = split( strip( groupString ).tolower(), WHITESPACE_CHARACTERS )
	array<WeightedRef> weapons

	foreach ( weightedRef in weightedRefs )
	{
		array<string> tokens = split( weightedRef, ":" )
		if( tokens.len() != 2 )
		{
			Warning( "Gun Run: GetWeaponGroupFromString - Invalid weapon group: %s", weightedRef )
			continue
		}

		WeightedRef weapon
		weapon.ref = tokens[0]
		weapon.weight = float( tokens[1] )
		weapons.append( weapon )
	}

	return weapons
}

string function GetWeightedRef( array<WeightedRef> refs, array<string> disabledRefs )
{
	float totalWeight = 0.0
	array<WeightedRef> filteredRefs

	foreach( ref in refs )
	{
		// Disallow any locked set if the base is already in use
		if( disabledRefs.contains( GetBaseWeaponRef( ref.ref ) ) )
		{
			printt( "Gun Run: - GetWeightedRef is skipping: ", ref.ref, " because the base weapon: ", GetBaseWeaponRef( ref.ref ), " is already in use" )
			continue
		}

		totalWeight += ref.weight
		filteredRefs.append( ref )
	}

	if( filteredRefs.len() == 0 )
	{
		Warning( "Gun Run: GetWeightedRef - No available refs" )
		return ""
	}

	float randVal = RandomFloat( totalWeight )
	float runningTotal = 0.0
	foreach( ref in filteredRefs )
	{
		runningTotal += ref.weight
		if( runningTotal >= randVal )
			return ref.ref
	}

	unreachable
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( !IsValid( attacker ) )
	{
		Warning( "Gun Run: OnPlayerKilled - Invalid attacker" )
		return
	}

	if( !attacker.IsPlayer() )
	{
		printt( "Gun Run: OnPlayerKilled - attacker is not a player" )
		return
	}
	WeaponStatsHook_OnKillEnemy( victim, attacker, attacker, damageInfo )
	Assert( attacker in file.playerScores )

	string weaponRef = ""
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	if( IsValid( weapon ) )
	{
		weaponRef = weapon.GetWeaponClassName()
		if( weapon.IsWeaponOffhandMelee() )
		{
			GameSummarySquadData squadData = GameSummary_GetPlayerData( attacker )
			if ( ( eGunGameDemotion.MELEE in squadData.modeMetaData ) == false )
				squadData.modeMetaData[ eGunGameDemotion.MELEE ] <- 0

			squadData.modeMetaData[ eGunGameDemotion.MELEE ] += 1

			ReducePoint( attacker, victim )
		}
	}

	int score = file.playerScores[attacker]
	if( score >= file.weaponRefs.len() )
		return

	string currentWeaponRef = GetBaseWeaponRef( file.weaponRefs[score] )

                                 
                                                                                                                    
   
                                                               
                                                                                                                 
    
                                          
    
   
       

	if( currentWeaponRef == weaponRef || DidDamageRecentlyWithWeapon( attacker, victim, currentWeaponRef ) )
	{
		FreeDM_SetScoreEventRoundWinningKillReplayEnts( victim, attacker, damageInfo )
		OnPlayerElimination( attacker, victim, currentWeaponRef )
	}
}

void function OnPlayerAssist( entity attacker, entity victim )
{
	if( !GetCurrentPlaylistVarBool( "gungame_score_assists", true ) )
		return

	if( !IsValid( attacker ) )
	{
		Warning( "Gun Run: OnPlayerAssist - Invalid attacker" )
		return
	}

	Assert( attacker in file.playerScores )

	int score = file.playerScores[attacker]
	if( score >= file.weaponRefs.len() )
		return

	string currentWeaponRef = GetBaseWeaponRef( file.weaponRefs[score] )
	if( DidDamageRecentlyWithWeapon( attacker, victim, currentWeaponRef ) )
		OnPlayerElimination( attacker, victim, currentWeaponRef )
}

void function OnPlayerElimination( entity attacker, entity victim, string weaponRef )
{
	Assert( attacker in file.playerScores )
	Assert( attacker in file.playerDeathStreak )
	Assert( victim in file.playerDeathStreak )

	// having 2 teams at scorelimit causes a crash during the victory ceremony
	if ( FreeDM_IsMatchWinnerDetermined() )
		return

	int score = file.playerScores[attacker]
	if( GetBaseWeaponRef( file.weaponRefs[score] ) == weaponRef )
	{
		// Increment victims death streak and clear killers
		file.playerDeathStreak[victim] = file.playerDeathStreak[victim] + 1
		file.playerDeathStreak[attacker] = 0

		int team = attacker.GetTeam()
		
		int teamScore = GameRules_GetTeamScore( team )
		int convertedScoreLimit = int( GetCurrentPlaylistVarInt( "scorelimit", 30 ) / float( GetScorePerGun() ) )

		// Force final kill with last weapon.  Don't allow a win when a kill is made with another gun while a different player is on the final weapon
		if( teamScore + 1 >= convertedScoreLimit && file.playerScores[attacker] < file.weaponRefs.len() - 1 )
			file.playerScores[attacker] = file.weaponRefs.len() - 1
		else
			file.playerScores[attacker] = teamScore + 1

		attacker.SetPlayerNetInt( GUNGAME_PLAYERSCORE, file.playerScores[attacker] )

		if( file.playerScores[attacker] < convertedScoreLimit )
		{
			LootData lootData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
			Remote_CallFunction_NonReplay( attacker, "ServerCallback_AnnounceScored", lootData.index )
		}

		// Increase score if this player has more than current team score
		if( file.playerScores[attacker] > teamScore )
		{
			FreeDM_AddTeamScore( team, file.playerScores[attacker] - teamScore )
			UpdateSquadWeaponIndex( team )

			foreach( squadMember in GetPlayerArrayOfTeam( team ) )
			{
				if( squadMember == attacker )
					continue

				UpdateWeaponPreviewHUD( squadMember, squadMember )
			}

			// If this is the winning kill, award the player with some bonus XP
			int teamscore = GamemodeUtility_GetTeamOrAllianceScore( team )
			if ( teamscore >= convertedScoreLimit )
				AddXP( attacker, eXPType.BONUS_FINAL_KILL )
		}

		GiveWeapons( attacker )
	}
}

                      
void function GunGame_OnMatchBehaviorEnd( entity player, bool wasUnexpectedDisconnect )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_GunGame_SetSummaryScreen" )
}
      

void function ReducePoint( entity attacker, entity victim )
{
	if( !GetCurrentPlaylistVarBool( "freedm_gun_game_melee_reduce_point", false ) )
		return

	Assert( victim in file.playerScores )
	file.playerScores[victim] = maxint( file.playerScores[victim] - 1, 0 )

	victim.SetPlayerNetInt( GUNGAME_PLAYERSCORE, file.playerScores[victim] )

	int currentHighestScore = 0
	int team = victim.GetTeam()
	foreach( squadMember in GetPlayerArrayOfTeam( team ) )
	{
		if( squadMember in file.playerScores && file.playerScores[ squadMember ] > currentHighestScore )
			currentHighestScore = file.playerScores[ squadMember ]
	}

	int teamScore = GameRules_GetTeamScore( team )
	if( currentHighestScore < teamScore )
	{
		FreeDM_AddTeamScore( team, currentHighestScore - teamScore )
		UpdateSquadWeaponIndex( team )

		foreach( squadMember in GetPlayerArrayOfTeam( team ) )
		{
			if( squadMember == victim )
				continue

			UpdateWeaponPreviewHUD( squadMember, squadMember )
		}
	}

	Remote_CallFunction_NonReplay( victim, "ServerCallback_AnnounceLostPoint", attacker )
}

bool function DidDamageRecentlyWithWeapon( entity attacker, entity victim, string weaponRef )
{
	foreach( DamageHistoryStruct damageHistory in victim.e.recentDamageHistory )
	{
		if( damageHistory.attacker == attacker )
		{
			if( Weapon_GetBaseClassName(weaponRef) == GetRefFromDamageSourceID( damageHistory.damageSourceId ) )
				return true
		}
	}

	return false
}

void function UpdateSquadWeaponIndex( int team )
{
	int teamScore = GameRules_GetTeamScore( team )
	if( teamScore >= file.weaponRefs.len() )
		return

	if( !SURVIVAL_Loot_IsRefValid( file.weaponRefs[ teamScore ] ) )
		return

	LootData lootData = SURVIVAL_Loot_GetLootDataByRef( file.weaponRefs[ teamScore ] )

	int squadArrayIndex = Squads_GetArrayIndexForTeam( team )
	SetGlobalNetInt( GUNGAME_SQUAD_WEAPON_INDEX + squadArrayIndex, lootData.index )
}

void function OnPlayerPostRespawned( entity player )
{
	if( !(player in file.playerScores) )
		file.playerScores[ player ] <- 0

	if( !(player in file.playerDeathStreak) )
		file.playerDeathStreak[ player ] <- 0

	ApplyLoadout( player )
}

void function ApplyLoadout( entity player )
{
	GivePassive( player, ePassives.PAS_INFINITE_HEAL )
	SetInfiniteAmmoForGameMode( player, true )

	if ( player.GetTeam() != TEAM_SPECTATOR )
	{
		GivePlayerSettingsMods( player, [ "targetinfo_ffa_squad" ] )
		player.SetNameVisibleToEnemy( true )
	}

	ResetPlayerInventory( player )

	FreeDM_GivePlayerFullTactical( player )

	// TODO - Make equipment and consumables data drive
	string equipmentString = strip( GetCurrentPlaylistVarString( "gun_game_equipment", "armor_pickup_lv1 helmet_pickup_lv1" ).tolower() )
	array<string> equipment = split( equipmentString, WHITESPACE_CHARACTERS )
	foreach( string item in equipment )
		SURVIVAL_GivePlayerEquipment( player, item, 0, null, "", false )

	array<string> consumables = [ "health_pickup_combo_large", "health_pickup_combo_small" ]
	foreach( string item in consumables)
		SURVIVAL_AddToPlayerInventory( player, item, 1 )


	string itemRef = EquipmentSlot_GetLootRefForSlot( player, "armor" )
	if ( SURVIVAL_Loot_IsRefValid( itemRef ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )
		player.SetShieldHealthMax( SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data ) )
		player.SetShieldHealth( SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data ) )

		if ( EvolvingArmor_IsEquipmentEvolvingArmor( itemRef ) )
			EvolvingArmor_SetEvolutionProgress( player, EvolvingArmor_GetRequirementForEvolution( data.tier ) )
	}

	// Skip weapon if the player has died repeatedly. Helps move off a weapon they are stuck on
	if( GetCurrentPlaylistVarBool( "gun_game_weapon_skip_enable", true ) )
	{
		if( file.playerDeathStreak[player] >= GetCurrentPlaylistVarInt( "gun_game_weapon_skip_deaths", GUNGAME_WEAPON_SKIP_NUM_DEATHS ) )
		{
			if( file.playerScores[player] < GameRules_GetTeamScore( player.GetTeam() ) )
			{
				file.playerDeathStreak[player] = 0
				file.playerScores[player] = file.playerScores[player] + 1

				int score = file.playerScores[player]
				if( score < file.weaponRefs.len() )
				{
					string weaponRef = GetBaseWeaponRef( file.weaponRefs[score] )
					LootData lootData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
					Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceWeaponSkip", lootData.index )
				}
			}
		}
	}

	GiveWeapons( player )
}

void function GiveWeapons( entity player )
{
	GivePrimaryWeapon( player )
	UpdateWeaponPreviewHUD( player, player )
}

void function GivePrimaryWeapon( entity player )
{
	Assert( player in file.playerScores )

	int weaponProgress = file.playerScores[player]
	if( weaponProgress >= file.weaponRefs.len() )
		return

	entity weaponEnt      = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	bool weaponEntIsValid = IsValid( weaponEnt )
	if ( weaponEntIsValid && weaponEnt.IsSustainedDischargeWeapon() && weaponEnt.IsDischarging() )
		weaponEnt.ForceSustainedDischargeEnd()

	if ( weaponEntIsValid && weaponEnt.GetWeaponClassName() == "mp_weapon_shotgun_pistol_energy" )
	{
		weaponEnt.ForceChargeEndNoAttack()
	}

	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_0 )

	entity newActiveWeapon = SpawnGenericLoot( file.weaponRefs[weaponProgress], player.GetOrigin(), player.GetAngles(), -1 )

	string opticOverride = GetCurrentPlaylistVarString( "gun_game_optic_override_" + file.weaponRefs[weaponProgress], "" )
	if( opticOverride != "" )
		ReplaceOpticInWeapon( newActiveWeapon, file.weaponRefs[weaponProgress], opticOverride )

	LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( file.weaponRefs[weaponProgress] )
	array<string> lootTags = weaponData.lootTags

	SURVIVAL_GiveMainWeapon( player, newActiveWeapon, lootTags, null, false, null, false, false, [], true )
	newActiveWeapon.Destroy()
}

void function ReplaceOpticInWeapon( entity newActiveWeapon, string weaponRef, string opticOverride )
{
	if( !IsValid( newActiveWeapon ) || !SURVIVAL_Loot_IsRefValid( weaponRef ) || !SURVIVAL_Loot_IsRefValid( opticOverride ) )
		return

	LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
	array<string> mods = clone weaponData.baseMods

	ReplaceOpticInMods( mods, opticOverride )
	newActiveWeapon.SetWeaponMods( mods )
}

void function ClientCallback_UpdateWeaponPreviewHUD( entity player )
{
	entity newTarget = player.GetObserverTarget()
	if ( !IsValid( newTarget ) )
		return

	if ( !newTarget.IsPlayer() )
		return

	UpdateWeaponPreviewHUD( player, newTarget )
}

void function UpdateWeaponPreviewHUD( entity player, entity playerToPreview )
{
	if( playerToPreview in file.playerScores )
	{
		array<int> weaponIndices = [ 0, 0 ]	// Loot index
		array<int> weaponNumbers = [ -1, -1 ] // Score/progression

		int weaponProgress = GameRules_GetTeamScore( playerToPreview.GetTeam() ) + 1

		// Make sure everyone ends on throwing star even if someone on your team is on it already
		if( weaponProgress >= file.weaponRefs.len() && file.playerScores[playerToPreview] < weaponProgress - 1 )
			weaponProgress = file.weaponRefs.len() - 1

		int currentWeaponProgress = file.playerScores[playerToPreview]

		for( int i = 0; i < weaponIndices.len(); ++i )
		{
			int weaponIndex = weaponProgress + i
			if( weaponIndex < file.weaponRefs.len() )
			{
				if( SURVIVAL_Loot_IsRefValid( file.weaponRefs[ weaponIndex ] ) )
				{
					LootData data = SURVIVAL_Loot_GetLootDataByRef( file.weaponRefs[ weaponIndex ] )
					weaponIndices[i] = data.index
					weaponNumbers[i] = weaponIndex
				}
			}
		}

		Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateWeaponPreviews", currentWeaponProgress, weaponIndices[0], weaponNumbers[0], weaponIndices[1], weaponNumbers[1] )
	}
}

void function GunGame_OnGameStatePlayingEnter()
{
	foreach ( player in GetPlayerArray_Alive() )
		ApplyLoadout( player )
}

void function InitSpawning()
{
	Spawn_SetSpawnpointRatingFunc( RateSpawnpoints_Generic )

	Spawn_SetFriendlyRatingCap( FLT_MAX )
}

array< array<string> > function GunGame_OverrideAbilityCarePackage(entity player)
{
	array<string> left = ["armor_pickup_lv2"]
	array<string> right = ["armor_pickup_lv2"]
	array<string> center = ["armor_pickup_lv2"]

	return [ left, center, right ]
}

#endif // SERVER

#if CLIENT
var function GunGame_GetHUDRui()
{
	return file.gamemodeRUI
}
#endif
#if CLIENT
void function ServerCallback_AnnounceScored( int lootIndex )
{
	Assert( SURVIVAL_Loot_IsLootIndexValid( lootIndex ) )

	LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
	string weaponName = GetWeaponInfoFileKeyField_GlobalString( lootData.baseWeapon, "shortprintname" )

	entity player = GetLocalViewPlayer()
	if( IsAlive( player ) )
	{
		AnnouncementMessageRight( player,Localize( "#GUNGAME_SCORED", weaponName ) )
		EmitSoundOnEntity( player, GUNGAME_PROMOTION_SOUND )
	}
	else
	{
		file.announceOnRespawnMsg = Localize( "#GUNGAME_SCORED", weaponName )
		file.playSoundOnRespawn = GUNGAME_PROMOTION_SOUND
	}
}

void function GunGame_OnPlayerGameStateEntered()
{
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		Squads_SetCustomPlayerInfo( player )
	}
}

void function GunGame_OnSpectateTargetChanged( entity player, entity previousTarget, entity currentTarget )
{
	Remote_ServerCallFunction( "ClientCallback_UpdateWeaponPreviewHUD" )
	SquadLeader_UpdateAllUnitFramesRui()
}

void function ServerCallback_AnnounceWeaponSkip( int lootIndex )
{
	Assert( SURVIVAL_Loot_IsLootIndexValid( lootIndex ) )

	LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
	string weaponName = GetWeaponInfoFileKeyField_GlobalString( lootData.baseWeapon, "shortprintname" )

	entity player = GetLocalViewPlayer()
	if( IsAlive( player ) )
		AnnouncementMessageRight( player,Localize( "#GUNGAME_WEAPONSKIP", weaponName ) )
	else
		file.announceOnRespawnMsg = Localize( "#GUNGAME_WEAPONSKIP", weaponName )
}

void function ServerCallback_AnnounceLostPoint( entity attacker )
{
	Assert( IsValid( attacker ) )

	entity player = GetLocalViewPlayer()
	if( IsAlive( player ) )
	{
		AnnouncementMessageRight( player, Localize( "#GUNGAME_LOSTPOINT", attacker.GetPlayerName() ) )
		EmitSoundOnEntity( player, GUNGAME_DEMOTION_SOUND )
	}
	else
	{
		file.announceOnRespawnMsg = Localize( "#GUNGAME_LOSTPOINT", attacker.GetPlayerName() )
		file.playSoundOnRespawn = GUNGAME_DEMOTION_SOUND
	}
}

void function ServerCallback_UpdateWeaponPreviews( int currentWeaponNumber, int weapon0Index, int weapon0Number, int weapon1Index, int weapon1Number )
{
	file.currentWeaponNumber = currentWeaponNumber

	file.weaponPreviewLootIndexPrev = file.weaponPreviewLootIndex0

	if( SURVIVAL_Loot_IsLootIndexValid( weapon0Index ) )
		file.weaponPreviewLootIndex0 = weapon0Index

	file.weaponPreviewNumber0 = weapon0Number

	if( SURVIVAL_Loot_IsLootIndexValid( weapon1Index ) )
		file.weaponPreviewLootIndex1 = weapon1Index

	file.weaponPreviewNumber1 = weapon1Number
}

void function ServerCallback_GunGame_SetSummaryScreen()
{
	SetSummaryDataDisplayStringsCallback( GunGame_PopulateSummaryDataStrings )
}

void function GunGame_PopulateSummaryDataStrings( SquadSummaryPlayerData data )
{
	data.modeSpecificSummaryData[0].displayString = "#DEATH_SCREEN_SUMMARY_KILLS"
	data.modeSpecificSummaryData[1].displayString = "#DEATH_SCREEN_SUMMARY_ASSISTS"
	data.modeSpecificSummaryData[2].displayString = ""
	data.modeSpecificSummaryData[3].displayString = "#DEATH_SCREEN_SUMMARY_DAMAGE_DEALT"
	data.modeSpecificSummaryData[4].displayString = ""
	data.modeSpecificSummaryData[5].displayString = "#DEATH_SCREEN_SUMMARY_GUNGAME_DEMOTION_MELEE"
	data.modeSpecificSummaryData[6].displayString = ""
}

void function Client_OnPlayerSpawned( entity localPlayer )
{
	if( file.announceOnRespawnMsg != "" )
	{
		AnnouncementMessageRight( localPlayer, file.announceOnRespawnMsg )
		file.announceOnRespawnMsg = ""
	}

	if( file.playSoundOnRespawn != "" )
	{
		EmitSoundOnEntity( localPlayer, file.playSoundOnRespawn )
		file.playSoundOnRespawn = ""
	}
}

void function Client_OnTeamChanged( entity player, int oldTeam, int newTeam )
{
	if( !IsValid( player ) )
		return

	Squads_SetCustomPlayerInfo( player )
}

void function GunGame_OnSelectedWeaponChanged( entity selectedWeapon )
{
	if ( file.gamemodeRUI == null )
		return

	if ( !IsValid(selectedWeapon) || selectedWeapon == null || selectedWeapon.IsWeaponOffhandMelee() )
		return

	entity localPlayer = GetLocalViewPlayer()
	bool isWeaponTypeUlt = false

	string weaponName = selectedWeapon.GetWeaponClassName()
	printt("Gun Run: weapon Ult name: " + weaponName)

	switch( weaponName )
	{
		case SNIPERULT_WEAPON_NAME:
                  
                            
        
		case MOUNTED_TURRET_WEAPON_NAME:
		case MOBILE_HMG_WEAPON_NAME:
		case MOUNTED_TURRET_PLACEABLE_WEAPON_NAME:
			isWeaponTypeUlt = true
			break
	}

	printt("Gun Run: weapon Ult : " + isWeaponTypeUlt)
	RuiSetBool( file.gamemodeRUI, "hasWeaponUltActive", isWeaponTypeUlt )
}

void function CreateNestedScoreRUIs( var scoreRui )
{
	const MAX_SCORE_RUIS = 25 // Number of uihandles in parent rui that can be used
	int maxScore = minint( GetCurrentPlaylistVarInt( "scorelimit", 25 ), MAX_SCORE_RUIS )

	for( int i = 0; i < maxScore; ++i )
	{
		var rui = RuiCreateNested( scoreRui, "scorePip" + i + "Handle", $"ui/gun_game_score_pip.rpak" )
		file.scorePipRUIs.append( rui )
	}
}

void function DisplayGunGameScore_thread()
{
	var rui = CreateCockpitPostFXRui( $"ui/gun_game_score.rpak", MINIMAP_Z_BASE + 10 )
	CreateNestedScoreRUIs( rui )

	file.gamemodeRUI = rui

	int convertedScoreLimit = int( GetCurrentPlaylistVarInt( "scorelimit", 30 ) / float( GetScorePerGun() ) )
	RuiSetInt( rui, "scoreLimit", convertedScoreLimit )
	RuiSetInt( rui, "scoreProgressLimit", GetScorePerGun() )

	int previousTopScore = 0

	while( GetGameState() < eGameState.WinnerDetermined )
	{
		array < entity > allPlayersArray = GetPlayerArray()
		foreach ( entity player in allPlayersArray )
		{
			if ( !IsValid( player ) )
				continue

			Squads_SetCustomPlayerInfo( player )
		}

		entity localViewPlayer = GetLocalViewPlayer()

		/////////////////////////////
		// Update weapon preview HUD
		/////////////////////////////

		RuiSetInt( rui, "currentWeaponNumber", file.currentWeaponNumber + 1 )

		bool showWeapon0Connector = false
		bool showWeapon1Connector = false

		if( SURVIVAL_Loot_IsLootIndexValid( file.weaponPreviewLootIndexPrev ) )
		{
			LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( file.weaponPreviewLootIndexPrev )
			RuiSetImage( rui, "weaponIconPrev", lootData.hudIcon )
		}
		if( SURVIVAL_Loot_IsLootIndexValid( file.weaponPreviewLootIndex0 ) )
		{
			LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( file.weaponPreviewLootIndex0 )
			RuiSetImage( rui, "weaponIcon0", lootData.hudIcon )
			RuiSetInt( rui, "weaponTier0", lootData.tier )
		}
		RuiSetInt( rui, "weaponNumber0", file.weaponPreviewNumber0 + 1 )

		if( SURVIVAL_Loot_IsLootIndexValid( file.weaponPreviewLootIndex1 ) )
		{
			LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( file.weaponPreviewLootIndex1 )
			RuiSetImage( rui, "weaponIcon1", lootData.hudIcon )
			RuiSetInt( rui, "weaponTier1", lootData.tier )
		}
		RuiSetInt( rui, "weaponNumber1", file.weaponPreviewNumber1 + 1 )

		for( int i = 0; i < file.scorePipRUIs.len(); ++i )
		{
			RuiSetBool( file.scorePipRUIs[i], "displayWeapon", false )
			RuiSetColorAlpha( file.scorePipRUIs[i], "weaponColor", SrgbToLinear( <1, 1, 1> ), 1 )
			RuiSetBool( file.scorePipRUIs[i], "clientSquadScore", false )
		}

		const int MAX_UI_TEAMS = 4
		int numTeams = GetCurrentPlaylistVarInt( "max_teams", 4 )
		int myTeam = localViewPlayer.GetTeam()
		array<int> squadScores


		//Setting Teammate Variables
		array<entity> squadMembers = GetPlayerArrayOfTeam( myTeam )

		RuiSetInt(rui, "squadSize", squadMembers.len())

		squadMembers.fastremovebyvalue( localViewPlayer )
		squadMembers.sort( SquadMemberIndexSort )

		for( int i = file.connectedSquadMembers.len() - 1; i >= 0; i-- )
		{
			entity player = file.connectedSquadMembers[i]
			//checking the max team size because for some reason it sometimes tries to write to squadWeaponPreview2 that doesn't exist.
			if (!IsValid(player) && i < (GetCurrentPlaylistVarInt("max_team_size", 3)  -2) )
			{
				printt("Gun Run: remove " + i)
				RuiSetBool(rui, "squadWeaponPreview" + i, false)
				file.connectedSquadMembers.remove(i)
			}
		}

		int newTopScore = previousTopScore

		int localPlayerScore = 1
		if( IsValid( localViewPlayer ) && localViewPlayer.GetTeam() != TEAM_SPECTATOR )
			localPlayerScore = GunGame_GetPlayerScore( localViewPlayer ) + 1

		if( newTopScore < localPlayerScore )
			newTopScore = localPlayerScore

		int iterations = minint( NUM_TEAMMATE_UI_SLOTS, squadMembers.len() ) // UI can only handle upto 2 teammates
		for( int i = 0; i < iterations; i++ )
		{
			if(file.connectedSquadMembers.find(squadMembers[i]) == -1)
				file.connectedSquadMembers.append(squadMembers[i])

			if (!IsValid(squadMembers[i]))
				continue

			entity weapon = squadMembers[i].GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
			if( IsValid( weapon ) )
			{
				int score = GunGame_GetPlayerScore(squadMembers[i]) + 1
				LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )
				RuiSetImage( rui, "teammateWeaponIcon" + i, weaponData.hudIcon )
				RuiSetInt( rui, "teammateWeaponNumber" + i, score )

				if( newTopScore < score)
					newTopScore = score
			}

			RuiSetBool(rui, "squadWeaponPreview" + i, true)
		}

		//need to know when top squad member changes
		if( previousTopScore < newTopScore )
			SquadLeader_UpdateAllUnitFramesRui()

		for( int team = TEAM_IMC; team < TEAM_IMC + MAX_UI_TEAMS; team++ )
		{
			int squadIndex = Squads_GetSquadUIIndex( team )
			int reorderedIndex = Squads_GetReorderedTeamsUIId( team )

			if( reorderedIndex >= numTeams )
			{
				RuiSetBool( rui, "squadVisible" + reorderedIndex, false )
				continue
			}

			int teamScore = GameRules_GetTeamScore( team )

			if( !file.hasPlayedFinalWeaponSound && teamScore == ( convertedScoreLimit - 1 ) )
			{
				file.hasPlayedFinalWeaponSound = true
				EmitSoundOnEntity( localViewPlayer, GUNGAME_FINAL_WEAPON_SOUND )
			}

			int squadWeaponIndex = GetGlobalNetInt( GUNGAME_SQUAD_WEAPON_INDEX + Squads_GetArrayIndexForTeam( team ) )
			RuiSetInt( rui, "score_" + (reorderedIndex + 1), teamScore )

			if( SURVIVAL_Loot_IsLootIndexValid( squadWeaponIndex ) && teamScore < file.scorePipRUIs.len()-1 )
			{
				LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( squadWeaponIndex )

				RuiSetBool( file.scorePipRUIs[teamScore], "displayWeapon", true )
				if( IsValid( lootData.hudIcon ) )
					RuiSetImage( file.scorePipRUIs[teamScore], "weaponIcon", lootData.hudIcon )
				RuiSetInt( file.scorePipRUIs[teamScore], "weaponNumber", teamScore + 1 )
				string weaponName = GetWeaponInfoFileKeyField_GlobalString( lootData.baseWeapon, "shortprintname" )
				RuiSetString( file.scorePipRUIs[teamScore], "weaponName", weaponName )

				if( reorderedIndex == 0 ) // local squad
				{
					RuiSetColorAlpha( file.scorePipRUIs[teamScore], "weaponColor", Squads_GetSquadColor( 0 ), 1.0 )
					RuiSetBool( file.scorePipRUIs[teamScore], "clientSquadScore", true )
				}
			}

			GunGame_SetCharacterInfo( rui,team )
		}

		previousTopScore = newTopScore

		WaitFrame()
	}

	file.gamemodeRUI = null
	RuiDestroy( rui )
}
#endif // Client

#if CLIENT
bool function GunGame_IsTeamWinning( int teamToCheck )
{
	const int MAX_UI_TEAMS = 4

	int teamToCheckScore = GameRules_GetTeamScore( teamToCheck )
	int highestScore = 0

	for( int team = TEAM_IMC; team < TEAM_IMC + MAX_UI_TEAMS; team++ )
	{
		if( teamToCheck == team )
			continue

		if( !GameRules_IsTeamIndexValid( team ) )
			continue

		int teamScore = GameRules_GetTeamScore( team )

		if( highestScore < teamScore )
			highestScore = teamScore
	}

	return teamToCheckScore > highestScore
}
#endif // Client

#if CLIENT
void function GunGame_SetCharacterInfo( var rui, int team )
{

	int squadIndex = Squads_GetSquadUIIndex( team )
	int reorderedIndex = Squads_GetReorderedTeamsUIId( team )
	string indexString = string( squadIndex + 1 )
	
	RuiSetImage( rui, "squadImage" + indexString, Squads_GetSquadIcon(reorderedIndex ) )
	RuiSetString( rui, "squadName" + indexString, Squads_GetSquadName(reorderedIndex ) )
	RuiSetBool( rui, "squadVisible" + indexString, true )
	RuiSetColorAlpha( rui, "squadBorderColor" + indexString, Squads_GetSquadColor( reorderedIndex ), 1.0 )
}
#endif // CLIENT

#if CLIENT
void function GunGame_ScoreboardSetup()
{
	clGlobal.showScoreboardFunc = ShowScoreboardOrMap_Teams
	clGlobal.hideScoreboardFunc = HideScoreboardOrMap_Teams
	Teams_AddCallback_ScoreboardData( GunGame_GetScoreboardData )
	Teams_AddCallback_Header( GunGame_ScoreboardUpdateHeader )
	Teams_AddCallback_GetTeamColor( GunGame_GetTeamColor )
	Teams_AddCallback_GetTeamName( GunGame_GetTeamName )
	Teams_AddCallback_GetTeamIcon( GunGame_GetTeamIcon )
	Teams_AddCallback_PlayerScores( GunGame_GetPlayerScores )
	Teams_AddCallback_SortScoreboardPlayers( GunGame_SortPlayersByScore )
}
#endif // CLIENT

#if CLIENT
ScoreboardData function GunGame_GetScoreboardData()
{
	ScoreboardData data
	data.numScoreColumns = 4

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_kills_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 2 )

	data.columnDisplayIcons.append( $"rui/hud/gamestate/assist_count_icon2" )
	data.columnDisplayIconsScale.append( 0.8 )
	data.columnNumDigits.append( 2 )

	data.columnDisplayIcons.append( $"rui/hud/gamestate/player_damage_dealt_icon" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 4 )

	data.columnDisplayIcons.append( $"rui/hud/gametype_icons/scoreboard/gunscore" )
	data.columnDisplayIconsScale.append( 1.0 )
	data.columnNumDigits.append( 4 )

	return data
}
#endif // CLIENT

#if CLIENT
array< string > function GunGame_GetPlayerScores( entity player )
{
	array< string > scores

	string eliminations = string( player.GetPlayerNetInt( "kills" ) )
	scores.append( eliminations )

	string assists = string( player.GetPlayerNetInt( "assists" ) )
	scores.append( assists )

	string damage = string( player.GetPlayerNetInt( "damageDealt" ) )
	scores.append( damage )

	//LootData lootData = SURVIVAL_Loot_GetLootDataByRef( file.weaponRefs[ GunGame_GetPlayerScore( player ) ] )
	string gunNumber =  string( minint( GunGame_GetPlayerScore( player ) + 1, GetCurrentPlaylistVarInt( "scorelimit", 30 ) ) )//"%$" + lootData.hudIcon + "%"// use me for the icon
	scores.append( gunNumber )


	return scores
}
#endif // CLIENT


#if CLIENT
array< TeamsScoreboardPlayer > function GunGame_SortPlayersByScore( array< TeamsScoreboardPlayer > players )
{
	players.sort( int function( TeamsScoreboardPlayer a, TeamsScoreboardPlayer b )
	{
		entity playerA = FromEHI( a.playerEHI )
		entity playerB = FromEHI( b.playerEHI )

		if( !IsValid( playerA ) || !IsValid( playerB ) )
			return 0

		int aScore = playerA.GetPlayerNetInt( "kills" )
		int bScore = playerB.GetPlayerNetInt( "kills" )

		if ( aScore > bScore ) return -1
		else if ( aScore < bScore ) return 1
		return 0
	}
	)

	return players
}
#endif // CLIENT

#if CLIENT
void function GunGame_ScoreboardUpdateHeader( var headerRui, var frameRui, int team )
{
	if( headerRui != null )
	{
		int squadIndex = Squads_GetSquadUIIndex( team )
		int teamScore = GameRules_GetTeamScore( team )

		RuiSetString( headerRui, "headerText", Localize( Squads_GetSquadName( squadIndex ) ) )
		int squadWeaponIndex = GetGlobalNetInt( GUNGAME_SQUAD_WEAPON_INDEX + Squads_GetArrayIndexForTeam( team ) )

		if( SURVIVAL_Loot_IsLootIndexValid( squadWeaponIndex ) && GetGameState() >= eGameState.Playing )
		{
			LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( squadWeaponIndex )
			RuiSetInt( headerRui, "weaponNumber", minint( teamScore + 1, GetCurrentPlaylistVarInt( "scorelimit", 30 ) ) )
			RuiSetImage( headerRui, "weaponIcon", lootData.hudIcon )
		}

		RuiSetBool( headerRui, "isWinning", GunGame_IsTeamWinning(team) )
		RuiSetImage( headerRui, "teamIcon", Squads_GetSquadIcon(squadIndex))
		RuiSetBool( headerRui, "useGunGameElements", true )
		RuiSetBool( headerRui, "useScoreLimitElements", false )
	}

}
#endif // CLIENT

#if CLIENT
vector function GunGame_GetTeamColor( int team )
{
	int squadIndex = Squads_GetSquadUIIndex( team )

	return Squads_GetSquadColor( squadIndex )
}
#endif //client

#if CLIENT
string function GunGame_GetTeamName( int team )
{
	int squadIndex = Squads_GetSquadUIIndex( team )

	return Squads_GetSquadName( squadIndex )
}
#endif //client

#if CLIENT
asset function GunGame_GetTeamIcon( int team )
{
	int squadIndex = Squads_GetSquadUIIndex( team )

	return Squads_GetSquadIcon( squadIndex )
}
#endif //client

int function GunGame_GetPlayerScore( entity player )
{
	return player.GetPlayerNetInt( GUNGAME_PLAYERSCORE )
}

bool function GunGame_IsPlayerAhead( entity player )
{
	int team = player.GetTeam()
	array<entity> squadMembers = GetPlayerArrayOfTeam( team )

	entity playerAhead
	int highestScore = 0

	foreach( member in squadMembers )
	{
		int score = GunGame_GetPlayerScore( member )
		if( score > highestScore )
		{
			highestScore = score
			playerAhead = member
		}
	}

	return playerAhead == player
}

int function GetScorePerGun()
{
	return GetCurrentPlaylistVarInt( "gun_game_score_per_gun", 1 )
}

#if DEVELOPER
#if SERVER
void function DEV_GunGame_BuildWeaponList()
{
	BuildWeaponList()
}

void function DEV_GunGame_TestEndFlow( int winningTeam )
{
	if( winningTeam < 0 )
		return

	int maxTeams = GetCurrentPlaylistVarInt( "max_teams", 4 )
	if( winningTeam >= maxTeams )
		return

	int scoreLimit = GetCurrentPlaylistVarInt( "scorelimit", 30 )
	FreeDM_AddTeamScore( winningTeam + TEAM_IMC, scoreLimit )
}

void function DEV_GunGame_TestDemotion( entity player )
{
	int playerTeam = player.GetTeam()
	int numTeams = FreeDM_GetNumTeams()
	for( int team = TEAM_IMC; team < TEAM_IMC + numTeams; team++ )
	{
		if( team != playerTeam )
		{
			array<entity> enemyPlayers = GetPlayerArrayOfTeam_Alive( team )
			if( enemyPlayers.len() > 0 )
			{
				player.Die()
				ReducePoint( enemyPlayers[0], player )
				return
			}
		}
	}

	Warning( "Gun Run: DEV_GunGame_TestDemotion - No valid attackers found" )
}

void function DEV_GunGame_ScorePlayer( entity player )
{
	if( !IsValid( player ) || player == null )
		return

	if( !(player in file.playerScores) )
		return

	int score = file.playerScores[player]
	if( score >= file.weaponRefs.len() )
		return

	string currentWeaponRef = GetBaseWeaponRef( file.weaponRefs[score] )
	OnPlayerElimination( player, player, currentWeaponRef )
}
#endif
#endif

                            