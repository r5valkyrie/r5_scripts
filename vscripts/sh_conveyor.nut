global function ConveyorInit
global function OnSpawnConveyorCrateMover
#if DEV
global function DEBUG_Conveyor_DestroyDeployables
#endif
global array<string> DEPLOYABLE_ABILITY_NAMES = []

struct {
	asset model
	vector modelOffsetSpawn // Lobby Only
	string modelAnimSeq // Lobby Only
	string ambientGeneric
	int crateCount
	float timeGap
	float crateSpeed
	float crateHeight
	array< string > pathNames
	table< string, array< entity > > crates
	bool DEV = false
}file

void function ConveyorInit( asset model, string sound, int crateCount, float speed, vector modelOffsetSpawn = <0, 0, 0>, string modelAnimSeq = "")
{
	DEPLOYABLE_ABILITY_NAMES = [ DIRTY_BOMB_TARGETNAME, TROPHY_SYSTEM_NAME, TESLA_TRAP_NAME, DEATH_TOTEM_TARGETNAME, SILENCE_MOVER_SCRIPTNAME ]
	PrecacheModel (model)
	file.model = model
	file.ambientGeneric = sound
	file.crateCount = crateCount
	file.crateSpeed = speed
	file.modelOffsetSpawn = modelOffsetSpawn
	file.modelAnimSeq = modelAnimSeq
	file.crates = {}
	file.pathNames = []
	AddSpawnCallback_ScriptName( "conveyor_rotator_mover", OnSpawnConveyorCrateMover )
}


void function OnSpawnConveyorCrateMover ( entity mover )
{
	string pathName = mover.GetTargetName()

	array<entity> startPoints = GetEntArrayByScriptName( "ConveyorStartPoint" )
	entity startPoint
	foreach ( p in startPoints )
	{
		if ((pathName == "") || p.GetValueForKey( "script_noteworthy" ) == pathName )
			startPoint = p
	}

	Assert (IsValid(startPoint), "Could not find start point for pathname " + pathName)

	thread SpawnConveyorCrates ( mover, startPoint )
}

void function SpawnConveyorCrates ( entity mover, entity startPoint )
{
	string pathName = mover.GetTargetName()

	float pathTime = GetPathTime ( mover, startPoint )
	float timeGap = ( pathTime / ( file.crateCount ) )

	vector origin = mover.GetOrigin()

	// offset the right side by half a cycle
	if (pathName == "right_side")
		wait timeGap/2

	// destroy the template crate
	mover.Destroy()

	file.pathNames.append( pathName )
	file.crates[pathName] <- []

	while ( file.crates[pathName].len() < file.crateCount )
	{
		entity script_mover = null
		if ( IsLobby() )
		{
			script_mover = CreateScriptMover_NEW("Crate #" + file.crates[pathName].len() + " " +  pathName, startPoint.GetOrigin() + file.modelOffsetSpawn )
			entity model = CreatePropDynamic( file.model, startPoint.GetOrigin() + file.modelOffsetSpawn, <0,0,0> )
			model.SetParent( script_mover )
			model.Anim_PlayOnly( file.modelAnimSeq )
			model.SetCycle( RandomFloat( 1.0 ) )
		}
		else
		{
			script_mover = CreateExpensiveScriptMoverModel(file.model, startPoint.GetOrigin() + file.modelOffsetSpawn, <0, 0, 0>, SOLID_VPHYSICS)
			script_mover.SetPusher( true )
		}

		SetTargetName( script_mover, pathName )
		file.crates[pathName].append( script_mover )
		script_mover.SetScriptName( "Crate #" + file.crates[pathName].len() + " " +  pathName)
		script_mover.Train_MoveToTrainNode( startPoint, file.crateSpeed, file.crateSpeed )
		file.crateHeight = script_mover.GetBoundingMaxs().y

		if ( file.ambientGeneric != "" )
		{
			entity ambientGeneric = CreateEntity( "ambient_generic" )
			ambientGeneric.SetOrigin( script_mover.GetOrigin() + <0, 0, script_mover.GetBoundingMaxs().z / 2 > )
			ambientGeneric.SetSoundName( file.ambientGeneric )
			ambientGeneric.SetEnabled( true )
			ambientGeneric.SetParent( script_mover )
			DispatchSpawn( ambientGeneric )
		}

		thread MoverStatus( script_mover, startPoint )
		wait timeGap
	}

	OnThreadEnd ( void function () : (pathName) { if ( file.DEV ) printf ( "CONVEYOR: Finished spawning crates for :" + pathName )} )
}

void function MoverStatus ( entity script_mover, entity startPoint )
{
	float t = Time()
	if ( !IsLobby() )
	{
		array<entity> nodesThatDestroyChildren = GetDestroyChildrenNodes( startPoint )
		
		if ( nodesThatDestroyChildren.len() == 0 && file.DEV )
		{
			printt ( "Conveyor - WARNING: Didn't find any conveyor belt nodes that destroy children" )
		}
		else
		{
			for ( int i = 0; i < nodesThatDestroyChildren.len(); i++ )
			{
				bool hitNode = false
				while (!hitNode)
				{
					WaitSignal (nodesThatDestroyChildren[i], "OnArriveAtTrainNode")
					if ( Distance(script_mover.GetOrigin(), nodesThatDestroyChildren[i].GetOrigin() ) < 12 )
					{
						// move to next node
						hitNode = true
						Conveyor_DestroyDeployables ( script_mover )
					}
				}
			}
		}
	}

	script_mover.WaitSignal ( "OnTrainStopped" )

	if ( file.DEV )
		printf ( "CONVEYOR: A crate on " + script_mover.GetTargetName() + " is stopped, putting it back to the beginning. It took " + (Time() - t) + " seconds." )

	script_mover.SetOrigin ( startPoint.GetOrigin() )
	script_mover.SetAngles ( startPoint.GetAngles() )
	script_mover.Train_MoveToTrainNode( startPoint, file.crateSpeed, file.crateSpeed )

	thread MoverStatus( script_mover, startPoint )
}

array<entity> function GetDestroyChildrenNodes ( entity startNode )
{
	array<entity> consideredPathNodes = []

	entity pathNode = startNode
	entity lastNode

	array<entity> result = []

	while ( IsValid( pathNode ) )
	{
		consideredPathNodes.append( pathNode )
		lastNode = pathNode

		if ( pathNode.HasKey( "script_noteworthy" ) && pathNode.kv.script_noteworthy == "destroy_children" )
		{
			result.append( pathNode )
		}

		array<entity> nextNodes = pathNode.GetLinkEntArray()
		if ( nextNodes.len() > 0 )
		{
			// normal case, just get the next node in the chain
			pathNode = nextNodes[0]
			if ( consideredPathNodes.contains(pathNode) )
			{
				// We've looped on ourselves
				break
			}
		}
		else
		{
			// We're at the end
			break
		}
	}
	return result
}

#if DEV
void function DEBUG_Conveyor_DestroyDeployables ()
{
	// destroy the deployables on the 'first' crate it finds them on
	foreach ( string name in file.pathNames )
	{
		foreach ( entity crate in file.crates[ name ] )
		{
			array<entity> children = GetChildren(crate)
			foreach ( entity child in children )
			{
				entity target
				foreach ( string abilityName in DEPLOYABLE_ABILITY_NAMES)
				{
					target = FindScriptNameInChildren( child, abilityName )
					if ( target != null )
					{
						printt ( "Conveyor - Debug destroying deployables on: " + crate.GetScriptName() )
						Conveyor_DestroyDeployables ( crate, true )
						break
					}
				}
			}
		}
	}
	printt ( "Conveyor - Didn't find any crates with children" )
}
#endif

void function Conveyor_DestroyDeployables ( entity script_mover, bool destroyImmediately = false )
{
	array<entity> children = GetChildren(script_mover)
	if ( children.len() > 0 )
	{
		foreach ( entity child in children )
		{
			entity target
			foreach ( string abilityName in DEPLOYABLE_ABILITY_NAMES)
			{
				// Skipping these abilities as they already check for overlapping Geo, and I don't want to double up for performance reasons
				if ([DEATH_TOTEM_TARGETNAME].contains(abilityName))
					continue
				target = FindScriptNameInChildren( child, abilityName )
				if ( target != null )
				{
					if ( !destroyImmediately )
					{
						float heightOffset = 0.0
						switch ( abilityName )
						{
							/*case SPACE_ELEVATOR_SCRIPTNAME:
							case GIBRALTAR_DOME_SCRIPTNAME:
								heightOffset = 20.0
								break*/
						}
						//thread Thread_CheckForGeoIntersection( target, script_mover, heightOffset )
					}
					//else
						//DeactivateDeployableAbility ( target )
					break
				}
			}
		}
	}
}

float function GetPathTime ( entity mover, entity startNode )
{
	array<entity> consideredPathNodes = []

	entity pathNode = startNode
	entity lastNode

	float pathTime = 0.0

	while ( IsValid( pathNode ) )
	{
		bool teleport = false
		if ( (!pathNode.HasKey( "teleport_to_node" ) || pathNode.GetValueForKey( "teleport_to_node" ) == "0") && IsValid(lastNode) )
		{
			if (pathNode.HasKey( "perfect_circular_rotation" ) && pathNode.GetValueForKey( "perfect_circular_rotation" ) == "1")
			{
				vector pivotPoint = < lastNode.GetOrigin().x, pathNode.GetOrigin().y, pathNode.GetOrigin().z >
				float angle1 = VectorToAngles( lastNode.GetOrigin() - pivotPoint ).y
				float angle2 = VectorToAngles( pathNode.GetOrigin() - pivotPoint ).y

				float angleDiff = fabs( angle1 - angle2 )
				angleDiff = (angleDiff + 180) % 360 - 180

				Assert ( pivotPoint.y - lastNode.GetOrigin().x == pivotPoint.x - pathNode.GetOrigin().y, "Radius measured from startPoint is: " + (pivotPoint.y - lastNode.GetOrigin().x) + " and the radius measured from endPoint is: " + (pivotPoint.x - pathNode.GetOrigin().y) )

				float radius = pivotPoint.y - lastNode.GetOrigin().x

				pathTime = ( angleDiff * radius ) / file.crateSpeed
			}
			else
			{
				float dist = Distance( pathNode.GetOrigin(), lastNode.GetOrigin() )
				pathTime += dist / file.crateSpeed
			}

		}

		consideredPathNodes.append(pathNode)
		lastNode = pathNode

		array<entity> nextNodes = pathNode.GetLinkEntArray()
		if ( nextNodes.len() > 0 )
		{
			// normal case, just get the next node in the chain
			pathNode = nextNodes[0]
			if ( consideredPathNodes.contains(pathNode) )
			{
				// We've looped on ourselves
				break
			}
		}
		else
		{
			// We're at the end
			break
		}
	}

	if ( file.DEV ) printf ("CONVEYOR: Calculated " + mover.GetTargetName() + " path time as: " + pathTime + " seconds.")
	return pathTime + 0.7 // For some reason the function calculated the path as 0.7 sec shorter than it really is
} 