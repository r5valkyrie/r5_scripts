global function GetIsUnifiedRandomizerEnabled
global function RandomizeNodeLocations
global function MapPropPlacementUtilities_Init
global function PropTool_RandomizeNodeLocations
#if DEVELOPER
	global function MapAnalysis_POIValueSimulation
	global function MapAnalysis_PropPlacementConflicts
	global function MapAnalysis_PropNodeFrequencies
	global function MapAnalysis_ShowPropNodes
	global function MapAnalysis_PrintPropData

	global function PropTool_ShowCurrentPropCombination
	global function PropTool_ValidateSolution
	global function PropTool_WalkCurrentCombination

struct SpawnParameters
{
	array< entity > nodes
	float exclusionDistance
	int goal
	vector debugColor
	string propType
}

#endif

const float PROPTOOL_DISTANCE_TOLERANCE = 100.0

global const table<string, string> ePropPlacementType =
{
	NO_TYPE_SPECIFIED = "none",
	CRAFTER = "crafter",
	RING_CONSOLE = "ring_console"
	ENEMY_SCAN_BEACON = "enemy_scan_beacon"
}

global const table< string, int > propString2Int =
{
	["crafter"] = 0,
	["ring_console"] = 1,
	["enemy_scan_beacon"] = 2
}

struct
{
	#if DEVELOPER
		table< int, int > poiInteractableCounts
		table< entity, int > nodeFrequencyTracker
		array< SpawnParameters > cachedSpawnParameters
		bool usingPropToolLogic = false
	#endif
} file

bool function GetIsUnifiedRandomizerEnabled()
{
	return GetCurrentPlaylistVarBool( "unifed_interactable_randomizer_enabled", true )
}

float function GetGlobalExlusionDistanceModifier()
{
	return GetCurrentPlaylistVarFloat( "global_prop_exclusion_distance_modifier", 1 )
}

void function MapPropPlacementUtilities_Init()
{
	#if DEVELOPER
		file.poiInteractableCounts.clear()
		file.cachedSpawnParameters.clear()
		file.nodeFrequencyTracker.clear()
	#endif
}

array< entity > function RandomizeNodeLocations( array< entity > nodes, float exclusionDistance, int goal, bool destroyUnusedEntities, string propType, vector optionalDebugColor = <0,0,0>)
{
	ArrayRemoveInvalid( nodes )
	array< entity > distributedNodes
	array< entity > nonDistributedNodes

	#if DEVELOPER
		SpawnParameters spawnParams
		foreach ( node in nodes )
		{
			entity dummyNode = CreateEntity( "prop_script" )
			dummyNode.SetOrigin( node.GetOrigin() )
			spawnParams.nodes.append( dummyNode )
		}

		//Two-pass approach is necessary so that all of the props have dummy versions before links are assessed
		foreach ( node in nodes )
		{
			foreach ( entity linkedEnt in node.GetLinkEntArray() )
			{
				if ( GetEditorClass( linkedEnt ) == GetEditorClass( node ) )
				{
					int linkIndex = nodes.find( linkedEnt )
					if ( linkIndex != -1 )
					{
						spawnParams.nodes[nodes.find( node )].LinkToEnt( spawnParams.nodes[linkIndex] )
					}
				}
			}
		}

		spawnParams.exclusionDistance = exclusionDistance * GetGlobalExlusionDistanceModifier()
		spawnParams.goal = goal
		spawnParams.debugColor = optionalDebugColor
		spawnParams.propType = propType
		file.cachedSpawnParameters.append( spawnParams )

		PropTool_ValidateSolution( nodes, propType )
	#endif

	array< vector > randomPropCombination = []
	//if ( propType in propString2Int )
	//	randomPropCombination = PropTool_GetRandomPropCombination( propString2Int[propType] )
	if ( IsValid( randomPropCombination ) && randomPropCombination.len() > 0 )
	{
		PropTool_RandomizeNodeLocations( nodes, distributedNodes, randomPropCombination, goal )
		#if DEVELOPER
		file.usingPropToolLogic = true;
		#endif
	}
	else
		ManualExclusionLogicSpawn( nodes, distributedNodes, exclusionDistance * GetGlobalExlusionDistanceModifier(), goal )

	if ( destroyUnusedEntities )
	{
		foreach ( node in nodes )
			node.Destroy()

		nodes.clear()
	}

	return distributedNodes
}

void function PropTool_RandomizeNodeLocations(  array< entity > nodes, array< entity > distributedNodes, array< vector > randomPropCombination, int goal )
{
	array< entity > nonDistributedNodes

	nodes.randomize()

	while ( nodes.len() > 0 )
	{
		entity node = nodes.pop();
		bool nodeIsInRandomCombination = false
		foreach ( vector v in randomPropCombination )
		{
			if ( DistanceSqr( node.GetOrigin(), v  ) < PROPTOOL_DISTANCE_TOLERANCE )
			{
				nodeIsInRandomCombination = true
				break
			}
		}
		if ( nodeIsInRandomCombination )
		{
			distributedNodes.append( node )
		}
		else
		{
			nonDistributedNodes.append( node )
		}
	}

	while ( distributedNodes.len() < goal && nonDistributedNodes.len() > 0 )
	{
		entity additionalNode = nonDistributedNodes.pop()
		distributedNodes.append( additionalNode )
	}

	nodes.clear()
	nodes.extend( nonDistributedNodes )

	ArrayRemoveInvalid( distributedNodes )
}

void function ManualExclusionLogicSpawn( array< entity > nodes, array< entity > distributedNodes, float exclusionDistance, int goal )
{
	table< entity, array< entity > > links
	foreach ( entity baseEntity in nodes )
	{
		array< entity > linkedEntities = baseEntity.GetLinkEntArray()
		linkedEntities.extend( baseEntity.GetLinkParentArray() )
		links[baseEntity] <- linkedEntities
	}

	array< entity > nonDistributedNodes
	nodes.randomize()
	if ( nodes.len() >= goal )
	{
		while ( nodes.len() > 0 )
		{
			entity node = nodes.pop()
			if ( distributedNodes.len() >= goal )
			{
				nonDistributedNodes.append( node )
				continue
			}

			bool nodeValid = true
			foreach ( entity linkedEntity in links[node] )
			{
				if ( distributedNodes.contains( linkedEntity ) )
				{
					nonDistributedNodes.append( node )
					nodeValid = false
					break
				}
			}

			if ( nodeValid )
			{
				distributedNodes.append( node )

				#if DEVELOPER
					file.nodeFrequencyTracker[node] <- 1
					int relatedPOI = MapZones_GetClosestZoneCenter( node.GetOrigin() )

					if( relatedPOI != -1 )
					{
						if( relatedPOI in file.poiInteractableCounts )
						{
							file.poiInteractableCounts[relatedPOI]++
						}
						else
						{
							file.poiInteractableCounts[relatedPOI] <- 1
						}
					}
				#endif
			}
		}

		while ( distributedNodes.len() < goal )
		{
			entity node = nonDistributedNodes.pop()
			distributedNodes.append( node )

			#if DEVELOPER
				file.nodeFrequencyTracker[node] <- 1
				int relatedPOI = MapZones_GetClosestZoneCenter( node.GetOrigin() )

				if ( relatedPOI != -1 )
				{
					if ( relatedPOI in file.poiInteractableCounts )
					{
						file.poiInteractableCounts[relatedPOI]++
					}
					else
					{
						file.poiInteractableCounts[relatedPOI] <- 1
					}
				}
			#endif
		}

		nodes.clear()
		nodes.extend( nonDistributedNodes )
	}
	else
	{
		// if we have less then the goal lets just keep all of them. We can't just do distributedNodes = clone nodes as the clone is local to this function (yay c++ dependency)
		distributedNodes.clear()
		distributedNodes.extend( clone nodes )
		nodes.clear()
	}

	ArrayRemoveInvalid( distributedNodes )
}

void function OldLogicSpawn( array< entity > nodes, array< entity > distributedNodes, float exclusionDistance, int goal )
{
	array< entity > nonDistributedNodes
	ArrayRemoveInvalid( nodes )
	nodes.randomize()
	if ( nodes.len() >= goal )
	{
		float exclusionDistanceSquared = exclusionDistance * exclusionDistance
		distributedNodes.append( nodes.pop() )

		for ( int i = 0; i < goal - 1; i++ )
		{
			for ( int j = nodes.len() - 1; j >= 0 ; j-- )
			{
				int count = 0
				entity node = nodes[j]
				foreach ( distributedNode in distributedNodes )
				{
					if ( DistanceSqr( node.GetOrigin(), distributedNode.GetOrigin() ) > exclusionDistanceSquared )
					{
						count++
					}
				}

				if ( count == distributedNodes.len() )
				{
					#if DEVELOPER
						int relatedPOI = MapZones_GetClosestZoneCenter( node.GetOrigin() )

						if( relatedPOI != -1 )
						{
							if( relatedPOI in file.poiInteractableCounts )
							{
								file.poiInteractableCounts[relatedPOI]++
							}
							else
							{
								file.poiInteractableCounts[relatedPOI] <- 1
							}
						}
						file.nodeFrequencyTracker[node] <- 1
					#endif

					distributedNodes.append( node )
					nodes.remove( j )
					break
				}
				else
				{
					nonDistributedNodes.append( node )
					nodes.remove( j )
				}
			}
		}

		int validSpotsFound = distributedNodes.len()
		if ( validSpotsFound < goal )
		{
			for ( int i = 0; i < goal - validSpotsFound; i++ )
			{
				distributedNodes.append( nonDistributedNodes[i] )
				nonDistributedNodes.remove( i )

				#if DEVELOPER
					file.nodeFrequencyTracker[nonDistributedNodes[i]] <- 1
					int relatedPOI = MapZones_GetClosestZoneCenter( nonDistributedNodes[i].GetOrigin() )

					if( relatedPOI != -1 )
					{
						if( relatedPOI in file.poiInteractableCounts )
						{
							file.poiInteractableCounts[relatedPOI]++
						}
						else
						{
							file.poiInteractableCounts[relatedPOI] <- 1
						}
					}
				#endif
			}

			nodes.extend( nonDistributedNodes )
		}
	}
	else
	{
		// if we have less then 10 lets just keep all of them.
		distributedNodes = clone nodes
		nodes.clear()
	}

	ArrayRemoveInvalid( distributedNodes )
}

#if DEVELOPER
void function MapAnalysis_POIValueSimulation( bool usingOldLogic = false )
{
	if ( file.usingPropToolLogic )
	{
		printt( "Current map is using prop tool logic to spawn one or more prop types.  POI value simulation not available. " )
		return
	}
	if( GetIsUnifiedRandomizerEnabled() )
		thread MapAnalysis_POIValueSimulationThread( 1000, usingOldLogic )
}

void function MapAnalysis_POIValueSimulationThread( int iterationCount, bool usingOldLogic )
{
	table< int, int > POI_tallies

	for ( int k = 0; k < iterationCount; k++ ){
		file.poiInteractableCounts.clear()
		file.nodeFrequencyTracker.clear()

		foreach( SpawnParameters spawnParam in file.cachedSpawnParameters )
		{
			ArrayRemoveInvalid( spawnParam.nodes )
			array< entity > nodes = clone spawnParam.nodes
			array< entity > distributedNodes

			if ( !usingOldLogic )
			{
				ManualExclusionLogicSpawn( nodes, distributedNodes, spawnParam.exclusionDistance, spawnParam.goal )
			}
			else
			{
				OldLogicSpawn( nodes, distributedNodes, spawnParam.exclusionDistance, spawnParam.goal )
			}
		}

		foreach ( int POI, value in file.poiInteractableCounts )
		{
			if ( POI in POI_tallies )
			{
				POI_tallies[POI] += value
			}
			else
			{
				POI_tallies[POI] <- value
			}
		}

		if( k % 50 == 0 )
		{
			WaitFrame()
		}
	}

	foreach( key, value in POI_tallies )
	{
		if( key == -1 )
			break

		printt( "DIST SIM: " + MapZones_GetNameForZone( key ) + " = " + value )
		//DebugDrawCylinder( MapZones_GetTriggerForZone( key ).GetCenter(), <-90, 0, 0>, 512, 8192, (value > 2000) ? COLOR_GREEN : (value > 1000) ? COLOR_YELLOW : COLOR_RED, true, 100 )
		//DebugDrawText( MapZones_GetTriggerForZone( key ).GetCenter(), MapZones_GetNameForZone( key ) + ": " + (float(value)/1000) + " props", false, 100.0 )
	}
}

void function MapAnalysis_PropPlacementConflicts( string filterType = ePropPlacementType.NO_TYPE_SPECIFIED, bool usingOldLogic = false )
{
	if ( !GetIsUnifiedRandomizerEnabled() )
		return

	foreach ( SpawnParameters spawnParams in file.cachedSpawnParameters )
	{
		if ( filterType == ePropPlacementType.NO_TYPE_SPECIFIED || spawnParams.propType == filterType )
		{
			float exclusionDistanceSquared = spawnParams.exclusionDistance * spawnParams.exclusionDistance
			vector debugColor = spawnParams.debugColor == <0,0,0> ? <RandomInt(256), RandomInt(256), RandomInt(256)> : spawnParams.debugColor
			if( !usingOldLogic )
			{
				for( int i = 0; i < spawnParams.nodes.len(); i++ )
				{
					foreach( entity linkedEnt in spawnParams.nodes[i].GetLinkEntArray() )
					{
						//DebugDrawSphere( spawnParams.nodes[i].GetOrigin(), 1024, debugColor, true, 100 )
						//DebugDrawSphere( linkedEnt.GetOrigin(), 1024, debugColor, true, 100 )
						//DebugDrawLine ( spawnParams.nodes[i].GetOrigin(), linkedEnt.GetOrigin(), debugColor, true, 100 )
						//DebugDrawText( linkedEnt.GetOrigin(), spawnParams.propType, false, 100.0 )
					}
				}
			}
			else
			{
				for ( int i = 0; i < spawnParams.nodes.len() - 1; i++ )
				{
					for ( int j = i + 1; j < spawnParams.nodes.len(); j++ )
					{
						if ( DistanceSqr( spawnParams.nodes[i].GetOrigin(), spawnParams.nodes[j].GetOrigin() ) <= exclusionDistanceSquared )
						{
							//DebugDrawSphere( spawnParams.nodes[i].GetOrigin(), 1024, debugColor, true, 100 )
							//DebugDrawSphere( spawnParams.nodes[j].GetOrigin(), 1024, debugColor, true, 100 )
							//DebugDrawLine ( spawnParams.nodes[i].GetOrigin(), spawnParams.nodes[j].GetOrigin(), debugColor, true, 100 )
							//DebugDrawText( spawnParams.nodes[j].GetOrigin(), spawnParams.propType, false, 100.0 )
							//DebugDrawCircle( spawnParams.nodes[i].GetOrigin(), <0,0,0>, spawnParams.exclusionDistance, debugColor, true, 100 );
						}
					}
				}
			}
		}
	}
}

void function MapAnalysis_PropNodeFrequencies( string filterType = ePropPlacementType.NO_TYPE_SPECIFIED, bool usingOldLogic = false )
{
	if ( file.usingPropToolLogic )
	{
		printt( "Current map is using prop tool logic to spawn one or more prop types.  Prop node frequencies not available. " )
		return
	}
	if ( GetIsUnifiedRandomizerEnabled() )
		thread MapAnalysis_PropNodeFrequenciesThread( filterType, 1000, usingOldLogic )
}

void function MapAnalysis_PropNodeFrequenciesThread( string filterType, int iterationCount, bool usingOldLogic )
{
	table< entity, int > node_tallies

	for ( int k = 0; k < iterationCount; k++ ){
		file.poiInteractableCounts.clear()
		file.nodeFrequencyTracker.clear()

		foreach ( SpawnParameters spawnParam in file.cachedSpawnParameters )
		{
			ArrayRemoveInvalid( spawnParam.nodes )
			array< entity > nodes = clone spawnParam.nodes
			array< entity > distributedNodes
			array< entity > nonDistributedNodes

			if( !usingOldLogic )
			{
				ManualExclusionLogicSpawn( nodes, distributedNodes, spawnParam.exclusionDistance, spawnParam.goal )
			}
			else
			{
				OldLogicSpawn( nodes, distributedNodes, spawnParam.exclusionDistance, spawnParam.goal )
			}
		}

		foreach ( entity node, value in file.nodeFrequencyTracker )
		{
			if( node in node_tallies )
			{
				node_tallies[node] += value
			}
			else
			{
				node_tallies[node] <- value
			}
		}

		if( k % 50 == 0 )
		{
			WaitFrame()
		}
	}

	foreach ( SpawnParameters spawnParams in file.cachedSpawnParameters )
	{
		if ( filterType == ePropPlacementType.NO_TYPE_SPECIFIED || spawnParams.propType == filterType )
		{
			vector debugColor = spawnParams.debugColor == <0,0,0> ? <RandomInt(256), RandomInt(256), RandomInt(256)> : spawnParams.debugColor
			foreach ( entity key in spawnParams.nodes )
			{
				int value = node_tallies[key]
				printt( "DIST SIM: " + value )
				//DebugDrawSphere( key.GetOrigin(), 2048 * (float(value)/iterationCount), (value > (0.8 * iterationCount)) ? COLOR_GREEN : (value > (0.4 * iterationCount)) ? COLOR_YELLOW : COLOR_RED, true, 100 )
				//DebugDrawText( key.GetOrigin(), spawnParams.propType + ": " + (float(value)/(iterationCount * 0.01)) + "%", false, 100.0 )
			}
		}
	}
}

void function MapAnalysis_ShowPropNodes( string filterType = ePropPlacementType.NO_TYPE_SPECIFIED )
{
	if( !GetIsUnifiedRandomizerEnabled() )
		return

	vector propCenter = <0,0,0>
	int propCount

	foreach( SpawnParameters spawnParams in file.cachedSpawnParameters )
	{
		if( filterType == ePropPlacementType.NO_TYPE_SPECIFIED || spawnParams.propType == filterType )
		{
			vector debugColor = spawnParams.debugColor == <0,0,0> ? <RandomInt(256), RandomInt(256), RandomInt(256)> : spawnParams.debugColor
			foreach ( node in spawnParams.nodes )
			{
				//DebugDrawSphere( node.GetOrigin(), 1024, debugColor, true, 100 )
				//DebugDrawText( node.GetOrigin(), spawnParams.propType, false, 100.0 )
				propCenter += node.GetOrigin()
				propCount++
			}
		}
	}

	//DebugDrawCylinder( (propCenter / propCount), <-90, 0, 0>, 512, 16384, COLOR_BLUE, true, 100 )
}

void function MapAnalysis_PrintPropData()
{
	printt("************* PROP DATA")
	printt("map: " + GetMapName() )
	foreach ( SpawnParameters spawnParams in file.cachedSpawnParameters )
	{
		printt("prop: " + spawnParams.propType )
		printt("count: " + spawnParams.nodes.len() )
		printt("goal: " + spawnParams.goal )
	}
	printt("***********************")
}

void function PropTool_ShowCurrentPropCombination( string propType )
{
	int currentComboIndex = 0//PropTool_GetIndexForCurrentPropCombination( propString2Int[propType] )
	array< vector > currentCombo = []
	//currentCombo = PropTool_GetPropCombinationByIndex( propString2Int[propType], currentComboIndex )
	if ( IsValid( currentCombo ) && currentCombo.len() > 0 )
	{
		foreach ( vector vec in currentCombo )
		{
			//DebugDrawSphere( vec, 1024, COLOR_RED, true, 100 )
		}
	}
}

void function PropTool_WalkCurrentCombination_thread( string propType, float delay = 5.0 )
{
	int currentComboIndex = 0//PropTool_GetIndexForCurrentPropCombination( propString2Int[propType] )
	array< vector > currentCombo = []
	//currentCombo = PropTool_GetPropCombinationByIndex( propString2Int[propType], currentComboIndex )
	if ( IsValid( currentCombo ) && currentCombo.len() > 0 )
	{
		foreach ( vector vec in currentCombo )
		{
			vec = vec - < 0.0, 100.0, 0.0 >
			bool teleportedToNextProp = TeleportPlayerNoInterp( gp()[0], vec )
			if ( !teleportedToNextProp )
				printt( "propTool:  unable to teleport to location " + vec.x + " " + vec.y + " " + vec.z )
			wait delay
		}
	}
}

void function PropTool_WalkCurrentCombination( string propType )
{
	thread PropTool_WalkCurrentCombination_thread( propType )
}

void function PropTool_ValidateSolution( array< entity > nodes, string propType, bool verbose = false )
{
	int propTypeInt = propString2Int[propType]
	int comboCount = 0//PropTool_GetPropCombinationCount( propTypeInt )
	printt( "propTool: ********** Validating solution for prop type: " + propType )
	if ( comboCount > 0 )
	{
		int goal = 0
		int comboSize = 0//PropTool_GetPropCombinationSize( propTypeInt )
		foreach ( SpawnParameters spawnParams in file.cachedSpawnParameters )
		{
			if ( spawnParams.propType == propType )
				goal = spawnParams.goal
		}

		printt( "propTool: Number of combinations in solution: " + comboCount )
		printt( "propTool: goal prop count: " + goal )
		printt( "propTool: combination size: " + comboSize )
		int totalVectorsNotFound = 0
		int totalEmptyCombinations = 0
		for ( int i = 0; i < comboCount; i++ )
		{
			int vectorsFound = 0
			int vectorsNotFound = 0

			if ( verbose )
				printt( "propTool: Combo" + i + " :")

			array< vector >	combo = []//PropTool_GetPropCombinationByIndex( propTypeInt, i )

			if ( !IsValid( combo ) || combo.len() <= 0 )
			{
				totalEmptyCombinations += 1

				if ( verbose )
					printt( "proptool: combination is empty or invalid! " )
				continue
			}
			foreach ( vector v in combo )
			{
				bool vecFound = false

				if ( verbose )
					printt( "propTool: < "  + v.x + ", " + v.y + ", " + v.z + " >")

				foreach ( entity node in nodes )
				{
					if ( DistanceSqr( node.GetOrigin(), v  ) < PROPTOOL_DISTANCE_TOLERANCE )
					{
						vecFound = true
						break
					}
				}
				if ( vecFound )
				{
					vectorsFound++

					if ( verbose )
						printt("propTool: \tOK")
				}
				else
				{
					vectorsNotFound++

					if ( verbose )
						printt( "propTool: \tVECTOR NOT A NODE LOCATION!" )
				}
			}
			totalVectorsNotFound += vectorsNotFound

			if ( verbose )
			{
				printt( " propTool: vectors found: " + vectorsFound )
				printt( " propTool: vectors not found: " + vectorsNotFound )
			}
		}
		if ( goal != comboSize || totalEmptyCombinations > 0 ||  totalVectorsNotFound > 0 )
		{
			printt("propTool: SOLUTION HAS ERRORS!")
			if ( goal != comboSize )
			{
				printt( "propTool: goal of " + goal + " does not match size of combinations " + comboSize + ".")
			}
			if ( totalEmptyCombinations > 0  )
			{

				printt( "propTool: solution contains " + totalEmptyCombinations + " empty or invalid combinations." )
			}
			if ( totalVectorsNotFound > 0 )
			{
				printt("propTool: Combinations contain vectors that do not match any node location.")
			}
		}
		else
			printt( "propTool: Solution OK!" )
	}
	else
		printt( "propTool: No combinations found! " )

	printt( "propTool: ***********************" )
}
#endif