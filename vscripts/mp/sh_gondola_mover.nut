global function GondolaMover_Init
global function GondolasAreActive
global function IsPlayerInsideGondola
global function IsGondolaAtStation

// Scriptnames
global const string GONDOLA_SCRIPTNAME = "gondola_func_brush"
const string GONDOLA_INTERIOR_TRIGGER = "gondola_interior_trigger"
const string GONDOLA_MOVER_SCRIPTNAME = "gondola_mover"

#if SERVER
const string GONDOLA_NODE_START_SCRIPTNAME = "gondola_node_a"
const string GONDOLA_NODE_END_SCRIPTNAME = "gondola_node_b"
const string GONDOLA_NODE_MIDSTATION_A = "gondola_midstation_a"
const string GONDOLA_NODE_MIDSTATION_B = "gondola_midstation_b"
const string GONDOLA_MIDSTATION_TRIGGER = "gondola_midstation_trigger"

// Audio
const string GONDOLA_MOTOR_SOUND = "Vehicles_Gondola_Cart_Movement"
const string GONDOLA_ARRIVAL_SOUND = "Vehicles_Gondola_Cart_Arrival"
const string GONDOLA_DEPARTURE_WARNING_SOUND = "Vehicles_Gondola_Cart_Departure_Warning"
const string GONDOLA_DEPARTURE_SOUND ="Vehicles_Gondola_Cart_Departure"
const string GONDOLA_MIDSTATION_ACCEL_SOUND = "Vehicles_Gondola_Midstation_Accel"
const string GONDOLA_MIDSTATION_DECEL_SOUND = "Vehicles_Gondola_Midstation_Decel"
const string GONDOLA_MIDSTATION_THROUGH_SOUND = "Vehicles_Gondola_Midstation_Thru"
const string GONDOLA_MID_TOWER_SOUND = "Vehicles_Gondola_Midstation_Tower"

const float GONDOLA_STATION_WAIT = 4.0
const float GONDOLA_STATION_LEAVE_BUFFER = 1.0
const float GONDOLA_PATH_DURATION_STANDARD = 6.0
const float GONDOLA_PATH_DURATION_EXTENDED = 14.0
const float GONDOLA_PATH_STATION_SPEED_MODIFIER = 0.5
#endif // SERVER

#if CLIENT
const float TRIGGER_TO_MODEL_RADIUS_SQR = 15000
#endif // CLIENT

#if SERVER
global enum eMoverStates
{
	MOVE_FORWARD_CURRENT_PATH,
	MOVE_FORWARD,

	_COUNT
}
#endif // SERVER

struct GondolaMoverData
{
	entity model
	entity interiorTrigger
	bool isGondolaAtStation

	#if SERVER
		entity mover
		entity startingPoint
		entity startNode

		entity audioTarget
		entity audioTargetMidstation

		array< entity > path
		array< entity > gondolaMidStationTriggers
		array< string > gondolaMidStationNodes = [ GONDOLA_NODE_MIDSTATION_A, GONDOLA_NODE_MIDSTATION_B ]
		array< string > gondolaStationNodes = [ GONDOLA_NODE_START_SCRIPTNAME, GONDOLA_NODE_END_SCRIPTNAME ]
	#endif
}


struct
{
	array< entity > initOnly_gondolas
	array< entity > initOnly_gondolaInteriorTriggers

	table< entity, GondolaMoverData > moverDatas

} file


void function GondolaMover_Init()
{
	#if SERVER
		AddSpawnCallback_ScriptName( GONDOLA_SCRIPTNAME, OnGondolaFuncBrushSpawned )
	#endif // SERVER

	#if CLIENT
		AddCreateCallback( "func_brush", OnGondolaFuncBrushSpawned )
		AddDestroyCallback( "func_brush", Cl_OnGondolaFuncBrushDestroyed )
		AddCreateCallback( "trigger_multiple_clientside", Cl_OnGondolaTriggerSpawned )
	#endif // CLIENT
}


void function OnGondolaFuncBrushSpawned( entity gondola )
{
	#if CLIENT
		if ( gondola.GetScriptName() != GONDOLA_SCRIPTNAME )
			return
	#endif // CLIENT

	file.initOnly_gondolas.append( gondola )

	GondolaMoverData data
	data.model = gondola

	// Set up Client tigger
	#if CLIENT
		array< entity > triggers = GetEntArrayByScriptName( GONDOLA_INTERIOR_TRIGGER )
		foreach( trigger in triggers)
		{
			if ( !IsValid( trigger.GetParent() ) && DistanceSqr( trigger.GetOrigin(), data.model.GetOrigin() ) < TRIGGER_TO_MODEL_RADIUS_SQR )
			{
				trigger.SetParent( data.model )
			}
		}
	#endif

	#if SERVER
		foreach ( linkEnt in data.model.GetLinkEntArray() )
		{
			string scriptName = linkEnt.GetScriptName()

			if ( scriptName == GONDOLA_INTERIOR_TRIGGER )
			{
				data.interiorTrigger = linkEnt
				file.initOnly_gondolaInteriorTriggers.append( data.interiorTrigger )
			}
			else if ( scriptName == GONDOLA_NODE_START_SCRIPTNAME )
			{
				data.startingPoint = linkEnt

				// Set up path
				data.mover = GondolaSetupMover( data.startingPoint.GetOrigin(), data.startingPoint.GetAngles() )
				data.path = GondolaSetupPath( data.startingPoint, data.mover )
			}
			else if ( scriptName == GONDOLA_MIDSTATION_TRIGGER )
			{
				data.gondolaMidStationTriggers.append( linkEnt )
				linkEnt.SetParent( data.model )
			}
		}

		if( !IsValid( data.mover ) )
			return

		// Set up audio targets and ambient generics
		entity audioTarget = CreateEntity( "prop_script" )
		audioTarget.SetOrigin( data.model.GetOrigin() )
		audioTarget.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
		DispatchSpawn( audioTarget )
		data.audioTarget = audioTarget
		data.audioTarget.SetParent( data.model )

		entity ambientGeneric = CreateEntity( "ambient_generic" )
		ambientGeneric.SetOrigin( data.model.GetOrigin() )
		ambientGeneric.SetSoundName( GONDOLA_MOTOR_SOUND )
		ambientGeneric.SetEnabled( true )
		ambientGeneric.SetParent( data.model )
		DispatchSpawn( ambientGeneric )

		// Parenting
		data.model.SetParent( data.mover )
		data.interiorTrigger.SetParent( data.mover )

		file.moverDatas[ data.mover ] <- data

		// Need to wait for loot to spawn on all gondolas before setting mover state
		FlagWait( "Survival_LootSpawned" )

		SetMoverState( data.mover, eMoverStates.MOVE_FORWARD_CURRENT_PATH )
	#endif // SERVER
}

#if CLIENT
void function Cl_OnGondolaFuncBrushDestroyed( entity ent )
{
	file.initOnly_gondolas.fastremovebyvalue( ent )
}
#endif // CLIENT

#if SERVER
entity function GondolaSetupMover( vector origin, vector angles )
{
	entity mover = CreateScriptMover_NEW( GONDOLA_MOVER_SCRIPTNAME, origin, angles )
	mover.SetPusher( true )
	//mover.SetPusherMovesNearbyVehicles( true )

	return mover
}


array< entity > function GondolaSetupPath( entity startNode, entity mover )
{
	array< entity > pathNodes
	pathNodes.append( startNode )

	entity curNode = startNode

	string curNodeName = curNode.GetScriptName()
	while ( curNodeName != GONDOLA_NODE_END_SCRIPTNAME )
	{
		array< entity > linkEnts = curNode.GetLinkEntArray()
		int numLinkEnts          = linkEnts.len()

		if ( numLinkEnts == 0 )
			break

		foreach ( ent in linkEnts )
		{
			if ( ent.GetClassName() == "info_target" )
			{
				pathNodes.append( ent )
				curNode = ent
				break
			}
		}
	}

	return pathNodes
}
#endif

#if CLIENT
void function Cl_OnGondolaTriggerSpawned( entity trigger )
{
	if ( trigger.GetScriptName() != GONDOLA_INTERIOR_TRIGGER )
		return

	if ( !file.initOnly_gondolaInteriorTriggers.contains( trigger ) )
		file.initOnly_gondolaInteriorTriggers.append( trigger )

	// Triggers may not exist when gondola spawncallback is set up, this is back up
	foreach( gondola in file.initOnly_gondolas )
	{
		if ( DistanceSqr( trigger.GetOrigin(), gondola.GetOrigin() ) < TRIGGER_TO_MODEL_RADIUS_SQR )
		{
			trigger.SetParent( gondola )
			break
		}
	}
}
#endif // CLIENT

#if SERVER
void function SetMoverState( entity mover, int desiredMoverState )
{
	switch ( desiredMoverState )
	{
		case eMoverStates.MOVE_FORWARD_CURRENT_PATH:
			thread MoverFollowPath_Thread( false, mover )
			break

		case eMoverStates.MOVE_FORWARD:
			thread MoverFollowPath_Thread( true, mover )
			break
	}
}


void function MoverFollowPath_Thread( bool shouldGetNewPath, entity mover )
{
	EndSignal( mover, "OnDestroy" )

	GondolaMoverData data = file.moverDatas[ mover ]

	if ( shouldGetNewPath )
	{
		data.path.reverse()
		data.gondolaMidStationNodes.reverse()
		data.gondolaStationNodes.reverse()
	}

	int pathLength = data.path.len()
	for ( int i = 1 ; i < pathLength; i++ )
	{
		string nodeName = data.path[ i ].GetScriptName()

		vector nodeOrigin = data.path[ i ].GetOrigin()
		float duration = GONDOLA_PATH_DURATION_STANDARD
		float accelTime = 0.0
		float decelTime = 0.0

		if ( HasMidStation( data.path ) )
		{
			if ( nodeName == data.gondolaMidStationNodes[ 0 ] )
			{
				EmitSoundOnEntity( data.audioTarget, GONDOLA_DEPARTURE_SOUND )

				accelTime = duration * GONDOLA_PATH_STATION_SPEED_MODIFIER
			}
			else if ( nodeName == data.gondolaMidStationNodes[ 1 ] )
			{
				duration = GONDOLA_PATH_DURATION_EXTENDED
				thread GondolaMidstation_Thread( duration, data.audioTarget )
				thread GondolaMidstation_Cleanup_Thread( data.gondolaMidStationTriggers, duration )
			}
			else if ( IsStationNode( nodeName )  )
			{
				decelTime = duration * GONDOLA_PATH_STATION_SPEED_MODIFIER
				thread GondolaEnterStation_Thread( duration, data.audioTarget )
			}
		}
		else
		{
			if ( IsStationNode( nodeName )  )
			 {
				 EmitSoundOnEntity( data.audioTarget, GONDOLA_MID_TOWER_SOUND )

				 decelTime = duration * GONDOLA_PATH_STATION_SPEED_MODIFIER
				 thread GondolaEnterStation_Thread( duration, data.audioTarget )
				 data.isGondolaAtStation = true
			 }
			 else
			 {
				 EmitSoundOnEntity( data.audioTarget, GONDOLA_DEPARTURE_SOUND )

				 accelTime = duration * GONDOLA_PATH_STATION_SPEED_MODIFIER
			 }
		}

		mover.NonPhysicsMoveTo( nodeOrigin, duration, accelTime, decelTime )

		wait duration

		if ( IsStationNode( nodeName ) )
			break
	}

	wait GONDOLA_STATION_WAIT

	EmitSoundOnEntity( data.audioTarget, GONDOLA_DEPARTURE_WARNING_SOUND )

	wait GONDOLA_STATION_LEAVE_BUFFER

	SetMoverState( mover, eMoverStates.MOVE_FORWARD )
	data.isGondolaAtStation = false
}


void function GondolaEnterStation_Thread( float duration, entity audioTarget )
{
	EndSignal( audioTarget, "OnDestroy" )

	// Wait 55 percent of duration
	float time = duration * 0.55
	wait time

	EmitSoundOnEntity( audioTarget, GONDOLA_ARRIVAL_SOUND )
}


void function GondolaMidstation_Thread( float duration, entity audioTarget )
{
	EndSignal( audioTarget, "OnDestroy" )

	EmitSoundOnEntity( audioTarget, GONDOLA_MIDSTATION_DECEL_SOUND )

	// Wait 20 percent of duration
	float time = duration * 0.2
	wait time

	EmitSoundOnEntity( audioTarget, GONDOLA_MIDSTATION_THROUGH_SOUND )

	wait duration - time

	EmitSoundOnEntity( audioTarget, GONDOLA_MIDSTATION_ACCEL_SOUND )
}


bool function IsStationNode( string nodeName )
{
	if ( nodeName == GONDOLA_NODE_END_SCRIPTNAME || nodeName == GONDOLA_NODE_START_SCRIPTNAME )
		return true

	return false
}


bool function HasMidStation( array< entity > moverPath )
{
	bool hasMidStation
	foreach ( node in moverPath )
	{
		if ( node.GetScriptName() == GONDOLA_NODE_MIDSTATION_A || node.GetScriptName() == GONDOLA_NODE_MIDSTATION_B )
		{
			hasMidStation = true
			break
		}
	}

	return hasMidStation
}

// Fix for R5DEV-263868 - need to clean up Caustic's dirty bombs otherwise they're pushed with the mover and can insta-kill players
void function GondolaMidstation_Cleanup_Thread( array< entity > cleanupTriggers, float duration )
{
	if ( cleanupTriggers.len() == 0 )
		return

	float startTime = Time()
	float endTime = startTime + duration

	while( Time() < endTime )
	{
		foreach( trigger in cleanupTriggers )
		{
			array<entity> touchingEnts = trigger.GetTouchingEntities()

			foreach ( touchingEnt in touchingEnts )
			{
				if ( touchingEnt.GetTargetName() == DIRTY_BOMB_TARGETNAME )
				{
					RemoveCausticDirtyBomb( touchingEnt, null )
				}

				break
			}
		}

		WaitFrame()
	}
}
#endif // SERVER

bool function IsPlayerInsideGondola( entity ent )
{
	bool playerIsInGondola = false

	//TODO: MegC: This isn't an optimal use of triggers. Should refactor to use static volume instead.
	foreach( trigger in file.initOnly_gondolaInteriorTriggers )
	{
		if ( trigger.GetTouchingEntities().contains( ent ) )
		{
			if ( ent.DoesShareRealms( trigger ) && ent.IsPlayer() )
			{
				playerIsInGondola = true
				break
			}
		}
	}

	return playerIsInGondola
}

bool function IsGondolaAtStation( entity gondola )
{
	entity mover = gondola.GetParent()
	GondolaMoverData data = file.moverDatas[ mover ]
	return data.isGondolaAtStation
}


bool function GondolasAreActive()
{
	if ( file.initOnly_gondolas.len() == 0 )
		return false

	return true
}