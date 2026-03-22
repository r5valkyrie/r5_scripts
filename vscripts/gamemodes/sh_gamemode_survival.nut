//

// Moved from cl_gamemode_survival.nut for compile order (sh_ files compile before cl_)
#if CLIENT
global struct SummaryDisplayData
{
	string displayString
	int	displayValue
}

global struct SquadSummaryPlayerData
{
	int eHandle
	int kills
	int assists
	int knockdowns
	int damageDealt
	int survivalTime
	int revivesGiven
	int respawnsGiven
	entity victoryScreenCharacterModel
	array< SummaryDisplayData > modeSpecificSummaryData
	bool summary3IsTime
}

global struct SquadSummaryData
{
	array<SquadSummaryPlayerData> playerData
	int                           squadPlacement = -1
	int 						  gameResultFlags = 0
	int 						  gameScoreFlags = 0
}
#endif

global function PreGame_GetWaitingForPlayersHasBlackScreen
global function PreGame_GetWaitingForPlayersSpawningEnabled
global function PreGame_GetWaitingForPlayersDelayMin
global function PreGame_GetWaitingForPlayersDelayMax
global function PreGame_GetWaitingForPlayersCountdown
global function CharSelect_GetIntroMusicStartTime
global function CharSelect_GetIntroTransitionDuration
global function CharSelect_GetIntroCountdownDuration
global function CharSelect_GetPickingDelayBeforeAll
global function CharSelect_GetPickingDelayOnFirst
global function CharSelect_GetPickingSingleDurationMax
global function CharSelect_GetPickingSingleDurationMin
global function CharSelect_GetPickingDelayAfterEachLock
global function CharSelect_GetPickingDelayAfterAll
global function CharSelect_GetOutroSceneChangeDuration
global function CharSelect_GetOutroAllSquadsPresentDuration
global function CharSelect_GetOutroSquadPresentDuration
global function CharSelect_GetOutroMVPPresentDuration
global function CharSelect_GetOutroChampionPresentDuration
global function CharSelect_GetOutroTransitionDuration

#if SERVER || CLIENT
global function GamemodeSurvivalShared_Init

global function Survival_CanUseHealthPack
global function Survival_PlayerCanDrop

global function Survival_GetCharacterSelectDuration
global function Survival_CharacterSelectEnabled

global function Sur_SetPlaneCenterEnt
global function Sur_SetPlaneEnt
global function Sur_GetPlaneCenterEnt
global function Sur_GetPlaneEnt
global function SetVictorySequencePlatformModel
global function GetVictorySequencePlatformModel
global function PredictHealthPackUse

global function GetMusicForJump

global function PositionIsInMapBounds
global function Survival_IsPlayerHealing

global function PlayerIsMarkedAsCanBeRespawned

global function Survival_IsDropshipClampedToRing
global function Survival_GetPlaneMoveSpeed
global function Survival_GetPlaneJumpDelay
global function Survival_GetPlaneLeaveMapDurationMultiplier

                       
                                         
                                                 
                                           
                                             
                                             
                                                 
                                                      
                                          
                                                 
                                                
      

global function Survival_RequireJumpmasterInPlane
#endif

#if SERVER
global function Survival_GetCurrentRank
global function Survival_GetFinalRank

                       
                                
                                
                                      
                                      
                                      
                                                
                                                
      
#endif

                  
          
                            
      
      

#if SERVER && DEVELOPER
global function DEV_OverridePodiumBackground
global function DEV_OverridePodiumBanners
global function DEV_OverridePodiumBase
global function DEV_TeleportToPodium
#endif


#if UI
global function GamemodeSurvivalShared_UI_Init
#endif

global function IsSquadDataPersistenceEmpty

global const float MAX_MAP_BOUNDS = 61000.0

global const string SURVIVAL_DEFAULT_TITAN_DEFENSE = "mp_titanability_arm_block"

global const float CHARACTER_SELECT_OPEN_TRANSITION_DURATION = 3.0
global const float CHARACTER_SELECT_CLOSE_TRANSITION_DURATION = 3.0
global const float CHARACTER_SELECT_CHARACTER_LOCK_DURATION = 0.5
global const float CHARACTER_SELECT_FINISHED_HOLD_DURATION = 2.5
global const float CHARACTER_SELECT_PRE_PICK_COUNTDOWN_DURATION = 4.0
global const float CHARACTER_SELECT_SCENE_ROTATE_DURATION = 4.0

global const float SURVIVAL_MINIMAP_RING_SCALE = 65536
global const SMALL_HEALTH_USE_TIME = 4.0
global const MEDIUM_HEALTH_USE_TIME = 7.0
global const LARGE_HEALTH_USE_TIME = 12.0
global const SYRINGE_HEALTH_USE_TIME = 4.0

global const int SURVIVAL_MAP_GRIDSIZE = 7

global const SURVIVAL_PLANE_MODEL = $"mdl/vehicles_r2/spacecraft/draconis/draconis_flying_small.rmdl"
global const SURVIVAL_SQUAD_SUMMARY_MODEL = $"mdl/levels_terrain/mp_lobby/mp_setting_menu.rmdl"
global const string SURVIVAL_PLANE_NAME = "planeEnt"

const int USEHEALTHPACK_DENY_NONE = -1
const int USEHEALTHPACK_ALLOW = 0
const int USEHEALTHPACK_DENY_ULT_FULL = 1
const int USEHEALTHPACK_DENY_HEALTH_FULL = 2
const int USEHEALTHPACK_DENY_SHIELD_FULL = 3
const int USEHEALTHPACK_DENY_NO_HEALTH_KITS = 4
const int USEHEALTHPACK_DENY_NO_SHIELD_KITS = 5
const int USEHEALTHPACK_DENY_NO_KITS = 6
const int USEHEALTHPACK_DENY_FULL = 7

const string PODIUM_FX_SPARKS_L1 = "sparks_L1"
const string PODIUM_FX_SPARKS_L2 = "sparks_L2"
const string PODIUM_FX_SPARKS_R1 = "sparks_R1"
const string PODIUM_FX_SPARKS_R2 = "sparks_R2"
const string PODIUM_FX_FIREBALL_L1 = "Fireball_L1"
const string PODIUM_FX_FIREBALL_L2 = "Fireball_L2"
const string PODIUM_FX_FIREBALL_R1 = "Fireball_R1"
const string PODIUM_FX_FIREBALL_R2 = "Fireball_R2"
const string PODIUM_FX_CONFETTI = "confetti_burst"

// each mode should have enums that are specific to the final display location - e.g., 4 displays in "slot 4" -> 1 / 1a / 1b | 2 | 3 | 4 | 5 -- maps to --> [ 0, ... , 0 ]
// so 4 would be index 4 - or the 5th slot - *in the array* or position 3 on the UI.
global const int NUMBER_OF_SUMMARY_DISPLAY_VALUES = 7 // 1 - 1a - 1b / 2 / 3 (time) / 4 / 5
global const array< int > SUMMARY_DISPLAY_EMPTY_SET = [ 0, 0, 0, 0, 0, 0, 0 ]

enum eUseHealthKitResult
{
	ALLOW,
	DENY_NONE,
	DENY_ULT_FULL,
	DENY_ULT_NOTREADY,
	DENY_HEALTH_FULL,
	DENY_SHIELD_FULL,
	DENY_NO_HEALTH_KIT,
	DENY_NO_SHIELD_KIT,
	DENY_NO_KITS,
	DENY_NO_SHIELDS,
	DENY_FULL,
	DENY_SPRINTING,
}

table< int, string > healthKitResultStrings =
{
	[eUseHealthKitResult.ALLOW] = "",
	[eUseHealthKitResult.DENY_NONE] = "",
	[eUseHealthKitResult.DENY_ULT_FULL] = "#DENY_ULT_FULL",
	[eUseHealthKitResult.DENY_ULT_NOTREADY ] = "#DENY_ULT_NOTREADY",
	[eUseHealthKitResult.DENY_HEALTH_FULL] = "#DENY_HEALTH_FULL",
	[eUseHealthKitResult.DENY_SHIELD_FULL] = "#DENY_SHIELD_FULL",
	[eUseHealthKitResult.DENY_NO_HEALTH_KIT] = "#DENY_NO_HEALTH_KIT",
	[eUseHealthKitResult.DENY_NO_SHIELD_KIT] = "#DENY_NO_SHIELD_KIT",
	[eUseHealthKitResult.DENY_NO_KITS] = "#DENY_NO_KITS",
	[eUseHealthKitResult.DENY_NO_SHIELDS] = "#DENY_NO_SHIELDS",
	[eUseHealthKitResult.DENY_FULL] = "#DENY_FULL",
	[eUseHealthKitResult.DENY_SPRINTING] = "#DENY_SPRINTING",
}

global struct TargetKitHealthAmounts
{
	float targetHealth
	float targetShields
}

global enum eSurvivalHints
{
	EQUIP,
	ORDNANCE,
                               
	ORDNANCE_FUSE,
	ORDNANCE_FUSE_MULTI,
      
                               
	CRYPTO_DRONE_ACCESS,
      
              
                       
                        
      
}

global enum ePodiumBanner
{
	NORMAL = 0,
	ANNIVERSARY,
	FREEDM,
	CONTROL,
	LTM,
	MIXTAPE,
                            
	SR_LEGENDS,
	SR_REV,
      
                    
	TURBO,
      
	_COUNT
}

global enum ePodiumBackground
{
	MP_RR_DESERTLANDS_HU = 0,
	MP_RR_DIVIDED_MOON,
	MP_RR_CANYONLANDS_HU,
	MP_RR_OLYMPUS_MU2,
	MP_RR_TROPICS_ISLAND_MU1,
	MP_RR_ADQUEDUCT,
	MP_RR_ARENA_HABITAT,
	MP_RR_PARTY_CRASHER,
	MP_RR_ARENA_PHASE_RUNNER,
	MP_RR_FREEDM_SKULLTOWN,
	MP_RR_ARENA_SKYGARDER,
	MP_RR_OLYMPUS_MU1_NIGHT,
	MP_RR_DESERTLANDS_NIGHT,
	MP_RR_CANYONLANDS_MU1_NIGHT,
                            
	SR_LEGENDS,
	SR_REV,
      
	MP_RR_TROPICS_ISLAND_MU2,
	MP_RR_THUNDERDOME,
	_COUNT
}

global struct VictoryPlatformModelData
{
	bool   isSet = false // DEPRECATED
	asset  modelAsset = $"mdl/dev/empty_model.rmdl"
	vector originOffset = < 0, 0, -10 >
	vector modelAngles = < 0, 0, 0 >
}

struct
{
	entity                     planeCenterEnt
	entity                     planeEnt
                        
            
                               
                                     
                        
                                                                                                                                                                                        
        
       
	VictoryPlatformModelData & victorySequencePlatforData

	#if SERVER && DEVELOPER
		bool podiumFXSeqInProgress = false
	#endif
} file


bool function HasFastIntro()
{
	if ( GetCurrentPlaylistVarBool( "fast_intro", false ) )
		return true

	return false // ConVar "fast_intro" not in S3
}

//
bool function PreGame_GetWaitingForPlayersHasBlackScreen()		{ return GetCurrentPlaylistVarBool( "waiting_for_players_has_black_screen", false ) }
bool function PreGame_GetWaitingForPlayersSpawningEnabled()		{ return GetCurrentPlaylistVarBool( "waiting_for_players_spawning_enabled", false ) }
float function PreGame_GetWaitingForPlayersDelayMin()			{ return GetCurrentPlaylistVarFloat( "waiting_for_players_min_wait", 0.0 ) }
float function PreGame_GetWaitingForPlayersDelayMax()			{ return GetCurrentPlaylistVarFloat( "waiting_for_players_timeout_seconds", 20.0 ) }
float function PreGame_GetWaitingForPlayersCountdown()			{ return (HasFastIntro() ? 0.0 : GetCurrentPlaylistVarFloat( "waiting_for_players_countdown_seconds", 8.0 ) ) }
//
float function CharSelect_GetIntroMusicStartTime()		 		{ return GetCurrentPlaylistVarFloat( "charselect_intro_music_start_time", -0.8 ) }
float function CharSelect_GetIntroTransitionDuration()			{ return GetCurrentPlaylistVarFloat( "charselect_intro_transition_duration", 3.0 ) }
float function CharSelect_GetIntroCountdownDuration()			{ return GetCurrentPlaylistVarFloat( "charselect_intro_countdown_duration", 0.0 ) }
//
float function CharSelect_GetPickingDelayBeforeAll()			{ return GetCurrentPlaylistVarFloat( "charselect_picking_delay_before_all", 0.0 ) }
float function CharSelect_GetPickingDelayOnFirst()				{ return GetCurrentPlaylistVarFloat( "charselect_picking_delay_on_first", 1.5 ) }
float function CharSelect_GetPickingSingleDurationMax()			{ return (HasFastIntro() ? 0.0 : GetCurrentPlaylistVarFloat( "character_select_time_max", 8.0 ) ) }
float function CharSelect_GetPickingSingleDurationMin()			{ return (HasFastIntro() ? 0.0 : GetCurrentPlaylistVarFloat( "character_select_time_min", 6.0 ) ) }
float function CharSelect_GetPickingDelayAfterEachLock()		{ return GetCurrentPlaylistVarFloat( "charselect_picking_delay_after_each_lock", 0.5 ) }
float function CharSelect_GetPickingDelayAfterAll()				{ return GetCurrentPlaylistVarFloat( "charselect_picking_delay_after_all", 1.5 ) }
//
float function CharSelect_GetOutroSceneChangeDuration()			{ return GetCurrentPlaylistVarFloat( "charselect_outro_scene_change_duration", 4.0 ) }
float function CharSelect_GetOutroAllSquadsPresentDuration()	{ return GetCurrentPlaylistVarFloat( "charselect_outro_all_squads_present_duration", 0.0 ) }
float function CharSelect_GetOutroSquadPresentDuration()		{ return GetCurrentPlaylistVarFloat( "charselect_outro_squad_present_duration", 6.0  ) }
float function CharSelect_GetOutroMVPPresentDuration()			{ return GetCurrentPlaylistVarFloat( "charselect_outro_mvp_present_duration", 0.0 ) }
float function CharSelect_GetOutroChampionPresentDuration()		{ return GetCurrentPlaylistVarFloat( "charselect_outro_champion_present_duration", 8.0 ) }
float function CharSelect_GetOutroTransitionDuration()			{ return GetCurrentPlaylistVarFloat( "charselect_outro_transition_duration", 3.0 ) }


#if SERVER || CLIENT
void function GamemodeSurvivalShared_Init()
{
	#if SERVER || CLIENT
		BleedoutShared_Init()
		ShApexScreens_Init()
		Sh_RespawnBeacon_Init()

		MobileRespawnBeacon_Init()
		Sh_Airdrops_Init()

                      
                      
                            

                          
                          
                                

                        
                          
        

		PrecacheImpactEffectTable( "dropship_dust" )
		PrecacheModel( SURVIVAL_PLANE_MODEL )
		PrecacheModel( SURVIVAL_SQUAD_SUMMARY_MODEL )

		AddCallback_PlayerCanUseZipline( Sur_CanUseZipline )
		MapZones_SharedInit()
		ClientMusic_SharedInit()

		AddCallback_CanStartCustomWeaponActivity( ACT_VM_WEAPON_INSPECT, CanWeaponInspect )

		Remote_RegisterServerFunction( "ClientCallback_Sur_RequestSquadDataPersistence" )
		Remote_RegisterServerFunction( "ClientCallback_Sur_UpdateCharacterLock", "bool")

		// GamemodeSurvival_Init
		var dt = GetDataTable( LOOT_DATATABLE )
		int numRows = GetDataTableRowCount( dt )
		Remote_RegisterServerFunction( "ClientCallback_Sur_UseHealthPack", "int", -1, numRows )
		Remote_RegisterServerFunction( "ClientCallback_Sur_DropBackpackItem", "int", -1, numRows, "int", 0, INT_MAX )
		Remote_RegisterServerFunction( "ClientCallback_Sur_DropBackpackItem_Box", "int", -1, numRows, "int", 0, INT_MAX, "int",INT_MIN, INT_MAX )
		Remote_RegisterServerFunction( "ClientCallback_Sur_DropEquipment", "int", 0, eEquipmentSlotType.COUNT )
		Remote_RegisterServerFunction( "ClientCallback_Sur_EquipOrdnance", "int", -1, numRows )
		Remote_RegisterServerFunction( "ClientCallback_Sur_EquipGadget", "int", -1, numRows )
		Remote_RegisterServerFunction( "ClientCallback_Sur_EquipAttachment", "int", -1, numRows, "int", -1, INT_MAX )
		Remote_RegisterServerFunction( "ClientCallback_Sur_UnequipAttachment", "int", -1, numRows, "int", -1, INT_MAX, "bool" )
		Remote_RegisterServerFunction( "ClientCallback_Sur_TransferAttachment", "int", -1, numRows, "int", WEAPON_INVENTORY_SLOT_PRIMARY_0, WEAPON_INVENTORY_SLOT_PRIMARY_1 )

		Remote_RegisterServerFunction( "ClientCallback_Sur_CancelHeal" )

		Remote_RegisterServerFunction( "ClientCallback_TPPromptGoToMapPoint", "float", -FLT_MAX, FLT_MAX, 32, "float", -FLT_MAX, FLT_MAX, 32 )
		RegisterNetworkedVariable( "numberOfAirdropRoundsLeft", SNDC_GLOBAL, SNVT_INT, 0 )
	#endif

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.burn, Player_OnBurnDamage )

		                  
			AddDamageCallbackSourceID( eDamageSourceId.caustic_toxin, Player_OnCausticToxinDamage )
                          

	#endif // SERVER

	if ( FreelanceSystemsAreEnabled() )
	{
		FreelanceNPCs_Init()
		SkitSystem_Init()
		ObjectiveSystem_Init()
		EncounterSystem_Init()

#if SERVER
		NPCGarbageCollection_InitForGameMode()
		PVELoot_InitForGameMode()
#endif // SERVER

	}

#if SERVER
                       
                                                                             
      
#endif //server

#if SERVER
	Survival_AddCallback_OnPlayerLaunchedFromPlane(LTM_AnnouncementSplash)
#endif //server

#if SERVER || CLIENT
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
#endif

                       
           
                                                                                                                                                                  
       
      
}
#endif

#if SERVER || CLIENT
void function EntitiesDidLoad()
{
	// TODO BA: Switch this to an entity that is available on both client / server.

	#if SERVER
		string entityToCheck = "podium_bg_skin_swap"
	#elseif CLIENT
		string entityToCheck = "podium_info_target"
	#endif

	array< entity > podiumInfoTargets = GetEntArrayByScriptName(entityToCheck )
	if ( podiumInfoTargets.len() != 1 )
		return // Map is not setup for this.

	SetVictorySequencePlatformModel( $"mdl/dev/empty_model.rmdl", < 0, 0, -10 >, < 0, 0, 0 > )
#if CLIENT
	SetVictorySequenceLocationFromInfoNode()
#endif

#if SERVER
	SetupVictoryPodium()

	FlagInit( PODIUM_FX_SPARKS_L1 )
	FlagInit( PODIUM_FX_SPARKS_L2 )
	FlagInit( PODIUM_FX_SPARKS_R1 )
	FlagInit( PODIUM_FX_SPARKS_R2 )
	FlagInit( PODIUM_FX_FIREBALL_L1)
	FlagInit( PODIUM_FX_FIREBALL_L2)
	FlagInit( PODIUM_FX_FIREBALL_R1)
	FlagInit( PODIUM_FX_FIREBALL_R2)
	FlagInit( PODIUM_FX_CONFETTI)

	AddCallback_GameStateEnter( eGameState.Resolution, Podium_OnResolution )
#endif
}
#endif

#if UI
void function GamemodeSurvivalShared_UI_Init()
{
	AddUICallback_InputModeChanged( UIInputChanged )
}

void function UIInputChanged( bool controllerModeActive )
{

}
#endif

#if SERVER || CLIENT
bool function Survival_PlayerCanDrop( entity player )
{
	if ( !IsAlive( player ) )
		return false

	if ( IsEventFinale() )
		return false

	//if ( !GamePlaying() )
	//	return false

                       
                                                               
              
      

	if ( player.ContextAction_IsActive() && !player.ContextAction_IsRodeo() )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( player.IsPhaseShifted() )
		return false

	if ( player.IsGrappleActive() )
		return false
	
	if ( player.IsTraversing() || player.IsWallHanging() || player.IsWallRunning() )
		return false
	
	if ( player.p.isInExtendedUse )
		return false
	
	if ( IsPlayerInCryptoDroneCameraView( player ) )
		return false

                            
	if ( ExplosiveHold_IsPlayerPlantingGrenade( player ) )
		return false
      

	if ( player.PlayerMelee_GetState() == PLAYER_MELEE_STATE_SLAM_ATTACK )
		return false

	return true
}

bool function Survival_CanUseHealthPack( entity player, int itemType, bool checkInventory = false, bool printReason = false )
{
	if ( itemType == eHealthPickupType.INVALID )
		return false

	int canUseResult = Survival_TryUseHealthPack( player, itemType )
	if ( canUseResult == eUseHealthKitResult.ALLOW )
	{
		if ( checkInventory )
		{
			if ( SURVIVAL_CountItemsInInventory( player, SURVIVAL_Loot_GetHealthPickupRefFromType( itemType ) ) > 0 )
				return true

			bool needHeal   = GetHealthFrac( player ) < 1.0
			bool needShield = GetShieldHealthFrac( player ) < 1.0

			if ( needHeal && needShield )
				canUseResult = eUseHealthKitResult.DENY_NO_KITS
			else if ( needShield )
				canUseResult = eUseHealthKitResult.DENY_NO_SHIELD_KIT
			else
				canUseResult = eUseHealthKitResult.DENY_NO_HEALTH_KIT
		}
		else
		{
			return true
		}
	}

	#if CLIENT
		if ( printReason )
		{
			switch( canUseResult )
			{
				case eUseHealthKitResult.DENY_NONE:
					// no announcement
					break

				case eUseHealthKitResult.DENY_NO_HEALTH_KIT:
				case eUseHealthKitResult.DENY_NO_KITS:
				case eUseHealthKitResult.DENY_NO_SHIELD_KIT:
					Remote_ServerCallFunction( "ClientCallback_Quickchat", eCommsAction.INVENTORY_NEED_HEALTH, eCommsFlags.NONE )
					// falls through to announcement
				default:
					AnnouncementMessageRight( player, healthKitResultStrings[canUseResult] )
					break
			}
		}
	#endif

	return false

	/*
	#if CLIENT
		if ( player != GetLocalClientPlayer() )
			return false

		if ( player != GetLocalViewPlayer() )
			return false

		if ( IsWatchingReplay() )
			return false
	#elseif SERVER
		if ( Bleedout_IsPlayerGivingFirstAid( player ) )
			return false
	#endif

	if ( player.ContextAction_IsActive() && !player.ContextAction_IsRodeo() )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( !IsAlive( player ) )
		return false

	if ( player.IsPhaseShifted() )
		return false

	if ( StatusEffect_GetSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return false

	if ( player.GetWeaponDisableFlags() == WEAPON_DISABLE_FLAGS_ALL )
		return false

	if ( player.IsTitan() )
		return false

	if ( itemType == eHealthPickupType.ULTIMATE )
	{
		entity ultimateAbility = player.GetOffhandWeapon( OFFHAND_INVENTORY )
		int ammo = ultimateAbility.GetWeaponPrimaryClipCount()
		int maxAmmo = ultimateAbility.GetWeaponPrimaryClipCountMax()

		if( ammo >= maxAmmo )
			return false
	}
	else
	{
		int currentHealth = player.GetHealth()
		int currentShields = player.GetShieldHealth()
		bool canHeal = false
		bool canShield = false

		HealthPickup pickup = SURVIVAL_Loot_GetHealthKitDataFromStruct( itemType )

		if ( pickup.healAmount > 0 && currentHealth < pickup.healCap )
			canHeal = true

		if ( pickup.healAmount > 0 && pickup.healTime > 0 )
			canHeal = true

		if ( pickup.shieldAmount > 0 && currentShields < player.GetShieldHealthMax() )
			canShield = true

		if ( pickup.healAmount > 0 && pickup.healCap > 100 )
		{
			int targetHealth = int( currentHealth + pickup.healAmount )
			int overHeal = targetHealth - player.GetMaxHealth()
			if ( overHeal && currentShields < player.GetShieldHealthMax() )
				canShield = true
		}

		if ( !canHeal && !canShield )
			return false
	}

	return true
	*/
}

int function Survival_TryUseHealthPack( entity player, int itemType )
{
	#if CLIENT
		if ( player != GetLocalClientPlayer() )
			return eUseHealthKitResult.DENY_NONE

		if ( player != GetLocalViewPlayer() )
			return eUseHealthKitResult.DENY_NONE

		if ( IsWatchingReplay() )
			return eUseHealthKitResult.DENY_NONE
	#elseif SERVER
		if ( Bleedout_IsPlayerGivingFirstAid( player ) )
			return eUseHealthKitResult.DENY_NONE
	#endif

	if ( player.ContextAction_IsActive() && !player.ContextAction_IsRodeo() )
		return eUseHealthKitResult.DENY_NONE

	if ( Bleedout_IsBleedingOut( player ) )
		return eUseHealthKitResult.DENY_NONE

	if ( !IsAlive( player ) )
		return eUseHealthKitResult.DENY_NONE

	if ( player.IsPhaseShifted() )
		return eUseHealthKitResult.DENY_NONE

	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return eUseHealthKitResult.DENY_NONE

	if ( player.GetWeaponDisableFlags() == WEAPON_DISABLE_FLAGS_ALL )
		return eUseHealthKitResult.DENY_NONE

	if ( player.IsTitan() )
		return eUseHealthKitResult.DENY_NONE

	if ( itemType == eHealthPickupType.ULTIMATE )
	{
		entity ultimateAbility = player.GetOffhandWeapon( OFFHAND_INVENTORY )
		int ammo               = ultimateAbility.GetWeaponPrimaryClipCount()
		int maxAmmo            = ultimateAbility.GetWeaponPrimaryClipCountMax()

		if ( ammo >= maxAmmo )
			return eUseHealthKitResult.DENY_ULT_FULL
		if ( !ultimateAbility.IsReadyToFire() )
			return eUseHealthKitResult.DENY_ULT_NOTREADY
	}
	else
	{
		int currentHealth  = player.GetHealth()
		int currentShields = player.GetShieldHealth()
		bool canHeal       = false
		bool canShield     = false
		bool needHeal      = currentHealth < player.GetMaxHealth()
		bool needShield    = currentShields < player.GetShieldHealthMax()

		HealthPickup pickup = SURVIVAL_Loot_GetHealthKitDataFromStruct( itemType )

		if ( pickup.healAmount > 0 && pickup.shieldAmount == 0 && pickup.healCap <= 100 )
		{
			if ( !needHeal )
				return eUseHealthKitResult.DENY_HEALTH_FULL
		}
		else if ( pickup.shieldAmount > 0 && pickup.healAmount == 0 )
		{
			if ( !needShield )
				return player.GetShieldHealthMax() > 0 ? eUseHealthKitResult.DENY_SHIELD_FULL : eUseHealthKitResult.DENY_NO_SHIELDS
		}
		else
		{
			if ( pickup.healAmount > 0 && currentHealth < pickup.healCap )
				canHeal = true

			if ( pickup.healAmount > 0 && pickup.healTime > 0 )
				canHeal = true

			if ( pickup.shieldAmount > 0 && needShield )
				canShield = true

			if ( pickup.healAmount > 0 && pickup.healCap > 100 )
			{
				int targetHealth = int( currentHealth + pickup.healAmount )
				int overHeal     = targetHealth - player.GetMaxHealth()
				if ( overHeal > 0 && currentShields < player.GetShieldHealthMax() )
					canShield = true
			}

			if ( !canHeal && !canShield )
			{
				if ( currentHealth == player.GetMaxHealth() && currentShields == player.GetShieldHealthMax() )
					return eUseHealthKitResult.DENY_FULL

				return eUseHealthKitResult.DENY_NO_KITS
			}
		}
	}

	if ( GetCurrentPlaylistVarBool( "survival_healthkits_limit_movement", true ) == false && player.IsSprinting() )
	{
		return eUseHealthKitResult.DENY_SPRINTING
	}

	return eUseHealthKitResult.ALLOW
}
#endif

#if SERVER || CLIENT
float function Survival_GetCharacterSelectDuration( int pickIndex )
{
	float min = CharSelect_GetPickingSingleDurationMin()
	float max = CharSelect_GetPickingSingleDurationMax()
	return GraphCapped( pickIndex, 0, (MAX_TEAM_PLAYERS - 1), max, min )
}
#endif

#if SERVER || CLIENT
bool function Survival_CharacterSelectEnabled()
{
	return Survival_GetCharacterSelectDuration( 0 ) > 0.0
}
#endif

#if SERVER || CLIENT
bool function Sur_CanUseZipline( entity player, entity zipline, vector ziplineClosestPoint )
{
	if ( player.IsGrapplingZipline() )
		return true

	if ( player.GetWeaponDisableFlags() == WEAPON_DISABLE_FLAGS_ALL )
	{
		bool allowZipAttachFromUpdraft = GetCurrentPlaylistVarBool( "updraft_zipline_attach", true )
		bool allowZipAttachDuringDNAPickup = GetCurrentPlaylistVarBool( "DNA_pickup_zipline_attach", true )
	
		bool allowedDuringWeaponDisable = false

		if ( allowZipAttachDuringDNAPickup )
		{
			entity firstPersonProxy = player.GetPredictedFirstPersonProxy()
			string firstPersonAnim = firstPersonProxy.GetCurrentSequenceName()
			bool isPlayingPickupAnimation = firstPersonAnim.find( PICKING_UP_RESPAWN_BANNER_ANIM ) > -1 && IsPlayingFirstPersonAnimation( player )

			if ( isPlayingPickupAnimation )
				allowedDuringWeaponDisable = true
		}

		if ( allowZipAttachFromUpdraft )
		{
			//if ( player.Player_IsSkydiveAnticipating() && player.Skydive_IsFromUpdraft() )
				allowedDuringWeaponDisable = true
		}

		return allowedDuringWeaponDisable
	}

	//if ( IsValid( player.GetActiveWeapon( eActiveInventorySlot.mainHand ) ) && player.GetActiveWeapon( eActiveInventorySlot.mainHand ).IsWeaponOffhand() )
	//	return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	return true
}
#endif

#if SERVER || CLIENT
void function Sur_SetPlaneCenterEnt( entity ent )
{
	file.planeCenterEnt = ent
}
#endif

#if SERVER || CLIENT
void function Sur_SetPlaneEnt( entity ent )
{
	file.planeEnt = ent

	#if SERVER
		foreach( player in GetPlayerArray() )
		{
			player.SetPlayerNetEnt( "planeEnt", ent )
		}
	#endif
}
#endif

                       
          
                                                        
 
                        
 

                                           
 
                      
 

                                                
 
                                                                                                         

                                     
                

                                                               
                                                                                                                                                 
  
                                                              
                                                                                 
                                                   
                                                                                       

                                    
                                                        
                                         
  
                                                   
  
                                                           
                    
  

                                                  
  
                                                
  
 

                                                                    
 
                                    
 

                                                 
 
                            
 

                                                                                              
 
                                                      
 

                                                              
 
                                 
 
               

                                        
 
                              
                                                  
                                              
       

                                                                   
 

                                                 
 
                                                                                  
 

                                                        
 
                                                                                              
 

                                             
 
                                                                                 
 

                                                            
 
                                                                                                 
 

                                           
 
                                                                  
 

                                                 
 
                                                                                  
 

                                                      
 
                                                                                  
 

                                          
 
                                                                          
 

                                                  
 
                                                                                   
 

                                                
 
                     
                                                                                                                                 
       
                                                                                   

 
      

bool function Survival_IsDropshipClampedToRing()
{
                              
                                                  
              
       

	return GetCurrentPlaylistVarBool( "dropship_bounds_clamp_to_ring", false )
}

float function Survival_GetPlaneMoveSpeed()
{
                              
                                                  
                                             
       

	return GetCurrentPlaylistVarFloat( "survival_plane_move_speed", 2000.0 )
}

float function Survival_GetPlaneJumpDelay()
{
	return GetCurrentPlaylistVarFloat( "survival_plane_jump_delay", 9.0 )
}

float function Survival_GetPlaneLeaveMapDurationMultiplier()
{
	return GetCurrentPlaylistVarFloat( "survival_plane_leave_map_duration_multiplier", 3.0 )
}

#if SERVER || CLIENT
entity function Sur_GetPlaneCenterEnt()
{
	return file.planeCenterEnt
}
#endif

#if SERVER || CLIENT
entity function Sur_GetPlaneEnt( int teamNum = -1 )
{
                        
                                                                 
   
                                                     
                                                         
                             
                   
   
       

	return file.planeEnt
}
#endif

#if !UI

#if SERVER
//This should live in sh_fire, but for now we're avoiding DFS
const string SFX_BURN_1P = "flesh_fire_damage_1p"
const string SFX_BURN_3P = "flesh_thermiteburn_1p_vs_3p"
void function Player_OnBurnDamage( entity target, var damageInfo )
{
	if ( !target.IsPlayer() )
		return

	EmitSoundOnEntityOnlyToPlayer( target, target, SFX_BURN_1P )
	EmitSoundOnEntityExceptToPlayer( target, target, SFX_BURN_3P )
}

                  
void function Player_OnCausticToxinDamage( entity target, var damageInfo )
{
	if ( !target.IsPlayer() )
		return

	EmitSoundOnEntityOnlyToPlayer( target, target, "flesh_causticgas_damage_1p" )
	EmitSoundOnEntityExceptToPlayer( target, target, "flesh_causticgas_damage_3p" )
}
                        
#endif

TargetKitHealthAmounts function PredictHealthPackUse( entity player, HealthPickup itemData )
{
	int currentHealth   = player.GetHealth()
	int maxHealth   = player.GetMaxHealth()
	int currentShields  = player.GetShieldHealth()
	int shieldHealthMax = player.GetShieldHealthMax()

	int resourceHealthRemaining = 0
	int virtualHealth           = minint( currentHealth + resourceHealthRemaining, maxHealth )
	int missingHealth           = maxHealth - virtualHealth
	int missingShields          = shieldHealthMax - currentShields

	TargetKitHealthAmounts targetValues

	if ( itemData.healAmount > 0 )
	{
		int healthToApply = minint( int( itemData.healAmount ), missingHealth )
		Assert( virtualHealth + healthToApply <= 100, "Bad math: " + virtualHealth + " + " + healthToApply + " > 100 " )

		int remainingHealth = int( itemData.healAmount - healthToApply )

		int shieldsToApply = 0
		if ( itemData.healCap > maxHealth && remainingHealth > 0 )
		{
			shieldsToApply = minint( remainingHealth, missingShields )
		}

		Assert( currentShields + shieldsToApply <= shieldHealthMax, "Bad math: " + currentShields + " + " + shieldsToApply + " > " + shieldHealthMax )

		if ( healthToApply != 0 || itemData.healTime > 0 ) // healTime items can exceed the cap
			targetValues.targetHealth = (healthToApply + resourceHealthRemaining) / float( maxHealth )

		if ( shieldsToApply != 0 && shieldHealthMax > 0 )
			targetValues.targetShields = shieldsToApply / float( shieldHealthMax )
	}

	if ( itemData.shieldAmount > 0 && shieldHealthMax > 0 )
		targetValues.targetShields = itemData.shieldAmount / float( shieldHealthMax )

	return targetValues
}


#endif
#if SERVER || CLIENT
bool function CanWeaponInspect( entity player, int activity )
{
	if ( Bleedout_IsBleedingOut( player ) )
		return false

	return GetCurrentPlaylistVarBool( "enable_weapon_inspect", true )
}
#endif


#if SERVER
int function Survival_GetCurrentRank( entity player )
{
                  
                                                                            
                                              
       

	                      
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
			return WinterExpress_GetCurrentRank( player )
       

	                        
		if ( GameMode_IsActive( eGameModes.CONTROL ) )
			return Control_GetCurrentRank( player )
       

                           
                                                                         
                                            
       

	                       
		if( GameMode_IsActive( eGameModes.FREEDM ) )
			return FreeDM_GetCurrentRank( player )
       

	                            
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
			return ShadowArmy_GetCurrentRank( player )
                                   

	int team                  = player.GetTeam()
	int numLivingSquadMembers = GetPlayerArrayOfTeam_AliveConnected( team ).len()
	if ( numLivingSquadMembers <= 0 )
	{
		#if SERVER
			return _GetSquadRank( EHIToEncodedEHandle( player ) )
		#else
			return player.GetPersistentVarAsInt( "lastGameRank" )
		#endif
	}
	return GetNumTeamsRemaining()
}


int function Survival_GetFinalRank( int teamIndex )
{
	int bestRank = GetCurrentPlaylistVarInt( "max_teams", 20 )

	table< int, GameSummarySquadData > ornull squadDataMap = GameSummary_GetTeamDataOrNull( teamIndex )
	if ( squadDataMap == null )
		return bestRank

	expect table<int, GameSummarySquadData>( squadDataMap )

	foreach ( teamMemberIndex, squadMemberData in squadDataMap )
	{
		bestRank = minint( _GetSquadRank( squadMemberData.eHandle ), bestRank )
	}

	return bestRank
}
#endif // SERVER


#if SERVER
                  
                                           
 
                          
 
      

#if DEVELOPER
void function DEV_OverridePodiumBackground( int i )
{
	array< entity > podiumBackground = GetEntArrayByScriptName( "podium_bg_skin_swap" )
	if ( podiumBackground.len() == 1 )
	{
		podiumBackground[0].SetSkin( i )
	}
}

void function DEV_OverridePodiumBanners( int i )
{
	array< entity > podiumBanners = GetEntArrayByScriptName( "podium_banner_skin_swap" )
	foreach ( podiumBanner in podiumBanners )
	{
		podiumBanner.SetSkin( i )
	}
}

void function DEV_OverridePodiumBase( int i )
{
	array< entity > podiumBase = GetEntArrayByScriptName( "podium_base_skin_swap" )
	if ( podiumBase.len() == 1 )
	{
		podiumBase[0].SetSkin( i )
	}
}

void function DEV_TeleportToPodium( entity player )
{
	if ( !IsValid ( player ) )
		return


	array< entity > podiumBase = GetEntArrayByScriptName( "podium_base_skin_swap" )
	if ( podiumBase.len() == 1 )
	{
		player.SetOrigin( podiumBase[0].GetOrigin() )
	}
}
#endif

void function Podium_OnResolution()
{

                            
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
	{
		SetupPodiumForShadowArmy()
		return
	}
      

	thread PodiumFXThread(  )
}

                            
void function SetupPodiumForShadowArmy()
{
	int gameResultFlag = Survival_GetGameResultFlags()
	bool legendsWon =  ( gameResultFlag == SHADOWARMY_VICTORY_FLAGS_EVAC )

	array< entity > podiumBanners = GetEntArrayByScriptName( "podium_banner_skin_swap" )
	foreach ( podiumBanner in podiumBanners )
	{
		podiumBanner.SetSkin( legendsWon ? ePodiumBanner.SR_LEGENDS : ePodiumBanner.SR_REV )
	}

	array< entity > podiumBase = GetEntArrayByScriptName( "podium_base_skin_swap" )
	if ( podiumBase.len() == 1 )
	{
		podiumBase[0].SetSkin( legendsWon ? ePodiumBanner.SR_LEGENDS : ePodiumBanner.SR_REV  )
	}

	array< entity > podiumBackground = GetEntArrayByScriptName( "podium_bg_skin_swap" )
	if ( podiumBackground.len() == 1 )
	{
		int podiumBackgroundSkin = GetPodiumBackgroundSkinFromMapName()
		podiumBackground[0].SetSkin( legendsWon ? ePodiumBackground.SR_LEGENDS : ePodiumBackground.SR_REV  )
	}
}
      


void function PodiumFXThread( )
{
	//	SEQUENTIAL SPARKS AND FLAMES LEFT TO RIGHT

	#if SERVER && DEVELOPER
		if( file.podiumFXSeqInProgress )
			return

		file.podiumFXSeqInProgress = true

		OnThreadEnd(
			function() : ()
			{
				file.podiumFXSeqInProgress = false
			}
		)
	#endif
	#if SERVER
		string entityToCheck = "podium_bg_skin_swap"
	#elseif CLIENT
		string entityToCheck = "podium_info_target"
	#endif

	array< entity > podiumInfoTargets = GetEntArrayByScriptName(entityToCheck )
	if( podiumInfoTargets.len() == 0 )
		return

	EmitSoundAtPosition( TEAM_ANY, <0, 0, 10000>,  "Podium_Pyro_FlameBurst_Sequence", podiumInfoTargets[0] )

	// 	FLAMES ONLY
	
	wait 1
	FlagSet(PODIUM_FX_FIREBALL_L1)
	FlagSet(PODIUM_FX_FIREBALL_R1)

	wait .1
	FlagSet(PODIUM_FX_FIREBALL_L2)
	FlagSet(PODIUM_FX_FIREBALL_R2)

	wait .25
	FlagClear(PODIUM_FX_FIREBALL_L1)
	FlagClear(PODIUM_FX_FIREBALL_R1)

	wait .1
	FlagClear(PODIUM_FX_FIREBALL_L2)
	FlagClear(PODIUM_FX_FIREBALL_R2)

	wait .25
	FlagSet(PODIUM_FX_FIREBALL_L1)
	FlagSet(PODIUM_FX_FIREBALL_R1)

	wait .1
	FlagSet(PODIUM_FX_FIREBALL_L2)
	FlagSet(PODIUM_FX_FIREBALL_R2)

	wait .25
	FlagClear(PODIUM_FX_FIREBALL_L1)
	FlagClear(PODIUM_FX_FIREBALL_R1)

	wait .1
	FlagClear(PODIUM_FX_FIREBALL_L2)
	FlagClear(PODIUM_FX_FIREBALL_R2)

	wait .5
	FlagSet(PODIUM_FX_FIREBALL_L1)
	wait .015
	FlagSet(PODIUM_FX_FIREBALL_R1)
	wait .015
	FlagSet(PODIUM_FX_FIREBALL_L2)
	wait .015
	FlagSet(PODIUM_FX_FIREBALL_R2)

	wait 1
	FlagClear(PODIUM_FX_FIREBALL_L1)
	FlagClear(PODIUM_FX_FIREBALL_R1)
	FlagClear(PODIUM_FX_FIREBALL_L2)
	FlagClear(PODIUM_FX_FIREBALL_R2)
}

void function SetupVictoryPodium()
{
	int podiumSkin = GetPodiumBannerSkinFromGameMode()

	array< entity > podiumBanners = GetEntArrayByScriptName( "podium_banner_skin_swap" )
	foreach ( podiumBanner in podiumBanners )
	{
		podiumBanner.SetSkin( podiumSkin )
		podiumBanner.SetModelScale( 0.5 )
	}

	array< entity > podiumBase = GetEntArrayByScriptName( "podium_base_skin_swap" )
	if ( podiumBase.len() == 1 )
	{
		podiumBase[0].SetSkin( podiumSkin )
	}

	array< entity > podiumBackground = GetEntArrayByScriptName( "podium_bg_skin_swap" )
	if ( podiumBackground.len() == 1 )
	{
		int podiumBackgroundSkin = GetPodiumBackgroundSkinFromMapName()
		podiumBackground[0].SetSkin( podiumBackgroundSkin )
	}
}

int function GetPodiumBannerSkinFromGameMode()
{
	if ( UseLTMPodiumBanner() )
	{
		return ePodiumBanner.LTM
	}

	if ( IsCurrentModeMixtape() )
	{
		return ePodiumBanner.MIXTAPE
	}

	return ePodiumBanner.NORMAL
}

int function GetPodiumBackgroundSkinFromMapName()
{
	switch ( GetMapName() )
	{
		case "mp_rr_desertlands_hu" :
			return ePodiumBackground.MP_RR_DESERTLANDS_HU
			break
		case "mp_rr_divided_moon_mu1" :
			return ePodiumBackground.MP_RR_DIVIDED_MOON
			break
		case "mp_rr_canyonlands_hu":
			return ePodiumBackground.MP_RR_CANYONLANDS_HU
			break
		case "mp_rr_olympus_mu2":
			return ePodiumBackground.MP_RR_OLYMPUS_MU2
			break
		case "mp_rr_tropic_island_mu1":
                 
                                       
      
			return ePodiumBackground.MP_RR_TROPICS_ISLAND_MU1
			break
		case "mp_rr_aqueduct":
			return ePodiumBackground.MP_RR_ADQUEDUCT
			break
		case "mp_rr_arena_habitat" :
			return ePodiumBackground.MP_RR_ARENA_HABITAT
			break
		case "mp_rr_party_crasher" :
			return ePodiumBackground.MP_RR_PARTY_CRASHER
			break
		case "mp_rr_arena_phase_runner":
			return ePodiumBackground.MP_RR_ARENA_PHASE_RUNNER
			break
		case "mp_rr_freedm_skulltown":
			return ePodiumBackground.MP_RR_FREEDM_SKULLTOWN
			break
		case "mp_rr_arena_skygarden":
			return ePodiumBackground.MP_RR_ARENA_SKYGARDER
			break
		case "mp_rr_desertlands_night":
			return ePodiumBackground.MP_RR_DESERTLANDS_NIGHT
			break
		case "mp_rr_canyonlands_mu1_night" :
			return ePodiumBackground.MP_RR_CANYONLANDS_MU1_NIGHT
			break
		case "mp_rr_olympus_mu1_night":
			return ePodiumBackground.MP_RR_OLYMPUS_MU1_NIGHT
			break
		case "mp_rr_tropic_island_mu2":
			return ePodiumBackground.MP_RR_TROPICS_ISLAND_MU2
			break
		case "mp_rr_thunderdome":
			return ePodiumBackground.MP_RR_THUNDERDOME
			break
		default:
			printt("[GetPodiumBackgroundSkinFromMapName] map:" + GetMapName() + " not setup in GetPodiumBackgroundSkinFromMapName and will use default background")
			break
	}

	return 0

}
#endif

#if SERVER || CLIENT
void function SetVictorySequencePlatformModel( asset model, vector originOffset, vector modelAngles )
{
	VictoryPlatformModelData data
	data.isSet = true // DEPRECATE
	data.modelAsset = model
	data.originOffset = originOffset
	data.modelAngles = modelAngles
	file.victorySequencePlatforData = data

	PrecacheModel( model )
}

VictoryPlatformModelData function GetVictorySequencePlatformModel()
{
	return file.victorySequencePlatforData
}

string function GetMusicForJump( entity player )
{
	string override = GetCurrentPlaylistVarString( "music_override_skydive", "" )

	                            
		// Uses different music tracks depending on which Alliance players are in so I can't use the playlist override
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
		{
			int playerAlliance = AllianceProximity_GetAllianceFromTeam( player.GetTeam() )
			if ( playerAlliance == SHADOWARMY_LEGEND_ALLIANCE )
				override = "Music_RevArmy_Jump_Legends"
			else
				override = "Music_RevArmy_Jump_Revenants"
		}
                                   

	if ( override.len() > 0 )
		return override
	return MusicPack_GetSkydiveMusic( GetMusicPackForPlayer( player ) )
}

bool function PositionIsInMapBounds( vector pos )
{
	return VectorWithinBounds( pos, MAX_MAP_BOUNDS )
}

bool function Survival_IsPlayerHealing( entity player )
{
	return player.GetPlayerNetBool( "isHealing" )
}

bool function PlayerIsMarkedAsCanBeRespawned( entity player )
{
	int respawnStatus = player.GetPlayerNetInt( "respawnStatus" )
	switch ( respawnStatus )
	{
		case eRespawnStatus.WAITING_FOR_DELIVERY:
		case eRespawnStatus.WAITING_FOR_PICKUP:
		case eRespawnStatus.WAITING_FOR_RESPAWN:
			return true
	}

	return false
}

#endif // SERVER || CLIENT

bool function IsSquadDataPersistenceEmpty( entity player )
{
	int maxTrackedSquadMembers = PersistenceGetArrayCount( "lastGameSquadStats" )
	for ( int i = 0 ; i < maxTrackedSquadMembers ; i++ )
	{
		int eHandle = player.GetPersistentVarAsInt( "lastGameSquadStats[" + i + "].eHandle" )

		// If we have any data at all it's not empty
		if ( eHandle > 0 )
			return false
	}
	return true
}

#if SERVER || CLIENT
bool function Survival_RequireJumpmasterInPlane()
{
                      
                                       
               
       
	                         
		if ( ForcedSpawn_UseForcedSpawning() )
			return false
       
	return true
}
#endif // SERVER || CLIENT

#if SERVER
void function Survival_OnGameplayStarted()
{
                       
                                                                    
                                                            
      
}
#endif // SERVER