//=========================================================
//	cl_gamemode_survival.nut
//=========================================================

global function ClGamemodeSurvival_Init
global function CLSurvival_RegisterNetworkFunctions

global function ServerCallback_AnnounceCircleClosing
global function ServerCallback_SUR_PingMinimap
global function ServerCallback_SurvivalHint
global function ServerCallback_PlayerBootsOnGround
global function ServerCallback_ClearHints
global function ServerCallback_MatchEndAnnouncement
global function ServerCallback_DestroyEndAnnouncement
global function ServerCallback_ShowWinningSquadSequence
global function ServerCallback_AddWinningSquadData
global function ServerCallback_PromptSayThanks
global function ServerCallback_PromptWelcome
global function ServerCallback_RefreshInventoryAndWeaponInfo
global function ServerCallback_RefreshDeathBoxHighlight

global function AddCallback_OnUpdateShowButtonHints
global function AddCallback_OnVictoryCharacterModelSpawned

global function OnHealthPickupTypeChanged

global function UpdateFallbackMatchmaking
global function UpdateInventoryCounter

global function OverrideHUDHealthFractions

global function OpenSurvivalMenu

global function SURVIVAL_PopulatePlayerInfoRui

global function MarkDpadAsBlocked

global function SetEvoArmorModifier

global function ScorebarInitTracking

global function Survival_MinimapPackage_ObjectiveAreaInit

global function PlayerHudSetWeaponInspect
global function UpdateDpadHud
global function DEV_SendCheatsStateToUI
global function PROTO_ServerCallback_Sur_HoldForUltimate

global function PROTO_OpenInventoryOrSpecifiedMenu

global function UICallback_UpdateCharacterDetailsPanel
global function UICallback_OpenCharacterSelectNewMenu
global function UICallback_QueryPlayerCanBeRespawned

global function HealthkitWheelToggleEnabled
global function HealthkitWheelUseOnRelease
global function HealthkitUseOnHold

global function OrdnanceWheelToggleEnabled
global function OrdnanceWheelUseOnRelease
global function OrdnanceUseOnHold

global function GetSquadSummaryData
global function SetSquadDataToLocalTeam
global function IsSquadDataPersistenceEmpty
global function SetVictorySequenceLocation
global function SetVictorySequenceSunSkyIntensity
global function IsShowingVictorySequence
global function ServerCallback_NessyMessage
global function ShowChampionVictoryScreen
global function SetCustomPlayerInfoShadowFormState

global function CanReportPlayer

global function UIToClient_ToggleMute
global function SetSquadMuteState
global function ToggleSquadMute
global function IsSquadMuted
global function AddCallback_OnSquadMuteChanged
global function AddCallback_ShouldRunCharacterSelection

global function OverwriteWithCustomPlayerInfoTreatment
global function SetCustomPlayerInfoCharacterIcon
global function SetCustomPlayerInfoTreatment
global function SetCustomPlayerInfoColor

global function ClearCustomPlayerInfoColor
global function ClearCustomPlayerInfoTreatment
global function ClearCustomPlayerInfoCharacterIcon

global function GetPlayerInfoColor

global function SetNextCircleDisplayCustomStarting
global function SetNextCircleDisplayCustomClosing
global function SetNextCircleDisplayCustomClear

global function SetPreVictoryScreenCallback
global function SetChampionScreenRuiAsset
global function SetChampionScreenSound
global function SetChampionScreenRuiAssetExtraFunc
global function InitSurvivalHealthBar
global function SURVIVAL_SetGameStateAssetOverrideCallback
#if DEVELOPER
global function EvolvingArmor_SetEvolutionRuiAnimTime
global function Dev_ShowVictorySequence
global function Dev_AdjustVictorySequence
#endif

global function ChangeHUDVisibilityWhenInCryptoDrone
global function GetCompassRui
global function Survival_SetPilotHudVisible
global function CircleAnnouncementsEnable
global function SetDpadMenuHidden
global function Survival_SetVictorySoundPackageFunction
global function UpdateDpadHud_Copy

global function ServerCallback_Scenarios_MatchEndAnnouncement
global function FS_ForceCompass
global function FS_DestroyCompass
global function AddCallback_OnLocalPlayerUnitframeInit
global function GetDpadMenuRui

global struct NextCircleDisplayCustomData
{
	float  circleStartTime
	float  circleCloseTime
	float  countdownGoalTime
	int    roundNumber
	string roundString

	vector deathFieldOrigin
	vector safeZoneOrigin

	float deathfieldDistance
	float deathfieldStartRadius
	float deathfieldEndRadius

	asset  altIcon = $""
	string altIconText
	vector altColor = <1, 1, 1>
}

global struct VictorySoundPackage
{
	string youAreChampPlural
	string youAreChampSingular
	string theyAreChampPlural
	string theyAreChampSingular
}

struct VictoryCameraPackage
{
	vector camera_offset_start
	vector camera_offset_end
	vector camera_focus_offset
	float camera_fov
}

global struct VictoryEffectPackage
{
	vector position
	vector angles
	asset effect = $""
}

const VICTORY_PODIUM_RUI = $"ui/victory_podium_ui.rpak"

const float CROUCH_SPAM_DETECT_TIMEOUT = 1.25
const string SOUND_UI_TEAMMATE_KILLED = "UI_DeathAlert_Friendly"

const string CIRCLE_CLOSING_IN_SOUND = "UI_InGame_RingMoveWarning" //"survival_circle_close_alarm_01"
const string CIRCLE_CLOSING_SOUND = "survival_circle_close_alarm_02"
const float TITAN_DESYNC_TIME = 1.0
const float OVERVIEW_MAP_SIZE = 4096 //

//
const int HEALTH_STATE_DEFAULT = 0
const int HEALTH_STATE_BLEED = 1
const int HEALTH_STATE_REVIVE = 2

const string SFX_DROPSELECTION_ME = "UI_Survival_DropSelection_Player"
const string SFX_DROPSELECTION_TEAM = "UI_Survival_DropSelection_TeamMember"

global const vector SAFE_ZONE_COLOR = <1, 1, 1>
global const float SAFE_ZONE_ALPHA = 0.05

global const string HEALTHKIT_BIND_COMMAND = "+scriptCommand2"
global const string ORDNANCEMENU_BIND_COMMAND = "+strafe"

global const asset CRAFTING_ZONE_ASSET = $"rui/hud/gametype_icons/survival/crafting_zone"
global const string GADGETSLOT_BIND_COMMAND = "+scriptCommand6"
global bool RGB_HUD = false


struct WaitingForPlayersCameraLocPair
{
    vector origin = <0, 0, 0>
    vector angles = <0, 0, 0>
}

global struct SummaryDataEntry
{
	string displayString = ""
}

global struct SquadSummaryPlayerData
{
	int eHandle
	int kills
	int damageDealt
	int survivalTime
	int revivesGiven
	int respawnsGiven
	int prophuntModelIndex
	array<SummaryDataEntry> modeSpecificSummaryData // FreeDM port
}

global struct SquadSummaryData
{
	array<SquadSummaryPlayerData> playerData
	int                           squadPlacement = -1
}

struct
{
	array<void functionref( entity, var )> callbacks_onLocalPlayerUnitframeInit

	var titanLinkProgressRui
	var dpadMenuRui
	var pilotRui

	var fallbackMMRui

	array<var>         minimapTopos
	table<entity, var> minimapTopoClientEnt
	var compassRui

	bool cameFromWaitingForPlayersState = false
	bool knowsHowToUseAmmo = false
	bool superHintAllowed = true
	bool needsMapHint = true

	bool                        toggleMuteKeysEnabled = false
	bool                        isSquadMuted = false
	array< void functionref() > squadMuteChangeCallbacks

	entity lastPrimaryWeapon

	bool toposInitialized = false

	entity planeStart
	entity planeEnd

	bool mapContextPushed = false

	bool autoLoadoutDone = false

	bool haveEverSetOwnDropPoint = false

	string playerState


	string                  rodeoOfferingHintShown = ""
	ConsumableInventoryItem rodeoOfferedItem

	bool  wantsGroundItemUpdate = false
	float nextGroundItemUpdate = 0

	bool requestReviveButtonRegistered = false

	table<entity, entity> playerWaypointData

	var inWorldMinimapDeathFieldRui

	table<string, string> toggleAttachments

	vector victorySequencePosition = < 0, 0, 10000 >
	vector victorySequenceAngles = < 0, 0, 0 >
	float  victorySunIntensity = 1.0
	float  victorySkyIntensity = 1.0
	var    victoryRui = null
	bool IsShowingVictorySequence = false

	SquadSummaryData squadSummaryData
	SquadSummaryData winnerSquadSummaryData

	var inventoryCountRui

	bool shouldShowButtonHintsLocal

	float nextAllowToggleFireRateTime = 0.0

	bool circleAnnouncementsEnabled = true

	bool functionref() shouldRunCharacterSelectionCallback

	table<entity, asset> customPlayerInfoTreatment
	table<entity, vector> customCharacterColor
	table<entity, asset> customCharacterIcon

	asset customChampionScreenRuiAsset
	string customChampionScreenSound
	void functionref( bool) onPreVictoryScreenCallback

	table<entity, var> playerArrows
	var fullmaprui
	VictorySoundPackage functionref() victorySoundPackageCallback
	table<entity functionref( vector, float ), bool functionref( entity )> fullMapAimTargetCallbacks
	void functionref() gameStateOverrideCallback
	int   crouchSpamCount
	float lastPressedCrouchTime
} file

void function ClGamemodeSurvival_Init()
{
	if( GetCurrentPlaylistVarBool( "flowstate_evo_shields", false ) )
		SetConVarInt( "colorblind_mode", 0 )

	Sh_ArenaDeathField_Init()
	ClSurvivalCommentary_Init()

	BleedoutClient_Init()
	ClSurvivalShip_Init()
	SurvivalFreefall_Init()
	ClUnitFrames_Init()
	Cl_Survival_InventoryInit()
	Cl_Survival_LootInit()
	Cl_SquadDisplay_Init()

	Bleedout_SetFirstAidStrings( "#SURVIVAL_APPLYING_FIRST_AID", "#SURVIVAL_RECIEVING_FIRST_AID" )

	RegisterSignal( "Sur_EndTrackOffhandWeaponSlot0" )
	RegisterSignal( "Sur_EndTrackAmmo" )
	RegisterSignal( "Sur_EndTrackPrimary" )
	RegisterSignal( "StopShowingRodeoOfferingPrompt" )
	RegisterSignal( "ReloadPressed" )
	RegisterSignal( "ClearSwapOnUseThread" )
	RegisterSignal( "DroppodLanded" )
	RegisterSignal( "RestartLaserSightThread" )
	FlagInit( "SquadEliminated" )

	ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_survival.rpak" )
	if ( file.gameStateOverrideCallback != null )
	{
		file.gameStateOverrideCallback()
	}

	if ( IsFallLTM() )
	{
		ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_shadow_squad.rpak" )
		ClGameState_RegisterGameStateFullmapAsset( $"ui/gamestate_info_fullmap_shadow_squad.rpak" )
	}

	AddCallback_OnClientScriptInit( OverrideMinimapPackages )

	SetGameModeScoreBarUpdateRulesWithFlags( GameModeScoreBarRules, sbflag.SKIP_STANDARD_UPDATE )
	AddCallback_OnPlayerMatchStateChanged( OnPlayerMatchStateChanged )

	AddCallback_OnClientScriptInit( Cl_Survival_AddClient )

	AddCreateCallback( "npc_titan", OnTrackTitanTeam )
	AddCreateCallback( "prop_survival", OnPropCreated )
	AddCreateCallback( "prop_script", OnPropScriptCreated )

	AddCreateCallback( "player", OnPlayerCreated )
	AddDestroyCallback( "player", OnPlayerDestroyed )
	AddOnDeathCallback( "player", OnPlayerKilled )

	AddCreatePilotCockpitCallback( OnPilotCockpitCreated )
	AddCallback_PlayerClassChanged( Survival_OnPlayerClassChanged )

	RegisterConCommandTriggeredCallback( "-offhand4", AllowSuperHint )
	RegisterConCommandTriggeredCallback( "+scriptCommand3", ToggleFireSelect )
	RegisterConCommandTriggeredCallback( "weaponSelectOrdnance", TryCycleOrdnance )

	RegisterConCommandTriggeredCallback( "+reload", ReloadPressed )
	RegisterConCommandTriggeredCallback( "+use", UsePressed )
	RegisterConCommandTriggeredCallback( "+useAndReload", ReloadPressed )

	RegisterConCommandTriggeredCallback( "+duck", CrouchPressed )
	RegisterConCommandTriggeredCallback( "+toggle_duck", CrouchPressed )
	RegisterConCommandTriggeredCallback( HEALTHKIT_BIND_COMMAND, HealthkitButton_Down )
	RegisterConCommandTriggeredCallback( "-" + HEALTHKIT_BIND_COMMAND.slice( 1 ), HealthkitButton_Up )

	RegisterConCommandTriggeredCallback( ORDNANCEMENU_BIND_COMMAND, OrdnanceMenu_Down )
	RegisterConCommandTriggeredCallback( "-" + ORDNANCEMENU_BIND_COMMAND.slice( 1 ), OrdnanceMenu_Up )

	RegisterConCommandTriggeredCallback( GADGETSLOT_BIND_COMMAND, GadgetSlot_Down )
	file.inventoryCountRui = CreateFullscreenRui( $"ui/inventory_count_meter.rpak", 0 )

	AddCallback_MinimapEntShouldCreateCheck( DontCreateRuisForEnemies )
	AddCallback_MinimapEntSpawned( AddInWorldMinimapObject )
	AddCallback_LocalViewPlayerSpawned( AddInWorldMinimapObject )

	AddCallback_LocalClientPlayerSpawned( OnLocalPlayerSpawned )

	AddCallback_EntitiesDidLoad( Survival_EntitiesDidLoad )

	AddCallback_OnBleedoutStarted( Sur_OnBleedoutStarted )
	AddCallback_OnBleedoutEnded( Sur_OnBleedoutEnded )

	AddFirstPersonSpectateStartedCallback( OnFirstPersonSpectateStarted )
	AddCallback_OnViewPlayerChanged( OnViewPlayerChanged )
	AddCallback_ItemFlavorLoadoutSlotDidChange_AnyPlayer( Loadout_Character(), OnPlayerLoadoutChanged )
	AddCallback_OnPlayerConsumableInventoryChanged( UpdateDpadHud )

	AddClientCallback_OnResolutionChanged( OnResolutionChanged_FixRuiSize )
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, Survival_WaitForPlayers )
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, EnableToggleMuteKeys )
	if( Playlist() != ePlaylists.fs_scenarios )
		AddCallback_GameStateEnter( eGameState.PickLoadout, Survival_RunCharacterSelection )
	AddCallback_GameStateEnter( eGameState.PickLoadout, DisableToggleMuteKeys )
	AddCallback_GameStateEnter( eGameState.Prematch, OnGamestatePrematch )
	AddCallback_GameStateEnter( eGameState.Playing, DisableToggleMuteKeys )
	AddCallback_GameStateEnter( eGameState.WaitingForCustomStart, SetDpadMenuVisible )
	AddCallback_GameStateEnter( eGameState.Playing, SetDpadMenuVisible )
	AddCallback_GameStateEnter( eGameState.Playing, OnGamestatePlaying )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, Survival_ClearHints )
	AddCallback_GameStateEnter( eGameState.Playing, OnGameStatePlaying_CheckCryptoDrone )
	{
		GenericFullmapSetupStruct fullmapData
		fullmapData.ruiAsset = $"ui/in_world_minimap_plane_path.rpak"
		fullmapData.friendlyOnly = false
		fullmapData.hudMapOnly = false
		fullmapData.setupFunc = null
		AddCallback_Targetname_AddToFullMapAndInWorldMapCustom( "pathCenterEnt", fullmapData )
	}

	{
		GenericFullmapSetupStruct fullmapData
		fullmapData.defaultIcon = $"rui/survival_ship"
		fullmapData.iconScale = <1.5, 1.5, 0.0>
		fullmapData.iconColor = <0.5, 0.5, 0.5>
		fullmapData.friendlyOnly = false
		fullmapData.hudMapOnly = false
		AddCallback_Targetname_AddToFullMapAndInWorldMapGeneric( "planeEnt", fullmapData )
	}

	if ( SquadMuteIntroEnabled() )
		AddCallback_OnSquadMuteChanged( OnSquadMuteChanged )

	RegisterServerVarChangeCallback( "gameState", OnGamestateChanged )

	if ( GetCurrentPlaylistVarBool( "inventory_counter_enabled", true ) )
		AddCallback_LocalPlayerPickedUpLoot( TryUpdateInventoryCounter )

	Obituary_SetEnabled( GetCurrentPlaylistVarBool( "enable_obituary", true ) )

	foreach ( equipSlot, data in EquipmentSlot_GetAllEquipmentSlots() )
	{
		if ( data.trackingNetInt != "" )
		{
			AddCallback_OnEquipSlotTrackingIntChanged( equipSlot, EquipmentChanged )
		}
	}

	AddCallback_OnEquipSlotTrackingIntChanged( "backpack", BackpackChanged )

	if ( IsSoloMode() || ShouldModeDisableCharacterComms() )
		SetCommsDialogueEnabled( false )

	if( Playlist() == ePlaylists.fs_haloMod_survival )
		RegisterSignal("NewKillChangeRui")
}

void function SURVIVAL_SetGameStateAssetOverrideCallback( void functionref() func )
{
	file.gameStateOverrideCallback = func
}

void function AddCallback_OnLocalPlayerUnitframeInit( void functionref(entity, var) func )
{
	Assert( file.callbacks_onLocalPlayerUnitframeInit.contains( func ) == false, "Callback (" + string( func ) + ") already registered for OnMapEditorPropSpawned" )

	if( file.callbacks_onLocalPlayerUnitframeInit.contains( func ) )
		return

	file.callbacks_onLocalPlayerUnitframeInit.append( func )
}

void function Survival_EntitiesDidLoad()
{
	//SetConVarInt( "fps_max", 190 ) //remove me when 190 fps fix arrives

	InitInWorldScreens()

	thread Flowstate_CheckForLaserSightsAndApplyEffect()

	// Hud_SetVisible(HudElement( "Overshields_TestFrame" ), true)
	// RuiSetImage( Hud_GetRui( HudElement( "Overshields_TestFrame" ) ), "basicImage", $"rui/flowstatecustom/overshield_info_box")

	file.toposInitialized = true
}

void function Flowstate_CheckForLaserSightsAndApplyEffect()
{
	Signal( clGlobal.signalDummy, "RestartLaserSightThread" )
	EndSignal( clGlobal.signalDummy, "RestartLaserSightThread" )

	entity player = GetLocalViewPlayer()

	entity weapon
	entity weapon2
	entity altWeapon
	entity activeMainWeapon
	entity activeAltWeapon
	array<string> modsMain
	array<string> modsAlt
	table<string,int> e
	bool hasLaserMain = false
	bool hasLaserAlt = false
	bool exitCheck = false
	e["mainFxHandle"] <- -1
	e["altFxHandle"] <- -1
	entity prevMainWeapon = null
	entity prevAltWeapon = null

	while ( true )
	{
		WaitFrame()

		if ( !IsValid( player ) )
			break

		weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		weapon2 = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 )
		altWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_DUALPRIMARY_0 )

		activeMainWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		activeAltWeapon = player.GetActiveWeapon( eActiveInventorySlot.altHand )

		bool changedMainWeapon = activeMainWeapon != prevMainWeapon
		bool changedAltWeapon = activeAltWeapon != prevAltWeapon
		prevMainWeapon = activeMainWeapon
		prevAltWeapon = activeAltWeapon

		modsMain.clear()
		hasLaserMain = false
		if ( IsValid( activeMainWeapon ) )
			modsMain = clone activeMainWeapon.GetMods()

		exitCheck = false
		foreach ( mod in modsMain )
		{
			if ( exitCheck )
				continue

			if ( !SURVIVAL_Loot_IsRefValid( mod ) )
				continue

			if ( mod == "laser_sight_l1" || mod == "laser_sight_l2" || mod == "laser_sight_l3" || mod == "laser_sight_l4" )
			{
				hasLaserMain = true
				exitCheck = true
			}
		}

		modsAlt.clear()
		hasLaserAlt = false
		if ( IsValid( activeAltWeapon ) )
			modsAlt = clone activeAltWeapon.GetMods()

		exitCheck = false
		foreach ( mod in modsAlt )
		{
			if ( exitCheck )
				continue

			if ( !SURVIVAL_Loot_IsRefValid( mod ) )
				continue

			if ( mod == "laser_sight_l1" || mod == "laser_sight_l2" || mod == "laser_sight_l3" || mod == "laser_sight_l4" )
			{
				hasLaserAlt = true
				exitCheck = true
			}
		}

		// Check conditions for mainHand
		if ( !IsAlive( player ) ||
			( !IsValid( weapon ) && !IsValid( weapon2 ) ) ||
			!IsValid( activeMainWeapon ) ||
			activeMainWeapon.IsWeaponAdsButtonPressed() ||
			( activeMainWeapon != weapon && activeMainWeapon != weapon2 ) ||
			activeMainWeapon.GetWeaponClassName().find("melee") != -1 ||
			activeMainWeapon.IsDiscarding() ||
			!hasLaserMain ||
			player.Player_IsFreefalling() ||
			player != GetLocalViewPlayer() ||
			player.IsThirdPersonShoulderModeOn() ||
			changedMainWeapon )
		{
			if ( e["mainFxHandle"] != -1 )
			{
				EffectStop( e["mainFxHandle"], true, false )
				e["mainFxHandle"] = -1
			}
		}
		else if ( hasLaserMain && e["mainFxHandle"] == -1 )
		{
			e["mainFxHandle"] = activeMainWeapon.PlayWeaponEffectReturnViewEffectHandle( $"P_wpn_lasercannon_aim", $"", "muzzle_flash" )
		}

		// Check conditions for altHand
		if ( !IsAlive( player ) ||
			!IsValid( altWeapon ) ||
			!IsValid( activeAltWeapon ) ||
			activeAltWeapon.IsWeaponAdsButtonPressed() ||
			activeAltWeapon != altWeapon ||
			activeAltWeapon.GetWeaponClassName().find("melee") != -1 ||
			activeAltWeapon.IsDiscarding() ||
			!hasLaserAlt ||
			player.Player_IsFreefalling() ||
			player != GetLocalViewPlayer() ||
			player.IsThirdPersonShoulderModeOn() ||
			changedAltWeapon )
		{
			if ( e["altFxHandle"] != -1 )
			{
				EffectStop( e["altFxHandle"], true, false )
				e["altFxHandle"] = -1
			}
		}
		else if ( hasLaserAlt && e["altFxHandle"] == -1 )
		{
			e["altFxHandle"] = activeAltWeapon.PlayWeaponEffectReturnViewEffectHandle( $"P_wpn_lasercannon_aim", $"", "muzzle_flash" )
		}
	}
}

bool function SprintFXAreEnabled()
{
	bool enabled = GetCurrentPlaylistVarBool( "fp_sprint_fx", false )
	return enabled
}


void function OnPlayerCreated( entity player )
{
	if ( SprintFXAreEnabled() )
	{
		if ( player == GetLocalViewPlayer() )
			thread TrackSprint( player )
	}

	if ( (player.GetTeam() == GetLocalClientPlayer().GetTeam()) && (SquadMuteIntroEnabled() || SquadMuteLegendSelectEnabled()) )
	{
		//
		if ( IsSquadMuted() )
			SetSquadMuteState( IsSquadMuted() )
	}

	if( IsFiringRangeGameMode() )
	{
		thread PlayFiringRangeMusicForPlayer( player )
	}

	if( GetCurrentPlaylistVarBool( "fs_stamina_mod", false ) && player == GetLocalClientPlayer() )
		thread UpdateStaminaBar(player)
}


void function PlayFiringRangeMusicForPlayer( entity player )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )

	ItemFlavor musicPack = GetMusicPackForPlayer( player )
	if ( !IsValid( player ) )
		return

	string desiredMusicTrack = MusicPack_GetLobbyMusic( musicPack )
	EmitSoundOnEntity( player, desiredMusicTrack )
}

void function UpdateStaminaBar(entity player)
{
	Hud_SetVisible( HudElement( "StaminaBarMover" ), true )
	Hud_SetVisible( HudElement( "StaminaBarMover2" ), false )
	Hud_SetVisible( HudElement( "StaminaBar" ), true )
	Hud_SetVisible( HudElement( "StaminaText" ), true )

	while( true )
	{
		WaitFrame()

		if( !IsValid( player ) || !IsAlive( player ) || GetGameState() != eGameState.Playing || player.IsObserver() )
		{
			Hud_SetVisible( HudElement( "StaminaBarMover" ), false )
			Hud_SetVisible( HudElement( "StaminaBarMover2" ), false )
			Hud_SetVisible( HudElement( "StaminaBar" ), false )
			Hud_SetVisible( HudElement( "StaminaText" ), false )
			continue
		}

		Hud_SetVisible( HudElement( "StaminaBar" ), true )
		Hud_SetVisible( HudElement( "StaminaText" ), true )

		if(player.GetPlayerNetBool("playerStaminaRecovering")) {
			Hud_SetVisible( HudElement( "StaminaBarMover" ), false )
			Hud_SetVisible( HudElement( "StaminaBarMover2" ), true )
		}
		else {
			Hud_SetVisible( HudElement( "StaminaBarMover" ), true )
			Hud_SetVisible( HudElement( "StaminaBarMover2" ), false )
		}

		Hud_SetWidth( HudElement( "StaminaBarMover" ), (player.GetPlayerNetInt( "playerStamina" ).tofloat() - 0.0) / (100 - 0) * 300)
		Hud_SetWidth( HudElement( "StaminaBarMover2" ), (player.GetPlayerNetInt( "playerStamina" ).tofloat() - 0.0) / (100 - 0) * 300)
		Hud_SetWidth( HudElement( "StaminaBar" ), (100 - 0.0) / (100 - 0) * 300)
	}
}

void function OnPlayerDestroyed( entity player )
{

}


void function TrackSprint( entity player )
{
	player.EndSignal( "OnDestroy" )

	table<string, bool> e
	e[ "sprintingVisuals" ] <- false
	int fxHandle

	while ( 1 )
	{
		bool isSprint     = e[ "sprintingVisuals" ]
		bool shouldSprint = ShouldShowSprintVisuals( player )

		if ( isSprint && !shouldSprint )
		{
			e[ "sprintingVisuals" ] = false
			player.SetFOVScale( 1, 2 )
			EffectStop( fxHandle, false, true )
			fxHandle = -1
		}
		else if ( !isSprint && shouldSprint )
		{
			e[ "sprintingVisuals" ] = true
			//
			if ( IsValid( player.GetCockpit() ) )
				fxHandle = StartParticleEffectOnEntity( player.GetCockpit(), GetParticleSystemIndex( SPRINT_FP ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		}

		//
		if ( shouldSprint )
			player.SetFOVScale( 1.15, 2 )

		WaitFrame()
	}
}


bool function ShouldShowSprintVisuals( entity player )
{
	if ( player.GetParent() != null )
		return false

	if ( player.GetPhysics() == MOVETYPE_NOCLIP )
		return false

	if ( GetGameState() != eGameState.Playing )
		return false

	vector vel = player.GetVelocity()
	return vel.Length() >= 221 && player.IsOnGround()
}


const array<int> nonCompassModes = [
	ePlaylists.winterexpress,
	ePlaylists.custom_ctf,
	ePlaylists.fs_haloMod_ctf,
	ePlaylists.fs_haloMod_oddball,
	ePlaylists.fs_scenarios,
	ePlaylists.fs_1v1,
	ePlaylists.fs_lgduels_1v1,
	ePlaylists.fs_snd,
	ePlaylists.fs_spieslegends,
	ePlaylists.fs_apexkart
]

void function Cl_Survival_AddClient( entity player )
{
	file.dpadMenuRui = CreateCockpitPostFXRui( SURVIVAL_HUD_DPAD_RUI, HUD_Z_BASE )
	RuiTrackFloat( file.dpadMenuRui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )

	getroottable().testRui <- file.dpadMenuRui
	SetDpadMenuVisible()

	#if DEVELOPER
		if ( GetBugReproNum() == 1972 )
			file.pilotRui = CreatePermanentCockpitPostFXRui( $"ui/survival_player_hud_editor_version.rpak", HUD_Z_BASE )
		else
			file.pilotRui = CreatePermanentCockpitPostFXRui( SURVIVAL_HUD_PLAYER, HUD_Z_BASE )
	#else
		file.pilotRui = CreatePermanentCockpitPostFXRui( SURVIVAL_HUD_PLAYER, HUD_Z_BASE )
	#endif

	RuiSetBool( file.pilotRui, "isVisible", GetHudDefaultVisibility() )
	RuiSetBool( file.pilotRui, "useShields", true )

	if ( GetCurrentPlaylistVarBool( "compass_flat_enabled", true ) )
	{

		file.compassRui = CreatePermanentCockpitRui( $"ui/compass_flat.rpak", HUD_Z_BASE )
		RuiTrackFloat3( file.compassRui, "playerAngles", player, RUI_TRACK_CAMANGLES_FOLLOW )
		RuiTrackInt( file.compassRui, "gameState", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "gameState" ) )
	}

	#if PC_PROG
		if ( GetCurrentPlaylistVarBool( "pc_force_pushtotalk", false ) )
			player.ClientCommand( "+pushtotalk" )
	#endif

	SetConVarFloat( "dof_variable_blur", 0.0 )

	RuiTrackInt( file.pilotRui, "squadID", player, RUI_TRACK_SQUADID )

	WaitingForPlayersOverlay_Setup( player )
}

void function FS_ForceCompass( )
{
	if ( file.compassRui != null )
		RuiDestroyIfAlive( file.compassRui )

	file.compassRui = CreatePermanentCockpitRui( $"ui/compass_flat.rpak", HUD_Z_BASE )
	RuiTrackFloat3( file.compassRui, "playerAngles", GetLocalViewPlayer(), RUI_TRACK_CAMANGLES_FOLLOW )
	RuiTrackInt( file.compassRui, "gameState", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "gameState" ) )
}

void function FS_DestroyCompass()
{
	if ( file.compassRui != null )
		RuiDestroyIfAlive( file.compassRui )
}

void function InitSurvivalHealthBar()
{
	Assert( IsNewThread(), "Must be threaded off" )
	entity player = GetLocalViewPlayer()


	if( IsFlowstateActive() )
	{
		MG_CustomPilotRUI( player, file.pilotRui )
		return
	}

	SURVIVAL_PopulatePlayerInfoRui( player, file.pilotRui )
}

void function MG_CustomPilotRUI( entity player, var rui ) {

	RuiSetInt( rui, "micStatus", 0 )
	RuiSetColorAlpha( rui, "customCharacterColor", SrgbToLinear( <0, 0, 255> / 255.0 ), 1.0 )
	RuiSetBool( rui, "useCustomCharacterColor", true )

	switch(player.GetPlayerName()) {
		case "DEAFPS":
			RuiSetImage( rui, "playerIcon", $"rui/flowstatecustom/dea/dea_pfp" )
			RuiSetString( rui, "name", "DEAFPS" )
			break
		case "DEAR5R":
			RuiSetImage( rui, "playerIcon", $"rui/flowstatecustom/dea/dea_pfp" )
			RuiSetString( rui, "name", "DEAFPS" )
   			break
		case "LoyTakian":
			RuiSetImage( rui, "playerIcon", $"rui/flowstatecustom/dea/loy_pfp" )
			RuiSetString( rui, "name", "Loy" )
			break
   		default:
			SURVIVAL_PopulatePlayerInfoRui( player, rui )
	}

}

void function SURVIVAL_PopulatePlayerInfoRui( entity player, var rui )
{
	Assert( IsValid( player ) )

	EndSignal( player, "OnDestroy" )

	if ( GetCurrentPlaylistVarBool( "flowstate_enable_editor_hud", false ) )
	{
		RuiTrackInt( rui, "teamMemberIndex", player, RUI_TRACK_PLAYER_TEAM_MEMBER_INDEX )
		RuiTrackString( rui, "name", player, RUI_TRACK_PLAYER_NAME_STRING )
		RuiTrackInt( rui, "micStatus", player, RUI_TRACK_MIC_STATUS )

		ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
		asset classIcon      = CharacterClass_GetGalleryPortrait( character )

		RuiSetImage( rui, "playerIcon", classIcon )
		RuiTrackFloat( rui, "playerHealthFrac", player, RUI_TRACK_HEALTH )
		RuiTrackFloat( rui, "playerTargetHealthFrac", player, RUI_TRACK_HEAL_TARGET )
		RuiTrackFloat( rui, "playerShieldFrac", player, RUI_TRACK_SHIELD_FRACTION )
		// RuiTrackFloat( rui, "cameraViewFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.camera_view ) //

		vector shieldFrac = < SURVIVAL_GetArmorShieldCapacity( 0 ) / 100.0,
				SURVIVAL_GetArmorShieldCapacity( 1 ) / 100.0,
				SURVIVAL_GetArmorShieldCapacity( 2 ) / 100.0 >

		RuiSetColorAlpha( rui, "shieldFrac", shieldFrac, float( SURVIVAL_GetArmorShieldCapacity( 3 ) ) )
		RuiTrackFloat( rui, "playerTargetShieldFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.target_shields )
		RuiTrackFloat( rui, "playerTargetHealthFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.target_health )
		RuiTrackFloat( rui, "playerTargetHealthFracTemp", player, RUI_TRACK_HEAL_TARGET )

		OverwriteWithCustomPlayerInfoTreatment( player, rui )
		return
	}
	RuiTrackInt( rui, "teamMemberIndex", player, RUI_TRACK_PLAYER_TEAM_MEMBER_INDEX )
	RuiTrackString( rui, "name", player, RUI_TRACK_PLAYER_NAME_STRING )
	RuiTrackInt( rui, "micStatus", player, RUI_TRACK_MIC_STATUS )

	ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
	asset classIcon      = CharacterClass_GetGalleryPortrait( character )

	RuiSetImage( rui, "playerIcon", classIcon )
	RuiSetInt( rui, "playerBaseHealth", GetPlayerSettingBaseHealth( player ) )
	RuiSetInt( rui, "playerBaseShield", GetPlayerSettingBaseShield( player ) )

	RuiSetGameTime( rui, "trackedPlayerChangeTime", Time() )
	RuiTrackFloat( rui, "playerHealthFrac", player, RUI_TRACK_HEALTH )
	RuiTrackFloat( rui, "playerTargetHealthFrac", player, RUI_TRACK_HEAL_TARGET )
	RuiTrackFloat( rui, "playerShieldFrac", player, RUI_TRACK_SHIELD_FRACTION )
	RuiTrackFloat( rui, "cameraViewFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.camera_view ) //

	vector shieldFrac = < SURVIVAL_GetArmorShieldCapacity( 0 ) / 100.0,
			SURVIVAL_GetArmorShieldCapacity( 1 ) / 100.0,
			SURVIVAL_GetArmorShieldCapacity( 2 ) / 100.0 >

	RuiSetColorAlpha( rui, "shieldFrac", shieldFrac, float( SURVIVAL_GetArmorShieldCapacity( 3 ) ) )
	RuiTrackFloat( rui, "playerTargetShieldFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.target_shields )
	RuiTrackFloat( rui, "playerTargetHealthFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.target_health )
	RuiTrackFloat( rui, "playerTargetHealthFracTemp", player, RUI_TRACK_HEAL_TARGET )
	string platformString = "#CROSSPLAY_ICON_PC"
	RuiSetString( rui, "platformString", platformString )
		RuiSetString( rui, "platformString", platformString )

	bool isSwitchHardware = player.GetHardware() == "HARDWARE_SWITCH"
	if ( isSwitchHardware )
		RuiSetFloat( rui, "nxPlatformTextOffsetX", -1.5 )
	OverwriteWithCustomPlayerInfoTreatment( player, rui )

	RuiSetBool( rui, "disconnected", false )

	if(RGB_HUD)
		thread RGBRui(rui)
}

void function RGBRui(var rui)
{
	entity player = GetLocalClientPlayer()
	while(RGB_HUD)
	{
		RuiSetColorAlpha( rui, "customCharacterColor", SrgbToLinear( <RandomInt(255), RandomInt(255) , RandomInt(255)> / 255.0 ), 1.0 )
		wait 0.1
	}
}

void function OverwriteWithCustomPlayerInfoTreatment( entity player, var rui )
{
	if ( GetCurrentPlaylistVarBool( "flowstate_enable_editor_hud", false ) )
	{
		if ( player in file.customCharacterIcon )
			RuiSetImage( rui, "playerIcon", file.customCharacterIcon[player] )

		return
	}

	if ( player in file.customCharacterIcon )
		RuiSetImage( rui, "playerIcon", file.customCharacterIcon[player] )

	if ( player in file.customPlayerInfoTreatment )
	{
		RuiSetImage( rui, "customTreatment", file.customPlayerInfoTreatment[player] )
	}
	else
	{
		RuiSetImage( rui, "customTreatment", $"" )
	}

	if ( player in file.customCharacterColor )
	{
		RuiSetColorAlpha( rui, "customCharacterColor", SrgbToLinear( GetPlayerInfoColor( player ) / 255.0 ), 1.0 )
		RuiSetBool( rui, "useCustomCharacterColor", true )
	}
	else
	{
		RuiSetBool( rui, "useCustomCharacterColor", false )
	}
}

void function SetCustomPlayerInfoCharacterIcon( entity player, asset customIcon )
{
	if ( !(player in file.customCharacterIcon) )
		file.customCharacterIcon[player] <- customIcon
	file.customCharacterIcon[player] = customIcon
	if ( file.pilotRui != null )
		RuiSetImage( file.pilotRui, "playerIcon", file.customCharacterIcon[player] )
}

void function ClearCustomPlayerInfoCharacterIcon(entity player)
{
	if ( player in file.customCharacterIcon )
	{
		delete file.customCharacterIcon[player]
		ItemFlavor character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_Character() )
		asset classIcon      = CharacterClass_GetGalleryPortrait( character )
		RuiSetImage( file.pilotRui, "playerIcon", classIcon )
	}
}

void function SetCustomPlayerInfoTreatment( entity player, asset treatmentImage )
{
	if ( !(player in file.customPlayerInfoTreatment) )
		file.customPlayerInfoTreatment[player] <- treatmentImage
	file.customPlayerInfoTreatment[player] = treatmentImage
	if ( file.pilotRui != null )
		RuiSetImage( file.pilotRui, "customTreatment", file.customPlayerInfoTreatment[player] )
}

void function ClearCustomPlayerInfoTreatment(entity player)
{
	if ( player in file.customPlayerInfoTreatment )
	{
		delete file.customPlayerInfoTreatment[player]
		RuiSetImage( file.pilotRui, "customTreatment", $"" )
	}
}

void function SetCustomPlayerInfoShadowFormState( entity player, bool state )
{
	if ( file.pilotRui != null )
		RuiSetBool( file.pilotRui, "useShadowFormFrame", state )
}

void function SetCustomPlayerInfoColor( entity player, vector characterColor )
{
	if ( !(player in file.customCharacterColor ) )
		file.customCharacterColor[player] <- characterColor
	file.customCharacterColor[player] = characterColor
	if ( file.pilotRui != null )
	{
		RuiSetColorAlpha( file.pilotRui, "customCharacterColor", SrgbToLinear( file.customCharacterColor[player] / 255.0 ), 1.0 )
		RuiSetBool( file.pilotRui, "useCustomCharacterColor", true )
	}

}

vector function GetPlayerInfoColor( entity player )
{
	if ( player in file.customCharacterColor )
		return file.customCharacterColor[player]

	return GetKeyColor( COLORID_MEMBER_COLOR0, player.GetTeamMemberIndex() )
}


void function ClearCustomPlayerInfoColor( entity player )
{
	if ( player in file.customCharacterColor )
	{
		delete file.customCharacterColor[player]
		RuiSetBool( file.pilotRui, "useCustomCharacterColor", false )
	}
}

void function OverrideHUDHealthFractions( entity player, float targetHealthFrac = -1, float targetShieldFrac = -1 )
{
	if ( targetHealthFrac < 0 )
		RuiTrackFloat( file.pilotRui, "playerTargetHealthFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.target_health )
	else
		RuiSetFloat( file.pilotRui, "playerTargetHealthFrac", targetHealthFrac )

	if ( targetShieldFrac < 0 )
		RuiTrackFloat( file.pilotRui, "playerTargetShieldFrac", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.target_shields )
	else
		RuiSetFloat( file.pilotRui, "playerTargetShieldFrac", targetShieldFrac )
}

void function OverrideMinimapPackages( entity player )
{
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.OBJECTIVE_AREA, MINIMAP_OBJECTIVE_AREA_RUI, MinimapPackage_ObjectiveAreaInit )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.FD_HARVESTER, MINIMAP_OBJECT_RUI, MinimapPackage_PlaneInit )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.AT_BANK, MINIMAP_OBJECT_RUI, MinimapPackage_MarkerInit )
	RegisterMinimapPackage( "npc_titan", eMinimapObject_npc_titan.AT_BOUNTY_BOSS, MINIMAP_OBJECT_RUI, FD_NPCTitanInit )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.VAULT_PANEL, MINIMAP_OBJECT_RUI, MinimapPackage_VaultPanel, FULLMAP_OBJECT_RUI, MinimapPackage_VaultPanel )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.VAULT_PANEL_OPEN, MINIMAP_OBJECT_RUI, MinimapPackage_VaultPanelOpen, FULLMAP_OBJECT_RUI, MinimapPackage_VaultPanelOpen )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.SURVEY_BEACON, MINIMAP_OBJECT_RUI, MinimapPackage_SurveyBeacon )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.HOVERTANK, MINIMAP_OBJECT_RUI, MinimapPackage_HoverTank )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.HOVERTANK_DESTINATION, MINIMAP_OBJECT_RUI, MinimapPackage_HoverTankDestination )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.TRAIN, MINIMAP_OBJECT_RUI, MinimapPackage_Train )

	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.SND_A, MINIMAP_OBJECT_RUI, MinimapPackage_A )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.SND_B, MINIMAP_OBJECT_RUI, MinimapPackage_B )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.BOMB, MINIMAP_OBJECT_RUI, MinimapPackage_Bomb )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.FLAG_MIL, MINIMAP_OBJECT_RUI, MinimapPackage_FlagMIL )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.FLAG_IMC, MINIMAP_OBJECT_RUI, MinimapPackage_FlagIMC )
}

void function FD_NPCTitanInit( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
}

void function MinimapPackage_VaultKey( entity ent, var rui )
{
}
void function MinimapPackage_SurveyBeacon( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/survey_beacon_only_pathfinder" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_HoverTank( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/sur_hovertank_minimap" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_HoverTankDestination( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/sur_hovertank_minimap_destination" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_Train( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/sur_train_minimap" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_Bomb( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/flowstatecustom/bombicon" )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_FlagIMC( entity ent, var rui )
{
	asset icon = $""

	if(GetLocalClientPlayer().GetTeam() == TEAM_IMC )
		icon = $"rui/gamemodes/capture_the_flag/imc_flag"
	else if(GetLocalClientPlayer().GetTeam() == TEAM_MILITIA )
		icon = $"rui/gamemodes/capture_the_flag/mil_flag"

	RuiSetImage( rui, "defaultIcon", icon )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_FlagMIL( entity ent, var rui )
{
	asset icon = $""

	if(GetLocalClientPlayer().GetTeam() == TEAM_MILITIA )
		icon = $"rui/gamemodes/capture_the_flag/imc_flag"
	else if(GetLocalClientPlayer().GetTeam() == TEAM_IMC )
		icon = $"rui/gamemodes/capture_the_flag/mil_flag"

	RuiSetImage( rui, "defaultIcon", icon )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_A( entity ent, var rui )
{
	asset icon = $""

	if(GetLocalClientPlayer().GetTeam() == Safe_GetAttackerTeam())
		icon = $"rui/flowstatecustom/A_Attack"
	else if(GetLocalClientPlayer().GetTeam() == Safe_GetDefenderTeam())
		icon = $"rui/flowstatecustom/A_Defend"

	RuiSetImage( rui, "defaultIcon", icon )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}
void function MinimapPackage_B( entity ent, var rui )
{
	asset icon = $""

	if(GetLocalClientPlayer().GetTeam() == Safe_GetAttackerTeam())
		icon = $"rui/flowstatecustom/B_Attack"
	else if(GetLocalClientPlayer().GetTeam() == Safe_GetDefenderTeam())
		icon = $"rui/flowstatecustom/B_Defend"

	RuiSetImage( rui, "defaultIcon", icon )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}
void function MinimapPackage_MarkerInit( entity ent, var rui )
{
	if ( ent.GetTargetName() != "worldMarker" )
		return

	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/ctf/ctf_flag_neutral" )
	RuiSetImage( rui, "clampedDefaultIcon", $"rui/hud/gametype_icons/ctf/ctf_flag_neutral" )
	RuiSetBool( rui, "useTeamColor", true )
}


void function MinimapPackage_PlaneInit( entity ent, var rui )
{
	if ( ent.GetTargetName() != "planeMapEnt" )
		return

	RuiSetImage( rui, "defaultIcon", $"rui/survival_ship" )
	RuiSetImage( rui, "clampedDefaultIcon", $"rui/survival_ship" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function Survival_MinimapPackage_ObjectiveAreaInit( entity ent, var rui )
{
	RuiSetFloat( rui, "radiusScale", SURVIVAL_MINIMAP_RING_SCALE )
	if ( ent.IsClientOnly() )
		RuiSetFloat( rui, "objectRadius", ent.e.clientEntMinimapScale )
	else
		RuiTrackFloat( rui, "objectRadius", ent, RUI_TRACK_MINIMAP_SCALE )
	RuiSetImage( rui, "clampedImage", $"" )
	RuiSetImage( rui, "centerImage", $"" )
	RuiSetBool( rui, "blink", true )

	switch ( ent.GetTargetName() )
	{
		case "safeZone":
			RuiTrackFloat3( rui, "playerPos", GetLocalViewPlayer(), RUI_TRACK_ABSORIGIN_FOLLOW )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( SAFE_ZONE_COLOR ), SAFE_ZONE_ALPHA )  //
			RuiSetBool( rui, "drawLine", true )
			break

		case "safeZone_noline":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( SAFE_ZONE_COLOR ), SAFE_ZONE_ALPHA )  //
			break

		case "surveyZone":
			RuiSetBool( rui, "blink", false )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( TEAM_COLOR_PARTY / 255.0 ), 0.05 )  //
			break

		case "trainIcon":
			RuiSetBool( rui, "blink", false )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( TEAM_COLOR_PARTY / 255.0 ), 1.0 )  //
			break

		case "risingWallIconDown":
		case "risingWallIconMoving":
		case "risingWallIconUp":
			RuiSetBool( rui, "blink", false )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( TEAM_COLOR_PARTY / 255.0 ), 1.0 )  //
			break

		case "hotZone":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( <128, 188, 255> / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( <128, 188, 255> / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break


		case "airdropClusterWhite":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER1 ) / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER1 ) / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break
		case "airdropClusterBlue":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER2 ) / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER2 ) / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break
		case "airdropClusterPurple":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER3 ) / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER3 ) / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break
		case "airdropClusterGold":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER4 ) / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER4 ) / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break
		case "airdropClusterRed":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER5 ) / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER5 ) / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break

		case "campfireZone":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( <173, 216, 255> / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( <173, 216, 230> / 255.0 ), 0.0 )
			RuiSetBool( rui, "blink", false )
			RuiSetBool( rui, "borderBlink", false )
			break

		case "craftingZone":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( <255, 255, 255> / 255.0 ), 1 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( <235, 207, 52> / 255.0 ), 0 )
			RuiSetAsset( rui, "areaImage", CRAFTING_ZONE_ASSET )
			RuiSetBool( rui, "blink", false )
			break

		//case FISSURE_MINIMAP_WARNING:
		//	RuiSetColorAlpha( rui, "objColor", SrgbToLinear( RING_COLLAPSEMODE_WARN_COLOR / 255.0 ), 0.04 )
		//	RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( RING_COLLAPSEMODE_WARN_COLOR / 255.0 ), 0.5 )
		//	RuiSetBool( rui, "blink", true )
		//	RuiSetBool( rui, "borderBlink", true )
		//	break

		//case RING_FISSURE:
		//	RuiSetColorAlpha( rui, "objColor", SrgbToLinear( RING_COLLAPSEMODE_DANGER_COLOR / 255.0 ), 1.0 )
		//	RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( RING_COLLAPSEMODE_DANGER_COLOR_BORDER / 255.0 ), 1.0 )
		//	RuiSetBool( rui, "blink", false )
		//	RuiSetBool( rui, "borderBlink", false )
		//	break
	}
}


void function MinimapPackage_ObjectiveAreaInit( entity ent, var rui )
{
	RuiSetFloat( rui, "radiusScale", SURVIVAL_MINIMAP_RING_SCALE )
	RuiTrackFloat( rui, "objectRadius", ent, RUI_TRACK_MINIMAP_SCALE )
	RuiSetImage( rui, "clampedImage", $"" )
	RuiSetImage( rui, "centerImage", $"" )
	RuiSetBool( rui, "blink", true )

	switch ( ent.GetTargetName() )
	{
		case "safeZone":
			RuiTrackFloat3( rui, "playerPos", GetLocalViewPlayer(), RUI_TRACK_ABSORIGIN_FOLLOW )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( SAFE_ZONE_COLOR ), SAFE_ZONE_ALPHA )  //
			RuiSetBool( rui, "drawLine", true )
			break

		case "safeZone_noline":
			//
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( SAFE_ZONE_COLOR ), SAFE_ZONE_ALPHA )  //
			//
			break

		case "surveyZone":
			RuiSetBool( rui, "blink", false )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( TEAM_COLOR_PARTY / 255.0 ), 0.05 )  //
			break

#if(true)

		case "trainIcon":
			//
			//
			RuiSetBool( rui, "blink", false )
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( TEAM_COLOR_PARTY / 255.0 ), 1.0 )  //
			break
#endif

#if(false)






//







//

#endif

		case "hotZone":
			RuiSetColorAlpha( rui, "objColor", SrgbToLinear( <128, 188, 255> / 255.0 ), 0.25 )
			RuiSetColorAlpha( rui, "objBorderColor", SrgbToLinear( <128, 188, 255> / 255.0 ), 0.5 )
			RuiSetBool( rui, "blink", true )
			RuiSetBool( rui, "borderBlink", true )
			break
	}
}


void function CLSurvival_RegisterNetworkFunctions()
{
	if ( IsLobby() )
		return

	RegisterNetworkedVariableChangeCallback_time( "nextCircleStartTime", NextCircleStartTimeChanged )
	RegisterNetworkedVariableChangeCallback_time( "circleCloseTime", CircleCloseTimeChanged )
	RegisterNetworkedVariableChangeCallback_bool( "isHealing", OnIsHealingChanged )
}


void function ScorebarInitTracking( entity player, var statusRui )
{
	RuiTrackInt( statusRui, "connectedPlayerCount", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "connectedPlayerCount" ) )
	RuiTrackFloat( statusRui, "deathfieldDistance", player, RUI_TRACK_DEATHFIELD_DISTANCE )
	RuiTrackInt( statusRui, "teamMemberIndex", player, RUI_TRACK_PLAYER_TEAM_MEMBER_INDEX )


	if( Gamemode() != eGamemodes.fs_snd && Playlist() != ePlaylists.fs_scenarios )
	{
		RuiTrackInt( statusRui, "livingPlayerCount", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "livingPlayerCount" ) )
		RuiTrackInt( statusRui, "squadsRemainingCount", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "squadsRemainingCount" ) )
	}

	if ( GetCurrentPlaylistVarBool( "second_scorebar_enabled", false ) == true || Gamemode() == eGamemodes.fs_infected )
	{
		RuiTrackInt( statusRui, "squadsRemainingCount", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "livingPlayerCount" ) )
		RuiTrackInt( statusRui, "squadsRemainingCount2", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "livingShadowPlayerCount" ) )
	}
}


void function OnHealthPickupTypeChanged( entity player, int oldKitType, int kitType, bool actuallyChanged )
{
	if ( WeaponDrivenConsumablesEnabled() )
	{
		Consumable_OnSelectedConsumableTypeNetIntChanged( player, oldKitType, kitType, actuallyChanged )
	}

	if ( !IsLocalViewPlayer( player ) )
		return

	if(!GetCurrentPlaylistVarBool( "firingrange_aimtrainerbycolombia", false ))
		UpdateDpadHud( player )
}


void function UpdateDpadHud( entity player )
{
	if ( !IsValid( player ) || file.pilotRui == null || file.dpadMenuRui == null )
		return

	if ( !IsLocalViewPlayer( player ) )
		return

	PerfStart( PerfIndexClient.SUR_HudRefresh )

	PerfStart( PerfIndexClient.SUR_HudRefresh_1 )
	int healthItems = SURVIVAL_Loot_GetTotalHealthItems( player, eHealthPickupCategory.HEALTH )
	PerfEnd( PerfIndexClient.SUR_HudRefresh_1 )
	RuiSetInt( file.dpadMenuRui, "totalHealthPackCount", healthItems )
	PerfStart( PerfIndexClient.SUR_HudRefresh_2 )
	int shieldItems = SURVIVAL_Loot_GetTotalHealthItems( player, eHealthPickupCategory.SHIELD )
	PerfEnd( PerfIndexClient.SUR_HudRefresh_2 )
	RuiSetInt( file.dpadMenuRui, "totalShieldPackCount", shieldItems )

	int kitType = Survival_Health_GetSelectedHealthPickupType()
	if ( kitType != -1 )
	{
		PerfStart( PerfIndexClient.SUR_HudRefresh_3 )
		string kitRef    = SURVIVAL_Loot_GetHealthPickupRefFromType( kitType )
		LootData kitData = SURVIVAL_Loot_GetLootDataByRef( kitRef )
		PerfEnd( PerfIndexClient.SUR_HudRefresh_3 )
		RuiSetInt( file.dpadMenuRui, "selectedHealthPickupCount", SURVIVAL_CountItemsInInventory( player, kitRef ) )
		RuiSetImage( file.dpadMenuRui, "selectedHealthPickupIcon", kitData.hudIcon )
		if ( PlayerHasPassive( player, ePassives.PAS_INFINITE_HEAL ) )
			RuiSetBool( file.dpadMenuRui, "isInfinite", true )
		else
			RuiSetBool( file.dpadMenuRui, "isInfinite", false )
	}
	else
	{
		RuiSetInt( file.dpadMenuRui, "selectedHealthPickupCount", -1 )
		RuiSetImage( file.dpadMenuRui, "selectedHealthPickupIcon", $"rui/hud/gametype_icons/survival/health_pack_auto" )
	}
	PerfEnd( PerfIndexClient.SUR_HudRefresh )

	// if( Flowstate_IsHaloMode() )
	// {
		// RuiSetInt( file.dpadMenuRui, "selectedHealthPickupCount", 1 )
		// RuiSetImage( file.dpadMenuRui, "selectedHealthPickupIcon", $"rui/pilot_loadout/tactical/pilot_tactical_cloak" )
	// }

	RuiSetInt( file.dpadMenuRui, "healthTypeCount", GetCountForLootType( eLootType.HEALTH ) )

	entity ordnanceWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
	int ordnanceAmmo      = 0
	asset ordnanceIcon    = $""

	if ( IsValid( ordnanceWeapon ) )
	{
		string ordnanceRef = ordnanceWeapon.GetWeaponClassName()
		if ( SURVIVAL_Loot_IsRefValid( ordnanceRef ) )
		{
			LootData ordnanceLootData = SURVIVAL_Loot_GetLootDataByRef( ordnanceRef )
			if ( ordnanceLootData.lootType == eLootType.ORDNANCE )
			{
				ordnanceAmmo = SURVIVAL_CountItemsInInventory( player, ordnanceRef )
				ordnanceIcon = ordnanceWeapon.GetWeaponSettingAsset( eWeaponVar.hud_icon )
			}
		}
	}

	RuiSetImage( file.dpadMenuRui, "ordnanceIcon", ordnanceIcon )
	RuiSetInt( file.dpadMenuRui, "ordnanceCount", ordnanceAmmo )
	RuiSetInt( file.dpadMenuRui, "ordnanceTypeCount", GetCountForLootType( eLootType.ORDNANCE ) )

	RuiSetBool( file.dpadMenuRui, "gadgetUIEnabled", true )
	asset gadgetIcon = $"rui/hud/dpad/empty_slot"
	LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "gadgetslot" )
	string gadgetRef = EquipmentSlot_GetLootRefForSlot( player, "gadgetslot" )
	int gadgetAmmo = 0
	int maxAmmoCount = 0
	if ( gadgetRef == "" && IsLootTypeValid( lootData.lootType ) && SURVIVAL_Loot_IsRefValid( lootData.ref ) )
		gadgetRef = lootData.ref

	if ( gadgetRef != "" && SURVIVAL_Loot_IsRefValid( gadgetRef ) )
	{
		LootData gadgetLootData = SURVIVAL_Loot_GetLootDataByRef( gadgetRef )
		if ( gadgetLootData.lootType == eLootType.SURVIVAL )
		{
			gadgetIcon = gadgetLootData.hudIcon
			maxAmmoCount = gadgetLootData.inventorySlotCount
			gadgetAmmo = SURVIVAL_CountItemsInInventory( player, gadgetRef )
		}

		entity gadgetWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
		if ( IsValid( gadgetWeapon ) && gadgetWeapon.GetWeaponClassName() == gadgetRef )
			gadgetAmmo = gadgetWeapon.GetWeaponPrimaryClipCount()
	}

	if ( gadgetRef == "" )
	{
		entity gadgetWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
		if ( IsValid( gadgetWeapon ) )
		{
			string activeRef = gadgetWeapon.GetWeaponClassName()
			if ( SURVIVAL_Loot_IsRefValid( activeRef ) )
			{
				LootData activeLootData = SURVIVAL_Loot_GetLootDataByRef( activeRef )
				if ( activeLootData.lootType == eLootType.SURVIVAL )
				{
					gadgetIcon = activeLootData.hudIcon
					maxAmmoCount = activeLootData.inventorySlotCount
					gadgetAmmo = gadgetWeapon.GetWeaponPrimaryClipCount()
				}
			}
		}

	}
	RuiSetImage( file.dpadMenuRui, "gadgetIcon", gadgetIcon )
	RuiSetInt( file.dpadMenuRui, "gadgetCount", gadgetAmmo )
	RuiSetInt( file.dpadMenuRui, "maxGadgetCount", maxAmmoCount )

	int useSurvivalSlotButton = GetConVarInt( "hud_setting_showButtonHints" )
	bool showGadgetButtonText = (useSurvivalSlotButton == 0)
	RuiSetBool( file.dpadMenuRui, "showGadgetButtonText", showGadgetButtonText )
		if ( StatusEffect_GetSeverity( player, eStatusEffect.is_boxing ) > 0  )
		{
			RuiSetBool( file.dpadMenuRui, "isBoxing", true )
		}
		else
		{
			RuiSetBool( file.dpadMenuRui, "isBoxing", false )
		}
}

void function UpdateDpadHud_Copy()
{
	entity player = GetLocalViewPlayer()

	if ( !IsValid( player ) || file.pilotRui == null || file.dpadMenuRui == null )
		return

	if ( !IsLocalViewPlayer( player ) )
		return

	PerfStart( PerfIndexClient.SUR_HudRefresh )

	PerfStart( PerfIndexClient.SUR_HudRefresh_1 )
	int healthItems = SURVIVAL_Loot_GetTotalHealthItems( player, eHealthPickupCategory.HEALTH )
	PerfEnd( PerfIndexClient.SUR_HudRefresh_1 )
	RuiSetInt( file.dpadMenuRui, "totalHealthPackCount", healthItems )
	PerfStart( PerfIndexClient.SUR_HudRefresh_2 )
	int shieldItems = SURVIVAL_Loot_GetTotalHealthItems( player, eHealthPickupCategory.SHIELD )
	PerfEnd( PerfIndexClient.SUR_HudRefresh_2 )
	RuiSetInt( file.dpadMenuRui, "totalShieldPackCount", shieldItems )

	int kitType = Survival_Health_GetSelectedHealthPickupType()
	if ( kitType != -1 )
	{
		PerfStart( PerfIndexClient.SUR_HudRefresh_3 )
		string kitRef    = SURVIVAL_Loot_GetHealthPickupRefFromType( kitType )
		LootData kitData = SURVIVAL_Loot_GetLootDataByRef( kitRef )
		PerfEnd( PerfIndexClient.SUR_HudRefresh_3 )
		RuiSetInt( file.dpadMenuRui, "selectedHealthPickupCount", SURVIVAL_CountItemsInInventory( player, kitRef ) )
		RuiSetImage( file.dpadMenuRui, "selectedHealthPickupIcon", kitData.hudIcon )
	}
	else
	{
		RuiSetInt( file.dpadMenuRui, "selectedHealthPickupCount", -1 )
		RuiSetImage( file.dpadMenuRui, "selectedHealthPickupIcon", $"rui/hud/gametype_icons/survival/health_pack_auto" )
	}
	PerfEnd( PerfIndexClient.SUR_HudRefresh )

	// if( Flowstate_IsHaloMode() )
	// {
		// RuiSetInt( file.dpadMenuRui, "selectedHealthPickupCount", 1 )
		// RuiSetImage( file.dpadMenuRui, "selectedHealthPickupIcon", $"rui/pilot_loadout/tactical/pilot_tactical_cloak" )
	// }

	RuiSetInt( file.dpadMenuRui, "healthTypeCount", GetCountForLootType( eLootType.HEALTH ) )

	entity ordnanceWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
	int ordnanceAmmo      = 0
	asset ordnanceIcon    = $""

	if ( IsValid( ordnanceWeapon ) )
	{
		string ordnanceRef = ordnanceWeapon.GetWeaponClassName()
		if ( SURVIVAL_Loot_IsRefValid( ordnanceRef ) )
		{
			LootData ordnanceLootData = SURVIVAL_Loot_GetLootDataByRef( ordnanceRef )
			if ( ordnanceLootData.lootType == eLootType.ORDNANCE )
			{
				ordnanceAmmo = SURVIVAL_CountItemsInInventory( player, ordnanceRef )
				ordnanceIcon = ordnanceWeapon.GetWeaponSettingAsset( eWeaponVar.hud_icon )
			}
		}
	}

	RuiSetImage( file.dpadMenuRui, "ordnanceIcon", ordnanceIcon )
	RuiSetInt( file.dpadMenuRui, "ordnanceCount", ordnanceAmmo )
	RuiSetInt( file.dpadMenuRui, "ordnanceTypeCount", GetCountForLootType( eLootType.ORDNANCE ) )

	RuiSetBool( file.dpadMenuRui, "gadgetUIEnabled", true )
	asset gadgetIcon = $"rui/hud/dpad/empty_slot"
	LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "gadgetslot" )
	string gadgetRef = EquipmentSlot_GetLootRefForSlot( player, "gadgetslot" )
	int gadgetAmmo = 0
	int maxAmmoCount = 0
	if ( gadgetRef == "" && IsLootTypeValid( lootData.lootType ) && SURVIVAL_Loot_IsRefValid( lootData.ref ) )
		gadgetRef = lootData.ref

	if ( gadgetRef != "" && SURVIVAL_Loot_IsRefValid( gadgetRef ) )
	{
		LootData gadgetLootData = SURVIVAL_Loot_GetLootDataByRef( gadgetRef )
		if ( gadgetLootData.lootType == eLootType.SURVIVAL )
		{
			gadgetIcon = gadgetLootData.hudIcon
			maxAmmoCount = gadgetLootData.inventorySlotCount
			gadgetAmmo = SURVIVAL_CountItemsInInventory( player, gadgetRef )
		}

		entity gadgetWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
		if ( IsValid( gadgetWeapon ) && gadgetWeapon.GetWeaponClassName() == gadgetRef )
			gadgetAmmo = gadgetWeapon.GetWeaponPrimaryClipCount()
	}

	if ( gadgetRef == "" )
	{
		entity gadgetWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )
		if ( IsValid( gadgetWeapon ) )
		{
			string activeRef = gadgetWeapon.GetWeaponClassName()
			if ( SURVIVAL_Loot_IsRefValid( activeRef ) )
			{
				LootData activeLootData = SURVIVAL_Loot_GetLootDataByRef( activeRef )
				if ( activeLootData.lootType == eLootType.SURVIVAL )
				{
					gadgetIcon = activeLootData.hudIcon
					maxAmmoCount = activeLootData.inventorySlotCount
					gadgetAmmo = gadgetWeapon.GetWeaponPrimaryClipCount()
				}
			}
		}

	}
	RuiSetImage( file.dpadMenuRui, "gadgetIcon", gadgetIcon )
	RuiSetInt( file.dpadMenuRui, "gadgetCount", gadgetAmmo )
	RuiSetInt( file.dpadMenuRui, "maxGadgetCount", maxAmmoCount )

	int useSurvivalSlotButton = GetConVarInt( "hud_setting_showButtonHints" )
	bool showGadgetButtonText = (useSurvivalSlotButton == 0)
	RuiSetBool( file.dpadMenuRui, "showGadgetButtonText", showGadgetButtonText )
}

array<void functionref( bool )> s_callbacks_OnUpdateShowButtonHints
void function AddCallback_OnUpdateShowButtonHints( void functionref( bool ) func )
{
	Assert( !s_callbacks_OnUpdateShowButtonHints.contains( func ) )
	s_callbacks_OnUpdateShowButtonHints.append( func )
}

array<void functionref( entity, ItemFlavor, int )> s_callbacks_OnVictoryCharacterModelSpawned
void function AddCallback_OnVictoryCharacterModelSpawned( void functionref( entity, ItemFlavor, int ) func )
{
	Assert( !s_callbacks_OnVictoryCharacterModelSpawned.contains( func ) )
	s_callbacks_OnVictoryCharacterModelSpawned.append( func )
}

void function OnResolutionChanged_FixRuiSize()
{
	if( GetGameState() == eGameState.WaitingForPlayers )
	{
		UpdateFullscreenTopology( clGlobal.topoFullscreenHud, true, true )
		UpdateFullscreenTopology( clGlobal.topoFullscreenHudPermanent, true, true )
		UpdateFullscreenTopology( clGlobal.topFullscreenTargetInfo, true )
		FS_GamemodeHudSetup()
	}
}

bool s_didScorebarSetup = false
void function GameModeScoreBarRules( var gamestateRui )
{
	if ( !s_didScorebarSetup )
	{
		entity player = GetLocalViewPlayer()
		if ( !IsValid( player ) )
			return

		ScorebarInitTracking( player, gamestateRui )
		RuiSetBool( gamestateRui, "hideSquadsRemaining", GetCurrentPlaylistVarBool( "scorebar_hide_squads_remaining", false ) )
		RuiSetBool( gamestateRui, "hideWaitingForPlayers", GetCurrentPlaylistVarBool( "scorebar_hide_waiting_for_players", false ) )

		s_didScorebarSetup = true

		UpdateGamestateRuiTracking( player )

		//
		file.shouldShowButtonHintsLocal = !ShouldShowButtonHints()
	}

	PerfStart( PerfIndexClient.SUR_ScoreBoardRules_1 )
	PerfStart( PerfIndexClient.SUR_ScoreBoardRules_2 )

	if ( file.shouldShowButtonHintsLocal != ShouldShowButtonHints() )
	{
		entity player = GetLocalViewPlayer()
		if ( !IsValid( player ) )
			return

		bool showButtonHints = ShouldShowButtonHints()

		Minimap_UpdateShowButtonHint()
		ClWeaponStatus_UpdateShowButtonHint()
		if ( file.dpadMenuRui != null )
			RuiSetBool( file.dpadMenuRui, "showButtonHints", showButtonHints )

		//
		foreach( func in s_callbacks_OnUpdateShowButtonHints )
			func( showButtonHints )

		file.shouldShowButtonHintsLocal = showButtonHints
	}

	PerfEnd( PerfIndexClient.SUR_ScoreBoardRules_2 )

	PerfStart( PerfIndexClient.SUR_ScoreBoardRules_3 )

	float endTime = GetNV_PreGameStartTime()
	if ( endTime != 0.0 )
		RuiSetGameTime( gamestateRui, "endTime", endTime )

	PerfEnd( PerfIndexClient.SUR_ScoreBoardRules_3 )
	PerfEnd( PerfIndexClient.SUR_ScoreBoardRules_1 )
}


void function OnIsHealingChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	if ( player != GetLocalClientPlayer() )
		return

	UpdateHealHint( player )
}


void function SetNextCircleDisplayCustom_( NextCircleDisplayCustomData data )
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( !IsValid( localViewPlayer ) )
		return

	var gamestateRui = ClGameState_GetRui()
	array<var> ruis = [gamestateRui]
	var cameraRui = GetCameraCircleStatusRui()
	if ( IsValid( cameraRui ) )
		ruis.append( cameraRui )

	foreach( rui in ruis )
	{
		RuiTrackFloat3( rui, "playerOrigin", localViewPlayer, RUI_TRACK_ABSORIGIN_FOLLOW )

		RuiSetGameTime( rui, "circleStartTime", data.circleStartTime )
		RuiSetGameTime( rui, "circleCloseTime", data.circleCloseTime )
		RuiSetInt( rui, "roundNumber", data.roundNumber )
		RuiSetString( rui, "roundClosingString", data.roundString )

		RuiSetFloat3( rui, "deathFieldOrigin", data.deathFieldOrigin )
		RuiSetFloat3( rui, "safeZoneOrigin", data.safeZoneOrigin )

		RuiSetFloat( rui, "deathfieldDistance", data.deathfieldDistance )
		RuiSetFloat( rui, "deathfieldStartRadius", data.deathfieldStartRadius )
		RuiSetFloat( rui, "deathfieldEndRadius", data.deathfieldEndRadius )

		RuiSetBool( rui, "hasAltIcon", (data.altIcon != $"") )
		RuiSetImage( rui, "altIcon", data.altIcon )
		RuiSetString( rui, "altIconText", data.altIconText )
	}
}


void function SetNextCircleDisplayCustomStarting( float circleStartTime, asset altIcon, string altIconText )
{
	NextCircleDisplayCustomData data
	data.circleStartTime = circleStartTime
	data.roundNumber = -1
	data.altIcon = altIcon
	data.altIconText = altIconText
	SetNextCircleDisplayCustom_( data )
}


void function SetNextCircleDisplayCustomClosing( float circleCloseTime, string prompt )
{
	NextCircleDisplayCustomData data
	data.circleStartTime = Time() - 4.0
	data.circleCloseTime = circleCloseTime
	data.roundString = prompt
	data.roundNumber = -1
	SetNextCircleDisplayCustom_( data )
}


void function SetNextCircleDisplayCustomClear()
{
	NextCircleDisplayCustomData data
	SetNextCircleDisplayCustom_( data )
}


void function NextCircleStartTimeChanged( entity player, float old, float new, bool actuallyChanged )
{
	if ( !actuallyChanged  || ! CircleAnnouncementsEnabled() )
		return

    if(SURVIVAL_GetCurrentDeathFieldStage() == -1)
        return
	UpdateFullmapRuiTracks()

	var gamestateRui = ClGameState_GetRui()
	array<var> ruis = [gamestateRui]
	var cameraRui = GetCameraCircleStatusRui()
	if ( IsValid( cameraRui ) )
		ruis.append( cameraRui )


	int roundNumber = (SURVIVAL_GetCurrentDeathFieldStage() + 1)
	string roundString = Localize( "#SURVIVAL_CIRCLE_STATUS_ROUND_CLOSING", roundNumber )
	if ( SURVIVAL_IsFinalDeathFieldStage() )
		roundString = Localize( "#SURVIVAL_CIRCLE_STATUS_ROUND_CLOSING_FINAL" )
	DeathFieldStageData data = GetDeathFieldStage( SURVIVAL_GetCurrentDeathFieldStage() )
	float currentRadius      = SURVIVAL_GetDeathFieldCurrentRadius()
	float endRadius          = data.endRadius

	foreach( rui in ruis )
	{
		RuiSetGameTime( rui, "circleStartTime", new )
		RuiSetInt( rui, "roundNumber", roundNumber )
		RuiSetString( rui, "roundClosingString", roundString )

		entity localViewPlayer = GetLocalViewPlayer()
		if ( IsValid( localViewPlayer ) )
		{
			RuiSetFloat( rui, "deathfieldStartRadius", currentRadius )
			RuiSetFloat( rui, "deathfieldEndRadius", endRadius )
			RuiTrackFloat3( rui, "playerOrigin", localViewPlayer, RUI_TRACK_ABSORIGIN_FOLLOW )

			#if(true)
				RuiTrackInt( rui, "teamMemberIndex", localViewPlayer, RUI_TRACK_PLAYER_TEAM_MEMBER_INDEX )
			#endif
		}
	}

	if ( new < Time() )
		return

	if ( actuallyChanged && GamePlaying() && Playlist() != ePlaylists.fs_movementgym )
	{
		if ( !GetCurrentPlaylistVarBool( "deathfield_starts_after_ship_flyout", true ) && SURVIVAL_GetCurrentDeathFieldStage() == 0 )
			return //

		if ( SURVIVAL_IsFinalDeathFieldStage() )
			roundString = "#SURVIVAL_CIRCLE_ROUND_FINAL"
		else
			roundString = Localize( "#SURVIVAL_CIRCLE_ROUND", SURVIVAL_GetCurrentRoundString() )

		float duration = 7.0

		AnnouncementData announcement
		announcement = Announcement_Create( "" )
		Announcement_SetSubText( announcement, roundString )
		Announcement_SetHeaderText( announcement, "#SURVIVAL_CIRCLE_WARNING" )
		Announcement_SetDisplayEndTime( announcement, new )
		Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING )
		Announcement_SetSoundAlias( announcement, CIRCLE_CLOSING_IN_SOUND )
		Announcement_SetPurge( announcement, true )
		Announcement_SetPriority( announcement, 200 ) //
		Announcement_SetDuration( announcement, duration )

		AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	}
}


void function CircleCloseTimeChanged( entity player, float old, float new, bool actuallyChanged )
{
	var gamestateRui = ClGameState_GetRui()
	array<var> ruis = [gamestateRui]
	var cameraRui = GetCameraCircleStatusRui()
	if ( IsValid( cameraRui ) )
		ruis.append( cameraRui )
	foreach( rui in ruis )
	{
		RuiSetGameTime( rui, "circleCloseTime", new )
	}

	UpdateFullmapRuiTracks()
}


void function InventoryCountChanged( entity player, int old, int new, bool actuallyChanged )
{
	ResetInventoryMenu( player )
}


asset function GetArmorIconForTypeIndex( int typeIndex )
{
	switch ( typeIndex )
	{
		case 1:
			return $"rui/hud/gametype_icons/survival/sur_armor_icon_l1"

		case 2:
			return $"rui/hud/gametype_icons/survival/sur_armor_icon_l2"

		case 3:
			return $"rui/hud/gametype_icons/survival/sur_armor_icon_l3"

		default:
			return $""
	}

	unreachable
}


void function EquipmentChanged( entity player, string equipSlot, int new )
{
	int tier          = 0
	EquipmentSlot es  = Survival_GetEquipmentSlotDataByRef( equipSlot )
	asset hudIcon     = es.emptyImage
	int armorCapacity = -1

	bool isEvo   = false
	int evoCount = 0

	if ( new > -1 )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( new )
		tier = data.tier
		hudIcon = data.hudIcon

		if ( data.lootType == eLootType.ARMOR )
		{
			armorCapacity = SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data )
		}

		if ( es.attachmentPoint != "" )
		{
			string attachmentStyle = GetAttachmentPointStyle( es.attachmentPoint, data.ref )
			hudIcon = emptyAttachmentSlotImages[attachmentStyle]
		}
	}


		LootData data = EquipmentSlot_GetEquippedLootDataForSlot( player, "armor" )
		if ( data.lootType == eLootType.ARMOR && EvolvingArmor_IsEquipmentEvolvingArmor( data.ref ) )
		{
			isEvo = true
			evoCount = EvolvingArmor_GetRequirementForEvolution( data.tier )
		}

	if ( player == GetLocalViewPlayer() )
	{
		if ( es.unitFrameTierVar != "" )

		RuiSetInt( file.pilotRui, es.unitFrameTierVar, tier )
		if ( es.unitFrameImageVar != "" )
		RuiSetImage( file.pilotRui, es.unitFrameImageVar, hudIcon )
		if ( armorCapacity >= 0 )
		{
			RuiSetInt( file.pilotRui, "armorShieldCapacity", armorCapacity )
		}

			if ( data.lootType == eLootType.ARMOR )
			{
				if ( EvolvingArmor_IsEquipmentEvolvingArmor( data.ref ) )
				{
					RuiSetBool( file.pilotRui, "evoShieldDoubleDisplayAmount", EvolvingArmor_ExceedsMaxIntLimit( data ) )
					RuiSetBool( file.pilotRui, "isEvolvingShield", isEvo )
					RuiTrackInt( file.pilotRui, "evolvingShieldKillCounter", player, RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( NV_EVOLVING_ARMOR_KILL_COUNT ) )
				}
				else
				{
					RuiSetBool( file.pilotRui, "isEvolvingShield", false )
				}
			}
			else if ( data.ref == "" )
			{
				RuiSetBool( file.pilotRui, "isEvolvingShield", false )
			}



			RuiSetBool( file.pilotRui, "hasReducedShieldValues", true )
		UpdateActiveLootPings()
	}
	else
	{
		if ( PlayerHasUnitFrame( player ) )
		{
			var rui = GetUnitFrame( player ).rui

			RuiSetInt( rui, "armorShieldCapacity", armorCapacity )
		}
	}

	if ( player == GetLocalClientPlayer() )
	{
		ResetInventoryMenu( player )
	}
}


void function BackpackChanged( entity player, string equipSlot, int new )
{
	int tier         = 0
	EquipmentSlot es = Survival_GetEquipmentSlotDataByRef( equipSlot )
	asset hudIcon    = es.emptyImage

	if ( new > -1 )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( new )
		tier = data.tier
		hudIcon = data.hudIcon
	}

	if ( player == GetLocalViewPlayer() )
	{
		RuiSetImage( file.dpadMenuRui, "backpackIcon", hudIcon )
		RuiSetInt( file.dpadMenuRui, "backpackTier", tier )
	}
}


void function UpdateActiveLootPings()
{
	entity player           = GetLocalViewPlayer()
	array<entity> waypoints = Waypoints_GetActiveLootPings()
	foreach ( wp in waypoints )
	{
		entity owner = wp.GetOwner()
		if ( owner != player )
		{
			entity lootItem = Waypoint_GetItemEntForLootWaypoint( wp )
			if ( !IsValid( lootItem ) )
				continue

			LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( lootItem.GetSurvivalInt() )
			RuiSetBool( wp.wp.ruiHud, "isImportant", SURVIVAL_IsLootAnUpgrade( player, lootItem, lootData, eLootContext.GROUND ) )
		}
	}
}


void function LinkContestedChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	if ( player != GetLocalClientPlayer() )
		return

	if ( player != GetLocalViewPlayer() )
		return

	RuiSetBool( file.titanLinkProgressRui, "isContested", new )
}


void function LinkInUseChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	if ( player != GetLocalClientPlayer() )
		return

	if ( player != GetLocalViewPlayer() )
		return

	RuiSetBool( file.titanLinkProgressRui, "isInUse", new )
}


void function Survival_SetPilotHudVisible( bool visible )
{
	if ( file.pilotRui != null )
		RuiSetBool( file.pilotRui, "isVisible", visible )
	if ( file.dpadMenuRui != null )
		RuiSetBool( file.dpadMenuRui, "isVisible", visible )
	if ( file.compassRui != null )
		RuiSetBool( file.compassRui, "isVisible", visible )
}

void function OnPilotCockpitCreated( entity cockpit, entity player )
{
	if ( file.pilotRui != null )
		RuiSetBool( file.pilotRui, "isVisible", GetHudDefaultVisibility() )

	if ( player == GetLocalViewPlayer() )
	{
		RuiTrackBool( file.dpadMenuRui, "inventoryEnabled", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR_BOOL, GetNetworkedVariableIndex( "inventoryEnabled" ) )
		RuiTrackInt( file.dpadMenuRui, "selectedHealthPickup", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "selectedHealthPickupType" ) )
		RuiTrackFloat( file.dpadMenuRui, "bleedoutEndTime", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )

		EquipmentSlot es = Survival_GetEquipmentSlotDataByRef( "backpack" )
		RuiSetImage( file.dpadMenuRui, "backpackIcon", es.emptyImage )
		RuiSetInt( file.dpadMenuRui, "backpackTier", 0 )

		foreach ( equipSlot, data in EquipmentSlot_GetAllEquipmentSlots() )
		{
			if ( data.trackingNetInt != "" )
			{
				EquipmentChanged( GetLocalViewPlayer(), equipSlot, EquipmentSlot_GetEquippedLootDataForSlot( player, equipSlot ).index )
			}
		}
	}
}


void function ToggleFireSelect( entity player )
{
	if ( file.nextAllowToggleFireRateTime > Time() )
		return

	file.nextAllowToggleFireRateTime = Time() + 0.05

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return

	if( weapon.GetWeaponClassName() == "mp_weapon_titan_sword" )
		return

	if ( weapon.IsDiscarding() )
		return

	if ( player.GetWeaponDisableFlags() == WEAPON_DISABLE_FLAGS_ALL )
		return

	foreach ( mod, toggleMod in GetAttachmentsWithToggleModsList() )
	{
		if ( IsModActive( weapon, mod ) )
		{
			WeaponModCommand_Toggle( toggleMod )
			return
		}
	}

	bool canToggleAltfire = DoesModExist( weapon, "altfire" ) && !DoesModExist( weapon, "hopup_selectfire" )

	if ( canToggleAltfire && IsModActive( weapon, "hopup_highcal_rounds" ) )
		canToggleAltfire = false

	if ( canToggleAltfire )
	{
		WeaponModCommand_Toggle( "altfire" )
		return
	}

	// if( DoesModExist( weapon, "choke" ) )
	// {
		// WeaponModCommand_Toggle( "choke" )
		// return
	// }
}


void function ServerCallback_SUR_PingMinimap( vector origin, float duration, float spreadRadius, float ringRadius, int colorIndex )
{
	vector color = TEAM_COLOR_ENEMY
	asset altIcon = $""
	switch ( colorIndex )
	{
		case 0:
			color = TEAM_COLOR_ENEMY
			break;

		case 1:
			color = TEAM_COLOR_FRIENDLY
			break;

		case 2:
			color = COLOR_AIRDROP
			break

		case 3:
			color = CRAFTING_COLOR
			altIcon = $"rui/hud/ping/hex_pulse"
			break
	}
	thread ServerCallback_SUR_PingMinimap_Internal( origin, duration, spreadRadius, ringRadius, color, altIcon )
}


void function ServerCallback_SUR_PingMinimap_Internal( vector origin, float duration, float spreadRadius, float ringRadius, vector color, asset altIcon = $"" )
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	float endTime = Time() + duration

	float randMin = -1 * spreadRadius
	float randMax = spreadRadius

	float minWait = 0.6
	float maxWait = 1.0

	float pulseDuration = 1.5
	float lifeTime      = 1.5

	while ( Time() < endTime )
	{
		vector newOrigin = origin + < RandomIntRange( randMin, randMax ), RandomIntRange( randMin, randMax ), 0 >  //

		Minimap_RingPulseAtLocation( newOrigin, ringRadius, color / 255.0, pulseDuration, lifeTime, false, altIcon )
		FullMap_PingLocation( newOrigin, ringRadius, color / 255.0, pulseDuration, lifeTime, false, altIcon )

		wait RandomFloatRange( minWait, maxWait )
	}
}
bool function FS_ShouldHookMapKey()
{
	if( Flowstate_IsHaloMode() && Playlist() != ePlaylists.fs_haloMod_survival && GetGameState() == eGameState.Playing
		|| Gamemode() == eGamemodes.CUSTOM_CTF && GetGameState() == eGameState.Playing
		|| Playlist() == ePlaylists.fs_1v1
		|| Playlist() == ePlaylists.fs_lgduels_1v1
		|| Playlist() == ePlaylists.fs_snd
		|| Playlist() == ePlaylists.fs_dm
		|| Playlist() == ePlaylists.fs_dm_fast_instagib
		|| Playlist() == ePlaylists.fs_realistic_ttv
		// || Playlist() == ePlaylists.fs_scenarios
	)
		return true

	return false
}

void function AllowSuperHint( entity player )
{
	file.superHintAllowed = true
}


void function Survival_OnPlayerClassChanged( entity player )
{
	if ( file.pilotRui == null )
		return

	if ( player != GetLocalViewPlayer() )
		return

	UpdateDpadHud( player )

	if ( player.IsTitan() )
	{
		if ( file.playerState != "titan" )
		{
			ResetInventoryMenu( player )
			file.playerState = "titan"
		}
	}
	else
	{
		bool resetInventory = false

		if ( file.playerState != "pilot" )
		{
			resetInventory = true
			file.playerState = "pilot"
		}

		if ( resetInventory )
		{
			ResetInventoryMenu( player )
		}

		bool isReady = LoadoutSlot_IsReady( ToEHI( player ), Loadout_Character() )
		if ( isReady )
		{
			thread InitSurvivalHealthBar()
		}
	}

	if ( player == GetLocalClientPlayer() )
	{
		thread PeriodicHealHint()
		thread TrackAmmoPool( player )
		thread TrackPrimaryWeapon( player )
		if ( file.pilotRui != null )
			thread TrackPrimaryWeaponEnabled( player, file.pilotRui, "Sur_EndTrackPrimary" )
	}

	ServerCallback_ClearHints()

	bool doublejumpTest = false
	foreach( mod in player.GetPlayerSettingsMods() )
		if( mod == "enable_doublejump" )
			doublejumpTest = true

	if( doublejumpTest )
	{
		if( !player.IsOnGround() )
		{
			thread function () : ( player )
			{
				EndSignal( player, "OnDeath" )

				AddPlayerHint( 5.0, 0.25, $"", "Press %jump% to double jump" ) //#JUMP_PAD_DOUBLE_JUMP_HINT

				OnThreadEnd(
					function () : ( player )
					{
						HidePlayerHint( "Press %jump% to double jump" ) //#JUMP_PAD_DOUBLE_JUMP_HINT
					}
				)

				bool stillHasDoubleJumpMod

				while( !player.IsOnGround() )
				{
					stillHasDoubleJumpMod = false

					foreach( mod in player.GetPlayerSettingsMods() )
						if( mod == "enable_doublejump" )
							stillHasDoubleJumpMod = true

					if( !stillHasDoubleJumpMod )
						break

					WaitFrame()
				}
			}()
		}
	}
}


void function OnPropScriptCreated( entity prop )
{
	if ( prop.GetTargetName() == "hotZone" )
		SetMapFeatureItem( 300, "#HOT_ZONE", "#HOT_ZONE_DESC", $"rui/hud/gametype_icons/survival/hot_zone" )
}


void function OnPropCreated( entity prop )
{
	if ( prop.GetSurvivalInt() < 0 )
	{
		PROTO_OnContainerCreated( prop )
		return
	}
}


string function DroppodButtonUseTextOverride( entity prop )
{
	if ( GetLocalViewPlayer().GetParent() != null )
		return " "
	return ""
}


void function OpenSurvivalMenu()
{
	entity player = GetLocalClientPlayer()

	if ( !IsAlive( player ) || player != GetLocalClientPlayer() )
	{
		RunUIScript( "ServerCallback_OpenSurvivalExitMenu", false )
	}
	else
	{
		PROTO_OpenInventoryOrSpecifiedMenu( player )
	}
}


void function PROTO_OpenInventoryOrSpecifiedMenu( entity player )
{
	HideScoreboard()

	if( Playlist() == ePlaylists.fs_scenarios && player.GetPlayerNetTime( "FS_Scenarios_timePlayerEnteredInLobby" ) != -1 && IsAlive( GetLocalClientPlayer() ) )
	{
		RunUIScript( "UI_OpenScenariosStandingsMenu" )
		return
	}

	OpenSurvivalInventory( player )
}


void function OpenQuickSwap( entity player )
{
	thread TryOpenQuickSwap()
}


void function PeriodicHealHint()
{
	while ( IsAlive( GetLocalClientPlayer() ) )
	{
		wait 30.0
		UpdateHealHint( GetLocalClientPlayer() )
	}
}


void function TrackAmmoPool( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return
	if ( player != GetLocalClientPlayer() )
		return

	player.Signal( "Sur_EndTrackAmmo" )
	player.EndSignal( "Sur_EndTrackAmmo" )
	player.EndSignal( "OnDeath" )

	table<string, int> oldAmmo
	foreach ( ammoRef, value in eAmmoPoolType )
	{
		oldAmmo[ ammoRef ] <- 0
	}

	while ( IsAlive( player ) )
	{
		bool resetAmmo = false
		foreach ( ammoRef, value in eAmmoPoolType )
		{
			int ammo = player.AmmoPool_GetCount( value )

			if ( ammo != oldAmmo[ ammoRef ] )
			{
				resetAmmo = true
				oldAmmo[ ammoRef ] = ammo
			}
		}

		if ( resetAmmo )
			ResetInventoryMenu( player )
		WaitFrame()
	}
}


void function TrackPrimaryWeapon( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( player != GetLocalClientPlayer() )
		return

	player.Signal( "Sur_EndTrackPrimary" )
	player.EndSignal( "Sur_EndTrackPrimary" )
	player.EndSignal( "OnDeath" )

	entity oldWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	int oldBitField  = 0

	if ( oldWeapon != null && oldWeapon.IsWeaponOffhand() )
		oldWeapon = null

	bool firstRun = true

	while ( IsAlive( player ) )
	{
		entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( IsValid( weapon ) && weapon.IsWeaponMelee() )
		{
			WaitFrame()
			continue
		}

		int bitField = 0

		if ( !player.IsTitan() )
		{
			if ( player.GetWeaponDisableFlags() != WEAPON_DISABLE_FLAGS_ALL )
			{
				if ( weapon != null && weapon.IsWeaponOffhand() )
					weapon = IsValid( oldWeapon ) ? oldWeapon : null
			}
			if ( weapon )
				bitField = weapon.GetModBitField()
		}

		if ( (weapon != oldWeapon || bitField != oldBitField || firstRun) )
		{
			firstRun = false

			if ( IsValid( weapon ) && weapon.GetWeaponType() != WT_ANTITITAN )
				file.lastPrimaryWeapon = weapon
			else
				file.lastPrimaryWeapon = null

			ServerCallback_ClearHints()

			if ( IsValid( weapon ) )
			{
				if ( weapon.GetWeaponType() == WT_ANTITITAN && SURVIVAL_GetAllPlayerOrdnance( player ).len() > 1 && !Flowstate_IsHaloMode() )
					ServerCallback_SurvivalHint( eSurvivalHints.ORDNANCE )
			}

			UpdateActiveLootPings()
			ResetInventoryMenu( player )
			oldWeapon = weapon
			oldBitField = bitField
		}
		WaitFrame()
	}
}


void function ServerCallback_SurvivalHint( int hintType )
{
	string hintString
	float duration = 8.0

	switch ( hintType )
	{
		case eSurvivalHints.EQUIP:
			hintString = "#SURVIVAL_ATTACH_HINT"
			break

		case eSurvivalHints.ORDNANCE:
			duration = 2.0
			hintString = "#SURVIVAL_ORDNANCE_HINT"
			break

		default:
			return
	}
	AddPlayerHint( duration, 0.5, $"", hintString )
}


void function ServerCallback_ClearHints()
{
	HidePlayerHint( "#SURVIVAL_MAP_HINT" )
	HidePlayerHint( "#SURVIVAL_ATTACH_HINT" )
	HidePlayerHint( "#SURVIVAL_DROPPOD_LAUNCH_HINT" )
	HidePlayerHint( "#SURVIVAL_DROPPOD_STEER_HINT" )
	HidePlayerHint( "#SURVIVAL_DROPPOD_ACTIVATE_HINT" )
	HidePlayerHint( "#SURVIVAL_TITAN_HOVER_HINT" )
}


void function SurvivalTitanHoverHint()
{
	ServerCallback_ClearHints()
	wait 4
	AddPlayerHint( 6.0, 0.5, $"", "#SURVIVAL_TITAN_HOVER_HINT" )
}


void function Sur_Cl_PickLoadout( entity player )
{

}


void function Survival_WaitForPlayers()
{
	file.cameFromWaitingForPlayersState = true
	SetDpadMenuVisible()
	SetMapSetting_FogEnabled( true )
	Minimap_UpdateMinimapVisibility( GetLocalClientPlayer() )
}


void function EnableToggleMuteKeys()
{
	if ( !SquadMuteIntroEnabled() )
		return

	if ( file.toggleMuteKeysEnabled )
		return

	RegisterButtonPressedCallback( BUTTON_Y, OnToggleMute )
	RegisterButtonPressedCallback( KEY_F, OnToggleMute )

	file.toggleMuteKeysEnabled = true
}


void function DisableToggleMuteKeys()
{
	DisableCustomMapAndGamemodeNameFrames()

	if ( !SquadMuteIntroEnabled() )
		return

	if ( !file.toggleMuteKeysEnabled )
		return

	DeregisterButtonPressedCallback( BUTTON_Y, OnToggleMute )
	DeregisterButtonPressedCallback( KEY_F, OnToggleMute )

	file.toggleMuteKeysEnabled = false
}


void function OnToggleMute( var button )
{
	ToggleSquadMute()
}

bool function GetWaitingForPlayersOverlayEnabled( entity player )
{
	if( Playlist() == ePlaylists.fs_movementgym )
		return false

	if ( IsTestMap() )
		return false

	// if ( player.GetTeam() == TEAM_SPECTATOR )
		// return false

	if ( GetCurrentPlaylistVarBool( "survival_staging_area_enabled", false ) )
		return false

	// if( GameRules_GetGameMode() != SURVIVAL )
		// return false

	if( Gamemode() == eGamemodes.fs_snd || Gamemode() == eGamemodes.fs_spieslegends )
		return false

	return true
}


var s_overlayRui = null
void function WaitingForPlayersOverlay_Setup( entity player )
{
	if ( !GetWaitingForPlayersOverlayEnabled( player ) )
		return

	s_overlayRui = CreatePermanentCockpitRui( $"ui/waiting_for_players_blackscreen.rpak", -1 )
	RuiSetResolutionToScreenSize( s_overlayRui )
	RuiSetBool( s_overlayRui, "isOpaque", PreGame_GetWaitingForPlayersHasBlackScreen() )

	UpdateWaitingForPlayersMuteHint()
}


void function WaitingForPlayersOverlay_Destroy()
{
	if( Gamemode() != eGamemodes.fs_aimtrainer )
		WaitingForPlayers_RemoveCustomCameras()

	if ( s_overlayRui == null )
		return

	RuiDestroyIfAlive( s_overlayRui )
	s_overlayRui = null
}

void function UpdateWaitingForPlayersMuteHint()
{
	if ( !s_overlayRui )
		return

	string muteString = ""
	if ( SquadMuteIntroEnabled() && !IsSoloMode() )
		muteString = Localize( IsSquadMuted() ? "#CHAR_SEL_BUTTON_UNMUTE" : "#CHAR_SEL_BUTTON_MUTE" )
	RuiSetString( s_overlayRui, "squadMuteHint", muteString )
}

void function WaitingForPlayers_CreateCustomCameras()
{
	if( IsDevGamemode() && s_overlayRui != null )
	{
		RuiSetBool( s_overlayRui, "isOpaque", true )
		return
	}

	entity player = GetLocalClientPlayer()

	WaitingForPlayersCameraLocPair waitingForPlayersCamera = ReturnCameraForThisTime()

	vector origin = waitingForPlayersCamera.origin
	origin.z += 100

	entity camera = CreateClientSidePointCamera( origin, waitingForPlayersCamera.angles, 70 )
	player.ClearMenuCameraEntity()
	player.SetMenuCameraEntityWithAudio( camera )
	camera.SetTargetFOV( 70, true, EASING_CUBIC_INOUT, 0.50 )

	if( Gamemode() == eGamemodes.fs_aimtrainer )
	{
		DisableCustomMapAndGamemodeNameFrames()
		return
	}
	//FS_GamemodeHudSetup()
}

void function FS_GamemodeHudSetup()
{
	Hud_SetVisible(HudElement( "WaitingForPlayers_GamemodeFrame" ), true)

	RuiSetImage( Hud_GetRui( HudElement( "WaitingForPlayers_GamemodeFrame" ) ), "basicImage", $"rui/gamemodes/survival/waitingforplayers/gamemode")
	RuiSetImage( Hud_GetRui( HudElement( "WaitingForPlayers_MapFrame" ) ), "basicImage", $"rui/gamemodes/survival/waitingforplayers/map")

	Hud_SetVisible(HudElement( "WaitingForPlayers_GamemodeName" ), true)
	Hud_SetVisible(HudElement( "WaitingForPlayers_MapFrame" ), true)
	Hud_SetVisible(HudElement( "WaitingForPlayers_MapName" ), true)

	string modeString
	string modeSubString
	switch( Playlist() )
	{
		default:
		modeString = GetCurrentPlaylistVarString( "name", "APEX" )
		modeSubString = "#" + GetMapName()
		break
	}

	Hud_SetText( HudElement( "WaitingForPlayers_GamemodeName"), modeString )
	Hud_SetText( HudElement( "WaitingForPlayers_MapName"), modeSubString)

}

void function DisableCustomMapAndGamemodeNameFrames()
{
	Hud_SetVisible(HudElement( "WaitingForPlayers_GamemodeFrame" ), false)
	Hud_SetVisible(HudElement( "WaitingForPlayers_GamemodeName" ), false)
	Hud_SetVisible(HudElement( "WaitingForPlayers_MapFrame" ), false)
	Hud_SetVisible(HudElement( "WaitingForPlayers_MapName" ), false)

}

void function WaitingForPlayers_RemoveCustomCameras()
{
	entity player = GetLocalClientPlayer()

	player.ClearMenuCameraEntity()
	SetMapSetting_FogEnabled( true )
	DisableCustomMapAndGamemodeNameFrames()

	if( Playlist() != ePlaylists.survival && Playlist() != ePlaylists.survival_duos && Playlist() != ePlaylists.survival_solos )
		return

	entity targetCamera = GetEntByScriptName( "target_char_sel_camera_new" )
	entity camera = CreateClientSidePointCamera( targetCamera.GetOrigin(), targetCamera.GetAngles(), 35.5 )
	player.SetMenuCameraEntity( camera )
}

WaitingForPlayersCameraLocPair function NewCameraPair(vector origin, vector angles)
{
    WaitingForPlayersCameraLocPair locPair
    locPair.origin = origin
    locPair.angles = angles

    return locPair
}

WaitingForPlayersCameraLocPair function ReturnCameraForThisTime()
{
	return GetCamerasForMap( GetMapName() ).getrandom()
}

array<WaitingForPlayersCameraLocPair> function GetCamerasForMap( string map )
{
	array<WaitingForPlayersCameraLocPair> cutsceneSpawns

	switch(map)
	{
		case "mp_rr_desertlands_holiday":
		case "mp_rr_desertlands_64k_x_64k":
		case "mp_rr_desertlands_64k_x_64k_nx":
		case "mp_rr_desertlands_64k_x_64k_mv":
		case "mp_rr_desertlands_64k_x_64k_tt":
		case "mp_rr_desertlands_mu1":
		case "mp_rr_desertlands_mu1_tt":
		case "mp_rr_desertlands_mu2":
			cutsceneSpawns.append(NewCameraPair( <-17572.3301, 11646.5137, -3777.35034>, <0, 155.688446, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-15497.5586, 25198.2129, -4041.42749>, <0, 9.20065498, 0> ))
			cutsceneSpawns.append(NewCameraPair( <28017.6992, 8541.48926, -3296.67017>, <0, 106.955139, 0> ))
			cutsceneSpawns.append(NewCameraPair( <10490.2441, 6386.27734, -4340.8833>, <-23, -120.848991, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-1528.49048, -7687.84863, -4087.68896>, <0, -7.29582596, 0> ))
			cutsceneSpawns.append(NewCameraPair( <4207.39697, -21928.7891, -3208.28174>, <0, -16.8694267, 0> ))
		break

		case "mp_rr_canyonlands_64k_x_64k":
		case "mp_rr_canyonlands_mu1":
		case "mp_rr_canyonlands_mu1_night":
			cutsceneSpawns.append(NewCameraPair( <-6049.01807, 18478.2285, 2771.03174>, <0, -34.2617683, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-15686.7402, 1259.25342, 2888.13013>, <0, 143.531845, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-26376.4258, -3842.12036, 2760.02759>, <0, 52.9255295, 0> ))
			cutsceneSpawns.append(NewCameraPair( <28823.8867, 4136.58398, 4171.0459>, <0, -135.179871, 0> ))
		break

		case "mp_rr_canyonlands_mu2":
		case "mp_rr_canyonlands_mu2_tt":
			cutsceneSpawns.append(NewCameraPair( <-6049.01807, 18478.2285, 2771.03174>, <0, -34.2617683, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-15686.7402, 1259.25342, 2888.13013>, <0, 143.531845, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-26376.4258, -3842.12036, 2760.02759>, <0, 52.9255295, 0> ))
			cutsceneSpawns.append(NewCameraPair( <29186.4004, 4389.00684, 4393.5957>, <0, -144.792419, 0> ))
			cutsceneSpawns.append(NewCameraPair( <19051.4375, 10624.1055, 4916.54883>, <0, -8.65356064, 0> ))
			cutsceneSpawns.append(NewCameraPair( <34535.5469, 24481.7012, 4585.43506>, <0, -44.7645645, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-12433.5381, -9732.68555, 3427.97339>, <0, -48.9345093, 0> ))
		break

		case "mp_rr_olympus_tt":
		case "mp_rr_olympus_mu1":
		case "mp_rr_olympus":
			cutsceneSpawns.append(NewCameraPair( <-25235.1055, 1220.16565, -5563.3125> , <0, 14.9181824, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-22515.6289, 18350.7285, -6227.43359> , <0, -31.012104, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-34199.1133, 10023.2178, -3739.12305> , <0, 57.2625656, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-42535.6719, -8651.65527, -3381.62817> , <0, -117.898598, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-34771.207, -18455.5371, -3415.63062> , <0, 96.4288177, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-7813.10205, -26010.8672, -2247.70752> , <0, -149.884628, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-3477.38794, -29067.6367, -975.647644> , <0, 51.4941902, 0> ))
			cutsceneSpawns.append(NewCameraPair( <22722.5684, -17699.8711, -5239.71533> , <0, -123.869438, 0> ))
			cutsceneSpawns.append(NewCameraPair( <14765.1807, -4291.78955, -3995.76563> , <0, -23.8360157, 0> ))
			cutsceneSpawns.append(NewCameraPair( <16342.6611, 5930.64844, -3591.96875> , <0, 149.040939, 0> ))
			cutsceneSpawns.append(NewCameraPair( <5397.75439, 22433.9219, -5673.11865> , <0, 43.7146683, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-293.680786, 6115.55811, -4848.82373> , <0, 68.2613144, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-2724.11963, 862.047485, -5981.30273> , <0, -88.4052658, 0> ))
			cutsceneSpawns.append(NewCameraPair( <-20965.0313, 373.067291, -5486.98096> , <0, -61.3815041, 0> ))
		break

		case "mp_rr_arena_empty":
			cutsceneSpawns.append(NewCameraPair( <41000,-10000,0>, <0,0,0> ) )
		break

		case "mp_rr_arena_composite":
		cutsceneSpawns.append(NewCameraPair( <2307.4375, 1415.3374, 429.479797> , <0, 130.879272, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <2877.44409, 5697.83105, 1672.90344> , <0, 10.1077566, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-890.250305, 6196.06494, 1501.16028> , <0, -149.713516, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-1853.4906, 4318.04736, 791.386963> , <0, -108.551895, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-2628.37329, -472.374023, 325.194672> , <0, 80.4712677, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-854.504883, 844.514343, 608.447632> , <0, -21.671114, 0> ) )
		break

		case "mp_rr_aqueduct":
		cutsceneSpawns.append(NewCameraPair( <4536.32324, -4842.01514, 627.977661> , <0, 168.955353, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <2123.55908, -5994.70752, 422.766052> , <0, 169.391968, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-324.00824, -6295.51123, 1393.36169> , <0, 61.8894501, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-974.514282, -1108.53979, -55.8972359> , <0, -51.9891815, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <1274.22766, -5196.98389, 1064.73584> , <0, 143.300842, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-763.161804, -5228.40234, 477.852356> , <0, 124.9048, 0> ) )
		break

		case "mp_rr_arena_phase_runner":
		cutsceneSpawns.append(NewCameraPair( <20500.5332, 18673.2109, -371.418091> , <0, 5.8379364, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <22216.2598, 14448.0566, 120.776726> , <0, 26.7628136, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <25429.293, 13582.9941, -808.916077> , <0, 10.6653433, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <28682.6699, 17033.4258, -739.663818> , <0, 171.884537, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <23470.3652, 17689.8359, -1296.198> , <0, 64.2433472, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <24990.2383, 21005.0762, -621.474304> , <0, 46.2398949, 0> ) )

		break

		case "mp_rr_party_crasher":
		cutsceneSpawns.append(NewCameraPair( <3385.96265, -1591.92493, 2220.44629> , <0, 97.7711029, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-1012.03864, -2472.96851, 1999.18762> , <0, 131.942291, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-1949.47925, -565.452087, 1366.40222> , <0, -4.39630127, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <-840.577515, 3031.18994, 1057.86731> , <0, -49.7104607, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <416.486328, 2083.01709, 562.318604> , <0, -83.0055008, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <2646.22314, 2588.46582, 1168.85779> , <0, -107.622498, 0> ) )
		break

		case "mp_rr_canyonlands_staging":
		cutsceneSpawns.append(NewCameraPair( <33541.2188, -5675.45654, -28549.1484>, <0, -132.551712, 0> ) )
		cutsceneSpawns.append(NewCameraPair( <33966.2188, -6687.17529, -28518.5449>, <0, 58.0181351, 0> ) )

		break
	}

	return cutsceneSpawns
}

void function OnGamestatePlaying()
{
	WaitingForPlayersOverlay_Destroy()

	if( Playlist() == ePlaylists.survival || Playlist() == ePlaylists.survival_duos || Playlist() == ePlaylists.survival_solos )
		GetLocalClientPlayer().ClearMenuCameraEntity()
}

void function Survival_RunCharacterSelection()
{
	if ( file.shouldRunCharacterSelectionCallback != null )
	{
		if ( !file.shouldRunCharacterSelectionCallback() )
			return
	}

	SetDpadMenuHidden()
	WaitingForPlayersOverlay_Destroy()
	thread Survival_RunCharacterSelection_Thread()
}

void function Survival_RunCharacterSelection_Thread()
{
	FlagWait( "ClientInitComplete" )

	if ( !Survival_CharacterSelectEnabled() )
		return

	while( GetGlobalNetBool( "characterSelectionReady" ) == false )
		WaitFrame()
	for ( ;; )
	{
		entity player = GetLocalClientPlayer()
		if ( IsValid( player ) && (player.GetPlayerNetInt( "characterSelectLockstepPlayerIndex" ) >= 0) )
			break
		WaitFrame()
	}

	HideMapRui()

	//
	CloseCharacterSelectNewMenu()
	WaitFrame()
	OpenCharacterSelectNewMenu()

	while( Time() < GetGlobalNetTime( "squadPresentationStartTime" ) )
		WaitFrame()

	if ( GetCurrentPlaylistVarInt( "survival_enable_squad_intro", 1 ) == 1 )
	{
		if( GetCurrentPlaylistVarBool( "r5reloaded_AnimatedCharacterSelect", false ) )
			thread DoAnimatedSquadCardsPresentation()
		else
			thread DoSquadCardsPresentation()
	}
	else
		CloseCharacterSelectNewMenu()

	while( Time() < GetGlobalNetTime( "championSquadPresentationStartTime" ) )
		WaitFrame()

	if ( GetCurrentPlaylistVarInt( "survival_enable_gladiator_intros", 1 ) == 1 )
	{
		if( GetCurrentPlaylistVarBool( "r5reloaded_AnimatedCharacterSelect", false) )
			thread DoAnimatedChampionSquadCardsPresentation()
		else
			thread DoChampionSquadCardsPresentation()
	}
}


void function OnGamestateChanged()
{
	int gamestate = GetGameState()

	var gamestateRui = ClGameState_GetRui()
	if ( gamestateRui == null )
		return

	bool gamestateIsPlaying         = GamePlaying()
	bool gamestateWaitingForPlayers = GetGameState() == eGameState.WaitingForPlayers
	RuiSetBool( gamestateRui, "gamestateIsPlaying", gamestateIsPlaying )
	RuiSetBool( gamestateRui, "gamestateWaitingForPlayers", gamestateWaitingForPlayers )
	RuiSetInt( gamestateRui, "gamestate", gamestate )

	if ( file.pilotRui != null )
	{
		RuiSetBool( file.pilotRui, "gamestateIsPlaying", gamestateIsPlaying )
		RuiSetBool( file.dpadMenuRui, "gamestateIsPlaying", gamestateIsPlaying )

		RuiSetBool( file.pilotRui, "gamestateWaitingForPlayers", gamestateWaitingForPlayers )
		RuiSetBool( file.dpadMenuRui, "gamestateWaitingForPlayers", gamestateWaitingForPlayers )
	}
}


void function OnGamestatePrematch()
{
	SetDpadMenuHidden()
	WaitingForPlayersOverlay_Destroy()
	Minimap_UpdateMinimapVisibility( GetLocalClientPlayer() )
}


void function SetDpadMenuVisible()
{
	if(!GetCurrentPlaylistVarBool( "firingrange_aimtrainerbycolombia", false ))
		RuiSetBool( file.dpadMenuRui, "isVisible", GetHudDefaultVisibility() )
	else
		RuiSetBool( file.dpadMenuRui, "isVisible", false )
}


void function SetDpadMenuHidden()
{
	RuiSetBool( file.dpadMenuRui, "isVisible", false )
}

void function ChangeHUDVisibilityWhenInCryptoDrone( bool isInCryptoDrone = false )
{
	//TODO: debug it

	// if ( IsAlive( GetLocalClientPlayer() ) )
	// {

		// var cryptoAnimatedTacticalRui = GetCryptoAnimatedTacticalRui()

		// if ( cryptoAnimatedTacticalRui != null )
		// {
			// RuiSetBool( cryptoAnimatedTacticalRui, "isVisible", isInCryptoDrone ? false : GetHudDefaultVisibility() )
		// }
	// }

	RuiSetBool( GetUltimateRui(), "isVisible", isInCryptoDrone ? false : GetHudDefaultVisibility() )
}

void function OnGameStatePlaying_CheckCryptoDrone()
{
	entity player = GetLocalClientPlayer()


	if (PlayerHasPassive( player, ePassives.PAS_CRYPTO ))
	{
		ChangeHUDVisibilityWhenInCryptoDrone(IsPlayerInCryptoDroneCameraView(player))
	}
}

void function Survival_ClearHints()
{
	UpdateHealHint( GetLocalViewPlayer() )
}


void function ServerCallback_PlayerBootsOnGround()
{
	NotifyDropSequence( false )

	Signal( GetLocalClientPlayer(), "DroppodLanded" )
	Fullmap_ClearInWorldMinimaps()

	DoF_LerpFarDepthToDefault( 0.5 )
	DoF_LerpNearDepthToDefault( 0.5 )
	SetConVarFloat( "dof_variable_blur", 0.0 )
}


void function ServerCallback_AnnounceCircleClosing()
{
	if ( !CircleAnnouncementsEnabled() )
		return

	float duration                = 4.0
	string circleClosingSound = "survival_circle_close_alarm_02"
	#if(true)
		if ( IsFallLTM() )
			circleClosingSound = "survival_circle_close_alarm_02_ss"
	#endif

	AnnouncementData announcement = Announcement_Create( Localize( "#SURVIVAL_CIRCLE_STARTING" ) )
	Announcement_SetSoundAlias( announcement, circleClosingSound )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING )
	Announcement_SetPurge( announcement, true )
	Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
	Announcement_SetPriority( announcement, 200 ) //
	announcement.duration = duration
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}


void function Sur_OnBleedoutStarted( entity victim, float endTime )
{
	if ( victim != GetLocalViewPlayer() )
		return

	RuiSetGameTime( file.pilotRui, "bleedoutEndTime", endTime )
	RuiSetBool( file.pilotRui, "isDowned", true )

	if ( victim == GetLocalClientPlayer() )
		RunUIScript( "TryCloseSurvivalInventory", null )
}


void function Sur_OnBleedoutEnded( entity victim )
{
	if ( victim != GetLocalViewPlayer() )
		return

	RuiSetGameTime( file.pilotRui, "bleedoutEndTime", 0.0 )
	RuiSetBool( file.pilotRui, "isDowned", false )
}

bool function DontCreateRuisForEnemies( entity ent )
{
	if ( ent.IsPlayer() || ent.IsNPC() )
	{
		#if(false)











#endif //

		if ( ent.GetTeam() != GetLocalViewPlayer().GetTeam() )
		{
			return false
		}
	}

	return true
}


void function MarkDpadAsBlocked( bool isBlocked )
{
	if ( file.dpadMenuRui != null )
		RuiSetBool( file.dpadMenuRui, "dpadNotAvailable", isBlocked )
}


void function OnTrackTitanTeam( entity titan )
{
	thread OnTrackTitanTeamInternal( titan )
}


void function OnTrackTitanTeamInternal( entity titan )
{
	titan.SetDoDestroyCallback( true )

	EndSignal( titan, "OnDestroy" )

	int team = titan.GetTeam()

	while ( IsValid( titan ) )
	{
		if ( team != titan.GetTeam() )
		{
			team = titan.GetTeam()
			Signal( titan, "SettingsChanged" )
		}
		wait 0.5
	}
}

struct PROTO_LootContainerState
{
	entity container
	bool   isLit = false
	entity light = null
}

bool proto_isContainerThinkRunning = false
array<PROTO_LootContainerState> proto_lootContainerStateList = []
void function PROTO_OnContainerCreated( entity container )
{
	PROTO_LootContainerState state
	state.container = container
	proto_lootContainerStateList.append( state )

	if ( !proto_isContainerThinkRunning )
	{
		thread PROTO_ContainersThink()
	}

	//
}


void function PROTO_ContainersThink()
{
	proto_isContainerThinkRunning = true
	while( true )
	{
		if ( proto_lootContainerStateList.len() == 0 )
		{
			proto_isContainerThinkRunning = false
			return
		}

		entity player = GetLocalViewPlayer()

		array<int> stateIndexesToRemove = []
		foreach( int stateIndex, PROTO_LootContainerState state in proto_lootContainerStateList )
		{
			if ( !IsValid( state.container ) )
			{
				stateIndexesToRemove.append( stateIndex )
				continue
			}

			float dist           = Distance2D( state.container.GetWorldSpaceCenter(), player.GetWorldSpaceCenter() )
			float fullOnPoint    = 100.0
			float offPoint       = 120.0
			bool shouldBecomeLit = (dist < offPoint)
			//

			if ( shouldBecomeLit )
			{
				if ( !state.isLit )
				{
					state.light = CreateClientSideDynamicLight( state.container.GetWorldSpaceCenter(), <0, 0, 0>, <0, 0, 0>, 0.0 )
					//
					state.isLit = true
				}
			}
			else//
			{
				if ( state.isLit )
				{
					state.light.Destroy()
					state.light = null
					state.isLit = false
				}
			}

			if ( state.isLit )
			{
				vector lightCol  = <0, 1, 1>
				float brightness = GraphCapped( dist, fullOnPoint, offPoint, 1.0, 0.0 )
				state.light.SetLightColor( lightCol * brightness )
				state.light.SetLightRadius( 220.0 )
			}
		}

		for ( int i = stateIndexesToRemove.len() - 1; i >= 0; i-- )
		{
			PROTO_LootContainerState state = proto_lootContainerStateList[ stateIndexesToRemove[i] ]
			if ( state.light != null )
			{
				state.light.Destroy()
			}
			proto_lootContainerStateList.fastremove( stateIndexesToRemove[i] )
		}

		wait 0.1
	}
}


void function TryCycleOrdnance( entity player )
{
	if ( player == GetLocalClientPlayer() && player == GetLocalViewPlayer() && !Flowstate_IsHaloMode() )
	{
		entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( IsValid( weapon ) && player.GetWeaponDisableFlags() != WEAPON_DISABLE_FLAGS_ALL )
		{
			if ( weapon.GetWeaponType() == WT_ANTITITAN )
			{
				array<string> allOrdnance = SURVIVAL_GetAllPlayerOrdnance( player )

				if ( allOrdnance.len() > 1 || !allOrdnance.contains( weapon.GetWeaponClassName() ) )
				{
					player.ClientCommand( "Sur_SwapToNextOrdnance" )
				}
			}
		}
	}
}


void function CrouchPressed( entity player )
{
	if ( !GetCurrentPlaylistVarBool( "survival_autoprompt_taunt_on_crouch_spam", true ) )
		return

	if ( player != GetLocalClientPlayer() || player != GetLocalViewPlayer() )
		return

	if ( IsPlayerInCryptoDroneCameraView( player ) )
		return

	if ( Time() - file.lastPressedCrouchTime > CROUCH_SPAM_DETECT_TIMEOUT )
		file.crouchSpamCount = 0
	else
		file.crouchSpamCount += 1

	file.lastPressedCrouchTime = Time()

	if ( file.crouchSpamCount == 4 )
	{
		ServerCallback_PromptTaunt()
	}
}
void function ReloadPressed( entity player )
{
	player.Signal( "ReloadPressed" )

	if ( player != GetLocalClientPlayer() || player != GetLocalViewPlayer() )
		return

	int weaponDisableFlags = player.GetWeaponDisableFlags()
	if ( weaponDisableFlags == WEAPON_DISABLE_FLAGS_ALL )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponType() == WT_ANTITITAN )
		return

	if ( weapon.GetWeaponPrimaryClipCountMax() <= 0 || !weapon.GetWeaponSettingBool( eWeaponVar.uses_ammo_pool ) || player.AmmoPool_GetCount( weapon.GetWeaponAmmoPoolType() ) > 0 )
		return

	bool isUsePressed   = player.IsInputCommandPressed( IN_USE )
	entity playerUseEnt = player.GetUseEntity()
	if ( isUsePressed && playerUseEnt != null )
		return

	NotifyReloadAttemptButNoReserveAmmo()
}


void function UsePressed( entity player )
{
	int gamepadUseType = GetConVarInt( "gamepad_use_type" )
	if ( gamepadUseType == eGamepadUseSchemeType.TAP_TO_USE_HOLD_TO_RELOAD && player == GetLocalClientPlayer() && player == GetLocalViewPlayer() )
	{
		if ( !player.HasUsePrompt() )
		{
			entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			if ( IsValid( weapon ) && player.GetWeaponDisableFlags() != WEAPON_DISABLE_FLAGS_ALL )
			{
				if ( !weapon.GetWeaponSettingBool( eWeaponVar.reload_enabled ) )
					return

				if ( weapon.GetWeaponType() == WT_ANTITITAN )
				{
					array<string> allOrdnance = SURVIVAL_GetAllPlayerOrdnance( player )

					if ( allOrdnance.len() > 1 && !Flowstate_IsHaloMode() )
					{
						ServerCallback_SurvivalHint( eSurvivalHints.ORDNANCE )
					}
				}
				else if ( IsControllerModeActive() && player.AmmoPool_GetCount( weapon.GetWeaponAmmoPoolType() ) > 0 )
				{
					float lowAmmoFrac = weapon.GetWeaponSettingFloat( eWeaponVar.low_ammo_fraction )

					float weaponClipMax = float( weapon.GetWeaponPrimaryClipCountMax() )
					float currClipCount = float( weapon.GetWeaponPrimaryClipCount() )
					float ammoFrac      = currClipCount / weaponClipMax

					if ( weaponClipMax > currClipCount && ammoFrac > lowAmmoFrac )
						AddPlayerHint( 2.0, 0.5, $"", "#HINT_RELOAD_TAP_TO_USE" )
				}
			}
		}
	}
}

void function UpdateFallbackMatchmaking( string fallbackPlaylistName, string fallbackStatusText )
{
	if ( fallbackPlaylistName == "" )
	{
		if ( file.fallbackMMRui != null )
			RuiDestroy( file.fallbackMMRui )

		file.fallbackMMRui = null
		return
	}

	if ( file.fallbackMMRui == null )
	{
		file.fallbackMMRui = RuiCreate( $"ui/fallback_status_text.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 100 )
		RuiSetGameTime( file.fallbackMMRui, "queueStartTime", Time() )
	}

	string playlistName = Localize( GetPlaylistVarString( fallbackPlaylistName, "name", "Undefined: " + fallbackPlaylistName ) )

	RuiSetString( file.fallbackMMRui, "fallbackPlaylistText", playlistName )
	RuiSetString( file.fallbackMMRui, "fallbackStatusText", fallbackStatusText )
}


void function PROTO_ServerCallback_Sur_HoldForUltimate()
{
	AddPlayerHint( 4.0, 0.25, $"", "Hold %offhand4%" )
}


void function SetVictorySequenceLocation( vector position, vector angles )
{
	file.victorySequencePosition = position
	file.victorySequenceAngles = angles
}


void function SetVictorySequenceSunSkyIntensity( float sunIntensity, float skyIntensity )
{
	file.victorySunIntensity = sunIntensity
	file.victorySkyIntensity = skyIntensity
}


void function ServerCallback_MatchEndAnnouncement( bool victory, int winningTeam )
{
	clGlobal.levelEnt.Signal( "SquadEliminated" )

	DeathScreenCreateNonMenuBlackBars()
	DeathScreenUpdate()
	entity clientPlayer = GetLocalClientPlayer()

	Assert( IsValid( clientPlayer ) )

	bool isPureSpectator = clientPlayer.GetTeam() == TEAM_SPECTATOR

	if ( clientPlayer.GetTeam() == winningTeam || IsAlive( clientPlayer ) || isPureSpectator )
		ShowChampionVictoryScreen( winningTeam )
}

void function ServerCallback_Scenarios_MatchEndAnnouncement()
{
	// DeathScreenCreateNonMenuBlackBars()
	// DeathScreenUpdate()
	thread function () : ()
	{
		entity clientPlayer = GetLocalClientPlayer()

		if ( IsAlive( clientPlayer ) )
			ShowChampionVictoryScreen( GetLocalClientPlayer().GetTeam() )

		wait 4

		ForceDestroyBlackBarRui()
		ForceDestroyChampionScreenRui()
	}()
}

void function ServerCallback_DestroyEndAnnouncement()
{
	entity clientPlayer = GetLocalClientPlayer()

	if(!IsValid(clientPlayer)) return

	ForceDestroyBlackBarRui()
	ForceDestroyChampionScreenRui()
}

void function ForceDestroyChampionScreenRui()
{
	if(file.victoryRui != null)
	{
		RuiDestroyIfAlive( file.victoryRui )
		file.victoryRui = null
	}
}

void function ShowChampionVictoryScreen( int winningTeam )
{
	if ( file.victoryRui != null )
		return

	entity clientPlayer = GetLocalClientPlayer()

	HideGladiatorCardSidePane( true )
	UpdateRespawnStatus( eRespawnStatus.NONE )

	asset ruiAsset = GetChampionScreenRuiAsset()
	file.victoryRui = CreateFullscreenRui( ruiAsset )
	RuiSetBool( file.victoryRui, "onWinningTeam", GetLocalClientPlayer().GetTeam() == winningTeam )

	EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_ChampionVictory" )

	Chroma_VictoryScreen()
}

string function GetChampionScreenSound()
{
	if ( file.customChampionScreenSound != "" )
		return file.customChampionScreenSound

	return "UI_InGame_ChampionVictory"
}

asset function GetChampionScreenRuiAsset()
{

	if ( file.customChampionScreenRuiAsset != $"" )
		return file.customChampionScreenRuiAsset

	return $"ui/champion_screen.rpak"
}

void functionref( var ) s_championScreenExtraFunc = null
void function SetChampionScreenRuiAssetExtraFunc( void functionref( var ) func )
{
	s_championScreenExtraFunc = func
}
void function SetChampionScreenRuiAsset( asset ruiAsset )
{
	file.customChampionScreenRuiAsset = ruiAsset
}

void function SetChampionScreenSound( string alias )
{
	file.customChampionScreenSound = alias
}

void function SetPreVictoryScreenCallback( void functionref(bool) func )
{
	file.onPreVictoryScreenCallback = func
}
void function ShowSquadSummary()
{
	entity player = GetLocalClientPlayer()
	EndSignal( player, "OnDestroy" )
}

void function ServerCallback_AddWinningSquadData( int index, int eHandle, int kills, int damageDealt, int survivalTime, int revivesGiven, int respawnsGiven )
{
	if ( index == -1 )
	{
		file.winnerSquadSummaryData.playerData.clear()
		file.winnerSquadSummaryData.squadPlacement = -1
		return
	}

	SquadSummaryPlayerData data
	data.eHandle = eHandle
	data.kills = kills
	data.damageDealt = damageDealt
	data.survivalTime = survivalTime
	data.revivesGiven = revivesGiven
	data.respawnsGiven = respawnsGiven
	file.winnerSquadSummaryData.playerData.append( data )
	file.winnerSquadSummaryData.squadPlacement = 1
}


SquadSummaryData function GetSquadSummaryData()
{
	return file.squadSummaryData
}

#if DEVELOPER
void function Dev_ShowVictorySequence()
{
	ServerCallback_AddWinningSquadData( -1, -1, 0, 0, 0, 0, 0 )
	foreach( int i, entity player in GetPlayerArrayOfTeam( GetLocalClientPlayer().GetTeam() ) )
		ServerCallback_AddWinningSquadData( i, player.GetEncodedEHandle(), 2, 1234, 600, 3, 1 )
	thread ShowVictorySequence()
}

void function Dev_AdjustVictorySequence()
{
	ServerCallback_AddWinningSquadData( -1, -1, 0, 0, 0, 0, 0 )
	foreach( int i, entity player in GetPlayerArrayOfTeam( GetLocalClientPlayer().GetTeam() ) )
		ServerCallback_AddWinningSquadData( i, player.GetEncodedEHandle(), 2, 1234, 600, 3, 1 )
	GetLocalClientPlayer().FreezeControlsOnClient()
	thread ShowVictorySequence( true )
}
#endif

void function ServerCallback_ShowWinningSquadSequence()
{
	thread ShowVictorySequence()
}


bool function IsSquadDataPersistenceEmpty()
{
	entity player = GetLocalClientPlayer()

	int maxTrackedSquadMembers = PersistenceGetArrayCount( "lastGameSquadStats" )
	for ( int i = 0 ; i < maxTrackedSquadMembers ; i++ )
	{
		int eHandle = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].eHandle" )

		if ( eHandle > 0 )
			return false
	}
	return true
}


void function SetSquadDataToLocalTeam()
{
	entity player = GetLocalClientPlayer()

	int maxTrackedSquadMembers = PersistenceGetArrayCount( "lastGameSquadStats" )

	#if DEVELOPER
		printt( "PD: Reading Match Summary Persistet Vars for", player, "and", maxTrackedSquadMembers, "maxTrackedSquadMembers" )
	#endif

	file.squadSummaryData.playerData.clear()
	for ( int i = 0 ; i < maxTrackedSquadMembers ; i++ )
	{
		int eHandle = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].eHandle" )

		#if DEVELOPER
			printt( "PD: ", i, "eHandle", player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].eHandle" ) )
		#endif

		if ( eHandle <= 0 )
			continue

		SquadSummaryPlayerData data

		data.eHandle = eHandle
		data.kills = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].kills" )
		data.damageDealt = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].damageDealt" )
		data.survivalTime = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].survivalTime" )
		data.revivesGiven = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].revivesGiven" )
		data.respawnsGiven = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].respawnsGiven" )

		#if DEVELOPER
			printt( "PD: ", i, "kills", player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].kills" ) )
			printt( "PD: ", i, "damageDealt", player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].damageDealt" ) )
			printt( "PD: ", i, "survivalTime", player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].survivalTime" ) )
			printt( "PD: ", i, "revivesGiven", player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].revivesGiven" ) )
			printt( "PD: ", i, "respawnsGiven", player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].respawnsGiven" ) )
		#endif

		file.squadSummaryData.playerData.append( data )
	}

	file.squadSummaryData.squadPlacement = player.GetPersistentVarAsInt( "lastGameRank" )

	#if DEVELOPER
		printt( "PD: squadPlacement", player.GetPersistentVarAsInt( "lastGameRank" ) )
	#endif

}


void function VictorySequenceOrderLocalPlayerFirst( entity player )
{
	int playerEHandle = player.GetEncodedEHandle()
	bool hadLocalPlayer = false
	array<SquadSummaryPlayerData> playerDataArray
	SquadSummaryPlayerData localPlayerData

	foreach( SquadSummaryPlayerData data in file.winnerSquadSummaryData.playerData )
	{
		if ( data.eHandle == playerEHandle )
		{
			localPlayerData = data
			hadLocalPlayer = true
			continue
		}

		playerDataArray.append( data )
	}

	file.winnerSquadSummaryData.playerData = playerDataArray
	if ( hadLocalPlayer )
		file.winnerSquadSummaryData.playerData.insert( 0, localPlayerData )
}


void function ShowVictorySequence( bool placementMode = false )
{
	#if(!DEV)
		placementMode = false
	#endif

	entity player = GetLocalClientPlayer()

	EndSignal( player, "OnDestroy" )

	#if(true)
		array<int> offsetArray = [90, 78, 78, 90, 90, 78, 78, 90, 90, 78]
	#endif

	ScreenFade( player, 255, 255, 255, 255, 0.4, 2.0, FFADE_OUT | FFADE_PURGE )

	EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_ChampionMountain_Whoosh" )

	wait 0.4

	file.IsShowingVictorySequence = true

	DeathScreenUpdate()

	if ( IsSpectating() )
	{
		SwitchDeathScreenTab( eDeathScreenPanel.SPECTATE )
		EnableDeathScreenTab( eDeathScreenPanel.SQUAD_SUMMARY, false )
		EnableDeathScreenTab( eDeathScreenPanel.DEATH_RECAP, false )
	}

	if ( file.victoryRui != null )
		RuiDestroyIfAlive( file.victoryRui )

	UpdateRespawnStatus( eRespawnStatus.NONE )
	HideGladiatorCardSidePane( true )
	Signal( player, "Bleedout_StopBleedoutEffects" )

	ScreenFade( player, 255, 255, 255, 255, 0.4, 0.0, FFADE_IN | FFADE_PURGE )

	// if( GetCurrentPlaylistVarBool( "survival_server_restart_after_end", false ) )
		// DM_HintCatalog( 5, null )

	asset defaultModel                = GetGlobalSettingsAsset( DEFAULT_PILOT_SETTINGS, "bodyModel" )
	LoadoutEntry loadoutSlotCharacter = Loadout_Character()
	vector characterAngles            = < file.victorySequenceAngles.x / 2.0, file.victorySequenceAngles.y, file.victorySequenceAngles.z >

	array<entity> cleanupEnts
	array<var> overHeadRuis

	VictoryPlatformModelData victoryPlatformModelData = GetVictorySequencePlatformModel()
	entity platformModel
	int maxPlayersToShow = -1
	if ( victoryPlatformModelData.isSet )
	{
		platformModel = CreateClientSidePropDynamic( file.victorySequencePosition + victoryPlatformModelData.originOffset, victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
		#if(true)
			if ( IsFallLTM() )
			{
				entity platformModel2 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -284, 1000, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
				entity platformModel3 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -284, 0, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )					//
				entity platformModel4 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -500, 200, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
				entity platformModel5 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -284, 500, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
				entity platformModel6 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, 0, 500, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )					//
				entity platformModel7 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, 300, 300, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
				entity platformModel8 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, 0, 1000, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
				cleanupEnts.append( platformModel2 )
				cleanupEnts.append( platformModel3 )
				cleanupEnts.append( platformModel4 )
				cleanupEnts.append( platformModel5 )
				cleanupEnts.append( platformModel6 )
				cleanupEnts.append( platformModel7 )
				cleanupEnts.append( platformModel8 )
				if ( IsShadowVictory() )
					maxPlayersToShow = 16
			}
		#endif

		cleanupEnts.append( platformModel )
		int playersOnPodium = 0

		VictorySequenceOrderLocalPlayerFirst( player )

		foreach( int i, SquadSummaryPlayerData data in file.winnerSquadSummaryData.playerData )
		{
			if ( maxPlayersToShow > 0 && i > maxPlayersToShow )
				break

			string playerName = ""
			if ( EHIHasValidScriptStruct( data.eHandle ) )
				playerName = EHI_GetName( data.eHandle )

			if ( !LoadoutSlot_IsReady( data.eHandle, loadoutSlotCharacter ) )
				continue

			ItemFlavor character = LoadoutSlot_GetItemFlavor( data.eHandle, loadoutSlotCharacter )

			if ( !LoadoutSlot_IsReady( data.eHandle, Loadout_CharacterSkin( character ) ) )
				continue

			ItemFlavor characterSkin = LoadoutSlot_GetItemFlavor( data.eHandle, Loadout_CharacterSkin( character ) )

			vector pos = GetVictorySquadFormationPosition( file.victorySequencePosition, file.victorySequenceAngles, i )

			entity characterNode = CreateScriptRef( pos, characterAngles )
			characterNode.SetParent( platformModel, "", true )
			entity characterModel = CreateClientSidePropDynamic( pos, characterAngles, defaultModel )
			SetForceDrawWhileParented( characterModel, true )
			characterModel.MakeSafeForUIScriptHack()
			CharacterSkin_Apply( characterModel, characterSkin )
			if( Flowstate_IsHaloMode() )
			{
				entity modelPlayer = FromEHI( data.eHandle )

				if( !IsValid( modelPlayer ) )
					characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief.rmdl" )
				else
				{
					switch( modelPlayer.GetPlayerNetInt( "fs_haloMod_assignedMasterChief" ) )
					{
						case 0:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_yellow.rmdl" )
						break

						case 1:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_white.rmdl" )
						break

						case 2:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_red.rmdl" )
						break

						case 3:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_purple.rmdl" )
						break

						case 4:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_pink.rmdl" )
						break

						case 5:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_orange.rmdl" )
						break

						case 6:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief_blue.rmdl" )
						break

						case 7:
						characterModel.SetModel( $"mdl/Humans/pilots/w_master_chief.rmdl" )
						break
					}
				}
			}

			cleanupEnts.append( characterModel )

			#if DEVELOPER
				if ( GetBugReproNum() == 1111 )
				{
					var topo = CreateRUITopology_Worldspace( OffsetPointRelativeToVector( pos, < 0, -50, 0 >, characterModel.GetForwardVector() ), characterAngles + <0, 180, 0>, 1000, 500 )
					var rui  = RuiCreate( $"ui/dev_blue_screen.rpak", topo, RUI_DRAW_WORLD, 1000 )
					characterModel.Hide()
				}
				else if ( GetBugReproNum() == 2222 )
				{
					if ( i == 0 )
						characterModel.Hide()
				}
			#endif

			foreach( func in s_callbacks_OnVictoryCharacterModelSpawned )
				func( characterModel, character, data.eHandle )

			characterModel.SetParent( characterNode, "", false )
			string victoryAnim = GetVictorySquadFormationActivity( i, characterModel )
			characterModel.Anim_Play( victoryAnim )
			characterModel.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()
			#if(true)
				if ( IsFallLTM() )
				{
					float duration = characterModel.GetSequenceDuration( victoryAnim )
					float initialTime = RandomFloatRange( 0, duration )
					characterModel.Anim_SetInitialTime( initialTime )
				}
			#endif


			#if DEVELOPER
				if ( GetBugReproNum() == 1111 || GetBugReproNum() == 2222 )
				{
					playersOnPodium++
					continue
				}
			#endif

			bool createOverheadRui = true
			#if(true)
				if ( IsFallLTM() && IsShadowVictory() && player.GetEncodedEHandle() != data.eHandle )
				{
					createOverheadRui = false
				}
			#endif
			if ( createOverheadRui )
			{
				int offset = 78
				#if(true)
					if ( IsFallLTM() )
						offset = offsetArray[i]
				#endif

				entity overheadEnt = CreateClientSidePropDynamic( pos + (AnglesToUp( file.victorySequenceAngles ) * offset), <0, 0, 0>, $"mdl/dev/empty_model.rmdl" )
				overheadEnt.Hide()
				var overheadRui = RuiCreate( $"ui/winning_squad_member_overhead_name.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
				RuiSetString( overheadRui, "playerName", playerName )
				RuiTrackFloat3( overheadRui, "position", overheadEnt, RUI_TRACK_ABSORIGIN_FOLLOW )
				overHeadRuis.append( overheadRui )
			}

			playersOnPodium++
		}

		VictorySoundPackage victorySoundPackage = GetVictorySoundPackage()
		string dialogueApexChampion
		if ( player.GetTeam() == GetWinningTeam() )
		{
			if ( playersOnPodium > 1 )
				dialogueApexChampion = victorySoundPackage.youAreChampPlural
			else
				dialogueApexChampion = victorySoundPackage.youAreChampSingular
		}
		else
		{
			if ( playersOnPodium > 1 )
				dialogueApexChampion = victorySoundPackage.theyAreChampPlural
			else
				dialogueApexChampion = victorySoundPackage.theyAreChampSingular
		}

		EmitSoundOnEntityAfterDelay( platformModel, dialogueApexChampion, 0.5 )

		VictoryCameraPackage victoryCameraPackage = GetVictoryCameraPackage()

		vector camera_offset_start = victoryCameraPackage.camera_offset_start
		vector camera_offset_end   = victoryCameraPackage.camera_offset_end
		vector camera_focus_offset = victoryCameraPackage.camera_focus_offset
		float camera_fov           = victoryCameraPackage.camera_fov

		vector camera_start_pos = OffsetPointRelativeToVector( file.victorySequencePosition, camera_offset_start, AnglesToForward( file.victorySequenceAngles ) )
		vector camera_end_pos   = OffsetPointRelativeToVector( file.victorySequencePosition, camera_offset_end, AnglesToForward( file.victorySequenceAngles ) )
		vector camera_focus_pos = OffsetPointRelativeToVector( file.victorySequencePosition, camera_focus_offset, AnglesToForward( file.victorySequenceAngles ) )

		vector camera_start_angles = VectorToAngles( camera_focus_pos - camera_start_pos )
		vector camera_end_angles   = VectorToAngles( camera_focus_pos - camera_end_pos )

		entity cameraMover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", camera_start_pos, camera_start_angles )
		entity camera      = CreateClientSidePointCamera( camera_start_pos, camera_start_angles, camera_fov )
		player.SetMenuCameraEntity( camera )
		camera.SetTargetFOV( camera_fov, true, EASING_CUBIC_INOUT, 0.0 )
		camera.SetParent( cameraMover, "", false )
		cleanupEnts.append( camera )

		GetLightEnvironmentEntity().ScaleSunSkyIntensity( file.victorySunIntensity, file.victorySkyIntensity )

		float camera_move_duration = 6.5
		cameraMover.NonPhysicsMoveTo( camera_end_pos, camera_move_duration, 0.0, camera_move_duration / 2.0 )
		cameraMover.NonPhysicsRotateTo( camera_end_angles, camera_move_duration, 0.0, camera_move_duration / 2.0 )
		cleanupEnts.append( cameraMover )

		wait camera_move_duration - 0.5

		#if DEVELOPER
			if ( placementMode )
			{
				if ( IsValid( platformModel ) )
					platformModel.SetParent( cameraMover, "", true )

				while( true )
				{
					vector pos        = cameraMover.GetOrigin()
					vector ang        = cameraMover.GetAngles()
					vector flatAngles = FlattenAngles( ang )

					vector forward = AnglesToForward( flatAngles )
					vector right   = AnglesToRight( flatAngles )
					vector up      = <0, 0, 1>

					float moveSpeed = 800.0 + (InputGetAxis( ANALOG_L_TRIGGER ) * 5000.0)
					moveSpeed *= max( 1.0 - InputGetAxis( ANALOG_R_TRIGGER ), 0.05 )

					float rotateSpeed = 2.0 + (InputGetAxis( ANALOG_L_TRIGGER ) * 10.0)
					rotateSpeed *= max( 1.0 - InputGetAxis( ANALOG_R_TRIGGER ), 0.05 )

					if ( InputGetAxis( ANALOG_LEFT_Y ) > 0.15 || InputGetAxis( ANALOG_LEFT_Y ) < -0.15 )
						pos += forward * InputGetAxis( ANALOG_LEFT_Y ) * -moveSpeed
					if ( InputGetAxis( ANALOG_LEFT_X ) > 0.15 || InputGetAxis( ANALOG_LEFT_X ) < -0.15 )
						pos += right * InputGetAxis( ANALOG_LEFT_X ) * moveSpeed
					if ( InputIsButtonDown( BUTTON_STICK_LEFT ) )
						pos += up * moveSpeed * 0.1
					if ( InputIsButtonDown( BUTTON_STICK_RIGHT ) )
						pos -= up * moveSpeed * 0.1

					if ( InputGetAxis( ANALOG_RIGHT_X ) > 0.15 || InputGetAxis( ANALOG_RIGHT_X ) < -0.15 )
					{
						float yaw = ang.y + (InputGetAxis( ANALOG_RIGHT_X ) * -rotateSpeed)
						ang = ClampAngles( < ang.x, yaw, ang.z > )
					}

					cameraMover.NonPhysicsMoveTo( pos, 0.1, 0.0, 0.0 )
					cameraMover.NonPhysicsRotateTo( ang, 0.1, 0.0, 0.0 )

					printt( "SetVictorySequenceLocation(" + (platformModel.GetOrigin() - victoryPlatformModelData.originOffset) + ", " + ClampAngles( < 0, camera.GetAngles().y + 180, 0 > ) + " )" )

					WaitFrame()
				}
			}
		#endif
	}

	file.IsShowingVictorySequence = false

	#if DEVELOPER
		printt( "PD: IsSquadDataPersistenceEmpty", IsSquadDataPersistenceEmpty() )
	#endif

	Assert( !IsSquadDataPersistenceEmpty(), "Persistence didn't get transmitted to the client in time!" )
	SetSquadDataToLocalTeam()    //

	ShowDeathScreen( eDeathScreenPanel.SQUAD_SUMMARY )
	EnableDeathScreenTab( eDeathScreenPanel.SPECTATE, false )
	EnableDeathScreenTab( eDeathScreenPanel.DEATH_RECAP, !IsAlive( player ) )
	SwitchDeathScreenTab( eDeathScreenPanel.SQUAD_SUMMARY )

	wait 1.0

	foreach( rui in overHeadRuis )
		RuiDestroyIfAlive( rui )

	foreach( entity ent in cleanupEnts )
		ent.Destroy()
}


bool function IsShowingVictorySequence()
{
	return file.IsShowingVictorySequence
}

void function Survival_SetVictorySoundPackageFunction( VictorySoundPackage functionref() func )
{
	file.victorySoundPackageCallback = func
}

VictorySoundPackage function GetVictorySoundPackage()
{
	VictorySoundPackage victorySoundPackage

	if ( file.victorySoundPackageCallback != null )
		return file.victorySoundPackageCallback()

	#if(true)
		if ( IsFallLTM() )
		{
			float randomFloat = RandomFloatRange( 0, 1 )
			if ( IsShadowVictory() )
			{
				string shadowsWinAlias
				if ( randomFloat < 0.33 )
					shadowsWinAlias = "diag_ap_nocNotify_shadowSquadWin_01_3p"
				else if ( randomFloat < 0.66 )
					shadowsWinAlias = "diag_ap_nocNotify_shadowSquadWin_02_3p"
				else
					shadowsWinAlias = "diag_ap_nocNotify_shadowSquadWin_03_3p"
				victorySoundPackage.youAreChampPlural = shadowsWinAlias
				victorySoundPackage.youAreChampSingular = shadowsWinAlias
				victorySoundPackage.theyAreChampPlural = shadowsWinAlias
				victorySoundPackage.theyAreChampSingular = shadowsWinAlias
			}
			else //
			{
				if ( randomFloat < 0.33 )
				{
					victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_01_3p" //
					victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_03_3p" //
					victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_01_3p" //
				}
				else if ( randomFloat < 0.66 )
				{
					victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_02_3p" //
					victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_04_3p" //
					victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_02_3p" //
				}
				else
				{
					victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_03_3p" //
					victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_05_3p" //
					victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_01_3p" //
				}
				victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_victorySquad_03_3p" //

			}

			return victorySoundPackage
		}
	#endif //

	victorySoundPackage.youAreChampPlural = "diag_ap_aiNotify_winnerFound_07" //
	victorySoundPackage.youAreChampSingular = "diag_ap_aiNotify_winnerFound_10" //
	victorySoundPackage.theyAreChampPlural = "diag_ap_aiNotify_winnerFound_08" //
	victorySoundPackage.theyAreChampSingular = "diag_ap_ainotify_introchampion_01_02" //

	return victorySoundPackage
}


VictoryCameraPackage function GetVictoryCameraPackage()
{
	VictoryCameraPackage victoryCameraPackage

	#if(true)
		if ( IsFallLTM() )
		{
			if ( IsShadowVictory() )
			{
				victoryCameraPackage.camera_offset_start = <0, 725, 100>
				victoryCameraPackage.camera_offset_end = <0, 400, 48>
			}
			else
			{
				victoryCameraPackage.camera_offset_start = <0, 735, 68>
				victoryCameraPackage.camera_offset_end = <0, 625, 48>
			}

			victoryCameraPackage.camera_focus_offset = <0, 0, 36>
			victoryCameraPackage.camera_fov = 35.5

			return victoryCameraPackage
		}
	#endif //

	victoryCameraPackage.camera_offset_start = <0, 320, 68>
	victoryCameraPackage.camera_offset_end = <0, 200, 48>
	victoryCameraPackage.camera_focus_offset = <0, 0, 36>
	victoryCameraPackage.camera_fov = 35.5

	return victoryCameraPackage
}



vector function GetVictorySquadFormationPosition( vector mainPosition, vector angles, int index )
{
	if ( index == 0 )
		return mainPosition - <0, 0, 8>

	float offset_side = 48.0
	float offset_back = -28.0

	#if(true)
		if ( IsFallLTM() )
		{
			if ( IsShadowVictory() )
			{
				if ( index < 7 )
				{
					offset_side = 48.0
					offset_back = -48.0
				}
				else if ( index == 7 )
					return OffsetPointRelativeToVector( mainPosition, <24, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 8 )
					return OffsetPointRelativeToVector( mainPosition, <48, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 9 )
					return OffsetPointRelativeToVector( mainPosition, <72, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 10 )
					return OffsetPointRelativeToVector( mainPosition, <96, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 11 )
					return OffsetPointRelativeToVector( mainPosition, <120, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 12 )
					return OffsetPointRelativeToVector( mainPosition, <-24, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 13 )
					return OffsetPointRelativeToVector( mainPosition, <-48, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 14 )
					return OffsetPointRelativeToVector( mainPosition, <-96, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 15 )
					return OffsetPointRelativeToVector( mainPosition, <-120, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 16 )
					return OffsetPointRelativeToVector( mainPosition, <12, 32, -8>, AnglesToForward( angles ) )
			}
			else
			{
				if ( index > 2 )
				{
					//
					offset_side = 56.0
					offset_back = -28.0

				}
			}
		}

	#endif //

	int countBack = (index + 1) / 2
	vector offset = < offset_side, offset_back, 0 > * countBack

	if ( index % 2 == 0 )
		offset.x *= -1

	vector point = OffsetPointRelativeToVector( mainPosition, offset, AnglesToForward( angles ) )
	return point - <0, 0, 8>
}


string function GetVictorySquadFormationActivity( int index, entity characterModel )
{
	#if(true)
		if ( IsFallLTM() && IsShadowVictory() )
		{
			bool animExists = characterModel.LookupSequence( "ACT_VICTORY_DANCE" ) != -1
			if ( animExists )
				return "ACT_VICTORY_DANCE"
			else
			{
				Assert( characterModel.LookupSequence( "ACT_MP_MENU_LOBBY_SELECT_IDLE" ) != -1, "Unable to find victory idle for " + characterModel )
				return "ACT_MP_MENU_LOBBY_SELECT_IDLE"
			}

		}

	#endif //

	return "ACT_MP_MENU_LOBBY_SELECT_IDLE"
	/*







*/
}


bool function HealthkitWheelToggleEnabled()
{
	return false
}


bool function HealthkitWheelUseOnRelease()
{
	return false && !HealthkitUseOnHold()
}


bool function HealthkitUseOnHold()
{
	return false && !HealthkitWheelToggleEnabled()
}


void function HealthkitButton_Down( entity player )
{
	if ( !CommsMenu_CanUseMenu( player ) || Flowstate_IsHaloMode() && Playlist() != ePlaylists.fs_haloMod_survival )
		return

	if ( !IsFiringRangeGameMode() )
	{
		int ms = PlayerMatchState_GetFor( player )
		if ( ms < ePlayerMatchState.NORMAL )
			return
	}

	if ( player.ContextAction_IsInVehicle() )
		return

	CommsMenu_OpenMenuTo( player, eChatPage.INVENTORY_HEALTH, eCommsMenuStyle.INVENTORY_HEALTH_MENU, false )
}


void function HealthkitButton_Up( entity player )
{
	if ( !IsCommsMenuActive() || Flowstate_IsHaloMode() && Playlist() != ePlaylists.fs_haloMod_survival )
		return

	if ( CommsMenu_GetCurrentCommsMenu() != eCommsMenuStyle.INVENTORY_HEALTH_MENU )
		return

	if ( HealthkitWheelToggleEnabled() )
		return

	if ( CommsMenu_HasValidSelection() )
		CommsMenu_ExecuteSelection( eWheelInputType.NONE )

	CommsMenu_Shutdown( true )
}


bool function OrdnanceWheelToggleEnabled()
{
	return false
}


bool function OrdnanceWheelUseOnRelease()
{
	if( Flowstate_IsHaloMode() )
		return false

	return true && !OrdnanceUseOnHold()
}


bool function OrdnanceUseOnHold()
{
	if( Flowstate_IsHaloMode() )
		return false

	return false && !OrdnanceWheelToggleEnabled()
}


void function OrdnanceMenu_Down( entity player )
{
	if ( !SURVIVAL_PlayerCanSwitchOrdnance( player ) )
		return

	#if(false)


#endif

	if ( !CommsMenu_CanUseMenu( player ) )
		return

	if ( Bleedout_IsBleedingOut( player ) )
		return

	CommsMenu_OpenMenuTo( player, eChatPage.ORDNANCE_LIST, eCommsMenuStyle.ORDNANCE_MENU, false )
}


void function OrdnanceMenu_Up( entity player )
{
	if ( !IsCommsMenuActive() )
		return
	if ( CommsMenu_GetCurrentCommsMenu() != eCommsMenuStyle.ORDNANCE_MENU )
		return

	if ( CommsMenu_HasValidSelection() )
		CommsMenu_ExecuteSelection( eWheelInputType.NONE )

	CommsMenu_Shutdown( true )
}



void function GadgetSlot_Down( entity player )
{
	if ( !SURVIVAL_PlayerCanSwitchOrdnance( player ) )
		return






	if ( Bleedout_IsBleedingOut( player ) )
		return

	string equipRef = EquipmentSlot_GetLootRefForSlot( player, "gadgetslot" )
	if ( equipRef == "" )
		return
	else
	{
		if( SURVIVAL_Loot_GetLootDataByRef( equipRef ).lootType == eLootType.GADGET )
		{
		//	Remote_ServerCallFunction( "ClientCallback_Sur_EquipGadget", equipRef )
		}
	}
}
const float MINIMAP_SCALE_SPECTATE = 1.0
void function OnFirstPersonSpectateStarted( entity player, entity currentTarget )
{
	if ( !Flag( "SquadEliminated" ) )
		StopLocal1PDeathSound()

	if ( IsValid( currentTarget ) && currentTarget.IsPlayer() )
		thread InitSurvivalHealthBar()

	Minimap_SetSizeScale( MINIMAP_SCALE_SPECTATE )
}

void function OnViewPlayerChanged( entity newViewPlayer )
{
	if ( IsValid( newViewPlayer ) && newViewPlayer.IsPlayer() )
	{
		bool isReady = ToEHI( newViewPlayer ) != EHI_null && IsLocalClientEHIValid();
		if ( isReady )
		{
			thread InitSurvivalHealthBar()
			ScorebarInitTracking( newViewPlayer, ClGameState_GetRui() )
		}
	}
}

void function OnPlayerLoadoutChanged( EHI playerEHI, ItemFlavor flavour )
{
	entity player = FromEHI( playerEHI )
	if ( player == GetLocalViewPlayer() )
	{
		thread InitSurvivalHealthBar()
	}

	Squads_SetCustomPlayerInfo( player )
}

void function OnLocalPlayerSpawned( entity localPlayer )
{
	thread InitSurvivalHealthBar()
	ScorebarInitTracking( localPlayer, ClGameState_GetRui() )

	Minimap_SetSizeScale( 1.0 )
}


void function OnPlayerMatchStateChanged( entity player, int oldState, int newState )
{
	switch ( newState )
	{
		case ePlayerMatchState.SKYDIVE_PRELAUNCH:
		case ePlayerMatchState.SKYDIVE_FALLING:
			Minimap_SetSizeScale( MINIMAP_SCALE_SPECTATE )
			break

		case ePlayerMatchState.NORMAL:
		case ePlayerMatchState.STAGING_AREA:
			Minimap_SetSizeScale( 1.0 )
			break
	}

	UpdateIsSonyMP()
	Chroma_UpdateBackground()
}


void function UICallback_UpdateCharacterDetailsPanel( var ruiPanel )
{
	var rui              = Hud_GetRui( ruiPanel )
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( GetLocalClientPlayer() ), Loadout_Character() )
	UpdateCharacterDetailsMenu( rui, character, true )
}


void function UICallback_OpenCharacterSelectNewMenu()
{
	entity player = GetLocalClientPlayer()
	if ( IsAlive( player ) && player.ContextAction_IsMeleeExecution() )
		return

	if ( ( GetGameState() < eGameState.PickLoadout && !IsSurvivalTraining() ) || GetCurrentPlaylistVarBool( "character_reselect_enabled", false ) )
	{
		OpenCharacterSelectNewMenu( true )
	}
}


void function UICallback_QueryPlayerCanBeRespawned()
{
	entity player             = GetLocalClientPlayer()
	bool playerCanBeRespawned = (PlayerIsMarkedAsCanBeRespawned( player ) && (GetGameState() == eGameState.Playing))

	bool penaltyMayBeActive
	if ( IsRankedGame() )
	{
		penaltyMayBeActive = Ranked_IsPlayerAbandoning( player ) //
	}
	else
	{
		penaltyMayBeActive = PlayerMatchState_GetFor( GetLocalClientPlayer() ) < ePlayerMatchState.NORMAL
		penaltyMayBeActive = penaltyMayBeActive && GetPlayerArrayOfTeam( player.GetTeam() ).len() == 3
	}

	RunUIScript( "ConfirmLeaveMatchDialog_SetPlayerCanBeRespawned", playerCanBeRespawned, penaltyMayBeActive )
}

void function ServerCallback_PromptTaunt()
{
	int selectedIndex = -1

	EHI playerEHI        = LocalClientEHI()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, Loadout_Character() )

	array<ItemFlavor> options
	table<ItemFlavor, int> optionToIndex
	entity localPlayer = FromEHI( playerEHI )
	if ( IsValid( localPlayer ) && !CanPlayerSpeak( localPlayer ) )
		return

	{
		for ( int i = 0; i < MAX_QUIPS_EQUIPPED; i++ )
		{
			LoadoutEntry entry = Loadout_CharacterQuip( character, i )
			ItemFlavor quip    = LoadoutSlot_GetItemFlavor( playerEHI, entry )
			if ( !CharacterQuip_IsTheEmpty( quip ) )
			{
				options.append( quip )
				optionToIndex[ quip ] <- i
			}
		}
	}

	string promptString = "#PING_SAY_CELEBRATE"

	if ( options.len() > 0 )
	{
		ItemFlavor flav = options.getrandom()



		selectedIndex = optionToIndex[ flav ]
	}

	AddPingBlockingFunction( "quickchat",
		void function( entity player ) : ( selectedIndex, promptString )
		{
			if ( selectedIndex == -1 )
				Quickchat( player, eCommsAction.QUICKCHAT_CELEBRATE, null )
			else
			{

					PerformQuipAtSlot( selectedIndex )
			}
		},
		6.0, Localize( promptString ) )
}

void function ServerCallback_PromptWelcome()
{
	if ( ShouldMuteCommsActionForCooldown( GetLocalViewPlayer(), eCommsAction.REPLY_WELCOME, null ) )
		return

	AddPingBlockingFunction( "quickchat", CreateQuickchatFunction( eCommsAction.REPLY_WELCOME, null ), 6.0, Localize( "#PING_SAY_WELCOME" ) )
}


void function ServerCallback_PromptSayThanks( entity thankee )
{
	if ( ShouldMuteCommsActionForCooldown( GetLocalViewPlayer(), eCommsAction.REPLY_THANKS, null ) )
		return

	AddPingBlockingFunction( "quickchat", CreateQuickchatFunction( eCommsAction.REPLY_THANKS, thankee ), 6.0, Localize( "#PING_SAY_THANKS", thankee.GetPlayerName() ) )
}


void functionref(entity) function CreateQuickchatFunction( int commsAction, entity thankee )
{
	return void function( entity player ) : ( thankee, commsAction )
	{
		Quickchat( player, commsAction, thankee )
	}
}


bool function CanReportPlayer( entity target )
{
	int reportStyle = GetReportStyle()

	if ( !IsValid( target ) )
		return false

	if ( !target.IsPlayer() )
		return false

	#if(CONSOLE_PROG)
		reportStyle = minint( reportStyle, 1 )
	#endif

	switch ( reportStyle )
	{
		case 0: //
		return false

		case 1: //
		return target.GetHardware() == GetLocalClientPlayer().GetHardware()

		case 2: //
		break

		default:
			return false
	}

	return true
}


void function OnPlayerKilled( entity player )
{
	entity viewPlayer = GetLocalViewPlayer()
	if ( player.GetTeam() == viewPlayer.GetTeam() && player != viewPlayer )
	{
		EmitSoundOnEntity( viewPlayer, SOUND_UI_TEAMMATE_KILLED )
	}
}


void function UpdateInventoryCounter( entity player, string ref, bool isFull = false )
{
	var rui = file.inventoryCountRui

	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat2( rui, "offset", <0.0, 0.18, 0.0> )
	RuiSetInt( rui, "maxCount", SURVIVAL_GetInventoryLimit( player ) )
	RuiSetInt( rui, "currentCount", SURVIVAL_GetInventoryCount( player ) )
	RuiSetInt( rui, "highlightCount", 0 ) //
	RuiSetBool( rui, "isFull", isFull )
}


void function TryUpdateInventoryCounter( entity player, LootData data, int lootAction )
{
	if ( lootAction == eLootAction.PICKUP || lootAction == eLootAction.PICKUP_ALL || data.lootType == eLootType.BACKPACK )
	{
		UpdateInventoryCounter( player, data.ref )
	}
}


void function PlayerHudSetWeaponInspect( bool inspect )
{
	RuiSetBool( file.pilotRui, "weaponInspect", inspect )
	RuiSetBool( file.dpadMenuRui, "weaponInspect", inspect )
}


void function ServerCallback_NessyMessage( int state )
{
	switch( state )
	{
		case 0:
			Obituary_Print_Localized( Localize( "#NESSY_APPEARS" ) )
		break

		case 1:
			Obituary_Print_Localized( Localize( "#NESSY_SURFACES" ) )
		break

		case 40:
		//printt("Mantling, zipline use count reset.")
		entity player = GetLocalClientPlayer()
		player.p.ziplineUsages = 0
		break
	}
}


void function ServerCallback_RefreshInventoryAndWeaponInfo()
{
	ServerCallback_RefreshInventory()
	ClWeaponStatus_RefreshWeaponInfo()
}


void function UIToClient_ToggleMute()
{
	ToggleSquadMute()
}


void function ToggleSquadMute()
{
	SetSquadMuteState( !file.isSquadMuted )
}


void function SetSquadMuteState( bool isSquadMuted )
{
	file.isSquadMuted = isSquadMuted
	foreach ( player in GetPlayerArrayOfTeam( GetLocalClientPlayer().GetTeam() ) )
	{
		if ( player == GetLocalClientPlayer() )
			continue

		if ( player.IsTextMuted() != isSquadMuted )
		{
			TogglePlayerTextMute( player )
		}

		if ( player.IsVoiceMuted() != isSquadMuted )
		{
			TogglePlayerVoiceMute( player )
		}
	}

	foreach ( cb in file.squadMuteChangeCallbacks )
		cb()
}


bool function IsSquadMuted()
{
	return file.isSquadMuted
}


bool function SquadMuteIntroEnabled()
{
	return IsFiringRangeGameMode() ? false : GetCurrentPlaylistVarBool( "squad_mute_intro_enable", true )
}


void function AddCallback_OnSquadMuteChanged( void functionref() cb )
{
	file.squadMuteChangeCallbacks.append( cb )
}


void function OnSquadMuteChanged()
{
	UpdateWaitingForPlayersMuteHint()
}


void function ServerCallback_RefreshDeathBoxHighlight()
{
	array<entity> boxes = GetAllDeathBoxes()
	ArrayRemoveInvalid( boxes )
	foreach ( box in boxes )
	{
		ManageHighlightEntity( box )
	}
}


bool function CircleAnnouncementsEnabled()
{
	return file.circleAnnouncementsEnabled
}


void function CircleAnnouncementsEnable( bool state )
{
	file.circleAnnouncementsEnabled = state
}


var function GetCompassRui()
{
	return file.compassRui
}

var function GetDpadMenuRui()
{
	return file.dpadMenuRui
}



void function AddCallback_ShouldRunCharacterSelection( bool functionref() func )
{
	file.shouldRunCharacterSelectionCallback = func
}

void function DEV_SendCheatsStateToUI()
{
	bool cheatsState = GetConVarBool( "sv_cheats" )
	RunUIScript("UpdateCheatsState", cheatsState)
}

void function EvolvingArmor_SetEvolutionRuiAnimTime()
{
	if ( file.pilotRui == null )
		return

	RuiSetGameTime( file.pilotRui, "evolvingArmorUpgradeStartTime", Time() )
}


void function SetEvoArmorModifier( float modifier, asset image )
{
	if( IsValid( file.pilotRui ) )
	{
		RuiSetFloat( file.pilotRui, "evoShieldMultiplier", modifier )
		RuiSetImage( file.pilotRui, "evoShieldMultiplierImage", image )
	}
}
