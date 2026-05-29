                    

global function GoldenHorse_Init

global function IsGoldenHorse_FR
global function GoldenHorse_TicksEnabled
global function GoldenHorse_SwordCarePackageEnabled
global function GoldenHorse_ModifyCarePackageSpawnDistance

#if SERVER

global function GoldenHorse_OnPlayerReconnected
global function ClientToServer_ClientToServer_PingLootTickFromMap

#if DEVELOPER
global function DEV_SpawnGoldenHorseTick
global function DEV_SpawnTitanSword
#endif

#endif

#if CLIENT
global function ServerToClient_GoldenHorse_RegisterLootTick
global function ServerToClient_GoldenHorse_MarkAllLootTicks

global function GoldenHorse_UpdateLootHighlight
#endif

//Playlist
const string PVAR_GOLDEN_HORSE_FR_ENABLED = "is_golden_horse_fr"
const string PVAR_GOLDEN_HORSE_TICKS_ENABLED = "golden_horse_ticks_enabled"
const string PVAR_GOLDEN_HORSE_SWORD_SPAWNS_ENABLED = "golden_horse_swords_enabled"
const string PVAR_GOLDEN_HORSE_SWORD_HOVERTANK_ENABLED = "golden_horse_sword_hovertank_enabled"
const string PVAR_GOLDEN_HORSE_SWORD_CAREPACKAGE_ENABLED = "golden_horse_sword_carepackage_enabled"
const string PVAR_GOLDEN_HORSE_CAREPACKAGE_DIST_ENABLED = "golden_horse_carepackage_dist_enabled"
const string PVAR_GOLDEN_HORSE_SPAWN_ALL_TICKS = "golden_horse_spawn_all_ticks"
const string PVAR_GOLDEN_HORSE_TICKS_PER_CLUSTER = "golden_horse_ticks_per_cluster"
const string PVAR_GOLDEN_HORSE_SWORDS_PER_CLUSTER = "golden_horse_swords_per_cluster"
const string PVAR_GOLDEN_HORSE_SWORDS_SUBDIVIDE_PER_CLUSTER = "golden_horse_swords_subdivide"
const string PVAR_GOLDEN_HORSE_SPAWN_ALL_SWORDS = "golden_horse_spawn_all_swords"
const string PVAR_GOLDEN_HORSE_RED_MAX = "golden_horse_red_max"
const string PVAR_GOLDEN_HORSE_TICK_DIST_HUD_MIN = "golden_horse_tick_dist_hud_min"
const string PVAR_GOLDEN_HORSE_TICK_DIST_HUD_MAX = "golden_horse_tick_dist_hud_min"

//NAMES
global const string GOLDEN_HORSE_LOOT_TICK_SCRIPT_NAME = "loot_tick_golden_horse"

//VARS
const int GOLDEN_HORSE_TICKS_PER_CLUSTER = 4 //Gets us 12
const int GOLDEN_HORSE_SWORDS_PER_CLUSTER = 3 //Gets us 9
const int GOLDEN_HORSE_SWORDS_SUBDIVIDE = 1 //Gets us 8
const int GOLDEN_HORSE_RED_MAX = 60
global const int GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER = 107 //TODO: wow I should find a better spot for this
const float GOLDEN_HORSE_TICK_DIST_HUD_MIN = 30 * METERS_TO_INCHES
const float GOLDEN_HORSE_TICK_DIST_HUD_MAX = 35 * METERS_TO_INCHES

//UI
const asset GOLDEN_HORSE_TICK_ICON = $"rui/gamemodes/golden_horse/golden_horse_tick_icon"

struct ClusterSpawnData
{
	vector origin
	vector angles
}

struct
{
	#if SERVER
		int           redMax = GOLDEN_HORSE_RED_MAX
		int           redCount = 0
		array<entity> ticksArray
	#endif

	#if CLIENT
		table<entity, var> tickMarkersTable
		table<entity, var> tickWorldIconTable // Only use this for marking all loot ticks during skydive
	#endif
} file

bool function IsGoldenHorse_FR()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_FR_ENABLED, false )
}

bool function GoldenHorse_SwordCarePackageEnabled()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_SWORD_CAREPACKAGE_ENABLED, true )
}

bool function GoldenHorse_ModifyCarePackageSpawnDistance()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_CAREPACKAGE_DIST_ENABLED, true )
}

bool function GoldenHorse_TicksEnabled()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_TICKS_ENABLED, true )
}

bool function GoldenHorse_DebugTicks()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_SPAWN_ALL_TICKS, false )
}

bool function GoldenHorse_SwordSpawnsEnabled()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_SWORD_SPAWNS_ENABLED, true )
}

bool function GoldenHorse_DebugSwordSpawns()
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_SPAWN_ALL_SWORDS, false )
}

void function GoldenHorse_Init()
{
	#if SERVER
		file.redMax = GetCurrentPlaylistVarInt( PVAR_GOLDEN_HORSE_RED_MAX, GOLDEN_HORSE_RED_MAX )

		Loot_AddCallback_OnLootSpawn( OnLootSpawn )
		AddCallback_EntitiesDidLoad( OnEntitiesDidLoad )
		AddCallback_OnQuickchatEvent( eCommsAction.QUICKCHAT_GH_MARK_LOOT_TICKS, GoldenHorse_MarkAllLootTicks )
		AddCallback_OnPlayerMatchStateChanged( GoldenHorse_Server_OnPlayerMatchStateChanged )
	#endif

	#if CLIENT
		AddCallback_OnPlayerMatchStateChanged( GoldenHorse_Client_OnPlayerMatchStateChanged )
		AddCallback_GameStateEnter( eGameState.Playing, GoldenHorse_OnGamestateEnterPlaying_Client )
		AddCallback_OnFindFullMapAimEntity( GetLootTickUnderAim, PingLootTickUnderAim )
		GoldenHorse_RegisterMinimapPackage()
	#endif

	#if SERVER || CLIENT
		Remote_RegisterClientFunction( "ServerToClient_GoldenHorse_RegisterLootTick", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_GoldenHorse_MarkAllLootTicks" )
		Remote_RegisterServerFunction( "ClientToServer_ClientToServer_PingLootTickFromMap", "typed_entity", "npc_frag_drone" )
	#endif
}

void function OnEntitiesDidLoad()
{

	#if SERVER
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) && GoldenHorse_TicksEnabled() )
			thread InitTicks_Thread()
		if ( GoldenHorse_SwordSpawnsEnabled() )
			thread InitSwords_Thread()
	#endif
}


//SPAWNS LOGIC
#if SERVER
ClusterSpawnData function CreateClusterSpawn( vector origin, vector angles = <-1, -1, -1> )
{
	ClusterSpawnData data
	data.origin = origin
	data.angles = angles
	return data
}

void function SpawnCluster( array < array<ClusterSpawnData> > clusters, int spawnsPerCluster, int subdivisionsPerCluster, bool spawnAll, void functionref( vector, vector ) callbackFunc )
{
	if ( spawnAll )
	{
		foreach ( array<ClusterSpawnData> cluster in clusters )
		{
			foreach ( ClusterSpawnData spawn in cluster )
			{
				callbackFunc( spawn.origin, spawn.angles )
			}
		}
	}
	else
	{
		array < array<ClusterSpawnData> > clusterCheck
		table < array<ClusterSpawnData>, int > spawnCount

		//Dupe info to get unique spawns
		foreach ( array<ClusterSpawnData> cluster in clusters )
		{
			clusterCheck.append( cluster )
			spawnCount[cluster] <- spawnsPerCluster
		}

		//How many do we want to do instead
		for ( int i = 0; i < subdivisionsPerCluster; ++i )
		{
			array<ClusterSpawnData> cluster = clusterCheck.getrandom()
			clusterCheck.fastremovebyvalue( cluster )
			spawnCount[cluster] -= 1

			if ( clusterCheck.len() == 0 )
				break
		}

		//int debugIndex = 0
		//int totalSpawned = 0
		foreach ( array<ClusterSpawnData> cluster in clusters )
		{
			//printt( "CLUSTER SPAWNING " + spawnCount[cluster] + " from " + debugIndex )
			for ( int i = 0; i < spawnCount[cluster]; ++i )
			{
				ClusterSpawnData spawn = cluster.getrandom()
				//				thread SpawnTick_Thread( spawn )
				callbackFunc( spawn.origin, spawn.angles )
				cluster.fastremovebyvalue( spawn )
				//++totalSpawned
				if ( cluster.len() == 0 )
					break
			}
			//++debugIndex
		}
		//printt( "CLUSTER SPAWNED A TOTAL OF " + totalSpawned )
	}
}
#endif

//Tick Spawning
#if SERVER
void function InitTicks_Thread()
{
	int ticksPerCluster = GetCurrentPlaylistVarInt( PVAR_GOLDEN_HORSE_TICKS_PER_CLUSTER, GOLDEN_HORSE_TICKS_PER_CLUSTER )
	SpawnCluster( GetTickClusterForMap(), ticksPerCluster, 0, GoldenHorse_DebugTicks(), SpawnTick )
}

void function SpawnTick( vector origin, vector angles )
{
	thread SpawnTick_Thread( origin, angles )
}

void function SpawnTick_Thread( vector origin, vector angles )
{
	printt( "SPAWNING GOLDEN HORSE TICK AT: " + origin )
	if ( angles == <-1, -1, -1> )
		angles = <0, 0, 0>
	entity tick = LootTicks_SpawnLootTickAtOrigin( origin, angles, HopupGoldenHorse_GetEnabledList(), GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER )
	tick.SetScriptName( GOLDEN_HORSE_LOOT_TICK_SCRIPT_NAME )
	//tick.SetNetworkDistanceCullEnabled( false )
	tick.Minimap_SetAlignUpright( true )
	tick.Minimap_SetClampToEdge( false )
	tick.Minimap_SetCustomState( eMinimapObject_npc.LOOT_TICK_GH )
	tick.Minimap_SetZOrder( MINIMAP_Z_OBJECT )

	//Probably don't need beam anymore if we have the show loot ticks button, but leave it in for now (or flip it on when they hit the button)
	//thread CreateLootBeam( tick, COLORID_HUD_LOOT_TIER_GH )

	file.ticksArray.append( tick )
}

void function CreateLootBeam( entity ent, int color )
{
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	int beamIndex = GetParticleSystemIndex( FX_AIRDROP_BEAM_CP )
	entity beamFx = StartParticleEffectInWorld_ReturnEntity( beamIndex, ent.GetOrigin(), ent.GetAngles() + <0, 180, 0> )
	EffectSetControlPointColorById( beamFx, 1, color )
	OnThreadEnd(
		function() : ( beamFx )
		{
			beamFx.Destroy()
		}
	)

	WaitForever()
}

// Tell all clients to create loot tick RUIs
void function GoldenHorse_Server_OnPlayerMatchStateChanged( entity player, int oldState, int newState )
{
	if ( newState == ePlayerMatchState.SKYDIVE_PRELAUNCH )
	{
		RegisterLootTicksOnClient( player )
	}
}

void function GoldenHorse_OnPlayerReconnected( entity player )
{
	RegisterLootTicksOnClient( player )
}

void function RegisterLootTicksOnClient( entity player )
{
	if ( !IsValid( player ) )
		return

	foreach ( tick in file.ticksArray )
	{
		Remote_CallFunction_NonReplay( player, "ServerToClient_GoldenHorse_RegisterLootTick", tick )
	}
}

// Tell all clients to create skydive markers for loot ticks
void function GoldenHorse_MarkAllLootTicks( entity player, int commsAction, entity subjectEnt )
{
	Remote_CallFunction_NonReplay( player, "ServerToClient_GoldenHorse_MarkAllLootTicks" )
}
#endif

#if CLIENT
void function ServerToClient_GoldenHorse_RegisterLootTick( entity tick )
{
	if ( !IsValid( tick ) )
		return

	AddEntityDestroyedCallback( tick,
		void function( entity ent ) : ( tick )
		{
			GoldenHorse_OnTickDestroyed( tick )
		}
	)

	vector pos             = tick.GetOrigin() + tick.GetUpVector() * 50
	entity localViewPlayer = GetLocalViewPlayer()
	var rui                = GoldenHorse_CreateTickRui( pos, 36, 48,
		GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_TICK_DIST_HUD_MIN, GOLDEN_HORSE_TICK_DIST_HUD_MIN ), GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_TICK_DIST_HUD_MAX, GOLDEN_HORSE_TICK_DIST_HUD_MAX ), true )

	file.tickWorldIconTable[ tick ] <- rui
}

void function GoldenHorse_OnTickDestroyed( entity tick )
{
	if ( !(tick in file.tickWorldIconTable) )
		return

	var rui = file.tickWorldIconTable[ tick ]
	RuiSetBool( rui, "isFinished", true )
}

void function GoldenHorse_Client_OnPlayerMatchStateChanged( entity player, int newState )
{
	if ( player != GetLocalViewPlayer() )
		return

	// UI Prompt to mark loot ticks when preparing to skydive
	if ( newState == ePlayerMatchState.SKYDIVE_PRELAUNCH )
	{
		GoldenHorse_PromptMarkAllLootTicks()
	}

	// Destroy all loot tick markers when player lands
	if ( newState == ePlayerMatchState.NORMAL )
	{
		GoldenHorse_DestroyLootTickMarkers()
	}
}

void function GoldenHorse_PromptMarkAllLootTicks()
{
	thread Thread_PromptMarkAllLootTicks()
}

void function Thread_PromptMarkAllLootTicks()
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) || ShouldMuteCommsActionForCooldown( player, eCommsAction.QUICKCHAT_GH_MARK_LOOT_TICKS, null ) )
		return

	wait 2.0

	AddOnscreenPromptFunction( "quickchat", CreateQuickchatFunction( eCommsAction.QUICKCHAT_GH_MARK_LOOT_TICKS, player ), 10, Localize( "#QUICKCHAT_MARK_ALL_CACTICKS" ) )
}

void function ServerToClient_GoldenHorse_MarkAllLootTicks()
{
	entity localViewPlayer = GetLocalViewPlayer()
	EmitSoundOnEntity( localViewPlayer, "coop_minimap_ping" )

	foreach ( entity tick, var icon in file.tickWorldIconTable )
	{
		vector pos = tick.GetOrigin() + tick.GetUpVector() * 50
		var rui    = GoldenHorse_CreateTickRui( pos, 32, 54, 50000, 200000, false )
		file.tickMarkersTable[tick] <- rui
	}
}

var function GoldenHorse_CreateTickRui( vector pos, float sizeMin, float sizeMax, float minDist, float maxDist, bool hideNearCrossHair )
{
	entity localViewPlayer = GetLocalViewPlayer()
	var rui                = CreatePermanentCockpitRui( $"ui/survey_beacon_marker_icon.rpak", RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), pos ) )
	RuiSetImage( rui, "beaconImage", GOLDEN_HORSE_TICK_ICON )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", pos )
	RuiSetFloat( rui, "sizeMin", sizeMin )
	RuiSetFloat( rui, "sizeMax", sizeMax )
	RuiSetFloat( rui, "minAlphaDist", minDist )
	RuiSetFloat( rui, "maxAlphaDist", maxDist )
	RuiSetBool( rui, "shouldHideNearCrosshairs", hideNearCrossHair )
	RuiKeepSortKeyUpdated( rui, true, "pos" )

	return rui
}

void function GoldenHorse_DestroyLootTickMarkers()
{
	foreach ( rui in file.tickMarkersTable )
	{
		RuiSetBool( rui, "isFinished", true )
	}
	file.tickMarkersTable.clear()
}
#endif

//Sword Spawning
#if SERVER
void function InitSwords_Thread()
{
	int swordsPerCluster       = GetCurrentPlaylistVarInt( PVAR_GOLDEN_HORSE_SWORDS_PER_CLUSTER, GOLDEN_HORSE_SWORDS_PER_CLUSTER )
	int swordsSubdivideCluster = GetCurrentPlaylistVarInt( PVAR_GOLDEN_HORSE_SWORDS_SUBDIVIDE_PER_CLUSTER, GOLDEN_HORSE_SWORDS_SUBDIVIDE )
	SpawnCluster( GetSwordClusterForMap(), swordsPerCluster, swordsSubdivideCluster, GoldenHorse_DebugSwordSpawns(), SpawnSword )
}

void function SpawnSword( vector origin, vector angles )
{
	//Hack to show swords on map
	//thread SpawnTick_Thread( origin, angles )

	//offset to reposition sword
	origin += VectorRotate( <-8, 0, 0>, angles )
	thread SpawnSword_Thread( origin, angles )
}

void function SpawnSword_Thread( vector origin, vector angles )
{
	printt( "SPAWNING GOLDEN HORSE TITAN SWORD AT: " + origin )
	entity sword = SpawnGenericLoot( TITAN_SWORD_WEAPON_REF, origin, angles )
}
#endif

#if SERVER
//TODO: Stuff for weapon skins maybe?
void function OnLootSpawn( entity ent, LootData data, int count )
{
	if ( data.ref == "hopup_golden_horse_red" )
	{
		++file.redCount

		if ( file.redCount > file.redMax )
		{
			ent.e.lootRef = "hopup_golden_horse_blue" //TODO: Pick a random one, but we just can't spawn any more reds
		}
	}
	/*switch ( data.ref )
	{
		case ENERGY_MOZAMBIQUE_WEAPON_REF:
			thread DelayedSkinChange_Thread( ent, $"settings/itemflav/weapon_skin/mozambique/epic_04.rpak" )
			break

		case HEAVY_MOZAMBIQUE_WEAPON_REF:
			thread DelayedSkinChange_Thread( ent, $"settings/itemflav/weapon_skin/mozambique/legendary_03.rpak" )
			break

		case LIGHT_MOZAMBIQUE_WEAPON_REF:
			thread DelayedSkinChange_Thread( ent, $"settings/itemflav/weapon_skin/mozambique/rare_13.rpak" )
			break

		case SNIPER_MOZAMBIQUE_WEAPON_REF:
			thread DelayedSkinChange_Thread( ent, $"settings/itemflav/weapon_skin/mozambique/legendary_01.rpak" )
			break
	}*/
}

//TODO: I should really make it easier to do without thread
void function DelayedSkinChange_Thread( entity ent, asset skin )
{
	wait 0.1
	if ( IsValid( ent ) )
	{
		ItemFlavor skinFlavor = GetItemFlavorByAsset( skin )
		//ItemFlavor charmFlavor = GetItemFlavorByAsset( charm )
		WeaponCosmetics_Apply( ent, skinFlavor, null )
	}
}
#endif

#if CLIENT
string function GoldenHorse_UpdateLootHighlight( entity prop, string ref, int tier, string highlight )
{
	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
		return highlight

	if ( ref == "hopup_golden_horse_green" )
		highlight = "survival_item_gh"

	return highlight
}
#endif

//Map functions
#if CLIENT
void function GoldenHorse_OnGamestateEnterPlaying_Client()
{
	SetMapFeatureItem( 1000, "#GOLDEN_HORSE_MAP_FEATURE", "#GOLDEN_HORSE_MAP_FEATURE_DESC", GOLDEN_HORSE_TICK_ICON )
}

void function GoldenHorse_RegisterMinimapPackage()
{
	RegisterMinimapPackage( "npc_frag_drone", eMinimapObject_npc.LOOT_TICK_GH, MINIMAP_OBJECT_RUI, MinimapPackage_LootTick, FULLMAP_OBJECT_RUI, FullmapPackage_LootTick )
}

void function MinimapPackage_LootTick( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", GOLDEN_HORSE_TICK_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetBool( rui, "forceShow", true )
}

void function FullmapPackage_LootTick( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", GOLDEN_HORSE_TICK_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetBool( rui, "forceShow", true )
}

entity function GetLootTickUnderAim( vector worldPos, float worldRange )
{
	float closestDistSqr = FLT_MAX
	float worldRangeSqr  = worldRange * worldRange
	entity closestEnt    = null

	if ( MapPing_Modify_DistanceCheck_Enabled() )
	{
		float modifier = MapPing_DistanceCheck_GetModifier()

		if ( worldRange >= MapPing_DistanceCheck_GetDistanceRange() )
			modifier *= 0.5

		worldRangeSqr = (worldRange * modifier) * (worldRange * modifier)
	}

	foreach ( entity tick, var rui in file.tickWorldIconTable )
	{
		if ( !IsValid( tick ) )
			continue

		vector beaconOrigin = tick.GetOrigin()

		float distSqr = Distance2DSqr( beaconOrigin, worldPos )
		if ( distSqr < worldRangeSqr && distSqr < closestDistSqr )
		{
			closestDistSqr = distSqr
			closestEnt     = tick
		}
	}

	if ( !IsValid( closestEnt ) )
		return null

	return closestEnt
}

bool function PingLootTickUnderAim( entity tick )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) || !IsAlive( player ) || !IsPingEnabledForPlayer( player ) )
		return false

	Remote_ServerCallFunction( "ClientToServer_ClientToServer_PingLootTickFromMap", tick )
	EmitSoundOnEntity( GetLocalViewPlayer(), PING_SOUND_LOCAL_CONFIRM )
	return true
}
#endif

#if SERVER
void function ClientToServer_ClientToServer_PingLootTickFromMap( entity player, entity tick )
{
	if ( IsValid( player ) && IsValid( tick ) )
	{
		entity wp = CreateWaypoint_Ping_Location( player, ePingType.LOOT_TICK_GH, tick, tick.GetOrigin() + tick.GetUpVector() * 50, -1, false, false, pingWheelIndex.PING_MAP )
	}
}
#endif

//Tick Clusters
#if SERVER
//19.1 is
//CLands HU
//Tropics MU2
//DLands HU
array < array<ClusterSpawnData> > function GetTickClusterForMap()
{
	switch ( GetMapName() )
	{
		case "mp_rr_desertlands_hu":
			return GetTickCluster_WorldsEdge()

		case "mp_rr_canyonlands_hu":
			return GetTickCluster_KingsCanyon()

		case "mp_rr_tropic_island_mu2":
			return GetTickCluster_Tropics()

		case "mp_rr_olympus_mu2":
			return GetTickCluster_Olympus()

		case "mp_rr_divided_moon":
			return GetTickCluster_DividedMoon()
	}

	return [[CreateClusterSpawn( < 0, 0, 0> )]]
}

array < array<ClusterSpawnData> > function GetTickCluster_WorldsEdge()
{
	return [
		//NE
		[
			CreateClusterSpawn( < 26466.6, 11920.3, -2536.3 >, < 0, 151.106, 0 > ),
			CreateClusterSpawn( < 14947.2, 5611.34, -3855.97 >, < 0, -45.7021, 0 > ),
			CreateClusterSpawn( < 11726.5, -7985.94, -3933.37 >, < 0, -71.263, 0 > ),
			CreateClusterSpawn( < 12416.6, 20024.3, -3955.5> ),
			//CreateClusterSpawn( < 17036.9, 30544.4, -3918.33> ), //Doubles at climatize
			//CreateClusterSpawn( < 22488.9, 25095, -3918.33> ),
			CreateClusterSpawn( < 20999.7, 28594, -5071.84 >, < 0, -150.533, 0 > ),
			CreateClusterSpawn( < 1520.02, 10257.1, -4073.97 >, < 0, 43.3963, 0 > ),
		],

		//NW
		[
			CreateClusterSpawn( < -11085.5, 21457.5, -3463.97 >, < 0, -92.0529, 0 > ),
			CreateClusterSpawn( < 79.19, 20489, -2895.97 > ),
			CreateClusterSpawn( < -32681.2, 16374.6, -3008.95 >, < 0, 49.3542, 0 > ),
			CreateClusterSpawn( < -18408.7, 13369.6, -3614.97> ),
			CreateClusterSpawn( < -12963.1, 4385.25, -2501.24 >, < 0, 85.2295, 0 > ),
			CreateClusterSpawn( < -27234.9, -299.577, -3136.34 >, < 0, -37.4269, 0 > ),
			CreateClusterSpawn( < -7440.36, -10695.4, -3839.94> ),
		],

		//S
		[
			CreateClusterSpawn( < 6307.99, -20224.6, -3635.97> ),
			CreateClusterSpawn( < 29501.1, -8175.45, -3263.34 > ),
			CreateClusterSpawn( < -28406.8, -27324.7, -4243.94> ),
			CreateClusterSpawn( < -5106.24, -33681.3, -3555.48> ),
			CreateClusterSpawn( < 8741.15, -40875.1, -2340.82> ),
			CreateClusterSpawn( < -10589.3, -21332, -3136.08 >, < 0, -4.18293, 0 > ),
			CreateClusterSpawn( < 30619.5, -24045.3, -3696.72 >, < 0, -98.5453, 0 > ),
		]
	]

}


array < array<ClusterSpawnData> > function GetTickCluster_KingsCanyon()
{
	return [
		//NE
		[
			CreateClusterSpawn( < 4855.5, 25752.7, 4900.03 >, < 0, 137.039, 0 > ),
			CreateClusterSpawn( < 16239, 15991.4, 4706.2 >, < 0, -88.5292, 0 > ),
			CreateClusterSpawn( < 24797.3, 28592.8, 4670.03 >, < 0, 14.8268, 0 > ),
			CreateClusterSpawn( < 23520.1, 12356.9, 2545.97 >, < 0, -112.856, 0 > ),
			CreateClusterSpawn( < 27356.6, 6800.26, 2888.03 >, < 0, -88.9897, 0 > ),
			CreateClusterSpawn( < 35362.4, -746.504, 3497.08 >, < 0, -122.298, 0 > ),
			CreateClusterSpawn( < 36339.7, 24113.2, 3968.06 >, < 0, -176.124, 0 > ),
			CreateClusterSpawn( < 610.897, 36215.5, 5128.72 >, < 0, -0.607208, 0 > ),
			CreateClusterSpawn( < 15817.8, -2792.45, 3907.3 >, < 0, 67.1988, 0 > ),
		],

		//NW
		[
			CreateClusterSpawn( < 36339.7, 24113.2, 3968.06 >, < 0, -176.124, 0 > ),
			CreateClusterSpawn( < -30278.7, 10982.3, 3420.03 >, < 0, 4.42722, 0 > ),
			CreateClusterSpawn( < -27341.1, 23757.9, 1772.03 >, < 0, 70.7171, 0 > ),
			CreateClusterSpawn( < -10058.4, 22752.3, 2593.12 >, < 0, -4.83389, 0 > ),
			CreateClusterSpawn( < -17320.7, 5279.96, 2943.84 >, < 0, -24.9983, 0 > ),
			CreateClusterSpawn( < -17320.7, 5279.96, 2943.84 >, < 0, -24.9983, 0> ),
			CreateClusterSpawn( < 489.498, 11992.5, 2357.43 >, < 0, 67.145, 0 > ),
			CreateClusterSpawn( < -8012.44, 5499.09, 2408.03 >, < 0, -14.5632, 0 > ),
		],

		//S
		[
			CreateClusterSpawn( < 8132.77, -31026, 3440.03 >, < 0, -84.9033, 0 > ),
			CreateClusterSpawn( < 21996.4, -23183.1, 3856.28 >, < 0, -67.7262, 0 > ),
			CreateClusterSpawn( < 27584.1, -6023.55, 4188.06 >, < 0, -80.8208, 0 > ),
			CreateClusterSpawn( < 656.913, -15045.7, 3408.06 >, < 0, 15.0755, 0 > ),
			CreateClusterSpawn( < -20696.1, -13947.8, 3024.03 >, < 0, -43.7558, 0 > ),
			CreateClusterSpawn( < -24065.9, -1468.08, 2512.03 >, < 0, -176.648, 0 > ),
			CreateClusterSpawn( < -3593.68, -940.122, 2570.01 >, < 0, -70.2717, 0 > ),
		]
	]

}


array < array<ClusterSpawnData> > function GetTickCluster_Tropics()
{
	return [
		//NE
		[
			CreateClusterSpawn( < 26620.8, 40941.6, 10515.5 >, < 0, -61.4783, 0 > ),
			CreateClusterSpawn( < 23341, 28448.7, 12477 >, < 0, 54.4211, 0 > ),
			CreateClusterSpawn( < 44118.9, 22818.9, 9619.03 >, < 0, 55.9146, 0 > ),
			CreateClusterSpawn( < 26139.9, 13357.4, 6502.11 >, < 0, 76.6207, 0 > ),
			CreateClusterSpawn( < 17363, -6702.75, 280.149 >, < 0, 2.52511, 0 > ),
			CreateClusterSpawn( < -1561.11, -6282.34, 150.753 >, < 0, 99.5558, 0 > ),
			CreateClusterSpawn( < -24522.3, 9285.16, 113.408 >, < 0, 71.2951, 0 > ),
		],

		//NW
		[
			CreateClusterSpawn( < -15598.7, 2526.34, 1109.81 >, < 0, -73.3791, 0 > ),
			CreateClusterSpawn( < -5128.59, 9020.23, 353.692 >, < 0, -161.088, 0 > ),
			CreateClusterSpawn( < -35416.8, 21547.5, 280.596 >, < 0, -23.8752, 0 > ),
			CreateClusterSpawn( < -25608, 35769.9, 1504.66 >, < 0, -147.932, 0 > ),
			CreateClusterSpawn( < 7945.77, 39279.1, 4122.06 >, < 0, -18.8745, 0 > ),
			CreateClusterSpawn( < 7426.45, 16010, 3686.26 >, < 0, 110.241, 0 > ),
		],

		//S
		[
			CreateClusterSpawn( < 3681.98, -14041, 966.046 >, < 0, -160.064, 0 > ),
			CreateClusterSpawn( < 1681.54, -37240.2, 964.436 >, < 0, -78.9586, 0 > ),
			CreateClusterSpawn( < 29249.5, -24942.8, 1064.1 >, < 0, -86.5804, 0 > ),
			CreateClusterSpawn( < 28670.5, -12060.4, 26.1225 >, < 0, 170.101, 0 > ),
			CreateClusterSpawn( < -19412.5, -29534.8, 238.606 >, < 0, 3.03483, 0 > ),
			CreateClusterSpawn( < -33132, -21778.3, 151.819 >, < 0, -135.464, 0 > ),
			CreateClusterSpawn( < -23371.8, -6027.1, 328.031 >, < 0, -160.655, 0 > ),
		]
	]

}

array < array<ClusterSpawnData> > function GetTickCluster_Olympus()
{
	//SW
	return [
		[
			CreateClusterSpawn( < -19895, -27528.2, -4415.94> ),
			CreateClusterSpawn( < -30937.5, -16808.9, -3723.94> ),
			CreateClusterSpawn( < -42677.4, -12577.2, -3021.56> ),
			CreateClusterSpawn( < -34815.3, -822.365, -4093.91> ),
			CreateClusterSpawn( < -28116.6, -6083.03, -4129.59> ),
			CreateClusterSpawn( < -22088.9, 2296.63, -5137.59 > ),
		],

		//SE
		[
			CreateClusterSpawn( < 30267.6, 6192.28, -3454.68 > ),
			CreateClusterSpawn( < 24103.1, -5992.61, -4727.97 > ),
			CreateClusterSpawn( < 18853.3, -20175.5, -4790.16 > ),
			CreateClusterSpawn( < 9360.59, -29673, -5424.56 > ),
			CreateClusterSpawn( < -5512.9, -34676.2, -2338.86> ), //Doubles at bonsai plaza
			CreateClusterSpawn( < -5503.66, -30898.1, -2338.86 > ),
		],

		//N
		[
			CreateClusterSpawn( < -16606.4, 20997.4, -6720.52 > ),
			CreateClusterSpawn( < -17095, 38665.8, -6815.73 > ),
			CreateClusterSpawn( < -30184.7, 20511.5, -6511.97 > ),
			CreateClusterSpawn( < -32774.9, 12771.8, -6743.94> ),
			CreateClusterSpawn( < -4997.52, 28737, -5963.95 > ),
			CreateClusterSpawn( < 10155, 29249.9, -4641.76 > ),
		]
	]
}

array < array<ClusterSpawnData> > function GetTickCluster_DividedMoon()
{
	//SE
	return [
		[
			CreateClusterSpawn( < 29986.8, -10845.8, 4641.47> ),
			CreateClusterSpawn( < 33531.3, -1465.56, 3793.7> ),
			CreateClusterSpawn( < 15092.7, -11868.4, 6186.73> ),
			CreateClusterSpawn( < 1158.57, -24173.2, 5763.69> ),
			CreateClusterSpawn( < 12784.9, -34129.8, 6987.33> ),
			CreateClusterSpawn( < -8802.64, -22111.2, 2928.15> ),
		],

		//N
		[
			CreateClusterSpawn( < 22836.2, 7393.57, 1614.68> ),
			CreateClusterSpawn( < 9612.44, 8892.96, 1836.4> ),
			CreateClusterSpawn( < 892.897, 32374.7, 1156.26> ),
			CreateClusterSpawn( < 26878.3, 36814.6, 3655.44> ),
			CreateClusterSpawn( < -21499.9, 23021.4, 2161.52> ),
			CreateClusterSpawn( < -3026.85, 12027.7, 2023.13> ),
		]
		,
		//SW
		[
			CreateClusterSpawn( < -34922.1, 32730.8, 47.9316> ), //Doubles in Breaker Wharf
			CreateClusterSpawn( < -38196.4, 29458.4, 47.9321> ),
			CreateClusterSpawn( < -25742.6, 9436.57, 1648.65> ),
			CreateClusterSpawn( < -33839.6, -3588.93, 2759.81> ),
			CreateClusterSpawn( < -10829.3, -3210.59, 2035.6> ),
			CreateClusterSpawn( < -27445.8, -26690.2, 2615.99> ),
		]
	]
}
#endif


//SWORD CLUSTERS
#if SERVER
//19.1 is
//CLands HU
//Tropics MU2
//DLands HU
array < array<ClusterSpawnData> > function GetSwordClusterForMap()
{
	switch ( GetMapName() )
	{
		case "mp_rr_desertlands_hu":
			return GetSwordCluster_WorldsEdge()

		case "mp_rr_canyonlands_hu":
			thread SpawnSwordOnHovertank()
			return GetSwordCluster_KingsCanyon()

		case "mp_rr_tropic_island_mu2":
			return GetSwordCluster_Tropics()

		case "mp_rr_olympus_mu2":
			return GetSwordCluster_Olympus()

		case "mp_rr_divided_moon":
			return GetSwordCluster_DividedMoon()
	}

	return [[CreateClusterSpawn( < 0, 0, 0> )]]
}


array < array<ClusterSpawnData> > function GetSwordCluster_WorldsEdge()
{
	return [
		//NE
		[
			CreateClusterSpawn( < 9772.72, 5386.04, -3567.97 >, < 0, 68.219, 0 > ),
			CreateClusterSpawn( < 33714.1, 9413.79, -3524.94 >, < 0, 91.5245, 0 > ),
			CreateClusterSpawn( < 17038.2, 30541.3, -3918.33 >, < 0, 133.353, 0 > ), //Double climatizee
			CreateClusterSpawn( < 22492.4, 25094.4, -3918.33 >, < 0, 140.73, 0 > ),
			CreateClusterSpawn( < 15042.9, 11184.9, -3015.49 >, < 0, -57.3894, 0 > ),
			CreateClusterSpawn( < 4997.58, 24400.7, -3914.48 >, < 0, 144.041, 0 > ),
		],

		//NW
		[
			CreateClusterSpawn( < -13132.2, 26385.4, -2939.17 >, < 0, -19.9199, 0 > ),
			CreateClusterSpawn( < -23834.9, 23004.8, -1424.05 >, < 0, 89.4636, 0 > ),
			CreateClusterSpawn( < -27945.2, 7722.62, -3748.32 >, < 0, -142.475, 0 > ),
			CreateClusterSpawn( < -20301.5, -5797.02, -3007.05 >, < 0, 79.1328, 0 > ),
			CreateClusterSpawn( < -17790.7, -16353.8, -3139.05 >, < 0, -12.8221, 0 > ),
			CreateClusterSpawn( < -7752.69, -9189.68, -3375.36 >, < 0, 35.6283, 0 > ),
			CreateClusterSpawn( < -9530.49, 11304.8, -2495.92 >, < 0, -25.851, 0 > ),
		],

		//S
		[
			CreateClusterSpawn( < -9958.04, -26823.5, -2889.87 >, < 0, 86.6079, 0 > ),
			CreateClusterSpawn( < 6250.1, -22807.7, -2550.95 >, < 0, -45.7273, 0 > ),
			CreateClusterSpawn( < 19610.1, -37106.6, -2357.27 >, < 0, 177.137, 0 > ),
			CreateClusterSpawn( < 23858.3, -28015.9, -2519.97 >, < 0, 160.256, 0 > ),
			CreateClusterSpawn( < 24770.5, -10955.7, -3707.87 >, < 0, -128.481, 0 > ),
			CreateClusterSpawn( < 6659.17, -36780.8, -2492.25 >, < 0, -160.129, 0 > ),
		]
	]

}

array < array<ClusterSpawnData> > function GetSwordCluster_KingsCanyon()
{
	return [
		//NE
		[
			CreateClusterSpawn( < 14939, -1422.47, 5236.03 >, < 0, -94.1804, 0 > ),
			CreateClusterSpawn( < 27355.9, 6246.71, 2888.03 >, < 0, -179.701, 0 > ),
			CreateClusterSpawn( < 36181.9, 21895.6, 4160.06 >, < 0, 95.8702, 0 > ),
			CreateClusterSpawn( < 23147.5, 24957.5, 4766.09 >, < 0, 33.9683, 0 > ),
			CreateClusterSpawn( < 36640.8, 3575.4, 3043.19 >, < 0, -132.44, 0 > ),
			CreateClusterSpawn( < 18825.8, 10909.8, 4563.72 >, < 0, 107.439, 0 > ),
		],

		//NW
		[
			CreateClusterSpawn( < -18942.6, 18956.9, 3658.3 >, < 0, 174.526, 0 > ),
			CreateClusterSpawn( < -2104.53, 39345, 5128.37 >, < 0, 16.8362, 0 > ),
			CreateClusterSpawn( < 7409.9, 26167.7, 5866.03 >, < 0, -150.742, 0 > ),
			CreateClusterSpawn( < -1004.65, 19564, 4570.03 >, < 0, 24.585, 0 > ),
			CreateClusterSpawn( < 5412.24, 12403.2, 4395.8 >, < 0, -113.972, 0 > ),
			CreateClusterSpawn( < -4377.84, 7976.63, 3488.33 >, < 0, -26.2678, 0 > ),
		],

		//S
		[
			CreateClusterSpawn( < 7930.06, -29970.6, 3118.03 >, < 0, -3.73562, 0 > ),
			CreateClusterSpawn( < 12853.8, -18339, 4266.03 >, < 0, -130.009, 0 > ),
			CreateClusterSpawn( < -7633.6, -15375, 3614.66 >, < 0, 137.298, 0 > ),
			CreateClusterSpawn( < -17473.9, 365.224, 3295.15 >, < 0, 126.034, 0 > ),
			CreateClusterSpawn( < 20979.8, -13514.7, 4778.83 >, < 0, -130.11, 0 > ),
			CreateClusterSpawn( < 938.316, -10747.8, 3264.03 >, < 0, 96.0721, 0 > ),
		]
	]

}

void function SpawnSwordOnHovertank()
{
	//-9163.300, -23172.699, 3264.470
	//CreateClusterSpawn( < -9163.33, -23175.1, 3461.56 >, < 0, 175.975, 0 > )
	const vector offset = <0, 0, 197>

	if ( !GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_SWORD_HOVERTANK_ENABLED, true ) )
		return

	array<entity> hoverTanks = GetEntArrayByScriptName( "_hover_tank_mover" )
	if ( hoverTanks.len() == 0 )
		return

	foreach ( entity hoverTank in hoverTanks )
	{
		SpawnSword( hoverTank.GetOrigin() + offset, AnglesCompose( hoverTank.GetAngles(), <0, 65, 0> ) )
	}
}

array < array<ClusterSpawnData> > function GetSwordCluster_Tropics()
{
	return [
		//NE
		[
			CreateClusterSpawn( < 27275.1, -12174.9, 1520.66 >, < 0, -150.562, 0 > ),
			CreateClusterSpawn( < 35813.8, 34833, 10033.6 >, < 0, -172.192, 0 > ),
			CreateClusterSpawn( < 13890.2, 21055.2, 6004.09 >, < 0, -42, 0 > ),
			CreateClusterSpawn( < 27447.1, 40104.9, 10743.8 >, < 0, -3.30687, 0 > ),
			CreateClusterSpawn( < 25058.8, 9598.82, 6809.3 >, < 0, -15.2892, 0 > ),
			CreateClusterSpawn( < 13378.9, 10335, 4679.19 >, < 0, -42.6317, 0 > ),
		],

		//NW
		[
			CreateClusterSpawn( < -36527.2, 16119.5, 1131.71 >, < 0, 3.75804, 0 > ),
			CreateClusterSpawn( < -8869.55, 30841.9, 604.532 >, < 0, -178.759, 0 > ),
			CreateClusterSpawn( < -73.0957, 13118.8, 1626.69 >, < 0, 55.5506, 0 > ),
			CreateClusterSpawn( < -9484.1, -2238.66, 998.621 >, < 0, -122.153, 0 > ),
			CreateClusterSpawn( < -34864.6, 3639.98, 612.883 >, < 0, -100.301, 0 > ),

		],

		//S
		[
			CreateClusterSpawn( < 22985.4, -27941.3, 144.031 >, < 0, -157.359, 0 > ),
			CreateClusterSpawn( < 29029.4, -24587.6, 1050.29 >, < 0, -106.238, 0 > ),
			CreateClusterSpawn( < -11462.9, -31268.6, 28.8323 >, < 0, 102.936, 0 > ),
			CreateClusterSpawn( < -42095.2, -13471.2, 877.366 >, < 0, 36.712, 0 > ),
			CreateClusterSpawn( < 1640.89, -10132.3, 1180.44 >, < 0, -141.995, 0 > ),
			CreateClusterSpawn( < 4171.33, -25460.4, 1667.64 >, < 0, -44.1771, 0 > ),
		]
	]

}

array < array<ClusterSpawnData> > function GetSwordCluster_Olympus()
{
	//SW
	return [
		[
			CreateClusterSpawn( < -19895, -27528.2, -4415.94> ),
			CreateClusterSpawn( < -30937.5, -16808.9, -3723.94 > ),
			CreateClusterSpawn( < -42677.4, -12577.2, -3021.56 > ),
			CreateClusterSpawn( < -34815.3, -822.365, -4093.91 > ),
			CreateClusterSpawn( < -28116.6, -6083.03, -4129.59 > ),
			CreateClusterSpawn( < -22088.9, 2296.63, -5137.59 > ),
		],

		//SE
		[
			CreateClusterSpawn( < 30267.6, 6192.28, -3454.68 > ),
			CreateClusterSpawn( < 24103.1, -5992.61, -4727.97 > ),
			CreateClusterSpawn( < 18853.3, -20175.5, -4790.16 > ),
			CreateClusterSpawn( < 9360.59, -29673, -5424.56 > ),
			CreateClusterSpawn( < -5512.9, -34676.2, -2338.86 > ), //Doubles at bonsai plaza
			CreateClusterSpawn( < -5503.66, -30898.1, -2338.86 > ),
		],

		//N
		[
			CreateClusterSpawn( < -16606.4, 20997.4, -6720.52 > ),
			CreateClusterSpawn( < -17095, 38665.8, -6815.73 > ),
			CreateClusterSpawn( < -30184.7, 20511.5, -6511.97 > ),
			CreateClusterSpawn( < -32774.9, 12771.8, -6743.94 > ),
			CreateClusterSpawn( < -4997.52, 28737, -5963.95 > ),
			CreateClusterSpawn( < 10155, 29249.9, -4641.76 > ),
		]
	]
}

array < array<ClusterSpawnData> > function GetSwordCluster_DividedMoon()
{
	//SE
	return [
		[
			CreateClusterSpawn( < 29986.8, -10845.8, 4641.47 > ),
			CreateClusterSpawn( < 33531.3, -1465.56, 3793.7 > ),
			CreateClusterSpawn( < 15092.7, -11868.4, 6186.73 > ),
			CreateClusterSpawn( < 1158.57, -24173.2, 5763.69 > ),
			CreateClusterSpawn( < 12784.9, -34129.8, 6987.33 > ),
			CreateClusterSpawn( < -8802.64, -22111.2, 2928.15 > ),
		],

		//N
		[
			CreateClusterSpawn( <22836.2, 7393.57, 1614.68 > ),
			CreateClusterSpawn( <9612.44, 8892.96, 1836.4 > ),
			CreateClusterSpawn( <892.897, 32374.7, 1156.26> ),
			CreateClusterSpawn( <26878.3, 36814.6, 3655.44> ),
			CreateClusterSpawn( <-21499.9, 23021.4, 2161.52> ),
			CreateClusterSpawn( <-3026.85, 12027.7, 2023.13> ),
		]
		,
		//SW
		[
			CreateClusterSpawn( < -34922.1, 32730.8, 47.9316> ), //Doubles in Breaker Wharf
			CreateClusterSpawn( < -38196.4, 29458.4, 47.9321> ),
			CreateClusterSpawn( < -25742.6, 9436.57, 1648.65> ),
			CreateClusterSpawn( < -33839.6, -3588.93, 2759.81> ),
			CreateClusterSpawn( < -10829.3, -3210.59, 2035.6> ),
			CreateClusterSpawn( < -27445.8, -26690.2, 2615.99> ),
		]
	]
}
#endif


#if DEVELOPER
#if SERVER
const vector CROSSHAIR_OFFSET = <0, 0, -32>
void function DEV_SpawnGoldenHorseTick( entity player, bool usePlayerAngles = false )
{
	vector origin = GetPlayerCrosshairOrigin( player )
	origin += CROSSHAIR_OFFSET
	vector angles = usePlayerAngles? player.GetAngles() : <-1, -1, -1>
	SpawnTick( origin, angles )
	//printt( "<" + origin.x + ", " + origin.y + ", " + origin.z + ">" )
	printt( "CreateClusterSpawn( < " + origin.x + ", " + origin.y + ", " + origin.z + " >, < " + angles.x + ", " + angles.y + ", " + angles.z + " > )," )
}

void function DEV_SpawnTitanSword( entity player, bool usePlayerAngles = false )
{
	vector origin = GetPlayerCrosshairOrigin( player )
	origin += CROSSHAIR_OFFSET
	vector angles = usePlayerAngles? AnglesCompose( player.GetAngles(), <0, 90, 0> ) : <-1, -1, -1>
	SpawnSword( origin, angles )
	printt( "CreateClusterSpawn( < " + origin.x + ", " + origin.y + ", " + origin.z + " >, < " + angles.x + ", " + angles.y + ", " + angles.z + " > )," )
}
#endif
#endif

                          