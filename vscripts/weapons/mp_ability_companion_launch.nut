global function Companion_Launch_Init
global function OnWeaponActivate_companion_launch
global function OnWeaponDeactivate_companion_launch
global function OnWeaponPrimaryAttack_companion_launch
global function OnWeaponPrimaryAttackAnimEvent_companion_launch
//global function OnWeaponChargeLevelIncreased_companion_launch
global function OnWeaponAttemptOffhandSwitch_companion_launch
#if CLIENT
global function OnClientAnimEvent_companion_launch
#endif

global function CanLaunchToCompanion

#if SERVER
global function ClientToServer_AttemptCancelLaunch
#endif

global function CodeCallback_OnJetDriveStart
global function CodeCallback_OnJetDriveDoubleJump
global function CodeCallback_OnJetDriveWindowBegin
global function CodeCallback_OnJetDriveDuckCancel
global function CodeCallback_OnJetDrivePlayerStuck

////////////////////////////////////////////////

// Sound
const string JET_DRIVE_PRELAUNCH_BUILDUP_1P = "vantage_tac_buildup_1p"
const string JET_DRIVE_PRELAUNCH_BUILDUP_3P = "vantage_tac_buildup_3p"
const string JET_DRIVE_PRELAUNCH_BUILDUP_ABORT_1P = "Vantage_Tac_BuildupAbort_1p"
const string JET_DRIVE_PRELAUNCH_BUILTUP_WRIST_ABORT_1P = "Vantage_Tac_BuildupWristAbort_1p"
const string JET_DRIVE_PRELAUNCH_BUILDUP_ABORT_3P = "Vantage_Tac_BuildupAbort_3p"
const string JET_DRIVE_LAUNCH_1P = "vantage_tac_launch_1p"
const string JET_DRIVE_LAUNCH_3P = "vantage_tac_launch_3p"
const string JET_DRIVE_DOUBLE_JUMP_1P = "vantage_tac_launchdoublejump_1p"
const string JET_DRIVE_DOUBLE_JUMP_3P = "vantage_tac_launchdoublejump_3p"
const string JET_DRIVE_LAUNCH_ECHO_VOICE = "Vantage_Tac_Echo_Voice_JetPack"
const string JET_DRIVE_DEPLOY_ECHO_VOICE = "vantage_tac_draw"
const string JET_DRIVE_DEPLOY_ECHO_VOICE_3P = "vantage_tac_draw_3p"

const string JET_DRIVE_LAUNCH_CANCEL_1P = "vantage_tac_launchabort_1p"
const string JET_DRIVE_LAUNCH_CANCEL_3P = "vantage_tac_launchabort_3p"
const string ECHO_FIRST_DEPLOY_DIAG = "diag_mp_vantage_bc_tacticalfirst_1p"

const string JET_DRIVE_LAUNCH_END_1P = "vantage_tac_launchend_1p"
const string JET_DRIVE_LAUNCH_END_3P = "vantage_tac_launchend_3p"
const string JET_DRIVE_JUMP_WINDOW_SOUND_1P = "vantage_tac_doublejumpavailable_1p"

// FX
const JET_DRIVE_PRE_LAUNCH_FX = $"P_Vantage_thrusters_prelaunch" //"P_valk_launch_eng"
const JET_DRIVE_LAUNCH_FX = $"P_Vantage_thrusters_launch" //"P_valk_launch_eng"
const JET_DRIVE_DOUBLE_JUMP_FX = $"P_Vantage_thrusters_jump" //"P_valk_launch_eng"
const JET_DRIVE_SCREEN_FX = $"P_van_tac_launch_screen"

const string TAKE_OFF_IMPACT_FX_TABLE = "pilot_bodyslam"

//Mods
const string IS_LAUNCHING_MOD = "vantage_is_launching_mod"
const string IS_LAUNCHING_ONEHAND_MOD = "vantage_is_launching_onehand_mod"
const string FAILED_LOS_MOD = "vantage_failed_los_mod"
const string FROM_PERCHED_MOD = "vantage_from_perched_mod"

const string WHISTLE_FWD_MOD = "vantage_whistle_fwd"
const string WHISTLE_BACK_MOD = "vantage_whistle_back"
const string WHISTLE_LEFT_MOD = "vantage_whistle_left"
const string WHISTLE_RIGHT_MOD = "vantage_whistle_right"
const string CAN_INTERRUPT_MOD = "vantage_can_interrupt"

const string JET_DRIVE_DOUBLE_JUMP_HINT_STRING = "#JUMP_PAD_DOUBLE_JUMP_HINT"

//Tuning


const float LAUNCH_TARGET_UP_OFFSET = -1.75 * METERS_TO_INCHES
const float LAUNCH_TARGET_FWD_OFFSET = 0 * METERS_TO_INCHES

const float JET_DRIVE_DEPLOY_WEAPONS_TIME = 0.5

const bool JET_DRIVE_PATH_TRAVEL_VERSION = true
const float JET_DRIVE_PATH_ACCEL = 40 * METERS_TO_INCHES
const float JET_DRIVE_PATH_SPEED = 20 * METERS_TO_INCHES
const float JET_DRIVE_PATH_SPEED_MIN = 2 * METERS_TO_INCHES
const float JET_DRIVE_PATH_DECEL_FRAC = 0.2

const float JET_DRIVE_PATH_DECEL_DIST = 5 * METERS_TO_INCHES
const float JET_DRIVE_PATH_POINT_PROX = 3 * METERS_TO_INCHES

const vector JET_DRIVE_DOUBLE_JUMP_VEL = < 13 * METERS_TO_INCHES, 0, 10 * METERS_TO_INCHES > // <Forwards, (no side), and Up>
const float JET_DRIVE_DOUBLE_JUMP_BACK_VEL_FRAC = 0.5 //The amount the double jump velocity is cut down when jumping back the way you came.
                    
const vector JET_DRIVE_DOUBLE_JUMP_VEL_UPGRADE = < 14 * METERS_TO_INCHES, 0, 12 * METERS_TO_INCHES >
const float JET_DRIVE_DOUBLE_JUMP_BACK_VEL_FRAC_UPGRADE = 0.8
      

global const vector ECHO_INITIAL_DEPLOY_OFFSET = <30, -15, 80>


global function DoMoreEchoTraces
bool ECHO_DO_ADDITIONAL_VIS_TRACES = true

//Debug
const bool JET_DRIVE_DEBUG_DRAW = false
const bool JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS = false
const bool JET_DRIVE_DEBUG_DRAW_TRAVEL_PATH = false

const int JET_DRIVE_DISABLE_WEAPON_TYPES = WPT_ALL_EXCEPT_VIEWHANDS_OR_INCAP & ~WPT_TACTICAL

struct
{
	table<entity, bool> isButtonHeld
	table<entity, string> cachedLastWeaponName
	table<entity, vector> cachedOrderPos
} file

global enum eCanLaunchResult
{
	SUCCESS,
	INVALID,
	PLAYER_STATE
	NO_OFF_SCREEN,
	NO_LOS_FAIL
}

global const string  VANTAGE_COMPANION_LAUNCH_WEAPON_NAME = "mp_ability_companion_launch"


void function DoMoreEchoTraces( bool val )
{
	ECHO_DO_ADDITIONAL_VIS_TRACES = val
}


void function Companion_Launch_Init()
{
	PrecacheWeapon( VANTAGE_COMPANION_LAUNCH_WEAPON_NAME )

	PrecacheParticleSystem( JET_DRIVE_PRE_LAUNCH_FX )
	PrecacheParticleSystem( JET_DRIVE_LAUNCH_FX )
	PrecacheParticleSystem( JET_DRIVE_DOUBLE_JUMP_FX )
	PrecacheParticleSystem( JET_DRIVE_SCREEN_FX )
	PrecacheImpactEffectTable( TAKE_OFF_IMPACT_FX_TABLE )

	RegisterSignal( "VantageLaunched_Signal" )
	RegisterSignal( "JetDrive_EndPrelaunch" )
	RegisterSignal( "Vantage_RemoveAllTacMods" )

	AddCallback_OnPassiveChanged( ePassives.PAS_VANTAGE, OnPassiveChangedVantageCompanionLaunch )

	//Cancel logic
                      
           
                                                                           
                                                                     
       

                                                                      
       
}

void function OnPassiveChangedVantageCompanionLaunch( entity player, int passive, bool didHave, bool nowHas )
{
	#if CLIENT
		if ( !IsValid( GetLocalClientPlayer() ) || player != GetLocalClientPlayer() )
			return
	#endif

	if ( didHave && !nowHas )
	{
		#if SERVER
			entity weapon = player.GetOffhandWeapon( OFFHAND_RIGHT )

			if ( IsValid( weapon ) && weapon.GetWeaponClassName() == VANTAGE_COMPANION_LAUNCH_WEAPON_NAME )
			{
				player.TakeOffhandWeapon( OFFHAND_RIGHT )
			}
		#endif
	}
	else if ( nowHas && !didHave )
	{
		#if SERVER
			entity weapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
			if ( IsValid( weapon ))
			{
				player.TakeOffhandWeapon( OFFHAND_RIGHT )
			}
			player.GiveOffhandWeapon( VANTAGE_COMPANION_LAUNCH_WEAPON_NAME, OFFHAND_RIGHT, [] )
		#endif
	}
}

bool function OnWeaponAttemptOffhandSwitch_companion_launch( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return false

	//if ( player.IsInputCommandHeld( IN_PING ) )
	//	return false

	if ( player.IsInputCommandHeld( IN_PING ) || player.IsInputCommandPressed( IN_PING ) )
	{
		//printt( "VANTAGE TAC CANCELLED - OffhandSwitch" )
		return false
	}

	if ( VantageCompanion_GetPlayerLaunchState( player ) != ePlayerLaunchState.NONE )
		return false

	return true
}

void function OnWeaponActivate_companion_launch( entity weapon )
{
	#if CLIENT
		//if ( weapon.GetOwner() != GetLocalViewPlayer() || weapon.GetOwner() != GetLocalClientPlayer() )
		//	return
	#endif

	if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
		printt( "VANTAGE TAC: Activate -----------------------------------" )

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return
		
	VantageCompanion_SetPlayerLaunchState( player, ePlayerLaunchState.NONE )
	RemoveAllTacMods( weapon )

	int companionState = player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT )

	if ( companionState == eCompanionState.PERCHED )
	{
	#if CLIENT
		if ( InPrediction() )
	#endif // CLIENT
			weapon.AddMod( FROM_PERCHED_MOD )
	}

	thread CheckForHoldInput_Thread( player, weapon )
}


var function OnWeaponPrimaryAttack_companion_launch( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	Assert( player.IsPlayer() )

	entity tacWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	int ammoReq  = tacWeapon.GetAmmoPerShot()
	int currAmmo = tacWeapon.GetWeaponPrimaryClipCount()
	int ammoUsed = -1

	if ( player.IsInputCommandHeld( IN_PING ) || player.IsInputCommandPressed( IN_PING ) )
	{
		//printt( "VANTAGE TAC CANCELLED - CL PRIMARY" )
		return 0
	}

	int companionState = player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT )
	if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
		printt( "VANTAGE TAC: PRIMATK" )

#if CLIENT
	if ( companionState == eCompanionState.PERCHED )
	{
		entity localClient = GetLocalClientPlayer()
		entity localView = GetLocalViewPlayer()
		if ( player == GetLocalViewPlayer() )
		{
			entity companionEnt = VantageCompanion_GetEnt( player )

			if ( IsValid( companionEnt ) )
			{
				EmitSoundOnEntity( companionEnt, JET_DRIVE_DEPLOY_ECHO_VOICE )
			}
		}
	}
#endif

	if ( (player in file.isButtonHeld) && file.isButtonHeld[player] == true )//weapon.HasMod( IS_LAUNCHING_MOD ) )
	{
		if ( currAmmo >= ammoReq )
		{
			RemoveAllTacMods( weapon )
			#if CLIENT
				if ( InPrediction() )
			#endif // CLIENT
				AddLaunchingMod( player, weapon ) //weapon.AddMod( IS_LAUNCHING_MOD )

			if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
				printt( "--VANTAGE TAC: PRIMATK PRE LAUNCH" )

			if ( companionState == eCompanionState.PERCHED )
			{
				if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
					printt( "---VANTAGE TAC: PRIMATK PERCHED ORDER" )
				//If companion is perched then lets get it out in preparation for launch
				VantageCompanion_OrderCompanion( player )
				#if SERVER
				VantageCompanion_ShowAndSetToShoulder( player )
				#endif
			}

			entity mainHandWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			if ( IsValid( mainHandWeapon) )
			{
				if ( !IsBitFlagSet( mainHandWeapon.GetWeaponTypeFlags(), WPT_ULTIMATE ) )
					file.cachedLastWeaponName[player] <- mainHandWeapon.GetWeaponClassName()

				if ( !IsBitFlagSet( mainHandWeapon.GetWeaponTypeFlags(), WPT_VIEWHANDS ) )
				{
					//We're going to be using both hands to do our jump, get the weapon down ASAP (feels like a magic 3rd hand is holstering it, hide this as best we can.)
					//mainHandWeapon.FastHolster()
				}
			}

			//Vantage will launch

			thread PreLaunch_Thread( player )
		}
		else
		{
			#if CLIENT
			AddPlayerHint( 2.0, 0.25, $"", "#TAC_NO_AMMO" )
			#endif
			weapon.DoDryfire()
			//We use the perch mod to show the on cooldown wrist graphic
			RemoveAllTacMods( weapon )
			weapon.AddMod( FROM_PERCHED_MOD )
			ammoUsed = 0 //This means we wont continue
		}
	}
	else //if ( currAmmo < ammoReq )
	{
		if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
			printt( "--VANTAGE TAC: PRIMATK REG CACHE ORDER" )

		//printt( "Ping held: " + player.IsInputCommandHeld( IN_PING ) + " Ping pressed: " + player.IsInputCommandPressed( IN_PING ) )
		#if CLIENT
		if ( InPrediction() && IsFirstTimePredicted() )
		{
		#endif // CLIENT
			file.cachedOrderPos[player] <- VantageCompanion_FindAndDisplayOrderPos( player )
			if ( companionState != eCompanionState.PERCHED )
			{
				RemoveAllTacMods( weapon )

				entity companionEnt = VantageCompanion_GetEnt( player )
				vector toEcho = FlattenNormalizeVec(companionEnt.GetOrigin() - player.GetOrigin())
				vector toEchoLeft = CrossProduct(toEcho, UP_VECTOR )

				// DebugDrawArrow( companionEnt.GetOrigin(), companionEnt.GetOrigin() + 30*toEcho, 10, COLOR_GREEN, false, 5.0 )
				//DebugDrawArrow( companionEnt.GetOrigin(), companionEnt.GetOrigin() + 30*toEchoLeft, 10, <0,50,255>, false, 5.0 )
				vector echoToOrderPos = FlattenNormalizeVec(file.cachedOrderPos[player] - companionEnt.GetOrigin() )
				float dot = DotProduct( toEcho, echoToOrderPos )

				if ( dot >= DOT_45DEGREE )
				{
					//printt("Whistle Ahead")
					weapon.AddMod( WHISTLE_FWD_MOD )
				}
				//else if ( dot <= -DOT_45DEGREE )
				//{
				//	//printt("Whistle Back")
				//	weapon.AddMod( WHISTLE_BACK_MOD )
				//}
				else
				{
					float leftDot = DotProduct( toEchoLeft, echoToOrderPos )
					if ( leftDot <= 0 )
					{
						//printt("Whistle RIGHT")
						weapon.AddMod( WHISTLE_RIGHT_MOD )
					}
					else
					{
						//printt("Whistle LEFT")
						weapon.AddMod( WHISTLE_LEFT_MOD )
					}
				}
				//}
			}
#if CLIENT
		}
#endif

	}

	return ammoUsed
}

void function AddLaunchingMod( entity player, entity weapon )
{
	//If heirloom/artifact
	string modToAdd = IS_LAUNCHING_MOD
	if ( IsMeleeWeaponNotFists( player ) )
		modToAdd = IS_LAUNCHING_ONEHAND_MOD

	weapon.AddMod( modToAdd )
}

vector function GetInitialDeployPos( entity player )
{
	vector initialDeploy = player.EyePosition() + (player.GetViewForward() * ECHO_INITIAL_DEPLOY_OFFSET.x)
												+ (player.GetViewRight() * ECHO_INITIAL_DEPLOY_OFFSET.y)
												+ (player.GetViewUp() * ECHO_INITIAL_DEPLOY_OFFSET.z)
	return initialDeploy
}

var function OnWeaponPrimaryAttackAnimEvent_companion_launch( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	Assert( player.IsPlayer() )

	if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
		printt( "VANTAGE TAC: ATK ANIM , Launch state: "+ VantageCompanion_GetPlayerLaunchState( player ) )

	int playerLaunchState = VantageCompanion_GetPlayerLaunchState( player )
	if ( playerLaunchState != ePlayerLaunchState.NONE )
	{
		player.Signal( "JetDrive_EndPrelaunch" )
#if SERVER
		entity companionEnt = VantageCompanion_GetEnt(player)
		if ( IsValid( companionEnt ) )
		{
			entity tacWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
			int canLaunch = CanLaunchToCompanion ( player, companionEnt )
			int ammoReq  = tacWeapon.GetAmmoPerShot()
			int currAmmo = tacWeapon.GetWeaponPrimaryClipCount()
			bool hasAmmo  = currAmmo >= ammoReq

			if ( canLaunch == eCanLaunchResult.SUCCESS && hasAmmo )
			{
				if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
					printt( "--VANTAGE TAC: ATK ANIM LAUNCH" )

				thread JetDrive_Thread( player, companionEnt )

				int newAmmo = currAmmo - ammoReq
				tacWeapon.SetWeaponPrimaryClipCount( newAmmo )

				player.Signal( "VantageLaunched_Signal" )
				PlayerUsedOffhand( player, tacWeapon )
			}
			else
			{
				if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
					printt( "--VANTAGE TAC: FAILED_LOS_MOD" )

				RemoveAllTacMods( weapon )
				weapon.AddMod( FAILED_LOS_MOD )

				//weapon.Holster()

				StopSoundOnEntity( player, JET_DRIVE_LAUNCH_1P )
				EmitSoundOnEntityExceptToPlayer( player, player, JET_DRIVE_PRELAUNCH_BUILDUP_ABORT_3P )

				if ( player in file.cachedLastWeaponName )
				{
					player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, file.cachedLastWeaponName[player] )
				}

				if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
					printt( "--VANTAGE TAC: ATK ANIM NO LOS" )
			}
		}
		#endif
	}
	else
	{
		if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
			printt( "--VANTAGE TAC: ATK ANIM REG SEND ORDER" )

		//printt( "Ping held: " + player.IsInputCommandHeld( IN_PING ) + " Ping pressed: " + player.IsInputCommandPressed( IN_PING ) )

		if ( player in file.cachedOrderPos )
		{
		#if CLIENT
			if ( InPrediction() && IsFirstTimePredicted() )
		#endif // CLIENT
			{
				weapon.AddMod( CAN_INTERRUPT_MOD )
			}


			VantageCompanion_OrderCompanion( player, false, file.cachedOrderPos[player] )

#if SERVER
			int companionState = player.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT )
			if ( companionState == eCompanionState.PERCHED )
			{
				entity companionEnt = VantageCompanion_GetEnt( player )
				EmitSoundOnEntityOnlyToPlayer( player, player, ECHO_FIRST_DEPLOY_DIAG )
				EmitSoundOnEntityExceptToPlayer( companionEnt, player, JET_DRIVE_DEPLOY_ECHO_VOICE_3P )

				vector launchPos = GetInitialDeployPos( player )
				if ( PositionIsInMapBounds( launchPos ) )
					companionEnt.SetAbsOrigin( launchPos )
				companionEnt.SetForwardVector( player.GetViewForward() )

				companionEnt.Show()
			}
#endif
		}
		else
		{
			printt( "Vantage companion launch, player: " + player + " not in file.cachedOrderPos. " )
			#if SERVER
				printt( "--Vantage Server" )
			#endif

			#if CLIENT
				printt( "--Vantage Client " + (InPrediction() ? "Predicted" : "NOT Predicted") + " " + (IsFirstTimePredicted() ? "FirstTime" : "NOT FirstTime" )  )
			#endif
		}

	}

	return -1
}


void function OnWeaponDeactivate_companion_launch( entity weapon )
{
	if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
		printt( "VANTAGE TAC: Deactivate -----------------------------------" )

	entity weaponOwner = weapon.GetWeaponOwner()

	if ( IsValid(weaponOwner ) )
		weaponOwner.Signal( "JetDrive_EndPrelaunch" )

	if ( weaponOwner in file.cachedOrderPos )
		delete file.cachedOrderPos[weaponOwner]

	bool dryFire = false

	#if CLIENT
	if ( weaponOwner == GetLocalViewPlayer() )
	{
	#endif
		int ammoReq  = weapon.GetAmmoPerShot()
		int currAmmo = weapon.GetWeaponPrimaryClipCount()
		dryFire = currAmmo < ammoReq
	#if CLIENT
	}
	#endif

	RemoveAllTacMods( weapon, dryFire )
}

void function RemoveAllTacMods( entity weapon, bool instant = true )
{
	#if CLIENT
	if ( InPrediction() )
	#endif // CLIENT
	{
		weapon.Signal( "Vantage_RemoveAllTacMods" )

		if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
					printt( "--VANTAGE TAC: RemoveAllTacMods" )

		weapon.RemoveMod( IS_LAUNCHING_MOD )
		weapon.RemoveMod( IS_LAUNCHING_ONEHAND_MOD )
		weapon.RemoveMod( FAILED_LOS_MOD )
		if ( instant )
			weapon.RemoveMod( FROM_PERCHED_MOD )
		else
		{
			if ( weapon.HasMod( FROM_PERCHED_MOD ) )
				thread RemoveModAfterDelay( weapon, FROM_PERCHED_MOD, 0.4 )
		}
		weapon.RemoveMod( WHISTLE_FWD_MOD )
		weapon.RemoveMod( WHISTLE_BACK_MOD )
		weapon.RemoveMod( WHISTLE_LEFT_MOD )
		weapon.RemoveMod( WHISTLE_RIGHT_MOD )
		weapon.RemoveMod( CAN_INTERRUPT_MOD )
	}
}

void function RemoveModAfterDelay( entity weapon, string mod, float delay )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "Vantage_RemoveAllTacMods" )

	OnThreadEnd(
		function() : ( weapon, mod )
		{
			#if CLIENT
			if ( InPrediction() )
			{
			#endif
				if ( IsValid( weapon ) )
					weapon.RemoveMod( mod )
			#if CLIENT
			}
			#endif
		}
	)

	wait delay
}


void function CheckForHoldInput_Thread( entity player, entity weapon )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "VantageLaunched_Signal" )

	//#if CLIENT
	//	if ( InPrediction() )
	//#endif // CLIENT
	//	weapon.AddMod( IS_LAUNCHING_MOD )


	file.isButtonHeld[player] <- true

	OnThreadEnd(
		function() : ( player, weapon  )
		{
			//int playerLaunchState = VantageCompanion_GetPlayerLaunchState( player )
			//if ( playerLaunchState != ePlayerLaunchState.NONE )
			//{
			//	#if CLIENT
			//	if ( InPrediction() )
			//	#endif // CLIENT
			//		weapon.RemoveMod( IS_LAUNCHING_MOD )
			//}

			file.isButtonHeld[player] = false
		}
	)

	while ( player.IsInputCommandHeld( IN_OFFHAND1 ) )
	{
		if ( player.IsInputCommandHeld( IN_PING ) || player.IsInputCommandPressed( IN_PING ) )
		{
			//print( "CheckforHold ABORT due to ping" )
			return
		}
		WaitFrame()
	}
}


int function CanLaunchToCompanion( entity player, entity companion )
{
	if ( !IsValid( companion) )
		return eCanLaunchResult.INVALID

	if ( player.ContextAction_IsBusy() )
		return eCanLaunchResult.PLAYER_STATE
	if ( player.ContextAction_IsActive() )
		return eCanLaunchResult.PLAYER_STATE
	if ( player.IsPhaseShifted() )
		return eCanLaunchResult.PLAYER_STATE
	if ( player.Player_IsSkywardFollowing() )
		return eCanLaunchResult.PLAYER_STATE
	if ( HoverVehicle_IsPlayerInAnyVehicle( player ) )
		return eCanLaunchResult.PLAYER_STATE

	vector companionPos = companion.GetOrigin()

	bool shouldCheckOnScreen = GetCurrentPlaylistVarBool( "vantage_los_check_onscreen", true )
	if ( shouldCheckOnScreen )
	{
		//On screen?
		vector playerToCompanionPos = companionPos - player.EyePosition()
		float dotToCompanionPos     = DotProduct( player.GetViewVector(), Normalize( playerToCompanionPos ) )
		if ( dotToCompanionPos < DOT_60DEGREE )
			return eCanLaunchResult.NO_OFF_SCREEN
	}


	bool shouldCheckBlocked = GetCurrentPlaylistVarBool( "vantage_los_check_blocked", true )
	if ( shouldCheckBlocked )
	{
		//Do Trace
		vector startTrace = player.EyePosition()
		vector endTrace = companion.GetOrigin()
		TraceResults tr = TraceLine( startTrace, endTrace , [],TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER, player )
		//DebugDrawSphere( endTrace, 10, (tr.fraction < 1.0) ? COLOR_RED : COLOR_GREEN,true, 0.1)
		if ( tr.fraction < 1.0 )
		{
			//Try another
			if ( ECHO_DO_ADDITIONAL_VIS_TRACES )
			{
				vector offset = (player.GetViewRight()*METERS_TO_INCHES*0.5)
				startTrace = player.EyePosition() + offset + (UP_VECTOR*METERS_TO_INCHES*0.5)
				tr = TraceLine( startTrace, endTrace , [],TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER, player )
				//DebugDrawLine( startTrace, endTrace, (tr.fraction < 1.0) ? COLOR_RED : COLOR_GREEN,true, 0.1)
				if ( tr.fraction < 1.0 )
				{
					startTrace = player.EyePosition()  - offset + (UP_VECTOR*METERS_TO_INCHES*0.5)
					tr = TraceLine( startTrace, endTrace , [],TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER, player )
					//DebugDrawLine(startTrace, endTrace, (tr.fraction < 1.0) ? COLOR_RED : COLOR_GREEN,true, 0.1)
					if ( tr.fraction < 1.0 )
					{
						return eCanLaunchResult.NO_LOS_FAIL
					}
				}
			}
			else
			{
				return eCanLaunchResult.NO_LOS_FAIL
			}
		}
	}

	return eCanLaunchResult.SUCCESS
}

void function PreLaunch_Thread( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "JetDrive_EndPrelaunch" )

	array<entity> jumpJetFXs
	int disableWallClimbHandle

	OnThreadEnd(
		function() : ( player, jumpJetFXs , disableWallClimbHandle)
		{
			if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
				printt( "JETDRIVE PreLaunch OnThreadEnd" )
			
			if ( IsValid( player ) )
				VantageCompanion_SetPlayerLaunchState( player, ePlayerLaunchState.NONE )

			#if SERVER
				DestroyJetDriveJetEffects( jumpJetFXs )

				Vantage_EnableUnarmedADS( player, true )

				if ( IsValid( player ) )
				{
					StatusEffect_Stop( player, disableWallClimbHandle )
					Embark_Allow( player )
					EnableMantle( player )
					player.EnableWeaponTypes( JET_DRIVE_DISABLE_WEAPON_TYPES )
					StopSoundOnEntity( player, JET_DRIVE_PRELAUNCH_BUILDUP_3P )
				}
			#endif

			#if CLIENT
			if ( IsValid( player ) )
				StopSoundOnEntity( player,JET_DRIVE_PRELAUNCH_BUILDUP_1P )
			#endif

		}
	)


	VantageCompanion_SetPlayerLaunchState( player, ePlayerLaunchState.PRELAUNCHING )


	#if SERVER
		EmitSoundOnEntityExceptToPlayer( player, player, JET_DRIVE_PRELAUNCH_BUILDUP_3P )

		player.DisableWeaponTypes( JET_DRIVE_DISABLE_WEAPON_TYPES )
		Embark_Disallow( player )
		DisableMantle( player )
		player.ClearTraverse()

		Vantage_EnableUnarmedADS( player, false )

		CreateJetDriveJetEffects( player, JET_DRIVE_PRE_LAUNCH_FX, jumpJetFXs )
	#endif


	const float TIMEOUT = 2.0
	float endTime = Time() + TIMEOUT
	while ( Time() < endTime )
	{
		if ( JET_DRIVE_DEBUG_DRAW_FLOW_PRINTS )
			printt("JETDRIVE Prelaunch thread..." + (Time() - (endTime - TIMEOUT)) )
		WaitFrame()
	}
}

#if SERVER
void function JetDrive_Thread( entity player, entity companion )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	player.Signal( "JumpPad_GiveDoubleJump" ) //Temp fix to disable double jump if I have one Maybe should call RemoveDoubleJump

	VantageCompanion_SetPlayerLaunchState( player, ePlayerLaunchState.LAUNCHING )

	vector startingPosition = player.GetOrigin()
	vector playerToCompanionPos = companion.GetOrigin() - player.GetOrigin()

	vector offset = (FlattenNormalizeVec( playerToCompanionPos ) * LAUNCH_TARGET_FWD_OFFSET) +  <0.0, 0.0, LAUNCH_TARGET_UP_OFFSET>

	float approxTravelDistance      = Length( playerToCompanionPos )

	float travelSpeed = GetCurrentPlaylistVarFloat( "vantage_tactical_speed", JET_DRIVE_PATH_SPEED )
	float timeOut = 2* approxTravelDistance / travelSpeed
	timeOut = Round( timeOut, 1)

	//player.BeginJetDrive( travelSpeed, JET_DRIVE_PATH_ACCEL, companion.GetOrigin(), companion, offset, timeOut )
	                    
	//if ( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_vantage_tac_jump
	//	player.EnableJetDriveDoubleJump( JET_DRIVE_DOUBLE_JUMP_VEL_UPGRADE, JET_DRIVE_DOUBLE_JUMP_BACK_VEL_FRAC_UPGRADE, JET_DRIVE_DOUBLE_JUMP_1P, JET_DRIVE_DOUBLE_JUMP_3P )
	//else
       
	//	player.EnableJetDriveDoubleJump( JET_DRIVE_DOUBLE_JUMP_VEL, JET_DRIVE_DOUBLE_JUMP_BACK_VEL_FRAC, JET_DRIVE_DOUBLE_JUMP_1P, JET_DRIVE_DOUBLE_JUMP_3P )

	array<entity> jumpJetFXs

	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_tactical" )
	CreateJetDriveJetEffects( player, JET_DRIVE_LAUNCH_FX, jumpJetFXs )
	PlayImpactFXTable( player.GetOrigin(), player, TAKE_OFF_IMPACT_FX_TABLE )
	//HolsterAndDisableWeapons( player )
	player.DisableWeaponTypes( JET_DRIVE_DISABLE_WEAPON_TYPES )
	player.Zipline_Stop()
	player.ClearTraverse()

	Vantage_EnableUnarmedADS( player, false )

	EmitSoundOnEntity( companion, JET_DRIVE_LAUNCH_ECHO_VOICE )
	EmitSoundOnEntityExceptToPlayer( player, player, JET_DRIVE_LAUNCH_3P )
	EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_LAUNCH_1P )
	//DEV_DebugDrawPathPoints( pathPoints , 20)
	//GivePlayerSettingsMods( player, [ "disable_jump_and_gravity" ] )
	DisableMantle( player )

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VANTAGE_JETDRIVE_START, player, player.GetOrigin(), player.GetTeam(), player )

	//thread CreateAndUpdateHawkRopeVFX_Thread( player, companion, travelTime )

	//thread CreateHawkLaunchFX_Thread( player, companion, fxTime ) //Should be connected to this thread maybe?

	OnThreadEnd(
		function() : ( player , jumpJetFXs, startingPosition )
		{
			if ( IsValid ( player ) )
			{
				VantageCompanion_SetPlayerLaunchState( player, ePlayerLaunchState.NONE )

				TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VANTAGE_JETDRIVE_END, player, player.GetOrigin(), player.GetTeam(), player )

				//Test this out, may need to do this a different way if we keep it.
				//ClientCallback_VantageCompanion_Recall( player )

				DestroyJetDriveJetEffects( jumpJetFXs )
				//TakePlayerSettingsMods( player, [ "disable_jump_and_gravity" ] )
				EnableMantle(player)

				vector endPosition = player.GetOrigin()
				int distanceTravelled = int(Distance( startingPosition, endPosition) * INCHES_TO_METERS )
				//printt( " Vantage Tac distance(m) " + distanceTravelled )
				StatsHook_VantageTacticalDistance( player, distanceTravelled )

				float weaponsDelay = GetCurrentPlaylistVarFloat( "vantage_tactical_deploy_weapons_delay", JET_DRIVE_DEPLOY_WEAPONS_TIME )
				thread JetDrive_DeployAndEnableWeaponsAfterDelay( player, weaponsDelay )
				if (PlayerHasPassive(player, ePassives.PAS_VANTAGE))
				{
					Vantage_EnableUnarmedADS( player, true )
				}
				StopSoundOnEntity( player, JET_DRIVE_LAUNCH_3P )

				thread WaitForGround_Thread( player )

			}
		}
	)


	vector previousPos = player.GetOrigin()


}

void function JetDrive_DeployAndEnableWeaponsAfterDelay( entity player, float delay )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd( function() : ( player ) {
		if ( IsValid( player ) )
			//DeployAndEnableWeapons( player )
			player.EnableWeaponTypes( JET_DRIVE_DISABLE_WEAPON_TYPES  )
		if ( player in file.cachedLastWeaponName )
		{
			if ( IsValid( player ) )
			{
				string weaponName = file.cachedLastWeaponName[player]

				//R5DEV-369697 - TNordin - I still can't repro this locally, but there's enough videos that I believe it can happen.
				//I believe the issue is that code thinks we already have an offhand active (Vantage tac) and so trying to equip mp_ability_consumable (also offhand) throws an assert.
				//Declan wrote a helper function to solve this back when Crypto could heal while in drone view (what??) and its still in mp_ability_consumable, so using it here to help solve.
				if ( weaponName == CONSUMABLE_WEAPON_NAME )
					TryTriggerConsumableUse( player )
                                      
                                                      
                                                                                                   
          
				else
					player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, file.cachedLastWeaponName[player] )
			}
		}
	} )

	wait delay
}

void function DoubleJump_Thread( entity player, float timeout )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )


	array<entity> jumpJetFXs
	CreateJetDriveJetEffects( player, JET_DRIVE_DOUBLE_JUMP_FX, jumpJetFXs )

	OnThreadEnd(
		function() : ( player, jumpJetFXs)
		{
			DestroyJetDriveJetEffects( jumpJetFXs )
		}
	)

	wait timeout
}


void function CreateJetDriveJetEffects( entity player, asset jetFXAsset, array<entity> jumpJetFXs)
{
	array<string> attachments = [ "vent_left", "vent_right" ]
	foreach ( attachment in attachments )
	{
		int friendlyID = GetParticleSystemIndex( jetFXAsset )
		entity jetFX   = StartParticleEffectOnEntity_ReturnEntity( player, friendlyID, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( attachment ) )
		jetFX.SetOwner( player )
		SetTeam( jetFX, player.GetTeam() )
		//friendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
		jumpJetFXs.append( jetFX )
	}
}

void function DestroyJetDriveJetEffects( array<entity> jumpJetFXs )
{
	foreach ( fx in jumpJetFXs )
	{
		if ( IsValid( fx ) )
			fx.Destroy()
	}
	jumpJetFXs.clear()
}

void function ClientToServer_AttemptCancelLaunch( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !PlayerHasPassive( player, ePassives.PAS_VANTAGE ) )
		return

	if ( VantageCompanion_GetPlayerLaunchState( player ) != ePlayerLaunchState.PRELAUNCHING )
		return

	entity launchWeapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
	if ( IsValid( launchWeapon ) )
	{
		//launchWeapon.Holster()
		EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_PRELAUNCH_BUILDUP_ABORT_1P )
		//EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_PRELAUNCH_BUILTUP_WRIST_ABORT_1P )
	}
}
#endif


void function WaitForGround_Thread( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid(player) && player.IsOnGround() )
			{
				#if SERVER
					StopSoundOnEntity( player, JET_DRIVE_LAUNCH_END_3P )
				#elseif CLIENT
					StopSoundOnEntity( player, JET_DRIVE_LAUNCH_END_1P )
				#endif
			}
		}
	)

	while ( !player.IsOnGround() )
	{
		WaitFrame()
	}
}

void function DEV_DebugDrawPathPoints( array<vector> pathPoints, float time = 5 )
{
	vector prevPathPoint = ZERO_VECTOR
	foreach( point in pathPoints )
	{
		//DebugDrawSphere( point, 10, COLOR_YELLOW, false, time )
		if ( prevPathPoint != ZERO_VECTOR )
		{
			//DebugDrawLine( point, prevPathPoint, <100,255,0>,false, time )
		}
		prevPathPoint = point
	}
}

void function CodeCallback_OnJetDriveStart( entity player )
{
	#if CLIENT
		//printt("CLIENT OnJetDriveStart")
		//printt( "--Vantage Client " + (InPrediction() ? "Predicted" : "NOT Predicted") + " " + (IsFirstTimePredicted() ? "FirstTime" : "NOT FirstTime" )  )

		                    
		if ( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_vantage_tac_jump
			player.EnableJetDriveDoubleJump( JET_DRIVE_DOUBLE_JUMP_VEL_UPGRADE, JET_DRIVE_DOUBLE_JUMP_BACK_VEL_FRAC_UPGRADE, JET_DRIVE_DOUBLE_JUMP_1P, JET_DRIVE_DOUBLE_JUMP_3P )
		else
        
			player.EnableJetDriveDoubleJump( JET_DRIVE_DOUBLE_JUMP_VEL, JET_DRIVE_DOUBLE_JUMP_BACK_VEL_FRAC, JET_DRIVE_DOUBLE_JUMP_1P, JET_DRIVE_DOUBLE_JUMP_3P )
		if ( InPrediction() )
		{
			thread JetDriveClientThread( player )
		}
	#endif
}


void function CodeCallback_OnJetDriveDuckCancel( entity player )
{
	if ( !IsValid( player ) )
		return

	#if CLIENT
		if ( InPrediction() && IsFirstTimePredicted() )
		{
			if ( player == GetLocalViewPlayer() )
			{
				EmitSoundOnEntity( player, JET_DRIVE_LAUNCH_CANCEL_1P )
				StopSoundOnEntity( player, JET_DRIVE_LAUNCH_1P )
			}
		}
	#endif

	#if SERVER
		EmitSoundOnEntityExceptToPlayer( player, player, JET_DRIVE_LAUNCH_CANCEL_3P )
		StopSoundOnEntity( player, JET_DRIVE_LAUNCH_3P )

		EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_LAUNCH_CANCEL_1P )
		StopSoundOnEntity( player, JET_DRIVE_LAUNCH_1P )
	#endif
}

void function CodeCallback_OnJetDrivePlayerStuck( entity player, float fracCompleted )
{
	#if SERVER
	if ( PlayerHasPassive( player, ePassives.PAS_VANTAGE ) )
	{
		//printt("Player cancelled JetDrive, Stuck at " + fracCompleted )
		const float JET_DRIVE_REFUND_MAX_FRAC = 0.95
		if ( fracCompleted < JET_DRIVE_REFUND_MAX_FRAC )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_PRELAUNCH_BUILDUP_ABORT_1P )
			EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_PRELAUNCH_BUILTUP_WRIST_ABORT_1P )
			entity tacWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
			if ( IsValid( tacWeapon ) )
			{
				float refundFrac = min( (1.0 - fracCompleted), 0.8 )
				//printt("++ JetDrive Refund " + int(100*refundFrac) + "%" )

				float refundAmount = tacWeapon.GetWeaponPrimaryClipCountMax() * refundFrac

				tacWeapon.SetWeaponPrimaryClipCount( refundAmount )
				tacWeapon.SetNextAttackAllowedTime( Time() )
			}
		}
	}
	#endif
}

void function CodeCallback_OnJetDriveDoubleJump( entity player )
{
	#if CLIENT
		HidePlayerHint( JET_DRIVE_DOUBLE_JUMP_HINT_STRING )
		StopSoundOnEntity( player, JET_DRIVE_JUMP_WINDOW_SOUND_1P )
	#endif
	StopSoundOnEntity( player, JET_DRIVE_LAUNCH_END_1P )

	#if SERVER
		thread DoubleJump_Thread( player , 10 )
	#endif
}

void function CodeCallback_OnJetDriveWindowBegin( entity player, float windowTimeOut )
{
	#if SERVER
		EmitSoundOnEntityExceptToPlayer( player, player, JET_DRIVE_LAUNCH_END_3P )
		EmitSoundOnEntityOnlyToPlayer( player, player, JET_DRIVE_LAUNCH_END_1P )
	#endif

	#if CLIENT
		if ( InPrediction() && IsFirstTimePredicted() )
		{
			if ( player == GetLocalViewPlayer() )
				EmitSoundOnEntity( player, JET_DRIVE_LAUNCH_END_1P )

			float time = windowTimeOut - Time()
			thread PlayJetDriveDoubleJumpWindowSound( player, windowTimeOut )
			AddPlayerHint( time, 0, $"", JET_DRIVE_DOUBLE_JUMP_HINT_STRING )
		}
	#endif
}

#if CLIENT

void function AttemptCancelLaunch( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( !PlayerHasPassive( player, ePassives.PAS_VANTAGE ) )
		return

	if ( VantageCompanion_GetPlayerLaunchState( player ) != ePlayerLaunchState.PRELAUNCHING )
		return

	Remote_ServerCallFunction( "ClientToServer_AttemptCancelLaunch" )
}

void function JetDriveClientThread( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	int screenFXID = GetParticleSystemIndex( JET_DRIVE_SCREEN_FX )
	int screenFXHandle = StartParticleEffectOnEntityWithPos( player, screenFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( screenFXHandle, true )
	

	OnThreadEnd(
		function() : ( player, screenFXHandle )
		{
			if ( EffectDoesExist( screenFXHandle ) )
			{
				EffectStop( screenFXHandle, false, true )
			}

			HidePlayerHint( JET_DRIVE_DOUBLE_JUMP_HINT_STRING )

			if ( IsValid ( player ) )
			{
				StopSoundOnEntity( player, JET_DRIVE_JUMP_WINDOW_SOUND_1P )
				StopSoundOnEntity( player, JET_DRIVE_LAUNCH_1P )

				if ( player == GetLocalViewPlayer() )
					thread WaitForGround_Thread( player )
			}
		}
	)


}

void function OnClientAnimEvent_companion_launch( entity weapon, string name )
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( !IsValid( localViewPlayer ) )
		return

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner != localViewPlayer )
		return

	ClientCodeCallback_HandleClientAnimEvent( weaponOwner, name )
}

void function PlayJetDriveDoubleJumpWindowSound(  entity player, float timeout )
{
	if ( !IsValid(player) )
		return

	if ( InPrediction() && IsFirstTimePredicted() )
	{
		EmitSoundOnEntity(player, JET_DRIVE_JUMP_WINDOW_SOUND_1P )

		OnThreadEnd(
			function() : ( player)
			{
				if ( IsValid(player) )
					StopSoundOnEntity( player, JET_DRIVE_JUMP_WINDOW_SOUND_1P )
			}
		)
		while ( Time() < timeout )
			WaitFrame()
	}
}
#endif 