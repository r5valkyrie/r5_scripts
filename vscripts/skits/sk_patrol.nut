#if SERVER

global function LaunchSkit_Patrol

#if DEVELOPER
global function DebugDrawPatrolPaths
global function DebugToggleDrawLeader
#endif

global enum ePatrolSize
{
	SOLO = 1,
	SMALL = 2,
	MEDIUM = 4,
	LARGE = 6,
	HUGE = 8
}

struct TraverseStruct
{
	PatrolRouteNode& currentNode
	bool traverseBackwards
}

struct MyVars
{
	PatrolRoute&         route
	int                  zoneId
	array<int>           zoneGroupIds
	ResourceGroup&       baseGroup

	int                  patrolSize

	NPCSquadInfo         patrolSquad
}
table<SkitInstance, MyVars> s_siToVars


SkitInstance ornull function InitPatrolSkit( PatrolRoute route, ResourceGroup baseGroup, int patrolSize = ePatrolSize.MEDIUM )
{
	array<InfantrySpawn> spawnPoints
	spawnPoints = ORS_GetLinkedResources( route.core ).infantrySpawns

	if ( spawnPoints.len() == 0 )
	{
		Warning( "%s() - No infantry spawners found for route.", FUNC_NAME() )
		return null
	}

	if ( spawnPoints.len() < patrolSize )
	{
		Warning( "%s() - Fewer spawners then patrolSize (%s) where found", FUNC_NAME(), string( patrolSize ) )
		patrolSize = spawnPoints.len() // don't spawn more then one guy per spawner, it works, but not well.
	}

	SkitInstance si = Skit_AllocInstance( PatrolRuntime, PatrolCleanup )
	MyVars vars
	s_siToVars[si] <- vars

	vars.route = route
	vars.baseGroup = baseGroup
	vars.patrolSize = patrolSize
	vars.zoneId = ORS_GetTopParentZoneIdForResource( route.core )
	vars.zoneGroupIds = MapZones_GetZonesInGroupWithZone( vars.zoneId )

	vars.patrolSquad.spawnPoints = spawnPoints
                   
	vars.patrolSquad.npcTypes = [eNPC.SPECTRE]
     
                                                                                                           
      
	vars.patrolSquad.npcRank = 0 //DEFAULT_RANK
	vars.patrolSquad.spawnCredits = patrolSize

	SkFlagInit( si, "npc_spawned" )
	return si
}


void function PatrolCleanup( SkitInstance si )
{
	printf( "%s()", FUNC_NAME() )

	MyVars vars = s_siToVars[si]
	SkRes_FreeResource( vars.route.core, si )

	delete s_siToVars[si]
}


void function PatrolRuntime( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	SkRes_MarkResourceInUse( vars.route.core, si )

	SkTools_WatchZonePopulationsForThreshold( si, vars.zoneGroupIds, eZonePop.PLAYERS_INSIDE, OnInnerEnter, OnInnerLeave )
	SkTools_WatchZonePopulationForThreshold( si, vars.zoneId, eZonePop.PLAYERS_NEARBY, OnNearbyEnter, OnNearbyLeave )

	entity leader

	TraverseStruct traverseData
	traverseData.currentNode = vars.route.startNodeArray.getrandom()

	bool patrolDestroyed = false
	while( !patrolDestroyed )
	{
		SkFlagWait( si, "npc_spawned" )

		if ( !IsAlive( leader ) )
		{
			leader = GetNewPatrolLeader( vars.patrolSquad.ents )
			leader.DisableBehavior( "Follow" )
			leader.AssaultSetGoalRadius( 256 ) //256 is min for spectres.
			//leader.AssaultSetArrivalTolerance( 4 ) //4 is min
			leader.AssaultSetFightRadius( 2500 )
			PatrolFollowLeader( vars.patrolSquad.ents, leader )

			#if DEVELOPER
				thread DebugDrawLeader( leader )
			#endif
		}

		waitthread function() : ( leader, traverseData )
		{
			EndSignal( leader, "OnDeath", "OnStateChange" )
			FollowPatrolPath( leader, traverseData )
		}()

		if ( IsAlive( leader ) )
		{
			leader.DisableBehavior( "Assault" )
			waitthread WaitForOutOfCombat( leader )
		}

		patrolDestroyed = (vars.patrolSquad.deathCount == vars.patrolSize)
	}
}


void function FollowPatrolPath( entity npc, TraverseStruct traverseData )
{
	EndSignal( npc, "OnDeath" )

	PatrolRouteNode ornull previousNode = null

	while( true )
	{
		PatrolRouteNode ornull nextNode = GetNextNodeInRoute( traverseData.currentNode, traverseData.traverseBackwards, previousNode )
		if ( nextNode == null )
		{
			traverseData.traverseBackwards = !traverseData.traverseBackwards
			previousNode = null
			continue
		}

		expect PatrolRouteNode( nextNode )
		npc.AssaultClearArrivalTolerance()
		npc.AssaultPointClamped( nextNode.nodeOrigin )
		if ( nextNode.assault_tolerance > 0 )
		{
			float goalRadius = npc.AssaultGetGoalRadius()
			npc.AssaultSetArrivalTolerance( min( goalRadius, nextNode.assault_tolerance ) ) // wait until we are at the radius set in LevelEd.
			table signalData = WaitSignal( npc, "OnFinishedAssault", "OnFailedToPath" )
		}
		else
		{
			table signalData = WaitSignal( npc, "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
		}

		nextNode.visits++
		previousNode = traverseData.currentNode
		traverseData.currentNode = nextNode
	}
}


PatrolRouteNode ornull function GetNextNodeInRoute( PatrolRouteNode node, bool traverseBackwards, PatrolRouteNode ornull previousNode )
{
	array<PatrolRouteNode> childNodes = clone( node.childLinks )
	array<PatrolRouteNode> parentNodes = clone( node.parentLinks )
	if ( previousNode != null )
	{
		// strip out previous node if one is available
		expect PatrolRouteNode( previousNode )
		childNodes.fastremovebyvalue( previousNode )
		parentNodes.fastremovebyvalue( previousNode )
	}

	if ( !traverseBackwards )
	{
		// return a random child node
		if ( childNodes.len() > 0 )
			return GetNodeByWeight( childNodes )
	}
	else if ( parentNodes.len() > 0 )
	{
		// return a random parent node
		return GetNodeByWeight( parentNodes )
	}

	return null // no more nodes in the direction we where tracersing the links
}


PatrolRouteNode function GetNodeByWeight( array<PatrolRouteNode> nodeArray )
{
	nodeArray.sort( SortLowestWeight )

	float totalWeight
	foreach ( PatrolRouteNode node in nodeArray )
		totalWeight += node.weight

	float rnd = RandomFloat(1)
	float combinedPrevChance = 0
	foreach ( PatrolRouteNode node in nodeArray )
	{
		float baseChance = (totalWeight * node.weight) / pow( totalWeight, 2)
		if ( rnd <= (combinedPrevChance + baseChance) )
			return node
		combinedPrevChance += baseChance
	}
	return nodeArray.getrandom()
}


int function SortLowestWeight( PatrolRouteNode a, PatrolRouteNode b )
{
	if ( a.weight > b.weight )
		return 1

	if ( a.weight < b.weight )
		return -1

	return 0
}


void function WaitForOutOfCombat( entity leader )
{
	EndSignal( leader, "OnDeath" )
	while( leader.GetNPCState() == "combat" )
	{
		WaitSignal( leader, "OnStateChange" )
	}
}


entity function GetNewPatrolLeader( array<entity> npcArray )
{
	foreach ( npc in npcArray )
	{
		if ( IsAlive( npc ) )
			return npc
	}
	return null
}


void function OnInnerEnter( SkitInstance si )
{
	printf( "%s()", FUNC_NAME() )
	MyVars vars = s_siToVars[si]

	if ( !vars.patrolSquad.isSpawned )
	{
		array<entity> newNpc = SkNPC_SquadRespawn( si, vars.patrolSquad )
		Assert( vars.patrolSquad.ents.len() > 0, "Failed to spawn any AI for the Patrol" )
		SkFlagSet( si, "npc_spawned" )
	}
}


void function OnInnerLeave( SkitInstance si )
{
	printf( "%s()", FUNC_NAME() )
}


void function OnNearbyEnter( SkitInstance si )
{
	printf( "%s()", FUNC_NAME() )
}


void function OnNearbyLeave( SkitInstance si )
{
	printf( "%s()", FUNC_NAME() )
	MyVars vars = s_siToVars[si]

	if ( vars.patrolSquad.isSpawned )
		SkNPC_SquadReleaseAll( vars.patrolSquad )

	SkFlagClear( si, "npc_spawned" )
}


void function PatrolFollowLeader( array<entity> npcArray, entity leader )
{
	foreach ( npc in npcArray )
	{
		if ( npc == leader || !IsAlive( npc ) )
			continue

		// follow behavoir need a bit of work to look good.
		npc.DisableBehavior( "Assault" )
		npc.EnableBehavior( "Follow" )
		//npc.SetFollowTargetMoveTolerance( 512 )
		//npc.SetFollowGoalTolerance( 0 )
		npc.SetFollowGoalCombatTolerance( 1500 )
		npc.InitFollowBehavior( leader, AIF_FIRETEAM ) //AIF_GUNSHIP, AIF_SIMPLE, AIF_SUPPORT_DRONE, AIF_TITAN_FOLLOW_PILOT, AIF_FIRETEAM
	}
}


//////////////////////
void function LaunchSkit_Patrol( string resource = "patrol" )
{
	array<ResourceGroup> patrolGroups = ORS_Find_( ORS_GetGlobalGroup(), 0, [eORType.GROUP], [resource], [] ).groups

	printf( "Found %d patrol groups.", patrolGroups.len() )
	foreach ( ResourceGroup group in patrolGroups )
	{
		printf( "Launching for group: %s", ORS_GetLongDesc( group.core ) )

		array<PatrolRoute> routes = ORS_Find_( group, 0, [eORType.PATROL_ROUTE], [], [] ).patrolRoutes

		foreach( PatrolRoute route in routes )
		{
			ResourceGroup baseGroup = ORS_GetGroupForResource( route.core )

			SkitInstance ornull siRaw = InitPatrolSkit( route, baseGroup )
			if ( siRaw == null )
			{
				Warning( "%s() - Couldn't init skit for group: %s.", FUNC_NAME(), ORS_GetLongDesc( baseGroup.core ) )
				continue
			}

			expect SkitInstance( siRaw )
			Skit_LaunchInstance( siRaw )
		}
	}
}

#if DEVELOPER
bool s_shouldDrawLeader = false
void function DebugToggleDrawLeader()
{
	s_shouldDrawLeader = !s_shouldDrawLeader
}

void function DebugDrawLeader( entity leader )
{
	EndSignal( leader, "OnDeath" )
	while( true )
	{
		if ( s_shouldDrawLeader )
			DebugDrawText( leader.GetOrigin() + <0,0,72>, string( leader.GetEntIndex() ), false, 0.1 )
		WaitFrame()
	}
}

void function DebugDrawPatrolPaths( float duration = 5.0 )
{
	array<PatrolRouteNode> visitedNodes

	array<PatrolRoute> routes = ORS_Find_( ORS_GetGlobalGroup(), eSearchFlags.RETURN_INUSE_RESOURCES | eSearchFlags.TRAVERSE_INUSE_GROUPS, [eORType.PATROL_ROUTE], [], [] ).patrolRoutes
	foreach ( PatrolRoute route in routes )
	{
		foreach ( PatrolRouteNode startNode in route.startNodeArray )
		{
			vector color                = <RandomFloatRange( 0, 64 ), RandomFloatRange( 224, 255 ), RandomFloatRange( 64, 96 )>
			PatrolRouteNode currentNode = startNode
			bool haveNode               = true

			PatrolRouteNode rootNode
			DrawNodeConnections( startNode, visitedNodes, color, duration )
		}
	}
}

void function DrawNodeConnections( PatrolRouteNode node, array<PatrolRouteNode> visitedNodes, vector color, float duration )
{
	visitedNodes.append( node )

	foreach ( int index, PatrolRouteNode nextNode in node.childLinks )
	{
		if ( !visitedNodes.contains( nextNode ) )
		{
			//DebugDrawArrow( node.nodeOrigin + <0, 0, 16>, nextNode.nodeOrigin, 24, color, true, duration )
			DrawNodeConnections( nextNode, visitedNodes, color, duration )
		}
		else
		{
			//DebugDrawArrow( node.nodeOrigin + <0, 0, 16>, nextNode.nodeOrigin, 24, <0, 0, 192>, true, duration )
		}

		//DebugDrawText( node.nodeOrigin, string( node.visits ), false, duration )
	}

	foreach ( PatrolRouteNode prevNode in node.parentLinks )
	{
		int inlinks = node.parentLinks.len()
		if ( !visitedNodes.contains( prevNode ) )
		{
			//DebugDrawArrow( prevNode.nodeOrigin + <0, 0, -8>, node.nodeOrigin + <0, 0, -8>, 24, <192, 128, 0>, true, duration )
		}

		//DebugDrawText( node.nodeOrigin, string( node.visits ), false, duration )
	}
}
#endif //DEV

#endif // #if SERVER
 