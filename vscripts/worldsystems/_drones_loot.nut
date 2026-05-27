global function InitLootDrones
global function EntitiesDidLoadLootDrones

global function LootDrones_DetachLootRollerAndCleanUpData
global function LootDrones_ReleaseLootRoller
global function LootDrones_GetTrainNodesArray

global function LootDrones_CreateLootDrone
global function LootDrones_DestroyAllLootDrones
global function LootDrones_LootDroneKilled
global function LootDrones_ExplodeLootDrone
global function LootDrones_DroneFallSequence

global function LootDrones_OnLootRollerPostDamaged
global function LootDrones_OnLootRollerKilled
global function LootDrones_OnLootDroneDestroyed

                    
                                                      
                                                 
                                                 
      

const string LOOT_DRONE_PHYSPROP_SCRIPT_NAME = "loot_drone_dead_dummy" // dswieczko don't see this used anywhere


struct
{
	array<entity> initOnly_lootDroneNodes
	array<entity> initOnly_lootDroneTrainNodes
} file

void function InitLootDrones()
{
	Assert( !Flag( "EntitiesDidLoad" ), "Warning! You need to call InitLootDrones() before entities loaded!" )
	AddSpawnCallback_ScriptName( LOOT_DRONE_NODE_SCRIPT_NAME, OnLootDroneNodeSpawned )
}

void function EntitiesDidLoadLootDrones()
{
	PrecacheScriptString( LOOT_DRONE_MODEL_SCRIPTNAME )
	PrecacheScriptString( LOOT_DRONE_ROTATOR_SCRIPTNAME )
                    
                                                            
                                                              
      
}

void function OnLootDroneNodeSpawned( entity node )
{
	string nodeType = node.GetClassName()
	switch ( nodeType )
	{
		case "info_target":
			AddNodeToInfoTargetArray( node )
			break
		case DRONE_TRACK_NODE_CLASS_NAME:
			AddNodeToTrainNodeArray( node )
			break
	}
}

void function AddNodeToInfoTargetArray( entity node )
{
	if ( !file.initOnly_lootDroneNodes.contains( node ) )
		file.initOnly_lootDroneNodes.append( node )
}

void function AddNodeToTrainNodeArray( entity node )
{
	if ( !file.initOnly_lootDroneTrainNodes.contains( node ) )
		file.initOnly_lootDroneTrainNodes.append( node )
}

array<entity> function LootDrones_GetTrainNodesArray()
{
	return file.initOnly_lootDroneTrainNodes
}

void function LootDrones_OnLootRollerKilled( entity rollerModel, var damageInfo )
{
	LootRollerData rollerData = GetLootRollerDataFromRollerModel( rollerModel )

	entity parentEnt = rollerData.lootRollerModel.GetParent()

	if( Drones_IsValidDroneOrDroneMover( parentEnt ) )
	{
		DroneData ornull droneData = Drones_GetDroneDataFromRollerModelEnt( rollerModel )
		if ( droneData != null )
		{
			expect DroneData( droneData )
			LootDrones_DetachLootRollerAndCleanUpData( rollerData, droneData, false )
		}
	}
}

void function LootDrones_OnLootRollerPostDamaged( entity rollerModel, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	LootRollerData rollerData = GetLootRollerDataFromRollerModel( rollerModel )

	entity rollerParent = rollerData.lootRollerModel.GetParent()
	string rollerParentScriptName = rollerParent.GetScriptName()

	if ( !Drones_IsValidDroneOrDroneMover( rollerParent ) )
		return

	DroneData ornull droneData = Drones_GetDroneDataFromRollerModelEnt( rollerModel )
	if ( droneData != null )
	{
		expect DroneData( droneData )
		if ( rollerParent != droneData.mover )
			return

		entity attacker = DamageInfo_GetAttacker( damageInfo )

		if ( !IsValid( attacker ) )
			return

		Drones_ManagePanic( droneData )
	}
}

void function LootDrones_DetachLootRollerAndCleanUpData( LootRollerData rollerData, DroneData droneData, bool rollerIsAlive )
{
	if ( IsValid( droneData.roller ) )
	{
		RemoveCallback_LootRollerKilled( droneData.roller, LootDrones_OnLootRollerKilled )
		RemoveCallback_LootRollerDamaged( droneData.roller, LootDrones_OnLootRollerPostDamaged )
		droneData.roller = null
	}

	//droneData.roller = null
	thread HACK_Drones_DroneDisappear( droneData )

	if ( rollerIsAlive )
	{
		rollerData.timeOfRelease = Time()
		entity lootRoller = rollerData.lootRollerModel
		lootRoller.ClearParent()
		lootRoller.Signal( "ParentDroneDestroyed" )
		HACK_AwakenLootRoller( rollerData )
		StartLootRollerNotificationSounds( rollerData )
	}
}

void function LootDrones_LootDroneKilled( entity lootDroneModel, var damageInfo )
{
	Drones_DroneKilled( lootDroneModel, damageInfo, LOOT_DRONE_DEATH_SOUND, LOOT_DRONE_CRASHING_SOUND, LOOT_DRONE_DAMAGE_VO )
}

                    
                                                                                        
 
                                                                                                        
 
      

void function LootDrones_ExplodeLootDrone( DroneData droneData )
{
	// Ensure this is the last function you run in this function, once this runs it will destory the drone model making future validity checks invalid
	Drones_ExplodeDrone( droneData, LOOT_DRONE_CRASHING_SOUND, LOOT_DRONE_CRASHED_SOUND, LOOT_DRONE_FX_EXPLOSION )
}

void function LootDrones_DroneFallSequence( DroneData droneData, var damageInfo )
{
	thread Drones_DroneFallSequence_Thread( droneData, damageInfo, LOOT_DRONE_FX_FALL_EXPLOSION, LOOT_DRONE_FALLING_GRAVITY, LOOT_DRONE_MIN_FALL_DIST_TO_SURFACE )
}

const float LOOT_ROLLER_ATTACH_Z_OFFSET = -46
DroneData function LootDrones_CreateLootDrone( vector origin, vector angles )
{
	DroneData data
	entity droneModel = CreatePropDynamic( LOOT_DRONE_MODEL, origin, angles, 6 )
	droneModel.SetScriptName( LOOT_DRONE_MODEL_SCRIPTNAME )
	string scriptName = droneModel.GetScriptName()

	droneModel.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	droneModel.kv.contents = (int(droneModel.kv.contents) | CONTENTS_BLOCK_PING )
	droneModel.Code_SetTeam( TEAM_TICK )
	droneModel.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE ) //Hack to make IsAlive() return true
	droneModel.SetMaxHealth( LOOT_DRONE_HEALTH_MAX )
	droneModel.SetHealth( LOOT_DRONE_HEALTH_MAX )
	droneModel.SetTouchTriggers( true )
	droneModel.Highlight_Enable()
	//droneModel.EnableEntScopeHighlight()

	entity mover = CreateScriptMover( LOOT_DRONE_MOVER_SCRIPTNAME, origin, angles )
	mover.DisallowZiplines()

	//entity rotator = CreateScriptMover( origin, angles )
	//rotator.SetScriptName( LOOT_DRONE_ROTATOR_SCRIPTNAME )
	//rotator.DisallowZiplines()

	droneModel.SetParent( mover )
	//rotator.SetParent( mover )
	data.model = droneModel
	//data.rotator = rotator
	data.mover = mover
	data.health = LOOT_DRONE_HEALTH_MAX
	data.__accel = LOOT_DRONE_FLIGHT_ACCEL
	data.__maxSpeed = LOOT_DRONE_FLIGHT_SPEED_MAX
	data.__panicSpeed = LOOT_DRONE_FLIGHT_SPEED_PANIC
	data.__panicDuration = LOOT_DRONE_PANIC_DURATION
	data.__fallingSpeedMax = LOOT_DRONE_FALLING_SPEED_MAX
	data.__fallingAccel = LOOT_DRONE_FALLING_ACCEL
	data.droneType = eDroneType.LOOT_DRONE

	vector lootRollerOrg = droneModel.GetOrigin() + < 0, 0, LOOT_ROLLER_ATTACH_Z_OFFSET >
	LootRollerData rollerData = LootRollers_CreateLootRoller( lootRollerOrg, droneModel.GetAngles() )
	rollerData.lootRollerModel.SetParent( mover )
	rollerData.lootDrone = droneModel
	data.roller = rollerData.lootRollerModel

	AddCallback_LootRollerDamaged( rollerData, LootDrones_OnLootRollerPostDamaged )
	AddCallback_LootRollerKilled( rollerData, LootDrones_OnLootRollerKilled )
	AddEntityCallback_OnPostDamaged( droneModel, Drones_OnDronePostDamaged )
	AddEntityDestroyedCallback( droneModel, LootDrones_OnLootDroneDestroyed )

	MarkEntForCleanupOnRoundEnd( droneModel )

	entity soundEntity = CreateEntity( "ambient_generic" )
	soundEntity.SetOrigin( droneModel.GetOrigin() )
	soundEntity.SetSoundName( LOOT_DRONE_LIVING_SOUND )
	soundEntity.SetParent( droneModel )
	soundEntity.SetEnabled( true )
	data.soundEntity = soundEntity

	AddSonarDetectionForPropScript( data.model )
	AddEMPDamageDevice( data.model )

	Drones_GetAllActiveDrones().append( data )
	ShDrones_DroneSpawned( data.model )

	return data
}

                    
                                                                                                                                  
 
                                                                                          

               

                                                                             
                                                                
                                               

                                                                   
                                                                              
                                           
                                                                                                                  
                                       
                                    
                                    
                              
                                     

                                                                                        
                         

                                                       
                                                                 
                             

                              
                             
                        
                         
                   
                                 
                                       
                                              
                                                  
                                                 
                                                      
                                               
                                               

                                                                                      

                                                                                                                                          

                                              
                                  
                                         

                                                                            
                                                                      
                                                                         
                                                                         

                                          

                                                         
                                                  
                                                      
                                      
                                 
                                 
                                                             
                                                                                                                                   
                                                                           
                               

                                             
                                 

                                           
                                    

            
 
      

                    
                                                                                  
 
                                                  
                   
        

                                                                            

                                                             
                                                               

                                                                                  

                         
  
                               
                                        
         

                                                                               
  
 
      

                    
                                                                            
 
                                                  
                   
        

                                            
        

                                                                         

                                                                              
 
      

                    
                                                                             
 
                                                                            

                                                                                  
                         
  
                               

                                                   
  
 
      

void function LootDrones_ReleaseLootRoller( DroneData droneData )
{
	if ( !IsValid( droneData.roller ) )
		return

	LootRollerData rollerData = GetLootRollerDataFromRollerModel( droneData.roller )
	rollerData.lootRollerModel.ClearParent()
	rollerData.lootRollerModel.SetOrigin( droneData.lastSafeRollerPosition )
	HACK_AwakenLootRoller( rollerData )
	StartLootRollerNotificationSounds( rollerData )

	vector randTossDir = RandomVecInDomeWithFOV( droneData.model.GetUpVector(), 45 )
	vector flatRandTossDir = FlattenVec( randTossDir )
	randTossDir = Normalize( randTossDir)
	flatRandTossDir = Normalize( flatRandTossDir)

	randTossDir = ( randTossDir * 0.5 ) + ( flatRandTossDir * 0.5 )
	randTossDir *= RandomFloatRange( LOOT_DRONE_RAND_TOSS_MIN, LOOT_DRONE_RAND_TOSS_MAX )

	droneData.roller.SetVelocity( droneData.roller.GetVelocity() + randTossDir )
}

void function LootDrones_OnLootDroneDestroyed( entity droneModel )
{
	if ( ShDrones_IsValidDrone( droneModel ) )
		Drones_DestroyDrone( Drones_GetDroneDataFromDroneModelEnt( droneModel ) )
}

void function LootDrones_DestroyAllLootDrones()
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( data.droneType == eDroneType.LOOT_DRONE )
			Drones_DestroyDrone( data )
	}
}

                    
                                                      
 
                                                          
  
                                                        
                              
  
 
      
 