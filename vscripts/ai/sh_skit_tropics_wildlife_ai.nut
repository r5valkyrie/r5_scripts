global function TropicsWildlife_Init
global function TropicsWildlife_PreMapInit
global function IsTropicsWildlifeEnabled

#if DEVELOPER && SERVER
global function DEV_TropicsWildlife_PrintCampDetails
global function DEV_TropicsWildlife_PrintCampDetailsAll
global function DEV_TropicsWildlife_PrintTotalAIOnMap
global function DEV_TropicsWildlife_ToggleDebugDrawAssaultRadii
global function DEV_TropicsWildlife_ToggleDebugDrawActivationRadii
global function DEV_TropicsWildlife_ToggleCampsEnabled
global function DEV_TropicsWildlife_SpawnXSpiders
global function DEV_TropicsWildlife_SpawnXProwlers
global function DEV_TropicsWildlife_DestroyAllSkits
global function DEV_TropicsWildlife_CreateAllSkits
global function DEV_TropicsWildlife_HardResetAllSkits
#endif // DEV && SERVER

#if SERVER
global function Wildlife_ClientToServer_PingWildlifeFromMap
global function DEV_TropicsWildlife_GetCampDetailsAllString
#endif

#if CLIENT
global function Wildlife_ServerToClient_SetWildlifeClientEnt
global function ServerCallback_CL_CampClearedNoMaterialRewards
#endif

#if DEVELOPER
const bool TROPICS_WILDLIFE_AI_DEBUG = false
#endif // DEV

#if CLIENT
const asset PROWLER_PIT_CAMP_ICON = $"rui/hud/gametype_icons/survival/prowler_pit_icon"
const asset PROWLER_PIT_CAMP_ICON_SMALL = $"rui/hud/gametype_icons/survival/prowler_pit_small"

const asset PROWLER_CAMP_ICON = $"rui/hud/gametype_icons/survival/prowler_icon"
const asset PROWLER_CAMP_ICON_SMALL = $"rui/hud/gametype_icons/survival/ai_camp_small"

const asset SPIDER_CAMP_ICON = $"rui/hud/gametype_icons/survival/spider_icon"
const asset SPIDER_CAMP_ICON_SMALL = $"rui/hud/gametype_icons/survival/ai_camp_small"
const asset WILDLIFE_CAMP_SPAWNPOINT_ICON = $"rui/hud/gametype_icons/survival/wildlife_ai_camp"
#endif


#if CLIENT || SERVER
const string FUNCNAME_SetWildlifeClientEnt = "Wildlife_ServerToClient_SetWildlifeClientEnt"
const string FUNCNAME_PingWildlifeFromMap = "Wildlife_ClientToServer_PingWildlifeFromMap"
#endif


const string EDITOR_CLASS_CAMP_ROOT_KEYWORD = "info_ai_camp_node"
const string EDITOR_CLASS_CAMP_ASSAULT_RADIUS_KEYWORD = "info_ai_camp_assaultradius"
const string EDITOR_CLASS_CAMP_TREASURE_CHEST_KEYWORD = "info_ai_camp_treasurechest"

const string EDITOR_CLASS_PROWLER_SPAWNPOINT_KEYWORD = "info_ai_spawnpoint_prowler"
const string EDITOR_CLASS_SPIDER_SPAWNPOINT_KEYWORD = "info_ai_spawnpoint_spider"




const string EDITOR_CLASS_SPIDER_EGG_KEYWORD = "script_ai_spider_egg"
const string EDITOR_CLASS_PROWLER_DEN_KEYWORD = "script_ai_prowler_den"

const string SCRIPT_NAME_GOLIATH_PIT_KEYWORD = "goliath_pit"

const string WILDLIFE_SPAWNER_INFOENT_BASECLASS = "info_target"
const string WILDLIFE_CAMPNODE_INFOENT_BASECLASS = "script_ref"

const string PROWLER_RESET_ASSAULT_SIGNAL_KEYWORD = "OnResetProwlerAssaultRadius"
const string END_DEATHFIELD_MONITOR_SIGNAL_KEYWORD = "OnEndDeathFieldMonitor"
const string EXTERNAL_CAMP_MONITOR_SIGNAL_KEYWORD = "OnEndExternalCampMonitor"
const string CANCEL_SPAWNLOCK_MONITOR_SIGNAL_KEYWORD = "OnCancelSpawnLockMonitor"

const int MAX_SPIDERS_ALLOWED_ALIVE_IN_SPIDER_NEST = 12

global const int WILDLIFE_MAX_FLYER_COUNT = 54

const float WILDLIFE_ASSAULTPOINT_HEIGHT = 1750.0
const float WILDLIFE_ASSAULTPOINT_DEFAULT_RADIUS = 2048.0
const float PROWLER_DISENGAGE_DISTANCE = 3000.0

const float WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE = 2.0

const float WILDLIFE_SMARTLOOT_CAMP_RADIUS_SCALAR = 1.25
const float WILDLIFE_SMARTLOOT_TEAM_RADIUS_LIMITER = 1024.0

const int AI_LIMIT = 190
const float REWARD_MESSAGE_DELAY = 1.5

#if SERVER
global enum eGeneratorType
{
	SPIDER_EGG,
	PROWLER_DEN
}

struct NPCSpawnerData
{
	int npcType = -1		// eNPC

	vector origin
	vector angles

	bool isLinkedToCamp = false
}

struct NPCGeneratorData // a spawn closet
{
	int type = -1 // eGeneratorType

	bool exhausted = false

	int maxLife = -1

	vector origin
	vector angles

	bool isLinkedToCamp = false
}

struct AssaultPointData
{
	vector origin
	float radius = -1.0

	bool isLinkedToCamp = false
}

struct TreasureChestData
{
	vector origin
	vector angles

	bool isSelected = false
	bool isLinkedToCamp = false
}

struct WildlifeCampData
{
	int type = -1 // eCampType

	array<NPCSpawnerData> linkedNPCSpawners
	array<NPCGeneratorData> linkedNPCGenerators
	array<TreasureChestData> linkedTreasureChests

	vector activationOrigin
	float activationRadius = -1.0

	bool hasAssaultPoint = false
	AssaultPointData& assaultPoint
	float fullAssaultRadius = -1.0

	bool limitProwlerAssaultRadius = true

	bool isActive = false
	bool isDisabled = false // used for playlist var control on if a camp is on or off

	int totalLife = 0 // the total AI at this camp (spawned at spawnpoints and tallied total of all generators
	int lifeRemaining = 0 // the remaining life of the total AI camp
	int initialSpawnTotal = 0
	int maxAlive = 0 // the total amount of AI allowed to be alive at a camp at one time

	string scriptName = ""

	// todo (tgoodbrand): how to save & restore npcs spawned from generators when activating/deactivating camps
	array<Point> cachedDormantNPCs
	array<entity> activeNPCs
	array<entity> npcGeneratorEnts

	entity treasureChest

	entity minimapIcon

	table<int, TeamLootTracker> lootTrackers // key = teamId

	struct
	{
		array<string> childGUIDs
	} _setup
}

int s_maxAllowedAIAlive = 100
bool s_treasureChestEnabled = true

bool s_campsActivationEnabled = true
bool s_generatorsCreated = false
bool s_treasureChestsCreated = false

bool s_isMatchWinnerDetermined = false
bool s_wildlifeRuntimeActive = false
bool s_wildlifeRuntimeThreadRunning = false

int s_totalAliveAI = 0

array<entity> s_setup_campNodes
array<entity> s_setup_assaultPoints
array<entity> s_setup_npcSpawners
array<entity> s_setup_treasureChests

array<WildlifeCampData> s_wildlifeCampDatas
array<WildlifeCampData> s_activeWildlifeCampDatas
array<WildlifeCampData> s_externalWildlifeCampDatas
array<AssaultPointData> s_assaultPointDatas
array<NPCGeneratorData> s_spiderEggGeneratorDatas
array<NPCGeneratorData> s_prowlerDenGeneratorDatas
array<TreasureChestData> s_treasureChestDatas
array<NPCSpawnerData> s_prowlerSpawnPoints
array<NPCSpawnerData> s_spiderSpawnPoints




// TODO (tgoodbrand): these should be skit resources???
table<SpiderEggData, WildlifeCampData> s_spiderEggToWildlifeCamp
table<ProwlerDenData, WildlifeCampData> s_prowlerDenToWildlifeCamp
#endif // SERVER

#if CLIENT
struct WildlifeTrackingData
{
	entity rootEnt
	bool active
	int wildlifeType = -1 // eCampType
}

struct{
	table < entity, WildlifeTrackingData > wildlifeEntStatuses
}file
#endif

void function TropicsWildlife_PreMapInit()
{
	AddCallback_OnNetworkRegistration( TropicsWildlife_OnNetworkRegistration )
}

void function TropicsWildlife_Init()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_Init()")
	#endif

	if ( !IsTropicsWildlifeEnabled() )
	{
		#if DEVELOPER
			if ( TROPICS_WILDLIFE_AI_DEBUG )
				printf("TropicsWildlife_Init: Map AI disabled. (See: Playlist var wildlife_ai_enabled)")
		#endif
		return
	}

	TropicsWildlife_InitializeNPCDependencies()

	RegisterSignal( PROWLER_RESET_ASSAULT_SIGNAL_KEYWORD )
	RegisterSignal( END_DEATHFIELD_MONITOR_SIGNAL_KEYWORD )
	RegisterSignal( EXTERNAL_CAMP_MONITOR_SIGNAL_KEYWORD )
	RegisterSignal( CANCEL_SPAWNLOCK_MONITOR_SIGNAL_KEYWORD )

	SpiderEgg_Init()

	#if SERVER
		SetCallback_SpiderEgg_OnSpiderSpawn( SpiderEggOnSpawnCallback )
		SetCallback_SpiderEgg_OnAdditionalSpawnCheck( SpiderEggOnAdditionalSpawnCheckCallback )

		ProwlerDen_Init()
		SetCallback_ProwlerDen_OnProwlerSpawn( ProwlerDenOnSpawnCallback )
		SetCallback_ProwlerDen_OnAdditionalSpawnCheck( ProwlerDenOnAdditionalSpawnCheckCallback )

		s_maxAllowedAIAlive = GetCurrentPlaylistVarInt( "wildlife_ai_max_allowed_alive", 100 )
		s_treasureChestEnabled = GetCurrentPlaylistVarBool( "wildlife_ai_treasure_chest_enabled", true )

		if( s_maxAllowedAIAlive >= AI_LIMIT )
		{
			s_maxAllowedAIAlive = AI_LIMIT-1
		}

		AddCallback_EntitiesDidLoad( TropicsWildlife_EntitiesDidLoad )

		AddSpawnCallbackEditorClass( "script_ref", EDITOR_CLASS_CAMP_ROOT_KEYWORD, TropicsWildlife_CampNode_OnSpawnCallbackEditorClass )
		AddSpawnCallbackEditorClass( "script_ref", EDITOR_CLASS_CAMP_ASSAULT_RADIUS_KEYWORD, TropicsWildlife_AssaultPoint_OnSpawnCallbackEditorClass )
		AddSpawnCallbackEditorClass( "script_ref", EDITOR_CLASS_CAMP_TREASURE_CHEST_KEYWORD, TropicsWildlife_TreasureChest_OnSpawnCallbackEditorClass )
		AddSpawnCallbackEditorClass( "info_target", EDITOR_CLASS_PROWLER_SPAWNPOINT_KEYWORD, TropicsWildlife_ProwlerSpawner_OnSpawnCallbackEditorClass )
		AddSpawnCallbackEditorClass( "info_target", EDITOR_CLASS_SPIDER_SPAWNPOINT_KEYWORD, TropicsWildlife_SpiderSpawner_OnSpawnCallbackEditorClass )
		AddCallback_OnSurvivalDeathFieldStageChanged( TropicsWildlife_OnSurvivalDeathFieldStageChanged )
		//SURVIVAL_AddCallback_OnDeathFieldStartShrink( TropicsWildlife_OnDeathFieldStartShrink )
		//SURVIVAL_AddCallback_OnDeathFieldStopShrink( TropicsWildlife_OnDeathFieldStopShrink )
		AddCallback_GameStateEnter( eGameState.WinnerDetermined, TropicsWildlife_OnWinnerDetermined )
		AddCallback_GameStateEnter( eGameState.Playing, Wildlife_InitClientTrackingEnts )
	#endif

	#if CLIENT
		Waypoints_RegisterCustomType( "broadcasthudsplash_msg", Instance_BroadcastHudSplashToRadius )
		Waypoints_RegisterCustomType( "highlighter", InstanceHighlighterWP )
		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.SPIDER_CAMP, MINIMAP_OBJECT_RUI, MinimapPackage_SpiderCamp, FULLMAP_OBJECT_RUI, FullmapPackage_SpiderCamp )
		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.PROWLER_CAMP, MINIMAP_OBJECT_RUI, MinimapPackage_ProwlerCamp, FULLMAP_OBJECT_RUI, FullmapPackage_ProwlerCamp )
		SetMapFeatureItem( 1000, "#WILDLIFE_CAMP", "#WILDLIFE_CAMP_DESC", WILDLIFE_CAMP_SPAWNPOINT_ICON )

		if( Wildlife_PingFromMap_Enabled() )
			AddCallback_OnFindFullMapAimEntity( GetWildlifeUnderAim, PingWildlifeUnderAim )
	#endif
}
#if CLIENT
void function Instance_BroadcastHudSplashToRadius( entity wp )
{
	entity player = GetLocalClientPlayer()
	if ( !IsAlive( player ) )
		return

	string messageText = wp.GetWaypointString( 0 )
	string subText = wp.GetWaypointString( 1 )
	vector origin = wp.GetWaypointVector( 0 )
	float range = wp.GetWaypointFloat( 0 )
	float duration = wp.GetWaypointFloat( 1 )

	if ( (range > 0.0) && (Distance( player.GetOrigin(), origin ) > range) )
		return


	AnnouncementMessageSweep( GetLocalClientPlayer(), messageText, subText, <220,220,220>, $"", SFX_HUD_ANNOUNCE_QUICK, duration )
}

void function InstanceHighlighterWP( entity wp )
{
	array<entity> ents
	for ( int idx = 0; idx < 8; ++idx )
	{
		entity ent = wp.GetWaypointEntity( idx )
		if ( IsValid( ent ) )
			ents.append( ent )
	}

	thread function() : (wp, ents)
	{
		foreach( ent in ents )
			ent.Highlight_PushPingedState()

		wp.EndSignal( "OnDestroy" )
		OnThreadEnd( function() : (ents)
		{
			foreach( ent in ents )
			{
				if ( IsValid( ent ) )
					ent.Highlight_PopPingedState()
			}
		} )

		WaitForever()
	}()
}
#endif

#if CLIENT||SERVER
bool function Wildlife_PingFromMap_Enabled()
{
	return GetCurrentPlaylistVarBool( "wildlife_pingfrommap_enabled", true )
}
#endif

void function TropicsWildlife_OnNetworkRegistration()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_OnNetworkRegistration()")
	#endif

	#if SERVER || CLIENT
		if( Wildlife_PingFromMap_Enabled() )
		{
			//Remote_RegisterServerFunction( FUNCNAME_PingWildlifeFromMap, "typed_entity", "prop_script", "int", -1, INT_MAX  )
			Remote_RegisterClientFunction( FUNCNAME_SetWildlifeClientEnt, "entity", "bool", "int", -1, INT_MAX )
		}
	#endif

	Remote_RegisterClientFunction( "ServerCallback_CL_CampClearedNoMaterialRewards", "int", 0, eWildLifeCampType.Count - 1 )
}

#if CLIENT
void function MinimapPackage_SpiderCamp( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", SPIDER_CAMP_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )

	RuiSetBool( rui, "useTeamColor", false )

	RuiSetImage( rui, "smallIcon", SPIDER_CAMP_ICON_SMALL )
	RuiSetBool( rui, "hasSmallIcon", true )
}

void function FullmapPackage_SpiderCamp( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", SPIDER_CAMP_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )

	RuiSetBool( rui, "useTeamColor", false )

	RuiSetImage( rui, "smallIcon", SPIDER_CAMP_ICON_SMALL )
	RuiSetBool( rui, "hasSmallIcon", true )
}

void function MinimapPackage_ProwlerCamp( entity ent, var rui )
{
	asset prowlerIconName = PROWLER_CAMP_ICON
	asset smallProwlerIconName = PROWLER_CAMP_ICON_SMALL
	if ( ent.GetScriptName() == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
	{
		prowlerIconName = PROWLER_PIT_CAMP_ICON
		smallProwlerIconName = PROWLER_PIT_CAMP_ICON_SMALL
	}

	RuiSetImage( rui, "defaultIcon", prowlerIconName )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )

	RuiSetBool( rui, "useTeamColor", false )

	RuiSetImage( rui, "smallIcon", smallProwlerIconName )
	RuiSetBool( rui, "hasSmallIcon", true )
}

void function FullmapPackage_ProwlerCamp( entity ent, var rui )
{
	asset prowlerIconName = PROWLER_CAMP_ICON
	asset smallProwlerIconName = PROWLER_CAMP_ICON_SMALL
	if ( ent.GetScriptName() == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
	{
		prowlerIconName = PROWLER_PIT_CAMP_ICON
		smallProwlerIconName = PROWLER_PIT_CAMP_ICON_SMALL
	}

	RuiSetImage( rui, "defaultIcon", prowlerIconName )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )

	RuiSetBool( rui, "useTeamColor", false )

	RuiSetImage( rui, "smallIcon", smallProwlerIconName )
	RuiSetBool( rui, "hasSmallIcon", true )
}

void function ServerCallback_CL_CampClearedNoMaterialRewards( int campIndex )
{
	string msg = WILDLIFE_REWARD_STRINGS[ campIndex ]
	AnnouncementMessageRight( GetLocalClientPlayer(), msg, "", <214,214,214>, $"", 2, "UI_TropicsAI_AreaCompletionStinger" )
}
#endif

#if SERVER
void function TropicsWildlife_CampNode_OnSpawnCallbackEditorClass( entity campNode )
{
	s_setup_campNodes.push( campNode )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_CampNode_OnSpawnCallbackEditorClass: Total Camp Nodes = " + s_setup_campNodes.len() )
	#endif
}

void function TropicsWildlife_AssaultPoint_OnSpawnCallbackEditorClass( entity assaultPoint )
{
	s_setup_assaultPoints.push( assaultPoint )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_AssaultPoint_OnSpawnCallbackEditorClass: Total Camp Nodes = " + s_setup_assaultPoints.len() )
	#endif
}

void function TropicsWildlife_TreasureChest_OnSpawnCallbackEditorClass( entity treasureChest )
{
	s_setup_treasureChests.push( treasureChest )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_TreasureChest_OnSpawnCallbackEditorClass: Total Camp Nodes = " + s_setup_treasureChests.len() )
	#endif
}

void function TropicsWildlife_SpiderSpawner_OnSpawnCallbackEditorClass( entity spiderSpawner )
{
	s_setup_npcSpawners.push( spiderSpawner )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_SpiderSpawner_OnSpawnCallbackEditorClass: Total Camp Nodes = " + s_setup_npcSpawners.len() )
	#endif
}

void function TropicsWildlife_ProwlerSpawner_OnSpawnCallbackEditorClass( entity prowlerSpawner )
{
	s_setup_npcSpawners.push( prowlerSpawner )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_ProwlerSpawner_OnSpawnCallbackEditorClass: Total Camp Nodes = " + s_setup_npcSpawners.len() )
	#endif
}

void function Wildlife_InitClientTrackingEnts( )
{
	if( Wildlife_PingFromMap_Enabled() )
	{
		foreach( player in GetPlayerArray() )
		{
			foreach( WildlifeCampData data in s_wildlifeCampDatas )
			{
				if( IsValid( data.minimapIcon ) ) //data.npcGeneratorEnts.len() > 0 )
				{
					entity spawnerEnt = data.minimapIcon //data.npcGeneratorEnts[0]
					bool active = true
					int campType = data.type

					Remote_CallFunction_NonReplay( player, FUNCNAME_SetWildlifeClientEnt, spawnerEnt, active, campType )
				}
			}
		}
	}
}

void function TropicsWildlife_OnWinnerDetermined()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_OnWinnerDetermined: Turn off AI sensing" )
	#endif

	s_isMatchWinnerDetermined = true
	Signal( svGlobal.levelEnt, END_DEATHFIELD_MONITOR_SIGNAL_KEYWORD )
	Signal( svGlobal.levelEnt, EXTERNAL_CAMP_MONITOR_SIGNAL_KEYWORD )
	Signal( svGlobal.levelEnt, CANCEL_SPAWNLOCK_MONITOR_SIGNAL_KEYWORD )

	foreach ( WildlifeCampData campData in s_activeWildlifeCampDatas )
	{
		foreach ( entity npc in campData.activeNPCs )
		{
			npc.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
		}

		if ( campData.type == eWildLifeCampType.PROWLER_DENS )
		{
			foreach ( entity denEntity in campData.npcGeneratorEnts )
			{
				ProwlerDenData denData = GetProwlerDenData( denEntity )
				ProwlerDen_SetActive( denData, false )
			}
		}
	}
}

void function TropicsWildlife_OnDeathFieldStartShrink( table<int,DeathFieldData> deathFieldData )
{
	Signal( svGlobal.levelEnt, EXTERNAL_CAMP_MONITOR_SIGNAL_KEYWORD )

	s_externalWildlifeCampDatas.clear()
	array<WildlifeCampData> campDatas = clone s_activeWildlifeCampDatas
	vector nextCircleCenter = SURVIVAL_GetDeathFieldCenter()
	float roundEndRadius = SURVIVAL_Server_GetNextDeathFieldEndRadius()
	foreach ( WildlifeCampData campData in s_activeWildlifeCampDatas )
	{
		float distance = Distance2D( campData.assaultPoint.origin, nextCircleCenter )
		float maxDistance = roundEndRadius - campData.fullAssaultRadius // include camps that may only be partially covered by the ring
		if ( distance <= maxDistance )
		{
			campDatas.removebyvalue( campData )
		} else { // add the camp to a list that can be monitored when the ring stops moving (and isn't cleared on round change)
			s_externalWildlifeCampDatas.push( campData )
		}
	}

	thread MarkWildifeInDeathfieldPassive_Thread( campDatas, nextCircleCenter, true )
}

void function MarkWildifeInDeathfieldPassive_Thread( array<WildlifeCampData> campDatas, vector circleCenter, bool isDeathfieldMoving )
{
	EndSignal( svGlobal.levelEnt, END_DEATHFIELD_MONITOR_SIGNAL_KEYWORD )
	EndSignal( svGlobal.levelEnt, EXTERNAL_CAMP_MONITOR_SIGNAL_KEYWORD )

	const float SPAWN_TIME_IGNORE_WINDOW = 3.0
	const float PASSIVE_CHECK_TICK_RATE = 1.0

	while (true)
	{
		float curDeathFieldRadius = SURVIVAL_GetDeathFieldCurrentRadius()

		foreach ( WildlifeCampData campData in campDatas )
		{
			foreach ( entity npc in campData.activeNPCs )
			{
				if ( IsValid( npc ) )
				{
					float distance = Distance2D( npc.GetOrigin(), circleCenter )
					// ignore if already passive
					if ( npc.GetNPCFlag( NPC_IGNORE_ALL ) )
					{
						// did we wander back into the deathfield?
						if ( !isDeathfieldMoving && distance < curDeathFieldRadius )
						{
							npc.DisableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
						}
						continue
					}

					// ignore if in combat
					if ( npc.GetNPCState() == "combat" )
					{
						continue
					}

					// ignore if only just spawned so we can enter combat
					if ( npc.ai.spawnTime + SPAWN_TIME_IGNORE_WINDOW > Time() )
					{
						continue
					}

					// turn passive if ring is over them
					if ( distance > curDeathFieldRadius )
					{
						npc.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
						npc.ClearAllEnemyMemory()
					}
				}
			}
		}

		if ( campDatas.len() == 0 ) // if the camps are monitoring are cleared, we don't need this thread anymore
		{
			return
		}

		wait PASSIVE_CHECK_TICK_RATE
	}
}

void function TropicsWildlife_OnDeathFieldStopShrink( table<int,DeathFieldData> deathFieldData )
{
	Signal( svGlobal.levelEnt, END_DEATHFIELD_MONITOR_SIGNAL_KEYWORD )
}

void function TropicsWildlife_OnSurvivalDeathFieldStageChanged(int stage, float nextCircleStartTime)
{
	if ( stage == 0 )
	{
		return
	}

	array<WildlifeCampData> campDatas = clone s_activeWildlifeCampDatas
	vector nextCircleCenter = SURVIVAL_GetDeathFieldCenter()
	float roundRadius = SURVIVAL_GetDeathFieldCurrentRadius()
	foreach ( WildlifeCampData campData in s_activeWildlifeCampDatas )
	{
		float distance = Distance2D( campData.assaultPoint.origin, nextCircleCenter )
		float maxDistance = campData.fullAssaultRadius + roundRadius
		if ( distance <= maxDistance )
		{
			campDatas.removebyvalue( campData )
		}
	}

	array<entity> players = GetConnectedPlayers()
	foreach ( entity player in players )
	{
		foreach ( WildlifeCampData campData in campDatas )
		{
			if ( Distance2D( campData.assaultPoint.origin, player.GetOrigin() ) < campData.fullAssaultRadius * 1.5 )
			{
				campDatas.removebyvalue( campData )
				break
			}
		}
	}

	foreach ( WildlifeCampData campData in campDatas )
	{
		foreach ( entity npc in campData.activeNPCs )
		{
			if ( IsValid( npc ) )
			{
				npc.Destroy()
			}
		}
		campData.activeNPCs.clear()

		if ( campData.type == eWildLifeCampType.SPIDER_NEST )
		{
			foreach ( entity eggEntity in campData.npcGeneratorEnts )
			{
				SpiderEggData eggData = GetSpiderEggData( eggEntity )
				SpiderEgg_ToggleHatchedState( eggData )
			}
		}
		else
		{
			foreach ( entity denEntity in campData.npcGeneratorEnts )
			{
				ProwlerDenData denData = GetProwlerDenData( denEntity )
				ProwlerDen_SetActive( denData, false )
			}
		}

		if ( IsValid( campData.minimapIcon ) )
		{
			foreach ( player in GetPlayerArray() )
			{
				campData.minimapIcon.Minimap_Hide( 0, player )
			}
			campData.minimapIcon.Destroy()
		}
		campData.lifeRemaining = 0
		campData.isActive = false

		s_activeWildlifeCampDatas.fastremovebyvalue( campData )
		if ( s_externalWildlifeCampDatas.contains( campData ) )
		{
			s_externalWildlifeCampDatas.fastremovebyvalue( campData )
		}
	}

	thread MarkWildifeInDeathfieldPassive_Thread( s_externalWildlifeCampDatas, nextCircleCenter, false )
}

void function TropicsWildlife_EntitiesDidLoad()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_EntitiesDidLoad()")
	#endif

	foreach ( entity campNode in s_setup_campNodes )
	{
		WildlifeCampData newCamp
		newCamp.activationOrigin = campNode.GetOrigin()
		newCamp.activationRadius = float( campNode.GetValueForKey( "script_radius" ) )
		newCamp.scriptName = campNode.GetScriptName()
		newCamp.isDisabled = GetCurrentPlaylistVarBool( newCamp.scriptName + "_disabled", false )
		newCamp.type = eWildLifeCampType.UNKNOWN
		s_wildlifeCampDatas.append( newCamp )

		foreach ( entity linkEnt in campNode.GetLinkEntArray() )
		{
			string editorClass = GetEditorClass( linkEnt )
			switch ( editorClass )
			{
				case EDITOR_CLASS_CAMP_ASSAULT_RADIUS_KEYWORD:
					AssaultPointData newData
					newData.origin = linkEnt.GetOrigin()
					newData.radius = float( linkEnt.GetValueForKey( "script_radius" ) )
					if ( newData.radius <= 0 )
					{
						newData.radius = WILDLIFE_ASSAULTPOINT_DEFAULT_RADIUS
					}
					newCamp.assaultPoint = newData
					newCamp.fullAssaultRadius = newData.radius
					newCamp.hasAssaultPoint = true
					s_assaultPointDatas.append( newData )
					break
				case EDITOR_CLASS_CAMP_TREASURE_CHEST_KEYWORD:
					TreasureChestData newData
					newData.origin = linkEnt.GetOrigin()
					newData.angles = linkEnt.GetAngles()
					newCamp.linkedTreasureChests.append( newData )
					s_treasureChestDatas.append( newData )
					break
				case EDITOR_CLASS_PROWLER_SPAWNPOINT_KEYWORD:
					NPCSpawnerData newData
					newData.npcType = eNPC.PROWLER
					newData.origin = linkEnt.GetOrigin()
					newData.angles = linkEnt.GetAngles()
					newCamp.linkedNPCSpawners.append( newData )
					s_prowlerSpawnPoints.append( newData )
					break
				case EDITOR_CLASS_SPIDER_SPAWNPOINT_KEYWORD:
					NPCSpawnerData newData
					newData.npcType = eNPC.SPIDER_JUNGLE
					newData.origin = linkEnt.GetOrigin()
					newData.angles = linkEnt.GetAngles()
					newCamp.linkedNPCSpawners.append( newData )
					s_spiderSpawnPoints.append( newData )
					break










				case EDITOR_CLASS_SPIDER_EGG_KEYWORD:
					NPCGeneratorData newData
					newData.type = eGeneratorType.SPIDER_EGG
					SpiderEggData eggData = GetSpiderEggData( linkEnt )
					newData.origin = linkEnt.GetOrigin()
					newData.angles = linkEnt.GetAngles()
					newData.maxLife = eggData.spidersInside
					newCamp.totalLife += newData.maxLife
					newCamp.npcGeneratorEnts.append( eggData.eggEntity )
					newCamp.linkedNPCGenerators.append( newData )
					s_spiderEggGeneratorDatas.append( newData )
					s_spiderEggToWildlifeCamp[ eggData ] <- newCamp
					break
				case EDITOR_CLASS_PROWLER_DEN_KEYWORD:
					NPCGeneratorData newData
					newData.type = eGeneratorType.PROWLER_DEN
					ProwlerDenData denData = GetProwlerDenData( linkEnt )
					newData.origin = linkEnt.GetOrigin()
					newData.angles = linkEnt.GetAngles()
					newData.maxLife = denData.lifeMax
					newCamp.totalLife += newData.maxLife
					newCamp.npcGeneratorEnts.append( denData.denEntity )
					newCamp.linkedNPCGenerators.append( newData )
					s_prowlerDenGeneratorDatas.append( newData )
					s_prowlerDenToWildlifeCamp[ denData ] <- newCamp
					break
				default:
					Warning( FUNC_NAME() + " " + editorClass + " is a child of AI Camp at " + newCamp.activationOrigin + ". This class of entity is not supposed by Wildlife AI." )
			}
		}
	}

	CreateCampTreasureChests()

	FinalizeCampSetup()

	CleanUpSetupEnts()

	TropicsWildlifeRuntimeThinkStart()
}

void function CleanUpSetupEnts()
{
	foreach ( entity campNode in s_setup_campNodes )
	{
		campNode.Destroy()
	}
	s_setup_campNodes.clear()

	foreach ( entity assaultPoint in s_setup_assaultPoints )
	{
		assaultPoint.Destroy()
	}
	s_setup_assaultPoints.clear()

	foreach ( entity npcSpawner in s_setup_npcSpawners )
	{
		npcSpawner.Destroy()
	}
	s_setup_npcSpawners.clear()

	foreach ( entity treasureChest in s_setup_treasureChests )
	{
		treasureChest.Destroy()
	}
	s_setup_treasureChests.clear()
}

void function FinalizeCampSetup()
{
	foreach ( WildlifeCampData campData in s_wildlifeCampDatas )
	{
		if ( campData.linkedNPCSpawners.len() > 0 || campData.linkedNPCGenerators.len() > 0 )
		{
			Assert( campData.hasAssaultPoint, "info_AI_camp_node at " + campData.activationOrigin + " requires an info_AI_camp_assaultradius and none were found. Potential link missing." )
		}

		// todo (tgoodbrand): this isn't great and should be improved in the future. Maybe a dropdown on the camp_node, right now we need a spider_egg or a prowler_den to set campData type
		if ( campData.linkedNPCGenerators.len() > 0 )
		{
			campData.type = ( campData.linkedNPCGenerators[0].type == eGeneratorType.SPIDER_EGG ) ? eWildLifeCampType.SPIDER_NEST : eWildLifeCampType.PROWLER_DENS
		}

		if ( campData.type == eWildLifeCampType.SPIDER_NEST )
		{
			campData.maxAlive = GetCurrentPlaylistVarInt( "wildlife_ai_spider_camp_max_alive", MAX_SPIDERS_ALLOWED_ALIVE_IN_SPIDER_NEST )
			campData.initialSpawnTotal = GetCurrentPlaylistVarInt( "wildlife_ai_spider_camp_initial_spawn_limit", campData.linkedNPCSpawners.len() )

		}
		else if ( campData.type == eWildLifeCampType.PROWLER_DENS )
		{
			const int GOLIATH_PIT_SPAWN_MODIFIER = 2
			const int REGULAR_SPAWN_MODIFIER = 1
			if ( campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
			{
				campData.limitProwlerAssaultRadius = false
				campData.maxAlive = GetCurrentPlaylistVarInt( "wildlife_ai_goliathpit_camp_max_alive", campData.linkedNPCSpawners.len() )
				campData.initialSpawnTotal = GetCurrentPlaylistVarInt( "wildlife_ai_goliathpit_camp_initial_spawn_limit", campData.linkedNPCSpawners.len() - GOLIATH_PIT_SPAWN_MODIFIER )
			} else {
				campData.maxAlive = GetCurrentPlaylistVarInt( "wildlife_ai_prowler_camp_max_alive", campData.linkedNPCSpawners.len() + REGULAR_SPAWN_MODIFIER )
				campData.initialSpawnTotal = GetCurrentPlaylistVarInt( "wildlife_ai_prowler_camp_initial_spawn_limit", 2 )
				campData.fullAssaultRadius = campData.assaultPoint.radius * WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE
			}
		}
		campData.totalLife += campData.initialSpawnTotal
		campData.lifeRemaining = campData.totalLife













		#if DEVELOPER
			if ( TROPICS_WILDLIFE_AI_DEBUG )
			{
				printf("-= Camp Data Finalized =-")
				DEV_TropicsWildlife_PrintCampDetails( campData )
			}
			DEV_Tropics_RegisterNPCCamp (
				campData.assaultPoint.origin,
				campData.type == eWildLifeCampType.PROWLER_DENS ? eNPC.PROWLER : eNPC.SPIDER_JUNGLE,
				campData.fullAssaultRadius,
				campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD ? float(11000) : float(6000)
			)
		#endif

		printf( "Wildlife camp full assault radius = " + campData.fullAssaultRadius )
	}

	s_generatorsCreated = true

	#if DEVELOPER
	if ( TROPICS_WILDLIFE_AI_DEBUG )
		printf("FinalizeCampSetup: " + s_wildlifeCampDatas.len() + " Total Camp Datas Finalized")
	#endif
}

void function CreateCampNPCGenerators()
{
	if ( s_generatorsCreated )
	{
		return
	}

	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		WildlifeCampData campData = s_wildlifeCampDatas[i]
		array<NPCGeneratorData> npcGenerators = campData.linkedNPCGenerators
		for (int s = 0; s < npcGenerators.len(); s++)
		{
			NPCGeneratorData generator = npcGenerators[s]
			switch ( generator.type )
			{
				case eGeneratorType.SPIDER_EGG:
					SpiderEggData egg = SpiderEgg_Create( generator.origin, generator.angles, eNpcTeam.INFECTED, generator.maxLife )
					campData.npcGeneratorEnts.append( egg.eggEntity )
					s_spiderEggToWildlifeCamp[ egg ] <- campData
					break
				case eGeneratorType.PROWLER_DEN:
					ProwlerDenData den = ProwlerDen_Create( generator.origin, generator.angles, eNpcTeam.WILDLIFE, generator.maxLife )
					campData.npcGeneratorEnts.append( den.denEntity )
					s_prowlerDenToWildlifeCamp[ den ] <- campData
					break
			}
			#if DEVELOPER
				if ( TROPICS_WILDLIFE_AI_DEBUG )
					printf( "TropicsWildlife_Runtime: camp #" + (i+1) + " npc generator #" + (s+1))
			#endif
		}
	}

	s_generatorsCreated = true
}

void function CreateCampTreasureChests()
{
	if ( !s_treasureChestEnabled || s_treasureChestsCreated )
	{
		return
	}

	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		WildlifeCampData campData = s_wildlifeCampDatas[i]
		array<TreasureChestData> treasureChests = campData.linkedTreasureChests
		if ( treasureChests.len() == 0 )
		{
			continue
		}

		int ridx = RandomInt( treasureChests.len() )
		campData.treasureChest = CreateTreasureChest( treasureChests[ridx].origin, treasureChests[ridx].angles )
		#if DEVELOPER
			if ( TROPICS_WILDLIFE_AI_DEBUG )
				printf( "TropicsWildlife_CreateCampTreasureChests: Deathbox created at index: " + ridx + " Origin: " + treasureChests[ridx].origin + " Angles: " + treasureChests[ridx].angles )
		#endif
	}

	s_treasureChestsCreated = true
}

entity function SpiderEggOnSpawnCallback( SpiderEggData eggData )
{
	if ( !s_wildlifeRuntimeActive )
	{
		return null
	}

	if ( CheckIfActiveAIWithinLimit() == false )
	{
		return null
	}

	WildlifeCampData campData
	if ( eggData in s_spiderEggToWildlifeCamp )
	{
		campData = s_spiderEggToWildlifeCamp[ eggData ]
	}

	int idx = eggData.spidersSpawned
	entity spider = SpawnWildlifeAI( campData, eNPC.SPIDER_JUNGLE, 1.0, eggData.spiderAnimSetups[idx].spawnPoint.origin, eggData.spiderAnimSetups[idx].spawnPoint.angles )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_SpiderEggOnSpawnCallback: AI in current Camp = " + campData.activeNPCs.len() + " MaxAlive = " + campData.maxAlive + " LifeRemaining = " + campData.lifeRemaining )
	#endif

	if ( s_isMatchWinnerDetermined )
	{
		spider.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
	}

	return spider
}

void function ReduceSpiderCountInNest( WildlifeCampData campData, int spidersSpawned, int spidersWanted )
{
	campData.totalLife -= spidersWanted - spidersSpawned
	campData.lifeRemaining -= spidersWanted - spidersSpawned
}

entity function ProwlerDenOnSpawnCallback( ProwlerDenData denData, vector spawnPoint, vector spawnAngles )
{
	if ( !s_wildlifeRuntimeActive )
	{
		return null
	}

	if ( CheckIfActiveAIWithinLimit() == false )
	{
		return null
	}

	WildlifeCampData campData
	if ( denData in s_prowlerDenToWildlifeCamp )
	{
		campData = s_prowlerDenToWildlifeCamp[ denData ]
	}

	entity prowler = SpawnWildlifeAI( campData, eNPC.PROWLER, WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE, spawnPoint, spawnAngles )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_ProwlerDenOnSpawnCallback: AI in current Camp = " + campData.activeNPCs.len() + " MaxAlive = " + campData.maxAlive + " LifeRemaining = " + campData.lifeRemaining )
	#endif

	ForceAwarenessForProwler( campData, prowler )

	if ( campData.scriptName != SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
	{
		thread ResetProwlerAssaultRadiiAfterDuration_Thread( prowler, campData )
	}

	if ( s_isMatchWinnerDetermined )
	{
		prowler.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
	}

	return prowler
}

int function ProwlerDenOnAdditionalSpawnCheckCallback( ProwlerDenData denData, bool isForced )
{
	if ( denData in s_prowlerDenToWildlifeCamp )
	{
		WildlifeCampData campData = s_prowlerDenToWildlifeCamp[ denData ]

		if ( campData.scriptName != SCRIPT_NAME_GOLIATH_PIT_KEYWORD && GetCurrentPlaylistVarBool( "wildlife_ai_disable_prowler_dens_with_multiple_teams", true ) )
		{
			if ( MultipleTeamsWithinWildlifeCamp( campData ) )
			{
				thread LockProwlerDenSpawnsUntilOneTeam_Thread( campData )
				return 0
			}
			// if the Prowler Den is covered by the ring and its not "red" i.e.: has an extended assault radius
			if ( !isForced && campData.limitProwlerAssaultRadius )
			{
				vector nextCircleCenter = SURVIVAL_GetDeathFieldCenter()
				float curDeathFieldRadius = SURVIVAL_GetDeathFieldCurrentRadius()
				float distance = Distance2D( denData.denEntity.GetOrigin(), nextCircleCenter )
				if ( distance > curDeathFieldRadius )
				{
					return 0
				}
			}
		}

		if ( campData.lifeRemaining == 0 || GetProwlerCampActiveNPCCount( campData ) >= campData.maxAlive || campData.activeNPCs.len() >= campData.lifeRemaining  )
		{
			return 0
		}
		else if ( GetProwlerCampActiveNPCCount( campData ) < floor( campData.maxAlive * 0.5 ) && denData.life > 1 )
		{
			return 2
		}
	}
	return minint( denData.life, 1 )
}

void function LockProwlerDenSpawnsUntilOneTeam_Thread( WildlifeCampData campData )
{
	EndSignal( svGlobal.levelEnt, CANCEL_SPAWNLOCK_MONITOR_SIGNAL_KEYWORD )

	const float CHECK_TEAM_COUNT_TICKRATE = 1.0
	const float DEN_SPAWN_UNLOCK_DELAY = 5.0
	const float EMPTY_CAMP_CHECK_DELAY = 3.0

	foreach ( entity den in campData.npcGeneratorEnts )
	{
		ProwlerDen_SetLockSpawns( GetProwlerDenData( den ), true )
	}

	while ( MultipleTeamsWithinWildlifeCamp( campData ) == true )
	{
		wait CHECK_TEAM_COUNT_TICKRATE
	}

	wait DEN_SPAWN_UNLOCK_DELAY

	foreach ( entity den in campData.npcGeneratorEnts )
	{
		ProwlerDen_SetLockSpawns( GetProwlerDenData( den ), false )
	}

	wait EMPTY_CAMP_CHECK_DELAY

	if ( campData.activeNPCs.len() == 0 && campData.lifeRemaining > 0 )
	{
		array<entity> generatorEnts = clone campData.npcGeneratorEnts
		generatorEnts.randomize()
		for ( int i = 0; i < generatorEnts.len(); i++ )
		{
			ProwlerDenData denData = GetProwlerDenData( generatorEnts[i] )
			if ( denData.life > 0 )
			{
				ProwlerDen_ForceSpawnProwlers( denData )
				break
			}
		}
	}
}

bool function MultipleTeamsWithinWildlifeCamp( WildlifeCampData campData )
{
	array<int> teamsInCamp
	vector assaultOrigin = campData.assaultPoint.origin
	float assaultRadius = campData.fullAssaultRadius
	foreach ( player in GetPlayerArray_Alive() )
	{
		if ( !IsValid(player) )
		{
			continue
		}

		int team = player.GetTeam()
		if ( teamsInCamp.contains( team ) )
		{
			continue
		}
		if ( Distance2D( player.GetOrigin(), assaultOrigin ) < assaultRadius * 1.25 )
		{
			teamsInCamp.push( team )
		}
		if ( teamsInCamp.len() >= 2 )
		{
			return true
		}
	}

	return false
}

int function SpiderEggOnAdditionalSpawnCheckCallback( SpiderEggData eggData )
{
	WildlifeCampData campData
	if ( eggData in s_spiderEggToWildlifeCamp )
	{
		campData = s_spiderEggToWildlifeCamp[ eggData ]

		// limit spawns of spiders as we approach MAX_SPIDERS_ALLOWED_ALIVE_IN_SPIDER_NEST
		if ( campData.activeNPCs.len() >= campData.maxAlive * 0.75 )
		{
			const int HIGH_LIFE_LIMITER = 1
			ReduceSpiderCountInNest( campData, HIGH_LIFE_LIMITER, eggData.spidersInside )
			return HIGH_LIFE_LIMITER
		}
		else if ( campData.activeNPCs.len() >= campData.maxAlive * 0.5 )
		{
			const int MEDIUM_LIFE_LIMITER = 2
			ReduceSpiderCountInNest( campData, MEDIUM_LIFE_LIMITER, eggData.spidersInside )
			return MEDIUM_LIFE_LIMITER
		}
	}
	return eggData.spidersInside
}

int function GetProwlerCampActiveNPCCount( WildlifeCampData campData )
{
	int currentLife = campData.activeNPCs.len()
	foreach ( entity den in campData.npcGeneratorEnts )
	{
		currentLife += GetProwlerDenData( den ).queuedSpawnCount
	}
	return currentLife
}

void function ExtendProwlerCampAssaultRadii( WildlifeCampData campData )
{
	if ( campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
	{
		return
	}

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_ExtendProwlerCampAssaultRadii: Remove Assault Radius Limit")
	#endif

	Signal( campData, PROWLER_RESET_ASSAULT_SIGNAL_KEYWORD )
	for ( int i = 0; i < campData.activeNPCs.len(); ++i )
	{
		if ( IsValid( campData.activeNPCs[i] ) )
		{
			Signal( campData.activeNPCs[i], PROWLER_RESET_ASSAULT_SIGNAL_KEYWORD )
		}
	}
	if ( campData.limitProwlerAssaultRadius )
	{
		float assaultRadius = campData.assaultPoint.radius * WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE
		for ( int i = 0; i < campData.activeNPCs.len(); ++i )
		{
			UpdateAssaultRadiusOfProwler( campData.activeNPCs[i], assaultRadius )
		}
		campData.limitProwlerAssaultRadius = false
	}

	thread ResetAssaultRadiiOfActiveProwlersInCampAfterDuration_Thread( campData )
}

void function ResetProwlerAssaultRadiiAfterDuration_Thread( entity prowler, WildlifeCampData campData )
{
	EndSignal( prowler, PROWLER_RESET_ASSAULT_SIGNAL_KEYWORD )

	OnThreadEnd(
		function() : ()
		{
			#if DEVELOPER
				if ( TROPICS_WILDLIFE_AI_DEBUG )
					printf("ResetProwlerAssaultRadiiAfterDuration_Thread: OnThreadEnd")
			#endif
		}
	)
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("ResetProwlerAssaultRadiiAfterDuration_Thread: Start Wait")
	#endif

	wait 20.0

	UpdateAssaultRadiusOfProwler( prowler, campData.assaultPoint.radius )
}

void function ResetAssaultRadiiOfActiveProwlersInCampAfterDuration_Thread( WildlifeCampData campData )
{
	EndSignal( campData, PROWLER_RESET_ASSAULT_SIGNAL_KEYWORD )

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_ReduceProwlerCampAssaultRadiiAfterDuration_Thread: Start Wait")
	#endif

	wait 20.0

	for ( int i = 0; i < campData.activeNPCs.len(); ++i )
	{
		UpdateAssaultRadiusOfProwler( campData.activeNPCs[i], campData.assaultPoint.radius )
	}

	campData.limitProwlerAssaultRadius = true

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_ReduceProwlerCampAssaultRadiiAfterDuration_Thread: Assault Radius Reset")
	#endif
}

void function UpdateAssaultRadiusOfProwler( entity prowler, float assaultRadius )
{
	if ( IsValid( prowler ) && prowler.AssaultGetGoalRadius() != assaultRadius )
	{
		prowler.AssaultSetGoalRadius( assaultRadius )
		prowler.AssaultSetArrivalTolerance( assaultRadius * 0.5 )
	}
}

// todo (tgoodbrand): each camp should be managed in its own script -> NEW sh_skit_tropics_wildlife_camp
// todo (tgoodbrand): this file should manage all camp runtime logic sh_skit_tropics_wildlife_ai.nut > sh_tropics_wildlife
void function TropicsWildlifeRuntimeThinkStart()
{
	if ( s_wildlifeRuntimeThreadRunning )
	{
		return
	}

	s_wildlifeRuntimeActive = true
	s_wildlifeRuntimeThreadRunning = true
	thread TropicsWildlifeRuntime_Thread()
}

void function TropicsWildlifeRuntimeThinkStop()
{
	if ( !s_wildlifeRuntimeThreadRunning )
	{
		s_wildlifeRuntimeActive = false
		return
	}

	s_wildlifeRuntimeActive = false
	while ( s_wildlifeRuntimeThreadRunning )
	{
		WaitFrame()
	}
}

void function TropicsWildlifeRuntime_Thread()
{
	AssertIsNewThread()

	OnThreadEnd(
		function() : ()
		{
			TropicsWildlifeRuntime_Deactivate()
			s_wildlifeRuntimeThreadRunning = false
			s_wildlifeRuntimeActive = false
		}
	)

	if ( s_wildlifeRuntimeActive )
	{
		TropicsWildlifeRuntime_Activate()

		while ( s_wildlifeRuntimeActive )
		{
			WaitFrame()
		}
	}
}

void function TropicsWildlifeRuntime_Activate()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_Runtime: Activated. Spawning Wildlife...")
	#endif

	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		#if DEVELOPER
			if ( TROPICS_WILDLIFE_AI_DEBUG )
				printf( "TropicsWildlife_Runtime: camp #" + (i+1) + " @ location: " + s_wildlifeCampDatas[i].activationOrigin + " isDisabled = " + s_wildlifeCampDatas[i].isDisabled)
		#endif

		WildlifeCampData campData = s_wildlifeCampDatas[i]
		if ( campData.isDisabled == false )
		{
			array<NPCSpawnerData> npcSpawners = campData.linkedNPCSpawners
			npcSpawners.randomize()
			for (int s = 0; s < campData.initialSpawnTotal; s++)
			{
				if ( s >= campData.linkedNPCSpawners.len() )
				{
					break
				}

				if ( campData.activeNPCs.len() >= campData.maxAlive )
				{
					break
				}

				if ( CheckIfActiveAIWithinLimit() == false )
				{
					break
				}

				SpawnWildlifeAI( campData, npcSpawners[s].npcType, 1.0, npcSpawners[s].origin, npcSpawners[s].angles )

				#if DEVELOPER
					if ( TROPICS_WILDLIFE_AI_DEBUG )
						printf( "TropicsWildlife_Runtime: camp #" + (i+1) + " spawner #" + (s+1) + " AI alive in camp = " + campData.activeNPCs.len() + " Total AI across Map = " + s_totalAliveAI )
				#endif
			}

			entity campIcon = CreatePropScript( $"mdl/dev/empty_model.rmdl", campData.assaultPoint.origin, <0,0,0>, -1 )
			if ( campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
			{
				campIcon.SetScriptName( SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
			}
			campIcon.Minimap_SetAlignUpright( true )
			campIcon.Minimap_SetCustomState( campData.type == eWildLifeCampType.PROWLER_DENS ? eMinimapObject_prop_script.PROWLER_CAMP : eMinimapObject_prop_script.SPIDER_CAMP )
			campIcon.Minimap_SetObjectScale( 1 )
			foreach ( player in GetPlayerArray() )
			{
				campIcon.Minimap_AlwaysShow( 0, player )
			}
			campIcon.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
			campData.minimapIcon = campIcon

			s_activeWildlifeCampDatas.push( campData )
			campData.isActive = true
		} else {
			switch ( campData.type )
			{
				case eWildLifeCampType.SPIDER_NEST:
					for ( int g = 0; g < campData.npcGeneratorEnts.len(); g++ )
					{
						SpiderEggData eggData = GetSpiderEggData( campData.npcGeneratorEnts[g] )
						SpiderEgg_ToggleHatchedState( eggData )
					}
					break
				case eWildLifeCampType.PROWLER_DENS:
					for ( int g = 0; g < campData.npcGeneratorEnts.len(); g++ )
					{
						ProwlerDenData denData = GetProwlerDenData( campData.npcGeneratorEnts[g] )
						ProwlerDen_SetActive( denData, false )
					}
					break
			}
		}
	}
}

void function TropicsWildlifeRuntime_Deactivate()
{
	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		WildlifeCampData campData = s_wildlifeCampDatas[i]
		campData.isActive = false
		if ( IsValid( campData.minimapIcon ) )
		{
			foreach ( player in GetPlayerArray() )
			{
				campData.minimapIcon.Minimap_Hide( 0, player )
			}
			campData.minimapIcon.Destroy()
		}
		campData.minimapIcon = null
	}

	s_activeWildlifeCampDatas.clear()

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife Runtime: Shutdown Complete")
	#endif
}

string function GetWildlifeNPCClassname( int npcType )
{
	switch ( npcType )
	{
		case eNPC.SPIDER_JUNGLE:
			return "npc_spider"
		case eNPC.PROWLER:
			return "npc_prowler"
	}

	Assert( false, FUNC_NAME() + " - Unsupported wildlife npcType " + npcType )
	return "npc_spider"
}

int function GetWildlifeNPCTeam( int npcType )
{
	switch ( npcType )
	{
		case eNPC.SPIDER_JUNGLE:
			return eNpcTeam.INFECTED
		case eNPC.PROWLER:
			return eNpcTeam.WILDLIFE
	}

	Assert( false, FUNC_NAME() + " - Unsupported wildlife npcType " + npcType )
	return eNpcTeam.INFECTED
}

entity function SpawnWildlifeAI( WildlifeCampData campData, int npcType, float assaultScale, vector origin, vector angles )
{
	string npcClassName = GetWildlifeNPCClassname( npcType )
	int npcTeam = GetWildlifeNPCTeam( npcType )
	entity npc = CreateNPCFromAISettings( npcClassName, npcTeam, origin, angles )
	DispatchSpawn( npc )
	npc.ai.spawnTime = Time()

	if ( campData.hasAssaultPoint )
	{
		float assaultRadius = campData.assaultPoint.radius
		if ( campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
		{
			//npc.SetNetworkDistanceCullRadius( 11000.0 )
		}
		else
		{
			assaultRadius *= assaultScale
		}

		npc.AssaultSetGoalRadius( assaultRadius )
		thread LeashNPCToAssaultPoint_Thread( npc, npcType, campData, "OnDamaged" )

		AddEntityCallback_OnKilled( npc, void function ( entity npc, var damageInfo ) : ( campData )
		{
			HandleNPCDeath( npc, damageInfo, campData )
		} )
		AddEntityCallback_OnDamaged( npc, void function ( entity npc, var damageInfo )
		{
			npc.DisableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
		} )
		campData.activeNPCs.push( npc )
	}
	s_totalAliveAI++

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_SpawnWildlifeAI: Total AI = " + s_totalAliveAI + " AI in current Camp = " + campData.activeNPCs.len() + " LifeRemaining = " + campData.lifeRemaining + " TotalLife = " + campData.totalLife )
	#endif

	return npc
}

bool function CheckIfActiveAIWithinLimit()
{
	if ( s_totalAliveAI > s_maxAllowedAIAlive )
	{
		printf( "TropicsWildlife_CheckIfActiveAIWithinLimit: Tropics Wildlife - AI Limit Reached! Script AI limit = " + s_maxAllowedAIAlive )
		//PIN_GameError( "Tropics Wildlife - AI Limit Reached! Script AI limit = " + s_maxAllowedAIAlive, "Survival AI" )
		return false
	}

	return true
}

entity function CreateTreasureChest( vector origin, vector angles )
{
	entity deathBox = CreateDeathBox( origin, angles )

	Highlight_SetNeutralHighlight( deathBox, "survival_item_common" )

	deathBox.Solid()
	deathBox.SetUsable()
	deathBox.SetUsableByGroup( "pilot" )
	deathBox.SetUsePrompts( "#DEATHBOX_HINT", "#DEATHBOX_HINT" )
	deathBox.AddUsableValue( USABLE_CUSTOM_HINTS )
	deathBox.e.blockActive = false

	array<string> lootRefs = CreateLootForFlyerDeathBox( deathBox )

	foreach( lootRef in lootRefs )
	{
		if ( lootRef != "" )
		{
			LootData data = SURVIVAL_Loot_GetLootDataByRef( lootRef )
			entity loot   = SpawnGenericLoot( lootRef, deathBox.GetOrigin(), <-1, -1, -1>, data.countPerDrop )
			AddToDeathBox( loot, deathBox )
		}
	}

	UpdateDeathBoxHighlight( deathBox )


		//SendGenericProfileForDeathBoxRui( deathBox )


	return deathBox
}

bool function IsInRangeToSpawnLoot( vector npcPos, vector playerPos, AILootSpawnParams params )
{
	if( Distance2D( params.center, playerPos ) > (params.lootRadius * WILDLIFE_SMARTLOOT_CAMP_RADIUS_SCALAR) &&
			Distance2D( npcPos, playerPos ) > WILDLIFE_SMARTLOOT_TEAM_RADIUS_LIMITER )
		return false

	return true
}

AILootSpawnParams function GetLootParams( entity npc,  WildlifeCampData campData )
{
	AILootSpawnParams params

	bool isProwler = (npc.ai.npcType == eNPC.PROWLER)

	params.playlistVarPrefix = "wildlife_ai"
	params.ammoDropEnabled = GetCurrentPlaylistVarBool( "wildlife_ai_ammo_lootdrop_enabled", true )
	params.ordnanceChance = GetCurrentPlaylistVarFloat( "wildlife_ai_ordnance_lootdrop_percent", 0.20 )
	params.helmetChance = GetCurrentPlaylistVarFloat( "wildlife_ai_helmet_lootdrop_percent", 0.10 )
	params.consumableChance = GetCurrentPlaylistVarFloat( "wildlife_ai_consumable_lootdrop_percent", 1.0 )
	params.epicConsumableChance = isProwler ? GetCurrentPlaylistVarFloat( "wildlife_ai_prowler_epic_consumable_lootdrop_percent", 0.1 ) : GetCurrentPlaylistVarFloat( "wildlife_ai_spider_epic_consumable_lootdrop_percent", 0.05 )
	params.ammoRatio = isProwler ? GetCurrentPlaylistVarFloat( "wildlife_ai_prowler_lootdrop_ammoratio", 0.25 ) :  GetCurrentPlaylistVarFloat( "wildlife_ai_spider_lootdrop_ammoratio", 0.75 )
	params.attachmentDropChance = isProwler ? GetCurrentPlaylistVarFloat( "wildlife_ai_prowler_lootdrop_percent", 0.75 ) : GetCurrentPlaylistVarFloat( "wildlife_ai_spider_lootdrop_percent", 0.50 )
	params.ammoRadius = WILDLIFE_SMARTLOOT_TEAM_RADIUS_LIMITER
	params.center = campData.assaultPoint.origin
	params.lootRadius = campData.fullAssaultRadius
	params.InRangeForLootFunc = IsInRangeToSpawnLoot
	params.lootTrackers = campData.lootTrackers

	return params
}

void function HandleNPCDeath( entity npc, var damageInfo, WildlifeCampData campData )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	s_totalAliveAI--
	campData.activeNPCs.fastremovebyvalue( npc )

	int lethalDamageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( lethalDamageSource == eDamageSourceId.fall )
	{
		Warning( FUNC_NAME() + " - NPC fell to its death in AI Camp at " + campData.activationOrigin + ". Good indication of a spawner being below the navmesh!" )
	}

	campData.lifeRemaining--

	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_HandleNPCDeath:           AI in current Camp = " + campData.activeNPCs.len() + " LifeRemaining = " + campData.lifeRemaining )
	#endif

	array<string> lootRewards = AI_Loot_SpawnReward( npc, GetLootParams( npc, campData ), damageInfo )

	// enable sensing for AI when a buddy in their camp dies - see MarkWildlifeInDeathfieldPassive_Thread
	foreach ( entity activeNPC in campData.activeNPCs )
	{
		if ( IsValid( activeNPC ) && activeNPC.GetNPCFlag( NPC_IGNORE_ALL ) )
		{
			activeNPC.DisableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
		//	UpdateEnemyMemoryWithinRadiusAroundPoint( activeNPC, campData.assaultPoint.radius, campData.assaultPoint.origin )
		}
	}

	if ( campData.type == eWildLifeCampType.PROWLER_DENS )
	{
		if ( campData.activeNPCs.len() == 1 )
		{ // let's give awareness to a remaining prowler to keep the intensity up
			entity lastProwler = campData.activeNPCs[0]
			if ( IsValid( lastProwler ) )
			{
				ForceAwarenessForProwler( campData, lastProwler )
			}
		}
		else if ( campData.lifeRemaining > 0 && campData.activeNPCs.len() == 0 )
		{ // let's spawn some prowler when the camp is empty
			int maxSpawn = ( ( campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD ) ? 3 : 2 )
			maxSpawn = minint( maxSpawn, campData.npcGeneratorEnts.len() )

			if (  IsValid( attacker ) && attacker.IsPlayer() )
			{
				if ( Distance2D( attacker.GetOrigin(), campData.assaultPoint.origin ) > campData.fullAssaultRadius )
				{
					maxSpawn = 1
				}
			}

			array<ProwlerDenData> densWithPlayersNear
			array<ProwlerDenData> densWithoutPlayersNear
			for ( int i = 0; i < campData.npcGeneratorEnts.len(); i++ )
			{
				ProwlerDenData denData = GetProwlerDenData( campData.npcGeneratorEnts[i] )
				if ( denData.life > 0 )
				{
					if ( denData.playersInTrigger.len() > 0 )
					{
						densWithPlayersNear.append( denData )
					} else {
						densWithoutPlayersNear.append( denData )
						if ( densWithoutPlayersNear.len() >= maxSpawn )
						{
							break
						}
					}
				}
			}

			while ( densWithoutPlayersNear.len() < maxSpawn && densWithPlayersNear.len() > 0 )
			{
				ProwlerDenData denData = densWithPlayersNear.getrandom()
				densWithoutPlayersNear.append( denData )
				densWithPlayersNear.fastremovebyvalue( denData )
			}

			for ( int i = 0; i < densWithoutPlayersNear.len(); i++ )
			{
				ProwlerDen_ForceSpawnProwlers( densWithoutPlayersNear[i] )
			}
		}

		printf("TropicsWildlife_HandleNPCDeath -> ExtendProwlerCampAssaultRadii")
		ExtendProwlerCampAssaultRadii( campData )

		if (  IsValid( attacker ) && attacker.IsPlayer() )
		{
			string lethalDamageSourceName = GetEnumString ("eDamageSourceId", lethalDamageSource)
			switch ( npc.ai.npcType )
			{
				case eNPC.SPIDER_JUNGLE:
					//PIN_PlayerItemDestruction( attacker, ITEM_DESTRUCTION_TYPES.SPIDER_JUNGLE, { death_pos = npc.GetOrigin(), camp_ID = campData.scriptName, killed_by = lethalDamageSourceName, rewards = lootRewards } )
					break
				case eNPC.PROWLER:
					//PIN_PlayerItemDestruction( attacker, ITEM_DESTRUCTION_TYPES.PROWLER, { death_pos = npc.GetOrigin(), camp_ID = campData.scriptName, killed_by = lethalDamageSourceName, rewards = lootRewards } )
					break
			}
		}
	}

	// When the camp is depleted
	if ( campData.lifeRemaining <= 0 && campData.activeNPCs.len() == 0 )
	{
		int rewardTotal
		float squadRangeModifier = 1.0
		if ( campData.type == eWildLifeCampType.PROWLER_DENS )
		{
			rewardTotal = GetCurrentPlaylistVarInt( "wildlife_ai_prowler_den_crafting_reward", 50 ) * campData.npcGeneratorEnts.len()
		} else {
			rewardTotal = GetCurrentPlaylistVarInt( "wildlife_ai_spider_camp_crafting_reward", 90 )
			squadRangeModifier = 2.0
		}

		// remove the map icons
		if ( IsValid( campData.minimapIcon ) )
		{
			foreach ( player in GetPlayerArray() )
			{
				campData.minimapIcon.Minimap_Hide( 0, player )
			}
			campData.minimapIcon.Destroy()
		}
		campData.isActive = false
		s_activeWildlifeCampDatas.fastremovebyvalue( campData )
		if ( s_externalWildlifeCampDatas.contains( campData ) )
		{
			s_externalWildlifeCampDatas.fastremovebyvalue( campData )
		}

		// reward materials to squad
		array<entity> players
		if ( campData.type == eWildLifeCampType.PROWLER_DENS && campData.scriptName == SCRIPT_NAME_GOLIATH_PIT_KEYWORD )
		{
			players = GetPlayerArray_Alive()
		} else {
			players = GetPlayerArrayOfTeam_AliveConnected( DamageInfo_GetAttacker( damageInfo ).GetTeam() )
		}

		array<entity> validPlayersToReward = []
		foreach ( entity player in players )
		{
			if ( IsValidPlayer( player ) && Distance2D( player.GetOrigin(), campData.assaultPoint.origin ) < ( campData.fullAssaultRadius * squadRangeModifier ) )
			{
				validPlayersToReward.append( player )
			}
		}


		//UpgradeCore_GrantXp_WildlifeClear( validPlayersToReward )


		{
			thread DisplayCampCompletionMessageAfterDelay_Thread( validPlayersToReward, campData.type )
		}

		// change scriptname so 'empty' pings work for dens
		if ( campData.type == eWildLifeCampType.PROWLER_DENS )
		{
			foreach( denEnt in campData.npcGeneratorEnts )
			{
				denEnt.SetScriptName( denEnt.GetScriptName() + "_empty" )
			}
		}

		if (  IsValid( attacker ) && attacker.IsPlayer() )
		{
			switch ( campData.type )
			{
				case eWildLifeCampType.SPIDER_NEST:
					//PIN_PlayerItemDestruction( attacker, ITEM_DESTRUCTION_TYPES.SPIDER_NEST, { camp_ID = campData.scriptName } )
					break
				case eWildLifeCampType.PROWLER_DENS:
					//PIN_PlayerItemDestruction( attacker, ITEM_DESTRUCTION_TYPES.PROWLER_NEST, { camp_ID = campData.scriptName } )
					break
			}
		}

	}
}

void function DisplayCampCompletionMessageAfterDelay_Thread( array<entity> players, int campIndex )
{
	wait REWARD_MESSAGE_DELAY
	foreach ( entity player in players )
	{
		if ( IsValidPlayer( player ) && IsAlive( player ) )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_CL_CampClearedNoMaterialRewards", campIndex )
		}
	}
}

void function LeashNPCToAssaultPoint_Thread( entity npc, int npcType, WildlifeCampData campData, string signalToBreakAssaultPoint )
{
	AssertIsNewThread()

	npc.EndSignal( "OnDeath" )

	float fightRadius = npc.AssaultGetFightRadius()

	if (npcType == eNPC.PROWLER)
	{
		npc.kv.disengageEnemyDist = PROWLER_DISENGAGE_DISTANCE
	}

	bool isReturning = false
	while ( true )
	{
		waitthread SetAssaultPointForNPCUntilSignal_Thread( npc, campData, fightRadius, signalToBreakAssaultPoint, isReturning )
		waitthread ResetAssaultPointForNPCAfterCombat_Thread( npc, campData, signalToBreakAssaultPoint )
		isReturning = true
	}
}

void function SetAssaultPointForNPCUntilSignal_Thread( entity npc, WildlifeCampData campData, float fightRadius, string signalToBreakAssaultPoint, bool isReturning )
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_SetAssaultPointForNPCUntilSignal_Thread()")
	#endif

	AssertIsNewThread()

	if ( !IsAlive( npc ) )
		return

	if ( signalToBreakAssaultPoint != "" )
		npc.EndSignal( signalToBreakAssaultPoint )

	OnThreadEnd(
		function() : ( npc )
		{
			if ( !IsAlive( npc ) )
				return

			npc.DisableBehavior( "Assault" )
		}
	)

	npc.EnableBehavior( "Assault" )
	AssaultPointData assaultPoint = campData.assaultPoint
	float assaultRadius = npc.AssaultGetGoalRadius()
	npc.AssaultPointClampedExtents( assaultPoint.origin, <64, 64, 64> )
	if ( isReturning )
	{
		npc.AssaultSetArrivalTolerance( assaultRadius * 0.5 )
	}
	else
	{
		npc.AssaultSetArrivalTolerance( assaultRadius )
	}
	npc.AssaultSetFightRadius( fightRadius )
	npc.AssaultSetGoalHeight( WILDLIFE_ASSAULTPOINT_HEIGHT )

	WaitForever()
}

void function ResetAssaultPointForNPCAfterCombat_Thread( entity npc, WildlifeCampData campData, string signalToBreakAssaultPoint )
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf("TropicsWildlife_ResetAssaultPointForNPCAfterCombat_Thread()")
	#endif

	AssertIsNewThread()

	if ( npc.GetNPCState() != "combat" )
		npc.WaitSignal( "OnStateChange" ) // wait till npc enters combat

	if ( npc.GetNPCState() == "combat" )
	{
		npc.EndSignal( "OnStateChange" )

		AssaultPointData assaultPoint = campData.assaultPoint
		float hardLeashRange = assaultPoint.radius * WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE * 1.5
		while ( Distance2D( npc.GetOrigin(), assaultPoint.origin ) < hardLeashRange ) // create a hard leash range
		{
			wait 1.0
		}

		npc.AssaultSetFightRadius( 0 )
	}
}

void function ResetCampNPCGenerators()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_ResetCampNPCGenerators()" )
	#endif

	foreach ( SpiderEggData egg, WildlifeCampData data in s_spiderEggToWildlifeCamp )
	{
		SpiderEgg_Reset( egg )
	}

	foreach ( ProwlerDenData den, WildlifeCampData data in s_prowlerDenToWildlifeCamp )
	{
		ProwlerDen_Reset( den )
	}
}

void function DestroyAllActiveWildlifeNPCs()
{
	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		WildlifeCampData campData = s_wildlifeCampDatas[i]
		foreach ( entity npc in clone campData.activeNPCs )
		{
			if ( IsValid( npc ) )
			{
				npc.Destroy()
			}
		}
		campData.activeNPCs.clear()
	}

	s_totalAliveAI = 0
}

void function DestroyCampTreasureChests()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_DestroyCampTreasureChests()" )
	#endif

	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		entity deathBox = s_wildlifeCampDatas[i].treasureChest
		if ( IsValid( deathBox ) )
		{
			deathBox.Destroy()
		}
	}

	s_treasureChestsCreated = false
}

WildlifeCampData ornull function GetCampAtPosition( vector position )
{
	foreach ( WildlifeCampData campData in s_wildlifeCampDatas )
	{
		if ( Distance2D( campData.assaultPoint.origin, position ) < campData.assaultPoint.radius )
		{
			return campData
		}
	}

	return null
}

void function ResetAllCampDatas()
{
	#if DEVELOPER
		if ( TROPICS_WILDLIFE_AI_DEBUG )
			printf( "TropicsWildlife_ResetAllCampDatas()" )
	#endif

	for (int i = 0; i < s_wildlifeCampDatas.len(); i++)
	{
		s_wildlifeCampDatas[i].lifeRemaining = s_wildlifeCampDatas[i].totalLife
		s_wildlifeCampDatas[i].cachedDormantNPCs = []
		s_wildlifeCampDatas[i].lootTrackers.clear()
	}
}

void function ForceAwarenessForProwler( WildlifeCampData campData, entity prowler )
{
	if ( !(s_wildlifeCampDatas.contains(campData)) || campData.lifeRemaining > 2)
	{
		UpdateEnemyMemoryWithinRadius( prowler, PROWLER_DEN_SPAWN_TIGGER_RADIUS )
	}
	else
	{
		float assaultRadius = campData.assaultPoint.radius * WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE
		//UpdateEnemyMemoryWithinRadiusAroundPoint( prowler, assaultRadius, campData.assaultPoint.origin )
		float newMaxDistance = assaultRadius * 2 // we want diameter
		prowler.SetMaxEnemyDistOverride( newMaxDistance )
		prowler.kv.disengageEnemyDist = newMaxDistance
	}
}
#endif // SERVER

bool function IsTropicsWildlifeEnabled()
{
	return GetCurrentPlaylistVarBool( "wildlife_ai_enabled", true )
}

void function TropicsWildlife_InitializeNPCDependencies()
{
	FreelanceNPCs_Init()
	#if SERVER
		//NPCGarbageCollection_InitForGameMode()
	#endif
}

#if SERVER
string function DEV_TropicsWildlife_GetCampDetailsAllString()
{
    string wildlifeInfo =
	"-= Tropics Wildlife AI =-\n" +
	"\t Total Wildlife Camps = " + s_wildlifeCampDatas.len() + "\n" +
	"\t Total Active Camps = " + s_activeWildlifeCampDatas.len() + "\n" +
	"\t Total Prowler Camps = " + DEV_TropicsWildlife_CountCampsByType( eWildLifeCampType.PROWLER_DENS ) + "\n" +
	"\t Total Prowler Spawners = " + s_prowlerSpawnPoints.len() + "\n" +
	"\t Total Prowler Den Spawners = " + s_prowlerDenGeneratorDatas.len() + "\n" +
	"\t Total Treasure Chests = " + s_treasureChestDatas.len() + "\n" +
	"\t Total Spider Camps = " + DEV_TropicsWildlife_CountCampsByType( eWildLifeCampType.SPIDER_NEST ) + "\n" +
	"\t Total Spider Spawners = " + s_spiderSpawnPoints.len() + "\n" +
	"\t Total Spider Egg Spawners = " + s_spiderEggGeneratorDatas.len()
    return wildlifeInfo
}
#endif

#if DEVELOPER && SERVER
void function DEV_TropicsWildlife_PrintCampDetails( entity player )
{
	if ( !IsValid( player ) )
	{
		return
	}

	WildlifeCampData ornull camp = GetCampAtPosition( player.GetOrigin() )
	if ( camp == null )
	{
		return
	}

	expect WildlifeCampData( camp )
	printf( "-= Tropics Wildlife AI =-" )
	printf( "\tTropics Camp Location = " + camp.assaultPoint.origin )
	printf( "\tTropics Camp Type = " + ( camp.type == eWildLifeCampType.PROWLER_DENS ? "Prowler" : "Spider" ) )
	printf( "\tTropics Camp Is Active = " + camp.isActive )
	printf( "\tTropics Camp Is Disabled = " + camp.isDisabled )
	printf( "\tTropics Camp Assault Radius = " + camp.assaultPoint.radius )
	printf( "\tTropics Camp Stats ( Alive = " + camp.activeNPCs.len() + " Max Alive = " + camp.maxAlive + " Life Remaining = " + camp.lifeRemaining + " Total Life = " + camp.totalLife + " )" )
	printf( "\tTropics Camp Treasure Chests = " + camp.linkedTreasureChests.len() )
	printf( "\tTropics Camp NPC Spawners = " + camp.linkedNPCSpawners.len() )
	printf( "\tTropics Camp NPC Generators = " + camp.linkedNPCGenerators.len() )
}

void function DEV_TropicsWildlife_PrintCampDetailsAll()
{
	printf( "-= Tropics Wildlife AI =-" )
	printf( "\t Total Wildlife Camps = " + s_wildlifeCampDatas.len() )
	printf( "\t Total Active Camps = " + s_activeWildlifeCampDatas.len() )
	printf( "\t Total Prowler Camps = " + DEV_TropicsWildlife_CountCampsByType( eWildLifeCampType.PROWLER_DENS ) )
	printf( "\t Total Prowler Spawners = " + s_prowlerSpawnPoints.len() )
	printf( "\t Total Prowler Den Spawners = " + s_prowlerDenGeneratorDatas.len() )
	printf( "\t Total Treasure Chests = " + s_treasureChestDatas.len() )
	printf( "\t Total Spider Camps = " + DEV_TropicsWildlife_CountCampsByType( eWildLifeCampType.SPIDER_NEST ) )
	printf( "\t Total Spider Spawners = " + s_spiderSpawnPoints.len() )
	printf( "\t Total Spider Egg Spawners = " + s_spiderEggGeneratorDatas.len() )
}

int function DEV_TropicsWildlife_CountCampsByType( int type )
{
	int count = 0
	foreach (key, val in s_wildlifeCampDatas)
	{
		count += val.type == type ? 1 : 0
	}
	return count
}

bool s_isDebugDrawAssaultRadiiEnabled = false
void function DEV_TropicsWildlife_ToggleDebugDrawAssaultRadii()
{
	if ( s_isDebugDrawAssaultRadiiEnabled == true )
	{
		s_isDebugDrawAssaultRadiiEnabled = false
	} else {
		s_isDebugDrawAssaultRadiiEnabled = true
		thread function() : ()
		{
			for ( ;; )
			{
				WaitFrame()
				if ( !s_isDebugDrawAssaultRadiiEnabled )
				{
					break
				}

				foreach ( WildlifeCampData campData in s_wildlifeCampDatas )
				{
					vector origin = campData.assaultPoint.origin
					float radius = campData.assaultPoint.radius
					if ( campData.type == eWildLifeCampType.PROWLER_DENS && campData.scriptName != SCRIPT_NAME_GOLIATH_PIT_KEYWORD && !campData.limitProwlerAssaultRadius )
						radius *= WILDLIFE_PROWLER_ASSAULTPOINT_EXTENDS_SCALE
					DebugDrawTrigger( origin, radius, 255, 0, 102, 1.0, true )
				}
			}
		}()
	}
}

bool s_isDebugDrawActivationRadiiEnabled = false
void function DEV_TropicsWildlife_ToggleDebugDrawActivationRadii()
{
	if ( s_isDebugDrawActivationRadiiEnabled == true )
	{
		s_isDebugDrawActivationRadiiEnabled = false
	} else {
		s_isDebugDrawActivationRadiiEnabled = true
		thread function() : ()
		{
			for ( ;; )
			{
				WaitFrame()
				if ( !s_isDebugDrawActivationRadiiEnabled )
				{
					break
				}

				foreach ( WildlifeCampData campData in s_wildlifeCampDatas )
				{
					DebugDrawTrigger( campData.activationOrigin, campData.activationRadius, 255, 255, 255, 1.0, true )
				}
			}
		}()
	}
}

void function DEV_TropicsWildlife_PrintTotalAIOnMap()
{
	printf( "-= Tropics Wildlife AI =-" )
	// todo (tgoodbrand): this will have to loop through all active camps to get active ai eventually
	printf( "\t Total Active AI = " + s_totalAliveAI )
	printf( "\t Total Dormant AI = TODO" ) // these are ai agents that are in a camp that's deactivated
}

void function DEV_TropicsWildlife_ToggleCampsEnabled()
{
	if ( s_campsActivationEnabled == true )
	{
		printf( "-= Wildlife AI camp activation toggled off =-" )
		s_campsActivationEnabled = false
		printf( "\t AI camp activation TODO" )
	} else {
		printf( "-= Wildlife AI camp activation toggled on =-" )
		s_campsActivationEnabled = true
		printf( "\t AI camp activation TODO" )
	}
}

void function DEV_TropicsWildlife_DestroyAllSkits()
{
	waitthread DEV_TropicsWildlife_DestroyAllSkits_Thread()

	for( int i = 0; i < s_wildlifeCampDatas.len(); i++ )
	{
		WildlifeCampData campData = s_wildlifeCampDatas[i]
		campData.npcGeneratorEnts.clear()
		if ( IsValid( campData.minimapIcon ) )
		{
			foreach ( player in GetPlayerArray() )
			{
				campData.minimapIcon.Minimap_Hide( 0, player )
			}
			campData.minimapIcon.Destroy()
		}
		campData.isActive = false
	}

	// destroy spider eggs
	printf( "-= Wildlife AI Destroy all Spider Eggs =-" )
	foreach ( SpiderEggData egg, WildlifeCampData data in s_spiderEggToWildlifeCamp )
	{
		SpiderEgg_Destroy( egg )
	}
	s_spiderEggToWildlifeCamp.clear()

	// destroy prowler dens
	printf( "-= Wildlife AI Destroy all Prowler Den =-" )
	foreach ( ProwlerDenData den, WildlifeCampData data in s_prowlerDenToWildlifeCamp )
	{
		ProwlerDen_Destroy( den )
	}
	s_prowlerDenToWildlifeCamp.clear()

	s_activeWildlifeCampDatas.clear()

	s_generatorsCreated = false

	printf( "\t Total AI across Map = " + s_totalAliveAI )
	printf( "-= Tropics Wildlife Clean Up Complete =-" )
}

void function DEV_TropicsWildlife_DestroyAllSkits_Thread()
{
	AssertIsNewThread()

	printf( "-= Tropics Wildlife remove AI from Map =-" )
	if ( s_wildlifeRuntimeThreadRunning )
	{
		TropicsWildlifeRuntimeThinkStop()
	}
	else
	{
		printf( "\t Wildlife runtime is not active. Try DEV_TropicsWildlife_CreateAllSkits to startup map AI\n" )
	}

	DestroyAllActiveWildlifeNPCs()
}

void function DEV_TropicsWildlife_CreateAllSkits()
{
	printf( "-= Tropics Wildlife create AI on Map =-" )
	if ( !s_wildlifeRuntimeThreadRunning )
	{
		ResetAllCampDatas()
		if ( s_generatorsCreated )
		{
			ResetCampNPCGenerators()
		}
		else
		{
			CreateCampNPCGenerators()
		}
		CreateCampTreasureChests()
		TropicsWildlifeRuntimeThinkStart()
	}
	else
	{
		printf( "\t Wildlife runtime already initialized. Try DEV_TropicsWildlife_DestroyAllSkits first\n" )
	}
}

void function DEV_TropicsWildlife_HardResetAllSkits() // destroys all generators, spawners, ai, resets all data and creates all camps fresh as if from map load
{
	printf( "-= Tropics Wildlife hard reset AI on Map =-" )

	thread DEV_TropicsWildlife_HardResetAllSkits_Thread()

	printf( "-= Tropics Wildlife Hard Reset Complete =-" )
}

void function DEV_TropicsWildlife_HardResetAllSkits_Thread()
{
	AssertIsNewThread()

	waitthread DEV_TropicsWildlife_DestroyAllSkits_Thread()
	DestroyCampTreasureChests()
	DEV_TropicsWildlife_CreateAllSkits()
}

void function DEV_TropicsWildlife_SpawnXSpiders( int spawnCount = 5 )
{
	DEV_TropicsWildlife_DebugSpawn_Internal( spawnCount, "npc_spider", HULL_SMALL, eNpcTeam.INFECTED, 196, 768 )
}

void function DEV_TropicsWildlife_SpawnXProwlers( int spawnCount = 5 )
{
	DEV_TropicsWildlife_DebugSpawn_Internal( spawnCount, "npc_prowler", HULL_PROWLER, eNpcTeam.WILDLIFE )
}

void function DEV_TropicsWildlife_DebugSpawn_Internal( int spawnCount, string npcClassName, int hullType, int npcTeam, float minDist = 512, float maxDist = 2048 )
{
	spawnCount = minint( spawnCount, 99 )
	spawnCount = maxint( spawnCount, 1 )
	array<vector> origins = NavMesh_RandomPositions_LargeArea( GetPlayerArray()[0].GetOrigin(), hullType, spawnCount, minDist, maxDist )
	if ( origins.len() == 0 )
	{
		BroadcastTestMsg( "Can't debug spawn NPCs - no navmesh to spawn NPCS.", FILE_NAME() )
		return
	}

	if ( CheckIfActiveAIWithinLimit() == false )
	{
		return
	}

	for ( int i = 0; i < origins.len(); ++i )
	{
		entity npc = CreateNPCFromAISettings( npcClassName, npcTeam, origins[i], <0,0,0> )
		DispatchSpawn( npc )
	}
}

void function BroadcastHudSplashToRadius( string messageText, string subText, vector origin, float range, float duration )
{
	entity wp = CreateWaypoint_Custom( "broadcasthudsplash_msg" )
	wp.SetWaypointString( 0, messageText )
	wp.SetWaypointString( 1, subText )
	wp.SetWaypointVector( 0, origin )
	wp.SetWaypointFloat( 0, range )
	wp.SetWaypointFloat( 1, duration )

	thread function() : (wp)
	{
		wait 1.0
		wp.Destroy()
	}()
}

void function BroadcastTestMsg( string messageText, string subText )
{
	BroadcastHudSplashToRadius( messageText, subText, <0,0,0>, -1.0, 4.0 )
}
#endif // DEV && SERVER

#if CLIENT
void function Wildlife_ServerToClient_SetWildlifeClientEnt( entity targetEnt, bool active, int campType )
{
	printf("Wildlife attempting to set")
	if ( IsValid( targetEnt ) )
	{
		WildlifeTrackingData newWildlifeData
		newWildlifeData.rootEnt = targetEnt
		newWildlifeData.active = active
		newWildlifeData.wildlifeType = campType

		file.wildlifeEntStatuses[targetEnt] <- newWildlifeData
		printf("Wildlife Root Set: " + targetEnt)
	}
}
#endif // CLIENT

#if CLIENT
entity function GetWildlifeUnderAim( vector worldPos, float worldRange )
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

	foreach( entity spawnEnt, WildlifeTrackingData wildlifeData in file.wildlifeEntStatuses )
	{
		if ( !IsValid( spawnEnt ) )
			continue

		if( !file.wildlifeEntStatuses[spawnEnt].active )
			continue

		vector wildlifeOrigin = spawnEnt.GetOrigin()

		float distSqr = Distance2DSqr( wildlifeOrigin, worldPos )
		if ( distSqr < worldRangeSqr && distSqr < closestDistSqr  )
		{
			closestDistSqr = distSqr
			closestEnt     = spawnEnt
		}
	}

	if ( !IsValid( closestEnt ) )
	{
		return null
	}

	//return the object
	return closestEnt
}

bool function PingWildlifeUnderAim( entity targetEnt )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) || !IsAlive( player ) )
		return false

	if ( !IsPingEnabledForPlayer( player ) )
		return false

	if( !IsValid( targetEnt ) )
		return false

	int pingType

	if( file.wildlifeEntStatuses[targetEnt].wildlifeType == eWildLifeCampType.PROWLER_DENS )//eCampType.PROWLER_DENS )
		pingType = ePingType.PING_PROWLER_DEN

	if( file.wildlifeEntStatuses[targetEnt].wildlifeType == eWildLifeCampType.SPIDER_NEST )
		pingType = ePingType.PING_SPIDER_EGGS

	EmitSoundOnEntity( GetLocalViewPlayer(), PING_SOUND_LOCAL_CONFIRM )

	return true
}
#endif


#if SERVER
void function Wildlife_ClientToServer_PingWildlifeFromMap( entity player, entity targetEnt, int pingType )
{
	if ( IsValid( player ) && IsValid( targetEnt ) )
	{
		//CreateWaypoint_Ping_Location( player, pingType, targetEnt, targetEnt.GetOrigin() + <0, 0, 50>, -1, false, false, pingWheelIndex.PING_MAP )
	}
}
#endif