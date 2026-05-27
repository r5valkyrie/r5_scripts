global function ShAdDrones_Init
global function ShAdDrones_EntitiesDidLoad

#if CLIENT
global function AdDrones_SetAdDroneTrailFX
global function AdDrones_SetAdDroneTrailFXType
global function AdDrones_PlayBillboardVFXOnAdDrone_Thread
global function ServerCallback_AdDroneSetBillboardVFX
#endif

#if SERVER
global function AdDrones_GetRandomBillboardEffect
global function AdDrones_GetRandomBillboardIndex
global function AdDrones_SetBillboardForProjectorModel
global function AdDrones_RemoveBillboardForProjectorModel
#endif // SERVER

#if DEV && SERVER
global function DEV_ForceBillboardIndex_For_AdDrones
#endif // DEV && SERVER

global const asset AD_DRONE_MODEL = $"mdl/props/loot_drone/loot_drone.rmdl"
global const asset AD_DRONE_BILLBOARD_PROJECTOR_MODEL = $"mdl/props/loot_projector/loot_projector.rmdl"
global const float AD_DRONE_HEALTH_MAX = 450.0
global const float AD_DRONE_ROLL = 9.0

global const asset AD_DRONE_FX_EXPLOSION = $"P_loot_drone_explosion"
global const asset AD_DRONE_BILLBOARD_PROJECTOR_FX_EXPLOSION = $"P_drone_ads_destroy"
const asset AD_DRONE_FX_TRAIL = $"P_loot_drone_exhaust"
const asset AD_DRONE_FX_TRAIL_PANIC = $"P_loot_drone_exhaust_afterburn"
const asset AD_DRONE_FX_TRAIL_FALL = $"p_loot_drone_body_trail"
global const asset AD_DRONE_FX_FALL_EXPLOSION = $"P_loot_drone_explosion_air"

// Different Billboard VFX
const asset AD_DRONE_BILLBOARD_1 = $"P_drone_ads_chevrex"
const asset AD_DRONE_BILLBOARD_2 = $"P_drone_ads_chickenbique"
const asset AD_DRONE_BILLBOARD_3 = $"P_drone_ads_hammond"
const asset AD_DRONE_BILLBOARD_4 = $"P_drone_ads_koalakola"
const asset AD_DRONE_BILLBOARD_5 = $"P_drone_ads_paradinha"
const asset AD_DRONE_BILLBOARD_6 = $"P_drone_ads_powerizer"
const asset AD_DRONE_BILLBOARD_7 = $"P_drone_ads_silva"
const asset AD_DRONE_BILLBOARD_8 = $"P_drone_ads_ziptec"

global const string AD_DRONE_LIVING_SOUND = "LootDrone_Mvmt_Flying"
global const string AD_DRONE_DEATH_SOUND = "LootDrone_KillShot"
global const string AD_DRONE_CRASHING_SOUND = "LootDrone_Mvmt_Crashing"
global const string AD_DRONE_CRASHED_SOUND = "LootDrone_Explo"

global const string AD_DRONE_DAMAGE_VO = "bc_cargoBotDamaged"

global const float AD_DRONE_FLIGHT_SPEED_MAX = 175.0
global const float AD_DRONE_FLIGHT_ACCEL = 100.0
global const float AD_DRONE_FLIGHT_SPEED_PANIC = 500.0
global const float AD_DRONE_PANIC_DURATION = 5.0

global const float AD_DRONE_FALLING_SPEED_MAX = 800.0
global const float AD_DRONE_FALLING_ACCEL = 300.0
global const float AD_DRONE_FALLING_GRAVITY = 350.0
global const float AD_DRONE_MIN_FALL_DIST_TO_SURFACE = 32.0

global const string AD_DRONE_MODEL_SCRIPTNAME = "AdDroneModel"
global const string AD_DRONE_MOVER_SCRIPTNAME = "AdDroneMover"
global const string AD_DRONE_ROTATOR_SCRIPTNAME = "AdDroneRotator"
global const string AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME = "AdDroneProjectorModel"

global const string AD_DRONE_NODE_SCRIPT_NAME = "ad_drone_path_node"

global const int AD_DRONE_DEFAULT_LOOT_AMOUNT_TO_SPAWN = 0
global const string AD_DRONE_DEFAULT_LOOT_GROUP = "control_ordnance"

struct
{
	array< asset > availableAdDroneBillboardVFX

	#if SERVER
		array< int > unusedBillboardVFXIndexes
		table< entity, int > projectorModelToBillboardIndexTable
	#endif // SERVER

	#if  CLIENT
		table< EHI, int > projectorEHIToBillboardIndexTable
	#endif // CLIENT

} file

void function ShAdDrones_Init()
{
	file.availableAdDroneBillboardVFX = [ AD_DRONE_BILLBOARD_1, AD_DRONE_BILLBOARD_2, AD_DRONE_BILLBOARD_3, AD_DRONE_BILLBOARD_4, AD_DRONE_BILLBOARD_5, AD_DRONE_BILLBOARD_6, AD_DRONE_BILLBOARD_7, AD_DRONE_BILLBOARD_8 ]

	foreach ( particleSystem in file.availableAdDroneBillboardVFX )
	{
		PrecacheParticleSystem( particleSystem )
	}
}

void function ShAdDrones_EntitiesDidLoad()
{
	PrecacheModel( AD_DRONE_MODEL )
	PrecacheModel( AD_DRONE_BILLBOARD_PROJECTOR_MODEL )
	PrecacheParticleSystem( AD_DRONE_FX_TRAIL )
	PrecacheParticleSystem( AD_DRONE_FX_TRAIL_PANIC )
	PrecacheParticleSystem( AD_DRONE_FX_EXPLOSION )
	PrecacheParticleSystem( AD_DRONE_BILLBOARD_PROJECTOR_FX_EXPLOSION )
	PrecacheParticleSystem( AD_DRONE_FX_FALL_EXPLOSION )
	PrecacheParticleSystem( AD_DRONE_FX_TRAIL_FALL )

	#if SERVER
		GamemodeUtility_AddCallback_OnPlayerJoinedMatchInProgress( AdDrones_SetVFXOnAllAdDronesForPlayer )
		AddCallback_OnClientConnectionRestored( AdDrones_SetVFXOnAllAdDronesForPlayer )
		AddCallback_OnObserverConnected( AdDrones_SetVFXOnAllAdDronesForPlayer )
	#endif // SERVER
}

#if SERVER
asset function AdDrones_GetRandomBillboardEffect()
{
	int index = AdDrones_GetRandomBillboardIndex()
	return file.availableAdDroneBillboardVFX[index]
}
#endif // SERVER

#if SERVER
// Get a unique but random billboard VFX index
int function AdDrones_GetRandomBillboardIndex()
{
	// If the we are running this for the first time or we have used up all indexes in this match. Refresh the array of indexes
	if ( file.unusedBillboardVFXIndexes.len() < 1 )
	{
		for ( int i = 0; i < file.availableAdDroneBillboardVFX.len(); i++ )
		{
			file.unusedBillboardVFXIndexes.append( i )
		}
	}

	Assert( file.unusedBillboardVFXIndexes.len() > 0, "AdDrone: Tried to get a Billboard VFX index but the unused indexes array is empty" )
	int billboardIndex = file.unusedBillboardVFXIndexes.getrandom()
	file.unusedBillboardVFXIndexes.fastremovebyvalue( billboardIndex )

	return billboardIndex
}
#endif // SERVER

#if SERVER
// Set the billboard index to a specific drone
void function AdDrones_SetBillboardForProjectorModel( entity projectorModel )
{
	if ( IsValid( projectorModel ) )
	{
		int billboardVFXIndex = AdDrones_GetRandomBillboardIndex()
		file.projectorModelToBillboardIndexTable[projectorModel] <- billboardVFXIndex
		printt( "AdDrone: Setting up which Billboard VFX to use on Ad Drone, going with index ", billboardVFXIndex )
		foreach ( player in GetPlayerArray() )
		{
			if ( IsValid( player ) )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_AdDroneSetBillboardVFX", projectorModel, billboardVFXIndex )
			}
		}
	}
}
#endif // SERVER

#if SERVER
// Remove the destroyed ad drone from the billboard table and kill the billboard VFX
void function AdDrones_RemoveBillboardForProjectorModel( entity projectorModel )
{
	if ( projectorModel in file.projectorModelToBillboardIndexTable )
		delete file.projectorModelToBillboardIndexTable[projectorModel]
}
#endif // SERVER

#if SERVER
// When a player reconnects or an observer connects, make sure we trigger the correct billboard vfx for the ad drones
void function AdDrones_SetVFXOnAllAdDronesForPlayer( entity player )
{
	if ( IsValid( player ) )
	{
		printt( "AdDrone: Player Reconnected, updating Client Billboard Indexes" )
		foreach( key, value in file.projectorModelToBillboardIndexTable )
		{
			if ( IsValid( key ) )
				Remote_CallFunction_NonReplay( player, "ServerCallback_AdDroneSetBillboardVFX", key, value )
		}
	}
}
#endif // SERVER

#if CLIENT
void function ServerCallback_AdDroneSetBillboardVFX( entity projectorEnt, int billboardToDisplay )
{
	printt( "AdDrone: ServerCallback_AdDroneSetBillboardVFX" )

	if ( !IsValid( projectorEnt ) )
		return

	if ( billboardToDisplay < 0 || billboardToDisplay >= file.availableAdDroneBillboardVFX.len() )
		return

	file.projectorEHIToBillboardIndexTable[ ToEHI( projectorEnt ) ] <- billboardToDisplay
	thread AdDrones_PlayBillboardVFXOnAdDrone_Thread( projectorEnt )
}
#endif //CLIENT

#if CLIENT
// Play and manage the lifetime of Ad Drone billboard VFX.
// If we are changing the billboard it is ok to just run this thread again after setting the new billboard in file.projectorEHIToBillboardIndexTable, this thread will kill the old one
void function AdDrones_PlayBillboardVFXOnAdDrone_Thread( entity projectorEnt )
{
	#if DEV
		Assert( IsNewThread(), "Must be threaded off" )
	#endif // DEV

	if ( !IsValid( projectorEnt ) )
		return

	EHI projectorEHI = ToEHI( projectorEnt )
	if ( !( projectorEHI in file.projectorEHIToBillboardIndexTable ) )
		return

	if ( IsValid( clGlobal.levelEnt ) )
		EndSignal( clGlobal.levelEnt, "OnDestroy" )

	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) )
		return

	// Kill an old thread if it is running already
	projectorEnt.Signal( "StopAdDroneVFX" )

	EndSignal( localPlayer, "OnDestroy" )
	EndSignal( projectorEnt, "StopAdDroneVFX" )


	int billboardToDisplay = file.projectorEHIToBillboardIndexTable[ projectorEHI ]
	int fxId = GetParticleSystemIndex( file.availableAdDroneBillboardVFX[ billboardToDisplay ] )
	int billboardFXHandle = StartParticleEffectOnEntity( projectorEnt, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	OnThreadEnd(
		function() : ( billboardFXHandle )
		{
			if ( EffectDoesExist( billboardFXHandle ) )
				EffectStop( billboardFXHandle, false, true )
		}
	)

	WaitForever()
}
#endif //CLIENT

#if CLIENT
void function AdDrones_SetAdDroneTrailFX( DroneClientData droneData )
{
	entity droneEnt = droneData.model

	int fxId          = GetParticleSystemIndex( AD_DRONE_FX_TRAIL )
	int attachIdx     = droneEnt.LookupAttachment( DEFAULT_DRONE_FX_ATTACH_NAME )
	int trailFXHandle = StartParticleEffectOnEntity( droneEnt, fxId, FX_PATTACH_POINT_FOLLOW, attachIdx )

	droneData.trailFXHandle = trailFXHandle
}
#endif //CLIENT

#if CLIENT
void function AdDrones_SetAdDroneTrailFXType( entity droneEnt, int trailType )
{
	printt( "AdDrone: AdDrones_SetAdDroneTrailFXType" )
	if ( !ShDrones_IsValidDrone( droneEnt ) )
		return

	asset fxAsset
	int fxHandle
	DroneClientData clientData = ShDrones_GetDroneClientData( droneEnt )
	switch( trailType )
	{
		case eDroneTrailFXType.PANIC:
			fxAsset = AD_DRONE_FX_TRAIL_PANIC
			fxHandle = clientData.panicFXHandle
			break
		case eDroneTrailFXType.FALL:
			fxAsset = AD_DRONE_FX_TRAIL_FALL
			fxHandle = clientData.fallFXHandle
			break
		case eDroneTrailFXType.TRAIL:
		default:
			fxAsset = AD_DRONE_FX_TRAIL
			fxHandle = clientData.trailFXHandle
	}

	if ( EffectDoesExist( fxHandle ) )
		return

	int fxId = GetParticleSystemIndex( fxAsset )
	int attachIdx = droneEnt.LookupAttachment( ( DEFAULT_DRONE_FX_ATTACH_NAME ) )
	int trailFXHandle = StartParticleEffectOnEntity( droneEnt, fxId, FX_PATTACH_POINT_FOLLOW, attachIdx )

	switch( trailType )
	{
		case eDroneTrailFXType.PANIC:
			clientData.panicFXHandle = trailFXHandle
			break
		case eDroneTrailFXType.FALL:
			clientData.fallFXHandle = trailFXHandle
			break
		case eDroneTrailFXType.TRAIL:
		default:
			clientData.trailFXHandle = trailFXHandle
	}
}
#endif //CLIENT

#if DEV && SERVER
void function DEV_ForceBillboardIndex_For_AdDrones( int billboardVFXIndex )
{
	foreach ( DroneData data in Drones_GetAllActiveDrones() )
	{
		if ( data.droneType == eDroneType.AD_DRONE && IsValid( data.roller ) && data.roller.GetScriptName().tolower() == AD_DRONE_PROJECTOR_MODEL_SCRIPTNAME.tolower() )
		{
			file.projectorModelToBillboardIndexTable[ data.roller ] <- billboardVFXIndex
			foreach ( player in GetPlayerArray() )
			{
				if ( IsValid( player ) )
					Remote_CallFunction_NonReplay( player, "ServerCallback_AdDroneSetBillboardVFX", data.roller, billboardVFXIndex )
			}
		}
	}
}
#endif // DEV && SERVER 