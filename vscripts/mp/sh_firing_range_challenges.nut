#if SERVER || CLIENT
global function ShFiringRangeChallenges_Init
global function FRC_RegisterChallenge
global function FRC_IsEnabled
#endif

#if SERVER

global function FRC_AddCleanupEnt
global function FRC_UpdateState
global function FRC_UpdateScore
global function FRC_IsChallengeActive
global function FRC_IsPlayerActiveForChallenge
global function FRC_ClientToServer_TryLeaveChallenge
#if DEVELOPER
global function DEV_FiringRange_HideTargets
#endif // DEVELOPER
#endif

#if CLIENT
global function FRC_StartChallengeTimer
global function ServerCallback_FRC_UpdateState
global function ServerCallback_FRC_SetChallengeKey
global function ServerCallback_FRC_UpdateOutofBounds
global function ServerCallback_FRC_PostGameStats
global function FRC_GetState
#endif

// GUNRACK_MODEL already defined as global const in _loot_gun_racks.nut
const asset GUNRACK_BASE_MODEL = $"mdl/props/explosivehold_container_01/explosivehold_gunrackcap_01.rmdl"
const vector BASE_ORIGIN_OFFSET = <-10, 0, 0>
const vector BASE_ANGLE_OFFSET = <0, 180, 0>

const float POST_CHALLENGE_WAIT_TIME = 10.0
const int ACTIVE_CHALLENGE_WEAPON_FLAGS = WPT_TACTICAL | WPT_ULTIMATE | WPT_MELEE

const asset FRC_BORDER01_MDL = $"mdl/canyonlands/firingrange_perimetermarker_01.rmdl"
const asset FRC_BORDER02_MDL = $"mdl/canyonlands/firingrange_perimetermarker_02.rmdl"

const string FRC_SCORE_NETWORK_VAR = "firingRangeChallengeScore"

global enum eFiringRangeChallengeType
{
	FR_CHALLENGE_TYPE_TARGETS_HIT,
	FR_CHALLENGE_TYPE_BEST_DAMAGE,
	FR_CHALLENGE_TYPE_BEST_TIME
}

global struct FiringRangeChallengeRegistrationData
{
	string           challengeName
	string           challengeInteractStr
	string		     challengeStartHint
	string           challengeKey
	vector           gunRackOrigin
	vector           gunRackAngles
	string           gunRackScriptName
	string           weaponRef
	array < string > weaponMods
	asset            weaponMdl
	asset		 	 rewardTracker

	int   challengeType
	float challengeTime = 0.0
	string borderName = ""
	int borderType = 0
	string outOfBoundsTriggerScriptName = ""

	StatTemplate& statTemplate

	vector playerTeleportPosition
	array <vector> squadSafePosition

	array < string > postGameStats

	void functionref( entity ) challengeSetupFunc
	void functionref( entity ) challengeStartFunc
	void functionref( int ) challengeCleanUpFunc
	void functionref( entity, bool ) challengePostFunc
}

struct FiringRangeChallengeRealmData
{
	int score = 0
	int challengeState = eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE
	string challengeKey = ""
	array < entity > entsToClean
#if SERVER
	entity activePlayer = null
	int team = TEAM_INVALID

	bool wasOutOfBounds = false
	float leaveTime = FLT_MAX
	float enterTime
	float timeSpentOutOfBounds = 0
	string triggerScriptName = ""
	int	challengeType =  0

	array < entity > challengeWeapons

	//global session stats.
	int shotsFired = 0
	int damage = 0
	int shotsHit = 0
	int critShotsHit = 0
#endif

	int target = 0

}

struct
{
	table < string, FiringRangeChallengeRegistrationData > registeredFiringRangeChallenges
	table< int,  FiringRangeChallengeRealmData > firingRangeChallengeDataByRealmTable
	table < string, vector > borderOriginByScriptNameTable

	#if CLIENT
		int score = 0
		int challengeState = eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE
		string challengeKey = ""
		var challengeRui = null
		array< string > registeredChallengeWeaponScriptName
	#endif
} file


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  #### ##    ## #### ########
//   ##  ###   ##  ##     ##
//   ##  ####  ##  ##     ##
//   ##  ## ## ##  ##     ##
//   ##  ##  ####  ##     ##
//   ##  ##   ###  ##     ##
//  #### ##    ## ####    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if SERVER || CLIENT
void function ShFiringRangeChallenges_Init()
{
	if ( GetMapName() != "mp_rr_canyonlands_staging" ) //keeping it broad for testing with dev playlists
		return

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	if ( !FRC_IsEnabled() )
		return

	RegisterNetworkedVariable( FRC_SCORE_NETWORK_VAR, SNDC_PLAYER_EXCLUSIVE, SNVT_BIG_INT, 0 )

	#if SERVER
		AddCallback_OnClientDisconnected( FRC_OnPlayerDisconnected )
		AddCallback_OnPlayerKilled ( FRC_OnPlayerKilled )
		Bleedout_AddCallback_OnPlayerStartBleedout( FRC_OnPlayerDowned )
		AddCallback_OnPlayerRespawned( FRC_OnPlayerSpawned )
		// Loot_AddCallback_OnLootSpawn( FRC_OnLootSpawn ) // S3: callback not available
		PrecacheModel( GUNRACK_MODEL )
		PrecacheModel ( GUNRACK_BASE_MODEL )
		PrecacheModel ( FRC_BORDER01_MDL )
		PrecacheModel ( FRC_BORDER02_MDL )
		#if DEVELOPER
			RegisterSignal("DEV_EndChallenge")
		#endif

		AddCallback_OnWeaponAttack( FRC_OnWeaponFired )
	#endif

	#if CLIENT
		RegisterSignal("FRChallengeStarted")
		RegisterSignal("FRChallengeEnded")
		AddCreateCallback( "prop_script", FRChallenge_GunCreated )
		AddCinematicEventFlagChangedCallback( CE_FLAG_HIDE_MAIN_HUD_INSTANT, OnFirstDrawCinematicFlagChanged )
		RegisterSignal("FRChallengedEndMemoriesEffect")
		PrecacheParticleSystem( $"P_adrenaline_screen_CP" )

		RegisterNetVarIntChangeCallback( FRC_SCORE_NETWORK_VAR, FiringRangeChallengeScoreUpdated, SNDC_PLAYER_EXCLUSIVE )
	#endif

	RegisterSignal("FRC_BackInBounds")
	RegisterSignal( "FRChallengeEnded" )

}

bool function FRC_IsEnabled()
{
	return GetCurrentPlaylistVarBool( "s12e04_EnableFRChallenges", false )
}

void function FRC_RegisterChallenge( string challengeKey, FiringRangeChallengeRegistrationData data )
{
	Assert( !(challengeKey in file.registeredFiringRangeChallenges) , "Another firing range challenge with key " + challengeKey + " already registered." )

	if ( !GetCurrentPlaylistVarBool( "FRC_" + challengeKey, true ) )
		return

	//TODO BA: Check registration data for other things and assert when necessary.
	file.registeredFiringRangeChallenges[ challengeKey ] <- data

	#if CLIENT
	file.registeredChallengeWeaponScriptName.append(challengeKey)
	#endif
}

void function EntitiesDidLoad()
{
	#if SERVER
	foreach ( challengeData in file.registeredFiringRangeChallenges )
	{
		PrecacheScriptString( challengeData.gunRackScriptName )
		entity gunRack = CreatePropScript( GUNRACK_MODEL, challengeData.gunRackOrigin, challengeData.gunRackAngles, SOLID_VPHYSICS )
		gunRack.SetScriptName( challengeData.gunRackScriptName )
		gunRack.SetSkin( 1 )

		entity gunRackBase = CreatePropScript( GUNRACK_BASE_MODEL, challengeData.gunRackOrigin + BASE_ORIGIN_OFFSET, challengeData.gunRackAngles + BASE_ANGLE_OFFSET, SOLID_VPHYSICS )
		gunRackBase.SetFadeDistance( 15000 )
		gunRackBase.SetScriptName( challengeData.gunRackScriptName + "_base" )
	}

	array < entity > bordersChallenge1 = GetEntArrayByScriptName( "frc_challenge1_border" )
	foreach( border in bordersChallenge1 )
	{
		file.borderOriginByScriptNameTable[ "frc_challenge1_border" ] <- border.GetOrigin()
		border.Destroy()
	}

	array < entity > bordersChallenge2 = GetEntArrayByScriptName( "frc_challenge2_border" )
	foreach( border in bordersChallenge2 )
	{
		file.borderOriginByScriptNameTable[ "frc_challenge2_border" ] <- border.GetOrigin()
		border.Destroy()
	}

	array < entity > bordersChallenge3 = GetEntArrayByScriptName( "frc_challenge3_border" )
	foreach( border in bordersChallenge3 )
	{
		file.borderOriginByScriptNameTable[ "frc_challenge3_border" ] <- border.GetOrigin()
		border.Destroy()
	}

	array<int> allCommonPlayerRealms = GetAllPlayerCommonRealms()
	foreach( int realm in allCommonPlayerRealms )
	{
		FiringRangeChallengeRealmData data
		file.firingRangeChallengeDataByRealmTable[realm] <- data
		FRC_SetupFiringRangeChallengesForRealm( realm )
	}

	FRC_SetupTriggers()
	#endif
}
#endif // SERVER || CLIENT

#if SERVER
void function FRC_SetupTriggers()
{
	array < entity > challenge1Trigger = GetEntArrayByScriptName( "frc_challenge1_trigger" )
	if ( challenge1Trigger.len() == 1 )
	{
		challenge1Trigger[0].SetEnterCallback( FRC_OnEntEnterChallengeTrigger )
		challenge1Trigger[0].SetLeaveCallback( FRC_OnEntLeaveChallengeTrigger )
	}

	array < entity > challenge2Trigger = GetEntArrayByScriptName( "frc_challenge2_trigger" )
	if ( challenge2Trigger.len() == 1 )
	{
		challenge2Trigger[0].SetEnterCallback( FRC_OnEntEnterChallengeTrigger )
		challenge2Trigger[0].SetLeaveCallback( FRC_OnEntLeaveChallengeTrigger )
	}

	array < entity > challenge3Trigger = GetEntArrayByScriptName( "frc_challenge3_trigger" )
	if ( challenge3Trigger.len() == 1 )
	{
		challenge3Trigger[0].SetEnterCallback( FRC_OnEntEnterChallengeTrigger )
		challenge3Trigger[0].SetLeaveCallback( FRC_OnEntLeaveChallengeTrigger )
	}
}

void function FRC_SetupFiringRangeChallengesForRealm( int realm )
{
	foreach ( challengeData in file.registeredFiringRangeChallenges )
	{
		entity gunRack = GetEntByScriptName( challengeData.gunRackScriptName )
		FRC_CreateChallengePickUpWeapon( realm, gunRack, challengeData.weaponRef, challengeData.weaponMdl, challengeData.challengeKey )
	}
}

void function FRC_SetupFiringRangeBordersForRealm( int realm )
{
	array < entity > bordersChallenge1 = GetEntArrayByScriptName( "frc_challenge1_border" )
	foreach( border in bordersChallenge1 )
		border.Hide()

	array < entity > bordersChallenge2 = GetEntArrayByScriptName( "frc_challenge2_border" )
	foreach( border in bordersChallenge2 )
		border.Hide()

	array < entity > bordersChallenge3 = GetEntArrayByScriptName( "frc_challenge3_border" )
	foreach( border in bordersChallenge3 )
		border.Hide()
}

void function FRC_CreateChallengePickUpWeapon( int realm, entity gunRack, string lootRef, asset mdl, string challengeKey )
{
	vector rackAngles = gunRack.GetAngles()
	vector lootAngles = AnglesCompose( rackAngles, <-85, 180, 0> )
	if ( lootRef.find( "_bow" ) >= 0  ) //if ( lootRef == "mp_weapon_bow_challenge" )
		lootAngles = AnglesCompose( lootAngles, <85, 0, 0> )

	vector lootOrigin = PositionOffsetFromEnt( gunRack, 2, 0, 47 )

	entity gun = CreatePropScript( mdl, lootOrigin, lootAngles, SOLID_VPHYSICS )
	gun.RemoveFromAllRealms()
	gun.AddToRealm( realm )
	gun.SetScriptName( challengeKey )
	gun.SetUsableByGroup( "pilot" )
	gun.AddUsableValue( USABLE_CUSTOM_HINTS )

	AddCallback_OnUseEntity_ClientServer( gun, FRC_ChallengeGunOnUseFunc )
	SetCallback_CanUseEntityCallback( gun, FRC_GenericCanPickUpWeapon )
	PrecacheScriptString( challengeKey )

	FRC_AddCleanupEnt( gun, realm )
	FRC_AddChallengeWeapon( gun, realm )
}

void function FRC_ChallengeGunOnUseFunc( entity gun, entity player, int useInputFlags )
{
	if ( !IsValid( player ) )
		return

	int realm = player.GetRealms()[0]
	FRC_DisableChallengeWeapons ( realm )
	thread FRC_ChallengeGunOnUseThread( gun, player )
}

void function FRC_ChallengeGunOnUseThread(  entity gun, entity player )
{
	EndSignal ( player, "OnDestroy" )

	if ( !IsValid( player ) )
		return

	if ( !IsValid( gun ) )
		return

	string challengeKey = gun.GetScriptName()
	if ( challengeKey == "" )
		return

	gun.UnsetUsable()

	if ( !(challengeKey in file.registeredFiringRangeChallenges) )
		return

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	file.firingRangeChallengeDataByRealmTable[realm].challengeKey = challengeKey
	file.firingRangeChallengeDataByRealmTable[realm].activePlayer = player
	file.firingRangeChallengeDataByRealmTable[realm].team = player.GetTeam()
	file.firingRangeChallengeDataByRealmTable[realm].challengeType = file.registeredFiringRangeChallenges[challengeKey].challengeType

	int target = FRC_GetChallengeStat( player, file.registeredFiringRangeChallenges[challengeKey].statTemplate )
	file.firingRangeChallengeDataByRealmTable[realm].target = target + 1
	file.firingRangeChallengeDataByRealmTable[realm].triggerScriptName = file.registeredFiringRangeChallenges[challengeKey].outOfBoundsTriggerScriptName

	array<entity> teamPlayers = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach ( teamPlayer in teamPlayers )
	{
		if ( !IsValid( teamPlayer ) )
			continue

		ScreenFadeToBlackForever( teamPlayer, 0 )
		Remote_CallFunction_NonReplay( player, "SCB_FiringRange_EnableCharacterChange", false )
	}

	WaitFrame() // Allow screen to go black.

	FRC_SetupPlayersForChallenge( player )

	WaitFrame() // Allow for players to be setup properly.

	FRC_HideFiringRangeTargets( realm )
	Remote_CallFunction_NonReplay( player, "ServerCallback_FRC_SetChallengeKey", gun )
	FRC_CreateBorder( file.registeredFiringRangeChallenges[challengeKey].borderName, file.registeredFiringRangeChallenges[challengeKey].borderType, realm )
	FRC_TeleportSquad ( player, file.registeredFiringRangeChallenges[challengeKey].playerTeleportPosition, file.registeredFiringRangeChallenges[challengeKey].squadSafePosition )
	file.registeredFiringRangeChallenges[challengeKey].challengeSetupFunc( player )
	FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_PENDING )

	foreach ( teamPlayer in teamPlayers )
	{
		if ( !IsValid( teamPlayer ) )
			continue

		ScreenFadeFromBlack ( teamPlayer, 0.3, 0 )
	}

	FRC_GiveInventory( player, file.registeredFiringRangeChallenges[challengeKey].weaponRef, clone file.registeredFiringRangeChallenges[challengeKey].weaponMods)
	PIN_Interact( player, challengeKey)
}

void function FRC_SetupPlayersForChallenge( entity challengePlayer )
{
	if ( !IsValid( challengePlayer ) )
		return

	CancelPlayerStatesData states
	states.cancelZipline = true
	states.cancelGrapple = true
	states.cancelPhaseTunnel = true
	states.cancelPhaseWalk = true
	states.cancelRevive = true
	states.cancelCryptoDrone = true
	states.cancelTotem = true
	states.cancelMainOrAltHandAbility = true
	states.cancelHuntMode = true
	states.cancelBleedOut = true

	array<entity> teamPlayers = GetPlayerArrayOfTeam( challengePlayer.GetTeam() )
	foreach( player in teamPlayers )
	{
		if ( !IsValid( player ) )
			continue

		if ( player.IsThirdPersonShoulderModeOn() )
			player.SetThirdPersonShoulderModeOff()

		// SwapToLastEquippedPrimaryFromAbility( player ) // S3: not available

		CancelPlayerStates( player, states )

		if ( player ==  challengePlayer )
		{
			ResetPlayerInventory ( player )
			// player.DisableWeaponTypes( ACTIVE_CHALLENGE_WEAPON_FLAGS ) // S3: entity method only at runtime
		}
		else
		{
			// player.DisableWeaponTypes ( WPT_ALL_EXCEPT_VIEWHANDS ) // S3: entity method only at runtime
		}

		FiringRange_CleanUpPlayerPermanents( player )
	}
}

void function FRC_TeleportSquad( entity challengePlayer, vector challengePosition, array< vector > playerSquad )
{
	if ( !IsValid( challengePlayer ) )
		return

	int i = 0
	array<entity> teamPlayers = GetPlayerArrayOfTeam( challengePlayer.GetTeam() )
	foreach ( teamPlayer in teamPlayers )
	{
		if ( teamPlayer == challengePlayer )
		{
			teamPlayer.SetOrigin( challengePosition )
			teamPlayer.SetAngles( < 0, 0, 0 > )
		}
		else
		{
			teamPlayer.SetOrigin( playerSquad[i] )
			i++
		}
	}
}

void function FRC_GiveInventory( entity player, string weaponRef, array< string > weaponMods )
{
	if ( !IsValid( player ) )
		return

	SetInfiniteAmmoForGameMode( player, true )

	LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
	entity newActiveWeapon = SpawnGenericLoot( weaponRef, player.GetOrigin(), player.GetAngles(), -1 )
	newActiveWeapon.SetWeaponMods( weaponMods )
	Survival_PickupItem( newActiveWeapon, player )
	newActiveWeapon.Destroy()

	entity weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if ( IsValid( weapon ) && weapon.UsesClipsForAmmo() )
	{
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
	}
}

void function FRC_AddCleanupEnt( entity ent, int realm )
{
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	file.firingRangeChallengeDataByRealmTable[realm].entsToClean.append( ent )
}

void function FRC_AddCleanupEntsForRealm( array<entity> ents, int realm )
{
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	file.firingRangeChallengeDataByRealmTable[realm].entsToClean.extend( ents )
}

void function FRC_AddChallengeWeapon( entity weapon, int realm )
{
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	file.firingRangeChallengeDataByRealmTable[realm].challengeWeapons.append( weapon )
}

void function FRC_DisableChallengeWeapons( int realm )
{
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	foreach ( weapon in file.firingRangeChallengeDataByRealmTable[realm].challengeWeapons )
	{
		if ( IsValid( weapon ) )
			weapon.UnsetUsable()
	}
}

void function FRC_CleanUpEntsForRealm ( int realm )
{
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	foreach( entity ent in file.firingRangeChallengeDataByRealmTable[realm].entsToClean )
	{
		if ( IsValid( ent ) )
			ent.Destroy()
	}

	file.firingRangeChallengeDataByRealmTable[realm].entsToClean.clear()
	file.firingRangeChallengeDataByRealmTable[realm].challengeWeapons.clear()
}

void function FRC_OnPlayerDisconnected( entity player )
{
	if ( !IsValid( player ) )
		return

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( IsValid( file.firingRangeChallengeDataByRealmTable[realm].activePlayer ) && file.firingRangeChallengeDataByRealmTable[realm].activePlayer == player )
	{
		FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	}
}

void function FRC_OnPlayerKilled( entity player, entity attacker, var damageInfo )
{
	if ( !IsValid( player ) )
		return

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( IsValid( file.firingRangeChallengeDataByRealmTable[realm].activePlayer ) && file.firingRangeChallengeDataByRealmTable[realm].activePlayer == player )
	{
		FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	}
}

void function FRC_OnPlayerDowned( entity victim, entity attacker, var attackerDamageInfo )
{
	if ( !IsValid( victim ) )
		return

	int realm = victim.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( IsValid( file.firingRangeChallengeDataByRealmTable[realm].activePlayer ) && file.firingRangeChallengeDataByRealmTable[realm].activePlayer == victim )
	{
		FRC_UpdateState( victim, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	}
}

void function FRC_OnPlayerSpawned( entity player )
{
	if ( !IsValid( player ) )
		return

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( IsValid( file.firingRangeChallengeDataByRealmTable[realm].activePlayer ) && file.firingRangeChallengeDataByRealmTable[realm].activePlayer == player )
	{
		FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	}
}

void function FRC_OnPlayerWeaponSwitched( entity player, entity activateWeapon, entity previousWeapon )
{
	if ( !IsValid (player) )
		return

	int realm = player.GetRealms()[0]
	if ( !( realm in file.firingRangeChallengeDataByRealmTable ) )
		return

	if ( IsValid( file.firingRangeChallengeDataByRealmTable[realm].activePlayer ) && ( file.firingRangeChallengeDataByRealmTable[realm].activePlayer == player ) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState == eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
	{
		FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	}
}

void function FRC_OnLootSpawn( entity ent, LootData data, int count )
{
	WaitFrame()

	if ( !IsValid( ent ) )
		return

	if ( ent.e.spawnSource != eSpawnSource.PLAYER_DROP )
		return

	entity owner = ent.GetOwner()
	if ( !IsValid (owner) )
		return

	int realm = owner.GetRealms()[0]
	if ( !( realm in file.firingRangeChallengeDataByRealmTable ) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	{
		// if the challenge is active, this should never really be invalid - but better to check.
		if ( !IsValid(file.firingRangeChallengeDataByRealmTable[realm].activePlayer) )
			return

		if ( file.firingRangeChallengeDataByRealmTable[realm].activePlayer != owner )
			return

		FRC_UpdateState( owner, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
	}
}

void function FRC_ResetChallengeState( int realm )
{
	if ( !( realm in file.firingRangeChallengeDataByRealmTable ) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState == eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
		return

	string challengeKey = file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey
	if ( challengeKey != "" && challengeKey in file.registeredFiringRangeChallenges )
	{
		file.registeredFiringRangeChallenges[challengeKey].challengeCleanUpFunc( realm )
	}
	else
	{
		// TODO BA: Log this. Shouldn't happen.
	}

	FRC_CleanUpEntsForRealm( realm )

	file.firingRangeChallengeDataByRealmTable[realm].score = 0
	file.firingRangeChallengeDataByRealmTable[realm].challengeKey = ""
	file.firingRangeChallengeDataByRealmTable[realm].challengeState = eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE
	file.firingRangeChallengeDataByRealmTable[realm].target = 0
	file.firingRangeChallengeDataByRealmTable[realm].wasOutOfBounds = false
	file.firingRangeChallengeDataByRealmTable[realm].leaveTime = FLT_MAX
	file.firingRangeChallengeDataByRealmTable[realm].enterTime = 0
	file.firingRangeChallengeDataByRealmTable[realm].timeSpentOutOfBounds = 0
	file.firingRangeChallengeDataByRealmTable[realm].triggerScriptName = ""
	file.firingRangeChallengeDataByRealmTable[realm].shotsFired = 0
	file.firingRangeChallengeDataByRealmTable[realm].shotsHit = 0
	file.firingRangeChallengeDataByRealmTable[realm].damage = 0
	file.firingRangeChallengeDataByRealmTable[realm].critShotsHit = 0

	int team = file.firingRangeChallengeDataByRealmTable[realm].team
	entity activePlayer = file.firingRangeChallengeDataByRealmTable[realm].activePlayer

	array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( teamPlayer in teamPlayers )
	{
		if ( !IsValid( teamPlayer ) )
			continue

		if ( !IsValid (activePlayer) || teamPlayer != activePlayer )
			{} // teamPlayer.EnableWeaponTypes( WPT_ALL_EXCEPT_VIEWHANDS ) // S3: entity method not available at compile time

		ScreenFadeToBlackForever( teamPlayer, 0.2 )
	}

	wait 1.0

	if ( IsValid (activePlayer) )
	{

		if ( !IsInfiniteReloadsEnabled( activePlayer ) )

		//SetInfiniteAmmoForGameMode( activePlayer, false )

		// Restore Friendly Fire State.
		FRSetting_InfiniteReloads_Restore_From_NetVar( activePlayer )

		ResetPlayerInventory( activePlayer )
		// activePlayer.EnableWeaponTypes( ACTIVE_CHALLENGE_WEAPON_FLAGS ) // S3: entity method not available at compile time
		activePlayer.SetOrigin( file.registeredFiringRangeChallenges[challengeKey].playerTeleportPosition )
		Remote_CallFunction_NonReplay( activePlayer, "SCB_FiringRange_EnableCharacterChange", true )
		activePlayer.Signal("CleanupPlayerPermanents")
		activePlayer.SetPlayerNetInt( FRC_SCORE_NETWORK_VAR, 0)
	}

	FRC_SetupFiringRangeChallengesForRealm ( realm )


		if( IsUsingConsolidatedLoot() )
		{
			ConsolidatedLoot_Create_FiringRange_WeaponsAndLoot_ForRealm( realm )
		}
		else
		{
			Create_FiringRange_WeaponsAndLoot_ForRealm( realm )
		}




 	int i = 0
	foreach ( teamPlayer in teamPlayers )
	{
		if ( !IsValid( teamPlayer ) )
			continue

		// teleport players.
		ScreenFadeFromBlack ( teamPlayer, 0.3, 0 )

		if ( !IsValid (activePlayer) || teamPlayer != activePlayer )
		{
			teamPlayer.SetOrigin( file.registeredFiringRangeChallenges[challengeKey].squadSafePosition[i] )
			Remote_CallFunction_NonReplay( teamPlayer, "SCB_FiringRange_EnableCharacterChange", true )
			++i
		}
	}

	file.firingRangeChallengeDataByRealmTable[realm].activePlayer = null
	file.firingRangeChallengeDataByRealmTable[realm].team = TEAM_INVALID
}

void function FRC_CreateBorder( string borderName, int borderType, int realm )
{
	if ( borderName == "" )
		return

	if ( !(borderName in file.borderOriginByScriptNameTable) )
		return

	vector origin = file.borderOriginByScriptNameTable[borderName]

	if ( borderType == 0 )
	{
		entity border = CreatePropScript( FRC_BORDER01_MDL, origin, <0,90,0> ,SOLID_NONE )
		border.RemoveFromAllRealms()
		border.AddToRealm( realm )
		FRC_AddCleanupEnt( border, realm )
	}
	else
	{
		entity border = CreatePropScript( FRC_BORDER02_MDL, origin, <0,90,0> ,SOLID_NONE )
		border.RemoveFromAllRealms()
		border.AddToRealm( realm )
		FRC_AddCleanupEnt( border, realm )
	}
}

void function FRC_HideFiringRangeTargets( int realm )
{
	FRC_CleanUpEntsForRealm( realm )
	FR_ResidentDummies_DestroyInRealm ( realm, true )
	RemoveStagingAreaEntsForRealm ( realm )
}

bool function FRC_SetStat( entity player )
{
	if ( !IsValid ( player ) )
		return false

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return false

	string challengeKey = file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey

	if ( !(challengeKey in file.registeredFiringRangeChallenges) )
		return false

	StatsHook_S12E04_UpdateChallengeStat( player, file.registeredFiringRangeChallenges[challengeKey].statTemplate, file.firingRangeChallengeDataByRealmTable[ realm ].score )
	PIN_FiringRangeChallengeCompleted( player, challengeKey, file.firingRangeChallengeDataByRealmTable[ realm ].score )

	if ( file.firingRangeChallengeDataByRealmTable[ realm ].score >= file.firingRangeChallengeDataByRealmTable[ realm ].target )
	{

		if ( file.registeredFiringRangeChallenges[challengeKey].challengePostFunc != null )
			file.registeredFiringRangeChallenges[challengeKey].challengePostFunc( player, true )

		EmitSoundToTeamPlayers( "S12E04_bangalore_StoryEvent_Challenge_success", player.GetTeam() )
		return true
	}
	else
	{
		if ( file.registeredFiringRangeChallenges[challengeKey].challengePostFunc != null )
			file.registeredFiringRangeChallenges[challengeKey].challengePostFunc( player, false )

		EmitSoundToTeamPlayers( "S12E04_bangalore_StoryEvent_Challenge_fail", player.GetTeam() )
		return false
	}

	unreachable
}

void function FRC_TryReward( entity player )
{
	if ( !IsValid ( player ) )
		return

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	string challengeKey = file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey
	ItemFlavor rewardBadge = GetItemFlavorByAsset( file.registeredFiringRangeChallenges[challengeKey].rewardTracker )

	GrantRewardsConfig grc
	if ( !GRX_HasItem( player, ItemFlavor_GetGRXIndex( rewardBadge ) ) )
	{
		grc.what = MakeItemFlavorBag( { [rewardBadge] = 1 } )
		grc.allowAlreadyOwned = true
		grc.showCeremony = true
		int result = GRX_GrantRewards( player, grc )
		Assert( result == eGrantRewardsResult.DONE )
	}
}

void function FRC_ClientToServer_TryLeaveChallenge( entity player  )
{
	if( !IsValid( player ) )
		return

	if( !player.IsPlayer() )
		return

	if( player.IsObserver())
		return

	int realm = player.GetRealms()[0]
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	string challengeKey = file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey
	if ( file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey == "" )
		return

	if ( !(challengeKey in file.registeredFiringRangeChallenges) )
		return

	thread FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE  )
}

void function FRC_UpdateState( entity player, int state )
{
	if ( !IsValid (player) )
		return

	int realm = player.GetRealms()[0]
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	string challengeKey = file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey
	if ( file.firingRangeChallengeDataByRealmTable[ realm ].challengeKey == "" )
		return

	if ( !(challengeKey in file.registeredFiringRangeChallenges) )
		return

	switch ( state )
	{
		case eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE:
			thread FRC_ResetChallengeState( realm )
			Signal( player, "FRChallengeEnded" )
			break
		case eFiringRangeChallengeState.FR_CHALLENGE_PENDING:
			break
		case eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE:
			file.registeredFiringRangeChallenges[challengeKey].challengeStartFunc( player )
			FRC_ManualOOBTrigger( player, realm )
			EmitSoundToTeamPlayers( "S12E04_bangalore_StoryEvent_Challenge_start", player.GetTeam() )
			break
		case eFiringRangeChallengeState.FR_CHALLENGE_POST:
			thread FRC_PostChallengeThread( player )
			break
	}

	file.firingRangeChallengeDataByRealmTable[realm].challengeState = state
	if ( IsValid ( player ) )
		Remote_CallFunction_NonReplay( player, "ServerCallback_FRC_UpdateState", state )

	//Ugly check to make sure people are in bounds at the start
	if ( state == eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
		FRC_ManualOOBTrigger( player, realm )
}

void function FRC_ManualOOBTrigger( entity player, int realm )
{
	if ( !IsValid( player ) )
		return

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	string triggerScriptName = file.firingRangeChallengeDataByRealmTable[realm].triggerScriptName
	array <entity> triggers = GetEntArrayByScriptName( triggerScriptName )
	foreach( trigger in triggers )
	{
		if ( !trigger.IsTouching( player ) )
			thread FRC_OnEntLeaveChallengeTrigger( trigger, player )
	}
}

void function FRC_PostChallengeThread( entity player )
{
	bool success = FRC_SetStat( player )
	FRC_TryReward( player )

	int realm = player.GetRealms()[0]
	if ( realm in file.firingRangeChallengeDataByRealmTable )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FRC_PostGameStats",
			file.firingRangeChallengeDataByRealmTable[realm].shotsFired,
			file.firingRangeChallengeDataByRealmTable[realm].damage,
			file.firingRangeChallengeDataByRealmTable[realm].shotsHit,
			file.firingRangeChallengeDataByRealmTable[realm].critShotsHit
		)
	}

	if ( IsValid( player ) )
		EndSignal( player, "FRChallengeEnded" )

	wait POST_CHALLENGE_WAIT_TIME

	//Thread this out, otherwise state change will end early because of end signal being sent when state changes to in active.
	thread FRC_UpdateState ( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
}

void function FRC_UpdateScore( entity player, int damage, int hitGroup )
{
	if ( !IsValid ( player ) )
		return

	int realm = player.GetRealms()[0]
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeType == eFiringRangeChallengeType.FR_CHALLENGE_TYPE_TARGETS_HIT )
	{
		file.firingRangeChallengeDataByRealmTable[realm].score += 1
	}
	else if ( file.firingRangeChallengeDataByRealmTable[realm].challengeType == eFiringRangeChallengeType.FR_CHALLENGE_TYPE_BEST_DAMAGE )
	{
		file.firingRangeChallengeDataByRealmTable[realm].score += damage
	}

	file.firingRangeChallengeDataByRealmTable[realm].shotsHit++
	file.firingRangeChallengeDataByRealmTable[realm].damage += damage

	if ( hitGroup == HIT_GROUP_HEADSHOT )
	{
		file.firingRangeChallengeDataByRealmTable[realm].critShotsHit++
	}

	player.SetPlayerNetInt( FRC_SCORE_NETWORK_VAR, file.firingRangeChallengeDataByRealmTable[realm].score )
}

bool function FRC_IsChallengeActive( int realm )
{
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return false

	return (file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE)
}

bool function FRC_IsPlayerActiveForChallenge ( entity player )
{
	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return false

	return file.firingRangeChallengeDataByRealmTable[realm].activePlayer == player
}

#if DEVELOPER
void function DEV_FiringRange_HideTargets()
{
	FRC_HideFiringRangeTargets( gp()[0].GetRealms()[0] )
}
#endif // DEVELOPER

#endif // SERVER

#if CLIENT
void function ServerCallback_FRC_UpdateState( int state )
{
	switch ( state )
	{
		case eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE:
			entity player = GetLocalViewPlayer()
			Signal( player, "FRChallengeEnded" )
			file.score = 0
			EnableEmoteProjector ( true )
			SCB_ShowDynStats_ByPVar()
			SCB_ShowDynTimer_ByPVar()
			RunUIScript( "SetFiringRangeChallengeInProgress", false )
			break
		case eFiringRangeChallengeState.FR_CHALLENGE_PENDING:
			thread FRC_CreatePendingChallengeUI()
			EnableEmoteProjector ( false )
			FR_DynStats_Hide_RUI()
			FR_DynTimer_Hide_RUI()
			RunUIScript( "SetFiringRangeChallengeInProgress", true )
			break
		case eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE:
			thread FRC_StartChallengeTimer()
			RunUIScript( "SetFiringRangeChallengeInProgress", true )
			break
		case eFiringRangeChallengeState.FR_CHALLENGE_POST:
			// Tell UI to show end of challenge stats.
			// Populate RUI here
			RunUIScript( "SetFiringRangeChallengeInProgress", false )
			break
	}

	file.challengeState = state
}

int function FRC_GetState()
{
	return file.challengeState
}

void function ServerCallback_FRC_SetChallengeKey( entity gun )
{
	string challengeKey = gun.GetScriptName()
	file.challengeKey = challengeKey
}

void function ServerCallback_FRC_UpdateOutofBounds( bool outOfBounds, float timer )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid ( player ) )
		return

	if ( !outOfBounds )
		Signal( player, "FRC_BackInBounds" )
	else
	{
		thread function() : ( outOfBounds, timer, player )
		{
			EndSignal( player, "OnDestroy" )
			EndSignal( player, "FRChallengeEnded")
			EndSignal( player, "FRC_BackInBounds" )

			OnThreadEnd(
				function() : ()
				{
					if ( file.challengeRui != null )
						RuiSetFloat( file.challengeRui, "oOBTimer", -1 )
				}
			)

			if ( file.challengeRui != null )
				RuiSetFloat( file.challengeRui, "oOBTimer", timer )

			wait timer
		}()
	}
}

void function ServerCallback_FRC_PostGameStats( int shotsFired, int damageDone, int shotsHit, int critShotsHit )
{
	if ( file.challengeRui == null )
		return

	float accuracy = ( shotsFired > 0 )? float (shotsHit) / float(shotsFired) * 100.0: 0.0
	RuiSetInt( file.challengeRui, "totalStatRows", 4)//needs to be the same as below

	var nestedRui = RuiCreateNested( file.challengeRui, "stat" + 0 + "NestedHandle", $"ui/fr_challenge_stat_float.rpak" )
	RuiSetString( nestedRui, "label", Localize("#FR_CHALLENGE_PG_STAT_1") )
	RuiSetFloat( nestedRui, "value", accuracy )

	nestedRui = RuiCreateNested( file.challengeRui, "stat" + 1 + "NestedHandle", $"ui/fr_challenge_stat_int.rpak" )
	RuiSetString( nestedRui, "label", Localize("#FR_CHALLENGE_PG_STAT_4") )
	RuiSetInt( nestedRui, "value", shotsHit )

	nestedRui = RuiCreateNested( file.challengeRui, "stat" + 2 + "NestedHandle", $"ui/fr_challenge_stat_int.rpak" )
	RuiSetString( nestedRui, "label", Localize("#FR_CHALLENGE_PG_STAT_3") )
	RuiSetInt( nestedRui, "value", damageDone )

	nestedRui = RuiCreateNested( file.challengeRui, "stat" + 3 + "NestedHandle", $"ui/fr_challenge_stat_int.rpak" )
	RuiSetString( nestedRui, "label", Localize("#FR_CHALLENGE_PG_STAT_2") )
	RuiSetInt( nestedRui, "value", critShotsHit )
}

void function FRC_CreatePendingChallengeUI()
{
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded")

	var rui = CreateFullscreenRui( $"ui/tutorial_hint_line.rpak" )
	RuiSetString( rui, "buttonText", "" )
	RuiSetString( rui, "gamepadButtonText", "")
	RuiSetString( rui, "hintText", "#CHALLENGE_START_HINT" )
	RuiSetInt( rui, "hintOffset", 0 )
	RuiSetBool( rui, "hideWithMenus", true )

	if ( file.challengeKey in file.registeredFiringRangeChallenges )
	{
		RuiSetString( rui, "hintText", file.registeredFiringRangeChallenges[file.challengeKey].challengeStartHint )

		int currentBest = FRC_GetChallengeStat( player, file.registeredFiringRangeChallenges[file.challengeKey].statTemplate )
		if ( currentBest > 0 )
		{
			string hint = ""
			switch ( file.registeredFiringRangeChallenges[file.challengeKey].challengeType )
			{
				case eFiringRangeChallengeType.FR_CHALLENGE_TYPE_BEST_DAMAGE:
					hint = format( Localize("#FR_CHALLENGE_DMG_GOAL_HINT"), string(currentBest) )
					break
				case eFiringRangeChallengeType.FR_CHALLENGE_TYPE_TARGETS_HIT:
					hint = format( Localize("#FR_CHALLENGE_TARGET_GOAL_HINT"), string(currentBest) )
					break
				default:
					break
			}
			RuiSetString( rui, "subText", hint )
		}
	}
	else
	{
		RuiSetString( rui, "hintText", "#FR_CHALLENGE_TARGET_HINT" )
	}

	OnThreadEnd(
		function() : ( rui )
		{
			if ( IsValid( rui ) )
				RuiDestroyIfAlive( rui )
		}
	)

	WaitSignal( player, "FRChallengeStarted")

	RuiSetBool( rui, "hintCompleted", true )

	wait 1.0
}

void function FRC_StartChallengeTimer()
{
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDestroy" )
	Signal( player, "FRChallengeStarted" )
	file.challengeRui    = CreateCockpitPostFXRui( $"ui/fr_challenge_timer.rpak", 0 )

	if ( !(file.challengeKey in file.registeredFiringRangeChallenges) )
		return

	float challengeTime = file.registeredFiringRangeChallenges[file.challengeKey].challengeTime

	switch ( file.registeredFiringRangeChallenges[file.challengeKey].challengeType )
	{
		case eFiringRangeChallengeType.FR_CHALLENGE_TYPE_BEST_DAMAGE:
			RuiSetString( file.challengeRui,  "challengeScoreText", "#CHALLENGE_TARGETS_DAMAGE" )
			break
		case eFiringRangeChallengeType.FR_CHALLENGE_TYPE_TARGETS_HIT:
			RuiSetString( file.challengeRui,  "challengeScoreText", "#CHALLENGE_TARGETS_HIT" )
			break
		case eFiringRangeChallengeType.FR_CHALLENGE_TYPE_BEST_TIME:
		default:
			RuiSetString( file.challengeRui,  "challengeScoreText", "" )
			break
	}

	int currentBest = FRC_GetChallengeStat( player, file.registeredFiringRangeChallenges[file.challengeKey].statTemplate )

	if ( file.registeredFiringRangeChallenges[file.challengeKey].challengeName != "" )
	{
		RuiSetString( file.challengeRui, "altIconText", file.registeredFiringRangeChallenges[file.challengeKey].challengeName )
		RuiSetString( file.challengeRui, "challengeTitle", file.registeredFiringRangeChallenges[file.challengeKey].challengeName )
	}

	RuiSetGameTime( file.challengeRui, "countdownGoalTime", Time() + challengeTime )
	RuiSetFloat( file.challengeRui, "timeOutTime", POST_CHALLENGE_WAIT_TIME )
	RuiSetInt( file.challengeRui, "target", currentBest )

	OnThreadEnd(
		function() : ()
		{
			RuiDestroyIfAlive( file.challengeRui )
			file.challengeRui = null
		}
	)

	WaitSignal( player, "FRChallengeEnded")
}

void function FiringRangeChallengeScoreUpdated( entity player, int newVal )
{
	file.score = newVal

	if ( file.challengeRui != null )
		RuiSetInt( file.challengeRui, "challengeProgress", file.score )
}

void function OnFirstDrawCinematicFlagChanged( entity player )
{
	int ceFlags = player.GetCinematicEventFlags()
	if ( IsBitFlagSet( ceFlags, CE_FLAG_HIDE_MAIN_HUD_INSTANT ) )
	{
		Crosshair_SetState( CROSSHAIR_STATE_HIDE_ALL )
		ServerCallback_SetCommsDialogueEnabled( 0 )
	}
	else
	{
		Crosshair_SetState( CROSSHAIR_STATE_SHOW_ALL )
		ServerCallback_SetCommsDialogueEnabled( 1 )
	}
}

void function FRChallenge_GunCreated( entity ent )
{
	if ( file.registeredChallengeWeaponScriptName.find( ent.GetScriptName() ) != -1 )
	{
		AddEntityCallback_GetUseEntOverrideText( ent, FRC_ChallengeGunTextOverride )
	}
}

string function FRC_ChallengeGunTextOverride( entity gun )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid(player) )
		return ""

	string challengeKey = gun.GetScriptName()
	if ( !(challengeKey in file.registeredFiringRangeChallenges) )
		return ""

	if ( !( FRC_CanCharacterPickup( player, gun ) ) )
		return "#FRC_CHALLENGE_CHAR_DISABLED_INTR"

	return file.registeredFiringRangeChallenges[challengeKey].challengeInteractStr
}
#endif

#if SERVER
void function FRC_OnEntEnterChallengeTrigger( entity trigger, entity ent )
{
	if ( !IsValid(ent) || !ent.IsPlayer() )
		return

	int realm = ent.GetRealms()[0]
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
		return

	if ( ent != file.firingRangeChallengeDataByRealmTable[realm].activePlayer )
		return

	if ( trigger.GetScriptName() != file.firingRangeChallengeDataByRealmTable[realm].triggerScriptName )
		return

	FRC_UpdatePlayerChallengeTriggerStatus( trigger, ent, false )
}

void function FRC_OnEntLeaveChallengeTrigger( entity trigger, entity ent )
{
	if ( !IsValid(ent) || !ent.IsPlayer() )
		return

	int realm = ent.GetRealms()[0]
	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
		return

	if ( ent != file.firingRangeChallengeDataByRealmTable[realm].activePlayer )
		return

	if ( trigger.GetScriptName() != file.firingRangeChallengeDataByRealmTable[realm].triggerScriptName )
		return

	FRC_UpdatePlayerChallengeTriggerStatus( trigger, ent, true )
}


void function FRC_UpdatePlayerChallengeTriggerStatus(entity trigger, entity ent, bool outOfBounds )
{
	int realm = ent.GetRealms()[0]
	bool wasOutOfBounds = file.firingRangeChallengeDataByRealmTable[realm].wasOutOfBounds

	if ( outOfBounds && !wasOutOfBounds ) // We've started being out of bounds
	{
		float timeSpentOutOfBounds = file.firingRangeChallengeDataByRealmTable[realm].timeSpentOutOfBounds
		float leaveTime = file.firingRangeChallengeDataByRealmTable[realm].leaveTime

		float timeSinceOutOfBounds = Time() - leaveTime
		if ( timeSinceOutOfBounds > 30.0 && timeSpentOutOfBounds < 2.0 )
			timeSpentOutOfBounds = 2.0

		float deadTime = 4.0 - timeSpentOutOfBounds

		file.firingRangeChallengeDataByRealmTable[realm].enterTime = Time()

		thread FRC_CancelChallengeOutOfBoundsThread( ent, Time() + deadTime )
	}
	else if ( !outOfBounds && wasOutOfBounds ) // we've stopped being out of bounds
	{
		ent.Signal( "FRC_BackInBounds" )

		file.firingRangeChallengeDataByRealmTable[realm].timeSpentOutOfBounds += Time() - file.firingRangeChallengeDataByRealmTable[realm].enterTime
		file.firingRangeChallengeDataByRealmTable[realm].leaveTime = Time()
	}

	file.firingRangeChallengeDataByRealmTable[realm].wasOutOfBounds = outOfBounds
}

void function FRC_CancelChallengeOutOfBoundsThread( entity player, float cancelTime )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRC_BackInBounds" )
	EndSignal( player, "FRChallengeEnded" )

	Remote_CallFunction_NonReplay( player, "ServerCallback_FRC_UpdateOutofBounds", true, (cancelTime - Time()) )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				Remote_CallFunction_NonReplay( player, "ServerCallback_FRC_UpdateOutofBounds", false, 0 )
		}
	)

	wait cancelTime - Time()

	if ( !(player.GetRealms()[0] in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[player.GetRealms()[0]].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
		return

	thread FRC_UpdateState( player, eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE )
}

void function FRC_OnWeaponFired( entity player, entity weapon, string weaponName, int ammoUsed, vector attackOrigin, vector attackDir )
{
	if ( !IsValid( player ) )
		return

	int realm = player.GetRealms()[0]

	if ( !(realm in file.firingRangeChallengeDataByRealmTable) )
		return

	if ( file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
		return

	//special case for shattered rounds.
	if ( weaponName == "mp_weapon_bow" && weapon.GetScriptInt0() == eShatterRoundsTypes.SHATTER_TRI )
	{
		file.firingRangeChallengeDataByRealmTable[realm].shotsFired+=7
	}

	// Increment shots fired stat.
	file.firingRangeChallengeDataByRealmTable[realm].shotsFired++
}
#endif

#if SERVER || CLIENT
int function FRC_GetChallengeStat( entity player, StatTemplate template )
{
	if ( !IsValid ( player ) )
		return 0

	return GetStat_Int( player, ResolveStatEntry( template ) )
}
#endif

#if SERVER || CLIENT
bool function FRC_CanPickUpWeaponPlayerStatusCheck ( entity player )
{
	if ( player.Anim_IsActive() )
		return false
	if ( player.ContextAction_IsBusy() )
		return false
	if ( player.ContextAction_IsActive() )
		return false
	if ( !player.IsOnGround() )
		return false
	if ( player.IsCrouched() )
		return false
	if ( player.IsSliding() )
		return false
	if ( player.IsTraversing() )
		return false
	if ( player.IsMantling() )
		return false
	if ( player.IsWallRunning() )
		return false
	if ( player.IsWallHanging() )
		return false
	if ( player.IsPhaseShifted() )
		return false
	// if ( player.Player_IsSkywardFollowing() ) // S3: entity method not available at compile time
	// 	return false
	// if ( player.Player_IsSkywardLaunching() ) // S3: entity method not available at compile time
	// 	return false
	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return false
	if ( player.GetParent() != null )
		return false
	if ( player.GetPlayerNetBool( "isHealing" ) )
		return false
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
		return false
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.altHand ) )
		return false
	if ( !IsAlive( player ) )
		return false
	if( Bleedout_IsBleedingOut( player ) )
		return false

	return true
}

bool function FRC_GenericCanPickUpWeapon( entity player, entity weapon, int useFlags )
{
	if ( !IsValid ( player ) )
		return false

	if ( !IsValid ( weapon ) )
		return false

	if ( !FRC_CanPickUpWeaponPlayerStatusCheck( player ) )
		return false

	int realm = player.GetRealms()[0]
	if ( (realm in file.firingRangeChallengeDataByRealmTable) && (file.firingRangeChallengeDataByRealmTable[realm].challengeState != eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE) )
		return false

	if ( !FRC_CanCharacterPickup( player, weapon ) )
		return false

	return true
}

bool function FRC_CanPickUpWeapon( entity player, entity weapon, int useFlags )
{
	if ( !IsValid ( player ) )
		return false

	if ( !FRC_CanPickUpWeaponPlayerStatusCheck( player ) )
		return false

	return true
}

bool function FRC_CanCharacterPickup( entity player, entity weapon )
{
	if ( !IsValid ( player ) )
		return false

	if ( !IsValid ( weapon ) )
		return false

	string weaponScriptName = weapon.GetScriptName()
	string disabledCharsOverride = GetCurrentPlaylistVarString( "FRC_" + weaponScriptName + "_disabled_chars", "" )
	if ( disabledCharsOverride ==  "" )
		return true

	array<string> disabledChars = []
	disabledChars.extend( split( disabledCharsOverride, WHITESPACE_CHARACTERS ) )
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetCharacterRef( character ).tolower()

	if ( disabledChars.contains( characterRef ) )
		return false

	return true
}
#endif

