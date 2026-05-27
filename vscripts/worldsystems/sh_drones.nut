/*
This is common script shared by different types of map drones.
These include drones like the Loot Drone that flies around with a loot roller or the Ad Drones flying around in Control Mode.
This script does NOT apply to Legend abilities like the Crypto Drone
The purpose of this script is to:
- support common Client/Script functions between drones
- Define Drone Data
- Handle Drone Client side states
- NOTE: Utility Drones have not been updated to use this script, they do not seem to be used anywhere

- When adding a new drone type, search addUniqueDroneLogicHere to see where you need to add logic
*/

global function ShDrones_Init
global function ShDrones_IsValidDrone
global function ShDrones_IsValidDroneMover
                    
                                                
      
global function ShDrones_DroneSpawned

                      
                                               
                                              
      

#if SERVER
global function Drones_ShouldSpawnLootDrones
global function Drones_ShouldSpawnAdDrones
                     
                                              
                                                  
      
                    
global function Drones_ShouldSpawnBlimpDrones
global function Drones_GetBlimpDronesCountToSpawn
      
                        
global function Drones_ShouldSpawnBroadcastDrones
global function Drones_GetBroadcastDronesCountToSpawn
      
#endif
#if CLIENT
global function ServerCallback_AddDroneClientData
global function ShDrones_GetDroneClientData
global function ServerCallback_SetDroneTrailFXType
global function ServerCallback_ClearDroneTrailFXType
global function ServerCallback_ClearAllDroneFX
global function ServerCallback_DestroyDroneScreenRUIs
#endif

global const string SIGNAL_DRONE_FALL_START = "signalDroneSpiral"
global const string SIGNAL_DRONE_STOP_PANIC = "droneStopPanicking"
global const string DEFAULT_DRONE_FX_ATTACH_NAME = "fx_center"

global const float DEFAULT_DRONE_HEALTH_MAX = 1.0
global const float DEFAULT_DRONE_FLIGHT_SPEED_MAX = 175.0
global const float DEFAULT_DRONE_FLIGHT_ACCEL = 100.0
global const float DEFAULT_DRONE_FLIGHT_SPEED_PANIC = 500.0
global const float DEFAULT_DRONE_PANIC_DURATION = 5.0
global const float DEFAULT_DRONE_FALLING_SPEED_MAX = 800.0
global const float DEFAULT_DRONE_FALLING_ACCEL = 300.0
global const float DEFAULT_DRONE_FALLING_GRAVITY = 350.0
global const float DEFAULT_DRONE_MIN_FALL_DIST_TO_SURFACE = 32.0
global const float DEFAULT_DRONE_ROLL = 45.0

#if SERVER
global const string DRONE_CALLBACK_ADD_CLIENT_DATA = "ServerCallback_AddDroneClientData"
global const string DRONE_CALLBACK_START_TRAIL_FX_TYPE = "ServerCallback_SetDroneTrailFXType"
global const string DRONE_CALLBACK_STOP_TRAIL_FX_TYPE = "ServerCallback_ClearDroneTrailFXType"
global const string DRONE_CALLBACK_DESTROY_DRONE_SCREEN_RUIS = "ServerCallback_DestroyDroneScreenRUIs"
#endif //SERVER

global enum eDroneType
{
	// addUniqueDroneLogicHere - new drone types need to be added here
	// BEFORE ADDING A NEW DRONE TYPE, CHECK IF YOU CAN USE A DEFAULT DRONE INSTEAD. It has lots of customizable fields
	// and is great for things like adding new drone models or vfx, adjusting drone movement, or changing drone loot.
	// Unless you are adding logic that none of our drones can currently do, it will probably serve your needs.
	INVALID,
	LOOT_DRONE,
	AD_DRONE,
                      
              
       
                     
                    
       
	                    
	BLIMP_DRONE,
       
	                        
	BROADCAST_DRONE,
       
                       
              
       
	_count
}

global enum eDroneTrailFXType
{
	TRAIL,
	PANIC,
	FALL,

	_count
}

global struct DroneData
{
	entity model
	entity mover
	entity rotator
	array<entity> path
                                            
               
       
	array<vector> pathVec
	entity roller
	entity soundEntity
	vector lastSafeRollerPosition
	float health 		= DEFAULT_DRONE_HEALTH_MAX
	bool __isDead
	float __speed
	float __accel 		= DEFAULT_DRONE_FLIGHT_ACCEL
	float __maxSpeed 	= DEFAULT_DRONE_FLIGHT_SPEED_MAX
	float __panicSpeed  = DEFAULT_DRONE_FLIGHT_SPEED_PANIC
	float __panicDuration = DEFAULT_DRONE_PANIC_DURATION
	float __fallingSpeedMax = DEFAULT_DRONE_FALLING_SPEED_MAX
	float __fallingAccel = DEFAULT_DRONE_FALLING_ACCEL

                       
                 
                        
                  
              
                  
                 
                     
                 
                   
                      
                     

                    

                            
       

	bool isPanicking
	float lastPanicTime = 0.0
	int droneType
}

#if CLIENT
global struct DroneRUIClientData
{
	var topology					= null
	var rui							= null
}

global struct DroneClientData
{
	entity model
	int droneType
	int trailFXHandle
	int panicFXHandle
	int fallFXHandle

	array<DroneRUIClientData> droneRUIs
}
#endif

struct
{
	#if CLIENT
		table<entity, DroneClientData> droneToClientData
	#endif
} file

void function ShDrones_Init()
{
	AddCallback_EntitiesDidLoad( ShDrones_EntitiesDidLoad )

                     
                                                 
   
                        
   
      

	                    
		ShBlimpDrones_Init()
       
	
	ShAdDrones_Init()

	#if SERVER
		// leaving this here in case drones get spawned outside of the drone scripts.
		// However, the script name of the model is tested in ShDrones_DroneSpawned and it is not set at the time of this callback.
		// This function is fired off at the end of the function that creates the drones through script in their create functions.
		AddSpawnCallback( "prop_dynamic", ShDrones_DroneSpawned )
		AddCallback_GameStateEnter( eGameState.Playing, ShDrones_OnGameStatePlaying )
	#endif
	#if CLIENT
		AddCreateCallback( "prop_dynamic", ShDrones_DroneSpawned )
		AddCreateCallback( "prop_dynamic", ShDrones_DroneRollerSpawned )
		RegisterSignal( "StopAdDroneVFX" )
	#endif
}

void function ShDrones_EntitiesDidLoad()
{
	// addUniqueDroneLogicHere - trigger the init for each drone type here if any exist on the map. Only init the drones you need
	if ( Drones_ShouldSpawnLootDrones() )
	{
		ShLootDrones_EntitiesDidLoad()
	}
                    
                                                                   
  
                                
  
      

	if ( Drones_ShouldSpawnAdDrones() )
	{
		ShAdDrones_EntitiesDidLoad()
	}

                     
                                        
  
                                  
  
      

                      
           
                                          
   
                                  
   
      
   
                                
   
       
      

                    
	if ( Drones_ShouldSpawnBlimpDrones() )
	{
		ShBlimpDrones_EntitiesDidLoad()
	}
      

                        
	if ( Drones_ShouldSpawnBroadcastDrones() )
	{
		ShBroadcastDrones_EntitiesDidLoad()
	}
      

#if SERVER
	Drones_InitDronePaths()

                       
                                          
   
                                     
   
       

	thread Drones_SpawnDrones_Thread( Drones_GetLootDronesCountToSpawn(), eDroneType.LOOT_DRONE )
#endif // SERVER
}

#if SERVER
void function ShDrones_OnGameStatePlaying()
{
	// addUniqueDroneLogicHere - spawn drones here or on load if we are using the drone type
	if ( Drones_ShouldSpawnAdDrones() )
	{
		// Ad Drones need to start once the player is in game so the billboards can appear properly
		thread Drones_SpawnDrones_Thread( Drones_GetAdDronesCountToSpawn(), eDroneType.AD_DRONE )
	}

                     
                                        
  
                                                                                                         
  
      

                    
	if ( Drones_ShouldSpawnBlimpDrones() )
	{
		thread Drones_SpawnDrones_Thread( Drones_GetBlimpDronesCountToSpawn(), eDroneType.BLIMP_DRONE )
	}
      

                        
	if ( Drones_ShouldSpawnBroadcastDrones() )
	{
		thread Drones_SpawnDrones_Thread( Drones_GetBroadcastDronesCountToSpawn(), eDroneType.BROADCAST_DRONE )
	}
      
}
#endif // SERVER


#if SERVER || CLIENT
// addUniqueDroneLogicHere - add the playlist var control for the drone if you plan to have that
int function Drones_GetAdDronesCountToSpawn()
{
	return GetCurrentPlaylistVarInt( "ad_drones_spawn_count", 0 )
}

int function Drones_GetLootDronesCountToSpawn()
{
	return GetCurrentPlaylistVarInt( "loot_drones_spawn_count", 0 )
}

                      
                                             
 
                                                                    
 
      

                     
                                                 
 
                                                                  
 
      

                    
int function Drones_GetBlimpDronesCountToSpawn()
{
	return GetCurrentPlaylistVarInt( "blimp_drones_spawn_count", 0 )
}
      

                        
int function Drones_GetBroadcastDronesCountToSpawn()
{
	return GetCurrentPlaylistVarInt( "broadcast_drones_spawn_count", 0 )
}
      

// addUniqueDroneLogicHere - add the logic that checks whether the drone type should be used on the map. Must be called after entites load
bool function Drones_ShouldSpawnAdDrones()
{
                       
                                                                                                                          
              
       

	return Drones_GetAdDronesCountToSpawn() > 0
}

bool function Drones_ShouldSpawnLootDrones()
{
	return Drones_GetLootDronesCountToSpawn() > 0
}

                      
                                               
 
                                            
 
      

                     
                                              
 
                                                   
                                                                                                              
                                                       
 
      

                    
bool function Drones_ShouldSpawnBlimpDrones()
{
	return Drones_GetBlimpDronesCountToSpawn() > 0
}
      

                        
bool function Drones_ShouldSpawnBroadcastDrones()
{
	return Drones_GetBroadcastDronesCountToSpawn() > 0
}
      
#endif // SERVER || CLIENT

void function ShDrones_DroneSpawned( entity droneEnt )
{
	int droneType = GetDroneTypeFromDroneEntity( droneEnt )

	if ( droneType == eDroneType.INVALID )
		return

	#if CLIENT
		printf( "DroneClientDebug: Adding Drone to Client Data" )
		AddDroneClientData( droneEnt )
	#endif //CLIENT

	#if SERVER
		DroneData data = Drones_GetDroneDataFromDroneModelEnt( droneEnt )
		if ( droneType == eDroneType.AD_DRONE )
		{
			if ( IsValid( data.roller ) && data.roller.GetScriptName().tolower() == AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME.tolower() )
			{
				entity projectorModel = data.roller
				AdDrones_SetBillboardForProjectorModel( projectorModel )
			}
		}
                       
                                                  
   
                                                                                                                    
    
                                                          
    
   
        
	#endif //SERVER
}

#if CLIENT
void function ShDrones_DroneRollerSpawned( entity rollerEnt )
{
	// We ensure trail vfx play on the drone model in AddDroneClientData triggered by ShDrones_DroneSpawned
	// Ad Drone Billboard vfx are tied to the roller model, so we use this callback to trigger the vfx on those
	if ( IsValid( rollerEnt ) && rollerEnt.GetScriptName() == AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME )
		thread AdDrones_PlayBillboardVFXOnAdDrone_Thread( rollerEnt )
}
#endif //CLIENT

int function GetDroneTypeFromDroneEntity( entity droneEnt )
{
	// addUniqueDroneLogicHere - Need to support checks that will return the correct drone type for each new drone type
	int droneType = eDroneType.INVALID
	if ( droneEnt.GetModelName().tolower() == LOOT_DRONE_MODEL.tolower() && droneEnt.GetScriptName().tolower() == LOOT_DRONE_MODEL_SCRIPTNAME.tolower() )
	{
		droneType = eDroneType.LOOT_DRONE
	}
	else if ( droneEnt.GetModelName().tolower() == AD_DRONE_MODEL.tolower() && droneEnt.GetScriptName().tolower() == AD_DRONE_MODEL_SCRIPTNAME.tolower() )
	{
		droneType = eDroneType.AD_DRONE
	}
                       
                                                                  
  
                                      
  
       
                     
                                                                                                                                                                   
  
                                           
  
       
                      
                                                                                                                                                               
  
                                     
  
       
	                    
	else if ( droneEnt.GetModelName().tolower() == BLIMP_DRONE_MODEL.tolower() && droneEnt.GetScriptName().tolower() == BLIMP_DRONE_MODEL_SCRIPTNAME.tolower() )
	{
		droneType = eDroneType.BLIMP_DRONE
	}
       
	                        
	else if ( droneEnt.GetModelName().tolower() == BROADCAST_DRONE_MODEL.tolower() && droneEnt.GetScriptName().tolower() == BROADCAST_DRONE_MODEL_SCRIPTNAME.tolower() )
	{
		droneType = eDroneType.BROADCAST_DRONE
	}
       

	return droneType
}

int function GetDroneTypeFromDroneMover( entity droneEnt )
{
	// addUniqueDroneLogicHere - Need to support checks that will return the correct drone type for each new drone type
	int droneType = eDroneType.INVALID
	string scriptName = droneEnt.GetScriptName()
	if ( ( scriptName == LOOT_DRONE_MOVER_SCRIPTNAME ) || ( scriptName == LOOT_DRONE_ROTATOR_SCRIPTNAME ) )
	{
		droneType = eDroneType.LOOT_DRONE
	}
	else if ( ( scriptName == AD_DRONE_MOVER_SCRIPTNAME ) || ( scriptName == AD_DRONE_ROTATOR_SCRIPTNAME ) )
	{
		droneType = eDroneType.AD_DRONE
	}
                       
                                                                  
  
                                      
  
       
                     
                                                                                                                             
  
                                           
  
       
                      
                                                                                                                 
  
                                     
  
       
	                    
	else if ( ( scriptName == BLIMP_DRONE_MOVER_SCRIPTNAME ) || ( scriptName == BLIMP_DRONE_ROTATOR_SCRIPTNAME ) )
	{
		droneType = eDroneType.BLIMP_DRONE
	}
       
	                        
	else if ( ( scriptName == BROADCAST_DRONE_MOVER_SCRIPTNAME ) || ( scriptName == BROADCAST_DRONE_ROTATOR_SCRIPTNAME ) )
	{
		droneType = eDroneType.BROADCAST_DRONE
	}
       

	return droneType
}

#if CLIENT
void function ServerCallback_AddDroneClientData( entity droneEnt )
{
	printf( "DroneClientDebug: ServerCallback_AddDroneClientData" )
	AddDroneClientData( droneEnt )
}
#endif //CLIENT

#if CLIENT
void function AddDroneClientData( entity droneEnt )
{
	int droneType = GetDroneTypeFromDroneEntity( droneEnt )
	if ( droneType == eDroneType.INVALID )
	{
		printf( "DroneClientDebug: DroneType is the INVALID type, will not setup client data for it" )
		return
	}

	if ( droneEnt in file.droneToClientData )
		return

	printf( "DroneClientDebug: Adding Clientside Drone Data entry for a Drone of Type: " + GetEnumString( "eDroneType", droneType ) )
	DroneClientData clientData
	clientData.droneType = droneType
	clientData.model = droneEnt
	SetDroneTrailFX( clientData )

	                    
		if ( droneType == eDroneType.BLIMP_DRONE )
		{
			BlimpDrones_InitializeDroneLighting( clientData )
			BlimpDrones_InitializeDroneRUIs( clientData )
		}
                           

	file.droneToClientData[ droneEnt ] <- clientData
}
#endif //CLIENT

#if CLIENT
DroneClientData function ShDrones_GetDroneClientData( entity droneEnt )
{
	Assert( ShDrones_IsValidDrone( droneEnt ), "Requested Drone client data from invalid entity!" )
	Assert( (droneEnt in file.droneToClientData), "Requested entity not part of Drone client table!" )

	return file.droneToClientData[ droneEnt ]
}
#endif //CLIENT

#if CLIENT
void function SetDroneTrailFX( DroneClientData droneData )
{
	int droneType = droneData.droneType

	// addUniqueDroneLogicHere - Need to get the expected trail fx for each unique drone type
	switch ( droneType )
	{
                      
                                     
        
		case eDroneType.LOOT_DRONE:
			SetLootDroneTrailFX( droneData )
			break

		case eDroneType.AD_DRONE:
			AdDrones_SetAdDroneTrailFX( droneData )
			break

                       
                               
                                     
        
        

		                        
		case eDroneType.BROADCAST_DRONE:
			BroadcastDrones_SetBroadcastDroneTrailFX( droneData )
			break
        
                        
                                
                                              
        
        

		default:
			break
	}
}
#endif //CLIENT

#if CLIENT
void function ServerCallback_SetDroneTrailFXType( entity droneEnt, int trailType )
{
	printf( "DroneClientDebug: ServerCallback_SetDroneTrailFXType" )
	if ( !ShDrones_IsValidDrone( droneEnt ) )
		return

	DroneClientData clientData = ShDrones_GetDroneClientData( droneEnt )
	// addUniqueDroneLogicHere - Need to set the correct vfx for each unique drone type here
	switch( clientData.droneType )
	{
                      
                                     
        
		case eDroneType.LOOT_DRONE:
			SetLootDroneTrailFXType( droneEnt, trailType )
			break

		case eDroneType.AD_DRONE:
			AdDrones_SetAdDroneTrailFXType( droneEnt, trailType )
			break

                       
                               
                                                   
        
        

		                        
		case eDroneType.BROADCAST_DRONE:
			BroadcastDrones_SetBroadcastDroneTrailFXType( droneEnt, trailType )
			break
        
                        
                                
                                                           
        
        

		default:
			break
	}
}
#endif //CLIENT

#if CLIENT
void function ServerCallback_ClearDroneTrailFXType( entity droneEnt, int trailType )
{
	printf( "DroneClientDebug: ServerCallback_ClearDroneTrailFXType" )

	if ( !ShDrones_IsValidDrone( droneEnt ) )
		return

	int fxHandle
	DroneClientData clientData = ShDrones_GetDroneClientData( droneEnt )
	switch( trailType )
	{
		case eDroneTrailFXType.TRAIL:
			fxHandle = clientData.trailFXHandle
			break
		case eDroneTrailFXType.PANIC:
			fxHandle = clientData.panicFXHandle
			break
		case eDroneTrailFXType.FALL:
			fxHandle = clientData.fallFXHandle
			break
	}

	if ( !EffectDoesExist( fxHandle ) )
		return

	EffectStop( fxHandle, false, true )
}
#endif //CLIENT

#if CLIENT
void function ServerCallback_ClearAllDroneFX( entity droneEnt )
{
	printf( "DroneClientDebug: ServerCallback_ClearAllDroneFX" )
	DroneClientData clientData = ShDrones_GetDroneClientData( droneEnt )
	if ( EffectDoesExist( clientData.trailFXHandle ) )
		EffectStop( clientData.trailFXHandle, false, true )
	if ( EffectDoesExist( clientData.panicFXHandle ) )
		EffectStop( clientData.panicFXHandle, false, true )
	if ( EffectDoesExist( clientData.fallFXHandle ) )
		EffectStop( clientData.fallFXHandle, false, true )
}
#endif //CLIENT

#if CLIENT
void function ServerCallback_DestroyDroneScreenRUIs( entity droneEnt )
{
	printf( "DroneClientDebug: ServerCallback_DestroyDroneScreenRUIs" )

	if ( !ShDrones_IsValidDrone( droneEnt ) )
		return

	DroneClientData clientData = ShDrones_GetDroneClientData( droneEnt )
	                    
		if ( clientData.droneType == eDroneType.BLIMP_DRONE )
		{
			BlimpDrones_DestroyDroneRUIs( clientData )
		}
                           
}
#endif

bool function ShDrones_IsValidDrone( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	bool isValidDrone = false

	if ( GetDroneTypeFromDroneEntity( ent ) != eDroneType.INVALID )
		isValidDrone = true

	return isValidDrone
}

bool function ShDrones_IsValidDroneMover( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	bool isValidDroneMover = false

	if ( GetDroneTypeFromDroneMover( ent ) != eDroneType.INVALID )
		isValidDroneMover = true

	return isValidDroneMover
}

                    
                                                            
 
                       
              

                               

                                                                          
                          

                         
 
      