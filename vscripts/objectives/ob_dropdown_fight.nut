global function InitObjectiveType_DropDownFight

#if SERVER
global function RunObjectiveType_DropdownFight

const string MY_TYPE = "dropdown_fight"
#endif // SERVER

void function InitObjectiveType_DropDownFight()
{
#if SERVER
	ObjectiveRegistrationInfo reg
	reg.title = "OBJECTIVES"
	reg.icon = $"rui/hud/objectives/generic_icon_a"
	reg.func_onGatherPossibleLaunches = OnGatherPossibleLaunches
	reg.func_runtime = MainThread

	ObjectiveSystem_RegisterType( MY_TYPE, reg )
#endif // SERVER
}

#if SERVER

struct GoalSpotInfo
{
	PointOfInterest& keyItemPOI
}

//
ResourceGroup ornull function GetParentGroupForChildWithKeyWord( ResourceCore core, string keyword )
{
	for ( ResourceGroup grp = ORS_GetGroupForResource( core ); grp != ORS_GetGlobalGroup() ; grp = ORS_GetGroupForResource( grp.core ) )
	{
		if ( grp.core.keywords.contains( keyword ) )
			return grp
	}
	return null
}
ResourceGroup ornull function GetRoomGroupForChild( ResourceCore core )
{
	return GetParentGroupForChildWithKeyWord( core, RES_KEYWORD_ROOM )
}
ResourceGroup ornull function GetBuildingGroupForChild( ResourceCore core )
{
	return GetParentGroupForChildWithKeyWord( core, RES_KEYWORD_BUILDING )
}

struct GoalSpotSetupInfo
{
	PointOfInterest& keyItemPOI
	ResourceGroup ornull roomGroup
	ResourceGroup ornull buildingGroup
}

array<GoalSpotInfo> function GatherGoalSpots( array<int> zoneIds )
{
	array<PointOfInterest> keyitemPOIs
	foreach ( zoneId in zoneIds )
	{
		ResourceGroup zoneGroup = ORS_GetGroupForMapZone( zoneId )
		ResourceCollection coll = ORS_Find_( zoneGroup, 0, [eORType.POI], ["keyitem"], [] )
		keyitemPOIs.extend( coll.pois )
	}

	array<GoalSpotSetupInfo> infos
	foreach( int index, PointOfInterest poi in keyitemPOIs )
	{
		GoalSpotSetupInfo info
		info.keyItemPOI = poi

		info.roomGroup = GetRoomGroupForChild( poi.core )
		info.buildingGroup = GetBuildingGroupForChild( poi.core )

		// Don't want to share rooms or buildings:
		bool isDuped = false
		foreach ( otherInfo in infos )
		{
			if ( (info.roomGroup != null) && (info.roomGroup == otherInfo.roomGroup) )
			{
				isDuped = true
				break
			}
			if ( (info.buildingGroup != null) && (info.buildingGroup == otherInfo.buildingGroup) )
			{
				isDuped = true
				break
			}
		}
		if ( isDuped )
			continue
		infos.append( info )
	}

	array<GoalSpotInfo> results
	foreach( info in infos )
	{
		printf( "Keyitem: %s", ORS_GetLongDesc( info.keyItemPOI.core ) )
		printf( "In a room: %s", string( info.roomGroup != null ) )
		printf( "In a building: %s", string( info.buildingGroup != null ) )

		if ( (info.roomGroup == null) && (info.buildingGroup == null) )
			continue

		GoalSpotInfo result
		result.keyItemPOI = info.keyItemPOI
		results.append( result )
	}

	return results
}


const string SIG_PICKED_UP_BOX = "PickedUpGoalBox"

///////////
struct MyVars
{
	int boxesLeft
}
table<SkitInstance, MyVars> s_siToVars

void function SetupLocalVars( SkitInstance si )
{
	MyVars newVars
	Assert( !(si in si.localVars) )
	s_siToVars[si] <- newVars
	thread function() : (si, newVars)
	{
		WaitSignal( si, SIG_SKIT_SHUTDOWN_COMPLETE )
		delete s_siToVars[si]
	}()
}
MyVars function GetLocalVars( SkitInstance si )
{
	return s_siToVars[si]
}
///////////

void function MainThread( SkitInstance si )
{
	ObjectiveInstance oi = ObjectiveSystem_GetObjectiveForSkit( si )

	RegisterSignal( SIG_PICKED_UP_BOX )

	//

	///////////////////////

	//LockAllDoorsIn2DRadius( oi.launchData.defaultOrigin, 6000.0 )

	vector evacOrigin = oi.launchData.custom.vecVars[VARNAME_EVAC_ORIGIN]

	array<GoalSpotInfo> goalInfos = GatherGoalSpots( oi.launchData.homeZones )
	int boxesTotalCount = SetupGoalBoxes( goalInfos, si, oi )

	SetupLocalVars( si )
	MyVars vars = GetLocalVars( si )
	vars.boxesLeft = boxesTotalCount

	SetupRespawnCheckpoints( oi )
	SetupRoamers( si, oi )
	SetupCommonLoot( si, oi )

	const int TASK_INDEX = 0
	oi.tasklist.SetTasklistStatus( TASK_INDEX, eTaskState.TO_DO )
	oi.tasklist.SetTasklistString( TASK_INDEX, "#OB_TASK_PICK_UP_BOXES" )
	oi.tasklist.SetTasklistCountNow( TASK_INDEX, 0 )
	oi.tasklist.SetTasklistCountGoal( TASK_INDEX, boxesTotalCount )

	int gotBoxes = 0
	while( true )
	{
		WaitSignal( si, SIG_PICKED_UP_BOX )
		++gotBoxes
		oi.tasklist.SetTasklistCountNow( TASK_INDEX, gotBoxes )

		vars.boxesLeft = maxint( (boxesTotalCount - gotBoxes), 0 )
		switch( vars.boxesLeft )
		{
			case 3:
				delaythread( RandomFloatRange( 1.5, 2.5 ) ) PlayCharacterDialogueToEveryone( "ob_dropdown_boxes_left_3" )
				break
			case 2:
				delaythread( RandomFloatRange( 1.5, 2.5 ) ) PlayCharacterDialogueToEveryone( "ob_dropdown_boxes_left_2" )
				break
			case 1:
				delaythread( RandomFloatRange( 1.5, 2.5 ) ) PlayCharacterDialogueToEveryone( "ob_dropdown_boxes_left_1" )
				break
			case 0:
				delaythread( RandomFloatRange( 1.5, 2.5 ) ) PlayCharacterDialogueToEveryone( "ob_dropdown_boxes_left_0" )
				break
		}

		if ( vars.boxesLeft == 0 )
			break
	}

	Wait( 0.5 )
	oi.tasklist.SetTasklistStatus( TASK_INDEX, eTaskState.DONE )
	Wait( 1.0 )
	Objectives_MarkObjectiveAsComplete( oi )

	Wait( 1.0 )
	// Turn off the deathfield:
	{
		if ( Flag( "DeathFieldPaused" ) )
			FlagClear( "DeathFieldPaused" )
		RoundBased_ResetDeathfield()
		EmitSoundAtPosition( TEAM_ANY, (oi.launchData.defaultOrigin + <0, 0, 512>), "Survival_Circle_Edge_ShutDown", GetPlayerArray()[0]  )
	}

	// Final Droppods:
	{
		array<array<int> > podPayloads = [
			[eNPC.DEATH_SPECTRE],
			[eNPC.DEATH_SPECTRE],
			[eNPC.DEATH_SPECTRE],
			[eNPC.DEATH_SPECTRE],
			[eNPC.SPECTRE, eNPC.SPECTRE],
			[eNPC.SPECTRE, eNPC.SPECTRE],
		]
		const bool DO_HUNT = false
		SpawnHunterDroppodsNearby( podPayloads, DO_HUNT, evacOrigin, si, oi, true )
	}

	WaitForever()
}

array<ProwlerSpawn> function GetOutdoorProwlerSpawnsFromGroup( ResourceGroup group )
{
	return ORS_Find_( group, 0, [eORType.PROWLER_SPAWN], [], [RES_KEYWORD_INDOORS] ).prowlerSpawns
}

int function SetupGoalBoxes( array<GoalSpotInfo> goalInfos, SkitInstance si, ObjectiveInstance oi )
{
	foreach( goalInfo in goalInfos )
		SetupGoalBox( goalInfo, si, oi )

	return goalInfos.len()
}

entity function SetupGoalBox( GoalSpotInfo goalInfo, SkitInstance si, ObjectiveInstance oi )
{
	entity box = TreasureBoxCreate( goalInfo.keyItemPOI.core.spawnOrigin, goalInfo.keyItemPOI.core.spawnAngles )

	EmitSoundOnEntity( box, "SQ_Extractor_ItemLoop" )
	box.SetUsable()
	box.AddUsableValue( USABLE_CAN_USE_OVERRIDE )
	Highlight_SetNeutralHighlight( box, "sp_interact_object" )
	Highlight_SetFriendlyHighlight( box, "sp_interact_object" )
	Highlight_SetEnemyHighlight( box, "sp_interact_object" )

	entity wp = CreateWaypoint_BasicLocation( (box.GetOrigin() + <0, 0, 72.0>), ePingType.QUEST_OBJECTIVE )
	wp.SetParent( box )
	Waypoint_Objectives_BindToObjective( wp, oi )
	//Waypoint_Objectives_SetHideWhenOutside( wp )

	SetupGoalLoot( goalInfo, si, oi )
	SetupGuards( goalInfo, si, oi )

	AddCallback_OnUseEntity_ServerOnly( box, void function( entity box, entity player, int useInputFlags ) : (goalInfo, wp, si, oi)
	{
		if ( !IsValid( player ) )
			return
		if ( !player.IsPlayer() )
			return

		EmitSoundOnEntityOnlyToPlayer( player, player, "SQ_Retrieve_Extracted_1p" )
		//EmitSoundOnEntityToTeamExceptPlayer( miniHarvester, "SQ_Retrieve_Extracted_3p", player.GetTeam(), player )

		box.Destroy()
		wp.Destroy()
		Signal( si, SIG_PICKED_UP_BOX )

		array<array<int> > podPayloads = [
			[eNPC.SPECTRE, eNPC.SPECTRE]
		]
		MyVars vars = GetLocalVars( si )
		if ( vars.boxesLeft <= 2 )
			podPayloads.append( [eNPC.DEATH_SPECTRE, eNPC.DEATH_SPECTRE] )

		const bool DO_HUNT2 = true	// weird name to get around DFS parsing issue on May 12, 2020
		SpawnHunterDroppodsNearby( podPayloads, DO_HUNT2, goalInfo.keyItemPOI.core.spawnOrigin, si, oi, false )
	} )

	return box
}

void function SetupGuards( GoalSpotInfo goalInfo, SkitInstance si, ObjectiveInstance oi )
{
	// Room:
	{
		const int MAX_GUARDS_IN_ROOM = 4
		ResourceGroup ornull group = GetRoomGroupForChild( goalInfo.keyItemPOI.core )
		if ( group != null )
		{
			expect ResourceGroup( group )
			if ( !ORS_IsInUse( group.core ) )
			{
				ORS_MarkInUse( group.core )
				BreachableRoomData roomData = BreachableRoomInitNew( oi, si, group, [eNPC.SPECTRE, eNPC.SPECTRE, eNPC.SPECTRE] )

				/*
				array<InfantrySpawn> spawns = ORS_GetInfantrySpawnsFromGroups( [group] )
				spawns.randomize()
				foreach( int index, InfantrySpawn spawn in spawns )
				{
					if ( index >= MAX_GUARDS_IN_ROOM )
						break

					int npcType = ((RandomFloat( 1.0 ) < 0.6) ? eNPC.SHOTGUN_SPECTRE : eNPC.SPECTRE)
					entity npc = SkNPC_SpawnNPC( si, npcType, spawn.core.spawnOrigin, spawn.core.spawnAngles )
					npc.AssaultSetGoalRadius( 500.0 )
					npc.AssaultSetFightRadius( 1000.0 )
				}
				*/
			}
		}
	}

	// Building:
	{
		const int MAX_GUARDS_IN_BUILDING = 10
		ResourceGroup ornull group = GetBuildingGroupForChild( goalInfo.keyItemPOI.core )
		if ( group != null )
		{
			expect ResourceGroup( group )
			if ( !ORS_IsInUse( group.core ) )
			{
				ORS_MarkInUse( group.core )

				array<InfantrySpawn> spawns = ORS_GetInfantrySpawnsFromGroups( [group] )
				spawns.randomize()
				foreach( int index, InfantrySpawn spawn in spawns )
				{
					if ( index >= MAX_GUARDS_IN_BUILDING )
						break

					entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, spawn.core.spawnOrigin, spawn.core.spawnAngles )
					HookDynamicFightRadiusTest( npc )
					//npc.AssaultSetGoalRadius( 500.0 )
					//npc.AssaultSetFightRadius( 1000.0 )
					//npc.AssaultSetGoalRadius( 100.0 )
					//npc.AssaultSetFightRadius( 400.0 )
				}
			}
		}
	}
}

ResourceGroup ornull function GetBuildingOrRoomGroup( GoalSpotInfo goalInfo )
{
	ResourceGroup ornull group = null
	group = GetBuildingGroupForChild( goalInfo.keyItemPOI.core )
	if ( group != null )
		return group
	group = GetRoomGroupForChild( goalInfo.keyItemPOI.core )
	if ( group != null )
		return group

	return null
}

void function SetupGoalLoot( GoalSpotInfo goalInfo, SkitInstance si, ObjectiveInstance oi )
{
                    
                                                   
                                                                 
                      
         
                               

                                                                        
                       
                                              
   
                                  
                             
                                                                                                 
                                  
                                                                 
                                                                                    
   
       
}

void function SetupCommonLoot( SkitInstance si, ObjectiveInstance oi )
{
                    
                                                                                          
                                                                           
                       
                      
                                             
   
                                  
                                                               
    
                                  
                  
    
                                                                                    
   
       
}


void function HookDynamicFightRadiusTest( entity npc )
{
	thread function() : (npc)
	{
		npc.EndSignal( "OnDestroy" )
		npc.EndSignal( "OnDeath" )

		const float DEFAULT_RADIUS_GOAL = 64.0
		const float DEFAULT_RADIUS_RIGHT = 64.0
		npc.AssaultSetGoalRadius( DEFAULT_RADIUS_GOAL )
		npc.AssaultSetFightRadius( DEFAULT_RADIUS_RIGHT )

		const float ANGRY_RADIUS_GOAL = 1000.0
		const float ANGRY_RADIUS_RIGHT = 2000.0
		{
			table details = WaitSignal( npc, "OnSeeEnemy" )
			//printf( " Spotted: %s", string( expect entity( details.activator ) ) )
			npc.AssaultSetGoalRadius( ANGRY_RADIUS_GOAL )
			npc.AssaultSetFightRadius( ANGRY_RADIUS_RIGHT )
		}
	}()
}

void function SpawnHunterDroppodsNearby( array<array<int> > podPayloads, bool doHuntDownPlayers, vector pos, SkitInstance si, ObjectiveInstance oi, bool doGlobal )
{
	array<ResourceGroup> zoneGroups = doGlobal ? [ORS_GetGlobalGroup()] : GetResourceGroupsForZoneIds( oi.launchData.homeZones )
	array<DroppodSpawn> spawns = ORS_GetDroppodSpawnsFromGroups( zoneGroups )
	if ( spawns.len() == 0 )
	{
		printf( "%s() - No droppod spawns found in area.", FUNC_NAME() )
		return
	}

	// Sort closest:
	spawns.sort( int function( DroppodSpawn aa, DroppodSpawn bb ) : (pos)
	{
		float aaDistSqr = DistanceSqr( pos, aa.core.spawnOrigin )
		float bbDistSqr = DistanceSqr( pos, bb.core.spawnOrigin )
		if ( aaDistSqr < bbDistSqr )
			return -1
		if ( aaDistSqr > bbDistSqr )
			return 1
		return 0
	} )

	foreach( int index, DroppodSpawn spawn in spawns )
	{
		if ( index >= podPayloads.len() )
			break
		array<int> payload = podPayloads[index]
		if ( payload.len() == 0 )
			continue

		thread function() : (index, spawn, payload, doHuntDownPlayers, si, oi)
		{
			SkThread_MarkAsNewSubthread( si )
			Wait( index * 0.45 )
			array<entity> podNPCs = SkNPC_SpawnDropPodTroops( si, spawn.core.spawnOrigin, payload )
			if ( doHuntDownPlayers )
			{
				foreach( npc in podNPCs )
					SkNPC_HuntClosestPlayerInObjective( npc, "", oi )
			}
		}()
	}
}

array<ResourceGroup> function GetResourceGroupsForZoneIds( array<int> zoneIds )
{
	array<ResourceGroup> results
	foreach( zoneId in zoneIds )
		results.append( ORS_GetGroupForMapZone( zoneId ) )
	return results
}

void function SetupRespawnCheckpoints( ObjectiveInstance oi )
{
	array<ResourceGroup> zoneGroups = GetResourceGroupsForZoneIds( oi.launchData.homeZones )
	array<PointOfInterest> spawns = ORS_GetPOIResourcesFromGroups( zoneGroups, ["checkpoint"] )
	printf( "%s() - Found %d checkpoint spawns.", FUNC_NAME(), spawns.len() )
	foreach( spawn in spawns )
		MissionCheckpoints_AddGlobalRespawnPoint( spawn.core.spawnOrigin, spawn.core.spawnAngles )
}

void function SetupRoamers( SkitInstance si, ObjectiveInstance oi )
{
	int MAX_ROAMERS = GetCurrentPlaylistVarInt( "mode_dropdown_roamers_count", 5 )

	array<ResourceGroup> zoneGroups = GetResourceGroupsForZoneIds( oi.launchData.homeZones )
	array<InfantrySpawn> spawns = ORS_GetOutdoorInfantrySpawnsFromGroups( zoneGroups )
	spawns.randomize()
	foreach( int index, InfantrySpawn spawn in spawns )
	{
		if ( index >= MAX_ROAMERS )
			break

		entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, spawn.core.spawnOrigin, spawn.core.spawnAngles )
		//npc.AssaultSetGoalRadius( 200.0 )
		npc.AssaultSetFightRadius( 3000.0 )
	}
}

const string VARNAME_EVAC_ORIGIN = "evacOrigin"
ObjectiveInstance function RunObjectiveType_DropdownFight( vector playareaCenter, vector evacOrigin )
{
	ObjectiveLaunchData ld

	int zoneId = MapZones_GetZoneForOrigin( playareaCenter )
	Assert( zoneId >= 0 )

	ld.objectiveType = MY_TYPE
	ld.zoneGroups = [MapZones_GetZoneGroupForZone( zoneId )]
	ld.homeZones = ((ld.zoneGroups.len() > 0) ? MapZones_GetZoneIdsForZoneGroup( ld.zoneGroups[0] ) : [zoneId])
	ld.ambientOverrideType = eAmbientOverrideType.BLOCKED
	ld.defaultOrigin = MapZones_GetAveragePositionOfZones( ld.homeZones )
	//ld.custom.intVars["locId"] <- locId
	ld.custom.vecVars[VARNAME_EVAC_ORIGIN] <- evacOrigin

	ObjectiveInstance oi = ObjectiveSystem_LaunchInstance( ld )
	return oi
}

void function OnGatherPossibleLaunches( array<ObjectiveLaunchData> results )
{
	/*
	for ( int locId = 0; locId < eMyLocations._count; ++locId )
	{
		MyLaunchInfo launchInfo = GetLaunchInfoForSpot( locId )
		bool spotInUse = false
		foreach ( string zoneGroup in launchInfo.zoneGroups )
		{
			if ( Objectives_AnyObjectiveIsUsingZoneGroup( zoneGroup ) )
				spotInUse = true
		}
		if ( spotInUse )
			continue

		if ( Objectives_AnyObjectiveIsUsingZoneIds( launchInfo.homeZones ) )
			continue

		ObjectiveLaunchData launchData
		launchData.objectiveType = MY_TYPE
		launchData.homeZones = launchInfo.homeZones
		launchData.zoneGroups = launchInfo.zoneGroups
		launchData.ambientOverrideType = eAmbientOverrideType.BLOCKED
		launchData.defaultOrigin = MapZones_GetAveragePositionOfZones( launchData.homeZones )
		launchData.custom.intVars["locId"] <- locId
		results.append( launchData )
	}
	*/
}

//
//
//

void function LockAllDoorsIn2DRadius( vector origin, float radius )
{
	array<entity> doors = GetAllDoorEnts()
	foreach( door in doors)
	{
		if ( !IsCodeDoor( door ) )
			continue
		if ( Distance( door.GetOrigin(), origin ) > radius )
			continue

		DoorMakeBreachable( door, door.GetOrigin(), door.GetAngles() )
		AddEntityDestroyedCallback( door, void function ( entity door ) : ()
		{
			DoorRestoreNavAndDeleteHints( door )
		} )
	}
	//
}

#endif // SERVER
 