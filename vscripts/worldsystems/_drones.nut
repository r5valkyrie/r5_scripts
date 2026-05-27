/*
This is common script shared by different types of map drones.
These include drones like the Loot Drone that flies around with a loot roller or the Ad Drones flying around in Control Mode.
This script does NOT apply to Legend abilities like the Crypto Drone
The purpose of this script is to:
- Init the right type of drone for the map/mode
- Handle the different drone signals and states
- Get the drones pathing
- NOTE: Utility Drones have not been updated to use this script, they do not seem to be used anywhere

- When adding a new drone type, search addUniqueDroneLogicHere to see where you need to add logic
*/

global function Drones_InitDrones

global function Drones_SpawnDrones_Thread
                      
                                                
      
                     
                                               
       
                                      
      
      
global function Drones_InitDronePaths

global function Drones_DestroyAllDrones
global function Drones_IsDroneAlive
global function Drones_DebugDrawAllSafeDronePaths
global function Drones_ManagePanic
global function Drones_OnDronePostDamaged
global function Drones_GetDroneDataFromDroneModelEnt
global function Drones_GetDroneDataFromDroneProjectorEnt
global function Drones_IsDroneValid //DSwieczko doesn't seem to be used anywhere
global function Drones_IsValidDroneOrDroneMover
global function HACK_Drones_DroneDisappear
global function Drones_ExplodeDrone
global function Drones_DestroyDrone
global function Drones_GetAllActiveDrones
global function Drones_GetDroneDataFromRollerModelEnt
global function Drones_DroneKilled
global function Drones_DroneFallSequence_Thread

#if DEV
global function DEV_Drones_StopAllDrones
const string SIGNAL_DRONE_STOP = "signalDroneStop"
#endif // DEV

global const string DRONE_TRACK_NODE_CLASS_NAME = "script_mover_train_node"


struct
{
	// addUniqueDroneLogicHere - Need to add an array containing the paths used by the new drone type
	array< array<entity> > lootDronePaths
	array< array<entity> > adDronePaths
                      
                                                    
      
                    
	array< array<entity> > blimpDronePaths
      
                        
	array< array<entity> > broadcastDronePaths
      
                     
                                   
      
	array< DroneData > activeDrones

	bool drawDroneLocations = false
} file

void function Drones_InitDrones()
{
	Assert( !Flag( "EntitiesDidLoad" ), "Warning! You need to call Drones_InitDrones() before entities loaded!" )
	InitLootDrones()
	InitAdDrones()

                    
	InitBlimpDrones()
      

                        
	InitBroadcastDrones()
      

                     
                   
      

                      
                     
      

	RegisterSignal( SIGNAL_DRONE_FALL_START )
	RegisterSignal( SIGNAL_DRONE_STOP_PANIC )

	#if DEV
		RegisterSignal( SIGNAL_DRONE_STOP )
	#endif // DEV

	AddCallback_EntitiesDidLoad( Drones_EntitiesDidLoad )
}

void function Drones_EntitiesDidLoad()
{
	if ( Drones_ShouldSpawnLootDrones() )
	{
		EntitiesDidLoadLootDrones()
	}
                    
                                                                   
  
                             
  
      

	if ( Drones_ShouldSpawnAdDrones() )
	{
		EntitiesDidLoadAdDrones()
	}

                     
                                        
  
                               
  
      

                    
	if ( Drones_ShouldSpawnBlimpDrones() )
	{
		EntitiesDidLoadBlimpDrones()
	}
      

                        
	if ( Drones_ShouldSpawnBroadcastDrones() )
	{
		EntitiesDidLoadBroadcastDrones()
	}
      
}

array <array<entity> > function GetAllDronePathsInCircle( array< array<entity> > dronePathsArray )
{
	int numPaths = dronePathsArray.len()
	array< array<entity> > validPaths
	int debug_numChecks

	for ( int i; i < numPaths; i++ )
	{
		int numNodesInPath = dronePathsArray[i].len()
		bool pathValid = true
		for( int j; j < numNodesInPath; j++ )
		{
			debug_numChecks++
			if ( !SURVIVAL_PosInsideDeathField( Survival_Loot_GetDefaultRealm(), dronePathsArray[i][j].GetOrigin() ))
			{
				pathValid = false
				break
			}
		}

		if ( pathValid )
			validPaths.append( dronePathsArray[i] )
	}

	return validPaths
}

void function Drone_FollowPath_Thread( DroneData droneData, array< entity > dronePath, entity startingPoint, float droneRoll )
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity mover = droneData.mover
	EndSignal( mover, "OnDestroy" )
	EndSignal( mover, SIGNAL_DRONE_FALL_START )
	EndSignal( droneData.model, "OnDestroy" )
	#if DEV
		EndSignal( mover, SIGNAL_DRONE_STOP )
	#endif // DEV

	droneData.path = dronePath
	foreach( node in dronePath )
	{
		droneData.pathVec.append( node.GetOrigin() )
	}

	mover.Train_MoveToTrainNode( startingPoint, droneData.__maxSpeed, droneData.__accel )
	mover.Train_AutoRoll( 100.0, droneRoll, 1024.0 )

	OnThreadEnd(
		function() : ( mover )
		{
			if( mover.Train_IsMovingToTrainNode() )
				mover.Train_StopImmediately()
		}
	)

	//Drone_RotatorThread( droneData )

	float targetSpeed = mover.Train_GetLastSpeed()
	float dronePanicSpeed = droneData.__panicSpeed
	float droneMaxSpeed = droneData.__maxSpeed
	float droneAccel = droneData.__accel


	while ( true )
	{
		float maxSpeed = droneData.isPanicking ? dronePanicSpeed : droneMaxSpeed

		if ( targetSpeed != maxSpeed )
		{
			mover.Train_MoveToTrainNodeEx( mover.Train_GetLastNode(), mover.Train_GetLastDistance(), mover.Train_GetLastSpeed(), maxSpeed, droneAccel )
			targetSpeed = maxSpeed
		}

		droneData.__speed = mover.Train_GetLastSpeed()

		if ( file.drawDroneLocations )
		{
			//DebugDrawArrow( droneData.model.GetOrigin() + < 0, 0, 1000 >, droneData.model.GetOrigin(), 35, COLOR_WHITE, true, 0.1 )
		}
		WaitFrame()
	}
}

                                           
                                
                                                                                                   
 
                                                

                               
                                
                                            
                                          
        
                                       
              

                               

                                               
                                           
                                     

                                                                       

                                

                                        
                                                       

               
  
                            
                                                                            
                                                           
   
                                        
                                        
                                       
                                       

                                                                             
                                       
                                       

                                                                                                                               

                                                                                 

                                                           
                                                                                            
   

                                                                          

                                                                                                    
   
                                                            
    
                                         
                                         
                                        
                                        

                                                                              
                                        
                                        
    

                                                                            
                       

                                                           
                                                                                                                                                                  
   

             
  
 


                                                                                                                                   
 
                                                                                                                                           
                                            

                       
                          
  
                      
                                
                                                                     
        
      
                     
                               
                                                                            
        
      
  

              

                                                 
  
                                                                                                                                     
                           
   
                      
                                 
                                                                      
         
      
                     
                                
                                                                             
         
      
   
         
  

                                                                   
  
                                         
                                           
  
                                                                                                                                                          
  
                                         
                                             
  
 


                                                                              
 
                                             
                                             
                                             

                            
 

       
                                                                      
 
                                                     
 
      
      

                      
                                                                             
 
                                            
                                                                     

                                           
              

            
            

                                                       
  
                          
                       
  
     
  
                                     
                                     
  

                                                                                                                                    
                                
              

            
 
      

                     
                                                                             
 
                                        
                                                                     

                                           
              

                                                                                                          
                                                                                                         
                                                                                                             
                                                                                                             

                                                                                             
                                     
  
                                                                                     
                              
               
  

            
 
      

const float DRONE_BANK_UPDATE_TIME = 0.2
const float DRONE_MAX_TURN_ANGLE_BANK = 45.0
const float DRONE_MAX_TURN_ANGLE_BANK_PANIC = 60.0
const float DRONE_LOOK_AHEAD_DIST = 1024.0
const bool DRONE_DEBUG_BANK_YAW_VECTORS = false
// This function is not actually used anywhere but leaving in for reference
void function Drone_RotatorThread( DroneData droneData )
{
	entity mover = droneData.mover
	entity rotator = droneData.rotator
	entity model = droneData.model

	EndSignal( mover, "OnDestroy" )
	EndSignal( mover, SIGNAL_DRONE_FALL_START )
	EndSignal( model, "OnDestroy" )
	EndSignal( model, "OnDeath" )
	EndSignal( rotator, "OnDestroy" )

	float pathLength = GetPathLength( droneData.pathVec )
	float goalDistanceAlongPath
	vector goalAngles
	float currentBank
	while( true )
	{
		vector currentPos     = mover.GetOrigin()
		vector moverForward   = mover.GetForwardVector()
		vector moverToForward = currentPos + moverForward
		vector forwardVec     = FlattenNormalizeVec( moverToForward - currentPos )
		entity lastNodeEnt    = mover.Train_GetLastNode()
		float lastNodeDist    = lastNodeEnt.GetTotalSmoothDistance()
		entity nextNodeEnt    = lastNodeEnt.GetNextTrainNode()
		float moverDistOnPath = mover.Train_GetLastDistance()
		float remainingDist   = lastNodeDist - moverDistOnPath
		float lookAheadDist   = moverDistOnPath + DRONE_LOOK_AHEAD_DIST
		vector lookAheadPos
		if ( DRONE_LOOK_AHEAD_DIST > remainingDist )
			lookAheadPos = nextNodeEnt.GetSmoothPositionAtDistance( DRONE_LOOK_AHEAD_DIST - remainingDist )
		else
			lookAheadPos = lastNodeEnt.GetSmoothPositionAtDistance( lookAheadDist )
		vector fwdToLookAhead = FlattenNormalizeVec( lookAheadPos - currentPos )

		#if DEV
			if ( DRONE_DEBUG_BANK_YAW_VECTORS )
			{
				//DebugDrawLine( currentPos, (currentPos + forwardVec), COLOR_WHITE, true, DRONE_BANK_UPDATE_TIME )
				//DebugDrawLine( currentPos, (currentPos + fwdToLookAhead), COLOR_RED, true, DRONE_BANK_UPDATE_TIME )

				//DebugDrawSphere( (currentPos + forwardVec), 8.0, COLOR_WHITE, true, DRONE_BANK_UPDATE_TIME )
				//DebugDrawSphere( lookAheadPos, 8.0, COLOR_RED, true, DRONE_BANK_UPDATE_TIME )

				//DebugDrawSphere( lastNodeEnt.GetOrigin(), 16.0, COLOR_BLUE, true, (DRONE_BANK_UPDATE_TIME * 2) )
				//DebugDrawSphere( nextNodeEnt.GetOrigin(), 16.0, COLOR_GREEN, true, (DRONE_BANK_UPDATE_TIME * 2) )
			}
		#endif

		float fwdDot            = DotProduct( forwardVec, fwdToLookAhead )
		float yawAngle          = acos( fwdDot ) * 180 / PI

		vector left             = Normalize( CrossProduct( moverForward, <0,0,1> ) )
		float leftDot           = DotProduct( left, fwdToLookAhead )
		if ( leftDot > 0 )
			yawAngle *= -1


		float maxBank = droneData.isPanicking ? DRONE_MAX_TURN_ANGLE_BANK_PANIC : DRONE_MAX_TURN_ANGLE_BANK
		float bankAmount = GraphCapped( yawAngle, -maxBank, maxBank, -maxBank, maxBank )

		goalAngles = RotateAnglesAboutAxis( rotator.GetAngles(), forwardVec, bankAmount )

		goalAngles.x = mover.GetAngles().x
		goalAngles.y = mover.GetAngles().y
		goalAngles.z = GraphCapped( goalAngles.z, -maxBank, maxBank, -maxBank, maxBank )
		//goalAngles.z = GraphCapped( fwdDot, 0.15, 0.975, goalAngles.z, mover.GetAngles().z )
		float lerpPercent = pow( fwdDot, 2 ) //sin( fwdDot * PI * 0.5 )
		goalAngles.z = LerpFloat( goalAngles.z, mover.GetAngles().z, lerpPercent )

		#if DEV
			if ( DRONE_DEBUG_BANK_YAW_VECTORS )
			{
				//DebugDrawLine( currentPos, (currentPos + forwardVec), COLOR_WHITE, true, DRONE_BANK_UPDATE_TIME )
				//DebugDrawLine( currentPos, (currentPos + fwdToLookAhead), COLOR_RED, true, DRONE_BANK_UPDATE_TIME )

				//DebugDrawSphere( (currentPos + forwardVec), 8.0, COLOR_WHITE, true, DRONE_BANK_UPDATE_TIME )
				//DebugDrawSphere( lookAheadPos, 8.0, COLOR_RED, true, DRONE_BANK_UPDATE_TIME )

				//DebugDrawSphere( lastNodeEnt.GetOrigin(), 16.0, COLOR_BLUE, true, (DRONE_BANK_UPDATE_TIME * 2) )
				//DebugDrawSphere( nextNodeEnt.GetOrigin(), 16.0, COLOR_GREEN, true, (DRONE_BANK_UPDATE_TIME * 2) )

				printf( "LootDroneDebug: fwdDot = %f, yawAngle = %f, bankAmount = %f, goalAngles.z = %f", fwdDot, yawAngle, bankAmount, goalAngles.z )
			}
		#endif

		rotator.NonPhysicsRotateTo( goalAngles, DRONE_BANK_UPDATE_TIME * 2.0, 0.0, 0.0 )

		wait DRONE_BANK_UPDATE_TIME
	}
}

float function Drones_GetDroneSpeed( DroneData droneData )
{
	return max( droneData.__speed, 0.01 )
}

void function Drones_ManagePanic( DroneData droneData )
{
	// printf( "DroneDebug: My roller took damage! I'M PANICKING" )
	droneData.lastPanicTime = Time()

	if ( !droneData.isPanicking )
		thread Drones_ManagePanic_Thread( droneData )
}

void function Drones_ManagePanic_Thread( DroneData droneData )
{
	EndSignal( droneData.mover, "OnDestroy" )
	EndSignal( droneData.model, "OnDestroy" )
	EndSignal( droneData.model, "OnDeath" )
	EndSignal( droneData.model, SIGNAL_DRONE_STOP_PANIC )

	array<entity> playerArray = GetPlayerArray()
	foreach ( player in playerArray )
		Remote_CallFunction_Replay( player, DRONE_CALLBACK_START_TRAIL_FX_TYPE, droneData.model, eDroneTrailFXType.PANIC )

	droneData.isPanicking = true

	OnThreadEnd(
		function () : ( droneData )
		{
			array<entity> playerArray = GetPlayerArray()
			foreach ( player in playerArray )
				Remote_CallFunction_Replay( player, DRONE_CALLBACK_STOP_TRAIL_FX_TYPE, droneData.model, eDroneTrailFXType.PANIC )
		}
	)

	while ( true )
	{
		float currentTime = Time()
		float deltaTime = currentTime - droneData.lastPanicTime

		if ( deltaTime >= droneData.__panicDuration )
		{
			droneData.lastPanicTime = Time()
			droneData.isPanicking = false
			Signal( droneData.model, SIGNAL_DRONE_STOP_PANIC )
		}

		WaitFrame()
	}
}

void function Drones_OnDronePostDamaged( entity droneModel, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	if ( !ShDrones_IsValidDrone( droneModel ) )
		return

	DroneData data = Drones_GetDroneDataFromDroneModelEnt( droneModel )
                       
                            
         
       

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) || !attacker.IsPlayer() )
		return

	// Show damage numbers when attacked
	if ( IsAlive( attacker ) )
		attacker.NotifyDidDamage( droneModel, DamageInfo_GetHitBox( damageInfo ),
			DamageInfo_GetDamagePosition( damageInfo ),
			DamageInfo_GetCustomDamageType( damageInfo ),
			damage,
			DamageInfo_GetDamageFlags( damageInfo ),
			DamageInfo_GetHitGroup( damageInfo ),
			DamageInfo_GetWeapon( damageInfo ),
			DamageInfo_GetDistFromAttackOrigin( damageInfo ) )

	bool isActiveDrone
	foreach ( DroneData droneData in Drones_GetAllActiveDrones() )
	{
		if ( droneData.model == droneModel )
			isActiveDrone = true
	}
	if ( !isActiveDrone )
		return

	float newHealth = data.health - damage
	if ( newHealth <= 0 && !data.__isDead )
	{
		if ( IsValid( attacker ) && attacker.IsPlayer() )
		{
			// addUniqueDroneLogicHere - setup unique drones with unique destruction PIN data if required otherwise Loot Drone will be used
			int itemDestructionType
			switch( data.droneType )
			{
				case eDroneType.LOOT_DRONE:
					itemDestructionType = ITEM_DESTRUCTION_TYPES.LOOT_DRONE
					break
                         
                                 
                                                              
          
          
				default:
					itemDestructionType = ITEM_DESTRUCTION_TYPES.LOOT_DRONE
					break
			}

			PIN_PlayerItemDestruction( attacker, itemDestructionType )
		}

		// addUniqueDroneLogicHere - trigger the drone killed function for this specific drone type
		switch( data.droneType )
		{
			case eDroneType.LOOT_DRONE:
				LootDrones_LootDroneKilled( droneModel, damageInfo )
				break

			case eDroneType.AD_DRONE:
				AdDrones_AdDroneKilled( droneModel, damageInfo )
				break

                         
                                 
                                                       
         
         

                        
                                
                                                            
         
         

                       
                                      
                                                               
         
         

			default:
				printf( "DroneDebug: Should be running a drone specific killed function but this drone type is not setup: " + data.droneType )
				break
		}
	}

	if ( newHealth > 0 )
		data.health -= damage
}

const float DRONE_DISAPPEAR_WAIT_TIME = 15.0
const float DRONE_DELAY_BEFORE_DSTRUCTION = 1.0
void function HACK_Drones_DroneDisappear( DroneData droneData, float delay = DRONE_DISAPPEAR_WAIT_TIME )
{
	if ( delay > 0 )
	{
		wait delay
	}
	if ( Drones_IsDroneAlive( droneData ) )
	{
		MarkDroneAsDead( droneData )
		droneData.model.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )

		wait DRONE_DELAY_BEFORE_DSTRUCTION

		Drones_DestroyDrone( droneData )
	}
}

void function Drones_ExplodeDrone( DroneData droneData, string crashingSFX, string crashedSFX, asset explosionVFX, int damageDef = damagedef_loot_drone_explosion )
{
	if ( IsValid( droneData.roller ) )
	{
		string rollerScriptName = droneData.roller.GetScriptName().tolower()
		// addUniqueDroneLogicHere - If you are storing a model or attachment as droneData.roller handle what happens to it when the drone explodes

                      
                                                             
   
                                                                                   

                                             
    
                                            
                                         
                                               
                           
    
   
      
        
		{
			switch( rollerScriptName )
			{
				case LOOT_ROLLER_SCRIPTNAME.tolower():
					LootDrones_ReleaseLootRoller( droneData )
					break

				case AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME.tolower():
					AdDrones_DestroyBillboardProjector( droneData )
					break

				default:
					break
			}
		}

	}

	if ( IsValid( droneData.soundEntity ) )
	{
		droneData.soundEntity.SetEnabled( false )
	}

	StopSoundOnEntity( droneData.model, crashingSFX )
	EmitSoundAtPosition( TEAM_UNASSIGNED, droneData.model.GetOrigin(), crashedSFX , droneData.model )//"defensivebombardment_explosions_generic" )

	int fxId = GetParticleSystemIndex( explosionVFX )
	entity fx = StartParticleEffectInWorld_ReturnEntity( fxId, droneData.model.GetOrigin(), <0,0,0> )
	thread DestroyAfterDelay( fx, 5.0 )

	vector damageOrigin = droneData.model.GetOrigin()
	Explosion_DamageDefSimple( damageDef, damageOrigin, droneData.model, droneData.model, damageOrigin )
	entity shake = CreateShake( damageOrigin, 5, 150, 1, 512 )
	shake.kv.spawnflags = 4 // SF_SHAKE_INAIR

	Drones_DestroyDrone( droneData )
}

void function Drones_DestroyDrone( DroneData droneData )
{
	if ( !Drones_GetAllActiveDrones().contains( droneData ) )
		return

	Drones_GetAllActiveDrones().fastremovebyvalue( droneData )

	if ( IsValid( droneData.roller ) && droneData.roller.GetScriptName().tolower() == LOOT_ROLLER_SCRIPTNAME.tolower() )
	{
		switch ( droneData.droneType )
		{
                    
                                      
      
                      
                                 
      
			case eDroneType.LOOT_DRONE:
				LootRollerData rollerData = GetLootRollerDataFromRollerModel( droneData.roller )
				LootDrones_DetachLootRollerAndCleanUpData( rollerData, droneData, true )
				break

			default:
				printf( "DroneDebug: Should be damaging a drone but no logic setup for drone of type: " + droneData.droneType )
				break
		}

	}

	array<entity> playerArray = GetPlayerArray()
	foreach ( player in playerArray )
	{
		Remote_CallFunction_Replay( player, DRONE_CALLBACK_DESTROY_DRONE_SCREEN_RUIS, droneData.model )
	}

	if ( IsValid( droneData.model ) )
		droneData.model.Destroy()
	if ( IsValid( droneData.mover ) )
		droneData.mover.Destroy()

	// This function gets interupted by the endsignal in Drones_DroneFallSequence_Thread as soon as the droneData.mover is destroyed.
	// There shouldn't be any script after this
	return
}

void function Drones_DroneKilled( entity droneModel, var damageInfo, string deathSFX, string crashingSFX, string reactionVO = "" )
{
	DroneData data = Drones_GetDroneDataFromDroneModelEnt( droneModel )
	data.__isDead = true

	EmitSoundAtPosition( TEAM_UNASSIGNED, data.model.GetOrigin(), deathSFX , data.model )
	EmitSoundOnEntity( data.model, crashingSFX )
	if ( IsValid( data.soundEntity ) )
	{
		data.soundEntity.SetEnabled( false )
	}

	array<entity> playerArray = GetPlayerArray()
	foreach ( player in playerArray )
	{
		Remote_CallFunction_Replay( player, DRONE_CALLBACK_STOP_TRAIL_FX_TYPE, data.model, eDroneTrailFXType.TRAIL )
		Remote_CallFunction_Replay( player, DRONE_CALLBACK_STOP_TRAIL_FX_TYPE, data.model, eDroneTrailFXType.PANIC )
	}

	if ( reactionVO != "" )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )
		thread PlayBattleChatterLineDelayedToSpeakerAndTeam( attacker, reactionVO, 0.75 )
	}

	// addUniqueDroneLogicHere - trigger the correct fall sequence for your drone here
	switch( data.droneType )
	{
                      
                                     
                                      
        
        
		case eDroneType.LOOT_DRONE:
			LootDrones_DroneFallSequence( data, damageInfo )
			break
                        
                                
                                                      
        
        

		case eDroneType.AD_DRONE:
			AdDrones_DroneFallSequence( data, damageInfo )
			break

                       
                               
                                                     
        
        

		default:
			printf( "DroneDebug: Should be running a drone fall sequence function but this drone type is not setup: " + data.droneType )
			break
	}

	entity lootRoller = data.roller

	if ( !IsValid( lootRoller ) || lootRoller.GetScriptName().tolower() != LOOT_ROLLER_SCRIPTNAME.tolower() )
		return

	switch( data.droneType )
	{
                    
                                     
        
      
                      
                                
      
		case eDroneType.LOOT_DRONE:
			LootRollerData rollerData = GetLootRollerDataFromRollerModel( lootRoller )
			LootDrones_DetachLootRollerAndCleanUpData( rollerData, data, true )
			break

		default:
			printf( "DroneDebug: Should be damaging a drone but no logic setup for drone of type: " + data.droneType )
			break
	}
}

const float DRONE_FALL_SEQUENCE_TICK = 0.099
void function Drones_DroneFallSequence_Thread( DroneData droneData, var damageInfo, asset fallingExplosionVFX, float fallingGravity = DEFAULT_DRONE_FALLING_GRAVITY, float minFallDistToSurface = DEFAULT_DRONE_MIN_FALL_DIST_TO_SURFACE )
{
	Assert( IsNewThread(), "Must be threaded off" )

	EndSignal( droneData.mover, "OnDestroy" )

	Signal( droneData.mover, SIGNAL_DRONE_FALL_START )

	droneData.__maxSpeed = droneData.__fallingSpeedMax
	droneData.__accel = droneData.__fallingAccel

	array<entity> playerArray = GetPlayerArray()
	foreach ( player in playerArray )
		Remote_CallFunction_Replay( player, DRONE_CALLBACK_START_TRAIL_FX_TYPE, droneData.model, eDroneTrailFXType.FALL )

	int initExploFxId = GetParticleSystemIndex( fallingExplosionVFX )
	entity initExploFx = StartParticleEffectInWorld_ReturnEntity( initExploFxId, droneData.model.GetOrigin(), droneData.model.GetAngles() )

	float gravitySpeed = 0.0
	float gravityAmount = fallingGravity
	bool nextMoveCollides

	float damage = DamageInfo_GetDamage( damageInfo )
	entity droneMdl = droneData.model
	vector modelOrigin = droneMdl.GetOrigin()
	vector modelRight = droneMdl.GetRightVector()
	vector damageLoc = DamageInfo_GetDamagePosition( damageInfo )
	vector damageDirFlat = FlattenNormalizeVec( damageLoc - modelOrigin )

	float damageRightDot = DotProduct( modelRight, damageDirFlat )

	vector angles = droneData.mover.GetAngles()
	while ( true )
	{
		float droneSpeed = Drones_GetDroneSpeed( droneData )
		vector moverOrigin = droneData.mover.GetOrigin()
		vector flatForward = Normalize( FlattenVec( droneData.mover.GetForwardVector() ) )
		gravitySpeed += gravityAmount * DRONE_FALL_SEQUENCE_TICK
		float fallingSpeed = sqrt( ( droneSpeed * droneSpeed ) + ( gravitySpeed * gravitySpeed ) )

		// Target position for one second in the future. Mover will update before then, but all speed is in dist/sec
		vector fallInterval = ( flatForward * droneSpeed ) + < 0, 0, -gravitySpeed >
		vector fallDir = Normalize( fallInterval )

		// The collision test must check forward at least the length of the drone
		float colTestIntervalScalar = max( fallingSpeed * DRONE_FALL_SEQUENCE_TICK, minFallDistToSurface )
		vector colTestInterval = fallDir * colTestIntervalScalar
		vector colTestEndPos = moverOrigin + colTestInterval
		array< entity > ignoreEnts
		ignoreEnts.append( droneData.model )
		ignoreEnts.append( droneData.mover )
		if ( IsValid( droneData.roller ) )
			ignoreEnts.append( droneData.roller )

		TraceResults results = TraceLine( moverOrigin, colTestEndPos, ignoreEnts, TRACE_MASK_SOLID | TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

		// addUniqueDroneLogicHere - if your drone has a unique attachment you do not want it to collide with on death, add it here
		if ( results.fraction < 1 )
		{
			if ( results.hitEnt.GetScriptName() != LOOT_ROLLER_SCRIPTNAME )
				nextMoveCollides = true
		}

		// Move time is one second, since that's the fall interval time
		float fallTime = 1.0
		if ( nextMoveCollides )
		{
			// Make sure drone doesn't submerge into geo before detonating
			float distToCollision = Length( colTestInterval * results.fraction )
			float correctedFallDist = distToCollision - minFallDistToSurface

			// Drone should blow up now. Otherwise loot roller will get submerged
			if ( correctedFallDist <= 0 )
			{
				// addUniqueDroneLogicHere - trigger the explode drone function for this specific drone type
				switch ( droneData.droneType )
				{
					case eDroneType.LOOT_DRONE:
						LootDrones_ExplodeLootDrone( droneData )
						break

					case eDroneType.AD_DRONE:
						AdDrones_ExplodeAdDrone( droneData )
						break

                           
                                   
                                             
           
           

                          
                                  
                                                  
           
           

					default:
						printf( "DroneDebug: Should be running a drone specific explode function but this drone type is not setup: " + droneData.droneType )
						break
				}
				break
			}
			// Otherwise, shorten fall interval so drone doesn't submerge loot roller
			else
			{
				fallInterval = fallDir * correctedFallDist
				fallTime = correctedFallDist / fallingSpeed
			}
		}

		droneData.mover.NonPhysicsMoveTo( moverOrigin + fallInterval, fallTime, 0, 0 )

		vector rotateDir = droneData.mover.GetAngles() + <(-10 * damageRightDot * damage), 0, 1>
		droneData.mover.NonPhysicsRotate( rotateDir, 0.25 )

		wait DRONE_FALL_SEQUENCE_TICK

		angles = droneData.mover.GetAngles()

		if ( nextMoveCollides )
		{
			// addUniqueDroneLogicHere - trigger the explode drone function for this specific drone type
			switch ( droneData.droneType )
			{
                        
                                       
          
				case eDroneType.LOOT_DRONE:
					LootDrones_ExplodeLootDrone( droneData )
					break

				case eDroneType.AD_DRONE:
					AdDrones_ExplodeAdDrone( droneData )
					break

                          
                                  
                                            
          
          

                         
                                 
                                                 
          
          

				default:
					printf( "DroneDebug: Should be running a drone specific explode function but this drone type is not setup: " + droneData.droneType )
					break
			}
			break
		}

		vector lastSafePos = droneData.mover.GetOrigin()
		lastSafePos += fallDir * -32
		droneData.lastSafeRollerPosition = lastSafePos
	}

	foreach ( player in playerArray )
		Remote_CallFunction_Replay( player, DRONE_CALLBACK_STOP_TRAIL_FX_TYPE, droneData.model, eDroneTrailFXType.FALL )
}

DroneData function Drones_GetDroneDataFromDroneModelEnt( entity droneModel )
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( droneModel == data.model )
			return data
	}

	Assert( false, "Warning! Tried to get drone data from an invalid drone!" )
	unreachable
}


DroneData function Drones_GetDroneDataFromDroneProjectorEnt( entity droneProjector )
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( droneProjector == data.roller )
			return data
	}

	Assert( false, "Warning! Tried to get drone data from an invalid drone!" )
	unreachable
}

bool function Drones_IsDroneValid( entity droneModel )
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( droneModel == data.model )
			return true
	}

	return false
}

// Returns active drone data for all different types of Drones
array< DroneData > function Drones_GetAllActiveDrones()
{
	return file.activeDrones
}

DroneData ornull function Drones_GetDroneDataFromRollerModelEnt( entity rollerModel )
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( rollerModel == data.roller )
			return data
	}

	return null
}

bool function Drones_IsValidDroneOrDroneMover( entity droneEnt )
{
	if ( !IsValid( droneEnt ) )
		return false

	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( droneEnt == data.model )
			return true

		if ( droneEnt == data.mover )
			return true

		if ( droneEnt == data.rotator )
			return true
	}

	return false
}

void function Drones_DebugDrawAllSafeDronePaths( float displayTime = 120 )
{
	// addUniqueDroneLogicHere - Need to trigger the function for the new drone type path

	// Debug draw Loot Drone Paths
	DebugDrawSafeDronePathsByPathArray( file.lootDronePaths )

	// Debug draw Ad Drone Paths
	DebugDrawSafeDronePathsByPathArray( file.adDronePaths, 120, < 255, 255, 255 > )

                     
                                   
                                                                                          
      

                        
	// Debug draw Broadcast Drone Paths
	DebugDrawSafeDronePathsByPathArray( file.broadcastDronePaths )
      

	file.drawDroneLocations = true
}

void function DebugDrawSafeDronePathsByPathArray( array< array<entity> > dronePaths, float displayTime = 120, vector color = < 255, 0, 0 > )
{
	foreach ( array < entity > path in GetAllDronePathsInCircle( dronePaths ) )
	{
		int numNodes = path.len()
		for ( int j; j < numNodes; j++ )
		{
			int j_next = ( j + 1 ) % numNodes
			//DebugDrawLine( path[j].GetOrigin(), path[ j_next ].GetOrigin(), color, true, displayTime )
		}
	}
}

                     
                                                                                                                                             
 
                                                                                     
                                               
  
                                                                                                               
  
 
      

bool function Drones_IsDroneAlive( DroneData droneData )
{
	if ( !Drones_GetAllActiveDrones().contains( droneData ) )
		return false

	return !droneData.__isDead
}

void function MarkDroneAsDead( DroneData droneData )
{
	droneData.__isDead = true
}

void function Drones_DestroyAllDrones()
{
	// addUniqueDroneLogicHere - Trigger the Destroy all drones function for the specific drone type
	// Destroy Loot Drones
	LootDrones_DestroyAllLootDrones()

	// Destroy Ad Drones
	AdDrones_DestroyAllAdDrones()

                     
                                          
       

                       
                               
       

                      
                                       
       

	                    
		BlimpDrones_DestroyAllBlimpDrones()
       

	                        
		BroadcastDrones_DestroyAllBroadcastDrones()
       
}

void function Drones_InitDronePaths()
{
	// addUniqueDroneLogicHere - Need to init the drone path and clear the temp train node array for each drone type

	if ( Drones_ShouldSpawnLootDrones() )
	{
		// Init paths for Loot Drones
		file.lootDronePaths = InitAndReturnDronePathsByPathType( clone LootDrones_GetTrainNodesArray(), eDroneType.LOOT_DRONE )
		LootDrones_GetTrainNodesArray().clear()
	}

	if ( Drones_ShouldSpawnAdDrones() )
	{
		// Init paths for Ad Drones
		file.adDronePaths = InitAndReturnDronePathsByPathType( clone AdDrones_GetTrainNodesArray(), eDroneType.AD_DRONE )
		AdDrones_GetTrainNodesArray().clear()
	}

                       
                                          
   
                                                               
   
       

                      
                                         
   
                                                               
                                                                 
                                         
   
       

	                    
		if ( Drones_ShouldSpawnBlimpDrones() )
		{
			// Init paths for blimp drones
			file.blimpDronePaths = InitAndReturnDronePathsByPathType( clone BlimpDrones_GetTrainNodesArray(), eDroneType.BLIMP_DRONE )
			BlimpDrones_GetTrainNodesArray().clear()
		}
       

	                        
		if ( Drones_ShouldSpawnBroadcastDrones() )
		{
			// Init paths for Broadcast drones
			file.broadcastDronePaths = InitAndReturnDronePathsByPathType( clone BroadcastDrones_GetTrainNodesArray(), eDroneType.BROADCAST_DRONE )
			BroadcastDrones_GetTrainNodesArray().clear()
		}
       
}

// Stripped down logic from desertlands train init.
// Modified to work for different types of drone paths, needs to be run from Drones_InitDronePaths() for all types of drones that we want active and pathing
array< array<entity> > function InitAndReturnDronePathsByPathType( array< entity > unparsedNodes, int droneTypeForPath )
{
	int numInitTrackNodes         = unparsedNodes.len()
	int curDronePathIdx           = 0
	string expectedPathScriptName
	array< array<entity> > parsedDronePaths

	// Ensure this is a valid drone type
	if ( droneTypeForPath < 0 || droneTypeForPath >= eDroneType._count )
	{
		printf( "DroneDebug: droneTypeForPath Int is not Valid " + droneTypeForPath )
		return parsedDronePaths
	}

	// addUniqueDroneLogicHere - Need to grab the path name for each drone type here (if using paths)
	switch ( droneTypeForPath )
	{
		case eDroneType.LOOT_DRONE:
			expectedPathScriptName = LOOT_DRONE_NODE_SCRIPT_NAME
			break

		case eDroneType.AD_DRONE:
			expectedPathScriptName = AD_DRONE_NODE_SCRIPT_NAME
			break

                    
                                     
                              
        
      

                    
		case eDroneType.BLIMP_DRONE:
			expectedPathScriptName = BLIMP_DRONE_NODE_SCRIPT_NAME
			break
      

                        
		case eDroneType.BROADCAST_DRONE:
			expectedPathScriptName = BROADCAST_DRONE_NODE_SCRIPT_NAME
			break
      

		default:
			printf( "DroneDebug: expectedPathScriptName can't be defined for a Drone path of Type: " + GetEnumString( "eDroneType", droneTypeForPath ) )
			return parsedDronePaths
	}

	for ( int i = numInitTrackNodes - 1; i >= 0; i-- )
	{
		entity startNode = unparsedNodes[i]
		entity curNode = startNode
		unparsedNodes.fastremovebyvalue( startNode )

		parsedDronePaths.append( [ startNode ] )

		while ( true )
		{
			array< entity > linkEnts = curNode.GetLinkEntArray()
			int numLinkEnts = linkEnts.len()

			entity nextNode
			if ( numLinkEnts > 0 )
			{
				if ( numLinkEnts == 1 )
				{
					nextNode = linkEnts[0]
				}
				else
				{
					foreach( ent in linkEnts )
					{
						if ( ent.GetClassName() == DRONE_TRACK_NODE_CLASS_NAME && ent.GetScriptName() == expectedPathScriptName )
						{
							nextNode = ent
						}
					}
				}
			}
			else
			{
				break
			}

			if ( !IsValid( nextNode ) )
			{
				printf( "DroneDebug: WARNING!!! Next train node isn't valid! Breaking out and drawing previous node location." )
				//DebugDrawSphere( curNode.GetOrigin(), 32, <255, 125, 0>, true, 600 )
				unparsedNodes.fastremovebyvalue( nextNode )
				i--
				break
			}
			else if ( nextNode == startNode )
			{
				//printf( "DroneDebug: TrainPathInit: Completed initializing drone path!" )
				break
			}

			unparsedNodes.fastremovebyvalue( nextNode )
			i--
			parsedDronePaths[curDronePathIdx].append( nextNode )
			//printf( "DroneDebug: InitAndReturnDronePathsByPathType: Adding new node to path. Length of current drone path is %i", parsedDronePaths[ curDronePathIdx ].len() )
			curNode = nextNode
		}

		curDronePathIdx++
	}
	return parsedDronePaths
}

void function Drones_SpawnDrones_Thread( int numToSpawn, int droneType )
{
	printf( "DroneDebug: Attempting to spawn " + numToSpawn + " drones of type: " + GetEnumString( "eDroneType", droneType ) )

	Assert( IsNewThread(), "Must be threaded off" )

	if ( numToSpawn <= 0 )
		return


                     
                                                                                                                       
       

	// Ensure this is a valid drone type
	if ( droneType < 0 || droneType >= eDroneType._count )
	{
		printf( "DroneDebug: DroneType Int is not Valid " + droneType )
		return
	}

	FlagWait( "DeathFieldCalculationComplete" )

	//Set the path to use for this Drone type
	array< array<entity> > dronePath

	// addUniqueDroneLogicHere - Need to grab the paths for each drone type here
	switch ( droneType )
	{
		case eDroneType.LOOT_DRONE:
			dronePath = file.lootDronePaths
			break

		case eDroneType.AD_DRONE:
			dronePath = file.adDronePaths
			break

                    
		case eDroneType.BLIMP_DRONE:
			dronePath = file.blimpDronePaths
			break
      

                        
		case eDroneType.BROADCAST_DRONE:
			dronePath = file.broadcastDronePaths
			break
      

		default:
			printf( "DroneDebug: Can't create a Drone Path for a Drone of Type: " + GetEnumString( "eDroneType", droneType ) )
			return
	}

	// Find valid paths for the Drone
	array< array< entity > > validPaths = GetAllDronePathsInCircle( dronePath )
	validPaths.randomize()

	int idxSlice = minint( numToSpawn, maxint( validPaths.len(), 0 ) )
	array< array< entity > > selectedPaths = validPaths.slice( 0, idxSlice )

	printf( "DroneDebug: Actual Drone Spawn Count: %i", selectedPaths.len() )
	for ( int i; i < idxSlice; i++ )
	{
		int numSelectedPathNodes = selectedPaths[i].len()
		int pathStartIdx = RandomIntRange( 0, numSelectedPathNodes )
		int beforePathStartIdx = ( i + 1 ) % numSelectedPathNodes
		vector spawnOrigin = ( selectedPaths[i][pathStartIdx].GetOrigin() + selectedPaths[i][beforePathStartIdx].GetOrigin() ) * 0.5
		spawnOrigin += <0, 0, 64>
		float droneRoll = DEFAULT_DRONE_ROLL

		//printf( "DroneDebug: Creating a drone at <%f, %f, %f>", spawnOrigin.x, spawnOrigin.y, spawnOrigin.z )
		// addUniqueDroneLogicHere - Need to run the create drone function contained in the unique drone script
		DroneData droneData
		switch ( droneType )
		{
			case eDroneType.LOOT_DRONE:
				droneData = LootDrones_CreateLootDrone( spawnOrigin, <0,0,0> )
				break

			case eDroneType.AD_DRONE:
				droneData = AdDrones_CreateAdDrone( spawnOrigin, <0,0,0> )
				droneRoll = AD_DRONE_ROLL
				break

                    
			case eDroneType.BLIMP_DRONE:
				droneData = BlimpDrones_CreateBlimpDrone( spawnOrigin, <0, 0, 0> )
				droneRoll = BLIMP_DRONE_ROLL
				break
      

                        
			case eDroneType.BROADCAST_DRONE:
				droneData = BroadcastDrones_CreateBroadcastDrone( spawnOrigin, <0, 0, 0> )
				droneRoll = BROADCAST_DRONE_ROLL
				break
      

			default:
				printf( "DroneDebug: Can't create a Drone for a Drone of Type: " + GetEnumString( "eDroneType", droneType ) )
				return
		}

		thread Drone_FollowPath_Thread( droneData, selectedPaths[i], selectedPaths[i][pathStartIdx], droneRoll )
	}
}


                      
                                                
 
                                                     
  
                                                                                                                                 

                                          
   
                                
   

                        

                                                                    
                                                                     

                                                                                                    
                                      
   
                                       

                                     
                                                           
    
                                                    
                                                                
                                                           
                                                                                                                              
                               

                                                                      
                                                                                                     
    
                                                                 
    
                                                                                  
                                                                    
    
       
    
            
    
   
  
 
      

                     
                                                  
                                                                
                                                                              
 
                                                                                                                                  

                                                

                       
        

                                     
                                                       
  
                                                                 
        
  

                                            

                                             
                             

                                                                             
                     
  
                               
                                                                                           
    
                                                                                                                               
                                                                  
                                          
    
                                         
        

          
                                                                                                                       
         
  

                                                                             
                         

                                                                       
                                

                       
                                                  
                                                          
  
                             
   
                                             
         

                                  
                             
                                                 
    
                                                                                                           
     
                                              
                              
     
    

                                    
            

                                                     
                                                       
                                                      
   

                                                            
   
                                 
    
                                                                                               
    

                                                  
                                                    
                                       
   
  
     
      
  
                                                       
  

                                                                            
                                       
  
                                                     
                           
                                      

                                                                                                         
                     
                      
   
                                
                                                                      
         

           
                                                                                                                 
          
   

                                                                              
  
 
      

#if DEV
// Stop all drones from moving
void function DEV_Drones_StopAllDrones()
{
	foreach ( droneData in file.activeDrones )
	{
		if ( !droneData.__isDead )
		{
			Signal( droneData.mover, SIGNAL_DRONE_FALL_START )
		}
	}
}
#endif // DEV 