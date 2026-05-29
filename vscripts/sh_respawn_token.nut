global function GetPlaylistVar_RespawnTokenEnabled

#if SERVER || CLIENT
global function Sh_Respawn_Token_Init
global function Sh_Respawn_Token_IsPlayerRespawnDisabled
#endif

#if SERVER
global function Respawn_Token_CanPlayerRespawn
global function Respawn_Token_IsPlayerEliminated
#endif

#if UI || CLIENT
global function Respawn_Token_CanLocalPlayerRespawn
global function Respawn_Token_CanLocalPlayerRespawnOrIsRespawning
global function Respawn_Token_SetCanLocalPlayerRespawn
#endif

#if CLIENT
global function Respawn_Token_Announcement_RespawnsDisabled
global function Respawn_Token_OnReconnect_UpdateRUI
#endif

#if DEVELOPER && SERVER
global function DEV_Respawn_Token_GiveSquadLife
global function DEV_Respawn_Token_ToggleInfiniteLives
#endif

#if SERVER || CLIENT
const string NETFUNC_ANNOUNCEMENT_RESPAWNS_DISABLED = "Respawn_Token_Announcement_RespawnsDisabled"
const string NETFUNC_ON_RECONNECT_UPDATE_RUI = "Respawn_Token_OnReconnect_UpdateRUI"

const string NETVAR_SQUAD_LIVES = "Squad_Lives"
const string NETVAR_RESPAWN_DISABLED = "Squad_Respawn_Disabled"

const float TIME_ANNOUNCEMENT_RESPAWN_DISABLED = 7.0
const float TIME_ANNOUNCEMENT_SQUAD_LIVES_REMAINING = 7.0

const int PRIORITY_ANNOUNCEMENT_SQUAD_LIVES_REMAINING = 1000
#endif

#if SERVER
const float TIME_DEATH_PING_WAIT = 60.0
#endif

#if CLIENT
const asset RUI_RESPAWN_INFO = $"ui/gamestate_info_survival_solos.rpak"
const asset RUI_RESPAWN_HUD = $"ui/survival_solos_respawn_token.rpak"

const string RUIVAR_RESPAWN_DISABLED = "respawnsDisabled"

const string SFX_SQUAD_LIVES_REMAINING_TWO = "UI_3Strikes_Widget_Stinger_Strike1"
const string SFX_SQUAD_LIVES_REMAINING_ONE = "UI_3Strikes_Widget_Stinger_Strike1"
const string SFX_SQUAD_LIVES_REMAINING_ZERO = "UI_3Strikes_Widget_Stinger_Strike1"
const string SFX_RESPAWN_DISABLED = "UI_3Strikes_RespawningDisabled"
#endif

global enum eRespawnTokenType
{
	INVALID = -1,
	INDIVIDUAL,  // Each player on a team has their own tokens
	SQUAD,       // Teams earn and use tokens together, 1 token per team respawn
	BANK,        // Teams earn and use tokens together, 1 token per player respawn
	_COUNT
}

struct
{
#if DEVELOPER && SERVER
	bool infiniteLives = false
#endif

#if CLIENT || UI
	int squadLives = 0
	int squadLivesViewPlayer = 0
	int lastSquadLifeAnnouncement = -1
	bool canRespawn = false
	bool isRespawning = false
#endif

#if CLIENT
	var nestedRespawnTokenRui
	bool squadEliminated = false
#endif
} file


#if SERVER || CLIENT
void function Sh_Respawn_Token_Init()
{
	if ( !GetPlaylistVar_RespawnTokenEnabled() )
		return

	Sh_Respawn_Token_RegisterNetworking()

#if SERVER
	AddCallback_OnClientConnected( Respawn_Token_OnClientConnected )
	AddCallback_OnPlayerKilled( Respawn_Token_OnPlayerKilled )
	AddCallback_OnPlayerKilled( StoreAllChargeForPlayer )
	AddCallback_OnDeathBoxSpawned( GamemodeUtility_DestroyDeathboxOnDelay )
	AddCallback_OnPlayerRespawned( RestoreChargesForPlayer )
	AddCallback_OnClientDisconnected( Respawn_Token_OnPlayerDisconnect )
	AddCallback_OnClientConnectionRestored( Respawn_Token_OnPlayerReconnect )
	SURVIVAL_AddCallback_OnDeathFieldStopShrink( Respawn_Token_OnDeathFieldStopShrink )

	SpawnGroupSkydive_SetCallback_GetSquadSpawnDelay( Respawn_Token_RespawnCooldown )
	SpawnGroupSkydive_SetCallback_CanRespawnPlayerOrSquad( bool function( entity player ) : () { return !Respawn_Token_IsPlayerEliminated( player ) } )
	SpawnGroupSkydive_SetCallback_GetSquadPlayersToRespawn( Respawn_Token_GetSquadPlayersToRespawn )
#endif // SERVER

#if CLIENT
	RegisterNetVarIntChangeCallback( NETVAR_SQUAD_LIVES, Respawn_Token_SquadLivesChanged )

	Announcements_SetOnSetupAnnouncement_RemainingRespawns( Respawn_Token_OnSetupAnnouncement_RemainingRespawns )
	AddCallback_PlayerFreefallActiveChanged( Respawn_Token_PlayerFreefallActiveChanged )
	DeathScreen_SetIsPlayerWaitingForRespawnFunc( Respawn_Token_IsPlayerWaitingForRespawn )

	Respawn_Token_OverrideGameState()
#endif // CLIENT

	Assert( GetPlaylistVar_RespawnTokenType() != eRespawnTokenType.INVALID, "Playlist variable \"respawn_token_type\" must be set when using Respawn Tokens with \"respawn_token_enabled\"!" )
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
void function Sh_Respawn_Token_RegisterNetworking()
{
	RegisterNetworkedVariable( NETVAR_SQUAD_LIVES, SNDC_PLAYER_EXCLUSIVE, SNVT_INT, 0.0 )
	RegisterNetworkedVariable( NETVAR_RESPAWN_DISABLED, SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, false )

	Remote_RegisterClientFunction( NETFUNC_ANNOUNCEMENT_RESPAWNS_DISABLED )
	Remote_RegisterClientFunction( NETFUNC_ON_RECONNECT_UPDATE_RUI )
}
#endif // SERVER || CLIENT

#if CLIENT
void function Respawn_Token_OverrideGameState()
{
	ClGameState_RegisterGameStateAsset( RUI_RESPAWN_INFO )
}
#endif // CLIENT

#if SERVER || CLIENT
bool function Sh_Respawn_Token_IsPlayerRespawnDisabled( entity player )
{
	return player.GetPlayerNetBool( NETVAR_RESPAWN_DISABLED )
}
#endif // SERVER || CLIENT

#if SERVER
void function Respawn_Token_OnClientConnected( entity player )
{
	if ( !IsValid( player ) )
		return

	SetPlayerLives( player, GetStartingRespawnCount(), false )
}
#endif // SERVER

#if SERVER
void function Respawn_Token_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( victim ) )
		return

	Respawn_Token_TryTakeToken( victim )

	if ( !Respawn_Token_IsPlayerEliminated( victim ) )
	{
		Respawn_Token_DropExtraLoot( victim, damageInfo )

		int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		bool isFallOrCrushDeath = SURVIVAL_IsFallDeath( victim, damageSourceIdentifier ) || SURVIVAL_IsCrushDeath( damageSourceIdentifier )
		thread Respawn_Token_PingDeathLocation_Thread( victim, isFallOrCrushDeath )
	}
}
#endif // SERVER

#if SERVER
void function Respawn_Token_TryTakeToken( entity player )
{
	switch ( GetPlaylistVar_RespawnTokenType() )
	{
		case eRespawnTokenType.INDIVIDUAL:
			Respawn_Token_TakeToken( player, eRespawnTokenType.INDIVIDUAL )
			break

		case eRespawnTokenType.SQUAD:
			if ( GetPlayerArrayOfTeam_Alive( player.GetTeam() ).len() <= 0 )
			{
				Respawn_Token_TakeToken( player, eRespawnTokenType.SQUAD )
			}
			break

		case eRespawnTokenType.BANK:
			Respawn_Token_TakeToken( player, eRespawnTokenType.BANK )
			break

		default:
			break
	}
}
#endif // SERVER

#if SERVER
void function Respawn_Token_TakeToken( entity player, int respawnTokenType )
{
	if( respawnTokenType == eRespawnTokenType.SQUAD || respawnTokenType == eRespawnTokenType.BANK )
	{
		TakeSquadLife( player )
	}
	else if ( respawnTokenType == eRespawnTokenType.INDIVIDUAL )
	{
		TakePlayerLife( player )
	}

	if ( !Respawn_Token_IsPlayerEliminated( player ) || !GamePlayingOrSuddenDeath() )
		return

	CheckForAndTrySetEliminationModeWinner()
}
#endif // SERVER

#if SERVER
void function Respawn_Token_DropExtraLoot( entity player, var damageInfo )
{
	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool isFallOrCrushDeath = SURVIVAL_IsFallDeath( player, damageSourceIdentifier ) || SURVIVAL_IsCrushDeath( damageSourceIdentifier )

	if ( GetPlaylistVar_AmmoOnKillEnabled() )
	{
		SpawnAmmoForAttacker( player, damageInfo, isFallOrCrushDeath )
	}

	if ( GetPlaylistVar_ArmorOnKillEnabled() )
	{
		LootData armorData = GamemodeUtility_GetPlayerArmorData( player )
		if ( isFallOrCrushDeath )
		{
			GamemodeUtility_SpawnArmor( player, armorData, 0.0, eSpawnSource.PLAYER_DEATH, true )
		}
		else
		{
			GamemodeUtility_SpawnArmor( player, armorData )
		}
	}
}
#endif // SERVER

#if SERVER
void function Respawn_Token_PingDeathLocation_Thread( entity player, bool useSafeLocation )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( !GetPlaylistVar_PingDeathLocationEnabled() )
		return

	vector pingLocation
                             
		pingLocation = player.GetOrigin() + <0, 0, 16>
      
                                                
                                   

	if ( useSafeLocation )
		pingLocation = GetSafeLocation( pingLocation )

	player.EndSignal( "OnDestroy" )
	player.WaitSignal( "OnRespawned" )
	wait 0.5

	entity wp
                             
		wp = CreateWaypoint_BasicLocation( pingLocation, ePingType.MARK_MY_LAST_DEATH_LOCATION )
      
                                                                    
                                   

	wp.SetOnlyTransmitToOnePlayer( player )
	wp.SetOwner( player )

	wp.EndSignal( "OnDestroy" )
	OnThreadEnd( function() : ( wp ) {
		if ( IsValid( wp ) )
		{
			wp.Destroy()
		}
	} )

	wait TIME_DEATH_PING_WAIT
}
#endif // SERVER

#if SERVER
void function Respawn_Token_OnPlayerDisconnect( entity player )
{
	if ( GetPlaylistVar_TakeTokenOnDisconnect() )
	{
		SetPlayerLives( player, 0, false )
	}

	if ( GetPlaylistVar_KillPlayerOnDisconnect() )
	{
		player.TakeDamage( player.GetMaxHealth(), null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } )
	}
}
#endif //SERVER

#if SERVER
void function Respawn_Token_OnPlayerReconnect( entity player )
{
	Remote_CallFunction_Replay( player, NETFUNC_ON_RECONNECT_UPDATE_RUI )
}
#endif // SERVER

#if SERVER
void function Respawn_Token_OnDeathFieldStopShrink( table<int,DeathFieldData> deathFieldData )
{
	int deathStage = SURVIVAL_GetCurrentDeathFieldStage()
	int disableStage = GetPlaylistVar_RespawnDisabledDeathstage()
	if ( deathStage == disableStage )
	{
		array<entity> players = GetPlayerArray()
		foreach( player in players )
		{
			player.SetPlayerNetBool( NETVAR_RESPAWN_DISABLED, true )

			if ( Respawn_Token_CanPlayerRespawn( player ) )
			{
				                    
					UpgradeCore_IncrementXP( player, GetPlaylistVar_XPForRespawnToken(), false, eUpgradeXPActions.RESPAWN_TOKEN_PRESERVED )
          

				// We are using SetPlayerLives instead of AdjustPlayerLives since this loop is going through each player individually
				SetPlayerLives( player, 0, true )
			}

			// After xp awarded to queue respawn warning after levelup announcement - the levelup announcement is set to purge
			Remote_CallFunction_NonReplay( player, NETFUNC_ANNOUNCEMENT_RESPAWNS_DISABLED )
		}
	}
}
#endif // SERVER

#if SERVER
bool function Respawn_Token_CanPlayerRespawn( entity player )
{
	return ( GetPlayerLives( player ) > 0 )
}
#endif // SERVER

#if SERVER
bool function Respawn_Token_IsPlayerNotEliminated( entity player )
{
	return !Respawn_Token_IsPlayerEliminated( player )
}
#endif // SERVER

#if SERVER
bool function Respawn_Token_IsPlayerEliminated( entity player )
{
	return ( GetPlayerLives( player ) <= -1 )
}
#endif // SERVER

#if SERVER
float function Respawn_Token_RespawnCooldown( int team )
{
	// team is ignored, used to match required function signature
	return GetCurrentPlaylistVarFloat( "respawn_token_cooldown_after_kill_replay", 5.0 )
}
#endif // SERVER

#if SERVER
array< entity > function Respawn_Token_GetSquadPlayersToRespawn( entity player )
{
	return [ player ]
}
#endif // SERVER

#if UI || CLIENT
bool function Respawn_Token_CanLocalPlayerRespawn()
{
	return file.canRespawn
}
#endif // UI || CLIENT

#if UI || CLIENT
bool function Respawn_Token_CanLocalPlayerRespawnOrIsRespawning()
{
	return file.canRespawn || file.isRespawning
}
#endif // UI || CLIENT

#if UI || CLIENT
void function Respawn_Token_SetCanLocalPlayerRespawn( bool isRespawning, bool canRespawn )
{
	file.isRespawning = isRespawning
	file.canRespawn = canRespawn
}
#endif // UI || CLIENT

#if SERVER
void function SpawnAmmoForAttacker( entity victim, var damageInfo, bool spawnLootInSafeLocation )
{
	float ammoCount = GetPlaylistVar_AmmoOnKillMultiplier()
	int ammoStacks = GetPlaylistVar_AmmoOnKillBoxesToSpawn()
	for ( int i = 0; i < ammoStacks; i++ )
	{
		SpawnAmmoForRandomWeapon( victim, damageInfo, ammoCount, spawnLootInSafeLocation )
	}
}
#endif // SERVER

#if SERVER || CLIENT
int function GetPlayerLives( entity player )
{
	if ( !IsValid( player ) )
	{
		return 0
	}

	return player.GetPlayerNetInt( NETVAR_SQUAD_LIVES )
}
#endif // SERVER || CLIENT

#if SERVER
void function SetPlayerLives( entity player, int newValue, bool fromRespawnDisable )
{
	if ( !IsValid( player ) )
		return

	SetPlayerLives_Stats( player, newValue, fromRespawnDisable )

	player.SetPlayerNetInt( NETVAR_SQUAD_LIVES, newValue )
}
#endif // SERVER

#if SERVER
void function SetPlayerLives_Stats( entity player, int newValue, bool fromRespawnDisable )
{
	if ( !IsValid( player ) )
		return

	int lifeCountChange = GetPlayerLives( player ) - newValue

	if ( lifeCountChange > 0 && newValue >= 0 )
	{
		int solosStat = eSurvivalSolosStat.EXTRA_LIVES_USED
		if ( fromRespawnDisable )
		{
			solosStat = eSurvivalSolosStat.EXTRA_LIVES_PRESERVED
		}

		GameSummarySquadData squadData = GameSummary_GetPlayerData( player )
		if ( ( solosStat in squadData.modeMetaData ) == false )
			squadData.modeMetaData[ solosStat ] <- 0

		squadData.modeMetaData[ solosStat ] += lifeCountChange
	}
}
#endif // SERVER

#if SERVER
void function AdjustPlayerLives( entity player, int lifeChange )
{
	if ( !IsValid( player ) )
		return

	int lives = GetPlayerLives( player )
	int newlives = ( lives + lifeChange )

	SetPlayerLives( player, newlives, false )
}
#endif // SERVER

#if SERVER
void function TakePlayerLife( entity player )
{
#if DEVELOPER
	if ( file.infiniteLives )
		return
#endif // DEV

	AdjustPlayerLives( player, -1 )
}
#endif // SERVER

#if SERVER
void function GivePlayerLife( entity player )
{
	AdjustPlayerLives( player, 1 )
}
#endif // SERVER

#if SERVER
void function AdjustSquadLives( entity player, int lifeChange )
{
	array<entity> squadArray = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach ( squadMember in squadArray )
	{
		AdjustPlayerLives( squadMember, lifeChange )
	}
}
#endif // SERVER

#if SERVER
void function TakeSquadLife( entity player )
{
#if DEVELOPER
	if ( file.infiniteLives )
		return
#endif // DEV

	AdjustSquadLives( player, -1 )
}
#endif // SERVER

#if SERVER
void function GiveSquadLife( entity player )
{
	AdjustSquadLives( player, 1 )
}
#endif // SERVER

#if CLIENT
var function Respawn_Token_OnSetupAnnouncement_RemainingRespawns( AnnouncementData announcement )
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return null

	var rui = RuiCreate( $"ui/announcement_solos_respawns_remaining.rpak", clGlobal.topoFullScreen, RUI_DRAW_POSTEFFECTS, RUI_SORT_SCREENFADE + 1 )
	RuiSetInt( rui, "squadLives", file.squadLives )
	RuiSetInt( rui, "strikeTotal", LivesToStrikes( file.squadLives ) )

	EmitSoundOnEntity( player, announcement.soundAlias )
	return rui
}
#endif // CLIENT

#if CLIENT
void function Respawn_Token_SquadLivesChanged( entity player, int newValue )
{
	if ( !IsValid( player ) )
		return

	if ( player == GetLocalViewPlayer() )
	{
		file.squadLivesViewPlayer = newValue
	}

	if ( player == GetLocalClientPlayer() )
	{
		file.squadLives = newValue

		// NETVAR_SQUAD_LIVES is being reset to 0 shortly after the local player is eliminated, this tracks that they were eliminated until we work that out
		if ( file.squadLives <= -1 )
		{
			file.squadEliminated = true
		}
	}

	UpdateRui_SquadLives()
}
#endif // CLIENT

#if CLIENT
void function Respawn_Token_PlayerFreefallActiveChanged( entity player, bool isFreefallActive )
{
	if ( !isFreefallActive )
		return

	if ( file.lastSquadLifeAnnouncement == file.squadLives )
		return

	Announcement_SquadLivesRemaining()
	file.lastSquadLifeAnnouncement = file.squadLives
}
#endif // CLIENT

#if CLIENT
void function UpdateRui_SquadLives()
{
	var gamestateRui = ClGameState_GetRui()
	if ( gamestateRui != null && RuiIsAlive( gamestateRui ) && file.nestedRespawnTokenRui == null || !RuiIsAlive( file.nestedRespawnTokenRui ) )
	{
		RuiDestroyNestedIfAlive( gamestateRui, "respawnTokenHudHandle" )
		file.nestedRespawnTokenRui = RuiCreateNested( gamestateRui, "respawnTokenHudHandle", RUI_RESPAWN_HUD )
	}

	if ( file.nestedRespawnTokenRui != null && RuiIsAlive( file.nestedRespawnTokenRui ) )
	{
		RuiSetInt( file.nestedRespawnTokenRui, "squadLives", maxint( file.squadLives, 0 ) )
		RuiSetInt( file.nestedRespawnTokenRui, "viewPlayerLives", maxint( file.squadLivesViewPlayer, 0 ) )
	}

	if ( IsValid( GetLocalClientPlayer() ) )
	{
		bool isRespawning = file.squadLives >= 0 && !file.squadEliminated
		bool canRespawn = !file.squadEliminated && ( (file.squadLives > 0 && IsAlive( GetLocalClientPlayer() ) ) || (file.squadLives >= 0 && !IsAlive( GetLocalClientPlayer() ) ) )

		Respawn_Token_SetCanLocalPlayerRespawn( isRespawning, canRespawn )
		RunUIScript( "Respawn_Token_SetCanLocalPlayerRespawn", isRespawning, canRespawn )
	}
}
#endif // CLIENT

#if CLIENT
void function UpdateRui_RespawnState( bool newState )
{
	var rui = ClGameState_GetRui()
	if ( rui != null )
	{
		RuiSetBool( rui, RUIVAR_RESPAWN_DISABLED, newState )
	}

	Respawn_Token_SetCanLocalPlayerRespawn( newState, newState )
	RunUIScript( "Respawn_Token_SetCanLocalPlayerRespawn", newState, newState )
}
#endif // CLIENT

#if CLIENT
void function Respawn_Token_OnReconnect_UpdateRUI()
{
	UpdateRui_SquadLives()
}
#endif // CLIENT

#if CLIENT
void function Announcement_SquadLivesRemaining()
{
	string message = Localize( "#SURVIVAL_MODE_SOLOS_RESPAWN_TOKEN_USED" )
	string announcementSFX

	if ( file.squadLives >= 2 )
	{
		announcementSFX = SFX_SQUAD_LIVES_REMAINING_TWO
	}
	else if ( file.squadLives >= 1 )
	{
		announcementSFX = SFX_SQUAD_LIVES_REMAINING_ONE
	}
	else
	{
		announcementSFX = SFX_SQUAD_LIVES_REMAINING_ZERO
	}

	AnnouncementData announcement = Announcement_Create( message )
	announcement.priority = 202 // ring events are 200

	Announcement_SetDuration( announcement, TIME_ANNOUNCEMENT_SQUAD_LIVES_REMAINING )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_REMAINING_RESPAWNS )
	Announcement_SetPriority( announcement, PRIORITY_ANNOUNCEMENT_SQUAD_LIVES_REMAINING )

	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	EmitSoundOnEntity( GetLocalViewPlayer(), announcementSFX )

	UpdateRui_SquadLives()
}
#endif // CLIENT

#if CLIENT
// The evo levelup from owning a token purges the round start announcement, so we re-add it here with the respawn disabled message
void function Respawn_Token_Announcement_RespawnsDisabled()
{
	int currentDeathFieldStage = SURVIVAL_GetCurrentDeathFieldStage()
	if ( currentDeathFieldStage >= 0 )
	{
		AnnouncementData announcement = Announcement_Create( Localize( "#SURVIVAL_CIRCLE_STARTING" ) )

		Announcement_SetSubText( announcement, GetAnnouncementSubtextString( currentDeathFieldStage + 1 ) )
		Announcement_SetHeaderText( announcement, "" ) // #SURVIVAL_CIRCLE_WARNING // see Announcement_SetDisplayEndTime below
		Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
		Announcement_SetAdditionalText( announcement, "#SURVIVAL_MODE_SOLOS_RESPAWNS_DISABLED" )
		// Announcement_SetDisplayEndTime( announcement, GetGlobalNetTime( "nextCircleStartTime" ) ) // nextCircleStartTime is incorrect in this context (shrink end, not round start), so I have moved the header into the main message to make this make sense
		Announcement_SetDuration( announcement, TIME_ANNOUNCEMENT_RESPAWN_DISABLED )
		Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING )
		Announcement_SetSoundAlias( announcement, SFX_RESPAWN_DISABLED )
		Announcement_SetPriority( announcement, 209 )
		Announcement_SetPurge( announcement, false ) // not purging here causes back to back ring start announcements if there was no levelup, but purging will purge the levelup if it occured

		AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	}

	UpdateRui_RespawnState( false )
	UpdateRui_SquadLives()
}
#endif // CLIENT

#if CLIENT
int function Respawn_Token_GetMaxSquadLives()
{
	return GetStartingRespawnCount() + 1
}
#endif // CLIENT

#if CLIENT
bool function Respawn_Token_IsPlayerWaitingForRespawn( entity player )
{
	if ( !IsValid( player ) || ( player != GetLocalClientPlayer() ) )
		return false

	if ( Sh_Respawn_Token_IsPlayerRespawnDisabled( player ) )
		return false

	if ( file.squadEliminated )
		return false

	// < 0 means that the player used their last life and can no longer respawn
	return ( file.squadLives >= 0 )
}
#endif // CLIENT

#if DEVELOPER && SERVER
void function DEV_Respawn_Token_GiveSquadLife( entity player )
{
	GiveSquadLife( player )
}
#endif // DEV && SERVER

#if DEVELOPER && SERVER
void function DEV_Respawn_Token_ToggleInfiniteLives()
{
	file.infiniteLives = !file.infiniteLives

	string state = ( file.infiniteLives ? "ON" : "OFF" )
	printf( "[Solos] Infinite lives is toggled to: " + state )
}
#endif // DEV && SERVER

int function LivesToStrikes( int lives )
{
	// Strikes count from 0 to 3 while lives start at any positive value and count to -1
	const int MAX_STRIKES = 3

	int strikes = minint( MAX_STRIKES - lives - 1, 3 )
	return maxint( strikes, 0 )
}

bool function GetPlaylistVar_RespawnTokenEnabled()
{
	return GetCurrentPlaylistVarBool( "respawn_token_enabled", false )
}

int function GetPlaylistVar_RespawnTokenType()
{
	string playlistTokenType = GetCurrentPlaylistVarString( "respawn_token_type", "" ).tolower()

	int tokenType = eRespawnTokenType.INVALID
	bool typeFound = false
	for( int i = 0; i < eRespawnTokenType._COUNT; i++ )
	{
		string enumType = GetEnumString( "eRespawnTokenType", i ).tolower()
		if ( enumType.tolower() == playlistTokenType )
		{
			tokenType = i
			typeFound = true
			break
		}
	}

	Assert( typeFound, "Playlist Respawn Token type '" + playlistTokenType + "' is not a specified enumerator." )

	return tokenType
}

bool function GetPlaylistVar_AmmoOnKillEnabled()
{
	return GetCurrentPlaylistVarBool( "respawn_token_ammo_on_kill_enabled", false )
}

float function GetPlaylistVar_AmmoOnKillMultiplier()
{
	return GetCurrentPlaylistVarFloat( "respawn_token_ammo_on_kill_multiplier", 1.0 )
}

int function GetPlaylistVar_AmmoOnKillBoxesToSpawn()
{
	return GetCurrentPlaylistVarInt( "respawn_token_ammo_on_kill_spawns", 4 )
}

bool function GetPlaylistVar_ArmorOnKillEnabled()
{
	return GetCurrentPlaylistVarBool( "respawn_token_armor_on_kill_enabled", false )
}

bool function GetPlaylistVar_PingDeathLocationEnabled()
{
	return GetCurrentPlaylistVarBool( "respawn_token_ping_death_location", false )
}

int function GetPlaylistVar_RespawnDisabledDeathstage()
{
	return GetCurrentPlaylistVarInt( "respawn_token_respawn_disable_deathstage_close", 4 )
}

int function GetPlaylistVar_XPForRespawnToken()
{
	return GetCurrentPlaylistVarInt( "respawn_token_xp_for_respawn_token", 500 )
}

bool function GetPlaylistVar_TakeTokenOnDisconnect()
{
	return GetCurrentPlaylistVarBool( "respawn_token_take_token_on_disconnect", false )
}

bool function GetPlaylistVar_KillPlayerOnDisconnect()
{
	return GetCurrentPlaylistVarBool( "respawn_token_kill_player_on_disconnect", false )
}
