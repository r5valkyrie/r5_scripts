

global function Crafting_Init
global function Crafting_RegisterNetworking
global function Crafting_IsEnabled
global function Crafting_IsDispenserCraftingEnabled
global function Crafting_DispenserFreeSupportBanner
global function Crafting_DispenserSupportMRB
global function Dispensers_GetReplicatorStateForPlayer
global function Crafting_Access_Inventory_Enabled
global function Crafting_GetPlayerCraftingMaterials
global function Crafting_GetLootDataFromIndex
global function Crafting_GetCraftingDataArray
global function Crafting_IsItemCurrentlyOwnedByAnyPlayer
global function Crafting_DoesPlayerOwnItem

global function Crafting_IsPingMapIconEnabled

#if SERVER
global function Crafting_GetDisabledGroundLoot
global function Crafting_GetDisabledPoolLoot
global function Crafting_IsLootRemovedFromGround
global function Crafting_IsLootRemovedFromPool
global function Crafting_AddExclusiveLoot
global function Crafting_GetPreviousAirdropLocations

global function Crafting_GetCraftingItemsByCategoryName

global function AirdropWorkbench_Thread
global function Crafting_GetAllWorkbenchClusters
global function Crafting_WorkbenchAirdropLogicForRound_Thread
global function Crafting_GetAllHarvesters

global function Crafting_ClearUseLinksForAllHarvesters

global function Crafting_OnNPCKill
global function Crafting_RewardOnWildlifeCampComplete

global function Crafting_AddMaterialsToPlayer
global function AddCallback_OnCraftingMaterialsGranted

global function Crafting_RemoveMaterialsFromPlayer
global function Crafting_GetUseStatusForWorkbench
global function Crafting_OnPlayerConnectionChanged
global function Crafting_AirdropWorkbenchAtPlayer
global function Crafting_CloseCraftingMenu

global function ClientCallback_InitializeCraftingAtWorkbench
global function ClientCallback_ClosedCraftingMenu


global function Crafting_PingNearestWorkbench


global function Dispensers_PingNearestDispenser

global function ClientCallback_Crafting_Notify_Teammates_On_Obit

#if DEVELOPER
global function Crafting_ShowCraftingLocations
global function RemoveLimitedStockFromWorkbenchAtIndex
global function DEV_PlayerUseRandomHarvester
global function DEV_PrintDisabledGroundLoot
global function DEV_PrintDisabledPoolLoot
#endif // DEVELOPER

global function Crafting_IsPlayerAtWorkbench
global function Crafting_CreateHolderEnt





global function Crafting_DoorCloseCheck

global function Crafting_ClientToServer_PingCrafterFromMap

global function Crafting_PossibleWorkbenchLocations_Get
global function Crafting_SetCrafterGoalCount
#endif // SERVER

#if DEVELOPER
#if SERVER
global function DEV_PrintUsedHarvesters
#endif
global function DEV_Crafting_PrintsOn
#endif

#if CLIENT
global function UICallback_PopulateCraftingPanel
global function Crafting_Workbench_OpenCraftingMenu
global function Crafting_PopulateItemRuiAtIndex
global function ServerCallback_CL_MaterialsChanged
global function ServerCallback_CL_HarvesterUsed
global function ServerCallback_CL_ArmorDeposited
global function ServerCallback_PromptNextHarvester
global function ServerCallback_PromptWorkbench
global function ServerCallback_PromptAllWorkbenches
global function ServerCallback_UpdateWorkbenchVars

global function ServerCallback_Crafting_Notify_Player_On_Obit

global function ServertoClientCallback_SetDispenserData
global function Crafting_IsPlayerCrafting

global function Crafting_OnMenuItemSelected
global function Crafting_OnWorkbenchMenuClosed
global function TryCloseCraftingMenuFromDamage
global function TryCloseCraftingMenu
global function ServerCallback_SetCraftingIndexForSpectator

global function MarkNextStepForPlayer
global function MarkAllWorkbenches
global function DestroyWorkbenchMarkers
global function HarvesterAnimThread

global function Crafting_ShowCraftingMapFeature

global function Crafting_GetWorkbenchTitleString
global function Crafting_GetWorkbenchDescString

global function Crafting_IsPlayerAtWorkbench

global function Crafting_GetCraftingIcon
global function Crafting_GetSmallCraftingIcon
global function Crafting_GetCraftingZoneIcon

#if DEVELOPER
global function DEV_Crafting_TogglePreMatchRotation
global function DEV_Crafting_PrintUsedHarvesterEHIs
#endif // DEVELOPER
#endif // CLIENT












//data
const asset CRAFTING_DATATABLE = $"datatable/crafting_workbench.rpak"
const asset CRAFTING_CATEGORIES_DATATABLE = $"datatable/crafting_bundles.rpak"
const string CRAFTING_NULL_CHECK = "null"

const asset CRAFTING_DISPENSERS_DATATABLE = $"datatable/crafting_dispenser_workbench.rpak"
const asset CRAFTING_DISPENSERS_CATEGORIES_DATATABLE = $"datatable/crafting_dispenser_bundles.rpak"

//initialization scriptnames
global const string HARVESTER_SCRIPTNAME = "crafting_harvester"
global const string WORKBENCH_CLUSTER_SCRIPTNAME = "crafting_workbench_cluster"
global const string WORKBENCH_SCRIPTNAME = "crafting_workbench"
global const string WORKBENCH_CLUSTER_AIRDROPPED_SCRIPTNAME = "crafting_workbench_cluster_airdropped"
const string WORKBENCH_RANDOMIZATION_TARGET_SCRIPTNAME = "crafting_workbench_randomization"

//harvester assets
const float HARVESTER_USE_DURATION = 0.5
const asset HARVESTER_MODEL = $"mdl/props/crafting_siphon/crafting_siphon.rmdl"
const string HARVESTER_FULL_IDLE_ANIM = "source_full_idle"
const string HARVESTER_EMPTY_IDLE_ANIM = "source_empty_idle"
const string HARVESTER_FULL_TO_EMPTY_ANIM = "source_full_to_empty"
const string HARVESTER_MINIMAP_SCRIPTNAME = "crafting_harvester_minimap"

const asset HARVESTER_IDLE_FX = $"P_siphon_idle"

//workbench assets
const asset WORKBENCH_CLUSTER_AIRDROP_MODEL = $"mdl/props/crafting_replicator/crafting_replicator.rmdl"
const asset WORKBENCH_CLUSTER_MODEL = $"mdl/props/crafting_replicator/crafting_replicator_no_engine.rmdl"
const asset WORKBENCH_MODEL = $"mdl/dev/empty_model.rmdl"
const float WORKBENCH_USE_DURATION = 1.0
const float WORKBENCH_CRAFTING_DURATION = 10.0
const float WORKBENCH_LIMITED_STOCK_USE_DEFAULT = 3
const string WORKBENCH_IDLE_ANIM = "crafting_replicator_ready_idle"
const string WORKBENCH_IDLE_GROUND_ANIM = "crafting_replicator_ready_groundidle"

const float WORKBENCH_CRAFTING_DURATION_NEW = 0
const asset WORKBENCH_DISPENSER_HOLO_COLOR_FX = $"P_workbench_s20"
const asset WORKBENCH_DISPENSER_START_FX = $"P_workbench_s20_start"
const asset WORKBENCH_DISPENSER_BEAM_FX = $"P_workbench_s20_stock_beam_LT"
const vector WORKBENCH_DISPENSER_VFX_COLOR = < 183, 135, 255 >

const asset WORKBENCH_HOLO_FX = $"P_workbench_holo"



const asset WORKBENCH_START_FX = $"P_workbench_start"
const asset WORKBENCH_BEAM_FX = $"P_workbench_stock_beam_LT"
const asset WORKBENCH_ENGINE_SMOKE_FX = $"P_lootpod_vent_top"
const asset WORKBENCH_DOOR_OPEN_FX = $"P_lootpod_door_open"
const asset WORKBENCH_PRINTING_FX = $"P_replipod_printing_CP"

//workbench consts
const float WORKBENCH_CLOSEDOOR_DURATION = 0.8

//Crafting PIN: If the category is in this array, the PIN will post the actual item name as the item_id.
const array<string> CRAFTED_ITEM_CATEGORIES_FOR_ITEM_NAMES = [ "weapon_one", "weapon_two" ]

//rewards
const int CRAFTING_PASSIVE_REWARD = 5
const int HARVESTER_SUCCESS_REWARD = 25
const int HARVESTER_TEAMMATE_REWARD = 25

//minimap assets
const asset WORKBENCH_ICON_ASSET = $"rui/hud/gametype_icons/survival/crafting_workbench"
const asset WORKBENCH_ICON_LIMITED_ASSET = $"rui/hud/gametype_icons/survival/crafting_workbench_limited"
const asset WORKBENCH_ICON_AIRDROP_ASSET = $"rui/hud/gametype_icons/survival/crafting_workbench_airdrop"

const asset DISPENSER_WORKBENCH_ICON_ASSET = $"rui/hud/gametype_icons/survival/crafting_workbench_2"
const asset DISPENSER_WORKBENCH_ICON_AIRDROP_ASSET = $"rui/hud/gametype_icons/survival/crafting_workbench_airdrop_2"
const asset DISPENSER_CRAFTING_SMALL_WORKBENCH_ASSET = $"rui/hud/ping/icon_ping_crafting_2_hexagon"
global const asset CRAFTING_2_ZONE_ASSET = $"rui/hud/gametype_icons/survival/crafting_2_zone"

const asset HARVESTER_ICON_ASSET = $"rui/hud/gametype_icons/survival/crafting_harvester"
const asset CRAFTING_SMALL_HARVESTER_ASSET = $"rui/hud/gametype_icons/survival/crafting_small_harvester"
const asset CRAFTING_SMALL_WORKBENCH_ASSET = $"rui/hud/ping/icon_ping_crafting_hexagon"
global const asset CRAFTING_ZONE_ASSET = $"rui/hud/gametype_icons/survival/crafting_zone"
const asset CRAFTING_CURRENCY_ASSET = $"rui/hud/gametype_icons/survival/crafting_currency"

//audio assets
const string HARVESTER_AMBIENT_LOOP = "Crafting_Extractor_AmbientLoop"
const string WORKBENCH_AMBIENT_LOOP = "Crafting_V2_0_Replicator_AmbientLoop"
const string HARVESTER_COLLECT_1P = "Crafting_Extractor_Collect_1P"
const string HARVESTER_COLLECT_3P = "Crafting_Extractor_Collect_3P"
const string HARVESTER_COLLECT_TEAM = "UI_InGame_Crafting_Extractor_Collect_Squad"
const string WORKBENCH_MENU_OPEN_START = "Crafting_ReplicateMenu_OpenStart"
const string WORKBENCH_MENU_OPEN_FAIL = "Crafting_ReplicateMenu_OpenFail"
const string WORKBENCH_MENU_OPEN_SUCCESS = "Crafting_ReplicateMenu_OpenSuccess"
const string WORKBENCH_CRAFTING_START_1P = "Crafting_V2_0_Replicator_Crafting_Start_1P"
const string WORKBENCH_CRAFTING_START_3P = "Crafting_V2_0_Replicator_Crafting_Start_3P"
const string WORKBENCH_CRAFTING_FINISH = "Crafting_Replicator_CraftingFinish"
const string WORKBENCH_CRAFTING_FINISH_WARNING = "Crafting_Replicater_WarningToEnd"
const string WORKBENCH_CRAFTING_LOOP = "Crafting_Replicator_CraftingLoop"
const string WORKBENCH_CRAFTING_DOOR_OPEN = "Crafting_V2_0_Replicator_Crafting_Finish_Eject"
const string WORKBENCH_CRAFTING_DOOR_CLOSE = "Crafting_V2_0_Replicator_Crafting_Close"

//rui tracking
const int RUI_TRACK_INDEX_CAPTURE_END_TIME = 0 //gametime
const int RUI_TRACK_INDEX_REQUIRED_TIME = 1 //float
const int RUI_TRACK_INDEX_ACTIVATOR_TEAM = 4 //int
const int RUI_TRACK_INDEX_COLOR = 0 //float3

//item creation consts
const float CRAFTING_PICKUP_GRACE_PERIOD = 5.0
global const string HOLDER_ENT_NAME = "holder_ent"

//Evo Amount
global const int CRAFTING_EVO_GRANT = 200
const int MAX_ARMOR_EVO_TIER = 5

//Ammo Amount Multipler
global const int CRAFTING_AMMO_MULTIPLIER = 3
global const int CRAFTING_AMMO_MULTIPLIER_SMALL = 2

global const int DISPENSERS_CRAFTING_AMMO_MULTIPLIER = 6
global const int DISPENSERS_CRAFTING_AMMO_MULTIPLIER_SMALL = 4


//Exiting Crafter Safe Spot Checks
const float IDEAL_END_FLAT_LENGTH = 27
const vector IDEAL_END_TRACE_OFFSET_START = <0, 0, 72>
const vector IDEAL_END_TRACE_OFFSET_END = <0, 0, -32>

//Crafting Obituary
global const float CRAFTING_OBIT_DEBOUNCE_PERIOD = 1.0

//Ping from Map func name
const string FUNCNAME_PingCrafterFromMap = "Crafting_ClientToServer_PingCrafterFromMap"





//Airdrops
const float REPLICATOR_AIRDROP_DISPLACEMENT = 3000.0

global enum eHarvesterState
{
	EMPTY,
	FULL,
	CLOSED,
	COUNT_
}

global enum eCraftingExclusivityStyle
{
	RARITY,
	FLOOR,
	NONE,
	COUNT_
}

global enum eCraftingRotationStyle
{
	DAILY,
	WEEKLY,
	HOURLY,
	PERMANENT,
	LOADOUT_BASED,
	SEASONAL,

		PERK,

	/*%if HAS_SHELVED_LEGEND_ABILITIES
	CALIBER_PASSIVE,
	%endif*/
	COUNT_
}

global enum eCraftingRandomization
{
	NO_DISTRIBUTION, //no randomization, all entities present
	RANDOM_HARVESTER_DISTRIBUTION, //active harvesters are randomized
	RANDOM_CLUSTER_DISTRIBUTION, //active workbench clusters are randomized
	RANDOM_CLUSTER_LINKED_DISTRIBUTION, //active workbench clusters and their linked harvesters are randomized
	RANDOM_COMBINATION_DISTRIBUTION, //workbenches and harvesters are independently randomized
	COUNT_
}

enum eCrafting_Obit_NotifyType
{
	IS_CRAFTING_ITEM,
	SUBSEQUENT_ITEM,
	IS_REQUESTING_MATERIALS,
	COUNT_
}

global enum eCrafting_Dispenser_StateType
{
	DEFAULT,
	NO_ONE_HAS_USED,
	ALL_USED,
	PLAYER_HAS_USED,
	TEAMMATE_HAS_USED,
	COUNT_
}

global struct CraftingBundle
{
	array< string > 			itemsInBundle

	#if CLIENT
		table<int, var> attachedRui
	#endif
}

global struct CraftingCategory
{
	int index
	string category
	int rotationStyle
	int exclusivityStyle
	int numSlots

	table< string, CraftingBundle > bundlesInCategory
	array< string > bundleStrings

	table< string, int > itemToCostTable
}

struct WorkbenchData
{
	entity workbench
	string lootAttachmentIndex
	string doorAnimIndex
	bool isDoorOpen = false
	array<entity> spawnedLoot

#if SERVER
	vector userSafeSpot
#endif

	entity cluster
	bool isCrafting = false
	table<entity, bool> playersHaveUsed
}

struct CraftingItemInfo
{
	int index
	var rui
	int cost
	bool canBuy
	bool canAfford
}











#if SERVER
global typedef OnCraftingMaterialsGrantedCallback void functionref( entity, entity, int )
#endif

struct {
	bool                           isEnabled = false
	bool						   isNetworkingRegistered = false

	table<string, CraftingCategory > craftingData
	array<CraftingCategory> craftingDataArray

	array<string> disabledGroundLoot
	array<string> disabledPoolLoot
	entity		  limitedStockParent
	int 		  timeAtMatchStart

	#if CLIENT
	table<entity, entity>	   	   harvesterToClientProxy
	table<entity, var>             harvesterRuiTable
	table<entity, var>			   workbenchRuiTable
	array<var>					   gameStartRui
	bool						   gameStartRuiCreated
	array<var>					   fullmapRui
	bool						   fullmapInitialized = false
	array<var> 					   exclusivityNotification

	table<entity, var>			   harvesterMinimapRuiTable
	table<entity, var>			   harvesterFullmapRuiTable

	table<entity, var>			   dispenserMapRuiTable
	table<entity, var>			   dispenserMinimapRuiTable

	array<int>					   workbenchMarkerList
	array<var>				   	   workbenchMarkerRuiList

	array<int>				       nextStepMarkerList
	array<var>					   nextStepMarkerRuiList

	array< table<var, var> >	   nearbyLiveWorkbenchRui

	array< CraftingItemInfo >	   craftingItems_ClientList

	// Added so we can restore a used harvester's state locally at create time.
	table< EHI, array< EHI > >		usedHarvesterEHIs

	//To help with locally refreshing the client's local fake harvesters
	table< EHI, entity >			harvesterTableLocal

	// For Referencing back to if players used a Dispenser already
	table<entity, WorkbenchData>	workbenchDataTable_Client
	bool							playerIsCrafting = false

	#if DEVELOPER
	bool 							DEV_testingRotationRui
	#endif
	#endif

	#if SERVER
		array< Point > 							workbenchPossibleLocations // Locations of the placed workbench locations. Useful in many other applications.
		array<entity>                  			harvesterArray
		array<entity>				   			workbenchArray
		array<vector>				   			workbenchAirdropPositions
		table<entity, WorkbenchData>   			workbenchDataTable
		table<entity, array<WorkbenchData> > 	workbenchClusterToBenchData
		table<entity, entity>		   			minimapObjTable
		table<entity, entity>		   			limitedStockFXTable
		array<OnCraftingMaterialsGrantedCallback> craftingMatsGrantedCallbacks

		table< entity, entity >			playerToNextStepTable
		int								matchStartTime

		float							craftingPickupGracePeriod

		table< EHI, float > notifyingPlayerObitTimes

		array<entity>					playersInCraftingIdle

		int defaultCrafterGoalCount = 12


	table<int, int>					npcCraftingRewardTable

	#endif

	table<entity, entity>		   ambGenericTable
	array<entity>				   workbenchClusterArray

	bool harvestersTeamUse = true

	bool craftingBetterSpectatorEnabled = false

	bool crafting_obit_notify = true

	#if DEVELOPER
		bool devPrintsOn = false
	#endif
} file

void function Crafting_Init()
{
	FlagInit( "CraftingInitialized" )

	RegisterCraftingData()
	RegisterCraftingDistribution()

	// If TRUE, all teammates will get materials if any teammate interacts with a Harvester.
	file.harvestersTeamUse 	= GetCurrentPlaylistVarBool( "harvesters_teamuse", true )

	file.craftingBetterSpectatorEnabled	= GetCurrentPlaylistVarBool( "crafting_use_better_specating", true )

	file.crafting_obit_notify = GetCurrentPlaylistVarBool( "crafting_obit_notify", true )

	#if SERVER
		file.matchStartTime = GetUnixTimestamp()
		HandleCraftingExclusivity()

		file.craftingPickupGracePeriod = GetCurrentPlaylistVarFloat( "crafting_pickup_grace_period", CRAFTING_PICKUP_GRACE_PERIOD )


		file.npcCraftingRewardTable = {}
		file.npcCraftingRewardTable[eNPC.PROWLER] <- GetCurrentPlaylistVarInt( "wildlife_ai_prowler_crafting_reward", 0 )




			file.npcCraftingRewardTable[eNPC.SPIDER_JUNGLE] <- GetCurrentPlaylistVarInt( "wildlife_ai_spider_jungle_crafting_reward", 0 )


	#endif

	#if CLIENT
		if ( IsLobby() )
		{
			file.isEnabled = Crafting_PlaylistVar_IsEnabled()
			return
		}
	#endif

	#if SERVER
		AddSpawnCallbackEditorClass( "prop_dynamic", "script_survival_crafting_harvester", OnHarvesterScriptTargetSpawned )
		AddSpawnCallbackEditorClass( "prop_dynamic", "script_survival_crafting_workbench_cluster", OnWorkbenchScriptTargetSpawned )
	#endif

	#if SERVER
		AddSpawnCallback( "prop_dynamic", SetupWorkbenchClusterFromTarget )
	#endif
	#if CLIENT
		AddCreateCallback( "prop_material_harvester", OnHarvesterCreated )
		AddDestroyCallback( "prop_material_harvester", OnHarvesterDestroyed )
		AddCreateCallback( "prop_dynamic", OnWorkbenchClusterCreated )
		AddCreateCallback( "info_target", OnLimitedStockParentCreated )
	#endif

	RegisterSignal( "Crafting_PlayerStartedPlaying" )
	RegisterSignal( "CraftingPlayerAttaching" )
	RegisterSignal( "CraftingComplete" )
	RegisterSignal( "CraftingPlayerDetached" )
	RegisterSignal( "OnPinged_Crafting" )
	RegisterSignal( "CraftingPlayerPlayExitAnim" )
	RegisterSignal( "CraftingPlayerDetachImmediate" )
	RegisterSignal( "CraftingDestroyReferencePlacement" )
	if ( file.craftingBetterSpectatorEnabled )
	{
		RegisterSignal( "crafting_kill_spectator_thread" )
	}

	#if CLIENT
		RegisterSignal ( "OnPlayerUsedDispenser" )
		RegisterSignal ( "OnNewHoloStartPlaying" )
	#endif







	if ( !Crafting_PlaylistVar_IsEnabled() )
		return

	printf( "CRAFTING: Crafting Systems enabled" )
	file.isEnabled = true

	#if SERVER
		AddCallback_GameStateEnter( eGameState.Playing, Crafting_OnGameStatePlaying )
		//AddCallback_OnClientConnectionLost( Crafting_OnPlayerConnectionChanged ) //not in S3
		//AddCallback_OnClientConnectionRestored( Crafting_OnPlayerConnectionChanged ) //not in S3
		AddCallback_EntitiesDidLoad( Crafting_OnEntitiesDidLoad )
		//AddCallback_OnQuickchatEvent( eCommsAction.REPLY_CRAFTING_NEXT_HARVESTER_OR_WORKBENCH, PingNextGoalForPlayer ) //S22 comms action
		//AddCallback_OnQuickchatEvent( eCommsAction.REPLY_CRAFTING_PING_ALL_WORKBENCHES, PingAllWorkbenches ) //S22 comms action
		AddCallback_OnLootBinOpening( Crafting_OnLootbinOpen )
		AddPingCallbackForType( ePingType.LOOT, OnLootPinged )

		Loot_AddCallback_OnPlayerLootPickup( Crafting_OnLootPickedUp )
		AddCallback_OnPlayerKilled( Crafting_OnPlayerKilled )
		Bleedout_AddCallback_OnPlayerStartBleedout( Crafting_OnPlayerBleedingOut )
		AddCallback_OnPlayerMatchStateChanged( Crafting_OnPlayerMatchStateChanged ) //signature mismatch

		AddCallback_OnPlayerRespawned( Dispensers_OnPlayerStateChanged )
		//AddCallback_OnClientConnectionLost( Dispensers_OnPlayerStateChanged ) //not in S3
		//AddCallback_OnClientConnectionRestored( Dispensers_OnPlayerStateChanged ) //not in S3
		AddCallback_OnSurvivalDeathFieldStageChanged( Callback_Dispensers_RefreshState )

	#endif
	#if CLIENT
		AddCallback_GameStateEnter( eGameState.WaitingForPlayers, OnWaitingForPlayers_Client )
		AddCallback_GameStateEnter( eGameState.Playing, OnGameStartedPlaying_Client )
		//AddDestroyCallback( "prop_dynamic", OnWorkbenchDestroyed )
		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, SetupProgressWaypoint )
		AddCallback_GameStateEnter( eGameState.Playing, Crafting_OnGameStatePlaying )
		AddLocalPlayerTookDamageCallback( TryCloseCraftingMenuFromDamage )
		RegisterMinimapPackages()
		AddCallback_OnPlayerMatchStateChanged( OnPlayerMatchStateChanged )

		AddCallback_UseEntGainFocus( Crafting_OnGainFocus )
		AddCallback_UseEntLoseFocus( Crafting_OnLoseFocus )

		RegisterSignal( "CraftingWaypointCreated" )
		RegisterSignal( "HarvesterDisabled" )
		RegisterSignal( "HarvesterStopFX" )
		RegisterSignal( "WorkbenchUsed" )

		FlagInit( "CraftingNotificationLive", false )

		if( Replicators_PingFromMap_Enabled() )
			AddCallback_OnFindFullMapAimEntity( GetCrafterUnderAim, PingCrafterUnderAim )
	#endif

	PrecacheScriptString( WORKBENCH_SCRIPTNAME )
	PrecacheScriptString( WORKBENCH_RANDOMIZATION_TARGET_SCRIPTNAME )
	PrecacheScriptString( WORKBENCH_CLUSTER_SCRIPTNAME )
	PrecacheScriptString( WORKBENCH_CLUSTER_AIRDROPPED_SCRIPTNAME )



	PrecacheScriptString( HOLDER_ENT_NAME )
	PrecacheScriptString( HARVESTER_SCRIPTNAME )
	PrecacheScriptString( HARVESTER_MINIMAP_SCRIPTNAME )
	PrecacheScriptString( CARE_PACKAGE_SCRIPTNAME )

	PrecacheModel( HARVESTER_MODEL )
	PrecacheModel( WORKBENCH_MODEL )
	PrecacheModel( WORKBENCH_CLUSTER_MODEL )
	PrecacheModel( WORKBENCH_CLUSTER_AIRDROP_MODEL )


	PrecacheParticleSystem( HARVESTER_IDLE_FX )

	PrecacheParticleSystem( WORKBENCH_HOLO_FX )



	PrecacheParticleSystem( WORKBENCH_START_FX )
	PrecacheParticleSystem( WORKBENCH_BEAM_FX )
	PrecacheParticleSystem( WORKBENCH_ENGINE_SMOKE_FX )
	PrecacheParticleSystem( WORKBENCH_DOOR_OPEN_FX )
	PrecacheParticleSystem( WORKBENCH_PRINTING_FX )
	PrecacheParticleSystem( WORKBENCH_DISPENSER_HOLO_COLOR_FX )
	PrecacheParticleSystem( WORKBENCH_DISPENSER_START_FX )
	PrecacheParticleSystem( WORKBENCH_DISPENSER_BEAM_FX )
}

void function Crafting_RegisterNetworking()
{
	if ( !Crafting_PlaylistVar_IsEnabled() )
		return

	file.isEnabled = true

	if ( !Crafting_IsDispenserCraftingEnabled() )
	{
		RegisterNetworkedVariable( "craftingMaterials", SNDC_PLAYER_GLOBAL, SNVT_BIG_INT, 0 )
		RegisterNetworkedVariable( "Crafting_NumHarvesters", SNDC_GLOBAL, SNVT_INT, 0 )
	}

	RegisterNetworkedVariable( "Crafting_StartTime", SNDC_GLOBAL, SNVT_TIME, -1.0 )

#if SERVER || CLIENT
	Remote_RegisterClientFunction( "ServerCallback_CL_MaterialsChanged", "int", -1, INT_MAX, "int", -1, INT_MAX, "int", 0, eWildLifeCampType.Count, "entity", "bool" )
#endif

	Remote_RegisterClientFunction( "ServerCallback_CL_HarvesterUsed", "entity", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_CL_ArmorDeposited" )
	Remote_RegisterClientFunction( "ServerCallback_PromptNextHarvester", "entity", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_PromptWorkbench", "entity", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_PromptAllWorkbenches", "entity" )
	Remote_RegisterClientFunction( "ServerCallback_UpdateWorkbenchVars" )
	Remote_RegisterClientFunction( "ServerCallback_SetCraftingIndexForSpectator", "int", 0, 32 )

	Remote_RegisterClientFunction( "Crafting_Workbench_OpenCraftingMenu", "entity" )
	Remote_RegisterClientFunction( "TryCloseCraftingMenu" )
	Remote_RegisterClientFunction( "MarkAllWorkbenches" )
	Remote_RegisterClientFunction( "MarkNextStepForPlayer", "entity" )

	Remote_RegisterClientFunction( "ServerCallback_Crafting_Notify_Player_On_Obit", "entity", "int", 0, eCrafting_Obit_NotifyType.COUNT_, "int", 0, 256, "int", 0, 128, "int", -1, MAX_ARMOR_EVO_TIER + 1 )
	Remote_RegisterServerFunction( "ClientCallback_Crafting_Notify_Teammates_On_Obit", 		  "int", 0, eCrafting_Obit_NotifyType.COUNT_, "int", 0, 256, "int", 0, 128, "int", -1, MAX_ARMOR_EVO_TIER + 1 )
	Remote_RegisterServerFunction( "ClientCallback_InitializeCraftingAtWorkbench", "int", 0, 32 )
	Remote_RegisterServerFunction( "ClientCallback_ClosedCraftingMenu" )

	Remote_RegisterServerFunction( FUNCNAME_PingCrafterFromMap, "typed_entity", "prop_dynamic" )

	Remote_RegisterClientFunction( "ServertoClientCallback_SetDispenserData", "entity", "entity", "entity", "entity", "bool", "bool" )

	#if CLIENT
	AddOnSpectatorTargetChangedCallback( Crafting_OnSpectateTargetChanged )
	AddFirstPersonSpectateStartedCallback( Crafting_OnFirstPersonSpectateStarted )
	AddFirstPersonSpectateEndedCallback( Crafting_OnFirstPersonSpectateEnded )
	#endif

	file.isNetworkingRegistered = true
}


bool function Crafting_IsEnabled()
{
	return file.isEnabled
}

bool function Crafting_PlaylistVar_IsEnabled()
{
	return( GetCurrentPlaylistVarBool( "crafting_enabled", true ))
}

bool function Crafting_IsDispenserCraftingEnabled()
{
	//return( GetCurrentPlaylistVarBool( "crafting_dispensers_enabled", false ))
	return false//force disabled due to rui for this does not exist in s16
}

int function Crafting_DispenserAmmoMulitplier()
{
	return GetCurrentPlaylistVarInt( "dispensers_ammo_multi", 6 )
}

int function Crafting_DispenserAmmoMulitplierSmall()
{
	return GetCurrentPlaylistVarInt( "dispensers_ammo_multi_small", 4 )
}

bool function Crafting_DispenserFreeSupportBanner()
{
	return GetCurrentPlaylistVarBool ( "dispenser_support_craft", false )
}

bool function Crafting_DispenserSupportMRB()
{
	return GetCurrentPlaylistVarBool( "dispenser_support_mrb", false )
}

bool function Crafting_AutoEject_IsEnabled()
{
	return GetCurrentPlaylistVarBool( "crafting_auto_eject_enabled", true )
}

bool function Crafting_Access_Inventory_Enabled()
{
	return GetCurrentPlaylistVarBool( "crafting_access_inventory_enabled", true )
}

bool function Crafting_QuickOpenCraftingMenu()
{
	return GetCurrentPlaylistVarBool( "crafting_quickopen_enabled", true )
}

bool function Crafting_DispenserReactivation_IsEnabled()
{
	return GetCurrentPlaylistVarBool( "crafting_dispensers_reactivate_enabled", false )
}

bool function Crafting_LocationBeam_Enabled()
{
	return GetCurrentPlaylistVarBool( "crafting_dispensers_locationbeam", true )
}

#if CLIENT||SERVER
bool function Replicators_PingFromMap_Enabled()
{
	return GetCurrentPlaylistVarBool( "replicators_pingfrommap_enabled", true )
}
#endif

array<CraftingCategory> function Crafting_GetCraftingDataArray()
{
	return file.craftingDataArray
}

bool function Crafting_IsPingMapIconEnabled()
{
	return GetCurrentPlaylistVarBool( "crafting_pingmapicon_enabled", true )
}

bool function Crafting_CraftersDisabledInDeathField()
{
	return( GetCurrentPlaylistVarBool( "crafting_crafters_disabled_indeathfield", false ))
}

float function Crafting_CrafterExlusionDistance()
{
	return GetCurrentPlaylistVarFloat( "crafting_crafter_exclusion_distance", 16250 )
}

float function Crafting_HarvesterExlusionDistance()
{
	return GetCurrentPlaylistVarFloat( "crafting_harvester_exclusion_distance", 12000 )
}

#if SERVER
int function Crafting_HarvesterGoalOverride()
{
	return GetCurrentPlaylistVarInt( "crafting_cluster_goal_override", file.defaultCrafterGoalCount )
}

void function Crafting_SetCrafterGoalCount( int goal )
{
	file.defaultCrafterGoalCount = goal
}
#endif // SERVER

void function RegisterCraftingData()
{
	var dataTable
	dataTable = GetDataTable( CRAFTING_DATATABLE )

	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		dataTable = GetDataTable( CRAFTING_DISPENSERS_DATATABLE )
	}

	int numRows = GetDataTableRowCount( dataTable )

	for ( int i=0; i<numRows; i++ )
	{
		CraftingCategory item
		item.index = i

		item.category = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "category" ) )

		string rotationStyle = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "rotationStyle" ) )
		item.rotationStyle = GetRotationStyleEnumFromString( rotationStyle )

		string exclusivityStyle = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "exclusivityStyle" ) )
		item.exclusivityStyle = GetExclusivityStyleEnumFromString( exclusivityStyle )

		int numSlots = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "slots" ) )
		item.numSlots = numSlots

		string bundleString = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "bundlesList" ) )
		array<string> bundles = GetTrimmedSplitString( bundleString, " " )
		foreach( bundle in bundles )
		{
			CraftingBundle newBundleStruct
			item.bundlesInCategory[bundle] <- newBundleStruct
			item.bundleStrings.append( bundle )
		}

		file.craftingData[ item.category ] <- item
		file.craftingDataArray.append( item )
	}

	printf( "CRAFTING: Data parsed and registered" )

	//check for playlist bundle overrides
	foreach ( item in file.craftingDataArray )
	{
		string bundlesPlaylistCheck = GetCurrentPlaylistVarString( "crafting_dt_override_" + item.category + "_bundles", "" )
		if ( bundlesPlaylistCheck != "" )
		{
			array<string> bundles = GetTrimmedSplitString( bundlesPlaylistCheck, " " )
			foreach( bundle in bundles )
			{
				CraftingBundle newBundleStruct
				item.bundlesInCategory.clear()
				item.bundlesInCategory[bundle] <- newBundleStruct
				item.bundleStrings.clear()
				item.bundleStrings.append( bundle )
			}
		}
	}
}


void function RegisterCraftingDistribution()
{
	var distributionTable
	distributionTable = GetDataTable( CRAFTING_CATEGORIES_DATATABLE )

	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		distributionTable = GetDataTable( CRAFTING_DISPENSERS_CATEGORIES_DATATABLE )
	}

	int numRows = GetDataTableRowCount( distributionTable )

	foreach ( category in file.craftingDataArray )
	{
		printf( "CRAFTING: Getting datatable for category " + category.category )
		foreach ( name, bundle in category.bundlesInCategory )
		{
			int startingRow = GetDataTableRowMatchingStringValue( distributionTable, GetDataTableColumnByName( distributionTable, "bundle" ), name )
			string bundlePlaylistCheck = GetCurrentPlaylistVarString( "crafting_dt_override_bundle_" + name, "" )

			if ( bundlePlaylistCheck != "" )
			{
				array<string> itemsInBundle = GetTrimmedSplitString( bundlePlaylistCheck, " " )
				Assert( itemsInBundle.len() == category.numSlots, "CRAFTING: Playlist override for bundle " + name + " in category " + category.category + " does not match expected number of slots: " + category.numSlots )

				foreach( item in itemsInBundle )
				{
					array<string> result = GetTrimmedSplitString( item, ":" )
					string itemRef = result[0]
					int cost = int(result[1])

					bundle.itemsInBundle.append( itemRef )
					category.itemToCostTable[itemRef] <- cost
				}
				continue
			}

			if ( startingRow == -1 )
				continue

			int currentRow = startingRow
			while ( ( currentRow < numRows && GetDataTableString( distributionTable, currentRow, GetDataTableColumnByName( distributionTable, "bundle" ) ) == "" ) || currentRow == startingRow )
			{
				string item = GetDataTableString( distributionTable, currentRow, GetDataTableColumnByName( distributionTable, "base" ) )
				int cost = GetDataTableInt( distributionTable, currentRow, GetDataTableColumnByName( distributionTable, "base_item_cost" ) )

				bundle.itemsInBundle.append( item )
				category.itemToCostTable[item] <-cost

				currentRow++
			}
		}
	}
}

array<string> function Crafting_GetCraftingItemsByCategoryName( string categoryToCheck )
{
	array<string> validItemsInBundle

	for ( int i = 0; i < file.craftingDataArray.len(); i++ )
	{
		CraftingCategory group = file.craftingDataArray[i]

		if( group.category != categoryToCheck )
			continue

		if ( group.exclusivityStyle == eCraftingExclusivityStyle.RARITY || group.exclusivityStyle == eCraftingExclusivityStyle.FLOOR )
		{
			validItemsInBundle.extend( GenerateCraftingItemsInCategory( null, group ) )
		}
	}

	return validItemsInBundle
}


void function HandleCraftingExclusivity()
{
	if ( !Crafting_PlaylistVar_IsEnabled() )
		return

	for ( int i = 0; i < file.craftingDataArray.len(); i++ )
	{
		CraftingCategory group = file.craftingDataArray[i]

		array<string> itemsToDisable

		if ( group.exclusivityStyle == eCraftingExclusivityStyle.RARITY || group.exclusivityStyle == eCraftingExclusivityStyle.FLOOR )
		{
			array< string > validItems = GenerateCraftingItemsInCategory( null, group )
			foreach ( item in validItems )
			{
				itemsToDisable.append( item )
			}
		}
		else if ( group.exclusivityStyle == eCraftingExclusivityStyle.NONE )
		{
			//do nothing
		}

		foreach ( item in itemsToDisable )
		{
			Crafting_AddExclusiveLoot(item)
		}
	}
}

void function Crafting_AddExclusiveLoot( string item )
{
	if ( item.find( "mp_weapon" ) != -1 )
	{
		//If it's a weapon, add all known locked sets
		string weapon = GetBaseWeaponRef( item )
		file.disabledPoolLoot.append( weapon )
		foreach ( string set in GetLockedSetsDisabledByCrafting() )
		{
			file.disabledPoolLoot.append( weapon + set )
		}
	}
	else
		//if loot is not a weapon, add to disabled ground loot list so it can still spawn in care packages etc, but does not spawn in initial ground loot spawn
		file.disabledGroundLoot.append( item )
}


int function GetRotationStyleEnumFromString( string input )
{
	int rotationStyle
	bool rotationStyleFound = false

	for ( int i = 0; i < eCraftingRotationStyle.COUNT_; i++ )
	{
		string enumStyle = GetEnumString( "eCraftingRotationStyle", i )
		if ( enumStyle.tolower() == input )
		{
			rotationStyle = i
			rotationStyleFound = true
			break
		}
	}

	Assert( rotationStyleFound, "Playlist Crafting Rotation Pattern '" + input + "' is not a specified enumerator." )

	return rotationStyle
}


int function GetExclusivityStyleEnumFromString( string input )
{
	int exclusivityStyle
	bool exclusivityStyleFound = false

	for ( int i = 0; i < eCraftingExclusivityStyle.COUNT_; i++ )
	{
		string enumStyle = GetEnumString( "eCraftingExclusivityStyle", i )
		if ( enumStyle.tolower() == input )
		{
			exclusivityStyle = i
			exclusivityStyleFound = true
			break
		}
	}

	Assert( exclusivityStyleFound, "Playlist Crafting Exclusivity Style '" + input + "' is not a specified enumerator." )

	return exclusivityStyle
}


void function Crafting_OnGameStatePlaying()
{
	thread Crafting_OnGameStatePlaying_Thread()
}


void function Crafting_OnGameStatePlaying_Thread()
{
	#if SERVER
		int randomizationStyle = GetCraftingRandomizationStyle()
		if ( randomizationStyle == eCraftingRandomization.RANDOM_HARVESTER_DISTRIBUTION )
		{
			RandomizeHarvesterLocations()
		}
		else if ( randomizationStyle == eCraftingRandomization.RANDOM_CLUSTER_DISTRIBUTION )
		{
			waitthread RandomizeClusterLocations_Thread( false )
		}
		else if ( randomizationStyle == eCraftingRandomization.RANDOM_CLUSTER_LINKED_DISTRIBUTION )
		{
			waitthread RandomizeClusterLocations_Thread( true )
		}
		else if ( randomizationStyle == eCraftingRandomization.RANDOM_COMBINATION_DISTRIBUTION )
		{
			waitthread RandomizeClusterLocations_Thread( false )
			RandomizeHarvesterLocations()
		}

		foreach( harvester in file.harvesterArray )
		{
			foreach( ent in harvester.GetLinkEntArray() )
				harvester.UnlinkFromEnt( ent )
		}


		SetupLimitedStockParent()
		SetupMinimapZones()
		if ( file.workbenchClusterArray.len() > 0 )
		{
			thread Crafting_WorkbenchAirdropLogic()
		}
	#endif

	file.timeAtMatchStart = GetUnixTimestamp()

	FlagSet( "CraftingInitialized" )
}


#if SERVER
int function GetCraftingRandomizationStyle()
{
	int randomizationStyle
	string playlistStyle = GetCurrentPlaylistVarString( "crafting_randomization_pattern", "RANDOM_CLUSTER_LINKED_DISTRIBUTION" ).tolower()
	bool randomizationPatternFound = false

	for( int i = 0; i < eCraftingRandomization.COUNT_; i++ )
	{
		string enumStyle = GetEnumString( "eCraftingRandomization", i )
		if (enumStyle.tolower() == playlistStyle)
		{
			randomizationStyle = i
			randomizationPatternFound = true
			break
		}
	}

	Assert( randomizationPatternFound, "Playlist Crafting Randomization Pattern '" + playlistStyle + "' is not a specified enumerator." )

	return randomizationStyle
}

void function RandomizeHarvesterLocations()
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	if ( file.harvesterArray.len() == 0 )
		return

	file.harvesterArray.randomize()
	array<entity> distributedHarvesters
	array<entity> nonDistributedHarvesters
	int goal = file.workbenchClusterArray.len() * 2

	if ( GetCurrentPlaylistVarInt( "crafting_harvester_goal_override", -1 ) != -1 )
		goal = GetCurrentPlaylistVarInt( "crafting_harvester_goal_override", -1 )

	if ( GetIsUnifiedRandomizerEnabled() )
	{
		distributedHarvesters = RandomizeNodeLocations( file.harvesterArray, Crafting_HarvesterExlusionDistance(), goal, true, ePropPlacementType.NO_TYPE_SPECIFIED, COLOR_MAGENTA )
	}
	else
	{
		if ( file.harvesterArray.len() >= goal )
		{
			float exclusionDistanceSquared = Crafting_HarvesterExlusionDistance() * Crafting_HarvesterExlusionDistance();
			distributedHarvesters.append( file.harvesterArray[0] )
			for ( int i = 0; i < goal - 1; i++ )
			{
				for ( int j = 0; j < file.harvesterArray.len(); j++ )
				{
					int count = 0
					foreach ( distributedHarvester in distributedHarvesters )
					{
						if ( DistanceSqr( file.harvesterArray[j].GetOrigin(), distributedHarvester.GetOrigin() ) > exclusionDistanceSquared )
						{
							count++
						}
					}
					if ( count == distributedHarvesters.len() )
					{
						distributedHarvesters.append( file.harvesterArray[j] )
						file.harvesterArray.remove( j )
						j--
						break
					}
					else
					{
						nonDistributedHarvesters.append( file.harvesterArray[j] )
						file.harvesterArray.remove( j )
						j--
					}
				}
			}

			int validSpotsFound = distributedHarvesters.len()
			if ( validSpotsFound < goal )
			{
				for ( int i = 0; i < goal - validSpotsFound + 1; i++ )
				{
					distributedHarvesters.append( nonDistributedHarvesters[i] )
				}
			}
		}
		else
		{
			// if we have less then goal lets just keep all of them.
			distributedHarvesters = clone file.harvesterArray
			file.harvesterArray.clear()
		}

		//Destroying unused entities
		for ( int i = 0; i < file.harvesterArray.len(); i++ )
		{
			file.harvesterArray[i].Destroy()
			file.harvesterArray.remove( i )
			i--
		}

		for ( int i = 0; i < nonDistributedHarvesters.len(); i++ )
		{
			if ( !distributedHarvesters.contains( nonDistributedHarvesters[i] ) )
			{
				nonDistributedHarvesters[i].Destroy()
				nonDistributedHarvesters.remove( i )
				i--
			}
		}
	}

	file.harvesterArray.clear()
	file.harvesterArray = clone distributedHarvesters

	SetGlobalNetInt( "Crafting_NumHarvesters", file.harvesterArray.len() )
}


void function RandomizeClusterLocations_Thread( bool shouldLinkHarvesters )
{
	if ( file.workbenchClusterArray.len() == 0 )
		return

	file.workbenchClusterArray.randomize()
	array< entity > distributedClusters
	array < entity > nonDistributedClusters
	int goal = Crafting_HarvesterGoalOverride()

	if ( GetIsUnifiedRandomizerEnabled() )
	{
		distributedClusters = RandomizeNodeLocations( file.workbenchClusterArray, Crafting_CrafterExlusionDistance(), goal, false, ePropPlacementType.CRAFTER, COLOR_ORANGE )
		ArrayRemoveInvalid( file.workbenchClusterArray )

		//Destroying unused entities
		for ( int i = 0; i < file.workbenchClusterArray.len(); i++ )
		{
			DestroyClusterAndLinkedEntities( file.workbenchClusterArray, file.workbenchClusterArray[i], i, shouldLinkHarvesters )
			i--
		}
	}
	else
	{
		if ( file.workbenchClusterArray.len() >= goal )
		{
			float exclusionDistanceSquared = Crafting_CrafterExlusionDistance() * Crafting_CrafterExlusionDistance()
			distributedClusters.append( file.workbenchClusterArray[0] )
			for ( int i = 0; i < goal - 1; i++ )
			{
				for ( int j = 0; j < file.workbenchClusterArray.len(); j++ )
				{
					int count = 0
					foreach ( distributedCluster in distributedClusters )
					{
						if ( DistanceSqr( file.workbenchClusterArray[j].GetOrigin(), distributedCluster.GetOrigin() ) > exclusionDistanceSquared )
						{
							count++
						}
					}
					if ( count == distributedClusters.len() )
					{
						distributedClusters.append( file.workbenchClusterArray[j] )
						file.workbenchClusterArray.remove( j )
						j--
						break
					}
					else
					{
						nonDistributedClusters.append( file.workbenchClusterArray[j] )
						file.workbenchClusterArray.remove( j )
						j--
					}
				}
			}

			int validSpotsFound = distributedClusters.len()
			if ( validSpotsFound < goal )
			{
				for ( int i = 0; i < goal - validSpotsFound + 1; i++ )
				{
					distributedClusters.append( nonDistributedClusters[i] )
				}
			}
		}
		else
		{
			// if we have less then goal lets just keep all of them.
			distributedClusters = clone file.workbenchClusterArray
			file.workbenchClusterArray.clear()
		}

		//Destroying unused entities
		for ( int i = 0; i < file.workbenchClusterArray.len(); i++ )
		{
			DestroyClusterAndLinkedEntities( file.workbenchClusterArray, file.workbenchClusterArray[i], i, shouldLinkHarvesters )
			i--
		}
		WaitFrame() // Doing both these loops in the same frame contributed to an issue with running over the frame budget
		for ( int i = 0; i < nonDistributedClusters.len(); i++ )
		{
			if ( !distributedClusters.contains( nonDistributedClusters[i] ) )
			{
				DestroyClusterAndLinkedEntities( nonDistributedClusters, nonDistributedClusters[i], i, shouldLinkHarvesters )
				i--
			}
		}
	}

	file.workbenchClusterArray.clear()
	file.workbenchClusterArray = clone distributedClusters
	ArrayRemoveInvalid( file.workbenchClusterArray )

	array<entity> clusterArray = clone file.workbenchClusterArray
	clusterArray.randomize()
	for( int i = 4; i >= 2; i-- )
	{
		int perPOIgoal = goal - 2
		if ( i == 4 || i == 2 )
			perPOIgoal = 1
		if ( perPOIgoal < 0 )
			continue

		array<entity> arrayForRemoval = clone clusterArray
		foreach ( cluster in clusterArray )
		{
			int harvesterCount = 0
			foreach ( ent in cluster.GetLinkEntArray() )
			{
				if ( ent.GetScriptName() == HARVESTER_SCRIPTNAME )
					harvesterCount++
			}

			if ( harvesterCount >= i )
			{
				DestroyLinkedHarvestersFromWorkbenchCluster( cluster, harvesterCount - i )
				perPOIgoal--
				arrayForRemoval.removebyvalue( cluster )
			}

			if ( perPOIgoal <= 0 )
				break
		}

		clusterArray = arrayForRemoval
	}

	if ( !Crafting_IsDispenserCraftingEnabled() )
	{
		SetGlobalNetInt( "Crafting_NumHarvesters", file.harvesterArray.len() )
	}
}

void function DestroyClusterAndLinkedEntities( array<entity> arrayRef, entity cluster, int index, bool shouldlinkHarvesters )
{
	array<entity> linkedEntities = cluster.GetLinkEntArray()

	foreach( ent in linkedEntities )
	{
		if( !IsValid( ent ) )
			continue

		if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
		{
			cluster.UnlinkFromEnt( ent )
			if (( cluster in file.ambGenericTable ) && IsValid( file.ambGenericTable[cluster] ))
			{
				file.ambGenericTable[cluster].Destroy()
				delete file.ambGenericTable[cluster]
			}
			ent.Destroy()
		}

		if ( ent.GetScriptName() == HARVESTER_SCRIPTNAME && shouldlinkHarvesters )
		{
			cluster.UnlinkFromEnt( ent )
			file.harvesterArray.fastremovebyvalue( ent )
			ent.Destroy()
		}
	}

	arrayRef.remove( index )
	cluster.Destroy()
}

void function DestroyLinkedHarvestersFromWorkbenchCluster( entity cluster, int numToDestroy )
{
	if ( numToDestroy <= 0 )
		return

	array<entity> linkedEntities = clone cluster.GetLinkEntArray()
	linkedEntities.randomize()
	int destroyedCounter = 0

	foreach( ent in linkedEntities )
	{
		if ( ent.GetScriptName() == HARVESTER_SCRIPTNAME && destroyedCounter < numToDestroy )
		{
			cluster.UnlinkFromEnt( ent )
			file.harvesterArray.fastremovebyvalue( ent )
			ent.Destroy()
			destroyedCounter++
		}
	}
}


void function SetupMinimapZones()
{
	foreach( cluster in file.workbenchClusterArray )
	{
		vector averageLocation = cluster.GetOrigin()
		//check if cluster has harvesters
		array<entity> linkedEntities = cluster.GetLinkEntArray()
		int numEntities = 1
		foreach( ent in linkedEntities )
		{
			if ( ent.GetScriptName() == HARVESTER_SCRIPTNAME )
			{
				averageLocation += ent.GetOrigin()
				numEntities++
			}
		}

		averageLocation = averageLocation / ( numEntities )

		entity furthestEnt = cluster
		vector averageLocationProjection = < averageLocation.x, averageLocation.y, 0 >
		foreach( ent in linkedEntities )
		{
			if ( ent.GetScriptName() == HARVESTER_SCRIPTNAME )
			{
				vector entProjection = < ent.GetOrigin().x, ent.GetOrigin().y, 0 >
				vector furthestEntProjection = < furthestEnt.GetOrigin().x, furthestEnt.GetOrigin().y, 0 >
				if ( Distance( entProjection, averageLocationProjection ) > Distance( furthestEntProjection, averageLocationProjection ) )
					furthestEnt = ent
			}
		}

		vector furthestEntProjection = < furthestEnt.GetOrigin().x, furthestEnt.GetOrigin().y, 0 >
		float radius = Distance( averageLocationProjection, furthestEntProjection ) + 300

		//minimapObj for zone
		entity surveyZone = CreatePropScript( $"mdl/dev/empty_model.rmdl", averageLocation )
		surveyZone.Minimap_SetObjectScale( radius / SURVIVAL_MINIMAP_RING_SCALE )
		surveyZone.Minimap_SetAlignUpright( true )
		surveyZone.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
		surveyZone.Minimap_SetClampToEdge( true )
		surveyZone.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
		surveyZone.DisableHibernation()
		SetTargetName( surveyZone, "craftingZone" )
	}
}


void function SetupLimitedStockParent()
{
	entity randomizationParent = CreateEntity( "info_target" )
	randomizationParent.SetScriptName( WORKBENCH_RANDOMIZATION_TARGET_SCRIPTNAME )
	randomizationParent.kv.spawnFlags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	randomizationParent.DisableHibernation()
	DispatchSpawn( randomizationParent )

	file.limitedStockParent = randomizationParent
}

void function SetupLimitedStockWorkbench( entity workbench )
{
	workbench.LinkToEnt( file.limitedStockParent )
	int fxId = GetParticleSystemIndex( WORKBENCH_BEAM_FX )
	file.limitedStockFXTable[workbench] <- StartParticleEffectOnEntity_ReturnEntity( workbench, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	workbench.SetTakeDamageType( DAMAGE_NO )
	workbench.SetShieldHealthMax( WORKBENCH_LIMITED_STOCK_USE_DEFAULT )
	workbench.SetShieldHealth( WORKBENCH_LIMITED_STOCK_USE_DEFAULT )

	foreach( player in GetConnectedPlayers() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateWorkbenchVars" )
}

#if DEVELOPER
void function RemoveLimitedStockFromWorkbenchAtIndex( entity workbench )
{
	if ( workbench.GetShieldHealth() > 0 )
	{
		workbench.SetShieldHealth( workbench.GetShieldHealth() - 1 )

		if ( workbench.GetShieldHealth() <= 0 )
		{
			array<entity> otherWorkbenchesInCluster = workbench.GetLinkEntArray()
			array<entity> otherPlayersAtCluster
			foreach ( bench in otherWorkbenchesInCluster )
			{
				if ( bench.GetScriptName() == WORKBENCH_SCRIPTNAME )
				{
					foreach ( potentialPlayer in bench.GetLinkEntArray() )
					{
						if ( IsValidPlayer( potentialPlayer ) )
							otherPlayersAtCluster.append( potentialPlayer )
					}
				}
			}

			foreach( player in otherPlayersAtCluster )
			{
				if ( file.craftingBetterSpectatorEnabled )
				{
					Remote_CallFunction_Replay( player, "TryCloseCraftingMenu" )
				}
				else
				{
					Remote_CallFunction_NonReplay( player, "TryCloseCraftingMenu" )
				}
			}

			EffectStop( file.limitedStockFXTable[workbench] )
			delete file.limitedStockFXTable[workbench]
		}
	}

	foreach( player in GetConnectedPlayers() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateWorkbenchVars" )
}
#endif

array<string> function Crafting_GetDisabledGroundLoot()
{
	return file.disabledGroundLoot
}

array<string> function Crafting_GetDisabledPoolLoot()
{
	return file.disabledPoolLoot
}

bool function Crafting_IsLootRemovedFromGround( string ref )
{
	return Crafting_GetDisabledGroundLoot().contains( ref )
}

bool function Crafting_IsLootRemovedFromPool( string ref )
{
	return Crafting_GetDisabledPoolLoot().contains( ref )
}

array<vector> function Crafting_GetPreviousAirdropLocations()
{
	return file.workbenchAirdropPositions
}

#if DEVELOPER
void function DEV_PrintDisabledGroundLoot()
{
	printf( "Crafting -- Disabled Ground Loot" )
	foreach ( string ref in Crafting_GetDisabledGroundLoot() )
	{
		printf( ref )
	}
}

void function DEV_PrintDisabledPoolLoot()
{
	printf( "Crafting -- Disabled Pool Loot" )
	foreach ( string ref in Crafting_GetDisabledPoolLoot() )
	{
		printf( ref )
	}
}
#endif

array<entity> function Crafting_GetAllHarvesters()
{
	return file.harvesterArray
}

array<entity> function Crafting_GetAllWorkbenchClusters()
{
	return file.workbenchClusterArray
}

void function Dispensers_OnPlayerStateChanged( entity player )
{
	if ( !Crafting_IsDispenserCraftingEnabled() )
		return

	if ( !IsValid( player ) )
		return

	array<entity> workbenchClusters = Crafting_GetAllWorkbenchClusters()
	foreach ( entity cluster in workbenchClusters )
	{
		if ( !IsValid( cluster ) )
			continue

		array <entity> benchSiblings = cluster.GetLinkEntArray()
		foreach ( bench in benchSiblings)
		{
			if ( bench.GetScriptName() == WORKBENCH_SCRIPTNAME )
			{
				WorkbenchData craftingBenchData = file.workbenchDataTable[bench]
				foreach( teammate in GetPlayerArrayOfTeam( player.GetTeam() ) )
				{
					if ( teammate in craftingBenchData.playersHaveUsed )
					{
						if ( teammate == player )
							craftingBenchData.playersHaveUsed[ player ] <- true

						Remote_CallFunction_NonReplay( player, "ServertoClientCallback_SetDispenserData", teammate, bench, cluster, file.minimapObjTable[cluster], false, true )
					}
				}
			}
		}
	}
}

void function Callback_Dispensers_RefreshState( int stage, float nextCircleStartTime )
{
	if ( !Crafting_DispenserReactivation_IsEnabled() )
		return

	if ( stage == 0 || stage > 4 )
		return

	array< entity > allPlayers = GetPlayerArray()
	array<entity> workbenchClusters = Crafting_GetAllWorkbenchClusters()
	foreach ( entity cluster in workbenchClusters )
	{
		array <entity> benchSiblings = cluster.GetLinkEntArray()
		foreach ( bench in benchSiblings)
		{
			if ( bench.GetScriptName() == WORKBENCH_SCRIPTNAME )
			{
				WorkbenchData craftingBenchData = file.workbenchDataTable[bench]
				foreach ( player in allPlayers )
				{
					if ( player in craftingBenchData.playersHaveUsed )
					{
						// dont need to call for all teammates here because we already clear their data in the next function
						Remote_CallFunction_NonReplay( player, "ServertoClientCallback_SetDispenserData", player, bench, cluster, file.minimapObjTable[cluster], false, false )
					}
				}
				craftingBenchData.playersHaveUsed.clear()
			}
		}
	}
}
#endif // SERVER

int function Dispensers_GetReplicatorStateForPlayer( entity player, entity pingEnt )
{
	if ( !IsValid( pingEnt ) || !IsValid( player ) )
		return 0

	//check state of replicator to see who has used it on the team
	int notifyType
	int teammatesUsed = 0
	bool isNotifier = false
	WorkbenchData craftingBenchData

	array <entity> benchSiblings = pingEnt.GetLinkEntArray()
	foreach ( bench in benchSiblings)
	{
		if ( bench.GetScriptName() == WORKBENCH_SCRIPTNAME )
		{
			#if SERVER
			craftingBenchData = file.workbenchDataTable[bench]
			#endif

			#if CLIENT
			craftingBenchData = file.workbenchDataTable_Client[bench]
			#endif
			break
		}
		else
		{
			return 0
		}
	}

	array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach ( teamPlayer in teammates )
	{
		if ( teamPlayer in craftingBenchData.playersHaveUsed )
		{
			teammatesUsed++
			if ( teamPlayer == player )
				isNotifier = true
		}
	}

	if ( teammatesUsed == 0 )
	{
		notifyType = eCrafting_Dispenser_StateType.NO_ONE_HAS_USED
	}
	else if ( isNotifier && teammatesUsed == teammates.len() )
	{
		notifyType = eCrafting_Dispenser_StateType.ALL_USED
	}
	else if ( isNotifier && teammatesUsed > 0 )
	{
		notifyType = eCrafting_Dispenser_StateType.PLAYER_HAS_USED
	}
	else if ( !isNotifier && teammatesUsed > 0 )
	{
		notifyType = eCrafting_Dispenser_StateType.TEAMMATE_HAS_USED
	}

	return notifyType
}

array<string> function GetItemNamesFromCraftingBundle( CraftingBundle craftedBundle )
{
	array<string> arrayResults

	Assert( craftedBundle.itemsInBundle.len() > 0, "WARNING: GetItemNamesFromCraftingBundle called with no items in the bundle." )

	foreach( string bundleString in craftedBundle.itemsInBundle )
	{
		#if DEVELOPER
		DEV_Crafting_Print( format( "  ** crafting item bundlestring = %s", bundleString  ))
		#endif // DEVELOPER
		arrayResults.append( bundleString )
	}
	return arrayResults
}

int function GetLimitedStockFromWorkbench( entity workbench )
{
	if ( !IsLimitedStockWorkbench( workbench ) )
	{
		return 0
	}

	return workbench.GetShieldHealth()
}

bool function IsLimitedStockWorkbench( entity workbench )
{
	if ( !IsValid( file.limitedStockParent ) || !IsValid( workbench ) )
		return false

	//return file.limitedStockParent.GetLinkParentArray().contains( workbench )
	return false
}


string function LimitedStock_TextOverride( entity workbench )
{
	entity cluster
	foreach ( ent in workbench.GetLinkParentArray() )
	{
		if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
		{
			cluster = ent
			break
		}
	}

	bool isWorkbenchBusy = workbench.GetLinkEntArray().len() != 0
	bool isWorkbenchCrafting = workbench.GetOwner() != null
	if ( isWorkbenchBusy || isWorkbenchCrafting || workbench.e.isBusy )
		return "#CRAFTING_WORKBENCH_USE_PROMPT_UNAVAILABLE"

	if ( GetLimitedStockFromWorkbench( cluster ) <= 0 )
		return "#CRAFTING_WORKBENCH_USE_PROMPT_INVALID"

	return "#CRAFTING_WORKBENCH_USE_PROMPT"
}


#if CLIENT
void function OnLimitedStockParentCreated( entity target )
{
	if ( !file.isEnabled )
		return

	if ( target.GetScriptName() != WORKBENCH_RANDOMIZATION_TARGET_SCRIPTNAME )
		return

	file.limitedStockParent = target
}


string function Crafting_GetWorkbenchTitleString()
{
	entity workbench = GetLocalClientPlayerWorkbench()
	if ( IsLimitedStockWorkbench( workbench ) )
	{
		return Localize("#CRAFTING_WORKBENCH_LIMITED")
	}
	else if ( Crafting_IsDispenserCraftingEnabled() )
	{
		return Localize("#DISPENSER_TITLE")
	}

	else
		return Localize("#CRAFTING_WORKBENCH")
	unreachable
}


string function Crafting_GetWorkbenchDescString()
{
	entity workbench = GetLocalClientPlayerWorkbench()
	if ( IsLimitedStockWorkbench( workbench ) )
	{
		return GetLimitedStockFromWorkbench( workbench ) <=1 ? Localize("#CRAFTING_LIMITED_USE_BENCH_SINGULAR", GetLimitedStockFromWorkbench( workbench )) : Localize("#CRAFTING_LIMITED_USE_BENCH", GetLimitedStockFromWorkbench( workbench ))
	}
	else if ( Crafting_IsDispenserCraftingEnabled() )
	{
		return Localize("#DISPENSER_DESC")
	}

	else
		return Localize("#CRAFTING_WORKBENCH_DESC")
	unreachable
}


entity function GetLocalClientPlayerWorkbench()
{
	entity player = GetLocalViewPlayer()
	entity workbench
	array<entity> possibleWorkbenches = player.GetLinkParentArray()
	foreach( ent in possibleWorkbenches )
	{
		if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
		{
			foreach ( cluster in ent.GetLinkParentArray() )
			{
				if ( cluster.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
				{
					workbench = cluster
					break
				}
			}

			if ( workbench != null )
				break
		}
	}

	return workbench
}


void function RegisterMinimapPackages()
{
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.CRAFTING_HARVESTER, MINIMAP_OBJECT_RUI, MinimapPackage_Crafting_Harvester, FULLMAP_OBJECT_RUI, FullmapPackage_Crafting_Harvester )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.CRAFTING_WORKBENCH, MINIMAP_OBJECT_RUI, MiniMapPackage_Crafting_Workbench, FULLMAP_OBJECT_RUI, MapPackage_Crafting_Workbench )
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.CRAFTING_WORKBENCH_LIMITED, MINIMAP_OBJECT_RUI, MapPackage_Crafting_WorkbenchLimited, FULLMAP_OBJECT_RUI, MapPackage_Crafting_WorkbenchLimited )
}


void function FullmapPackage_Crafting_Harvester( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", HARVESTER_ICON_ASSET )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )

	RuiSetImage( rui, "smallIcon", CRAFTING_SMALL_HARVESTER_ASSET )
	RuiSetBool( rui, "hasSmallIcon", true )

	file.harvesterFullmapRuiTable[ent] <- rui
}

void function MinimapPackage_Crafting_Harvester( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", HARVESTER_ICON_ASSET )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )

	RuiSetImage( rui, "smallIcon", CRAFTING_SMALL_HARVESTER_ASSET )
	RuiSetBool( rui, "hasSmallIcon", true )

	file.harvesterMinimapRuiTable[ent] <- rui
}

void function MapPackage_Crafting_Workbench( entity ent, var rui )
{
	bool isAirdrop = ent.GetTargetName() == "craftingWorkbenchAirdropIcon"

	RuiSetImage( rui, "defaultIcon", Crafting_GetCraftingIcon( isAirdrop ) )

	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )

	if ( !isAirdrop )
	{
		RuiSetImage( rui, "smallIcon", Crafting_GetSmallCraftingIcon() )
		RuiSetBool( rui, "hasSmallIcon", true )

		if ( Crafting_IsDispenserCraftingEnabled() )
			RuiSetFloat2( rui, "iconScale", <1.15, 1.15, 0.0> )
	}

	file.dispenserMapRuiTable[ent] <- rui
}

void function MiniMapPackage_Crafting_Workbench( entity ent, var rui )
{
	bool isAirdrop = ent.GetTargetName() == "craftingWorkbenchAirdropIcon"

	RuiSetImage( rui, "defaultIcon", Crafting_GetCraftingIcon( isAirdrop ) )

	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )

	if ( !isAirdrop )
	{
		RuiSetImage( rui, "smallIcon", Crafting_GetSmallCraftingIcon() )
		RuiSetBool( rui, "hasSmallIcon", true )

		if ( Crafting_IsDispenserCraftingEnabled() )
			RuiSetFloat2( rui, "iconScale", <1.15, 1.15, 0.0> )
	}

		file.dispenserMinimapRuiTable[ent] <- rui
}

void function MapPackage_Crafting_WorkbenchLimited( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", WORKBENCH_ICON_LIMITED_ASSET )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function TryCloseCraftingMenuFromDamage( float damage, vector damageOrigin, int damageType, int damageSourceId, entity attacker )
{
	if ( GetConVarBool( "player_setting_damage_closes_deathbox_menu" ) )
		TryCloseCraftingMenu()
}
#endif // CLIENT


///// SETUP FUNCTIONS /////
#if SERVER
void function Crafting_OnEntitiesDidLoad()
{
	if ( !Crafting_IsDispenserCraftingEnabled() )
	{
		SetGlobalNetInt( "Crafting_NumHarvesters", file.harvesterArray.len() )
	}

	SetGlobalNetTime( "Crafting_StartTime", float(file.matchStartTime) )
}

entity function CreateMaterialHarvester( asset model, vector ornull origin = null, vector ornull angles = null, int solidType = 0, float fadeDist = -1, bool dispatchSpawn = true )
{
	entity materialHarvester = CreateEntity( "prop_dynamic" )
	materialHarvester.SetValueForModelKey( model )
	materialHarvester.kv.fadedist = fadeDist
	materialHarvester.kv.renderamt = 255
	materialHarvester.kv.rendercolor = "255 255 255"
	materialHarvester.kv.solid = solidType // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	if ( origin )
	{
		// hack: Setting origin twice. SetOrigin needs to happen before DispatchSpawn, otherwise the prop may not touch triggers
		materialHarvester.SetOrigin( expect vector( origin ) )
		if ( angles )
			materialHarvester.SetAngles( expect vector( angles ) )
	}

	if ( dispatchSpawn )
		DispatchSpawn( materialHarvester )

	if ( origin )
	{
		// hack: Setting origin twice. SetOrigin needs to happen after DispatchSpawn, otherwise origin is snapped to nearest whole unit
		materialHarvester.SetOrigin( expect vector( origin ) )
		if ( angles )
			materialHarvester.SetAngles( expect vector( angles ) )
	}

	materialHarvester.SetFadeDistance( fadeDist )

	return materialHarvester
}

void function OnHarvesterScriptTargetSpawned( entity ent )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		ent.Destroy()
		return
	}

	vector origin = ent.GetOrigin()
	vector angles = ent.GetAngles()
	array<entity> links = ent.GetLinkEntArray()
	array<entity> parentLinks = ent.GetLinkParentArray()
	entity par = ent.GetParent()

//	ent.Destroy()

	if ( !file.isEnabled )
		return

	entity harvester = ent//CreateMaterialHarvester( HARVESTER_MODEL, origin, angles, 6, 15000, false )
	harvester.SetCanBeMeleed( false )

	//DispatchSpawn( harvester )
	harvester.SetFadeDistance( 15000 )
	harvester.SetScriptName( HARVESTER_SCRIPTNAME )

	harvester.SetUsable()
	harvester.AddUsableValue( USABLE_CUSTOM_HINTS )
	AddCallback_OnUseEntity_ClientServer( harvester, HarvestCraftingMaterials )
	SetCallback_CanUseEntityCallback( harvester, Crafting_Harvester_IsNotBusy )
	//harvester.Hide()

	file.harvesterArray.append( harvester )
	return
	/*entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", harvester.GetOrigin() )
	minimapObj.SetAngles( <0, 0, 0> )
	minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.CRAFTING_HARVESTER )
	minimapObj.Minimap_SetObjectScale( 1 )
	minimapObj.SetScriptName( HARVESTER_MINIMAP_SCRIPTNAME )
	minimapObj.SetParent( harvester )
	minimapObj.Minimap_SetAlignUpright( true )
	SetTargetName( minimapObj, "craftingHarvesterIcon" )
	minimapObj.Minimap_AlwaysShow( TEAM_UNASSIGNED, null )
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	minimapObj.DisableHibernation()


	file.minimapObjTable[harvester] <- minimapObj*/

	#if DEVELOPER
		DEV_Crafting_Print( format( "OnHarvesterScriptTargetSpawned():  %s", string( harvester ) ))
	#endif

	foreach( link in links )
		harvester.LinkToEnt( link )
	foreach( rent in parentLinks )
		rent.LinkToEnt( harvester )

	if ( IsValid( par ) )
		harvester.SetParent( par )
}
#endif

#if CLIENT
void function OnHarvesterCreated( entity target )
{
	if ( !file.isEnabled )
	{
		return
	}

	if ( target.GetScriptName() != "crafting_harvester" )
		return

	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		target.Destroy()
		return
	}

	#if DEVELOPER
	DEV_Crafting_Print( format( "OnHarvesterCreated():  %s", string( target ) ))
	#endif

	EHI harvesterEHI = ToEHI( target )
	file.harvesterTableLocal[ harvesterEHI ] <- target

	//create fake harvester for proxies
	vector origin = target.GetOrigin()
	vector angles = target.GetAngles()
	entity fakeHarvester = CreatePropDynamic( HARVESTER_MODEL, origin, angles)
	fakeHarvester.SetFadeDistance( 15000 )
	fakeHarvester.SetForceVisibleInPhaseShift( true )
	file.harvesterToClientProxy[target] <- fakeHarvester

	entity ambGen = CreateClientSideAmbientGeneric( target.GetOrigin(), HARVESTER_AMBIENT_LOOP, 3000 )
	ambGen.SetParent( target )
	ambGen.SetLocalOrigin( <0, 0, 60> )
	file.ambGenericTable[target] <- ambGen

	CreateHarvesterWorldIcon( target )

	if( !PlayerHasUsedHarvester( GetLocalViewPlayer(), target ) )
	{
		CL_SetHarvesterState( target, eHarvesterState.FULL )

		AddCallback_OnUseEntity_ClientServer( target, HarvestCraftingMaterials )
		SetCallback_CanUseEntityCallback( target, Crafting_Harvester_IsNotBusy )
		AddEntityCallback_GetUseEntOverrideText( target, Crafting_Harvester_UseTextOverride )
	}
	else
	{
		CL_SetHarvesterState( target, eHarvesterState.EMPTY )
		entity minimapObj = null
		foreach ( entity child in target.GetChildren() )
		{
			if ( child.GetScriptName() == HARVESTER_MINIMAP_SCRIPTNAME )
			{
				minimapObj = child
				break
			}
		}

		bool success = SetMapIconsAsUsed( target, minimapObj )
		//In some cases, the RUI table isn't built yet, as it's created by another spawn callbacks
		//so this logic just let's us try again next frame, which should fix it.
		if ( !success )
		{
			thread SetMapIconStateRetry_Thread( target, minimapObj )
		}
	}
}

void function SetMapIconStateRetry_Thread( entity harvester, entity minimapObj )
{
	EndSignal( harvester, "OnDestroy", "HarvesterDisabled" )
	EndSignal( minimapObj, "OnDestroy" )
	for( int i = 0; i < 10; i++ )
	{
		WaitFrame()

		if ( SetMapIconsAsUsed( harvester, minimapObj ) )
			return
	}
}

void function CL_SetHarvesterState( entity harvester, int harvesterState )
{
	if( !IsValid( harvester ) )
		return

	entity fakeHarvester = file.harvesterToClientProxy[ harvester ]
	entity ambGen = file.ambGenericTable[ harvester ]

	if( !IsValid( fakeHarvester ) )
		return

	switch( harvesterState )
	{
		case eHarvesterState.EMPTY:
			fakeHarvester.Anim_Stop()
			fakeHarvester.Anim_Play( HARVESTER_EMPTY_IDLE_ANIM )
			fakeHarvester.kv.intensity = 0.1
			if( IsValid( ambGen ) )
			{
				ambGen.SetEnabled( false )
			}
			break
		case eHarvesterState.FULL:
			thread PlayHarvesterIdleFX( fakeHarvester )
			fakeHarvester.Anim_Stop()
			fakeHarvester.Anim_Play( HARVESTER_FULL_IDLE_ANIM )
			fakeHarvester.kv.intensity = 1.0
			if( IsValid( ambGen ) )
			{
				ambGen.SetEnabled( true )
			}
			break
		default:
			break
	}
}

void function OnHarvesterDestroyed( entity target )
{
	#if DEVELOPER
		DEV_Crafting_Print( format( "OnHarvesterDestroyed():  %s", string( target ) ))
	#endif

	if ( !( target in file.harvesterRuiTable ) )
		return

	RuiDestroy( file.harvesterRuiTable[target] )
	delete file.harvesterRuiTable[target]

	if (( target in file.harvesterToClientProxy ) && IsValid( file.harvesterToClientProxy[target] ) )
	{
		file.harvesterToClientProxy[target].Destroy()
		delete file.harvesterToClientProxy[target]
	}

	if (( target in file.ambGenericTable ) && IsValid( file.ambGenericTable[target] ))
	{
		file.ambGenericTable[target].Destroy()
		delete file.ambGenericTable[target]
	}
}

void function PlayHarvesterIdleFX( entity harvester )
{
	if( !IsValid( harvester ) )
		return

	//This is to prevent multiple instances of FX stacking up
	Signal( harvester, "HarvesterStopFX" )

	EndSignal( harvester, "OnDestroy", "HarvesterDisabled", "HarvesterStopFX" )

	int attachId = harvester.LookupAttachment( "FX_INSIDE" )
	int idleFx = StartParticleEffectOnEntity( harvester, GetParticleSystemIndex( HARVESTER_IDLE_FX ), FX_PATTACH_POINT_FOLLOW, attachId )

	OnThreadEnd(
		function() : ( idleFx )
		{
			if ( IsValid( idleFx ) )
			{
				EffectStop( idleFx, false, true )
			}
		}
	)

	WaitForever()
}

string function Crafting_Harvester_UseTextOverride( entity ent )
{
	entity player = GetLocalViewPlayer()

	CustomUsePrompt_Show( ent )
	CustomUsePrompt_SetSourcePos( ent.GetOrigin() + < 0, 0, 30 > )

	//CustomUsePrompt_SetAdditionalText( "%ping% " + Localize( "#COMMS_PING" ) ) //removing for 14.1 due to shared crafting materials removing the need for pinging harvestors for teammates
	CustomUsePrompt_SetText( Localize("#CRAFTING_HARVESTER_USE_PROMPT") )
	CustomUsePrompt_SetLineColor( GetCraftingColor() )
	CustomUsePrompt_SetHintImage( CRAFTING_CURRENCY_ASSET )
	CustomUsePrompt_SetShouldCenterImage( true )

	if ( PlayerIsInADS( player ) )
		CustomUsePrompt_ShowSourcePos( false )
	else
		CustomUsePrompt_ShowSourcePos( true )

	return ""
}
#endif

bool function PlayerHasUsedHarvester( entity player, entity harvester )
{
	if( !IsValid( harvester ) )
		return false

	if( !IsValid( player ) || !player.IsPlayer() )
		return false

	int indexToCheck = 0
	if ( file.harvestersTeamUse )
	{
		indexToCheck = player.GetTeam()
	}
	else
	{
		indexToCheck = EHIToEncodedEHandle( ToEHI( player ) )
		//the first player is index 1
		indexToCheck--
	}

	return false //GetUseStateByIndex not in S3
}

#if SERVER
//Can only sets this on the server
void function SetHarvesterAsUsedByPlayer( entity player, entity harvester )
{
	if( !IsValid( harvester ) )
		return

	if( !IsValid( player ) || !player.IsPlayer() )
		return

	int indexToSet = 0
	if ( file.harvestersTeamUse )
	{
		indexToSet = player.GetTeam()
	}
	else
	{
		indexToSet = EHIToEncodedEHandle( ToEHI( player ) )
		//the first player is index 1
		indexToSet--
	}

	//harvester.SetUseStateByIndex( indexToSet, true ) //not in S3
}
#endif

///// HARVESTER USE FUNCTIONS /////
void function HarvestCraftingMaterials( entity harvester, entity player, int pickupFlags )
{
	#if SERVER
		if( !IsValid( harvester ) )
			return

		if( !IsValid( player ) )
			return

		if( file.harvestersTeamUse )
		{
			// Say "Got Materials" line from Arenas.
			thread PlayBattleChatterLineDelayedToSpeakerAndTeamWithDebounceTime_Thread( player, "bc_arenasMatsPickedUp", 0.80, 5.0, 5.0 )

			foreach( squadMember in GetPlayerArrayOfTeam( player.GetTeam() ) )
			{
				HarvestCraftingMaterials_Single( harvester, squadMember, player, pickupFlags )
			}
		}
		else
		{
			HarvestCraftingMaterials_Single( harvester, player, player, pickupFlags )
		}
	#endif
}

#if SERVER
void function HarvestCraftingMaterials_Single( entity harvester, entity player, entity playerInteractor, int pickupFlags )
{
	Assert( IsValid( harvester ) )
	Assert( IsValid( player ) )

	if ( player == playerInteractor )
	{
		SetHarvesterAsUsedByPlayer( player, harvester )
	}

//	Remote_CallFunction_Replay( player, "ServerCallback_CL_HarvesterUsed", harvester, file.minimapObjTable[harvester] )

	Crafting_AddMaterialsToPlayer( player, playerInteractor, HARVESTER_TEAMMATE_REWARD  )
	if(( player == playerInteractor ) && ( Stats_ShouldGatherBRStatsInModeForPlayer( player ) )) //This is tied up to a challenge so needs to be checked.
	{
		StatsHook_HarvesterExtracted( player )
	}

	if ( player == playerInteractor )
	{
		printf( format( "CRAFTING: Material harvest success for interactor %s at Harvester %s", string( player ), string( harvester )  ))
		EmitSoundOnEntityOnlyToPlayer( harvester, player, HARVESTER_COLLECT_1P )
		EmitSoundOnEntityExceptToPlayer( harvester, player, HARVESTER_COLLECT_3P )
		Harvester_GetNextStepForPlayer( harvester, player )
	}
	else
	{
		printf( format( "CRAFTING: Material harvest for teammate %s at Harvester %s", string( player ), string( harvester )  ))
		EmitSoundOnEntityOnlyToPlayer( player, player, HARVESTER_COLLECT_TEAM )
	}

	PIN_Interact( player, "crafting_harvester_used", harvester.GetOrigin() )
}
#endif

#if CLIENT
void function Crafting_OnSpectateTargetChanged( entity spectatingPlayer, entity oldSpectatorTarget, entity newSpectatorTarget )
{
	#if DEVELOPER
		DEV_Crafting_Print( format( " ********** Refreshing Local Harvesters"))
	#endif

	entity player = GetLocalViewPlayer()

	#if DEVELOPER
		DEV_Crafting_Print( format( "*** SPECTATOR: ServerCallback_RefreshLocalHarvesters: "))
		DEV_Crafting_Print( format( "*** SPECTATOR: Player == %s", string( player ) ))
		EHI playerEHI = ToEHI( player )
		if( playerEHI in file.usedHarvesterEHIs )
		{
			DEV_Crafting_Print( format( "*** SPECTATOR: Local file.usedHarvesterEHIs.len() == %s", string( file.usedHarvesterEHIs[ playerEHI ].len()) ))
		}
	#endif

	foreach( harvesterEHI, harvester in file.harvesterTableLocal )
	{
		if( IsValid( harvester ) )
		{
			entity fakeHarvester = file.harvesterToClientProxy[ harvester ]

			if( IsValid( fakeHarvester ) )
			{
				if( PlayerHasUsedHarvester( player, harvester )  )
				{
					CL_SetHarvesterState( harvester, eHarvesterState.EMPTY )
				}
				else
				{
					CL_SetHarvesterState( harvester, eHarvesterState.FULL )
				}
			}
		}
	}

	if ( file.craftingBetterSpectatorEnabled && GetLocalClientPlayer() != GetLocalViewPlayer() )
	{
		Signal(GetLocalClientPlayer(), "crafting_kill_spectator_thread")
		Crafting_Workbench_CloseCraftingMenu()

		if ( Crafting_IsPlayerAtWorkbench( newSpectatorTarget ) )
		{
			Crafting_Workbench_OpenCraftingMenu( newSpectatorTarget.GetLinkParent() )
		}
	}
}

void function Crafting_OnFirstPersonSpectateStarted( entity spectatingPlayer, entity spectateTarget )
{
	if ( file.craftingBetterSpectatorEnabled )
	{
		if ( Crafting_IsPlayerAtWorkbench( spectateTarget ) )
		{
			Crafting_Workbench_OpenCraftingMenuAsSpectator( spectateTarget.GetLinkParent() )
		}
	}
}

void function Crafting_OnFirstPersonSpectateEnded( entity  spectatingPlayer, entity spectateTarget )
{
	if ( file.craftingBetterSpectatorEnabled )
	{
		Crafting_Workbench_CloseCraftingMenu()
	}
}

void function HarvesterAnimThread( entity harvesterProxy, bool doEmptyingAnim = true )
{
	if( !IsValid( harvesterProxy ) )
		return

	harvesterProxy.Anim_Stop()

	string animName = HARVESTER_FULL_TO_EMPTY_ANIM
	float waitTime = 2

	if( !doEmptyingAnim )
	{
		animName = HARVESTER_EMPTY_IDLE_ANIM
		waitTime = 0.1
	}

	if( !UpgradeCore_UseUpdatedHarvesterModel() )
	{
		harvesterProxy.Anim_Play( animName )

		wait waitTime

		if ( IsValid( harvesterProxy ) )
		{
			harvesterProxy.Anim_Stop()
		}
	}
	else
	{
		harvesterProxy.Anim_Play( EVO_HARVESTER_FULL_TO_EMPTY_ANIM )

		wait waitTime

		if ( IsValid( harvesterProxy ) )
		{
			harvesterProxy.Anim_Stop()
		}
	}
}
#endif

#if SERVER
void function Harvester_GetNextStepForPlayer( entity harvester, entity player )
{
	if( !IsValid( harvester ) )
		return

	if( !IsValid( player ) )
		return

	//find linked workbench
	entity workbench = harvester.GetLinkParent()
	if ( workbench == null )
	{
		Warning( "CRAFTING: Trying to find connected Workbench for harvester but unable to find link" )
		return
	}

	//try to find any other unused harvester for this workbench for this player
	entity nextHarvester = null
	foreach ( possibleHarvester in workbench.GetLinkEntArray() )
	{
		if ( IsValidPlayer( possibleHarvester ) )
			continue

		if ( possibleHarvester.GetScriptName() != HARVESTER_SCRIPTNAME )
			continue

		if ( player.GetLinkParentArray().contains( possibleHarvester ) )
			continue

		// See whether a player has used a harvester.
		if( PlayerHasUsedHarvester( player,  possibleHarvester ))
			continue

		nextHarvester = possibleHarvester
		break
		//
	}

	//send contextual prompt for next harvester if one is found
	if ( nextHarvester != null )
	{
		StoreNextGoalForPlayer( player, nextHarvester )
		Remote_CallFunction_NonReplay( player, "ServerCallback_PromptNextHarvester", player, nextHarvester )
		return
	}

	//if not found, send contextual prompt for workbench - the player must have used all harvesters for this bench
	StoreNextGoalForPlayer( player, workbench )
	Remote_CallFunction_NonReplay( player, "ServerCallback_PromptWorkbench", player, workbench )
}

void function StoreNextGoalForPlayer( entity player, entity nextStep )
{
	if ( player in file.playerToNextStepTable )
	{
		file.playerToNextStepTable[player] = nextStep
	}
	else
	{
		file.playerToNextStepTable[player] <- nextStep
	}
}

void function PingNextGoalForPlayer( entity player, int commsAction, entity subjectEnt )
{
	entity nextStep = null
	if ( player in file.playerToNextStepTable )
		nextStep = file.playerToNextStepTable[player]

	if ( nextStep != null )
	{
		Remote_CallFunction_NonReplay( player, "MarkNextStepForPlayer", nextStep )
	}
	else
	{
		Warning( "CRAFTING: Next Step Not Found, cannot ping" )
	}
}

void function PingAllWorkbenches( entity player, int commsAction, entity subjectEnt )
{
	Remote_CallFunction_NonReplay( player, "MarkAllWorkbenches" )
}

void function Crafting_ClearUseLinksForAllHarvesters()
{
	foreach ( harvester in file.harvesterArray )
		ClearUseLinksForHarvester( harvester )
}

void function ClearUseLinksForHarvester( entity harvester )
{
	if( !IsValid( harvester ) )
		return

	foreach ( linkedEnt in harvester.GetLinkEntArray() )
		harvester.UnlinkFromEnt( linkedEnt )
}

void function ClearUseLinksForPlayer( entity player )
{
	if ( !IsValidPlayer( player ) )
		return

	foreach ( linkedEnt in player.GetLinkParentArray() )
	{
		if ( linkedEnt.GetScriptName() == HARVESTER_SCRIPTNAME )
			linkedEnt.UnlinkFromEnt( player )
	}
}

bool function Crafting_GetUseStatusForWorkbench()
{
	return file.workbenchArray[0].GetLinkEntArray().len() == 1
}
#endif // SERVER

bool function Crafting_Harvester_IsNotBusy( entity player, entity ent, int useFlags )
{
	#if CLIENT
	if( GetLocalClientPlayer() != GetLocalViewPlayer() )
		return false
	#endif // CLIENT

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( player.ContextAction_IsActive() )
		return false

	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return false

	//players that have used the harvester cannot use it again.
	if ( PlayerHasUsedHarvester( player, ent ) )
		return false

	return true
}

#if CLIENT
void function ServerCallback_CL_HarvesterUsed( entity harvester, entity minimapObj )
{
	if( !IsValid( harvester ) )
		return

	#if DEVELOPER
		DEV_Crafting_Print( format( "ServerCallback_CL_HarvesterUsed():  %s", string( harvester ) ))
	#endif

	file.ambGenericTable[harvester].SetEnabled( false )
	thread HarvesterAnimThread( file.harvesterToClientProxy[harvester] )
	thread PROTO_FadeModelIntensityOverTime( file.harvesterToClientProxy[harvester], 1, 1, 0.1 )

	Signal( file.harvesterToClientProxy[harvester], "HarvesterDisabled" )
	Signal( harvester, "HarvesterDisabled" )

	SetMapIconsAsUsed( harvester, minimapObj )
}

bool function SetMapIconsAsUsed( entity harvester, entity minimapObj )
{
	if ( IsValid(harvester) && (harvester in file.harvesterRuiTable) && (file.harvesterRuiTable[harvester] != null) )
	{
		RuiDestroyIfAlive( file.harvesterRuiTable[harvester] )
		delete file.harvesterRuiTable[harvester]
	}

	bool setMap = false
	if ( IsValid(minimapObj) && (minimapObj in file.harvesterFullmapRuiTable) && (minimapObj in file.harvesterMinimapRuiTable) )
	{
		//RuiSetBool( file.harvesterRuiTable[harvester], "enabled", false )
		RuiSetFloat3( file.harvesterFullmapRuiTable[minimapObj], "iconColor", <0,0,0> )
		RuiSetFloat3( file.harvesterMinimapRuiTable[minimapObj], "iconColor", <0,0,0> )
		setMap = true
	}

	return setMap
}

void function ServerCallback_CL_MaterialsChanged( int amount, int difference, int campIndex, entity giver, bool selfOnly )
{
		if ( Crafting_IsDispenserCraftingEnabled() )
			return

	if ( file.fullmapRui.len() != 0 && file.fullmapRui[0] != null )
		RuiSetInt( file.fullmapRui[0], "craftingMaterials", amount )

	string headerText = WILDLIFE_REWARD_STRINGS[ campIndex ]
	string header
	string milesAlias
	if (headerText != "")
	{
		header = Localize(headerText).toupper() + "\n"
		if (headerText.find("CAMP_REWARD") >= 0)
			milesAlias = "UI_TropicsAI_AreaCompletionStinger"
	}

	if ( difference > 0 )
	{
		if( GetLocalViewPlayer() == giver )
		{
			if ( selfOnly )
			{
				AnnouncementMessageRight( GetLocalViewPlayer(), header + Localize( "#CRAFTING_HARVESTER_AWARD", difference ), "", <214, 214, 214>, $"", 2, milesAlias )
			}
			else
			{
				AnnouncementMessageRight( GetLocalViewPlayer(), header + Localize( "#CRAFTING_HARVESTER_AWARD_TEAMUSE", difference ), "", <214, 214, 214>, $"", 2, milesAlias )
			}
		}
		else
		{
			AnnouncementMessageRight( GetLocalViewPlayer(), header + Localize( "#CRAFTING_HARVESTER_AWARD_TEAMMATES", giver.GetPlayerName(), difference ), "", <214, 214, 214>, $"", 2, milesAlias )
		}
	}
	else
	{
		AnnouncementMessageRight( GetLocalViewPlayer(), header + Localize( "#CRAFTING_HARVESTER_BALANCE_UPDATE", amount ), "", <214, 214, 214>, $"", 2, milesAlias )
	}

	// Update the Materials count in the Crafting Menu if player is in crafting.
	RefreshCraftingMenu()
}

// Update the Crafting Menu's Materials if the Player is crafting.
void function RefreshCraftingMenu()
{
	if ( !Crafting_IsPlayerAtWorkbench( GetLocalViewPlayer() ) )
		return

	CommsMenu_RefreshData()

	Update_CraftingItems_Availabilities()
}

void function ServerCallback_CL_ArmorDeposited()
{
	thread CLArmorDepositThread()
}

void function CLArmorDepositThread()
{
	GetLocalViewPlayer().EndSignal( "OnDeath" )
	GetLocalViewPlayer().EndSignal( "OnDestroy" )

	wait 3.0
	AnnouncementMessageRight( GetLocalViewPlayer(), Localize( "#CRAFTING_WORKBENCH_ARMOR_DEPOSIT" ), "", <214,214,214>, $"", 3, "Crafting_MaterialsGathered_1P" )
}

void function CreateHarvesterWorldIcon( entity harvester )
{
	if( !IsValid( harvester ) )
		return

	entity localViewPlayer = GetLocalViewPlayer()
	vector pos             = harvester.GetOrigin() + (harvester.GetUpVector() * 50)
	var rui                = CreateCockpitRui( $"ui/survey_beacon_marker_icon.rpak", RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), pos ) )
	RuiSetImage( rui, "beaconImage", CRAFTING_CURRENCY_ASSET )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", pos )
	RuiSetFloat( rui, "sizeMin", 24 )
	RuiSetFloat( rui, "sizeMax", 40 )
	RuiSetFloat( rui, "minAlphaDist", 1000 )
	RuiSetFloat( rui, "maxAlphaDist", 3000 )
	RuiSetBool( rui, "shouldHideNearCrosshairs", true )
	RuiKeepSortKeyUpdated( rui, true, "pos" )
	file.harvesterRuiTable[harvester] <- rui
}

void function ServerCallback_Crafting_Notify_Player_On_Obit( entity notifyingPlayer, int notifyType, int cost, int itemIndex, int evoTier )
{
	if( !file.crafting_obit_notify )
		return

	if( !IsValid( notifyingPlayer ) || !notifyingPlayer.IsPlayer())
		return

	if(( notifyType < 0 ) || ( notifyType >= eCrafting_Obit_NotifyType.COUNT_ ))
		return

	// Grab the item and validItems list via itemIndex.
	CraftingCategory ornull item = GetCategoryForIndex( itemIndex )
	if ( item == null )
		return
	expect CraftingCategory( item )

	string itemCategory = item.category
	array<string> validItems = Crafting_GetLootDataFromIndex( itemIndex, notifyingPlayer )

	// Resolve item name.
	array< string > obit_SpecialCategories = [
		"evo",

			"banner"

	]

	if( obit_SpecialCategories.contains( itemCategory ) )
	{
		Crafting_Obit_Notify_Single( notifyingPlayer, notifyType, cost, itemCategory, evoTier )
	}
	else
	{
		int numValidItems = validItems.len()
		if( numValidItems > 0 )
		{
			// Output Crafting Obit for each item in list. Don't show  dupes.
			array< string > prevItems = []
			for ( int i = numValidItems - 1; i >= 0; i-- )
			{
				// Don't show duplicates.
				if( !( prevItems.contains( validItems[i] )))
				{
					Crafting_Obit_Notify_Single( notifyingPlayer, notifyType, cost, validItems[i] )
					prevItems.append( validItems[i] )
				}
			}
		}
	}
}

void function Crafting_Obit_Notify_Single( entity notifyingPlayer, int notifyType, int mats, string itemRef, int evoTier = -1 )
{
	if( !IsValid( notifyingPlayer ) || !notifyingPlayer.IsPlayer())
		return

	string notifierName = notifyingPlayer.GetPlayerName()
	if( notifierName == "" )
		return

	if(( notifyType < 0 ) || ( notifyType > eCrafting_Obit_NotifyType.COUNT_ ))
		return

	string itemName = ""
	vector itemColor = < 255, 255, 255 >

	if ( itemRef == "evo" )
	{
		itemName = Localize( "#CRAFTING_ITEM_EVO" )
		LootData existingArmorData = EquipmentSlot_GetEquippedLootDataForSlot( notifyingPlayer, "armor" )

		if( evoTier >= 0 )
		{
			itemColor = GetKeyColor( COLORID_TEXT_LOOT_TIER0, evoTier )
		}
	}


	else if( itemRef == "banner" )
	{
		itemName = Localize( "#CRAFTING_ITEM_BANNER" )
	}

	else if ( SURVIVAL_Loot_IsRefValid( itemRef ) )
	{
		LootData lootData = SURVIVAL_Loot_GetLootDataByRef( itemRef )
		itemName = Localize( lootData.pickupString )
		itemColor = GetKeyColor( COLORID_TEXT_LOOT_TIER0, SURVIVAL_Loot_GetLootDataByRef( itemRef ).tier )
	}

	vector playerColor = GetKeyColor( COLORID_MEMBER_COLOR0, notifyingPlayer.GetTeamMemberIndex())

	if( itemName != "" )
	{
		switch( notifyType )
		{
			case eCrafting_Obit_NotifyType.IS_REQUESTING_MATERIALS:
				Obituary_Print_Localized( Localize( "#CRAFTING_REQUEST_MATS_TO_CRAFT_ITEM", notifierName, mats, itemName ), playerColor, itemColor )
				break
			case eCrafting_Obit_NotifyType.IS_CRAFTING_ITEM:
				Obituary_Print_Localized( Localize( "#CRAFTING_PLAYER_IS_CRAFTING_ITEM", notifierName, itemName ), playerColor, itemColor )
				break
			case eCrafting_Obit_NotifyType.SUBSEQUENT_ITEM:
				Obituary_Print_Localized( Localize( "#CRAFTING_SUBSEQUENT_ITEM", itemName ))
				break
			default:
				break
		}
	}
}


#endif // CLIENT

///// CRAFTING MANAGEMENT /////
#if SERVER
void function Crafting_OnLootbinOpen( entity player, entity lootbin, array<entity> regularLootEnts, array<entity> secretLootEnts, void functionref( bool, bool ) preventLootRevealFun )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	if ( IsValidPlayer( player ) && !lootbin.e.hasBeenOpened )
	{
		Crafting_AddMaterialsToPlayer( player, player, CRAFTING_PASSIVE_REWARD, eWildLifeCampType.UNKNOWN, true )
	}
}


void function Crafting_OnNPCKill (entity npc, var damageInfo, int npcType)
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	entity player = DamageInfo_GetAttacker(damageInfo)

	if (npcType in file.npcCraftingRewardTable)
	{
		if (IsValidPlayer ( player ) && file.npcCraftingRewardTable[npcType] > 0)
		{
			Crafting_AddMaterialsToPlayer( player, player, file.npcCraftingRewardTable[npcType], eWildLifeCampType.UNKNOWN, true )
		}
	}
}

void function Crafting_RewardOnWildlifeCampComplete ( array<entity> playersToReward, int campType, int rewardAmount, float rewardDelay )
{
	wait rewardDelay

	array<entity> validPlayersToReward = []

	foreach ( entity player in playersToReward )
	{
		if ( IsValidPlayer( player ) )
			validPlayersToReward.append( player )
	}

	if ( validPlayersToReward.len() == 0 )
		return

	int rewardPerSquadmate = rewardAmount / validPlayersToReward.len()
	foreach ( entity player in validPlayersToReward )
	{
		Crafting_AddMaterialsToPlayer( player, player, rewardPerSquadmate, campType, true )
	}
}


void function AddCallback_OnCraftingMaterialsGranted( OnCraftingMaterialsGrantedCallback callback )
{
	Assert( !file.craftingMatsGrantedCallbacks.contains( callback ), "Already added " + string( callback ) + " with AddCallback_OnCraftingMaterialsGranted" )
	file.craftingMatsGrantedCallbacks.append( callback )
}

void function Crafting_AddMaterialsToPlayer( entity player, entity giver, int amount, int campIndex = eWildLifeCampType.UNKNOWN, bool selfOnly = false )
{
	if( !Crafting_PlaylistVar_IsEnabled())
		return

	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	int oldMaterials = player.GetPlayerNetInt( "craftingMaterials" )





	player.SetPlayerNetInt( "craftingMaterials", oldMaterials + amount )

	if ( player != giver )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CL_MaterialsChanged", oldMaterials + amount, amount, campIndex, giver, false )

		// The Thanks prompt is delayed so the material finder can mark more materials before possibly responding to teammates' thanks.
		if( IsAlive( player ) )
			thread DoDelayedThanks( player, giver )
	}
	else
		Remote_CallFunction_NonReplay( player, "ServerCallback_CL_MaterialsChanged", oldMaterials + amount, amount, campIndex, player, selfOnly )

	foreach( callback in file.craftingMatsGrantedCallbacks )
	{
		callback( player, giver, amount )
	}

	if( player == giver )
	{
		if ( !Stats_ShouldGatherBRStatsInModeForPlayer( player ) ) //This is tied up to a challenge so needs to be checked.
			return

		StatsHook_CraftingMaterialsCollected( player, amount )
	}
}

void function DoDelayedThanks( entity player, entity playerToThank, float delay = 2.5 )
{
	wait delay
	if( IsValid( player ) )
		Remote_CallFunction_NonReplay( player, "ServerCallback_PromptSayThanks", playerToThank )
}

//if too many are removed, reset to 0 so player never has negative materials
void function Crafting_RemoveMaterialsFromPlayer( entity player, int amount )
{
	if( !Crafting_PlaylistVar_IsEnabled())
		return

	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	int oldMaterials = player.GetPlayerNetInt( "craftingMaterials" )
	int newMaterials = oldMaterials - amount

	if ( newMaterials < 0 )
		newMaterials = 0

	player.SetPlayerNetInt( "craftingMaterials", newMaterials )

	Remote_CallFunction_NonReplay( player, "ServerCallback_CL_MaterialsChanged", newMaterials, -1, eWildLifeCampType.UNKNOWN, player, true )
}

#endif

int function Crafting_GetPlayerCraftingMaterials( entity player )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		return 0

	if( !IsValid( player ) || !Crafting_IsEnabled() )
		return 0

	int playerMaterials = ( Crafting_PlaylistVar_IsEnabled() && file.isNetworkingRegistered ) ? player.GetPlayerNetInt( "craftingMaterials" ) : 0
	return playerMaterials
}

#if SERVER || CLIENT
bool function Crafting_IsPlayerAtWorkbench( entity player )
{
	if ( !IsValid( player ) )
		return false

	foreach( ent in player.GetLinkParentArray() )
	{
		if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
			return true
	}

	return false
}

asset function Crafting_GetCraftingIcon( bool isAirdrop )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		return isAirdrop ? DISPENSER_WORKBENCH_ICON_AIRDROP_ASSET : DISPENSER_WORKBENCH_ICON_ASSET
	}

	return isAirdrop ? WORKBENCH_ICON_AIRDROP_ASSET : WORKBENCH_ICON_ASSET
}

asset function Crafting_GetSmallCraftingIcon()
{
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		return DISPENSER_CRAFTING_SMALL_WORKBENCH_ASSET
	}

	return CRAFTING_SMALL_WORKBENCH_ASSET
}

asset function Crafting_GetCraftingZoneIcon()
{
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		return CRAFTING_2_ZONE_ASSET
	}

	return CRAFTING_ZONE_ASSET
}

#endif


///// CRAFTING WORKBENCHES /////
#if SERVER
void function OnWorkbenchScriptTargetSpawned( entity ent )
{
	vector origin = ent.GetOrigin()
	vector angles = ent.GetAngles()
	array<entity> links = ent.GetLinkEntArray()
	entity par = ent.GetParent()

	// Add to Possible Crafting Locations. Useful in many other features:
	// - POI Player Spawning.
	// - Free Respawns
	Crafting_PossibleWorkbenchLocations_Add( origin, angles )

	ent.Destroy()

	if ( !file.isEnabled )
		return

	entity workbench_cluster = CreatePropDynamic_NoDispatchSpawn( WORKBENCH_CLUSTER_MODEL, origin, angles, 6 )
	workbench_cluster.SetScriptName( WORKBENCH_CLUSTER_SCRIPTNAME )
	workbench_cluster.SetCanBeMeleed( false )

	if ( Crafting_IsDispenserCraftingEnabled() )
		workbench_cluster.SetSkin( 2 )

	AddCallback_GroundCheckOnPhysicsThrowCompleted( workbench_cluster, Workbench_OnLootGroundCheck )

	array<entity> workbenches
	array<WorkbenchData> benchDataList
	for ( int i = 1; i <= 3; i++ )
	{
		entity workbench       = CreatePropDynamic_NoDispatchSpawn( WORKBENCH_MODEL, workbench_cluster.GetOrigin(), workbench_cluster.GetAngles(), 6 )
		workbench.SetScriptName( WORKBENCH_SCRIPTNAME )
		workbench.SetCanBeMeleed( false )
		workbench.kv.CollisionGroup = TRACE_COLLISION_GROUP_NONE
		workbench.SetCollisionAllowed( false )

		workbench.SetFadeDistance( 15000 )
		workbenches.append( workbench )

		WorkbenchData benchData
		benchData.workbench = workbench
		benchData.cluster = workbench_cluster
		switch ( i )
		{
			case 2:
				benchData.doorAnimIndex = "A"
				benchData.lootAttachmentIndex = "C"
				break
			case 3:
				benchData.doorAnimIndex = "B"
				benchData.lootAttachmentIndex = "L"
				break
			case 1:
				benchData.doorAnimIndex = "C"
				benchData.lootAttachmentIndex = "R"
				break
		}

		workbench.kv.targetname = benchData.doorAnimIndex
		DispatchSpawn( workbench )

		file.workbenchDataTable[workbench] <- benchData
		benchDataList.append( benchData )
	}

	file.workbenchClusterToBenchData[workbench_cluster] <- benchDataList

	foreach( workbench in workbenches )
		workbench_cluster.LinkToEnt( workbench )

	foreach( link in links )
		workbench_cluster.LinkToEnt( link )

	if ( IsValid( par ) )
	{
		workbench_cluster.SetParent( par )
		foreach ( bench in workbenches )
			bench.SetParent( par )
	}

	DispatchSpawn( workbench_cluster )
	workbench_cluster.SetFadeDistance( 15000 )

	thread PlayWorkbenchHologramFX( workbench_cluster )
	thread PlayWorkbenchEngineFX( workbench_cluster )

	//update workbench itneract locations
	int workbenchCounter = 1
	foreach( bench in workbenches )
	{
		int doorAttachment = workbench_cluster.LookupAttachment( "door_open_" + workbenchCounter )
		vector originToAttachment = workbench_cluster.GetAttachmentOrigin( doorAttachment ) - workbench_cluster.GetOrigin()
		vector workbenchOrigin = workbench_cluster.GetAttachmentOrigin( doorAttachment ) + (originToAttachment * 0.3)
		workbenchOrigin = <workbenchOrigin.x, workbenchOrigin.y, workbench_cluster.GetAttachmentOrigin( doorAttachment ).z - 20>
		vector workbenchAngles = workbench_cluster.GetAttachmentAngles( doorAttachment )
		bench.SetOrigin( workbenchOrigin )
		bench.SetAngles( workbenchAngles )

		workbenchCounter++
	}

	workbench_cluster.Anim_Play( WORKBENCH_IDLE_GROUND_ANIM )
}

void function Crafting_PossibleWorkbenchLocations_Add( vector origin, vector angles )
{
	Point newLoc
	newLoc.origin = origin
	newLoc.angles = angles
	file.workbenchPossibleLocations.append( newLoc )
}

array< Point > function Crafting_PossibleWorkbenchLocations_Get()
{
	return( file.workbenchPossibleLocations )
}

void function SetupWorkbenchClusterFromTarget( entity target )
{
	if ( target.GetScriptName() != WORKBENCH_CLUSTER_SCRIPTNAME )
		return

	if ( !file.isEnabled )
	{
		foreach( ent in target.GetLinkEntArray() )
		{
			target.UnlinkFromEnt( ent )
			ent.Destroy()
		}

		target.Destroy()
		return
	}

	entity ambGen = CreateEntity( "ambient_generic" )
	ambGen.SetOrigin( target.GetOrigin() )
	ambGen.SetSoundName( WORKBENCH_AMBIENT_LOOP )
	ambGen.SetEnabled( true )
	ambGen.SetParent( target )
	ambGen.SetLocalOrigin( <0, 0, 60> )
	DispatchSpawn( ambGen )

	file.ambGenericTable[target] <- ambGen

	//minimap obj for small Icon
	entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", target.GetOrigin() )
	minimapObj.Minimap_SetCustomState( IsLimitedStockWorkbench(target) ? eMinimapObject_prop_script.CRAFTING_WORKBENCH_LIMITED : eMinimapObject_prop_script.CRAFTING_WORKBENCH )
	minimapObj.Minimap_SetObjectScale( 1 )
	minimapObj.SetParent( target )
	minimapObj.Minimap_SetAlignUpright( true )
	SetTargetName( minimapObj, target.GetModelName() == WORKBENCH_CLUSTER_AIRDROP_MODEL ? "craftingWorkbenchAirdropIcon" : "craftingWorkbenchIcon" )
	minimapObj.Minimap_AlwaysShow( TEAM_UNASSIGNED, null )
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	minimapObj.DisableHibernation()

	file.minimapObjTable[target] <- minimapObj

	foreach( ent in target.GetLinkEntArray() )
	{
		SetupWorkbenchFromTarget( ent )
	}

	file.workbenchClusterArray.append( target )

	CreateAirdropBadPlace( target, target.GetOrigin(), 512 )
}

void function SetupWorkbenchFromTarget( entity target )
{
	if ( target.GetScriptName() != WORKBENCH_SCRIPTNAME )
		return

	target.SetUsable()
	target.AddUsableValue( USABLE_CUSTOM_HINTS )
	target.SetBoundingBox( <-4, -4, -12>, <4, 4, 12> )
	target.SetUsableDistanceOverride( 35 )
	target.SetUsableFOVByDegrees( 250.0 )
	AddCallback_OnUseEntity_ClientServer( target, UseCraftingWorkbench )
	SetCallback_CanUseEntityCallback( target, Crafting_Workbench_IsNotBusy )

	file.workbenchArray.append( target )
}

void function Crafting_OnPlayerConnectionChanged( entity player )
{
	player.Signal( "CraftingPlayerDetachImmediate" )
}

void function PlayWorkbenchHologramFX( entity workbench )
{
	//Dont play FX if workbench is IsMarkedForDeletion
	if ( !IsValid(workbench) )
	{
		return
	}

	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	workbench.EndSignal( "OnDestroy" )

	//printt( "FX: Workbench Holo FX START")

	int attachId = workbench.LookupAttachment( "FX_LIGHT" )
	entity holoFx = StartParticleEffectOnEntityWithPos_ReturnEntity( workbench, GetParticleSystemIndex( WORKBENCH_HOLO_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachId, <0, 0, 0>, <-90, 0, 0> )

	OnThreadEnd(
		function() : ( holoFx )
		{
			if ( IsValid( holoFx ) )
			{
				//printt( "FX: Workbench Holo FX END")
				EffectStop( holoFx )
			}
		}
	)

	WaitForever()
}

void function PlayWorkbenchEngineFX( entity workbench )
{
	StartParticleEffectOnEntity( workbench, GetParticleSystemIndex( WORKBENCH_ENGINE_SMOKE_FX ), FX_PATTACH_POINT_FOLLOW, workbench.LookupAttachment( "thruster_fx_1" ) )
	StartParticleEffectOnEntity( workbench, GetParticleSystemIndex( WORKBENCH_ENGINE_SMOKE_FX ), FX_PATTACH_POINT_FOLLOW, workbench.LookupAttachment( "thruster_fx_2" ) )
	StartParticleEffectOnEntity( workbench, GetParticleSystemIndex( WORKBENCH_ENGINE_SMOKE_FX ), FX_PATTACH_POINT_FOLLOW, workbench.LookupAttachment( "thruster_fx_3" ) )
}

void function Crafting_WorkbenchAirdropLogic()
{
	if ( !GetCurrentPlaylistVarBool( "crafting_midgame_airdrop_enabled", true ) )
		return

	EndSignal( svGlobal.levelEnt, "RoundEnd" )
	string playlistVar = GetCurrentPlaylistVarString( "crafting_midgame_airdrop_stages", "1:2 2:1" )

	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		playlistVar = GetCurrentPlaylistVarString( "crafting_dispensers_airdrop_stages", "1:2 2:1 3:1" )

		if ( Crafting_DispenserReactivation_IsEnabled() )
		{
			playlistVar = GetCurrentPlaylistVarString( "crafting_dispensers_airdrop_stages", "2:1 3:1" )
		}
	}

	//parse airdropstages
	array<string> airdropStrings = GetTrimmedSplitString( playlistVar, " " )
	table<int, int> stageToAmountTable

	foreach( stage in airdropStrings )
	{
		array<string> tokens = GetTrimmedSplitString( stage, ":" )
		stageToAmountTable[int(tokens[0])-1] <- int(tokens[1])

		printf( "CRAFTING: Adding airdrop at stage " + (int(tokens[0]) - 1) + " with amount " + int(tokens[1]) )
	}

	FlagWait( "DeathCircleActive" )

	while ( true )
	{
		FlagWaitClear( "SUR_DeathFieldShrinking" )

		if ( SURVIVAL_GetCurrentDeathFieldStage() in stageToAmountTable )
		{
			int currentStage = SURVIVAL_GetCurrentDeathFieldStage()
			int dropCount = stageToAmountTable[ currentStage ]

			if ( !(currentStage in stageToAmountTable) )
				continue

			wait 15.0
			printf( "CRAFTING: Stage is " + currentStage + " airdropping " + dropCount + " benches"  )








			thread Crafting_WorkbenchAirdropLogicForRound_Thread( dropCount, false, currentStage )

			FlagWait( "SUR_DeathFieldShrinking" )
		} else {
			wait 0.1
			FlagWait( "SUR_DeathFieldShrinking" )
		}
	}
}

void function Crafting_WorkbenchAirdropLogicForRound_Thread( int dropCount, bool debugCrafters = false, int aidropStage = -1 )
{
	entity fakePod = CreatePropDynamic( SURVIVAL_LOOT_POD_MODEL )
	float dropDuration = fakePod.GetSequenceDuration( CARE_PACKAGE_ANIMATION )
	fakePod.Destroy()

	float baseAngle = RandomFloatForLoot( 360.0 )
	float angleAdjust = 360.0 / float( dropCount )

	int failedAirdrops = 0

	for(int i = 0; i < dropCount; i++ )
	{
		printf( "CRAFTING: Attempting to airdrop workbench" )
		//crafting workbench airdrop logic here
		vector center
		float radius
		#if DEVELOPER
			if ( debugCrafters )
			{
				DeathFieldStageData deathFieldStageData = GetDeathFieldStage( Survival_Loot_GetDefaultRealm(), aidropStage )
				center = deathFieldStageData.endPos
				radius = deathFieldStageData.endRadius * 0.75
			}
			else
		#endif // DEVELOPER
		{
			DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData( Survival_Loot_GetDefaultRealm() )
			center                 = deathFieldData.center
			radius                  = deathFieldData.endRadius * 0.75
		}


		int randomSeedIntForCircleCenter = -1
		if ( IsLockedLootActive() )
			randomSeedIntForCircleCenter = GetRandomSeedIntForLoot()

		float minDistance = REPLICATOR_AIRDROP_DISPLACEMENT
		if ( aidropStage > 1 ) //airdropStage is referring to what set of airdrops is occuring, NOT necessarily the round they are occuring at
			minDistance = GetCurrentPlaylistVarFloat( "crafting_airdrop_min_distance", 500.0 )

		array<vector> prevAirdrops
		prevAirdrops.extend( file.workbenchAirdropPositions )
		prevAirdrops.extend( Survival_GetPreviousAirdrops() )
		prevAirdrops.extend( UpgradeCore_GetPreviousDropLocations() )
		foreach( workbenchCluster in file.workbenchClusterArray )
			prevAirdrops.append( workbenchCluster.GetOrigin() )

		Point airdropPoint
		waitthread FindRandomAirdropDropPoint_Thread( airdropPoint, baseAngle, center, radius, prevAirdrops, false, DEFAULT_MAX_AIRDROP_SEARCH_RUNTIME, randomSeedIntForCircleCenter, minDistance )
		if ( ( airdropPoint.angles == <0,0,0> ) && ( airdropPoint.origin == <0,0,0> ) )
		{
			printf( "CRAFTING: Failed to find airdrop location" )
			failedAirdrops++
			continue //skip airdrop if we failed to find a location
		}

		#if DEVELOPER
			if ( debugCrafters )
			{
				//DebugDrawArrow( airdropPoint.origin + <0, 0, 7000>, airdropPoint.origin, 128, <255, 0, 0>, true, 100.0 )
				//DebugDrawCircle( airdropPoint.origin, <0,0,0>, 32, <255, 0, 0>, true, 100.0 )
			}
		#endif //DEVELOPER

		IssueAirdropPing( airdropPoint.origin, dropDuration + 8.0, eLootTier.NONE, eAirdropType.CRAFTING_REPLICATOR )

		PIN_AirdropAction ( "crafting_station", airdropPoint.origin )

		thread AirdropWorkbench_Thread( airdropPoint.origin, airdropPoint.angles, true, debugCrafters )
		file.workbenchAirdropPositions.append( airdropPoint.origin )

		baseAngle += angleAdjust
	}

	if ( failedAirdrops != dropCount ) // if all our airdrops fail, don't issue the commentary event
		AddSurvivalCommentaryEvent( eSurvivalEventType.REPLICATOR_AIRDROP_INCOMING )
}

void function AirdropWorkbench_Thread( vector origin, vector angles, bool animateDrop = true, bool saveEntity = false )
{
	printf( "CRAFTING: Location found, Airdropping Workbench" )
	entity dropPod = CreatePropDynamic_NoDispatchSpawn( WORKBENCH_CLUSTER_AIRDROP_MODEL, origin, angles, 6 )
	dropPod.SetScriptName( CARE_PACKAGE_SCRIPTNAME )
	dropPod.EnableRenderAlways()
	dropPod.DisableHibernation()
	dropPod.SetScriptName( WORKBENCH_CLUSTER_AIRDROPPED_SCRIPTNAME )
	SetTargetName( dropPod, "care_package" )

	if ( Crafting_IsDispenserCraftingEnabled() )
		dropPod.SetSkin( 2 )

	DispatchSpawn( dropPod )

	dropPod.SetAIObstacle( true )
	TeslaTrap_MakeEntityRealTimeObstructor( dropPod )
	MarkEntForCleanupOnRoundEnd( dropPod )

	#if DEVELOPER
		if ( saveEntity )
			DEV_AddAirdropEntity( dropPod )
	#endif // DEVELOPER

	dropPod.EndSignal( "OnDestroy" )

	int podFlags = 0
	dropPod.Solid()
	dropPod.DisallowZiplines()

	thread DropPodLocationMarker( dropPod, null, COLORID_AIRDROP_CRAFTING_COLOR, FX_AIRDROP_GROUND_MARKER_CRAFTING_CP )

	if ( Crafting_LocationBeam_Enabled() )
		thread DropPodLocationBeam( dropPod, null, COLORID_CRAFTING_DISPENSER )

	vector soundOrigin = dropPod.GetOrigin()
	EmitSoundAtPosition( TEAM_UNASSIGNED, soundOrigin, "Survival_LootPod_Beacon_Marker", dropPod )

	CreateAirdropBadPlace( dropPod, origin, 128 )

	OnThreadEnd(
		function() : ( soundOrigin )
		{
			// incase the droppod gets destroyed before it lands. Shouldn't happen but better safe ...
			StopSoundAtPosition( soundOrigin, "Survival_LootPod_Beacon_Marker" )
		}
	)

	if ( Time() > 30 )
		Leviathan_ConsiderLookAtEnt( dropPod, RandomFloatRange( 10, 16 ), 0.2 )

	if ( animateDrop )
	{
		waitthread AnimateAirdropPod( dropPod, origin, angles, "crafting_replicator_drop" )
		StopSoundAtPosition( soundOrigin, "Survival_LootPod_Beacon_Marker" )
		EmitSoundOnEntity( dropPod, "Survival_LootPod_SteamSizzle" )
	}

	//deploy workbench cluster here
	entity workbench_cluster = CreatePropDynamic_NoDispatchSpawn( WORKBENCH_CLUSTER_AIRDROP_MODEL, dropPod.GetOrigin(), dropPod.GetAngles(), 6 )
	workbench_cluster.SetScriptName( WORKBENCH_CLUSTER_SCRIPTNAME )
	workbench_cluster.SetCanBeMeleed( false )
	workbench_cluster.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT

	if ( Crafting_IsDispenserCraftingEnabled() )
		workbench_cluster.SetSkin( 2 )

	#if DEVELOPER
		if ( saveEntity )
			DEV_AddAirdropEntity( workbench_cluster )
	#endif // DEVELOPER

	AddCallback_GroundCheckOnPhysicsThrowCompleted( workbench_cluster, Workbench_OnLootGroundCheck )

	array<entity> workbenches
	array<WorkbenchData> benchDataList
	for ( int i = 1; i <= 3; i++ )
	{
		entity workbench       = CreatePropDynamic_NoDispatchSpawn( WORKBENCH_MODEL, workbench_cluster.GetOrigin(), workbench_cluster.GetAngles(), 6 )
		workbench.SetScriptName( WORKBENCH_SCRIPTNAME )
		workbench.SetCanBeMeleed( false )
		workbench.kv.CollisionGroup = TRACE_COLLISION_GROUP_NONE
		workbench.SetCollisionAllowed( false )

		workbench.SetFadeDistance( 15000 )
		workbenches.append( workbench )

		WorkbenchData benchData
		benchData.workbench = workbench
		switch ( i )
		{
			case 2:
				benchData.doorAnimIndex = "A"
				benchData.lootAttachmentIndex = "C"
				break
			case 3:
				benchData.doorAnimIndex = "B"
				benchData.lootAttachmentIndex = "L"
				break
			case 1:
				benchData.doorAnimIndex = "C"
				benchData.lootAttachmentIndex = "R"
				break
		}

		workbench.kv.targetname = benchData.doorAnimIndex
		DispatchSpawn( workbench )

		file.workbenchDataTable[workbench] <- benchData
		benchDataList.append( benchData )
	}

	file.workbenchClusterToBenchData[workbench_cluster] <- benchDataList

	foreach( workbench in workbenches )
		workbench_cluster.LinkToEnt( workbench )


	//SetupLimitedStockWorkbench( workbench_cluster )
	workbench_cluster.SetFadeDistance( 15000 )
	DispatchSpawn( workbench_cluster )
	workbench_cluster.Anim_Play( WORKBENCH_IDLE_ANIM )

	//update workbench interact locations
	int workbenchCounter = 1
	foreach( bench in workbenches )
	{
		int doorAttachment = workbench_cluster.LookupAttachment( "door_open_" + workbenchCounter )
		vector originToAttachment = workbench_cluster.GetAttachmentOrigin( doorAttachment ) - workbench_cluster.GetOrigin()
		vector workbenchOrigin = workbench_cluster.GetAttachmentOrigin( doorAttachment ) + (originToAttachment *0.3)
		workbenchOrigin = <workbenchOrigin.x, workbenchOrigin.y, workbench_cluster.GetAttachmentOrigin( doorAttachment ).z - 20>
		vector workbenchAngles = workbench_cluster.GetAttachmentAngles( doorAttachment )
		bench.SetOrigin( workbenchOrigin )
		bench.SetAngles( workbenchAngles )
		workbenchCounter++
	}

	thread PlayWorkbenchHologramFX( workbench_cluster )
	thread PlayWorkbenchEngineFX( workbench_cluster )

	dropPod.Destroy()
}

void function Crafting_AirdropWorkbenchAtPlayer( entity player )
{
	thread AirdropWorkbench_Thread( player.GetOrigin(), player.GetAngles() )
}


void function Workbench_OnLootGroundCheck( entity dropEnt, entity checkEnt )
{
	//fix case of loot sticking to Replicators
	if ( IsValid( dropEnt.GetParent() ) && dropEnt.GetParent() == checkEnt )
	{
		vector vel = ( dropEnt.GetOrigin() - dropEnt.GetParent().GetOrigin() ) * 1.5
		FakePhysicsThrow( null, dropEnt, vel, true )
	}
}

#if DEVELOPER
//bind t "script thread Crafting_ShowCraftingLocations()"
void function Crafting_ShowCraftingLocations( float lifetime = 5.0)
{
	array<entity> ReplicatorLocations = GetEntArrayByScriptName( "crafting_workbench" )
	array<entity> HarvestorLocations = GetEntArrayByScriptName( "crafting_harvester" )
	int ReplicatorCount = ReplicatorLocations.len()
	int HarvestorCount = HarvestorLocations.len()
	//float lifetime = 5.0
 	DEV_Crafting_Print( format( "Crafting Replicator Locations: %s", string( ReplicatorCount )))
	DEV_Crafting_Print( format( "Crafting Harvestor Locations: %s", string( ReplicatorCount )))

	foreach( location in ReplicatorLocations )
	{
		vector origin = location.GetOrigin()
		DebugDrawSphere( origin, 128, 255, 255, 0, true, lifetime )
		DebugDrawLine( origin, origin + <0,0,12000>, 255, 255, 0, true, lifetime )
		DEV_Crafting_Print( format( "Crafting Replicator Location: %s", string( origin )))

	}
	foreach( location in HarvestorLocations )
	{
		vector origin = location.GetOrigin()
		DebugDrawSphere( origin, 64, 0, 255, 0, true, lifetime )
		DebugDrawLine( origin, origin + <0,0,6000>, 0, 255, 0, true, lifetime )
		DEV_Crafting_Print( format( "Crafting Harvestor Location: %s", string( origin )))
	}
}
#endif // DEVELOPER

#endif // SERVER

#if CLIENT
void function OnWorkbenchClusterCreated( entity target )
{
	if ( !file.isEnabled )
	{
		return
	}

	if ( target.GetScriptName() != WORKBENCH_CLUSTER_SCRIPTNAME )
		return

	foreach( ent in target.GetLinkEntArray() )
	{
		OnWorkbenchCreated( ent, target )

		if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME && IsLimitedStockWorkbench( target ) )
			AddEntityCallback_GetUseEntOverrideText( ent, LimitedStock_TextOverride )
		else if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
		{
			AddEntityCallback_GetUseEntOverrideText( ent, Crafting_Workbench_UseTextOverride )

			if ( Crafting_IsDispenserCraftingEnabled() )
			{
				WorkbenchData benchData
				benchData.workbench = ent
				benchData.cluster = target

				file.workbenchDataTable_Client[ent] <- benchData
			}
		}
	}
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		entity player = GetLocalViewPlayer()
		thread PlayClientSideWorkbenchHologramFX( target )
	}

	//CreateWorkbenchWorldIcon( target, IsLimitedStockWorkbench( target ) )
	file.workbenchClusterArray.append( target )
}

void function OnWorkbenchCreated( entity target, entity cluster )
{
	if ( target.GetScriptName() != WORKBENCH_SCRIPTNAME )
		return

	AddCallback_OnUseEntity_ClientServer( target, UseCraftingWorkbench )
	SetCallback_CanUseEntityCallback( target, Crafting_Workbench_IsNotBusy )
}

string function Crafting_Workbench_UseTextOverride( entity ent )
{
	entity player = GetLocalViewPlayer()

	CustomUsePrompt_Show( ent )
	CustomUsePrompt_SetSourcePos( ent.GetOrigin() + ( ent.GetScriptName() == HARVESTER_SCRIPTNAME ? < 0, 0, 30 > : <0,0,-20> ) )

	CustomUsePrompt_SetText( Localize("#CRAFTING_WORKBENCH_USE_PROMPT") )

	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		CustomUsePrompt_SetText( Localize("#DISPENSER_USE_PROMPT") )

		WorkbenchData dispensorData = file.workbenchDataTable_Client [ ent ]
		if ( player in dispensorData.playersHaveUsed )
			CustomUsePrompt_SetText( Localize("#DISPENSER_HAS_USED_PROMPT") )
	}






	CustomUsePrompt_SetLineColor( GetCraftingColor() )

	if ( PlayerIsInADS( player ) )
		CustomUsePrompt_ShowSourcePos( false )
	else
		CustomUsePrompt_ShowSourcePos( true )

	return ""
}
#endif

void function UseCraftingWorkbench( entity bench, entity player, int pickupFlags )
{
	#if CLIENT
		CustomUsePrompt_SetLastUsedTime( Time() )
	#endif

	if ( player.IsInventoryOpen() )
		return

	//if( player.Player_IsSkywardLaunching() ) // S3: entity method not available
	//	return

	//if( player.Player_IsSkywardFollowing() ) // S3: entity method not available
	//	return


	//	if ( TitanSword_Super_BlockAction( player, "use_crafter" ) )
	//		return


	#if SERVER
		if ( Crafting_IsDispenserCraftingEnabled() )
		{
			WorkbenchData craftingBenchData = file.workbenchDataTable[bench]
			if ( player in craftingBenchData.playersHaveUsed )
				{
					EmitSoundOnEntityOnlyToPlayer( bench, player, "menu_deny" )
					return
				}
		}
	#endif

	if ( IsBitFlagSet( pickupFlags, USE_INPUT_LONG ) )
	{
		entity cluster
		foreach ( ent in bench.GetLinkParentArray() )
		{
			if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
			{
				cluster = ent
				break
			}
		}

		//check limited use
		if ( IsLimitedStockWorkbench( cluster ) && GetLimitedStockFromWorkbench( cluster ) <= 0 )
			return

		thread WorkbenchThink( bench, player )

		#if CLIENT
			cluster.Signal("WorkbenchUsed")
		#endif
	}
}

void function WorkbenchThink( entity ent, entity playerUser )
{
	#if SERVER
		if ( Crafting_IsDispenserCraftingEnabled() )
		{
			WorkbenchData craftingBenchData = file.workbenchDataTable[ent]
			if ( playerUser in craftingBenchData.playersHaveUsed )
				return
		}
	#endif

	#if CLIENT
		if ( Crafting_IsDispenserCraftingEnabled() )
		{
			WorkbenchData craftingBenchData = file.workbenchDataTable_Client[ent]
			if ( playerUser in craftingBenchData.playersHaveUsed )
				return
		}
	#endif

	ExtendedUseSettings settings = WorkbenchExtendedUseSettings( ent, playerUser )

	ent.EndSignal( "OnDestroy" )
	playerUser.EndSignal( "StartPhaseShift" )

	waitthread ExtendedUse( ent, playerUser, settings )
}

ExtendedUseSettings function WorkbenchExtendedUseSettings( entity ent, entity playerUser )
{
	ExtendedUseSettings settings
	settings.duration = 0.3
	#if CLIENT
	settings.loopSound = "UI_Survival_PickupTicker"
	settings.displayRui = $"ui/extended_use_hint.rpak"
	settings.displayRuiFunc = DefaultExtendedUseRui
	settings.icon = $""
	settings.hint = "#PROMPT_OPEN"
	#elseif SERVER
	settings.successFunc = UseCraftingWorkbench_Success
	settings.failureFunc = UseCraftingWorkbench_Failure
	#endif

	return settings
}

#if SERVER
void function UseCraftingWorkbench_Success( entity bench, entity player, ExtendedUseSettings settings )
{
	bool isWorkbenchBusy = bench.GetLinkEntArray().len() != 0
	bool isWorkbenchCrafting = bench.GetOwner() != null
	if ( isWorkbenchBusy || isWorkbenchCrafting )
		return

	if ( IsPlayerInCryptoDroneCameraView( player ) )
		return

	if ( player.IsPhaseShifted() )
		return

	if ( GetPlayerIsEmoting( player ) )
		return

	if ( player.IsInventoryOpen() )
		return

	//if ( player.Player_IsSkywardLaunching() ) // S3: entity method not available
	//	return

	//if ( player.Player_IsSkywardFollowing() ) // S3: entity method not available
	//	return

	bench.LinkToEnt( player )

	entity cluster
	foreach ( ent in bench.GetLinkParentArray() )
	{
		if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
		{
			cluster = ent
			break
		}
	}

	thread WorkbenchUseThread( bench, cluster, player )

//%if HAS_BOUNTYHUNT
//	if ( IsBountyHuntEnabled() )
//		GiveBounty( player )
//%endif

}

void function UseCraftingWorkbench_Failure( entity bench, entity player, ExtendedUseSettings settings )
{
	if ( bench.GetLinkEntArray().contains( player ) )
		bench.UnlinkFromEnt( player )
}

void function WorkbenchUseThread( entity bench, entity cluster, entity player )
{
	player.Signal( "CraftingPlayerAttaching" )

	thread PlayerAttachedToWorkbenchThread( cluster, bench, player, file.workbenchDataTable[bench] )
}

void function WorkbenchAnimation_IdleDoneCallback( entity ent )
{
	if( IsValid( ent.GetParent()) )
	{
		try { PlayParentedFirstAndThirdPersonAnimation( ent, ent.GetParent(), "ref", ent.e.entAnim1p, ent.e.entAnim3p ) } catch(e) {}
	}
}

void function PlayerAttachedToWorkbenchThread( entity cluster, entity bench, entity player, WorkbenchData data )
{
	if ( !player.ContextAction_IsActive() )
		player.ContextAction_SetBusy()
	else
		return

	if ( player.GetParent() != null )
	{
		printf( "CRAFTING: player tried to attach to crafting workbench while parented to " + player.GetParent() )
		return
	}





	player.EndSignal( "CraftingPlayerDetachImmediate" )
	player.EndSignal( "DeathTotem_PreRecallPlayer" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "Interrupted" )
	player.EndSignal( "OnDestroy" )

	vector safeSpot = player.GetOrigin()
	data.userSafeSpot = safeSpot

	PassByReferenceBool needToHideCraftingMenuForSpectator
	needToHideCraftingMenuForSpectator.value = false

	OnThreadEnd(
		function() : ( player, bench, safeSpot, needToHideCraftingMenuForSpectator )
		{
			if ( player.ContextAction_IsBusy() )
				player.ContextAction_ClearBusy()

			if ( needToHideCraftingMenuForSpectator.value && file.craftingBetterSpectatorEnabled )
			{
				Remote_CallFunction_Replay( player, "TryCloseCraftingMenu" )
				file.playersInCraftingIdle.fastremovebyvalue( player )
			}

			if ( !IsValid( player ) )
				return

			if ( Crafting_IsDispenserCraftingEnabled() && Crafting_QuickOpenCraftingMenu() )
				thread ForceCrouchStand_1PCameraRestoreHack_Thread( player )

			RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
			RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )

			EnableOffhandWeapons( player )
			if ( !Crafting_Access_Inventory_Enabled() )
				EnableInventory( player )

			bench.UnlinkFromEnt( player )
			Assert(!HoverVehicle_IsPlayerInAnyVehicle(player), "Player is considered to be in a vehicle as they attach to Workbench. Parent is " + player.GetParent().name)
			Vehicle_KickPlayer_ForOtherReason( player ) //ewww for some reason this is necessary
			player.ClearParent()
			StopPlayingAnimation( player )
			// We need this in addition to StopPlayingAnimation as a fix for R5DEV-383734. The player may not be in an animation
			// at this point but can have an animation entity blocker (if they try to revive someone immediately) so without
			// destroying the animation entity blocker the below call to PutPlayerInSafeSpace can error.
			DestroyPlayAnimationEntityBlocker( player )

			vector dirFromWorkbenchToPlayer = Normalize(FlattenVec(player.GetOrigin() - bench.GetOrigin()))

			vector idealExitSpot = bench.GetOrigin() + dirFromWorkbenchToPlayer * IDEAL_END_FLAT_LENGTH
			TraceResults tr = TraceLine( player.GetOrigin() + IDEAL_END_TRACE_OFFSET_START, player.GetOrigin() + IDEAL_END_TRACE_OFFSET_END, player, TRACE_MASK_PLAYERSOLID )
			idealExitSpot.z = tr.endPos.z

			PutPlayerInSafeSpot( player, null, null, safeSpot, idealExitSpot )

			if ( player.e.Callback_PlayParentedAnim != null )
			{
				player.e.Callback_PlayParentedAnim = null
				player.e.entAnim1p = ""
				player.e.entAnim3p = ""
			}

			player.Signal( "CraftingPlayerDetached" )
		}
	)

	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	AddCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )

	DisableOffhandWeapons( player )
	if ( !Crafting_Access_Inventory_Enabled() )
		DisableInventory( player )

	string airAppend = ""
	if ( cluster.GetModelName() == WORKBENCH_CLUSTER_AIRDROP_MODEL )
		airAppend = "_air"

	string animAppendSequence = "" + data.doorAnimIndex + airAppend

	if ( Crafting_IsDispenserCraftingEnabled() && Crafting_QuickOpenCraftingMenu() )
	{
		try { PlayParentedFirstAndThirdPersonAnimation( player, cluster, "ref", "ptpov_crafting_replicator_start_" + animAppendSequence + "_quick", "pilot_crafting_replicator_start_" + animAppendSequence ) } catch(e) {}
	}
	else
	{
		try { PlayParentedFirstAndThirdPersonAnimation( player, cluster, "ref", "ptpov_crafting_replicator_start_" + animAppendSequence, "pilot_crafting_replicator_start_" + animAppendSequence ) } catch(e) {}
	}
	player.e.Callback_PlayParentedAnim = WorkbenchAnimation_IdleDoneCallback
	player.e.entAnim1p = "ptpov_crafting_replicator_idle_" + animAppendSequence
	player.e.entAnim3p = "pilot_crafting_replicator_idle_" + animAppendSequence

	if ( Crafting_IsDispenserCraftingEnabled() && Crafting_QuickOpenCraftingMenu() )
	{
		wait GetCurrentPlaylistVarFloat( "crafting_quickopen_time", 0.5 )
	}
	else
	{
		waitthread WaittillAnimDone( player )
	}

	needToHideCraftingMenuForSpectator.value = true
	if ( file.craftingBetterSpectatorEnabled )
	{
		Remote_CallFunction_Replay( player, "Crafting_Workbench_OpenCraftingMenu", bench )
	}
	else
	{
		Remote_CallFunction_NonReplay( player, "Crafting_Workbench_OpenCraftingMenu", bench )
	}
	if( Crafting_CraftersDisabledInDeathField() )
	{
		thread Crafting_RingLogic_Thread( player )
	}
	PIN_Interact( player, "crafting_workbench_used", bench.GetOrigin() )

	thread PlayBattleChatterLineDelayedToSpeakerAndTeamWithDebounceTime_Thread( player, "bc_crafting", 1.0, 45.0, 90.0 )

	EmitSoundOnEntityOnlyToPlayer( bench, player, WORKBENCH_MENU_OPEN_SUCCESS )

	//this shouldn't be required per se, but helps ensure that players can't get stuck in crafting
	file.playersInCraftingIdle.append( player )
	WaitSignal( player, "CraftingPlayerPlayExitAnim" )
	file.playersInCraftingIdle.fastremovebyvalue( player )

	needToHideCraftingMenuForSpectator.value = false

	if ( player.GetParent() != cluster )
	{
		Assert( false, "CRAFTING: player tried to detach from crafting workbench while parented to something else" )
		return
	}

	try { PlayParentedFirstAndThirdPersonAnimation( player, cluster, "ref", "ptpov_crafting_replicator_end_" + animAppendSequence, "pilot_crafting_replicator_end_" + animAppendSequence ) } catch(e) {}
	try { player.Anim_SetStartTime(1) } catch(ex2) {}
	waitthread WaittillAnimDone( player )
}

void function Crafting_RingLogic_Thread(entity player)
{
	player.EndSignal( "CraftingPlayerDetached" )
	while ( DeathField_PointDistanceFromFrontierForIndex( player.GetOrigin(), player.DeathFieldIndex() ) > 0 )
	{
		WaitFrame()
	}
	player.Signal( "CraftingPlayerDetachImmediate" )
}

void function Crafting_OnPlayerKilled( entity player, entity attacker, var damageInfo )
{
	player.Signal( "CraftingPlayerDetachImmediate" )
	ClearUseLinksForPlayer( player )
}

void function Crafting_OnPlayerBleedingOut( entity player, entity attacker, var damageInfo )
{
	player.Signal( "CraftingPlayerDetachImmediate" )
	BleedoutState_SetPlayerBleedoutState( player, BS_BLEEDING_OUT )
}

void function ClientCallback_ClosedCraftingMenu( entity player )
{
	Crafting_CloseCraftingMenu( player )
}

void function Crafting_CloseCraftingMenu( entity player)
{
	if ( !IsValidPlayer( player )  || !Crafting_IsPlayerAtWorkbench( player ) )
		return

	if ( file.craftingBetterSpectatorEnabled )
	{
		Remote_CallFunction_Replay( player, "TryCloseCraftingMenu" )
	}

	if ( file.playersInCraftingIdle.contains( player ) )
	{
		player.Signal( "CraftingPlayerPlayExitAnim" )
	}
	else
	{
		if ( player.IsBot() )
		{
			Warning("Bot " + player +" is trying to close the crafting menu but isn't in the right step of crafting!")
		}
		else
		{
			Assert( false, "Player: " + player + " is trying to close the crafting menu but isn't in the right step of crafting!")
		}

		player.Signal( "CraftingPlayerDetachImmediate" )
	}
}

////////////////////////////////////////////////////////
// Crafting the loot item(s)
////////////////////////////////////////////////////////

void function ClientCallback_InitializeCraftingAtWorkbench( entity player, int craftingIndex )
{
	entity workbench = null
	foreach( ent in player.GetLinkParentArray() )
	{
		if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
		{
			workbench = ent
			break
		}
	}

	if ( workbench == null )
	{
		Warning( "CRAFTING: Trying to initialize crafting at workbench but player is not linked to workbench properly" )
		return
	}

	if ( file.craftingBetterSpectatorEnabled )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_SetCraftingIndexForSpectator", craftingIndex )
	}

	// Check if bench is crafting to avoid a malicious user using the same bench multiple times
	WorkbenchData benchDataPreCraftAttempt = file.workbenchDataTable[workbench]
	if ( player in benchDataPreCraftAttempt.playersHaveUsed )
	{
		Warning( "CRAFTING: Tried to craft even though bench was already used by this player." )
		return
	}

	if ( benchDataPreCraftAttempt.isCrafting )
	{
		Warning( "CRAFTING: Trying to craft even though crafting is in progress" )
		return
	}
	benchDataPreCraftAttempt.isCrafting = true

	EmitSoundOnEntityOnlyToPlayer( workbench, player, WORKBENCH_CRAFTING_START_1P )
	EmitSoundOnEntityExceptToPlayer( workbench, player, WORKBENCH_CRAFTING_START_3P )

	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		entity cluster
		foreach ( ent in workbench.GetLinkParentArray() )
		{
			if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
			{
				cluster = ent
				break
			}
		}
		array <entity> benchSiblings = cluster.GetLinkEntArray()
		foreach ( bench in benchSiblings)
		{
			if (bench.GetScriptName() == WORKBENCH_SCRIPTNAME)
			{
				WorkbenchData craftingBenchData = file.workbenchDataTable[bench]
				if ( !(player in craftingBenchData.playersHaveUsed) )
				{
					CraftingCategory ornull item = GetCategoryForIndex( craftingIndex )
					expect CraftingCategory( item )
					if ( !( item.category == "banner" && (Perks_GetRoleForPlayer( player ) == eCharacterClassRole.SUPPORT) && Crafting_DispenserFreeSupportBanner() ) )
					{
						craftingBenchData.playersHaveUsed [ player ] <- true
					}

					bool isBanner = item.category == "banner"
					foreach( teammate in GetPlayerArrayOfTeam( player.GetTeam() ) )
					{
						Remote_CallFunction_NonReplay( teammate, "ServertoClientCallback_SetDispenserData", player, bench, cluster, file.minimapObjTable[cluster], isBanner, true )
					}
				}
			}
		}
	}

	thread CraftingThread_Internal( player, workbench, WORKBENCH_CRAFTING_DURATION, craftingIndex )
}

void function CraftingThread_Internal( entity player, entity workbench, float duration, int itemIndex )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		duration = WORKBENCH_CRAFTING_DURATION_NEW

	entity cluster
	foreach ( ent in workbench.GetLinkParentArray() )
	{
		if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
		{
			cluster = ent
			break
		}
	}





	// Handled as a reference so we don't need to have multiple of these
	WorkbenchData craftingBenchData = file.workbenchDataTable[workbench]

	// Make sure to always set that we are not crafting when our thread ends.
	OnThreadEnd(
		function() : ( craftingBenchData )
		{
			craftingBenchData.isCrafting = false
		}
	)

	CraftingCategory ornull item = GetCategoryForIndex( itemIndex )
	if ( item == null )
	{
		Warning( "CRAFTING: Trying to craft when specified index category is null" )
		return
	}

	expect CraftingCategory( item )

	//creating valid item list
	array<string> validItems = Crafting_GetLootDataFromIndex( itemIndex, player )
	if ( validItems.len() == 0 )
	{
		Warning( "CRAFTING: Trying to craft when validItems is not populated" )
		return
	}

	int cost
	foreach ( ref in validItems )
	{
		cost += item.itemToCostTable[ref]
	}

	bool canAfford = Crafting_GetPlayerCraftingMaterials( player ) >= cost
	if ( !canAfford )
	{
		if ( !Crafting_IsDispenserCraftingEnabled() )
		{
			Warning( "CRAFTING: Trying to craft without necessary fund" )
			return // silently fail if we do not have the money, certainly cheating
		}
	}

	Crafting_RemoveMaterialsFromPlayer( player, cost )
	StatsHook_CraftingItemCrafted( player )

	// PIN V0: If the category is in this array, post the item name with the cost. Else, post the category with the cost
	if ( CRAFTED_ITEM_CATEGORIES_FOR_ITEM_NAMES.contains( item.category ) )
	{
		// Get the item names.
		CraftingBundle craftedItemBundle = item.bundlesInCategory[ item.category ]
		array<string> craftedItemNames = GetItemNamesFromCraftingBundle( craftedItemBundle )
		string craftedItemRef = craftedItemNames[0]

		#if DEVELOPER
		DEV_Crafting_Print( format( "***** crafted item name = %s", craftedItemRef ))
		#endif

		PIN_Interact( player, "crafting_item_crafted" , workbench.GetOrigin(), craftedItemRef, cost )
	}
	else
	{
		PIN_Interact( player, "crafting_item_crafted" , workbench.GetOrigin(), item.category, cost )
	}

	int evoArmorProgress
	int evoTier = -1
 	LootData existingArmorData
	if ( item.category == "evo" )
	{
		string equipSlot = "armor"
		existingArmorData = EquipmentSlot_GetEquippedLootDataForSlot( player, equipSlot )
		evoArmorProgress = EvolvingArmor_GetEvolutionProgress( player )
		Inventory_SetPlayerEquipment( player, "armor_pickup_lv0_evolving", equipSlot )
		EvolvingArmor_SetEvolutionProgress( player, EvolvingArmor_GetRequirementForEvolution( 0 ) )

		Remote_CallFunction_NonReplay( player, "ServerCallback_CL_ArmorDeposited" )
	}

	/*if ( IsLimitedStockWorkbench( cluster ) )
		RemoveLimitedStockFromWorkbenchAtIndex( cluster )*/

	bool isAnyWorkbenchCrafting = false
	foreach( benchData in file.workbenchClusterToBenchData[cluster] )
	{
		//printf( "Crafting: Checking bench " + benchData.workbench + " at cluster " + benchData.cluster + " with value " + benchData.isCrafting )
		if ( benchData.isCrafting && benchData.workbench != workbench )
		{
			isAnyWorkbenchCrafting = true
			break
		}
	}

	if ( !isAnyWorkbenchCrafting )
		EmitSoundOnEntity( cluster, WORKBENCH_CRAFTING_LOOP )

	bool needWP = true
	if ( Crafting_IsDispenserCraftingEnabled() )
		needWP = false

	entity wp = CreateWaypoint_ObjectiveEntLocation( workbench, ePingType.OBJECTIVE )
	if ( needWP == true )
	{
		wp.SetParent( workbench )
		wp.SetLocalOrigin( <0, 0, -4> )
		{
			if ( item.category == "evo" )
			{
				int tier = existingArmorData.tier
				int amountToGrant = GetCurrentPlaylistVarInt( "crafting_override_evo_grant", CRAFTING_EVO_GRANT )
				int armorProgress = evoArmorProgress - amountToGrant
				while ( armorProgress <= 0 && tier != 5 )
				{
					tier = tier + 1
					if ( tier == 4 )
						tier = tier + 1

					if ( tier == MAX_ARMOR_EVO_TIER )
						break

					armorProgress = EvolvingArmor_GetRequirementForEvolution( tier ) - abs( armorProgress )
					StatsHook_EvoArmorEvolved( player, tier )
				}
				wp.SetWaypointInt( 5, tier )
				evoTier = EnsureValidEvoTier( tier )
			}

			else if ( item.category == "banner" )
			{
				wp.SetWaypointInt( 5, 5 )
				wp.SetWaypointInt( 6, 1 )
			}

			else
			{
				LootData data = SURVIVAL_Loot_GetLootDataByRef( validItems[0] )
				wp.SetWaypointInt( 5, data.tier )
			}
		}

		wp.SetWaypointGametime( RUI_TRACK_INDEX_CAPTURE_END_TIME, Time() + duration )
		wp.SetWaypointFloat( RUI_TRACK_INDEX_REQUIRED_TIME, duration )
		wp.SetWaypointInt( RUI_TRACK_INDEX_ACTIVATOR_TEAM, player.GetTeam() )
		wp.SetWaypointString( 0, craftingBenchData.doorAnimIndex )
	}

	if (Crafting_IsDispenserCraftingEnabled())
	{
		entity startFX = StartParticleEffectOnEntityWithPos_ReturnEntity( cluster, GetParticleSystemIndex( WORKBENCH_DISPENSER_START_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, cluster.LookupAttachment( "FX_LIGHT" ), <0, 0, 0>, <0, 0, 0> )
		EffectSetControlPointVector( startFX, 1, WORKBENCH_DISPENSER_VFX_COLOR )
	}
	else
	{
		StartParticleEffectOnEntityWithPos( cluster, GetParticleSystemIndex( WORKBENCH_START_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, cluster.LookupAttachment( "FX_LIGHT" ), <0, 0, 0>, <0, 0, 0> )
	}

	// Notify via obit that this player is crafting.
	if( file.crafting_obit_notify )
		Crafting_Obit_Items_Notify_Teammates( player, eCrafting_Obit_NotifyType.IS_CRAFTING_ITEM, cost, itemIndex, evoTier )

	//start UI process if crafted itemref is valid
	float waitCraftDuration = 3.0
	if (Crafting_IsDispenserCraftingEnabled())
		waitCraftDuration = 1.0

	if ( needWP == true )
	{
		workbench.SetOwner( wp )
	}

	wait duration - waitCraftDuration
	EmitSoundOnEntity( workbench, WORKBENCH_CRAFTING_FINISH_WARNING )
	wait waitCraftDuration

	Signal( cluster, "CraftingComplete" )

	if ( needWP == true )
	{
		workbench.SetOwner( null )
	}

	wp.Destroy()

	StopSoundOnEntity( workbench, WORKBENCH_CRAFTING_START_1P )
	StopSoundOnEntity( workbench, WORKBENCH_CRAFTING_START_3P )

	EmitSoundOnEntity( workbench, WORKBENCH_CRAFTING_FINISH )

	craftingBenchData.isCrafting = false

	isAnyWorkbenchCrafting = false
	foreach( benchData in file.workbenchClusterToBenchData[cluster] )
	{
		if ( benchData.isCrafting )
		{
			isAnyWorkbenchCrafting = true
			break
		}
	}

	if ( !isAnyWorkbenchCrafting )
		StopSoundOnEntity( cluster, WORKBENCH_CRAFTING_LOOP )

	thread DoorOpenAnimThread( cluster, craftingBenchData )


	bool autoCloseDoor = false
	array<entity> bannerPlayers = []
	if ( item.category == "banner" )
	{
		bannerPlayers = GetCraftableTeamBanners( player )
		if ( bannerPlayers.len() == 0 )
			autoCloseDoor = true

		foreach( teammate in bannerPlayers )
		{
			int respawnStatus = teammate.GetPlayerNetInt( "respawnStatus" )
			if ( respawnStatus == eRespawnStatus.PICKUP_DESTROYED )
			{
				StatsHook_RespawnBannerCrafted( player )
			}
		}

	}

	if ( autoCloseDoor )
	{
		craftingBenchData.isDoorOpen = true

		wait 1

		entity closeCluster
		foreach ( ent in workbench.GetLinkParentArray() )
		{
			if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
			{
				closeCluster = ent
				break
			}
		}

		thread DoorCloseAnimThread( closeCluster, craftingBenchData )
		craftingBenchData.isDoorOpen = false

		return
	}


	array<string> itemsToSpawn = clone validItems
	int evoProgressToSpawn = 0
	if ( item.category == "evo" )
	{
		string newArmorRef = existingArmorData.ref
		int tierLevel = existingArmorData.tier
		int amountToGrant = GetCurrentPlaylistVarInt( "crafting_override_evo_grant", CRAFTING_EVO_GRANT )
		int newProgress = evoArmorProgress - amountToGrant
		printf( "CRAFTING: Trying to grant evo shield with progress " + newProgress )
		while ( newProgress <= 0  && tierLevel != 5)
		{
			tierLevel = tierLevel + 1
			printf( "CRAFTING: Levelling up shield to tier " + tierLevel )
			if ( tierLevel >= 4 )
			{
				newArmorRef = "armor_pickup_lv5_evolving"
				newProgress = 0
			}
			else
			{
				newArmorRef = "armor_pickup_lv" + tierLevel + "_evolving"
				newProgress = EvolvingArmor_GetRequirementForEvolution( tierLevel ) - abs( newProgress )
			}
			printf( "CRAFTING: Setting shield progress to " + newProgress )
		}
		evoProgressToSpawn = newProgress

		itemsToSpawn.clear()
		itemsToSpawn.append( newArmorRef )
	}


	if( item.category == "banner" )
	{
		while( itemsToSpawn.len() < bannerPlayers.len() )
		{
			itemsToSpawn.append( CRAFTED_BANNER_REF )
		}

		if (  Crafting_IsDispenserCraftingEnabled() && Crafting_DispenserSupportMRB() && Perks_GetRoleForPlayer( player ) == eCharacterClassRole.SUPPORT  )
		{
			itemsToSpawn.append( "mp_ability_mobile_respawn_beacon" )
		}
	}


	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		if ( item.category == "health_pickup" )
		{
			for ( int i = 0; i < GetCurrentPlaylistVarInt( "dispenser_health_number", 0 ); i++ )
			{
				itemsToSpawn.append( "health_pickup_health_large" )
			}
		}

		if ( item.category == "shield_pickup" )
		{
			for ( int i = 0; i < GetCurrentPlaylistVarInt( "dispenser_batt_number", 0 ); i++ )
			{
				itemsToSpawn.append( "health_pickup_combo_large" )
			}
		}
	}

	array<entity> spawnedLoot = DroppodDoorThink( cluster, craftingBenchData.lootAttachmentIndex, itemsToSpawn, true )
	for ( int i = 0; i < spawnedLoot.len(); i++ )
	{
		entity lootItem = spawnedLoot[i]
		if ( item.category == "evo" )
		{
			SetPropSurvivalExtraPropertyOnEnt( lootItem, evoProgressToSpawn )
		}


		if ( item.category == "banner" )
		{
			int lootIndex = lootItem.GetSurvivalInt()
			LootData data = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
			if ( data.ref == CRAFTED_BANNER_REF )
			{
				lootItem.SetSurvivalProperty( EHIToEncodedEHandle( bannerPlayers[i] ) )

				float waitDuration = Perk_Get_CraftedBannerTimeoutDuration()
				thread SetCraftedItemtoExpire_Thread( player, lootItem, waitDuration )
			}
		}


		workbench.LinkToEnt( lootItem )

		if ( file.craftingPickupGracePeriod > 0 && item.category != "banner" )
		{
			Crafting_CreateHolderEnt( player, lootItem, file.craftingPickupGracePeriod )
			if ( Crafting_AutoEject_IsEnabled() )
				thread Crafting_AutoEject( lootItem, file.craftingPickupGracePeriod )
		}
	}

	craftingBenchData.isDoorOpen = true
	craftingBenchData.spawnedLoot = spawnedLoot
}

int function CalculateEvoArmorTierAfterCrafting( entity player )
{
	string equipSlot = "armor"
	LootData existingArmorData = EquipmentSlot_GetEquippedLootDataForSlot( player, equipSlot )
	int evoArmorProgress = EvolvingArmor_GetEvolutionProgress( player )

	int tierLevel = existingArmorData.tier
	int amountToGrant = GetCurrentPlaylistVarInt( "crafting_override_evo_grant", CRAFTING_EVO_GRANT )
	int newProgress = evoArmorProgress - amountToGrant

	if( newProgress <= 0  )
	{
		tierLevel++
		if( tierLevel == 4 )
			return( MAX_ARMOR_EVO_TIER )
		else
			return( tierLevel )
	}

	return tierLevel
}

void function DoorOpenAnimThread( entity workbench, WorkbenchData data )
{




	int attachId = workbench.LookupAttachment( "FX_DOOR_OPEN_" + data.doorAnimIndex )
	StartParticleEffectOnEntity( workbench, GetParticleSystemIndex( WORKBENCH_DOOR_OPEN_FX ), FX_PATTACH_POINT_FOLLOW, attachId )

	int animIndex = workbench.LookupPoseParameterIndex( "Open" + data.doorAnimIndex )
	workbench.SetPoseParameterOverTime( animIndex, 1.0, 0.8 )

	vector attachmentOrigin = workbench.GetAttachmentOrigin( attachId )
	EmitSoundAtPosition( TEAM_ANY, attachmentOrigin, WORKBENCH_CRAFTING_DOOR_OPEN, workbench )
}

void function Crafting_OnLootPickedUp( entity player, entity pickup, string ref, int unitsPickedUp, bool willDestroy, entity deathBox, int pickupFlags )
{
	Crafting_DoorCloseCheck ( pickup, willDestroy )
}

void function SetCraftedItemtoExpire_Thread( entity player, entity item, float expirationWaitDuration)
{
	EndSignal( item, "OnDestroy" )

	wait expirationWaitDuration

	Crafting_DoorCloseCheck( item, true )

	if( IsValid(item) )
		item.Destroy()
}

void function Crafting_DoorCloseCheck( entity pickup, bool willDestroy )
{
	bool lootOnWorkbench = false
	WorkbenchData data
	foreach ( bench in file.workbenchArray )
	{
		if ( bench in file.workbenchDataTable )
		{
			data = file.workbenchDataTable[bench]
			foreach ( lootEnt in data.spawnedLoot )
			{
				if ( pickup == lootEnt )
				{
					lootOnWorkbench = true
					break
				}
			}
		}

		if ( lootOnWorkbench )
			break
	}

	if ( !lootOnWorkbench )
		return

	entity cluster
	foreach ( ent in data.workbench.GetLinkParentArray() )
	{
		if ( ent.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
		{
			cluster = ent
			break
		}
	}

	if ( lootOnWorkbench && willDestroy )
	{
		data.spawnedLoot.fastremovebyvalue( pickup )
		data.workbench.UnlinkFromEnt( pickup )

		if ( data.spawnedLoot.len() <= 0 )
		{


			thread DoorCloseAnimThread( cluster, data )
			data.isDoorOpen = false
			file.workbenchDataTable[data.workbench] <- data
		}
	}
}

void function DoorCloseAnimThread( entity workbench, WorkbenchData data )
{




	wait 0.5
	if ( !IsValid(workbench) )
		return

	int animIndex = workbench.LookupPoseParameterIndex( "Open" + data.doorAnimIndex )
	workbench.SetPoseParameterOverTime( animIndex, 0.0, WORKBENCH_CLOSEDOOR_DURATION )

	int attachId = workbench.LookupAttachment( "FX_DOOR_OPEN_" + data.doorAnimIndex )
	vector attachmentOrigin = workbench.GetAttachmentOrigin( attachId )
	EmitSoundAtPosition( TEAM_ANY, attachmentOrigin, WORKBENCH_CRAFTING_DOOR_CLOSE, workbench)
}

void function Crafting_CreateHolderEnt( entity player, entity item, float holdDuration )
{
	thread CreateHolderEnt_Thread( player, item, holdDuration )
}

void function CreateHolderEnt_Thread( entity player, entity item, float holdDuration )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( item, "OnDestroy" )
	EndSignal( item, "OnPinged_Crafting" )

	if ( !IsValid( player ) || !IsValid( item ) )
		return

	entity oldParent = item.GetParent()
	string oldParentAttachment = item.GetParentAttachment()

	entity holder = CreatePropScript( EMPTY_MODEL, item.GetOrigin(), item.GetAngles() )

	if(IsValid(oldParent))
	{
		holder.SetParent( oldParent, oldParentAttachment, true )
	}

	holder.SetScriptName( HOLDER_ENT_NAME )
	item.SetParent( holder )
	holder.SetOwner( player )

	OnThreadEnd(
		function() : ( item, oldParent, oldParentAttachment, holder )
		{
			if (IsValid(item))
			{
				if (IsValid(oldParent))
				{
					item.SetParent( oldParent, oldParentAttachment, true )
				}
				else
				{
					item.ClearParent()
				}
			}

			if ( IsValid( holder ))
			{
				holder.Destroy()
			}
		}
	)

	wait holdDuration
}

void function OnLootPinged( entity player, entity wp, entity pingEnt, int pingType )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( pingEnt ) )
		return

	if ( ! Crafting_DoesPlayerOwnItem( player, pingEnt ) )
		return

	if ( pingEnt.e.spawnSource == eSpawnSource.CRAFTING )
		Signal( pingEnt, "OnPinged_Crafting" )
}

void function Dispensers_PingNearestDispenser( entity player, vector origin )
{
	if ( !IsValid ( player ) )
		return

	entity dispenser = GetClosestValidDispenser( player, origin )
	int pingType
	int notifyType = Dispensers_GetReplicatorStateForPlayer( player, dispenser )
	switch( notifyType )
	{
		case eCrafting_Dispenser_StateType.NO_ONE_HAS_USED:
			pingType = ePingType.PING_REPLICATOR_NOONE_USED
			break
		case eCrafting_Dispenser_StateType.ALL_USED:
			pingType = ePingType.PING_REPLICATOR_ALL_USED
			break
		case eCrafting_Dispenser_StateType.PLAYER_HAS_USED:
			pingType = ePingType.PING_REPLICATOR_PLAYER_USED
			break
		case eCrafting_Dispenser_StateType.TEAMMATE_HAS_USED:
			pingType = ePingType.PING_REPLICATOR_TEAMMATE_USED
			break
		default:
			pingType = ePingType.PING_REPLICATOR
			break
	}

	if ( IsValid( dispenser ) )
	{
		entity wp = CreateWaypoint_Ping_Location( player, pingType, dispenser, dispenser.GetOrigin(), -1, true )
		wp.SetAbsOrigin( dispenser.GetOrigin() + <0, 0, 35> )
		wp.SetParent( dispenser )
	}
}

entity function GetClosestValidDispenser( entity player, vector origin )
{
	array<entity> dispensers               = clone file.workbenchClusterArray
	if( dispensers.len() <= 0 )
		return null

	array<entity> teamArray = GetPlayerArrayOfTeam( player.GetTeam() )

	foreach ( entity cluster in dispensers )
	{
		if ( !IsValid( cluster ) )
			continue

		array< entity > benchSiblings = cluster.GetLinkEntArray()
		foreach ( bench in benchSiblings)
		{
			if ( bench.GetScriptName() == WORKBENCH_SCRIPTNAME )
			{
				WorkbenchData craftingBenchData = file.workbenchDataTable[bench]
				foreach( ally in teamArray )
				{
					if ( ally in craftingBenchData.playersHaveUsed )
					{
						dispensers.removebyvalue( cluster )
						break
					}
				}
			}
		}
	}

	if ( dispensers.len() <= 0 )
		return null

	array< ArrayDistanceEntry > allResults = ArrayDistanceResults( dispensers, origin )
	allResults.sort( DistanceCompareClosest )

	return allResults[0].ent
}

void function Crafting_AutoEject( entity loot, float holdDuration )
{
	EndSignal( loot, "OnDestroy" )
	float extraDuration = GetCurrentPlaylistVarFloat( "crafting_auto_eject_time", 10.0 )

	float totalDuration = holdDuration + extraDuration

	wait totalDuration

	if ( IsValid( loot ) )
	{
		vector vel = ( loot.GetOrigin() - loot.GetParent().GetOrigin() ) * 2.0
		FakePhysicsThrow( null, loot, vel, true )

		wait 0.5

		Crafting_DoorCloseCheck( loot, true )
	}
}
#endif // SERVER

int function EnsureValidEvoTier( int evoTier )
{

	if( evoTier > MAX_ARMOR_EVO_TIER )
		return MAX_ARMOR_EVO_TIER

	// Skips to Max if 4.
	if( evoTier == 4  )
		return MAX_ARMOR_EVO_TIER

	if( evoTier < -1 )
		return -1

	return evoTier
}

bool function Crafting_IsItemCurrentlyOwnedByAnyPlayer( entity itemEnt )
{
	if ( !IsValid( itemEnt ) )
		return false

	if ( !IsValid( itemEnt.GetParent() ) )
		return false

	if ( ! ( itemEnt.GetParent().GetScriptName() == HOLDER_ENT_NAME ) )
		return false

	if ( !IsValid( itemEnt.GetParent().GetOwner() ) )
		return false

	if ( ! ( itemEnt.GetParent().GetOwner().IsPlayer() ) )
		return false

	return true
}

bool function Crafting_DoesPlayerOwnItem( entity player, entity itemEnt )
{
	if ( !IsValid( player ) )
		return false

	if ( !Crafting_IsItemCurrentlyOwnedByAnyPlayer( itemEnt ) )
		return false

	return player == itemEnt.GetParent().GetOwner()
}

array< string > function GenerateCraftingItemsInCategory( entity player, CraftingCategory categoryToCheck )
{
	int craftingRotation = categoryToCheck.rotationStyle

	//check categories that aren't based on timestamps to short circuit
	if ( craftingRotation == eCraftingRotationStyle.PERMANENT || craftingRotation == eCraftingRotationStyle.SEASONAL )
	{
		CraftingBundle bundle = GetBundleForCategory( categoryToCheck )
		return bundle.itemsInBundle
	}


	if ( craftingRotation == eCraftingRotationStyle.PERK )
	{
		bool has_banners = Player_Banners_Enabled()
		if ( Crafting_IsDispenserCraftingEnabled() && ( GetRespawnStyle() == eRespawnStyle.RESPAWN_CHAMBERS ) && has_banners )
		{
			CraftingBundle bundle = GetBundleForCategory( categoryToCheck )
			return bundle.itemsInBundle
		}
		else
		{
			if ( categoryToCheck.category == "banner" && ( Perk_CanBuyBanners( player ) && ( GetRespawnStyle() == eRespawnStyle.RESPAWN_CHAMBERS ) && has_banners || Perks_DoesPlayerHavePerk( player, ePerkIndex.BANNER_CRAFTING ) ) )
			{
				CraftingBundle bundle = GetBundleForCategory( categoryToCheck )
				return bundle.itemsInBundle
			}







			else
			{
				return []
			}
		}
	}


	if ( craftingRotation == eCraftingRotationStyle.LOADOUT_BASED )
	{
		array< string > itemList
		CraftingBundle bundle = GetBundleForCategory( categoryToCheck )
		array< string > listToCheck = bundle.itemsInBundle

		array<entity> weapons  = SURVIVAL_GetPrimaryWeapons( player )
		foreach( slot, weapon in weapons )
		{
			int ammoType = weapon.GetWeaponAmmoPoolType()
			string ammoRef = AmmoType_GetRefFromIndex(ammoType)

			foreach( item in listToCheck )
			{
				if ( item == ammoRef )
					itemList.append( item )
			}
		}

		return itemList
	}


	CraftingBundle bundle = GetBundleForCategory( categoryToCheck )
	array< string > listToCheck = bundle.itemsInBundle

	return listToCheck
}

void function Crafting_Obit_Items_Notify_Teammates( entity notifyingplayer, int notifyType, int cost, int itemIndex, int evoTier = -1 )
{
	if( file.crafting_obit_notify )
	{
		int evoTierToUse = EnsureValidEvoTier( evoTier )

		#if SERVER
			ClientCallback_Crafting_Notify_Teammates_On_Obit( notifyingplayer, notifyType, cost, itemIndex, evoTierToUse )
		#elseif CLIENT
			Remote_ServerCallFunction( "ClientCallback_Crafting_Notify_Teammates_On_Obit", notifyType, cost, itemIndex, evoTierToUse )
		#endif
	}
}

CraftingBundle function GetBundleForCategory( CraftingCategory categoryToCheck )
{
	int craftingRotation = categoryToCheck.rotationStyle

	//check categories that aren't based on timestamps to short circuit

	if ( CheckCraftingRotation( craftingRotation ) )
	{
		Assert( categoryToCheck.bundlesInCategory.len() != 0, "CRAFTING: Bundle list in category " + categoryToCheck.category + " is empty" )
		return categoryToCheck.bundlesInCategory[categoryToCheck.bundleStrings.top()]
	}

	//remainder of categories are based on rotations
	string unixTimeEventStartString = GetCurrentPlaylistVarString( "crafting_rotation_start", "2020-03-01 10:00:00 -08:00" )
	int unixTimeNow
	#if SERVER
		if ( file.isNetworkingRegistered )
			unixTimeNow = GetUnixTimestamp()//int(GetGlobalNetTime( "Crafting_StartTime" ))
		else
			unixTimeNow = file.matchStartTime
	#endif
	#if CLIENT
		if ( !IsLobby() )
			unixTimeNow = GetUnixTimestamp()//int(GetGlobalNetTime( "Crafting_StartTime" ))
		else
			unixTimeNow = GetUnixTimestamp()
	#endif

	int ornull unixTimeEventStart = DateTimeStringToUnixTimestamp( unixTimeEventStartString )
	Assert( unixTimeEventStart != null, format( "Bad format in playlist for setting 'crafting_rotation_start': '%s'", unixTimeEventStartString ) )
	expect int( unixTimeEventStart )

	int unixTimeSinceEventStarted = ( unixTimeNow - unixTimeEventStart )
	int hoursSinceEventStarted = int( floor( unixTimeSinceEventStarted / SECONDS_PER_HOUR ) )
	int daysSinceEventStarted =  int( floor( unixTimeSinceEventStarted / SECONDS_PER_DAY ) )
	int weeksSinceEventStarted = int( floor( unixTimeSinceEventStarted / SECONDS_PER_WEEK ) )

	int rotationRaw = 1
	if ( craftingRotation == eCraftingRotationStyle.WEEKLY )
	{
		rotationRaw = weeksSinceEventStarted
	} else if ( craftingRotation == eCraftingRotationStyle.DAILY )
	{
		rotationRaw = daysSinceEventStarted
	} else if ( craftingRotation == eCraftingRotationStyle.HOURLY )
	{
		rotationRaw = hoursSinceEventStarted
	}

	int rotationIndex = abs(rotationRaw % ( categoryToCheck.bundleStrings.len() ) )
	return categoryToCheck.bundlesInCategory[ categoryToCheck.bundleStrings[rotationIndex] ]
}

bool function CheckCraftingRotation( int craftingRotation )
{
	if ( craftingRotation == eCraftingRotationStyle.PERMANENT )
		return true

	if ( craftingRotation == eCraftingRotationStyle.SEASONAL )
		return true

	if ( craftingRotation == eCraftingRotationStyle.LOADOUT_BASED )
		return true


	if ( craftingRotation == eCraftingRotationStyle.PERK )
		return true


	/*%if HAS_SHELVED_LEGEND_ABILITIES
	if( craftingRotation == eCraftingRotationStyle.CALIBER_PASSIVE )
		return true
	%endif*/

	return false
}

#if SERVER
void function Crafting_OnPlayerMatchStateChanged( entity player, int oldState, int newState )
{
	if ( newState == ePlayerMatchState.SKYDIVE_PRELAUNCH )
		thread Thread_Crafting_PromptAllWorkbenches ( player )
}

void function Thread_Crafting_PromptAllWorkbenches ( entity player )
{

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) && GoldenHorse_TicksEnabled() )
		return


	FlagWait( "CraftingInitialized" )
	if ( file.workbenchClusterArray.len() == 0 || !IsValid(player) )
		return
	Remote_CallFunction_NonReplay( player, "ServerCallback_PromptAllWorkbenches", player )
}

#if DEVELOPER
void function DEV_PlayerUseRandomHarvester ( entity player )
{
	foreach (entity harvester in file.harvesterArray)
	{
		if( IsValid( harvester ) )
		{
			if ( !PlayerHasUsedHarvester( player, harvester ) )
			{
				player.ForceUseEntity( harvester, 1 )
				break
			}
		}
	}
}
#endif

void function ClientCallback_Crafting_Notify_Teammates_On_Obit( entity player, int notifyType, int mats, int itemIndex, int evoTierParm )
{
	if( !file.crafting_obit_notify )
		return

	if( !Can_Notify_Via_Obit( player ) )
		return

	if(( notifyType < 0 ) || ( notifyType > eCrafting_Obit_NotifyType.COUNT_ ))
		return

	if( mats < 0  )
		return

	// Check to see if item is an evo shield and if so, pass the expected Shield Level after crafting to the Obit.
	int evoTier = evoTierParm
	CraftingCategory ornull item = GetCategoryForIndex( itemIndex )
	if ( item == null )
		return

	expect CraftingCategory( item )
	if(( item.category == "evo" ) && ( notifyType == eCrafting_Obit_NotifyType.IS_REQUESTING_MATERIALS ))
	{
		evoTier = CalculateEvoArmorTierAfterCrafting( player )
	}

	array< entity > squad = GetPlayerArrayOfTeam_Alive( player.GetTeam() )
	foreach ( teammate in squad )
	{
		if ( IsValid( teammate ) && IsAlive( teammate ) )
			Remote_CallFunction_NonReplay( teammate, "ServerCallback_Crafting_Notify_Player_On_Obit", player, notifyType, mats, itemIndex, EnsureValidEvoTier( evoTier ))
	}
}

bool function Can_Notify_Via_Obit( entity player )
{
	if( !IsValid( player ) || !player.IsPlayer())
		return false

	float currentTime = Time()

	if( !( player in file.notifyingPlayerObitTimes ) )
	{
		file.notifyingPlayerObitTimes[ player ] <- currentTime
		return true
	}

	float timePassed = currentTime - file.notifyingPlayerObitTimes[ player ]
	file.notifyingPlayerObitTimes[ player ] = currentTime
	return( timePassed > CRAFTING_OBIT_DEBOUNCE_PERIOD )
}

#endif // SERVER

#if DEVELOPER
#if SERVER
void function DEV_PrintUsedHarvesters()
{
	DEV_Crafting_Print( "----- Used Harvesters:"  )
	foreach( entity player in GetPlayerArray_AliveConnected() )
	{
		DEV_Crafting_Print( format( "	- Player: %s", string( player )))
		foreach( entity harvester in file.harvesterArray )
		{
			if ( PlayerHasUsedHarvester( player, harvester ) )
			{
				DEV_Crafting_Print( format( "	--- used Harvester: %s ", string( harvester )))
			}
		}
	}
}
#endif

void function DEV_Crafting_PrintsOn( bool isOn = true )
{
	file.devPrintsOn = isOn
}

void function DEV_Crafting_Print( string printThis )
{
	if( file.devPrintsOn )
	{
		printt( format( "CRAFTING: %s ", printThis ))
	}
}

#endif // DEVELOPER



bool function Crafting_Workbench_IsNotBusy( entity player, entity ent, int useFlags )
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, ent ) )
		return false

	bool isWorkbenchBusy = ent.GetLinkEntArray().len() != 0
	bool isWorkbenchCrafting = ent.GetOwner() != null

	if( Crafting_CraftersDisabledInDeathField() )
	{
		if ( DeathField_PointDistanceFromFrontierForIndex( ent.GetOrigin(), player.DeathFieldIndex() ) <= 0 )
		{
			return false
		}
	}

	if ( isWorkbenchBusy || isWorkbenchCrafting )
		return false

	return true
}


array<string> function Crafting_GetLootDataFromIndex( int index, entity player )
{
	entity workbench
	array<entity> possibleWorkbenches = player.GetLinkParentArray()
	foreach( ent in possibleWorkbenches )
	{
		if ( ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
		{
			foreach ( cluster in ent.GetLinkParentArray() )
			{
				if ( cluster.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
				{
					workbench = cluster
					break
				}
			}

			if ( workbench != null )
				break
		}
	}

	CraftingCategory ornull item = GetCategoryForIndex( index )
	array< string > validItemList

	if ( item == null )
		return validItemList

	expect CraftingCategory( item )
	bool showWhenEmpty = false

	validItemList = GenerateCraftingItemsInCategory( player, item )

	int cumulativeIndex = 0
	foreach( category in file.craftingDataArray )
	{
		if ( category == item )
			break

		cumulativeIndex += category.numSlots
	}

	if ( item.category == "ammo" || item.category == "evo" || item.category == "banner" )
		return validItemList


	if ( validItemList.len() == 0 )
		return validItemList

	array<string> finalItemList
	int difference = index - cumulativeIndex
	finalItemList.append( validItemList[difference] )
	return finalItemList
}


CraftingCategory ornull function GetCategoryForIndex( int index )
{
	int cumulativeIndex = 0
	foreach( category in file.craftingDataArray )
	{
		cumulativeIndex += category.numSlots
		if ( index < cumulativeIndex )
			return category
	}

	return null
}


#if SERVER
void function Crafting_PingNearestWorkbench( entity player, vector origin )
{
	entity workbench = GetClosestValidWorkbench( player, origin )

	if ( IsValid( workbench ) )
	{
		entity wp = CreateWaypoint_Ping_Location( player, ePingType.PING_REPLICATOR, workbench, workbench.GetOrigin(), -1, true )
		wp.SetAbsOrigin( workbench.GetOrigin() + <0, 0, 35> )
		wp.SetParent( workbench )
	}
}

entity function GetClosestValidWorkbench( entity player, vector origin )
{
	array<entity> workbenches               = clone file.workbenchClusterArray
	if( workbenches.len() <= 0 )
		return null

	array<ArrayDistanceEntry> allResults = ArrayDistanceResults( workbenches, origin )
	allResults.sort( DistanceCompareClosest )

	//TODO: Add logic similar to GetClosestValidStation() from sh_respawn_beacon.nut for better determining which is the best, closest, safest valid work bench. That logic checks for things like ring threat and estimated time for a player to travel to the station.
	//For the time being, just going to grab whatever is the closest

	return allResults[0].ent
}
#endif



#if CLIENT
void function MarkNextStepForPlayer( entity markedEnt )
{
	thread NextStepMarkerThread( markedEnt )
}

void function NextStepMarkerThread( entity markedEnt )
{
	table<int, var> result = CreateMarker( markedEnt, true )

	markedEnt.EndSignal( "HarvesterDisabled" )
	markedEnt.EndSignal( "WorkbenchUsed" )

	OnThreadEnd(
		function() : ( result )
		{
			foreach( fxId, rui in result)
			{
				EffectStop( fxId, true, false )
				RuiSetBool( rui, "isFinished", true )
			}
		}
	)

	wait 20

	return
}

void function MarkAllWorkbenches()
{
	foreach( cluster in file.workbenchClusterArray )
	{
		table<int, var> result = CreateMarker(cluster)
		foreach( fxId, rui in result)
		{
			file.workbenchMarkerList.append( fxId )
			file.workbenchMarkerRuiList.append( rui )
		}
	}
}

bool function ShouldShowCraftingMapFeature()
{
	if( !GameMode_IsActive( eGameModes.SURVIVAL ) )
		return false


	if( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
		return false


	return true
}

void function Crafting_ShowCraftingMapFeature()
{
	if( !ShouldShowCraftingMapFeature() )
		return

	string mapName = GetMapName()
	bool showMapFeature = true

	//hide the Crafting Map Feature on Storm Point because we don't have enough space for Crafting. Other maps do have space however.
	//TODO: Refactor when a better system for managing too many enumerated map features is developed.
	if(  mapName.find( "mp_rr_tropic_island" ) >= 0 )
		showMapFeature = false

	if( showMapFeature )
	{
		if ( Crafting_IsDispenserCraftingEnabled() )
		{
			SetMapFeatureItem( 100, "#DISPENSER_MAP_FEATURE_TITLE", "#DISPENSER_MAP_FEATURE_DESC", Crafting_GetCraftingIcon( false ) )
		}
		else if ( !Crafting_IsDispenserCraftingEnabled() )
		{
			SetMapFeatureItem( 100, "#CRAFTING_CLUSTER_MAP_FEATURE", "#CRAFTING_CLUSTER_MAP_FEATURE_DESC", Crafting_GetCraftingIcon( false ) )
		}
	}
}

table<int, var> function CreateMarker( entity markedEnt, bool shouldFadeOutNearCrosshair = false )
{
	table<int, var> resultTable
	if ( !IsValid( markedEnt ) )
		return resultTable

	asset iconToUse = $""
	switch( markedEnt.GetScriptName() )
	{
		case HARVESTER_SCRIPTNAME:
			iconToUse = HARVESTER_ICON_ASSET
			break
		case WORKBENCH_CLUSTER_SCRIPTNAME:
			iconToUse = Crafting_GetCraftingIcon( false )
			break
	}

	int fxHandle
	if (Crafting_IsDispenserCraftingEnabled())
	{
		fxHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( WORKBENCH_DISPENSER_BEAM_FX ), markedEnt.GetOrigin(), markedEnt.GetAngles() )
		EffectSetControlPointVector( fxHandle, 1, WORKBENCH_DISPENSER_VFX_COLOR )
	}
	else
	{
		fxHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( WORKBENCH_BEAM_FX ), markedEnt.GetOrigin(), markedEnt.GetAngles() )
	}

	entity localViewPlayer = GetLocalViewPlayer()
	vector pos             = markedEnt.GetOrigin() + (markedEnt.GetUpVector() * 200)
	var rui                = CreatePermanentCockpitRui( $"ui/survey_beacon_marker_icon.rpak", RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), pos ) )
	RuiSetImage( rui, "beaconImage", iconToUse )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", pos )
	RuiSetFloat( rui, "sizeMin", 24 )
	RuiSetFloat( rui, "sizeMax", 40 )
	RuiSetFloat( rui, "minAlphaDist", 50000 )
	RuiSetFloat( rui, "maxAlphaDist", 200000 )
	RuiSetBool( rui, "shouldHideNearCrosshairs", shouldFadeOutNearCrosshair )
	RuiKeepSortKeyUpdated( rui, true, "pos" )

	EmitSoundOnEntity( localViewPlayer, "coop_minimap_ping" )

	resultTable[fxHandle] <- rui
	return resultTable
}

void function DestroyWorkbenchMarkers()
{
	foreach( id in file.workbenchMarkerList )
		EffectStop( id, true, false )

	file.workbenchMarkerList.clear()

	foreach( rui in file.workbenchMarkerRuiList )
	{
		RuiSetBool( rui, "isFinished", true )
	}

	file.workbenchMarkerRuiList.clear()
}


void function Crafting_OnGainFocus( entity ent )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetScriptName() == HARVESTER_SCRIPTNAME || ent.GetScriptName() == WORKBENCH_SCRIPTNAME )
		CustomUsePrompt_Show( ent )

}


void function Crafting_OnLoseFocus( entity ent )
{
	if ( ent != null && ent.GetScriptName() == HARVESTER_SCRIPTNAME )
		CustomUsePrompt_ClearForEntity( ent )
}

#if DEVELOPER
void function DEV_Crafting_TogglePreMatchRotation()
{
	if ( file.DEV_testingRotationRui )
	{
		file.DEV_testingRotationRui = false
	}
	else
	{
		file.gameStartRuiCreated = false
		file.DEV_testingRotationRui = true
		OnWaitingForPlayers_Client()
	}
}

void function DEV_Crafting_PrintUsedHarvesterEHIs()
{
	entity player = GetLocalViewPlayer()
	EHI playerEHI = ToEHI( player )

	if( playerEHI in file.usedHarvesterEHIs )
	{
		printt( format( "Used Harvester EHIs for %s", string( player ) ) )
		array< EHI > usedHarvesterEHIs = file.usedHarvesterEHIs[ playerEHI ]
		foreach( harvesterEHI in usedHarvesterEHIs )
		{
			printt( "Used Harvester EHI == " + harvesterEHI )
		}
	}
	else
	{
		printt( format( "%s has no used EHIs", string( player ) ) )
	}
}

#endif //DEVELOPER

void function OnWaitingForPlayers_Client()
{
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) || GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_TRAINING ) || HasWaitingGameStateArtHud() )
		return

	if ( file.gameStartRui.len() != 0 )
		Warning( "CRAFTING: OnWaitingForPlayers_Client() in sh_crafting.nut is being triggering multiple times - Code should investigate" )
	//This flag set is jank, remove this when we understand why this is hitting multiple times
	if ( file.gameStartRuiCreated )
		return

	if ( !Crafting_IsDispenserCraftingEnabled() )
	{
		file.gameStartRuiCreated = true
		var craftingGameStartRui = RuiCreate( $"ui/crafting_game_start.rpak", clGlobal.topoFullScreen, RUI_DRAW_POSTEFFECTS, 1 )
		file.gameStartRui.append( craftingGameStartRui )

		for ( int i = 0; i < 6; i++ )
		{
			var rui = SetupWorkbenchPreview( file.gameStartRui[0], i , "rotation" + i, false )
			file.gameStartRui.append( rui )
			//if ( i == 1 || i == 3 || i == 5)
			//RuiSetBool( rui, "shouldDisplayRotation", true )
		}
	}

	thread GameStart_CleanupThread()
}


void function GameStart_CleanupThread()
{
	OnThreadEnd(
		function() : (  )
		{
			if ( file.gameStartRui.len() != 0 )
			{
				RuiDestroy( file.gameStartRui[0] )
				file.gameStartRui.clear()
			}
		}
	)

	#if DEVELOPER
	while ( file.DEV_testingRotationRui )
	{
		WaitFrame()
	}
	#endif
	while ( GetGameState() == eGameState.WaitingForPlayers )
	{
		WaitFrame()
	}

	//end thread and cleanup when gamestate is no longer waiting for players
}


void function UICallback_PopulateCraftingPanel( var button )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	var rui = Hud_GetRui( button )
	if ( rui == null )
		return
	//only setup first 4 categories
	for ( int i = 0; i < 6; i++ )
	{
		var nestedRui = SetupWorkbenchPreview( rui, i , "rotation" + i, false )
		RuiSetBool( nestedRui, "shouldDisplayCost", false )
		if ( i == 1 || i == 3 || i == 5 )
			RuiSetBool( nestedRui, "shouldDisplayRotation", true )
	}
}


var function SetupWorkbenchPreview( var baseRui, int index, string uiHandle, bool shouldShowLimitedStock = true, bool shouldUseMini = false, string itemRefOverride = "" )
{
	RuiDestroyNestedIfAlive( baseRui, uiHandle )

	var rui = RuiCreateNested( baseRui, uiHandle, $"ui/crafting_button.rpak" )
	if ( shouldUseMini )
		RuiSetBool( rui, "isMini", true )

	RuiSetImage( rui, "iconImage", $"" )
	RuiSetInt( rui, "lootTier", 0 )
	RuiSetInt( rui, "cost", 0 )

	array< string > validItemList
	if ( itemRefOverride == "" )
	{
		validItemList = Crafting_GetLootDataFromIndex( index, GetLocalViewPlayer() )
	} else {
		validItemList.append( itemRefOverride )
	}

	RuiSetBool( rui, "isWeapon", false )
	RuiSetInt( rui, "limitedStockAmount", 0 )

	CraftingCategory ornull item
	item = GetCategoryForIndex( index )
	if ( item == null )
		return

	if ( validItemList.len() != 0 )
	{
		expect CraftingCategory( item )
		string refString = validItemList[0]
		int cost = item.itemToCostTable[refString]

		LootData lootRef = SURVIVAL_Loot_GetLootDataByRef( refString )
		asset hudIcon = lootRef.craftingIcon != $"" ? lootRef.craftingIcon : lootRef.hudIcon
		RuiSetImage( rui, "iconImage", hudIcon )
		RuiSetInt( rui, "lootTier", lootRef.tier )


			if ( lootRef.ref == "hopup_golden_horse_green" )
			{
				RuiSetInt( rui, "lootTier", GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER )
			}


		if ( lootRef.lootType == eLootType.MAINWEAPON )
		{
			RuiSetBool( rui, "isWeapon", true )
			RuiSetString( rui, "name", Localize( GetWeaponInfoFileKeyField_GlobalString( GetBaseWeaponRef(refString), "shortprintname" ) ) )
		}

		RuiSetInt( rui, "cost", cost )
	}

	RuiSetBool( rui, "isOwned", false )
	if ( item != null )
	{
		expect CraftingCategory( item )
		RuiSetInt( rui, "rotationStyle", item.rotationStyle )
	}

	return rui
}

void function OnGameStartedPlaying_Client()
{
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) || GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_TRAINING ) )
		return

	if ( file.fullmapInitialized )
	{
		printf( "CRAFTING: Cancelling fullmap init because it already exists" )
		return
	}

	if ( !Crafting_IsDispenserCraftingEnabled() )
	{
		file.fullmapRui.append( RuiCreate( $"ui/crafting_fullmap.rpak", clGlobal.topoFullscreenFullMap, FULLMAP_RUI_DRAW_LAYER, 20 ) )
		RuiTrackInt( file.fullmapRui[0], "craftingMaterials", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "craftingMaterials" ) )

		for ( int i = 0; i < 6; i++ )
		{
			if ( Crafting_IsDispenserCraftingEnabled() )
				break

			var rui = SetupWorkbenchPreview( file.fullmapRui[0], i, "rotation" + i, false )
			RuiSetBool( rui, "isMini", true )
			file.fullmapRui.append( rui )
		}

		InitHUDRui( file.fullmapRui[0] )
		Fullmap_AddRui( file.fullmapRui[0] )

		file.fullmapInitialized = true
	}

	#if DEVELOPER
	DEV_Crafting_Print( format( "CLIENT: Player Started Playing: %s", string( GetLocalViewPlayer() ) ) )
	#endif // DEVELOPER

	//thread NotificationThread()
}

//todo: Refactor notifications to display when player can craft something new
/*void function NotificationThread()
{
	FlagWaitClear( "CraftingNotificationLive" )
	FlagSet( "CraftingNotificationLive" )

	wait 3

	float displayTime = 20
	file.exclusivityNotification.append( CreatePermanentCockpitPostFXRui( $"ui/crafting_notification.rpak" ) )
	RuiSetGameTime( file.exclusivityNotification[0], "startTime", Time() )
	RuiSetGameTime( file.exclusivityNotification[0], "endTime", Time() + displayTime )

	int exclusiveCounter = 0
	array<string> leftOverDisabledItems = clone file.disabledGroundLoot
	foreach( item in file.disabledGroundLoot )
	{
		foreach ( group in file.craftingDataArray )
		{
			if ( group.itemsInCategory.contains( item ) || group.upgradesInCategory.contains( item ) )
			{
				SetupWorkbenchPreview( file.exclusivityNotification[0], -1, "exclusive" + exclusiveCounter, false, true, item )
				exclusiveCounter++
				leftOverDisabledItems.fastremovebyvalue( item )
				printf( "CRAFTING: Removing " + item + " from leftover disabled list" )
			}
		}
	}

	for( int i = 0; i<leftOverDisabledItems.len(); i++ )
	{
		SetupWorkbenchPreview( file.exclusivityNotification[0], -1, "disabled" + i, false, true, leftOverDisabledItems[i] )
		printf( "CRAFTING: Adding " + leftOverDisabledItems[i] + " to disabeld list" )
	}

	wait displayTime

	thread DeleteNotificationThread()
}*/

void function OnPlayerMatchStateChanged( entity player, int newState, int oldState )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( newState == ePlayerMatchState.NORMAL )
	{
		DestroyWorkbenchMarkers()
	}
}

/*void function DeleteNotificationThread()
{
	if ( file.exclusivityNotification.len() == 0 )
		return

	RuiSetGameTime( file.exclusivityNotification[0], "endTime", Time() )
	wait 1

	if ( file.exclusivityNotification.len() > 0)
	{
		foreach( rui in file.exclusivityNotification )
			RuiDestroyIfAlive( rui )
	}

	file.exclusivityNotification.clear()

	FlagClear( "CraftingNotificationLive" )
}*/

vector function GetCraftingColor()
{
	if ( Crafting_IsDispenserCraftingEnabled() )
	{
		return SrgbToLinear( CRAFTING_2PT0_COLOR / 255.0 )
	}

	return SrgbToLinear( <0, 255, 240> / 255.0 )
}


///////////////// WORKBENCH RUI //////////////
void function Crafting_Workbench_OpenCraftingMenu( entity workbench )
{
	file.playerIsCrafting = true

	CommsMenu_Shutdown( false )
	HideScoreboard()

	if ( !CommsMenu_CanUseMenu( GetLocalViewPlayer(), eChatPage.CRAFTING ) )
	{
		return
	}

	if ( Bleedout_IsBleedingOut( GetLocalViewPlayer() ) )
		return

	file.craftingItems_ClientList.clear()

	PushLockFOV()
	UpgradeSelectionMenu_TryClose()
	CommsMenu_OpenMenuTo( GetLocalViewPlayer(), eChatPage.CRAFTING, eCommsMenuStyle.CRAFTING, false )

	if ( GetLocalClientPlayer() == GetLocalViewPlayer() && GetCurrentPlaylistVarBool("crafting_enable_stuck_player_fix", false) )
	{
		thread Crafting_StuckPlayerWatchdog_Thread( workbench )
	}
}

void function Crafting_Workbench_OpenCraftingMenuAsSpectator( entity workbench )
{
	if ( !IsLocalPlayerOnTeamSpectator() )
		return

	CommsMenu_Shutdown( false )
	file.craftingItems_ClientList.clear()

	PushLockFOV()
	UpgradeSelectionMenu_TryClose()
	CommsMenu_OpenMenuTo( GetLocalViewPlayer(), eChatPage.CRAFTING, eCommsMenuStyle.CRAFTING, false )
}

void function Crafting_StuckPlayerWatchdog_Thread( entity workbench )
{
	Assert( GetLocalViewPlayer() == GetLocalClientPlayer(), "Spectators shouldn't be running this function" )

	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDeath", "OnDestroy")
	EndSignal( workbench, "OnDestroy" )

	while ( true )
	{
		WaitFrame()

		if ( IsCommsMenuActive() )
			continue

		wait 0.5

		entity crafter = player.GetParent()
		if ( !IsValid( crafter ) )
			break

		if ( crafter.GetScriptName() != WORKBENCH_CLUSTER_SCRIPTNAME )
			break

		Remote_ServerCallFunction( "ClientCallback_ClosedCraftingMenu" )
	}
}

bool function Crafting_OnMenuItemSelected( int index, var menuRui )
{
	if ( !file.isEnabled )
		return false

	CraftingCategory ornull item = GetCategoryForIndex( index )
	array< string > validItemList

	if ( item == null )
	{
		RuiSetGameTime( menuRui, "invalidSelectionTime", Time() )
		return false
	}

	expect CraftingCategory( item )
	entity player = GetLocalViewPlayer()

	validItemList = Crafting_GetLootDataFromIndex( index, player )

	int cost
	bool canBuy = true
	if ( validItemList.len() != 0 )
	{
		foreach ( ref in validItemList )
			cost += item.itemToCostTable[ref]

		if ( item.category == "evo" )
		{
			LootData existingArmorData = EquipmentSlot_GetEquippedLootDataForSlot( GetLocalViewPlayer(), "armor" )
			if ( existingArmorData.ref.find( "evolving" ) == -1 )
			{
				canBuy = false
			}
			else if ( existingArmorData.tier >= 5 )
			{

				canBuy = false
			}
			// TODO: else figure out evoTier and send it to the obit.
		}

		else if (  item.category == "banner" )
		{
			if ( Perk_CanBuyBanners( player ) )
				canBuy = true
			else
				canBuy = false
		}







	}
	else
	{
		canBuy = false
	}

	bool canAfford = Crafting_GetPlayerCraftingMaterials( player ) >= cost

	//only craft if available and in budget
	if (canBuy && canAfford)
	{
		Remote_ServerCallFunction( "ClientCallback_InitializeCraftingAtWorkbench", index )
		Crafting_Workbench_CloseCraftingMenu()
		return true
	}
	else
	{
		CraftingBundle bundle = GetBundleForCategory( item )
		RuiSetGameTime( bundle.attachedRui[index], "invalidSelectionTime", Time() )
		RuiSetGameTime( menuRui, "invalidSelectionTime", Time() )

		// Notify "<Name> needs $$ for crafting" to team if player can't afford.
		if( file.crafting_obit_notify )
		{
			int materialsNeeded = cost - Crafting_GetPlayerCraftingMaterials( player )
			if(( canBuy ) && ( materialsNeeded > 0 ))
			{
				Crafting_Obit_Items_Notify_Teammates( player, eCrafting_Obit_NotifyType.IS_REQUESTING_MATERIALS, materialsNeeded, index )
			}
		}

		return false
	}

	unreachable
}


void function TryCloseCraftingMenu()
{
	if ( GetLocalClientPlayer() == GetLocalViewPlayer() )
	{
		Crafting_Workbench_CloseCraftingMenu()
	}
	else
	{
		if ( file.craftingBetterSpectatorEnabled )
		{
			thread TryCloseCraftingMenuForSpectator_Thread()
		}
	}
}

void function TryCloseCraftingMenuForSpectator_Thread()
{
	wait 0.2
	Signal(GetLocalClientPlayer(), "crafting_kill_spectator_thread")
	Crafting_Workbench_CloseCraftingMenu()
}

void function ServerCallback_SetCraftingIndexForSpectator( int index )
{
	if ( GetLocalClientPlayer() == GetLocalViewPlayer() )
		return

	CommsMenu_SetCurrentChoiceForCrafting( index )
}

void function Crafting_Workbench_CloseCraftingMenu( )
{
	if ( !IsCommsMenuActive() )
		return
	if ( CommsMenu_GetCurrentCommsMenu() != eCommsMenuStyle.CRAFTING )
		return

	file.playerIsCrafting = false
	CommsMenu_Shutdown( true )
}

void function Crafting_OnWorkbenchMenuClosed( bool instant )
{
	if ( !file.isEnabled)
		return
	if ( GetLocalClientPlayer() == GetLocalViewPlayer() )
	{
		Remote_ServerCallFunction( "ClientCallback_ClosedCraftingMenu" )
	}
	PopLockFOV()

	file.playerIsCrafting = false
	file.craftingItems_ClientList.clear()
}

void function CreateWorkbenchWorldIcon( entity workbench, bool isLimitedStock = false )
{
	entity localViewPlayer = GetLocalViewPlayer()
	vector pos             = workbench.GetOrigin() + (workbench.GetUpVector() * 160)
	var rui                = CreateCockpitRui( $"ui/survey_beacon_marker_icon.rpak", RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), pos ) )
	RuiSetImage( rui, "beaconImage", isLimitedStock ? WORKBENCH_ICON_LIMITED_ASSET : Crafting_GetCraftingIcon( false ) )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", pos )
	RuiSetFloat( rui, "sizeMin", 48 )
	RuiSetFloat( rui, "minAlphaDist", 1000 )
	RuiSetFloat( rui, "maxAlphaDist", 3000 )
	RuiKeepSortKeyUpdated( rui, true, "pos" )
	file.workbenchRuiTable[workbench] <- rui
}

void function SetupProgressWaypoint( entity waypoint )
{
	if ( Crafting_IsDispenserCraftingEnabled() )
		return

	if ( waypoint.GetWaypointType() != eWaypoint.OBJECTIVE || Waypoint_GetPingTypeForWaypoint( waypoint ) != ePingType.OBJECTIVE )
	{
		return
	}

	thread SetupProgressWaypoint_Internal( waypoint )
}

void function SetupProgressWaypoint_Internal( entity waypoint )
{
	if ( waypoint.GetWaypointType() != eWaypoint.OBJECTIVE || Waypoint_GetPingTypeForWaypoint( waypoint ) != ePingType.OBJECTIVE )
	{
		return
	}

	int timeoutCounter = 0
	while ( IsValid( waypoint ) && waypoint.wp.ruiHud == null )
	{
		printf( "CRAFTING: Waypoint WaitFrame" )
		WaitFrame()
		timeoutCounter++
		if (timeoutCounter > 1000)
			return
	}

	if ( !IsValid( waypoint ) )
	{
		printf( "CRAFTING: Waypoint Invalid" )
		return
	}

	RuiSetFloat( waypoint.wp.ruiHud, "maxDrawDistance", 3000 )
	RuiSetFloat( waypoint.wp.ruiHud, "iconSize", 72.0 )
	RuiSetFloat( waypoint.wp.ruiHud, "iconSizePinned", 72.0 )
	RuiSetImage( waypoint.wp.ruiHud, "outerIcon", $"rui/events/s03e01a/item_source_icon" )
	RuiSetImage( waypoint.wp.ruiHud, "innerIcon", $"rui/events/s03e01a/item_source_icon" )
	RuiSetInt( waypoint.wp.ruiHud, "yourObjectiveStatus", 2 )
	RuiSetInt( waypoint.wp.ruiHud, "yourTeamIndex", GetLocalViewPlayer().GetTeam() )
	RuiSetInt( waypoint.wp.ruiHud, "roundState", 0 )
	RuiSetString( waypoint.wp.ruiHud, "pingPrompt", Localize( "#CRAFTING_PROMPT" ) )
	RuiSetString( waypoint.wp.ruiHud, "pingPromptForOwner", Localize( "#CRAFTING_PROMPT" ) )
	RuiSetBool( waypoint.wp.ruiHud, "reverseProgress", false )
	RuiSetBool( waypoint.wp.ruiHud, "iconColorOverride", true )
	RuiSetFloat3( waypoint.wp.ruiHud, "iconColor", Crafting_GetWaypointColor( waypoint ) )
	//RuiSetImage( waypoint.wp.ruiHud, "fillBackgroundImage", $"rui/hud/gametype_icons/obj_background_capturepoint" )
	//RuiSetImage( waypoint.wp.ruiHud, "fillImage", $"rui/hud/gametype_icons/obj_background_capturepoint_fill" )

	RuiTrackGameTime( waypoint.wp.ruiHud, "captureEndTime", waypoint, RUI_TRACK_WAYPOINT_GAMETIME, RUI_TRACK_INDEX_CAPTURE_END_TIME )
	RuiTrackFloat( waypoint.wp.ruiHud, "captureTimeRequired", waypoint, RUI_TRACK_WAYPOINT_FLOAT, RUI_TRACK_INDEX_REQUIRED_TIME )
	RuiTrackInt( waypoint.wp.ruiHud, "currentControllingTeam", waypoint, RUI_TRACK_WAYPOINT_INT, RUI_TRACK_INDEX_ACTIVATOR_TEAM )

	thread PlayWorkbenchPrintingFX( waypoint, waypoint.GetWaypointString( 0 )  )
}

void function PlayWorkbenchPrintingFX( entity waypoint, string animIndex )
{
	waypoint.EndSignal( "OnDestroy" )

	entity workbench = waypoint.GetParent()
	foreach ( cluster in workbench.GetLinkParentArray() )
	{
		if ( cluster.GetScriptName() == WORKBENCH_CLUSTER_SCRIPTNAME )
		{
			workbench = cluster
			break
		}
	}

	int attachId = workbench.LookupAttachment( "FX_DOOR_OPEN_" + animIndex )
	int fxHandle = StartParticleEffectOnEntity( workbench, GetParticleSystemIndex( WORKBENCH_PRINTING_FX ), FX_PATTACH_POINT_FOLLOW, attachId )
	vector lootTier = Crafting_GetWaypointColor( waypoint )

	EffectSetControlPointVector( fxHandle, 1, lootTier )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, true, false )
		}
	)

	WaitForever()
}

vector function Crafting_GetWaypointColor( entity waypoint, bool isVFX = false )
{
	switch( waypoint.GetWaypointInt( 6 ) )
	{
		case 1: //banners
			return SrgbToLinear( GetKeyColor( COLORID_HUD_HEAL_COLOR ) / 255.0 )
			break
		case 0:
		default:
			if( isVFX )
				return GetFXRarityColorForTier( waypoint.GetWaypointInt( 5 ) )
			else
				return ( GetKeyColor( COLORID_LOOT_TIER0 + waypoint.GetWaypointInt( 5 ) ) / 255.0 )
			break
	}

	return ( GetKeyColor( COLORID_LOOT_TIER0 + waypoint.GetWaypointInt( 5 ) ) / 255.0 )
}

void function ServerCallback_UpdateWorkbenchVars()
{
	if ( GetGameState() != eGameState.Playing )
		return

	CommsMenu_RefreshData()
}


void function ServerCallback_PromptNextHarvester( entity playerBeingAddressed, entity harvester )
{
	if( !IsValid( harvester ) )
		return

	if( !IsValid( playerBeingAddressed ) )
		return

	if ( ShouldMuteCommsActionForCooldown( GetLocalViewPlayer(), eCommsAction.REPLY_CRAFTING_NEXT_HARVESTER_OR_WORKBENCH, null) )
		return

	const float DELAY = 0.5
	const float DURATION = 5.0

	thread PromptAfterDelayThread( playerBeingAddressed, eCommsAction.REPLY_CRAFTING_NEXT_HARVESTER_OR_WORKBENCH, "#PING_CRAFTING_NEXT_HARVESTER" , DELAY, DURATION )
}

void function ServerCallback_PromptWorkbench( entity playerBeingAddressed, entity workbench )
{
	if ( ShouldMuteCommsActionForCooldown( GetLocalViewPlayer(), eCommsAction.REPLY_CRAFTING_NEXT_HARVESTER_OR_WORKBENCH, null) )
		return

	const float DELAY = 2.5
	const float DURATION = 6.0

	thread PromptAfterDelayThread( playerBeingAddressed, eCommsAction.REPLY_CRAFTING_NEXT_HARVESTER_OR_WORKBENCH, "#PING_CRAFTING_NEXT_WORKBENCH" , DELAY, DURATION )
}

void function ServerCallback_PromptAllWorkbenches( entity playerBeingAddressed )
{
	if ( ShouldMuteCommsActionForCooldown( GetLocalViewPlayer(), eCommsAction.REPLY_CRAFTING_PING_ALL_WORKBENCHES, null ) )
		return

	const float DELAY = 2.0

	thread PromptAfterDelayThread( playerBeingAddressed, eCommsAction.REPLY_CRAFTING_PING_ALL_WORKBENCHES, "#PING_CRAFTING_ALL_WORKBENCHES", DELAY )
}

void function PromptAfterDelayThread( entity player, int commAction, string promptText, float delay = 2.5, float duration = 10 )
{
	wait delay

	if ( !IsValid( player ) )
		return

	AddOnscreenPromptFunction( "quickchat", CreateQuickchatFunction( commAction, player ), duration, Localize( promptText ) )
}


void function Crafting_PopulateItemRuiAtIndex( var rui, int index )
{
	if ( !file.isEnabled )
		return

	if ( IsLobby() )
		return

	CraftingCategory ornull item = GetCategoryForIndex( index )
	array<string> validItemList

	if ( item == null )
		return

	expect CraftingCategory( item )
	validItemList = Crafting_GetLootDataFromIndex( index, GetLocalViewPlayer() )

	int cost
	bool canBuy = true

		if ( validItemList.len() != 0 && item.category != "evo" && item.category != "banner" && item.category != "event_special" )



	{
		foreach ( ref in validItemList )
			cost += item.itemToCostTable[ref]


		LootData lootRef = SURVIVAL_Loot_GetLootDataByRef( validItemList[0] )
		asset hudIcon = lootRef.craftingIcon != $"" ? lootRef.craftingIcon : lootRef.hudIcon
		RuiSetImage( rui, "icon", hudIcon )
		printt("CRAFTING LOOT ICON : " + lootRef.hudIcon)
		RuiSetInt( rui, "tier", lootRef.tier )

			if ( lootRef.ref == "hopup_golden_horse_green" )
			{
				RuiSetInt( rui, "tier", GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER )
			}


		if ( lootRef.lootType == eLootType.MAINWEAPON )
			RuiSetBool( rui, "isWeapon", true )
		else if ( lootRef.lootType == eLootType.AMMO && validItemList.len() > 1 && validItemList[1] != "" )
		{
			LootData lootRefAlt = SURVIVAL_Loot_GetLootDataByRef( validItemList[1] )
			RuiSetBool( rui, "isAmmo", true )
			RuiSetImage( rui, "altIcon", lootRefAlt.hudIcon )
			if ( lootRef.ref == BULLET_AMMO || lootRef.ref == HIGHCAL_AMMO || lootRef.ref == SPECIAL_AMMO )
			{
				RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * CRAFTING_AMMO_MULTIPLIER )
				if ( Crafting_IsDispenserCraftingEnabled() )
				{
					RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * Crafting_DispenserAmmoMulitplier() )
				}
			}

			if ( lootRefAlt.ref == BULLET_AMMO || lootRefAlt.ref == HIGHCAL_AMMO || lootRefAlt.ref == SPECIAL_AMMO )
			{
				RuiSetInt( rui, "ammoAmountAlt", lootRefAlt.countPerDrop * CRAFTING_AMMO_MULTIPLIER )
				if ( Crafting_IsDispenserCraftingEnabled() )
				{
					RuiSetInt( rui, "ammoAmountAlt", lootRefAlt.countPerDrop * Crafting_DispenserAmmoMulitplier() )
				}
			}

			if ( lootRef.ref == SHOTGUN_AMMO || lootRef.ref == ARROWS_AMMO || lootRef.ref == SNIPER_AMMO )
			{
				RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * CRAFTING_AMMO_MULTIPLIER_SMALL )
				if ( Crafting_IsDispenserCraftingEnabled() )
				{
					RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * Crafting_DispenserAmmoMulitplierSmall() )
				}
			}

			if ( lootRefAlt.ref == SHOTGUN_AMMO || lootRefAlt.ref == ARROWS_AMMO || lootRefAlt.ref == SNIPER_AMMO )
			{
				RuiSetInt( rui, "ammoAmountAlt", lootRefAlt.countPerDrop * CRAFTING_AMMO_MULTIPLIER_SMALL )
				if ( Crafting_IsDispenserCraftingEnabled() )
				{
					RuiSetInt( rui, "ammoAmountAlt", lootRefAlt.countPerDrop * Crafting_DispenserAmmoMulitplierSmall() )
				}
			}
		}
		else if ( lootRef.lootType == eLootType.AMMO )
		{
			if ( lootRef.ref == BULLET_AMMO || lootRef.ref == HIGHCAL_AMMO || lootRef.ref == SPECIAL_AMMO )
			{
				RuiSetBool( rui, "isAmmo", true )
				RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * CRAFTING_AMMO_MULTIPLIER )
				if ( Crafting_IsDispenserCraftingEnabled() )
				{
					RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * Crafting_DispenserAmmoMulitplier() )
				}
			}

			if ( lootRef.ref == SHOTGUN_AMMO || lootRef.ref == ARROWS_AMMO || lootRef.ref == SNIPER_AMMO )
			{
				RuiSetBool( rui, "isAmmo", true )
				RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * CRAFTING_AMMO_MULTIPLIER_SMALL )
				if ( Crafting_IsDispenserCraftingEnabled() )
				{
					RuiSetInt( rui, "ammoAmount", lootRef.countPerDrop * Crafting_DispenserAmmoMulitplierSmall() )
				}
			}
		}
	}
	else if ( validItemList.len() != 0 && item.category == "evo" )
	{
		cost = item.itemToCostTable[validItemList[0]]
		RuiSetImage( rui, "icon", $"rui/hud/gametype_icons/survival/crafting_evo_points" )
		RuiSetBool( rui, "isWeapon", true )

		LootData existingArmorData = EquipmentSlot_GetEquippedLootDataForSlot( GetLocalViewPlayer(), "armor" )
		if ( existingArmorData.ref.find( "evolving" ) == -1 )
		{
			canBuy = false
		}
		else
		{
			if ( existingArmorData.tier >= 5 )
				canBuy = false
		}
	}

		else if ( validItemList.len() != 0 && item.category == "banner" && ( GetRespawnStyle() == eRespawnStyle.RESPAWN_CHAMBERS ) && Player_Banners_Enabled() )
		{
			cost = item.itemToCostTable[validItemList[0]]
			RuiSetImage( rui, "icon", $"rui/hud/gametype_icons/survival/perk_craftable_banner_double_generic" )
			RuiSetBool( rui, "isWeapon", false )

			if ( Perk_CanBuyBanners( GetLocalViewPlayer() ) )
			{
				canBuy = true
			}
			else
			{
				canBuy = false
			}
		}











	else
	{
		canBuy = false
	}

	RuiSetInt( rui, "cost", cost )
	RuiSetString( rui, "rotationStyle", GetEnumString( "eCraftingRotationStyle", item.rotationStyle ) )

	bool canAfford = Crafting_GetPlayerCraftingMaterials( GetLocalViewPlayer() ) >= cost
	RuiSetBool( rui, "isEnabled", canBuy && canAfford )

	// Set Crafting 2.0 style
	//if ( Crafting_IsDispenserCraftingEnabled() )
	//	RuiSetBool( rui, "isCrafting2pt0", true )

	CraftingBundle bundle = GetBundleForCategory( item )
	bundle.attachedRui[index] <- rui

	Add_CraftingItem_To_ClientList( index, rui, cost, canBuy, canAfford )
}

// Save out item info to client list so availability can be updated when Materials are added:
void function Add_CraftingItem_To_ClientList( int index, var rui, int cost, bool canBuy, bool canAfford )
{
	int playerMaterials = Crafting_GetPlayerCraftingMaterials( GetLocalViewPlayer() )

	// If the item is already in the list, then just update it.
	foreach( itemInfo in file.craftingItems_ClientList )
	{
		if( itemInfo.index == index )
		{
			itemInfo.rui = rui
			itemInfo.cost = cost
			itemInfo.canBuy = canBuy
			itemInfo.canAfford = playerMaterials >= cost
			return
		}
	}

	CraftingItemInfo newItem
	newItem.index = index
	newItem.rui = rui
	newItem.cost = cost
	newItem.canBuy = canBuy
	newItem.canAfford = playerMaterials >= cost

	file.craftingItems_ClientList.append( newItem )
}

// Go through crafting items list and update their availability in the Crafting Menu.
void function Update_CraftingItems_Availabilities()
{
	int playerMaterials = Crafting_GetPlayerCraftingMaterials( GetLocalViewPlayer() )

	foreach( item in file.craftingItems_ClientList )
	{
		if( IsValid( item.rui ) )
		{
			bool newCanAfford = playerMaterials >= item.cost
			// TODO: UI Improvements- Look at itemInfo.canAfford vs newCanAfford to trigger item flourish if newly affordable.

			item.canAfford = newCanAfford
			RuiSetBool( item.rui, "isEnabled", item.canBuy && item.canAfford )
		}
	}
}

void function ServertoClientCallback_SetDispenserData( entity player, entity bench, entity cluster, entity minimapObj, bool isBanner, bool hasUsed )
{
	if ( !IsValid( player ) || !IsValid( bench ) || !IsValid( cluster ) || !IsValid( minimapObj ) )
		return

	WorkbenchData dispensorData = file.workbenchDataTable_Client[ bench ]
	dispensorData.workbench = bench
	if ( isBanner && ( Perks_GetRoleForPlayer( player ) == eCharacterClassRole.SUPPORT ) && Crafting_DispenserFreeSupportBanner() )
	{
		//dooooooo nothing - there is a pretty way to do this i'm sure
	}
	else if ( !hasUsed )
	{
		dispensorData.playersHaveUsed.clear()
		file.workbenchDataTable_Client[ bench ] <- dispensorData
		if ( player == GetLocalViewPlayer() )
		{
			thread PlayClientSideWorkbenchHologramFX( cluster )
			ResetDispenserIcons( cluster, minimapObj )
			thread DisplayDelayedReactivationMessage( player )
		}
	}
	else
	{
		dispensorData.playersHaveUsed[ player ] <- hasUsed
		file.workbenchDataTable_Client[ bench ] <- dispensorData
		if ( player == GetLocalViewPlayer() )
		{
			cluster.Signal( "OnPlayerUsedDispenser")
			SetDispenserIconsAsUsed( cluster, minimapObj )
		}
	}
}

void function SetDispenserIconsAsUsed( entity dispenser, entity minimapObj )
{
	if ( !IsValid( minimapObj ) || !(minimapObj in file.dispenserMapRuiTable) )
		return

	RuiSetFloat3( file.dispenserMapRuiTable[minimapObj], "iconColor", GetCraftingColor() )
	RuiSetFloat3( file.dispenserMinimapRuiTable[minimapObj], "iconColor", GetCraftingColor() )

	RuiSetImage( file.dispenserMapRuiTable[minimapObj], "defaultIcon", $"" )
	RuiSetImage( file.dispenserMinimapRuiTable[minimapObj], "defaultIcon", $"" )

	RuiSetImage( file.dispenserMapRuiTable[minimapObj], "smallIcon", $"" )
	RuiSetImage( file.dispenserMinimapRuiTable[minimapObj], "smallIcon", $"" )
}

void function ResetDispenserIcons( entity dispenser, entity minimapObj )
{
	if ( !IsValid( minimapObj ) || !(minimapObj in file.dispenserMapRuiTable) )
		return

	RuiSetFloat3( file.dispenserMapRuiTable[minimapObj], "iconColor", GetCraftingColor() )
	RuiSetFloat3( file.dispenserMinimapRuiTable[minimapObj], "iconColor", GetCraftingColor() )

	bool isAirdrop = dispenser.GetModelName() == WORKBENCH_CLUSTER_AIRDROP_MODEL

	RuiSetImage( file.dispenserMapRuiTable[minimapObj], "defaultIcon", Crafting_GetCraftingIcon( isAirdrop ) )
	RuiSetImage( file.dispenserMinimapRuiTable[minimapObj], "defaultIcon", Crafting_GetCraftingIcon( isAirdrop ) )

	if ( !isAirdrop )
	{
		RuiSetImage( file.dispenserMapRuiTable[minimapObj], "smallIcon", Crafting_GetSmallCraftingIcon() )
		RuiSetImage( file.dispenserMinimapRuiTable[minimapObj], "smallIcon", Crafting_GetSmallCraftingIcon() )

		RuiSetBool( file.dispenserMapRuiTable[minimapObj], "hasSmallIcon", true )
		RuiSetBool( file.dispenserMinimapRuiTable[minimapObj], "hasSmallIcon", true )
	}
}

void function DisplayDelayedReactivationMessage( entity player )
{
	wait 8.5

	if( GetLocalViewPlayer() == player )
	{
		AnnouncementMessageSweep( GetLocalViewPlayer(),  "#DISPENSER_REACTIVATED_ANNOUNCEMENT" , "", GetCraftingColor(), $"", SFX_HUD_ANNOUNCE_QUICK, 3.0 )
	}
}

void function PlayClientSideWorkbenchHologramFX( entity workbench )
{
	if ( !IsValid( workbench ) )
		return

	workbench.Signal( "OnNewHoloStartPlaying" ) //Stop any existing before starting a new one. Preventing overlapping Holo FX

	workbench.EndSignal( "OnDestroy" )
	workbench.EndSignal ( "OnPlayerUsedDispenser" )
	workbench.EndSignal ( "OnNewHoloStartPlaying" )

	int attachId = workbench.LookupAttachment( "FX_LIGHT" )
	int holoFx = StartParticleEffectOnEntityWithPos( workbench, GetParticleSystemIndex( WORKBENCH_DISPENSER_HOLO_COLOR_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachId, <0, 0, 0>, <-90, 0, 0> )
	EffectSetControlPointVector( holoFx, 1, WORKBENCH_DISPENSER_VFX_COLOR )

	OnThreadEnd(
		function() : ( holoFx )
		{
			if ( EffectDoesExist( holoFx ) )
			{
				EffectStop( holoFx, false, true )
			}
		}
	)

	WaitForever()
}

bool function Crafting_IsPlayerCrafting()
{
	return file.playerIsCrafting
}
#endif // CLIENT






















































































































































































































































































































































#if CLIENT
entity function GetCrafterUnderAim( vector worldPos, float worldRange )
{
	float closestDistSqr        = FLT_MAX
	float worldRangeSqr = worldRange * worldRange
	entity closestEnt = null

	if( MapPing_Modify_DistanceCheck_Enabled() )
	{
		float modifier = MapPing_DistanceCheck_GetModifier()

		if( worldRange >= MapPing_DistanceCheck_GetDistanceRange() )
			modifier *= 0.5

		worldRangeSqr = ( worldRange * modifier ) * ( worldRange * modifier )
	}

	foreach ( crafter in file.workbenchClusterArray )
	{
		if ( !IsValid( crafter ) )
			continue

		vector crafterOrigin = crafter.GetOrigin()

		float distSqr = Distance2DSqr( crafterOrigin, worldPos )
		if ( distSqr < worldRangeSqr && distSqr < closestDistSqr  )
		{
			closestDistSqr = distSqr
			closestEnt     = crafter
		}
	}

	if ( !IsValid( closestEnt ) )
	{
		return null
	}

	return closestEnt
}

bool function PingCrafterUnderAim( entity crafter )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) || !IsAlive( player ) )
		return false

	if ( !IsPingEnabledForPlayer( player ) )
		return false

	Remote_ServerCallFunction( FUNCNAME_PingCrafterFromMap, crafter )

	EmitSoundOnEntity( GetLocalViewPlayer(), PING_SOUND_LOCAL_CONFIRM )

	return true
}
#endif

#if SERVER
void function Crafting_ClientToServer_PingCrafterFromMap( entity player, entity crafter )
{
	if ( IsValid( player ) && IsValid( crafter ) )
	{
		if ( Crafting_IsDispenserCraftingEnabled() )
		{
			int pingType
			int notifyType = Dispensers_GetReplicatorStateForPlayer( player, crafter )
			switch( notifyType )
			{
				case eCrafting_Dispenser_StateType.NO_ONE_HAS_USED:
					pingType = ePingType.PING_REPLICATOR_NOONE_USED
					break
				case eCrafting_Dispenser_StateType.ALL_USED:
					pingType = ePingType.PING_REPLICATOR_ALL_USED
					break
				case eCrafting_Dispenser_StateType.PLAYER_HAS_USED:
					pingType = ePingType.PING_REPLICATOR_PLAYER_USED
					break
				case eCrafting_Dispenser_StateType.TEAMMATE_HAS_USED:
					pingType = ePingType.PING_REPLICATOR_TEAMMATE_USED
					break
				default:
					pingType = ePingType.PING_REPLICATOR
					break
			}
			CreateWaypoint_Ping_Location( player, pingType, crafter, crafter.GetOrigin() + <0, 0, 50>, -1, false )
		}
		else
		{
			CreateWaypoint_Ping_Location( player, ePingType.PING_REPLICATOR, crafter, crafter.GetOrigin() + <0, 0, 50>, -1, false )
		}
	}
}
#endif