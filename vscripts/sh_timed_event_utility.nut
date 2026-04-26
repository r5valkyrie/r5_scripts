/*todo: MAKING SURE YOUR MODE WORKS WITH TIMED EVENTS:
	1. Make sure the GameState HUD RUI for your mode has an argument for a nested RUI named "timedEventTracker"
	2. Make sure TimedEvents_Init is called in your gamemode script
*/

global function TimedEvents_Init

#if SERVER || CLIENT
	global function TimedEvents_RegisterTimedEvent
#endif

#if SERVER
	global function TimedEvents_CancelCurrentTimedEvents
	global function TimedEvents_SetSingleScheduleVars
	global function TimedEvents_TriggerTimedEventByEventType // Trigger a timed event by its type (enum value). Used for debug or to trigger events that are not controlled by delays.
#endif

global const float TIMED_EVENT_DISPLAY_BUFFER = 10.0
const string WAYPOINTTYPE_TIMEDEVENTTRACKER = "timed_event_tracker"

const INT_EVENTTYPE =			4	// This is an int used as an identifier for the event. Can be used to trigger the event by type
global const TIMEDEVENT_WAYPOINT_INT_EVENT_PHASE = 		5	// if events need to, they can track the phase of the event through their own enums
global const TIMEDEVENT_WAYPOINT_EVENT_START_TIME = 	0
global const TIMEDEVENT_WAYPOINT_EVENT_END_TIME = 		1
global const WAYPOINT_EVENT_STRING_AWARD = 			0

#if SERVER
const float TIMED_EVENT_DEFAULT_SINGLE_SCHEDULE_START_DELAY = 90.0
const float TIMED_EVENT_DEFAULT_SINGLE_SCHEDULE_EVENT_DELAY = 150.0
#endif



//this struct isn't used for event registration, just for duplicating client data when events are created for override behavior
#if CLIENT
global struct TimedEventLocalClientData
{
	string eventName
	string eventDesc
	vector colorOverride
	bool shouldShowPreamble
	bool shouldHideUntilPrembleDone
	bool shouldHideTimer
	bool shouldAutoShowSuddenDeathText
	float eventEndTime //Used for animation
}
#endif


global struct TimedEventData
{
	int eventType = 0 // Modes set this based on their own enums for events. The event can then be triggered using the TimedEvents_TriggerTimedEventByEventType function
	#if SERVER
		bool isRepeatingEvent
		bool shouldDestroyWPOnEventEnd = true
		bool isTriggeredByFunctionCall	= false 	// Normally Timed Events trigger on a time schedule, if true, this event will not and must be triggered by the TimedEvents_TriggerTimedEventByEventType function
		bool shouldUseSingleSchedule = false 	// Events on a single schedule trigger on the same cadence and can have a randomized order or replace each other in case of start failures
		void functionref( TimedEventData, entity ) timedEventFunctionThread
		float startTimeDelay 	//determines time delay until event starts (from start time of appropriate gamestate)
		float repeatInterval 	//determines repeat delay between events if event is Repeating
		float eventLength 	//determines length of event
		int gamestateActivation	= eGameState.Playing	//determines what gamestate the timed event occurs in

		bool functionref( float ) timedEventFunctionStartValidation
		bool shouldCancelOtherTimedEvents = false
	#endif

	#if CLIENT
		string eventName      //specified either in the timedevent setup, or driven by the override function
		string eventDesc	  //specified either in the timedevent setup, or driven by the override function
		vector colorOverride //specified either in the timedevent setup, or driven by the override function

		void functionref( entity, TimedEventLocalClientData )		infoOverrideFunctionThread
	#endif

	bool 	shouldHideUntilPrembleDone = false				// detemines if we show the premble if using it
	bool   	shouldShowPreamble = true				//determines if we signal "event beginning in... "
	bool 	shouldHideTimer = false // Determines whether we display a timer on the timed event info pane while the event is active
	bool 	shouldAutoShowSuddenDeathText = true // If the event time is at 0 but the event is still active, automatically display sudden death text
}




struct
{
	bool enabled = false

	array<TimedEventData>		timedEvents
	table<int, TimedEventData>	eventTypeToTimedEvent
	table<TimedEventData, int>	timedEventToEventType

	#if SERVER
		bool didSetSingleScheduleVars = false
		bool shouldTriggerBackupEventsOnSingleSchedule = false
		bool shouldRandomizeOrderOnSingleSchedule = false
		float singleScheduleStartDelay = TIMED_EVENT_DEFAULT_SINGLE_SCHEDULE_START_DELAY
		float singleScheduleTimeBetweenEvents = TIMED_EVENT_DEFAULT_SINGLE_SCHEDULE_EVENT_DELAY
	#endif // SERVER

	#if CLIENT
		var 										timedEventRui
		table<int, entity>							eventTypeToWaypoint
		table<entity, TimedEventLocalClientData >	waypointToLocalData
	#endif
}
file

void function TimedEvents_Init()
{
	file.enabled = true

	#if SERVER
		RegisterSignal( "TimedEvents_CancelTermination" )
		RegisterSignal( "TimedEvents_GameStateTermination" )
		RegisterSignal( "StopTimedEvents" )
		RegisterSignal( "EventEnd" )
		AddCallback_GameStateEnter( eGameState.Playing, OnGameStatePlaying_TimedEvents )
		AddCallback_GameStateEnter( eGameState.Epilogue, OnGamestateEpilogue_TimedEvents )
	#endif

	#if CLIENT
		Waypoints_RegisterCustomType( WAYPOINTTYPE_TIMEDEVENTTRACKER, InstanceWPTimedEventTracker )
		AddCallback_GameStateEnter( eGameState.Playing, OnGamestatePlaying_TimedEvents_Client )
		AddCallback_GameStateEnter( eGameState.Epilogue, OnGamestateEpilogue_TimedEvents_Client )
	#endif
}

#if SERVER || CLIENT
void function TimedEvents_RegisterTimedEvent( TimedEventData data )
{
	Assert( file.enabled, "TimedEvents not initailized, Check the gamemode's initialization setup" )
	if ( !file.enabled )
		return

	int timedEventType = data.eventType

	if ( timedEventType in file.eventTypeToTimedEvent )
	{
		#if DEV
			Assert( false, "Timed Events: eventType: " + timedEventType + " already exists for a registered Timed Event. Make sure to set a unique eventType int for each Timed Event when registering them." )
		#endif // DEV
		return
	}

	file.timedEvents.append( data )
	file.eventTypeToTimedEvent[ timedEventType ] <- data
	file.timedEventToEventType[ data ] <- timedEventType
}
#endif


#if SERVER
// Set vars to be used by events that work on a single repeating schedule
void function TimedEvents_SetSingleScheduleVars( bool shouldTriggerBackupEventsOnSingleSchedule, bool shouldRandomizeOrderOnSingleSchedule, float singleScheduleStartDelay, float singleScheduleTimeBetweenEvents )
{
	Assert( file.enabled, "TimedEvents not initailized, Check the gamemode's initialization setup" )
	if ( !file.enabled )
		return

	Assert( singleScheduleStartDelay > TIMED_EVENT_DISPLAY_BUFFER, "Timed Events: Trying to set singleScheduleStartDelay with a time value that is less than or equal to the event display buffer of " + TIMED_EVENT_DISPLAY_BUFFER )
	Assert( singleScheduleTimeBetweenEvents > TIMED_EVENT_DISPLAY_BUFFER, "Timed Events: Trying to set singleScheduleTimeBetweenEvents with a time value that is less than or equal to the event display buffer of " + TIMED_EVENT_DISPLAY_BUFFER )

	file.shouldTriggerBackupEventsOnSingleSchedule = shouldTriggerBackupEventsOnSingleSchedule
	file.shouldRandomizeOrderOnSingleSchedule = shouldRandomizeOrderOnSingleSchedule
	file.singleScheduleStartDelay = singleScheduleStartDelay
	file.singleScheduleTimeBetweenEvents = singleScheduleTimeBetweenEvents
	file.didSetSingleScheduleVars = true

	#if DEV
		printf( "Timed Events: Set Single Schedule Vars" )
	#endif // DEV
}
#endif // SERVER

#if SERVER
void function OnGameStatePlaying_TimedEvents()
{
	thread TimedEvent_ManagementThread( eGameState.Playing )
}
#endif // SERVER

#if SERVER
void function OnGamestateEpilogue_TimedEvents()
{
	thread TimedEvent_ManagementThread( eGameState.Epilogue )
}
#endif // SERVER

#if SERVER
void function TimedEvent_ManagementThread( int gamestate )
{
	EndSignal( svGlobal.levelEnt, "StopTimedEvents" )
	float startTime = Time()

	array< TimedEventData > singleScheduleEvents

	//add all registered timed events to the register so we can track the last time they triggered, -1 means hasn't triggered yet
	table< TimedEventData, float > timedEventStartRegister
	int uniqueScheduleTimedEventsCount = 0

	foreach ( event in file.timedEvents )
	{
		// Don't schedule events that are triggered by a function call. Gamemodes are responsible for triggering these using the TimedEvents_TriggerTimedEventByEventType function
		if ( event.isTriggeredByFunctionCall )
			continue

		if ( event.gamestateActivation == gamestate ) //only register events for the appropriate gamestate
		{
			// Seperate events into ones that follow a single schedule and ones that have their own unique schedule to follow.
			if ( event.shouldUseSingleSchedule )
			{
				singleScheduleEvents.append( event )
			}
			else
			{
				timedEventStartRegister[ event ] <- -1
				uniqueScheduleTimedEventsCount++
			}
		}
	}

	thread TimedEvent_ManageSingleScheduleEvents_Thread( singleScheduleEvents, gamestate )

	if ( uniqueScheduleTimedEventsCount > 0 ) // There are timed events on a unique schedule so check if they should trigger every frame on a loop
	{
		while ( GetGameState() == gamestate )
		{
			float currentTime = Time()

			table< TimedEventData, float > timedEventStartRegisterClone = clone timedEventStartRegister
			foreach( event, lastTrigger in timedEventStartRegister )
			{
				if ( event.timedEventFunctionStartValidation != null )
				{
					if ( !event.timedEventFunctionStartValidation( event.eventLength ) ) //skip event if validation not met
						continue
				}

				bool shouldTriggerThisFrame = false
				bool shouldCreateWaypointThisFrame = false

				float timeBaseline = -1
				float timeEventBuffer = -1
				if ( lastTrigger == -1 )
				{
					//event has not triggered yet, use initial start conditions
					timeBaseline = startTime
					timeEventBuffer = event.startTimeDelay
				}
				else
				{
					//check if event is repeating
					if ( !event.isRepeatingEvent )
						continue

					timeBaseline = lastTrigger
					timeEventBuffer = event.repeatInterval
				}

				float soonestEventStartTime = 			timeBaseline + timeEventBuffer
				float soonestEventDisplayTime = 		soonestEventStartTime
				if ( event.shouldShowPreamble )
					soonestEventDisplayTime -= TIMED_EVENT_DISPLAY_BUFFER

				//check if we should create a start waypoint
				if ( currentTime >= soonestEventDisplayTime )
					shouldCreateWaypointThisFrame = true

				//complete actions if we should be making a waypoint
				if ( shouldCreateWaypointThisFrame )
				{
					#if DEV
						printf( "Timed Events: Triggering Unique Schedule Timed Event" )
					#endif // DEV

					float trueEventStartTime = currentTime
					float trueEventDisplayTime = currentTime

					if ( event.shouldShowPreamble )
						trueEventStartTime = trueEventDisplayTime + TIMED_EVENT_DISPLAY_BUFFER

					float trueEventEndTime = trueEventStartTime + event.eventLength

					thread TimedEvent_KickoffThread( event, trueEventStartTime, trueEventDisplayTime, trueEventEndTime )
					timedEventStartRegisterClone[ event ] <- trueEventStartTime
				}
			}

			timedEventStartRegister = timedEventStartRegisterClone

			WaitFrame()
		}
	}
	else // There are no unique schedule timed events to manage. Just manage the gamestate termination signal
	{
		#if DEV
			printf( "Timed Events: There are no unique schedule timed events going to wait for gamestate change" )
		#endif // DEV

		WaittillGameStateOrHigher( gamestate + 1 )
	}

	#if DEV
		printf( "Timed Events: Reached Gamestate triggered event termination" )
	#endif // DEV

	svGlobal.levelEnt.Signal( "TimedEvents_GameStateTermination" )
}
#endif // SERVER

#if SERVER
// Manage the triggering of events that work off of a single schedule. These events can be randomized and can trigger events for backup if an event fails to trigger
void function TimedEvent_ManageSingleScheduleEvents_Thread( array< TimedEventData > events, int gamestate )
{
	// Don't bother doing anything if there are no events
	if ( events.len() <= 0 )
		return

	EndSignal( svGlobal.levelEnt, "StopTimedEvents" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_GameStateTermination" )

	Assert( file.didSetSingleScheduleVars, "Trying to Run TimedEvent_ManageSingleScheduleEvents_Thread but single schedule vars were not set using TimedEvents_SetSingleScheduleVars" )

	// Wait the intial start delay
	wait file.singleScheduleStartDelay - TIMED_EVENT_DISPLAY_BUFFER

	array< TimedEventData > eventPool = clone events

	// Randomize events if that's what was set
	if ( file.shouldRandomizeOrderOnSingleSchedule )
		eventPool.randomize()

	float currentTime
	float timeBetweenEvents = file.singleScheduleTimeBetweenEvents - TIMED_EVENT_DISPLAY_BUFFER

	array< TimedEventData > nextEventPool // put repeatable events in here, and when we run out of events we move this pool over

	// Trigger the events on the single schedule
	while ( eventPool.len() > 0 )
	{
		#if DEV
			printf( "Timed Events: Going to try to trigger a single schedule timed event" )
		#endif // DEV

		currentTime = Time()

		// Find a valid event to trigger
		TimedEventData currentEvent
		bool didFindValidEvent = false
		array< TimedEventData > eventsToRemoveFromPool

		foreach( event in eventPool )
		{
			// Add all events that get tested ( whether they pass or fail validation tests) to be removed from the event pool so it can refresh properly.
			// If we don't do this logic we can end up with a very small pool of events to try to use as backups if the event meant to trigger fails.
			eventsToRemoveFromPool.append( event )
			if ( event.timedEventFunctionStartValidation == null || event.timedEventFunctionStartValidation != null && event.timedEventFunctionStartValidation( event.eventLength ) )
			{
				currentEvent = event
				didFindValidEvent = true
				break
			}
			else if ( !file.shouldTriggerBackupEventsOnSingleSchedule )
			{
				break
			}
		}

		foreach( event in eventsToRemoveFromPool )
		{
			eventPool.removebyvalue( event )
			if ( event.isRepeatingEvent )
				nextEventPool.append( event )
		}

		if ( eventPool.len() <= 0 )
		{
			eventPool = clone nextEventPool

			// Randomize events if that's what was set
			if ( file.shouldRandomizeOrderOnSingleSchedule )
				eventPool.randomize()

			nextEventPool.clear()
		}

		if ( didFindValidEvent )
		{
			#if DEV
				printf( "Timed Events: Triggering a single schedule timed event" )
			#endif // DEV

			float trueEventStartTime = currentTime
			float trueEventDisplayTime = currentTime

			if ( currentEvent.shouldShowPreamble )
				trueEventStartTime += TIMED_EVENT_DISPLAY_BUFFER

			float trueEventEndTime = trueEventStartTime + currentEvent.eventLength

			thread TimedEvent_KickoffThread( currentEvent, trueEventStartTime, trueEventDisplayTime, trueEventEndTime )
		}
		else
		{
			#if DEV
				printf( "Timed Events: Didn't find a valid single schedule timed event to trigger" )
			#endif // DEV
		}
		#if DEV
			printf( "Timed Events: Going to wait for the next single schedule timed event. Wait Time: " + timeBetweenEvents )
		#endif // DEV

		wait timeBetweenEvents
	}
}
#endif // SERVER

#if SERVER
void function TimedEvent_KickoffThread( TimedEventData event, float eventStartTime, float eventDisplayStartTime, float eventEndTime )
{
	// Check if event will pass validation before triggering the countdown
	if ( event.timedEventFunctionStartValidation != null )
	{
		if ( !event.timedEventFunctionStartValidation( event.eventLength ) )
			return
	}

	if ( event.shouldCancelOtherTimedEvents )
		TimedEvents_CancelCurrentTimedEvents()

	if ( !IsValid( svGlobal.levelEnt ) )
		return

	EndSignal( svGlobal.levelEnt, "GameEnd" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_GameStateTermination" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_CancelTermination" )

	entity wp = CreateWaypoint_Custom( WAYPOINTTYPE_TIMEDEVENTTRACKER )
	wp.SetWaypointInt( INT_EVENTTYPE, file.timedEventToEventType[ event ] )
	wp.SetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME, eventStartTime )
	wp.SetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME, eventEndTime )
	thread TimedEvent_WaypointCleanupThread( wp, event )

	while ( Time() < eventStartTime )
		WaitFrame()

	// Check if the event will pass validation again once the countdown is done
	if ( event.timedEventFunctionStartValidation != null )
	{
		// terminate event if validation not met
		if ( !event.timedEventFunctionStartValidation( event.eventLength ) )
		{
			Signal( wp, "EventEnd" )
			return
		}
	}

	thread event.timedEventFunctionThread( event, wp )
}
#endif // SERVER

#if SERVER
void function TimedEvent_WaypointCleanupThread( entity wp, TimedEventData data )
{
	EndSignal( svGlobal.levelEnt, "GameEnd" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_GameStateTermination" )
	EndSignal( svGlobal.levelEnt, "TimedEvents_CancelTermination" )
	EndSignal( wp, "EventEnd" )

	OnThreadEnd(
		function() : ( data, wp )
		{
			if ( IsValid( wp ) )
				wp.Destroy()
		}
	)

	wait data.eventLength

	if ( !data.shouldDestroyWPOnEventEnd )
		WaitForever()
}
#endif // SERVER

#if SERVER
void function TimedEvents_CancelCurrentTimedEvents()
{
	svGlobal.levelEnt.Signal( "TimedEvents_CancelTermination" )
}
#endif // SERVER

#if CLIENT
void function InstanceWPTimedEventTracker( entity wp )
{
	if ( !IsValid( wp ) )
		return

	if ( wp.GetWaypointCustomType() != WAYPOINTTYPE_TIMEDEVENTTRACKER )
		return

	int eventType = wp.GetWaypointInt( INT_EVENTTYPE )
	file.eventTypeToWaypoint[ eventType ] <- wp

	TimedEventData event = file.eventTypeToTimedEvent[eventType]
	TimedEventLocalClientData localData
	localData.eventName = event.eventName
	localData.eventDesc = event.eventDesc
	localData.colorOverride = event.colorOverride
	localData.shouldShowPreamble = event.shouldShowPreamble
	localData.shouldHideUntilPrembleDone = event.shouldHideUntilPrembleDone
	localData.shouldHideTimer = event.shouldHideTimer
	localData.shouldAutoShowSuddenDeathText = event.shouldAutoShowSuddenDeathText
	localData.eventEndTime = 0

	file.waypointToLocalData[ wp ] <- localData

	if ( event.infoOverrideFunctionThread != null )
	{
		thread event.infoOverrideFunctionThread( wp, localData )
	}
}
#endif // CLIENT

#if CLIENT
void function OnGamestatePlaying_TimedEvents_Client()
{
	thread ManageTimedEventTracker( ClGameState_GetRui(), eGameState.Playing )
}
#endif // CLIENT

#if CLIENT
void function OnGamestateEpilogue_TimedEvents_Client()
{
	thread ManageTimedEventTracker( ClGameState_GetRui(), eGameState.Epilogue )
}
#endif // CLIENT

#if CLIENT
void function ManageTimedEventTracker( var gameStateRui, int gamestate )
{
	#if DEV
		printf( "Timed Events: starting management thread on client for gamestate " + gamestate )
	#endif // DEV

	if ( file.timedEventRui != null )
		return

	int numTrackers = 5 //should always match RUI
	array<var>		trackerRuis
	table<entity, int> assignedWaypoints

	var trackerContainer = RuiCreateNested( gameStateRui, "timedEventTracker", $"ui/timed_event_tracker_container.rpak" )
	file.timedEventRui = trackerContainer

	for( int i = 0; i<numTrackers; i++ )
	{
		var eventRui = RuiCreateNested( trackerContainer, "tracker" + i, $"ui/timed_event_tracker.rpak" )
		trackerRuis.append( eventRui )
	}


	while ( GetGameState() == gamestate )
	{
		array<entity> waypointsAssignedThisFrame

		//clear invalid waypoints
		table<entity, int> eventTypeTrackerCopy = clone assignedWaypoints
		foreach( wp, eventType in eventTypeTrackerCopy )
		{

			if ( !IsValid( wp ) && file.waypointToLocalData[ wp ].eventEndTime == 0 )
				file.waypointToLocalData[ wp ].eventEndTime = Time() + 0.5 // Exist for at least 0.5 more seconds
			else if ( !IsValid( wp ) && Time() > file.waypointToLocalData[ wp ].eventEndTime )
				delete assignedWaypoints[ wp ]
		}

		//add any valid waypoints that are not assigned
		foreach( eventType, wp in file.eventTypeToWaypoint )
		{
			if ( !( wp in assignedWaypoints ) && IsValid( wp ) )
			{
				assignedWaypoints[ wp ] <- eventType
				waypointsAssignedThisFrame.append( wp )
			}
		}

		//populate RUI information
		int i = 0
		foreach( wp, eventType in assignedWaypoints )
		{
			if ( i >= trackerRuis.len() )
				break

			var rui = trackerRuis[i]
			TimedEventLocalClientData localData = file.waypointToLocalData[ wp ]

			if ( IsValid( wp ) )
			{
				if ( !localData.shouldShowPreamble && Time() < wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME ) )
					continue
			}

			RuiSetBool( rui, "shouldShow", true )
			RuiSetString( rui, "eventName", localData.eventName )
			RuiSetString( rui, "eventDesc", localData.eventDesc )
			RuiSetBool( rui, "shouldShowPreamble", localData.shouldShowPreamble )
			RuiSetBool( rui, "shouldHideUntilPrembleDone", localData.shouldHideUntilPrembleDone )
			RuiSetBool( rui, "shouldHideTimer", localData.shouldHideTimer )
			RuiSetBool( rui, "shouldAutoShowSuddenDeathText", localData.shouldAutoShowSuddenDeathText )
			RuiSetFloat3( rui, "colorOverride", SrgbToLinear( localData.colorOverride / 255.0 ) )
			RuiSetFloat( rui, "animateOutEndTime", localData.eventEndTime )

			if ( IsValid( wp ) )
			{
				RuiSetString( rui, "award", wp.GetWaypointString( WAYPOINT_EVENT_STRING_AWARD ))
				RuiSetGameTime( rui, "startTime", wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_START_TIME ) )
				RuiSetGameTime( rui, "endTime", wp.GetWaypointGametime( TIMEDEVENT_WAYPOINT_EVENT_END_TIME ) )
			}

			i++
		}

		for( int j = i; j < trackerRuis.len(); j++ )
		{
			var rui = trackerRuis[j]
			RuiSetBool( rui, "shouldShow", false )
			RuiSetFloat3( rui, "colorOverride", <1,1,1> )
		}


		RuiSetInt( trackerContainer, "numTrackersShown", i )


		WaitFrame()
	}

	//tear down individual trackers
	for( int i = 0; i<numTrackers; i++ )
	{
		RuiDestroyNestedIfAlive( trackerContainer, "tracker" + i )
	}
	trackerRuis.clear()

	//tear down RUI
	RuiDestroyNestedIfAlive( gameStateRui, "timedEventTracker" )
	file.timedEventRui = null
}
#endif // CLIENT

#if SERVER
// Trigger a timed event by its index. This is used for debug and to trigger events that are based around other conditions ( not on delay like most timed events).
// NOTE: The index is determined by the order timed events are registered in
void function TimedEvents_TriggerTimedEventByEventType( int eventType )
{
	if ( eventType in file.eventTypeToTimedEvent )
	{

		TimedEventData event = file.eventTypeToTimedEvent[ eventType ]

		#if DEV
			printf( "Timed Events: TimedEvents_TriggerTimedEventByEventType triggered for eventType: " + eventType )
		#endif // DEV

		float trueStartTime = Time()
		if ( event.shouldShowPreamble )
			trueStartTime += TIMED_EVENT_DISPLAY_BUFFER

		thread TimedEvent_KickoffThread( event, trueStartTime, Time(), trueStartTime + event.eventLength )
	}
	else
	{
		#if DEV
			printf( "Timed Events: TimedEvents_TriggerTimedEventByEventType passed in eventType: " + eventType + " is not valid. Below are the current registered timed events:" )

			foreach ( key, value in file.eventTypeToTimedEvent )
			{
				printf( "EventType: " + key )
			}
		#endif // DEV
	}
}
#endif // SERVER 