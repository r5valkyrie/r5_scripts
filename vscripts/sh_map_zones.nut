global function MapZones_SharedInit
global function MapZones_RegisterNetworking
global function MapZones_RegisterDataTable
global function MapZones_GetCount
global function GetZoneNameForZoneId
global function MapZones_AddMinimapLevelLabel
global function GetZoneMiniMapNameForZoneId
global function MapZones_GetZoneIdForTriggerName
global function GetDevNameForZoneId
global function MapZones_GetNormalZoneName

                        
                                               
                                            
                              

#if CLIENT
global function SCB_OnPlayerEntersMapZone
global function MapZones_ZoneIntroText
global function MapZones_ZoneIntroTextFullscreenWithSubtext
global function MapZones_GetChromaBackgroundForZoneId
global function MapZones_ShowEnterZoneName
#endif

#if SERVER
global function MapZones_GetAllZoneIDs_Sorted
global function MapZones_GetZoneForOrigin
global function MapZones_GetZoneOrClosestZoneForPoint
global function MapZones_GetClosestNamedZoneForPoint
global function MapZones_GetClosestZoneCenter
global function MapZones_GetTriggerForZone
global function MapZones_GetTriggerNameForZone
global function MapZones_GetTierForZone
                     
                                      
                                            
                           
global function MapZones_GetNameForZone
global function MapZones_GetIdForZoneName
global function MapZones_GetPopulationInfoForZone
global function MapZones_GetZoneGroupForZone
global function MapZones_GetZoneIdsForZoneGroup
global function MapZones_GetZonesInGroupWithZone
global function MapZones_GetBoundsArea2DForZone
global function MapZones_GetNeighborZonesForZones
global function MapZones_PerZoneCallback
global function MapZones_RefreshZoneCalloutsForAll
global function MapZones_RefreshZoneCalloutForPlayer
global function MapZones_WaitForAnyPlayerEntersZone

global function MapZones_AddCallback_PlayerZoneChanged

global function MapZones_GetZoneDatas
//
global function MapZones_GetPopEnumForZone
global function MapZones_GetPopEnumForZones
global function MapZones_GetAveragePositionOfZones
global function MapZones_GetRandomZoneFromPlayers
global function MapZones_GetZoneStatsRef
//
global function MapZones_GetAllZoneIDs
//

global function MapZones_RegisterSkitForNotifications
global function MapZones_StopAllNotificationsForSkit

#if AUTO_PLAYER
global function AutoPlayer_GetDropDestinations
#endif // AUTO_PLAYER
#endif // SERVER

#if (SERVER && DEVELOPER)
global function DEV_PrintMapZoneInfo
global function DEV_MapZone_ToggleOverlay
global function Dev_GoToZone
global function DEV_GetAllZoneStatsRef
#endif // (SERVER && DEVELOPER)

global struct ZonePopulationInfo
{
	int playersInside = 0
	int playersNearby = 0
}

global enum eZonePop
{
	NO_PLAYERS_AROUND,
	PLAYERS_NEARBY,
	PLAYERS_INSIDE,

	_count
}

#if SERVER
const string SIGNAL_ZONES_PLAYER_ENTERED = "PlayerEnteredZone"

typedef PlayerZoneChangedCallback void functionref( entity player, int newZoneId )

global struct ZoneData
{
	entity     zoneTrigger
	int        zoneTier
                     
                         
      
	array<int> neighborZoneIds

	float boundsArea2D

	int playersInside
	int playersNearby

	array<SkitInstance> skitPopNotifies

	int    zoneId
	string zoneName
	string zoneGroup
	string zoneTriggerName

	string statsRef
}
table<int, ZoneData> s_zoneDatas
#endif // SERVER

struct
{
	bool            	mapZonesInitialized = false
	var             	mapZonesDataTable
	table< int, int > 	calculatedZoneTiers

	#if SERVER
		array< PlayerZoneChangedCallback > playerZoneChangedCallbacks
		table< entity, bool > playerCheckCurrentZone
	#endif
} file

const int INVALID_ZONE_ID = -1

string function GetDevNameForZoneId( int zoneId )
{
	return GetDataTableString( file.mapZonesDataTable, zoneId, GetDataTableColumnByName( file.mapZonesDataTable, "triggerName" ) )
}

const string EDITOR_CLASSNAME_ZONE_TRIGGER = "trigger_pve_zone"
void function MapZones_SharedInit()
{
	#if SERVER
		AddSpawnCallbackEditorClass( "trigger_multiple", EDITOR_CLASSNAME_ZONE_TRIGGER, InitZoneTrigger )

		AddCallback_EntitiesDidLoad( EntitiesDidLoad )

		AddCallback_OnClientDisconnected( OnClientDisconnected )
		AddDeathCallback( "player", PlayerDeathCallback )

		RegisterSignal( SIGNAL_ZONES_PLAYER_ENTERED )
	#endif // SERVER
}

const string FUNCNAME_OnPlayerEntersZone = "SCB_OnPlayerEntersMapZone"
void function MapZones_RegisterNetworking()
{
	Remote_RegisterClientFunction( FUNCNAME_OnPlayerEntersZone, "int", 0, 128, "int", 0, 4 )
}


void function MapZones_RegisterDataTable( asset dataTableAsset )
{
	file.mapZonesDataTable   = GetDataTable( dataTableAsset )
	file.mapZonesInitialized = true
}


int function MapZones_GetCount()
{
	if ( !file.mapZonesInitialized )
		return 0

	return GetDataTableRowCount( file.mapZonesDataTable )
}


                        
                                               
 
                                
 

                                                                                                    
 
                                                          
                                           

           
                                                   
       

                                 
  
                             
                 
                                                                                                                                 

            
                                                                                              
                                                                                                                                         

                                             

                                           
                               
      
                                   

        

                           
   
                             
            
   

                                
                                                                                                                                      

            
                                                                                                                                         
                                                  

                                                
   
                                                         
                                       
                                                   
                                  
                                                                    
          
                             
                                                                                 
         
   
      
   
          
                             
                                                                                                         
         
   
        

            
                                                                                                                                         

                          
   
                                                                      

                                 
    
                                                 

                                                                                                                                                                                                                        
                                                                        
                                                                   
                                             
                                   
                                          
                                                                     

           
                              
     
                                                                                                   
                                                                                                                  
     
          

           
                              
                                                                                                                                                                                                                      
          

    
       
    
           
                              
                                                                                                                      
          
    
   
        
            
                          
    
                                     
     
                                                             
                                            
     
    
        

                    
  

               
 
      


string function GetZoneMiniMapNameForZoneId( int zoneId )
{
	Assert( zoneId < GetDataTableRowCount( file.mapZonesDataTable ) )
	string zoneName = GetDataTableString( file.mapZonesDataTable, zoneId, GetDataTableColumnByName( file.mapZonesDataTable, "miniMapName" ) )
	return zoneName
}


string function GetZoneNameForZoneId( int zoneId )
{
	Assert( zoneId < GetDataTableRowCount( file.mapZonesDataTable ) )
	string zoneName = GetDataTableString( file.mapZonesDataTable, zoneId, GetDataTableColumnByName( file.mapZonesDataTable, "zoneName" ) )
	return zoneName
}


void function MapZones_AddMinimapLevelLabel( string name, float x, float y, float scale = 1.0, float width = 200, bool overrideLabelDisable = false )
{
	if ( GetCurrentPlaylistVarBool( "disable_minimap_labels", false ) && !overrideLabelDisable )
		return

	#if CLIENT
		SURVIVAL_AddMinimapLevelLabel( name, x, y, scale, width, overrideLabelDisable )
	#endif // CLIENT

                      
                                                         
                            
}


string function MapZones_GetChromaBackgroundForZoneId( int zoneId )
{
	int column = GetDataTableColumnByName( file.mapZonesDataTable, "chroma" )
	if ( column < 0 )
		return ""

	string chroma = GetDataTableString( file.mapZonesDataTable, zoneId, column )
	return chroma
}


int function MapZones_GetZoneIdForTriggerName( string triggerName )
{
	int zoneId = GetDataTableRowMatchingStringValue( file.mapZonesDataTable, GetDataTableColumnByName( file.mapZonesDataTable, "triggerName" ), triggerName )
	return zoneId
}


string function GetZoneGroupForZoneId( int zoneId )
{
	Assert( zoneId < GetDataTableRowCount( file.mapZonesDataTable ) )

	string name = ""
	int column  = GetDataTableColumnByName( file.mapZonesDataTable, "zoneGroup" )
	if ( column >= 0 )
		name = GetDataTableString( file.mapZonesDataTable, zoneId, column )

	if ( name.len() == 0 )
		return GetZoneNameForZoneId( zoneId )
	return name
}


string function MapZones_GetZoneStatsRef( int zoneId )
{
	if ( !file.mapZonesInitialized )
		return ""

	Assert( zoneId < GetDataTableRowCount( file.mapZonesDataTable ) )
	if ( zoneId < 0 )
		return ""

	string statsRef = ""
	int column      = GetDataTableColumnByName( file.mapZonesDataTable, "statsRef" )
	if ( column >= 0 )
		statsRef = GetDataTableString( file.mapZonesDataTable, zoneId, column )

	return statsRef
}


string function MapZones_GetNormalZoneName( string zoneName )
{
	if ( zoneName.find( "_SHORT" ) > -1 )
	{
		return zoneName.slice( 0, zoneName.len() - 6 )
	}

	return zoneName
}

#if SERVER

#if AUTO_PLAYER
array< vector > function AutoPlayer_GetDropDestinations()
{
	array< vector > ret

	foreach ( zoneId in s_zoneDatas )
	{
		if ( zoneId.zoneTier > 0 )
			ret.append( zoneId.zoneTrigger.GetOrigin() )
	}

	return ret
}
#endif // AUTO_PLAYER


void function PlayerDeathCallback( entity player, var damageInfo )
{
	if ( !IsValid( player ) )
		return
	RemovePlayerFromCurrentZone( player )
	ExecutePendingPopulationNotifies()
}

void function OnClientDisconnected( entity player )
{
	RemovePlayerFromCurrentZone( player )
	ExecutePendingPopulationNotifies()
}

void function EntitiesDidLoad()
{
	#if DEVELOPER
		thread DebugFrameThread()
	#endif // DEV

	if ( !file.mapZonesInitialized )
		return

	thread GenerateZoneTiers()
}

                     
                                                                       
 
                            
  
            

                             
   
                              
   
      
   
                  
   

                    
                                      
                                        
   
                                                                                                          
    
                           
    
   

                                         
   
                               
   
  
 
                           

// The code function involved more than just the geometric position and was causing the check to occasionally fail, so just created a new one
bool function TriggerContainsPointSimple( entity trigger, vector origin )
{
	vector topRight = trigger.GetOrigin() + trigger.GetBoundingMaxs()
	vector botLeft = trigger.GetOrigin() + trigger.GetBoundingMins()

	if ( origin.x > topRight.x || origin.x < botLeft.x )
		return false
	if ( origin.y > topRight.y || origin.y < botLeft.y )
		return false
	if ( origin.z > topRight.z || origin.z < botLeft.z )
		return false

	return true
}

void function GenerateZoneTiers()
{
	array<LootZone> lootZones = GetAllLootZones()

	foreach ( mapZoneData in s_zoneDatas )
	{
		foreach ( lootZone in lootZones )
		{
			if ( !TriggerContainsPointSimple( mapZoneData.zoneTrigger, lootZone.origin ) )
				continue

			if ( lootZone.zoneClass.find( "poi_" ) == 0 )
				continue

			int zoneTier = SURVIVAL_LootTierForLootGroup( lootZone.zoneClass )

                        
                                                                                                           
     
                 
     
                              

			mapZoneData.zoneTier = maxint( zoneTier, mapZoneData.zoneTier )
		}

		WaitFrame()
	}

	foreach ( outerMapZoneData in s_zoneDatas )
	{
		if ( outerMapZoneData.zoneName == "" )
			continue

		foreach ( innerMapZoneData in s_zoneDatas )
		{
			if ( innerMapZoneData.zoneName != outerMapZoneData.zoneName )
				continue

			innerMapZoneData.zoneTier = maxint( outerMapZoneData.zoneTier, innerMapZoneData.zoneTier )
			outerMapZoneData.zoneTier = maxint( outerMapZoneData.zoneTier, innerMapZoneData.zoneTier )
		}
	}

                        
                                                                             
                           
                                        
   
                                                        
   

                                               
       
}

int function MapZones_GetZoneForOrigin( vector point )
{
	foreach ( ZoneData zd in s_zoneDatas )
	{
		if ( zd.zoneTrigger.ContainsPoint( point ) )
			return zd.zoneId
	}

	return -1
}

int function MapZones_GetClosestZoneCenter( vector point )
{
	int bestZone   = -1
	float bestDist = 9999999.9
	foreach ( ZoneData zd in s_zoneDatas )
	{
		float dist = Distance( point, zd.zoneTrigger.GetCenter() )
		if ( dist > bestDist )
			continue

		bestZone = zd.zoneId
		bestDist = dist
	}

	return bestZone
}

int function MapZones_GetZoneOrClosestZoneForPoint( vector point )
{
	int inZone = MapZones_GetZoneForOrigin( point )
	if ( inZone >= 0 )
		return inZone

	return MapZones_GetClosestZoneCenter( point )
}

string function MapZones_GetClosestNamedZoneForPoint( vector point )
{
	string bestZone = ""
	float bestDist  = 9999999.9
	foreach ( ZoneData zd in s_zoneDatas )
	{
		float dist = Distance( point, zd.zoneTrigger.GetCenter() )
		if ( dist > bestDist )
			continue

		if ( zd.zoneName.len() == 0 )
			continue

		bestZone = zd.zoneName
		bestDist = dist
	}

	return bestZone
}

// ---

// Returns array of ZoneDatas:
//	- Parameters:
//		- includeUnnamed: append unnamed zoneDatas after named ones.
//		- doSortByGreatBounds: sort by greater bounds.
array< ZoneData > function MapZones_GetZoneDatas( bool includeUnnamed = true, bool doSortByGreaterBounds = true, bool doSortByNumLootItems = false )
{
	array< ZoneData > zoneDatas_Named
	array< ZoneData > zoneDatas_Unnamed
	array< ZoneData > result

	if( !file.mapZonesInitialized )
	{
		string warningStr = format( "%s(): called before zones initialized.", FUNC_NAME() )
		Warning( warningStr )
		return result
	}

	foreach( int id, ZoneData zd in s_zoneDatas )
	{
		if( zd.zoneName.len() == 0 )
		{
			zoneDatas_Unnamed.append( zd )
		}
		else
		{
			zoneDatas_Named.append( zd )
		}
	}

	if( doSortByGreaterBounds )
	{
		zoneDatas_Named.sort( Compare_BoundsGreater )
	}
	result.extend( zoneDatas_Named )
	if( includeUnnamed )
	{
		if( doSortByGreaterBounds )
		{
			zoneDatas_Unnamed.sort( Compare_BoundsGreater )
		}
		result.extend( zoneDatas_Unnamed )
	}

                     
                            
  
                                        
  
                           

	return result
}

int function Compare_BoundsGreater( ZoneData a, ZoneData b )
{
	if ( a.boundsArea2D < b.boundsArea2D )
		return 1
	else if ( a.boundsArea2D > b.boundsArea2D )
		return -1

	return 0
}

                     
                                                              
 
                                               
          
                                                    
           

         
 
                           

// ---

array< int > function MapZones_GetAllZoneIDs_Sorted( bool includeUnnamed = true, bool doSortByGreaterBounds = true )
{
	// Returns array of Zone IDs:
	//	- Parameters:
	//		- includeUnnamed: append unnamed zoneIDs after named ones.
	//		- doSortByGreatBounds: sort by greater bounds.

	array< int > result

	if( !file.mapZonesInitialized )
	{
		string warningStr = format( "%s(): called before zones initialized.", FUNC_NAME() )
		Warning( warningStr )
		return result
	}

	array< ZoneData > resultData = MapZones_GetZoneDatas( includeUnnamed, doSortByGreaterBounds )
	
	foreach( int id, ZoneData zd in resultData )
	{
		if ( !result.contains( zd.zoneId ) )
			result.append( zd.zoneId )
	}
	return result
}

// ---

string function MapZones_GetTriggerNameForZone( int zoneId )
{
	if ( !(zoneId in s_zoneDatas) )
		return ""

	ZoneData zd = s_zoneDatas[zoneId]
	return expect string( zd.zoneTrigger.kv.zone_name )
}

entity function MapZones_GetTriggerForZone( int zoneId )
{
	if ( !(zoneId in s_zoneDatas) )
		return null

	ZoneData zd = s_zoneDatas[zoneId]
	return zd.zoneTrigger
}

int function MapZones_GetTierForZone( int zoneId )
{
	if ( !(zoneId in s_zoneDatas) )
		return -1

	ZoneData zd = s_zoneDatas[zoneId]
	return zd.zoneTier
}

                     
                                                       
 
                                
           

                                  
                           
 
                           

string function MapZones_GetNameForZone( int zoneId )
{
	if ( !(zoneId in s_zoneDatas) )
		return ""

	ZoneData zd = s_zoneDatas[zoneId]
	return zd.zoneName
}

int function MapZones_GetIdForZoneName( string zoneName )
{
	if ( file.mapZonesDataTable == null )
		return -1

	zoneName = MapZones_GetNormalZoneName( zoneName )
	int row = GetDataTableRowMatchingStringValue( file.mapZonesDataTable, GetDataTableColumnByName( file.mapZonesDataTable, "zoneName" ), zoneName )
	string triggerName = GetDataTableString( file.mapZonesDataTable, row, GetDataTableColumnByName( file.mapZonesDataTable, "triggerName" ) )
	foreach ( int index, ZoneData zd in s_zoneDatas )
	{
		if ( zd.zoneTriggerName == triggerName )
			return zd.zoneId
	}

	return -1
}

void function MapZones_PerZoneCallback( void functionref( int ) callbackFunc )
{
	foreach ( int index, ZoneData zd in s_zoneDatas )
	{
		callbackFunc( index )
	}
}

ZonePopulationInfo function MapZones_GetPopulationInfoForZone( int zoneId )
{
	Assert( zoneId in s_zoneDatas )

	ZonePopulationInfo result
	ZoneData zd = s_zoneDatas[zoneId]
	result.playersInside = zd.playersInside
	result.playersNearby = zd.playersNearby
	return result
}

string function MapZones_GetZoneGroupForZone( int zoneId )
{
	if ( !(zoneId in s_zoneDatas) )
		return ""

	ZoneData zd = s_zoneDatas[zoneId]
	return zd.zoneGroup
}

array<int> function MapZones_GetZoneIdsForZoneGroup( string zoneGroup )
{
	array<int> ids = []
	foreach ( zoneId, zoneData in s_zoneDatas )
	{
		if ( zoneData.zoneGroup == zoneGroup )
			ids.append( zoneId )
	}

	return ids
}

array<int> function MapZones_GetZonesInGroupWithZone( int zoneId )
{
	return MapZones_GetZoneIdsForZoneGroup( MapZones_GetZoneGroupForZone( zoneId ) )
}

float function MapZones_GetBoundsArea2DForZone( int zoneId )
{
	Assert( zoneId in s_zoneDatas )

	ZoneData zd = s_zoneDatas[zoneId]
	return zd.boundsArea2D
}

array<int> function MapZones_GetNeighborZonesForZones( array<int> zoneIds )
{
	array<int> allneighbors
	foreach ( zoneId in zoneIds )
	{
		ZoneData zd = s_zoneDatas[zoneId]
		foreach ( neighborId in zd.neighborZoneIds )
		{
			if ( zoneIds.contains( neighborId ) )
				continue
			if ( allneighbors.contains( neighborId ) )
				continue
			allneighbors.append( neighborId )
		}
	}
	return allneighbors
}

float function GetZoneBoundsArea2D( entity trigger )
{
	vector mins  = trigger.GetBoundingMins()
	vector maxs  = trigger.GetBoundingMaxs()
	vector delta = (maxs - mins)

	return (delta.x * delta.y)
}

void function DestroyZoneTrigger( entity trigger )
{
	//destroy ent along with any linked ents
	array<entity> linkedEnts = trigger.GetLinkEntArray()
	foreach ( linkedEnt in linkedEnts )
	{
		if ( IsValid( linkedEnt ) )
			linkedEnt.Destroy()
	}
	trigger.Destroy()
}

void function InitZoneTrigger( entity trigger )
{
	// Map does not support map zones
	if ( !file.mapZonesInitialized )
	{
		DestroyZoneTrigger( trigger )
		return
	}

	string zoneName = expect string( trigger.kv.zone_name )
	int zoneId      = MapZones_GetZoneIdForTriggerName( zoneName )
	if ( zoneId == INVALID_ZONE_ID )
	{
		Warning( "Could not find map zone in datatable: " + zoneName )
		DestroyZoneTrigger( trigger )
		return
	}

	//Assert( !(zoneId in s_zoneDatas), format( "Can't have more than one zone trigger with the same name: '%s'", zoneName ) )
	if ( (zoneId in s_zoneDatas) )
	{
		Warning( "%s() - Can't have more than one zone trigger with the same name: '%s'", FUNC_NAME(), zoneName )
	}

	ZoneData zd
	s_zoneDatas[zoneId] <- zd
	trigger.e.triggerZoneId = zoneId

	trigger.kv.triggerFilterUseNew       = 1
	trigger.kv.triggerFilterPlayer       = "all"
	trigger.kv.triggerFilterPhaseShift   = "any"
	trigger.kv.triggerFilterNpc          = "none"
	trigger.kv.triggerFilterNonCharacter = 0
	trigger.kv.triggerFilterTeamMilitia  = 1
	trigger.kv.triggerFilterTeamIMC      = 1
	trigger.kv.triggerFilterTeamNeutral  = 1
	trigger.kv.triggerFilterTeamBeast    = 1
	trigger.kv.triggerFilterTeamOther    = 1
	trigger.ConnectOutput( "OnStartTouch", ZoneTrigger_OnStartTouch )
                         
                                                         
                                            
                                                                          
                                                   
                                                   
                                                                                                                           
                                                                                         
                                   
        
                           
                                                                                    
       
       

	zd.zoneTrigger 		= trigger
	zd.zoneId      		= zoneId
	zd.zoneName    		= GetZoneNameForZoneId( zoneId )
	zd.zoneGroup   		= GetZoneGroupForZoneId( zoneId )
	zd.zoneTriggerName 	= zoneName
	zd.statsRef   		= MapZones_GetZoneStatsRef( zoneId )

	zd.boundsArea2D = GetZoneBoundsArea2D( trigger )

	foreach ( entity neighborEnt in trigger.GetLinkEntArray() )
	{
		if ( GetEditorClass( neighborEnt ) != EDITOR_CLASSNAME_ZONE_TRIGGER )
			continue

		string neighborZoneName = expect string( neighborEnt.kv.zone_name )
		int neighborZoneId      = MapZones_GetZoneIdForTriggerName( neighborZoneName )
		zd.neighborZoneIds.append( neighborZoneId )
	}
}


array<int> function MapZones_GetAllZoneIDs()
{
	array<int> res = []
	foreach ( ZoneData zd in s_zoneDatas )
	{
		if ( !res.contains( zd.zoneId ) )
			res.append( zd.zoneId )
	}

	return res
}


void function ZoneTrigger_OnStartTouch( entity self, entity activator, entity caller, var value )
{
	entity triggeringEnt = activator
	entity trigger       = self
	if ( !IsValid( triggeringEnt ) )
		return

	if ( triggeringEnt.IsPlayer() )
		OnPlayerEntersZone( triggeringEnt, trigger )
}

array<ZoneData> s_notifyZonesForPop
void function AddToPopNotify( ZoneData zd )
{
	if ( s_notifyZonesForPop.contains( zd ) )
		return
	s_notifyZonesForPop.append( zd )
}

void function RemovePlayerFromCurrentZone( entity player )
{
	if ( player.p.currentZoneId == INVALID_ZONE_ID )
		return

	ZoneData zd = s_zoneDatas[player.p.currentZoneId]
	foreach ( int neighborId in zd.neighborZoneIds )
	{
		ZoneData neighbor = s_zoneDatas[neighborId]
		neighbor.playersNearby -= 1
		AddToPopNotify( neighbor )
	}
	zd.playersInside -= 1
	AddToPopNotify( zd )

	player.p.currentZoneId = INVALID_ZONE_ID
}

void function AddPlayerToNewZone( entity player, int zoneId )
{
	Assert( player.p.currentZoneId == INVALID_ZONE_ID )

	ZoneData zd = s_zoneDatas[zoneId]
	foreach ( int neighborId in zd.neighborZoneIds )
	{
		ZoneData neighbor = s_zoneDatas[neighborId]
		neighbor.playersNearby += 1
		AddToPopNotify( neighbor )
	}
	zd.playersInside += 1
	AddToPopNotify( zd )

	player.p.currentZoneId = zoneId

	zd.zoneTrigger.Signal( SIGNAL_ZONES_PLAYER_ENTERED )
}

void function ExecutePendingPopulationNotifies()
{
	foreach ( ZoneData zd in s_notifyZonesForPop )
	{
		if ( zd.skitPopNotifies.len() == 0 )
			continue

		array<SkitInstance> listCopy = clone zd.skitPopNotifies
		foreach ( SkitInstance si in listCopy )
			Signal( si, SIG_ZONEPOPCHANGED )
	}

	s_notifyZonesForPop.clear()
}

void function MapZones_RegisterSkitForNotifications( SkitInstance si, int zoneId )
{
	if ( si.zonePopNotifies.contains( zoneId ) )
		return

	ZoneData zd = s_zoneDatas[zoneId]
	Assert( !zd.skitPopNotifies.contains( si ) )
	zd.skitPopNotifies.append( si )
	si.zonePopNotifies.append( zoneId )
}

void function MapZones_StopAllNotificationsForSkit( SkitInstance si )
{
	foreach ( int zoneId in si.zonePopNotifies )
		s_zoneDatas[zoneId].skitPopNotifies.fastremovebyvalue( si )
	si.zonePopNotifies.clear()
}

void function MapZones_WaitForAnyPlayerEntersZone( int zoneId )
{
	ZoneData zd = s_zoneDatas[zoneId]
	zd.zoneTrigger.WaitSignal( SIGNAL_ZONES_PLAYER_ENTERED )
}

void function MapZones_RefreshZoneCalloutsForAll()
{
	array<entity> players = GetPlayerArray()
	foreach ( entity player in players )
		MapZones_RefreshZoneCalloutForPlayer( player )
}

void function MapZones_RefreshZoneCalloutForPlayer( entity player )
{
	int zoneId = player.p.currentZoneId
	if ( zoneId >= 0 )
		Remote_CallFunction_Replay( player, FUNCNAME_OnPlayerEntersZone, zoneId, s_zoneDatas[zoneId].zoneTier )
}

void function MapZones_AddCallback_PlayerZoneChanged( PlayerZoneChangedCallback callback )
{
	Assert( !file.playerZoneChangedCallbacks.contains( callback ), "Already added " + string( callback ) + " with MapZones_AddCallback_PlayerZoneChanged" )
	file.playerZoneChangedCallbacks.append( callback )
}

void function OnPlayerEntersZone( entity player, entity zoneTrigger )
{
	//string zoneName = expect string( zoneTrigger.kv.zone_name )
	//Dev_PrintMessage( player, " ", zoneName, 4  )

	int zoneId = zoneTrigger.e.triggerZoneId

	Remote_CallFunction_Replay( player, FUNCNAME_OnPlayerEntersZone, zoneId, s_zoneDatas[zoneId].zoneTier )

	int newZone = zoneTrigger.e.triggerZoneId
	if ( newZone != player.p.currentZoneId )
	{
		RemovePlayerFromCurrentZone( player )
		AddPlayerToNewZone( player, newZone )
		ExecutePendingPopulationNotifies()

                   
                                                                                                                                                   
                                                                     
        

		thread GetPlayerPOIDataThread( player )
		foreach( func in file.playerZoneChangedCallbacks )
		{
			func( player, newZone )
		}
	}

	                  
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		{
			FR_Nessie_EnterZone( player, zoneId )
		}
       
}

void function GetPlayerPOIDataThread( entity player )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )

	if ( !(player in file.playerCheckCurrentZone) )
		file.playerCheckCurrentZone [ player ] <- false

	if ( file.playerCheckCurrentZone [ player ] == true )
		return

	if ( !(file.playerCheckCurrentZone [ player ]) )
	{
		file.playerCheckCurrentZone [ player ] = true
		PIN_PlayerEnterPOI( player )
		wait 15.0
	}

	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			file.playerCheckCurrentZone [ player ] = false
		}
	)
}

int function MapZones_GetPopEnumForZone( int zoneId )
{
	ZoneData zd = s_zoneDatas[zoneId]
	if ( zd.playersInside > 0 )
		return eZonePop.PLAYERS_INSIDE
	if ( zd.playersNearby > 0 )
		return eZonePop.PLAYERS_NEARBY
	return eZonePop.NO_PLAYERS_AROUND
}

int function MapZones_GetPopEnumForZones( array<int> zoneIds )
{
	int bestPop = eZonePop.NO_PLAYERS_AROUND
	foreach ( zoneId in zoneIds )
	{
		int thisPop = MapZones_GetPopEnumForZone( zoneId )
		if ( thisPop > bestPop )
			bestPop = thisPop
	}
	return bestPop
}

vector function MapZones_GetAveragePositionOfZones( array<int> zoneIds )
{
	if ( zoneIds.len() == 0 )
		return <0, 0, 0>

	vector accum = <0, 0, 0>
	foreach ( int zoneId in zoneIds )
	{
		entity trigger = MapZones_GetTriggerForZone( zoneId )
		accum += trigger.GetCenter()
	}
	vector result = (accum / float( zoneIds.len() ))
	return result
}

int function MapZones_GetRandomZoneFromPlayers( array<entity> playersOrig )
{
	array<entity> players = clone playersOrig
	players.randomize()
	foreach ( player in players )
	{
		int zoneId = MapZones_GetZoneForOrigin( player.GetOrigin() )
		if ( zoneId < 0 )
			continue
		return zoneId
	}

	return -1
}
#endif // #if SERVER


#if CLIENT
var s_zoneIntroRui = null
void function MapZones_ZoneIntroText_( entity player, string zoneDisplayName, int zoneTier, string zoneDisplaySubText, bool doFullscreenRui )
{
	if ( GetGlobalNetBoolSafe( "isMapZoneDisplayTextDisabled" ) )
		return

	if ( s_zoneIntroRui != null )
		RuiDestroyIfAlive( s_zoneIntroRui )

	var rui
	if ( doFullscreenRui )
		rui = CreateFullscreenRui( $"ui/map_zone_intro_title.rpak", 0 )
	else
		rui = CreateCockpitRui( $"ui/map_zone_intro_title.rpak", 0 )

	string currentPlaylist = GetCurrentPlaylistName()

	RuiSetString( rui, "titleText", zoneDisplayName )
	if ( GetPlaylistVarBool( currentPlaylist, "loot_display_zone_tier", true ) )
	{
		RuiSetString( rui, "subTextDefault", zoneDisplaySubText )
		RuiSetInt( rui, "zoneTier", zoneTier )
	}
	RuiSetBool( rui, "minimapIsDisabled", MiniMapIsDisabled() )
	s_zoneIntroRui = rui
}
void function MapZones_ZoneIntroText( entity player, string zoneDisplayName, int zoneTier )
{
	MapZones_ZoneIntroText_( player, zoneDisplayName, zoneTier, "", false )
}
void function MapZones_ZoneIntroTextFullscreenWithSubtext( entity player, string zoneDisplayName, int zoneTier, string subText )
{
	MapZones_ZoneIntroText_( player, zoneDisplayName, zoneTier, subText, true )
}

array<string> s_lastZoneDisplayNames = ["", ""]
int s_lastZoneDisplayNameIndex = -1
void function SCB_OnPlayerEntersMapZone( int zoneId, int zoneTier )
{
	entity player = GetLocalViewPlayer()

	Chroma_SetPlayerZone( zoneId )

	int ceFlags = player.GetCinematicEventFlags()
	if ( IsBitFlagSet( ceFlags, (CE_FLAG_HIDE_MAIN_HUD | CE_FLAG_INTRO ) ) )
		return

	MapZones_ShowEnterZoneName( zoneId, zoneTier )
}

void function MapZones_ShowEnterZoneName( int zoneId, int zoneTier )
{
	entity player = GetLocalViewPlayer()

	string zoneDisplayName = GetZoneNameForZoneId( zoneId )
	if ( s_lastZoneDisplayNames.contains( zoneDisplayName ) )
		return
	if ( zoneDisplayName.len() == 0 )
		return

	if ( IsPVEMode() )
		zoneTier = 0
	if ( IsPVEMode() || (zoneTier > 1) )
		ClientMusic_RequestStingerForNewZone( zoneId )

	MapZones_ZoneIntroText( player, zoneDisplayName, zoneTier )
	s_lastZoneDisplayNameIndex                         = ((s_lastZoneDisplayNameIndex + 1) % s_lastZoneDisplayNames.len())
	s_lastZoneDisplayNames[s_lastZoneDisplayNameIndex] = zoneDisplayName
}
#endif // CLIENT



#if (SERVER && DEVELOPER)
string function GetZoneLine( int zoneId )
{
	if ( zoneId == INVALID_ZONE_ID )
		return format( "Not touching any zone." )
	return format( "%s    \"%s\"    (%.1f)", GetDevNameForZoneId( zoneId ), GetZoneNameForZoneId( zoneId ), sqrt( s_zoneDatas[zoneId].boundsArea2D ) )
}

void function MapZones_DebugDrawFrame()
{
	array<entity> players = GetPlayerArray()

	// Current zone info:
	{
		string text = ""
		foreach ( entity player in players )
		{
			int zoneID       = MapZones_GetZoneForOrigin( player.GetOrigin() )
			string statRef   = MapZones_GetZoneStatsRef( zoneID )
			string zoneGroup = MapZones_GetZoneGroupForZone( zoneID )

			text += GetZoneLine( player.p.currentZoneId )
			text += format( "  actual: %d", zoneID )

			if ( zoneGroup != "" )
				text += format( "  zoneGroup: %s", zoneGroup )
			if ( statRef != "" )
				text += format( "  statRef: %s", statRef )

			if ( players.len() > 1 )
				text += format( "    (%s)\n", player.GetPlayerName() )
			else
				text += "\n"
		}
		DebugDrawScreenText( 0.20, 0.125, text )
	}

	// All zones info:
	{
		string text = ""
		for ( int zoneId = 0; zoneId < MapZones_GetCount(); ++zoneId )
		{
			if ( !(zoneId in s_zoneDatas) )
				continue

			ZoneData zd = s_zoneDatas[zoneId]
			if ( (zd.playersInside == 0) && (zd.playersNearby == 0) )
				continue

			text += format( "%s\t p(%d,%d)\n", GetDevNameForZoneId( zoneId ), zd.playersInside, zd.playersNearby )

			vector mins = zd.zoneTrigger.GetBoundingMins()
			vector maxs = zd.zoneTrigger.GetBoundingMaxs()
			int rrr     = ((zd.playersInside == 0) ? 150 : 255)
			int ggg     = ((zd.playersInside == 0) ? 150 : 255)
			int bbb     = ((zd.playersInside == 0) ? 128 : 255)
			DebugDrawBox( zd.zoneTrigger.GetOrigin(), mins, maxs, rrr, ggg, bbb, 1, 0.1 )
		}
		DebugDrawScreenText( 0.85, 0.10, text )
	}
}

void function DEV_PrintMapZoneInfo()
{
	//foreach( int index, ZoneData zd in s_zoneDatas )
	int total = 0
	int options = 0
	for ( int index = 0; index < MapZones_GetCount(); ++index )
	{
		if ( !(index in s_zoneDatas) )
			continue
		ZoneData zd = s_zoneDatas[index]

		entity trigger = zd.zoneTrigger
		//DebugDrawBox( trigger.GetOrigin(), trigger.GetBoundingMins(), trigger.GetBoundingMaxs(), <0, 0, 255>, 1, 200.0 )
		DebugDrawText( trigger.GetOrigin() + <0,0,10>, GetDevNameForZoneId( index ), false, 200.0 )

		//printf( "**********************")
		printf( "%s   \"%s\"    Area: (%.0f)   %.0f  Trigger: '%s'  (%s)", GetDevNameForZoneId( index ), GetZoneNameForZoneId( index ), sqrt( zd.boundsArea2D ), zd.boundsArea2D, string( zd.zoneTrigger.kv.zone_name ), string( zd.zoneTrigger ) )
                       
                                                        
                               

                                 
    
             
    
        

		string neighborsDesc = ""
		foreach ( int neighborIndex in zd.neighborZoneIds )
			neighborsDesc += format( "%s%s", ((neighborsDesc.len() > 0) ? ", " : ""), GetDevNameForZoneId( neighborIndex ) )
		printf( "  Neighbors: %s", neighborsDesc )
		printf( "" )
	}

	printf( "Total loot locations %.0f and %.0f zones with any loot ", total, options )
}

bool s_debugDrawFrame = false
void function DEV_MapZone_ToggleOverlay()
{
	s_debugDrawFrame = !s_debugDrawFrame
}

void function Dev_GoToZone( string triggerName )
{
	int zoneId  = MapZones_GetZoneIdForTriggerName( triggerName )
	ZoneData zd = s_zoneDatas[zoneId]
	GetPlayerArray()[0].SetOrigin( zd.zoneTrigger.GetOrigin() )
}

array< string > function DEV_GetAllZoneStatsRef()
{
	array< string > zones
	if ( !file.mapZonesInitialized )
	{
		Warning( "Called DEV_GetAllZoneStatsRef before map zones were initialized" )
	}
	else
	{
		int column = GetDataTableColumnByName( file.mapZonesDataTable, "statsRef" )
		if ( column >= 0 )
		{
			foreach ( zoneId, zoneData in s_zoneDatas )
			{
				string temp = GetDataTableString( file.mapZonesDataTable, zoneId, column )
				zones.append( temp )
			}
		}
	}
	return zones
}

void function DebugFrameThread()
{
	while ( true )
	{
		if ( s_debugDrawFrame )
		{
			MapZones_DebugDrawFrame()
		}

		WaitFrame()
	}
}
#endif // #if (SERVER && DEVELOPER)
