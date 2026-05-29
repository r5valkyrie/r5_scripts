global function ShApexScreens_Init

#if SERVER
global function SvApexScreens_ShowCircleState
global function SvApexScreens_ForceShowSquad
global function SvApexScreens_HighlightPlayerForImpressiveKill
global function SvApexScreens_HighlightPlayerForKillSpree
global function SvApexScreens_SetEventTimeA
global function SvApexScreens_SetEventTimeB
global function SvApexScreens_SetEventIntA
global function SvApexScreens_SetScreenSequenceForGameState
global function SvApexScreens_RefreshScreenSequence
global function SvApexScreens_QueueCustomScreenSequence
global function SvApexScreens_SetLogoModeCenterOnly
#endif

#if SERVER && DEVELOPER
global function DEV_ApexScreens_SetMode
global function DEV_ApexScreens_TogglePreviewMode
global function DEV_ApexScreens_GladCardPreviewMode
global function ApexScreenMasterThink
#endif

#if CLIENT
global function ClApexScreens_DisableAllScreens
global function ClApexScreens_EnableAllScreens
global function ClApexScreens_IsDisabled
global function ServerToClient_ApexScreenKillDataChanged
global function ServerToClient_ApexScreenRefreshAll
//global function ClApexScreens_Lobby_SetMode
//global function ClApexScreens_Lobby_SetCardOwner
global function ClApexScreens_OnStaticPropRuiVisibilityChange
global function ClApexScreens_AddScreenOverride
global function ClApexScreens_GetCustomBannerScreen
global function ClApexScreens_PosInStaticBanner

global function ClApexScreens_SetCustomApexScreenBGAsset
global function ClApexScreens_SetCustomLogoTint
global function ClApexScreens_SetCustomLogoImage
global function ClApexScreens_SetCustomLogoSize
global function ClApexScreens_SetAnimatedLogoAsset
global function ClApexScreens_SetEventScreenOverride
#endif

global function GetCurrentPlaylistVarAsset

#if CLIENT && DEVELOPER
global function DEV_CreatePerfectApexScreen
global function DEV_ToggleActiveApexScreenDebug
#endif

global const string CUSTOM_BANNER_LEFT_SCRIPTNAME = "leftScreen_custom"
global const string CUSTOM_BANNER_CENTER_SCRIPTNAME = "centerScreen_custom"
global const string CUSTOM_BANNER_RIGHT_SCRIPTNAME = "rightScreen_custom"

const int EHI_LOCALSELF 				= -1
const int EHI_LOCALTEAMMATE_RANDOM 	= -2

const float APEX_SCREEN_TRANSITION_IN_DURATION = 0.7 // must stay in sync with apex_screens.rui

const float APEX_SCREEN_RANDOM_TINT_INTENSITY_MIN = 0.4
const float APEX_SCREEN_RANDOM_TINT_INTENSITY_MAX = 0.6
const vector[3] APEX_SCREEN_RANDOM_TINT_PALETTE = [
	<1.0, 1.0, 1.0> - <0.85, 0.87, 0.88>,
	<1.0, 1.0, 1.0> - <0.80, 0.95, 1.00>,
	<1.0, 1.0, 1.0> - <0.98, 1.00, 1.00>,
]

const asset BLANK_ASSET = $"ui/apex_screen_logo_only.rpak"

// "Apex Screen" = really big flex screen (not an entity)
// "Apex Screen state" = what's showing on a particular screen, in particular "mode index" where mode means "show logo", "show blisk's face", "show a gladiator card", etc


global enum eApexScreenPosition
{
	// must match  * in apex_screens.rui
	L = 0,
	C = 1,
	R = 2,
	_COUNT_BANNERTYPES,

	TV_LIKE = 3,

	DISABLED = -1,
}

global enum eApexScreenMode
{
	// must match APEX_SCREEN_MODE_* in apex_screens.rui
	OFF = 0,
	LOGO = 1,
	PLAYER_NAME_CHAMPION = 2,
	PLAYER_NAME_KILLLEADER = 3,
	GCARD_FRONT_CLEAN = 4,
	GCARD_FRONT_DETAILS = 5,
	GCARD_BACK = 6,
	UNUSED = 7,
	CIRCLE_STATE = 8,
	PLAYERS_REMAINING = 9,
	SQUADS_REMAINING = 10,
	ZONE_NAME = 11,
	ZONE_LOOT = 12,
	CAMERA_VIEW = 13,
	BG_NO_LOGO = 14,

	_COUNT,
	INVALID = -1,
}

global enum eApexScreenTransitionStyle
{
	// must match APEX_SCREEN_TRANSITION_STYLE_* in apex_screens.rui
	NONE = 0,
	SLIDE = 1,
	FADE_TO_BLACK = 2,
}


global enum eApexScreenMods
{
	RED = (1 << 0),
}

global enum eApexScreenDisplayGroup
{
	DISPLAY_PLAYER,
	DISPLAY_PLAYER_SQUAD,
	DISPLAY_LOGOS,
	DISPLAY_CENTER_LOGO_ONLY,
	DISPLAY_RANDOM_PLAYERS,
	DISPLAY_PLAYER_SQUAD_CENTERED,
	DISPLAY_LOCALPLAYER,
	DISPLAY_RANDOM_LOCALTEAMMATE
}

#if CLIENT
global struct ScreenOverrideInfo
{
	asset  ruiAsset
	string scriptNameRequired = ""
	bool   skipStandardVars

	//
	bool bindStartTimeVarToEventTimeA
	bool bindStartTimeVarToEventTimeB
	bool bindEventIntA

	struct
	{
		table<string, int>    ints
		table<string, float>  floats
		table<string, bool>   bools
		table<string, asset>  images
		table<string, string> strings
		table<string, vector> float3s
		table<string, vector> float2s
		table<string, float>  gametimes
	} vars
}
table<string, ScreenOverrideInfo> s_screenOverrides

global struct ApexScreenState
{
	var    rui

	var 	nestedRui

	int    magicId
	string mockup
	asset  ruiToCreate
	asset  ruiToCreateOrig
	asset  ruiLastCreated

	bool                overrideInfoIsValid = false
	ScreenOverrideInfo& overrideInfo

	vector uvMin = <0.0, 0.0, 0.0>
	vector uvMax = <1.0, 1.0, 0.0>
	bool   sharesPropWithEnvironmentalRUI = false

	bool  visibleInPVS = false
	bool  isOutsideCircle = false
	float commenceTime

	int    position = -1
	vector spawnOrigin
	vector spawnForward
	vector spawnRight
	vector spawnUp
	float  spawnScale
	vector spawnMins
	vector spawnMaxs
	float  diagonalSize
	int    modBits = 0x00000000

	float                      currDistToSizeRatio = -1.0
	NestedGladiatorCardHandle& nestedGladiatorCard0Handle

	vector tint

	var    floatingTopo = null
	var    floatingRui = null
	var[3] floatingNestedBadgeRuiList = [null, null, null]

	int updateSerialNum = 0
}
#endif


#if CLIENT
struct ApexScreenPositionMasterState
{
	float commenceTime = -1
	int   modeIndex = eApexScreenMode.LOGO
	int   transitionStyle = -1
	EHI   playerEHI
}
#endif


#if SERVER
struct ApexScreenJob
{
	int mode = eApexScreenMode.INVALID

}

global struct ApexScreenSettingsGroup
{
	float duration = 20.0
	int displayMode = eApexScreenDisplayGroup.DISPLAY_LOGOS
	EncodedEHandle functionref() getFocusPlayerFunc
	int overrideScreen_L = -1
	int overrideScreen_C = -1
	int overrideScreen_R = -1
}
#endif


struct {
	#if SERVER && DEVELOPER
		bool DEV_inDebugPreviewMode = false
	#endif

	#if SERVER
		array<ApexScreenSettingsGroup> queuedScreenSettings
		table< int, array<ApexScreenSettingsGroup> > gameStateToScreenSettings
		bool logoModeCenterOnly = false
	#endif

	#if CLIENT
		ApexScreenPositionMasterState[eApexScreenPosition._COUNT_BANNERTYPES] screenPositionMasterStates

		bool                        forceDisableScreens = false
		array<ApexScreenState>      staticScreenList
		bool                        allScreenUpdateQueued = false
		table<int, ApexScreenState> magicIdScreenStateMap
		table<int, array<var> >     environmentalRUIListMapByMagicId
		int                         killScreenDamageSourceID = -1
		float                       killScreenDistance
		int                         killedPlayerGrade
		string                      killedPlayerName
		table                       signalDummy

		table<string, ApexScreenState> customBannerList

		bool DEV_activeScreenDebug = false

		asset bannerBGAssert = $"rui/rui_screens/banner_c"
		vector logoOverlayTint = < 1.0 , 1.0, 1.0 >
		vector logoSize = <562,407,0>
		asset logoImage = $"rui/rui_screens/apex_logo"
		asset animatedLogoAsset = $""

		table< int, ScreenOverrideInfo > eventScreenOverrideByScreenPosTable
	#endif
} file


#if SERVER || CLIENT
const string NV_ApexScreensEventTimeA = "NV_ApexScreensEventTimeA"
const string NV_ApexScreensEventTimeB = "NV_ApexScreensEventTimeB"
const string NV_ApexScreensEventIntA = "NV_ApexScreensEventIntA"
void function ShApexScreens_Init()
{
	#if SERVER
		BlockMapEntityParseCreationOf( "prop_control_panel", "ApexScreenTerminal", "" )
	#elseif CLIENT
		AddCallback_OnEnumStaticPropRui( OnEnumStaticPropRui )
	#endif

	if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
		return

	#if SERVER
		foreach ( state in eGameState )
		{
			file.gameStateToScreenSettings[ state ] <- []
		}

		{
			ApexScreenSettingsGroup settings
			settings.displayMode = eApexScreenDisplayGroup.DISPLAY_LOGOS
			settings.duration = 2.5
			file.gameStateToScreenSettings[ eGameState.WaitingForPlayers ].append( settings )
		}

		{
			ApexScreenSettingsGroup settings
			settings.displayMode = eApexScreenDisplayGroup.DISPLAY_RANDOM_PLAYERS
			settings.duration = 18.0
			file.gameStateToScreenSettings[ eGameState.WaitingForPlayers ].append( settings )
		}

		{
			ApexScreenSettingsGroup settings
			settings.displayMode = eApexScreenDisplayGroup.DISPLAY_PLAYER
			settings.duration = 20.0
			settings.getFocusPlayerFunc = SurvivalCommentary_GetChampionEEH
			settings.overrideScreen_L = eApexScreenMode.PLAYER_NAME_CHAMPION
			file.gameStateToScreenSettings[ eGameState.Playing ].append( settings )
		}

		{
			ApexScreenSettingsGroup settings
			settings.displayMode = eApexScreenDisplayGroup.DISPLAY_PLAYER_SQUAD
			settings.duration = 20.0
			settings.getFocusPlayerFunc = SurvivalCommentary_GetChampionEEH
			file.gameStateToScreenSettings[ eGameState.Playing ].append( settings )
		}

		{
			ApexScreenSettingsGroup settings
			settings.displayMode = eApexScreenDisplayGroup.DISPLAY_PLAYER
			settings.duration = 20.0
			settings.getFocusPlayerFunc = SurvivalCommentary_GetKillLeaderEEH
			settings.overrideScreen_L = eApexScreenMode.PLAYER_NAME_KILLLEADER
			file.gameStateToScreenSettings[ eGameState.Playing ].append( settings )
		}

		{
			ApexScreenSettingsGroup settings
			settings.displayMode = eApexScreenDisplayGroup.DISPLAY_PLAYER_SQUAD
			settings.duration = 20.0
			settings.getFocusPlayerFunc = SurvivalCommentary_GetKillLeaderEEH
			file.gameStateToScreenSettings[ eGameState.Playing ].append( settings )
		}
	#endif

	Remote_RegisterClientFunction( "ServerToClient_ApexScreenKillDataChanged", "int", 0, 512, "float", 0.0, 10000.0, 32, "int", 0, 32, "entity" )
	Remote_RegisterClientFunction( "ServerToClient_ApexScreenRefreshAll" )

	for ( int screenPosition = eApexScreenPosition.L; screenPosition <= eApexScreenPosition.R; screenPosition++ )
	{
		RegisterNetworkedVariable( format( "ApexScreensMasterState_Pos%d_CommenceTime", screenPosition ), SNDC_GLOBAL, SNVT_TIME, -1 )
		RegisterNetworkedVariable( format( "ApexScreensMasterState_Pos%d_ModeIndex", screenPosition ), SNDC_GLOBAL, SNVT_INT, -1 )
		RegisterNetworkedVariable( format( "ApexScreensMasterState_Pos%d_TransitionStyle", screenPosition ), SNDC_GLOBAL, SNVT_INT, -1 )
		RegisterNetworkedVariable( format( "ApexScreensMasterState_Pos%d_Player", screenPosition ), SNDC_GLOBAL, SNVT_BIG_INT, -1 )

		#if CLIENT
			RegisterNetVarTimeChangeCallback( format( "ApexScreensMasterState_Pos%d_CommenceTime", screenPosition ), void function( entity unused, float new ) : (screenPosition) {
				file.screenPositionMasterStates[screenPosition].commenceTime = new
				UpdateAllScreensContent()
			} )
			RegisterNetVarIntChangeCallback( format( "ApexScreensMasterState_Pos%d_ModeIndex", screenPosition ), void function( entity unused, int new ) : (screenPosition) {
				file.screenPositionMasterStates[screenPosition].modeIndex = new
				UpdateAllScreensContent()
			} )
			RegisterNetVarIntChangeCallback( format( "ApexScreensMasterState_Pos%d_TransitionStyle", screenPosition ), void function( entity unused, int new ) : (screenPosition) {
				file.screenPositionMasterStates[screenPosition].transitionStyle = new
				UpdateAllScreensContent()
			} )
			RegisterNetVarIntChangeCallback( format( "ApexScreensMasterState_Pos%d_Player", screenPosition ), void function( entity unused, int new ) : (screenPosition) {
				file.screenPositionMasterStates[screenPosition].playerEHI = new
				UpdateAllScreensContent()
			} )
		#endif // CLIENT
	}

	RegisterNetworkedVariable( NV_ApexScreensEventTimeA, SNDC_GLOBAL, SNVT_TIME, -1 )
	#if CLIENT
		RegisterNetVarTimeChangeCallback( NV_ApexScreensEventTimeA, void function( entity unused, float newTime )
		{
			OnUpdateApexScreensEventTime( newTime )
		} )
	#endif // CLIENT
	RegisterNetworkedVariable( NV_ApexScreensEventTimeB, SNDC_GLOBAL, SNVT_TIME, -1 )
	RegisterNetworkedVariable( NV_ApexScreensEventIntA, SNDC_GLOBAL, SNVT_INT, -1 )

	#if SERVER
		RegisterSignal( "ApexScreenMasterThink" )

		AddCallback_GameStatePostEnter( eGameState.PickLoadout, OnGameStatePostEnter_PickLoadout )
		AddCallback_GameStatePostEnter( eGameState.Prematch, OnGameStatePostEnter_Prematch )

		AddCallback_EntitiesDidLoad( EntitiesDidLoadSv )
	#elseif CLIENT
		RegisterSignal( "UpdateScreenCards" )
		RegisterSignal( "ScreenOff" )

		AddCallback_OnStaticPropRUICreated( ClientStaticPropRUICreated )
	#endif

	//AddCallback_OnSurvivalDeathFieldStageChanged( OnSurvivalDeathFieldStageChanged )
}
#endif

#if SERVER
void function SvApexScreens_SetEventTimeA( float time )
{
	SetGlobalNetTime( NV_ApexScreensEventTimeA, time )
}

void function SvApexScreens_SetEventTimeB( float time )
{
	SetGlobalNetTime( NV_ApexScreensEventTimeB, time )
}

void function SvApexScreens_SetEventIntA( int val )
{
	SetGlobalNetInt( NV_ApexScreensEventIntA, val )
}

#endif // SERVER

asset function CastStringToAsset( string val )
{
	return GetKeyValueAsAsset( { kn = val }, "kn" )
}


asset function GetCurrentPlaylistVarAsset( string varName, asset defaultAsset = $"" )
{
	string assetRaw = GetCurrentPlaylistVarString( varName, "" )
	if ( assetRaw.len() == 0 )
		return defaultAsset

	return CastStringToAsset( assetRaw )
}

#if CLIENT
vector function CastStringToFloat3( string val )
{
	array<string> fields = split( val, ", " )
	float xx             = ((fields.len() > 0) ? float( fields[0] ) : 0.0)
	float yy             = ((fields.len() > 1) ? float( fields[1] ) : 0.0)
	float zz             = ((fields.len() > 2) ? float( fields[2] ) : 0.0)
	return <xx, yy, zz>
}

void function SetupScreenOverridesFromPlaylist_S3Tease()
{
	for ( int overrideIdx = 0; overrideIdx < 5; ++overrideIdx )
	{
		// "apexscreen_tv_override_0"
		string keyName = format( "apexscreen_tv_override_%d", overrideIdx )
		if ( !GetCurrentPlaylistVarBool( keyName, false ) )
			continue

		SetupScreenOverridesFromPlaylists( keyName )
	}
}

void function SetupScreenOverridesFromPlaylists( string playlistKey )
{
	ScreenOverrideInfo newInfo
	newInfo.scriptNameRequired = GetCurrentPlaylistVarString( format( "%s_scriptname", playlistKey ), "" )
	newInfo.ruiAsset = CastStringToAsset( GetCurrentPlaylistVarString( format( "%s_rui", playlistKey ), "" ) )
	newInfo.skipStandardVars = GetCurrentPlaylistVarBool( format( "%s_skip_standard_vars", playlistKey ), false )
	newInfo.bindStartTimeVarToEventTimeA = GetCurrentPlaylistVarBool( format( "%s_bind_startTime_var_to_event_a", playlistKey ), false )
	newInfo.bindStartTimeVarToEventTimeB = GetCurrentPlaylistVarBool( format( "%s_bind_startTime_var_to_event_b", playlistKey ), false )

	for ( int varIdx = 0; varIdx < 10; ++varIdx )
	{
		string varPlaylistKey = format( "%s_var%d", playlistKey, varIdx )
		string val            = GetCurrentPlaylistVarString( varPlaylistKey, "" )
		if ( val.len() == 0 )
			continue

		array<string> splitVals = split( val, "~" )
		Assert( (splitVals.len() == 3), format( "Key '%s' with val '%s' only has %d/3 fields.", varPlaylistKey, val, splitVals.len() ) )
		switch( splitVals[0] )
		{
			case "int":
				newInfo.vars.ints[splitVals[1]] <- int( splitVals[2] )
				break

			case "float":
				newInfo.vars.floats[splitVals[1]] <- float( splitVals[2] )
				break

			case "bool":
				newInfo.vars.bools[splitVals[1]] <- ((int( splitVals[2] ) != 0) || (splitVals[2] == "true"))
				break

			case "string":
				newInfo.vars.strings[splitVals[1]] <- splitVals[2]
				break

			case "image":
				newInfo.vars.images[splitVals[1]] <- CastStringToAsset( splitVals[2] )
				break

			case "float3":
				newInfo.vars.float3s[splitVals[1]] <- CastStringToFloat3( splitVals[2] )
				break

			case "float2":
				newInfo.vars.float2s[splitVals[1]] <- CastStringToFloat3( splitVals[2] )
				break

			default:
				Assert( false, format( "Unhandled field type '%s'.", splitVals[0] ) )
				break
		}
	}
}

void function ClApexScreens_AddScreenOverride( ScreenOverrideInfo newInfo )
{
	s_screenOverrides[newInfo.scriptNameRequired] <- newInfo
}


ApexScreenState function ClApexScreens_GetCustomBannerScreen( string teaseScreenKey )
{
	return file.customBannerList[ teaseScreenKey ]
}
#endif // CLIENT


////
////
//// Server-side screen scheduler
////
////

#if SERVER
void function SvApexScreens_ForceShowSquad( EncodedEHandle ply0, EncodedEHandle ply1, EncodedEHandle ply2 )
{
	#if DEVELOPER
		if ( file.DEV_inDebugPreviewMode )
			return
	#endif

	ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, ply0 )
	ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, ply1 )
	ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, ply2 )
	thread ApexScreenMasterThink()
}
#endif


#if SERVER
void function SvApexScreens_ShowCircleState()
{
	#if DEVELOPER
		if ( file.DEV_inDebugPreviewMode )
			return
	#endif
	// todo(dw): re-enable
	//ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.CIRCLE_STATE, null )
	//ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.CIRCLE_STATE, null )
	//ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.CIRCLE_STATE, null )
	//thread ApexScreenMasterThink()
}
#endif


#if SERVER
void function SvApexScreens_HighlightPlayerForImpressiveKill( entity player, int damageSourceID, float distanceBetweenPlayers, int killedPlayerGrade, entity killedPlayer )
{
	#if DEVELOPER
		if ( file.DEV_inDebugPreviewMode )
			return
	#endif

	if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
		return

	foreach ( entity playerToInform in GetPlayerArray() )
		Remote_CallFunction_Replay( playerToInform, "ServerToClient_ApexScreenKillDataChanged", damageSourceID, distanceBetweenPlayers, killedPlayerGrade, killedPlayer )

	// todo(dw): re-enable
	//ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.LOGO, null )
	//ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, null )
	//ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.LOGO, null )
	//thread ApexScreenMasterThink()
}
#endif


#if SERVER
void function SvApexScreens_HighlightPlayerForKillSpree()
{
	#if DEVELOPER
		if ( file.DEV_inDebugPreviewMode )
			return
	#endif
	// todo(dw)
}
#endif


#if SERVER
void function ShowModeInternal( int screenPosition, int transitionStyle, int mode, EncodedEHandle playerEEH )
{
	return
	if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
		return

	Assert( screenPosition < eApexScreenPosition._COUNT_BANNERTYPES )
	SetGlobalNetTime( format( "ApexScreensMasterState_Pos%d_CommenceTime", screenPosition ), Time() )
	SetGlobalNetInt( format( "ApexScreensMasterState_Pos%d_ModeIndex", screenPosition ), mode )
	SetGlobalNetInt( format( "ApexScreensMasterState_Pos%d_TransitionStyle", screenPosition ), transitionStyle )
	SetGlobalNetInt( format( "ApexScreensMasterState_Pos%d_Player", screenPosition ), playerEEH ) // todo(dw)
}
#endif


#if SERVER
void function EntitiesDidLoadSv()
{
	if ( IsLobby() )
		return

	foreach ( entity targetInfo in GetEntArrayByScriptName( "apex_screen" ) )
	{
		// (dw): These are not needed now but may be in the future. Either way, we should destroy them after load to
		// save on edicts.
		targetInfo.Destroy()
	}

	thread ApexScreenMasterThink()
}
#endif


#if SERVER
void function OnGameStatePostEnter_PickLoadout()
{
	thread ApexScreenMasterThink()
}
#endif


#if SERVER
void function OnGameStatePostEnter_Prematch()
{
	thread ApexScreenMasterThink()
}
#endif


#if SERVER
void function HaltApexScreenMasterThink()
{
	svGlobal.levelEnt.Signal( "ApexScreenMasterThink" )
}
void function ApexScreenMasterThink()
{
	// todo(dw): this kind of think function with arbitrary waits is temp
	if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
		return

	HaltApexScreenMasterThink()
	svGlobal.levelEnt.EndSignal( "ApexScreenMasterThink" )

	#if DEVELOPER
		if ( file.DEV_inDebugPreviewMode )
			return
	#endif

	Assert( !IsLobby() )

	table<ItemFlavor, bool> previousChosenCharacterSet

	int lastGameState = -1
	int idx = 0
	while ( true )
	{
		if ( lastGameState != GetGameState() )
		{
			idx = 0
			lastGameState = GetGameState()
		}

		ApexScreenSettingsGroup ornull data

		if ( file.queuedScreenSettings.len() > 0 )
		{
			data = file.queuedScreenSettings[ 0 ]
			file.queuedScreenSettings.remove( 0 )
		}

		if ( data == null )
		{
			if ( !( GetGameState() in file.gameStateToScreenSettings ) || file.gameStateToScreenSettings[ GetGameState() ].len() == 0 )
			{
				wait 0.3
				continue
			}
			idx = idx % file.gameStateToScreenSettings[ GetGameState() ].len()

			data = file.gameStateToScreenSettings[ GetGameState() ][ idx ]
		}

		expect ApexScreenSettingsGroup( data )

		switch ( data.displayMode )
		{
			case eApexScreenDisplayGroup.DISPLAY_RANDOM_PLAYERS:
				array<entity> allPlayers = GetPlayerArray()
				if ( allPlayers.len() == 0 )
				{
					wait 0.5
					break
				}

				LoadoutEntry characterSlot = Loadout_Character()

				array<EncodedEHandle> randomPlayerOrNullList
				table<ItemFlavor, bool> chosenCharacterSet
				for ( int tries = 0; randomPlayerOrNullList.len() < 3 && tries < 200; tries++ )
				{
					entity candidate = allPlayers.getrandom()

					if ( LoadoutSlot_IsReady( ToEHI( candidate ), characterSlot ) )
					{
						ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( candidate ), characterSlot )

						if ( character in chosenCharacterSet )
							continue

						if ( character in previousChosenCharacterSet )
							continue

						chosenCharacterSet[character] <- true
						randomPlayerOrNullList.append( candidate.GetEncodedEHandle() )
					}
				}
				randomPlayerOrNullList.resize( 3, EncodedEHandle_null )
				previousChosenCharacterSet = chosenCharacterSet

				ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, randomPlayerOrNullList[0] )
				ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, randomPlayerOrNullList[1] )
				ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, randomPlayerOrNullList[2] )
				wait data.duration
				break

			case eApexScreenDisplayGroup.DISPLAY_LOGOS:
				_DisplayLogos( data.duration )
				break

			case eApexScreenDisplayGroup.DISPLAY_PLAYER:
				EncodedEHandle playerEEH    = data.getFocusPlayerFunc()
				int expectedSquadSizeChampion = GetExpectedSquadSize( GetEntityFromEncodedEHandle( playerEEH ) )

				int L_screen = data.overrideScreen_L <= -1 ? eApexScreenMode.PLAYER_NAME_CHAMPION : data.overrideScreen_L
				int C_screen = data.overrideScreen_C <= -1 ? eApexScreenMode.GCARD_FRONT_CLEAN : data.overrideScreen_C
				int R_screen = data.overrideScreen_R <= -1 ? eApexScreenMode.GCARD_BACK : data.overrideScreen_R

				if ( playerEEH != EncodedEHandle_null )
				{
					ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, L_screen, playerEEH )
					ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, C_screen, playerEEH )
					ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, R_screen, playerEEH )
					wait data.duration
				}
				else
				{
					_DisplayLogos( 4.5 )
				}
				break

			case eApexScreenDisplayGroup.DISPLAY_LOCALPLAYER:
				int L_screen = data.overrideScreen_L <= -1 ? eApexScreenMode.LOGO : data.overrideScreen_L
				int C_screen = data.overrideScreen_C <= -1 ? eApexScreenMode.GCARD_FRONT_DETAILS : data.overrideScreen_C
				int R_screen = data.overrideScreen_R <= -1 ? eApexScreenMode.LOGO : data.overrideScreen_R

				_SetLogoDisplay()
				ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, C_screen, EHI_LOCALSELF )
				wait data.duration
				break

			case eApexScreenDisplayGroup.DISPLAY_RANDOM_LOCALTEAMMATE:
				int L_screen = data.overrideScreen_L <= -1 ? eApexScreenMode.LOGO : data.overrideScreen_L
				int C_screen = data.overrideScreen_C <= -1 ? eApexScreenMode.GCARD_FRONT_DETAILS : data.overrideScreen_C
				int R_screen = data.overrideScreen_R <= -1 ? eApexScreenMode.LOGO : data.overrideScreen_R

				_SetLogoDisplay()
				ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, C_screen, EHI_LOCALTEAMMATE_RANDOM )
				wait data.duration
				break

			case eApexScreenDisplayGroup.DISPLAY_PLAYER_SQUAD:
			case eApexScreenDisplayGroup.DISPLAY_PLAYER_SQUAD_CENTERED:
				EncodedEHandle playerEEH    = data.getFocusPlayerFunc()
				int expectedSquadSizeChampion = GetExpectedSquadSize( GetEntityFromEncodedEHandle( playerEEH ) )

				array<EncodedEHandle> squad = GetPlayerSquadSafe( playerEEH, 3 ) // todo(dw): hard-coded squad size?

				// Centered version must have null EHIs removed.
				if( data.displayMode == eApexScreenDisplayGroup.DISPLAY_PLAYER_SQUAD_CENTERED )
				{
					foreach( squadEHI in squad)
					{
						if( squadEHI == EncodedEHandle_null )
						{
							squad.removebyvalue( squadEHI )
						}
					}
					expectedSquadSizeChampion = squad.len()
				}

				if ( playerEEH != EncodedEHandle_null )
				{
					if ( expectedSquadSizeChampion == 1 )
					{
						_SetLogoDisplay()
						ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.FADE_TO_BLACK, eApexScreenMode.GCARD_FRONT_DETAILS, playerEEH )
					}
					if ( expectedSquadSizeChampion == 2 )
					{
						_SetLogoDisplay()
						ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.FADE_TO_BLACK, eApexScreenMode.GCARD_FRONT_DETAILS, playerEEH )
						ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.FADE_TO_BLACK, eApexScreenMode.GCARD_FRONT_DETAILS, squad[1] )
					}
					else if( expectedSquadSizeChampion > 2 )
					{
						ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.FADE_TO_BLACK, eApexScreenMode.GCARD_FRONT_DETAILS, squad[1] )
						ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.NONE, eApexScreenMode.GCARD_FRONT_DETAILS, playerEEH )
						ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.FADE_TO_BLACK, eApexScreenMode.GCARD_FRONT_DETAILS, squad[2] )
					}
					wait data.duration
				}
				else
				{
					_DisplayLogos( 4.5 )
				}
				break
		}

		idx++
	}
}

void function _DisplayLogos( float duration )
{
	_SetLogoDisplay()
	wait duration
}

void function _SetLogoDisplay()
{
	int sideLogo = file.logoModeCenterOnly ? eApexScreenMode.BG_NO_LOGO : eApexScreenMode.LOGO

	ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, sideLogo, EncodedEHandle_null )
	ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.LOGO, EncodedEHandle_null )
	ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, sideLogo, EncodedEHandle_null )
}
#endif


#if SERVER && DEVELOPER
void function DEV_ApexScreens_TogglePreviewMode()
{
	file.DEV_inDebugPreviewMode = !file.DEV_inDebugPreviewMode
	printt( "Apex Screen Preview Mode: " + (file.DEV_inDebugPreviewMode ? "ON" : "OFF") )
}
#endif


#if SERVER && DEVELOPER
void function DEV_ApexScreens_GladCardPreviewMode()
{
	file.DEV_inDebugPreviewMode = true

	array<entity> testArray = GetPlayerArray()

	HaltApexScreenMasterThink()

	//ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, testArray[RandomIntRange( 0, testArray.len() )] )
	//ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, GetPlayerArray()[0] )
	//ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_DETAILS, testArray[RandomIntRange( 0, testArray.len() )] )

	ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.PLAYER_NAME_KILLLEADER, GetPlayerArray()[0].GetEncodedEHandle() )
	ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_FRONT_CLEAN, GetPlayerArray()[0].GetEncodedEHandle() )
	ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, eApexScreenMode.GCARD_BACK, GetPlayerArray()[0].GetEncodedEHandle() )
}
#endif


#if SERVER && DEVELOPER
void function DEV_ApexScreens_SetMode( var opt = "random" )
{
    if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
        return

	int currentMode = GetGlobalNetInt( "ApexScreensMasterState_Pos1_ModeIndex" ) // just use center screen
	int nextMode
	if ( opt == "random" )
		nextMode = RandomIntRange( 0, eApexScreenMode._COUNT )
	else if ( opt == "next" )
		nextMode = modint( currentMode + 1, eApexScreenMode._COUNT )
	else if ( opt == "prev" )
		nextMode = modint( currentMode - 1, eApexScreenMode._COUNT )
	else if ( type( opt ) == "string" )
		nextMode = eApexScreenMode[string(opt).toupper()]
	else
		nextMode = int(opt)

	array<entity> testArray = GetPlayerArray()
	entity firstPlayer = null
	if ( testArray.len() > 0 )
		firstPlayer = testArray[0]

	testArray.append( null )

	HaltApexScreenMasterThink()
	ShowModeInternal( eApexScreenPosition.L, eApexScreenTransitionStyle.SLIDE, nextMode, EHIToEncodedEHandle( testArray[RandomIntRange( 0, testArray.len() )] ) )
	ShowModeInternal( eApexScreenPosition.C, eApexScreenTransitionStyle.NONE, nextMode, EHIToEncodedEHandle( firstPlayer ) )
	ShowModeInternal( eApexScreenPosition.R, eApexScreenTransitionStyle.SLIDE, nextMode, EHIToEncodedEHandle( testArray[RandomIntRange( 0, testArray.len() )] ) )

	printt( "Apex Screen Mode: " + GetEnumString( "eApexScreenMode", nextMode ) )
}
#endif



////
////
//// Client-side screen state management
////
////

//#if CLIENT
//void function ClApexScreens_Lobby_SetMode( int modeIndex )
//{
//	Assert( IsLobby() )
//
//	file.masterState.modeIndex = modeIndex
//	UpdateAllScreensContent()
//}
//#endif
//
//
//#if CLIENT
//void function ClApexScreens_Lobby_SetCardOwner( int index, entity owner )
//{
//	Assert( IsLobby() )
//
//	switch ( index )
//	{
//		case 0: file.masterState.player0 = owner; break
//
//		case 1: file.masterState.player1 = owner; break
//
//		case 2: file.masterState.player2 = owner; break
//	}
//	UpdateAllScreensContent()
//}
//#endif


#if CLIENT
void function ClApexScreens_DisableAllScreens()
{
	Assert( !file.forceDisableScreens )
	file.forceDisableScreens = true
	UpdateAllScreensContent()
}
#endif


#if CLIENT
void function ClApexScreens_EnableAllScreens()
{
	Assert( file.forceDisableScreens )
	file.forceDisableScreens = false
	UpdateAllScreensContent()
}
#endif

#if CLIENT
bool function ClApexScreens_IsDisabled()
///asdfasdf
{
	return file.forceDisableScreens
}
#endif

#if CLIENT
void function UpdateAllScreensContent()
{
	if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
		return

	// todo(dw): make this run when switching spectator targets

	if ( !IsValid( clGlobal.levelEnt ) )
		return // this can be called before scripts have finished initializing

	if ( file.allScreenUpdateQueued )
		return
	file.allScreenUpdateQueued = true

	thread UpdateAllScreensContentThread()
}
void function UpdateAllScreensContentThread()
{
	WaitEndFrame()
	file.allScreenUpdateQueued = false
	UpdateScreensContent( file.staticScreenList )
}

//
void function OnUpdateApexScreensEventTime( float newTime )
{
	printf( "%s() - New time: %.2f", FUNC_NAME(), newTime )

	if ( newTime < 0 )
	{
		bool didChange = false
		foreach ( ApexScreenState screen in file.staticScreenList )
		{
			if ( screen.ruiToCreateOrig != $"" )
			{
				screen.overrideInfoIsValid = false
				screen.ruiToCreate = screen.ruiToCreateOrig
				didChange = true
			}
		}

		if ( didChange )
			UpdateAllScreensContent()
		return
	}

	foreach ( ApexScreenState screen in file.staticScreenList )
	{

		if ( !(screen.position in file.eventScreenOverrideByScreenPosTable) )
			continue

		ScreenOverrideInfo screenOverrideInfo = file.eventScreenOverrideByScreenPosTable[ screen.position ]

		screen.overrideInfoIsValid = true

		if ( screen.ruiToCreateOrig == $"" )
			screen.ruiToCreateOrig = screen.ruiToCreate

		screen.overrideInfo = screenOverrideInfo
		screen.ruiToCreate = screenOverrideInfo.ruiAsset
		screen.overrideInfo.vars.gametimes["eventTriggerTime"] <- GetGlobalNetTime( NV_ApexScreensEventTimeA )
	}

	UpdateAllScreensContent()
}

void function ClApexScreens_OnStaticPropRuiVisibilityChange( array<int> newlyVisible, array<int> newlyHidden )
{
	array<ApexScreenState> screensToUpdate = []

	foreach ( int magicId in newlyHidden )
	{
		if ( !(magicId in file.magicIdScreenStateMap) )
			continue // not an apex screen

		ApexScreenState screen = file.magicIdScreenStateMap[magicId]

		Assert( screen.visibleInPVS )

		screen.visibleInPVS = false
		screensToUpdate.append( screen )
	}

	foreach ( int magicId in newlyVisible )
	{
		if ( !(magicId in file.magicIdScreenStateMap) )
			continue // not an apex screen

		ApexScreenState screen = file.magicIdScreenStateMap[magicId]

		Assert( !screen.visibleInPVS )

		screen.visibleInPVS = true
		screensToUpdate.append( screen )
	}

	UpdateScreensContent( screensToUpdate )
}
#endif


#if CLIENT && DEVELOPER
void function DEV_ToggleActiveApexScreenDebug()
{
	file.DEV_activeScreenDebug = !file.DEV_activeScreenDebug
	thread DEV_ActiveApexScreenDebugThread()
}
void function DEV_ActiveApexScreenDebugThread()
{
	RegisterSignal( "DEV_ActiveApexScreenDebugThread" )
	Signal( clGlobal.levelEnt, "DEV_ActiveApexScreenDebugThread" )
	EndSignal( clGlobal.levelEnt, "DEV_ActiveApexScreenDebugThread" )

	const float interval = 0.3

	while ( file.DEV_activeScreenDebug )
	{
		wait interval

		int totalCount = 0, activeCount = 0, activeTVCount = 0
		foreach ( ApexScreenState screen in file.staticScreenList )
		{
			totalCount += 1

			if ( screen.visibleInPVS )
			{
				activeCount += 1
				DebugDrawRotatedBox( <0, 0, 0>, screen.spawnMins + <-1, -1, -3>, screen.spawnMaxs + <-1, -1, -3>, <0, 0, 0>, 140, 185, 255, true, interval + 0.1 )
			}
			else
			{
				DebugDrawRotatedBox( <0, 0, 0>, screen.spawnMins + <-1, -1, -3>, screen.spawnMaxs + <-1, -1, -3>, <0, 0, 0>, 25, 25, 80, true, interval + 0.1 )
			}
		}
		printt( "ACTIVE SCREEN COUNT: " + activeCount + " (of " + totalCount + ") (" + activeTVCount + " TVs)" )
	}
}
#endif


#if CLIENT
bool function ClApexScreens_PosInStaticBanner( vector pos )
{
	foreach ( magicId, screen in file.magicIdScreenStateMap )
	{
		if ( !screen.visibleInPVS )
			continue

		if ( PointIsWithinBounds( pos, screen.spawnMins, screen.spawnMaxs ) )
		{
			return true
		}
	}
	return false
}

var function CreateBlankApexScreenRUIElement( ApexScreenState screen )
{
	var rui

	if ( screen.magicId != -1 )
	{
		StaticPropRui propStaticRuiInfo
		propStaticRuiInfo.ruiName = BLANK_ASSET
		propStaticRuiInfo.magicId = screen.magicId
		rui = RuiCreateOnStaticProp( propStaticRuiInfo )

		screen.ruiLastCreated = BLANK_ASSET

		RuiSetFloat2( rui, "uvMin", screen.uvMin )
		RuiSetFloat2( rui, "uvMax", screen.uvMax )

		return rui
	}

	return null
}

void function RuiDestroyIfAliveDelay_Thread( var rui, float delayTime )
{
	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroyIfAlive( rui )
		}
	)

	wait delayTime
}

struct DelayedScreenContentData
{
	int              serialNum
	ApexScreenState& screen
	float            modeChangeTime
	int              transitionStyle
	int              gcardPresentation
	EHI              playerEHI
	int              lifestateOverride
}

void function UpdateScreensContent( array<ApexScreenState> screenList )
{
	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	array<DelayedScreenContentData> delayedData = []

	entity localViewPlayer = GetLocalViewPlayer()
	bool isCrypto          = PlayerHasPassive( localViewPlayer, ePassives.PAS_CRYPTO )
                               
	bool activeCamera      = IsValid( localViewPlayer.p.cryptoActiveCamera )
      
                                                                            
       

	foreach ( ApexScreenState screen in screenList )
	{
		bool shouldShow = true

		if ( file.forceDisableScreens )
			shouldShow = false
		else if ( !screen.visibleInPVS )
			shouldShow = false
		else if ( screen.position == eApexScreenPosition.DISABLED )
			shouldShow = false
		else if ( screen.isOutsideCircle )
			shouldShow = false

		bool needShutdown = ((screen.rui != null && screen.ruiLastCreated != BLANK_ASSET) && (!shouldShow || (screen.ruiToCreate != screen.ruiLastCreated)))
		if ( needShutdown )
		{
			screen.commenceTime = -1.0
			Signal( screen, "ScreenOff" ) // to clean up any threads expecting the RUI to exist

			CleanupNestedGladiatorCard( screen.nestedGladiatorCard0Handle )

			if ( screen.nestedRui != null )
			{
				RuiDestroyNestedIfAlive( screen.rui, "animatedLogoHandle" )
				screen.nestedRui = null
			}

			#if NX_PROG
				thread RuiDestroyIfAliveDelay_Thread( screen.rui, 0.4 )
				screen.rui = CreateBlankApexScreenRUIElement( screen )
				if( screen.rui != null )
					RuiSetGameTime( screen.rui, "transitionInStartTime", Time() )
			#else
				RuiDestroyIfAlive( screen.rui )
				screen.rui = null
			#endif
		}

		bool doStandardVars = (!screen.overrideInfoIsValid || !screen.overrideInfo.skipStandardVars)

		bool needStartup = (shouldShow && (screen.rui == null || screen.ruiLastCreated == BLANK_ASSET))

		if ( needStartup )
		{
			#if NX_PROG
				if ( screen.rui != null )
				{
					RuiDestroyIfAlive( screen.rui )
				}
			#endif

			screen.rui = CreateApexScreenRUIElement( screen )
			if ( screen.rui != null )
			{
				if ( doStandardVars )
					screen.nestedGladiatorCard0Handle = CreateNestedGladiatorCard( screen.rui, "card0", eGladCardDisplaySituation.APEX_SCREEN_STILL, eGladCardPresentation.OFF )
			}
			else
			{
				shouldShow = false
			}

			#if NX_PROG
				var tmpRui = CreateBlankApexScreenRUIElement( screen )
				if( tmpRui != null )
					RuiSetGameTime( tmpRui, "transitionOutStartTime", Time() )
				thread RuiDestroyIfAliveDelay_Thread( tmpRui, 0.4 )

				screen.ruiLastCreated = screen.ruiToCreate
			#endif
		}

		if ( !shouldShow )
			continue
		if ( !doStandardVars )
			continue
		#if NX_PROG
			if ( screen.ruiLastCreated == BLANK_ASSET )
				continue
		#endif

		ApexScreenPositionMasterState masterState = file.screenPositionMasterStates[screen.position]
		float desiredCommenceTime                 = masterState.commenceTime
		int desiredMode                           = masterState.modeIndex
		int desiredTransitionStyle                = masterState.transitionStyle
		EHI desiredPlayerEHI                      = masterState.playerEHI

                                
		if ( desiredCommenceTime == screen.commenceTime && !activeCamera )
       
                                                                
        
			continue

		if ( isCrypto )
			RuiSetFloat( screen.rui, "cryptoHintAlpha", 1.0 )
		else
			RuiSetFloat( screen.rui, "cryptoHintAlpha", 0.0 )

                                
		if ( activeCamera )
       
                 
        
		{
			desiredMode = eApexScreenMode.CAMERA_VIEW
			desiredTransitionStyle = eApexScreenTransitionStyle.NONE
			desiredCommenceTime = -1
		}

		screen.commenceTime = desiredCommenceTime

		RuiSetGameTime( screen.rui, "commenceTime", desiredCommenceTime )
		RuiSetInt( screen.rui, "modeIndex", desiredMode )
		RuiSetInt( screen.rui, "transitionStyle", desiredTransitionStyle )

		int lifestateOverride = eGladCardLifestateOverride.NONE
		int gcardPresentation = GetGCardPresentationForApexScreenMode( desiredMode )

		screen.updateSerialNum = modint( screen.updateSerialNum + 1, INT_MAX )

		DelayedScreenContentData dscd
		dscd.serialNum = screen.updateSerialNum
		dscd.modeChangeTime = screen.commenceTime
		if ( dscd.transitionStyle != eApexScreenTransitionStyle.NONE )
			dscd.modeChangeTime += APEX_SCREEN_TRANSITION_IN_DURATION
		dscd.screen = screen
		dscd.transitionStyle = desiredTransitionStyle
		dscd.gcardPresentation = gcardPresentation

		dscd.playerEHI = desiredPlayerEHI
		if( dscd.playerEHI == EHI_LOCALSELF )
		{
			dscd.playerEHI = GetLocalViewPlayer().GetEncodedEHandle()
		}
		else if( dscd.playerEHI == EHI_LOCALTEAMMATE_RANDOM )
		{
			array< entity > teammates = GetPlayerArrayOfTeam( GetLocalViewPlayer().GetTeam() )
			teammates.randomize()

			foreach( player in teammates )
			{
				if( IsValid( player ) )
				{
					dscd.playerEHI = player.GetEncodedEHandle()
					break
				}
			}
		}

		dscd.lifestateOverride = lifestateOverride
		delayedData.append( dscd )
	}

	thread (void function() : (delayedData) {
		delayedData.sort( int function( DelayedScreenContentData a, DelayedScreenContentData b ) {
			return (a.modeChangeTime == b.modeChangeTime) ? 0 : (a.modeChangeTime < b.modeChangeTime) ? -1 : 1
		} )
		foreach ( DelayedScreenContentData dscd in delayedData )
		{
			if ( dscd.screen.updateSerialNum != dscd.serialNum )
				continue

			if ( dscd.modeChangeTime - Time() > 0.02 )
				wait (dscd.modeChangeTime - Time())

			if ( dscd.screen.updateSerialNum != dscd.serialNum )
				continue

			// Account for the case where the rui has been destroyed outside of the thread (see needShutdown above)
			if ( dscd.screen.rui == null )
				continue

			UpdateScreenDetails( dscd.screen, dscd.modeChangeTime, dscd.transitionStyle, dscd.gcardPresentation, dscd.playerEHI, dscd.lifestateOverride )
		}
	})()
}
#endif


#if CLIENT
int function GetGCardPresentationForApexScreenMode( int screenMode )
{
	switch( screenMode )
	{
		case eApexScreenMode.GCARD_FRONT_CLEAN:
			return eGladCardPresentation.FRONT_CLEAN

		case eApexScreenMode.GCARD_FRONT_DETAILS:
			return eGladCardPresentation.FRONT_DETAILS

		case eApexScreenMode.GCARD_BACK:
			return eGladCardPresentation.BACK
	}

	return eGladCardPresentation.OFF
}
#endif


#if CLIENT
void function UpdateScreenDetails( ApexScreenState screen, float modeChangeTime, int transitionStyle, int gcardPresentation, EHI playerEHI, int lifestateOverride )
{
	string playerName = ""
	int playerEHI_ToUse = playerEHI

	if( playerEHI_ToUse == EHI_LOCALSELF )
	{
		playerEHI_ToUse = GetLocalViewPlayer().GetEncodedEHandle()
	}
	else if( playerEHI_ToUse == EHI_LOCALTEAMMATE_RANDOM )
	{
		array< entity > teammates = GetPlayerArrayOfTeam( GetLocalViewPlayer().GetTeam() )
		teammates.randomize()

		foreach( player in teammates )
		{
			if( IsValid( player ) )
			{
				playerEHI_ToUse = player.GetEncodedEHandle()
				break
			}
		}
	}

	if ( EHIHasValidScriptStruct( playerEHI_ToUse ) )
		playerName = GetPlayerNameUnlessAnonymized( playerEHI_ToUse ) //EHI_GetName( playerEHI )
	RuiSetString( screen.rui, "playerName", playerName )

	entity player = FromEHI( playerEHI_ToUse ) // todo(dw): cache kills
	if ( IsValid( player ) )
		RuiTrackInt( screen.rui, "playerKillCount", player, RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "kills" ) )

	RuiSetFloat( screen.rui, "xpBonusAmount", XpEventTypeData_GetAmount( eXPType.KILL_CHAMPION_MEMBER ) )

	ChangeNestedGladiatorCardPresentation( screen.nestedGladiatorCard0Handle, gcardPresentation )
	ChangeNestedGladiatorCardOwner( screen.nestedGladiatorCard0Handle, playerEHI, modeChangeTime, lifestateOverride )
}
#endif


#if CLIENT
void function ClientStaticPropRUICreated( StaticPropRui propRui, var ruiInstance )
{
	if ( !(propRui.magicId in file.environmentalRUIListMapByMagicId) )
	{
		file.environmentalRUIListMapByMagicId[propRui.magicId] <- []
	}
	file.environmentalRUIListMapByMagicId[propRui.magicId].append( ruiInstance )
}
#endif


#if CLIENT
void function SetupForHorizontalTVScreen( StaticPropRui staticPropRuiInfo, ApexScreenState apexScreen )
{
	if ( staticPropRuiInfo.scriptName in s_screenOverrides )
	{
		apexScreen.overrideInfo = s_screenOverrides[staticPropRuiInfo.scriptName]
		apexScreen.overrideInfoIsValid = true
		apexScreen.ruiToCreate = apexScreen.overrideInfo.ruiAsset
		apexScreen.position = eApexScreenPosition.TV_LIKE
		return
	}

	apexScreen.position = eApexScreenPosition.DISABLED
}


void function SetupForVerticalBannerScreen( StaticPropRui staticPropRuiInfo, ApexScreenState apexScreen )
{
	if ( staticPropRuiInfo.scriptName in s_screenOverrides )
	{
		apexScreen.overrideInfo = s_screenOverrides[staticPropRuiInfo.scriptName]
		apexScreen.overrideInfoIsValid = true
		apexScreen.ruiToCreate = apexScreen.overrideInfo.ruiAsset

		if ( apexScreen.position > eApexScreenPosition._COUNT_BANNERTYPES )
			apexScreen.position = eApexScreenPosition.TV_LIKE

		return
	}

	//apexScreen.position = eApexScreenPosition.DISABLED
}


bool function OnEnumStaticPropRui( StaticPropRui staticPropRuiInfo )
{
	if ( !GetCurrentPlaylistVarBool( "enable_apex_screens", true ) )
		return (staticPropRuiInfo.mockupName.find( "apex_screen" ) != -1)
	//printt( "STATIC RUI", staticPropRuiInfo.magicId, "SCRIPTNAME:" + staticPropRuiInfo.scriptName, "MOCKUP:" + staticPropRuiInfo.mockupName, "MODEL:" + staticPropRuiInfo.modelName, "RUI:" + staticPropRuiInfo.ruiName )

	ApexScreenState apexScreen
	apexScreen.magicId = staticPropRuiInfo.magicId
	apexScreen.rui = null
	apexScreen.spawnOrigin = staticPropRuiInfo.spawnOrigin
	apexScreen.spawnForward = Normalize( staticPropRuiInfo.spawnForward )
	apexScreen.spawnRight = Normalize( staticPropRuiInfo.spawnRight )
	apexScreen.spawnUp = Normalize( staticPropRuiInfo.spawnUp )
	apexScreen.spawnScale = Length( staticPropRuiInfo.spawnForward )
	apexScreen.spawnMins = staticPropRuiInfo.spawnMins
	apexScreen.spawnMaxs = staticPropRuiInfo.spawnMaxs
	apexScreen.ruiToCreate = $"ui/apex_screen.rpak"
	apexScreen.mockup = staticPropRuiInfo.mockupName
	apexScreen.diagonalSize = Distance( staticPropRuiInfo.spawnMins, staticPropRuiInfo.spawnMaxs )

	float tintIntensity = RandomFloatRange( APEX_SCREEN_RANDOM_TINT_INTENSITY_MIN, APEX_SCREEN_RANDOM_TINT_INTENSITY_MAX )
	apexScreen.tint = tintIntensity * APEX_SCREEN_RANDOM_TINT_PALETTE[RandomInt( APEX_SCREEN_RANDOM_TINT_PALETTE.len() )]

	if ( "apex_screen_mods" in staticPropRuiInfo.args )
	{
		string modsStr = staticPropRuiInfo.args.apex_screen_mods
		apexScreen.modBits = 0
		foreach ( string modKey in GetTrimmedSplitString( modsStr, "," ) )
		{
			if ( modKey.toupper() in eApexScreenMods )
				apexScreen.modBits = apexScreen.modBits | eApexScreenMods[modKey.toupper()]
			else
				Warning( "Apex screen at " + apexScreen.spawnOrigin + " has unknown mod '" + modKey.toupper() + "' (" + modsStr + ")" )
		}
	}

	// NOTE: model names used to have random backslashes in them. I changed them to always have forward slashes, but I left both ways in here to keep compatibility.
	// When the slash change has had time to settle, we should remove the backslash versions.
	bool needsScreenPositionSetup = true
	switch( staticPropRuiInfo.modelName )
	{
		case "mdl/olympus/path_tt_screen_01_off.rmdl":
		case "mdl/eden/beacon_small_screen_02_off.rmdl":
		case "mdl/olympus\\path_tt_screen_01_off.rmdl":
		case "mdl/eden\\beacon_small_screen_02_off.rmdl":
			apexScreen.uvMin = <0.0, 0.295, 0.0>
			apexScreen.uvMax = <1.0, 0.705, 0.0>
			SetupForHorizontalTVScreen( staticPropRuiInfo, apexScreen )
			needsScreenPositionSetup = false
			break

		case "mdl/thunderdome/apex_screen_05.rmdl":
		case "mdl/thunderdome\\apex_screen_05.rmdl":
			apexScreen.uvMin = <0.235, 0.0, 0.0>
			apexScreen.uvMax = <0.765, 1.0, 0.0>
			break

		case "mdl/thunderdome/survival_modular_flexscreens_01.rmdl":
		case "mdl/thunderdome/survival_modular_flexscreens_02.rmdl":
		case "mdl/thunderdome/survival_modular_flexscreens_03.rmdl":
		case "mdl/thunderdome/survival_modular_flexscreens_04.rmdl":
		case "mdl/thunderdome\\survival_modular_flexscreens_01.rmdl":
		case "mdl/thunderdome\\survival_modular_flexscreens_02.rmdl":
		case "mdl/thunderdome\\survival_modular_flexscreens_03.rmdl":
		case "mdl/thunderdome\\survival_modular_flexscreens_04.rmdl":
			apexScreen.uvMin = <0.323, 0.0, 0.0>
			apexScreen.uvMax = <0.684, 1.0, 0.0>
			break

		case "mdl/thunderdome/survival_modular_flexscreens_05.rmdl":
		case "mdl/thunderdome\\survival_modular_flexscreens_05.rmdl":
			apexScreen.uvMin = <0.0, 0.215, 0.0>
			apexScreen.uvMax = <1.0, 0.785, 0.0>
			break

		default:
			return false // don't block default, we're not going to put any apex screen stuff on this prop
			//apexScreen.sharesPropWithEnvironmentalRUI = true
			//apexScreen.isVideoOnly = true
			//apexScreen.uvMin = <0.0, 0.0, 0.0>
			//apexScreen.uvMax = <1.0, 1.0, 0.0>
			break
	}

	if ( needsScreenPositionSetup )
	{
		float uvWidth           = (apexScreen.uvMax.x - apexScreen.uvMin.x)
		float uvHeight          = (apexScreen.uvMax.y - apexScreen.uvMin.y)
		float screenAspectRatio = (uvHeight < 0.0001) ? 0.0 : uvWidth / uvHeight
		bool isVertical         = (screenAspectRatio < 1.1)
		if ( !isVertical )
		{
			//apexScreen.screenPosition = eApexScreenPosition.TV_LIKE
			apexScreen.position = eApexScreenPosition.DISABLED
		}
		else
		{
			switch( staticPropRuiInfo.scriptName )
			{
				case "leftScreen":
					apexScreen.position = eApexScreenPosition.L
					break

				case CUSTOM_BANNER_LEFT_SCRIPTNAME:
					apexScreen.position = eApexScreenPosition.L
					SetupForVerticalBannerScreen( staticPropRuiInfo, apexScreen )
					file.customBannerList["left"] <- apexScreen
					break

				case "rightScreen":
					apexScreen.position = eApexScreenPosition.R
					break

				case CUSTOM_BANNER_RIGHT_SCRIPTNAME:
					apexScreen.position = eApexScreenPosition.R
					SetupForVerticalBannerScreen( staticPropRuiInfo, apexScreen )
					file.customBannerList["right"] <- apexScreen
					break

				case CUSTOM_BANNER_CENTER_SCRIPTNAME:
					apexScreen.position = eApexScreenPosition.C
					SetupForVerticalBannerScreen( staticPropRuiInfo, apexScreen )
					file.customBannerList["center"] <- apexScreen
					break

				default:
					apexScreen.position = eApexScreenPosition.C
					break
			}
		}
	}

	Assert( string( apexScreen.ruiToCreate ) != "" )

	file.staticScreenList.append( apexScreen )
	file.magicIdScreenStateMap[apexScreen.magicId] <- apexScreen

	if ( apexScreen.sharesPropWithEnvironmentalRUI )
		return false // don't block default if the model is not an "apex-only" model (it could be showing an ad or a sushi menu, etc)

	return true
}
#endif

#if CLIENT
var function CreateApexScreenRUIElement( ApexScreenState screen )
{
	var rui
	if ( screen.magicId == -1 )
	{
		#if DEVELOPER
			float aspectRatio = 1.0//0.38
			float height      = screen.diagonalSize / sqrt( 1.0 + pow( aspectRatio, 2.0 ) )
			float width       = aspectRatio * height
			vector origin     = screen.spawnOrigin// + <0, 0, -height>
			var topo          = RuiTopology_CreatePlane( origin, <0, width, 0>, <0, 0, -height>, false )

			rui = RuiCreate( screen.ruiToCreate, topo, RUI_DRAW_WORLD, 32767 )
		#else
			return null
		#endif
	}
	else
	{
		StaticPropRui propStaticRuiInfo
		propStaticRuiInfo.ruiName = screen.ruiToCreate
		propStaticRuiInfo.magicId = screen.magicId
		rui = RuiCreateOnStaticProp( propStaticRuiInfo )
	}
	screen.ruiLastCreated = screen.ruiToCreate

	vector basePos = screen.spawnOrigin
	basePos.z -= (screen.spawnMaxs.z - screen.spawnMins.z)

	//DebugDrawAxis( basePos, VectorToAngles( screen.spawnForward ), 25, 5 )
	RuiSetFloat3( rui, "screenWorldPos", basePos )
	RuiSetFloat( rui, "screenScale", screen.spawnScale )
	RuiSetFloat2( rui, "uvMin", screen.uvMin )
	RuiSetFloat2( rui, "uvMax", screen.uvMax )
	RuiSetInt( rui, "screenPosition", screen.position )
	RuiSetInt( rui, "modBits", screen.modBits )
	RuiSetFloat3( rui, "tintColor", screen.tint )
	RuiSetFloat( rui, "tintIntensity", 1.0 )
	RuiSetInt( rui, "unixTimeStamp", GetUnixTimestamp() )
	RuiSetImage( rui, "overlayImg", file.bannerBGAssert )
	RuiSetImage( rui, "logoImage", file.logoImage )
	RuiSetFloat3( rui, "logoTint", file.logoOverlayTint )
	RuiSetFloat2( rui, "logoSize", file.logoSize )

	if ( file.animatedLogoAsset != $"" )
	{
		var nestedRui = RuiCreateNested( rui, "animatedLogoHandle", file.animatedLogoAsset )
		screen.nestedRui = nestedRui
	}

	if ( screen.sharesPropWithEnvironmentalRUI )
		RuiSetBool( rui, "sharesPropWithEnvironmentalRUI", true )

	RuiTrackInt( rui, "cameraNearbyEnemySquads", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "cameraNearbyEnemySquads" ) )

	if ( screen.overrideInfoIsValid )
	{
		foreach ( string varName, int varValue in screen.overrideInfo.vars.ints )
			RuiSetInt( rui, varName, varValue )

		foreach ( string varName, float varValue in screen.overrideInfo.vars.floats )
			RuiSetFloat( rui, varName, varValue )

		foreach ( string varName, bool varValue in screen.overrideInfo.vars.bools )
			RuiSetBool( rui, varName, varValue )

		foreach ( string varName, string varValue in screen.overrideInfo.vars.strings )
			RuiSetString( rui, varName, varValue )

		foreach ( string varName, asset varValue in screen.overrideInfo.vars.images )
			RuiSetImage( rui, varName, varValue )

		foreach ( string varName, vector varValue in screen.overrideInfo.vars.float3s )
			RuiSetFloat3( rui, varName, varValue )

		foreach ( string varName, vector varValue in screen.overrideInfo.vars.float2s )
			RuiSetFloat2( rui, varName, varValue )

		foreach ( string varName, float varValue in screen.overrideInfo.vars.gametimes )
			RuiSetGameTime( rui, varName, varValue )

		if ( screen.overrideInfo.bindStartTimeVarToEventTimeA )
			RuiTrackFloat( rui, "startTime", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL, GetNetworkedVariableIndex( NV_ApexScreensEventTimeA ) )
		if ( screen.overrideInfo.bindStartTimeVarToEventTimeB )
			RuiTrackFloat( rui, "startTime", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL, GetNetworkedVariableIndex( NV_ApexScreensEventTimeB ) )
		if ( screen.overrideInfo.bindEventIntA )
			RuiTrackInt( rui, "intA", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( NV_ApexScreensEventIntA ) )
	}

	return rui
}

void function ClApexScreens_SetCustomApexScreenBGAsset( asset bg )
{
	file.bannerBGAssert = bg
}

void function ClApexScreens_SetCustomLogoTint( vector tint )
{
	file.logoOverlayTint = tint
}

void function ClApexScreens_SetCustomLogoImage( asset logo )
{
	file.logoImage = logo
}

void function ClApexScreens_SetCustomLogoSize( vector l_size )
{
	file.logoSize = l_size
}
void function ClApexScreens_SetAnimatedLogoAsset( asset ruiAsset )
{
	file.animatedLogoAsset = ruiAsset
}

void function ClApexScreens_SetEventScreenOverride( int position, ScreenOverrideInfo screenOverrideInfo )
{
	file.eventScreenOverrideByScreenPosTable[ position ] <- screenOverrideInfo
}
#endif


#if CLIENT && DEVELOPER
void function DEV_CreatePerfectApexScreen( vector origin, float diagonalSize, int screenPosition )
{
	ApexScreenState apexScreen
	apexScreen.magicId = -1
	apexScreen.rui = null
	apexScreen.spawnOrigin = origin
	apexScreen.ruiToCreate = $"ui/apex_screen.rpak"
	apexScreen.diagonalSize = diagonalSize
	apexScreen.position = screenPosition
	apexScreen.uvMin = <0.31, 0.0, 0.0>
	apexScreen.uvMax = <0.69, 1.0, 0.0>

	file.staticScreenList.append( apexScreen )

	UpdateScreensContent( [apexScreen] )
}
#endif



////
////
//// Kill event data
////
////

#if CLIENT
void function ServerToClient_ApexScreenKillDataChanged( int damageSourceID, float distanceBetweenPlayers, int killedPlayerGrade, entity killedPlayer )
{
	file.killScreenDamageSourceID = damageSourceID
	file.killScreenDistance = floor( distanceBetweenPlayers / 12 )
	file.killedPlayerGrade = killedPlayerGrade

	if ( IsValid( killedPlayer ) )
		file.killedPlayerName = killedPlayer.GetPlayerName()

	UpdateAllScreensContent()
}

void function ServerToClient_ApexScreenRefreshAll()
{
	UpdateAllScreensContent()
}
#endif





////
////
//// Work-in-progress scheduler
////
////

//#if CLIENT
//struct ApexScreenSituation
//{
//	bool  required = false
//	float earliestStart = -1.0
//	float latestStart = -1.0
//	float minimumDuration = 0.0
//	float earliestFinish = -1.0
//	float latestFinish = -1.0
//
//	int    mode = eApexScreenMode.INVALID
//	entity player0 = null
//	entity player1 = null
//	entity player2 = null
//}
//#endif
//
//void function OnSurvivalDeathFieldStageChanged( int stage, float nextCircleStartTime )
//{
//	// todo(dw): first circle
//	// todo(dw): last circle
//
//	#if CLIENT
//		ApexScreenSituation sit
//		sit.onlyOnce = false
//		sit.required = true
//		sit.earliestStart = nextCircleStartTime - 30.0
//		sit.latestStart = nextCircleStartTime - 8.0
//		sit.minimumDuration = 0.0
//		sit.earliestFinish = nextCircleStartTime + 5.0
//		sit.latestFinish = nextCircleStartTime + 120.0
//		sit.mode = eApexScreenMode.CIRCLE_STATE
//		file.circleWillCloseSituationOrNull = sit
//
//		ApexScreenSituation sit
//		sit.onlyOnce = false
//		sit.required = true
//		sit.earliestStart = nextCircleStartTime - 30.0
//		sit.latestStart = nextCircleStartTime - 8.0
//		sit.minimumDuration = 0.0
//		sit.earliestFinish = nextCircleStartTime + 5.0
//		sit.latestFinish = nextCircleStartTime + 120.0
//		sit.mode = eApexScreenMode.CIRCLE_STATE
//		file.circleWillCloseSituationOrNull = sit
//	#endif
//}
//
//#if SERVER
//ApexScreenSituation function GetScreenSituation( ApexScreenState screenState )
//{
//	array<ApexScreenSituation> choices = []
//
//	{
//		// circle state -- about to close & just closed
//		float nextCircleStartTime = GetGlobalNetTime( "nextCircleStartTime" )
//	}
//
//	// impressive kill
//
//	// players remaining
//	// squads remaining
//
//	// champion squad
//
//	// logo
//}
//#endif

#if SERVER
void function SvApexScreens_SetScreenSequenceForGameState( int gameState, array<ApexScreenSettingsGroup> sequence )
{
	file.gameStateToScreenSettings[ gameState ] = sequence
}

void function SvApexScreens_RefreshScreenSequence()
{
	thread ApexScreenMasterThink()
}

void function SvApexScreens_QueueCustomScreenSequence( ApexScreenSettingsGroup sequence )
{
	file.queuedScreenSettings.append( sequence )
}

void function SvApexScreens_SetLogoModeCenterOnly( bool logoModeCenterOnly )
{
	file.logoModeCenterOnly = logoModeCenterOnly
}
#endif
