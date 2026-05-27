global function MpAbilityArmoredLeap_Init
global function OnWeaponActivate_ability_armored_leap
global function OnWeaponDeactivate_ability_armored_leap
global function OnWeaponReadyToFire_ability_armored_leap
global function OnWeaponPrimaryAttack_ability_armored_leap
global function OnWeaponPrimaryAttackAnimEvent_ability_armored_leap

global function CodeCallback_ArmoredLeapPhaseChange

global const string ARMORED_LEAP_WEAPON_NAME = "mp_ability_armored_leap"
global const string ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME 		= "al_shield_anchor"
global const string CASTLE_WALL_SNAKEHEAD_SCRIPTNAME 		= "axiom_castle_wall_snakehead"
global const string ARMORED_LEAP_SHIELD_BARRIER_SCRIPTNAME 		= "al_shield_barrier"
global const string CASTLE_WALL_THREAT_TARGETNAME = "axiom_castle_wall_threat"
global const string ARMORED_LEAP_IMPACT_ZONE_THREAT_TARGETNAME = "axiom_impact_zone_threat"

global const string ARMORED_LEAP_SHIELD_ANCHOR_LEFT = "al_shield_anchor_l"
global const string ARMORED_LEAP_SHIELD_ANCHOR_CENTER = "al_shield_anchor_c"
global const string ARMORED_LEAP_SHIELD_ANCHOR_RIGHT = "al_shield_anchor_r"
global const string ARMORED_LEAP_SHIELD_LOW_LEFT = "al_shield_low_l"
global const string ARMORED_LEAP_SHIELD_LOW_RIGHT = "al_shield_low_r"

const string ARMORED_LEAP_MOVER_SCRIPTNAME = "Newcastle_Leap_mover"

global function IsCastleWallEnt
global function CastleWall_EntityShouldBeHighlighted
global function ArmoredLeap_TargetEntityShouldBeHighlighted
global function ArmoredLeap_HandleInterruptedMidLeap
global function GetCurrentArmoredLeapPhase

#if SERVER
global function ClientCallback_TryPickupCastleWall
#endif

#if CLIENT
global function ServerToClient_ArmoredLeap_AirLaunchComplete
global function ServerToClient_ArmoredLeap_GroundDiveComplete
global function ServerToClient_ArmoredLeapComplete
global function ServerToClient_ArmoredLeapShutdown
global function ServerToClient_ArmoredLeapInterrupted
global function ServerToClient_VisorMode_DeActivate
global function ServerToClient_SetClient_AllyInDanger
global function ServerToClient_RescueTargetRui_Activate
global function ServerToClient_RescueTargetRui_Deactivate
global function ServerToClient_SetClient_BleedoutWaypoint
global function ServerToClient_RemoveClient_BleedoutWaypoint
#endif

//VFX THREAT TESTS - VISOR //
const bool VISOR_THREAT_DETECTION							= true

                    
const bool CASTLE_WALL_STOPS_GRENADES						= true
      

#if DEV
const bool DEBUG_ARMORED_LEAP_TARGETING_DRAW 				= false
const bool DEBUG_SNAKE_DRAW 								= false
const bool DEBUG_DEV_TEST_FLAG								= false		//Turn on in box when Bot-Recording - prevents endless walls.
const bool DEBUG_THREAT_INDICATORS							= false
const bool DEBUG_DRAW_PUSHER_MOVEMENT						= false
const bool DEBUG_DRAW_DAMAGE_BARRIERS						= false
const bool DEBUG_CAMERA_LERP								= false
const bool DEBUG_PHASE_CHANGES								= false
const bool DEBUG_BETTER_AIR_POS								= false
const bool DEBUG_DRAW_ANTI_GRENADE_DEBUG					= false
#endif //DEV


const float ARMORED_LEAP_DISTANCE_MIN 						= 50.0
const float ARMORED_LEAP_DISTANCE 							= 40 * METERS_TO_INCHES //
const float ARMORED_LEAP_MAX_ALLY_RANGE 					= 80 * METERS_TO_INCHES //
const float ARMORED_LEAP_MAX_SLAM_FOLLOW_DISTANCE 			= 1500
const float ARMORED_LEAP_MAX_LEAP_HEIGHT 					= 25 * METERS_TO_INCHES //800 		//(20m)
const float ARMORED_LEAP_MAX_LEAP_HEIGHT_ALLY 				= 50 * METERS_TO_INCHES //2000 		//(50m)
const float ARMORED_LEAP_MIN_AIR_HEIGHT 					= 100 //150
const float ARMORED_LEAP_CLOSE_AIR_HEIGHT 					= 200		// Max Air Height of a Leap - Axiom jumps higher at closer ranges
const float ARMORED_LEAP_FAR_AIR_HEIGHT 					= 500		// Air Height of a FAR Leap - Axiom jumps lower - but farther - at longer ranges
const float ARMORED_LEAP_MAX_AIR_HEIGHT 					= 800		// Max Air Height of a Leap - Axiom jumps higher at closer ranges
const float ARMORED_LEAP_FAR_AIR_HEIGHT_DIST 				= 1000 		// The distance at which we cap to the FAR air height
const float ARMORED_LEAP_AIR_POS_OFFSET						= 150		// Horizontal offset distance from the slam position - use for Air Position of Leap
const float ARMORED_LEAP_HUMAN_HEIGHT_OFFSET				= 90 //82		// Vertical Buffer to account for standing players (may need to find the real number...but this is close for now)
const float ARMORED_LEAP_GROUND_DASH_RANGE 					= 600
const float ARMORED_LEAP_GROUND_DASH_HEIGHT_LIMIT 			= 250
const float ARMORED_LEAP_AIR_LAUNCH_SPEED					= 1000		// Speed to dash to the Air Position (will be affected by Ease-Out Time)
const float ARMORED_LEAP_GROUND_DASH_SPEED 					= 1500		// Speed to slam into the ground at (will be affected by Ease-In Time)
const float ARMORED_LEAP_SLAM_SPEED_NEAR 					= 2000 //2500		// Speed to slam into the ground at (will be affected by Ease-In Time)
const float ARMORED_LEAP_SLAM_SPEED_FAR 					= 2500 //3500		// Speed to slam into the ground at (will be affected by Ease-In Time)
const float ARMORED_LEAP_AIR_LAUNCH_EASE_OUT_TIME			= 0.8 		// "Hang Time Tunable" Determines how much of the time it takes to launch is used to slow to 0 as the player moved to the Air Point. 					//Affects Launch Speed//
const float ARMORED_LEAP_SLAM_EASE_IN_TIME					= 0.9 		// "Hang Time Tunable" Determines how much of the time it takes to slam is used to wind-up from 0 to the speed used to slam to the Ground Point 	//Affects Slam Speed//
const float ARMORED_LEAP_LAUNCH_CROUCH_TIME 				= 0.4		//0.6
const float ARMORED_LEAP_LAUNCH_DASH_CROUCH_TIME 			= 0.6
const float ARMORED_LEAP_AIRPOS_CHECK_RANGE 				= 20		// Used to determine when "close enough" to desired Air Position for Slam to begin
const float ARMORED_LEAP_GROUNDPOS_CHECK_RANGE 				= 80		// Impact Point Offset distance to prevent Slam from pushing player into the ground.
const float ARMORED_LEAP_AIR_HOVER_TIME 					= 0.55 //1.0
const float ARMORED_LEAP_AIR_HOVER_GRAVITY 					= 0.45
const float ARMORED_LEAP_AIR_HOVER_VEL_SCALAR 				= 0.5
const float ARMORED_LEAP_INTERRUPTED_VELOCITY_SCALE			= 0.35 //If interrupted, Newcastle will keep this % of his travel velocity if its over 300 u/s.

// New Code-Movement Variables //
const float ARMORED_LEAP_SLAM_SPEED_MAX 					= 3500
const float ARMORED_LEAP_GROUND_DASH_SPEED_MIN 				= 800
const float ARMORED_LEAP_GROUND_DASH_SPEED_MAX 				= 1500
const float ARMORED_LEAP_GROUND_DASH_ACCEL 					= 12000

const float ARMORED_LEAP_JUMP_SPEED_MIN 					= 1800
const float ARMORED_LEAP_JUMP_SPEED_MAX 					= 2500
const float ARMORED_LEAP_HOVER_SPEED_MIN					= 320
const float ARMORED_LEAP_HOVER_SPEED_MAX					= 400

const float ARMORED_LEAP_JUMP_ACCEL							= 24000
const float ARMORED_LEAP_HOVER_ACCEL 						= 9000
const float ARMORED_LEAP_DIVE_ACCEL 						= 9000

const float ARMORED_LEAP_AIRPOS_CHECK_RANGE_MIN				= 300
const float ARMORED_LEAP_AIRPOS_CHECK_RANGE_MAX				= 400

const float ARMORED_LEAP_HOVER_DIVE_PREP_SPEED 				= 150
const float ARMORED_LEAP_HOVER_DIVE_PREP_ACCEL				= ARMORED_LEAP_HOVER_DIVE_PREP_SPEED / 0.25


const vector ARMORED_LEAP_COL_MINS 							= <-16,-16, 0  > //Min Capsule Test Size for Trajectory & Collision test during leap
const vector ARMORED_LEAP_COL_MAXS 							= < 16, 16, 16 > //Max Capsule Test Size for Trajectory & Collision test during leap
const vector ARMORED_LEAP_ENDPOINT_BUFFER 					= <0,0,8>		 //Minor ground offset buffer for landing area tests
const float ARMORED_LEAP_AIR_DIVE_LONG_DIST					= 600			//If an air dive is longer than this 2D distance, trigger the "long" dive anim states
const float ARMORED_LEAP_TIMEOUT_JUMP						= 2.75			//Max range jumps seem to take roughly 2.46s
const float ARMORED_LEAP_TIMEOUT_AIR_DIVE					= 2.75			//Air dive 2.509s
const float ARMORED_LEAP_TIMEOUT_DASH						= 2.5			//Dash 2.145s
const float ARMORED_LEAP_TIMEOUT_JUMP_ALLY					= 3.25			//Ally jump 3.11s

const float ARMORED_LEAP_DOT_TO_ALLY_TARGET 				= 0.95		// How close to center screen an ally must be to become a Valid Target
const float ARMORED_LEAP_ALLY_DANGER_ALERT_TIME 			= 16.0		// How long to maintain ALERT status in Newcastle Targeting after an Ally is considered IN DANGER
const float ARMORED_LEAP_ALLY_DANGER_DISTANCE_MAX			= 200

const bool  ARMORED_LEAP_ALLOW_START_ON_MOVERS_DEFAULT 		= true		//Rules for Deployment on Movers ( as Ash's Phase Breach )
const bool  ARMORED_LEAP_ALLOW_END_ON_MOVERS_DEFAULT 		= true
const float ARMORED_LEAP_MOVERS_MAX_SPEED_FOR_END_DEFAULT 	= 12.0

const float ARMORED_LEAP_WARNING_DURATION 					= 1.5
const float ARMORED_LEAP_RECOVERY_TIME						= 0.75 		//0.75 //Amount of time movement is HELD for after a slam
const float ARMORED_LEAP_CAM_RECOVERY_TIME					= 0.5		//Amount of time we hold the camera in 3P before returning to 1P (0.75s transition)
const float ARMORED_LEAP_RECOVERY_MOVESLOW_DURATION 		= 1.0
const float ARMORED_LEAP_ABOVE_LEDGE_DEGREE_CHECK_OFFSET 	= 8 		//Degrees below the player's View Vector to check for Ledges
const float ARMORED_LEAP_LEDGE_INSET_AMOUNT			 		= 100//50 		//How far onto a Ledge we want to cast the End Position of the Jump
const float ARMORED_LEAP_LEDGE_INSET_DOWN_TRACE 			= -100 		//How far past the inset position to look for valid ground (allows jumps to clear small wall ledges)
const float ARMORED_LEAP_ABOVE_LEDGE_DOWN_TRACE_OFFSET 		= 200 		//How high above the Ledge Inset we trace down from to determine a clear path
const float ARMORED_LEAP_MIN_TARGET_DIST_TO_WALL 			= 75.0		//How far from a wall the targeting is allowed to be
const float ARMORED_LEAP_OFFSET_TEST_HEIGHT 				= 48.0 		//Test height used to evaluate down from in endPoint ground checks. Around middle of a character to cover most slope grades

//3p Camera
const float ARMORED_LEAP_INITIAL_CAMERA_DIST				= 75.0 //65.0 //90.0
const float ARMORED_LEAP_AIR_CAMERA_DIST					= 115.0
const float ARMORED_LEAP_SLAM_CAMERA_DIST					= 45.0
const float ARMORED_LEAP_END_CAMERA_DIST					= 85.0 //45.0

const float ARMORED_LEAP_INITIAL_CAMERA_RIGHT				= -35.0 //0 //-25.0
const float ARMORED_LEAP_AIR_CAMERA_RIGHT					= -35.0
const float ARMORED_LEAP_SLAM_CAMERA_RIGHT					= -35.0
const float ARMORED_LEAP_END_CAMERA_RIGHT					= -15.0

const float ARMORED_LEAP_INITIAL_CAMERA_HEIGHT				= 10.0 //25.0//10.0
const float ARMORED_LEAP_AIR_CAMERA_HEIGHT					= 35.0
const float ARMORED_LEAP_SLAM_CAMERA_HEIGHT					= 15.0
const float ARMORED_LEAP_END_CAMERA_HEIGHT					= 4.5 //7.5

const float ARMORED_LEAP_IMPACT_RANGE 						= 350.0
const float ARMORED_LEAP_MIN_FORCE 							= 250 //200
const float ARMORED_LEAP_MAX_FORCE 							= 450
const int ARMORED_LEAP_DAMAGE 								= 0 //25
const int ARMORED_LEAP_DAMAGE_MIN							= 0 //5

const float ARMORED_LEAP_VISOR_POST_LANDING_DURATION 		= 0.5 //1.5
const int ARMORED_LEAP_REFUND_AMOUNT_FRAC 					= 85		//Amount of Ultimate Charge Restored if you go down before deploying the Shield Wall (max 120 - so it's ~70%)

//GAMEPLAY TUNING - CASTLE WALL //
const int CASTLE_WALL_SHIELD_ANCHOR_HEALTH 						= 750	//( 500 )
const int CASTLE_WALL_MAX_NUM_CASTLES							= 1
const float CASTLE_WALL_SPAWN_OFFSET 							= 50	//How far from the Player to Spawn the Walls
const float CASTLE_WALL_SPAWN_GROUND_CHECK_DIST 				= 100
const float CASTLE_WALL_SPAWN_OFFSET_STEP 						= 10
const float CASTLE_WALL_SPAWN_UPTRACE_OFFSET 					= 32
const float CASTLE_WALL_SHIELD_THICKNESS 						= 5
const float CASTLE_WALL_HIGH_WALL_DEPLOY_DELAY 					= 0.15	//1
const float CASTLE_WALL_HIGH_WALL_PLANTED_Z_OFFSET 				= 28

const float CASTLE_WALL_OVERLAP_CLEANUP_RADIUS_SEGMENT 			= 40
const float CASTLE_WALL_OVERLAP_CLEANUP_RADIUS_ANCHOR			= 180

const int CASTLE_WALL_BARRIER_DAMAGE 							= 20
const float CASTLE_WALL_BARRIER_DAMAGE_INTERVAL 				= 2.5	// How often the Shield deals EMP Damage (also how long the status effect lasts)
const float CASTLE_WALL_BARRIER_DELAY_TIME 						= 3.0	// This is not go lower than the minimum time it takes to construct the Castle
const float CASTLE_WALL_BARRIER_DURATION 						= 60.0
const float CASTLE_WALL_BARRIER_WARNING_DURATION 				= 2.0

const float CASTLE_WALL_WARNING_RADIUS 							= 150

const float CASTLE_WALL_PROTECTION_AREA_RANGE 					= 250

//SNAKE VERSION TUNING VARIABLES
const float CASTLE_SNAKE_WALL_HIGHCOVER_HEIGHT_OFFSET 			= 15	//40	//55
const float CASTLE_SNAKE_WALL_HIGHCOVER_CORE_OFFSET 			= 115	//130
const float CASTLE_SNAKE_MIN_SEGMENT_DISTANCE 					= 27    //30 //32.0 //20.0 //Distance required before placing another wall segment
//float CASTLE_SNAKE_MAX_NUM_SEGMENTS						= 5
//float CASTLE_SNAKE_MAX_WALL_LENGTH 						= CASTLE_SNAKE_MIN_SEGMENT_DISTANCE * CASTLE_SNAKE_MAX_NUM_SEGMENTS //168 	//140//Approx. for now. We should calculate this based on the length of each segment and max number of segments.
const float CASTLE_SNAKE_GRADUAL_ANGLE_SHIFT 					= 8	//Amount of rotation after each piece is deployed

const float CASTLE_SNAKE_HIGH_COVER_INITIAL_ANGLE_SHIFT 		= 18.0 	//How many degrees the snake turns on init
const float CASTLE_SNAKE_HIGH_COVER_FINAL_ANGLE_SHIFT 			= 10.0 	//How many degrees the snake turns at end - when deploying the High Cover
const float CASTLE_SNAKE_MIN_HIGH_COVER_WALL_LENGTH 			= 32.0 	//Wall must be longer than this amount to be allowed to deploy HighCover end
const float CASTLE_SNAKE_MIN_HIGH_COVER_WIDTH 					= 25.0 	//Wall must be longer than this amount to be allowed to deploy HighCover end
const float CASTLE_SNAKE_WALL_HIGH_COVER_EXTENSION_TIME 		= 0.35
const float CASTLE_SNAKE_MAX_TRAVEL_TIME 						= 3.0   //Maximum amount of time a SnakeHead is allowed to pathfind for (failsafe)
const float CASTLE_SNAKE_MIN_SNAKE_KICKUP_DIST 					= 10.0	//Min Distance Snake needs to travel before playing another "kick-up" impact table effect.


const float CASTLE_SNAKE_MIN_ALLOWED_SNAKE_DEPLOYMENT_RANGE 	= 65 //Minimum Clearance to the side of a Castle Wall to spawn a Snake Head
const float CASTLE_SNAKE_FINAL_SPACING_DISTANCE 				= 40 //Distance from final wall to last segment

const float CASTLE_ANCHOR_SIDE_OFFSET_DEPLOYED 					= 39.25
const float CASTLE_ANCHOR_SIDE_OFFSET_UNDEPLOYED 				= 15 //18

const float CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_LOW 			= 36	//Distance from center of LOW wall required to damage along the "sides"
const float CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_HIGH			= 58	//Distance from center of HIGH wall required to damage along the sides
const float CASTLE_SNAKE_WALL_DAMAGE_VOLUME_THICKNESS 			= 5		//Thickness of Area Trigger from FRONT of the wall
const float CASTLE_SNAKE_WALL_DAMAGE_VOLUME_HEIGHT 				= 80 	// Width of the Shield Damage Volume

////////////////CONSTS FOR SNAKE WALL POSITIONING////////////////////
const float CASTLE_SNAKE_TEST_STEP 								= 64.0
const float CASTLE_SNAKE_CLIMB_HEIGHT 							= 32.0 //64.0 //24.0
const float CASTLE_SNAKE_DROP_TEST_HEIGHT 						= 80 // The height at which we determine the SNAKE can drop to follow a slope. // Past this value, TEST the BROKEN SNAKE drop
const float CASTLE_SNAKE_DROP_TEST_HEIGHT_MAX 					= 100 //250 // The height at which we determine the SNAKE cannot drop ( start looking for BEND instead )
/////////////////////////////////////////////////////////////////////

// CASTLE WALL ALLY OBJECT DESTRUCTION VARIABLES //
const float CASTLE_WALL_ALLY_OBJECT_DESTROYED_RADIUS 			= 35
const float CASTLE_WALL_ALLY_OBJECT_DESTROYED_REFUND_TIME 		= 15
const float CASTLE_WALL_ALLY_OBJECT_DESTROYED_REFUND_FRAC 		= 0.95 //percent of refund

//TARGETING TUNING VARIABLES
const float ARMORED_LEAP_MAX_TARGETING_DIRECTION_RANGE 			= 2500
const float ARMORED_LEAP_MAX_TARGETING_POSITION_RANGE 			= 2500 //750
const float ARMORED_LEAP_TARGETING_FX_DIST_FROM_LANDING			= 50 //150 //200
const float ARMORED_LEAP_TARGETING_MAX_TARGETS					= 10

//VFX//
const vector NC_COLOR_FRIENDLY									= < 64, 220, 255 >
const vector NC_COLOR_BEHIND									= < 128, 128, 128 >
const vector CASTLE_WALL_COLOR_ALLY 							= < 10, 100, 120 >
const float  CASTLE_WALL_ALPHA_ALLY								= 180
const vector CASTLE_WALL_COLOR_ENEMY 							= < 250, 85, 25 >
const float  CASTLE_WALL_ALPHA_ENEMY							= 255

const asset ARMORED_LEAP_AR_TARGET_FX 							= $"P_armored_leap_target"
const asset ARMORED_LEAP_AR_TARGET_FX_ALTZ						= $"P_armored_leap_target_altz"
const asset ARMORED_LEAP_AR_AIM_FX 								= $"P_wrp_trl_end"
const asset ARMORED_LEAP_PREVIEW_RING_FX 						= $"P_armored_leap_preview"
const asset ARMORED_LEAP_ALLY_BEAM_FX 							= $"P_armored_leap_ally_beam"	//Likely overkill. Try to replace with a FRIENDLY targeting diamond at some point
const asset ARMORED_LEAP_PLACEMENT_ARROW_LEAP_FX				= $"P_armored_leap_path_jump"
const asset ARMORED_LEAP_PLACEMENT_ARROW_LEAP_FX_ALTZ			= $"P_armored_leap_path_jump_altz"
const asset ARMORED_LEAP_PLACEMENT_ARROW_DASH_FX				= $"P_armored_leap_path_dash"
const asset ARMORED_LEAP_PLACEMENT_ARC							= $"P_armored_leap_arc"

const asset ARMORED_LEAP_LAUNCH_JET_BACK_FX						= $"P_NC_launch_jet_back"
const asset ARMORED_LEAP_DOWN_JET_BACK_FX						= $"P_NC_down_jet_back"
const asset ARMORED_LEAP_LAUNCH_JET_LEG_FX						= $"P_NC_launch_jet_leg"
const asset ARMORED_LEAP_AFTERBURNER_FX							= $"P_NC_lanuch_aftburn_trail"
const asset ARMORED_LEAP_ENERGY_RADIUS_FX 						= $"P_armored_leap_radius" //P_emp_charge_radius_MDL"

const asset ARMORED_LEAP_IMPACT_FX 								= $"P_armored_leap_shockwave"
const string ARMORED_LEAP_IMPACT_FX_TABLE 						= "exp_armored_leap_WallSlam"	// New FX w Sound
const string CASTLE_WALL_SNAKE_IMPACT_FX_TABLE 					= "pilot_bodyslam"   	 		// using bodyslam.  looks good to me

const asset CASTLE_WALL_SHIELD_ANCHOR_COL_FX 					= $"mdl/fx/newcastle_ar_wall.rmdl" //$"mdl/fx/jericho_gun_shield.rmdl" //
const asset CASTLE_WALL_SHIELD_WALL_CENTRE_MDL 					= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_large_w.rmdl" //newcastle_shield_wall_v21_middle_w.rmdl"
const asset CASTLE_WALL_SHIELD_WALL_ENDS_L_MDL 					= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_large_w.rmdl"  //$"mdl/props/newcastle_shield_wall/newcastle_shield_wall_v21_ends_w.rmdl"
const asset CASTLE_WALL_SHIELD_WALL_ENDS_R_MDL 					= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_large_w.rmdl"  //$"mdl/props/newcastle_shield_wall/newcastle_shield_wall_v21_ends_w.rmdl"
const asset CASTLE_WALL_SHIELD_WALL_ENDS_LOW_COL_L_MDL			= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_left_compact_w.rmdl"
const asset CASTLE_WALL_SHIELD_WALL_ENDS_LOW_COL_R_MDL			= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_right_compact_w.rmdl"
const asset CASTLE_WALL_SHIELD_WALL_SEG_L_MDL 					= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_left_small_w.rmdl" //$"mdl/props/newcastle_shield_wall/newcastle_shield_wall_v21_small_left_w.rmdl"
const asset CASTLE_WALL_SHIELD_WALL_SEG_R_MDL 					= $"mdl/props/newcastle_shield_wall/newcastle_wall_v22_right_small_w.rmdl" //$"mdl/props/newcastle_shield_wall/newcastle_shield_wall_v21_small_right_w.rmdl"


const CASTLE_WALL_SHIELD_ANCHOR_DESTROYED_FX 					= $"P_armored_leap_wall_destruction"
const CASTLE_WALL_SHIELD_ANCHOR_DESTROYED_LARGE_FX				= $"P_armored_leap_wall_lg_destruction"
const asset CASTLE_WALL_EMP_FX_3P 								= $"P_emp_body_human"
const asset CASTLE_WALL_BARRIER_BEAM_FX 						= $"P_tesla_trap_link_CP" //$"P_wpn_monarch_beam_v2"
const asset CASTLE_WALL_ELEC_PANEL_LG_FX 						= $"P_armored_leap_elec_panel_lg_01"
const asset CASTLE_WALL_ELEC_PANEL_LG_R_FX 						= $"P_armored_leap_elec_panel_lg_R"
const asset CASTLE_WALL_ELEC_PANEL_LG_L_FX 						= $"P_armored_leap_elec_panel_lg_L"
const asset CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT 					= $"P_armored_leap_elec_panel_sm_l_01"
const asset CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT_02				= $"P_armored_leap_elec_panel_sm_l_02"
const asset CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT_03				= $"P_armored_leap_elec_panel_sm_l_03"
const asset CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT					= $"P_armored_leap_elec_panel_sm_r_01"
const asset CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT_02				= $"P_armored_leap_elec_panel_sm_r_02"
const asset CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT_03				= $"P_armored_leap_elec_panel_sm_r_03"

                    
const asset CASTLE_WALL_INTERCEPT_PROJECTILE_SMALL_FX 			= $"P_armored_wall_zap"
const asset CASTLE_WALL_INTERCEPT_PROJECTILE_SMALL_ENEMY_FX 	= $"P_armored_wall_zap_enemy"
const asset CASTLE_WALL_INTERCEPT_PROJECTILE_CLOSE_FX 			= $"P_armored_wall_zap"
const asset CASTLE_WALL_INTERCEPT_PROJECTILE_CLOSE_ENEMY_FX 	= $"P_armored_wall_zap_enemy"

const string CASTLE_WALL_INTERCEPT_BEAM_SOUND 					= "Newcastle_Tactical_InterceptBeam"
const string CASTLE_WALL_INTERCEPT_SMALL 						= "Newcastle_Tactical_InterceptZap"

      

//SFX//
const string ARMORED_LEAP_SOUND_ACTIVATE_3P						= "Newcastle_Ultimate_Prep_3P" 	// //Wraith_PhaseGate_FirstGate_DeviceActivate_3p
const string ARMORED_LEAP_SOUND_LAUNCH_3P						= "Newcastle_Ultimate_Launch_3p" 	//"Valk_Ultimate_BlastOff_3P"
const string ARMORED_LEAP_SOUND_DIVESLAM_3P						= "Newcastle_Ultimate_AirborneBoost_3p" 	//"Valk_Ultimate_BlastOff_3P"
const string ARMORED_LEAP_SOUND_AIR_MVMT_3P						= "Newcastle_Ultimate_AirborneMvmt_3p"
const string ARMORED_LEAP_SOUND_ACTIVATE_1P						= "Newcastle_Ultimate_UI_LoopStop"
const string ARMORED_LEAP_SOUND_TO_STOP_1P						= "newcastle_ultimate_ui" //can be started via animation event, not currently stopping reliably though, so going to stop via script as well - R5DEV-352806
const string ARMORED_LEAP_SOUND_LAUNCH_1P						= "Newcastle_Ultimate_Launch_1p"		//"Valk_Ultimate_BlastOff_1P"
const string ARMORED_LEAP_SOUND_DIVESLAM_1P						= "Newcastle_Ultimate_AirborneBoost_1p" 	//"Valk_Ultimate_BlastOff_3P"
const string ARMORED_LEAP_SOUND_AIR_MVMT_1P						= "Newcastle_Ultimate_AirborneMvmt_1p"

const string CASTLE_WALL_PLACED_SFX_3P 							= "Newcastle_Ultimate_Wall_Place_3p"
const string CASLTE_WALL_LANDS_ON_GROUND 						= "Newcastle_Ultimate_Wall_Land_Default"

const string CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND 				= "Newcastle_Ultimate_Wall_Loop"
const string CASTLE_WALL_BARRIER_END_WARNING_SOUND 				= "Newcastle_Ultimate_Wall_Warn2End"
const string CASTLE_WALL_BARRIER_DISSOLVE_SOUND 				= "Newcastle_Ultimate_Wall_Dissolve"
const string CASTLE_WALL_SHIELD_ANCHOR_DESTROY_SOUND 			= "Newcastle_Ultimate_Wall_Destroy"
const string CASTLE_WALL_BARRIER_DAMAGE_1P_SOUND 				= "Newcastle_Ultimate_Wall_Damage_1p"
const string CASTLE_WALL_BARRIER_DAMAGE_3P_SOUND 				= "Newcastle_Ultimate_Wall_Damage_3p"

const string ARMORED_LEAP_ALLY_TARGETED_SFX_1P 					= "Newcastle_Teamscan_Ping"

const string ARMORED_LEAP_ALLY_TARGETED_CHATTER_1P 				= "diag_mp_newcastle_bc_superSquadTargeted_1p"
const string ARMORED_LEAP_ALLY_TARGETED_CHATTER_3P 				= "diag_mp_newcastle_bc_superSquadTargeted_3p"
const string ARMORED_LEAP_ALLY_BUDDY_TARGETED_CHATTER_3P 		= "diag_mp_newcastle_bc_superSquadObserving_3p"
const string CASTLE_WALL_DESTROYED_CHATTER_VO_1P 				= "diag_mp_newcastle_bc_superDestroyed_1p"
const string CASTLE_WALL_DESTROYED_CHATTER_VO_3P 				= "diag_mp_newcastle_bc_superDestroyed_3p"
const string CASTLE_WALL_REMOVED_CHATTER_VO_1P 					= "diag_mp_newcastle_bc_superAdjust_1p"
const string CASTLE_WALL_REMOVED_CHATTER_VO_3P 					= "diag_mp_newcastle_bc_superAdjust_3p"

const string ARMORED_LEAP_TARGET_FAIL_DEFAULT					= "#HINT_NEWCASTLE_LEAP_TARGET_FAIL_DEFAULT"
const string ARMORED_LEAP_TARGET_FAIL_BLOCKED_LAND				= "#HINT_NEWCASTLE_LEAP_TARGET_FAIL_BLOCKED_LAND"
const string ARMORED_LEAP_TARGET_FAIL_BLOCKED_LEAP				= "#HINT_NEWCASTLE_LEAP_TARGET_FAIL_BLOCKED_LEAP"
const string ARMORED_LEAP_TARGET_FAIL_BLOCKED_ALLY				= "#HINT_NEWCASTLE_LEAP_TARGET_FAIL_BLOCKED_ALLY"
//////

//SIGNALS//

struct ArmoredLeapTargetInfo
{
	array<vector> posList
	vector        finalPos
	vector        airPos
	vector        eyeHitPos
	vector        eyeHitNorm
	entity		  hitEnt
	bool          success
	bool          isOccluded
	float         pathDistance
	int			  failCase
	bool		  hasAlly
	entity		  allyTarget
}

struct ArmoredLeapSnakeInfo
{
	entity		  mover
	vector        shieldDir
	vector        moverDir
	vector		  nextValidPos
	vector		  dropPos
	vector		  destination
	vector		  surfaceAngle
	float		  wallLength
	bool		  stopped
	bool		  drop
	bool		  isLeft
}

struct FindOffsetPosStruct
{
	bool success
	vector position
}

#if DEV
const table<int,string> armoredLeapPhaseToStringMap = {
	[ PLAYER_ARMORED_LEAP_PHASE_NONE ] = "PLAYER_ARMORED_LEAP_PHASE_NONE",
	[ PLAYER_ARMORED_LEAP_PHASE_PREP ] = "PLAYER_ARMORED_LEAP_PHASE_PREP",
	[ PLAYER_ARMORED_LEAP_PHASE_TRAVEL_AIR ] = "PLAYER_ARMORED_LEAP_PHASE_TRAVEL_AIR",
	[ PLAYER_ARMORED_LEAP_PHASE_TRAVEL_AIR_HOVER ] = "PLAYER_ARMORED_LEAP_PHASE_TRAVEL_AIR_HOVER",
	[ PLAYER_ARMORED_LEAP_PHASE_TRAVEL_GROUND ] = "PLAYER_ARMORED_LEAP_PHASE_TRAVEL_GROUND",
	[ PLAYER_ARMORED_LEAP_PHASE_ARRIVAL ] = "PLAYER_ARMORED_LEAP_PHASE_ARRIVAL",
	[ PLAYER_ARMORED_LEAP_PHASE_INTERRUPTED ] = "PLAYER_ARMORED_LEAP_PHASE_INTERRUPTED"
}
#endif

#if CLIENT
struct CastleWallThreatIndicatorLine
{
	vector startPos
	vector endPos
}

struct CastleWallEntityData
{
	entity        anchorLeft
	entity        anchorCenter
	entity        anchorRight
	array<entity> lowWallsLeft
	array<entity> lowWallsRight
}
#endif //CLIENT

enum eFailCase
{
	DEFAULT,
	BLOCKED_LANDING,
	BLOCKED_LEAP,
	BLOCKED_ALLY,

	_count
}

enum eSegmentType
{
	CENTER,
	LOW,
	HIGH,
	LOW_LEFT,
	LOW_RIGHT,

	_count
}

enum eAnchorType
{
	NONE,
	LEFT,
	CENTER,
	RIGHT,
	_count
}

struct ArmoredLeapPhaseChangeData
{
	int oldPhase
	int newPhase
}

struct
{
	//Live Tuning variables//
	int castleWallHealth		= CASTLE_WALL_SHIELD_ANCHOR_HEALTH
	float maxDist				= ARMORED_LEAP_DISTANCE
	float maxDistAlly			= ARMORED_LEAP_MAX_ALLY_RANGE
	float maxHeight				= ARMORED_LEAP_MAX_LEAP_HEIGHT
	float maxHeightAlly			= ARMORED_LEAP_MAX_LEAP_HEIGHT_ALLY
	float airLaunchSpeed		= ARMORED_LEAP_AIR_LAUNCH_SPEED //Used by SCRIPT system ONLY - DELETE on CLEANUP
	float airJumpSpeedMin		= ARMORED_LEAP_JUMP_SPEED_MIN
	float airJumpSpeedMax		= ARMORED_LEAP_JUMP_SPEED_MAX
	float airHoverSpeedMin		= ARMORED_LEAP_HOVER_SPEED_MIN
	float airHoverSpeedMax		= ARMORED_LEAP_HOVER_SPEED_MAX
	float groundDashSpeed		= ARMORED_LEAP_GROUND_DASH_SPEED //Used by SCRIPT system ONLY - DELETE on CLEANUP
	float groundDashSpeedMin	= ARMORED_LEAP_GROUND_DASH_SPEED_MIN
	float groundDashSpeedMax	= ARMORED_LEAP_GROUND_DASH_SPEED_MAX
	float airSlamSpeedNear		= ARMORED_LEAP_SLAM_SPEED_NEAR
	float airSlamSpeedFar		= ARMORED_LEAP_SLAM_SPEED_FAR
	float airSlamSpeedMax		= ARMORED_LEAP_SLAM_SPEED_MAX
	float moveRecoveryTime		= ARMORED_LEAP_RECOVERY_MOVESLOW_DURATION
	float impactRadius			= ARMORED_LEAP_IMPACT_RANGE
	float impactForceMin		= ARMORED_LEAP_MIN_FORCE
	float impactForceMax		= ARMORED_LEAP_MAX_FORCE
	float barrierDuration		= CASTLE_WALL_BARRIER_DURATION
	float barrierDelay			= CASTLE_WALL_BARRIER_DELAY_TIME
	float barrierDMGInterval	= CASTLE_WALL_BARRIER_DAMAGE_INTERVAL
	int barrierDamage			= CASTLE_WALL_BARRIER_DAMAGE
	int impactDamage			= ARMORED_LEAP_DAMAGE

	//File Variables//
	table<entity, ArmoredLeapTargetInfo>        armoredLeapTargetTable
	table<entity, vector> allyLKP = {}
	table<entity, entity> allyTarget = {}

	table<entity, bool> playerWeaponsHolstered = {}
	table<entity, vector> shieldSlamPos = {}
	table<entity, int> threatVisionHandle = {}
	table<entity, bool> threatVisionActive = {}
	table<entity, bool> isTargetPlacementActive = {}
	table<entity, bool> allyIsInDanger = {}
	table<entity, bool> ultDeployed = {}

	bool allowStartOnMovers 		= ARMORED_LEAP_ALLOW_START_ON_MOVERS_DEFAULT
	bool allowEndOnMovers 			= ARMORED_LEAP_ALLOW_END_ON_MOVERS_DEFAULT
	float maxEndingMoverSpeedSqr 	= ARMORED_LEAP_MOVERS_MAX_SPEED_FOR_END_DEFAULT

	bool hasVisorThreatDetection	= VISOR_THREAT_DETECTION

                    
	bool hasWallStopsGrenades		= CASTLE_WALL_STOPS_GRENADES
       

	table< entity, bool > canDoWallRemoveChatter = {}

	#if SERVER
	table<entity, array<entity> > castleEntArray
	table<entity, array<entity> > playerCastles
	table< entity, array< array<entity> > > playerCastleArrays
	table< entity, int > numPlayerCastles = {}

	table< entity, array<entity> > castleSnakeTailsL
	table< entity, array<entity> > castleSnakeTailsR
	table<entity, bool> endWallDeployed

	table<entity, vector> lastSnakePanelPos
	table<entity, int> currentArmoredLeapPhase

	                    
//	table < entity, entity >                  trophyZapTag
       
	#endif

	#if CLIENT
		float cl_timeRemaining = 0.0
		float cl_overshield = 0.0

		array<entity> castleWallClientAGs
		table<int, CastleWallEntityData > castleWallEnts
		table<entity, bool> castleWallHighlightFocus
		array<entity> enemyThreatTargets
		int colorCorrection = -1
		table<entity, entity> bleedoutWP

		var visorRui = null
		int currentArmoredLeapPhase = PLAYER_ARMORED_LEAP_PHASE_NONE
	#endif

	table< entity, array< ArmoredLeapPhaseChangeData > > armoredLeapPhaseChangeQueue

} file

void function MpAbilityArmoredLeap_Init()
{
	PrecacheParticleSystem( ARMORED_LEAP_AR_TARGET_FX )
	PrecacheParticleSystem( ARMORED_LEAP_AR_TARGET_FX_ALTZ )
	PrecacheParticleSystem( ARMORED_LEAP_AR_AIM_FX )
	PrecacheParticleSystem( ARMORED_LEAP_ENERGY_RADIUS_FX )
	PrecacheParticleSystem( ARMORED_LEAP_PREVIEW_RING_FX )
	PrecacheParticleSystem( ARMORED_LEAP_AFTERBURNER_FX )
	PrecacheParticleSystem( ARMORED_LEAP_LAUNCH_JET_BACK_FX )
	PrecacheParticleSystem( ARMORED_LEAP_DOWN_JET_BACK_FX )
	PrecacheParticleSystem( ARMORED_LEAP_LAUNCH_JET_LEG_FX )
	PrecacheParticleSystem( ARMORED_LEAP_ALLY_BEAM_FX )

	PrecacheParticleSystem( ARMORED_LEAP_PLACEMENT_ARC )
	PrecacheParticleSystem( ARMORED_LEAP_PLACEMENT_ARROW_LEAP_FX )
	PrecacheParticleSystem( ARMORED_LEAP_PLACEMENT_ARROW_LEAP_FX_ALTZ )
	PrecacheParticleSystem( ARMORED_LEAP_PLACEMENT_ARROW_DASH_FX )

	PrecacheParticleSystem( CASTLE_WALL_SHIELD_ANCHOR_DESTROYED_FX )
	PrecacheParticleSystem( CASTLE_WALL_SHIELD_ANCHOR_DESTROYED_LARGE_FX )
	PrecacheParticleSystem( CASTLE_WALL_BARRIER_BEAM_FX )
	PrecacheParticleSystem( CASTLE_WALL_EMP_FX_3P )

	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_LG_FX )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_LG_R_FX )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_LG_L_FX )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT_02 )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT_03 )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT_02 )
	PrecacheParticleSystem( CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT_03 )

	PrecacheParticleSystem( ARMORED_LEAP_IMPACT_FX )

	PrecacheImpactEffectTable( ARMORED_LEAP_IMPACT_FX_TABLE )
	PrecacheImpactEffectTable( CASTLE_WALL_SNAKE_IMPACT_FX_TABLE )

                    
	PrecacheParticleSystem( CASTLE_WALL_INTERCEPT_PROJECTILE_SMALL_FX )
	PrecacheParticleSystem( CASTLE_WALL_INTERCEPT_PROJECTILE_SMALL_ENEMY_FX )
	PrecacheParticleSystem( CASTLE_WALL_INTERCEPT_PROJECTILE_CLOSE_FX )
	PrecacheParticleSystem( CASTLE_WALL_INTERCEPT_PROJECTILE_CLOSE_ENEMY_FX )
      

	PrecacheModel( CASTLE_WALL_SHIELD_ANCHOR_COL_FX )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_CENTRE_MDL )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_ENDS_L_MDL )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_ENDS_R_MDL )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_ENDS_LOW_COL_L_MDL )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_ENDS_LOW_COL_R_MDL )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_SEG_L_MDL )
	PrecacheModel( CASTLE_WALL_SHIELD_WALL_SEG_R_MDL )

	PrecacheScriptString( ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
	PrecacheScriptString( CASTLE_WALL_THREAT_TARGETNAME )

	RegisterSignal( "StopArmoredLeapTargetPlacement" )
	RegisterSignal( "ArmoredLeap_LeapComplete" )
	RegisterSignal( "ArmoredLeap_LeapShutdown" )
	RegisterSignal( "ArmoredLeap_AllyRescueComplete" )
	RegisterSignal( "CastleWall_PickedUp" )
	RegisterSignal( "ArmoredLeap_LaunchEffectsEnd" )
	RegisterSignal( "CastleWall_BarrierDisrupted" )
	RegisterSignal( "CastleWall_CastleDestroyed" )
	RegisterSignal( "ArmoredLeap_AirLaunchComplete" )
	RegisterSignal( "ArmoredLeap_GroundDiveComplete" )
	RegisterSignal( "VisorMode_DeActivate" )
	RegisterSignal( "StopConcurrentPlacementThread" )

	//Signals to control the script flow between phases (phase change is handled by code, calls back to script and fires relevant signals.)
	RegisterSignal( "ArmoredLeap_StartPrepPhase" )
	RegisterSignal( "ArmoredLeap_EndPrepPhase" )
	RegisterSignal( "ArmoredLeap_StartTravelAirPhase" )
	RegisterSignal( "ArmoredLeap_EndTravelAirPhase" )
	RegisterSignal( "ArmoredLeap_StartTravelAirHoverPhase" )
	RegisterSignal( "ArmoredLeap_EndTravelAirHoverPhase" )
	RegisterSignal( "ArmoredLeap_StartTravelGroundPhase" )
	RegisterSignal( "ArmoredLeap_EndTravelGroundPhase" )
	RegisterSignal( "ArmoredLeap_StartArrivalPhase" )
	RegisterSignal( "ArmoredLeap_EndArrivalPhase" )
	RegisterSignal( "ArmoredLeap_Interrupted" )
	RegisterSignal( "NewcastlePassiveEnd" )

	AddCallback_PlayerCanUseZipline( ArmoredLeap_CanUseZipline )

	AddCallback_OnPassiveChanged( ePassives.PAS_AXIOM, OnNewcastlePassiveChanged )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_castle_wall, CastleWall_DamagedTarget )
		Bleedout_AddCallback_OnPlayerStartBleedout( ArmoredLeap_OnPlayerStartBleedout )
		Bleedout_AddCallback_OnPlayerStopBleedout( ArmoredLeap_OnPlayerStopBleedout )
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+scriptCommand5", OnCharacterButtonPressed )
		file.colorCorrection = ColorCorrection_Register( "materials/correction/ability_hunt_mode.raw_hdr" ) //This is BH's - Try to determine how to make a new one in the tool again.

		AddCallback_UseEntGainFocus( CastleWall_OnGainFocus )
		AddCallback_UseEntLoseFocus( CastleWall_OnLoseFocus )

		AddCreateCallback( "prop_script", CastleWall_OnPropScriptCreated )
		AddDestroyCallback( "prop_script", CastleWall_OnPropScriptDestroyed )
		AddCallback_ModifyDamageFlyoutForScriptName( ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME, CastleWall_OffsetDamageNumbers )
		AddTargetNameCreateCallback( ARMORED_LEAP_IMPACT_ZONE_THREAT_TARGETNAME, AddImpactZoneThreatIndicator )

	#endif

		Remote_RegisterServerFunction( "ClientCallback_TryPickupCastleWall", "typed_entity", "prop_script" ) //Only for CastleV2 - but temp. outside of condition for global validation
		Remote_RegisterClientFunction( "ServerToClient_ArmoredLeapComplete", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_ArmoredLeapShutdown", "entity" ) //Test to Shutdown the Armored Leap Thread on a Client that shouldn't be running.
		Remote_RegisterClientFunction( "ServerToClient_ArmoredLeapInterrupted", "entity" ) //To ensure all interruptions always make it to the client.  If a client predicted ent gets put to sleep (IE it suddenly has a move parent) we can end up in a situation where it won't update to realize its been interrupted.
		Remote_RegisterClientFunction( "ServerToClient_VisorMode_DeActivate", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_ArmoredLeap_AirLaunchComplete", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_ArmoredLeap_GroundDiveComplete", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_SetClient_AllyInDanger", "entity", "entity", "bool" )
		Remote_RegisterClientFunction( "ServerToClient_RescueTargetRui_Activate", "entity", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_RescueTargetRui_Deactivate", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_SetClient_BleedoutWaypoint", "entity", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_RemoveClient_BleedoutWaypoint", "entity" )

	//Live Tunables//
	file.castleWallHealth			= GetCurrentPlaylistVarInt( "newcastle_armored_leap_castleWallHP", CASTLE_WALL_SHIELD_ANCHOR_HEALTH )
	file.maxDist 					= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_dist", ARMORED_LEAP_DISTANCE )
	file.maxDistAlly 				= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_dist_ally", ARMORED_LEAP_MAX_ALLY_RANGE )
	file.maxHeight 					= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_height", ARMORED_LEAP_MAX_LEAP_HEIGHT )
	file.maxHeightAlly 				= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_height_ally", ARMORED_LEAP_MAX_LEAP_HEIGHT_ALLY )
	file.airLaunchSpeed 			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_launch", ARMORED_LEAP_AIR_LAUNCH_SPEED ) //Old SCRIPT SYSTEM - DELETE ON CLEANUP
	file.airJumpSpeedMin 			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_jump_min", ARMORED_LEAP_JUMP_SPEED_MIN )
	file.airJumpSpeedMax 			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_jump_max", ARMORED_LEAP_JUMP_SPEED_MAX )
	file.airHoverSpeedMin 			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_hover_min", ARMORED_LEAP_HOVER_SPEED_MIN )
	file.airHoverSpeedMax 			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_hover_max", ARMORED_LEAP_HOVER_SPEED_MAX )
	file.groundDashSpeed			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_ground_dash", ARMORED_LEAP_GROUND_DASH_SPEED ) //Old SCRIPT SYSTEM - DELETE ON CLEANUP
	file.groundDashSpeedMin			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_ground_dash_min", ARMORED_LEAP_GROUND_DASH_SPEED_MIN )
	file.groundDashSpeedMax			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_ground_dash_max", ARMORED_LEAP_GROUND_DASH_SPEED_MAX )
	file.airSlamSpeedNear			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_slam_near", ARMORED_LEAP_SLAM_SPEED_NEAR )
	file.airSlamSpeedFar			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_slam_far", ARMORED_LEAP_SLAM_SPEED_FAR )
	file.airSlamSpeedMax			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_speed_air_slam_max", ARMORED_LEAP_SLAM_SPEED_MAX )
	file.moveRecoveryTime			= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_moveslow_recovery_time", ARMORED_LEAP_RECOVERY_MOVESLOW_DURATION )
	file.impactRadius 				= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_impact_radius", ARMORED_LEAP_IMPACT_RANGE )
	file.impactForceMin				= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_impact_force_min", ARMORED_LEAP_MIN_FORCE )
	file.impactForceMax				= GetCurrentPlaylistVarFloat( "newcastle_armored_leap_impact_force_max", ARMORED_LEAP_MAX_FORCE )
	file.barrierDuration			= GetCurrentPlaylistVarFloat( "newcastle_castle_wall_barrier_duration", CASTLE_WALL_BARRIER_DURATION )
	file.barrierDelay 				= GetCurrentPlaylistVarFloat( "newcastle_castle_wall_barrier_delay", CASTLE_WALL_BARRIER_DELAY_TIME )
	file.barrierDMGInterval			= GetCurrentPlaylistVarFloat( "newcastle_castle_wall_barrier_dmg_interval", CASTLE_WALL_BARRIER_DAMAGE_INTERVAL )
	file.barrierDamage				= GetCurrentPlaylistVarInt( "newcastle_castle_wall_barrier_dmg", CASTLE_WALL_BARRIER_DAMAGE )
	file.impactDamage				= GetCurrentPlaylistVarInt( "newcastle_armored_leap_impact_dmg", ARMORED_LEAP_DAMAGE )

	file.maxEndingMoverSpeedSqr 	= pow( GetCurrentPlaylistVarFloat( "axiom_armored_leap_max_mover_speed", ARMORED_LEAP_MOVERS_MAX_SPEED_FOR_END_DEFAULT ), 2.0)
	file.allowStartOnMovers 		= GetCurrentPlaylistVarBool( "axiom_armored_leap_allow_start_on_movers", ARMORED_LEAP_ALLOW_START_ON_MOVERS_DEFAULT )
	file.allowEndOnMovers 			= GetCurrentPlaylistVarBool( "axiom_armored_leap_allow_end_on_movers", ARMORED_LEAP_ALLOW_END_ON_MOVERS_DEFAULT )

	file.hasVisorThreatDetection	= GetCurrentPlaylistVarBool( "newcastle_hasVisorThreat", VISOR_THREAT_DETECTION )

                    
	file.hasWallStopsGrenades		= GetCurrentPlaylistVarBool( "newcastle_hasWallStopsGrenades", CASTLE_WALL_STOPS_GRENADES )
      
}

void function OnNewcastlePassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if ( !IsAlive( player ) )
		return

	if ( didHave )
	{
		player.Signal( "NewcastlePassiveEnd" )
		
		if ( player in file.armoredLeapPhaseChangeQueue )
			delete file.armoredLeapPhaseChangeQueue[player]
	}

	if ( nowHas )
	{
		array< ArmoredLeapPhaseChangeData > data
		file.armoredLeapPhaseChangeQueue[player] <- data
		thread ArmoredLeapPhaseChangeQueueProcessor_Thread( player )
	}
}

void function OnWeaponActivate_ability_armored_leap( entity weapon )
{
	#if SERVER
	entity player = weapon.GetWeaponOwner()
	if ( IsValid ( player ) )
	{
		EmitSoundOnEntityExceptToPlayer( player, player, ARMORED_LEAP_SOUND_ACTIVATE_3P )
	}
	#endif //SERVER
}

void function OnWeaponReadyToFire_ability_armored_leap( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if ( weapon.GetWeaponPrimaryClipCount() < weapon.GetAmmoPerShot() )
		return

	//Weird Guard to prevent AR from appearing when we holster the weapon.
	if( weapon.GetWeaponActivity() == ACT_VM_HOLSTER ) //455 ) //Holster Activity //todo: Travis to investigate a better solution to this.
		return

	if( player in file.isTargetPlacementActive )
		return

	if( player in file.armoredLeapTargetTable )
		delete file.armoredLeapTargetTable[player]

	thread ArmoredLeap_TargetPlacementTracking_Thread( player )

	#if CLIENT
		if ( player == GetLocalViewPlayer() )
		{
			thread ArmoredLeap_AR_Placement_Thread( weapon )
		}
	#endif

}


void function OnWeaponDeactivate_ability_armored_leap( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	Signal( player, "StopArmoredLeapTargetPlacement" )

	#if SERVER
		StopSoundOnEntity( player, ARMORED_LEAP_SOUND_ACTIVATE_3P )
	#endif

	if ( GetCurrentArmoredLeapPhase( player ) == PLAYER_ARMORED_LEAP_PHASE_NONE )
	{
		Signal( player, "VisorMode_DeActivate" )
	}

	#if CLIENT
		if ( player == GetLocalViewPlayer() )
		{
			weapon.Signal( "StopArmoredLeapTargetPlacement" )
			//animation is driving this sound and sometimes if we interrupt the deploy anim before the UI thread has turned on, this sound can persist.
			StopSoundOnEntity( player, ARMORED_LEAP_SOUND_TO_STOP_1P )
		}
	#endif
	if( player in file.allyLKP )
		delete file.allyLKP[player]
}


var function OnWeaponPrimaryAttack_ability_armored_leap( entity weapon, WeaponPrimaryAttackParams params )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) || player.IsPhaseShifted() )
		return 0

	ArmoredLeapTargetInfo info = GetArmoredLeapTargetInfo( player )

	#if SERVER
	if ( !info.success )
	{
		Remote_CallFunction_NonReplay( player, "ServerToClient_ArmoredLeapShutdown", player )
		return 0
	}
	#endif

	#if CLIENT
	if ( !InPrediction() || IsFirstTimePredicted() )
	{
		if ( !info.success )
			return 0
	}
	else
		return 0
	#endif

	if ( DoAdditionalAirPosChecks() )
	{
		info = GetBetterAirPos( player, info )
	}

	if ( IsValid( info.allyTarget) )
	{
		file.allyTarget[player] <- info.allyTarget
	}

	file.armoredLeapTargetTable[player] <- info

	if ( player.IsPhaseShifted() )
	{
		delete file.armoredLeapTargetTable[player]
		return 0
	}

	#if SERVER
		                     
			Vehicle_KickPlayer_ForAbility( player )
        
		weapon.AddMod( "ability_in_effect_regen_paused" )
	#endif

	#if SERVER
		if( info.hasAlly )
		{
			array<entity> allyArray = GetAllyPlayerArray(player)
			foreach ( ally in allyArray )
			{
				if( !IsValid( ally ) )
					continue

				if ( ally == player )
					continue

				if( ally == info.allyTarget )
				{
					EmitSoundOnEntityOnlyToPlayer( player, player, ARMORED_LEAP_ALLY_TARGETED_CHATTER_1P )
					EmitSoundOnEntityOnlyToPlayer( player, info.allyTarget, ARMORED_LEAP_ALLY_TARGETED_CHATTER_3P )
					continue
				}

				EmitSoundOnEntityOnlyToPlayer( player, ally, ARMORED_LEAP_ALLY_BUDDY_TARGETED_CHATTER_3P )
			}

		}
		else
			PlayBattleChatterLineToSpeakerAndTeam( player, "bc_super" )
	#endif

	#if SERVER
	file.currentArmoredLeapPhase[player] <- PLAYER_ARMORED_LEAP_PHASE_NONE
	#elseif CLIENT
	file.currentArmoredLeapPhase = PLAYER_ARMORED_LEAP_PHASE_NONE
	#endif


	thread ArmoredLeap_Master_Thread( player, info.finalPos, info.airPos, info.hitEnt )

	Signal( player, "StopArmoredLeapTargetPlacement" )
	#if CLIENT
		if( file.visorRui != null )
			RuiSetGameTime( file.visorRui, "jumpTime", Time() )
	#endif

	PlayerUsedOffhand( player, weapon, true, null, {pos = info.finalPos, hasAlly = info.hasAlly} )


	return weapon.GetAmmoPerShot()
}


//Once we have a proper anim we should remove the crouch state and fire from here instead of above.
var function OnWeaponPrimaryAttackAnimEvent_ability_armored_leap( entity weapon, WeaponPrimaryAttackParams params )
{
	int ammoReq = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	entity player = weapon.GetWeaponOwner()

	return 0
}


////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////             >> ARMORED LEAP <<          ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
void function ArmoredLeap_Master_Thread( entity player, vector endPoint, vector airPoint, entity hitEnt )
{
}

bool function WasArmoredLeapInterrupted( entity player, table signalData )
{
	bool interrupted = expect bool( signalData.interrupted )

	//Validate against the the cached leap phase, in tight spaces, the leap can go into the traversal phase and interrupted phase in one server fame.  In that case our waitsignal will pickup the traversal signal (interrupted == false) and not the interrupred one since it was waiting on both.


	return interrupted
}

#if SERVER
bool function CreateCastleWall( entity player )
{
	TraceResults downTrace = TraceHull( player.GetOrigin() + <0,0,32>, player.GetOrigin() + < 0.0, 0.0, -(ARMORED_LEAP_GROUNDPOS_CHECK_RANGE+50) >, player.GetPlayerMins(), player.GetPlayerMaxs(), ArmoredLeapIgnoreArray(), TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if ( downTrace.fraction < 1.0 ) //If we've been thrown into the air (ex. rogue jump pad...cancel and refund part of the cancelled ultimate )
	{
		//did we land somewhere we shouldn't spawn the ult?
		if ( ArmoredLeap_IsValidPosition( player, downTrace.endPos, downTrace.hitEnt ) )
		{
			ArmoredLeap_Impact( player )
			CreateUltPOI( player, downTrace )

			file.ultDeployed[player] <- true

			return true
		}
	}

	ArmoredLeap_OnAttemptFailed( player, ZERO_VECTOR ) //refund a failed deploy if we got this far
	return false
}


void function CreateUltPOI( entity player, TraceResults downTrace )
{
	bool foundGround = downTrace.fraction < 1.0
	vector poiPos

	if ( !foundGround )
	{
		//only need to do this trace if we didn't find ground above
		TraceResults groundTraceEnd = TraceLine( player.GetOrigin(), player.GetOrigin() + <0, 0, -5000>, [ player ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		poiPos = groundTraceEnd.endPos
	}
	else
	{
		poiPos = downTrace.endPos
	}

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_NEWCASTLE_ARMORED_LEAP_END, player, poiPos, player.GetTeam(), player )
}
#endif

int function GetCurrentArmoredLeapPhase( entity player )
{
	int leapPhase = PLAYER_ARMORED_LEAP_PHASE_NONE

	#if SERVER
	if ( player in file.currentArmoredLeapPhase )
		leapPhase = file.currentArmoredLeapPhase[player]
	#elseif CLIENT
	leapPhase = file.currentArmoredLeapPhase
	#endif

	return leapPhase
}


void function ArmoredLeap_HandleInterruptedMidLeap( entity player )
{

}

#if SERVER
bool function ArmoredLeap_Handle_Interrupted( entity player, vector endPos )
{
	vector pOrigin = player.GetOrigin()

	TraceResults pDownTrace = TraceHull( pOrigin+<0,0,32>, pOrigin + < 0.0, 0.0, -ARMORED_LEAP_GROUNDPOS_CHECK_RANGE >, player.GetPlayerMins(), player.GetPlayerMaxs(), GetPlayerArray_AliveConnected(), TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	bool isValidEnd = ArmoredLeap_HasValidHullRoom( player, pDownTrace.endPos )
	if ( ( pDownTrace.fraction < 1.0 && !pDownTrace.startSolid ) || isValidEnd )//Interrupted - but close enough to deploy
	{
		CreateCastleWall( player )
		return true
	}
	else //Interrupted, but not close enough to deploy. Bail and Refund.
	{
		thread ArmoredLeap_LeapComplete_Thread( player )
		return false
	}

	return false
}
#endif

void function ArmoredLeap_UpdateLKP_Thread( entity player, vector airPoint, vector endPoint )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	player.EndSignal( "ArmoredLeap_StartTravelGroundPhase" )
	player.EndSignal( "ArmoredLeap_EndTravelAirHoverPhase" )
	player.EndSignal( "ArmoredLeap_Interrupted" )
	player.EndSignal( "ArmoredLeap_LeapComplete" )
	player.EndSignal( "Interrupted" )

	while( true )
	{
		endPoint = ArmoredLeap_GetUpdatedLKP( player, airPoint, endPoint ) //Updates LKP & endPoint
		WaitFrame()
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////       ARMORED LEAP MOVEMENT PHASES      ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

void function ArmoredLeap_LaunchPrep_Thread( entity player, vector endPoint, vector airPoint, float crouchTime )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	#if SERVER
		int crouchHandle
		StatusEffect_AddTimed( player, eStatusEffect.move_slow, crouchTime, 1.5, 0 )
		if ( !GetArmoredLeapUseCode() )
		{
			crouchHandle = player.PushForcedStance( FORCE_STANCE_CROUCH )
		}
	#endif

	#if SERVER
	OnThreadEnd(
		function() : ( player,  crouchHandle )
		{
			if ( IsValid( player ) )
			{
				if ( !GetArmoredLeapUseCode() )
				{
					player.RemoveForcedStance( crouchHandle )
				}
			}
		}
	)
	#endif

	bool launchSFX = false
	vector targetPos = endPoint
	float endCrouchTime = Time() + crouchTime

	while( Time() < endCrouchTime )
	{
		if (!IsValid(player))
			return

		if ( player.IsPhaseShifted() )
			return

		if ( !GetArmoredLeapUseCode() )
		{
			endPoint = ArmoredLeap_GetUpdatedLKP( player, airPoint, targetPos ) //Updates the LKP
		}

		#if SERVER
			if( Time() > (endCrouchTime - 0.2) && !launchSFX ) //This times the SFX with the Launch - Ideally, we want this tied to Animation
			{
				launchSFX = true
				EmitSoundOnEntityOnlyToPlayer( player, player, ARMORED_LEAP_SOUND_LAUNCH_1P )
				EmitSoundOnEntityExceptToPlayer( player, player, ARMORED_LEAP_SOUND_LAUNCH_3P )
			}
		#endif

		WaitFrame()
	}
}

void function ArmoredLeap_LaunchHoverPrep_Thread( entity player, vector endPoint, vector airPoint )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	if( !IsValid( player ) )
		return

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				#if SERVER
				if ( !GetArmoredLeapUseCode() )
				{
					float curGravity = player.GetLocalGravityStrength()
					#if DEV
						if ( curGravity != 1 )
							player.SetLocalGravityStrength( 1 )
					#endif
				}
				#endif
			}
		}
	)

	#if SERVER
	if ( !GetArmoredLeapUseCode() )
	{
		float gravity = player.GetLocalGravityStrength()
		vector currentVel = player.GetVelocity()
		vector newVel = currentVel * ARMORED_LEAP_AIR_HOVER_VEL_SCALAR // addedVel //maybe just set to 0 - but likely want some float

		//Set Gravity & Hover Speed
		#if DEV
		player.SetLocalGravityStrength( ARMORED_LEAP_AIR_HOVER_GRAVITY )
		player.SetVelocity( newVel )
		#endif
	}
	#endif

	//Hold Air Hover for Duration
	float endTime = Time() + ARMORED_LEAP_AIR_HOVER_TIME
	while( Time() < endTime  )
	{
		if( !IsValid( player ) )
			return

		#if SERVER
		if( ArmoredLeap_IsInterrupted(player, endPoint) )
		{
			//printt( "STOPPING THE MOVE BECAUSE WE ARE BLOCKED BY SOMETHING" )

			thread ArmoredLeap_LeapComplete_Thread( player )
			return
		}

		if ( player.IsPhaseShifted() )
		{
			thread ArmoredLeap_LeapComplete_Thread( player )
			return
		}
		#endif

		endPoint = ArmoredLeap_GetUpdatedLKP( player, player.EyePosition(), endPoint ) //Updates the LKP
		WaitFrame()
	}
}


void function ArmoredLeap_LaunchToAirPosition( entity player, entity mover, vector endPoint, vector airPoint )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "ArmoredLeap_AirLaunchComplete" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	if ( !IsValid( player ) )
		return

	OnThreadEnd(
		function() : ( player )
		{

			if ( IsValid( player ) )
			{
				#if CLIENT
					if ( player == GetLocalClientPlayer() )
						Signal( player, "ArmoredLeap_AirLaunchComplete" )
				#endif //CLIENT
				#if SERVER
					//all this remote call did was the above clinet script, why do a callback?
					//Remote_CallFunction_NonReplay( player, "ServerToClient_ArmoredLeap_AirLaunchComplete", player )

					StopSoundOnEntity( player, ARMORED_LEAP_SOUND_AIR_MVMT_1P )
					StopSoundOnEntity( player, ARMORED_LEAP_SOUND_AIR_MVMT_3P )
				#endif
			}
		}
	)

	//Launch Prep - Crouch//
	if ( GetArmoredLeapUseCode() )
	{
		thread ArmoredLeap_LaunchPrep_Thread( player, endPoint, airPoint, ARMORED_LEAP_LAUNCH_CROUCH_TIME )
		player.WaitSignal( "ArmoredLeap_EndPrepPhase" )

		if ( !IsValid( player ) )
			return
	}
	else
	{
		waitthread ArmoredLeap_LaunchPrep_Thread( player, endPoint, airPoint, ARMORED_LEAP_LAUNCH_CROUCH_TIME )

		if ( !IsValid( player ) )
			return

		//Update the end position
		endPoint = ArmoredLeap_GetUpdatedLKP( player, airPoint, endPoint ) //Will return LKP if valid
	}

	float dist = Distance( player.GetOrigin(), airPoint )
	bool isAtHoverDist = false

	#if SERVER
		//Holster Weapons
		file.playerWeaponsHolstered[player] <- true
		HolsterAndDisableWeapons( player )

		//SFX for Air Movement
		EmitSoundOnEntityOnlyToPlayer( player, player, ARMORED_LEAP_SOUND_AIR_MVMT_1P )
		EmitSoundOnEntityExceptToPlayer( player, player, ARMORED_LEAP_SOUND_AIR_MVMT_3P )

		//Launch the Player to the Air Position

		float lerpTime = dist / ARMORED_LEAP_AIR_LAUNCH_SPEED
		lerpTime = clamp( lerpTime, 0.8, 1.0 )
		float easeTime = lerpTime * ARMORED_LEAP_AIR_LAUNCH_EASE_OUT_TIME

		//player.SetTrackEntityOffsetDistanceOverTime( ARMORED_LEAP_INITIAL_CAMERA_DIST, ARMORED_LEAP_AIR_CAMERA_DIST, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
		//player.SetTrackEntityOffsetHeightOverTime( ARMORED_LEAP_INITIAL_CAMERA_HEIGHT, ARMORED_LEAP_AIR_CAMERA_HEIGHT, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
		//player.SetTrackEntityOffsetRightOverTime( ARMORED_LEAP_INITIAL_CAMERA_RIGHT, ARMORED_LEAP_AIR_CAMERA_RIGHT, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )

		#if DEV
			if ( DEBUG_CAMERA_LERP )
			{
				printt( "Setting starting dist to: " + ARMORED_LEAP_INITIAL_CAMERA_DIST + " ending dist: " + ARMORED_LEAP_AIR_CAMERA_DIST + " over: " + lerpTime )
				printt( "Setting starting height to: " + ARMORED_LEAP_INITIAL_CAMERA_HEIGHT + " ending height: " + ARMORED_LEAP_AIR_CAMERA_HEIGHT + " over: " + lerpTime )
				printt( "Setting starting right to: " + ARMORED_LEAP_INITIAL_CAMERA_RIGHT + " ending right: " + ARMORED_LEAP_AIR_CAMERA_RIGHT + " over: " + lerpTime )
			}
		#endif //DEV

		if ( !GetArmoredLeapUseCode() )
			mover.NonPhysicsMoveTo( airPoint, lerpTime, 0, easeTime )
	#endif

	//Hold thread & Update LKP until we reach the Air Position
	if ( GetArmoredLeapUseCode() )
	{
		player.WaitSignal( "ArmoredLeap_EndTravelAirHoverPhase" )
	}
	else
	{
		//Hold thread & Update LKP until we reach the Air Position
		while( dist > ARMORED_LEAP_AIRPOS_CHECK_RANGE )
		{
			if( !IsValid(player) )
				return

			#if SERVER
				if( ArmoredLeap_IsInterrupted(player, airPoint) )
				{
					thread ArmoredLeap_LeapComplete_Thread( player )
					return
				}
			#endif

			dist = Distance( player.GetOrigin(), airPoint )

			if( dist < ARMORED_LEAP_AIRPOS_CHECK_RANGE * 2 && !isAtHoverDist )
			{
				isAtHoverDist = true
			}

			endPoint = ArmoredLeap_GetUpdatedLKP( player, airPoint, endPoint ) //Updates LKP & endPoint
			WaitFrame()
		}
	}
}


void function ArmoredLeap_SlamToGroundPosition( entity player, entity mover, vector endPoint, vector airPoint, bool isDashing )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "ArmoredLeap_GroundDiveComplete" )
	EndSignal( player, "ArmoredLeap_LeapComplete" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	player.EndSignal( "ArmoredLeap_StartArrivalPhase" )
	player.EndSignal( "ArmoredLeap_Interrupted" )
	player.EndSignal( "Interrupted" )


	endPoint = endPoint + ARMORED_LEAP_ENDPOINT_BUFFER //Buffer height to prevent landing too far in undulating ground.
	float dist = Distance( player.GetOrigin(), endPoint )

	#if SERVER
		float dist2D = Distance2D( player.EyePosition(), endPoint )
		float dist3D = Distance( player.EyePosition(), endPoint )

		float slamSpeed = GraphCapped( dist3D, ARMORED_LEAP_CLOSE_AIR_HEIGHT, ARMORED_LEAP_FAR_AIR_HEIGHT, ARMORED_LEAP_SLAM_SPEED_NEAR, ARMORED_LEAP_SLAM_SPEED_FAR )
		if( isDashing )
			slamSpeed = ARMORED_LEAP_GROUND_DASH_SPEED

		float lerpTime = dist / slamSpeed //
		float easeTime = lerpTime * ARMORED_LEAP_SLAM_EASE_IN_TIME

		if(isDashing)
		{
			//player.SetTrackEntityOffsetDistanceOverTime( ARMORED_LEAP_INITIAL_CAMERA_DIST, ARMORED_LEAP_END_CAMERA_DIST, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
			//player.SetTrackEntityOffsetHeightOverTime( ARMORED_LEAP_INITIAL_CAMERA_HEIGHT, ARMORED_LEAP_END_CAMERA_HEIGHT, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
			//player.SetTrackEntityOffsetRightOverTime( ARMORED_LEAP_INITIAL_CAMERA_RIGHT, ARMORED_LEAP_END_CAMERA_RIGHT, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
			#if DEV
				if ( DEBUG_CAMERA_LERP )
				{
					printt( "Setting starting height to: " + ARMORED_LEAP_INITIAL_CAMERA_HEIGHT + " ending height: " + ARMORED_LEAP_END_CAMERA_HEIGHT + " over: " + lerpTime )
					printt( "Setting starting right to: " + ARMORED_LEAP_INITIAL_CAMERA_RIGHT + " ending right: " + ARMORED_LEAP_END_CAMERA_RIGHT + " over: " + lerpTime )
				}
			#endif //DEV
		}
		else
		{
			//player.SetTrackEntityOffsetDistanceOverTime( ARMORED_LEAP_AIR_CAMERA_DIST, ARMORED_LEAP_END_CAMERA_DIST, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
			//player.SetTrackEntityOffsetHeightOverTime( ARMORED_LEAP_AIR_CAMERA_HEIGHT, ARMORED_LEAP_END_CAMERA_HEIGHT, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
			//player.SetTrackEntityOffsetRightOverTime( ARMORED_LEAP_AIR_CAMERA_RIGHT, ARMORED_LEAP_END_CAMERA_RIGHT, lerpTime, THIRD_PERSON_CAMERA_LERP_MODE_EXPONENTIAL )
			#if DEV
				if ( DEBUG_CAMERA_LERP )
				{
					printt( "Setting starting height to: " + ARMORED_LEAP_AIR_CAMERA_HEIGHT + " ending height: " + ARMORED_LEAP_END_CAMERA_HEIGHT + " over: " + lerpTime )
					printt( "Setting starting right to: " + ARMORED_LEAP_AIR_CAMERA_RIGHT + " ending right: " + ARMORED_LEAP_END_CAMERA_RIGHT + " over: " + lerpTime )
				}
			#endif //DEV
		}

		//player.SetTrackEntityOffsetDistanceOverTimeLogLerpGrowthFactor( 1 )
		//player.SetTrackEntityOffsetHeightOverTimeLogLerpGrowthFactor( 1 )
		//player.SetTrackEntityOffsetRightOverTimeLogLerpGrowthFactor( 1 )



		vector dir =  endPoint - player.GetOrigin()
		vector anglesToUse = VectorToAngles( dir )

		if ( !GetArmoredLeapUseCode() )
			mover.NonPhysicsMoveTo( endPoint, lerpTime, easeTime, 0 )

		//Temp VFX/SFX for Movement Trail
		array<entity> fxArray
		int attatchID = player.LookupAttachment( "CHESTFOCUS" )
		int fxId = GetParticleSystemIndex( ARMORED_LEAP_AFTERBURNER_FX )

		entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, attatchID, <0,0,0>, <0,180,0> ) // AnglesCompose( player.GetAttachmentAngles( attatchID ), <0,0,180> ) )
		fx.SetOwner( player )
		fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE

		fxArray.append(fx)

		//VFX for Launch Movement
		int fxIDBack = GetParticleSystemIndex( ARMORED_LEAP_DOWN_JET_BACK_FX )
		int ventLeftAttachID 	= player.LookupAttachment( "vent_left_back" )
		int ventRightAttachID 	= player.LookupAttachment( "vent_right_back" )

		entity fxBackL = StartParticleEffectOnEntity_ReturnEntity( player, fxIDBack, FX_PATTACH_POINT_FOLLOW, ventLeftAttachID )
		entity fxBackR = StartParticleEffectOnEntity_ReturnEntity( player, fxIDBack, FX_PATTACH_POINT_FOLLOW, ventRightAttachID )
		fxArray.append(fxBackL)
		fxArray.append(fxBackR)

		//SFX for Movement
		EmitSoundOnEntityOnlyToPlayer( player, player, ARMORED_LEAP_SOUND_DIVESLAM_1P )
		EmitSoundOnEntityExceptToPlayer( player, player, ARMORED_LEAP_SOUND_DIVESLAM_3P )
		EmitSoundOnEntityOnlyToPlayer( player, player, ARMORED_LEAP_SOUND_AIR_MVMT_1P )
		EmitSoundOnEntityExceptToPlayer( player, player, ARMORED_LEAP_SOUND_AIR_MVMT_3P )

		OnThreadEnd(
			function() : ( player, fxArray )
			{
				if ( IsValid( player ) )
				{
					Remote_CallFunction_NonReplay( player, "ServerToClient_ArmoredLeap_GroundDiveComplete", player )
					Signal(player,"ArmoredLeap_GroundDiveComplete")

					StopSoundOnEntity( player, ARMORED_LEAP_SOUND_AIR_MVMT_1P )
					StopSoundOnEntity( player, ARMORED_LEAP_SOUND_AIR_MVMT_3P )

				}
				foreach (fx in fxArray)
				{
					if( IsValid(fx) )
					{
						EffectStop( fx )
						fx.Destroy()
					}
				}
			}
		)
	#endif

	if ( GetArmoredLeapUseCode() )
	{
		//thread will end on player signalling "ArmoredLeap_StartArrivalPhase" or "ArmoredLeap_Interrupted"
		WaitForever()
	}
	else
	{
		dist = Distance( player.GetOrigin(), endPoint )
		vector endPos = endPoint
		while( dist > ARMORED_LEAP_GROUNDPOS_CHECK_RANGE )
		{
			if( !IsValid( player ) )
				return

			vector pOrigin = player.GetOrigin()
			#if SERVER
				if( ArmoredLeap_IsInterrupted(player, endPos) )
				{
					TraceResults pDownTrace = TraceLine( pOrigin+<0,0,32>, pOrigin + < 0.0, 0.0, -ARMORED_LEAP_GROUNDPOS_CHECK_RANGE >,  GetPlayerArray_AliveConnected(), TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
					if ( pDownTrace.fraction < 1.0 && !pDownTrace.startSolid ) //Interrupted - but close enough to deploy
					{
						break
					}
					else //Interrupted, but not close enough to deploy. Bail and Refund.
					{
						thread ArmoredLeap_LeapComplete_Thread( player )
						return
					}
				}
			#endif

			//If the ground moves away from newcastle's endPoint - we look down farther to see if he should keep going with the slam

			vector lastPos = endPos
			float zHeight = max( player.GetOrigin().z, endPos.z )
			vector upTestPos = <endPos.x, endPos.y, zHeight>

			//Use the Player's Z (if higher) as a test in case the platform below begins moving UP while Newcastle is mid-air
			//We now trace UP to playerZ to prevent setting the endPos on a platform above the desired end location (when tracking LKP under a rooftop)
			TraceResults testTrace = TraceLine( endPos, upTestPos, GetPlayerArray_AliveConnected(), TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			TraceResults endTrace = TraceLine( testTrace.endPos , endPoint + < 0.0, 0.0, -500 >,  GetPlayerArray_AliveConnected(), TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			if ( endTrace.fraction < 1.0 && endPos != endTrace.endPos && !endTrace.startSolid )
			{
				endPos = endTrace.endPos + ARMORED_LEAP_ENDPOINT_BUFFER
			}

			dist = Distance( player.GetOrigin(), endPos )
			#if SERVER
				if( endPos != lastPos && Distance(endPos, lastPos) > 16 )
				{
					if( dist > ARMORED_LEAP_GROUNDPOS_CHECK_RANGE )
					{
						lastPos = endPos
						//pDist = dist // WOAH! We just lost ground and have to go farther. Update the pDist to make sure it knows we're not going AWAY from the new target location.
						slamSpeed = GraphCapped( dist, ARMORED_LEAP_CLOSE_AIR_HEIGHT, ARMORED_LEAP_FAR_AIR_HEIGHT, ARMORED_LEAP_SLAM_SPEED_NEAR, ARMORED_LEAP_SLAM_SPEED_FAR )
						if( isDashing )
							slamSpeed = ARMORED_LEAP_GROUND_DASH_SPEED

						lerpTime = dist / slamSpeed

						dir =  endPos - player.GetOrigin()
						anglesToUse = VectorToAngles( dir )

						mover.NonPhysicsMoveTo( endPos, lerpTime, 0, 0 )
						lastPos = endPos
					}
					else
						mover.NonPhysicsStop()
				}
			#endif

			WaitFrame()
		}
	}
}

void function ArmoredLeap_ReturnControlToPlayerAfterDelay( entity player, float delay )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
			{
				#if SERVER
					player.MovementEnable()
				#endif
				if ( GetArmoredLeapUseCode() )
				{

				}
				else
				{
	
				}
			}
		}
	)
	#if SERVER
		TraceResults endResults = TraceHull( player.GetOrigin(), player.GetOrigin() + <0, 0, 1>, player.GetPlayerMins(), player.GetPlayerMaxs(), GetPlayerArray_Alive(), TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if ( endResults.startSolid )
		{
			PutPlayerInSafeSpot( player, null, null, player.GetOrigin(), player.GetOrigin() )
		}
		player.SetVelocity( <0,0,0> )
		player.MovementDisable()
		StatusEffect_AddTimed( player, eStatusEffect.move_slow, 0.2, file.moveRecoveryTime, 0.5 )
	#endif//SERVER

	wait delay

}

void function ArmoredLeap_CameraRecoveryDelay( entity player, float delay )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
			{
				#if SERVER
				//// --- end 3rd person ---
				//player.SetTrackEntityOffsetRight( 0 )
				//player.ClearTrackEntitySettings()
				#endif
			}
		}
	)
	wait delay

}


void function CodeCallback_ArmoredLeapPhaseChange( entity player, int newArmoredLeapPhase, int oldArmoredLeapPhase )
{
	if ( !IsValid( player ) )
		return

	#if DEV
	if ( DEBUG_PHASE_CHANGES )
		printt( FUNC_NAME() + " got code callback for player: " + player.GetPlayerName() + " phase is: " + armoredLeapPhaseToStringMap[newArmoredLeapPhase] + " old phase is: " + armoredLeapPhaseToStringMap[oldArmoredLeapPhase] )
	#endif

	ArmoredLeapPhaseChangeData data
	data.oldPhase = oldArmoredLeapPhase
	data.newPhase = newArmoredLeapPhase
	if ( player in file.armoredLeapPhaseChangeQueue )
		file.armoredLeapPhaseChangeQueue[player].insert( 0, data )
}

//R5DEV-384280 - CodeCallback_ArmoredLeapPhaseChange drives the phase changes in script.  Previously we just issued the signals from that code callback directly.
//The problem is though that signals don't get processed until the end of the script frame, but codecallbacks are immediate.
//So in the case of Newcastle flying through the air (Octane jump pad) and then pressing deploy on the leap when he was super close to the ground we would have both the
//PLAYER_ARMORED_LEAP_PHASE_TRAVEL_GROUND phase change and PLAYER_ARMORED_LEAP_PHASE_ARRIVAL phase change happen between server frames.  Then when the next server frame runs
//ArmoredLeap_SlamToGroundPosition script function would end without having a chance to process the PLAYER_ARMORED_LEAP_PHASE_TRAVEL_GROUND phase because PLAYER_ARMORED_LEAP_PHASE_ARRIVAL would have signaled
//"ArmoredLeap_StartArrivalPhase" which is an endsignal on ArmoredLeap_SlamToGroundPosition.  To work around this, I've built this processor thread that will queue up phase changes as they come in from the CodeCallback and only process one phase change per frame.
//This allows the rest of the script can react to each phase as it happens once phase change per frame.
void function ArmoredLeapPhaseChangeQueueProcessor_Thread( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "NewcastlePassiveEnd" )

	while ( true )
	{
		if ( player in file.armoredLeapPhaseChangeQueue )
		{
			if ( file.armoredLeapPhaseChangeQueue[player].len() > 0 )
			{
				ArmoredLeapPhaseChangeData phaseChangeToProcess = file.armoredLeapPhaseChangeQueue[player].pop()

				int oldArmoredLeapPhase = phaseChangeToProcess.oldPhase
				int newArmoredLeapPhase = phaseChangeToProcess.newPhase

				#if DEV
				if ( DEBUG_PHASE_CHANGES )
					printt( FUNC_NAME() + " OldPhase: " + oldArmoredLeapPhase + " NewPhase: " + newArmoredLeapPhase )
				#endif

				#if SERVER
					file.currentArmoredLeapPhase[player] <- newArmoredLeapPhase
				#elseif CLIENT
					file.currentArmoredLeapPhase = newArmoredLeapPhase
				#endif
			}
		}

		WaitFrame()
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////       ARMORED LEAP COMPLETION FLOW     ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#if SERVER
void function ArmoredLeap_LeapComplete_Thread( entity player )
{
	if( !IsValid(player) )
		return

	Signal( player, "ArmoredLeap_LeapComplete" )
	Remote_CallFunction_NonReplay( player, "ServerToClient_ArmoredLeapComplete", player )

	wait ARMORED_LEAP_VISOR_POST_LANDING_DURATION

	if( !IsValid(player) )
		return

	if( player in file.threatVisionActive )
		delete file.threatVisionActive[player]

	Signal( player, "VisorMode_DeActivate" )
	Remote_CallFunction_NonReplay( player, "ServerToClient_VisorMode_DeActivate", player )
}
#endif

#if CLIENT
void function ServerToClient_ArmoredLeapComplete( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return
	Signal( player, "ArmoredLeap_LeapComplete" )
}

void function ServerToClient_ArmoredLeapShutdown( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return
	Signal( player, "ArmoredLeap_LeapShutdown" )

	if( player in file.armoredLeapTargetTable ) //We remove the table on the client so the AR does not remain locked in an invalid position on the client (since the server check failed)
		delete file.armoredLeapTargetTable[player]
}

void function ServerToClient_ArmoredLeapInterrupted( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	player.Signal( "ArmoredLeap_Interrupted", { interrupted = true } )
}
#endif


#if CLIENT
void function ServerToClient_ArmoredLeap_AirLaunchComplete( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return
	Signal( player, "ArmoredLeap_AirLaunchComplete" )
}
#endif

#if CLIENT
void function ServerToClient_ArmoredLeap_GroundDiveComplete( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return
	Signal( player, "ArmoredLeap_GroundDiveComplete" )
}
#endif


void function ArmoredLeap_OnAttemptFailed( entity player, vector startpoint )
{
	if( !IsValid( player ) )
		return

	entity weapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	#if SERVER
		if ( EntityInSolid( player ) )
		{
			PutPlayerInSafeSpot( player, null, null, player.GetOrigin(), player.GetOrigin() )
		}

		if ( !GetArmoredLeapUseCode() )
		{
			//On a Failed Attempt, we want to curb insane speeds from sending Newcastle flying off the map
			vector curVelocity = player.GetVelocity()
			const float velScale 			= 0.35
			const float maxUnchangedSpeed 	= 100
			float speed = player.GetVelocity().Length()
			if( speed > maxUnchangedSpeed )
				player.SetVelocity( curVelocity - ( curVelocity * velScale ) )
		}

	#endif

	if( !IsValid( weapon ) )
		return

	int currentAmmo = weapon.GetWeaponPrimaryClipCount()
	int ammo = minint( currentAmmo + ARMORED_LEAP_REFUND_AMOUNT_FRAC, weapon.GetWeaponPrimaryClipCountMax() )
	weapon.SetWeaponPrimaryClipCount( ammo )

}

bool function ArmoredLeap_IsInterrupted( entity player, vector destination )
{
	if( !IsValid(player) )
		return false

	if(	player.IsPhaseShifted() )
		return true

	vector mins   		= ARMORED_LEAP_COL_MINS
	vector maxs   		= ARMORED_LEAP_COL_MAXS
	vector pPos	  		= player.GetOrigin() + <0,0,35>
	vector fwd 	  		= Normalize( player.GetForwardVector() )

	//DebugDrawArrow( pPos, destination, 8, COLOR_YELLOW, true, 15.0 )

	array<entity> ignoreArray = ArmoredLeapIgnoreArray()
	TraceResults results = TraceHull( pPos, destination , mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if ( results.startSolid )
	{
		return true
	}

	float distToEnd = Distance(pPos, results.endPos)

	if( distToEnd <= 200 )
	{
		bool isValidEnd = ArmoredLeap_HasValidHullRoom( player, destination )
		entity pusher = GetPusherEnt( results.hitEnt )

		if( !isValidEnd )
			return true
	}


	return false
}

void function ArmoredLeap_CheckForUpdraft_Thread( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "ArmoredLeap_LeapComplete")
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	while(true)
	{
		if( !IsValid( player ) )
			return


		WaitFrame()
	}
}


#if DEV
#if SERVER
void function Debug_TrackPlayerInLeap_Thread( entity player, entity mover, vector endPoint, vector airPoint )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "ArmoredLeap_LeapComplete")

	while (IsValid(player) )
	{
		//DebugDrawAngles( mover.GetOrigin(), mover.GetAngles() , 15 )
		//DebugDrawAngles( player.GetOrigin(), VectorToAngles( player.GetViewVector() ) , 15 )
		//DebugDrawAngles( player.GetOrigin(), VectorToAngles( player.CameraAngles() ) , 15 )
		//DebugDrawAngles( player.GetOrigin(), VectorToAngles( player.EyeAngles() ) , 15 )
		wait 1.5
		//WaitFrame()
	}

}
#endif
#endif

//////////////////////////////
///////LAUNCH FX//////////////
#if SERVER
void function ArmoredLeap_LaunchVFX_Thread( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "ArmoredLeap_LaunchEffectsEnd")
	EndSignal( player, "ArmoredLeap_StartTravelGroundPhase" )
	EndSignal( player, "ArmoredLeap_Interrupted" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	if ( !IsValid( player ) )
		return

	//VFX for Launch Movement
	int fxIDBack = GetParticleSystemIndex( ARMORED_LEAP_LAUNCH_JET_BACK_FX )
	int fxIDLeg = GetParticleSystemIndex( ARMORED_LEAP_LAUNCH_JET_LEG_FX )

	int ventLeftAttachID 	= player.LookupAttachment( "vent_left_back" )
	int ventRightAttachID 	= player.LookupAttachment( "vent_right_back" )
	int legLeftAttachID 	= player.LookupAttachment( "fx_knee_jet_l" )
	int legRightAttachID 	= player.LookupAttachment( "fx_knee_jet_r" )

	array<entity> fxArray
	entity fxLegL = StartParticleEffectOnEntity_ReturnEntity( player, fxIDLeg, FX_PATTACH_POINT_FOLLOW, legLeftAttachID )
	entity fxLegR = StartParticleEffectOnEntity_ReturnEntity( player, fxIDLeg, FX_PATTACH_POINT_FOLLOW, legRightAttachID )
	fxArray.append(fxLegL)
	fxArray.append(fxLegR)

	entity fxBackL = StartParticleEffectOnEntity_ReturnEntity( player, fxIDBack, FX_PATTACH_POINT_FOLLOW, ventLeftAttachID )
	entity fxBackR = StartParticleEffectOnEntity_ReturnEntity( player, fxIDBack, FX_PATTACH_POINT_FOLLOW, ventRightAttachID )
	fxArray.append(fxBackL)
	fxArray.append(fxBackR)

	OnThreadEnd(
		function() : ( player, fxArray )
		{
			if ( IsValid( player ) )
			{
			}

			foreach( fx in fxArray )
			{
				if( IsValid(fx) )
				{
					EffectStop(fx)
					fx.Destroy()
				}
			}
		}
	)

	WaitForever()
}

#endif

#if SERVER
void function ArmoredLeap_CreateWarningArea( entity player, vector targetPos, float duration )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "NewcastlePassiveEnd" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "Interrupted" )

	int fxid = GetParticleSystemIndex( ARMORED_LEAP_ENERGY_RADIUS_FX )
	vector origin = player.GetOrigin()
	int team = player.GetTeam()

	array<entity> fxArray

	entity fxAlly = StartParticleEffectInWorld_ReturnEntity( fxid, targetPos, <0,0,0> )
	SetTeam( fxAlly, team )
	fxAlly.SetOwner(player)
	fxAlly.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	EffectSetControlPointVector( fxAlly, 5, <0.15, 0, 0> )
	EffectSetControlPointVector( fxAlly, 1, FRIENDLY_COLOR_FX ) // <255,255,0> ) //
	fxAlly.RemoveFromAllRealms()
	fxAlly.AddToOtherEntitysRealms( player )
	FiringRange_AddToRemoveOnCharacterChange( fxAlly, player )

	entity fxEnemy = StartParticleEffectInWorld_ReturnEntity( fxid, targetPos, <0,0,0> )
	SetTeam( fxEnemy, team )
	fxEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	EffectSetControlPointVector( fxEnemy, 5, <0.15, 0, 0> )
	EffectSetControlPointVector( fxEnemy, 1, ENEMY_COLOR_FX )
	fxEnemy.RemoveFromAllRealms()
	fxEnemy.AddToOtherEntitysRealms( player )
	FiringRange_AddToRemoveOnCharacterChange( fxEnemy, player )

	fxArray.append(fxAlly)
	fxArray.append(fxEnemy)

	//Create Ally Tracking Marker
	bool hasAlly = ( player in file.allyTarget )
	int allyMarkerFxID = -1
	entity allyMarker = null

	if ( hasAlly )
	{
		allyMarkerFxID                = GetParticleSystemIndex( ARMORED_LEAP_AR_TARGET_FX_ALTZ )
		allyMarker                    = StartParticleEffectInWorld_ReturnEntity( allyMarkerFxID, origin, <0, 0, 0> )
		allyMarker.SetOwner( player )
		allyMarker.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
		EffectSetControlPointVector( allyMarker, 1, TEAM_COLOR_FRIENDLY )
	}

	// Create Threat Zone
	entity impactZone = CreatePropScript( $"mdl/dev/empty_model.rmdl", targetPos )
	SetTargetName( impactZone, ARMORED_LEAP_IMPACT_ZONE_THREAT_TARGETNAME )
	impactZone.SetOwner( player )
	SetTeam( impactZone, team )
	impactZone.RemoveFromAllRealms()
	impactZone.AddToOtherEntitysRealms( player )
	FiringRange_AddToRemoveOnCharacterChange( impactZone, player )

	OnThreadEnd(
		function() : ( player, fxArray, allyMarker, impactZone )
		{
			if ( IsValid( player ) )
			{
			}
			foreach (fx in fxArray )
			{
				if( !IsValid(fx) )
					continue

				fx.ClearParent()
				EffectStop( fx )
				fx.Destroy()
			}
			if( IsValid(allyMarker) )
			{
				allyMarker.ClearParent()
				thread ArmoredLeap_CleanUpAllyMarker( allyMarker )
			}
			if( IsValid(impactZone) )
			{
				impactZone.Destroy()
			}
		}
	)

	float endTime = Time() + duration
	bool fxAttached = false
	bool shouldBeParented = false

	//We need to wait the warning duration.
	//However, if we have an ally we are targeting, we need to track them.
	while ( Time() < endTime )
	{
		//Setting the fx Position every frame is simpler - but it snaps the effect around and isn't good overall.
		//Desire here is to PARENT the fx to the Ally Target (when one is available) until the allyTarget is no longer valid to land on (death/positioning)
		//The LKP keeps track of whether the target is close to valid ground - so we don't allow/clear parenting if the target's origin is too far away from the LKP
		if( hasAlly && ( player in file.allyTarget ) )
		{
			if ( IsValid( allyMarker ) )
			{
				allyMarker.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
			}

			if( player in file.allyLKP )
				targetPos = file.allyLKP[player]

			entity target = file.allyTarget[player]
			if( IsValid( target ) )
			{
				float dist = Distance( targetPos, target.GetOrigin() ) //Check to make sure the Target is near the LKP so we allow parenting of the VFX
				if( dist < 100  ) //Target == LKP - We are clear to PARENT
				{
					shouldBeParented = true

					if( fxAttached == false ) //Using this bool so that we don't setOrigin/setParent every frame, just on first attachments.
					{
						foreach( fx in fxArray)
						{
							if( !IsValid(fx) )
								continue

							fx.SetOrigin( target.GetOrigin() )
							fx.SetParent( target )
						}

						if( IsValid( allyMarker ) )
						{
							allyMarker.SetOrigin( target.GetOrigin() )
							allyMarker.SetParent( target )
						}

						fxAttached = true
					}
				}
				else //Target != LKP - We should not be PARENTED
					shouldBeParented = false

			}
			else
				shouldBeParented = false

			if( !shouldBeParented )
			{
				if( fxAttached == true )
				{
					if( player in file.allyLKP )
						targetPos = file.allyLKP[player]

					foreach( fx in fxArray)
					{
						if(!IsValid(fx))
							continue

						fx.ClearParent()
						fx.SetAbsOrigin( targetPos )
					}

					if( IsValid( allyMarker ) )
					{
						allyMarker.ClearParent()
						allyMarker.SetAbsOrigin( targetPos )
					}

					fxAttached = false
				}
			}

		}

		WaitFrame()
	}
}

void function ArmoredLeap_CleanUpAllyMarker( entity allyMarker )
{
	//Keeps the Ally Marker around until the landing is complete
	OnThreadEnd(
		function() : ( allyMarker )
		{
			if( IsValid(allyMarker) )
			{
				EffectStop( allyMarker )
				allyMarker.Destroy()
			}
		}
	)
	wait 0.5
}
#endif

#if SERVER
void function ArmoredLeap_OnPlayerStartBleedout( entity victim, entity attacker, var damageInfo )
{
	array<entity> allyNewcastles
	foreach ( player in GetAllyPlayerArray(victim) )
	{
		if( !IsValid( player ) )
			continue

		if( !(PlayerHasPassive( player, ePassives.PAS_AXIOM )) )
			continue

		allyNewcastles.append(player)
	}

	entity wp = Bleedout_GetBleedoutWaypoint( victim )

	if( IsValid( wp ) )
	{
		foreach ( newcastle in allyNewcastles )
		{
			//Store Bleedout Waypoint
			Remote_CallFunction_NonReplay( newcastle, "ServerToClient_SetClient_BleedoutWaypoint", victim, wp )
		}
	}

	if ( IsValid( victim ) && PlayerHasPassive( victim, ePassives.PAS_AXIOM ) )
	{
		ArmoredLeap_HandleInterruptedMidLeap( victim )
	}
}
void function ArmoredLeap_OnPlayerStopBleedout( entity victim )
{
	array<entity> allyNewcastles
	foreach ( player in GetAllyPlayerArray(victim) )
	{
		if( !IsValid( player ) )
			continue

		if( !(PlayerHasPassive( player, ePassives.PAS_AXIOM )) )
			continue

		allyNewcastles.append(player)
	}
	//Remove Bleedout Waypoint
	foreach ( newcastle in allyNewcastles )
	{
		Remote_CallFunction_NonReplay( newcastle, "ServerToClient_RemoveClient_BleedoutWaypoint", victim )
	}
}
#endif

#if CLIENT
void function ServerToClient_SetClient_BleedoutWaypoint( entity victim, entity wp )
{
	if( IsValid( wp ) )
		file.bleedoutWP[victim] <- wp
}
void function ServerToClient_RemoveClient_BleedoutWaypoint( entity victim )
{
	if( victim in file.bleedoutWP )
		delete file.bleedoutWP[ victim ]
}
#endif

#if CLIENT
void function ServerToClient_RescueTargetRui_Activate( entity allyTarget, entity player )
{
	if ( allyTarget != GetLocalClientPlayer() )
		return

	thread ArmoredLeap_CreateAllyRescueHud( allyTarget, player )
}

void function ServerToClient_RescueTargetRui_Deactivate( entity allyTarget )
{
	if ( allyTarget != GetLocalClientPlayer() )
		return

	Signal( allyTarget, "ArmoredLeap_AllyRescueComplete" )
}

void function ArmoredLeap_CreateAllyRescueHud( entity allyTarget, entity player )
{
	if ( allyTarget != GetLocalClientPlayer() )
		return

	if( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )

	allyTarget.EndSignal( "OnDeath" )
	allyTarget.EndSignal( "OnDestroy" )
	EndSignal( allyTarget, "ArmoredLeap_AllyRescueComplete" )

	//ALLY RUI
	var rui = CreateCockpitRui( $"ui/newcastle_rescue_icon.rpak", HUD_Z_BASE )

	RuiSetBool( rui, "isVisible", true )
	RuiSetBool( rui, "showClampArrow", true )

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroyIfAlive( rui )
		}
	)

	while ( true )
	{
		if ( !IsValid( player ) )
			return
		if ( !IsValid( allyTarget ) )
			return

		//Add condition to turn off when looking at the player.
		int attachment = player.LookupAttachment( "CHESTFOCUS" )
		RuiTrackFloat3( rui, "pos", player, RUI_TRACK_POINT_FOLLOW, attachment )

		WaitFrame()
	}

}
#endif //CLIENT



void function ArmoredLeap_TargetPlacementTracking_Thread( entity ent )
{
	EndSignal( ent, "OnDeath" )
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "BleedOut_OnStartDying" )
	EndSignal( ent, "DeathTotem_PreRecallPlayer" )
	EndSignal( ent, "StopArmoredLeapTargetPlacement" ) //Used the "player" version rather than the weapon version
	EndSignal( ent, "ArmoredLeap_LeapComplete" )
	EndSignal( ent, "ArmoredLeap_Interrupted" )

	//Target Placement State Set - Used to prevent use of other elements while Targeting (eg. Ziplines)
	file.isTargetPlacementActive[ent] <- true

	bool inDanger = false
	entity lastAttacker
	bool attackerNearby

	array<entity> allyArray = GetAllyPlayerArray(ent)
	foreach ( ally in allyArray )
	{
		if ( ally == ent )
			continue

		if( !IsValid( ally ) )
			continue

		file.allyIsInDanger[ally] <- false
	}

	OnThreadEnd(
		function() : ( ent, allyArray )
		{
			if ( IsValid( ent ) )
			{
				if( ent in file.isTargetPlacementActive )
					delete file.isTargetPlacementActive[ent]

			}

			foreach ( ally in allyArray )
			{
				if( !IsValid( ally ) )
					continue

				if( ally in file.allyIsInDanger )
					delete file.allyIsInDanger[ally]
			}
		}
	)


	while( IsValid(ent) )
	{
		// Set Last Known Position (LKP) //
		ArmoredLeapTargetInfo info //info is passed in here - but as a formality. We're just using this to determine whether to set LKP on the server
		ArmoredLeap_SetAllyTargetAndLKP( ent, info )

		//This is now doing the heavy lifting on the Ally Tracking for Server and Client.
		//However. I am repeating this logic client-side in the original function just to fill the struct for the AR Targeting. :(
		//The Server then makes a final pass using the original logic, and takes the stored data for the LKP here into account in it's pass.
		//I don't want to run EVERYTHING on the server - but it definitely feels weird to be running the same logic chunk portion on the client that I'm technically already doing.



		//Ally In Danger// - Used by the Visor to show ALERT indicator when targeting
		allyArray = GetAllyPlayerArray( ent )

		foreach ( ally in allyArray )
		{
			if ( ally == ent )
				continue

			if( !IsValid( ally ) )
				continue

			if ( ally.e.recentDamageHistory.len() > 0 )
			{
				lastAttacker = ally.e.recentDamageHistory[ 0 ].attacker //can we extend this to a larger list?
			}

			if( IsValid( lastAttacker ) )
			{
				float distToAttacker = 	Distance2D( ally.GetOrigin(), lastAttacker.GetOrigin() )
				if( distToAttacker < ARMORED_LEAP_ALLY_DANGER_DISTANCE_MAX )
					attackerNearby = true
				else
					attackerNearby = false
			}

			#if SERVER
				if( Time() < ally.GetLastTimeDamaged() + ARMORED_LEAP_ALLY_DANGER_ALERT_TIME || attackerNearby) //this will have to be per ally
				{
					inDanger = true
				}
				else
				{
					attackerNearby = false
					inDanger = false
				}

				if( ally in file.allyIsInDanger )
				{
					if(file.allyIsInDanger[ally] != inDanger)
					{
						file.allyIsInDanger[ally] <- inDanger
						Remote_CallFunction_NonReplay( ent, "ServerToClient_SetClient_AllyInDanger", ent, ally, inDanger )
					}
				}

			#endif
		}


		WaitFrame()
	}

}

void function ArmoredLeap_SetAllyTargetAndLKP( entity ent, ArmoredLeapTargetInfo info )
{
	entity targetAlly = GetAllyTargetInRange( ent )
	array<entity> ignoreArray = ArmoredLeapIgnoreArray()

	bool foundValidEnd = false

	if( IsValid( targetAlly ) )
	{
		file.allyTarget[ent] <- targetAlly
		vector allyEndPos = targetAlly.GetOrigin() + < 0,0,5 > //slightly off the ground.
		bool inPhaseShift = targetAlly.IsPhaseShifted()

		TraceResults groundTrace = TraceLine( allyEndPos, allyEndPos + <0,0,-1000>, ignoreArray, TRACE_MASK_ABILITY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if( groundTrace.fraction < 1 || inPhaseShift ) //We have ground beneath our target player
		{
			entity hitEnt = groundTrace.hitEnt
			//ArmoredLeapTargetInfo info //info is passed in here - but as a formality. We're just using this to determine whether to set LKP on the server
			allyEndPos = ArmoredLeap_GetBestAllyLandingPos( ent, groundTrace.endPos, Normalize(ent.GetViewVector()), info )  //groundTrace.endPos + < 0,0,5 >
			//DebugDrawSphere( allyEndPos, 10.0, COLOR_YELLOW, true, 0.1 )

			foundValidEnd  = ArmoredLeap_HasValidLeapPos( ent, targetAlly, allyEndPos, hitEnt, info )
			//DebugDrawSphere( info.finalPos, 20.0, <150, 0, 150>, true, 0.1 )

			if( foundValidEnd )
			{
				info.hasAlly = true
				info.allyTarget = targetAlly

				file.allyLKP[ent] <- allyEndPos
			}
			else
			{
				if ( ent in file.allyLKP )
				{
					if ( IsValid( file.allyLKP[ent] ) )
					{
						allyEndPos = file.allyLKP[ent]
						foundValidEnd = ArmoredLeap_HasValidLeapPos( ent, targetAlly, allyEndPos, hitEnt, info )
						if ( foundValidEnd )
						{
							info.hasAlly = false
							info.allyTarget = targetAlly
						}
						else
						{
							if ( ent in file.allyLKP )
								delete file.allyLKP[ent]
						}
					}
				}
			}
		}
		else
		{
			if( ent in file.allyTarget )
				delete file.allyTarget[ent]

			if( ent in file.allyLKP )
				delete file.allyLKP[ent]
		}
	}
	else
	{
		if( ent in file.allyTarget )
			delete file.allyTarget[ent]

		if( ent in file.allyLKP )
			delete file.allyLKP[ent]
	}
}

vector function ArmoredLeap_GetUpdatedLKP( entity player, vector airPoint, vector targetPos )
{
	if( player in file.allyTarget )
	{
		if( IsValid( file.allyTarget[player] ) )
		{
			array<entity> ignoreArray = ArmoredLeapIgnoreArray()
			vector adjustedEndPos = file.allyTarget[player].GetOrigin() + < 0,0,5 > //slightly off the ground.
			bool inPhaseShift = file.allyTarget[player].IsPhaseShifted()

			TraceResults groundTrace = TraceLine( adjustedEndPos, adjustedEndPos + <0,0,-1000>, ignoreArray, TRACE_MASK_ABILITY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //ARMORED_LEAP_HUMAN_HEIGHT_OFFSET
			if( groundTrace.fraction < 1 && !inPhaseShift ) //We have ground beneath our target player
			{
				adjustedEndPos = groundTrace.endPos + < 0,0,5 >
				float dist2D = Distance2D( airPoint, adjustedEndPos )
				if( dist2D <= ARMORED_LEAP_MAX_SLAM_FOLLOW_DISTANCE )
				{
					//DebugDrawLine( <airPoint.x, airPoint.y, targetPos.z >, targetPos, 0, 255, 0, true, 0.5 )
					adjustedEndPos = groundTrace.endPos + < 0,0,5 >
					TraceResults slamTrace = TraceHull( airPoint, adjustedEndPos, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

					if ( slamTrace.fraction == 1.0 )
					{
						file.allyLKP[player] <- slamTrace.endPos
					}
				}
			}

		}
		else
			delete file.allyTarget[player]
	}

	if( player in file.allyLKP )
	{
		targetPos = file.allyLKP[player]

	}

	//DebugDrawLine( player.GetOrigin(), targetPos, COLOR_GREEN, true, 20 )
	//DebugDrawSphere( targetPos, 50.0, <0, 150, 150>, true, 0.1 )
	return targetPos
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////            ARMORED LEAP AR & THREAT VISION         ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#if CLIENT
void function ArmoredLeap_AR_Placement_Thread( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if( !IsValid( player ) )
		return

	Signal(player, "StopConcurrentPlacementThread")
	player.EndSignal("StopConcurrentPlacementThread")

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )

	EndSignal( player, "VisorMode_DeActivate" )
	EndSignal( player, "ArmoredLeap_LeapComplete" )
	EndSignal( player, "ArmoredLeap_Interrupted" )

	int team = player.GetTeam()

	thread ArmoredLeap_VisionMode_Thread( player )

	//ALLY RUI - Lock On and Ally Reticules //
	array<var> ruis

	table< entity, var > allyRui
	array<entity> allyArray = GetAllyPlayerArray( player )


	//AR Mover Entities//
	array<entity> arEnts

	entity endPointMover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", <0, 0, 0>, <0, 0, 0> )			// Holds the TARGETING AR CIRCLE VFX - Always shows landing position
	entity allyMover	 = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", <0, 0, 0>, <0, 0, 0> )			// Holds the BEAM VFX - Tracks Allies and LKP
	entity shieldMover = CreateClientsideScriptMover( CASTLE_WALL_SHIELD_ANCHOR_COL_FX, <0, 0, 0>, <0, 180, 0> ) 	// Holds the SHIELD AR VFX
	shieldMover.EnableRenderAlways()
	shieldMover.kv.rendermode = 3
	shieldMover.kv.renderamt = 1
	DeployableModelHighlightNewcastle( shieldMover )

	arEnts.append(endPointMover)
	arEnts.append(allyMover)
	arEnts.append(shieldMover)

	// "Leap/Dash" Arrows //
	entity arrowLeap = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", ZERO_VECTOR, ZERO_VECTOR )
	entity arrowDash = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", ZERO_VECTOR, ZERO_VECTOR )
	arrowLeap.SetOrigin( endPointMover.GetOrigin() ) //We can adjust offsets here if need be.
	arrowDash.SetOrigin( endPointMover.GetOrigin() )

	arrowLeap.SetParent( endPointMover, "", true, 0.0 )
	arrowDash.SetParent( endPointMover, "", true, 0.0 )

	arEnts.append(arrowLeap)
	arEnts.append(arrowDash)

	///////////////////////

	OnThreadEnd(
		function() : ( ruis, arEnts )
		{
			foreach( ar in arEnts )
			{
				if( IsValid(ar) )
					ar.Destroy()
			}

			foreach ( rui in ruis )
			{
				RuiDestroyIfAlive( rui )
			}

			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_DEFAULT )
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_LAND )
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_LEAP )
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_ALLY )
		}
	)


	//////////////////// AR VFX //////////////////////
	int fxID           = GetParticleSystemIndex( ARMORED_LEAP_AR_TARGET_FX_ALTZ )
	int screenFxHandle = StartParticleEffectOnEntity( endPointMover, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID ) //EYETEST
	EffectSetControlPointVector( screenFxHandle, 1, NC_COLOR_FRIENDLY )
	EffectSetControlPointVector( screenFxHandle, 3, NC_COLOR_BEHIND )

	int allyBeamFxID =  GetParticleSystemIndex( ARMORED_LEAP_ALLY_BEAM_FX )
	int allyBeamHandle = StartParticleEffectOnEntityWithPos( allyMover, allyBeamFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, endPointMover.GetOrigin() +<0,0,250>, <0,0,1> )
	EffectSetControlPointVector( allyBeamHandle, 1, TEAM_COLOR_FRIENDLY )

	int arcFxID =  GetParticleSystemIndex( ARMORED_LEAP_PLACEMENT_ARC )
	int arcFxHandle = StartParticleEffectOnEntity( shieldMover, arcFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	//EffectSetControlPointVector( arcFxHandle, 1, <ARMORED_LEAP_IMPACT_RANGE, 0, 0> )
	EffectSetControlPointVector( arcFxHandle, 2, NC_COLOR_FRIENDLY )


	////////////////// AR ARROW FX /////////////////////
	int leapFxID           = GetParticleSystemIndex( ARMORED_LEAP_PLACEMENT_ARROW_LEAP_FX_ALTZ )
	int leapFxHandle = StartParticleEffectOnEntity( arrowLeap, leapFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID ) //EYETEST
	EffectSetControlPointVector( leapFxHandle, 1, NC_COLOR_FRIENDLY )
	EffectSetControlPointVector( leapFxHandle, 3, NC_COLOR_BEHIND )

	int dashFxID           = GetParticleSystemIndex( ARMORED_LEAP_PLACEMENT_ARROW_DASH_FX )
	int dashFxHandle = StartParticleEffectOnEntity( arrowDash, dashFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID ) //EYETEST
	EffectSetControlPointVector( leapFxHandle, 1, NC_COLOR_FRIENDLY )
	EffectSetControlPointVector( leapFxHandle, 3, NC_COLOR_BEHIND )


	//Additional Variables
	bool inDashRange 	= false
	bool isLeaping 		= false
	string failReason 	= ""
	entity prevTarget

	//////////////////////////////////////////////////////////////////////////////


	////////// AR TARGETING MODE /////////////
	ArmoredLeapTargetInfo info

	while ( !isLeaping )
	{
		if ( !IsValid( player ) )
			return

		if ( player in file.armoredLeapTargetTable )
			info = file.armoredLeapTargetTable[ player ]
		else
			info = GetArmoredLeapTargetInfo( player )

		#if DEV
		if ( DoAdditionalAirPosChecks() )
		{
			if ( DEBUG_BETTER_AIR_POS )
			{
				//Enable debug draws on the client while targetting if we have this debug flag set.
				GetBetterAirPos( player, info )
			}
		}
		#endif //DEV

		int leapPhase = GetCurrentArmoredLeapPhase( player )

		if ( leapPhase != PLAYER_ARMORED_LEAP_PHASE_NONE && leapPhase != PLAYER_ARMORED_LEAP_PHASE_PREP )
		{
			isLeaping = true
			break
		}

		#if DEV
			if( DEBUG_ARMORED_LEAP_TARGETING_DRAW )
			{
				DebugDrawLine( player.GetOrigin(), info.airPos , <0, 200, 200>, true, 0.1 )
				DebugDrawLine( info.airPos, info.finalPos , <200, 200, 0>, true, 0.1 )
			}
		#endif

		switch( info.failCase )
		{
			case eFailCase.DEFAULT:
				failReason = ARMORED_LEAP_TARGET_FAIL_DEFAULT
				break

			case eFailCase.BLOCKED_LANDING:
				failReason = ARMORED_LEAP_TARGET_FAIL_BLOCKED_LAND
				break

			case eFailCase.BLOCKED_LEAP:
				failReason = ARMORED_LEAP_TARGET_FAIL_BLOCKED_LEAP
				break

			case eFailCase.BLOCKED_ALLY:
				failReason = ARMORED_LEAP_TARGET_FAIL_BLOCKED_ALLY
				break
		}

		///////////////////////////////////////////////
		//Update Position & Orientation of each Mover//
		vector adjPos = info.finalPos + <0,0,CASTLE_WALL_HIGH_WALL_PLANTED_Z_OFFSET>
		vector fwdPos = adjPos + FlattenVec(AnglesToForward(player.CameraAngles())) * CASTLE_WALL_SPAWN_OFFSET

		TraceResults fwdTrace = TraceLine( adjPos, fwdPos, GetPlayerArray_Alive(), TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if ( fwdTrace.fraction < 1.0 )
			adjPos = fwdTrace.endPos
		else
			adjPos = (info.finalPos + <0,0,CASTLE_WALL_HIGH_WALL_PLANTED_Z_OFFSET> ) + FlattenVec(AnglesToForward(player.CameraAngles())) * CASTLE_WALL_SPAWN_OFFSET

		endPointMover.SetOrigin( info.finalPos )    // Setting this regardless of success, otherwise VFX can get desynced from the target position
		endPointMover.SetAngles( VectorToAngles( FlattenVec( Normalize( info.finalPos - player.EyePosition() ) ) ) )
		allyMover.SetOrigin( info.finalPos + <0,0,100> )
		shieldMover.SetOrigin( adjPos )
		shieldMover.SetAngles( AnglesCompose( VectorToAngles( FlattenVec(info.finalPos - player.EyePosition()) ), <0,0,0> ) )

		float testDistance = Distance(player.GetOrigin(), info.finalPos)
		float testHeight = ( info.finalPos.z - player.GetOrigin().z )
		float testDistanceM = Distance(player.GetOrigin(), info.finalPos) * INCHES_TO_METERS
		float testHeightM = ( info.finalPos.z - player.GetOrigin().z ) * INCHES_TO_METERS
		//printt( "DIST: " + testDistance + " | " + testDistanceM + " || HEIGHT:  " + testHeight + " | " + testHeightM  )

		endPointMover.Hide()
		allyMover.Hide()
		shieldMover.Hide()
		arrowLeap.Hide()
		arrowDash.Hide()
		//////////////////////////////////////////////////

		entity allyTarget = info.allyTarget

		// Valid Armored Leap Location//
		if ( info.success )
		{
			endPointMover.Show()
			shieldMover.Show()
			arrowLeap.Show()
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_DEFAULT )
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_LAND )
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_LEAP )
			HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_ALLY )

			if( info.failCase == eFailCase.BLOCKED_ALLY )
				AddPlayerHint( 60.0, 0, $"", failReason )

			if ( !info.isOccluded )//we dont need to test occluded, but we DO need to swap back from red/fail
			{
				EffectSetControlPointVector( screenFxHandle, 1, NC_COLOR_FRIENDLY ) //in front particles
				EffectSetControlPointVector( screenFxHandle, 3, NC_COLOR_BEHIND ) //behind particles
				//EffectSetControlPointVector( arcFxHandle, 2, NC_COLOR_FRIENDLY )
			}
			else
			{
				EffectSetControlPointVector( screenFxHandle, 1, NC_COLOR_FRIENDLY ) //in front particles
				EffectSetControlPointVector( screenFxHandle, 3, NC_COLOR_BEHIND ) //behind particles
				//EffectSetControlPointVector( arcFxHandle, 2, TEAM_COLOR_ENEMY )
			}


			inDashRange = ArmoredLeap_IsInDashRange( player, info.finalPos, info.hitEnt )

			// ALLY LOCK-ON //
			if( info.hasAlly )
			{
				if( allyTarget != prevTarget )
				{
					EmitSoundOnEntity( player, ARMORED_LEAP_ALLY_TARGETED_SFX_1P )
					prevTarget = allyTarget
				}
				allyMover.Show()
			}
			else //No Valid Ally
			{
				bool isVisible 		= false
				bool allyIsValid	= IsValid( allyTarget )
				if( allyIsValid ) //If we lost the target but still have a valid LKP, the RUI is maintained ( currently goes red to show separation )
				{
					array<entity> ignoreArray = ArmoredLeapIgnoreArray()
					TraceResults losTrace = TraceLine( player.EyePosition(), allyTarget.EyePosition(), ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
					isVisible = losTrace.fraction == 1
				}

				if( allyIsValid && !ArmoredLeap_HasValidLandingRoom( player, allyTarget.GetOrigin(), info ) && ( player in file.allyLKP ) && isVisible ) //info
				{
					//We fall into this on ledges when the ALLY's "landing area" is technically invalid - but his LKP holds
					allyMover.Show()
				}

				if( IsValid( prevTarget ) )
					prevTarget = null
			}

			// DASH ARROW //
			if ( !info.isOccluded && inDashRange )
			{
				shieldMover.Show()
				arrowLeap.Hide()
				arrowDash.Show()
			}

		}
		else //no Success
		{
			//hadAlly = false
			inDashRange = false
			endPointMover.Show()
			endPointMover.SetOrigin( info.eyeHitPos )
			EffectSetControlPointVector( screenFxHandle, 1, <255, 0, 0> )
			EffectSetControlPointVector( screenFxHandle, 3, <255, 0, 0> )
			AddPlayerHint( 60.0, 0, $"", failReason )
		}

		//  ALLY RETICULE //  -Show all allies with a reticule on the screen during this mode.
		foreach( ally in allyArray )
		{
			if( ally == player )
				continue

			if( IsValid( ally )  )
			{
				//We only want to show Targeting RUI for Allies of your Squad
				//OR Alliance members who you're targeted. -- Otherwise we have too many active rui elements and it gets messy.
				int allyTeam = ally.GetTeam()
				if( team != allyTeam && ally != allyTarget )
				{
					if( ally in allyRui )
					{
						var oldRui = allyRui[ally]

						if( ruis.contains(oldRui) )
							ruis.fastremovebyvalue( oldRui ) //If Alliance Member WAS a previous target, remove their rui marker when not a target anymore

						if( oldRui != null )
							RuiDestroyIfAlive( oldRui )

						allyRui[ally] = null
					}
					continue
				}

				if( !( ally in allyRui ) )
				{
					if( team == allyTeam || ally == allyTarget )
					{
						allyRui[ally] <- CreateCockpitRui( $"ui/ally_hint_target.rpak", HUD_Z_BASE )
						ruis.append( allyRui[ally] )
					}
				}

				entity wp
				if ( ally in file.bleedoutWP )
				{
					wp = file.bleedoutWP[ally]
				}

				if( ally in allyRui )
				{
					if( allyRui[ally] == null )
						continue
				}

				ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( ally ), Loadout_Character() )

				RuiSetBool( allyRui[ally], "isVisible", true ) //
				RuiSetBool( allyRui[ally], "isTarget", ally == allyTarget && info.hasAlly )
				RuiSetBool( allyRui[ally], "isVisible", IsAlive( ally ) )
				RuiSetImage( allyRui[ally], "legendIcon", CharacterClass_GetGalleryPortrait( character ) )
				RuiSetFloat( allyRui[ally], "bleedoutEndTime", ally.GetPlayerNetTime( "bleedoutEndTime" ) )

				if( IsValid( wp ) )
					RuiTrackFloat3( allyRui[ally], "pos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
				else
				{
					int attachment = ally.LookupAttachment( "CHESTFOCUS" )
					RuiTrackFloat3( allyRui[ally], "pos", ally, RUI_TRACK_POINT_FOLLOW, attachment )
				}

				if( ally in file.allyIsInDanger )
				{
					if( file.allyIsInDanger[ally] )
						RuiSetBool( allyRui[ally], "isInDanger", true )
					else
						RuiSetBool( allyRui[ally], "isInDanger", false )
				}

				vector allyOrigin 		= ally.GetOrigin()
				float allyDistance 		= Distance( allyOrigin, player.GetOrigin() )
				bool isAllyOutOfRange 	= !( ArmoredLeap_HasValidLeapPos( player, ally, allyOrigin, null,  info ) && ( allyDistance < GetArmoredLeapAllyDistance( player ) ) ) //ARMORED_LEAP_MAX_ALLY_RANGE ) )

				RuiSetBool( allyRui[ally], "outOfRange", isAllyOutOfRange )
				//printt( "AllyDist: " + allyDistance + " OUT OF RANGE? " + isAllyOutOfRange )

			}
			else //Ally has Disconnected or is currently the Lock-On Target
			{
				//Destroy rui?
				if( ally in allyRui )
				{
					RuiDestroyIfAlive( allyRui[ally] )

					if( ruis.contains( allyRui[ally] ) )
					{
						ruis.fastremovebyvalue( allyRui[ally] )
					}
					delete allyRui[ally]
				}
			}
		}
		allyArray = GetAllyPlayerArray( player ) // Update the Ally Array in case of disconnects

		WaitFrame()
	}

	////////// AR TARGETING MODE - COMPLETE //////////
	foreach ( hudRui in ruis )
	{
		RuiDestroyIfAlive( hudRui )
	}

	HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_DEFAULT)
	HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_LAND )
	HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_LEAP )
	HidePlayerHint( ARMORED_LEAP_TARGET_FAIL_BLOCKED_ALLY )

	arrowLeap.Hide()
	arrowDash.Hide()
	allyMover.Hide()
	shieldMover.Show()
	endPointMover.Show()

	if ( player in file.armoredLeapTargetTable )
		info = file.armoredLeapTargetTable[ player ]
	else
		info = GetArmoredLeapTargetInfo( player )

	//Ensures that AR Circle always shows confirmed state on client if leap becomes successful
	EffectSetControlPointVector( screenFxHandle, 1, NC_COLOR_FRIENDLY ) //in front particles
	EffectSetControlPointVector( screenFxHandle, 3, NC_COLOR_BEHIND ) //behind particles

	vector endPoint = info.finalPos


	////// AR SHIELD ARC - MID-AIR STATE //////
	while ( isLeaping ) //AR Shield and Arc are maintained on target while in the Air
	{
		if ( !IsValid( player ) )
			return

		int leapPhase = GetCurrentArmoredLeapPhase( player )

		if( player in file.allyLKP )
			endPoint = file.allyLKP[player]

		vector flatCamDir = FlattenVec( AnglesToForward(player.CameraAngles() ) )
		vector shieldPosAR = (endPoint+ <0,0,28> ) + flatCamDir * CASTLE_WALL_SPAWN_OFFSET

		shieldMover.SetOrigin( shieldPosAR )
		shieldMover.SetAngles( AnglesCompose( VectorToAngles(flatCamDir), <0,0,0> ) )
		endPointMover.SetOrigin( endPoint )
		endPointMover.SetAngles( shieldMover.GetAngles() )

		WaitFrame()
	}
}
#endif //CLIENT


#if CLIENT
void function UpdateAllyTargetRUI( var rui, entity allyTarget, entity allyMover )
{
	entity player = GetLocalClientPlayer()

	if( !IsValid( player ) )
		return

	if( !( IsValid( allyTarget ) ) )
		return

	if( !( IsValid( allyMover ) ) )
		return

	if( rui != null )
		return

	if( !allyTarget.IsPlayer() )
	{
		RuiTrackFloat3( rui, "pos", allyTarget, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat3( rui, "chestPos", allyTarget, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat3( rui, "targetPos", allyMover, RUI_TRACK_ABSORIGIN_FOLLOW )
		return
	}

	int armorTier = EquipmentSlot_GetEquipmentTier( allyTarget, "armor" )
	RuiSetInt( rui, "armorTier", armorTier )

	float shieldFrac = GetShieldHealthFrac( allyTarget )
	float healthFrac = GetHealthFrac( allyTarget )
	RuiSetFloat( rui, "shieldFrac", shieldFrac )
	RuiSetFloat( rui, "healthFrac", healthFrac )

	RuiTrackFloat( rui, "shieldFrac", allyTarget, RUI_TRACK_SHIELD_FRACTION )
	RuiTrackFloat( rui, "healthFrac", allyTarget, RUI_TRACK_HEALTH )
	RuiTrackFloat3( rui, "pos", allyTarget, RUI_TRACK_OVERHEAD_FOLLOW )

	int attachment = allyTarget.LookupAttachment( "CHESTFOCUS" )
	RuiTrackFloat3( rui, "chestPos", allyTarget, RUI_TRACK_POINT_FOLLOW, attachment )

	RuiTrackFloat3( rui, "targetPos", allyMover, RUI_TRACK_ABSORIGIN_FOLLOW )

	if( allyTarget in file.allyIsInDanger )
	{
		if( file.allyIsInDanger[allyTarget] )
			RuiSetBool( rui, "isInDanger", true )
		else
			RuiSetBool( rui, "isInDanger", false )
	}

}
#endif

#if CLIENT
void function ArmoredLeap_VisionMode_Thread( entity player )
{
	if( player != GetLocalClientPlayer() )
		return

	//I've made some changes to hopefully fix the double UI issue, still will keep this to see if its still occuring.
	if ( file.visorRui != null )
	{
		Warning( FUNC_NAME() + " multiple inits on visor rui?")
		return
	}

	EndSignal( player, "VisorMode_DeActivate" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "DeathTotem_PreRecallPlayer" )
	EndSignal( player, "ArmoredLeap_LeapComplete" )
	EndSignal( player, "StopArmoredLeapTargetPlacement" )


	//GfxDesaturate( true )
	Chroma_StartHuntMode()
	ColorCorrection_SetExclusive( file.colorCorrection, true )

	file.visorRui = CreateCockpitRui( $"ui/armored_leap_visor.rpak" )
	RuiSetBool( file.visorRui, "isVisible", true )


	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
			{
				ColorCorrection_SetWeight( file.colorCorrection, 0.0 ) //May want to END this with a fade-out//
				ColorCorrection_SetExclusive( file.colorCorrection, false )
				//GfxDesaturate( false )
				Chroma_EndHuntMode()

			}

			if( file.visorRui != null )
			{
				if( file.visorRui != null )
					RuiSetGameTime( file.visorRui, "endTime", Time() )

				RuiDestroyIfAlive ( file.visorRui )
				file.visorRui = null
			}
		}
	)

	const LERP_IN_TIME = 0.0125
	float startTime = Time()

	while ( true )
	{
		float weight = 5.0
		weight = GraphCapped( Time() - startTime, 0, LERP_IN_TIME, 0, weight )

		ColorCorrection_SetWeight( file.colorCorrection, weight )

		if( file.visorRui != null )
			RuiSetFloat3( file.visorRui, "cameraAngle", player.CameraAngles() )

		WaitFrame()
	}

	WaitForever()
}
#endif


bool function ArmoredLeap_TargetEntityShouldBeHighlighted( entity ent )
{
	#if CLIENT
		if( !IsValid(ent) )
			return false

		if ( (file.enemyThreatTargets.contains(ent) ) )
				return true

	#endif
	return false
}

#if CLIENT
void function ArmoredLeap_TrackEnemyAtLandingZone_Thread( entity player, vector endPoint )
{
	Assert ( IsNewThread(), "Must be threaded off." )

	if( player != GetLocalClientPlayer() )
		return

	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "VisorMode_DeActivate" )
	EndSignal( player, "ArmoredLeap_LeapShutdown" )

	int team = player.GetTeam()
	array<int> arcFXArray

	array<entity> enemyThreatTargets = ArmoredLeap_GetEnemyThreatsArray( player, endPoint )

	//We've built the EnemyInRange Array - Time to assign Tracking FX
	foreach( enemy in enemyThreatTargets ) //file.enemyThreatTargets ) //enemiesInRangeArray )
	{
		if( !(IsValid(enemy)) )
			continue

		file.enemyThreatTargets.append(enemy)

		float dist = Distance2D( enemy.GetOrigin(), endPoint )
		if( dist < ARMORED_LEAP_MAX_TARGETING_POSITION_RANGE )
		{
			ManageHighlightEntity( enemy )
		}

	}

	OnThreadEnd(
		function() : ( player, enemyThreatTargets, arcFXArray )
		{
			foreach( arcFX in arcFXArray)
			{
				if( EffectDoesExist( arcFX ) )
				{
					EffectStop( arcFX, false, true )
				}
			}

			foreach( enemy in enemyThreatTargets )
			{
				if ( IsValid( enemy ) )
				{
					foreach ( threatEnemy in file.enemyThreatTargets )
					{
						if( threatEnemy != enemy )
							continue

						file.enemyThreatTargets.removebyvalue(threatEnemy)
						ManageHighlightEntity( threatEnemy )
					}
				}
			}

		}
	)

	while ( true )
	{
		if( !IsValid( player ) )
			return

		//Update Highlights for Enemy Target
		foreach( enemy in enemyThreatTargets )
		{
			//CleanUp Invalid Enemy Targets
			if ( !IsValid( enemy ) )
			{
				enemyThreatTargets.removebyvalue( enemy )

				if( file.enemyThreatTargets.contains( enemy ) )
					file.enemyThreatTargets.fastremovebyvalue( enemy )
				continue
			}

			if( !( file.enemyThreatTargets.contains( enemy ) ) )
				file.enemyThreatTargets.append( enemy )

			//Update Highlight on the Enemy
			ManageHighlightEntity( enemy )

		}


		//Look for New Targets
		array<entity> newTargets = ArmoredLeap_GetEnemyThreatsArray( player, endPoint )

		foreach( target in newTargets )
		{
			if( !(enemyThreatTargets.contains(target)) )
				enemyThreatTargets.append(target)
		}

		WaitFrame()
	}

	WaitForever()
}
#endif  //CLIENT

#if CLIENT
array<entity> function ArmoredLeap_GetEnemyThreatsArray( entity player, vector endPoint )
{
	array<entity> enemyThreatsArray

	if( !IsValid(player) )
		return enemyThreatsArray

	const bool DO_THREAT_VISIBILITY_TRACE		= true
	const float THREAT_TRACE_OFFSET_Z 			= 80.0

	int team = player.GetTeam()
	array<entity> ignoreArray = ArmoredLeapIgnoreArray( null, true )

	array<entity> enemyPlayersArray = GetPlayerArrayOfEnemies_Alive( team )

	array<entity> holoEnts = GetPlayerDecoyArray()
	foreach ( ent in holoEnts )
	{
		if( !IsValid(ent) )
			continue
		if( team == ent.GetTeam() )
			continue
		enemyPlayersArray.append(ent)
	}

	foreach ( enemy in enemyPlayersArray)
	{
		if( !IsValid( enemy ) )
			continue

		if( enemy == player ) //Firing Range / Friendly-Fire ON
			continue

		bool phaseShifted = enemy.IsPlayer() ? enemy.IsPhaseShiftedOrPending() : false
		if ( phaseShifted )
			continue

		float dist = Distance2D( enemy.GetOrigin(), endPoint )
		if( dist > ARMORED_LEAP_MAX_TARGETING_DIRECTION_RANGE )
			continue

		//Visibility Test
		//From PLAYER && SHIELD
		if( DO_THREAT_VISIBILITY_TRACE )
		{
			TraceResults playerTrace = TraceLine( enemy.GetOrigin() + < 0.0, 0.0, THREAT_TRACE_OFFSET_Z >, player.EyePosition(), ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			TraceResults shieldTrace = TraceLine( enemy.GetOrigin() + < 0.0, 0.0, THREAT_TRACE_OFFSET_Z >, endPoint + < 0.0, 0.0, THREAT_TRACE_OFFSET_Z >, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

			if( playerTrace.fraction < 1 && shieldTrace.fraction < 1 )
				continue
		}

		//Add to Viable Target Array if closest
		if( enemyThreatsArray.len() >= ARMORED_LEAP_TARGETING_MAX_TARGETS )
		{
			entity farthestTarget = enemy
			float farthestDist = dist
			foreach( target in enemyThreatsArray )
			{
				float targetDist = Distance2D( target.GetOrigin(), endPoint )
				if( farthestDist < targetDist )
				{
					farthestTarget = target
					farthestDist = targetDist
				}
			}

			if( farthestTarget != enemy )
			{
				enemyThreatsArray.fastremovebyvalue(farthestTarget)
				enemyThreatsArray.append(enemy)
			}
		}
		else
			enemyThreatsArray.append(enemy)
	}

	return enemyThreatsArray
}
#endif //CLIENT

#if CLIENT
void function ServerToClient_VisorMode_DeActivate( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return
	Signal( player, "VisorMode_DeActivate" )
}
#endif

#if CLIENT
void function ServerToClient_SetClient_AllyInDanger( entity player, entity ally, bool inDanger )
{
	if( player != GetLocalClientPlayer() )
		return

	file.allyIsInDanger[ally] <- inDanger
}
#endif //CLIENT








////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////            ARMORED LEAP IMPACT          ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#if SERVER
void function ArmoredLeap_Impact( entity player )
{
	int team = player.GetTeam()
	vector origin = player.GetOrigin()

	//Create Castle Walls
	CastleWall_CreateCastle( player )

	//Apply Knockback & Blast//
	ArmoredLeap_ApplyKnockbackForce( player, origin, ARMORED_LEAP_IMPACT_RANGE, ARMORED_LEAP_DAMAGE, ARMORED_LEAP_MAX_FORCE )

}
#endif //SERVER


#if SERVER
void function ArmoredLeap_ApplyKnockbackForce( entity owner, vector origin, float forceRadius, int blastDamage, float blastForce )
{
	int team = owner.GetTeam()

	array<entity> players = GetPlayerArray_Alive()
	foreach ( entity player in players )
	{
		if( !(player.DoesShareRealms( owner ) ) )
			continue

		if( owner == player )
		{
			player.ViewPunch( origin, 5, -5, 2 )
			continue
		}

		float distTest = Distance( origin, player.GetOrigin() )
		float distSqr = DistanceSqr( origin, player.GetOrigin() )
		if ( distSqr > ( forceRadius * forceRadius ) )
			continue

		vector originToPlayer = FlattenVec( Normalize( player.GetCenter() - origin ) )

		float impulseForce = GraphCapped( distSqr, 0, forceRadius * forceRadius, blastForce, ARMORED_LEAP_MIN_FORCE)

		player.SetVelocity( ZERO_VECTOR )
		vector currentVel = player.GetVelocity()
		vector addedVel = ( originToPlayer + <0,0,0.5> ) * impulseForce //1.05
		vector newVel = currentVel + addedVel


		if ( IsFriendlyTeam( player.GetTeam(), team ) )
		{
			player.ViewPunch( origin, 15, -15, 5 )
			continue
		}
		else
		{
			player.SetVelocity( newVel )
			player.ViewPunch( origin, 35, -35, 5 )
		}

		float minDamage = ARMORED_LEAP_DAMAGE_MIN.tofloat()

		float proximityDamage = GraphCapped( distSqr, 0, forceRadius * forceRadius, blastDamage.tofloat(), minDamage  )
		blastDamage = proximityDamage.tointeger()
		player.TakeDamage( blastDamage, owner, owner, { damageSourceId = eDamageSourceId.mp_ability_armored_leap } )

		if ( player.Player_IsSkywardFollowing() )
			ValkUlt_AllyCancel( player )

		if ( player.Player_IsSkywardLaunching() )
		{
			ValkUlt_Canceled_ClearOffhand( player )
		}

		Bleedout_ReviveForceStop( player )
		if( player.ContextAction_IsMeleeExecution() )
		{
			//ExecutionCancelSendSignal( player )
			player.Signal("InterruptSyncedMelee")
		}

	}

	//Impact VFX//
	PlayImpactFXTable( origin, owner, ARMORED_LEAP_IMPACT_FX_TABLE )

	//Shockwave VFX//
	int fxid = GetParticleSystemIndex( ARMORED_LEAP_IMPACT_FX )
	StartParticleEffectInWorld( fxid, origin, <0,0,0> )

}
#endif //SERVER

/////////////////////////////////////////////////
///////////// UTILITY FUNCTIONS ////////////////
////////////////////////////////////////////////

array<entity> function ArmoredLeapIgnoreArray( entity castle = null, bool ignoreAllCastles = false, bool ignorePropDoors = false )
{
	array<entity> ignoreArray = GetPlayerArray_Alive()

	//Handle Castle Walls to Ignore
	if( ignoreAllCastles )
	{
		array<entity> shieldAnchor = GetEntArrayByScriptName( ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME ) //CAstle Anchor
		foreach ( shieldWall in shieldAnchor )
		{
			if( !IsValid( shieldWall ) )
				continue

			ignoreArray.append( shieldWall )
		}
	}
	else
	{
		#if SERVER
			//Append own CastleEnts into Ignore
			if( castle in file.castleEntArray )
			{
				foreach ( wallEnt in file.castleEntArray[castle] )
				{
					if( !IsValid(wallEnt) )
						continue

					ignoreArray.append( wallEnt )
				}
			}
		#endif
	}

	//Ignore Energy Shield Abilities
	array<entity> mobileShields = GetEntArrayByScriptName( MOBILE_SHIELD_SCRIPTNAME ) //mobile Shield Walls
	foreach ( shieldWall in mobileShields )
	{
		if( !IsValid(shieldWall) )
			continue
		ignoreArray.append( shieldWall )
	}

	array<entity> thrownShields = GetEntArrayByScriptName( SHIELD_THROW_SCRIPTNAME ) // mobile Shield Projectile
	foreach ( shield in thrownShields )
	{
		if( !IsValid(shield) )
			continue
		ignoreArray.append( shield )
	}

	array<entity> bubbleShields = GetEntArrayByScriptName( BUBBLE_SHIELD_SCRIPTNAME ) //CAstle Anchor
	foreach ( bubble in bubbleShields )
	{
		if( !IsValid(bubble) )
			continue
		ignoreArray.append( bubble )
	}

	array<entity> holoEnts = GetPlayerDecoyArray()
	ignoreArray.extend( holoEnts )

	if( ignorePropDoors )
		ignoreArray.extend( GetAllPropDoors() )

	return ignoreArray
}








// Utility Trace Constants for Targeting //
const bool DO_LEDGE_TRACE = true
const bool DO_LOWER_ANGLE_TRACE = true
const float DOWN_TRACE_DISTANCE = 1500.0
const float TUNNEL_STEP_DIST = 16.0
const float MINIMUM_TUNNEL_STEP_DIST = 4.0


float function GetArmoredLeapDistance( entity player )
{
	float result = file.maxDist

	                    
	if( IsValid( player ) && player.HasPassive( ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_newcastle_ult_distance
	{
		result *= GetUpgradedArmoredLeapDistance()
	}
       

	return result
}

float function GetArmoredLeapAllyDistance( entity player )
{
	float result = file.maxDistAlly

	                    
		if( IsValid( player ) && player.HasPassive( ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_newcastle_ult_distance
		{
			result *= GetUpgradedArmoredLeapDistance()
		}
       

	return result
}

float function GetArmoredLeapHeight( entity player )
{
	float result = file.maxHeight

	                    
		if( IsValid( player ) && player.HasPassive( ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_newcastle_ult_distance
		{
			result *= GetUpgradedArmoredLeapDistance()
		}
       

	return result
}

float function GetArmoredLeapHeightAlly( entity player )
{
	float result = file.maxHeightAlly

	                    
		if( IsValid( player ) && player.HasPassive( ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_newcastle_ult_distance
		{
			result *= GetUpgradedArmoredLeapDistance()
		}
       

	return result
}

ArmoredLeapTargetInfo function GetArmoredLeapTargetInfo( entity ent )
{
	ArmoredLeapTargetInfo info
	info.finalPos   = ent.GetOrigin()
	info.success    = false
	info.isOccluded = false
	info.hasAlly 	= false
	info.failCase	= eFailCase.DEFAULT

	vector eyePos = ent.EyePosition()
	vector eyeDir = ent.GetViewVector()
	eyeDir          = Normalize( eyeDir )
	info.eyeHitNorm = -eyeDir

	float rangeNormal = GetArmoredLeapDistance( ent )
	float rangeSqr    = rangeNormal * rangeNormal

	// Effective range based on a cylindrical range check instead of spherical
	float pitchClamped   = clamp( ent.EyeAngles().x, -70.0, 70.0 )
	float rangeEffective = rangeNormal / deg_cos( pitchClamped )

	bool foundValidEnd = false






	array<entity> ignoreArray = ArmoredLeapIgnoreArray()

	// Initial trace from eye - looking to hit something within range of the ability
	TraceResults initialTrace = TraceLine( eyePos, eyePos + (eyeDir * rangeEffective), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	info.eyeHitPos = initialTrace.endPos

	//LowDir is used when Aiming ABOVE a Ledge to help maintain the old target
	vector lowHitPos
	vector lowDir = AnglesToForward(AnglesCompose( VectorToAngles( eyeDir ), <ARMORED_LEAP_ABOVE_LEDGE_DEGREE_CHECK_OFFSET,0,0> ) )
	lowDir = Normalize( lowDir )

	entity hitEnt = initialTrace.hitEnt
	if( IsValid( hitEnt ) )
	{
		info.hitEnt = hitEnt
		string scriptName = hitEnt.GetScriptName()
		if( scriptName == JUMP_PAD_SCRIPTNAME ) //prevent targeting on Octane Jump Pads
			return info

		if( EntIsHoverVehicle(hitEnt) )
			return info
	}

	if( !ent.IsOnGround() )
	{
		// Min Air Allowance Trace
		const float ARMORED_LEAP_MIN_HOVER_AIR_HEIGHT = 100 // Player must be at least this high off ground to be allowed to target in the air.
		TraceResults minAirTrace = TraceLine( ent.GetOrigin(), ent.GetOrigin() + <0,0,-ARMORED_LEAP_MIN_HOVER_AIR_HEIGHT>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if( minAirTrace.fraction < 1 )
			return info
	}

	if( !ArmoredLeap_HasValidHullRoom( ent, ent.GetOrigin() ) )
	{
		info.failCase = eFailCase.BLOCKED_LEAP
		return info
	}

	#if DEV
		if( DEBUG_ARMORED_LEAP_TARGETING_DRAW )
		{
			//InitialTrace  	= AQUA
			//DownTraceEnd		= GREEN
			//LedgeAbove		= YELLOW/ORANGE //Aiming at Wall - Look for Ledge Above
			//LedgeBelow		= PINK/PURPLE/RED //Aiming at Air - Look for Ledge below
			DebugDrawSphere( initialTrace.endPos, 5.0, <0, 150, 150>, false, 0.1 ) //AQUA (Initial Trace)
		}
	#endif

	vector adjustedEndPos = initialTrace.endPos


	// ALLY & LKP //
	// Setting the Ally Target and LKP here on the client updates info.airPoint and info.failReason as it tests for validity to the LKP/Ally Target
	entity targetAlly = GetAllyTargetInRange( ent )
	ArmoredLeap_SetAllyTargetAndLKP( ent, info )

	if( ent in file.allyTarget )
	{
		if( IsValid(file.allyTarget[ent]) )
		{
			targetAlly = file.allyTarget[ent]
		}
	}
	if( ent in file.allyLKP )
	{
		adjustedEndPos = file.allyLKP[ent]
		foundValidEnd = true
	}

	if( !foundValidEnd )
	{

		bool didLowerTraceHit = false
		if ( initialTrace.fraction < 1.0 )
		{
			if ( DotProduct( initialTrace.surfaceNormal, <0, 0, 1> ) > 0.85 )
			{
				hitEnt = initialTrace.hitEnt
				//foundValidEnd = true
				foundValidEnd = ArmoredLeap_HasValidLandingRoom( ent, adjustedEndPos, info )
				if( !foundValidEnd )
				{
					//If Invalid - Check for a LIP. Walk back the test point and test again for landing room//
					//This is to keep the Placement Target on the ledge without invalidating it when you're looking at a space with no landing room.

					const float ARMORED_LEAP_LIP_TEST_STEP = 16
					float backStep = ARMORED_LEAP_LIP_TEST_STEP //32 //48 //64


					for( int i=0; i < 4; i++ ) //This is potentially a lot of extra traces - Runs often on the client / runs once during selection on the server
					{
						vector lipTestPos = adjustedEndPos - eyeDir * backStep
						TraceResults lipTrace = TraceLine( lipTestPos, lipTestPos + <0, 0, -100>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

						if ( lipTrace.fraction < 1.0 )
						{
							foundValidEnd = ArmoredLeap_HasValidLandingRoom( ent, lipTrace.endPos, info )
							if( foundValidEnd )
							{
								hitEnt = lipTrace.hitEnt
								adjustedEndPos = lipTrace.endPos
								break
							}
							else info.failCase = eFailCase.BLOCKED_LANDING

						}
						backStep += ARMORED_LEAP_LIP_TEST_STEP
					}

				}

				//Look ahead for a wall, if there IS a wall, re-adjust the ground point.
				vector flatEyeDir 	= FlattenVec(eyeDir)
				vector raisedEndPos	= adjustedEndPos + <0,0,ARMORED_LEAP_OFFSET_TEST_HEIGHT>
				vector wallTestPos 	= raisedEndPos + flatEyeDir * ARMORED_LEAP_MIN_TARGET_DIST_TO_WALL
				TraceResults wallAheadTrace = TraceLine( raisedEndPos, wallTestPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

				if ( wallAheadTrace.fraction < 1.0 ) //found collision ahead
				{
					if( DotProduct( wallAheadTrace.surfaceNormal, <0, 0, 1> ) < 0.85 ) //Is a Wall not a Slope
					{
						float distDiff = Distance(wallTestPos, wallAheadTrace.endPos)
						raisedEndPos = raisedEndPos - flatEyeDir *distDiff
						TraceResults pushbackTrace = TraceLine( raisedEndPos, raisedEndPos + <0,0,-100>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
						if ( pushbackTrace.fraction < 1.0 )
						{
							foundValidEnd = ArmoredLeap_HasValidLandingRoom( ent, pushbackTrace.endPos, info )
							if( foundValidEnd )
							{
								adjustedEndPos = pushbackTrace.endPos
								hitEnt = pushbackTrace.hitEnt
							}
							else info.failCase = eFailCase.BLOCKED_LANDING
						}
					}
				}
			}
			else
			{
				adjustedEndPos -= eyeDir * ARMORED_LEAP_MIN_TARGET_DIST_TO_WALL
			}
		}
		else
		{
			//We have no surface contact. Check LowDir to confirm a ledge or maintain a long drop. - Helps keep ledges when looking above a surface
			TraceResults lowTrace = TraceLine( eyePos, eyePos + (lowDir * rangeEffective), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			if( lowTrace.fraction < 1.0 )
			{
				if ( DotProduct( Normalize(lowTrace.surfaceNormal), <0, 0, 1> ) < 0.75 ) //We only want to validate a LowHit if it strikes a wall (for ledges) - Ignore looking at ground.
				{
					lowHitPos = lowTrace.endPos
					didLowerTraceHit = true
				}
			}
		}


		if ( DO_LEDGE_TRACE && !foundValidEnd && (initialTrace.fraction < 1.0 || didLowerTraceHit) )
		{
			vector lookPos          = didLowerTraceHit ? lowHitPos : initialTrace.endPos
			vector lookDir			= didLowerTraceHit ? lowDir : eyeDir
			vector ledgeTraceStart  = lookPos + <0, 0, 200.0> + Normalize( <lookDir.x, lookDir.y, 0> ) * ARMORED_LEAP_LEDGE_INSET_AMOUNT
			TraceResults ledgeTrace = TraceHull( ledgeTraceStart, ledgeTraceStart + <0, 0, -200>, ent.GetPlayerMins(), ent.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )


			#if DEV
				if( DEBUG_ARMORED_LEAP_TARGETING_DRAW )
				{
					DebugDrawSphere( ledgeTraceStart, 8.0, COLOR_YELLOW, true, 0.1 ) //YELLOW (LedgeStart)
					DebugDrawSphere( ledgeTrace.endPos, 15.0, <255, 175, 0>, true, 0.1 ) //ORANGE (LedgeEnd)
					DebugDrawCircle( ledgeTrace.endPos, VectorToAngles(ledgeTrace.surfaceNormal), 64, <255, 175, 175>, true, 0.1, 3 )
				}
			#endif

			bool isHigher = ( ledgeTrace.endPos.z + 64.0 ) > lookPos.z
			float frac = ledgeTrace.fraction
			bool solid = ledgeTrace.startSolid
			if ( ledgeTrace.fraction < 1.0 && isHigher && !ledgeTrace.startSolid )
			{
				hitEnt = ledgeTrace.hitEnt
				bool ledgeRoomAirCheck = ArmoredLeap_HasValidLeapPos( ent, null, ledgeTrace.endPos, hitEnt, info ) //ledgeRoomTrace.endPos // We REALLY only need the "slam" part of this check. Refactor later?
				if ( ledgeRoomAirCheck == true )
				{
					adjustedEndPos = ledgeTrace.endPos
					foundValidEnd  = true
				}
			}
		}

		vector airPos = adjustedEndPos

		if ( !foundValidEnd )
		{
			TraceResults downTrace = TraceLine( airPos, airPos - <0.0, 0.0, DOWN_TRACE_DISTANCE>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

			if ( downTrace.fraction < 1.0 )
			{
				hitEnt = downTrace.hitEnt
				if (DotProduct( eyeDir, Normalize( downTrace.endPos - eyePos ) ) > 0.88 )
				{
					adjustedEndPos = downTrace.endPos
					foundValidEnd  = true
				}
			}

			#if DEV
				if( DEBUG_ARMORED_LEAP_TARGETING_DRAW )
				{
					DebugDrawSphere( downTrace.endPos, 5.0, COLOR_GREEN, false, 0.1 ) //GREEN (Downcast End)
				}
			#endif
		}

		if ( !foundValidEnd )
		{
			//We haven't found a Valid End - but there could be a ledge below us.
			airPos = adjustedEndPos

			lowDir = AnglesToForward(AnglesCompose( VectorToAngles( eyeDir ), <ARMORED_LEAP_ABOVE_LEDGE_DEGREE_CHECK_OFFSET,0,0> ) )
			lowDir = Normalize( lowDir )

			vector adjustedAirPos = eyePos + lowDir * rangeEffective
			TraceResults lowAirTrace = TraceLine( eyePos, adjustedAirPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			if ( lowAirTrace.fraction < 1.0 )
			{
				//--Hey. We hit something on the lower cast! Let's make a ledge check--//
				vector lowAirDir = Normalize( lowAirTrace.endPos - eyePos )
				vector ledgeInset = lowAirTrace.endPos + lowAirDir * ARMORED_LEAP_LEDGE_INSET_AMOUNT
				ledgeInset = < ledgeInset.x, ledgeInset.y, lowAirTrace.endPos.z > //Flatten height

				vector intersect = ledgeInset + <0,0,ARMORED_LEAP_ABOVE_LEDGE_DOWN_TRACE_OFFSET>

				TraceResults dropAirTrace = TraceLine( intersect, ledgeInset + <0,0,ARMORED_LEAP_LEDGE_INSET_DOWN_TRACE> , ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
				hitEnt = dropAirTrace.hitEnt
				if( dropAirTrace.fraction < 1 && ArmoredLeap_HasValidLeapPos( ent, null, dropAirTrace.endPos, hitEnt, info ))
				{
					//If I can SEE this endPoint - we're on a slope bouncing back. Don't do it.
					TraceResults sightTrace = TraceLine( eyePos, dropAirTrace.endPos + <0,0,8> , ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
					if( sightTrace.fraction < 1.0 )
					{
						adjustedEndPos = dropAirTrace.endPos
						foundValidEnd = true
					}
				}
				#if DEV
					if( DEBUG_ARMORED_LEAP_TARGETING_DRAW )
					{
						DebugDrawSphere( intersect, 8.0, <255, 0, 250>, false, 0.1 ) //PINK (LedgeInset)
						DebugDrawSphere( dropAirTrace.endPos, 15.0, <255, 0, 100>, true, 0.1 ) //RED (LedgeDropEnd)
					}
				#endif
			}

			#if DEV
				if( DEBUG_ARMORED_LEAP_TARGETING_DRAW )
				{
					DebugDrawSphere( lowAirTrace.endPos, 5.0, <100, 0, 50>, true, 0.1 ) //PURPLE (LowAir)
				}
			#endif

			if ( !foundValidEnd )
				return info

		}

		foundValidEnd  = ArmoredLeap_HasValidLeapPos( ent, null, adjustedEndPos, hitEnt, info ) //nullifying out the ally check since we're past that.

		if ( !foundValidEnd )
			return info

		if( IsValid( targetAlly ) )
			info.failCase = eFailCase.BLOCKED_ALLY
	}


	vector portalPos = ent.GetOrigin()
	vector portalDir = Normalize( adjustedEndPos - portalPos )
	float distCheck  = Distance( portalPos, adjustedEndPos )

	while ( info.pathDistance < distCheck )
	{
		float step = min( TUNNEL_STEP_DIST, distCheck - info.pathDistance )

		if ( step < MINIMUM_TUNNEL_STEP_DIST )
			break

		vector newPos = portalPos + (portalDir * step)


		info.pathDistance += step
		info.posList.append( newPos )
		info.finalPos = (newPos)
		info.hitEnt = hitEnt
		portalPos     = newPos
	}

	info.success    = info.pathDistance > ARMORED_LEAP_DISTANCE_MIN && foundValidEnd
	info.isOccluded = !PlayerCanSeePos( ent, info.finalPos, true, 70 )

	return info
}

//Try and get an air position that will better pass the code IsArmoredLeapTravelBlocked() checks.
ArmoredLeapTargetInfo function GetBetterAirPos( entity player, ArmoredLeapTargetInfo info )
{
	if ( IsValid( player ) && info.success )
	{
		TraceResults groundTraceResult = TraceHull( info.finalPos + <0, 0, 10>, info.finalPos - <0, 0, 2000>, player.GetPlayerMins(), player.GetPlayerMaxs(), player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		info.finalPos = groundTraceResult.endPos
		array<entity> ignoreArray = ArmoredLeapIgnoreArray()
		vector playerPos          = player.GetOrigin()
		vector groundOffset	  = player.IsOnGround() ? <0, 0, 48> : <0, 0, 0> //additional offset when on the ground so we don't get caught on low geo, or have traces think they hit right away.
		playerPos += groundOffset
		float distCheck           = Distance( player.GetOrigin(), info.finalPos )
		//Take the airheight from ArmoredLeapTargetInfo
		//We should never get a ZERO_VECTOR airPos, but we did in the past due to a bug.  That bug has since been fixed, but going to leave this guard in here in case others crop up.  The results have NC leaping really high in the air, which we want to avoid.
		float airHeight           = info.airPos == ZERO_VECTOR ? ARMORED_LEAP_MAX_AIR_HEIGHT : info.airPos.z - info.finalPos.z
		TraceResults traceUp      = TraceHull( info.finalPos, info.finalPos + <0, 0, airHeight>, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

		#if DEV
		if ( DEBUG_BETTER_AIR_POS )
		{
			DebugDrawText( info.eyeHitPos, "info.eyeHitPos", true, 0.1 )
			DebugDrawText( info.finalPos, "info.finalPos", true, 0.1 )
			DebugDrawText( traceUp.endPos, "traceUp.endPos", true, 0.1 )
		}
		#endif //DEV

		//start looking along our air pos to find the highest unblocked one that we can.
		const int findPosIterations = 5
		float airDis = Distance( info.finalPos, traceUp.endPos )
		float interationDist = airDis / findPosIterations
		bool foundGoodAirPos = false
		vector goodAirPos = ZERO_VECTOR

		for ( int i = 0; i < findPosIterations; i++ )
		{
			//nested loop that sets this can't break out of parent loop
			if ( foundGoodAirPos )
				break

			float zOffSet = i * interationDist

			vector leapDir = Normalize( ( traceUp.endPos - <0, 0, zOffSet> ) - playerPos )
			vector traceTarget = traceUp.endPos - <0, 0, zOffSet>

			TraceResults iterationTrace = TraceHull( playerPos, traceTarget, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

			//Had issues where taces to ground could come back with 0.996 etc.  Calling 0.99 "good enough" here.
			if ( iterationTrace.fraction >= 0.99 )
			{
				#if DEV
				if ( DEBUG_BETTER_AIR_POS )
				{
					DebugDrawMark( iterationTrace.endPos, 10, COLOR_GREEN, true, 0.1 )
					DebugDrawLine( playerPos, traceTarget, COLOR_CYAN, true, 0.1 )
					DebugDrawText( iterationTrace.endPos, "fraction: " + iterationTrace.fraction, true, 0.1 )
				}
				#endif //DEV

				if ( !foundGoodAirPos )
				{
					//vector function GetBetterAirPos_FindOffsetPos( entity player, vector leapdir, vector airPos, vector endPos )
					FindOffsetPosStruct offsetData = GetBetterAirPos_FindOffsetPos( player, ignoreArray, leapDir, traceTarget, info.finalPos )

					if ( offsetData.success )
					{
						foundGoodAirPos = true
						goodAirPos      = offsetData.position
					}
				}
			}
			else
			{
				#if DEV
				if ( DEBUG_BETTER_AIR_POS )
				{
					DebugDrawLine( playerPos, traceTarget, COLOR_RED, true, 0.1 )
					DebugDrawMark( iterationTrace.endPos, 10, COLOR_RED, true, 0.1 )
					DebugDrawText( iterationTrace.endPos, "fraction: " + iterationTrace.fraction, true, 0.1 )
				}
				#endif
			}
		}

		//lets try moving our air pos back towards us if we haven't found a valid position yet.
		if ( !foundGoodAirPos )
		{
			TraceResults traceUpPlayer = TraceHull( player.GetOrigin(), player.GetOrigin() + <0, 0, airHeight>, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			traceUp = TraceLine( info.finalPos, info.finalPos + <0, 0, airHeight>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			vector abovePlayer = traceUpPlayer.endPos
			vector aboveDest = traceUp.endPos
			vector walkBackDir = Normalize( aboveDest - abovePlayer )
			float walkBackDistTotal = Distance( aboveDest, abovePlayer )

			#if DEV
			if ( DEBUG_BETTER_AIR_POS )
			{
				DebugDrawMark( abovePlayer, 10, COLOR_YELLOW, true, 0.1 )
				DebugDrawMark( aboveDest, 10, COLOR_MAGENTA, true, 0.1 )
			}
			#endif

			const int walkBackIterations = 8
			float walkBackIterationDist = walkBackDistTotal / walkBackIterations
			bool validDirectlyOverEnd = false
			bool validDirectlyOverPlayer = false
			vector validDirectlyOverEndPos = ZERO_VECTOR
			vector validDirectlyOverPlayerPos = ZERO_VECTOR

			for ( int i = walkBackIterations; i >= 0; i-- )
			{
				float iterationDist = i * walkBackIterationDist
				vector walkBackIterationPos = abovePlayer + ( walkBackDir * iterationDist )

				TraceResults traceToWalkbackPos

				//this will be the directly above endPos trace, do a line so that its less strict.
				if ( i == walkBackIterations )
				{
					traceToWalkbackPos = TraceLine( player.GetOrigin(), walkBackIterationPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
				}
				else
				{
					traceToWalkbackPos = TraceHull( player.GetOrigin(), walkBackIterationPos, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
				}

				if ( traceToWalkbackPos.fraction >= 0.99 )
				{
					#if DEV
						if ( DEBUG_BETTER_AIR_POS )
						{
							DebugDrawLine( player.GetOrigin(), traceToWalkbackPos.endPos, COLOR_GREEN, true, 0.1 )
							DebugDrawText( traceToWalkbackPos.endPos, "fraction: " + traceToWalkbackPos.fraction, true, 0.1 )
						}
					#endif

					//trace to finalPos
					TraceResults traceFinalPos = TraceHull( walkBackIterationPos, info.finalPos, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

					if ( traceFinalPos.fraction >= 0.99 )
					{
						#if DEV
							if ( DEBUG_BETTER_AIR_POS )
							{
								DebugDrawLine( walkBackIterationPos, traceFinalPos.endPos, COLOR_GREEN, true, 0.1 )
								//DebugDrawText( iterationTrace.endPos, "fraction: " + iterationTrace.fraction, true, 0.1 )
							}
						#endif

						//clear directly above the player, try and walk it back so its not a straight line down if possible.
						if ( i == walkBackIterations )
						{
							FindOffsetPosStruct offsetData = GetBetterAirPos_FindOffsetPos( player, ignoreArray, walkBackDir, walkBackIterationPos, info.finalPos )

							if ( offsetData.success )
							{
								foundGoodAirPos = true
								goodAirPos      = offsetData.position
								break
							}
							else
							{
								foundGoodAirPos = true
								goodAirPos      = walkBackIterationPos
								break
							}
						}
						else
						{
							foundGoodAirPos = true
							goodAirPos      = walkBackIterationPos
							break
						}
					}
					else
					{
						#if DEV
							if ( DEBUG_BETTER_AIR_POS )
							{
								DebugDrawLine( walkBackIterationPos, info.finalPos, COLOR_RED, true, 0.1 )
								DebugDrawMark( traceFinalPos.endPos, 25, COLOR_RED, true, 0.1 )
								DebugDrawText( traceFinalPos.endPos, "fraction: " + traceFinalPos.fraction, true, 0.1 )
							}
						#endif
					}
				}
				else
				{
					#if DEV
						if ( DEBUG_BETTER_AIR_POS )
						{
							DebugDrawLine( player.GetOrigin(), walkBackIterationPos, COLOR_RED, true, 0.1 )
							DebugDrawMark( traceToWalkbackPos.endPos, 25, COLOR_RED, true, 0.1 )
							DebugDrawText( traceToWalkbackPos.endPos, "fraction: " + traceToWalkbackPos.fraction, true, 0.1 )
						}
					#endif
				}
			}
		}

		if ( foundGoodAirPos )
		{
			info.airPos = goodAirPos

			#if DEV
			if ( DEBUG_BETTER_AIR_POS )
			{
				float drawTime = 0.1
				#if SERVER
				drawTime = 5.0
				#endif

				DebugDrawMark( info.finalPos, 25, COLOR_YELLOW, true, drawTime )
				DebugDrawMark( goodAirPos, 25, COLOR_CYAN, true, drawTime )
				DebugDrawText( player.GetWorldSpaceCenter(), "foundGoodAirPos found!", true, 0.1 )
			}
			#endif //DEV
		}
		else
		{
			#if DEV
			if ( DEBUG_BETTER_AIR_POS )
			{
				DebugDrawText( player.GetWorldSpaceCenter(), "foundGoodAirPos NOT found!", true, 0.1 )
			}
			#endif //DEV
		}
	}

	return info
}

FindOffsetPosStruct function GetBetterAirPos_FindOffsetPos( entity player, array< entity > ignoreArray, vector leapDir, vector airPos, vector endPos )
{
	FindOffsetPosStruct results
	results.success = false
	results.position = ZERO_VECTOR
	//the air pos looks good, but can we still make it back to the target dest?
	//Start off ARMORED_LEAP_AIR_POS_OFFSET away from directly above our end pos, move closer and closer though if we don't have a path (worst case is directly above endPos)
	const int endPosInterations = 3
	float iterationToEndDist = ARMORED_LEAP_AIR_POS_OFFSET / endPosInterations

	for ( int x = endPosInterations; x >= 0; x-- )
	{
		float offset = x * iterationToEndDist
		vector offsetTraceTarget = airPos - ( leapDir * offset )

		TraceResults destinationTrace = TraceHull( offsetTraceTarget, endPos, player.GetPlayerMins(), player.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

		if ( destinationTrace.fraction >= 0.99 )
		{
			#if DEV
			if ( DEBUG_BETTER_AIR_POS )
			{
				DebugDrawMark( destinationTrace.endPos, 10, COLOR_GREEN, true, 0.1 )
				DebugDrawLine( offsetTraceTarget, destinationTrace.endPos, COLOR_GREEN, true, 0.1 )
				DebugDrawText( offsetTraceTarget, "goodAirPos! fraction: " + destinationTrace.fraction, true, 0.1 )
			}
			#endif //DEV

			results.success = true
			results.position = offsetTraceTarget
			return results
		}
		else
		{
			#if DEV
			if ( DEBUG_BETTER_AIR_POS )
			{
				DebugDrawMark( destinationTrace.endPos, 10, COLOR_RED, true, 0.1 )
				DebugDrawLine( offsetTraceTarget, destinationTrace.endPos, COLOR_RED, true, 0.1 )
				DebugDrawText( offsetTraceTarget, "fraction: " + destinationTrace.fraction, true, 0.1 )
			}
			#endif //DEV
		}
	}

	return results
}

vector function ArmoredLeap_GetBestAllyLandingPos( entity ent, vector endPos, vector eyeDir, ArmoredLeapTargetInfo info )
{
	vector bestPos = endPos
	array<entity> ignoreArray = ArmoredLeapIgnoreArray()
	if( !ArmoredLeap_HasValidLandingRoom( ent, endPos, info ) )
	{
		vector traceOrigin                  = ent.EyePosition() //trace.endPos
		array<vector> ridgeTraceVectorArray //= [ <1, 0, 0>, <-1, 0, 0>, <0.5, 0.86, 0>, <-0.5, -0.86, 0>, <0.5, -0.86, 0>, <-0.5, 0.86, 0> ]
		//Starting with FORWARD/BACK - test possible nearby locations for landing.
		int maxNumChecks = 6
		float angleOffset = 360 / maxNumChecks.tofloat()
		float angle = 0

		eyeDir = FlattenVec(Normalize( endPos - ent.EyePosition() ))
		ridgeTraceVectorArray.append( eyeDir )

		for ( int i=1;i<maxNumChecks;i++ )
		{
			eyeDir = -(eyeDir) // * -1 //flip the eye Dir each time so we check front & back//

			vector offsetVec = RotateVector( eyeDir, <0,angle,0> )
			ridgeTraceVectorArray.append( offsetVec )
			if( i == 1 )
				angle = angle + angleOffset
			if( i == 5 )
				angle = angle + angleOffset
			if( IsOdd( i ) )
				angle = angle * -1
		}

		foreach ( traceVector in ridgeTraceVectorArray )
		{
			vector ridgeOrigin      = endPos + <0, 0, ARMORED_LEAP_OFFSET_TEST_HEIGHT> + traceVector * 64
			vector ridgeTraceOrigin = endPos + <0, 0, -ARMORED_LEAP_OFFSET_TEST_HEIGHT> + traceVector * 64

			TraceResults ridgeTrace = TraceLine( ridgeOrigin, ridgeTraceOrigin, ignoreArray, (TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | CONTENTS_NOAIRDROP), TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, ent )
			float fraction          = ridgeTrace.fraction
			if ( fraction == 1 )
			{
				//DebugDrawSphere( ridgeTrace.endPos, 5, COLOR_RED, true, 0.1 )
				continue
			}

			bestPos = ridgeTrace.endPos
			if( ArmoredLeap_HasValidLandingRoom( ent, bestPos, info )  )
			{
				//DebugDrawSphere( ridgeTrace.endPos, 5, COLOR_GREEN, true, 0.1 )
				return bestPos
			}

			//DebugDrawSphere( ridgeTrace.endPos, 5, COLOR_YELLOW, true, 0.1 )
		}
	}

	return endPos
}

bool function ArmoredLeap_HasValidLandingRoom( entity ent, vector endPos, ArmoredLeapTargetInfo info )
{
	bool isTriangle = true

	array<entity> ignoreArray = ArmoredLeapIgnoreArray()

	if( !ArmoredLeap_HasValidHullRoom(ent, endPos+ ARMORED_LEAP_ENDPOINT_BUFFER, true) )
	{
		info.failCase = eFailCase.BLOCKED_LANDING
		return false
	}
	if( isTriangle )
	{
		//Triangle Cast // to check if we are on a ridge. makes a tringle and all traces have to hit solid or we are probably on a ridge.
		//This gives us false negatives on Ledges and Corners where you have plenty of room behind the ledge.
		vector traceOrigin                  = endPos //trace.endPos
		array<vector> ridgeTraceVectorArray = [ <1, 0, 0>, <-0.5, 0.86, 0>, <-0.5, -0.86, 0> ] //[ <1, 0, 0>, <-0.5, 0.86, 0>, <-0.5, -0.86, 0> ]
		foreach ( traceVector in ridgeTraceVectorArray )
		{
			vector ridgeOrigin      = endPos + <0, 0, ARMORED_LEAP_OFFSET_TEST_HEIGHT> + traceVector * 64 //18 //<0, 0, 16> //traceOrigin
			vector ridgeTraceOrigin = endPos + <0, 0, -ARMORED_LEAP_OFFSET_TEST_HEIGHT> + traceVector * 64 //18 //<0, 0, -12>

			TraceResults ridgeTrace = TraceLine( ridgeOrigin, ridgeTraceOrigin, ignoreArray, (TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | CONTENTS_NOAIRDROP), TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, ent )
			float fraction          = ridgeTrace.fraction
			if ( fraction == 1 )
			{
				//DebugDrawArrow( ridgeOrigin, ridgeTrace.endPos, 4, <0, 128, 128>, true, 0.1 )

				info.failCase = eFailCase.BLOCKED_LANDING
				return false
			}
		}
	}


	return true
}

bool function ArmoredLeap_HasValidHullRoom( entity ent, vector pos, bool useLandingHulls = false )
{
	vector up = <0,0,1>
	array<entity> ignoreArray = ArmoredLeapIgnoreArray()

	vector mins = ent.GetPlayerMins()
	vector maxs = ent.GetPlayerMaxs()
	maxs = < maxs.x, maxs.y, 80 > //max changes to 47 when crouched. We always want to assume standing.

	if( useLandingHulls )
		maxs = maxs + <0,0,38>

	TraceResults results = TraceHull( pos, pos, mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent )
	if ( results.startSolid )
	{
		return false
	}

	return true
}

bool function ArmoredLeap_HasValidLeapPos( entity ent, entity targetAlly, vector endPos, entity traceHitEnt,  ArmoredLeapTargetInfo info )
{
	bool hasValidAirPosition = true

	vector eyePos = ent.EyePosition()
	vector eyeDir = ent.GetViewVector()
	eyeDir          = Normalize( eyeDir )

	array<entity> ignoreArray = ArmoredLeapIgnoreArray()

	vector leapPos = ent.GetOrigin()
	vector leapDir = Normalize( endPos - leapPos )
	float distCheck  = Distance( leapPos, endPos )

	float maxHeight	  = GetArmoredLeapHeight( ent )//ARMORED_LEAP_MAX_LEAP_HEIGHT
	float vertDist	= endPos.z - leapPos.z

	vector adjustedEndPos = endPos + < 0, 0, 5 > //Minor bump from ground to prevent odd detection cases//

	info.hitEnt = traceHitEnt

	if( !ArmoredLeap_IsValidPosition( ent, endPos, traceHitEnt ) )
	{
		info.failCase = eFailCase.DEFAULT
		return false
	}

	if( !ArmoredLeap_HasValidLandingRoom( ent, endPos, info ) )
	{
		info.failCase = eFailCase.BLOCKED_LANDING
		return false
	}

	if( !ent.IsOnGround() ) //IsValid(targetAlly) &&
	{
		//TraceResults allyTrace = TraceLine( leapPos, endPos, ignoreArray, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		TraceResults airLOSTrace = TraceLine( leapPos, endPos, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		//TraceResults airLOSTrace = TraceHull( leapPos, endPos, ent.GetPlayerMins(), ent.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if ( airLOSTrace.fraction < 0.98 )//If we're in the air, targeting an Ally - we can't JUMP. Don't dash through walls!
			return false
	}

	//Max Height Check - Excluded if Valid Ally
	//printt("TotalDist:  " + distCheck + "   |  Meters: " + (distCheck/ (100 / 2.54)) )
	//printt("VertDist:  " + vertDist + "   |  Meters: " + (vertDist/ (100 / 2.54)) )
	//printt("Meters: " + (ARMORED_LEAP_DISTANCE/ (100 / 2.54)) )

	if( IsValid(targetAlly) )
		maxHeight = GetArmoredLeapHeightAlly( ent ) //ARMORED_LEAP_MAX_LEAP_HEIGHT_ALLY

	if( vertDist > maxHeight )
	{
		info.failCase = eFailCase.DEFAULT
		return false
	}

	//--Default Desired Air Location--//
	float airHeight = GraphCapped( distCheck, 0, ARMORED_LEAP_FAR_AIR_HEIGHT_DIST, ARMORED_LEAP_CLOSE_AIR_HEIGHT, ARMORED_LEAP_FAR_AIR_HEIGHT )
	vector airLeapPos = ( endPos + < 0, 0, airHeight > ) - ( leapDir * ARMORED_LEAP_AIR_POS_OFFSET )

	//--Check for Landing ( slam ) clearance--//
	bool isDash = ArmoredLeap_IsInDashRange(ent, adjustedEndPos, traceHitEnt)

	vector up = <0,0,1>
	vector mins = ARMORED_LEAP_COL_MINS
	vector maxs = ARMORED_LEAP_COL_MAXS

	if( !isDash ) //We only need to check for Air Clearance if we're LEAPING
	{
		bool hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, airLeapPos )
		TraceResults upAirTrace = TraceLine( adjustedEndPos, airLeapPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_ABILITY
		if ( upAirTrace.fraction < 1.0 || !hasAirSpace )
		{
			//--Ceiling Detected at Landing Location -- Check for Human Height Clearance --//
			vector newAirLeapPos = upAirTrace.endPos - < 0, 0, ARMORED_LEAP_HUMAN_HEIGHT_OFFSET >
			hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, newAirLeapPos )

			TraceResults newAirLeapTrace = TraceLine( newAirLeapPos, adjustedEndPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			float zDist = Distance( < 0, 0, newAirLeapPos.z>, < 0, 0, endPos.z >  )
			if( zDist < ARMORED_LEAP_MIN_AIR_HEIGHT || newAirLeapTrace.fraction < 1 || !hasAirSpace)
			{
				//--Not enough clearance at Target Location
				//DebugDrawSphere( newAirLeapPos, 5, <hasAirSpace ? 0 : 255, hasAirSpace ? 255 : 0, 0>, true, 0.1, 8 )
				//DebugDrawBox( newAirLeapPos, ent.GetPlayerMins(), ent.GetPlayerMaxs(), COLOR_GREEN, 1, 0.1 )
				//DebugDrawLine( newAirLeapPos, adjustedEndPos, COLOR_GREEN, true, 0.1 )

				//Natrual Trajectory of Slam is Blocked - Try directly above
				//This additional step solves for situations that would fail when the target ally was TOO CLOSE to cover and the angle of the slam would fail.
				vector overheadAirPos = endPos + < 0, 0, airHeight >
				hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, overheadAirPos )

				TraceResults overheadAirLeapTrace = TraceLine( adjustedEndPos, overheadAirPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
				if ( overheadAirLeapTrace.fraction < 1.0 || !hasAirSpace)
				{
					//Ceiling Directly Above
					newAirLeapPos = overheadAirLeapTrace.endPos - < 0, 0, ARMORED_LEAP_HUMAN_HEIGHT_OFFSET >
					hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, overheadAirPos )
					TraceResults newOverheadAirLeapTrace = TraceLine( newAirLeapPos, adjustedEndPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
					zDist = Distance( < 0, 0, newAirLeapPos.z>, < 0, 0, endPos.z >  )
					if( zDist < ARMORED_LEAP_MIN_AIR_HEIGHT || newOverheadAirLeapTrace.fraction < 1 || !hasAirSpace )
					{
						//DebugDrawSphere( newAirLeapPos, 5, COLOR_RED, true, 0.1, 8 )
						info.failCase = eFailCase.BLOCKED_LANDING
						return false
					}

				}
				else
				{
					newAirLeapPos = overheadAirPos
				}

			}

			airLeapPos = newAirLeapPos
		}


		//TRY CHANGING THESE TO THE HULL TRACE - THIS IS WHERE 90% OF THE DASH PROBLEMS LIE WHEN YOU CLIP BULDINGS/OVERHANGS//
		//--Check for Trajectory (AirDash) Clearance--//
		hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, airLeapPos )
		TraceResults dashTrace = TraceHull( eyePos, airLeapPos, mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent ) //TRACE_MASK_PLAYERSOLID
		if( dashTrace.fraction < 1.0 || !hasAirSpace)
		{
			//--No LoS to Dash Location--//
			//Try Dropping slightly lower to see if we've just hit a weird edge case
			vector dropLeapPos = airLeapPos + < 0, 0, ARMORED_LEAP_HUMAN_HEIGHT_OFFSET >
			hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, dropLeapPos )
			TraceResults dashDropTrace = TraceHull( eyePos, dropLeapPos,  mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent )
			TraceResults dashDropToEnd = TraceLine( dropLeapPos, adjustedEndPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

			if( dashDropTrace.fraction < 1.0 || dashDropToEnd.fraction < 1 || !hasAirSpace )
			{
				//Still no dice. Try min jump height
				dropLeapPos = <dropLeapPos.x, dropLeapPos.y, endPos.z> + < 0, 0, ARMORED_LEAP_MIN_AIR_HEIGHT >
				hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, dropLeapPos )

				TraceResults dashMinHeightTrace = TraceHull( eyePos, dropLeapPos,  mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent )
				TraceResults dashMinToEnd 		= TraceLine( dropLeapPos, adjustedEndPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

				if( dashMinHeightTrace.fraction < 1.0 || dashMinToEnd.fraction < 1.0 || !hasAirSpace)
				{
					//--No LoS to Dash Location--//

					//If we have a valid Ally, but no normal dash line. SUPER JUMP test!
					if( IsValid(targetAlly) )
					{
						airHeight = ARMORED_LEAP_MAX_AIR_HEIGHT

						vector airLeapTestPos = ( endPos + < 0, 0, airHeight > ) - ( leapDir * ARMORED_LEAP_AIR_POS_OFFSET)
						hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, airLeapTestPos )

						TraceResults dashHighTrace = TraceHull( eyePos, airLeapTestPos,  mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent )

						if( dashHighTrace.fraction < 1.0 || !hasAirSpace)
						{
							float minLeapAirDist = Distance2D( ent.GetOrigin(), endPos ) / 3 //Pull super jump air point closer to Newcastle (will likely need to replace this with a path to go over)

							airLeapTestPos = ( ent.GetOrigin() + < 0, 0, airHeight > ) + leapDir * minLeapAirDist
							hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, airLeapTestPos )

							TraceResults superDashTrace = TraceHull( eyePos, airLeapTestPos,  mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent )

							if( superDashTrace.fraction < 1 || !hasAirSpace)
							{
								airLeapTestPos = ent.GetOrigin() + < 0, 0, airHeight >
								hasAirSpace = ArmoredLeap_HasValidHullRoom( ent, airLeapTestPos )

								TraceResults diveKickTrace = TraceHull( eyePos, airLeapTestPos,  mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, up, ent )

								if( diveKickTrace.fraction < 1 || !hasAirSpace)
								{
									//DebugDrawSphere( superDashTrace.endPos, 25, COLOR_MAGENTA, true, 0.1, 8 )
									info.failCase = eFailCase.BLOCKED_LEAP
									return false
								}
							}
							//DebugDrawSphere( dashHighTrace.endPos, 25, COLOR_YELLOW, true, 0.1, 8 )
						}

						//TraceResults dashHighToGroundTrace = TraceLine( airLeapTestPos, adjustedEndPos, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_ABILITY
						//TraceResults dashHighToGroundTrace = TraceHull( airLeapTestPos, adjustedEndPos, mins, maxs, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_ABILITY
						TraceResults dashHighToGroundTrace = TraceHull( adjustedEndPos, airLeapTestPos, ent.GetPlayerMins(), ent.GetPlayerMaxs(), ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
						if ( dashHighToGroundTrace.fraction < 0.98 ) //1.0 )
						{
							info.failCase = eFailCase.BLOCKED_LANDING
							return false
						}
						else
						{
							info.airPos = ( airLeapTestPos )
							return hasValidAirPosition
						}
					}

					info.failCase = eFailCase.BLOCKED_LEAP
					return false
				}

			}

			airLeapPos = dropLeapPos
		}

	}
	info.airPos = ( airLeapPos )


	return hasValidAirPosition
}

bool function ArmoredLeap_IsValidPosition( entity player, vector position, entity traceHitEnt ) // vector eyeDir, vector normal )
{
	if ( IsValid( traceHitEnt ) )
	{
		if ( traceHitEnt.IsPlayer() || traceHitEnt.IsNPC() || IsDeathboxFlyer( traceHitEnt ) )
			return false

		if ( traceHitEnt.GetScriptName() == CRYPTO_DRONE_SCRIPTNAME  )
			return false

		if ( traceHitEnt.IsProjectile() )
			return false

		entity pusher = GetPusherEnt( traceHitEnt )
		if ( pusher )
		{
			if ( ! file.allowEndOnMovers )
				return false

		}
	}

	array<string> triggersToCheck =
		[
			"trigger_slip",
			"trigger_out_of_bounds",
			"trigger_no_object_placement",
			"trigger_no_zipline",
			"trigger_no_grapple",
			"trigger_networked_out_of_bounds",
			"trigger_networked_no_op",
			"trigger_networked_block_all_op"
		]

	return true
}

bool function ArmoredLeap_IsInDashRange( entity player, vector endPoint, entity hitEnt )
{
	if( !IsValid(player) )
		return false

	entity pusher = GetPusherEnt( hitEnt )
	float dist = Distance2D( player.EyePosition(), endPoint )
	float distZ = fabs( player.GetOrigin().z - endPoint.z )
	array<entity> ignoreArray = ArmoredLeapIgnoreArray()
	TraceResults visionTrace = TraceLine( player.EyePosition(), endPoint + <0,0,5>, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

	if( dist <= ARMORED_LEAP_GROUND_DASH_RANGE && visionTrace.fraction == 1 && distZ < ARMORED_LEAP_GROUND_DASH_HEIGHT_LIMIT && player.IsOnGround() )
	{
		TraceResults dashBackTrace = TraceHull( endPoint + <0,0,16>, player.EyePosition(), ARMORED_LEAP_COL_MINS, ARMORED_LEAP_COL_MAXS, ignoreArray, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if ( dashBackTrace.fraction < 0.98 ) //1.0 )
		{
			return false
		}
		return true
	}

	return false
}

bool function ArmoredLeap_CanUseZipline( entity player, entity zipline, vector ziplineClosestPoint )
{
	if( !(player in file.isTargetPlacementActive) )
		return true

	if ( file.isTargetPlacementActive[player] )
		return false

	return true
}



///////////////////////////////////////
///// AUTO-ALLY TARGET SELECTION //////
//////////////////////////////////////

entity function GetAllyTargetInRange( entity owner )
{
	entity hitEnt = null
	entity allyEnt = null
	float distToTarget = 0.0
	float lastBestDotRange = 0.0
	bool canTargetAllyDeathbox = true

	array<entity> allyArray = GetAllyPlayerArray(owner) //GetPlayerArray_Alive()
	array<entity> allyInRangeArray

	//Determine Allies ( Friendly Teams or Alliances )
	foreach ( entity player in allyArray )
	{
		float distToAlly = Distance2D( owner.GetOrigin(), player.GetOrigin() )
		if ( distToAlly > GetArmoredLeapAllyDistance( owner ) ) //ARMORED_LEAP_MAX_ALLY_RANGE )
			continue

		allyInRangeArray.append( player )

	}

	if( canTargetAllyDeathbox )
	{
		array<entity> deathboxArray = GetAllDeathBoxes()
		foreach( deathbox in deathboxArray)
		{
			if( !IsValid( deathbox ) )
				continue
			if( !ShouldPickupDNAFromDeathBox( deathbox, owner  ) )
				continue
			float distToBox = Distance2D( owner.GetOrigin(), deathbox.GetOrigin() )
			if ( distToBox > GetArmoredLeapAllyDistance( owner ) ) // ARMORED_LEAP_MAX_ALLY_RANGE )
				continue

			allyInRangeArray.append(deathbox)
		}
	}

	//Determine Target Ally
	foreach ( entity ally in allyInRangeArray )
	{
		if ( !IsValid( ally ) )
		{
			continue
		}
		//bool hasLOS = false
		vector allyEyePos = ally.GetOrigin() + <0,0,ARMORED_LEAP_HUMAN_HEIGHT_OFFSET> // Can't use "center" on client / Crypto's EyePosition moves to Drone.
		vector playerEyePos = owner.EyePosition()
		vector playerEyeDir = AnglesToForward( owner.EyeAngles() )

		vector dir = Normalize(playerEyeDir)
		vector dirToTarget = Normalize( allyEyePos - playerEyePos )

		//TraceResults results = TraceLine( playerEyePos, allyEyePos, [owner], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		//hasLOS = results.fraction > 0.95

		float dotRangeToTarget = DotProduct( dir, dirToTarget )

		if( dotRangeToTarget > ARMORED_LEAP_DOT_TO_ALLY_TARGET )
		{
			if( dotRangeToTarget > lastBestDotRange )
			{
				allyEnt = ally
				lastBestDotRange = dotRangeToTarget
			}
		}

	}

	return allyEnt
}

array<entity> function GetAllyPlayerArray( entity owner )
{
	int team = owner.GetTeam()
	int alliance

	if ( AllianceProximity_IsUsingAlliances()  )
	{
		alliance = AllianceProximity_GetAllianceFromTeam( team )
	}

	array<entity> playerArray = GetPlayerArray_Alive()
	array<entity> validAllyArray

	//Determine Allies ( Friendly Teams or Alliances )
	foreach ( entity player in playerArray )
	{
		if ( player == owner )
			continue

		if ( player.IsPhaseShifted() )
			continue

		if( player.Player_IsSkywardFollowing() ) //Skyward Ally followers have a blocker volume. Ignore - players can only target Valk herself and land under
			continue

		int playerTeam = player.GetTeam()
		if( !IsFriendlyTeam( team, playerTeam ) )
			continue

		if ( AllianceProximity_IsUsingAlliances()  )
		{
			if ( !IsTeamInAlliance( playerTeam, alliance ) )
				continue
		}

		validAllyArray.append( player )
	}

	return validAllyArray
}


////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////                CASTLE WALL              ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
#if SERVER
void function CastleWall_CastleManager_Thread( entity player, entity castle )
{
	EndSignal( castle, "OnDestroy" )
	EndSignal( castle, "CastleWall_CastleDestroyed" )

	#if DEV
		if( DEBUG_DEV_TEST_FLAG )
		{
			if( player.IsBot() ) //Allow Bot_Record to loop and not make endless walls until cap explodes
				EndSignal( player, "OnDestroy" )
		}
	#endif
	////////////////////////////////////////

	file.castleEntArray[castle] <- []
	file.castleSnakeTailsL[castle] <- []
	file.castleSnakeTailsR[castle] <- []

	if( !( player in file.playerCastleArrays ) )
	{
		file.playerCastles[player] <- []
	}

	if( !( player in file.playerCastleArrays ) )
	{
		file.playerCastleArrays[player] <- []
	}

	file.playerCastles[player].append(castle)
	file.playerCastleArrays[player].append( file.castleEntArray[castle] )

	int arraySize = file.playerCastleArrays[player].len()

	if( arraySize > CASTLE_WALL_MAX_NUM_CASTLES )
	{
		array<entity> oldCastleArray = file.playerCastleArrays[player][0]
		foreach( pCastle in file.playerCastles[player] )
		{
			if( !(pCastle in file.castleEntArray) )
				continue

			array<entity> storedCastleArray = file.castleEntArray[pCastle]
			if( oldCastleArray == storedCastleArray)
			{
				Signal(pCastle, "CastleWall_CastleDestroyed")
				break
			}
		}


	}

	OnThreadEnd(
		function() : ( castle, player )
		{
			if( IsValid(castle) )
			{
				if( player in file.playerCastleArrays )
				{
					file.playerCastleArrays[player].removebyvalue(file.castleEntArray[castle])
				}

				if( player in file.playerCastles )
				{
					file.playerCastles[player].fastremovebyvalue(castle)
				}

				if( IsValid( file.castleSnakeTailsL[castle] ) )
				{
					delete file.castleSnakeTailsL[castle]
				}
				if( IsValid( file.castleSnakeTailsR[castle] ) )
				{
					delete file.castleSnakeTailsR[castle]
				}

				if( IsValid( file.castleEntArray[castle] ) )
				{
					//Clear out and Destroy Walls
					foreach( wall in file.castleEntArray[castle] )
					{
						if ( wall in file.endWallDeployed )
							delete file.endWallDeployed[wall]

						if( IsValid( wall ) )
							wall.Destroy()
					}

					delete file.castleEntArray[castle]

					//Destroy the Castle
					castle.Destroy()
				}
			}
		}
	)

	WaitForever()
}
#endif
////////////////////SNAKE CASTLE///////////////////////////
#if SERVER
void function CastleWall_CreateCastle( entity player )
{
	if ( !IsAlive( player ) )
		return

	//Forward Castle Wall //
	entity castle = CreateInfoTarget( player.GetOrigin(), player.GetAngles() ) //Need someone to be in charge of the shield in case the player dies.
	castle.SetOwner( player )
	SetTeam( castle, player.GetTeam() )
	castle.RemoveFromAllRealms()
	castle.AddToOtherEntitysRealms( player )
	FiringRange_AddToRemoveOnCharacterChange( castle, player )

	MarkEntForCleanupOnRoundEnd( castle )

	thread CastleWall_CastleManager_Thread( player, castle )

	vector fwd = Normalize( FlattenVec( player.GetViewVector() ) )
	vector right = VectorRotate( fwd, <0, -90, 0> ) //Normalize( FlattenVec( player.GetRightVector() ) )

	//Default Position to Plant the Shield
	vector originPos = player.GetOrigin() + fwd *CASTLE_WALL_SPAWN_OFFSET

	array<entity> ignoreArray 	= ArmoredLeapIgnoreArray(castle, true) //For placement of the shield, we want to stomp through any other castles (we'll destroy them)

	//Drop a trace to find the desired Shield Origin on the ground surface
	TraceResults originTrace = TraceLine( originPos + < 0.0, 0.0, CASTLE_WALL_SPAWN_GROUND_CHECK_DIST >, originPos, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if ( originTrace.fraction < 1.0 )
		originPos = originTrace.endPos

	//Cliff Test//
	//If desired Shield Position is over an edge, try to walk it back to find the ledge or min forward position.
	TraceResults downTrace = TraceLine( originPos, originPos + < 0.0, 0.0, -CASTLE_WALL_SPAWN_GROUND_CHECK_DIST >, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if ( downTrace.fraction == 1.0 ) //Found NOTHING ahead and down! Uh oh! A CLIFF!
	{

		float fOffset = CASTLE_WALL_SPAWN_OFFSET - CASTLE_WALL_SPAWN_OFFSET_STEP

		for (int i=0; i<3; i++)
		{
			originPos = player.GetOrigin() + fwd * fOffset

			TraceResults downStepTrace = TraceLine( originPos, originPos + < 0.0, 0.0, -CASTLE_WALL_SPAWN_GROUND_CHECK_DIST >, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			if ( downStepTrace.fraction != 1.0 )
				break

			fOffset = fOffset - CASTLE_WALL_SPAWN_OFFSET_STEP
		}
	}
	else
		originPos = downTrace.endPos

	//Collision Test
	//If desired Shield position is inside an object - reel it back to the Player's Position to prevent it from getting stuck in something
	vector offsetOrigin = player.GetOrigin() + <0,0,5>
	TraceResults forwardUpTrace = TraceLine( offsetOrigin, originPos + <0,0,CASTLE_WALL_SPAWN_UPTRACE_OFFSET>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if ( forwardUpTrace.fraction != 1.0 ) //Test for Blockage between Player and Castle
	{
		originPos = forwardUpTrace.endPos + fwd * (-CASTLE_WALL_SHIELD_THICKNESS)

		TraceResults downFwdTrace = TraceLine( originPos, originPos + <0,0,-100>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //look down from origin pos to find ground
		if ( downFwdTrace.fraction != 1.0 ) //Test for Ground at Castle Position
		{
			originPos = downFwdTrace.endPos + fwd * (-CASTLE_WALL_SHIELD_THICKNESS) //Back the Shield out of the wall.
		}
	}

	//Create One Thread that manages the core shield raise
	thread CastleWall_CreateMainWall_Thread( player, castle, fwd, originPos )

}
#endif

#if SERVER
void function CastleWall_CreateMainWall_Thread( entity player, entity castle, vector dir, vector originPos )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	if( !IsValid( castle ) )
		return

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	ItemFlavor skin      = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterSkin( character ) )
	string characterSkinName = CharacterSkin_GetSkinName( skin )
	int characterCamo = CharacterSkin_GetCamoIndex( skin )

	//////CREATE SHIELD//////////
	entity shieldAnchor = CreateCastlePhysicalShield( null, castle, originPos, dir, CASTLE_WALL_SHIELD_WALL_CENTRE_MDL, <0,0,0>, eSegmentType.HIGH, eAnchorType.CENTER )
	//AbilityCosmetics_Apply( shieldAnchor, characterSkinName, characterCamo )

	int bodyGroupIndexCenter = shieldAnchor.FindBodygroup( "CENTER" )
	shieldAnchor.SetBodygroupModelByIndex( bodyGroupIndexCenter, 1 )

	file.castleEntArray[castle].append(shieldAnchor)

	EndSignal( shieldAnchor, "OnDestroy" )
	EndSignal( shieldAnchor, "CastleWall_PickedUp" )

	EmitSoundOnEntity( shieldAnchor, CASTLE_WALL_PLACED_SFX_3P )
	EmitSoundOnEntity( shieldAnchor, CASLTE_WALL_LANDS_ON_GROUND )

	OnThreadEnd(
		function() : ( shieldAnchor, castle )
		{
			if( IsValid( shieldAnchor ) )
			{
				CastleWall_CheckForStickyEnt(shieldAnchor)
			}
		}
	)


	if( !IsValid( castle ) )
		return

	////////// RAISE UP ANIMATION //////////////////
	if( IsValid(castle) ) // Extend the peice upwards
	{
		shieldAnchor.Anim_PlayOnly( "shieldwall_expand_C" )

		////////////// CASTLE SNAKE CREATION ////////////////////

		//Create LEFT Snake
		vector sideDir = RotateVector(dir, <0,90,0> )
		//DebugDrawLine( castle.GetOrigin(), castle.GetOrigin() + (sideDir) * 45, COLOR_GREEN, true, 20 )
		thread CastleWall_CreateSnakeWall_Thread( player, castle, dir, originPos, sideDir, true, characterSkinName, characterCamo )

		//Create RIGHT Snake
		sideDir = RotateVector(dir, <0,-90,0> )
		//DebugDrawLine( castle.GetOrigin(), castle.GetOrigin() + (sideDir) * 45, COLOR_GREEN, true, 20 )
		thread CastleWall_CreateSnakeWall_Thread( player, castle, dir, originPos, sideDir, false, characterSkinName, characterCamo )
	}

	wait file.barrierDelay

	if( !(IsValid(shieldAnchor) ) )
		return

	////////////////// TRIGGER REGION & BARRIER VFX ////////////////////
	thread CastleWall_CreateElectricBarriers( castle )
	                    
		if ( file.hasWallStopsGrenades )
		{
			thread CastleWall_InterceptProjectiles( player, castle, shieldAnchor )
		}
       

}
#endif


#if SERVER
void function CastleWall_CreateSnakeWall_Thread( entity player, entity castle, vector dir, vector originPos, vector sideDir, bool isLeft, string characterSkinName, int characterCamo )
{
	EndSignal( castle, "OnDestroy" )
	entity owner = castle

	if( !IsValid( castle ) )
		return

	bool saveEnts = GetArmoredLeapUseReducedEntCount()
	//////////// TEST FOR CREATION /////////////
	array<entity> ignoreArray 	= ArmoredLeapIgnoreArray(castle, true, true)

	//Determine Valid Room to Begin Snake//
	vector originOffsetPos = originPos + <0,0,32>
	vector minRangeTestPos = originOffsetPos + sideDir * CASTLE_SNAKE_MIN_ALLOWED_SNAKE_DEPLOYMENT_RANGE
	TraceResults minRangeTrace = TraceLine( originOffsetPos, minRangeTestPos , ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

	if ( minRangeTrace.fraction < 1.0 )
	{
		if ( DotProduct( minRangeTrace.surfaceNormal, <0, 0, 1> ) < 0.80 )
			return //No room. Do not deploy the snake.
	}
	///////////////////////////////////////////

	////////// SNAKE HEAD CREATION////////////
	//Create the Mover for the SnakeHead
	entity mover = CreateScriptMover( CASTLE_WALL_SNAKEHEAD_SCRIPTNAME, originPos, VectorToAngles( dir ), SOLID_VPHYSICS )
	mover.SetOwner( owner )
	mover.RemoveFromAllRealms()
	mover.AddToOtherEntitysRealms( owner )

	entity playerOwner = castle.GetOwner()
	if( IsValidPlayer( playerOwner ) )
	{
		FiringRange_AddToRemoveOnCharacterChange( mover, playerOwner )
	}

	EndSignal( mover, "OnDestroy" )

	int anchorType 	= isLeft ? eAnchorType.LEFT : eAnchorType.RIGHT
	asset mdl 		= isLeft ? CASTLE_WALL_SHIELD_WALL_ENDS_LOW_COL_L_MDL : CASTLE_WALL_SHIELD_WALL_ENDS_LOW_COL_R_MDL

	//Create the Core Shield "Anchor"// This shield will move across the ground pooping out wall segments.
	entity shieldAnchor = CreateCastlePhysicalShield( mover, owner, mover.GetOrigin(), dir, mdl, <0,0,0>, eSegmentType.HIGH, anchorType )
	//AbilityCosmetics_Apply( shieldAnchor, characterSkinName, characterCamo )
	file.castleEntArray[castle].append(shieldAnchor)

	EndSignal( shieldAnchor, "OnDestroy" )
	EndSignal( shieldAnchor, "CastleWall_PickedUp" )


	OnThreadEnd(
		function() : ( mover, shieldAnchor )
		{
			if( IsValid( shieldAnchor ) )
			{
				shieldAnchor.ClearParent()
				CastleWall_CheckForStickyEnt(shieldAnchor)
			}

			if( IsValid( mover ) )
			{
				mover.Destroy()
			}

			if ( mover in file.lastSnakePanelPos )
			{
				delete file.lastSnakePanelPos[mover]
			}
		}
	)

	/////// SNAKE HEAD SETUP /////////

	//Snake Info - Store information about the snake for reference
	ArmoredLeapSnakeInfo snakeInfo
	snakeInfo.mover = mover
	snakeInfo.moverDir = sideDir
	snakeInfo.shieldDir = dir
	snakeInfo.wallLength = 0.0
	snakeInfo.isLeft = isLeft

	//INTRO MOVEMENT// Move the Snake to the Edge of the Wall//
	float CASTLE_SNAKE_INIT_SNAKE_DIST = saveEnts ? CASTLE_ANCHOR_SIDE_OFFSET_DEPLOYED : CASTLE_ANCHOR_SIDE_OFFSET_UNDEPLOYED //18.0
	vector initPos =  mover.GetOrigin() + snakeInfo.moverDir * CASTLE_SNAKE_INIT_SNAKE_DIST

	ignoreArray 	= ArmoredLeapIgnoreArray(castle, true, true)
	TraceResults initTraceResult = TraceLine( initPos + <0,0,CASTLE_SNAKE_CLIMB_HEIGHT>, initPos + <0,0,-CASTLE_SNAKE_DROP_TEST_HEIGHT>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //64
	if ( initTraceResult.fraction < 1.0 )
	{
		initPos = initTraceResult.endPos
	}
	else
	{
		//we start far off if "saving ents" but if that trace down fails, lets move it back in so we don't end up floating in the air. - Still minor issues here - TNordin.
		if ( saveEnts )
		{
			vector additionalTracePos = mover.GetOrigin() + snakeInfo.moverDir * ( CASTLE_ANCHOR_SIDE_OFFSET_DEPLOYED + CASTLE_ANCHOR_SIDE_OFFSET_UNDEPLOYED )

			//DebugDrawArrow( additionalTracePos + <0,0,64>, additionalTracePos + <0,0,-64>, 8, COLOR_YELLOW, true, 15.0 )

			TraceResults additionalTrace = TraceLine( additionalTracePos + <0,0,CASTLE_SNAKE_CLIMB_HEIGHT>, additionalTracePos + <0,0,-CASTLE_SNAKE_DROP_TEST_HEIGHT>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			if ( additionalTrace.fraction == 1.0 )
			{
				initPos =  mover.GetOrigin() + snakeInfo.moverDir * 18.0
			}
		}
	}

	//DebugDrawArrow( initPos + <0,0,64>, initPos + <0,0,-64>, 10, COLOR_RED, true, 15.0 )
	// DebugDrawArrow( mover.GetOrigin(), initPos, 8, COLOR_GREEN, true, 15.0 )

	//we start on the side of the main anchor, so need to start rotating off the bat.
	if ( saveEnts )
	{
		float moverRotAngle = isLeft ? CASTLE_SNAKE_GRADUAL_ANGLE_SHIFT : -CASTLE_SNAKE_GRADUAL_ANGLE_SHIFT

		snakeInfo.moverDir = RotateVector( <snakeInfo.moverDir.x,snakeInfo.moverDir.y,0> , <0,moverRotAngle,0> )
	}

	mover.NonPhysicsMoveTo( initPos, 0.2, 0.0, 0.0 )

	float initDist = Distance2D( mover.GetOrigin(), initPos )
	while( initDist > 0 )
	{
		if( !IsValid( mover ) )
			return
		//Let the snake reach the edge of the shield before beginning to follow ground.
		initDist = Distance2D( mover.GetOrigin(), initPos )
		WaitFrame()
	}

	if( !IsValid( castle ) )
		return
	if( !IsValid( mover ) )
		return

	/////// SNAKE HEAD INITIAL DESTINATION //////
	ignoreArray 	= ArmoredLeapIgnoreArray(castle, true, true)
	vector destination = SnakeWall_GetNextValidPos( mover, mover.GetOrigin(), ignoreArray, snakeInfo )

	if( snakeInfo.stopped )
	{
		//If the initial snake head cannot move, we prevent it from entering movement
		//This FAIL POSITION is corrected to let it stick out of the central shield wall properly
		vector failPos =  mover.GetOrigin() + snakeInfo.moverDir * CASTLE_ANCHOR_SIDE_OFFSET_UNDEPLOYED
		mover.NonPhysicsMoveTo( failPos, 0.2, 0.0, 0.0 )
		if( isLeft )
			shieldAnchor.Anim_PlayOnly( "shieldwall_travel_L" )
		else
			shieldAnchor.Anim_PlayOnly( "shieldwall_travel_R" )

		file.endWallDeployed[shieldAnchor] <- false

		wait 1
		return
	}

	float CASTLE_SNAKE_MAX_NUM_SEGMENTS						= 6
	float CASTLE_SNAKE_MAX_WALL_LENGTH						= CASTLE_SNAKE_MIN_SEGMENT_DISTANCE * CASTLE_SNAKE_MAX_NUM_SEGMENTS //168

	if ( saveEnts )
	{
		CASTLE_SNAKE_MAX_NUM_SEGMENTS						= 4
		CASTLE_SNAKE_MAX_WALL_LENGTH 						= CASTLE_SNAKE_MIN_SEGMENT_DISTANCE * CASTLE_SNAKE_MAX_NUM_SEGMENTS //168
		file.lastSnakePanelPos[mover] <- ZERO_VECTOR
	}


	////// SNAKE TAIL DEPLOYMENT /////
	thread CastleWall_TrackAndDeploy_SnakeWallPanels_Thread( castle, mover, snakeInfo, isLeft, characterSkinName, characterCamo )
	/////////////////////////////////


	/////// SNAKE HEAD MOVEMENT //////
	bool hasOpened = false
	float prevWallLength = 0
	float endTime = Time() + CASTLE_SNAKE_MAX_TRAVEL_TIME

	while( snakeInfo.wallLength < CASTLE_SNAKE_MAX_WALL_LENGTH  && IsValid(mover) && Time() < endTime )
	{
		if( !IsValid( castle ) )
			return
		if( !IsValid( mover ) )
			return
		if( !IsValid( shieldAnchor ) )
			return

		if( snakeInfo.wallLength - prevWallLength > CASTLE_SNAKE_MIN_SNAKE_KICKUP_DIST )
		{
			PlayImpactFXTable( mover.GetOrigin(), mover, CASTLE_WALL_SNAKE_IMPACT_FX_TABLE )
			prevWallLength = snakeInfo.wallLength
		}

		//SnakeAnimation - Opening//
		float minOpeningDistance = CASTLE_SNAKE_MIN_SEGMENT_DISTANCE - 3
		if( snakeInfo.wallLength > minOpeningDistance && !hasOpened )
		{

			if( isLeft )
				shieldAnchor.Anim_PlayOnly( "shieldwall_travel_L" )
			else
				shieldAnchor.Anim_PlayOnly( "shieldwall_travel_R" )

			hasOpened = true
		}


		///////DESTINATION////////
		float travelTime = 0.4
		float updateTime = 0.01
		ignoreArray 	= ArmoredLeapIgnoreArray(castle, true, true)

		if( snakeInfo.drop == true )
		{
			//We have moved over the edge. Now we need to drop to the stored DropPos
			destination = snakeInfo.dropPos
			travelTime = 0.3 //Should we physics this somehow instead?
			updateTime = 1 //Ensure we reach the Drop Point
			snakeInfo.drop = false
		}
		else
		{
			destination = SnakeWall_GetNextValidPos( mover, mover.GetOrigin(), ignoreArray, snakeInfo )
		}

		#if DEV
		if( DEBUG_SNAKE_DRAW )
		{
			DebugDrawSphere( mover.GetOrigin(), 3, COLOR_YELLOW, true, 0.2 )
			DebugDrawSphere( destination, 5, COLOR_YELLOW, true, 1 )
		}
		#endif


		/////// MOVEMENT ////////

		//STOP SNAKE
		//Prevent Snake from curling back on itself
		if ( DotProduct(snakeInfo.moverDir, sideDir) < 0 )
			snakeInfo.stopped = true

		if( snakeInfo.stopped )
		{
			mover.NonPhysicsMoveTo( mover.GetOrigin(), 0.2, 0.0, 0.0 )
			break
		}

		//MOVE SNAKE
		mover.NonPhysicsMoveTo( destination, travelTime, 0.0, 0.0 )

		//ROTATE SNAKE - Follows Surface as it moves
		vector up = AnglesToUp( mover.GetAngles() )
		float rot = 90
		if(isLeft)
			rot = -90
		dir = RotateVector( snakeInfo.moverDir, <0,rot,0> )
		vector angles = VectorToAngles( <dir.x,dir.y, 0 > )
		vector traceStart = mover.GetOrigin() + (up*16)
		vector traceEnd = mover.GetOrigin() - <0,0,50>
		vector surfaceAngles = angles

		TraceResults traceResult = TraceLine( traceStart, traceEnd, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )
		if ( traceResult.fraction < 1.0 )
		{
			vector moverDir = RotateVector( snakeInfo.moverDir, <0,rot,0> ) //mover.GetForwardVector()
			if ( DotProduct( moverDir, dir ) > 0 )
			{
				surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, dir )
			}
			else
			{
				surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, <-dir.x, -dir.y, dir.z> )
			}

			vector newUpDir = AnglesToUp( surfaceAngles )
			if ( fabs(DotProduct( newUpDir, up )) < 0.25 ) //AXIOM_REVIVE_SLOPE_ANGLE_LIMIT (0.35)
				surfaceAngles = angles
		}

		snakeInfo.surfaceAngle = surfaceAngles
		mover.NonPhysicsRotateTo( surfaceAngles, 0.3, 0.05, 0.05 ) //AXIOM_REVIVE_ROTATE_TRAVEL_TIME (0.3)



		//UPDATE CHECK
		//We hold the thread momentarily to allow the snake to travel. For drops, we hold longer to ensure it reaches its destination before a new movement update
		//Basically a variable "waitframe"
		if(snakeInfo.drop) //Ensure we reach actual Destination Step - Used for the Pre-Drop Hover
			updateTime = 1

		float checkDist = 25
		waitthread SnakeWall_MoveSnakeHeadToUpdatePos_Thread( mover, updateTime, destination, checkDist ) //may not need this if the loop is short enough

	}

	if( !IsValid( castle ) )
		return
	if( !IsValid( mover ) )
		return
	if( !IsValid( shieldAnchor ) )
		return

	///////SNAKE HEAD END ROTATION///////////
	///Hook High Cover inward//
	const float CASTLE_SNAKE_HIGH_COVER_FINAL_ROTATION_TIME = 0.3

	float rot = 90 - CASTLE_SNAKE_HIGH_COVER_FINAL_ANGLE_SHIFT
	if(isLeft)
		rot = -90 + CASTLE_SNAKE_HIGH_COVER_FINAL_ANGLE_SHIFT
	dir = RotateVector( snakeInfo.moverDir, <0,rot,0> )
	vector angles = VectorToAngles( <dir.x,dir.y, 0 > )
	mover.NonPhysicsRotateTo( angles, CASTLE_SNAKE_HIGH_COVER_FINAL_ROTATION_TIME, 0.05, 0.05 )

	wait CASTLE_SNAKE_HIGH_COVER_FINAL_ROTATION_TIME


	//////// SNAKE END - HIGH COVER DEPLOYMENT /////////
	if( !IsValid( castle ) )
		return
	if( !IsValid( mover ) )
		return
	if( !IsValid( shieldAnchor ) )
		return

	//Check for ROOM to deploy HIGH COVER
	bool canDeployHighCover = true

	if( snakeInfo.wallLength < CASTLE_SNAKE_MIN_HIGH_COVER_WALL_LENGTH )
		canDeployHighCover = false

	ignoreArray 	= ArmoredLeapIgnoreArray(castle, true)

	float hullWidth = 5
	float hullDepth = 5
	float hullHeight = 60
	vector startPos = mover.GetOrigin() + <0,0,32>
	vector endPos = (mover.GetOrigin() + <0,0,32>) + snakeInfo.moverDir * CASTLE_ANCHOR_SIDE_OFFSET_DEPLOYED

	//DebugDrawBox( startPos, <-hullWidth,-hullDepth,0>, <hullWidth,hullDepth,hullHeight>, COLOR_GREEN, 1, 10.0 )
	//DebugDrawBox( endPos, <-hullWidth,-hullDepth,0>, <hullWidth,hullDepth,hullHeight>, <0, 128, 0>, 1, 10.0 )
	TraceResults wallTrace = TraceHull( startPos, endPos, <-hullWidth, -hullDepth, 0>, <hullWidth, hullDepth, hullHeight>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if( wallTrace.fraction < 1 )
		canDeployHighCover = false

	if ( saveEnts )
	{
		vector anchorEdgeToOrigin

		float offset = canDeployHighCover ? CASTLE_ANCHOR_SIDE_OFFSET_DEPLOYED : CASTLE_ANCHOR_SIDE_OFFSET_UNDEPLOYED

		//move the final anchors to line up with the last shieldEnt edge.
		if ( isLeft )
		{
			anchorEdgeToOrigin = ( mover.GetOrigin() + ( mover.GetRightVector() * offset ) ) - file.lastSnakePanelPos[mover]
		}
		else
		{
			anchorEdgeToOrigin = ( mover.GetOrigin() + ( -mover.GetRightVector() * offset ) ) - file.lastSnakePanelPos[mover]
		}
		CastleWall_CheckForCastleOverlapAndCleanup( castle, shieldAnchor, CASTLE_WALL_OVERLAP_CLEANUP_RADIUS_SEGMENT )

		vector anchorEdgeNewPos = mover.GetOrigin() - anchorEdgeToOrigin
		TraceResults anchorEdgeDownTrace = TraceLine( anchorEdgeNewPos + <0,0,CASTLE_SNAKE_CLIMB_HEIGHT*2>, anchorEdgeNewPos + <0,0,-CASTLE_SNAKE_DROP_TEST_HEIGHT>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )  //64
		if( anchorEdgeDownTrace.fraction < 1 )
			anchorEdgeNewPos = anchorEdgeDownTrace.endPos

		mover.NonPhysicsMoveTo( anchorEdgeNewPos, CASTLE_SNAKE_HIGH_COVER_FINAL_ROTATION_TIME, 0.05, 0.05 )

		wait CASTLE_SNAKE_HIGH_COVER_FINAL_ROTATION_TIME
	}

	file.endWallDeployed[shieldAnchor] <- canDeployHighCover

	if(!canDeployHighCover)
		return

	thread CastleWall_CreateEndWall( castle, mover, shieldAnchor, dir, anchorType, isLeft, characterSkinName, characterCamo )

	wait CASTLE_SNAKE_WALL_HIGH_COVER_EXTENSION_TIME

}
#endif //SERVER

#if SERVER
void function CastleWall_CreateEndWall( entity castle, entity mover, entity shieldAnchor, vector dir, int anchorType, bool isLeft, string characterSkinName, int characterCamo )
{
	if( !IsValid( castle ) || !IsValid(mover) ||!IsValid( shieldAnchor ) )
		return

	//Create replacement Shield Anchor End and assign previous anchor Health
	asset mdl = isLeft ? CASTLE_WALL_SHIELD_WALL_ENDS_L_MDL : CASTLE_WALL_SHIELD_WALL_ENDS_R_MDL
	entity endWall = CreateCastlePhysicalShield( mover, castle, mover.GetOrigin(), dir, mdl, <0,0,0>, eSegmentType.HIGH, anchorType )
	//AbilityCosmetics_Apply( endWall, characterSkinName, characterCamo  )


	int bodyGroupIndex = isLeft ? endWall.FindBodygroup( "LEFT" ) : endWall.FindBodygroup( "RIGHT" )
	endWall.SetBodygroupModelByIndex( bodyGroupIndex, 1 )

	file.castleEntArray[castle].append(endWall)
	endWall.SetHealth( shieldAnchor.GetHealth() )

	endWall.ClearParent()
	CastleWall_CheckForStickyEnt(endWall)

	EndSignal( endWall, "OnDestroy" )
	EndSignal( endWall, "CastleWall_PickedUp" )

	OnThreadEnd(
		function() : ( endWall )
		{
			if( IsValid( endWall ) )
			{
			}
		}
	)

	//Cleanup and Destroy previous Shield Anchor
	if( castle in file.castleEntArray )
	{
		if( file.castleEntArray[castle].contains(shieldAnchor) )
		{
			file.castleEntArray[castle].fastremovebyvalue(shieldAnchor)
		}
	}
	shieldAnchor.Destroy()

	//SnakeAnimation - Opening High Cover
	if( isLeft )
		endWall.Anim_PlayOnly( "shieldwall_expand_L" )
	else
		endWall.Anim_PlayOnly( "shieldwall_expand_R" )

	CastleWall_CheckForCastleOverlapAndCleanup( castle, endWall, CASTLE_WALL_OVERLAP_CLEANUP_RADIUS_SEGMENT )
	wait CASTLE_SNAKE_WALL_HIGH_COVER_EXTENSION_TIME //todo: Determine proper barrier deployment time.

}
#endif

#if SERVER
void function CastleWall_TrackAndDeploy_SnakeWallPanels_Thread( entity castle, entity mover, ArmoredLeapSnakeInfo snakeInfo, bool isLeft, string characterSkinName, int characterCamo )
{
	EndSignal( mover, "OnDestroy" )
	EndSignal( castle, "CastleWall_CastleDestroyed" )

	array<entity> snakeSegments
	entity prevSeg = mover

	int lastSnakeNum = 0
	vector lastKnownPos = mover.GetOrigin()
	vector lastSegPos = mover.GetOrigin()

	float CASTLE_SNAKE_MAX_NUM_SEGMENTS						= 6
	float CASTLE_SNAKE_MAX_WALL_LENGTH						= CASTLE_SNAKE_MIN_SEGMENT_DISTANCE * CASTLE_SNAKE_MAX_NUM_SEGMENTS //168
	bool saveEnts = GetArmoredLeapUseReducedEntCount()

	if ( saveEnts )
	{
		CASTLE_SNAKE_MAX_NUM_SEGMENTS						= 4
		CASTLE_SNAKE_MAX_WALL_LENGTH 						= CASTLE_SNAKE_MIN_SEGMENT_DISTANCE * CASTLE_SNAKE_MAX_NUM_SEGMENTS //168
	}

	while( IsValid(mover) )
	{
		if( !IsValid( castle ) )
			break

		snakeInfo.wallLength = snakeInfo.wallLength + Distance( mover.GetOrigin(), lastKnownPos ) //Distance2D( destination, originPos )
		lastKnownPos = mover.GetOrigin()

		if( snakeInfo.stopped )
			break

		if( snakeInfo.wallLength < CASTLE_SNAKE_MAX_WALL_LENGTH + CASTLE_SNAKE_FINAL_SPACING_DISTANCE ) //Don't drop a piece through final wall - but need enough space to lead up to final wall location.//
		{
				vector dirToMover = snakeInfo.moverDir
				vector newSegPos = mover.GetOrigin() //+ snakeInfo.moverDir * 12
				//I need to create a point at the END of each PIECE that I can use to determine my direction.

			array<entity> ignoreArray 	= ArmoredLeapIgnoreArray(castle)

			//Check for the correct Height to deploy the wall at, using the lower of two test points
			vector centerPos = lastSegPos + snakeInfo.moverDir * CASTLE_SNAKE_MIN_SEGMENT_DISTANCE/2 //CASTLE_SNAKE_DROP_TEST_HEIGHT
			TraceResults downTrace = TraceLine( lastSegPos + <0,0,64> , lastSegPos + <0,0,-50>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_SHOT_HULL TRACE_MASK_SOLID
			TraceResults downSlopeTrace = TraceLine( centerPos + <0,0,64> , centerPos + <0,0,-50>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_SHOT_HULL TRACE_MASK_SOLID

			float zHeight = min( downTrace.endPos.z, downSlopeTrace.endPos.z )
			if( downTrace.fraction == 1 || downTrace.startSolid )
				zHeight = lastSegPos.z //if our pivot has no ground - use pivot location
			else if( downSlopeTrace.fraction == 1 || downTrace.startSolid )
				zHeight = downTrace.endPos.z //if our pivot has ground - but our slope finds nothing - use the down trace instead

				//Once we have a Snake Segment, we need to determine the next position using the last known snake position & segment size
				if( lastSnakeNum > 0 )
				{
					dirToMover = Normalize(mover.GetOrigin() - lastSegPos )
					newSegPos = <lastSegPos.x, lastSegPos.y, zHeight >
					prevSeg = snakeSegments.top()
				}
				else
					newSegPos = <newSegPos.x, newSegPos.y, zHeight>

				//Ensure that we've cleared the deployment distance and deploy a snake segment
				float distToLastSeg = Distance2D( mover.GetOrigin(), lastSegPos )
				if( distToLastSeg >= CASTLE_SNAKE_MIN_SEGMENT_DISTANCE - 5 || lastSnakeNum == 0 )
				{
					//Create the Segment
					entity wallSeg = CastleWall_CreateSnakeWallPanel( castle, snakeInfo.moverDir, newSegPos, VectorToAngles(mover.GetForwardVector()), isLeft, characterSkinName, characterCamo ) //castle, snakeInfo.moverDir, mover.GetOrigin(), snakeInfo.surfaceAngle, isLeft )

					snakeSegments.append( wallSeg )
					lastSegPos = wallSeg.GetOrigin() + snakeInfo.moverDir * CASTLE_SNAKE_MIN_SEGMENT_DISTANCE //wallSeg.GetOrigin()

					lastSnakeNum += 1

					//////NATURAL TURN////////
					float moverRotAngle = CASTLE_SNAKE_GRADUAL_ANGLE_SHIFT
					if(!isLeft)
						moverRotAngle = -CASTLE_SNAKE_GRADUAL_ANGLE_SHIFT

					snakeInfo.moverDir = RotateVector( <snakeInfo.moverDir.x,snakeInfo.moverDir.y,0> , <0,moverRotAngle,0> )

					//CheckForComplete//

				}
		}


		if( snakeInfo.wallLength > CASTLE_SNAKE_MAX_WALL_LENGTH - CASTLE_SNAKE_MIN_SEGMENT_DISTANCE )
			snakeInfo.stopped = true

		if ( saveEnts )
		{
			if ( mover in file.lastSnakePanelPos )
			{
				file.lastSnakePanelPos[mover] = lastSegPos
			}
		}

		WaitFrame()
	}
}
#endif


#if SERVER
entity function CastleWall_CreateSnakeWallPanel( entity castle, vector dir, vector pos, vector angles, bool isLeft, string characterSkinName, int characterCamo )
{
	entity owner = castle

	float rot = 90
	if ( isLeft )
		rot = -90
	dir = RotateVector( dir, <0, rot, 0> )

	angles = VectorToAngles( dir )

	//Create the Core Shield "Anchor"// This shield will move across the ground pooping out wall segments.
	entity shieldAnchor
	if ( isLeft )
	{
		shieldAnchor = CreateCastlePhysicalShield( null, owner, pos, dir, CASTLE_WALL_SHIELD_WALL_SEG_L_MDL, angles, eSegmentType.LOW_LEFT ) //, angles ) //Can be teseted with Surface angles
		file.castleSnakeTailsL[castle].append(shieldAnchor)
	}
	else
	{
		shieldAnchor = CreateCastlePhysicalShield( null, owner, pos, dir, CASTLE_WALL_SHIELD_WALL_SEG_R_MDL, angles, eSegmentType.LOW_RIGHT )
		file.castleSnakeTailsR[castle].append(shieldAnchor)
	}
	//AbilityCosmetics_Apply( shieldAnchor, characterSkinName, characterCamo )

	file.castleEntArray[castle].append(shieldAnchor)

	EmitSoundOnEntity( shieldAnchor, CASTLE_WALL_PLACED_SFX_3P )
	EmitSoundOnEntity( shieldAnchor, CASLTE_WALL_LANDS_ON_GROUND )

	CastleWall_CheckForStickyEnt(shieldAnchor)

	return shieldAnchor
}
#endif


#if SERVER
vector function SnakeWall_GetNextValidPos(entity mover, vector pos, array<entity> ignoreArray, ArmoredLeapSnakeInfo snakeInfo )
{
	vector nextValidPos = pos
	entity owner = mover.GetOwner()
	//array<entity> ignoreArray 	= ArmoredLeapIgnoreArray()

	vector dir = snakeInfo.moverDir
	dir = Normalize( FlattenVec( dir ) )

	pos = pos + <0,0,CASTLE_WALL_HIGH_WALL_PLANTED_Z_OFFSET> //used higher test position offset for path detection
	vector newPos = pos + dir * CASTLE_SNAKE_TEST_STEP

	vector traceStart = pos
	vector traceEndUnder = <newPos.x, newPos.y, traceStart.z >
	vector traceEndOver = <newPos.x, newPos.y, traceStart.z + CASTLE_SNAKE_CLIMB_HEIGHT>

	TraceResults forwardTrace = TraceLine( traceStart, traceEndUnder, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_SHOT_HULL TRACE_MASK_SOLID
	if ( forwardTrace.fraction == 1.0 && !forwardTrace.startSolid ) //Found NOTHING ahead!
	{
		//LOOK DOWN FOR CLIFFS & PLATFORMS
		nextValidPos = SnakeWall_GetBestDownTracePosition( nextValidPos, traceStart, forwardTrace.endPos, dir, ignoreArray, snakeInfo )
	}
	else // FOUND A WALL - Test for Step-Up
	{
		entity hitEnt = forwardTrace.hitEnt
		bool canMountEnt = SnakeWall_IsValidMountHitEnt( hitEnt )

		TraceResults upwardTrace = TraceLine( traceStart, traceEndOver, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
		if ( upwardTrace.fraction < 0.5 || !canMountEnt ) //Blocked. Obstacle ahead is not small enough for a step-up OR illegal climb obstacle
		{
			//We should STOP the SNAKE
			snakeInfo.stopped = true
		}
		else //Found a Step-Up. Ensure there is ground below.
		{
			//LOOK DOWN FOR CLIFFS AND PLATFORMS
			nextValidPos = SnakeWall_GetBestDownTracePosition( nextValidPos, traceStart, upwardTrace.endPos, dir, ignoreArray, snakeInfo )
		}
	}

	if( !snakeInfo.drop )
		snakeInfo.nextValidPos = nextValidPos

	float dist2D = Distance2D( nextValidPos, pos )
	if ( dist2D == 0 || nextValidPos == pos )
		snakeInfo.stopped = true

	return nextValidPos
}
#endif

bool function SnakeWall_IsValidMountHitEnt( entity hitEnt )
{
	//Castle Wall considers these objects invalid for mounting purposes due to awkward potential rotation results
	if( !IsValid( hitEnt ) )
		return false

	array<entity> lootBins = GetEntArrayByScriptName( LOOT_BIN_SCRIPTNAME ) //CAstle Anchor //GetAllLootBins()
	if( lootBins.contains(hitEnt) )
		return false

	if( hitEnt.GetNetworkedClassName() == "phys_bone_follower" )
		return false

	return true
}

vector function SnakeWall_GetBestDownTracePosition( vector nextValidPos, vector traceStart, vector tracePos, vector dir, array<entity> ignoreArray, ArmoredLeapSnakeInfo snakeInfo )
{
//todo: Fix this - We check ahead and down to see if we can drop off - BUT on success, we basically move through the ground to get there.
	//INSTEAD - we should Wile E. Coyote over the edge first, THEN drop.
	//Do we need to singal a DROPPED state to the SNAKE?


	TraceResults downTrace = TraceLine( tracePos, tracePos + <0.0, 0.0, -CASTLE_SNAKE_DROP_TEST_HEIGHT>, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	if ( downTrace.fraction == 1.0 ) //FOUND A CLIFF
	{
		TraceResults downCliffTrace = TraceLine( tracePos, tracePos + < 0.0, 0.0, -CASTLE_SNAKE_DROP_TEST_HEIGHT_MAX >, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

		#if DEV
			if( DEBUG_SNAKE_DRAW )
			{
				DebugDrawSphere( downCliffTrace.endPos, 6.0, COLOR_RED, true, 15.0, 8 )
			}
		#endif

		entity hitEnt = downCliffTrace.hitEnt
		bool canMountEnt = SnakeWall_IsValidMountHitEnt( hitEnt )

		if( downCliffTrace.fraction != 1 && canMountEnt ) //Cliff has ground within range for the BROKEN SNAKE to continue. Drop the Snake? Need to check for room below.
		{
			vector downCliffTraceEnd = downCliffTrace.endPos + <0,0,5>
			TraceResults dropRoomAheadTrace = TraceLine( downCliffTraceEnd , downCliffTraceEnd + dir * CASTLE_SNAKE_TEST_STEP , ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
			if( dropRoomAheadTrace.fraction == 1 )
			{
				nextValidPos = tracePos //send it off the cliff
				snakeInfo.drop = true //flag the Snake for Dropping
				snakeInfo.dropPos = downCliffTrace.endPos //Set it's Drop Position for Reference.
				return nextValidPos
			}

		}
		else //Actually a CLIFF, start BEND ANGLE test to see if we can follow a LEDGE
		{
			const float CASTLE_SNAKE_NUM_ANGLE_CHECKS = 5
			const float CASTLE_SNAKE_MAX_EDGE_ANGLE = 45.0

			float anglePerCheck = CASTLE_SNAKE_MAX_EDGE_ANGLE/CASTLE_SNAKE_NUM_ANGLE_CHECKS

			if( !snakeInfo.isLeft ) //Invert for the Right Snake
				anglePerCheck = -(anglePerCheck)

			for( int i = 0; i < CASTLE_SNAKE_NUM_ANGLE_CHECKS; i++ )
			{
				float adjustedAngle = anglePerCheck*i
				vector bendTestPos = traceStart + ( RotateVector(dir, <0, adjustedAngle, 0> ) * CASTLE_SNAKE_TEST_STEP ) //todo: Might need a way to ensure we're rotating AWAY from the DIR to curve along ledges towards the player (inside of wall)
				TraceResults ledgeBendTrace = TraceLine( traceStart, bendTestPos, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

				if( ledgeBendTrace.fraction == 1 ) //We're good ahead. Check down
				{
					TraceResults ledgeBendDownTrace = TraceLine( ledgeBendTrace.endPos, ledgeBendTrace.endPos + < 0.0, 0.0, -CASTLE_SNAKE_DROP_TEST_HEIGHT >, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
					hitEnt = ledgeBendDownTrace.hitEnt
					canMountEnt = SnakeWall_IsValidMountHitEnt( hitEnt )
					if ( ledgeBendDownTrace.fraction != 1.0 && canMountEnt ) //Found Ground. We can continue.
					{
						snakeInfo.moverDir = RotateVector(dir, <0, adjustedAngle, 0> )
						nextValidPos = ledgeBendDownTrace.endPos
						return nextValidPos
					}

					#if DEV
					if( DEBUG_SNAKE_DRAW )
					{
						DebugDrawSphere( ledgeBendTrace.endPos, 6.0, COLOR_RED, true, 15.0 )//Show where we're checking around the circle
					}
					#endif

				}
			}
			//We have failed to find a valid position to bend the snake to. - We should probably STOP the snake here.
			snakeInfo.stopped = true

		}

	}
	else // found ground. Set the nextValidPos
	{
		if( !downTrace.startSolid )
			nextValidPos = downTrace.endPos
	}

	return nextValidPos

}

#if SERVER
void function SnakeWall_MoveSnakeHeadToUpdatePos_Thread( entity target, float updateTime, vector destination, float checkDist )
{
	EndSignal( target, "OnDestroy" )

	float endTime   = Time() + updateTime

	while ( Time() < endTime )
	{
		float dist = Distance( destination, target.GetOrigin() )
		if( dist < checkDist )
		{
			return
		}
		WaitFrame()
	}
}
#endif //SERVER



////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////           PHYSICAL SHIELD WALL          ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
//

#if SERVER
void function CastleWall_CheckForCastleOverlapAndCleanup( entity castle, entity wall, float radius )
{
	if( !IsValid(castle) )
		return
	if( !IsValid(wall) )
		return

	array<entity> castleEnts

	if( castle in file.castleEntArray )
		castleEnts.extend(file.castleEntArray[castle])

	int team = castle.GetTeam()

	//DebugDrawCircle( wall.GetOrigin(), <0, 0, 0>, radius, COLOR_RED, true, 5 )

	//Destroy any other nearby intersecting
	array<entity> shieldAnchor = GetEntArrayByScriptName( ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME ) //CAstle Anchor
	foreach ( shieldWall in shieldAnchor )
	{
		if( !IsValid(shieldWall) )
			continue

		if( wall == shieldWall )
			continue

		float distToWall = Distance( wall.GetOrigin(), shieldWall.GetOrigin() )
		if( distToWall < radius )
		{
			if( castleEnts.contains( shieldWall) )
				continue

			entity damageOwner 	= IsValid( castle ) ? castle : svGlobal.worldspawn
			shieldWall.TakeDamage( CASTLE_WALL_SHIELD_ANCHOR_HEALTH, damageOwner, wall, { origin = wall.GetOrigin(), damageType = DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_ability_castle_wall } )
		}
	}

	array<entity> destructibleArray =  GetAllDestructibleEntsArray( team ) //Other Entities
	foreach ( ent in destructibleArray )
	{
		if( !IsValid(ent) )
			continue

		//int entTeam = ent.GetTeam()
		//if( entTeam == team )
		//	continue

		float distToWall = Distance( wall.GetOrigin(), ent.GetOrigin() )
		if( distToWall < radius )
		{
			//Check vertical displacement - discard items too far below
			float vertDist = ent.GetOrigin().z - wall.GetOrigin().z
			if( vertDist < -50 )
				continue

			entity damageOwner 	= IsValid( castle ) ? castle : svGlobal.worldspawn

			int entTeam 			= ent.GetTeam()
			string entName 			= ent.GetScriptName()
			string entTargetName	= ent.GetTargetName()
			bool isRefundUlt 		= false

			//Ally Ultimates are a brutal thing to have Newcastle destroy with accidental wall placement
			//To soften the blow, but not impede Newcastle's Ult Deployment, we refund ally Ultimates that get destroyed [75%] - if recently placed.
			//However, we also use a smaller radius to detect for destruction to try and maintain the Ult if possible.
			if( entTeam == team )
			{
				if( distToWall > radius/2 ) //Use smaller test radius to only crush when necessary
					continue

				switch( entName )
				{
					case TROPHY_SYSTEM_NAME:
					case DEATH_TOTEM_TARGETNAME:
					case ECHO_LOCATOR_SCRIPT_NAME:
					case BLACKHOLE_PROP_SCRIPTNAME:
					case BLACK_MARKET_SCRIPTNAME:
					case MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME:
					case JUMP_PAD_SCRIPTNAME:
					{
						isRefundUlt = true
						break
					}
				}

				if( isRefundUlt ) //We have an ally Ultimate in Range - Set WorldDamage Owner to deal damage to friendly Ults
					damageOwner 	= svGlobal.worldspawn

			}
			vector entToWall = Normalize( ent.GetOrigin() - wall.GetOrigin() )
			int damage = ent.GetHealth()
			ent.TakeDamage( damage, damageOwner, damageOwner, { origin = wall.GetOrigin(), force = -entToWall, damageSourceId = eDamageSourceId.mp_ability_castle_wall, scriptType = DF_EXPLOSION } )

			//We have damaged an ally Ultimate in Range - Determine if a Refund is necessary
			if( isRefundUlt )
			{
				float timeSinceSpawn = ent.GetTimeSinceSpawning()
				if( timeSinceSpawn < CASTLE_WALL_ALLY_OBJECT_DESTROYED_REFUND_TIME )
				{
					entity entOwner = ent.GetOwner()
					if( IsValid(entOwner) && entOwner.IsPlayer() )
					{
						entity ultimateWeapon = entOwner.GetOffhandWeapon( OFFHAND_ULTIMATE )

						if( IsValid( ultimateWeapon ) )
						{
							float ultCharge = ultimateWeapon.GetWeaponPrimaryClipCount().tofloat()

							int ultimateCharge 		= ultimateWeapon.GetWeaponPrimaryClipCount()
							int maxUltimateCharge 	= ultimateWeapon.GetWeaponPrimaryClipCountMax()

							if ( maxUltimateCharge > 0 )
							{
								float ultRefund = maxUltimateCharge.tofloat() * CASTLE_WALL_ALLY_OBJECT_DESTROYED_REFUND_FRAC //this will change rate based on shield size
								ultCharge = ultCharge + ultRefund
								if ( ultCharge - ultimateCharge.tofloat() > 0 )
									ultimateWeapon.SetWeaponPrimaryClipCount( minint( ultCharge.tointeger(), maxUltimateCharge)  )
							}
						}


					}
				}
			}

			if ( entName == DIRTY_BOMB_TARGETNAME )
			{

			}

			if( IsValid( ent ) && entTargetName == SPIKE_STRIP_CORE_SPIKE_NAME )
			{
				ent.Destroy()
			}
		}
	}
}

array<entity> function GetAllDestructibleEntsArray( int team )
{
	array<entity> destructibleArray

	destructibleArray.extend( GetEntArrayByScriptName( TROPHY_SYSTEM_NAME ) ) 						//Wattson Ult
	destructibleArray.extend( GetEntArrayByScriptName( TESLA_TRAP_NAME ) )							//Wattson Fence
	destructibleArray.extend( GetEntArrayByScriptName( DIRTY_BOMB_TARGETNAME ) )					//Caustic Trap
	destructibleArray.extend( GetEntArrayByScriptName( DEATH_TOTEM_TARGETNAME ) )					//Revenant Totem
	destructibleArray.extend( GetEntArrayByScriptName( BLACKHOLE_PROP_SCRIPTNAME ) )				//Horizon NEWT
	destructibleArray.extend( GetEntArrayByScriptName( BLACK_MARKET_SCRIPTNAME ) )					//Loba Black Market
	destructibleArray.extend( GetEntArrayByScriptName( BASE_WALL_SCRIPT_NAME ) )					//Rampart Wall
	destructibleArray.extend( GetEntArrayByScriptName( MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME ) )		//Planted Shiela
	destructibleArray.extend( GetEntArrayByScriptName( ECHO_LOCATOR_SCRIPT_NAME ) )					//Seer Ult
	destructibleArray.extend( GetEntArrayByScriptName( ECHO_LOCATOR_SCRIPT_NAME ) )					//Seer Ult
	destructibleArray.extend( GetEntArrayByScriptName( CRYPTO_DRONE_SCRIPTNAME ) )					//Crypto Drone
	destructibleArray.extend( GetEntArrayByScriptName( JUMP_PAD_SCRIPTNAME ) )						//Jump Pad
	destructibleArray.extend( GetEntArrayByScriptName( SHIELD_MINE_PROP_SCRIPTNAME ) )				//Conduit Ult Mines
	destructibleArray.extend( GetAllSpikeCores() )													//Catalyst tac

	//May want to Add Maggie Drill/Ball ] Ballistic Tac in Future// Ash Tether -> Tried Ash Tether, destroying the prop leaves behind elements/threads sometimes. Would need more investigation
	destructibleArray.extend( GetPlayerDecoyArray() )												//Mirage Decoys
	destructibleArray.extend( LootTicks_GetAllLootTicks() )
	destructibleArray.extend( GetAllLootRollers() )
	destructibleArray.extend( GetAllPropDoors() )

	return destructibleArray
}
#endif

#if SERVER
void function CastleWall_CheckForStickyEnt( entity wallEnt )
{
	entity castle = wallEnt.GetOwner()

	if( !IsValid(castle) )
		return

	array<entity> ignoreArray = ArmoredLeapIgnoreArray(castle)

	TraceResults results = TraceLine( wallEnt.GetOrigin() + <0,0,32>, wallEnt.GetOrigin() + <0,0,-32>, ignoreArray, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	entity hitEnt = results.hitEnt
	if ( IsValid( hitEnt ) && EntityShouldStick( wallEnt, hitEnt ) && SnakeWall_IsValidMountHitEnt( hitEnt ) )
	{
		if( !EntIsHoverVehicle(hitEnt) && !hitEnt.IsWorld() )
			wallEnt.SetParent( hitEnt, "", true )
	}
}
#endif


#if SERVER
void function CastleWall_CheckForGeoIntersection( entity wallProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	wallProxy.EndSignal( "OnDestroy" )

	float startTime = Time()

	WaitFrame() //Allow walls to be properly assigned when created.

	float hullDepth = 5
	float hullWidth = hullDepth
	float wallFullWidth = 30
	float hullHeight = 50
	float heightOffGround = 10 // Matches object_placement_ground_penetration_max

	string targetName = wallProxy.GetTargetName()
	switch( targetName )
	{
		case ARMORED_LEAP_SHIELD_LOW_LEFT:
		case ARMORED_LEAP_SHIELD_LOW_RIGHT:
			wallFullWidth = 15
			break
	}

	while ( IsValid(wallProxy) )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		ignoreEnts.append( wallProxy )

		vector right = wallProxy.GetRightVector()
		vector up = wallProxy.GetUpVector()

		vector startPos = wallProxy.GetOrigin() + up * heightOffGround + right * -wallFullWidth * 0.8
		vector endPos   = wallProxy.GetOrigin() + up * heightOffGround + right * wallFullWidth * 0.8

		switch( targetName ) //Need to nudge these back over due to their origin being on the corner
		{
			case ARMORED_LEAP_SHIELD_LOW_LEFT:
				startPos = startPos + right * -wallFullWidth
				endPos   = endPos + right * -wallFullWidth
				break
			case ARMORED_LEAP_SHIELD_LOW_RIGHT:
				startPos = startPos + right * wallFullWidth
				endPos   = endPos + right * wallFullWidth
				break
		}

		TraceResults results = TraceHull( startPos, endPos, <-hullWidth, -hullDepth, 0>, <hullWidth, hullDepth, hullHeight>, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		//DebugDrawBox( startPos, <-hullWidth,-hullDepth,0>, <hullWidth,hullDepth,hullHeight>, COLOR_GREEN, 1, 1.0 )
		//DebugDrawBox( endPos, <-hullWidth,-hullDepth,0>, <hullWidth,hullDepth,hullHeight>, <0, 128, 0>, 1, 1.0 )
		//PrintTraceResults( results )
		if ( results.startSolid || results.fraction != 1 )
		{
			entity hitEnt = results.hitEnt
			if ( IsValid( hitEnt ) )
			{
				bool canDamage = true
				string hitEntClassname = hitEnt.GetClassName()
				if ( hitEntClassname == "phys_bone_follower" || hitEntClassname == "func_brush" || hitEntClassname == "script_mover" || hitEntClassname == "func_brush_lightweight" || hitEntClassname == "prop_dynamic" || hitEntClassname == "player_vehicle" )
				{

					entity pusher = GetPusherEnt( hitEnt )
					entity wallParent = wallProxy.GetParent()

					if( EntIsHoverVehicle(hitEnt) )
						canDamage = true

					if( canDamage )
					{
						//If the MAIN SHIELD is destroyed by the world shortly after deployment, we want to issue a refund.
						//There is an edge case issue here where if the Shield is spawned completely inside a slow-moving object it is not detected and will not refund.
						if( Time() - startTime <= 2 && targetName == ARMORED_LEAP_SHIELD_ANCHOR_CENTER )
						{
							entity castle = wallProxy.GetOwner()
							if(IsValid(castle))
							{
								entity player = castle.GetOwner()
								if( IsValid(player) )
									ArmoredLeap_OnAttemptFailed( player, player.GetOrigin() )
							}
						}

						entity damageOwner 	= svGlobal.worldspawn
						wallProxy.TakeDamage( CASTLE_WALL_SHIELD_ANCHOR_HEALTH, damageOwner, hitEnt, { origin = wallProxy.GetOrigin(), damageType = DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_ability_castle_wall } )
					}
				}
			}
		}

		wait 0.2
	}
}
#endif

                    
int function GetUpgradedCastleWallExtraHealth()
{
	return GetCurrentPlaylistVarInt( "ultimate_armored_leap_upgrade_extra_health", 200 )
}

float function GetUpgradedCastleWallBarrierExtraDuration()
{
	return GetCurrentPlaylistVarFloat( "ultimate_armored_leap_upgrade_extra_barrier_duration", 120 )
}

float function GetUpgradedArmoredLeapDistance()
{
	return GetCurrentPlaylistVarFloat( "ultimate_armored_leap_upgrade_range_multiplier", 1.2 )
}
      

#if SERVER
int function GetCastleWallHealth( entity owner )
{
	int result = file.castleWallHealth

	                    
	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_boosted_armored_leap
	{
		result += GetUpgradedCastleWallExtraHealth()
	}
       

	return result
}

///////// PHYSICAL SHIELD WALL //////////////
entity function CreateCastlePhysicalShield( entity mover, entity owner, vector origin, vector dir, asset shieldAsset, vector angles = <0,0,0>, int segmentType = eSegmentType.HIGH, int anchorType = eAnchorType.NONE ) //Testing adding the dir
{
	vector flatForward
	if( IsValid( mover ) )
		flatForward = Normalize( FlattenVec( mover.GetForwardVector() ) )
	else
		flatForward = Normalize( FlattenVec( dir ) )

	if( angles == ZERO_VECTOR )
		angles = AnglesCompose( VectorToAngles(flatForward), ZERO_VECTOR )

	entity shield = CreatePropScript( shieldAsset, origin, angles, SOLID_OBB )
	shield.SetScriptName( ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
	shield.kv.CollisionGroup = TRACE_COLLISION_GROUP_NONE
	//shield.kv.contents = int( shield.kv.contents)  | TRACE_MASK_OPAQUE | TRACE_MASK_BLOCKLOS
	//shield.kv.CollisionGroup = TRACE_COLLISION_GROUP_PLAYER
	//shield.kv.CollisionGroup = TRACE_COLLISION_GROUP_PLAYER_MOVEMENT

	float cleanupRadius = CASTLE_WALL_OVERLAP_CLEANUP_RADIUS_SEGMENT

	switch( anchorType )
	{
		case eAnchorType.NONE:
			if ( segmentType == eSegmentType.LOW_LEFT )
			{
				SetTargetName( shield, ARMORED_LEAP_SHIELD_LOW_LEFT )
			}
			else if ( segmentType == eSegmentType.LOW_RIGHT )
			{
				SetTargetName( shield, ARMORED_LEAP_SHIELD_LOW_RIGHT )
			}
			else
			{
				SetTargetName( shield, ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
			}
			break
		case eAnchorType.LEFT:
			SetTargetName( shield, ARMORED_LEAP_SHIELD_ANCHOR_LEFT )
			break
		case eAnchorType.CENTER:
			SetTargetName( shield, ARMORED_LEAP_SHIELD_ANCHOR_CENTER )
			cleanupRadius = CASTLE_WALL_OVERLAP_CLEANUP_RADIUS_ANCHOR
			break
		case eAnchorType.RIGHT:
			SetTargetName( shield, ARMORED_LEAP_SHIELD_ANCHOR_RIGHT )
			break
	}

	shield.RemoveFromAllRealms()
	shield.AddToOtherEntitysRealms( owner )

	if( IsValid( owner ) )
	{
		entity player = owner
		if( !IsValidPlayer( player ) )
		{
			// The owner is not a player, but a castle.
			player = owner.GetOwner()
		}
		if( IsValidPlayer( player ) )
		{
			FiringRange_AddToRemoveOnCharacterChange( shield, player )
		}
	}

	shield.SetOwner( owner )
	shield.LinkToEnt( owner.GetOwner() )
	SetTeam( shield, owner.GetTeam() )

	shield.SetMaxHealth( GetCastleWallHealth( owner.GetOwner() ) )
	shield.SetHealth( GetCastleWallHealth( owner.GetOwner() ) )


	shield.DisableHibernation()
	shield.SetDamageNotifications( false )
	shield.SetDeathNotifications( false )
	shield.SetArmorType( ARMOR_TYPE_HEAVY )
	shield.SetTakeDamageType( DAMAGE_YES )

	if( IsValid( mover ) )
		shield.SetParent( mover, "", true )

	shield.AllowMantle()


	if ( shield.GetTargetName() != ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
	{
		shield.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE )
	}

                                   
                                                    
       

	shield.e.noOwnerFriendlyFire = false
	shield.e.noFriendlyFireProtection = true
	shield.e.canBeDamagedFromGas = false
	shield.e.canBurn = true
	shield.e.blocksThermite = true
	shield.SetTouchTriggers( true )
	shield.SetForceVisibleInPhaseShift( true )

	AddSonarDetectionForPropScript( shield )
	MarkEntForCleanupOnRoundEnd( shield )

	shield.SetUsable()
	shield.SetUsablePriority( USABLE_PRIORITY_LOW )
	shield.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER ) //Update hint text every server frame so that we can keep unique client texts up to date.
	SetCallback_CanUseEntityCallback( shield, CastleWall_CanUse )


	//shield.kv.contents = int( shield.kv.contents)  | TRACE_MASK_OPAQUE | TRACE_MASK_BLOCKLOS

	if( segmentType == eSegmentType.LOW_LEFT || segmentType == eSegmentType.LOW_RIGHT )
		AddEntityCallback_OnDamaged( shield,  void function ( entity shield, var damageInfo ) : ( owner, segmentType ) //castle is the owner
		{
			if( !IsValid( owner ) )
				return

			if( !IsValid( shield ) )
				return

			array<entity> tailFriends
			if( segmentType == eSegmentType.LOW_LEFT  )
				tailFriends = file.castleSnakeTailsL[owner]
			else
				tailFriends = file.castleSnakeTailsR[owner]

			//Set All Panels to the Same HP
			int minHP = shield.GetHealth()
			foreach ( panel in tailFriends )
			{
				if( !(IsValid(panel)) )
					continue

				minHP = minint( panel.GetHealth(), minHP )
			}
			minHP = maxint( minHP, 0 )
			foreach ( panel in tailFriends )
			{
				if( !(IsValid(panel)) )
					continue

				panel.SetHealth( minHP )
			}
		})
	AddEMPDamageDevice( shield )

	AddWreckingBallEMPDamageDevice( shield )

                 
                                   
       

	AddEMPDisableDevice( shield, CastleWall_OnEMPDisable )
	AddEntityCallback_OnPostDamaged( shield, CastleWall_OnDamaged )
	AddEntityCallback_OnPostDamaged( shield, CastleWall_OnPostDamaged )

	CastleWall_CheckForCastleOverlapAndCleanup( owner, shield, cleanupRadius )
	thread CastleWall_CheckForGeoIntersection( shield )

	return shield
}
#endif

#if SERVER
void function CastleWall_OnDamaged( entity shieldEnt, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( shieldEnt ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	//Two melees will destroy the wall
	if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) || IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) )
		{
			switch ( damageSourceIdentifier )
			{

                                               
				case eDamageSourceId.melee_shadowroyale_hands:
				case eDamageSourceId.melee_shadowsquad_hands:
				case eDamageSourceId.mp_weapon_shadow_squad_hands_primary:
					DamageInfo_SetDamage( damageInfo, shieldEnt.GetMaxHealth() / 2 )
					DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
					break
      

				default:
					if ( IsProwler( attacker ) )
						DamageInfo_SetDamage( damageInfo, shieldEnt.GetMaxHealth() / 2 )
					DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )
			}
		}

		if ( IsBitFlagSet( damageFlags, DF_MELEE ) )
		{
			DamageInfo_SetDamage( damageInfo, shieldEnt.GetMaxHealth() / 2 )
			DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
		}

	}
	else
	{
		if ( shieldEnt.GetMaxHealth() < file.castleWallHealth )
		{
			DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
		}
		else
		{
			DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )
		}
	}
}
#endif

#if SERVER
void function CastleWall_OnPostDamaged( entity shieldEnt, var damageInfo )
{
	if( !IsValid( shieldEnt ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity weapon = DamageInfo_GetWeapon( damageInfo )

	if ( !IsValid( attacker ) )
		return

	bool shieldWallDestroyed = ( shieldEnt.GetHealth() - DamageInfo_GetDamage( damageInfo ) ) <= 0

	if ( attacker.IsPlayer() )
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_NO_HITBEEP )
		DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )

		if ( shieldWallDestroyed )
		{
			DamageInfo_AddCustomDamageType( damageInfo, DF_KILLSHOT )
		}

		int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		if( damageSourceID == eDamageSourceId.mp_ability_crypto_drone_emp_trap )
			return

		int damageFlags 	= DamageInfo_GetCustomDamageType( damageInfo )
		if ( !IsBitFlagSet( damageFlags, DF_MELEE ) )
		{
			attacker.NotifyDidDamage( shieldEnt, 0, DamageInfo_GetDamagePosition( damageInfo ), damageFlags,
				DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX,
				DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
		}
	}
	if ( shieldWallDestroyed )
	{
		CastleWall_DestroyWallEnt( shieldEnt, damageInfo )
	}

}
#endif

#if SERVER
void function CastleWall_OnEMPDisable( entity shieldEnt )
{
	if( !IsValid(shieldEnt) )
		return

	Signal( shieldEnt, "CastleWall_BarrierDisrupted" )
}
#endif

#if CLIENT
vector function CastleWall_OffsetDamageNumbers( entity shieldEnt, vector damageFlyoutPosition )
{
	vector flyoutPosition = ZERO_VECTOR

	entity player = GetLocalClientPlayer()

	if( !IsValid(player) )
		return damageFlyoutPosition

	float distToShield = Distance( player.GetOrigin(),shieldEnt.GetOrigin() )
	const float CASTLE_WALL_DAMAGE_POS_FWD_OFFSET = 20.0
	const float CASTLE_WALL_DAMAGE_POS_VERT_OFFSET_NEAR 	= 25.0
	const float CASTLE_WALL_DAMAGE_POS_VERT_OFFSET_FAR 		= -180.0
	vector origin = shieldEnt.GetOrigin() - shieldEnt.GetForwardVector() * CASTLE_WALL_DAMAGE_POS_FWD_OFFSET

	float vertOffset = GraphCapped( distToShield, 200, 2000, CASTLE_WALL_DAMAGE_POS_VERT_OFFSET_NEAR, CASTLE_WALL_DAMAGE_POS_VERT_OFFSET_FAR )
	flyoutPosition = origin + <0,0,vertOffset> //Top Shield

	return flyoutPosition
}
#endif

#if SERVER
void function CastleWall_DestroyWallEnt( entity shield, var damageInfo )
{
	int effectID
	string destroySFX

	if( IsValid( shield ) )
	{
		string scriptName = shield.GetScriptName()
		string targetName = shield.GetTargetName()

		if( targetName == ARMORED_LEAP_SHIELD_ANCHOR_CENTER || targetName == ARMORED_LEAP_SHIELD_ANCHOR_RIGHT || targetName == ARMORED_LEAP_SHIELD_ANCHOR_LEFT )
		{
			effectID = GetParticleSystemIndex( CASTLE_WALL_SHIELD_ANCHOR_DESTROYED_LARGE_FX )
			destroySFX 	= CASTLE_WALL_SHIELD_ANCHOR_DESTROY_SOUND
		}
		else if( scriptName == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
		{
			effectID = GetParticleSystemIndex( CASTLE_WALL_SHIELD_ANCHOR_DESTROYED_FX )
			destroySFX 	= CASTLE_WALL_SHIELD_ANCHOR_DESTROY_SOUND
		}

		StartParticleEffectInWorld( effectID, shield.GetOrigin(), shield.GetAngles() )
		EmitSoundAtPosition( TEAM_UNASSIGNED, shield.GetOrigin(), destroySFX, shield )

		entity castle = shield.GetOwner()
		if( IsValid( castle ) )
		{
			entity castleOwner = castle.GetOwner()
			if( IsValid(castleOwner) )
			{
				entity attacker = DamageInfo_GetAttacker( damageInfo )
				if ( IsValid( attacker ) && attacker.IsPlayer() )
				{
					if( attacker.GetTeam() != castleOwner.GetTeam() )
					{
						EmitSoundOnEntityToTeamExceptPlayer( castleOwner, CASTLE_WALL_DESTROYED_CHATTER_VO_3P, castleOwner.GetTeam(), castleOwner )
						EmitSoundOnEntityOnlyToPlayer( castleOwner, castleOwner, CASTLE_WALL_DESTROYED_CHATTER_VO_1P )
					}
				}
			}

			if( castle in file.castleEntArray )
			{
				if( file.castleEntArray[castle].contains(shield) )
					file.castleEntArray[castle].fastremovebyvalue(shield)

				if( castle in file.castleSnakeTailsL )
				{
					CastleWall_DestroyConnectedTailPanelEnts( shield, castle, file.castleSnakeTailsL[castle] )
				}
				if( castle in file.castleSnakeTailsR )
				{
					CastleWall_DestroyConnectedTailPanelEnts( shield, castle, file.castleSnakeTailsR[castle] )
				}
				//Signal full Cleanup
				if( file.castleEntArray[castle].len() == 0 )
					Signal( castle, "CastleWall_CastleDestroyed" )
			}
		}
	}
}

void function CastleWall_DestroyConnectedTailPanelEnts( entity shield, entity castle, array<entity> tailArray )
{
		if( tailArray.contains( shield ) )
		{
			foreach( panel in tailArray )
			{
				if( !IsValid( panel ) )
					continue

				if( panel != shield )
				{
					if( file.castleEntArray[castle].contains(panel) )
						file.castleEntArray[castle].fastremovebyvalue(panel)

					panel.Destroy()
				}

			}
		}
}

#endif

bool function IsCastleWallEnt( entity ent )
{
	return ent.GetScriptName() == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME
}




////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////           ELECTRICAL BARRIER            ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

/////MOVE THIS////
#if SERVER
void function CastleWall_CreateElectricBarriers( entity castle )
{
	EndSignal( castle, "OnDestroy" )

	if( castle in file.castleEntArray )
	{
		int segmentType		= eSegmentType.HIGH
		vector dir 			= castle.GetForwardVector()

		//Used to randomize the small panel FX used
		array<int> leftNum 	= [0,1,2]
		array<int> rightNum = [0,1,2]
		int randChoice
		int randFXInt = 0

		foreach( wall in file.castleEntArray[castle] )
		{
			bool shouldActivate	= true
			if( !IsValid( wall ) )
				continue

			string targetName = wall.GetTargetName()

			switch( targetName )
			{
				case ARMORED_LEAP_SHIELD_LOW_LEFT:
					segmentType = eSegmentType.LOW_LEFT
					if( leftNum.len() > 0 )
					{
						randChoice = RandomInt( leftNum.len() )
						//printt("choice:   " + randChoice + " | left_Value:  " +leftNum[randChoice])
						//printt("L_LEN:   " + leftNum.len())
						randFXInt = leftNum[randChoice]
						leftNum.fastremove(randChoice)
					}

					break
				case ARMORED_LEAP_SHIELD_LOW_RIGHT:
					segmentType = eSegmentType.LOW_LEFT
					if( rightNum.len() > 0 )
					{
						randChoice = RandomInt( rightNum.len() )
						//printt("choice:   " + randChoice + " | right_Value:  " +rightNum[randChoice])
						//printt("R_LEN:   " + rightNum.len())
						randFXInt = rightNum[randChoice]
						rightNum.fastremove(randChoice)
					}
					break
				case ARMORED_LEAP_SHIELD_ANCHOR_CENTER:
					segmentType = eSegmentType.HIGH
					break
				case ARMORED_LEAP_SHIELD_ANCHOR_LEFT:
					segmentType = eSegmentType.HIGH
					break
				case ARMORED_LEAP_SHIELD_ANCHOR_RIGHT:
					segmentType = eSegmentType.HIGH
					break
				default:
					break
			}

			if( wall in file.endWallDeployed )
			{
				shouldActivate = file.endWallDeployed[wall]
			}

			dir = wall.GetForwardVector()

			if( shouldActivate )
			{
				////Create the Damage Trigger Volume for the Shield Barrier
				thread CastleWall_CreateTriggerVolume( wall, castle, segmentType, CASTLE_SNAKE_WALL_DAMAGE_VOLUME_HEIGHT, CASTLE_SNAKE_WALL_DAMAGE_VOLUME_THICKNESS )

				////Create the Electric Energy VFX across the Shield Barrier
				thread CastleWall_CreateSnakeWall_ArcSurfaceFX( castle, wall, dir, randFXInt )
			}
		}
	}

}
#endif

float function CastleWall_GetWallBarrierDuration( entity owner )
{
	float result = file.barrierDuration

	                    
	if( IsValid( owner ) && owner.HasPassive( ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_boosted_armored_leap
	{
		result += GetUpgradedCastleWallBarrierExtraDuration()
	}
       

	return result
}

/////// SHIELD TRIGGER VOLUME ////////
#if SERVER
void function CastleWall_CreateTriggerVolume( entity shieldWall, entity castle, int segmentType, float height, float thickness )
{
	shieldWall.EndSignal( "OnDestroy" )
	//Disable Electrical Barrier
	EndSignal( shieldWall, "CastleWall_BarrierDisrupted" )

	vector up = shieldWall.GetUpVector()
	vector forward = shieldWall.GetForwardVector()
	vector dir = Normalize( forward )

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( shieldWall )
	trigger.SetCylinderRadius( height ) 	//Cylinder is on its side so the RADIUS determines how high the volume needs to go.
	trigger.SetAboveHeight( thickness )		//HEIGHT determines how "thick" the area in front of the shield is
	trigger.SetBelowHeight( thickness )
	SetTeam( trigger, shieldWall.GetTeam() )
	trigger.kv.triggerFilterNonCharacter = "0"
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( shieldWall )
	entity owner = castle.GetOwner()
	if( IsValidPlayer( owner ) )
	{
		FiringRange_AddToRemoveOnCharacterChange( trigger, owner )
	}
	DispatchSpawn( trigger )

	float upOffset 	= 0
	if(  segmentType != eSegmentType.HIGH )
		upOffset = 35 //offset LOW segments to be in line with high ones.

	vector newOrigin = shieldWall.GetCenter() +(up * upOffset) + (dir * CASTLE_SNAKE_WALL_DAMAGE_VOLUME_THICKNESS)
	trigger.SetOrigin( newOrigin )

	trigger.SetAngles( AnglesCompose( shieldWall.GetAngles(),  < 90, 90, 90 > ) )

	trigger.SetParent( shieldWall, "", true, 0.0 )


	OnThreadEnd(
		function() : ( trigger, shieldWall )
		{
			if ( IsValid( trigger ) )
			{
				trigger.Destroy()
			}
			if ( IsValid( shieldWall ) )
			{
			}
		}
	)

	wait 0.5 //allow launch delay before trigger activation can occur
	if ( IsValid( trigger ) )
	{
		trigger.SetEnterCallback( CastleWall_OnTriggerEnter )
		trigger.SetLeaveCallback( CastleWall_OnTriggerExit )
		trigger.SearchForNewTouchingEntity()
	}

	#if DEV
		if( DEBUG_DRAW_DAMAGE_BARRIERS )
		{
			if( segmentType == eSegmentType.HIGH )
			{
				float widthHigh = CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_HIGH //40
				DebugDrawLine( trigger.GetOrigin(), trigger.GetOrigin() + trigger.GetRightVector() * widthHigh, COLOR_GREEN, true, 60 )
				DebugDrawLine( trigger.GetOrigin(), trigger.GetOrigin() - trigger.GetRightVector() * widthHigh, COLOR_GREEN, true, 60 )
				DebugDrawSphere( trigger.GetOrigin() + trigger.GetRightVector() * widthHigh, 4.0, COLOR_GREEN, true, 60 )
				DebugDrawSphere( trigger.GetOrigin() - trigger.GetRightVector() * widthHigh, 4.0, COLOR_GREEN, true, 60 )

			}

			if( segmentType == eSegmentType.LOW )
			{
				float widthLow = CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_LOW //15
				DebugDrawLine( trigger.GetOrigin(), trigger.GetOrigin() + trigger.GetRightVector() * widthLow, <200, 200, 0>, true, 60 )
				DebugDrawLine( trigger.GetOrigin(), trigger.GetOrigin() - trigger.GetRightVector() * widthLow, <200, 200, 0>, true, 60 )
				DebugDrawSphere( trigger.GetOrigin() + trigger.GetRightVector() * widthLow, 4.0, COLOR_YELLOW, true, 60 )
				DebugDrawSphere( trigger.GetOrigin() - trigger.GetRightVector() * widthLow, 4.0, <255, 255, 100>, true, 60 )
			}
		}
	#endif

	//Add Duration to the Electric Charge. Need a SFX sound to indicate
	wait CastleWall_GetWallBarrierDuration( castle.GetOwner() ) - CASTLE_WALL_BARRIER_WARNING_DURATION - 0.5

	//Begin Warning//
	if( !IsValid(shieldWall) )
		return

	EmitSoundOnEntity( shieldWall, CASTLE_WALL_BARRIER_END_WARNING_SOUND )

	wait CASTLE_WALL_BARRIER_WARNING_DURATION
	//WaitForever()

}

void function CastleWall_OnTriggerEnter( entity trigger, entity player )
{
	if ( !IsValid( player) )
		return

	//Firing range, dummies/friendly fire team mates when killed will become invalidated and get picked up by OnTriggerEnter() callback, so early out. R5DEV-290145
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		if ( !IsAlive( player ) )
		{
			return
		}
	}

	thread CastleWall_OnTriggerUpdate( trigger, player )
}

void function CastleWall_OnTriggerExit( entity trigger, entity player )
{
	if ( !IsValid( player) )
		return

}

void function CastleWall_OnTriggerUpdate( entity trigger, entity victim )
{
	trigger.EndSignal( "OnDestroy" )

	entity shieldWall = trigger.GetOwner()

	if ( !IsValid( shieldWall ) )
		return

	if ( !victim.IsPlayer() && !(victim.IsNPC() && !victim.IsNonCombatAI()) )
		return

	if( victim.IsPlayer() )
		victim.EndSignal( "OnDeath" )

	victim.EndSignal( "OnDestroy" )

	int team 			= trigger.GetTeam()
	int vteam			= victim.GetTeam()
	entity castle 		= shieldWall.GetOwner()
	bool inRange		= false
	float wallDist		= CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_HIGH

	OnThreadEnd(
		function() : ( victim )
		{
			if ( IsValid( victim ) )
			{
			}
		}
	)

	if ( IsFriendlyTeam( vteam, team ) )
		return

	while ( trigger.IsTouching( victim ) )
	{
		if( !IsValid( victim ) )
			return

		if ( !StatusEffect_HasSeverity( victim, eStatusEffect.castle_wall_emp ) && !victim.IsPhaseShifted() ) //.emp
		{

			if( castle in file.castleEntArray )
			{
				if( file.castleEntArray[castle].contains(shieldWall) )
				{
					string targetName = shieldWall.GetTargetName()

					switch( targetName )
					{
						case ARMORED_LEAP_SHIELD_LOW_LEFT:
							wallDist = CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_LOW
							break
						case ARMORED_LEAP_SHIELD_LOW_RIGHT:
							wallDist = CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_LOW
							break
						default:
							wallDist = CASTLE_SNAKE_WALL_DAMAGE_VOLUME_WIDTH_HIGH
							break
					}
				}

				float heightDiff = shieldWall.GetOrigin().z - victim.EyePosition().z
				float dist = Distance2D( trigger.GetOrigin(), victim.GetOrigin() )
				if( dist > wallDist || heightDiff > 0 )
					inRange = false
				else
					inRange = true
			}


			if( IsEnemyTeam( vteam, team ) && inRange )
			{
				entity castleOwner = castle.GetOwner()
				entity damageOwner 	= IsValid( castleOwner ) ? castleOwner : svGlobal.worldspawn
				shieldWall 			= IsValid( shieldWall ) ? shieldWall : svGlobal.worldspawn

				if ( victim.IsPlayer() )
				{
					thread CastleWall_TrackEMPFX_Thread( victim )

					StatusEffect_AddTimed( victim, eStatusEffect.castle_wall_emp, 1.0, CASTLE_WALL_BARRIER_DAMAGE_INTERVAL, 0.2 )
					StatusEffect_AddTimed( victim, eStatusEffect.emp, 1.0, CASTLE_WALL_BARRIER_DAMAGE_INTERVAL, 0.2 )
					StatusEffect_AddTimed( victim, eStatusEffect.move_slow, 0.75, CASTLE_WALL_BARRIER_DAMAGE_INTERVAL, 1 )
					StatusEffect_AddTimed( victim, eStatusEffect.turn_slow, 0.75, CASTLE_WALL_BARRIER_DAMAGE_INTERVAL, 1 )
				}

				victim.TakeDamage( CASTLE_WALL_BARRIER_DAMAGE, damageOwner, shieldWall, { origin = trigger.GetOrigin(), damageType = DF_ELECTRICAL, scriptType = DF_STUN_AI, damageSourceId = eDamageSourceId.mp_ability_castle_wall } )

				if ( !victim.IsNPC() )
				{
					EmitSoundAtPositionOnlyToPlayer( TEAM_UNASSIGNED, trigger.GetOrigin(), victim, CASTLE_WALL_BARRIER_DAMAGE_1P_SOUND )
					EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, trigger.GetOrigin(), victim, CASTLE_WALL_BARRIER_DAMAGE_3P_SOUND )
				}
				else
				{
					EmitSoundAtPosition( TEAM_UNASSIGNED, trigger.GetOrigin(), CASTLE_WALL_BARRIER_DAMAGE_3P_SOUND, trigger )
				}
			}
		}

		WaitFrame()
	}
}

void function CastleWall_DamagedTarget( entity victim, var damageInfo )
{
	if ( !victim.IsNPC() )
		return

	if ( Electricity_ShouldStunNPCAndAddImmunity( victim ) )
	{
		DamageInfo_ScaleDamage( damageInfo, 0 )
		return
	}

	Electricity_DamagedPlayerOrNPC( victim, damageInfo, CASTLE_WALL_BARRIER_DAMAGE_INTERVAL )
}

void function CastleWall_TrackEMPFX_Thread( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	int effectID = GetParticleSystemIndex( CASTLE_WALL_EMP_FX_3P )
	entity empEffect3p

	if ( !StatusEffect_HasSeverity( player, eStatusEffect.castle_wall_emp ) )
	{
		empEffect3p = StartParticleEffectOnEntity_ReturnEntity( player, effectID, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
		empEffect3p.SetOwner( player )
		empEffect3p.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
	}

	OnThreadEnd(
		function() : ( empEffect3p )
		{
			if ( IsValid( empEffect3p ) )
			{
				EffectStop( empEffect3p )
				empEffect3p.Destroy()
			}
		}
	)

	wait CASTLE_WALL_BARRIER_DAMAGE_INTERVAL
}
#endif //SERVER


////////////// SHIELD ELECTRIC BARRIER EFFECTS ////////////////
#if SERVER
void function CastleWall_CreateSnakeWall_ArcSurfaceFX( entity castle, entity ent, vector dir, int randFXInt = 0 )
{
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "CastleWall_PickedUp" )
	EndSignal( castle, "CastleWall_CastleDestroyed" )
	//Disable Electrical Barrier
	EndSignal( ent, "CastleWall_BarrierDisrupted" )

	int team = ent.GetTeam()
	entity owner = ent.GetOwner()

	array<entity> fxArray
	float fxDirY 		= 0
	vector pos 			= ent.GetOrigin()
	vector angles 		= VectorToAngles(Normalize( dir ) )
	string targetName 	= ent.GetTargetName()

	int fxID

	switch( ent.GetTargetName() )
	{
		case ARMORED_LEAP_SHIELD_ANCHOR_LEFT:
			fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_LG_L_FX )
			break
		case ARMORED_LEAP_SHIELD_ANCHOR_CENTER:
			fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_LG_FX )
			break
		case ARMORED_LEAP_SHIELD_ANCHOR_RIGHT:
			fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_LG_R_FX )
			break
		case ARMORED_LEAP_SHIELD_LOW_LEFT:
			switch( randFXInt )
			{
				case 0:
					fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT )
					//printt(" LEFT RAND FX IN: "  + randFXInt )
					break
				case 1:
					fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT_02 )
					//printt(" LEFT RAND FX IN: "  + randFXInt )
					break
				case 2:
					fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_SM_FX_LEFT_03 )
					//printt(" LEFT RAND FX IN: "  + randFXInt )
					break
				default:
					break
			}
			break
		case ARMORED_LEAP_SHIELD_LOW_RIGHT:
			switch( randFXInt )
			{
				case 0:
					fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT )
					//printt(" RIGHT RAND FX IN: "  + randFXInt )
					break
				case 1:
					fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT_02 )
					//printt(" RIGHT RAND FX IN: "  + randFXInt )
					break
				case 2:
					fxID = GetParticleSystemIndex( CASTLE_WALL_ELEC_PANEL_SM_FX_RIGHT_03 )
					//printt(" RIGHT RAND FX IN: "  + randFXInt )
					break
				default:
					break
			}
			fxDirY = -180
			break
		default:
			break
	}

	#if DEV
		if( DEBUG_DRAW_DAMAGE_BARRIERS )
		{
			DebugDrawArrow(  pos, pos + AnglesToForward( angles )*25, 10, <255,150,0>,false, 10)
		}
	#endif

	//Ally FX//
	entity fxAlly = StartParticleEffectOnEntityWithPos_ReturnEntity( ent, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,fxDirY,0> )
	EffectSetControlPointVector( fxAlly, 2, CASTLE_WALL_COLOR_ALLY )
	EffectSetControlPointVector( fxAlly, 3, <CASTLE_WALL_ALPHA_ALLY, 0, 0> )

	SetTeam( fxAlly, team )
	fxAlly.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	fxAlly.SetOwner( owner )

	//Enemy FX//
	entity fxEnemy = StartParticleEffectOnEntityWithPos_ReturnEntity( ent, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,fxDirY,0> )
	EffectSetControlPointVector( fxEnemy, 2, CASTLE_WALL_COLOR_ENEMY )
	EffectSetControlPointVector( fxEnemy, 3, <CASTLE_WALL_ALPHA_ENEMY, 0, 0> )

	SetTeam( fxEnemy, team )
	fxEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	fxEnemy.SetOwner( owner )

	fxArray.append(fxAlly)
	fxArray.append(fxEnemy)
	////////////

	ent.e.castleWallIsEnergized = true

	OnThreadEnd(
		function () : ( fxArray, ent )
		{
			foreach ( fx in fxArray )
			{
				if ( IsValid( fx ) )
				{
					EffectStop(fx)
					fx.Destroy()
				}
			}

			if( IsValid( ent ) )
			{
				ent.e.castleWallIsEnergized = false
			}
		}
	)

	//Add Duration to the Electric Charge. Need a SFX sound to indicate
	wait CastleWall_GetWallBarrierDuration( castle.GetOwner() ) - CASTLE_WALL_BARRIER_WARNING_DURATION

	//Begin Warning//
	if( !IsValid(ent) )
		return
	EmitSoundOnEntity( ent, CASTLE_WALL_BARRIER_END_WARNING_SOUND )

	wait CASTLE_WALL_BARRIER_WARNING_DURATION

}
#endif // SERVER

                    

const float INTERCEPT_RANGE_MAX 							= 200 //512 //128
const float INTERCEPT_RANGE_MIN 							= 64 //498
const float INTERCEPT_HEIGHT_MAX 							= 800 //512 //128
const float CASTLE_WALL_INTERCEPT_FWD_OFFSET 				= 200
const float CASTLE_WALL_INTERCEPT_Z_OFFSET 					= 50 //50
const float CASTLE_WALL_MAX_INTERCEPT_OFFSET 				= 100.0 //35
const float CASTLE_WALL_MAX_INTERCEPT_OFFSET_LOW 			= 50.0
const float CASTLE_WALL_MIN_INTERCEPT_DIST_TO_WALL 			= 30.0
const float CASTLE_WALL_INTERCEPT_OVERHEAD_MIN_HEIGHT 		= 120
const float CASTLE_WALL_INTERCEPT_OVERHEAD_MAX_BACK_DIST 	= 150
const float CASTLE_WALL_LOW_CENTER_OFFSET					= 15
const float CASTLE_WALL_MAIN_INTERCEPT_RANGE_EXTENTION		= 50

#if SERVER
void function CastleWall_InterceptProjectiles( entity player, entity castle, entity shieldAnchor )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	EndSignal( castle, "OnDestroy" )
	EndSignal( shieldAnchor, "CastleWall_BarrierDisrupted" )

	vector castleFwd 	= shieldAnchor.GetForwardVector()
	vector vortexOrigin = ( shieldAnchor.GetOrigin() - castleFwd * CASTLE_WALL_INTERCEPT_FWD_OFFSET ) + <0, 0, CASTLE_WALL_INTERCEPT_Z_OFFSET>

	#if DEV
	if ( DEBUG_DRAW_ANTI_GRENADE_DEBUG )
	{
		DebugDrawSphere( vortexOrigin, INTERCEPT_RANGE_MAX + INTERCEPT_RANGE_MIN , <255, 255, 100>, true, 10 )
	}
	#endif

	//------------------------------
	// Vortex to detect bullets, projectiles, and mortars entering our defensive perimiter.
	//------------------------------
	entity vortexSphere = CreateEntity( "vortex_sphere" )

	vortexSphere.kv.spawnflags = SF_BLOCK_OWNER_WEAPON
	vortexSphere.kv.enabled = 0
	vortexSphere.kv.radius = INTERCEPT_RANGE_MAX
	vortexSphere.kv.height = INTERCEPT_HEIGHT_MAX
	vortexSphere.kv.bullet_fov = 360
	vortexSphere.kv.physics_pull_strength = 0//25
	vortexSphere.kv.physics_side_dampening = 0//6
	vortexSphere.kv.physics_fov = 360
	vortexSphere.kv.physics_max_mass = 0//2
	vortexSphere.kv.physics_max_size = 0//6

	vortexSphere.SetAngles( <0, 0, 0> ) // viewvec?
	vortexSphere.SetOrigin( vortexOrigin )
	vortexSphere.SetMaxHealth( 100 )
	vortexSphere.SetHealth( 100 )

	DispatchSpawn( vortexSphere )

	if ( IsValid( player ) )
		AddToUltimateRealm( player, vortexSphere )

	if ( IsValid( castle ) )
		vortexSphere.SetOwner( castle )

	//HACK: Until we get a better way to do this use the vortex's target name to specify that it is a vortex trigger that
	//will run a set callback when a projectile or bullet hits it instead of preforming its normal vortex logic.
	Vortex_ConvertToVortexTriggerArea( vortexSphere )
	SetCallback_VortexSphereTriggerOnBulletHit( vortexSphere, CastleWall_OnBulletHitVortexTrigger )
	SetCallback_VortexSphereTriggerOnProjectileHit( vortexSphere, CastleWall_OnProjectileHitVortexTrigger )

	VortexFireEnable( vortexSphere )
	vortexSphere.SetInvulnerable()


	OnThreadEnd(
		function() : ( vortexSphere )
		{
			if ( IsValid( vortexSphere ) )
			{
				vortexSphere.Destroy()
			}
		}
	)

	wait CastleWall_GetWallBarrierDuration( player ) - 0.5 // - CASTLE_WALL_BARRIER_WARNING_DURATION
}

void function CastleWall_OnBulletHitVortexTrigger( entity weapon, entity vortexSphere, var damageInfo )
{
	//printt( "BULLET HIT VORTEX TRIGGER" )
	return
}

void function CastleWall_OnProjectileHitVortexTrigger( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	entity castle			= vortexSphere.GetOwner()
	if ( !IsValid( castle ) )
		return

	if ( !IsValid( projectile ) )
		return

	if ( !projectile.DoesShareRealms( castle ) )
		return

	//Don't destroy planted projectiles
	//if ( projectile.proj.isPlanted )
	//	return

	//printt( projectile.GetClassName() )
	//printt( projectile.ProjectileGetWeaponClassName() )

	//Get Closest Wall Segment
	entity closestWall = null
	float closestDist = INTERCEPT_RANGE_MAX

	if( castle in file.castleEntArray )
	{
		foreach ( wallEnt in file.castleEntArray[castle] )
		{
			if( !IsValid(wallEnt) )
				continue

			float distToWall = Distance2D( wallEnt.GetOrigin(), contactPos )
			//if( wallEnt == mainWall && distToWall < CASTLE_WALL_MAX_INTERCEPT_OFFSET + CASTLE_WALL_MAIN_INTERCEPT_RANGE_EXTENTION )
			if( wallEnt.GetTargetName() == ARMORED_LEAP_SHIELD_ANCHOR_CENTER && distToWall < CASTLE_WALL_MAX_INTERCEPT_OFFSET + CASTLE_WALL_MAIN_INTERCEPT_RANGE_EXTENTION )
			{
				//favor main wall if close enough && coming head-on
				vector velDir       = Normalize( projectile.GetVelocity() )
				vector dirToWall	= FlattenVec( velDir - wallEnt.GetOrigin() )
				vector wallDir		= Normalize( wallEnt.GetForwardVector() )
				float dotToWall	= DotProduct( velDir, FlattenVec( wallDir ) )

				if( dotToWall < -0.90 )
				{
					closestWall = wallEnt
					break
				}
			}

			if( distToWall < closestDist )
			{
				closestWall = wallEnt
				closestDist = distToWall
			}
		}
	}

	if( closestWall == null )
		return

	#if DEV
	if ( DEBUG_DRAW_ANTI_GRENADE_DEBUG )
	{
		DebugDrawSphere( closestWall.GetOrigin(), 30 , <255, 255, 255>, true, 5 )
	}
	#endif

	//Don't shoot down projectiles we aren't intended to target.
	if ( !CastleWall_ShouldTargetProjectile( closestWall, projectile, attacker, contactPos ) )
		return

	//If we can see the projectile, zap it.
	if ( CastleWall_HasLOSToTarget( closestWall, projectile, castle, contactPos ) )
	{
		projectile.RoundOriginAndAnglesToNearestNetworkValue()
		thread CastleWall_ZapProjectile( closestWall, projectile )
		int projectileTeam = projectile.GetTeam()
		projectile.Destroy()
	}
}

void function CastleWall_ZapProjectile( entity wallEnt, entity projectile )
{
	vector projectileOrigin = projectile.GetOrigin()
	vector wallOrigin = wallEnt.GetOrigin()
	vector velocity = projectile.GetVelocity()

	string targetName = wallEnt.GetTargetName()
	switch( targetName )
	{
		case ARMORED_LEAP_SHIELD_LOW_LEFT:
			wallOrigin = wallOrigin + wallEnt.GetRightVector() * -CASTLE_WALL_LOW_CENTER_OFFSET
		case ARMORED_LEAP_SHIELD_LOW_RIGHT:
			wallOrigin = wallOrigin + wallEnt.GetRightVector() * CASTLE_WALL_LOW_CENTER_OFFSET
			break
	}

	//vector zapOrigin = projectileOrigin + Normalize( velocity ) * 20 //make the zap seem like it comes from an invisible deflector shield rather than a specific location
	vector zapOrigin = wallOrigin + <0,0, CASTLE_WALL_INTERCEPT_Z_OFFSET > // make the zap come from the wall itself

	EmitSoundOnEntity( wallEnt, CASTLE_WALL_INTERCEPT_BEAM_SOUND )

	int team = wallEnt.GetTeam()

	//Without a unique "TargetName" - the vfx seems to just pick any other prop with that name to initiate from
	/////////////////////////////////////////////////////////
	entity fakeTag = CreateExpensiveScriptMover( zapOrigin, wallEnt.GetAngles() )
	fakeTag.SetParent( wallEnt )
	SetTargetName( fakeTag, UniqueString( "trophyTag" ) )

	//Ally VFX//
	entity allyBeamFX = CreateEntity( "info_particle_system" )
	allyBeamFX.kv.cpoint1 = fakeTag.GetTargetName()

	asset allyZapFX = CastleWall_GetZapFX( wallOrigin, projectile, false )

	allyBeamFX.SetValueForEffectNameKey( allyZapFX )
	allyBeamFX.kv.start_active = 1
	SetTeam( allyBeamFX, team )
	allyBeamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	allyBeamFX.SetOrigin( projectileOrigin )

	DispatchSpawn( allyBeamFX )

	//Enemy VFX//
	entity enemyBeamFX = CreateEntity( "info_particle_system" )
	enemyBeamFX.kv.cpoint1 = fakeTag.GetTargetName()

	asset enemyZapFX = CastleWall_GetZapFX( wallOrigin, projectile, true )

	enemyBeamFX.SetValueForEffectNameKey( enemyZapFX )
	enemyBeamFX.kv.start_active = 1
	SetTeam( enemyBeamFX, team )
	enemyBeamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	enemyBeamFX.SetOrigin( projectileOrigin )

	DispatchSpawn( enemyBeamFX )


	CopyRealmsFromTo( wallEnt, allyBeamFX )
	CopyRealmsFromTo( wallEnt, enemyBeamFX )

	string zapSound = CASTLE_WALL_INTERCEPT_SMALL
	EmitSoundAtPosition( TEAM_UNASSIGNED, projectile.GetOrigin(), zapSound, wallEnt )

	OnThreadEnd(
		function () : ( allyBeamFX, enemyBeamFX )
		{
			if ( IsValid( allyBeamFX ) )
				allyBeamFX.Destroy()

			if ( IsValid( enemyBeamFX ) )
				enemyBeamFX.Destroy()
		}
	)

	wait 0.3
}
#endif //SERVER

#if SERVER
asset function CastleWall_GetZapFX( vector wallOrigin, entity projectile, bool isEnemy = false )
{
	vector projectileOrigin = projectile.GetOrigin()
	float distSqr           = DistanceSqr( wallOrigin, projectileOrigin )
	float rngSqr 			= INTERCEPT_RANGE_MIN * INTERCEPT_RANGE_MAX

	asset zapEffect = isEnemy == true ? CASTLE_WALL_INTERCEPT_PROJECTILE_SMALL_ENEMY_FX : CASTLE_WALL_INTERCEPT_PROJECTILE_SMALL_FX

	if ( distSqr < rngSqr )
		return isEnemy == true ? CASTLE_WALL_INTERCEPT_PROJECTILE_CLOSE_ENEMY_FX : CASTLE_WALL_INTERCEPT_PROJECTILE_CLOSE_FX

	return zapEffect
}


bool function CastleWall_ShouldTargetProjectile( entity wallEnt, entity projectile, entity attacker, vector contactPos )
{

	var large = projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_intercept_large" )
	if ( large == "" || large == null )
		large = false

	if ( Trophy_ProjectileIsValidIgnoreType( projectile, wallEnt ) ) //todo: leaving for now - part of Wattson though...
		return false

	// if "large" (Gibraltar or Bangalore Ultimate missile), ignore - allow overheads to penetrate
	if ( large )
		return false // We only want to target throwable thingies here ->

	vector wallOrigin = wallEnt.GetOrigin()
	vector projectileOrigin = projectile.GetOrigin()
	vector velocity        = projectile.GetVelocity()
	vector velDir       = Normalize( projectile.GetVelocity() )
	vector trophyToProj = Normalize( wallOrigin - projectileOrigin )
	vector dirToWall	= FlattenVec( projectileOrigin - wallOrigin )
	vector wallDir		= Normalize( wallEnt.GetForwardVector() )

	float dotToWall	= DotProduct( velDir, FlattenVec( wallDir ) ) // Used to check that Projectile is headed towards wall
	float dotWallToProj	= DotProduct( trophyToProj, wallDir ) // Used to check that Projectile is not behind the wall

	float offset = CASTLE_WALL_MAX_INTERCEPT_OFFSET
	string targetName = wallEnt.GetTargetName()

	switch( targetName )
	{
		case ARMORED_LEAP_SHIELD_ANCHOR_CENTER:
			offset = CASTLE_WALL_MAX_INTERCEPT_OFFSET*2
			break
		case ARMORED_LEAP_SHIELD_LOW_LEFT:
			wallOrigin = wallOrigin + wallEnt.GetRightVector() * -CASTLE_WALL_LOW_CENTER_OFFSET
			offset = CASTLE_WALL_MAX_INTERCEPT_OFFSET_LOW
			break
		case ARMORED_LEAP_SHIELD_LOW_RIGHT:
			wallOrigin = wallOrigin + wallEnt.GetRightVector() * CASTLE_WALL_LOW_CENTER_OFFSET
			offset = CASTLE_WALL_MAX_INTERCEPT_OFFSET_LOW
			break
	}

	vector rDirA	= wallOrigin + wallEnt.GetRightVector() * offset
	vector rDirB	= wallOrigin + wallEnt.GetRightVector() * -offset
	//vector closestPoint 	= GetClosestPointOnLine( rDirA, rDirB, projectileOrigin )
	vector ornull closestPoint 	=  GetIntersectionOfLineAndPlane( projectileOrigin, projectileOrigin + FlattenVec( velDir ) * FLT_MAX, wallOrigin, wallDir )

	if( closestPoint == null )
		return false

	expect vector ( closestPoint )

	float rDist				= fabs( Distance2D( wallOrigin,  closestPoint ) )

	#if DEV
	if ( DEBUG_DRAW_ANTI_GRENADE_DEBUG )
	{
		//DebugDrawArrow( wallEnt.GetOrigin(), wallEnt.GetOrigin() + Normalize( dirToWall ) * 35, 10, <255, 150, 0>, false, 10 )
		//DebugDrawArrow( rDirA, rDirB, 10, <0, 0, 255>, false, 10 )

		//DebugDrawSphere( closestPoint, 3.0, <150, 0, 150>, true, 20.0 )
		DebugDrawLine( rDirA, rDirA + <0,0,100>, COLOR_BLUE, true, 20.0 )
		DebugDrawLine( rDirB, rDirB + <0,0,100>, COLOR_BLUE, true, 20.0 )
	}
	#endif

	//Check for Fail Cases
	if( dotToWall > 0.0 ) //same direction? We don't wanna zap you! -> return false
	{
			return false
	}
	else // going in the opposite direction -> we should probably zap! But slow down...
	{
		if( rDist > offset ) // Are we beyond the horizontal barrier limit?
			return false

		if ( dotWallToProj > 0.0 ) // Are we far BEHIND the wall already!? Don't be zappin' that dude!
		{
			float heightDiff = projectileOrigin.z - wallOrigin.z
			float distToWall = fabs( Distance2D( wallOrigin, projectileOrigin ) )
			if( !( velocity.z < 0 && heightDiff > CASTLE_WALL_INTERCEPT_OVERHEAD_MIN_HEIGHT && distToWall < CASTLE_WALL_INTERCEPT_OVERHEAD_MAX_BACK_DIST && dotToWall < -0.1 ) ) //Check if the trajectory down within wall range?
			{
				vector attackerDirToWall 	= FlattenNormalizeVec( wallOrigin - attacker.GetOrigin() )
				float dotAtkToWall 			= DotProduct( attackerDirToWall, wallDir )

				if( dotAtkToWall > 0 )
					return false
			}
		}
	}

	return true

}

bool function Trophy_ProjectileIsValidIgnoreType( entity projectile, entity trophy )
{
	var ignore = projectile.ProjectileGetWeaponInfoFileKeyField( "trophy_system_ignores" )
	if ( ignore == "" || ignore == null )
		ignore = "none"

	expect string(ignore)

	bool projectileTrophyFriendlyTeam = IsFriendlyTeam( projectile.GetTeam(), trophy.GetTeam() )

	if( projectileTrophyFriendlyTeam && !GetCurrentPlaylistVarBool( "newcastle_allow_friendly_intercepts", true ) )
		return true

	if ( eTrophySystemIgnores[ ignore ] == eTrophySystemIgnores.always
	|| 	( eTrophySystemIgnores[ ignore ] == eTrophySystemIgnores.friendlyOnly && projectileTrophyFriendlyTeam )
	|| 	( eTrophySystemIgnores[ ignore ] == eTrophySystemIgnores.enemyOnly && !projectileTrophyFriendlyTeam )
	)
	{
		return true
	}

	return false
}

bool function CastleWall_HasLOSToTarget( entity trophy, entity target, entity castle, vector contactPos )
{
	vector startOrigin = trophy.GetOrigin() + <0,0,CASTLE_WALL_INTERCEPT_Z_OFFSET>
	vector endOrigin   = contactPos

	array<entity> ignoreArray = ArmoredLeapIgnoreArray(castle)

	TraceResults results = TraceLineHighDetail( startOrigin, endOrigin, ignoreArray, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS, trophy )
	#if DEV
	if ( DEBUG_DRAW_ANTI_GRENADE_DEBUG )
	{
		DebugDrawLine( results.endPos, endOrigin, COLOR_RED, true, 20.0 )
		DebugDrawLine( startOrigin, results.endPos, COLOR_GREEN, true, 20.0 )
	}
	#endif

	if ( results.fraction >= 0.9 )
		return true

	return false
}

#endif //SERVER

      


//////////////////////////////////
///// Manual Wall Destroy ///////
/////////////////////////////////
bool function CastleWall_CanUse( entity player, entity ent, int useFlags )
{
	if ( ! IsValid( player ) )
		return false

	TraceResults viewTrace = GetViewTrace( player )

	int playerTeam = player.GetTeam()

	return IsFriendlyTeam( ent.GetTeam(), playerTeam ) &&
	viewTrace.hitEnt == ent &&
	SURVIVAL_PlayerAllowedToPickup( player ) &&
	! GradeFlagsHas( ent, eGradeFlags.IS_BUSY )
}

#if SERVER
void function CastleWall_TrackTimeSinceWallPickUp_Thread( entity player, entity castleWall )
{
	EndSignal( player, "OnDeath", "OnDestroy" )
	EndSignal( castleWall, "OnDestroy" )

	if( player in file.canDoWallRemoveChatter )
	{
		file.canDoWallRemoveChatter[ player ] <- false
	}

	OnThreadEnd(
		function () : ( player )
		{
			if( IsValid( player ) )
			{
				if( player in file.canDoWallRemoveChatter )
				{
					file.canDoWallRemoveChatter[ player ] <- true
				}
			}
		}
	)

	wait 5
}
#endif

#if SERVER
void function ClientCallback_TryPickupCastleWall( entity player, entity castleWall )
{
	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return

	if ( !IsValid( castleWall ) || castleWall.GetScriptName() != ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
		return

	if ( castleWall != player.GetUseEntity() )
		return

	if ( GradeFlagsHas( castleWall, eGradeFlags.IS_BUSY ) )
		return

	int playerTeam = player.GetTeam()
	if( !IsFriendlyTeam( castleWall.GetTeam(), playerTeam ) )
		return

	GradeFlagsSet( castleWall, eGradeFlags.IS_BUSY )

	if ( CastleWall_PickUp( player, castleWall ) )
	{
		entity wallOwner = castleWall.GetOwner()
		if( IsValid( wallOwner ) )
		{
			entity castleOwner = wallOwner.GetOwner()
			if( IsValid( castleOwner) && castleOwner == player )
			{
				if( !( player in file.canDoWallRemoveChatter ) )
				{
					file.canDoWallRemoveChatter[ player ] <- true
				}

				if ( file.canDoWallRemoveChatter[player] )
				{
					thread CastleWall_TrackTimeSinceWallPickUp_Thread( player, wallOwner )
					EmitSoundOnEntityToTeamExceptPlayer( castleOwner, CASTLE_WALL_REMOVED_CHATTER_VO_3P, castleOwner.GetTeam(), castleOwner )
					EmitSoundOnEntityOnlyToPlayer( castleOwner, castleOwner, CASTLE_WALL_REMOVED_CHATTER_VO_1P )
				}

			}
		}

		thread CastleWall_PlayPickupAnimAndDissolveAfter( castleWall )

	}
}

bool function CastleWall_PickUp( entity player, entity castleWall )
{

	int playerTeam = player.GetTeam()
	//printt( IsFriendlyTeam( castleWall.GetTeam(), playerTeam ) )
	if( !IsFriendlyTeam( castleWall.GetTeam(), playerTeam ) )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	//Don't allow the player to pick up walls if they are using a mounted turret.
	if ( MountedTurretPlaceable_IsUsingMountedTurret( player ) )
		return false

	return true
}

void function CastleWall_PlayPickupAnimAndDissolveAfter( entity castleWall )
{
	//waitthread PlayAnim( wall, "prop_rampart_wall_destroy" )

	if ( IsValid( castleWall ) )
	{
		entity castleParent = castleWall.GetParent()
		//printt( castleParent )
		if( IsValid(castleParent) )
		{
			if( castleParent.GetScriptName() == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
			{
				castleParent.Dissolve( ENTITY_DISSOLVE_CORE, ZERO_VECTOR, 500 )
				castleParent.Signal( "CastleWall_PickedUp" )
			}

		}

		EmitSoundAtPosition( TEAM_UNASSIGNED, castleWall.GetOrigin(), CASTLE_WALL_BARRIER_DISSOLVE_SOUND, castleWall )
		castleWall.NotSolid()
		castleWall.Dissolve( ENTITY_DISSOLVE_CORE, ZERO_VECTOR, 500 )
	}
	castleWall.Signal( "CastleWall_PickedUp" )
	wait 3

}
#endif


#if CLIENT
////COVER WALL PICKUP///
void function OnCharacterButtonPressed( entity player )
{
	entity useEnt = player.GetUsePromptEntity()
	if ( !IsValid( useEnt ) || useEnt.GetScriptName() != ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
		return

	int playerTeam = player.GetTeam()
	int entTeam = useEnt.GetTeam()

	if ( !IsFriendlyTeam( entTeam, playerTeam ) )
		return

	//float useTime = useEnt.GetCreationTime()
	CustomUsePrompt_SetLastUsedTime( Time() )

	Remote_ServerCallFunction( "ClientCallback_TryPickupCastleWall", useEnt )
}

void function CastleWall_OnPropScriptCreated( entity ent )
{
	if ( ent.GetScriptName() == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
	{
		AddEntityCallback_GetUseEntOverrideText( ent, CastleWall_UseTextOverride )
		AddCallback_OnUseEntity_ClientServer( ent, CastleWall_OnUseWall )

		int shieldTeam = ent.GetTeam()

		bool startThreatIndicatorThread = false

		if ( !( shieldTeam in file.castleWallEnts ) )
		{
			startThreatIndicatorThread = true
			CastleWallEntityData data

			file.castleWallEnts[shieldTeam] <- data
		}

		switch( ent.GetTargetName() )
		{
			case ARMORED_LEAP_SHIELD_ANCHOR_LEFT:
				file.castleWallEnts[shieldTeam].anchorLeft = ent
				break
			case ARMORED_LEAP_SHIELD_ANCHOR_CENTER:
				file.castleWallEnts[shieldTeam].anchorCenter = ent
				break
			case ARMORED_LEAP_SHIELD_ANCHOR_RIGHT:
				file.castleWallEnts[shieldTeam].anchorRight = ent
				break
			case ARMORED_LEAP_SHIELD_LOW_LEFT:
				file.castleWallEnts[shieldTeam].lowWallsLeft.append( ent )
				break
			case ARMORED_LEAP_SHIELD_LOW_RIGHT:
				file.castleWallEnts[shieldTeam].lowWallsRight.append( ent )
				break
			default:
				break
		}

		ent.e.castleWallIsEnergized = true
		thread TrackCastleWallEnergizedState_Thread( ent )

		if ( startThreatIndicatorThread )
		{
			thread DoCastleWallThreatIndicatorAndSound_Thread( GetLocalViewPlayer(), shieldTeam, CASTLE_WALL_WARNING_RADIUS, ent )
		}
	}
}

void function CastleWall_OnUseWall( entity wallProxy, entity player, int useFlags )
{
	if ( IsControllerModeActive() )
	{
		if ( !IsBitFlagSet( useFlags, USE_INPUT_LONG ) )
		{
			thread IssueReloadCommand( player )
		}
	}
}

void function TrackCastleWallEnergizedState_Thread( entity ent )
{
	EndSignal( ent, "OnDestroy" )

	OnThreadEnd(
		function() : ( ent )
		{
			if ( IsValid( ent ) )
				ent.e.castleWallIsEnergized = false
		}
	)

	// owner can be null on the client, if it is use the linked ent instead
	entity owner = ent.GetOwner()
	if( !IsValid( owner ) )
		owner = ent.GetLinkEnt()
	float endTime                    = Time() + CastleWall_GetWallBarrierDuration( ent.GetOwner() ) + file.barrierDelay //adding the barrier delay time to the total time
	while ( Time() < endTime )
	{
		WaitFrame()
	}
}

void function CastleWall_OnPropScriptDestroyed( entity ent )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetScriptName() == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
	{
		CustomUsePrompt_ClearForEntity( ent )
	}
}

string function CastleWall_UseTextOverride( entity ent )
{
	entity player = GetLocalViewPlayer()
	int playerTeam = player.GetTeam()

	if ( !CastleWall_CanUse( player, ent, USE_FLAG_NONE ) )
	{
		CustomUsePrompt_Hide()

		if( ent in file.castleWallHighlightFocus )
			delete file.castleWallHighlightFocus[ent]
	}
	else if ( IsFriendlyTeam( ent.GetTeam(), playerTeam ) )
	{
		CustomUsePrompt_Show( ent )
		CustomUsePrompt_SetSourcePos( ent.GetOrigin() + < 0, 0, -5 > )

		CustomUsePrompt_SetText( Localize("#NEWCASTLE_CASTLE_WALL_DYNAMIC_DESTROY") )
		//CustomUsePrompt_SetHintImage( $"rui/hud/character_abilities/rampart_cover_destroy" )
		CustomUsePrompt_SetHintImage( $"" )
		CustomUsePrompt_SetLineColor( <1.0, 0.5, 0.0> )

		file.castleWallHighlightFocus[ ent ] <- true

		if ( PlayerIsInADS( player ) )
			CustomUsePrompt_ShowSourcePos( false )
		else
			CustomUsePrompt_ShowSourcePos( true )
	}

	ManageHighlightEntity( ent )
	return ""
}
#endif //CLIENT

bool function CastleWall_EntityShouldBeHighlighted( entity target )
{
	#if CLIENT
		if( !IsValid(target) )
			return false

		if ( (target in file.castleWallHighlightFocus) )
		{
			if ( file.castleWallHighlightFocus[ target ] )
				return true
		}
	#endif

	return false
}

#if CLIENT
void function CastleWall_OnGainFocus( entity ent )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetScriptName() == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
	{
		CustomUsePrompt_Show( ent )
	}
}

void function CastleWall_OnLoseFocus( entity ent )
{
	if ( IsValid( ent ) )
	{
		if ( ent.GetScriptName() == ARMORED_LEAP_SHIELD_ANCHOR_SCRIPTNAME )
		{
			if( ent in file.castleWallHighlightFocus )
				delete file.castleWallHighlightFocus[ent]

			ManageHighlightEntity( ent )
		}
	}

	CustomUsePrompt_ClearForAny()
}
#endif //CLIENT

#if CLIENT
void function AddImpactZoneThreatIndicator( entity impactMarker )
{
	entity player = GetLocalViewPlayer()
	int team = player.GetTeam()
	int markerTeam = impactMarker.GetTeam()

	if( IsEnemyTeam( team, markerTeam ) )
		ShowGrenadeArrow( player, impactMarker, ARMORED_LEAP_IMPACT_RANGE, 0.0, true, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ALL, <0, 0, 0>, true )
}
#endif

#if CLIENT
//The idea here is that this thread on the client side will dynamically handle the threat indicator and electricity sounds.
//-"close" entity that goes to the closest position along a series of lines connecting the centre point of all active/alive wall segments.  We show the threat indicator from here and play the ambient sound.
//-"far" entity, that goes to the farthest position along a series of lines connecting the centre point of all active/alive wall segments. We only play the ambient sound from here.
//This was done to cut down on having ambient generics spawning for every trigger (and repeating the same sound).  Wanted to have the "far" one so that if the wall gets split, you wouldn't just hear electricty coming from the closest panel (you'd still hear it coming from the other side as well)
void function DoCastleWallThreatIndicatorAndSound_Thread( entity player, int shieldTeam, float warningRadius, entity ent )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy" )

	// owner can be null on the client, if it is use the linked ent instead
	entity owner = ent.GetOwner()
	if( !IsValid( owner ) )
		owner = ent.GetLinkEnt()
	float endTime                    = Time() + CastleWall_GetWallBarrierDuration( owner )
	vector ornull closestProjection  = GetProjectionForCastleThreat( player, shieldTeam, true )
	vector ornull farthestProjection = GetProjectionForCastleThreat( player, shieldTeam, false )
	vector startingPosClose          = ZERO_VECTOR
	vector startingPosFar			 = ZERO_VECTOR
	bool doClosestPositionActions
	bool doFarthestPositionActions

	if ( closestProjection != null )
	{
		startingPosClose         = expect vector( closestProjection )
		doClosestPositionActions = true
	}
	else
	{
		doClosestPositionActions = false
	}

	if ( farthestProjection != null )
	{
		startingPosFar         = expect vector( closestProjection )
		doFarthestPositionActions = true
	}
	else
	{
		doFarthestPositionActions = false
	}

	entity closestPositionEnt  = CreateClientSidePropDynamic( startingPosClose, <0,0,0>, $"mdl/dev/empty_model.rmdl" )
	closestPositionEnt.SetScriptName( CASTLE_WALL_THREAT_TARGETNAME )
	entity farthestPositionEnt = CreateClientSidePropDynamic( startingPosFar, <0,0,0>, $"mdl/dev/empty_model.rmdl" )

	if ( !doClosestPositionActions )
	{
		closestPositionEnt.Hide()
	}

	if ( !doFarthestPositionActions )
	{
		farthestPositionEnt.Hide()
	}

	OnThreadEnd(
		function() : ( closestPositionEnt, farthestPositionEnt, shieldTeam )
		{
			if ( IsValid( closestPositionEnt ) )
			{
				StopSoundOnEntityByName( closestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
				closestPositionEnt.Destroy()
			}

			if ( IsValid( farthestPositionEnt ) )
			{
				StopSoundOnEntityByName( farthestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
				farthestPositionEnt.Destroy()
			}

			if ( shieldTeam in file.castleWallEnts )
			{
				delete file.castleWallEnts[shieldTeam]
			}
		}
	)

	if ( IsEnemyTeam( GetLocalViewPlayer().GetTeam(), shieldTeam ) )
	{
		ShowGrenadeArrow( player, closestPositionEnt, warningRadius, 0.0, true, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ALL, <0, 0, 0>, true )
	}

	float barrierDelayTime = Time() + file.barrierDelay
	bool wallEnergized = false

	while ( Time() < endTime )
	{
		vector ornull newClosestProjection = GetProjectionForCastleThreat( player, shieldTeam, true )
		vector ornull newFarthestProjection = GetProjectionForCastleThreat( player, shieldTeam, false )

		//We now wait for the energizing delay to complete before adding audio//
		if( Time() > barrierDelayTime && !wallEnergized )
		{
			if( IsValid( closestPositionEnt ) )
				EmitSoundOnEntity( closestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
			if( IsValid ( farthestPositionEnt ) )
				EmitSoundOnEntity( farthestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )

			if ( !doClosestPositionActions )
				StopSoundOnEntityByName( closestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
			if ( !doFarthestPositionActions )
				StopSoundOnEntityByName( closestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )

			wallEnergized = true
		}

		if ( newClosestProjection != null )
		{
			if ( !doClosestPositionActions )
			{
				closestPositionEnt.Show()
				doClosestPositionActions = true
				if( wallEnergized )
					EmitSoundOnEntity( closestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
			}

			closestPositionEnt.SetOrigin( expect vector ( newClosestProjection ) )
		}
		else
		{
			if ( doClosestPositionActions )
			{
				closestPositionEnt.Hide()
				StopSoundOnEntityByName( closestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
				doClosestPositionActions = false
			}
		}

		if ( newFarthestProjection != null )
		{
			if ( !doFarthestPositionActions )
			{
				farthestPositionEnt.Show()
				doFarthestPositionActions = true
				if( wallEnergized )
					EmitSoundOnEntity( farthestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
			}

			farthestPositionEnt.SetOrigin( expect vector ( newFarthestProjection ) )
		}
		else
		{
			if ( doFarthestPositionActions )
			{
				farthestPositionEnt.Hide()
				StopSoundOnEntityByName( farthestPositionEnt, CASTLE_WALL_BARRIER_ACTIVE_LOOP_SOUND )
				doFarthestPositionActions = false
			}
		}

		#if DEV
		if ( DEBUG_THREAT_INDICATORS )
		{
			DebugDrawMark( closestPositionEnt.GetOrigin(), 20, COLOR_RED, true, 0.1 )
			DebugDrawMark( farthestPositionEnt.GetOrigin(), 10, COLOR_BLUE, true, 0.1 )
		}
		#endif //DEV

		WaitFrame()
	}
}

vector ornull function GetProjectionForCastleThreat( entity player, int shieldTeam, bool findClosest )
{
	vector ornull bestPos   = null
	float bestDistanceFound = findClosest ? FLT_MAX : 0.0

	if ( ( shieldTeam in file.castleWallEnts ) )
	{
		//center to left
		array<CastleWallThreatIndicatorLine> leftToCenterLines = BuildThreatLines( file.castleWallEnts[shieldTeam].anchorCenter, file.castleWallEnts[shieldTeam].lowWallsLeft, file.castleWallEnts[shieldTeam].anchorLeft )
		//enter to right
		array<CastleWallThreatIndicatorLine> centerToRightLines = BuildThreatLines( file.castleWallEnts[shieldTeam].anchorCenter, file.castleWallEnts[shieldTeam].lowWallsRight, file.castleWallEnts[shieldTeam].anchorRight )

		//consolidate all lines into one array to evaluate
		leftToCenterLines.extend( centerToRightLines )

		foreach ( CastleWallThreatIndicatorLine line in leftToCenterLines )
		{
			vector projection = GetClosestPointOnLineSegment( line.startPos, line.endPos, player.EyePosition() )
			float distance = Distance( player.EyePosition(), projection )

			if ( findClosest )
			{
				if ( distance < bestDistanceFound )
				{
					bestPos           = projection
					bestDistanceFound = distance
				}
			}
			else
			{
				if ( distance > bestDistanceFound )
				{
					bestPos           = projection
					bestDistanceFound = distance
				}
			}
		}
	}

	return bestPos
}

array<CastleWallThreatIndicatorLine> function BuildThreatLines( entity startingAnchor, array<entity> middleWalls, entity endingAnchor )
{
	array<CastleWallThreatIndicatorLine> results
	array<entity> allWalls
	const float indicatorForwardOffset = 10.0

	allWalls.append( startingAnchor )
	allWalls.extend( middleWalls )
	allWalls.append( endingAnchor )

	for ( int i = 1; i < allWalls.len(); i++ )
	{
		CastleWallThreatIndicatorLine line
		vector startPos
		vector endPos

		bool validCurrent   = IsValid( allWalls[i] )
		bool validPrevious  = IsValid( allWalls[i - 1] )
		bool validLineFound = false

		if ( validCurrent && validPrevious )
		{
			startPos       = allWalls[i - 1].GetWorldSpaceCenter() + ( allWalls[i - 1].GetForwardVector() * indicatorForwardOffset )
			endPos         = allWalls[i].GetWorldSpaceCenter() + ( allWalls[i].GetForwardVector() * indicatorForwardOffset )
			validLineFound = true
		}
		else if ( validCurrent && !validPrevious )
		{
			startPos       = allWalls[i].GetWorldSpaceCenter() + ( allWalls[i].GetForwardVector() * indicatorForwardOffset )
			endPos         = allWalls[i].GetWorldSpaceCenter() + ( allWalls[i].GetForwardVector() * indicatorForwardOffset )
			validLineFound = true
		}
		else if ( validPrevious && !validCurrent )
		{
			startPos       = allWalls[i - 1].GetWorldSpaceCenter() + ( allWalls[i - 1].GetForwardVector() * indicatorForwardOffset )
			endPos         = allWalls[i - 1].GetWorldSpaceCenter() + ( allWalls[i - 1].GetForwardVector() * indicatorForwardOffset )
			validLineFound = true
		}

		if ( validLineFound )
		{
			line.startPos = startPos
			line.endPos = endPos
			results.append( line )

			#if DEV
			if ( DEBUG_THREAT_INDICATORS )
			{
				 DebugDrawArrow( line.startPos, line.endPos, 10, COLOR_GREEN, true, 0.1 )
			}
			#endif //DEV
		}
	}

	return results
}
#endif //CLIENT

//Remove 4 of the extra panels that are covered by the anchors.
bool function GetArmoredLeapUseReducedEntCount()
{
	return GetCurrentPlaylistVarBool( "newcastle_ult_reduce_ents", true )
}

//Use code based ultimate movement instead of script.
bool function GetArmoredLeapUseCode()
{
	return GetCurrentPlaylistVarBool( "newcastle_ult_code", true )
}

//Do additional checks for airpos.  This only runs on server when we go to launch the ability, will result in less cases of NC getting "stuck" as original script checks can choose paths that fail the block checks in code.
bool function DoAdditionalAirPosChecks()
{
	return GetCurrentPlaylistVarBool( "newcastle_ult_additional_air_pos_checks", true )
} 