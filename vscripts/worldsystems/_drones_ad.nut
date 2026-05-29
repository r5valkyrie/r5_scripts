global function InitAdDrones
global function EntitiesDidLoadAdDrones

global function AdDrones_GetDroneDataFromBillboardModelEnt
global function AdDrones_GetTrainNodesArray

global function AdDrones_CreateAdDrone
global function AdDrones_DestroyAllAdDrones
global function AdDrones_OnAdDroneDestroyed
global function AdDrones_AdDroneKilled
global function AdDrones_ExplodeAdDrone
global function AdDrones_DroneFallSequence
global function AdDrones_DestroyBillboardProjector
global function AdDrones_DropLoot

struct
{
	array<entity> initOnly_adDroneTrainNodes
} file

void function InitAdDrones()
{
	Assert( !Flag( "EntitiesDidLoad" ), "Warning! You need to call InitAdDrones() before entities loaded!" )
	AddSpawnCallback_ScriptName( AD_DRONE_NODE_SCRIPT_NAME, OnAdDroneNodeSpawned )
}

void function EntitiesDidLoadAdDrones()
{
	PrecacheScriptString( AD_DRONE_MODEL_SCRIPTNAME )
	PrecacheScriptString( AD_DRONE_MOVER_SCRIPTNAME )
	PrecacheScriptString( AD_DRONE_ROTATOR_SCRIPTNAME )
	PrecacheScriptString( AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME )

	PrecacheScriptString( AD_DRONE_NODE_SCRIPT_NAME )
}

void function OnAdDroneNodeSpawned( entity node )
{
	string nodeType = node.GetClassName()
	switch ( nodeType )
	{
		case DRONE_TRACK_NODE_CLASS_NAME:
			AddNodeToTrainNodeArray( node )
			break
	}
}

void function AddNodeToTrainNodeArray( entity node )
{
	if ( !file.initOnly_adDroneTrainNodes.contains( node ) )
		file.initOnly_adDroneTrainNodes.append( node )
}

array<entity> function AdDrones_GetTrainNodesArray()
{
	return file.initOnly_adDroneTrainNodes
}

void function AdDrones_AdDroneKilled( entity droneModel, var damageInfo )
{
	Drones_DroneKilled( droneModel, damageInfo, AD_DRONE_DEATH_SOUND, AD_DRONE_CRASHING_SOUND, AD_DRONE_DAMAGE_VO )
}

void function AdDrones_ExplodeAdDrone( DroneData droneData )
{
	if ( droneData.droneType != eDroneType.AD_DRONE )
		return

	AdDrones_DestroyBillboardProjector( droneData )
	AdDrones_DropLoot( droneData.model )
	// Ensure this is the last function you run in this function, once this runs it will destory the drone model making future validity checks invalid
	Drones_ExplodeDrone( droneData, AD_DRONE_CRASHING_SOUND, AD_DRONE_CRASHED_SOUND, AD_DRONE_FX_EXPLOSION )
}

void function AdDrones_DroneFallSequence( DroneData droneData, var damageInfo )
{
	AdDrones_DestroyBillboardProjector( droneData )
	thread Drones_DroneFallSequence_Thread( droneData, damageInfo, AD_DRONE_FX_FALL_EXPLOSION, AD_DRONE_FALLING_GRAVITY, AD_DRONE_MIN_FALL_DIST_TO_SURFACE )
}

DroneData ornull function AdDrones_GetDroneDataFromBillboardModelEnt( entity billboardModel )
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( billboardModel == data.roller )
			return data
	}

	return null
}

const float PROJECTOR_ATTACH_Z_OFFSET = -15 // The lower this number the lower the projector model goes from the drone
const float PROJECTOR_ATTACH_X_OFFSET = 10 // The higher this number is the more forward the projector model goes in relation to the drone
DroneData function AdDrones_CreateAdDrone( vector origin, vector angles )
{
	DroneData data
	entity droneModel = CreatePropDynamic( AD_DRONE_MODEL, origin, angles, 6 )
	droneModel.SetScriptName( AD_DRONE_MODEL_SCRIPTNAME )
	string scriptName = droneModel.GetScriptName()

	droneModel.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	droneModel.kv.contents = (int(droneModel.kv.contents) | CONTENTS_BLOCK_PING )
	droneModel.Code_SetTeam( TEAM_TICK )
	droneModel.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE ) //Hack to make IsAlive() return true
	droneModel.SetMaxHealth( AD_DRONE_HEALTH_MAX )
	droneModel.SetHealth( AD_DRONE_HEALTH_MAX )
	droneModel.SetTouchTriggers( true )
	droneModel.Highlight_Enable()
	//droneModel.EnableEntScopeHighlight()

	entity mover = CreateScriptMover( AD_DRONE_MOVER_SCRIPTNAME, origin, angles )
	mover.DisallowZiplines()

	//entity rotator = CreateScriptMover( origin, angles )
	//rotator.SetScriptName( AD_DRONE_ROTATOR_SCRIPTNAME )
	//rotator.DisallowZiplines()

	droneModel.SetParent( mover )
	//rotator.SetParent( mover )
	data.model = droneModel
	//data.rotator = rotator
	data.mover = mover
	data.health = AD_DRONE_HEALTH_MAX
	data.__accel = AD_DRONE_FLIGHT_ACCEL
	data.__maxSpeed = AD_DRONE_FLIGHT_SPEED_MAX
	data.__panicSpeed = AD_DRONE_FLIGHT_SPEED_PANIC
	data.__panicDuration = AD_DRONE_PANIC_DURATION
	data.__fallingSpeedMax = AD_DRONE_FALLING_SPEED_MAX
	data.__fallingAccel = AD_DRONE_FALLING_ACCEL
	data.droneType = eDroneType.AD_DRONE


	// Create the loot projector model attached to the drone
	vector projectorOrg = droneModel.GetOrigin() + < PROJECTOR_ATTACH_X_OFFSET, 0, PROJECTOR_ATTACH_Z_OFFSET >
	entity projectorModel = CreatePropDynamic( AD_DRONE_BILLBOARD_PROJECTOR_MODEL, projectorOrg, droneModel.GetAngles(), 0 )//6
	projectorModel.SetScriptName( AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME )
	projectorModel.SetParent( mover )
	data.roller = projectorModel
	projectorModel.Highlight_Enable()
	//projectorModel.EnableEntScopeHighlight()

	AddEntityCallback_OnPostDamaged( droneModel, Drones_OnDronePostDamaged )
	AddEntityDestroyedCallback( droneModel, AdDrones_OnAdDroneDestroyed )

	MarkEntForCleanupOnRoundEnd( droneModel )
	MarkEntForCleanupOnRoundEnd( projectorModel )

	entity soundEntity = CreateEntity( "ambient_generic" )
	soundEntity.SetOrigin( droneModel.GetOrigin() )
	soundEntity.SetSoundName( AD_DRONE_LIVING_SOUND )
	soundEntity.SetParent( droneModel )
	soundEntity.SetEnabled( true )
	data.soundEntity = soundEntity

	AddEMPDamageDevice( data.model )

	Drones_GetAllActiveDrones().append( data )
	ShDrones_DroneSpawned( data.model )

	return data
}

void function AdDrones_OnAdDroneDestroyed( entity droneModel )
{
	if ( ShDrones_IsValidDrone( droneModel ) )
	{
		DroneData data = Drones_GetDroneDataFromDroneModelEnt( droneModel )

                      
                                                                                            
   
                                  
                              
   

                                              
   
                                             
   
                                                                                  
   
                                         
   
     
		if ( data.droneType != eDroneType.AD_DRONE )
			return

		AdDrones_DestroyBillboardProjector( data )
		AdDrones_DropLoot( droneModel )
		Drones_DestroyDrone( data )
      
	}
}

void function AdDrones_DestroyAllAdDrones()
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( data.droneType == eDroneType.AD_DRONE )
			Drones_DestroyDrone( data )
	}
}

void function AdDrones_DestroyBillboardProjector( DroneData droneData )
{
	entity billboardProjectorModel = droneData.roller

	if ( !IsValid( billboardProjectorModel ) )
		return

	if ( billboardProjectorModel.GetScriptName().tolower() != AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME.tolower() )
		return

	int fxId = GetParticleSystemIndex( AD_DRONE_BILLBOARD_PROJECTOR_FX_EXPLOSION )
	entity fx = StartParticleEffectInWorld_ReturnEntity( fxId, billboardProjectorModel.GetOrigin(), <0,0,0> )
	thread DestroyAfterDelay( fx, 5.0 )

	AdDrones_RemoveBillboardForProjectorModel( billboardProjectorModel )

	droneData.roller = null
	billboardProjectorModel.Destroy()
}

int function AdDrones_GetLootAmountToSpawn()
{
	return GetCurrentPlaylistVarInt( "ad_drones_loot_amount_on_death", AD_DRONE_DEFAULT_LOOT_AMOUNT_TO_SPAWN )
}

string function AdDrones_GetLootGroupForLootSpawn()
{
	return GetCurrentPlaylistVarString( "ad_drones_loot_group", AD_DRONE_DEFAULT_LOOT_GROUP )
}

const float LOOT_THROW_STRENGTH = 350.0
void function AdDrones_DropLoot( entity droneModel )
{
	if( !IsValid( droneModel ) )
		return

	int lootAmountToSpawn = AdDrones_GetLootAmountToSpawn()
                       
                                                                                                                                                               
   
                                                   
   
       
	string lootGroup = AdDrones_GetLootGroupForLootSpawn()

	if ( lootAmountToSpawn <= 0 )
		return

	vector throwOriginOffset = < 0, 0, 100 >
	for ( int i = 0; i < lootAmountToSpawn; i++ )
	{
		string lootRef = SURVIVAL_GetWeightedItemFromGroup( lootGroup )
		SpawnAndThrowItems_ReturnItems( droneModel, lootRef, 1, LOOT_THROW_STRENGTH, eSpawnSource.GAME, throwOriginOffset )
	}
}