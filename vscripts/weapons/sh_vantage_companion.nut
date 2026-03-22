global function VantageCompanion_Init


global function VantageCompanion_GetEnt
global function VantageCompanion_FindAndDisplayOrderPos
global function VantageCompanion_OrderCompanion
global function VantageCompanion_SetPlayerLaunchState
global function VantageCompanion_GetPlayerLaunchState

//Launch
//global function Launch_CalcLaunchVelocity
global function Launch_CalcLaunchToPos
//global function Launch_CalcTravelTime
//global function Launch_CalcPosOnTraj

#if CLIENT
global function GetVantageTacticalRui
global function CreateVantageTacticalRui_Internal
global function DestroyVantageTacticalRui
global function TrackVantageAnimatedTacticalRuiOffhandWeapon
#endif

#if SERVER
global function VantageCompanion_Deploy
global function VantageCompanion_Destroy
global function VantageCompanion_ShowAndSetToShoulder


global function ClientCallback_VantageCompanion_Recall
#endif

////////////////////////////////////////////////

// Model
const asset VANTAGE_COMPANION_MODEL = $"mdl/creatures/echo/echo_base_w.rmdl"
const float VANTAGE_COMPANION_MODEL_SCALE = 1.5

global const string VANTAGE_COMPANION_SCRIPTNAME = "vantage_companion"

// Sound
const string SOUND_COMPANION_RECALL_VOICE = "Vantage_Tac_Echo_Voice_Recall"
const string SOUND_COMPANION_PERCH_VOICE = "Vantage_Tac_Holster"

//const string SOUND_COMPANION_REACTION = "frenchfry_large_action_3"//"Fuse_Binocs_Tag_Enemy_1p"

// FX
const FX_COMPANION_TRAIL = $"P_van_tac_echo_trail"
const FX_COMPANION_TRAIL_ENEMY = $"P_van_tac_echo_trail_enemy"
const FX_COMPANION_ORDER_AR_GROUND = $"P_van_tac_echo_AR_ping_ground"
const FX_COMPANION_ORDER_AR_WALL = $"P_van_tac_echo_AR_ping_CP"
const FX_COMPANION_ORDER_AR_CORNER = $"P_van_tac_echo_AR_ping_wall_dir"//"P_van_tac_echo_AR_ping_corner"
const FX_COMPANION_ORDER_AR_CORNER_TOP = $"P_van_tac_echo_AR_ping_wall_top"//"P_van_tac_echo_AR_ping_corner"
const FX_COMPANION_ORDER_AR_AIR = $"P_van_tac_echo_AR_ping_air"


const asset FX_PROJECTILE_DESTROYED = $"P_projectile_melted"

const asset FX_LOC_LINE = $"P_van_tac_echo_AR_line"
const asset FX_LOC_LINE_END = $"P_van_tac_echo_AR_end"

const float COMPANION_AR_MARKER_LIFETIME = 2.0
const float COMPANION_AR_SPEED_THRESHOLD_SQR = 100 * 100
//Mods

////////Tuning

//Launch
const float LAUNCH_TARGET_UP_OFFSET = -1.75 * METERS_TO_INCHES
const float LAUNCH_TARGET_FWD_OFFSET = 0 * METERS_TO_INCHES
//const float LAUNCH_MIN_TIME_DIST = 15
//const float LAUNCH_MAX_TIME_DIST = 60
//const float LAUNCH_MIN_TIME = 1
//const float LAUNCH_MAX_TIME = 1


const float VANTAGE_COMPANION_BASE_SPEED = 1200
//const float VANTAGE_COMPANION_UP_SPEED = 100
//const vector VANTAGE_COMPANION_OVERWATCH_OFFSET = <200, 0, 300>
const float VANTAGE_COMPANION_ANG_ACCEL_LOW_SPEED = 180 //deg/s
const float VANTAGE_COMPANION_ANG_ACCEL_MAX_SPEED = 360 //deg/s

const float VANTAGE_COMPANION_LOW_SPEED_THRESHOLD = 75
const float VANTAGE_COMPANION_SLOW_DOWN_RANGE = 8.0 * METERS_TO_INCHES
const float VANTAGE_COMPANION_CLOSE_TO_DESTINATION_DIST = 12

const float ECHO_ORDER_LEDGE_CHECK_UP = 2.5 * METERS_TO_INCHES
const float ECHO_ORDER_LEDGE_CHECK_BACK = 1 * METERS_TO_INCHES
const float ECHO_ORDER_MIN_HEIGHT = 6 * METERS_TO_INCHES

const int ECHO_ORDER_TRACE_COL_MASK = TRACE_MASK_PLAYERSOLID
const int ECHO_ORDER_TRACE_COL_GRP = TRACE_COLLISION_GROUP_PLAYER_MOVEMENT

const vector VANTAGE_COMPANION_BOUND_MINS = <-10, -10, -10>
const vector VANTAGE_COMPANION_BOUND_MAXS = <10, 10, 15>


const float VANTAGE_COMPANION_RANGE_BASE = 40.0 * METERS_TO_INCHES
const float VANTAGE_COMPANION_RANGE_MAX = 55.0 * METERS_TO_INCHES

//const float VANTAGE_COMPANION_TARGET_RANGE_PCT = 0.4
//const float VANTAGE_COMPANION_TARGET_RANGE_MAX = 60 * METERS_TO_INCHES
//const float VANTAGE_COMPANION_TARGET_Z_OFFSET = 150

const float VANTAGE_COMPANION_PERCHED_RANGE = 60
const float VANTAGE_COMPANION_ICON_FADE_DIST_NEAR = 3 * METERS_TO_INCHES

const float  VANTAGE_COMPANION_GROUND_UI_MIN_DIST = 6 * METERS_TO_INCHES
const float  VANTAGE_COMPANION_GROUND_UI_MIN_DIST_SQR = VANTAGE_COMPANION_GROUND_UI_MIN_DIST * VANTAGE_COMPANION_GROUND_UI_MIN_DIST

const float  VANTAGE_COMPANION_RETREAT_DIST = 3 * METERS_TO_INCHES

const string VANTAGE_COMPANION_USE_PATHFINDING_PLAYLIST_VAR = "vantage_companion_use_pathfinding"
const string VANTAGE_COMPANION_HIGHT_ADJUST_INITIAL_ORDER_PLAYLIST_VAR = "vantage_companion_initial_height_adjust"
const string VANTAGE_COMPANION_ENABLE_SIMPLE_PATHFIND_PLAYLIST_VAR = "vantage_companion_enable_simple_pathfind"
const string VANTAGE_COMPANION_ENABLE_SIMPLE_PATHFIND_COMBAT_PLAYLIST_VAR = "vantage_companion_enable_simple_pathfind_combat"
const string VANTAGE_COMPANION_PATHFIND_DURING_COMBAT_PLAYLIST_VAR = "vantage_companion_pathfind_during_combat"
const string VANTAGE_COMPANION_PATHFIND_MAX_LENGTH_RATIO_PLAYLIST_VAR = "vantage_companion_pathfind_max_ratio"
const string VANTAGE_COMPANION_PATHFIND_MAX_TIME_DIFF_PLAYLIST_VAR = "vantage_companion_pathfind_max_diff"

global const string VANTAGE_COMPANION_PATHFINDING_ROUTE_CLEARED_SIGNAL = "vantage_companion_pathfinding_route_cleared"
const float VANTAGE_COMPANION_PATHFINDING_NODE_COMPLETION_DIST = 16
const int VANTAGE_COMPANION_PATHFINDING_BAIL_CONDITION = ePathfindingBailCondition.TIME_AND_RATIO

const int VANTAGE_COMPANION_MAX_PATH_LEN = 30
const float VANTAGE_COMPANION_INIT_HEIGHT_OFFSET = 50
const float VANTAGE_COMPANION_FINAL_HEIGHT_OFFSET = -20
const float VANTAGE_COMPANION_ENTER_DOOR_HEIGHT = 70
const float VANTAGE_COMPANION_DOOR_ERROR_RADIUS = 12
const float VANTAGE_COMPANION_NEAR_POINT_DIST = 1.75 * METERS_TO_INCHES
const int VANTAGE_COMPANION_MAX_LOOK_AHEAD = 5

//Network
global const string VANTAGE_COMPANION_STATE_NETINT = "vantage_companion_state"
const string VANTAGE_COMPANION_ENT_NETVAR = "vantage_companion_ent"

//////////////////////////
/// DEBUGGING
#if DEVELOPER
global function DEV_VantageCompanion_SetDebugDraw
global function DEV_VantageCompanion_SetOrderDebugDraw

bool VANTAGE_COMPANION_DEBUG_DRAW = false
bool VANTAGE_COMPANION_ORDER_DEBUG_DRAW = false
bool VANTAGE_COMPANION_FOLLOW_DEBUG_DRAW = false
bool VANTAGE_COMPANION_VORTEX_DEBUG_DRAW = false
bool VANTAGE_COMPANION_LAUNCH_DEBUG_DRAW = false
#endif //DEVELOPER


#if DEVELOPER
array<string> sCompanionStateStrings =
[
	"Unknown"
	"Perched",
	"Recalling",
	"Ordered to Position",
	"Ordered to Target",
	"At Position"
]
#endif


#if DEVELOPER
array<string> sPlayerLaunchStateStrings =
[
	"None"
	"Prelaunching",
	"Launching"
]
#endif


struct EchoCompanionData
{
	int    playerLaunchState

	#if SERVER
		entity targetEntity
		vector ornull orderPosOrNull

		float  lastDamageTime		//Are these three still used?
		vector lastCachedSendPos
		vector lastCachedSendARPos

	#endif
}

array<string> sOrderTypeStrings =
[
	"None"
	"GROUND",
	"WALL",
	"AIR",
	"CORNER"
]

enum eOrderType
{
	NONE,

	GROUND,
	WALL,
	AIR,
	CORNER
}

struct OrderPosData
{
	vector orderPos
	vector arPos
	vector arNormal
	vector arPosSecondary
	vector arNormalSecondary
	int		orderType
}

struct
{
	table<entity, CompanionData> companionData
	table<entity, EchoCompanionData> echoData

	float TUNING_VANTAGE_COMPANION_RANGE_BASE
	float TUNING_VANTAGE_COMPANION_RANGE_MAX
                    
	float TUNING_VANTAGE_COMPANION_UPGRADED_RANGE
      

	var vantageTacticalRui

	int   previousCompanionState
	float recallStartDistanceTo = 0
} file


void function VantageCompanion_Init()
{
	PrecacheModel( VANTAGE_COMPANION_MODEL )
	PrecacheParticleSystem( FX_COMPANION_TRAIL )
	PrecacheParticleSystem( FX_COMPANION_TRAIL_ENEMY )
	PrecacheParticleSystem( FX_PROJECTILE_DESTROYED )
	PrecacheParticleSystem( FX_COMPANION_ORDER_AR_GROUND )
	PrecacheParticleSystem( FX_COMPANION_ORDER_AR_WALL )
	PrecacheParticleSystem( FX_COMPANION_ORDER_AR_CORNER )
	PrecacheParticleSystem( FX_COMPANION_ORDER_AR_CORNER_TOP )
	PrecacheParticleSystem( FX_COMPANION_ORDER_AR_AIR )

	PrecacheParticleSystem( FX_LOC_LINE )
	PrecacheParticleSystem( FX_LOC_LINE_END )

	PrecacheScriptString( VANTAGE_COMPANION_SCRIPTNAME )

	RegisterSignal( "EndCompanionLifetime_Signal" )
	RegisterSignal( VANTAGE_COMPANION_PATHFINDING_ROUTE_CLEARED_SIGNAL )

	file.TUNING_VANTAGE_COMPANION_RANGE_BASE = GetCurrentPlaylistVarFloat( "vantage_tactical_base_range", VANTAGE_COMPANION_RANGE_BASE )
	file.TUNING_VANTAGE_COMPANION_RANGE_MAX = GetCurrentPlaylistVarFloat( "vantage_tactical_max_range", VANTAGE_COMPANION_RANGE_MAX )
	                    
	file.TUNING_VANTAGE_COMPANION_UPGRADED_RANGE = GetCurrentPlaylistVarFloat( "vantage_tactical_upgraded_range_bonus", 10 * METERS_TO_INCHES )
       

	#if DEVELOPER
	Assert( eCompanionState.COUNT == sCompanionStateStrings.len(), "Must define a string for each state." )
	Assert( ePlayerLaunchState.COUNT == sPlayerLaunchStateStrings.len(), "Must define a string for each state." )
	#endif

	Remote_RegisterServerFunction( "ClientCallback_VantageCompanion_Recall" )

	RegisterNetworkedVariable( VANTAGE_COMPANION_STATE_NETINT, SNDC_PLAYER_EXCLUSIVE, SNVT_INT , eCompanionState.UNKNOWN )
	RegisterNetworkedVariable( VANTAGE_COMPANION_ENT_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_ENTITY )


#if CLIENT
	AddCreateCallback( "script_mover", VantageCompanion_OnPropScriptCreated )
	RegisterConCommandTriggeredCallback( "+scriptCommand5", AttemptRecallCompanion )
	AddCallback_OnWeaponStatusUpdate( VantageCompanion_WeaponStatusCheck )

	AddCallback_CreatePlayerPassiveRui( CreateVantageTacticalRui_Internal )
	AddCallback_DestroyPlayerPassiveRui( DestroyVantageTacticalRui )
#endif
}

float function VantageCompanion_GetRangeBase( entity owner )
{
	float result = file.TUNING_VANTAGE_COMPANION_RANGE_BASE
	                    
	if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) )
	{
		result += file.TUNING_VANTAGE_COMPANION_UPGRADED_RANGE
	}
       

	return result
}

float function VantageCompanion_GetRangeMax( entity owner )
{
	float result = file.TUNING_VANTAGE_COMPANION_RANGE_MAX

	                    
	if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) )
	{
		result += file.TUNING_VANTAGE_COMPANION_UPGRADED_RANGE
	}
       

	return result
}

float function VantageCompanion_GetSpeed( entity owner )
{
	float result = VANTAGE_COMPANION_BASE_SPEED

	                    
		if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) )
		{
			result *= 1.15
		}
       

	return result
}

const float UPDATE_RATE = 0.1


OrderPosData function FindEchoOrderPos( entity player )
{
	OrderPosData orderPosData
#if SERVER
	CompanionData currentCompanionData 		= file.companionData[player]
	EchoCompanionData currentEchoData 		= file.echoData[player]
#endif //SERVER

	#if DEVELOPER
		int devTraces = 0 //dev tracking
	#endif //#if DEVELOPER

	////////////////////////////////
	/// Find our initial test position.
	vector startTraceInitial = player.EyePosition()
	vector playerViewVector  = player.GetPlayerOrNPCViewVector()
	vector endTraceInitial   = startTraceInitial + playerViewVector * VantageCompanion_GetRangeBase( player )

	TraceResults trInitial = TraceLine( startTraceInitial, endTraceInitial, [ player ], TRACE_MASK_PLAYERSOLID , ECHO_ORDER_TRACE_COL_GRP, player )

	#if DEVELOPER
	if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
	{
		//DebugDrawLine( startTraceInitial, endTraceInitial, <255, 255, 0>, false, 5.0 )
		//DebugDrawLine( startTraceInitial, trInitial.endPos, <0, 255, 0>, false, 5.0 )
		//DebugDrawSphere( trInitial.endPos, 3, <0, 255, 0>, false, 5.0 )

		string text = VM_NAME()
		DebugDrawText( trInitial.endPos - <0,0,15> , text, true, 5.0 )
	}
	#endif

	#if DEVELOPER
		devTraces++
	#endif //#if DEVELOPER

	vector orderEndPos = trInitial.endPos
	orderPosData.orderPos    = trInitial.endPos
	orderPosData.arPos = trInitial.endPos
	orderPosData.orderType = eOrderType.AIR

	if ( trInitial.fraction < 0.99 )
	{
		float boundsAdj = fabs(VANTAGE_COMPANION_BOUND_MAXS.z)*1.5
		vector startHullTrace = trInitial.endPos + (trInitial.surfaceNormal * boundsAdj) + (playerViewVector * -boundsAdj)

		TraceResults trHull = TraceHull( startHullTrace, trInitial.endPos, VANTAGE_COMPANION_BOUND_MINS*1.5, VANTAGE_COMPANION_BOUND_MAXS*1.5, [ player ], TRACE_MASK_PLAYERSOLID , ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )
		#if DEVELOPER
			devTraces++

			if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
			{
				//DebugDrawArrow( startHullTrace, trInitial.endPos, 5, <255, 255, 0>, false, 5.0 )
			}
		#endif //#if DEVELOPER

		if ( trHull.startSolid )
		{
			#if DEVELOPER
				if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
				{
					DebugDrawText( startHullTrace, "startsolid (red)", false, 5.0 )
					//DebugDrawBox( startHullTrace, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, <255, 0, 0>, 1, 5.0 )
				}
			#endif //#if DEVELOPER
			//Redo the initial trace to use a hull
			TraceResults trInitialHullRedo = TraceHull( startTraceInitial, endTraceInitial, VANTAGE_COMPANION_BOUND_MINS*1.5, VANTAGE_COMPANION_BOUND_MAXS*1.5, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )
			#if DEVELOPER
				devTraces++
			#endif //#if DEVELOPER

			//Check if we are too far from the initial spot, if so dont continue using this hull trace redo
			if ( Distance( trHull.endPos, trInitialHullRedo.endPos ) < (3 * METERS_TO_INCHES) )
			{
				startHullTrace = trInitialHullRedo.endPos + (trInitialHullRedo.surfaceNormal * boundsAdj) + (playerViewVector * -boundsAdj)

				trHull = TraceHull( startHullTrace, trInitialHullRedo.endPos, VANTAGE_COMPANION_BOUND_MINS * 1.5, VANTAGE_COMPANION_BOUND_MAXS * 1.5, [ player ], ECHO_ORDER_TRACE_COL_MASK, ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )

				#if DEVELOPER
					devTraces++

					if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
					{
						//DebugDrawArrow( startHullTrace, trInitialHullRedo.endPos, 5, COLOR_ORANGE, false, 5.0 )
					}
				#endif //#if DEVELOPER
			}
		}

		orderPosData.orderPos    = trHull.endPos
		orderPosData.arNormal = trInitial.surfaceNormal
		orderPosData.orderType = eOrderType.GROUND

		float upDot = DotProduct( trInitial.surfaceNormal, UP_VECTOR )
		float upDotAbs  = fabs( upDot )
		bool normalIsFlat = upDotAbs < DOT_45DEGREE

		#if DEVELOPER
			if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
			{
				int g = normalIsFlat ? 50 : 255
				int b = normalIsFlat ? 255 : 50
				string normalType = normalIsFlat ? "wall" : ( (upDot > 0) ? "ground" : "ceiling" )
				DebugDrawText( trInitial.endPos, "normal (green): " + normalType, false, 5.0 )
				DebugDrawArrow( trInitial.endPos, trInitial.endPos + (trInitial.surfaceNormal * 30), 5, 0, g, b, false, 5.0)
			}
		#endif //#if DEVELOPER

		if ( normalIsFlat )
		{
			orderPosData.orderType = eOrderType.WALL
			//See if there is a ledge above this
			vector flatNormal = FlattenNormalizeVec( trInitial.surfaceNormal )

			//////////////////////
			//trace up
			vector traceUpStart = trInitial.endPos + (trInitial.surfaceNormal * ECHO_ORDER_LEDGE_CHECK_BACK / 2.0)
			vector traceUpEnd = traceUpStart + (UP_VECTOR * ECHO_ORDER_LEDGE_CHECK_UP )
			TraceResults trUp = TraceLine( traceUpStart, traceUpEnd, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, player )

			#if DEVELOPER
				devTraces++

				if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
				{
					//DebugDrawArrow( traceUpStart, trUp.endPos, 10, COLOR_ORANGE, false, 5.0 )
				}
			#endif //#if DEVELOPER

			if ( trUp.fraction > 0.99 )
			{

				///////////////////////
				// trace back
				vector traceBackStart = trUp.endPos
				vector traceBackEnd = traceBackStart - (flatNormal * ECHO_ORDER_LEDGE_CHECK_BACK * 1.5 )
				TraceResults trBack = TraceLine( traceBackStart, traceBackEnd, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, player )

				#if DEVELOPER
					devTraces++

					if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
					{
						//DebugDrawArrow( traceBackStart, trBack.endPos, 10, <255, 255, 0>, false, 5.0 )
					}
				#endif //#if DEVELOPER

				if ( trBack.fraction > 0.99 )
				{
					vector ledgeStartTrace = trBack.endPos //trInitial.endPos + (UP_VECTOR * ECHO_ORDER_LEDGE_CHECK_UP) - (flatNormal * ECHO_ORDER_LEDGE_CHECK_BACK)
					vector ledgeEndTrace = ledgeStartTrace - (UP_VECTOR * ECHO_ORDER_LEDGE_CHECK_UP * 2)

					//TraceResults trLedge = TraceLine( ledgeStartTrace, ledgeEndTrace, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP )
					TraceResults trLedge = TraceHull( ledgeStartTrace, ledgeEndTrace, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, [ player ], ECHO_ORDER_TRACE_COL_MASK, ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )

					#if DEVELOPER
						devTraces++

						if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
						{
							//DebugDrawArrow( ledgeStartTrace, ledgeEndTrace, 10, COLOR_LIGHT_GREEN, false, 5.0 )
						}
					#endif //#if DEVELOPER

					if ( !trLedge.startSolid && trLedge.fraction < 0.99 )
					{
						//Found!
						#if DEVELOPER
							if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
							{
								DebugDrawText( trLedge.endPos,"CornerPos", false, 5.0 )
								//DebugDrawSphere( trLedge.endPos, 8,COLOR_LIGHT_GREEN,false, 5.0 )
							}
						#endif //#if DEVELOPER
						orderPosData.orderPos = trLedge.endPos
						orderPosData.arPosSecondary = trLedge.endPos
						orderPosData.arNormalSecondary = trLedge.surfaceNormal
						orderPosData.orderType = eOrderType.CORNER
					}
				}
			}
		}
	}


	/////////////////////////////////
	// Adjust it so its off the ground and not to close to the ceiling.

	vector adjustedPoint = AdjustCompanionPosForHeight( orderPosData.orderPos, player )
	float lastPointGroundHeight = orderPosData.orderPos.z
	orderPosData.orderPos  = adjustedPoint

                         
                                                                                     
                                                
  
                                                                                                         
   
                                           
   
      
   
             
                                                      
                                                                                                      
    
                                                      
    
         
             
                                             
                                             
                                                              
                                                                                                               
                              
                                        
    
                                                     
             

                                                        
                                                       
                                                             
                      
             
                                              
    
         
   
  
       

#if SERVER
	float lastCompanionHeight =	currentCompanionData.ceilingHeightAtDestination
	currentCompanionData.ceilingHeightAtDestination = -1
#endif //SERVER

	Assert( orderPosData.orderType != eOrderType.NONE, "FindEchoOrderPos: Tried to find a position but orderType was NONE" )

	#if DEVELOPER
		if ( VANTAGE_COMPANION_DEBUG_DRAW || VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
		{
			float distanceMeters = Distance( player.GetOrigin(), orderPosData.orderPos ) * INCHES_TO_METERS
			printt( "SENDING ECHO TO " + orderPosData.orderPos + ", " + distanceMeters + "m away. OrderType: " + sOrderTypeStrings[orderPosData.orderType] + " Traces: " + devTraces )
		}
	#endif //#if DEVELOPER

#if SERVER
	if ( !GetCurrentPlaylistVarBool( VANTAGE_COMPANION_USE_PATHFINDING_PLAYLIST_VAR, true ) )
		return orderPosData

	bool isPlayerInCombat = PlayerIsInCombat( player )
	bool allowedToDoFullPathfind = !isPlayerInCombat || GetCurrentPlaylistVarBool( VANTAGE_COMPANION_PATHFIND_DURING_COMBAT_PLAYLIST_VAR, false )
	bool allowedToDoSimplePathfind = !isPlayerInCombat || GetCurrentPlaylistVarBool( VANTAGE_COMPANION_ENABLE_SIMPLE_PATHFIND_COMBAT_PLAYLIST_VAR, true )

	//spamming
	if ( allowedToDoFullPathfind && currentCompanionData.remainingPathNodes > 0 )
	{
		//if player spamming, just keep path and replace last point with new goal, return out
		int size = currentCompanionData.orderRoute.len()
		vector previousGoal = currentCompanionData.orderRoute[size - 1]
		float distanceFromOldToNewGoal = Length(orderPosData.orderPos - previousGoal)
		//if the new goal is close, just move the goal, otherwise, clear the path and go on cooldown
		if ( distanceFromOldToNewGoal < ( 10 * METERS_TO_INCHES ) )
		{
			currentCompanionData.orderRoute[size - 1] = orderPosData.orderPos
		}
		else
		{
			Signal(player, VANTAGE_COMPANION_PATHFINDING_ROUTE_CLEARED_SIGNAL)
			currentCompanionData.orderRoute.clear()
			currentCompanionData.indexHeightAdjusted.clear()
			currentCompanionData.remainingPathNodes = 0
			currentCompanionData.currentPathNode = 0
			currentCompanionData.orderDidPathfinding = false

			//We could put you on a pathfinding cooldown here, but I don't think we need to
		}
		return orderPosData
	}
	
	Signal(player, VANTAGE_COMPANION_PATHFINDING_ROUTE_CLEARED_SIGNAL)
	currentCompanionData.orderRoute.clear()
	currentCompanionData.indexHeightAdjusted.clear()
	currentCompanionData.remainingPathNodes = 0
	currentCompanionData.currentPathNode = 0
	currentCompanionData.orderDidPathfinding = false

	entity echo = VantageCompanion_GetEnt( player )
	Assert( IsValid(echo) )
	bool isEchoPerched = player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) == eCompanionState.PERCHED
	vector echoPosition = echo.GetLocalOrigin()

	if ( isEchoPerched )
	{
		if ( !GetCurrentPlaylistVarBool( VANTAGE_COMPANION_HIGHT_ADJUST_INITIAL_ORDER_PLAYLIST_VAR, true ) )
			return orderPosData

		//If echo is perched, they don't start from eye level, instead they're some height up
		echoPosition += UP_VECTOR * ECHO_INITIAL_DEPLOY_OFFSET.z
	}

	TraceResults trLoS = TraceLine( echoPosition, orderPosData.orderPos, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, player )
	//We only need to pathfind if we don't have a clear path to our new position
	if ( trLoS.fraction > .99 )
	{
		return orderPosData
	}

	if ( isEchoPerched )
	{
		//if we don't have a path on the initial order, but we can do a simple one point pathfind
		//DebugDrawLine( echoPosition, orderPosData.orderPos, <0, 255, 0>, false, 5  )
		//DebugDrawLine( startTrace, endTrace, COLOR_PINK, false, 5  )
		//DebugDrawSphere( trLoS.endPos, 2, <255, 0, 0>, false, 5 )

		vector fromEchoToOrderPos = trLoS.endPos - echoPosition
		float fromEchoToOrderPosLength = Length( fromEchoToOrderPos )

		if ( fromEchoToOrderPosLength < ( 3 * METERS_TO_INCHES ) )
		{
			//We're too close and this will look bad
			return orderPosData
		}

		vector fromEchoToOrderPosNormalized = ( fromEchoToOrderPos / fromEchoToOrderPosLength )
		//shift it a tiny bit further a long to make sure we get a clean hit
		vector losBlockerPoint = trLoS.endPos + ( fromEchoToOrderPosNormalized * 12 )
		fromEchoToOrderPosLength += 12

		//vector initialOrderTraceVectorNormalized = Normalize(orderEndPos - startTrace)
		//float losDotEchoToOrderPos = DotProduct( fromEchoToOrderPosNormalized, initialOrderTraceVectorNormalized )
		//vector losBlockerPointOnOriginalTrace = startTrace + ( initialOrderTraceVectorNormalized * (losDotEchoToOrderPos * fromEchoToOrderPosLength) )
		vector losBlockerPointOnOriginalTrace = GetClosestPointOnLineSegment( startTraceInitial, orderEndPos, losBlockerPoint )

		TraceResults trLoSBlockerHeight = TraceHull( losBlockerPointOnOriginalTrace, losBlockerPoint, VANTAGE_COMPANION_BOUND_MINS*1.5, VANTAGE_COMPANION_BOUND_MAXS*1.5, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )
		//DebugDrawArrow( losBlockerPointOnOriginalTrace, losBlockerPoint, 5, <0, 0, 255>, false, 5  )
		//DebugDrawSphere( trLoSBlockerHeight.endPos, 2, <0, 255, 0>, false, 5 )
		vector pathNode = trLoSBlockerHeight.endPos + ( UP_VECTOR * VANTAGE_COMPANION_FINAL_HEIGHT_OFFSET )

		currentCompanionData.orderRoute.append( pathNode )
		currentCompanionData.orderRoute.append( orderPosData.orderPos )
		currentCompanionData.indexHeightAdjusted.resize( currentCompanionData.orderRoute.len(), true )
		currentCompanionData.remainingPathNodes = 1
		currentCompanionData.startedMovingCloser = false

		currentCompanionData.orderDidPathfinding = true
		vector toNextPoint  = (currentCompanionData.orderRoute[0] - echoPosition)
		currentCompanionData.distanceToNextPoint = Length(toNextPoint)
		currentCompanionData.dirToNextPoint = toNextPoint/currentCompanionData.distanceToNextPoint

		#if DEVELOPER
			if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
			{
				//Magenta are the actual points that we're trying to move to
				//DebugDrawSphere( currentCompanionData.orderRoute[0], 10, COLOR_MAGENTA, false, 5 )
				DebugDrawText( currentCompanionData.orderRoute[0], string(0), false, 5 )
			}
		#endif //#if DEVELOPER
		return orderPosData
	}



	//Set Vantage Flight Params//
	CompanionFlightParams flightData = GetVantageCompanionFlightData( player )

	CompanionPathData pathData = GetCompanionPathData( echo, echoPosition, orderPosData.orderPos, lastCompanionHeight, flightData )

	//this is a check to see if we can do a simple one point pathfind to handle situations where full pathfinds
	//often return bad results. i.e. if echo is on the side of a wall and you order them onto the roof or vice versa
	if ( allowedToDoSimplePathfind && GetCurrentPlaylistVarBool( VANTAGE_COMPANION_ENABLE_SIMPLE_PATHFIND_PLAYLIST_VAR, true ) )
	{

		// Simplified Pathfinding - Use Simplifed Results //
		if( pathData.isValidSimplePath )
		{
			currentCompanionData.orderRoute = pathData.pathPoints
			currentCompanionData.indexHeightAdjusted.resize( currentCompanionData.orderRoute.len(), true )
			currentCompanionData.remainingPathNodes = 1
			currentCompanionData.startedMovingCloser = false

			currentCompanionData.orderDidPathfinding = true
			vector toNextPoint  = (currentCompanionData.orderRoute[0] - echoPosition)
			currentCompanionData.distanceToNextPoint = Length(toNextPoint)
			currentCompanionData.dirToNextPoint = toNextPoint/currentCompanionData.distanceToNextPoint

			#if DEVELOPER
				if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
				{
					//Magenta are the actual points that we're trying to move to
					//DebugDrawSphere( currentCompanionData.orderRoute[0], 10, COLOR_MAGENTA, false, 5 )
					DebugDrawText( currentCompanionData.orderRoute[0], string(0), false, 5 )
				}
			#endif //#if DEVELOPER
			return orderPosData
		}
	}

	// Advanced Pathfinding - Use Nav Mesh Results //
	if ( !allowedToDoFullPathfind )
	{
		return orderPosData
	}

	if ( !pathData.isValidFullPath )
		return orderPosData

	currentCompanionData.orderRoute = pathData.pathPoints
	currentCompanionData.remainingPathNodes = (pathData.pathPoints.len() - 1)
	currentCompanionData.startedMovingCloser = false

	//Get the Ground Height for Path Points
	array<float> groundHeightArray = GetGroundHeightArrayForPath( pathData.pathPoints, pathData.pathPoints.len() )

	currentCompanionData.orderRoute[currentCompanionData.orderRoute.len() - 1] = orderPosData.orderPos

	currentCompanionData.indexHeightAdjusted.resize( currentCompanionData.orderRoute.len(), false )
	//goal destionation is already done
	currentCompanionData.indexHeightAdjusted[currentCompanionData.orderRoute.len() - 1] = true

	//Adjust the Height of Path Points
	thread Companion_AdjustHeight_Thread( player, echo, orderPosData.orderPos, currentCompanionData, groundHeightArray, flightData )
	//
	#if DEVELOPER
		if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
		{
			printt( "New num nodes: " + currentCompanionData.orderRoute.len() )
			printt( "Dev Traces: " + devTraces )
		}
	#endif

	currentCompanionData.orderDidPathfinding = true
	vector toNextPoint  = (currentCompanionData.orderRoute[0] - echoPosition)
	currentCompanionData.distanceToNextPoint = Length(toNextPoint)
	currentCompanionData.dirToNextPoint = toNextPoint/currentCompanionData.distanceToNextPoint

	#if DEVELOPER
		if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
		{
			//White is our final destination
			//DebugDrawSphere( orderPosData.orderPos, 10, <255, 255, 255>, false, 5 )
			DebugDrawText( orderPosData.orderPos, "end:" + string( currentCompanionData.orderRoute.len() - 1 ), false, 5 )
		}
	#endif //#if DEVELOPER
#endif

	return orderPosData
}

vector function VantageCompanion_FindAndDisplayOrderPos( entity player )
{
	OrderPosData companionOrderData = FindEchoOrderPos( player )

	#if CLIENT
		CreateCompanionARIndicator( player,  companionOrderData )
	#endif


	return companionOrderData.orderPos
}


void function VantageCompanion_OrderCompanion( entity player, bool showAR = true, vector ornull overrideOrderPos = null)
{
	OrderPosData companionOrderData
	if ( overrideOrderPos != null )
	{
		companionOrderData.orderType = eOrderType.GROUND //Was unset before, TODO, do we care that this is not transferred
		companionOrderData.orderPos = expect vector(overrideOrderPos)
	}
	else
	{
		companionOrderData = FindEchoOrderPos( player )
	}

	if ( showAR )
	{
		#if CLIENT
			CreateCompanionARIndicator( player, companionOrderData )
		#endif
	}

	#if SERVER
		SetSendPos( player, companionOrderData.orderPos )
	#endif
}

void function VantageCompanion_SetPlayerLaunchState( entity player, int launchState )
{
	if ( player in file.echoData )
	{
		file.echoData[player].playerLaunchState = launchState
	}
}

int function VantageCompanion_GetPlayerLaunchState( entity player )
{
	if ( player in file.echoData )
	{
		return file.echoData[player].playerLaunchState
	}

	return ePlayerLaunchState.NONE
}


vector function AdjustCompanionPosForHeight( vector proposedCompanionPos , entity player )
{
	vector adjustedPoint = proposedCompanionPos

	bool traceDownHit = false

	//First trace down to see if we are in the clear
	vector endTracePoint    = proposedCompanionPos - UP_VECTOR * ECHO_ORDER_MIN_HEIGHT
	TraceResults trHullDown = TraceHull( proposedCompanionPos, endTracePoint, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )
	TraceResults trHullUp
	if ( trHullDown.fraction < 1.0 )
	{
		traceDownHit = true

		//Trace back up to see if we can get above our position
		trHullUp = TraceHull( trHullDown.endPos, trHullDown.endPos + UP_VECTOR * ECHO_ORDER_MIN_HEIGHT, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, UP_VECTOR, player )

		//lower adjusted point by the final offset to reduce Echo's height away from the ceiling. This reduces issues
		//with the future hull traces clipping the ceiling.
		adjustedPoint = trHullUp.endPos //trHullDown.endPos + UP_VECTOR * ( ( trHullUp.fraction * ECHO_ORDER_MIN_HEIGHT ) + VANTAGE_COMPANION_FINAL_HEIGHT_OFFSET )
	}

	#if DEVELOPER
		if ( VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
		{
			float drawTime = 5.0
			vector drawColor = !traceDownHit ? <0, 255, 0> : COLOR_ORANGE

			if ( !traceDownHit )
			{
				DebugDrawText( trHullDown.endPos, "All Clear",false, drawTime )
				DebugDrawLine( proposedCompanionPos, trHullDown.endPos, int(drawColor.x), int(drawColor.y), int(drawColor.z), false, drawTime )
			}
			else
			{

				DebugDrawText( trHullDown.endPos, "Down Hit Something", false, drawTime )
				DebugDrawArrow( proposedCompanionPos, trHullDown.endPos, 3, int(drawColor.x), int(drawColor.y), int(drawColor.z), false, drawTime )
				//DebugDrawMark( trHullDown.endPos, 3, <255, 0, 0>, false, drawTime )

				drawColor = (trHullUp.fraction >= 1.0) ? COLOR_LIGHT_GREEN : COLOR_ORANGE

				DebugDrawArrow( trHullDown.endPos, trHullUp.endPos, 3, int(drawColor.x), int(drawColor.y), int(drawColor.z), false, drawTime )

				DebugDrawText( adjustedPoint, "Adjusted pos", false, drawTime )
				//DebugDrawMark( adjustedPoint, 5, COLOR_LIGHT_GREEN, false, drawTime )
				DebugDrawBox( adjustedPoint, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, int(drawColor.x), int(drawColor.y), int(drawColor.z), 1, drawTime )
			}
		}
	#endif //#if DEVELOPER

	return adjustedPoint
}

void function TestCompanionSendPoint_Thread( entity player, entity echoEnt )
{
	player.EndSignal( "OnDestroy" )
	echoEnt.EndSignal( "OnDestroy" )

	while (true)
	{
		vector traceStart = player.EyePosition()
		vector traceEnd = player.EyePosition() + player.GetPlayerOrNPCViewVector() * (VantageCompanion_GetRangeBase( player ) - 15)
		TraceResults tr = TraceLine( traceStart, traceEnd , [ player, echoEnt ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, player )

		int pointInRange = tr.fraction < 1.0 ? 1 : 0

		entity weapon = player.GetOffhandWeapon( OFFHAND_RIGHT )

		//bool isPredictedOrServer = true//InPrediction() //&& IsFirstTimePredicted()
		//#if SERVER
		//	isPredictedOrServer = true
		//#endif //SERVER
		//
		//if ( isPredictedOrServer )
		{
			if ( IsValid( weapon ) )
			{
				bool isPredictableEnt = true // GetPredictable not in S3 CLIENT
				if ( isPredictableEnt )
					weapon.SetScriptInt0( pointInRange )
			}
		}
		WaitFrame()
	}

}

CompanionFlightParams function GetVantageCompanionFlightData( entity owner )
{
	CompanionFlightParams flightData

	flightData.boundsMin			= VANTAGE_COMPANION_BOUND_MINS
	flightData.boundsMax			= VANTAGE_COMPANION_BOUND_MAXS
	flightData.entSpeed				= VantageCompanion_GetSpeed( owner )
	flightData.initHeightOffset		= VANTAGE_COMPANION_INIT_HEIGHT_OFFSET
	flightData.minHeightOffset		= ECHO_ORDER_MIN_HEIGHT
	flightData.finalOffset			= VANTAGE_COMPANION_FINAL_HEIGHT_OFFSET
	flightData.maxPathLength 		= VANTAGE_COMPANION_MAX_PATH_LEN
	flightData.maxLengthRatio 		= GetCurrentPlaylistVarFloat( VANTAGE_COMPANION_PATHFIND_MAX_LENGTH_RATIO_PLAYLIST_VAR, 1.6 )
	flightData.maxTimeDiff 			= GetCurrentPlaylistVarFloat( VANTAGE_COMPANION_PATHFIND_MAX_TIME_DIFF_PLAYLIST_VAR, 1.8 )
	flightData.doorErrorRadius		= VANTAGE_COMPANION_DOOR_ERROR_RADIUS
	flightData.doorEnterHeight		= VANTAGE_COMPANION_ENTER_DOOR_HEIGHT
	flightData.eBailCondition		= VANTAGE_COMPANION_PATHFINDING_BAIL_CONDITION

	return flightData
}

entity function VantageCompanion_GetEnt( entity player )
{
	return player.GetPlayerNetEnt( VANTAGE_COMPANION_ENT_NETVAR )
}

const vector DEBUGDRAW_ECHO_COLOR = <0, 100, 255>

void function DebugDrawCompanion( entity echoEnt )
{
	if ( IsValid( echoEnt ) )
	{
		DebugDrawBox( echoEnt.GetOrigin(), VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, 255, 150, 0, 50, 2*UPDATE_RATE )
		DebugDrawSphere( echoEnt.GetOrigin(), 4, 0, 100, 255, false, 2*UPDATE_RATE )
	}
}

void function VantageCompanion_Recall( entity player )
{
	if ( player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) != eCompanionState.RECALLING && player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) != eCompanionState.PERCHED )
	{
		entity enchoEnt = player.GetPlayerNetEnt( VANTAGE_COMPANION_ENT_NETVAR )
		if ( player in file.companionData )
		{
			#if SERVER
				file.companionData[player].orderRoute.clear()
				file.companionData[player].remainingPathNodes = 0
				Signal(player, VANTAGE_COMPANION_PATHFINDING_ROUTE_CLEARED_SIGNAL)
				VantageCompanion_SetOrderPos( player, null )
				EmitSoundOnEntityOnlyToPlayer( enchoEnt, player, SOUND_COMPANION_RECALL_VOICE )
			#endif

			#if CLIENT
				if ( player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) != eCompanionState.PERCHED )
				{
					entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )

					if ( IsValid( weapon ) && weapon.GetWeaponClassName() == VANTAGE_RECALL_WEAPON_NAME )
					{
						ActivateOffhandWeaponByIndex( OFFHAND_EQUIPMENT )
					}
					//HidePlayerHint( "#TELEPORTING_HAWK_RECALL" )
				}

				if ( file.vantageTacticalRui != null )
				{
					float recallStartDistanceTo = Distance( player.GetOrigin(), enchoEnt.GetOrigin() )
					var rui                     = file.vantageTacticalRui

					RuiSetFloat( rui, "recallStartDistanceTo", recallStartDistanceTo )
					RuiSetFloat( rui, "recallTransitionTime", Time() )
				}
			#endif
		}
	}
}

//Launch stuff
vector function Launch_CalcLaunchToPos( entity player, entity echoEnt )
{
	vector finalLaunchToPos    = echoEnt.GetOrigin() + <0.0, 0.0, LAUNCH_TARGET_UP_OFFSET>

	vector playerToArrivalPos = finalLaunchToPos - player.GetOrigin()
	finalLaunchToPos += Normalize(FlattenVec( playerToArrivalPos )) * LAUNCH_TARGET_FWD_OFFSET

	return finalLaunchToPos
}

#if SERVER
void function ClientCallback_VantageCompanion_Recall( entity player )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	VantageCompanion_Recall( player )
}
void function SetSendPos( entity player, vector sendPos )
{
	VantageCompanion_SetOrderPos( player, sendPos )
}

void function VantageCompanion_Deploy( entity player )
{
	CompanionData thisCompanionData
	file.companionData[player] <- thisCompanionData

	EchoCompanionData thisEchoData
	file.echoData[player] <- thisEchoData

	thread VantageCompanionSpawnAndLifetime_Thread( player )
}

void function VantageCompanion_Destroy( entity player )
{
	player.Signal( "EndCompanionLifetime_Signal" )
}

void function VantageCompanion_ShowAndSetToShoulder( entity player )
{
	if ( !IsValid(player) )
		return

	entity companionEnt = VantageCompanion_GetEnt( player )
	if ( !IsValid( companionEnt ) )
		return

	companionEnt.Show()
	vector shoulderPos = GetCompanionPerchedPos( player )
	companionEnt.SetAbsOrigin( shoulderPos )
}

void function VantageCompanionSpawnAndLifetime_Thread( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndCompanionLifetime_Signal" )

	entity echoEnt
	array<entity> fxArray
	CompanionData currentCompanionData = file.companionData[player]
	EchoCompanionData currentEchoData = file.echoData[player]

	player.SetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT, eCompanionState.UNKNOWN )

	echoEnt = CreateCompanionEntity( player )
	player.p.realmLinkedEntities.append( echoEnt )

	entity vortexSphere //= CreateCompanionVortexSphere( echoEnt )
	//vortexSphere.SetBlocksRadiusDamage( false )
 	player.SetPlayerNetEnt( VANTAGE_COMPANION_ENT_NETVAR, echoEnt )

	SetCompanionPerched( true, echoEnt, true )

	thread TestCompanionSendPoint_Thread( player, echoEnt )

	OnThreadEnd(
		function() : ( player , echoEnt, fxArray, vortexSphere)
		{
			if ( IsValid( player ) )
			{
				if ( player.p.realmLinkedEntities.contains( echoEnt ) )
					player.p.realmLinkedEntities.fastremovebyvalue( echoEnt )
			}

			foreach( fx in fxArray )
			{
				EffectStop( fx )
				fx.Destroy()
			}

			if ( IsValid( echoEnt ) )
			{
				if ( GetCurrentPlaylistVarBool( VANTAGE_COMPANION_USE_PATHFINDING_PLAYLIST_VAR, true ) )
				{
					DeregisterNavMesh_EntityMemory( echoEnt )
				}
				echoEnt.Destroy()
			}

			if ( IsValid( vortexSphere ) )
				vortexSphere.Destroy()

			delete file.companionData[player]
		}
	)


	                    
	float prevEcholocationPingTime
       

	int framesInvalid = 0
	while ( true )
	{
		float echoAngAccelMultiplier = 1.0

		vector echoCurrentPos = echoEnt.GetOrigin()
		vector echoToPlayer   = player.GetOrigin() - echoCurrentPos
		float distanceToEcho  = Length( echoToPlayer )
		vector currentVel     = echoEnt.GetVelocity()
		float currentSpeed    = Length( currentVel )

		int playerLaunchState = VantageCompanion_GetPlayerLaunchState( player )

		Highlight_ClearEnemyHighlight( echoEnt )

		vector echoGoalPos
		if ( ShouldHardRecallCompanion(player, echoEnt, distanceToEcho ) )
		{
			VantageCompanion_Recall( player )
			SetCompanionPerched( true, echoEnt)
		}
		else if ( currentEchoData.targetEntity != null )
		{
			if ( IsAlive(currentEchoData.targetEntity) )
			{
				player.SetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT, eCompanionState.ORDERED_TO_TARGET )

				Highlight_SetEnemyHighlight( echoEnt, "enemy_sonar" )

				//Fly out toward a player our owner has damaged.
				SetCompanionPerched( false, echoEnt )

				echoGoalPos = echoCurrentPos//CalculateCompanionPosGivenTargetEntity( player, currentCompanionData.targetEntity )

				float distance = Distance( echoGoalPos, echoCurrentPos );
			}
			else
			{
				VantageCompanion_SetOrderPos( player, echoCurrentPos )
			}
		}
		else if ( currentEchoData.orderPosOrNull != null )
		{
			//Fly to and stay at our ordered position
			player.SetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT, eCompanionState.ORDERED_TO_POSITION )

			SetCompanionPerched( false, echoEnt )

			vector ornull overridePos = currentEchoData.orderPosOrNull
			echoGoalPos = expect vector( overridePos )

			vector playerToGoal = echoGoalPos - player.GetOrigin()
			float playerToGoalDistance = Length( playerToGoal )

			if ( playerToGoalDistance > VantageCompanion_GetRangeMax( player ) )
			{
				vector retreatPos = FindCompanionFollowPos( player, echoEnt, echoGoalPos )
				VantageCompanion_SetOrderPos( player, retreatPos )
			}
		}
		else if ( player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) == eCompanionState.PERCHED )
		{
			//vector shoulderPos = GetCompanionPerchedPos( player )
			//echoEnt.SetAbsOrigin( shoulderPos )
			#if DEVELOPER
				//Draw goal position
				if ( VANTAGE_COMPANION_DEBUG_DRAW  )
				{
					DebugDrawCompanion( echoEnt )
				}
			#endif
		}
		else
		{
			// Fly back to Shoulder
			vector shoulderPos = GetCompanionPerchedPos( player )
			echoGoalPos = shoulderPos

			if ( player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) != eCompanionState.RECALLING )
			{
				vector toGoalPos = echoGoalPos - echoCurrentPos
				vector toGoalFlatNorm = FlattenNormalizeVec( toGoalPos )
				vector currentFwd = echoEnt.GetForwardVector()
				vector currentFlatFwd = FlattenNormalizeVec( currentFwd )
				float dot = DotProduct( currentFlatFwd, toGoalFlatNorm )
				if ( dot < -DOT_10DEGREE )
				{
					echoEnt.SetAbsForwardVector( echoEnt.GetRightVector()  )
				}

			}

			player.SetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT, eCompanionState.RECALLING )

			float distance = Distance( echoGoalPos, echoCurrentPos )

			if ( distance <= VANTAGE_COMPANION_PERCHED_RANGE )
			{
				SetCompanionPerched( true,  echoEnt )
			}
		}


		/////////////////////////////////////////////////////////////////////////
		// Pathfinding
		waitthread DoCompanionPathfinding( player, echoEnt, echoGoalPos, currentCompanionData )

		//we're keeping the turn rate consistent for the last step of pathfinding
		if ( currentCompanionData.orderDidPathfinding )
		{
			echoAngAccelMultiplier = 3
		}

		// End Pathfinding section
		//////////////////////////////////////////////////////////////////////////////////


		// Do movement and turning
		DoMovementAndTurning( player, echoEnt, echoGoalPos,  currentCompanionData )

                          
                                                                                           
   
                                                                                    
   
        

		wait UPDATE_RATE
	}
}

void function DoMovementAndTurning( entity player, entity echoEnt, vector echoGoalPos, CompanionData currentCompanionData )
{
	vector echoCurrentPos = echoEnt.GetOrigin()
	vector echoToPlayer   = player.GetOrigin() - echoCurrentPos
	float distanceToEcho  = Length( echoToPlayer )
	vector currentVel     = echoEnt.GetVelocity()
	float currentSpeed    = Length( currentVel )
	float echoAngAccelMultiplier = 1.0
	if ( currentCompanionData.orderDidPathfinding )
	{
		echoAngAccelMultiplier = 3.0
	}
	int playerLaunchState = VantageCompanion_GetPlayerLaunchState( player )

	if ( player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) != eCompanionState.PERCHED  )
	{
		vector toGoalPos
		if( currentCompanionData.remainingPathNodes > 0 )
		{
			toGoalPos = currentCompanionData.orderRoute[currentCompanionData.currentPathNode] - echoCurrentPos
		}
		else
		{
			toGoalPos = echoGoalPos - echoCurrentPos
		}

		//////////////////////////////////////////////
		//Figure out our speed
		float distance = Length( toGoalPos )
		float echoBaseSpeed 	= VantageCompanion_GetSpeed( player )
		float echoDesiredSpeed 	= echoBaseSpeed
		float echoBaseRange = VantageCompanion_GetRangeBase( player )
		float echoMaxRange = VantageCompanion_GetRangeMax( player )
		bool isPlayerRecalling = player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) == eCompanionState.RECALLING


		if ( distance > VANTAGE_COMPANION_SLOW_DOWN_RANGE )
		{
			float speedMult = 1.0

			if ( playerLaunchState == ePlayerLaunchState.LAUNCHING )
			{
				speedMult = 3.0
			}
			else if ( isPlayerRecalling )
			{
				speedMult = 2.0
			}
			else
			{
				//
				if ( distance > echoMaxRange )
				{
					speedMult = GraphCapped( distance, echoMaxRange, echoMaxRange * 3.0, 1.0, 3.0 )
				}
				else if ( distance >  echoBaseRange )
				{
					speedMult = GraphCapped( distance, echoBaseRange, echoMaxRange, 1.0, 1.5 )
				}
			}
			echoDesiredSpeed *= speedMult
		}
		else
		{
			float minSpeed = 0
			if ( isPlayerRecalling )
			{
				float playerSpeed = min( Length( player.GetVelocity() ), 400.0 )
				minSpeed = playerSpeed * 1.25
			}

			if ( currentCompanionData.remainingPathNodes > 0 )
			{
				vector previousGoalToCurrentGoal
				int currentNode = currentCompanionData.currentPathNode
				if ( currentNode > 0 )
				{
					previousGoalToCurrentGoal = Normalize(currentCompanionData.orderRoute[currentNode] - currentCompanionData.orderRoute[currentNode - 1])
				}
				else
				{
					previousGoalToCurrentGoal = Normalize(currentCompanionData.orderRoute[currentNode] - echoCurrentPos)
				}
				vector currentGoalToNextGoal = Normalize(currentCompanionData.orderRoute[currentCompanionData.currentPathNode + 1] - currentCompanionData.orderRoute[currentCompanionData.currentPathNode])

				float currentToNextDot = DotProduct( previousGoalToCurrentGoal, currentGoalToNextGoal )
				if ( currentToNextDot < 0.25 )
				{
					//if we always use this speed, echo won't stop at final position, so only use this speed when not at end of path
					minSpeed = echoBaseSpeed * 0.25
					echoDesiredSpeed = GraphCapped( distance, 0.0, VANTAGE_COMPANION_SLOW_DOWN_RANGE, minSpeed, echoBaseSpeed )
				}
			}
			else
			{
				echoDesiredSpeed = GraphCapped( distance, 0.0, VANTAGE_COMPANION_SLOW_DOWN_RANGE, minSpeed, echoBaseSpeed )
			}
		}



		// Now do turning based on how fast we are going and where the goal is.
		vector toGoalNorm = Normalize( toGoalPos )
		vector newFwd   = Normalize( SlerpVector( echoEnt.GetForwardVector(), toGoalNorm, 0.5 ) )
		if ( currentSpeed <= VANTAGE_COMPANION_LOW_SPEED_THRESHOLD )
		{
			echoEnt.SetAbsForwardVector( newFwd  )
		}
		vector companionFwd = echoEnt.GetForwardVector()



		float echoAngAccel = VANTAGE_COMPANION_ANG_ACCEL_LOW_SPEED//GraphCapped( echoDesiredSpeed, 0.0, VANTAGE_COMPANION_BASE_SPEED, VANTAGE_COMPANION_ANG_ACCEL_MAX_SPEED, VANTAGE_COMPANION_ANG_ACCEL_LOW_SPEED )
		echoAngAccel *= echoAngAccelMultiplier

		float dot         = DotProduct( companionFwd, toGoalNorm )
		float degreesToTarget = (acos( dot ) * 180 / PI)

		float lerpFrac = 1.0
		if ( degreesToTarget > 0 && distance > (VANTAGE_COMPANION_SLOW_DOWN_RANGE/2) )
		{
			lerpFrac  = min( (echoAngAccel * UPDATE_RATE) / degreesToTarget, 1.0)
		}
		//printt("Echo turning: degToTarget: " + degreesToTarget + " accel: " + echoAccel + " lerpFrac: " + lerpFrac )

		float echoLowSpeed    = min( echoBaseSpeed*0.5, echoDesiredSpeed*0.5)
		float echoActualSpeed = GraphCapped( degreesToTarget, 0, 90, echoDesiredSpeed, echoLowSpeed )

		vector newDir   = Normalize( SlerpVector( companionFwd, toGoalNorm, lerpFrac ) )

		echoEnt.NonPhysicsMoveWithGravity( newDir * echoActualSpeed, < 0, 0, 0 > )

		// This bit flattens out our trajectory
		if ( echoActualSpeed <= VANTAGE_COMPANION_LOW_SPEED_THRESHOLD )
		{
			newDir = FlattenVec( newDir )
		}
		echoEnt.SetAbsForwardVector( newDir  )


		/////////////////////////////////////////////////////////////////////////
		// Set the ceiling height param to help pathfinfding
		if ( distance < VANTAGE_COMPANION_CLOSE_TO_DESTINATION_DIST )
		{
			if ( currentCompanionData.ceilingHeightAtDestination == -1 )
			{
				TraceResults trCeiling
				float heightToCheck = 50 * METERS_TO_INCHES
				trCeiling = TraceLine( echoCurrentPos, echoCurrentPos + (UP_VECTOR * heightToCheck), [ player ], ECHO_ORDER_TRACE_COL_MASK , ECHO_ORDER_TRACE_COL_GRP, player )
				currentCompanionData.ceilingHeightAtDestination = trCeiling.fraction * heightToCheck
			}
		}
		else
		{
			currentCompanionData.ceilingHeightAtDestination = -1
		}
		/////////////////////////////////////////////////////////////////////////

		/////////////////////////////////////////////////////////////////////////
		// Anim: Set pose parameters based on the above
		float dotRight = DotProduct( echoEnt.GetRightVector(), toGoalNorm )
		float degreesRelative = degreesToTarget * ( dotRight > 0 ? 1 : -1 )
		vector headDirection = Normalize( echoToPlayer )
		SetCompanionPoseParameters( echoEnt, echoActualSpeed, degreesRelative, headDirection )
		// End Anim
		/////////////////////////////////////////////////////////////////////////


		#if DEVELOPER
			//Draw goal position
			if ( VANTAGE_COMPANION_DEBUG_DRAW || VANTAGE_COMPANION_ORDER_DEBUG_DRAW )
			{
				const float arrowLength = 30
				//DebugDrawSphere( echoGoalPos, 2, <255, 0, 0>, true, UPDATE_RATE )

				//DebugDrawArrow( echoCurrentPos, echoCurrentPos + (companionFwd*arrowLength*2.0), 5, <0, 255, 0>, false, 2*UPDATE_RATE)

				//DebugDrawArrow( echoCurrentPos, echoCurrentPos + (Normalize(newDir)*arrowLength), 5, COLOR_ORANGE, false, 2*UPDATE_RATE)

				//DebugDrawArrow( echoCurrentPos, echoCurrentPos + (Normalize( toGoalPos )*arrowLength), 5, <255, 0, 0>, false, 2*UPDATE_RATE)
				if ( echoActualSpeed > 10 )
				{
					//DebugDrawLine( currentCompanionData.prevPos, echoCurrentPos, COLOR_CYAN, false, 5.0 )
					//DebugDrawText( echoCurrentPos, ("s: " + int(echoActualSpeed)), false, 5.0 )
				}

				DebugDrawCompanion( echoEnt )

				//State
				int companionState = player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT )
				string text
				text += "Companion state: " + sCompanionStateStrings[companionState]
				text += "\nPlayer Launch state: " + sPlayerLaunchStateStrings[playerLaunchState]

				text += "\nBase Speed: " + echoBaseSpeed
				text += "\nActual Speed: " + echoActualSpeed
				text += "\nDesired Speed: " + echoDesiredSpeed
				text += "\nTurning frac: " + lerpFrac

				//DebugDrawScreenTextWithColor( 0.7, 0.8, text, COLOR_LIGHT_BLUE )
			}

			currentCompanionData.prevPos = echoCurrentPos
		#endif
	}
}

void function SetCompanionPoseParameters( entity companion, float echoSpeed, float degreesToTarget , vector headDirection )
{
	int speedPoseID = companion.LookupPoseParameterIndex( "velocity" )
	companion.SetPoseParameter( speedPoseID, echoSpeed )

	float leanParam = 0
	if ( echoSpeed > 200 )
	{
		leanParam = degreesToTarget
	}

	int leanPoseID = companion.LookupPoseParameterIndex( "lean" )
	companion.SetPoseParameter( leanPoseID, leanParam )

	float headYaw  = 0
	float headPitch = 0
	float dotFwd         = DotProduct( companion.GetForwardVector(), headDirection )
	if ( dotFwd > 0 )
	{
		float dotRight = DotProduct( companion.GetRightVector(), headDirection )
		headYaw = GraphCapped( dotRight, -DOT_45DEGREE, DOT_45DEGREE, -90, 90 )

		float dotUp = DotProduct( companion.GetUpVector(), headDirection )
		headPitch = GraphCapped( dotUp, -1, DOT_85DEGREE, -90, 90 )
	}
	else
	{
		float dotRight = DotProduct( companion.GetRightVector(), headDirection )
		headYaw = dotRight >= 0 ? 90.0 : -90.0

		float dotUp = DotProduct( companion.GetUpVector(), headDirection )
		headPitch = dotUp >= 0 ? 90.0 : -90.0
	}


	int headYawID =  companion.LookupPoseParameterIndex( "head_yaw" )
	companion.SetPoseParameter( headYawID, headYaw )

	int headPitchID =  companion.LookupPoseParameterIndex( "head_pitch" )
	companion.SetPoseParameter( headPitchID, headPitch )


	//printt( "ECHO pose speed " + echoSpeed  + "\tdegrees " + leanParam + "\theadYaw " + headYaw + "\theadPitch " + headPitch)
}

bool function ShouldHardRecallCompanion( entity player, entity echoEnt, float distance )
{
	if ( distance <= VantageCompanion_GetRangeMax( player ) )
		return false

	//if ( player.IsSkydiving() /*Player_IsSkydiving not in S3*/ )
		return true

	if ( player.IsPhaseShifted() )
		return true

	return false
}

entity function CreateCompanionVortexSphere( entity echoEnt )
{
	entity vortexSphere = CreateEntity( "vortex_sphere" )

	vortexSphere.kv.spawnflags             = SF_BLOCK_OWNER_WEAPON | SF_ABSORB_BULLETS
	vortexSphere.kv.enabled                = 0
	vortexSphere.kv.radius                 = 16
	vortexSphere.kv.height                 = 16
	vortexSphere.kv.bullet_fov             = 360
	vortexSphere.kv.physics_pull_strength  = 0//25
	vortexSphere.kv.physics_side_dampening = 0//6
	vortexSphere.kv.physics_fov            = 360
	vortexSphere.kv.physics_max_mass       = 0//2
	vortexSphere.kv.physics_max_size       = 0//6

	vortexSphere.SetAngles( <0, 0, 0> ) // viewvec?
	int attachIndex = echoEnt.LookupAttachment( "ORIGIN" )
	vortexSphere.SetOrigin( echoEnt.GetAttachmentOrigin( attachIndex ) )
	vortexSphere.SetMaxHealth( 1000 )
	vortexSphere.SetHealth( 1000 )

	vortexSphere.RemoveFromAllRealms()
	vortexSphere.AddToOtherEntitysRealms( echoEnt )

	DispatchSpawn( vortexSphere )

	vortexSphere.SetOwner( echoEnt )
	vortexSphere.SetParent( echoEnt, "ORIGIN", true, 0.0 )

	Vortex_ConvertToVortexTriggerArea( vortexSphere )
	SetCallback_VortexSphereTriggerOnProjectileHit( vortexSphere, VantageCompanion_VortexTriggerOnProjectileHit )
	VortexFireEnable( vortexSphere )



	return vortexSphere
}
void function VantageCompanion_VortexTriggerOnProjectileHit( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	#if DEVELOPER
		if ( VANTAGE_COMPANION_VORTEX_DEBUG_DRAW )
		{
			printt( "VantageCompanion_VortexTriggerOnProjectileHit" )
		}
	#endif //#if DEVELOPER

	if ( !IsValid(attacker) )
		return

	entity echoEnt = vortexSphere.GetOwner()
	if ( !IsValid(echoEnt) )
		return

	entity vantagePlayer = echoEnt.GetBossPlayer()
	if ( !IsValid(vantagePlayer) )
		return

	int companionState = vantagePlayer.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT )
	if ( companionState == eCompanionState.PERCHED )
		return

	if ( echoEnt.GetTeam() == attacker.GetTeam() )
		return


	if ( Time() > 0 ) //debounceTime )
	{
		VantageCompanion_BulletReaction( vantagePlayer, echoEnt, attacker)
	}
}

void function VantageCompanion_BulletReaction( entity vantagePlayer, entity echoEnt, entity attacker )
{
	//play animation
	thread HitAnimationThread( echoEnt , 1 )

	//play sound
	if ( IsValid( attacker ) )
		return

	if ( vantagePlayer in file.echoData )
	{
		if ( IsValid( file.echoData[vantagePlayer].targetEntity) &&
				file.echoData[vantagePlayer].targetEntity.GetTeam() == attacker.GetTeam() )
		{
			StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FX_PROJECTILE_DESTROYED ), echoEnt.GetOrigin(), echoEnt.GetAngles() )

			vector echoToOwner = vantagePlayer.GetOrigin() - echoEnt.GetOrigin()
			vector retreatPos  = echoEnt.GetOrigin() + Normalize( echoToOwner )* VANTAGE_COMPANION_RETREAT_DIST
			VantageCompanion_SetOrderPos( vantagePlayer, retreatPos )
		}
	}
}

void function HitAnimationThread( entity echoEnt , float reactTime )
{
	echoEnt.Anim_PlayOnly( "fl_flap_cycle_littleHawk" )

	wait reactTime

	if ( IsValid( echoEnt ) )
		echoEnt.Anim_PlayOnly( "fl_flap_cycle_littleHawk" )

}


void function SetCompanionPerched(  bool setPerched, entity companion, bool initialSpawn=false )
{
	entity bossPlayer = companion.GetBossPlayer()
	if ( !IsValid( bossPlayer ) )
		return

	bool isCurrentlyPerched = bossPlayer.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) == eCompanionState.PERCHED

	if ( setPerched &&  !isCurrentlyPerched)
	{
		vector shoulderPos = GetCompanionPerchedPos( bossPlayer )

		int attach_id = bossPlayer.LookupAttachment( "ORIGIN" )
		vector attachAngles = bossPlayer.GetAttachmentAngles( attach_id )

		companion.Signal( SIGNAL_WAYPOINT_DESTROY )
		companion.NonPhysicsStop()

		if ( PositionIsInMapBounds( shoulderPos ) )
			companion.SetAbsOrigin( shoulderPos )

		companion.SetAbsAngles( attachAngles )

		if ( !initialSpawn )
			EmitSoundOnEntityOnlyToPlayer( companion, bossPlayer, SOUND_COMPANION_PERCH_VOICE )

		//mover.SetParent( bossPlayer, "ORIGIN", true )
		//mover.Hide()
		companion.Hide()
		companion.NotSolid()

		bossPlayer.SetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT, eCompanionState.PERCHED )
	}
	else if ( !setPerched )
	{
		companion.Solid()
		//mover.ClearParent()
		//mover.Show()
		//companion.Show()
	}

}

//void function VantageCompanion_SetTargetEntity( entity player, entity targetEnt )
//{
//	if ( player in file.companionData )
//	{
//		file.companionData[player].targetEntity   = targetEnt
//		file.companionData[player].lastDamageTime = Time()
//	}
//}

void function VantageCompanion_SetOrderPos( entity player, vector ornull orderPosOrNull )
{
	if ( player in file.echoData )
	{
		file.echoData[player].orderPosOrNull = orderPosOrNull
	}
	else
	{
		Assert( false, "Player " + player + " not in companionData table" )
	}
}

array <vector> followCheckOffsets = [
	<1,0,0>,
	<1,0.5,0>,
	<1,-0.5,0>,
	<1,0,0.5>,
	<1,0.5,0.5>,
	<1,1,0.7>,
	<1,1,0>,
	<1,-1,0>,
	<1,0,0.7>,
	<1,1,0.7>,
	<1,-1,0.7>,
	<1,1,-0.7>,
	<1,-1,-0.7>
]

const float LAZY_FOLLOW_CATCHUP_DIST = 5 * METERS_TO_INCHES

vector function FindCompanionFollowPos( entity player, entity companion, vector goalPos )
{
	vector playerPos       = player.GetOrigin()
	vector echoPos         = companion.GetOrigin()
	vector toPlayerVec     = playerPos - echoPos

	float distance     = Length( toPlayerVec )
	float distOutOfRange = distance - VantageCompanion_GetRangeMax( player )

	vector toPlayerNorm = Normalize( toPlayerVec )
	float toPlayerUpDot = DotProduct( UP_VECTOR, toPlayerNorm )

	vector forwardDirection = toPlayerNorm
	if ( toPlayerUpDot < 0 )
	{
		forwardDirection.z *= fabs(toPlayerUpDot)
		forwardDirection = Normalize( forwardDirection )
	}

	vector rightDirection = CrossProduct(forwardDirection, UP_VECTOR  )

	const float IN_RANGE_BUFFER = 60
	float retreatDistance = max( distOutOfRange + IN_RANGE_BUFFER, LAZY_FOLLOW_CATCHUP_DIST  )

	vector retreatPos = echoPos + (forwardDirection * retreatDistance)

	bool found = false
	foreach( offset in followCheckOffsets )
	{
		vector traceEnd = echoPos
						+ (offset.x * forwardDirection * retreatDistance)
						+ (offset.y * rightDirection * retreatDistance)
						+ (offset.z * UP_VECTOR * retreatDistance)

		array <entity> ignoreEnts = [ companion, player ]
		TraceResults trHull = TraceHull( echoPos, traceEnd, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, ignoreEnts, ECHO_ORDER_TRACE_COL_MASK, TRACE_COLLISION_GROUP_PLAYER, UP_VECTOR, companion)

		#if DEVELOPER
			if ( VANTAGE_COMPANION_FOLLOW_DEBUG_DRAW )
			{
				int r = trHull.fraction >= 1.0 ? 0 : 255
				int g = trHull.fraction >= 1.0 ? 255 : 0
				DebugDrawBox( trHull.endPos, VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS, r, g, 0, 10, 5.0 )
				DebugDrawLine( echoPos, trHull.endPos, r, g, 0, false, 5.0 )
			}
		#endif //#if DEVELOPER
		if ( trHull.fraction >= 1.0 )
		{
			retreatPos = trHull.endPos
			found = true

			#if DEVELOPER
				if ( VANTAGE_COMPANION_FOLLOW_DEBUG_DRAW )
				{
					printt( "Found one! offset: " + offset )
					string retreatDistMString = "Dist: " + ( retreatDistance * INCHES_TO_METERS )
					DebugDrawText( retreatPos, retreatDistMString, true, 5.0 )
				}
			#endif //#if DEVELOPER

			break
		}
	}

	#if DEVELOPER
		if ( VANTAGE_COMPANION_FOLLOW_DEBUG_DRAW && !found )
			printt( "No luck, backup: " + retreatPos )
	#endif //#if DEVELOPER

	retreatPos = AdjustCompanionPosForHeight( retreatPos, player )

	return retreatPos
}


vector function GetCompanionPerchedPos( entity player )
{
	int attach_id = player.LookupAttachment( "CHESTFOCUS" )
	vector attachPos = player.GetAttachmentOrigin( attach_id )
	vector attachAngles = player.GetAttachmentAngles( attach_id )
	//
	vector attachUp = AnglesToUp( attachAngles )
	vector attachRight = AnglesToRight( attachAngles )
	//
	//
	vector pos = attachPos + attachUp* 40 + attachRight*-20

	//vector pos = player.EyePosition() + UP_VECTOR* 15 +
	return pos
}

entity function CreateCompanionEntity(  entity player )
{
	vector origin = GetCompanionPerchedPos( player )
	vector angles = player.GetAngles()

	entity companionEntity

	/// Mover with prop script on it
	//entity companionProp = CreatePropScript( VANTAGE_COMPANION_MODEL, origin, angles, SOLID_HITBOXES )
	entity companionProp = CreateExpensiveScriptMoverModel( VANTAGE_COMPANION_MODEL, origin, angles, SOLID_BBOX )

	companionProp.SetScriptName( VANTAGE_COMPANION_SCRIPTNAME )
	companionProp.SetTitle( "#ECHO" )
	companionProp.SetOwner( player )
	companionProp.SetBossPlayer( player )
	companionProp.kv.collisionGroup = TRACE_COLLISION_GROUP_NONE
	companionProp.kv.contents = CONTENTS_NOGRAPPLE | CONTENTS_BLOCKLOS | CONTENTS_BLOCK_PING
	//companionProp.NotSolid()
	companionProp.SetModelScale( VANTAGE_COMPANION_MODEL_SCALE )
	companionProp.SetBoundingBox( VANTAGE_COMPANION_BOUND_MINS, VANTAGE_COMPANION_BOUND_MAXS )
	companionProp.e.preventStickyEnts = true

	companionProp.RemoveFromAllRealms()
	companionProp.AddToOtherEntitysRealms( player )

	SetTeam( companionProp, player.GetTeam() )

	Highlight_SetOwnedHighlight( companionProp, "sp_friendly_hero" )
	Highlight_SetFriendlyHighlight( companionProp, "sp_friendly_hero" )


	entity trailFX = StartParticleEffectOnEntity_ReturnEntity ( companionProp, GetParticleSystemIndex( FX_COMPANION_TRAIL ), FX_PATTACH_POINT_FOLLOW, companionProp.LookupAttachment( "CHESTFOCUS" ) )//FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	trailFX.SetOwner( companionProp )
	SetTeam( trailFX, companionProp.GetTeam() )
	trailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY

	trailFX.RemoveFromAllRealms()
	trailFX.AddToOtherEntitysRealms( player )

	entity trailFXEnemy = StartParticleEffectOnEntity_ReturnEntity ( companionProp, GetParticleSystemIndex( FX_COMPANION_TRAIL_ENEMY ), FX_PATTACH_POINT_FOLLOW, companionProp.LookupAttachment( "CHESTFOCUS" ) )//FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	trailFXEnemy.SetOwner( companionProp )
	SetTeam( trailFXEnemy, companionProp.GetTeam() )
	trailFXEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	trailFXEnemy.RemoveFromAllRealms()
	trailFXEnemy.AddToOtherEntitysRealms( player )

	//fxArray.append( trailFX )

	//entity mover = CreateScriptMover( "", origin, angles )
	//mover.RemoveFromAllRealms()
	//mover.AddToOtherEntitysRealms( player )



	thread CompanionAnimFX_Thread( companionProp, player, trailFX, trailFXEnemy )


	companionEntity = companionProp

	if ( GetCurrentPlaylistVarBool( VANTAGE_COMPANION_USE_PATHFINDING_PLAYLIST_VAR, true ) )
	{
		RegisterNavMesh_EntityMemory( companionEntity, HULL_HUMAN )
	}

	return companionEntity
}

void function CompanionAnimFX_Thread( entity echoEnt , entity player , entity trailFX , entity trailFXEnemy )
{
	echoEnt.EndSignal("OnDestroy")

	OnThreadEnd(
		function() : ( trailFX , trailFXEnemy)
		{
			if ( IsValid( trailFX ) )
			{
				EffectStop( trailFX )
				trailFX.Destroy()
			}
			if ( IsValid( trailFXEnemy ) )
			{
				EffectStop( trailFXEnemy )
				trailFXEnemy.Destroy()
			}
		}
	)

	bool isPerchedAnimState = true
	echoEnt.Anim_PlayOnly( "fl_perched_idle" )
	trailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY
	trailFXEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY

	while( true )
	{
		bool isActuallyPerched = ( player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) == eCompanionState.PERCHED )
		//
		if ( !isPerchedAnimState && isActuallyPerched )
		{
			echoEnt.Anim_PlayOnly( "fl_perched_idle" )
			trailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY
			trailFXEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY
			isPerchedAnimState = true
		}
		else if ( isPerchedAnimState &&  !isActuallyPerched )
		{
			echoEnt.Anim_PlayOnly( "fl_flap_cycle_littleHawk" )
			trailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
			trailFXEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
			isPerchedAnimState = false
		}

		WaitFrame()
	}


}


#endif //SERVER

#if DEVELOPER
void function DEV_VantageCompanion_SetDebugDraw( bool enabled )
{
	VANTAGE_COMPANION_DEBUG_DRAW = enabled
}

void function DEV_VantageCompanion_SetOrderDebugDraw( bool enabled )
{
	VANTAGE_COMPANION_ORDER_DEBUG_DRAW = enabled
}
#endif


//////////////////////////////////////////////////////////////////////////////////////////////
// CLIENT
#if CLIENT
void function VantageCompanion_WeaponStatusCheck( entity player, var rui, int slot )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_VANTAGE ) )
		return

	switch ( slot )
	{
		case OFFHAND_LEFT:
			entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_LEFT )
			if ( IsValid( offhandWeapon ) && file.vantageTacticalRui != null )
			{
				UpdateVantageTacticalRui()
			}
			RuiSetBool( rui, "isVisible", false )
			break
	}
}
#endif

#if CLIENT
void function AttemptRecallCompanion( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	if ( !IsAlive( player ) )
		return

	int playerLaunchState = VantageCompanion_GetPlayerLaunchState( player )
	if ( playerLaunchState != ePlayerLaunchState.NONE )
		return

	Remote_ServerCallFunction( "ClientCallback_VantageCompanion_Recall" )
	VantageCompanion_Recall(player)

}
#endif


#if CLIENT
asset function GetARParticleSystemAsset( int orderType )
{
	asset arAsset = FX_COMPANION_ORDER_AR_GROUND
	switch( orderType )
	{
		case eOrderType.GROUND:
			arAsset = FX_COMPANION_ORDER_AR_GROUND
			break
		case eOrderType.WALL:
			arAsset = FX_COMPANION_ORDER_AR_WALL
			break
		case eOrderType.CORNER:
			arAsset = FX_COMPANION_ORDER_AR_CORNER
			break
		case eOrderType.AIR:
			arAsset = FX_COMPANION_ORDER_AR_AIR
			break
	}

	return arAsset
}
#endif

#if CLIENT
void function CreateCompanionARIndicator( entity player, OrderPosData orderPosData )
{
	//Get this base
	asset arAsset = GetARParticleSystemAsset( orderPosData.orderType )
	int arID     = GetParticleSystemIndex( arAsset )

	int fxHandle = StartParticleEffectInWorldWithHandle( arID, orderPosData.arPos, <0, 0, 1> )
	vector endAngles = VectorToAngles( orderPosData.arNormal )
	EffectSetControlPointAngles( fxHandle, 0, endAngles )
	EffectSetControlPointVector( fxHandle, 1, FRIENDLY_COLOR_FX )

	thread DestroyCompanionARAfterTime( fxHandle, COMPANION_AR_MARKER_LIFETIME )


	if ( orderPosData.orderType == eOrderType.CORNER )
	{
		vector flatVecToPrimary = FlattenNormalizeVec(orderPosData.arPosSecondary - orderPosData.arPos )
		int arID2     = GetParticleSystemIndex( FX_COMPANION_ORDER_AR_CORNER_TOP )
		int fxHandle2 = StartParticleEffectInWorldWithHandle( arID2, orderPosData.arPosSecondary, <0, 0, 1> )
		vector secToPrimAngles = VectorToAngles( flatVecToPrimary )
		vector secAngles = VectorToAngles( orderPosData.arNormalSecondary )
		vector finalAngles = secAngles + secToPrimAngles
		EffectSetControlPointAngles( fxHandle2, 0, finalAngles )
		EffectSetControlPointVector( fxHandle2, 1, FRIENDLY_COLOR_FX )


		thread DestroyCompanionARAfterTime( fxHandle2, COMPANION_AR_MARKER_LIFETIME )
	}


	//entity echoEnt = VantageCompanion_GetEnt( player )
	//thread DestroyEchoAROnProximity( fxHandle, echoEnt, pos )
}
#endif

#if CLIENT
void function DestroyEchoAROnProximity( int fxHandle, entity echoEnt, vector pos )
{
	echoEnt.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, true, true )
		}
	)

	//float testDistanceSqr = pow( distanceMeters * METERS_TO_INCHES, 2 )
	while ( true )
	{
		//float currentDistanceSqr = DistanceSqr( echo.GetOrigin(), pos )
		float echoSpeedSqr = LengthSqr( echoEnt.GetVelocity() )
		if ( echoSpeedSqr <= COMPANION_AR_SPEED_THRESHOLD_SQR )
			break
	}

}
#endif

#if CLIENT
void function DestroyCompanionARAfterTime( int fxHandle, float time )
{
	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )
		}
	)
	wait(time)
}
#endif

#if CLIENT
void function VantageCompanion_OnPropScriptCreated( entity echoEnt )
{
	if ( echoEnt.GetScriptName() == VANTAGE_COMPANION_SCRIPTNAME )
	{
		entity echoOwner = echoEnt.GetOwner()
		if ( !IsValid( echoOwner) )
			return

		CompanionData newData
		file.companionData[echoOwner] <- newData

		EchoCompanionData newEchoData
		file.echoData[echoOwner] <- newEchoData

		if ( echoOwner == GetLocalViewPlayer() )
		{
			thread VantageCompanion_CreateHUDMarker( echoEnt )
			//thread TestCompanionSendPoint_Thread( ent.GetOwner(), ent )
		}
	}
}
#endif

#if CLIENT
void function VantageCompanion_CreateHUDMarker( entity echoEnt )
{
	EndSignal( echoEnt, "OnDestroy" )
	EndSignal( echoEnt.GetOwner(), "OnDestroy" )

	entity localViewPlayer = GetLocalViewPlayer()

	array<var> ruis

	var rui = CreateCockpitRui( $"ui/echo_screen_marker.rpak", RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), echoEnt.GetOrigin() ) )
	RuiSetImage( rui, "icon", $"rui/hud/tactical_icons/tactical_vantage" )
	RuiSetBool( rui, "isVisible", true )
	RuiSetBool( rui, "pinToEdge", true )
	RuiSetBool( rui, "showClampArrow", true )
	RuiSetFloat( rui, "distanceFade", VANTAGE_COMPANION_ICON_FADE_DIST_NEAR )
	RuiSetFloat( rui, "prelaunchDuration", 1.4 )

	RuiSetBool( rui, "showIconOnScreen", true )

	RuiSetBool( rui, "adsFade", false )
	RuiTrackFloat3( rui, "pos", echoEnt, RUI_TRACK_POINT_FOLLOW, echoEnt.LookupAttachment( "ORIGIN" ))

	ruis.append(rui)

	array<int> fxs

	entity locLineFXMover
	int locLineFXHandle
	int locEndFXHandle

	locLineFXMover = CreateClientsideScriptMover( EMPTY_MODEL, <0, 0, 0>, <0, 0, 0> )
	locLineFXMover.SetParent( echoEnt )

	int arID = GetParticleSystemIndex( FX_LOC_LINE )

	locLineFXHandle = StartParticleEffectOnEntity( locLineFXMover, arID, FX_PATTACH_ABSORIGIN, ATTACHMENTID_INVALID )

	int endID       = GetParticleSystemIndex( FX_LOC_LINE_END )
	locEndFXHandle = StartParticleEffectOnEntity( locLineFXMover, endID, FX_PATTACH_ABSORIGIN, ATTACHMENTID_INVALID )
	//EffectSetControlPointVector( locEndFXHandle, 1, FRIENDLY_COLOR_FX )

	fxs.append(locLineFXHandle)
	fxs.append(locEndFXHandle)


	OnThreadEnd(
		function() : ( ruis , fxs , locLineFXMover)
		{
			foreach( rui in ruis )
				RuiDestroy( rui )

			foreach( fxHandle in fxs )
			{
				if ( EffectDoesExist( fxHandle ) )
					EffectStop( fxHandle, true, true )
			}

			if ( IsValid(locLineFXMover) )
				locLineFXMover.Destroy()
		}
	)

	while( true )
	{
		entity vantagePlayer = echoEnt.GetOwner()
		if( IsValid( vantagePlayer ) )
		{
			if ( vantagePlayer in file.echoData )
			{
				int companionState    = vantagePlayer.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT )
				int playerLaunchState = VantageCompanion_GetPlayerLaunchState( vantagePlayer )

				// On Sceen marker
				entity vantageTacWeapon = vantagePlayer.GetOffhandWeapon( OFFHAND_TACTICAL )
				bool hasAmmo            = false
				if ( IsValid( vantageTacWeapon) )
				{
					hasAmmo = vantageTacWeapon.GetWeaponPrimaryClipCount() >= vantageTacWeapon.GetAmmoPerShot()

					RuiSetBool( rui, "hasAmmo", hasAmmo )
				}

				int canLaunchResult = CanLaunchToCompanion( vantagePlayer, echoEnt )
				bool canLaunch = canLaunchResult == eCanLaunchResult.SUCCESS
				RuiSetBool( rui, "canLaunch", canLaunch )
				RuiSetInt( rui, "launchState", playerLaunchState )

				RuiSetInt( rui, "companionState", companionState )


				#if DEVELOPER
				if ( VANTAGE_COMPANION_DEBUG_DRAW )
				{
					vector color = <0, 200, 50>
					string text = "CLIENT"
					//State
					text += "\nCompanion state: " + sCompanionStateStrings[companionState]
					text += "\nLaunch state: " + sPlayerLaunchStateStrings[playerLaunchState]

					DebugDrawScreenTextWithColor( 0.7, 0.7, text, color )
				}
				#endif

				UpdateLocLineFX( echoEnt, locLineFXHandle, locEndFXHandle )

				float distanceSqr  = DistanceSqr( echoEnt.GetOrigin(),  vantagePlayer.GetOrigin() )

				bool shouldShowLocFX = companionState != eCompanionState.PERCHED && ( distanceSqr > VANTAGE_COMPANION_GROUND_UI_MIN_DIST_SQR )
				if ( shouldShowLocFX )
				{
					locLineFXMover.Show()
				}
				else
				{
					locLineFXMover.Hide()
				}

				// Control HUD
				if( file.vantageTacticalRui != null )
				{
					RuiSetInt( file.vantageTacticalRui, "companionState", companionState )

					float distanceTo = Distance( vantagePlayer.GetOrigin(), echoEnt.GetOrigin() )
					RuiSetFloat( file.vantageTacticalRui, "distanceTo", distanceTo )

					if( file.previousCompanionState <= eCompanionState.PERCHED && companionState >= eCompanionState.ORDERED_TO_POSITION )
					{
						RuiSetFloat( file.vantageTacticalRui, "orderedTransitionTime", Time() )
					}
				}

				const bool DEBUG_VISIBILITY = false
				if ( DEBUG_VISIBILITY )
				{
					if ( canLaunchResult == eCanLaunchResult.SUCCESS )
					{
						DebugDrawSphere( echoEnt.GetOrigin(), 10, <0, 255,50>, true, 0.1)
					}
					else
					{
						DebugDrawSphere( echoEnt.GetOrigin(), 7, <255, 50,0>, true, 0.1)
						string cantLaunchText = "FAIL"
						if ( canLaunchResult == eCanLaunchResult.NO_OFF_SCREEN )
							cantLaunchText = "OffScreen"
						else if ( canLaunchResult == eCanLaunchResult.NO_LOS_FAIL )
							cantLaunchText = "No LOS"
						else if ( canLaunchResult == eCanLaunchResult.PLAYER_STATE )
							cantLaunchText = "Player State"
						DebugDrawText( echoEnt.GetOrigin(), cantLaunchText,false, 0.1 )
					}

				}
				file.previousCompanionState = companionState
			}
		}
		WaitFrame()
	}
}
#endif

#if CLIENT
void function UpdateLocLineFX( entity echoEnt, int lineHandle, int endHandle )
{
	const float TRACE_DIST = 10000
	vector startTrace = echoEnt.GetOrigin()
	vector endTrace = echoEnt.GetOrigin() - UP_VECTOR*TRACE_DIST
	TraceResults tr = TraceLine( startTrace, endTrace , [],TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE, echoEnt)

	float endTime = Distance( startTrace, tr.endPos )

	float gravity = GetConVarFloat( "sv_gravity" )
	vector gravityVector = < 0,0,0>
	vector endTimeVector = < 1, 9999,9999 >
	vector offsetVector = ZERO_VECTOR

	//R5DEV-369085 - Guarding against this effect being killed (unsure of the how/why no solid repro.)
	if ( EffectDoesExist( lineHandle ) )
	{
		EffectWake( lineHandle )

		///////////////////////////////////////////////////
		//Dfranco uncomment this section
		EffectSetControlPointVector( lineHandle, 1, echoEnt.GetOrigin() )
		EffectSetControlPointVector( lineHandle, 0, tr.endPos )
		///////////////////////////////////////////////////

		//////////////////////////
		// Old setup here Dfranco, comment this out
		//EffectSetControlPointVector( lineHandle, 0, echoEnt.GetOrigin() )
		//EffectSetControlPointVector( lineHandle, 1, -UP_VECTOR*endTime)

		EffectSetControlPointVector( lineHandle, 2, offsetVector )
		//
		EffectSetControlPointVector( lineHandle, 3, gravityVector ) //Vector( gravInfo.baseGravity, gravInfo.gravityStage2, gravInfo.gravityStageFinal ) );
		////EffectSetControlPointVector( arcHandle, 4, hawkPlayer.GetOrigin() )
		EffectSetControlPointVector( lineHandle, 5, ZERO_VECTOR ) //Vector( gravInfo.baseFriction, gravInfo.frictionStage2, gravInfo.frictionStageFinal ) );
		EffectSetControlPointVector( lineHandle, 6, endTimeVector ) //Vector( pathOut.endTime, gravInfo.gravityStage2StartTime, gravInfo.gravityStageFinalStartTime ) );
		EffectSetControlPointVector( lineHandle, 7, -UP_VECTOR * endTime ) //pathIn.gravityLaunchVelocity );
		///////////////////////////////////
	}


	//for ( int i = 0; i < 4; i++ )
	//{
	//	vector angles = VectorToAngles( -UP_VECTOR )
	//	EffectSetControlPointAngles( lineHandle, 0, angles )
	//}

	if ( EffectDoesExist( endHandle ) )
	{
		EffectWake( endHandle )
		EffectSetControlPointVector( endHandle, 0, tr.endPos )
		//EffectSetControlPointVector( endHandle, 0, tr.endPos )

		vector endAngles = VectorToAngles( tr.surfaceNormal )
		EffectSetControlPointAngles( endHandle, 0, endAngles )
	}

}
#endif

#if CLIENT
var function GetVantageTacticalRui()
{
	return file.vantageTacticalRui
}
#endif

#if CLIENT
void function CreateVantageTacticalRui_Internal( entity player )
{
	if( file.vantageTacticalRui != null )
		return

	if ( PlayerHasPassive( player, ePassives.PAS_VANTAGE ) )
	{
		if ( file.vantageTacticalRui == null )
		{
			file.vantageTacticalRui = CreateCockpitPostFXRui( $"ui/vantage_companion_tactical.rpak", HUD_Z_BASE )
		}

		UpdateVantageTacticalRui()
	}
}
#endif

#if CLIENT
void function UpdateVantageTacticalRui()
{
	entity localViewPlayer = GetLocalViewPlayer()
	var rui = file.vantageTacticalRui
	if ( IsValid( localViewPlayer ) )
	{
		//RuiTrackFloat( file.vantageTacticalRui, "recallFrac", localViewPlayer, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.crypto_camera_is_recalling )
		RuiTrackFloat( rui, "bleedoutEndTime", localViewPlayer, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
		RuiTrackFloat( rui, "reviveEndTime", localViewPlayer, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )

		entity offhandWeapon = localViewPlayer.GetOffhandWeapon( OFFHAND_TACTICAL )
		if ( IsValid( offhandWeapon ) )
		{
			RuiTrackFloat( rui, "stockAmmoFrac", offhandWeapon, RUI_TRACK_WEAPON_REMAINING_AMMO_FRACTION )
			RuiTrackFloat( rui, "clipAmmoFrac", offhandWeapon, RUI_TRACK_WEAPON_CLIP_AMMO_FRACTION )
			RuiTrackFloat( rui, "maxMagAmmo", offhandWeapon, RUI_TRACK_WEAPON_CLIP_AMMO_MAX )
			RuiTrackFloat( rui, "maxAmmo", offhandWeapon, RUI_TRACK_WEAPON_AMMO_MAX )
			RuiTrackFloat( rui, "regenAmmoRate", offhandWeapon, RUI_TRACK_WEAPON_AMMO_REGEN_RATE )

			int maxAmmoReady  = offhandWeapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size )
			int ammoPerShot   = offhandWeapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
			int ammoMinToFire = offhandWeapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )

			if ( maxAmmoReady == 0 )
				maxAmmoReady = 1

			RuiSetFloat( rui, "minFireFrac", float( ammoMinToFire ) / float( maxAmmoReady ) )
			RuiSetInt( rui, "ammoMinToFire", ammoMinToFire )

			if ( ammoPerShot == 0 )
				ammoPerShot = 1

			RuiSetInt( rui, "segments", maxAmmoReady / ammoPerShot )
			RuiTrackFloat( rui, "chargeFrac", offhandWeapon, RUI_TRACK_WEAPON_CLIP_AMMO_FRACTION )
			RuiTrackFloat( rui, "refillRate", offhandWeapon, RUI_TRACK_WEAPON_AMMO_REGEN_RATE )
			RuiTrackFloat( rui, "readyFrac", offhandWeapon, RUI_TRACK_WEAPON_READY_TO_FIRE_FRACTION )
		}

		               
			if ( StatusEffect_HasSeverity( localViewPlayer, eStatusEffect.is_boxing ) )
				RuiSetBool( file.vantageTacticalRui, "isBoxing", true )
			else
				RuiSetBool( file.vantageTacticalRui, "isBoxing", false )
        
	}
}
#endif

#if CLIENT
void function TrackVantageAnimatedTacticalRuiOffhandWeapon()
{
	if ( file.vantageTacticalRui != null )
	{
		entity localViewPlayer = GetLocalViewPlayer()
		if ( IsValid( localViewPlayer ) )
		{
			entity offhandWeapon = localViewPlayer.GetOffhandWeapon( OFFHAND_LEFT )
			if ( IsValid( offhandWeapon ) )
			{
				RuiTrackFloat( file.vantageTacticalRui, "clipAmmoFrac", offhandWeapon, RUI_TRACK_WEAPON_CLIP_AMMO_FRACTION )

                           
                                                 
     
                                                                                                          
                                                                                                  
                                                                                                                       
                                                                           
     
          
			}
		}
	}
}
#endif

#if CLIENT
void function DestroyVantageTacticalRui( entity player )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_VANTAGE ) )
	{
		if ( file.vantageTacticalRui != null )
		{
			RuiDestroy( file.vantageTacticalRui )
			file.vantageTacticalRui = null
		}
	}
}
#endif