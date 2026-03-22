

#if SERVER || CLIENT
global function Sh_Survival_Solos_Init
#endif

#if CLIENT
global function Survival_Solos_Announcement_SquadElimination
global function Survival_Solos_SetDeathScreenCallbacks
#endif

#if SERVER || CLIENT
const string NETFUNC_SET_DEATH_SCREEN_CALLBACKS = "Survival_Solos_SetDeathScreenCallbacks"

const float TIME_ANNOUNCEMENT_SQUAD_ELIMINATED = 4.0
#endif

#if CLIENT
const string RUIVAR_DEATH_SCREEN_TITLE = "headerText"
const string RUIVAR_DEATH_SCREEN_KILLS = "killsText"

const string TEXT_MODE_SOLOS = "#SURVIVAL_MODE_SOLOS"
const string TEXT_MODE_SOLOS_SUB = "#SURVIVAL_MODE_SOLOS_DESCRIPTION_2"
const string TEXT_MODE_SOLOS_RESPAWNS_REMAINING = "#SURVIVAL_MODE_SOLOS_RESPAWNS_REMAINING"
const string TEXT_MODE_SOLOS_RESPAWN_REMAINING = "#SURVIVAL_MODE_SOLOS_RESPAWN_REMAINING"
const string TEXT_MODE_SOLOS_FINAL_RESPAWN = "#SURVIVAL_MODE_SOLOS_FINAL_RESPAWN"
const string TEXT_MODE_SOLOS_RESPAWNS_REMAINING_LABEL = "#SURVIVAL_MODE_SOLOS_RESPAWNS_REMAINING_LABEL"
const string TEXT_RESPAWN_DISABLED = "RESPAWNING DISABLED"
const string TEXT_RESPAWN_DISABLED_SUB = "Tokens have been converted to XP"
const string TEXT_SQUAD_PLACEMENT_WIN = "#SQUAD_PLACEMENT_GCARDS_TITLE"
const string TEXT_SQUAD_PLACEMENT_LOSE = "#SQUAD_HEADER_DEFEAT"
const string TEXT_SQUAD_PLACEMENT_KILLS = "#DEATH_SCREEN_SUMMARY_KILLS"
const string TEXT_DEATH_SCREEN_SUMMARY_KILLS = "#DEATH_SCREEN_SUMMARY_KILLS"
const string TEXT_DEATH_SCREEN_SUMMARY_ASSISTS = "#DEATH_SCREEN_SUMMARY_ASSISTS"
const string TEXT_DEATH_SCREEN_SUMMARY_KNOCKDOWNS = "#DEATH_SCREEN_SUMMARY_KNOCKDOWNS"
const string TEXT_DEATH_SCREEN_SUMMARY_DAMAGE = "#DEATH_SCREEN_SUMMARY_DAMAGE_DEALT"
const string TEXT_DEATH_SCREEN_SUMMARY_TIME = "#DEATH_SCREEN_SUMMARY_SURVIVAL_TIME"
const string TEXT_DEATH_SCREEN_SUMMARY_REVIVES = "#DEATH_SCREEN_SUMMARY_REVIVES"
const string TEXT_DEATH_SCREEN_SUMMARY_RESPAWN_TOKENS_USED = "#DEATH_SCREEN_SUMMARY_RESPAWN_TOKENS_USED"
const string TEXT_DEATH_SCREEN_SUMMARY_RESPAWN_TOKENS_REMAINING = "#DEATH_SCREEN_SUMMARY_RESPAWN_TOKENS_REMAINING"

const string SFX_SQUAD_ELIMINATED = "UI_3Strikes_EnemySquadEliminated"
#endif

// Mode-specific table info for Game Summary Squad Data
// these should be specific to the final display location - e.g., 4 displays in "slot 4" -> 1 / 1a / 1b | 2 | 3 | 4 | 5 -- maps to --> [ 0, ... , 0 ]
// so 4 would be the 4th index - or 5th slot - *in the array* or position 3 on the UI.
global enum eSurvivalSolosStat {
	EXTRA_LIVES_USED = 5,
	EXTRA_LIVES_PRESERVED = 6,
}


#if SERVER || CLIENT
void function Sh_Survival_Solos_Init()
{
	Sh_Survival_Solos_RegisterNetworking()

	#if SERVER

			MatchBehaviorPlayer_AddEndedCallback( Survival_Solos_OnMatchBehaviorEnd )

	#endif
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
void function Sh_Survival_Solos_RegisterNetworking()
{
	Remote_RegisterClientFunction( NETFUNC_SET_DEATH_SCREEN_CALLBACKS )
}
#endif // SERVER || CLIENT

#if SERVER
void function Survival_Solos_OnClientConnected( entity player )
{
	if ( IsValid( player ) )
	{
		Remote_CallFunction_NonReplay( player, NETFUNC_SET_DEATH_SCREEN_CALLBACKS )
	}
}
#endif // SERVER

#if SERVER

void function Survival_Solos_OnMatchBehaviorEnd( entity player, bool wasUnexpectedDisconnect )
{
	if ( IsValid( player ) )
	{
		Remote_CallFunction_NonReplay( player, NETFUNC_SET_DEATH_SCREEN_CALLBACKS )
	}
}

#endif // SERVER

#if CLIENT
void function Survival_Solos_SetDeathScreenCallbacks()
{
	DeathScreen_SetModeSpecificRuiUpdateFunc( Survival_Solos_DeathScreenUpdate )
	DeathScreen_SetDataRuiAssetForGamemode( $"ui/header_data_solo.rpak" )
	SetSummaryDataDisplayStringsCallback( Survival_Solos_PopulateSummaryDataStrings )
	AddCallback_ShouldShowDeathScreen( Survival_Solos_ShouldShowDeathScreen )
}
#endif // CLIENT

#if CLIENT
void function Survival_Solos_DeathScreenUpdate( var rui )
{
	SquadSummaryData squadData = GetSquadSummaryData()
	string titleString = squadData.squadPlacement == 1 ? TEXT_SQUAD_PLACEMENT_WIN : TEXT_SQUAD_PLACEMENT_LOSE
	string killsText = TEXT_SQUAD_PLACEMENT_KILLS
	RuiSetString( rui, RUIVAR_DEATH_SCREEN_TITLE, titleString )
	RuiSetString( rui, RUIVAR_DEATH_SCREEN_KILLS, killsText )
	RuiSetBool( rui, "isAwaitingRespawn", Respawn_Token_CanLocalPlayerRespawnOrIsRespawning() )
}
#endif // CLIENT

#if CLIENT
bool function Survival_Solos_ShouldShowDeathScreen()
{
	return true // !Survival_Solos_CanLocalPlayerRespawnOrIsRespawning()
}
#endif // CLIENT

#if CLIENT
void function Survival_Solos_PopulateSummaryDataStrings( SquadSummaryPlayerData data )
{
	data.modeSpecificSummaryData[0].displayString = TEXT_DEATH_SCREEN_SUMMARY_KILLS
	data.modeSpecificSummaryData[1].displayString = ""
	data.modeSpecificSummaryData[2].displayString = ""
	data.modeSpecificSummaryData[3].displayString = TEXT_DEATH_SCREEN_SUMMARY_DAMAGE
	data.modeSpecificSummaryData[4].displayString = TEXT_DEATH_SCREEN_SUMMARY_TIME
	data.modeSpecificSummaryData[5].displayString = TEXT_DEATH_SCREEN_SUMMARY_RESPAWN_TOKENS_USED
	data.modeSpecificSummaryData[6].displayString = TEXT_DEATH_SCREEN_SUMMARY_RESPAWN_TOKENS_REMAINING
}
#endif // CLIENT

#if CLIENT
void function Announcement_SplashSolo()
{
	string message = TEXT_MODE_SOLOS
	string subText = TEXT_MODE_SOLOS_SUB

	AnnouncementData announcement = Announcement_Create( message )
	announcement.priority = 202 // ring events are 200
	announcement.drawOverScreenFade = true

	Announcement_SetSubText( announcement, subText )
	Announcement_SetHideOnDeath( announcement, true )
	Announcement_SetDuration( announcement, 16.0 )
	Announcement_SetPurge( announcement, true )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetTitleColor( announcement, <0, 0, 0> )
	Announcement_SetIcon( announcement, $"" )
	Announcement_SetLeftIcon( announcement, $"" )
	Announcement_SetRightIcon( announcement, $"" )

	AnnouncementFromClass( GetLocalClientPlayer(), announcement )
}
#endif // CLIENT

#if CLIENT
void function Survival_Solos_Announcement_SquadElimination()
{
	string message = ""

	AnnouncementData announcement = Announcement_Create( message )

	Announcement_SetDuration( announcement, TIME_ANNOUNCEMENT_SQUAD_ELIMINATED )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_MILESTONE_SMALL )
	Announcement_SetTitleColor( announcement, < 1,1,1 > )

	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	EmitSoundOnEntity( GetLocalViewPlayer(), SFX_SQUAD_ELIMINATED )
}
#endif // CLIENT
