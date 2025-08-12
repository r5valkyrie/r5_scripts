//RealisticMode 																			//mkos
//Just a regular Flowstate gamemode with some tweaks & extra features

global function RealisticMode_Init
global function RealisticMode_GivePlayerBonusHeals
global function RealisticMode_GetBestSpawnPointFFA

#if DEVELOPER
	global function DEV_PrintTrackedDoors
#endif 

const vector TTV_BUILDING_ORIGIN = < 9864.35, 5497.93, -3567.97 >
const float TTV_BUILDING_RADIUS = 4500.0
const float DOOR_RESPAWN_PLAYER_RADIUS_LIMIT = 130.0
const float DOOR_REGEN_GRACE = 60
const int HIGH_PLAYER_COUNT_THRESHOLD = 15

const array<string> STANDARD_REALISTIC_KILL_LOOT = 
[
	"health_pickup_combo_small", 
	"health_pickup_combo_small", 
	"health_pickup_combo_large",
	"health_pickup_health_large",
	"mp_weapon_grenade_emp"
]

const array<string> STANDARD_SPAWN_LOOT = 
[
	"health_pickup_combo_small", //1
	"health_pickup_combo_small", //2
	"health_pickup_health_small", //3
	"health_pickup_health_small", //4
	"mp_weapon_grenade_emp", //5
	"optic_cq_hcog_classic", //6
	"optic_cq_hcog_bruiser", //7
	"optic_cq_holosight", //8
	"optic_ranged_hcog", //9
	"optic_ranged_aog_variable" //10
]

struct DoorDataStruct
{
    entity door
    vector origin
    vector angles
    asset model
    string scriptName
	float lastDestroyTime
}

struct 
{
	array< SpawnData > gamemodeSpawns = []
	array< DoorDataStruct > trackedDoors
	
	int iTrackedDoors = 0

} file 

void function RealisticMode_Init()
{
	RegisterSignal( "PlayerSkyDive" )
	
	AddCallback_EntitiesDidLoad( InitializeDoorTracking )
	AddCallback_OnPlayerWeaponAttachmentChanged( Realistic_OnWeaponAttachmentChanged )
	AddCallback_OnPlayerRespawned( RealisticMode_OnSpawned )

	Flowstate_SpawnSystem_InitGamemodeOptions()
	
	int eMap = SpawnSystem_FindBaseMapForPak( MapName() )
	file.gamemodeSpawns = SpawnSystem_ReturnAllSpawnLocations( eMap )
	
	mAssert( file.gamemodeSpawns.len() > 0, "No valid spawns configured" )
	
	#if DEVELOPER
		printw( file.gamemodeSpawns.len(), "Realistic TTV Spawns loaded for ", AllMapsArray()[ eMap ] )
	#endif
	
	if ( !FlowState_AdminTgive() )
		INIT_WeaponsMenu()
	else 
		INIT_WeaponsMenu_Disabled()
}

void function UpdateDestroyTime( entity door )
{
	foreach( DoorDataStruct data in file.trackedDoors )
	{
		if( data.door == door )
		{
			printt( "UpdateDestroyTime() Found door, setting destroy time to:", Time() )
			int dataIndex = file.trackedDoors.find( data )
			
			if( dataIndex > -1 )
				file.trackedDoors[ dataIndex ].lastDestroyTime = Time()
			
			break
		}
	}
}

bool function InTrackedDoors( entity door )
{
	foreach( data in file.trackedDoors )
	{
		if( data.door == door )
			return true
	}
	
	return false
}

void function RunDoorMonitor( entity door )
{
	#if DEVELOPER
		//printw( "Checking to run door monitor" )
	#endif 
	
	if( InTrackedDoors( door ) )
	{
		//printt( " --- SUCCESS --- : running monitor" )
		thread RunDoorMonitor_Thread( door )
		file.iTrackedDoors++
	}
	else
	{
		//printt( "ERROR. Door is not in tracked doors." )
	}
}

#if DEVELOPER
	void function DEV_PrintTrackedDoors()
	{
		printt( file.iTrackedDoors )
	}
#endif

void function RunDoorMonitor_Thread( entity door )
{
	if( !IsValid( door ) ) //threaded off 
		return
		
	svGlobal.levelEnt.EndSignal( "GameEnd" )
	door.EndSignal( "OnDestroy" )
	
	OnThreadEnd
	(
		void function() : ( door )
		{
			if( InTrackedDoors( door ) )
			{
				UpdateDestroyTime( door )
				file.iTrackedDoors--
			}
			#if DEVELOPER
			else
				printt( "Not in tracked doors?", door )
			#endif
		}
	)
	
	#if DEVELOPER
		//printt( "Waiting for destroy" )
	#endif 
	
	WaitForever()
}

void function CollectAllDoors()
{
    foreach ( door in GetAllPropDoors() )
    {
        if ( !IsValid( door ) )
            continue
								
		float distance = Distance2D( door.GetOrigin(), TTV_BUILDING_ORIGIN )
        if ( distance > TTV_BUILDING_RADIUS )
        {
			#if DEVELOPER
				//printt( "Skipping door outside radius" )
			#endif 
			
            continue
        }
		
        DoorDataStruct doorData
		
        doorData.door = door
        doorData.origin = door.GetOrigin()
        doorData.angles = door.GetAngles()
        doorData.model = door.GetModelName()
        doorData.scriptName = door.GetScriptName()

        file.trackedDoors.append( doorData )
		RunDoorMonitor( door )
		
        #if DEVELOPER
			//printt( "adding door at:", doorData.origin )
		#endif
    }
	
	#if DEVELOPER
		printw( "Total Doors Added:", file.trackedDoors.len() )
		printw( "Total doors tracked:", file.iTrackedDoors )
	#endif
}

void function RespawnDoor( DoorDataStruct doorData )
{
    if ( IsValid( doorData.door ) )
        return
	
	if( Time() - doorData.lastDestroyTime < DOOR_REGEN_GRACE ) 
		return
		
	#if DEVELOPER
		Warning( "Spawning visual debug sphere at", VectorToString( doorData.origin ) )
		DebugDrawSphere( doorData.origin, DOOR_RESPAWN_PLAYER_RADIUS_LIMIT, 255, 0, 0, true, 5.0 )
	#endif 
	
	array<entity> nearbyEntities = ArrayEntSphere( doorData.origin, DOOR_RESPAWN_PLAYER_RADIUS_LIMIT )
	
	bool bNearbyPlayerFound = false
	foreach ( entity ent in nearbyEntities )
	{
		if ( ent.IsPlayer() )
		{
			bNearbyPlayerFound = true 
			break
		}
	}
			
	if( bNearbyPlayerFound )
		return

    entity newDoor = CreateEntity( "prop_door" )
    
	newDoor.SetOrigin( doorData.origin )
    newDoor.SetAngles( doorData.angles )
    newDoor.SetModel( doorData.model )
    newDoor.SetScriptName( doorData.scriptName )

    DispatchSpawn( newDoor )
    doorData.door = newDoor

	RunDoorMonitor( newDoor )
	
    #if DEVELOPER
		//printt("Respawned door at:", doorData.origin, "with model:", doorData.model);
    #endif
}

void function DoorRespawn_Thread()
{
    for( ; ; )
    {
        foreach ( doorData in file.trackedDoors )
            RespawnDoor( doorData )

        wait 5
    }
}

void function InitializeDoorTracking()
{
    CollectAllDoors()
    thread DoorRespawn_Thread()
}

void function RealisticMode_GivePlayerBonusHeals( entity player, bool spawn = false )
{
	if( !spawn )
	{
		foreach( ref in STANDARD_REALISTIC_KILL_LOOT )
			SURVIVAL_AddToPlayerInventory( player, ref, 1 )
	}
	else 
	{
		foreach( ref in STANDARD_SPAWN_LOOT )
			SURVIVAL_AddToPlayerInventory( player, ref, 1 )
	}
}

void function Realistic_OnWeaponAttachmentChanged( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if( !CheckRate( player, false, 0.05 ) )
		return
		
	//(mk):only intended for realistic ttv mode 		
	ClientCommand_SaveCurrentWeapons( player, [] )
}

void function RealisticMode_OnSpawned( entity player )
{
	thread
	(
		void function() : ( player )
		{
			wait 3 //todo, unweave fsdm logic
			
			if( !IsValid( player ) )
				return
			
			player.TakeOffhandWeapon( OFFHAND_SLOT_FOR_CONSUMABLES )
			player.GiveOffhandWeapon( CONSUMABLE_WEAPON_NAME, OFFHAND_SLOT_FOR_CONSUMABLES, [] )
			player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
			player.TakeOffhandWeapon( OFFHAND_MELEE )
			player.GiveWeapon( "mp_weapon_melee_survival", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )
			player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE, [] )	

			RealisticMode_GivePlayerBonusHeals( player, true )	
		}
	)()
}

//taken from fsdm, same function
LocPair function RealisticMode_GetBestSpawnPointFFA()
{	
	table<LocPair, float> SpawnsAndNearestEnemy = {}
	bool bHighVolume = GetPlayerArray_Alive().len() > HIGH_PLAYER_COUNT_THRESHOLD

	foreach( SpawnData dataSpawn in file.gamemodeSpawns )
    {
		if( !bHighVolume && dataSpawn.info == "overfill" )
			continue
	
		array<float> AllPlayersDistancesForThisSpawnPoint
		
		foreach( player in GetPlayerArray_Alive() )
			AllPlayersDistancesForThisSpawnPoint.append( Distance( player.GetOrigin(), dataSpawn.spawn.origin ) )
		AllPlayersDistancesForThisSpawnPoint.sort()
		SpawnsAndNearestEnemy[ dataSpawn.spawn ] <- AllPlayersDistancesForThisSpawnPoint[0] //grab nearest player distance for each spawn point
	}

	LocPair finalLoc
	float compareDis = -1
	foreach( loc, dis in SpawnsAndNearestEnemy ) //calculate the best spawn point which is the one with the furthest enemy of the nearest
	{
		if( dis > compareDis )
		{
			finalLoc = loc
			compareDis = dis
		}
	}
	
    return finalLoc
}

void function INIT_WeaponsMenu()
{
	AddClientCommandCallback( "CC_MenuGiveAimTrainerWeapon", CC_MenuGiveAimTrainerWeapon ) 
	AddClientCommandCallback( "CC_AimTrainer_SelectWeaponSlot", CC_AimTrainer_SelectWeaponSlot )
	AddClientCommandCallback( "CC_AimTrainer_WeaponSelectorClose", CC_AimTrainer_CloseWeaponSelector )
}

void function INIT_WeaponsMenu_Disabled()
{
	AddClientCommandCallback( "CC_MenuGiveAimTrainerWeapon", MessagePlayer_Disabled ) 
	AddClientCommandCallback( "CC_AimTrainer_SelectWeaponSlot", MessagePlayer_Disabled )
	AddClientCommandCallback( "CC_AimTrainer_WeaponSelectorClose", MessagePlayer_Disabled )
}

bool function MessagePlayer_Disabled( entity player, array<string> args )
{
	LocalEventMsg( player, "#FS_DisabledTDMWeps" )
	return true
}